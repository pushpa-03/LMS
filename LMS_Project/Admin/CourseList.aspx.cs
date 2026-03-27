using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using LearningManagementSystem.BL;

namespace LearningManagementSystem.Admin
{
    public partial class CourseList : Page
    {
        CourseBL bl = new CourseBL();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["InstituteId"] == null)
            {
                Response.Redirect("~/Default.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadCourses();
            }
            else
            {
                LoadCourses();
            }
        }

        private void LoadCourses(string status = "All")
        {
            int instituteId = Convert.ToInt32(Session["InstituteId"]);

            // 🔥 1. GET FULL DATA FOR STATS
            DataTable dtAll = bl.GetCourses(instituteId, "All");

            // 🔥 2. APPLY FILTER FOR DISPLAY
            DataTable dt = status == "All" ? dtAll : bl.GetCourses(instituteId, status);

            // 🔍 SEARCH (apply only on display data)
            if (!string.IsNullOrEmpty(txtSearch.Value))
            {
                string search = txtSearch.Value.Replace("'", "''");

                var rows = dt.Select($"CourseName LIKE '%{search}%' OR CourseCode LIKE '%{search}%'");
                dt = rows.Length > 0 ? rows.CopyToDataTable() : dt.Clone();
            }

            // ================= ✅ CORRECT STATS =================
            lblTotal.Text = dtAll.Rows.Count.ToString();
            lblActive.Text = dtAll.Select("IsActive = true").Length.ToString();
            lblInactive.Text = dtAll.Select("IsActive = false").Length.ToString();

            // ================= GROUP (USE FILTERED DATA) =================
            DataTable streamTable = new DataTable();
            streamTable.Columns.Add("StreamId");
            streamTable.Columns.Add("StreamName");
            streamTable.Columns.Add("CourseCount");
            streamTable.Columns.Add("Courses", typeof(DataTable));

            DataView view = new DataView(dt);
            DataTable distinct = view.ToTable(true, "StreamId", "StreamName");

            foreach (DataRow row in distinct.Rows)
            {
                DataRow newRow = streamTable.NewRow();

                newRow["StreamId"] = row["StreamId"];
                newRow["StreamName"] = row["StreamName"];

                DataRow[] rows = dt.Select("StreamId=" + row["StreamId"]);
                newRow["CourseCount"] = rows.Length;

                if (rows.Length > 0)
                    newRow["Courses"] = rows.CopyToDataTable();

                streamTable.Rows.Add(newRow);
            }

            rptStreams.DataSource = streamTable;
            rptStreams.DataBind();
        }

        protected void rptStreams_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item ||
                e.Item.ItemType == ListItemType.AlternatingItem)
            {
                DataRowView drv = (DataRowView)e.Item.DataItem;

                GridView gv = (GridView)e.Item.FindControl("gvInnerCourses");

                if (drv["Courses"] != DBNull.Value)
                {
                    gv.DataSource = (DataTable)drv["Courses"];
                    gv.DataBind();
                }
            }
        }

        protected void FilterStatus_Click(object sender, EventArgs e)
        {
            LinkButton btn = (LinkButton)sender;
            LoadCourses(btn.CommandArgument);

        }
    }
}