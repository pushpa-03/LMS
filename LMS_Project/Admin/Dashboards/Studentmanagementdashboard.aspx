<%@ Page Title="Student Management Dashboard" Language="C#"
    MasterPageFile="~/Admin/AdminMaster.Master"
    AutoEventWireup="true"
    CodeBehind="Studentmanagementdashboard.aspx.cs"
    Inherits="LearningManagementSystem.Admin.StudentManagementDashboard" %>

<asp:Content ID="cHead" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet"/>
<style>
/* ══════════════════ TOKENS ══════════════════ */
:root{
  --p:#4f46e5;--pl:#ede9fe;--pd:#3730a3;
  --g:#10b981;--gl:#d1fae5;
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
  --sh:0 1px 3px rgba(0,0,0,.07),0 1px 2px rgba(0,0,0,.05);
  --shm:0 4px 16px rgba(0,0,0,.09);
  --shl:0 8px 30px rgba(0,0,0,.12);
}
*{box-sizing:border-box;margin:0;padding:0;}
body{background:var(--pg);font-family:'Inter','Segoe UI',system-ui,sans-serif;color:var(--tx);font-size:14px;}
.wrap{padding:22px;}

/* ── Alert ── */
.dash-alert{display:flex;align-items:center;gap:10px;padding:12px 18px;border-radius:var(--rads);
  font-size:13px;font-weight:500;margin-bottom:16px;animation:fadeD .3s ease;}
@keyframes fadeD{from{opacity:0;transform:translateY(-6px)}to{opacity:1;transform:none}}
.alert-success{background:var(--gl);color:#065f46;border-left:3px solid var(--g);}
.alert-danger {background:var(--rl);color:#991b1b;border-left:3px solid var(--r);}
.alert-warning{background:var(--wl);color:#92400e;border-left:3px solid var(--w);}
.alert-info   {background:var(--bl);color:#1e40af;border-left:3px solid var(--b);}

/* ── Top bar ── */
.topbar{display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:14px;margin-bottom:20px;}
.tb-left h1{font-size:21px;font-weight:800;display:flex;align-items:center;gap:10px;}
.tb-ico{width:38px;height:38px;background:var(--bl);color:var(--b);border-radius:11px;
  display:flex;align-items:center;justify-content:center;font-size:16px;flex-shrink:0;}
.tb-left p{font-size:13px;color:var(--ts);margin-top:3px;padding-left:48px;}
.tb-right{display:flex;align-items:center;gap:8px;flex-wrap:wrap;}
.sess-pill{background:var(--pl);color:var(--p);padding:6px 14px;border-radius:20px;
  font-size:12px;font-weight:700;display:inline-flex;align-items:center;gap:6px;}
.btn-export{padding:8px 18px;background:var(--g);color:#fff;border:none;border-radius:var(--rads);
  font-size:12px;font-weight:700;cursor:pointer;display:inline-flex;align-items:center;gap:6px;transition:.2s;}
.btn-export:hover{background:var(--t);transform:translateY(-1px);}

/* ── FILTER BAR ── */
.filter-bar{
  background:var(--bg);border:1px solid var(--bd);border-radius:var(--rad);
  padding:16px 20px;margin-bottom:20px;box-shadow:var(--sh);
}
.filter-bar-top{display:flex;align-items:center;justify-content:space-between;
  flex-wrap:wrap;gap:10px;margin-bottom:14px;}
.filter-label{font-size:12px;font-weight:700;color:var(--ts);text-transform:uppercase;
  letter-spacing:.05em;display:flex;align-items:center;gap:6px;}
.filter-actions{display:flex;gap:8px;}
.btn-apply{padding:7px 20px;background:var(--p);color:#fff;border:none;border-radius:var(--rads);
  font-size:12px;font-weight:700;cursor:pointer;transition:.2s;}
.btn-apply:hover{background:var(--pd);}
.btn-reset{padding:7px 16px;background:var(--pg);color:var(--ts);border:1px solid var(--bd);
  border-radius:var(--rads);font-size:12px;font-weight:600;cursor:pointer;transition:.2s;}
.btn-reset:hover{background:var(--bd);}
.filter-row{display:flex;flex-wrap:wrap;gap:10px;align-items:flex-end;}
.f-group{display:flex;flex-direction:column;gap:4px;min-width:140px;flex:1;}
.f-group label{font-size:11px;font-weight:600;color:var(--ts);}
.f-sel,.f-inp{
  padding:8px 10px;border:1.5px solid var(--bd);border-radius:var(--rads);
  font-size:13px;color:var(--tx);background:#fff;transition:border .2s;width:100%;
}
.f-sel:focus,.f-inp:focus{border-color:var(--p);outline:none;box-shadow:0 0 0 3px rgba(79,70,229,.1);}
.search-wrap{position:relative;flex:2;min-width:200px;}
.search-wrap i{position:absolute;left:10px;top:50%;transform:translateY(-50%);color:var(--tm);font-size:13px;}
.f-search{padding-left:32px !important;}
.loading-bar{
  height:3px;background:linear-gradient(90deg,var(--p),var(--pu),var(--b));
  width:0%;border-radius:2px;transition:width .4s;margin-top:10px;
}
.active-filters{display:flex;flex-wrap:wrap;gap:6px;margin-top:10px;}
.af-chip{
  background:var(--pl);color:var(--p);padding:3px 10px;border-radius:99px;
  font-size:11px;font-weight:600;display:inline-flex;align-items:center;gap:5px;cursor:pointer;
}
.af-chip i{font-size:10px;opacity:.7;}
.af-chip:hover{background:var(--bl);color:var(--b);}

/* ── KPI GRID ── */
.kpi-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(150px,1fr));gap:12px;margin-bottom:20px;}
.kpi{background:var(--bg);border:1px solid var(--bd);border-radius:var(--rad);padding:16px;
  box-shadow:var(--sh);position:relative;overflow:hidden;transition:transform .18s,box-shadow .18s;}
.kpi:hover{transform:translateY(-3px);box-shadow:var(--shm);}
.kpi::before{content:'';position:absolute;top:0;left:0;right:0;height:3px;border-radius:var(--rad) var(--rad) 0 0;}
.kc-b::before{background:var(--b);}   .kc-g::before{background:var(--g);}
.kc-pu::before{background:var(--pu);} .kc-w::before{background:var(--w);}
.kc-t::before{background:var(--t);}   .kc-ro::before{background:var(--ro);}
.kc-r::before{background:var(--r);}   .kc-or::before{background:var(--or);}
.kpi-top{display:flex;align-items:center;justify-content:space-between;margin-bottom:10px;}
.kpi-lbl{font-size:10px;font-weight:700;color:var(--ts);text-transform:uppercase;letter-spacing:.06em;}
.kpi-ico{width:38px;height:38px;border-radius:10px;display:flex;align-items:center;justify-content:center;font-size:16px;}
.ib {background:var(--bl);color:var(--b);}  .ig {background:var(--gl);color:var(--g);}
.ipu{background:var(--pul);color:var(--pu);} .iw {background:var(--wl);color:var(--w);}
.it {background:var(--tl);color:var(--t);}  .iro{background:var(--rol);color:var(--ro);}
.ir {background:var(--rl);color:var(--r);}  .ior{background:var(--orl);color:var(--or);}
.kpi-val{font-size:26px;font-weight:900;color:var(--tx);line-height:1;
  transition:all .4s;letter-spacing:-.5px;}
.kpi-sub{font-size:11px;color:var(--tm);margin-top:4px;}
.kpi-shimmer .kpi-val{background:var(--bd);border-radius:4px;color:transparent;animation:shimmer 1.2s infinite;}
@keyframes shimmer{0%,100%{opacity:.5}50%{opacity:1}}

/* ── Card ── */
.card{background:var(--bg);border:1px solid var(--bd);border-radius:var(--rad);
  box-shadow:var(--sh);padding:20px;transition:box-shadow .18s;}
.card:hover{box-shadow:var(--shm);}
.card-hd{display:flex;align-items:flex-start;justify-content:space-between;margin-bottom:16px;gap:8px;flex-wrap:wrap;}
.card-hd-l{display:flex;align-items:center;gap:10px;}
.c-ico{width:32px;height:32px;border-radius:9px;display:flex;align-items:center;justify-content:center;font-size:14px;flex-shrink:0;}
.c-title{font-size:14px;font-weight:700;color:var(--tx);}
.c-sub{font-size:12px;color:var(--ts);margin-top:1px;}
.chart-box{position:relative;width:100%;}
.g2 {display:grid;grid-template-columns:1fr 1fr;gap:16px;margin-bottom:18px;}
.g3 {display:grid;grid-template-columns:1fr 1fr 1fr;gap:16px;margin-bottom:18px;}
.g21{display:grid;grid-template-columns:2fr 1fr;gap:16px;margin-bottom:18px;}
.g12{display:grid;grid-template-columns:1fr 2fr;gap:16px;margin-bottom:18px;}

/* ── Tabs ── */
.tab-bar{display:flex;gap:2px;background:var(--pg);border-radius:10px;padding:4px;
  margin-bottom:18px;flex-wrap:wrap;}
.tab-btn{padding:8px 18px;border:none;background:transparent;border-radius:8px;
  font-size:13px;font-weight:600;color:var(--ts);cursor:pointer;transition:.18s;
  display:flex;align-items:center;gap:6px;white-space:nowrap;}
.tab-btn.active{background:var(--bg);color:var(--p);box-shadow:var(--sh);}
.tab-btn:hover:not(.active){background:rgba(255,255,255,.6);color:var(--tx);}
.tab-pane{display:none;} .tab-pane.active{display:block;}

/* ── Student Table ── */
.tbl-wrap{overflow-x:auto;}
.stbl{width:100%;border-collapse:collapse;font-size:13px;min-width:900px;}
.stbl th{font-size:10px;font-weight:700;color:var(--ts);text-transform:uppercase;
  letter-spacing:.05em;padding:10px 12px;border-bottom:2px solid var(--bd);
  text-align:left;white-space:nowrap;cursor:pointer;user-select:none;}
.stbl th:hover{color:var(--p);}
.stbl th.sorted{color:var(--p);}
.stbl td{padding:11px 12px;border-bottom:1px solid var(--bd);vertical-align:middle;}
.stbl tr:hover td{background:#f7f8ff;}
.stbl tr:last-child td{border-bottom:none;}
.st-av{width:34px;height:34px;border-radius:50%;background:var(--pl);color:var(--p);
  display:flex;align-items:center;justify-content:center;font-size:13px;font-weight:800;
  overflow:hidden;flex-shrink:0;border:2px solid var(--bd);}
.st-av img{width:100%;height:100%;object-fit:cover;}
.st-name{font-weight:600;color:var(--tx);}
.st-roll{font-size:11px;color:var(--tm);}
.status-pill{display:inline-block;padding:2px 10px;border-radius:99px;font-size:11px;font-weight:700;}
.sp-active  {background:var(--gl);color:#065f46;}
.sp-inactive{background:var(--rl);color:#991b1b;}
.sp-new     {background:var(--bl);color:#1d4ed8;}
.att-mini{display:inline-flex;align-items:center;gap:4px;font-size:12px;font-weight:600;}
.att-bar-mini{width:50px;height:5px;background:var(--bd);border-radius:99px;overflow:hidden;display:inline-block;}
.att-fill-mini{height:5px;border-radius:99px;}

/* Pagination */
.pagination{display:flex;align-items:center;gap:6px;justify-content:space-between;
  margin-top:14px;flex-wrap:wrap;}
.pag-info{font-size:12px;color:var(--ts);}
.pag-btns{display:flex;gap:4px;}
.pag-btn{width:32px;height:32px;border:1px solid var(--bd);border-radius:var(--rads);
  background:#fff;color:var(--ts);font-size:12px;font-weight:600;cursor:pointer;
  display:flex;align-items:center;justify-content:center;transition:.15s;}
.pag-btn:hover{border-color:var(--p);color:var(--p);}
.pag-btn.active{background:var(--p);color:#fff;border-color:var(--p);}
.pag-btn:disabled{opacity:.4;cursor:not-allowed;}

/* ── Top students & at-risk ── */
.stu-item{display:flex;align-items:center;gap:12px;padding:10px 0;border-bottom:1px solid var(--bd);}
.stu-item:last-child{border-bottom:none;}
.stu-rank{width:22px;height:22px;border-radius:50%;display:flex;align-items:center;
  justify-content:center;font-size:11px;font-weight:800;flex-shrink:0;}
.r1{background:#fef3c7;color:#b45309;}  .r2{background:#f3f4f6;color:#374151;}
.r3{background:#fde8d8;color:#c05621;}  .rn{background:var(--pg);color:var(--ts);}
.stu-info{flex:1;min-width:0;}
.stu-name{font-size:13px;font-weight:700;color:var(--tx);white-space:nowrap;overflow:hidden;text-overflow:ellipsis;}
.stu-course{font-size:11px;color:var(--ts);}
.stu-right{text-align:right;flex-shrink:0;}
.grade-pill{padding:2px 10px;border-radius:99px;font-size:11px;font-weight:800;}
.ga{background:var(--gl);color:#065f46;}  .gb{background:var(--bl);color:#1d4ed8;}
.gc{background:var(--wl);color:#92400e;}  .gf{background:var(--rl);color:#991b1b;}
.risk-pill{padding:2px 9px;border-radius:99px;font-size:10px;font-weight:700;
  background:var(--rl);color:#991b1b;}

/* ── Progress bars ── */
.pi{margin-bottom:12px;}
.pi-lbl{display:flex;justify-content:space-between;font-size:12px;font-weight:500;color:var(--tx);margin-bottom:4px;}
.pi-track{height:7px;background:var(--bd);border-radius:99px;overflow:hidden;}
.pi-fill{height:7px;border-radius:99px;transition:width 1s ease;width:0%;}

/* ── Empty / Loading ── */
.empty{text-align:center;padding:40px;color:var(--tm);}
.empty i{font-size:32px;display:block;margin-bottom:10px;opacity:.4;}
.loading-spin{display:inline-block;width:20px;height:20px;border:2px solid var(--bd);
  border-top-color:var(--p);border-radius:50%;animation:spin .7s linear infinite;}
@keyframes spin{to{transform:rotate(360deg)}}

/* Count-up animation */
.count-up{transition:all .5s cubic-bezier(.4,0,.2,1);}

/* Responsive */
@media(max-width:1100px){.g21,.g12{grid-template-columns:1fr;}.g3{grid-template-columns:1fr 1fr;}}
@media(max-width:700px) {.g2,.g3{grid-template-columns:1fr;}.kpi-grid{grid-template-columns:1fr 1fr 1fr;}}
@media(max-width:480px) {.kpi-grid{grid-template-columns:1fr 1fr;}.tab-btn{font-size:12px;padding:7px 12px;}}
</style>
</asp:Content>

<asp:Content ID="cBody" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

<%-- Server config passed to JS --%>
<asp:HiddenField ID="hdnInstId" runat="server"/>
<asp:HiddenField ID="hdnSessId" runat="server"/>
<asp:HiddenField ID="hdnPage"   runat="server" Value="0"/>

<%-- ASP controls (used for dropdown init only; actual filtering via AJAX) --%>
<asp:DropDownList ID="ddlStream"   runat="server" Style="display:none;"/>
<asp:DropDownList ID="ddlCourse"   runat="server" Style="display:none;"/>
<asp:DropDownList ID="ddlSemester" runat="server" Style="display:none;"/>
<asp:DropDownList ID="ddlSection"  runat="server" Style="display:none;"/>
<asp:DropDownList ID="ddlGender"   runat="server" Style="display:none;"/>
<asp:DropDownList ID="ddlMonth"    runat="server" Style="display:none;"/>
<asp:DropDownList ID="ddlYear"     runat="server" Style="display:none;"/>
<asp:TextBox      ID="txtSearch"   runat="server" Style="display:none;"/>
<asp:Label        ID="lblSessionName" runat="server" Style="display:none;"/>

<div class="wrap">

<%-- TOP BAR --%>
<div class="topbar">
  <div class="tb-left">
    <h1><span class="tb-ico"><i class="fa fa-users"></i></span>Student Management</h1>
    <p>Live analytics &amp; student records &mdash; Session:
      <strong id="sessLabel"></strong>
    </p>
  </div>
  <div class="tb-right">
    <span class="sess-pill"><i class="fa fa-calendar-check"></i><span id="sessLabel2"></span></span>
    <button class="btn-export" onclick="exportCSV()">
      <i class="fa fa-file-csv"></i>Export CSV
    </button>
    <div class="loading-spin" id="globalSpinner" style="display:none;"></div>
  </div>
</div>

<%-- FILTER BAR --%>
<div class="filter-bar">
  <div class="filter-bar-top">
    <div class="filter-label"><i class="fa fa-filter"></i>Filters</div>
    <div class="filter-actions">
      <button class="btn-reset" onclick="resetFilters()"><i class="fa fa-rotate"></i> Reset</button>
      <button class="btn-apply" onclick="applyFilters(0)"><i class="fa fa-magnifying-glass"></i> Search</button>
    </div>
  </div>
  <div class="filter-row">
    <div class="f-group">
      <label>Stream</label>
      <select id="fStream" class="f-sel" onchange="onStreamChange()">
        <option value="0">All Streams</option>
      </select>
    </div>
    <div class="f-group">
      <label>Course</label>
      <select id="fCourse" class="f-sel">
        <option value="0">All Courses</option>
      </select>
    </div>
    <div class="f-group">
      <label>Semester</label>
      <select id="fSemester" class="f-sel">
        <option value="0">All Semesters</option>
      </select>
    </div>
    <div class="f-group">
      <label>Section</label>
      <select id="fSection" class="f-sel">
        <option value="0">All Sections</option>
      </select>
    </div>
    <div class="f-group">
      <label>Gender</label>
      <select id="fGender" class="f-sel">
        <option value="">All</option>
        <option value="Male">Male</option>
        <option value="Female">Female</option>
        <option value="Other">Other</option>
      </select>
    </div>
    <div class="f-group">
      <label>Join Month</label>
      <select id="fMonth" class="f-sel">
        <option value="">All Months</option>
        <option value="1">January</option> <option value="2">February</option>
        <option value="3">March</option>   <option value="4">April</option>
        <option value="5">May</option>     <option value="6">June</option>
        <option value="7">July</option>    <option value="8">August</option>
        <option value="9">September</option><option value="10">October</option>
        <option value="11">November</option><option value="12">December</option>
      </select>
    </div>
    <div class="f-group">
      <label>Year</label>
      <select id="fYear" class="f-sel">
        <option value="">All Years</option>
      </select>
    </div>
    <div class="f-group search-wrap" style="flex:2;">
      <label>Search</label>
      <div style="position:relative;">
        <i class="fa fa-magnifying-glass" style="position:absolute;left:10px;top:50%;transform:translateY(-50%);color:var(--tm);font-size:13px;z-index:1;"></i>
        <input id="fSearch" class="f-sel" style="padding-left:32px;"
               type="text" placeholder="Name, Roll No, Contact..."
               onkeydown="if(event.key==='Enter')applyFilters(0)"/>
      </div>
    </div>
  </div>
  <div class="loading-bar" id="loadBar"></div>
  <div class="active-filters" id="activeFilters"></div>
</div>

<%-- KPI CARDS --%>
<div class="kpi-grid">
  <div class="kpi kc-b">
    <div class="kpi-top"><span class="kpi-lbl">Total Students</span><div class="kpi-ico ib"><i class="fa fa-users"></i></div></div>
    <div class="kpi-val count-up" id="kTotal">—</div>
    <div class="kpi-sub" id="kTotalSub">Enrolled this session</div>
  </div>
  <div class="kpi kc-g">
    <div class="kpi-top"><span class="kpi-lbl">Active</span><div class="kpi-ico ig"><i class="fa fa-circle-check"></i></div></div>
    <div class="kpi-val count-up" id="kActive">—</div>
    <div class="kpi-sub">Currently active</div>
  </div>
  <div class="kpi kc-r">
    <div class="kpi-top"><span class="kpi-lbl">Inactive</span><div class="kpi-ico ir"><i class="fa fa-circle-xmark"></i></div></div>
    <div class="kpi-val count-up" id="kInactive">—</div>
    <div class="kpi-sub">Deactivated accounts</div>
  </div>
  <div class="kpi kc-pu">
    <div class="kpi-top"><span class="kpi-lbl">New Admissions</span><div class="kpi-ico ipu"><i class="fa fa-user-plus"></i></div></div>
    <div class="kpi-val count-up" id="kNew">—</div>
    <div class="kpi-sub">First login pending</div>
  </div>
  <div class="kpi kc-t">
    <div class="kpi-top"><span class="kpi-lbl">Attendance</span><div class="kpi-ico it"><i class="fa fa-calendar-check"></i></div></div>
    <div class="kpi-val count-up" id="kAtt">—</div>
    <div class="kpi-sub">Session average</div>
  </div>
  <div class="kpi kc-w">
    <div class="kpi-top"><span class="kpi-lbl">Assign. Rate</span><div class="kpi-ico iw"><i class="fa fa-clipboard-check"></i></div></div>
    <div class="kpi-val count-up" id="kAssign">—</div>
    <div class="kpi-sub">Submission rate</div>
  </div>
  <div class="kpi kc-or">
    <div class="kpi-top"><span class="kpi-lbl">Avg Quiz</span><div class="kpi-ico ior"><i class="fa fa-chart-simple"></i></div></div>
    <div class="kpi-val count-up" id="kQuiz">—</div>
    <div class="kpi-sub">Quiz score average</div>
  </div>
  <div class="kpi kc-ro">
    <div class="kpi-top"><span class="kpi-lbl">Gender Split</span><div class="kpi-ico iro"><i class="fa fa-venus-mars"></i></div></div>
    <div class="kpi-val count-up" id="kGender">—</div>
    <div class="kpi-sub" id="kGenderSub">M / F / Other</div>
  </div>
</div>

<%-- TABS --%>
<div class="tab-bar">
  <button class="tab-btn active" onclick="switchTab('overview',this)">
    <i class="fa fa-chart-pie"></i>Overview
  </button>
  <button class="tab-btn" onclick="switchTab('students',this)">
    <i class="fa fa-users"></i>Student Records
  </button>
  <button class="tab-btn" onclick="switchTab('performance',this)">
    <i class="fa fa-trophy"></i>Performance
  </button>
  <button class="tab-btn" onclick="switchTab('atrisk',this)">
    <i class="fa fa-triangle-exclamation"></i>At-Risk
  </button>
</div>

<%-- ══════ TAB: OVERVIEW ══════ --%>
<div id="tab-overview" class="tab-pane active">

  <%-- Row 1: Enrollment trend + Attendance trend --%>
  <div class="g21">
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="c-ico" style="background:var(--pl);color:var(--p);"><i class="fa fa-arrow-trend-up"></i></div>
          <div><div class="c-title">Monthly Enrollment — Last 12 Months</div>
            <div class="c-sub">New vs active students per month</div></div>
        </div>
        <span id="enrollTotal" style="font-size:11px;color:var(--tm);"></span>
      </div>
      <div class="chart-box" style="height:250px;"><canvas id="chartEnroll"></canvas></div>
    </div>
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="c-ico" style="background:var(--gl);color:var(--g);"><i class="fa fa-calendar-day"></i></div>
          <div><div class="c-title">Attendance — Last 30 Days</div>
            <div class="c-sub">Daily % trend</div></div>
        </div>
      </div>
      <div class="chart-box" style="height:250px;"><canvas id="chartAtt"></canvas></div>
    </div>
  </div>

  <%-- Row 2: Stream, Course, Gender, Grades --%>
  <div class="g2">
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="c-ico" style="background:var(--pul);color:var(--pu);"><i class="fa fa-layer-group"></i></div>
          <div><div class="c-title">Students by Stream</div></div>
        </div>
      </div>
      <div class="chart-box" style="height:220px;"><canvas id="chartStream"></canvas></div>
    </div>
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="c-ico" style="background:var(--cyl);color:var(--cy);"><i class="fa fa-graduation-cap"></i></div>
          <div><div class="c-title">Students by Course</div></div>
        </div>
      </div>
      <div class="chart-box" style="height:220px;"><canvas id="chartCourse"></canvas></div>
    </div>
  </div>

  <div class="g3">
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="c-ico" style="background:var(--rol);color:var(--ro);"><i class="fa fa-venus-mars"></i></div>
          <div><div class="c-title">Gender Distribution</div></div>
        </div>
      </div>
      <div class="chart-box" style="height:180px;"><canvas id="chartGender"></canvas></div>
      <div id="genderLeg" style="display:flex;flex-wrap:wrap;gap:6px;justify-content:center;margin-top:8px;"></div>
    </div>
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="c-ico" style="background:var(--tl);color:var(--t);"><i class="fa fa-chart-pie"></i></div>
          <div><div class="c-title">Grade Distribution</div></div>
        </div>
      </div>
      <div class="chart-box" style="height:180px;"><canvas id="chartGrades"></canvas></div>
    </div>
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="c-ico" style="background:var(--bl);color:var(--b);"><i class="fa fa-sitemap"></i></div>
          <div><div class="c-title">Students by Section</div></div>
        </div>
      </div>
      <div class="chart-box" style="height:180px;"><canvas id="chartSection"></canvas></div>
    </div>
  </div>

  <%-- Admissions by month bar --%>
  <div class="card" style="margin-bottom:18px;">
    <div class="card-hd">
      <div class="card-hd-l">
        <div class="c-ico" style="background:var(--wl);color:var(--w);"><i class="fa fa-user-plus"></i></div>
        <div><div class="c-title">New Admissions by Month</div>
          <div class="c-sub">Students who joined each month</div></div>
      </div>
    </div>
    <div class="chart-box" style="height:200px;"><canvas id="chartAdm"></canvas></div>
  </div>

</div>

<%-- ══════ TAB: STUDENT RECORDS ══════ --%>
<div id="tab-students" class="tab-pane">
  <div class="card">
    <div class="card-hd">
      <div class="card-hd-l">
        <div class="c-ico" style="background:var(--bl);color:var(--b);"><i class="fa fa-table"></i></div>
        <div>
          <div class="c-title">Student Records</div>
          <div class="c-sub" id="recordsCount">Loading…</div>
        </div>
      </div>
      <div style="display:flex;align-items:center;gap:8px;">
        <span style="font-size:12px;color:var(--ts);">Sort by:</span>
        <select id="sortBy" class="f-sel" style="width:130px;padding:6px 10px;"
                onchange="applyFilters(0)">
          <option value="name">Name</option>
          <option value="att">Attendance</option>
          <option value="score">Score</option>
        </select>
      </div>
    </div>
    <div class="tbl-wrap">
      <table class="stbl" id="studentTable">
        <thead>
          <tr>
            <th>#</th>
            <th>Student</th>
            <th>Roll No</th>
            <th>Stream / Course</th>
            <th>Semester</th>
            <th>Section</th>
            <th>Gender</th>
            <th>Joined</th>
            <th>Attendance</th>
            <th>Avg Score</th>
            <th>Submissions</th>
            <th>Status</th>
          </tr>
        </thead>
        <tbody id="studentTbody">
          <tr><td colspan="12" class="empty"><div class="loading-spin"></div></td></tr>
        </tbody>
      </table>
    </div>
    <div class="pagination">
      <div class="pag-info" id="pagInfo"></div>
      <div class="pag-btns" id="pagBtns"></div>
    </div>
  </div>
</div>

<%-- ══════ TAB: PERFORMANCE ══════ --%>
<div id="tab-performance" class="tab-pane">
  <div class="g12">
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="c-ico" style="background:var(--wl);color:var(--w);"><i class="fa fa-medal"></i></div>
          <div><div class="c-title">Top 10 Students</div>
            <div class="c-sub">By avg quiz score + attendance</div></div>
        </div>
      </div>
      <div id="topStudentsList"><div class="empty"><div class="loading-spin"></div></div></div>
    </div>
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="c-ico" style="background:var(--tl);color:var(--t);"><i class="fa fa-chart-radar"></i></div>
          <div><div class="c-title">Grade Distribution</div>
            <div class="c-sub">Student count per grade bracket</div></div>
        </div>
      </div>
      <div class="chart-box" style="height:300px;"><canvas id="chartGradesPerf"></canvas></div>
      <div class="card-hd" style="margin-top:16px;margin-bottom:8px;">
        <div class="c-title" style="font-size:13px;">Attendance Breakdown</div>
      </div>
      <div id="sectionBars"></div>
    </div>
  </div>
</div>

<%-- ══════ TAB: AT-RISK ══════ --%>
<div id="tab-atrisk" class="tab-pane">
  <div class="g2">
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="c-ico" style="background:var(--rl);color:var(--r);"><i class="fa fa-triangle-exclamation"></i></div>
          <div><div class="c-title">At-Risk Students</div>
            <div class="c-sub">Attendance &lt;75% or Score &lt;40</div></div>
        </div>
      </div>
      <div id="atRiskList"><div class="empty"><div class="loading-spin"></div></div></div>
    </div>
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="c-ico" style="background:var(--rl);color:var(--r);"><i class="fa fa-chart-bar"></i></div>
          <div><div class="c-title">Risk Analysis</div>
            <div class="c-sub">Attendance vs Performance scatter</div></div>
        </div>
      </div>
      <div class="chart-box" style="height:320px;"><canvas id="chartRisk"></canvas></div>
    </div>
  </div>
</div>

</div><%-- /wrap --%>

<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.4.1/chart.umd.min.js"></script>
<script>
(function () {
'use strict';

/* ════════════════════════════════════════════════════════
   GLOBALS
════════════════════════════════════════════════════════ */
const INST = document.getElementById('<%= hdnInstId.ClientID %>').value;
const SESS = document.getElementById('<%= hdnSessId.ClientID %>').value;
const SESS_NAME = document.getElementById('<%= lblSessionName.ClientID %>').innerText || '';
document.getElementById('sessLabel').innerText  = SESS_NAME;
document.getElementById('sessLabel2').innerText = SESS_NAME;

const PAL   = ['#4f46e5','#10b981','#f59e0b','#ef4444','#8b5cf6','#3b82f6','#0d9488','#f43f5e','#0891b2','#ec4899','#ea580c','#84cc16'];
const GRD   = { color:'rgba(148,163,184,.12)' };
const TICK  = { font:{ size:11, family:"'Inter','Segoe UI',sans-serif" } };
const TT    = { padding:10, cornerRadius:8, bodyFont:{size:12}, titleFont:{size:12,weight:'bold'} };
const ANIM  = { duration:900, easing:'easeInOutQuart' };
const noLeg = { legend:{display:false} };

let charts = {};   // keyed chart instances
let currentPage = 0;
let totalPages  = 1;
let debounceTimer = null;
let lastData = null;

/* ════════════════════════════════════════════════════════
   YEAR DROPDOWN POPULATE
════════════════════════════════════════════════════════ */
(function () {
    const yr = document.getElementById('fYear');
    const cur = new Date().getFullYear();
    for (let y = cur; y >= cur - 5; y--) {
        const o = document.createElement('option');
        o.value = y; o.text = y; yr.appendChild(o);
    }
})();

/* ════════════════════════════════════════════════════════
   FILTER HELPERS
════════════════════════════════════════════════════════ */
function getFilters() {
    return {
        stream:   document.getElementById('fStream').value,
        course:   document.getElementById('fCourse').value,
        semester: document.getElementById('fSemester').value,
        section:  document.getElementById('fSection').value,
        gender:   document.getElementById('fGender').value,
        month:    document.getElementById('fMonth').value,
        year:     document.getElementById('fYear').value,
        search:   document.getElementById('fSearch').value.trim()
    };
}

window.resetFilters = function () {
    ['fStream','fCourse','fSemester','fSection','fGender','fMonth','fYear']
        .forEach(id => document.getElementById(id).value = (id==='fStream'||id==='fCourse'||id==='fSemester'||id==='fSection') ? '0' : '');
    document.getElementById('fSearch').value = '';
    document.getElementById('activeFilters').innerHTML = '';
    applyFilters(0);
};

window.applyFilters = function (page) {
    currentPage = page || 0;
    clearTimeout(debounceTimer);
    debounceTimer = setTimeout(() => fetchData(currentPage), 300);
};

// Stream changes → reload courses
window.onStreamChange = function () {
    const streamId = document.getElementById('fStream').value;
    const url = buildUrl('courses', 0, { stream: streamId });
    fetch(url)
        .then(r => r.json())
        .then(d => {
            const sel = document.getElementById('fCourse');
            sel.innerHTML = '<option value="0">All Courses</option>';
            (d.courses || []).forEach(c => {
                const o = document.createElement('option');
                o.value = c.CourseId; o.text = c.CourseDisplay;
                sel.appendChild(o);
            });
        });
    applyFilters(0);
};

// Build URL for AJAX
function buildUrl(action, page, extra) {
    const f = getFilters();
    let url = `${location.pathname}?ajax=1&action=${action}`
        + `&inst=${INST}&sess=${SESS}`
        + `&stream=${f.stream}&course=${f.course}`
        + `&semester=${f.semester}&section=${f.section}`
        + `&gender=${encodeURIComponent(f.gender)}`
        + `&month=${f.month}&year=${f.year}`
        + `&search=${encodeURIComponent(f.search)}`
        + `&page=${page||0}`;
    if (extra) Object.keys(extra).forEach(k => url += `&${k}=${extra[k]}`);
    return url;
}

/* ════════════════════════════════════════════════════════
   MAIN DATA FETCH
════════════════════════════════════════════════════════ */
function fetchData(page) {
    setLoading(true);
    updateActiveFilterChips();

    fetch(buildUrl('all', page))
        .then(r => { if (!r.ok) throw new Error('Server error ' + r.status); return r.json(); })
        .then(d => {
            lastData = d;
            renderKPIs(d.kpi);
            renderCharts(d);
            renderStudentTable(d);
            renderTopStudents(d.topStudents);
            renderAtRisk(d.atRisk);
            setLoading(false);
        })
        .catch(err => {
            setLoading(false);
            console.error(err);
        });
}

/* ════════════════════════════════════════════════════════
   LOADING STATE
════════════════════════════════════════════════════════ */
function setLoading(on) {
    const bar = document.getElementById('loadBar');
    const sp  = document.getElementById('globalSpinner');
    bar.style.width = on ? '85%' : '100%';
    sp.style.display = on ? 'inline-block' : 'none';
    if (!on) setTimeout(() => bar.style.width = '0%', 600);
}

/* ════════════════════════════════════════════════════════
   ACTIVE FILTER CHIPS
════════════════════════════════════════════════════════ */
function updateActiveFilterChips() {
    const f = getFilters();
    const wrap = document.getElementById('activeFilters');
    wrap.innerHTML = '';
    const selMap = {
        stream: 'fStream', course: 'fCourse', semester: 'fSemester',
        section: 'fSection', gender: 'fGender', month: 'fMonth', year: 'fYear'
    };
    Object.keys(selMap).forEach(k => {
        const el  = document.getElementById(selMap[k]);
        const val = el.value;
        if (!val || val === '0') return;
        const txt = el.options[el.selectedIndex]?.text || val;
        wrap.innerHTML += `<span class="af-chip" onclick="clearFilter('${selMap[k]}')">
            ${txt} <i class="fa fa-xmark"></i></span>`;
    });
    if (f.search) {
        wrap.innerHTML += `<span class="af-chip" onclick="clearFilter('fSearch')">
            "${f.search}" <i class="fa fa-xmark"></i></span>`;
    }
}

window.clearFilter = function (id) {
    const el = document.getElementById(id);
    if (el.tagName === 'SELECT') el.value = (id==='fStream'||id==='fCourse'||id==='fSemester'||id==='fSection') ? '0' : '';
    else el.value = '';
    applyFilters(0);
};

/* ════════════════════════════════════════════════════════
   KPI RENDER — count-up animation
════════════════════════════════════════════════════════ */
function renderKPIs(k) {
    if (!k) return;
    countUp('kTotal',   k.total   || 0);
    countUp('kActive',  k.active  || 0);
    countUp('kInactive',k.inactive|| 0);
    countUp('kNew',     k.newAdm  || 0);
    document.getElementById('kAtt').innerText    = (k.attPct    || 0) + '%';
    document.getElementById('kAssign').innerText = (k.assignRate|| 0) + '%';
    document.getElementById('kQuiz').innerText   = k.avgQuiz    || '0';
    document.getElementById('kGender').innerText = `${k.males||0}/${k.females||0}/${k.others||0}`;
}

function countUp(id, target) {
    const el = document.getElementById(id);
    const start = parseInt(el.innerText) || 0;
    const diff  = target - start;
    const steps = 30;
    let i = 0;
    const iv = setInterval(() => {
        i++;
        el.innerText = Math.round(start + diff * (i / steps));
        if (i >= steps) { el.innerText = target; clearInterval(iv); }
    }, 20);
}

/* ════════════════════════════════════════════════════════
   CHART HELPERS
════════════════════════════════════════════════════════ */
function destroyChart(key) { if (charts[key]) { charts[key].destroy(); charts[key] = null; } }
function gV(ctx, h, c1, c2) {
    const g = ctx.createLinearGradient(0,0,0,h);
    g.addColorStop(0,c1); g.addColorStop(1,c2); return g;
}
function emptyChart(id, msg) {
    const el = document.getElementById(id);
    if (!el) return;
    const box = el.closest('.chart-box');
    if (box) box.innerHTML = `<div class="empty"><i class="fa fa-chart-simple"></i><p>${msg||'No data'}</p></div>`;
}

/* ════════════════════════════════════════════════════════
   ALL CHARTS
════════════════════════════════════════════════════════ */
function renderCharts(d) {
    renderEnrollment(d.enrollment);
    renderAttendance(d.attendance);
    renderStream(d.streamCount);
    renderCourse(d.courseCount);
    renderGender(d.gender);
    renderGrades(d.grades, 'chartGrades');
    renderGrades(d.grades, 'chartGradesPerf');
    renderSection(d.sectionCount);
    renderAdmissions(d.admByMonth);
    renderSectionBars(d.sectionCount);
}

// 1. Enrollment
function renderEnrollment(data) {
    destroyChart('enroll');
    if (!data || !data.length) { emptyChart('chartEnroll','No enrollment data'); return; }
    const el = document.getElementById('chartEnroll');
    if (!el) return;
    const ctx = el.getContext('2d');
    const grad = gV(ctx, 230, 'rgba(79,70,229,.28)', 'rgba(79,70,229,.02)');
    const total = data.reduce((a,b) => a + (b.Students||0), 0);
    document.getElementById('enrollTotal').innerText = total + ' total';
    charts.enroll = new Chart(ctx, {
        type:'line',
        data:{
            labels: data.map(r=>r.Mon),
            datasets:[
                { label:'New Students', data:data.map(r=>r.Students||0),
                  borderColor:'#4f46e5', backgroundColor:grad, borderWidth:2.5,
                  tension:.42, fill:true, pointRadius:4, pointHoverRadius:7,
                  pointBackgroundColor:'#4f46e5', pointHoverBackgroundColor:'#fff',
                  pointHoverBorderColor:'#4f46e5', pointHoverBorderWidth:2 },
                { label:'Active', data:data.map(r=>r.Active||0),
                  borderColor:'#10b981', borderWidth:2, borderDash:[4,4],
                  tension:.42, fill:false, pointRadius:3, pointHoverRadius:6,
                  pointBackgroundColor:'#10b981' }
            ]
        },
        options:{ responsive:true, maintainAspectRatio:false,
            plugins:{ legend:{position:'top',labels:{boxWidth:10,font:{size:11}}}, tooltip:TT },
            scales:{ x:{grid:{display:false},ticks:TICK}, y:{beginAtZero:true,grid:GRD,ticks:TICK} },
            animation:ANIM }
    });
}

// 2. Attendance
function renderAttendance(data) {
    destroyChart('att');
    if (!data || !data.length) { emptyChart('chartAtt','No attendance data'); return; }
    const el = document.getElementById('chartAtt');
    if (!el) return;
    const ctx  = el.getContext('2d');
    const grad = gV(ctx, 230, 'rgba(16,185,129,.25)', 'rgba(16,185,129,.02)');
    charts.att = new Chart(ctx, {
        type:'line',
        data:{
            labels: data.map(r=>r.DayLbl),
            datasets:[{ label:'Attendance %', data:data.map(r=>r.AttPct||0),
                borderColor:'#10b981', backgroundColor:grad, borderWidth:2.5,
                tension:.4, fill:true, pointRadius:3, pointHoverRadius:7,
                pointBackgroundColor:'#10b981', pointHoverBackgroundColor:'#fff',
                pointHoverBorderColor:'#10b981', pointHoverBorderWidth:2 }]
        },
        options:{ responsive:true, maintainAspectRatio:false,
            plugins:{...noLeg, tooltip:{...TT,callbacks:{label:c=>' '+c.raw+'%'}}},
            scales:{ x:{grid:{display:false},ticks:{font:{size:10},maxTicksLimit:10}},
                y:{beginAtZero:true,max:100,grid:GRD,ticks:{...TICK,callback:v=>v+'%'}} },
            animation:ANIM }
    });
}

// 3. Stream horizontal bar
function renderStream(data) {
    destroyChart('stream');
    if (!data || !data.length) { emptyChart('chartStream','No stream data'); return; }
    const el = document.getElementById('chartStream');
    if (!el) return;
    charts.stream = new Chart(el, {
        type:'bar',
        data:{ labels:data.map(r=>r.StreamName),
            datasets:[{ label:'Students', data:data.map(r=>r.Students||0),
                backgroundColor:PAL.map(c=>c+'CC'), borderRadius:6, borderSkipped:false }] },
        options:{ indexAxis:'y', responsive:true, maintainAspectRatio:false,
            plugins:{...noLeg, tooltip:TT},
            scales:{ x:{beginAtZero:true,grid:GRD,ticks:TICK}, y:{grid:{display:false},ticks:{font:{size:11}}} },
            animation:ANIM }
    });
}

// 4. Course bar
function renderCourse(data) {
    destroyChart('course');
    if (!data || !data.length) { emptyChart('chartCourse','No course data'); return; }
    const el = document.getElementById('chartCourse');
    if (!el) return;
    charts.course = new Chart(el, {
        type:'bar',
        data:{ labels:data.map(r=>(r.CourseName||'').length>14?r.CourseName.substring(0,13)+'…':r.CourseName),
            datasets:[{ label:'Students', data:data.map(r=>r.Students||0),
                backgroundColor:PAL.slice(2).map(c=>c+'CC'), borderRadius:6 }] },
        options:{ responsive:true, maintainAspectRatio:false,
            plugins:{...noLeg, tooltip:TT},
            scales:{ x:{grid:{display:false},ticks:{font:{size:10}}}, y:{beginAtZero:true,grid:GRD,ticks:TICK} },
            animation:ANIM }
    });
}

// 5. Gender doughnut
function renderGender(data) {
    destroyChart('gender');
    const leg = document.getElementById('genderLeg');
    leg.innerHTML = '';
    if (!data || !data.length) { emptyChart('chartGender','No gender data'); return; }
    const el = document.getElementById('chartGender');
    if (!el) return;
    const GCOL = ['#4f46e5','#f43f5e','#10b981','#f59e0b'];
    charts.gender = new Chart(el, {
        type:'doughnut',
        data:{ labels:data.map(r=>r.Gender),
            datasets:[{ data:data.map(r=>r.Total||0),
                backgroundColor:GCOL, borderWidth:3, borderColor:'#fff', hoverOffset:10 }] },
        options:{ cutout:'65%', responsive:true, maintainAspectRatio:false,
            plugins:{legend:{display:false},tooltip:TT},
            animation:{animateRotate:true,duration:1100} }
    });
    const tot = data.reduce((a,b)=>a+(b.Total||0),0)||1;
    data.forEach((r,i)=>{
        leg.innerHTML += `<div style="display:flex;align-items:center;gap:5px;font-size:12px;">
            <span style="width:10px;height:10px;border-radius:2px;background:${GCOL[i]};display:inline-block;"></span>
            ${r.Gender} <strong style="color:${GCOL[i]};">${Math.round((r.Total||0)/tot*100)}%</strong></div>`;
    });
}

// 6. Grade distribution doughnut (reused in two tabs)
function renderGrades(data, canvasId) {
    const key = 'grades_'+canvasId;
    destroyChart(key);
    if (!data || !data.length) { emptyChart(canvasId,'No grade data'); return; }
    const el = document.getElementById(canvasId);
    if (!el) return;
    const GCOL = ['#10b981','#3b82f6','#8b5cf6','#f59e0b','#ea580c','#ef4444','#94a3b8'];
    charts[key] = new Chart(el, {
        type:'doughnut',
        data:{ labels:data.map(r=>r.GradeLabel),
            datasets:[{ data:data.map(r=>r.Students||0),
                backgroundColor:GCOL, borderWidth:2, borderColor:'#fff', hoverOffset:8 }] },
        options:{ cutout:'55%', responsive:true, maintainAspectRatio:false,
            plugins:{ legend:{ position:'right', labels:{boxWidth:10,font:{size:11}} }, tooltip:TT },
            animation:{animateRotate:true,duration:1100} }
    });
}

// 7. Section doughnut
function renderSection(data) {
    destroyChart('section');
    if (!data || !data.length) { emptyChart('chartSection','No section data'); return; }
    const el = document.getElementById('chartSection');
    if (!el) return;
    charts.section = new Chart(el, {
        type:'doughnut',
        data:{ labels:data.map(r=>r.SectionName),
            datasets:[{ data:data.map(r=>r.Students||0),
                backgroundColor:PAL, borderWidth:2, borderColor:'#fff', hoverOffset:8 }] },
        options:{ cutout:'55%', responsive:true, maintainAspectRatio:false,
            plugins:{ legend:{position:'right',labels:{boxWidth:10,font:{size:11}}}, tooltip:TT },
            animation:{animateRotate:true,duration:1100} }
    });
}

// 8. Admissions by month bar
function renderAdmissions(data) {
    destroyChart('adm');
    if (!data || !data.length) { emptyChart('chartAdm','No admission data'); return; }
    const el = document.getElementById('chartAdm');
    if (!el) return;
    charts.adm = new Chart(el, {
        type:'bar',
        data:{ labels:data.map(r=>r.Mon),
            datasets:[{ label:'New Admissions', data:data.map(r=>r.Count||0),
                backgroundColor:'rgba(79,70,229,.8)', borderRadius:6 }] },
        options:{ responsive:true, maintainAspectRatio:false,
            plugins:{...noLeg,tooltip:TT},
            scales:{ x:{grid:{display:false},ticks:TICK}, y:{beginAtZero:true,grid:GRD,ticks:TICK} },
            animation:ANIM }
    });
}

// 9. Section progress bars
function renderSectionBars(data) {
    const wrap = document.getElementById('sectionBars');
    if (!wrap) return;
    wrap.innerHTML = '';
    if (!data || !data.length) { wrap.innerHTML="<div class='empty'><i class='fa fa-sitemap'></i><p>No data</p></div>"; return; }
    const max = Math.max(...data.map(r=>r.Students||0)) || 1;
    data.forEach((r,i) => {
        const pct = Math.round((r.Students||0)/max*100);
        wrap.innerHTML += `<div class="pi">
            <div class="pi-lbl"><span>${r.SectionName}</span><span>${r.Students||0} students</span></div>
            <div class="pi-track">
                <div class="pi-fill" data-w="${pct}%" style="background:${PAL[i%PAL.length]};"></div>
            </div></div>`;
    });
    setTimeout(() => document.querySelectorAll('.pi-fill[data-w]').forEach(el => el.style.width=el.dataset.w), 300);
}

/* ════════════════════════════════════════════════════════
   STUDENT TABLE RENDER
════════════════════════════════════════════════════════ */
function renderStudentTable(d) {
    const tbody   = document.getElementById('studentTbody');
    const pagInfo = document.getElementById('pagInfo');
    const pagBtns = document.getElementById('pagBtns');
    const recLbl  = document.getElementById('recordsCount');

    if (!d.students || !d.students.length) {
        tbody.innerHTML = `<tr><td colspan="12"><div class="empty"><i class="fa fa-users"></i><p>No students match the filters</p></div></td></tr>`;
        pagInfo.innerText = ''; pagBtns.innerHTML = '';
        recLbl.innerText = '0 records';
        return;
    }

    totalPages = d.pageCount || 1;
    currentPage = d.pageIndex || 0;
    const skip = currentPage * d.pageSize;
    recLbl.innerText = `${d.totalCount} students found`;

    let html = '';
    d.students.forEach((s,i) => {
        const att    = parseFloat(s.AttPct) || 0;
        const score  = parseFloat(s.AvgScore) || 0;
        const attCol = att >= 75 ? '#10b981' : att >= 60 ? '#f59e0b' : '#ef4444';
        const init   = (s.FullName||'?').substring(0,1).toUpperCase();
        const img    = s.ProfileImage
            ? `<img src="${s.ProfileImage}" alt=""/>`
            : init;
        const grade  = score>=80?'A':score>=60?'B':score>=40?'C':'D';
        const gClass = score>=80?'ga':score>=60?'gb':score>=40?'gc':'gf';

        html += `<tr>
            <td style="color:var(--tm);font-size:11px;">${skip+i+1}</td>
            <td>
                <div style="display:flex;align-items:center;gap:8px;">
                    <div class="st-av">${img}</div>
                    <div>
                        <div class="st-name">${esc(s.FullName||'')}</div>
                        <div class="st-roll">${esc(s.ContactNo||'')}</div>
                    </div>
                </div>
            </td>
            <td style="font-size:12px;font-weight:600;">${esc(s.RollNumber||'—')}</td>
            <td>
                <div style="font-size:12px;font-weight:600;">${esc(s.StreamName||'—')}</div>
                <div style="font-size:11px;color:var(--ts);">${esc(s.CourseName||'—')}</div>
            </td>
            <td style="font-size:12px;">${esc(s.SemesterName||'—')}</td>
            <td style="font-size:12px;">${esc(s.SectionName||'—')}</td>
            <td style="font-size:12px;">${esc(s.Gender||'—')}</td>
            <td style="font-size:12px;color:var(--ts);">${esc(s.JoinedDate||'—')}</td>
            <td>
                <div class="att-mini" style="color:${attCol};">
                    <div class="att-bar-mini">
                        <div class="att-fill-mini" style="width:${att}%;background:${attCol};"></div>
                    </div>
                    ${att}%
                </div>
            </td>
            <td><span class="grade-pill ${gClass}">${grade} ${score}</span></td>
            <td style="font-size:12px;font-weight:600;color:var(--p);">${s.Submissions||0}</td>
            <td>
                <span class="status-pill ${s.Status==='Active'?'sp-active':'sp-inactive'}">${s.Status||'—'}</span>
                ${s.AdmissionType==='New'?'<span class="status-pill sp-new" style="margin-left:4px;">New</span>':''}
            </td>
        </tr>`;
    });
    tbody.innerHTML = html;

    // Pagination
    pagInfo.innerText = `Showing ${skip+1}–${Math.min(skip+d.pageSize, d.totalCount)} of ${d.totalCount}`;
    let btns = `<button class="pag-btn" onclick="applyFilters(${currentPage-1})" ${currentPage===0?'disabled':''}>
        <i class="fa fa-chevron-left"></i></button>`;
    const start = Math.max(0, currentPage-2);
    const end   = Math.min(totalPages-1, start+4);
    for (let p = start; p <= end; p++) {
        btns += `<button class="pag-btn ${p===currentPage?'active':''}" onclick="applyFilters(${p})">${p+1}</button>`;
    }
    btns += `<button class="pag-btn" onclick="applyFilters(${currentPage+1})" ${currentPage>=totalPages-1?'disabled':''}>
        <i class="fa fa-chevron-right"></i></button>`;
    pagBtns.innerHTML = btns;
}

/* ════════════════════════════════════════════════════════
   TOP STUDENTS
════════════════════════════════════════════════════════ */
function renderTopStudents(data) {
    const wrap = document.getElementById('topStudentsList');
    if (!wrap) return;
    if (!data || !data.length) {
        wrap.innerHTML = "<div class='empty'><i class='fa fa-users'></i><p>No data</p></div>";
        return;
    }
    let html = '';
    data.forEach((s,i) => {
        const score  = parseFloat(s.AvgScore)||0;
        const att    = parseFloat(s.AttPct)||0;
        const grade  = score>=80?'A':score>=70?'B+':score>=60?'B':score>=50?'C':'D';
        const gClass = score>=70?'ga':score>=50?'gb':'gc';
        const rank   = i<3 ? `r${i+1}` : 'rn';
        const init   = (s.FullName||'?').substring(0,1).toUpperCase();
        html += `<div class="stu-item">
            <div class="stu-rank ${rank}">${i+1}</div>
            <div class="st-av" style="width:36px;height:36px;">
                ${s.ProfileImage ? `<img src="${s.ProfileImage}" alt=""/>` : init}
            </div>
            <div class="stu-info">
                <div class="stu-name">${esc(s.FullName||'')}</div>
                <div class="stu-course">${esc(s.CourseName||'—')} &bull; ${esc(s.SemesterName||'—')}</div>
            </div>
            <div class="stu-right">
                <span class="grade-pill ${gClass}">${grade} ${score}</span>
                <div style="font-size:10px;color:var(--ts);margin-top:3px;">
                    <i class="fa fa-calendar-check" style="color:var(--g);"></i> ${att}%
                    &nbsp;&bull;&nbsp;${s.Submissions||0} sub.
                </div>
            </div>
        </div>`;
    });
    wrap.innerHTML = html;
}

/* ════════════════════════════════════════════════════════
   AT-RISK STUDENTS
════════════════════════════════════════════════════════ */
function renderAtRisk(data) {
    const wrap = document.getElementById('atRiskList');
    if (!wrap) return;
    if (!data || !data.length) {
        wrap.innerHTML = "<div class='empty' style='padding:60px;'><i class='fa fa-circle-check' style='color:var(--g);opacity:1;font-size:36px;'></i><p style='color:var(--g);font-weight:700;margin-top:8px;'>No at-risk students!</p></div>";
        return;
    }

    // Also build scatter data for risk chart
    destroyChart('risk');
    const el = document.getElementById('chartRisk');
    if (el) {
        charts.risk = new Chart(el, {
            type:'scatter',
            data:{ datasets:[{
                label:'Students',
                data: data.map(r=>({ x: parseFloat(r.AttPct)||0, y: parseFloat(r.AvgScore)||0, name: r.FullName })),
                backgroundColor: data.map(r=>{
                    const att = parseFloat(r.AttPct)||0;
                    return att<60?'rgba(239,68,68,.7)':att<75?'rgba(245,158,11,.7)':'rgba(79,70,229,.7)';
                }),
                pointRadius:7, pointHoverRadius:10
            }]},
            options:{ responsive:true, maintainAspectRatio:false,
                plugins:{ legend:{display:false},
                    tooltip:{ ...TT, callbacks:{
                        label: ctx => {
                            const raw = ctx.raw;
                            return ` ${raw.name}: Att ${raw.x}%, Score ${raw.y}`;
                        }
                    }}},
                scales:{
                    x:{ title:{display:true,text:'Attendance %',font:{size:11}},
                        min:0,max:100,grid:GRD,ticks:TICK },
                    y:{ title:{display:true,text:'Avg Score',font:{size:11}},
                        min:0,max:100,grid:GRD,ticks:TICK }
                },
                animation:ANIM }
        });
    }

    let html = '';
    data.forEach(s => {
        const att   = parseFloat(s.AttPct)||0;
        const score = parseFloat(s.AvgScore)||0;
        const col   = att<60||score<33 ? 'var(--r)' : 'var(--w)';
        const init  = (s.FullName||'?').substring(0,1).toUpperCase();
        html += `<div class="stu-item">
            <div class="st-av" style="background:var(--rl);color:var(--r);">
                ${s.ProfileImage ? `<img src="${s.ProfileImage}" alt=""/>` : init}
            </div>
            <div class="stu-info">
                <div class="stu-name">${esc(s.FullName||'')}</div>
                <div class="stu-course">${esc(s.CourseName||'—')}</div>
            </div>
            <div class="stu-right">
                <span class="risk-pill">${esc(s.RiskReason||'At Risk')}</span>
                <div style="font-size:10px;color:var(--ts);margin-top:4px;">
                    Att: <strong style="color:${att<60?'var(--r)':'var(--w)'};">${att}%</strong>
                    &nbsp;&bull;&nbsp;
                    Score: <strong style="color:${score<33?'var(--r)':'var(--w)'};">${score}</strong>
                </div>
            </div>
        </div>`;
    });
    wrap.innerHTML = html;
}

/* ════════════════════════════════════════════════════════
   TABS
════════════════════════════════════════════════════════ */
window.switchTab = function (name, btn) {
    document.querySelectorAll('.tab-pane').forEach(p => p.classList.remove('active'));
    document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
    document.getElementById('tab-'+name)?.classList.add('active');
    btn.classList.add('active');
};

/* ════════════════════════════════════════════════════════
   CSV EXPORT
════════════════════════════════════════════════════════ */
window.exportCSV = function () {
    if (!lastData?.students?.length) { alert('No data to export'); return; }
    const headers = ['Name','Roll No','Stream','Course','Semester','Section','Gender','Joined','Attendance%','AvgScore','Submissions','Status'];
    const rows = lastData.students.map(s => [
        s.FullName, s.RollNumber, s.StreamName, s.CourseName,
        s.SemesterName, s.SectionName, s.Gender, s.JoinedDate,
        s.AttPct, s.AvgScore, s.Submissions, s.Status
    ].map(v => `"${(v||'').toString().replace(/"/g,'""')}"`));
    const csv = [headers, ...rows].map(r=>r.join(',')).join('\n');
    const a = document.createElement('a');
    a.href = 'data:text/csv;charset=utf-8,' + encodeURIComponent(csv);
    a.download = `students_${new Date().toISOString().slice(0,10)}.csv`;
    a.click();
};

/* ════════════════════════════════════════════════════════
   UTILITY
════════════════════════════════════════════════════════ */
function esc(s) {
    return String(s||'')
        .replace(/&/g,'&amp;')
        .replace(/</g,'&lt;')
        .replace(/>/g,'&gt;')
        .replace(/"/g,'&quot;');
}

/* ════════════════════════════════════════════════════════
   LIVE SEARCH — debounced on input
════════════════════════════════════════════════════════ */
document.getElementById('fSearch').addEventListener('input', function () {
    clearTimeout(debounceTimer);
    debounceTimer = setTimeout(() => applyFilters(0), 500);
});

// Dropdowns trigger immediate re-fetch on change
['fStream','fCourse','fSemester','fSection','fGender','fMonth','fYear'].forEach(id => {
    const el = document.getElementById(id);
    if (el && id !== 'fStream') // fStream handled by onStreamChange
        el.addEventListener('change', () => applyFilters(0));
});

/* ════════════════════════════════════════════════════════
   INIT — populate dropdowns from server-rendered ASP controls
════════════════════════════════════════════════════════ */
(function initFromServer() {
    // Copy stream options from hidden ASP dropdown to JS dropdown
    const aspStream = document.getElementById('<%= ddlStream.ClientID %>');
    const jsStream  = document.getElementById('fStream');
    if (aspStream) {
        Array.from(aspStream.options).forEach(o => {
            if (o.value === '0') return;
            const n = document.createElement('option');
            n.value = o.value; n.text = o.text; jsStream.appendChild(n);
        });
    }
    // Semester
    const aspSem = document.getElementById('<%= ddlSemester.ClientID %>');
    const jsSem  = document.getElementById('fSemester');
    if (aspSem) {
        Array.from(aspSem.options).forEach(o => {
            if (o.value === '0') return;
            const n = document.createElement('option');
            n.value = o.value; n.text = o.text; jsSem.appendChild(n);
        });
    }
    // Section
    const aspSec = document.getElementById('<%= ddlSection.ClientID %>');
    const jsSec  = document.getElementById('fSection');
    if (aspSec) {
        Array.from(aspSec.options).forEach(o => {
            if (o.value === '0') return;
            const n = document.createElement('option');
            n.value = o.value; n.text = o.text; jsSec.appendChild(n);
        });
    }
    // Courses
    const aspCourse = document.getElementById('<%= ddlCourse.ClientID %>');
    const jsCourse  = document.getElementById('fCourse');
    if (aspCourse) {
        Array.from(aspCourse.options).forEach(o => {
            if (o.value === '0') return;
            const n = document.createElement('option');
            n.value = o.value; n.text = o.text; jsCourse.appendChild(n);
        });
    }

    // Auto-load on page ready
    applyFilters(0);
})();

})();
</script>
</asp:Content>
