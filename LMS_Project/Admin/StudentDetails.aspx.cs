//using System;
//using System.Data;
//using System.Text;
//using System.Web.UI.WebControls;


//namespace LearningManagementSystem.Admin
//{
//    public partial class StudentDetails : BasePage
//    {
//        StudentDetailsBL bl = new StudentDetailsBL();
//        protected string AttendanceJson = "[0,0]";
//        protected string ProgressJson = "[0,0,0]";

//        protected void Page_Load(object sender, EventArgs e)
//        {
//            //if (Session["InstituteId"] == null) Response.Redirect("~/Default.aspx");
//            if (!IsPostBack)
//            {
//                int userId = Convert.ToInt32(Request.QueryString["id"] ?? "0");
//                if (userId == 0) Response.Redirect("StudentsList.aspx");
//                LoadFullDashboard(userId, "Current");
//            }
//        }

//        protected void Filter_Changed(object sender, EventArgs e)
//        {
//            LoadFullDashboard(Convert.ToInt32(Request.QueryString["id"]), ddlAcademicScope.SelectedValue);
//        }

//        private void LoadFullDashboard(int userId, string filterScope)
//        {
//            DataSet ds = bl.GetStudentFullDetails(userId, filterScope);
//            if (ds == null || ds.Tables.Count < 8 || ds.Tables[0].Rows.Count == 0) return;

//            DataRow profile = ds.Tables[0].Rows[0];

//            // Header Info
//            lblName.Text = profile["FullName"].ToString();
//            lblRoll.Text = profile["RollNumber"].ToString();
//            lblEmail.Text = profile["Email"].ToString();
//            litInitial.Text = profile["FullName"].ToString().Substring(0, 1).ToUpper();
//            lblCourseHeader.Text = profile["CourseName"].ToString();
//            lblSemHeader.Text = profile["SemesterName"].ToString();

//            // --- Interactive Snapshot (Profile Details) ---
//            lbl_Stream.Text = $"{profile["StreamName"]} - {profile["CourseName"]}";
//            lblGender.Text = profile["Gender"].ToString();
//            lblDOB.Text = Convert.ToDateTime(profile["DOB"]).ToString("dd MMM yyyy");
//            lblPhone.Text = profile["ContactNo"].ToString();
//            lblAddress.Text = $"{profile["Address"]}, {profile["City"]}, {profile["Pincode"]}";
//            lblEmerName.Text = profile["EmergencyContactName"].ToString();
//            lblEmerPhone.Text = profile["EmergencyContactNo"].ToString();
//            //lbl_Skills.Text = profile["Skills"]?.ToString() ?? "N/A";

//            //lblStream.Text = $"{profile["StreamName"]} - {profile["CourseName"]}";
//            // --- Skills Section ---
//            StringBuilder sb = new StringBuilder(); // First declaration
//            string rawSkills = profile["Skills"]?.ToString();
//            if (!string.IsNullOrEmpty(rawSkills))
//            {
//                foreach (var s in rawSkills.Split(','))
//                {
//                    sb.Append($"<span class='badge bg-primary...'>{s.Trim()}</span> ");
//                }
//                lbl_Skills.Text = sb.ToString();
//            }

//            // Stats Logic
//            int present = Convert.ToInt32(ds.Tables[4].Rows[0]["Present"]);
//            int absent = Convert.ToInt32(ds.Tables[4].Rows[0]["Absent"]);
//            double attPer = (present + absent) > 0 ? (double)present * 100 / (present + absent) : 0;

//            lblAttPer.Text = attPer.ToString("0") + "%";
//            lblSubCount.Text = ds.Tables[5].Rows.Count.ToString();
//            lblTaskCount.Text = ds.Tables[7].Rows[0]["Assignments"].ToString();


//            // Out-of-the-box Risk Analysis
//            if (attPer < 75)
//                litRiskBadge.Text = "<span class='status-pill status-at-risk'><i class='fas fa-exclamation-triangle me-1'></i> LOW ATTENDANCE RISK</span>";
//            else
//                litRiskBadge.Text = "<span class='status-pill status-good'><i class='fas fa-check-circle me-1'></i> ACADEMICALLY STABLE</span>";

//            // Bind Repeaters
//            rptSubjects.DataSource = ds.Tables[5];
//            rptSubjects.DataBind();
//            rptActivity.DataSource = ds.Tables[6];
//            rptActivity.DataBind();

//            // JSON for Charts
//            AttendanceJson = $"[{present}, {absent}]";
//            ProgressJson = $"[{ds.Tables[7].Rows[0]["Videos"]}, {ds.Tables[7].Rows[0]["Assignments"]}, {ds.Tables[7].Rows[0]["Quiz"]}]";
//            lblOverallProgress.Text = ((Convert.ToInt32(ds.Tables[7].Rows[0]["Videos"]) + Convert.ToInt32(ds.Tables[7].Rows[0]["Assignments"])) / 2).ToString();
//        }

//        protected void btnDownload_Click(object sender, EventArgs e) { /* Report logic */ }
//    }
//}


//-----------------------------------------------------------------------------------------------------------------------



using LearningManagementSystem.BL;
using System;
using System.Data;
using System.Text;
using System.Web.UI;

namespace LearningManagementSystem.Admin
{
    public partial class StudentDetails : BasePage
    {
        private readonly StudentDetailsBL _bl = new StudentDetailsBL();

        // ── Student UserId from query string ──────────────────────────────────
        private int StudentUserId
        {
            get
            {
                // Accept both "UserId" and "id" for backward compatibility
                string raw = Request.QueryString["UserId"] ?? Request.QueryString["id"] ?? "0";
                return int.TryParse(raw, out int id) ? id : 0;
            }
        }

        // ── Selected session (defaults to current global session) ─────────────
        private int ViewSessionId
        {
            get
            {
                string qs = Request.QueryString["SessionId"];
                if (!string.IsNullOrEmpty(qs) && int.TryParse(qs, out int sid) && sid > 0)
                    return sid;
                return SessionId; // from BasePage
            }
        }

        // ── Exposed to ASPX markup ────────────────────────────────────────────
        protected string StudentName = "Student";
        protected string StudentInitials = "S";
        protected string AvatarColor = "#4f46e5";
        protected string RollNumber = "—";
        protected string StreamCourse = "—";
        protected string SessionLabel = "—";
        protected bool IsActive = true;

        // Performance KPIs
        protected decimal AttScore = 0;
        protected decimal AssScore = 0;
        protected decimal QuizScoreVal = 0;
        protected decimal VideoScoreVal = 0;
        protected int AIUsageTotal = 0;
        protected int UnreadNotifsVal = 0;
        protected decimal OverallScore = 0;

        private static readonly string[] AvatarColors = {
            "#4f46e5","#059669","#d97706","#7c3aed",
            "#0284c7","#dc2626","#0891b2","#db2777"
        };

        // ══════════════════════════════════════════════════════════════════════
        //  PAGE LOAD
        // ══════════════════════════════════════════════════════════════════════
        protected void Page_Load(object sender, EventArgs e)
        {
            if (StudentUserId == 0)
            {
                Response.Redirect("StudentsList.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadSessionSelector();
            }

            LoadAllData();
        }

        // ══════════════════════════════════════════════════════════════════════
        //  SESSION SELECTOR (previous sessions dropdown)
        // ══════════════════════════════════════════════════════════════════════
        private void LoadSessionSelector()
        {
            DataTable dt = _bl.GetStudentSessions(StudentUserId);
            ddlViewSession.Items.Clear();
            foreach (DataRow r in dt.Rows)
            {
                bool isCurr = Convert.ToBoolean(r["IsCurrent"]);
                bool isRe = Convert.ToBoolean(r["IsReEnrolled"]);
                string label = r["SessionName"].ToString()
                    + (isCurr ? " (Current)" : "")
                    + (isRe ? " [Re-enrolled]" : "");
                var item = new System.Web.UI.WebControls.ListItem(label, r["SessionId"].ToString());
                if (Convert.ToInt32(r["SessionId"]) == ViewSessionId)
                    item.Selected = true;
                ddlViewSession.Items.Add(item);
            }
        }

        // ══════════════════════════════════════════════════════════════════════
        //  MASTER LOAD — populates all sections
        // ══════════════════════════════════════════════════════════════════════
        private void LoadAllData()
        {
            int uid = StudentUserId;
            int sess = ViewSessionId;

            LoadProfile(uid, sess);
            LoadPerformanceKPIs(uid, sess);
            LoadAttendance(uid, sess);
            LoadSubjects(uid, sess);
            LoadAssignments(uid, sess);
            LoadQuizzes(uid, sess);
            LoadAI(uid, sess);
            LoadActivity(uid, sess);
            LoadNotifications(uid, sess);
            LoadHelpRequests(uid, sess);
            LoadParents(uid, sess);
        }

        // ── PROFILE ───────────────────────────────────────────────────────────
        private void LoadProfile(int uid, int sess)
        {
            DataTable dt = _bl.GetStudentProfile(uid, sess);
            if (dt.Rows.Count == 0) return;
            DataRow r = dt.Rows[0];

            StudentName = r["FullName"].ToString();
            RollNumber = r["RollNumber"].ToString();
            IsActive = Convert.ToBoolean(r["IsActive"]);
            SessionLabel = r["SessionName"].ToString();

            string stream = r["StreamName"].ToString();
            string course = r["CourseName"].ToString();
            StreamCourse = string.IsNullOrWhiteSpace(stream) ? course
                         : string.IsNullOrWhiteSpace(course) ? stream
                         : $"{stream} › {course}";

            // Avatar
            string[] parts = StudentName.Trim().Split(' ');
            StudentInitials = parts.Length == 1
                ? StudentName.Substring(0, Math.Min(2, StudentName.Length)).ToUpper()
                : (parts[0][0].ToString() + parts[parts.Length - 1][0].ToString()).ToUpper();
            AvatarColor = AvatarColors[Math.Abs(StudentName.GetHashCode()) % AvatarColors.Length];

            // Bind profile fields
            lblFullName.Text = H(r["FullName"]);
            lblEmail.Text = H(r["Email"]);
            lblUsername.Text = H(r["Username"]);
            lblGender.Text = H(r["Gender"]);
            lblDOB.Text = FormatDate(r["DOB"]);
            lblContact.Text = H(r["ContactNo"]);
            lblEmerContact.Text = H(r["EmergencyContactName"]) + " (" + H(r["EmergencyContactNo"]) + ")";
            lblFather.Text = H(r["FatherName"]);
            lblMother.Text = H(r["MotherName"]);
            lblAddress.Text = BuildAddress(r);
            lblSkills.Text = H(r["Skills"]);
            lblHobbies.Text = H(r["Hobbies"]);
            lblJoinedDate.Text = FormatDate(r["JoinedDate"]);
            lblEnrolledOn.Text = FormatDate(r["EnrolledOn"]);
            lblRollNo.Text = H(r["RollNumber"]);
            lblStream.Text = H(r["StreamName"]);
            lblCourse.Text = H(r["CourseName"]);
            lblLevel.Text = H(r["LevelName"]);
            lblSemester.Text = H(r["SemesterName"]);
            lblSection.Text = H(r["SectionName"]);
            lblSessionName.Text = H(r["SessionName"]);
            lblIsActive.Text = IsActive ? "Active" : "Inactive";
            lblIsActive.CssClass = IsActive ? "status-badge active" : "status-badge inactive";
            lblReEnrolled.Text = Convert.ToBoolean(r["IsReEnrolled"]) ? "Re-enrolled" : "Original";
        }

        // ── PERFORMANCE KPIs ──────────────────────────────────────────────────
        private void LoadPerformanceKPIs(int uid, int sess)
        {
            DataTable dt = _bl.GetOverallPerformance(uid, sess);
            if (dt.Rows.Count == 0) return;
            DataRow r = dt.Rows[0];

            AttScore = Dec(r["AttendanceScore"]);
            AssScore = Dec(r["AssignmentScore"]);
            QuizScoreVal = Dec(r["QuizScore"]);
            VideoScoreVal = Dec(r["VideoScore"]);
            AIUsageTotal = Int(r["TotalAIUsage"]);
            UnreadNotifsVal = Int(r["UnreadNotifications"]);

            // Weighted overall: 30% att, 25% ass, 25% quiz, 20% video
            OverallScore = Math.Round(AttScore * 0.30m + AssScore * 0.25m +
                                      QuizScoreVal * 0.25m + VideoScoreVal * 0.20m, 1);

            // Bind to labels for server-rendered values used in chart data attrs
            hfAttScore.Value = AttScore.ToString("F1");
            hfAssScore.Value = AssScore.ToString("F1");
            hfQuizScore.Value = QuizScoreVal.ToString("F1");
            hfVideoScore.Value = VideoScoreVal.ToString("F1");
            hfOverall.Value = OverallScore.ToString("F1");
        }

        // ── ATTENDANCE ────────────────────────────────────────────────────────
        private void LoadAttendance(int uid, int sess)
        {
            // Summary
            DataTable dtSum = _bl.GetAttendanceSummary(uid, sess);
            if (dtSum.Rows.Count > 0)
            {
                DataRow r = dtSum.Rows[0];
                lblAttTotal.Text = S(r["TotalDays"]);
                lblAttPresent.Text = S(r["PresentDays"]);
                lblAttAbsent.Text = S(r["AbsentDays"]);
                lblAttLeave.Text = S(r["LeaveDays"]);
                lblAttPct.Text = Dec(r["AttendancePercent"]).ToString("F1") + "%";
                hfAttPct.Value = Dec(r["AttendancePercent"]).ToString("F1");
            }

            // Per-subject
            DataTable dtSub = _bl.GetAttendanceBySubject(uid, sess);
            rptAttSubject.DataSource = dtSub;
            rptAttSubject.DataBind();

            // Monthly trend → JSON for chart
            DataTable dtMonth = _bl.GetAttendanceMonthlyTrend(uid, sess);
            hfAttMonthLabels.Value = BuildJsonArray(dtMonth, "MonthLabel");
            hfAttMonthPresent.Value = BuildJsonArray(dtMonth, "PresentDays");
            hfAttMonthPct.Value = BuildJsonArray(dtMonth, "Percentage");

            // Calendar data → JSON
            DataTable dtCal = _bl.GetAttendanceCalendar(uid, sess);
            hfCalData.Value = BuildCalendarJson(dtCal);
        }

        // ── SUBJECTS ─────────────────────────────────────────────────────────
        private void LoadSubjects(int uid, int sess)
        {
            DataTable dt = _bl.GetEnrolledSubjects(uid, sess);
            rptSubjects.DataSource = dt;
            rptSubjects.DataBind();

            // Also build video progress
            DataTable dtVid = _bl.GetVideoProgress(uid, sess);
            rptVideoProgress.DataSource = dtVid;
            rptVideoProgress.DataBind();
        }

        // ── ASSIGNMENTS ───────────────────────────────────────────────────────
        private void LoadAssignments(int uid, int sess)
        {
            DataTable dt = _bl.GetAssignments(uid, sess);
            rptAssignments.DataSource = dt;
            rptAssignments.DataBind();

            int total = dt.Rows.Count;
            int graded = 0; int submitted = 0; int pending = 0; int missed = 0;
            foreach (DataRow r in dt.Rows)
            {
                switch (r["SubmissionStatus"].ToString())
                {
                    case "Graded": graded++; break;
                    case "Submitted": submitted++; break;
                    case "Pending": pending++; break;
                    case "Missed": missed++; break;
                }
            }
            lblAsgTotal.Text = total.ToString();
            lblAsgGraded.Text = graded.ToString();
            lblAsgSubmit.Text = submitted.ToString();
            lblAsgPending.Text = pending.ToString();
            lblAsgMissed.Text = missed.ToString();
            hfAsgChartData.Value = $"[{graded},{submitted},{pending},{missed}]";
        }

        // ── QUIZZES ───────────────────────────────────────────────────────────
        private void LoadQuizzes(int uid, int sess)
        {
            DataTable dt = _bl.GetQuizResults(uid, sess);
            rptQuizzes.DataSource = dt;
            rptQuizzes.DataBind();

            int total = dt.Rows.Count; int passed = 0; int failed = 0; int notAttempted = 0;
            decimal totalPct = 0; int attempted = 0;
            foreach (DataRow r in dt.Rows)
            {
                switch (r["QuizStatus"].ToString())
                {
                    case "Passed": passed++; totalPct += Dec(r["ScorePercent"]); attempted++; break;
                    case "Failed": failed++; totalPct += Dec(r["ScorePercent"]); attempted++; break;
                    case "Not Attempted": notAttempted++; break;
                }
            }
            lblQzTotal.Text = total.ToString();
            lblQzPassed.Text = passed.ToString();
            lblQzFailed.Text = failed.ToString();
            lblQzNA.Text = notAttempted.ToString();
            lblQzAvg.Text = attempted > 0
                ? (totalPct / attempted).ToString("F1") + "%" : "—";
            hfQzChartData.Value = $"[{passed},{failed},{notAttempted}]";
        }

        // ── AI ────────────────────────────────────────────────────────────────
        private void LoadAI(int uid, int sess)
        {
            DataTable dtSum = _bl.GetAIUsageSummary(uid, sess);
            rptAISummary.DataSource = dtSum;
            rptAISummary.DataBind();

            DataTable dtHist = _bl.GetAIHistory(uid, sess);
            rptAIHistory.DataSource = dtHist;
            rptAIHistory.DataBind();

            // Chart data
            var labels = new StringBuilder("[");
            var counts = new StringBuilder("[");
            bool first = true;
            foreach (DataRow r in dtSum.Rows)
            {
                if (!first) { labels.Append(","); counts.Append(","); }
                labels.Append($"\"{r["Type"]}\"");
                counts.Append(r["UsageCount"]);
                first = false;
            }
            labels.Append("]"); counts.Append("]");
            hfAILabels.Value = labels.ToString();
            hfAICounts.Value = counts.ToString();
        }

        // ── ACTIVITY ─────────────────────────────────────────────────────────
        private void LoadActivity(int uid, int sess)
        {
            DataTable dt = _bl.GetActivityLog(uid, sess);
            rptActivity.DataSource = dt;
            rptActivity.DataBind();
        }

        // ── NOTIFICATIONS ─────────────────────────────────────────────────────
        private void LoadNotifications(int uid, int sess)
        {
            DataTable dt = _bl.GetNotifications(uid, sess);
            rptNotifications.DataSource = dt;
            rptNotifications.DataBind();
        }

        // ── HELP REQUESTS ─────────────────────────────────────────────────────
        private void LoadHelpRequests(int uid, int sess)
        {
            DataTable dt = _bl.GetHelpRequests(uid, sess);
            rptHelp.DataSource = dt;
            rptHelp.DataBind();
        }

        // ── PARENTS ───────────────────────────────────────────────────────────
        private void LoadParents(int uid, int sess)
        {
            DataTable dt = _bl.GetLinkedParents(uid, sess);
            rptParents.DataSource = dt;
            rptParents.DataBind();
            lblParentCount.Text = dt.Rows.Count.ToString();
        }

        // ── SESSION SWITCH ────────────────────────────────────────────────────
        protected void ddlViewSession_Changed(object sender, EventArgs e)
        {
            int newSess = int.TryParse(ddlViewSession.SelectedValue, out int s) ? s : SessionId;
            Response.Redirect($"StudentDetails.aspx?UserId={StudentUserId}&SessionId={newSess}");
        }

        // ══════════════════════════════════════════════════════════════════════
        //  HELPERS
        // ══════════════════════════════════════════════════════════════════════
        protected string GetAttColor(object pct)
        {
            decimal v = Dec(pct);
            if (v >= 75) return "#059669";
            if (v >= 50) return "#d97706";
            return "#dc2626";
        }

        protected string GetStatusClass(object status)
        {
            switch (status?.ToString())
            {
                case "Graded": return "tag-graded";
                case "Submitted": return "tag-submitted";
                case "Pending": return "tag-pending";
                case "Missed": return "tag-missed";
                default: return "tag-pending";
            }
        }

        protected string GetQuizClass(object status)
        {
            switch (status?.ToString())
            {
                case "Passed": return "tag-graded";
                case "Failed": return "tag-missed";
                case "Not Attempted": return "tag-pending";
                default: return "tag-pending";
            }
        }

        protected string GetActivityIcon(object type)
        {
            switch (type?.ToString())
            {
                case "StudentAdded": return "fa-user-plus";
                case "StudentUpdated": return "fa-pen";
                case "StudentReEnrolled": return "fa-sync";
                case "StudentActivated": return "fa-check-circle";
                case "StudentDeactivated": return "fa-ban";
                default: return "fa-circle";
            }
        }

        protected string GetAITypeColor(object type)
        {
            switch (type?.ToString())
            {
                case "Summary": return "#4f46e5";
                case "Notes": return "#059669";
                case "Quiz": return "#d97706";
                case "Doubt": return "#0284c7";
                default: return "#64748b";
            }
        }

        protected string FormatDate(object val) =>
            val != null && val != DBNull.Value && DateTime.TryParse(val.ToString(), out DateTime d)
                ? d.ToString("dd MMM yyyy") : "—";

        protected string FormatDateTime(object val) =>
            val != null && val != DBNull.Value && DateTime.TryParse(val.ToString(), out DateTime d)
                ? d.ToString("dd MMM yyyy hh:mm tt") : "—";

        private static string H(object val) =>
            System.Web.HttpUtility.HtmlEncode(val?.ToString() ?? "");

        private static string S(object val) => val?.ToString() ?? "0";

        private static decimal Dec(object val)
        {
            if (val == null || val == DBNull.Value) return 0;
            return decimal.TryParse(val.ToString(), out decimal d) ? d : 0;
        }

        private static int Int(object val)
        {
            if (val == null || val == DBNull.Value) return 0;
            return int.TryParse(val.ToString(), out int i) ? i : 0;
        }

        private string BuildAddress(DataRow r)
        {
            var parts = new System.Collections.Generic.List<string>();
            foreach (string col in new[] { "Address", "City", "Country", "Pincode" })
            {
                string v = r[col]?.ToString()?.Trim();
                if (!string.IsNullOrWhiteSpace(v) && v != "N/A" && v != "0")
                    parts.Add(H(v));
            }
            return parts.Count > 0 ? string.Join(", ", parts) : "—";
        }

        private static string BuildJsonArray(DataTable dt, string col)
        {
            if (dt == null || dt.Rows.Count == 0) return "[]";
            var sb = new StringBuilder("[");
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                if (i > 0) sb.Append(",");
                object val = dt.Rows[i][col];
                bool isNum = val is int || val is long || val is decimal || val is double || val is float;
                if (isNum) sb.Append(val);
                else sb.Append($"\"{val?.ToString()?.Replace("\"", "\\\"")}\"");
            }
            sb.Append("]");
            return sb.ToString();
        }

        private static string BuildCalendarJson(DataTable dt)
        {
            if (dt == null || dt.Rows.Count == 0) return "[]";
            var sb = new StringBuilder("[");
            bool first = true;
            foreach (DataRow r in dt.Rows)
            {
                if (!first) sb.Append(",");
                string date = Convert.ToDateTime(r["Date"]).ToString("yyyy-MM-dd");
                string status = r["DayStatus"].ToString();
                sb.Append($"{{\"date\":\"{date}\",\"status\":\"{status}\"}}");
                first = false;
            }
            sb.Append("]");
            return sb.ToString();
        }

        // Exposed helper for ASPX percent-bar width capping
        protected string BarWidth(object pct)
        {
            decimal v = Dec(pct);
            if (v > 100) v = 100;
            if (v < 0) v = 0;
            return v.ToString("F1");
        }
    }
}