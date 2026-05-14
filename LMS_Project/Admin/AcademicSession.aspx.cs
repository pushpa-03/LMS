//using LearningManagementSystem.BL;
//using LearningManagementSystem.GC;
//using System;
//using System.Data;
//using System.Data.SqlClient;
//using System.Web.UI;
//using System.Web.UI.WebControls;

//namespace LearningManagementSystem.Admin
//{
//    public partial class AcademicSession : Page
//    {
//        AcademicSessionBL bl = new AcademicSessionBL();

//        private bool IsSuperAdmin()
//        {
//            return Session["Role"]?.ToString() == "SuperAdmin";
//        }

//        int InstituteId => Convert.ToInt32(Session["InstituteId"]);
//        int SocietyId => Convert.ToInt32(Session["SocietyId"]);

//        protected void Page_Load(object sender, EventArgs e)
//        {
//            if (Session["InstituteId"] == null)
//            {
//                Response.Redirect("~/Default.aspx");
//                return;
//            }

//            if (!IsPostBack)
//                LoadSessions();
//        }

//        private void LoadSessions()
//        {
//            DataTable dt = bl.GetSessionsByInstitute(InstituteId);

//            gvSessions.DataSource = dt;
//            gvSessions.DataBind();

//            lblTotal.Text = dt.Rows.Count.ToString();
//            lblCurrent.Text = dt.Select("IsCurrent = true").Length.ToString();
//            lblPast.Text = dt.Select("IsCurrent = false").Length.ToString();
//        }

//        // ================= SAVE =================
//        protected void btnSave_Click(object sender, EventArgs e)
//        {
//            if (IsSuperAdmin())
//            {
//                ShowToast("warning", "You have view-only access.");
//                return;
//            }

//            try
//            {
//                if (string.IsNullOrWhiteSpace(txtSessionName.Text))
//                {
//                    ShowToast("warning", "Session name required");
//                    return;
//                }

//                AcademicSessionGC obj = new AcademicSessionGC
//                {
//                    SessionId = string.IsNullOrEmpty(hfSessionId.Value) ? 0 : Convert.ToInt32(hfSessionId.Value),
//                    SocietyId = SocietyId,
//                    InstituteId = InstituteId,
//                    SessionName = txtSessionName.Text.Trim(),
//                    StartDate = Convert.ToDateTime(txtStartDate.Text),
//                    EndDate = Convert.ToDateTime(txtEndDate.Text),
//                    IsCurrent = chkCurrent.Checked
//                };

//                if (obj.EndDate <= obj.StartDate)
//                {
//                    ShowToast("warning", "End date must be greater than start date");
//                    return;
//                }

//                // ✅ SAFER LOGIC
//                if (obj.SessionId > 0)
//                {
//                    bl.UpdateSession(obj);
//                    ShowToast("success", "Session updated successfully");
//                }
//                else
//                {
//                    bl.InsertSession(obj);
//                    ShowToast("success", "Session created successfully");
//                }

//                Clear();
//                LoadSessions();
//            }
//            catch (Exception ex)
//            {
//                if (ex.Message.Contains("UQ_Session"))
//                    ShowToast("error", "Session already exists!");
//                else
//                    ShowToast("error", "Something went wrong");
//            }
//        }

//        // ================= GRID ACTIONS =================
//        protected void gvSessions_RowCommand(object sender, GridViewCommandEventArgs e)
//        {
//            int id = Convert.ToInt32(e.CommandArgument);

//            try
//            {
//                // ================= EDIT =================
//                if (e.CommandName == "EditRow")
//                {
//                    DataTable dt = bl.GetById(id, InstituteId);

//                    if (dt.Rows.Count > 0)
//                    {
//                        hfSessionId.Value = id.ToString();

//                        txtSessionName.Text = dt.Rows[0]["SessionName"].ToString();
//                        txtStartDate.Text = Convert.ToDateTime(dt.Rows[0]["StartDate"]).ToString("yyyy-MM-dd");
//                        txtEndDate.Text = Convert.ToDateTime(dt.Rows[0]["EndDate"]).ToString("yyyy-MM-dd");
//                        chkCurrent.Checked = Convert.ToBoolean(dt.Rows[0]["IsCurrent"]);

//                        ScriptManager.RegisterStartupScript(this, GetType(),
//                        "modal", @"
//                        document.querySelector('#SessionModal h5').innerText = 'Edit Session';
//                        new bootstrap.Modal(document.getElementById('SessionModal')).show();", true);
//                    }
//                }

//                // ================= SET CURRENT =================
//                else if (e.CommandName == "SetCurrent")
//                {
//                    if (IsSuperAdmin())
//                    {
//                        ShowToast("warning", "You have view-only access.");
//                        return;
//                    }

//                    bl.SetCurrentSession(id, InstituteId);
//                    LoadSessions();
//                    ShowToast("success", "Session set as current");
//                }

//                // ================= DELETE =================
//                else if (e.CommandName == "DeleteRow")
//                {
//                    if (IsSuperAdmin())
//                    {
//                        ShowToast("warning", "You have view-only access.");
//                        return;
//                    }

//                    // 🔍 PRE-CHECK
//                    if (bl.IsSessionInUse(id, InstituteId))
//                    {
//                        ShowToast("warning", "This session is used in other modules. Please deactivate it instead.");
//                        return;
//                    }

//                    bl.Delete(id, InstituteId);
//                    LoadSessions();

//                    ShowToast("success", "Session deleted successfully");
//                }
//            }
//            catch (SqlException ex)
//            {
//                if (ex.Number == 547)
//                    ShowToast("error", "This session is used in other modules. You can deactivate it instead.");
//                else
//                    ShowToast("error", "Database error occurred");
//            }
//            catch
//            {
//                ShowToast("error", "Something went wrong");
//            }
//        }

//        // ================= ROW DATABOUND =================
//        protected void gvSessions_RowDataBound(object sender, GridViewRowEventArgs e)
//        {
//            if (IsSuperAdmin() && e.Row.RowType == DataControlRowType.DataRow)
//            {
//                foreach (TableCell cell in e.Row.Cells)
//                {
//                    foreach (Control ctrl in cell.Controls)
//                    {
//                        if (ctrl is LinkButton btn)
//                        {
//                            btn.Enabled = false;
//                            btn.CssClass += " disabled opacity-50";
//                        }
//                    }
//                }
//            }
//        }

//        // ================= CLEAR =================
//        private void Clear()
//        {
//            hfSessionId.Value = "";
//            txtSessionName.Text = "";
//            txtStartDate.Text = "";
//            txtEndDate.Text = "";
//            chkCurrent.Checked = false;

//            ScriptManager.RegisterStartupScript(this, GetType(),
//            "resetTitle",
//            "document.querySelector('#SessionModal h5').innerText = 'Academic Session';", true);
//        }

//        // ================= TOAST =================
//        private void ShowToast(string type, string msg)
//        {
//            msg = msg.Replace("'", "\\'"); // ✅ prevent JS break

//            string script = $@"
//                var t = document.getElementById('liveToast');
//                var m = document.getElementById('toastMsg');

//                m.innerText = '{msg}';
//                t.classList.remove('bg-success','bg-danger','bg-warning','bg-info');

//                let bg = {{
//                    success: 'bg-success',
//                    error: 'bg-danger',
//                    warning: 'bg-warning text-dark',
//                    info: 'bg-info'
//                }}['{type}'];

//                t.classList.add(bg);

//                new bootstrap.Toast(t).show();
//            ";

//            ScriptManager.RegisterStartupScript(this, GetType(), "toast", script, true);
//        }
//    }
//}

//----------------------------------------------------------------------------------------------------------------------

using LearningManagementSystem.BL;
using LearningManagementSystem.GC;
using Newtonsoft.Json;
using System;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace LearningManagementSystem.Admin
{
    public partial class AcademicSession : BasePage
    {
        private readonly AcademicSessionBL _bl = new AcademicSessionBL();

        private bool IsSuperAdmin =>
            Session["Role"]?.ToString() == "SuperAdmin";

      
        // ══════════════════════════════════════════════════════════════════════
        //  PAGE LOAD
        // ══════════════════════════════════════════════════════════════════════
        protected void Page_Load(object sender, EventArgs e)
        {
           

            if (!IsPostBack)
            {
                LoadSessions();
                LoadDeadlineAlerts();
                LoadSessionDropdowns();
                ConfigureNewSessionButton();
            }
        }

        // ── Load GridView ─────────────────────────────────────────────────────
        private void LoadSessions()
        {
            try
            {
                DataTable dt = _bl.GetSessionsByInstitute(InstituteId);
                gvSessions.DataSource = dt;
                gvSessions.DataBind();

                lblTotal.Text = dt.Rows.Count.ToString();
                lblCurrent.Text = dt.Select("IsCurrent = true").Length.ToString();
                lblPast.Text = dt.Select("IsCurrent = false").Length.ToString();

                // Count sessions ending within 30 days
                int endingSoon = 0;
                DateTime now = DateTime.Today;
                foreach (DataRow row in dt.Rows)
                {
                    if (!Convert.ToBoolean(row["IsCurrent"])) continue;
                    int days = (Convert.ToDateTime(row["EndDate"]) - now).Days;
                    if (days >= 0 && days <= 30) endingSoon++;
                }
                lblEnding.Text = endingSoon.ToString();
            }
            catch (Exception ex)
            {
                SetToast("err", "Error loading sessions: " + ex.Message);
            }
        }

        // ── Deadline alert banners ────────────────────────────────────────────
        private void LoadDeadlineAlerts()
        {
            try
            {
                DataTable dt = _bl.GetSessionsByInstitute(InstituteId);
                DateTime now = DateTime.Today;
                string alerts = "";

                foreach (DataRow row in dt.Rows)
                {
                    if (!Convert.ToBoolean(row["IsCurrent"])) continue;

                    DateTime end = Convert.ToDateTime(row["EndDate"]);
                    int days = (end - now).Days;
                    string name = row["SessionName"].ToString();

                    if (days < 0)
                        alerts += Alert("danger", "fa-exclamation-circle",
                            "Session Overdue!",
                            $"Current session <strong>{name}</strong> ended {Math.Abs(days)} day(s) ago. Please start a new session immediately.");
                    else if (days <= 14)
                        alerts += Alert("danger", "fa-exclamation-triangle",
                            $"Urgent: Ending in {days} day(s)!",
                            $"<strong>{name}</strong> ends on {end:dd MMM yyyy}. Start the new session immediately.");
                    else if (days <= 30)
                        alerts += Alert("warn", "fa-clock",
                            $"Session ending in {days} days",
                            $"<strong>{name}</strong> ends on {end:dd MMM yyyy}. Prepare and start the new session.");
                    else if (days <= 60)
                        alerts += Alert("info", "fa-info-circle",
                            $"Session ends in {days} days",
                            $"<strong>{name}</strong> ends on {end:dd MMM yyyy}. You can create the next session anytime.");
                }

                phAlerts.Controls.Add(new LiteralControl(alerts));
            }
            catch { /* Non-critical */ }
        }

        private static string Alert(string type, string icon, string title, string body) =>
            $@"<div class='deadline-alert {type}'>
                <i class='fa {icon}'></i>
                <div><div class='al-title'>{title}</div>{body}</div>
               </div>";

        // ── Load Copy-From / Copy-To dropdowns ────────────────────────────────
        private void LoadSessionDropdowns()
        {
            try
            {
                DataTable dt = _bl.GetSessionsByInstitute(InstituteId);

                ddlCopyFrom.Items.Clear();
                ddlCopyTo.Items.Clear();
                ddlCopyFrom.Items.Add(new ListItem("-- Select source session --", ""));
                ddlCopyTo.Items.Add(new ListItem("-- Select target (new) session --", ""));

                foreach (DataRow row in dt.Rows)
                {
                    string sid = row["SessionId"].ToString();
                    string name = row["SessionName"].ToString();
                    bool current = Convert.ToBoolean(row["IsCurrent"]);

                    ddlCopyFrom.Items.Add(new ListItem(name + (current ? " ★ Current" : ""), sid));
                    ddlCopyTo.Items.Add(new ListItem(name, sid));
                }

                // Pre-select current session as source
                foreach (ListItem item in ddlCopyFrom.Items)
                {
                    if (item.Text.Contains("★ Current")) { item.Selected = true; break; }
                }
            }
            catch { /* Non-critical */ }
        }

        // ── Enable / disable "Start New Session" button ───────────────────────
        // Rules:
        //   • Must have at least 1 current session
        //   • Must have at least 2 sessions total (one to copy from, one to copy to)
        //   • SuperAdmin cannot use it
        private void ConfigureNewSessionButton()
        {
            try
            {
                DataTable dt = _bl.GetSessionsByInstitute(InstituteId);
                bool hasCurrent = dt.Select("IsCurrent = true").Length > 0;
                bool hasMultiple = dt.Rows.Count >= 2;
                bool enabled = hasCurrent && hasMultiple && !IsSuperAdmin;

                btnStartNewSession.Enabled = enabled;

                if (!enabled)
                    btnStartNewSession.ToolTip = IsSuperAdmin
                        ? "SuperAdmin has view-only access."
                        : !hasCurrent
                            ? "Set a session as current first, then use this button."
                            : "Create a new session first using 'Add Session', then use this button.";
            }
            catch { }
        }

        // ══════════════════════════════════════════════════════════════════════
        //  ADD / EDIT — btnSave_Click
        // ══════════════════════════════════════════════════════════════════════
        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (IsSuperAdmin) { SetToast("warn", "SuperAdmin has view-only access."); return; }

            try
            {
                // ── Server-side validation ──
                string name = txtSessionName.Text.Trim();

                if (string.IsNullOrEmpty(name))
                { SetToast("warn", "Academic year name is required."); ReOpenAddModal(); return; }

                if (!System.Text.RegularExpressions.Regex.IsMatch(name, @"^\d{4}-\d{4}$"))
                { SetToast("warn", "Format must be YYYY-YYYY (e.g. 2025-2026)."); ReOpenAddModal(); return; }

                // Validate year range is +1
                string[] parts = name.Split('-');
                if (int.Parse(parts[1]) != int.Parse(parts[0]) + 1)
                { SetToast("warn", "End year must be start year + 1 (e.g. 2025-2026)."); ReOpenAddModal(); return; }

                if (string.IsNullOrEmpty(txtStartDate.Text))
                { SetToast("warn", "Start date is required."); ReOpenAddModal(); return; }

                if (string.IsNullOrEmpty(txtEndDate.Text))
                { SetToast("warn", "End date is required."); ReOpenAddModal(); return; }

                DateTime start = Convert.ToDateTime(txtStartDate.Text);
                DateTime end = Convert.ToDateTime(txtEndDate.Text);

                if (end <= start)
                { SetToast("warn", "End date must be after start date."); ReOpenAddModal(); return; }

                if ((end - start).Days < 180)
                { SetToast("warn", "Session duration must be at least 6 months."); ReOpenAddModal(); return; }

                int sessionId = string.IsNullOrEmpty(hfSessionId.Value)
                    ? 0 : Convert.ToInt32(hfSessionId.Value);

                // Duplicate name check
                if (_bl.IsSessionNameExists(InstituteId, name, sessionId))
                { SetToast("warn", $"Session '{name}' already exists for this institute."); ReOpenAddModal(); return; }

                var obj = new AcademicSessionGC
                {
                    SessionId = sessionId,
                    SocietyId = SocietyId,
                    InstituteId = InstituteId,
                    SessionName = name,
                    StartDate = start,
                    EndDate = end,
                    IsCurrent = chkCurrent.Checked
                };

                if (obj.SessionId > 0)
                {
                    _bl.UpdateSession(obj);
                    SetToast("ok", $"Session '{name}' updated successfully.");
                }
                else
                {
                    _bl.InsertSession(obj);
                    SetToast("ok", $"Session '{name}' created! Use 'Start New Session' to copy data from previous session.");
                }

                ClearForm();
                LoadSessions();
                LoadSessionDropdowns();
                ConfigureNewSessionButton();

                // Close modal after successful save
                ScriptManager.RegisterStartupScript(this, GetType(), "closeAdd",
                    "closeModal('addModal');", true);
            }
            catch (Exception ex)
            {
                string msg = ex.Message.Contains("UQ_Session")
                    ? "This session name already exists."
                    : "Error: " + ex.Message;
                SetToast("err", msg);
                ReOpenAddModal();
            }
        }

        // ══════════════════════════════════════════════════════════════════════
        //  START NEW SESSION — button click (JS opens modal, this is fallback)
        // ══════════════════════════════════════════════════════════════════════
        protected void btnStartNewSession_Click(object sender, EventArgs e)
        {
            // JS confirmNewSession() returns false so this normally
            // doesn't fire. This is a safety fallback.
            ScriptManager.RegisterStartupScript(this, GetType(), "openNS",
                "openModal('newSessionModal');", true);
        }

        // ══════════════════════════════════════════════════════════════════════
        //  EXECUTE NEW SESSION — copies data via stored procedure
        // ══════════════════════════════════════════════════════════════════════
        protected void btnExecuteNewSession_Click(object sender, EventArgs e)
        {
            if (IsSuperAdmin) { SetToast("warn", "SuperAdmin has view-only access."); return; }

            try
            {
                // Validate
                if (string.IsNullOrEmpty(ddlCopyFrom.SelectedValue))
                { SetToast("warn", "Please select the source session to copy from."); return; }

                if (string.IsNullOrEmpty(ddlCopyTo.SelectedValue))
                { SetToast("warn", "Please select the target new session."); return; }

                int fromId = Convert.ToInt32(ddlCopyFrom.SelectedValue);
                int toId = Convert.ToInt32(ddlCopyTo.SelectedValue);

                if (fromId == toId)
                { SetToast("warn", "Source and target sessions must be different."); return; }

                // Warn if target already has data (but allow it — SP deduplicates)
                bool hasData = _bl.SessionHasData(toId, InstituteId);

                // Execute the stored procedure
                _bl.StartNewSession(fromId, toId, InstituteId, SocietyId);

                // Set as current if toggled
                if (chkSetAsCurrent.Checked)
                {
                    _bl.SetCurrentSession(toId, InstituteId);

                    // Update server session variables so the header reflects it
                    Session["CurrentSessionId"] = toId;
                    DataTable dtSess = _bl.GetById(toId, InstituteId);
                    if (dtSess != null && dtSess.Rows.Count > 0)
                        Session["SessionName"] = dtSess.Rows[0]["SessionName"].ToString();
                }

                string fromName = ddlCopyFrom.SelectedItem?.Text ?? fromId.ToString();
                string toName = ddlCopyTo.SelectedItem?.Text ?? toId.ToString();
                string extraMsg = hasData ? " (duplicate items were skipped)" : "";

                SetToast("ok",
                    $"New session started! Data copied from '{fromName}' → '{toName}'{extraMsg}.");

                LoadSessions();
                LoadSessionDropdowns();
                LoadDeadlineAlerts();
                ConfigureNewSessionButton();

                ScriptManager.RegisterStartupScript(this, GetType(), "closeNS",
                    "closeModal('newSessionModal');", true);
            }
            catch (Exception ex)
            {
                // If the stored procedure doesn't exist yet
                if (ex.Message.Contains("sp_StartNewSession") || ex.Message.Contains("Could not find"))
                {
                    SetToast("err",
                        "Stored procedure 'sp_StartNewSession' not found. " +
                        "Please run SessionManagement.sql in your database first.");
                }
                else
                {
                    SetToast("err", "Failed to start new session: " + ex.Message);
                }
            }
        }

        // ══════════════════════════════════════════════════════════════════════
        //  GRID ROW COMMANDS
        // ══════════════════════════════════════════════════════════════════════
        protected void gvSessions_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (!int.TryParse(e.CommandArgument?.ToString(), out int id)) return;

            try
            {
                // ── EDIT ──────────────────────────────────────────────────────
                if (e.CommandName == "EditRow")
                {
                    DataTable dt = _bl.GetById(id, InstituteId);
                    if (dt == null || dt.Rows.Count == 0)
                    { SetToast("warn", "Session not found."); return; }

                    DataRow r = dt.Rows[0];
                    hfSessionId.Value = id.ToString();
                    txtSessionName.Text = r["SessionName"].ToString();
                    txtStartDate.Text = Convert.ToDateTime(r["StartDate"]).ToString("yyyy-MM-dd");
                    txtEndDate.Text = Convert.ToDateTime(r["EndDate"]).ToString("yyyy-MM-dd");
                    chkCurrent.Checked = Convert.ToBoolean(r["IsCurrent"]);

                    ScriptManager.RegisterStartupScript(this, GetType(), "openEdit", @"
                        document.getElementById('addModalTitle').innerHTML =
                            '<i class=""fa fa-pencil me-2""></i>Edit Academic Session';
                        openModal('addModal');", true);
                }

                // ── SET CURRENT ────────────────────────────────────────────────
                else if (e.CommandName == "SetCurrent")
                {
                    if (IsSuperAdmin) { SetToast("warn", "View-only access."); return; }

                    DataTable dt = _bl.GetById(id, InstituteId);
                    string name = dt != null && dt.Rows.Count > 0
                        ? dt.Rows[0]["SessionName"].ToString() : id.ToString();

                    _bl.SetCurrentSession(id, InstituteId);

                    // Update server session variables
                    Session["CurrentSessionId"] = id;
                    Session["SessionName"] = name;

                    LoadSessions();
                    ConfigureNewSessionButton();
                    SetToast("ok", $"'{name}' is now the active session.");
                }

                // ── VIEW ANALYSIS ──────────────────────────────────────────────
                else if (e.CommandName == "ViewAnalysis")
                {
                    ScriptManager.RegisterStartupScript(this, GetType(), "anal",
                        $"showAnalysis({id});", true);
                }

                // ── DELETE ─────────────────────────────────────────────────────
                else if (e.CommandName == "DeleteRow")
                {
                    if (IsSuperAdmin) { SetToast("warn", "View-only access."); return; }

                    // Block delete of current session
                    DataTable dt = _bl.GetById(id, InstituteId);
                    if (dt != null && dt.Rows.Count > 0
                        && Convert.ToBoolean(dt.Rows[0]["IsCurrent"]))
                    {
                        SetToast("warn",
                            "Cannot delete the active session. Set another session as current first.");
                        return;
                    }

                    // Block delete if data exists
                    if (_bl.IsSessionInUse(id, InstituteId))
                    {
                        SetToast("warn",
                            "This session has related data (students, videos, attendance etc.) " +
                            "and cannot be deleted. Past sessions are kept for historical analysis.");
                        return;
                    }

                    string sname = dt != null && dt.Rows.Count > 0
                        ? dt.Rows[0]["SessionName"].ToString() : "";

                    _bl.Delete(id, InstituteId);
                    LoadSessions();
                    LoadSessionDropdowns();
                    ConfigureNewSessionButton();
                    SetToast("ok", $"Session '{sname}' deleted.");
                }
            }
            catch (SqlException ex)
            {
                SetToast("err", ex.Number == 547
                    ? "This session has linked data and cannot be deleted."
                    : "Database error: " + ex.Message);
            }
            catch (Exception ex)
            {
                SetToast("err", ex.Message == "SESSION_IN_USE"
                    ? "Session has related data and cannot be deleted."
                    : "Error: " + ex.Message);
            }
        }

        // ── GridView RowDataBound ─────────────────────────────────────────────
        protected void gvSessions_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType != DataControlRowType.DataRow) return;

            if (e.Row.DataItem is DataRowView drv)
            {
                // Highlight current session row green
                if (Convert.ToBoolean(drv["IsCurrent"]))
                    e.Row.CssClass += " is-current";

                // Disable all buttons for SuperAdmin
                if (IsSuperAdmin)
                {
                    foreach (TableCell cell in e.Row.Cells)
                        foreach (Control ctrl in cell.Controls)
                            if (ctrl is LinkButton btn)
                            { btn.Enabled = false; btn.CssClass += " disabled"; }
                }
            }
        }

        // ══════════════════════════════════════════════════════════════════════
        //  AJAX WEBMETHOD — session summary counts for analysis panel
        // ══════════════════════════════════════════════════════════════════════
        [WebMethod(EnableSession = true)]
        public static string GetSessionSummary(int sessionId)
        {
            try
            {
                var ctx = HttpContext.Current;
                int instituteId = ctx.Session["InstituteId"] != null
                    ? Convert.ToInt32(ctx.Session["InstituteId"]) : 0;

                DataTable dt = new AcademicSessionBL().GetSessionSummary(sessionId, instituteId);

                if (dt == null || dt.Rows.Count == 0)
                    return JsonConvert.SerializeObject(
                        new { Streams = 0, Courses = 0, Subjects = 0, Students = 0, Videos = 0, Attendance = 0 });

                DataRow r = dt.Rows[0];
                return JsonConvert.SerializeObject(new
                {
                    Streams = r["Streams"],
                    Courses = r["Courses"],
                    Subjects = r["Subjects"],
                    Students = r["Students"],
                    Videos = r["Videos"],
                    Attendance = r["Attendance"]
                });
            }
            catch (Exception ex)
            {
                return JsonConvert.SerializeObject(new { error = ex.Message });
            }
        }

        // ── Helper: clear add/edit form ───────────────────────────────────────
        private void ClearForm()
        {
            hfSessionId.Value = "";
            txtSessionName.Text = "";
            txtStartDate.Text = "";
            txtEndDate.Text = "";
            chkCurrent.Checked = false;
        }

        // ── Helper: re-open add modal after validation failure ─────────────────
        private void ReOpenAddModal()
        {
            ScriptManager.RegisterStartupScript(this, GetType(), "reOpenAdd",
                "openModal('addModal');", true);
        }

        // ── Helper: set toast via hidden fields ───────────────────────────────
        private void SetToast(string type, string msg)
        {
            hfToastMsg.Value = msg.Replace("'", "\\'").Replace("\"", "&quot;");
            hfToastType.Value = type;
        }
    }
}