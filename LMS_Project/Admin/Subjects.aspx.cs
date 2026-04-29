//using System;
//using System.Data;
//using System.Net.Security;
//using System.Web.UI;
//using System.Web.UI.WebControls;

//namespace LearningManagementSystem.Admin
//{
//    public partial class Subjects : BasePage
//    {
//        SubjectsBL bl = new SubjectsBL();


//        protected void Page_Load(object sender, EventArgs e)
//        {
//            if (!IsPostBack)
//            {
//                if (SessionId == 0)
//                {
//                    lblMsg.Text = "No active academic session found!";
//                    lblMsg.Visible = true;
//                    return;
//                }

//                LoadFilters();
//                LoadDashboard();
//            }
//        }

//        private void LoadDashboard()
//        {
//            if (SessionId == 0) return; // 🛡 safety

//            int statusFilter = chkStatus.Checked ? 0 : 1;

//            //int? streamId = string.IsNullOrEmpty(ddlStream.SelectedValue) ? (int?)null : Convert.ToInt32(ddlStream.SelectedValue);
//            //int? courseId = string.IsNullOrEmpty(ddlCourse.SelectedValue) ? (int?)null : Convert.ToInt32(ddlCourse.SelectedValue);
//            //int? levelId = string.IsNullOrEmpty(ddlLevel.SelectedValue) ? (int?)null : Convert.ToInt32(ddlLevel.SelectedValue);
//            //int? semId = string.IsNullOrEmpty(ddlSemester.SelectedValue) ? (int?)null : Convert.ToInt32(ddlSemester.SelectedValue);

//            int? streamId = int.TryParse(ddlStream.SelectedValue, out int s) ? s : (int?)null;
//            int? courseId = int.TryParse(ddlCourse.SelectedValue, out int c) ? c : (int?)null;
//            int? levelId = int.TryParse(ddlLevel.SelectedValue, out int l) ? l : (int?)null;
//            int? semId = int.TryParse(ddlSemester.SelectedValue, out int sm) ? sm : (int?)null;

//            // ✅ Use BasePage SessionId
//            DataTable dtStats = bl.GetAdminStats(InstituteId, SessionId);
//            rptStats.DataSource = dtStats;
//            rptStats.DataBind();

//            DataTable dt = bl.GetFilteredSubjects(
//                SocietyId, InstituteId, SessionId, statusFilter,
//                streamId, courseId, levelId, semId
//            );

//            rptSubjects.DataSource = dt;
//            rptSubjects.DataBind();

//            phEmpty.Visible = dt.Rows.Count == 0;

//            // ✅ SAFE CALCULATIONS
//            int active = dt.Select("IsActive = 1").Length;
//            int inactive = dt.Select("IsActive = 0").Length;
//            int totalEnroll = 0;

//            foreach (DataRow r in dt.Rows)
//            {
//                if (r["StudentCount"] != DBNull.Value)
//                    totalEnroll += Convert.ToInt32(r["StudentCount"]);
//            }

//            string script = $"loadCharts({active},{inactive},{totalEnroll});";
//            ScriptManager.RegisterStartupScript(this, GetType(), "chart", script, true);
//        }

//        protected void FilterChanged(object sender, EventArgs e)
//        {
//            LoadDashboard();
//        }

//        protected void chkStatus_CheckedChanged(object sender, EventArgs e)
//        {
//            LoadDashboard();
//        }

//        protected void rptSubjects_ItemCommand(object source, RepeaterCommandEventArgs e)
//        {
//            if (e.CommandName == "Toggle")
//            {
//                int subjectId = Convert.ToInt32(e.CommandArgument);
//                bl.ToggleSubjectStatus(subjectId);
//                LoadDashboard(); // Refresh UI
//            }
//        }

//        private void LoadFilters()
//        {
//            DataTable dt = bl.GetFilterData(InstituteId);

//            BindDropdown(ddlStream, dt, "Stream", "All Streams");
//            BindDropdown(ddlCourse, dt, "Course", "All Courses");
//            BindDropdown(ddlLevel, dt, "Level", "All Levels");
//            BindDropdown(ddlSemester, dt, "Semester", "All Semesters");
//        }

//        private void BindDropdown(DropDownList ddl, DataTable dt, string type, string defaultText)
//        {
//            DataRow[] rows = dt.Select($"Type='{type}'");

//            if (rows.Length > 0)
//            {
//                DataTable temp = rows.CopyToDataTable();
//                ddl.DataSource = temp;
//                ddl.DataTextField = "Name";
//                ddl.DataValueField = "Id";
//                ddl.DataBind();
//            }

//            ddl.Items.Insert(0, new ListItem(defaultText, ""));
//        }


//    }
//}

//--------------------------------------------------------------------------------------------------------------------------

using System;
using System.Data;
using System.Web.UI.WebControls;

namespace LearningManagementSystem.Admin
{
    public partial class Subjects : BasePage
    {
        private readonly SubjectsBL _bl = new SubjectsBL();

        protected void Page_Load(object sender, EventArgs e)
        {
            try
            {
                if (!IsPostBack)
                {
                    if (SessionId == 0)
                    {
                        ShowAlert("No active academic session found. Please set a current session first.", "warning");
                        return;
                    }
                    LoadFilters();
                    LoadDashboard();
                }
            }
            catch (Exception ex)
            {
                ShowAlert("Error loading page: " + ex.Message, "danger");
            }
        }

        private void LoadDashboard()
        {
            try
            {
                if (SessionId == 0) return;

                int statusFilter = chkStatus.Checked ? 0 : 1;
                litToggleLabel.Text = chkStatus.Checked ? "Showing Inactive" : "Showing Active";

                int? streamId = TryParseNullable(ddlStream.SelectedValue);
                int? courseId = TryParseNullable(ddlCourse.SelectedValue);
                int? levelId = TryParseNullable(ddlLevel.SelectedValue);
                int? semId = TryParseNullable(ddlSemester.SelectedValue);

                // Load stats
                DataTable dtStats = _bl.GetAdminStats(InstituteId, SessionId);
                rptStats.DataSource = dtStats;
                rptStats.DataBind();

                // Load subjects
                DataTable dt = _bl.GetFilteredSubjects(
                    SocietyId, InstituteId, SessionId,
                    statusFilter, streamId, courseId, levelId, semId
                );

                rptSubjects.DataSource = dt;
                rptSubjects.DataBind();

                phEmpty.Visible = (dt == null || dt.Rows.Count == 0);
            }
            catch (Exception ex)
            {
                ShowAlert("Error loading subjects: " + ex.Message, "danger");
            }
        }

        protected void FilterChanged(object sender, EventArgs e)
        {
            try { LoadDashboard(); }
            catch (Exception ex) { ShowAlert("Filter error: " + ex.Message, "danger"); }
        }

        protected void chkStatus_CheckedChanged(object sender, EventArgs e)
        {
            try { LoadDashboard(); }
            catch (Exception ex) { ShowAlert("Toggle error: " + ex.Message, "danger"); }
        }

        protected void rptSubjects_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            try
            {
                if (e.CommandName == "Toggle")
                {
                    int subjectId = Convert.ToInt32(e.CommandArgument);
                    string result = _bl.ToggleSubjectStatus(subjectId);
                    hfToastMsg.Value = result;
                    LoadDashboard();
                }
            }
            catch (Exception ex)
            {
                ShowAlert("Error toggling status: " + ex.Message, "danger");
            }
        }

        private void LoadFilters()
        {
            try
            {
                DataTable dt = _bl.GetFilterData(InstituteId, SessionId);
                BindDropdown(ddlStream, dt, "Stream", "All Streams");
                BindDropdown(ddlCourse, dt, "Course", "All Courses");
                BindDropdown(ddlLevel, dt, "Level", "All Levels");
                BindDropdown(ddlSemester, dt, "Semester", "All Semesters");
            }
            catch (Exception ex)
            {
                ShowAlert("Error loading filters: " + ex.Message, "danger");
            }
        }

        private void BindDropdown(DropDownList ddl, DataTable dt, string type, string defaultText)
        {
            DataRow[] rows = dt.Select($"Type='{type}'");
            ddl.Items.Clear();
            if (rows.Length > 0)
            {
                DataTable temp = rows.CopyToDataTable();
                ddl.DataSource = temp;
                ddl.DataTextField = "Name";
                ddl.DataValueField = "Id";
                ddl.DataBind();
            }
            ddl.Items.Insert(0, new ListItem(defaultText, ""));
        }

        private void ShowAlert(string message, string type)
        {
            lblMsg.Text = message;
            lblMsg.CssClass = $"alert alert-{type} alert-auto d-block mb-3";
            lblMsg.Visible = true;
        }

        private static int? TryParseNullable(string val)
        {
            return int.TryParse(val, out int result) ? result : (int?)null;
        }
    }
}