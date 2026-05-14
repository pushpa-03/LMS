using LearningManagementSystem.BL;
using System;
using System.Data;
using System.Text;
using System.Web.UI.WebControls;

namespace LearningManagementSystem.Admin
{
    public partial class TeacherDetails : BasePage
    {
        private readonly TeacherDetailsBL _bl = new TeacherDetailsBL();

        // ── QueryString ids ──────────────────────────────────────────────────
        private int TeacherUserId
        {
            get
            {
                string raw = Request.QueryString["id"] ?? Request.QueryString["UserId"] ?? "0";
                return int.TryParse(raw, out int id) ? id : 0;
            }
        }

        private int ViewSessionId
        {
            get
            {
                string qs = Request.QueryString["SessionId"];
                if (!string.IsNullOrEmpty(qs) && int.TryParse(qs, out int s) && s > 0) return s;
                return SessionId;
            }
        }

        // ── Properties rendered in ASPX ──────────────────────────────────────
        protected string TeacherName = "Teacher";
        protected string TeacherInitials = "T";
        protected string AvatarColor = "#4f46e5";
        protected string ProfileImage = "";
        protected bool IsActive = true;

        private static readonly string[] Colors = {
            "#4f46e5","#059669","#d97706","#7c3aed",
            "#0284c7","#dc2626","#0891b2","#db2777"
        };

        // ════════════════════════════════════════════════════════════════════
        //  PAGE LOAD
        // ════════════════════════════════════════════════════════════════════
        protected void Page_Load(object sender, EventArgs e)
        {
            if (TeacherUserId == 0) { Response.Redirect("TeacherList.aspx"); return; }
            if (!IsPostBack) LoadSessionSelector();
            LoadAllData();
        }

        private void LoadSessionSelector()
        {
            DataTable dt = _bl.GetTeacherSessions(TeacherUserId);
            ddlSession.Items.Clear();
            foreach (DataRow r in dt.Rows)
            {
                bool isCurr = Convert.ToBoolean(r["IsCurrent"]);
                var item = new ListItem(r["SessionName"] + (isCurr ? " (Current)" : ""),
                                        r["SessionId"].ToString());
                if (Convert.ToInt32(r["SessionId"]) == ViewSessionId) item.Selected = true;
                ddlSession.Items.Add(item);
            }
        }

        protected void ddlSession_Changed(object sender, EventArgs e)
        {
            int s = int.TryParse(ddlSession.SelectedValue, out int sv) ? sv : SessionId;
            Response.Redirect($"TeacherDetails.aspx?id={TeacherUserId}&SessionId={s}");
        }

        private void LoadAllData()
        {
            int uid = TeacherUserId, sess = ViewSessionId;
            LoadProfile(uid, sess);
            LoadKPIs(uid, sess);
            LoadSubjects(uid, sess);
            LoadRatings(uid, sess);
            LoadAssignments(uid, sess);
            LoadAttendance(uid, sess);
            LoadVideoTrend(uid, sess);
            LoadActivity(uid, sess);
            LoadNotifications(uid, sess);
            LoadHelp(uid, sess);
            LoadAI(uid, sess);
            LoadComments(uid, sess);
        }

        // ── Profile ──────────────────────────────────────────────────────────
        private void LoadProfile(int uid, int sess)
        {
            DataTable dt = _bl.GetTeacherProfile(uid, sess);
            if (dt.Rows.Count == 0) return;
            DataRow r = dt.Rows[0];

            TeacherName = r["FullName"].ToString();
            IsActive = Convert.ToBoolean(r["IsActive"]);
            ProfileImage = r["ProfileImage"].ToString();

            string[] parts = TeacherName.Trim().Split(' ');
            TeacherInitials = parts.Length == 1
                ? TeacherName.Substring(0, Math.Min(2, TeacherName.Length)).ToUpper()
                : (parts[0][0].ToString() + parts[parts.Length - 1][0]).ToUpper();
            AvatarColor = Colors[Math.Abs(TeacherName.GetHashCode()) % Colors.Length];

            lblFullName.Text = H(r["FullName"]);
            lblEmail.Text = H(r["Email"]);
            lblUsername.Text = H(r["Username"]);
            lblGender.Text = H(r["Gender"]);
            lblDOB.Text = FmtDate(r["DOB"]);
            lblContact.Text = H(r["ContactNo"]);
            lblEmg.Text = H(r["EmergencyContactName"]) + " — " + H(r["EmergencyContactNo"]);
            lblFather.Text = H(r["FatherName"]);
            lblMother.Text = H(r["MotherName"]);
            lblAddress.Text = BuildAddr(r);
            lblSkills.Text = H(r["Skills"]);
            lblJoined.Text = FmtDate(r["JoinedDate"]);
            lblEmpId.Text = H(r["EmployeeId"]);
            lblDesig.Text = H(r["Designation"]);
            lblQual.Text = H(r["Qualification"]);
            lblExp.Text = r["ExperienceYears"] + " yrs";
            lblStream.Text = H(r["StreamName"]);
            lblSession.Text = H(r["SessionName"]);
            lblStatus.Text = IsActive ? "Active" : "Inactive";
            lblStatus.CssClass = IsActive ? "status-badge active" : "status-badge inactive";
            lblLastLogin.Text = r["LastLogin"] == DBNull.Value ? "Never" : FmtDateTime(r["LastLogin"]);
            lblCreatedOn.Text = FmtDate(r["CreatedOn"]);
        }

        // ── KPIs ─────────────────────────────────────────────────────────────
        private void LoadKPIs(int uid, int sess)
        {
            DataTable dt = _bl.GetTeacherKPIs(uid, sess);
            if (dt.Rows.Count == 0) return;
            DataRow r = dt.Rows[0];
            hfKpiSubjects.Value = N(r["TotalSubjects"]);
            hfKpiVideos.Value = N(r["TotalVideos"]);
            hfKpiViews.Value = N(r["TotalViews"]);
            hfKpiAssignments.Value = N(r["TotalAssignments"]);
            hfKpiStudents.Value = N(r["TotalStudents"]);
            hfKpiAI.Value = N(r["AIInteractions"]);
            hfKpiRating.Value = Dec(r["AvgVideoRating"]).ToString("F1");
        }

        // ── Subjects ─────────────────────────────────────────────────────────
        private void LoadSubjects(int uid, int sess)
        {
            DataTable dt = _bl.GetAssignedSubjects(uid, sess);

            // Build chart JSON
            var lbl = new StringBuilder("[");
            var pct = new StringBuilder("[");
            var enr = new StringBuilder("[");
            bool f = true;
            foreach (DataRow r in dt.Rows)
            {
                if (!f) { lbl.Append(","); pct.Append(","); enr.Append(","); }
                lbl.Append($"\"{EscJs(r["SubjectName"].ToString())}\"");
                pct.Append(Dec(r["SyllabusCompletedPct"]).ToString("F1"));
                enr.Append(N(r["EnrolledStudents"]));
                f = false;
            }
            lbl.Append("]"); pct.Append("]"); enr.Append("]");
            hfSubjectLabels.Value = lbl.ToString();
            hfSyllabusPcts.Value = pct.ToString();
            hfEnrollCounts.Value = enr.ToString();

            rptSubjects.DataSource = dt;
            rptSubjects.DataBind();
            rptSubjectChapters.DataSource = dt;
            rptSubjectChapters.DataBind();
        }

        protected void rptSubjectChapters_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item &&
                e.Item.ItemType != ListItemType.AlternatingItem) return;

            var hfSub = (HiddenField)e.Item.FindControl("hfSubId");
            var rptCh = (Repeater)e.Item.FindControl("rptChapters");
            var lblSub = (Label)e.Item.FindControl("lblSubNameTree");
            if (hfSub == null || rptCh == null) return;

            int subId = Convert.ToInt32(hfSub.Value);
            DataRow dr = ((DataRowView)e.Item.DataItem).Row;
            if (lblSub != null) lblSub.Text = H(dr["SubjectName"].ToString());

            rptCh.DataSource = _bl.GetChaptersWithContent(subId, ViewSessionId);
            rptCh.DataBind();
        }

        public void rptChapters_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item &&
                e.Item.ItemType != ListItemType.AlternatingItem) return;

            var hfCh = (HiddenField)e.Item.FindControl("hfChapterId");
            var rptVid = (Repeater)e.Item.FindControl("rptChapterVideos");
            if (hfCh == null || rptVid == null) return;

            rptVid.DataSource = _bl.GetVideosByChapterFull(
                Convert.ToInt32(hfCh.Value), ViewSessionId);
            rptVid.DataBind();
        }

        // ── Ratings ──────────────────────────────────────────────────────────
        private void LoadRatings(int uid, int sess)
        {
            DataTable dt = _bl.GetVideoRatingsSummary(uid, sess);
            rptRatings.DataSource = dt;
            rptRatings.DataBind();

            var lbl = new StringBuilder("[");
            var avg = new StringBuilder("[");
            var vws = new StringBuilder("[");
            int i = 0;
            foreach (DataRow r in dt.Rows)
            {
                if (i >= 8) break;
                if (i > 0) { lbl.Append(","); avg.Append(","); vws.Append(","); }
                string t = r["VideoTitle"].ToString();
                if (t.Length > 20) t = t.Substring(0, 20) + "…";
                lbl.Append($"\"{EscJs(t)}\"");
                avg.Append(Dec(r["AvgRating"]).ToString("F1"));
                vws.Append(N(r["TotalViews"]));
                i++;
            }
            lbl.Append("]"); avg.Append("]"); vws.Append("]");
            hfRatingLabels.Value = lbl.ToString();
            hfRatingAvgs.Value = avg.ToString();
            hfRatingViews.Value = vws.ToString();
        }

        // ── Assignments ──────────────────────────────────────────────────────
        private void LoadAssignments(int uid, int sess)
        {
            DataTable dt = _bl.GetAssignments(uid, sess);
            rptAssignments.DataSource = dt;
            rptAssignments.DataBind();

            var lbl = new StringBuilder("[");
            var subs = new StringBuilder("[");
            var tot = new StringBuilder("[");
            int i = 0;
            foreach (DataRow r in dt.Rows)
            {
                if (i >= 6) break;
                if (i > 0) { lbl.Append(","); subs.Append(","); tot.Append(","); }
                string t = r["Title"].ToString();
                if (t.Length > 18) t = t.Substring(0, 18) + "…";
                lbl.Append($"\"{EscJs(t)}\"");
                subs.Append(N(r["Submissions"]));
                tot.Append(N(r["TotalStudents"]));
                i++;
            }
            lbl.Append("]"); subs.Append("]"); tot.Append("]");
            hfAsgLabels.Value = lbl.ToString();
            hfAsgSubs.Value = subs.ToString();
            hfAsgTotals.Value = tot.ToString();
            hfAsgTotal.Value = dt.Rows.Count.ToString();
        }

        // ── Attendance ───────────────────────────────────────────────────────
        private void LoadAttendance(int uid, int sess)
        {
            DataTable dt = _bl.GetAttendanceBySubject(uid, sess);
            DataTable dtTop = _bl.GetTopAttendingClasses(uid, sess);
            rptAttendance.DataSource = dt; rptAttendance.DataBind();
            rptTopClasses.DataSource = dtTop; rptTopClasses.DataBind();

            var lbl = new StringBuilder("[");
            var pct = new StringBuilder("[");
            bool f = true;
            foreach (DataRow r in dt.Rows)
            {
                if (!f) { lbl.Append(","); pct.Append(","); }
                lbl.Append($"\"{EscJs(r["SubjectCode"].ToString())}\"");
                pct.Append(Dec(r["AvgAttendancePct"]).ToString("F1"));
                f = false;
            }
            lbl.Append("]"); pct.Append("]");
            hfAttLabels.Value = lbl.ToString();
            hfAttPcts.Value = pct.ToString();
        }

        // ── Video trend ──────────────────────────────────────────────────────
        private void LoadVideoTrend(int uid, int sess)
        {
            DataTable dt = _bl.GetVideoUploadTrend(uid, sess);
            var lbl = new StringBuilder("[");
            var cnt = new StringBuilder("[");
            var vws = new StringBuilder("[");
            bool f = true;
            foreach (DataRow r in dt.Rows)
            {
                if (!f) { lbl.Append(","); cnt.Append(","); vws.Append(","); }
                lbl.Append($"\"{EscJs(r["MonthLabel"].ToString())}\"");
                cnt.Append(N(r["VideoCount"]));
                vws.Append(N(r["TotalViews"]));
                f = false;
            }
            lbl.Append("]"); cnt.Append("]"); vws.Append("]");
            hfTrendLabels.Value = lbl.ToString();
            hfTrendCounts.Value = cnt.ToString();
            hfTrendViews.Value = vws.ToString();
        }

        // ── Communications ───────────────────────────────────────────────────
        private void LoadActivity(int uid, int sess)
        { rptActivity.DataSource = _bl.GetActivityLog(uid, sess); rptActivity.DataBind(); }

        private void LoadNotifications(int uid, int sess)
        { rptNotifs.DataSource = _bl.GetNotifications(uid, sess); rptNotifs.DataBind(); }

        private void LoadHelp(int uid, int sess)
        { rptHelp.DataSource = _bl.GetHelpRequests(uid, sess); rptHelp.DataBind(); }

        private void LoadAI(int uid, int sess)
        {
            DataTable dt = _bl.GetAIUsageOnVideos(uid, sess);
            rptAI.DataSource = dt; rptAI.DataBind();
            hfAITotal.Value = dt.Rows.Count.ToString();
        }

        private void LoadComments(int uid, int sess)
        {
            DataTable dt = _bl.GetVideoComments(uid, sess);
            rptComments.DataSource = dt; rptComments.DataBind();
            hfCommentTotal.Value = dt.Rows.Count.ToString();
        }

        // ════════════════════════════════════════════════════════════════════
        //  PROTECTED HELPERS — all MUST be protected (called from .aspx)
        // ════════════════════════════════════════════════════════════════════

        /// <summary>Caps value 0–100, returns string for CSS width.</summary>
        protected string Bar(object pct)
        {
            decimal v = Dec(pct);
            return Math.Min(Math.Max(v, 0), 100).ToString("F1");
        }

        /// <summary>Submission rate bar width: subs / total * 100.</summary>
        protected string SubRate(object submissions, object total)
        {
            decimal s = Dec(submissions), t = Dec(total);
            if (t == 0) return "0";
            return Math.Min(s / t * 100, 100).ToString("F1");
        }

        /// <summary>Submission rate as formatted percent string.</summary>
        protected string SubRatePct(object submissions, object total)
        {
            decimal s = Dec(submissions), t = Dec(total);
            if (t == 0) return "0%";
            return Math.Round(s / t * 100, 0) + "%";
        }

        /// <summary>Color based on attendance %.</summary>
        protected string AttColor(object pct)
        {
            decimal v = Dec(pct);
            if (v >= 75) return "#059669";
            if (v >= 50) return "#d97706";
            return "#dc2626";
        }

        /// <summary>Star HTML string for a 1–5 rating.</summary>
        protected string StarHtml(object rating)
        {
            decimal r = Dec(rating);
            var sb = new StringBuilder();
            for (int i = 1; i <= 5; i++)
                sb.Append(i <= (int)Math.Round(r)
                    ? "<span style='color:#f59e0b'>★</span>"
                    : "<span style='color:#e2e8f0'>★</span>");
            return sb.ToString();
        }

        /// <summary>Rating color: green ≥4, amber ≥3, red below.</summary>
        protected string RatingColor(object rating)
        {
            decimal v = Dec(rating);
            if (v >= 4) return "var(--green)";
            if (v >= 3) return "var(--amber)";
            return "var(--red)";
        }

        /// <summary>FA icon class for activity type.</summary>
        protected string ActivityIcon(object t)
        {
            switch (t?.ToString())
            {
                case "VideoUploaded": return "fa-video";
                case "AssignmentAdded": return "fa-file-alt";
                case "Login": return "fa-sign-in-alt";
                case "ProfileUpdated": return "fa-user-edit";
                default: return "fa-circle";
            }
        }

        protected string FmtDate(object val)
            => val != null && val != DBNull.Value
               && DateTime.TryParse(val.ToString(), out DateTime d)
               ? d.ToString("dd MMM yyyy") : "—";

        protected string FmtDateTime(object val)
            => val != null && val != DBNull.Value
               && DateTime.TryParse(val.ToString(), out DateTime d)
               ? d.ToString("dd MMM yyyy hh:mm tt") : "—";

        /// <summary>HTML-encode helper for ASPX expressions.</summary>
        protected string H(object v)
            => System.Web.HttpUtility.HtmlEncode(v?.ToString() ?? "");

        /// <summary>Safe decimal conversion.</summary>
        protected decimal Dec(object v)
        {
            if (v == null || v == DBNull.Value) return 0;
            return decimal.TryParse(v.ToString(), out decimal d) ? d : 0;
        }

        // ── Private helpers (not called from ASPX) ────────────────────────
        private static string N(object v) => v?.ToString() ?? "0";

        private static string EscJs(string s)
            => (s ?? "").Replace("\\", "\\\\").Replace("\"", "\\\"");

        private static string BuildAddr(DataRow r)
        {
            var parts = new System.Collections.Generic.List<string>();
            foreach (string col in new[] { "Address", "City", "Country", "Pincode" })
            {
                string v = r[col]?.ToString()?.Trim();
                if (!string.IsNullOrWhiteSpace(v) && v != "0")
                    parts.Add(System.Web.HttpUtility.HtmlEncode(v));
            }
            return parts.Count > 0 ? string.Join(", ", parts) : "—";
        }
    }
}


//===================================================================================================================

// ===== working code (12/03/26) ==========================================

//using LearningManagementSystem.BL;
//using System;
//using System.Data;
//using System.Web.UI;

//namespace LearningManagementSystem.Admin
//{
//    public partial class TeacherDetails : BasePage
//    {
//        AddTeacherBL tbl = new AddTeacherBL();
//        AssignSubjectFacultyBL sbl = new AssignSubjectFacultyBL();

//        protected void Page_Load(object sender, EventArgs e)
//        {

//            if (Request.QueryString["id"] != null && !IsPostBack)
//            {
//                int userId = Convert.ToInt32(Request.QueryString["id"]);
//                LoadProfile(userId);
//                LoadSubjectHistory(userId);
//            }
//        }
//        private void LoadProfile(int userId)
//        {
//            DataTable dt = tbl.GetTeacherById(userId, SessionId);
//            if (dt != null && dt.Rows.Count > 0)
//            {
//                DataRow row = dt.Rows[0];
//                string fullName = row["FullName"].ToString();
//                litFullName.Text = fullName;
//                litEmpId.Text = row["EmployeeId"].ToString();
//                litDesignation.Text = row["Designation"].ToString();
//                litInitial.Text = fullName.Substring(0, 1).ToUpper();

//                // Basic Info
//                litContact.Text = row["ContactNo"].ToString();
//                litEmail.Text = row["Email"].ToString();

//                // Profile Image Logic
//                if (row["ProfileImage"] != DBNull.Value && !string.IsNullOrEmpty(row["ProfileImage"].ToString()))
//                {
//                    imgProfile.ImageUrl = row["ProfileImage"].ToString();
//                    imgProfile.Visible = true;
//                    divInitial.Visible = false;
//                }

//                // Show Full Details only if they exist
//                if (row["ExperienceYears"] != DBNull.Value || row["Address"] != DBNull.Value)
//                {
//                    phFullDetails.Visible = true;
//                    litDOB.Text = Convert.ToDateTime(row["DOB"]).ToString("dd MMM yyyy");
//                    litExp.Text = row["ExperienceYears"].ToString();
//                    litAddress.Text = $"{row["Address"]}, {row["City"]}";
//                }

//                // DYNAMIC GRAPH CALCULATION
//                // Typically: (Completed Topics / Total Topics) * 100
//                // For now, setting a dynamic calculation or a default
//                litProgressText.Text = "82"; // This should be calculated from a query to Materials/Syllabus table

//                // DYNAMIC RATING
//                litRating.Text = "4.9";
//            }
//        }

//        private void LoadSubjectHistory(int userId)
//        {
//            int instituteId = InstituteId;
//            int currentSessionId = SessionId;

//            // Fetching subjects assigned to this specific teacher
//            DataTable dt = sbl.GetAllByTeacher(instituteId, userId);
//            rptSubjects.DataSource = dt;
//            rptSubjects.DataBind();
//            litSubCount.Text = dt.Rows.Count.ToString();
//        }
//    }
//}


//----------------------------------------------------------------------------------------------------------------------


//using LearningManagementSystem.BL;
//using System;
//using System.Data;
//using System.Text;
//using System.Web.UI.WebControls;

//namespace LearningManagementSystem.Admin
//{
//    public partial class TeacherDetails : BasePage
//    {
//        private readonly TeacherDetailsBL _bl = new TeacherDetailsBL();

//        // ── Teacher UserId from querystring ──────────────────────────────────
//        private int TeacherUserId
//        {
//            get
//            {
//                string raw = Request.QueryString["id"] ?? Request.QueryString["UserId"] ?? "0";
//                return int.TryParse(raw, out int id) ? id : 0;
//            }
//        }

//        // ── Selected session ─────────────────────────────────────────────────
//        private int ViewSessionId
//        {
//            get
//            {
//                string qs = Request.QueryString["SessionId"];
//                if (!string.IsNullOrEmpty(qs) && int.TryParse(qs, out int s) && s > 0)
//                    return s;
//                return SessionId;
//            }
//        }

//        // ── Properties exposed to ASPX markup ────────────────────────────────
//        protected string TeacherName = "Teacher";
//        protected string TeacherInitials = "T";
//        protected string AvatarColor = "#4f46e5";
//        protected string ProfileImage = "";
//        protected bool IsActive = true;

//        // KPI values (set in code, rendered to HF for JS)
//        protected int TotalSubjects = 0;
//        protected int TotalVideos = 0;
//        protected int TotalViews = 0;
//        protected int TotalAssignments = 0;
//        protected int TotalStudents = 0;
//        protected int AIInteractions = 0;
//        protected decimal AvgRating = 0;

//        private static readonly string[] Colors = {
//            "#4f46e5","#059669","#d97706","#7c3aed",
//            "#0284c7","#dc2626","#0891b2","#db2777"
//        };

//        // ═══════════════════════════════════════════════════════════════════
//        //  PAGE LOAD
//        // ═══════════════════════════════════════════════════════════════════
//        protected void Page_Load(object sender, EventArgs e)
//        {
//            if (TeacherUserId == 0)
//            {
//                Response.Redirect("TeacherList.aspx");
//                return;
//            }

//            if (!IsPostBack)
//                LoadSessionSelector();

//            LoadAllData();
//        }

//        // ── Session dropdown ─────────────────────────────────────────────────
//        private void LoadSessionSelector()
//        {
//            DataTable dt = _bl.GetTeacherSessions(TeacherUserId);
//            ddlSession.Items.Clear();
//            foreach (DataRow r in dt.Rows)
//            {
//                bool isCurr = Convert.ToBoolean(r["IsCurrent"]);
//                string label = r["SessionName"] + (isCurr ? " (Current)" : "");
//                var item = new ListItem(label, r["SessionId"].ToString());
//                if (Convert.ToInt32(r["SessionId"]) == ViewSessionId)
//                    item.Selected = true;
//                ddlSession.Items.Add(item);
//            }
//        }

//        protected void ddlSession_Changed(object sender, EventArgs e)
//        {
//            int s = int.TryParse(ddlSession.SelectedValue, out int sv) ? sv : SessionId;
//            Response.Redirect($"TeacherDetails.aspx?id={TeacherUserId}&SessionId={s}");
//        }

//        // ── Master load ──────────────────────────────────────────────────────
//        private void LoadAllData()
//        {
//            int uid = TeacherUserId;
//            int sess = ViewSessionId;

//            LoadProfile(uid, sess);
//            LoadKPIs(uid, sess);
//            LoadSubjects(uid, sess);
//            LoadRatings(uid, sess);
//            LoadAssignments(uid, sess);
//            LoadAttendance(uid, sess);
//            LoadVideoTrend(uid, sess);
//            LoadActivity(uid, sess);
//            LoadNotifications(uid, sess);
//            LoadHelp(uid, sess);
//            LoadAI(uid, sess);
//            LoadComments(uid, sess);
//        }

//        // ── Profile ──────────────────────────────────────────────────────────
//        private void LoadProfile(int uid, int sess)
//        {
//            DataTable dt = _bl.GetTeacherProfile(uid, sess);
//            if (dt.Rows.Count == 0) return;
//            DataRow r = dt.Rows[0];

//            TeacherName = r["FullName"].ToString();
//            IsActive = Convert.ToBoolean(r["IsActive"]);
//            ProfileImage = r["ProfileImage"].ToString();

//            // Avatar initials
//            string[] parts = TeacherName.Trim().Split(' ');
//            TeacherInitials = parts.Length == 1
//                ? TeacherName.Substring(0, Math.Min(2, TeacherName.Length)).ToUpper()
//                : (parts[0][0].ToString() + parts[parts.Length - 1][0].ToString()).ToUpper();
//            AvatarColor = Colors[Math.Abs(TeacherName.GetHashCode()) % Colors.Length];

//            // Bind fields
//            lblFullName.Text = H(r["FullName"]);
//            lblEmail.Text = H(r["Email"]);
//            lblUsername.Text = H(r["Username"]);
//            lblGender.Text = H(r["Gender"]);
//            lblDOB.Text = FmtDate(r["DOB"]);
//            lblContact.Text = H(r["ContactNo"]);
//            lblEmg.Text = H(r["EmergencyContactName"]) + " — " + H(r["EmergencyContactNo"]);
//            lblFather.Text = H(r["FatherName"]);
//            lblMother.Text = H(r["MotherName"]);
//            lblAddress.Text = BuildAddr(r);
//            lblSkills.Text = H(r["Skills"]);
//            lblJoined.Text = FmtDate(r["JoinedDate"]);
//            lblEmpId.Text = H(r["EmployeeId"]);
//            lblDesig.Text = H(r["Designation"]);
//            lblQual.Text = H(r["Qualification"]);
//            lblExp.Text = r["ExperienceYears"].ToString() + " yrs";
//            lblStream.Text = H(r["StreamName"]);
//            lblSession.Text = H(r["SessionName"]);
//            lblStatus.Text = IsActive ? "Active" : "Inactive";
//            lblStatus.CssClass = IsActive ? "status-badge active" : "status-badge inactive";

//            string lastLogin = r["LastLogin"] == DBNull.Value ? "Never" : FmtDateTime(r["LastLogin"]);
//            lblLastLogin.Text = lastLogin;
//            lblCreatedOn.Text = FmtDate(r["CreatedOn"]);
//        }

//        // ── KPIs ─────────────────────────────────────────────────────────────
//        private void LoadKPIs(int uid, int sess)
//        {
//            DataTable dt = _bl.GetTeacherKPIs(uid, sess);
//            if (dt.Rows.Count == 0) return;
//            DataRow r = dt.Rows[0];

//            TotalSubjects = Int(r["TotalSubjects"]);
//            TotalVideos = Int(r["TotalVideos"]);
//            TotalViews = Int(r["TotalViews"]);
//            TotalAssignments = Int(r["TotalAssignments"]);
//            TotalStudents = Int(r["TotalStudents"]);
//            AIInteractions = Int(r["AIInteractions"]);
//            AvgRating = Dec(r["AvgVideoRating"]);

//            hfKpiSubjects.Value = TotalSubjects.ToString();
//            hfKpiVideos.Value = TotalVideos.ToString();
//            hfKpiViews.Value = TotalViews.ToString();
//            hfKpiAssignments.Value = TotalAssignments.ToString();
//            hfKpiStudents.Value = TotalStudents.ToString();
//            hfKpiAI.Value = AIInteractions.ToString();
//            hfKpiRating.Value = AvgRating.ToString("F1");
//        }

//        // ── Subjects ─────────────────────────────────────────────────────────
//        private void LoadSubjects(int uid, int sess)
//        {
//            DataTable dt = _bl.GetAssignedSubjects(uid, sess);
//            rptSubjects.DataSource = dt;
//            rptSubjects.DataBind();

//            // Chart: syllabus completion per subject
//            var labels = new StringBuilder("[");
//            var pcts = new StringBuilder("[");
//            var enroll = new StringBuilder("[");
//            bool first = true;
//            foreach (DataRow r in dt.Rows)
//            {
//                if (!first) { labels.Append(","); pcts.Append(","); enroll.Append(","); }
//                labels.Append($"\"{r["SubjectName"]}\"");
//                pcts.Append(r["SyllabusCompletedPct"]);
//                enroll.Append(r["EnrolledStudents"]);
//                first = false;
//            }
//            labels.Append("]"); pcts.Append("]"); enroll.Append("]");
//            hfSubjectLabels.Value = labels.ToString();
//            hfSyllabusPcts.Value = pcts.ToString();
//            hfEnrollCounts.Value = enroll.ToString();

//            // Load chapter/video tree for each subject
//            rptSubjectChapters.DataSource = dt;
//            rptSubjectChapters.DataBind();
//        }

//        protected void rptSubjectChapters_ItemDataBound(object sender, RepeaterItemEventArgs e)
//        {
//            if (e.Item.ItemType != ListItemType.Item &&
//                e.Item.ItemType != ListItemType.AlternatingItem) return;

//            var hfSub = (HiddenField)e.Item.FindControl("hfSubId");
//            var rptCh = (Repeater)e.Item.FindControl("rptChapters");
//            var lblSub = (System.Web.UI.WebControls.Label)e.Item.FindControl("lblSubNameTree");

//            if (hfSub == null || rptCh == null) return;
//            int subId = Convert.ToInt32(hfSub.Value);

//            DataRow dr = (DataRow)((DataRowView)e.Item.DataItem).Row;
//            if (lblSub != null) lblSub.Text = H(dr["SubjectName"].ToString());

//            DataTable dtCh = _bl.GetChaptersWithContent(subId, ViewSessionId);
//            rptCh.DataSource = dtCh;
//            rptCh.DataBind();
//        }

//        protected void rptChapters_ItemDataBound(object sender, RepeaterItemEventArgs e)
//        {
//            if (e.Item.ItemType != ListItemType.Item &&
//                e.Item.ItemType != ListItemType.AlternatingItem) return;

//            var hfCh = (HiddenField)e.Item.FindControl("hfChapterId");
//            var rptVid = (Repeater)e.Item.FindControl("rptChapterVideos");
//            if (hfCh == null || rptVid == null) return;

//            int chId = Convert.ToInt32(hfCh.Value);
//            DataTable dtVid = _bl.GetVideosByChapterFull(chId, ViewSessionId);
//            rptVid.DataSource = dtVid;
//            rptVid.DataBind();
//        }

//        // ── Ratings ──────────────────────────────────────────────────────────
//        private void LoadRatings(int uid, int sess)
//        {
//            DataTable dt = _bl.GetVideoRatingsSummary(uid, sess);
//            rptRatings.DataSource = dt;
//            rptRatings.DataBind();

//            // Top 5 for chart
//            var labels = new StringBuilder("[");
//            var avgs = new StringBuilder("[");
//            var views = new StringBuilder("[");
//            int i = 0;
//            foreach (DataRow r in dt.Rows)
//            {
//                if (i >= 8) break;
//                if (i > 0) { labels.Append(","); avgs.Append(","); views.Append(","); }
//                string title = r["VideoTitle"].ToString();
//                if (title.Length > 20) title = title.Substring(0, 20) + "…";
//                labels.Append($"\"{title}\"");
//                avgs.Append(r["AvgRating"]);
//                views.Append(r["TotalViews"]);
//                i++;
//            }
//            labels.Append("]"); avgs.Append("]"); views.Append("]");
//            hfRatingLabels.Value = labels.ToString();
//            hfRatingAvgs.Value = avgs.ToString();
//            hfRatingViews.Value = views.ToString();
//        }

//        // ── Assignments ──────────────────────────────────────────────────────
//        private void LoadAssignments(int uid, int sess)
//        {
//            DataTable dt = _bl.GetAssignments(uid, sess);
//            rptAssignments.DataSource = dt;
//            rptAssignments.DataBind();

//            // Chart: submission rate per assignment (top 6)
//            var labels = new StringBuilder("[");
//            var subs = new StringBuilder("[");
//            var totals = new StringBuilder("[");
//            int i = 0;
//            foreach (DataRow r in dt.Rows)
//            {
//                if (i >= 6) break;
//                if (i > 0) { labels.Append(","); subs.Append(","); totals.Append(","); }
//                string title = r["Title"].ToString();
//                if (title.Length > 18) title = title.Substring(0, 18) + "…";
//                labels.Append($"\"{title}\"");
//                subs.Append(r["Submissions"]);
//                totals.Append(r["TotalStudents"]);
//                i++;
//            }
//            labels.Append("]"); subs.Append("]"); totals.Append("]");
//            hfAsgLabels.Value = labels.ToString();
//            hfAsgSubs.Value = subs.ToString();
//            hfAsgTotals.Value = totals.ToString();
//        }

//        // ── Attendance ───────────────────────────────────────────────────────
//        private void LoadAttendance(int uid, int sess)
//        {
//            DataTable dt = _bl.GetAttendanceBySubject(uid, sess);
//            rptAttendance.DataSource = dt;
//            rptAttendance.DataBind();

//            DataTable dtTop = _bl.GetTopAttendingClasses(uid, sess);
//            rptTopClasses.DataSource = dtTop;
//            rptTopClasses.DataBind();

//            // Attendance chart data
//            var labels = new StringBuilder("[");
//            var pcts = new StringBuilder("[");
//            bool first = true;
//            foreach (DataRow r in dt.Rows)
//            {
//                if (!first) { labels.Append(","); pcts.Append(","); }
//                labels.Append($"\"{r["SubjectCode"]}\"");
//                pcts.Append(r["AvgAttendancePct"]);
//                first = false;
//            }
//            labels.Append("]"); pcts.Append("]");
//            hfAttLabels.Value = labels.ToString();
//            hfAttPcts.Value = pcts.ToString();
//        }

//        // ── Video upload trend ───────────────────────────────────────────────
//        private void LoadVideoTrend(int uid, int sess)
//        {
//            DataTable dt = _bl.GetVideoUploadTrend(uid, sess);
//            var labels = new StringBuilder("[");
//            var counts = new StringBuilder("[");
//            var vws = new StringBuilder("[");
//            bool first = true;
//            foreach (DataRow r in dt.Rows)
//            {
//                if (!first) { labels.Append(","); counts.Append(","); vws.Append(","); }
//                labels.Append($"\"{r["MonthLabel"]}\"");
//                counts.Append(r["VideoCount"]);
//                vws.Append(r["TotalViews"]);
//                first = false;
//            }
//            labels.Append("]"); counts.Append("]"); vws.Append("]");
//            hfTrendLabels.Value = labels.ToString();
//            hfTrendCounts.Value = counts.ToString();
//            hfTrendViews.Value = vws.ToString();
//        }

//        // ── Activity ─────────────────────────────────────────────────────────
//        private void LoadActivity(int uid, int sess)
//        {
//            DataTable dt = _bl.GetActivityLog(uid, sess);
//            rptActivity.DataSource = dt;
//            rptActivity.DataBind();
//        }

//        // ── Notifications ────────────────────────────────────────────────────
//        private void LoadNotifications(int uid, int sess)
//        {
//            DataTable dt = _bl.GetNotifications(uid, sess);
//            rptNotifs.DataSource = dt;
//            rptNotifs.DataBind();
//        }

//        // ── Help requests ────────────────────────────────────────────────────
//        private void LoadHelp(int uid, int sess)
//        {
//            DataTable dt = _bl.GetHelpRequests(uid, sess);
//            rptHelp.DataSource = dt;
//            rptHelp.DataBind();
//        }

//        // ── AI interactions ──────────────────────────────────────────────────
//        private void LoadAI(int uid, int sess)
//        {
//            DataTable dt = _bl.GetAIUsageOnVideos(uid, sess);
//            rptAI.DataSource = dt;
//            rptAI.DataBind();
//            hfAITotal.Value = dt.Rows.Count.ToString();
//        }

//        // ── Video comments ───────────────────────────────────────────────────
//        private void LoadComments(int uid, int sess)
//        {
//            DataTable dt = _bl.GetVideoComments(uid, sess);
//            rptComments.DataSource = dt;
//            rptComments.DataBind();
//            hfCommentTotal.Value = dt.Rows.Count.ToString();
//        }

//        // ═══════════════════════════════════════════════════════════════════
//        //  PROTECTED HELPERS (called from ASPX markup)
//        // ═══════════════════════════════════════════════════════════════════
//        protected string Bar(object pct)
//        {
//            decimal v = Dec(pct);
//            return Math.Min(Math.Max(v, 0), 100).ToString("F1");
//        }

//        protected string AttColor(object pct)
//        {
//            decimal v = Dec(pct);
//            if (v >= 75) return "#059669";
//            if (v >= 50) return "#d97706";
//            return "#dc2626";
//        }

//        protected string StarHtml(object rating)
//        {
//            decimal r = Dec(rating);
//            var sb = new StringBuilder();
//            for (int i = 1; i <= 5; i++)
//                sb.Append(i <= (int)Math.Round(r)
//                    ? "<span style='color:#f59e0b'>★</span>"
//                    : "<span style='color:#e2e8f0'>★</span>");
//            return sb.ToString();
//        }

//        protected string FmtDate(object val)
//            => val != null && val != DBNull.Value && DateTime.TryParse(val.ToString(), out DateTime d)
//               ? d.ToString("dd MMM yyyy") : "—";

//        protected string FmtDateTime(object val)
//            => val != null && val != DBNull.Value && DateTime.TryParse(val.ToString(), out DateTime d)
//               ? d.ToString("dd MMM yyyy hh:mm tt") : "—";

//        protected string ActivityIcon(object t)
//        {
//            switch (t?.ToString())
//            {
//                case "VideoUploaded": return "fa-video";
//                case "AssignmentAdded": return "fa-file-alt";
//                case "Login": return "fa-sign-in-alt";
//                case "ProfileUpdated": return "fa-user-edit";
//                default: return "fa-circle";
//            }
//        }

//        // ── Private helpers ──────────────────────────────────────────────────
//        private static string H(object v)
//            => System.Web.HttpUtility.HtmlEncode(v?.ToString() ?? "");

//        private static decimal Dec(object v)
//        {
//            if (v == null || v == DBNull.Value) return 0;
//            return decimal.TryParse(v.ToString(), out decimal d) ? d : 0;
//        }

//        private static int Int(object v)
//        {
//            if (v == null || v == DBNull.Value) return 0;
//            return int.TryParse(v.ToString(), out int i) ? i : 0;
//        }

//        private static string BuildAddr(DataRow r)
//        {
//            var parts = new System.Collections.Generic.List<string>();
//            foreach (string col in new[] { "Address", "City", "Country", "Pincode" })
//            {
//                string v = r[col]?.ToString()?.Trim();
//                if (!string.IsNullOrWhiteSpace(v) && v != "0") parts.Add(H(v));
//            }
//            return parts.Count > 0 ? string.Join(", ", parts) : "—";
//        }

//        private static string BuildJsonArray(DataTable dt, string col)
//        {
//            if (dt == null || dt.Rows.Count == 0) return "[]";
//            var sb = new StringBuilder("[");
//            for (int i = 0; i < dt.Rows.Count; i++)
//            {
//                if (i > 0) sb.Append(",");
//                object val = dt.Rows[i][col];
//                bool num = val is int || val is long || val is decimal || val is double || val is float;
//                sb.Append(num ? val.ToString() : $"\"{val?.ToString()?.Replace("\"", "'")}\"");
//            }
//            sb.Append("]");
//            return sb.ToString();
//        }
//    }
//}