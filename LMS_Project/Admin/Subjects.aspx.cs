using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace LearningManagementSystem.Admin
{
    public partial class Subjects : System.Web.UI.Page
    {
        SubjectsBL bl = new SubjectsBL();

        int SocietyId => Convert.ToInt32(Session["SocietyId"]);
        int InstituteId => Convert.ToInt32(Session["InstituteId"]);

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["InstituteId"] == null) Response.Redirect("~/Default.aspx");

            if (!IsPostBack)
            {
                LoadFilters();
                LoadDashboard();
            }
        }

        //private void LoadDashboard()
        //{
        //    int sessionId = bl.GetCurrentSession(InstituteId);
        //    if (sessionId == 0)
        //    {
        //        lblMsg.Text = "No Active Academic Session Found. Please create a session first.";
        //        lblMsg.Visible = true;
        //        return;
        //    }

        //    // Bind Statistics
        //    DataTable dtStats = bl.GetAdminStats(InstituteId, sessionId);
        //    rptStats.DataSource = dtStats;
        //    rptStats.DataBind();

        //    // Bind Subjects based on switch
        //    int statusFilter = chkStatus.Checked ? 0 : 1; // 1 = Active, 0 = Inactive
        //    DataTable dt = bl.GetHierarchicalSubjects(SocietyId, InstituteId, sessionId, statusFilter);

        //    rptSubjects.DataSource = dt;
        //    rptSubjects.DataBind();

        //    phEmpty.Visible = (dt.Rows.Count == 0);
        //}

        private void LoadDashboard()
        {
            int sessionId = bl.GetCurrentSession(InstituteId);

            int statusFilter = chkStatus.Checked ? 0 : 1;

            int? streamId = string.IsNullOrEmpty(ddlStream.SelectedValue) ? (int?)null : Convert.ToInt32(ddlStream.SelectedValue);
            int? courseId = string.IsNullOrEmpty(ddlCourse.SelectedValue) ? (int?)null : Convert.ToInt32(ddlCourse.SelectedValue);
            int? levelId = string.IsNullOrEmpty(ddlLevel.SelectedValue) ? (int?)null : Convert.ToInt32(ddlLevel.SelectedValue);
            int? semId = string.IsNullOrEmpty(ddlSemester.SelectedValue) ? (int?)null : Convert.ToInt32(ddlSemester.SelectedValue);

            DataTable dtStats = bl.GetAdminStats(InstituteId, sessionId);
            rptStats.DataSource = dtStats;
            rptStats.DataBind();

            DataTable dt = bl.GetFilteredSubjects(
                SocietyId, InstituteId, sessionId, statusFilter,
                streamId, courseId, levelId, semId
            );

            rptSubjects.DataSource = dt;
            rptSubjects.DataBind();

            phEmpty.Visible = dt.Rows.Count == 0;

            // 🔥 Chart script injection
            int active = dt.Select("IsActive = 1").Length;
            int inactive = dt.Select("IsActive = 0").Length;
            int totalEnroll = 0;

            foreach (DataRow r in dt.Rows)
                totalEnroll += Convert.ToInt32(r["StudentCount"]);

            string script = $"loadCharts({active},{inactive},{totalEnroll});";
            ScriptManager.RegisterStartupScript(this, GetType(), "chart", script, true);
        }

        protected void FilterChanged(object sender, EventArgs e)
        {
            LoadDashboard();
        }

        protected void chkStatus_CheckedChanged(object sender, EventArgs e)
        {
            LoadDashboard();
        }

        protected void rptSubjects_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "Toggle")
            {
                int subjectId = Convert.ToInt32(e.CommandArgument);
                bl.ToggleSubjectStatus(subjectId);
                LoadDashboard(); // Refresh UI
            }
        }

        private void LoadFilters()
        {
            DataTable dt = bl.GetFilterData(InstituteId);

            ddlStream.DataSource = dt.Select("Type='Stream'").CopyToDataTable();
            ddlStream.DataTextField = "Name";
            ddlStream.DataValueField = "Id";
            ddlStream.DataBind();
            ddlStream.Items.Insert(0, new ListItem("All Streams", ""));

            ddlCourse.DataSource = dt.Select("Type='Course'").CopyToDataTable();
            ddlCourse.DataTextField = "Name";
            ddlCourse.DataValueField = "Id";
            ddlCourse.DataBind();
            ddlCourse.Items.Insert(0, new ListItem("All Courses", ""));

            ddlLevel.DataSource = dt.Select("Type='Level'").CopyToDataTable();
            ddlLevel.DataTextField = "Name";
            ddlLevel.DataValueField = "Id";
            ddlLevel.DataBind();
            ddlLevel.Items.Insert(0, new ListItem("All Levels", ""));

            ddlSemester.DataSource = dt.Select("Type='Semester'").CopyToDataTable();
            ddlSemester.DataTextField = "Name";
            ddlSemester.DataValueField = "Id";
            ddlSemester.DataBind();
            ddlSemester.Items.Insert(0, new ListItem("All Semesters", ""));
        }
    }
}