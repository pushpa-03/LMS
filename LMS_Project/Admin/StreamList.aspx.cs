using LMS.BL;
using System;
using System.Data;
using System.Collections.Generic;
using System.Web.UI.WebControls;

namespace LearningManagementSystem.Admin
{
    public partial class StreamList : BasePage
    {
        StreamBL bl = new StreamBL();

       

        private string CurrentFilter
        {
            get { return ViewState["Filter"] != null ? ViewState["Filter"].ToString() : "1"; }
            set { ViewState["Filter"] = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if(SessionId == 0)
            {
                return;
            }

            if (!IsPostBack)
            {
                LoadStreams();
            }
        }

       
        void LoadStreams()
        {
            DataTable dt = bl.GetStreams(InstituteId, SessionId, CurrentFilter);

            // SEARCH
            if (!string.IsNullOrWhiteSpace(txtSearch.Value))
            {
                string search = txtSearch.Value.Replace("'", "''");

                DataRow[] rows = dt.Select($"StreamName LIKE '%{search}%'");

                dt = rows.Length > 0
                    ? rows.CopyToDataTable()
                    : dt.Clone();
            }

            // ===== PAGING =====
            PagedDataSource pg = new PagedDataSource();

            pg.DataSource = dt.DefaultView;

            pg.AllowPaging = true;

            pg.PageSize = 5;

            pg.CurrentPageIndex = CurrentPage;

            rptStreams.DataSource = pg;
            rptStreams.DataBind();

            // ===== PAGER =====
            pagerDiv.Visible = pg.PageCount > 1;

            GeneratePager(pg.PageCount);

            // ===== EMPTY =====
            pnlEmpty.Visible = dt.Rows.Count == 0;

            // ===== STATS =====
            int total = dt.Rows.Count;
            int active = dt.Select("IsActive = true").Length;
            int inactive = dt.Select("IsActive = false").Length;

            lblTotal.Text = total.ToString();
            lblActive.Text = active.ToString();
            lblInactive.Text = inactive.ToString();

            lblPercent.Text = total > 0
                ? ((active * 100) / total) + "%"
                : "0%";
        }

        private void GeneratePager(int totalPages)
        {
            List<dynamic> pages = new List<dynamic>();

            int start = Math.Max(CurrentPage - 2, 0);
            int end = Math.Min(start + 4, totalPages - 1);

            for (int i = start; i <= end; i++)
            {
                pages.Add(new
                {
                    Text = (i + 1).ToString(),
                    Value = i,
                    Selected = i == CurrentPage
                });
            }

            rptPager.DataSource = pages;
            rptPager.DataBind();
        }

        protected void Pager_Click(object sender, EventArgs e)
        {
            LinkButton btn = (LinkButton)sender;

            DataTable dt = bl.GetStreams(InstituteId, SessionId, CurrentFilter);

            int totalPages = (int)Math.Ceiling((double)dt.Rows.Count / 5);

            switch (btn.CommandArgument)
            {
                case "First":
                    CurrentPage = 0;
                    break;

                case "Prev":
                    if (CurrentPage > 0)
                        CurrentPage--;
                    break;

                case "Next":
                    if (CurrentPage < totalPages - 1)
                        CurrentPage++;
                    break;

                case "Last":
                    CurrentPage = totalPages - 1;
                    break;

                default:
                    CurrentPage = Convert.ToInt32(btn.CommandArgument);
                    break;
            }

            LoadStreams();

            upStreams.Update();
        }
        // ================= FILTER =================
        protected void Filter_Click(object sender, EventArgs e)
        {
            if (CurrentFilter == "1")
            {
                CurrentFilter = "0";
                btnToggleView.Text = "👁 View Active";
            }
            else
            {
                CurrentFilter = "1";
                btnToggleView.Text = "👁 View Inactive";
            }

            LoadStreams();
        }

        private int CurrentPage
        {
            get
            {
                return ViewState["CurrentPage"] != null
                    ? Convert.ToInt32(ViewState["CurrentPage"])
                    : 0;
            }
            set
            {
                ViewState["CurrentPage"] = value;
            }
        }
    }
}