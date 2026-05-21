using LearningManagementSystem.BL;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace LearningManagementSystem.Admin
{
    public partial class ParentList : BasePage
    {
        // ── BL ────────────────────────────────────────────────────────────────
        private readonly AddParentBL bl = new AddParentBL();

        // ── CONSTANTS ─────────────────────────────────────────────────────────
        private const int PageSize = 8;   // groups per page
        private const int MaxPageButtons = 5; // how many numbered buttons to show

        // ── VIEW-STATE BACKED PROPERTIES ─────────────────────────────────────

        /// <summary>"1" = Active, "0" = Inactive</summary>
        public string CurrentFilter
        {
            get { return ViewState["Filter"] == null ? "1" : ViewState["Filter"].ToString(); }
            set { ViewState["Filter"] = value; }
        }

        /// <summary>Zero-based current page index.</summary>
        private int CurrentPage
        {
            get { return ViewState["CurrentPage"] == null ? 0 : (int)ViewState["CurrentPage"]; }
            set { ViewState["CurrentPage"] = value; }
        }

        // ── PUBLIC FIELDS (rendered in ASPX) ─────────────────────────────────
        public int TotalParents = 0;
        public int ActiveParents = 0;
        public int InactiveParents = 0;
        public int TotalLinks = 0;

        // ══════════════════════════════════════════════════════════════════════
        //  PAGE LOAD
        // ══════════════════════════════════════════════════════════════════════
        protected void Page_Load(object sender, EventArgs e)
        {
            if (SessionId == 0) return;

            if (!IsPostBack)
            {
                CurrentFilter = "1";
                CurrentPage = 0;
            }

            // Always load stats (they use properties, must run every postback)
            LoadStats();

            // Always load data (drives repeater + pagination)
            LoadData();
        }

        // ══════════════════════════════════════════════════════════════════════
        //  TOGGLE ACTIVE / INACTIVE
        // ══════════════════════════════════════════════════════════════════════
        protected void ToggleView_Click(object sender, EventArgs e)
        {
            CurrentFilter = CurrentFilter == "1" ? "0" : "1";
            CurrentPage = 0; // reset to first page on toggle

            btnToggleView.Text = CurrentFilter == "1"
                ? "<i class='fa fa-eye me-1'></i> View Inactive"
                : "<i class='fa fa-eye me-1'></i> View Active";
        }
        // (LoadData and LoadStats are called in Page_Load every postback)

        // ══════════════════════════════════════════════════════════════════════
        //  PAGER CLICK — First / Prev / Next / Last / numbered
        // ══════════════════════════════════════════════════════════════════════
        protected void Pager_Click(object sender, EventArgs e)
        {
            // Derive total pages from the full dataset count
            bool isActive = CurrentFilter == "1";
            DataTable dtAll = bl.GetParentsWithStudentDetails(InstituteId, SessionId, isActive);
            int totalGroups = CountGroups(dtAll);
            int totalPages = (int)Math.Ceiling(totalGroups / (double)PageSize);
            if (totalPages < 1) totalPages = 1;

            string arg = ((LinkButton)sender).CommandArgument;

            switch (arg)
            {
                case "First": CurrentPage = 0; break;
                case "Prev": CurrentPage = Math.Max(0, CurrentPage - 1); break;
                case "Next": CurrentPage = Math.Min(totalPages - 1, CurrentPage + 1); break;
                case "Last": CurrentPage = totalPages - 1; break;
                default:
                    if (int.TryParse(arg, out int pg))
                        CurrentPage = Math.Max(0, Math.Min(totalPages - 1, pg - 1));
                    break;
            }
            // LoadData is called in Page_Load — nothing else needed here.
        }

        // ══════════════════════════════════════════════════════════════════════
        //  LOAD DATA — groups the flat BL result, slices one page, binds
        // ══════════════════════════════════════════════════════════════════════
        private void LoadData()
        {
            bool isActive = CurrentFilter == "1";
            DataTable dt = bl.GetParentsWithStudentDetails(InstituteId, SessionId, isActive);

            // ── Build all grouped objects (same logic as original) ──────────
            var allGroups = dt.AsEnumerable()
                .GroupBy(r => new
                {
                    StudentId = r["StudentId"],
                    StudentName = r["StudentName"].ToString(),
                    Stream = r["StreamName"],
                    Course = r["CourseName"],
                    Level = r["LevelName"],
                    Semester = r["SemesterName"],
                    Section = r["SectionName"],
                    Session = r["SessionName"]
                })
                .Select(g => new
                {
                    StudentName = g.Key.StudentName,
                    Stream = g.Key.Stream == DBNull.Value ? "-" : g.Key.Stream.ToString(),
                    Course = g.Key.Course == DBNull.Value ? "-" : g.Key.Course.ToString(),
                    Level = g.Key.Level == DBNull.Value ? "-" : g.Key.Level.ToString(),
                    Semester = g.Key.Semester == DBNull.Value ? "-" : g.Key.Semester.ToString(),
                    Section = g.Key.Section == DBNull.Value ? "-" : g.Key.Section.ToString(),
                    Session = g.Key.Session == DBNull.Value ? "-" : g.Key.Session.ToString(),
                    Parents = g.Select(x => new
                    {
                        ParentName = x["ParentName"].ToString(),
                        Relation = x["RelationshipType"].ToString(),
                        Email = x["Email"].ToString(),
                        ContactNo = x["ContactNo"].ToString()
                    }).ToList()
                })
                .ToList();

            int totalGroups = allGroups.Count;
            int totalPages = (int)Math.Ceiling(totalGroups / (double)PageSize);
            if (totalPages < 1) totalPages = 1;

            // Guard against out-of-range page (e.g. after toggle)
            if (CurrentPage >= totalPages) CurrentPage = 0;

            // ── Slice for current page ────────────────────────────────────
            var pageGroups = allGroups
                .Skip(CurrentPage * PageSize)
                .Take(PageSize)
                .ToList();

            // ── Bind repeater ─────────────────────────────────────────────
            rptStudents.DataSource = pageGroups;
            rptStudents.DataBind();

            // ── Empty state ───────────────────────────────────────────────
            pnlEmpty.Visible = totalGroups == 0;

            // ── Info bar ──────────────────────────────────────────────────
            int rangeStart = totalGroups == 0 ? 0 : CurrentPage * PageSize + 1;
            int rangeEnd = Math.Min((CurrentPage + 1) * PageSize, totalGroups);

            lblShowRange.Text = rangeStart + "–" + rangeEnd;
            lblTotalCount.Text = totalGroups.ToString();
            lblModeBadge.Text = isActive ? "Active" : "Inactive";
            lblModeBadge.CssClass = isActive ? "pl-mode-badge active" : "pl-mode-badge inactive";

            // ── Pagination panel ──────────────────────────────────────────
            pnlPagination.Visible = totalGroups > PageSize;

            if (pnlPagination.Visible)
            {
                lblCurrentPage.Text = (CurrentPage + 1).ToString();
                lblTotalPages.Text = totalPages.ToString();
                lblPageSummary.Text = $"Page {CurrentPage + 1} of {totalPages}";

                // First / Prev disabled state
                btnFirst.CssClass = "pl-pg-btn" + (CurrentPage == 0 ? " disabled" : "");
                btnPrev.CssClass = "pl-pg-btn" + (CurrentPage == 0 ? " disabled" : "");
                btnFirst.Enabled = CurrentPage > 0;
                btnPrev.Enabled = CurrentPage > 0;

                // Next / Last disabled state
                btnNext.CssClass = "pl-pg-btn" + (CurrentPage >= totalPages - 1 ? " disabled" : "");
                btnLast.CssClass = "pl-pg-btn" + (CurrentPage >= totalPages - 1 ? " disabled" : "");
                btnNext.Enabled = CurrentPage < totalPages - 1;
                btnLast.Enabled = CurrentPage < totalPages - 1;

                // Build numbered page buttons
                BuildPageNumbers(totalPages);
            }
        }

        // ══════════════════════════════════════════════════════════════════════
        //  BUILD NUMBERED PAGE BUTTONS into the PlaceHolder
        // ══════════════════════════════════════════════════════════════════════
        private void BuildPageNumbers(int totalPages)
        {
            phPageNumbers.Controls.Clear();

            // Decide window of page numbers to show (centred around current page)
            int half = MaxPageButtons / 2;
            int start = Math.Max(0, CurrentPage - half);
            int end = Math.Min(totalPages - 1, start + MaxPageButtons - 1);
            // Adjust start if end is at the ceiling
            start = Math.Max(0, end - MaxPageButtons + 1);

            // Left ellipsis
            if (start > 0)
            {
                AddPageButton(1, false);             // always show page 1
                if (start > 1)
                    phPageNumbers.Controls.Add(MakeSep());
            }

            // Window of numbered buttons
            for (int i = start; i <= end; i++)
            {
                AddPageButton(i + 1, i == CurrentPage);
            }

            // Right ellipsis
            if (end < totalPages - 1)
            {
                if (end < totalPages - 2)
                    phPageNumbers.Controls.Add(MakeSep());
                AddPageButton(totalPages, false);    // always show last page
            }
        }

        private void AddPageButton(int pageNumber, bool isActive)
        {
            var btn = new LinkButton
            {
                Text = pageNumber.ToString(),
                CommandName = "Page",
                CommandArgument = pageNumber.ToString(),
                CssClass = "pl-pg-btn" + (isActive ? " active" : ""),
            };
            btn.Click += Pager_Click;
            phPageNumbers.Controls.Add(btn);
        }

        private static Literal MakeSep()
        {
            return new Literal { Text = "<span class='pl-pg-sep'>…</span>" };
        }

        // ══════════════════════════════════════════════════════════════════════
        //  LOAD STATS (unchanged from original)
        // ══════════════════════════════════════════════════════════════════════
        private void LoadStats()
        {
            DataTable dt = bl.GetStats(InstituteId, SessionId);
            if (dt.Rows.Count > 0)
            {
                TotalParents = Convert.ToInt32(dt.Rows[0]["TotalParents"]);
                ActiveParents = Convert.ToInt32(dt.Rows[0]["ActiveParents"]);
                InactiveParents = Convert.ToInt32(dt.Rows[0]["InactiveParents"]);
                TotalLinks = Convert.ToInt32(dt.Rows[0]["TotalLinks"]);
            }
        }

        // ══════════════════════════════════════════════════════════════════════
        //  HELPERS (called from ASPX — must be protected)
        // ══════════════════════════════════════════════════════════════════════

        /// <summary>Returns CSS class for parent avatar based on relation type.</summary>
        protected string GetRelationClass(object relation)
        {
            string r = relation?.ToString()?.ToLower() ?? "";
            if (r.Contains("father") || r.Contains("dad")) return "pl-av-father";
            if (r.Contains("mother") || r.Contains("mom")) return "pl-av-mother";
            if (r.Contains("guardian")) return "pl-av-guardian";
            return "pl-av-default";
        }

        // ── Private helper ────────────────────────────────────────────────────
        private static int CountGroups(DataTable dt)
        {
            if (dt == null || dt.Rows.Count == 0) return 0;
            return dt.AsEnumerable()
                     .Select(r => r["StudentId"].ToString())
                     .Distinct()
                     .Count();
        }
    }
}