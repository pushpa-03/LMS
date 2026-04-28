//using System;
//using System.Data;
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

//        //private void LoadFilters()
//        //{
//        //    DataTable dt = bl.GetFilterData(InstituteId);

//        //    ddlStream.DataSource = dt.Select("Type='Stream'").CopyToDataTable();
//        //    ddlStream.DataTextField = "Name";
//        //    ddlStream.DataValueField = "Id";
//        //    ddlStream.DataBind();
//        //    ddlStream.Items.Insert(0, new ListItem("All Streams", ""));

//        //    ddlCourse.DataSource = dt.Select("Type='Course'").CopyToDataTable();
//        //    ddlCourse.DataTextField = "Name";
//        //    ddlCourse.DataValueField = "Id";
//        //    ddlCourse.DataBind();
//        //    ddlCourse.Items.Insert(0, new ListItem("All Courses", ""));

//        //    ddlLevel.DataSource = dt.Select("Type='Level'").CopyToDataTable();
//        //    ddlLevel.DataTextField = "Name";
//        //    ddlLevel.DataValueField = "Id";
//        //    ddlLevel.DataBind();
//        //    ddlLevel.Items.Insert(0, new ListItem("All Levels", ""));

//        //    ddlSemester.DataSource = dt.Select("Type='Semester'").CopyToDataTable();
//        //    ddlSemester.DataTextField = "Name";
//        //    ddlSemester.DataValueField = "Id";
//        //    ddlSemester.DataBind();
//        //    ddlSemester.Items.Insert(0, new ListItem("All Semesters", ""));
//        //}
//    }
//}


//------------------------------------------------------------------------------------------------------------------------------------

using System;
using System.Data;
using System.Net.Security;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace LearningManagementSystem.Admin
{
    public partial class Subjects : BasePage
    {
        SubjectsBL bl = new SubjectsBL();


        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (SessionId == 0)
                {
                    lblMsg.Text = "No active academic session found!";
                    lblMsg.Visible = true;
                    return;
                }

                LoadFilters();
                LoadDashboard();
            }
        }

        private void LoadDashboard()
        {
            if (SessionId == 0) return; // 🛡 safety

            int statusFilter = chkStatus.Checked ? 0 : 1;

            //int? streamId = string.IsNullOrEmpty(ddlStream.SelectedValue) ? (int?)null : Convert.ToInt32(ddlStream.SelectedValue);
            //int? courseId = string.IsNullOrEmpty(ddlCourse.SelectedValue) ? (int?)null : Convert.ToInt32(ddlCourse.SelectedValue);
            //int? levelId = string.IsNullOrEmpty(ddlLevel.SelectedValue) ? (int?)null : Convert.ToInt32(ddlLevel.SelectedValue);
            //int? semId = string.IsNullOrEmpty(ddlSemester.SelectedValue) ? (int?)null : Convert.ToInt32(ddlSemester.SelectedValue);

            int? streamId = int.TryParse(ddlStream.SelectedValue, out int s) ? s : (int?)null;
            int? courseId = int.TryParse(ddlCourse.SelectedValue, out int c) ? c : (int?)null;
            int? levelId = int.TryParse(ddlLevel.SelectedValue, out int l) ? l : (int?)null;
            int? semId = int.TryParse(ddlSemester.SelectedValue, out int sm) ? sm : (int?)null;

            // ✅ Use BasePage SessionId
            DataTable dtStats = bl.GetAdminStats(InstituteId, SessionId);
            rptStats.DataSource = dtStats;
            rptStats.DataBind();

            DataTable dt = bl.GetFilteredSubjects(
                SocietyId, InstituteId, SessionId, statusFilter,
                streamId, courseId, levelId, semId
            );

            rptSubjects.DataSource = dt;
            rptSubjects.DataBind();

            phEmpty.Visible = dt.Rows.Count == 0;

            // ✅ SAFE CALCULATIONS
            int active = dt.Select("IsActive = 1").Length;
            int inactive = dt.Select("IsActive = 0").Length;
            int totalEnroll = 0;

            foreach (DataRow r in dt.Rows)
            {
                if (r["StudentCount"] != DBNull.Value)
                    totalEnroll += Convert.ToInt32(r["StudentCount"]);
            }

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

            BindDropdown(ddlStream, dt, "Stream", "All Streams");
            BindDropdown(ddlCourse, dt, "Course", "All Courses");
            BindDropdown(ddlLevel, dt, "Level", "All Levels");
            BindDropdown(ddlSemester, dt, "Semester", "All Semesters");
        }

        private void BindDropdown(DropDownList ddl, DataTable dt, string type, string defaultText)
        {
            DataRow[] rows = dt.Select($"Type='{type}'");

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

       
    }
}