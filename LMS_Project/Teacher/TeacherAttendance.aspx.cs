using System;
using System.Collections.Generic;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using static AttendanceBL;

namespace LMS_Project.Teacher
{
    public partial class TeacherAttendance : Page
    {
        private readonly AttendanceBL _bl = new AttendanceBL();

        private int TeacherId => Convert.ToInt32(Session[AttendanceGC.SESSION_USER_ID]);
        private int InstituteId => Convert.ToInt32(Session[AttendanceGC.SESSION_INSTITUTE_ID]);
        private int SocietyId => Convert.ToInt32(Session[AttendanceGC.SESSION_SOCIETY_ID]);

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session[AttendanceGC.SESSION_USER_ID] == null)
            {
                Response.Redirect("~/Default.aspx");
                return;
            }

            if (!IsPostBack)
            {
                txtDate.Text = DateTime.Today.ToString(AttendanceGC.DATE_FORMAT);
                txtReportFrom.Text = DateTime.Today.AddDays(-30).ToString(AttendanceGC.DATE_FORMAT);
                txtReportTo.Text = DateTime.Today.ToString(AttendanceGC.DATE_FORMAT);
                txtDayFrom.Text = DateTime.Today.AddDays(-30).ToString(AttendanceGC.DATE_FORMAT);
                txtDayTo.Text = DateTime.Today.ToString(AttendanceGC.DATE_FORMAT);

                LoadSubjectDropdowns();

                // Load Analytics data automatically on page load
                LoadAnalyticsData();
            }
        }

        private void LoadSubjectDropdowns()
        {
            DataTable dt = _bl.GetTeacherSubjects(TeacherId, InstituteId, SocietyId);
            BindSubjectDDL(ddlSubject, dt);
            BindSubjectDDL(ddlReportSubject, dt);
            BindSubjectDDL(ddlDaySubject, dt);
        }

        private static void BindSubjectDDL(DropDownList ddl, DataTable dt)
        {
            ddl.Items.Clear();
            if (dt == null || dt.Rows.Count == 0)
            {
                ddl.Items.Add(new ListItem("-- No Subjects Assigned --", ""));
                return;
            }

            foreach (DataRow row in dt.Rows)
            {
                string subjectId = row["SubjectId"].ToString();
                string subjectName = row["SubjectName"].ToString();
                string sessionId = row["SessionId"].ToString();
                string sectionName = row["SectionName"] != DBNull.Value
                                     ? " [" + row["SectionName"] + "]" : "";
                ddl.Items.Add(new ListItem(subjectName + sectionName, subjectId + "|" + sessionId));
            }
        }

        private static (int SubjectId, int SessionId) ParseDDLValue(string val)
        {
            if (string.IsNullOrEmpty(val)) return (0, 0);
            var parts = val.Split('|');
            int sid = parts.Length > 0 && int.TryParse(parts[0], out int s) ? s : 0;
            int sesId = parts.Length > 1 && int.TryParse(parts[1], out int se) ? se : 0;
            return (sid, sesId);
        }

        // ── TAB 1: MARK ATTENDANCE ──
        protected void btnLoadStudents_Click(object sender, EventArgs e)
        {
            hfActiveTab.Value = "mark";
            HideAlert();

            if (string.IsNullOrEmpty(ddlSubject.SelectedValue) || ddlSubject.SelectedValue == "0|0")
            { ShowAlert(AttendanceGC.MSG_SELECT_SUBJECT, "info"); return; }

            if (string.IsNullOrEmpty(txtDate.Text))
            { ShowAlert(AttendanceGC.MSG_SELECT_DATE, "warning"); return; }

            DateTime selectedDate;
            if (!DateTime.TryParse(txtDate.Text, out selectedDate))
            { ShowAlert("Invalid date format.", "warning"); return; }

            if (selectedDate.Date > DateTime.Today)
            { ShowAlert(AttendanceGC.MSG_FUTURE_DATE, "warning"); return; }

            var (subjectId, sessionId) = ParseDDLValue(ddlSubject.SelectedValue);

            if (subjectId == 0)
            { ShowAlert("Invalid subject selected.", "warning"); return; }

            DataTable dt = _bl.GetStudentsForSubject(subjectId, sessionId, InstituteId, SocietyId, selectedDate);

            if (dt == null || dt.Rows.Count == 0)
            {
                ShowAlert(AttendanceGC.MSG_NO_STUDENTS, "info");
                pnlAttendanceGrid.Visible = false;
                return;
            }

            bool alreadyMarked = _bl.IsAttendanceAlreadyMarked(subjectId, selectedDate, InstituteId, SocietyId);
            if (alreadyMarked)
                ShowAlert(AttendanceGC.MSG_ALREADY_MARKED, "warning");

            rptStudents.DataSource = dt;
            rptStudents.DataBind();

            lblGridTitle.Text = "Students – " + ddlSubject.SelectedItem.Text;
            lblSelectedDate.Text = selectedDate.ToString("dd MMM yyyy");
            pnlAttendanceGrid.Visible = true;
            hfAttendanceData.Value = "";
        }

        protected void btnSaveAttendance_Click(object sender, EventArgs e)
        {
            hfActiveTab.Value = "mark";
            if (string.IsNullOrEmpty(hfAttendanceData.Value))
            { ShowAlert("No attendance data received. Please try again.", "danger"); return; }

            DateTime selectedDate;
            if (!DateTime.TryParse(txtDate.Text, out selectedDate))
            { ShowAlert("Invalid date.", "danger"); return; }

            var (subjectId, sessionId) = ParseDDLValue(ddlSubject.SelectedValue);

            if (subjectId == 0)
            { ShowAlert("Invalid subject.", "danger"); return; }

            List<AttendanceRecord> records = new List<AttendanceRecord>();

            foreach (string entry in hfAttendanceData.Value.Split(','))
            {
                string[] parts = entry.Split(':');
                if (parts.Length != 2) continue;
                if (!int.TryParse(parts[0], out int userId)) continue;

                records.Add(new AttendanceRecord
                {
                    UserId = userId,
                    SubjectId = subjectId,
                    SessionId = sessionId,
                    Date = selectedDate,
                    Status = parts[1]
                });
            }

            if (records.Count == 0)
            { ShowAlert("Nothing to save.", "warning"); return; }

            try
            {
                bool saved = _bl.SaveAttendance(records, TeacherId, SocietyId, InstituteId);
                ShowAlert(saved ? AttendanceGC.MSG_ATTENDANCE_SAVED : AttendanceGC.MSG_ERROR,
                          saved ? "success" : "danger");
                if (saved)
                {
                    btnLoadStudents_Click(sender, e);
                }
            }
            catch (Exception ex)
            {
                ShowAlert("Error: " + ex.Message, "danger");
            }
        }

        // ── TAB 2: REPORT ──
        protected void btnLoadReport_Click(object sender, EventArgs e)
        {
            hfActiveTab.Value = "report";

            if (string.IsNullOrEmpty(ddlReportSubject.SelectedValue) || ddlReportSubject.SelectedValue == "0|0")
            { ShowAlert("Please select a subject.", "warning"); return; }

            var (subjectId, sessionId) = ParseDDLValue(ddlReportSubject.SelectedValue);

            DateTime from, to;
            if (!DateTime.TryParse(txtReportFrom.Text, out from))
                from = DateTime.Today.AddMonths(-1);
            if (!DateTime.TryParse(txtReportTo.Text, out to))
                to = DateTime.Today;

            DataTable dt = _bl.GetAttendanceReport(subjectId, sessionId, InstituteId, SocietyId, from, to);

            if (dt == null || dt.Rows.Count == 0)
            {
                pnlReport.Visible = false;
                pnlReportStats.Visible = false;
                ShowAlert("No attendance records found for the selected criteria.", "info");
                return;
            }

            int totalStudents = dt.Rows.Count;
            int lowAttendance = 0;
            double sumPct = 0;

            foreach (DataRow row in dt.Rows)
            {
                double pct = Convert.ToDouble(row["Percentage"]);
                sumPct += pct;
                if (pct < 75) lowAttendance++;
            }

            lblTotalStudents.Text = totalStudents.ToString();
            lblAvgPresent.Text = totalStudents > 0
                                    ? Math.Round(sumPct / totalStudents, 1).ToString() + "%" : "0%";
            lblLowAttendance.Text = lowAttendance.ToString();

            rptReport.DataSource = dt;
            rptReport.DataBind();
            pnlReportStats.Visible = true;
            pnlReport.Visible = true;
        }

        // ── TAB 3: DAY-WISE ──
        protected void btnLoadDaywise_Click(object sender, EventArgs e)
        {
            hfActiveTab.Value = "daywise";

            if (string.IsNullOrEmpty(ddlDaySubject.SelectedValue) || ddlDaySubject.SelectedValue == "0|0")
            { ShowAlert("Please select a subject.", "warning"); return; }

            var (subjectId, sessionId) = ParseDDLValue(ddlDaySubject.SelectedValue);

            DateTime from, to;
            if (!DateTime.TryParse(txtDayFrom.Text, out from))
                from = DateTime.Today.AddMonths(-1);
            if (!DateTime.TryParse(txtDayTo.Text, out to))
                to = DateTime.Today;

            DataTable dt = _bl.GetDayWiseAttendance(subjectId, sessionId, InstituteId, SocietyId, from, to);

            if (dt == null || dt.Rows.Count == 0)
            {
                pnlDaywise.Visible = false;
                ShowAlert("No day-wise records found.", "info");
                return;
            }

            rptDaywise.DataSource = dt;
            rptDaywise.DataBind();
            pnlDaywise.Visible = true;
        }

        // ── TAB 4: ANALYTICS (Auto-loaded, no filters) ──
        private void LoadAnalyticsData()
        {
            try
            {
                // Get current academic session dates (current month and year)
                DateTime currentDate = DateTime.Today;
                DateTime fromDate = new DateTime(currentDate.Year, currentDate.Month, 1);
                DateTime toDate = currentDate;

                // Load analytics for all subjects (subjectId = 0 means all subjects)
                AnalyticsResult r = _bl.GetAnalyticsData(
                    TeacherId, 0, 0, InstituteId, SocietyId, fromDate, toDate);

                if (r == null || (r.SubjectNames.Count == 0 && r.TotalPresent == 0))
                {
                    pnlAnalytics.Visible = false;
                    return;
                }

                // Load daily attendance for current month
                DataTable dtDaily = _bl.GetDailyAttendanceForMonth(TeacherId, InstituteId, SocietyId,
                    currentDate.Year, currentDate.Month);

                if (dtDaily != null && dtDaily.Rows.Count > 0)
                {
                    rptDailyAttendance.DataSource = dtDaily;
                    rptDailyAttendance.DataBind();
                }

                // Update KPI cards
                lblAnaAvgPct.Text = r.AvgAttendancePct.ToString("F1");
                lblAnaTotalPresent.Text = r.TotalPresent.ToString();
                lblAnaTotalAbsent.Text = r.TotalAbsent.ToString();
                lblAnaTotalLeave.Text = r.TotalLeave.ToString();
                lblAnaLowCount.Text = r.LowAttendanceCount.ToString();
                lblAnaTotalDays.Text = r.TotalClassDays.ToString();

                // Store data in hidden fields for JavaScript charts
                hfPieData.Value = Newtonsoft.Json.JsonConvert.SerializeObject(new { present = r.TotalPresent, absent = r.TotalAbsent, leave = r.TotalLeave });
                hfSubjectData.Value = Newtonsoft.Json.JsonConvert.SerializeObject(new { labels = r.SubjectNames, values = r.SubjectAvgPct });
                hfMonthlyData.Value = Newtonsoft.Json.JsonConvert.SerializeObject(new { labels = r.MonthLabels, present = r.MonthPresent, absent = r.MonthAbsent, leave = r.MonthLeave });
                hfDowData.Value = Newtonsoft.Json.JsonConvert.SerializeObject(new { labels = r.DowLabels, values = r.DowAvgPct });
                hfDistData.Value = Newtonsoft.Json.JsonConvert.SerializeObject(new { labels = r.DistLabels, values = r.DistCounts });
                hfSubBarData.Value = Newtonsoft.Json.JsonConvert.SerializeObject(new { labels = r.SubjectNames, present = r.SubjectPresent, absent = r.SubjectAbsent, leave = r.SubjectLeave });
                hfAbsenteeData.Value = Newtonsoft.Json.JsonConvert.SerializeObject(new { labels = r.AbsenteeNames, values = r.AbsenteeCounts });
                hfTopStudentData.Value = Newtonsoft.Json.JsonConvert.SerializeObject(new { labels = r.TopStudentNames, values = r.TopStudentPct });
                hfRiskData.Value = Newtonsoft.Json.JsonConvert.SerializeObject(new { labels = r.SubjectNames, safe = r.RiskSafe, good = r.RiskGood, warning = r.RiskWarning, danger = r.RiskDanger });
                hfCumulData.Value = Newtonsoft.Json.JsonConvert.SerializeObject(new { labels = r.CumulDates, values = r.CumulPresent });

                pnlAnalytics.Visible = true;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error loading analytics: " + ex.Message);
                pnlAnalytics.Visible = false;
            }
        }
        // Optional: Method to refresh analytics data
        protected void btnRefreshAnalytics_Click(object sender, EventArgs e)
        {
            LoadAnalyticsData();
            ShowAlert("Analytics data refreshed!", "success");
        }
        // Helper method to calculate percentage for the repeater
        protected string GetPercentage(object presentCount, object totalStudents)
        {
            try
            {
                int present = Convert.ToInt32(presentCount);
                int total = Convert.ToInt32(totalStudents);
                if (total == 0) return "0";
                return Math.Round((double)present / total * 100, 0).ToString();
            }
            catch
            {
                return "0";
            }
        }
        // ── Helpers ──
        private void ShowAlert(string message, string type)
        {
            lblAlert.Text = message;
            string alertClass = "att-alert att-alert-" + type;
            markAlert.Attributes["class"] = alertClass;
            pnlAlert.Visible = true;
        }

        private void HideAlert()
        {
            pnlAlert.Visible = false;
        }
    }
}