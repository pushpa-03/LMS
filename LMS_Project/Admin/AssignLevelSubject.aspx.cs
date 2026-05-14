using LearningManagementSystem.BL;
using LearningManagementSystem.GC;
using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace LearningManagementSystem.Admin
{
    public partial class AssignLevelSubject : BasePage
    {
        private readonly AssignLevelSubjectBL _bl = new AssignLevelSubjectBL();

        // ── Tracker Pagination ────────────────────────────────────────────────
        private const int TrackerPageSize = 3;

        private int TrackerPage
        {
            get => (int)(ViewState["TrackerPage"] ?? 1);
            set => ViewState["TrackerPage"] = value;
        }

        private bool IsSuperAdmin =>
            Session["Role"]?.ToString()
                .Equals("SuperAdmin", StringComparison.OrdinalIgnoreCase) == true;

        // ═════════════════════════════════════════════════════════════════════
        //  PAGE LOAD
        //
        //  ★ KEY FIX: BindTracker() is called on EVERY request (not just
        //  !IsPostBack). BuildTrackerPager() adds LinkButton controls
        //  dynamically to pnlTrackerPager. WebForms rule: dynamic controls
        //  must be re-added in Page_Load on every postback so the framework
        //  can match and fire their Click events. If only added on !IsPostBack,
        //  the buttons appear but clicking them causes a full postback where
        //  the buttons don't exist → event never fires → page stays on page 1.
        // ═════════════════════════════════════════════════════════════════════
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                ConfigureRoleUI();
                SetSessionLabel();

                if (SessionId == 0)
                {
                    ShowToast("No active academic session found. Please configure a session first.", "warning");
                    return;
                }

                LoadAllDropdowns();
                LoadSubjectsGrid();
                UpdateHeaderStats();
            }

            // ★ Always bind tracker — required so pager LinkButtons are
            //   re-added to the control tree on every postback
            if (SessionId > 0)
                BindTracker();
        }

        // ── Role UI ──────────────────────────────────────────────────────────
        private void ConfigureRoleUI()
        {
            lblSuperAdminBadge.Visible = IsSuperAdmin;
            pnlSaveBtn.Visible = !IsSuperAdmin;
            pnlSuperAdminNote.Visible = IsSuperAdmin;

            if (IsSuperAdmin)
                ScriptManager.RegisterStartupScript(this, GetType(), "hideDel",
                    "document.querySelectorAll('.als-del-btn').forEach(function(b){b.style.display='none';});",
                    true);
        }

        private void SetSessionLabel()
        {
            lblSessionName.Text = Session["SessionName"]?.ToString() ?? "—";
        }

        // ── Header stats ─────────────────────────────────────────────────────
        private void UpdateHeaderStats()
        {
            if (SessionId == 0) return;
            DataTable dt = _bl.GetStats(InstituteId, SessionId);
            if (dt.Rows.Count > 0)
            {
                lblTotalAssigned.Text = dt.Rows[0]["TotalAssigned"].ToString();
                lblActiveSubjects.Text = dt.Rows[0]["ActiveSubjects"].ToString();
            }
        }

        // ═════════════════════════════════════════════════════════════════════
        //  DROPDOWNS
        // ═════════════════════════════════════════════════════════════════════
        private void LoadAllDropdowns()
        {
            LoadStreams();
            LoadLevels();
            LoadSemesters();
            LoadSections();
            LoadTrackerStreamFilter();
        }

        private void LoadStreams()
        {
            DataTable dt = _bl.GetStreams(InstituteId, SessionId);
            ddlStream.Items.Clear();
            ddlStream.Items.Add(new ListItem("-- Select Stream --", "0"));
            foreach (DataRow dr in dt.Rows)
                ddlStream.Items.Add(new ListItem(dr["StreamName"].ToString(), dr["StreamId"].ToString()));
        }

        private void LoadCourses(int streamId)
        {
            DataTable dt = streamId > 0 ? _bl.GetCourses(streamId, SessionId) : new DataTable();
            ddlCourse.Items.Clear();
            ddlCourse.Items.Add(new ListItem("-- Select Course --", "0"));
            foreach (DataRow dr in dt.Rows)
                ddlCourse.Items.Add(new ListItem(dr["CourseName"].ToString(), dr["CourseId"].ToString()));
        }

        private void LoadLevels()
        {
            DataTable dt = _bl.GetLevels(InstituteId, SessionId);
            ddlLevel.Items.Clear();
            ddlLevel.Items.Add(new ListItem("-- Select Level --", "0"));
            foreach (DataRow dr in dt.Rows)
                ddlLevel.Items.Add(new ListItem(dr["LevelName"].ToString(), dr["LevelId"].ToString()));
        }

        private void LoadSemesters()
        {
            DataTable dt = _bl.GetSemesters(InstituteId, SessionId);
            ddlSemester.Items.Clear();
            ddlSemester.Items.Add(new ListItem("-- Select Semester --", "0"));
            foreach (DataRow dr in dt.Rows)
                ddlSemester.Items.Add(new ListItem(dr["SemesterName"].ToString(), dr["SemesterId"].ToString()));
        }

        private void LoadSections()
        {
            DataTable dt = _bl.GetSections(InstituteId, SessionId);
            ddlSection.Items.Clear();
            ddlSection.Items.Add(new ListItem("-- All Sections --", "0"));
            foreach (DataRow dr in dt.Rows)
                ddlSection.Items.Add(new ListItem(dr["SectionName"].ToString(), dr["SectionId"].ToString()));
        }

        private void LoadTrackerStreamFilter()
        {
            DataTable dt = _bl.GetStreams(InstituteId, SessionId);
            ddlTrackerStream.Items.Clear();
            ddlTrackerStream.Items.Add(new ListItem("All Streams", "0"));
            foreach (DataRow dr in dt.Rows)
                ddlTrackerStream.Items.Add(new ListItem(dr["StreamName"].ToString(), dr["StreamId"].ToString()));
        }

        // ═════════════════════════════════════════════════════════════════════
        //  DROPDOWN POSTBACK HANDLERS
        // ═════════════════════════════════════════════════════════════════════
        protected void ddlStream_Changed(object sender, EventArgs e)
        {
            LoadCourses(GetDdlInt(ddlStream));
            LoadSubjectsGrid();
            ShowAlreadyAssignedBox();
            UpdatePathBar();
        }

        protected void ddlCourse_Changed(object sender, EventArgs e)
        {
            LoadSubjectsGrid();
            ShowAlreadyAssignedBox();
            UpdatePathBar();
        }

        protected void ddlLevel_Changed(object sender, EventArgs e)
        {
            LoadSubjectsGrid();
            ShowAlreadyAssignedBox();
            UpdatePathBar();
        }

        protected void ddlSemester_Changed(object sender, EventArgs e)
        {
            LoadSubjectsGrid();
            ShowAlreadyAssignedBox();
            UpdatePathBar();
        }

        protected void ddlTrackerStream_Changed(object sender, EventArgs e)
        {
            TrackerPage = 1;
            // BindTracker() already called in Page_Load — no need to call again
        }

        private void UpdatePathBar()
        {
            ScriptManager.RegisterStartupScript(this, GetType(), "updatePath", "updatePathBar();", true);
        }

        // ═════════════════════════════════════════════════════════════════════
        //  SUBJECTS GRID (left panel)
        // ═════════════════════════════════════════════════════════════════════
        private void LoadSubjectsGrid()
        {
            if (SessionId == 0) return;

            DataTable dt = _bl.GetSubjectsWithAssignedFlag(
                InstituteId, SessionId,
                GetDdlInt(ddlStream), GetDdlInt(ddlCourse),
                GetDdlInt(ddlLevel), GetDdlInt(ddlSemester));

            gvSubjects.DataSource = dt;
            gvSubjects.DataBind();

            ScriptManager.RegisterStartupScript(this, GetType(), "subCnt",
                $"var sc=document.getElementById('subjectCount');if(sc)sc.textContent='{dt.Rows.Count}';",
                true);
        }

        private void ShowAlreadyAssignedBox()
        {
            int streamId = GetDdlInt(ddlStream);
            int courseId = GetDdlInt(ddlCourse);
            int levelId = GetDdlInt(ddlLevel);
            int semesterId = GetDdlInt(ddlSemester);

            if (streamId == 0 || levelId == 0 || semesterId == 0)
            { pnlAlreadyAssigned.Visible = false; return; }

            DataTable dt = _bl.GetAlreadyAssigned(InstituteId, SessionId, streamId, courseId, levelId, semesterId);
            if (dt.Rows.Count == 0) { pnlAlreadyAssigned.Visible = false; return; }

            pnlAlreadyAssigned.Visible = true;
            var sb = new StringBuilder();
            foreach (DataRow dr in dt.Rows)
            {
                string cls = Convert.ToBoolean(dr["IsMandatory"])
                    ? " bg-danger-subtle text-danger" : " bg-info-subtle text-info";
                sb.Append($"<span class='badge rounded-pill{cls} px-2 py-1 me-1' style='font-size:11px'>{dr["SubjectName"]}</span>");
            }
            litAssignedTags.Text = sb.ToString();

            ScriptManager.RegisterStartupScript(this, GetType(), "assignCnt",
                $"var ac=document.getElementById('assignedCount');if(ac)ac.textContent='{dt.Rows.Count}';",
                true);
        }

        // ═════════════════════════════════════════════════════════════════════
        //  SAVE — ASSIGN SUBJECTS
        // ═════════════════════════════════════════════════════════════════════
        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (IsSuperAdmin) { ShowToast("Access Denied: SuperAdmin has view-only access.", "warning"); return; }
            if (SessionId == 0) { ShowToast("No active academic session found.", "warning"); return; }

            int streamId = GetDdlInt(ddlStream);
            int courseId = GetDdlInt(ddlCourse);
            int levelId = GetDdlInt(ddlLevel);
            int semesterId = GetDdlInt(ddlSemester);
            int sectionId = GetDdlInt(ddlSection);

            if (streamId == 0) { ShowToast("Please select a Stream.", "warning"); return; }
            if (levelId == 0) { ShowToast("Please select a Level.", "warning"); return; }
            if (semesterId == 0) { ShowToast("Please select a Semester.", "warning"); return; }

            var toInsert = new List<LevelSemesterSubjectGC>();
            int duplicates = 0;
            int selected = 0;

            try
            {
                foreach (GridViewRow row in gvSubjects.Rows)
                {
                    if (row.RowType != DataControlRowType.DataRow) continue;

                    var chk = row.FindControl("chkSelect") as CheckBox;
                    if (chk == null || !chk.Checked) continue;

                    selected++;
                    int subjectId = Convert.ToInt32(gvSubjects.DataKeys[row.RowIndex].Value);
                    bool mandatory = (row.FindControl("chkMandatory") as CheckBox)?.Checked ?? true;

                    if (_bl.IsAlreadyAssigned(InstituteId, SessionId, streamId, courseId, levelId, semesterId, subjectId))
                    { duplicates++; continue; }

                    toInsert.Add(new LevelSemesterSubjectGC
                    {
                        SocietyId = SocietyId,
                        InstituteId = InstituteId,
                        SessionId = SessionId,
                        StreamId = streamId,
                        CourseId = courseId > 0 ? courseId : (int?)null,
                        LevelId = levelId > 0 ? levelId : (int?)null,
                        SemesterId = semesterId > 0 ? semesterId : (int?)null,
                        SubjectId = subjectId,
                        IsMandatory = mandatory
                    });
                }

                if (selected == 0)
                { ShowToast("Please select at least one subject to assign.", "warning"); return; }

                if (toInsert.Count == 0 && duplicates > 0)
                { ShowToast($"All {duplicates} selected subject(s) are already assigned. No changes made.", "warning"); return; }

                if (toInsert.Count > 0)
                    _bl.InsertBatch(toInsert);

                LogActivity(UserId, SocietyId, InstituteId, SessionId,
                    $"ASSIGN_SUBJECTS: Stream={streamId}, Level={levelId}, Sem={semesterId}, Count={toInsert.Count}", 0);

                string msg = $"{toInsert.Count} subject(s) assigned successfully.";
                if (duplicates > 0) msg += $" {duplicates} already assigned — skipped.";
                ShowToast(msg, "success");

                LoadSubjectsGrid();
                ShowAlreadyAssignedBox();
                UpdateHeaderStats();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[AssignLevelSubject.Save] {ex}");
                ShowToast("An unexpected error occurred. Please try again.", "danger");
            }
        }

        // ═════════════════════════════════════════════════════════════════════
        //  TRACKER GRIDVIEW  (called from Page_Load on every request)
        // ═════════════════════════════════════════════════════════════════════
        private void BindTracker()
        {
            if (SessionId == 0) return;

            int filterStream = GetDdlInt(ddlTrackerStream);
            DataTable dtAll = _bl.GetAssignmentTracker(InstituteId, SessionId, filterStream);

            int total = dtAll.Rows.Count;
            int totalPages = (int)Math.Ceiling((double)total / TrackerPageSize);
            if (totalPages < 1) totalPages = 1;
            if (TrackerPage > totalPages) TrackerPage = totalPages;
            if (TrackerPage < 1) TrackerPage = 1;

            int start = (TrackerPage - 1) * TrackerPageSize;
            int end = Math.Min(start + TrackerPageSize, total);

            DataTable dtPage = dtAll.Clone();
            for (int i = start; i < end; i++)
                dtPage.ImportRow(dtAll.Rows[i]);

            gvTracker.DataSource = dtPage;
            gvTracker.DataBind();

            BuildTrackerPager(totalPages);

            if (IsSuperAdmin)
                ScriptManager.RegisterStartupScript(this, GetType(), "hideDelT",
                    "document.querySelectorAll('.als-del-btn').forEach(function(b){b.style.display='none';});",
                    true);
        }

        // ═════════════════════════════════════════════════════════════════════
        //  TRACKER PAGER
        //
        //  ★ FIX 1: Use a NAMED method (TrackerPagerBtn_Click) instead of a
        //    lambda. Lambdas on dynamic controls are never matched by the
        //    WebForms postback event dispatch mechanism.
        //
        //  ★ FIX 2: BuildTrackerPager() is called inside BindTracker() which
        //    runs in Page_Load on EVERY request. This means buttons are always
        //    in the control tree when postback event processing happens.
        // ═════════════════════════════════════════════════════════════════════
        private void BuildTrackerPager(int totalPages)
        {
            pnlTrackerPager.Controls.Clear();
            if (totalPages <= 1) return;

            // «  First
            AddTrackerBtn("«", 1, TrackerPage == 1);
            // ‹  Prev
            AddTrackerBtn("‹", TrackerPage - 1, TrackerPage == 1);

            int from = Math.Max(1, TrackerPage - 2);
            int to = Math.Min(totalPages, TrackerPage + 2);

            if (from > 1)
            {
                AddTrackerBtn("1", 1, false);
                if (from > 2)
                    pnlTrackerPager.Controls.Add(new LiteralControl(
                        "<span class='als-page-btn' style='cursor:default;pointer-events:none;border:none'>…</span>"));
            }

            for (int p = from; p <= to; p++)
                AddTrackerBtn(p.ToString(), p, false, p == TrackerPage);

            if (to < totalPages)
            {
                if (to < totalPages - 1)
                    pnlTrackerPager.Controls.Add(new LiteralControl(
                        "<span class='als-page-btn' style='cursor:default;pointer-events:none;border:none'>…</span>"));
                AddTrackerBtn(totalPages.ToString(), totalPages, false);
            }

            // ›  Next
            AddTrackerBtn("›", TrackerPage + 1, TrackerPage == totalPages);
            // »  Last
            AddTrackerBtn("»", totalPages, TrackerPage == totalPages);
        }

        private void AddTrackerBtn(string text, int page, bool disabled, bool active = false)
        {
            var btn = new LinkButton
            {
                Text = text,
                CommandArgument = page.ToString(),
                CssClass = "als-page-btn"
                                  + (active ? " active" : "")
                                  + (disabled ? " disabled" : ""),
                Enabled = !disabled
            };
            // ★ Named method — not a lambda
            btn.Click += TrackerPagerBtn_Click;
            pnlTrackerPager.Controls.Add(btn);
        }

        // ★ Named handler — this is what actually fires on button click
        protected void TrackerPagerBtn_Click(object sender, EventArgs e)
        {
            if (int.TryParse(((LinkButton)sender).CommandArgument, out int p))
            {
                TrackerPage = p;
                // BindTracker() runs in Page_Load — but since we're in an
                // event handler which fires AFTER Page_Load, we call it again
                // explicitly so the grid updates with the new page immediately.
                BindTracker();
            }
        }

        // ═════════════════════════════════════════════════════════════════════
        //  TRACKER ROW COMMANDS
        // ═════════════════════════════════════════════════════════════════════
        protected void gvTracker_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName != "RemoveAssign") return;

            if (IsSuperAdmin) { ShowToast("Access Denied: SuperAdmin has view-only access.", "warning"); return; }

            if (!int.TryParse(e.CommandArgument?.ToString(), out int id) || id == 0) return;

            try
            {
                _bl.RemoveAssignment(id);
                LogActivity(UserId, SocietyId, InstituteId, SessionId, $"REMOVE_SUBJECT_ASSIGN: Id={id}", id);
                ShowToast("Subject assignment removed successfully.", "success");
                LoadSubjectsGrid();
                ShowAlreadyAssignedBox();
                UpdateHeaderStats();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[AssignLevelSubject.Remove] {ex}");
                ShowToast("Failed to remove assignment. Please try again.", "danger");
            }
        }

        // ═════════════════════════════════════════════════════════════════════
        //  HELPERS
        // ═════════════════════════════════════════════════════════════════════
        private int GetDdlInt(DropDownList ddl)
        {
            if (ddl == null) return 0;
            return int.TryParse(ddl.SelectedValue, out int v) ? v : 0;
        }

        private void ShowToast(string msg, string type = "success")
        {
            msg = msg.Replace("'", "\\'").Replace("\r", "").Replace("\n", "");
            ScriptManager.RegisterStartupScript(this, GetType(),
                "toast_" + Guid.NewGuid().ToString("N").Substring(0, 8),
                $"serverToast('{msg}', '{type}');", true);
        }
    }

}