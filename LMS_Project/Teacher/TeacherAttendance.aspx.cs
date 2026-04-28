using LMS_Project.Student;
using System;
using System.Collections.Generic;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;

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
            ddl.Items.Add(new ListItem("-- Select Subject --", ""));
            if (dt == null || dt.Rows.Count == 0) return;

            foreach (DataRow row in dt.Rows)
            {
                string subjectId = row[AttendanceGC.COL_SUBJECT_ID].ToString();
                string subjectName = row[AttendanceGC.COL_SUBJECT_NAME].ToString();
                string sessionId = row[AttendanceGC.COL_SESSION_ID].ToString();
                string sectionName = row[AttendanceGC.COL_SECTION_NAME] != DBNull.Value
                                     ? " [" + row[AttendanceGC.COL_SECTION_NAME] + "]" : "";
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

        // ── TAB 1: MARK ATTENDANCE ──────────────────────────────

        protected void btnLoadStudents_Click(object sender, EventArgs e)
        {
            hfActiveTab.Value = "mark";
            HideAlert();

            if (string.IsNullOrEmpty(ddlSubject.SelectedValue))
            { ShowAlert(AttendanceGC.MSG_SELECT_SUBJECT, "info"); return; }

            if (string.IsNullOrEmpty(txtDate.Text))
            { ShowAlert(AttendanceGC.MSG_SELECT_DATE, "warning"); return; }

            DateTime selectedDate = DateTime.Parse(txtDate.Text);

            if (selectedDate.Date > DateTime.Today)
            { ShowAlert(AttendanceGC.MSG_FUTURE_DATE, "warning"); return; }

            var (subjectId, sessionId) = ParseDDLValue(ddlSubject.SelectedValue);

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

            DateTime selectedDate = DateTime.Parse(txtDate.Text);
            var (subjectId, sessionId) = ParseDDLValue(ddlSubject.SelectedValue);

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
            }
            catch (Exception ex)
            {
                ShowAlert("Error: " + ex.Message, "danger");
            }
        }

        // ── TAB 2: REPORT ───────────────────────────────────────

        protected void btnLoadReport_Click(object sender, EventArgs e)
        {
            hfActiveTab.Value = "report";   // ← ADD THIS LINE

            if (string.IsNullOrEmpty(ddlReportSubject.SelectedValue)) return;

            var (subjectId, sessionId) = ParseDDLValue(ddlReportSubject.SelectedValue);

            DateTime from = string.IsNullOrEmpty(txtReportFrom.Text)
                            ? DateTime.Today.AddMonths(-1) : DateTime.Parse(txtReportFrom.Text);
            DateTime to = string.IsNullOrEmpty(txtReportTo.Text)
                            ? DateTime.Today : DateTime.Parse(txtReportTo.Text);

            DataTable dt = _bl.GetAttendanceReport(subjectId, sessionId, InstituteId, SocietyId, from, to);

            if (dt == null || dt.Rows.Count == 0)
            { pnlReport.Visible = false; pnlReportStats.Visible = false; return; }

            int totalStudents = dt.Rows.Count;
            int lowAttendance = 0;
            double sumPct = 0;

            foreach (DataRow row in dt.Rows)
            {
                double pct = Convert.ToDouble(row[AttendanceGC.COL_PERCENTAGE]);
                sumPct += pct;
                if (pct < 75) lowAttendance++;
            }

            lblTotalStudents.Text = totalStudents.ToString();
            lblAvgPresent.Text = totalStudents > 0
                                    ? Math.Round(sumPct / totalStudents, 1) + "%" : "0%";
            lblLowAttendance.Text = lowAttendance.ToString();

            rptReport.DataSource = dt;
            rptReport.DataBind();
            pnlReportStats.Visible = true;
            pnlReport.Visible = true;
        }

        // ── TAB 3: DAY-WISE ─────────────────────────────────────

        protected void btnLoadDaywise_Click(object sender, EventArgs e)
        {
            hfActiveTab.Value = "daywise";   // ← ADD THIS LINE

            if (string.IsNullOrEmpty(ddlDaySubject.SelectedValue)) return;

            var (subjectId, sessionId) = ParseDDLValue(ddlDaySubject.SelectedValue);

            DateTime from = string.IsNullOrEmpty(txtDayFrom.Text)
                            ? DateTime.Today.AddMonths(-1) : DateTime.Parse(txtDayFrom.Text);
            DateTime to = string.IsNullOrEmpty(txtDayTo.Text)
                            ? DateTime.Today : DateTime.Parse(txtDayTo.Text);

            DataTable dt = _bl.GetDayWiseAttendance(subjectId, sessionId, InstituteId, SocietyId, from, to);

            if (dt == null || dt.Rows.Count == 0)
            { pnlDaywise.Visible = false; return; }

            rptDaywise.DataSource = dt;
            rptDaywise.DataBind();
            pnlDaywise.Visible = true;
        }
        // ── Helpers ─────────────────────────────────────────────

        private void ShowAlert(string message, string type)
        {
            lblAlert.Text = message;
            markAlert.Attributes["class"] = "att-alert att-alert-" + type;
            pnlAlert.Visible = true;
        }

        private void HideAlert()
        {
            pnlAlert.Visible = false;
        }
    }
}