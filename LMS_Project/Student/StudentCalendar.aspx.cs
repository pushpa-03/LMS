using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace LMS_Project.Student
{
    public partial class StudentCalendar : System.Web.UI.Page
    {
        CalendarBL bl = new CalendarBL();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                ViewState["CurrentDate"] = DateTime.Today;
                BindAll();
            }
        }

        void BindAll()
        {
            DateTime dt = (DateTime)ViewState["CurrentDate"];

            calEvents.VisibleDate = dt;
            lblMonthYear.Text = dt.ToString("MMMM yyyy");
            lblTableMonthYear.Text = dt.ToString("MMMM yyyy");

            if (Session["InstituteId"] == null || Session["UserId"] == null) return;

            int instituteId = Convert.ToInt32(Session["InstituteId"]);
            int studentId = Convert.ToInt32(Session["UserId"]);

            DataTable events = bl.GetEventsByMonthForStudent(dt.Year, dt.Month, instituteId, studentId);
            gvEvents.DataSource = events;
            gvEvents.DataBind();
        }

        protected void btnPrev_Click(object sender, EventArgs e)
        {
            ViewState["CurrentDate"] = ((DateTime)ViewState["CurrentDate"]).AddMonths(-1);
            BindAll();
        }

        protected void btnNext_Click(object sender, EventArgs e)
        {
            ViewState["CurrentDate"] = ((DateTime)ViewState["CurrentDate"]).AddMonths(1);
            BindAll();
        }

        protected void calEvents_DayRender(object sender, DayRenderEventArgs e)
        {
            e.Cell.Controls.Clear();
            e.Cell.Controls.Add(new Literal
            {
                Text = $"<span class='day-number'>{e.Day.DayNumberText}</span>"
            });

            if (Session["InstituteId"] == null || Session["UserId"] == null) return;

            int instituteId = Convert.ToInt32(Session["InstituteId"]);
            int studentId = Convert.ToInt32(Session["UserId"]);

            DataTable dt = bl.GetEventsForStudent(e.Day.Date, instituteId, studentId);

            foreach (DataRow row in dt.Rows)
            {
                string title = System.Web.HttpUtility.HtmlEncode(row["Title"].ToString());
                string type = row["EventType"].ToString();

                string css = "event-general";
                if (type == "Holiday") css = "event-holiday";
                else if (type == "Exam") css = "event-exam";
                else if (type == "Assignment") css = "event-assignment";

                e.Cell.Controls.Add(new Literal
                {
                    Text = $"<span class='event-dot {css}' title='{title}'>{title}</span>"
                });
            }
        }
    }
}