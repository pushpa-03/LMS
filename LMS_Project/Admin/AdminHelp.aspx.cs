using System;
using System.Collections.Generic;
using System.Web.UI;
using System.Web.UI.WebControls;
using LearningManagementSystem.BL;
using LearningManagementSystem.GC;

namespace LearningManagementSystem.Admin
{
    public partial class AdminHelp : Page
    {
        private HelpBL _bl = new HelpBL();

        // ─── Session helpers ────────────────────────────────────────────────────
        private int SocietyId => Convert.ToInt32(Session["SocietyId"]);
        private int InstituteId => Convert.ToInt32(Session["InstituteId"]);
        private int AdminUserId => Convert.ToInt32(Session["UserId"]);

        // ─── Page Load ──────────────────────────────────────────────────────────
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadMessageList();
                HideThread();
            }
        }

        // ─── OnLoad: reads ?hid= from query string ───────────────────────────────
        protected override void OnLoad(EventArgs e)
        {
            base.OnLoad(e);

            int helpId;
            if (int.TryParse(Request.QueryString["hid"], out helpId) && helpId > 0)
            {
                hfHelpId.Value = helpId.ToString();
                LoadMessageList();
                LoadThread(helpId);
            }
        }

        // ─── Load left-panel message list ───────────────────────────────────────
        private void LoadMessageList()
        {
            var list = _bl.GetAllHelpRequests(SocietyId, InstituteId);
            rptMessages.DataSource = list;
            rptMessages.DataBind();

            int unreplied = _bl.GetUnrepliedCount(SocietyId, InstituteId);
            lblUnrepliedBadge.Text = unreplied > 0 ? unreplied.ToString() : "";
            lblUnrepliedBadge.Visible = unreplied > 0;
        }

        // ─── Hide chat thread (initial state / after delete) ────────────────────
        private void HideThread()
        {
            chatEmpty.Visible = true;
            chatThread.Visible = false;
            hfHelpId.Value = "";
            lblChatUser.Text = "";
            lblChatMeta.Text = "";
            txtReply.Text = "";
            rptThread.DataSource = null;
            rptThread.DataBind();
        }

        // ─── Load a selected conversation into the right panel ──────────────────
        private void LoadThread(int helpId)
        {
            var request = _bl.GetHelpRequestById(helpId, SocietyId, InstituteId);
            if (request == null) { HideThread(); return; }

            var replies = _bl.GetRepliesByHelpId(helpId, SocietyId, InstituteId);
            var timeline = new List<ThreadItem>();

            // Original question bubble (from user)
            timeline.Add(new ThreadItem
            {
                IsAdminReply = false,
                SenderLabel = request.Username + " (" + request.RoleName + ")",
                Text = request.Question,
                Time = request.AskedOn
            });

            // Admin reply bubbles
            foreach (var rep in replies)
            {
                timeline.Add(new ThreadItem
                {
                    IsAdminReply = true,
                    SenderLabel = "You (Admin)",
                    Text = rep.Reply,
                    Time = rep.RepliedOn
                });
            }

            rptThread.DataSource = timeline;
            rptThread.DataBind();

            lblChatUser.Text = request.Username + " — " + request.RoleName;
            lblChatMeta.Text = "Asked on " + request.AskedOn.ToString("dd MMM yyyy, hh:mm tt");
            hfHelpId.Value = helpId.ToString();

            chatEmpty.Visible = false;
            chatThread.Visible = true;
        }

        // ─── Send Reply ─────────────────────────────────────────────────────────
        protected void btnSendReply_Click(object sender, EventArgs e)
        {
            int helpId;
            if (!int.TryParse(hfHelpId.Value, out helpId) || helpId <= 0)
            {
                ShowAlert("Please select a message first.", false);
                return;
            }

            string reply = txtReply.Text.Trim();
            if (string.IsNullOrEmpty(reply))
            {
                ShowAlert("Reply cannot be empty.", false);
                return;
            }

            bool ok = _bl.PostReply(new HelpReplyGC
            {
                SocietyId = SocietyId,
                InstituteId = InstituteId,
                HelpId = helpId,
                AdminId = AdminUserId,
                Reply = reply
            });

            if (ok)
            {
                txtReply.Text = "";
                ShowAlert("Reply sent successfully.", true);
            }
            else
            {
                ShowAlert("Failed to send reply. Please try again.", false);
            }

            LoadMessageList();
            LoadThread(helpId);
        }

        // ─── Delete conversation ─────────────────────────────────────────────────
        protected void btnDelete_Click(object sender, EventArgs e)
        {
            int helpId;
            if (!int.TryParse(hfHelpId.Value, out helpId) || helpId <= 0) return;

            bool ok = _bl.DeleteHelpRequest(helpId, SocietyId, InstituteId);
            if (ok)
            {
                ShowAlert("Conversation deleted.", true);
                LoadMessageList();
                HideThread();
            }
            else
            {
                ShowAlert("Could not delete. Please try again.", false);
                LoadThread(helpId);
            }
        }

        // ─── Repeater item command (reserved for future use) ────────────────────
        protected void rptMessages_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            // reserved
        }

        // ─── Build chat bubble HTML (called from rptThread in ASPX) ─────────────
        // ✅ FIXED: now INSIDE the AdminHelp class
        protected string BuildBubble(bool isAdmin, string senderLabel, string text, DateTime time)
        {
            string side = isAdmin ? "admin" : "user";
            string label = isAdmin ? "You (Admin)" : Server.HtmlEncode(senderLabel);
            string timeStr = time.ToString("dd MMM yyyy, hh:mm tt");
            string encodedText = Server.HtmlEncode(text);

            return $@"
                <div class='bubble-wrap {side}'>
                    <div class='bubble-label'>{label}</div>
                    <div class='bubble'>{encodedText}</div>
                    <div class='bubble-time'>{timeStr}</div>
                </div>";
        }

        // ─── Helper: show alert banner ──────────────────────────────────────────
        private void ShowAlert(string msg, bool success)
        {
            lblAlert.Text = msg;
            lblAlert.CssClass = "help-alert " + (success ? "success" : "error");
            lblAlert.Visible = true;
        }

    }   // ← END of AdminHelp class

    // ─── DTO for the chat timeline repeater (separate class, same namespace) ────
    public class ThreadItem
    {
        public bool IsAdminReply { get; set; }
        public string SenderLabel { get; set; }
        public string Text { get; set; }
        public DateTime Time { get; set; }
    }

}