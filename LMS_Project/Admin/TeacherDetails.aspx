<%@ Page Title="Teacher Details" Language="C#"
    MasterPageFile="~/Admin/AdminMaster.master"
    AutoEventWireup="true"
    CodeBehind="TeacherDetails.aspx.cs"
    Inherits="LearningManagementSystem.Admin.TeacherDetails" %>

<asp:Content ID="c1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&family=DM+Mono:wght@400;500&display=swap" rel="stylesheet">
</asp:Content>

<asp:Content ID="c2" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

<%-- ══ HIDDEN FIELDS — chart data bridges server → JS ════════════════════ --%>
<asp:HiddenField ID="hfKpiSubjects"    runat="server" />
<asp:HiddenField ID="hfKpiVideos"      runat="server" />
<asp:HiddenField ID="hfKpiViews"       runat="server" />
<asp:HiddenField ID="hfKpiAssignments" runat="server" />
<asp:HiddenField ID="hfKpiStudents"    runat="server" />
<asp:HiddenField ID="hfKpiAI"          runat="server" />
<asp:HiddenField ID="hfKpiRating"      runat="server" />
<asp:HiddenField ID="hfSubjectLabels"  runat="server" />
<asp:HiddenField ID="hfSyllabusPcts"   runat="server" />
<asp:HiddenField ID="hfEnrollCounts"   runat="server" />
<asp:HiddenField ID="hfRatingLabels"   runat="server" />
<asp:HiddenField ID="hfRatingAvgs"     runat="server" />
<asp:HiddenField ID="hfRatingViews"    runat="server" />
<asp:HiddenField ID="hfAsgLabels"      runat="server" />
<asp:HiddenField ID="hfAsgSubs"        runat="server" />
<asp:HiddenField ID="hfAsgTotals"      runat="server" />
<asp:HiddenField ID="hfAsgTotal"       runat="server" />
<asp:HiddenField ID="hfAttLabels"      runat="server" />
<asp:HiddenField ID="hfAttPcts"        runat="server" />
<asp:HiddenField ID="hfTrendLabels"    runat="server" />
<asp:HiddenField ID="hfTrendCounts"    runat="server" />
<asp:HiddenField ID="hfTrendViews"     runat="server" />
<asp:HiddenField ID="hfAITotal"        runat="server" />
<asp:HiddenField ID="hfCommentTotal"   runat="server" />

<style>
:root{
  --ink:#0d1117;--ink2:#1e293b;--ink3:#334155;--ink4:#64748b;--ink5:#94a3b8;
  --surf:#fff;--surf2:#f8fafc;--surf3:#f1f5f9;--surf4:#e2e8f0;
  --blue:#4f46e5;--blue-lt:#eef2ff;
  --green:#059669;--green-lt:#ecfdf5;
  --amber:#d97706;--amber-lt:#fffbeb;
  --red:#dc2626;--red-lt:#fef2f2;
  --cyan:#0891b2;--cyan-lt:#ecfeff;
  --purple:#7c3aed;--purple-lt:#f5f3ff;
  --pink:#db2777;--pink-lt:#fdf2f8;
  --gold:#f59e0b;
  --r:14px;--rsm:8px;--rlg:20px;
  --sh:0 1px 3px rgba(0,0,0,.06),0 4px 16px rgba(0,0,0,.05);
  --shl:0 8px 40px rgba(0,0,0,.12);
  --f:'Plus Jakarta Sans',system-ui,sans-serif;
  --mono:'DM Mono',monospace;
  --tr:.22s cubic-bezier(.4,0,.2,1);
}
*,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
body{font-family:var(--f);color:var(--ink);background:var(--surf2);font-size:14px}
.td-root{max-width:1440px;margin:0 auto;padding:0 20px 60px}

/* TOPBAR */
.topbar{display:flex;align-items:center;justify-content:space-between;
  padding:18px 0 14px;flex-wrap:wrap;gap:10px}
.back-link{display:inline-flex;align-items:center;gap:7px;font-size:13px;
  font-weight:600;color:var(--ink4);text-decoration:none;transition:color var(--tr)}
.back-link:hover{color:var(--blue)}
.sess-wrap{display:flex;align-items:center;gap:8px}
.sess-wrap label{font-size:12px;font-weight:600;color:var(--ink4);white-space:nowrap}
.sess-sel{border:1.5px solid var(--surf4);border-radius:var(--rsm);
  padding:6px 12px;font-size:13px;font-family:var(--f);
  background:var(--surf);color:var(--ink);cursor:pointer}
.sess-sel:focus{outline:none;border-color:var(--blue)}

/* HERO */
.hero{background:var(--surf);border-radius:var(--rlg);border:1.5px solid var(--surf4);
  box-shadow:var(--sh);padding:30px 32px;display:flex;align-items:flex-start;
  gap:28px;flex-wrap:wrap;margin-bottom:24px;position:relative;overflow:hidden}
.hero::before{content:'';position:absolute;top:0;left:0;right:0;height:4px;
  background:linear-gradient(90deg,var(--blue),var(--purple),var(--pink))}
.av-ring{width:90px;height:90px;border-radius:50%;flex-shrink:0;
  display:flex;align-items:center;justify-content:center;
  font-size:30px;font-weight:800;color:#fff;
  box-shadow:0 0 0 4px rgba(255,255,255,.8),0 0 0 7px currentColor;
  animation:pop .5s both}
@keyframes pop{0%{transform:scale(.6);opacity:0}80%{transform:scale(1.06)}100%{transform:scale(1);opacity:1}}
.av-img{width:90px;height:90px;border-radius:50%;object-fit:cover;
  border:4px solid var(--surf4);flex-shrink:0}
.hero-info{flex:1;min-width:220px}
.hero-name{font-size:1.5rem;font-weight:800;color:var(--ink);line-height:1.15;margin-bottom:7px}
.hero-meta{display:flex;flex-wrap:wrap;gap:7px;align-items:center;margin-bottom:10px}
.pill{display:inline-flex;align-items:center;gap:5px;background:var(--surf3);
  border-radius:30px;padding:3px 10px;font-size:11px;font-weight:600;color:var(--ink3)}
.status-badge{display:inline-flex;align-items:center;gap:4px;
  border-radius:30px;padding:3px 10px;font-size:11px;font-weight:700}
.status-badge::before{content:'';width:6px;height:6px;border-radius:50%}
.status-badge.active{background:var(--green-lt);color:var(--green)}
.status-badge.active::before{background:var(--green)}
.status-badge.inactive{background:var(--red-lt);color:var(--red)}
.status-badge.inactive::before{background:var(--red)}
.hero-right{display:flex;flex-direction:column;gap:8px;align-items:flex-end}
.rating-big{font-size:2rem;font-weight:800;color:var(--gold)}

/* KPI GRID */
.kpi-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(155px,1fr));
  gap:14px;margin-bottom:24px}
.kpi{background:var(--surf);border-radius:var(--r);border:1.5px solid var(--surf4);
  box-shadow:var(--sh);padding:18px 20px;position:relative;overflow:hidden;
  transition:transform var(--tr),box-shadow var(--tr);animation:fu .5s both}
.kpi:hover{transform:translateY(-4px);box-shadow:var(--shl)}
.kpi::after{content:'';position:absolute;bottom:0;left:0;right:0;height:3px;
  background:var(--ac,var(--blue));border-radius:0 0 3px 3px}
.kpi-ico{width:36px;height:36px;border-radius:10px;margin-bottom:10px;
  display:flex;align-items:center;justify-content:center;font-size:15px}
.kpi-val{font-size:1.4rem;font-weight:800;line-height:1;color:var(--ink);margin-bottom:3px}
.kpi-lbl{font-size:10px;font-weight:700;color:var(--ink4);text-transform:uppercase;letter-spacing:.05em}
@keyframes fu{from{opacity:0;transform:translateY(14px)}to{opacity:1;transform:translateY(0)}}

/* TABS */
.tabs{display:flex;gap:4px;flex-wrap:wrap;background:var(--surf3);
  border-radius:12px;padding:5px;margin-bottom:22px;border:1.5px solid var(--surf4)}
.tab-btn{border:none;background:transparent;border-radius:8px;
  padding:8px 14px;font-family:var(--f);font-size:12px;font-weight:600;
  color:var(--ink4);cursor:pointer;display:flex;align-items:center;gap:5px;
  transition:all var(--tr);white-space:nowrap}
.tab-btn:hover{background:var(--surf);color:var(--ink)}
.tab-btn.on{background:var(--surf);color:var(--blue);box-shadow:var(--sh)}
.tab-pane{display:none;animation:fu .3s both}
.tab-pane.on{display:block}

/* CARD */
.card{background:var(--surf);border-radius:var(--r);border:1.5px solid var(--surf4);
  box-shadow:var(--sh);padding:22px 24px;margin-bottom:18px}
.card-title{font-size:13px;font-weight:700;color:var(--ink3);
  margin-bottom:14px;display:flex;align-items:center;gap:8px;flex-wrap:wrap}
.card-title .ico{width:28px;height:28px;border-radius:7px;
  display:flex;align-items:center;justify-content:center;font-size:12px;flex-shrink:0}
.g2{display:grid;grid-template-columns:1fr 1fr;gap:18px}
.g3{display:grid;grid-template-columns:repeat(auto-fill,minmax(280px,1fr));gap:14px}
@media(max-width:768px){.g2,.chart-row{grid-template-columns:1fr}}

/* PROFILE FIELDS */
.pfg{display:grid;grid-template-columns:1fr 1fr;gap:10px}
@media(max-width:600px){.pfg{grid-template-columns:1fr}}
.pf{background:var(--surf2);border-radius:var(--rsm);padding:10px 13px}
.pf-l{font-size:10px;font-weight:700;text-transform:uppercase;
  letter-spacing:.05em;color:var(--ink5);margin-bottom:3px}
.pf-v{font-size:13px;font-weight:600;color:var(--ink2)}
.pf-full{grid-column:1/-1}

/* CHART BOX */
.chart-row{display:grid;grid-template-columns:1fr 1fr;gap:18px;margin-bottom:18px}
.chart-box{background:var(--surf);border-radius:var(--r);border:1.5px solid var(--surf4);
  box-shadow:var(--sh);padding:20px 22px}
canvas{max-height:240px}

/* SUBJECT CARD */
.subj-card{background:var(--surf);border:1.5px solid var(--surf4);border-radius:var(--r);
  box-shadow:var(--sh);padding:18px 20px;position:relative;overflow:hidden;
  transition:transform var(--tr),box-shadow var(--tr)}
.subj-card:hover{transform:translateY(-3px);box-shadow:var(--shl)}
.sc-accent{position:absolute;top:0;left:0;width:4px;height:100%}
.sc-name{font-weight:700;color:var(--ink);margin-bottom:2px}
.sc-code{font-size:11px;color:var(--ink5);font-family:var(--mono);margin-bottom:8px}
.sc-metrics{display:grid;grid-template-columns:repeat(4,1fr);gap:6px;margin-bottom:10px}
.sc-m{background:var(--surf2);border-radius:6px;padding:7px;text-align:center}
.sc-m-val{font-size:1rem;font-weight:800;color:var(--ink)}
.sc-m-lbl{font-size:9px;font-weight:600;color:var(--ink5);text-transform:uppercase;letter-spacing:.04em}

/* PROGRESS BAR */
.pb-wrap{background:var(--surf3);border-radius:30px;height:7px;overflow:hidden}
.pb-fill{height:100%;border-radius:30px;transition:width 1.2s cubic-bezier(.4,0,.2,1)}

/* CHAPTER ACCORDION */
.acc-hd{display:flex;align-items:center;justify-content:space-between;
  padding:10px 13px;background:var(--surf2);border-radius:var(--rsm);
  cursor:pointer;border:1px solid var(--surf4);transition:background var(--tr);margin-bottom:3px}
.acc-hd:hover{background:var(--surf3)}
.acc-hd.open{background:var(--blue-lt);border-color:rgba(79,70,229,.2)}
.acc-tit{font-weight:600;font-size:13px;color:var(--ink)}
.acc-hd.open .acc-tit{color:var(--blue)}
.acc-arrow{transition:transform var(--tr);font-size:11px;color:var(--ink4)}
.acc-hd.open .acc-arrow{transform:rotate(90deg)}
.acc-body{display:none;padding:4px 0 10px}
.acc-body.open{display:block}

/* VIDEO ROW */
.vid-row{display:flex;align-items:center;gap:10px;padding:9px 12px;
  border-radius:var(--rsm);border:1px solid var(--surf4);margin-bottom:6px;
  transition:background var(--tr)}
.vid-row:hover{background:var(--surf2)}
.vid-ico{width:38px;height:38px;border-radius:7px;flex-shrink:0;
  background:var(--blue-lt);display:flex;align-items:center;
  justify-content:center;font-size:14px;color:var(--blue)}
.vid-info{flex:1;min-width:0}
.vid-tit{font-size:12px;font-weight:600;color:var(--ink);
  white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.vid-meta{font-size:10px;color:var(--ink5)}
.vid-stats{display:flex;gap:12px;flex-shrink:0}
.vid-stat{text-align:center}
.vs-val{font-size:12px;font-weight:700;color:var(--ink)}
.vs-lbl{font-size:9px;color:var(--ink5)}

/* TABLE */
.tbl-wrap{overflow-x:auto;border-radius:var(--rsm)}
.tbl{width:100%;border-collapse:collapse;min-width:500px}
.tbl thead th{background:linear-gradient(135deg,#4f46e5,#6366f1);
  color:#fff;padding:10px 13px;font-size:11px;font-weight:700;
  text-transform:uppercase;letter-spacing:.04em;white-space:nowrap;text-align:left}
.tbl tbody td{padding:10px 13px;border-bottom:1px solid var(--surf3);
  font-size:12px;vertical-align:middle;color:var(--ink2)}
.tbl tbody tr:last-child td{border-bottom:none}
.tbl tbody tr:hover{background:var(--surf2)}

/* TAGS */
.tag{display:inline-flex;align-items:center;gap:3px;
  border-radius:6px;padding:2px 8px;font-size:11px;font-weight:700;white-space:nowrap}
.tag-blue  {background:#dbeafe;color:#1d4ed8}
.tag-green {background:#dcfce7;color:#15803d}
.tag-amber {background:#fef9c3;color:#854d0e}
.tag-red   {background:#fee2e2;color:#b91c1c}
.tag-purple{background:#ede9fe;color:#6d28d9}

/* TIMELINE */
.timeline{position:relative;padding-left:28px}
.timeline::before{content:'';position:absolute;left:10px;top:0;bottom:0;width:2px;background:var(--surf4)}
.tl-item{position:relative;margin-bottom:14px}
.tl-dot{position:absolute;left:-24px;top:2px;width:20px;height:20px;border-radius:50%;
  display:flex;align-items:center;justify-content:center;font-size:9px;color:#fff;flex-shrink:0}
.tl-body{background:var(--surf2);border-radius:var(--rsm);padding:9px 12px;border:1px solid var(--surf4)}
.tl-title{font-size:13px;font-weight:600;color:var(--ink)}
.tl-time{font-size:10px;color:var(--ink5);margin-top:2px}

/* HELP */
.help-card{background:var(--surf);border:1.5px solid var(--surf4);
  border-radius:var(--r);padding:14px 16px;margin-bottom:10px}
.help-q{font-size:13px;font-weight:600;color:var(--ink)}
.help-time{font-size:11px;color:var(--ink5);margin:3px 0 8px}
.help-reply{background:var(--blue-lt);border-radius:var(--rsm);
  padding:9px 12px;border-left:3px solid var(--blue)}
.hr-from{font-size:10px;font-weight:700;color:var(--blue);text-transform:uppercase;margin-bottom:3px}
.hr-text{font-size:12px;color:var(--ink2)}
.help-pend{background:var(--amber-lt);border-radius:var(--rsm);
  padding:7px 12px;font-size:12px;color:var(--amber);font-weight:600}

/* STAT STRIP */
.stat-strip{display:flex;gap:10px;flex-wrap:wrap;margin-bottom:14px}
.stat-chip{background:var(--surf2);border-radius:9px;border:1.5px solid var(--surf4);
  padding:12px 18px;flex:1;min-width:90px;text-align:center}
.sc-val{font-size:1.6rem;font-weight:800;line-height:1}
.sc-lbl{font-size:10px;font-weight:600;color:var(--ink4);text-transform:uppercase;margin-top:2px}

/* COMMENT CARD */
.cmt-card{border:1px solid var(--surf4);border-radius:var(--rsm);
  padding:11px 13px;margin-bottom:7px;transition:background var(--tr)}
.cmt-card:hover{background:var(--surf2)}
.cmt-head{display:flex;align-items:center;gap:8px;margin-bottom:5px;flex-wrap:wrap}
.cmt-av{width:28px;height:28px;border-radius:50%;display:flex;align-items:center;
  justify-content:center;font-size:11px;font-weight:700;color:#fff;flex-shrink:0}
.cmt-name{font-size:12px;font-weight:700;color:var(--ink)}
.cmt-txt{font-size:12px;color:var(--ink3);line-height:1.5}
.cmt-meta{font-size:10px;color:var(--ink5);margin-top:4px;display:flex;gap:10px;flex-wrap:wrap}

/* AI ITEM */
.ai-item{border:1px solid var(--surf4);border-radius:var(--rsm);padding:11px 13px;margin-bottom:7px}
.ai-q{font-size:12px;font-weight:600;color:var(--ink2);margin-bottom:3px}
.ai-a{font-size:11px;color:var(--ink4);line-height:1.5}
.ai-meta{font-size:10px;color:var(--ink5);margin-top:4px;display:flex;gap:10px;flex-wrap:wrap}

/* TOP CLASS ROW */
.tc-row{display:flex;align-items:center;gap:10px;margin-bottom:10px;
  padding-bottom:10px;border-bottom:1px solid var(--surf4)}
.tc-row:last-child{border-bottom:none;margin-bottom:0;padding-bottom:0}
.tc-num{width:28px;height:28px;border-radius:50%;background:var(--green-lt);
  color:var(--green);display:flex;align-items:center;justify-content:center;
  font-weight:800;font-size:11px;flex-shrink:0}

/* EMPTY */
.empty{text-align:center;padding:36px 20px;color:var(--ink5)}
.empty i{font-size:2rem;opacity:.3;display:block;margin-bottom:8px}
.empty p{font-size:13px}

::-webkit-scrollbar{width:4px;height:4px}
::-webkit-scrollbar-thumb{background:#b0bec5;border-radius:4px}
@media(max-width:768px){
  .hero{padding:20px 16px;gap:16px}
  .kpi-grid{grid-template-columns:repeat(2,1fr)}
  .sc-metrics{grid-template-columns:repeat(2,1fr)}
  .g3{grid-template-columns:1fr}
}
@media(max-width:480px){
  .tab-btn{padding:7px 10px;font-size:11px}
  .kpi-grid{grid-template-columns:repeat(2,1fr)}
}
</style>

<div class="td-root">

<%-- TOP BAR --%>
<div class="topbar">
    <a href="TeacherList.aspx" class="back-link">
        <i class="fa fa-arrow-left"></i> Back to Faculty
    </a>
    <div class="sess-wrap">
        <label><i class="fa fa-calendar-alt me-1"></i>Session:</label>
        <asp:DropDownList ID="ddlSession" runat="server" CssClass="sess-sel"
            AutoPostBack="true" OnSelectedIndexChanged="ddlSession_Changed" />
    </div>
</div>

<%-- HERO CARD --%>
<div class="hero">
    <%  if (!string.IsNullOrWhiteSpace(ProfileImage)) { %>
        <img src="<%=ProfileImage%>" alt="Photo" class="av-img" />
    <%  } else { %>
        <div class="av-ring" style="background:<%=AvatarColor%>;color:<%=AvatarColor%>">
            <%=TeacherInitials%>
        </div>
    <%  } %>

    <div class="hero-info">
        <div class="hero-name"><%=TeacherName%></div>
        <div class="hero-meta">
            <asp:Label ID="lblStatus" runat="server" CssClass="status-badge active" />
            <span class="pill"><i class="fa fa-id-badge me-1"></i><asp:Label ID="lblEmpId" runat="server" /></span>
            <span class="pill"><i class="fa fa-briefcase me-1"></i><asp:Label ID="lblDesig" runat="server" /></span>
            <span class="pill" style="background:var(--blue-lt);color:var(--blue)">
                <i class="fa fa-layer-group me-1"></i><asp:Label ID="lblStream" runat="server" />
            </span>
        </div>
        <div style="font-size:12px;color:var(--ink4)">
            <i class="fa fa-calendar me-1"></i><asp:Label ID="lblSession" runat="server" />
            &nbsp;|&nbsp;
            <i class="fa fa-clock me-1"></i> Last login: <asp:Label ID="lblLastLogin" runat="server" />
        </div>
    </div>

    <div class="hero-right">
        <div style="text-align:right">
            <div style="font-size:10px;font-weight:700;color:var(--ink5);text-transform:uppercase;
                        letter-spacing:.05em;margin-bottom:3px">Avg Rating</div>
            <div class="rating-big" id="heroRating">—</div>
            <div style="font-size:13px;color:var(--gold)" id="heroStars"></div>
        </div>
    </div>
</div>

<%-- KPI RIBBON --%>
<div class="kpi-grid">
    <div class="kpi" style="--ac:var(--blue);animation-delay:.05s">
        <div class="kpi-ico" style="background:var(--blue-lt);color:var(--blue)"><i class="fa fa-book"></i></div>
        <div class="kpi-val kpi-num" id="kSubjects">—</div>
        <div class="kpi-lbl">Subjects</div>
    </div>
    <div class="kpi" style="--ac:var(--cyan);animation-delay:.10s">
        <div class="kpi-ico" style="background:var(--cyan-lt);color:var(--cyan)"><i class="fa fa-video"></i></div>
        <div class="kpi-val kpi-num" id="kVideos">—</div>
        <div class="kpi-lbl">Videos</div>
    </div>
    <div class="kpi" style="--ac:var(--green);animation-delay:.15s">
        <div class="kpi-ico" style="background:var(--green-lt);color:var(--green)"><i class="fa fa-eye"></i></div>
        <div class="kpi-val kpi-num" id="kViews">—</div>
        <div class="kpi-lbl">Total Views</div>
    </div>
    <div class="kpi" style="--ac:var(--purple);animation-delay:.20s">
        <div class="kpi-ico" style="background:var(--purple-lt);color:var(--purple)"><i class="fa fa-tasks"></i></div>
        <div class="kpi-val kpi-num" id="kAssign">—</div>
        <div class="kpi-lbl">Assignments</div>
    </div>
    <div class="kpi" style="--ac:var(--pink);animation-delay:.25s">
        <div class="kpi-ico" style="background:var(--pink-lt);color:var(--pink)"><i class="fa fa-users"></i></div>
        <div class="kpi-val kpi-num" id="kStudents">—</div>
        <div class="kpi-lbl">Students</div>
    </div>
    <div class="kpi" style="--ac:var(--amber);animation-delay:.30s">
        <div class="kpi-ico" style="background:var(--amber-lt);color:var(--amber)"><i class="fa fa-robot"></i></div>
        <div class="kpi-val kpi-num" id="kAI">—</div>
        <div class="kpi-lbl">AI Queries</div>
    </div>
</div>

<%-- TABS --%>
<div class="tabs" role="tablist">
    <button class="tab-btn on" type="button" onclick="sw(this,'tProfile')"><i class="fa fa-user-circle"></i> Profile</button>
    <button class="tab-btn"    type="button" onclick="sw(this,'tSubjects')"><i class="fa fa-book-open"></i> Subjects</button>
    <button class="tab-btn"    type="button" onclick="sw(this,'tContent')"><i class="fa fa-layer-group"></i> Content</button>
    <button class="tab-btn"    type="button" onclick="sw(this,'tRatings')"><i class="fa fa-star"></i> Ratings</button>
    <button class="tab-btn"    type="button" onclick="sw(this,'tAssignments')"><i class="fa fa-file-alt"></i> Assignments</button>
    <button class="tab-btn"    type="button" onclick="sw(this,'tAttendance')"><i class="fa fa-calendar-check"></i> Attendance</button>
    <button class="tab-btn"    type="button" onclick="sw(this,'tComms')"><i class="fa fa-comments"></i> Communications</button>
    <button class="tab-btn"    type="button" onclick="sw(this,'tAnalytics')"><i class="fa fa-chart-line"></i> Analytics</button>
</div>

<%-- ════ TAB 1: PROFILE ════════════════════════════════════════════════════ --%>
<div class="tab-pane on" id="tProfile">
    <div class="g2">
        <div class="card">
            <div class="card-title">
                <span class="ico" style="background:var(--blue-lt);color:var(--blue)"><i class="fa fa-user"></i></span>
                Personal Information
            </div>
            <div class="pfg">
                <div class="pf"><div class="pf-l">Full Name</div><div class="pf-v"><asp:Label ID="lblFullName" runat="server"/></div></div>
                <div class="pf"><div class="pf-l">Gender</div><div class="pf-v"><asp:Label ID="lblGender" runat="server"/></div></div>
                <div class="pf"><div class="pf-l">Date of Birth</div><div class="pf-v"><asp:Label ID="lblDOB" runat="server"/></div></div>
                <div class="pf"><div class="pf-l">Contact</div><div class="pf-v"><asp:Label ID="lblContact" runat="server"/></div></div>
                <div class="pf"><div class="pf-l">Father's Name</div><div class="pf-v"><asp:Label ID="lblFather" runat="server"/></div></div>
                <div class="pf"><div class="pf-l">Mother's Name</div><div class="pf-v"><asp:Label ID="lblMother" runat="server"/></div></div>
                <div class="pf pf-full"><div class="pf-l">Emergency Contact</div><div class="pf-v"><asp:Label ID="lblEmg" runat="server"/></div></div>
                <div class="pf pf-full"><div class="pf-l">Address</div><div class="pf-v"><asp:Label ID="lblAddress" runat="server"/></div></div>
                <div class="pf pf-full"><div class="pf-l">Skills</div><div class="pf-v"><asp:Label ID="lblSkills" runat="server"/></div></div>
                <div class="pf"><div class="pf-l">Joined Date</div><div class="pf-v"><asp:Label ID="lblJoined" runat="server"/></div></div>
                <div class="pf"><div class="pf-l">Account Created</div><div class="pf-v"><asp:Label ID="lblCreatedOn" runat="server"/></div></div>
            </div>
        </div>

        <div class="card">
            <div class="card-title">
                <span class="ico" style="background:var(--purple-lt);color:var(--purple)"><i class="fa fa-graduation-cap"></i></span>
                Academic &amp; Login Details
            </div>
            <div class="pfg">
                <div class="pf"><div class="pf-l">Username</div>
                    <div class="pf-v" style="font-family:var(--mono)"><asp:Label ID="lblUsername" runat="server"/></div></div>
                <div class="pf"><div class="pf-l">Email</div><div class="pf-v"><asp:Label ID="lblEmail" runat="server"/></div></div>
                <div class="pf"><div class="pf-l">Employee ID</div>
                    <div class="pf-v" style="font-family:var(--mono);font-weight:700;color:var(--blue)">
                        <asp:Label ID="lblEmpId2" runat="server"/></div></div>
                <div class="pf"><div class="pf-l">Designation</div><div class="pf-v"><asp:Label ID="lblDesig2" runat="server"/></div></div>
                <div class="pf"><div class="pf-l">Qualification</div><div class="pf-v"><asp:Label ID="lblQual" runat="server"/></div></div>
                <div class="pf"><div class="pf-l">Experience</div><div class="pf-v"><asp:Label ID="lblExp" runat="server"/></div></div>
                <div class="pf"><div class="pf-l">Department</div><div class="pf-v"><asp:Label ID="lblStream2" runat="server"/></div></div>
                <div class="pf"><div class="pf-l">Session</div>
                    <div class="pf-v" style="color:var(--blue);font-weight:700"><asp:Label ID="lblSession2" runat="server"/></div></div>
                <div class="pf pf-full"><div class="pf-l">Last Login</div><div class="pf-v"><asp:Label ID="lblLastLogin2" runat="server"/></div></div>
            </div>
        </div>
    </div>

    <div class="chart-box" style="margin-bottom:18px">
        <div class="card-title"><i class="fa fa-chart-area" style="color:var(--blue)"></i>&nbsp;Performance Overview</div>
        <canvas id="radarChart" height="160"></canvas>
    </div>
</div>

<%-- ════ TAB 2: SUBJECTS ═══════════════════════════════════════════════════ --%>
<div class="tab-pane" id="tSubjects">
    <div class="chart-row">
        <div class="chart-box">
            <div class="card-title"><i class="fa fa-chart-bar" style="color:var(--blue)"></i>&nbsp;Syllabus Completion %</div>
            <canvas id="syllabusChart"></canvas>
        </div>
        <div class="chart-box">
            <div class="card-title"><i class="fa fa-users" style="color:var(--green)"></i>&nbsp;Enrolled Students</div>
            <canvas id="enrollChart"></canvas>
        </div>
    </div>

    <div class="g3">
        <asp:Repeater ID="rptSubjects" runat="server">
            <ItemTemplate>
                <div class="subj-card">
                    <div class="sc-accent" style="background:var(--blue)"></div>
                    <div class="sc-name"><%# Eval("SubjectName") %></div>
                    <div class="sc-code"><%# Eval("SubjectCode") %> &bull; <%# Eval("Duration") %></div>
                    <div style="font-size:11px;color:var(--ink4);margin-bottom:8px">
                        <i class="fa fa-layer-group me-1"></i><%# Eval("StreamName") %>
                        &nbsp;›&nbsp;<%# Eval("CourseName") %>
                        &nbsp;›&nbsp;<%# Eval("LevelName") %>
                        &nbsp;›&nbsp;<%# Eval("SemesterName") %>
                    </div>
                    <div class="sc-metrics">
                        <div class="sc-m"><div class="sc-m-val"><%# Eval("ChapterCount") %></div><div class="sc-m-lbl">Chapters</div></div>
                        <div class="sc-m"><div class="sc-m-val"><%# Eval("VideoCount") %></div><div class="sc-m-lbl">Videos</div></div>
                        <div class="sc-m"><div class="sc-m-val"><%# Eval("MaterialCount") %></div><div class="sc-m-lbl">Materials</div></div>
                        <div class="sc-m"><div class="sc-m-val"><%# Eval("EnrolledStudents") %></div><div class="sc-m-lbl">Students</div></div>
                    </div>
                    <div style="margin-bottom:6px">
                        <div style="display:flex;justify-content:space-between;font-size:11px;margin-bottom:3px">
                            <span style="font-weight:600;color:var(--ink4)">Syllabus Completed</span>
                            <span style="font-weight:700;color:var(--blue)"><%# string.Format("{0:F1}%",Eval("SyllabusCompletedPct")) %></span>
                        </div>
                        <div class="pb-wrap">
                            <div class="pb-fill" style="width:<%# Bar(Eval("SyllabusCompletedPct")) %>%;background:var(--blue)"></div>
                        </div>
                    </div>
                    <div style="font-size:11px;color:var(--ink4)">
                        <i class="fa fa-user-graduate me-1"></i><%# Eval("CompletedStudents") %> students completed
                    </div>
                </div>
            </ItemTemplate>
            <FooterTemplate>
                <asp:Panel runat="server" Visible='<%# rptSubjects.Items.Count==0 %>'>
                    <div class="empty"><i class="fa fa-book"></i><p>No subjects assigned this session.</p></div>
                </asp:Panel>
            </FooterTemplate>
        </asp:Repeater>
    </div>
</div>

<%-- ════ TAB 3: CONTENT TREE ═══════════════════════════════════════════════ --%>
<div class="tab-pane" id="tContent">
    <asp:Repeater ID="rptSubjectChapters" runat="server"
        OnItemDataBound="rptSubjectChapters_ItemDataBound">
        <ItemTemplate>
            <div class="card" style="margin-bottom:14px">
                <asp:HiddenField ID="hfSubId" runat="server" Value='<%# Eval("SubjectId") %>' />
                <div class="card-title">
                    <span class="ico" style="background:var(--blue-lt);color:var(--blue)"><i class="fa fa-book-open"></i></span>
                    <asp:Label ID="lblSubNameTree" runat="server" />
                    <span class="tag tag-blue" style="margin-left:auto"><%# Eval("ChapterCount") %> chapters</span>
                </div>

                <asp:Repeater ID="rptChapters" runat="server"
                    OnItemDataBound="rptChapters_ItemDataBound">
                    <ItemTemplate>
                        <asp:HiddenField ID="hfChapterId" runat="server" Value='<%# Eval("ChapterId") %>' />
                        <div class="acc-hd" onclick="toggleAcc(this)">
                            <div style="display:flex;align-items:center;gap:8px;flex-wrap:wrap">
                                <span style="width:22px;height:22px;border-radius:50%;background:var(--blue-lt);
                                      color:var(--blue);display:flex;align-items:center;justify-content:center;
                                      font-size:10px;font-weight:800;flex-shrink:0">
                                    <%# Container.ItemIndex+1 %>
                                </span>
                                <span class="acc-tit"><%# Eval("ChapterName") %></span>
                                <span class="tag tag-blue" style="font-size:10px"><%# Eval("VideoCount") %> videos</span>
                                <span class="tag tag-green" style="font-size:10px"><%# Eval("MaterialCount") %> materials</span>
                            </div>
                            <div style="display:flex;align-items:center;gap:10px">
                                <span style="font-size:11px;color:var(--ink4)">
                                    <i class="fa fa-eye me-1"></i><%# Eval("TotalViews") %> views
                                </span>
                                <i class="fa fa-chevron-right acc-arrow"></i>
                            </div>
                        </div>
                        <div class="acc-body">
                            <asp:Repeater ID="rptChapterVideos" runat="server">
                                <ItemTemplate>
                                    <div class="vid-row">
                                        <div class="vid-ico"><i class="fa fa-play"></i></div>
                                        <div class="vid-info">
                                            <div class="vid-tit"><%# Eval("Title") %></div>
                                            <div class="vid-meta"><%# Eval("Duration") %> &bull; Uploaded <%# FmtDate(Eval("UploadedOn")) %></div>
                                        </div>
                                        <div class="vid-stats">
                                            <div class="vid-stat"><div class="vs-val"><%# Eval("ViewCount") %></div><div class="vs-lbl">Views</div></div>
                                            <div class="vid-stat"><div class="vs-val"><%# Eval("UniqueViewers") %></div><div class="vs-lbl">Students</div></div>
                                            <div class="vid-stat"><div class="vs-val"><%# Eval("CompletedCount") %></div><div class="vs-lbl">Completed</div></div>
                                            <div class="vid-stat">
                                                <div class="vs-val">
                                                    <%# string.Format("{0:F1}",Eval("AvgRating")) %>
                                                    <span style="color:var(--gold);font-size:10px">★</span>
                                                </div>
                                                <div class="vs-lbl">Rating</div>
                                            </div>
                                        </div>
                                    </div>
                                </ItemTemplate>
                                <FooterTemplate>
                                    <%# ((Repeater)Container.NamingContainer).Items.Count == 0 ?
                                        "<div class='empty' style='padding:14px'><i class='fa fa-video'></i><p style='font-size:12px'>No videos.</p></div>"
                                        : "" %>
                                </FooterTemplate>
                            </asp:Repeater>
                        </div>
                    </ItemTemplate>
                    <FooterTemplate>
                        <%# ((Repeater)Container.NamingContainer).Items.Count == 0 ?
                            "<div class='empty'><i class='fa fa-folder-open'></i><p>No chapters.</p></div>"
                            : "" %>
                    </FooterTemplate>
                </asp:Repeater>
            </div>
        </ItemTemplate>
    </asp:Repeater>
</div>

<%-- ════ TAB 4: RATINGS ════════════════════════════════════════════════════ --%>
<div class="tab-pane" id="tRatings">
    <div class="chart-row">
        <div class="chart-box">
            <div class="card-title"><i class="fa fa-star" style="color:var(--gold)"></i>&nbsp;Avg Rating per Video</div>
            <canvas id="ratingChart"></canvas>
        </div>
        <div class="chart-box">
            <div class="card-title"><i class="fa fa-eye" style="color:var(--cyan)"></i>&nbsp;Views per Video</div>
            <canvas id="viewsChart"></canvas>
        </div>
    </div>
    <div class="card">
        <div class="card-title">
            <span class="ico" style="background:var(--amber-lt);color:var(--amber)"><i class="fa fa-star"></i></span>
            All Video Ratings
        </div>
        <div class="tbl-wrap">
            <table class="tbl">
                <thead>
                    <tr><th>#</th><th>Video</th><th>Chapter</th><th>Subject</th><th>Avg Rating</th><th>Ratings</th><th>Views</th></tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptRatings" runat="server">
                        <ItemTemplate>
                            <tr>
                                <td style="font-family:var(--mono);font-weight:700;color:var(--ink4)"><%# Container.ItemIndex+1 %></td>
                                <td style="font-weight:600;max-width:200px">
                                    <div style="white-space:nowrap;overflow:hidden;text-overflow:ellipsis;max-width:190px" title="<%# Eval("VideoTitle") %>">
                                        <%# Eval("VideoTitle") %>
                                    </div>
                                </td>
                                <td><%# Eval("ChapterName") %></td>
                                <td><span class="tag tag-blue"><%# Eval("SubjectName") %></span></td>
                                <td>
                                    <div style="display:flex;align-items:center;gap:6px">
                                        <span style="font-weight:800;color:<%# RatingColor(Eval("AvgRating")) %>">
                                            <%# string.Format("{0:F1}",Eval("AvgRating")) %>
                                        </span>
                                        <span><%# StarHtml(Eval("AvgRating")) %></span>
                                    </div>
                                </td>
                                <td style="font-family:var(--mono)"><%# Eval("RatingCount") %></td>
                                <td style="font-family:var(--mono)"><%# Eval("TotalViews") %></td>
                            </tr>
                        </ItemTemplate>
                        <FooterTemplate>
                            <asp:Panel runat="server" Visible='<%# rptRatings.Items.Count==0 %>'>
                                <tr><td colspan="7"><div class="empty"><i class="fa fa-star"></i><p>No ratings yet.</p></div></td></tr>
                            </asp:Panel>
                        </FooterTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
        </div>
    </div>
</div>

<%-- ════ TAB 5: ASSIGNMENTS ════════════════════════════════════════════════ --%>
<div class="tab-pane" id="tAssignments">
    <div class="chart-row">
        <div class="chart-box">
            <div class="card-title"><i class="fa fa-chart-bar" style="color:var(--purple)"></i>&nbsp;Submission Rate (top 6)</div>
            <canvas id="asgChart"></canvas>
        </div>
        <div class="card" style="margin-bottom:0">
            <div class="card-title">
                <span class="ico" style="background:var(--purple-lt);color:var(--purple)"><i class="fa fa-tasks"></i></span>
                Assignment Summary
            </div>
            <div class="stat-strip">
                <div class="stat-chip"><div class="sc-val" id="asgTotalLbl">—</div><div class="sc-lbl">Total</div></div>
                <div class="stat-chip"><div class="sc-val" style="color:var(--blue)" id="asgSubsLbl">—</div><div class="sc-lbl">Submissions</div></div>
            </div>
        </div>
    </div>
    <div class="card">
        <div class="card-title">
            <span class="ico" style="background:var(--blue-lt);color:var(--blue)"><i class="fa fa-file-alt"></i></span>
            All Assignments
        </div>
        <div class="tbl-wrap">
            <table class="tbl">
                <thead>
                    <tr><th>Assignment</th><th>Subject</th><th>Created</th><th>Due</th><th>Max</th><th>Students</th><th>Submitted</th><th>Graded</th><th>Avg</th><th>Rate %</th></tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptAssignments" runat="server">
                        <ItemTemplate>
                            <tr>
                                <td style="font-weight:600;max-width:180px">
                                    <div style="white-space:nowrap;overflow:hidden;text-overflow:ellipsis;max-width:170px" title="<%# Eval("Title") %>"><%# Eval("Title") %></div>
                                    <div style="font-size:10px;color:var(--ink5)"><%# Eval("Description") %></div>
                                </td>
                                <td><span class="tag tag-blue"><%# Eval("SubjectCode") %></span></td>
                                <td style="font-size:11px"><%# FmtDate(Eval("CreatedOn")) %></td>
                                <td style="font-size:11px"><%# FmtDate(Eval("DueDate")) %></td>
                                <td style="font-family:var(--mono)"><%# Eval("MaxMarks") %></td>
                                <td style="font-family:var(--mono)"><%# Eval("TotalStudents") %></td>
                                <td style="font-family:var(--mono);font-weight:700;color:var(--blue)"><%# Eval("Submissions") %></td>
                                <td style="font-family:var(--mono);font-weight:700;color:var(--green)"><%# Eval("Graded") %></td>
                                <td style="font-family:var(--mono)"><%# string.Format("{0:F1}",Eval("AvgMarks")) %></td>
                                <td>
                                    <div class="pb-wrap" style="width:70px;margin-bottom:2px">
                                        <div class="pb-fill" style="width:<%# SubRate(Eval("Submissions"),Eval("TotalStudents")) %>%;background:var(--blue)"></div>
                                    </div>
                                    <div style="font-size:10px;font-weight:600;color:var(--ink4)">
                                        <%# SubRatePct(Eval("Submissions"),Eval("TotalStudents")) %>
                                    </div>
                                </td>
                            </tr>
                        </ItemTemplate>
                        <FooterTemplate>
                            <asp:Panel runat="server" Visible='<%# rptAssignments.Items.Count==0 %>'>
                                <tr><td colspan="10"><div class="empty"><i class="fa fa-file"></i><p>No assignments created.</p></div></td></tr>
                            </asp:Panel>
                        </FooterTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
        </div>
    </div>
</div>

<%-- ════ TAB 6: ATTENDANCE ═════════════════════════════════════════════════ --%>
<div class="tab-pane" id="tAttendance">
    <div class="chart-row">
        <div class="chart-box">
            <div class="card-title"><i class="fa fa-chart-bar" style="color:var(--green)"></i>&nbsp;Subject-wise Avg Attendance %</div>
            <canvas id="attChart"></canvas>
        </div>
        <div class="card" style="margin-bottom:0">
            <div class="card-title">
                <span class="ico" style="background:var(--green-lt);color:var(--green)"><i class="fa fa-trophy"></i></span>
                Top Attending Classes
            </div>
            <asp:Repeater ID="rptTopClasses" runat="server">
                <ItemTemplate>
                    <div class="tc-row">
                        <div class="tc-num"><%# Container.ItemIndex+1 %></div>
                        <div style="flex:1;min-width:0">
                            <div style="font-size:12px;font-weight:600;color:var(--ink)">
                                <%# Eval("SubjectCode") %> &mdash; <%# Eval("LevelName") %> / <%# Eval("SectionName") %>
                            </div>
                            <div style="font-size:10px;color:var(--ink5)"><%# Eval("StudentCount") %> students</div>
                        </div>
                        <div style="font-size:1.1rem;font-weight:800;color:<%# AttColor(Eval("AttendancePct")) %>">
                            <%# string.Format("{0:F1}%",Eval("AttendancePct")) %>
                        </div>
                    </div>
                </ItemTemplate>
                <FooterTemplate>
                    <asp:Panel runat="server" Visible='<%# rptTopClasses.Items.Count==0 %>'>
                        <div class="empty"><i class="fa fa-calendar-times"></i><p>No data.</p></div>
                    </asp:Panel>
                </FooterTemplate>
            </asp:Repeater>
        </div>
    </div>

    <div class="card">
        <div class="card-title">
            <span class="ico" style="background:var(--green-lt);color:var(--green)"><i class="fa fa-calendar-check"></i></span>
            Subject-wise Attendance Detail
        </div>
        <div class="tbl-wrap">
            <table class="tbl">
                <thead>
                    <tr><th>Subject</th><th>Code</th><th>Students</th><th>Classes</th><th>Present</th><th>Avg %</th></tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptAttendance" runat="server">
                        <ItemTemplate>
                            <tr>
                                <td style="font-weight:600"><%# Eval("SubjectName") %></td>
                                <td><span class="tag tag-blue"><%# Eval("SubjectCode") %></span></td>
                                <td style="font-family:var(--mono)"><%# Eval("TotalStudents") %></td>
                                <td style="font-family:var(--mono)"><%# Eval("TotalClasses") %></td>
                                <td style="font-family:var(--mono)"><%# Eval("PresentCount") %></td>
                                <td>
                                    <div style="display:flex;align-items:center;gap:8px">
                                        <div class="pb-wrap" style="width:80px">
                                            <div class="pb-fill" style="width:<%# Bar(Eval("AvgAttendancePct")) %>%;background:<%# AttColor(Eval("AvgAttendancePct")) %>"></div>
                                        </div>
                                        <span style="font-weight:700;font-size:12px;color:<%# AttColor(Eval("AvgAttendancePct")) %>">
                                            <%# string.Format("{0:F1}%",Eval("AvgAttendancePct")) %>
                                        </span>
                                    </div>
                                </td>
                            </tr>
                        </ItemTemplate>
                        <FooterTemplate>
                            <asp:Panel runat="server" Visible='<%# rptAttendance.Items.Count==0 %>'>
                                <tr><td colspan="6"><div class="empty"><i class="fa fa-calendar-times"></i><p>No data.</p></div></td></tr>
                            </asp:Panel>
                        </FooterTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
        </div>
    </div>
</div>

<%-- ════ TAB 7: COMMUNICATIONS ════════════════════════════════════════════ --%>
<div class="tab-pane" id="tComms">
    <div class="g2">
        <div class="card">
            <div class="card-title">
                <span class="ico" style="background:var(--blue-lt);color:var(--blue)"><i class="fa fa-stream"></i></span>
                Activity Log
            </div>
            <div class="timeline">
                <asp:Repeater ID="rptActivity" runat="server">
                    <ItemTemplate>
                        <div class="tl-item">
                            <div class="tl-dot" style="background:var(--blue)"><i class="fa <%# ActivityIcon(Eval("ActivityType")) %>"></i></div>
                            <div class="tl-body">
                                <div class="tl-title"><%# Eval("ActivityType") %></div>
                                <div class="tl-time"><i class="fa fa-clock me-1"></i><%# FmtDateTime(Eval("ActionTime")) %></div>
                            </div>
                        </div>
                    </ItemTemplate>
                    <FooterTemplate>
                        <asp:Panel runat="server" Visible='<%# rptActivity.Items.Count==0 %>'>
                            <div class="empty"><i class="fa fa-history"></i><p>No activity.</p></div>
                        </asp:Panel>
                    </FooterTemplate>
                </asp:Repeater>
            </div>
        </div>

        <div class="card">
            <div class="card-title">
                <span class="ico" style="background:var(--amber-lt);color:var(--amber)"><i class="fa fa-bell"></i></span>
                Notifications
            </div>
            <div class="timeline">
                <asp:Repeater ID="rptNotifs" runat="server">
                    <ItemTemplate>
                        <div class="tl-item">
                            <div class="tl-dot" style="background:<%# Convert.ToBoolean(Eval("IsRead")) ? "var(--ink4)" : "var(--amber)" %>">
                                <i class="fa fa-bell"></i>
                            </div>
                            <div class="tl-body">
                                <div class="tl-title" style="<%# !Convert.ToBoolean(Eval("IsRead")) ? "color:var(--amber)" : "" %>">
                                    <%# Eval("Message") %>
                                    <%# !Convert.ToBoolean(Eval("IsRead")) ? "<span class='tag tag-amber' style='margin-left:4px;font-size:9px'>Unread</span>" : "" %>
                                </div>
                                <div class="tl-time"><i class="fa fa-tag me-1"></i><%# Eval("NotificationType") %> &bull; <%# FmtDateTime(Eval("CreatedOn")) %></div>
                            </div>
                        </div>
                    </ItemTemplate>
                    <FooterTemplate>
                        <asp:Panel runat="server" Visible='<%# rptNotifs.Items.Count==0 %>'>
                            <div class="empty"><i class="fa fa-bell-slash"></i><p>No notifications.</p></div>
                        </asp:Panel>
                    </FooterTemplate>
                </asp:Repeater>
            </div>
        </div>
    </div>

    <div class="card">
        <div class="card-title">
            <span class="ico" style="background:var(--green-lt);color:var(--green)"><i class="fa fa-question-circle"></i></span>
            Help Requests &amp; Replies
        </div>
        <asp:Repeater ID="rptHelp" runat="server">
            <ItemTemplate>
                <div class="help-card">
                    <div class="help-q"><i class="fa fa-question-circle me-1" style="color:var(--blue)"></i><%# Eval("Question") %></div>
                    <div class="help-time"><i class="fa fa-clock me-1"></i>Asked on <%# FmtDateTime(Eval("AskedOn")) %></div>
                    <%# Convert.ToBoolean(Eval("HasReply"))
                        ? "<div class='help-reply'><div class='hr-from'><i class='fa fa-user-shield me-1'></i>"
                          + H(Eval("RepliedBy")) + " — " + FmtDateTime(Eval("RepliedOn"))
                          + "</div><div class='hr-text'>" + H(Eval("Reply")) + "</div></div>"
                        : "<div class='help-pend'><i class='fa fa-hourglass-half me-1'></i>Awaiting reply…</div>" %>
                </div>
            </ItemTemplate>
            <FooterTemplate>
                <asp:Panel runat="server" Visible='<%# rptHelp.Items.Count==0 %>'>
                    <div class="empty"><i class="fa fa-comment-slash"></i><p>No help requests.</p></div>
                </asp:Panel>
            </FooterTemplate>
        </asp:Repeater>
    </div>

    <div class="card">
        <div class="card-title">
            <span class="ico" style="background:var(--cyan-lt);color:var(--cyan)"><i class="fa fa-comments"></i></span>
            Student Comments on Videos
            <span class="tag tag-blue" style="margin-left:auto" id="cmtBadge">—</span>
        </div>
        <asp:Repeater ID="rptComments" runat="server">
            <ItemTemplate>
                <div class="cmt-card">
                    <div class="cmt-head">
                        <div class="cmt-av" style="background:var(--blue)">
                            <%# H(Eval("CommenterName")).Length > 0 ? H(Eval("CommenterName")).Substring(0,1).ToUpper() : "?" %>
                        </div>
                        <div>
                            <div class="cmt-name"><%# H(Eval("CommenterName")) %></div>
                            <span class="tag <%# Eval("CommenterRole").ToString()=="Teacher"?"tag-green":Eval("CommenterRole").ToString()=="Admin"?"tag-red":"tag-blue" %>"
                                  style="font-size:9px"><%# Eval("CommenterRole") %></span>
                        </div>
                        <div style="margin-left:auto;text-align:right">
                            <div style="font-size:11px;font-weight:600;color:var(--ink3)"><%# H(Eval("VideoTitle")) %></div>
                            <div style="font-size:10px;color:var(--ink5)"><%# H(Eval("SubjectName")) %></div>
                        </div>
                    </div>
                    <div class="cmt-txt"><%# H(Eval("CommentText")) %></div>
                    <div class="cmt-meta"><span><i class="fa fa-clock me-1"></i><%# FmtDateTime(Eval("CreatedOn")) %></span></div>
                </div>
            </ItemTemplate>
            <FooterTemplate>
                <asp:Panel runat="server" Visible='<%# rptComments.Items.Count==0 %>'>
                    <div class="empty"><i class="fa fa-comment-slash"></i><p>No comments.</p></div>
                </asp:Panel>
            </FooterTemplate>
        </asp:Repeater>
    </div>
</div>

<%-- ════ TAB 8: ANALYTICS ══════════════════════════════════════════════════ --%>
<div class="tab-pane" id="tAnalytics">
    <div class="chart-box" style="margin-bottom:18px">
        <div class="card-title"><i class="fa fa-chart-line" style="color:var(--blue)"></i>&nbsp;Monthly Video Uploads &amp; Views</div>
        <canvas id="trendChart" height="140"></canvas>
    </div>

    <div class="card">
        <div class="card-title">
            <span class="ico" style="background:var(--amber-lt);color:var(--amber)"><i class="fa fa-robot"></i></span>
            Student AI Interactions on Teacher's Videos
            <span class="tag tag-amber" style="margin-left:auto" id="aiBadge">—</span>
        </div>
        <asp:Repeater ID="rptAI" runat="server">
            <ItemTemplate>
                <div class="ai-item">
                    <div class="ai-q"><i class="fa fa-question-circle me-1" style="color:var(--blue)"></i><%# H(Eval("Question")) %></div>
                    <div class="ai-a"><%# H(Eval("Answer")) %></div>
                    <div class="ai-meta">
                        <span><i class="fa fa-video me-1"></i><%# H(Eval("VideoTitle")) %></span>
                        <span><i class="fa fa-book me-1"></i><%# H(Eval("SubjectName")) %></span>
                        <span><i class="fa fa-user me-1"></i><%# H(Eval("StudentName")) %></span>
                        <span style="margin-left:auto"><i class="fa fa-clock me-1"></i><%# FmtDateTime(Eval("CreatedOn")) %></span>
                    </div>
                </div>
            </ItemTemplate>
            <FooterTemplate>
                <asp:Panel runat="server" Visible='<%# rptAI.Items.Count==0 %>'>
                    <div class="empty"><i class="fa fa-robot"></i><p>No AI interactions.</p></div>
                </asp:Panel>
            </FooterTemplate>
        </asp:Repeater>
    </div>
</div>

</div><%-- /td-root --%>

<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
<script>
/* ── HELPERS ─────────────────────────────────────────────────── */
function hf(id){var e=document.getElementById(id);return e?e.value:'';}
function jp(id){try{return JSON.parse(hf(id)||'[]');}catch(e){return[];}}
function jpn(id){var v=parseFloat(hf(id));return isNaN(v)?0:v;}
Chart.defaults.font.family="'Plus Jakarta Sans',system-ui,sans-serif";
Chart.defaults.color='#64748b';

/* ── TABS ────────────────────────────────────────────────────── */
var built={};
function sw(btn,pane){
    document.querySelectorAll('.tab-btn').forEach(function(b){b.classList.remove('on');});
    document.querySelectorAll('.tab-pane').forEach(function(p){p.classList.remove('on');});
    btn.classList.add('on');
    var el=document.getElementById(pane);if(el)el.classList.add('on');
    if(!built[pane]){built[pane]=true;buildFor(pane);}
}

/* ── INIT ────────────────────────────────────────────────────── */
document.addEventListener('DOMContentLoaded',function(){
    // KPI count-up
    var map={
        kSubjects:'<%= hfKpiSubjects.ClientID %>',
        kVideos:  '<%= hfKpiVideos.ClientID %>',
        kViews:   '<%= hfKpiViews.ClientID %>',
        kAssign:  '<%= hfKpiAssignments.ClientID %>',
        kStudents:'<%= hfKpiStudents.ClientID %>',
        kAI:      '<%= hfKpiAI.ClientID %>'
    };
    Object.keys(map).forEach(function(k){
        var el=document.getElementById(k);
        if(el) countUp(el,parseFloat(hf(map[k]))||0);
    });

    // Hero rating
    var r=jpn('<%= hfKpiRating.ClientID %>');
    document.getElementById('heroRating').innerText=r.toFixed(1);
    var s=''; for(var i=1;i<=5;i++) s+=(i<=Math.round(r)?'★':'☆');
    document.getElementById('heroStars').innerText=s;

    // Badges
    var cmt=document.getElementById('cmtBadge');
    if(cmt) cmt.innerText=hf('<%= hfCommentTotal.ClientID %>')+' comments';
    var ai=document.getElementById('aiBadge');
    if(ai) ai.innerText=hf('<%= hfAITotal.ClientID %>')+' interactions';

    // Assignment summary
    var asgTot=document.getElementById('asgTotalLbl');
    var asgSub=document.getElementById('asgSubsLbl');
    if(asgTot) asgTot.innerText=hf('<%= hfAsgTotal.ClientID %>');
    if(asgSub){
        var arr=jp('<%= hfAsgSubs.ClientID %>');
        asgSub.innerText=arr.reduce(function(a,b){return a+b;},0);
    }

    // Sync duplicate profile labels
    var pairs=[
        ['<%= lblEmpId.ClientID %>','<%= lblEmpId2.ClientID %>'],
        ['<%= lblDesig.ClientID %>','<%= lblDesig2.ClientID %>'],
        ['<%= lblStream.ClientID %>','<%= lblStream2.ClientID %>'],
        ['<%= lblSession.ClientID %>','<%= lblSession2.ClientID %>'],
        ['<%= lblLastLogin.ClientID %>','<%= lblLastLogin2.ClientID %>']
    ];
    pairs.forEach(function(p){
        var src=document.getElementById(p[0]);
        var dst=document.getElementById(p[1]);
        if(src&&dst) dst.innerHTML=src.innerHTML;
    });

    // Animate progress bars
    var obs=new IntersectionObserver(function(entries){
        entries.forEach(function(e){
            if(e.isIntersecting){
                var f=e.target,w=f.style.width;
                f.style.width='0';setTimeout(function(){f.style.width=w;},50);
                obs.unobserve(f);
            }
        });
    },{threshold:.1});
    document.querySelectorAll('.pb-fill').forEach(function(el){obs.observe(el);});

    buildFor('tProfile');
});

/* ── COUNT-UP ────────────────────────────────────────────────── */
function countUp(el,target){
    var dur=900,start=performance.now();
    (function step(now){
        var p=Math.min((now-start)/dur,1);
        var e=1-Math.pow(1-p,3);
        el.textContent=Math.round(target*e).toLocaleString();
        if(p<1)requestAnimationFrame(step);
    })(performance.now());
}

/* ── CHART DISPATCHER ────────────────────────────────────────── */
function buildFor(tab){
    if(tab==='tProfile')    buildRadar();
    if(tab==='tSubjects')  {buildSyllabus();buildEnroll();}
    if(tab==='tRatings')   {buildRatingChart();buildViewsChart();}
    if(tab==='tAssignments'){buildAsg();}
    if(tab==='tAttendance') buildAtt();
    if(tab==='tAnalytics')  buildTrend();
}

/* ── RADAR ───────────────────────────────────────────────────── */
function buildRadar(){
    var ctx=document.getElementById('radarChart');
    if(!ctx||ctx._c)return;
    var subs=jpn('<%= hfKpiSubjects.ClientID %>');
    var vids=jpn('<%= hfKpiVideos.ClientID %>');
    var asgn=jpn('<%= hfKpiAssignments.ClientID %>');
    var stud=jpn('<%= hfKpiStudents.ClientID %>');
    var rate=jpn('<%= hfKpiRating.ClientID %>');
    ctx._c=new Chart(ctx,{type:'radar',
        data:{labels:['Subjects','Videos','Assignments','Students','Rating'],
            datasets:[{label:'Teacher',
                data:[Math.min(subs*10,100),Math.min(vids*5,100),Math.min(asgn*5,100),Math.min(stud*2,100),rate*20],
                backgroundColor:'rgba(79,70,229,.15)',borderColor:'#4f46e5',
                borderWidth:2.5,pointBackgroundColor:'#4f46e5',pointRadius:5}]},
        options:{responsive:true,animation:{duration:1200},
            scales:{r:{min:0,max:100,ticks:{stepSize:20,backdropColor:'transparent',font:{size:10}},
                grid:{color:'rgba(0,0,0,.06)'},angleLines:{color:'rgba(0,0,0,.06)'},
                pointLabels:{font:{size:11,weight:'600'}}}},
            plugins:{legend:{display:false}}}});
}

/* ── SYLLABUS BAR ────────────────────────────────────────────── */
function buildSyllabus(){
    var ctx=document.getElementById('syllabusChart');
    if(!ctx||ctx._c)return;
    var L=jp('<%= hfSubjectLabels.ClientID %>'),D=jp('<%= hfSyllabusPcts.ClientID %>');
    if(!L.length){ctx.parentElement.innerHTML=emptyH('No subjects.');return;}
    ctx._c=new Chart(ctx,{type:'bar',
        data:{labels:L,datasets:[{label:'Completion %',data:D,backgroundColor:'rgba(79,70,229,.75)',borderRadius:7,borderSkipped:false}]},
        options:bOpts('%','%')});
}

/* ── ENROLL BAR ──────────────────────────────────────────────── */
function buildEnroll(){
    var ctx=document.getElementById('enrollChart');
    if(!ctx||ctx._c)return;
    var L=jp('<%= hfSubjectLabels.ClientID %>'),D=jp('<%= hfEnrollCounts.ClientID %>');
    if(!L.length){ctx.parentElement.innerHTML=emptyH('No data.');return;}
    ctx._c=new Chart(ctx,{type:'bar',
        data:{labels:L,datasets:[{label:'Students',data:D,backgroundColor:'rgba(5,150,105,.75)',borderRadius:7,borderSkipped:false}]},
        options:bOpts('','Students')});
}

/* ── RATING H-BAR ────────────────────────────────────────────── */
function buildRatingChart(){
    var ctx=document.getElementById('ratingChart');
    if(!ctx||ctx._c)return;
    var L=jp('<%= hfRatingLabels.ClientID %>'),D=jp('<%= hfRatingAvgs.ClientID %>');
    if(!L.length){ctx.parentElement.innerHTML=emptyH('No ratings.');return;}
    ctx._c=new Chart(ctx,{type:'bar',
        data:{labels:L,datasets:[{label:'Avg Rating',data:D,backgroundColor:'rgba(245,158,11,.8)',borderRadius:6,borderSkipped:false,indexAxis:'y'}]},
        options:{indexAxis:'y',responsive:true,animation:{duration:900},
            scales:{x:{min:0,max:5,ticks:{font:{size:10},callback:function(v){return v+'★';}},grid:{color:'rgba(0,0,0,.04)'}},
                    y:{grid:{display:false},ticks:{font:{size:10}}}},
            plugins:{legend:{display:false},tooltip:{callbacks:{label:function(c){return c.raw+'★';}}}}}});
}

/* ── VIEWS H-BAR ─────────────────────────────────────────────── */
function buildViewsChart(){
    var ctx=document.getElementById('viewsChart');
    if(!ctx||ctx._c)return;
    var L=jp('<%= hfRatingLabels.ClientID %>'),D=jp('<%= hfRatingViews.ClientID %>');
    if(!L.length){ctx.parentElement.innerHTML=emptyH('No data.');return;}
    ctx._c=new Chart(ctx,{type:'bar',
        data:{labels:L,datasets:[{label:'Views',data:D,backgroundColor:'rgba(8,145,178,.75)',borderRadius:6,borderSkipped:false,indexAxis:'y'}]},
        options:{indexAxis:'y',responsive:true,animation:{duration:900},
            scales:{x:{ticks:{font:{size:10}},grid:{color:'rgba(0,0,0,.04)'}},y:{grid:{display:false},ticks:{font:{size:10}}}},
            plugins:{legend:{display:false}}}});
}

/* ── ASSIGNMENT GROUPED BAR ──────────────────────────────────── */
function buildAsg(){
    var ctx=document.getElementById('asgChart');
    if(!ctx||ctx._c)return;
    var L=jp('<%= hfAsgLabels.ClientID %>'),S=jp('<%= hfAsgSubs.ClientID %>'),T=jp('<%= hfAsgTotals.ClientID %>');
    if(!L.length){ctx.parentElement.innerHTML=emptyH('No assignments.');return;}
    ctx._c=new Chart(ctx,{type:'bar',
        data:{labels:L,datasets:[
            {label:'Submitted',data:S,backgroundColor:'rgba(79,70,229,.75)',borderRadius:5,borderSkipped:false},
            {label:'Total',data:T,backgroundColor:'rgba(148,163,184,.4)',borderRadius:5,borderSkipped:false}]},
        options:bOpts('','Count')});
}

/* ── ATTENDANCE BAR ──────────────────────────────────────────── */
function buildAtt(){
    var ctx=document.getElementById('attChart');
    if(!ctx||ctx._c)return;
    var L=jp('<%= hfAttLabels.ClientID %>'),D=jp('<%= hfAttPcts.ClientID %>');
    if(!L.length){ctx.parentElement.innerHTML=emptyH('No attendance data.');return;}
    var colors=D.map(function(v){return v>=75?'rgba(5,150,105,.75)':v>=50?'rgba(217,119,6,.75)':'rgba(220,38,38,.75)';});
    ctx._c=new Chart(ctx,{type:'bar',
        data:{labels:L,datasets:[{label:'Attendance %',data:D,backgroundColor:colors,borderRadius:7,borderSkipped:false}]},
        options:bOpts('%','Att %')});
}

/* ── TREND COMBO ─────────────────────────────────────────────── */
function buildTrend(){
    var ctx=document.getElementById('trendChart');
    if(!ctx||ctx._c)return;
    var L=jp('<%= hfTrendLabels.ClientID %>'),C=jp('<%= hfTrendCounts.ClientID %>'),V=jp('<%= hfTrendViews.ClientID %>');
        if (!L.length) { ctx.parentElement.innerHTML = emptyH('No upload history.'); return; }
        ctx._c = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: L, datasets: [
                    { label: 'Uploads', data: C, backgroundColor: 'rgba(79,70,229,.75)', borderRadius: 6, borderSkipped: false, yAxisID: 'y' },
                    {
                        label: 'Views', data: V, type: 'line', borderColor: '#f59e0b', backgroundColor: 'rgba(245,158,11,.1)',
                        borderWidth: 2.5, pointRadius: 4, tension: .4, fill: true, yAxisID: 'y1'
                    }]
            },
            options: {
                responsive: true, animation: { duration: 1000 }, interaction: { mode: 'index', intersect: false },
                scales: {
                    y: { position: 'left', grid: { color: 'rgba(0,0,0,.04)' }, ticks: { font: { size: 10 } }, title: { display: true, text: 'Videos', font: { size: 10 } } },
                    y1: { position: 'right', grid: { drawOnChartArea: false }, ticks: { font: { size: 10 } }, title: { display: true, text: 'Views', font: { size: 10 } } }
                },
                plugins: { legend: { position: 'top', labels: { font: { size: 11 } } } }
            }
        });
    }

    /* ── SHARED BAR OPTIONS ──────────────────────────────────────── */
    function bOpts(sfx, yLbl) {
        return {
            responsive: true, animation: { duration: 900, easing: 'easeOutQuart' },
            scales: {
                y: {
                    beginAtZero: true, grid: { color: 'rgba(0,0,0,.04)' },
                    ticks: { font: { size: 10 }, callback: function (v) { return v + sfx; } },
                    title: { display: true, text: yLbl, font: { size: 10 } }
                },
                x: { grid: { display: false }, ticks: { font: { size: 10, weight: '600' } } }
            },
            plugins: { legend: { display: false }, tooltip: { callbacks: { label: function (c) { return c.raw + sfx; } } } }
        };
    }
    function emptyH(msg) {
        return '<div class="empty"><i class="fa fa-chart-bar"></i><p>' + msg + '</p></div>';
    }

    /* ── ACCORDION ───────────────────────────────────────────────── */
    function toggleAcc(hd) {
        hd.classList.toggle('open');
        var b = hd.nextElementSibling;
        if (b && b.classList.contains('acc-body')) b.classList.toggle('open');
    }
</script>

</asp:Content>
