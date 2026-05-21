using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using LearningManagementSystem.BL;

namespace LearningManagementSystem.Admin
{
    public partial class CourseList : BasePage
    {
        CourseBL bl = new CourseBL();

        // Page size for client-side pagination (stream cards per page)
        // Set via hidden field so JS can read it
        private const int CardsPerPage = 3;

        protected void Page_Load(object sender, EventArgs e)
        {
            // Always load — we need current data on every postback
            LoadCourses(ViewState["FilterStatus"]?.ToString() ?? "All");
        }

        private void LoadCourses(string status = "All")
        {
            // Full data for stats
            DataTable dtAll = bl.GetCourses(InstituteId, SessionId, "All");

            // Filtered display data
            DataTable dt = status == "All"
                ? dtAll
                : bl.GetCourses(InstituteId, SessionId, status);

            // Server-side search filter (applied on full filtered set)
            string search = txtSearch.Value?.Trim() ?? "";
            if (!string.IsNullOrEmpty(search))
            {
                string safe = search.Replace("'", "''");
                DataRow[] rows = dt.Select(
                    $"CourseName LIKE '%{safe}%' OR CourseName LIKE '%{safe}%' OR CourseCode LIKE '%{safe}%'");
                dt = rows.Length > 0 ? rows.CopyToDataTable() : dt.Clone();
            }

            // Stats (always from full unfiltered set)
            lblTotal.Text = dtAll.Rows.Count.ToString();
            lblActive.Text = dtAll.Select("IsActive = true").Length.ToString();
            lblInactive.Text = dtAll.Select("IsActive = false").Length.ToString();

            // Group by stream
            DataTable streamTable = new DataTable();
            streamTable.Columns.Add("StreamId");
            streamTable.Columns.Add("StreamName");
            streamTable.Columns.Add("CourseCount");
            streamTable.Columns.Add("Courses", typeof(DataTable));

            DataTable distinct = new DataView(dt).ToTable(true, "StreamId", "StreamName");

            foreach (DataRow row in distinct.Rows)
            {
                DataRow[] matches = dt.Select("StreamId=" + row["StreamId"]);
                if (matches.Length == 0) continue;

                DataRow nr = streamTable.NewRow();
                nr["StreamId"] = row["StreamId"];
                nr["StreamName"] = row["StreamName"];
                nr["CourseCount"] = matches.Length;
                nr["Courses"] = matches.CopyToDataTable();
                streamTable.Rows.Add(nr);
            }

            rptStreams.DataSource = streamTable;
            rptStreams.DataBind();

            pnlEmpty.Visible = streamTable.Rows.Count == 0;

            // Pass cards-per-page to JS via hidden field
            hfCardsPerPage.Value = CardsPerPage.ToString();

            // Re-register the current search so JS can filter on page load
            if (!string.IsNullOrEmpty(search))
                ScriptManager.RegisterStartupScript(this, GetType(), "initSearch",
                    $"document.getElementById('txtSearchClient').value='{search.Replace("'", "\\'")}';", true);
        }

        protected void rptStreams_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item &&
                e.Item.ItemType != ListItemType.AlternatingItem) return;

            DataRowView drv = (DataRowView)e.Item.DataItem;
            GridView gv = (GridView)e.Item.FindControl("gvInnerCourses");
            if (gv == null) return;

            if (drv["Courses"] != DBNull.Value)
            {
                gv.DataSource = (DataTable)drv["Courses"];
                gv.DataBind();
            }
        }

        protected void FilterStatus_Click(object sender, EventArgs e)
        {
            string status = ((LinkButton)sender).CommandArgument;
            ViewState["FilterStatus"] = status;
            LoadCourses(status);
        }
    }
}