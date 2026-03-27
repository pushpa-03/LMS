using System;
using System.Collections.Generic;
using System.Web.UI;
using LearningManagementSystem.BL;
using LearningManagementSystem.GC;

namespace LearningManagementSystem.Student
{
    public partial class UserHelp : Page
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

        // Called from repeater in ASPX
        protected string BuildReplyHtml(bool hasReply, string replyText, DateTime? repliedOn)
        {
            if (!hasReply)
                return "<div class='thread-time mt-2' style='color:#e65100;'><i class='fas fa-hourglass-half me-1'></i>Waiting for admin reply…</div>";

            string time = repliedOn.HasValue
                ? repliedOn.Value.ToString("dd MMM yyyy, hh:mm tt")
                : "";

            return $@"
                <div class='thread-reply'>
                    <div class='reply-label'><i class='fas fa-reply me-1'></i>Admin replied · {time}</div>
                    {Server.HtmlEncode(replyText)}
                </div>";
        }

        private void ShowAlert(string msg, bool success)
        {
            lblAlert.Text = msg;
            lblAlert.CssClass = "help-alert " + (success ? "success" : "error");
            lblAlert.Visible = true;
        }
    }
}