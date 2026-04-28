<%@ Page Title="Stream Wise Dashboard" Language="C#"
    MasterPageFile="~/Admin/AdminMaster.Master"
    AutoEventWireup="true"
    CodeBehind="StreamWisedashboard.aspx.cs"
    Inherits="LearningManagementSystem.Admin.Dashboards.StreamWiseDashboard" %>

<asp:Content ID="cHead" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet"/>
<style>
:root{
  --p:#4f46e5;--pl:#ede9fe;--pd:#3730a3;
  --g:#10b981;--gl:#d1fae5;
  --w:#f59e0b;--wl:#fef3c7;
  --r:#ef4444;--rl:#fee2e2;
  --b:#3b82f6;--bl:#dbeafe;
  --pu:#8b5cf6;--pul:#f3f0ff;
  --t:#0d9488;--tl:#ccfbf1;
  --ro:#f43f5e;--rol:#ffe4e6;
  --tx:#1e293b;--ts:#64748b;--tm:#94a3b8;
  --bd:#e2e8f0;--bg:#fff;--pg:#f8fafc;
  --rad:14px;--rads:8px;
  --sh:0 1px 3px rgba(0,0,0,.07),0 1px 2px rgba(0,0,0,.05);
  --shm:0 4px 14px rgba(0,0,0,.09);
}
*{box-sizing:border-box;margin:0;padding:0;}
body{background:var(--pg);font-family:'Inter','Segoe UI',sans-serif;color:var(--tx);}
.wrap{padding:24px;}

/* Alert */
.dash-alert{display:flex;align-items:center;gap:10px;padding:12px 18px;border-radius:var(--rads);
  font-size:13px;font-weight:500;margin-bottom:18px;animation:fadeSlide .3s ease;}
@keyframes fadeSlide{from{opacity:0;transform:translateY(-6px)}to{opacity:1;transform:none}}
.alert-success{background:var(--gl);color:#065f46;}
.alert-danger{background:var(--rl);color:#991b1b;}
.alert-warning{background:var(--wl);color:#92400e;}
.alert-info{background:var(--bl);color:#1e40af;}

/* Top bar */
.topbar{display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:14px;margin-bottom:24px;}
.tb-left h1{font-size:21px;font-weight:800;display:flex;align-items:center;gap:10px;}
.h1-ico{width:36px;height:36px;background:var(--pl);color:var(--p);border-radius:10px;
  display:flex;align-items:center;justify-content:center;font-size:15px;flex-shrink:0;}
.tb-left p{font-size:13px;color:var(--ts);margin-top:3px;padding-left:46px;}
.tb-right{display:flex;align-items:center;gap:10px;flex-wrap:wrap;}
.ddl{padding:9px 14px;border:1.5px solid var(--bd);border-radius:var(--rads);font-size:13px;
  color:var(--tx);background:#fff;cursor:pointer;font-weight:500;min-width:175px;transition:border .2s;}
.ddl:focus{border-color:var(--p);outline:none;box-shadow:0 0 0 3px rgba(79,70,229,.12);}
.sess-badge{background:var(--pl);color:var(--p);padding:7px 16px;border-radius:20px;
  font-size:12px;font-weight:700;display:flex;align-items:center;gap:6px;white-space:nowrap;}

/* Banner */
.banner{position:relative;border-radius:var(--rad);overflow:hidden;margin-bottom:24px;
  min-height:178px;background:linear-gradient(135deg,#1a1560 0%,#3b30c8 45%,#7033d4 100%);
  box-shadow:var(--shm);}
.b-bgimg{position:absolute;inset:0;width:100%;height:100%;object-fit:cover;z-index:0;display:block;}
.b-ov{position:absolute;inset:0;background:linear-gradient(100deg,rgba(8,5,55,.78) 0%,rgba(8,5,55,.22) 100%);z-index:1;}
.b-body{position:relative;z-index:2;display:flex;align-items:center;
  justify-content:space-between;padding:28px 36px;gap:24px;flex-wrap:wrap;}
.b-title{font-size:24px;font-weight:800;color:#fff;margin-bottom:4px;display:flex;align-items:center;gap:10px;}
.b-title i{opacity:.85;}
.b-sub{font-size:13px;color:rgba(255,255,255,.72);}
.b-stats{display:flex;gap:18px;margin-top:14px;flex-wrap:wrap;}
.bstat .v{font-size:22px;font-weight:900;color:#fff;}
.bstat .l{font-size:10px;color:rgba(255,255,255,.62);text-transform:uppercase;letter-spacing:.04em;}

/* Upload column */
.up-col{display:flex;flex-direction:column;align-items:flex-end;gap:8px;min-width:192px;}
.dz{width:192px;border:2px dashed rgba(255,255,255,.4);border-radius:10px;
  padding:14px 8px;text-align:center;cursor:pointer;transition:.2s;background:rgba(255,255,255,.07);}
.dz:hover{border-color:#fff;background:rgba(255,255,255,.16);}
.dz i{font-size:24px;color:#fff;display:block;margin-bottom:5px;}
.dz-lbl{font-size:11px;color:rgba(255,255,255,.82);line-height:1.5;}
.btn-up{width:192px;padding:8px 0;background:#fff;color:var(--p);border:none;border-radius:var(--rads);
  font-size:12px;font-weight:700;cursor:pointer;transition:.15s;}
.btn-up:hover{background:#f0efff;transform:translateY(-1px);}
.btn-rm{width:192px;padding:8px 0;background:rgba(255,255,255,.14);color:#fff;
  border:1px solid rgba(255,255,255,.32);border-radius:var(--rads);font-size:12px;font-weight:600;cursor:pointer;transition:.15s;}
.btn-rm:hover{background:rgba(255,255,255,.26);}
#upProg{width:192px;height:4px;background:rgba(255,255,255,.2);border-radius:2px;overflow:hidden;}
#upBar{height:4px;background:#fff;width:0%;transition:width .35s;border-radius:2px;}

/* KPI grid */
.kpi-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(158px,1fr));gap:14px;margin-bottom:24px;}
.kpi{background:var(--bg);border:1px solid var(--bd);border-radius:var(--rad);padding:18px 16px;
  box-shadow:var(--sh);position:relative;overflow:hidden;transition:transform .18s,box-shadow .18s;cursor:default;}
.kpi:hover{transform:translateY(-3px);box-shadow:var(--shm);}
.kpi::before{content:'';position:absolute;top:0;left:0;right:0;height:3px;border-radius:var(--rad) var(--rad) 0 0;}
.k-blue::before{background:var(--b);}  .k-green::before{background:var(--g);}
.k-pu::before{background:var(--pu);}   .k-amber::before{background:var(--w);}
.k-teal::before{background:var(--t);}  .k-rose::before{background:var(--ro);}
.kpi-top{display:flex;align-items:center;justify-content:space-between;margin-bottom:12px;}
.kpi-lbl{font-size:11px;font-weight:700;color:var(--ts);text-transform:uppercase;letter-spacing:.05em;}
.kpi-ico{width:42px;height:42px;border-radius:11px;display:flex;align-items:center;justify-content:center;font-size:18px;}
.ic-b{background:var(--bl);color:var(--b);}  .ic-g{background:var(--gl);color:var(--g);}
.ic-pu{background:var(--pul);color:var(--pu);} .ic-w{background:var(--wl);color:var(--w);}
.ic-t{background:var(--tl);color:var(--t);} .ic-ro{background:var(--rol);color:var(--ro);}
.kpi-val{font-size:30px;font-weight:900;color:var(--tx);line-height:1;}
.kpi-hint{font-size:11px;color:var(--tm);margin-top:5px;}

/* Stream scroll */
.sc-row{display:flex;gap:12px;overflow-x:auto;padding-bottom:8px;margin-bottom:22px;
  scrollbar-width:thin;scrollbar-color:var(--bd) transparent;}
.sc-row::-webkit-scrollbar{height:4px;}
.sc-row::-webkit-scrollbar-thumb{background:var(--bd);border-radius:4px;}
.sc{background:var(--bg);border:1.5px solid var(--bd);border-radius:var(--rad);
  padding:15px 17px;min-width:172px;flex-shrink:0;box-shadow:var(--sh);transition:.18s;cursor:pointer;}
.sc:hover,.sc.act{border-color:var(--p);box-shadow:0 0 0 3px rgba(79,70,229,.13);}
.sc-name{font-size:13px;font-weight:700;color:var(--tx);margin-bottom:9px;
  display:flex;align-items:center;gap:6px;}
.sc-name i{color:var(--p);font-size:11px;}
.sc-stat{display:flex;justify-content:space-between;font-size:12px;margin-bottom:4px;}
.sc-stat span:first-child{color:var(--ts);}
.sc-stat span:last-child{font-weight:700;}
.att-track{height:5px;background:var(--bd);border-radius:99px;margin-top:9px;overflow:hidden;}
.att-fill{height:5px;background:var(--g);border-radius:99px;width:0%;transition:width 1.2s ease;}
.att-lbl{font-size:10px;color:var(--ts);text-align:right;margin-top:3px;}

/* Card */
.card{background:var(--bg);border:1px solid var(--bd);border-radius:var(--rad);
  box-shadow:var(--sh);padding:20px;transition:box-shadow .18s;}
.card:hover{box-shadow:var(--shm);}
.card-hd{display:flex;align-items:flex-start;justify-content:space-between;margin-bottom:18px;gap:10px;}
.card-hd-l{display:flex;align-items:center;gap:10px;}
.c-ico{width:34px;height:34px;border-radius:9px;display:flex;align-items:center;
  justify-content:center;font-size:15px;flex-shrink:0;}
.c-title{font-size:14px;font-weight:700;color:var(--tx);}
.c-sub{font-size:12px;color:var(--ts);margin-top:2px;}
.chart-box{position:relative;width:100%;}

/* Grid layouts */
.g2{display:grid;grid-template-columns:1fr 1fr;gap:16px;margin-bottom:20px;}
.g3{display:grid;grid-template-columns:1fr 1fr 1fr;gap:16px;margin-bottom:20px;}
.g21{display:grid;grid-template-columns:2fr 1fr;gap:16px;margin-bottom:20px;}

/* Table */
.tbl{width:100%;border-collapse:collapse;font-size:13px;}
.tbl th{font-size:11px;font-weight:700;color:var(--ts);text-transform:uppercase;
  letter-spacing:.04em;padding:0 12px 12px;border-bottom:2px solid var(--bd);text-align:left;white-space:nowrap;}
.tbl td{padding:11px 12px;border-bottom:1px solid var(--bd);vertical-align:middle;}
.tbl tr:last-child td{border:none;}
.tbl tbody tr{transition:background .12s;}
.tbl tbody tr:hover td{background:#f7f8ff;}
.num{font-size:11px;color:var(--tm);}
.sname{font-weight:600;color:var(--tx);}
.scode{display:inline-block;font-size:10px;background:var(--pl);color:var(--p);
  padding:2px 8px;border-radius:99px;font-weight:700;}
.chip{display:inline-flex;align-items:center;gap:4px;padding:3px 9px;
  border-radius:99px;font-size:11px;font-weight:600;white-space:nowrap;}
.chip i{font-size:10px;}
.cv{background:var(--bl);color:#1d4ed8;}
.ca{background:var(--wl);color:#92400e;}
.cq{background:var(--pul);color:#6d28d9;}
.cvw{background:var(--tl);color:#0f766e;font-weight:700;}

/* Teachers */
.tch{display:flex;align-items:center;gap:12px;padding:12px 0;border-bottom:1px solid var(--bd);}
.tch:last-child{border:none;}
.av{width:44px;height:44px;border-radius:50%;background:var(--pl);color:var(--p);
  display:flex;align-items:center;justify-content:center;font-size:17px;font-weight:800;
  flex-shrink:0;overflow:hidden;border:2px solid var(--bd);}
.av img{width:100%;height:100%;object-fit:cover;}
.tch-name{font-size:13px;font-weight:700;color:var(--tx);}
.tch-des{font-size:11px;color:var(--ts);margin-top:1px;}
.tch-chips{display:flex;gap:5px;margin-top:5px;}
.tch-right{margin-left:auto;text-align:right;flex-shrink:0;}
.tch-right .big{font-size:16px;font-weight:800;color:var(--p);}
.tch-right .sm{font-size:10px;color:var(--tm);}

/* Progress bars */
.pi{margin-bottom:14px;}
.pi-lbl{display:flex;justify-content:space-between;font-size:12px;font-weight:500;color:var(--tx);margin-bottom:5px;}
.pi-lbl span:last-child{color:var(--ts);}
.pi-track{height:8px;background:var(--bd);border-radius:99px;overflow:hidden;}
.pi-fill{height:8px;border-radius:99px;transition:width 1.1s ease;width:0%;}

/* Empty */
.empty{text-align:center;padding:40px;color:var(--tm);}
.empty i{font-size:32px;display:block;margin-bottom:10px;opacity:.45;}
.empty p{font-size:13px;}

@media(max-width:1100px){.g21{grid-template-columns:1fr;}.g3{grid-template-columns:1fr 1fr;}}
@media(max-width:700px){.g2,.g3{grid-template-columns:1fr;}.kpi-grid{grid-template-columns:1fr 1fr;}}
@media(max-width:440px){.kpi-grid{grid-template-columns:1fr;}}
</style>
</asp:Content>

<asp:Content ID="cBody" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

<%-- Hidden fields for chart data --%>
<asp:HiddenField ID="hdnCourseLabels"    runat="server"/>
<asp:HiddenField ID="hdnCourseStudents"  runat="server"/>
<asp:HiddenField ID="hdnTrendMonths"     runat="server"/>
<asp:HiddenField ID="hdnTrendStudents"   runat="server"/>
<asp:HiddenField ID="hdnAttDays"         runat="server"/>
<asp:HiddenField ID="hdnAttPct"          runat="server"/>
<asp:HiddenField ID="hdnQuizStreams"     runat="server"/>
<asp:HiddenField ID="hdnQuizPassRate"    runat="server"/>
<asp:HiddenField ID="hdnQuizAvgScore"    runat="server"/>
<asp:HiddenField ID="hdnGenderLabels"    runat="server"/>
<asp:HiddenField ID="hdnGenderVals"      runat="server"/>
<asp:HiddenField ID="hdnAssignStreams"   runat="server"/>
<asp:HiddenField ID="hdnAssignSubmitted" runat="server"/>
<asp:HiddenField ID="hdnBannerPath"      runat="server"/>

<div class="wrap">

  <%-- Alert --%>
  <asp:Panel ID="pnlAlert" runat="server" Visible="false" CssClass="dash-alert">
    <i class="fa fa-circle-info"></i>
    <asp:Label ID="lblAlert" runat="server"/>
  </asp:Panel>

  <%-- TOP BAR --%>
  <div class="topbar">
    <div class="tb-left">
      <h1><span class="h1-ico"><i class="fa fa-layer-group"></i></span>Stream Wise Dashboard</h1>
      <p>Analytics per academic stream &mdash; <strong><asp:Label ID="lblStreamTitle" runat="server" Text="All Streams"/></strong></p>
    </div>
    <div class="tb-right">
      <asp:DropDownList ID="ddlStream" runat="server" CssClass="ddl"
        AutoPostBack="true" OnSelectedIndexChanged="ddlStream_SelectedIndexChanged"/>
      <span class="sess-badge"><i class="fa fa-calendar-check"></i><%=Session["SessionName"]%></span>
    </div>
  </div>

  <%-- BANNER --%>
  <div class="banner">
    <asp:Image ID="imgBanner" runat="server" Visible="false" CssClass="b-bgimg" AlternateText=""/>
    <div class="b-ov"></div>
    <div class="b-body">
      <div>
        <div class="b-title"><i class="fa fa-layer-group"></i>
          <asp:Label ID="lblBannerStream" runat="server" Text="Stream Analytics"/>
        </div>
        <div class="b-sub">Session: <%=Session["SessionName"]%> &nbsp;&bull;&nbsp;
          <asp:Label ID="lblBannerSub" runat="server" Text="All Streams Overview"/>
        </div>
        <div class="b-stats">
          <div class="bstat">
            <div class="v"><asp:Label ID="lblBStudents" runat="server" Text="—"/></div>
            <div class="l">Students</div>
          </div>
          <div class="bstat">
            <div class="v"><asp:Label ID="lblBTeachers" runat="server" Text="—"/></div>
            <div class="l">Teachers</div>
          </div>
          <div class="bstat">
            <div class="v"><asp:Label ID="lblBCourses" runat="server" Text="—"/></div>
            <div class="l">Courses</div>
          </div>
          <div class="bstat">
            <div class="v"><asp:Label ID="lblBAtt" runat="server" Text="—"/></div>
            <div class="l">Attendance</div>
          </div>
        </div>
      </div>
      <div class="up-col">
        <div class="dz" onclick="document.getElementById('fpicker').click();">
          <i class="fa fa-cloud-arrow-up"></i>
          <div class="dz-lbl" id="dzLabel">
            Click to choose banner<br/>
            <small style="opacity:.7;">JPG · PNG · WebP &nbsp;|&nbsp; Max 5 MB</small>
          </div>
        </div>
        <input type="file" id="fpicker" accept="image/*" style="display:none;" onchange="onFilePick(this)"/>
        <asp:FileUpload ID="fuBanner" runat="server" Style="display:none;"/>
        <div id="upProg"><div id="upBar"></div></div>
        <asp:Button ID="btnUploadBanner" runat="server" Text="⬆  Upload Banner"
          CssClass="btn-up" OnClick="btnUploadBanner_Click"/>
        <asp:Button ID="btnRemoveBanner" runat="server" Text="✕  Remove Banner"
          CssClass="btn-rm" OnClick="btnRemoveBanner_Click"/>
      </div>
    </div>
  </div>

  <%-- KPI CARDS --%>
  <div class="kpi-grid">
    <div class="kpi k-blue">
      <div class="kpi-top"><span class="kpi-lbl">Total Students</span><div class="kpi-ico ic-b"><i class="fa fa-users"></i></div></div>
      <div class="kpi-val"><asp:Label ID="lblStudents" runat="server" Text="0"/></div>
      <div class="kpi-hint">Enrolled this session</div>
    </div>
    <div class="kpi k-green">
      <div class="kpi-top"><span class="kpi-lbl">Avg Attendance</span><div class="kpi-ico ic-g"><i class="fa fa-calendar-check"></i></div></div>
      <div class="kpi-val"><asp:Label ID="lblAttPct" runat="server" Text="0%"/></div>
      <div class="kpi-hint">Session overall average</div>
    </div>
    <div class="kpi k-pu">
      <div class="kpi-top"><span class="kpi-lbl">Courses</span><div class="kpi-ico ic-pu"><i class="fa fa-graduation-cap"></i></div></div>
      <div class="kpi-val"><asp:Label ID="lblCourses" runat="server" Text="0"/></div>
      <div class="kpi-hint">Active in this stream</div>
    </div>
    <div class="kpi k-amber">
      <div class="kpi-top"><span class="kpi-lbl">Subjects</span><div class="kpi-ico ic-w"><i class="fa fa-book-open"></i></div></div>
      <div class="kpi-val"><asp:Label ID="lblSubjects" runat="server" Text="0"/></div>
      <div class="kpi-hint">Assigned to stream</div>
    </div>
    <div class="kpi k-teal">
      <div class="kpi-top"><span class="kpi-lbl">Faculty</span><div class="kpi-ico ic-t"><i class="fa fa-chalkboard-user"></i></div></div>
      <div class="kpi-val"><asp:Label ID="lblTeachers" runat="server" Text="0"/></div>
      <div class="kpi-hint">Teachers assigned</div>
    </div>
    <div class="kpi k-rose">
      <div class="kpi-top"><span class="kpi-lbl">Sections</span><div class="kpi-ico ic-ro"><i class="fa fa-sitemap"></i></div></div>
      <div class="kpi-val"><asp:Label ID="lblSections" runat="server" Text="0"/></div>
      <div class="kpi-hint">Active sections</div>
    </div>
  </div>

  <%-- STREAM MINI-CARDS --%>
  <div class="sc-row">
    <asp:Repeater ID="rptStreamCards" runat="server">
      <ItemTemplate>
        <div class="sc">
          <div class="sc-name"><i class="fa fa-layer-group"></i><%# Eval("StreamName") %></div>
          <div class="sc-stat"><span>Students</span><span><%# Eval("TotalStudents") %></span></div>
          <div class="sc-stat"><span>Courses</span><span><%# Eval("TotalCourses") %></span></div>
          <div class="sc-stat"><span>Teachers</span><span><%# Eval("TotalTeachers") %></span></div>
          <div class="att-track">
            <div class="att-fill" style="width:<%# Eval("AttendancePct") ?? 0 %>%"></div>
          </div>
          <div class="att-lbl"><%# FormatDec(Eval("AttendancePct")) %>% attendance</div>
        </div>
      </ItemTemplate>
    </asp:Repeater>
  </div>

  <%-- ROW 1: Enrollment trend + 7-day attendance --%>
  <div class="g21">
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="c-ico" style="background:var(--pl);color:var(--p);"><i class="fa fa-arrow-trend-up"></i></div>
          <div><div class="c-title">Enrollment Trend — Last 6 Months</div>
            <div class="c-sub">New students joining per month</div></div>
        </div>
      </div>
      <div class="chart-box" style="height:245px;"><canvas id="chartEnroll"></canvas></div>
    </div>
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="c-ico" style="background:var(--gl);color:var(--g);"><i class="fa fa-calendar-week"></i></div>
          <div><div class="c-title">Attendance — Last 7 Days</div>
            <div class="c-sub">Daily % present</div></div>
        </div>
      </div>
      <div class="chart-box" style="height:245px;"><canvas id="chartAtt7"></canvas></div>
    </div>
  </div>

  <%-- ROW 2: Course + Gender + Quiz --%>
  <div class="g3">
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="c-ico" style="background:var(--pul);color:var(--pu);"><i class="fa fa-graduation-cap"></i></div>
          <div><div class="c-title">Students by Course</div><div class="c-sub">Enrollment per course</div></div>
        </div>
      </div>
      <div class="chart-box" style="height:240px;"><canvas id="chartCourse"></canvas></div>
    </div>
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="c-ico" style="background:var(--rol);color:var(--ro);"><i class="fa fa-venus-mars"></i></div>
          <div><div class="c-title">Gender Distribution</div><div class="c-sub">Male / Female / Other</div></div>
        </div>
      </div>
      <div class="chart-box" style="height:195px;"><canvas id="chartGender"></canvas></div>
      <div id="gLegend" style="margin-top:10px;display:flex;flex-wrap:wrap;gap:8px;justify-content:center;"></div>
    </div>
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="c-ico" style="background:var(--wl);color:var(--w);"><i class="fa fa-trophy"></i></div>
          <div><div class="c-title">Quiz Pass Rate by Stream</div><div class="c-sub">Pass % &amp; avg score</div></div>
        </div>
      </div>
      <div class="chart-box" style="height:240px;"><canvas id="chartQuiz"></canvas></div>
    </div>
  </div>

  <%-- ROW 3: Subject table + Teachers --%>
  <div class="g21">
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="c-ico" style="background:var(--bl);color:var(--b);"><i class="fa fa-table-list"></i></div>
          <div><div class="c-title">Subjects in Stream</div><div class="c-sub">Content &amp; engagement overview</div></div>
        </div>
        <span style="font-size:11px;color:var(--tm);">Top 10</span>
      </div>
      <div style="overflow-x:auto;">
        <table class="tbl">
          <thead><tr>
            <th>#</th><th>Subject</th><th>Code</th>
            <th>Videos</th><th>Assignments</th><th>Quizzes</th><th>Views</th>
          </tr></thead>
          <tbody>
            <asp:Repeater ID="rptSubjects" runat="server">
              <ItemTemplate>
                <tr>
                  <td class="num"><%# Container.ItemIndex+1 %></td>
                  <td class="sname"><%# Server.HtmlEncode(Eval("SubjectName").ToString()) %></td>
                  <td><span class="scode"><%# string.IsNullOrWhiteSpace(Eval("SubjectCode")?.ToString()) ? "—" : Eval("SubjectCode").ToString() %></span></td>
                  <td><span class="chip cv"><i class="fa fa-video"></i><%# Eval("Videos") %></span></td>
                  <td><span class="chip ca"><i class="fa fa-clipboard"></i><%# Eval("Assignments") %></span></td>
                  <td><span class="chip cq"><i class="fa fa-circle-question"></i><%# Eval("Quizzes") %></span></td>
                  <td><span class="chip cvw"><i class="fa fa-eye"></i><%# Eval("VideoViews") %></span></td>
                </tr>
              </ItemTemplate>
              <FooterTemplate>
                <%# rptSubjects.Items.Count==0 ? "<tr><td colspan='7'><div class='empty'><i class='fa fa-book-open'></i><p>No subjects found</p></div></td></tr>" : "" %>
              </FooterTemplate>
            </asp:Repeater>
          </tbody>
        </table>
      </div>
    </div>
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="c-ico" style="background:var(--wl);color:var(--w);"><i class="fa fa-star"></i></div>
          <div><div class="c-title">Top Faculty</div><div class="c-sub">Ranked by activity</div></div>
        </div>
      </div>
      <asp:Repeater ID="rptTeachers" runat="server">
        <ItemTemplate>
          <div class="tch">
            <div class="av">
              <%# !string.IsNullOrEmpty(Eval("ProfileImage")?.ToString())
                  ? string.Format("<img src='{0}' alt=''/>", Eval("ProfileImage"))
                  : Eval("FullName").ToString().Substring(0,1).ToUpper() %>
            </div>
            <div style="flex:1;min-width:0;">
              <div class="tch-name"><%# Server.HtmlEncode(Eval("FullName").ToString()) %></div>
              <div class="tch-des"><%# Eval("Designation") %> &middot; <%# Eval("ExperienceYears") %> yrs</div>
              <div class="tch-chips">
                <span class="chip cv"><i class="fa fa-video"></i><%# Eval("Videos") %> vids</span>
                <span class="chip ca"><i class="fa fa-clipboard"></i><%# Eval("Assignments") %></span>
              </div>
            </div>
            <div class="tch-right">
              <div class="big"><%# Eval("Videos") %></div>
              <div class="sm">Videos</div>
            </div>
          </div>
        </ItemTemplate>
        <FooterTemplate>
          <%# rptTeachers.Items.Count==0 ? "<div class='empty'><i class='fa fa-chalkboard-user'></i><p>No teachers found</p></div>" : "" %>
        </FooterTemplate>
      </asp:Repeater>
    </div>
  </div>

  <%-- ROW 4: Assignment progress bars + Polar chart --%>
  <div class="g2">
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="c-ico" style="background:var(--wl);color:var(--w);"><i class="fa fa-clipboard-check"></i></div>
          <div><div class="c-title">Assignment Completion by Stream</div>
            <div class="c-sub">Submissions received</div></div>
        </div>
      </div>
      <div id="assignBars"></div>
    </div>
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="c-ico" style="background:var(--tl);color:var(--t);"><i class="fa fa-chart-pie"></i></div>
          <div><div class="c-title">Avg Quiz Score — Stream Comparison</div>
            <div class="c-sub">Polar area chart</div></div>
        </div>
      </div>
      <div class="chart-box" style="height:250px;"><canvas id="chartPolar"></canvas></div>
    </div>
  </div>

</div><%-- /wrap --%>

<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.4.1/chart.umd.min.js"></script>
<script>
    (function () {
        'use strict';
        const hf = id => { try { return JSON.parse(document.getElementById(id).value || '[]'); } catch { return []; } };
        const PAL = ['#4f46e5', '#10b981', '#f59e0b', '#ef4444', '#8b5cf6', '#3b82f6', '#0d9488', '#f43f5e', '#0891b2', '#ec4899'];
        const palA = a => PAL.map(c => c + Math.round(a * 255).toString(16).padStart(2, '0'));
        const GRD = { color: 'rgba(148,163,184,.12)' };
        const TICK = { font: { size: 11, family: "'Inter','Segoe UI',sans-serif" } };
        const ANIM = { duration: 1000, easing: 'easeInOutQuart' };
        const TT = { bodyFont: { size: 12 }, titleFont: { size: 12, weight: 'bold' }, padding: 10, cornerRadius: 8 };
        const noLeg = { legend: { display: false } };

        function gV(ctx, h, c1, c2) { const g = ctx.createLinearGradient(0, 0, 0, h); g.addColorStop(0, c1); g.addColorStop(1, c2); return g; }
        function noData(id) { const el = document.getElementById(id); if (el) el.parentElement.innerHTML = "<div class='empty'><i class='fa fa-chart-simple'></i><p>No data</p></div>"; }

        // 1. Enrollment trend
        (function () {
            const lab = hf('<%= hdnTrendMonths.ClientID %>'),dat=hf('<%= hdnTrendStudents.ClientID %>');
  if(!lab.length){noData('chartEnroll');return;}
  const ctx=document.getElementById('chartEnroll').getContext('2d');
  const gr=gV(ctx,220,'rgba(79,70,229,.30)','rgba(79,70,229,.01)');
  new Chart(ctx,{type:'line',data:{labels:lab,datasets:[{label:'New Students',data:dat,
    borderColor:'#4f46e5',backgroundColor:gr,borderWidth:2.5,tension:.42,fill:true,
    pointBackgroundColor:'#4f46e5',pointRadius:5,pointHoverRadius:8,
    pointHoverBackgroundColor:'#fff',pointHoverBorderColor:'#4f46e5',pointHoverBorderWidth:2}]},
    options:{responsive:true,maintainAspectRatio:false,
      plugins:{...noLeg,tooltip:{...TT,callbacks:{label:c=>' '+c.raw+' students'}}},
      scales:{x:{grid:{display:false},ticks:TICK},y:{beginAtZero:true,grid:GRD,ticks:TICK}},
      animation:ANIM}});
})();

// 2. 7-day attendance
(function(){
  const lab=hf('<%= hdnAttDays.ClientID %>'),dat=hf('<%= hdnAttPct.ClientID %>');
  if(!lab.length){noData('chartAtt7');return;}
  const ctx=document.getElementById('chartAtt7').getContext('2d');
  const gr=gV(ctx,220,'rgba(16,185,129,.28)','rgba(16,185,129,.01)');
  new Chart(ctx,{type:'line',data:{labels:lab,datasets:[{label:'Attendance %',data:dat,
    borderColor:'#10b981',backgroundColor:gr,borderWidth:2.5,tension:.4,fill:true,
    pointBackgroundColor:'#10b981',pointRadius:5,pointHoverRadius:8,
    pointHoverBackgroundColor:'#fff',pointHoverBorderColor:'#10b981',pointHoverBorderWidth:2}]},
    options:{responsive:true,maintainAspectRatio:false,
      plugins:{...noLeg,tooltip:{...TT,callbacks:{label:c=>' '+c.raw+'%'}}},
      scales:{x:{grid:{display:false},ticks:TICK},
        y:{beginAtZero:true,max:100,grid:GRD,ticks:{...TICK,callback:v=>v+'%'}}},
      animation:ANIM}});
})();

// 3. Course horizontal bar
(function(){
  const lab=hf('<%= hdnCourseLabels.ClientID %>'),dat=hf('<%= hdnCourseStudents.ClientID %>');
  if(!lab.length){noData('chartCourse');return;}
  new Chart(document.getElementById('chartCourse'),{type:'bar',
    data:{labels:lab,datasets:[{label:'Students',data:dat,backgroundColor:palA(.82),borderRadius:6,borderSkipped:false}]},
    options:{indexAxis:'y',responsive:true,maintainAspectRatio:false,
      plugins:{...noLeg,tooltip:TT},
      scales:{x:{beginAtZero:true,grid:GRD,ticks:TICK},y:{grid:{display:false},ticks:{font:{size:11}}}},
      animation:ANIM}});
})();

// 4. Gender doughnut
(function(){
  const lab=hf('<%= hdnGenderLabels.ClientID %>'),dat=hf('<%= hdnGenderVals.ClientID %>');
  if(!lab.length){noData('chartGender');return;}
  const GCOL=['#4f46e5','#f43f5e','#10b981','#f59e0b'];
  new Chart(document.getElementById('chartGender'),{type:'doughnut',
    data:{labels:lab,datasets:[{data:dat,backgroundColor:GCOL,borderWidth:3,borderColor:'#fff',hoverOffset:8}]},
    options:{cutout:'65%',responsive:true,maintainAspectRatio:false,
      plugins:{legend:{display:false},tooltip:TT},
      animation:{animateRotate:true,duration:1100}}});
  const leg=document.getElementById('gLegend');
  const tot=dat.reduce((a,b)=>a+b,0)||1;
  lab.forEach((l,i)=>{
    leg.innerHTML+=`<div style="display:flex;align-items:center;gap:5px;font-size:12px;">
      <span style="width:10px;height:10px;border-radius:2px;background:${GCOL[i]};display:inline-block;"></span>
      ${l} <strong style="color:${GCOL[i]};">${Math.round(dat[i]/tot*100)}%</strong></div>`;
  });
})();

// 5. Quiz pass rate grouped bar
(function(){
  const lab=hf('<%= hdnQuizStreams.ClientID %>'),
        pass=hf('<%= hdnQuizPassRate.ClientID %>'),
        avg=hf('<%= hdnQuizAvgScore.ClientID %>');
  if(!lab.length){noData('chartQuiz');return;}
  new Chart(document.getElementById('chartQuiz'),{type:'bar',
    data:{labels:lab,datasets:[
      {label:'Pass Rate %',data:pass,backgroundColor:'rgba(79,70,229,.82)',borderRadius:5},
      {label:'Avg Score',data:avg,backgroundColor:'rgba(245,158,11,.82)',borderRadius:5}]},
    options:{responsive:true,maintainAspectRatio:false,
      plugins:{legend:{position:'top',labels:{boxWidth:10,font:{size:11}}},tooltip:TT},
      scales:{x:{grid:{display:false},ticks:{font:{size:10}}},
        y:{beginAtZero:true,max:100,grid:GRD,ticks:{...TICK,callback:v=>v+'%'}}},
      animation:ANIM}});
})();

// 6. Polar — avg score
(function(){
  const lab=hf('<%= hdnQuizStreams.ClientID %>'),dat=hf('<%= hdnQuizAvgScore.ClientID %>');
  if(!lab.length){noData('chartPolar');return;}
  new Chart(document.getElementById('chartPolar'),{type:'polarArea',
    data:{labels:lab,datasets:[{data:dat,backgroundColor:palA(.72),borderColor:'#fff',borderWidth:2}]},
    options:{responsive:true,maintainAspectRatio:false,
      plugins:{legend:{position:'right',labels:{boxWidth:10,font:{size:11}}},tooltip:TT},
      scales:{r:{beginAtZero:true,ticks:{font:{size:10}},grid:{color:'rgba(148,163,184,.2)'}}},
      animation:{duration:1100,easing:'easeInOutBack'}}});
})();

// 7. Assignment progress bars
(function(){
  const str=hf('<%= hdnAssignStreams.ClientID %>'),sub=hf('<%= hdnAssignSubmitted.ClientID %>');
  const wrap=document.getElementById('assignBars');
  if(!str.length){wrap.innerHTML="<div class='empty'><i class='fa fa-clipboard-check'></i><p>No assignment data</p></div>";return;}
  const maxV=Math.max(...sub)||1;
  str.forEach((s,i)=>{
    const pct=Math.round(sub[i]/maxV*100);
    wrap.innerHTML+=`<div class="pi">
      <div class="pi-lbl"><span>${s}</span><span>${sub[i]} submissions</span></div>
      <div class="pi-track"><div class="pi-fill" data-w="${pct}%" style="background:${PAL[i%PAL.length]};"></div></div></div>`;
  });
  setTimeout(()=>document.querySelectorAll('.pi-fill[data-w]').forEach(el=>el.style.width=el.dataset.w),300);
})();

// Banner preview
window.onFilePick=function(input){
  if(!input.files||!input.files[0])return;
  const f=input.files[0];
  document.getElementById('dzLabel').innerHTML=
    `<strong style="font-size:12px;">${f.name}</strong><br/><small style="opacity:.75;">${(f.size/1048576).toFixed(2)} MB</small>`;
  let w=0;const bar=document.getElementById('upBar');
  const iv=setInterval(()=>{w+=5;bar.style.width=w+'%';if(w>=80)clearInterval(iv);},40);
  const rdr=new FileReader();
  rdr.onload=e=>{
    const img=document.getElementById('<%= imgBanner.ClientID %>');
    img.src=e.target.result;img.style.display='block';
  };
  rdr.readAsDataURL(f);
};

// Sync banner labels from server-side
(function(){
  const sl=document.getElementById('<%= lblStudents.ClientID %>'),
        bl=document.getElementById('<%= lblBStudents.ClientID %>');
  if(sl&&bl)bl.innerText=sl.innerText;
  const tl=document.getElementById('<%= lblTeachers.ClientID %>'),
        btl=document.getElementById('<%= lblBTeachers.ClientID %>');
  if(tl&&btl)btl.innerText=tl.innerText;
  const cl=document.getElementById('<%= lblCourses.ClientID %>'),
        bcl=document.getElementById('<%= lblBCourses.ClientID %>');
  if(cl&&bcl)bcl.innerText=cl.innerText;
  const al=document.getElementById('<%= lblAttPct.ClientID %>'),
        bal=document.getElementById('<%= lblBAtt.ClientID %>');
            if (al && bal) bal.innerText = al.innerText;
        })();

    })();
</script>
</asp:Content>
