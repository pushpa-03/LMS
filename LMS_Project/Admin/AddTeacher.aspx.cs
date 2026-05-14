//using LearningManagementSystem.BL;
//using LearningManagementSystem.GC;
//using OfficeOpenXml;          // EPPlus — Install-Package EPPlus
//using System;
//using System.Collections.Generic;
//using System.Data;
//using System.IO;
//using System.Text;
//using System.Web.UI;
//using System.Web.UI.WebControls;
//using System.Linq;


//namespace LearningManagementSystem.Admin
//{
//    public partial class AddTeacher : BasePage
//    {
//        // ─── BL Instance ──────────────────────────────────────────────────────────
//        private readonly AddTeacherBL _bl = new AddTeacherBL();

//        // ─── Pagination ───────────────────────────────────────────────────────────
//        private const int PageSize = 10;


//        //private int CurrentPage
//        //{
//        //    get => (int)(ViewState["TeacherPage"] ?? 1);
//        //    set => ViewState["TeacherPage"] = value;
//        //}

//        public int CurrentPage
//        {
//            get
//            {
//                object o = ViewState["CurrentPage"];
//                return o != null ? Convert.ToInt32(o) : 1;
//            }
//            set
//            {
//                ViewState["CurrentPage"] = value;
//                hfCurrentPage.Value = value.ToString();
//            }
//        }


//        // ─── Role ─────────────────────────────────────────────────────────────────
//        private bool IsSuperAdmin =>
//            Session["Role"]?.ToString()
//                .Equals("SuperAdmin", StringComparison.OrdinalIgnoreCase) == true;

//        // ═════════════════════════════════════════════════════════════════════════
//        //  PAGE LOAD
//        // ═════════════════════════════════════════════════════════════════════════
//        protected void Page_Load(object sender, EventArgs e)
//        {
//            if (!IsPostBack)
//            {
//                CurrentPage = 1;

//                ConfigureRoleUI();
//                SetSessionLabel();
//                LoadAllDropdowns();
//                LoadPreviousSessions();
//            }
//            else
//            {
//                if (!string.IsNullOrEmpty(hfCurrentPage.Value))
//                {
//                    int p;

//                    if (int.TryParse(hfCurrentPage.Value, out p))
//                    {
//                        CurrentPage = p;
//                    }
//                }
//            }

//            BindTeachers();
//        }

//        protected override void RaisePostBackEvent(IPostBackEventHandler sourceControl, string eventArgument)
//        {
//            string target = Request["__EVENTTARGET"];

//            if (target == "PageChange")
//            {
//                int page;

//                if (int.TryParse(eventArgument, out page))
//                {
//                    CurrentPage = page;
//                }
//            }

//            base.RaisePostBackEvent(sourceControl, eventArgument);
//        }

//        // ─── Role UI ──────────────────────────────────────────────────────────────
//        private void ConfigureRoleUI()
//        {
//            lblSuperAdminBadge.Visible = IsSuperAdmin;
//            pnlAddBtn.Visible = !IsSuperAdmin;
//            pnlBulkBtn.Visible = !IsSuperAdmin;
//            pnlReenrolBtn.Visible = !IsSuperAdmin;
//        }

//        // ─── Session label ────────────────────────────────────────────────────────
//        private void SetSessionLabel()
//        {
//            lblSessionName.Text = Session["SessionName"]?.ToString() ?? "—";
//        }

//        // ═════════════════════════════════════════════════════════════════════════
//        //  DROPDOWN LOADERS
//        // ═════════════════════════════════════════════════════════════════════════
//        private void LoadAllDropdowns()
//        {
//            LoadStreamDropdowns();
//        }

//        private void LoadStreamDropdowns()
//        {
//            DataTable dt = _bl.GetStreams(InstituteId, SessionId);

//            // Modal stream dropdown
//            ddlStream.Items.Clear();
//            ddlStream.Items.Add(new ListItem("-- Select Stream --", "0"));
//            foreach (DataRow dr in dt.Rows)
//                ddlStream.Items.Add(new ListItem(
//                    dr["StreamName"].ToString(), dr["StreamId"].ToString()));

//            // Filter stream dropdown (header)
//            ddlFilterStream.Items.Clear();
//            ddlFilterStream.Items.Add(new ListItem("All Streams", "0"));
//            foreach (DataRow dr in dt.Rows)
//                ddlFilterStream.Items.Add(new ListItem(
//                    dr["StreamName"].ToString(), dr["StreamId"].ToString()));

//            // Re-enrol new stream dropdown
//            ddlReenrolStream.Items.Clear();
//            ddlReenrolStream.Items.Add(new ListItem("-- Keep Same --", "0"));
//            foreach (DataRow dr in dt.Rows)
//                ddlReenrolStream.Items.Add(new ListItem(
//                    dr["StreamName"].ToString(), dr["StreamId"].ToString()));
//        }

//        private void LoadPreviousSessions()
//        {
//            DataTable dt = _bl.GetPreviousSessions(InstituteId, SessionId);
//            ddlPrevSession.Items.Clear();
//            ddlPrevSession.Items.Add(
//                new ListItem("-- Select Previous Session --", "0"));
//            foreach (DataRow dr in dt.Rows)
//                ddlPrevSession.Items.Add(new ListItem(
//                    dr["SessionName"].ToString(), dr["SessionId"].ToString()));
//        }

//        // ─── Filter postbacks ─────────────────────────────────────────────────────
//        protected void ddlFilterStream_Changed(object sender, EventArgs e)
//        {
//            CurrentPage = 1;
//            BindTeachers();
//        }

//        protected void ddlFilterStatus_Changed(object sender, EventArgs e)
//        {
//            CurrentPage = 1;
//            BindTeachers();
//        }

//        // ═════════════════════════════════════════════════════════════════════════
//        //  BIND REPEATER + GRID + STATS
//        // ═════════════════════════════════════════════════════════════════════════
//        private void BindTeachers()
//        {
//            if (SessionId == 0)
//            {
//                ShowToast("No active academic session. Please configure a session first.", "warning");
//                ClearBindings();
//                return;
//            }

//            int filterStreamId = int.TryParse(ddlFilterStream.SelectedValue, out int fs) ? fs : 0;
//            string filterStatus = ddlFilterStatus.SelectedValue;

//            DataTable dtAll = _bl.GetTeachers(InstituteId, SessionId, filterStreamId, filterStatus);

//            // Stats (always from full set)
//            UpdateStats(dtAll);

//            System.Diagnostics.Debug.WriteLine(
//                "CurrentPage = " + CurrentPage +
//                ", TotalRecords = " + dtAll.Rows.Count
//            );

//            // Pagination
//            //int total = dtAll.Rows.Count;
//            //int totalPages = (int)Math.Ceiling((double)total / PageSize);
//            //if (CurrentPage > totalPages && totalPages > 0) CurrentPage = totalPages;
//            //if (CurrentPage < 1) CurrentPage = 1;

//            //int start = (CurrentPage - 1) * PageSize;
//            //int end = Math.Min(start + PageSize, total);

//            //DataTable dtPage = dtAll.Clone();
//            //for (int i = start; i < end; i++)
//            //    dtPage.ImportRow(dtAll.Rows[i]);

//            //rptTeachers.DataSource = dtPage;
//            //rptTeachers.DataBind();

//            //gvTeachers.DataSource = dtPage;
//            //gvTeachers.DataBind();

//            //// Record count label (via JS)
//            //string countText = total == 0
//            //    ? "No teachers found"
//            //    : $"Showing {(total == 0 ? 0 : start + 1)}–{end} of {total} teachers";

//            //ScriptManager.RegisterStartupScript(this, GetType(), "recCnt",
//            //    $"var rc=document.getElementById('recordCount');if(rc)rc.textContent='{countText}';",
//            //    true);

//            //BuildPager(totalPages);

//            hfTotalRecords.Value = dtAll.Rows.Count.ToString();

//            int totalRecords = dtAll.Rows.Count;

//            int totalPages = (int)Math.Ceiling((double)totalRecords / PageSize);

//            if (totalPages <= 0)
//                totalPages = 1;

//            if (CurrentPage < 1)
//                CurrentPage = 1;

//            if (CurrentPage > totalPages)
//                CurrentPage = totalPages;

//            int skip = (CurrentPage - 1) * PageSize;

//            DataTable paged = dtAll.Clone();

//            foreach (DataRow row in dtAll.AsEnumerable()
//                                         .Skip(skip)
//                                         .Take(PageSize))
//            {
//                paged.ImportRow(row);
//            }

//            gvTeachers.DataSource = paged;
//            gvTeachers.DataBind();

//            rptTeachers.DataSource = paged;
//            rptTeachers.DataBind();



//            ScriptManager.RegisterStartupScript(
//                 this,
//                 GetType(),
//                 "pagination_init",
//                 $"initPagination({totalRecords},{CurrentPage},{PageSize});",
//                 true
//             );
//        }

//        private void ClearBindings()
//        {
//            rptTeachers.DataSource = null; rptTeachers.DataBind();
//            gvTeachers.DataSource = null; gvTeachers.DataBind();
//            UpdateStats(null);
//        }

//        private void UpdateStats(DataTable dt)
//        {
//            if (dt == null || dt.Rows.Count == 0)
//            {
//                lblTotal.Text = lblActive.Text =
//                    lblPending.Text = lblInactive.Text = "0";
//                return;
//            }
//            lblTotal.Text = dt.Rows.Count.ToString();
//            lblActive.Text = dt.Select("IsActive = 1").Length.ToString();
//            lblInactive.Text = dt.Select("IsActive = 0").Length.ToString();
//            lblPending.Text = dt.Select("IsFirstLogin = 1").Length.ToString();
//        }

//        // ═════════════════════════════════════════════════════════════════════════
//        //  PAGINATION
//        // ═════════════════════════════════════════════════════════════════════════
//        //private void BuildPager(int totalPages)
//        //{
//        //    pnlPager.Controls.Clear();
//        //    if (totalPages <= 1) return;

//        //    AddPageBtn("‹ Prev", CurrentPage - 1, CurrentPage == 1);

//        //    int from = Math.Max(1, CurrentPage - 2);
//        //    int to = Math.Min(totalPages, CurrentPage + 2);

//        //    if (from > 1) { AddPageBtn("1", 1, false); if (from > 2) AddEllipsis(); }

//        //    for (int p = from; p <= to; p++)
//        //        AddPageBtn(p.ToString(), p, false, p == CurrentPage);

//        //    if (to < totalPages)
//        //    {
//        //        if (to < totalPages - 1) AddEllipsis();
//        //        AddPageBtn(totalPages.ToString(), totalPages, false);
//        //    }

//        //    AddPageBtn("Next ›", CurrentPage + 1, CurrentPage == totalPages);
//        //}

//        //private void AddPageBtn(string text, int page,
//        //                        bool disabled, bool active = false)
//        //{
//        //    var btn = new LinkButton
//        //    {
//        //        Text = text,
//        //        CommandName = "Page",
//        //        CommandArgument = page.ToString(),
//        //        CssClass = "tch-page-btn" + (active ? " active" : ""),
//        //        Enabled = !disabled
//        //    };
//        //    btn.Click += PageBtn_Click;
//        //    pnlPager.Controls.Add(btn);
//        //}

//        //private void AddEllipsis()
//        //{
//        //    pnlPager.Controls.Add(new LiteralControl(
//        //        "<span class='tch-page-btn' style='cursor:default;pointer-events:none'>…</span>"));
//        //}

//        //protected void PageBtn_Click(object sender, EventArgs e)
//        //{
//        //    if (int.TryParse(((LinkButton)sender).CommandArgument, out int p))
//        //    {
//        //        CurrentPage = p;
//        //        BindTeachers();
//        //    }
//        //}


//        // ═════════════════════════════════════════════════════════════════════════
//        //  SAVE TEACHER  (INSERT / UPDATE)
//        // ═════════════════════════════════════════════════════════════════════════
//        protected void btnSaveTeacher_Click(object sender, EventArgs e)
//        {
//            if (IsSuperAdmin)
//            {
//                ShowToast("Access Denied: SuperAdmin has view-only access.", "warning");
//                return;
//            }
//            if (SessionId == 0)
//            {
//                ShowToast("No active academic session found.", "warning");
//                return;
//            }

//            // ── Collect values ──────────────────────────────────────────────────
//            string fullName = txtFullName.Text.Trim();
//            string username = txtUsername.Text.Trim().ToLower();
//            string email = txtEmail.Text.Trim().ToLower();
//            string password = txtPassword.Text;
//            string contact = txtContact.Text.Trim();
//            string empId = txtEmpId.Text.Trim();
//            string designation = txtDesignation.Text.Trim();
//            string qualification = txtQualification.Text.Trim();
//            string gender = ddlGender.SelectedValue;
//            string address = txtAddress.Text.Trim();
//            string emgName = txtEmgName.Text.Trim();
//            string emgContact = txtEmgContact.Text.Trim();
//            string joinDateStr = txtJoinDate.Text.Trim();
//            string dobStr = txtDOB.Text.Trim();

//            int userId = string.IsNullOrEmpty(hfTeacherUserId.Value)
//                            ? 0 : Convert.ToInt32(hfTeacherUserId.Value);
//            bool isInsert = userId == 0;

//            int streamId = int.TryParse(ddlStream.SelectedValue, out int sid)
//                           && sid > 0 ? sid : 0;

//            // ── Server-side validation ──────────────────────────────────────────
//            if (fullName.Length < 3)
//            { ShowToast("Full name must be at least 3 characters.", "danger"); ReopenModal(); return; }

//            if (!System.Text.RegularExpressions.Regex.IsMatch(username, @"^[a-z0-9_]{3,50}$"))
//            { ShowToast("Username: lowercase, numbers, underscore only (3–50 chars).", "danger"); ReopenModal(); return; }

//            if (!System.Text.RegularExpressions.Regex.IsMatch(email, @"^[^\s@]+@[^\s@]+\.[^\s@]+$"))
//            { ShowToast("Please enter a valid email address.", "danger"); ReopenModal(); return; }

//            if (isInsert && password.Length < 6)
//            { ShowToast("Password must be at least 6 characters.", "danger"); ReopenModal(); return; }

//            if (!System.Text.RegularExpressions.Regex.IsMatch(contact, @"^[0-9+]{10,15}$"))
//            { ShowToast("Enter a valid contact number (10–15 digits).", "danger"); ReopenModal(); return; }

//            if (empId.Length < 2)
//            { ShowToast("Employee ID is required.", "danger"); ReopenModal(); return; }

//            if (streamId == 0)
//            { ShowToast("Please select a stream.", "danger"); ReopenModal(); return; }

//            if (designation.Length < 2)
//            { ShowToast("Designation is required.", "danger"); ReopenModal(); return; }

//            if (!int.TryParse(txtExperience.Text.Trim(), out int expYears) || expYears < 0)
//            { ShowToast("Enter valid experience years.", "danger"); ReopenModal(); return; }

//            if (string.IsNullOrWhiteSpace(joinDateStr))
//            { ShowToast("Joining date is required.", "danger"); ReopenModal(); return; }

//            if (string.IsNullOrWhiteSpace(gender))
//            { ShowToast("Please select gender.", "danger"); ReopenModal(); return; }

//            if (string.IsNullOrWhiteSpace(dobStr))
//            { ShowToast("Date of birth is required.", "danger"); ReopenModal(); return; }

//            if (string.IsNullOrWhiteSpace(emgName))
//            { ShowToast("Emergency contact name is required.", "danger"); ReopenModal(); return; }

//            if (!System.Text.RegularExpressions.Regex.IsMatch(emgContact, @"^[0-9+]{10,15}$"))
//            { ShowToast("Enter a valid emergency contact number.", "danger"); ReopenModal(); return; }

//            if (string.IsNullOrWhiteSpace(address))
//            { ShowToast("Address is required.", "danger"); ReopenModal(); return; }

//            // ── Duplicate checks ────────────────────────────────────────────────
//            if (isInsert && _bl.IsUsernameTaken(username, 0))
//            { ShowToast($"Username '{username}' is already taken.", "danger"); ReopenModal(); return; }

//            if (isInsert && _bl.IsEmailTaken(email, 0))
//            { ShowToast($"Email '{email}' is already registered.", "danger"); ReopenModal(); return; }

//            if (_bl.IsEmpIdTaken(InstituteId, SessionId, empId, userId))
//            { ShowToast($"Employee ID '{empId}' already exists in this session.", "danger"); ReopenModal(); return; }

//            try
//            {
//                var obj = new TeacherGC
//                {
//                    UserId = userId,
//                    SocietyId = SocietyId,
//                    InstituteId = InstituteId,
//                    SessionId = SessionId,

//                    // Account
//                    Username = username,
//                    Email = email,
//                    Password = password,
//                    ContactNo = contact,
//                    IsActive = chkActive.Checked,

//                    // Professional
//                    StreamId = streamId,
//                    EmployeeId = empId,
//                    Designation = designation,
//                    Qualification = string.IsNullOrWhiteSpace(qualification)
//                                    ? "N/A" : qualification,
//                    ExperienceYears = expYears,
//                    JoinedDate = DateTime.TryParse(joinDateStr, out DateTime jd)
//                                    ? jd : DateTime.Today,

//                    // Personal
//                    FullName = fullName,
//                    Gender = gender,
//                    DOB = DateTime.TryParse(dobStr, out DateTime dob)
//                                    ? dob : DateTime.MinValue,
//                    FatherName = txtFatherName.Text.Trim(),
//                    MotherName = txtMotherName.Text.Trim(),
//                    EmgName = emgName,
//                    EmgContact = emgContact,
//                    Address = address,
//                    City = txtCity.Text.Trim(),
//                    Country = txtCountry.Text.Trim(),
//                    Pincode = int.TryParse(txtPincode.Text.Trim(), out int pin)
//                                    ? pin : (int?)null,
//                    Skills = txtSkills.Text.Trim()
//                };

//                if (isInsert)
//                {
//                    int newId = _bl.InsertTeacher(obj);
//                    LogActivity(UserId, SocietyId, InstituteId, SessionId,
//                        $"ADD_TEACHER: Name={fullName}, EmpId={empId}, Username={username}",
//                        newId);
//                    ShowToast($"Teacher '{fullName}' added successfully. " +
//                              "Login credentials created.", "success");
//                }
//                else
//                {
//                    _bl.UpdateTeacher(obj);
//                    LogActivity(UserId, SocietyId, InstituteId, SessionId,
//                        $"UPDATE_TEACHER: UserId={userId}, Name={fullName}", userId);
//                    ShowToast($"Teacher '{fullName}' updated successfully.", "success");
//                }

//                ClearForm();
//                CurrentPage = 1;
//                BindTeachers();
//            }
//            catch (Exception ex)
//            {
//                System.Diagnostics.Debug.WriteLine($"[AddTeacher.Save] {ex}");
//                ShowToast("An unexpected error occurred. Please try again.", "danger");
//                ReopenModal();
//            }
//        }

//        // ═════════════════════════════════════════════════════════════════════════
//        //  REPEATER COMMANDS  (Card View)
//        // ═════════════════════════════════════════════════════════════════════════
//        protected void rptTeachers_ItemCommand(object source, RepeaterCommandEventArgs e)
//        {
//            HandleCommand(e.CommandName, e.CommandArgument?.ToString());
//        }

//        // ═════════════════════════════════════════════════════════════════════════
//        //  GRIDVIEW COMMANDS  (Table View)
//        // ═════════════════════════════════════════════════════════════════════════
//        protected void gvTeachers_RowCommand(object sender, GridViewCommandEventArgs e)
//        {
//            HandleCommand(e.CommandName, e.CommandArgument?.ToString());
//        }

//        // ─── Shared command handler ───────────────────────────────────────────────
//        private void HandleCommand(string name, string arg)
//        {
//            if (IsSuperAdmin && name != "ViewTeacher")
//            {
//                ShowToast("Access Denied: SuperAdmin has view-only access.", "warning");
//                return;
//            }

//            if (!int.TryParse(arg, out int userId) || userId == 0) return;

//            try
//            {
//                switch (name)
//                {
//                    case "ViewTeacher": HandleView(userId); break;
//                    case "EditTeacher": HandleEdit(userId); break;
//                    case "ToggleTeacher": HandleToggle(userId); break;
//                    case "ResetPassword": HandleResetPassword(userId); break;
//                    case "DeleteTeacher": HandleDelete(userId); break;
//                }
//            }
//            catch (Exception ex)
//            {
//                System.Diagnostics.Debug.WriteLine($"[AddTeacher.Command:{name}] {ex}");
//                ShowToast("An unexpected error occurred. Please try again.", "danger");
//            }
//        }

//        // ─── View Profile ─────────────────────────────────────────────────────────
//        private void HandleView(int userId)
//        {
//            DataTable dt = _bl.GetTeacherById(userId, SessionId);
//            if (dt == null || dt.Rows.Count == 0)
//            { ShowToast("Teacher not found.", "warning"); return; }

//            string html = BuildProfileHtml(dt.Rows[0]);
//            string script = $@"
//                document.getElementById('teacherProfileBody').innerHTML = {EscapeJs(html)};
//                new bootstrap.Modal(document.getElementById('ViewTeacherModal')).show();";

//            ScriptManager.RegisterStartupScript(this, GetType(), "viewProf", script, true);
//        }

//        private string BuildProfileHtml(DataRow dr)
//        {
//            string avatarColor = GetAvatarColor(dr["FullName"].ToString());
//            string initials = GetInitials(dr["FullName"].ToString());
//            bool active = Convert.ToBoolean(dr["IsActive"]);
//            bool firstLogin = Convert.ToBoolean(dr["IsFirstLogin"]);

//            return $@"
//            <div class='d-flex align-items-center gap-3 mb-4'>
//                <div style='width:60px;height:60px;border-radius:50%;background:{avatarColor};
//                            display:flex;align-items:center;justify-content:center;
//                            font-weight:700;font-size:20px;color:#fff'>{initials}</div>
//                <div>
//                    <h5 class='fw-bold mb-1'>{dr["FullName"]}</h5>
//                    <div class='d-flex gap-2 flex-wrap'>
//                        <span class='badge bg-primary bg-opacity-10 text-primary'>@{dr["Username"]}</span>
//                        <span class='badge bg-secondary bg-opacity-10 text-secondary'>{dr["EmployeeId"]}</span>
//                        {(active
//                            ? "<span class='badge bg-success bg-opacity-10 text-success'>Active</span>"
//                            : "<span class='badge bg-secondary bg-opacity-10 text-secondary'>Inactive</span>")}
//                        {(firstLogin
//                            ? "<span class='badge bg-warning text-dark'>First Login Pending</span>"
//                            : "")}
//                    </div>
//                </div>
//            </div>
//            <div class='row g-3'>
//                <div class='col-6 col-md-4'>
//                    <div class='pf-field'><span class='pf-lbl'>Email</span>
//                    <span class='pf-val'>{dr["Email"]}</span></div>
//                </div>
//                <div class='col-6 col-md-4'>
//                    <div class='pf-field'><span class='pf-lbl'>Contact</span>
//                    <span class='pf-val'>{dr["ContactNo"]}</span></div>
//                </div>
//                <div class='col-6 col-md-4'>
//                    <div class='pf-field'><span class='pf-lbl'>Stream</span>
//                    <span class='pf-val acad-tag tag-stream'>{dr["StreamName"]}</span></div>
//                </div>
//                <div class='col-6 col-md-4'>
//                    <div class='pf-field'><span class='pf-lbl'>Designation</span>
//                    <span class='pf-val acad-tag tag-desig'>{dr["Designation"]}</span></div>
//                </div>
//                <div class='col-6 col-md-4'>
//                    <div class='pf-field'><span class='pf-lbl'>Experience</span>
//                    <span class='pf-val'>{dr["ExperienceYears"]} yrs</span></div>
//                </div>
//                <div class='col-6 col-md-4'>
//                    <div class='pf-field'><span class='pf-lbl'>Qualification</span>
//                    <span class='pf-val'>{dr["Qualification"]}</span></div>
//                </div>
//                <div class='col-6 col-md-4'>
//                    <div class='pf-field'><span class='pf-lbl'>Gender</span>
//                    <span class='pf-val'>{dr["Gender"]}</span></div>
//                </div>
//                <div class='col-6 col-md-4'>
//                    <div class='pf-field'><span class='pf-lbl'>DOB</span>
//                    <span class='pf-val'>{FormatDate(dr["DOB"])}</span></div>
//                </div>
//                <div class='col-6 col-md-4'>
//                    <div class='pf-field'><span class='pf-lbl'>Joined</span>
//                    <span class='pf-val'>{FormatDate(dr["JoinedDate"])}</span></div>
//                </div>
//                <div class='col-6 col-md-4'>
//                    <div class='pf-field'><span class='pf-lbl'>Father</span>
//                    <span class='pf-val'>{dr["FatherName"]}</span></div>
//                </div>
//                <div class='col-6 col-md-4'>
//                    <div class='pf-field'><span class='pf-lbl'>Mother</span>
//                    <span class='pf-val'>{dr["MotherName"]}</span></div>
//                </div>
//                <div class='col-6 col-md-4'>
//                    <div class='pf-field'><span class='pf-lbl'>Skills</span>
//                    <span class='pf-val'>{dr["Skills"]}</span></div>
//                </div>
//                <div class='col-12'>
//                    <div class='pf-field'><span class='pf-lbl'>Address</span>
//                    <span class='pf-val'>{dr["Address"]}, {dr["City"]}, {dr["Country"]} – {dr["Pincode"]}</span></div>
//                </div>
//                <div class='col-12 col-md-6'>
//                    <div class='pf-field'><span class='pf-lbl'>Emergency Contact</span>
//                    <span class='pf-val'>{dr["EmergencyContactName"]} | {dr["EmergencyContactNo"]}</span></div>
//                </div>
//            </div>";
//        }

//        // ─── Load for Edit ────────────────────────────────────────────────────────
//        private void HandleEdit(int userId)
//        {
//            DataTable dt = _bl.GetTeacherById(userId, SessionId);
//            if (dt == null || dt.Rows.Count == 0)
//            { ShowToast("Teacher not found.", "warning"); return; }

//            DataRow dr = dt.Rows[0];
//            hfTeacherUserId.Value = userId.ToString();

//            // Tab 1 – Account
//            txtFullName.Text = dr["FullName"].ToString();
//            txtUsername.Text = dr["Username"].ToString();
//            txtEmail.Text = dr["Email"].ToString();
//            txtContact.Text = dr["ContactNo"].ToString();
//            txtEmpId.Text = dr["EmployeeId"].ToString();
//            txtPassword.Text = string.Empty; // never pre-fill

//            // Tab 2 – Professional
//            TrySelect(ddlStream, dr["StreamId"].ToString());
//            txtDesignation.Text = dr["Designation"].ToString();
//            txtExperience.Text = dr["ExperienceYears"].ToString();
//            txtQualification.Text = dr["Qualification"].ToString();
//            txtJoinDate.Text = FormatDateInput(dr["JoinedDate"]);
//            chkActive.Checked = Convert.ToBoolean(dr["IsActive"]);

//            // Tab 3 – Personal
//            ddlGender.SelectedValue = dr["Gender"].ToString();
//            txtDOB.Text = FormatDateInput(dr["DOB"]);
//            txtFatherName.Text = dr["FatherName"].ToString();
//            txtMotherName.Text = dr["MotherName"].ToString();
//            txtEmgName.Text = dr["EmergencyContactName"].ToString();
//            txtEmgContact.Text = dr["EmergencyContactNo"].ToString();
//            txtAddress.Text = dr["Address"].ToString();
//            txtCity.Text = dr["City"].ToString();
//            txtCountry.Text = dr["Country"].ToString();
//            txtPincode.Text = dr["Pincode"].ToString();
//            txtSkills.Text = dr["Skills"].ToString();

//            ScriptManager.RegisterStartupScript(this, GetType(),
//                "openEdit", "openModal();", true);
//        }

//        // ─── Toggle Active / Inactive ─────────────────────────────────────────────
//        private void HandleToggle(int userId)
//        {
//            DataTable dt = _bl.GetTeacherById(userId, SessionId);
//            bool wasActive = dt?.Rows.Count > 0 &&
//                             Convert.ToBoolean(dt.Rows[0]["IsActive"]);
//            string name = dt?.Rows.Count > 0
//                            ? dt.Rows[0]["FullName"].ToString() : "Teacher";

//            _bl.ToggleTeacher(userId);
//            LogActivity(UserId, SocietyId, InstituteId, SessionId,
//                $"TOGGLE_TEACHER: UserId={userId}, " +
//                $"NewStatus={(!wasActive ? "Active" : "Inactive")}", userId);

//            ShowToast(
//                $"'{name}' has been {(wasActive ? "deactivated" : "activated")} successfully.",
//                "success");
//            BindTeachers();
//        }

//        // ─── Reset Password ───────────────────────────────────────────────────────
//        private void HandleResetPassword(int userId)
//        {
//            string tempPwd = "Tchr@" + new Random().Next(1000, 9999);
//            _bl.ResetPassword(userId, tempPwd);
//            LogActivity(UserId, SocietyId, InstituteId, SessionId,
//                $"RESET_PWD_TEACHER: UserId={userId}", userId);

//            ShowToast(
//                $"Password reset to: <strong>{tempPwd}</strong> — Share with the teacher securely.",
//                "warning");
//            BindTeachers();
//        }

//        // ─── Delete ───────────────────────────────────────────────────────────────
//        private void HandleDelete(int userId)
//        {
//            bool inUse = _bl.IsTeacherInUse(userId);
//            if (inUse)
//            {
//                ShowToast(
//                    "Cannot delete: teacher has assigned subjects, attendance records, " +
//                    "or quiz records. Deactivate instead.", "warning");
//                return;
//            }

//            DataTable dt = _bl.GetTeacherById(userId, SessionId);
//            string name = dt?.Rows.Count > 0
//                           ? dt.Rows[0]["FullName"].ToString() : "Teacher";

//            _bl.DeleteTeacher(userId, SessionId);
//            LogActivity(UserId, SocietyId, InstituteId, SessionId,
//                $"DELETE_TEACHER: UserId={userId}, Name={name}", userId);

//            ShowToast($"Teacher '{name}' deleted successfully.", "success");
//            CurrentPage = 1;
//            BindTeachers();
//        }

//        // ═════════════════════════════════════════════════════════════════════════
//        //  BULK UPLOAD
//        // ═════════════════════════════════════════════════════════════════════════
//        protected void btnBulkUpload_Click(object sender, EventArgs e)
//        {
//            if (IsSuperAdmin) { ShowToast("Access Denied.", "warning"); return; }
//            if (!fuBulk.HasFile)
//            { ShowToast("Please select an Excel file.", "warning"); return; }

//            string ext = Path.GetExtension(fuBulk.FileName).ToLower();
//            if (ext != ".xlsx" && ext != ".xls")
//            { ShowToast("Only .xlsx / .xls files are supported.", "danger"); return; }

//            int inserted = 0, skipped = 0, errors = 0;
//            var errRows = new List<string>();
//            var sb = new StringBuilder();

//            try
//            {
//                ExcelPackage.License.SetNonCommercialPersonal("LMS_Project");
//                using (var pkg = new ExcelPackage(fuBulk.FileContent))
//                {
//                    var ws = pkg.Workbook.Worksheets[0];
//                    if (ws?.Dimension == null)
//                    { ShowToast("The Excel file appears to be empty.", "warning"); return; }

//                    int rows = ws.Dimension.Rows;

//                    // Column order (same as the manual form / template):
//                    // 1 FullName, 2 Username, 3 Email, 4 Password, 5 ContactNo,
//                    // 6 EmployeeId, 7 StreamName, 8 Designation, 9 ExperienceYears,
//                    // 10 Qualification, 11 JoiningDate, 12 Gender, 13 DOB,
//                    // 14 FatherName, 15 MotherName, 16 Address, 17 City,
//                    // 18 Country, 19 Pincode, 20 Skills

//                    for (int row = 2; row <= rows; row++)
//                    {
//                        string fullName = ws.Cells[row, 1].Text.Trim();
//                        string username = ws.Cells[row, 2].Text.Trim().ToLower();
//                        string email = ws.Cells[row, 3].Text.Trim().ToLower();
//                        string password = ws.Cells[row, 4].Text.Trim();
//                        string contact = ws.Cells[row, 5].Text.Trim();
//                        string empId = ws.Cells[row, 6].Text.Trim();
//                        string streamNm = ws.Cells[row, 7].Text.Trim();
//                        string designation = ws.Cells[row, 8].Text.Trim();
//                        string expStr = ws.Cells[row, 9].Text.Trim();
//                        string qual = ws.Cells[row, 10].Text.Trim();
//                        string joinStr = ws.Cells[row, 11].Text.Trim();
//                        string gender = ws.Cells[row, 12].Text.Trim();
//                        string dobStr = ws.Cells[row, 13].Text.Trim();
//                        string fatherNm = ws.Cells[row, 14].Text.Trim();
//                        string motherNm = ws.Cells[row, 15].Text.Trim();
//                        string address = ws.Cells[row, 16].Text.Trim();
//                        string city = ws.Cells[row, 17].Text.Trim();
//                        string country = ws.Cells[row, 18].Text.Trim();
//                        string pincode = ws.Cells[row, 19].Text.Trim();
//                        string skills = ws.Cells[row, 20].Text.Trim();

//                        // Skip completely blank rows
//                        if (string.IsNullOrWhiteSpace(fullName) &&
//                            string.IsNullOrWhiteSpace(username)) continue;

//                        // Row-level validation
//                        var rowErrs = new List<string>();
//                        if (string.IsNullOrWhiteSpace(fullName)) rowErrs.Add("Full name missing");
//                        if (!System.Text.RegularExpressions.Regex
//                                .IsMatch(username, @"^[a-z0-9_]{3,50}$"))
//                            rowErrs.Add("Invalid username");
//                        if (!System.Text.RegularExpressions.Regex
//                                .IsMatch(email, @"^[^\s@]+@[^\s@]+\.[^\s@]+$"))
//                            rowErrs.Add("Invalid email");
//                        if (password.Length < 6) rowErrs.Add("Password too short");
//                        if (!System.Text.RegularExpressions.Regex
//                                .IsMatch(contact, @"^[0-9+]{10,15}$"))
//                            rowErrs.Add("Invalid contact");
//                        if (string.IsNullOrWhiteSpace(empId)) rowErrs.Add("Employee ID missing");
//                        if (string.IsNullOrWhiteSpace(streamNm)) rowErrs.Add("Stream missing");
//                        if (string.IsNullOrWhiteSpace(designation)) rowErrs.Add("Designation missing");
//                        if (string.IsNullOrWhiteSpace(gender)) rowErrs.Add("Gender missing");
//                        if (!DateTime.TryParse(dobStr, out _)) rowErrs.Add("Invalid DOB");
//                        if (!DateTime.TryParse(joinStr, out _)) rowErrs.Add("Invalid joining date");
//                        if (!int.TryParse(expStr, out _)) rowErrs.Add("Invalid experience");

//                        if (rowErrs.Count > 0)
//                        {
//                            errRows.Add($"Row {row}: {string.Join(", ", rowErrs)}");
//                            errors++;
//                            continue;
//                        }

//                        // Duplicates → skip and report
//                        if (_bl.IsUsernameTaken(username, 0) || _bl.IsEmailTaken(email, 0))
//                        {
//                            errRows.Add($"Row {row}: Duplicate — username/email already exists " +
//                                        $"({username} / {email})");
//                            skipped++;
//                            continue;
//                        }

//                        // Resolve stream FK
//                        int streamId = _bl.GetStreamIdByName(InstituteId, SessionId, streamNm);
//                        if (streamId == 0)
//                        {
//                            errRows.Add($"Row {row}: Stream '{streamNm}' not found");
//                            errors++;
//                            continue;
//                        }

//                        var obj = new TeacherGC
//                        {
//                            SocietyId = SocietyId,
//                            InstituteId = InstituteId,
//                            SessionId = SessionId,
//                            FullName = fullName,
//                            Username = username,
//                            Email = email,
//                            Password = password,
//                            ContactNo = contact,
//                            EmployeeId = empId,
//                            StreamId = streamId,
//                            Designation = designation,
//                            ExperienceYears = int.Parse(expStr),
//                            Qualification = string.IsNullOrWhiteSpace(qual) ? "N/A" : qual,
//                            JoinedDate = DateTime.Parse(joinStr),
//                            Gender = gender,
//                            DOB = DateTime.Parse(dobStr),
//                            FatherName = fatherNm,
//                            MotherName = motherNm,
//                            EmgName = "N/A",
//                            EmgContact = "0000000000",
//                            Address = string.IsNullOrWhiteSpace(address) ? "N/A" : address,
//                            City = city,
//                            Country = country,
//                            Pincode = int.TryParse(pincode, out int pin) ? pin : (int?)null,
//                            Skills = skills,
//                            IsActive = true
//                        };

//                        try
//                        {
//                            _bl.InsertTeacher(obj);
//                            LogActivity(UserId, SocietyId, InstituteId, SessionId,
//                                $"BULK_ADD_TEACHER: Name={fullName}, EmpId={empId}", 0);
//                            inserted++;
//                        }
//                        catch (Exception rowEx)
//                        {
//                            errRows.Add($"Row {row}: DB error — {rowEx.Message}");
//                            errors++;
//                        }
//                    }
//                }

//                // Build result HTML
//                sb.Append("<div class='d-flex gap-3 flex-wrap mb-3'>");
//                sb.Append($"<span class='badge bg-success px-3 py-2'>" +
//                           $"<i class='fa fa-check me-1'></i>{inserted} Added</span>");
//                if (skipped > 0)
//                    sb.Append($"<span class='badge bg-warning text-dark px-3 py-2'>" +
//                               $"<i class='fa fa-ban me-1'></i>{skipped} Skipped (duplicate)</span>");
//                if (errors > 0)
//                    sb.Append($"<span class='badge bg-danger px-3 py-2'>" +
//                               $"<i class='fa fa-times me-1'></i>{errors} Errors</span>");
//                sb.Append("</div>");

//                if (errRows.Count > 0)
//                {
//                    sb.Append("<div class='text-danger small'><strong>Issues:</strong>" +
//                               "<ul class='mb-0'>");
//                    foreach (var err in errRows)
//                        sb.Append($"<li>{err}</li>");
//                    sb.Append("</ul></div>");
//                }

//                litBulkResult.Text = sb.ToString();
//                pnlBulkResult.Visible = true;

//                ShowToast(
//                    $"Bulk upload: {inserted} added, {skipped} skipped, {errors} errors.",
//                    inserted > 0 ? "success" : "warning");

//                if (inserted > 0) { CurrentPage = 1; BindTeachers(); }

//                // Re-open bulk modal to show results
//                ScriptManager.RegisterStartupScript(this, GetType(), "openBulk2",
//                    "new bootstrap.Modal(document.getElementById('BulkModal')).show();",
//                    true);
//            }
//            catch (Exception ex)
//            {
//                System.Diagnostics.Debug.WriteLine($"[BulkTeacher] {ex}");
//                ShowToast("Failed to process file. Ensure it is a valid Excel file.", "danger");
//            }
//        }

//        // ─── Download Template ────────────────────────────────────────────────────
//        protected void lnkDownloadTemplate_Click(object sender, EventArgs e)
//        {
//            ExcelPackage.License.SetNonCommercialPersonal("LMS_Project");
//            using (var pkg = new ExcelPackage())
//            {
//                var ws = pkg.Workbook.Worksheets.Add("Teachers");

//                string[] headers = {
//                    "FullName","Username","Email","Password","ContactNo","EmployeeId",
//                    "StreamName","Designation","ExperienceYears","Qualification",
//                    "JoiningDate","Gender","DOB","FatherName","MotherName",
//                    "Address","City","Country","Pincode","Skills"
//                };

//                for (int i = 0; i < headers.Length; i++)
//                {
//                    var cell = ws.Cells[1, i + 1];
//                    cell.Value = headers[i];
//                    cell.Style.Font.Bold = true;
//                    cell.Style.Fill.PatternType =
//                        OfficeOpenXml.Style.ExcelFillStyle.Solid;
//                    cell.Style.Fill.BackgroundColor
//                        .SetColor(System.Drawing.Color.FromArgb(79, 70, 229));
//                    cell.Style.Font.Color
//                        .SetColor(System.Drawing.Color.White);
//                    ws.Column(i + 1).Width = 20;
//                }

//                // Sample row
//                ws.Cells[2, 1].Value = "Dr. Priya Sharma";
//                ws.Cells[2, 2].Value = "priya_sharma25";
//                ws.Cells[2, 3].Value = "priya@school.edu";
//                ws.Cells[2, 4].Value = "Pass@1234";
//                ws.Cells[2, 5].Value = "9876543210";
//                ws.Cells[2, 6].Value = "EMP2025001";
//                ws.Cells[2, 7].Value = "Computer Science";
//                ws.Cells[2, 8].Value = "Associate Professor";
//                ws.Cells[2, 9].Value = "8";
//                ws.Cells[2, 10].Value = "M.Tech";
//                ws.Cells[2, 11].Value = "2025-07-01";
//                ws.Cells[2, 12].Value = "Female";
//                ws.Cells[2, 13].Value = "1990-04-15";
//                ws.Cells[2, 14].Value = "Rajesh Sharma";
//                ws.Cells[2, 15].Value = "Sunita Sharma";
//                ws.Cells[2, 16].Value = "45 MG Road, Pune";
//                ws.Cells[2, 17].Value = "Pune";
//                ws.Cells[2, 18].Value = "India";
//                ws.Cells[2, 19].Value = "411001";
//                ws.Cells[2, 20].Value = "Python, Machine Learning";

//                Response.Clear();
//                Response.ContentType =
//                    "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
//                Response.AddHeader("Content-Disposition",
//                    "attachment; filename=TeacherUploadTemplate.xlsx");
//                Response.BinaryWrite(pkg.GetAsByteArray());
//                Response.End();
//            }
//        }

//        // ═════════════════════════════════════════════════════════════════════════
//        //  RE-ENROL
//        // ═════════════════════════════════════════════════════════════════════════
//        protected void ddlPrevSession_Changed(object sender, EventArgs e)
//        {
//            int prevSessionId = int.TryParse(
//                ddlPrevSession.SelectedValue, out int ps) ? ps : 0;

//            if (prevSessionId == 0)
//            {
//                rptPrevTeachers.DataSource = null;
//                rptPrevTeachers.DataBind();
//                return;
//            }

//            // Load teachers from previous session (all status)
//            DataTable dt = _bl.GetTeachers(InstituteId, prevSessionId, 0, "All");
//            rptPrevTeachers.DataSource = dt;
//            rptPrevTeachers.DataBind();

//            // Re-open the re-enrol modal (postback closes it)
//            ScriptManager.RegisterStartupScript(this, GetType(), "openReenrol2",
//                "new bootstrap.Modal(document.getElementById('ReenrolModal')).show();",
//                true);
//        }

//        protected void btnReenrol_Click(object sender, EventArgs e)
//        {
//            if (IsSuperAdmin) { ShowToast("Access Denied.", "warning"); return; }

//            string ids = hfReenrolIds.Value;
//            if (string.IsNullOrWhiteSpace(ids))
//            { ShowToast("No teachers selected for re-enrolment.", "warning"); return; }

//            int prevSessionId = int.TryParse(
//                ddlPrevSession.SelectedValue, out int ps) ? ps : 0;
//            if (prevSessionId == 0)
//            { ShowToast("Please select a previous session.", "warning"); return; }

//            int newStreamId = int.TryParse(
//                ddlReenrolStream.SelectedValue, out int ns) && ns > 0 ? ns : 0;

//            int[] userIds = Array.ConvertAll(ids.Split(','), int.Parse);
//            int enrolled = 0, skippedRe = 0;

//            foreach (int uid in userIds)
//            {
//                try
//                {
//                    bool ok = _bl.ReenrolTeacher(
//                        uid, prevSessionId, SessionId,
//                        SocietyId, InstituteId,
//                        newStreamId > 0 ? newStreamId : (int?)null);

//                    if (ok)
//                    {
//                        LogActivity(UserId, SocietyId, InstituteId, SessionId,
//                            $"REENROL_TEACHER: UserId={uid}", uid);
//                        enrolled++;
//                    }
//                    else skippedRe++;
//                }
//                catch { skippedRe++; }
//            }

//            ShowToast(
//                $"Re-enrolment done: {enrolled} enrolled, " +
//                $"{skippedRe} skipped (already in session).",
//                "success");
//            CurrentPage = 1;
//            BindTeachers();
//        }

//        // ═════════════════════════════════════════════════════════════════════════
//        //  HELPERS  (also called by ASPX inline expressions)
//        // ═════════════════════════════════════════════════════════════════════════
//        //protected string GetInitials(string fullName)
//        //{
//        //    if (string.IsNullOrWhiteSpace(fullName)) return "?";
//        //    var parts = fullName.Trim()
//        //        .Split(new char[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
//        //    if (parts.Length == 1)
//        //        return parts[0].Substring(0, Math.Min(2, parts[0].Length)).ToUpper();
//        //    return (parts[0][0].ToString() +
//        //            parts[parts.Length - 1][0].ToString()).ToUpper();
//        //}

//        //private static readonly string[] AvatarColors = {
//        //    "#4f46e5","#0891b2","#059669","#d97706",
//        //    "#dc2626","#7c3aed","#db2777","#0d9488"
//        //};

//        //protected string GetAvatarColor(string name)
//        //{
//        //    if (string.IsNullOrWhiteSpace(name)) return AvatarColors[0];
//        //    return AvatarColors[Math.Abs(name.GetHashCode()) % AvatarColors.Length];
//        //}

//        //private static readonly string[] StreamColors = {
//        //    "#4f46e5","#0891b2","#059669","#d97706","#7c3aed","#dc2626"
//        //};

//        //protected string GetStreamColor(object streamId)
//        //{
//        //    if (streamId == null) return StreamColors[0];
//        //    return StreamColors[Math.Abs(streamId.GetHashCode()) % StreamColors.Length];
//        //}

//        // ─── Helper Methods for UI ────────────────────────────────────────────────
//        // PLACE HELPERS HERE (Inside the class, but outside other methods)
//        protected string GetInitials(string name)
//        {
//            if (string.IsNullOrWhiteSpace(name)) return "T";
//            string[] parts = name.Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
//            if (parts.Length == 1) return parts[0].Substring(0, Math.Min(2, parts[0].Length)).ToUpper();
//            return (parts[0][0].ToString() + parts[parts.Length - 1][0].ToString()).ToUpper();
//        }

//        protected string GetAvatarColor(string name)
//        {
//            string[] colors = { "#4f46e5", "#0891b2", "#059669", "#d97706", "#2563eb", "#7c3aed", "#db2777" };
//            if (string.IsNullOrWhiteSpace(name)) return colors[0];
//            int hash = Math.Abs(name.GetHashCode());
//            return colors[hash % colors.Length];
//        }

//        protected string GetStreamColor(string streamName)
//        {
//            if (string.IsNullOrWhiteSpace(streamName)) return "bg-secondary";
//            streamName = streamName.ToLower();
//            if (streamName.Contains("science")) return "bg-primary";
//            if (streamName.Contains("commerce")) return "bg-success";
//            return "bg-secondary";
//        }
//        private void ClearForm()
//        {
//            hfTeacherUserId.Value = string.Empty;
//            txtFullName.Text = txtUsername.Text = txtEmail.Text = string.Empty;
//            txtPassword.Text = txtContact.Text = txtEmpId.Text = string.Empty;
//            txtDesignation.Text = txtExperience.Text = txtQualification.Text = string.Empty;
//            txtJoinDate.Text = txtDOB.Text = txtFatherName.Text = string.Empty;
//            txtMotherName.Text = txtEmgName.Text = txtEmgContact.Text = string.Empty;
//            txtAddress.Text = txtCity.Text = txtCountry.Text = string.Empty;
//            txtPincode.Text = txtSkills.Text = string.Empty;
//            ddlGender.SelectedIndex = 0;
//            ddlStream.SelectedIndex = 0;
//            chkActive.Checked = true;
//        }

//        private void ReopenModal()
//        {
//            ScriptManager.RegisterStartupScript(this, GetType(),
//                "reopen_" + Guid.NewGuid().ToString("N").Substring(0, 6),
//                "openModal();", true);
//        }

//        private void ShowToast(string msg, string type = "success")
//        {
//            msg = msg.Replace("'", "\\'")
//                     .Replace("\r", "").Replace("\n", "");
//            ScriptManager.RegisterStartupScript(this, GetType(),
//                "toast_" + Guid.NewGuid().ToString("N").Substring(0, 8),
//                $"serverToast('{msg}', '{type}');", true);
//        }

//        private void TrySelect(DropDownList ddl, string value)
//        {
//            if (ddl == null || string.IsNullOrWhiteSpace(value))
//                return;

//            ddl.ClearSelection();

//            ListItem item = ddl.Items.FindByValue(value);

//            if (item != null)
//                item.Selected = true;
//        }

//        private string FormatDate(object val) =>
//            val != null && DateTime.TryParse(val.ToString(), out DateTime d)
//                ? d.ToString("dd MMM yyyy") : "—";

//        private string FormatDateInput(object val) =>
//            val != null && DateTime.TryParse(val.ToString(), out DateTime d)
//                ? d.ToString("yyyy-MM-dd") : string.Empty;

//        private string EscapeJs(string html) =>
//            "`" + html.Replace("`", "\\`").Replace("${", "\\${") + "`";
//    }
//}



//-----------------------------------------------------------------------------------------------------------------


using LearningManagementSystem.BL;
using LearningManagementSystem.GC;
using OfficeOpenXml;
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace LearningManagementSystem.Admin
{
    public partial class AddTeacher : BasePage
    {
        private readonly AddTeacherBL _bl = new AddTeacherBL();

        // ─── Pagination ───────────────────────────────────────────────────────
        private const int PageSize = 10;

        public int CurrentPage
        {
            get => (int)(ViewState["TeacherPage"] ?? 1);
            set => ViewState["TeacherPage"] = value;
        }

        private bool IsSuperAdmin =>
            Session["Role"]?.ToString()
                .Equals("SuperAdmin", StringComparison.OrdinalIgnoreCase) == true;

        // ═════════════════════════════════════════════════════════════════════
        //  PAGE LOAD  — one-time init only
        // ═════════════════════════════════════════════════════════════════════
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                ConfigureRoleUI();
                SetSessionLabel();
                LoadAllDropdowns();
                LoadPreviousSessions();
                CurrentPage = 1;
            }
            // ★ CRITICAL: BindTeachers() must run on EVERY request — not just first load.
            // BuildPager() adds LinkButton controls dynamically to pnlPager.
            // ASP.NET WebForms rule: dynamically added controls must be re-added
            // to the control tree in Page_Load on every postback so their events
            // can be found and fired by the framework before event processing.
            // Moving this to Page_PreRender (after event processing) is too late —
            // the button Click events would never fire.
            if (SessionId > 0)
                BindTeachers();
        }

        private void ConfigureRoleUI()
        {
            lblSuperAdminBadge.Visible = IsSuperAdmin;
            pnlAddBtn.Visible = !IsSuperAdmin;
            pnlBulkBtn.Visible = !IsSuperAdmin;
            pnlReenrolBtn.Visible = !IsSuperAdmin;
        }

        private void SetSessionLabel()
        {
            lblSessionName.Text = Session["SessionName"]?.ToString() ?? "—";
        }

        // ═════════════════════════════════════════════════════════════════════
        //  HELPER METHODS — must be protected for ASPX <%# %> expressions
        // ═════════════════════════════════════════════════════════════════════
        private static readonly string[] _avatarColors = {
            "#4f46e5","#0891b2","#059669","#d97706",
            "#dc2626","#7c3aed","#db2777","#0d9488"
        };
        private static readonly string[] _streamColors = {
            "#4f46e5","#0891b2","#059669","#d97706","#7c3aed","#dc2626"
        };

        protected string GetAvatarColor(string name)
        {
            if (string.IsNullOrWhiteSpace(name)) return _avatarColors[0];
            return _avatarColors[Math.Abs(name.GetHashCode()) % _avatarColors.Length];
        }
        protected string GetStreamColor(object streamId)
        {
            if (streamId == null) return _streamColors[0];
            return _streamColors[Math.Abs(streamId.GetHashCode()) % _streamColors.Length];
        }
        protected string GetInitials(string fullName)
        {
            if (string.IsNullOrWhiteSpace(fullName)) return "?";
            var parts = fullName.Trim().Split(new char[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            if (parts.Length == 1) return parts[0].Substring(0, Math.Min(2, parts[0].Length)).ToUpper();
            return (parts[0][0].ToString() + parts[parts.Length - 1][0].ToString()).ToUpper();
        }

        // ═════════════════════════════════════════════════════════════════════
        //  DROPDOWNS
        // ═════════════════════════════════════════════════════════════════════
        private void LoadAllDropdowns()
        {
            DataTable dt = _bl.GetStreams(InstituteId, SessionId);

            ddlStream.Items.Clear();
            ddlStream.Items.Add(new ListItem("-- Select Stream --", "0"));
            foreach (DataRow dr in dt.Rows)
                ddlStream.Items.Add(new ListItem(dr["StreamName"].ToString(), dr["StreamId"].ToString()));

            ddlFilterStream.Items.Clear();
            ddlFilterStream.Items.Add(new ListItem("All Streams", "0"));
            foreach (DataRow dr in dt.Rows)
                ddlFilterStream.Items.Add(new ListItem(dr["StreamName"].ToString(), dr["StreamId"].ToString()));

            ddlReenrolStream.Items.Clear();
            ddlReenrolStream.Items.Add(new ListItem("-- Keep Same --", "0"));
            foreach (DataRow dr in dt.Rows)
                ddlReenrolStream.Items.Add(new ListItem(dr["StreamName"].ToString(), dr["StreamId"].ToString()));
        }

        private void LoadPreviousSessions()
        {
            DataTable dt = _bl.GetPreviousSessions(InstituteId, SessionId);
            ddlPrevSession.Items.Clear();
            ddlPrevSession.Items.Add(new ListItem("-- Select Previous Session --", "0"));
            foreach (DataRow dr in dt.Rows)
                ddlPrevSession.Items.Add(new ListItem(dr["SessionName"].ToString(), dr["SessionId"].ToString()));
        }

        protected void ddlFilterStream_Changed(object sender, EventArgs e)
        {
            CurrentPage = 1;
        }
        protected void ddlFilterStatus_Changed(object sender, EventArgs e)
        {
            CurrentPage = 1;
        }

        // ═════════════════════════════════════════════════════════════════════
        //  BIND GRID + STATS  (called from Page_PreRender every request)
        // ═════════════════════════════════════════════════════════════════════
        private void BindTeachers()
        {
            if (SessionId == 0)
            {
                ShowToast("No active academic session. Please configure a session first.", "warning");
                gvTeachers.DataSource = null; gvTeachers.DataBind();
                
                UpdateStats(null);
                pnlPager.Controls.Clear();
                return;
            }

            int filterStreamId = int.TryParse(ddlFilterStream.SelectedValue, out int fs) ? fs : 0;
            string filterStatus = ddlFilterStatus.SelectedValue;
            DataTable dtAll = _bl.GetTeachers(InstituteId, SessionId, filterStreamId, filterStatus);

            UpdateStats(dtAll);

            int total = dtAll.Rows.Count;
            int totalPages = (int)Math.Ceiling((double)total / PageSize);
            if (totalPages < 1) totalPages = 1;
            if (CurrentPage > totalPages) CurrentPage = totalPages;
            if (CurrentPage < 1) CurrentPage = 1;

            int start = (CurrentPage - 1) * PageSize;
            int end = Math.Min(start + PageSize, total);

            DataTable dtPage = dtAll.Clone();
            for (int i = start; i < end; i++)
                dtPage.ImportRow(dtAll.Rows[i]);

           
            gvTeachers.DataSource = dtPage;
            gvTeachers.DataBind();

            // Record count
            string countText = total == 0
                ? "No teachers found"
                : $"Showing {start + 1}–{end} of {total} teachers";
            ScriptManager.RegisterStartupScript(this, GetType(), "recCnt",
                $"var rc=document.getElementById('recordCount');if(rc)rc.textContent='{countText}';var rm=document.getElementById('recordCountMobile');if(rm)rm.textContent='{countText}';", true);

            // Pagination info
            string pageInfo = total > 0
                ? $"Page {CurrentPage} of {totalPages}"
                : "";
            ScriptManager.RegisterStartupScript(this, GetType(), "pgInfo",
                $"var pi=document.getElementById('pagerInfo');if(pi)pi.textContent='{pageInfo}';", true);

            BuildPager(totalPages);

            if (IsSuperAdmin)
                ScriptManager.RegisterStartupScript(this, GetType(), "hideSA",
                    "document.querySelectorAll('.tbl-act-btn:not(.act-view)').forEach(b=>b.style.display='none');", true);
        }

        private void UpdateStats(DataTable dt)
        {
            if (dt == null || dt.Rows.Count == 0)
            { lblTotal.Text = lblActive.Text = lblPending.Text = lblInactive.Text = "0"; return; }
            lblTotal.Text = dt.Rows.Count.ToString();
            lblActive.Text = dt.Select("IsActive = 1").Length.ToString();
            lblInactive.Text = dt.Select("IsActive = 0").Length.ToString();
            lblPending.Text = dt.Select("IsFirstLogin = 1").Length.ToString();
        }

        // ═════════════════════════════════════════════════════════════════════
        //  PAGINATION — server-side LinkButton pager (same as AddStudent)
        // ═════════════════════════════════════════════════════════════════════
        private void BuildPager(int totalPages)
        {
            pnlPager.Controls.Clear();
            if (totalPages <= 1) return;

            // «  First
            AddPagerBtn("«", 1, CurrentPage == 1);
            // ‹  Prev
            AddPagerBtn("‹", CurrentPage - 1, CurrentPage == 1);

            int from = Math.Max(1, CurrentPage - 2);
            int to = Math.Min(totalPages, CurrentPage + 2);

            if (from > 1)
            {
                AddPagerBtn("1", 1, false);
                if (from > 2)
                    pnlPager.Controls.Add(new LiteralControl(
                        "<span class='tch-page-btn' style='cursor:default;pointer-events:none;border:none'>…</span>"));
            }

            for (int p = from; p <= to; p++)
                AddPagerBtn(p.ToString(), p, false, p == CurrentPage);

            if (to < totalPages)
            {
                if (to < totalPages - 1)
                    pnlPager.Controls.Add(new LiteralControl(
                        "<span class='tch-page-btn' style='cursor:default;pointer-events:none;border:none'>…</span>"));
                AddPagerBtn(totalPages.ToString(), totalPages, false);
            }

            // ›  Next
            AddPagerBtn("›", CurrentPage + 1, CurrentPage == totalPages);
            // »  Last
            AddPagerBtn("»", totalPages, CurrentPage == totalPages);
        }

        private void AddPagerBtn(string text, int page, bool disabled, bool active = false)
        {
            var btn = new LinkButton
            {
                Text = text,
                CommandArgument = page.ToString(),
                CssClass = "tch-page-btn"
                                  + (active ? " active" : "")
                                  + (disabled ? " disabled" : ""),
                Enabled = !disabled
            };
            btn.Click += PageBtn_Click;
            pnlPager.Controls.Add(btn);
        }

        protected void PageBtn_Click(object sender, EventArgs e)
        {
            if (int.TryParse(((LinkButton)sender).CommandArgument, out int p))
            {
                CurrentPage = p;
                BindTeachers(); // Re-bind with new page
            }
        }

        // ═════════════════════════════════════════════════════════════════════
        //  SAVE (INSERT / UPDATE)
        // ═════════════════════════════════════════════════════════════════════
        protected void btnSaveTeacher_Click(object sender, EventArgs e)
        {
            if (IsSuperAdmin) { ShowToast("Access Denied: SuperAdmin has view-only access.", "warning"); return; }
            if (SessionId == 0) { ShowToast("No active academic session found.", "warning"); return; }

            string fullName = txtFullName.Text.Trim();
            string username = txtUsername.Text.Trim().ToLower();
            string email = txtEmail.Text.Trim().ToLower();
            string password = txtPassword.Text;
            string contact = txtContact.Text.Trim();
            string empId = txtEmpId.Text.Trim();
            string designation = txtDesignation.Text.Trim();
            string qual = txtQualification.Text.Trim();
            string gender = ddlGender.SelectedValue;
            string address = txtAddress.Text.Trim();
            string emgName = txtEmgName.Text.Trim();
            string emgContact = txtEmgContact.Text.Trim();
            string joinDateStr = txtJoinDate.Text.Trim();
            string dobStr = txtDOB.Text.Trim();

            int userId = string.IsNullOrEmpty(hfTeacherUserId.Value) ? 0 : Convert.ToInt32(hfTeacherUserId.Value);
            bool isInsert = userId == 0;
            int streamId = int.TryParse(ddlStream.SelectedValue, out int sid) && sid > 0 ? sid : 0;

            // ── Validation ───────────────────────────────────────────────────
            if (fullName.Length < 3) { ShowToast("Full name must be at least 3 characters.", "danger"); ReopenModal(); return; }
            if (!System.Text.RegularExpressions.Regex.IsMatch(username, @"^[a-z0-9_]{3,50}$"))
            { ShowToast("Username: lowercase, numbers, underscore only (3–50 chars).", "danger"); ReopenModal(); return; }
            if (!System.Text.RegularExpressions.Regex.IsMatch(email, @"^[^\s@]+@[^\s@]+\.[^\s@]+$"))
            { ShowToast("Please enter a valid email address.", "danger"); ReopenModal(); return; }
            if (isInsert && password.Length < 6) { ShowToast("Password must be at least 6 characters.", "danger"); ReopenModal(); return; }
            if (!System.Text.RegularExpressions.Regex.IsMatch(contact, @"^[0-9+]{10,15}$"))
            { ShowToast("Enter a valid contact number (10–15 digits).", "danger"); ReopenModal(); return; }
            if (empId.Length < 2) { ShowToast("Employee ID is required.", "danger"); ReopenModal(); return; }
            if (streamId == 0) { ShowToast("Please select a stream.", "danger"); ReopenModal(); return; }
            if (designation.Length < 2) { ShowToast("Designation is required.", "danger"); ReopenModal(); return; }
            if (!int.TryParse(txtExperience.Text.Trim(), out int expYears) || expYears < 0)
            { ShowToast("Enter valid experience years.", "danger"); ReopenModal(); return; }
            if (string.IsNullOrWhiteSpace(joinDateStr)) { ShowToast("Joining date is required.", "danger"); ReopenModal(); return; }

            // Joining date validation: not future (more than 1 year), not too old
            if (DateTime.TryParse(joinDateStr, out DateTime joinDate))
            {
                if (joinDate > DateTime.Today.AddYears(1))
                { ShowToast("Joining date cannot be more than 1 year in the future.", "danger"); ReopenModal(); return; }
                if (joinDate < DateTime.Today.AddYears(-60))
                { ShowToast("Joining date seems too far in the past. Please verify.", "danger"); ReopenModal(); return; }
            }

            if (string.IsNullOrWhiteSpace(gender)) { ShowToast("Please select gender.", "danger"); ReopenModal(); return; }
            if (string.IsNullOrWhiteSpace(dobStr)) { ShowToast("Date of birth is required.", "danger"); ReopenModal(); return; }

            // DOB: teacher age must be 18–80
            if (!DateTime.TryParse(dobStr, out DateTime dob))
            { ShowToast("Invalid date of birth.", "danger"); ReopenModal(); return; }
            int age = (int)((DateTime.Today - dob).TotalDays / 365.25);
            if (age < 18) { ShowToast("Teacher must be at least 18 years old.", "danger"); ReopenModal(); return; }
            if (age > 80) { ShowToast("Date of birth seems incorrect — age exceeds 80 years.", "danger"); ReopenModal(); return; }

            if (string.IsNullOrWhiteSpace(emgName)) { ShowToast("Emergency contact name is required.", "danger"); ReopenModal(); return; }
            if (!System.Text.RegularExpressions.Regex.IsMatch(emgContact, @"^[0-9+]{10,15}$"))
            { ShowToast("Enter a valid emergency contact number.", "danger"); ReopenModal(); return; }
            if (string.IsNullOrWhiteSpace(address)) { ShowToast("Address is required.", "danger"); ReopenModal(); return; }

            // ── Duplicate checks ─────────────────────────────────────────────
            if (isInsert && _bl.IsUsernameTaken(username, 0))
            { ShowToast($"Username '{username}' is already taken.", "danger"); ReopenModal(); return; }
            if (isInsert && _bl.IsEmailTaken(email, 0))
            { ShowToast($"Email '{email}' is already registered.", "danger"); ReopenModal(); return; }
            if (_bl.IsEmpIdTaken(InstituteId, SessionId, empId, userId))
            { ShowToast($"Employee ID '{empId}' already exists in this session.", "danger"); ReopenModal(); return; }

            try
            {
                var obj = new TeacherGC
                {
                    UserId = userId,
                    SocietyId = SocietyId,
                    InstituteId = InstituteId,
                    SessionId = SessionId,
                    Username = username,
                    Email = email,
                    Password = password,
                    ContactNo = contact,
                    IsActive = chkActive.Checked,
                    StreamId = streamId,
                    EmployeeId = empId,
                    Designation = designation,
                    Qualification = string.IsNullOrWhiteSpace(qual) ? "N/A" : qual,
                    ExperienceYears = expYears,
                    JoinedDate = DateTime.TryParse(joinDateStr, out DateTime jd) ? jd : DateTime.Today,
                    FullName = fullName,
                    Gender = gender,
                    DOB = dob,
                    FatherName = txtFatherName.Text.Trim(),
                    MotherName = txtMotherName.Text.Trim(),
                    EmgName = emgName,
                    EmgContact = emgContact,
                    Address = address,
                    City = txtCity.Text.Trim(),
                    Country = txtCountry.Text.Trim(),
                    Pincode = int.TryParse(txtPincode.Text.Trim(), out int pin) ? pin : (int?)null,
                    Skills = txtSkills.Text.Trim()
                };

                if (isInsert)
                {
                    int newId = _bl.InsertTeacher(obj);
                    LogActivity(UserId, SocietyId, InstituteId, SessionId, $"ADD_TEACHER: Name={fullName}, EmpId={empId}", newId);
                    ShowToast($"Teacher '{fullName}' added successfully. Login credentials created.", "success");
                }
                else
                {
                    _bl.UpdateTeacher(obj);
                    LogActivity(UserId, SocietyId, InstituteId, SessionId, $"UPDATE_TEACHER: UserId={userId}, Name={fullName}", userId);
                    ShowToast($"Teacher '{fullName}' updated successfully.", "success");
                }

                ClearForm();
                CurrentPage = 1;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[AddTeacher.Save] {ex}");
                ShowToast("An unexpected error occurred. Please try again.", "danger");
                ReopenModal();
            }
        }

        // ═════════════════════════════════════════════════════════════════════
        //  ROW COMMANDS
        // ═════════════════════════════════════════════════════════════════════
        protected void rptTeachers_ItemCommand(object source, RepeaterCommandEventArgs e)
        { HandleCommand(e.CommandName, e.CommandArgument?.ToString()); }

        protected void gvTeachers_RowCommand(object sender, GridViewCommandEventArgs e)
        { HandleCommand(e.CommandName, e.CommandArgument?.ToString()); }

        private void HandleCommand(string name, string arg)
        {
            if (IsSuperAdmin && name != "ViewTeacher")
            { ShowToast("Access Denied: SuperAdmin has view-only access.", "warning"); return; }
            if (!int.TryParse(arg, out int userId) || userId == 0) return;
            try
            {
                switch (name)
                {
                    case "ViewTeacher": HandleView(userId); break;
                    case "EditTeacher": HandleEdit(userId); break;
                    case "ToggleTeacher": HandleToggle(userId); break;
                    case "ResetPassword": HandleResetPassword(userId); break;
                    case "DeleteTeacher": HandleDelete(userId); break;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[AddTeacher.Command:{name}] {ex}");
                ShowToast("An unexpected error occurred. Please try again.", "danger");
            }
        }

        private void HandleView(int userId)
        {
            DataTable dt = _bl.GetTeacherById(userId, SessionId);
            if (dt == null || dt.Rows.Count == 0) { ShowToast("Teacher not found.", "warning"); return; }
            DataRow dr = dt.Rows[0];
            string html = BuildProfileHtml(dr);
            // Pass userId to JS so "Teacher Details" button gets correct link
            string script = $@"
                document.getElementById('teacherProfileBody').innerHTML = {EscapeJs(html)};
                var lnk=document.getElementById('btnViewDetails');
                if(lnk) lnk.href='TeacherDetails.aspx?userId={userId}';
                new bootstrap.Modal(document.getElementById('ViewTeacherModal')).show();";
            ScriptManager.RegisterStartupScript(this, GetType(), "viewProf", script, true);
        }

        private string BuildProfileHtml(DataRow dr)
        {
            string avatarColor = GetAvatarColor(dr["FullName"].ToString());
            string initials = GetInitials(dr["FullName"].ToString());
            bool active = Convert.ToBoolean(dr["IsActive"]);
            bool firstLogin = Convert.ToBoolean(dr["IsFirstLogin"]);

            return $@"
            <div class='d-flex align-items-center gap-3 mb-4'>
                <div style='width:60px;height:60px;border-radius:50%;background:{avatarColor};
                            display:flex;align-items:center;justify-content:center;
                            font-weight:700;font-size:20px;color:#fff'>{initials}</div>
                <div>
                    <h5 class='fw-bold mb-1'>{dr["FullName"]}</h5>
                    <div class='d-flex gap-2 flex-wrap'>
                        <span class='badge bg-primary bg-opacity-10 text-primary'>@{dr["Username"]}</span>
                        <span class='badge bg-secondary bg-opacity-10 text-secondary'>{dr["EmployeeId"]}</span>
                        {(active ? "<span class='badge bg-success bg-opacity-10 text-success'>Active</span>"
                                 : "<span class='badge bg-secondary bg-opacity-10 text-secondary'>Inactive</span>")}
                        {(firstLogin ? "<span class='badge bg-warning text-dark'>First Login Pending</span>" : "")}
                    </div>
                </div>
            </div>
            <div class='row g-3'>
                <div class='col-6 col-md-4'><div class='pf-field'><span class='pf-lbl'>Email</span><span class='pf-val'>{dr["Email"]}</span></div></div>
                <div class='col-6 col-md-4'><div class='pf-field'><span class='pf-lbl'>Contact</span><span class='pf-val'>{dr["ContactNo"]}</span></div></div>
                <div class='col-6 col-md-4'><div class='pf-field'><span class='pf-lbl'>Stream</span><span class='pf-val acad-tag tag-stream'>{dr["StreamName"]}</span></div></div>
                <div class='col-6 col-md-4'><div class='pf-field'><span class='pf-lbl'>Designation</span><span class='pf-val acad-tag tag-desig'>{dr["Designation"]}</span></div></div>
                <div class='col-6 col-md-4'><div class='pf-field'><span class='pf-lbl'>Experience</span><span class='pf-val'>{dr["ExperienceYears"]} yrs</span></div></div>
                <div class='col-6 col-md-4'><div class='pf-field'><span class='pf-lbl'>Qualification</span><span class='pf-val'>{dr["Qualification"]}</span></div></div>
                <div class='col-6 col-md-4'><div class='pf-field'><span class='pf-lbl'>Gender</span><span class='pf-val'>{dr["Gender"]}</span></div></div>
                <div class='col-6 col-md-4'><div class='pf-field'><span class='pf-lbl'>DOB</span><span class='pf-val'>{FormatDate(dr["DOB"])}</span></div></div>
                <div class='col-6 col-md-4'><div class='pf-field'><span class='pf-lbl'>Joined</span><span class='pf-val'>{FormatDate(dr["JoinedDate"])}</span></div></div>
                <div class='col-6 col-md-4'><div class='pf-field'><span class='pf-lbl'>Father</span><span class='pf-val'>{dr["FatherName"]}</span></div></div>
                <div class='col-6 col-md-4'><div class='pf-field'><span class='pf-lbl'>Mother</span><span class='pf-val'>{dr["MotherName"]}</span></div></div>
                <div class='col-6 col-md-4'><div class='pf-field'><span class='pf-lbl'>Skills</span><span class='pf-val'>{dr["Skills"]}</span></div></div>
                <div class='col-12'><div class='pf-field'><span class='pf-lbl'>Address</span>
                    <span class='pf-val'>{dr["Address"]}, {dr["City"]}, {dr["Country"]} – {dr["Pincode"]}</span></div></div>
                <div class='col-12 col-md-6'><div class='pf-field'><span class='pf-lbl'>Emergency Contact</span>
                    <span class='pf-val'>{dr["EmergencyContactName"]} | {dr["EmergencyContactNo"]}</span></div></div>
            </div>";
        }

        private void HandleEdit(int userId)
        {
            DataTable dt = _bl.GetTeacherById(userId, SessionId);
            if (dt == null || dt.Rows.Count == 0) { ShowToast("Teacher not found.", "warning"); return; }
            DataRow dr = dt.Rows[0];
            hfTeacherUserId.Value = userId.ToString();
            txtFullName.Text = dr["FullName"].ToString();
            txtUsername.Text = dr["Username"].ToString();
            txtEmail.Text = dr["Email"].ToString();
            txtContact.Text = dr["ContactNo"].ToString();
            txtEmpId.Text = dr["EmployeeId"].ToString();
            txtPassword.Text = string.Empty;
            TrySelect(ddlStream, dr["StreamId"].ToString());
            txtDesignation.Text = dr["Designation"].ToString();
            txtExperience.Text = dr["ExperienceYears"].ToString();
            txtQualification.Text = dr["Qualification"].ToString();
            txtJoinDate.Text = FormatDateInput(dr["JoinedDate"]);
            chkActive.Checked = Convert.ToBoolean(dr["IsActive"]);
            ddlGender.SelectedValue = dr["Gender"].ToString();
            txtDOB.Text = FormatDateInput(dr["DOB"]);
            txtFatherName.Text = dr["FatherName"].ToString();
            txtMotherName.Text = dr["MotherName"].ToString();
            txtEmgName.Text = dr["EmergencyContactName"].ToString();
            txtEmgContact.Text = dr["EmergencyContactNo"].ToString();
            txtAddress.Text = dr["Address"].ToString();
            txtCity.Text = dr["City"].ToString();
            txtCountry.Text = dr["Country"].ToString();
            txtPincode.Text = dr["Pincode"].ToString();
            txtSkills.Text = dr["Skills"].ToString();
            ScriptManager.RegisterStartupScript(this, GetType(), "openEdit", "openModal();", true);
        }

        private void HandleToggle(int userId)
        {
            DataTable dt = _bl.GetTeacherById(userId, SessionId);
            bool wasActive = dt?.Rows.Count > 0 && Convert.ToBoolean(dt.Rows[0]["IsActive"]);
            string name = dt?.Rows.Count > 0 ? dt.Rows[0]["FullName"].ToString() : "Teacher";
            _bl.ToggleTeacher(userId);
            LogActivity(UserId, SocietyId, InstituteId, SessionId,
                $"TOGGLE_TEACHER: UserId={userId}, NewStatus={(!wasActive ? "Active" : "Inactive")}", userId);
            ShowToast($"'{name}' has been {(wasActive ? "deactivated" : "activated")} successfully.", "success");
        }

        private void HandleResetPassword(int userId)
        {
            string tempPwd = "Tchr@" + new Random().Next(1000, 9999);
            _bl.ResetPassword(userId, tempPwd);
            LogActivity(UserId, SocietyId, InstituteId, SessionId, $"RESET_PWD_TEACHER: UserId={userId}", userId);
            ShowToast($"Password reset to: <strong>{tempPwd}</strong> — Share with the teacher securely.", "warning");
        }

        private void HandleDelete(int userId)
        {
            bool inUse = _bl.IsTeacherInUse(userId);
            if (inUse)
            { ShowToast("Cannot delete: teacher has assigned subjects, attendance or quiz records. Deactivate instead.", "warning"); return; }
            DataTable dt = _bl.GetTeacherById(userId, SessionId);
            string name = dt?.Rows.Count > 0 ? dt.Rows[0]["FullName"].ToString() : "Teacher";
            _bl.DeleteTeacher(userId, SessionId);
            LogActivity(UserId, SocietyId, InstituteId, SessionId, $"DELETE_TEACHER: UserId={userId}, Name={name}", userId);
            ShowToast($"Teacher '{name}' deleted successfully.", "success");
            CurrentPage = 1;
        }

        // ═════════════════════════════════════════════════════════════════════
        //  BULK UPLOAD
        // ═════════════════════════════════════════════════════════════════════
        protected void btnBulkUpload_Click(object sender, EventArgs e)
        {
            if (IsSuperAdmin) { ShowToast("Access Denied.", "warning"); return; }
            if (!fuBulk.HasFile) { ShowToast("Please select an Excel file.", "warning"); return; }
            string ext = Path.GetExtension(fuBulk.FileName).ToLower();
            if (ext != ".xlsx" && ext != ".xls") { ShowToast("Only .xlsx / .xls files are supported.", "danger"); return; }

            int inserted = 0, skipped = 0, errors = 0;
            var errRows = new List<string>();
            var sb = new StringBuilder();

            try
            {
                ExcelPackage.License.SetNonCommercialPersonal("LMS_Project");
                using (var pkg = new ExcelPackage(fuBulk.FileContent))
                {
                    var ws = pkg.Workbook.Worksheets[0];
                    if (ws?.Dimension == null) { ShowToast("The Excel file appears to be empty.", "warning"); return; }
                    int rows = ws.Dimension.Rows;
                    for (int row = 2; row <= rows; row++)
                    {
                        string fullName = ws.Cells[row, 1].Text.Trim();
                        string username = ws.Cells[row, 2].Text.Trim().ToLower();
                        string email = ws.Cells[row, 3].Text.Trim().ToLower();
                        string password = ws.Cells[row, 4].Text.Trim();
                        string contact = ws.Cells[row, 5].Text.Trim();
                        string empId = ws.Cells[row, 6].Text.Trim();
                        string streamNm = ws.Cells[row, 7].Text.Trim();
                        string designation = ws.Cells[row, 8].Text.Trim();
                        string expStr = ws.Cells[row, 9].Text.Trim();
                        string qual = ws.Cells[row, 10].Text.Trim();
                        string joinStr = ws.Cells[row, 11].Text.Trim();
                        string gender = ws.Cells[row, 12].Text.Trim();
                        string dobStr = ws.Cells[row, 13].Text.Trim();
                        string fatherNm = ws.Cells[row, 14].Text.Trim();
                        string motherNm = ws.Cells[row, 15].Text.Trim();
                        string address = ws.Cells[row, 16].Text.Trim();
                        string city = ws.Cells[row, 17].Text.Trim();
                        string country = ws.Cells[row, 18].Text.Trim();
                        string pincode = ws.Cells[row, 19].Text.Trim();
                        string skills = ws.Cells[row, 20].Text.Trim();

                        if (string.IsNullOrWhiteSpace(fullName) && string.IsNullOrWhiteSpace(username)) continue;

                        var rowErrs = new List<string>();
                        if (string.IsNullOrWhiteSpace(fullName)) rowErrs.Add("Full name missing");
                        if (!System.Text.RegularExpressions.Regex.IsMatch(username, @"^[a-z0-9_]{3,50}$")) rowErrs.Add("Invalid username");
                        if (!System.Text.RegularExpressions.Regex.IsMatch(email, @"^[^\s@]+@[^\s@]+\.[^\s@]+$")) rowErrs.Add("Invalid email");
                        if (password.Length < 6) rowErrs.Add("Password too short (min 6)");
                        if (!System.Text.RegularExpressions.Regex.IsMatch(contact, @"^[0-9+]{10,15}$")) rowErrs.Add("Invalid contact");
                        if (string.IsNullOrWhiteSpace(empId)) rowErrs.Add("Employee ID missing");
                        if (string.IsNullOrWhiteSpace(streamNm)) rowErrs.Add("Stream missing");
                        if (string.IsNullOrWhiteSpace(designation)) rowErrs.Add("Designation missing");
                        if (string.IsNullOrWhiteSpace(gender)) rowErrs.Add("Gender missing");
                        // DOB validation: must parse and age 18-80
                        if (!DateTime.TryParse(dobStr, out DateTime dobDt)) rowErrs.Add("Invalid DOB format (use YYYY-MM-DD)");
                        else
                        {
                            int dobAge = (int)((DateTime.Today - dobDt).TotalDays / 365.25);
                            if (dobAge < 18) rowErrs.Add("Teacher must be at least 18 years old");
                            if (dobAge > 80) rowErrs.Add("DOB seems incorrect (age >80)");
                        }
                        // Joining date validation
                        if (!DateTime.TryParse(joinStr, out DateTime joinDt)) rowErrs.Add("Invalid joining date");
                        else
                        {
                            if (joinDt > DateTime.Today.AddYears(1)) rowErrs.Add("Joining date too far in future");
                            if (joinDt < DateTime.Today.AddYears(-60)) rowErrs.Add("Joining date too far in past");
                        }
                        if (!int.TryParse(expStr, out int expInt) || expInt < 0 || expInt > 60) rowErrs.Add("Invalid experience (0-60)");

                        if (rowErrs.Count > 0) { errRows.Add($"Row {row}: {string.Join(", ", rowErrs)}"); errors++; continue; }
                        if (_bl.IsUsernameTaken(username, 0) || _bl.IsEmailTaken(email, 0))
                        { errRows.Add($"Row {row}: Duplicate username/email ({username})"); skipped++; continue; }

                        int streamId = _bl.GetStreamIdByName(InstituteId, SessionId, streamNm);
                        if (streamId == 0) { errRows.Add($"Row {row}: Stream '{streamNm}' not found"); errors++; continue; }

                        var obj = new TeacherGC
                        {
                            SocietyId = SocietyId,
                            InstituteId = InstituteId,
                            SessionId = SessionId,
                            FullName = fullName,
                            Username = username,
                            Email = email,
                            Password = password,
                            ContactNo = contact,
                            EmployeeId = empId,
                            StreamId = streamId,
                            Designation = designation,
                            ExperienceYears = expInt,
                            Qualification = string.IsNullOrWhiteSpace(qual) ? "N/A" : qual,
                            JoinedDate = joinDt,
                            Gender = gender,
                            DOB = dobDt,
                            FatherName = fatherNm,
                            MotherName = motherNm,
                            EmgName = "N/A",
                            EmgContact = "0000000000",
                            Address = string.IsNullOrWhiteSpace(address) ? "N/A" : address,
                            City = city,
                            Country = country,
                            Pincode = int.TryParse(pincode, out int pin) ? pin : (int?)null,
                            Skills = skills,
                            IsActive = true
                        };
                        try { _bl.InsertTeacher(obj); LogActivity(UserId, SocietyId, InstituteId, SessionId, $"BULK_ADD_TEACHER: Name={fullName}", 0); inserted++; }
                        catch (Exception rowEx) { errRows.Add($"Row {row}: DB error — {rowEx.Message}"); errors++; }
                    }
                }

                sb.Append("<div class='d-flex gap-3 flex-wrap mb-3'>");
                sb.Append($"<span class='badge bg-success px-3 py-2'><i class='fa fa-check me-1'></i>{inserted} Added</span>");
                if (skipped > 0) sb.Append($"<span class='badge bg-warning text-dark px-3 py-2'><i class='fa fa-ban me-1'></i>{skipped} Skipped (duplicate)</span>");
                if (errors > 0) sb.Append($"<span class='badge bg-danger px-3 py-2'><i class='fa fa-times me-1'></i>{errors} Errors</span>");
                sb.Append("</div>");
                if (errRows.Count > 0)
                { sb.Append("<div class='text-danger small'><strong>Issues:</strong><ul class='mb-0'>"); foreach (var er in errRows) sb.Append($"<li>{er}</li>"); sb.Append("</ul></div>"); }

                litBulkResult.Text = sb.ToString();
                pnlBulkResult.Visible = true;
                ShowToast($"Bulk upload: {inserted} added, {skipped} skipped, {errors} errors.", inserted > 0 ? "success" : "warning");
                if (inserted > 0) CurrentPage = 1;
                ScriptManager.RegisterStartupScript(this, GetType(), "openBulk2",
                    "new bootstrap.Modal(document.getElementById('BulkModal')).show();", true);
            }
            catch (Exception ex)
            { System.Diagnostics.Debug.WriteLine($"[BulkTeacher] {ex}"); ShowToast("Failed to process file. Ensure it is a valid Excel file.", "danger"); }
        }

        protected void lnkDownloadTemplate_Click(object sender, EventArgs e)
        {
            ExcelPackage.License.SetNonCommercialPersonal("LMS_Project");
            using (var pkg = new ExcelPackage())
            {
                var ws = pkg.Workbook.Worksheets.Add("Teachers");
                string[] headers = {
                    "FullName","Username","Email","Password","ContactNo","EmployeeId",
                    "StreamName","Designation","ExperienceYears","Qualification",
                    "JoiningDate","Gender","DOB","FatherName","MotherName",
                    "Address","City","Country","Pincode","Skills"
                };
                for (int i = 0; i < headers.Length; i++)
                {
                    var cell = ws.Cells[1, i + 1];
                    cell.Value = headers[i]; cell.Style.Font.Bold = true;
                    cell.Style.Fill.PatternType = OfficeOpenXml.Style.ExcelFillStyle.Solid;
                    cell.Style.Fill.BackgroundColor.SetColor(System.Drawing.Color.FromArgb(79, 70, 229));
                    cell.Style.Font.Color.SetColor(System.Drawing.Color.White);
                    ws.Column(i + 1).Width = 20;
                }
                ws.Cells[2, 1].Value = "Dr. Priya Sharma"; ws.Cells[2, 2].Value = "priya_sharma25";
                ws.Cells[2, 3].Value = "priya@school.edu"; ws.Cells[2, 4].Value = "Pass@1234";
                ws.Cells[2, 5].Value = "9876543210"; ws.Cells[2, 6].Value = "EMP2025001";
                ws.Cells[2, 7].Value = "Computer Science"; ws.Cells[2, 8].Value = "Associate Professor";
                ws.Cells[2, 9].Value = "8"; ws.Cells[2, 10].Value = "M.Tech";
                ws.Cells[2, 11].Value = "2025-07-01"; ws.Cells[2, 12].Value = "Female";
                ws.Cells[2, 13].Value = "1990-04-15"; ws.Cells[2, 14].Value = "Rajesh Sharma";
                ws.Cells[2, 15].Value = "Sunita Sharma"; ws.Cells[2, 16].Value = "45 MG Road, Pune";
                ws.Cells[2, 17].Value = "Pune"; ws.Cells[2, 18].Value = "India";
                ws.Cells[2, 19].Value = "411001"; ws.Cells[2, 20].Value = "Python, ML";
                Response.Clear();
                Response.ContentType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
                Response.AddHeader("Content-Disposition", "attachment; filename=TeacherUploadTemplate.xlsx");
                Response.BinaryWrite(pkg.GetAsByteArray());
                Response.End();
            }
        }

        // ═════════════════════════════════════════════════════════════════════
        //  RE-ENROL
        // ═════════════════════════════════════════════════════════════════════
        protected void ddlPrevSession_Changed(object sender, EventArgs e)
        {
            int prevSessionId = int.TryParse(ddlPrevSession.SelectedValue, out int ps) ? ps : 0;
            if (prevSessionId == 0) { rptPrevTeachers.DataSource = null; rptPrevTeachers.DataBind(); return; }
            DataTable dt = _bl.GetTeachers(InstituteId, prevSessionId, 0, "All");
            rptPrevTeachers.DataSource = dt;
            rptPrevTeachers.DataBind();
            ScriptManager.RegisterStartupScript(this, GetType(), "openReenrol2",
                "new bootstrap.Modal(document.getElementById('ReenrolModal')).show();", true);
        }

        protected void btnReenrol_Click(object sender, EventArgs e)
        {
            if (IsSuperAdmin) { ShowToast("Access Denied.", "warning"); return; }
            string ids = hfReenrolIds.Value;
            if (string.IsNullOrWhiteSpace(ids)) { ShowToast("No teachers selected.", "warning"); return; }
            int prevSessionId = int.TryParse(ddlPrevSession.SelectedValue, out int ps) ? ps : 0;
            if (prevSessionId == 0) { ShowToast("Please select a previous session.", "warning"); return; }
            int newStreamId = int.TryParse(ddlReenrolStream.SelectedValue, out int ns) && ns > 0 ? ns : 0;
            int[] userIds = Array.ConvertAll(ids.Split(','), int.Parse);
            int enrolled = 0, skippedRe = 0;
            foreach (int uid in userIds)
            {
                try
                {
                    bool ok = _bl.ReenrolTeacher(uid, prevSessionId, SessionId, SocietyId, InstituteId,
                                newStreamId > 0 ? newStreamId : (int?)null);
                    if (ok) { LogActivity(UserId, SocietyId, InstituteId, SessionId, $"REENROL_TEACHER: UserId={uid}", uid); enrolled++; }
                    else skippedRe++;
                }
                catch { skippedRe++; }
            }
            ShowToast($"Re-enrolment: {enrolled} enrolled, {skippedRe} skipped.", "success");
            CurrentPage = 1;
        }

        // ═════════════════════════════════════════════════════════════════════
        //  UTILITIES
        // ═════════════════════════════════════════════════════════════════════
        private void ClearForm()
        {
            hfTeacherUserId.Value = string.Empty;
            txtFullName.Text = txtUsername.Text = txtEmail.Text = string.Empty;
            txtPassword.Text = txtContact.Text = txtEmpId.Text = string.Empty;
            txtDesignation.Text = txtExperience.Text = txtQualification.Text = string.Empty;
            txtJoinDate.Text = txtDOB.Text = txtFatherName.Text = string.Empty;
            txtMotherName.Text = txtEmgName.Text = txtEmgContact.Text = string.Empty;
            txtAddress.Text = txtCity.Text = txtCountry.Text = string.Empty;
            txtPincode.Text = txtSkills.Text = string.Empty;
            ddlGender.SelectedIndex = 0;
            ddlStream.SelectedIndex = 0;
            chkActive.Checked = true;
        }

        private void ReopenModal() =>
            ScriptManager.RegisterStartupScript(this, GetType(),
                "reopen_" + Guid.NewGuid().ToString("N").Substring(0, 6), "openModal();", true);

        private void ShowToast(string msg, string type = "success")
        {
            msg = msg.Replace("'", "\'").Replace("\r", "").Replace("\n", "");
            ScriptManager.RegisterStartupScript(this, GetType(),
                "toast_" + Guid.NewGuid().ToString("N").Substring(0, 8),
                $"serverToast('{msg}','{type}');", true);
        }

        private void TrySelect(DropDownList ddl, string value)
        {
            if (ddl == null || string.IsNullOrWhiteSpace(value)) return;
            var item = ddl.Items.FindByValue(value);
            if (item != null) item.Selected = true;
        }

        private string FormatDate(object val) =>
            val != null && DateTime.TryParse(val.ToString(), out DateTime d) ? d.ToString("dd MMM yyyy") : "—";
        private string FormatDateInput(object val) =>
            val != null && DateTime.TryParse(val.ToString(), out DateTime d) ? d.ToString("yyyy-MM-dd") : string.Empty;
        private string EscapeJs(string html) =>
            "`" + html.Replace("`", "\\`").Replace("${", "\\${") + "`";
    }
}