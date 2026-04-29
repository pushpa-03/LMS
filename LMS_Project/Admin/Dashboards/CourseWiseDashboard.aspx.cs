using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace LearningManagementSystem.Admin.Dashboards
{
    public partial class CourseWiseDashboard : BasePage
    {
        private readonly CourseWiseDashboardBL bl = new CourseWiseDashboardBL();
        private int SelectedCourseId;

        // ──────────────────────────────────────────────────────────
        // Page Load
        // ──────────────────────────────────────────────────────────
        protected void Page_Load(object sender, EventArgs e)
        {

            if (!IsPostBack)
            {
                LoadCourseDropdown();
                ddlCourse.SelectedValue = "0";
                SelectedCourseId = 0;
                LoadDashboard();
                LoadBannerIfExists();
            }
        }

        // ──────────────────────────────────────────────────────────
        // Populate dropdown with stream grouping
        // ──────────────────────────────────────────────────────────
        private void LoadCourseDropdown()
        {
            try
            {
                DataTable dt = bl.GetAllCourses(InstituteId, SessionId);
                ddlCourse.Items.Clear();
                ddlCourse.Items.Add(new ListItem("📚 All Courses", "0"));

                if (dt == null || dt.Rows.Count == 0) return;

                string lastStream = "";
                foreach (DataRow r in dt.Rows)
                {
                    string stream = r["StreamName"].ToString();
                    if (stream != lastStream)
                    {
                        ddlCourse.Items.Add(new ListItem($"── {stream} ──", "-1") { Enabled = false });
                        lastStream = stream;
                    }
                    string code = r["CourseCode"].ToString();
                    string display = r["CourseName"].ToString() + (code.Length > 0 ? $" ({code})" : "");
                    ddlCourse.Items.Add(new ListItem(display, r["CourseId"].ToString()));
                }
            }
            catch (Exception ex)
            {
                ShowAlert("Failed to load course list: " + ex.Message, "danger");
            }
        }

        // ──────────────────────────────────────────────────────────
        // PostBack: filter changed
        // ──────────────────────────────────────────────────────────
        protected void ddlCourse_SelectedIndexChanged(object sender, EventArgs e)
        {
            int val = 0;
            int.TryParse(ddlCourse.SelectedValue, out val);
            SelectedCourseId = val < 0 ? 0 : val;

            // Re-sync dropdown to valid value if separator was somehow selected
            if (val < 0) ddlCourse.SelectedValue = "0";

            LoadDashboard();
            LoadBannerIfExists();
        }

        // ──────────────────────────────────────────────────────────
        // Main dashboard load — all data from DB, no static fallback
        // ──────────────────────────────────────────────────────────
        private void LoadDashboard()
        {
            try
            {
                int.TryParse(ddlCourse.SelectedValue, out SelectedCourseId);
                if (SelectedCourseId < 0) SelectedCourseId = 0;

                // Update header labels
                lblCourseTitle.Text = ddlCourse.SelectedItem?.Text ?? "All Courses";
                lblBannerCourse.Text = SelectedCourseId == 0
                    ? "All Courses — " + Session["SessionName"]
                    : ddlCourse.SelectedItem?.Text ?? "Course Dashboard";
                lblSessionBadge.Text = Session["SessionName"]?.ToString() ?? "";

                // ── 1. KPIs ──────────────────────────────────────
                DataTable dtKPI = bl.GetCourseKPIs(InstituteId, SessionId, SelectedCourseId);
                BindKPIs(dtKPI);

                // ── 2. Course cards (horizontal scroll) ──────────
                if (dtKPI != null && dtKPI.Rows.Count > 0)
                {
                    rptCourseCards.DataSource = dtKPI;
                    rptCourseCards.DataBind();
                }

                // ── 3. Enrollment trend ───────────────────────────
                DataTable dtTrend = bl.GetEnrollmentTrend(InstituteId, SessionId, SelectedCourseId);
                hdnTrendMonths.Value = ToJsonStr(dtTrend, "MonthName");
                hdnTrendStudents.Value = ToJsonNum(dtTrend, "Students");

                // ── 4. Level-wise ─────────────────────────────────
                DataTable dtLevel = bl.GetLevelWiseStudents(InstituteId, SessionId, SelectedCourseId);
                hdnLevelLabels.Value = ToJsonStr(dtLevel, "LevelName");
                hdnLevelStudents.Value = ToJsonNum(dtLevel, "Students");

                // ── 5. Semester-wise ──────────────────────────────
                DataTable dtSem = bl.GetSemesterWiseStudents(InstituteId, SessionId, SelectedCourseId);
                hdnSemLabels.Value = ToJsonStr(dtSem, "SemesterName");
                hdnSemStudents.Value = ToJsonNum(dtSem, "Students");

                // ── 6. Attendance by week ─────────────────────────
                DataTable dtAtt = bl.GetAttendanceByWeek(InstituteId, SessionId, SelectedCourseId);
                hdnAttWeeks.Value = ToJsonStr(dtAtt, "WeekLabel");
                hdnAttPct.Value = ToJsonNum(dtAtt, "AttPct");
                hdnAttPresent.Value = ToJsonNum(dtAtt, "Present");
                hdnAttAbsent.Value = ToJsonNum(dtAtt, "Absent");

                // ── 7. Subject performance (shared for table + chart) ──
                DataTable dtSubj = bl.GetSubjectPerformance(InstituteId, SessionId, SelectedCourseId);
                hdnSubjNames.Value = ToJsonStr(dtSubj, "SubjectName");
                hdnSubjVideos.Value = ToJsonNum(dtSubj, "Videos");
                hdnSubjAssign.Value = ToJsonNum(dtSubj, "Assignments");
                hdnSubjQuizzes.Value = ToJsonNum(dtSubj, "Quizzes");
                hdnSubjAtt.Value = ToJsonNum(dtSubj, "AttPct");
                hdnSubjScore.Value = ToJsonNum(dtSubj, "AvgScore");
                // Reuse same DataTable for repeater (no extra DB call)
                rptSubjects.DataSource = dtSubj;
                rptSubjects.DataBind();

                // ── 8. Quiz performance ───────────────────────────
                DataTable dtQuiz = bl.GetQuizPerformance(InstituteId, SessionId, SelectedCourseId);
                hdnQuizTitles.Value = ToJsonStr(dtQuiz, "QuizTitle");
                hdnQuizAvg.Value = ToJsonNum(dtQuiz, "AvgScore");
                hdnQuizPass.Value = ToJsonNum(dtQuiz, "PassRate");
                hdnQuizHigh.Value = ToJsonNum(dtQuiz, "HighScore");
                rptQuizzes.DataSource = dtQuiz;
                rptQuizzes.DataBind();

                // ── 9. Gender ─────────────────────────────────────
                DataTable dtGender = bl.GetGenderDistribution(InstituteId, SessionId, SelectedCourseId);
                hdnGenderLabels.Value = ToJsonStr(dtGender, "Gender");
                hdnGenderVals.Value = ToJsonNum(dtGender, "Total");

                // ── 10. Section-wise ──────────────────────────────
                DataTable dtSec = bl.GetSectionWiseStudents(InstituteId, SessionId, SelectedCourseId);
                hdnSecLabels.Value = ToJsonStr(dtSec, "SectionName");
                hdnSecStudents.Value = ToJsonNum(dtSec, "Students");

                // ── 11. Assignment submission rate ────────────────
                DataTable dtAssign = bl.GetAssignmentSubmissionRate(InstituteId, SessionId, SelectedCourseId);
                hdnAssignSubjects.Value = ToJsonStr(dtAssign, "SubjectName");
                hdnAssignRate.Value = ToJsonNum(dtAssign, "SubRate");
                hdnAssignTotal.Value = ToJsonNum(dtAssign, "TotalAssign");
                hdnAssignSubmitted.Value = ToJsonNum(dtAssign, "Submitted");

                // ── 12. Top students ──────────────────────────────
                DataTable dtStudents = bl.GetTopStudents(InstituteId, SessionId, SelectedCourseId);
                rptTopStudents.DataSource = dtStudents;
                rptTopStudents.DataBind();

                // Hide alert if everything loaded fine
                pnlAlert.Visible = false;
            }
            catch (Exception ex)
            {
                ShowAlert("Error loading dashboard: " + ex.Message, "danger");
            }
        }

        // ──────────────────────────────────────────────────────────
        // Bind KPI labels with null safety
        // ──────────────────────────────────────────────────────────
        private void BindKPIs(DataTable dtKPI)
        {
            if (dtKPI == null || dtKPI.Rows.Count == 0)
            {
                lblStudents.Text = lblSubjects.Text = lblSections.Text =
                lblAssignSub.Text = lblQuizAttempts.Text = lblAvgQuiz.Text = "0";
                lblAttPct.Text = "0%";
                lblStreamName.Text = "—";
                return;
            }

            if (SelectedCourseId != 0)
            {
                DataRow r = dtKPI.Rows[0];
                lblStudents.Text = Fmt(r["TotalStudents"]);
                lblSubjects.Text = Fmt(r["TotalSubjects"]);
                lblSections.Text = Fmt(r["TotalSections"]);
                lblAttPct.Text = FmtDec(r["AttendancePct"]) + "%";
                lblAssignSub.Text = Fmt(r["AssignmentSubmissions"]);
                lblQuizAttempts.Text = Fmt(r["QuizAttempts"]);
                lblAvgQuiz.Text = FmtDec(r["AvgQuizScore"]);
                lblStreamName.Text = r["StreamName"].ToString();
            }
            else
            {
                // Aggregate across all courses
                int stu = 0, sub = 0, sec = 0, asub = 0, qat = 0, attC = 0, qC = 0;
                double attSum = 0, qSum = 0;
                foreach (DataRow r in dtKPI.Rows)
                {
                    stu += ToInt(r["TotalStudents"]);
                    sub += ToInt(r["TotalSubjects"]);
                    sec += ToInt(r["TotalSections"]);
                    asub += ToInt(r["AssignmentSubmissions"]);
                    qat += ToInt(r["QuizAttempts"]);
                    if (r["AttendancePct"] != DBNull.Value && r["AttendancePct"].ToString() != "")
                    { attSum += ToDbl(r["AttendancePct"]); attC++; }
                    if (r["AvgQuizScore"] != DBNull.Value && r["AvgQuizScore"].ToString() != "")
                    { qSum += ToDbl(r["AvgQuizScore"]); qC++; }
                }
                lblStudents.Text = stu.ToString("N0");
                lblSubjects.Text = sub.ToString();
                lblSections.Text = sec.ToString();
                lblAttPct.Text = (attC > 0 ? (attSum / attC).ToString("0.#") : "0") + "%";
                lblAssignSub.Text = asub.ToString("N0");
                lblQuizAttempts.Text = qat.ToString("N0");
                lblAvgQuiz.Text = (qC > 0 ? (qSum / qC).ToString("0.#") : "0");
                lblStreamName.Text = "All Streams";
            }
        }

        // ──────────────────────────────────────────────────────────
        // Banner Upload  — validated, production-safe
        // ──────────────────────────────────────────────────────────
        protected void btnUploadBanner_Click(object sender, EventArgs e)
        {
            int.TryParse(ddlCourse.SelectedValue, out SelectedCourseId);
            if (SelectedCourseId < 0) SelectedCourseId = 0;

            if (!fuBanner.HasFile)
            {
                ShowAlert("Please select an image file before uploading.", "warning");
                return;
            }

            string ext = Path.GetExtension(fuBanner.FileName).ToLower().Trim();
            var allowed = new HashSet<string> { ".jpg", ".jpeg", ".png", ".webp", ".gif" };
            if (!allowed.Contains(ext))
            {
                ShowAlert("Invalid file type. Allowed: JPG, JPEG, PNG, WebP, GIF.", "danger");
                return;
            }

            const int maxBytes = 5 * 1024 * 1024; // 5 MB
            if (fuBanner.FileBytes.Length > maxBytes)
            {
                ShowAlert("File too large. Maximum allowed size is 5 MB.", "danger");
                return;
            }

            try
            {
                string folder = Server.MapPath("~/Uploads/CourseBanners/");
                if (!Directory.Exists(folder)) Directory.CreateDirectory(folder);

                // Delete old banner for this course (any extension)
                foreach (var oldExt in allowed)
                {
                    string old = Path.Combine(folder, $"course_{SelectedCourseId}{oldExt}");
                    if (File.Exists(old)) File.Delete(old);
                }

                string fileName = $"course_{SelectedCourseId}{ext}";
                string fullPath = Path.Combine(folder, fileName);
                fuBanner.SaveAs(fullPath);

                imgBanner.ImageUrl = ResolveUrl($"~/Uploads/CourseBanners/{fileName}");
                imgBanner.Visible = true;
                hdnBannerPath.Value = $"~/Uploads/CourseBanners/{fileName}";
                ShowAlert("Banner uploaded successfully.", "success");
            }
            catch (Exception ex)
            {
                ShowAlert("Upload failed: " + ex.Message, "danger");
            }
        }

        protected void btnRemoveBanner_Click(object sender, EventArgs e)
        {
            try
            {
                if (!string.IsNullOrEmpty(hdnBannerPath.Value))
                {
                    string p = Server.MapPath(hdnBannerPath.Value);
                    if (File.Exists(p)) File.Delete(p);
                }
                imgBanner.Visible = false;
                hdnBannerPath.Value = "";
                ShowAlert("Banner removed.", "info");
            }
            catch (Exception ex)
            {
                ShowAlert("Remove failed: " + ex.Message, "danger");
            }
        }

        private void LoadBannerIfExists()
        {
            int.TryParse(ddlCourse.SelectedValue, out SelectedCourseId);
            if (SelectedCourseId < 0) SelectedCourseId = 0;

            foreach (var ext in new[] { ".jpg", ".jpeg", ".png", ".webp", ".gif" })
            {
                string rel = $"~/Uploads/CourseBanners/course_{SelectedCourseId}{ext}";
                string phys = Server.MapPath(rel);
                if (File.Exists(phys))
                {
                    imgBanner.ImageUrl = ResolveUrl(rel);
                    imgBanner.Visible = true;
                    hdnBannerPath.Value = rel;
                    return;
                }
            }
            imgBanner.Visible = false;
            hdnBannerPath.Value = "";
        }

        // ──────────────────────────────────────────────────────────
        // JSON serialisers — safe for chart injection
        // ──────────────────────────────────────────────────────────
        private string ToJsonNum(DataTable dt, string col)
        {
            if (dt == null || dt.Rows.Count == 0) return "[]";
            var sb = new StringBuilder("[");
            foreach (DataRow r in dt.Rows)
            {
                string v = r[col]?.ToString() ?? "";
                sb.Append(string.IsNullOrEmpty(v) ? "0" : v).Append(",");
            }
            if (sb.Length > 1) sb.Length--;
            sb.Append("]");
            return sb.ToString();
        }

        private string ToJsonStr(DataTable dt, string col)
        {
            if (dt == null || dt.Rows.Count == 0) return "[]";
            var sb = new StringBuilder("[");
            foreach (DataRow r in dt.Rows)
            {
                string v = (r[col]?.ToString() ?? "")
                    .Replace("\\", "\\\\")
                    .Replace("\"", "\\\"")
                    .Replace("\r", "").Replace("\n", "");
                sb.AppendFormat("\"{0}\",", v);
            }
            if (sb.Length > 1) sb.Length--;
            sb.Append("]");
            return sb.ToString();
        }

        // ──────────────────────────────────────────────────────────
        // Helpers accessible from ASPX inline expressions
        // ──────────────────────────────────────────────────────────
        public string FmtDec(object v) =>
            (v == null || v == DBNull.Value || v.ToString() == "") ? "0"
            : Convert.ToDecimal(v).ToString("0.#");

        private string Fmt(object v) => (v == null || v == DBNull.Value) ? "0" : v.ToString();
        private int ToInt(object v) => (v == null || v == DBNull.Value) ? 0 : Convert.ToInt32(v);
        private double ToDbl(object v) => (v == null || v == DBNull.Value) ? 0d : Convert.ToDouble(v);

        protected string GetGrade(object score)
        {
            if (score == null || score == DBNull.Value) return "—";
            double s = Convert.ToDouble(score);
            if (s >= 90) return "A+"; if (s >= 80) return "A";
            if (s >= 70) return "B+"; if (s >= 60) return "B";
            if (s >= 50) return "C"; if (s >= 33) return "D";
            return "F";
        }

        protected string GetGradeClass(object score)
        {
            if (score == null || score == DBNull.Value) return "grade-none";
            double s = Convert.ToDouble(score);
            if (s >= 70) return "grade-a";
            if (s >= 50) return "grade-b";
            if (s >= 33) return "grade-c";
            return "grade-f";
        }

        protected string GetGradeColor(object score)
        {
            if (score == null || score == DBNull.Value)
                return "#6b7280"; // gray

            double s = Convert.ToDouble(score);

            if (s >= 90) return "#16a34a";   // green (A+)
            if (s >= 80) return "#22c55e";   // light green (A)
            if (s >= 70) return "#3b82f6";   // blue (B+)
            if (s >= 60) return "#eab308";   // yellow (B)
            if (s >= 50) return "#f97316";   // orange (C)
            if (s >= 33) return "#ef4444";   // red (D)

            return "#991b1b"; // dark red (Fail)
        }

        protected string AvatarInitial(object name)
        {
            string n = name?.ToString() ?? "";
            return string.IsNullOrEmpty(n) ? "?" : n.Substring(0, 1).ToUpper();
        }

        private void ShowAlert(string msg, string type)
        {
            pnlAlert.Visible = true;
            lblAlert.Text = System.Web.HttpUtility.HtmlEncode(msg);
            pnlAlert.CssClass = $"dash-alert alert-{type}";
        }
    }
}