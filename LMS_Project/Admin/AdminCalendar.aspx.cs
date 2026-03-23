using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace LMS_Project.Admin
{
    public partial class AdminCalendar : System.Web.UI.Page
    {
        CalendarBL bl = new CalendarBL();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                ViewState["CurrentDate"] = DateTime.Today;
                txtStartDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
                txtEndDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
                BindAll();
            }
        }

        // Bind calendar + table together
        void BindAll()
        {
            DateTime dt = (DateTime)ViewState["CurrentDate"];

            // Calendar
            calEvents.VisibleDate = dt;
            lblMonthYear.Text = dt.ToString("MMMM yyyy");
            lblTableMonthYear.Text = dt.ToString("MMMM yyyy");

            // Table — only if session ready
            if (Session["InstituteId"] != null)
            {
                int instituteId = Convert.ToInt32(Session["InstituteId"]);
                DataTable events = bl.GetEventsByMonth(dt.Year, dt.Month, instituteId);
                gvEvents.DataSource = events;
                gvEvents.DataBind();
            }
        }

        protected void btnPrev_Click(object sender, EventArgs e)
        {
            ViewState["CurrentDate"] = ((DateTime)ViewState["CurrentDate"]).AddMonths(-1);
            hfReopenModal.Value = "";
            BindAll();
        }

        protected void btnNext_Click(object sender, EventArgs e)
        {
            ViewState["CurrentDate"] = ((DateTime)ViewState["CurrentDate"]).AddMonths(1);
            hfReopenModal.Value = "";
            BindAll();
        }

        protected void calEvents_DayRender(object sender, DayRenderEventArgs e)
        {
            e.Cell.Controls.Clear();
            e.Cell.Controls.Add(new Literal
            {
                Text = $"<span class='day-number'>{e.Day.DayNumberText}</span>"
            });

            if (Session["InstituteId"] == null) return;
            int instituteId = Convert.ToInt32(Session["InstituteId"]);

            DataTable dt = bl.GetEvents(e.Day.Date, instituteId);

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

        // ── ADD ────────────────────────────────────────────────
        protected void btnSave_Click(object sender, EventArgs e)
        {
            hfReopenModal.Value = "addEventModal";
            if (!Page.IsValid) return;

            DateTime startDate, endDate;
            if (!DateTime.TryParse(txtStartDate.Text, out startDate) ||
                !DateTime.TryParse(txtEndDate.Text, out endDate))
            {
                ShowMsg(lblMessage, "Invalid date format.", false);
                return;
            }
            if (endDate < startDate)
            {
                ShowMsg(lblMessage, "End date cannot be before start date.", false);
                return;
            }

            CalendarGC obj = new CalendarGC
            {
                InstituteId = Session["InstituteId"] != null ? (int?)Convert.ToInt32(Session["InstituteId"]) : null,
                UserId = Session["UserId"] != null ? (int?)Convert.ToInt32(Session["UserId"]) : null,
                SocietyId = null,
                Title = txtTitle.Text.Trim(),
                EventType = ddlEventType.SelectedValue,
                StartTime = startDate,
                EndTime = endDate,
                IsAllDay = chkAllDay.Checked,
                SubjectId = null
            };

            bl.AddEvent(obj);

            txtTitle.Text = "";
            txtStartDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
            txtEndDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
            chkAllDay.Checked = false;

            ShowMsg(lblMessage, "✅ Event saved successfully!", true);

            // Stay on saved event's month, close modal
            ViewState["CurrentDate"] = startDate;
            hfReopenModal.Value = "";
            BindAll();
        }

        // ── GRIDVIEW EDIT / DELETE ─────────────────────────────
        protected void gvEvents_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int eventId = Convert.ToInt32(e.CommandArgument);
            int instituteId = Convert.ToInt32(Session["InstituteId"]);

            if (e.CommandName == "EditEvent")
            {
                // Load event group range into edit modal
                DateTime groupStart, groupEnd;
                bl.GetEventGroupRange(eventId, instituteId, out groupStart, out groupEnd);

                CalendarGC ev = bl.GetEventById(eventId);

                hfEditEventId.Value = eventId.ToString();
                txtEditTitle.Text = ev.Title;
                ddlEditEventType.SelectedValue = ev.EventType;
                txtEditStartDate.Text = groupStart.ToString("yyyy-MM-dd");
                txtEditEndDate.Text = groupEnd.ToString("yyyy-MM-dd");
                chkEditAllDay.Checked = ev.IsAllDay;

                hfReopenModal.Value = "editEventModal";
                BindAll();
            }
            else if (e.CommandName == "DeleteEvent")
            {
                bl.DeleteEventGroup(eventId, instituteId);
                hfReopenModal.Value = "";
                BindAll();
            }
        }

        // ── UPDATE ─────────────────────────────────────────────
        protected void btnUpdate_Click(object sender, EventArgs e)
        {
            hfReopenModal.Value = "editEventModal";
            if (!Page.IsValid) return;

            DateTime startDate, endDate;
            if (!DateTime.TryParse(txtEditStartDate.Text, out startDate) ||
                !DateTime.TryParse(txtEditEndDate.Text, out endDate))
            {
                ShowMsg(lblEditMessage, "Invalid date format.", false);
                return;
            }
            if (endDate < startDate)
            {
                ShowMsg(lblEditMessage, "End date cannot be before start date.", false);
                return;
            }

            int eventId = Convert.ToInt32(hfEditEventId.Value);
            int instituteId = Convert.ToInt32(Session["InstituteId"]);

            // Delete old group, re-insert with new range
            bl.DeleteEventGroup(eventId, instituteId);

            CalendarGC obj = new CalendarGC
            {
                InstituteId = instituteId,
                UserId = Session["UserId"] != null ? (int?)Convert.ToInt32(Session["UserId"]) : null,
                SocietyId = null,
                Title = txtEditTitle.Text.Trim(),
                EventType = ddlEditEventType.SelectedValue,
                StartTime = startDate,
                EndTime = endDate,
                IsAllDay = chkEditAllDay.Checked,
                SubjectId = null
            };

            bl.AddEvent(obj);

            hfReopenModal.Value = ""; // close modal after update
            ViewState["CurrentDate"] = startDate;
            BindAll();
        }

        // ── HELPER ────────────────────────────────────────────
        void ShowMsg(System.Web.UI.WebControls.Label lbl, string msg, bool success)
        {
            lbl.Text = msg;
            lbl.CssClass = success ? "text-success small" : "text-danger small";
            lbl.Visible = true;
        }
    }
}