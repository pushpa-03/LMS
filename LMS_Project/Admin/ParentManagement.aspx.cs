using LearningManagementSystem.BL;
using LearningManagementSystem.GC;
using OfficeOpenXml;           // Install-Package EPPlus
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using OfficeOpenXml;

namespace LearningManagementSystem.Admin
{
    public partial class ParentManagement : BasePage
    {
        // ─── BL ───────────────────────────────────────────────────────────────────
        private readonly AddParentBL _bl = new AddParentBL();

        // ─── Pagination ───────────────────────────────────────────────────────────
        private const int PageSize = 6;

        private int CurrentPage
        {
            get => (int)(ViewState["ParentPage"] ?? 1);
            set => ViewState["ParentPage"] = value;
        }

        // ─── Role ─────────────────────────────────────────────────────────────────
        private bool IsSuperAdmin =>
            Session["Role"]?.ToString()
                .Equals("SuperAdmin", StringComparison.OrdinalIgnoreCase) == true;

        // ═════════════════════════════════════════════════════════════════════════
        //  PAGE LOAD
        // ═════════════════════════════════════════════════════════════════════════
        protected void Page_Load(object sender, EventArgs e)
        {
            if (SessionId != 0)
            {
                string filterStatus = ddlFilterStatus.SelectedValue;
                DataTable dtAll = _bl.GetParents(InstituteId, SessionId, filterStatus);

                int total = dtAll.Rows.Count;
                int totalPages = (int)Math.Ceiling((double)total / PageSize);

                BuildPager(totalPages);
            }

            if (!IsPostBack)
            {
                ConfigureRoleUI();
                SetSessionLabel();

                if (SessionId == 0)
                {
                    ShowToast("No active academic session found. Please configure a session first.", "warning");
                    return;
                }

                BindParents();
                LoadStudentRepeater();
                this.DataBind(); // ✅ REQUIRED
                ExcelPackage.License.SetNonCommercialPersonal("Name");
            }

        }

        // ─── Role UI ──────────────────────────────────────────────────────────────
        private void ConfigureRoleUI()
        {
            lblSuperAdminBadge.Visible = IsSuperAdmin;
            pnlAddBtn.Visible = !IsSuperAdmin;
            pnlBulkBtn.Visible = !IsSuperAdmin;
        }

        private void SetSessionLabel()
        {
            lblSessionName.Text = Session["SessionName"]?.ToString() ?? "—";
        }

        // ═════════════════════════════════════════════════════════════════════════
        //  STUDENT REPEATER  (for the Link Students tab in modal)
        // ═════════════════════════════════════════════════════════════════════════
        private void LoadStudentRepeater()
        {
            DataTable dt = _bl.GetActiveStudents(InstituteId, SessionId);
            rptStudents.DataSource = dt;
            rptStudents.DataBind();
        }

        // ═════════════════════════════════════════════════════════════════════════
        //  FILTER POSTBACK
        // ═════════════════════════════════════════════════════════════════════════
        protected void ddlFilterStatus_Changed(object sender, EventArgs e)
        {
            CurrentPage = 1;
            BindParents();
        }

        // ═════════════════════════════════════════════════════════════════════════
        //  BIND GRID + STATS + PAGER
        // ═════════════════════════════════════════════════════════════════════════
        private void BindParents()
        {
            if (SessionId == 0)
            {
                gvParents.DataSource = null;
                gvParents.DataBind();
                UpdateStats(null);
                return;
            }

            string filterStatus = ddlFilterStatus.SelectedValue;
            DataTable dtAll = _bl.GetParents(InstituteId, SessionId, filterStatus);

            UpdateStats(dtAll);

            // Pagination slice
            int total = dtAll.Rows.Count;
            int totalPages = (int)Math.Ceiling((double)total / PageSize);
            if (CurrentPage > totalPages && totalPages > 0) CurrentPage = totalPages;
            if (CurrentPage < 1) CurrentPage = 1;

            int start = (CurrentPage - 1) * PageSize;
            int end = Math.Min(start + PageSize, total);

            DataTable dtPage = dtAll.Clone();
            for (int i = start; i < end; i++)
                dtPage.ImportRow(dtAll.Rows[i]);

            gvParents.DataSource = dtPage;
            gvParents.DataBind();

            // Record count JS
            string countText = total == 0
                ? "No parents found"
                : $"Showing {(total == 0 ? 0 : start + 1)}–{end} of {total} parents";

            ScriptManager.RegisterStartupScript(this, GetType(), "recCnt",
                $"var rc=document.getElementById('recordCount');if(rc)rc.textContent='{countText}';",
                true);

            BuildPager(totalPages);
        }

        private void UpdateStats(DataTable dt)
        {
            if (dt == null || dt.Rows.Count == 0)
            {
                lblTotal.Text = lblActive.Text =
                    lblInactive.Text = lblLinks.Text = "0";
                return;
            }

            // Stats from dedicated query for accuracy
            DataTable dtStats = _bl.GetStats(InstituteId, SessionId);
            if (dtStats.Rows.Count > 0)
            {
                DataRow r = dtStats.Rows[0];
                lblTotal.Text = r["TotalParents"].ToString();
                lblActive.Text = r["ActiveParents"].ToString();
                lblInactive.Text = r["InactiveParents"].ToString();
                lblLinks.Text = r["TotalLinks"].ToString();
            }
        }

        // ─── Pager ────────────────────────────────────────────────────────────────
        //private void BuildPager(int totalPages)
        //{
        //    pnlPager.Controls.Clear();
        //    if (totalPages <= 1) return;

        //    AddPageBtn("‹ Prev", CurrentPage - 1, CurrentPage == 1);

        //    int from = Math.Max(1, CurrentPage - 2);
        //    int to = Math.Min(totalPages, CurrentPage + 2);

        //    if (from > 1) { AddPageBtn("1", 1, false); if (from > 2) AddEllipsis(); }
        //    for (int p = from; p <= to; p++)
        //        AddPageBtn(p.ToString(), p, false, p == CurrentPage);
        //    if (to < totalPages) { if (to < totalPages - 1) AddEllipsis(); AddPageBtn(totalPages.ToString(), totalPages, false); }

        //    AddPageBtn("Next ›", CurrentPage + 1, CurrentPage == totalPages);
        //}

        private void BuildPager(int totalPages)
        {
            pnlPager.Controls.Clear();

            if (totalPages <= 1)
                return;

            // PREVIOUS BUTTON
            AddPageBtn("‹ Prev", CurrentPage - 1, CurrentPage == 1);

            int startPage = Math.Max(1, CurrentPage - 2);
            int endPage = Math.Min(totalPages, CurrentPage + 2);

            // FIRST PAGE
            if (startPage > 1)
            {
                AddPageBtn("1", 1, false);

                if (startPage > 2)
                    AddEllipsis();
            }

            // PAGE NUMBERS
            for (int i = startPage; i <= endPage; i++)
            {
                AddPageBtn(i.ToString(), i, false, i == CurrentPage);
            }

            // LAST PAGE
            if (endPage < totalPages)
            {
                if (endPage < totalPages - 1)
                    AddEllipsis();

                AddPageBtn(totalPages.ToString(), totalPages, false);
            }

            // NEXT BUTTON
            AddPageBtn("Next ›", CurrentPage + 1, CurrentPage == totalPages);
        }
        //private void AddPageBtn(string text, int page, bool disabled, bool active = false)
        //{
        //    var btn = new LinkButton
        //    {
        //        Text = text,
        //        CommandName = "Page",
        //        CommandArgument = page.ToString(),
        //        CssClass = "par-page-btn" + (active ? " active" : ""),
        //        Enabled = !disabled
        //    };
        //    btn.Click += PageBtn_Click;
        //    pnlPager.Controls.Add(btn);
        //}

        protected void PagerButton_Click(object sender, EventArgs e)
        {
            LinkButton btn = sender as LinkButton;

            if (btn != null)
            {
                int pageNo;

                if (int.TryParse(btn.CommandArgument, out pageNo))
                {
                    CurrentPage = pageNo;

                    BindParents();
                }
            }
        }
        private void AddPageBtn(string text, int pageNo, bool disabled, bool active = false)
        {
            LinkButton btn = new LinkButton();

            btn.Text = text;
            btn.CommandName = "Page";
            btn.CommandArgument = pageNo.ToString();

            btn.CssClass = "par-page-btn";

            if (active)
                btn.CssClass += " active";

            if (disabled)
            {
                btn.Enabled = false;
                btn.Style["opacity"] = "0.5";
                btn.Style["cursor"] = "not-allowed";
            }

            btn.Click += PagerButton_Click;

            pnlPager.Controls.Add(btn);
        }


        private void AddEllipsis() =>
            pnlPager.Controls.Add(new LiteralControl(
                "<span class='par-page-btn' style='cursor:default;pointer-events:none'>…</span>"));

        protected void PageBtn_Click(object sender, EventArgs e)
        {
            if (int.TryParse(((LinkButton)sender).CommandArgument, out int p))
            {
                CurrentPage = p;
                BindParents();
            }
        }

        // ═════════════════════════════════════════════════════════════════════════
        //  SAVE PARENT  (INSERT / UPDATE)
        // ═════════════════════════════════════════════════════════════════════════
        protected void btnSaveParent_Click(object sender, EventArgs e)
        {
            if (IsSuperAdmin)
            {
                ShowToast("Access Denied: SuperAdmin has view-only access.", "warning");
                return;
            }
            if (SessionId == 0)
            {
                ShowToast("No active academic session found.", "warning");
                return;
            }

            // ── Collect values ──────────────────────────────────────────────────
            string fullName = txtFullName.Text.Trim();
            string username = txtUsername.Text.Trim().ToLower();
            string email = txtEmail.Text.Trim().ToLower();
            string contact = txtContact.Text.Trim();
            string gender = ddlGender.SelectedValue;
            string dobStr = txtDOB.Text.Trim();
            string relation = ddlRelation.SelectedValue;
            string address = txtAddress.Text.Trim();
            string studIds = hfSelectedStuds.Value;

            int parentUserId = string.IsNullOrEmpty(hfParentUserId.Value)
                                ? 0 : Convert.ToInt32(hfParentUserId.Value);
            bool isInsert = parentUserId == 0;

            // ── Server-side validation ──────────────────────────────────────────
            if (fullName.Length < 3)
            { ShowToast("Full name must be at least 3 characters.", "danger"); ReopenModal(); return; }

            if (!System.Text.RegularExpressions.Regex.IsMatch(username, @"^[a-z0-9_]{3,50}$"))
            { ShowToast("Username: lowercase, numbers, underscore only (3–50 chars).", "danger"); ReopenModal(); return; }

            if (!System.Text.RegularExpressions.Regex.IsMatch(email, @"^[^\s@]+@[^\s@]+\.[^\s@]+$"))
            { ShowToast("Please enter a valid email address.", "danger"); ReopenModal(); return; }

            if (!System.Text.RegularExpressions.Regex.IsMatch(contact, @"^[0-9+]{10,15}$"))
            { ShowToast("Enter a valid contact number (10–15 digits).", "danger"); ReopenModal(); return; }

            if (string.IsNullOrWhiteSpace(gender))
            { ShowToast("Please select gender.", "danger"); ReopenModal(); return; }

            if (string.IsNullOrWhiteSpace(dobStr))
            { ShowToast("Date of birth is required.", "danger"); ReopenModal(); return; }

            if (!DateTime.TryParse(dobStr, out DateTime dob))
            { ShowToast("Invalid date of birth.", "danger"); ReopenModal(); return; }

            if (string.IsNullOrWhiteSpace(relation))
            { ShowToast("Please select a relationship type.", "danger"); ReopenModal(); return; }

            if (string.IsNullOrWhiteSpace(studIds))
            { ShowToast("Please select at least one student to link.", "danger"); ReopenModal(); return; }

            if (string.IsNullOrWhiteSpace(address))
            { ShowToast("Address is required.", "danger"); ReopenModal(); return; }

            // Parse student IDs
            List<int> studentIdList = new List<int>();
            foreach (string s in studIds.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries))
                if (int.TryParse(s.Trim(), out int sid)) studentIdList.Add(sid);

            if (studentIdList.Count == 0)
            { ShowToast("Please select at least one student.", "danger"); ReopenModal(); return; }

            // ── Duplicate checks ────────────────────────────────────────────────
            if (isInsert && _bl.IsUsernameTaken(username, 0))
            { ShowToast($"Username '{username}' is already taken.", "danger"); ReopenModal(); return; }

            if (isInsert && _bl.IsEmailTaken(email, 0))
            { ShowToast($"Email '{email}' is already registered.", "danger"); ReopenModal(); return; }

            try
            {
                // Password = DOB in DDMMYYYY
                string password = dob.ToString("ddMMyyyy");

                var obj = new ParentGC
                {
                    UserId = parentUserId,
                    SocietyId = SocietyId,
                    InstituteId = InstituteId,
                    SessionId = SessionId,
                    FullName = fullName,
                    Username = username,
                    Email = email,
                    Password = password,
                    ContactNo = contact,
                    Gender = gender,
                    DOB = dob,
                    RelationshipType = relation,
                    IsPrimaryGuardian = chkPrimary.Checked,
                    StudentIds = studentIdList,
                    Address = address,
                    City = txtCity.Text.Trim(),
                    Country = txtCountry.Text.Trim(),
                    Pincode = int.TryParse(txtPincode.Text.Trim(), out int pin) ? pin : (int?)null,
                    Occupation = txtOccupation.Text.Trim(),
                    AnnualIncome = txtIncome.Text.Trim()
                };

                if (isInsert)
                {
                    int newId = _bl.InsertParent(obj);
                    LogActivity(UserId, SocietyId, InstituteId, SessionId,
                        $"ADD_PARENT: Name={fullName}, Username={username}", newId);
                    ShowToast($"Parent '{fullName}' added successfully. " +
                              $"Login password: <strong>{password}</strong>", "success");
                }
                else
                {
                    _bl.UpdateParent(obj);
                    LogActivity(UserId, SocietyId, InstituteId, SessionId,
                        $"UPDATE_PARENT: UserId={parentUserId}, Name={fullName}", parentUserId);
                    ShowToast($"Parent '{fullName}' updated successfully.", "success");
                }

                ClearForm();
                CurrentPage = 1;
                BindParents();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[AddParent.Save] {ex}");
                ShowToast("An unexpected error occurred. Please try again.", "danger");
                ReopenModal();
            }
        }

        // ═════════════════════════════════════════════════════════════════════════
        //  GRIDVIEW ROW COMMANDS
        // ═════════════════════════════════════════════════════════════════════════
        protected void gvParents_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (IsSuperAdmin && e.CommandName != "SendCreds")
            {
                ShowToast("Access Denied: SuperAdmin has view-only access.", "warning");
                return;
            }

            if (!int.TryParse(e.CommandArgument?.ToString(), out int parentUserId) || parentUserId == 0)
                return;

            try
            {
                switch (e.CommandName)
                {
                    case "SendCreds": HandleSendCreds(parentUserId); break;
                    case "EditRow": HandleEdit(parentUserId); break;
                    case "ResetPwd": HandleResetPassword(parentUserId); break;
                    case "Toggle": HandleToggle(parentUserId); break;
                    case "DeleteRow": HandleDelete(parentUserId); break;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[AddParent.RowCmd:{e.CommandName}] {ex}");
                ShowToast("An unexpected error occurred. Please try again.", "danger");
            }
        }

        // ─── Send Credentials ─────────────────────────────────────────────────────
        private void HandleSendCreds(int parentUserId)
        {
            DataTable dt = _bl.GetParentById(parentUserId, SessionId);
            if (dt == null || dt.Rows.Count == 0)
            { ShowToast("Parent not found.", "warning"); return; }

            DataRow dr = dt.Rows[0];
            string name = dr["FullName"].ToString();
            string uname = dr["Username"].ToString();
            string email = dr["Email"].ToString();
            string dob = dr["DOB"] != DBNull.Value
                           ? Convert.ToDateTime(dr["DOB"]).ToString("ddMMyyyy")
                           : "DDMMYYYY";

            // Build linked students list
            DataTable dtLinks = _bl.GetLinkedStudents(parentUserId, SessionId);
            var studentLines = new StringBuilder();
            foreach (DataRow sr in dtLinks.Rows)
                studentLines.AppendLine($"  • {sr["FullName"]} ({sr["RollNumber"]})");

            string loginUrl = Request.Url.GetLeftPart(UriPartial.Authority) + "/Default.aspx";

            string htmlContent = $@"
            <div class='creds-box'>
                <div class='creds-field'>
                    <span class='creds-label'>Parent Name</span>
                    <span class='creds-val'>{name}</span>
                </div>
                <div class='creds-field'>
                    <span class='creds-label'>Email / Username</span>
                    <span class='creds-val'>{email} &nbsp;/&nbsp; {uname}</span>
                </div>
                <div class='creds-field'>
                    <span class='creds-label'>Password (DOB: DDMMYYYY)</span>
                    <span class='creds-val text-primary'>{dob}</span>
                </div>
                <div class='creds-field'>
                    <span class='creds-label'>Login URL</span>
                    <span class='creds-val'><a href='{loginUrl}' target='_blank'>{loginUrl}</a></span>
                </div>
                <div class='creds-field'>
                    <span class='creds-label'>Linked Student(s)</span>
                    <span class='creds-val'>{studentLines.ToString().Replace(Environment.NewLine, "<br/>")}</span>
                </div>
                <div class='alert alert-warning border-0 rounded-3 mt-3 py-2 px-3 mb-0' style='font-size:12px'>
                    <i class='fa fa-exclamation-triangle me-1'></i>
                    Please share these credentials securely. Ask parent to change password after first login.
                </div>
            </div>";

            string plainText = $"Parent: {name}\nUsername: {uname}\nEmail: {email}\n" +
                               $"Password: {dob}\nLogin: {loginUrl}\n" +
                               $"Students:\n{studentLines}";

            string safeHtml = htmlContent.Replace("'", "\\'").Replace("\r", "").Replace("\n", "");
            string safeText = plainText.Replace("'", "\\'").Replace("\r", "").Replace("\n", "\\n");

            string script = $"showCredsModal('{safeHtml}', '{safeText}');";
            ScriptManager.RegisterStartupScript(this, GetType(), "showCreds", script, true);

            LogActivity(UserId, SocietyId, InstituteId, SessionId,
                $"VIEW_CREDS_PARENT: UserId={parentUserId}, Name={name}", parentUserId);
        }

        // ─── Edit ─────────────────────────────────────────────────────────────────
        private void HandleEdit(int parentUserId)
        {
            DataTable dt = _bl.GetParentById(parentUserId, SessionId);
            if (dt == null || dt.Rows.Count == 0)
            { ShowToast("Parent not found.", "warning"); return; }

            DataRow dr = dt.Rows[0];
            hfParentUserId.Value = parentUserId.ToString();

            // Tab 1 – Account
            txtFullName.Text = dr["FullName"].ToString();
            txtUsername.Text = dr["Username"].ToString();
            txtEmail.Text = dr["Email"].ToString();
            txtContact.Text = dr["ContactNo"].ToString();
            ddlGender.SelectedValue = dr["Gender"].ToString();
            txtDOB.Text = FormatDateInput(dr["DOB"]);

            // Tab 2 – Link Students (relation, primary)
            ddlRelation.SelectedValue = dr["RelationshipType"].ToString();
            chkPrimary.Checked = dr["IsPrimaryGuardian"] != DBNull.Value &&
                                        Convert.ToBoolean(dr["IsPrimaryGuardian"]);

            // Pre-tick linked students via JS
            DataTable dtLinks = _bl.GetLinkedStudents(parentUserId, SessionId);
            var idList = new List<string>();
            foreach (DataRow sr in dtLinks.Rows)
                idList.Add(sr["UserId"].ToString());

            string idsJson = "[" + string.Join(",", idList) + "]";
            string preTickScript = $@"
                var ids = {idsJson};
                document.querySelectorAll('.stud-chk').forEach(function(c){{
                    c.checked = ids.includes(parseInt(c.value));
                }});
                updateSelectedStuds();";
            ScriptManager.RegisterStartupScript(this, GetType(), "preTick", preTickScript, true);
            hfSelectedStuds.Value = string.Join(",", idList);

            // Tab 3 – Personal
            txtAddress.Text = dr["Address"].ToString();
            txtCity.Text = dr["City"].ToString();
            txtCountry.Text = dr["Country"].ToString();
            txtPincode.Text = dr["Pincode"] != DBNull.Value ? dr["Pincode"].ToString() : "";
            txtOccupation.Text = dr["Occupation"].ToString();
            txtIncome.Text = dr["AnnualIncome"].ToString();

            ScriptManager.RegisterStartupScript(this, GetType(), "openEdit", "openModal();", true);
        }

        // ─── Reset Password ───────────────────────────────────────────────────────
        private void HandleResetPassword(int parentUserId)
        {
            DataTable dt = _bl.GetParentById(parentUserId, SessionId);
            if (dt == null || dt.Rows.Count == 0)
            { ShowToast("Parent not found.", "warning"); return; }

            DataRow dr = dt.Rows[0];
            string name = dr["FullName"].ToString();

            // Reset to DOB-based password
            string newPwd = dr["DOB"] != DBNull.Value
                            ? Convert.ToDateTime(dr["DOB"]).ToString("ddMMyyyy")
                            : "Parent@123";

            _bl.ResetPassword(parentUserId, newPwd);
            LogActivity(UserId, SocietyId, InstituteId, SessionId,
                $"RESET_PWD_PARENT: UserId={parentUserId}, Name={name}", parentUserId);

            ShowToast($"Password for '{name}' reset to: <strong>{newPwd}</strong> (DOB-based).", "warning");
            BindParents();
        }

        // ─── Toggle ───────────────────────────────────────────────────────────────
        private void HandleToggle(int parentUserId)
        {
            DataTable dt = _bl.GetParentById(parentUserId, SessionId);
            bool wasActive = dt?.Rows.Count > 0 && Convert.ToBoolean(dt.Rows[0]["IsActive"]);
            string name = dt?.Rows.Count > 0 ? dt.Rows[0]["FullName"].ToString() : "Parent";

            _bl.ToggleParent(parentUserId);
            LogActivity(UserId, SocietyId, InstituteId, SessionId,
                $"TOGGLE_PARENT: UserId={parentUserId}, NewStatus={(!wasActive ? "Active" : "Inactive")}",
                parentUserId);

            ShowToast($"'{name}' has been {(wasActive ? "deactivated" : "activated")} successfully.", "success");
            BindParents();
        }

        // ─── Delete ───────────────────────────────────────────────────────────────
        private void HandleDelete(int parentUserId)
        {
            DataTable dt = _bl.GetParentById(parentUserId, SessionId);
            string name = dt?.Rows.Count > 0 ? dt.Rows[0]["FullName"].ToString() : "Parent";

            // Check FK usage
            bool inUse = _bl.IsParentInUse(parentUserId);
            if (inUse)
            {
                ShowToast($"Cannot delete '{name}': parent has linked records. Deactivate instead.", "warning");
                return;
            }

            _bl.DeleteParent(parentUserId, SessionId);
            LogActivity(UserId, SocietyId, InstituteId, SessionId,
                $"DELETE_PARENT: UserId={parentUserId}, Name={name}", parentUserId);

            ShowToast($"Parent '{name}' deleted successfully.", "success");
            CurrentPage = 1;
            BindParents();
        }

        // ═════════════════════════════════════════════════════════════════════════
        //  BULK UPLOAD
        // ═════════════════════════════════════════════════════════════════════════
        protected void btnBulkUpload_Click(object sender, EventArgs e)
        {

            if (IsSuperAdmin) { ShowToast("Access Denied.", "warning"); return; }
            if (!fuBulk.HasFile)
            { ShowToast("Please select an Excel file.", "warning"); return; }

            string ext = Path.GetExtension(fuBulk.FileName).ToLower();
            if (ext != ".xlsx" && ext != ".xls")
            { ShowToast("Only .xlsx or .xls files are supported.", "danger"); return; }

            int inserted = 0, skipped = 0, errors = 0;
            var errRows = new List<string>();
            var sb = new StringBuilder();

            try
            {
                
                using (var pkg = new ExcelPackage(fuBulk.FileContent))
                {
                    var ws = pkg.Workbook.Worksheets[0];
                    if (ws?.Dimension == null)
                    { ShowToast("The Excel file is empty.", "warning"); return; }

                    int rows = ws.Dimension.Rows;

                    // Column order (matches template + manual form):
                    // 1 FullName, 2 Username, 3 Email, 4 ContactNo, 5 Gender, 6 DOB (YYYY-MM-DD)
                    // 7 RelationshipType, 8 IsPrimaryGuardian (TRUE/FALSE)
                    // 9 StudentUsername (to find the student FK)
                    // 10 Address, 11 City, 12 Country, 13 Pincode, 14 Occupation

                    for (int row = 2; row <= rows; row++)
                    {
                        string fullName = ws.Cells[row, 1].Text.Trim();
                        string username = ws.Cells[row, 2].Text.Trim().ToLower();
                        string email = ws.Cells[row, 3].Text.Trim().ToLower();
                        string contact = ws.Cells[row, 4].Text.Trim();
                        string gender = ws.Cells[row, 5].Text.Trim();
                        string dobStr = ws.Cells[row, 6].Text.Trim();
                        string relation = ws.Cells[row, 7].Text.Trim();
                        string isPrimStr = ws.Cells[row, 8].Text.Trim();
                        string studUname = ws.Cells[row, 9].Text.Trim();
                        string address = ws.Cells[row, 10].Text.Trim();
                        string city = ws.Cells[row, 11].Text.Trim();
                        string country = ws.Cells[row, 12].Text.Trim();
                        string pincode = ws.Cells[row, 13].Text.Trim();
                        string occupation = ws.Cells[row, 14].Text.Trim();

                        if (string.IsNullOrWhiteSpace(fullName) &&
                            string.IsNullOrWhiteSpace(username)) continue;

                        // Row-level validation
                        var rowErrs = new List<string>();
                        if (string.IsNullOrWhiteSpace(fullName) || fullName.Length < 3) rowErrs.Add("Full name missing or too short");
                        if (!System.Text.RegularExpressions.Regex.IsMatch(username, @"^[a-z0-9_]{3,50}$")) rowErrs.Add("Invalid username");
                        if (!System.Text.RegularExpressions.Regex.IsMatch(email, @"^[^\s@]+@[^\s@]+\.[^\s@]+$")) rowErrs.Add("Invalid email");
                        if (!System.Text.RegularExpressions.Regex.IsMatch(contact, @"^[0-9+]{10,15}$")) rowErrs.Add("Invalid contact");
                        if (string.IsNullOrWhiteSpace(gender)) rowErrs.Add("Gender missing");
                        if (!DateTime.TryParse(dobStr, out DateTime dob)) rowErrs.Add("Invalid DOB");
                        if (string.IsNullOrWhiteSpace(relation)) rowErrs.Add("Relationship missing");
                        if (string.IsNullOrWhiteSpace(studUname)) rowErrs.Add("StudentUsername missing");

                        if (rowErrs.Count > 0)
                        {
                            errRows.Add($"Row {row}: {string.Join(", ", rowErrs)}");
                            errors++;
                            continue;
                        }

                        // Duplicate check → skip and report
                        if (_bl.IsUsernameTaken(username, 0) || _bl.IsEmailTaken(email, 0))
                        {
                            errRows.Add($"Row {row}: Duplicate — username/email already exists ({username})");
                            skipped++;
                            continue;
                        }

                        // Resolve student FK by username
                        int studentUserId = _bl.GetUserIdByUsername(studUname);
                        if (studentUserId == 0)
                        {
                            errRows.Add($"Row {row}: Student '{studUname}' not found");
                            errors++;
                            continue;
                        }

                        bool isPrimary = isPrimStr.Equals("TRUE", StringComparison.OrdinalIgnoreCase) ||
                                         isPrimStr == "1" || isPrimStr.Equals("YES", StringComparison.OrdinalIgnoreCase);

                        string password = dob.ToString("ddMMyyyy");

                        var obj = new ParentGC
                        {
                            SocietyId = SocietyId,
                            InstituteId = InstituteId,
                            SessionId = SessionId,
                            FullName = fullName,
                            Username = username,
                            Email = email,
                            Password = password,
                            ContactNo = contact,
                            Gender = gender,
                            DOB = dob,
                            RelationshipType = relation,
                            IsPrimaryGuardian = isPrimary,
                            StudentIds = new List<int> { studentUserId },
                            Address = string.IsNullOrWhiteSpace(address) ? "N/A" : address,
                            City = city,
                            Country = country,
                            Pincode = int.TryParse(pincode, out int pin) ? pin : (int?)null,
                            Occupation = occupation
                        };

                        try
                        {
                            _bl.InsertParent(obj);
                            LogActivity(UserId, SocietyId, InstituteId, SessionId,
                                $"BULK_ADD_PARENT: Name={fullName}, Username={username}", 0);
                            inserted++;
                        }
                        catch (Exception rowEx)
                        {
                            errRows.Add($"Row {row}: DB error — {rowEx.Message}");
                            errors++;
                        }
                    }
                }

                // Result HTML
                sb.Append("<div class='d-flex gap-3 flex-wrap mb-3'>");
                sb.Append($"<span class='badge bg-success px-3 py-2'><i class='fa fa-check me-1'></i>{inserted} Added</span>");
                if (skipped > 0)
                    sb.Append($"<span class='badge bg-warning text-dark px-3 py-2'><i class='fa fa-ban me-1'></i>{skipped} Skipped (duplicate)</span>");
                if (errors > 0)
                    sb.Append($"<span class='badge bg-danger px-3 py-2'><i class='fa fa-times me-1'></i>{errors} Errors</span>");
                sb.Append("</div>");

                if (errRows.Count > 0)
                {
                    sb.Append("<div class='text-danger small'><strong>Issues:</strong><ul class='mb-0'>");
                    foreach (var er in errRows)
                        sb.Append($"<li>{er}</li>");
                    sb.Append("</ul></div>");
                }

                litBulkResult.Text = sb.ToString();
                pnlBulkResult.Visible = true;

                ShowToast($"Bulk upload: {inserted} added, {skipped} skipped, {errors} errors.",
                    inserted > 0 ? "success" : "warning");

                if (inserted > 0) { CurrentPage = 1; BindParents(); }

                ScriptManager.RegisterStartupScript(this, GetType(), "openBulk2",
                    "new bootstrap.Modal(document.getElementById('BulkModal')).show();", true);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[BulkParent] {ex}");
                ShowToast("Failed to process the file. Ensure it is a valid Excel file.", "danger");
            }
        }

        // ─── Download Template ────────────────────────────────────────────────────
        protected void lnkDownloadTemplate_Click(object sender, EventArgs e)
        {
            

            using (var pkg = new ExcelPackage())
            {
                var ws = pkg.Workbook.Worksheets.Add("Parents");

                string[] headers = {
                    "FullName","Username","Email","ContactNo","Gender","DOB",
                    "RelationshipType","IsPrimaryGuardian","StudentUsername",
                    "Address","City","Country","Pincode","Occupation"
                };

                for (int i = 0; i < headers.Length; i++)
                {
                    var cell = ws.Cells[1, i + 1];
                    cell.Value = headers[i];
                    cell.Style.Font.Bold = true;
                    cell.Style.Fill.PatternType = OfficeOpenXml.Style.ExcelFillStyle.Solid;
                    cell.Style.Fill.BackgroundColor.SetColor(System.Drawing.Color.FromArgb(79, 70, 229));
                    cell.Style.Font.Color.SetColor(System.Drawing.Color.White);
                    ws.Column(i + 1).Width = 20;
                }

                // Sample row
                ws.Cells[2, 1].Value = "Ramesh Sharma";
                ws.Cells[2, 2].Value = "ramesh_sharma25";
                ws.Cells[2, 3].Value = "ramesh@email.com";
                ws.Cells[2, 4].Value = "9876543210";
                ws.Cells[2, 5].Value = "Male";
                ws.Cells[2, 6].Value = "1980-06-15";
                ws.Cells[2, 7].Value = "Father";
                ws.Cells[2, 8].Value = "TRUE";
                ws.Cells[2, 9].Value = "rahul2025";
                ws.Cells[2, 10].Value = "45 MG Road, Mumbai";
                ws.Cells[2, 11].Value = "Mumbai";
                ws.Cells[2, 12].Value = "India";
                ws.Cells[2, 13].Value = "400001";
                ws.Cells[2, 14].Value = "Engineer";

                Response.Clear();
                Response.ContentType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
                Response.AddHeader("Content-Disposition", "attachment; filename=ParentUploadTemplate.xlsx");
                Response.BinaryWrite(pkg.GetAsByteArray());

                Response.Flush();
                Response.SuppressContent = true;
                HttpContext.Current.ApplicationInstance.CompleteRequest(); // Safer alternative to Response.End()
            }
        }

        // ═════════════════════════════════════════════════════════════════════════
        //  HELPERS  (also called from ASPX inline expressions)
        // ═════════════════════════════════════════════════════════════════════════

        protected string BuildStudentTags(string names, string rolls, string streams)
        {
            if (string.IsNullOrWhiteSpace(names)) return "";

            var nameArr = names.Split(',');
            var rollArr = rolls.Split(',');
            var streamArr = streams.Split(',');

            var html = "";

            for (int i = 0; i < nameArr.Length; i++)
            {
                string name = i < nameArr.Length ? nameArr[i] : "";
                string roll = i < rollArr.Length ? rollArr[i] : "";
                string stream = i < streamArr.Length ? streamArr[i] : "";

                html += $@"<span class='acad-tag tag-stud'>{name} ({roll}) - {stream}</span>";
            }

            return html;
        }

        protected string GetInitials(string name)
        {
            if (string.IsNullOrWhiteSpace(name)) return "?";
            var parts = name.Trim().Split(new char[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            if (parts.Length == 1) return parts[0].Substring(0, Math.Min(2, parts[0].Length)).ToUpper();
            return (parts[0][0].ToString() + parts[parts.Length - 1][0].ToString()).ToUpper();
        }

        private static readonly string[] AvatarColors = {
            "#4f46e5","#0891b2","#059669","#d97706",
            "#dc2626","#7c3aed","#db2777","#0d9488"
        };

        protected string GetAvatarColor(string name)
        {
            if (string.IsNullOrWhiteSpace(name)) return AvatarColors[0];
            return AvatarColors[Math.Abs(name.GetHashCode()) % AvatarColors.Length];
        }
        private void ClearForm()
        {
            hfParentUserId.Value = string.Empty;
            hfSelectedStuds.Value = string.Empty;
            txtFullName.Text = txtUsername.Text = txtEmail.Text = string.Empty;
            txtContact.Text = txtDOB.Text = txtAddress.Text = string.Empty;
            txtCity.Text = txtCountry.Text = txtPincode.Text = string.Empty;
            txtOccupation.Text = txtIncome.Text = string.Empty;
            ddlGender.SelectedIndex = 0;
            ddlRelation.SelectedIndex = 0;
            chkPrimary.Checked = false;
        }

        private void ReopenModal()
        {
            ScriptManager.RegisterStartupScript(this, GetType(),
                "reopen_" + Guid.NewGuid().ToString("N").Substring(0, 6),
                "openModal();", true);
        }

        private void ShowToast(string msg, string type = "success")
        {
            msg = msg.Replace("'", "\\'").Replace("\r", "").Replace("\n", "");
            ScriptManager.RegisterStartupScript(this, GetType(),
                "toast_" + Guid.NewGuid().ToString("N").Substring(0, 8),
                $"serverToast('{msg}', '{type}');", true);
        }

        private string FormatDateInput(object val) =>
            val != null && DateTime.TryParse(val.ToString(), out DateTime d)
                ? d.ToString("yyyy-MM-dd") : string.Empty;
    }
}