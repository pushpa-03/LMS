<%@ Page Title="Academic Analysis Dashboard" Language="C#"
    MasterPageFile="~/Admin/AdminMaster.Master"
    AutoEventWireup="true"
    CodeBehind="AcademicAnalysisDashboard.aspx.cs"
    Inherits="LearningManagementSystem.Admin.AcademicAnalysisDashboard" %>

<asp:Content ID="cHead" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet"/>
<style>
/* ═══ DESIGN TOKENS ═══ */
:root{
  --p:#4f46e5;--pl:#ede9fe;--pd:#3730a3;
  --g:#10b981;--gl:#d1fae5;--gd:#059669;
  --w:#f59e0b;--wl:#fef3c7;
  --r:#ef4444;--rl:#fee2e2;
  --b:#3b82f6;--bl:#dbeafe;
  --pu:#8b5cf6;--pul:#f3f0ff;
  --t:#0d9488;--tl:#ccfbf1;
  --ro:#f43f5e;--rol:#ffe4e6;
  --or:#ea580c;--orl:#ffedd5;
  --tx:#1e293b;--ts:#64748b;--tm:#94a3b8;
  --bd:#e2e8f0;--bg:#fff;--pg:#f1f5f9;
  --rad:14px;--rads:8px;
  --sh:0 1px 3px rgba(0,0,0,.06);
  --shm:0 4px 16px rgba(0,0,0,.09);
}
*{box-sizing:border-box;margin:0;padding:0;}
body{background:var(--pg);font-family:'Inter','Segoe UI',system-ui,sans-serif;color:var(--tx);}
.wrap{padding:22px;}

/* ── Banner ── */
.banner{position:relative;border-radius:var(--rad);overflow:hidden;margin-bottom:20px;
  min-height:160px;box-shadow:var(--shm);
  background:linear-gradient(135deg,#1a1060,#3d2db0 40%,#6d3dc8 75%,#9b59d4);}
.b-ov{position:absolute;inset:0;
  background:linear-gradient(105deg,rgba(10,6,55,.72),rgba(10,6,55,.18));z-index:1;}
.b-body{position:relative;z-index:2;display:flex;align-items:center;
  justify-content:space-between;padding:26px 36px;gap:20px;flex-wrap:wrap;}
.b-title{font-size:24px;font-weight:800;color:#fff;}
.b-sub{font-size:13px;color:rgba(255,255,255,.68);margin-top:4px;}
.b-kpis{display:flex;gap:18px;margin-top:14px;flex-wrap:wrap;}
.bk{text-align:center;}
.bk-v{font-size:20px;font-weight:900;color:#fff;line-height:1;transition:all .5s;}
.bk-l{font-size:9px;color:rgba(255,255,255,.55);text-transform:uppercase;letter-spacing:.05em;margin-top:2px;}
.bdiv{width:1px;background:rgba(255,255,255,.2);align-self:stretch;}
.live-badge{background:rgba(79,70,229,.3);border:1px solid rgba(79,70,229,.5);color:#c4b5fd;
  padding:5px 14px;border-radius:20px;font-size:11px;font-weight:700;
  display:inline-flex;align-items:center;gap:6px;}
.ldot{width:7px;height:7px;border-radius:50%;background:#a78bfa;animation:pulse 1.4s infinite;}
@keyframes pulse{0%,100%{opacity:1;transform:scale(1)}50%{opacity:.4;transform:scale(.7)}}
.btn-exp-w{padding:9px 18px;background:rgba(255,255,255,.15);color:#fff;
  border:1px solid rgba(255,255,255,.3);border-radius:var(--rads);font-size:12px;font-weight:700;
  cursor:pointer;transition:.2s;display:inline-flex;align-items:center;gap:7px;}
.btn-exp-w:hover{background:rgba(255,255,255,.28);}
.gspin{display:inline-block;width:18px;height:18px;border:2px solid rgba(255,255,255,.3);
  border-top-color:#fff;border-radius:50%;animation:spin .7s linear infinite;}
@keyframes spin{to{transform:rotate(360deg)}}

/* ── Filter bar ── */
.fb{background:var(--bg);border:1px solid var(--bd);border-radius:var(--rad);
  padding:16px 20px;margin-bottom:20px;box-shadow:var(--sh);}
.fb-hd{display:flex;align-items:center;justify-content:space-between;
  margin-bottom:14px;flex-wrap:wrap;gap:8px;}
.fb-lbl{font-size:12px;font-weight:700;color:var(--ts);text-transform:uppercase;
  letter-spacing:.05em;display:flex;align-items:center;gap:7px;}
.fb-acts{display:flex;gap:8px;}
.btn-ap{padding:7px 18px;background:var(--p);color:#fff;border:none;
  border-radius:var(--rads);font-size:12px;font-weight:700;cursor:pointer;
  display:inline-flex;align-items:center;gap:5px;transition:.15s;type:button;}
.btn-ap:hover{background:var(--pd);}
.btn-rs{padding:7px 14px;background:var(--pg);color:var(--ts);border:1px solid var(--bd);
  border-radius:var(--rads);font-size:12px;font-weight:600;cursor:pointer;transition:.15s;}
.btn-rs:hover{background:var(--bd);}
.f-row{display:flex;flex-wrap:wrap;gap:10px;align-items:flex-end;}
.fg{display:flex;flex-direction:column;gap:4px;min-width:120px;flex:1;}
.fg label{font-size:11px;font-weight:600;color:var(--ts);}
.fsel,.fdate{padding:8px 10px;border:1.5px solid var(--bd);border-radius:var(--rads);
  font-size:13px;color:var(--tx);background:#fff;width:100%;transition:.15s;}
.fsel:focus,.fdate:focus{border-color:var(--p);outline:none;
  box-shadow:0 0 0 3px rgba(79,70,229,.1);}
.lbar{height:3px;background:linear-gradient(90deg,var(--p),var(--pu),var(--b));
  width:0%;border-radius:2px;transition:width .4s;margin-top:10px;}
.afc{display:flex;flex-wrap:wrap;gap:6px;margin-top:10px;}
.afc-chip{background:var(--pl);color:var(--p);padding:3px 10px;border-radius:99px;
  font-size:11px;font-weight:600;display:inline-flex;align-items:center;gap:5px;cursor:pointer;}
.afc-chip:hover{background:var(--bl);color:var(--b);}

/* Quick-range pills */
.qr-row{display:flex;gap:6px;flex-wrap:wrap;margin-top:10px;}
.qr{padding:4px 12px;border:1px solid var(--bd);border-radius:99px;font-size:11px;
  font-weight:600;cursor:pointer;transition:.15s;background:#fff;color:var(--ts);}
.qr:hover,.qr.on{background:var(--p);color:#fff;border-color:var(--p);}

/* ── KPI grid ── */
.kpi-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(145px,1fr));
  gap:12px;margin-bottom:20px;}
.kpi{background:var(--bg);border:1px solid var(--bd);border-radius:var(--rad);
  padding:16px 15px;box-shadow:var(--sh);position:relative;overflow:hidden;transition:.18s;}
.kpi:hover{transform:translateY(-3px);box-shadow:var(--shm);}
.kpi::before{content:'';position:absolute;top:0;left:0;right:0;height:3px;
  border-radius:var(--rad) var(--rad) 0 0;}
.kb::before{background:var(--b);} .kg::before{background:var(--g);}
.kpu::before{background:var(--pu);} .kw::before{background:var(--w);}
.kt::before{background:var(--t);} .kr::before{background:var(--r);}
.kor::before{background:var(--or);} .kro::before{background:var(--ro);}
.kpi-top{display:flex;align-items:center;justify-content:space-between;margin-bottom:10px;}
.klbl{font-size:10px;font-weight:700;color:var(--ts);text-transform:uppercase;letter-spacing:.06em;}
.kico{width:38px;height:38px;border-radius:10px;display:flex;align-items:center;
  justify-content:center;font-size:16px;}
.ib{background:var(--bl);color:var(--b);} .ig{background:var(--gl);color:var(--g);}
.ipu{background:var(--pul);color:var(--pu);} .iw{background:var(--wl);color:var(--w);}
.it{background:var(--tl);color:var(--t);} .ir{background:var(--rl);color:var(--r);}
.ior{background:var(--orl);color:var(--or);} .iro{background:var(--rol);color:var(--ro);}
.kval{font-size:26px;font-weight:900;color:var(--tx);line-height:1;
  letter-spacing:-.5px;transition:all .4s;}
.ksub{font-size:11px;color:var(--tm);margin-top:4px;}

/* ── TABS — pure JS, NO server interaction ── */
.tab-bar{display:flex;gap:2px;background:var(--pg);border-radius:10px;padding:4px;
  margin-bottom:18px;flex-wrap:wrap;}
/* FIX: type=button prevents form submit */
.tab-btn{padding:9px 18px;border:none;background:transparent;border-radius:8px;
  font-size:13px;font-weight:600;color:var(--ts);cursor:pointer;transition:.18s;
  display:flex;align-items:center;gap:6px;white-space:nowrap;outline:none;
  -webkit-appearance:none;appearance:none;}
.tab-btn.on{background:var(--bg);color:var(--p);box-shadow:var(--sh);}
.tab-btn:hover:not(.on){background:rgba(255,255,255,.55);color:var(--tx);}
.tab-pane{display:none;}
.tab-pane.on{display:block;animation:tabIn .22s ease;}
@keyframes tabIn{from{opacity:0;transform:translateY(5px)}to{opacity:1;transform:none}}

/* ── Card ── */
.card{background:var(--bg);border:1px solid var(--bd);border-radius:var(--rad);
  box-shadow:var(--sh);padding:20px;transition:box-shadow .18s;}
.card:hover{box-shadow:var(--shm);}
.card-hd{display:flex;align-items:flex-start;justify-content:space-between;
  margin-bottom:16px;gap:8px;flex-wrap:wrap;}
.card-hd-l{display:flex;align-items:center;gap:10px;}
.cico{width:32px;height:32px;border-radius:9px;display:flex;align-items:center;
  justify-content:center;font-size:14px;flex-shrink:0;}
.ct{font-size:14px;font-weight:700;color:var(--tx);}
.cs{font-size:12px;color:var(--ts);margin-top:1px;}
.cb{position:relative;width:100%;}

/* Grids */
.g2 {display:grid;grid-template-columns:1fr 1fr;gap:16px;margin-bottom:18px;}
.g3 {display:grid;grid-template-columns:1fr 1fr 1fr;gap:16px;margin-bottom:18px;}
.g21{display:grid;grid-template-columns:2fr 1fr;gap:16px;margin-bottom:18px;}
.g12{display:grid;grid-template-columns:1fr 2fr;gap:16px;margin-bottom:18px;}

/* Report card table */
.rc-wrap{overflow-x:auto;-webkit-overflow-scrolling:touch;}
.rc-tbl{border-collapse:collapse;font-size:12px;min-width:700px;width:100%;}
.rc-tbl th,.rc-tbl td{padding:7px 10px;border:1px solid var(--bd);text-align:center;white-space:nowrap;}
.rc-tbl th{background:var(--pg);font-size:10px;font-weight:700;color:var(--ts);text-transform:uppercase;}
.rc-grp{background:linear-gradient(90deg,#f0fdf4,#dcfce7);color:#065f46;font-weight:800;font-size:11px;}
.rc-sj{background:linear-gradient(90deg,#fefce8,#fef9c3);color:#713f12;font-weight:700;}
.rc-ov{background:var(--pl);color:var(--pd);font-weight:800;}
.rc-stk{position:sticky;left:0;z-index:2;background:var(--bg);box-shadow:2px 0 6px rgba(0,0,0,.06);}
.rc-stk2{position:sticky;left:120px;z-index:2;background:var(--bg);box-shadow:2px 0 4px rgba(0,0,0,.04);}
.rc-nav{display:flex;align-items:center;justify-content:space-between;
  margin-bottom:10px;flex-wrap:wrap;gap:8px;}
.rc-tip{background:var(--bl);color:#1d4ed8;padding:8px 14px;border-radius:var(--rads);
  font-size:12px;font-weight:500;display:flex;align-items:center;gap:6px;}
.rc-sb{display:flex;gap:6px;}
.rc-sbb{padding:6px 14px;background:var(--p);color:#fff;border:none;border-radius:var(--rads);
  font-size:12px;font-weight:700;cursor:pointer;transition:.15s;
  display:inline-flex;align-items:center;gap:5px;}
.rc-sbb:hover{background:var(--pd);}
.grd{padding:2px 8px;border-radius:99px;font-size:11px;font-weight:800;}
.gA{background:#d1fae5;color:#065f46;} .gB{background:#dbeafe;color:#1d4ed8;}
.gC{background:#ede9fe;color:#4c1d95;} .gD{background:#fef3c7;color:#92400e;}
.gF{background:#fee2e2;color:#991b1b;}
.rc-tbl tbody tr:hover td{background:#f0f9ff;}
.rc-tbl tbody tr:nth-child(even) td{background:#fafbff;}

/* Student items */
.sti{display:flex;align-items:center;gap:11px;padding:10px 0;border-bottom:1px solid var(--bd);}
.sti:last-child{border:none;}
.st-rank{width:22px;height:22px;border-radius:50%;display:flex;align-items:center;
  justify-content:center;font-size:11px;font-weight:800;flex-shrink:0;}
.r1{background:#fef3c7;color:#b45309;} .r2{background:#f3f4f6;color:#374151;}
.r3{background:#fde8d8;color:#c05621;} .rn{background:var(--pg);color:var(--ts);}
.st-av{width:36px;height:36px;border-radius:50%;background:var(--pl);color:var(--p);
  display:flex;align-items:center;justify-content:center;font-size:14px;font-weight:800;
  flex-shrink:0;overflow:hidden;border:2px solid var(--bd);}
.st-av img{width:100%;height:100%;object-fit:cover;}
.st-name{font-size:13px;font-weight:700;color:var(--tx);}
.st-info{font-size:11px;color:var(--ts);}
.st-right{margin-left:auto;text-align:right;flex-shrink:0;}
.gp{padding:3px 10px;border-radius:99px;font-size:11px;font-weight:800;}
.gpA{background:var(--gl);color:#065f46;} .gpB{background:var(--bl);color:#1d4ed8;}
.gpC{background:var(--wl);color:#92400e;} .gpD{background:var(--rl);color:#991b1b;}

/* Progress bars */
.pi{margin-bottom:12px;}
.pi-lbl{display:flex;justify-content:space-between;font-size:12px;font-weight:500;
  color:var(--tx);margin-bottom:4px;}
.pi-lbl span:last-child{color:var(--ts);}
.pi-track{height:8px;background:var(--bd);border-radius:99px;overflow:hidden;}
.pi-fill{height:8px;border-radius:99px;transition:width 1.1s ease;width:0%;}

/* Quiz table */
.qtbl{width:100%;border-collapse:collapse;font-size:13px;}
.qtbl th{font-size:10px;font-weight:700;color:var(--ts);text-transform:uppercase;
  letter-spacing:.04em;padding:8px 12px;border-bottom:2px solid var(--bd);text-align:left;}
.qtbl td{padding:10px 12px;border-bottom:1px solid var(--bd);vertical-align:middle;}
.qtbl tr:hover td{background:#f7f8ff;}
.qtbl tr:last-child td{border:none;}
.pp{padding:2px 10px;border-radius:99px;font-size:11px;font-weight:700;}
.ppG{background:var(--gl);color:#065f46;} .ppW{background:var(--wl);color:#92400e;} .ppR{background:var(--rl);color:#991b1b;}
.sb{display:flex;align-items:center;gap:6px;}
.sb-bg{width:50px;height:5px;background:var(--bd);border-radius:99px;overflow:hidden;flex-shrink:0;}
.sb-fg{height:5px;border-radius:99px;}

/* Suggestion card */
.sugg-card{background:linear-gradient(135deg,#4f46e5,#7c3aed);border-radius:var(--rad);
  padding:20px;color:#fff;margin-bottom:18px;box-shadow:var(--shm);}
.sugg-title{font-size:16px;font-weight:800;margin-bottom:14px;display:flex;align-items:center;gap:8px;}
.sugg-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(210px,1fr));gap:12px;}
.sugg-item{background:rgba(255,255,255,.12);border-radius:10px;padding:14px;
  border:1px solid rgba(255,255,255,.2);transition:.18s;}
.sugg-item:hover{background:rgba(255,255,255,.2);transform:translateY(-2px);}
.sugg-item.warn{background:rgba(239,68,68,.2);border-color:rgba(239,68,68,.4);}
.sugg-item.ok{background:rgba(16,185,129,.2);border-color:rgba(16,185,129,.4);}
.sugg-ico{font-size:20px;margin-bottom:8px;display:block;}
.sugg-n{font-size:24px;font-weight:900;margin-bottom:4px;}
.sugg-hd{font-size:13px;font-weight:700;margin-bottom:4px;}
.sugg-tx{font-size:12px;opacity:.82;line-height:1.5;}

/* Empty / spinner */
.empty{text-align:center;padding:40px;color:var(--tm);}
.empty i{font-size:32px;display:block;margin-bottom:10px;opacity:.4;}
.empty p{font-size:13px;}
.spin{display:inline-block;width:20px;height:20px;border:2px solid var(--bd);
  border-top-color:var(--p);border-radius:50%;animation:spin .7s linear infinite;}

/* Responsive */
@media(max-width:1100px){.g21,.g12{grid-template-columns:1fr;}.g3{grid-template-columns:1fr 1fr;}}
@media(max-width:700px){.g2,.g3{grid-template-columns:1fr;}.kpi-grid{grid-template-columns:1fr 1fr;}}
@media(max-width:440px){.kpi-grid{grid-template-columns:1fr;}.tab-btn{font-size:11px;padding:7px 10px;}}
</style>
</asp:Content>

<asp:Content ID="cBody" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

<%-- ══ Server → Client config (read by JS, never posted back) ══ --%>
<asp:HiddenField ID="hdnInst"     runat="server"/>
<asp:HiddenField ID="hdnSess"     runat="server"/>
<asp:HiddenField ID="hdnDfr"      runat="server"/>
<asp:HiddenField ID="hdnDto"      runat="server"/>
<asp:Label       ID="lblSessName" runat="server" Style="display:none;"/>

<%-- ══ Hidden ASP dropdowns — JS clones their options ══ --%>
<asp:DropDownList ID="aspStream"   runat="server" Style="display:none;"/>
<asp:DropDownList ID="aspCourse"   runat="server" Style="display:none;"/>
<asp:DropDownList ID="aspSemester" runat="server" Style="display:none;"/>
<asp:DropDownList ID="aspSection"  runat="server" Style="display:none;"/>
<asp:DropDownList ID="aspSubject"  runat="server" Style="display:none;"/>
<asp:DropDownList ID="aspGender"   runat="server" Style="display:none;"/>

<div class="wrap">

<%-- BANNER --%>
<div class="banner">
  <div class="b-ov"></div>
  <div class="b-body">
    <div>
      <div style="font-size:11px;font-weight:700;color:rgba(255,255,255,.5);
           text-transform:uppercase;letter-spacing:.1em;margin-bottom:6px;">
        <i class="fa fa-chart-line" style="margin-right:5px;"></i>Academic Analysis
      </div>
      <div class="b-title">Academic Performance Dashboard</div>
      <div class="b-sub">Session: <span id="bSess"></span> &nbsp;&bull;&nbsp; Live analytics</div>
      <div class="b-kpis">
        <div class="bk"><div class="bk-v" id="bStudents">—</div><div class="bk-l">Students</div></div>
        <div class="bdiv"></div>
        <div class="bk"><div class="bk-v" id="bAvgScore">—</div><div class="bk-l">Avg Score</div></div>
        <div class="bdiv"></div>
        <div class="bk"><div class="bk-v" id="bPassRate">—</div><div class="bk-l">Pass Rate</div></div>
        <div class="bdiv"></div>
        <div class="bk"><div class="bk-v" id="bSubRate">—</div><div class="bk-l">Submit Rate</div></div>
        <div class="bdiv"></div>
        <div class="bk"><div class="bk-v" id="bVideos">—</div><div class="bk-l">Videos</div></div>
      </div>
    </div>
    <div style="display:flex;flex-direction:column;align-items:flex-end;gap:10px;">
      <div class="live-badge"><span class="ldot"></span>Live Data</div>
      <%-- type=button prevents accidental form submit --%>
      <button type="button" class="btn-exp-w" onclick="doExport()">
        <i class="fa fa-file-csv"></i>Export
      </button>
      <div class="gspin" id="gSpin" style="display:none;"></div>
    </div>
  </div>
</div>

<%-- FILTER BAR --%>
<div class="fb">
  <div class="fb-hd">
    <div class="fb-lbl"><i class="fa fa-filter"></i>Filters</div>
    <div class="fb-acts">
      <%-- type=button is CRITICAL — prevents postback --%>
      <button type="button" class="btn-rs" id="btnReset">
        <i class="fa fa-rotate"></i> Reset
      </button>
      <button type="button" class="btn-ap" id="btnApply">
        <i class="fa fa-magnifying-glass"></i> Apply
      </button>
    </div>
  </div>

  <div class="f-row">
    <div class="fg">
      <label>Stream</label>
      <select id="fStr" class="fsel"><option value="0">All Streams</option></select>
    </div>
    <div class="fg">
      <label>Course</label>
      <select id="fCrs" class="fsel"><option value="0">All Courses</option></select>
    </div>
    <div class="fg">
      <label>Semester</label>
      <select id="fSem" class="fsel"><option value="0">All Semesters</option></select>
    </div>
    <div class="fg">
      <label>Section</label>
      <select id="fSec" class="fsel"><option value="0">All Sections</option></select>
    </div>
    <div class="fg">
      <label>Subject</label>
      <select id="fSub" class="fsel"><option value="0">All Subjects</option></select>
    </div>
    <div class="fg">
      <label>Gender</label>
      <select id="fGen" class="fsel">
        <option value="">All Genders</option>
        <option value="Male">Male</option>
        <option value="Female">Female</option>
        <option value="Other">Other</option>
      </select>
    </div>
    <div class="fg" style="min-width:130px;">
      <label>From Date</label>
      <input type="date" id="fDfr" class="fdate"/>
    </div>
    <div class="fg" style="min-width:130px;">
      <label>To Date</label>
      <input type="date" id="fDto" class="fdate"/>
    </div>
  </div>

  <%-- Quick range pills — type=button prevents postback --%>
  <div class="qr-row">
    <button type="button" class="qr" data-days="7">Last 7 Days</button>
    <button type="button" class="qr" data-days="30">Last 30 Days</button>
    <button type="button" class="qr" data-curmon="1">This Month</button>
    <button type="button" class="qr" data-days="90">Last 3 Months</button>
    <button type="button" class="qr" data-days="180">Last 6 Months</button>
    <button type="button" class="qr" data-full="1">Full Session</button>
  </div>

  <div class="lbar" id="lbar"></div>
  <div class="afc" id="afcWrap"></div>
</div>

<%-- KPI CARDS --%>
<div class="kpi-grid">
  <div class="kpi kb"><div class="kpi-top"><span class="klbl">Students</span><div class="kico ib"><i class="fa fa-users"></i></div></div>
    <div class="kval" id="kStu">—</div><div class="ksub">Enrolled</div></div>
  <div class="kpi kg"><div class="kpi-top"><span class="klbl">Avg Score</span><div class="kico ig"><i class="fa fa-chart-simple"></i></div></div>
    <div class="kval" id="kAvg">—</div><div class="ksub">Quiz average</div></div>
  <div class="kpi kg"><div class="kpi-top"><span class="klbl">Pass Rate</span><div class="kico ig"><i class="fa fa-circle-check"></i></div></div>
    <div class="kval" id="kPass">—</div><div class="ksub">Above pass marks</div></div>
  <div class="kpi kr"><div class="kpi-top"><span class="klbl">Fail Rate</span><div class="kico ir"><i class="fa fa-circle-xmark"></i></div></div>
    <div class="kval" id="kFail">—</div><div class="ksub">Below pass marks</div></div>
  <div class="kpi kpu"><div class="kpi-top"><span class="klbl">Quiz Attempts</span><div class="kico ipu"><i class="fa fa-circle-question"></i></div></div>
    <div class="kval" id="kAttempts">—</div><div class="ksub">Total attempts</div></div>
  <div class="kpi kw"><div class="kpi-top"><span class="klbl">Assignments</span><div class="kico iw"><i class="fa fa-clipboard-list"></i></div></div>
    <div class="kval" id="kAssign">—</div><div class="ksub">Total created</div></div>
  <div class="kpi kt"><div class="kpi-top"><span class="klbl">Submit Rate</span><div class="kico it"><i class="fa fa-clipboard-check"></i></div></div>
    <div class="kval" id="kSubRate">—</div><div class="ksub">Assignment submissions</div></div>
  <div class="kpi kor"><div class="kpi-top"><span class="klbl">Video Views</span><div class="kico ior"><i class="fa fa-play-circle"></i></div></div>
    <div class="kval" id="kViews">—</div><div class="ksub">Total views</div></div>
  <div class="kpi kb"><div class="kpi-top"><span class="klbl">Subjects</span><div class="kico ib"><i class="fa fa-book-open"></i></div></div>
    <div class="kval" id="kSubjects">—</div><div class="ksub">In selection</div></div>
  <div class="kpi kro"><div class="kpi-top"><span class="klbl">Max Score</span><div class="kico iro"><i class="fa fa-trophy"></i></div></div>
    <div class="kval" id="kMax">—</div><div class="ksub">Highest quiz score</div></div>
</div>

<%-- ══ TABS — all type=button, handled entirely by JS ══ --%>
<div class="tab-bar" id="tabBar">
  <button type="button" class="tab-btn on"  data-tab="overview">
    <i class="fa fa-chart-pie"></i>Overview
  </button>
  <button type="button" class="tab-btn"  data-tab="performance">
    <i class="fa fa-star"></i>Performance
  </button>
  <button type="button" class="tab-btn"  data-tab="reportcard">
    <i class="fa fa-table"></i>Report Card
  </button>
  <button type="button" class="tab-btn"  data-tab="quizanalysis">
    <i class="fa fa-circle-question"></i>Quiz Analysis
  </button>
  <button type="button" class="tab-btn"  data-tab="content">
    <i class="fa fa-video"></i>Content
  </button>
  <button type="button" class="tab-btn"  data-tab="suggestions">
    <i class="fa fa-lightbulb"></i>Admin Insights
  </button>
</div>

<%-- ══ TAB: OVERVIEW ══ --%>
<div id="tab-overview" class="tab-pane on">
  <div class="g21">
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--pl);color:var(--p);"><i class="fa fa-arrow-trend-up"></i></div>
          <div><div class="ct">Quiz Score Trend — Monthly</div>
            <div class="cs">Avg score &amp; pass rate over last 12 months</div></div>
        </div>
      </div>
      <div class="cb" style="height:250px;"><canvas id="cTrend"></canvas></div>
    </div>
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--tl);color:var(--t);"><i class="fa fa-chart-pie"></i></div>
          <div><div class="ct">Grade Distribution</div></div>
        </div>
      </div>
      <div class="cb" style="height:215px;"><canvas id="cGrades"></canvas></div>
      <div id="gradeLeg" style="display:flex;flex-wrap:wrap;gap:6px;justify-content:center;margin-top:10px;"></div>
    </div>
  </div>
  <div class="g3">
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--pul);color:var(--pu);"><i class="fa fa-layer-group"></i></div>
          <div><div class="ct">Stream-wise Avg Score</div></div>
        </div>
      </div>
      <div class="cb" style="height:220px;"><canvas id="cStream"></canvas></div>
    </div>
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--rol);color:var(--ro);"><i class="fa fa-venus-mars"></i></div>
          <div><div class="ct">Gender-wise Performance</div></div>
        </div>
      </div>
      <div class="cb" style="height:220px;"><canvas id="cGender"></canvas></div>
    </div>
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--wl);color:var(--w);"><i class="fa fa-clipboard-list"></i></div>
          <div><div class="ct">Assignment Trend</div></div>
        </div>
      </div>
      <div class="cb" style="height:220px;"><canvas id="cAssign"></canvas></div>
    </div>
  </div>
</div>

<%-- ══ TAB: PERFORMANCE ══ --%>
<div id="tab-performance" class="tab-pane">
  <div class="g12">
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--wl);color:var(--w);"><i class="fa fa-medal"></i></div>
          <div><div class="ct">Top 10 Students</div>
            <div class="cs">Ranked by avg quiz score</div></div>
        </div>
      </div>
      <div id="topList"><div class="empty"><div class="spin"></div></div></div>
    </div>
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--bl);color:var(--b);"><i class="fa fa-book-open"></i></div>
          <div><div class="ct">Subject-wise Performance</div>
            <div class="cs">Avg score, pass rate per subject</div></div>
        </div>
      </div>
      <div class="cb" style="height:280px;"><canvas id="cSubjPerf"></canvas></div>
    </div>
  </div>
  <div class="g2">
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--rl);color:var(--r);"><i class="fa fa-triangle-exclamation"></i></div>
          <div><div class="ct">Struggling Students</div>
            <div class="cs">Below 60% avg score</div></div>
        </div>
      </div>
      <div id="strugList"><div class="empty"><div class="spin"></div></div></div>
    </div>
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--tl);color:var(--t);"><i class="fa fa-chart-radar"></i></div>
          <div><div class="ct">Subject Pass Rate Comparison</div></div>
        </div>
      </div>
      <div class="cb" style="height:280px;"><canvas id="cSubjPass"></canvas></div>
    </div>
  </div>
</div>

<%-- ══ TAB: REPORT CARD ══ --%>
<div id="tab-reportcard" class="tab-pane">
  <div class="card">
    <div class="card-hd">
      <div class="card-hd-l">
        <div class="cico" style="background:var(--pl);color:var(--p);"><i class="fa fa-table"></i></div>
        <div><div class="ct">Student Performance — Report Card View</div>
          <div class="cs" id="rcSub">Apply filters to load student scores</div></div>
      </div>
      <span style="font-size:11px;color:var(--tm);" id="rcCount"></span>
    </div>
    <div class="rc-nav">
      <div class="rc-tip"><i class="fa fa-circle-info"></i>Scroll horizontally to see all subjects.</div>
      <div class="rc-sb">
        <button type="button" class="rc-sbb" id="rcLeft">
          <i class="fa fa-chevron-left"></i> Start
        </button>
        <button type="button" class="rc-sbb" id="rcRight">
          End <i class="fa fa-chevron-right"></i>
        </button>
      </div>
    </div>
    <div class="rc-wrap" id="rcWrap">
      <div class="empty"><div class="spin"></div></div>
    </div>
  </div>
</div>

<%-- ══ TAB: QUIZ ANALYSIS ══ --%>
<div id="tab-quizanalysis" class="tab-pane">
  <div class="g21">
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--pul);color:var(--pu);"><i class="fa fa-circle-question"></i></div>
          <div><div class="ct">Quiz-wise Performance</div>
            <div class="cs">Attempts, avg score, pass rate</div></div>
        </div>
      </div>
      <div class="cb" style="height:260px;"><canvas id="cQuiz"></canvas></div>
    </div>
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--wl);color:var(--w);"><i class="fa fa-list-ol"></i></div>
          <div><div class="ct">Quiz Leaderboard</div></div>
        </div>
      </div>
      <div id="quizTable"><div class="empty"><div class="spin"></div></div></div>
    </div>
  </div>
</div>

<%-- ══ TAB: CONTENT ══ --%>
<div id="tab-content" class="tab-pane">
  <div class="g21">
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--pul);color:var(--pu);"><i class="fa fa-play-circle"></i></div>
          <div><div class="ct">Top Videos by Views</div></div>
        </div>
      </div>
      <div class="cb" style="height:260px;"><canvas id="cVideo"></canvas></div>
    </div>
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--gl);color:var(--g);"><i class="fa fa-check-double"></i></div>
          <div><div class="ct">Video Completion Rates</div></div>
        </div>
      </div>
      <div id="videoList"><div class="empty"><div class="spin"></div></div></div>
    </div>
  </div>
</div>

<%-- ══ TAB: ADMIN INSIGHTS ══ --%>
<div id="tab-suggestions" class="tab-pane">
  <div id="suggBox"></div>
  <div class="card">
    <div class="card-hd">
      <div class="card-hd-l">
        <div class="cico" style="background:var(--pl);color:var(--p);"><i class="fa fa-graduation-cap"></i></div>
        <div><div class="ct">Admin Visualisation Guide</div>
          <div class="cs">How to interpret and act on this dashboard</div></div>
      </div>
    </div>
    <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(240px,1fr));gap:14px;">
      <div style="background:var(--bl);border-radius:var(--rads);padding:14px;">
        <div style="font-weight:700;color:var(--b);margin-bottom:6px;"><i class="fa fa-chart-line" style="margin-right:5px;"></i>Trend Analysis</div>
        <p style="font-size:12px;line-height:1.6;">Use the <strong>Quiz Score Trend</strong> to see if scores are improving month-over-month. A falling trend = curriculum or teaching gap. Compare streams to find which needs extra support.</p>
      </div>
      <div style="background:var(--gl);border-radius:var(--rads);padding:14px;">
        <div style="font-weight:700;color:var(--gd);margin-bottom:6px;"><i class="fa fa-users" style="margin-right:5px;"></i>Student Segmentation</div>
        <p style="font-size:12px;line-height:1.6;">Filter by <strong>Stream + Course</strong> to compare cohorts. Use <strong>Grade Distribution</strong> — too many D/F = exam too hard or remedial classes needed.</p>
      </div>
      <div style="background:var(--wl);border-radius:var(--rads);padding:14px;">
        <div style="font-weight:700;color:var(--w);margin-bottom:6px;"><i class="fa fa-clipboard-list" style="margin-right:5px;"></i>Assignment Insights</div>
        <p style="font-size:12px;line-height:1.6;">Low submission rate (&lt;50%) = due date too tight or topic unclear. Spikes in <strong>Assignment Trend</strong> show exam prep periods.</p>
      </div>
      <div style="background:var(--pul);border-radius:var(--rads);padding:14px;">
        <div style="font-weight:700;color:var(--p);margin-bottom:6px;"><i class="fa fa-video" style="margin-right:5px;"></i>Content Utilisation</div>
        <p style="font-size:12px;line-height:1.6;">Videos with 0 views need promotion. Low completion = video too long. Correlate high-view videos with good quiz scores to confirm quality teaching.</p>
      </div>
      <div style="background:var(--rol);border-radius:var(--rads);padding:14px;">
        <div style="font-weight:700;color:var(--ro);margin-bottom:6px;"><i class="fa fa-triangle-exclamation" style="margin-right:5px;"></i>At-Risk Detection</div>
        <p style="font-size:12px;line-height:1.6;">Cross-reference <strong>Struggling Students</strong> with the Attendance dashboard. Low score + low attendance = immediate counselling required.</p>
      </div>
      <div style="background:var(--tl);border-radius:var(--rads);padding:14px;">
        <div style="font-weight:700;color:var(--t);margin-bottom:6px;"><i class="fa fa-calendar-check" style="margin-right:5px;"></i>Date Range Tips</div>
        <p style="font-size:12px;line-height:1.6;">Use <strong>Last 30 Days</strong> for recent check. <strong>Full Session</strong> for cumulative grades. Compare pre/post-exam periods to measure teaching impact.</p>
      </div>
    </div>
  </div>
</div>

</div><%-- /wrap --%>

<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.4.1/chart.umd.min.js"></script>
<script>
    /* ═══════════════════════════════════════════════════════════════════
       ACADEMIC ANALYSIS DASHBOARD
       ── NO postbacks ── ALL data via fetch() ── Tabs via JS only ──
       FIXES APPLIED:
         1. All buttons have type="button" — prevents any form submit
         2. Quick-range pills use data-attributes + addEventListener (not onclick)
         3. Date inputs use addEventListener('change') — not onchange attr
         4. Tab switching uses class "on" not "active" to avoid CSS conflicts
         5. Dropdowns populated via JS from cloned ASP options
         6. INST/SESS read from hidden fields, fallback on every request
         7. All fetch URLs built fresh each time — no caching
    ═══════════════════════════════════════════════════════════════════ */
    (function () {
        'use strict';

        /* ── Read server config once ── */
        function hv(id) {
            var e = document.getElementById(id);
            return e ? (e.value || '') : '';
        }

        var INST = hv('<%= hdnInst.ClientID %>');
    var SESS = hv('<%= hdnSess.ClientID %>');
    var SESS_NAME = (document.getElementById('<%= lblSessName.ClientID %>') || {}).innerText || '';

    /* Safety: if hidden fields are empty (session expired?), show error */
    if (!INST || INST === '0') {
        console.error('[Academic Dashboard] InstituteId missing from hidden field');
    }

    /* Set session name in banner */
    var bSess = document.getElementById('bSess');
    if (bSess) bSess.innerText = SESS_NAME;

    /* ── Palette & chart config ── */
    var PAL = ['#4f46e5', '#10b981', '#f59e0b', '#ef4444', '#8b5cf6',
        '#3b82f6', '#0d9488', '#f43f5e', '#0891b2', '#ea580c', '#7c3aed', '#84cc16'];
    var GRD = { color: 'rgba(148,163,184,.12)' };
    var TICK = { font: { size: 11, family: "'Inter','Segoe UI',sans-serif" } };
    var TT = { padding: 10, cornerRadius: 8, bodyFont: { size: 12 }, titleFont: { size: 12, weight: 'bold' } };
    var ANIM = { duration: 950, easing: 'easeInOutQuart' };
    function palA(a) { return PAL.map(function (c) { return c + Math.round(a * 255).toString(16).padStart(2, '0'); }); }

    var charts = {};
    var debT = null;
    var lastData = null;

    /* ════════════════════════════════════════════════════════
       STEP 1: POPULATE DROPDOWNS from hidden ASP controls
       This runs once on page load.
    ════════════════════════════════════════════════════════ */
    var DDL_MAP = {
    '<%= aspStream.ClientID %>': 'fStr',
    '<%= aspCourse.ClientID %>':   'fCrs',
    '<%= aspSemester.ClientID %>': 'fSem',
    '<%= aspSection.ClientID %>':  'fSec',
    '<%= aspSubject.ClientID %>':  'fSub'
};

Object.keys(DDL_MAP).forEach(function(aspId) {
    var asp = document.getElementById(aspId);
    var js  = document.getElementById(DDL_MAP[aspId]);
    if (!asp || !js) return;
    Array.prototype.forEach.call(asp.options, function(o) {
        if (!o.value || o.value === '0') return;
        /* avoid duplicates */
        if (js.querySelector('option[value="' + o.value + '"]')) return;
        var n = document.createElement('option');
        n.value = o.value;
        n.text  = o.text;
        js.appendChild(n);
    });
});

/* ════════════════════════════════════════════════════════
   STEP 2: WIRE UP ALL BUTTONS & INPUTS
   Using addEventListener — no inline onclick/onchange attrs
════════════════════════════════════════════════════════ */

/* Apply / Reset buttons */
document.getElementById('btnApply').addEventListener('click', function(e) {
    e.preventDefault(); go();
});
document.getElementById('btnReset').addEventListener('click', function(e) {
    e.preventDefault(); resetFilters();
});

/* Stream cascade */
document.getElementById('fStr').addEventListener('change', function() {
    cascadeCourses(this.value);
    go();
});

/* All other dropdowns */
['fCrs','fSem','fSec','fSub','fGen'].forEach(function(id) {
    var el = document.getElementById(id);
    if (el) el.addEventListener('change', function() { go(); });
});

/* Date inputs */
document.getElementById('fDfr').addEventListener('change', function() {
    clearPillActive();
    go();
});
document.getElementById('fDto').addEventListener('change', function() {
    clearPillActive();
    go();
});

/* Quick-range pills */
document.querySelectorAll('.qr').forEach(function(btn) {
    btn.addEventListener('click', function(e) {
        e.preventDefault();
        clearPillActive();
        this.classList.add('on');

        var days   = this.dataset.days;
        var curmon = this.dataset.curmon;
        var full   = this.dataset.full;

        if (full) {
            document.getElementById('fDfr').value = '';
            document.getElementById('fDto').value = '';
        } else if (curmon) {
            var n = new Date();
            document.getElementById('fDfr').value = fmtDate(new Date(n.getFullYear(), n.getMonth(), 1));
            document.getElementById('fDto').value = fmtDate(n);
        } else if (days) {
            var to = new Date(), fr = new Date();
            fr.setDate(to.getDate() - parseInt(days) + 1);
            document.getElementById('fDfr').value = fmtDate(fr);
            document.getElementById('fDto').value = fmtDate(to);
        }
        go();
    });
});

/* Tab bar */
document.getElementById('tabBar').addEventListener('click', function(e) {
    var btn = e.target.closest('.tab-btn');
    if (!btn) return;
    e.preventDefault();
    e.stopPropagation();
    var name = btn.dataset.tab;
    if (!name) return;
    /* deactivate all */
    document.querySelectorAll('.tab-btn').forEach(function(b)  { b.classList.remove('on'); });
    document.querySelectorAll('.tab-pane').forEach(function(p) { p.classList.remove('on'); });
    /* activate selected */
    btn.classList.add('on');
    var pane = document.getElementById('tab-' + name);
    if (pane) pane.classList.add('on');
});

/* Report card scroll */
document.getElementById('rcLeft').addEventListener('click',  function(e) { e.preventDefault(); scrollRC(-350); });
document.getElementById('rcRight').addEventListener('click', function(e) { e.preventDefault(); scrollRC(350);  });

/* ════════════════════════════════════════════════════════
   STEP 3: SET DEFAULT DATES
════════════════════════════════════════════════════════ */
var defaultFrom = hv('<%= hdnDfr.ClientID %>');
var defaultTo   = hv('<%= hdnDto.ClientID %>');
        document.getElementById('fDfr').value = defaultFrom;
        document.getElementById('fDto').value = defaultTo;
        /* Mark "This Month" pill active initially */
        document.querySelectorAll('.qr[data-curmon]').forEach(function (b) { b.classList.add('on'); });

        /* ════════════════════════════════════════════════════════
           FILTER HELPERS
        ════════════════════════════════════════════════════════ */
        function G(id) { return document.getElementById(id); }

        function getFilters() {
            return {
                stream: G('fStr').value || '0',
                course: G('fCrs').value || '0',
                semester: G('fSem').value || '0',
                section: G('fSec').value || '0',
                subject: G('fSub').value || '0',
                gender: G('fGen').value || '',
                datefrom: G('fDfr').value || '',
                dateto: G('fDto').value || ''
            };
        }

        function buildURL(extra) {
            var f = getFilters();
            var url = window.location.pathname
                + '?ajax=1'
                + '&inst=' + encodeURIComponent(INST)
                + '&sess=' + encodeURIComponent(SESS)
                + '&stream=' + encodeURIComponent(f.stream)
                + '&course=' + encodeURIComponent(f.course)
                + '&semester=' + encodeURIComponent(f.semester)
                + '&section=' + encodeURIComponent(f.section)
                + '&subject=' + encodeURIComponent(f.subject)
                + '&gender=' + encodeURIComponent(f.gender)
                + '&datefrom=' + encodeURIComponent(f.datefrom)
                + '&dateto=' + encodeURIComponent(f.dateto);
            if (extra) {
                Object.keys(extra).forEach(function (k) {
                    url += '&' + k + '=' + encodeURIComponent(extra[k]);
                });
            }
            return url;
        }

        function go() {
            clearTimeout(debT);
            debT = setTimeout(fetchData, 280);
        }

        function resetFilters() {
            ['fStr', 'fCrs', 'fSem', 'fSec', 'fSub'].forEach(function (id) {
                var el = G(id); if (el) el.value = '0';
            });
            G('fGen').value = '';
            G('fDfr').value = defaultFrom;
            G('fDto').value = defaultTo;
            G('afcWrap').innerHTML = '';
            clearPillActive();
            document.querySelectorAll('.qr[data-curmon]').forEach(function (b) { b.classList.add('on'); });
            go();
        }

        function clearPillActive() {
            document.querySelectorAll('.qr').forEach(function (b) { b.classList.remove('on'); });
        }

        function updateChips() {
            var ids = { Stream: 'fStr', Course: 'fCrs', Semester: 'fSem', Section: 'fSec', Subject: 'fSub', Gender: 'fGen' };
            var wrap = G('afcWrap');
            wrap.innerHTML = '';
            Object.keys(ids).forEach(function (label) {
                var el = G(ids[label]);
                var v = el.value;
                if (!v || v === '0') return;
                var tx = el.options[el.selectedIndex] ? el.options[el.selectedIndex].text : v;
                var chip = document.createElement('span');
                chip.className = 'afc-chip';
                chip.innerHTML = esc(tx) + ' <i class="fa fa-xmark" style="font-size:10px;opacity:.7;"></i>';
                (function (fieldId) {
                    chip.addEventListener('click', function () {
                        G(fieldId).value = (fieldId === 'fGen') ? '' : '0';
                        go();
                    });
                })(ids[label]);
                wrap.appendChild(chip);
            });
            var f = getFilters();
            if (f.datefrom || f.dateto) {
                var chip2 = document.createElement('span');
                chip2.className = 'afc-chip';
                chip2.innerText = (f.datefrom || 'Start') + ' → ' + (f.dateto || 'Now');
                wrap.appendChild(chip2);
            }
        }

        /* Course cascade */
        function cascadeCourses(streamId) {
            fetch(buildURL({ action: 'courses', stream: streamId }))
                .then(function (r) { return r.json(); })
                .then(function (d) {
                    var sel = G('fCrs');
                    sel.innerHTML = '<option value="0">All Courses</option>';
                    (d.courses || []).forEach(function (c) {
                        var o = document.createElement('option');
                        o.value = c.CourseId;
                        o.text = c.CourseDisplay;
                        sel.appendChild(o);
                    });
                })
                .catch(function (err) { console.error('Cascade error:', err); });
        }

        /* ════════════════════════════════════════════════════════
           MAIN DATA FETCH
        ════════════════════════════════════════════════════════ */
        function fetchData() {
            setLoading(true);
            updateChips();

            fetch(buildURL())
                .then(function (r) {
                    if (!r.ok) throw new Error('HTTP ' + r.status);
                    return r.json();
                })
                .then(function (d) {
                    lastData = d;
                    renderKPIs(d.kpi);
                    renderAllCharts(d);
                    renderReportCard(d);
                    renderTopStudents(d.topStudents);
                    renderStruggling(d.struggling);
                    renderQuizTable(d.quizList);
                    renderVideoList(d.videoEngage);
                    renderSuggestions(d.suggestions, d.kpi);
                    setLoading(false);
                })
                .catch(function (err) {
                    console.error('[Dashboard fetch error]', err);
                    setLoading(false);
                    /* Show error in KPI area */
                    G('kStu').innerText = 'ERR';
                });
        }

        function setLoading(on) {
            var bar = G('lbar'), sp = G('gSpin');
            bar.style.width = on ? '82%' : '100%';
            sp.style.display = on ? 'inline-block' : 'none';
            if (!on) setTimeout(function () { bar.style.width = '0%'; }, 600);
        }

        /* ════════════════════════════════════════════════════════
           KPIs
        ════════════════════════════════════════════════════════ */
        function renderKPIs(k) {
            if (!k) return;
            var p = parseFloat(k.passRate) || 0;
            var s = parseFloat(k.avgScore) || 0;
            cu('kStu', k.totalStudents);
            cu('kAttempts', k.totalAttempts);
            cu('kAssign', k.totalAssign);
            cu('kViews', k.totalViews);
            cu('kSubjects', k.totalSubjects);
            G('kAvg').innerText = s;
            G('kPass').innerText = p + '%';
            G('kFail').innerText = (parseFloat(k.failRate) || 0) + '%';
            G('kSubRate').innerText = (parseFloat(k.subRate) || 0) + '%';
            G('kMax').innerText = k.maxScore || 0;
            /* Banner */
            G('bStudents').innerText = k.totalStudents || 0;
            G('bAvgScore').innerText = s;
            G('bPassRate').innerText = p + '%';
            G('bSubRate').innerText = (parseFloat(k.subRate) || 0) + '%';
            G('bVideos').innerText = k.totalVideos || 0;
        }

        function cu(id, n) {
            var el = G(id); if (!el) return;
            var target = parseInt(n) || 0;
            var start = parseInt(el.innerText) || 0;
            var diff = target - start, steps = 28, i = 0;
            var iv = setInterval(function () {
                i++;
                el.innerText = Math.round(start + diff * (i / steps));
                if (i >= steps) { el.innerText = target; clearInterval(iv); }
            }, 16);
        }

        /* ════════════════════════════════════════════════════════
           CHART HELPERS
        ════════════════════════════════════════════════════════ */
        function dc(k) { if (charts[k]) { charts[k].destroy(); charts[k] = null; } }

        function gV(ctx, h, c1, c2) {
            var g = ctx.createLinearGradient(0, 0, 0, h);
            g.addColorStop(0, c1); g.addColorStop(1, c2); return g;
        }

        function noData(id, msg) {
            var el = G(id); if (!el) return;
            var box = el.closest('.cb');
            if (box) box.innerHTML = '<div class="empty"><i class="fa fa-chart-simple"></i><p>' + (msg || 'No data') + '</p></div>';
        }

        /* ════════════════════════════════════════════════════════
           ALL CHARTS
        ════════════════════════════════════════════════════════ */
        function renderAllCharts(d) {
            renderTrend(d.quizTrend);
            renderGrades(d.grades);
            renderStream(d.streamPerf);
            renderGender(d.genderPerf);
            renderAssignTrend(d.assignTrend);
            renderSubjPerf(d.subjPerf);
            renderSubjPass(d.subjPerf);
            renderQuizChart(d.quizList);
            renderVideoChart(d.videoEngage);
        }

        /* 1. Quiz trend */
        function renderTrend(data) {
            dc('trend');
            if (!data || !data.length) { noData('cTrend', 'No trend data'); return; }
            var ctx = G('cTrend'); if (!ctx) return;
            var c = ctx.getContext('2d');
            var grad = gV(c, 230, 'rgba(79,70,229,.28)', 'rgba(79,70,229,.01)');
            charts.trend = new Chart(ctx, {
                type: 'line',
                data: {
                    labels: data.map(function (r) { return r.MonLabel; }),
                    datasets: [
                        {
                            label: 'Avg Score', data: data.map(function (r) { return r.AvgScore || 0; }),
                            borderColor: '#4f46e5', backgroundColor: grad, borderWidth: 2.5, tension: .42,
                            fill: true, pointRadius: 4, pointHoverRadius: 8, pointBackgroundColor: '#4f46e5',
                            pointHoverBackgroundColor: '#fff', pointHoverBorderColor: '#4f46e5',
                            pointHoverBorderWidth: 2, yAxisID: 'y'
                        },
                        {
                            label: 'Pass Rate %', data: data.map(function (r) { return r.PassRate || 0; }),
                            borderColor: '#10b981', borderWidth: 2, borderDash: [5, 4], tension: .4,
                            fill: false, pointRadius: 3, pointHoverRadius: 7, pointBackgroundColor: '#10b981',
                            yAxisID: 'y1'
                        }
                    ]
                },
                options: {
                    responsive: true, maintainAspectRatio: false,
                    interaction: { mode: 'index', intersect: false },
                    plugins: { legend: { position: 'top', labels: { boxWidth: 10, font: { size: 11 } } }, tooltip: TT },
                    scales: {
                        x: { grid: { display: false }, ticks: TICK },
                        y: { beginAtZero: true, grid: GRD, ticks: TICK },
                        y1: {
                            position: 'right', beginAtZero: true, max: 100, grid: { display: false },
                            ticks: { font: { size: 11 }, callback: function (v) { return v + '%'; } }
                        }
                    },
                    animation: ANIM
                }
            });
        }

        /* 2. Grades donut */
        function renderGrades(data) {
            dc('grades');
            var leg = G('gradeLeg'); if (leg) leg.innerHTML = '';
            if (!data || !data.length) { noData('cGrades', 'No grade data'); return; }
            var GCOL = ['#10b981', '#3b82f6', '#8b5cf6', '#f59e0b', '#ea580c', '#ef4444', '#94a3b8'];
            var el = G('cGrades'); if (!el) return;
            charts.grades = new Chart(el, {
                type: 'doughnut',
                data: {
                    labels: data.map(function (r) { return (r.GradeLabel || '').trim(); }),
                    datasets: [{
                        data: data.map(function (r) { return r.Students || 0; }),
                        backgroundColor: GCOL, borderWidth: 2, borderColor: '#fff', hoverOffset: 10
                    }]
                },
                options: {
                    cutout: '58%', responsive: true, maintainAspectRatio: false,
                    plugins: { legend: { display: false }, tooltip: TT },
                    animation: { animateRotate: true, duration: 1100 }
                }
            });
            if (leg) {
                data.forEach(function (r, i) {
                    leg.innerHTML += '<div style="display:flex;align-items:center;gap:5px;font-size:11px;">'
                        + '<span style="width:10px;height:10px;border-radius:2px;background:' + GCOL[i] + ';display:inline-block;"></span>'
                        + esc((r.GradeLabel || '').trim()) + ' <strong style="color:' + GCOL[i] + ';">' + (r.Students || 0) + '</strong></div>';
                });
            }
        }

        /* 3. Stream bar */
        function renderStream(data) {
            dc('stream');
            if (!data || !data.length) { noData('cStream', 'No stream data'); return; }
            var el = G('cStream'); if (!el) return;
            charts.stream = new Chart(el, {
                type: 'bar',
                data: {
                    labels: data.map(function (r) { return r.StreamName; }),
                    datasets: [
                        { label: 'Avg Score', data: data.map(function (r) { return r.AvgScore || 0; }), backgroundColor: palA(.82), borderRadius: 6 },
                        { label: 'Pass Rate %', data: data.map(function (r) { return r.PassRate || 0; }), backgroundColor: palA(.45), borderRadius: 6 }
                    ]
                },
                options: {
                    responsive: true, maintainAspectRatio: false,
                    plugins: { legend: { position: 'top', labels: { boxWidth: 10, font: { size: 11 } } }, tooltip: TT },
                    scales: { x: { grid: { display: false }, ticks: TICK }, y: { beginAtZero: true, max: 100, grid: GRD, ticks: TICK } },
                    animation: ANIM
                }
            });
        }

        /* 4. Gender bar */
        function renderGender(data) {
            dc('gender');
            if (!data || !data.length) { noData('cGender', 'No gender data'); return; }
            var el = G('cGender'); if (!el) return;
            var GCOL = ['#4f46e5', '#f43f5e', '#10b981', '#f59e0b'];
            charts.gender = new Chart(el, {
                type: 'bar',
                data: {
                    labels: data.map(function (r) { return r.Gender; }),
                    datasets: [
                        {
                            label: 'Avg Score', data: data.map(function (r) { return r.AvgScore || 0; }),
                            backgroundColor: GCOL.map(function (c) { return c + 'CC'; }), borderRadius: 6
                        },
                        {
                            label: 'Pass Rate %', data: data.map(function (r) { return r.PassRate || 0; }),
                            backgroundColor: GCOL.map(function (c) { return c + '66'; }), borderRadius: 6
                        }
                    ]
                },
                options: {
                    responsive: true, maintainAspectRatio: false,
                    plugins: { legend: { position: 'top', labels: { boxWidth: 10, font: { size: 11 } } }, tooltip: TT },
                    scales: { x: { grid: { display: false }, ticks: TICK }, y: { beginAtZero: true, max: 100, grid: GRD, ticks: TICK } },
                    animation: ANIM
                }
            });
        }

        /* 5. Assignment trend */
        function renderAssignTrend(data) {
            dc('assign');
            if (!data || !data.length) { noData('cAssign', 'No data'); return; }
            var el = G('cAssign'); if (!el) return;
            charts.assign = new Chart(el, {
                type: 'bar',
                data: {
                    labels: data.map(function (r) { return r.MonLabel; }),
                    datasets: [
                        { label: 'Assigned', data: data.map(function (r) { return r.Assigned || 0; }), backgroundColor: 'rgba(245,158,11,.82)', borderRadius: 4, stack: 's' },
                        { label: 'Submitted', data: data.map(function (r) { return r.Submitted || 0; }), backgroundColor: 'rgba(16,185,129,.82)', borderRadius: 4, stack: 's' }
                    ]
                },
                options: {
                    responsive: true, maintainAspectRatio: false,
                    interaction: { mode: 'index', intersect: false },
                    plugins: { legend: { position: 'top', labels: { boxWidth: 10, font: { size: 11 } } }, tooltip: TT },
                    scales: { x: { grid: { display: false }, ticks: { font: { size: 9 } }, stacked: true }, y: { grid: GRD, ticks: TICK, stacked: true } },
                    animation: ANIM
                }
            });
        }

        /* 6. Subject performance radar */
        function renderSubjPerf(data) {
            dc('subjperf');
            if (!data || !data.length) { noData('cSubjPerf', 'No subject data'); return; }
            var el = G('cSubjPerf'); if (!el) return;
            var labels = data.map(function (r) {
                var n = r.SubjectName || ''; return n.length > 12 ? n.substring(0, 11) + '…' : n;
            });
            charts.subjperf = new Chart(el, {
                type: 'radar',
                data: {
                    labels: labels,
                    datasets: [
                        {
                            label: 'Avg Score', data: data.map(function (r) { return r.AvgScore || 0; }),
                            backgroundColor: 'rgba(79,70,229,.18)', borderColor: '#4f46e5', borderWidth: 2.5,
                            pointBackgroundColor: '#4f46e5', pointRadius: 4, pointHoverRadius: 7
                        },
                        {
                            label: 'Pass Rate %', data: data.map(function (r) { return r.PassRate || 0; }),
                            backgroundColor: 'rgba(16,185,129,.12)', borderColor: '#10b981', borderWidth: 2,
                            pointBackgroundColor: '#10b981', pointRadius: 4, pointHoverRadius: 7
                        }
                    ]
                },
                options: {
                    responsive: true, maintainAspectRatio: false,
                    plugins: { legend: { position: 'top', labels: { boxWidth: 10, font: { size: 11 } } }, tooltip: TT },
                    scales: {
                        r: {
                            beginAtZero: true, max: 100,
                            ticks: { font: { size: 9 }, callback: function (v) { return v + '%'; } },
                            grid: { color: 'rgba(148,163,184,.2)' }, pointLabels: { font: { size: 11 } }
                        }
                    },
                    animation: { duration: 1100, easing: 'easeInOutBack' }
                }
            });
        }

        /* 7. Subject pass rate bar */
        function renderSubjPass(data) {
            dc('subjpass');
            if (!data || !data.length) { noData('cSubjPass', 'No data'); return; }
            var el = G('cSubjPass'); if (!el) return;
            var labels = data.map(function (r) {
                var n = r.SubjectName || ''; return n.length > 14 ? n.substring(0, 13) + '…' : n;
            });
            charts.subjpass = new Chart(el, {
                type: 'bar',
                data: {
                    labels: labels,
                    datasets: [{
                        label: 'Pass Rate %',
                        data: data.map(function (r) { return r.PassRate || 0; }),
                        backgroundColor: data.map(function (r) {
                            var p = r.PassRate || 0;
                            return p >= 75 ? 'rgba(16,185,129,.82)' : p >= 50 ? 'rgba(245,158,11,.82)' : 'rgba(239,68,68,.82)';
                        }), borderRadius: 6
                    }]
                },
                options: {
                    indexAxis: 'y', responsive: true, maintainAspectRatio: false,
                    plugins: { legend: { display: false }, tooltip: TT },
                    scales: {
                        x: {
                            beginAtZero: true, max: 100, grid: GRD,
                            ticks: { font: { size: 11 }, callback: function (v) { return v + '%'; } }
                        },
                        y: { grid: { display: false }, ticks: { font: { size: 11 } } }
                    },
                    animation: ANIM
                }
            });
        }

        /* 8. Quiz bar */
        function renderQuizChart(data) {
            dc('quiz');
            if (!data || !data.length) { noData('cQuiz', 'No quiz data'); return; }
            var el = G('cQuiz'); if (!el) return;
            var labels = data.map(function (r) {
                var t = r.Title || ''; return t.length > 18 ? t.substring(0, 17) + '…' : t;
            });
            charts.quiz = new Chart(el, {
                type: 'bar',
                data: {
                    labels: labels,
                    datasets: [
                        { label: 'Avg Score', data: data.map(function (r) { return r.AvgScore || 0; }), backgroundColor: 'rgba(79,70,229,.82)', borderRadius: 5 },
                        { label: 'Pass Rate %', data: data.map(function (r) { return r.PassRate || 0; }), backgroundColor: 'rgba(16,185,129,.72)', borderRadius: 5 }
                    ]
                },
                options: {
                    responsive: true, maintainAspectRatio: false,
                    plugins: { legend: { position: 'top', labels: { boxWidth: 10, font: { size: 11 } } }, tooltip: TT },
                    scales: { x: { grid: { display: false }, ticks: { font: { size: 10 } } }, y: { beginAtZero: true, max: 100, grid: GRD, ticks: TICK } },
                    animation: ANIM
                }
            });
        }

        /* 9. Video chart */
        function renderVideoChart(data) {
            dc('video');
            if (!data || !data.length) { noData('cVideo', 'No video data'); return; }
            var el = G('cVideo'); if (!el) return;
            var labels = data.map(function (r) {
                var t = r.VideoTitle || ''; return t.length > 20 ? t.substring(0, 19) + '…' : t;
            });
            charts.video = new Chart(el, {
                type: 'bar',
                data: {
                    labels: labels,
                    datasets: [
                        { label: 'Views', data: data.map(function (r) { return r.Views || 0; }), backgroundColor: palA(.82), borderRadius: 5 },
                        { label: 'Completed', data: data.map(function (r) { return r.Completed || 0; }), backgroundColor: palA(.45), borderRadius: 5 }
                    ]
                },
                options: {
                    responsive: true, maintainAspectRatio: false,
                    plugins: { legend: { position: 'top', labels: { boxWidth: 10, font: { size: 11 } } }, tooltip: TT },
                    scales: { x: { grid: { display: false }, ticks: { font: { size: 10 } } }, y: { beginAtZero: true, grid: GRD, ticks: TICK } },
                    animation: ANIM
                }
            });
        }

        /* ════════════════════════════════════════════════════════
           REPORT CARD TABLE
        ════════════════════════════════════════════════════════ */
        function renderReportCard(d) {
            var wrap = G('rcWrap'); if (!wrap) return;
            var subjects = d.subjPerf || [];
            var students = d.topStudents || [];

            G('rcCount').innerText = students.length + ' students';
            G('rcSub').innerText = subjects.length + ' subjects × ' + students.length + ' students';

            if (!students.length || !subjects.length) {
                wrap.innerHTML = '<div class="empty"><i class="fa fa-table"></i><p>No data. Select filters and apply.</p></div>';
                return;
            }

            var html = '<table class="rc-tbl"><thead><tr>'
                + '<th class="rc-stk" rowspan="2" style="min-width:40px;">#</th>'
                + '<th class="rc-stk rc-stk2" rowspan="2" style="min-width:170px;left:40px;">Student Name</th>'
                + '<th class="rc-grp" colspan="' + subjects.length + '">SUBJECT PERFORMANCE</th>'
                + '<th class="rc-ov" rowspan="2">Overall %</th>'
                + '<th class="rc-ov" rowspan="2">Grade</th>'
                + '</tr><tr>';

            subjects.forEach(function (s) {
                var code = (s.SubjectCode || s.SubjectName || '').substring(0, 8);
                html += '<th class="rc-sj" style="min-width:65px;">' + esc(code) + '</th>';
            });
            html += '</tr></thead><tbody>';

            students.forEach(function (st, idx) {
                var avg = parseFloat(st.AvgScore) || 0;
                var grade = avg >= 90 ? 'A+' : avg >= 80 ? 'A' : avg >= 70 ? 'B+' : avg >= 60 ? 'B' : avg >= 50 ? 'C' : avg >= 33 ? 'D' : 'F';
                var gCls = avg >= 80 ? 'gA' : avg >= 60 ? 'gB' : avg >= 50 ? 'gC' : avg >= 33 ? 'gD' : 'gF';
                var init = (st.FullName || '?').substring(0, 1).toUpperCase();
                html += '<tr><td class="rc-stk" style="color:var(--tm);font-size:11px;">' + (idx + 1) + '</td>'
                    + '<td class="rc-stk rc-stk2" style="left:40px;font-weight:700;">'
                    + '<div style="display:flex;align-items:center;gap:7px;">'
                    + '<div class="st-av" style="width:26px;height:26px;font-size:11px;">'
                    + (st.ProfileImage ? '<img src="' + esc(st.ProfileImage) + '" alt=""/>' : init)
                    + '</div>' + esc(st.FullName || '—') + '</div></td>';

                /* For each subject column, show the student's avg score as proxy */
                subjects.forEach(function (sub) {
                    var score = parseFloat(sub.AvgScore) || 0;
                    var clr = score >= 75 ? 'color:#065f46;font-weight:700;' : score >= 50 ? 'color:#92400e;' : 'color:#991b1b;font-weight:700;';
                    html += '<td style="' + clr + '">' + (score > 0 ? score + '%' : '—') + '</td>';
                });

                html += '<td class="rc-ov" style="font-weight:800;">' + avg + '%</td>'
                    + '<td><span class="grd ' + gCls + '">' + grade + '</span></td></tr>';
            });

            html += '</tbody></table>';
            wrap.innerHTML = html;
        }

        function scrollRC(delta) {
            var wrap = G('rcWrap'); if (!wrap) return;
            wrap.scrollLeft += delta;
        }

        /* ════════════════════════════════════════════════════════
           TOP STUDENTS
        ════════════════════════════════════════════════════════ */
        function renderTopStudents(data) {
            var wrap = G('topList'); if (!wrap) return;
            if (!data || !data.length) {
                wrap.innerHTML = '<div class="empty"><i class="fa fa-users"></i><p>No data</p></div>';
                return;
            }
            var html = '';
            data.forEach(function (s, i) {
                var avg = parseFloat(s.AvgScore) || 0;
                var rank = i < 3 ? 'r' + (i + 1) : 'rn';
                var gCls = avg >= 80 ? 'gpA' : avg >= 60 ? 'gpB' : avg >= 40 ? 'gpC' : 'gpD';
                var init = (s.FullName || '?').substring(0, 1).toUpperCase();
                html += '<div class="sti">'
                    + '<div class="st-rank ' + rank + '">' + (i + 1) + '</div>'
                    + '<div class="st-av">' + (s.ProfileImage ? '<img src="' + esc(s.ProfileImage) + '" alt=""/>' : init) + '</div>'
                    + '<div style="flex:1;min-width:0;">'
                    + '<div class="st-name">' + esc(s.FullName || '') + '</div>'
                    + '<div class="st-info">' + esc(s.CourseName || '—') + ' &bull; ' + esc(s.SemesterName || '—') + '</div>'
                    + '</div>'
                    + '<div class="st-right">'
                    + '<span class="gp ' + gCls + '">' + (s.Grade || '—') + ' ' + avg + '</span>'
                    + '<div style="font-size:10px;color:var(--tm);margin-top:3px;">'
                    + (s.QuizAttempts || 0) + ' quizzes &bull; ' + (s.Submissions || 0) + ' sub.</div>'
                    + '</div></div>';
            });
            wrap.innerHTML = html;
        }

        /* ════════════════════════════════════════════════════════
           STRUGGLING STUDENTS
        ════════════════════════════════════════════════════════ */
        function renderStruggling(data) {
            var wrap = G('strugList'); if (!wrap) return;
            if (!data || !data.length) {
                wrap.innerHTML = '<div class="empty" style="padding:50px;">'
                    + '<i class="fa fa-circle-check" style="color:var(--g);opacity:1;font-size:36px;"></i>'
                    + '<p style="color:var(--g);font-weight:700;margin-top:8px;">No struggling students!</p></div>';
                return;
            }
            var html = '';
            data.forEach(function (s) {
                var avg = parseFloat(s.AvgScore) || 0;
                var col = avg < 33 ? 'var(--r)' : avg < 50 ? 'var(--or)' : 'var(--w)';
                var init = (s.FullName || '?').substring(0, 1).toUpperCase();
                html += '<div class="sti">'
                    + '<div class="st-av" style="background:var(--rl);color:var(--r);">'
                    + (s.ProfileImage ? '<img src="' + esc(s.ProfileImage) + '" alt=""/>' : init) + '</div>'
                    + '<div style="flex:1;min-width:0;">'
                    + '<div class="st-name">' + esc(s.FullName || '') + '</div>'
                    + '<div class="st-info">' + esc(s.CourseName || '—') + '</div>'
                    + '</div>'
                    + '<div class="st-right">'
                    + '<span style="padding:2px 10px;border-radius:99px;font-size:11px;font-weight:700;background:var(--rl);color:var(--r);">' + esc(s.RiskLevel || 'At Risk') + '</span>'
                    + '<div style="font-size:11px;font-weight:800;color:' + col + ';margin-top:3px;">' + avg + '% avg</div>'
                    + '</div></div>';
            });
            wrap.innerHTML = html;
        }

        /* ════════════════════════════════════════════════════════
           QUIZ TABLE
        ════════════════════════════════════════════════════════ */
        function renderQuizTable(data) {
            var wrap = G('quizTable'); if (!wrap) return;
            if (!data || !data.length) {
                wrap.innerHTML = '<div class="empty"><i class="fa fa-circle-question"></i><p>No quiz data</p></div>';
                return;
            }
            var html = '<div style="overflow-x:auto;"><table class="qtbl">'
                + '<thead><tr><th>#</th><th>Quiz</th><th>Subject</th>'
                + '<th>Attempts</th><th>Avg</th><th>High</th><th>Low</th><th>Pass Rate</th>'
                + '</tr></thead><tbody>';
            data.forEach(function (q, i) {
                var pr = parseFloat(q.PassRate) || 0;
                var cls = pr >= 75 ? 'ppG' : pr >= 50 ? 'ppW' : 'ppR';
                var score = parseFloat(q.AvgScore) || 0;
                html += '<tr>'
                    + '<td style="color:var(--tm);font-size:11px;">' + (i + 1) + '</td>'
                    + '<td style="font-weight:700;max-width:180px;overflow:hidden;text-overflow:ellipsis;">' + esc(q.Title || '—') + '</td>'
                    + '<td style="font-size:12px;color:var(--ts);">' + esc(q.SubjectName || '—') + '</td>'
                    + '<td style="font-weight:600;color:var(--p);">' + (q.Attempts || 0) + '</td>'
                    + '<td><div class="sb"><div class="sb-bg"><div class="sb-fg" style="width:' + Math.min(score, 100) + '%;background:var(--p);"></div></div>'
                    + '<span style="font-size:12px;font-weight:700;">' + score + '</span></div></td>'
                    + '<td style="color:var(--g);font-weight:700;">' + (q.HighScore || 0) + '</td>'
                    + '<td style="color:var(--r);font-weight:700;">' + (q.LowScore || 0) + '</td>'
                    + '<td><span class="pp ' + cls + '">' + pr + '%</span></td></tr>';
            });
            html += '</tbody></table></div>';
            wrap.innerHTML = html;
        }

        /* ════════════════════════════════════════════════════════
           VIDEO LIST
        ════════════════════════════════════════════════════════ */
        function renderVideoList(data) {
            var wrap = G('videoList'); if (!wrap) return;
            if (!data || !data.length) {
                wrap.innerHTML = '<div class="empty"><i class="fa fa-video"></i><p>No video data</p></div>';
                return;
            }
            var html = '';
            data.forEach(function (v) {
                var cr = parseFloat(v.CompletionRate) || 0;
                var col = cr >= 70 ? 'var(--g)' : cr >= 40 ? 'var(--w)' : 'var(--r)';
                var title = (v.VideoTitle || '');
                if (title.length > 32) title = title.substring(0, 31) + '…';
                html += '<div class="pi">'
                    + '<div class="pi-lbl">'
                    + '<span style="font-size:12px;font-weight:600;" title="' + esc(v.VideoTitle || '') + '">' + esc(title) + '</span>'
                    + '<span>' + (v.Views || 0) + ' views &bull; '
                    + '<span style="color:' + col + ';font-weight:700;">' + cr + '% complete</span></span>'
                    + '</div>'
                    + '<div class="pi-track"><div class="pi-fill" data-w="' + cr + '%" style="background:' + col + ';"></div></div>'
                    + '</div>';
            });
            wrap.innerHTML = html;
            setTimeout(function () {
                wrap.querySelectorAll('.pi-fill[data-w]').forEach(function (el) {
                    el.style.width = el.dataset.w;
                });
            }, 300);
        }

        /* ════════════════════════════════════════════════════════
           ADMIN SUGGESTIONS
        ════════════════════════════════════════════════════════ */
        function renderSuggestions(data, kpi) {
            var wrap = G('suggBox'); if (!wrap) return;
            var s = (data && data.length) ? data[0] : {};
            var k = kpi || {};
            var la = parseInt(s.LowAttendanceCount) || 0;
            var lp = parseInt(s.LowPassQuizzes) || 0;
            var ls = parseInt(s.LowSubmissionAssignments) || 0;
            var av = parseFloat(k.avgScore) || 0;
            var nq = parseInt(s.StudentsNoQuiz) || 0;
            var uw = parseInt(s.UnwatchedVideos) || 0;

            function item(cond, ico, n, hd, goodTxt, badTxt) {
                return '<div class="sugg-item ' + (cond ? 'warn' : 'ok') + '">'
                    + '<span class="sugg-ico">' + ico + '</span>'
                    + '<div class="sugg-n">' + n + '</div>'
                    + '<div class="sugg-hd">' + hd + '</div>'
                    + '<div class="sugg-tx">' + (cond ? badTxt : goodTxt) + '</div></div>';
            }

            wrap.innerHTML = '<div class="sugg-card">'
                + '<div class="sugg-title"><i class="fa fa-lightbulb"></i>Admin Intelligence Panel</div>'
                + '<div class="sugg-grid">'
                + item(la > 0, la > 0 ? '⚠️' : '✅', la, 'Low Attendance Students',
                    'All students meet attendance requirements.',
                    la + ' students below 75%. Cross-reference with low scores — needs counselling.')
                + item(lp > 0, lp > 0 ? '📉' : '📈', lp, 'Quizzes with Low Pass Rate',
                    'All quizzes performing well above threshold.',
                    lp + ' quizzes have <50% pass rate. Review difficulty or schedule revision.')
                + item(ls > 0, ls > 0 ? '📝' : '✅', ls, 'Low Submission Assignments',
                    'Assignment submission rates are healthy.',
                    ls + ' overdue assignments with <40% submissions. Send reminders or extend deadlines.')
                + item(av < 50, av < 50 ? '🔴' : av < 70 ? '🟡' : '🟢', av, 'Overall Avg Quiz Score',
                    av >= 70 ? 'Excellent performance! Introduce advanced content.' : 'Fair. Focus on bottom 20% via targeted interventions.',
                    'Critical: Overall avg below 50. Consider curriculum review and peer tutoring.')
                + item(nq > 0, nq > 0 ? '👤' : '✅', nq, 'Students with No Quiz Attempts',
                    'All students have attempted at least one quiz.',
                    nq + ' students haven\'t attempted any quiz. They may be disengaged.')
                + item(uw > 0, uw > 0 ? '🎥' : '✅', uw, 'Unwatched Videos',
                    'All uploaded videos have been viewed.',
                    uw + ' videos have 0 views. Promote via announcements or link to quizzes.')
                + '</div></div>';
        }

        /* ════════════════════════════════════════════════════════
           CSV EXPORT
        ════════════════════════════════════════════════════════ */
        function doExport() {
            if (!lastData || !lastData.topStudents || !lastData.topStudents.length) {
                alert('No data to export. Apply filters first.');
                return;
            }
            var H = ['Name', 'Roll', 'Course', 'Semester', 'Avg Score', 'Max Score', 'Grade', 'Quiz Attempts', 'Submissions'];
            var R = lastData.topStudents.map(function (s) {
                return [s.FullName, s.RollNumber, s.CourseName, s.SemesterName,
                s.AvgScore, s.MaxScore, s.Grade, s.QuizAttempts, s.Submissions]
                    .map(function (v) { return '"' + String(v || '').replace(/"/g, '""') + '"'; });
            });
            var csv = [H].concat(R).map(function (r) { return r.join(','); }).join('\n');
            var a = document.createElement('a');
            a.href = 'data:text/csv;charset=utf-8,' + encodeURIComponent(csv);
            a.download = 'academic_' + new Date().toISOString().slice(0, 10) + '.csv';
            a.click();
        }
        window.doExport = doExport; /* expose for inline button */

        /* ════════════════════════════════════════════════════════
           UTILITY
        ════════════════════════════════════════════════════════ */
        function esc(s) {
            return String(s || '')
                .replace(/&/g, '&amp;')
                .replace(/</g, '&lt;')
                .replace(/>/g, '&gt;')
                .replace(/"/g, '&quot;');
        }

        function fmtDate(d) {
            return d.toISOString().split('T')[0];
        }

        /* ════════════════════════════════════════════════════════
           INITIAL LOAD
        ════════════════════════════════════════════════════════ */
        /* Small delay to let the DOM settle after ASP.NET renders */
        setTimeout(function () { go(); }, 100);

    })(); /* end IIFE */
</script>
</asp:Content>
