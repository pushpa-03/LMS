using LearningManagementSystem.Admin.Dashboards;
using System;
using System.Data;
using System.IO;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace LearningManagementSystem.Admin.Dashboards
{
    public partial class CourseWiseDashboard : Page
    {
        CourseWiseDashboardBL bl = new CourseWiseDashboardBL();
        int InstituteId, SessionId, SelectedCourseId;

        protected void Page_Load(object sender, EventArgs e)
        {
            InstituteId = Convert.ToInt32(Session["InstituteId"]);
            SessionId = Convert.ToInt32(Session["SessionId"]);

            if (!IsPostBack)
            {
                LoadCourseDropdown();
                SelectedCourseId = 0;
                LoadDashboard();
            }
        }

        private void LoadCourseDropdown()
        {
            DataTable dt = bl.GetAllCourses(InstituteId, SessionId);
            ddlCourse.Items.Clear();
            ddlCourse.Items.Add(new ListItem("All Courses", "0"));
            string lastStream = "";
            foreach (DataRow r in dt.Rows)
            {
                string stream = r["StreamName"].ToString();
                if (stream != lastStream)
                {
                    // Optgroup via disabled option as separator
                    ddlCourse.Items.Add(new ListItem($"── {stream} ──", "-1") { Enabled = false });
                    lastStream = stream;
                }
                string code = string.IsNullOrEmpty(r["CourseCode"].ToString()) ? "" : $" ({r["CourseCode"]})";
                ddlCourse.Items.Add(new ListItem(r["CourseName"].ToString() + code, r["CourseId"].ToString()));
            }
        }

        protected void ddlCourse_SelectedIndexChanged(object sender, EventArgs e)
        {
            SelectedCourseId = Convert.ToInt32(ddlCourse.SelectedValue);
            if (SelectedCourseId < 0) SelectedCourseId = 0;
            LoadDashboard();
            LoadBannerIfExists();
        }

        private void LoadDashboard()
        {
            SelectedCourseId = Convert.ToInt32(ddlCourse.SelectedValue);
            if (SelectedCourseId < 0) SelectedCourseId = 0;
            lblCourseTitle.Text = ddlCourse.SelectedItem?.Text ?? "All Courses";
            lblBannerCourse.Text = lblCourseTitle.Text;

            // ── KPIs ──
            DataTable dtKPI = bl.GetCourseKPIs(InstituteId, SessionId, SelectedCourseId);
            if (dtKPI != null && dtKPI.Rows.Count > 0)
            {
                if (SelectedCourseId != 0)
                {
                    DataRow r = dtKPI.Rows[0];
                    lblStudents.Text = r["TotalStudents"].ToString();
                    lblSubjects.Text = r["TotalSubjects"].ToString();
                    lblSections.Text = r["TotalSections"].ToString();
                    lblAttPct.Text = FormatDec(r["AttendancePct"]) + "%";
                    lblAssignSub.Text = r["AssignmentSubmissions"].ToString();
                    lblQuizAttempts.Text = r["QuizAttempts"].ToString();
                    lblAvgQuiz.Text = FormatDec(r["AvgQuizScore"]);
                    lblStreamName.Text = r["StreamName"].ToString();
                }
                else
                {
                    int stu = 0, sub = 0, sec = 0, asub = 0, qat = 0;
                    double attSum = 0, qSum = 0; int attC = 0, qC = 0;
                    foreach (DataRow r in dtKPI.Rows)
                    {
                        stu += ParseInt(r["TotalStudents"]);
                        sub += ParseInt(r["TotalSubjects"]);
                        sec += ParseInt(r["TotalSections"]);
                        asub += ParseInt(r["AssignmentSubmissions"]);
                        qat += ParseInt(r["QuizAttempts"]);
                        if (r["AttendancePct"] != DBNull.Value) { attSum += ParseDbl(r["AttendancePct"]); attC++; }
                        if (r["AvgQuizScore"] != DBNull.Value) { qSum += ParseDbl(r["AvgQuizScore"]); qC++; }
                    }
                    lblStudents.Text = stu.ToString();
                    lblSubjects.Text = sub.ToString();
                    lblSections.Text = sec.ToString();
                    lblAttPct.Text = (attC > 0 ? (attSum / attC).ToString("0.##") : "0") + "%";
                    lblAssignSub.Text = asub.ToString();
                    lblQuizAttempts.Text = qat.ToString();
                    lblAvgQuiz.Text = (qC > 0 ? (qSum / qC).ToString("0.##") : "0");
                    lblStreamName.Text = "All Streams";
                }
                // Course cards repeater
                rptCourseCards.DataSource = dtKPI;
                rptCourseCards.DataBind();
            }

            // ── Enrollment trend ──
            DataTable dtTrend = bl.GetEnrollmentTrend(InstituteId, SessionId, SelectedCourseId);
            hdnTrendMonths.Value = JsonStr(dtTrend, "MonthName");
            hdnTrendStudents.Value = JsonNum(dtTrend, "Students");

            // ── Level-wise ──
            DataTable dtLevel = bl.GetLevelWiseStudents(InstituteId, SessionId, SelectedCourseId);
            hdnLevelLabels.Value = JsonStr(dtLevel, "LevelName");
            hdnLevelStudents.Value = JsonNum(dtLevel, "Students");

            // ── Semester-wise ──
            DataTable dtSem = bl.GetSemesterWiseStudents(InstituteId, SessionId, SelectedCourseId);
            hdnSemLabels.Value = JsonStr(dtSem, "SemesterName");
            hdnSemStudents.Value = JsonNum(dtSem, "Students");

            // ── Attendance by week ──
            DataTable dtAtt = bl.GetAttendanceByWeek(InstituteId, SessionId, SelectedCourseId);
            hdnAttWeeks.Value = JsonStr(dtAtt, "WeekLabel");
            hdnAttPct.Value = JsonNum(dtAtt, "AttPct");
            hdnAttPresent.Value = JsonNum(dtAtt, "Present");
            hdnAttAbsent.Value = JsonNum(dtAtt, "Absent");

            // ── Subject performance ──
            DataTable dtSubj = bl.GetSubjectPerformance(InstituteId, SessionId, SelectedCourseId);
            hdnSubjNames.Value = JsonStr(dtSubj, "SubjectName");
            hdnSubjVideos.Value = JsonNum(dtSubj, "Videos");
            hdnSubjAssign.Value = JsonNum(dtSubj, "Assignments");
            hdnSubjQuizzes.Value = JsonNum(dtSubj, "Quizzes");
            hdnSubjAtt.Value = JsonNum(dtSubj, "AttPct");
            hdnSubjScore.Value = JsonNum(dtSubj, "AvgScore");

            // ── Quiz performance ──
            DataTable dtQuiz = bl.GetQuizPerformance(InstituteId, SessionId, SelectedCourseId);
            hdnQuizTitles.Value = JsonStr(dtQuiz, "QuizTitle");
            hdnQuizAvg.Value = JsonNum(dtQuiz, "AvgScore");
            hdnQuizPass.Value = JsonNum(dtQuiz, "PassRate");
            hdnQuizHigh.Value = JsonNum(dtQuiz, "HighScore");

            // ── Gender ──
            DataTable dtGender = bl.GetGenderDistribution(InstituteId, SessionId, SelectedCourseId);
            hdnGenderLabels.Value = JsonStr(dtGender, "Gender");
            hdnGenderVals.Value = JsonNum(dtGender, "Total");

            // ── Section-wise ──
            DataTable dtSec = bl.GetSectionWiseStudents(InstituteId, SessionId, SelectedCourseId);
            hdnSecLabels.Value = JsonStr(dtSec, "SectionName");
            hdnSecStudents.Value = JsonNum(dtSec, "Students");

            // ── Assignment submission rate ──
            DataTable dtAssign = bl.GetAssignmentSubmissionRate(InstituteId, SessionId, SelectedCourseId);
            hdnAssignSubjects.Value = JsonStr(dtAssign, "SubjectName");
            hdnAssignRate.Value = JsonNum(dtAssign, "SubRate");
            hdnAssignTotal.Value = JsonNum(dtAssign, "TotalAssign");
            hdnAssignSub2.Value = JsonNum(dtAssign, "Submitted");

            // ── Top students ──
            DataTable dtStudents = bl.GetTopStudents(InstituteId, SessionId, SelectedCourseId);
            rptTopStudents.DataSource = dtStudents;
            rptTopStudents.DataBind();

            // ── Subject table ──
            DataTable dtSubjTbl = bl.GetSubjectPerformance(InstituteId, SessionId, SelectedCourseId);
            rptSubjects.DataSource = dtSubjTbl;
            rptSubjects.DataBind();
        }

        // ── Banner Upload ──
        protected void btnUploadBanner_Click(object sender, EventArgs e)
        {
            SelectedCourseId = Convert.ToInt32(ddlCourse.SelectedValue);
            if (SelectedCourseId < 0) SelectedCourseId = 0;
            if (!fuBanner.HasFile) { ShowAlert("Select an image first.", "warning"); return; }
            string ext = Path.GetExtension(fuBanner.FileName).ToLower();
            if (!".jpg.jpeg.png.webp.gif".Contains(ext)) { ShowAlert("Only image files allowed.", "danger"); return; }
            if (fuBanner.FileBytes.Length > 5 * 1024 * 1024) { ShowAlert("Max 5 MB.", "danger"); return; }

            string folder = Server.MapPath("~/Uploads/CourseBanners/");
            if (!Directory.Exists(folder)) Directory.CreateDirectory(folder);
            string fileName = $"course_{SelectedCourseId}{ext}";
            fuBanner.SaveAs(Path.Combine(folder, fileName));
            string url = $"~/Uploads/CourseBanners/{fileName}";
            imgBanner.ImageUrl = ResolveUrl(url);
            imgBanner.Visible = true;
            hdnBannerPath.Value = url;
            ShowAlert("Banner uploaded successfully!", "success");
        }

        protected void btnRemoveBanner_Click(object sender, EventArgs e)
        {
            if (!string.IsNullOrEmpty(hdnBannerPath.Value))
            {
                string p = Server.MapPath(hdnBannerPath.Value);
                if (File.Exists(p)) File.Delete(p);
                imgBanner.Visible = false; hdnBannerPath.Value = "";
                ShowAlert("Banner removed.", "info");
            }
        }

        private void LoadBannerIfExists()
        {
            SelectedCourseId = Convert.ToInt32(ddlCourse.SelectedValue);
            if (SelectedCourseId < 0) SelectedCourseId = 0;
            foreach (var ext in new[] { ".jpg", ".jpeg", ".png", ".webp", ".gif" })
            {
                string p = Server.MapPath($"~/Uploads/CourseBanners/course_{SelectedCourseId}{ext}");
                if (File.Exists(p))
                {
                    imgBanner.ImageUrl = ResolveUrl($"~/Uploads/CourseBanners/course_{SelectedCourseId}{ext}");
                    imgBanner.Visible = true;
                    hdnBannerPath.Value = $"~/Uploads/CourseBanners/course_{SelectedCourseId}{ext}";
                    return;
                }
            }
            imgBanner.Visible = false; hdnBannerPath.Value = "";
        }

        // ── Helpers ──
        private string JsonNum(DataTable dt, string col)
        {
            if (dt == null || dt.Rows.Count == 0) return "[]";
            var sb = new StringBuilder("[");
            foreach (DataRow r in dt.Rows)
                sb.Append(string.IsNullOrEmpty(r[col].ToString()) ? "0" : r[col].ToString()).Append(",");
            if (sb.Length > 1) sb.Length--;
            return sb.Append("]").ToString();
        }
        private string JsonStr(DataTable dt, string col)
        {
            if (dt == null || dt.Rows.Count == 0) return "[]";
            var sb = new StringBuilder("[");
            foreach (DataRow r in dt.Rows)
                sb.AppendFormat("\"{0}\",", r[col].ToString().Replace("\"", "\\\"").Replace("\r", "").Replace("\n", ""));
            if (sb.Length > 1) sb.Length--;
            return sb.Append("]").ToString();
        }
        public string FormatDec(object v) => (v == null || v == DBNull.Value) ? "0" : Convert.ToDecimal(v).ToString("0.##");
        private int ParseInt(object v) => (v == null || v == DBNull.Value) ? 0 : Convert.ToInt32(v);
        private double ParseDbl(object v) => (v == null || v == DBNull.Value) ? 0 : Convert.ToDouble(v);

        private void ShowAlert(string msg, string type)
        {
            pnlAlert.Visible = true;
            lblAlert.Text = msg;
            pnlAlert.CssClass = $"dash-alert alert-{type}";
        }

        // Returns score grade label for repeater
        protected string GetGrade(object score)
        {
            if (score == null || score == DBNull.Value) return "—";
            double s = Convert.ToDouble(score);
            if (s >= 90) return "A+"; if (s >= 75) return "A"; if (s >= 60) return "B";
            if (s >= 45) return "C"; if (s >= 33) return "D"; return "F";
        }
        protected string GetGradeColor(object score)
        {
            if (score == null || score == DBNull.Value) return "#94a3b8";
            double s = Convert.ToDouble(score);
            if (s >= 75) return "#10b981"; if (s >= 45) return "#f59e0b"; return "#ef4444";
        }
    }
}