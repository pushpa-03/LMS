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
        private readonly AssignSubjectFacultyBL _bl = new AssignSubjectFacultyBL();

        private const int TrackerPageSize = 5;
        private const int WorkloadPageSize = 8;

        private int TrackerPage
        {
            get => ViewState["TrackerPage"] != null ? Convert.ToInt32(ViewState["TrackerPage"]) : 1;
            set => ViewState["TrackerPage"] = value;
        }
        private int WorkloadPage
        {
            get => ViewState["WorkloadPage"] != null ? Convert.ToInt32(ViewState["WorkloadPage"]) : 1;
            set => ViewState["WorkloadPage"] = value;
        }

        private bool IsSuperAdmin =>
            Session["Role"]?.ToString()
                .Equals("SuperAdmin", StringComparison.OrdinalIgnoreCase) == true;

        // ═════════════════════════════════════════════════════════════════════
        //  PAGE LOAD
        //  ★ BindTracker + BindWorkload run on EVERY request so pager
        //    LinkButtons are always re-added to the control tree.
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
                LoadSections(ddlSection);
                LoadSections(ddlBulkSection);
                LoadTrackerStreams();
                UpdateStats();
            }

            if (SessionId > 0)
            {
                BindTracker();
                BindWorkload();
            }
        }

        private void ConfigureRoleUI()
        {
            lblSuperAdminBadge.Visible = IsSuperAdmin;
            pnlSaveBtn.Visible = !IsSuperAdmin;
            pnlBulkSaveBtn.Visible = !IsSuperAdmin;
            pnlSuperAdminNote.Visible = IsSuperAdmin;
        }

        private void UpdateStats()
        {
            var dt = _bl.GetStats(InstituteId, SessionId);
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
            var dt = _bl.GetStreams(InstituteId, SessionId);
            ddlTrackerStream.Items.Clear();
            ddlTrackerStream.Items.Add(new ListItem("All Streams", "0"));
            foreach (DataRow dr in dt.Rows)
                ddlTrackerStream.Items.Add(new ListItem(dr["StreamName"].ToString(), dr["StreamId"].ToString()));
        }

        private void LoadTrackerStreams()
        {
            var dt = _bl.GetStreams(InstituteId, SessionId);
            ddlTrackerStream.Items.Clear();
            ddlTrackerStream.Items.Add(new ListItem("All Streams", "0"));
            foreach (DataRow dr in dt.Rows)
                ddlTrackerStream.Items.Add(new ListItem(dr["StreamName"].ToString(), dr["StreamId"].ToString()));
        }

        private void LoadSections(DropDownList ddl)
        {
            var dt = _bl.GetSections(InstituteId, SessionId);
            ddl.Items.Clear();
            ddl.Items.Add(new ListItem("-- Select Section --", "0"));
            foreach (DataRow dr in dt.Rows)
                ddl.Items.Add(new ListItem(dr["SectionName"].ToString(), dr["SectionId"].ToString()));
        }

        // ═════════════════════════════════════════════════════════════════════
        //  POSTBACK HANDLERS
        //  ddlStream — filters tracker; no bulk section postback needed
        //  (bulk section is handled client-side via AJAX)
        // ═════════════════════════════════════════════════════════════════════
        protected void ddlTrackerStream_Changed(object sender, EventArgs e)
        {
            TrackerPage = 1;
        }
        protected void ddlTrackerStatus_Changed(object sender, EventArgs e)
        {
            TrackerPage = 1;
        }

        // ═════════════════════════════════════════════════════════════════════
        //  TRACKER GRID
        // ═════════════════════════════════════════════════════════════════════
        private void BindTracker()
        {
            if (SessionId == 0) return;

            int filterStream = GetInt(ddlTrackerStream.SelectedValue);
            string filterStatus = ddlTrackerStatus.SelectedValue;

            var dtAll = _bl.GetAll(InstituteId, SessionId, filterStream, filterStatus);

            int total = dtAll.Rows.Count;
            int totalPages = Math.Max(1, (int)Math.Ceiling((double)total / TrackerPageSize));
            if (TrackerPage > totalPages) TrackerPage = totalPages;
            if (TrackerPage < 1) TrackerPage = 1;

            int start = (TrackerPage - 1) * TrackerPageSize;
            int end = Math.Min(start + TrackerPageSize, total);

            var dtPage = dtAll.Clone();
            for (int i = start; i < end; i++) dtPage.ImportRow(dtAll.Rows[i]);

            gvAssign.DataSource = dtPage;
            gvAssign.DataBind();

            BuildPager(pnlPager, totalPages, TrackerPage, "tracker");

            if (IsSuperAdmin)
                ScriptManager.RegisterStartupScript(this, GetType(), "hideSA",
                    "document.querySelectorAll('.asf-act-btn').forEach(b=>b.style.display='none');", true);
        }

        private void BindWorkload()
        {
            if (SessionId == 0) return;

            var dtAll = _bl.GetTeacherWorkload(InstituteId, SessionId);

            int total = dtAll.Rows.Count;
            int totalPages = Math.Max(1, (int)Math.Ceiling((double)total / WorkloadPageSize));
            if (WorkloadPage > totalPages) WorkloadPage = totalPages;
            if (WorkloadPage < 1) WorkloadPage = 1;

            int start = (WorkloadPage - 1) * WorkloadPageSize;
            int end = Math.Min(start + WorkloadPageSize, total);

            var dtPage = dtAll.Clone();
            for (int i = start; i < end; i++) dtPage.ImportRow(dtAll.Rows[i]);

            gvWorkload.DataSource = dtPage;
            gvWorkload.DataBind();

            BuildPager(pnlWorkloadPager, totalPages, WorkloadPage, "workload");
        }

        // ═════════════════════════════════════════════════════════════════════
        //  PAGER — named handler (never lambda)
        // ═════════════════════════════════════════════════════════════════════
        private void BuildPager(Panel pnl, int totalPages, int currentPage, string key)
        {
            pnl.Controls.Clear();
            if (totalPages <= 1) return;

            AddPagerBtn(pnl, "«", 1, currentPage == 1, key);
            AddPagerBtn(pnl, "‹", currentPage - 1, currentPage == 1, key);

            int from = Math.Max(1, currentPage - 2);
            int to = Math.Min(totalPages, currentPage + 2);

            if (from > 1)
            {
                AddPagerBtn(pnl, "1", 1, false, key);
                if (from > 2) pnl.Controls.Add(new LiteralControl(
                    "<span class='asf-page-btn' style='cursor:default;pointer-events:none;border:none'>…</span>"));
            }
            for (int p = from; p <= to; p++)
                AddPagerBtn(pnl, p.ToString(), p, false, key, p == currentPage);
            if (to < totalPages)
            {
                if (to < totalPages - 1) pnl.Controls.Add(new LiteralControl(
                    "<span class='asf-page-btn' style='cursor:default;pointer-events:none;border:none'>…</span>"));
                AddPagerBtn(pnl, totalPages.ToString(), totalPages, false, key);
            }

            AddPagerBtn(pnl, "›", currentPage + 1, currentPage == totalPages, key);
            AddPagerBtn(pnl, "»", totalPages, currentPage == totalPages, key);
        }

        private void AddPagerBtn(Panel pnl, string text, int page, bool disabled,
                                 string key, bool active = false)
        {
            var btn = new LinkButton
            {
                Text = text,
                CommandArgument = page + "|" + key,
                CssClass = "asf-page-btn" + (active ? " active" : "") + (disabled ? " disabled" : ""),
                Enabled = !disabled
            };
            btn.Click += PagerBtn_Click;
            pnl.Controls.Add(btn);
        }

        protected void PagerBtn_Click(object sender, EventArgs e)
        {
            string[] parts = ((LinkButton)sender).CommandArgument.Split('|');
            if (parts.Length != 2 || !int.TryParse(parts[0], out int page)) return;
            if (parts[1] == "tracker") { TrackerPage = page; BindTracker(); }
            else { WorkloadPage = page; BindWorkload(); }
        }

        // ═════════════════════════════════════════════════════════════════════
        //  SINGLE ASSIGN
        // ═════════════════════════════════════════════════════════════════════
        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (IsSuperAdmin) { ShowToast("Access Denied: SuperAdmin is view-only.", "warning"); return; }
            if (SessionId == 0) { ShowToast("No active session.", "warning"); return; }

            if (!int.TryParse(hfTeacherId.Value?.Trim(), out int teacherId) || teacherId == 0)
            { ShowToast("Please select a teacher from the search results.", "warning"); KeepTab("single"); return; }

            if (!int.TryParse(hfSingleSubjectId.Value?.Trim(), out int subjectId) || subjectId == 0)
            { ShowToast("Please select a subject.", "warning"); KeepTab("single"); return; }

            int sectionId = GetInt(ddlSection.SelectedValue);
            if (sectionId == 0)
            { ShowToast("Please select a section.", "warning"); KeepTab("single"); return; }

            try
            {
                if (_bl.IsAlreadyAssigned(InstituteId, SessionId, teacherId, subjectId, sectionId))
                {
                    ShowToast($"This teacher is already assigned to this subject in Section '{ddlSection.SelectedItem?.Text}'. No duplicate created.", "warning");
                    KeepTab("single"); return;
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

                var dtT = _bl.GetTeacherById(teacherId);
                var dtSub = _bl.GetSubjectById(subjectId, InstituteId, SessionId);
                string tName = dtT.Rows.Count > 0 ? dtT.Rows[0]["FullName"].ToString() : "Teacher";
                string subName = dtSub.Rows.Count > 0 ? dtSub.Rows[0]["SubjectName"].ToString() : "Subject";
                string secName = ddlSection.SelectedItem?.Text ?? "Section";

                _bl.SendNotification(teacherId, SocietyId, InstituteId, SessionId,
                    $"You have been assigned to teach '{subName}' for Section '{secName}'. Please check your dashboard for your updated timetable.",
                    "SubjectFacultyAssign");

                LogActivity(UserId, SocietyId, InstituteId, SessionId,
                    $"ASSIGN_SF: Teacher={tName}, Subject={subName}, Section={secName}", teacherId);

                ShowToast($"'{tName}' assigned to '{subName}' (Sec: {secName}). Teacher notified.", "success");

                // Clear hidden fields
                hfTeacherId.Value = "";
                hfSingleSubjectId.Value = "";
                LoadSections(ddlSection);

                // Tell JS to clear the form but stay on single tab
                ScriptManager.RegisterStartupScript(this, GetType(), "afterSingle",
                    "afterSingleSave();", true);

                TrackerPage = 1;
                WorkloadPage = 1;
                UpdateStats();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[ASF.Save] {ex}");
                ShowToast("An unexpected error occurred. Please try again.", "danger");
                KeepTab("single");
            }
        }

        // ═════════════════════════════════════════════════════════════════════
        //  BULK ASSIGN
        // ═════════════════════════════════════════════════════════════════════
        protected void btnBulkSave_Click(object sender, EventArgs e)
        {
            if (IsSuperAdmin) { ShowToast("Access Denied: SuperAdmin is view-only.", "warning"); return; }
            if (SessionId == 0) { ShowToast("No active session.", "warning"); return; }

            if (!int.TryParse(hfTeacherId.Value?.Trim(), out int teacherId) || teacherId == 0)
            { ShowToast("Please select a teacher.", "warning"); KeepTab("bulk"); return; }

            int sectionId = GetInt(hfBulkSectionId.Value);
            if (sectionId == 0)
            { ShowToast("Please select a section.", "warning"); KeepTab("bulk"); return; }

            string subjectIdsRaw = hfBulkSubjectIds.Value?.Trim();
            if (string.IsNullOrWhiteSpace(subjectIdsRaw))
            { ShowToast("Please tick at least one subject.", "warning"); KeepTab("bulk"); return; }

            var subjectIds = new List<int>();
            foreach (var s in subjectIdsRaw.Split(','))
                if (int.TryParse(s.Trim(), out int sid) && sid > 0)
                    subjectIds.Add(sid);

            if (subjectIds.Count == 0)
            { ShowToast("No valid subjects selected.", "warning"); KeepTab("bulk"); return; }

            try
            {
                int inserted = 0, duplicates = 0;
                var subNames = new List<string>();

                var dtT = _bl.GetTeacherById(teacherId);
                string tName = dtT.Rows.Count > 0 ? dtT.Rows[0]["FullName"].ToString() : "Teacher";
                // Get section name from DB
                var allSecs = _bl.GetSections(InstituteId, SessionId);
                string secName = "Section";
                foreach (DataRow sr in allSecs.Rows)
                    if (Convert.ToInt32(sr["SectionId"]) == sectionId)
                    { secName = sr["SectionName"].ToString(); break; }

                foreach (int subjectId in subjectIds)
                {
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

                    var dtSub = _bl.GetSubjectById(subjectId, InstituteId, SessionId);
                    if (dtSub.Rows.Count > 0) subNames.Add(dtSub.Rows[0]["SubjectName"].ToString());
                    inserted++;
                }

                if (inserted > 0)
                {
                    _bl.SendNotification(teacherId, SocietyId, InstituteId, SessionId,
                        $"You have been assigned to teach {inserted} subject(s) for Section '{secName}': {string.Join(", ", subNames)}. Please check your dashboard.",
                        "BulkSubjectFacultyAssign");

                    LogActivity(UserId, SocietyId, InstituteId, SessionId,
                        $"BULK_ASSIGN_SF: Teacher={tName}, Section={secName}, Count={inserted}", teacherId);
                }

                string msg = inserted > 0
                    ? $"{inserted} subject(s) assigned to '{tName}' (Sec: {secName})."
                    : $"No new assignments — all subjects already assigned for '{tName}'.";
                if (duplicates > 0) msg += $" {duplicates} duplicate(s) skipped.";
                if (inserted > 0) msg += " Teacher notified.";

                ShowToast(msg, inserted > 0 ? "success" : "warning");

                // Clear hidden fields; tell JS to reset bulk form and stay on bulk tab
                hfTeacherId.Value = "";
                hfBulkSectionId.Value = "";
                hfBulkSubjectIds.Value = "";

                ScriptManager.RegisterStartupScript(this, GetType(), "afterBulk",
                    "afterBulkSave();", true);

                TrackerPage = 1;
                WorkloadPage = 1;
                UpdateStats();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[ASF.BulkSave] {ex}");
                ShowToast("An unexpected error occurred. Please try again.", "danger");
                KeepTab("bulk");
            }
        }

        // ═════════════════════════════════════════════════════════════════════
        //  TRACKER ROW COMMANDS
        // ═════════════════════════════════════════════════════════════════════
        protected void gvAssign_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (IsSuperAdmin) { ShowToast("Access Denied.", "warning"); return; }
            if (!int.TryParse(e.CommandArgument?.ToString(), out int id) || id == 0) return;
            try
            {
                switch (e.CommandName)
                {
                    case "Toggle":
                        _bl.Toggle(id);
                        LogActivity(UserId, SocietyId, InstituteId, SessionId, $"TOGGLE_SF: Id={id}", id);
                        ShowToast("Status updated.", "success");
                        break;
                    case "DeleteRow":
                        _bl.Delete(id);
                        LogActivity(UserId, SocietyId, InstituteId, SessionId, $"DELETE_SF: Id={id}", id);
                        ShowToast("Assignment removed.", "success");
                        TrackerPage = 1;
                        break;
                }
                UpdateStats();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[ASF.RowCmd] {ex}");
                ShowToast("Cannot delete — may have attendance records. Use Toggle instead.", "danger");
            }
        }

        // ═════════════════════════════════════════════════════════════════════
        //  WEBMETHOD — Teacher live-search (called by JS fetch, no postback)
        // ═════════════════════════════════════════════════════════════════════
        [WebMethod]
        public static List<object> SearchTeachers(string prefix, string instituteId, string sessionId)
        {
            var list = new List<object>();
            try
            {
                int.TryParse(instituteId, out int instId);
                int.TryParse(sessionId, out int sessId);
                var dt = new AssignSubjectFacultyBL().SearchTeachers(prefix, instId, sessId);
                foreach (DataRow dr in dt.Rows)
                    list.Add(new
                    {
                        UserId = dr["UserId"].ToString(),
                        FullName = dr["FullName"].ToString(),
                        EmployeeId = dr["EmployeeId"].ToString(),
                        StreamName = dr["StreamName"].ToString()
                    });
            }
            catch (Exception ex) { System.Diagnostics.Debug.WriteLine($"[SearchTeachers] {ex}"); }
            return list;
        }

        // ══════════════════════════════════════════════════════════════════════
        //  WEBMETHOD — Get subjects for a section (AJAX, no postback)
        // ══════════════════════════════════════════════════════════════════════
        [WebMethod]
        public static List<object> GetSubjectsForSection(string sectionId, string instituteId, string sessionId)
        {
            var list = new List<object>();
            try
            {
                int.TryParse(sectionId, out int secId);
                int.TryParse(instituteId, out int instId);
                int.TryParse(sessionId, out int sessId);
                var bl = new AssignSubjectFacultyBL();
                var dt = secId > 0
                    ? bl.GetSubjectsForSection(instId, sessId, secId)
                    : bl.GetAllSubjectsPublic(instId, sessId);
                foreach (DataRow dr in dt.Rows)
                    list.Add(new
                    {
                        SubjectId = dr["SubjectId"].ToString(),
                        SubjectCode = dr["SubjectCode"].ToString(),
                        SubjectName = dr["SubjectName"].ToString(),
                        StreamName = dr["StreamName"].ToString(),
                        CourseName = dr["CourseName"].ToString(),
                        LevelName = dr["LevelName"].ToString(),
                        SemesterName = dr["SemesterName"].ToString(),
                        IsMandatory = dr["IsMandatory"].ToString()
                    });
            }
            catch (Exception ex) { System.Diagnostics.Debug.WriteLine($"[GetSubjectsForSection] {ex}"); }
            return list;
        }

        // ══════════════════════════════════════════════════════════════════════
        //  WEBMETHOD — Get sections for a subject (AJAX, no postback)
        // ══════════════════════════════════════════════════════════════════════
        [WebMethod]
        public static List<object> GetSectionsForSubject(string subjectId, string instituteId, string sessionId)
        {
            var list = new List<object>();
            try
            {
                int.TryParse(subjectId, out int subId);
                int.TryParse(instituteId, out int instId);
                int.TryParse(sessionId, out int sessId);
                var dt = new AssignSubjectFacultyBL().GetSectionsForSubject(subId, instId, sessId);
                foreach (DataRow dr in dt.Rows)
                    list.Add(new { SectionId = dr["SectionId"].ToString(), SectionName = dr["SectionName"].ToString() });
            }
            catch (Exception ex) { System.Diagnostics.Debug.WriteLine($"[GetSectionsForSubject] {ex}"); }
            return list;
        }

        // ═════════════════════════════════════════════════════════════════════
        //  ASPX HELPERS
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
            return p.Length == 1 ? p[0].Substring(0, Math.Min(2, p[0].Length)).ToUpper()
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

        // ── Utilities ──────────────────────────────────────────────────────────
        private int GetInt(string val) => int.TryParse(val, out int v) ? v : 0;
        private void KeepTab(string tab) =>
            ScriptManager.RegisterStartupScript(this, GetType(),
                "kt_" + Guid.NewGuid().ToString("N").Substring(0, 6),
                $"switchTab('{tab}');", true);

        private void ShowToast(string msg, string type = "success")
        {
            msg = msg.Replace("'", "\\'").Replace("\r", "").Replace("\n", "");
            ScriptManager.RegisterStartupScript(this, GetType(),
                "t_" + Guid.NewGuid().ToString("N").Substring(0, 8),
                $"serverToast('{msg}','{type}');", true);
        }
    }
}