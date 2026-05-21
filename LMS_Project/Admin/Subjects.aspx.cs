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