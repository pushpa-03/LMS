<%@ Page Title="Communication & Support Dashboard" Language="C#"
    MasterPageFile="~/Admin/AdminMaster.Master"
    AutoEventWireup="true"
    CodeBehind="CommunicationSupportDashboard.aspx.cs"
    Inherits="LearningManagementSystem.Admin.CommunicationSupportDashboard" %>

<asp:Content ID="cHead" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet"/>
<style>
/* ═══════════════════ TOKENS ═══════════════════ */
:root{
  --p:#6366f1;--pl:#eef2ff;--pd:#4338ca;
  --g:#10b981;--gl:#d1fae5;--gd:#059669;
  --w:#f59e0b;--wl:#fef3c7;--wd:#d97706;
  --r:#ef4444;--rl:#fee2e2;
  --b:#3b82f6;--bl:#dbeafe;
  --t:#0d9488;--tl:#ccfbf1;
  --pu:#8b5cf6;--pul:#f3f0ff;
  --ro:#f43f5e;--rol:#ffe4e6;
  --or:#ea580c;--orl:#ffedd5;
  --cy:#0891b2;--cyl:#cffafe;
  --tx:#0f172a;--ts:#475569;--tm:#94a3b8;
  --bd:#e2e8f0;--bg:#fff;--pg:#f8fafc;
  --rad:16px;--rads:10px;
  --sh:0 1px 3px rgba(0,0,0,.05),0 1px 2px rgba(0,0,0,.03);
  --shm:0 8px 24px rgba(0,0,0,.08);
  --shl:0 20px 48px rgba(0,0,0,.12);
}
*{box-sizing:border-box;margin:0;padding:0;}
body{background:var(--pg);font-family:'Inter','Segoe UI',system-ui,sans-serif;color:var(--tx);}
.wrap{padding:24px;}

/* ═══ BANNER ═══ */
.banner{
  position:relative;border-radius:var(--rad);overflow:hidden;
  margin-bottom:22px;min-height:170px;
  background:linear-gradient(135deg,#0f172a 0%,#1e1b4b 30%,#312e81 60%,#4f46e5 85%,#818cf8 100%);
  box-shadow:var(--shl);
}
.b-mesh{position:absolute;inset:0;z-index:0;overflow:hidden;}
.b-mesh::before{
  content:'';position:absolute;width:600px;height:600px;
  border-radius:50%;background:rgba(99,102,241,.18);
  top:-200px;right:-150px;animation:meshpulse 6s ease-in-out infinite;
}
.b-mesh::after{
  content:'';position:absolute;width:400px;height:400px;
  border-radius:50%;background:rgba(167,139,250,.12);
  bottom:-150px;left:-100px;animation:meshpulse 8s ease-in-out infinite reverse;
}
@keyframes meshpulse{0%,100%{transform:scale(1)}50%{transform:scale(1.1)}}
.b-grid{
  position:absolute;inset:0;z-index:0;
  background-image:linear-gradient(rgba(255,255,255,.03) 1px,transparent 1px),
    linear-gradient(90deg,rgba(255,255,255,.03) 1px,transparent 1px);
  background-size:40px 40px;
}
.b-body{position:relative;z-index:2;display:flex;align-items:center;
  justify-content:space-between;padding:28px 36px;gap:20px;flex-wrap:wrap;}
.b-eyebrow{font-size:10px;font-weight:800;color:rgba(255,255,255,.5);
  text-transform:uppercase;letter-spacing:.14em;margin-bottom:7px;
  display:flex;align-items:center;gap:6px;}
.b-title{font-size:26px;font-weight:900;color:#fff;line-height:1.15;letter-spacing:-.5px;}
.b-sub{font-size:13px;color:rgba(255,255,255,.6);margin-top:5px;}
.b-kpis{display:flex;gap:22px;margin-top:18px;flex-wrap:wrap;}
.bk{text-align:center;}
.bk-v{font-size:22px;font-weight:900;color:#fff;line-height:1;}
.bk-l{font-size:9px;color:rgba(255,255,255,.5);text-transform:uppercase;letter-spacing:.07em;margin-top:3px;}
.bdiv{width:1px;background:rgba(255,255,255,.15);align-self:stretch;}
.live-pill{background:rgba(16,185,129,.18);border:1px solid rgba(16,185,129,.35);
  color:#6ee7b7;padding:5px 14px;border-radius:20px;font-size:11px;font-weight:700;
  display:inline-flex;align-items:center;gap:6px;}
.ldot{width:7px;height:7px;border-radius:50%;background:#10b981;animation:lpulse 1.4s infinite;}
@keyframes lpulse{0%,100%{opacity:1;transform:scale(1)}50%{opacity:.4;transform:scale(.7)}}
.btn-bw{padding:9px 18px;background:rgba(255,255,255,.12);color:#fff;
  border:1px solid rgba(255,255,255,.25);border-radius:var(--rads);
  font-size:12px;font-weight:700;cursor:pointer;transition:.2s;
  display:inline-flex;align-items:center;gap:7px;backdrop-filter:blur(4px);}
.btn-bw:hover{background:rgba(255,255,255,.22);}
.gspin{display:inline-block;width:18px;height:18px;
  border:2px solid rgba(255,255,255,.2);border-top-color:#a5b4fc;
  border-radius:50%;animation:spin .7s linear infinite;}
@keyframes spin{to{transform:rotate(360deg)}}

/* ═══ FILTER BAR ═══ */
.fb{background:var(--bg);border:1px solid var(--bd);border-radius:var(--rad);
  padding:16px 20px;margin-bottom:22px;box-shadow:var(--sh);}
.fb-hd{display:flex;align-items:center;justify-content:space-between;
  margin-bottom:14px;flex-wrap:wrap;gap:8px;}
.fb-lbl{font-size:11px;font-weight:800;color:var(--ts);text-transform:uppercase;
  letter-spacing:.07em;display:flex;align-items:center;gap:7px;}
.fb-acts{display:flex;gap:8px;}
.btn-ap{padding:7px 18px;background:var(--p);color:#fff;border:none;
  border-radius:var(--rads);font-size:12px;font-weight:700;cursor:pointer;
  display:inline-flex;align-items:center;gap:6px;transition:.15s;}
.btn-ap:hover{background:var(--pd);}
.btn-rs{padding:7px 14px;background:var(--pg);color:var(--ts);
  border:1px solid var(--bd);border-radius:var(--rads);
  font-size:12px;font-weight:600;cursor:pointer;}
.btn-rs:hover{background:var(--bd);}
.f-row{display:flex;flex-wrap:wrap;gap:10px;align-items:flex-end;}
.fg{display:flex;flex-direction:column;gap:4px;min-width:120px;flex:1;}
.fg label{font-size:11px;font-weight:600;color:var(--ts);}
.fsel,.fdate{padding:8px 10px;border:1.5px solid var(--bd);border-radius:var(--rads);
  font-size:13px;color:var(--tx);background:#fff;width:100%;transition:.15s;}
.fsel:focus,.fdate:focus{border-color:var(--p);outline:none;
  box-shadow:0 0 0 3px rgba(99,102,241,.1);}
.lbar{height:3px;background:linear-gradient(90deg,var(--p),var(--b),var(--g));
  width:0%;border-radius:2px;transition:width .4s;margin-top:10px;}
.qr-row{display:flex;gap:6px;flex-wrap:wrap;margin-top:10px;}
.qr{padding:4px 12px;border:1px solid var(--bd);border-radius:99px;
  font-size:11px;font-weight:600;cursor:pointer;transition:.15s;
  background:#fff;color:var(--ts);}
.qr:hover,.qr.on{background:var(--p);color:#fff;border-color:var(--p);}
.af-chips{display:flex;flex-wrap:wrap;gap:6px;margin-top:10px;}
.afc{background:var(--pl);color:var(--p);padding:3px 10px;border-radius:99px;
  font-size:11px;font-weight:600;display:inline-flex;align-items:center;gap:5px;cursor:pointer;}
.afc:hover{background:var(--bl);color:var(--b);}

/* ═══ KPI GRID ═══ */
.kpi-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(150px,1fr));
  gap:13px;margin-bottom:22px;}
.kpi{background:var(--bg);border:1px solid var(--bd);border-radius:var(--rad);
  padding:17px 16px;box-shadow:var(--sh);position:relative;overflow:hidden;transition:.2s;}
.kpi:hover{transform:translateY(-3px);box-shadow:var(--shm);}
.kpi::before{content:'';position:absolute;top:0;left:0;right:0;height:3px;
  border-radius:var(--rad) var(--rad) 0 0;}
.kb::before{background:var(--b);}  .kg::before{background:var(--g);}
.kp::before{background:var(--p);}  .kw::before{background:var(--w);}
.kt::before{background:var(--t);}  .kr::before{background:var(--r);}
.kor::before{background:var(--or);}.kpu::before{background:var(--pu);}
.kcy::before{background:var(--cy);}.kro::before{background:var(--ro);}
.kpi-top{display:flex;align-items:center;justify-content:space-between;margin-bottom:10px;}
.klbl{font-size:10px;font-weight:800;color:var(--ts);text-transform:uppercase;letter-spacing:.06em;}
.kico{width:38px;height:38px;border-radius:11px;display:flex;
  align-items:center;justify-content:center;font-size:16px;}
.ib{background:var(--bl);color:var(--b);}  .ig{background:var(--gl);color:var(--g);}
.ip{background:var(--pl);color:var(--p);}  .iw{background:var(--wl);color:var(--w);}
.it{background:var(--tl);color:var(--t);}  .ir{background:var(--rl);color:var(--r);}
.ior{background:var(--orl);color:var(--or);}.ipu{background:var(--pul);color:var(--pu);}
.icy{background:var(--cyl);color:var(--cy);}.iro{background:var(--rol);color:var(--ro);}
.kval{font-size:26px;font-weight:900;color:var(--tx);line-height:1;
  letter-spacing:-.5px;transition:all .4s;}
.ksub{font-size:11px;color:var(--tm);margin-top:4px;}

/* ═══ TABS ═══ */
.tab-bar{display:flex;gap:2px;background:var(--pg);border-radius:12px;
  padding:4px;margin-bottom:20px;flex-wrap:wrap;}
.tab-btn{padding:9px 16px;border:none;background:transparent;border-radius:9px;
  font-size:13px;font-weight:600;color:var(--ts);cursor:pointer;transition:.18s;
  display:flex;align-items:center;gap:6px;white-space:nowrap;outline:none;}
.tab-btn.on{background:var(--bg);color:var(--p);box-shadow:var(--sh);}
.tab-btn:hover:not(.on){background:rgba(255,255,255,.6);}
.tab-pane{display:none;}
.tab-pane.on{display:block;animation:tabIn .22s ease;}
@keyframes tabIn{from{opacity:0;transform:translateY(5px)}to{opacity:1;transform:none}}

/* ═══ CARD ═══ */
.card{background:var(--bg);border:1px solid var(--bd);border-radius:var(--rad);
  box-shadow:var(--sh);padding:22px;transition:box-shadow .2s,transform .2s;}
.card:hover{box-shadow:var(--shm);}
.card-hd{display:flex;align-items:flex-start;justify-content:space-between;
  margin-bottom:18px;gap:8px;flex-wrap:wrap;}
.card-hd-l{display:flex;align-items:center;gap:11px;}
.cico{width:34px;height:34px;border-radius:10px;display:flex;
  align-items:center;justify-content:center;font-size:14px;flex-shrink:0;}
.ct{font-size:14px;font-weight:800;color:var(--tx);}
.cs{font-size:12px;color:var(--ts);margin-top:1px;}
.cb{position:relative;width:100%;}
.g2{display:grid;grid-template-columns:1fr 1fr;gap:16px;margin-bottom:20px;}
.g3{display:grid;grid-template-columns:1fr 1fr 1fr;gap:16px;margin-bottom:20px;}
.g21{display:grid;grid-template-columns:2fr 1fr;gap:16px;margin-bottom:20px;}
.g12{display:grid;grid-template-columns:1fr 2fr;gap:16px;margin-bottom:20px;}
.g13{display:grid;grid-template-columns:1fr 3fr;gap:16px;margin-bottom:20px;}

/* ═══ TABLES ═══ */
.tbl{width:100%;border-collapse:collapse;font-size:13px;}
.tbl th{font-size:10px;font-weight:800;color:var(--ts);text-transform:uppercase;
  letter-spacing:.05em;padding:9px 12px;border-bottom:2px solid var(--bd);
  text-align:left;white-space:nowrap;}
.tbl td{padding:11px 12px;border-bottom:1px solid var(--bd);vertical-align:middle;}
.tbl tr:hover td{background:#f8f9ff;}
.tbl tr:last-child td{border-bottom:none;}
.tbl-wrap{overflow-x:auto;}
.av{width:34px;height:34px;border-radius:50%;display:flex;align-items:center;
  justify-content:center;font-size:12px;font-weight:800;overflow:hidden;
  flex-shrink:0;border:2px solid var(--bd);background:var(--pl);color:var(--p);}
.av img{width:100%;height:100%;object-fit:cover;}
.uname{font-weight:700;color:var(--tx);font-size:13px;}
.usub{font-size:11px;color:var(--tm);}

/* Status pills */
.pill{display:inline-block;padding:3px 10px;border-radius:99px;
  font-size:11px;font-weight:700;}
.pill-open{background:#fef3c7;color:#92400e;}
.pill-res {background:var(--gl);color:#065f46;}
.pill-info{background:var(--bl);color:#1d4ed8;}
.pill-warn{background:var(--rl);color:#991b1b;}
.pill-new {background:var(--pul);color:#5b21b6;}

/* Progress bars */
.pi{margin-bottom:13px;}
.pi-lbl{display:flex;justify-content:space-between;font-size:12px;
  font-weight:600;color:var(--tx);margin-bottom:5px;}
.pi-lbl span:last-child{color:var(--ts);font-weight:500;}
.pi-track{height:8px;background:var(--bd);border-radius:99px;overflow:hidden;}
.pi-fill{height:8px;border-radius:99px;transition:width 1.1s ease;width:0%;}

/* Message feed */
.msg-item{display:flex;align-items:flex-start;gap:10px;padding:11px 0;
  border-bottom:1px solid var(--bd);}
.msg-item:last-child{border:none;}
.msg-body{flex:1;min-width:0;}
.msg-name{font-size:13px;font-weight:700;color:var(--tx);}
.msg-role{font-size:11px;color:var(--ts);margin-bottom:3px;}
.msg-preview{font-size:12px;color:var(--ts);
  white-space:nowrap;overflow:hidden;text-overflow:ellipsis;max-width:300px;}
.msg-time{font-size:10px;color:var(--tm);white-space:nowrap;flex-shrink:0;}

/* Announcement cards */
.ann-card{background:var(--pg);border:1px solid var(--bd);border-radius:var(--rads);
  padding:14px;margin-bottom:10px;transition:.18s;}
.ann-card:hover{border-color:var(--p);box-shadow:0 2px 8px rgba(99,102,241,.1);}
.ann-title{font-size:13px;font-weight:700;color:var(--tx);margin-bottom:4px;}
.ann-content{font-size:12px;color:var(--ts);line-height:1.6;
  display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden;}
.ann-meta{display:flex;align-items:center;gap:10px;margin-top:8px;flex-wrap:wrap;}
.ann-meta span{font-size:11px;color:var(--tm);display:flex;align-items:center;gap:4px;}

/* Stat row inside insight card */
.stat-row{display:flex;align-items:center;justify-content:space-between;
  padding:10px 0;border-bottom:1px solid var(--bd);}
.stat-row:last-child{border:none;}
.stat-lbl{font-size:13px;color:var(--ts);display:flex;align-items:center;gap:8px;}
.stat-val{font-size:16px;font-weight:800;color:var(--tx);}
.stat-val.warn{color:var(--r);}
.stat-val.ok  {color:var(--g);}

/* Rank badges */
.rk{width:22px;height:22px;border-radius:50%;display:flex;align-items:center;
  justify-content:center;font-size:11px;font-weight:800;flex-shrink:0;}
.r1{background:#fef3c7;color:#b45309;}.r2{background:#f3f4f6;color:#374151;}
.r3{background:#fde8d8;color:#c05621;}.rn{background:var(--pg);color:var(--ts);}

/* Engagement ring */
.eng-ring-wrap{display:flex;flex-direction:column;align-items:center;
  justify-content:center;padding:16px 0;}
.eng-ring{position:relative;width:140px;height:140px;}
.eng-ring svg{width:140px;height:140px;transform:rotate(-90deg);}
.ring-bg{fill:none;stroke:var(--bd);stroke-width:12;}
.ring-fg{fill:none;stroke:var(--p);stroke-width:12;stroke-linecap:round;
  stroke-dasharray:340;stroke-dashoffset:340;transition:stroke-dashoffset 1.4s ease;}
.ring-label{position:absolute;inset:0;display:flex;flex-direction:column;
  align-items:center;justify-content:center;text-align:center;}
.ring-pct{font-size:28px;font-weight:900;color:var(--tx);}
.ring-txt{font-size:10px;color:var(--tm);font-weight:600;text-transform:uppercase;}

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

/* Empty / spinner */
.empty{text-align:center;padding:40px;color:var(--tm);}
.empty i{font-size:32px;display:block;margin-bottom:10px;opacity:.35;}
.empty p{font-size:13px;}
.spin{display:inline-block;width:20px;height:20px;border:2px solid var(--bd);
  border-top-color:var(--p);border-radius:50%;animation:spin .7s linear infinite;}

/* Insight panel */
.insight-panel{
  background:linear-gradient(135deg,#0f172a,#1e1b4b,#312e81);
  border-radius:var(--rad);padding:22px;color:#fff;margin-bottom:20px;
  box-shadow:var(--shl);}
.insight-title{font-size:15px;font-weight:800;margin-bottom:16px;
  display:flex;align-items:center;gap:8px;}
.insight-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(190px,1fr));gap:12px;}
.ins{background:rgba(255,255,255,.08);border-radius:11px;padding:14px;
  border:1px solid rgba(255,255,255,.12);transition:.18s;}
.ins:hover{background:rgba(255,255,255,.15);transform:translateY(-2px);}
.ins.warn{background:rgba(239,68,68,.18);border-color:rgba(239,68,68,.35);}
.ins.ok  {background:rgba(16,185,129,.18);border-color:rgba(16,185,129,.35);}
.ins-ico{font-size:22px;margin-bottom:8px;display:block;}
.ins-n{font-size:26px;font-weight:900;margin-bottom:3px;}
.ins-hd{font-size:13px;font-weight:700;margin-bottom:4px;}
.ins-tx{font-size:12px;opacity:.78;line-height:1.55;}

@media(max-width:1100px){.g21,.g12,.g13{grid-template-columns:1fr;}.g3{grid-template-columns:1fr 1fr;}}
@media(max-width:700px) {.g2,.g3{grid-template-columns:1fr;}.kpi-grid{grid-template-columns:1fr 1fr;}}
@media(max-width:480px) {.kpi-grid{grid-template-columns:1fr 1fr;}.tab-btn{font-size:11px;padding:7px 9px;}}
</style>
</asp:Content>

<asp:Content ID="cBody" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

<%-- Hidden server → client fields --%>
<asp:HiddenField ID="hdnInst" runat="server"/>
<asp:HiddenField ID="hdnSess" runat="server"/>
<asp:HiddenField ID="hdnDfr"  runat="server"/>
<asp:HiddenField ID="hdnDto"  runat="server"/>
<asp:Label       ID="lblSess" runat="server" Style="display:none;"/>
<asp:DropDownList ID="aspStream" runat="server" Style="display:none;"/>
<asp:DropDownList ID="aspRole"   runat="server" Style="display:none;"/>

<div class="wrap">

<!-- ══ BANNER ══ -->
<div class="banner">
  <div class="b-mesh"></div>
  <div class="b-grid"></div>
  <div class="b-body">
    <div>
      <div class="b-eyebrow">
        <i class="fa fa-comments"></i>Communication &amp; Support
      </div>
      <div class="b-title">Communication &amp; Support Dashboard</div>
      <div class="b-sub">Session: <span id="bSess">—</span> &nbsp;&bull;&nbsp; Notifications · Help Desk · Announcements · Messages</div>
      <div class="b-kpis">
        <div class="bk"><div class="bk-v" id="bNotif">—</div><div class="bk-l">Notifications</div></div>
        <div class="bdiv"></div>
        <div class="bk"><div class="bk-v" id="bHelp">—</div><div class="bk-l">Help Requests</div></div>
        <div class="bdiv"></div>
        <div class="bk"><div class="bk-v" id="bMsg">—</div><div class="bk-l">Messages</div></div>
        <div class="bdiv"></div>
        <div class="bk"><div class="bk-v" id="bRes">—</div><div class="bk-l">Resolution %</div></div>
        <div class="bdiv"></div>
        <div class="bk"><div class="bk-v" id="bAnn">—</div><div class="bk-l">Announcements</div></div>
      </div>
    </div>
    <div style="display:flex;flex-direction:column;align-items:flex-end;gap:10px;">
      <div class="live-pill"><span class="ldot"></span>Live</div>
      <button type="button" class="btn-bw" id="btnExport">
        <i class="fa fa-file-csv"></i>Export
      </button>
      <div class="gspin" id="gSpin" style="display:none;"></div>
    </div>
  </div>
</div>

<!-- ══ FILTER BAR ══ -->
<div class="fb">
  <div class="fb-hd">
    <div class="fb-lbl"><i class="fa fa-sliders"></i>Filters</div>
    <div class="fb-acts">
      <button type="button" class="btn-rs" id="btnReset"><i class="fa fa-rotate"></i> Reset</button>
      <button type="button" class="btn-ap" id="btnApply"><i class="fa fa-magnifying-glass"></i> Apply</button>
    </div>
  </div>
  <div class="f-row">
    <div class="fg" style="min-width:130px;"><label>From Date</label>
      <input type="date" id="fDfr" class="fdate"/></div>
    <div class="fg" style="min-width:130px;"><label>To Date</label>
      <input type="date" id="fDto" class="fdate"/></div>
  </div>
  <div class="qr-row">
    <button type="button" class="qr" data-days="7">Last 7 Days</button>
    <button type="button" class="qr on" data-days="30">Last 30 Days</button>
    <button type="button" class="qr" data-curmon="1">This Month</button>
    <button type="button" class="qr" data-days="90">Last 3 Months</button>
    <button type="button" class="qr" data-full="1">Full Session</button>
  </div>
  <div class="lbar" id="lbar"></div>
  <div class="af-chips" id="afcWrap"></div>
</div>

<!-- ══ KPI CARDS ══ -->
<div class="kpi-grid">
  <div class="kpi kb"><div class="kpi-top"><span class="klbl">Notifications Sent</span><div class="kico ib"><i class="fa fa-bell"></i></div></div>
    <div class="kval" id="kNotif">—</div><div class="ksub">Total dispatched</div></div>
  <div class="kpi kr"><div class="kpi-top"><span class="klbl">Unread</span><div class="kico ir"><i class="fa fa-bell-slash"></i></div></div>
    <div class="kval" id="kUnread">—</div><div class="ksub">Pending read</div></div>
  <div class="kpi kw"><div class="kpi-top"><span class="klbl">Help Requests</span><div class="kico iw"><i class="fa fa-circle-question"></i></div></div>
    <div class="kval" id="kHelp2">—</div><div class="ksub">Support tickets</div></div>
  <div class="kpi kr"><div class="kpi-top"><span class="klbl">Open Tickets</span><div class="kico ir"><i class="fa fa-ticket"></i></div></div>
    <div class="kval" id="kOpen">—</div><div class="ksub">Awaiting resolution</div></div>
  <div class="kpi kg"><div class="kpi-top"><span class="klbl">Resolution Rate</span><div class="kico ig"><i class="fa fa-circle-check"></i></div></div>
    <div class="kval" id="kResRate">—</div><div class="ksub">% resolved</div></div>
  <div class="kpi kp"><div class="kpi-top"><span class="klbl">Announcements</span><div class="kico ip"><i class="fa fa-bullhorn"></i></div></div>
    <div class="kval" id="kAnn2">—</div><div class="ksub">Published</div></div>
  <div class="kpi kt"><div class="kpi-top"><span class="klbl">Messages</span><div class="kico it"><i class="fa fa-comments"></i></div></div>
    <div class="kval" id="kMsg2">—</div><div class="ksub">Total sent</div></div>
  <div class="kpi kpu"><div class="kpi-top"><span class="klbl">Active Threads</span><div class="kico ipu"><i class="fa fa-comment-dots"></i></div></div>
    <div class="kval" id="kThreads">—</div><div class="ksub">Discussion threads</div></div>
  <div class="kpi kcy"><div class="kpi-top"><span class="klbl">Users Engaged</span><div class="kico icy"><i class="fa fa-users"></i></div></div>
    <div class="kval" id="kEngaged">—</div><div class="ksub">Received notifications</div></div>
  <div class="kpi kro"><div class="kpi-top"><span class="klbl">Total Users</span><div class="kico iro"><i class="fa fa-user-group"></i></div></div>
    <div class="kval" id="kTotalUsers">—</div><div class="ksub">Enrolled students</div></div>
</div>

<!-- ══ TABS ══ -->
<div class="tab-bar" id="tabBar">
  <button type="button" class="tab-btn on" data-tab="overview">
    <i class="fa fa-chart-pie"></i>Overview</button>
  <button type="button" class="tab-btn" data-tab="notifications">
    <i class="fa fa-bell"></i>Notifications</button>
  <button type="button" class="tab-btn" data-tab="helpdesk">
    <i class="fa fa-ticket"></i>Help Desk</button>
  <button type="button" class="tab-btn" data-tab="announcements">
    <i class="fa fa-bullhorn"></i>Announcements</button>
  <button type="button" class="tab-btn" data-tab="messages">
    <i class="fa fa-comments"></i>Messages</button>
  <button type="button" class="tab-btn" data-tab="insights">
    <i class="fa fa-lightbulb"></i>Insights</button>
</div>

<!-- ══ TAB: OVERVIEW ══ -->
<div id="tab-overview" class="tab-pane on">

  <!-- Combined weekly trend + Role distribution -->
  <div class="g21">
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--pl);color:var(--p);"><i class="fa fa-chart-line"></i></div>
          <div><div class="ct">Weekly Communication Trend</div>
            <div class="cs">Notifications · Help Requests · Messages per week</div></div>
        </div>
        <span id="weekLbl" style="font-size:11px;color:var(--tm);"></span>
      </div>
      <div class="cb" style="height:250px;"><canvas id="cWeekly"></canvas></div>
    </div>
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--wl);color:var(--w);"><i class="fa fa-chart-pie"></i></div>
          <div><div class="ct">Role-wise Messages</div></div>
        </div>
      </div>
      <div class="cb" style="height:210px;"><canvas id="cRoleMsg"></canvas></div>
      <div id="roleLeg" style="display:flex;flex-wrap:wrap;gap:6px;justify-content:center;margin-top:10px;"></div>
    </div>
  </div>

  <!-- Notification trend + Help trend -->
  <div class="g2">
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--bl);color:var(--b);"><i class="fa fa-bell"></i></div>
          <div><div class="ct">Notification Activity</div>
            <div class="cs">Sent vs Read per day</div></div>
        </div>
      </div>
      <div class="cb" style="height:220px;"><canvas id="cNotifTrend"></canvas></div>
    </div>
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--wl);color:var(--w);"><i class="fa fa-circle-question"></i></div>
          <div><div class="ct">Help Request Activity</div>
            <div class="cs">Open vs Resolved per day</div></div>
        </div>
      </div>
      <div class="cb" style="height:220px;"><canvas id="cHelpTrend"></canvas></div>
    </div>
  </div>

  <!-- Stream reach + Hourly pattern -->
  <div class="g2">
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--gl);color:var(--g);"><i class="fa fa-layer-group"></i></div>
          <div><div class="ct">Stream Notification Reach</div>
            <div class="cs">Students reached per stream</div></div>
        </div>
      </div>
      <div id="streamReachBars"></div>
    </div>
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--tl);color:var(--t);"><i class="fa fa-clock"></i></div>
          <div><div class="ct">Peak Communication Hours</div>
            <div class="cs">Messages by hour of day</div></div>
        </div>
      </div>
      <div class="cb" style="height:230px;"><canvas id="cHourly"></canvas></div>
    </div>
  </div>

  <!-- Engagement ring + Notification types -->
  <div class="g12">
    <div class="card" style="display:flex;flex-direction:column;align-items:center;justify-content:center;">
      <div class="card-hd" style="width:100%;">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--pl);color:var(--p);"><i class="fa fa-chart-pie"></i></div>
          <div><div class="ct">Notification Reach</div>
            <div class="cs">Students engaged (30d)</div></div>
        </div>
      </div>
      <div class="eng-ring-wrap">
        <div class="eng-ring">
          <svg viewBox="0 0 140 140">
            <circle class="ring-bg" cx="70" cy="70" r="54"/>
            <circle class="ring-fg" id="ringFg" cx="70" cy="70" r="54"/>
          </svg>
          <div class="ring-label">
            <div class="ring-pct" id="ringPct">—%</div>
            <div class="ring-txt">Engaged</div>
          </div>
        </div>
        <div style="text-align:center;margin-top:12px;">
          <div style="font-size:20px;font-weight:900;color:var(--tx);" id="engNum">—</div>
          <div style="font-size:12px;color:var(--ts);">of <span id="totalUsersNum">—</span> students</div>
        </div>
      </div>
    </div>
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--pul);color:var(--pu);"><i class="fa fa-tag"></i></div>
          <div><div class="ct">Notification Types</div>
            <div class="cs">Breakdown by category</div></div>
        </div>
      </div>
      <div class="cb" style="height:260px;"><canvas id="cNotifTypes"></canvas></div>
    </div>
  </div>

</div>

<!-- ══ TAB: NOTIFICATIONS ══ -->
<div id="tab-notifications" class="tab-pane">
  <div class="g21">
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--bl);color:var(--b);"><i class="fa fa-chart-area"></i></div>
          <div><div class="ct">Notification Delivery Timeline</div>
            <div class="cs">Sent · Read · Unread over time</div></div>
        </div>
      </div>
      <div class="cb" style="height:270px;"><canvas id="cNotifDetail"></canvas></div>
    </div>
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--gl);color:var(--g);"><i class="fa fa-layer-group"></i></div>
          <div><div class="ct">Stream Reach Breakdown</div></div>
        </div>
      </div>
      <div class="cb" style="height:270px;"><canvas id="cStreamReach"></canvas></div>
    </div>
  </div>
  <div class="card">
    <div class="card-hd">
      <div class="card-hd-l">
        <div class="cico" style="background:var(--pul);color:var(--pu);"><i class="fa fa-tag"></i></div>
        <div><div class="ct">Notification Type Performance</div>
          <div class="cs">Read rates by category</div></div>
      </div>
    </div>
    <div id="notifTypeBars"></div>
  </div>
</div>

<!-- ══ TAB: HELP DESK ══ -->
<div id="tab-helpdesk" class="tab-pane">
  <div class="g3" style="margin-bottom:18px;">
    <div class="card" style="text-align:center;padding:20px;">
      <div style="font-size:11px;font-weight:800;color:var(--ts);text-transform:uppercase;letter-spacing:.07em;margin-bottom:8px;">Open Tickets</div>
      <div style="font-size:36px;font-weight:900;color:var(--r);" id="hdOpen">—</div>
      <div style="font-size:12px;color:var(--tm);margin-top:4px;">Awaiting resolution</div>
    </div>
    <div class="card" style="text-align:center;padding:20px;">
      <div style="font-size:11px;font-weight:800;color:var(--ts);text-transform:uppercase;letter-spacing:.07em;margin-bottom:8px;">Resolution Rate</div>
      <div style="font-size:36px;font-weight:900;color:var(--g);" id="hdResRate">—</div>
      <div style="font-size:12px;color:var(--tm);margin-top:4px;">Percentage resolved</div>
    </div>
    <div class="card" style="text-align:center;padding:20px;">
      <div style="font-size:11px;font-weight:800;color:var(--ts);text-transform:uppercase;letter-spacing:.07em;margin-bottom:8px;">Unresponded >24h</div>
      <div style="font-size:36px;font-weight:900;color:var(--w);" id="hdOver24">—</div>
      <div style="font-size:12px;color:var(--tm);margin-top:4px;">Need immediate action</div>
    </div>
  </div>
  <div class="g21">
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--wl);color:var(--w);"><i class="fa fa-chart-bar"></i></div>
          <div><div class="ct">Help Request Trend</div>
            <div class="cs">Open vs Resolved over time</div></div>
        </div>
      </div>
      <div class="cb" style="height:230px;"><canvas id="cHelpDetail"></canvas></div>
    </div>
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--tl);color:var(--t);"><i class="fa fa-clock"></i></div>
          <div><div class="ct">Today's Activity</div></div>
        </div>
      </div>
      <div id="todayStats" style="padding-top:6px;"></div>
    </div>
  </div>
  <div class="card">
    <div class="card-hd">
      <div class="card-hd-l">
        <div class="cico" style="background:var(--rl);color:var(--r);"><i class="fa fa-ticket"></i></div>
        <div><div class="ct">Help Requests</div>
          <div class="cs" id="helpCount">Loading…</div></div>
      </div>
    </div>
    <div class="tbl-wrap">
      <table class="tbl">
        <thead><tr>
          <th>#</th><th>Student</th><th>Question</th>
          <th>Asked</th><th>Hours Open</th><th>Status</th><th>Resolved By</th>
        </tr></thead>
        <tbody id="helpTbody">
          <tr><td colspan="7"><div class="empty"><div class="spin"></div></div></td></tr>
        </tbody>
      </table>
    </div>
    <div class="pag">
      <div class="pag-info" id="helpPagInfo"></div>
      <div class="pag-btns" id="helpPagBtns"></div>
    </div>
  </div>
</div>

<!-- ══ TAB: ANNOUNCEMENTS ══ -->
<div id="tab-announcements" class="tab-pane">
  <div class="g21">
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--pl);color:var(--p);"><i class="fa fa-bullhorn"></i></div>
          <div><div class="ct">Recent Announcements</div>
            <div class="cs" id="annCount">Loading…</div></div>
        </div>
      </div>
      <div id="annList"><div class="empty"><div class="spin"></div></div></div>
    </div>
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--gl);color:var(--g);"><i class="fa fa-chart-pie"></i></div>
          <div><div class="ct">Notification Delivery</div>
            <div class="cs">Read vs Unread split</div></div>
        </div>
      </div>
      <div class="cb" style="height:220px;"><canvas id="cReadUnread"></canvas></div>
      <div id="readUnreadLeg" style="display:flex;gap:14px;justify-content:center;margin-top:10px;flex-wrap:wrap;"></div>
    </div>
  </div>
</div>

<!-- ══ TAB: MESSAGES ══ -->
<div id="tab-messages" class="tab-pane">
  <div class="g21">
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--tl);color:var(--t);"><i class="fa fa-comments"></i></div>
          <div><div class="ct">Recent Messages</div>
            <div class="cs">Latest platform communications</div></div>
        </div>
        <button type="button" class="btn-ap" id="btnRefresh"
                style="font-size:11px;padding:5px 12px;">
          <i class="fa fa-rotate"></i> Refresh
        </button>
      </div>
      <div id="msgFeed"><div class="empty"><div class="spin"></div></div></div>
    </div>
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--wl);color:var(--w);"><i class="fa fa-medal"></i></div>
          <div><div class="ct">Top Communicators</div>
            <div class="cs">Most active message senders</div></div>
        </div>
      </div>
      <div id="topCommList"><div class="empty"><div class="spin"></div></div></div>
    </div>
  </div>
  <div class="card">
    <div class="card-hd">
      <div class="card-hd-l">
        <div class="cico" style="background:var(--bl);color:var(--b);"><i class="fa fa-chart-line"></i></div>
        <div><div class="ct">Message Activity Trend</div>
          <div class="cs">Daily messages sent</div></div>
      </div>
    </div>
    <div class="cb" style="height:210px;"><canvas id="cMsgTrend"></canvas></div>
  </div>
</div>

<!-- ══ TAB: INSIGHTS ══ -->
<div id="tab-insights" class="tab-pane">
  <div id="insightPanel"></div>
  <div class="card">
    <div class="card-hd">
      <div class="card-hd-l">
        <div class="cico" style="background:var(--pl);color:var(--p);"><i class="fa fa-graduation-cap"></i></div>
        <div><div class="ct">Communication Health Guide</div>
          <div class="cs">How to interpret and improve platform communication</div></div>
      </div>
    </div>
    <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(230px,1fr));gap:14px;">
      <div style="background:var(--bl);border-radius:var(--rads);padding:14px;">
        <div style="font-weight:800;color:var(--b);margin-bottom:7px;font-size:13px;">
          <i class="fa fa-bell" style="margin-right:6px;"></i>Low Read Rates
        </div>
        <p style="font-size:12px;line-height:1.75;color:var(--ts);">If notification read rates are below 60%, review notification timing. Peak engagement hours from the Hourly Pattern chart reveal the best time to send critical updates.</p>
      </div>
      <div style="background:var(--wl);border-radius:var(--rads);padding:14px;">
        <div style="font-weight:800;color:var(--wd);margin-bottom:7px;font-size:13px;">
          <i class="fa fa-ticket" style="margin-right:6px;"></i>Help Desk Backlog
        </div>
        <p style="font-size:12px;line-height:1.75;color:var(--ts);">Tickets open beyond 24 hours damage student trust. Assign dedicated support staff per stream and set response SLAs. Automate acknowledgement messages immediately on submission.</p>
      </div>
      <div style="background:var(--gl);border-radius:var(--rads);padding:14px;">
        <div style="font-weight:800;color:var(--gd);margin-bottom:7px;font-size:13px;">
          <i class="fa fa-bullhorn" style="margin-right:6px;"></i>Announcement Strategy
        </div>
        <p style="font-size:12px;line-height:1.75;color:var(--ts);">Post announcements 2-3 days before deadlines. Cross-post via notifications to unread users. Use stream-specific announcements to improve relevance and engagement rates.</p>
      </div>
      <div style="background:var(--pul);border-radius:var(--rads);padding:14px;">
        <div style="font-weight:800;color:var(--pu);margin-bottom:7px;font-size:13px;">
          <i class="fa fa-comments" style="margin-right:6px;"></i>Message Engagement
        </div>
        <p style="font-size:12px;line-height:1.75;color:var(--ts);">Low message counts from teachers indicate poor adoption. Gamify teacher participation with activity badges. Highlight top communicators in faculty meetings to drive peer motivation.</p>
      </div>
      <div style="background:var(--rol);border-radius:var(--rads);padding:14px;">
        <div style="font-weight:800;color:var(--ro);margin-bottom:7px;font-size:13px;">
          <i class="fa fa-layer-group" style="margin-right:6px;"></i>Stream Coverage Gaps
        </div>
        <p style="font-size:12px;line-height:1.75;color:var(--ts);">Streams with &lt;50% notification reach suggest connectivity issues or disengagement. Verify that all students in those streams have verified email/phone numbers linked to their accounts.</p>
      </div>
      <div style="background:var(--tl);border-radius:var(--rads);padding:14px;">
        <div style="font-weight:800;color:var(--t);margin-bottom:7px;font-size:13px;">
          <i class="fa fa-chart-line" style="margin-right:6px;"></i>Weekly Patterns
        </div>
        <p style="font-size:12px;line-height:1.75;color:var(--ts);">Communication spikes before exams or submission deadlines are normal and healthy. Flat communication weeks signal content drought — schedule regular teacher-student interactions to maintain momentum.</p>
      </div>
    </div>
  </div>
</div>

</div><%-- /wrap --%>

<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.4.1/chart.umd.min.js"></script>
<script>
/* ════════════════════════════════════════════════════════════════
   COMMUNICATION & SUPPORT DASHBOARD
   ── All buttons type="button" — zero postbacks
   ── Pure fetch() AJAX — no page reload ever
   ── Tabs: delegated listener on #tabBar, class "on" only
   ── Quick-range pills: data-attributes + addEventListener
   ── Date inputs: addEventListener('change')
   ── NO inline onclick / onchange anywhere
════════════════════════════════════════════════════════════════ */
(function(){
'use strict';

/* ── Server config ── */
function hv(id){var e=document.getElementById(id);return e?(e.value||''):'';};
var INST  = hv('<%= hdnInst.ClientID %>');
var SESS  = hv('<%= hdnSess.ClientID %>');
var SNAME = (document.getElementById('<%= lblSess.ClientID %>')||{}).innerText||'';
var DEF_FR= hv('<%= hdnDfr.ClientID %>');
var DEF_TO= hv('<%= hdnDto.ClientID %>');
document.getElementById('bSess').innerText = SNAME;

/* ── Chart palette ── */
var PAL=['#6366f1','#10b981','#f59e0b','#ef4444','#8b5cf6','#3b82f6',
         '#0d9488','#f43f5e','#0891b2','#ea580c','#84cc16','#ec4899'];
var GRD={color:'rgba(148,163,184,.1)'};
var TICK={font:{size:11,family:"'Inter','Segoe UI',sans-serif"}};
var TT={padding:10,cornerRadius:9,bodyFont:{size:12},titleFont:{size:12,weight:'bold'}};
var ANIM={duration:900,easing:'easeInOutQuart'};
function palA(a){return PAL.map(function(c){return c+Math.round(a*255).toString(16).padStart(2,'0');});}

var charts={}, debT=null, lastData=null, helpPage=0;

function G(id){return document.getElementById(id);}
function fmt(d){return d.toISOString().split('T')[0];}

/* ── Init date fields ── */
G('fDfr').value = DEF_FR;
G('fDto').value = DEF_TO;
document.querySelectorAll('.qr[data-days="30"]').forEach(function(b){b.classList.add('on');});

/* ════════════════════════════════════════════════════
   STEP 1: Wire ALL buttons with addEventListener
   NO onclick / onchange inline — prevents postbacks
════════════════════════════════════════════════════ */
G('btnApply').addEventListener('click',function(e){e.preventDefault();go();});
G('btnReset').addEventListener('click',function(e){e.preventDefault();resetF();});
G('btnExport').addEventListener('click',function(e){e.preventDefault();doExport();});
G('btnRefresh').addEventListener('click',function(e){e.preventDefault();go();});

G('fDfr').addEventListener('change',function(){clearPills();go();});
G('fDto').addEventListener('change',function(){clearPills();go();});

document.querySelectorAll('.qr').forEach(function(btn){
  btn.addEventListener('click',function(e){
    e.preventDefault();
    clearPills();this.classList.add('on');
    var days=this.dataset.days, cm=this.dataset.curmon, full=this.dataset.full;
    var to=new Date(), fr=new Date();
    if(full){G('fDfr').value='';G('fDto').value='';}
    else if(cm){
      G('fDfr').value=fmt(new Date(to.getFullYear(),to.getMonth(),1));
      G('fDto').value=fmt(to);
    }else{
      fr.setDate(to.getDate()-parseInt(days)+1);
      G('fDfr').value=fmt(fr);G('fDto').value=fmt(to);
    }
    go();
  });
});

/* Tab bar — single delegated listener */
G('tabBar').addEventListener('click',function(e){
  var btn=e.target.closest('.tab-btn');if(!btn)return;
  e.preventDefault();e.stopPropagation();
  var name=btn.dataset.tab;if(!name)return;
  document.querySelectorAll('.tab-btn').forEach(function(b){b.classList.remove('on');});
  document.querySelectorAll('.tab-pane').forEach(function(p){p.classList.remove('on');});
  btn.classList.add('on');
  var pane=G('tab-'+name);if(pane)pane.classList.add('on');
});

/* ════════════════════════════════════════════════════
   FILTER HELPERS
════════════════════════════════════════════════════ */
function clearPills(){document.querySelectorAll('.qr').forEach(function(b){b.classList.remove('on');});}

function getF(){
  return{datefrom:G('fDfr').value||'', dateto:G('fDto').value||''};
}

function buildURL(extra){
  var f=getF();
  var u=location.pathname
    +'?ajax=1&inst='+encodeURIComponent(INST)+'&sess='+encodeURIComponent(SESS)
    +'&datefrom='+f.datefrom+'&dateto='+f.dateto;
  if(extra)Object.keys(extra).forEach(function(k){u+='&'+k+'='+encodeURIComponent(extra[k]);});
  return u;
}

function resetF(){
  G('fDfr').value=DEF_FR;G('fDto').value=DEF_TO;
  G('afcWrap').innerHTML='';clearPills();
  document.querySelectorAll('.qr[data-days="30"]').forEach(function(b){b.classList.add('on');});
  go();
}

function updateChips(){
  var f=getF(),wrap=G('afcWrap');wrap.innerHTML='';
  if(f.datefrom||f.dateto){
    var c=document.createElement('span');c.className='afc';
    c.innerText=(f.datefrom||'Start')+' → '+(f.dateto||'Now');
    wrap.appendChild(c);
  }
}

/* ════════════════════════════════════════════════════
   MAIN FETCH
════════════════════════════════════════════════════ */
function go(){
  clearTimeout(debT);
  debT=setTimeout(fetchData,280);
}

function fetchData(){
  setLoad(true);updateChips();
  fetch(buildURL())
    .then(function(r){
      if(!r.ok) throw new Error('HTTP '+r.status+' '+r.statusText);
      return r.json();
    })
    .then(function(d){
      lastData=d;
      renderKPIs(d.kpi);
      renderAllCharts(d);
      renderHelpTable(d,0);
      renderAnnouncements(d.announcements,d.annTotal);
      renderMessages(d.recentMessages);
      renderTopComm(d.topComm);
      renderTodayStats(d.adminStats);
      renderInsightPanel(d.adminStats,d.kpi);
      setLoad(false);
    })
    .catch(function(err){
      setLoad(false);
      console.error('[CommSupport]',err);
    });
}

function setLoad(on){
  var bar=G('lbar'), sp=G('gSpin');
  bar.style.width=on?'82%':'100%';
  sp.style.display=on?'inline-block':'none';
  if(!on)setTimeout(function(){bar.style.width='0%';},600);
}

/* ════════════════════════════════════════════════════
   KPIs
════════════════════════════════════════════════════ */
function renderKPIs(k){
  if(!k)return;
  cu('kNotif',     k.totalNotifications);
  cu('kUnread',    k.unreadNotifications);
  cu('kHelp2',     k.totalHelpRequests);
  cu('kOpen',      k.openHelpRequests);
  cu('kAnn2',      k.totalAnnouncements);
  cu('kMsg2',      k.totalMessages);
  cu('kThreads',   k.activeThreads);
  cu('kEngaged',   k.engagedUsers);
  cu('kTotalUsers',k.totalUsers);
  G('kResRate').innerText = (parseFloat(k.resolutionRate)||0).toFixed(1)+'%';

  /* Banner */
  G('bNotif').innerText  = k.totalNotifications||0;
  G('bHelp').innerText   = k.totalHelpRequests||0;
  G('bMsg').innerText    = k.totalMessages||0;
  G('bRes').innerText    = (parseFloat(k.resolutionRate)||0).toFixed(0)+'%';
  G('bAnn').innerText    = k.totalAnnouncements||0;

  /* Help desk summary tab */
  var hdO=G('hdOpen'),hdR=G('hdResRate'),hdOv=G('hdOver24');
  if(hdO)hdO.innerText=k.openHelpRequests||0;
  if(hdR)hdR.innerText=(parseFloat(k.resolutionRate)||0).toFixed(1)+'%';

  /* Engagement ring */
  var total=parseInt(k.totalUsers)||1;
  var eng=parseInt(k.engagedUsers)||0;
  var pct=Math.round(eng/total*100);
  var el=G('ringFg');
  if(el){
    var circum=2*Math.PI*54;
    setTimeout(function(){
      el.style.strokeDashoffset=circum-(circum*pct/100);
    },300);
  }
  var rp=G('ringPct');if(rp)rp.innerText=pct+'%';
  var en=G('engNum');if(en)en.innerText=eng;
  var tu=G('totalUsersNum');if(tu)tu.innerText=total;
}

function cu(id,n){
  var el=G(id);if(!el)return;
  var t=parseInt(n)||0,s=parseInt(el.innerText)||0,diff=t-s,steps=28,i=0;
  var iv=setInterval(function(){
    i++;el.innerText=Math.round(s+diff*(i/steps));
    if(i>=steps){el.innerText=t;clearInterval(iv);}
  },16);
}

/* ════════════════════════════════════════════════════
   CHART HELPERS
════════════════════════════════════════════════════ */
function dc(k){if(charts[k]){charts[k].destroy();charts[k]=null;}}
function gV(ctx,h,c1,c2){var g=ctx.createLinearGradient(0,0,0,h);g.addColorStop(0,c1);g.addColorStop(1,c2);return g;}
function noData(id,msg){
  var el=G(id);if(!el)return;
  var box=el.closest('.cb');
  if(box)box.innerHTML='<div class="empty"><i class="fa fa-chart-simple"></i><p>'+(msg||'No data')+'</p></div>';
}

function renderAllCharts(d){
  renderWeekly(d.weeklyTrend);
  renderRoleMsg(d.roleComm);
  renderNotifTrend(d.notifTrend,'cNotifTrend');
  renderNotifTrend(d.notifTrend,'cNotifDetail');
  renderHelpTrend(d.helpTrend,'cHelpTrend');
  renderHelpTrend(d.helpTrend,'cHelpDetail');
  renderStreamReachChart(d.streamReach);
  renderStreamReachBars(d.streamReach);
  renderHourlyPattern(d.hourlyPattern);
  renderNotifTypes(d.notifTypes);
  renderNotifTypeBars(d.notifTypes);
  renderReadUnread(d.kpi);
  renderMsgTrend(d.msgTrend);
}

/* 1. Weekly combined trend */
function renderWeekly(data){
  dc('weekly');
  if(!data||!data.length){noData('cWeekly','No data');return;}
  var el=G('cWeekly');if(!el)return;
  var lbl=G('weekLbl');
  var totN=data.reduce(function(a,r){return a+(r.Notifications||0);},0);
  if(lbl)lbl.innerText=totN+' notifications this period';
  charts.weekly=new Chart(el,{type:'bar',data:{
    labels:data.map(function(r){return r.WLabel;}),
    datasets:[
      {label:'Notifications',data:data.map(function(r){return r.Notifications||0;}),
       backgroundColor:'rgba(99,102,241,.85)',borderRadius:5,stack:''},
      {label:'Help Requests',data:data.map(function(r){return r.HelpRequests||0;}),
       backgroundColor:'rgba(245,158,11,.85)',borderRadius:5,stack:''},
      {label:'Messages',data:data.map(function(r){return r.Messages||0;}),
       backgroundColor:'rgba(16,185,129,.85)',borderRadius:5,stack:''}
    ]
  },options:{responsive:true,maintainAspectRatio:false,
    interaction:{mode:'index',intersect:false},
    plugins:{legend:{position:'top',labels:{boxWidth:10,font:{size:11}}},tooltip:TT},
    scales:{x:{grid:{display:false},ticks:TICK},y:{beginAtZero:true,grid:GRD,ticks:TICK}},
    animation:ANIM}});
}

/* 2. Role-wise messages donut */
function renderRoleMsg(data){
  dc('roleMsg');
  var leg=G('roleLeg');if(leg)leg.innerHTML='';
  if(!data||!data.length){noData('cRoleMsg','No data');return;}
  var el=G('cRoleMsg');if(!el)return;
  charts.roleMsg=new Chart(el,{type:'doughnut',data:{
    labels:data.map(function(r){return r.RoleName;}),
    datasets:[{data:data.map(function(r){return r.Messages||0;}),
      backgroundColor:palA(.85),borderWidth:2,borderColor:'#fff',hoverOffset:10}]
  },options:{cutout:'60%',responsive:true,maintainAspectRatio:false,
    plugins:{legend:{display:false},tooltip:TT},
    animation:{animateRotate:true,duration:1100}}});
  if(leg){
    var tot=data.reduce(function(a,r){return a+(r.Messages||0);},0)||1;
    data.forEach(function(r,i){
      leg.innerHTML+='<div style="display:flex;align-items:center;gap:5px;font-size:11px;">'
        +'<span style="width:10px;height:10px;border-radius:2px;background:'+PAL[i%PAL.length]+';display:inline-block;flex-shrink:0;"></span>'
        +esc(r.RoleName)+' <strong style="color:'+PAL[i%PAL.length]+';">'+Math.round((r.Messages||0)/tot*100)+'%</strong></div>';
    });
  }
}

/* 3. Notification trend line (reusable) */
function renderNotifTrend(data,cid){
  var key='nt_'+cid;dc(key);
  if(!data||!data.length){noData(cid,'No notification data');return;}
  var el=G(cid);if(!el)return;
  var ctx=el.getContext('2d');
  var grad=gV(ctx,220,'rgba(99,102,241,.22)','rgba(99,102,241,.01)');
  charts[key]=new Chart(el,{type:'line',data:{
    labels:data.map(function(r){return r.DateStr;}),
    datasets:[
      {label:'Sent',data:data.map(function(r){return r.Total||0;}),
       borderColor:'#6366f1',backgroundColor:grad,borderWidth:2.5,tension:.4,fill:true,pointRadius:0,pointHoverRadius:6},
      {label:'Read',data:data.map(function(r){return r.ReadCount||0;}),
       borderColor:'#10b981',borderWidth:2,borderDash:[4,4],tension:.4,fill:false,pointRadius:0,pointHoverRadius:5},
      {label:'Unread',data:data.map(function(r){return r.UnreadCount||0;}),
       borderColor:'#ef4444',borderWidth:2,borderDash:[4,4],tension:.4,fill:false,pointRadius:0,pointHoverRadius:5}
    ]
  },options:{responsive:true,maintainAspectRatio:false,
    interaction:{mode:'index',intersect:false},
    plugins:{legend:{position:'top',labels:{boxWidth:10,font:{size:11}}},tooltip:TT},
    scales:{x:{grid:{display:false},ticks:{font:{size:10},maxTicksLimit:12}},
      y:{beginAtZero:true,grid:GRD,ticks:TICK}},animation:ANIM}});
}

/* 4. Help request trend */
function renderHelpTrend(data,cid){
  var key='ht_'+cid;dc(key);
  if(!data||!data.length){noData(cid,'No help request data');return;}
  var el=G(cid);if(!el)return;
  charts[key]=new Chart(el,{type:'bar',data:{
    labels:data.map(function(r){return r.DateStr;}),
    datasets:[
      {label:'Open',    data:data.map(function(r){return r.Open||0;}),
       backgroundColor:'rgba(245,158,11,.82)',borderRadius:4,stack:'s'},
      {label:'Resolved',data:data.map(function(r){return r.Resolved||0;}),
       backgroundColor:'rgba(16,185,129,.82)',borderRadius:4,stack:'s'}
    ]
  },options:{responsive:true,maintainAspectRatio:false,
    interaction:{mode:'index',intersect:false},
    plugins:{legend:{position:'top',labels:{boxWidth:10,font:{size:11}}},tooltip:TT},
    scales:{x:{grid:{display:false},ticks:{font:{size:10},maxTicksLimit:12},stacked:true},
      y:{beginAtZero:true,grid:GRD,ticks:TICK,stacked:true}},animation:ANIM}});
}

/* 5. Stream reach chart */
function renderStreamReachChart(data){
  dc('streamReach');
  if(!data||!data.length){noData('cStreamReach','No stream data');return;}
  var el=G('cStreamReach');if(!el)return;
  charts.streamReach=new Chart(el,{type:'bar',data:{
    labels:data.map(function(r){return r.StreamName;}),
    datasets:[
      {label:'Total Students',data:data.map(function(r){return r.TotalStudents||0;}),
       backgroundColor:palA(.45),borderRadius:5},
      {label:'Reached',data:data.map(function(r){return r.Reached||0;}),
       backgroundColor:palA(.85),borderRadius:5}
    ]
  },options:{responsive:true,maintainAspectRatio:false,
    plugins:{legend:{position:'top',labels:{boxWidth:10,font:{size:11}}},tooltip:TT},
    scales:{x:{grid:{display:false},ticks:{font:{size:11}}},
      y:{beginAtZero:true,grid:GRD,ticks:TICK}},animation:ANIM}});
}

/* 6. Stream reach progress bars */
function renderStreamReachBars(data){
  var wrap=G('streamReachBars');if(!wrap)return;
  wrap.innerHTML='';
  if(!data||!data.length){wrap.innerHTML='<div class="empty"><i class="fa fa-layer-group"></i><p>No stream data</p></div>';return;}
  data.forEach(function(r,i){
    var pct=parseFloat(r.ReachRate)||0;
    var col=pct>=80?'var(--g)':pct>=50?'var(--p)':'var(--r)';
    wrap.innerHTML+='<div class="pi">'
      +'<div class="pi-lbl"><span>'+esc(r.StreamName)+'</span>'
        +'<span>'+esc(r.Reached)+'/'+esc(r.TotalStudents)+' ('+pct+'%)</span></div>'
      +'<div class="pi-track"><div class="pi-fill" data-w="'+pct+'%" style="background:'+col+';"></div></div>'
    +'</div>';
  });
  setTimeout(function(){wrap.querySelectorAll('.pi-fill[data-w]').forEach(function(el){el.style.width=el.dataset.w;});},300);
}

/* 7. Hourly pattern */
function renderHourlyPattern(data){
  dc('hourly');
  if(!data||!data.length){noData('cHourly','No hourly data');return;}
  var el=G('cHourly');if(!el)return;
  var hrs=[],vals=[];
  for(var h=0;h<24;h++){hrs.push(h+':00');vals.push(0);}
  data.forEach(function(r){var hr=parseInt(r.Hr)||0;if(hr>=0&&hr<24)vals[hr]=r.Messages||0;});
  var maxV=Math.max.apply(null,vals)||1;
  charts.hourly=new Chart(el,{type:'bar',data:{labels:hrs,datasets:[{label:'Messages',data:vals,
    backgroundColor:vals.map(function(v){return 'rgba(99,102,241,'+Math.max(.15,v/maxV).toFixed(2)+')'}),
    borderRadius:4}]
  },options:{responsive:true,maintainAspectRatio:false,
    plugins:{legend:{display:false},tooltip:TT},
    scales:{x:{grid:{display:false},ticks:{font:{size:9},maxTicksLimit:12}},
      y:{beginAtZero:true,grid:GRD,ticks:TICK}},animation:ANIM}});
}

/* 8. Notification types polar */
function renderNotifTypes(data){
  dc('notifTypes');
  if(!data||!data.length){noData('cNotifTypes','No type data');return;}
  var el=G('cNotifTypes');if(!el)return;
  charts.notifTypes=new Chart(el,{type:'polarArea',data:{
    labels:data.map(function(r){return r.NotifType;}),
    datasets:[{data:data.map(function(r){return r.Total||0;}),
      backgroundColor:palA(.72),borderColor:'#fff',borderWidth:2}]
  },options:{responsive:true,maintainAspectRatio:false,
    plugins:{legend:{position:'right',labels:{boxWidth:10,font:{size:10}}},tooltip:TT},
    scales:{r:{beginAtZero:true,ticks:{font:{size:9}},grid:{color:'rgba(148,163,184,.2)'}}},
    animation:{duration:1100,easing:'easeInOutBack'}}});
}

/* 9. Notification type read rate progress bars */
function renderNotifTypeBars(data){
  var wrap=G('notifTypeBars');if(!wrap)return;
  wrap.innerHTML='';
  if(!data||!data.length){wrap.innerHTML='<div class="empty"><i class="fa fa-tag"></i><p>No type data</p></div>';return;}
  data.forEach(function(r,i){
    var pct=parseFloat(r.ReadRate)||0;
    var col=pct>=80?'var(--g)':pct>=50?'var(--b)':'var(--r)';
    wrap.innerHTML+='<div class="pi">'
      +'<div class="pi-lbl"><span style="font-weight:700;">'+esc(r.NotifType)+'</span>'
        +'<span>'+esc(r.Total)+' sent &bull; '+pct+'% read</span></div>'
      +'<div class="pi-track"><div class="pi-fill" data-w="'+pct+'%" style="background:'+col+';"></div></div>'
    +'</div>';
  });
  setTimeout(function(){wrap.querySelectorAll('.pi-fill[data-w]').forEach(function(el){el.style.width=el.dataset.w;});},300);
}

/* 10. Read vs Unread donut */
function renderReadUnread(k){
  dc('readUnread');
  var leg=G('readUnreadLeg');if(leg)leg.innerHTML='';
  if(!k){noData('cReadUnread','No data');return;}
  var el=G('cReadUnread');if(!el)return;
  var read=parseInt(k.totalNotifications)-parseInt(k.unreadNotifications);
  var unread=parseInt(k.unreadNotifications)||0;
  charts.readUnread=new Chart(el,{type:'doughnut',data:{
    labels:['Read','Unread'],
    datasets:[{data:[Math.max(0,read),unread],
      backgroundColor:['#10b981','#ef4444'],borderWidth:3,borderColor:'#fff',hoverOffset:8}]
  },options:{cutout:'65%',responsive:true,maintainAspectRatio:false,
    plugins:{legend:{display:false},tooltip:TT},
    animation:{animateRotate:true,duration:1100}}});
  if(leg){
    var tot=(parseInt(k.totalNotifications)||1);
    leg.innerHTML='<div style="display:flex;align-items:center;gap:6px;font-size:12px;">'
      +'<span style="width:12px;height:12px;border-radius:2px;background:#10b981;display:inline-block;"></span>'
      +'Read <strong style="color:#10b981;">'+Math.max(0,read)+' ('+Math.round(Math.max(0,read)/tot*100)+'%)</strong></div>'
      +'<div style="display:flex;align-items:center;gap:6px;font-size:12px;">'
      +'<span style="width:12px;height:12px;border-radius:2px;background:#ef4444;display:inline-block;"></span>'
      +'Unread <strong style="color:#ef4444;">'+unread+' ('+Math.round(unread/tot*100)+'%)</strong></div>';
  }
}

/* 11. Message trend */
function renderMsgTrend(data){
  dc('msgTrend');
  if(!data||!data.length){noData('cMsgTrend','No message data');return;}
  var el=G('cMsgTrend');if(!el)return;
  var ctx=el.getContext('2d');
  var grad=gV(ctx,200,'rgba(13,148,136,.22)','rgba(13,148,136,.01)');
  charts.msgTrend=new Chart(el,{type:'line',data:{
    labels:data.map(function(r){return r.DateStr;}),
    datasets:[{label:'Messages',data:data.map(function(r){return r.Total||0;}),
      borderColor:'#0d9488',backgroundColor:grad,borderWidth:2.5,tension:.42,fill:true,
      pointRadius:0,pointHoverRadius:7}]
  },options:{responsive:true,maintainAspectRatio:false,
    plugins:{legend:{display:false},tooltip:TT},
    scales:{x:{grid:{display:false},ticks:{font:{size:10},maxTicksLimit:12}},
      y:{beginAtZero:true,grid:GRD,ticks:TICK}},animation:ANIM}});
}

/* ════════════════════════════════════════════════════
   HELP REQUEST TABLE
════════════════════════════════════════════════════ */
function renderHelpTable(d,page){
  var tbody=G('helpTbody'),pagInfo=G('helpPagInfo'),pagBtns=G('helpPagBtns'),cnt=G('helpCount');
  var data=d.helpRequests;
  var total=d.helpTotal||0;
  var pageSize=d.helpPageSize||10;
  var pageCount=d.helpPageCount||1;
  var pageIdx=d.helpPage||0;

  if(cnt)cnt.innerText=total+' tickets';

  /* hdOver24 */
  var s=d.adminStats||{};
  var hdOv=G('hdOver24');if(hdOv)hdOv.innerText=s.unrespondedOver24h||0;

  if(!data||!data.length){
    tbody.innerHTML='<tr><td colspan="7"><div class="empty"><i class="fa fa-ticket"></i><p>No help requests found</p></div></td></tr>';
    pagInfo.innerText='';pagBtns.innerHTML='';return;
  }
  var skip=pageIdx*pageSize;
  var html='';
  data.forEach(function(r,i){
    var isOpen=r.Status==='Open';
    var hrs=parseInt(r.HoursOpen)||0;
    var urgentCls=isOpen&&hrs>24?'pill-warn':'';
    var init=(r.StudentName||'?').substring(0,1).toUpperCase();
    var img=r.ProfileImage?'<img src="'+esc(r.ProfileImage)+'" alt=""/>':init;
    var asked=r.AskedOn?new Date(r.AskedOn).toLocaleDateString('en-IN',{day:'2-digit',month:'short',year:'numeric'}):'—';
    html+='<tr>'
      +'<td style="color:var(--tm);font-size:11px;">'+(skip+i+1)+'</td>'
      +'<td><div style="display:flex;align-items:center;gap:8px;">'
        +'<div class="av">'+img+'</div>'
        +'<div class="uname">'+esc(r.StudentName||'')+'</div>'
      +'</div></td>'
      +'<td style="max-width:260px;font-size:12px;color:var(--ts);">'
        +'<div style="white-space:nowrap;overflow:hidden;text-overflow:ellipsis;max-width:260px;" title="'+esc(r.Question)+'">'
        +esc((r.Question||'').substring(0,80))+'</div></td>'
      +'<td style="font-size:11px;color:var(--ts);white-space:nowrap;">'+asked+'</td>'
      +'<td style="font-size:12px;font-weight:700;color:'+(hrs>24?'var(--r)':'var(--ts)')+';">'
        +(isOpen?hrs+'h':'—')+'</td>'
      +'<td><span class="pill '+(isOpen?'pill-open '+urgentCls:'pill-res')+'">'+esc(r.Status)+'</span></td>'
      +'<td style="font-size:12px;color:var(--ts);">'+esc(r.ResolvedBy||'—')+'</td>'
    +'</tr>';
  });
  tbody.innerHTML=html;

  /* Pagination */
  var showing='Showing '+(skip+1)+'–'+Math.min(skip+pageSize,total)+' of '+total;
  pagInfo.innerText=showing;
  var btns='<button type="button" class="pbtn" data-pg="'+(pageIdx-1)+'" '+(pageIdx===0?'disabled':'')+'>'
    +'<i class="fa fa-chevron-left"></i></button>';
  var st=Math.max(0,pageIdx-2),en=Math.min(pageCount-1,st+4);
  for(var p=st;p<=en;p++)
    btns+='<button type="button" class="pbtn '+(p===pageIdx?'on':'')+'" data-pg="'+p+'">'+(p+1)+'</button>';
  btns+='<button type="button" class="pbtn" data-pg="'+(pageIdx+1)+'" '+(pageIdx>=pageCount-1?'disabled':'')+'>'
    +'<i class="fa fa-chevron-right"></i></button>';
  pagBtns.innerHTML=btns;
  pagBtns.querySelectorAll('.pbtn[data-pg]').forEach(function(btn){
    btn.addEventListener('click',function(e){
      e.preventDefault();if(this.disabled)return;
      var pg=parseInt(this.dataset.pg)||0;
      fetchPage(pg);
    });
  });
}

function fetchPage(page){
  setLoad(true);
  fetch(buildURL({page:page}))
    .then(function(r){return r.json();})
    .then(function(d){renderHelpTable(d,page);setLoad(false);})
    .catch(function(err){setLoad(false);console.error(err);});
}

/* ════════════════════════════════════════════════════
   ANNOUNCEMENTS
════════════════════════════════════════════════════ */
function renderAnnouncements(data,total){
  var wrap=G('annList'),cnt=G('annCount');
  if(cnt)cnt.innerText=(total||0)+' published';
  if(!data||!data.length){
    wrap.innerHTML='<div class="empty"><i class="fa fa-bullhorn"></i><p>No announcements found</p></div>';
    return;
  }
  var html='';
  data.forEach(function(a){
    var dt=a.CreatedOn?new Date(a.CreatedOn).toLocaleDateString('en-IN',{day:'2-digit',month:'short',year:'numeric'}):'—';
    html+='<div class="ann-card">'
      +'<div class="ann-title">'+esc(a.Title||'Untitled')+'</div>'
      +'<div class="ann-content">'+esc(a.Content||'')+'</div>'
      +'<div class="ann-meta">'
        +'<span><i class="fa fa-user"></i>'+esc(a.CreatedBy||'')+'</span>'
        +'<span><i class="fa fa-layer-group"></i>'+esc(a.StreamName||'All')+'</span>'
        +'<span><i class="fa fa-calendar"></i>'+dt+'</span>'
        +(parseInt(a.NotifCount||0)>0?'<span><i class="fa fa-bell"></i>'+esc(a.NotifCount)+' notified</span>':'')
      +'</div>'
    +'</div>';
  });
  wrap.innerHTML=html;
}

/* ════════════════════════════════════════════════════
   MESSAGES FEED
════════════════════════════════════════════════════ */
function renderMessages(data){
  var wrap=G('msgFeed');if(!wrap)return;
  if(!data||!data.length){
    wrap.innerHTML='<div class="empty"><i class="fa fa-comments"></i><p>No messages found</p></div>';
    return;
  }
  var typeCol={'Student':'var(--b)','Teacher':'var(--g)','Admin':'var(--p)'};
  var html='';
  data.forEach(function(m){
    var init=(m.SenderName||'?').substring(0,1).toUpperCase();
    var img=m.ProfileImage?'<img src="'+esc(m.ProfileImage)+'" alt=""/>':init;
    var col=typeCol[m.SenderRole]||'var(--ts)';
    var t=m.SentOn?new Date(m.SentOn).toLocaleString('en-IN',{day:'2-digit',month:'short',hour:'2-digit',minute:'2-digit'}):'—';
    html+='<div class="msg-item">'
      +'<div class="av" style="background:'+col+'22;color:'+col+';">'+img+'</div>'
      +'<div class="msg-body">'
        +'<div class="msg-name">'+esc(m.SenderName||'')+'</div>'
        +'<div class="msg-role">'+esc(m.SenderRole||'User')
          +(m.Subject?' &bull; <em>'+esc(m.Subject)+'</em>':'')+'</div>'
        +'<div class="msg-preview">'+esc(m.Preview||'')+'</div>'
      +'</div>'
      +'<div class="msg-time">'+t+'</div>'
    +'</div>';
  });
  wrap.innerHTML=html;
}

/* ════════════════════════════════════════════════════
   TOP COMMUNICATORS
════════════════════════════════════════════════════ */
function renderTopComm(data){
  var wrap=G('topCommList');if(!wrap)return;
  if(!data||!data.length){
    wrap.innerHTML='<div class="empty"><i class="fa fa-comments"></i><p>No communicator data</p></div>';
    return;
  }
  var maxM=Math.max.apply(null,data.map(function(r){return r.MessageCount||0;}))||1;
  var html='';
  data.forEach(function(t,i){
    var init=(t.FullName||'?').substring(0,1).toUpperCase();
    var img=t.ProfileImage?'<img src="'+esc(t.ProfileImage)+'" alt=""/>':init;
    var rank=i<3?'r'+(i+1):'rn';
    var pct=Math.round((t.MessageCount||0)/maxM*100);
    html+='<div style="display:flex;align-items:center;gap:10px;padding:9px 0;border-bottom:1px solid var(--bd);">'
      +'<div class="rk '+rank+'">'+(i+1)+'</div>'
      +'<div class="av">'+img+'</div>'
      +'<div style="flex:1;min-width:0;">'
        +'<div class="uname">'+esc(t.FullName||'')+'</div>'
        +'<div class="usub">'+esc(t.RoleName||'')+'&nbsp;&bull;&nbsp;'+esc(t.ActiveDays||0)+' active days</div>'
        +'<div style="height:4px;background:var(--bd);border-radius:99px;margin-top:4px;overflow:hidden;">'
          +'<div style="height:4px;background:var(--p);border-radius:99px;transition:width 1s ease;width:0%;" data-w="'+pct+'%"></div></div>'
      +'</div>'
      +'<div style="text-align:right;flex-shrink:0;">'
        +'<div style="font-size:15px;font-weight:800;color:var(--p);">'+esc(t.MessageCount||0)+'</div>'
        +'<div style="font-size:10px;color:var(--tm);">messages</div>'
      +'</div>'
    +'</div>';
  });
  wrap.innerHTML=html;
  setTimeout(function(){wrap.querySelectorAll('[data-w]').forEach(function(el){el.style.width=el.dataset.w;});},300);
}

/* ════════════════════════════════════════════════════
   TODAY STATS
════════════════════════════════════════════════════ */
function renderTodayStats(s){
  var wrap=G('todayStats');if(!wrap||!s)return;
  wrap.innerHTML='<div class="stat-row">'
    +'<div class="stat-lbl"><i class="fa fa-bell" style="color:var(--p);"></i>Notifications Sent Today</div>'
    +'<div class="stat-val">'+(s.notificationsToday||0)+'</div></div>'
  +'<div class="stat-row">'
    +'<div class="stat-lbl"><i class="fa fa-ticket" style="color:var(--w);"></i>Help Requests Today</div>'
    +'<div class="stat-val">'+(s.helpRequestsToday||0)+'</div></div>'
  +'<div class="stat-row">'
    +'<div class="stat-lbl"><i class="fa fa-comments" style="color:var(--t);"></i>Messages Today</div>'
    +'<div class="stat-val">'+(s.messagesToday||0)+'</div></div>'
  +'<div class="stat-row">'
    +'<div class="stat-lbl"><i class="fa fa-clock" style="color:var(--or);"></i>Avg Resolution Time</div>'
    +'<div class="stat-val '+(parseFloat(s.avgResolutionHours||0)>24?'warn':'ok')+'">'
      +(s.avgResolutionHours||0)+'h</div></div>'
  +'<div class="stat-row">'
    +'<div class="stat-lbl"><i class="fa fa-triangle-exclamation" style="color:var(--r);"></i>Unresponded >24h</div>'
    +'<div class="stat-val '+(parseInt(s.unrespondedOver24h||0)>0?'warn':'ok')+'">'+(s.unrespondedOver24h||0)+'</div></div>'
  +'<div class="stat-row">'
    +'<div class="stat-lbl"><i class="fa fa-chart-line" style="color:var(--g);"></i>30-Day Engagement Rate</div>'
    +'<div class="stat-val ok">'+(s.engagementRate30d||0)+'%</div></div>';
}

/* ════════════════════════════════════════════════════
   INSIGHT PANEL
════════════════════════════════════════════════════ */
function renderInsightPanel(s,k){
  var wrap=G('insightPanel');if(!wrap)return;
  s=s||{};k=k||{};
  var unr=parseInt(s.unrespondedOver24h||0);
  var rate=parseFloat(k.resolutionRate||0);
  var eng=parseFloat(s.engagementRate30d||0);
  var notifT=parseInt(s.notificationsToday||0);
  var resH=parseFloat(s.avgResolutionHours||0);
  var openH=parseInt(k.openHelpRequests||0);
  function si(warn,ico,n,hd,tx){
    return'<div class="ins '+(warn?'warn':'ok')+'">'
      +'<span class="ins-ico">'+ico+'</span><div class="ins-n">'+n+'</div>'
      +'<div class="ins-hd">'+hd+'</div><div class="ins-tx">'+tx+'</div></div>';
  }
  wrap.innerHTML='<div class="insight-panel">'
    +'<div class="insight-title"><i class="fa fa-gauge-high"></i>Communication Health Panel</div>'
    +'<div class="insight-grid">'
    +si(openH>10,'🎫',openH,'Open Tickets',
      openH>10?'High backlog! Assign more support staff and set resolution SLAs immediately.':'Ticket queue is manageable. Keep response times under 4 hours.')
    +si(unr>0,'⚠️',unr,'Unresponded >24h',
      unr>0?unr+' tickets haven\'t received any response in 24+ hours. Students are waiting — escalate now.':'All help requests have been responded to within 24 hours. Excellent!')
    +si(resH>48,'⏱️',resH.toFixed(1)+'h','Avg Resolution Time',
      resH>48?'Resolution times over 48h severely damage trust. Introduce auto-assignments and response templates.':'Good resolution time. Aim to keep this under 24 hours for best experience.')
    +si(eng<50,'📊',eng.toFixed(1)+'%','30-Day Engagement Rate',
      eng<50?'Less than half of students are receiving notifications. Verify contact details and enable push notifications.':'Strong engagement rate. Continue maintaining regular communication cadence.')
    +si(notifT===0,'🔔',notifT,'Notifications Today',
      notifT===0?'No notifications sent today. Schedule a daily digest or reminder to keep students informed.':'Active notification day. Monitor read rates to gauge content relevance.')
    +si(rate<60,'✅',rate.toFixed(1)+'%','Resolution Rate',
      rate<60?'Low resolution rate. Review unanswered questions and create an FAQ to handle recurring topics.':'Good resolution performance. Document resolved cases to build a knowledge base.')
    +'</div></div>';
}

/* ════════════════════════════════════════════════════
   CSV EXPORT
════════════════════════════════════════════════════ */
function doExport(){
  if(!lastData||!lastData.helpRequests||!lastData.helpRequests.length){
    alert('No data to export.');return;
  }
  var H=['Student','Question','Asked On','Hours Open','Status','Resolved By'];
  var R=lastData.helpRequests.map(function(r){
    return[r.StudentName,r.Question,r.AskedOn,r.HoursOpen,r.Status,r.ResolvedBy]
      .map(function(v){return'"'+String(v||'').replace(/"/g,'""')+'"';});
  });
  var csv=[H].concat(R).map(function(r){return r.join(',');}).join('\n');
  var a=document.createElement('a');
  a.href='data:text/csv;charset=utf-8,'+encodeURIComponent(csv);
  a.download='comm_support_'+new Date().toISOString().slice(0,10)+'.csv';
  a.click();
}

/* ════════════════════════════════════════════════════
   UTILITY
════════════════════════════════════════════════════ */
function esc(s){
  return String(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;')
    .replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

/* ════════════════════════════════════════════════════
   INITIAL LOAD
════════════════════════════════════════════════════ */
setTimeout(function(){go();},120);

})();
</script>
</asp:Content>
