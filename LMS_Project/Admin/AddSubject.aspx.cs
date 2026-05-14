//using LearningManagementSystem.BL;
//using LearningManagementSystem.GC;
//using System;
//using System.Data;
//using System.Web.UI;
//using System.Web.UI.WebControls;

//namespace LearningManagementSystem.Admin
//{
//    public partial class AddSubject : BasePage
//    {
//        AddSubjectBL bl = new AddSubjectBL();

//        private bool IsSuperAdmin()
//        {
//            return Session["Role"]?.ToString() == "SuperAdmin";
//        }

//        protected void Page_Load(object sender, EventArgs e)
//        {
//            if (!IsPostBack)
//                BindGrid();
//        }


//        private void BindGrid()
//        {

//            string status = ViewStateStatus;
//            string search = txtSearch?.Text?.Trim() ?? "";

//            DataTable dt = bl.GetSubjects(InstituteId, SessionId, status, search);

//            if (SessionId == 0)


//            {
//                gvSubjects.DataSource = null;
//                gvSubjects.DataBind();
//                return;
//            }

//            gvSubjects.DataSource = dt;
//            gvSubjects.DataBind();

//            lblTotal.Text = dt.Rows.Count.ToString();
//            lblActive.Text = dt.Select("IsActive = 1").Length.ToString();
//            lblInactive.Text = dt.Select("IsActive = 0").Length.ToString();
//        }

//        protected void btnSave_Click(object sender, EventArgs e)
//        {
//            if (IsSuperAdmin())
//            {
//                ShowToast("Access Denied: View only mode", false);
//                return;
//            }

//            try
//            {
//                if (SessionId == 0)
//                {
//                    ShowToast("No active session!", false);
//                    return;
//                }

//                // VALIDATION (SERVER SIDE)
//                if (!System.Text.RegularExpressions.Regex.IsMatch(txtSubjectCode.Text, @"^[A-Za-z0-9]+$"))
//                {
//                    ShowToast("Invalid Subject Code", false);
//                    return;
//                }

//                AddSubjectGC obj = new AddSubjectGC
//                {
//                    SubjectId = string.IsNullOrEmpty(hfSubjectId.Value) ? 0 : Convert.ToInt32(hfSubjectId.Value),
//                    SocietyId = SocietyId,
//                    InstituteId = InstituteId,
//                    SessionId = SessionId,
//                    SubjectCode = txtSubjectCode.Text.Trim(),
//                    SubjectName = txtSubjectName.Text.Trim(),
//                    Description = txtDescription.Text.Trim(),
//                    Duration = txtDuration.Text.Trim()
//                };

//                if (obj.SubjectId == 0)
//                {
//                    bl.Insert(obj);
//                    LogActivity(UserId, SocietyId, InstituteId, SessionId, "Add Subject", 0);
//                    ShowToast("Subject Added", true);
//                }
//                else
//                {
//                    bl.Update(obj);
//                    LogActivity(UserId, SocietyId, InstituteId, SessionId, "Update Subject", obj.SubjectId);
//                    ShowToast("Subject Updated", true);
//                }

//                BindGrid();
//                Clear();
//            }
//            catch (Exception ex)
//            {
//                ShowToast("Error: " + ex.Message, false);
//            }
//        }

//        protected void gvSubjects_RowCommand(object sender, GridViewCommandEventArgs e)
//        {
//            if (IsSuperAdmin())
//            {
//                ShowToast("Access Denied: View only mode", false);
//                return;
//            }

//            int id;
//            if (!int.TryParse(e.CommandArgument?.ToString(), out id))
//                return;

//            try
//            {
//                if (e.CommandName == "EditRow")
//                {
//                    hfSubjectId.Value = id.ToString();

//                    DataTable dt = bl.GetById(id, SessionId);

//                    if (dt.Rows.Count > 0)
//                    {
//                        var dr = dt.Rows[0];

//                        txtSubjectCode.Text = dr["SubjectCode"].ToString();
//                        txtSubjectName.Text = dr["SubjectName"].ToString();
//                        txtDescription.Text = dr["Description"].ToString();
//                        txtDuration.Text = dr["Duration"].ToString();

//                        ScriptManager.RegisterStartupScript(this, GetType(), "open", "openModal();", true);
//                    }
//                }
//                else if (e.CommandName == "Toggle")
//                {
//                    bl.Toggle(id, SessionId);
//                    LogActivity(UserId, SocietyId, InstituteId, SessionId, "Toggle Subject", id);
//                    ShowToast("Status updated", true);
//                }
//                else if (e.CommandName == "DeleteRow")
//                {
//                    bl.Delete(id, SessionId);
//                    LogActivity(UserId, SocietyId, InstituteId, SessionId, "Delete Subject", id);
//                    ShowToast("Deleted successfully", true);
//                }

//                BindGrid();
//            }
//            catch (Exception ex)
//            {
//                if (ex.Message.Contains("REFERENCE"))
//                    ShowToast("This subject is used elsewhere. Deactivate instead.", false);
//                else
//                    ShowToast("Error occurred", false);
//            }
//        }

//        protected void btnUpdate_Click(object sender, EventArgs e)
//        {
//            AddSubjectGC obj = new AddSubjectGC
//            {
//                SubjectId = Convert.ToInt32(hfSubjectId.Value),

//                SocietyId = SocietyId,
//                InstituteId = InstituteId,

//                SubjectCode = txtSubjectCode.Text.Trim(),
//                SubjectName = txtSubjectName.Text.Trim(),
//                Duration = txtDuration.Text.Trim(),
//                Description = txtDescription.Text.Trim()
//            };

//            bl.Update(obj);

//            BindGrid();
//        }

//        protected void btnFilter_Click(object sender, EventArgs e)
//        {
//            BindGrid();
//        }

//        protected void FilterStatus_Click(object sender, EventArgs e)
//        {
//            string status = ((LinkButton)sender).CommandArgument;

//            BindGrid();
//        }
//        private void ShowToast(string msg, bool success)
//        {
//            string script = $@"
//                var t = document.getElementById('liveToast');
//                var m = document.getElementById('toastMsg');

//                m.innerText = '{msg}';
//                t.classList.remove('bg-success','bg-danger');
//                t.classList.add('{(success ? "bg-success" : "bg-danger")}');

//                new bootstrap.Toast(t).show();
//            ";

//            ScriptManager.RegisterStartupScript(this, GetType(), "toast", script, true);
//        }

//        private void Clear()
//        {
//            hfSubjectId.Value = "";
//            txtSubjectCode.Text = "";
//            txtSubjectName.Text = "";
//            txtDescription.Text = "";
//            txtDuration.Text = "";
//        }

//        string ViewStateStatus
//        {
//            get => ViewState["Status"]?.ToString() ?? "1"; // default Active
//            set => ViewState["Status"] = value;
//        }

//        protected void btnToggleView_Click(object sender, EventArgs e)
//        {
//            if (ViewStateStatus == "1")
//            {
//                ViewStateStatus = "0";
//                btnToggleView.Text = "Show Active";
//            }
//            else
//            {
//                ViewStateStatus = "1";
//                btnToggleView.Text = "Show Inactive";
//            }

//            BindGrid();
//        }
//    }
//}


//-------------------------------------------------------------------------------------------------------------------------

using LearningManagementSystem.BL;
using LearningManagementSystem.GC;
using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace LearningManagementSystem.Admin
{
    public partial class AddSubject : BasePage
    {
        // ─── Business-Logic Layer ──────────────────────────────────────────────────
        private readonly AddSubjectBL _bl = new AddSubjectBL();

        // ─── Role Check ────────────────────────────────────────────────────────────
        private bool IsSuperAdmin =>
            Session["Role"]?.ToString().Equals("SuperAdmin", StringComparison.OrdinalIgnoreCase) == true;

        // ─── Page Load ─────────────────────────────────────────────────────────────
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                ConfigureRoleUI();
                BindGrid();
            }
        }

        // ─── Role-based UI Configuration ───────────────────────────────────────────
        private void ConfigureRoleUI()
        {
            hfIsSuperAdmin.Value = IsSuperAdmin ? "true" : "false";

            if (IsSuperAdmin)
            {
                // Show the "View Only" badge
                lblSuperAdminBadge.Visible = true;

                // Hide the Add button panel
                pnlAddBtn.Visible = false;

                // Hide the toggle button (still functional on postback but no UI change needed)
                // Keep btnToggleView visible so they can still switch views
            }
        }

        // ─── Bind GridView ─────────────────────────────────────────────────────────
        private void BindGrid()
        {
            // Guard: no session → clear grid
            if (SessionId == 0)
            {
                gvSubjects.DataSource = null;
                gvSubjects.DataBind();
                UpdateStats(null);
                ShowToast("No active academic session found. Please configure a session.", "warning");
                return;
            }

            string status = ViewStateStatus;
            string search = txtSearch?.Text?.Trim() ?? string.Empty;

            DataTable dt = _bl.GetSubjects(InstituteId, SessionId, status, search);

            gvSubjects.DataSource = dt;
            gvSubjects.DataBind();

            UpdateStats(dt);

            // Sync toggle button label
            btnToggleView.Text = status == "1"
                ? "<i class='fa fa-eye me-1'></i>Show Inactive"
                : "<i class='fa fa-eye-slash me-1'></i>Show Active";
        }

        // ─── Update Stats Labels ────────────────────────────────────────────────────
        private void UpdateStats(DataTable dt)
        {
            if (dt == null || dt.Rows.Count == 0)
            {
                lblTotal.Text = "0";
                lblActive.Text = "0";
                lblInactive.Text = "0";
                return;
            }

            lblTotal.Text = dt.Rows.Count.ToString();
            lblActive.Text = dt.Select("IsActive = 1").Length.ToString();
            lblInactive.Text = dt.Select("IsActive = 0").Length.ToString();
        }

        // ─── Save (Insert / Update) ────────────────────────────────────────────────
        protected void btnSave_Click(object sender, EventArgs e)
        {
            // 1. SuperAdmin guard
            if (IsSuperAdmin)
            {
                ShowToast("Access Denied: SuperAdmin has view-only access and cannot perform CRUD operations.", "warning");
                return;
            }

            // 2. Session guard
            if (SessionId == 0)
            {
                ShowToast("No active academic session found. Please configure an academic session first.", "warning");
                return;
            }

            // 3. Server-side validation
            string code = txtSubjectCode.Text.Trim();
            string name = txtSubjectName.Text.Trim();
            string durVal = txtDurationValue.Text.Trim();
            string durUnit = ddlDurationUnit.SelectedValue;

            if (string.IsNullOrWhiteSpace(code))
            {
                ShowToast("Subject Code is required.", "danger");
                ReopenModal();
                return;
            }

            // Code: alphanumeric only
            if (!System.Text.RegularExpressions.Regex.IsMatch(code, @"^[a-zA-Z0-9]+$"))
            {
                ShowToast("Subject Code must contain only letters and numbers (no special characters).", "danger");
                ReopenModal();
                return;
            }

            if (string.IsNullOrWhiteSpace(name) || name.Length < 3)
            {
                ShowToast("Subject Name must be at least 3 characters.", "danger");
                ReopenModal();
                return;
            }

            // Duration: if provided, must be a positive integer
            string durationFull = string.Empty;
            if (!string.IsNullOrWhiteSpace(durVal))
            {
                if (!int.TryParse(durVal, out int durInt) || durInt <= 0)
                {
                    ShowToast("Duration must be a positive number.", "danger");
                    ReopenModal();
                    return;
                }
                durationFull = $"{durInt} {durUnit}"; // e.g. "45 mins"
            }

            try
            {
                int subjectId = string.IsNullOrEmpty(hfSubjectId.Value)
                    ? 0
                    : Convert.ToInt32(hfSubjectId.Value);

                bool isInsert = subjectId == 0;

                // Check for duplicate code in same session (server-side)
                bool isDuplicate = _bl.IsCodeDuplicate(InstituteId, SessionId, code, subjectId);
                if (isDuplicate)
                {
                    ShowToast($"Subject Code '{code}' already exists in this session. Please use a unique code.", "danger");
                    ReopenModal();
                    return;
                }

                var obj = new AddSubjectGC
                {
                    SubjectId = subjectId,
                    SocietyId = SocietyId,
                    InstituteId = InstituteId,
                    SessionId = SessionId,
                    SubjectCode = code,
                    SubjectName = name,
                    Description = txtDescription.Text.Trim(),
                    Duration = durationFull,
                    IsActive = chkActive.Checked
                };

                if (isInsert)
                {
                    _bl.Insert(obj);
                    LogActivity(UserId, SocietyId, InstituteId, SessionId,
                        $"INSERT_SUBJECT: Code={code}, Name={name}", 0);
                    ShowToast($"Subject '{name}' added successfully.", "success");
                }
                else
                {
                    _bl.Update(obj);
                    LogActivity(UserId, SocietyId, InstituteId, SessionId,
                        $"UPDATE_SUBJECT: Id={subjectId}, Code={code}, Name={name}", subjectId);
                    ShowToast($"Subject '{name}' updated successfully.", "success");
                }

                Clear();
                BindGrid();
            }
            catch (Exception ex)
            {
                // Log internally; show friendly message
                System.Diagnostics.Debug.WriteLine($"[AddSubject.Save] Error: {ex}");
                ShowToast("An unexpected error occurred while saving. Please try again.", "danger");
                ReopenModal();
            }
        }

        // ─── GridView Row Commands ─────────────────────────────────────────────────
        protected void gvSubjects_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            // SuperAdmin: block all modifications
            if (IsSuperAdmin)
            {
                ShowToast("Access Denied: SuperAdmin has view-only access and cannot modify subjects.", "warning");
                return;
            }

            if (e.CommandArgument == null) return;
            if (!int.TryParse(e.CommandArgument.ToString(), out int id)) return;

            try
            {
                switch (e.CommandName)
                {
                    case "EditRow":
                        HandleEdit(id);
                        break;

                    case "Toggle":
                        HandleToggle(id);
                        break;

                    case "DeleteRow":
                        HandleDelete(id);
                        break;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[AddSubject.RowCommand] Error: {ex}");
                ShowToast("An unexpected error occurred. Please try again.", "danger");
            }
        }

        // ─── Handle Edit ───────────────────────────────────────────────────────────
        private void HandleEdit(int id)
        {
            DataTable dt = _bl.GetById(id, SessionId);
            if (dt == null || dt.Rows.Count == 0)
            {
                ShowToast("Subject not found or may have been deleted.", "warning");
                BindGrid();
                return;
            }

            DataRow dr = dt.Rows[0];

            hfSubjectId.Value = id.ToString();
            txtSubjectCode.Text = dr["SubjectCode"].ToString();
            txtSubjectName.Text = dr["SubjectName"].ToString();
            txtDescription.Text = dr["Description"].ToString();
            chkActive.Checked = Convert.ToBoolean(dr["IsActive"]);

            // Parse stored duration back into value + unit
            string fullDuration = dr["Duration"].ToString();
            ParseDuration(fullDuration, out string durVal, out string durUnit);
            txtDurationValue.Text = durVal;
            if (!string.IsNullOrEmpty(durUnit))
            {
                try { ddlDurationUnit.SelectedValue = durUnit; } catch { /* default */ }
            }

            // Open modal via JS
            ScriptManager.RegisterStartupScript(this, GetType(), "openEdit", "openModal();", true);
        }

        // ─── Handle Toggle ─────────────────────────────────────────────────────────
        private void HandleToggle(int id)
        {
            // Get current status first for better toast message
            DataTable dt = _bl.GetById(id, SessionId);
            if (dt == null || dt.Rows.Count == 0)
            {
                ShowToast("Subject not found.", "warning");
                BindGrid();
                return;
            }

            bool wasActive = Convert.ToBoolean(dt.Rows[0]["IsActive"]);
            string subjectName = dt.Rows[0]["SubjectName"].ToString();

            _bl.Toggle(id, SessionId);

            LogActivity(UserId, SocietyId, InstituteId, SessionId,
                $"TOGGLE_SUBJECT: Id={id}, Name={subjectName}, NewStatus={(!wasActive ? "Active" : "Inactive")}", id);

            string newStatus = wasActive ? "deactivated" : "activated";
            ShowToast($"Subject '{subjectName}' has been {newStatus} successfully.", "success");

            BindGrid();
        }

        // ─── Handle Delete ─────────────────────────────────────────────────────────
        private void HandleDelete(int id)
        {
            // Check if subject is used in other tables before deleting
            bool isUsed = _bl.IsSubjectInUse(id);
            if (isUsed)
            {
                // Get name for a better message
                string subName = GetSubjectName(id);
                ShowToast(
                    $"Cannot delete '{subName}': this subject is assigned to students, faculty, or other records. " +
                    "You may deactivate it instead.",
                    "warning");
                return;
            }

            DataTable dt = _bl.GetById(id, SessionId);
            string name = dt?.Rows.Count > 0 ? dt.Rows[0]["SubjectName"].ToString() : "Subject";

            _bl.Delete(id, SessionId);

            LogActivity(UserId, SocietyId, InstituteId, SessionId,
                $"DELETE_SUBJECT: Id={id}, Name={name}", id);

            ShowToast($"Subject '{name}' deleted successfully.", "success");
            BindGrid();
        }

        // ─── Toggle View (Active / Inactive) ──────────────────────────────────────
        protected void btnToggleView_Click(object sender, EventArgs e)
        {
            ViewStateStatus = ViewStateStatus == "1" ? "0" : "1";
            BindGrid();
        }

        // ─── Toast Helper ──────────────────────────────────────────────────────────
        /// <summary>
        /// Shows a Bootstrap toast via ScriptManager.
        /// type: "success" | "danger" | "warning"
        /// </summary>
        private void ShowToast(string msg, string type = "success")
        {
            // Escape single quotes to prevent JS injection
            msg = msg.Replace("'", "\\'");

            string script = $"serverToast('{msg}', '{type}');";
            ScriptManager.RegisterStartupScript(this, GetType(), "toast_" + Guid.NewGuid().ToString("N").Substring(0, 8), script, true);
        }

        // ─── Reopen Modal (after server validation failure) ────────────────────────
        private void ReopenModal()
        {
            ScriptManager.RegisterStartupScript(this, GetType(), "reopenModal", "openModal();", true);
        }

        // ─── Clear Form ────────────────────────────────────────────────────────────
        private void Clear()
        {
            hfSubjectId.Value = string.Empty;
            txtSubjectCode.Text = string.Empty;
            txtSubjectName.Text = string.Empty;
            txtDescription.Text = string.Empty;
            txtDurationValue.Text = string.Empty;
            chkActive.Checked = true;
            ddlDurationUnit.SelectedIndex = 0;
        }

        // ─── ViewState Status ──────────────────────────────────────────────────────
        private string ViewStateStatus
        {
            get => ViewState["SubjectStatus"]?.ToString() ?? "1"; // "1" = Active
            set => ViewState["SubjectStatus"] = value;
        }

        // ─── Duration Parser ───────────────────────────────────────────────────────
        /// <summary>Splits "45 mins" → ("45", "mins")</summary>
        private void ParseDuration(string fullDuration, out string value, out string unit)
        {
            value = string.Empty;
            unit = "hrs";

            if (string.IsNullOrWhiteSpace(fullDuration)) return;

            var parts = fullDuration.Trim().Split(new char[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            if (parts.Length >= 1) value = parts[0];
            if (parts.Length >= 2) unit = parts[1].ToLower();
        }

        // ─── Get Subject Name (for messages) ──────────────────────────────────────
        private string GetSubjectName(int id)
        {
            try
            {
                var dt = _bl.GetById(id, SessionId);
                return dt?.Rows.Count > 0 ? dt.Rows[0]["SubjectName"].ToString() : "this subject";
            }
            catch { return "this subject"; }
        }
    }
}