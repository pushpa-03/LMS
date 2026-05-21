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

        // ── Properties rendered directly in ASPX markup ───────────────────────
        protected string TeacherName = "Teacher";
        protected string TeacherInitials = "T";
        protected string AvatarColor = "#4f46e5";
        protected string ProfileImage = "";
        protected bool IsActive = true;

        private static readonly string[] AvatarColors = {
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

        // ── Session dropdown ─────────────────────────────────────────────────
        private void LoadSessionSelector()
        {
            DataTable dt = _bl.GetTeacherSessions(TeacherUserId);
            ddlSession.Items.Clear();
            foreach (DataRow r in dt.Rows)
            {
                bool isCurr = Convert.ToBoolean(r["IsCurrent"]);
                var item = new ListItem(
                    r["SessionName"] + (isCurr ? " (Current)" : ""),
                    r["SessionId"].ToString());
                if (Convert.ToInt32(r["SessionId"]) == ViewSessionId)
                    item.Selected = true;
                ddlSession.Items.Add(item);
            }
        }

        protected void ddlSession_Changed(object sender, EventArgs e)
        {
            int s = int.TryParse(ddlSession.SelectedValue, out int sv) ? sv : SessionId;
            Response.Redirect($"TeacherDetails.aspx?id={TeacherUserId}&SessionId={s}");
        }

        // ── Master load ──────────────────────────────────────────────────────
        private void LoadAllData()
        {
            int uid = TeacherUserId;
            int sess = ViewSessionId;
            LoadProfile(uid, sess);
            LoadKPIs(uid, sess);
            LoadSubjects(uid, sess);         // also fills radar HFs
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

        // ════════════════════════════════════════════════════════════════════
        //  PROFILE
        // ════════════════════════════════════════════════════════════════════
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
            AvatarColor = AvatarColors[Math.Abs(TeacherName.GetHashCode()) % AvatarColors.Length];

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

        // ════════════════════════════════════════════════════════════════════
        //  KPIs  (raw counts for the 6 KPI cards)
        // ════════════════════════════════════════════════════════════════════
        private void LoadKPIs(int uid, int sess)
        {
            DataTable dt = _bl.GetTeacherKPIs(uid, sess);
            if (dt.Rows.Count == 0) return;
            DataRow r = dt.Rows[0];

            hfKpiSubjects.Value = N(r["TotalSubjects"]);
            hfKpiVideos.Value = N(r["TotalVideos"]);
            hfKpiViews.Value = N(r["TotalViews"]);          // raw all-role play counter
            hfKpiAssignments.Value = N(r["TotalAssignments"]);
            hfKpiStudents.Value = N(r["TotalStudents"]);
            hfKpiAI.Value = N(r["AIInteractions"]);
            hfKpiRating.Value = Dec(r["AvgVideoRating"]).ToString("F1");
        }

        // ════════════════════════════════════════════════════════════════════
        //  SUBJECTS
        //  GetAssignedSubjects returns ONE row per unique SubjectId (OUTER APPLY TOP 1).
        //  rptSubjects shows one card per subject.
        //  rptSubjects_ItemDataBound fills the nested rptSections.
        //
        //  Radar hidden-field values are also derived from the subjects data here.
        // ════════════════════════════════════════════════════════════════════
        private void LoadSubjects(int uid, int sess)
        {
            // --- one row per UNIQUE subject (sections collapsed inside card) ---
            DataTable dt = _bl.GetAssignedSubjectsDistinct(uid, sess);

            // chart JSON (one entry per subject)
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

            // ── Radar values (real 0–100 percentages) ───────────────────────
            // AttPct  = avg of all subjects' attendance pcts
            // VidPct  = avg of all subjects' SyllabusCompletedPct
            // AsgPct  = from KPIs.OverallSubmissionRate
            // RatPct  = (AvgVideoRating / 5) * 100
            // StudPct = min(TotalStudents * 2, 100)  — rough reach scale

            decimal attSum = 0, vidSum = 0;
            int subjCount = dt.Rows.Count;
            foreach (DataRow r in dt.Rows)
            {
                attSum += Dec(r["AvgAttendancePct"]);
                vidSum += Dec(r["SyllabusCompletedPct"]);
            }
            decimal attPct = subjCount > 0 ? Math.Round(attSum / subjCount, 1) : 0;
            decimal vidPct = subjCount > 0 ? Math.Round(vidSum / subjCount, 1) : 0;

            // pull assignment rate and rating from KPI table (already computed)
            DataTable dtKpi = _bl.GetTeacherKPIs(uid, sess);
            decimal asgPct = 0, ratPct = 0, studPct = 0;
            if (dtKpi.Rows.Count > 0)
            {
                asgPct = Dec(dtKpi.Rows[0]["OverallSubmissionRate"]);
                decimal avgRat = Dec(dtKpi.Rows[0]["AvgVideoRating"]);
                ratPct = Math.Round(avgRat / 5m * 100m, 1);
                int studs = Int(dtKpi.Rows[0]["TotalStudents"]);
                studPct = Math.Min(studs * 2m, 100m);
            }

            hfRadarAttPct.Value = attPct.ToString("F1");
            hfRadarVidPct.Value = vidPct.ToString("F1");
            hfRadarAsgPct.Value = asgPct.ToString("F1");
            hfRadarRatPct.Value = ratPct.ToString("F1");
            hfRadarSubPct.Value = studPct.ToString("F1");

            // bind the subject cards repeater
            rptSubjects.DataSource = dt;
            rptSubjects.DataBind();

            // bind the content-tree repeater (same data)
            rptSubjectChapters.DataSource = dt;
            rptSubjectChapters.DataBind();
        }

        // ────────────────────────────────────────────────────────────────────
        //  rptSubjects ItemDataBound
        //  Finds hfSubjectId and rptSections inside the item, then calls BL
        //  to get per-section data for that subject.
        // ────────────────────────────────────────────────────────────────────
        protected void rptSubjects_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item &&
                e.Item.ItemType != ListItemType.AlternatingItem) return;

            // Find the hidden field that holds SubjectId
            var hfSubId = (HiddenField)e.Item.FindControl("hfSubjectId");
            // Find the nested sections repeater
            var rptSecs = (Repeater)e.Item.FindControl("rptSections");

            if (hfSubId == null || rptSecs == null) return;

            int subjectId = Convert.ToInt32(hfSubId.Value);

            // Get section-wise breakdown for this subject
            DataTable dtSec = _bl.GetSectionsForSubject(TeacherUserId, subjectId, ViewSessionId);
            rptSecs.DataSource = dtSec;
            rptSecs.DataBind();

            if (rptSecs.Controls.Count > 0)
            {
                RepeaterItem footer =
                    rptSecs.Controls[rptSecs.Controls.Count - 1] as RepeaterItem;

                if (footer != null)
                {
                    Panel pnl =
                        footer.FindControl("pnlNoSections") as Panel;

                    if (pnl != null)
                        pnl.Visible = rptSecs.Items.Count == 0;
                }
            }
        }

        // ────────────────────────────────────────────────────────────────────
        //  Content Tree: Subject → Chapter → Video (Tab 3)
        // ────────────────────────────────────────────────────────────────────
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

        // ════════════════════════════════════════════════════════════════════
        //  RATINGS
        // ════════════════════════════════════════════════════════════════════
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

        // ════════════════════════════════════════════════════════════════════
        //  ASSIGNMENTS
        // ════════════════════════════════════════════════════════════════════
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

        // ════════════════════════════════════════════════════════════════════
        //  ATTENDANCE
        // ════════════════════════════════════════════════════════════════════
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

        // ════════════════════════════════════════════════════════════════════
        //  VIDEO TREND
        // ════════════════════════════════════════════════════════════════════
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

        // ════════════════════════════════════════════════════════════════════
        //  COMMUNICATIONS
        // ════════════════════════════════════════════════════════════════════
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
        //  PROTECTED HELPERS  (called from ASPX markup — must be protected)
        // ════════════════════════════════════════════════════════════════════

        /// <summary>Caps value 0–100 for CSS width.</summary>
        protected string Bar(object pct)
        {
            decimal v = Dec(pct);
            return Math.Min(Math.Max(v, 0), 100).ToString("F1");
        }

        /// <summary>Submission rate bar width.</summary>
        protected string SubRate(object submissions, object total)
        {
            decimal s = Dec(submissions), t = Dec(total);
            if (t == 0) return "0";
            return Math.Min(s / t * 100, 100).ToString("F1");
        }

        /// <summary>Submission rate as percent string.</summary>
        protected string SubRatePct(object submissions, object total)
        {
            decimal s = Dec(submissions), t = Dec(total);
            if (t == 0) return "0%";
            return Math.Round(s / t * 100, 0) + "%";
        }

        /// <summary>Color by attendance %.</summary>
        protected string AttColor(object pct)
        {
            decimal v = Dec(pct);
            if (v >= 75) return "#059669";
            if (v >= 50) return "#d97706";
            return "#dc2626";
        }

        /// <summary>5-star HTML for a 1–5 rating.</summary>
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

        /// <summary>Color for rating value.</summary>
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

        protected string H(object v)
            => System.Web.HttpUtility.HtmlEncode(v?.ToString() ?? "");

        protected decimal Dec(object v)
        {
            if (v == null || v == DBNull.Value) return 0;
            return decimal.TryParse(v.ToString(), out decimal d) ? d : 0;
        }

        // ── Private helpers ───────────────────────────────────────────────
        private static string N(object v) => v?.ToString() ?? "0";

        private static int Int(object v)
        {
            if (v == null || v == DBNull.Value) return 0;
            return int.TryParse(v.ToString(), out int i) ? i : 0;
        }

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