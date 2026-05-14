using System;
using System.Collections.Generic;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace LearningManagementSystem.Admin
{
    public partial class AssignStudentSubject : BasePage
    {
        private readonly AssignStudentSubjectBL _bl = new AssignStudentSubjectBL();

        private const int SubjPageSize = 10;
        private const int StudPageSize = 10;
        private const int TrackerPageSize = 5;

        // ── ViewState page indices ──────────────────────────────────
        private int SubjPage { get => (int)(ViewState["SubjPage"] ?? 1); set => ViewState["SubjPage"] = value; }
        private int StudPage { get => (int)(ViewState["StudPage"] ?? 1); set => ViewState["StudPage"] = value; }
        private int TrackerPage { get => (int)(ViewState["TrackerPage"] ?? 1); set => ViewState["TrackerPage"] = value; }

        // ── Stored filter IDs (in ViewState — survive postback) ─────
        private int VS_StreamId { get => (int)(ViewState["vs_str"] ?? 0); set => ViewState["vs_str"] = value; }
        private int VS_CourseId { get => (int)(ViewState["vs_crs"] ?? 0); set => ViewState["vs_crs"] = value; }
        private int VS_LevelId { get => (int)(ViewState["vs_lvl"] ?? 0); set => ViewState["vs_lvl"] = value; }
        private int VS_SemId { get => (int)(ViewState["vs_sem"] ?? 0); set => ViewState["vs_sem"] = value; }
        private int VS_SecId { get => (int)(ViewState["vs_sec"] ?? 0); set => ViewState["vs_sec"] = value; }

        // ── Total row counts (for pager labels) ────────────────────
        private int VS_SubjTotal { get => (int)(ViewState["vs_stot"] ?? 0); set => ViewState["vs_stot"] = value; }
        private int VS_StudTotal { get => (int)(ViewState["vs_dtot"] ?? 0); set => ViewState["vs_dtot"] = value; }

        private bool IsSuperAdmin =>
            Session["Role"]?.ToString().Equals("SuperAdmin", StringComparison.OrdinalIgnoreCase) == true;

        // ══════════════════════════════════════════════════════════════
        //  PAGE LOAD
        // ══════════════════════════════════════════════════════════════
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                ConfigureRoleUI();
                lblSessionName.Text = Session["SessionName"]?.ToString() ?? "—";
                if (SessionId == 0) { ShowToast("No active academic session found.", "warning"); return; }

                LoadStreams();
                LoadLevels();
                LoadSemesters();
                LoadSections();
                BindTracker();
                UpdateHeaderStats();
            }
        }

        private void ConfigureRoleUI()
        {
            lblSuperAdminBadge.Visible = IsSuperAdmin;
            pnlLoadBtn.Visible = !IsSuperAdmin;
            pnlAssignBtn.Visible = !IsSuperAdmin;
            pnlSuperAdminNote.Visible = IsSuperAdmin;
        }

        private void UpdateHeaderStats()
        {
            try
            {
                DataTable dt = _bl.GetStats(InstituteId, SessionId);
                if (dt?.Rows.Count > 0)
                {
                    lblTotalAssigned.Text = dt.Rows[0]["TotalAssignments"].ToString();
                    lblStudentsAssigned.Text = dt.Rows[0]["StudentsAssigned"].ToString();
                    lblPending.Text = dt.Rows[0]["StudentsPending"].ToString();
                }
            }
            catch (Exception ex) { Log("[Stats]", ex); }
        }

        // ══════════════════════════════════════════════════════════════
        //  DROPDOWN LOADERS
        // ══════════════════════════════════════════════════════════════
        private void LoadStreams()
        {
            ddlStream.Items.Clear();
            ddlStream.Items.Add(new ListItem("-- Select Stream --", "0"));
            foreach (DataRow r in _bl.GetStreams(InstituteId, SessionId).Rows)
                ddlStream.Items.Add(new ListItem(r["StreamName"].ToString(), r["StreamId"].ToString()));
        }

        private void LoadCourses(int streamId)
        {
            ddlCourse.Items.Clear();
            ddlCourse.Items.Add(new ListItem("-- Select Course --", "0"));
            if (streamId <= 0) return;
            foreach (DataRow r in _bl.GetCourses(streamId, SessionId).Rows)
                ddlCourse.Items.Add(new ListItem(r["CourseName"].ToString(), r["CourseId"].ToString()));
        }

        private void LoadLevels()
        {
            ddlLevel.Items.Clear();
            ddlLevel.Items.Add(new ListItem("-- Level --", "0"));
            foreach (DataRow r in _bl.GetLevels(InstituteId, SessionId).Rows)
                ddlLevel.Items.Add(new ListItem(r["LevelName"].ToString(), r["LevelId"].ToString()));
        }

        private void LoadSemesters()
        {
            ddlSemester.Items.Clear();
            ddlSemester.Items.Add(new ListItem("-- Semester --", "0"));
            foreach (DataRow r in _bl.GetSemesters(InstituteId, SessionId).Rows)
                ddlSemester.Items.Add(new ListItem(r["SemesterName"].ToString(), r["SemesterId"].ToString()));
        }

        private void LoadSections()
        {
            ddlSection.Items.Clear();
            ddlSection.Items.Add(new ListItem("-- All Sections --", "0"));
            foreach (DataRow r in _bl.GetSections(InstituteId, SessionId).Rows)
                ddlSection.Items.Add(new ListItem(r["SectionName"].ToString(), r["SectionId"].ToString()));
        }

        // ══════════════════════════════════════════════════════════════
        //  DROPDOWN CHANGE EVENTS
        // ══════════════════════════════════════════════════════════════
        protected void ddlStream_Changed(object sender, EventArgs e) { LoadCourses(Ddl(ddlStream)); ClearGrids(); }
        protected void ddlCourse_Changed(object sender, EventArgs e) => ClearGrids();
        protected void ddlLevel_Changed(object sender, EventArgs e) => ClearGrids();
        protected void ddlSemester_Changed(object sender, EventArgs e) => ClearGrids();
        protected void ddlSection_Changed(object sender, EventArgs e) => ClearGrids();

        private void ClearGrids()
        {
            gvSubjects.DataSource = null; gvSubjects.DataBind();
            gvStudents.DataSource = null; gvStudents.DataBind();
            pnlSubjPager.Visible = false;
            pnlStudPager.Visible = false;
            VS_StreamId = VS_CourseId = VS_LevelId = VS_SemId = VS_SecId = 0;
            VS_SubjTotal = VS_StudTotal = 0;
            hfStreamId.Value = hfCourseId.Value = hfLevelId.Value =
            hfSemesterId.Value = hfSectionId.Value = "0";
            hfSelectedSubjects.Value = "";
        }

        protected void ddlTrackerFilter_Changed(object sender, EventArgs e)
        {
            TrackerPage = 1;
            BindTracker();
        }

        // ══════════════════════════════════════════════════════════════
        //  LOAD BUTTON
        // ══════════════════════════════════════════════════════════════
        protected void btnLoad_Click(object sender, EventArgs e)
        {
            if (IsSuperAdmin) { ShowToast("SuperAdmin has view-only access.", "warning"); return; }
            if (SessionId == 0) { ShowToast("No active academic session.", "warning"); return; }

            int streamId = Ddl(ddlStream), courseId = Ddl(ddlCourse),
                levelId = Ddl(ddlLevel), semId = Ddl(ddlSemester),
                secId = Ddl(ddlSection);

            if (streamId == 0 || levelId == 0 || semId == 0)
            { ShowToast("Please select Stream, Level and Semester.", "warning"); return; }

            try
            {
                DataTable dtSubj = _bl.GetSubjectsForClass(InstituteId, SessionId, streamId, courseId, levelId, semId);
                DataTable dtStud = _bl.GetStudentsWithAssignmentStatus(InstituteId, SessionId, streamId, courseId, levelId, semId, secId);

                // Store totals and filter IDs in ViewState
                VS_StreamId = streamId; VS_CourseId = courseId;
                VS_LevelId = levelId; VS_SemId = semId;
                VS_SecId = secId;
                VS_SubjTotal = dtSubj.Rows.Count;
                VS_StudTotal = dtStud.Rows.Count;

                // Also sync HiddenFields (for Assign button)
                hfStreamId.Value = streamId.ToString();
                hfCourseId.Value = courseId.ToString();
                hfLevelId.Value = levelId.ToString();
                hfSemesterId.Value = semId.ToString();
                hfSectionId.Value = secId.ToString();
                hfSelectedSubjects.Value = "";

                SubjPage = StudPage = 1;
                BindSubjPage(dtSubj);
                BindStudPage(dtStud);

                Script($"document.getElementById('subjCount').textContent='{dtSubj.Rows.Count}';" +
                       $"document.getElementById('studCount').textContent='{dtStud.Rows.Count}';" +
                       "updatePathBar();");

                if (dtSubj.Rows.Count == 0)
                    ShowToast("No subjects configured for this class.", "warning");
                else if (dtStud.Rows.Count == 0)
                    ShowToast("No students enrolled in this class.", "warning");
                else
                    ShowToast($"Loaded {dtSubj.Rows.Count} subject(s) and {dtStud.Rows.Count} student(s). Select subjects and click Assign.", "info");
            }
            catch (Exception ex) { Log("[Load]", ex); ShowToast("Failed to load: " + ex.Message, "danger"); }
        }

        // ══════════════════════════════════════════════════════════════
        //  SUBJECT PAGER BUTTONS
        //  Re-query DB using stored ViewState filter IDs — no DataTable in ViewState
        // ══════════════════════════════════════════════════════════════
        protected void SubjPrev_Click(object sender, EventArgs e) { SubjPage = Math.Max(1, SubjPage - 1); ReloadSubjGrid(); }
        protected void SubjNext_Click(object sender, EventArgs e) { SubjPage++; ReloadSubjGrid(); }

        private void ReloadSubjGrid()
        {
            if (VS_StreamId == 0) return;
            try
            {
                DataTable dt = _bl.GetSubjectsForClass(InstituteId, SessionId,
                    VS_StreamId, VS_CourseId, VS_LevelId, VS_SemId);
                VS_SubjTotal = dt.Rows.Count;
                BindSubjPage(dt);
            }
            catch (Exception ex) { Log("[ReloadSubj]", ex); }
        }

        private void BindSubjPage(DataTable dt)
        {
            int total = dt.Rows.Count;
            int pages = Math.Max(1, (int)Math.Ceiling((double)total / SubjPageSize));
            if (SubjPage < 1) SubjPage = 1;
            if (SubjPage > pages) SubjPage = pages;

            int start = (SubjPage - 1) * SubjPageSize;
            DataTable page = dt.Clone();
            for (int i = start; i < Math.Min(start + SubjPageSize, total); i++)
                page.ImportRow(dt.Rows[i]);

            gvSubjects.DataSource = page;
            gvSubjects.DataBind();

            // Pager visibility & labels
            pnlSubjPager.Visible = pages > 1;
            btnSubjPrev.Enabled = SubjPage > 1;
            btnSubjNext.Enabled = SubjPage < pages;
            lblSubjPage.Text = $"Page {SubjPage} of {pages}  ({total} subjects)";
        }

        // ══════════════════════════════════════════════════════════════
        //  STUDENT PAGER BUTTONS
        // ══════════════════════════════════════════════════════════════
        protected void StudPrev_Click(object sender, EventArgs e) { StudPage = Math.Max(1, StudPage - 1); ReloadStudGrid(); }
        protected void StudNext_Click(object sender, EventArgs e) { StudPage++; ReloadStudGrid(); }

        private void ReloadStudGrid()
        {
            if (VS_StreamId == 0) return;
            try
            {
                DataTable dt = _bl.GetStudentsWithAssignmentStatus(InstituteId, SessionId,
                    VS_StreamId, VS_CourseId, VS_LevelId, VS_SemId, VS_SecId);
                VS_StudTotal = dt.Rows.Count;
                BindStudPage(dt);
            }
            catch (Exception ex) { Log("[ReloadStud]", ex); }
        }

        private void BindStudPage(DataTable dt)
        {
            int total = dt.Rows.Count;
            int pages = Math.Max(1, (int)Math.Ceiling((double)total / StudPageSize));
            if (StudPage < 1) StudPage = 1;
            if (StudPage > pages) StudPage = pages;

            int start = (StudPage - 1) * StudPageSize;
            DataTable page = dt.Clone();
            for (int i = start; i < Math.Min(start + StudPageSize, total); i++)
                page.ImportRow(dt.Rows[i]);

            gvStudents.DataSource = page;
            gvStudents.DataBind();

            pnlStudPager.Visible = pages > 1;
            btnStudPrev.Enabled = StudPage > 1;
            btnStudNext.Enabled = StudPage < pages;
            lblStudPage.Text = $"Page {StudPage} of {pages}  ({total} students)";
        }

        // ══════════════════════════════════════════════════════════════
        //  ROW DATABOUND
        // ══════════════════════════════════════════════════════════════
        protected void gvSubjects_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType != DataControlRowType.DataRow) return;
            var hf = e.Row.FindControl("hfSubjectId") as HiddenField;
            if (hf != null)
                hf.Value = DataBinder.Eval(e.Row.DataItem, "SubjectId").ToString();
        }

        // ══════════════════════════════════════════════════════════════
        //  ASSIGN BUTTON
        // ══════════════════════════════════════════════════════════════
        protected void btnAssign_Click(object sender, EventArgs e)
        {
            if (IsSuperAdmin) { ShowToast("Access Denied: SuperAdmin view-only.", "warning"); return; }
            if (SessionId == 0) { ShowToast("No active academic session.", "warning"); return; }

            int streamId = HF(hfStreamId), courseId = HF(hfCourseId),
                levelId = HF(hfLevelId), semId = HF(hfSemesterId),
                secId = HF(hfSectionId);

            if (streamId == 0 || levelId == 0 || semId == 0)
            { ShowToast("Please click 'Load Students & Subjects' first.", "warning"); return; }

            string raw = (hfSelectedSubjects.Value ?? "").Trim();
            System.Diagnostics.Debug.WriteLine("[Assign] raw=" + raw);

            if (string.IsNullOrEmpty(raw))
            { ShowToast("No subjects selected. Please tick at least one subject.", "warning"); return; }

            var subjectIds = new List<int>();
            foreach (var t in raw.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries))
                if (int.TryParse(t.Trim(), out int sid) && sid > 0) subjectIds.Add(sid);

            if (subjectIds.Count == 0) { ShowToast("Could not read subject IDs. Try again.", "warning"); return; }

            DataTable dtAll;
            try { dtAll = _bl.GetStudentsForClass(InstituteId, SessionId, streamId, courseId, levelId, semId, secId); }
            catch (Exception ex) { ShowToast("Failed to load students: " + ex.Message, "danger"); return; }

            if (dtAll.Rows.Count == 0) { ShowToast("No students found for this class.", "warning"); return; }

            int inserted = 0, skipped = 0;
            foreach (DataRow sr in dtAll.Rows)
            {
                int uid = Convert.ToInt32(sr["UserId"]);
                foreach (int subId in subjectIds)
                {
                    try
                    {
                        if (_bl.InsertIfNew(uid, subId, SocietyId, InstituteId, SessionId)) inserted++;
                        else skipped++;
                    }
                    catch (Exception ex) { Log("[Insert]", ex); }
                }
            }

            // Notifications
            if (inserted > 0)
            {
                try
                {
                    DataTable dtN = _bl.GetSubjectNamesByIds(subjectIds, SessionId, InstituteId);
                    var names = new List<string>();
                    foreach (DataRow r in dtN.Rows) names.Add(r["SubjectName"].ToString());
                    string msg = $"You have been assigned {names.Count} subject(s): {string.Join(", ", names)}.";
                    foreach (DataRow sr in dtAll.Rows)
                        _bl.SendNotification(Convert.ToInt32(sr["UserId"]), SocietyId, InstituteId, SessionId, msg, "SubjectAssignment");
                }
                catch (Exception ex) { Log("[Notify]", ex); }
            }

            try { LogActivity(UserId, SocietyId, InstituteId, SessionId, $"ASSIGN_STUDENT_SUBJECTS Inserted={inserted}", 0); }
            catch { }

            string toastMsg = inserted > 0
                ? $"{inserted} assignment(s) saved. {skipped} already existed (skipped). Students notified."
                : $"All subjects already assigned — {skipped} skipped. Nothing new added.";
            ShowToast(toastMsg, inserted > 0 ? "success" : "warning");

            hfSelectedSubjects.Value = "";

            // Refresh grids — re-query DB
            try
            {
                DataTable dtSubj = _bl.GetSubjectsForClass(InstituteId, SessionId, streamId, courseId, levelId, semId);
                DataTable dtStud = _bl.GetStudentsWithAssignmentStatus(InstituteId, SessionId, streamId, courseId, levelId, semId, secId);
                VS_SubjTotal = dtSubj.Rows.Count;
                VS_StudTotal = dtStud.Rows.Count;
                BindSubjPage(dtSubj);
                BindStudPage(dtStud);
                Script($"document.getElementById('studCount').textContent='{dtStud.Rows.Count}';");
            }
            catch (Exception ex) { Log("[RefreshGrids]", ex); }

            TrackerPage = 1;
            BindTracker();
            UpdateHeaderStats();
        }

        // ══════════════════════════════════════════════════════════════
        //  TRACKER GRID
        // ══════════════════════════════════════════════════════════════
        private void BindTracker()
        {
            if (SessionId == 0) return;
            try
            {
                string filter = ddlTrackerFilter.SelectedValue;
                DataTable dtAll = _bl.GetAssignmentTracker(InstituteId, SessionId, filter);

                int total = dtAll.Rows.Count;
                int pages = Math.Max(1, (int)Math.Ceiling((double)total / TrackerPageSize));
                if (TrackerPage < 1) TrackerPage = 1;
                if (TrackerPage > pages) TrackerPage = pages;

                int start = (TrackerPage - 1) * TrackerPageSize;
                DataTable page = dtAll.Clone();
                for (int i = start; i < Math.Min(start + TrackerPageSize, total); i++)
                    page.ImportRow(dtAll.Rows[i]);

                gvAssigned.DataSource = page;
                gvAssigned.DataBind();

                BuildTrackerPager(pages, total);
            }
            catch (Exception ex)
            {
                Log("[BindTracker]", ex);
                gvAssigned.DataSource = null;
                gvAssigned.DataBind();
            }
        }

        private void BuildTrackerPager(int totalPages, int totalRows)
        {
            pnlTrackerPager.Controls.Clear();
            if (totalPages <= 1) return;

            int start = (TrackerPage - 1) * TrackerPageSize + 1;
            int end = Math.Min(TrackerPage * TrackerPageSize, totalRows);
            pnlTrackerPager.Controls.Add(new LiteralControl(
                $"<span class='text-muted small me-2'>{start}–{end} of {totalRows}</span>"));

            AddPageBtn("‹", TrackerPage - 1, TrackerPage == 1);
            int from = Math.Max(1, TrackerPage - 2), to = Math.Min(totalPages, TrackerPage + 2);
            if (from > 1) { AddPageBtn("1", 1, false); if (from > 2) AddEllipsis(); }
            for (int p = from; p <= to; p++) AddPageBtn(p.ToString(), p, false, p == TrackerPage);
            if (to < totalPages) { if (to < totalPages - 1) AddEllipsis(); AddPageBtn(totalPages.ToString(), totalPages, false); }
            AddPageBtn("›", TrackerPage + 1, TrackerPage == totalPages);
        }

        private void AddPageBtn(string text, int page, bool disabled, bool active = false)
        {
            var btn = new LinkButton
            {
                Text = text,
                CommandArgument = page.ToString(),
                CssClass = "ass-page-btn" + (active ? " active" : ""),
                Enabled = !disabled
            };
            btn.Click += (s, ev) =>
            {
                if (int.TryParse(((LinkButton)s).CommandArgument, out int p))
                { TrackerPage = p; BindTracker(); }
            };
            pnlTrackerPager.Controls.Add(btn);
        }

        private void AddEllipsis() =>
            pnlTrackerPager.Controls.Add(new LiteralControl(
                "<span class='ass-page-btn' style='cursor:default;pointer-events:none'>…</span>"));

        // ══════════════════════════════════════════════════════════════
        //  TRACKER ROW COMMAND
        // ══════════════════════════════════════════════════════════════
        protected void gvAssigned_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName != "DeleteRow") return;
            if (IsSuperAdmin) { ShowToast("SuperAdmin has view-only access.", "warning"); return; }
            if (!int.TryParse(e.CommandArgument?.ToString(), out int id) || id == 0)
            { ShowToast("Invalid record.", "warning"); return; }

            try
            {
                _bl.DeleteAssignment(id);
                try { LogActivity(UserId, SocietyId, InstituteId, SessionId, $"REMOVE_ASSIGN Id={id}", id); } catch { }
                ShowToast("Assignment removed.", "success");

                BindTracker();
                UpdateHeaderStats();

                // Refresh student grid if class is loaded
                if (VS_StreamId > 0 && VS_LevelId > 0 && VS_SemId > 0)
                {
                    DataTable dtStud = _bl.GetStudentsWithAssignmentStatus(
                        InstituteId, SessionId, VS_StreamId, VS_CourseId, VS_LevelId, VS_SemId, VS_SecId);
                    VS_StudTotal = dtStud.Rows.Count;
                    BindStudPage(dtStud);
                }
            }
            catch (Exception ex) { Log("[Delete]", ex); ShowToast("Failed: " + ex.Message, "danger"); }
        }

        // ══════════════════════════════════════════════════════════════
        //  HELPERS
        // ══════════════════════════════════════════════════════════════
        private static readonly string[] _colors = {
            "#4f46e5","#0891b2","#059669","#d97706","#dc2626","#7c3aed","#db2777","#0d9488"
        };
        protected string GetAvatarColor(string name) =>
            string.IsNullOrWhiteSpace(name) ? _colors[0]
            : _colors[Math.Abs(name.GetHashCode()) % _colors.Length];

        protected string GetInitials(string name)
        {
            if (string.IsNullOrWhiteSpace(name)) return "?";
            var p = name.Trim().Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            return p.Length == 1
                ? p[0].Substring(0, Math.Min(2, p[0].Length)).ToUpper()
                : (p[0][0].ToString() + p[p.Length - 1][0]).ToUpper();
        }

        private int Ddl(DropDownList d) => d == null ? 0 : (int.TryParse(d.SelectedValue, out int v) ? v : 0);
        private int HF(HiddenField h) => h == null ? 0 : (int.TryParse(h.Value, out int v) ? v : 0);

        private void Script(string js) =>
            ScriptManager.RegisterStartupScript(this, GetType(),
                "sc_" + Guid.NewGuid().ToString("N").Substring(0, 6), js, true);

        private void ShowToast(string msg, string type = "success")
        {
            msg = msg.Replace("'", "\\'").Replace("\r", "").Replace("\n", " ");
            Script($"serverToast('{msg}','{type}');");
        }

        private void Log(string tag, Exception ex) =>
            System.Diagnostics.Debug.WriteLine($"{tag} {ex.Message}");
    }
}