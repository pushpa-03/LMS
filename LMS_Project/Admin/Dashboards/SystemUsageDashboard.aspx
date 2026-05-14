<%@ Page Title="System Usage Dashboard" Language="C#"
    MasterPageFile="~/Admin/AdminMaster.Master"
    AutoEventWireup="true"
    CodeBehind="SystemUsageDashboard.aspx.cs"
    Inherits="LearningManagementSystem.Admin.SystemUsageDashboard" %>

<asp:Content ID="cHead" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet"/>
<style>
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
  --cy:#0891b2;--cyl:#cffafe;
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
  min-height:158px;box-shadow:var(--shm);
  background:linear-gradient(135deg,#0f172a 0%,#1e3a5f 40%,#1d4ed8 80%,#3b82f6 100%);}
.b-ov{position:absolute;inset:0;background:linear-gradient(105deg,rgba(5,10,30,.72),rgba(5,10,30,.18));z-index:1;}
.b-body{position:relative;z-index:2;display:flex;align-items:center;
  justify-content:space-between;padding:24px 36px;gap:20px;flex-wrap:wrap;}
.b-title{font-size:24px;font-weight:800;color:#fff;}
.b-sub{font-size:13px;color:rgba(255,255,255,.65);margin-top:4px;}
.b-kpis{display:flex;gap:16px;margin-top:14px;flex-wrap:wrap;}
.bk{text-align:center;}
.bk-v{font-size:20px;font-weight:900;color:#fff;line-height:1;transition:all .5s;}
.bk-l{font-size:9px;color:rgba(255,255,255,.52);text-transform:uppercase;letter-spacing:.05em;margin-top:2px;}
.bdiv{width:1px;background:rgba(255,255,255,.18);align-self:stretch;}
.live-pill{background:rgba(16,185,129,.22);border:1px solid rgba(16,185,129,.42);
  color:#a7f3d0;padding:5px 14px;border-radius:20px;font-size:11px;font-weight:700;
  display:inline-flex;align-items:center;gap:6px;}
.ldot{width:7px;height:7px;border-radius:50%;background:#10b981;animation:pulse 1.4s infinite;}
@keyframes pulse{0%,100%{opacity:1;transform:scale(1)}50%{opacity:.4;transform:scale(.7)}}
.btn-ew{padding:9px 18px;background:rgba(255,255,255,.13);color:#fff;
  border:1px solid rgba(255,255,255,.26);border-radius:var(--rads);
  font-size:12px;font-weight:700;cursor:pointer;transition:.2s;
  display:inline-flex;align-items:center;gap:7px;}
.btn-ew:hover{background:rgba(255,255,255,.24);}
.gspin{display:inline-block;width:18px;height:18px;border:2px solid rgba(255,255,255,.22);
  border-top-color:#60a5fa;border-radius:50%;animation:spin .7s linear infinite;}
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
.fg{display:flex;flex-direction:column;gap:4px;min-width:115px;flex:1;}
.fg label{font-size:11px;font-weight:600;color:var(--ts);}
.fsel,.fdate{padding:8px 10px;border:1.5px solid var(--bd);border-radius:var(--rads);
  font-size:13px;color:var(--tx);background:#fff;width:100%;transition:.15s;}
.fsel:focus,.fdate:focus{border-color:var(--p);outline:none;box-shadow:0 0 0 3px rgba(79,70,229,.1);}
.lbar{height:3px;background:linear-gradient(90deg,var(--p),var(--b),var(--g));
  width:0%;border-radius:2px;transition:width .4s;margin-top:10px;}
.afc{display:flex;flex-wrap:wrap;gap:6px;margin-top:10px;}
.afc-chip{background:var(--pl);color:var(--p);padding:3px 10px;border-radius:99px;
  font-size:11px;font-weight:600;display:inline-flex;align-items:center;gap:5px;cursor:pointer;}
.afc-chip:hover{background:var(--bl);color:var(--b);}
.qr-row{display:flex;gap:6px;flex-wrap:wrap;margin-top:10px;}
.qr{padding:4px 12px;border:1px solid var(--bd);border-radius:99px;font-size:11px;
  font-weight:600;cursor:pointer;transition:.15s;background:#fff;color:var(--ts);}
.qr:hover,.qr.on{background:var(--p);color:#fff;border-color:var(--p);}

/* KPI grid */
.kpi-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(145px,1fr));
  gap:12px;margin-bottom:20px;}
.kpi{background:var(--bg);border:1px solid var(--bd);border-radius:var(--rad);
  padding:16px 15px;box-shadow:var(--sh);position:relative;overflow:hidden;transition:.18s;}
.kpi:hover{transform:translateY(-3px);box-shadow:var(--shm);}
.kpi::before{content:'';position:absolute;top:0;left:0;right:0;height:3px;border-radius:var(--rad) var(--rad) 0 0;}
.kb::before{background:var(--b);} .kg::before{background:var(--g);}
.kp::before{background:var(--p);} .kw::before{background:var(--w);}
.kt::before{background:var(--t);} .kr::before{background:var(--r);}
.kor::before{background:var(--or);} .kpu::before{background:var(--pu);}
.kcy::before{background:var(--cy);}
.kpi-top{display:flex;align-items:center;justify-content:space-between;margin-bottom:10px;}
.klbl{font-size:10px;font-weight:700;color:var(--ts);text-transform:uppercase;letter-spacing:.06em;}
.kico{width:38px;height:38px;border-radius:10px;display:flex;align-items:center;justify-content:center;font-size:16px;}
.ib{background:var(--bl);color:var(--b);} .ig{background:var(--gl);color:var(--g);}
.ip{background:var(--pl);color:var(--p);} .iw{background:var(--wl);color:var(--w);}
.it{background:var(--tl);color:var(--t);} .ir{background:var(--rl);color:var(--r);}
.ior{background:var(--orl);color:var(--or);} .ipu{background:var(--pul);color:var(--pu);}
.icy{background:var(--cyl);color:var(--cy);}
.kval{font-size:26px;font-weight:900;color:var(--tx);line-height:1;letter-spacing:-.5px;transition:all .4s;}
.ksub{font-size:11px;color:var(--tm);margin-top:4px;}

/* Tabs */
.tab-bar{display:flex;gap:2px;background:var(--pg);border-radius:10px;padding:4px;margin-bottom:18px;flex-wrap:wrap;}
.tab-btn{padding:9px 16px;border:none;background:transparent;border-radius:8px;
  font-size:13px;font-weight:600;color:var(--ts);cursor:pointer;transition:.18s;
  display:flex;align-items:center;gap:6px;white-space:nowrap;outline:none;}
.tab-btn.on{background:var(--bg);color:var(--p);box-shadow:var(--sh);}
.tab-btn:hover:not(.on){background:rgba(255,255,255,.55);}
.tab-pane{display:none;}
.tab-pane.on{display:block;animation:tabIn .22s ease;}
@keyframes tabIn{from{opacity:0;transform:translateY(5px)}to{opacity:1;transform:none}}

/* Card */
.card{background:var(--bg);border:1px solid var(--bd);border-radius:var(--rad);
  box-shadow:var(--sh);padding:20px;transition:box-shadow .18s;}
.card:hover{box-shadow:var(--shm);}
.card-hd{display:flex;align-items:flex-start;justify-content:space-between;margin-bottom:16px;gap:8px;flex-wrap:wrap;}
.card-hd-l{display:flex;align-items:center;gap:10px;}
.cico{width:32px;height:32px;border-radius:9px;display:flex;align-items:center;justify-content:center;font-size:14px;flex-shrink:0;}
.ct{font-size:14px;font-weight:700;color:var(--tx);}
.cs{font-size:12px;color:var(--ts);margin-top:1px;}
.cb{position:relative;width:100%;}
.g2{display:grid;grid-template-columns:1fr 1fr;gap:16px;margin-bottom:18px;}
.g3{display:grid;grid-template-columns:1fr 1fr 1fr;gap:16px;margin-bottom:18px;}
.g21{display:grid;grid-template-columns:2fr 1fr;gap:16px;margin-bottom:18px;}
.g12{display:grid;grid-template-columns:1fr 2fr;gap:16px;margin-bottom:18px;}

/* User table */
.utbl{width:100%;border-collapse:collapse;font-size:13px;}
.utbl th{font-size:10px;font-weight:700;color:var(--ts);text-transform:uppercase;
  letter-spacing:.04em;padding:8px 12px;border-bottom:2px solid var(--bd);text-align:left;white-space:nowrap;}
.utbl td{padding:10px 12px;border-bottom:1px solid var(--bd);vertical-align:middle;}
.utbl tr:hover td{background:#f7f8ff;}
.utbl tr:last-child td{border-bottom:none;}
.uav{width:36px;height:36px;border-radius:50%;background:var(--pl);color:var(--p);
  display:flex;align-items:center;justify-content:center;font-size:13px;font-weight:800;
  flex-shrink:0;overflow:hidden;border:2px solid var(--bd);}
.uav img{width:100%;height:100%;object-fit:cover;}
.uname{font-weight:700;color:var(--tx);}
.urole{font-size:11px;color:var(--tm);}
.role-pill{padding:2px 8px;border-radius:99px;font-size:11px;font-weight:700;}
.rp-stu{background:var(--bl);color:#1d4ed8;}
.rp-tch{background:var(--gl);color:#065f46;}
.rp-adm{background:var(--pul);color:var(--pd);}
.rp-def{background:var(--pg);color:var(--ts);}

/* Progress bars */
.pi{margin-bottom:12px;}
.pi-lbl{display:flex;justify-content:space-between;font-size:12px;font-weight:500;color:var(--tx);margin-bottom:4px;}
.pi-lbl span:last-child{color:var(--ts);}
.pi-track{height:8px;background:var(--bd);border-radius:99px;overflow:hidden;}
.pi-fill{height:8px;border-radius:99px;transition:width 1.1s ease;width:0%;}

/* Activity feed */
.act-item{display:flex;align-items:flex-start;gap:10px;padding:9px 0;border-bottom:1px solid var(--bd);}
.act-item:last-child{border:none;}
.act-ico{width:34px;height:34px;border-radius:9px;flex-shrink:0;display:flex;align-items:center;justify-content:center;font-size:13px;}
.act-name{font-size:13px;font-weight:600;color:var(--tx);}
.act-type{font-size:11px;color:var(--ts);margin-top:1px;}
.act-time{margin-left:auto;font-size:10px;color:var(--tm);white-space:nowrap;flex-shrink:0;}

/* Rank badges */
.rk{width:22px;height:22px;border-radius:50%;display:flex;align-items:center;
  justify-content:center;font-size:11px;font-weight:800;flex-shrink:0;}
.r1{background:#fef3c7;color:#b45309;} .r2{background:#f3f4f6;color:#374151;}
.r3{background:#fde8d8;color:#c05621;} .rn{background:var(--pg);color:var(--ts);}

/* Suggestion card */
.sugg-card{background:linear-gradient(135deg,#0f172a,#1e3a5f,#1d4ed8);
  border-radius:var(--rad);padding:20px;color:#fff;margin-bottom:18px;box-shadow:var(--shm);}
.sugg-title{font-size:16px;font-weight:800;margin-bottom:14px;display:flex;align-items:center;gap:8px;}
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

/* Engagement bar inside table */
.eng-wrap{display:flex;align-items:center;gap:6px;}
.eng-bg{width:60px;height:5px;background:var(--bd);border-radius:99px;overflow:hidden;flex-shrink:0;}
.eng-fg{height:5px;border-radius:99px;background:var(--p);}

/* Empty / spinner */
.empty{text-align:center;padding:40px;color:var(--tm);}
.empty i{font-size:32px;display:block;margin-bottom:10px;opacity:.4;}
.empty p{font-size:13px;}
.spin{display:inline-block;width:20px;height:20px;border:2px solid var(--bd);
  border-top-color:var(--p);border-radius:50%;animation:spin .7s linear infinite;}

@media(max-width:1100px){.g21,.g12{grid-template-columns:1fr;}.g3{grid-template-columns:1fr 1fr;}}
@media(max-width:700px){.g2,.g3{grid-template-columns:1fr;}.kpi-grid{grid-template-columns:1fr 1fr;}}
@media(max-width:460px){.kpi-grid{grid-template-columns:1fr 1fr;}.tab-btn{font-size:11px;padding:7px 10px;}}
</style>
</asp:Content>

<asp:Content ID="cBody" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

<asp:HiddenField ID="hdnInst" runat="server"/>
<asp:HiddenField ID="hdnSess" runat="server"/>
<asp:HiddenField ID="hdnDfr"  runat="server"/>
<asp:HiddenField ID="hdnDto"  runat="server"/>
<asp:Label       ID="lblSess" runat="server" Style="display:none;"/>
<asp:DropDownList ID="aspRole"   runat="server" Style="display:none;"/>
<asp:DropDownList ID="aspStream" runat="server" Style="display:none;"/>

<div class="wrap">

<!-- BANNER -->
<div class="banner">
  <div class="b-ov"></div>
  <div class="b-body">
    <div>
      <div style="font-size:11px;font-weight:700;color:rgba(255,255,255,.5);text-transform:uppercase;letter-spacing:.1em;margin-bottom:5px;">
        <i class="fa fa-gauge-high" style="margin-right:5px;"></i>System Usage
      </div>
      <div class="b-title">System Usage Dashboard</div>
      <div class="b-sub">Session: <span id="bSess"></span> &nbsp;&bull;&nbsp; Real-time platform engagement analytics</div>
      <div class="b-kpis">
        <div class="bk"><div class="bk-v" id="bLogins">—</div><div class="bk-l">Logins</div></div>
        <div class="bdiv"></div>
        <div class="bk"><div class="bk-v" id="bUsers">—</div><div class="bk-l">Active Users</div></div>
        <div class="bdiv"></div>
        <div class="bk"><div class="bk-v" id="bToday">—</div><div class="bk-l">Today</div></div>
        <div class="bdiv"></div>
        <div class="bk"><div class="bk-v" id="bVideos">—</div><div class="bk-l">Video Views</div></div>
        <div class="bdiv"></div>
        <div class="bk"><div class="bk-v" id="bAI">—</div><div class="bk-l">AI Uses</div></div>
      </div>
    </div>
    <div style="display:flex;flex-direction:column;align-items:flex-end;gap:10px;">
      <div class="live-pill"><span class="ldot"></span>Live</div>
      <button type="button" class="btn-ew" onclick="doExport()"><i class="fa fa-file-csv"></i>Export</button>
      <div class="gspin" id="gSpin" style="display:none;"></div>
    </div>
  </div>
</div>

<!-- FILTER BAR -->
<div class="fb">
  <div class="fb-hd">
    <div class="fb-lbl"><i class="fa fa-sliders"></i>Filters</div>
    <div class="fb-acts">
      <button type="button" class="btn-rs" id="btnReset"><i class="fa fa-rotate"></i> Reset</button>
      <button type="button" class="btn-ap" id="btnApply"><i class="fa fa-magnifying-glass"></i> Apply</button>
    </div>
  </div>
  <div class="f-row">
    <div class="fg"><label>Role</label>
      <select id="fRole" class="fsel"><option value="">All Roles</option></select>
    </div>
    <div class="fg" style="min-width:130px;"><label>From Date</label>
      <input type="date" id="fDfr" class="fdate"/>
    </div>
    <div class="fg" style="min-width:130px;"><label>To Date</label>
      <input type="date" id="fDto" class="fdate"/>
    </div>
  </div>
  <div class="qr-row">
    <button type="button" class="qr" data-days="7">Last 7 Days</button>
    <button type="button" class="qr on" data-days="30">Last 30 Days</button>
    <button type="button" class="qr" data-curmon="1">This Month</button>
    <button type="button" class="qr" data-days="90">Last 3 Months</button>
    <button type="button" class="qr" data-full="1">Full Session</button>
  </div>
  <div class="lbar" id="lbar"></div>
  <div class="afc" id="afcWrap"></div>
</div>

<!-- KPI CARDS -->
<div class="kpi-grid">
  <div class="kpi kb"><div class="kpi-top"><span class="klbl">Total Logins</span><div class="kico ib"><i class="fa fa-right-to-bracket"></i></div></div>
    <div class="kval" id="kLogins">—</div><div class="ksub">In selected period</div></div>
  <div class="kpi kg"><div class="kpi-top"><span class="klbl">Active Users</span><div class="kico ig"><i class="fa fa-users"></i></div></div>
    <div class="kval" id="kUsers">—</div><div class="ksub">Unique in period</div></div>
  <div class="kpi kw"><div class="kpi-top"><span class="klbl">Today's Logins</span><div class="kico iw"><i class="fa fa-calendar-day"></i></div></div>
    <div class="kval" id="kToday">—</div><div class="ksub">Live today</div></div>
  <div class="kpi kb"><div class="kpi-top"><span class="klbl">Video Views</span><div class="kico ib"><i class="fa fa-play-circle"></i></div></div>
    <div class="kval" id="kVideos">—</div><div class="ksub">Content watched</div></div>
  <div class="kpi kt"><div class="kpi-top"><span class="klbl">Quiz Attempts</span><div class="kico it"><i class="fa fa-circle-question"></i></div></div>
    <div class="kval" id="kQuizzes">—</div><div class="ksub">Total attempts</div></div>
  <div class="kpi kor"><div class="kpi-top"><span class="klbl">Submissions</span><div class="kico ior"><i class="fa fa-clipboard-check"></i></div></div>
    <div class="kval" id="kSubmit">—</div><div class="ksub">Assignment submissions</div></div>
  <div class="kpi kpu"><div class="kpi-top"><span class="klbl">AI Uses</span><div class="kico ipu"><i class="fa fa-robot"></i></div></div>
    <div class="kval" id="kAI">—</div><div class="ksub">AI feature interactions</div></div>
  <div class="kpi kr"><div class="kpi-top"><span class="klbl">Help Requests</span><div class="kico ir"><i class="fa fa-circle-info"></i></div></div>
    <div class="kval" id="kHelp">—</div><div class="ksub">Support tickets</div></div>
  <div class="kpi kcy"><div class="kpi-top"><span class="klbl">Total Students</span><div class="kico icy"><i class="fa fa-user-graduate"></i></div></div>
    <div class="kval" id="kStu">—</div><div class="ksub">Enrolled</div></div>
  <div class="kpi kg"><div class="kpi-top"><span class="klbl">Total Teachers</span><div class="kico ig"><i class="fa fa-chalkboard-user"></i></div></div>
    <div class="kval" id="kTeach">—</div><div class="ksub">Active faculty</div></div>
</div>

<!-- TABS -->
<div class="tab-bar" id="tabBar">
  <button type="button" class="tab-btn on" data-tab="overview"><i class="fa fa-chart-pie"></i>Overview</button>
  <button type="button" class="tab-btn" data-tab="users"><i class="fa fa-users"></i>Top Users</button>
  <button type="button" class="tab-btn" data-tab="features"><i class="fa fa-layer-group"></i>Feature Usage</button>
  <button type="button" class="tab-btn" data-tab="activity"><i class="fa fa-bolt"></i>Activity Feed</button>
  <button type="button" class="tab-btn" data-tab="inactive"><i class="fa fa-user-xmark"></i>Inactive Users</button>
  <button type="button" class="tab-btn" data-tab="insights"><i class="fa fa-lightbulb"></i>Admin Insights</button>
</div>

<!-- TAB: OVERVIEW -->
<div id="tab-overview" class="tab-pane on">
  <div class="g21">
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--bl);color:var(--b);"><i class="fa fa-chart-line"></i></div>
          <div><div class="ct">Daily Login Trend</div><div class="cs">Student · Teacher · Admin logins per day</div></div>
        </div>
        <span id="trendTotal" style="font-size:11px;color:var(--tm);"></span>
      </div>
      <div class="cb" style="height:250px;"><canvas id="cTrend"></canvas></div>
    </div>
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--pul);color:var(--pu);"><i class="fa fa-chart-pie"></i></div>
          <div><div class="ct">Activity by Role</div></div>
        </div>
      </div>
      <div class="cb" style="height:210px;"><canvas id="cRole"></canvas></div>
      <div id="roleLeg" style="display:flex;flex-wrap:wrap;gap:6px;justify-content:center;margin-top:10px;"></div>
    </div>
  </div>
  <div class="g3">
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--tl);color:var(--t);"><i class="fa fa-clock"></i></div>
          <div><div class="ct">Hourly Pattern</div><div class="cs">Peak usage hours</div></div>
        </div>
      </div>
      <div class="cb" style="height:200px;"><canvas id="cHourly"></canvas></div>
    </div>
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--wl);color:var(--w);"><i class="fa fa-calendar-days"></i></div>
          <div><div class="ct">Day-of-Week</div><div class="cs">Which days are busiest?</div></div>
        </div>
      </div>
      <div class="cb" style="height:200px;"><canvas id="cDow"></canvas></div>
    </div>
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--gl);color:var(--g);"><i class="fa fa-calendar-week"></i></div>
          <div><div class="ct">Weekly Trend</div><div class="cs">Last 8 weeks</div></div>
        </div>
      </div>
      <div class="cb" style="height:200px;"><canvas id="cWeekly"></canvas></div>
    </div>
  </div>
  <div class="g2">
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--cyl);color:var(--cy);"><i class="fa fa-layer-group"></i></div>
          <div><div class="ct">Stream-wise Engagement</div><div class="cs">Active users &amp; engagement rate</div></div>
        </div>
      </div>
      <div class="cb" style="height:230px;"><canvas id="cStream"></canvas></div>
    </div>
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--orl);color:var(--or);"><i class="fa fa-chart-bar"></i></div>
          <div><div class="ct">Feature Popularity</div><div class="cs">Most-used platform features</div></div>
        </div>
      </div>
      <div class="cb" style="height:230px;"><canvas id="cFeature"></canvas></div>
    </div>
  </div>
</div>

<!-- TAB: TOP USERS -->
<div id="tab-users" class="tab-pane">
  <div class="card">
    <div class="card-hd">
      <div class="card-hd-l">
        <div class="cico" style="background:var(--wl);color:var(--w);"><i class="fa fa-medal"></i></div>
        <div><div class="ct">Top 15 Most Active Users</div><div class="cs">Ranked by total platform actions</div></div>
      </div>
      <span id="topCount" style="font-size:11px;color:var(--tm);"></span>
    </div>
    <div style="overflow-x:auto;">
      <table class="utbl">
        <thead>
          <tr>
            <th>#</th><th>User</th><th>Role</th><th>Total Actions</th>
            <th>Active Days</th><th>Video Views</th><th>Quizzes</th>
            <th>Last Seen</th><th>Engagement</th>
          </tr>
        </thead>
        <tbody id="topTbody">
          <tr><td colspan="9"><div class="empty"><div class="spin"></div></div></td></tr>
        </tbody>
      </table>
    </div>
  </div>
</div>

<!-- TAB: FEATURE USAGE -->
<div id="tab-features" class="tab-pane">
  <div class="g12">
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--pl);color:var(--p);"><i class="fa fa-layer-group"></i></div>
          <div><div class="ct">Feature Usage Breakdown</div><div class="cs">Which platform features are most used?</div></div>
        </div>
      </div>
      <div id="featureBars"></div>
    </div>
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--tl);color:var(--t);"><i class="fa fa-chart-pie"></i></div>
          <div><div class="ct">Usage Distribution</div></div>
        </div>
      </div>
      <div class="cb" style="height:280px;"><canvas id="cFeatureDonut"></canvas></div>
      <div id="featureDonutLeg" style="display:flex;flex-wrap:wrap;gap:6px;justify-content:center;margin-top:10px;"></div>
    </div>
  </div>
  <div class="card" style="margin-bottom:18px;">
    <div class="card-hd">
      <div class="card-hd-l">
        <div class="cico" style="background:var(--gl);color:var(--g);"><i class="fa fa-table"></i></div>
        <div><div class="ct">Feature Details</div><div class="cs">Total uses &amp; unique users per feature</div></div>
      </div>
    </div>
    <div style="overflow-x:auto;">
      <table class="utbl" id="featureTable">
        <thead><tr><th>#</th><th>Feature</th><th>Total Uses</th><th>Unique Users</th><th>Usage Share</th></tr></thead>
        <tbody id="featureTbody"><tr><td colspan="5"><div class="empty"><div class="spin"></div></div></td></tr></tbody>
      </table>
    </div>
  </div>
</div>

<!-- TAB: ACTIVITY FEED -->
<div id="tab-activity" class="tab-pane">
  <div class="g21">
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--pl);color:var(--p);"><i class="fa fa-bolt"></i></div>
          <div><div class="ct">Recent Activity Feed</div><div class="cs">Latest 20 platform actions</div></div>
        </div>
        <button type="button" class="btn-ap" style="font-size:11px;padding:5px 12px;" onclick="go()">
          <i class="fa fa-rotate"></i> Refresh
        </button>
      </div>
      <div id="actFeed"><div class="empty"><div class="spin"></div></div></div>
    </div>
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--wl);color:var(--w);"><i class="fa fa-chart-bar"></i></div>
          <div><div class="ct">Stream Engagement</div><div class="cs">Active ratio per stream</div></div>
        </div>
      </div>
      <div id="streamBars"></div>
    </div>
  </div>
</div>

<!-- TAB: INACTIVE USERS -->
<div id="tab-inactive" class="tab-pane">
  <div class="g12">
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--rl);color:var(--r);"><i class="fa fa-user-xmark"></i></div>
          <div><div class="ct">Inactive Users</div><div class="cs">Not logged in for 14+ days</div></div>
        </div>
        <span id="inactiveCount" style="font-size:11px;color:var(--tm);"></span>
      </div>
      <div id="inactiveList"><div class="empty"><div class="spin"></div></div></div>
    </div>
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--wl);color:var(--w);"><i class="fa fa-chart-pie"></i></div>
          <div><div class="ct">Active vs Inactive</div></div>
        </div>
      </div>
      <div class="cb" style="height:220px;"><canvas id="cActive"></canvas></div>
      <div id="activeLeg" style="display:flex;gap:14px;justify-content:center;margin-top:10px;flex-wrap:wrap;"></div>
    </div>
  </div>
</div>

<!-- TAB: ADMIN INSIGHTS -->
<div id="tab-insights" class="tab-pane">
  <div id="suggBox"></div>
  <div class="card">
    <div class="card-hd">
      <div class="card-hd-l">
        <div class="cico" style="background:var(--pl);color:var(--p);"><i class="fa fa-graduation-cap"></i></div>
        <div><div class="ct">System Usage Visualisation Guide</div><div class="cs">How to interpret and act on this dashboard</div></div>
      </div>
    </div>
    <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(230px,1fr));gap:14px;">
      <div style="background:var(--bl);border-radius:var(--rads);padding:14px;">
        <div style="font-weight:700;color:var(--b);margin-bottom:6px;"><i class="fa fa-chart-line" style="margin-right:5px;"></i>Login Trend</div>
        <p style="font-size:12px;line-height:1.7;">A drop in daily logins indicates disengagement. Compare weekdays vs weekends — high weekend activity means students are self-studying, which is positive.</p>
      </div>
      <div style="background:var(--gl);border-radius:var(--rads);padding:14px;">
        <div style="font-weight:700;color:var(--gd);margin-bottom:6px;"><i class="fa fa-clock" style="margin-right:5px;"></i>Peak Hours</div>
        <p style="font-size:12px;line-height:1.7;">If peak usage is late night (10pm-2am), schedule live classes or doubt sessions then. If morning (8-10am), platform is used before classes — great for assignments.</p>
      </div>
      <div style="background:var(--wl);border-radius:var(--rads);padding:14px;">
        <div style="font-weight:700;color:var(--w);margin-bottom:6px;"><i class="fa fa-layer-group" style="margin-right:5px;"></i>Feature Adoption</div>
        <p style="font-size:12px;line-height:1.7;">Low Video Views vs high Logins = students log in but don't consume content. Push notifications about new video uploads. Low AI usage = awareness campaign needed.</p>
      </div>
      <div style="background:var(--pul);border-radius:var(--rads);padding:14px;">
        <div style="font-weight:700;color:var(--p);margin-bottom:6px;"><i class="fa fa-user-xmark" style="margin-right:5px;"></i>Inactive Users</div>
        <p style="font-size:12px;line-height:1.7;">Cross-reference inactive users with low attendance records — these students need outreach. Assign a counsellor and send personalised re-engagement messages.</p>
      </div>
      <div style="background:var(--rol);border-radius:var(--rads);padding:14px;">
        <div style="font-weight:700;color:var(--ro);margin-bottom:6px;"><i class="fa fa-users" style="margin-right:5px;"></i>Stream Comparison</div>
        <p style="font-size:12px;line-height:1.7;">Low engagement rate in a stream means either content is poor or students are disinterested. Talk to stream faculty and review video completion rates for those subjects.</p>
      </div>
      <div style="background:var(--tl);border-radius:var(--rads);padding:14px;">
        <div style="font-weight:700;color:var(--t);margin-bottom:6px;"><i class="fa fa-circle-info" style="margin-right:5px;"></i>Help Requests</div>
        <p style="font-size:12px;line-height:1.7;">Spike in help requests = something isn't intuitive. Review the most common request topics and update the LMS documentation or add tutorial videos for those features.</p>
      </div>
    </div>
  </div>
</div>

</div>

<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.4.1/chart.umd.min.js"></script>
<script>
(function(){
'use strict';

function hv(id){var e=document.getElementById(id);return e?e.value:'';}
var INST=hv('<%= hdnInst.ClientID %>');
var SESS=hv('<%= hdnSess.ClientID %>');
var SNAME=(document.getElementById('<%= lblSess.ClientID %>')||{}).innerText||'';
var DEF_FR=hv('<%= hdnDfr.ClientID %>');
var DEF_TO=hv('<%= hdnDto.ClientID %>');
document.getElementById('bSess').innerText=SNAME;

var PAL=['#4f46e5','#10b981','#f59e0b','#ef4444','#8b5cf6','#3b82f6','#0d9488','#f43f5e','#0891b2','#ea580c'];
var GRD={color:'rgba(148,163,184,.12)'};
var TICK={font:{size:11,family:"'Inter','Segoe UI',sans-serif"}};
var TT={padding:10,cornerRadius:8,bodyFont:{size:12},titleFont:{size:12,weight:'bold'}};
var ANIM={duration:950,easing:'easeInOutQuart'};
function palA(a){return PAL.map(function(c){return c+Math.round(a*255).toString(16).padStart(2,'0');});}

var charts={},debT=null,lastData=null;

/* Clone dropdowns */
var DDL={'<%= aspRole.ClientID %>':'fRole'};
Object.keys(DDL).forEach(function(aspId){
  var asp=document.getElementById(aspId),js=document.getElementById(DDL[aspId]);
  if(!asp||!js)return;
  Array.prototype.forEach.call(asp.options,function(o){
    if(js.querySelector('option[value="'+o.value+'"]'))return;
    var n=document.createElement('option');n.value=o.value;n.text=o.text;js.appendChild(n);
  });
});

document.getElementById('fDfr').value=DEF_FR;
document.getElementById('fDto').value=DEF_TO;
document.querySelectorAll('.qr[data-days="30"]').forEach(function(b){b.classList.add('on');});

function G(id){return document.getElementById(id);}

/* Wire buttons */
G('btnApply').addEventListener('click',function(e){e.preventDefault();go();});
G('btnReset').addEventListener('click',function(e){e.preventDefault();resetF();});
G('fRole').addEventListener('change',function(){go();});
G('fDfr').addEventListener('change',function(){clearPills();go();});
G('fDto').addEventListener('change',function(){clearPills();go();});

document.querySelectorAll('.qr').forEach(function(btn){
  btn.addEventListener('click',function(e){
    e.preventDefault();clearPills();this.classList.add('on');
    var days=this.dataset.days,cm=this.dataset.curmon,full=this.dataset.full;
    var to=new Date(),fr=new Date();
    if(full){G('fDfr').value='';G('fDto').value='';}
    else if(cm){G('fDfr').value=fmt(new Date(to.getFullYear(),to.getMonth(),1));G('fDto').value=fmt(to);}
    else{fr.setDate(to.getDate()-parseInt(days)+1);G('fDfr').value=fmt(fr);G('fDto').value=fmt(to);}
    go();
  });
});

G('tabBar').addEventListener('click',function(e){
  var btn=e.target.closest('.tab-btn');if(!btn)return;
  e.preventDefault();e.stopPropagation();
  var name=btn.dataset.tab;if(!name)return;
  document.querySelectorAll('.tab-btn').forEach(function(b){b.classList.remove('on');});
  document.querySelectorAll('.tab-pane').forEach(function(p){p.classList.remove('on');});
  btn.classList.add('on');
  var pane=G('tab-'+name);if(pane)pane.classList.add('on');
});

function clearPills(){document.querySelectorAll('.qr').forEach(function(b){b.classList.remove('on');});}
function fmt(d){return d.toISOString().split('T')[0];}

function getF(){return{role:G('fRole').value||'',datefrom:G('fDfr').value||'',dateto:G('fDto').value||''};}

function buildURL(){
  var f=getF();
  return location.pathname+'?ajax=1&inst='+encodeURIComponent(INST)+'&sess='+encodeURIComponent(SESS)
    +'&role='+encodeURIComponent(f.role)+'&datefrom='+f.datefrom+'&dateto='+f.dateto;
}

function resetF(){
  G('fRole').value='';G('fDfr').value=DEF_FR;G('fDto').value=DEF_TO;
  G('afcWrap').innerHTML='';clearPills();
  document.querySelectorAll('.qr[data-days="30"]').forEach(function(b){b.classList.add('on');});
  go();
}

function updateChips(){
  var f=getF(),wrap=G('afcWrap');wrap.innerHTML='';
  if(f.role){var c=document.createElement('span');c.className='afc-chip';c.innerText='Role: '+f.role;
    c.addEventListener('click',function(){G('fRole').value='';go();});wrap.appendChild(c);}
  if(f.datefrom||f.dateto){var c2=document.createElement('span');c2.className='afc-chip';
    c2.innerText=(f.datefrom||'Start')+' → '+(f.dateto||'Now');wrap.appendChild(c2);}
}

/* MAIN FETCH */
function go(){clearTimeout(debT);debT=setTimeout(fetchData,280);}
window.go=go;

function fetchData(){
  setLoad(true);updateChips();
  fetch(buildURL())
    .then(function(r){if(!r.ok)throw new Error('HTTP '+r.status);return r.json();})
    .then(function(d){
      lastData=d;
      renderKPIs(d.kpi);
      renderAllCharts(d);
      renderTopUsers(d.topUsers);
      renderActivity(d.recentActivity);
      renderInactive(d.inactiveUsers,d.kpi);
      renderFeatureTable(d.featureUsage);
      renderFeatureBars(d.featureUsage);
      renderStreamBars(d.streamWise);
      renderSuggestions(d.adminStats,d.kpi);
      setLoad(false);
    })
    .catch(function(err){setLoad(false);console.error('[SysUsage]',err);});
}

function setLoad(on){
  var bar=G('lbar'),sp=G('gSpin');
  bar.style.width=on?'82%':'100%';sp.style.display=on?'inline-block':'none';
  if(!on)setTimeout(function(){bar.style.width='0%';},600);
}

/* KPIs */
function renderKPIs(k){
  if(!k)return;
  cu('kLogins',k.totalLogins);cu('kUsers',k.activeUsers);cu('kToday',k.todayLogins);
  cu('kVideos',k.totalVideoViews);cu('kQuizzes',k.quizAttempts);
  cu('kSubmit',k.assignSubmissions);cu('kAI',k.aiUses);
  cu('kHelp',k.helpRequests);cu('kStu',k.totalStudents);cu('kTeach',k.totalTeachers);
  G('bLogins').innerText=k.totalLogins||0;G('bUsers').innerText=k.activeUsers||0;
  G('bToday').innerText=k.todayLogins||0;G('bVideos').innerText=k.totalVideoViews||0;
  G('bAI').innerText=k.aiUses||0;
}

function cu(id,n){
  var el=G(id);if(!el)return;
  var t=parseInt(n)||0,s=parseInt(el.innerText)||0,diff=t-s,steps=28,i=0;
  var iv=setInterval(function(){i++;el.innerText=Math.round(s+diff*(i/steps));
    if(i>=steps){el.innerText=t;clearInterval(iv);}},16);
}

/* Chart helpers */
function dc(k){if(charts[k]){charts[k].destroy();charts[k]=null;}}
function gV(ctx,h,c1,c2){var g=ctx.createLinearGradient(0,0,0,h);g.addColorStop(0,c1);g.addColorStop(1,c2);return g;}
function noData(id,msg){var el=G(id);if(!el)return;var box=el.closest('.cb');if(box)box.innerHTML='<div class="empty"><i class="fa fa-chart-simple"></i><p>'+(msg||'No data')+'</p></div>';}

function renderAllCharts(d){
  renderTrend(d.dailyTrend);
  renderRole(d.roleWise);
  renderHourly(d.hourly);
  renderDow(d.dayOfWeek);
  renderWeekly(d.weeklyTrend);
  renderStream(d.streamWise);
  renderFeatureChart(d.featureUsage);
  renderFeatureDonut(d.featureUsage);
  renderActiveDonut(d.kpi,d.inactiveUsers);
}

/* 1. Daily login trend */
function renderTrend(data){
  dc('trend');
  if(!data||!data.length){noData('cTrend','No login data');return;}
  var ctx=G('cTrend');if(!ctx)return;
  var c=ctx.getContext('2d');
  var grad=gV(c,230,'rgba(59,130,246,.26)','rgba(59,130,246,.01)');
  var total=data.reduce(function(a,r){return a+(parseInt(r.Logins)||0);},0);
  G('trendTotal').innerText=total+' total logins';
  charts.trend=new Chart(ctx,{type:'line',data:{
    labels:data.map(function(r){return r.DateStr;}),
    datasets:[
      {label:'Total',data:data.map(function(r){return r.Logins||0;}),
       borderColor:'#3b82f6',backgroundColor:grad,borderWidth:2.5,tension:.42,fill:true,pointRadius:0,pointHoverRadius:7},
      {label:'Students',data:data.map(function(r){return r.StudentLogins||0;}),
       borderColor:'#10b981',borderWidth:2,borderDash:[4,4],tension:.4,fill:false,pointRadius:0,pointHoverRadius:6},
      {label:'Teachers',data:data.map(function(r){return r.TeacherLogins||0;}),
       borderColor:'#f59e0b',borderWidth:2,borderDash:[4,4],tension:.4,fill:false,pointRadius:0,pointHoverRadius:6}
    ]
  },options:{responsive:true,maintainAspectRatio:false,
    interaction:{mode:'index',intersect:false},
    plugins:{legend:{position:'top',labels:{boxWidth:10,font:{size:11}}},tooltip:TT},
    scales:{x:{grid:{display:false},ticks:{font:{size:10},maxTicksLimit:12}},y:{beginAtZero:true,grid:GRD,ticks:TICK}},
    animation:ANIM}});
}

/* 2. Role donut */
function renderRole(data){
  dc('role');
  var leg=G('roleLeg');if(leg)leg.innerHTML='';
  if(!data||!data.length){noData('cRole','No role data');return;}
  var el=G('cRole');if(!el)return;
  var RCOL=['#4f46e5','#10b981','#f59e0b','#ef4444','#8b5cf6'];
  charts.role=new Chart(el,{type:'doughnut',data:{
    labels:data.map(function(r){return r.RoleName;}),
    datasets:[{data:data.map(function(r){return r.TotalActions||0;}),backgroundColor:RCOL,borderWidth:2,borderColor:'#fff',hoverOffset:10}]
  },options:{cutout:'60%',responsive:true,maintainAspectRatio:false,
    plugins:{legend:{display:false},tooltip:TT},animation:{animateRotate:true,duration:1100}}});
  if(leg){var tot=data.reduce(function(a,r){return a+(r.TotalActions||0);},0)||1;
    data.forEach(function(r,i){leg.innerHTML+='<div style="display:flex;align-items:center;gap:5px;font-size:11px;">'
      +'<span style="width:10px;height:10px;border-radius:2px;background:'+RCOL[i]+';display:inline-block;flex-shrink:0;"></span>'
      +esc(r.RoleName)+' <strong style="color:'+RCOL[i]+';">'+Math.round((r.TotalActions||0)/tot*100)+'%</strong></div>';});}
}

/* 3. Hourly bar */
function renderHourly(data){
  dc('hourly');
  if(!data||!data.length){noData('cHourly','No hourly data');return;}
  var el=G('cHourly');if(!el)return;
  var hrs=[],vals=[];
  for(var h=0;h<24;h++){hrs.push(h+':00');vals.push(0);}
  data.forEach(function(r){var hr=parseInt(r.Hr)||0;if(hr>=0&&hr<24)vals[hr]=parseInt(r.Total)||0;});
  var maxV=Math.max.apply(null,vals)||1;
  charts.hourly=new Chart(el,{type:'bar',data:{labels:hrs,datasets:[{label:'Actions',data:vals,
    backgroundColor:vals.map(function(v){return 'rgba(79,70,229,'+Math.max(.18,v/maxV).toFixed(2)+')';}),borderRadius:3}]
  },options:{responsive:true,maintainAspectRatio:false,
    plugins:{legend:{display:false},tooltip:TT},
    scales:{x:{grid:{display:false},ticks:{font:{size:9},maxTicksLimit:12}},y:{beginAtZero:true,grid:GRD,ticks:TICK}},
    animation:ANIM}});
}

/* 4. Day-of-week radar */
function renderDow(data){
  dc('dow');
  if(!data||!data.length){noData('cDow','No data');return;}
  var el=G('cDow');if(!el)return;
  charts.dow=new Chart(el,{type:'radar',data:{
    labels:data.map(function(r){return r.DayName;}),
    datasets:[{label:'Actions',data:data.map(function(r){return r.Total||0;}),
      backgroundColor:'rgba(79,70,229,.18)',borderColor:'#4f46e5',borderWidth:2.5,
      pointBackgroundColor:'#4f46e5',pointRadius:4,pointHoverRadius:7}]
  },options:{responsive:true,maintainAspectRatio:false,
    plugins:{legend:{display:false},tooltip:TT},
    scales:{r:{beginAtZero:true,ticks:{font:{size:9}},grid:{color:'rgba(148,163,184,.2)'},pointLabels:{font:{size:11}}}},
    animation:{duration:1100,easing:'easeInOutBack'}}});
}

/* 5. Weekly bar */
function renderWeekly(data){
  dc('weekly');
  if(!data||!data.length){noData('cWeekly','No weekly data');return;}
  var el=G('cWeekly');if(!el)return;
  charts.weekly=new Chart(el,{type:'bar',data:{
    labels:data.map(function(r){return r.WLabel;}),
    datasets:[
      {label:'Actions',data:data.map(function(r){return r.TotalActions||0;}),backgroundColor:'rgba(59,130,246,.82)',borderRadius:5},
      {label:'Users',  data:data.map(function(r){return r.UniqueUsers||0;}),  backgroundColor:'rgba(16,185,129,.72)',borderRadius:5}
    ]
  },options:{responsive:true,maintainAspectRatio:false,
    plugins:{legend:{position:'top',labels:{boxWidth:10,font:{size:11}}},tooltip:TT},
    scales:{x:{grid:{display:false},ticks:TICK},y:{beginAtZero:true,grid:GRD,ticks:TICK}},animation:ANIM}});
}

/* 6. Stream bar */
function renderStream(data){
  dc('stream');
  if(!data||!data.length){noData('cStream','No stream data');return;}
  var el=G('cStream');if(!el)return;
  charts.stream=new Chart(el,{type:'bar',data:{
    labels:data.map(function(r){return r.StreamName;}),
    datasets:[
      {label:'Total Actions',data:data.map(function(r){return r.TotalActions||0;}),backgroundColor:palA(.82),borderRadius:5},
      {label:'Engagement %',data:data.map(function(r){return r.EngagementRate||0;}),backgroundColor:palA(.42),borderRadius:5,yAxisID:'y1'}
    ]
  },options:{responsive:true,maintainAspectRatio:false,
    plugins:{legend:{position:'top',labels:{boxWidth:10,font:{size:11}}},tooltip:TT},
    scales:{x:{grid:{display:false},ticks:TICK},
      y:{beginAtZero:true,grid:GRD,ticks:TICK},
      y1:{position:'right',beginAtZero:true,max:100,grid:{display:false},ticks:{font:{size:11},callback:function(v){return v+'%';}}}},
    animation:ANIM}});
}

/* 7. Feature bar */
function renderFeatureChart(data){
  dc('feat');
  if(!data||!data.length){noData('cFeature','No feature data');return;}
  var el=G('cFeature');if(!el)return;
  charts.feat=new Chart(el,{type:'bar',data:{
    labels:data.map(function(r){return r.Feature;}),
    datasets:[{label:'Uses',data:data.map(function(r){return r.Total||0;}),backgroundColor:palA(.82),borderRadius:5,borderSkipped:false}]
  },options:{indexAxis:'y',responsive:true,maintainAspectRatio:false,
    plugins:{legend:{display:false},tooltip:TT},
    scales:{x:{beginAtZero:true,grid:GRD,ticks:TICK},y:{grid:{display:false},ticks:{font:{size:11}}}},animation:ANIM}});
}

/* 8. Feature donut */
function renderFeatureDonut(data){
  dc('featd');
  var leg=G('featureDonutLeg');if(leg)leg.innerHTML='';
  if(!data||!data.length){noData('cFeatureDonut','No data');return;}
  var el=G('cFeatureDonut');if(!el)return;
  charts.featd=new Chart(el,{type:'doughnut',data:{
    labels:data.map(function(r){return r.Feature;}),
    datasets:[{data:data.map(function(r){return r.Total||0;}),backgroundColor:palA(.85),borderWidth:2,borderColor:'#fff',hoverOffset:8}]
  },options:{cutout:'55%',responsive:true,maintainAspectRatio:false,
    plugins:{legend:{display:false},tooltip:TT},animation:{animateRotate:true,duration:1100}}});
  if(leg){
    var tot=data.reduce(function(a,r){return a+(r.Total||0);},0)||1;
    data.forEach(function(r,i){leg.innerHTML+='<div style="display:flex;align-items:center;gap:5px;font-size:11px;">'
      +'<span style="width:10px;height:10px;border-radius:2px;background:'+PAL[i%PAL.length]+';display:inline-block;flex-shrink:0;"></span>'
      +esc(r.Feature)+' <strong style="color:'+PAL[i%PAL.length]+';">'+Math.round((r.Total||0)/tot*100)+'%</strong></div>';});
  }
}

/* 9. Active vs Inactive donut */
function renderActiveDonut(kpi,inactive){
  dc('active');
  var leg=G('activeLeg');if(leg)leg.innerHTML='';
  if(!kpi)return;
  var el=G('cActive');if(!el)return;
  var active=parseInt(kpi.activeUsers)||0;
  var total=parseInt(kpi.totalStudents)||0;
  var inact=Math.max(0,total-active);
  charts.active=new Chart(el,{type:'doughnut',data:{
    labels:['Active','Inactive'],
    datasets:[{data:[active,inact],backgroundColor:['#10b981','#e2e8f0'],borderWidth:3,borderColor:'#fff',hoverOffset:8}]
  },options:{cutout:'65%',responsive:true,maintainAspectRatio:false,
    plugins:{legend:{display:false},tooltip:TT},animation:{animateRotate:true,duration:1100}}});
  if(leg){var tot=total||1;
    leg.innerHTML='<div style="display:flex;align-items:center;gap:6px;font-size:12px;">'
      +'<span style="width:12px;height:12px;border-radius:2px;background:#10b981;display:inline-block;"></span>'
      +'Active <strong style="color:#10b981;">'+active+' ('+Math.round(active/tot*100)+'%)</strong></div>'
      +'<div style="display:flex;align-items:center;gap:6px;font-size:12px;">'
      +'<span style="width:12px;height:12px;border-radius:2px;background:#e2e8f0;display:inline-block;"></span>'
      +'Inactive <strong style="color:var(--ts);">'+inact+' ('+Math.round(inact/tot*100)+'%)</strong></div>';}
}

/* TOP USERS TABLE */
function renderTopUsers(data){
  var tbody=G('topTbody'),cnt=G('topCount');
  if(cnt)cnt.innerText=(data?data.length:0)+' users';
  if(!data||!data.length){tbody.innerHTML='<tr><td colspan="9"><div class="empty"><i class="fa fa-users"></i><p>No activity data</p></div></td></tr>';return;}
  var maxA=Math.max.apply(null,data.map(function(r){return parseInt(r.TotalActions)||0;}))||1;
  var html='';
  data.forEach(function(r,i){
    var acts=parseInt(r.TotalActions)||0;
    var pct=Math.round(acts/maxA*100);
    var init=(r.FullName||'?').substring(0,1).toUpperCase();
    var img=r.ProfileImage?'<img src="'+esc(r.ProfileImage)+'" alt=""/>':init;
    var rank=i<3?'r'+(i+1):'rn';
    var roleCls=r.RoleName==='Student'?'rp-stu':r.RoleName==='Teacher'?'rp-tch':r.RoleName==='Admin'?'rp-adm':'rp-def';
    var ls=r.LastSeen?new Date(r.LastSeen).toLocaleDateString('en-IN',{day:'2-digit',month:'short'}):'—';
    html+='<tr>'
      +'<td><div class="rk '+rank+'">'+(i+1)+'</div></td>'
      +'<td><div style="display:flex;align-items:center;gap:8px;">'
        +'<div class="uav">'+img+'</div>'
        +'<div><div class="uname">'+esc(r.FullName||'')+'</div></div>'
      +'</div></td>'
      +'<td><span class="role-pill '+roleCls+'">'+esc(r.RoleName||'User')+'</span></td>'
      +'<td style="font-weight:700;color:var(--p);">'+acts+'</td>'
      +'<td style="font-weight:600;">'+esc(r.ActiveDays||0)+' days</td>'
      +'<td style="color:var(--b);font-weight:600;">'+esc(r.VideoViews||0)+'</td>'
      +'<td style="color:var(--g);font-weight:600;">'+esc(r.QuizAttempts||0)+'</td>'
      +'<td style="font-size:11px;color:var(--ts);">'+ls+'</td>'
      +'<td><div class="eng-wrap"><div class="eng-bg"><div class="eng-fg" style="width:'+pct+'%;"></div></div>'
        +'<span style="font-size:11px;font-weight:700;min-width:28px;">'+pct+'%</span></div></td>'
    +'</tr>';
  });
  tbody.innerHTML=html;
}

/* ACTIVITY FEED */
function renderActivity(data){
  var wrap=G('actFeed');if(!wrap)return;
  if(!data||!data.length){wrap.innerHTML='<div class="empty"><i class="fa fa-bolt"></i><p>No recent activity</p></div>';return;}
  var typeCol={'Login':'var(--g)','Logout':'var(--ts)','View':'var(--b)','Submit':'var(--w)','Quiz':'var(--pu)','Upload':'var(--or)'};
  var typeIco={'Login':'fa-right-to-bracket','Logout':'fa-right-from-bracket','View':'fa-eye','Submit':'fa-clipboard-check','Quiz':'fa-circle-question','Upload':'fa-upload'};
  var html='';
  data.forEach(function(r){
    var col=typeCol[r.ActivityType]||'var(--ts)';
    var ico=typeIco[r.ActivityType]||'fa-circle-dot';
    var init=(r.FullName||'?').substring(0,1).toUpperCase();
    var img=r.ProfileImage?'<img src="'+esc(r.ProfileImage)+'" alt=""/>':init;
    var t=r.ActionTime?new Date(r.ActionTime).toLocaleString('en-IN',{day:'2-digit',month:'short',hour:'2-digit',minute:'2-digit'}):'-';
    html+='<div class="act-item">'
      +'<div class="act-ico" style="background:'+col+'22;color:'+col+';"><i class="fa '+ico+'"></i></div>'
      +'<div style="flex:1;min-width:0;">'
        +'<div class="act-name">'+esc(r.FullName||'')+'</div>'
        +'<div class="act-type">'+esc(r.ActivityType||'—')+(r.Description?' — '+esc(r.Description.substring(0,60)):'')+'</div>'
      +'</div>'
      +'<div class="act-time">'+t+'</div>'
    +'</div>';
  });
  wrap.innerHTML=html;
}

/* INACTIVE USERS */
function renderInactive(data,kpi){
  var wrap=G('inactiveList'),cnt=G('inactiveCount');
  if(cnt)cnt.innerText=(data?data.length:0)+' users';
  if(!data||!data.length){
    wrap.innerHTML='<div class="empty" style="padding:50px;"><i class="fa fa-circle-check" style="color:var(--g);opacity:1;font-size:36px;"></i><p style="color:var(--g);font-weight:700;margin-top:8px;">All users recently active!</p></div>';
    return;
  }
  var html='';
  data.forEach(function(r,i){
    var days=parseInt(r.DaysSinceLogin)||0;
    var col=days>30?'var(--r)':days>14?'var(--w)':'var(--ts)';
    var init=(r.FullName||'?').substring(0,1).toUpperCase();
    var img=r.ProfileImage?'<img src="'+esc(r.ProfileImage)+'" alt=""/>':init;
    var roleCls=r.RoleName==='Student'?'rp-stu':r.RoleName==='Teacher'?'rp-tch':'rp-adm';
    html+='<div style="display:flex;align-items:center;gap:10px;padding:9px 0;border-bottom:1px solid var(--bd);">'
      +'<div class="rk '+(i<3?'r'+(i+1):'rn')+'">'+(i+1)+'</div>'
      +'<div class="uav" style="background:var(--rl);color:var(--r);">'+img+'</div>'
      +'<div style="flex:1;min-width:0;">'
        +'<div class="uname">'+esc(r.FullName||'')+'</div>'
        +'<div style="font-size:11px;color:var(--ts);">Last seen: '+esc(r.LastSeen||'Never')+'</div>'
      +'</div>'
      +'<span class="role-pill '+roleCls+'">'+esc(r.RoleName||'User')+'</span>'
      +'<div style="font-size:12px;font-weight:800;color:'+col+';min-width:50px;text-align:right;">'
        +(days>=999?'Never':days+'d ago')
      +'</div>'
    +'</div>';
  });
  wrap.innerHTML=html;
}

/* FEATURE TABLE */
function renderFeatureTable(data){
  var tbody=G('featureTbody');if(!tbody)return;
  if(!data||!data.length){tbody.innerHTML='<tr><td colspan="5"><div class="empty"><i class="fa fa-layer-group"></i><p>No data</p></div></td></tr>';return;}
  var tot=data.reduce(function(a,r){return a+(parseInt(r.Total)||0);},0)||1;
  tbody.innerHTML=data.map(function(r,i){
    var pct=Math.round((r.Total||0)/tot*100);
    return'<tr>'
      +'<td style="color:var(--tm);font-size:11px;">'+(i+1)+'</td>'
      +'<td style="font-weight:700;">'+esc(r.Feature||'')+'</td>'
      +'<td style="font-weight:700;color:var(--p);">'+esc(r.Total||0)+'</td>'
      +'<td style="color:var(--ts);">'+esc(r.UniqueUsers||0)+'</td>'
      +'<td><div class="eng-wrap"><div class="eng-bg"><div class="eng-fg" style="width:'+pct+'%;background:'+PAL[i%PAL.length]+';"></div></div>'
        +'<span style="font-size:11px;font-weight:700;min-width:30px;">'+pct+'%</span></div></td>'
    +'</tr>';
  }).join('');
}

/* FEATURE BARS */
function renderFeatureBars(data){
  var wrap=G('featureBars');if(!wrap)return;
  wrap.innerHTML='';
  if(!data||!data.length){wrap.innerHTML='<div class="empty"><i class="fa fa-layer-group"></i><p>No data</p></div>';return;}
  var max=Math.max.apply(null,data.map(function(r){return r.Total||0;}))||1;
  data.forEach(function(r,i){
    var pct=Math.round((r.Total||0)/max*100);
    wrap.innerHTML+='<div class="pi">'
      +'<div class="pi-lbl"><span style="font-weight:700;">'+esc(r.Feature)+'</span>'
        +'<span>'+esc(r.Total||0)+' uses ('+esc(r.UniqueUsers||0)+' users)</span></div>'
      +'<div class="pi-track"><div class="pi-fill" data-w="'+pct+'%" style="background:'+PAL[i%PAL.length]+';"></div></div>'
    +'</div>';
  });
  setTimeout(function(){wrap.querySelectorAll('.pi-fill[data-w]').forEach(function(el){el.style.width=el.dataset.w;});},300);
}

/* STREAM BARS */
function renderStreamBars(data){
  var wrap=G('streamBars');if(!wrap)return;
  wrap.innerHTML='';
  if(!data||!data.length){wrap.innerHTML='<div class="empty"><i class="fa fa-layer-group"></i><p>No data</p></div>';return;}
  data.forEach(function(r,i){
    var pct=parseFloat(r.EngagementRate)||0;
    var col=pct>=70?'var(--g)':pct>=40?'var(--p)':'var(--r)';
    wrap.innerHTML+='<div class="pi">'
      +'<div class="pi-lbl"><span>'+esc(r.StreamName)+'</span>'
        +'<span>'+esc(r.ActiveStudents)+'/'+esc(r.TotalStudents)+' ('+pct+'%)</span></div>'
      +'<div class="pi-track"><div class="pi-fill" data-w="'+pct+'%" style="background:'+col+';"></div></div>'
    +'</div>';
  });
  setTimeout(function(){wrap.querySelectorAll('.pi-fill[data-w]').forEach(function(el){el.style.width=el.dataset.w;});},300);
}

/* SUGGESTIONS */
function renderSuggestions(stats,kpi){
  var wrap=G('suggBox');if(!wrap)return;
  var s=(stats&&stats.length)?stats[0]:{};
  var k=kpi||{};
  var nli=parseInt(s.NeverLoggedIn)||0;
  var avg=parseFloat(s.AvgLoginsPerDay)||0;
  var ph=parseInt(s.PeakHour)||0;
  var a7=parseInt(s.ActiveLast7)||0;
  var ohr=parseInt(s.OpenHelpRequests)||0;
  var nm=parseInt(s.NotifThisMonth)||0;
  function si(warn,ico,n,hd,txt){return'<div class="si '+(warn?'warn':'ok')+'">'
    +'<span class="si-ico">'+ico+'</span><div class="si-n">'+n+'</div>'
    +'<div class="si-hd">'+hd+'</div><div class="si-tx">'+txt+'</div></div>';}
  wrap.innerHTML='<div class="sugg-card"><div class="sugg-title"><i class="fa fa-gauge-high"></i>System Health Panel</div>'
    +'<div class="sugg-grid">'
    +si(nli>0,'👤',nli,'Never Logged In',nli>0?nli+' enrolled students have never logged in. Verify accounts are activated and credentials delivered.':'All students have logged in at least once.')
    +si(avg<10,'📊',avg.toFixed(1),'Avg Logins/Day',avg<10?'Low daily logins. Check if notifications are being sent and if students know the login URL.':'Platform shows healthy daily activity.')
    +si(false,'⏰',ph+':00','Peak Usage Hour','Students are most active at '+ph+':00. Schedule announcements, live classes, or assignment deadlines around this time.')
    +si(a7<parseInt(k.totalStudents)*0.3,'🔥',a7,'Active Last 7 Days',a7<(parseInt(k.totalStudents)||1)*0.3?'Less than 30% of students were active last week. Re-engagement campaign needed.':'Good weekly engagement. Keep content fresh.')
    +si(ohr>5,'🆘',ohr,'Open Help Requests',ohr>5?ohr+' unresolved help requests. Assign support staff to clear the backlog — unresolved issues hurt retention.':'All help requests resolved. Support is up to date!')
    +si(nm<10,'🔔',nm,'Notifications This Month',nm<10?'Only '+nm+' notifications sent. Students who don\'t receive reminders disengage faster. Set up automated alerts.':'Good notification activity this month.')
    +'</div></div>';
}

/* CSV */
function doExport(){
  if(!lastData||!lastData.topUsers||!lastData.topUsers.length){alert('No data to export');return;}
  var H=['Name','Role','Total Actions','Active Days','Video Views','Quizzes','Last Seen'];
  var R=lastData.topUsers.map(function(r){
    return[r.FullName,r.RoleName,r.TotalActions,r.ActiveDays,r.VideoViews,r.QuizAttempts,r.LastSeen]
      .map(function(v){return'"'+String(v||'').replace(/"/g,'""')+'"';});
  });
  var csv=[H].concat(R).map(function(r){return r.join(',');}).join('\n');
  var a=document.createElement('a');
  a.href='data:text/csv;charset=utf-8,'+encodeURIComponent(csv);
  a.download='system_usage_'+new Date().toISOString().slice(0,10)+'.csv';
  a.click();
}
window.doExport=doExport;

function esc(s){return String(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');}

setTimeout(function(){go();},120);
})();
</script>
</asp:Content>
