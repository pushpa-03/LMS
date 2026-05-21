using LearningManagementSystem.BL;
using System;
using System.Data;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace LearningManagementSystem.Admin
{
    public partial class TeacherList : BasePage
    {
        AddTeacherBL bl = new AddTeacherBL();

        // ── Pagination ─────────────────────────────────────────
        private const int PageSize = 10;
        private int CurrentPage
        {
            get => ViewState["TLPage"] != null ? Convert.ToInt32(ViewState["TLPage"]) : 1;
            set => ViewState["TLPage"] = value;
        }

      
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (SessionId == 0) return;

                LoadStreams();

                // Default filter = Active teachers
                ddlStatus.SelectedValue = "1";
            }

            if (SessionId > 0)
                BindTeacherData();
        }

        private void LoadStreams()
        {
            ddlStream.DataSource = bl.GetStreams(InstituteId, SessionId);
            ddlStream.DataTextField = "StreamName";
            ddlStream.DataValueField = "StreamId";
            ddlStream.DataBind();
            ddlStream.Items.Insert(0, new ListItem("All Departments", "0"));
        }

        private void BindTeacherData()
        {
            string search = txtSearch.Text.Trim();
            int streamId = Convert.ToInt32(ddlStream.SelectedValue);
            string status = ddlStatus.SelectedValue;

            DataTable dtAll = bl.GetFilteredTeachers(InstituteId, SessionId,
                                                     search, streamId, status);

            foreach (DataColumn col in dtAll.Columns)
            {
                System.Diagnostics.Debug.WriteLine(col.ColumnName);
            }

            // ── Stat Cards Counts ─────────────────────────────
            int totalFaculty = dtAll.Rows.Count;

            int activeFaculty = dtAll.AsEnumerable()
                .Count(r => r["IsActive"] != DBNull.Value &&
                            Convert.ToBoolean(r["IsActive"]) == true);

            int inactiveFaculty = dtAll.AsEnumerable()
                .Count(r => r["IsActive"] != DBNull.Value &&
                            Convert.ToBoolean(r["IsActive"]) == false);

            int totalDepartments = dtAll.AsEnumerable()
                .Where(r => r["Stream"] != DBNull.Value &&
                            !string.IsNullOrWhiteSpace(r["Stream"].ToString()))
                .Select(r => r["Stream"].ToString())
                .Distinct()
                .Count();

            // Assign to frontend literals
            litTotal.Text = totalFaculty.ToString();
            litActive.Text = activeFaculty.ToString();
            litInactive.Text = inactiveFaculty.ToString();
            litDepts.Text = totalDepartments.ToString();

            // Pagination
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

            BuildPager(totalPages);

            // Record info label
            string info = total == 0
                ? "No teachers found"
                : $"Showing {(total == 0 ? 0 : start + 1)}–{end} of {total} teachers";
            ScriptManager.RegisterStartupScript(this, GetType(), "pgInfo",
                $"var el=document.getElementById('pgInfo');if(el)el.textContent='{info}';", true);
        }

        // ── Server-side pager ───────────────────────────────────
        private void BuildPager(int totalPages)
        {
            pnlPager.Controls.Clear();
            if (totalPages <= 1) return;

            AddBtn("«", 1, CurrentPage == 1);
            AddBtn("‹", CurrentPage - 1, CurrentPage == 1);

            int from = Math.Max(1, CurrentPage - 2);
            int to = Math.Min(totalPages, CurrentPage + 2);

            if (from > 1)
            {
                AddBtn("1", 1, false);
                if (from > 2) pnlPager.Controls.Add(new LiteralControl(
                    "<span class='tl-pg-btn' style='cursor:default;pointer-events:none;border:none'>…</span>"));
            }

            for (int p = from; p <= to; p++)
                AddBtn(p.ToString(), p, false, p == CurrentPage);

            if (to < totalPages)
            {
                if (to < totalPages - 1) pnlPager.Controls.Add(new LiteralControl(
                    "<span class='tl-pg-btn' style='cursor:default;pointer-events:none;border:none'>…</span>"));
                AddBtn(totalPages.ToString(), totalPages, false);
            }

            AddBtn("›", CurrentPage + 1, CurrentPage == totalPages);
            AddBtn("»", totalPages, CurrentPage == totalPages);
        }

        private void AddBtn(string text, int page, bool disabled, bool active = false)
        {
            var btn = new LinkButton
            {
                Text = text,
                CommandArgument = page.ToString(),
                CssClass = "tl-pg-btn"
                                  + (active ? " active" : "")
                                  + (disabled ? " disabled" : ""),
                Enabled = !disabled
            };
            btn.Click += PageBtn_Click; // ★ named method — not lambda
            pnlPager.Controls.Add(btn);
        }

        // ★ Named Click handler — fires correctly on postback
        protected void PageBtn_Click(object sender, EventArgs e)
        {
            if (int.TryParse(((LinkButton)sender).CommandArgument, out int p))
            {
                CurrentPage = p;
                // BindTeacherData() already called in Page_Load (which runs first),
                // but CurrentPage changed AFTER that call, so re-bind explicitly.
                BindTeacherData();
            }
        }

        // ── Filter / clear postbacks ────────────────────────────
        protected void Filter_Changed(object sender, EventArgs e)
        {
            CurrentPage = 1;
            // BindTeacherData() called in Page_Load already
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            txtSearch.Text = "";
            ddlStream.SelectedIndex = 0;

            // Default back to Active
            ddlStatus.SelectedValue = "1";

            CurrentPage = 1;
        }

        // ── Row commands ────────────────────────────────────────
        protected void gvTeachers_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            string userId = e.CommandArgument.ToString();
            if (e.CommandName == "ViewDetails")
                Response.Redirect($"TeacherDetails.aspx?id={userId}");
            else if (e.CommandName == "EditRow")
                Response.Redirect($"AddTeacher.aspx?id={userId}");
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
    }
}