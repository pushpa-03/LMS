<%@ Page Title="Course Wise Dashboard" Language="C#"
    MasterPageFile="~/Admin/AdminMaster.Master"
    AutoEventWireup="true"
    CodeBehind="CourseWiseDashboard.aspx.cs"
    Inherits="LearningManagementSystem.Admin.Dashboards.CourseWiseDashboard" %>

<asp:Content ID="cHead" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet"/>
<style>
/* ══════════════════════════ TOKENS ══════════════════════════ */
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
  --tx:#1e293b;--ts:#64748b;--tm:#94a3b8;
  --bd:#e2e8f0;--bg:#fff;--pg:#f1f5f9;
  --rad:14px;--rads:8px;--radc:50%;
  --sh:0 1px 3px rgba(0,0,0,.07),0 1px 2px rgba(0,0,0,.05);
  --shm:0 4px 16px rgba(0,0,0,.09);
  --shl:0 8px 30px rgba(0,0,0,.12);
}
*{box-sizing:border-box;margin:0;padding:0;}
body{background:var(--pg);font-family:'Inter','Segoe UI',system-ui,sans-serif;color:var(--tx);}

/* ─── Wrapper ─── */
.wrap{padding:24px;max-width:1600px;}

/* ─── Alert ─── */
.dash-alert{
  display:flex;align-items:center;gap:10px;
  padding:12px 18px;border-radius:var(--rads);
  font-size:13px;font-weight:500;margin-bottom:18px;
  animation:fadeDown .3s ease;
}
@keyframes fadeDown{from{opacity:0;transform:translateY(-8px)}to{opacity:1;transform:none}}
.alert-success{background:var(--gl);color:#065f46;border-left:3px solid var(--g);}
.alert-danger {background:var(--rl);color:#991b1b;border-left:3px solid var(--r);}
.alert-warning{background:var(--wl);color:#92400e;border-left:3px solid var(--w);}
.alert-info   {background:var(--bl);color:#1e40af;border-left:3px solid var(--b);}

/* ─── Top bar ─── */
.topbar{
  display:flex;align-items:center;justify-content:space-between;
  flex-wrap:wrap;gap:14px;margin-bottom:22px;
}
.tb-left h1{
  font-size:22px;font-weight:800;
  display:flex;align-items:center;gap:10px;
}
.tb-ico{
  width:38px;height:38px;background:var(--pl);color:var(--p);
  border-radius:11px;display:flex;align-items:center;justify-content:center;
  font-size:16px;flex-shrink:0;
}
.tb-left p{font-size:13px;color:var(--ts);margin-top:3px;padding-left:48px;}
.tb-right{display:flex;align-items:center;gap:10px;flex-wrap:wrap;}
.ddl{
  padding:9px 14px;border:1.5px solid var(--bd);border-radius:var(--rads);
  font-size:13px;color:var(--tx);background:#fff;cursor:pointer;
  font-weight:500;min-width:200px;transition:border-color .2s,box-shadow .2s;
}
.ddl:focus{border-color:var(--p);outline:none;box-shadow:0 0 0 3px rgba(79,70,229,.12);}
.sess-pill{
  background:var(--pl);color:var(--p);padding:7px 16px;
  border-radius:20px;font-size:12px;font-weight:700;
  display:inline-flex;align-items:center;gap:6px;white-space:nowrap;
}

/* ─── BANNER ─── */
.banner{
  position:relative;border-radius:var(--rad);overflow:hidden;
  margin-bottom:22px;min-height:180px;
  background:linear-gradient(135deg,#1a1460 0%,#3d31cb 48%,#7034d6 100%);
  box-shadow:var(--shm);
}
.b-bg{position:absolute;inset:0;width:100%;height:100%;object-fit:cover;z-index:0;display:block;}
.b-ov{position:absolute;inset:0;background:linear-gradient(100deg,rgba(10,6,60,.80),rgba(10,6,60,.20));z-index:1;}
.b-body{
  position:relative;z-index:2;display:flex;align-items:center;
  justify-content:space-between;padding:28px 36px;gap:24px;flex-wrap:wrap;
}
.b-left{}
.b-label{
  font-size:11px;font-weight:700;color:rgba(255,255,255,.58);
  text-transform:uppercase;letter-spacing:.1em;margin-bottom:6px;
}
.b-title{font-size:24px;font-weight:800;color:#fff;margin-bottom:4px;line-height:1.2;}
.b-sub  {font-size:13px;color:rgba(255,255,255,.70);}
.b-kpis {display:flex;gap:20px;margin-top:16px;flex-wrap:wrap;}
.bk     {text-align:center;}
.bk-v   {font-size:22px;font-weight:900;color:#fff;line-height:1;}
.bk-l   {font-size:10px;color:rgba(255,255,255,.58);text-transform:uppercase;letter-spacing:.05em;margin-top:2px;}
.b-divider{width:1px;background:rgba(255,255,255,.25);align-self:stretch;margin:0 4px;}

/* Upload zone */
.up-col{display:flex;flex-direction:column;align-items:flex-end;gap:8px;min-width:195px;}
.dz{
  width:195px;border:2px dashed rgba(255,255,255,.38);border-radius:10px;
  padding:14px 10px;text-align:center;cursor:pointer;
  transition:border-color .2s,background .2s;background:rgba(255,255,255,.07);
}
.dz:hover{border-color:rgba(255,255,255,.8);background:rgba(255,255,255,.14);}
.dz i{font-size:26px;color:#fff;display:block;margin-bottom:6px;}
.dz-txt{font-size:11px;color:rgba(255,255,255,.82);line-height:1.5;}
.btn-up{
  width:195px;padding:8px 0;background:#fff;color:var(--p);
  border:none;border-radius:var(--rads);font-size:12px;font-weight:700;
  cursor:pointer;transition:background .15s,transform .15s;letter-spacing:.01em;
}
.btn-up:hover{background:#f0efff;transform:translateY(-1px);}
.btn-rm{
  width:195px;padding:8px 0;background:rgba(255,255,255,.14);color:#fff;
  border:1px solid rgba(255,255,255,.32);border-radius:var(--rads);
  font-size:12px;font-weight:600;cursor:pointer;transition:.15s;
}
.btn-rm:hover{background:rgba(255,255,255,.26);}
.up-prog{width:195px;height:3px;background:rgba(255,255,255,.2);border-radius:2px;overflow:hidden;margin-top:2px;}
.up-bar {height:3px;background:#fff;width:0%;transition:width .35s;border-radius:2px;}

/* ─── KPI GRID ─── */
.kpi-grid{
  display:grid;
  grid-template-columns:repeat(auto-fit,minmax(155px,1fr));
  gap:14px;margin-bottom:22px;
}
.kpi{
  background:var(--bg);border:1px solid var(--bd);border-radius:var(--rad);
  padding:18px 16px;box-shadow:var(--sh);position:relative;overflow:hidden;
  transition:transform .18s,box-shadow .18s;cursor:default;
}
.kpi:hover{transform:translateY(-3px);box-shadow:var(--shm);}
.kpi::before{
  content:'';position:absolute;top:0;left:0;right:0;height:3px;
  border-radius:var(--rad) var(--rad) 0 0;
}
.kc-b::before{background:var(--b);}   .kc-g::before{background:var(--g);}
.kc-pu::before{background:var(--pu);} .kc-w::before{background:var(--w);}
.kc-t::before{background:var(--t);}   .kc-ro::before{background:var(--ro);}
.kc-cy::before{background:var(--cy);}
.kpi-top{display:flex;align-items:center;justify-content:space-between;margin-bottom:12px;}
.kpi-lbl{font-size:10px;font-weight:700;color:var(--ts);text-transform:uppercase;letter-spacing:.06em;}
.kpi-ico{
  width:40px;height:40px;border-radius:10px;
  display:flex;align-items:center;justify-content:center;font-size:17px;
}
.i-b {background:var(--bl);color:var(--b);}  .i-g {background:var(--gl);color:var(--g);}
.i-pu{background:var(--pul);color:var(--pu);} .i-w {background:var(--wl);color:var(--w);}
.i-t {background:var(--tl);color:var(--t);}   .i-ro{background:var(--rol);color:var(--ro);}
.i-cy{background:var(--cyl);color:var(--cy);}
.kpi-val{font-size:28px;font-weight:900;color:var(--tx);line-height:1;letter-spacing:-.5px;}
.kpi-sub{font-size:11px;color:var(--tm);margin-top:4px;}

/* ─── Course scroll ─── */
.course-scroll{
  display:flex;gap:12px;overflow-x:auto;padding-bottom:8px;margin-bottom:22px;
  scrollbar-width:thin;scrollbar-color:var(--bd) transparent;
}
.course-scroll::-webkit-scrollbar{height:4px;}
.course-scroll::-webkit-scrollbar-thumb{background:var(--bd);border-radius:4px;}
.cc{
  background:var(--bg);border:1.5px solid var(--bd);border-radius:var(--rad);
  padding:15px 17px;min-width:175px;flex-shrink:0;box-shadow:var(--sh);
  transition:border-color .18s,box-shadow .18s;cursor:pointer;
}
.cc:hover{border-color:var(--p);box-shadow:0 0 0 3px rgba(79,70,229,.12);}
.cc-name{font-size:13px;font-weight:700;color:var(--tx);margin-bottom:4px;}
.cc-stream{font-size:11px;color:var(--ts);margin-bottom:10px;}
.cc-row{display:flex;justify-content:space-between;font-size:12px;margin-bottom:4px;}
.cc-row span:first-child{color:var(--ts);}
.cc-row span:last-child{font-weight:700;color:var(--tx);}
.att-bar{height:5px;background:var(--bd);border-radius:99px;margin-top:10px;overflow:hidden;}
.att-fill{height:5px;background:var(--g);border-radius:99px;width:0%;transition:width 1.2s ease;}
.att-lbl{font-size:10px;color:var(--ts);text-align:right;margin-top:3px;}

/* ─── Card ─── */
.card{
  background:var(--bg);border:1px solid var(--bd);border-radius:var(--rad);
  box-shadow:var(--sh);padding:20px;transition:box-shadow .18s;
}
.card:hover{box-shadow:var(--shm);}
.card-hd{
  display:flex;align-items:flex-start;justify-content:space-between;
  margin-bottom:18px;gap:10px;flex-wrap:wrap;
}
.card-hd-l{display:flex;align-items:center;gap:10px;}
.c-ico{
  width:34px;height:34px;border-radius:9px;
  display:flex;align-items:center;justify-content:center;font-size:15px;flex-shrink:0;
}
.c-title{font-size:14px;font-weight:700;color:var(--tx);}
.c-sub{font-size:12px;color:var(--ts);margin-top:2px;}
.chart-box{position:relative;width:100%;}

/* ─── Grid layouts ─── */
.g2 {display:grid;grid-template-columns:1fr 1fr;gap:16px;margin-bottom:20px;}
.g3 {display:grid;grid-template-columns:1fr 1fr 1fr;gap:16px;margin-bottom:20px;}
.g21{display:grid;grid-template-columns:2fr 1fr;gap:16px;margin-bottom:20px;}
.g12{display:grid;grid-template-columns:1fr 2fr;gap:16px;margin-bottom:20px;}
.g13{display:grid;grid-template-columns:1fr 3fr;gap:16px;margin-bottom:20px;}

/* ─── Subject table ─── */
.tbl{width:100%;border-collapse:collapse;font-size:13px;}
.tbl th{
  font-size:10px;font-weight:700;color:var(--ts);text-transform:uppercase;
  letter-spacing:.05em;padding:0 12px 12px;border-bottom:2px solid var(--bd);
  text-align:left;white-space:nowrap;
}
.tbl td{padding:11px 12px;border-bottom:1px solid var(--bd);vertical-align:middle;}
.tbl tr:last-child td{border-bottom:none;}
.tbl tbody tr{transition:background .12s;}
.tbl tbody tr:hover td{background:#f7f8ff;}
.snum{font-size:11px;color:var(--tm);font-weight:500;}
.sname{font-weight:600;color:var(--tx);}
.scode{
  display:inline-block;font-size:10px;background:var(--pl);color:var(--p);
  padding:2px 8px;border-radius:99px;font-weight:700;letter-spacing:.02em;
}
.chip{
  display:inline-flex;align-items:center;gap:3px;
  padding:3px 9px;border-radius:99px;font-size:11px;font-weight:600;white-space:nowrap;
}
.chip i{font-size:10px;}
.cv {background:var(--bl);color:#1d4ed8;}
.ca {background:var(--wl);color:#92400e;}
.cq {background:var(--pul);color:#6d28d9;}
.cat{background:var(--gl);color:#065f46;}

/* ─── Progress bars (assignment rate) ─── */
.pi{margin-bottom:14px;}
.pi-lbl{display:flex;justify-content:space-between;font-size:12px;font-weight:500;color:var(--tx);margin-bottom:5px;}
.pi-lbl span:last-child{color:var(--ts);}
.pi-track{height:8px;background:var(--bd);border-radius:99px;overflow:hidden;}
.pi-fill{height:8px;border-radius:99px;transition:width 1.1s ease;width:0%;}

/* ─── Top students ─── */
.stu-item{
  display:flex;align-items:center;gap:12px;
  padding:11px 0;border-bottom:1px solid var(--bd);
  transition:background .12s;
}
.stu-item:last-child{border-bottom:none;}
.stu-item:hover{background:#f8f9ff;margin:0 -20px;padding-left:20px;padding-right:20px;}
.stu-rank{
  width:24px;height:24px;border-radius:50%;
  display:flex;align-items:center;justify-content:center;
  font-size:11px;font-weight:800;flex-shrink:0;
}
.rank-1{background:#fef3c7;color:#b45309;}
.rank-2{background:#f3f4f6;color:#374151;}
.rank-3{background:#fde8d8;color:#c05621;}
.rank-n{background:var(--pg);color:var(--ts);}
.av{
  width:40px;height:40px;border-radius:50%;background:var(--pl);color:var(--p);
  display:flex;align-items:center;justify-content:center;font-size:16px;font-weight:800;
  flex-shrink:0;overflow:hidden;border:2px solid var(--bd);
}
.av img{width:100%;height:100%;object-fit:cover;}
.stu-name{font-size:13px;font-weight:700;color:var(--tx);}
.stu-roll{font-size:11px;color:var(--ts);margin-top:1px;}
.stu-sem {font-size:10px;color:var(--tm);margin-top:1px;}
.stu-right{margin-left:auto;text-align:right;flex-shrink:0;}
.grade-a{background:#d1fae5;color:#065f46;padding:3px 10px;border-radius:99px;font-size:12px;font-weight:800;}
.grade-b{background:#dbeafe;color:#1e40af;padding:3px 10px;border-radius:99px;font-size:12px;font-weight:800;}
.grade-c{background:#fef3c7;color:#92400e;padding:3px 10px;border-radius:99px;font-size:12px;font-weight:800;}
.grade-f{background:#fee2e2;color:#991b1b;padding:3px 10px;border-radius:99px;font-size:12px;font-weight:800;}
.grade-none{background:var(--pg);color:var(--ts);padding:3px 10px;border-radius:99px;font-size:12px;font-weight:700;}
.stu-att{font-size:11px;color:var(--ts);margin-top:3px;}

/* ─── Quiz rows ─── */
.quiz-item{
  display:flex;align-items:center;gap:12px;
  padding:10px 0;border-bottom:1px solid var(--bd);
}
.quiz-item:last-child{border-bottom:none;}
.quiz-ico{
  width:36px;height:36px;border-radius:9px;background:var(--pul);color:var(--pu);
  display:flex;align-items:center;justify-content:center;font-size:14px;flex-shrink:0;
}
.quiz-title{font-size:13px;font-weight:600;color:var(--tx);}
.quiz-meta{font-size:11px;color:var(--ts);margin-top:2px;}
.quiz-right{margin-left:auto;text-align:right;flex-shrink:0;}
.quiz-score{font-size:14px;font-weight:800;color:var(--p);}
.quiz-pass{font-size:10px;color:var(--ts);margin-top:1px;}
.pass-pill{
  display:inline-block;font-size:10px;font-weight:700;padding:2px 8px;border-radius:99px;
}
.pp-g{background:var(--gl);color:#065f46;}
.pp-w{background:var(--wl);color:#92400e;}
.pp-r{background:var(--rl);color:#991b1b;}

/* ─── Empty state ─── */
.empty{text-align:center;padding:40px;color:var(--tm);}
.empty i{font-size:34px;display:block;margin-bottom:10px;opacity:.4;}
.empty p{font-size:13px;}

/* ─── Responsive ─── */
@media(max-width:1200px){.g3{grid-template-columns:1fr 1fr;}.g21{grid-template-columns:1fr;}.g12{grid-template-columns:1fr;}}
@media(max-width:800px) {.g2,.g3{grid-template-columns:1fr;}.kpi-grid{grid-template-columns:1fr 1fr 1fr;}}
@media(max-width:520px) {.kpi-grid{grid-template-columns:1fr 1fr;}.topbar{flex-direction:column;align-items:flex-start;}}
</style>
</asp:Content>

<asp:Content ID="cBody" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

<%-- ══ Hidden fields — all synced with code-behind ══ --%>
<asp:HiddenField ID="hdnTrendMonths"    runat="server"/>
<asp:HiddenField ID="hdnTrendStudents"  runat="server"/>
<asp:HiddenField ID="hdnLevelLabels"    runat="server"/>
<asp:HiddenField ID="hdnLevelStudents"  runat="server"/>
<asp:HiddenField ID="hdnSemLabels"      runat="server"/>
<asp:HiddenField ID="hdnSemStudents"    runat="server"/>
<asp:HiddenField ID="hdnAttWeeks"       runat="server"/>
<asp:HiddenField ID="hdnAttPct"         runat="server"/>
<asp:HiddenField ID="hdnAttPresent"     runat="server"/>
<asp:HiddenField ID="hdnAttAbsent"      runat="server"/>
<asp:HiddenField ID="hdnSubjNames"      runat="server"/>
<asp:HiddenField ID="hdnSubjVideos"     runat="server"/>
<asp:HiddenField ID="hdnSubjAssign"     runat="server"/>
<asp:HiddenField ID="hdnSubjQuizzes"    runat="server"/>
<asp:HiddenField ID="hdnSubjAtt"        runat="server"/>
<asp:HiddenField ID="hdnSubjScore"      runat="server"/>
<asp:HiddenField ID="hdnQuizTitles"     runat="server"/>
<asp:HiddenField ID="hdnQuizAvg"        runat="server"/>
<asp:HiddenField ID="hdnQuizPass"       runat="server"/>
<asp:HiddenField ID="hdnQuizHigh"       runat="server"/>
<asp:HiddenField ID="hdnGenderLabels"   runat="server"/>
<asp:HiddenField ID="hdnGenderVals"     runat="server"/>
<asp:HiddenField ID="hdnSecLabels"      runat="server"/>
<asp:HiddenField ID="hdnSecStudents"    runat="server"/>
<asp:HiddenField ID="hdnAssignSubjects" runat="server"/>
<asp:HiddenField ID="hdnAssignRate"     runat="server"/>
<asp:HiddenField ID="hdnAssignTotal"    runat="server"/>
<asp:HiddenField ID="hdnAssignSubmitted" runat="server"/>
<asp:HiddenField ID="hdnBannerPath"     runat="server"/>

<div class="wrap">

  <%-- ══ Alert panel ══ --%>
  <asp:Panel ID="pnlAlert" runat="server" Visible="false" CssClass="dash-alert">
    <i class="fa fa-circle-exclamation"></i>
    <asp:Label ID="lblAlert" runat="server"/>
  </asp:Panel>

  <%-- ══ TOP BAR ══ --%>
  <div class="topbar">
    <div class="tb-left">
      <h1>
        <span class="tb-ico"><i class="fa fa-graduation-cap"></i></span>
        Course Wise Dashboard
      </h1>
      <p>
        Deep analytics by course &mdash;
        <strong><asp:Label ID="lblCourseTitle" runat="server" Text="All Courses"/></strong>
        &nbsp;&bull;&nbsp; Stream: <asp:Label ID="lblStreamName" runat="server" Text="All"/>
      </p>
    </div>
    <div class="tb-right">
      <asp:DropDownList ID="ddlCourse" runat="server" CssClass="ddl"
        AutoPostBack="true"
        OnSelectedIndexChanged="ddlCourse_SelectedIndexChanged"/>
      <span class="sess-pill">
        <i class="fa fa-calendar-check"></i>
        <asp:Label ID="lblSessionBadge" runat="server"/>
      </span>
    </div>
  </div>

  <%-- ══ BANNER + UPLOAD ══ --%>
  <div class="banner">
    <asp:Image ID="imgBanner" runat="server" Visible="false" CssClass="b-bg" AlternateText="Course Banner"/>
    <div class="b-ov"></div>
    <div class="b-body">
      <div class="b-left">
        <div class="b-label"><i class="fa fa-graduation-cap" style="margin-right:5px;"></i>Course Analytics</div>
        <div class="b-title"><asp:Label ID="lblBannerCourse" runat="server" Text="Course Overview"/></div>
        <div class="b-sub">Session: <asp:Label ID="lblSessionBadge2" runat="server"/>
          &nbsp;&bull;&nbsp; Stream: <asp:Label ID="lblStreamName2" runat="server" Text="All"/>
        </div>
        <div class="b-kpis">
          <div class="bk">
            <div class="bk-v"><asp:Label ID="lblStudents"  runat="server" Text="0"/></div>
            <div class="bk-l">Students</div>
          </div>
          <div class="b-divider"></div>
          <div class="bk">
            <div class="bk-v"><asp:Label ID="lblSubjects"  runat="server" Text="0"/></div>
            <div class="bk-l">Subjects</div>
          </div>
          <div class="b-divider"></div>
          <div class="bk">
            <div class="bk-v"><asp:Label ID="lblSections"  runat="server" Text="0"/></div>
            <div class="bk-l">Sections</div>
          </div>
          <div class="b-divider"></div>
          <div class="bk">
            <div class="bk-v"><asp:Label ID="lblAttPct"    runat="server" Text="0%"/></div>
            <div class="bk-l">Attendance</div>
          </div>
          <div class="b-divider"></div>
          <div class="bk">
            <div class="bk-v"><asp:Label ID="lblAvgQuiz"   runat="server" Text="0"/></div>
            <div class="bk-l">Avg Quiz</div>
          </div>
        </div>
      </div>

      <%-- Upload column --%>
      <div class="up-col">
        <div class="dz" onclick="document.getElementById('fpick').click();">
          <i class="fa fa-cloud-arrow-up"></i>
          <div class="dz-txt" id="dzTxt">
            Choose banner image<br/>
            <small style="opacity:.7;">JPG · PNG · WebP &nbsp;|&nbsp; Max 5 MB</small>
          </div>
        </div>
        <%-- Hidden real file input; syncs file to ASP FileUpload via JS --%>
        <input type="file" id="fpick" accept="image/jpeg,image/png,image/webp,image/gif"
               style="display:none;" onchange="onBannerPick(this)"/>
        <asp:FileUpload ID="fuBanner" runat="server" Style="display:none;"/>
        <div class="up-prog"><div class="up-bar" id="upBar"></div></div>
        <asp:Button ID="btnUploadBanner" runat="server" Text="⬆  Upload Banner"
          CssClass="btn-up" OnClick="btnUploadBanner_Click"
          OnClientClick="return syncFileToAsp();"/>
        <asp:Button ID="btnRemoveBanner" runat="server" Text="✕  Remove Banner"
          CssClass="btn-rm" OnClick="btnRemoveBanner_Click"/>
      </div>
    </div>
  </div>

  <%-- ══ KPI CARDS ══ --%>
  <div class="kpi-grid">
    <div class="kpi kc-b">
      <div class="kpi-top">
        <span class="kpi-lbl">Total Students</span>
        <div class="kpi-ico i-b"><i class="fa fa-users"></i></div>
      </div>
      <%-- lblStudents already in banner; create separate display labels --%>
      <div class="kpi-val" id="kStudents">0</div>
      <div class="kpi-sub">Enrolled this session</div>
    </div>
    <div class="kpi kc-g">
      <div class="kpi-top">
        <span class="kpi-lbl">Attendance</span>
        <div class="kpi-ico i-g"><i class="fa fa-calendar-check"></i></div>
      </div>
      <div class="kpi-val" id="kAtt">0%</div>
      <div class="kpi-sub">Course average</div>
    </div>
    <div class="kpi kc-pu">
      <div class="kpi-top">
        <span class="kpi-lbl">Subjects</span>
        <div class="kpi-ico i-pu"><i class="fa fa-book-open"></i></div>
      </div>
      <div class="kpi-val" id="kSubj">0</div>
      <div class="kpi-sub">Mapped to course</div>
    </div>
    <div class="kpi kc-w">
      <div class="kpi-top">
        <span class="kpi-lbl">Sections</span>
        <div class="kpi-ico i-w"><i class="fa fa-sitemap"></i></div>
      </div>
      <div class="kpi-val" id="kSec">0</div>
      <div class="kpi-sub">Active sections</div>
    </div>
    <div class="kpi kc-t">
      <div class="kpi-top">
        <span class="kpi-lbl">Assignments Sub.</span>
        <div class="kpi-ico i-t"><i class="fa fa-clipboard-check"></i></div>
      </div>
      <div class="kpi-val" id="kAssign">0</div>
      <div class="kpi-sub"><asp:Label ID="lblAssignSub" runat="server" Text="0"/></div>
    </div>
    <div class="kpi kc-ro">
      <div class="kpi-top">
        <span class="kpi-lbl">Quiz Attempts</span>
        <div class="kpi-ico i-ro"><i class="fa fa-circle-question"></i></div>
      </div>
      <div class="kpi-val" id="kQuiz">0</div>
      <div class="kpi-sub"><asp:Label ID="lblQuizAttempts" runat="server" Text="0"/></div>
    </div>
    <div class="kpi kc-cy">
      <div class="kpi-top">
        <span class="kpi-lbl">Avg Quiz Score</span>
        <div class="kpi-ico i-cy"><i class="fa fa-chart-simple"></i></div>
      </div>
      <div class="kpi-val" id="kAvgQ">0</div>
      <div class="kpi-sub">Out of 100</div>
    </div>
  </div>

  <%-- ══ COURSE MINI-CARDS SCROLL ══ --%>
  <div class="course-scroll">
    <asp:Repeater ID="rptCourseCards" runat="server">
      <ItemTemplate>
        <div class="cc">
          <div class="cc-name"><%# Server.HtmlEncode(Eval("CourseName").ToString()) %></div>
          <div class="cc-stream"><%# Eval("StreamName") %></div>
          <div class="cc-row"><span>Students</span><span><%# Eval("TotalStudents") %></span></div>
          <div class="cc-row"><span>Subjects</span><span><%# Eval("TotalSubjects") %></span></div>
          <div class="cc-row"><span>Sections</span><span><%# Eval("TotalSections") %></span></div>
          <div class="att-bar">
            <div class="att-fill" style="width:<%# Eval("AttendancePct") ?? 0 %>%"></div>
          </div>
          <div class="att-lbl"><%# FmtDec(Eval("AttendancePct")) %>% attendance</div>
        </div>
      </ItemTemplate>
    </asp:Repeater>
  </div>

  <%-- ══ ROW 1: Enrollment Trend + Attendance by Week ══ --%>
  <div class="g21">
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="c-ico" style="background:var(--pl);color:var(--p);"><i class="fa fa-arrow-trend-up"></i></div>
          <div>
            <div class="c-title">Monthly Enrollment Trend</div>
            <div class="c-sub">New students joining over last 6 months</div>
          </div>
        </div>
        <span id="trendTotal" style="font-size:11px;color:var(--tm);"></span>
      </div>
      <div class="chart-box" style="height:250px;"><canvas id="chartTrend"></canvas></div>
    </div>
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="c-ico" style="background:var(--gl);color:var(--g);"><i class="fa fa-calendar-week"></i></div>
          <div>
            <div class="c-title">Weekly Attendance</div>
            <div class="c-sub">Last 4 weeks — Present vs Absent</div>
          </div>
        </div>
      </div>
      <div class="chart-box" style="height:250px;"><canvas id="chartAttWeek"></canvas></div>
    </div>
  </div>

  <%-- ══ ROW 2: Level + Semester + Gender ══ --%>
  <div class="g3">
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="c-ico" style="background:var(--pul);color:var(--pu);"><i class="fa fa-layer-group"></i></div>
          <div>
            <div class="c-title">Students by Level</div>
            <div class="c-sub">Study level distribution</div>
          </div>
        </div>
      </div>
      <div class="chart-box" style="height:220px;"><canvas id="chartLevel"></canvas></div>
    </div>
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="c-ico" style="background:var(--cyl);color:var(--cy);"><i class="fa fa-list-ol"></i></div>
          <div>
            <div class="c-title">Students by Semester</div>
            <div class="c-sub">Current session semesters</div>
          </div>
        </div>
      </div>
      <div class="chart-box" style="height:220px;"><canvas id="chartSem"></canvas></div>
    </div>
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="c-ico" style="background:var(--rol);color:var(--ro);"><i class="fa fa-venus-mars"></i></div>
          <div>
            <div class="c-title">Gender Distribution</div>
            <div class="c-sub">Male / Female / Other</div>
          </div>
        </div>
      </div>
      <div class="chart-box" style="height:175px;"><canvas id="chartGender"></canvas></div>
      <div id="gLeg" style="display:flex;flex-wrap:wrap;gap:8px;justify-content:center;margin-top:10px;"></div>
    </div>
  </div>

  <%-- ══ ROW 3: Subject Performance chart + Section pie ══ --%>
  <div class="g21">
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="c-ico" style="background:var(--wl);color:var(--w);"><i class="fa fa-chart-bar"></i></div>
          <div>
            <div class="c-title">Subject Content Overview</div>
            <div class="c-sub">Videos · Assignments · Quizzes per subject</div>
          </div>
        </div>
      </div>
      <div class="chart-box" style="height:250px;"><canvas id="chartSubjContent"></canvas></div>
    </div>
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="c-ico" style="background:var(--bl);color:var(--b);"><i class="fa fa-sitemap"></i></div>
          <div>
            <div class="c-title">Students by Section</div>
            <div class="c-sub">Section-wise distribution</div>
          </div>
        </div>
      </div>
      <div class="chart-box" style="height:215px;"><canvas id="chartSec"></canvas></div>
      <div id="secLeg" style="display:flex;flex-wrap:wrap;gap:8px;justify-content:center;margin-top:10px;"></div>
    </div>
  </div>

  <%-- ══ ROW 4: Subject Avg Score radar + Attendance % bar ══ --%>
  <div class="g2">
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="c-ico" style="background:var(--tl);color:var(--t);"><i class="fa fa-chart-pie"></i></div>
          <div>
            <div class="c-title">Subject Avg Score vs Attendance %</div>
            <div class="c-sub">Mixed axis — score (bar) · attendance (line)</div>
          </div>
        </div>
      </div>
      <div class="chart-box" style="height:250px;"><canvas id="chartSubjPerf"></canvas></div>
    </div>
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="c-ico" style="background:var(--wl);color:var(--w);"><i class="fa fa-clipboard-check"></i></div>
          <div>
            <div class="c-title">Assignment Submission Rate</div>
            <div class="c-sub">% submitted per subject</div>
          </div>
        </div>
      </div>
      <div id="assignBars" style="padding-top:6px;"></div>
    </div>
  </div>

  <%-- ══ ROW 5: Quiz performance + Top students ══ --%>
  <div class="g12">
    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="c-ico" style="background:var(--pul);color:var(--pu);"><i class="fa fa-trophy"></i></div>
          <div>
            <div class="c-title">Quiz Results</div>
            <div class="c-sub">Avg score &amp; pass rate per quiz</div>
          </div>
        </div>
      </div>
      <asp:Repeater ID="rptQuizzes" runat="server">
        <ItemTemplate>
          <div class="quiz-item">
            <div class="quiz-ico"><i class="fa fa-circle-question"></i></div>
            <div style="flex:1;min-width:0;">
              <div class="quiz-title"><%# Server.HtmlEncode(Eval("QuizTitle").ToString()) %></div>
              <div class="quiz-meta">
                <%# Eval("Attempts") %> attempts &nbsp;&bull;&nbsp;
                High: <%# Eval("HighScore") %>
              </div>
            </div>
            <div class="quiz-right">
              <div class="quiz-score"><%# FmtDec(Eval("AvgScore")) %></div>
              <div class="quiz-pass">
                <span class="pass-pill <%# Convert.ToDouble(Eval("PassRate") is DBNull ? 0 : Eval("PassRate")) >= 60 ? "pp-g" : Convert.ToDouble(Eval("PassRate") is DBNull ? 0 : Eval("PassRate")) >= 33 ? "pp-w" : "pp-r" %>">
                  <%# FmtDec(Eval("PassRate")) %>% pass
                </span>
              </div>
            </div>
          </div>
        </ItemTemplate>
        <FooterTemplate>
          <%# rptQuizzes.Items.Count == 0
              ? "<div class='empty'><i class='fa fa-circle-question'></i><p>No quiz data found</p></div>"
              : "" %>
        </FooterTemplate>
      </asp:Repeater>
    </div>

    <div class="card">
      <div class="card-hd">
        <div class="card-hd-l">
          <div class="c-ico" style="background:var(--wl);color:var(--w);"><i class="fa fa-medal"></i></div>
          <div>
            <div class="c-title">Top Performing Students</div>
            <div class="c-sub">Ranked by avg quiz score + attendance</div>
          </div>
        </div>
        <span style="font-size:11px;color:var(--tm);">Top 8</span>
      </div>
      <asp:Repeater ID="rptTopStudents" runat="server">
        <ItemTemplate>
          <div class="stu-item">
            <div class="stu-rank <%# Container.ItemIndex < 3 ? "rank-"+(Container.ItemIndex+1) : "rank-n" %>">
              <%# Container.ItemIndex + 1 %>
            </div>
            <div class="av">
              <%# !string.IsNullOrEmpty(Eval("ProfileImage")?.ToString())
                  ? string.Format("<img src='{0}' alt=''/>", Server.HtmlEncode(Eval("ProfileImage").ToString()))
                  : AvatarInitial(Eval("FullName")) %>
            </div>
            <div style="flex:1;min-width:0;">
              <div class="stu-name"><%# Server.HtmlEncode(Eval("FullName").ToString()) %></div>
              <div class="stu-roll">Roll: <%# Eval("RollNumber") %></div>
              <div class="stu-sem"><%# Eval("SemesterName") %></div>
            </div>
            <div class="stu-right">
              <span class="<%# GetGradeClass(Eval("AvgScore")) %>">
                <%# GetGrade(Eval("AvgScore")) %> &nbsp;<%# FmtDec(Eval("AvgScore")) %>
              </span>
              <div class="stu-att">
                <i class="fa fa-calendar-check" style="color:var(--g);margin-right:3px;"></i>
                <%# FmtDec(Eval("AttPct")) %>% &nbsp;&bull;&nbsp;
                <%# Eval("Submissions") %> sub.
              </div>
            </div>
          </div>
        </ItemTemplate>
        <FooterTemplate>
          <%# rptTopStudents.Items.Count == 0
              ? "<div class='empty'><i class='fa fa-users'></i><p>No student data found</p></div>"
              : "" %>
        </FooterTemplate>
      </asp:Repeater>
    </div>
  </div>

  <%-- ══ ROW 6: Subject details table ══ --%>
  <div class="card" style="margin-bottom:20px;">
    <div class="card-hd">
      <div class="card-hd-l">
        <div class="c-ico" style="background:var(--bl);color:var(--b);"><i class="fa fa-table-list"></i></div>
        <div>
          <div class="c-title">Subject Detail Table</div>
          <div class="c-sub">Content, performance &amp; engagement — Top 8 subjects</div>
        </div>
      </div>
    </div>
    <div style="overflow-x:auto;">
      <table class="tbl">
        <thead>
          <tr>
            <th>#</th>
            <th>Subject</th>
            <th>Code</th>
            <th>Videos</th>
            <th>Assignments</th>
            <th>Quizzes</th>
            <th>Avg Score</th>
            <th>Attendance %</th>
          </tr>
        </thead>
        <tbody>
          <asp:Repeater ID="rptSubjects" runat="server">
            <ItemTemplate>
              <tr>
                <td class="snum"><%# Container.ItemIndex + 1 %></td>
                <td class="sname"><%# Server.HtmlEncode(Eval("SubjectName").ToString()) %></td>
                <td>
                  <span class="scode">
                    <%# string.IsNullOrWhiteSpace(Eval("SubjectCode")?.ToString()) ? "—" : Server.HtmlEncode(Eval("SubjectCode").ToString()) %>
                  </span>
                </td>
                <td><span class="chip cv"><i class="fa fa-video"></i><%# Eval("Videos") %></span></td>
                <td><span class="chip ca"><i class="fa fa-clipboard"></i><%# Eval("Assignments") %></span></td>
                <td><span class="chip cq"><i class="fa fa-circle-question"></i><%# Eval("Quizzes") %></span></td>
                <td>
                  <strong style="color:<%# GetGradeColor(Eval("AvgScore")) %>;">
                    <%# FmtDec(Eval("AvgScore")) %>
                  </strong>
                  <span style="font-size:11px;color:var(--ts);margin-left:4px;">(<%# GetGrade(Eval("AvgScore")) %>)</span>
                </td>
                <td>
                  <span class="chip cat"><i class="fa fa-calendar-check"></i><%# FmtDec(Eval("AttPct")) %>%</span>
                </td>
              </tr>
            </ItemTemplate>
            <FooterTemplate>
              <%# rptSubjects.Items.Count == 0
                  ? "<tr><td colspan='8'><div class='empty'><i class='fa fa-book-open'></i><p>No subjects found for this course</p></div></td></tr>"
                  : "" %>
            </FooterTemplate>
          </asp:Repeater>
        </tbody>
      </table>
    </div>
  </div>

</div><%-- /wrap --%>

<%-- ══ Chart.js ══ --%>
<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.4.1/chart.umd.min.js"></script>
<script>
    (function () {
        'use strict';

        /* ── helpers ── */
        const hf = id => {
            try { return JSON.parse(document.getElementById(id)?.value || '[]'); }
            catch { return []; }
        };
        const lbl = id => document.getElementById(id)?.innerText?.trim() || '0';

        /* Push KPI values from banner labels into card divs */
        document.getElementById('kStudents').innerText = lbl('<%= lblStudents.ClientID %>');
document.getElementById('kAtt'     ).innerText = lbl('<%= lblAttPct.ClientID %>');
document.getElementById('kSubj'    ).innerText = lbl('<%= lblSubjects.ClientID %>');
document.getElementById('kSec'     ).innerText = lbl('<%= lblSections.ClientID %>');
document.getElementById('kAssign'  ).innerText = lbl('<%= lblAssignSub.ClientID %>');
document.getElementById('kQuiz'    ).innerText = lbl('<%= lblQuizAttempts.ClientID %>');
document.getElementById('kAvgQ'    ).innerText = lbl('<%= lblAvgQuiz.ClientID %>');

/* Sync banner session label */
const sLbl = document.getElementById('<%= lblSessionBadge2.ClientID %>');
if (sLbl) sLbl.innerText = document.getElementById('<%= lblSessionBadge.ClientID %>')?.innerText || '';
const s2 = document.getElementById('<%= lblStreamName2.ClientID %>');
if (s2) s2.innerText = document.getElementById('<%= lblStreamName.ClientID %>')?.innerText || '';

/* ── Palette & shared config ── */
const PAL  = ['#4f46e5','#10b981','#f59e0b','#ef4444','#8b5cf6','#3b82f6','#0d9488','#f43f5e','#0891b2','#ec4899'];
const palA = (a) => PAL.map(c => c + Math.round(a * 255).toString(16).padStart(2,'0'));
const GRD  = { color:'rgba(148,163,184,.12)' };
const TICK = { font:{ size:11, family:"'Inter','Segoe UI',sans-serif" } };
const TT   = { padding:10, cornerRadius:8, bodyFont:{size:12}, titleFont:{size:12,weight:'bold'} };
const ANIM = { duration:1000, easing:'easeInOutQuart' };
const noLeg = { legend:{display:false} };

function gradV(ctx, h, c1, c2) {
    const g = ctx.createLinearGradient(0,0,0,h);
    g.addColorStop(0, c1); g.addColorStop(1, c2); return g;
}
function empty(id, msg) {
    const el = document.getElementById(id);
    if (el) el.closest('.chart-box').innerHTML =
        `<div class="empty"><i class="fa fa-chart-simple"></i><p>${msg||'No data available'}</p></div>`;
}

/* ────────────────────────────────────────────────────
   1. Enrollment Trend — gradient area line chart
──────────────────────────────────────────────────── */
(function () {
    const months = hf('<%= hdnTrendMonths.ClientID %>');
    const data   = hf('<%= hdnTrendStudents.ClientID %>');
    if (!months.length) { empty('chartTrend','No enrollment data'); return; }

    const total = data.reduce((a,b)=>a+b,0);
    const tEl = document.getElementById('trendTotal');
    if (tEl) tEl.innerText = `${total} total`;

    const ctx  = document.getElementById('chartTrend').getContext('2d');
    const grad = gradV(ctx, 230, 'rgba(79,70,229,.30)', 'rgba(79,70,229,.01)');
    new Chart(ctx, {
        type:'line',
        data:{ labels:months, datasets:[{
            label:'New Students', data,
            borderColor:'#4f46e5', backgroundColor:grad,
            borderWidth:2.5, tension:.42, fill:true,
            pointBackgroundColor:'#4f46e5', pointRadius:5,
            pointHoverRadius:8, pointHoverBackgroundColor:'#fff',
            pointHoverBorderColor:'#4f46e5', pointHoverBorderWidth:2
        }]},
        options:{
            responsive:true, maintainAspectRatio:false,
            plugins:{ ...noLeg, tooltip:{ ...TT, callbacks:{ label:c=>' '+c.raw+' students' } } },
            scales:{
                x:{ grid:{display:false}, ticks:TICK },
                y:{ beginAtZero:true, grid:GRD, ticks:TICK }
            },
            animation:ANIM
        }
    });
})();

/* ────────────────────────────────────────────────────
   2. Weekly Attendance — stacked bar (Present + Absent)
──────────────────────────────────────────────────── */
(function () {
    const weeks   = hf('<%= hdnAttWeeks.ClientID %>');
    const present = hf('<%= hdnAttPresent.ClientID %>');
    const absent  = hf('<%= hdnAttAbsent.ClientID %>');
    if (!weeks.length) { empty('chartAttWeek','No attendance data'); return; }

    new Chart(document.getElementById('chartAttWeek'), {
        type:'bar',
        data:{ labels:weeks, datasets:[
            { label:'Present', data:present, backgroundColor:'#10b981', borderRadius:4, stack:'s' },
            { label:'Absent',  data:absent,  backgroundColor:'#ef4444', borderRadius:4, stack:'s' }
        ]},
        options:{
            responsive:true, maintainAspectRatio:false,
            interaction:{ mode:'index', intersect:false },
            plugins:{
                legend:{ position:'top', labels:{ boxWidth:10, font:{size:11} } },
                tooltip:{ ...TT }
            },
            scales:{
                x:{ grid:{display:false}, ticks:TICK, stacked:true },
                y:{ grid:GRD, ticks:TICK, stacked:true }
            },
            animation:ANIM
        }
    });
})();

/* ────────────────────────────────────────────────────
   3. Level — horizontal bar
──────────────────────────────────────────────────── */
(function () {
    const labels = hf('<%= hdnLevelLabels.ClientID %>');
    const data   = hf('<%= hdnLevelStudents.ClientID %>');
    if (!labels.length) { empty('chartLevel','No level data'); return; }

    new Chart(document.getElementById('chartLevel'), {
        type:'bar',
        data:{ labels, datasets:[{
            label:'Students', data,
            backgroundColor:palA(.82), borderRadius:6, borderSkipped:false
        }]},
        options:{
            indexAxis:'y', responsive:true, maintainAspectRatio:false,
            plugins:{ ...noLeg, tooltip:TT },
            scales:{ x:{ beginAtZero:true, grid:GRD, ticks:TICK }, y:{ grid:{display:false}, ticks:{font:{size:11}} } },
            animation:ANIM
        }
    });
})();

/* ────────────────────────────────────────────────────
   4. Semester — doughnut
──────────────────────────────────────────────────── */
(function () {
    const labels = hf('<%= hdnSemLabels.ClientID %>');
    const data   = hf('<%= hdnSemStudents.ClientID %>');
    if (!labels.length) { empty('chartSem','No semester data'); return; }

    new Chart(document.getElementById('chartSem'), {
        type:'doughnut',
        data:{ labels, datasets:[{ data, backgroundColor:palA(.85), borderWidth:2, borderColor:'#fff', hoverOffset:8 }] },
        options:{
            cutout:'58%', responsive:true, maintainAspectRatio:false,
            plugins:{ legend:{ position:'right', labels:{ boxWidth:10, font:{size:11} } }, tooltip:TT },
            animation:{ animateRotate:true, duration:1100 }
        }
    });
})();

/* ────────────────────────────────────────────────────
   5. Gender — doughnut
──────────────────────────────────────────────────── */
(function () {
    const labels = hf('<%= hdnGenderLabels.ClientID %>');
    const data   = hf('<%= hdnGenderVals.ClientID %>');
    if (!labels.length) { empty('chartGender','No gender data'); return; }

    const GCOL = ['#4f46e5','#f43f5e','#10b981','#f59e0b','#3b82f6'];
    new Chart(document.getElementById('chartGender'), {
        type:'doughnut',
        data:{ labels, datasets:[{ data, backgroundColor:GCOL, borderWidth:3, borderColor:'#fff', hoverOffset:8 }] },
        options:{
            cutout:'65%', responsive:true, maintainAspectRatio:false,
            plugins:{ legend:{display:false}, tooltip:TT },
            animation:{ animateRotate:true, duration:1100 }
        }
    });
    const total = data.reduce((a,b)=>a+b,0) || 1;
    const leg = document.getElementById('gLeg');
    labels.forEach((l,i) => {
        leg.innerHTML += `<div style="display:flex;align-items:center;gap:5px;font-size:12px;">
            <span style="width:10px;height:10px;border-radius:2px;background:${GCOL[i]};display:inline-block;flex-shrink:0;"></span>
            ${l} <strong style="color:${GCOL[i]};">${Math.round(data[i]/total*100)}%</strong></div>`;
    });
})();

/* ────────────────────────────────────────────────────
   6. Subject Content — grouped bar (Videos / Assign / Quiz)
──────────────────────────────────────────────────── */
(function () {
    const labels  = hf('<%= hdnSubjNames.ClientID %>');
    const videos  = hf('<%= hdnSubjVideos.ClientID %>');
    const assigns = hf('<%= hdnSubjAssign.ClientID %>');
    const quizzes = hf('<%= hdnSubjQuizzes.ClientID %>');
    if (!labels.length) { empty('chartSubjContent','No subject data'); return; }

    // Truncate long names
    const short = labels.map(l => l.length > 14 ? l.substring(0,13)+'…' : l);
    new Chart(document.getElementById('chartSubjContent'), {
        type:'bar',
        data:{ labels:short, datasets:[
            { label:'Videos',      data:videos,  backgroundColor:'rgba(59,130,246,.82)',  borderRadius:5 },
            { label:'Assignments', data:assigns, backgroundColor:'rgba(245,158,11,.82)',  borderRadius:5 },
            { label:'Quizzes',     data:quizzes, backgroundColor:'rgba(139,92,246,.82)',  borderRadius:5 }
        ]},
        options:{
            responsive:true, maintainAspectRatio:false,
            plugins:{ legend:{ position:'top', labels:{ boxWidth:10, font:{size:11} } }, tooltip:TT },
            scales:{
                x:{ grid:{display:false}, ticks:{ font:{size:10} } },
                y:{ beginAtZero:true, grid:GRD, ticks:TICK }
            },
            animation:ANIM
        }
    });
})();

/* ────────────────────────────────────────────────────
   7. Section — doughnut
──────────────────────────────────────────────────── */
(function () {
    const labels = hf('<%= hdnSecLabels.ClientID %>');
    const data   = hf('<%= hdnSecStudents.ClientID %>');
    if (!labels.length) { empty('chartSec','No section data'); return; }

    new Chart(document.getElementById('chartSec'), {
        type:'doughnut',
        data:{ labels, datasets:[{ data, backgroundColor:PAL, borderWidth:2, borderColor:'#fff', hoverOffset:8 }] },
        options:{
            cutout:'60%', responsive:true, maintainAspectRatio:false,
            plugins:{ legend:{display:false}, tooltip:TT },
            animation:{ animateRotate:true, duration:1100 }
        }
    });
    const total = data.reduce((a,b)=>a+b,0)||1;
    const leg = document.getElementById('secLeg');
    labels.forEach((l,i) => {
        leg.innerHTML += `<div style="display:flex;align-items:center;gap:5px;font-size:12px;">
            <span style="width:10px;height:10px;border-radius:2px;background:${PAL[i%PAL.length]};display:inline-block;flex-shrink:0;"></span>
            ${l} <strong style="color:${PAL[i%PAL.length]};">${Math.round(data[i]/total*100)}%</strong></div>`;
    });
})();

/* ────────────────────────────────────────────────────
   8. Subject Perf — mixed (bar avg score + line att%)
──────────────────────────────────────────────────── */
(function () {
    const labels = hf('<%= hdnSubjNames.ClientID %>');
    const scores = hf('<%= hdnSubjScore.ClientID %>');
    const att    = hf('<%= hdnSubjAtt.ClientID %>');
    if (!labels.length) { empty('chartSubjPerf','No performance data'); return; }

    const short = labels.map(l => l.length > 12 ? l.substring(0,11)+'…' : l);
    new Chart(document.getElementById('chartSubjPerf'), {
        type:'bar',
        data:{ labels:short, datasets:[
            { label:'Avg Score', data:scores, backgroundColor:'rgba(79,70,229,.80)', borderRadius:5, yAxisID:'y' },
            { label:'Attendance %', data:att, type:'line',
              borderColor:'#10b981', backgroundColor:'rgba(16,185,129,.10)',
              borderWidth:2.5, tension:.4, fill:true,
              pointRadius:4, pointHoverRadius:7,
              pointBackgroundColor:'#10b981', pointHoverBackgroundColor:'#fff',
              yAxisID:'y1' }
        ]},
        options:{
            responsive:true, maintainAspectRatio:false,
            interaction:{ mode:'index', intersect:false },
            plugins:{ legend:{ position:'top', labels:{ boxWidth:10, font:{size:11} } }, tooltip:TT },
            scales:{
                x:{ grid:{display:false}, ticks:{ font:{size:10} } },
                y: { position:'left',  beginAtZero:true, max:100, grid:GRD,
                     ticks:TICK, title:{ display:true, text:'Score', font:{size:10} } },
                y1:{ position:'right', beginAtZero:true, max:100, grid:{display:false},
                     ticks:{ ...TICK, callback:v=>v+'%' },
                     title:{ display:true, text:'Attendance %', font:{size:10} } }
            },
            animation:ANIM
        }
    });
})();

/* ────────────────────────────────────────────────────
   9. Assignment submission — animated progress bars
──────────────────────────────────────────────────── */
(function () {
    const subjects = hf('<%= hdnAssignSubjects.ClientID %>');
    const rates    = hf('<%= hdnAssignRate.ClientID %>');
    const totals   = hf('<%= hdnAssignTotal.ClientID %>');
    const subs     = hf('<%= hdnAssignSubmitted.ClientID %>');
    const wrap     = document.getElementById('assignBars');

    if (!subjects.length) {
        wrap.innerHTML = "<div class='empty'><i class='fa fa-clipboard-check'></i><p>No assignment data</p></div>";
        return;
    }

    subjects.forEach((s, i) => {
        const pct  = Math.min(parseFloat(rates[i]) || 0, 100).toFixed(1);
        const tot  = totals[i] || 0;
        const sub  = subs[i]  || 0;
        const col  = pct >= 70 ? '#10b981' : pct >= 40 ? '#f59e0b' : '#ef4444';
        const short = s.length > 22 ? s.substring(0,21)+'…' : s;
        wrap.innerHTML += `
        <div class="pi">
          <div class="pi-lbl">
            <span title="${s}">${short}</span>
            <span>${sub}/${tot} &nbsp;(${pct}%)</span>
          </div>
          <div class="pi-track">
            <div class="pi-fill" data-w="${pct}%" style="background:${col};"></div>
          </div>
        </div>`;
    });

    // Animate after render
    setTimeout(() => {
        document.querySelectorAll('.pi-fill[data-w]').forEach(el => {
            el.style.width = el.dataset.w;
        });
    }, 350);
})();

/* ────────────────────────────────────────────────────
   Banner file picker — client-side preview + fake progress
──────────────────────────────────────────────────── */
window.onBannerPick = function (input) {
    if (!input.files || !input.files[0]) return;
    const f = input.files[0];

    // Validate size client-side (5MB)
    if (f.size > 5 * 1024 * 1024) {
        alert('File too large. Maximum allowed size is 5 MB.');
        input.value = '';
        return;
    }

    // Update label
    document.getElementById('dzTxt').innerHTML =
        `<strong style="font-size:12px;">${f.name}</strong><br/>
         <small style="opacity:.75;">${(f.size/1048576).toFixed(2)} MB — click Upload ⬆</small>`;

    // Fake progress bar
    const bar = document.getElementById('upBar');
    let w = 0;
    const iv = setInterval(() => { w += 5; bar.style.width = w + '%'; if (w >= 80) clearInterval(iv); }, 40);

    // Live preview
    const rdr = new FileReader();
    rdr.onload = e => {
        const img = document.getElementById('<%= imgBanner.ClientID %>');
        if (img) { img.src = e.target.result; img.style.display = 'block'; }
    };
    rdr.readAsDataURL(f);
};

/* Sync JS file picker → ASP FileUpload control via DataTransfer */
window.syncFileToAsp = function () {
    const localInput = document.getElementById('fpick');
    const aspInput   = document.getElementById('<%= fuBanner.ClientID %>');
            if (!localInput.files || !localInput.files[0]) {
                // If no file chosen yet, warn user
                if (!aspInput.files || !aspInput.files[0]) {
                    alert('Please choose an image file first.');
                    return false;
                }
            }
            // Try DataTransfer assignment (modern browsers)
            try {
                const dt = new DataTransfer();
                dt.items.add(localInput.files[0]);
                aspInput.files = dt.files;
            } catch (e) {
                // DataTransfer not supported — let ASP handle its own input
            }
            return true;
        };

    })(); // end IIFE
</script>

<%-- Helper: GetGradeColor exposed for inline ASPX expression --%>
<%-- (already defined as protected method in code-behind) --%>

</asp:Content>
