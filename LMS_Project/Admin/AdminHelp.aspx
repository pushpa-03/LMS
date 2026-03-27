<%@ Page Title="Help & Messages" Language="C#" MasterPageFile="~/Admin/AdminMaster.master"
    AutoEventWireup="true" CodeBehind="AdminHelp.aspx.cs"
    Inherits="LearningManagementSystem.Admin.AdminHelp" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<style>

/* ── PAGE LAYOUT ── */
.help-container { display:flex; gap:20px; height:calc(100vh - 130px); }

/* ── LEFT PANEL: message list ── */
.msg-list-panel {
    width:340px; min-width:280px;
    background:#fff; border-radius:10px;
    border:1px solid #e0e0e0;
    display:flex; flex-direction:column;
    overflow:hidden;
}

.msg-list-header {
    background:linear-gradient(135deg,#2e7d32,#43a047);
    color:#fff; padding:14px 16px;
    font-weight:600; font-size:15px;
    display:flex; align-items:center; justify-content:space-between;
}

.badge-unreplied {
    background:#ff5722; color:#fff;
    border-radius:12px; padding:2px 9px;
    font-size:12px; font-weight:700;
}

.msg-search { padding:10px; border-bottom:1px solid #eee; }
.msg-search input {
    width:100%; padding:7px 12px; border-radius:6px;
    border:1px solid #ccc; font-size:13px; outline:none;
}
.msg-search input:focus { border-color:#43a047; }

.msg-list { list-style:none; margin:0; padding:0; overflow-y:auto; flex:1; }

.msg-item {
    padding:12px 16px; cursor:pointer;
    border-bottom:1px solid #f0f0f0;
    transition:.15s;
}
.msg-item:hover   { background:#f1f8f1; }
.msg-item.active  { background:#e8f5e9; border-left:4px solid #2e7d32; }
.msg-item.unreplied .msg-name::after {
    content:" ●"; color:#ff5722; font-size:10px;
}

.msg-name   { font-weight:600; font-size:13px; color:#333; }
.msg-role   { font-size:11px; color:#888; margin-bottom:3px; }
.msg-preview{ font-size:12px; color:#666; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
.msg-time   { font-size:11px; color:#aaa; float:right; }

/* ── RIGHT PANEL: chat thread ── */
.chat-panel {
    flex:1; background:#fff; border-radius:10px;
    border:1px solid #e0e0e0;
    display:flex; flex-direction:column; overflow:hidden;
}

.chat-header {
    background:#f9f9f9; border-bottom:1px solid #eee;
    padding:14px 20px; display:flex;
    align-items:center; justify-content:space-between;
}

.chat-header-info .chat-user  { font-weight:700; font-size:15px; color:#2e7d32; }
.chat-header-info .chat-meta  { font-size:12px; color:#888; }

.chat-body {
    flex:1; overflow-y:auto;
    padding:20px; display:flex;
    flex-direction:column; gap:14px;
    background:#fafafa;
}

/* ── BUBBLE STYLES ── */
.bubble-wrap         { display:flex; flex-direction:column; max-width:72%; }
.bubble-wrap.user    { align-self:flex-start; }
.bubble-wrap.admin   { align-self:flex-end; }

.bubble {
    padding:10px 15px; border-radius:14px;
    font-size:13.5px; line-height:1.5;
    word-wrap:break-word;
}
.bubble-wrap.user  .bubble {
    background:#f0f0f0; color:#333;
    border-bottom-left-radius:2px;
}
.bubble-wrap.admin .bubble {
    background:#2e7d32; color:#fff;
    border-bottom-right-radius:2px;
}

.bubble-label {
    font-size:11px; color:#aaa;
    margin-bottom:3px;
}
.bubble-wrap.admin .bubble-label { text-align:right; }

.bubble-time {
    font-size:10px; color:#aaa; margin-top:3px;
}
.bubble-wrap.admin .bubble-time { text-align:right; }

/* ── EMPTY STATE ── */
.chat-empty {
    flex:1; display:flex;
    flex-direction:column; align-items:center; justify-content:center;
    color:#bbb;
}
.chat-empty i { font-size:48px; margin-bottom:12px; }

/* ── REPLY BOX ── */
.chat-footer {
    border-top:1px solid #eee;
    padding:14px 16px; background:#fff;
    display:flex; gap:10px; align-items:flex-end;
}

.chat-footer textarea {
    flex:1; resize:none; border-radius:8px;
    border:1px solid #ccc; padding:10px 14px;
    font-size:13px; min-height:44px; max-height:120px;
    outline:none; font-family:inherit;
    transition:.2s;
}
.chat-footer textarea:focus { border-color:#43a047; }

.btn-send {
    background:#2e7d32; color:#fff;
    border:none; border-radius:8px;
    padding:10px 18px; cursor:pointer;
    font-size:14px; transition:.2s;
    white-space:nowrap;
}
.btn-send:hover { background:#1b5e20; }
.btn-send:disabled { background:#aaa; cursor:not-allowed; }

/* ── DELETE BUTTON ── */
.btn-del {
    background:none; border:1px solid #e57373;
    color:#e57373; border-radius:6px;
    padding:5px 12px; font-size:12px; cursor:pointer;
    transition:.15s;
}
.btn-del:hover { background:#ffebee; }

/* ── ALERT ── */
.help-alert {
    padding:10px 16px; border-radius:6px;
    margin-bottom:12px; font-size:13px;
    display:none;
}
.help-alert.success { background:#e8f5e9; color:#2e7d32; border:1px solid #a5d6a7; display:block; }
.help-alert.error   { background:#ffebee; color:#c62828; border:1px solid #ef9a9a; display:block; }

@media(max-width:768px){
    .help-container { flex-direction:column; height:auto; }
    .msg-list-panel { width:100%; height:280px; }
    .chat-panel     { height:500px; }
}
</style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

<!-- Page heading -->
<div class="d-flex align-items-center mb-3">
    <i class="fas fa-headset me-2 text-success fs-5"></i>
    <h5 class="mb-0 fw-bold">Help &amp; Messages</h5>
</div>

<!-- Alert -->
<asp:Label ID="lblAlert" runat="server" CssClass="help-alert" Visible="false" />

<div class="help-container">

    <!-- ════════════════ LEFT: MESSAGE LIST ════════════════ -->
    <div class="msg-list-panel">

        <div class="msg-list-header">
            <span><i class="fas fa-inbox me-2"></i>Inbox</span>
            <asp:Label ID="lblUnrepliedBadge" runat="server" CssClass="badge-unreplied" Visible="false" />
        </div>

        <div class="msg-search">
            <input type="text" id="searchBox" placeholder="Search by name or role…" onkeyup="filterMessages()" />
        </div>

        <ul class="msg-list" id="msgList">
            <asp:Repeater ID="rptMessages" runat="server">
                <ItemTemplate>
                    <li class='msg-item <%# !(bool)Eval("HasReply") ? "unreplied" : "" %>'
                        id='item_<%# Eval("HelpId") %>'
                        onclick='window.location.href="AdminHelp.aspx?hid=<%# Eval("HelpId") %>"'>
                        <span class="msg-time"><%# ((DateTime)Eval("AskedOn")).ToString("dd MMM") %></span>
                        <div class="msg-name"><%# Eval("Username") %></div>
                        <div class="msg-role"><%# Eval("RoleName") %></div>
                        <div class="msg-preview"><%# Server.HtmlEncode(Eval("Question").ToString().Length > 55 ? Eval("Question").ToString().Substring(0,55)+"…" : Eval("Question").ToString()) %></div>
                    </li>
                </ItemTemplate>
            </asp:Repeater>
        </ul>

    </div>

    <!-- ════════════════ RIGHT: CHAT PANEL ════════════════ -->
    <div class="chat-panel">

        <!-- Empty state -->
        <div class="chat-empty" id="chatEmpty" runat="server">
            <i class="fas fa-comments"></i>
            <p>Select a message to view the conversation</p>
        </div>

        <!-- Chat thread -->
        <div id="chatThread" runat="server" style="display:flex; flex:1; flex-direction:column; overflow:hidden;">

            <div class="chat-header">
                <div class="chat-header-info">
                    <div class="chat-user">
                        <asp:Label ID="lblChatUser" runat="server" />
                    </div>
                    <div class="chat-meta">
                        <asp:Label ID="lblChatMeta" runat="server" />
                    </div>
                </div>
                <asp:LinkButton ID="btnDelete" runat="server" CssClass="btn-del"
                    OnClick="btnDelete_Click"
                    OnClientClick="return confirm('Delete this entire conversation?');">
                    <i class="fas fa-trash-alt me-1"></i>Delete
                </asp:LinkButton>
            </div>

            <!-- Bubbles -->
            <div class="chat-body" id="chatBody">
                <asp:Repeater ID="rptThread" runat="server">
                    <ItemTemplate>
                        <%# BuildBubble(
                                (bool)Eval("IsAdminReply"),
                                Eval("SenderLabel").ToString(),
                                Eval("Text").ToString(),
                                (DateTime)Eval("Time")
                            ) %>
                    </ItemTemplate>
                </asp:Repeater>
            </div>

            <!-- Reply box -->
            <div class="chat-footer">
                <asp:HiddenField ID="hfHelpId" runat="server" />
                <asp:TextBox ID="txtReply" runat="server" TextMode="MultiLine" Rows="2"
                    placeholder="Type your reply…"
                    style="flex:1;resize:none;border-radius:8px;border:1px solid #ccc;
                           padding:10px 14px;font-size:13px;min-height:44px;
                           max-height:120px;outline:none;font-family:inherit;" />
                <asp:Button ID="btnSendReply" runat="server" Text="Send Reply"
                    CssClass="btn-send" OnClick="btnSendReply_Click" />
            </div>

        </div>
    </div>

</div>

<script>
    function filterMessages() {
        var q = document.getElementById("searchBox").value.toLowerCase().trim();
        document.querySelectorAll(".msg-item").forEach(function (li) {
            if (q === "") { li.style.display = ""; return; }
            var name = li.querySelector(".msg-name") ? li.querySelector(".msg-name").textContent.toLowerCase() : "";
            var role = li.querySelector(".msg-role") ? li.querySelector(".msg-role").textContent.toLowerCase() : "";
            var preview = li.querySelector(".msg-preview") ? li.querySelector(".msg-preview").textContent.toLowerCase() : "";
            li.style.display = (name.includes(q) || role.includes(q) || preview.includes(q)) ? "" : "none";
        });
    }

    function scrollChatToBottom() {
        var cb = document.getElementById("chatBody");
        if (cb) cb.scrollTop = cb.scrollHeight;
    }

    window.addEventListener("DOMContentLoaded", function () {
        scrollChatToBottom();

        // Highlight active item based on query string
        var params = new URLSearchParams(window.location.search);
        var hid = params.get("hid");
        if (hid) {
            var el = document.getElementById("item_" + hid);
            if (el) el.classList.add("active");
        }
    });

    // Auto-grow textarea
    document.addEventListener("DOMContentLoaded", function () {
        var ta = document.querySelector(".chat-footer textarea");
        if (ta) {
            ta.addEventListener("input", function () {
                this.style.height = "auto";
                this.style.height = Math.min(this.scrollHeight, 120) + "px";
            });
        }
    });
</script>

</asp:Content>