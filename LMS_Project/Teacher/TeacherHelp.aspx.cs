using System;
using System.Web.UI;
using LearningManagementSystem.BL;
using LearningManagementSystem.GC;

namespace LMS_Project.Teacher
{
    public partial class TeacherHelp : Page
    {
        private HelpBL _bl = new HelpBL();

        private int SocietyId => Convert.ToInt32(Session["SocietyId"]);
        private int InstituteId => Convert.ToInt32(Session["InstituteId"]);
        private int UserId => Convert.ToInt32(Session["UserId"]);

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
                LoadThreads();
        }

        private void LoadThreads()
        {
            var list = _bl.GetRequestsByUser(UserId, SocietyId, InstituteId);
            if (list.Count == 0)
            {
                pnlEmpty.Visible = true;
                rptThreads.DataSource = null;
            }
            else
            {
                pnlEmpty.Visible = false;
                rptThreads.DataSource = list;
            }
            rptThreads.DataBind();
        }

        protected void btnSubmit_Click(object sender, EventArgs e)
        {

            string q = txtQuestion.Text.Trim();
            if (string.IsNullOrEmpty(q))
            {
                ShowAlert("Please type your question.", false);
                return;
            }

            bool ok = _bl.SubmitQuestion(new HelpRequestGC
            {
                SocietyId = SocietyId,
                InstituteId = InstituteId,
                UserId = UserId,
                Question = q
            });

            if (ok)
            {
                txtQuestion.Text = "";
                ShowAlert("Your question has been sent to the admin.", true);
            }
            else
            {
                ShowAlert("Failed to submit. Please try again.", false);
            }

            LoadThreads();
        }

        private void ShowAlert(string msg, bool success)
        {
            lblAlert.Text = msg;
            lblAlert.CssClass = "help-alert " + (success ? "success" : "error");
            lblAlert.Visible = true;
        }
    }
}