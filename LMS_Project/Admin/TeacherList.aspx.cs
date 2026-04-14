using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace LearningManagementSystem.Admin
{
    public partial class TeacherList : BasePage
    {
        TeacherBL bl = new TeacherBL();

        protected void Page_Load(object sender, EventArgs e)
        {
            
            if (!IsPostBack)
            {
                if (SessionId == 0) return;

                LoadStreams();
                BindTeacherData();
            }
        }

        private void LoadStreams()
        {
            int instId = InstituteId;
            ddlStream.DataSource = bl.GetStreams(instId,SessionId);
            ddlStream.DataTextField = "StreamName";
            ddlStream.DataValueField = "StreamId";
            ddlStream.DataBind();
            ddlStream.Items.Insert(0, new ListItem("All Departments", "0"));
        }

        private void BindTeacherData()
        {
            int instId = InstituteId;
            string search = txtSearch.Text.Trim();
            int streamId = Convert.ToInt32(ddlStream.SelectedValue);
            string status = ddlStatus.SelectedValue;

            DataTable dt = bl.GetFilteredTeachers(instId,SessionId,search, streamId, status);
            gvTeachers.DataSource = dt;
            gvTeachers.DataBind();

            // Update Stats
            litTotal.Text = dt.Rows.Count.ToString();
        }

        protected void Filter_Changed(object sender, EventArgs e)
        {
            BindTeacherData();
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            txtSearch.Text = "";
            ddlStream.SelectedIndex = 0;
            ddlStatus.SelectedIndex = 0;
            BindTeacherData();
        }

        protected void gvTeachers_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            string userId = e.CommandArgument.ToString();
            if (e.CommandName == "ViewDetails")
            {
                Response.Redirect($"TeacherDetails.aspx?id={userId}");
            }
            else if (e.CommandName == "EditRow")
            {
                Response.Redirect($"AddTeacher.aspx?id={userId}");
            }
        }
    }
}