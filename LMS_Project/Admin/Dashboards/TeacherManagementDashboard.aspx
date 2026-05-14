<%@ Page Title="Teacher Management Dashboard" Language="C#"
    MasterPageFile="~/Admin/AdminMaster.Master"
    AutoEventWireup="true"
    CodeBehind="TeacherManagementDashboard.aspx.cs"
    Inherits="LearningManagementSystem.Admin.TeacherManagementDashboard" %>

<asp:Content ID="cHead" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet"/>
<style>
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
  --sh:0 1px 3px rgba(0,0,0,.06);--shm:0 4px 16px rgba(0,0,0,.09);
}
*{box-sizing:border-box;margin:0;padding:0;}
body{background:var(--pg);font-family:'Inter','Segoe UI',system-ui,sans-serif;color:var(--tx);}
.wrap{padding:22px;}

/* Banner */
.banner{position:relative;border-radius:var(--rad);overflow:hidden;margin-bottom:20px;
  min-height:165px;box-shadow:var(--shm);
  background:linear-gradient(135deg,#1a1060 0%,#3d2db0 40%,#6d3dc8 75%,#9b59d4 100%);}
.b-particles{position:absolute;inset:0;overflow:hidden;z-index:0;}
.bp{position:absolute;border-radius:50%;background:rgba(255,255,255,.08);
  animation:bfloat linear infinite;}
@keyframes bfloat{0%{transform:translateY(100%) scale(1);opacity:0}10%{opacity:1}
  90%{opacity:.6}100%{transform:translateY(-120px) scale(1.2);opacity:0}}
.b-ov{position:absolute;inset:0;
  background:linear-gradient(100deg,rgba(10,6,55,.72),rgba(10,6,55,.18));z-index:1;}
.b-body{position:relative;z-index:2;display:flex;align-items:center;
  justify-content:space-between;padding:26px 36px;gap:20px;flex-wrap:wrap;}
.b-eyebrow{font-size:11px;font-weight:700;color:rgba(255,255,255,.55);
  text-transform:uppercase;letter-spacing:.1em;margin-bottom:6px;
  display:flex;align-items:center;gap:6px;}
.b-title{font-size:24px;font-weight:800;color:#fff;line-height:1.2;margin-bottom:4px;}
.b-sub{font-size:13px;color:rgba(255,255,255,.68);}
.b-stats{display:flex;gap:20px;margin-top:16px;flex-wrap:wrap;}
.bst{text-align:center;}
.bst-v{font-size:22px;font-weight:900;color:#fff;line-height:1;transition:all .5s;}
.bst-l{font-size:9px;color:rgba(255,255,255,.55);text-transform:uppercase;letter-spacing:.06em;margin-top:2px;}
.bdiv{width:1px;background:rgba(255,255,255,.2);align-self:stretch;}
.live-badge{background:rgba(16,185,129,.2);border:1px solid rgba(16,185,129,.4);
  color:#a7f3d0;padding:4px 12px;border-radius:20px;font-size:11px;font-weight:700;
  display:inline-flex;align-items:center;gap:5px;}
.ldot{width:7px;height:7px;border-radius:50%;background:#10b981;animation:pulse 1.4s infinite;}
@keyframes pulse{0%,100%{opacity:1;transform:scale(1)}50%{opacity:.5;transform:scale(.8)}}
.btn-exp{padding:9px 20px;background:rgba(255,255,255,.15);color:#fff;
  border:1px solid rgba(255,255,255,.35);border-radius:var(--rads);
  font-size:12px;font-weight:700;cursor:pointer;transition:.2s;
  display:inline-flex;align-items:center;gap:7px;}
.btn-exp:hover{background:rgba(255,255,255,.28);}
.gspin{display:inline-block;width:18px;height:18px;border:2px solid rgba(255,255,255,.25);
  border-top-color:#a78bfa;border-radius:50%;animation:spin .7s linear infinite;}
@keyframes spin{to{transform:rotate(360deg)}}

/* Filter bar */
.fb{background:var(--bg);border:1px solid var(--bd);border-radius:var(--rad);
  padding:16px 20px;margin-bottom:20px;box-shadow:var(--sh);}
.fb-hd{display:flex;align-items:center;justify-content:space-between;
  margin-bottom:14px;flex-wrap:wrap;gap:8px;}
.fb-lbl{font-size:12px;font-weight:700;color:var(--ts);text-transform:uppercase;
  letter-spacing:.05em;display:flex;align-items:center;gap:7px;}
.fb-acts{display:flex;gap:8px;}
.btn-ap{padding:7px 18px;background:var(--p);color:#fff;border:none;
  border-radius:var(--rads);font-size:12px;font-weight:700;cursor:pointer;
  display:inline-flex;align-items:center;gap:5px;transition:.15s;}
.btn-ap:hover{background:var(--pd);}
.btn-rs{padding:7px 14px;background:var(--pg);color:var(--ts);border:1px solid var(--bd);
  border-radius:var(--rads);font-size:12px;font-weight:600;cursor:pointer;}
.btn-rs:hover{background:var(--bd);}
.f-row{display:flex;flex-wrap:wrap;gap:10px;align-items:flex-end;}
.fg{display:flex;flex-direction:column;gap:4px;min-width:120px;flex:1;}
.fg label{font-size:11px;font-weight:600;color:var(--ts);}
.fsel,.finp{padding:8px 10px;border:1.5px solid var(--bd);border-radius:var(--rads);
  font-size:13px;color:var(--tx);background:#fff;width:100%;transition:.18s;}
.fsel:focus,.finp:focus{border-color:var(--p);outline:none;box-shadow:0 0 0 3px var(--p20);}
.load-bar{height:3px;background:linear-gradient(90deg,var(--p),var(--pu),var(--b));
  width:0%;border-radius:2px;transition:width .4s;margin-top:10px;}
.af-chips{display:flex;flex-wrap:wrap;gap:6px;margin-top:10px;}
.af-chip{background:var(--pl);color:var(--p);padding:3px 10px;border-radius:99px;
  font-size:11px;font-weight:600;display:inline-flex;align-items:center;gap:5px;cursor:pointer;}
.af-chip:hover{background:var(--bl);color:var(--b);}

/* KPI grid */
.kpi-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(148px,1fr));
  gap:12px;margin-bottom:20px;}
.kpi{background:var(--bg);border:1px solid var(--bd);border-radius:var(--rad);
  padding:16px 15px;box-shadow:var(--sh);position:relative;overflow:hidden;transition:.18s;}
.kpi:hover{transform:translateY(-3px);box-shadow:var(--shm);}
.kpi::before{content:'';position:absolute;top:0;left:0;right:0;height:3px;
  border-radius:var(--rad) var(--rad) 0 0;}
.kb::before{background:var(--b);}  .kg::before{background:var(--g);}
.kpu::before{background:var(--pu);}.kw::before{background:var(--w);}
.kt::before{background:var(--t);}  .kr::before{background:var(--r);}
.kor::before{background:var(--or);}.kvi::before{background:var(--vi);}
.kro::before{background:var(--ro);}.kcy::before{background:var(--cy);}
.kpi-top{display:flex;align-items:center;justify-content:space-between;margin-bottom:10px;}
.klbl{font-size:10px;font-weight:700;color:var(--ts);text-transform:uppercase;letter-spacing:.06em;}
.kico{width:38px;height:38px;border-radius:10px;display:flex;align-items:center;
  justify-content:center;font-size:16px;}
.ib{background:var(--bl);color:var(--b);}   .ig{background:var(--gl);color:var(--g);}
.ipu{background:var(--pul);color:var(--pu);}.iw{background:var(--wl);color:var(--w);}
.it{background:var(--tl);color:var(--t);}   .ir{background:var(--rl);color:var(--r);}
.ior{background:var(--orl);color:var(--or);}.ivi{background:var(--vil);color:var(--vi);}
.iro{background:var(--rol);color:var(--ro);}.icy{background:var(--cyl);color:var(--cy);}
.kval{font-size:26px;font-weight:900;color:var(--tx);line-height:1;letter-spacing:-.5px;transition:all .4s;}
.ksub{font-size:11px;color:var(--tm);margin-top:4px;}

/* ══ TABS — pure JS, NO onclick, class "on" ══ */
.tab-bar{display:flex;gap:2px;background:var(--pg);border-radius:10px;padding:4px;
  margin-bottom:18px;flex-wrap:wrap;}
.tab-btn{padding:9px 16px;border:none;background:transparent;border-radius:8px;
  font-size:13px;font-weight:600;color:var(--ts);cursor:pointer;transition:.18s;
  display:flex;align-items:center;gap:6px;white-space:nowrap;outline:none;}
.tab-btn.on{background:var(--bg);color:var(--p);box-shadow:var(--sh);}
.tab-btn:hover:not(.on){background:rgba(255,255,255,.55);color:var(--tx);}
.tab-pane{display:none;}
.tab-pane.on{display:block;animation:tabIn .22s ease;}
@keyframes tabIn{from{opacity:0;transform:translateY(5px)}to{opacity:1;transform:none}}

/* Card */
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
.g2{display:grid;grid-template-columns:1fr 1fr;gap:16px;margin-bottom:18px;}
.g3{display:grid;grid-template-columns:1fr 1fr 1fr;gap:16px;margin-bottom:18px;}
.g21{display:grid;grid-template-columns:2fr 1fr;gap:16px;margin-bottom:18px;}
.g12{display:grid;grid-template-columns:1fr 2fr;gap:16px;margin-bottom:18px;}

/* Teacher table */
.tbl-wrap{overflow-x:auto;}
.ttbl{width:100%;border-collapse:collapse;font-size:13px;min-width:960px;}
.ttbl th{font-size:10px;font-weight:700;color:var(--ts);text-transform:uppercase;
  letter-spacing:.05em;padding:10px 12px;border-bottom:2px solid var(--bd);
  text-align:left;white-space:nowrap;}
.ttbl td{padding:11px 12px;border-bottom:1px solid var(--bd);vertical-align:middle;}
.ttbl tr:hover td{background:#f7f8ff;}
.ttbl tr:last-child td{border-bottom:none;}
.tav{width:36px;height:36px;border-radius:50%;background:var(--pul);color:var(--pu);
  display:flex;align-items:center;justify-content:center;font-size:13px;font-weight:800;
  overflow:hidden;flex-shrink:0;border:2px solid var(--bd);}
.tav img{width:100%;height:100%;object-fit:cover;}
.t-name{font-weight:700;color:var(--tx);}
.t-emp{font-size:11px;color:var(--tm);}
.sp{display:inline-block;padding:2px 9px;border-radius:99px;font-size:11px;font-weight:700;}
.sp-a{background:var(--gl);color:#065f46;}.sp-i{background:var(--rl);color:#991b1b;}
.sp-n{background:var(--bl);color:#1d4ed8;}
.ac{display:inline-flex;align-items:center;gap:3px;padding:2px 8px;
  border-radius:99px;font-size:11px;font-weight:600;margin-right:3px;}
.acv{background:var(--bl);color:#1d4ed8;}.aca{background:var(--wl);color:#92400e;}
.acq{background:var(--pul);color:#6d28d9;}.acs{background:var(--gl);color:#065f46;}

/* Pagination */
.pag{display:flex;align-items:center;justify-content:space-between;
  margin-top:14px;flex-wrap:wrap;gap:10px;}
.pag-info{font-size:12px;color:var(--ts);}
.pag-btns{display:flex;gap:4px;}
.pbtn{width:32px;height:32px;border:1px solid var(--bd);border-radius:var(--rads);
  background:#fff;color:var(--ts);font-size:12px;font-weight:600;cursor:pointer;
  display:flex;align-items:center;justify-content:center;transition:.15s;}
.pbtn:hover{border-color:var(--p);color:var(--p);}
.pbtn.on{background:var(--p);color:#fff;border-color:var(--p);}
.pbtn:disabled{opacity:.35;cursor:not-allowed;}

/* Top teachers */
.ti{display:flex;align-items:center;gap:12px;padding:11px 0;border-bottom:1px solid var(--bd);}
.ti:last-child{border:none;}
.ti-rank{width:24px;height:24px;border-radius:50%;display:flex;align-items:center;
  justify-content:center;font-size:11px;font-weight:800;flex-shrink:0;}
.r1{background:#fef3c7;color:#b45309;}.r2{background:#f3f4f6;color:#374151;}
.r3{background:#fde8d8;color:#c05621;}.rn{background:var(--pg);color:var(--ts);}
.ti-av{width:40px;height:40px;border-radius:50%;background:var(--pul);color:var(--pu);
  display:flex;align-items:center;justify-content:center;font-size:15px;font-weight:800;
  flex-shrink:0;overflow:hidden;border:2px solid var(--bd);}
.ti-av img{width:100%;height:100%;object-fit:cover;}
.ti-name{font-size:13px;font-weight:700;color:var(--tx);}
.ti-des{font-size:11px;color:var(--ts);}
.ti-score{font-size:14px;font-weight:800;color:var(--p);}
.ti-sub{font-size:10px;color:var(--tm);}

/* Activity feed */
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
.pi-lbl span:last-child{color:var(--ts);}
.pi-track{height:7px;background:var(--bd);border-radius:99px;overflow:hidden;}
.pi-fill{height:7px;border-radius:99px;transition:width 1.1s ease;width:0%;}

/* Empty/spinner */
.empty{text-align:center;padding:40px;color:var(--tm);}
.empty i{font-size:32px;display:block;margin-bottom:10px;opacity:.4;}
.empty p{font-size:13px;}
.spin{display:inline-block;width:20px;height:20px;border:2px solid var(--bd);
  border-top-color:var(--p);border-radius:50%;animation:spin .7s linear infinite;}

@media(max-width:1100px){.g21,.g12{grid-template-columns:1fr;}.g3{grid-template-columns:1fr 1fr;}}
@media(max-width:700px){.g2,.g3{grid-template-columns:1fr;}.kpi-grid{grid-template-columns:1fr 1fr;}}
@media(max-width:480px){.kpi-grid{grid-template-columns:1fr 1fr;}.tab-btn{font-size:11px;padding:7px 10px;}}
</style>
</asp:Content>

<asp:Content ID="cBody" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

<%-- Server → Client config --%>
<asp:HiddenField ID="hdnInstId" runat="server"/>
<asp:HiddenField ID="hdnSessId" runat="server"/>
<asp:Label       ID="lblSession" runat="server" Style="display:none;"/>

<%-- Hidden ASP dropdowns for server-side init --%>
<asp:DropDownList ID="ddlStream"      runat="server" Style="display:none;"/>
<asp:DropDownList ID="ddlSection"     runat="server" Style="display:none;"/>
<asp:DropDownList ID="ddlDesignation" runat="server" Style="display:none;"/>
<asp:DropDownList ID="ddlYear"        runat="server" Style="display:none;"/>

<div class="wrap">

<!-- BANNER -->
<div class="banner">
  <div class="b-particles" id="bPart"></div>
  <div class="b-ov"></div>
  <div class="b-body">
    <div>
      <div class="b-eyebrow"><i class="fa fa-chalkboard-user"></i>Teacher Management</div>
      <div class="b-title">Faculty Analytics Dashboard</div>
      <div class="b-sub">Session: <span id="bSess"></span> &nbsp;&bull;&nbsp; Performance &amp; activity tracking</div>
      <div class="b-stats">
        <div class="bst"><div class="bst-v" id="bTotal">—</div><div class="bst-l">Total Faculty</div></div>
        <div class="bdiv"></div>
        <div class="bst"><div class="bst-v" id="bActive">—</div><div class="bst-l">Active</div></div>
        <div class="bdiv"></div>
        <div class="bst"><div class="bst-v" id="bVideos">—</div><div class="bst-l">Videos</div></div>
        <div class="bdiv"></div>
        <div class="bst"><div class="bst-v" id="bStudents">—</div><div class="bst-l">Students</div></div>
        <div class="bdiv"></div>
        <div class="bst"><div class="bst-v" id="bAvgExp">—</div><div class="bst-l">Avg Exp</div></div>
      </div>
    </div>
    <div style="display:flex;flex-direction:column;align-items:flex-end;gap:10px;">
      <div class="live-badge"><span class="ldot"></span>Live Data</div>
      <%-- type=button CRITICAL — prevents postback --%>
      <button type="button" class="btn-exp" id="btnExport"><i class="fa fa-file-csv"></i>Export CSV</button>
      <div class="gspin" id="gSpin" style="display:none;"></div>
    </div>
  </div>
</div>

<!-- FILTER BAR -->
<div class="fb">
  <div class="fb-hd">
    <div class="fb-lbl"><i class="fa fa-filter"></i>Filters</div>
    <div class="fb-acts">
      <button type="button" class="btn-rs" id="btnReset"><i class="fa fa-rotate"></i> Reset</button>
      <button type="button" class="btn-ap" id="btnApply"><i class="fa fa-magnifying-glass"></i> Apply</button>
    </div>
  </div>
  <div class="f-row">
    <div class="fg"><label>Stream</label>
      <select id="fStream" class="fsel"><option value="0">All Streams</option></select>
    </div>
    <div class="fg"><label>Section</label>
      <select id="fSection" class="fsel"><option value="0">All Sections</option></select>
    </div>
    <div class="fg"><label>Designation</label>
      <select id="fDesig" class="fsel"><option value="">All</option></select>
    </div>
    <div class="fg"><label>Status</label>
      <select id="fStatus" class="fsel">
        <option value="">All</option>
        <option value="Active">Active</option>
        <option value="Inactive">Inactive</option>
      </select>
    </div>
    <div class="fg"><label>Join Month</label>
      <select id="fMonth" class="fsel">
        <option value="">All Months</option>
        <option value="1">January</option><option value="2">February</option>
        <option value="3">March</option><option value="4">April</option>
        <option value="5">May</option><option value="6">June</option>
        <option value="7">July</option><option value="8">August</option>
        <option value="9">September</option><option value="10">October</option>
        <option value="11">November</option><option value="12">December</option>
      </select>
    </div>
    <div class="fg"><label>Year</label>
      <select id="fYear" class="fsel"><option value="">All Years</option></select>
    </div>
    <div class="fg" style="flex:2;min-width:180px;"><label>Search</label>
      <div style="position:relative;">
        <i class="fa fa-magnifying-glass" style="position:absolute;left:10px;top:50%;transform:translateY(-50%);color:var(--tm);font-size:12px;"></i>
        <input type="text" id="fSearch" class="fsel" style="padding-left:32px;"
               placeholder="Name, Employee ID, Designation…"/>
      </div>
    </div>
  </div>
  <div class="load-bar" id="lbar"></div>
  <div class="af-chips" id="afcWrap"></div>
</div>

<!-- KPI CARDS -->
<div class="kpi-grid">
  <div class="kpi kb"><div class="kpi-top"><span class="klbl">Total Faculty</span><div class="kico ib"><i class="fa fa-chalkboard-user"></i></div></div>
    <div class="kval" id="kTotal">—</div><div class="ksub">All teachers</div></div>
  <div class="kpi kg"><div class="kpi-top"><span class="klbl">Active</span><div class="kico ig"><i class="fa fa-circle-check"></i></div></div>
    <div class="kval" id="kActive">—</div><div class="ksub">Currently active</div></div>
  <div class="kpi kr"><div class="kpi-top"><span class="klbl">Inactive</span><div class="kico ir"><i class="fa fa-circle-xmark"></i></div></div>
    <div class="kval" id="kInactive">—</div><div class="ksub">Deactivated</div></div>
  <div class="kpi kpu"><div class="kpi-top"><span class="klbl">New Joined</span><div class="kico ipu"><i class="fa fa-user-plus"></i></div></div>
    <div class="kval" id="kNew">—</div><div class="ksub">First login pending</div></div>
  <div class="kpi kvi"><div class="kpi-top"><span class="klbl">Videos</span><div class="kico ivi"><i class="fa fa-video"></i></div></div>
    <div class="kval" id="kVideos">—</div><div class="ksub">Total uploaded</div></div>
  <div class="kpi kw"><div class="kpi-top"><span class="klbl">Assignments</span><div class="kico iw"><i class="fa fa-clipboard-list"></i></div></div>
    <div class="kval" id="kAssign">—</div><div class="ksub">Created this session</div></div>
  <div class="kpi kt"><div class="kpi-top"><span class="klbl">Quizzes</span><div class="kico it"><i class="fa fa-circle-question"></i></div></div>
    <div class="kval" id="kQuizzes">—</div><div class="ksub">Active quizzes</div></div>
  <div class="kpi kor"><div class="kpi-top"><span class="klbl">Subjects Taught</span><div class="kico ior"><i class="fa fa-book-open"></i></div></div>
    <div class="kval" id="kSubjects">—</div><div class="ksub">Unique subjects</div></div>
  <div class="kpi kcy"><div class="kpi-top"><span class="klbl">Students Reached</span><div class="kico icy"><i class="fa fa-users"></i></div></div>
    <div class="kval" id="kStudents">—</div><div class="ksub">Across all streams</div></div>
  <div class="kpi kro"><div class="kpi-top"><span class="klbl">Avg Experience</span><div class="kico iro"><i class="fa fa-star"></i></div></div>
    <div class="kval" id="kAvgExpCard">—</div><div class="ksub">Years of experience</div></div>
</div>

<!-- TABS — all type=button, handled by JS tabBar listener -->
<div class="tab-bar" id="tabBar">
  <button type="button" class="tab-btn on" data-tab="overview"><i class="fa fa-chart-pie"></i>Overview</button>
  <button type="button" class="tab-btn" data-tab="records"><i class="fa fa-table"></i>Faculty Records</button>
  <button type="button" class="tab-btn" data-tab="performance"><i class="fa fa-trophy"></i>Performance</button>
  <button type="button" class="tab-btn" data-tab="content"><i class="fa fa-play-circle"></i>Content</button>
  <button type="button" class="tab-btn" data-tab="activity"><i class="fa fa-bell"></i>Activity</button>
</div>

<!-- TAB: OVERVIEW -->
<div id="tab-overview" class="tab-pane on">
  <div class="g21">
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--pl);color:var(--p);"><i class="fa fa-arrow-trend-up"></i></div>
          <div><div class="ct">Faculty Joining Trend — Last 12 Months</div>
            <div class="cs">New teachers onboarded per month</div></div>
        </div>
        <span id="trendLbl" style="font-size:11px;color:var(--tm);"></span>
      </div>
      <div class="cb" style="height:245px;"><canvas id="cTrend"></canvas></div>
    </div>
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--pul);color:var(--pu);"><i class="fa fa-layer-group"></i></div>
          <div><div class="ct">Faculty by Stream</div></div>
        </div>
      </div>
      <div class="cb" style="height:245px;"><canvas id="cStream"></canvas></div>
    </div>
  </div>
  <div class="g3">
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--wl);color:var(--w);"><i class="fa fa-id-badge"></i></div>
          <div><div class="ct">By Designation</div></div>
        </div>
      </div>
      <div class="cb" style="height:220px;"><canvas id="cDesig"></canvas></div>
    </div>
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--tl);color:var(--t);"><i class="fa fa-star"></i></div>
          <div><div class="ct">Experience Distribution</div></div>
        </div>
      </div>
      <div class="cb" style="height:220px;"><canvas id="cExp"></canvas></div>
    </div>
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--rol);color:var(--ro);"><i class="fa fa-venus-mars"></i></div>
          <div><div class="ct">Gender Distribution</div></div>
        </div>
      </div>
      <div class="cb" style="height:175px;"><canvas id="cGender"></canvas></div>
      <div id="genderLeg" style="display:flex;flex-wrap:wrap;gap:6px;justify-content:center;margin-top:10px;"></div>
    </div>
  </div>
  <div class="g2">
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--gl);color:var(--g);"><i class="fa fa-graduation-cap"></i></div>
          <div><div class="ct">Qualification Distribution</div></div>
        </div>
      </div>
      <div class="cb" style="height:230px;"><canvas id="cQual"></canvas></div>
    </div>
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--bl);color:var(--b);"><i class="fa fa-book-open"></i></div>
          <div><div class="ct">Subject-wise Faculty</div>
            <div class="cs">Teachers &amp; content per subject</div></div>
        </div>
      </div>
      <div class="cb" style="height:230px;"><canvas id="cSubject"></canvas></div>
    </div>
  </div>
</div>

<!-- TAB: FACULTY RECORDS -->
<div id="tab-records" class="tab-pane">
  <div class="card">
    <div class="card-hd">
      <div class="card-hd-l">
        <div class="cico" style="background:var(--bl);color:var(--b);"><i class="fa fa-table"></i></div>
        <div><div class="ct">Faculty Records</div>
          <div class="cs" id="recCount">Loading…</div></div>
      </div>
    </div>
    <div class="tbl-wrap">
      <table class="ttbl">
        <thead>
          <tr>
            <th>#</th><th>Teacher</th><th>Emp ID</th><th>Stream/Section</th>
            <th>Designation</th><th>Qualification</th><th>Exp</th>
            <th>Gender</th><th>Joined</th>
            <th>Videos</th><th>Assign.</th><th>Quizzes</th>
            <th>Avg Score</th><th>Status</th>
          </tr>
        </thead>
        <tbody id="tTbody">
          <tr><td colspan="14"><div class="empty"><div class="spin"></div></div></td></tr>
        </tbody>
      </table>
    </div>
    <div class="pag">
      <div class="pag-info" id="pagInfo"></div>
      <div class="pag-btns" id="pagBtns"></div>
    </div>
  </div>
</div>

<!-- TAB: PERFORMANCE -->
<div id="tab-performance" class="tab-pane">
  <div class="g12">
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--wl);color:var(--w);"><i class="fa fa-medal"></i></div>
          <div><div class="ct">Top 10 Teachers</div>
            <div class="cs">By content output &amp; student performance</div></div>
        </div>
      </div>
      <div id="topList"><div class="empty"><div class="spin"></div></div></div>
    </div>
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--tl);color:var(--t);"><i class="fa fa-chart-area"></i></div>
          <div><div class="ct">Avg Performance Metrics</div>
            <div class="cs">Per-teacher averages across all dimensions</div></div>
        </div>
      </div>
      <div class="cb" style="height:300px;"><canvas id="cRadar"></canvas></div>
    </div>
  </div>
  <div class="card" style="margin-bottom:18px;">
    <div class="card-hd">
      <div class="card-hd-l">
        <div class="cico" style="background:var(--vil);color:var(--vi);"><i class="fa fa-play-circle"></i></div>
        <div><div class="ct">Weekly Content Output — Last 8 Weeks</div>
          <div class="cs">Videos · Assignments · Quizzes</div></div>
      </div>
    </div>
    <div class="cb" style="height:230px;"><canvas id="cContent"></canvas></div>
  </div>
</div>

<!-- TAB: CONTENT -->
<div id="tab-content" class="tab-pane">
  <div class="g2">
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--pul);color:var(--pu);"><i class="fa fa-video"></i></div>
          <div><div class="ct">Content by Subject</div></div>
        </div>
      </div>
      <div class="cb" style="height:280px;"><canvas id="cSubjContent"></canvas></div>
    </div>
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--wl);color:var(--w);"><i class="fa fa-chart-bar"></i></div>
          <div><div class="ct">Top Teachers by Activity</div></div>
        </div>
      </div>
      <div id="contentBars" style="padding-top:6px;"></div>
    </div>
  </div>
</div>

<!-- TAB: ACTIVITY -->
<div id="tab-activity" class="tab-pane">
  <div class="g21">
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--gl);color:var(--g);"><i class="fa fa-bell"></i></div>
          <div><div class="ct">Recent Faculty Activity</div>
            <div class="cs">Latest teacher actions</div></div>
        </div>
        <button type="button" class="btn-ap" id="btnRefreshAct"
                style="font-size:11px;padding:5px 12px;">
          <i class="fa fa-rotate"></i> Refresh
        </button>
      </div>
      <div id="actFeed"><div class="empty"><div class="spin"></div></div></div>
    </div>
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--bl);color:var(--b);"><i class="fa fa-chart-pie"></i></div>
          <div><div class="ct">Gender Split</div></div>
        </div>
      </div>
      <div class="cb" style="height:200px;margin-bottom:16px;"><canvas id="cGender2"></canvas></div>
      <hr style="border:none;border-top:1px solid var(--bd);margin-bottom:16px;"/>
      <div style="font-size:13px;font-weight:700;margin-bottom:12px;">Stream Distribution</div>
      <div id="streamBars"></div>
    </div>
  </div>
</div>

</div><%-- /wrap --%>

<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.4.1/chart.umd.min.js"></script>
<script>
    /* ════════════════════════════════════════════════════════════════
       TEACHER MANAGEMENT DASHBOARD
       ── ALL buttons type="button" — zero postbacks
       ── ALL data via fetch() AJAX — no page reload
       ── Tabs: JS class "on" toggle only — tabBar click listener
       ── Dropdowns: JS cloned from hidden ASP controls
       ── Filters: addEventListener only — no inline onclick/onchange
    ════════════════════════════════════════════════════════════════ */
    (function () {
        'use strict';

        /* ── Server values ── */
        function hv(id) { var e = document.getElementById(id); return e ? (e.value || '') : ''; };
        var INST = hv('<%= hdnInstId.ClientID %>');
    var SESS = hv('<%= hdnSessId.ClientID %>');
    var SNAME = (document.getElementById('<%= lblSession.ClientID %>') || {}).innerText || '';
    document.getElementById('bSess').innerText = SNAME;

    /* ── Chart config ── */
    var PAL = ['#4f46e5', '#10b981', '#f59e0b', '#ef4444', '#8b5cf6', '#3b82f6',
        '#0d9488', '#f43f5e', '#0891b2', '#ea580c', '#7c3aed', '#84cc16'];
    var GRD = { color: 'rgba(148,163,184,.12)' };
    var TICK = { font: { size: 11, family: "'Inter','Segoe UI',sans-serif" } };
    var TT = { padding: 10, cornerRadius: 8, bodyFont: { size: 12 }, titleFont: { size: 12, weight: 'bold' } };
    var ANIM = { duration: 950, easing: 'easeInOutQuart' };
    function palA(a) { return PAL.map(function (c) { return c + Math.round(a * 255).toString(16).padStart(2, '0'); }); }

    var charts = {}, debT = null, lastData = null, curPage = 0, totPages = 1;

    /* ── Particles ── */
    (function () {
        var c = document.getElementById('bPart');
        for (var i = 0; i < 12; i++) {
            var d = document.createElement('div'), sz = Math.random() * 40 + 10;
            d.className = 'bp';
            d.style.cssText = 'width:' + sz + 'px;height:' + sz + 'px;left:' + Math.random() * 100 + '%;'
                + 'animation-duration:' + (Math.random() * 6 + 4) + 's;animation-delay:' + (Math.random() * 4) + 's;'
                + 'bottom:-' + sz + 'px;';
            c.appendChild(d);
        }
    })();

    /* ── Year dropdown ── */
    (function () {
        var sel = document.getElementById('fYear'), cur = new Date().getFullYear();
        for (var y = cur; y >= cur - 5; y--) {
            var o = document.createElement('option'); o.value = y; o.text = y; sel.appendChild(o);
        }
    })();

    /* ════════════════════════════════════════════════════════
       STEP 1: Clone ASP hidden dropdowns → visible JS selects
    ════════════════════════════════════════════════════════ */
    var DDL = {
  '<%= ddlStream.ClientID %>':      'fStream',
  '<%= ddlSection.ClientID %>':     'fSection',
  '<%= ddlDesignation.ClientID %>': 'fDesig',
  '<%= ddlYear.ClientID %>':        'fYear'
};
Object.keys(DDL).forEach(function(aspId){
  var asp=document.getElementById(aspId), js=document.getElementById(DDL[aspId]);
  if(!asp||!js) return;
  Array.prototype.forEach.call(asp.options,function(o){
    if((!o.value||o.value==='0')&&aspId!=='<%= ddlYear.ClientID %>') return;
      if (js.querySelector('option[value="' + o.value + '"]')) return;
      var n = document.createElement('option'); n.value = o.value; n.text = o.text; js.appendChild(n);
  });
});

        function G(id) { return document.getElementById(id); }

        /* ════════════════════════════════════════════════════════
           STEP 2: Wire all buttons & inputs with addEventListener
           NO inline onclick / onchange — prevents postbacks
        ════════════════════════════════════════════════════════ */
        G('btnApply').addEventListener('click', function (e) { e.preventDefault(); go(0); });
        G('btnReset').addEventListener('click', function (e) { e.preventDefault(); resetF(); });
        G('btnExport').addEventListener('click', function (e) { e.preventDefault(); doExport(); });
        G('btnRefreshAct').addEventListener('click', function (e) { e.preventDefault(); go(0); });

        /* Filter dropdowns — addEventListener change */
        ['fStream', 'fSection', 'fDesig', 'fStatus', 'fMonth', 'fYear'].forEach(function (id) {
            G(id).addEventListener('change', function () { go(0); });
        });

        /* Search input — debounced */
        G('fSearch').addEventListener('input', function () {
            clearTimeout(debT);
            debT = setTimeout(function () { go(0); }, 450);
        });
        G('fSearch').addEventListener('keydown', function (e) {
            if (e.key === 'Enter') { e.preventDefault(); go(0); }
        });

        /* Tab bar — single delegated listener */
        G('tabBar').addEventListener('click', function (e) {
            var btn = e.target.closest('.tab-btn'); if (!btn) return;
            e.preventDefault(); e.stopPropagation();
            var name = btn.dataset.tab; if (!name) return;
            document.querySelectorAll('.tab-btn').forEach(function (b) { b.classList.remove('on'); });
            document.querySelectorAll('.tab-pane').forEach(function (p) { p.classList.remove('on'); });
            btn.classList.add('on');
            var pane = G('tab-' + name); if (pane) pane.classList.add('on');
        });

        /* ════════════════════════════════════════════════════════
           FILTER HELPERS
        ════════════════════════════════════════════════════════ */
        function getF() {
            return {
                stream: G('fStream').value || '0',
                section: G('fSection').value || '0',
                desig: G('fDesig').value || '',
                status: G('fStatus').value || '',
                month: G('fMonth').value || '',
                year: G('fYear').value || '',
                search: (G('fSearch').value || '').trim()
            };
        }

        function buildURL(page) {
            var f = getF();
            return location.pathname
                + '?ajax=1&inst=' + encodeURIComponent(INST) + '&sess=' + encodeURIComponent(SESS)
                + '&stream=' + f.stream + '&section=' + f.section
                + '&desig=' + encodeURIComponent(f.desig)
                + '&status=' + encodeURIComponent(f.status)
                + '&month=' + f.month + '&year=' + f.year
                + '&search=' + encodeURIComponent(f.search)
                + '&page=' + (page || 0);
        }

        function resetF() {
            G('fStream').value = '0'; G('fSection').value = '0';
            G('fDesig').value = ''; G('fStatus').value = '';
            G('fMonth').value = ''; G('fYear').value = '';
            G('fSearch').value = ''; G('afcWrap').innerHTML = '';
            go(0);
        }

        function updateChips() {
            var f = getF(), wrap = G('afcWrap'); wrap.innerHTML = '';
            var labels = { stream: 'fStream', section: 'fSection', desig: 'fDesig', status: 'fStatus', month: 'fMonth', year: 'fYear' };
            Object.keys(labels).forEach(function (lbl) {
                var el = G(labels[lbl]); var v = el.value;
                if (!v || v === '0') return;
                var tx = el.options[el.selectedIndex] ? el.options[el.selectedIndex].text : v;
                var chip = document.createElement('span'); chip.className = 'af-chip';
                chip.innerHTML = esc(tx) + ' <i class="fa fa-xmark" style="font-size:10px;opacity:.7;"></i>';
                (function (fid) {
                    chip.addEventListener('click', function () {
                        var el2 = G(fid); el2.value = (fid === 'fStream' || fid === 'fSection') ? '0' : ''; go(0);
                    });
                })(labels[lbl]);
                wrap.appendChild(chip);
            });
            if (f.search) {
                var c2 = document.createElement('span'); c2.className = 'af-chip';
                c2.innerHTML = '"' + esc(f.search) + '" <i class="fa fa-xmark" style="font-size:10px;opacity:.7;"></i>';
                c2.addEventListener('click', function () { G('fSearch').value = ''; go(0); });
                wrap.appendChild(c2);
            }
        }

        /* ════════════════════════════════════════════════════════
           MAIN FETCH
        ════════════════════════════════════════════════════════ */
        function go(page) {
            curPage = page || 0;
            clearTimeout(debT);
            debT = setTimeout(function () { fetchData(curPage); }, 280);
        }

        function fetchData(page) {
            setLoad(true); updateChips();
            fetch(buildURL(page))
                .then(function (r) {
                    if (!r.ok) throw new Error('HTTP ' + r.status + ' — ' + r.statusText);
                    return r.json();
                })
                .then(function (d) {
                    lastData = d;
                    renderKPIs(d.kpi);
                    renderAllCharts(d);
                    renderTable(d);
                    renderTopTeachers(d.topTeachers);
                    renderActivity(d.recentActivity);
                    renderContentBars(d.topTeachers);
                    setLoad(false);
                })
                .catch(function (err) {
                    setLoad(false);
                    console.error('[Teacher Dashboard]', err);
                });
        }

        function setLoad(on) {
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
            cu('kTotal', k.total || 0);
            cu('kActive', k.active || 0);
            cu('kInactive', k.inactive || 0);
            cu('kNew', k.newJoined || 0);
            cu('kVideos', k.videos || 0);
            cu('kAssign', k.assignments || 0);
            cu('kQuizzes', k.quizzes || 0);
            cu('kSubjects', k.subjects || 0);
            cu('kStudents', k.students || 0);
            G('kAvgExpCard').innerText = parseFloat(k.avgExp || 0).toFixed(1) + ' yrs';
            /* Banner */
            G('bTotal').innerText = k.total || 0;
            G('bActive').innerText = k.active || 0;
            G('bVideos').innerText = k.videos || 0;
            G('bStudents').innerText = k.students || 0;
            G('bAvgExp').innerText = parseFloat(k.avgExp || 0).toFixed(1) + 'y';
        }

        function cu(id, n) {
            var el = G(id); if (!el) return;
            var t = parseInt(n) || 0, s = parseInt(el.innerText) || 0, diff = t - s, steps = 28, i = 0;
            var iv = setInterval(function () {
                i++; el.innerText = Math.round(s + diff * (i / steps));
                if (i >= steps) { el.innerText = t; clearInterval(iv); }
            }, 16);
        }

        /* ════════════════════════════════════════════════════════
           CHART HELPERS
        ════════════════════════════════════════════════════════ */
        function dc(k) { if (charts[k]) { charts[k].destroy(); charts[k] = null; } }
        function gV(ctx, h, c1, c2) { var g = ctx.createLinearGradient(0, 0, 0, h); g.addColorStop(0, c1); g.addColorStop(1, c2); return g; }
        function noData(id, msg) {
            var el = G(id); if (!el) return;
            var box = el.closest('.cb');
            if (box) box.innerHTML = '<div class="empty"><i class="fa fa-chart-simple"></i><p>' + (msg || 'No data') + '</p></div>';
        }

        function renderAllCharts(d) {
            renderTrend(d.joiningTrend);
            renderStream(d.streamWise);
            renderDesig(d.designation);
            renderExp(d.experience);
            renderGenderChart(d.gender, 'cGender', 'genderLeg');
            renderGenderChart(d.gender, 'cGender2', null);
            renderQual(d.qualification);
            renderSubject(d.subjectWise);
            renderSubjContent(d.subjectWise);
            renderContentTrend(d.contentTrend);
            renderRadar(d.perfMetrics);
            renderStreamBars(d.streamWise);
        }

        /* 1. Joining trend */
        function renderTrend(data) {
            dc('trend');
            if (!data || !data.length) { noData('cTrend', 'No joining data'); return; }
            var ctx = G('cTrend'); if (!ctx) return;
            var c = ctx.getContext('2d');
            var grad = gV(c, 230, 'rgba(79,70,229,.28)', 'rgba(79,70,229,.01)');
            var total = data.reduce(function (a, r) { return a + (r.Teachers || 0); }, 0);
            var lbl = G('trendLbl'); if (lbl) lbl.innerText = total + ' total';
            charts.trend = new Chart(ctx, {
                type: 'line', data: {
                    labels: data.map(function (r) { return r.Mon; }),
                    datasets: [{
                        label: 'New Faculty', data: data.map(function (r) { return r.Teachers || 0; }),
                        borderColor: '#4f46e5', backgroundColor: grad, borderWidth: 2.5, tension: .42, fill: true,
                        pointRadius: 5, pointHoverRadius: 8, pointBackgroundColor: '#4f46e5',
                        pointHoverBackgroundColor: '#fff', pointHoverBorderColor: '#4f46e5', pointHoverBorderWidth: 2
                    }]
                }, options: {
                    responsive: true, maintainAspectRatio: false,
                    plugins: { legend: { display: false }, tooltip: TT },
                    scales: { x: { grid: { display: false }, ticks: TICK }, y: { beginAtZero: true, grid: GRD, ticks: { ...TICK, precision: 0 } } },
                    animation: ANIM
                }
            });
        }

        /* 2. Stream bar */
        function renderStream(data) {
            dc('stream');
            if (!data || !data.length) { noData('cStream', 'No stream data'); return; }
            var el = G('cStream'); if (!el) return;
            charts.stream = new Chart(el, {
                type: 'bar', data: {
                    labels: data.map(function (r) { return r.StreamName; }),
                    datasets: [{
                        label: 'Teachers', data: data.map(function (r) { return r.Teachers || 0; }),
                        backgroundColor: palA(.82), borderRadius: 6, borderSkipped: false
                    }]
                }, options: {
                    indexAxis: 'y', responsive: true, maintainAspectRatio: false,
                    plugins: { legend: { display: false }, tooltip: TT },
                    scales: { x: { beginAtZero: true, grid: GRD, ticks: TICK }, y: { grid: { display: false }, ticks: { font: { size: 11 } } } },
                    animation: ANIM
                }
            });
        }

        /* 3. Designation donut */
        function renderDesig(data) {
            dc('desig');
            if (!data || !data.length) { noData('cDesig', 'No designation data'); return; }
            var el = G('cDesig'); if (!el) return;
            charts.desig = new Chart(el, {
                type: 'doughnut', data: {
                    labels: data.map(function (r) { return r.Designation; }),
                    datasets: [{
                        data: data.map(function (r) { return r.Teachers || 0; }),
                        backgroundColor: palA(.85), borderWidth: 2, borderColor: '#fff', hoverOffset: 8
                    }]
                }, options: {
                    cutout: '58%', responsive: true, maintainAspectRatio: false,
                    plugins: { legend: { position: 'right', labels: { boxWidth: 10, font: { size: 11 } } }, tooltip: TT },
                    animation: { animateRotate: true, duration: 1100 }
                }
            });
        }

        /* 4. Experience bar */
        function renderExp(data) {
            dc('exp');
            if (!data || !data.length) { noData('cExp', 'No data'); return; }
            var el = G('cExp'); if (!el) return;
            charts.exp = new Chart(el, {
                type: 'bar', data: {
                    labels: data.map(function (r) { return r.ExpBucket; }),
                    datasets: [{
                        label: 'Teachers', data: data.map(function (r) { return r.Teachers || 0; }),
                        backgroundColor: ['#dbeafe', '#bfdbfe', '#93c5fd', '#60a5fa', '#3b82f6'], borderRadius: 6
                    }]
                }, options: {
                    responsive: true, maintainAspectRatio: false,
                    plugins: { legend: { display: false }, tooltip: TT },
                    scales: { x: { grid: { display: false }, ticks: TICK }, y: { beginAtZero: true, grid: GRD, ticks: { ...TICK, precision: 0 } } },
                    animation: ANIM
                }
            });
        }

        /* 5. Gender donut */
        function renderGenderChart(data, cid, legId) {
            var key = 'gnd_' + cid; dc(key);
            if (!data || !data.length) { noData(cid, 'No gender data'); return; }
            var el = G(cid); if (!el) return;
            var GCOL = ['#4f46e5', '#f43f5e', '#10b981', '#f59e0b'];
            charts[key] = new Chart(el, {
                type: 'doughnut', data: {
                    labels: data.map(function (r) { return r.Gender; }),
                    datasets: [{
                        data: data.map(function (r) { return r.Total || 0; }),
                        backgroundColor: GCOL, borderWidth: 3, borderColor: '#fff', hoverOffset: 10
                    }]
                }, options: {
                    cutout: '65%', responsive: true, maintainAspectRatio: false,
                    plugins: { legend: { display: false }, tooltip: TT },
                    animation: { animateRotate: true, duration: 1100 }
                }
            });
            if (legId) {
                var leg = G(legId); if (!leg) return;
                leg.innerHTML = '';
                var tot = data.reduce(function (a, r) { return a + (r.Total || 0); }, 0) || 1;
                data.forEach(function (r, i) {
                    leg.innerHTML += '<div style="display:flex;align-items:center;gap:5px;font-size:12px;">'
                        + '<span style="width:10px;height:10px;border-radius:2px;background:' + GCOL[i] + ';display:inline-block;flex-shrink:0;"></span>'
                        + esc(r.Gender) + ' <strong style="color:' + GCOL[i] + ';">' + Math.round((r.Total || 0) / tot * 100) + '%</strong></div>';
                });
            }
        }

        /* 6. Qualification polar */
        function renderQual(data) {
            dc('qual');
            if (!data || !data.length) { noData('cQual', 'No data'); return; }
            var el = G('cQual'); if (!el) return;
            charts.qual = new Chart(el, {
                type: 'polarArea', data: {
                    labels: data.map(function (r) { return r.Qualification; }),
                    datasets: [{
                        data: data.map(function (r) { return r.Teachers || 0; }),
                        backgroundColor: palA(.72), borderColor: '#fff', borderWidth: 2
                    }]
                }, options: {
                    responsive: true, maintainAspectRatio: false,
                    plugins: { legend: { position: 'right', labels: { boxWidth: 10, font: { size: 10 } } }, tooltip: TT },
                    scales: { r: { beginAtZero: true, ticks: { font: { size: 9 } }, grid: { color: 'rgba(148,163,184,.2)' } } },
                    animation: { duration: 1100, easing: 'easeInOutBack' }
                }
            });
        }

        /* 7. Subject bar */
        function renderSubject(data) {
            dc('subj');
            if (!data || !data.length) { noData('cSubject', 'No subject data'); return; }
            var el = G('cSubject'); if (!el) return;
            var short = data.map(function (r) { var n = r.SubjectName || ''; return n.length > 14 ? n.substring(0, 13) + '…' : n; });
            charts.subj = new Chart(el, {
                type: 'bar', data: {
                    labels: short,
                    datasets: [
                        { label: 'Teachers', data: data.map(function (r) { return r.Teachers || 0; }), backgroundColor: 'rgba(79,70,229,.82)', borderRadius: 5 },
                        { label: 'Videos', data: data.map(function (r) { return r.Videos || 0; }), backgroundColor: 'rgba(139,92,246,.72)', borderRadius: 5 },
                        { label: 'Assignments', data: data.map(function (r) { return r.Assignments || 0; }), backgroundColor: 'rgba(245,158,11,.72)', borderRadius: 5 }
                    ]
                }, options: {
                    responsive: true, maintainAspectRatio: false,
                    plugins: { legend: { position: 'top', labels: { boxWidth: 10, font: { size: 11 } } }, tooltip: TT },
                    scales: { x: { grid: { display: false }, ticks: { font: { size: 10 } } }, y: { beginAtZero: true, grid: GRD, ticks: TICK } },
                    animation: ANIM
                }
            });
        }

        /* 8. Subject content (content tab) */
        function renderSubjContent(data) {
            dc('subjc');
            if (!data || !data.length) { noData('cSubjContent', 'No data'); return; }
            var el = G('cSubjContent'); if (!el) return;
            var short = data.map(function (r) { var n = r.SubjectName || ''; return n.length > 14 ? n.substring(0, 13) + '…' : n; });
            charts.subjc = new Chart(el, {
                type: 'bar', data: {
                    labels: short,
                    datasets: [
                        { label: 'Videos', data: data.map(function (r) { return r.Videos || 0; }), backgroundColor: 'rgba(124,58,237,.85)', borderRadius: 5 },
                        { label: 'Assignments', data: data.map(function (r) { return r.Assignments || 0; }), backgroundColor: 'rgba(245,158,11,.85)', borderRadius: 5 }
                    ]
                }, options: {
                    responsive: true, maintainAspectRatio: false,
                    plugins: { legend: { position: 'top', labels: { boxWidth: 10, font: { size: 11 } } }, tooltip: TT },
                    scales: { x: { grid: { display: false }, ticks: { font: { size: 10 } } }, y: { beginAtZero: true, grid: GRD, ticks: TICK } },
                    animation: ANIM
                }
            });
        }

        /* 9. Content trend stacked bar */
        function renderContentTrend(data) {
            dc('content');
            if (!data || !data.length) { noData('cContent', 'No content data'); return; }
            var el = G('cContent'); if (!el) return;
            charts.content = new Chart(el, {
                type: 'bar', data: {
                    labels: data.map(function (r) { return r.WeekLabel; }),
                    datasets: [
                        { label: 'Videos', data: data.map(function (r) { return r.Videos || 0; }), backgroundColor: 'rgba(124,58,237,.85)', borderRadius: 4, stack: 's' },
                        { label: 'Assignments', data: data.map(function (r) { return r.Assignments || 0; }), backgroundColor: 'rgba(245,158,11,.85)', borderRadius: 4, stack: 's' },
                        { label: 'Quizzes', data: data.map(function (r) { return r.Quizzes || 0; }), backgroundColor: 'rgba(16,185,129,.85)', borderRadius: 4, stack: 's' }
                    ]
                }, options: {
                    responsive: true, maintainAspectRatio: false,
                    interaction: { mode: 'index', intersect: false },
                    plugins: { legend: { position: 'top', labels: { boxWidth: 10, font: { size: 11 } } }, tooltip: TT },
                    scales: { x: { grid: { display: false }, ticks: TICK, stacked: true }, y: { grid: GRD, ticks: TICK, stacked: true } },
                    animation: ANIM
                }
            });
        }

        /* 10. Performance radar */
        function renderRadar(m) {
            dc('radar');
            if (!m) { noData('cRadar', 'No metrics data'); return; }
            var el = G('cRadar'); if (!el) return;
            var labels = ['Avg Videos', 'Avg Assigns', 'Avg Quizzes', 'Avg Students', 'Avg Views', 'Avg Score'];
            var vals = [
                parseFloat(m.avgVideos) || 0,
                parseFloat(m.avgAssignments) || 0,
                parseFloat(m.avgQuizzes) || 0,
                parseFloat(m.avgStudents) || 0,
                parseFloat(m.avgVideoViews) || 0,
                parseFloat(m.avgScore) || 0
            ];
            charts.radar = new Chart(el, {
                type: 'radar', data: {
                    labels: labels,
                    datasets: [{
                        label: 'Avg per Teacher', data: vals,
                        backgroundColor: 'rgba(79,70,229,.18)', borderColor: '#4f46e5', borderWidth: 2.5,
                        pointBackgroundColor: '#4f46e5', pointRadius: 5, pointHoverRadius: 7
                    }]
                }, options: {
                    responsive: true, maintainAspectRatio: false,
                    plugins: { legend: { display: false }, tooltip: TT },
                    scales: {
                        r: {
                            beginAtZero: true, ticks: { font: { size: 9 } }, grid: { color: 'rgba(148,163,184,.2)' },
                            pointLabels: { font: { size: 11 } }
                        }
                    },
                    animation: { duration: 1100, easing: 'easeInOutBack' }
                }
            });
        }

        /* 11. Stream progress bars */
        function renderStreamBars(data) {
            var wrap = G('streamBars'); if (!wrap) return;
            wrap.innerHTML = '';
            if (!data || !data.length) { wrap.innerHTML = '<div class="empty"><i class="fa fa-layer-group"></i><p>No data</p></div>'; return; }
            var max = Math.max.apply(null, data.map(function (r) { return r.Teachers || 0; })) || 1;
            data.forEach(function (r, i) {
                var pct = Math.round((r.Teachers || 0) / max * 100);
                wrap.innerHTML += '<div class="pi">'
                    + '<div class="pi-lbl"><span>' + esc(r.StreamName) + '</span><span>' + esc(r.Teachers || 0) + ' teachers</span></div>'
                    + '<div class="pi-track"><div class="pi-fill" data-w="' + pct + '%" style="background:' + PAL[i % PAL.length] + ';"></div></div>'
                    + '</div>';
            });
            setTimeout(function () { wrap.querySelectorAll('.pi-fill[data-w]').forEach(function (el) { el.style.width = el.dataset.w; }); }, 300);
        }

        /* ════════════════════════════════════════════════════════
           TEACHER TABLE
        ════════════════════════════════════════════════════════ */
        function renderTable(d) {
            var tbody = G('tTbody'), pagInfo = G('pagInfo'), pagBtns = G('pagBtns'), recLbl = G('recCount');
            if (!d.teachers || !d.teachers.length) {
                tbody.innerHTML = '<tr><td colspan="14"><div class="empty"><i class="fa fa-chalkboard-user"></i><p>No teachers match the filters</p></div></td></tr>';
                pagInfo.innerText = ''; pagBtns.innerHTML = ''; recLbl.innerText = '0 records';
                return;
            }
            totPages = d.pageCount || 1; curPage = d.pageIndex || 0;
            var skip = curPage * d.pageSize;
            recLbl.innerText = d.totalCount + ' teachers found';
            var html = '';
            d.teachers.forEach(function (t, i) {
                var score = parseFloat(t.AvgStudentScore) || 0;
                var init = (t.FullName || '?').substring(0, 1).toUpperCase();
                var img = t.ProfileImage ? '<img src="' + esc(t.ProfileImage) + '" alt=""/>' : init;
                var scoreCol = score >= 70 ? '#065f46' : score >= 50 ? '#92400e' : '#991b1b';
                html += '<tr>'
                    + '<td style="color:var(--tm);font-size:11px;">' + (skip + i + 1) + '</td>'
                    + '<td><div style="display:flex;align-items:center;gap:8px;">'
                    + '<div class="tav">' + img + '</div>'
                    + '<div><div class="t-name">' + esc(t.FullName || '') + '</div>'
                    + '<div class="t-emp">' + esc(t.TeacherEmail || '') + '</div></div>'
                    + '</div></td>'
                    + '<td style="font-size:12px;font-weight:600;">' + esc(t.EmployeeId || '—') + '</td>'
                    + '<td><div style="font-size:12px;font-weight:600;">' + esc(t.StreamName || '—') + '</div>'
                    + '<div style="font-size:11px;color:var(--ts);">' + esc(t.SectionName || '—') + '</div></td>'
                    + '<td style="font-size:12px;">' + esc(t.Designation || '—') + '</td>'
                    + '<td style="font-size:11px;color:var(--ts);">' + esc(t.Qualification || '—') + '</td>'
                    + '<td style="font-size:12px;font-weight:700;color:var(--p);">' + esc(t.ExperienceYears || 0) + ' yrs</td>'
                    + '<td style="font-size:12px;">' + esc(t.Gender || '—') + '</td>'
                    + '<td style="font-size:11px;color:var(--ts);">' + esc(t.JoinedDate || '—') + '</td>'
                    + '<td><span class="ac acv"><i class="fa fa-video"></i>' + esc(t.VideoCount || 0) + '</span></td>'
                    + '<td><span class="ac aca"><i class="fa fa-clipboard"></i>' + esc(t.AssignCount || 0) + '</span></td>'
                    + '<td><span class="ac acq"><i class="fa fa-circle-question"></i>' + esc(t.QuizCount || 0) + '</span></td>'
                    + '<td><span style="padding:2px 8px;border-radius:99px;font-size:11px;font-weight:800;'
                    + 'background:' + scoreCol + '22;color:' + scoreCol + ';">' + score + '</span></td>'
                    + '<td><span class="sp ' + (t.Status === 'Active' ? 'sp-a' : 'sp-i') + '">' + esc(t.Status || '—') + '</span>'
                    + (t.JoinType === 'New' ? '<span class="sp sp-n" style="margin-left:3px;">New</span>' : '') + '</td>'
                    + '</tr>';
            });
            tbody.innerHTML = html;

            /* Pagination */
            pagInfo.innerText = 'Showing ' + (skip + 1) + '–' + Math.min(skip + d.pageSize, d.totalCount) + ' of ' + d.totalCount;
            var btns = '<button type="button" class="pbtn" data-pg="' + (curPage - 1) + '" ' + (curPage === 0 ? 'disabled' : '') + '>'
                + '<i class="fa fa-chevron-left"></i></button>';
            var st = Math.max(0, curPage - 2), en = Math.min(totPages - 1, st + 4);
            for (var p = st; p <= en; p++)
                btns += '<button type="button" class="pbtn ' + (p === curPage ? 'on' : '') + '" data-pg="' + p + '">' + (p + 1) + '</button>';
            btns += '<button type="button" class="pbtn" data-pg="' + (curPage + 1) + '" ' + (curPage >= totPages - 1 ? 'disabled' : '') + '>'
                + '<i class="fa fa-chevron-right"></i></button>';
            pagBtns.innerHTML = btns;
            /* Wire pagination buttons — type=button already, no postback */
            pagBtns.querySelectorAll('.pbtn[data-pg]').forEach(function (btn) {
                btn.addEventListener('click', function (e) {
                    e.preventDefault();
                    if (this.disabled) return;
                    go(parseInt(this.dataset.pg) || 0);
                });
            });
        }

        /* ════════════════════════════════════════════════════════
           TOP TEACHERS
        ════════════════════════════════════════════════════════ */
        function renderTopTeachers(data) {
            var wrap = G('topList'); if (!wrap) return;
            if (!data || !data.length) {
                wrap.innerHTML = '<div class="empty"><i class="fa fa-chalkboard-user"></i><p>No data</p></div>';
                return;
            }
            var html = '';
            data.forEach(function (t, i) {
                var init = (t.FullName || '?').substring(0, 1).toUpperCase();
                var img = t.ProfileImage ? '<img src="' + esc(t.ProfileImage) + '" alt=""/>' : init;
                var rank = i < 3 ? 'r' + (i + 1) : 'rn';
                html += '<div class="ti">'
                    + '<div class="ti-rank ' + rank + '">' + (i + 1) + '</div>'
                    + '<div class="ti-av">' + img + '</div>'
                    + '<div style="flex:1;min-width:0;">'
                    + '<div class="ti-name">' + esc(t.FullName || '') + '</div>'
                    + '<div class="ti-des">' + esc(t.Designation || 'Teacher') + ' &bull; ' + esc(t.StreamName || '—') + ' &bull; ' + esc(t.ExperienceYears || 0) + ' yrs</div>'
                    + '<div style="display:flex;flex-wrap:wrap;gap:4px;margin-top:4px;">'
                    + '<span class="ac acv"><i class="fa fa-video"></i>' + esc(t.Videos || 0) + '</span>'
                    + '<span class="ac aca"><i class="fa fa-clipboard"></i>' + esc(t.Assignments || 0) + '</span>'
                    + '<span class="ac acq"><i class="fa fa-circle-question"></i>' + esc(t.Quizzes || 0) + '</span>'
                    + '<span class="ac acs"><i class="fa fa-users"></i>' + esc(t.StudentsReached || 0) + '</span>'
                    + '</div>'
                    + '</div>'
                    + '<div class="ti-right">'
                    + '<div class="ti-score">' + (t.TotalActivity || 0) + ' acts</div>'
                    + '<div class="ti-sub">Avg score: ' + esc(t.AvgStudentScore || 0) + '</div>'
                    + '<div class="ti-sub">' + esc(t.VideoViews || 0) + ' views</div>'
                    + '</div>'
                    + '</div>';
            });
            wrap.innerHTML = html;
        }

        /* ════════════════════════════════════════════════════════
           CONTENT BARS
        ════════════════════════════════════════════════════════ */
        function renderContentBars(data) {
            var wrap = G('contentBars'); if (!wrap) return;
            wrap.innerHTML = '';
            if (!data || !data.length) { wrap.innerHTML = '<div class="empty"><i class="fa fa-video"></i><p>No data</p></div>'; return; }
            var top = data.slice(0, 8);
            var max = Math.max.apply(null, top.map(function (t) { return t.TotalActivity || 0; })) || 1;
            top.forEach(function (t, i) {
                var pct = Math.round((t.TotalActivity || 0) / max * 100);
                var name = (t.FullName || '').length > 20 ? t.FullName.substring(0, 19) + '…' : t.FullName;
                wrap.innerHTML += '<div class="pi">'
                    + '<div class="pi-lbl"><span title="' + esc(t.FullName) + '">' + esc(name) + '</span>'
                    + '<span>' + esc(t.TotalActivity || 0) + ' activities</span></div>'
                    + '<div class="pi-track"><div class="pi-fill" data-w="' + pct + '%" style="background:' + PAL[i % PAL.length] + ';"></div></div>'
                    + '</div>';
            });
            setTimeout(function () { wrap.querySelectorAll('.pi-fill[data-w]').forEach(function (el) { el.style.width = el.dataset.w; }); }, 300);
        }

        /* ════════════════════════════════════════════════════════
           ACTIVITY FEED
        ════════════════════════════════════════════════════════ */
        function renderActivity(data) {
            var wrap = G('actFeed'); if (!wrap) return;
            if (!data || !data.length) {
                wrap.innerHTML = '<div class="empty"><i class="fa fa-bell"></i><p>No recent activity</p></div>';
                return;
            }
            var html = '';
            data.forEach(function (a) {
                var init = (a.FullName || '?').substring(0, 1).toUpperCase();
                var img = a.ProfileImage ? '<img src="' + esc(a.ProfileImage) + '" alt=""/>' : init;
                var time = a.ActionTime ? new Date(a.ActionTime).toLocaleString('en-IN', { day: '2-digit', month: 'short', hour: '2-digit', minute: '2-digit' }) : '—';
                html += '<div class="act-item">'
                    + '<div class="act-av">' + img + '</div>'
                    + '<div style="flex:1;min-width:0;">'
                    + '<div class="act-name">' + esc(a.FullName || '') + '</div>'
                    + '<div class="act-type">' + esc(a.ActivityType || '—') + ' &bull; ' + esc(a.Designation || 'Teacher') + '</div>'
                    + '</div>'
                    + '<div class="act-time">' + time + '</div>'
                    + '</div>';
            });
            wrap.innerHTML = html;
        }

        /* ════════════════════════════════════════════════════════
           CSV EXPORT
        ════════════════════════════════════════════════════════ */
        function doExport() {
            if (!lastData || !lastData.teachers || !lastData.teachers.length) {
                alert('No data to export. Apply filters first.'); return;
            }
            var H = ['Name', 'EmpID', 'Stream', 'Section', 'Designation', 'Qualification', 'Exp', 'Gender',
                'Joined', 'Videos', 'Assignments', 'Quizzes', 'AvgStudentScore', 'Status'];
            var R = lastData.teachers.map(function (t) {
                return [t.FullName, t.EmployeeId, t.StreamName, t.SectionName, t.Designation,
                t.Qualification, t.ExperienceYears, t.Gender, t.JoinedDate,
                t.VideoCount, t.AssignCount, t.QuizCount, t.AvgStudentScore, t.Status]
                    .map(function (v) { return '"' + String(v || '').replace(/"/g, '""') + '"'; });
            });
            var csv = [H].concat(R).map(function (r) { return r.join(','); }).join('\n');
            var a = document.createElement('a');
            a.href = 'data:text/csv;charset=utf-8,' + encodeURIComponent(csv);
            a.download = 'teachers_' + new Date().toISOString().slice(0, 10) + '.csv';
            a.click();
        }

        /* ════════════════════════════════════════════════════════
           UTILITY
        ════════════════════════════════════════════════════════ */
        function esc(s) {
            return String(s || '').replace(/&/g, '&amp;').replace(/</g, '&lt;')
                .replace(/>/g, '&gt;').replace(/"/g, '&quot;');
        }

        /* ════════════════════════════════════════════════════════
           INITIAL LOAD
        ════════════════════════════════════════════════════════ */
        setTimeout(function () { go(0); }, 120);

    })();
</script>
</asp:Content>
