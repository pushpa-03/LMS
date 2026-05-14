<%@ Page Title="AI Insights Dashboard" Language="C#"
    MasterPageFile="~/Admin/AdminMaster.Master"
    AutoEventWireup="true"
    CodeBehind="AIInsightsDashboard.aspx.cs"
    Inherits="LearningManagementSystem.Admin.AIInsightsDashboard" %>

<asp:Content ID="cHead" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet"/>
<style>
/* ═══ TOKENS ═══ */
:root{
  --p:#6d28d9;--pl:#ede9fe;--pd:#4c1d95;
  --g:#10b981;--gl:#d1fae5;--gd:#059669;
  --w:#f59e0b;--wl:#fef3c7;
  --r:#ef4444;--rl:#fee2e2;
  --b:#3b82f6;--bl:#dbeafe;
  --t:#0d9488;--tl:#ccfbf1;
  --ro:#f43f5e;--rol:#ffe4e6;
  --or:#ea580c;--orl:#ffedd5;
  --cy:#0891b2;--cyl:#cffafe;
  --ai:#7c3aed; /* AI purple */
  --tx:#1e293b;--ts:#64748b;--tm:#94a3b8;
  --bd:#e2e8f0;--bg:#fff;--pg:#f1f5f9;
  --rad:14px;--rads:8px;
  --sh:0 1px 3px rgba(0,0,0,.06);
  --shm:0 4px 16px rgba(0,0,0,.09);
  --shl:0 8px 28px rgba(0,0,0,.12);
}
*{box-sizing:border-box;margin:0;padding:0;}
body{background:var(--pg);font-family:'Inter','Segoe UI',system-ui,sans-serif;color:var(--tx);}
.wrap{padding:22px;}

/* ── BANNER ── */
.banner{
  position:relative;border-radius:var(--rad);overflow:hidden;
  margin-bottom:20px;min-height:168px;box-shadow:var(--shl);
  background:linear-gradient(135deg,#2e1065 0%,#4c1d95 35%,#6d28d9 65%,#7c3aed 100%);
}
.b-particles{position:absolute;inset:0;overflow:hidden;pointer-events:none;z-index:0;}
.bp{position:absolute;border-radius:50%;background:rgba(255,255,255,.07);animation:bfloat linear infinite;}
@keyframes bfloat{
  0%{transform:translateY(120%) scale(.8);opacity:0}
  10%{opacity:1}90%{opacity:.5}
  100%{transform:translateY(-60px) scale(1.1);opacity:0}
}
.b-ov{position:absolute;inset:0;background:linear-gradient(105deg,rgba(20,10,60,.72),rgba(20,10,60,.18));z-index:1;}
.b-body{position:relative;z-index:2;display:flex;align-items:center;
  justify-content:space-between;padding:26px 36px;gap:20px;flex-wrap:wrap;}
.b-icon{font-size:40px;margin-bottom:4px;display:block;}
.b-title{font-size:24px;font-weight:800;color:#fff;line-height:1.2;}
.b-sub{font-size:13px;color:rgba(255,255,255,.68);margin-top:4px;}
.b-kpis{display:flex;gap:18px;margin-top:14px;flex-wrap:wrap;}
.bk{text-align:center;}
.bk-v{font-size:22px;font-weight:900;color:#fff;line-height:1;transition:all .5s;}
.bk-l{font-size:9px;color:rgba(255,255,255,.55);text-transform:uppercase;letter-spacing:.05em;margin-top:2px;}
.bdiv{width:1px;background:rgba(255,255,255,.2);align-self:stretch;}
.live-pill{
  background:rgba(109,40,217,.35);border:1px solid rgba(167,139,250,.5);
  color:#ddd6fe;padding:5px 14px;border-radius:20px;font-size:11px;font-weight:700;
  display:inline-flex;align-items:center;gap:6px;
}
.ldot{width:7px;height:7px;border-radius:50%;background:#a78bfa;animation:pulse 1.4s infinite;}
@keyframes pulse{0%,100%{opacity:1;transform:scale(1)}50%{opacity:.4;transform:scale(.7)}}
.btn-exp{padding:9px 18px;background:rgba(255,255,255,.14);color:#fff;
  border:1px solid rgba(255,255,255,.28);border-radius:var(--rads);
  font-size:12px;font-weight:700;cursor:pointer;transition:.2s;
  display:inline-flex;align-items:center;gap:7px;}
.btn-exp:hover{background:rgba(255,255,255,.26);}
.gspin{display:inline-block;width:18px;height:18px;border:2px solid rgba(255,255,255,.25);
  border-top-color:#a78bfa;border-radius:50%;animation:spin .7s linear infinite;}
@keyframes spin{to{transform:rotate(360deg)}}

/* ── FILTER BAR ── */
.fb{background:var(--bg);border:1px solid var(--bd);border-radius:var(--rad);
  padding:16px 20px;margin-bottom:20px;box-shadow:var(--sh);}
.fb-hd{display:flex;align-items:center;justify-content:space-between;
  margin-bottom:14px;flex-wrap:wrap;gap:8px;}
.fb-lbl{font-size:12px;font-weight:700;color:var(--ts);text-transform:uppercase;
  letter-spacing:.05em;display:flex;align-items:center;gap:7px;}
.fb-acts{display:flex;gap:8px;}
.btn-ap{padding:7px 18px;background:var(--ai);color:#fff;border:none;
  border-radius:var(--rads);font-size:12px;font-weight:700;cursor:pointer;
  display:inline-flex;align-items:center;gap:5px;transition:.15s;}
.btn-ap:hover{background:var(--pd);}
.btn-rs{padding:7px 14px;background:var(--pg);color:var(--ts);
  border:1px solid var(--bd);border-radius:var(--rads);font-size:12px;
  font-weight:600;cursor:pointer;transition:.15s;}
.btn-rs:hover{background:var(--bd);}
.f-row{display:flex;flex-wrap:wrap;gap:10px;align-items:flex-end;}
.fg{display:flex;flex-direction:column;gap:4px;min-width:115px;flex:1;}
.fg label{font-size:11px;font-weight:600;color:var(--ts);}
.fsel,.fdate{padding:8px 10px;border:1.5px solid var(--bd);border-radius:var(--rads);
  font-size:13px;color:var(--tx);background:#fff;width:100%;transition:.15s;}
.fsel:focus,.fdate:focus{border-color:var(--ai);outline:none;
  box-shadow:0 0 0 3px rgba(109,40,217,.1);}
.lbar{height:3px;background:linear-gradient(90deg,var(--ai),var(--p),var(--b));
  width:0%;border-radius:2px;transition:width .4s;margin-top:10px;}
.afc{display:flex;flex-wrap:wrap;gap:6px;margin-top:10px;}
.afc-chip{background:var(--pl);color:var(--ai);padding:3px 10px;border-radius:99px;
  font-size:11px;font-weight:600;display:inline-flex;align-items:center;gap:5px;cursor:pointer;}
.afc-chip:hover{background:var(--bl);color:var(--b);}
.qr-row{display:flex;gap:6px;flex-wrap:wrap;margin-top:10px;}
.qr{padding:4px 12px;border:1px solid var(--bd);border-radius:99px;font-size:11px;
  font-weight:600;cursor:pointer;transition:.15s;background:#fff;color:var(--ts);}
.qr:hover,.qr.on{background:var(--ai);color:#fff;border-color:var(--ai);}

/* AI type quick filters */
.ai-type-row{display:flex;gap:8px;flex-wrap:wrap;margin-top:10px;}
.ai-type-btn{padding:5px 14px;border:1.5px solid var(--bd);border-radius:99px;
  font-size:12px;font-weight:600;cursor:pointer;transition:.15s;
  background:#fff;color:var(--ts);display:inline-flex;align-items:center;gap:5px;}
.ai-type-btn:hover{border-color:var(--ai);}
.ai-type-btn.on{color:#fff;border-color:transparent;}
.aib-all    .ai-type-btn.on,.ai-type-btn.on.aib-all{background:var(--ai);}
.ai-type-btn.on.t-sum  {background:#7c3aed;}
.ai-type-btn.on.t-note {background:#0891b2;}
.ai-type-btn.on.t-quiz {background:#10b981;}
.ai-type-btn.on.t-doubt{background:#f59e0b;}

/* ── KPI GRID ── */
.kpi-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(148px,1fr));
  gap:12px;margin-bottom:20px;}
.kpi{background:var(--bg);border:1px solid var(--bd);border-radius:var(--rad);
  padding:16px 15px;box-shadow:var(--sh);position:relative;overflow:hidden;
  transition:transform .18s,box-shadow .18s;}
.kpi:hover{transform:translateY(-3px);box-shadow:var(--shm);}
.kpi::before{content:'';position:absolute;top:0;left:0;right:0;height:3px;
  border-radius:var(--rad) var(--rad) 0 0;}
.kai::before{background:var(--ai);} .kg::before{background:var(--g);}
.kb::before{background:var(--b);}   .kw::before{background:var(--w);}
.kt::before{background:var(--t);}   .kr::before{background:var(--r);}
.kor::before{background:var(--or);} .kcy::before{background:var(--cy);}
.kpi-top{display:flex;align-items:center;justify-content:space-between;margin-bottom:10px;}
.klbl{font-size:10px;font-weight:700;color:var(--ts);text-transform:uppercase;letter-spacing:.06em;}
.kico{width:38px;height:38px;border-radius:10px;
  display:flex;align-items:center;justify-content:center;font-size:16px;}
.iai{background:var(--pl);color:var(--ai);}
.ig{background:var(--gl);color:var(--g);}
.ib{background:var(--bl);color:var(--b);}
.iw{background:var(--wl);color:var(--w);}
.it{background:var(--tl);color:var(--t);}
.ir{background:var(--rl);color:var(--r);}
.ior{background:var(--orl);color:var(--or);}
.icy{background:var(--cyl);color:var(--cy);}
.kval{font-size:26px;font-weight:900;color:var(--tx);line-height:1;
  letter-spacing:-.5px;transition:all .4s;}
.ksub{font-size:11px;color:var(--tm);margin-top:4px;}

/* Adoption ring inside a KPI card */
.adopt-ring{position:relative;width:56px;height:56px;flex-shrink:0;}
.adopt-ring canvas{position:absolute;inset:0;}
.adopt-pct{position:absolute;inset:0;display:flex;align-items:center;
  justify-content:center;font-size:12px;font-weight:800;color:var(--ai);}

/* ── TABS — pure JS ── */
.tab-bar{display:flex;gap:2px;background:var(--pg);border-radius:10px;padding:4px;
  margin-bottom:18px;flex-wrap:wrap;}
.tab-btn{padding:9px 16px;border:none;background:transparent;border-radius:8px;
  font-size:13px;font-weight:600;color:var(--ts);cursor:pointer;transition:.18s;
  display:flex;align-items:center;gap:6px;white-space:nowrap;outline:none;}
.tab-btn.on{background:var(--bg);color:var(--ai);box-shadow:var(--sh);}
.tab-btn:hover:not(.on){background:rgba(255,255,255,.55);color:var(--tx);}
.tab-pane{display:none;}
.tab-pane.on{display:block;animation:tabIn .22s ease;}
@keyframes tabIn{from{opacity:0;transform:translateY(5px)}to{opacity:1;transform:none}}

/* ── CARD ── */
.card{background:var(--bg);border:1px solid var(--bd);border-radius:var(--rad);
  box-shadow:var(--sh);padding:20px;transition:box-shadow .18s;}
.card:hover{box-shadow:var(--shm);}
.card-hd{display:flex;align-items:flex-start;justify-content:space-between;
  margin-bottom:16px;gap:8px;flex-wrap:wrap;}
.card-hd-l{display:flex;align-items:center;gap:10px;}
.cico{width:32px;height:32px;border-radius:9px;
  display:flex;align-items:center;justify-content:center;font-size:14px;flex-shrink:0;}
.ct{font-size:14px;font-weight:700;color:var(--tx);}
.cs{font-size:12px;color:var(--ts);margin-top:1px;}
.cb{position:relative;width:100%;}

/* Grid layouts */
.g2 {display:grid;grid-template-columns:1fr 1fr;gap:16px;margin-bottom:18px;}
.g3 {display:grid;grid-template-columns:1fr 1fr 1fr;gap:16px;margin-bottom:18px;}
.g21{display:grid;grid-template-columns:2fr 1fr;gap:16px;margin-bottom:18px;}
.g12{display:grid;grid-template-columns:1fr 2fr;gap:16px;margin-bottom:18px;}

/* ── AI USER TABLE ── */
.atbl{width:100%;border-collapse:collapse;font-size:13px;}
.atbl th{font-size:10px;font-weight:700;color:var(--ts);text-transform:uppercase;
  letter-spacing:.04em;padding:8px 12px;border-bottom:2px solid var(--bd);text-align:left;white-space:nowrap;}
.atbl td{padding:10px 12px;border-bottom:1px solid var(--bd);vertical-align:middle;}
.atbl tr:last-child td{border-bottom:none;}
.atbl tbody tr:hover td{background:#f5f3ff;}
.av{width:36px;height:36px;border-radius:50%;background:var(--pl);color:var(--ai);
  display:flex;align-items:center;justify-content:center;font-size:13px;
  font-weight:800;flex-shrink:0;overflow:hidden;border:2px solid var(--bd);}
.av img{width:100%;height:100%;object-fit:cover;}
.uname{font-weight:700;color:var(--tx);}
.uroll{font-size:11px;color:var(--tm);}
.ai-chip{display:inline-flex;align-items:center;gap:3px;padding:2px 8px;
  border-radius:99px;font-size:11px;font-weight:600;white-space:nowrap;}
.ac-sum {background:#ede9fe;color:#4c1d95;}
.ac-note{background:var(--cyl);color:#0e7490;}
.ac-quiz{background:var(--gl);color:#065f46;}
.ac-dbt {background:var(--wl);color:#92400e;}
.ac-tot {background:var(--pl);color:var(--ai);font-weight:800;}

/* Usage bar */
.ubar-wrap{display:flex;align-items:center;gap:7px;}
.ubar-bg{flex:1;height:6px;background:var(--bd);border-radius:99px;overflow:hidden;}
.ubar-fg{height:6px;border-radius:99px;background:var(--ai);transition:width 1s ease;width:0%;}
.ubar-n{font-size:12px;font-weight:700;color:var(--ai);min-width:28px;text-align:right;}

/* ── ACTIVITY FEED ── */
.act-item{display:flex;align-items:flex-start;gap:10px;
  padding:10px 0;border-bottom:1px solid var(--bd);}
.act-item:last-child{border-bottom:none;}
.act-ico{width:34px;height:34px;border-radius:9px;flex-shrink:0;
  display:flex;align-items:center;justify-content:center;font-size:14px;}
.aic-sum {background:#ede9fe;color:#4c1d95;}
.aic-note{background:var(--cyl);color:#0e7490;}
.aic-quiz{background:var(--gl);color:#065f46;}
.aic-dbt {background:var(--wl);color:#92400e;}
.aic-def {background:var(--pl);color:var(--ai);}
.aic-mat {background:var(--orl);color:var(--or);}
.act-name{font-size:13px;font-weight:600;color:var(--tx);}
.act-q{font-size:11px;color:var(--ts);margin-top:2px;
  white-space:nowrap;overflow:hidden;text-overflow:ellipsis;max-width:340px;}
.act-meta{display:flex;gap:6px;margin-top:4px;flex-wrap:wrap;}
.act-pill{padding:2px 8px;border-radius:99px;font-size:10px;font-weight:700;}
.act-time{margin-left:auto;font-size:10px;color:var(--tm);white-space:nowrap;flex-shrink:0;}

/* ── NON-USERS ── */
.nu-item{display:flex;align-items:center;gap:10px;
  padding:9px 0;border-bottom:1px solid var(--bd);}
.nu-item:last-child{border-bottom:none;}
.nu-name{font-size:13px;font-weight:600;color:var(--tx);}
.nu-meta{font-size:11px;color:var(--ts);margin-top:1px;}

/* ── PROGRESS BARS ── */
.pi{margin-bottom:12px;}
.pi-lbl{display:flex;justify-content:space-between;font-size:12px;
  font-weight:500;color:var(--tx);margin-bottom:4px;}
.pi-lbl span:last-child{color:var(--ts);}
.pi-track{height:8px;background:var(--bd);border-radius:99px;overflow:hidden;}
.pi-fill{height:8px;border-radius:99px;transition:width 1.1s ease;width:0%;}

/* ── SUGGESTIONS ── */
.sugg-card{background:linear-gradient(135deg,#4c1d95,#6d28d9,#7c3aed);
  border-radius:var(--rad);padding:20px;color:#fff;
  margin-bottom:18px;box-shadow:var(--shm);}
.sugg-title{font-size:16px;font-weight:800;margin-bottom:14px;
  display:flex;align-items:center;gap:8px;}
.sugg-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(210px,1fr));gap:12px;}
.si{background:rgba(255,255,255,.1);border-radius:10px;padding:14px;
  border:1px solid rgba(255,255,255,.18);transition:.18s;}
.si:hover{background:rgba(255,255,255,.18);transform:translateY(-2px);}
.si.warn{background:rgba(239,68,68,.2);border-color:rgba(239,68,68,.4);}
.si.ok{background:rgba(16,185,129,.2);border-color:rgba(16,185,129,.4);}
.si-ico{font-size:22px;margin-bottom:8px;display:block;}
.si-n{font-size:24px;font-weight:900;margin-bottom:3px;}
.si-hd{font-size:13px;font-weight:700;margin-bottom:4px;}
.si-tx{font-size:12px;opacity:.82;line-height:1.5;}

/* Rank badges */
.rk{width:22px;height:22px;border-radius:50%;display:flex;align-items:center;
  justify-content:center;font-size:11px;font-weight:800;flex-shrink:0;}
.r1{background:#fef3c7;color:#b45309;} .r2{background:#f3f4f6;color:#374151;}
.r3{background:#fde8d8;color:#c05621;} .rn{background:var(--pg);color:var(--ts);}

/* Empty / Spinner */
.empty{text-align:center;padding:40px;color:var(--tm);}
.empty i{font-size:32px;display:block;margin-bottom:10px;opacity:.4;}
.empty p{font-size:13px;}
.spin{display:inline-block;width:20px;height:20px;border:2px solid var(--bd);
  border-top-color:var(--ai);border-radius:50%;animation:spin .7s linear infinite;}

/* Responsive */
@media(max-width:1100px){.g21,.g12{grid-template-columns:1fr;}.g3{grid-template-columns:1fr 1fr;}}
@media(max-width:700px){.g2,.g3{grid-template-columns:1fr;}.kpi-grid{grid-template-columns:1fr 1fr;}}
@media(max-width:460px){.kpi-grid{grid-template-columns:1fr 1fr;}.tab-btn{font-size:11px;padding:7px 10px;}}
</style>
</asp:Content>

<asp:Content ID="cBody" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

<%-- Hidden fields: server → client (never posted back) --%>
<asp:HiddenField ID="hdnInst" runat="server"/>
<asp:HiddenField ID="hdnSess" runat="server"/>
<asp:HiddenField ID="hdnDfr"  runat="server"/>
<asp:HiddenField ID="hdnDto"  runat="server"/>
<asp:Label       ID="lblSess" runat="server" Style="display:none;"/>

<%-- Hidden ASP dropdowns: JS clones their options --%>
<asp:DropDownList ID="aspStream"  runat="server" Style="display:none;"/>
<asp:DropDownList ID="aspCourse"  runat="server" Style="display:none;"/>
<asp:DropDownList ID="aspSection" runat="server" Style="display:none;"/>
<asp:DropDownList ID="aspSubject" runat="server" Style="display:none;"/>

<div class="wrap">

<%-- ══ BANNER ══ --%>
<div class="banner">
  <div class="b-particles" id="bPart"></div>
  <div class="b-ov"></div>
  <div class="b-body">
    <div>
      <span class="b-icon">🤖</span>
      <div class="b-title">AI Insights Dashboard</div>
      <div class="b-sub">Session: <span id="bSess"></span> &nbsp;&bull;&nbsp;
        Track how students use AI — by stream, course, section &amp; subject
      </div>
      <div class="b-kpis">
        <div class="bk"><div class="bk-v" id="bTotal">—</div><div class="bk-l">Total Uses</div></div>
        <div class="bdiv"></div>
        <div class="bk"><div class="bk-v" id="bUsers">—</div><div class="bk-l">AI Users</div></div>
        <div class="bdiv"></div>
        <div class="bk"><div class="bk-v" id="bAdopt">—</div><div class="bk-l">Adoption %</div></div>
        <div class="bdiv"></div>
        <div class="bk"><div class="bk-v" id="bToday">—</div><div class="bk-l">Today</div></div>
      </div>
    </div>
    <div style="display:flex;flex-direction:column;align-items:flex-end;gap:10px;">
      <div class="live-pill"><span class="ldot"></span>Live Data</div>
      <button type="button" class="btn-exp" onclick="doExport()">
        <i class="fa fa-file-csv"></i>Export
      </button>
      <div class="gspin" id="gSpin" style="display:none;"></div>
    </div>
  </div>
</div>

<%-- ══ FILTER BAR ══ --%>
<div class="fb">
  <div class="fb-hd">
    <div class="fb-lbl"><i class="fa fa-robot"></i>Filters</div>
    <div class="fb-acts">
      <button type="button" class="btn-rs" id="btnReset"><i class="fa fa-rotate"></i> Reset</button>
      <button type="button" class="btn-ap" id="btnApply"><i class="fa fa-magnifying-glass"></i> Apply</button>
    </div>
  </div>

  <div class="f-row">
    <div class="fg"><label>Stream</label>
      <select id="fStr" class="fsel"><option value="0">All Streams</option></select>
    </div>
    <div class="fg"><label>Course</label>
      <select id="fCrs" class="fsel"><option value="0">All Courses</option></select>
    </div>
    <div class="fg"><label>Section</label>
      <select id="fSec" class="fsel"><option value="0">All Sections</option></select>
    </div>
    <div class="fg"><label>Subject</label>
      <select id="fSub" class="fsel"><option value="0">All Subjects</option></select>
    </div>
    <div class="fg" style="min-width:130px;"><label>From Date</label>
      <input type="date" id="fDfr" class="fdate"/>
    </div>
    <div class="fg" style="min-width:130px;"><label>To Date</label>
      <input type="date" id="fDto" class="fdate"/>
    </div>
  </div>

  <%-- Quick date pills --%>
  <div class="qr-row">
    <button type="button" class="qr" data-days="7">Last 7 Days</button>
    <button type="button" class="qr" data-days="30">Last 30 Days</button>
    <button type="button" class="qr on" data-curmon="1">This Month</button>
    <button type="button" class="qr" data-days="90">Last 3 Months</button>
    <button type="button" class="qr" data-full="1">Full Session</button>
  </div>

  <%-- AI Type quick-filter pills --%>
  <div class="ai-type-row">
    <span style="font-size:11px;font-weight:700;color:var(--ts);align-self:center;">AI Feature:</span>
    <button type="button" class="ai-type-btn on" data-aitype="">🤖 All</button>
    <button type="button" class="ai-type-btn t-sum"  data-aitype="Summary">📄 Summary</button>
    <button type="button" class="ai-type-btn t-note" data-aitype="Notes">📝 Notes</button>
    <button type="button" class="ai-type-btn t-quiz" data-aitype="Quiz">❓ Quiz Help</button>
    <button type="button" class="ai-type-btn t-dbt"  data-aitype="Doubt">💬 Doubt</button>
  </div>

  <div class="lbar" id="lbar"></div>
  <div class="afc" id="afcWrap"></div>
</div>

<%-- ══ KPI CARDS ══ --%>
<div class="kpi-grid">
  <div class="kpi kai">
    <div class="kpi-top"><span class="klbl">Total AI Uses</span><div class="kico iai"><i class="fa fa-robot"></i></div></div>
    <div class="kval" id="kTotal">—</div><div class="ksub">All features combined</div>
  </div>
  <div class="kpi kg">
    <div class="kpi-top"><span class="klbl">Unique AI Users</span><div class="kico ig"><i class="fa fa-users"></i></div></div>
    <div class="kval" id="kUsers">—</div><div class="ksub">Students using AI</div>
  </div>
  <div class="kpi kb">
    <div class="kpi-top"><span class="klbl">Adoption Rate</span><div class="kico ib"><i class="fa fa-percent"></i></div></div>
    <div class="kval" id="kAdopt">—</div><div class="ksub">Of enrolled students</div>
  </div>
  <div class="kpi kw">
    <div class="kpi-top"><span class="klbl">Today's Uses</span><div class="kico iw"><i class="fa fa-calendar-day"></i></div></div>
    <div class="kval" id="kToday">—</div><div class="ksub">Live count today</div>
  </div>
  <div class="kpi kai">
    <div class="kpi-top"><span class="klbl">AI Summaries</span><div class="kico iai"><i class="fa fa-file-lines"></i></div></div>
    <div class="kval" id="kSum">—</div><div class="ksub">Video summaries generated</div>
  </div>
  <div class="kpi kcy">
    <div class="kpi-top"><span class="klbl">AI Notes</span><div class="kico icy"><i class="fa fa-note-sticky"></i></div></div>
    <div class="kval" id="kNote">—</div><div class="ksub">Notes generated</div>
  </div>
  <div class="kpi kt">
    <div class="kpi-top"><span class="klbl">AI Quiz Help</span><div class="kico it"><i class="fa fa-circle-question"></i></div></div>
    <div class="kval" id="kQuiz">—</div><div class="ksub">Quiz generations</div>
  </div>
  <div class="kpi kor">
    <div class="kpi-top"><span class="klbl">AI Doubts</span><div class="kico ior"><i class="fa fa-comments"></i></div></div>
    <div class="kval" id="kDoubt">—</div><div class="ksub">Doubts asked to AI</div>
  </div>
  <div class="kpi kr">
    <div class="kpi-top"><span class="klbl">Non-AI Students</span><div class="kico ir"><i class="fa fa-user-xmark"></i></div></div>
    <div class="kval" id="kNonAI">—</div><div class="ksub">Haven't used AI yet</div>
  </div>
</div>

<%-- ══ TABS ══ --%>
<div class="tab-bar" id="tabBar">
  <button type="button" class="tab-btn on" data-tab="overview">
    <i class="fa fa-chart-pie"></i>Overview
  </button>
  <button type="button" class="tab-btn" data-tab="breakdown">
    <i class="fa fa-layer-group"></i>Breakdown
  </button>
  <button type="button" class="tab-btn" data-tab="users">
    <i class="fa fa-users"></i>Top Users
  </button>
  <button type="button" class="tab-btn" data-tab="activity">
    <i class="fa fa-bolt"></i>Activity Feed
  </button>
  <button type="button" class="tab-btn" data-tab="nonusers">
    <i class="fa fa-user-xmark"></i>Non-Users
  </button>
  <button type="button" class="tab-btn" data-tab="insights">
    <i class="fa fa-lightbulb"></i>Admin Insights
  </button>
</div>

<%-- ══ TAB: OVERVIEW ══ --%>
<div id="tab-overview" class="tab-pane on">
  <div class="g21">
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--pl);color:var(--ai);"><i class="fa fa-chart-line"></i></div>
          <div><div class="ct">Daily AI Usage Trend</div>
            <div class="cs">Video AI vs Material AI interactions per day</div></div>
        </div>
        <span id="trendTotal" style="font-size:11px;color:var(--tm);"></span>
      </div>
      <div class="cb" style="height:250px;"><canvas id="cDaily"></canvas></div>
    </div>
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--pl);color:var(--ai);"><i class="fa fa-chart-pie"></i></div>
          <div><div class="ct">AI Feature Type Breakdown</div>
            <div class="cs">Summary · Notes · Quiz · Doubt</div></div>
        </div>
      </div>
      <div class="cb" style="height:210px;"><canvas id="cType"></canvas></div>
      <div id="typeLeg" style="display:flex;flex-wrap:wrap;gap:6px;justify-content:center;margin-top:10px;"></div>
    </div>
  </div>
  <div class="g3">
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--pul,#f3f0ff);color:var(--ai);"><i class="fa fa-calendar-week"></i></div>
          <div><div class="ct">Weekly Trend</div><div class="cs">Last 8 weeks</div></div>
        </div>
      </div>
      <div class="cb" style="height:200px;"><canvas id="cWeekly"></canvas></div>
    </div>
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--tl);color:var(--t);"><i class="fa fa-clock"></i></div>
          <div><div class="ct">Hourly Usage Pattern</div><div class="cs">Peak AI usage hours</div></div>
        </div>
      </div>
      <div class="cb" style="height:200px;"><canvas id="cHourly"></canvas></div>
    </div>
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--gl);color:var(--g);"><i class="fa fa-layer-group"></i></div>
          <div><div class="ct">Stream-wise Usage</div></div>
        </div>
      </div>
      <div class="cb" style="height:200px;"><canvas id="cStream"></canvas></div>
    </div>
  </div>
</div>

<%-- ══ TAB: BREAKDOWN ══ --%>
<div id="tab-breakdown" class="tab-pane">
  <div class="g2">
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--cyl);color:var(--cy);"><i class="fa fa-graduation-cap"></i></div>
          <div><div class="ct">Course-wise AI Usage</div>
            <div class="cs">Total uses &amp; adoption rate per course</div></div>
        </div>
      </div>
      <div class="cb" style="height:250px;"><canvas id="cCourse"></canvas></div>
    </div>
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--wl);color:var(--w);"><i class="fa fa-sitemap"></i></div>
          <div><div class="ct">Section-wise AI Usage</div>
            <div class="cs">Which section uses AI most?</div></div>
        </div>
      </div>
      <div class="cb" style="height:250px;"><canvas id="cSection"></canvas></div>
    </div>
  </div>
  <div class="g2">
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--bl);color:var(--b);"><i class="fa fa-book-open"></i></div>
          <div><div class="ct">Subject-wise AI Usage</div>
            <div class="cs">Top 10 subjects by AI interactions</div></div>
        </div>
      </div>
      <div class="cb" style="height:250px;"><canvas id="cSubject"></canvas></div>
    </div>
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--rol);color:var(--ro);"><i class="fa fa-chart-bar"></i></div>
          <div><div class="ct">Adoption by Stream</div>
            <div class="cs">% of students using AI per stream</div></div>
        </div>
      </div>
      <div id="streamBars"></div>
    </div>
  </div>
</div>

<%-- ══ TAB: TOP USERS ══ --%>
<div id="tab-users" class="tab-pane">
  <div class="card">
    <div class="card-hd">
      <div class="card-hd-l">
        <div class="cico" style="background:var(--wl);color:var(--w);"><i class="fa fa-medal"></i></div>
        <div><div class="ct">Top AI Power Users</div>
          <div class="cs">Students with highest AI feature usage — ranked by total interactions</div></div>
      </div>
      <span style="font-size:11px;color:var(--tm);" id="topCount"></span>
    </div>
    <div style="overflow-x:auto;">
      <table class="atbl" id="topTable">
        <thead>
          <tr>
            <th>#</th><th>Student</th><th>Course</th><th>Section</th>
            <th>Summary</th><th>Notes</th><th>Quiz</th><th>Doubt</th>
            <th>Video AI</th><th>Material AI</th><th>Total Usage</th>
          </tr>
        </thead>
        <tbody id="topTbody">
          <tr><td colspan="11" class="empty"><div class="spin"></div></td></tr>
        </tbody>
      </table>
    </div>
  </div>
</div>

<%-- ══ TAB: ACTIVITY FEED ══ --%>
<div id="tab-activity" class="tab-pane">
  <div class="g21">
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--pl);color:var(--ai);"><i class="fa fa-bolt"></i></div>
          <div><div class="ct">Recent AI Activity</div>
            <div class="cs">Latest 20 AI interactions across all students</div></div>
        </div>
        <button type="button" class="btn-ap" style="font-size:11px;padding:5px 12px;"
                onclick="go()"><i class="fa fa-rotate"></i> Refresh</button>
      </div>
      <div id="actFeed"><div class="empty"><div class="spin"></div></div></div>
    </div>
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--gl);color:var(--g);"><i class="fa fa-chart-bar"></i></div>
          <div><div class="ct">Feature Usage Distribution</div>
            <div class="cs">Polar area chart</div></div>
        </div>
      </div>
      <div class="cb" style="height:280px;"><canvas id="cPolar"></canvas></div>
    </div>
  </div>
</div>

<%-- ══ TAB: NON-USERS ══ --%>
<div id="tab-nonusers" class="tab-pane">
  <div class="g12">
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--rl);color:var(--r);"><i class="fa fa-user-xmark"></i></div>
          <div><div class="ct">Students Not Using AI</div>
            <div class="cs">Top 15 — consider sending nudge notifications</div></div>
        </div>
        <span style="font-size:11px;color:var(--tm);" id="nuCount"></span>
      </div>
      <div id="nuList"><div class="empty"><div class="spin"></div></div></div>
    </div>
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--wl);color:var(--w);"><i class="fa fa-chart-pie"></i></div>
          <div><div class="ct">AI Adoption Overview</div>
            <div class="cs">Users vs Non-users donut</div></div>
        </div>
      </div>
      <div class="cb" style="height:220px;"><canvas id="cAdopt"></canvas></div>
      <div id="adoptLeg" style="display:flex;gap:14px;justify-content:center;margin-top:10px;flex-wrap:wrap;"></div>
      <div style="margin-top:16px;" id="nuCourseBars"></div>
    </div>
  </div>
</div>

<%-- ══ TAB: ADMIN INSIGHTS ══ --%>
<div id="tab-insights" class="tab-pane">
  <div id="suggBox"></div>

  <%-- Static guide --%>
  <div class="card">
    <div class="card-hd">
      <div class="card-hd-l">
        <div class="cico" style="background:var(--pl);color:var(--ai);"><i class="fa fa-graduation-cap"></i></div>
        <div><div class="ct">Admin AI Visualisation Guide</div>
          <div class="cs">How to analyse and act on this dashboard</div></div>
      </div>
    </div>
    <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(230px,1fr));gap:14px;">
      <div style="background:var(--pl);border-radius:var(--rads);padding:14px;">
        <div style="font-weight:700;color:var(--ai);margin-bottom:6px;">📈 Trend Analysis</div>
        <p style="font-size:12px;line-height:1.7;">Watch the <strong>Daily Trend</strong> chart — a spike means students face difficulty (exam prep). A plateau means disengagement. Compare Video AI vs Material AI to see which content type students struggle with more.</p>
      </div>
      <div style="background:var(--gl);border-radius:var(--rads);padding:14px;">
        <div style="font-weight:700;color:#065f46;margin-bottom:6px;">🎯 Adoption Strategy</div>
        <p style="font-size:12px;line-height:1.7;">Low adoption rate (&lt;30%) = students are unaware of AI features. Send announcements. Filter by section to find which classes are lagging. Focus teacher training on those sections.</p>
      </div>
      <div style="background:var(--wl);border-radius:var(--rads);padding:14px;">
        <div style="font-weight:700;color:#92400e;margin-bottom:6px;">🔍 Feature Insights</div>
        <p style="font-size:12px;line-height:1.7;">High <strong>Doubt</strong> usage on a subject = content is unclear. High <strong>Summary</strong> = students want quick revision. High <strong>Quiz</strong> = good self-assessment behaviour. Use this to advise teachers.</p>
      </div>
      <div style="background:var(--cyl);border-radius:var(--rads);padding:14px;">
        <div style="font-weight:700;color:#0e7490;margin-bottom:6px;">⏰ Peak Hours</div>
        <p style="font-size:12px;line-height:1.7;">Check the <strong>Hourly Pattern</strong> — if students use AI at 11pm-1am, they're studying late. Consider scheduling live classes or doubt sessions at those peak hours to support engagement.</p>
      </div>
      <div style="background:var(--rol);border-radius:var(--rads);padding:14px;">
        <div style="font-weight:700;color:var(--ro);margin-bottom:6px;">⚠️ Non-Users Action</div>
        <p style="font-size:12px;line-height:1.7;">Students in the <strong>Non-Users tab</strong> have never interacted with AI features. Cross-reference with low quiz scores — these students are both academically at risk AND missing support tools.</p>
      </div>
      <div style="background:var(--tl);border-radius:var(--rads);padding:14px;">
        <div style="font-weight:700;color:var(--t);margin-bottom:6px;">📚 Subject-wise Action</div>
        <p style="font-size:12px;line-height:1.7;">Filter by <strong>Subject</strong> to see which topic generates most AI queries. Subjects with highest Doubt usage should have their videos reviewed for clarity or additional material added by the teacher.</p>
      </div>
    </div>
  </div>
</div>

</div><%-- /wrap --%>

<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.4.1/chart.umd.min.js"></script>
<script>
/* ═══════════════════════════════════════════════════════════════
   AI INSIGHTS DASHBOARD
   ─ All buttons type="button" → zero postbacks
   ─ All data via fetch(AJAX) → no page reload
   ─ Tabs via JS class toggle only
   ─ Dropdowns populated from cloned ASP options
═══════════════════════════════════════════════════════════════ */
(function(){
'use strict';

/* ── Server values ── */
function hv(id){ var e=document.getElementById(id); return e?(e.value||''):''; }
var INST      = hv('<%= hdnInst.ClientID %>');
var SESS      = hv('<%= hdnSess.ClientID %>');
var SESS_NAME = (document.getElementById('<%= lblSess.ClientID %>')||{}).innerText||'';
var DEF_FR    = hv('<%= hdnDfr.ClientID %>');
var DEF_TO    = hv('<%= hdnDto.ClientID %>');

document.getElementById('bSess').innerText = SESS_NAME;

/* ── Palette ── */
var PAL=['#7c3aed','#10b981','#f59e0b','#ef4444','#3b82f6',
         '#0d9488','#f43f5e','#0891b2','#ea580c','#84cc16'];
var ATYPE_COL={ Summary:'#7c3aed', Notes:'#0891b2', Quiz:'#10b981', Doubt:'#f59e0b' };
var GRD ={color:'rgba(148,163,184,.12)'};
var TICK={font:{size:11,family:"'Inter','Segoe UI',sans-serif"}};
var TT  ={padding:10,cornerRadius:8,bodyFont:{size:12},titleFont:{size:12,weight:'bold'}};
var ANIM={duration:950,easing:'easeInOutQuart'};
function palA(a){return PAL.map(function(c){return c+Math.round(a*255).toString(16).padStart(2,'0');});}

var charts={}, debT=null, lastData=null, curAIType='';

/* ── Particles ── */
(function(){
  var c=document.getElementById('bPart');
  for(var i=0;i<12;i++){
    var d=document.createElement('div'), sz=Math.random()*40+10;
    d.className='bp';
    d.style.cssText='width:'+sz+'px;height:'+sz+'px;left:'+Math.random()*100+'%;'
      +'bottom:-'+sz+'px;animation-duration:'+(Math.random()*6+4)+'s;'
      +'animation-delay:'+(Math.random()*4)+'s;';
    c.appendChild(d);
  }
})();

/* ════════════════════════════════════════════════════════
   CLONE ASP DROPDOWNS → JS selects
════════════════════════════════════════════════════════ */
var DDL_MAP={
  '<%= aspStream.ClientID %>' :'fStr',
  '<%= aspCourse.ClientID %>' :'fCrs',
  '<%= aspSection.ClientID %>':'fSec',
  '<%= aspSubject.ClientID %>':'fSub'
};
Object.keys(DDL_MAP).forEach(function(aspId){
  var asp=document.getElementById(aspId);
  var js =document.getElementById(DDL_MAP[aspId]);
  if(!asp||!js) return;
  Array.prototype.forEach.call(asp.options,function(o){
    if(!o.value||o.value==='0') return;
    if(js.querySelector('option[value="'+o.value+'"]')) return;
    var n=document.createElement('option');
    n.value=o.value; n.text=o.text; js.appendChild(n);
  });
});

/* ════════════════════════════════════════════════════════
   SET DEFAULT DATES
════════════════════════════════════════════════════════ */
document.getElementById('fDfr').value=DEF_FR;
document.getElementById('fDto').value=DEF_TO;

/* ════════════════════════════════════════════════════════
   WIRE BUTTONS (all type=button → no postback)
════════════════════════════════════════════════════════ */
function G(id){return document.getElementById(id);}

G('btnApply').addEventListener('click',function(e){e.preventDefault();go();});
G('btnReset').addEventListener('click',function(e){e.preventDefault();resetF();});

/* Dropdowns */
G('fStr').addEventListener('change',function(){cascadeCourses(this.value);go();});
['fCrs','fSec','fSub'].forEach(function(id){
  G(id).addEventListener('change',function(){go();});
});

/* Date inputs */
G('fDfr').addEventListener('change',function(){clearPills();go();});
G('fDto').addEventListener('change',function(){clearPills();go();});

/* Quick-range pills */
document.querySelectorAll('.qr').forEach(function(btn){
  btn.addEventListener('click',function(e){
    e.preventDefault();
    clearPills(); this.classList.add('on');
    var days=this.dataset.days, cm=this.dataset.curmon, full=this.dataset.full;
    var to=new Date(), fr=new Date();
    if(full){ G('fDfr').value=''; G('fDto').value=''; }
    else if(cm){
      G('fDfr').value=fmt(new Date(to.getFullYear(),to.getMonth(),1));
      G('fDto').value=fmt(to);
    } else {
      fr.setDate(to.getDate()-parseInt(days)+1);
      G('fDfr').value=fmt(fr); G('fDto').value=fmt(to);
    }
    go();
  });
});

/* AI Type pills */
document.querySelectorAll('.ai-type-btn').forEach(function(btn){
  btn.addEventListener('click',function(e){
    e.preventDefault();
    document.querySelectorAll('.ai-type-btn').forEach(function(b){b.classList.remove('on');});
    this.classList.add('on');
    curAIType=this.dataset.aitype||'';
    go();
  });
});

/* Tab bar */
G('tabBar').addEventListener('click',function(e){
  var btn=e.target.closest('.tab-btn'); if(!btn) return;
  e.preventDefault(); e.stopPropagation();
  var name=btn.dataset.tab; if(!name) return;
  document.querySelectorAll('.tab-btn').forEach(function(b){b.classList.remove('on');});
  document.querySelectorAll('.tab-pane').forEach(function(p){p.classList.remove('on');});
  btn.classList.add('on');
  var pane=G('tab-'+name); if(pane) pane.classList.add('on');
});

function clearPills(){
  document.querySelectorAll('.qr').forEach(function(b){b.classList.remove('on');});
}
function fmt(d){return d.toISOString().split('T')[0];}

/* ════════════════════════════════════════════════════════
   FILTER HELPERS
════════════════════════════════════════════════════════ */
function getF(){
  return{
    stream:  G('fStr').value||'0',
    course:  G('fCrs').value||'0',
    section: G('fSec').value||'0',
    subject: G('fSub').value||'0',
    aitype:  curAIType,
    datefrom:G('fDfr').value||'',
    dateto:  G('fDto').value||''
  };
}

function buildURL(extra){
  var f=getF();
  var u=location.pathname
    +'?ajax=1&inst='+encodeURIComponent(INST)+'&sess='+encodeURIComponent(SESS)
    +'&stream='+f.stream+'&course='+f.course+'&section='+f.section
    +'&subject='+f.subject+'&aitype='+encodeURIComponent(f.aitype)
    +'&datefrom='+f.datefrom+'&dateto='+f.dateto;
  if(extra) Object.keys(extra).forEach(function(k){u+='&'+k+'='+encodeURIComponent(extra[k]);});
  return u;
}

function resetF(){
  ['fStr','fCrs','fSec','fSub'].forEach(function(id){G(id).value='0';});
  curAIType='';
  G('fDfr').value=DEF_FR; G('fDto').value=DEF_TO;
  G('afcWrap').innerHTML='';
  clearPills();
  document.querySelectorAll('.qr[data-curmon]').forEach(function(b){b.classList.add('on');});
  document.querySelectorAll('.ai-type-btn').forEach(function(b){b.classList.remove('on');});
  document.querySelector('.ai-type-btn[data-aitype=""]').classList.add('on');
  go();
}

function updateChips(){
  var names={Stream:'fStr',Course:'fCrs',Section:'fSec',Subject:'fSub'};
  var wrap=G('afcWrap'); wrap.innerHTML='';
  Object.keys(names).forEach(function(label){
    var el=G(names[label]); var v=el.value;
    if(!v||v==='0') return;
    var tx=el.options[el.selectedIndex]?el.options[el.selectedIndex].text:v;
    var chip=document.createElement('span'); chip.className='afc-chip';
    chip.innerHTML=esc(tx)+' <i class="fa fa-xmark" style="font-size:10px;opacity:.7;"></i>';
    (function(fid){chip.addEventListener('click',function(){G(fid).value='0';go();});})(names[label]);
    wrap.appendChild(chip);
  });
  if(curAIType){
    var c2=document.createElement('span'); c2.className='afc-chip';
    c2.innerText='AI: '+curAIType;
    wrap.appendChild(c2);
  }
  var f=getF();
  if(f.datefrom||f.dateto){
    var c3=document.createElement('span'); c3.className='afc-chip';
    c3.innerText=(f.datefrom||'Start')+' → '+(f.dateto||'Now');
    wrap.appendChild(c3);
  }
}

/* Cascade courses */
function cascadeCourses(streamId){
  fetch(buildURL({action:'courses',stream:streamId}))
    .then(function(r){return r.json();})
    .then(function(d){
      var sel=G('fCrs');
      sel.innerHTML='<option value="0">All Courses</option>';
      (d.courses||[]).forEach(function(c){
        var o=document.createElement('option');
        o.value=c.CourseId; o.text=c.CourseDisplay; sel.appendChild(o);
      });
    }).catch(function(){});
}

/* ════════════════════════════════════════════════════════
   MAIN FETCH
════════════════════════════════════════════════════════ */
function go(){
  clearTimeout(debT);
  debT=setTimeout(fetchData,280);
}
window.go=go;

function fetchData(){
  setLoad(true); updateChips();
  fetch(buildURL())
    .then(function(r){if(!r.ok)throw new Error('HTTP '+r.status);return r.json();})
    .then(function(d){
      lastData=d;
      renderKPIs(d.kpi);
      renderAllCharts(d);
      renderTopUsers(d.topUsers);
      renderActivity(d.activity);
      renderNonUsers(d.nonUsers, d.kpi);
      renderSuggestions(d.kpi, d.topUsers, d.nonUsers);
      setLoad(false);
    })
    .catch(function(err){setLoad(false);console.error('[AI Dashboard]',err);});
}

function setLoad(on){
  var bar=G('lbar'), sp=G('gSpin');
  bar.style.width=on?'82%':'100%';
  sp.style.display=on?'inline-block':'none';
  if(!on) setTimeout(function(){bar.style.width='0%';},600);
}

/* ════════════════════════════════════════════════════════
   KPI RENDER
════════════════════════════════════════════════════════ */
function renderKPIs(k){
  if(!k) return;
  var total=parseInt(k.totalInteractions)||0;
  var users=parseInt(k.uniqueUsers)||0;
  var enrolled=parseInt(k.totalEnrolled)||0;
  var nonAI=enrolled-users;

  cu('kTotal', total);
  cu('kUsers', users);
  cu('kToday', k.todayInteractions);
  cu('kSum',   (parseInt(k.videoSummary)||0));
  cu('kNote',  (parseInt(k.videoNotes)||0)+(parseInt(k.materialNotes)||0));
  cu('kQuiz',  (parseInt(k.videoQuiz)||0)+(parseInt(k.materialQuiz)||0));
  cu('kDoubt', (parseInt(k.videoDoubt)||0)+(parseInt(k.materialDoubt)||0));
  cu('kNonAI', nonAI<0?0:nonAI);
  G('kAdopt').innerText=(parseFloat(k.adoptionRate)||0)+'%';

  // Banner
  G('bTotal').innerText=total;
  G('bUsers').innerText=users;
  G('bAdopt').innerText=(parseFloat(k.adoptionRate)||0)+'%';
  G('bToday').innerText=parseInt(k.todayInteractions)||0;
}

function cu(id,n){
  var el=G(id); if(!el) return;
  var t=parseInt(n)||0, s=parseInt(el.innerText)||0, diff=t-s, steps=28, i=0;
  var iv=setInterval(function(){
    i++; el.innerText=Math.round(s+diff*(i/steps));
    if(i>=steps){el.innerText=t;clearInterval(iv);}
  },16);
}

/* ════════════════════════════════════════════════════════
   CHART HELPERS
════════════════════════════════════════════════════════ */
function dc(k){if(charts[k]){charts[k].destroy();charts[k]=null;}}
function gV(ctx,h,c1,c2){var g=ctx.createLinearGradient(0,0,0,h);g.addColorStop(0,c1);g.addColorStop(1,c2);return g;}
function noData(id,msg){
  var el=G(id); if(!el) return;
  var box=el.closest('.cb');
  if(box) box.innerHTML='<div class="empty"><i class="fa fa-robot"></i><p>'+(msg||'No data')+'</p></div>';
}

/* ════════════════════════════════════════════════════════
   ALL CHARTS
════════════════════════════════════════════════════════ */
function renderAllCharts(d){
  renderDaily(d.dailyTrend);
  renderType(d.typeBreak);
  renderWeekly(d.weeklyTrend);
  renderHourly(d.hourly);
  renderStream(d.streamUsage);
  renderCourse(d.courseUsage);
  renderSection(d.sectionUsage);
  renderSubject(d.subjectUsage);
  renderPolar(d.typeBreak);
  renderAdoptDonut(d.kpi);
  renderStreamBars(d.streamUsage);
  renderCourseBarsNu(d.courseUsage);
}

/* 1. Daily trend */
function renderDaily(data){
  dc('daily');
  if(!data||!data.length){noData('cDaily','No daily data');return;}
  var ctx=G('cDaily'); if(!ctx) return;
  var c=ctx.getContext('2d');
  var g1=gV(c,230,'rgba(124,58,237,.28)','rgba(124,58,237,.01)');
  var g2=gV(c,230,'rgba(59,130,246,.18)','rgba(59,130,246,.01)');
  var total=data.reduce(function(a,r){return a+(parseInt(r.Total)||0);},0);
  G('trendTotal').innerText=total+' total interactions';
  charts.daily=new Chart(ctx,{type:'line',data:{
    labels:data.map(function(r){return r.DateStr;}),
    datasets:[
      {label:'Video AI',data:data.map(function(r){return r.VideoAI||0;}),
       borderColor:'#7c3aed',backgroundColor:g1,borderWidth:2.5,tension:.42,fill:true,
       pointRadius:0,pointHoverRadius:7,pointHoverBackgroundColor:'#7c3aed'},
      {label:'Material AI',data:data.map(function(r){return r.MaterialAI||0;}),
       borderColor:'#3b82f6',backgroundColor:g2,borderWidth:2,tension:.42,fill:true,
       pointRadius:0,pointHoverRadius:7,pointHoverBackgroundColor:'#3b82f6'},
      {label:'Unique Users',data:data.map(function(r){return r.UniqueUsers||0;}),
       borderColor:'#10b981',borderWidth:2,borderDash:[5,4],tension:.4,fill:false,
       pointRadius:0,pointHoverRadius:6}
    ]
  },options:{responsive:true,maintainAspectRatio:false,
    interaction:{mode:'index',intersect:false},
    plugins:{legend:{position:'top',labels:{boxWidth:10,font:{size:11}}},tooltip:TT},
    scales:{x:{grid:{display:false},ticks:{font:{size:10},maxTicksLimit:12}},y:{beginAtZero:true,grid:GRD,ticks:TICK}},
    animation:ANIM}});
}

/* 2. Type donut */
function renderType(data){
  dc('type');
  var leg=G('typeLeg'); if(leg) leg.innerHTML='';
  if(!data||!data.length){noData('cType','No type data');return;}
  var el=G('cType'); if(!el) return;
  var TCOL=['#7c3aed','#0891b2','#10b981','#f59e0b','#ef4444','#94a3b8'];
  charts.type=new Chart(el,{type:'doughnut',data:{
    labels:data.map(function(r){return r.AIType;}),
    datasets:[{data:data.map(function(r){return r.Total||0;}),
      backgroundColor:TCOL,borderWidth:2,borderColor:'#fff',hoverOffset:10}]
  },options:{cutout:'58%',responsive:true,maintainAspectRatio:false,
    plugins:{legend:{display:false},tooltip:TT},
    animation:{animateRotate:true,duration:1100}}});
  if(leg){
    var tot=data.reduce(function(a,r){return a+(r.Total||0);},0)||1;
    data.forEach(function(r,i){
      leg.innerHTML+='<div style="display:flex;align-items:center;gap:5px;font-size:11px;">'
        +'<span style="width:10px;height:10px;border-radius:2px;background:'+TCOL[i]+';display:inline-block;flex-shrink:0;"></span>'
        +esc(r.AIType||'?')+' <strong style="color:'+TCOL[i]+';">'+(r.Total||0)+'</strong></div>';
    });
  }
}

/* 3. Weekly */
function renderWeekly(data){
  dc('weekly');
  if(!data||!data.length){noData('cWeekly','No weekly data');return;}
  var el=G('cWeekly'); if(!el) return;
  charts.weekly=new Chart(el,{type:'bar',data:{
    labels:data.map(function(r){return r.WLabel;}),
    datasets:[
      {label:'Total Uses',data:data.map(function(r){return r.Total||0;}),
       backgroundColor:'rgba(124,58,237,.82)',borderRadius:5},
      {label:'Unique Users',data:data.map(function(r){return r.UniqueUsers||0;}),
       backgroundColor:'rgba(16,185,129,.72)',borderRadius:5}
    ]
  },options:{responsive:true,maintainAspectRatio:false,
    plugins:{legend:{position:'top',labels:{boxWidth:10,font:{size:11}}},tooltip:TT},
    scales:{x:{grid:{display:false},ticks:TICK},y:{beginAtZero:true,grid:GRD,ticks:TICK}},
    animation:ANIM}});
}

/* 4. Hourly */
function renderHourly(data){
  dc('hourly');
  if(!data||!data.length){noData('cHourly','No hourly data');return;}
  var el=G('cHourly'); if(!el) return;
  // Build 24-hour labels array
  var hrs=[], vals=[];
  for(var h=0;h<24;h++){hrs.push(h+':00');vals.push(0);}
  data.forEach(function(r){
    var hr=parseInt(r.Hr)||0; if(hr>=0&&hr<24) vals[hr]=parseInt(r.Total)||0;
  });
  var maxV=Math.max.apply(null,vals)||1;
  charts.hourly=new Chart(el,{type:'bar',data:{
    labels:hrs,
    datasets:[{label:'AI Uses',data:vals,
      backgroundColor:vals.map(function(v){
        var a=Math.max(.25,v/maxV);
        return 'rgba(124,58,237,'+a.toFixed(2)+')';
      }),borderRadius:3}]
  },options:{responsive:true,maintainAspectRatio:false,
    plugins:{legend:{display:false},tooltip:TT},
    scales:{x:{grid:{display:false},ticks:{font:{size:9},maxTicksLimit:12}},y:{beginAtZero:true,grid:GRD,ticks:TICK}},
    animation:ANIM}});
}

/* 5. Stream bar */
function renderStream(data){
  dc('stream');
  if(!data||!data.length){noData('cStream','No stream data');return;}
  var el=G('cStream'); if(!el) return;
  charts.stream=new Chart(el,{type:'bar',data:{
    labels:data.map(function(r){return r.StreamName;}),
    datasets:[
      {label:'AI Uses',data:data.map(function(r){return r.TotalUses||0;}),backgroundColor:palA(.82),borderRadius:5},
      {label:'Adoption %',data:data.map(function(r){return r.AdoptionRate||0;}),
       backgroundColor:palA(.45),borderRadius:5,yAxisID:'y1'}
    ]
  },options:{responsive:true,maintainAspectRatio:false,
    plugins:{legend:{position:'top',labels:{boxWidth:10,font:{size:11}}},tooltip:TT},
    scales:{x:{grid:{display:false},ticks:TICK},
      y:{beginAtZero:true,grid:GRD,ticks:TICK},
      y1:{position:'right',beginAtZero:true,max:100,grid:{display:false},
          ticks:{font:{size:11},callback:function(v){return v+'%';}}}},
    animation:ANIM}});
}

/* 6. Course */
function renderCourse(data){
  dc('course');
  if(!data||!data.length){noData('cCourse','No course data');return;}
  var el=G('cCourse'); if(!el) return;
  var short=data.map(function(r){var n=r.CourseName||'';return n.length>14?n.substring(0,13)+'…':n;});
  charts.course=new Chart(el,{type:'bar',data:{
    labels:short,
    datasets:[
      {label:'AI Uses',data:data.map(function(r){return r.TotalUses||0;}),
       backgroundColor:palA(.82),borderRadius:5,borderSkipped:false}
    ]
  },options:{indexAxis:'y',responsive:true,maintainAspectRatio:false,
    plugins:{legend:{display:false},tooltip:TT},
    scales:{x:{beginAtZero:true,grid:GRD,ticks:TICK},y:{grid:{display:false},ticks:{font:{size:11}}}},
    animation:ANIM}});
}

/* 7. Section */
function renderSection(data){
  dc('section');
  if(!data||!data.length){noData('cSection','No section data');return;}
  var el=G('cSection'); if(!el) return;
  charts.section=new Chart(el,{type:'doughnut',data:{
    labels:data.map(function(r){return r.SectionName;}),
    datasets:[{data:data.map(function(r){return r.TotalUses||0;}),
      backgroundColor:palA(.85),borderWidth:2,borderColor:'#fff',hoverOffset:8}]
  },options:{cutout:'55%',responsive:true,maintainAspectRatio:false,
    plugins:{legend:{position:'right',labels:{boxWidth:10,font:{size:11}}},tooltip:TT},
    animation:{animateRotate:true,duration:1100}}});
}

/* 8. Subject */
function renderSubject(data){
  dc('subject');
  if(!data||!data.length){noData('cSubject','No subject data');return;}
  var el=G('cSubject'); if(!el) return;
  var short=data.map(function(r){var n=r.SubjectName||'';return n.length>14?n.substring(0,13)+'…':n;});
  charts.subject=new Chart(el,{type:'bar',data:{
    labels:short,
    datasets:[
      {label:'Video AI',data:data.map(function(r){return r.VideoAIUses||0;}),
       backgroundColor:'rgba(124,58,237,.82)',borderRadius:4,stack:'s'},
      {label:'Material AI',data:data.map(function(r){return r.MaterialAIUses||0;}),
       backgroundColor:'rgba(59,130,246,.75)',borderRadius:4,stack:'s'}
    ]
  },options:{responsive:true,maintainAspectRatio:false,
    interaction:{mode:'index',intersect:false},
    plugins:{legend:{position:'top',labels:{boxWidth:10,font:{size:11}}},tooltip:TT},
    scales:{x:{grid:{display:false},ticks:{font:{size:10}},stacked:true},
            y:{grid:GRD,ticks:TICK,stacked:true}},
    animation:ANIM}});
}

/* 9. Polar — feature distribution */
function renderPolar(data){
  dc('polar');
  if(!data||!data.length){noData('cPolar','No data');return;}
  var el=G('cPolar'); if(!el) return;
  charts.polar=new Chart(el,{type:'polarArea',data:{
    labels:data.map(function(r){return r.AIType;}),
    datasets:[{data:data.map(function(r){return r.Total||0;}),
      backgroundColor:['rgba(124,58,237,.7)','rgba(8,145,178,.7)','rgba(16,185,129,.7)','rgba(245,158,11,.7)'],
      borderColor:'#fff',borderWidth:2}]
  },options:{responsive:true,maintainAspectRatio:false,
    plugins:{legend:{position:'right',labels:{boxWidth:10,font:{size:11}}},tooltip:TT},
    scales:{r:{beginAtZero:true,ticks:{font:{size:9}},grid:{color:'rgba(148,163,184,.2)'}}},
    animation:{duration:1100,easing:'easeInOutBack'}}});
}

/* 10. Adoption donut */
function renderAdoptDonut(k){
  dc('adopt');
  var leg=G('adoptLeg'); if(leg) leg.innerHTML='';
  if(!k) return;
  var el=G('cAdopt'); if(!el) return;
  var users=parseInt(k.uniqueUsers)||0;
  var enrolled=parseInt(k.totalEnrolled)||0;
  var nonAI=Math.max(0,enrolled-users);
  charts.adopt=new Chart(el,{type:'doughnut',data:{
    labels:['AI Users','Not Using AI'],
    datasets:[{data:[users,nonAI],
      backgroundColor:['#7c3aed','#e2e8f0'],borderWidth:3,borderColor:'#fff',hoverOffset:8}]
  },options:{cutout:'65%',responsive:true,maintainAspectRatio:false,
    plugins:{legend:{display:false},tooltip:TT},
    animation:{animateRotate:true,duration:1100}}});
  if(leg){
    var tot=enrolled||1;
    leg.innerHTML='<div style="display:flex;align-items:center;gap:6px;font-size:12px;">'
      +'<span style="width:12px;height:12px;border-radius:2px;background:#7c3aed;display:inline-block;"></span>'
      +'AI Users <strong style="color:#7c3aed;">'+users+' ('+Math.round(users/tot*100)+'%)</strong></div>'
      +'<div style="display:flex;align-items:center;gap:6px;font-size:12px;">'
      +'<span style="width:12px;height:12px;border-radius:2px;background:#e2e8f0;display:inline-block;"></span>'
      +'Not Using <strong style="color:var(--ts);">'+nonAI+' ('+Math.round(nonAI/tot*100)+'%)</strong></div>';
  }
}

/* 11. Stream adoption bars */
function renderStreamBars(data){
  var wrap=G('streamBars'); if(!wrap) return;
  wrap.innerHTML='';
  if(!data||!data.length){wrap.innerHTML='<div class="empty"><i class="fa fa-layer-group"></i><p>No data</p></div>';return;}
  data.forEach(function(r,i){
    var pct=parseFloat(r.AdoptionRate)||0;
    var col=pct>=70?'var(--g)':pct>=40?'var(--ai)':'var(--r)';
    wrap.innerHTML+='<div class="pi">'
      +'<div class="pi-lbl"><span>'+esc(r.StreamName)+'</span>'
      +'<span>'+r.AIUsers+'/'+r.TotalStudents+' ('+pct+'%)</span></div>'
      +'<div class="pi-track"><div class="pi-fill" data-w="'+pct+'%" style="background:'+col+';"></div></div></div>';
  });
  setTimeout(function(){
    wrap.querySelectorAll('.pi-fill[data-w]').forEach(function(el){el.style.width=el.dataset.w;});
  },300);
}

/* 12. Course bars for non-users tab */
function renderCourseBarsNu(data){
  var wrap=G('nuCourseBars'); if(!wrap) return;
  wrap.innerHTML='';
  if(!data||!data.length) return;
  wrap.innerHTML='<div style="font-size:12px;font-weight:700;color:var(--ts);margin-bottom:8px;text-transform:uppercase;letter-spacing:.05em;">Adoption by Course</div>';
  var maxU=Math.max.apply(null,data.map(function(r){return r.TotalUses||0;}))||1;
  data.slice(0,6).forEach(function(r,i){
    var pct=Math.round((r.TotalUses||0)/maxU*100);
    wrap.innerHTML+='<div class="pi">'
      +'<div class="pi-lbl"><span style="font-size:12px;">'+esc(r.CourseName)+'</span>'
      +'<span>'+esc(r.AdoptionRate||'0')+'% adopted</span></div>'
      +'<div class="pi-track"><div class="pi-fill" data-w="'+pct+'%" style="background:'+PAL[i%PAL.length]+';"></div></div></div>';
  });
  setTimeout(function(){
    wrap.querySelectorAll('.pi-fill[data-w]').forEach(function(el){el.style.width=el.dataset.w;});
  },400);
}

/* ════════════════════════════════════════════════════════
   TOP AI USERS TABLE
════════════════════════════════════════════════════════ */
function renderTopUsers(data){
  var tbody=G('topTbody'); if(!tbody) return;
  var cnt=G('topCount'); if(cnt) cnt.innerText=(data?data.length:0)+' students';

  if(!data||!data.length){
    tbody.innerHTML='<tr><td colspan="11"><div class="empty"><i class="fa fa-users"></i><p>No AI usage data for this filter</p></div></td></tr>';
    return;
  }

  var maxU=Math.max.apply(null,data.map(function(r){return parseInt(r.TotalUses)||0;}))||1;
  var html='';
  data.forEach(function(r,i){
    var total=parseInt(r.TotalUses)||0;
    var init=(r.FullName||'?').substring(0,1).toUpperCase();
    var img=r.ProfileImage?'<img src="'+esc(r.ProfileImage)+'" alt=""/>':init;
    var rank=i<3?'r'+(i+1):'rn';
    var pct=Math.round(total/maxU*100);
    html+='<tr>'
      +'<td><div class="rk '+rank+'">'+(i+1)+'</div></td>'
      +'<td>'
        +'<div style="display:flex;align-items:center;gap:8px;">'
          +'<div class="av">'+img+'</div>'
          +'<div><div class="uname">'+esc(r.FullName||'')+'</div>'
          +'<div class="uroll">'+esc(r.RollNumber||'—')+'</div></div>'
        +'</div>'
      +'</td>'
      +'<td style="font-size:12px;">'+esc(r.CourseName||'—')+'</td>'
      +'<td style="font-size:12px;">'+esc(r.SectionName||'—')+'</td>'
      +'<td><span class="ai-chip ac-sum">'+esc(r.SummaryCnt||0)+'</span></td>'
      +'<td><span class="ai-chip ac-note">'+esc(r.NotesCnt||0)+'</span></td>'
      +'<td><span class="ai-chip ac-quiz">'+esc(r.QuizCnt||0)+'</span></td>'
      +'<td><span class="ai-chip ac-dbt">'+esc(r.DoubtCnt||0)+'</span></td>'
      +'<td style="font-weight:600;color:var(--ai);">'+esc(r.VideoAIUses||0)+'</td>'
      +'<td style="font-weight:600;color:var(--b);">'+esc(r.MaterialAIUses||0)+'</td>'
      +'<td>'
        +'<div class="ubar-wrap">'
          +'<div class="ubar-bg"><div class="ubar-fg" data-w="'+pct+'%"></div></div>'
          +'<div class="ubar-n">'+total+'</div>'
        +'</div>'
      +'</td>'
    +'</tr>';
  });
  tbody.innerHTML=html;
  setTimeout(function(){
    tbody.querySelectorAll('.ubar-fg[data-w]').forEach(function(el){el.style.width=el.dataset.w;});
  },300);
}

/* ════════════════════════════════════════════════════════
   ACTIVITY FEED
════════════════════════════════════════════════════════ */
function renderActivity(data){
  var wrap=G('actFeed'); if(!wrap) return;
  if(!data||!data.length){
    wrap.innerHTML='<div class="empty"><i class="fa fa-bolt"></i><p>No recent AI activity in this period</p></div>';
    return;
  }

  var typeIco={Summary:'fa-file-lines',Notes:'fa-note-sticky',Quiz:'fa-circle-question',Doubt:'fa-comments'};
  var typeCls={Summary:'aic-sum',Notes:'aic-note',Quiz:'aic-quiz',Doubt:'aic-dbt'};
  var typePillCls={Summary:'ac-sum',Notes:'ac-note',Quiz:'ac-quiz',Doubt:'ac-dbt'};
  var srcCls={Video:'aic-mat',Material:'aic-mat'};

  var html='';
  data.forEach(function(r){
    var ico=typeIco[r.AIType]||'fa-robot';
    var cls=typeCls[r.AIType]||'aic-def';
    var pcls=typePillCls[r.AIType]||'ac-tot';
    var init=(r.FullName||'?').substring(0,1).toUpperCase();
    var img=r.ProfileImage?'<img src="'+esc(r.ProfileImage)+'" alt=""/>':init;
    var q=(r.Question||'').substring(0,100)+(r.Question&&r.Question.length>100?'…':'');
    var t=r.UsedOn?new Date(r.UsedOn).toLocaleString('en-IN',{day:'2-digit',month:'short',hour:'2-digit',minute:'2-digit'}):'-';
    html+='<div class="act-item">'
      +'<div class="act-ico '+cls+'"><i class="fa '+ico+'"></i></div>'
      +'<div style="flex:1;min-width:0;">'
        +'<div class="act-name">'+esc(r.FullName||'')+'</div>'
        +(q?'<div class="act-q">'+esc(q)+'</div>':'')
        +'<div class="act-meta">'
          +'<span class="act-pill '+pcls+'">'+esc(r.AIType||'—')+'</span>'
          +'<span class="act-pill" style="background:var(--orl);color:var(--or);">'+esc(r.Source||'')+'</span>'
          +(r.CourseName?'<span class="act-pill" style="background:var(--pg);color:var(--ts);">'+esc(r.CourseName)+'</span>':'')
        +'</div>'
      +'</div>'
      +'<div class="act-time">'+t+'</div>'
    +'</div>';
  });
  wrap.innerHTML=html;
}

/* ════════════════════════════════════════════════════════
   NON-USERS LIST
════════════════════════════════════════════════════════ */
function renderNonUsers(data, kpi){
  var wrap=G('nuList'); if(!wrap) return;
  var cnt=G('nuCount');

  if(!data||!data.length){
    wrap.innerHTML='<div class="empty" style="padding:50px;">'
      +'<i class="fa fa-circle-check" style="color:var(--g);opacity:1;font-size:36px;"></i>'
      +'<p style="color:var(--g);font-weight:700;margin-top:8px;">All students have used AI features!</p></div>';
    if(cnt) cnt.innerText='0 students';
    return;
  }
  if(cnt) cnt.innerText=data.length+' students (showing top 15)';

  var html='';
  data.forEach(function(r,i){
    var init=(r.FullName||'?').substring(0,1).toUpperCase();
    var img=r.ProfileImage?'<img src="'+esc(r.ProfileImage)+'" alt=""/>':init;
    html+='<div class="nu-item">'
      +'<div class="rk '+(i<3?'r'+(i+1):'rn')+'">'+(i+1)+'</div>'
      +'<div class="av" style="background:var(--rl);color:var(--r);">'+img+'</div>'
      +'<div><div class="nu-name">'+esc(r.FullName||'')+'</div>'
        +'<div class="nu-meta">'+esc(r.CourseName||'—')+' &bull; '+esc(r.SectionName||'—')
          +' &bull; Roll: '+esc(r.RollNumber||'—')+'</div>'
      +'</div>'
      +'<div style="margin-left:auto;font-size:11px;color:var(--r);font-weight:700;">No AI Use</div>'
    +'</div>';
  });
  wrap.innerHTML=html;
}

/* ════════════════════════════════════════════════════════
   SUGGESTIONS
════════════════════════════════════════════════════════ */
function renderSuggestions(kpi, topUsers, nonUsers){
  var wrap=G('suggBox'); if(!wrap||!kpi) return;
  var adopt=parseFloat(kpi.adoptionRate)||0;
  var today=parseInt(kpi.todayInteractions)||0;
  var nu=(nonUsers?nonUsers.length:0);
  var total=parseInt(kpi.totalInteractions)||0;
  var doubtPct=total>0?Math.round(((parseInt(kpi.videoDoubt)||0)+(parseInt(kpi.materialDoubt)||0))/total*100):0;

  function si(warn,ico,n,hd,txt){
    return '<div class="si '+(warn?'warn':'ok')+'">'
      +'<span class="si-ico">'+ico+'</span>'
      +'<div class="si-n">'+n+'</div>'
      +'<div class="si-hd">'+hd+'</div>'
      +'<div class="si-tx">'+txt+'</div></div>';
  }

  wrap.innerHTML='<div class="sugg-card">'
    +'<div class="sugg-title"><i class="fa fa-robot"></i>AI Intelligence Panel</div>'
    +'<div class="sugg-grid">'
    +si(adopt<30,'📊',adopt+'%','AI Adoption Rate',
       adopt<30?'Only '+adopt+'% of students are using AI tools. Send notifications to encourage usage — target non-users from the list.'
               :adopt<60?'Moderate adoption. Focus on sections below 30% to boost overall engagement.'
               :'Excellent adoption! Maintain engagement by regularly updating AI-generated content.')
    +si(today===0,'⚡',today,'Today\'s Interactions',
       today===0?'No AI usage recorded today. This may indicate students are inactive or content is stale — check schedule.'
               :today+' AI interactions so far today. Peak engagement happening!')
    +si(nu>0,'👤',nu,'Students Never Used AI',
       nu>0?nu+' students have never triggered any AI feature. Cross-reference with attendance and quiz scores — these students need outreach.'
           :'All students have used at least one AI feature. Great engagement!')
    +si(doubtPct>40,'❓',doubtPct+'%','Doubt Interactions %',
       doubtPct>40?'Over 40% of AI usage is for doubts — students are confused. Review content clarity and ask teachers to add more examples.'
                 :'Balanced AI usage. Students are using Summary, Notes, and Quiz features effectively.')
    +si(total<100,'🤖',total,'Total AI Interactions',
       total<100?'Low total interactions. Promote AI features through announcements and teacher demonstration sessions.'
               :'Strong AI engagement this period. Keep analysing which subjects drive the most usage.')
    +si(false,'🏆',topUsers?topUsers.length:0,'Top AI Users Identified',
       'These students are self-learners. Recognise them publicly to inspire peers to start using AI features.')
    +'</div></div>';
}

/* ════════════════════════════════════════════════════════
   CSV EXPORT
════════════════════════════════════════════════════════ */
function doExport(){
  if(!lastData||!lastData.topUsers||!lastData.topUsers.length){
    alert('No top-user data to export. Apply filters first.');
    return;
  }
  var H=['Name','Roll','Course','Section','Summary','Notes','Quiz','Doubt','Video AI','Material AI','Total'];
  var R=lastData.topUsers.map(function(r){
    return[r.FullName,r.RollNumber,r.CourseName,r.SectionName,
           r.SummaryCnt,r.NotesCnt,r.QuizCnt,r.DoubtCnt,
           r.VideoAIUses,r.MaterialAIUses,r.TotalUses]
      .map(function(v){return '"'+String(v||'').replace(/"/g,'""')+'"';});
  });
  var csv=[H].concat(R).map(function(r){return r.join(',');}).join('\n');
  var a=document.createElement('a');
  a.href='data:text/csv;charset=utf-8,'+encodeURIComponent(csv);
  a.download='ai_insights_'+new Date().toISOString().slice(0,10)+'.csv';
  a.click();
}
window.doExport=doExport;

/* ════════════════════════════════════════════════════════
   UTILITY
════════════════════════════════════════════════════════ */
function esc(s){
  return String(s||'')
    .replace(/&/g,'&amp;').replace(/</g,'&lt;')
    .replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

/* ════════════════════════════════════════════════════════
   INITIAL LOAD
════════════════════════════════════════════════════════ */
setTimeout(function(){go();},120);

})();
</script>
</asp:Content>
