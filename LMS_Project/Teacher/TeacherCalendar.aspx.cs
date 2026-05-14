using LearningManagementSystem.Admin;
using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace LMS_Project.Teacher
{
    public partial class TeacherCalendar : System.Web.UI.Page
    {
        CalendarBL bl = new CalendarBL();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // TEMPORARY: Set default session values for testing
                // IMPORTANT: Remove these 3 lines after your login page is properly set up
                if (Session["UserId"] == null) Session["UserId"] = 1;  // Change to a valid teacher ID from your database
                if (Session["InstituteId"] == null) Session["InstituteId"] = 1;  // Change to a valid institute ID
                if (Session["SessionId"] == null) Session["SessionId"] = 1;  // Change to a valid session ID

                // Check if user is logged in
                if (Session["UserId"] == null || Session["InstituteId"] == null || Session["SessionId"] == null)
                {
                    ShowMsg(lblMessage, "Session data missing. Please login again.", false);
                    return;
                }

                ViewState["CurrentDate"] = DateTime.Today;
                txtStartDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
                txtEndDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
                LoadSubjectDropdowns();
                BindAll();
            }
        }

        // Populate subject dropdowns from teacher's assigned subjects
        void LoadSubjectDropdowns()
        {
            if (Session["UserId"] == null || Session["InstituteId"] == null)
            {
                ShowMsg(lblMessage, "Cannot load subjects: Session data missing.", false);
                return;
            }

            try
            {
                int teacherUserId = Convert.ToInt32(Session["UserId"]);
                int instituteId = Convert.ToInt32(Session["InstituteId"]);

                DataTable subjects = bl.GetTeacherSubjects(teacherUserId, instituteId);

                // Add dropdown
                ddlSubject.Items.Clear();
                ddlSubject.Items.Add(new ListItem("-- Select Subject --", ""));
                if (subjects != null)
                {
                    foreach (DataRow row in subjects.Rows)
                    {
                        ddlSubject.Items.Add(new ListItem(
                            row["SubjectName"].ToString(),
                            row["SubjectId"].ToString()
                        ));
                    }
                }

                // Edit dropdown
                ddlEditSubject.Items.Clear();
                ddlEditSubject.Items.Add(new ListItem("-- Select Subject --", ""));
                if (subjects != null)
                {
                    foreach (DataRow row in subjects.Rows)
                    {
                        ddlEditSubject.Items.Add(new ListItem(
                            row["SubjectName"].ToString(),
                            row["SubjectId"].ToString()
                        ));
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMsg(lblMessage, $"Error loading subjects: {ex.Message}", false);
            }
        }

        void BindAll()
        {
            try
            {
                if (ViewState["CurrentDate"] == null)
                {
                    ViewState["CurrentDate"] = DateTime.Today;
                }

                DateTime dt = (DateTime)ViewState["CurrentDate"];

                calEvents.VisibleDate = dt;
                lblMonthYear.Text = dt.ToString("MMMM yyyy");
                lblTableMonthYear.Text = dt.ToString("MMMM yyyy");

                if (Session["UserId"] == null || Session["InstituteId"] == null)
                {
                    ShowMsg(lblMessage, "Cannot load events: Session data missing.", false);
                    return;
                }

                int teacherUserId = Convert.ToInt32(Session["UserId"]);
                int instituteId = Convert.ToInt32(Session["InstituteId"]);

                DataTable events = bl.GetEventsByMonthForTeacher(dt.Year, dt.Month, instituteId, teacherUserId);

                if (events != null && events.Rows.Count > 0)
                {
                    gvEvents.DataSource = events;
                    gvEvents.DataBind();
                    lblEventCount.Text = $"({events.Rows.Count} event{(events.Rows.Count != 1 ? "s" : "")})";
                }
                else
                {
                    gvEvents.DataSource = null;
                    gvEvents.DataBind();
                    lblEventCount.Text = "(0 events)";
                }
            }
            catch (Exception ex)
            {
                ShowMsg(lblMessage, $"Error loading events: {ex.Message}", false);
            }
        }

        protected void btnPrev_Click(object sender, EventArgs e)
        {
            if (ViewState["CurrentDate"] != null)
            {
                ViewState["CurrentDate"] = ((DateTime)ViewState["CurrentDate"]).AddMonths(-1);
                hfReopenModal.Value = "";
                BindAll();
            }
        }

        protected void btnNext_Click(object sender, EventArgs e)
        {
            if (ViewState["CurrentDate"] != null)
            {
                ViewState["CurrentDate"] = ((DateTime)ViewState["CurrentDate"]).AddMonths(1);
                hfReopenModal.Value = "";
                BindAll();
            }
        }

        protected void calEvents_DayRender(object sender, DayRenderEventArgs e)
        {
            e.Cell.Controls.Clear();
            e.Cell.Controls.Add(new Literal
            {
                Text = $"<span class='day-number'>{e.Day.DayNumberText}</span>"
            });

            if (Session["UserId"] == null || Session["InstituteId"] == null) return;

            try
            {
                int teacherUserId = Convert.ToInt32(Session["UserId"]);
                int instituteId = Convert.ToInt32(Session["InstituteId"]);

                DataTable dt = bl.GetEventsForTeacher(e.Day.Date, instituteId, teacherUserId);

                if (dt != null && dt.Rows.Count > 0)
                {
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
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error in DayRender: {ex.Message}");
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            hfReopenModal.Value = "addEventModal";
            if (!Page.IsValid) return;

            if (Session["UserId"] == null || Session["InstituteId"] == null || Session["SessionId"] == null)
            {
                ShowMsg(lblMessage, "Session expired. Please login again.", false);
                return;
            }

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

            if (string.IsNullOrEmpty(ddlSubject.SelectedValue))
            {
                ShowMsg(lblMessage, "Please select a subject.", false);
                return;
            }

            try
            {
                CalendarGC obj = new CalendarGC
                {
                    InstituteId = Convert.ToInt32(Session["InstituteId"]),
                    UserId = Convert.ToInt32(Session["UserId"]),
                    SessionId = Convert.ToInt32(Session["SessionId"]),
                    SocietyId = null,
                    SubjectId = Convert.ToInt32(ddlSubject.SelectedValue),
                    Title = txtTitle.Text.Trim(),
                    EventType = ddlEventType.SelectedValue,
                    StartTime = startDate,
                    EndTime = endDate,
                    IsAllDay = chkAllDay.Checked
                };

                bl.AddEvent(obj);

                txtTitle.Text = "";
                txtStartDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
                txtEndDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
                chkAllDay.Checked = false;
                ddlSubject.SelectedIndex = 0;

                ShowMsg(lblMessage, "✅ Event saved successfully!", true);
                ViewState["CurrentDate"] = startDate;
                hfReopenModal.Value = "";
                BindAll();

                ScriptManager.RegisterStartupScript(this, GetType(), "hideModal",
                    "var modal = bootstrap.Modal.getInstance(document.getElementById('addEventModal')); if(modal) modal.hide();", true);
            }
            catch (Exception ex)
            {
                ShowMsg(lblMessage, $"Error saving event: {ex.Message}", false);
            }
        }

        protected void gvEvents_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            try
            {
                int eventId = Convert.ToInt32(e.CommandArgument);
                int instituteId = Convert.ToInt32(Session["InstituteId"]);

                if (e.CommandName == "EditEvent")
                {
                    DateTime groupStart, groupEnd;
                    bl.GetEventGroupRange(eventId, instituteId, out groupStart, out groupEnd);

                    CalendarGC ev = bl.GetEventById(eventId);

                    if (ev != null)
                    {
                        hfEditEventId.Value = eventId.ToString();
                        txtEditTitle.Text = ev.Title;
                        ddlEditEventType.SelectedValue = ev.EventType;
                        txtEditStartDate.Text = groupStart.ToString("yyyy-MM-dd");
                        txtEditEndDate.Text = groupEnd.ToString("yyyy-MM-dd");
                        chkEditAllDay.Checked = ev.IsAllDay;

                        if (ev.SubjectId.HasValue && ev.SubjectId.Value > 0)
                        {
                            if (ddlEditSubject.Items.FindByValue(ev.SubjectId.Value.ToString()) != null)
                            {
                                ddlEditSubject.SelectedValue = ev.SubjectId.Value.ToString();
                            }
                        }
                        else
                        {
                            ddlEditSubject.SelectedIndex = 0;
                        }

                        hfReopenModal.Value = "editEventModal";
                        BindAll();
                    }
                    else
                    {
                        ShowMsg(lblMessage, "Event not found.", false);
                    }
                }
                else if (e.CommandName == "DeleteEvent")
                {
                    bl.DeleteEventGroup(eventId, instituteId);
                    hfReopenModal.Value = "";
                    BindAll();
                    ShowMsg(lblMessage, "Event deleted successfully!", true);
                }
            }
            catch (Exception ex)
            {
                ShowMsg(lblMessage, $"Error: {ex.Message}", false);
            }
        }
        public string GetEventBadgeStyle(string eventType)
        {
            switch (eventType.ToLower())
            {
                case "holiday": return "background:#ffebee;color:#c62828;";
                case "exam": return "background:#fff3e0;color:#ef6c00;";
                case "assignment": return "background:#e3f2fd;color:#1976d2;";
                default: return "background:#e8f5e9;color:#2e7d32;";
            }
        }

        public string GetEventIcon(string eventType)
        {
            switch (eventType.ToLower())
            {
                case "holiday": return "🎉";
                case "exam": return "📝";
                case "assignment": return "📚";
                default: return "📌";
            }
        }
        protected void btnUpdate_Click(object sender, EventArgs e)
        {
            hfReopenModal.Value = "editEventModal";
            if (!Page.IsValid) return;

            if (Session["UserId"] == null || Session["InstituteId"] == null || Session["SessionId"] == null)
            {
                ShowMsg(lblEditMessage, "Session expired. Please login again.", false);
                return;
            }

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

            if (string.IsNullOrEmpty(ddlEditSubject.SelectedValue))
            {
                ShowMsg(lblEditMessage, "Please select a subject.", false);
                return;
            }

            try
            {
                int eventId = Convert.ToInt32(hfEditEventId.Value);
                int instituteId = Convert.ToInt32(Session["InstituteId"]);

                bl.DeleteEventGroup(eventId, instituteId);

                CalendarGC obj = new CalendarGC
                {
                    InstituteId = instituteId,
                    UserId = Convert.ToInt32(Session["UserId"]),
                    SessionId = Convert.ToInt32(Session["SessionId"]),
                    SocietyId = null,
                    SubjectId = Convert.ToInt32(ddlEditSubject.SelectedValue),
                    Title = txtEditTitle.Text.Trim(),
                    EventType = ddlEditEventType.SelectedValue,
                    StartTime = startDate,
                    EndTime = endDate,
                    IsAllDay = chkEditAllDay.Checked
                };

                bl.AddEvent(obj);

                hfReopenModal.Value = "";
                ViewState["CurrentDate"] = startDate;
                BindAll();
                ShowMsg(lblMessage, "✅ Event updated successfully!", true);

                ScriptManager.RegisterStartupScript(this, GetType(), "hideEditModal",
                    "var modal = bootstrap.Modal.getInstance(document.getElementById('editEventModal')); if(modal) modal.hide();", true);
            }
            catch (Exception ex)
            {
                ShowMsg(lblEditMessage, $"Error updating event: {ex.Message}", false);
            }
        }

        void ShowMsg(System.Web.UI.WebControls.Label lbl, string msg, bool success)
        {
            lbl.Text = msg;
            lbl.CssClass = success ? "text-success small" : "text-danger small";
            lbl.Visible = true;
        }
    }
}