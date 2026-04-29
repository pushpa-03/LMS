<%--<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MaterialPlayer.aspx.cs" Inherits="LMS_Project.Admin.MaterialPlayer" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Admin - Material Management</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.0/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet" />
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

    <style>
        :root { --primary-color: #4e73df; --secondary-color: #858796; }
        body { background: #f8f9fc; font-family: 'Segoe UI', sans-serif; }
        .admin-card { border: none; border-radius: 15px; box-shadow: 0 0.15rem 1.75rem 0 rgba(58, 59, 69, 0.15); background:#fff; }
        .viewer-section { height: 600px; overflow: hidden; }
        .sidebar-section { height: 600px; display: flex; flex-direction: column; }
        .chat-container { flex-grow: 1; overflow-y: auto; background: #fdfdfd; border: 1px solid #e3e6f0; border-radius: 10px; padding: 15px; }
        .nav-tabs .nav-link { color: var(--secondary-color); font-weight: 600; }
        .nav-tabs .nav-link.active { color: var(--primary-color); border-bottom: 3px solid var(--primary-color); }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:HiddenField ID="hfFilePath" runat="server" />
        <div class="container-fluid py-4">
            <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap">
    <div class="d-flex align-items-center gap-3">
        <a href="javascript:history.back()" class="btn btn-outline-secondary btn-sm rounded-pill">
            <i class="fas fa-arrow-left"></i> 
        </a>
        <h3 class="mb-0 d-flex align-items-center gap-2">
            <asp:Label ID="lblTitle" runat="server" /> 
            <span class="badge bg-primary text-uppercase" style="font-size:10px">Admin</span>
        </h3>
    </div>

    <div class="btn-group">
        <asp:HyperLink ID="lnkEdit" runat="server" CssClass="btn btn-sm btn-warning">
            <i class="fas fa-edit"></i> Edit
        </asp:HyperLink>
        <a id="downloadLink" runat="server" class="btn btn-sm btn-success">
            <i class="fas fa-download"></i> Download
        </a>
    </div>
</div>

            <div class="row">
                <div class="col-lg-8">
                    <div class="admin-card viewer-section p-2">
                        <div id="fileViewer" runat="server" style="height: 100%;"></div>
                    </div>
                </div>

                <div class="col-lg-4">
                    <div class="admin-card sidebar-section p-3">
                        <ul class="nav nav-tabs mb-3" id="adminTabs">
                            <li class="nav-item"><a class="nav-link active" data-bs-toggle="tab" href="#aiPreview">AI Tools</a></li>
                            <li class="nav-item"><a class="nav-link" data-bs-toggle="tab" href="#activityLog">History</a></li>
                        </ul>

                        <div class="tab-content d-flex flex-column flex-grow-1">
                            <div class="tab-pane fade show active flex-grow-1" id="aiPreview">
                                <div class="d-flex gap-2 mb-3">
                                    <button type="button" class="btn btn-sm btn-primary flex-fill" onclick="generateAI('quiz')">Quiz</button>
                                    <button type="button" class="btn btn-sm btn-info text-white flex-fill" onclick="generateAI('notes')">Notes</button>
                                </div>
                                
                                <div id="aiResponseBox" class="chat-container mb-2">
                                    <div class="text-center text-muted mt-5">
                                        <i class="fas fa-robot fa-3x mb-2"></i>
                                        <p>Generate Quiz or Notes to preview.</p>
                                    </div>
                                </div>
                                
                                <div class="input-group">
                                    <input id="txtAdminQuery" class="form-control" placeholder="Ask a doubt..." />
                                    <button type="button" class="btn btn-primary" onclick="askAdminDoubt()"><i class="fas fa-paper-plane"></i></button>
                                </div>
                            </div>

                            <div class="tab-pane fade flex-grow-1" id="activityLog">
                                <div id="historyContainer" class="chat-container" style="height: 450px;">
                                    <asp:Repeater ID="rptHistory" runat="server">
                                        <ItemTemplate>
                                            <div class="border-bottom py-2">
                                                <span class="badge bg-secondary mb-1"><%# Eval("Type") %></span>
                                                <p class="mb-1 small"><strong>Q:</strong> <%# Eval("Question") %></p>
                                                <p class="mb-0 small text-success"><strong>A:</strong> <%# Eval("Response") %></p>
                                            </div>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>

    <script>
        let materialId = '<%= Request.QueryString["MaterialId"] %>';

        async function generateAI(type) {
            const box = document.getElementById("aiResponseBox");
            const filePath = $('#<%= hfFilePath.ClientID %>').val();
            box.innerHTML = `<div class="text-center mt-5"><div class="spinner-border text-primary"></div><p>AI Processing...</p></div>`;

            let endpoint = type === 'quiz' ? 'material-quiz' : 'material-notes';

            try {
                const response = await fetch(`http://localhost:8000/${endpoint}`, {
                    method: "POST",
                    headers: { "Content-Type": "application/json" },
                    body: JSON.stringify({ file_path: filePath })
                });

                const data = await response.json();
                // Handle different response formats from FastAPI
                const resultText = typeof data === 'string' ? data : (data.result || data.answer || JSON.stringify(data));

                box.innerHTML = `<h6>${type.toUpperCase()} Preview:</h6><hr><div class="small" style="white-space:pre-wrap;">${resultText}</div>`;
                saveResult(type.charAt(0).toUpperCase() + type.slice(1), "Generated via AI", resultText);
            } catch (err) {
                box.innerHTML = "<div class='alert alert-danger'>AI Server is Offline</div>";
            }
        }

        async function askAdminDoubt() {
            const q = $("#txtAdminQuery").val();
            if (!q) return;
            const box = document.getElementById("aiResponseBox");
            const filePath = $('#<%= hfFilePath.ClientID %>').val();
            box.innerHTML = `<div class="text-center mt-5"><div class="spinner-border text-success"></div></div>`;

            try {
                const response = await fetch("http://localhost:8000/material-ask", {
                    method: "POST",
                    headers: { "Content-Type": "application/json" },
                    body: JSON.stringify({ file_path: filePath, question: q })
                });
                const resultText = await response.json();
                box.innerHTML = `<h6>Result:</h6><hr><div class="small" style="white-space:pre-wrap;">${resultText}</div>`;
                saveResult("Doubt", q, resultText);
                $("#txtAdminQuery").val("");
            } catch (err) { box.innerHTML = "<div class='alert alert-danger'>Error contacting AI</div>"; }
        }

        function saveResult(type, question, aiResponse) {
            $.ajax({
                type: "POST",
                url: "MaterialPlayer.aspx/SaveToHistory",
                data: JSON.stringify({ materialId: materialId, type: type, question: question, response: aiResponse }),
                contentType: "application/json; charset=utf-8",
                success: function () {
                    const entry = `<div class="border-bottom py-2 bg-light"><span class="badge bg-primary">${type}</span><p class="mb-0 small"><strong>Q:</strong> ${question}</p><p class="mb-0 small text-success"><strong>A:</strong> ${aiResponse.substring(0, 50)}...</p></div>`;
                    $("#historyContainer").prepend(entry);
                }
            });
        }
    </script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.0/js/bootstrap.bundle.min.js"></script>
</body>
</html>--%>


<%-- ------------------------------------------------------------------------------------------------------------------------------------------- --%>


<%@ Page Title="Material Viewer" Language="C#" MasterPageFile="~/Admin/AdminMaster.master"
    AutoEventWireup="true" CodeBehind="MaterialPlayer.aspx.cs"
    Inherits="LearningManagementSystem.Admin.MaterialPlayer" %>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">
<link href="https://fonts.googleapis.com/css2?family=Syne:wght@400;600;700;800&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">

<asp:HiddenField ID="hfMaterialId" runat="server" />
<asp:HiddenField ID="hfFilePath"   runat="server" />
<asp:HiddenField ID="hfFileType"   runat="server" />

<style>
:root {
    --ink:#0d0f1a; --ink-soft:#4a4f6a; --surface:#f5f6fa; --card-bg:#fff;
    --border:#e4e7f0; --accent:#4f46e5; --accent-2:#7c3aed;
    --success:#059669; --danger:#dc2626; --warn:#d97706;
    --radius:14px; --shadow:0 4px 24px rgba(13,15,26,.07);
    --shadow-lg:0 12px 48px rgba(13,15,26,.13);
}
* { box-sizing:border-box; }
body { font-family:'DM Sans',sans-serif; background:var(--surface); color:var(--ink); }

/* ── BACK BAR ── */
.back-bar { display:flex; align-items:center; gap:12px; margin-bottom:20px; flex-wrap:wrap; }
.btn-back { display:inline-flex; align-items:center; gap:7px; background:var(--card-bg); border:1px solid var(--border); border-radius:10px; padding:8px 16px; font-size:.84rem; font-weight:600; color:var(--ink-soft); text-decoration:none; transition:.2s; }
.btn-back:hover { border-color:var(--accent); color:var(--accent); }
.back-bar h2 { font-family:'Syne',sans-serif; font-weight:800; font-size:1.25rem; flex:1; }
.header-actions { display:flex; gap:8px; }
.btn-action { display:inline-flex; align-items:center; gap:6px; border-radius:10px; padding:8px 16px; font-size:.82rem; font-weight:700; cursor:pointer; transition:.2s; text-decoration:none; border:none; }
.btn-action.primary   { background:var(--accent); color:#fff; }
.btn-action.secondary { background:var(--card-bg); color:var(--ink-soft); border:1px solid var(--border); }
.btn-action.success   { background:#dcfce7; color:#15803d; }
.btn-action:hover { opacity:.88; }

/* ── LAYOUT ── */
.mp-layout { display:grid; grid-template-columns:1fr 360px; gap:20px; }
@media(max-width:1050px){ .mp-layout{grid-template-columns:1fr;} }

/* ── VIEWER CARD ── */
.viewer-card { background:var(--card-bg); border:1px solid var(--border); border-radius:var(--radius); box-shadow:var(--shadow); overflow:hidden; }
.viewer-toolbar { display:flex; align-items:center; justify-content:space-between; padding:12px 16px; border-bottom:1px solid var(--border); background:#fafbff; flex-wrap:wrap; gap:8px; }
.viewer-toolbar-left { display:flex; align-items:center; gap:10px; }
.file-badge { display:inline-flex; align-items:center; gap:6px; border-radius:8px; padding:4px 12px; font-size:.76rem; font-weight:700; text-transform:uppercase; }
.file-badge.pdf  { background:#fee2e2; color:#dc2626; }
.file-badge.doc  { background:#dbeafe; color:#1d4ed8; }
.file-badge.ppt  { background:#ffedd5; color:#ea580c; }
.file-badge.xls  { background:#dcfce7; color:#15803d; }
.file-badge.img  { background:#fef9c3; color:#ca8a04; }
.file-badge.vid  { background:#f3e8ff; color:#7c3aed; }
.file-badge.gen  { background:#f3f4f6; color:#6b7280; }
.viewer-body { height:600px; overflow:hidden; }
.viewer-body iframe,
.viewer-body video,
.viewer-body audio,
.viewer-body img   { width:100%; height:100%; border:none; display:block; }
.viewer-body img   { object-fit:contain; background:#f8f9fa; }

/* Unsupported placeholder */
.unsupported-box { display:flex; flex-direction:column; align-items:center; justify-content:center; height:100%; color:var(--ink-soft); gap:14px; }
.unsupported-box i { font-size:4rem; opacity:.25; }
.unsupported-box h5 { font-family:'Syne',sans-serif; font-weight:700; }

/* ── RIGHT PANEL ── */
.right-panel { display:flex; flex-direction:column; gap:14px; }

/* AI Panel */
.ai-panel { background:var(--card-bg); border:1px solid var(--border); border-radius:var(--radius); box-shadow:var(--shadow); overflow:hidden; display:flex; flex-direction:column; }
.ai-panel-header { background:linear-gradient(135deg,var(--accent),var(--accent-2)); padding:14px 16px; }
.ai-panel-header h5 { color:#fff; font-family:'Syne',sans-serif; font-weight:700; margin:0; font-size:.95rem; }
.ai-tabs { display:flex; border-bottom:1px solid var(--border); background:#fafbff; }
.ai-tab { flex:1; padding:10px; text-align:center; font-size:.8rem; font-weight:700; cursor:pointer; color:var(--ink-soft); border-bottom:3px solid transparent; transition:.2s; }
.ai-tab.active { color:var(--accent); border-bottom-color:var(--accent); background:#fff; }
.ai-action-btns { display:grid; grid-template-columns:1fr 1fr; gap:8px; padding:12px; border-bottom:1px solid var(--border); }
.btn-ai { border:none; border-radius:10px; padding:9px 8px; font-size:.78rem; font-weight:700; cursor:pointer; transition:.2s; display:flex; align-items:center; justify-content:center; gap:5px; }
.btn-ai.quiz    { background:#eef2ff; color:var(--accent); }
.btn-ai.notes   { background:#f0fdf4; color:var(--success); }
.btn-ai.summary { background:#fff7ed; color:var(--warn); }
.btn-ai.mind    { background:#fdf4ff; color:var(--accent-2); }
.btn-ai:hover   { filter:brightness(.94); }
.btn-ai:disabled{ opacity:.5; pointer-events:none; }

/* AI Response box */
.ai-response { flex:1; overflow-y:auto; padding:14px; min-height:220px; max-height:300px; font-size:.83rem; line-height:1.65; }
.ai-response .placeholder { display:flex; flex-direction:column; align-items:center; justify-content:center; height:100%; color:var(--ink-soft); text-align:center; gap:10px; }
.ai-response .placeholder i { font-size:2.5rem; opacity:.25; }
.ai-response pre { white-space:pre-wrap; font-family:'DM Sans',sans-serif; font-size:.82rem; }

/* Streaming cursor */
.streaming-cursor::after { content:'▊'; animation:blink .7s infinite; color:var(--accent); }
@keyframes blink { 0%,50%{opacity:1} 51%,100%{opacity:0} }

/* Loading spinner */
.ai-loading { display:flex; flex-direction:column; align-items:center; gap:10px; padding:30px; color:var(--ink-soft); font-size:.82rem; }
.spinner { width:32px; height:32px; border:3px solid var(--border); border-top-color:var(--accent); border-radius:50%; animation:spin .8s linear infinite; }
@keyframes spin { to{transform:rotate(360deg)} }

/* Ask doubt input */
.ai-ask-row { display:flex; gap:8px; padding:12px; border-top:1px solid var(--border); }
.ai-ask-input { flex:1; border:1px solid var(--border); border-radius:9px; padding:8px 12px; font-size:.83rem; font-family:'DM Sans',sans-serif; color:var(--ink); transition:.2s; }
.ai-ask-input:focus { border-color:var(--accent); outline:none; box-shadow:0 0 0 3px rgba(79,70,229,.1); }
.btn-ask { background:var(--accent); color:#fff; border:none; border-radius:9px; padding:8px 14px; font-size:.82rem; font-weight:700; cursor:pointer; white-space:nowrap; transition:.2s; }
.btn-ask:hover { opacity:.88; }

/* History tab */
.history-list { overflow-y:auto; max-height:380px; }
.history-item { padding:12px 14px; border-bottom:1px solid var(--border); }
.history-item:last-child { border-bottom:none; }
.hist-type { display:inline-block; background:#eef2ff; color:var(--accent); border-radius:6px; padding:2px 8px; font-size:.7rem; font-weight:700; text-transform:uppercase; margin-bottom:5px; }
.hist-q { font-size:.8rem; font-weight:600; color:var(--ink); margin-bottom:4px; }
.hist-a { font-size:.78rem; color:var(--ink-soft); display:-webkit-box; -webkit-line-clamp:3; -webkit-box-orient:vertical; overflow:hidden; }
.hist-time { font-size:.7rem; color:#94a3b8; margin-top:5px; }

/* Info card */
.info-card { background:var(--card-bg); border:1px solid var(--border); border-radius:var(--radius); padding:16px; box-shadow:var(--shadow); }
.info-card h6 { font-family:'Syne',sans-serif; font-weight:700; margin-bottom:12px; font-size:.88rem; }
.info-row { display:flex; justify-content:space-between; font-size:.8rem; padding:6px 0; border-bottom:1px solid var(--border); }
.info-row:last-child { border-bottom:none; }
.info-row .lbl { color:var(--ink-soft); font-weight:500; }
.info-row .val { font-weight:600; color:var(--ink); }

/* Toast */
#toast-wrap { position:fixed; bottom:24px; right:24px; z-index:9999; display:flex; flex-direction:column; gap:8px; }
.toast-msg { border-radius:12px; padding:11px 18px; font-size:.83rem; font-weight:500; box-shadow:var(--shadow-lg); animation:slideIn .3s; color:#fff; max-width:340px; }
.toast-msg.success { background:#059669; }
.toast-msg.danger  { background:#dc2626; }
.toast-msg.info    { background:#0284c7; }
@keyframes slideIn { from{opacity:0;transform:translateX(40px)} to{opacity:1;transform:translateX(0)} }

/* Alert */
.alert-auto { border-radius:10px; font-size:.85rem; padding:10px 16px; }
</style>

<!-- BACK BAR -->
<div class="back-bar">
    <a href="javascript:history.back()" class="btn-back"><i class="fa fa-arrow-left"></i> Back</a>
    <h2><i class="fa fa-file-alt me-2" style="color:var(--accent)"></i>
        <asp:Literal ID="litTitle" runat="server" /></h2>
    <div class="header-actions">
        <a id="lnkDownload" runat="server" class="btn-action success" target="_blank">
            <i class="fa fa-download"></i> Download
        </a>
    </div>
</div>

<asp:Label ID="lblMsg" runat="server" CssClass="alert alert-warning alert-auto d-block mb-3" Visible="false"></asp:Label>

<div class="mp-layout">

    <!-- ═══════ LEFT: File Viewer ═══════ -->
    <div>
        <div class="viewer-card">
            <div class="viewer-toolbar">
                <div class="viewer-toolbar-left">
                    <div class="file-badge" id="fileBadge" runat="server">FILE</div>
                    <span style="font-size:.83rem;font-weight:600" id="toolbarTitle" runat="server"></span>
                </div>
                <div style="font-size:.78rem;color:var(--ink-soft)" id="toolbarMeta" runat="server"></div>
            </div>
            <div class="viewer-body">
                <div id="fileViewer" runat="server"></div>
            </div>
        </div>

        <!-- Material Info -->
        <div class="info-card mt-3">
            <h6><i class="fa fa-info-circle me-2" style="color:var(--accent)"></i>Material Information</h6>
            <asp:Repeater ID="rptInfo" runat="server">
                <ItemTemplate>
                    <div class="info-row">
                        <span class="lbl"><%# Eval("Label") %></span>
                        <span class="val"><%# Eval("Value") %></span>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>

        <!-- AI History (All Users - Admin View) -->
        <div class="info-card mt-3">
            <h6><i class="fa fa-robot me-2" style="color:var(--accent-2)"></i>AI Usage History (All Students)</h6>
            <div class="history-list">
                <asp:Repeater ID="rptHistory" runat="server">
                    <ItemTemplate>
                        <div class="history-item">
                            <div class="hist-type"><%# Eval("Type") %></div>
                            <div class="hist-q"><%# Server.HtmlEncode(Eval("Question").ToString()) %></div>
                            <div class="hist-a"><%# Server.HtmlEncode(Eval("Response").ToString()) %></div>
                            <div class="hist-time"><i class="fa fa-clock me-1"></i><%# Eval("CreatedOn") != DBNull.Value ? Convert.ToDateTime(Eval("CreatedOn")).ToString("dd MMM yyyy, hh:mm tt") : "" %></div>
                        </div>
                    </ItemTemplate>
                    <FooterTemplate>
                        <asp:PlaceHolder ID="phNoHistory" runat="server" Visible='<%# Container.ItemIndex < 0 %>'>
                            <div style="text-align:center;padding:24px;color:var(--ink-soft);font-size:.83rem">
                                <i class="fa fa-robot" style="font-size:1.5rem;display:block;margin-bottom:8px;opacity:.3"></i>
                                No AI interactions yet.
                            </div>
                        </asp:PlaceHolder>
                    </FooterTemplate>
                </asp:Repeater>
            </div>
        </div>
    </div>

    <!-- ═══════ RIGHT: AI Panel ═══════ -->
    <div class="right-panel">

        <div class="ai-panel">
            <div class="ai-panel-header">
                <h5><i class="fa fa-robot me-2"></i>AI Assistant
                    <span style="font-size:.72rem;font-weight:400;opacity:.8;margin-left:6px">(Powered by Gemini Flash)</span>
                </h5>
            </div>

            <!-- Tabs -->
            <div class="ai-tabs">
                <div class="ai-tab active" onclick="switchAITab(this,'aiGenPane')">Generate</div>
                <div class="ai-tab" onclick="switchAITab(this,'aiAskPane')">Ask Doubt</div>
                <div class="ai-tab" onclick="switchAITab(this,'aiHistPane')">My History</div>
            </div>

            <!-- ── GENERATE TAB ── -->
            <div id="aiGenPane" class="ai-tab-pane">
                <div class="ai-action-btns">
                    <button class="btn-ai quiz"    id="btnQuiz"    onclick="generateAI('quiz')"   ><i class="fa fa-question-circle"></i> Quiz</button>
                    <button class="btn-ai notes"   id="btnNotes"   onclick="generateAI('notes')"  ><i class="fa fa-sticky-note"></i> Notes</button>
                    <button class="btn-ai summary" id="btnSummary" onclick="generateAI('summary')"><i class="fa fa-align-left"></i> Summary</button>
                    <button class="btn-ai mind"    id="btnMind"    onclick="generateAI('mindmap')"><i class="fa fa-project-diagram"></i> Mind Map</button>
                </div>
                <div class="ai-response" id="aiResponseBox">
                    <div class="placeholder">
                        <i class="fa fa-robot"></i>
                        <p>Select an action above to generate AI content from this material.</p>
                    </div>
                </div>
            </div>

            <!-- ── ASK DOUBT TAB ── -->
            <div id="aiAskPane" class="ai-tab-pane" style="display:none">
                <div class="ai-response" id="aiDoubtBox" style="min-height:280px;max-height:380px">
                    <div class="placeholder">
                        <i class="fa fa-question"></i>
                        <p>Ask any question about this material.</p>
                    </div>
                </div>
                <div class="ai-ask-row">
                    <input type="text" id="txtDoubt" class="ai-ask-input" placeholder="Type your question…"
                        onkeydown="if(event.key==='Enter')askDoubt()" />
                    <button class="btn-ask" onclick="askDoubt()"><i class="fa fa-paper-plane"></i></button>
                </div>
            </div>

            <!-- ── HISTORY TAB (this session, current admin) ── -->
            <div id="aiHistPane" class="ai-tab-pane" style="display:none">
                <div class="history-list" id="myHistoryList">
                    <div style="text-align:center;padding:24px;color:var(--ink-soft);font-size:.83rem">
                        <i class="fa fa-clock" style="font-size:1.5rem;display:block;margin-bottom:8px;opacity:.3"></i>
                        Your session AI history will appear here.
                    </div>
                </div>
            </div>
        </div>

        <!-- Copy/Save result -->
        <div id="copyResultBtn" style="display:none">
            <button class="btn-action primary" style="width:100%;justify-content:center" onclick="copyResult()">
                <i class="fa fa-copy"></i> Copy AI Result
            </button>
        </div>

    </div>
</div>

<!-- TOAST -->
<div id="toast-wrap"></div>

<script>
    const materialId = '<%= hfMaterialId.ClientID %>' ? document.getElementById('<%= hfMaterialId.ClientID %>').value : 0;
    const filePath = document.getElementById('<%= hfFilePath.ClientID %>').value;
    const fileType = document.getElementById('<%= hfFileType.ClientID %>').value;
    const AI_BASE = 'http://localhost:8000';

    let myHistory = [];
    let lastAIResult = '';

    // ── Toast ──
    function toast(msg, type) {
        const w = document.getElementById('toast-wrap');
        const t = document.createElement('div');
        t.className = 'toast-msg ' + (type || 'info');
        t.textContent = msg;
        w.appendChild(t);
        setTimeout(() => t.remove(), 5000);
    }

    // ── AI Tab switching ──
    function switchAITab(tabEl, paneId) {
        document.querySelectorAll('.ai-tab').forEach(t => t.classList.remove('active'));
        document.querySelectorAll('.ai-tab-pane').forEach(p => p.style.display = 'none');
        tabEl.classList.add('active');
        document.getElementById(paneId).style.display = 'block';
    }

    // ── Disable all AI buttons during operation ──
    function setAIBtns(disabled) {
        ['btnQuiz', 'btnNotes', 'btnSummary', 'btnMind'].forEach(id => {
            const b = document.getElementById(id);
            if (b) b.disabled = disabled;
        });
    }

    // ── Generate AI content (Quiz / Notes / Summary / Mind Map) ──
    async function generateAI(type) {
        const box = document.getElementById('aiResponseBox');
        box.innerHTML = `<div class="ai-loading"><div class="spinner"></div><span>Generating ${type}… this may take a few seconds.</span></div>`;
        document.getElementById('copyResultBtn').style.display = 'none';
        setAIBtns(true);

        const endpointMap = {
            quiz: 'material-quiz',
            notes: 'material-notes',
            summary: 'material-summary',
            mindmap: 'material-mindmap'
        };

        try {
            const res = await fetch(`${AI_BASE}/${endpointMap[type]}`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ file_path: filePath })
            });

            if (!res.ok) throw new Error(`Server error: ${res.status}`);
            const data = await res.json();
            const text = typeof data === 'string' ? data : (data.result || data.answer || JSON.stringify(data, null, 2));

            box.innerHTML = `<pre>${escHtml(text)}</pre>`;
            lastAIResult = text;
            document.getElementById('copyResultBtn').style.display = 'block';

            // Save to DB
            saveAIHistory(type, 'Generated via admin', text);
            addToMyHistory(type, 'Generated ' + type, text);
            toast(`${type.charAt(0).toUpperCase() + type.slice(1)} generated!`, 'success');
        }
        catch (err) {
            box.innerHTML = `<div class="placeholder"><i class="fa fa-exclamation-triangle" style="color:var(--danger)"></i><p style="color:var(--danger)">AI service error: ${escHtml(err.message)}<br><small>Make sure the AI server is running on port 8000.</small></p></div>`;
            toast('AI generation failed. Check server.', 'danger');
        }
        finally { setAIBtns(false); }
    }

    // ── Ask a doubt ──
    async function askDoubt() {
        const input = document.getElementById('txtDoubt');
        const q = (input.value || '').trim();
        if (!q) { toast('Please type a question.', 'danger'); return; }

        const box = document.getElementById('aiDoubtBox');
        box.innerHTML = `<div class="ai-loading"><div class="spinner"></div><span>Thinking…</span></div>`;
        input.disabled = true;

        try {
            const res = await fetch(`${AI_BASE}/material-ask`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ file_path: filePath, question: q })
            });

            if (!res.ok) throw new Error(`Server error: ${res.status}`);
            const text = await res.text();
            const clean = text.replace(/^"|"$/g, '').replace(/\\n/g, '\n');

            box.innerHTML = `
            <div style="background:#eef2ff;border-radius:10px;padding:10px 14px;margin-bottom:10px;font-size:.82rem">
                <strong><i class="fa fa-question-circle me-1" style="color:var(--accent)"></i>Question:</strong><br>${escHtml(q)}
            </div>
            <div style="font-size:.83rem;line-height:1.65"><pre>${escHtml(clean)}</pre></div>`;

            saveAIHistory('Doubt', q, clean);
            addToMyHistory('Doubt', q, clean);
            input.value = '';
            toast('Answer received!', 'success');
        }
        catch (err) {
            box.innerHTML = `<div class="placeholder"><i class="fa fa-exclamation-triangle" style="color:var(--danger)"></i><p style="color:var(--danger)">${escHtml(err.message)}</p></div>`;
            toast('Failed to get answer.', 'danger');
        }
        finally { input.disabled = false; input.focus(); }
    }

    // ── Save AI history to server ──
    async function saveAIHistory(type, question, response) {
        try {
            await fetch('MaterialPlayer.aspx/SaveToHistory', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json; charset=utf-8' },
                body: JSON.stringify({ materialId: parseInt(materialId), type, question, response })
            });
        } catch { /* Non-critical */ }
    }

    // ── Add to client-side "My History" tab ──
    function addToMyHistory(type, question, response) {
        myHistory.unshift({ type, question, response, time: new Date().toLocaleString() });
        renderMyHistory();
    }

    function renderMyHistory() {
        const list = document.getElementById('myHistoryList');
        if (!myHistory.length) return;
        list.innerHTML = myHistory.map(h => `
        <div class="history-item">
            <div class="hist-type">${escHtml(h.type)}</div>
            <div class="hist-q">${escHtml(h.question)}</div>
            <div class="hist-a">${escHtml(h.response.substring(0, 200))}${h.response.length > 200 ? '…' : ''}</div>
            <div class="hist-time"><i class="fa fa-clock me-1"></i>${h.time}</div>
        </div>`).join('');
    }

    // ── Copy result ──
    function copyResult() {
        if (!lastAIResult) return;
        navigator.clipboard.writeText(lastAIResult)
            .then(() => toast('Copied to clipboard!', 'success'))
            .catch(() => toast('Copy failed.', 'danger'));
    }

    // ── Escape HTML ──
    function escHtml(s) {
        return String(s)
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;');
    }

    // ── Keyboard shortcut: Enter to ask ──
    document.getElementById('txtDoubt')?.addEventListener('keydown', e => {
        if (e.key === 'Enter' && !e.shiftKey) { e.preventDefault(); askDoubt(); }
    });
</script>
</asp:Content>
