using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace LearningManagementSystem.Admin
{
    public partial class TeacherList : Page
    {
        TeacherBL bl = new TeacherBL();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null)
            {
                Response.Redirect("~/Default.aspx");
                return;
            }
            if (!IsPostBack)
            {
                LoadStreams();
                BindTeacherData();
            }
        }

        private void LoadStreams()
        {
            int instId = Convert.ToInt32(Session["InstituteId"]);
            ddlStream.DataSource = bl.GetStreams(instId);
            ddlStream.DataTextField = "StreamName";
            ddlStream.DataValueField = "StreamId";
            ddlStream.DataBind();
            ddlStream.Items.Insert(0, new ListItem("All Departments", "0"));
        }

        private void BindTeacherData()
        {
            int instId = Convert.ToInt32(Session["InstituteId"]);
            string search = txtSearch.Text.Trim();
            int streamId = Convert.ToInt32(ddlStream.SelectedValue);
            string status = ddlStatus.SelectedValue;

            DataTable dt = bl.GetFilteredTeachers(instId, search, streamId, status);
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