<%@ Page Title="Help & Support" Language="C#" MasterPageFile="~/Student/StudentMaster.master"
    AutoEventWireup="true" CodeBehind="UserHelp.aspx.cs"
    Inherits="LearningManagementSystem.Student.UserHelp" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<style>
.help-wrap { max-width:750px; margin:0 auto; }

.ask-card {
    background:#fff; border-radius:10px;
    border:1px solid #e0e0e0; padding:24px;
    margin-bottom:24px;
}
.ask-card h6 { font-weight:700; color:#1565c0; margin-bottom:16px; }

.ask-card textarea {
    width:100%; border:1px solid #ccc; border-radius:8px;
    padding:12px; font-size:14px; resize:vertical;
    min-height:100px; font-family:inherit; outline:none;
    transition:.2s; box-sizing:border-box;
}
.ask-card textarea:focus { border-color:#1976d2; }

.btn-ask {
    background:#1565c0; color:#fff; border:none;
    border-radius:8px; padding:10px 24px;
    font-size:14px; cursor:pointer; margin-top:10px;
    transition:.2s;
}
.btn-ask:hover { background:#0d47a1; }

/* Thread list */
.thread-card {
    background:#fff; border-radius:10px;
    border:1px solid #e0e0e0; margin-bottom:16px;
    overflow:hidden;
}
.thread-header {
    padding:12px 16px; background:#f9f9f9;
    border-bottom:1px solid #eee;
    display:flex; justify-content:space-between;
    align-items:center;
}
.thread-status-replied {
    background:#e3f2fd; color:#1565c0;
    border-radius:12px; padding:2px 10px;
    font-size:11px; font-weight:600;
}
.thread-status-pending {
    background:#fff3e0; color:#e65100;
    border-radius:12px; padding:2px 10px;
    font-size:11px; font-weight:600;
}
.thread-body { padding:14px 16px; }
.thread-question {
    font-size:14px; color:#333;
    margin-bottom:10px;
}
.thread-reply {
    background:#e3f2fd; border-left:3px solid #1565c0;
    padding:10px 14px; border-radius:6px;
    font-size:13px; color:#1565c0; margin-top:8px;
}
.thread-reply .reply-label {
    font-size:11px; color:#888; margin-bottom:4px;
}
.thread-time { font-size:11px; color:#aaa; }

.help-alert {
    padding:10px 16px; border-radius:6px;
    margin-bottom:14px; font-size:13px; display:none;
}
.help-alert.success { background:#e8f5e9; color:#2e7d32; border:1px solid #a5d6a7; display:block; }
.help-alert.error   { background:#ffebee; color:#c62828; border:1px solid #ef9a9a; display:block; }

.empty-state {
    text-align:center; padding:40px; color:#bbb;
}
.empty-state i { font-size:40px; margin-bottom:10px; display:block; }
</style>

<!-- PAGE BODY goes here — Student master has only ONE ContentPlaceHolder -->
<div class="help-wrap">

    <div class="d-flex align-items-center mb-3">
        <i class="fas fa-headset me-2 fs-5" style="color:#1565c0;"></i>
        <h5 class="mb-0 fw-bold" style="color:#1565c0;">Help &amp; Support</h5>
    </div>

    <!-- Alert -->
    <asp:Label ID="lblAlert" runat="server" CssClass="help-alert" Visible="false" />

    <!-- Ask a question -->
    <div class="ask-card">
        <h6><i class="fas fa-question-circle me-2"></i>Ask a Question</h6>
        <asp:TextBox ID="txtQuestion" runat="server" TextMode="MultiLine"
            placeholder="Type your question or issue here…" />
        <br />
        <asp:Button ID="btnSubmit" runat="server" Text="Send to Admin"
            CssClass="btn-ask" OnClick="btnSubmit_Click" />
    </div>

    <!-- Previous threads -->
    <h6 class="fw-bold mb-3">Your Previous Messages</h6>

    <asp:Panel ID="pnlEmpty" runat="server" Visible="false">
        <div class="empty-state">
            <i class="fas fa-comments"></i>
            <p>No messages yet. Ask your first question above!</p>
        </div>
    </asp:Panel>

    <asp:Repeater ID="rptThreads" runat="server">
        <ItemTemplate>
            <div class="thread-card">
                <div class="thread-header">
                    <span class="thread-time">
                        <i class="far fa-clock me-1"></i>
                        <%# ((DateTime)Eval("AskedOn")).ToString("dd MMM yyyy, hh:mm tt") %>
                    </span>
                    <%# (bool)Eval("HasReply")
                        ? "<span class='thread-status-replied'><i class='fas fa-check-circle me-1'></i>Replied</span>"
                        : "<span class='thread-status-pending'><i class='fas fa-clock me-1'></i>Pending</span>" %>
                </div>
                <div class="thread-body">
                    <div class="thread-question">
                        <strong>You:</strong> <%# Server.HtmlEncode(Eval("Question").ToString()) %>
                    </div>
                    <%# BuildReplyHtml(
                            (bool)Eval("HasReply"),
                            Eval("ReplyText") == null ? "" : Eval("ReplyText").ToString(),
                            Eval("RepliedOn") == null || Eval("RepliedOn") == DBNull.Value
                                ? (DateTime?)null
                                : (DateTime?)Convert.ToDateTime(Eval("RepliedOn"))
                        ) %>
                </div>
            </div>
        </ItemTemplate>
    </asp:Repeater>

</div>

</asp:Content>