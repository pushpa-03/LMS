<%@ Page Title="Material Viewer" Language="C#" MasterPageFile="~/Admin/AdminMaster.master"
    AutoEventWireup="true" CodeBehind="MaterialPlayer.aspx.cs"
    Inherits="LearningManagementSystem.Admin.MaterialPlayer" %>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">

<asp:HiddenField ID="hfMaterialId" runat="server" />
<asp:HiddenField ID="hfFilePath"   runat="server" />
<asp:HiddenField ID="hfFileType"   runat="server" />

<style>
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
:root {
    --primary: #6366f1;
    --primary-light: #eef2ff;
    --primary-dark: #4f46e5;
    --success: #059669;
    --danger: #dc2626;
    --warn: #d97706;
    --purple: #7c3aed;
    --bg: #f1f5f9;
    --card: #ffffff;
    --border: #e2e8f0;
    --text: #0f172a;
    --muted: #64748b;
    --shadow: 0 1px 3px rgba(0,0,0,.08), 0 4px 16px rgba(0,0,0,.06);
    --shadow-lg: 0 8px 32px rgba(0,0,0,.12);
    --radius: 12px;
    --font: 'Inter', system-ui, sans-serif;
}
body { font-family: var(--font); background: var(--bg); color: var(--text); font-size: 14px; line-height: 1.6; }

/* ── PAGE WRAPPER ── */
.mp-wrap { max-width: 1500px; margin: 0 auto; padding: 20px 22px; }
@media(max-width:700px){ .mp-wrap { padding: 12px; } }

/* ── BACK BAR ── */
.back-bar { display: flex; align-items: center; gap: 12px; margin-bottom: 18px; flex-wrap: wrap; }
.btn-back {
    display: inline-flex; align-items: center; gap: 6px;
    background: var(--card); border: 1px solid var(--border); border-radius: 10px;
    padding: 7px 14px; font-size: 13px; font-weight: 600; color: var(--muted);
    text-decoration: none; transition: .18s;
}
.btn-back:hover { border-color: var(--primary); color: var(--primary); }
.page-title { font-size: 1.15rem; font-weight: 800; color: var(--text); flex: 1; }
.btn-dl {
    display: inline-flex; align-items: center; gap: 6px;
    background: #dcfce7; color: #15803d; border: 1px solid #bbf7d0;
    border-radius: 10px; padding: 7px 16px; font-size: 13px; font-weight: 700;
    text-decoration: none; transition: .18s;
}
.btn-dl:hover { background: #bbf7d0; color: #15803d; }

/* ── MAIN GRID ── */
.mp-grid {
    display: grid;
    grid-template-columns: 1fr 360px;
    gap: 18px;
    align-items: start;
}
@media(max-width:1100px){ .mp-grid { grid-template-columns: 1fr; } }

/* ── VIEWER CARD ── */
.viewer-card {
    background: var(--card); border: 1px solid var(--border);
    border-radius: var(--radius); box-shadow: var(--shadow); overflow: hidden;
}
.viewer-toolbar {
    display: flex; align-items: center; justify-content: space-between;
    padding: 11px 16px; border-bottom: 1px solid var(--border);
    background: #fafbff; flex-wrap: wrap; gap: 8px;
}
.file-badge {
    display: inline-flex; align-items: center; gap: 5px;
    border-radius: 7px; padding: 3px 10px; font-size: 11px;
    font-weight: 800; text-transform: uppercase; letter-spacing: .04em;
}
.badge-pdf  { background: #fee2e2; color: #dc2626; }
.badge-doc  { background: #dbeafe; color: #1d4ed8; }
.badge-ppt  { background: #ffedd5; color: #ea580c; }
.badge-xls  { background: #dcfce7; color: #15803d; }
.badge-img  { background: #fef9c3; color: #854d0e; }
.badge-vid  { background: #f3e8ff; color: #7c3aed; }
.badge-gen  { background: #f1f5f9; color: #64748b; }
.toolbar-name { font-size: 13px; font-weight: 600; color: var(--text); }
.toolbar-meta { font-size: 12px; color: var(--muted); }

/* ── PDF / FILE VIEWER — FULL HEIGHT ── */
.viewer-body {
    /* Full height: calc(100vh minus header/toolbar space) */
    height: calc(100vh - 180px);
    min-height: 600px;
    overflow: hidden;
    position: relative;
    background: #525659; /* PDF viewer background */
}
.viewer-body iframe {
    width: 100%;
    height: 100%;
    border: none;
    display: block;
}
.viewer-body video {
    width: 100%; height: 100%; display: block; background: #000;
}
.viewer-body img {
    width: 100%; height: 100%; object-fit: contain;
    display: block; background: #f8fafc;
}
.unsupported {
    display: flex; flex-direction: column; align-items: center;
    justify-content: center; height: 100%; gap: 14px; color: var(--muted);
    text-align: center; padding: 40px;
}
.unsupported i { font-size: 3.5rem; opacity: .2; }
.unsupported h5 { font-size: 1rem; font-weight: 700; color: var(--text); }

/* ── INFO CARD ── */
.info-card {
    background: var(--card); border: 1px solid var(--border);
    border-radius: var(--radius); box-shadow: var(--shadow);
    padding: 16px; margin-top: 14px;
}
.info-card h6 {
    font-size: 12px; font-weight: 700; text-transform: uppercase;
    letter-spacing: .06em; color: var(--muted); margin-bottom: 12px;
}
.info-row {
    display: flex; justify-content: space-between; align-items: center;
    padding: 7px 0; border-bottom: 1px solid var(--border); font-size: 13px;
}
.info-row:last-child { border-bottom: none; }
.info-row .lbl { color: var(--muted); font-weight: 500; }
.info-row .val { font-weight: 600; color: var(--text); }

/* ── AI HISTORY (left bottom) ── */
.hist-card {
    background: var(--card); border: 1px solid var(--border);
    border-radius: var(--radius); box-shadow: var(--shadow);
    padding: 16px; margin-top: 14px;
}
.hist-card h6 {
    font-size: 12px; font-weight: 700; text-transform: uppercase;
    letter-spacing: .06em; color: var(--muted); margin-bottom: 12px;
}
.hist-scroll { max-height: 280px; overflow-y: auto; }
.hi { padding: 10px 0; border-bottom: 1px solid var(--border); }
.hi:last-child { border-bottom: none; }
.hi-type {
    display: inline-block; background: var(--primary-light); color: var(--primary);
    border-radius: 5px; padding: 1px 7px; font-size: 10px; font-weight: 700;
    text-transform: uppercase; margin-bottom: 4px;
}
.hi-q { font-size: 12px; font-weight: 600; color: var(--text); margin-bottom: 3px; }
.hi-a {
    font-size: 12px; color: var(--muted);
    display: -webkit-box; -webkit-line-clamp: 2;
    -webkit-box-orient: vertical; overflow: hidden;
}
.hi-time { font-size: 11px; color: #94a3b8; margin-top: 4px; }

/* ── RIGHT PANEL ── */
.right-col { display: flex; flex-direction: column; gap: 14px; }

/* ── AI PANEL ── */
.ai-panel {
    background: var(--card); border: 1px solid var(--border);
    border-radius: var(--radius); box-shadow: var(--shadow);
    overflow: hidden; display: flex; flex-direction: column;
}
.ai-hdr {
    background: linear-gradient(135deg, var(--primary), var(--purple));
    padding: 14px 16px; display: flex; align-items: center; gap: 8px;
}
.ai-hdr h5 { color: #fff; font-size: 14px; font-weight: 700; }
.ai-hdr small { color: rgba(255,255,255,.75); font-size: 11px; }

/* AI Tabs */
.ai-tabs { display: flex; border-bottom: 1px solid var(--border); background: #fafbff; }
.ai-tab {
    flex: 1; padding: 10px 8px; text-align: center; font-size: 12px;
    font-weight: 700; cursor: pointer; color: var(--muted);
    border-bottom: 3px solid transparent; transition: .18s; user-select: none;
}
.ai-tab.active { color: var(--primary); border-bottom-color: var(--primary); background: #fff; }
.ai-pane { display: none; }
.ai-pane.active { display: flex; flex-direction: column; }

/* Action buttons */
.ai-btns {
    display: grid; grid-template-columns: 1fr 1fr;
    gap: 8px; padding: 12px; border-bottom: 1px solid var(--border);
}
.btn-ai {
    border: none; border-radius: 9px; padding: 9px 6px;
    font-size: 12px; font-weight: 700; cursor: pointer; transition: .18s;
    display: flex; align-items: center; justify-content: center; gap: 5px;
    font-family: var(--font);
}
.btn-ai:hover { filter: brightness(.92); }
.btn-ai:disabled { opacity: .5; pointer-events: none; }
.btn-ai.quiz    { background: #eef2ff; color: var(--primary); }
.btn-ai.notes   { background: #f0fdf4; color: var(--success); }
.btn-ai.summary { background: #fff7ed; color: var(--warn); }
.btn-ai.mind    { background: #fdf4ff; color: var(--purple); }

/* AI response */
.ai-resp {
    overflow-y: auto; padding: 14px;
    min-height: 200px; max-height: 340px;
    font-size: 13px; line-height: 1.65;
}
.ai-placeholder {
    display: flex; flex-direction: column; align-items: center;
    justify-content: center; min-height: 180px; color: var(--muted);
    text-align: center; gap: 10px;
}
.ai-placeholder i { font-size: 2rem; opacity: .2; }
.ai-resp pre {
    white-space: pre-wrap; font-family: var(--font);
    font-size: 13px; line-height: 1.65;
}
.ai-spinner {
    display: flex; flex-direction: column; align-items: center;
    justify-content: center; min-height: 180px; gap: 12px; color: var(--muted);
}
.spin {
    width: 30px; height: 30px; border: 3px solid var(--border);
    border-top-color: var(--primary); border-radius: 50%;
    animation: spin .8s linear infinite;
}
@keyframes spin { to { transform: rotate(360deg); } }

/* Ask row */
.ask-row {
    display: flex; gap: 8px; padding: 12px;
    border-top: 1px solid var(--border);
}
.ask-input {
    flex: 1; border: 1px solid var(--border); border-radius: 9px;
    padding: 8px 12px; font-size: 13px; font-family: var(--font);
    color: var(--text); transition: .18s; background: var(--bg);
}
.ask-input:focus { border-color: var(--primary); outline: none; box-shadow: 0 0 0 3px rgba(99,102,241,.12); }
.btn-ask {
    background: var(--primary); color: #fff; border: none;
    border-radius: 9px; padding: 8px 14px; font-size: 13px;
    font-weight: 700; cursor: pointer; font-family: var(--font);
    white-space: nowrap; transition: .18s;
}
.btn-ask:hover { background: var(--primary-dark); }

/* History list */
.my-hist { overflow-y: auto; max-height: 340px; }

/* Copy btn */
.btn-copy {
    display: none; width: 100%; margin: 0; border: none;
    background: var(--primary); color: #fff; border-radius: 9px;
    padding: 9px; font-size: 13px; font-weight: 700; cursor: pointer;
    font-family: var(--font); transition: .18s;
}
.btn-copy:hover { background: var(--primary-dark); }

/* ── TOAST ── */
#toast-root {
    position: fixed; bottom: 24px; right: 24px; z-index: 9999;
    display: flex; flex-direction: column; gap: 8px; pointer-events: none;
}
.toast {
    border-radius: 10px; padding: 10px 16px; font-size: 13px;
    font-weight: 600; color: #fff; animation: slideIn .3s ease;
    max-width: 320px; pointer-events: auto; box-shadow: var(--shadow-lg);
}
.toast.ok  { background: #059669; }
.toast.err { background: #dc2626; }
.toast.inf { background: var(--primary); }
@keyframes slideIn { from { opacity:0; transform:translateX(40px); } to { opacity:1; transform:translateX(0); } }

.alert-auto { border-radius: 10px; font-size: 13px; padding: 10px 14px; margin-bottom: 14px; }
</style>

<!-- PAGE WRAPPER -->
<div class="mp-wrap">

<!-- BACK BAR -->
<div class="back-bar">
    <a href="javascript:history.back()" class="btn-back"><i class="fa fa-arrow-left"></i> Back</a>
    <span class="page-title">
        <i class="fa fa-file-alt me-1" style="color:var(--primary)"></i>
        <asp:Literal ID="litTitle" runat="server" />
    </span>
    <a id="lnkDownload" runat="server" class="btn-dl" target="_blank">
        <i class="fa fa-download"></i> Download
    </a>
</div>

<asp:Label ID="lblMsg" runat="server" CssClass="alert alert-warning alert-auto d-block" Visible="false" />

<!-- MAIN GRID -->
<div class="mp-grid">

    <!-- ═══ LEFT: VIEWER ═══ -->
    <div>
        <div class="viewer-card">
            <div class="viewer-toolbar">
                <div style="display:flex;align-items:center;gap:10px">
                    <span class="file-badge" id="fileBadge" runat="server">FILE</span>
                    <span class="toolbar-name" id="toolbarTitle" runat="server"></span>
                </div>
                <span class="toolbar-meta" id="toolbarMeta" runat="server"></span>
            </div>
            <!-- VIEWER BODY — full height -->
            <div class="viewer-body">
                <div id="fileViewer" runat="server" style="width:100%;height:100%"></div>
            </div>
        </div>

        <!-- Material Info -->
        <div class="info-card">
            <h6><i class="fa fa-info-circle me-1" style="color:var(--primary)"></i>Material Details</h6>
            <asp:Repeater ID="rptInfo" runat="server">
                <ItemTemplate>
                    <div class="info-row">
                        <span class="lbl"><%# Eval("Label") %></span>
                        <span class="val"><%# Eval("Value") %></span>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>

        <!-- AI History all students -->
        <div class="hist-card">
            <h6><i class="fa fa-robot me-1" style="color:var(--purple)"></i>AI Usage History — All Students</h6>
            <div class="hist-scroll">
                <asp:Repeater ID="rptHistory" runat="server">
                    <ItemTemplate>
                        <div class="hi">
                            <span class="hi-type"><%# Eval("Type") %></span>
                            <div class="hi-q"><%# Server.HtmlEncode(Eval("Question").ToString()) %></div>
                            <div class="hi-a"><%# Server.HtmlEncode(Eval("Response").ToString()) %></div>
                            <div class="hi-time">
                                <i class="fa fa-clock me-1"></i>
                                <%# Eval("CreatedOn") != DBNull.Value ? Convert.ToDateTime(Eval("CreatedOn")).ToString("dd MMM yyyy, hh:mm tt") : "" %>
                            </div>
                        </div>
                    </ItemTemplate>
                    <FooterTemplate>
                        <asp:PlaceHolder ID="phNoHist" runat="server" Visible='<%# Container.ItemIndex < 0 %>'>
                            <div style="text-align:center;padding:24px;color:var(--muted);font-size:13px">
                                <i class="fa fa-robot" style="font-size:1.6rem;display:block;margin-bottom:8px;opacity:.2"></i>
                                No AI interactions yet.
                            </div>
                        </asp:PlaceHolder>
                    </FooterTemplate>
                </asp:Repeater>
            </div>
        </div>
    </div>

    <!-- ═══ RIGHT: AI PANEL ═══ -->
    <div class="right-col">
        <div class="ai-panel">
            <div class="ai-hdr">
                <i class="fa fa-robot" style="color:#fff;font-size:16px"></i>
                <div>
                    <h5>AI Assistant</h5>
                    <small>Local Ollama · No internet required</small>
                </div>
            </div>

            <!-- TABS -->
            <div class="ai-tabs">
                <div class="ai-tab active" onclick="switchTab(this,'genPane')">Generate</div>
                <div class="ai-tab" onclick="switchTab(this,'askPane')">Ask Doubt</div>
                <div class="ai-tab" onclick="switchTab(this,'histPane')">My History</div>
            </div>

            <!-- GENERATE PANE -->
            <div id="genPane" class="ai-pane active">
                <div class="ai-btns">
                    <button class="btn-ai quiz"    id="bQuiz"    type="button" onclick="genAI('quiz')"><i class="fa fa-question-circle"></i> Quiz</button>
                    <button class="btn-ai notes"   id="bNotes"   type="button" onclick="genAI('notes')"><i class="fa fa-sticky-note"></i> Notes</button>
                    <button class="btn-ai summary" id="bSummary" type="button" onclick="genAI('summary')"><i class="fa fa-align-left"></i> Summary</button>
                    <button class="btn-ai mind"    id="bMind"    type="button" onclick="genAI('mindmap')"><i class="fa fa-project-diagram"></i> Mind Map</button>
                </div>
                <div class="ai-resp" id="genBox">
                    <div class="ai-placeholder">
                        <i class="fa fa-robot"></i>
                        <p>Click a button above to generate AI content from this material.</p>
                    </div>
                </div>
                <div style="padding:8px 12px;border-top:1px solid var(--border)">
                    <button class="btn-copy" id="copyBtn" type="button" onclick="copyResult()">
                        <i class="fa fa-copy me-1"></i> Copy Result
                    </button>
                </div>
            </div>

            <!-- ASK DOUBT PANE -->
            <div id="askPane" class="ai-pane">
                <div class="ai-resp" id="askBox" style="min-height:260px;max-height:380px">
                    <div class="ai-placeholder">
                        <i class="fa fa-question-circle"></i>
                        <p>Type a question below about this material.</p>
                    </div>
                </div>
                <div class="ask-row">
                    <input type="text" id="txtDoubt" class="ask-input"
                        placeholder="Ask anything about this material…" />
                    <button class="btn-ask" type="button" onclick="askDoubt()">
                        <i class="fa fa-paper-plane"></i>
                    </button>
                </div>
            </div>

            <!-- MY HISTORY PANE -->
            <div id="histPane" class="ai-pane">
                <div class="my-hist" id="myHistList">
                    <div class="ai-placeholder">
                        <i class="fa fa-clock"></i>
                        <p>Your AI interactions this session will appear here.</p>
                    </div>
                </div>
            </div>
        </div>
    </div>

</div><!-- /grid -->
</div><!-- /wrap -->

<div id="toast-root"></div>

<script>
    const AI_BASE = 'http://localhost:8000';
    const filePath = document.getElementById('<%= hfFilePath.ClientID %>').value;
    const matId = parseInt(document.getElementById('<%= hfMaterialId.ClientID %>').value) || 0;
    let lastResult = '';
    let myHist = [];

    /* ── Toast ── */
    function toast(msg, type = 'inf') {
        const w = document.getElementById('toast-root'), d = document.createElement('div');
        d.className = 'toast ' + type; d.textContent = msg; w.appendChild(d);
        setTimeout(() => d.remove(), 4500);
    }

    /* ── Tab switch ── */
    function switchTab(el, paneId) {
        document.querySelectorAll('.ai-tab').forEach(t => t.classList.remove('active'));
        document.querySelectorAll('.ai-pane').forEach(p => p.classList.remove('active'));
        el.classList.add('active');
        document.getElementById(paneId).classList.add('active');
    }

    /* ── Toggle AI buttons ── */
    function setAIBtns(off) {
        ['bQuiz', 'bNotes', 'bSummary', 'bMind'].forEach(id => {
            const b = document.getElementById(id); if (b) b.disabled = off;
        });
    }

    /* ── Generate AI ── */
    async function genAI(type) {
        const box = document.getElementById('genBox');
        const copyBtn = document.getElementById('copyBtn');
        box.innerHTML = `<div class="ai-spinner"><div class="spin"></div><span>Generating ${type}…</span></div>`;
        copyBtn.style.display = 'none';
        setAIBtns(true);

        const ep = { quiz: 'material-quiz', notes: 'material-notes', summary: 'material-summary', mindmap: 'material-mindmap' };
        try {
            const r = await fetch(`${AI_BASE}/${ep[type]}`, {
                method: 'POST', headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ file_path: filePath })
            });
            if (!r.ok) throw new Error('Server error ' + r.status);
            const data = await r.json();
            const text = typeof data === 'string' ? data : (data.result || data.notes || data.quiz || JSON.stringify(data, null, 2));
            box.innerHTML = `<pre>${esc(text)}</pre>`;
            lastResult = text;
            copyBtn.style.display = 'block';
            saveHist(type, 'Generated ' + type, text);
            addMyHist(type, 'Generated ' + type, text);
            toast(type.charAt(0).toUpperCase() + type.slice(1) + ' generated!', 'ok');
        } catch (e) {
            box.innerHTML = `<div class="ai-placeholder"><i class="fa fa-exclamation-triangle" style="color:var(--danger)"></i><p style="color:var(--danger)">${esc(e.message)}<br><small>Make sure AI server is running at localhost:8000</small></p></div>`;
            toast('AI error. Is the server running?', 'err');
        } finally { setAIBtns(false); }
    }

    /* ── Ask doubt ── */
    async function askDoubt() {
        const inp = document.getElementById('txtDoubt');
        const q = (inp.value || '').trim();
        if (!q) { toast('Please type a question', 'err'); return; }
        const box = document.getElementById('askBox');
        box.innerHTML = `<div class="ai-spinner"><div class="spin"></div><span>Thinking…</span></div>`;
        inp.disabled = true;
        try {
            const r = await fetch(`${AI_BASE}/material-ask`, {
                method: 'POST', headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ file_path: filePath, question: q })
            });
            if (!r.ok) throw new Error('Server error ' + r.status);
            const raw = await r.text();
            const text = raw.replace(/^"|"$/g, '').replace(/\\n/g, '\n');
            box.innerHTML = `
            <div style="background:#eef2ff;border-radius:8px;padding:10px 13px;margin-bottom:10px;font-size:12px">
                <strong style="color:var(--primary)"><i class="fa fa-question-circle me-1"></i>Question:</strong><br>${esc(q)}
            </div>
            <pre style="font-size:13px;line-height:1.65">${esc(text)}</pre>`;
            saveHist('Doubt', q, text);
            addMyHist('Doubt', q, text);
            inp.value = '';
            toast('Answer received!', 'ok');
        } catch (e) {
            box.innerHTML = `<div class="ai-placeholder"><i class="fa fa-exclamation-triangle" style="color:var(--danger)"></i><p style="color:var(--danger)">${esc(e.message)}</p></div>`;
            toast('Failed to get answer', 'err');
        } finally { inp.disabled = false; inp.focus(); }
    }

    /* ── Save history to DB ── */
    async function saveHist(type, question, response) {
        try {
            await fetch('MaterialPlayer.aspx/SaveToHistory', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json;charset=utf-8' },
                body: JSON.stringify({ materialId: matId, type, question, response })
            });
        } catch { }
    }

    /* ── My History tab ── */
    function addMyHist(type, q, resp) {
        myHist.unshift({ type, q, resp, time: new Date().toLocaleString() });
        const list = document.getElementById('myHistList');
        list.innerHTML = myHist.map(h => `
        <div class="hi">
            <span class="hi-type">${esc(h.type)}</span>
            <div class="hi-q">${esc(h.q)}</div>
            <div class="hi-a">${esc(h.resp.substring(0, 200))}${h.resp.length > 200 ? '…' : ''}</div>
            <div class="hi-time"><i class="fa fa-clock me-1"></i>${h.time}</div>
        </div>`).join('');
    }

    /* ── Copy ── */
    function copyResult() {
        if (!lastResult) return;
        navigator.clipboard.writeText(lastResult)
            .then(() => toast('Copied!', 'ok')).catch(() => toast('Copy failed', 'err'));
    }

    /* ── Escape HTML ── */
    function esc(s) {
        return String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
    }

    /* ── Enter to ask ── */
    document.getElementById('txtDoubt')?.addEventListener('keydown', e => {
        if (e.key === 'Enter' && !e.shiftKey) { e.preventDefault(); askDoubt(); }
    });
</script>
</asp:Content>

