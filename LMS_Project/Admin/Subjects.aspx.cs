using System;
using System.Data;
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
                LoadDashboard();
            }
        }

        private void LoadDashboard()
        {
            int sessionId = bl.GetCurrentSession(InstituteId);
            if (sessionId == 0)
            {
                lblMsg.Text = "No Active Academic Session Found. Please create a session first.";
                lblMsg.Visible = true;
                return;
            }

            // Bind Statistics
            DataTable dtStats = bl.GetAdminStats(InstituteId, sessionId);
            rptStats.DataSource = dtStats;
            rptStats.DataBind();

            // Bind Subjects based on switch
            int statusFilter = chkStatus.Checked ? 0 : 1; // 1 = Active, 0 = Inactive
            DataTable dt = bl.GetHierarchicalSubjects(SocietyId, InstituteId, sessionId, statusFilter);

            rptSubjects.DataSource = dt;
            rptSubjects.DataBind();

            phEmpty.Visible = (dt.Rows.Count == 0);
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
    }
}