<%@ Page Title="Students" Language="C#" MasterPageFile="~/Admin/AdminMaster.master"
    AutoEventWireup="true" CodeBehind="AddStudent.aspx.cs"
    Inherits="LearningManagementSystem.Admin.Student" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server" />
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">

<%-- ── Server hidden fields ── --%>
<asp:HiddenField ID="hfStudentUserId"    runat="server" />
<asp:HiddenField ID="hfReEnrolUserId"    runat="server" />
<asp:HiddenField ID="hfToastMsg"         runat="server" />
<asp:HiddenField ID="hfToastType"        runat="server" />
<asp:HiddenField ID="hfCurrentPage"      runat="server" Value="1" />
<asp:HiddenField ID="hfViewData"         runat="server" />
<asp:HiddenField ID="hfIsSuperAdmin"     runat="server" />

<style>
/* ═══════════════════════════════════════════════════════════
   TOKENS
═══════════════════════════════════════════════════════════ */
*,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
:root{
  --primary:#6366f1;--pd:#4f46e5;--pl:#eef2ff;
  --success:#059669;--danger:#dc2626;--warn:#d97706;--sky:#0284c7;
  --purple:#7c3aed;
  --bg:#f1f5f9;--card:#fff;--border:#e2e8f0;
  --text:#0f172a;--muted:#64748b;--dim:#94a3b8;
  --sh:0 1px 3px rgba(0,0,0,.07),0 4px 16px rgba(0,0,0,.05);
  --shl:0 8px 32px rgba(0,0,0,.13);
  --r:14px;--f:'Plus Jakarta Sans',system-ui,sans-serif;
}
body{font-family:var(--f);background:var(--bg);color:var(--text);font-size:14px}
.pg{max-width:1380px;margin:0 auto;padding:22px 16px}

/* ── HEADER ── */
.pg-hdr{display:flex;justify-content:space-between;align-items:flex-start;flex-wrap:wrap;gap:10px;margin-bottom:18px}
.pg-hdr h2{font-size:1.2rem;font-weight:800;color:var(--text)}
.pg-hdr p{font-size:12px;color:var(--muted);margin-top:2px}
.hdr-btns{display:flex;gap:8px;flex-wrap:wrap;align-items:center}

/* ── BUTTONS ── */
.btn-p{background:var(--primary);color:#fff;border:none;border-radius:9px;padding:9px 16px;font-size:13px;font-weight:700;cursor:pointer;font-family:var(--f);display:inline-flex;align-items:center;gap:6px;transition:.18s;white-space:nowrap}
.btn-p:hover{background:var(--pd)}
.btn-o{background:var(--card);color:var(--muted);border:1px solid var(--border);border-radius:9px;padding:8px 14px;font-size:13px;font-weight:600;cursor:pointer;font-family:var(--f);display:inline-flex;align-items:center;gap:6px;transition:.18s;white-space:nowrap}
.btn-o:hover{border-color:var(--primary);color:var(--primary)}
.btn-g{background:#059669;color:#fff;border:none;border-radius:9px;padding:9px 16px;font-size:13px;font-weight:700;cursor:pointer;font-family:var(--f);display:inline-flex;align-items:center;gap:6px;transition:.18s;white-space:nowrap}
.btn-g:hover{background:#047857}
.btn-warn{background:#fff7ed;color:#92400e;border:1px solid #fde68a;border-radius:9px;padding:8px 14px;font-size:13px;font-weight:700;cursor:pointer;font-family:var(--f);display:inline-flex;align-items:center;gap:6px;transition:.18s;white-space:nowrap}
.btn-warn:hover{background:#fef3c7}
.btn-purple{background:var(--purple);color:#fff;border:none;border-radius:9px;padding:9px 16px;font-size:13px;font-weight:700;cursor:pointer;font-family:var(--f);display:inline-flex;align-items:center;gap:6px;transition:.18s;white-space:nowrap}
.btn-purple:hover{background:#6d28d9}

.bico{width:30px;height:30px;border:none;border-radius:7px;cursor:pointer;display:inline-flex;align-items:center;justify-content:center;font-size:12px;transition:.15s;font-family:var(--f);flex-shrink:0}
.bico:hover{filter:brightness(.9);transform:scale(1.07)}
.bi-v{background:#e0f2fe;color:#0284c7}
.bi-e{background:#dcfce7;color:#15803d}
.bi-r{background:#f3e8ff;color:var(--purple)}
.bi-t{background:#fef9c3;color:#854d0e}
.bi-d{background:#fee2e2;color:var(--danger)}

/* ── STATS ── */
.stats{display:grid;grid-template-columns:repeat(5,1fr);gap:10px;margin-bottom:16px}
.sc{background:var(--card);border:1px solid var(--border);border-radius:var(--r);padding:12px 14px;display:flex;align-items:center;gap:10px;box-shadow:var(--sh);transition:.2s;min-width:0}
.sc:hover{transform:translateY(-2px);box-shadow:var(--shl)}
.sc-ico{width:38px;height:38px;border-radius:10px;display:flex;align-items:center;justify-content:center;font-size:15px;flex-shrink:0}
.ico-i{background:#eef2ff;color:var(--primary)}
.ico-g{background:#ecfdf5;color:var(--success)}
.ico-r{background:#fef2f2;color:var(--danger)}
.ico-a{background:#fffbeb;color:var(--warn)}
.ico-p{background:#f3e8ff;color:var(--purple)}
.sc-val{font-size:1.25rem;font-weight:800;line-height:1}
.sc-lbl{font-size:10px;font-weight:700;text-transform:uppercase;letter-spacing:.05em;color:var(--muted);margin-top:2px}

/* ── STREAM CARDS ── */
.sc-section{margin-bottom:16px}
.sc-section h5{font-size:13px;font-weight:700;color:var(--text);margin-bottom:8px;display:flex;align-items:center;gap:6px}
.sc-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(160px,1fr));gap:8px}
.scard{border-radius:12px;padding:12px;position:relative;overflow:hidden;transition:.2s}
.scard:hover{transform:translateY(-3px);box-shadow:var(--shl)}
.scard::after{content:'';position:absolute;top:-16px;right:-16px;width:60px;height:60px;border-radius:50%;background:rgba(255,255,255,.12)}
.scard .sc-label{font-size:10px;font-weight:600;opacity:.8;margin-bottom:2px}
.scard .sc-title{font-size:12px;font-weight:700;margin-bottom:6px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;color:#fff}
.scard .sc-num{font-size:1.6rem;font-weight:800;color:#fff;line-height:1}
.scard .sc-sub{font-size:10px;color:rgba(255,255,255,.75);margin-top:2px}
.sv0{background:linear-gradient(135deg,#6366f1,#818cf8)}
.sv1{background:linear-gradient(135deg,#059669,#34d399)}
.sv2{background:linear-gradient(135deg,#d97706,#fbbf24)}
.sv3{background:linear-gradient(135deg,#7c3aed,#a78bfa)}
.sv4{background:linear-gradient(135deg,#0284c7,#38bdf8)}
.sv5{background:linear-gradient(135deg,#dc2626,#f87171)}
.sv6{background:linear-gradient(135deg,#0891b2,#22d3ee)}
.sv7{background:linear-gradient(135deg,#4f46e5,#818cf8)}

/* ── PARENT SUGGESTION BANNER ── */
.parent-suggestion-banner{display:none;background:linear-gradient(135deg,#fef3c7,#fde68a);border:2px solid #f59e0b;border-radius:12px;padding:12px 16px;margin-bottom:14px;animation:slideDown .4s ease}
@keyframes slideDown{from{opacity:0;transform:translateY(-10px)}to{opacity:1;transform:translateY(0)}}
.psb-inner{display:flex;align-items:flex-start;gap:10px;flex-wrap:wrap}
.psb-icon{font-size:20px;flex-shrink:0;margin-top:2px}
.psb-text{flex:1;min-width:0}
.psb-text strong{font-size:13px;color:#92400e;display:block;margin-bottom:2px}
.psb-text span{font-size:12px;color:#78350f}
.psb-actions{display:flex;gap:7px;flex-wrap:wrap;align-items:center;margin-top:6px}
.psb-btn-yes{background:#f59e0b;color:#fff;border:none;border-radius:8px;padding:7px 14px;font-size:12px;font-weight:700;cursor:pointer;transition:.15s}
.psb-btn-yes:hover{background:#d97706}
.psb-btn-dismiss{background:transparent;color:#92400e;border:1px solid #f59e0b;border-radius:8px;padding:6px 12px;font-size:11px;cursor:pointer;transition:.15s}
.psb-btn-dismiss:hover{background:#fef3c7}

/* ── FILTER BAR ── */
.filter-bar{background:var(--card);border:1px solid var(--border);border-radius:var(--r);padding:10px 12px;margin-bottom:12px;display:flex;align-items:center;gap:8px;flex-wrap:wrap;box-shadow:var(--sh)}
.sb{position:relative;flex:1;min-width:160px}
.sb i{position:absolute;left:9px;top:50%;transform:translateY(-50%);color:var(--muted);font-size:12px;pointer-events:none}
.sb input{width:100%;border:1px solid var(--border);border-radius:8px;padding:7px 11px 7px 28px;font-size:13px;font-family:var(--f);color:var(--text);background:var(--bg);transition:.18s}
.sb input:focus{border-color:var(--primary);outline:none;box-shadow:0 0 0 3px rgba(99,102,241,.1)}
.fsel{border:1px solid var(--border);border-radius:8px;padding:7px 10px;font-size:13px;font-family:var(--f);color:var(--text);background:var(--bg);cursor:pointer;min-width:0}
.fsel:focus{border-color:var(--primary);outline:none}
.pg-sz{border:1px solid var(--border);border-radius:8px;padding:6px 8px;font-size:12px;font-family:var(--f);color:var(--muted);background:var(--bg);cursor:pointer}
.rec-info{font-size:12px;color:var(--muted);white-space:nowrap}

/* ── SUPERADMIN BANNER ── */
.sa-banner{background:linear-gradient(135deg,#fef3c7,#fde68a);border:1px solid #f59e0b;border-radius:10px;padding:10px 14px;display:flex;align-items:center;gap:10px;margin-bottom:12px;font-size:13px;font-weight:600;color:#92400e}
.sa-banner i{font-size:15px;color:#d97706;flex-shrink:0}

/* ── TABLE ── */
.tbl-wrap{background:var(--card);border:1px solid var(--border);border-radius:var(--r);box-shadow:var(--sh);overflow:hidden}
.tbl-scroll{width:100%;overflow-x:auto;-webkit-overflow-scrolling:touch}
.tbl-scroll table{width:100%;border-collapse:collapse;min-width:620px}
.tbl-scroll thead th{background:linear-gradient(135deg,var(--pd),var(--primary));color:#fff;padding:11px 12px;font-size:11px;font-weight:700;text-transform:uppercase;letter-spacing:.05em;white-space:nowrap;text-align:left;vertical-align:middle}
.tbl-scroll tbody td{padding:10px 12px;border-bottom:1px solid var(--border);font-size:13px;vertical-align:middle}
.tbl-scroll tbody tr:last-child td{border-bottom:none}
.tbl-scroll tbody tr:hover{background:#f8faff}
.tbl-scroll tbody tr.row-inactive{opacity:.55}
.tbl-empty{text-align:center;padding:44px 20px;color:var(--muted)}
.tbl-empty i{font-size:2.2rem;opacity:.18;display:block;margin-bottom:10px}

.stu-cell{display:flex;align-items:center;gap:9px}
.stu-av{width:30px;height:30px;border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:12px;font-weight:700;color:#fff;flex-shrink:0}
.stu-name{font-weight:600;font-size:13px;color:var(--text);line-height:1.2}
.stu-email{font-size:11px;color:var(--muted)}
.bdg{display:inline-flex;align-items:center;border-radius:6px;padding:2px 7px;font-size:10px;font-weight:700;white-space:nowrap}
.bdg-on{background:#dcfce7;color:#15803d}
.bdg-off{background:#f1f5f9;color:#64748b}
.act-g{display:flex;gap:3px;align-items:center;flex-wrap:nowrap}

/* ── PAGINATION ── */
.pager{display:flex;align-items:center;justify-content:space-between;padding:10px 12px;border-top:1px solid var(--border);flex-wrap:wrap;gap:8px}
.pager-info{font-size:12px;color:var(--muted)}
.pager-btns{display:flex;gap:3px;flex-wrap:wrap}
.pb{min-width:28px;height:28px;border:1px solid var(--border);border-radius:7px;background:var(--card);color:var(--muted);cursor:pointer;font-size:12px;font-weight:600;font-family:var(--f);display:flex;align-items:center;justify-content:center;padding:0 6px;transition:.15s}
.pb:hover{border-color:var(--primary);color:var(--primary)}
.pb.on{background:var(--primary);color:#fff;border-color:var(--primary)}
.pb:disabled{opacity:.35;pointer-events:none;cursor:default}

/* ══════════════════════════════════════════════════════════
   MODAL — fully responsive
══════════════════════════════════════════════════════════ */
.mo{
    display:none;
    position:fixed;
    inset:0;
    background:rgba(0,0,0,.5);
    z-index:9990;
    backdrop-filter:blur(3px);
    align-items:flex-start;
    justify-content:center;
    padding:12px;
    overflow-y:auto;
}
.mo.open{display:flex}

/* Modal box */
.mb{
    background:var(--card);
    border-radius:var(--r);
    box-shadow:var(--shl);
    width:100%;
    max-height:calc(100vh - 24px);
    display:flex;
    flex-direction:column;
    margin:auto;
    animation:mIn .22s ease;
    overflow:hidden;
}
@keyframes mIn{from{opacity:0;transform:scale(.97)}to{opacity:1;transform:scale(1)}}

/* Modal header */
.mh{
    padding:14px 18px;
    display:flex;
    justify-content:space-between;
    align-items:center;
    flex-shrink:0;
}
.mh.blue{background:linear-gradient(135deg,var(--pd),var(--primary))}
.mh.green{background:linear-gradient(135deg,#047857,#059669)}
.mh.amber{background:linear-gradient(135deg,#b45309,#d97706)}
.mh.purple{background:linear-gradient(135deg,#6d28d9,#7c3aed)}
.mh h5{color:#fff;font-size:13px;font-weight:700;margin:0}
.mc{background:rgba(255,255,255,.18);border:none;color:#fff;border-radius:7px;width:26px;height:26px;cursor:pointer;display:flex;align-items:center;justify-content:center;font-size:13px;transition:.18s;flex-shrink:0}
.mc:hover{background:rgba(255,255,255,.35)}

/* Modal body scrollable */
.mbody{
    padding:16px 18px 8px;
    overflow-y:auto;
    flex:1;
}

/* Modal footer */
.mfoot{
    padding:10px 18px 16px;
    display:flex;
    justify-content:flex-end;
    gap:8px;
    flex-wrap:wrap;
    flex-shrink:0;
    border-top:1px solid var(--border);
    background:var(--card);
}

/* ── FORM ── */
.f2{display:grid;grid-template-columns:1fr 1fr;gap:10px}
.f3{display:grid;grid-template-columns:1fr 1fr 1fr;gap:10px}
.fg{margin-bottom:0}
.fg label{display:block;font-size:11px;font-weight:700;text-transform:uppercase;letter-spacing:.04em;color:var(--muted);margin-bottom:4px}
.fc{width:100%;border:1px solid var(--border);border-radius:8px;padding:8px 10px;font-size:13px;font-family:var(--f);color:var(--text);background:var(--bg);transition:.18s}
.fc:focus{border-color:var(--primary);outline:none;box-shadow:0 0 0 3px rgba(99,102,241,.1)}
.fc.err{border-color:var(--danger);box-shadow:0 0 0 3px rgba(220,38,38,.1)}
select.fc{cursor:pointer}
.em{font-size:11px;color:var(--danger);margin-top:3px;display:none}
.em.show{display:block}
.fhint{font-size:11px;color:var(--muted);margin-top:3px}
.fsect{font-size:10px;font-weight:700;text-transform:uppercase;letter-spacing:.05em;color:var(--muted);padding:8px 0 5px;border-bottom:1px solid var(--border);margin:10px 0 12px;display:block}
.info-box{border-radius:9px;padding:9px 12px;font-size:12px;display:flex;align-items:flex-start;gap:8px;margin-bottom:10px}
.info-box i{flex-shrink:0;margin-top:1px}
.info-blue{background:var(--pl);border:1px solid #c7d2fe;color:#3730a3}
.info-amber{background:#fffbeb;border:1px solid #fde68a;color:#92400e}
.info-green{background:#f0fdf4;border:1px solid #bbf7d0;color:#15803d}

/* ── VIEW MODAL ── */
.prof-hdr{display:flex;align-items:center;gap:12px;margin-bottom:14px;padding-bottom:12px;border-bottom:1px solid var(--border);flex-wrap:wrap}
.prof-av{width:54px;height:54px;border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:20px;font-weight:700;color:#fff;flex-shrink:0}
.prof-name{font-size:1rem;font-weight:800;color:var(--text)}
.prof-meta{font-size:12px;color:var(--muted);margin-top:2px}
.dg{display:grid;grid-template-columns:1fr 1fr;gap:7px}
.dr{background:var(--bg);border-radius:8px;padding:8px 11px}
.dr-lbl{font-size:10px;font-weight:700;text-transform:uppercase;letter-spacing:.04em;color:var(--muted);margin-bottom:2px}
.dr-val{font-size:13px;font-weight:600;color:var(--text)}

/* ── BULK ── */
.drop-zone{border:2px dashed var(--border);border-radius:10px;padding:22px;text-align:center;background:var(--bg);transition:.2s;cursor:pointer}
.drop-zone:hover,.drop-zone.drag{border-color:var(--primary);background:var(--pl)}
.drop-zone i{font-size:1.6rem;color:var(--dim);margin-bottom:6px;display:block}
.drop-zone p{font-size:13px;color:var(--muted);margin-bottom:3px}
.drop-zone small{font-size:11px;color:var(--dim)}
.up-prog{height:5px;background:var(--border);border-radius:4px;overflow:hidden;margin-top:8px;display:none}
.up-fill{height:100%;background:var(--primary);border-radius:4px;width:0%;transition:width .3s}

/* ── TOAST ── */
#toast-root{position:fixed;bottom:18px;right:16px;z-index:99999;display:flex;flex-direction:column;gap:6px;pointer-events:none;max-width:90vw}
.toast-item{border-radius:11px;padding:10px 14px;font-size:13px;font-weight:600;color:#fff;animation:tIn .3s ease;max-width:360px;pointer-events:auto;box-shadow:var(--shl);display:flex;align-items:center;gap:7px;word-break:break-word}
.toast-item.ok  {background:#059669}
.toast-item.err {background:#dc2626}
.toast-item.warn{background:#d97706}
.toast-item.inf {background:var(--primary)}
@keyframes tIn{from{opacity:0;transform:translateX(40px)}to{opacity:1;transform:translateX(0)}}

/* ═══════════════════════════════════════════════════════════
   RESPONSIVE BREAKPOINTS
═══════════════════════════════════════════════════════════ */

/* Large tablet / small laptop */
@media(max-width:1100px){
    .stats{grid-template-columns:repeat(3,1fr)}
}

/* Tablet */
@media(max-width:768px){
    .pg{padding:14px 12px}
    .pg-hdr{gap:8px}
    .pg-hdr h2{font-size:1.1rem}
    .stats{grid-template-columns:repeat(2,1fr)}
    .sc-grid{grid-template-columns:repeat(auto-fill,minmax(140px,1fr))}
    .filter-bar{gap:7px}

    /* Table: hide less-important columns */
    .tbl-scroll table{min-width:520px}

    /* Modal: full width on tablet */
    .mb{max-width:100% !important;border-radius:12px}
    .f3{grid-template-columns:1fr 1fr}
    .f2{grid-template-columns:1fr 1fr}
    .dg{grid-template-columns:1fr 1fr}
}

/* Mobile */
@media(max-width:540px){
    .pg{padding:10px 8px}
    .stats{grid-template-columns:1fr 1fr}
    .stats .sc:last-child{grid-column:1/-1}
    .sc-grid{grid-template-columns:1fr 1fr}

    .filter-bar{flex-direction:column;align-items:stretch}
    .sb{min-width:unset;width:100%}
    .sb input{width:100%}
    .fsel,.pg-sz{width:100%}
    .rec-info{text-align:center}

    /* Header buttons: icon only on very small */
    .hdr-btns .btn-p span,
    .hdr-btns .btn-warn span{display:none}

    /* Table: narrow */
    .tbl-scroll table{min-width:480px}

    /* Modal */
    .mo{padding:6px}
    .mb{border-radius:10px;max-height:calc(100vh - 12px)}
    .mbody{padding:12px 12px 6px}
    .mfoot{padding:8px 12px 12px;gap:6px}
    .mfoot .btn-p,.mfoot .btn-g,.mfoot .btn-o,.mfoot .btn-warn,.mfoot .btn-purple{
        flex:1;justify-content:center;font-size:12px;padding:9px 10px
    }
    .f2{grid-template-columns:1fr}
    .f3{grid-template-columns:1fr}
    .dg{grid-template-columns:1fr}
    .prof-hdr{gap:10px}

    /* Action buttons: smaller */
    .bico{width:26px;height:26px;font-size:11px}
}

/* Very small */
@media(max-width:360px){
    .stats{grid-template-columns:1fr}
    .sc-grid{grid-template-columns:1fr}
    .pg-hdr h2{font-size:1rem}
}

/* Ensure modal doesn't overflow on landscape mobile */
@media(max-height:500px) and (max-width:768px){
    .mb{max-height:calc(100vh - 8px)}
    .mbody{padding:8px 10px 4px}
}
</style>

<div class="pg">

<%-- ── HEADER ── --%>
<div class="pg-hdr">
    <div>
        <h2><i class="fa fa-user-graduate me-2" style="color:var(--primary)"></i>Students Management</h2>
        <p>Enrol · edit · re-enrol · bulk import students · track activity</p>
    </div>
    <div class="hdr-btns">
        <button type="button" class="btn-warn" id="btnBulkUploadOpen">
            <i class="fa fa-file-import"></i><span> Bulk Upload</span>
        </button>
        <button type="button" class="btn-p" id="btnAddStudent">
            <i class="fa fa-plus"></i><span> Add Student</span>
        </button>
    </div>
</div>

<%-- ── SUPERADMIN BANNER ── --%>
<div class="sa-banner" id="saBanner" style="display:none">
    <i class="fa fa-eye"></i>
    <span>You are logged in as <strong>Super Admin</strong> — View Only access. CRUD operations are disabled.</span>
</div>

<%-- ── PARENT SUGGESTION BANNER ── --%>
<div class="parent-suggestion-banner" id="parentSuggestionBanner">
    <div class="psb-inner">
        <div class="psb-icon">👨‍👩‍👦</div>
        <div class="psb-text">
            <strong id="psbTitle">Student added successfully!</strong>
            <span id="psbMsg">Would you like to enroll a parent/guardian for this student?</span>
        </div>
        <div class="psb-actions">
            <button class="psb-btn-yes" id="psbYesBtn" onclick="goToParentPage()">
                <i class="fa fa-user-plus me-1"></i> Enroll Parent
            </button>
            <button class="psb-btn-dismiss" onclick="dismissParentSuggestion()">Maybe Later</button>
        </div>
    </div>
</div>

<%-- ── STATS ── --%>
<div class="stats">
    <div class="sc"><div class="sc-ico ico-i"><i class="fa fa-users"></i></div>
        <div><div class="sc-val"><asp:Label ID="lblTotalStudents"   runat="server">0</asp:Label></div>
             <div class="sc-lbl">Total</div></div></div>
    <div class="sc"><div class="sc-ico ico-g"><i class="fa fa-check-circle"></i></div>
        <div><div class="sc-val"><asp:Label ID="lblActiveStudents"  runat="server">0</asp:Label></div>
             <div class="sc-lbl">Active</div></div></div>
    <div class="sc"><div class="sc-ico ico-r"><i class="fa fa-times-circle"></i></div>
        <div><div class="sc-val"><asp:Label ID="lblInactiveStudents" runat="server">0</asp:Label></div>
             <div class="sc-lbl">Inactive</div></div></div>
    <div class="sc"><div class="sc-ico ico-a"><i class="fa fa-calendar-plus"></i></div>
        <div><div class="sc-val"><asp:Label ID="lblNewStudents"     runat="server">0</asp:Label></div>
             <div class="sc-lbl">New This Month</div></div></div>
    <div class="sc"><div class="sc-ico ico-p"><i class="fa fa-sync"></i></div>
        <div><div class="sc-val"><asp:Label ID="lblReEnrolled"      runat="server">0</asp:Label></div>
             <div class="sc-lbl">Re-enrolled</div></div></div>
</div>

<%-- ── STREAM / COURSE CARDS ── --%>
<div class="sc-section">
    <h5><i class="fa fa-layer-group me-1" style="color:var(--primary)"></i>Students by Stream &amp; Course</h5>
    <div class="sc-grid">
        <asp:Repeater ID="rptStats" runat="server">
            <ItemTemplate>
                <div class="scard sv<%# Container.ItemIndex % 8 %>">
                    <div class="sc-label"><%# Server.HtmlEncode(Eval("StreamName")?.ToString() ?? "No Stream") %></div>
                    <div class="sc-title"><%# Server.HtmlEncode(Eval("CourseName")?.ToString() ?? "No Course") %></div>
                    <div class="sc-num"><%# Eval("TotalStudents") %></div>
                    <div class="sc-sub">students enrolled</div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>
</div>

<%-- ── FILTER BAR ── --%>
<div class="filter-bar">
    <div class="sb">
        <i class="fa fa-search"></i>
        <input type="text" id="txtSearchClient" placeholder="Search name, roll no, email…" oninput="clientSearch(this.value)" />
    </div>
    <asp:DropDownList ID="ddlFilterStream" runat="server" CssClass="fsel" AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed" />
    <asp:DropDownList ID="ddlFilterStatus" runat="server" CssClass="fsel" AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed">
        <asp:ListItem Text="Active"   Value="1" Selected="True" />
        <asp:ListItem Text="Inactive" Value="0" />
    </asp:DropDownList>
    <asp:DropDownList ID="ddlPageSize" runat="server" CssClass="pg-sz" AutoPostBack="true" OnSelectedIndexChanged="PageSize_Changed">
        <asp:ListItem Text="10 / page" Value="10" />
        <asp:ListItem Text="25 / page" Value="25" />
        <asp:ListItem Text="50 / page" Value="50" />
    </asp:DropDownList>
    <span class="rec-info"><asp:Label ID="lblRecordInfo" runat="server" /></span>
</div>

<%-- ── TABLE ── --%>
<div class="tbl-wrap">
    <div class="tbl-scroll">
        <asp:GridView ID="gvStudents" runat="server"
            AutoGenerateColumns="false"
            CssClass="stu-tbl"
            GridLines="None"
            OnRowCommand="gvStudents_RowCommand"
            OnRowDataBound="gvStudents_RowDataBound">
            <EmptyDataTemplate>
                <div class="tbl-empty">
                    <i class="fa fa-user-slash"></i>
                    <h5>No students found</h5>
                    <p>Try changing filters or add a new student.</p>
                </div>
            </EmptyDataTemplate>
            <Columns>
                <asp:TemplateField HeaderText="#">
                    <ItemTemplate><%# GetRowNumber(Container.DataItemIndex) %></ItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Student">
                    <ItemTemplate>
                        <div class="stu-cell">
                            <div class="stu-av" style="background:<%# GetAvatarColor(Container.DataItemIndex) %>">
                                <%# GetInitial(Eval("FullName")?.ToString()) %>
                            </div>
                            <div>
                                <div class="stu-name"><%# Server.HtmlEncode(Eval("FullName")?.ToString() ?? "—") %></div>
                                <div class="stu-email"><%# Server.HtmlEncode(Eval("Email")?.ToString() ?? "") %></div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:TemplateField>
                <asp:BoundField DataField="RollNumber" HeaderText="Roll No" />
                <asp:TemplateField HeaderText="Stream / Course">
                    <ItemTemplate>
                        <div style="font-size:13px;font-weight:600;color:var(--text)"><%# Server.HtmlEncode(Eval("StreamName")?.ToString() ?? "—") %></div>
                        <div style="font-size:11px;color:var(--muted)"><%# Server.HtmlEncode(Eval("CourseName")?.ToString() ?? "—") %></div>
                    </ItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Year / Sem">
                    <ItemTemplate>
                        <div style="font-size:12px;font-weight:500"><%# Server.HtmlEncode(Eval("LevelName")?.ToString() ?? "—") %></div>
                        <div style="font-size:11px;color:var(--muted)"><%# Server.HtmlEncode(Eval("SemesterName")?.ToString() ?? "") %></div>
                    </ItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Actions">
                    <ItemTemplate>
                        <div class="act-g">
                            <asp:LinkButton runat="server" CssClass="bico bi-v" CommandName="ViewRow" CommandArgument='<%# Eval("UserId") %>' ToolTip="View Profile"><i class="fa fa-eye"></i></asp:LinkButton>
                            <asp:LinkButton runat="server" CssClass="bico bi-e" CommandName="EditRow" CommandArgument='<%# Eval("UserId") %>' ToolTip="Edit Student"><i class="fa fa-pen"></i></asp:LinkButton>
                            <asp:LinkButton runat="server" CssClass="bico bi-r" CommandName="ReEnroll" CommandArgument='<%# Eval("UserId") %>' ToolTip="Re-enrol"><i class="fa fa-sync"></i></asp:LinkButton>
                            <asp:LinkButton runat="server" CssClass="bico bi-t" CommandName="Toggle" CommandArgument='<%# Eval("UserId") %>' ToolTip="Toggle Active/Inactive" OnClientClick="return confirm('Toggle this student\'s active status?');"><i class="fa fa-power-off"></i></asp:LinkButton>
                            <asp:LinkButton runat="server" CssClass="bico bi-d" CommandName="DeleteRow" CommandArgument='<%# Eval("UserId") %>' ToolTip="Delete Student" OnClientClick="return confirm('Permanently delete this student?');"><i class="fa fa-trash"></i></asp:LinkButton>
                        </div>
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
        </asp:GridView>
    </div>
    <div class="pager">
        <div class="pager-info">
            Page <strong><asp:Label ID="lblCurrentPage" runat="server">1</asp:Label></strong>
            of <strong><asp:Label ID="lblTotalPages" runat="server">1</asp:Label></strong>
        </div>
        <div class="pager-btns">
            <asp:LinkButton ID="btnFirst" runat="server" CssClass="pb" OnClick="Pager_Click" CommandArgument="First">«</asp:LinkButton>
            <asp:LinkButton ID="btnPrev"  runat="server" CssClass="pb" OnClick="Pager_Click" CommandArgument="Prev">‹</asp:LinkButton>
            <asp:PlaceHolder ID="phPages" runat="server"></asp:PlaceHolder>
            <asp:LinkButton ID="btnNext"  runat="server" CssClass="pb" OnClick="Pager_Click" CommandArgument="Next">›</asp:LinkButton>
            <asp:LinkButton ID="btnLast"  runat="server" CssClass="pb" OnClick="Pager_Click" CommandArgument="Last">»</asp:LinkButton>
        </div>
    </div>
</div>

</div><%-- /pg --%>

<%-- ══════════ ADD STUDENT MODAL ══════════ --%>
<div class="mo" id="addMo">
    <div class="mb" style="max-width:680px">
        <div class="mh blue">
            <h5 id="addMoTitle"><i class="fa fa-user-plus me-2"></i>Add New Student</h5>
            <button type="button" class="mc" onclick="closeMo('addMo')"><i class="fa fa-times"></i></button>
        </div>
        <div class="mbody">
            <div class="info-box info-blue">
                <i class="fa fa-info-circle"></i>
                <span>Default password is <strong>Student@123</strong>. Student will be prompted to change on first login. Fields marked * are required.</span>
            </div>
            <span class="fsect">Academic Assignment (all optional)</span>
            <div class="f3">
                <div class="fg"><label>Stream</label>
                    <asp:DropDownList ID="ddlStream" runat="server" CssClass="fc" AutoPostBack="true" OnSelectedIndexChanged="ddlStream_Changed" /></div>
                <div class="fg"><label>Course</label>
                    <asp:DropDownList ID="ddlCourse" runat="server" CssClass="fc" /></div>
                <div class="fg"><label>Year / Class</label>
                    <asp:DropDownList ID="ddlStudyLevel" runat="server" CssClass="fc" onchange="validateAgeLevel()" /></div>
                <div class="fg"><label>Semester</label>
                    <asp:DropDownList ID="ddlSemester" runat="server" CssClass="fc" /></div>
                <div class="fg"><label>Section</label>
                    <asp:DropDownList ID="ddlSection" runat="server" CssClass="fc" /></div>
            </div>
            <span class="fsect">Personal Information</span>
            <div class="f2">
                <div class="fg"><label>Full Name *</label>
                    <asp:TextBox ID="txtFullName" runat="server" CssClass="fc" placeholder="e.g. John Doe" MaxLength="100" />
                    <div class="em" id="eFullName">Full name required (min 2 chars).</div></div>
                <div class="fg"><label>Roll Number *</label>
                    <asp:TextBox ID="txtRollNo" runat="server" CssClass="fc" placeholder="e.g. 24CS001" MaxLength="30" />
                    <div class="em" id="eRollNo">Roll number is required.</div></div>
                <div class="fg"><label>Username *</label>
                    <asp:TextBox ID="txtUsername" runat="server" CssClass="fc" placeholder="Unique login username" MaxLength="50" />
                    <div class="em" id="eUsername">3–50 chars: letters, numbers, underscore.</div></div>
                <div class="fg"><label>Email *</label>
                    <asp:TextBox ID="txtEmail" runat="server" CssClass="fc" placeholder="student@example.com" MaxLength="100" />
                    <div class="em" id="eEmail">Enter a valid email address.</div></div>
                <div class="fg"><label>Gender</label>
                    <asp:DropDownList ID="ddlGender" runat="server" CssClass="fc">
                        <asp:ListItem Text="Male"   Value="Male" />
                        <asp:ListItem Text="Female" Value="Female" />
                        <asp:ListItem Text="Other"  Value="Other" />
                    </asp:DropDownList></div>
                <div class="fg"><label>Date of Birth *</label>
                    <asp:TextBox ID="txtDOB" runat="server" TextMode="Date" CssClass="fc" onchange="validateAgeLevel()" />
                    <div class="em" id="eDOB">Invalid age for selected class/year.</div></div>
                <div class="fg"><label>Contact No.</label>
                    <asp:TextBox ID="txtContact" runat="server" CssClass="fc" placeholder="10–15 digit number" MaxLength="15" />
                    <div class="em" id="eContact">Enter a valid phone number.</div></div>
                <div class="fg"><label>Address</label>
                    <asp:TextBox ID="txtAddress" runat="server" CssClass="fc" placeholder="Optional" MaxLength="200" /></div>
            </div>
        </div>
        <div class="mfoot">
            <button type="button" class="btn-o" onclick="closeMo('addMo')">Cancel</button>
            <asp:Button ID="btnSave" runat="server" CssClass="btn-p" Text="Save Student" OnClick="btnSave_Click" OnClientClick="return validateAdd()" />
        </div>
    </div>
</div>

<%-- ══════════ EDIT MODAL ══════════ --%>
<div class="mo" id="editMo">
    <div class="mb" style="max-width:680px">
        <div class="mh green">
            <h5><i class="fa fa-user-edit me-2"></i>Edit Student</h5>
            <button type="button" class="mc" onclick="closeMo('editMo')"><i class="fa fa-times"></i></button>
        </div>
        <div class="mbody">
            <span class="fsect">Academic Assignment</span>
            <div class="f3">
                <div class="fg"><label>Stream</label>
                    <asp:DropDownList ID="ddlStreamEdit" runat="server" CssClass="fc" /></div>
                <div class="fg"><label>Course</label>
                    <asp:DropDownList ID="ddlCourseEdit" runat="server" CssClass="fc" /></div>
                <div class="fg"><label>Year / Class</label>
                    <asp:DropDownList ID="ddlStudyLevelEdit" runat="server" CssClass="fc" onchange="validateAgeLevelEdit()" /></div>
                <div class="fg"><label>Semester</label>
                    <asp:DropDownList ID="ddlSemesterEdit" runat="server" CssClass="fc" /></div>
                <div class="fg"><label>Section</label>
                    <asp:DropDownList ID="ddlSectionEdit" runat="server" CssClass="fc" /></div>
            </div>
            <span class="fsect">Personal Information</span>
            <div class="f2">
                <div class="fg"><label>Full Name *</label>
                    <asp:TextBox ID="txtFullNameEdit" runat="server" CssClass="fc" />
                    <div class="em" id="eFullNameE">Full name is required.</div></div>
                <div class="fg"><label>Roll Number *</label>
                    <asp:TextBox ID="txtRollNumberEdit" runat="server" CssClass="fc" />
                    <div class="em" id="eRollE">Roll number is required.</div></div>
                <div class="fg"><label>Email *</label>
                    <asp:TextBox ID="txtEmailEdit" runat="server" CssClass="fc" />
                    <div class="em" id="eEmailE">Valid email required.</div></div>
                <div class="fg"><label>Contact No.</label>
                    <asp:TextBox ID="txtContactEdit" runat="server" CssClass="fc" /></div>
                <div class="fg"><label>Gender</label>
                    <asp:DropDownList ID="ddlGenderEdit" runat="server" CssClass="fc">
                        <asp:ListItem Text="Male"   Value="Male" />
                        <asp:ListItem Text="Female" Value="Female" />
                        <asp:ListItem Text="Other"  Value="Other" />
                    </asp:DropDownList></div>
                <div class="fg"><label>Date of Birth</label>
                    <asp:TextBox ID="txtDOBEdit" runat="server" TextMode="Date" CssClass="fc" onchange="validateAgeLevelEdit()" />
                    <div class="em" id="eDOBE">Invalid age for selected class/year.</div></div>
            </div>
        </div>
        <div class="mfoot">
            <button type="button" class="btn-o" onclick="closeMo('editMo')">Cancel</button>
            <asp:Button ID="btnUpdate" runat="server" CssClass="btn-g" Text="Update Student" OnClick="btnUpdate_Click" OnClientClick="return validateEdit()" />
        </div>
    </div>
</div>

<%-- ══════════ VIEW PROFILE MODAL ══════════ --%>
<div class="mo" id="viewMo">
    <div class="mb" style="max-width:540px">
        <div class="mh blue">
            <h5><i class="fa fa-id-card me-2"></i>Student Profile</h5>
            <button type="button" class="mc" onclick="closeMo('viewMo')"><i class="fa fa-times"></i></button>
        </div>
        <div class="mbody">
            <div class="prof-hdr">
                <div class="prof-av" id="vAv" style="background:var(--primary)">S</div>
                <div>
                    <div class="prof-name" id="vName">—</div>
                    <div class="prof-meta" id="vRoll">—</div>
                    <div style="margin-top:6px" id="vBadge"></div>
                </div>
            </div>
            <div class="dg" id="vGrid"></div>
        </div>
        <div class="mfoot">
            <button type="button" class="btn-o" onclick="closeMo('viewMo')">Close</button>
            <a id="vDashLink" href="#" class="btn-p" target="_blank">
                <i class="fa fa-external-link-alt me-1"></i>Student Dashboard
            </a>
        </div>
    </div>
</div>

<%-- ══════════ RE-ENROL MODAL ══════════ --%>
<div class="mo" id="reenrolMo">
    <div class="mb" style="max-width:560px">
        <div class="mh purple">
            <h5><i class="fa fa-sync me-2"></i>Re-enrol Student</h5>
            <button type="button" class="mc" onclick="closeMo('reenrolMo')"><i class="fa fa-times"></i></button>
        </div>
        <div class="mbody">
            <div class="info-box info-blue">
                <i class="fa fa-info-circle"></i>
                <div>Creates a fresh academic record in the chosen session. Attendance and grades start fresh; personal data is retained.</div>
            </div>
            <div class="info-box info-green" id="parentReEnrollInfo" style="display:none">
                <i class="fa fa-users"></i>
                <div id="parentReEnrollMsg">Linked parents will be automatically re-enrolled.</div>
            </div>
            <div style="font-size:14px;font-weight:700;margin-bottom:12px" id="reenrolName">Student: —</div>
            <div class="fg" style="margin-bottom:12px">
                <label>Target Session *</label>
                <asp:DropDownList ID="ddlReEnrolSession" runat="server" CssClass="fc" />
                <div class="em" id="eReSession">Please select a target session.</div>
            </div>
            <div class="f3">
                <div class="fg"><label>Stream</label>
                    <asp:DropDownList ID="ddlReEnrolStream" runat="server" CssClass="fc" /></div>
                <div class="fg"><label>Course</label>
                    <asp:DropDownList ID="ddlReEnrolCourse" runat="server" CssClass="fc" /></div>
                <div class="fg"><label>Year / Class</label>
                    <asp:DropDownList ID="ddlReEnrolLevel" runat="server" CssClass="fc" /></div>
                <div class="fg"><label>Semester</label>
                    <asp:DropDownList ID="ddlReEnrolSemester" runat="server" CssClass="fc" /></div>
                <div class="fg"><label>Section</label>
                    <asp:DropDownList ID="ddlReEnrolSection" runat="server" CssClass="fc" /></div>
                <div class="fg"><label>New Roll No</label>
                    <asp:TextBox ID="txtReEnrolRoll" runat="server" CssClass="fc" placeholder="Leave blank to keep existing" /></div>
            </div>
        </div>
        <div class="mfoot">
            <button type="button" class="btn-o" onclick="closeMo('reenrolMo')">Cancel</button>
            <asp:Button ID="btnReEnrol" runat="server" CssClass="btn-purple" Text="Confirm Re-enrolment" OnClick="btnReEnrol_Click" OnClientClick="return validateReEnrol()" />
        </div>
    </div>
</div>

<%-- ══════════ BULK UPLOAD MODAL ══════════ --%>
<div class="mo" id="bulkMo">
    <div class="mb" style="max-width:520px">
        <div class="mh amber">
            <h5><i class="fa fa-file-import me-2"></i>Bulk Student Upload</h5>
            <button type="button" class="mc" onclick="closeMo('bulkMo')"><i class="fa fa-times"></i></button>
        </div>
        <div class="mbody">
            <div class="info-box info-amber">
                <i class="fa fa-table"></i>
                <div>
                    Required columns:<br>
                    <strong>Username, Email, FullName, RollNumber, StreamId, LevelId, SemesterId, CourseId, SectionId, Gender, DOB, Contact</strong><br>
                    <span style="font-size:11px;margin-top:3px;display:block">StreamId/CourseId etc. are optional. DOB: YYYY-MM-DD. Duplicates are skipped.</span>
                </div>
            </div>
            <div class="drop-zone" id="dropZone"
                 ondragover="event.preventDefault();this.classList.add('drag')"
                 ondragleave="this.classList.remove('drag')"
                 ondrop="handleDrop(event)">
                <i class="fa fa-cloud-upload-alt"></i>
                <p>Drag &amp; drop your CSV or Excel file here</p>
                <small>or click to browse</small>
                <div style="margin-top:10px">
                    <asp:FileUpload ID="fuBulk" runat="server" CssClass="fc" style="font-size:12px" Accept=".csv,.xlsx,.xls" />
                </div>
                <div class="up-prog" id="upProg">
                    <div class="up-fill" id="upFill"></div>
                </div>
            </div>
        </div>
        <div class="mfoot">
            <button type="button" class="btn-o" onclick="closeMo('bulkMo')">Cancel</button>
            <asp:Button ID="btnUploadBulk" runat="server" CssClass="btn-warn" Text="Upload &amp; Process" OnClick="btnUploadBulk_Click" OnClientClick="return startUpload()" />
        </div>
    </div>
</div>

<%-- TOAST ROOT --%>
<div id="toast-root"></div>

<%-- 
    REPLACE the entire <script>...</script> block in AddStudent.aspx with this.
    Key fixes:
    1. Single clean clientSearch() — no duplicate blocks, no orphaned code
    2. Enter key on search input is blocked (prevents postback)
    3. oninput on the search input (already correct — keep it)
--%>

<script>
    (function () {
        'use strict';

        /* ── SuperAdmin guard ── */
        var IS_SA = document.getElementById('<%= hfIsSuperAdmin.ClientID %>').value === '1';
    if (IS_SA) {
        document.getElementById('saBanner').style.display = 'flex';
        document.getElementById('btnAddStudent').style.display = 'none';
        document.getElementById('btnBulkUploadOpen').style.display = 'none';
    }

    /* ═══════════════════════════════════════════════════════
       TOAST
    ═══════════════════════════════════════════════════════ */
    function _showToast(msg, type) {
        if (!msg || !msg.trim()) return;
        var w = document.getElementById('toast-root');
        var d = document.createElement('div');
        d.className = 'toast-item ' + (type || 'inf');
        var ic = {
            ok: 'fa-check-circle', err: 'fa-times-circle',
            warn: 'fa-exclamation-triangle', inf: 'fa-info-circle'
        };
        d.innerHTML = '<i class="fa ' + (ic[type] || ic.inf) + '"></i><span>' + msg + '</span>';
        w.appendChild(d);
        setTimeout(function () {
            d.style.opacity = '0'; d.style.transition = 'opacity .4s';
            setTimeout(function () { if (d.parentNode) d.parentNode.removeChild(d); }, 400);
        }, 6000);
    }
    window._showToast = _showToast;

    /* ═══════════════════════════════════════════════════════
       DOM READY
    ═══════════════════════════════════════════════════════ */
    document.addEventListener('DOMContentLoaded', function () {

        /* — Fire server toast from hidden fields — */
        var hm = document.getElementById('<%= hfToastMsg.ClientID %>');
        var ht = document.getElementById('<%= hfToastType.ClientID %>');
        if (hm && hm.value && hm.value.trim()) {
            _showToast(hm.value, ht ? ht.value : 'inf');
            hm.value = ''; if (ht) ht.value = '';
        }

        /* — Fire view modal from hidden field — */
        var vd = document.getElementById('<%= hfViewData.ClientID %>');
        if (vd && vd.value && vd.value.trim()) {
            try { showViewModal(JSON.parse(vd.value)); vd.value = ''; } catch (e) { }
        }

        /* — Add Student button — */
        var addBtn = document.getElementById('btnAddStudent');
        if (addBtn) addBtn.addEventListener('click', function (e) {
            e.preventDefault();
            if (IS_SA) { _showToast('SuperAdmin has view-only access.', 'warn'); return; }
            openAddModal();
        });

        /* — Bulk Upload button — */
        var bulkBtn = document.getElementById('btnBulkUploadOpen');
        if (bulkBtn) bulkBtn.addEventListener('click', function (e) {
            e.preventDefault();
            if (IS_SA) { _showToast('SuperAdmin has view-only access.', 'warn'); return; }
            openMo('bulkMo');
        });

        /* — Close modal by clicking the backdrop — */
        document.querySelectorAll('.mo').forEach(function (m) {
            m.addEventListener('click', function (e) {
                if (e.target === m) m.classList.remove('open');
            });
        });

        /* ─────────────────────────────────────────────────────
           SEARCH INPUT SETUP
           • Block Enter key so ASP.NET form does NOT submit
           • oninput="clientSearch(this.value)" already on the input
        ───────────────────────────────────────────────────── */
        var searchInput = document.getElementById('txtSearchClient');
        if (searchInput) {
            searchInput.addEventListener('keydown', function (e) {
                if (e.key === 'Enter' || e.keyCode === 13) {
                    e.preventDefault();   // ← stops postback
                    e.stopPropagation();
                }
            });
        }

        /* — SuperAdmin: block edit/toggle/delete action buttons — */
        if (IS_SA) {
            document.querySelectorAll('.stu-tbl').forEach(function (tbl) {
                tbl.addEventListener('click', function (e) {
                    var lb = e.target.closest('a'); if (!lb) return;
                    var tt = (lb.getAttribute('title') || '').toLowerCase();
                    if (tt === 'view profile') return;
                    var blocked = ['edit', 're-enrol', 'toggle', 'delete']
                        .some(function (c) { return tt.indexOf(c) !== -1; });
                    if (blocked) {
                        e.preventDefault(); e.stopPropagation();
                        _showToast('SuperAdmin has view-only access.', 'warn');
                    }
                }, true);
            });
        }
    });

    /* ═══════════════════════════════════════════════════════
       CLIENT-SIDE SEARCH
       Fixed: GridView has NO <tbody> — target <tr> directly.
       Enter key is blocked above so this runs only on oninput.
    ═══════════════════════════════════════════════════════ */
    function clientSearch(q) {
        q = (q || '').toLowerCase().trim();

        var table = document.querySelector('.tbl-scroll table');
        if (!table) return;

        /* GridView renders <tr> directly in <table> — no <tbody>.
           querySelectorAll('tr') gets all rows including header.
           slice(1) skips index 0 (the <thead> row). */
        var allRows = Array.prototype.slice.call(table.querySelectorAll('tr'), 1);
        var visible = 0;

        allRows.forEach(function (row) {
            /* Always keep the EmptyDataTemplate row visible */
            if (row.querySelector('.tbl-empty')) {
                row.style.display = '';
                return;
            }
            var match = !q || row.innerText.toLowerCase().indexOf(q) !== -1;
            row.style.display = match ? '' : 'none';
            if (match) visible++;
        });

        /* Update the record-count label */
        var info = document.querySelector('.rec-info');
        if (!info) return;

        if (!q) {
            /* Search cleared — restore server-rendered label on next
               interaction; for now just leave it or restore a neutral msg */
            info.textContent = '';
            return;
        }

        info.textContent = visible === 0
            ? 'No students match "' + q + '"'
            : visible + ' student' + (visible !== 1 ? 's' : '') + ' match';
    }
    window.clientSearch = clientSearch; /* expose so oninput="clientSearch(this.value)" works */

    /* ═══════════════════════════════════════════════════════
       MODAL HELPERS
    ═══════════════════════════════════════════════════════ */
    function openMo(id) { var el = document.getElementById(id); if (el) el.classList.add('open'); }
    function closeMo(id) { var el = document.getElementById(id); if (el) el.classList.remove('open'); }
    window.openMo = openMo;
    window.closeMo = closeMo;

    function openAddModal() {
        ['<%= txtFullName.ClientID %>','<%= txtUsername.ClientID %>',
         '<%= txtEmail.ClientID %>','<%= txtRollNo.ClientID %>',
         '<%= txtContact.ClientID %>','<%= txtAddress.ClientID %>']
            .forEach(function (id) {
                var el = document.getElementById(id); if (el) el.value = '';
            });
        var dobEl = document.getElementById('<%= txtDOB.ClientID %>');
        if (dobEl) dobEl.value = '';
        clearErrs(['eFullName', 'eUsername', 'eEmail', 'eRollNo', 'eContact', 'eDOB']);
        document.getElementById('addMoTitle').innerHTML =
            '<i class="fa fa-user-plus me-2"></i>Add New Student';
        openMo('addMo');
    }
    window.openAddModal = openAddModal;

    /* ═══════════════════════════════════════════════════════
       PARENT SUGGESTION BANNER
    ═══════════════════════════════════════════════════════ */
    function showParentSuggestion(studentName, studentId) {
        var banner = document.getElementById('parentSuggestionBanner');
        var title = document.getElementById('psbTitle');
        var msg = document.getElementById('psbMsg');
        if (!banner) return;
        if (title) title.textContent = '✅ Student "' + studentName + '" added successfully!';
        if (msg) msg.textContent = 'Would you like to enroll a parent/guardian for this student?';
        banner.style.display = 'block';
        setTimeout(function () { dismissParentSuggestion(); }, 30000);
    }
    window.showParentSuggestion = showParentSuggestion;

    function dismissParentSuggestion() {
        var banner = document.getElementById('parentSuggestionBanner');
        if (banner) {
            banner.style.opacity = '0'; banner.style.transition = 'opacity .4s';
            setTimeout(function () { banner.style.display = 'none'; banner.style.opacity = '1'; }, 400);
        }
    }
    window.dismissParentSuggestion = dismissParentSuggestion;

    function goToParentPage() { window.location.href = 'ParentManagement.aspx'; }
    window.goToParentPage = goToParentPage;

    /* ═══════════════════════════════════════════════════════
       VIEW PROFILE MODAL
    ═══════════════════════════════════════════════════════ */
    function showViewModal(d) {
        var cols = ['#6366f1', '#059669', '#d97706', '#7c3aed', '#0284c7', '#dc2626'];
        var c = cols[(d.idx || 0) % cols.length];
        document.getElementById('vAv').style.background = c;
        document.getElementById('vAv').textContent = (d.name || '?').charAt(0).toUpperCase();
        document.getElementById('vName').textContent = d.name || '—';
        document.getElementById('vRoll').textContent = 'Roll No: ' + (d.roll || '—');
        document.getElementById('vBadge').innerHTML = (d.active === 'True' || d.active === true)
            ? "<span class='bdg bdg-on'>Active</span>"
            : "<span class='bdg bdg-off'>Inactive</span>";
        var rows = [
            ['Email', d.email || '—'], ['Contact', d.contact || '—'],
            ['Stream', d.stream || '—'], ['Course', d.course || '—'],
            ['Year / Class', d.level || '—'], ['Semester', d.sem || '—'],
            ['Section', d.section || '—'], ['Gender', d.gender || '—'],
            ['Date of Birth', d.dob || '—'], ['Enrolled', d.joined || '—']
        ];
        document.getElementById('vGrid').innerHTML = rows.map(function (r) {
            return '<div class="dr"><div class="dr-lbl">' + r[0] + '</div>' +
                '<div class="dr-val">' + esc(r[1]) + '</div></div>';
        }).join('');
        document.getElementById('vDashLink').href =
            'StudentDetails.aspx?UserId=' + (d.uid || 0);
        openMo('viewMo');
    }

    /* ═══════════════════════════════════════════════════════
       RE-ENROL MODAL
    ═══════════════════════════════════════════════════════ */
    function openReEnrolModal(name, parentCount) {
        document.getElementById('reenrolName').textContent = 'Student: ' + (name || '—');
        var infoBox = document.getElementById('parentReEnrollInfo');
        var infoMsg = document.getElementById('parentReEnrollMsg');
        if (infoBox && infoMsg) {
            if (parentCount > 0) {
                infoMsg.innerHTML = '<strong>' + parentCount +
                    ' linked parent(s)</strong> will be automatically re-enrolled.';
                infoBox.style.display = 'flex';
            } else {
                infoBox.style.display = 'none';
            }
        }
        openMo('reenrolMo');
    }
    window.openReEnrolModal = openReEnrolModal;

    /* ═══════════════════════════════════════════════════════
       AGE / LEVEL VALIDATION
    ═══════════════════════════════════════════════════════ */
    var AGE_RULES = [
        { keywords: ['1st', 'grade 1', 'class 1', 'class i', 'std 1'], minAge: 5 },
        { keywords: ['2nd', 'grade 2'], minAge: 6 }, { keywords: ['3rd', 'grade 3'], minAge: 7 },
        { keywords: ['4th', 'std 4'], minAge: 8 }, { keywords: ['5th', 'std 5'], minAge: 9 },
        { keywords: ['6th', 'std 6'], minAge: 10 }, { keywords: ['7th', 'std 7'], minAge: 11 },
        { keywords: ['8th', 'std 8'], minAge: 12 }, { keywords: ['9th', 'std 9'], minAge: 13 },
        { keywords: ['10th', 'ssc', 'matric'], minAge: 14 }, { keywords: ['11th', 'hsc'], minAge: 15 },
        { keywords: ['12th', 'senior secondary'], minAge: 16 },
        { keywords: ['1st year', 'first year', 'fy', 'year 1'], minAge: 17 },
        { keywords: ['2nd year', 'second year', 'sy', 'year 2'], minAge: 18 },
        { keywords: ['3rd year', 'third year', 'ty', 'year 3'], minAge: 19 },
        { keywords: ['4th year', 'fourth year', 'year 4'], minAge: 20 },
        { keywords: ['engineering', 'b.tech', 'btech', 'b.e.', 'be '], minAge: 17 },
        { keywords: ['mba', 'm.tech', 'mtech', 'm.sc', 'msc', 'postgrad'], minAge: 21 },
        { keywords: ['phd', 'doctorate'], minAge: 23 }
    ];
    function getMinAgeForLevel(t) {
        if (!t) return 4;
        var lt = t.toLowerCase();
        for (var i = 0; i < AGE_RULES.length; i++)
            for (var j = 0; j < AGE_RULES[i].keywords.length; j++)
                if (lt.indexOf(AGE_RULES[i].keywords[j]) !== -1) return AGE_RULES[i].minAge;
        return 4;
    }
    function calcAge(v) {
        if (!v) return null;
        var d = new Date(v); if (isNaN(d.getTime())) return null;
        var n = new Date(), a = n.getFullYear() - d.getFullYear(), m = n.getMonth() - d.getMonth();
        if (m < 0 || (m === 0 && n.getDate() < d.getDate())) a--;
        return a;
    }
    function validateAgeLevel() {
        var dobEl = document.getElementById('<%= txtDOB.ClientID %>');
        var lvl = document.getElementById('<%= ddlStudyLevel.ClientID %>');
        var dv=dobEl?dobEl.value:'', lt=lvl?lvl.options[lvl.selectedIndex].text:'';
        var age=calcAge(dv), min=getMinAgeForLevel(lt), eD=document.getElementById('eDOB');
        if (dv&&age!==null&&age<4){eD.textContent='Age must be at least 4.';eD.classList.add('show');if(dobEl)dobEl.classList.add('err');return false;}
        if (dv&&age!==null&&lt&&lt.indexOf('--')===-1&&age<min){eD.textContent='For "'+lt+'", min age is '+min+'. Current: '+age+'.';eD.classList.add('show');if(dobEl)dobEl.classList.add('err');return false;}
        eD.classList.remove('show');if(dobEl)dobEl.classList.remove('err');return true;
    }
    function validateAgeLevelEdit() {
        var dobEl = document.getElementById('<%= txtDOBEdit.ClientID %>');
        var lvl   = document.getElementById('<%= ddlStudyLevelEdit.ClientID %>');
        var dv=dobEl?dobEl.value:'', lt=lvl?lvl.options[lvl.selectedIndex].text:'';
        var age=calcAge(dv), min=getMinAgeForLevel(lt), eD=document.getElementById('eDOBE');
        if (dv&&age!==null&&age<4){eD.textContent='Age must be at least 4.';eD.classList.add('show');if(dobEl)dobEl.classList.add('err');return false;}
        if (dv&&age!==null&&lt&&lt.indexOf('--')===-1&&age<min){eD.textContent='For "'+lt+'", min age is '+min+'.';eD.classList.add('show');if(dobEl)dobEl.classList.add('err');return false;}
        eD.classList.remove('show');if(dobEl)dobEl.classList.remove('err');return true;
    }

    /* ═══════════════════════════════════════════════════════
       FORM VALIDATION
    ═══════════════════════════════════════════════════════ */
    function validateAdd() {
        if (IS_SA){_showToast('SuperAdmin has view-only access.','warn');return false;}
        var ok=true;
        var fn=v('<%= txtFullName.ClientID %>'),rn=v('<%= txtRollNo.ClientID %>'),
            un=v('<%= txtUsername.ClientID %>'),em=v('<%= txtEmail.ClientID %>'),
            ct=v('<%= txtContact.ClientID %>');
        if(!fn||fn.length<2){showE_('eFullName',true,'Full name must be at least 2 characters.');ok=false;}else showE_('eFullName',false);
        if(!rn){showE_('eRollNo',true,'Roll number is required.');ok=false;}else showE_('eRollNo',false);
        if(!un||!/^[A-Za-z0-9_]{3,50}$/.test(un)){showE_('eUsername',true,'3–50 chars: letters, numbers, underscore only.');ok=false;}else showE_('eUsername',false);
        if(!em||!/^[^@\s]+@[^@\s]+\.[^@\s]{2,}$/.test(em)){showE_('eEmail',true,'Enter a valid email address.');ok=false;}else showE_('eEmail',false);
        if(!validateAgeLevel()) ok=false;
        if(ct&&!/^\d{10,15}$/.test(ct)){showE_('eContact',true,'Enter 10–15 digit contact number.');ok=false;}else showE_('eContact',false);
        if(!ok) openMo('addMo');
        return ok;
    }
    function validateEdit() {
        if (IS_SA){_showToast('SuperAdmin has view-only access.','warn');return false;}
        var ok=true;
        var fn=v('<%= txtFullNameEdit.ClientID %>'),rn=v('<%= txtRollNumberEdit.ClientID %>'),
            em=v('<%= txtEmailEdit.ClientID %>');
        if(!fn){showE_('eFullNameE',true,'Full name is required.');ok=false;}else showE_('eFullNameE',false);
        if(!rn){showE_('eRollE',true,'Roll number is required.');ok=false;}else showE_('eRollE',false);
        if(!em||!/^[^@\s]+@[^@\s]+\.[^@\s]{2,}$/.test(em)){showE_('eEmailE',true,'Valid email required.');ok=false;}else showE_('eEmailE',false);
        if(!validateAgeLevelEdit()) ok=false;
        if(!ok) openMo('editMo');
        return ok;
    }
    function validateReEnrol() {
        if (IS_SA){_showToast('SuperAdmin has view-only access.','warn');return false;}
        var s=document.getElementById('<%= ddlReEnrolSession.ClientID %>');
        if(!s||!s.value){showE_('eReSession',true,'Please select a target session.');return false;}
        showE_('eReSession',false); return true;
    }

    /* ═══════════════════════════════════════════════════════
       BULK UPLOAD
    ═══════════════════════════════════════════════════════ */
    function startUpload() {
        if (IS_SA){_showToast('SuperAdmin has view-only access.','warn');return false;}
        var fu=document.getElementById('<%= fuBulk.ClientID %>');
        if(!fu||!fu.value){_showToast('Please select a CSV or Excel file.','err');return false;}
        var p=document.getElementById('upProg'),f=document.getElementById('upFill');
        if(p){p.style.display='block';var w=0;
            var t=setInterval(function(){w=Math.min(w+4,90);if(f)f.style.width=w+'%';},80);
            setTimeout(function(){clearInterval(t);},3000);}
        return true;
    }
    function handleDrop(e) {
        e.preventDefault();
        var dz=document.getElementById('dropZone');if(dz)dz.classList.remove('drag');
        var fu=document.getElementById('<%= fuBulk.ClientID %>');
            if (fu && e.dataTransfer.files.length) {
                try { var dt = new DataTransfer(); dt.items.add(e.dataTransfer.files[0]); fu.files = dt.files; } catch (err) { }
            }
        }
        window.startUpload = startUpload;
        window.handleDrop = handleDrop;

        /* ═══════════════════════════════════════════════════════
           UTILITIES
        ═══════════════════════════════════════════════════════ */
        function v(id) { var e = document.getElementById(id); return e ? e.value.trim() : ''; }
        function showE_(id, show, msg) {
            var el = document.getElementById(id); if (!el) return;
            el.classList.toggle('show', show);
            if (msg) el.textContent = msg;
            var inp = el.previousElementSibling;
            if (inp && inp.classList) inp.classList.toggle('err', show);
        }
        function clearErrs(ids) { ids.forEach(function (id) { showE_(id, false); }); }
        function esc(s) { return String(s || '').replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;'); }

    })();
</script>

</asp:Content>

