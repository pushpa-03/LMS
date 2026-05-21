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
        // ─── BL ───────────────────────────────────────────────────────────────────
        private readonly AddSubjectBL _bl = new AddSubjectBL();

        // ─── Page size ────────────────────────────────────────────────────────────
        private const int PAGE_SIZE = 4; // rows per page — change as needed

        // ─── Role check ───────────────────────────────────────────────────────────
        private bool IsSuperAdmin =>
            Session["Role"]?.ToString()
                .Equals("SuperAdmin", StringComparison.OrdinalIgnoreCase) == true;

        // ─── ViewState: current page ──────────────────────────────────────────────
        private int CurrentPage
        {
            get
            {
                object v = ViewState["SubjectPage"];
                return v is int p && p > 0 ? p : 1;
            }
            set { ViewState["SubjectPage"] = value; }
        }

        // ─── ViewState: active/inactive toggle ────────────────────────────────────
        private string ViewStateStatus
        {
            get => ViewState["SubjectStatus"]?.ToString() ?? "1";
            set => ViewState["SubjectStatus"] = value;
        }

        // ══════════════════════════════════════════════════════════════════════════
        //  PAGE LOAD
        //
        //  KEY FIX:  BindGrid() is called on EVERY request — not just !IsPostBack.
        //  Dynamic controls (phPageNums LinkButtons) must be re-created on every
        //  postback so ASP.NET can match their event handlers during the event phase.
        //  Calling BindGrid() only on !IsPostBack means the controls don't exist
        //  when the pager fires, which is why a second click was needed.
        // ══════════════════════════════════════════════════════════════════════════
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // First load only: configure role UI and reset to page 1
                ConfigureRoleUI();
                CurrentPage = 1;
            }

            // Always rebuild the grid + pager (every GET and every POST)
            BindGrid();
        }

        // ─── Role-based UI ────────────────────────────────────────────────────────
        private void ConfigureRoleUI()
        {
            hfIsSuperAdmin.Value = IsSuperAdmin ? "true" : "false";
            if (IsSuperAdmin)
            {
                lblSuperAdminBadge.Visible = true;
                pnlAddBtn.Visible = false;
            }
        }

        // ══════════════════════════════════════════════════════════════════════════
        //  BIND GRID  — fetches full result set, slices for current page,
        //               and always rebuilds the pager controls
        // ══════════════════════════════════════════════════════════════════════════
        private void BindGrid()
        {
            if (SessionId == 0)
            {
                gvSubjects.DataSource = null;
                gvSubjects.DataBind();
                UpdateStats(null);
                RenderPager(0, 0);
                ShowToast("No active academic session found. Please configure a session.", "warning");
                return;
            }

            string status = ViewStateStatus;
            string search = txtSearch?.Text?.Trim() ?? string.Empty;

            // Full result set from BL
            DataTable all = _bl.GetSubjects(InstituteId, SessionId, status, search);
            int total = all?.Rows.Count ?? 0;

            // Pagination maths
            int totalPages = total == 0 ? 1 : (int)Math.Ceiling((double)total / PAGE_SIZE);

            // Clamp current page
            if (CurrentPage > totalPages) CurrentPage = totalPages;
            if (CurrentPage < 1) CurrentPage = 1;

            int skip = (CurrentPage - 1) * PAGE_SIZE;
            int take = Math.Min(PAGE_SIZE, total - skip);

            // Slice for this page
            DataTable paged = all.Clone();
            for (int i = skip; i < skip + take; i++)
                paged.ImportRow(all.Rows[i]);

            gvSubjects.DataSource = paged;
            gvSubjects.DataBind();

            // Stats use the full set
            UpdateStats(all);

            // Info bar
            int from = total == 0 ? 0 : skip + 1;
            int to = total == 0 ? 0 : skip + take;
            lblRangeFrom.Text = from.ToString();
            lblRangeTo.Text = to.ToString();
            lblTotalCount.Text = total.ToString();
            lblPageMeta.Text = total == 0
                ? "No subjects found."
                : $"Page {CurrentPage} of {totalPages}";

            // Toggle button label
            btnToggleView.Text = status == "1"
                ? "<i class='fa fa-eye me-1'></i>Show Inactive"
                : "<i class='fa fa-eye-slash me-1'></i>Show Active";

            // Rebuild pager
            RenderPager(totalPages, total);
        }

        // ══════════════════════════════════════════════════════════════════════════
        //  RENDER PAGER
        //
        //  KEY FIX:  Always clears and re-adds LinkButtons to phPageNums.
        //  Because this runs inside Page_Load (before the event phase) the controls
        //  exist in the control tree when ASP.NET tries to route the Click event.
        //  That is what makes single-click navigation work.
        // ══════════════════════════════════════════════════════════════════════════
        private void RenderPager(int totalPages, int total)
        {
            pnlPager.Visible = totalPages > 1;
            if (!pnlPager.Visible) return;

            lblCurrentPage.Text = CurrentPage.ToString();
            lblTotalPages.Text = totalPages.ToString();

            bool onFirst = CurrentPage == 1;
            bool onLast = CurrentPage == totalPages;

            btnFirst.Enabled = !onFirst;
            btnPrev.Enabled = !onFirst;
            btnNext.Enabled = !onLast;
            btnLast.Enabled = !onLast;

            btnFirst.CssClass = "spg-btn" + (onFirst ? " disabled" : "");
            btnPrev.CssClass = "spg-btn" + (onFirst ? " disabled" : "");
            btnNext.CssClass = "spg-btn" + (onLast ? " disabled" : "");
            btnLast.CssClass = "spg-btn" + (onLast ? " disabled" : "");

            // ── Numbered buttons — always rebuilt ─────────────────────────────────
            phPageNums.Controls.Clear();

            int windowSize = 5;
            int startPage = Math.Max(1, CurrentPage - windowSize / 2);
            int endPage = Math.Min(totalPages, startPage + windowSize - 1);
            if (endPage - startPage < windowSize - 1)
                startPage = Math.Max(1, endPage - windowSize + 1);

            // Leading: always show page 1 + ellipsis if window doesn't start at 1
            if (startPage > 1)
            {
                AddPageButton(1, totalPages);
                if (startPage > 2) AddSeparator();
            }

            for (int i = startPage; i <= endPage; i++)
                AddPageButton(i, totalPages);

            // Trailing: always show last page + ellipsis if window doesn't reach it
            if (endPage < totalPages)
            {
                if (endPage < totalPages - 1) AddSeparator();
                AddPageButton(totalPages, totalPages);
            }
        }

        // Creates a numbered page LinkButton and wires the Click event
        private void AddPageButton(int pageNum, int totalPages)
        {
            bool isActive = pageNum == CurrentPage;
            var lb = new LinkButton
            {
                Text = pageNum.ToString(),
                CommandArgument = pageNum.ToString(),
                CssClass = "spg-btn" + (isActive ? " active" : ""),
                // Keep Enabled=true even for the active page so the control
                // participates in the control tree and doesn't cause issues;
                // the 'active' CSS style provides the visual cue.
                Enabled = true
            };
            lb.Click += Pager_Click;
            phPageNums.Controls.Add(lb);
        }

        private void AddSeparator()
        {
            phPageNums.Controls.Add(new Literal
            {
                Text = "<span class='spg-sep'>…</span>"
            });
        }

        // ══════════════════════════════════════════════════════════════════════════
        //  PAGER CLICK
        //
        //  Updates CurrentPage only — BindGrid was already called in Page_Load
        //  so we do NOT call it again here (it would double-render).
        //  Instead we just update ViewState and let Page_Load's BindGrid() that
        //  already ran handle the render... wait, Page_Load runs BEFORE events.
        //
        //  Correct flow:
        //    1. Page_Load fires  → BindGrid() renders page N (old page)
        //    2. Pager_Click fires → CurrentPage updated to N+1
        //    3. We call BindGrid() again here to re-render with the new page
        //
        //  This is the standard ASP.NET WebForms pattern for dynamic controls.
        // ══════════════════════════════════════════════════════════════════════════
        protected void Pager_Click(object sender, EventArgs e)
        {
            string arg = (sender as LinkButton)?.CommandArgument ?? "";

            // Compute total pages for clamping
            string search = txtSearch?.Text?.Trim() ?? string.Empty;
            DataTable all = _bl.GetSubjects(InstituteId, SessionId, ViewStateStatus, search);
            int totalPages = all == null || all.Rows.Count == 0
                                   ? 1
                                   : (int)Math.Ceiling((double)all.Rows.Count / PAGE_SIZE);

            switch (arg)
            {
                case "First": CurrentPage = 1; break;
                case "Prev": CurrentPage = Math.Max(1, CurrentPage - 1); break;
                case "Next": CurrentPage = Math.Min(totalPages, CurrentPage + 1); break;
                case "Last": CurrentPage = totalPages; break;
                default:
                    if (int.TryParse(arg, out int pg))
                        CurrentPage = Math.Max(1, Math.Min(pg, totalPages));
                    break;
            }

            // Re-render with the new page (Page_Load already ran with the old page)
            BindGrid();
        }

        // ══════════════════════════════════════════════════════════════════════════
        //  STATS
        // ══════════════════════════════════════════════════════════════════════════
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

        // ══════════════════════════════════════════════════════════════════════════
        //  SAVE (INSERT / UPDATE)
        // ══════════════════════════════════════════════════════════════════════════
        protected void btnSave_Click(object sender, EventArgs e)
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

            string code = txtSubjectCode.Text.Trim();
            string name = txtSubjectName.Text.Trim();
            string durVal = txtDurationValue.Text.Trim();
            string durUnit = ddlDurationUnit.SelectedValue;

            if (string.IsNullOrWhiteSpace(code))
            { ShowToast("Subject Code is required.", "danger"); ReopenModal(); return; }

            if (!System.Text.RegularExpressions.Regex.IsMatch(code, @"^[a-zA-Z0-9]+$"))
            { ShowToast("Subject Code must contain only letters and numbers.", "danger"); ReopenModal(); return; }

            if (string.IsNullOrWhiteSpace(name) || name.Length < 3)
            { ShowToast("Subject Name must be at least 3 characters.", "danger"); ReopenModal(); return; }

            string durationFull = string.Empty;
            if (!string.IsNullOrWhiteSpace(durVal))
            {
                if (!int.TryParse(durVal, out int durInt) || durInt <= 0)
                { ShowToast("Duration must be a positive number.", "danger"); ReopenModal(); return; }
                durationFull = $"{durInt} {durUnit}";
            }

            try
            {
                int subjectId = string.IsNullOrEmpty(hfSubjectId.Value) ? 0 : Convert.ToInt32(hfSubjectId.Value);
                bool isInsert = subjectId == 0;

                if (_bl.IsCodeDuplicate(InstituteId, SessionId, code, subjectId))
                { ShowToast($"Subject Code '{code}' already exists in this session.", "danger"); ReopenModal(); return; }

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
                    LogActivity(UserId, SocietyId, InstituteId, SessionId, $"INSERT_SUBJECT: Code={code}, Name={name}", 0);
                    ShowToast($"Subject '{name}' added successfully.", "success");
                    CurrentPage = 1;
                }
                else
                {
                    _bl.Update(obj);
                    LogActivity(UserId, SocietyId, InstituteId, SessionId, $"UPDATE_SUBJECT: Id={subjectId}, Code={code}, Name={name}", subjectId);
                    ShowToast($"Subject '{name}' updated successfully.", "success");
                }

                Clear();
                // BindGrid already called by Page_Load; call again to reflect new data
                BindGrid();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[AddSubject.Save] {ex}");
                ShowToast("An unexpected error occurred. Please try again.", "danger");
                ReopenModal();
            }
        }

        // ══════════════════════════════════════════════════════════════════════════
        //  GRIDVIEW ROW COMMANDS
        // ══════════════════════════════════════════════════════════════════════════
        protected void gvSubjects_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (IsSuperAdmin)
            { ShowToast("Access Denied: SuperAdmin has view-only access.", "warning"); return; }

            if (e.CommandArgument == null) return;
            if (!int.TryParse(e.CommandArgument.ToString(), out int id)) return;

            try
            {
                switch (e.CommandName)
                {
                    case "EditRow": HandleEdit(id); break;
                    case "Toggle": HandleToggle(id); break;
                    case "DeleteRow": HandleDelete(id); break;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[AddSubject.RowCommand] {ex}");
                ShowToast("An unexpected error occurred. Please try again.", "danger");
            }
        }

        private void HandleEdit(int id)
        {
            DataTable dt = _bl.GetById(id, SessionId);
            if (dt == null || dt.Rows.Count == 0)
            { ShowToast("Subject not found.", "warning"); BindGrid(); return; }

            DataRow dr = dt.Rows[0];
            hfSubjectId.Value = id.ToString();
            txtSubjectCode.Text = dr["SubjectCode"].ToString();
            txtSubjectName.Text = dr["SubjectName"].ToString();
            txtDescription.Text = dr["Description"].ToString();
            chkActive.Checked = Convert.ToBoolean(dr["IsActive"]);

            ParseDuration(dr["Duration"].ToString(), out string durVal, out string durUnit);
            txtDurationValue.Text = durVal;
            if (!string.IsNullOrEmpty(durUnit))
                try { ddlDurationUnit.SelectedValue = durUnit; } catch { }

            ScriptManager.RegisterStartupScript(this, GetType(), "openEdit", "openModal();", true);
        }

        private void HandleToggle(int id)
        {
            DataTable dt = _bl.GetById(id, SessionId);
            if (dt == null || dt.Rows.Count == 0)
            { ShowToast("Subject not found.", "warning"); BindGrid(); return; }

            bool wasActive = Convert.ToBoolean(dt.Rows[0]["IsActive"]);
            string subjectName = dt.Rows[0]["SubjectName"].ToString();

            _bl.Toggle(id, SessionId);
            LogActivity(UserId, SocietyId, InstituteId, SessionId,
                $"TOGGLE_SUBJECT: Id={id}, Name={subjectName}, NewStatus={(!wasActive ? "Active" : "Inactive")}", id);

            ShowToast($"Subject '{subjectName}' {(wasActive ? "deactivated" : "activated")} successfully.", "success");
            BindGrid();
        }

        private void HandleDelete(int id)
        {
            if (_bl.IsSubjectInUse(id))
            {
                ShowToast($"Cannot delete '{GetSubjectName(id)}': subject is in use. Deactivate instead.", "warning");
                return;
            }

            DataTable dt = _bl.GetById(id, SessionId);
            string name = dt?.Rows.Count > 0 ? dt.Rows[0]["SubjectName"].ToString() : "Subject";
            _bl.Delete(id, SessionId);

            LogActivity(UserId, SocietyId, InstituteId, SessionId, $"DELETE_SUBJECT: Id={id}, Name={name}", id);
            ShowToast($"Subject '{name}' deleted successfully.", "success");

            // Step back if the last item on the last page was deleted
            string search = txtSearch?.Text?.Trim() ?? string.Empty;
            DataTable check = _bl.GetSubjects(InstituteId, SessionId, ViewStateStatus, search);
            int totalPages = check == null || check.Rows.Count == 0
                                   ? 1 : (int)Math.Ceiling((double)check.Rows.Count / PAGE_SIZE);
            if (CurrentPage > totalPages) CurrentPage = totalPages;

            BindGrid();
        }

        // ─── Toggle active / inactive view ────────────────────────────────────────
        protected void btnToggleView_Click(object sender, EventArgs e)
        {
            ViewStateStatus = ViewStateStatus == "1" ? "0" : "1";
            CurrentPage = 1;
            BindGrid();
        }

        // ─── Server-side search (if a search button is wired up) ──────────────────
        protected void btnSearch_Click(object sender, EventArgs e)
        {
            CurrentPage = 1;
            BindGrid();
        }

        // ══════════════════════════════════════════════════════════════════════════
        //  HELPERS
        // ══════════════════════════════════════════════════════════════════════════
        private void ShowToast(string msg, string type = "success")
        {
            msg = msg.Replace("'", "\\'");
            ScriptManager.RegisterStartupScript(this, GetType(),
                "toast_" + Guid.NewGuid().ToString("N").Substring(0, 8),
                $"serverToast('{msg}','{type}');", true);
        }

        private void ReopenModal() =>
            ScriptManager.RegisterStartupScript(this, GetType(), "reopenModal", "openModal();", true);

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

        private void ParseDuration(string full, out string value, out string unit)
        {
            value = string.Empty; unit = "hrs";
            if (string.IsNullOrWhiteSpace(full)) return;
            var parts = full.Trim().Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            if (parts.Length >= 1) value = parts[0];
            if (parts.Length >= 2) unit = parts[1].ToLower();
        }

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