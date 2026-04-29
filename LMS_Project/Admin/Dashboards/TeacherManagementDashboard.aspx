<%@ Page Title="Teacher Management Dashboard" Language="C#"
    MasterPageFile="~/Admin/AdminMaster.Master"
    AutoEventWireup="true"
    CodeBehind="TeacherManagementDashboard.aspx.cs"
    Inherits="LearningManagementSystem.Admin.TeacherManagementDashboard" %>

<asp:Content ID="cHead" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet"/>
<style>
/* ══════════════════ DESIGN TOKENS ══════════════════ */
:root{
  --p:#4f46e5;--pl:#ede9fe;--pd:#3730a3;--p20:rgba(79,70,229,.12);
  --g:#10b981;--gl:#d1fae5;--gd:#059669;
  --w:#f59e0b;--wl:#fef3c7;
  --r:#ef4444;--rl:#fee2e2;
  --b:#3b82f6;--bl:#dbeafe;
  --pu:#8b5cf6;--pul:#f3f0ff;
  --t:#0d9488;--tl:#ccfbf1;
  --ro:#f43f5e;--rol:#ffe4e6;
  --cy:#0891b2;--cyl:#cffafe;
  --or:#ea580c;--orl:#ffedd5;
  --vi:#7c3aed;--vil:#ede9fe;
  --tx:#1e293b;--ts:#64748b;--tm:#94a3b8;
  --bd:#e2e8f0;--bg:#fff;--pg:#f1f5f9;
  --rad:14px;--rads:8px;
  --sh:0 1px 3px rgba(0,0,0,.06),0 1px 2px rgba(0,0,0,.04);
  --shm:0 4px 16px rgba(0,0,0,.09);
  --shl:0 10px 32px rgba(0,0,0,.12);
}
*{box-sizing:border-box;margin:0;padding:0;}
body{background:var(--pg);font-family:'Inter','Segoe UI',system-ui,sans-serif;color:var(--tx);}
.wrap{padding:22px;}

/* ── Alert ── */
.dash-alert{display:flex;align-items:center;gap:10px;padding:12px 18px;
  border-radius:var(--rads);font-size:13px;font-weight:500;margin-bottom:16px;
  animation:fadeD .3s ease;}
@keyframes fadeD{from{opacity:0;transform:translateY(-6px)}to{opacity:1;transform:none}}
.alert-danger{background:var(--rl);color:#991b1b;border-left:3px solid var(--r);}
.alert-info  {background:var(--bl);color:#1e40af;border-left:3px solid var(--b);}

/* ══════════════════ BANNER ══════════════════ */
.banner{
  position:relative;border-radius:var(--rad);overflow:hidden;
  margin-bottom:20px;min-height:165px;
  background:linear-gradient(135deg,#1a1060 0%,#3d2db0 40%,#6d3dc8 75%,#9b59d4 100%);
  box-shadow:var(--shm);
}
.b-particles{position:absolute;inset:0;overflow:hidden;z-index:0;}
.b-particle{
  position:absolute;border-radius:50%;background:rgba(255,255,255,.08);
  animation:float linear infinite;
}
@keyframes float{
  0%{transform:translateY(100%) scale(1);opacity:0}
  10%{opacity:1}
  90%{opacity:.6}
  100%{transform:translateY(-120px) scale(1.2);opacity:0}
}
.b-ov{position:absolute;inset:0;background:linear-gradient(100deg,rgba(10,6,55,.72),rgba(10,6,55,.18));z-index:1;}
.b-body{
  position:relative;z-index:2;display:flex;align-items:center;
  justify-content:space-between;padding:26px 36px;gap:20px;flex-wrap:wrap;
}
.b-left{flex:1;}
.b-eyebrow{font-size:11px;font-weight:700;color:rgba(255,255,255,.55);
  text-transform:uppercase;letter-spacing:.1em;margin-bottom:6px;
  display:flex;align-items:center;gap:6px;}
.b-title{font-size:24px;font-weight:800;color:#fff;line-height:1.2;margin-bottom:4px;}
.b-sub{font-size:13px;color:rgba(255,255,255,.68);}
.b-stats{display:flex;gap:20px;margin-top:16px;flex-wrap:wrap;}
.bst{text-align:center;padding:0 4px;}
.bst-v{font-size:22px;font-weight:900;color:#fff;line-height:1;
  transition:all .5s;}
.bst-l{font-size:9px;color:rgba(255,255,255,.55);text-transform:uppercase;letter-spacing:.06em;margin-top:2px;}
.b-divider{width:1px;background:rgba(255,255,255,.2);align-self:stretch;}
.b-right{display:flex;flex-direction:column;align-items:flex-end;gap:10px;}
.btn-export{
  padding:9px 20px;background:rgba(255,255,255,.15);color:#fff;
  border:1px solid rgba(255,255,255,.35);border-radius:var(--rads);
  font-size:12px;font-weight:700;cursor:pointer;transition:.2s;
  display:inline-flex;align-items:center;gap:7px;backdrop-filter:blur(4px);
}
.btn-export:hover{background:rgba(255,255,255,.28);}
.live-badge{
  background:rgba(16,185,129,.2);border:1px solid rgba(16,185,129,.4);
  color:#a7f3d0;padding:4px 12px;border-radius:20px;font-size:11px;font-weight:700;
  display:inline-flex;align-items:center;gap:5px;
}
.live-dot{width:7px;height:7px;border-radius:50%;background:#10b981;
  animation:pulse 1.4s infinite;}
@keyframes pulse{0%,100%{opacity:1;transform:scale(1)}50%{opacity:.5;transform:scale(.8)}}

/* ══════════════════ FILTER BAR ══════════════════ */
.filter-bar{
  background:var(--bg);border:1px solid var(--bd);border-radius:var(--rad);
  padding:16px 20px;margin-bottom:20px;box-shadow:var(--sh);
}
.fb-header{display:flex;align-items:center;justify-content:space-between;
  margin-bottom:14px;flex-wrap:wrap;gap:8px;}
.fb-label{font-size:12px;font-weight:700;color:var(--ts);text-transform:uppercase;
  letter-spacing:.05em;display:flex;align-items:center;gap:7px;}
.fb-actions{display:flex;gap:8px;}
.btn-search{padding:7px 18px;background:var(--p);color:#fff;border:none;
  border-radius:var(--rads);font-size:12px;font-weight:700;cursor:pointer;
  display:inline-flex;align-items:center;gap:6px;transition:.18s;}
.btn-search:hover{background:var(--pd);transform:translateY(-1px);}
.btn-reset{padding:7px 14px;background:var(--pg);color:var(--ts);
  border:1px solid var(--bd);border-radius:var(--rads);font-size:12px;
  font-weight:600;cursor:pointer;transition:.18s;display:inline-flex;align-items:center;gap:5px;}
.btn-reset:hover{background:var(--bd);}
.filter-row{display:flex;flex-wrap:wrap;gap:10px;align-items:flex-end;}
.fg{display:flex;flex-direction:column;gap:4px;min-width:130px;flex:1;}
.fg label{font-size:11px;font-weight:600;color:var(--ts);}
.fsel,.finp{
  padding:8px 10px;border:1.5px solid var(--bd);border-radius:var(--rads);
  font-size:13px;color:var(--tx);background:#fff;width:100%;transition:.18s;
}
.fsel:focus,.finp:focus{border-color:var(--p);outline:none;box-shadow:0 0 0 3px var(--p20);}
.sw-wrap{position:relative;flex:2;min-width:180px;}
.sw-wrap i{position:absolute;left:10px;top:50%;transform:translateY(-50%);
  color:var(--tm);font-size:12px;z-index:1;}
.fsearch{padding-left:32px !important;}
.load-bar{height:3px;background:linear-gradient(90deg,var(--p),var(--pu),var(--b));
  width:0%;border-radius:2px;transition:width .4s;margin-top:10px;}
.af-chips{display:flex;flex-wrap:wrap;gap:6px;margin-top:10px;}
.af-chip{background:var(--pl);color:var(--p);padding:3px 10px;border-radius:99px;
  font-size:11px;font-weight:600;display:inline-flex;align-items:center;gap:5px;cursor:pointer;}
.af-chip i{font-size:10px;opacity:.7;}
.af-chip:hover{background:var(--bl);color:var(--b);}

/* ══════════════════ KPI GRID ══════════════════ */
.kpi-grid{
  display:grid;
  grid-template-columns:repeat(auto-fit,minmax(148px,1fr));
  gap:12px;margin-bottom:20px;
}
.kpi{background:var(--bg);border:1px solid var(--bd);border-radius:var(--rad);
  padding:16px 15px;box-shadow:var(--sh);position:relative;overflow:hidden;
  transition:transform .18s,box-shadow .18s;}
.kpi:hover{transform:translateY(-3px);box-shadow:var(--shm);}
.kpi::before{content:'';position:absolute;top:0;left:0;right:0;height:3px;
  border-radius:var(--rad) var(--rad) 0 0;}
.kb::before{background:var(--b);}   .kg::before{background:var(--g);}
.kpu::before{background:var(--pu);} .kw::before{background:var(--w);}
.kt::before{background:var(--t);}   .kr::before{background:var(--r);}
.kor::before{background:var(--or);} .kvi::before{background:var(--vi);}
.kro::before{background:var(--ro);} .kcy::before{background:var(--cy);}
.kpi-top{display:flex;align-items:center;justify-content:space-between;margin-bottom:10px;}
.kpi-lbl{font-size:10px;font-weight:700;color:var(--ts);text-transform:uppercase;letter-spacing:.06em;}
.kpi-ico{width:38px;height:38px;border-radius:10px;display:flex;align-items:center;
  justify-content:center;font-size:16px;}
.ib{background:var(--bl);color:var(--b);}   .ig{background:var(--gl);color:var(--g);}
.ipu{background:var(--pul);color:var(--pu);} .iw{background:var(--wl);color:var(--w);}
.it{background:var(--tl);color:var(--t);}   .ir{background:var(--rl);color:var(--r);}
.ior{background:var(--orl);color:var(--or);} .ivi{background:var(--vil);color:var(--vi);}
.iro{background:var(--rol);color:var(--ro);} .icy{background:var(--cyl);color:var(--cy);}
.kpi-val{font-size:26px;font-weight:900;color:var(--tx);line-height:1;letter-spacing:-.5px;
  transition:all .4s;}
.kpi-sub{font-size:11px;color:var(--tm);margin-top:4px;}

/* ══════════════════ TABS ══════════════════ */
.tab-bar{display:flex;gap:2px;background:var(--pg);border-radius:10px;padding:4px;
  margin-bottom:18px;flex-wrap:wrap;}
.tab-btn{padding:8px 16px;border:none;background:transparent;border-radius:8px;
  font-size:13px;font-weight:600;color:var(--ts);cursor:pointer;transition:.18s;
  display:flex;align-items:center;gap:6px;white-space:nowrap;}
.tab-btn.active{background:var(--bg);color:var(--p);box-shadow:var(--sh);}
.tab-btn:hover:not(.active){background:rgba(255,255,255,.55);color:var(--tx);}
.tab-pane{display:none;animation:fadeIn .25s ease;}
.tab-pane.active{display:block;}
@keyframes fadeIn{from{opacity:0;transform:translateY(4px)}to{opacity:1;transform:none}}

/* ══════════════════ CARD ══════════════════ */
.card{background:var(--bg);border:1px solid var(--bd);border-radius:var(--rad);
  box-shadow:var(--sh);padding:20px;transition:box-shadow .18s;}
.card:hover{box-shadow:var(--shm);}
.card-hd{display:flex;align-items:flex-start;justify-content:space-between;
  margin-bottom:16px;gap:8px;flex-wrap:wrap;}
.card-hd-l{display:flex;align-items:center;gap:10px;}
.c-ico{width:32px;height:32px;border-radius:9px;display:flex;align-items:center;
  justify-content:center;font-size:14px;flex-shrink:0;}
.c-title{font-size:14px;font-weight:700;color:var(--tx);}
.c-sub{font-size:12px;color:var(--ts);margin-top:1px;}
.chart-box{position:relative;width:100%;}

/* ── Grids ── */
.g2 {display:grid;grid-template-columns:1fr 1fr;gap:16px;margin-bottom:18px;}
.g3 {display:grid;grid-template-columns:1fr 1fr 1fr;gap:16px;margin-bottom:18px;}
.g21{display:grid;grid-template-columns:2fr 1fr;gap:16px;margin-bottom:18px;}
.g12{display:grid;grid-template-columns:1fr 2fr;gap:16px;margin-bottom:18px;}
.g13{display:grid;grid-template-columns:1fr 3fr;gap:16px;margin-bottom:18px;}

/* ══════════════════ TEACHER TABLE ══════════════════ */
.tbl-wrap{overflow-x:auto;}
.ttbl{width:100%;border-collapse:collapse;font-size:13px;min-width:960px;}
.ttbl th{font-size:10px;font-weight:700;color:var(--ts);text-transform:uppercase;
  letter-spacing:.05em;padding:10px 12px;border-bottom:2px solid var(--bd);
  text-align:left;white-space:nowrap;cursor:pointer;user-select:none;}
.ttbl th:hover{color:var(--p);}
.ttbl td{padding:11px 12px;border-bottom:1px solid var(--bd);vertical-align:middle;}
.ttbl tr:hover td{background:#f7f8ff;}
.ttbl tr:last-child td{border-bottom:none;}
.tav{width:36px;height:36px;border-radius:50%;background:var(--pul);color:var(--pu);
  display:flex;align-items:center;justify-content:center;font-size:13px;font-weight:800;
  overflow:hidden;flex-shrink:0;border:2px solid var(--bd);}
.tav img{width:100%;height:100%;object-fit:cover;}
.t-name{font-weight:700;color:var(--tx);}
.t-emp{font-size:11px;color:var(--tm);}
.status-pill{display:inline-block;padding:2px 9px;border-radius:99px;font-size:11px;font-weight:700;}
.sp-a{background:var(--gl);color:#065f46;}
.sp-i{background:var(--rl);color:#991b1b;}
.sp-n{background:var(--bl);color:#1d4ed8;}
.act-chip{display:inline-flex;align-items:center;gap:3px;padding:2px 8px;
  border-radius:99px;font-size:11px;font-weight:600;margin-right:3px;}
.ac-v {background:var(--bl);color:#1d4ed8;}
.ac-a {background:var(--wl);color:#92400e;}
.ac-q {background:var(--pul);color:#6d28d9;}
.ac-s {background:var(--gl);color:#065f46;}

/* Pagination */
.pag{display:flex;align-items:center;justify-content:space-between;
  margin-top:14px;flex-wrap:wrap;gap:10px;}
.pag-info{font-size:12px;color:var(--ts);}
.pag-btns{display:flex;gap:4px;}
.pbtn{width:32px;height:32px;border:1px solid var(--bd);border-radius:var(--rads);
  background:#fff;color:var(--ts);font-size:12px;font-weight:600;cursor:pointer;
  display:flex;align-items:center;justify-content:center;transition:.15s;}
.pbtn:hover{border-color:var(--p);color:var(--p);}
.pbtn.act{background:var(--p);color:#fff;border-color:var(--p);}
.pbtn:disabled{opacity:.35;cursor:not-allowed;}

/* ══════════════════ TOP TEACHERS ══════════════════ */
.ti{display:flex;align-items:center;gap:12px;padding:11px 0;border-bottom:1px solid var(--bd);}
.ti:last-child{border:none;}
.ti-rank{width:24px;height:24px;border-radius:50%;display:flex;align-items:center;
  justify-content:center;font-size:11px;font-weight:800;flex-shrink:0;}
.r1{background:#fef3c7;color:#b45309;}
.r2{background:#f3f4f6;color:#374151;}
.r3{background:#fde8d8;color:#c05621;}
.rn{background:var(--pg);color:var(--ts);}
.ti-av{width:40px;height:40px;border-radius:50%;background:var(--pul);color:var(--pu);
  display:flex;align-items:center;justify-content:center;font-size:15px;font-weight:800;
  flex-shrink:0;overflow:hidden;border:2px solid var(--bd);}
.ti-av img{width:100%;height:100%;object-fit:cover;}
.ti-name{font-size:13px;font-weight:700;color:var(--tx);}
.ti-des{font-size:11px;color:var(--ts);}
.ti-chips{display:flex;flex-wrap:wrap;gap:4px;margin-top:4px;}
.ti-right{margin-left:auto;text-align:right;flex-shrink:0;}
.ti-score{font-size:14px;font-weight:800;color:var(--p);}
.ti-sub{font-size:10px;color:var(--tm);}

/* ══════════════════ ACTIVITY FEED ══════════════════ */
.act-item{display:flex;align-items:flex-start;gap:10px;padding:10px 0;border-bottom:1px solid var(--bd);}
.act-item:last-child{border:none;}
.act-av{width:34px;height:34px;border-radius:50%;background:var(--pul);color:var(--pu);
  display:flex;align-items:center;justify-content:center;font-size:13px;font-weight:800;
  flex-shrink:0;overflow:hidden;}
.act-av img{width:100%;height:100%;object-fit:cover;}
.act-name{font-size:13px;font-weight:600;color:var(--tx);}
.act-type{font-size:11px;color:var(--ts);}
.act-time{font-size:10px;color:var(--tm);margin-left:auto;white-space:nowrap;}

/* Progress bar */
.pi{margin-bottom:12px;}
.pi-lbl{display:flex;justify-content:space-between;font-size:12px;font-weight:500;
  color:var(--tx);margin-bottom:5px;}
.pi-track{height:7px;background:var(--bd);border-radius:99px;overflow:hidden;}
.pi-fill{height:7px;border-radius:99px;transition:width 1.1s ease;width:0%;}

/* Radar legend */
.radar-legend{display:flex;flex-wrap:wrap;gap:8px;justify-content:center;margin-top:10px;}
.rl-item{display:flex;align-items:center;gap:5px;font-size:11px;}
.rl-dot{width:10px;height:10px;border-radius:2px;flex-shrink:0;}

/* Empty / spinner */
.empty{text-align:center;padding:40px;color:var(--tm);}
.empty i{font-size:32px;display:block;margin-bottom:10px;opacity:.4;}
.empty p{font-size:13px;}
.spin{display:inline-block;width:20px;height:20px;border:2px solid var(--bd);
  border-top-color:var(--p);border-radius:50%;animation:spin .7s linear infinite;}
@keyframes spin{to{transform:rotate(360deg)}}

/* Responsive */
@media(max-width:1100px){.g21,.g12,.g13{grid-template-columns:1fr;}.g3{grid-template-columns:1fr 1fr;}}
@media(max-width:700px){.g2,.g3{grid-template-columns:1fr;}.kpi-grid{grid-template-columns:1fr 1fr 1fr;}}
@media(max-width:480px){.kpi-grid{grid-template-columns:1fr 1fr;}.tab-btn{font-size:11px;padding:7px 10px;}}
</style>
</asp:Content>

<asp:Content ID="cBody" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

<%-- Server config hidden fields --%>
<asp:HiddenField ID="hdnInstId" runat="server"/>
<asp:HiddenField ID="hdnSessId" runat="server"/>

<%-- Hidden ASP controls for dropdown init --%>
<asp:DropDownList ID="ddlStream"      runat="server" Style="display:none;"/>
<asp:DropDownList ID="ddlSection"     runat="server" Style="display:none;"/>
<asp:DropDownList ID="ddlDesignation" runat="server" Style="display:none;"/>
<asp:DropDownList ID="ddlMonth"       runat="server" Style="display:none;"/>
<asp:DropDownList ID="ddlYear"        runat="server" Style="display:none;"/>
<asp:Label        ID="lblSession"     runat="server" Style="display:none;"/>

<div class="wrap">

<%-- ══════════════ BANNER ══════════════ --%>
<div class="banner">
  <div class="b-particles" id="bParticles"></div>
  <div class="b-ov"></div>
  <div class="b-body">
    <div class="b-left">
      <div class="b-eyebrow"><i class="fa fa-chalkboard-user"></i>Teacher Management</div>
      <div class="b-title">Faculty Analytics Dashboard</div>
      <div class="b-sub">
        Session: <span id="bSession"></span> &nbsp;&bull;&nbsp;
        Real-time performance &amp; activity tracking
      </div>
      <div class="b-stats">
        <div class="bst"><div class="bst-v" id="bTotal">—</div><div class="bst-l">Total Faculty</div></div>
        <div class="b-divider"></div>
        <div class="bst"><div class="bst-v" id="bActive">—</div><div class="bst-l">Active</div></div>
        <div class="b-divider"></div>
        <div class="bst"><div class="bst-v" id="bVideos">—</div><div class="bst-l">Videos</div></div>
        <div class="b-divider"></div>
        <div class="bst"><div class="bst-v" id="bStudents">—</div><div class="bst-l">Students Reached</div></div>
        <div class="b-divider"></div>
        <div class="bst"><div class="bst-v" id="bAvgExp">—</div><div class="bst-l">Avg Exp (yrs)</div></div>
      </div>
    </div>
    <div class="b-right">
      <div class="live-badge"><span class="live-dot"></span>Live Data</div>
      <button class="btn-export" onclick="exportCSV()">
        <i class="fa fa-file-csv"></i>Export CSV
      </button>
      <div class="spin" id="globalSpin" style="display:none;"></div>
    </div>
  </div>
</div>

<%-- ══════════════ FILTER BAR ══════════════ --%>
<div class="filter-bar">
  <div class="fb-header">
    <div class="fb-label"><i class="fa fa-filter"></i>Filters</div>
    <div class="fb-actions">
      <button class="btn-reset" onclick="resetFilters()"><i class="fa fa-rotate"></i>Reset</button>
      <button class="btn-search" onclick="applyFilters(0)"><i class="fa fa-magnifying-glass"></i>Apply</button>
    </div>
  </div>
  <div class="filter-row">
    <div class="fg">
      <label>Stream</label>
      <select id="fStream" class="fsel" onchange="onStreamChange()">
        <option value="0">All Streams</option>
      </select>
    </div>
    <div class="fg">
      <label>Section</label>
      <select id="fSection" class="fsel" onchange="applyFilters(0)">
        <option value="0">All Sections</option>
      </select>
    </div>
    <div class="fg">
      <label>Designation</label>
      <select id="fDesig" class="fsel" onchange="applyFilters(0)">
        <option value="">All</option>
      </select>
    </div>
    <div class="fg">
      <label>Status</label>
      <select id="fStatus" class="fsel" onchange="applyFilters(0)">
        <option value="">All</option>
        <option value="Active">Active</option>
        <option value="Inactive">Inactive</option>
      </select>
    </div>
    <div class="fg">
      <label>Join Month</label>
      <select id="fMonth" class="fsel" onchange="applyFilters(0)">
        <option value="">All Months</option>
        <option value="1">January</option><option value="2">February</option>
        <option value="3">March</option><option value="4">April</option>
        <option value="5">May</option><option value="6">June</option>
        <option value="7">July</option><option value="8">August</option>
        <option value="9">September</option><option value="10">October</option>
        <option value="11">November</option><option value="12">December</option>
      </select>
    </div>
    <div class="fg">
      <label>Year</label>
      <select id="fYear" class="fsel" onchange="applyFilters(0)">
        <option value="">All Years</option>
      </select>
    </div>
    <div class="fg sw-wrap" style="flex:2;min-width:180px;">
      <label>Search</label>
      <div style="position:relative;">
        <i class="fa fa-magnifying-glass" style="position:absolute;left:10px;top:50%;transform:translateY(-50%);color:var(--tm);"></i>
        <input id="fSearch" class="fsel fsearch" type="text"
               placeholder="Name, Employee ID, Designation..."
               onkeydown="if(event.key==='Enter')applyFilters(0)"/>
      </div>
    </div>
  </div>
  <div class="load-bar" id="loadBar"></div>
  <div class="af-chips" id="afChips"></div>
</div>

<%-- ══════════════ KPI CARDS ══════════════ --%>
<div class="kpi-grid">
  <div class="kpi kb">
    <div class="kpi-top"><span class="kpi-lbl">Total Faculty</span><div class="kpi-ico ib"><i class="fa fa-chalkboard-user"></i></div></div>
    <div class="kpi-val" id="kTotal">—</div><div class="kpi-sub">All teachers</div>
  </div>
  <div class="kpi kg">
    <div class="kpi-top"><span class="kpi-lbl">Active</span><div class="kpi-ico ig"><i class="fa fa-circle-check"></i></div></div>
    <div class="kpi-val" id="kActive">—</div><div class="kpi-sub">Currently active</div>
  </div>
  <div class="kpi kr">
    <div class="kpi-top"><span class="kpi-lbl">Inactive</span><div class="kpi-ico ir"><i class="fa fa-circle-xmark"></i></div></div>
    <div class="kpi-val" id="kInactive">—</div><div class="kpi-sub">Deactivated</div>
  </div>
  <div class="kpi kpu">
    <div class="kpi-top"><span class="kpi-lbl">New Joined</span><div class="kpi-ico ipu"><i class="fa fa-user-plus"></i></div></div>
    <div class="kpi-val" id="kNew">—</div><div class="kpi-sub">First login pending</div>
  </div>
  <div class="kpi kvi">
    <div class="kpi-top"><span class="kpi-lbl">Videos</span><div class="kpi-ico ivi"><i class="fa fa-video"></i></div></div>
    <div class="kpi-val" id="kVideos">—</div><div class="kpi-sub">Total uploaded</div>
  </div>
  <div class="kpi kw">
    <div class="kpi-top"><span class="kpi-lbl">Assignments</span><div class="kpi-ico iw"><i class="fa fa-clipboard-list"></i></div></div>
    <div class="kpi-val" id="kAssign">—</div><div class="kpi-sub">Created this session</div>
  </div>
  <div class="kpi kt">
    <div class="kpi-top"><span class="kpi-lbl">Quizzes</span><div class="kpi-ico it"><i class="fa fa-circle-question"></i></div></div>
    <div class="kpi-val" id="kQuizzes">—</div><div class="kpi-sub">Active quizzes</div>
  </div>
  <div class="kpi kor">
    <div class="kpi-top"><span class="kpi-lbl">Subjects Taught</span><div class="kpi-ico ior"><i class="fa fa-book-open"></i></div></div>
    <div class="kpi-val" id="kSubjects">—</div><div class="kpi-sub">Unique subjects</div>
  </div>
  <div class="kpi kcy">
    <div class="kpi-top"><span class="kpi-lbl">Students Reached</span><div class="kpi-ico icy"><i class="fa fa-users"></i></div></div>
    <div class="kpi-val" id="kStudents">—</div><div class="kpi-sub">Across all streams</div>
  </div>
  <div class="kpi kro">
    <div class="kpi-top"><span class="kpi-lbl">Avg Experience</span><div class="kpi-ico iro"><i class="fa fa-star"></i></div></div>
    <div class="kpi-val" id="kAvgExp">—</div><div class="kpi-sub">Years of experience</div>
  </div>
</div>

<%-- ══════════════ TABS ══════════════ --%>
<div class="tab-bar">
  <button class="tab-btn active" onclick="switchTab('overview',this)">
    <i class="fa fa-chart-pie"></i>Overview
  </button>
  <button class="tab-btn" onclick="switchTab('records',this)">
    <i class="fa fa-table"></i>Faculty Records
  </button>
  <button class="tab-btn" onclick="switchTab('performance',this)">
    <i class="fa fa-trophy"></i>Performance
  </button>
  <button class="tab-btn" onclick="switchTab('content',this)">
    <i class="fa fa-play-circle"></i>Content
  </button>
  <button class="tab-btn" onclick="switchTab('activity',this)">
    <i class="fa fa-bell"></i>Activity
  </button>
</div>

<%-- ══════════════ TAB: OVERVIEW ══════════════ --%>
<div id="tab-overview" class="tab-pane active">

  <%-- Row 1: Joining trend + Stream wise --%>
  <div class="g21">
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="c-ico" style="background:var(--pl);color:var(--p);"><i class="fa fa-arrow-trend-up"></i></div>
          <div><div class="c-title">Faculty Joining Trend — Last 12 Months</div>
            <div class="c-sub">New teachers onboarded per month</div></div>
        </div>
        <span id="trendTotalLbl" style="font-size:11px;color:var(--tm);"></span>
      </div>
      <div class="chart-box" style="height:245px;"><canvas id="cTrend"></canvas></div>
    </div>
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="c-ico" style="background:var(--pul);color:var(--pu);"><i class="fa fa-layer-group"></i></div>
          <div><div class="c-title">Faculty by Stream</div></div>
        </div>
      </div>
      <div class="chart-box" style="height:245px;"><canvas id="cStream"></canvas></div>
    </div>
  </div>

  <%-- Row 2: Designation + Experience + Gender --%>
  <div class="g3">
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="c-ico" style="background:var(--wl);color:var(--w);"><i class="fa fa-id-badge"></i></div>
          <div><div class="c-title">By Designation</div></div>
        </div>
      </div>
      <div class="chart-box" style="height:220px;"><canvas id="cDesig"></canvas></div>
    </div>
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="c-ico" style="background:var(--tl);color:var(--t);"><i class="fa fa-star"></i></div>
          <div><div class="c-title">Experience Distribution</div></div>
        </div>
      </div>
      <div class="chart-box" style="height:220px;"><canvas id="cExp"></canvas></div>
    </div>
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="c-ico" style="background:var(--rol);color:var(--ro);"><i class="fa fa-venus-mars"></i></div>
          <div><div class="c-title">Gender Distribution</div></div>
        </div>
      </div>
      <div class="chart-box" style="height:175px;"><canvas id="cGender"></canvas></div>
      <div id="genderLeg" style="display:flex;flex-wrap:wrap;gap:6px;justify-content:center;margin-top:10px;"></div>
    </div>
  </div>

  <%-- Row 3: Qualification + Subject wise --%>
  <div class="g2">
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="c-ico" style="background:var(--gl);color:var(--g);"><i class="fa fa-graduation-cap"></i></div>
          <div><div class="c-title">Qualification Distribution</div>
            <div class="c-sub">Highest qualifications held</div></div>
        </div>
      </div>
      <div class="chart-box" style="height:230px;"><canvas id="cQual"></canvas></div>
    </div>
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="c-ico" style="background:var(--bl);color:var(--b);"><i class="fa fa-book-open"></i></div>
          <div><div class="c-title">Subject-wise Faculty Assignment</div>
            <div class="c-sub">Teachers &amp; content per subject</div></div>
        </div>
      </div>
      <div class="chart-box" style="height:230px;"><canvas id="cSubject"></canvas></div>
    </div>
  </div>

</div>

<%-- ══════════════ TAB: FACULTY RECORDS ══════════════ --%>
<div id="tab-records" class="tab-pane">
  <div class="card">
    <div class="card-hd">
      <div class="card-hd-l">
        <div class="c-ico" style="background:var(--bl);color:var(--b);"><i class="fa fa-table"></i></div>
        <div>
          <div class="c-title">Faculty Records</div>
          <div class="c-sub" id="recCount">Loading…</div>
        </div>
      </div>
    </div>
    <div class="tbl-wrap">
      <table class="ttbl">
        <thead>
          <tr>
            <th>#</th><th>Teacher</th><th>Emp ID</th><th>Stream / Section</th>
            <th>Designation</th><th>Qualification</th><th>Exp</th>
            <th>Gender</th><th>Joined</th>
            <th>Videos</th><th>Assign.</th><th>Quizzes</th>
            <th>Avg Score</th><th>Status</th>
          </tr>
        </thead>
        <tbody id="teacherTbody">
          <tr><td colspan="14" class="empty"><div class="spin"></div></td></tr>
        </tbody>
      </table>
    </div>
    <div class="pag">
      <div class="pag-info" id="pagInfo"></div>
      <div class="pag-btns" id="pagBtns"></div>
    </div>
  </div>
</div>

<%-- ══════════════ TAB: PERFORMANCE ══════════════ --%>
<div id="tab-performance" class="tab-pane">
  <div class="g12">
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="c-ico" style="background:var(--wl);color:var(--w);"><i class="fa fa-medal"></i></div>
          <div><div class="c-title">Top 10 Teachers</div>
            <div class="c-sub">By content output &amp; student performance</div></div>
        </div>
      </div>
      <div id="topTeachersList"><div class="empty"><div class="spin"></div></div></div>
    </div>
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="c-ico" style="background:var(--tl);color:var(--t);"><i class="fa fa-chart-radar"></i></div>
          <div><div class="c-title">Average Performance Metrics</div>
            <div class="c-sub">Per-teacher averages across all dimensions</div></div>
        </div>
      </div>
      <div class="chart-box" style="height:300px;"><canvas id="cRadar"></canvas></div>
      <div class="radar-legend" id="radarLeg"></div>
    </div>
  </div>

  <%-- Content output trend --%>
  <div class="card" style="margin-bottom:18px;">
    <div class="card-hd">
      <div class="card-hd-l">
        <div class="c-ico" style="background:var(--vi);color:#fff;"><i class="fa fa-play-circle"></i></div>
        <div><div class="c-title">Weekly Content Output — Last 8 Weeks</div>
          <div class="c-sub">Videos · Assignments · Quizzes created per week</div></div>
      </div>
    </div>
    <div class="chart-box" style="height:230px;"><canvas id="cContent"></canvas></div>
  </div>
</div>

<%-- ══════════════ TAB: CONTENT ══════════════ --%>
<div id="tab-content" class="tab-pane">
  <div class="g2">
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="c-ico" style="background:var(--pul);color:var(--pu);"><i class="fa fa-video"></i></div>
          <div><div class="c-title">Content by Subject</div>
            <div class="c-sub">Videos &amp; assignments per subject</div></div>
        </div>
      </div>
      <div class="chart-box" style="height:280px;"><canvas id="cSubjectContent"></canvas></div>
    </div>
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="c-ico" style="background:var(--wl);color:var(--w);"><i class="fa fa-chart-bar"></i></div>
          <div><div class="c-title">Top Teachers by Activity</div>
            <div class="c-sub">Videos + Assignments + Quizzes</div></div>
        </div>
      </div>
      <div id="contentBars" style="padding-top:6px;"></div>
    </div>
  </div>
</div>

<%-- ══════════════ TAB: ACTIVITY ══════════════ --%>
<div id="tab-activity" class="tab-pane">
  <div class="g21">
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="c-ico" style="background:var(--gl);color:var(--g);"><i class="fa fa-bell"></i></div>
          <div><div class="c-title">Recent Faculty Activity</div>
            <div class="c-sub">Latest actions from teachers</div></div>
        </div>
        <button class="btn-search" style="font-size:11px;padding:5px 12px;"
                onclick="applyFilters(0)">
          <i class="fa fa-rotate"></i> Refresh
        </button>
      </div>
      <div id="activityFeed"><div class="empty"><div class="spin"></div></div></div>
    </div>
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="c-ico" style="background:var(--bl);color:var(--b);"><i class="fa fa-chart-pie"></i></div>
          <div><div class="c-title">Gender &amp; Stream Split</div></div>
        </div>
      </div>
      <div class="chart-box" style="height:200px;margin-bottom:16px;"><canvas id="cGender2"></canvas></div>
      <hr style="border:none;border-top:1px solid var(--bd);margin-bottom:16px;"/>
      <div class="c-title" style="font-size:13px;margin-bottom:12px;">Stream Distribution</div>
      <div id="streamBars"></div>
    </div>
  </div>
</div>

</div><%-- /wrap --%>

<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.4.1/chart.umd.min.js"></script>
<script>
(function(){
'use strict';

/* ══════════════════════════════════════════════════════
   GLOBALS
══════════════════════════════════════════════════════ */
const INST  = document.getElementById('<%= hdnInstId.ClientID %>').value;
const SESS  = document.getElementById('<%= hdnSessId.ClientID %>').value;
const SNAME = document.getElementById('<%= lblSession.ClientID %>').innerText.trim();
document.getElementById('bSession').innerText  = SNAME;

const PAL  = ['#4f46e5','#10b981','#f59e0b','#ef4444','#8b5cf6','#3b82f6',
              '#0d9488','#f43f5e','#0891b2','#ea580c','#7c3aed','#84cc16'];
const GRD  = { color:'rgba(148,163,184,.12)' };
const TICK = { font:{ size:11, family:"'Inter','Segoe UI',sans-serif" } };
const TT   = { padding:10, cornerRadius:8, bodyFont:{size:12}, titleFont:{size:12,weight:'bold'} };
const ANIM = { duration:950, easing:'easeInOutQuart' };
const noL  = { legend:{display:false} };

let charts = {}, currentPage=0, totalPages=1, debounceT=null, lastData=null;

/* Particles */
(function(){
  const c = document.getElementById('bParticles');
  for(let i=0;i<12;i++){
    const d=document.createElement('div');
    const sz=Math.random()*40+10;
    d.className='b-particle';
    d.style.cssText=`width:${sz}px;height:${sz}px;left:${Math.random()*100}%;`
      +`animation-duration:${Math.random()*6+4}s;animation-delay:${Math.random()*4}s;`
      +`bottom:-${sz}px;`;
    c.appendChild(d);
  }
})();

/* Year dropdown */
(function(){
  const el=document.getElementById('fYear');
  const cur=new Date().getFullYear();
  for(let y=cur;y>=cur-5;y--){
    const o=document.createElement('option');o.value=y;o.text=y;el.appendChild(o);
  }
})();

/* ══════════════════════════════════════════════════════
   FILTER HELPERS
══════════════════════════════════════════════════════ */
function F(){ return {
  stream:  document.getElementById('fStream').value,
  section: document.getElementById('fSection').value,
  desig:   document.getElementById('fDesig').value,
  status:  document.getElementById('fStatus').value,
  month:   document.getElementById('fMonth').value,
  year:    document.getElementById('fYear').value,
  search:  document.getElementById('fSearch').value.trim()
};}

window.resetFilters = function(){
  ['fStream','fSection'].forEach(id=>document.getElementById(id).value='0');
  ['fDesig','fStatus','fMonth','fYear'].forEach(id=>document.getElementById(id).value='');
  document.getElementById('fSearch').value='';
  document.getElementById('afChips').innerHTML='';
  applyFilters(0);
};

window.applyFilters = function(page){
  currentPage = page||0;
  clearTimeout(debounceT);
  debounceT = setTimeout(()=>fetch_data(currentPage), 280);
};

window.onStreamChange = function(){
  const sid = document.getElementById('fStream').value;
  fetch(buildURL(0,{stream:sid}))
    .then(r=>r.json())
    .then(d=>{
      const sel=document.getElementById('fSection');
      // Reload sections if needed (optional cascade)
    });
  applyFilters(0);
};

function buildURL(page, extra){
  const f=F();
  let u=`${location.pathname}?ajax=1&inst=${INST}&sess=${SESS}`
      +`&stream=${f.stream}&section=${f.section}`
      +`&desig=${encodeURIComponent(f.desig)}`
      +`&month=${f.month}&year=${f.year}`
      +`&search=${encodeURIComponent(f.search)}`
      +`&page=${page||0}`;
  if(extra)Object.keys(extra).forEach(k=>u+=`&${k}=${extra[k]}`);
  return u;
}

function updateChips(){
  const f=F();
  const names={stream:'fStream',section:'fSection',desig:'fDesig',status:'fStatus',month:'fMonth',year:'fYear'};
  const wrap=document.getElementById('afChips');
  wrap.innerHTML='';
  Object.keys(names).forEach(k=>{
    const el=document.getElementById(names[k]);
    const v=el.value;
    if(!v||v==='0') return;
    const t=el.options[el.selectedIndex]?.text||v;
    wrap.innerHTML+=`<span class="af-chip" onclick="clearF('${names[k]}')">
        ${t} <i class="fa fa-xmark"></i></span>`;
  });
  if(f.search)
    wrap.innerHTML+=`<span class="af-chip" onclick="clearF('fSearch')">"${f.search}" <i class="fa fa-xmark"></i></span>`;
}

window.clearF=function(id){
  const el=document.getElementById(id);
  if(el.tagName==='SELECT') el.value=id==='fStream'||id==='fSection'?'0':'';
  else el.value='';
  applyFilters(0);
};

/* ══════════════════════════════════════════════════════
   MAIN FETCH
══════════════════════════════════════════════════════ */
function fetch_data(page){
  setLoading(true);
  updateChips();
  fetch(buildURL(page))
    .then(r=>{ if(!r.ok) throw new Error('HTTP '+r.status); return r.json(); })
    .then(d=>{
      lastData=d;
      renderKPIs(d.kpi);
      renderAllCharts(d);
      renderTable(d);
      renderTopTeachers(d.topTeachers);
      renderActivity(d.recentActivity);
      renderContentBars(d.topTeachers);
      setLoading(false);
    })
    .catch(err=>{ setLoading(false); console.error(err); });
}

function setLoading(on){
  const bar=document.getElementById('loadBar');
  const sp=document.getElementById('globalSpin');
  bar.style.width=on?'80%':'100%';
  sp.style.display=on?'inline-block':'none';
  if(!on) setTimeout(()=>bar.style.width='0%',600);
}

/* ══════════════════════════════════════════════════════
   KPI RENDER
══════════════════════════════════════════════════════ */
function renderKPIs(k){
  if(!k) return;
  countUp('kTotal',    k.total     ||0);
  countUp('kActive',   k.active    ||0);
  countUp('kInactive', k.inactive  ||0);
  countUp('kNew',      k.newJoined ||0);
  countUp('kVideos',   k.videos    ||0);
  countUp('kAssign',   k.assignments||0);
  countUp('kQuizzes',  k.quizzes   ||0);
  countUp('kSubjects', k.subjects  ||0);
  countUp('kStudents', k.students  ||0);
  document.getElementById('kAvgExp').innerText = parseFloat(k.avgExp||0).toFixed(1);

  // Banner stats
  document.getElementById('bTotal').innerText    = k.total    ||0;
  document.getElementById('bActive').innerText   = k.active   ||0;
  document.getElementById('bVideos').innerText   = k.videos   ||0;
  document.getElementById('bStudents').innerText = k.students ||0;
  document.getElementById('bAvgExp').innerText   = parseFloat(k.avgExp||0).toFixed(1);
}

function countUp(id,target){
  const el=document.getElementById(id);
  if(!el) return;
  const start=parseInt(el.innerText)||0;
  const diff=target-start, steps=28;
  let i=0;
  const iv=setInterval(()=>{
    i++;
    el.innerText=Math.round(start+diff*(i/steps));
    if(i>=steps){el.innerText=target;clearInterval(iv);}
  },18);
}

/* ══════════════════════════════════════════════════════
   CHART HELPERS
══════════════════════════════════════════════════════ */
function dc(k){ if(charts[k]){charts[k].destroy();charts[k]=null;} }
function gV(ctx,h,c1,c2){ const g=ctx.createLinearGradient(0,0,0,h);g.addColorStop(0,c1);g.addColorStop(1,c2);return g; }
function noData(id,msg){
  const el=document.getElementById(id);
  if(!el) return;
  const box=el.closest('.chart-box');
  if(box) box.innerHTML=`<div class="empty"><i class="fa fa-chart-simple"></i><p>${msg||'No data'}</p></div>`;
}
const palA=a=>PAL.map(c=>c+Math.round(a*255).toString(16).padStart(2,'0'));

/* ══════════════════════════════════════════════════════
   ALL CHARTS
══════════════════════════════════════════════════════ */
function renderAllCharts(d){
  renderTrend(d.joiningTrend);
  renderStream(d.streamWise);
  renderDesig(d.designation);
  renderExp(d.experience);
  renderGender(d.gender,'cGender','genderLeg');
  renderGender(d.gender,'cGender2',null);
  renderQual(d.qualification);
  renderSubjectChart(d.subjectWise);
  renderSubjectContent(d.subjectWise);
  renderContentTrend(d.contentTrend);
  renderRadar(d.perfMetrics);
  renderStreamBars(d.streamWise);
}

// 1. Joining trend
function renderTrend(data){
  dc('trend');
  if(!data?.length){noData('cTrend','No joining data');return;}
  const ctx=document.getElementById('cTrend')?.getContext('2d');
  if(!ctx) return;
  const grad=gV(ctx,230,'rgba(79,70,229,.28)','rgba(79,70,229,.01)');
  const total=data.reduce((a,b)=>a+(b.Teachers||0),0);
  const el=document.getElementById('trendTotalLbl');
  if(el) el.innerText=total+' total';
  charts.trend=new Chart(ctx,{type:'line',data:{
    labels:data.map(r=>r.Mon),
    datasets:[{label:'New Faculty',data:data.map(r=>r.Teachers||0),
      borderColor:'#4f46e5',backgroundColor:grad,borderWidth:2.5,tension:.42,fill:true,
      pointRadius:5,pointHoverRadius:8,pointBackgroundColor:'#4f46e5',
      pointHoverBackgroundColor:'#fff',pointHoverBorderColor:'#4f46e5',pointHoverBorderWidth:2}]
  },options:{responsive:true,maintainAspectRatio:false,
    plugins:{...noL,tooltip:{...TT,callbacks:{label:c=>' '+c.raw+' teachers'}}},
    scales:{x:{grid:{display:false},ticks:TICK},y:{beginAtZero:true,grid:GRD,ticks:TICK}},
    animation:ANIM}});
}

// 2. Stream horizontal bar
function renderStream(data){
  dc('stream');
  if(!data?.length){noData('cStream','No stream data');return;}
  const el=document.getElementById('cStream');
  if(!el) return;
  charts.stream=new Chart(el,{type:'bar',data:{
    labels:data.map(r=>r.StreamName),
    datasets:[{label:'Teachers',data:data.map(r=>r.Teachers||0),
      backgroundColor:palA(.82),borderRadius:6,borderSkipped:false}]
  },options:{indexAxis:'y',responsive:true,maintainAspectRatio:false,
    plugins:{...noL,tooltip:TT},
    scales:{x:{beginAtZero:true,grid:GRD,ticks:TICK},y:{grid:{display:false},ticks:{font:{size:11}}}},
    animation:ANIM}});
}

// 3. Designation doughnut
function renderDesig(data){
  dc('desig');
  if(!data?.length){noData('cDesig','No designation data');return;}
  const el=document.getElementById('cDesig');
  if(!el) return;
  charts.desig=new Chart(el,{type:'doughnut',data:{
    labels:data.map(r=>r.Designation),
    datasets:[{data:data.map(r=>r.Teachers||0),
      backgroundColor:palA(.85),borderWidth:2,borderColor:'#fff',hoverOffset:8}]
  },options:{cutout:'58%',responsive:true,maintainAspectRatio:false,
    plugins:{legend:{position:'right',labels:{boxWidth:10,font:{size:11}}},tooltip:TT},
    animation:{animateRotate:true,duration:1100}}});
}

// 4. Experience bar
function renderExp(data){
  dc('exp');
  if(!data?.length){noData('cExp','No experience data');return;}
  const el=document.getElementById('cExp');
  if(!el) return;
  charts.exp=new Chart(el,{type:'bar',data:{
    labels:data.map(r=>r.ExpBucket),
    datasets:[{label:'Teachers',data:data.map(r=>r.Teachers||0),
      backgroundColor:['#dbeafe','#bfdbfe','#93c5fd','#60a5fa','#3b82f6'],
      borderRadius:6}]
  },options:{responsive:true,maintainAspectRatio:false,
    plugins:{...noL,tooltip:TT},
    scales:{x:{grid:{display:false},ticks:TICK},y:{beginAtZero:true,grid:GRD,ticks:TICK}},
    animation:ANIM}});
}

// 5. Gender doughnut
function renderGender(data,canvasId,legId){
  const key='gender_'+canvasId; dc(key);
  if(!data?.length){noData(canvasId,'No gender data');return;}
  const el=document.getElementById(canvasId);
  if(!el) return;
  const GCOL=['#4f46e5','#f43f5e','#10b981','#f59e0b'];
  charts[key]=new Chart(el,{type:'doughnut',data:{
    labels:data.map(r=>r.Gender),
    datasets:[{data:data.map(r=>r.Total||0),backgroundColor:GCOL,borderWidth:3,borderColor:'#fff',hoverOffset:10}]
  },options:{cutout:'65%',responsive:true,maintainAspectRatio:false,
    plugins:{legend:{display:false},tooltip:TT},
    animation:{animateRotate:true,duration:1100}}});
  if(legId){
    const leg=document.getElementById(legId); if(!leg) return;
    leg.innerHTML='';
    const tot=data.reduce((a,b)=>a+(b.Total||0),0)||1;
    data.forEach((r,i)=>{
      leg.innerHTML+=`<div style="display:flex;align-items:center;gap:5px;font-size:12px;">
        <span style="width:10px;height:10px;border-radius:2px;background:${GCOL[i]};display:inline-block;flex-shrink:0;"></span>
        ${r.Gender} <strong style="color:${GCOL[i]};">${Math.round((r.Total||0)/tot*100)}%</strong></div>`;
    });
  }
}

// 6. Qualification polar
function renderQual(data){
  dc('qual');
  if(!data?.length){noData('cQual','No qualification data');return;}
  const el=document.getElementById('cQual');
  if(!el) return;
  charts.qual=new Chart(el,{type:'polarArea',data:{
    labels:data.map(r=>r.Qualification),
    datasets:[{data:data.map(r=>r.Teachers||0),backgroundColor:palA(.72),borderColor:'#fff',borderWidth:2}]
  },options:{responsive:true,maintainAspectRatio:false,
    plugins:{legend:{position:'right',labels:{boxWidth:10,font:{size:10}}},tooltip:TT},
    scales:{r:{beginAtZero:true,ticks:{font:{size:9}},grid:{color:'rgba(148,163,184,.2)'}}},
    animation:{duration:1100,easing:'easeInOutBack'}}});
}

// 7. Subject-wise teacher bar
function renderSubjectChart(data){
  dc('subj');
  if(!data?.length){noData('cSubject','No subject data');return;}
  const el=document.getElementById('cSubject');
  if(!el) return;
  const short=data.map(r=>(r.SubjectName||'').length>14?r.SubjectName.substring(0,13)+'…':r.SubjectName);
  charts.subj=new Chart(el,{type:'bar',data:{
    labels:short,
    datasets:[
      {label:'Teachers',data:data.map(r=>r.Teachers||0),backgroundColor:'rgba(79,70,229,.82)',borderRadius:5},
      {label:'Videos',  data:data.map(r=>r.Videos||0),  backgroundColor:'rgba(139,92,246,.72)',borderRadius:5},
      {label:'Assigns', data:data.map(r=>r.Assignments||0),backgroundColor:'rgba(245,158,11,.72)',borderRadius:5}
    ]
  },options:{responsive:true,maintainAspectRatio:false,
    plugins:{legend:{position:'top',labels:{boxWidth:10,font:{size:11}}},tooltip:TT},
    scales:{x:{grid:{display:false},ticks:{font:{size:10}}},y:{beginAtZero:true,grid:GRD,ticks:TICK}},
    animation:ANIM}});
}

// 8. Content output trend stacked
function renderContentTrend(data){
  dc('content');
  if(!data?.length){noData('cContent','No content data');return;}
  const el=document.getElementById('cContent');
  if(!el) return;
  charts.content=new Chart(el,{type:'bar',data:{
    labels:data.map(r=>r.WeekLabel),
    datasets:[
      {label:'Videos',      data:data.map(r=>r.Videos||0),      backgroundColor:'rgba(124,58,237,.85)',  borderRadius:4,stack:'s'},
      {label:'Assignments', data:data.map(r=>r.Assignments||0),  backgroundColor:'rgba(245,158,11,.85)',  borderRadius:4,stack:'s'},
      {label:'Quizzes',     data:data.map(r=>r.Quizzes||0),      backgroundColor:'rgba(16,185,129,.85)',  borderRadius:4,stack:'s'}
    ]
  },options:{responsive:true,maintainAspectRatio:false,
    interaction:{mode:'index',intersect:false},
    plugins:{legend:{position:'top',labels:{boxWidth:10,font:{size:11}}},tooltip:TT},
    scales:{x:{grid:{display:false},ticks:TICK,stacked:true},y:{grid:GRD,ticks:TICK,stacked:true}},
    animation:ANIM}});
}

// 9. Subject content (tab: content)
function renderSubjectContent(data){
  dc('subjc');
  if(!data?.length){noData('cSubjectContent','No subject data');return;}
  const el=document.getElementById('cSubjectContent');
  if(!el) return;
  const short=data.map(r=>(r.SubjectName||'').length>14?r.SubjectName.substring(0,13)+'…':r.SubjectName);
  charts.subjc=new Chart(el,{type:'bar',data:{
    labels:short,
    datasets:[
      {label:'Videos',  data:data.map(r=>r.Videos||0),      backgroundColor:'rgba(124,58,237,.85)',borderRadius:5},
      {label:'Assignments',data:data.map(r=>r.Assignments||0),backgroundColor:'rgba(245,158,11,.85)',borderRadius:5}
    ]
  },options:{responsive:true,maintainAspectRatio:false,
    plugins:{legend:{position:'top',labels:{boxWidth:10,font:{size:11}}},tooltip:TT},
    scales:{x:{grid:{display:false},ticks:{font:{size:10}}},y:{beginAtZero:true,grid:GRD,ticks:TICK}},
    animation:ANIM}});
}

// 10. Performance radar
function renderRadar(m){
  dc('radar');
  if(!m){noData('cRadar','No metrics data');return;}
  const el=document.getElementById('cRadar');
  if(!el) return;
  const labels=['Avg Videos','Avg Assigns','Avg Quizzes','Avg Students','Avg Views','Avg Score'];
  const vals=[
    parseFloat(m.avgVideos)||0,
    parseFloat(m.avgAssignments)||0,
    parseFloat(m.avgQuizzes)||0,
    parseFloat(m.avgStudents)||0,
    parseFloat(m.avgVideoViews)||0,
    parseFloat(m.avgScore)||0
  ];
  charts.radar=new Chart(el,{type:'radar',data:{
    labels,
    datasets:[{label:'Avg per Teacher',data:vals,
      backgroundColor:'rgba(79,70,229,.18)',borderColor:'#4f46e5',
      borderWidth:2.5,pointBackgroundColor:'#4f46e5',pointRadius:5,pointHoverRadius:7}]
  },options:{responsive:true,maintainAspectRatio:false,
    plugins:{legend:{display:false},tooltip:TT},
    scales:{r:{beginAtZero:true,ticks:{font:{size:9}},grid:{color:'rgba(148,163,184,.2)'},
      pointLabels:{font:{size:11}}}},
    animation:{duration:1100,easing:'easeInOutBack'}}});
  const leg=document.getElementById('radarLeg');
  if(leg){
    leg.innerHTML='';
    labels.forEach((l,i)=>{
      leg.innerHTML+=`<div class="rl-item"><div class="rl-dot" style="background:${PAL[i]};"></div>${l}: <strong>${vals[i].toFixed(1)}</strong></div>`;
    });
  }
}

// 11. Stream progress bars
function renderStreamBars(data){
  const wrap=document.getElementById('streamBars'); if(!wrap) return;
  wrap.innerHTML='';
  if(!data?.length){wrap.innerHTML="<div class='empty'><i class='fa fa-layer-group'></i><p>No data</p></div>";return;}
  const max=Math.max(...data.map(r=>r.Teachers||0))||1;
  data.forEach((r,i)=>{
    const pct=Math.round((r.Teachers||0)/max*100);
    wrap.innerHTML+=`<div class="pi">
      <div class="pi-lbl"><span>${r.StreamName}</span><span>${r.Teachers||0} teachers</span></div>
      <div class="pi-track"><div class="pi-fill" data-w="${pct}%" style="background:${PAL[i%PAL.length]};"></div></div></div>`;
  });
  setTimeout(()=>document.querySelectorAll('.pi-fill[data-w]').forEach(el=>el.style.width=el.dataset.w),300);
}

/* ══════════════════════════════════════════════════════
   TEACHER TABLE
══════════════════════════════════════════════════════ */
function renderTable(d){
  const tbody=document.getElementById('teacherTbody');
  const pagInfo=document.getElementById('pagInfo');
  const pagBtns=document.getElementById('pagBtns');
  const recLbl =document.getElementById('recCount');

  if(!d.teachers?.length){
    tbody.innerHTML=`<tr><td colspan="14"><div class="empty"><i class="fa fa-chalkboard-user"></i><p>No teachers match the filters</p></div></td></tr>`;
    pagInfo.innerText=''; pagBtns.innerHTML=''; recLbl.innerText='0 records';
    return;
  }
  totalPages=d.pageCount||1; currentPage=d.pageIndex||0;
  const skip=currentPage*d.pageSize;
  recLbl.innerText=`${d.totalCount} teachers found`;

  let html='';
  d.teachers.forEach((t,i)=>{
    const score=parseFloat(t.AvgStudentScore)||0;
    const init=(t.FullName||'?').substring(0,1).toUpperCase();
    const img=t.ProfileImage?`<img src="${t.ProfileImage}" alt=""/>`:init;
    const sc=score>=70?'ga':score>=50?'gb':score>=33?'gc':'gf';
    html+=`<tr>
      <td style="color:var(--tm);font-size:11px;">${skip+i+1}</td>
      <td>
        <div style="display:flex;align-items:center;gap:8px;">
          <div class="tav">${img}</div>
          <div>
            <div class="t-name">${esc(t.FullName||'')}</div>
            <div class="t-emp">${esc(t.TeacherEmail||'')}</div>
          </div>
        </div>
      </td>
      <td style="font-size:12px;font-weight:600;">${esc(t.EmployeeId||'—')}</td>
      <td>
        <div style="font-size:12px;font-weight:600;">${esc(t.StreamName||'—')}</div>
        <div style="font-size:11px;color:var(--ts);">${esc(t.SectionName||'—')}</div>
      </td>
      <td style="font-size:12px;">${esc(t.Designation||'—')}</td>
      <td style="font-size:11px;color:var(--ts);">${esc(t.Qualification||'—')}</td>
      <td style="font-size:12px;font-weight:700;color:var(--p);">${t.ExperienceYears||0} yrs</td>
      <td style="font-size:12px;">${esc(t.Gender||'—')}</td>
      <td style="font-size:11px;color:var(--ts);">${esc(t.JoinedDate||'—')}</td>
      <td><span class="act-chip ac-v"><i class="fa fa-video"></i>${t.VideoCount||0}</span></td>
      <td><span class="act-chip ac-a"><i class="fa fa-clipboard"></i>${t.AssignCount||0}</span></td>
      <td><span class="act-chip ac-q"><i class="fa fa-circle-question"></i>${t.QuizCount||0}</span></td>
      <td>
        <span style="padding:2px 8px;border-radius:99px;font-size:11px;font-weight:800;"
          class="${sc}">${score}</span>
      </td>
      <td>
        <span class="status-pill ${t.Status==='Active'?'sp-a':'sp-i'}">${t.Status||'—'}</span>
        ${t.JoinType==='New'?'<span class="status-pill sp-n" style="margin-left:3px;">New</span>':''}
      </td>
    </tr>`;
  });
  tbody.innerHTML=html;

  // Pagination
  pagInfo.innerText=`Showing ${skip+1}–${Math.min(skip+d.pageSize,d.totalCount)} of ${d.totalCount}`;
  let btns=`<button class="pbtn" onclick="applyFilters(${currentPage-1})" ${currentPage===0?'disabled':''}>
    <i class="fa fa-chevron-left"></i></button>`;
  const st=Math.max(0,currentPage-2), en=Math.min(totalPages-1,st+4);
  for(let p=st;p<=en;p++)
    btns+=`<button class="pbtn ${p===currentPage?'act':''}" onclick="applyFilters(${p})">${p+1}</button>`;
  btns+=`<button class="pbtn" onclick="applyFilters(${currentPage+1})" ${currentPage>=totalPages-1?'disabled':''}>
    <i class="fa fa-chevron-right"></i></button>`;
  pagBtns.innerHTML=btns;
}

/* ══════════════════════════════════════════════════════
   TOP TEACHERS LIST
══════════════════════════════════════════════════════ */
function renderTopTeachers(data){
  const wrap=document.getElementById('topTeachersList'); if(!wrap) return;
  if(!data?.length){wrap.innerHTML="<div class='empty'><i class='fa fa-chalkboard-user'></i><p>No data</p></div>";return;}
  let html='';
  data.forEach((t,i)=>{
    const init=(t.FullName||'?').substring(0,1).toUpperCase();
    const img=t.ProfileImage?`<img src="${t.ProfileImage}" alt=""/>`:init;
    const rank=i<3?`r${i+1}`:'rn';
    const act=(t.TotalActivity||0);
    html+=`<div class="ti">
      <div class="ti-rank ${rank}">${i+1}</div>
      <div class="ti-av">${img}</div>
      <div style="flex:1;min-width:0;">
        <div class="ti-name">${esc(t.FullName||'')}</div>
        <div class="ti-des">${esc(t.Designation||'Teacher')} &bull; ${esc(t.StreamName||'—')} &bull; ${t.ExperienceYears||0} yrs</div>
        <div class="ti-chips">
          <span class="act-chip ac-v"><i class="fa fa-video"></i>${t.Videos||0}</span>
          <span class="act-chip ac-a"><i class="fa fa-clipboard"></i>${t.Assignments||0}</span>
          <span class="act-chip ac-q"><i class="fa fa-circle-question"></i>${t.Quizzes||0}</span>
          <span class="act-chip ac-s"><i class="fa fa-users"></i>${t.StudentsReached||0}</span>
        </div>
      </div>
      <div class="ti-right">
        <div class="ti-score">${act} acts</div>
        <div class="ti-sub">Avg student: ${t.AvgStudentScore||0}</div>
        <div class="ti-sub">${t.VideoViews||0} views</div>
      </div>
    </div>`;
  });
  wrap.innerHTML=html;
}

/* ══════════════════════════════════════════════════════
   CONTENT PROGRESS BARS
══════════════════════════════════════════════════════ */
function renderContentBars(data){
  const wrap=document.getElementById('contentBars'); if(!wrap) return;
  wrap.innerHTML='';
  if(!data?.length){wrap.innerHTML="<div class='empty'><i class='fa fa-video'></i><p>No data</p></div>";return;}
  const top=data.slice(0,8);
  const max=Math.max(...top.map(t=>t.TotalActivity||0))||1;
  top.forEach((t,i)=>{
    const pct=Math.round((t.TotalActivity||0)/max*100);
    const name=(t.FullName||'').length>20?t.FullName.substring(0,19)+'…':t.FullName;
    wrap.innerHTML+=`<div class="pi">
      <div class="pi-lbl"><span title="${t.FullName}">${name}</span><span>${t.TotalActivity||0} activities</span></div>
      <div class="pi-track"><div class="pi-fill" data-w="${pct}%" style="background:${PAL[i%PAL.length]};"></div></div></div>`;
  });
  setTimeout(()=>document.querySelectorAll('.pi-fill[data-w]').forEach(el=>el.style.width=el.dataset.w),300);
}

/* ══════════════════════════════════════════════════════
   ACTIVITY FEED
══════════════════════════════════════════════════════ */
function renderActivity(data){
  const wrap=document.getElementById('activityFeed'); if(!wrap) return;
  if(!data?.length){
    wrap.innerHTML="<div class='empty'><i class='fa fa-bell'></i><p>No recent activity</p></div>";
    return;
  }
  let html='';
  data.forEach(a=>{
    const init=(a.FullName||'?').substring(0,1).toUpperCase();
    const img=a.ProfileImage?`<img src="${a.ProfileImage}" alt=""/>`:init;
    const time=a.ActionTime?new Date(a.ActionTime).toLocaleString('en-IN',{day:'2-digit',month:'short',hour:'2-digit',minute:'2-digit'}):'—';
    html+=`<div class="act-item">
      <div class="act-av">${img}</div>
      <div style="flex:1;min-width:0;">
        <div class="act-name">${esc(a.FullName||'')}</div>
        <div class="act-type">${esc(a.ActivityType||'—')} &bull; ${esc(a.Designation||'Teacher')}</div>
      </div>
      <div class="act-time">${time}</div>
    </div>`;
  });
  wrap.innerHTML=html;
}

/* ══════════════════════════════════════════════════════
   TABS
══════════════════════════════════════════════════════ */
window.switchTab=function(name,btn){
  document.querySelectorAll('.tab-pane').forEach(p=>p.classList.remove('active'));
  document.querySelectorAll('.tab-btn').forEach(b=>b.classList.remove('active'));
  document.getElementById('tab-'+name)?.classList.add('active');
  btn.classList.add('active');
};

/* ══════════════════════════════════════════════════════
   CSV EXPORT
══════════════════════════════════════════════════════ */
window.exportCSV=function(){
  if(!lastData?.teachers?.length){alert('No data to export');return;}
  const H=['Name','EmpID','Stream','Section','Designation','Qualification','Exp','Gender',
           'Joined','Videos','Assignments','Quizzes','AvgStudentScore','Status'];
  const R=lastData.teachers.map(t=>[
    t.FullName,t.EmployeeId,t.StreamName,t.SectionName,t.Designation,
    t.Qualification,t.ExperienceYears,t.Gender,t.JoinedDate,
    t.VideoCount,t.AssignCount,t.QuizCount,t.AvgStudentScore,t.Status
  ].map(v=>`"${(v||'').toString().replace(/"/g,'""')}"`));
  const csv=[H,...R].map(r=>r.join(',')).join('\n');
  const a=document.createElement('a');
  a.href='data:text/csv;charset=utf-8,'+encodeURIComponent(csv);
  a.download=`teachers_${new Date().toISOString().slice(0,10)}.csv`;
  a.click();
};

/* ══════════════════════════════════════════════════════
   UTILITY
══════════════════════════════════════════════════════ */
function esc(s){
  return String(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;')
    .replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

/* ══════════════════════════════════════════════════════
   LIVE SEARCH + DROPDOWN EVENTS
══════════════════════════════════════════════════════ */
document.getElementById('fSearch').addEventListener('input',function(){
  clearTimeout(debounceT);
  debounceT=setTimeout(()=>applyFilters(0),450);
});

/* ══════════════════════════════════════════════════════
   INIT — copy server-rendered ASP dropdown options to JS controls
══════════════════════════════════════════════════════ */
(function(){
  const map={
    '<%= ddlStream.ClientID %>':      'fStream',
    '<%= ddlSection.ClientID %>':     'fSection',
    '<%= ddlDesignation.ClientID %>': 'fDesig',
    '<%= ddlMonth.ClientID %>':       'fMonth',
    '<%= ddlYear.ClientID %>':        'fYear'
  };
  Object.keys(map).forEach(aspId=>{
    const asp=document.getElementById(aspId);
    const js =document.getElementById(map[aspId]);
    if(!asp||!js) return;
    Array.from(asp.options).forEach(o=>{
      if(!o.value||o.value==='0'||o.value==='') return;
      if(js.querySelector(`option[value="${o.value}"]`)) return;
      const n=document.createElement('option');
      n.value=o.value; n.text=o.text; js.appendChild(n);
    });
  });
  // Initial data load
  applyFilters(0);
})();

})();
</script>
</asp:Content>
