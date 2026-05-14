using LearningManagementSystem.BL;
using LearningManagementSystem.GC;
using System;
using System.Collections.Generic;
using System.Data;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace LearningManagementSystem.Admin
{
    [System.Web.Script.Services.ScriptService]
    public partial class AssignSubjectFaculty : BasePage
    {

        public int TrackerPage
        {
            get
            {
                object o = ViewState["TrackerPage"];
                return o != null ? Convert.ToInt32(o) : 1;
            }
            set
            {
                ViewState["TrackerPage"] = value;
            }
        }

        public int TrackerPageSize
        {
            get
            {
                object o = ViewState["TrackerPageSize"];
                return o != null ? Convert.ToInt32(o) : 10;
            }
            set
            {
                ViewState["TrackerPageSize"] = value;
            }
        }

        private readonly AssignSubjectFacultyBL _bl = new AssignSubjectFacultyBL();

        // ─── Tracker pagination ───────────────────────────────────────────────


        private const int WorkloadPageSize = 8;

       

        private int WorkloadPage
        {
            get => ViewState["WorkloadPage"] != null
                ? Convert.ToInt32(ViewState["WorkloadPage"])
                : 1;

            set => ViewState["WorkloadPage"] = value;
        }

        private bool IsSuperAdmin =>
            Session["Role"]?.ToString()
                .Equals("SuperAdmin", StringComparison.OrdinalIgnoreCase) == true;

        // ═════════════════════════════════════════════════════════════════════
        //  PAGE LOAD
        // ═════════════════════════════════════════════════════════════════════
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                ConfigureRoleUI();
                lblSessionName.Text = Session["SessionName"]?.ToString() ?? "—";

                if (SessionId == 0)
                {
                    ShowToast("No active academic session. Configure a session first.", "warning");
                    return;
                }

                LoadStreams();
                LoadAllSections(ddlSection, 0);
                LoadAllSections(ddlBulkSection, 0);
                LoadSubjectsDdl(ddlSubject);
                LoadTrackerStreams();
                BindBulkSubjectsRepeater();
                BindTracker();
                BindWorkload();
                UpdateStats();
            }
        }

        // ─── Role ─────────────────────────────────────────────────────────────
        private void ConfigureRoleUI()
        {
            lblSuperAdminBadge.Visible = IsSuperAdmin;
            pnlSaveBtn.Visible = !IsSuperAdmin;
            pnlBulkSaveBtn.Visible = !IsSuperAdmin;
            pnlSuperAdminNote.Visible = IsSuperAdmin;
        }

        // ─── Stats ────────────────────────────────────────────────────────────
        private void UpdateStats()
        {
            DataTable dt = _bl.GetStats(InstituteId, SessionId);
            if (dt.Rows.Count > 0)
            {
                lblTotalAssigned.Text = dt.Rows[0]["TotalAssignments"].ToString();
                lblActive.Text = dt.Rows[0]["ActiveAssignments"].ToString();
                lblTeachersAssigned.Text = dt.Rows[0]["TeachersAssigned"].ToString();
            }
        }

        // ═════════════════════════════════════════════════════════════════════
        //  DROPDOWN LOADERS
        // ═════════════════════════════════════════════════════════════════════
        private void LoadStreams()
        {
            DataTable dt = _bl.GetStreams(InstituteId, SessionId);
            ddlStream.Items.Clear();
            ddlStream.Items.Add(new ListItem("-- All Streams --", "0"));
            foreach (DataRow dr in dt.Rows)
                ddlStream.Items.Add(new ListItem(
                    dr["StreamName"].ToString(), dr["StreamId"].ToString()));
        }

        private void LoadTrackerStreams()
        {
            DataTable dt = _bl.GetStreams(InstituteId, SessionId);
            ddlTrackerStream.Items.Clear();
            ddlTrackerStream.Items.Add(new ListItem("All Streams", "0"));
            foreach (DataRow dr in dt.Rows)
                ddlTrackerStream.Items.Add(new ListItem(
                    dr["StreamName"].ToString(), dr["StreamId"].ToString()));
        }

        /// <summary>Load ALL sections (not subject-filtered) into a dropdown.</summary>
        private void LoadAllSections(DropDownList ddl, int streamId)
        {
            DataTable dt = _bl.GetSections(InstituteId, SessionId, streamId);
            ddl.Items.Clear();
            ddl.Items.Add(new ListItem("-- Select Section --", "0"));
            foreach (DataRow dr in dt.Rows)
                ddl.Items.Add(new ListItem(
                    dr["SectionName"].ToString(), dr["SectionId"].ToString()));
        }

        /// <summary>
        /// Load sections that are valid for the selected subject.
        /// Called after ddlSubject_Changed — narrows the section choices.
        /// </summary>
        private void LoadSectionsBySubject(int subjectId)
        {
            DataTable dt = subjectId > 0
                ? _bl.GetSectionsBySubject(subjectId, InstituteId, SessionId)
                : _bl.GetSections(InstituteId, SessionId, 0);

            ddlSection.Items.Clear();
            if (dt.Rows.Count == 0)
            {
                ddlSection.Items.Add(new ListItem("-- No sections found --", "0"));
            }
            else
            {
                ddlSection.Items.Add(new ListItem("-- Select Section --", "0"));
                foreach (DataRow dr in dt.Rows)
                    ddlSection.Items.Add(new ListItem(
                        dr["SectionName"].ToString(), dr["SectionId"].ToString()));
            }
        }

        private void LoadSubjectsDdl(DropDownList ddl)
        {
            DataTable dt = _bl.GetSubjects(InstituteId, SessionId);
            ddl.Items.Clear();
            ddl.Items.Add(new ListItem("-- Select Subject --", "0"));
            foreach (DataRow dr in dt.Rows)
                ddl.Items.Add(new ListItem(
                    dr["SubjectName"].ToString(), dr["SubjectId"].ToString()));
        }

        private void BindBulkSubjectsRepeater()
        {
            DataTable dt = _bl.GetSubjects(InstituteId, SessionId);
            rptBulkSubjects.DataSource = dt;
            rptBulkSubjects.DataBind();
        }

        // ═════════════════════════════════════════════════════════════════════
        //  POSTBACK HANDLERS
        // ═════════════════════════════════════════════════════════════════════

        /// <summary>Stream changes → filter sections (single-assign form).</summary>
        protected void ddlStream_Changed(object sender, EventArgs e)
        {
            int streamId = GetInt(ddlStream.SelectedValue);
            // When stream changes, reload sections by stream
            // (subject may not be selected yet, so use stream filter)
            int subjectId = GetInt(ddlSubject.SelectedValue);
            if (subjectId > 0)
                LoadSectionsBySubject(subjectId);   // subject wins if selected
            else
                LoadAllSections(ddlSection, streamId);
        }

        /// <summary>
        /// ★ Subject selection → reload sections that are VALID for this subject.
        /// This is the key feature: sections are derived from LevelSemesterSubjects
        /// so admin only sees sections where the subject is actually assigned.
        /// </summary>
        protected void ddlSubject_Changed(object sender, EventArgs e)
        {
            int subjectId = GetInt(ddlSubject.SelectedValue);
            LoadSectionsBySubject(subjectId);

            if (subjectId > 0 && ddlSection.Items.Count <= 1)
            {
                ShowToast("No sections found for this subject. " +
                          "Assign this subject to a class first via 'Assign Level Subjects'.", "warning");
            }
        }

        protected void ddlTrackerStream_Changed(object sender, EventArgs e)
        {
            TrackerPage = 1;
            BindTracker();
        }

        protected void ddlTrackerStatus_Changed(object sender, EventArgs e)
        {
            TrackerPage = 1;
            BindTracker();
        }

        // ═════════════════════════════════════════════════════════════════════
        //  TRACKER GRID  (with pagination)
        // ═════════════════════════════════════════════════════════════════════


        private void BindTracker()
        {
            if (SessionId == 0) return;

            int filterStream = GetInt(ddlTrackerStream.SelectedValue);
            string filterStatus = ddlTrackerStatus.SelectedValue;

            DataTable dtAll = _bl.GetAll(InstituteId, SessionId, filterStream, filterStatus);

            // ── Paginate ──────────────────────────────────────────────────────
            int total = dtAll.Rows.Count;
            int totalPages = Math.Max(1, (int)Math.Ceiling((double)total / TrackerPageSize));
            if (TrackerPage > totalPages) TrackerPage = totalPages;
            if (TrackerPage < 1) TrackerPage = 1;

            int start = (TrackerPage - 1) * TrackerPageSize;
            int end = Math.Min(start + TrackerPageSize, total);

            DataTable dtPage = dtAll.Clone();
            for (int i = start; i < end; i++)
                dtPage.ImportRow(dtAll.Rows[i]);

            gvAssign.DataSource = dtPage;
            gvAssign.DataBind();

            BuildPager(pnlPager, totalPages, TrackerPage, "tracker");

            // Record count JS
            string cnt = total == 0
                ? "No records"
                : $"Showing {start + 1}–{end} of {total}";
            ScriptManager.RegisterStartupScript(this, GetType(), "trkCnt",
                $"var el=document.getElementById('trackerCount');if(el)el.textContent='{cnt}';",
                true);

            // SuperAdmin: hide action buttons
            if (IsSuperAdmin)
                ScriptManager.RegisterStartupScript(this, GetType(), "hideSA",
                    "document.querySelectorAll('.asf-act-btn').forEach(b=>b.style.display='none');",
                    true);
        }

        // ─── Workload grid (with pagination) ──────────────────────────────────


        private void BindWorkload()
        {
            if (SessionId == 0) return;

            DataTable dtAll = _bl.GetTeacherWorkload(InstituteId, SessionId);

            int total = dtAll.Rows.Count;

            int totalPages = Math.Max(
                1,
                (int)Math.Ceiling((double)total / WorkloadPageSize)
            );

            if (WorkloadPage > totalPages)
                WorkloadPage = totalPages;

            if (WorkloadPage < 1)
                WorkloadPage = 1;

            int start = (WorkloadPage - 1) * WorkloadPageSize;
            int end = Math.Min(start + WorkloadPageSize, total);

            DataTable dtPage = dtAll.Clone();

            for (int i = start; i < end; i++)
                dtPage.ImportRow(dtAll.Rows[i]);

            gvWorkload.DataSource = dtPage;
            gvWorkload.DataBind();

            // BUILD WORKLOAD PAGER
            BuildPager(
                pnlWorkloadPager,
                totalPages,
                WorkloadPage,
                "workload"
            );
        }

        // ─── Generic pager builder ────────────────────────────────────────────
        private void BuildPager(Panel pnl, int totalPages, int currentPage, string key)
        {
            pnl.Controls.Clear();
            if (totalPages <= 1) return;

            AddPagerBtn(pnl, "‹", currentPage - 1, currentPage == 1, key);
            int from = Math.Max(1, currentPage - 2);
            int to = Math.Min(totalPages, currentPage + 2);

            if (from > 1) { AddPagerBtn(pnl, "1", 1, false, key); if (from > 2) AddPagerDots(pnl); }
            for (int p = from; p <= to; p++)
                AddPagerBtn(pnl, p.ToString(), p, false, key, p == currentPage);
            if (to < totalPages) { if (to < totalPages - 1) AddPagerDots(pnl); AddPagerBtn(pnl, totalPages.ToString(), totalPages, false, key); }
            AddPagerBtn(pnl, "›", currentPage + 1, currentPage == totalPages, key);
        }

        private void AddPagerBtn(Panel pnl, string text, int page, bool disabled,
                                 string key, bool active = false)
        {
            var btn = new LinkButton
            {
                Text = text,
                CommandArgument = page + "|" + key,
                CssClass = "asf-page-btn" + (active ? " active" : ""),
                Enabled = !disabled
            };
            btn.Click += PagerBtn_Click;
            pnl.Controls.Add(btn);
        }

        private void AddPagerDots(Panel pnl) =>
            pnl.Controls.Add(new LiteralControl(
                "<span class='asf-page-btn' style='cursor:default;pointer-events:none'>…</span>"));

        

        protected void PagerBtn_Click(object sender, EventArgs e)
        {
            if (!(sender is LinkButton btn))
                return;

            string[] parts = btn.CommandArgument.Split('|');

            if (parts.Length != 2)
                return;

            if (!int.TryParse(parts[0], out int page))
                return;

            string type = parts[1];

            switch (type)
            {
                case "tracker":
                    TrackerPage = page;
                    BindTracker();
                    break;

                case "workload":
                    WorkloadPage = page;
                    BindWorkload();
                    break;
            }
        }

        // ═════════════════════════════════════════════════════════════════════
        //  SINGLE ASSIGN  → btnSave_Click
        // ═════════════════════════════════════════════════════════════════════
        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (IsSuperAdmin) { ShowToast("Access Denied: SuperAdmin is view-only.", "warning"); return; }
            if (SessionId == 0) { ShowToast("No active session.", "warning"); return; }

            string teacherRaw = hfTeacherId.Value?.Trim();
            int subjectId = GetInt(ddlSubject.SelectedValue);
            int sectionId = GetInt(ddlSection.SelectedValue);

            if (!int.TryParse(teacherRaw, out int teacherId) || teacherId == 0)
            {
                ShowToast("Please select a teacher from the search results.", "warning");

                ScriptManager.RegisterStartupScript(this, GetType(),
                    "resetSingleTeacher", "resetSingleAssignForm();", true);

                return;
            }

            if (subjectId == 0)
            {
                ShowToast("Please select a subject.", "warning");

                ScriptManager.RegisterStartupScript(this, GetType(),
                    "resetSingleSubject", "resetSingleAssignForm();", true);

                return;
            }

            if (sectionId == 0)
            {
                ShowToast("Please select a section.", "warning");

                ScriptManager.RegisterStartupScript(this, GetType(),
                    "resetSingleSection", "resetSingleAssignForm();", true);

                return;
            }

            try
            {
                // ── Duplicate check ──────────────────────────────────────────
                if (_bl.IsAlreadyAssigned(InstituteId, SessionId, teacherId, subjectId, sectionId))
                {
                    string subN = ddlSubject.SelectedItem?.Text ?? "this subject";
                    string secN = ddlSection.SelectedItem?.Text ?? "this section";
                    ShowToast($"This teacher is already assigned to '{subN}' in Section '{secN}'. " +
                              "No duplicate created.", "warning");

                    ScriptManager.RegisterStartupScript(this, GetType(),
                    "resetSingleDup", "resetSingleAssignForm();", true);

                    return;
                }

                _bl.Insert(new SubjectFacultyGC
                {
                    SocietyId = SocietyId,
                    InstituteId = InstituteId,
                    SessionId = SessionId,
                    TeacherId = teacherId,
                    SubjectId = subjectId,
                    SectionId = sectionId,
                    AssignedBy = UserId
                });

                // Names for toast + notification
                DataTable dtT = _bl.GetTeacherById(teacherId);
                string tName = dtT.Rows.Count > 0 ? dtT.Rows[0]["FullName"].ToString() : "Teacher";
                string subName = ddlSubject.SelectedItem?.Text ?? "Subject";
                string secName = ddlSection.SelectedItem?.Text ?? "Section";

                _bl.SendNotification(teacherId, SocietyId, InstituteId, SessionId,
                    $"You have been assigned to teach '{subName}' for Section '{secName}'. " +
                    "Please check your dashboard for your updated timetable.",
                    "SubjectFacultyAssign");

                LogActivity(UserId, SocietyId, InstituteId, SessionId,
                    $"ASSIGN_SUBJECT_FACULTY: Teacher={tName}, Subject={subName}, Section={secName}",
                    teacherId);

                ShowToast($"'{tName}' assigned to '{subName}' (Sec: {secName}). Teacher notified.", "success");

                // Clear complete single form            


                ScriptManager.RegisterStartupScript(this, GetType(),
                "resetSingleSuccess", "resetSingleAssignForm();", true);

                RefreshAll();
            }

            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[ASF.Save] {ex}");

                ShowToast("An unexpected error occurred. Please try again.", "danger");

                ScriptManager.RegisterStartupScript(this, GetType(),
                    "resetSingleErr", "resetSingleAssignForm();", true);
            }
        }

        // ═════════════════════════════════════════════════════════════════════
        //  BULK ASSIGN  → btnBulkSave_Click
        //  Duplicates are SILENTLY SKIPPED — only a count is shown in the toast.
        // ═════════════════════════════════════════════════════════════════════
        protected void btnBulkSave_Click(object sender, EventArgs e)
        {
            if (IsSuperAdmin) { ShowToast("Access Denied: SuperAdmin is view-only.", "warning"); return; }
            if (SessionId == 0) { ShowToast("No active session.", "warning"); return; }

            string teacherRaw = hfTeacherId.Value?.Trim();
            string subjectIdsRaw = hfBulkSubjectIds.Value?.Trim();
            int sectionId = GetInt(ddlBulkSection.SelectedValue);

            if (!int.TryParse(teacherRaw, out int teacherId) || teacherId == 0)
            {
                ShowToast("Please select a teacher for bulk assignment.", "warning");

                ScriptManager.RegisterStartupScript(this, GetType(),
                    "resetBulkTeacher", "resetBulkAssignForm();", true);

                return;
            }

            if (sectionId == 0)
            {
                ShowToast("Please select a section for bulk assignment.", "warning");

                ScriptManager.RegisterStartupScript(this, GetType(),
                    "resetBulkSection", "resetBulkAssignForm();", true);

                return;
            }

            if (string.IsNullOrWhiteSpace(subjectIdsRaw))
            {
                ShowToast("Please tick at least one subject.", "warning");

                ScriptManager.RegisterStartupScript(this, GetType(),
                    "resetBulkSubjects", "resetBulkAssignForm();", true);

                return;
            }

            

            // Parse subject IDs (serialised by JS before postback)
            var subjectIds = new List<int>();
            foreach (var s in subjectIdsRaw.Split(','))
                if (int.TryParse(s.Trim(), out int sid) && sid > 0)
                    subjectIds.Add(sid);

            if (subjectIds.Count == 0)
            {
                ShowToast("No valid subjects selected. Please try again.", "warning");

                ScriptManager.RegisterStartupScript(this, GetType(),
                    "resetBulkInvalidSubjects", "resetBulkAssignForm();", true);

                return;
            }

            try
            {
                int inserted = 0;
                int duplicates = 0;
                var subNames = new List<string>();

                DataTable dtT = _bl.GetTeacherById(teacherId);
                string tName = dtT.Rows.Count > 0 ? dtT.Rows[0]["FullName"].ToString() : "Teacher";
                string secName = ddlBulkSection.SelectedItem?.Text ?? "Section";

                foreach (int subjectId in subjectIds)
                {
                    // Silently skip duplicates — just count them
                    if (_bl.IsAlreadyAssigned(InstituteId, SessionId, teacherId, subjectId, sectionId))
                    { duplicates++; continue; }

                    _bl.Insert(new SubjectFacultyGC
                    {
                        SocietyId = SocietyId,
                        InstituteId = InstituteId,
                        SessionId = SessionId,
                        TeacherId = teacherId,
                        SubjectId = subjectId,
                        SectionId = sectionId,
                        AssignedBy = UserId
                    });

                    DataTable dtSub = _bl.GetSubjectById(subjectId, InstituteId, SessionId);
                    if (dtSub.Rows.Count > 0)
                        subNames.Add(dtSub.Rows[0]["SubjectName"].ToString());

                    inserted++;
                }

                // Send ONE notification with all assigned subjects
                if (inserted > 0)
                {
                    _bl.SendNotification(teacherId, SocietyId, InstituteId, SessionId,
                        $"You have been assigned to teach {subNames.Count} subject(s) for " +
                        $"Section '{secName}': {string.Join(", ", subNames)}. " +
                        "Please check your dashboard.",
                        "BulkSubjectFacultyAssign");

                    LogActivity(UserId, SocietyId, InstituteId, SessionId,
                        $"BULK_ASSIGN_SF: Teacher={tName}, Section={secName}, Count={inserted}",
                        teacherId);
                }

                // Toast summarises result
                string msg = inserted > 0
                    ? $"{inserted} subject(s) assigned to '{tName}' (Sec: {secName})."
                    : $"No new assignments made for '{tName}' (Sec: {secName}).";
                if (duplicates > 0)
                    msg += $" {duplicates} duplicate(s) skipped automatically.";
                if (inserted > 0)
                    msg += " Teacher notified.";

                ShowToast(msg, inserted > 0 ? "success" : "warning");

                // Reset complete bulk form
                
                ScriptManager.RegisterStartupScript(this, GetType(),
                 "resetBulkSuccess", "resetBulkAssignForm();", true);

                RefreshAll();


            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[ASF.BulkSave] {ex}");

                ShowToast("An unexpected error occurred. Please try again.", "danger");

                ScriptManager.RegisterStartupScript(this, GetType(),
                    "resetBulkErr", "resetBulkAssignForm();", true);
            }
        }

        // ═════════════════════════════════════════════════════════════════════
        //  TRACKER ROW COMMANDS
        // ═════════════════════════════════════════════════════════════════════
        protected void gvAssign_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (IsSuperAdmin) { ShowToast("Access Denied: SuperAdmin is view-only.", "warning"); return; }
            if (!int.TryParse(e.CommandArgument?.ToString(), out int id) || id == 0) return;

            try
            {
                switch (e.CommandName)
                {
                    case "Toggle":
                        _bl.Toggle(id);
                        LogActivity(UserId, SocietyId, InstituteId, SessionId,
                            $"TOGGLE_SF: Id={id}", id);
                        ShowToast("Status updated.", "success");
                        break;

                    case "DeleteRow":
                        _bl.Delete(id);
                        LogActivity(UserId, SocietyId, InstituteId, SessionId,
                            $"DELETE_SF: Id={id}", id);
                        ShowToast("Assignment removed.", "success");
                        break;
                }
                RefreshAll();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[ASF.RowCmd:{e.CommandName}] {ex}");
                ShowToast("Cannot delete — assignment may have attendance records. " +
                          "Use Toggle (Deactivate) instead.", "danger");
            }
        }

        // ═════════════════════════════════════════════════════════════════════
        //  WEBMETHOD  — Teacher live-search (JS fetch — zero postback)
        //  STATIC so ASP.NET routing can call it without a page instance.
        // ═════════════════════════════════════════════════════════════════════
        [WebMethod]
        public static List<object> SearchTeachers(string prefix,
                                          string instituteId,
                                          string sessionId)
        {
            var list = new List<object>();

            try
            {
                System.Diagnostics.Debug.WriteLine("WEBMETHOD HIT");

                int instId = 0;
                int.TryParse(instituteId, out instId);

                int sessId = 0;
                int.TryParse(sessionId, out sessId);

                DataTable dt = new AssignSubjectFacultyBL()
                    .SearchTeachers(prefix, instId, sessId);

                System.Diagnostics.Debug.WriteLine("ROWS: " + dt.Rows.Count);

                foreach (DataRow dr in dt.Rows)
                {
                    list.Add(new
                    {
                        UserId = dr["UserId"].ToString(),
                        FullName = dr["FullName"].ToString(),
                        EmployeeId = dr["EmployeeId"].ToString(),
                        StreamName = dr["StreamName"].ToString()
                    });
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine(ex.ToString());
            }

            return list;
        }

        // ═════════════════════════════════════════════════════════════════════
        //  INLINE EXPRESSION HELPERS  (protected = callable from ASPX <%# %>)
        // ═════════════════════════════════════════════════════════════════════
        private static readonly string[] _colors = {
            "#4f46e5","#0891b2","#059669","#d97706","#dc2626","#7c3aed","#db2777","#0d9488"
        };

        protected string GetAvatarColor(string name)
        {
            if (string.IsNullOrWhiteSpace(name)) return _colors[0];
            return _colors[Math.Abs(name.GetHashCode()) % _colors.Length];
        }

        protected string GetInitials(string name)
        {
            if (string.IsNullOrWhiteSpace(name)) return "?";
            var p = name.Trim().Split(new char[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            return p.Length == 1
                ? p[0].Substring(0, Math.Min(2, p[0].Length)).ToUpper()
                : (p[0][0].ToString() + p[p.Length - 1][0].ToString()).ToUpper();
        }

        protected string GetLoadPercent(object count)
        {
            if (count == null || count == DBNull.Value) return "0";
            return Math.Min(Convert.ToInt32(count) * 100 / 8, 100).ToString();
        }

        protected string GetLoadColor(object count)
        {
            if (count == null || count == DBNull.Value) return "#94a3b8";
            int n = Convert.ToInt32(count);
            return n <= 2 ? "#16a34a" : n <= 5 ? "#d97706" : "#dc2626";
        }

        // ─── Utilities ────────────────────────────────────────────────────────
        private void RefreshAll()
        {
            TrackerPage = 1;
            WorkloadPage = 1;
            BindTracker();
            BindWorkload();
            UpdateStats();
        }

        private int GetInt(string val) =>
            int.TryParse(val, out int v) ? v : 0;

        private void ShowToast(string msg, string type = "success")
        {
            msg = msg.Replace("'", "\\'").Replace("\r", "").Replace("\n", "");
            ScriptManager.RegisterStartupScript(this, GetType(),
                "t_" + Guid.NewGuid().ToString("N").Substring(0, 8),
                $"serverToast('{msg}','{type}');", true);
        }

    }
}