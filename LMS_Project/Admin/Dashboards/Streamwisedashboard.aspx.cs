using System;
using System.Data;
using System.IO;
using System.Net.Security;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace LearningManagementSystem.Admin.Dashboards
{
    public partial class StreamWiseDashboard : Page
    {
        StreamWiseDashboardBL bl = new StreamWiseDashboardBL();
        int InstituteId, SessionId, SelectedStreamId;

        protected void Page_Load(object sender, EventArgs e)
        {
            InstituteId = Convert.ToInt32(Session["InstituteId"]);
            SessionId = Convert.ToInt32(Session["SessionId"]);

            if (!IsPostBack)
            {
                LoadStreamDropdown();
                SelectedStreamId = 0;
                LoadDashboard();
            }
        }

        private void LoadStreamDropdown()
        {
            DataTable dt = bl.GetAllStreams(InstituteId, SessionId);
            ddlStream.Items.Clear();
            ddlStream.Items.Add(new ListItem("All Streams", "0"));
            foreach (DataRow r in dt.Rows)
                ddlStream.Items.Add(new ListItem(r["StreamName"].ToString(), r["StreamId"].ToString()));
        }

        protected void ddlStream_SelectedIndexChanged(object sender, EventArgs e)
        {
            SelectedStreamId = Convert.ToInt32(ddlStream.SelectedValue);
            LoadDashboard();
            LoadBannerIfExists();
        }

        private void LoadDashboard()
        {
            SelectedStreamId = Convert.ToInt32(ddlStream.SelectedValue);
            lblStreamTitle.Text = ddlStream.SelectedItem.Text;

            // ── KPIs ──
            DataTable dtKPI = bl.GetStreamKPIs(InstituteId, SessionId, SelectedStreamId);
            if (dtKPI != null && dtKPI.Rows.Count > 0)
            {
                // If a single stream selected show first row; else aggregate
                if (SelectedStreamId != 0)
                {
                    DataRow r = dtKPI.Rows[0];
                    lblStudents.Text = r["TotalStudents"].ToString();
                    lblCourses.Text = r["TotalCourses"].ToString();
                    lblSubjects.Text = r["TotalSubjects"].ToString();
                    lblTeachers.Text = r["TotalTeachers"].ToString();
                    lblSections.Text = r["TotalSections"].ToString();
                    lblAttPct.Text = FormatDec(r["AttendancePct"]) + "%";
                }
                else
                {
                    int students = 0, courses = 0, subjects = 0, teachers = 0, sections = 0;
                    double attSum = 0; int attCount = 0;
                    foreach (DataRow r in dtKPI.Rows)
                    {
                        students += ParseInt(r["TotalStudents"]);
                        courses += ParseInt(r["TotalCourses"]);
                        subjects += ParseInt(r["TotalSubjects"]);
                        teachers += ParseInt(r["TotalTeachers"]);
                        sections += ParseInt(r["TotalSections"]);
                        if (r["AttendancePct"] != DBNull.Value) { attSum += Convert.ToDouble(r["AttendancePct"]); attCount++; }
                    }
                    lblStudents.Text = students.ToString();
                    lblCourses.Text = courses.ToString();
                    lblSubjects.Text = subjects.ToString();
                    lblTeachers.Text = teachers.ToString();
                    lblSections.Text = sections.ToString();
                    lblAttPct.Text = (attCount > 0 ? (attSum / attCount).ToString("0.##") : "0") + "%";
                }

                // Stream KPI repeater (stream cards)
                rptStreamCards.DataSource = dtKPI;
                rptStreamCards.DataBind();
            }

            // ── Course-wise students ──
            DataTable dtCourse = bl.GetCourseWiseStudents(InstituteId, SessionId, SelectedStreamId);
            hdnCourseLabels.Value = JsonStrArr(dtCourse, "CourseName");
            hdnCourseStudents.Value = JsonArr(dtCourse, "Students");

            // ── Monthly enrollment trend ──
            DataTable dtTrend = bl.GetMonthlyEnrollmentTrend(InstituteId, SessionId, SelectedStreamId);
            hdnTrendMonths.Value = JsonStrArr(dtTrend, "MonthName");
            hdnTrendStudents.Value = JsonArr(dtTrend, "Students");

            // ── Attendance last 7 days ──
            DataTable dtAtt = bl.GetAttendanceLast7Days(InstituteId, SessionId, SelectedStreamId);
            hdnAttDays.Value = JsonStrArr(dtAtt, "DayLabel");
            hdnAttPct.Value = JsonArr(dtAtt, "AttPct");

            // ── Quiz pass rate ──
            DataTable dtQuiz = bl.GetQuizPassRateByStream(InstituteId, SessionId, SelectedStreamId);
            hdnQuizStreams.Value = JsonStrArr(dtQuiz, "StreamName");
            hdnQuizPassRate.Value = JsonArr(dtQuiz, "PassRate");
            hdnQuizAvgScore.Value = JsonArr(dtQuiz, "AvgScore");

            // ── Gender distribution ──
            DataTable dtGender = bl.GetGenderDistribution(InstituteId, SessionId, SelectedStreamId);
            hdnGenderLabels.Value = JsonStrArr(dtGender, "Gender");
            hdnGenderVals.Value = JsonArr(dtGender, "Total");

            // ── Assignment completion ──
            DataTable dtAssign = bl.GetAssignmentCompletionRate(InstituteId, SessionId, SelectedStreamId);
            hdnAssignStreams.Value = JsonStrArr(dtAssign, "StreamName");
            hdnAssignSubmitted.Value = JsonArr(dtAssign, "Submitted");

            // ── Subject table ──
            DataTable dtSub = bl.GetSubjectsForStream(InstituteId, SessionId, SelectedStreamId);
            rptSubjects.DataSource = dtSub;
            rptSubjects.DataBind();

            // ── Teachers ──
            DataTable dtTeach = bl.GetTeachersForStream(InstituteId, SessionId, SelectedStreamId);
            rptTeachers.DataSource = dtTeach;
            rptTeachers.DataBind();
        }

        // ── Banner Upload ──
        protected void btnUploadBanner_Click(object sender, EventArgs e)
        {
            SelectedStreamId = Convert.ToInt32(ddlStream.SelectedValue);
            if (!fuBanner.HasFile) { ShowAlert("Select an image first.", "warning"); return; }
            string ext = Path.GetExtension(fuBanner.FileName).ToLower();
            if (!".jpg.jpeg.png.webp.gif".Contains(ext)) { ShowAlert("Only image files allowed.", "danger"); return; }
            if (fuBanner.FileBytes.Length > 5 * 1024 * 1024) { ShowAlert("Max 5 MB.", "danger"); return; }

            string folder = Server.MapPath("~/Uploads/StreamBanners/");
            if (!Directory.Exists(folder)) Directory.CreateDirectory(folder);
            string fileName = $"stream_{SelectedStreamId}{ext}";
            fuBanner.SaveAs(Path.Combine(folder, fileName));
            string url = $"~/Uploads/StreamBanners/{fileName}";
            imgBanner.ImageUrl = ResolveUrl(url);
            imgBanner.Visible = true;
            hdnBannerPath.Value = url;
            ShowAlert("Banner uploaded!", "success");
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
            SelectedStreamId = Convert.ToInt32(ddlStream.SelectedValue);
            string[] exts = { ".jpg", ".jpeg", ".png", ".webp", ".gif" };
            foreach (var ext in exts)
            {
                string path = Server.MapPath($"~/Uploads/StreamBanners/stream_{SelectedStreamId}{ext}");
                if (File.Exists(path))
                {
                    imgBanner.ImageUrl = ResolveUrl($"~/Uploads/StreamBanners/stream_{SelectedStreamId}{ext}");
                    imgBanner.Visible = true;
                    hdnBannerPath.Value = $"~/Uploads/StreamBanners/stream_{SelectedStreamId}{ext}";
                    return;
                }
            }
            imgBanner.Visible = false; hdnBannerPath.Value = "";
        }

        // ── Helpers ──
        private string JsonArr(DataTable dt, string col)
        {
            if (dt == null || dt.Rows.Count == 0) return "[]";
            var sb = new StringBuilder("[");
            foreach (DataRow r in dt.Rows)
                sb.Append(string.IsNullOrEmpty(r[col].ToString()) ? "0" : r[col].ToString()).Append(",");
            if (sb.Length > 1) sb.Length--;
            return sb.Append("]").ToString();
        }
        private string JsonStrArr(DataTable dt, string col)
        {
            if (dt == null || dt.Rows.Count == 0) return "[]";
            var sb = new StringBuilder("[");
            foreach (DataRow r in dt.Rows)
                sb.AppendFormat("\"{0}\",", r[col].ToString().Replace("\"", "\\\""));
            if (sb.Length > 1) sb.Length--;
            return sb.Append("]").ToString();
        }
        public string FormatDec(object v)
        {
            return (v == null || v == DBNull.Value)
                ? "0"
                : Convert.ToDecimal(v).ToString("0.##");
        }

        private int ParseInt(object v) => (v == null || v == DBNull.Value) ? 0 : Convert.ToInt32(v);

        private void ShowAlert(string msg, string type)
        {
            pnlAlert.Visible = true;
            lblAlert.Text = msg;
            pnlAlert.CssClass = $"dash-alert alert-{type}";
        }

        protected string GetRankBg(int i)
        {
            switch (i)
            {
                case 0: return "#fef3c7";
                case 1: return "#f3f4f6";
                case 2: return "#fde8d8";
                default: return "#f8fafc";
            }
        }

        protected string GetRankColor(int i)
        {
            switch (i)
            {
                case 0: return "#b45309";
                case 1: return "#374151";
                case 2: return "#c05621";
                default: return "#64748b";
            }
        }
        
    }
}