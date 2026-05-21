using LearningManagementSystem.BL;
using LearningManagementSystem.GC;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace LearningManagementSystem.Admin
{
    public partial class AddCourse : BasePage
    {
        // ─── BL ───────────────────────────────────────────────────────────────
        private readonly CourseBL bl = new CourseBL();

        // ─── Role guard ───────────────────────────────────────────────────────
        public bool IsSuperAdmin => Session["Role"]?.ToString() == "SuperAdmin";

        // ─── Pagination constants ─────────────────────────────────────────────
        // One "page" = this many stream groups.
        // Change this number to show more/fewer streams per page.
        private const int StreamsPerPage = 3;

        // ─── ViewState-backed current page (1-based) ──────────────────────────
        private int CurrentPage
        {
            get => ViewState["CoursePage"] is int v ? v : 1;
            set => ViewState["CoursePage"] = value;
        }

        // ─── ViewState-backed current filter ─────────────────────────────────
        private string CurrentFilter
        {
            get => ViewState["CourseFilter"]?.ToString() ?? "All";
            set => ViewState["CourseFilter"] = value;
        }

        // ═════════════════════════════════════════════════════════════════════
        //  PAGE LOAD
        //  CRITICAL: LoadStreams + LoadCourses must run on EVERY postback,
        //  because BuildPager() adds dynamic LinkButton controls to phPageNums.
        //  ASP.NET WebForms requires dynamic controls to be re-added inside
        //  Page_Load (before event processing), not in Page_PreRender.
        // ═════════════════════════════════════════════════════════════════════
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadStreams();
                CurrentPage = 1;
                CurrentFilter = "All";
            }

            // Always rebuild the course list + pager on every request
            LoadCourses(CurrentFilter);
        }

        // ═════════════════════════════════════════════════════════════════════
        //  LOAD STREAMS (dropdowns only — not affected by pagination)
        // ═════════════════════════════════════════════════════════════════════
        private void LoadStreams()
        {
            DataTable dt = bl.GetStreams(InstituteId, SessionId);

            // Add modal dropdown
            ddlStream.Items.Clear();
            ddlStream.DataSource = dt;
            ddlStream.DataTextField = "StreamName";
            ddlStream.DataValueField = "StreamId";
            ddlStream.DataBind();
            ddlStream.Items.Insert(0, new ListItem("-- Select Stream --", ""));

            // Edit modal dropdown
            ddlStreamEdit.Items.Clear();
            ddlStreamEdit.DataSource = dt;
            ddlStreamEdit.DataTextField = "StreamName";
            ddlStreamEdit.DataValueField = "StreamId";
            ddlStreamEdit.DataBind();
            ddlStreamEdit.Items.Insert(0, new ListItem("-- Select Stream --", ""));
        }

        // ═════════════════════════════════════════════════════════════════════
        //  LOAD COURSES — build grouped stream table, apply search + filter,
        //  slice one page of stream groups, bind repeater, build pager.
        // ═════════════════════════════════════════════════════════════════════
        private void LoadCourses(string status = "All")
        {
            // ── 1. Fetch from DB ────────────────────────────────────────────
            DataTable dt = bl.GetCourses(InstituteId, SessionId, status);

            // ── 2. Search filter (client-side HtmlInputText) ────────────────
            string search = txtSearch.Value?.Trim().ToLower() ?? "";
            if (!string.IsNullOrEmpty(search))
            {
                var filtered = dt.AsEnumerable()
                    .Where(r => r["CourseName"].ToString().ToLower().Contains(search)
                             || r["CourseCode"].ToString().ToLower().Contains(search));
                dt = filtered.Any() ? filtered.CopyToDataTable() : dt.Clone();
            }

            // ── 3. Stats (always based on full filtered set) ─────────────────
            lblTotal.Text = dt.Rows.Count.ToString();
            lblActive.Text = dt.Select("IsActive = true").Length.ToString();
            lblInactive.Text = dt.Select("IsActive = false").Length.ToString();

            // ── 4. Filter badge ──────────────────────────────────────────────
            SetFilterBadge(status);

            // ── 5. Build full stream-grouped DataTable (ALL streams) ─────────
            DataTable allStreams = BuildStreamTable(dt);

            int totalStreams = allStreams.Rows.Count;
            int totalCourses = dt.Rows.Count;
            int totalPages = (int)Math.Ceiling(totalStreams / (double)StreamsPerPage);
            if (totalPages < 1) totalPages = 1;

            // Guard page bounds (e.g. after delete shrinks list)
            if (CurrentPage > totalPages) CurrentPage = totalPages;
            if (CurrentPage < 1) CurrentPage = 1;

            // ── 6. Slice one page of stream groups ───────────────────────────
            int skip = (CurrentPage - 1) * StreamsPerPage;
            int take = Math.Min(StreamsPerPage, totalStreams - skip);

            DataTable pageStreams = allStreams.Clone();
            for (int i = skip; i < skip + take && i < totalStreams; i++)
                pageStreams.ImportRow(allStreams.Rows[i]);

            // ── 7. Info bar labels ───────────────────────────────────────────
            lblTotalStreams.Text = totalStreams.ToString();
            lblTotalCourses.Text = totalCourses.ToString();
            lblRangeFrom.Text = totalStreams == 0 ? "0" : (skip + 1).ToString();
            lblRangeTo.Text = (skip + take).ToString();

            // ── 8. Bind repeater ─────────────────────────────────────────────
            rptStreams.DataSource = pageStreams;
            rptStreams.DataBind();

            // ── 9. Pagination panel + pager buttons ───────────────────────────
            pnlPagination.Visible = totalStreams > StreamsPerPage;
            if (pnlPagination.Visible)
            {
                lblCurrentPage.Text = CurrentPage.ToString();
                lblTotalPages.Text = totalPages.ToString();

                // «  ‹  disabled when on first page
                btnFirst.CssClass = "ac-pg-btn" + (CurrentPage == 1 ? " disabled" : "");
                btnPrev.CssClass = "ac-pg-btn" + (CurrentPage == 1 ? " disabled" : "");
                btnFirst.Enabled = CurrentPage > 1;
                btnPrev.Enabled = CurrentPage > 1;

                // ›  »  disabled when on last page
                btnNext.CssClass = "ac-pg-btn" + (CurrentPage >= totalPages ? " disabled" : "");
                btnLast.CssClass = "ac-pg-btn" + (CurrentPage >= totalPages ? " disabled" : "");
                btnNext.Enabled = CurrentPage < totalPages;
                btnLast.Enabled = CurrentPage < totalPages;

                BuildPageNumbers(totalPages);
            }
        }

        // ── Helper: build the full stream→courses grouped DataTable ───────────
        private DataTable BuildStreamTable(DataTable courseRows)
        {
            DataTable st = new DataTable();
            st.Columns.Add("StreamId");
            st.Columns.Add("StreamName");
            st.Columns.Add("CourseCount", typeof(int));
            st.Columns.Add("Courses", typeof(DataTable));

            if (courseRows.Rows.Count == 0) return st;

            DataTable distinctStreams = new DataView(courseRows)
                .ToTable(true, "StreamId", "StreamName");

            foreach (DataRow row in distinctStreams.Rows)
            {
                string sid = row["StreamId"].ToString();
                DataRow[] rows = courseRows.Select("StreamId=" + sid);

                DataRow nr = st.NewRow();
                nr["StreamId"] = sid;
                nr["StreamName"] = row["StreamName"];
                nr["CourseCount"] = rows.Length;
                if (rows.Length > 0)
                    nr["Courses"] = rows.CopyToDataTable();
                st.Rows.Add(nr);
            }
            return st;
        }

        // ── Helper: numbered page buttons in phPageNums ───────────────────────
        private void BuildPageNumbers(int totalPages)
        {
            phPageNums.Controls.Clear();

            const int MaxVisible = 5;
            int half = MaxVisible / 2;
            int start = Math.Max(1, CurrentPage - half);
            int end = Math.Min(totalPages, start + MaxVisible - 1);
            // Shift start left if end hits ceiling
            start = Math.Max(1, end - MaxVisible + 1);

            // Leading ellipsis block
            if (start > 1)
            {
                AddNumBtn(1, false);
                if (start > 2)
                    phPageNums.Controls.Add(new LiteralControl(
                        "<span class='ac-pg-sep'>…</span>"));
            }

            // Window of numbered buttons
            for (int p = start; p <= end; p++)
                AddNumBtn(p, p == CurrentPage);

            // Trailing ellipsis block
            if (end < totalPages)
            {
                if (end < totalPages - 1)
                    phPageNums.Controls.Add(new LiteralControl(
                        "<span class='ac-pg-sep'>…</span>"));
                AddNumBtn(totalPages, false);
            }
        }

        private void AddNumBtn(int page, bool isActive)
        {
            var btn = new LinkButton
            {
                Text = page.ToString(),
                CommandArgument = page.ToString(),
                CssClass = "ac-pg-btn" + (isActive ? " active" : ""),
                Enabled = !isActive   // active page not clickable
            };
            btn.Click += Pager_Click;
            phPageNums.Controls.Add(btn);
        }

        // ═════════════════════════════════════════════════════════════════════
        //  PAGER CLICK  (First / Prev / numbered / Next / Last)
        // ═════════════════════════════════════════════════════════════════════
        protected void Pager_Click(object sender, EventArgs e)
        {
            // Derive total pages from full dataset
            DataTable dtAll = bl.GetCourses(InstituteId, SessionId, CurrentFilter);
            DataTable allStr = BuildStreamTable(dtAll);
            int totalPages = (int)Math.Ceiling(allStr.Rows.Count / (double)StreamsPerPage);
            if (totalPages < 1) totalPages = 1;

            string arg = ((LinkButton)sender).CommandArgument;
            switch (arg)
            {
                case "First": CurrentPage = 1; break;
                case "Prev": CurrentPage = Math.Max(1, CurrentPage - 1); break;
                case "Next": CurrentPage = Math.Min(totalPages, CurrentPage + 1); break;
                case "Last": CurrentPage = totalPages; break;
                default:
                    if (int.TryParse(arg, out int pg))
                        CurrentPage = Math.Max(1, Math.Min(totalPages, pg));
                    break;
            }
            // LoadCourses is called inside Page_Load on every postback.
        }

        // ═════════════════════════════════════════════════════════════════════
        //  ITEM DATABOUND — bind the inner course Repeater for each stream row
        // ═════════════════════════════════════════════════════════════════════
        protected void rptStreams_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item &&
                e.Item.ItemType != ListItemType.AlternatingItem) return;

            DataRowView drv = (DataRowView)e.Item.DataItem;
            Repeater rptC = (Repeater)e.Item.FindControl("rptCourses");

            if (rptC == null) return;

            if (drv["Courses"] != DBNull.Value)
            {
                rptC.DataSource = (DataTable)drv["Courses"];
                rptC.DataBind();
            }
            else
            {
                rptC.DataSource = new DataTable();
                rptC.DataBind();
            }
        }

        // ═════════════════════════════════════════════════════════════════════
        //  INNER COURSE REPEATER ITEM COMMAND (Edit / Toggle / Delete)
        // ═════════════════════════════════════════════════════════════════════
        protected void rptCourses_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (!int.TryParse(e.CommandArgument?.ToString(), out int id))
            {
                ShowMsg("Invalid course.", false); return;
            }

            switch (e.CommandName)
            {
                case "EditRow": HandleEdit(id); break;
                case "Toggle": HandleToggle(id); break;
                case "DeleteRow": HandleDelete(id); break;
            }
        }

        private void HandleEdit(int id)
        {
            if (IsSuperAdmin) { ShowMsg("SuperAdmin has view-only access.", false); return; }

            DataTable dt = bl.GetById(id, InstituteId, SessionId);
            if (dt == null || dt.Rows.Count == 0) return;

            DataRow r = dt.Rows[0];
            hfCourseId.Value = id.ToString();

            // SafeSelect — clears all items first to prevent multi-select crash
            SafeSelect(ddlStreamEdit, r["StreamId"].ToString());

            txtCourseNameEdit.Text = r["CourseName"].ToString();
            txtCourseCodeEdit.Text = r["CourseCode"].ToString();

            ScriptManager.RegisterStartupScript(this, GetType(), "editModal",
                "var m=new bootstrap.Modal(document.getElementById('EditModal'));m.show();",
                true);
        }

        private void HandleToggle(int id)
        {
            if (IsSuperAdmin) { ShowMsg("SuperAdmin has view-only access.", false); return; }
            bl.Toggle(id, InstituteId, SessionId);
            LogActivity(UserId, SocietyId, InstituteId, SessionId, "Course Status Changed", id);
            ShowMsg("Status changed successfully.", true);
        }

        private void HandleDelete(int id)
        {
            if (IsSuperAdmin) { ShowMsg("SuperAdmin has view-only access.", false); return; }

            bool ok = bl.Delete(id, InstituteId, SessionId, out string msg);
            if (ok)
                LogActivity(UserId, SocietyId, InstituteId, SessionId, "Course Deleted", id);

            // If deleting the last course on the last page, guard page index
            DataTable dtAll = bl.GetCourses(InstituteId, SessionId, CurrentFilter);
            DataTable allStr = BuildStreamTable(dtAll);
            int totalPages = (int)Math.Ceiling(allStr.Rows.Count / (double)StreamsPerPage);
            if (totalPages < 1) totalPages = 1;
            if (CurrentPage > totalPages) CurrentPage = totalPages;

            // Refresh dropdowns in case a stream becomes empty
            LoadStreams();
            ShowMsg(msg, ok);
        }

        // ═════════════════════════════════════════════════════════════════════
        //  SAVE (INSERT)
        // ═════════════════════════════════════════════════════════════════════
        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (IsSuperAdmin) { ShowMsg("SuperAdmin has view-only access.", false); return; }

            string name = txtCourseName.Text.Trim();
            string code = txtCourseCode.Text.Trim();

            if (ddlStream.SelectedValue == "" || string.IsNullOrWhiteSpace(name))
            { ShowMsg("Please select a stream and enter a course name.", false); return; }

            if (!IsValidCourseName(name))
            { ShowMsg("Course name must start with a letter and contain no special characters.", false); return; }

            if (!string.IsNullOrWhiteSpace(code) && !IsValidCourseCode(code))
            { ShowMsg("Course code must contain only letters and numbers.", false); return; }

            int streamId = Convert.ToInt32(ddlStream.SelectedValue);

            if (bl.IsCourseExists(InstituteId, SessionId, streamId, name))
            { ShowMsg("A course with this name already exists in the selected stream.", false); return; }

            bl.Insert(new CourseGC
            {
                SocietyId = SocietyId,
                InstituteId = InstituteId,
                SessionId = SessionId,
                StreamId = streamId,
                CourseName = name,
                CourseCode = code
            });

            LogActivity(UserId, SocietyId, InstituteId, SessionId, "Course Created: " + name, 0);

            txtCourseName.Text = "";
            txtCourseCode.Text = "";
            ddlStream.SelectedIndex = 0;

            ShowMsg("Course added successfully.", true);
        }

        // ═════════════════════════════════════════════════════════════════════
        //  UPDATE
        // ═════════════════════════════════════════════════════════════════════
        protected void btnUpdate_Click(object sender, EventArgs e)
        {
            if (IsSuperAdmin) { ShowMsg("SuperAdmin has view-only access.", false); return; }

            if (string.IsNullOrEmpty(hfCourseId.Value) || ddlStreamEdit.SelectedValue == "")
            { ShowMsg("All fields are required.", false); return; }

            string name = txtCourseNameEdit.Text.Trim();
            string code = txtCourseCodeEdit.Text.Trim();
            int courseId = Convert.ToInt32(hfCourseId.Value);

            if (!IsValidCourseName(name))
            { ShowMsg("Invalid course name.", false); return; }

            if (!string.IsNullOrWhiteSpace(code) && !IsValidCourseCode(code))
            { ShowMsg("Invalid course code.", false); return; }

            int streamId = Convert.ToInt32(ddlStreamEdit.SelectedValue);

            if (bl.IsCourseExists(InstituteId, SessionId, streamId, name, courseId))
            { ShowMsg("A course with this name already exists in the selected stream.", false); return; }

            bl.Update(new CourseGC
            {
                CourseId = courseId,
                InstituteId = InstituteId,
                SessionId = SessionId,
                StreamId = streamId,
                CourseName = name,
                CourseCode = code
            });

            LogActivity(UserId, SocietyId, InstituteId, SessionId, "Course Updated: " + name, courseId);
            ShowMsg("Course updated successfully.", true);
        }

        // ═════════════════════════════════════════════════════════════════════
        //  FILTER
        // ═════════════════════════════════════════════════════════════════════
        protected void FilterStatus_Click(object sender, EventArgs e)
        {
            LinkButton btn = (LinkButton)sender;
            CurrentFilter = btn.CommandArgument;
            CurrentPage = 1;   // reset to first page on every filter change
            // LoadCourses is called in Page_Load — no need to call again here
        }

        // ═════════════════════════════════════════════════════════════════════
        //  HELPERS
        // ═════════════════════════════════════════════════════════════════════

        // SafeSelect: prevent "Cannot have multiple items selected" crash
        private static void SafeSelect(DropDownList ddl, string value)
        {
            if (ddl == null) return;
            foreach (ListItem item in ddl.Items) item.Selected = false;
            ListItem match = ddl.Items.FindByValue(value);
            if (match != null) match.Selected = true;
        }

        private static bool IsValidCourseName(string name) =>
            System.Text.RegularExpressions.Regex.IsMatch(name, @"^[A-Za-z][A-Za-z0-9 ]*$");

        private static bool IsValidCourseCode(string code) =>
            System.Text.RegularExpressions.Regex.IsMatch(code, @"^[A-Za-z0-9]+$");

        private void SetFilterBadge(string status)
        {
            switch (status)
            {
                case "1":
                    lblFilterBadge.Text = "Showing: Active only";
                    lblFilterBadge.CssClass = "ac-filter-active-badge" +
                                               " " + "ac-filter-btn active-filter";
                    break;
                case "0":
                    lblFilterBadge.Text = "Showing: Inactive only";
                    lblFilterBadge.CssClass = "ac-filter-active-badge" +
                                               " " + "ac-filter-btn inactive-filter";
                    break;
                default:
                    lblFilterBadge.Text = "Showing: All courses";
                    lblFilterBadge.CssClass = "ac-filter-active-badge" +
                                               " " + "ac-filter-btn all-filter";
                    break;
            }
        }

        // ShowMsg: writes to hidden fields → JS fires the toast after postback.
        // This avoids calling ScriptManager.RegisterStartupScript with Bootstrap
        // toast code (which can silently fail before Bootstrap is loaded).
        private void ShowMsg(string msg, bool success)
        {
            hfToastMsg.Value = msg;
            hfToastType.Value = success ? "success" : "error";

            // Also register a direct startup script as belt-and-suspenders
            string escaped = msg.Replace("'", "\\'");
            ScriptManager.RegisterStartupScript(this, GetType(),
                "toast_" + Guid.NewGuid().ToString("N").Substring(0, 6),
                $"document.addEventListener('DOMContentLoaded',function(){{" +
                $"showToast('{escaped}','{(success ? "success" : "error")}');}});",
                true);
        }
    }
}