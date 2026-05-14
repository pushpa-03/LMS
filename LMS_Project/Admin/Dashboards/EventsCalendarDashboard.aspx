<%@ Page Title="Events & Calendar Dashboard" Language="C#"
    MasterPageFile="~/Admin/AdminMaster.Master"
    AutoEventWireup="true"
    CodeBehind="EventsCalendarDashboard.aspx.cs"
    Inherits="LearningManagementSystem.Admin.Dashboards.EventsCalendarDashboard" %>

<asp:Content ID="cHead" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet"/>
<style>
/* ═══ TOKENS ═══ */
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
  --pk:#ec4899;--pkl:#fce7f3;
  --tx:#1e293b;--ts:#64748b;--tm:#94a3b8;
  --bd:#e2e8f0;--bg:#fff;--pg:#f1f5f9;
  --rad:14px;--rads:8px;
  --sh:0 1px 3px rgba(0,0,0,.06);
  --shm:0 4px 16px rgba(0,0,0,.09);
}
*{box-sizing:border-box;margin:0;padding:0;}
body{background:var(--pg);font-family:'Inter','Segoe UI',system-ui,sans-serif;color:var(--tx);}
.wrap{padding:22px;}

/* Event type colors */
.et-exam      {background:#fee2e2;color:#991b1b;}
.et-holiday   {background:#d1fae5;color:#065f46;}
.et-seminar   {background:#dbeafe;color:#1e40af;}
.et-workshop  {background:#fef3c7;color:#92400e;}
.et-cultural  {background:#fce7f3;color:#9d174d;}
.et-sports    {background:#ccfbf1;color:#0f766e;}
.et-meeting   {background:#ede9fe;color:#4c1d95;}
.et-general   {background:#f1f5f9;color:#475569;}
.et-other     {background:#f3f4f6;color:#374151;}

/* ── BANNER ── */
.banner{
  position:relative;border-radius:var(--rad);overflow:hidden;
  margin-bottom:20px;min-height:160px;box-shadow:var(--shm);
  background:linear-gradient(135deg,#0c1445 0%,#1a2980 40%,#26d0ce 100%);
}
.b-ov{position:absolute;inset:0;
  background:linear-gradient(105deg,rgba(5,8,40,.75),rgba(5,8,40,.2));z-index:1;}
.b-wave{position:absolute;bottom:0;left:0;right:0;z-index:0;}
.b-wave svg{display:block;width:100%;height:55px;}
.b-body{position:relative;z-index:2;display:flex;align-items:center;
  justify-content:space-between;padding:24px 36px;gap:20px;flex-wrap:wrap;}
.b-eyebrow{font-size:11px;font-weight:700;color:rgba(255,255,255,.55);
  text-transform:uppercase;letter-spacing:.1em;margin-bottom:5px;
  display:flex;align-items:center;gap:6px;}
.b-title{font-size:24px;font-weight:800;color:#fff;}
.b-sub{font-size:13px;color:rgba(255,255,255,.65);margin-top:4px;}
.b-kpis{display:flex;gap:18px;margin-top:14px;flex-wrap:wrap;}
.bk{text-align:center;}
.bk-v{font-size:20px;font-weight:900;color:#fff;line-height:1;transition:all .5s;}
.bk-l{font-size:9px;color:rgba(255,255,255,.55);text-transform:uppercase;letter-spacing:.05em;margin-top:2px;}
.bdiv{width:1px;background:rgba(255,255,255,.2);align-self:stretch;}
.live-pill{background:rgba(16,185,129,.25);border:1px solid rgba(16,185,129,.45);
  color:#a7f3d0;padding:5px 14px;border-radius:20px;font-size:11px;font-weight:700;
  display:inline-flex;align-items:center;gap:6px;}
.ldot{width:7px;height:7px;border-radius:50%;background:#10b981;animation:pulse 1.4s infinite;}
@keyframes pulse{0%,100%{opacity:1;transform:scale(1)}50%{opacity:.4;transform:scale(.7)}}
.btn-exp{padding:9px 18px;background:rgba(255,255,255,.14);color:#fff;
  border:1px solid rgba(255,255,255,.28);border-radius:var(--rads);
  font-size:12px;font-weight:700;cursor:pointer;transition:.2s;
  display:inline-flex;align-items:center;gap:7px;}
.btn-exp:hover{background:rgba(255,255,255,.26);}
.gspin{display:inline-block;width:18px;height:18px;border:2px solid rgba(255,255,255,.25);
  border-top-color:#10b981;border-radius:50%;animation:spin .7s linear infinite;}
@keyframes spin{to{transform:rotate(360deg)}}

/* ── FILTER BAR ── */
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
.btn-rs{padding:7px 14px;background:var(--pg);color:var(--ts);
  border:1px solid var(--bd);border-radius:var(--rads);font-size:12px;font-weight:600;cursor:pointer;}
.btn-rs:hover{background:var(--bd);}
.f-row{display:flex;flex-wrap:wrap;gap:10px;align-items:flex-end;}
.fg{display:flex;flex-direction:column;gap:4px;min-width:120px;flex:1;}
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

/* ── KPI GRID ── */
.kpi-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(148px,1fr));
  gap:12px;margin-bottom:20px;}
.kpi{background:var(--bg);border:1px solid var(--bd);border-radius:var(--rad);
  padding:16px 15px;box-shadow:var(--sh);position:relative;overflow:hidden;transition:.18s;}
.kpi:hover{transform:translateY(-3px);box-shadow:var(--shm);}
.kpi::before{content:'';position:absolute;top:0;left:0;right:0;height:3px;
  border-radius:var(--rad) var(--rad) 0 0;}
.kb::before{background:var(--b);} .kg::before{background:var(--g);}
.kp::before{background:var(--p);} .kw::before{background:var(--w);}
.kt::before{background:var(--t);} .kr::before{background:var(--r);}
.kor::before{background:var(--or);} .kpk::before{background:var(--pk);}
.kpi-top{display:flex;align-items:center;justify-content:space-between;margin-bottom:10px;}
.klbl{font-size:10px;font-weight:700;color:var(--ts);text-transform:uppercase;letter-spacing:.06em;}
.kico{width:38px;height:38px;border-radius:10px;display:flex;align-items:center;
  justify-content:center;font-size:16px;}
.ib{background:var(--bl);color:var(--b);} .ig{background:var(--gl);color:var(--g);}
.ip{background:var(--pl);color:var(--p);} .iw{background:var(--wl);color:var(--w);}
.it{background:var(--tl);color:var(--t);} .ir{background:var(--rl);color:var(--r);}
.ior{background:var(--orl);color:var(--or);} .ipk{background:var(--pkl);color:var(--pk);}
.kval{font-size:26px;font-weight:900;color:var(--tx);line-height:1;
  letter-spacing:-.5px;transition:all .4s;}
.ksub{font-size:11px;color:var(--tm);margin-top:4px;}

/* ── TABS ── */
.tab-bar{display:flex;gap:2px;background:var(--pg);border-radius:10px;
  padding:4px;margin-bottom:18px;flex-wrap:wrap;}
.tab-btn{padding:9px 16px;border:none;background:transparent;border-radius:8px;
  font-size:13px;font-weight:600;color:var(--ts);cursor:pointer;transition:.18s;
  display:flex;align-items:center;gap:6px;white-space:nowrap;outline:none;}
.tab-btn.on{background:var(--bg);color:var(--p);box-shadow:var(--sh);}
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
.cico{width:32px;height:32px;border-radius:9px;display:flex;align-items:center;
  justify-content:center;font-size:14px;flex-shrink:0;}
.ct{font-size:14px;font-weight:700;color:var(--tx);}
.cs{font-size:12px;color:var(--ts);margin-top:1px;}
.cb{position:relative;width:100%;}

/* Grids */
.g2{display:grid;grid-template-columns:1fr 1fr;gap:16px;margin-bottom:18px;}
.g3{display:grid;grid-template-columns:1fr 1fr 1fr;gap:16px;margin-bottom:18px;}
.g21{display:grid;grid-template-columns:2fr 1fr;gap:16px;margin-bottom:18px;}
.g12{display:grid;grid-template-columns:1fr 2fr;gap:16px;margin-bottom:18px;}

/* ── INTERACTIVE CALENDAR ── */
.cal-wrap{background:var(--bg);border:1px solid var(--bd);border-radius:var(--rad);overflow:hidden;}
.cal-header{display:flex;align-items:center;justify-content:space-between;
  padding:14px 20px;background:linear-gradient(90deg,var(--p),var(--pu));color:#fff;}
.cal-nav{display:flex;align-items:center;gap:8px;}
.cal-nav button{background:rgba(255,255,255,.2);border:none;color:#fff;width:32px;
  height:32px;border-radius:var(--rads);cursor:pointer;font-size:14px;
  display:flex;align-items:center;justify-content:center;transition:.15s;}
.cal-nav button:hover{background:rgba(255,255,255,.35);}
.cal-month-lbl{font-size:16px;font-weight:800;min-width:140px;text-align:center;}
.cal-grid{display:grid;grid-template-columns:repeat(7,1fr);}
.cal-day-hdr{text-align:center;font-size:10px;font-weight:700;color:var(--ts);
  text-transform:uppercase;padding:8px 4px;background:var(--pg);border-bottom:1px solid var(--bd);}
.cal-day{min-height:78px;border-right:1px solid var(--bd);border-bottom:1px solid var(--bd);
  padding:6px;position:relative;cursor:pointer;transition:.15s;}
.cal-day:nth-child(7n){border-right:none;}
.cal-day:hover{background:#f7f8ff;}
.cal-day.today{background:linear-gradient(135deg,#ede9fe,#dbeafe);}
.cal-day.today .cal-dn{color:var(--p);font-weight:900;}
.cal-day.other-month{background:var(--pg);opacity:.5;}
.cal-day.has-events{cursor:pointer;}
.cal-dn{font-size:13px;font-weight:600;color:var(--tx);margin-bottom:3px;display:block;}
.cal-events-list{display:flex;flex-direction:column;gap:2px;}
.cal-ev-dot{font-size:10px;font-weight:600;border-radius:4px;padding:1px 5px;
  white-space:nowrap;overflow:hidden;text-overflow:ellipsis;max-width:100%;}
.cal-more{font-size:10px;color:var(--ts);font-weight:600;margin-top:2px;}

/* ── EVENT CARDS ── */
.ev-card{background:var(--bg);border:1px solid var(--bd);border-radius:10px;
  padding:14px 16px;margin-bottom:12px;transition:.18s;position:relative;
  border-left:4px solid var(--p);}
.ev-card:hover{box-shadow:var(--shm);transform:translateX(3px);}
.ev-card.today-ev{border-left-color:var(--g);background:linear-gradient(90deg,#f0fdf4,#fff);}
.ev-card.past-ev{border-left-color:var(--tm);opacity:.75;}
.ev-card.upcoming-ev{border-left-color:var(--b);}
.ev-title{font-size:14px;font-weight:700;color:var(--tx);margin-bottom:4px;}
.ev-meta{display:flex;flex-wrap:wrap;gap:8px;align-items:center;font-size:12px;color:var(--ts);}
.ev-meta i{font-size:11px;}
.ev-type-badge{padding:2px 10px;border-radius:99px;font-size:11px;font-weight:700;margin-left:auto;}
.ev-days{font-size:11px;font-weight:700;padding:2px 8px;border-radius:99px;}
.ev-days.soon{background:var(--rl);color:var(--r);}
.ev-days.near{background:var(--wl);color:#92400e;}
.ev-days.far {background:var(--bl);color:#1d4ed8;}
.ev-days.today-lbl{background:var(--gl);color:#065f46;}
.ev-days.past-lbl{background:var(--pg);color:var(--ts);}

/* ── EVENT TABLE ── */
.etbl{width:100%;border-collapse:collapse;font-size:13px;}
.etbl th{font-size:10px;font-weight:700;color:var(--ts);text-transform:uppercase;
  letter-spacing:.04em;padding:8px 12px;border-bottom:2px solid var(--bd);text-align:left;white-space:nowrap;}
.etbl td{padding:10px 12px;border-bottom:1px solid var(--bd);vertical-align:middle;}
.etbl tr:hover td{background:#f7f8ff;}
.etbl tr:last-child td{border-bottom:none;}

/* Progress bars */
.pi{margin-bottom:12px;}
.pi-lbl{display:flex;justify-content:space-between;font-size:12px;font-weight:500;
  color:var(--tx);margin-bottom:4px;}
.pi-lbl span:last-child{color:var(--ts);}
.pi-track{height:8px;background:var(--bd);border-radius:99px;overflow:hidden;}
.pi-fill{height:8px;border-radius:99px;transition:width 1.1s ease;width:0%;}

/* Suggestions */
.sugg-card{background:linear-gradient(135deg,#0c1445,#1a2980);
  border-radius:var(--rad);padding:20px;color:#fff;
  margin-bottom:18px;box-shadow:var(--shm);}
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

/* Modal for event detail */
.ev-modal{position:fixed;inset:0;background:rgba(0,0,0,.5);z-index:1000;
  display:flex;align-items:center;justify-content:center;
  animation:fadeIn .2s ease;}
@keyframes fadeIn{from{opacity:0}to{opacity:1}}
.ev-modal-box{background:var(--bg);border-radius:var(--rad);padding:24px;
  max-width:480px;width:90%;box-shadow:var(--shl,0 20px 60px rgba(0,0,0,.3));
  position:relative;animation:slideUp .25s ease;}
@keyframes slideUp{from{transform:translateY(20px);opacity:0}to{transform:none;opacity:1}}
.ev-modal-close{position:absolute;top:12px;right:14px;background:none;border:none;
  font-size:18px;cursor:pointer;color:var(--ts);}
.ev-modal-close:hover{color:var(--tx);}

/* Empty/spin */
.empty{text-align:center;padding:40px;color:var(--tm);}
.empty i{font-size:32px;display:block;margin-bottom:10px;opacity:.4;}
.empty p{font-size:13px;}
.spin{display:inline-block;width:20px;height:20px;border:2px solid var(--bd);
  border-top-color:var(--p);border-radius:50%;animation:spin .7s linear infinite;}

/* Responsive */
@media(max-width:1100px){.g21,.g12{grid-template-columns:1fr;}.g3{grid-template-columns:1fr 1fr;}}
@media(max-width:700px){.g2,.g3{grid-template-columns:1fr;}.kpi-grid{grid-template-columns:1fr 1fr;}.cal-day{min-height:55px;}}
@media(max-width:460px){.kpi-grid{grid-template-columns:1fr 1fr;}.tab-btn{font-size:11px;padding:7px 10px;}}
</style>
</asp:Content>

<asp:Content ID="cBody" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

<%-- Server → Client hidden fields --%>
<asp:HiddenField ID="hdnInst"     runat="server"/>
<asp:HiddenField ID="hdnSess"     runat="server"/>
<asp:HiddenField ID="hdnDfr"      runat="server"/>
<asp:HiddenField ID="hdnDto"      runat="server"/>
<asp:HiddenField ID="hdnCurYear"  runat="server"/>
<asp:HiddenField ID="hdnCurMonth" runat="server"/>
<asp:Label       ID="lblSess"     runat="server" Style="display:none;"/>

<%-- Hidden ASP dropdowns for server-init --%>
<asp:DropDownList ID="aspEventType" runat="server" Style="display:none;"/>
<asp:DropDownList ID="aspStream"    runat="server" Style="display:none;"/>

<div class="wrap">

<%-- BANNER --%>
<div class="banner">
  <div class="b-wave">
    <svg viewBox="0 0 1440 55" preserveAspectRatio="none" xmlns="http://www.w3.org/2000/svg">
      <path d="M0,28 C360,55 720,0 1080,28 C1260,42 1380,18 1440,28 L1440,55 L0,55 Z"
            fill="rgba(255,255,255,.05)"/>
    </svg>
  </div>
  <div class="b-ov"></div>
  <div class="b-body">
    <div>
      <div class="b-eyebrow"><i class="fa fa-calendar-days"></i>Events & Calendar</div>
      <div class="b-title">Events & Calendar Dashboard</div>
      <div class="b-sub">Session: <span id="bSess"></span> &nbsp;&bull;&nbsp; Full event lifecycle analytics</div>
      <div class="b-kpis">
        <div class="bk"><div class="bk-v" id="bTotal">—</div><div class="bk-l">Total Events</div></div>
        <div class="bdiv"></div>
        <div class="bk"><div class="bk-v" id="bUpcoming">—</div><div class="bk-l">Upcoming 30d</div></div>
        <div class="bdiv"></div>
        <div class="bk"><div class="bk-v" id="bToday">—</div><div class="bk-l">Today</div></div>
        <div class="bdiv"></div>
        <div class="bk"><div class="bk-v" id="bNext7">—</div><div class="bk-l">Next 7 Days</div></div>
        <div class="bdiv"></div>
        <div class="bk"><div class="bk-v" id="bCats">—</div><div class="bk-l">Categories</div></div>
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

<%-- FILTER BAR --%>
<div class="fb">
  <div class="fb-hd">
    <div class="fb-lbl"><i class="fa fa-filter"></i>Filters</div>
    <div class="fb-acts">
      <button type="button" class="btn-rs" id="btnReset"><i class="fa fa-rotate"></i> Reset</button>
      <button type="button" class="btn-ap" id="btnApply"><i class="fa fa-magnifying-glass"></i> Apply</button>
    </div>
  </div>
  <div class="f-row">
    <div class="fg"><label>Event Type</label>
      <select id="fType" class="fsel"><option value="">All Types</option></select>
    </div>
    <div class="fg"><label>Status</label>
      <select id="fStatus" class="fsel">
        <option value="">All</option>
        <option value="upcoming">Upcoming</option>
        <option value="past">Past</option>
        <option value="today">Today</option>
      </select>
    </div>
    <div class="fg" style="min-width:130px;"><label>From Date</label>
      <input type="date" id="fDfr" class="fdate"/>
    </div>
    <div class="fg" style="min-width:130px;"><label>To Date</label>
      <input type="date" id="fDto" class="fdate"/>
    </div>
  </div>
  <div class="qr-row">
    <button type="button" class="qr" data-days="7">Next 7 Days</button>
    <button type="button" class="qr" data-days="30">Next 30 Days</button>
    <button type="button" class="qr on" data-curyear="1">This Year</button>
    <button type="button" class="qr" data-curmon="1">This Month</button>
    <button type="button" class="qr" data-full="1">All Events</button>
  </div>
  <div class="lbar" id="lbar"></div>
  <div class="afc" id="afcWrap"></div>
</div>

<%-- KPI CARDS --%>
<div class="kpi-grid">
  <div class="kpi kb">
    <div class="kpi-top"><span class="klbl">Total Events</span><div class="kico ib"><i class="fa fa-calendar-days"></i></div></div>
    <div class="kval" id="kTotal">—</div><div class="ksub">In selected range</div>
  </div>
  <div class="kpi kg">
    <div class="kpi-top"><span class="klbl">Upcoming (30d)</span><div class="kico ig"><i class="fa fa-arrow-trend-up"></i></div></div>
    <div class="kval" id="kUpcoming">—</div><div class="ksub">Next 30 days</div>
  </div>
  <div class="kpi kp">
    <div class="kpi-top"><span class="klbl">Today's Events</span><div class="kico ip"><i class="fa fa-circle-dot"></i></div></div>
    <div class="kval" id="kToday">—</div><div class="ksub">Happening today</div>
  </div>
  <div class="kpi kw">
    <div class="kpi-top"><span class="klbl">Next 7 Days</span><div class="kico iw"><i class="fa fa-calendar-week"></i></div></div>
    <div class="kval" id="kNext7">—</div><div class="ksub">This week ahead</div>
  </div>
  <div class="kpi kt">
    <div class="kpi-top"><span class="klbl">This Month</span><div class="kico it"><i class="fa fa-calendar"></i></div></div>
    <div class="kval" id="kThisMonth">—</div><div class="ksub">Events this month</div>
  </div>
  <div class="kpi kr">
    <div class="kpi-top"><span class="klbl">Past Events</span><div class="kico ir"><i class="fa fa-calendar-xmark"></i></div></div>
    <div class="kval" id="kPast">—</div><div class="ksub">Already completed</div>
  </div>
  <div class="kpi kpk">
    <div class="kpi-top"><span class="klbl">Categories</span><div class="kico ipk"><i class="fa fa-tags"></i></div></div>
    <div class="kval" id="kCats">—</div><div class="ksub">Event types</div>
  </div>
  <div class="kpi kor">
    <div class="kpi-top"><span class="klbl">Notifications</span><div class="kico ior"><i class="fa fa-bell"></i></div></div>
    <div class="kval" id="kNotif">—</div><div class="ksub">Sent this period</div>
  </div>
</div>

<%-- TABS --%>
<div class="tab-bar" id="tabBar">
  <button type="button" class="tab-btn on" data-tab="calendar"><i class="fa fa-calendar"></i>Calendar</button>
  <button type="button" class="tab-btn" data-tab="upcoming"><i class="fa fa-arrow-trend-up"></i>Upcoming</button>
  <button type="button" class="tab-btn" data-tab="analytics"><i class="fa fa-chart-pie"></i>Analytics</button>
  <button type="button" class="tab-btn" data-tab="list"><i class="fa fa-list"></i>All Events</button>
  <button type="button" class="tab-btn" data-tab="past"><i class="fa fa-clock-rotate-left"></i>Past Events</button>
  <button type="button" class="tab-btn" data-tab="insights"><i class="fa fa-lightbulb"></i>Admin Insights</button>
</div>

<%-- ══ TAB: CALENDAR ══ --%>
<div id="tab-calendar" class="tab-pane on">
  <div class="g12">
    <div>
      <%-- Interactive Calendar --%>
      <div class="cal-wrap card" style="padding:0;margin-bottom:16px;">
        <div class="cal-header">
          <div class="cal-nav">
            <button type="button" id="calPrev"><i class="fa fa-chevron-left"></i></button>
            <div class="cal-month-lbl" id="calLabel">Loading…</div>
            <button type="button" id="calNext"><i class="fa fa-chevron-right"></i></button>
          </div>
          <button type="button" id="calToday" style="background:rgba(255,255,255,.2);border:none;color:#fff;
            padding:5px 14px;border-radius:var(--rads);cursor:pointer;font-size:12px;font-weight:700;">
            Today
          </button>
        </div>
        <div class="cal-grid" id="calDayHeaders"></div>
        <div class="cal-grid" id="calBody" style="grid-template-columns:repeat(7,1fr);"></div>
      </div>
      <%-- Legend --%>
      <div class="card" style="padding:14px 20px;">
        <div style="font-size:11px;font-weight:700;color:var(--ts);text-transform:uppercase;
          letter-spacing:.05em;margin-bottom:10px;">Event Types</div>
        <div id="legendBox" style="display:flex;flex-wrap:wrap;gap:8px;"></div>
      </div>
    </div>
    <%-- Today / selected day events panel --%>
    <div>
      <div class="card" style="margin-bottom:16px;">
        <div class="card-hd">
          <div class="card-hd-l">
            <div class="cico" style="background:var(--gl);color:var(--g);"><i class="fa fa-circle-dot"></i></div>
            <div><div class="ct" id="dayPanelTitle">Today's Events</div>
              <div class="cs" id="dayPanelDate"></div></div>
          </div>
        </div>
        <div id="dayEvents"><div class="empty"><div class="spin"></div></div></div>
      </div>
      <div class="card">
        <div class="card-hd">
          <div class="card-hd-l">
            <div class="cico" style="background:var(--wl);color:var(--w);"><i class="fa fa-calendar-week"></i></div>
            <div><div class="ct">Next 7 Days</div><div class="cs">Quick view</div></div>
          </div>
        </div>
        <div id="next7List"><div class="empty"><div class="spin"></div></div></div>
      </div>
    </div>
  </div>
</div>

<%-- ══ TAB: UPCOMING ══ --%>
<div id="tab-upcoming" class="tab-pane">
  <div class="g21">
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--bl);color:var(--b);"><i class="fa fa-arrow-trend-up"></i></div>
          <div><div class="ct">Upcoming Events</div>
            <div class="cs">Next events sorted by date</div></div>
        </div>
        <span style="font-size:11px;color:var(--tm);" id="upCount"></span>
      </div>
      <div id="upcomingList"><div class="empty"><div class="spin"></div></div></div>
    </div>
    <div>
      <div class="card" style="margin-bottom:16px;">
        <div class="card-hd">
          <div class="card-hd-l">
            <div class="cico" style="background:var(--pul);color:var(--pu);"><i class="fa fa-chart-pie"></i></div>
            <div><div class="ct">By Event Type</div></div>
          </div>
        </div>
        <div class="cb" style="height:220px;"><canvas id="cTypeDonut"></canvas></div>
        <div id="typeDonutLeg" style="display:flex;flex-wrap:wrap;gap:6px;justify-content:center;margin-top:10px;"></div>
      </div>
      <div class="card">
        <div class="card-hd">
          <div class="card-hd-l">
            <div class="cico" style="background:var(--tl);color:var(--t);"><i class="fa fa-layer-group"></i></div>
            <div><div class="ct">Type Distribution</div></div>
          </div>
        </div>
        <div id="typeBars"></div>
      </div>
    </div>
  </div>
</div>

<%-- ══ TAB: ANALYTICS ══ --%>
<div id="tab-analytics" class="tab-pane">
  <div class="g2">
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--pl);color:var(--p);"><i class="fa fa-chart-line"></i></div>
          <div><div class="ct">Monthly Event Count — 12 Months</div>
            <div class="cs">Events created/scheduled per month</div></div>
        </div>
      </div>
      <div class="cb" style="height:240px;"><canvas id="cMonthly"></canvas></div>
    </div>
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--wl);color:var(--w);"><i class="fa fa-calendar-days"></i></div>
          <div><div class="ct">Day-of-Week Pattern</div>
            <div class="cs">Which day has most events?</div></div>
        </div>
      </div>
      <div class="cb" style="height:240px;"><canvas id="cDayOfWeek"></canvas></div>
    </div>
  </div>
  <div class="g2">
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--orl);color:var(--or);"><i class="fa fa-bell"></i></div>
          <div><div class="ct">Notification Trend</div>
            <div class="cs">Notifications sent over time</div></div>
        </div>
      </div>
      <div class="cb" style="height:220px;"><canvas id="cNotif"></canvas></div>
    </div>
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--gl);color:var(--g);"><i class="fa fa-chart-bar"></i></div>
          <div><div class="ct">Events by Category</div>
            <div class="cs">Upcoming vs Past breakdown</div></div>
        </div>
      </div>
      <div class="cb" style="height:220px;"><canvas id="cTypeSplit"></canvas></div>
    </div>
  </div>
</div>

<%-- ══ TAB: ALL EVENTS LIST ══ --%>
<div id="tab-list" class="tab-pane">
  <div class="card">
    <div class="card-hd">
      <div class="card-hd-l">
        <div class="cico" style="background:var(--bl);color:var(--b);"><i class="fa fa-list"></i></div>
        <div><div class="ct">All Events</div>
          <div class="cs" id="listCount">Loading…</div></div>
      </div>
      <div style="display:flex;gap:8px;align-items:center;">
        <input type="text" id="evSearch" class="fsel" style="width:200px;padding:6px 10px;"
               placeholder="Search events…"/>
      </div>
    </div>
    <div style="overflow-x:auto;">
      <table class="etbl">
        <thead>
          <tr>
            <th>#</th><th>Title</th><th>Type</th>
            <th>Date</th><th>Time</th><th>Location</th><th>Status</th><th>Days</th>
          </tr>
        </thead>
        <tbody id="evTbody">
          <tr><td colspan="8"><div class="empty"><div class="spin"></div></div></td></tr>
        </tbody>
      </table>
    </div>
  </div>
</div>

<%-- ══ TAB: PAST EVENTS ══ --%>
<div id="tab-past" class="tab-pane">
  <div class="g21">
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--pg);color:var(--ts);"><i class="fa fa-clock-rotate-left"></i></div>
          <div><div class="ct">Past Events</div>
            <div class="cs">Recently completed events</div></div>
        </div>
      </div>
      <div id="pastList"><div class="empty"><div class="spin"></div></div></div>
    </div>
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--tl);color:var(--t);"><i class="fa fa-chart-pie"></i></div>
          <div><div class="ct">Past Events by Type</div></div>
        </div>
      </div>
      <div class="cb" style="height:260px;"><canvas id="cPastType"></canvas></div>
    </div>
  </div>
</div>

<%-- ══ TAB: ADMIN INSIGHTS ══ --%>
<div id="tab-insights" class="tab-pane">
  <div id="suggBox"></div>
  <div class="card">
    <div class="card-hd">
      <div class="card-hd-l">
        <div class="cico" style="background:var(--pl);color:var(--p);"><i class="fa fa-graduation-cap"></i></div>
        <div><div class="ct">Events Dashboard Guide</div>
          <div class="cs">How to interpret and act on event data</div></div>
      </div>
    </div>
    <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(230px,1fr));gap:14px;">
      <div style="background:var(--bl);border-radius:var(--rads);padding:14px;">
        <div style="font-weight:700;color:var(--b);margin-bottom:6px;"><i class="fa fa-calendar-check" style="margin-right:5px;"></i>Event Planning</div>
        <p style="font-size:12px;line-height:1.7;">Use the <strong>Monthly Trend</strong> to spot gaps — months with 0 events mean disengagement. Plan events 2-3 weeks apart for consistent student engagement throughout the academic year.</p>
      </div>
      <div style="background:var(--gl);border-radius:var(--rads);padding:14px;">
        <div style="font-weight:700;color:var(--gd);margin-bottom:6px;"><i class="fa fa-tags" style="margin-right:5px;"></i>Category Balance</div>
        <p style="font-size:12px;line-height:1.7;">A healthy event calendar should have a mix of Academic (Exams, Seminars), Cultural, Sports, and Holiday events. If one type dominates &gt;70%, add variety to keep students engaged.</p>
      </div>
      <div style="background:var(--wl);border-radius:var(--rads);padding:14px;">
        <div style="font-weight:700;color:var(--w);margin-bottom:6px;"><i class="fa fa-bell" style="margin-right:5px;"></i>Notification Strategy</div>
        <p style="font-size:12px;line-height:1.7;">Send event notifications 7 days and 24 hours before. Check the <strong>Notification Trend</strong> — spikes mean reminders went out. Low notifications = students may miss events.</p>
      </div>
      <div style="background:var(--pul);border-radius:var(--rads);padding:14px;">
        <div style="font-weight:700;color:var(--p);margin-bottom:6px;"><i class="fa fa-calendar-days" style="margin-right:5px;"></i>Day Pattern</div>
        <p style="font-size:12px;line-height:1.7;">Check <strong>Day-of-Week Pattern</strong> — avoid scheduling multiple critical events on Mondays/Fridays. Mid-week events (Tue-Thu) typically have higher attendance.</p>
      </div>
      <div style="background:var(--rol);border-radius:var(--rads);padding:14px;">
        <div style="font-weight:700;color:var(--ro);margin-bottom:6px;"><i class="fa fa-triangle-exclamation" style="margin-right:5px;"></i>Event Clusters</div>
        <p style="font-size:12px;line-height:1.7;">Multiple events on the same day can cause student fatigue. Use the calendar heatmap to spot clusters. Redistribute events so students can participate fully in each.</p>
      </div>
      <div style="background:var(--tl);border-radius:var(--rads);padding:14px;">
        <div style="font-weight:700;color:var(--t);margin-bottom:6px;"><i class="fa fa-file-lines" style="margin-right:5px;"></i>Missing Descriptions</div>
        <p style="font-size:12px;line-height:1.7;">Events without descriptions reduce student participation. Ask coordinators to add venue, agenda, and contact details for every upcoming event for better communication.</p>
      </div>
    </div>
  </div>
</div>

</div><%-- /wrap --%>

<%-- Event Detail Modal --%>
<div id="evModal" class="ev-modal" style="display:none;">
  <div class="ev-modal-box">
    <button type="button" class="ev-modal-close" onclick="closeModal()"><i class="fa fa-xmark"></i></button>
    <div id="evModalContent"></div>
  </div>
</div>

<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.4.1/chart.umd.min.js"></script>
<script>
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

/* Calendar state */
var calYear  = parseInt(hv('<%= hdnCurYear.ClientID %>'))  || new Date().getFullYear();
var calMonth = parseInt(hv('<%= hdnCurMonth.ClientID %>')) || (new Date().getMonth()+1);
var allEventsData = [];
var selectedDay   = null;

/* Palette & chart config */
var PAL=['#4f46e5','#10b981','#f59e0b','#ef4444','#8b5cf6',
         '#3b82f6','#0d9488','#f43f5e','#0891b2','#ea580c','#ec4899','#84cc16'];
var TYPE_COL={
  Exam:'#ef4444',Holiday:'#10b981',Seminar:'#3b82f6',Workshop:'#f59e0b',
  Cultural:'#ec4899',Sports:'#0d9488',Meeting:'#8b5cf6',General:'#64748b',Other:'#94a3b8'
};
var GRD={color:'rgba(148,163,184,.12)'};
var TICK={font:{size:11,family:"'Inter','Segoe UI',sans-serif"}};
var TT={padding:10,cornerRadius:8,bodyFont:{size:12},titleFont:{size:12,weight:'bold'}};
var ANIM={duration:950,easing:'easeInOutQuart'};
function palA(a){return PAL.map(function(c){return c+Math.round(a*255).toString(16).padStart(2,'0');});}

var charts={}, debT=null, lastData=null;

/* ════════════════════════════════════════════════════════
   INIT — clone ASP dropdowns, set default dates, wire events
════════════════════════════════════════════════════════ */
var DDL_MAP={
  '<%= aspEventType.ClientID %>':'fType'
};
Object.keys(DDL_MAP).forEach(function(aspId){
  var asp=document.getElementById(aspId), js=document.getElementById(DDL_MAP[aspId]);
  if(!asp||!js) return;
  Array.prototype.forEach.call(asp.options,function(o){
    if(!o.value&&o.value!=='') return;
    if(js.querySelector('option[value="'+o.value+'"]')) return;
    var n=document.createElement('option'); n.value=o.value; n.text=o.text; js.appendChild(n);
  });
});

document.getElementById('fDfr').value = DEF_FR;
document.getElementById('fDto').value = DEF_TO;
document.querySelectorAll('.qr[data-curyear]').forEach(function(b){b.classList.add('on');});

/* ── Buttons ── */
function G(id){return document.getElementById(id);}

G('btnApply').addEventListener('click',function(e){e.preventDefault();go();});
G('btnReset').addEventListener('click',function(e){e.preventDefault();resetF();});
G('fDfr').addEventListener('change',function(){clearPills();go();});
G('fDto').addEventListener('change',function(){clearPills();go();});
G('fType').addEventListener('change',function(){go();});
G('fStatus').addEventListener('change',function(){renderEventTable();});
G('evSearch').addEventListener('input',function(){renderEventTable();});

document.querySelectorAll('.qr').forEach(function(btn){
  btn.addEventListener('click',function(e){
    e.preventDefault(); clearPills(); this.classList.add('on');
    var days=this.dataset.days, cm=this.dataset.curmon, cy=this.dataset.curyear, full=this.dataset.full;
    var today=new Date();
    if(full){ G('fDfr').value=''; G('fDto').value=''; }
    else if(cm){
      G('fDfr').value=fmt(new Date(today.getFullYear(),today.getMonth(),1));
      G('fDto').value=fmt(new Date(today.getFullYear(),today.getMonth()+1,0));
    } else if(cy){
      G('fDfr').value=fmt(new Date(today.getFullYear(),0,1));
      G('fDto').value=fmt(new Date(today.getFullYear(),11,31));
    } else if(days){
      var fr=new Date(); fr.setDate(today.getDate());
      var to=new Date(); to.setDate(today.getDate()+parseInt(days)-1);
      G('fDfr').value=fmt(fr); G('fDto').value=fmt(to);
    }
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

/* Calendar navigation */
G('calPrev').addEventListener('click',function(e){
  e.preventDefault();
  calMonth--; if(calMonth<1){calMonth=12;calYear--;}
  renderCalendar();
});
G('calNext').addEventListener('click',function(e){
  e.preventDefault();
  calMonth++; if(calMonth>12){calMonth=1;calYear++;}
  renderCalendar();
});
G('calToday').addEventListener('click',function(e){
  e.preventDefault();
  var n=new Date(); calYear=n.getFullYear(); calMonth=n.getMonth()+1;
  renderCalendar();
});

function clearPills(){document.querySelectorAll('.qr').forEach(function(b){b.classList.remove('on');});}
function fmt(d){return d.toISOString().split('T')[0];}

/* ════════════════════════════════════════════════════════
   FILTER STATE
════════════════════════════════════════════════════════ */
function getF(){
  return{
    evtype:  G('fType').value||'',
    datefrom:G('fDfr').value||'',
    dateto:  G('fDto').value||''
  };
}

function buildURL(extra){
  var f=getF();
  var u=location.pathname+'?ajax=1&inst='+encodeURIComponent(INST)+'&sess='+encodeURIComponent(SESS)
    +'&evtype='+encodeURIComponent(f.evtype)
    +'&datefrom='+f.datefrom+'&dateto='+f.dateto
    +'&calyear='+calYear+'&calmonth='+calMonth;
  if(extra) Object.keys(extra).forEach(function(k){u+='&'+k+'='+encodeURIComponent(extra[k]);});
  return u;
}

function resetF(){
  G('fType').value=''; G('fStatus').value='';
  G('fDfr').value=DEF_FR; G('fDto').value=DEF_TO;
  G('afcWrap').innerHTML='';
  clearPills();
  document.querySelectorAll('.qr[data-curyear]').forEach(function(b){b.classList.add('on');});
  go();
}

function updateChips(){
  var wrap=G('afcWrap'); wrap.innerHTML='';
  var f=getF();
  if(f.evtype){
    var c=document.createElement('span'); c.className='afc-chip';
    c.innerHTML='Type: '+esc(f.evtype)+' <i class="fa fa-xmark" style="font-size:10px;opacity:.7;"></i>';
    c.addEventListener('click',function(){G('fType').value='';go();});
    wrap.appendChild(c);
  }
  if(f.datefrom||f.dateto){
    var c2=document.createElement('span'); c2.className='afc-chip';
    c2.innerText=(f.datefrom||'Start')+' → '+(f.dateto||'Now');
    wrap.appendChild(c2);
  }
}

/* ════════════════════════════════════════════════════════
   MAIN FETCH
════════════════════════════════════════════════════════ */
function go(){
  clearTimeout(debT);
  debT=setTimeout(fetchData,280);
}

function fetchData(){
  setLoad(true); updateChips();
  fetch(buildURL())
    .then(function(r){if(!r.ok)throw new Error('HTTP '+r.status);return r.json();})
    .then(function(d){
      lastData=d;
      allEventsData=d.allEvents||[];
      renderKPIs(d.kpi);
      renderAllCharts(d);
      renderCalendar(d.heatmap);
      renderUpcomingList(d.upcoming);
      renderEventTable();
      renderPastList(d.pastEvents);
      renderTypeBars(d.typeBreak);
      renderSuggestions(d.adminStats, d.kpi);
      buildLegend(d.typeBreak);
      setLoad(false);
    })
    .catch(function(err){setLoad(false);console.error('[Events]',err);});
}

function setLoad(on){
  var bar=G('lbar'), sp=G('gSpin');
  bar.style.width=on?'82%':'100%';
  sp.style.display=on?'inline-block':'none';
  if(!on) setTimeout(function(){bar.style.width='0%';},600);
}

/* ════════════════════════════════════════════════════════
   KPIs
════════════════════════════════════════════════════════ */
function renderKPIs(k){
  if(!k) return;
  cu('kTotal',     k.totalEvents);
  cu('kUpcoming',  k.upcomingNext30);
  cu('kToday',     k.todayEvents);
  cu('kNext7',     k.next7Days);
  cu('kThisMonth', k.thisMonthEvents);
  cu('kPast',      k.pastEvents);
  cu('kCats',      k.eventCategories);
  cu('kNotif',     k.notificationsSent);
  /* Banner */
  G('bTotal').innerText    = k.totalEvents||0;
  G('bUpcoming').innerText = k.upcomingNext30||0;
  G('bToday').innerText    = k.todayEvents||0;
  G('bNext7').innerText    = k.next7Days||0;
  G('bCats').innerText     = k.eventCategories||0;
}

function cu(id,n){
  var el=G(id); if(!el) return;
  var t=parseInt(n)||0, s=parseInt(el.innerText)||0, diff=t-s, steps=28, i=0;
  var iv=setInterval(function(){i++;el.innerText=Math.round(s+diff*(i/steps));
    if(i>=steps){el.innerText=t;clearInterval(iv);}},16);
}

/* ════════════════════════════════════════════════════════
   INTERACTIVE CALENDAR
════════════════════════════════════════════════════════ */
function renderCalendar(heatmapData){
  /* Draw day-of-week headers */
  var dhdr=G('calDayHeaders');
  if(dhdr.children.length===0){
    ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'].forEach(function(d){
      var el=document.createElement('div'); el.className='cal-day-hdr'; el.innerText=d;
      dhdr.appendChild(el);
    });
  }

  /* Build heatmap lookup: day → events */
  var hm={};
  if(heatmapData){
    heatmapData.forEach(function(r){
      var day=parseInt(r.Day);
      if(!hm[day]) hm[day]=[];
      hm[day].push({type:r.EventType, count:r.EventCount, titles:r.EventTitles||''});
    });
  }

  /* Update label */
  var MONTHS=['January','February','March','April','May','June',
              'July','August','September','October','November','December'];
  G('calLabel').innerText=MONTHS[calMonth-1]+' '+calYear;

  var body=G('calBody'); body.innerHTML='';
  var firstDay=new Date(calYear,calMonth-1,1).getDay();
  var daysInMonth=new Date(calYear,calMonth,0).getDate();
  var today=new Date();
  var todayStr=fmt(today);

  /* Empty cells before first day */
  for(var i=0;i<firstDay;i++){
    var blank=document.createElement('div'); blank.className='cal-day other-month';
    body.appendChild(blank);
  }

  /* Day cells */
  for(var d=1;d<=daysInMonth;d++){
    var cell=document.createElement('div');
    var dateStr=calYear+'-'+(calMonth<10?'0'+calMonth:calMonth)+'-'+(d<10?'0'+d:d);
    cell.className='cal-day'+(dateStr===todayStr?' today':'')+(hm[d]?' has-events':'');
    cell.dataset.day=d; cell.dataset.date=dateStr;

    var dn=document.createElement('span'); dn.className='cal-dn'; dn.innerText=d;
    cell.appendChild(dn);

    if(hm[d]){
      var evList=document.createElement('div'); evList.className='cal-events-list';
      var shown=0;
      hm[d].forEach(function(ev){
        if(shown>=2) return;
        var dot=document.createElement('div'); dot.className='cal-ev-dot';
        var col=TYPE_COL[ev.type]||'#94a3b8';
        dot.style.cssText='background:'+col+'22;color:'+col+';border-left:3px solid '+col+';';
        dot.title=ev.titles;
        dot.innerText=ev.type; evList.appendChild(dot); shown++;
      });
      var totalEv=hm[d].reduce(function(a,e){return a+(e.count||0);},0);
      if(totalEv>2){
        var more=document.createElement('div'); more.className='cal-more';
        more.innerText='+'+(totalEv-2)+' more'; evList.appendChild(more);
      }
      cell.appendChild(evList);
    }

    (function(day, dstr){
      cell.addEventListener('click',function(){selectDay(day, dstr);});
    })(d, dateStr);

    body.appendChild(cell);
  }

  /* Fill remaining cells */
  var totalCells=firstDay+daysInMonth;
  var remainder=totalCells%7===0?0:7-(totalCells%7);
  for(var j=0;j<remainder;j++){
    var end=document.createElement('div'); end.className='cal-day other-month';
    body.appendChild(end);
  }

  /* Show today's events on initial load */
  if(!selectedDay) selectDay(today.getDate(), todayStr);
}

function selectDay(day, dateStr){
  selectedDay={day:day, date:dateStr};
  /* Highlight selected */
  document.querySelectorAll('.cal-day').forEach(function(c){c.style.outline='none';});
  var cells=document.querySelectorAll('.cal-day');
  cells.forEach(function(c){
    if(c.dataset.date===dateStr) c.style.outline='2px solid var(--p)';
  });
  /* Show events for that day */
  var dayEvs=allEventsData.filter(function(e){return e.EventDateStr===dateStr;});
  var panel=G('dayEvents'), title=G('dayPanelTitle'), sub=G('dayPanelDate');
  var MONTHS=['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
  var parts=dateStr.split('-');
  sub.innerText=MONTHS[parseInt(parts[1])-1]+' '+parts[2]+', '+parts[0];
  var isToday=dateStr===fmt(new Date());
  title.innerText=isToday?'Today\'s Events':'Events on '+sub.innerText;

  if(!dayEvs.length){
    panel.innerHTML='<div class="empty" style="padding:24px;"><i class="fa fa-calendar"></i><p>No events on this day</p></div>';
  } else {
    panel.innerHTML=dayEvs.map(function(ev){
      var col=TYPE_COL[ev.EventType]||'#94a3b8';
      return '<div style="padding:10px;border-left:4px solid '+col+';margin-bottom:8px;'
        +'background:'+col+'11;border-radius:var(--rads);">'
        +'<div style="font-weight:700;font-size:13px;">'+esc(ev.Title||'')+'</div>'
        +'<div style="font-size:11px;color:var(--ts);margin-top:3px;">'
        +(ev.StartTime?'<i class="fa fa-clock"></i> '+esc(ev.StartTime)+' &nbsp;':'')
        +(ev.Location?'<i class="fa fa-location-dot"></i> '+esc(ev.Location):'')
        +'</div></div>';
    }).join('');
  }

  /* Next 7 days */
  renderNext7(dateStr);
}

function renderNext7(fromDate){
  var fr=new Date(fromDate), evs=[];
  for(var i=0;i<7;i++){
    var d=new Date(fr); d.setDate(fr.getDate()+i);
    var ds=fmt(d);
    allEventsData.filter(function(e){return e.EventDateStr===ds;})
      .forEach(function(e){evs.push(e);});
  }
  var wrap=G('next7List');
  if(!evs.length){wrap.innerHTML='<div class="empty" style="padding:20px;"><i class="fa fa-calendar-week"></i><p>No events in next 7 days</p></div>';return;}
  wrap.innerHTML=evs.slice(0,6).map(function(ev){
    var col=TYPE_COL[ev.EventType]||'#94a3b8';
    return '<div style="display:flex;gap:10px;align-items:center;padding:8px 0;border-bottom:1px solid var(--bd);">'
      +'<div style="width:36px;height:36px;border-radius:var(--rads);background:'+col+'22;'
        +'display:flex;align-items:center;justify-content:center;flex-shrink:0;color:'+col+';font-size:13px;font-weight:800;">'
        +new Date(ev.EventDateStr).getDate()+'</div>'
      +'<div style="flex:1;min-width:0;">'
        +'<div style="font-weight:700;font-size:12px;">'+esc(ev.Title||'')+'</div>'
        +'<div style="font-size:10px;color:var(--ts);">'+esc(ev.EventType||'General')+'</div>'
      +'</div>'
    +'</div>';
  }).join('');
}

/* ════════════════════════════════════════════════════════
   CHARTS
════════════════════════════════════════════════════════ */
function renderAllCharts(d){
  renderTypeDonut(d.typeBreak);
  renderMonthly(d.monthly);
  renderDayOfWeek(d.dayOfWeek);
  renderNotifTrend(d.notifTrend);
  renderTypeSplit(d.typeBreak);
  renderPastType(d.typeBreak);
}

function dc(k){if(charts[k]){charts[k].destroy();charts[k]=null;}}
function gV(ctx,h,c1,c2){var g=ctx.createLinearGradient(0,0,0,h);g.addColorStop(0,c1);g.addColorStop(1,c2);return g;}
function noData(id,msg){
  var el=G(id); if(!el) return;
  var box=el.closest('.cb');
  if(box) box.innerHTML='<div class="empty"><i class="fa fa-calendar"></i><p>'+(msg||'No data')+'</p></div>';
}

/* 1. Type donut */
function renderTypeDonut(data){
  dc('typeDonut');
  var leg=G('typeDonutLeg'); if(leg) leg.innerHTML='';
  if(!data||!data.length){noData('cTypeDonut','No data');return;}
  var el=G('cTypeDonut'); if(!el) return;
  var cols=data.map(function(r){return TYPE_COL[r.EventType]||PAL[0];});
  charts.typeDonut=new Chart(el,{type:'doughnut',data:{
    labels:data.map(function(r){return r.EventType;}),
    datasets:[{data:data.map(function(r){return r.Total||0;}),
      backgroundColor:cols,borderWidth:2,borderColor:'#fff',hoverOffset:10}]
  },options:{cutout:'58%',responsive:true,maintainAspectRatio:false,
    plugins:{legend:{display:false},tooltip:TT},
    animation:{animateRotate:true,duration:1100}}});
  if(leg){
    data.forEach(function(r,i){
      leg.innerHTML+='<div style="display:flex;align-items:center;gap:5px;font-size:11px;">'
        +'<span style="width:10px;height:10px;border-radius:2px;background:'+cols[i]+';display:inline-block;flex-shrink:0;"></span>'
        +esc(r.EventType)+' <strong style="color:'+cols[i]+';">'+r.Total+'</strong></div>';
    });
  }
}

/* 2. Monthly trend */
function renderMonthly(data){
  dc('monthly');
  if(!data||!data.length){noData('cMonthly','No monthly data');return;}
  var el=G('cMonthly'); if(!el) return;
  var ctx=el.getContext('2d');
  var grad=gV(ctx,220,'rgba(79,70,229,.28)','rgba(79,70,229,.01)');
  charts.monthly=new Chart(el,{type:'line',data:{
    labels:data.map(function(r){return r.MonLabel;}),
    datasets:[{label:'Events',data:data.map(function(r){return r.EventCount||0;}),
      borderColor:'#4f46e5',backgroundColor:grad,borderWidth:2.5,tension:.42,fill:true,
      pointRadius:4,pointHoverRadius:8,pointBackgroundColor:'#4f46e5',
      pointHoverBackgroundColor:'#fff',pointHoverBorderColor:'#4f46e5',pointHoverBorderWidth:2}]
  },options:{responsive:true,maintainAspectRatio:false,
    plugins:{legend:{display:false},tooltip:TT},
    scales:{x:{grid:{display:false},ticks:TICK},y:{beginAtZero:true,grid:GRD,ticks:{...TICK,precision:0}}},
    animation:ANIM}});
}

/* 3. Day of week radar */
function renderDayOfWeek(data){
  dc('dayofweek');
  if(!data||!data.length){noData('cDayOfWeek','No data');return;}
  var el=G('cDayOfWeek'); if(!el) return;
  charts.dayofweek=new Chart(el,{type:'radar',data:{
    labels:data.map(function(r){return r.DayName;}),
    datasets:[{label:'Events',data:data.map(function(r){return r.Total||0;}),
      backgroundColor:'rgba(79,70,229,.18)',borderColor:'#4f46e5',borderWidth:2.5,
      pointBackgroundColor:'#4f46e5',pointRadius:4,pointHoverRadius:7}]
  },options:{responsive:true,maintainAspectRatio:false,
    plugins:{legend:{display:false},tooltip:TT},
    scales:{r:{beginAtZero:true,ticks:{font:{size:9}},
      grid:{color:'rgba(148,163,184,.2)'},pointLabels:{font:{size:11}}}},
    animation:{duration:1100,easing:'easeInOutBack'}}});
}

/* 4. Notification trend */
function renderNotifTrend(data){
  dc('notif');
  if(!data||!data.length){noData('cNotif','No notification data');return;}
  var el=G('cNotif'); if(!el) return;
  charts.notif=new Chart(el,{type:'bar',data:{
    labels:data.map(function(r){return r.DateStr;}),
    datasets:[
      {label:'Notifications',data:data.map(function(r){return r.NotifCount||0;}),
       backgroundColor:'rgba(234,88,12,.82)',borderRadius:4},
      {label:'Recipients',data:data.map(function(r){return r.UniqueRecipients||0;}),
       backgroundColor:'rgba(16,185,129,.72)',borderRadius:4}
    ]
  },options:{responsive:true,maintainAspectRatio:false,
    plugins:{legend:{position:'top',labels:{boxWidth:10,font:{size:11}}},tooltip:TT},
    scales:{x:{grid:{display:false},ticks:{font:{size:9},maxTicksLimit:10}},y:{beginAtZero:true,grid:GRD,ticks:TICK}},
    animation:ANIM}});
}

/* 5. Type split bar */
function renderTypeSplit(data){
  dc('typesplit');
  if(!data||!data.length){noData('cTypeSplit','No data');return;}
  var el=G('cTypeSplit'); if(!el) return;
  charts.typesplit=new Chart(el,{type:'bar',data:{
    labels:data.map(function(r){return r.EventType;}),
    datasets:[
      {label:'Upcoming',data:data.map(function(r){return r.Upcoming||0;}),
       backgroundColor:'rgba(59,130,246,.82)',borderRadius:4,stack:'s'},
      {label:'Past',data:data.map(function(r){return r.Past||0;}),
       backgroundColor:'rgba(100,116,139,.55)',borderRadius:4,stack:'s'}
    ]
  },options:{responsive:true,maintainAspectRatio:false,
    interaction:{mode:'index',intersect:false},
    plugins:{legend:{position:'top',labels:{boxWidth:10,font:{size:11}}},tooltip:TT},
    scales:{x:{grid:{display:false},ticks:TICK,stacked:true},y:{grid:GRD,ticks:TICK,stacked:true}},
    animation:ANIM}});
}

/* 6. Past type polar */
function renderPastType(data){
  dc('pasttype');
  if(!data||!data.length){noData('cPastType','No past data');return;}
  var el=G('cPastType'); if(!el) return;
  charts.pasttype=new Chart(el,{type:'polarArea',data:{
    labels:data.map(function(r){return r.EventType;}),
    datasets:[{data:data.map(function(r){return r.Past||0;}),
      backgroundColor:data.map(function(r){
        var col=TYPE_COL[r.EventType]||'#94a3b8';
        return col+'BB';
      }),borderColor:'#fff',borderWidth:2}]
  },options:{responsive:true,maintainAspectRatio:false,
    plugins:{legend:{position:'right',labels:{boxWidth:10,font:{size:11}}},tooltip:TT},
    scales:{r:{beginAtZero:true,ticks:{font:{size:9}},grid:{color:'rgba(148,163,184,.2)'}}},
    animation:{duration:1100,easing:'easeInOutBack'}}});
}

/* ════════════════════════════════════════════════════════
   UPCOMING EVENTS LIST
════════════════════════════════════════════════════════ */
function renderUpcomingList(data){
  var wrap=G('upcomingList'), cnt=G('upCount');
  if(cnt) cnt.innerText=(data?data.length:0)+' events';
  if(!data||!data.length){
    wrap.innerHTML='<div class="empty"><i class="fa fa-calendar-check"></i><p>No upcoming events in this period</p></div>';
    return;
  }
  wrap.innerHTML=data.map(function(ev){
    var days=parseInt(ev.DaysFromNow)||0;
    var dCls=days===0?'today-lbl':days<=3?'soon':days<=14?'near':'far';
    var dTxt=days===0?'Today':days===1?'Tomorrow':'In '+days+'d';
    var evCls=days===0?'today-ev':days<0?'past-ev':'upcoming-ev';
    var col=TYPE_COL[ev.EventType]||'#64748b';
    return '<div class="ev-card '+evCls+'" style="border-left-color:'+col+';">'
      +'<div style="display:flex;align-items:flex-start;justify-content:space-between;gap:8px;">'
        +'<div class="ev-title">'+esc(ev.Title||'')+'</div>'
        +'<div>'
          +'<span class="ev-type-badge" style="background:'+col+'22;color:'+col+';">'+esc(ev.EventType||'General')+'</span>'
        +'</div>'
      +'</div>'
      +'<div class="ev-meta" style="margin-top:6px;">'
        +'<span><i class="fa fa-calendar"></i> '+esc(ev.EventDateStr||'')+'</span>'
        +(ev.StartTime?'<span><i class="fa fa-clock"></i> '+esc(ev.StartTime)+'</span>':'')
        +(ev.Location?'<span><i class="fa fa-location-dot"></i> '+esc(ev.Location)+'</span>':'')
        +'<span class="ev-days '+dCls+'" style="margin-left:auto;">'+dTxt+'</span>'
      +'</div>'
    +'</div>';
  }).join('');
}

/* ════════════════════════════════════════════════════════
   ALL EVENTS TABLE
════════════════════════════════════════════════════════ */
function renderEventTable(){
  var tbody=G('evTbody'), cnt=G('listCount');
  var status=G('fStatus').value;
  var search=(G('evSearch').value||'').toLowerCase();
  var filtered=allEventsData.filter(function(e){
    if(status&&e.Status!==status) return false;
    if(search&&!(e.Title||'').toLowerCase().includes(search)) return false;
    return true;
  });
  if(cnt) cnt.innerText=filtered.length+' events';
  if(!filtered.length){
    tbody.innerHTML='<tr><td colspan="8"><div class="empty"><i class="fa fa-calendar"></i><p>No events match your filters</p></div></td></tr>';
    return;
  }
  var html='';
  filtered.forEach(function(ev,i){
    var days=parseInt(ev.DaysFromNow)||0;
    var statusLbl=ev.Status==='today'?'Today':ev.Status==='past'?'Past':'Upcoming';
    var statusCol=ev.Status==='today'?'var(--g)':ev.Status==='past'?'var(--ts)':'var(--b)';
    var col=TYPE_COL[ev.EventType]||'#64748b';
    var dTxt=ev.Status==='today'?'Today':ev.Status==='past'?days+'d ago':'In '+days+'d';
    html+='<tr>'
      +'<td style="color:var(--tm);font-size:11px;">'+(i+1)+'</td>'
      +'<td style="font-weight:700;max-width:220px;overflow:hidden;text-overflow:ellipsis;">'+esc(ev.Title||'')+'</td>'
      +'<td><span style="padding:2px 8px;border-radius:99px;font-size:11px;font-weight:700;background:'+col+'22;color:'+col+';">'+esc(ev.EventType||'General')+'</span></td>'
      +'<td style="font-size:12px;white-space:nowrap;">'+esc(ev.EventDateStr||'')+'</td>'
      +'<td style="font-size:12px;">'+esc(ev.StartTime||'All day')+'</td>'
      +'<td style="font-size:12px;color:var(--ts);">'+esc(ev.Location||'—')+'</td>'
      +'<td><span style="padding:2px 8px;border-radius:99px;font-size:11px;font-weight:700;color:'+statusCol+';background:'+statusCol+'22;">'+statusLbl+'</span></td>'
      +'<td style="font-size:11px;font-weight:600;color:var(--ts);">'+dTxt+'</td>'
    +'</tr>';
  });
  tbody.innerHTML=html;
}

/* ════════════════════════════════════════════════════════
   PAST EVENTS
════════════════════════════════════════════════════════ */
function renderPastList(data){
  var wrap=G('pastList');
  if(!data||!data.length){
    wrap.innerHTML='<div class="empty"><i class="fa fa-clock-rotate-left"></i><p>No past events in this range</p></div>';
    return;
  }
  wrap.innerHTML=data.map(function(ev){
    var col=TYPE_COL[ev.EventType]||'#94a3b8';
    return '<div class="ev-card past-ev" style="border-left-color:'+col+';">'
      +'<div style="display:flex;align-items:flex-start;justify-content:space-between;gap:8px;">'
        +'<div class="ev-title" style="color:var(--ts);">'+esc(ev.Title||'')+'</div>'
        +'<span class="ev-type-badge" style="background:'+col+'22;color:'+col+';">'+esc(ev.EventType||'General')+'</span>'
      +'</div>'
      +'<div class="ev-meta" style="margin-top:5px;">'
        +'<span><i class="fa fa-calendar"></i> '+esc(ev.EventDateStr||'')+'</span>'
        +(ev.Location?'<span><i class="fa fa-location-dot"></i> '+esc(ev.Location)+'</span>':'')
        +'<span class="ev-days past-lbl" style="margin-left:auto;">'+esc(ev.DaysAgo+' days ago')+'</span>'
      +'</div>'
    +'</div>';
  }).join('');
}

/* ════════════════════════════════════════════════════════
   TYPE BARS
════════════════════════════════════════════════════════ */
function renderTypeBars(data){
  var wrap=G('typeBars'); if(!wrap) return;
  wrap.innerHTML='';
  if(!data||!data.length){wrap.innerHTML='<div class="empty"><i class="fa fa-tags"></i><p>No data</p></div>';return;}
  var max=Math.max.apply(null,data.map(function(r){return r.Total||0;}))||1;
  data.forEach(function(r){
    var pct=Math.round((r.Total||0)/max*100);
    var col=TYPE_COL[r.EventType]||'#94a3b8';
    wrap.innerHTML+='<div class="pi">'
      +'<div class="pi-lbl">'
        +'<span style="color:'+col+';font-weight:700;">'+esc(r.EventType)+'</span>'
        +'<span>'+r.Total+' events</span>'
      +'</div>'
      +'<div class="pi-track"><div class="pi-fill" data-w="'+pct+'%" style="background:'+col+';"></div></div>'
    +'</div>';
  });
  setTimeout(function(){
    wrap.querySelectorAll('.pi-fill[data-w]').forEach(function(el){el.style.width=el.dataset.w;});
  },300);
}

/* ════════════════════════════════════════════════════════
   LEGEND
════════════════════════════════════════════════════════ */
function buildLegend(data){
  var wrap=G('legendBox'); if(!wrap) return;
  wrap.innerHTML='';
  if(!data||!data.length) return;
  data.forEach(function(r){
    var col=TYPE_COL[r.EventType]||'#94a3b8';
    wrap.innerHTML+='<div style="display:flex;align-items:center;gap:5px;font-size:12px;">'
      +'<span style="width:12px;height:12px;border-radius:3px;background:'+col+';display:inline-block;flex-shrink:0;"></span>'
      +esc(r.EventType)+' <span style="color:var(--ts);">('+r.Total+')</span></div>';
  });
}

/* ════════════════════════════════════════════════════════
   ADMIN SUGGESTIONS
════════════════════════════════════════════════════════ */
function renderSuggestions(stats, kpi){
  var wrap=G('suggBox'); if(!wrap) return;
  var s=(stats&&stats.length)?stats[0]:{};
  var k=kpi||{};
  var next7=parseInt(s.Next7)||0;
  var noDesc=parseInt(s.UpcomingNoDesc)||0;
  var notifMon=parseInt(s.NotifThisMonth)||0;
  var monWEv=parseInt(s.MonthsWithEvents)||0;
  var totalYear=parseInt(s.TotalThisYear)||0;
  var bType=s.BusiestType||'—';

  function si(warn,ico,n,hd,txt){
    return '<div class="si '+(warn?'warn':'ok')+'">'
      +'<span class="si-ico">'+ico+'</span>'
      +'<div class="si-n">'+n+'</div>'
      +'<div class="si-hd">'+hd+'</div>'
      +'<div class="si-tx">'+txt+'</div></div>';
  }

  wrap.innerHTML='<div class="sugg-card">'
    +'<div class="sugg-title"><i class="fa fa-lightbulb"></i>Admin Events Intelligence Panel</div>'
    +'<div class="sugg-grid">'
    +si(next7===0,'📅',next7,'Events Next 7 Days',
       next7===0?'No events planned for next week. Consider scheduling an activity to maintain student engagement.'
               :'Good — '+next7+' event(s) planned. Ensure all details and notifications are ready.')
    +si(noDesc>0,'📝',noDesc,'Upcoming Events Without Description',
       noDesc>0?noDesc+' upcoming events have no description. Ask coordinators to add details for better student awareness.'
               :'All upcoming events have descriptions. Communication is complete!')
    +si(notifMon<5,'🔔',notifMon,'Notifications This Month',
       notifMon<5?'Only '+notifMon+' notifications sent this month. Send reminders about upcoming events to improve participation.'
                :'Good notification activity. Students are being kept informed about events.')
    +si(monWEv<6,'📊',monWEv,'Months with Events (This Year)',
       monWEv<6?'Events are concentrated in '+monWEv+' months. Plan events throughout the year for consistent engagement.'
               :'Events are well-distributed. '+monWEv+' months have scheduled activities.')
    +si(false,'🏆',totalYear,'Events This Year',
       'Total of '+totalYear+' events scheduled this academic year. Monitor event density to avoid student overload during exam periods.')
    +si(false,'🎯',bType,'Most Popular Event Type',
       bType+' events are most frequent. Ensure balance — combine academic events with cultural, sports, and social activities for holistic development.')
    +'</div></div>';
}

/* ════════════════════════════════════════════════════════
   MODAL
════════════════════════════════════════════════════════ */
window.closeModal=function(){G('evModal').style.display='none';};
G('evModal').addEventListener('click',function(e){if(e.target===this) closeModal();});

/* ════════════════════════════════════════════════════════
   CSV EXPORT
════════════════════════════════════════════════════════ */
function doExport(){
  if(!allEventsData||!allEventsData.length){alert('No events to export.');return;}
  var H=['Title','Type','Date','Start Time','Location','Status','Days From Now'];
  var R=allEventsData.map(function(e){
    return[e.Title,e.EventType,e.EventDateStr,e.StartTime,e.Location,e.Status,e.DaysFromNow]
      .map(function(v){return '"'+String(v||'').replace(/"/g,'""')+'"';});
  });
  var csv=[H].concat(R).map(function(r){return r.join(',');}).join('\n');
  var a=document.createElement('a');
  a.href='data:text/csv;charset=utf-8,'+encodeURIComponent(csv);
  a.download='events_'+new Date().toISOString().slice(0,10)+'.csv';
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
