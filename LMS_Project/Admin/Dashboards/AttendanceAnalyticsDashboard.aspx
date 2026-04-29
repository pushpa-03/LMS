<%@ Page Title="Attendance Analytics Dashboard" Language="C#"
    MasterPageFile="~/Admin/AdminMaster.Master"
    AutoEventWireup="true"
    CodeBehind="AttendanceAnalyticsDashboard.aspx.cs"
    Inherits="LearningManagementSystem.Admin.AttendanceAnalyticsDashboard" %>

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
  --cy:#0891b2;--cyl:#cffafe;
  --or:#ea580c;--orl:#ffedd5;
  --tx:#1e293b;--ts:#64748b;--tm:#94a3b8;
  --bd:#e2e8f0;--bg:#fff;--pg:#f1f5f9;
  --rad:14px;--rads:8px;
  --sh:0 1px 3px rgba(0,0,0,.06),0 1px 2px rgba(0,0,0,.04);
  --shm:0 4px 16px rgba(0,0,0,.09);
}
*{box-sizing:border-box;margin:0;padding:0;}
body{background:var(--pg);font-family:'Inter','Segoe UI',system-ui,sans-serif;color:var(--tx);}
.wrap{padding:22px;}

/* ── Alert ── */
.dash-alert{display:flex;align-items:center;gap:10px;padding:12px 18px;
  border-radius:var(--rads);font-size:13px;font-weight:500;margin-bottom:16px;
  animation:fd .3s ease;}
@keyframes fd{from{opacity:0;transform:translateY(-6px)}to{opacity:1;transform:none}}
.ad{background:var(--rl);color:#991b1b;border-left:3px solid var(--r);}

/* ══ BANNER ══ */
.banner{
  position:relative;border-radius:var(--rad);overflow:hidden;margin-bottom:20px;
  min-height:160px;box-shadow:var(--shm);
  background:linear-gradient(135deg,#064e3b 0%,#065f46 35%,#059669 70%,#10b981 100%);
}
.b-wave{position:absolute;bottom:0;left:0;right:0;z-index:0;}
.b-wave svg{display:block;width:100%;height:60px;}
.b-ov{position:absolute;inset:0;background:linear-gradient(105deg,rgba(4,30,24,.75),rgba(4,30,24,.18));z-index:1;}
.b-body{position:relative;z-index:2;display:flex;align-items:center;
  justify-content:space-between;padding:26px 36px;gap:20px;flex-wrap:wrap;}
.b-label{font-size:11px;font-weight:700;color:rgba(255,255,255,.55);
  text-transform:uppercase;letter-spacing:.1em;margin-bottom:6px;}
.b-title{font-size:24px;font-weight:800;color:#fff;line-height:1.2;}
.b-sub{font-size:13px;color:rgba(255,255,255,.68);margin-top:4px;}
.b-kpis{display:flex;gap:20px;margin-top:14px;flex-wrap:wrap;}
.bk{text-align:center;}
.bk-v{font-size:22px;font-weight:900;color:#fff;line-height:1;transition:all .5s;}
.bk-l{font-size:9px;color:rgba(255,255,255,.55);text-transform:uppercase;letter-spacing:.05em;margin-top:2px;}
.bdiv{width:1px;background:rgba(255,255,255,.2);align-self:stretch;}
.b-right{display:flex;flex-direction:column;align-items:flex-end;gap:10px;}
.live-badge{background:rgba(16,185,129,.25);border:1px solid rgba(16,185,129,.45);
  color:#a7f3d0;padding:5px 14px;border-radius:20px;font-size:11px;font-weight:700;
  display:inline-flex;align-items:center;gap:6px;}
.live-dot{width:7px;height:7px;border-radius:50%;background:#10b981;animation:pulse 1.4s infinite;}
@keyframes pulse{0%,100%{opacity:1;transform:scale(1)}50%{opacity:.45;transform:scale(.7)}}
.btn-exp{padding:9px 18px;background:rgba(255,255,255,.15);color:#fff;
  border:1px solid rgba(255,255,255,.35);border-radius:var(--rads);
  font-size:12px;font-weight:700;cursor:pointer;transition:.2s;
  display:inline-flex;align-items:center;gap:7px;backdrop-filter:blur(4px);}
.btn-exp:hover{background:rgba(255,255,255,.28);}
.spin{display:inline-block;width:18px;height:18px;border:2px solid rgba(255,255,255,.3);
  border-top-color:#fff;border-radius:50%;animation:spin .7s linear infinite;}
@keyframes spin{to{transform:rotate(360deg)}}

/* ══ FILTER BAR ══ */
.fb{background:var(--bg);border:1px solid var(--bd);border-radius:var(--rad);
  padding:16px 20px;margin-bottom:20px;box-shadow:var(--sh);}
.fb-hd{display:flex;align-items:center;justify-content:space-between;
  margin-bottom:14px;flex-wrap:wrap;gap:8px;}
.fb-lbl{font-size:12px;font-weight:700;color:var(--ts);text-transform:uppercase;
  letter-spacing:.05em;display:flex;align-items:center;gap:7px;}
.fb-acts{display:flex;gap:8px;}
.btn-apply{padding:7px 18px;background:var(--g);color:#fff;border:none;border-radius:var(--rads);
  font-size:12px;font-weight:700;cursor:pointer;display:inline-flex;align-items:center;gap:6px;transition:.18s;}
.btn-apply:hover{background:var(--gd);}
.btn-rst{padding:7px 14px;background:var(--pg);color:var(--ts);border:1px solid var(--bd);
  border-radius:var(--rads);font-size:12px;font-weight:600;cursor:pointer;
  display:inline-flex;align-items:center;gap:5px;transition:.18s;}
.btn-rst:hover{background:var(--bd);}
.f-row{display:flex;flex-wrap:wrap;gap:10px;align-items:flex-end;}
.fg{display:flex;flex-direction:column;gap:4px;min-width:120px;flex:1;}
.fg label{font-size:11px;font-weight:600;color:var(--ts);}
.fsel,.finp,.fdate{
  padding:8px 10px;border:1.5px solid var(--bd);border-radius:var(--rads);
  font-size:13px;color:var(--tx);background:#fff;width:100%;transition:.18s;
}
.fsel:focus,.finp:focus,.fdate:focus{
  border-color:var(--g);outline:none;box-shadow:0 0 0 3px rgba(16,185,129,.12);}
.sw{position:relative;flex:2;min-width:180px;}
.sw i{position:absolute;left:10px;top:50%;transform:translateY(-50%);color:var(--tm);font-size:12px;}
.fsrch{padding-left:32px !important;}
.lbar{height:3px;background:linear-gradient(90deg,var(--g),var(--t),var(--b));
  width:0%;border-radius:2px;transition:width .4s;margin-top:10px;}
.afc{display:flex;flex-wrap:wrap;gap:6px;margin-top:10px;}
.afc-chip{background:var(--gl);color:#065f46;padding:3px 10px;border-radius:99px;
  font-size:11px;font-weight:600;display:inline-flex;align-items:center;gap:5px;cursor:pointer;}
.afc-chip i{font-size:10px;opacity:.7;}
.afc-chip:hover{background:var(--bl);color:var(--b);}

/* quick-range pills */
.qr-pills{display:flex;gap:6px;flex-wrap:wrap;margin-top:10px;}
.qr-pill{padding:4px 12px;border:1px solid var(--bd);border-radius:99px;font-size:11px;
  font-weight:600;cursor:pointer;transition:.15s;background:#fff;color:var(--ts);}
.qr-pill:hover,.qr-pill.active{background:var(--g);color:#fff;border-color:var(--g);}

/* ══ KPI GRID ══ */
.kpi-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(145px,1fr));
  gap:12px;margin-bottom:20px;}
.kpi{background:var(--bg);border:1px solid var(--bd);border-radius:var(--rad);
  padding:16px 15px;box-shadow:var(--sh);position:relative;overflow:hidden;
  transition:transform .18s,box-shadow .18s;cursor:default;}
.kpi:hover{transform:translateY(-3px);box-shadow:var(--shm);}
.kpi::before{content:'';position:absolute;top:0;left:0;right:0;height:3px;
  border-radius:var(--rad) var(--rad) 0 0;}
.kg::before{background:var(--g);}  .kb::before{background:var(--b);}
.kr::before{background:var(--r);}  .kw::before{background:var(--w);}
.kt::before{background:var(--t);}  .kpu::before{background:var(--pu);}
.kor::before{background:var(--or);}.kro::before{background:var(--ro);}
.kcy::before{background:var(--cy);}
.kpi-top{display:flex;align-items:center;justify-content:space-between;margin-bottom:10px;}
.klbl{font-size:10px;font-weight:700;color:var(--ts);text-transform:uppercase;letter-spacing:.06em;}
.kico{width:38px;height:38px;border-radius:10px;display:flex;align-items:center;
  justify-content:center;font-size:16px;}
.ig{background:var(--gl);color:var(--g);}  .ib{background:var(--bl);color:var(--b);}
.ir{background:var(--rl);color:var(--r);}  .iw{background:var(--wl);color:var(--w);}
.it{background:var(--tl);color:var(--t);}  .ipu{background:var(--pul);color:var(--pu);}
.ior{background:var(--orl);color:var(--or);} .iro{background:var(--rol);color:var(--ro);}
.icy{background:var(--cyl);color:var(--cy);}
.kval{font-size:26px;font-weight:900;color:var(--tx);line-height:1;letter-spacing:-.5px;transition:all .4s;}
.ksub{font-size:11px;color:var(--tm);margin-top:4px;}
/* ring gauge in kpi */
.ring-kpi{position:relative;width:54px;height:54px;flex-shrink:0;}
.ring-kpi canvas{position:absolute;inset:0;}
.ring-val{position:absolute;inset:0;display:flex;align-items:center;justify-content:center;
  font-size:12px;font-weight:800;color:var(--tx);}

/* ══ TABS ══ */
.tab-bar{display:flex;gap:2px;background:var(--pg);border-radius:10px;padding:4px;
  margin-bottom:18px;flex-wrap:wrap;}
.tab-btn{padding:8px 16px;border:none;background:transparent;border-radius:8px;
  font-size:13px;font-weight:600;color:var(--ts);cursor:pointer;transition:.18s;
  display:flex;align-items:center;gap:6px;white-space:nowrap;}
.tab-btn.active{background:var(--bg);color:var(--g);box-shadow:var(--sh);}
.tab-btn:hover:not(.active){background:rgba(255,255,255,.55);}
.tab-pane{display:none;animation:fi .25s ease;}
.tab-pane.active{display:block;}
@keyframes fi{from{opacity:0;transform:translateY(5px)}to{opacity:1;transform:none}}

/* ══ CARD ══ */
.card{background:var(--bg);border:1px solid var(--bd);border-radius:var(--rad);
  box-shadow:var(--sh);padding:20px;transition:box-shadow .18s;margin-bottom:0;}
.card:hover{box-shadow:var(--shm);}
.card-hd{display:flex;align-items:flex-start;justify-content:space-between;
  margin-bottom:16px;gap:8px;flex-wrap:wrap;}
.card-hd-l{display:flex;align-items:center;gap:10px;}
.cico{width:32px;height:32px;border-radius:9px;display:flex;align-items:center;
  justify-content:center;font-size:14px;flex-shrink:0;}
.ctitle{font-size:14px;font-weight:700;color:var(--tx);}
.csub{font-size:12px;color:var(--ts);margin-top:1px;}
.chart-box{position:relative;width:100%;}
.g2 {display:grid;grid-template-columns:1fr 1fr;gap:16px;margin-bottom:18px;}
.g3 {display:grid;grid-template-columns:1fr 1fr 1fr;gap:16px;margin-bottom:18px;}
.g21{display:grid;grid-template-columns:2fr 1fr;gap:16px;margin-bottom:18px;}
.g12{display:grid;grid-template-columns:1fr 2fr;gap:16px;margin-bottom:18px;}

/* ══ HEATMAP ══ */
.heatmap-wrap{overflow-x:auto;}
.heatmap-grid{display:grid;gap:3px;min-width:320px;}
.hm-cell{width:22px;height:22px;border-radius:4px;cursor:pointer;position:relative;transition:.15s;}
.hm-cell:hover{transform:scale(1.25);z-index:2;box-shadow:0 2px 8px rgba(0,0,0,.18);}
.hm-label{font-size:10px;color:var(--ts);text-align:center;}
.hm-legend{display:flex;align-items:center;gap:6px;margin-top:10px;font-size:11px;color:var(--ts);}
.hm-legend-bar{display:flex;gap:2px;}
.hm-legend-cell{width:14px;height:14px;border-radius:3px;}

/* ══ STUDENT TABLE ══ */
.tbl-wrap{overflow-x:auto;}
.stbl{width:100%;border-collapse:collapse;font-size:13px;min-width:860px;}
.stbl th{font-size:10px;font-weight:700;color:var(--ts);text-transform:uppercase;
  letter-spacing:.05em;padding:10px 12px;border-bottom:2px solid var(--bd);text-align:left;
  white-space:nowrap;cursor:pointer;}
.stbl th:hover{color:var(--g);}
.stbl td{padding:11px 12px;border-bottom:1px solid var(--bd);vertical-align:middle;}
.stbl tr:hover td{background:#f0fdf4;}
.stbl tr:last-child td{border:none;}
.sav{width:34px;height:34px;border-radius:50%;background:var(--gl);color:var(--g);
  display:flex;align-items:center;justify-content:center;font-size:13px;font-weight:800;
  overflow:hidden;flex-shrink:0;border:2px solid var(--bd);}
.sav img{width:100%;height:100%;object-fit:cover;}
.sname{font-weight:700;color:var(--tx);}
.sroll{font-size:11px;color:var(--tm);}

/* attendance bar in table */
.att-bar-wrap{display:flex;align-items:center;gap:7px;}
.att-bar-bg{width:60px;height:6px;background:var(--bd);border-radius:99px;overflow:hidden;flex-shrink:0;}
.att-bar-fg{height:6px;border-radius:99px;transition:width 1s ease;}
.att-pct-lbl{font-size:12px;font-weight:700;min-width:36px;}

/* Category pill */
.cat-pill{padding:3px 10px;border-radius:99px;font-size:11px;font-weight:700;}
.cp-ex{background:#d1fae5;color:#065f46;} .cp-gd{background:#dbeafe;color:#1d4ed8;}
.cp-av{background:#fef3c7;color:#92400e;} .cp-lw{background:#fee2e2;color:#991b1b;}

/* Pagination */
.pag{display:flex;align-items:center;justify-content:space-between;
  margin-top:14px;flex-wrap:wrap;gap:10px;}
.pag-info{font-size:12px;color:var(--ts);}
.pag-btns{display:flex;gap:4px;}
.pbtn{width:32px;height:32px;border:1px solid var(--bd);border-radius:var(--rads);
  background:#fff;color:var(--ts);font-size:12px;font-weight:600;cursor:pointer;
  display:flex;align-items:center;justify-content:center;transition:.15s;}
.pbtn:hover{border-color:var(--g);color:var(--g);}
.pbtn.act{background:var(--g);color:#fff;border-color:var(--g);}
.pbtn:disabled{opacity:.35;cursor:not-allowed;}

/* Defaulters list */
.def-item{display:flex;align-items:center;gap:12px;padding:10px 0;border-bottom:1px solid var(--bd);}
.def-item:last-child{border:none;}
.def-bar-wrap{flex:1;display:flex;flex-direction:column;gap:3px;}
.def-bar-bg{height:6px;background:var(--bd);border-radius:99px;overflow:hidden;}
.def-bar-fg{height:6px;background:var(--r);border-radius:99px;transition:width 1s ease;width:0%;}
.def-pct{font-size:13px;font-weight:800;min-width:40px;text-align:right;}

/* Progress bars */
.pi{margin-bottom:12px;}
.pi-lbl{display:flex;justify-content:space-between;font-size:12px;font-weight:500;color:var(--tx);margin-bottom:4px;}
.pi-lbl span:last-child{color:var(--ts);}
.pi-track{height:8px;background:var(--bd);border-radius:99px;overflow:hidden;}
.pi-fill{height:8px;border-radius:99px;transition:width 1.1s ease;width:0%;}

/* Empty */
.empty{text-align:center;padding:40px;color:var(--tm);}
.empty i{font-size:32px;display:block;margin-bottom:10px;opacity:.4;}
.empty p{font-size:13px;}
.gspin{display:inline-block;width:20px;height:20px;border:2px solid var(--bd);
  border-top-color:var(--g);border-radius:50%;animation:spin .7s linear infinite;}

/* Responsive */
@media(max-width:1100px){.g21,.g12{grid-template-columns:1fr;}.g3{grid-template-columns:1fr 1fr;}}
@media(max-width:700px){.g2,.g3{grid-template-columns:1fr;}.kpi-grid{grid-template-columns:1fr 1fr 1fr;}}
@media(max-width:480px){.kpi-grid{grid-template-columns:1fr 1fr;}.tab-btn{font-size:11px;padding:7px 10px;}}
</style>
</asp:Content>

<asp:Content ID="cBody" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

<asp:HiddenField ID="hdnInstId"   runat="server"/>
<asp:HiddenField ID="hdnSessId"   runat="server"/>
<asp:HiddenField ID="hdnDateFrom" runat="server"/>
<asp:HiddenField ID="hdnDateTo"   runat="server"/>
<asp:Label       ID="lblSession"  runat="server" Style="display:none;"/>

<%-- Hidden ASP dropdowns for server-side init --%>
<asp:DropDownList ID="ddlStream"   runat="server" Style="display:none;"/>
<asp:DropDownList ID="ddlCourse"   runat="server" Style="display:none;"/>
<asp:DropDownList ID="ddlSection"  runat="server" Style="display:none;"/>
<asp:DropDownList ID="ddlSubject"  runat="server" Style="display:none;"/>
<asp:DropDownList ID="ddlSemester" runat="server" Style="display:none;"/>
<asp:DropDownList ID="ddlGender"   runat="server" Style="display:none;"/>

<div class="wrap">

<%-- ══ BANNER ══ --%>
<div class="banner">
  <div class="b-wave">
    <svg viewBox="0 0 1440 60" preserveAspectRatio="none" xmlns="http://www.w3.org/2000/svg">
      <path d="M0,30 C360,60 720,0 1080,30 C1260,45 1380,20 1440,30 L1440,60 L0,60 Z"
            fill="rgba(255,255,255,.06)"/>
    </svg>
  </div>
  <div class="b-ov"></div>
  <div class="b-body">
    <div>
      <div class="b-label"><i class="fa fa-calendar-check"></i>Attendance Analytics</div>
      <div class="b-title">Attendance Overview Dashboard</div>
      <div class="b-sub">Session: <span id="bSess"></span> &nbsp;&bull;&nbsp; Real-time analytics with full drill-down</div>
      <div class="b-kpis">
        <div class="bk"><div class="bk-v" id="bOverall">—</div><div class="bk-l">Overall %</div></div>
        <div class="bdiv"></div>
        <div class="bk"><div class="bk-v" id="bPresent">—</div><div class="bk-l">Total Present</div></div>
        <div class="bdiv"></div>
        <div class="bk"><div class="bk-v" id="bAbsent">—</div><div class="bk-l">Total Absent</div></div>
        <div class="bdiv"></div>
        <div class="bk"><div class="bk-v" id="bStudents">—</div><div class="bk-l">Students</div></div>
        <div class="bdiv"></div>
        <div class="bk"><div class="bk-v" id="bDays">—</div><div class="bk-l">Days Tracked</div></div>
        <div class="bdiv"></div>
        <div class="bk"><div class="bk-v" id="bToday">—</div><div class="bk-l">Today %</div></div>
      </div>
    </div>
    <div class="b-right">
      <div class="live-badge"><span class="live-dot"></span>Live</div>
      <button class="btn-exp" onclick="exportCSV()"><i class="fa fa-file-csv"></i>Export</button>
      <div class="spin" id="gSpin" style="display:none;"></div>
    </div>
  </div>
</div>

<%-- ══ FILTER BAR ══ --%>
<div class="fb">
  <div class="fb-hd">
    <div class="fb-lbl"><i class="fa fa-sliders"></i>Filters</div>
    <div class="fb-acts">
      <button class="btn-rst" onclick="resetFilters()"><i class="fa fa-rotate"></i>Reset</button>
      <button class="btn-apply" onclick="applyFilters(0)"><i class="fa fa-magnifying-glass"></i>Apply</button>
    </div>
  </div>
  <div class="f-row">
    <div class="fg">
      <label>Stream</label>
      <select id="fStream" class="fsel" onchange="onStreamChange()"><option value="0">All Streams</option></select>
    </div>
    <div class="fg">
      <label>Course</label>
      <select id="fCourse" class="fsel" onchange="applyFilters(0)"><option value="0">All Courses</option></select>
    </div>
    <div class="fg">
      <label>Section</label>
      <select id="fSection" class="fsel" onchange="applyFilters(0)"><option value="0">All Sections</option></select>
    </div>
    <div class="fg">
      <label>Subject</label>
      <select id="fSubject" class="fsel" onchange="applyFilters(0)"><option value="0">All Subjects</option></select>
    </div>
    <div class="fg">
      <label>Gender</label>
      <select id="fGender" class="fsel" onchange="applyFilters(0)">
        <option value="">All</option><option value="Male">Male</option>
        <option value="Female">Female</option><option value="Other">Other</option>
      </select>
    </div>
    <div class="fg">
      <label>Status</label>
      <select id="fStatus" class="fsel" onchange="applyFilters(0)">
        <option value="">All</option><option value="Present">Present</option>
        <option value="Absent">Absent</option><option value="Leave">Leave</option>
      </select>
    </div>
    <div class="fg">
      <label>Default Threshold</label>
      <select id="fThreshold" class="fsel" onchange="applyFilters(0)">
        <option value="75">75% (Default)</option>
        <option value="60">60%</option>
        <option value="80">80%</option>
        <option value="85">85%</option>
        <option value="90">90%</option>
      </select>
    </div>
    <div class="fg" style="min-width:130px;">
      <label>From Date</label>
      <input type="date" id="fDateFrom" class="fdate" onchange="applyFilters(0)"/>
    </div>
    <div class="fg" style="min-width:130px;">
      <label>To Date</label>
      <input type="date" id="fDateTo" class="fdate" onchange="applyFilters(0)"/>
    </div>
    <div class="fg sw" style="flex:2;min-width:170px;">
      <label>Search Student</label>
      <div style="position:relative;">
        <i class="fa fa-magnifying-glass" style="position:absolute;left:10px;top:50%;transform:translateY(-50%);color:var(--tm);"></i>
        <input id="fSearch" class="fsel fsrch" type="text"
               placeholder="Name or Roll No..."
               onkeydown="if(event.key==='Enter')applyFilters(0)"/>
      </div>
    </div>
  </div>

  <!-- Quick Range Pills -->
  <div class="qr-pills">
    <button class="qr-pill" onclick="setRange(7)">Last 7 Days</button>
    <button class="qr-pill" onclick="setRange(30)">Last 30 Days</button>
    <button class="qr-pill active" onclick="setCurMonth()">This Month</button>
    <button class="qr-pill" onclick="setRange(90)">Last 3 Months</button>
    <button class="qr-pill" onclick="setRange(180)">Last 6 Months</button>
    <button class="qr-pill" onclick="setFullSession()">Full Session</button>
  </div>

  <div class="lbar" id="lbar"></div>
  <div class="afc" id="afcWrap"></div>
</div>

<%-- ══ KPI CARDS ══ --%>
<div class="kpi-grid">
  <div class="kpi kg">
    <div class="kpi-top"><span class="klbl">Overall Attendance</span><div class="kico ig"><i class="fa fa-percent"></i></div></div>
    <div class="kval" id="kOverall">—</div><div class="ksub">All students avg</div>
  </div>
  <div class="kpi kg">
    <div class="kpi-top"><span class="klbl">Today's Attendance</span><div class="kico ig"><i class="fa fa-calendar-day"></i></div></div>
    <div class="kval" id="kToday">—</div><div class="ksub">Live today %</div>
  </div>
  <div class="kpi kb">
    <div class="kpi-top"><span class="klbl">Total Students</span><div class="kico ib"><i class="fa fa-users"></i></div></div>
    <div class="kval" id="kStudents">—</div><div class="ksub">In selection</div>
  </div>
  <div class="kpi kb">
    <div class="kpi-top"><span class="klbl">Days Tracked</span><div class="kico ib"><i class="fa fa-calendar"></i></div></div>
    <div class="kval" id="kDays">—</div><div class="ksub">Attendance days</div>
  </div>
  <div class="kpi kg">
    <div class="kpi-top"><span class="klbl">Total Present</span><div class="kico ig"><i class="fa fa-circle-check"></i></div></div>
    <div class="kval" id="kPresent">—</div><div class="ksub">Records marked present</div>
  </div>
  <div class="kpi kr">
    <div class="kpi-top"><span class="klbl">Total Absent</span><div class="kico ir"><i class="fa fa-circle-xmark"></i></div></div>
    <div class="kval" id="kAbsent">—</div><div class="ksub">Records marked absent</div>
  </div>
  <div class="kpi kw">
    <div class="kpi-top"><span class="klbl">On Leave</span><div class="kico iw"><i class="fa fa-person-walking-arrow-right"></i></div></div>
    <div class="kval" id="kLeave">—</div><div class="ksub">Leave records</div>
  </div>
  <div class="kpi kt">
    <div class="kpi-top"><span class="klbl">Above 75%</span><div class="kico it"><i class="fa fa-arrow-trend-up"></i></div></div>
    <div class="kval" id="kAbove75">—</div><div class="ksub">Students compliant</div>
  </div>
  <div class="kpi kr">
    <div class="kpi-top"><span class="klbl">Below 75%</span><div class="kico ir"><i class="fa fa-triangle-exclamation"></i></div></div>
    <div class="kval" id="kBelow75">—</div><div class="ksub">Defaulters at risk</div>
  </div>
</div>

<%-- ══ TABS ══ --%>
<div class="tab-bar">
  <button class="tab-btn active" onclick="switchTab('trends',this)"><i class="fa fa-chart-line"></i>Trends</button>
  <button class="tab-btn" onclick="switchTab('breakdown',this)"><i class="fa fa-chart-pie"></i>Breakdown</button>
  <button class="tab-btn" onclick="switchTab('students',this)"><i class="fa fa-users"></i>Students</button>
  <button class="tab-btn" onclick="switchTab('defaulters',this)"><i class="fa fa-triangle-exclamation"></i>Defaulters</button>
  <button class="tab-btn" onclick="switchTab('heatmap',this)"><i class="fa fa-table-cells"></i>Heatmap</button>
</div>

<%-- ══ TAB: TRENDS ══ --%>
<div id="tab-trends" class="tab-pane active">
  <div class="g21">
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--gl);color:var(--g);"><i class="fa fa-chart-line"></i></div>
          <div><div class="ctitle">Daily Attendance Trend</div>
            <div class="csub">Present · Absent · Leave per day (area chart)</div></div>
        </div>
        <span id="trendRangeLbl" style="font-size:11px;color:var(--tm);"></span>
      </div>
      <div class="chart-box" style="height:260px;"><canvas id="cDaily"></canvas></div>
    </div>
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--tl);color:var(--t);"><i class="fa fa-calendar-days"></i></div>
          <div><div class="ctitle">Day-of-Week Pattern</div>
            <div class="csub">Which day has best attendance?</div></div>
        </div>
      </div>
      <div class="chart-box" style="height:260px;"><canvas id="cDayOfWeek"></canvas></div>
    </div>
  </div>

  <div class="g2">
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--pul);color:var(--pu);"><i class="fa fa-chart-column"></i></div>
          <div><div class="ctitle">Weekly Summary</div>
            <div class="csub">Present vs Absent per week</div></div>
        </div>
      </div>
      <div class="chart-box" style="height:230px;"><canvas id="cWeekly"></canvas></div>
    </div>
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--wl);color:var(--w);"><i class="fa fa-calendar-alt"></i></div>
          <div><div class="ctitle">Monthly Trend</div>
            <div class="csub">Attendance % per month — full session</div></div>
        </div>
      </div>
      <div class="chart-box" style="height:230px;"><canvas id="cMonthly"></canvas></div>
    </div>
  </div>
</div>

<%-- ══ TAB: BREAKDOWN ══ --%>
<div id="tab-breakdown" class="tab-pane">
  <div class="g2">
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--pul);color:var(--pu);"><i class="fa fa-layer-group"></i></div>
          <div><div class="ctitle">Stream-wise Attendance</div>
            <div class="csub">% present per stream</div></div>
        </div>
      </div>
      <div class="chart-box" style="height:240px;"><canvas id="cStream"></canvas></div>
    </div>
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--cyl);color:var(--cy);"><i class="fa fa-graduation-cap"></i></div>
          <div><div class="ctitle">Course-wise Attendance</div></div>
        </div>
      </div>
      <div class="chart-box" style="height:240px;"><canvas id="cCourse"></canvas></div>
    </div>
  </div>
  <div class="g3">
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--bl);color:var(--b);"><i class="fa fa-book-open"></i></div>
          <div><div class="ctitle">Subject-wise</div></div>
        </div>
      </div>
      <div class="chart-box" style="height:220px;"><canvas id="cSubject"></canvas></div>
    </div>
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--tl);color:var(--t);"><i class="fa fa-sitemap"></i></div>
          <div><div class="ctitle">Section-wise</div></div>
        </div>
      </div>
      <div class="chart-box" style="height:220px;"><canvas id="cSection"></canvas></div>
    </div>
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--rol);color:var(--ro);"><i class="fa fa-chart-pie"></i></div>
          <div><div class="ctitle">Attendance Buckets</div>
            <div class="csub">Student distribution by range</div></div>
        </div>
      </div>
      <div class="chart-box" style="height:185px;"><canvas id="cBuckets"></canvas></div>
      <div id="bucketBars" style="margin-top:10px;"></div>
    </div>
  </div>
</div>

<%-- ══ TAB: STUDENTS ══ --%>
<div id="tab-students" class="tab-pane">
  <div class="card">
    <div class="card-hd">
      <div class="card-hd-l">
        <div class="cico" style="background:var(--bl);color:var(--b);"><i class="fa fa-table"></i></div>
        <div><div class="ctitle">Student-wise Attendance</div>
          <div class="csub" id="stuCount">Loading…</div></div>
      </div>
    </div>
    <div class="tbl-wrap">
      <table class="stbl">
        <thead>
          <tr>
            <th>#</th><th>Student</th><th>Roll No</th><th>Course</th>
            <th>Section</th><th>Gender</th><th>Total</th><th>Present</th>
            <th>Absent</th><th>Attendance</th><th>Status</th>
          </tr>
        </thead>
        <tbody id="stuTbody"><tr><td colspan="11"><div class="empty"><div class="gspin"></div></div></td></tr></tbody>
      </table>
    </div>
    <div class="pag">
      <div class="pag-info" id="pagInfo"></div>
      <div class="pag-btns" id="pagBtns"></div>
    </div>
  </div>
</div>

<%-- ══ TAB: DEFAULTERS ══ --%>
<div id="tab-defaulters" class="tab-pane">
  <div class="g12">
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--rl);color:var(--r);"><i class="fa fa-triangle-exclamation"></i></div>
          <div><div class="ctitle">Defaulters List</div>
            <div class="csub">Students below threshold</div></div>
        </div>
      </div>
      <div id="defList"><div class="empty"><div class="gspin"></div></div></div>
    </div>
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="cico" style="background:var(--rl);color:var(--r);"><i class="fa fa-chart-bar"></i></div>
          <div><div class="ctitle">Defaulter Attendance Bars</div>
            <div class="csub">Ranked by lowest attendance</div></div>
        </div>
      </div>
      <div id="defBars"></div>
    </div>
  </div>
</div>

<%-- ══ TAB: HEATMAP ══ --%>
<div id="tab-heatmap" class="tab-pane">
  <div class="card">
    <div class="card-hd">
      <div class="card-hd-l">
        <div class="cico" style="background:var(--gl);color:var(--g);"><i class="fa fa-table-cells"></i></div>
        <div><div class="ctitle">Attendance Heatmap</div>
          <div class="csub">Day-of-week × Month — darker = higher attendance</div></div>
      </div>
    </div>
    <div class="heatmap-wrap"><div id="heatmapContainer"></div></div>
    <div class="hm-legend">
      <span>Low</span>
      <div class="hm-legend-bar" id="hmLegBar"></div>
      <span>High</span>
    </div>
  </div>
</div>

</div><%-- /wrap --%>

<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.4.1/chart.umd.min.js"></script>
<script>
(function(){
'use strict';

/* ═══════════════════════════════════════════════════════
   GLOBALS
═══════════════════════════════════════════════════════ */
const INST  = document.getElementById('<%= hdnInstId.ClientID %>').value;
const SESS  = document.getElementById('<%= hdnSessId.ClientID %>').value;
const SNAME = document.getElementById('<%= lblSession.ClientID %>').innerText.trim();
let   DFROM = document.getElementById('<%= hdnDateFrom.ClientID %>').value;
let   DTO   = document.getElementById('<%= hdnDateTo.ClientID %>').value;

document.getElementById('bSess').innerText = SNAME;
document.getElementById('fDateFrom').value = DFROM;
document.getElementById('fDateTo').value   = DTO;

const PAL  = ['#10b981','#3b82f6','#f59e0b','#ef4444','#8b5cf6',
              '#0d9488','#f43f5e','#0891b2','#ea580c','#7c3aed','#84cc16','#4f46e5'];
const GRD  = { color:'rgba(148,163,184,.12)' };
const TICK = { font:{ size:11, family:"'Inter','Segoe UI',sans-serif" } };
const TT   = { padding:10, cornerRadius:8, bodyFont:{size:12}, titleFont:{size:12,weight:'bold'} };
const ANIM = { duration:950, easing:'easeInOutQuart' };
const noL  = { legend:{display:false} };
const palA = a => PAL.map(c => c+Math.round(a*255).toString(16).padStart(2,'0'));

let charts={}, curPage=0, totPages=1, debT=null, lastData=null;

/* ═══════════════════════════════════════════════════════
   FILTER HELPERS
═══════════════════════════════════════════════════════ */
function F(){ return {
  stream:    document.getElementById('fStream').value,
  course:    document.getElementById('fCourse').value,
  section:   document.getElementById('fSection').value,
  subject:   document.getElementById('fSubject').value,
  gender:    document.getElementById('fGender').value,
  status:    document.getElementById('fStatus').value,
  threshold: document.getElementById('fThreshold').value,
  datefrom:  document.getElementById('fDateFrom').value,
  dateto:    document.getElementById('fDateTo').value,
  search:    document.getElementById('fSearch').value.trim()
};}

window.resetFilters=function(){
  ['fStream','fCourse','fSection','fSubject'].forEach(id=>document.getElementById(id).value='0');
  ['fGender','fStatus'].forEach(id=>document.getElementById(id).value='');
  document.getElementById('fThreshold').value='75';
  document.getElementById('fSearch').value='';
  document.getElementById('afcWrap').innerHTML='';
  setCurMonth();
};

window.applyFilters=function(page){
  curPage=page||0;
  clearTimeout(debT);
  debT=setTimeout(()=>fetchData(curPage),280);
};

window.onStreamChange=function(){
  const sid=document.getElementById('fStream').value;
  fetch(buildURL(0)+`&action=courses&stream=${sid}`)
    .then(r=>r.json())
    .then(d=>{
      const sel=document.getElementById('fCourse');
      sel.innerHTML='<option value="0">All Courses</option>';
      (d.courses||[]).forEach(c=>{
        const o=document.createElement('option');
        o.value=c.CourseId; o.text=c.CourseDisplay; sel.appendChild(o);
      });
    }).catch(()=>{});
  applyFilters(0);
};

function buildURL(page){
  const f=F();
  return `${location.pathname}?ajax=1&inst=${INST}&sess=${SESS}`
    +`&stream=${f.stream}&course=${f.course}&section=${f.section}`
    +`&subject=${f.subject}&gender=${encodeURIComponent(f.gender)}`
    +`&datefrom=${f.datefrom}&dateto=${f.dateto}`
    +`&threshold=${f.threshold}`
    +`&search=${encodeURIComponent(f.search)}&page=${page||0}`;
}

/* Quick-range pills */
window.setRange=function(days){
  const to=new Date(), from=new Date();
  from.setDate(to.getDate()-days+1);
  document.getElementById('fDateFrom').value=fmt(from);
  document.getElementById('fDateTo').value=fmt(to);
  document.querySelectorAll('.qr-pill').forEach(p=>p.classList.remove('active'));
  event.target.classList.add('active');
  applyFilters(0);
};
window.setCurMonth=function(){
  const now=new Date();
  document.getElementById('fDateFrom').value=fmt(new Date(now.getFullYear(),now.getMonth(),1));
  document.getElementById('fDateTo').value=fmt(now);
  document.querySelectorAll('.qr-pill').forEach(p=>p.classList.remove('active'));
  document.querySelectorAll('.qr-pill')[2].classList.add('active');
  applyFilters(0);
};
window.setFullSession=function(){
  document.getElementById('fDateFrom').value='';
  document.getElementById('fDateTo').value='';
  document.querySelectorAll('.qr-pill').forEach(p=>p.classList.remove('active'));
  event.target.classList.add('active');
  applyFilters(0);
};
function fmt(d){ return d.toISOString().split('T')[0]; }

/* Active filter chips */
function updateChips(){
  const f=F();
  const ids={stream:'fStream',course:'fCourse',section:'fSection',subject:'fSubject',gender:'fGender'};
  const wrap=document.getElementById('afcWrap'); wrap.innerHTML='';
  Object.keys(ids).forEach(k=>{
    const el=document.getElementById(ids[k]);
    const v=el.value; if(!v||v==='0') return;
    const t=el.options[el.selectedIndex]?.text||v;
    wrap.innerHTML+=`<span class="afc-chip" onclick="clearF('${ids[k]}')">
        ${t} <i class="fa fa-xmark"></i></span>`;
  });
  if(f.datefrom||f.dateto)
    wrap.innerHTML+=`<span class="afc-chip">
      ${f.datefrom||'Start'} → ${f.dateto||'Now'} <i class="fa fa-calendar"></i></span>`;
  if(f.search)
    wrap.innerHTML+=`<span class="afc-chip" onclick="clearF('fSearch')">"${f.search}" <i class="fa fa-xmark"></i></span>`;
  const rl=document.getElementById('trendRangeLbl');
  if(rl) rl.innerText=f.datefrom?`${f.datefrom} → ${f.dateto||'Today'}`:'Full session';
}

window.clearF=function(id){
  const el=document.getElementById(id);
  if(el.tagName==='SELECT') el.value=id.includes('Stream')||id.includes('Course')||id.includes('Section')||id.includes('Subject')?'0':'';
  else el.value='';
  applyFilters(0);
};

/* ═══════════════════════════════════════════════════════
   MAIN FETCH
═══════════════════════════════════════════════════════ */
function fetchData(page){
  setLoading(true); updateChips();
  fetch(buildURL(page))
    .then(r=>{ if(!r.ok) throw new Error('HTTP '+r.status); return r.json(); })
    .then(d=>{
      lastData=d;
      renderKPIs(d.kpi);
      renderAllCharts(d);
      renderStudentTable(d);
      renderDefaulters(d.defaulters);
      renderHeatmap(d.heatmap);
      setLoading(false);
    })
    .catch(err=>{ setLoading(false); console.error(err); });
}

function setLoading(on){
  const bar=document.getElementById('lbar');
  const sp=document.getElementById('gSpin');
  bar.style.width=on?'82%':'100%';
  sp.style.display=on?'inline-block':'none';
  if(!on) setTimeout(()=>bar.style.width='0%',600);
}

/* ═══════════════════════════════════════════════════════
   KPI RENDER
═══════════════════════════════════════════════════════ */
function renderKPIs(k){
  if(!k) return;
  const pct=parseFloat(k.overallPct)||0;
  const today=parseFloat(k.todayPct)||0;

  // Main cards
  document.getElementById('kOverall').innerText   = pct+'%';
  document.getElementById('kToday').innerText     = today+'%';
  countUp('kStudents', k.totalStudents ||0);
  countUp('kDays',     k.totalDays     ||0);
  countUp('kPresent',  k.totalPresent  ||0);
  countUp('kAbsent',   k.totalAbsent   ||0);
  countUp('kLeave',    k.totalLeave    ||0);
  countUp('kAbove75',  k.above75       ||0);
  countUp('kBelow75',  k.below75       ||0);

  // Banner
  document.getElementById('bOverall').innerText  = pct+'%';
  document.getElementById('bToday').innerText    = today+'%';
  document.getElementById('bPresent').innerText  = fmt_num(k.totalPresent);
  document.getElementById('bAbsent').innerText   = fmt_num(k.totalAbsent);
  document.getElementById('bStudents').innerText = fmt_num(k.totalStudents);
  document.getElementById('bDays').innerText     = k.totalDays||0;
}

function fmt_num(n){ n=parseInt(n)||0; return n>=1000?(n/1000).toFixed(1)+'k':n; }

function countUp(id,target){
  const el=document.getElementById(id); if(!el) return;
  const start=parseInt(el.innerText)||0, diff=target-start, steps=28;
  let i=0;
  const iv=setInterval(()=>{
    i++; el.innerText=Math.round(start+diff*(i/steps));
    if(i>=steps){el.innerText=target; clearInterval(iv);}
  },16);
}

/* ═══════════════════════════════════════════════════════
   CHART HELPERS
═══════════════════════════════════════════════════════ */
function dc(k){ if(charts[k]){charts[k].destroy();charts[k]=null;} }
function gV(ctx,h,c1,c2){ const g=ctx.createLinearGradient(0,0,0,h);g.addColorStop(0,c1);g.addColorStop(1,c2);return g; }
function noData(id,msg){
  const el=document.getElementById(id); if(!el) return;
  const box=el.closest?.('.chart-box');
  if(box) box.innerHTML=`<div class="empty"><i class="fa fa-chart-simple"></i><p>${msg||'No data'}</p></div>`;
}

/* ═══════════════════════════════════════════════════════
   ALL CHARTS
═══════════════════════════════════════════════════════ */
function renderAllCharts(d){
  renderDaily(d.dailyTrend);
  renderDayOfWeek(d.dayOfWeek);
  renderWeekly(d.weeklySummary);
  renderMonthly(d.monthlySummary);
  renderStreamChart(d.streamWise);
  renderCourseChart(d.courseWise);
  renderSubjectChart(d.subjectWise);
  renderSectionChart(d.sectionWise);
  renderBuckets(d.buckets);
}

// 1. Daily — multi-area
function renderDaily(data){
  dc('daily');
  if(!data?.length){ noData('cDaily','No daily data'); return; }
  const el=document.getElementById('cDaily'); if(!el) return;
  const ctx=el.getContext('2d');
  const gP=gV(ctx,240,'rgba(16,185,129,.28)','rgba(16,185,129,.02)');
  const gA=gV(ctx,240,'rgba(239,68,68,.18)','rgba(239,68,68,.01)');

  charts.daily=new Chart(ctx,{type:'line',data:{
    labels:data.map(r=>r.DateStr),
    datasets:[
      {label:'Present',data:data.map(r=>r.Present||0),borderColor:'#10b981',
       backgroundColor:gP,borderWidth:2.5,tension:.4,fill:true,
       pointRadius:0,pointHoverRadius:6,pointHoverBackgroundColor:'#10b981'},
      {label:'Absent',data:data.map(r=>r.Absent||0),borderColor:'#ef4444',
       backgroundColor:gA,borderWidth:2,tension:.4,fill:true,
       pointRadius:0,pointHoverRadius:6,pointHoverBackgroundColor:'#ef4444'},
      {label:'Att %',data:data.map(r=>r.AttPct||0),borderColor:'#4f46e5',
       backgroundColor:'transparent',borderWidth:2,borderDash:[5,4],tension:.4,
       fill:false,pointRadius:0,pointHoverRadius:6,yAxisID:'y1'}
    ]
  },options:{responsive:true,maintainAspectRatio:false,
    interaction:{mode:'index',intersect:false},
    plugins:{legend:{position:'top',labels:{boxWidth:10,font:{size:11}}},tooltip:TT},
    scales:{
      x:{grid:{display:false},ticks:{font:{size:10},maxTicksLimit:12,maxRotation:30}},
      y:{beginAtZero:true,grid:GRD,ticks:TICK},
      y1:{position:'right',beginAtZero:true,max:100,grid:{display:false},
          ticks:{...TICK,callback:v=>v+'%'}}
    },animation:ANIM}});
}

// 2. Day-of-week radar
function renderDayOfWeek(data){
  dc('dow');
  if(!data?.length){ noData('cDayOfWeek','No day data'); return; }
  const el=document.getElementById('cDayOfWeek'); if(!el) return;
  charts.dow=new Chart(el,{type:'radar',data:{
    labels:data.map(r=>r.DayName),
    datasets:[{label:'Attendance %',data:data.map(r=>r.AttPct||0),
      backgroundColor:'rgba(16,185,129,.18)',borderColor:'#10b981',
      borderWidth:2.5,pointBackgroundColor:'#10b981',pointRadius:5,pointHoverRadius:8}]
  },options:{responsive:true,maintainAspectRatio:false,
    plugins:{...noL,tooltip:{...TT,callbacks:{label:c=>` ${c.raw}%`}}},
    scales:{r:{beginAtZero:true,max:100,ticks:{font:{size:9},callback:v=>v+'%'},
      grid:{color:'rgba(148,163,184,.2)'},pointLabels:{font:{size:11}}}},
    animation:{duration:1100,easing:'easeInOutBack'}}});
}

// 3. Weekly stacked bar
function renderWeekly(data){
  dc('weekly');
  if(!data?.length){ noData('cWeekly','No weekly data'); return; }
  const el=document.getElementById('cWeekly'); if(!el) return;
  charts.weekly=new Chart(el,{type:'bar',data:{
    labels:data.map(r=>r.WeekLabel),
    datasets:[
      {label:'Present',data:data.map(r=>r.Present||0),backgroundColor:'rgba(16,185,129,.85)',borderRadius:4,stack:'s'},
      {label:'Absent', data:data.map(r=>r.Absent ||0),backgroundColor:'rgba(239,68,68,.75)', borderRadius:4,stack:'s'}
    ]
  },options:{responsive:true,maintainAspectRatio:false,
    interaction:{mode:'index',intersect:false},
    plugins:{legend:{position:'top',labels:{boxWidth:10,font:{size:11}}},tooltip:TT},
    scales:{x:{grid:{display:false},ticks:TICK,stacked:true},y:{grid:GRD,ticks:TICK,stacked:true}},
    animation:ANIM}});
}

// 4. Monthly line+bar
function renderMonthly(data){
  dc('monthly');
  if(!data?.length){ noData('cMonthly','No monthly data'); return; }
  const el=document.getElementById('cMonthly'); if(!el) return;
  charts.monthly=new Chart(el,{type:'bar',data:{
    labels:data.map(r=>r.MonLabel),
    datasets:[
      {label:'Present',data:data.map(r=>r.Present||0),backgroundColor:'rgba(16,185,129,.75)',borderRadius:5},
      {label:'Absent', data:data.map(r=>r.Absent ||0),backgroundColor:'rgba(239,68,68,.65)', borderRadius:5},
      {label:'Att %',  data:data.map(r=>r.AttPct  ||0),type:'line',borderColor:'#4f46e5',
       borderWidth:2.5,tension:.4,fill:false,pointRadius:4,pointHoverRadius:7,
       pointBackgroundColor:'#4f46e5',yAxisID:'y1'}
    ]
  },options:{responsive:true,maintainAspectRatio:false,
    interaction:{mode:'index',intersect:false},
    plugins:{legend:{position:'top',labels:{boxWidth:10,font:{size:11}}},tooltip:TT},
    scales:{
      x:{grid:{display:false},ticks:{font:{size:10}}},
      y:{beginAtZero:true,grid:GRD,ticks:TICK},
      y1:{position:'right',beginAtZero:true,max:100,grid:{display:false},
          ticks:{...TICK,callback:v=>v+'%'}}
    },animation:ANIM}});
}

// 5. Stream bar
function renderStreamChart(data){
  dc('stream');
  if(!data?.length){ noData('cStream','No stream data'); return; }
  const el=document.getElementById('cStream'); if(!el) return;
  charts.stream=new Chart(el,{type:'bar',data:{
    labels:data.map(r=>r.StreamName),
    datasets:[
      {label:'Present %',data:data.map(r=>r.AttPct||0),backgroundColor:'rgba(16,185,129,.82)',borderRadius:6},
      {label:'Absent %', data:data.map(r=>100-(r.AttPct||0)),backgroundColor:'rgba(239,68,68,.55)',borderRadius:6}
    ]
  },options:{responsive:true,maintainAspectRatio:false,
    interaction:{mode:'index',intersect:false},
    plugins:{legend:{position:'top',labels:{boxWidth:10,font:{size:11}}},tooltip:TT},
    scales:{x:{grid:{display:false},ticks:TICK},y:{beginAtZero:true,max:100,grid:GRD,ticks:{...TICK,callback:v=>v+'%'}}},
    animation:ANIM}});
}

// 6. Course horizontal bar
function renderCourseChart(data){
  dc('course');
  if(!data?.length){ noData('cCourse','No course data'); return; }
  const el=document.getElementById('cCourse'); if(!el) return;
  const short=data.map(r=>(r.CourseName||'').length>16?r.CourseName.substring(0,15)+'…':r.CourseName);
  charts.course=new Chart(el,{type:'bar',data:{
    labels:short,
    datasets:[{label:'Attendance %',data:data.map(r=>r.AttPct||0),
      backgroundColor:palA(.82),borderRadius:6,borderSkipped:false}]
  },options:{indexAxis:'y',responsive:true,maintainAspectRatio:false,
    plugins:{...noL,tooltip:TT},
    scales:{x:{beginAtZero:true,max:100,grid:GRD,ticks:{...TICK,callback:v=>v+'%'}},
            y:{grid:{display:false},ticks:{font:{size:11}}}},
    animation:ANIM}});
}

// 7. Subject horizontal bar
function renderSubjectChart(data){
  dc('subj');
  if(!data?.length){ noData('cSubject','No subject data'); return; }
  const el=document.getElementById('cSubject'); if(!el) return;
  charts.subj=new Chart(el,{type:'bar',data:{
    labels:data.map(r=>(r.SubjectName||'').length>14?r.SubjectName.substring(0,13)+'…':r.SubjectName),
    datasets:[{label:'Att %',data:data.map(r=>r.AttPct||0),
      backgroundColor:palA(.82),borderRadius:5,borderSkipped:false}]
  },options:{indexAxis:'y',responsive:true,maintainAspectRatio:false,
    plugins:{...noL,tooltip:TT},
    scales:{x:{beginAtZero:true,max:100,grid:GRD,ticks:{...TICK,callback:v=>v+'%'}},
            y:{grid:{display:false},ticks:{font:{size:10}}}},
    animation:ANIM}});
}

// 8. Section doughnut
function renderSectionChart(data){
  dc('section');
  if(!data?.length){ noData('cSection','No section data'); return; }
  const el=document.getElementById('cSection'); if(!el) return;
  charts.section=new Chart(el,{type:'doughnut',data:{
    labels:data.map(r=>r.SectionName),
    datasets:[{data:data.map(r=>r.AttPct||0),
      backgroundColor:palA(.85),borderWidth:2,borderColor:'#fff',hoverOffset:10}]
  },options:{cutout:'60%',responsive:true,maintainAspectRatio:false,
    plugins:{legend:{position:'right',labels:{boxWidth:10,font:{size:11}}},
      tooltip:{...TT,callbacks:{label:c=>`${c.label}: ${c.raw}%`}}},
    animation:{animateRotate:true,duration:1100}}});
}

// 9. Buckets doughnut + bars
function renderBuckets(data){
  dc('buckets');
  const bBars=document.getElementById('bucketBars');
  if(!data?.length){ noData('cBuckets','No bucket data'); if(bBars) bBars.innerHTML=''; return; }
  const el=document.getElementById('cBuckets'); if(!el) return;
  const BCOL=['#10b981','#3b82f6','#f59e0b','#ef4444'];
  charts.buckets=new Chart(el,{type:'doughnut',data:{
    labels:data.map(r=>r.Bucket),
    datasets:[{data:data.map(r=>r.Students||0),
      backgroundColor:BCOL,borderWidth:2,borderColor:'#fff',hoverOffset:8}]
  },options:{cutout:'55%',responsive:true,maintainAspectRatio:false,
    plugins:{legend:{display:false},tooltip:TT},
    animation:{animateRotate:true,duration:1100}}});

  if(bBars){
    bBars.innerHTML='';
    const tot=data.reduce((a,b)=>a+(b.Students||0),0)||1;
    data.forEach((r,i)=>{
      const pct=Math.round((r.Students||0)/tot*100);
      bBars.innerHTML+=`<div class="pi">
        <div class="pi-lbl"><span style="color:${BCOL[i]};font-weight:700;">${r.Bucket}</span>
          <span>${r.Students||0} students</span></div>
        <div class="pi-track"><div class="pi-fill" data-w="${pct}%" style="background:${BCOL[i]};"></div></div>
        </div>`;
    });
    setTimeout(()=>document.querySelectorAll('.pi-fill[data-w]').forEach(el=>el.style.width=el.dataset.w),300);
  }
}

/* ═══════════════════════════════════════════════════════
   STUDENT TABLE
═══════════════════════════════════════════════════════ */
function renderStudentTable(d){
  const tbody  = document.getElementById('stuTbody');
  const pagI   = document.getElementById('pagInfo');
  const pagB   = document.getElementById('pagBtns');
  const stuLbl = document.getElementById('stuCount');

  if(!d.students?.length){
    tbody.innerHTML=`<tr><td colspan="11"><div class="empty"><i class="fa fa-users"></i><p>No student data matches filters</p></div></td></tr>`;
    pagI.innerText=''; pagB.innerHTML=''; stuLbl.innerText='0 records';
    return;
  }
  totPages=d.pageCount||1; curPage=d.pageIndex||0;
  const skip=curPage*d.pageSize;
  stuLbl.innerText=`${d.totalCount} students`;

  let html='';
  d.students.forEach((s,i)=>{
    const att   = parseFloat(s.AttPct)||0;
    const col   = att>=90?'#10b981':att>=75?'#3b82f6':att>=60?'#f59e0b':'#ef4444';
    const catCls= att>=90?'cp-ex':att>=75?'cp-gd':att>=60?'cp-av':'cp-lw';
    const init  = (s.FullName||'?').substring(0,1).toUpperCase();
    const img   = s.ProfileImage?`<img src="${s.ProfileImage}" alt=""/>`:init;
    html+=`<tr>
      <td style="color:var(--tm);font-size:11px;">${skip+i+1}</td>
      <td>
        <div style="display:flex;align-items:center;gap:8px;">
          <div class="sav">${img}</div>
          <div><div class="sname">${esc(s.FullName||'')}</div>
            <div class="sroll">${esc(s.Gender||'')}</div></div>
        </div>
      </td>
      <td style="font-size:12px;font-weight:600;">${esc(s.RollNumber||'—')}</td>
      <td style="font-size:12px;">${esc(s.CourseName||'—')}</td>
      <td style="font-size:12px;">${esc(s.SectionName||'—')}</td>
      <td style="font-size:12px;">${esc(s.Gender||'—')}</td>
      <td style="font-size:12px;font-weight:600;">${s.Total||0}</td>
      <td style="font-size:12px;color:var(--g);font-weight:600;">${s.Present||0}</td>
      <td style="font-size:12px;color:var(--r);font-weight:600;">${s.Absent||0}</td>
      <td>
        <div class="att-bar-wrap">
          <div class="att-bar-bg"><div class="att-bar-fg" style="width:${att}%;background:${col};"></div></div>
          <span class="att-pct-lbl" style="color:${col};">${att}%</span>
        </div>
      </td>
      <td><span class="cat-pill ${catCls}">${esc(s.AttCategory||'—')}</span></td>
    </tr>`;
  });
  tbody.innerHTML=html;

  pagI.innerText=`Showing ${skip+1}–${Math.min(skip+d.pageSize,d.totalCount)} of ${d.totalCount}`;
  let btns=`<button class="pbtn" onclick="applyFilters(${curPage-1})" ${curPage===0?'disabled':''}>
    <i class="fa fa-chevron-left"></i></button>`;
  const st=Math.max(0,curPage-2), en=Math.min(totPages-1,st+4);
  for(let p=st;p<=en;p++)
    btns+=`<button class="pbtn ${p===curPage?'act':''}" onclick="applyFilters(${p})">${p+1}</button>`;
  btns+=`<button class="pbtn" onclick="applyFilters(${curPage+1})" ${curPage>=totPages-1?'disabled':''}>
    <i class="fa fa-chevron-right"></i></button>`;
  pagB.innerHTML=btns;
}

/* ═══════════════════════════════════════════════════════
   DEFAULTERS
═══════════════════════════════════════════════════════ */
function renderDefaulters(data){
  const list=document.getElementById('defList');
  const bars=document.getElementById('defBars');
  if(!list) return;

  if(!data?.length){
    list.innerHTML="<div class='empty' style='padding:60px;'><i class='fa fa-circle-check' style='color:var(--g);opacity:1;font-size:36px;'></i><p style='color:var(--g);font-weight:700;margin-top:8px;'>No defaulters! All students above threshold.</p></div>";
    if(bars) bars.innerHTML='';
    return;
  }

  let html='';
  data.forEach(s=>{
    const att=parseFloat(s.AttPct)||0;
    const col=att<50?'#ef4444':att<65?'#ea580c':'#f59e0b';
    const init=(s.FullName||'?').substring(0,1).toUpperCase();
    const img=s.ProfileImage?`<img src="${s.ProfileImage}" alt=""/>`:init;
    html+=`<div class="def-item">
      <div class="sav" style="background:var(--rl);color:var(--r);">${img}</div>
      <div class="def-bar-wrap">
        <div style="display:flex;justify-content:space-between;font-size:12px;margin-bottom:3px;">
          <span style="font-weight:700;">${esc(s.FullName||'')}</span>
          <span style="color:var(--ts);font-size:11px;">${esc(s.CourseName||'—')} · ${esc(s.SectionName||'—')}</span>
        </div>
        <div class="def-bar-bg">
          <div class="def-bar-fg" data-w="${att}%" style="background:${col};"></div>
        </div>
        <div style="font-size:10px;color:var(--ts);margin-top:2px;">
          Present: ${s.Present||0} / ${s.Total||0} days
        </div>
      </div>
      <div class="def-pct" style="color:${col};">${att}%</div>
    </div>`;
  });
  list.innerHTML=html;
  setTimeout(()=>list.querySelectorAll('.def-bar-fg[data-w]').forEach(el=>el.style.width=el.dataset.w),300);

  // Progress bars tab
  if(bars){
    bars.innerHTML='';
    data.forEach((s,i)=>{
      const att=parseFloat(s.AttPct)||0;
      const col=att<50?'#ef4444':att<65?'#ea580c':'#f59e0b';
      const nm=(s.FullName||'').length>22?s.FullName.substring(0,21)+'…':s.FullName;
      bars.innerHTML+=`<div class="pi">
        <div class="pi-lbl"><span title="${s.FullName}">${nm}</span>
          <span style="color:${col};font-weight:700;">${att}%</span></div>
        <div class="pi-track"><div class="pi-fill" data-w="${att}%" style="background:${col};"></div></div></div>`;
    });
    setTimeout(()=>bars.querySelectorAll('.pi-fill[data-w]').forEach(el=>el.style.width=el.dataset.w),400);
  }
}

/* ═══════════════════════════════════════════════════════
   HEATMAP
═══════════════════════════════════════════════════════ */
function renderHeatmap(data){
  const wrap=document.getElementById('heatmapContainer'); if(!wrap) return;
  wrap.innerHTML='';
  if(!data?.length){ wrap.innerHTML="<div class='empty'><i class='fa fa-table-cells'></i><p>No heatmap data for selected range</p></div>"; return; }

  // Build month × day matrix
  const months=['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
  const days  =['Sun','Mon','Tue','Wed','Thu','Fri','Sat'];
  const PRESENT_MONTHS = [...new Set(data.map(r=>r.MonNum))].sort((a,b)=>a-b);

  const outer=document.createElement('div');
  outer.style.cssText='display:flex;gap:18px;flex-wrap:wrap;';

  PRESENT_MONTHS.forEach(mon=>{
    const monRows=data.filter(r=>r.MonNum==mon);
    const block=document.createElement('div');
    block.style.cssText='display:flex;flex-direction:column;gap:4px;';

    const lbl=document.createElement('div');
    lbl.className='hm-label';
    lbl.style.cssText='margin-bottom:4px;font-weight:700;font-size:12px;color:var(--ts);text-align:center;';
    lbl.innerText=months[mon-1];
    block.appendChild(lbl);

    days.forEach((d,di)=>{
      const row=monRows.find(r=>parseInt(r.DayIdx)===di);
      const pct=row?parseFloat(row.AttPct)||0:null;
      const cell=document.createElement('div');
      cell.className='hm-cell';
      cell.style.cssText=`display:inline-block;`;

      if(pct===null){
        cell.style.background='var(--bd)';
        cell.title=`${d} ${months[mon-1]}: No data`;
      } else {
        const green=pct>=90?'#059669':pct>=75?'#10b981':pct>=60?'#6ee7b7':pct>=40?'#fde68a':'#fca5a5';
        cell.style.background=green;
        cell.title=`${d} ${months[mon-1]}: ${pct}%`;
      }

      const row2=document.createElement('div');
      row2.style.cssText='display:flex;align-items:center;gap:5px;';
      const dlbl=document.createElement('span');
      dlbl.style.cssText='font-size:9px;color:var(--tm);width:22px;flex-shrink:0;';
      dlbl.innerText=d;
      row2.appendChild(dlbl);
      row2.appendChild(cell);
      block.appendChild(row2);
    });
    outer.appendChild(block);
  });
  wrap.appendChild(outer);

  // Legend
  const leg=document.getElementById('hmLegBar'); if(!leg) return;
  leg.innerHTML='';
  ['#fca5a5','#fde68a','#6ee7b7','#10b981','#059669'].forEach(c=>{
    const d=document.createElement('div');
    d.className='hm-legend-cell';
    d.style.background=c;
    leg.appendChild(d);
  });
}

/* ═══════════════════════════════════════════════════════
   TABS
═══════════════════════════════════════════════════════ */
window.switchTab=function(name,btn){
  document.querySelectorAll('.tab-pane').forEach(p=>p.classList.remove('active'));
  document.querySelectorAll('.tab-btn').forEach(b=>b.classList.remove('active'));
  document.getElementById('tab-'+name)?.classList.add('active');
  btn.classList.add('active');
};

/* ═══════════════════════════════════════════════════════
   CSV EXPORT
═══════════════════════════════════════════════════════ */
window.exportCSV=function(){
  if(!lastData?.students?.length){ alert('No student data to export'); return; }
  const H=['Name','Roll','Course','Section','Gender','Total','Present','Absent','Leave','Att%','Category'];
  const R=lastData.students.map(s=>[
    s.FullName,s.RollNumber,s.CourseName,s.SectionName,s.Gender,
    s.Total,s.Present,s.Absent,s.OnLeave,s.AttPct,s.AttCategory
  ].map(v=>`"${(v||'').toString().replace(/"/g,'""')}"`));
  const csv=[H,...R].map(r=>r.join(',')).join('\n');
  const a=document.createElement('a');
  a.href='data:text/csv;charset=utf-8,'+encodeURIComponent(csv);
  a.download=`attendance_${new Date().toISOString().slice(0,10)}.csv`;
  a.click();
};

/* ═══════════════════════════════════════════════════════
   UTILITY
═══════════════════════════════════════════════════════ */
function esc(s){ return String(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }

/* live search */
document.getElementById('fSearch').addEventListener('input',function(){
  clearTimeout(debT); debT=setTimeout(()=>applyFilters(0),450);
});

/* ═══════════════════════════════════════════════════════
   INIT — copy server-rendered ASP dropdown options
═══════════════════════════════════════════════════════ */
(function(){
  const map={
    '<%= ddlStream.ClientID %>':  'fStream',
    '<%= ddlCourse.ClientID %>':  'fCourse',
    '<%= ddlSection.ClientID %>': 'fSection',
    '<%= ddlSubject.ClientID %>': 'fSubject'
  };
  Object.keys(map).forEach(aspId=>{
    const asp=document.getElementById(aspId);
    const js =document.getElementById(map[aspId]);
    if(!asp||!js) return;
    Array.from(asp.options).forEach(o=>{
      if(!o.value||o.value==='0') return;
      if(js.querySelector(`option[value="${o.value}"]`)) return;
      const n=document.createElement('option');
      n.value=o.value; n.text=o.text; js.appendChild(n);
    });
  });
  applyFilters(0);
})();

})();
</script>
</asp:Content>
