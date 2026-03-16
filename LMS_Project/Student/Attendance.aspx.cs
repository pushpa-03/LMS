using System;
using System.Data;
using System.Text;
using System.Web.UI.WebControls;

namespace LMS_Project.Student
{
    public partial class Attendance : System.Web.UI.Page
    {
        StudentAttendanceBL bl = new StudentAttendanceBL();

        private int _userId;
        private int _instituteId;
        private int _sessionId;

        protected void Page_Load(object sender, EventArgs e)
        {
            _userId = Convert.ToInt32(Session["UserId"]);
            _instituteId = Convert.ToInt32(Session["InstituteId"]);

            StudentSubjectsBL subBL = new StudentSubjectsBL();
            _sessionId = Session["CurrentSessionId"] != null
                         ? Convert.ToInt32(Session["CurrentSessionId"])
                         : subBL.GetCurrentSessionId(_instituteId);

            if (!IsPostBack)
            {
                // Default calendar to current month
                hfYear.Value = DateTime.Now.Year.ToString();
                hfMonth.Value = DateTime.Now.Month.ToString();

                LoadOverallSummary();
                LoadSubjectCards();
                LoadCalendarSubjectDropdown();
                LoadRecentLog();
            }
        }

        // ── Overall banner ───────────────────────────────────────
        private void LoadOverallSummary()
        {
            DataTable dt = bl.GetOverallSummary(_userId, _instituteId, _sessionId);
            if (dt.Rows.Count == 0) return;

            DataRow r = dt.Rows[0];
            int present = r["Present"] == DBNull.Value ? 0 : Convert.ToInt32(r["Present"]);
            int absent = r["Absent"] == DBNull.Value ? 0 : Convert.ToInt32(r["Absent"]);
            int leave = r["Leave"] == DBNull.Value ? 0 : Convert.ToInt32(r["Leave"]);
            int total = Convert.ToInt32(r["Total"]);
            decimal pct = Convert.ToDecimal(r["Percentage"]);

            lblPresent.Text = present.ToString();
            lblAbsent.Text = absent.ToString();
            lblLeave.Text = leave.ToString();
            lblTotal.Text = total.ToString();

            litOverallRing.Text = BuildOverallRing((double)pct);
        }

        // ── Subject cards ────────────────────────────────────────
        private void LoadSubjectCards()
        {
            DataTable dt = bl.GetSubjectWiseAttendance(_userId, _instituteId, _sessionId);
            rptSubjects.DataSource = dt;
            rptSubjects.DataBind();
        }

        // ── Calendar subject dropdown ────────────────────────────
        private void LoadCalendarSubjectDropdown()
        {
            DataTable dt = bl.GetSubjectWiseAttendance(_userId, _instituteId, _sessionId);
            ddlCalSubject.Items.Clear();

            foreach (DataRow r in dt.Rows)
                ddlCalSubject.Items.Add(new ListItem(
                    r["SubjectCode"] + " — " + r["SubjectName"],
                    r["SubjectId"].ToString()));

            if (ddlCalSubject.Items.Count > 0)
            {
                // Use hfSubjectId if set (card click)
                int sid = Convert.ToInt32(hfSubjectId.Value);
                if (sid > 0)
                    ddlCalSubject.SelectedValue = sid.ToString();

                int subjectId = Convert.ToInt32(ddlCalSubject.SelectedValue);
                hfSubjectId.Value = subjectId.ToString();

                LoadCalendar(subjectId,
                    Convert.ToInt32(hfYear.Value),
                    Convert.ToInt32(hfMonth.Value));

                pnlCalendar.Visible = true;
            }
        }

        // ── Load calendar for selected subject + month ───────────
        private void LoadCalendar(int subjectId, int year, int month)
        {
            DataTable dt = bl.GetMonthlyAttendance(
                               _userId, subjectId, _instituteId, year, month);

            // Build a lookup: day → status
            var lookup = new System.Collections.Generic.Dictionary<int, string>();
            foreach (DataRow r in dt.Rows)
            {
                DateTime d = Convert.ToDateTime(r["Date"]);
                lookup[d.Day] = r["Status"].ToString();
            }

            lblCalMonthYear.Text =
                new DateTime(year, month, 1).ToString("MMMM yyyy");

            // Update subject label
            foreach (ListItem li in ddlCalSubject.Items)
                if (li.Value == subjectId.ToString())
                    lblCalSubject.Text = li.Text;

            litCalendar.Text = BuildCalendarHtml(year, month, lookup);
        }

        // ── Calendar HTML builder ────────────────────────────────
        private string BuildCalendarHtml(int year, int month,
            System.Collections.Generic.Dictionary<int, string> lookup)
        {
            var sb = new StringBuilder();
            string[] dayHeaders = { "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat" };
            DateTime firstDay = new DateTime(year, month, 1);
            int startDow = (int)firstDay.DayOfWeek; // 0=Sun
            int daysInMonth = DateTime.DaysInMonth(year, month);
            int today = (DateTime.Now.Year == year &&
                                    DateTime.Now.Month == month)
                                   ? DateTime.Now.Day : -1;

            sb.Append("<div class='cal-grid'>");

            // Day headers
            foreach (var h in dayHeaders)
                sb.Append($"<div class='cal-day-header'>{h}</div>");

            // Empty cells before first day
            for (int i = 0; i < startDow; i++)
                sb.Append("<div class='cal-day empty'></div>");

            // Day cells
            for (int d = 1; d <= daysInMonth; d++)
            {
                DateTime date = new DateTime(year, month, d);
                bool isWeekend = date.DayOfWeek == DayOfWeek.Saturday ||
                                 date.DayOfWeek == DayOfWeek.Sunday;
                bool isToday = (d == today);

                string css = "cal-day";
                if (isToday) css += " today";

                if (isWeekend)
                    css += " weekend";
                else if (lookup.ContainsKey(d))
                    css += " " + lookup[d].ToLower();
                else if (date < DateTime.Today)
                    css += " no-class";

                sb.Append($"<div class='{css}'>{d}</div>");
            }

            sb.Append("</div>");
            return sb.ToString();
        }

        // ── Recent log ───────────────────────────────────────────
        private void LoadRecentLog()
        {
            DataTable dt = bl.GetRecentAttendance(_userId, _instituteId, _sessionId);
            rptLog.DataSource = dt;
            rptLog.DataBind();
        }

        // ── Calendar events ──────────────────────────────────────
        protected void ddlCalSubject_Changed(object sender, EventArgs e)
        {
            int subjectId = Convert.ToInt32(ddlCalSubject.SelectedValue);
            hfSubjectId.Value = subjectId.ToString();
            LoadCalendar(subjectId,
                Convert.ToInt32(hfYear.Value),
                Convert.ToInt32(hfMonth.Value));
            pnlCalendar.Visible = true;
        }

        protected void btnPrevMonth_Click(object sender, EventArgs e)
        {
            // Check if triggered by card click
            string arg = Request["__EVENTARGUMENT"] ?? "";
            if (arg.StartsWith("select:"))
            {
                int sid = Convert.ToInt32(arg.Replace("select:", ""));
                hfSubjectId.Value = sid.ToString();
                if (ddlCalSubject.Items.FindByValue(sid.ToString()) != null)
                    ddlCalSubject.SelectedValue = sid.ToString();
                LoadCalendar(sid,
                    Convert.ToInt32(hfYear.Value),
                    Convert.ToInt32(hfMonth.Value));
                pnlCalendar.Visible = true;
                return;
            }

            // Normal prev month
            int year = Convert.ToInt32(hfYear.Value);
            int month = Convert.ToInt32(hfMonth.Value);
            month--;
            if (month < 1) { month = 12; year--; }
            hfYear.Value = year.ToString();
            hfMonth.Value = month.ToString();

            int subjectId = Convert.ToInt32(hfSubjectId.Value);
            LoadCalendar(subjectId, year, month);
            pnlCalendar.Visible = true;
        }

        protected void btnNextMonth_Click(object sender, EventArgs e)
        {
            int year = Convert.ToInt32(hfYear.Value);
            int month = Convert.ToInt32(hfMonth.Value);
            month++;
            if (month > 12) { month = 1; year++; }
            hfYear.Value = year.ToString();
            hfMonth.Value = month.ToString();

            int subjectId = Convert.ToInt32(hfSubjectId.Value);
            LoadCalendar(subjectId, year, month);
            pnlCalendar.Visible = true;
        }

        protected void rptSubjects_ItemCommand(object source,
            RepeaterCommandEventArgs e)
        { }

        // ── Helpers (called from ASPX) ───────────────────────────
        protected string GetAttendanceClass(decimal pct)
        {
            if (pct >= 75) return "high";
            if (pct >= 60) return "medium";
            return "low";
        }

        protected string GetAttendanceChip(decimal pct, int present, int total)
        {
            if (pct >= 75)
                return "<div class='safe-chip'>" +
                       "<i class='fas fa-check-circle'></i>" +
                       $"Good — {pct}%</div>";

            int needed = bl.ClassesNeededForTarget(present, total, 75);
            return "<div class='warning-chip'>" +
                   "<i class='fas fa-exclamation-triangle'></i>" +
                   $"{pct}% — Attend {needed} more class{(needed == 1 ? "" : "es")}" +
                   "</div>";
        }

        protected string BuildSmallDonut(decimal pct, int present, int total)
        {
            double angle = (double)pct / 100 * 251.2; // circumference = 2π*40
            string colorClass = pct >= 75 ? "high" : pct >= 60 ? "medium" : "low";
            string color = pct >= 75 ? "#2e7d32" : pct >= 60 ? "#f57f17" : "#c62828";

            return $@"
            <div class='small-donut'>
                <svg width='64' height='64' viewBox='0 0 64 64'>
                    <circle cx='32' cy='32' r='28' fill='none'
                            stroke='#e8f0fe' stroke-width='7'/>
                    <circle cx='32' cy='32' r='28' fill='none'
                            stroke='{color}' stroke-width='7'
                            stroke-dasharray='{angle:F1} 251.2'
                            stroke-linecap='round'
                            transform='rotate(-90 32 32)'/>
                </svg>
                <div class='sd-pct {colorClass}'>{pct}%</div>
            </div>";
        }

        private string BuildOverallRing(double pct)
        {
            double angle = pct / 100 * 314.2; // 2π*50
            string color = pct >= 75 ? "#ffffff" : pct >= 60 ? "#ffe082" : "#ef9a9a";

            return $@"
            <div style='position:relative;width:100px;height:100px;'>
                <svg width='100' height='100' viewBox='0 0 100 100'>
                    <circle cx='50' cy='50' r='44' fill='none'
                            stroke='rgba(255,255,255,.2)' stroke-width='10'/>
                    <circle cx='50' cy='50' r='44' fill='none'
                            stroke='{color}' stroke-width='10'
                            stroke-dasharray='{angle:F1} 314.2'
                            stroke-linecap='round'
                            transform='rotate(-90 50 50)'/>
                </svg>
                <div style='position:absolute;top:50%;left:50%;
                            transform:translate(-50%,-50%);text-align:center;'>
                    <div style='font-size:22px;font-weight:900;color:#fff;line-height:1;'>{pct:F0}%</div>
                    <div style='font-size:10px;color:rgba(255,255,255,.7);
                                text-transform:uppercase;letter-spacing:.4px;'>Overall</div>
                </div>
            </div>";
        }
    }
}