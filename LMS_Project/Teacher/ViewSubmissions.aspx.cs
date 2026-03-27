using LearningManagementSystem.BL;
using System;
using System.Data;
using System.Web.UI.WebControls;

namespace LearningManagementSystem.Teacher
{
    public partial class ViewSubmissions : System.Web.UI.Page
    {
        AssignmentBL bl = new AssignmentBL();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Request.QueryString["AssignmentId"] != null)
                {
                    int assignmentId = Convert.ToInt32(Request.QueryString["AssignmentId"]);
                    LoadSubmissions(assignmentId);
                }
            }
        }

        private void LoadSubmissions(int assignmentId)
        {
            int societyId = Convert.ToInt32(Session["SocietyId"]);
            int instituteId = Convert.ToInt32(Session["InstituteId"]);

            DataTable dt = bl.GetSubmissionsByAssignment(
                assignmentId, societyId, instituteId);

            if (dt.Rows.Count > 0)
            {
                gvSubmissions.DataSource = dt;
                gvSubmissions.DataBind();
                lblSubmissionCount.Text = dt.Rows.Count.ToString();
                gvSubmissions.Visible = true;
                pnlEmpty.Visible = false;
            }
            else
            {
                gvSubmissions.Visible = false;
                pnlEmpty.Visible = true;
                lblSubmissionCount.Text = "0";
            }
        }
        protected void gvSubmissions_RowEditing(object sender, GridViewEditEventArgs e)
        {
            gvSubmissions.EditIndex = e.NewEditIndex;

            int assignmentId = Convert.ToInt32(Request.QueryString["AssignmentId"]);
            LoadSubmissions(assignmentId);
        }
        protected void gvSubmissions_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
        {
            gvSubmissions.EditIndex = -1;

            int assignmentId = Convert.ToInt32(Request.QueryString["AssignmentId"]);
            LoadSubmissions(assignmentId);
        }
        protected void gvSubmissions_RowUpdating(object sender, GridViewUpdateEventArgs e)
        {
            int submissionId = Convert.ToInt32(
                gvSubmissions.DataKeys[e.RowIndex].Value);

            GridViewRow row = gvSubmissions.Rows[e.RowIndex];

            TextBox txtMarks =
                (TextBox)row.FindControl("txtMarks");

            TextBox txtFeedback =
                (TextBox)row.FindControl("txtFeedback");

            int marks = 0;
            if (!string.IsNullOrEmpty(txtMarks.Text))
                marks = Convert.ToInt32(txtMarks.Text);

            string feedback = txtFeedback.Text;

            // CALL BL METHOD
            bl.UpdateSubmissionMarks(submissionId, marks, feedback);

            gvSubmissions.EditIndex = -1;

            int assignmentId = Convert.ToInt32(Request.QueryString["AssignmentId"]);
            LoadSubmissions(assignmentId);
        }
    }
}