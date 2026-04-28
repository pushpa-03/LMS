using System;
using System.Data;
using System.IO;
using System.Text;
using System.Web.UI;

namespace LearningManagementSystem.Admin.Dashboards
{
    public partial class MonthlyAnalyticsDashboard : System.Web.UI.Page
    {
        MonthlyAnalyticsDashboardBL bl = new MonthlyAnalyticsDashboardBL();

        int InstituteId;
        int SessionId;

        protected void Page_Load(object sender, EventArgs e)
        {
            //if (Session["InstituteId"] == null || Session["SessionId"] == null)
            //{
            //    Response.Redirect("~/Default.aspx");
            //    return;
            //}

            InstituteId = Convert.ToInt32(Session["InstituteId"]);
            SessionId = Convert.ToInt32(Session["SessionId"]);
            this.DataBind();

            if (!IsPostBack)
            {
                PopulateMonthYearDDL();

                ddlMonth.SelectedValue = DateTime.Now.Month.ToString();
                ddlYear.SelectedValue = DateTime.Now.Year.ToString();


                LoadDashboard();
            }
        }

        private void PopulateMonthYearDDL()
        {
            ddlMonth.Items.Clear();
            ddlYear.Items.Clear();

            string[] months = {
                "January","February","March","April","May","June",
                "July","August","September","October","November","December"
            };

            for (int i = 1; i <= 12; i++)
                ddlMonth.Items.Add(new System.Web.UI.WebControls.ListItem(months[i - 1], i.ToString()));

            int curYear = DateTime.Now.Year;
            for (int y = curYear - 2; y <= curYear; y++)
                ddlYear.Items.Add(new System.Web.UI.WebControls.ListItem(y.ToString(), y.ToString()));
        }

        protected void btnFilter_Click(object sender, EventArgs e)
        {
            LoadDashboard();
        }

        private void LoadDashboard()
        {
            int SelectedMonth = Convert.ToInt32(ddlMonth.SelectedValue);
            int SelectedYear = Convert.ToInt32(ddlYear.SelectedValue);

            lblSelectedPeriod.Text = ddlMonth.SelectedItem.Text + " " + SelectedYear;
            lblSelectedPeriod2.Text = lblSelectedPeriod.Text;
            lblBannerPeriod.Text = lblSelectedPeriod.Text;

            // ───── KPIs ─────
            DataTable dtKPI = bl.GetMonthlySummaryKPIs(InstituteId, SessionId, SelectedMonth, SelectedYear);

            if (dtKPI.Rows.Count > 0)
            {
                var r = dtKPI.Rows[0];

                lblNewStudents.Text = r["NewStudents"].ToString();
                lblTotalActive.Text = r["TotalActiveStudents"].ToString();
                lblAttendancePct.Text = FormatDecimal(r["AttendancePct"]) + "%";

                lblAssignCreated.Text = r["AssignmentsCreated"].ToString();
                lblAssignSub.Text = r["AssignmentSubmissions"].ToString();

                lblVideosUploaded.Text = r["VideosUploaded"].ToString();
                lblVideoViews.Text = r["VideoViews"].ToString();

                lblQuizAttempts.Text = r["QuizAttempts"].ToString();
                lblAvgQuizScore.Text = FormatDecimal(r["AvgQuizScore"]);

                lblHelpRequests.Text = r["HelpRequests"].ToString();
                lblNotificationsSent.Text = r["NotificationsSent"].ToString();

                lblAttTrend.Text = TrendHtml(
                    ParseDouble(r["AttendancePct"]),
                    ParseDouble(r["PrevAttendancePct"])
                );

                lblStudentTrend.Text = TrendHtml(
                    ParseInt(r["NewStudents"]),
                    ParseInt(r["PrevNewStudents"])
                );
            }

            // ───── Charts Data ─────
            hdnDailyAttDays.Value = BuildJsonArray(bl.GetDailyAttendance(InstituteId, SessionId, SelectedMonth, SelectedYear), "DayNum");
            hdnDailyAttPresent.Value = BuildJsonArray(bl.GetDailyAttendance(InstituteId, SessionId, SelectedMonth, SelectedYear), "Present");
            hdnDailyAttAbsent.Value = BuildJsonArray(bl.GetDailyAttendance(InstituteId, SessionId, SelectedMonth, SelectedYear), "Absent");

            var dtVideo = bl.GetWeeklyVideoViews(InstituteId, SessionId, SelectedMonth, SelectedYear);
            hdnVideoWeeks.Value = BuildJsonStringArray(dtVideo, "WeekLabel");
            hdnVideoViews.Value = BuildJsonArray(dtVideo, "Views");
            hdnVideoCompleted.Value = BuildJsonArray(dtVideo, "Completed");

            var dtAssign = bl.GetSubjectAssignmentStats(InstituteId, SessionId, SelectedMonth, SelectedYear);
            hdnAssignSubjects.Value = BuildJsonStringArray(dtAssign, "SubjectName");
            hdnAssignTotal.Value = BuildJsonArray(dtAssign, "TotalAssignments");
            hdnAssignSub.Value = BuildJsonArray(dtAssign, "Submissions");

            var dtQuiz = bl.GetQuizPerformanceBySubject(InstituteId, SessionId, SelectedMonth, SelectedYear);
            hdnQuizSubjects.Value = BuildJsonStringArray(dtQuiz, "SubjectName");
            hdnQuizAvgScore.Value = BuildJsonArray(dtQuiz, "AvgScore");
            hdnQuizPassRate.Value = BuildJsonArray(dtQuiz, "PassRate");

            var dtStream = bl.GetAttendanceByStream(InstituteId, SessionId, SelectedMonth, SelectedYear);
            hdnStreamLabels.Value = BuildJsonStringArray(dtStream, "StreamName");
            hdnStreamAtt.Value = BuildJsonArray(dtStream, "AttPct");

            var dtTrend = bl.GetLast6MonthsTrend(InstituteId, SessionId);
            hdnTrendMonths.Value = BuildJsonStringArray(dtTrend, "MonthName");
            hdnTrendStudents.Value = BuildJsonArray(dtTrend, "NewStudents");
            hdnTrendAtt.Value = BuildJsonArray(dtTrend, "AvgAttendance");
            hdnTrendViews.Value = BuildJsonArray(dtTrend, "VideoViews");

            rptTopTeachers.DataSource = bl.GetTopActiveTeachers(InstituteId, SessionId, SelectedMonth, SelectedYear);
            rptTopTeachers.DataBind();

            rptNotifications.DataSource = bl.GetRecentNotifications(InstituteId, SessionId, SelectedMonth, SelectedYear);
            rptNotifications.DataBind();

            rptEvents.DataSource = bl.GetMonthlyEvents(InstituteId, SessionId, SelectedMonth, SelectedYear);
            rptEvents.DataBind();
        }

        // ───── Banner Upload ─────
        protected void btnUploadBanner_Click(object sender, EventArgs e)
        {
            int SelectedMonth = Convert.ToInt32(ddlMonth.SelectedValue);
            int SelectedYear = Convert.ToInt32(ddlYear.SelectedValue);

            if (!fuBanner.HasFile)
            {
                ShowAlert("Select a file first", "warning");
                return;
            }

            string ext = Path.GetExtension(fuBanner.FileName).ToLower();
            string[] allowed = { ".jpg", ".jpeg", ".png", ".webp" };

            if (Array.IndexOf(allowed, ext) < 0)
            {
                ShowAlert("Invalid file type", "danger");
                return;
            }

            string folder = Server.MapPath("~/Uploads/MonthlyBanners/");
            if (!Directory.Exists(folder)) Directory.CreateDirectory(folder);

            string fileName = $"banner_{InstituteId}_{SelectedMonth}_{SelectedYear}{ext}";
            string path = Path.Combine(folder, fileName);

            fuBanner.SaveAs(path);

            imgBannerPreview.ImageUrl = "~/Uploads/MonthlyBanners/" + fileName;
            imgBannerPreview.Visible = true;

            ShowAlert("Uploaded successfully", "success");
        }

        protected void btnRemoveBanner_Click(object sender, EventArgs e)
        {
            if (!string.IsNullOrEmpty(imgBannerPreview.ImageUrl))
            {
                string path = Server.MapPath(imgBannerPreview.ImageUrl);
                if (File.Exists(path)) File.Delete(path);

                imgBannerPreview.Visible = false;
                ShowAlert("Banner removed", "info");
            }
        }

        // ───── Helpers ─────
        private string BuildJsonArray(DataTable dt, string col)
        {
            if (dt == null || dt.Rows.Count == 0) return "[]";

            StringBuilder sb = new StringBuilder("[");
            foreach (DataRow r in dt.Rows)
                sb.Append(r[col] ?? 0).Append(",");

            if (sb.Length > 1) sb.Length--;
            sb.Append("]");
            return sb.ToString();
        }

        private string BuildJsonStringArray(DataTable dt, string col)
        {
            if (dt == null || dt.Rows.Count == 0) return "[]";

            StringBuilder sb = new StringBuilder("[");
            foreach (DataRow r in dt.Rows)
                sb.Append($"\"{r[col]}\",");

            if (sb.Length > 1) sb.Length--;
            sb.Append("]");
            return sb.ToString();
        }

        private string TrendHtml(double cur, double prev)
        {
            if (cur > prev) return $"<span class='trend-up'>↑ {cur - prev:0.#}%</span>";
            if (cur < prev) return $"<span class='trend-dn'>↓ {prev - cur:0.#}%</span>";
            return "<span class='trend-eq'>No change</span>";
        }

        private string FormatDecimal(object val)
        {
            return val == DBNull.Value ? "0" : Convert.ToDecimal(val).ToString("0.##");
        }

        private double ParseDouble(object val)
        {
            return val == DBNull.Value ? 0 : Convert.ToDouble(val);
        }

        private int ParseInt(object val)
        {
            return val == DBNull.Value ? 0 : Convert.ToInt32(val);
        }

        private void ShowAlert(string msg, string type)
        {
            pnlAlert.Visible = true;
            lblAlert.Text = msg;
            pnlAlert.CssClass = $"dash-alert alert-{type}";
        }

        // ✅ FIXED: moved inside class
        public string GetNotifClass(string type)
        {
            switch (type)
            {
                case "Assignment": return "assignment";
                case "Quiz": return "quiz";
                case "Alert": return "alert";
                default: return "general";
            }
        }

        public string GetNotifIcon(string type)
        {
            switch (type)
            {
                case "Assignment": return "fa fa-clipboard";
                case "Quiz": return "fa fa-question-circle";
                case "Alert": return "fa fa-triangle-exclamation";
                default: return "fa fa-bell";
            }
        }
    }
}