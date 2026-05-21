<%@ Page Title="Student Details" Language="C#"
    MasterPageFile="~/Admin/AdminMaster.master"
    AutoEventWireup="true"
    CodeBehind="StudentDetails.aspx.cs"
    Inherits="LearningManagementSystem.Admin.StudentDetails" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@300;400;500;600;700&family=DM+Mono:wght@400;500&family=Fraunces:wght@700;800&display=swap" rel="stylesheet">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

<%-- ══ ALL HIDDEN FIELDS (data bridges server→JS) ══════════════════════════ --%>
<asp:HiddenField ID="hfAttScore"        runat="server" />
<asp:HiddenField ID="hfAssScore"        runat="server" />
<asp:HiddenField ID="hfQuizScore"       runat="server" />
<asp:HiddenField ID="hfVideoScore"      runat="server" />
<asp:HiddenField ID="hfOverall"         runat="server" />
<asp:HiddenField ID="hfAttPct"          runat="server" />
<asp:HiddenField ID="hfAttMonthLabels"  runat="server" />
<asp:HiddenField ID="hfAttMonthPresent" runat="server" />
<asp:HiddenField ID="hfAttMonthPct"     runat="server" />
<asp:HiddenField ID="hfCalData"         runat="server" />
<asp:HiddenField ID="hfAsgChartData"    runat="server" />
<asp:HiddenField ID="hfQzChartData"     runat="server" />
<asp:HiddenField ID="hfAILabels"        runat="server" />
<asp:HiddenField ID="hfAICounts"        runat="server" />

<style>
/* ═══════════════════════════════════════════════════════════════
   TOKENS & RESET
═══════════════════════════════════════════════════════════════ */
:root {
  --ink:#0d1117; --ink-2:#1e293b; --ink-3:#334155; --ink-4:#64748b; --ink-5:#94a3b8;
  --surf:#ffffff; --surf-2:#f8fafc; --surf-3:#f1f5f9; --surf-4:#e2e8f0;
  --blue:#4f46e5; --blue-lt:#eef2ff; --blue-dk:#3730a3;
  --green:#059669; --green-lt:#ecfdf5;
  --amber:#d97706; --amber-lt:#fffbeb;
  --red:#dc2626; --red-lt:#fef2f2;
  --cyan:#0891b2; --cyan-lt:#ecfeff;
  --purple:#7c3aed; --purple-lt:#f5f3ff;
  --pink:#db2777; --pink-lt:#fdf2f8;
  --radius:14px; --radius-sm:8px; --radius-lg:20px;
  --shadow:0 1px 3px rgba(0,0,0,.06),0 4px 16px rgba(0,0,0,.05);
  --shadow-lg:0 8px 40px rgba(0,0,0,.12);
  --f-body:'DM Sans',system-ui,sans-serif;
  --f-display:'Fraunces',serif;
  --f-mono:'DM Mono',monospace;
  --transition:.22s cubic-bezier(.4,0,.2,1);
}

* { box-sizing:border-box; margin:0; padding:0; }
body { font-family:var(--f-body); color:var(--ink); background:var(--surf-2); font-size:14px; }

/* ─── LAYOUT ─────────────────────────────────────────────────── */
.sd-root { max-width:1440px; margin:0 auto; padding:0 20px 60px; }

/* ─── BACK + HEADER STRIP ─────────────────────────────────────── */
.sd-topbar {
  display:flex; align-items:center; justify-content:space-between;
  padding:18px 0 14px; flex-wrap:wrap; gap:10px;
}
.sd-back {
  display:inline-flex; align-items:center; gap:7px;
  font-size:13px; font-weight:600; color:var(--ink-4);
  text-decoration:none; transition:color var(--transition);
}
.sd-back:hover { color:var(--blue); }
.sd-session-wrap { display:flex; align-items:center; gap:8px; }
.sd-session-wrap label { font-size:12px; font-weight:600; color:var(--ink-4); white-space:nowrap; }
.sd-session-sel {
  border:1.5px solid var(--surf-4); border-radius:var(--radius-sm);
  padding:6px 12px; font-size:13px; font-family:var(--f-body);
  background:var(--surf); color:var(--ink); cursor:pointer;
  transition:border-color var(--transition);
}
.sd-session-sel:focus { outline:none; border-color:var(--blue); }

/* ─── HERO PROFILE CARD ──────────────────────────────────────── */
.sd-hero {
  background:var(--surf);
  border-radius:var(--radius-lg);
  border:1.5px solid var(--surf-4);
  box-shadow:var(--shadow);
  padding:30px 32px;
  display:flex; align-items:flex-start; gap:28px; flex-wrap:wrap;
  margin-bottom:24px;
  position:relative; overflow:hidden;
}
.sd-hero::before {
  content:''; position:absolute; top:0; left:0; right:0; height:4px;
  background:linear-gradient(90deg,var(--blue),var(--purple),var(--pink));
}
.sd-avatar-ring {
  width:90px; height:90px; border-radius:50%; flex-shrink:0;
  display:flex; align-items:center; justify-content:center;
  font-family:var(--f-display); font-size:32px; font-weight:700; color:#fff;
  box-shadow:0 0 0 4px rgba(255,255,255,.8),0 0 0 7px currentColor;
  animation:avatarPop .5s var(--transition) both;
}
@keyframes avatarPop {
  0%   { transform:scale(.6); opacity:0; }
  80%  { transform:scale(1.06); }
  100% { transform:scale(1); opacity:1; }
}
.sd-hero-info { flex:1; min-width:220px; }
.sd-hero-name {
  font-family:var(--f-display); font-size:1.5rem; font-weight:800;
  color:var(--ink); line-height:1.15; margin-bottom:6px;
}
.sd-hero-meta { display:flex; flex-wrap:wrap; gap:8px; align-items:center; margin-bottom:12px; }
.sd-pill {
  display:inline-flex; align-items:center; gap:5px;
  background:var(--surf-3); border-radius:30px;
  padding:3px 10px; font-size:11px; font-weight:600; color:var(--ink-3);
}
.status-badge {
  display:inline-flex; align-items:center; gap:4px;
  border-radius:30px; padding:3px 10px; font-size:11px; font-weight:700;
}
.status-badge::before { content:''; width:6px; height:6px; border-radius:50%; }
.status-badge.active  { background:var(--green-lt); color:var(--green); }
.status-badge.active::before  { background:var(--green); }
.status-badge.inactive { background:var(--red-lt); color:var(--red); }
.status-badge.inactive::before { background:var(--red); }
.sd-hero-stream { font-size:13px; color:var(--ink-4); }
.sd-hero-right { display:flex; flex-direction:column; gap:8px; align-items:flex-end; }

/* ─── KPI RIBBON ─────────────────────────────────────────────── */
.kpi-ribbon {
  display:grid; grid-template-columns:repeat(auto-fill,minmax(160px,1fr));
  gap:14px; margin-bottom:24px;
}
.kpi-card {
  background:var(--surf); border-radius:var(--radius);
  border:1.5px solid var(--surf-4); box-shadow:var(--shadow);
  padding:18px 20px; position:relative; overflow:hidden;
  transition:transform var(--transition),box-shadow var(--transition);
  animation:fadeUp .5s both;
}
.kpi-card:hover { transform:translateY(-4px); box-shadow:var(--shadow-lg); }
.kpi-card::after {
  content:''; position:absolute; bottom:0; left:0; right:0; height:3px;
  background:var(--accent,var(--blue)); border-radius:0 0 3px 3px;
}
.kpi-card .kpi-icon {
  width:36px; height:36px; border-radius:10px; margin-bottom:10px;
  display:flex; align-items:center; justify-content:center; font-size:15px;
}
.kpi-card .kpi-val {
  font-family:var(--f-display); font-size:1.2rem; font-weight:800; line-height:1;
  color:var(--ink); margin-bottom:4px;
}
.kpi-card .kpi-lbl { font-size:11px; font-weight:600; color:var(--ink-4); text-transform:uppercase; letter-spacing:.04em; }
.kpi-card .kpi-sub { font-size:11px; color:var(--ink-5); margin-top:2px; }
@keyframes fadeUp { from{opacity:0;transform:translateY(16px)} to{opacity:1;transform:translateY(0)} }

/* ─── SECTION TABS ───────────────────────────────────────────── */
.sd-tabs {
  display:flex; gap:4px; flex-wrap:wrap;
  background:var(--surf-3); border-radius:12px;
  padding:5px; margin-bottom:22px; border:1.5px solid var(--surf-4);
}
.sd-tab-btn {
  border:none; background:transparent; border-radius:8px;
  padding:8px 16px; font-family:var(--f-body); font-size:13px;
  font-weight:600; color:var(--ink-4); cursor:pointer;
  display:flex; align-items:center; gap:6px;
  transition:all var(--transition);
}
.sd-tab-btn:hover { background:var(--surf); color:var(--ink); }
.sd-tab-btn.active { background:var(--surf); color:var(--blue); box-shadow:var(--shadow); }
.sd-tab-btn .tab-dot {
  width:18px; height:18px; border-radius:5px; font-size:10px;
  display:flex; align-items:center; justify-content:center;
  background:var(--blue-lt); color:var(--blue); font-weight:700;
}

/* ─── SECTION PANEL ──────────────────────────────────────────── */
.sd-panel { display:none; animation:fadeUp .3s both; }
.sd-panel.active { display:block; }

/* ─── SECTION HEADING ────────────────────────────────────────── */
.sec-hd {
  display:flex; align-items:center; justify-content:space-between;
  margin-bottom:16px; flex-wrap:wrap; gap:8px;
}
.sec-title {
  font-family:var(--f-display); font-size:1.1rem; font-weight:700; color:var(--ink);
  display:flex; align-items:center; gap:8px;
}
.sec-title .ico {
  width:30px; height:30px; border-radius:8px;
  display:flex; align-items:center; justify-content:center;
  font-size:13px;
}

/* ─── CARD GENERIC ───────────────────────────────────────────── */
.sd-card {
  background:var(--surf); border-radius:var(--radius);
  border:1.5px solid var(--surf-4); box-shadow:var(--shadow);
  padding:22px 24px; margin-bottom:18px;
}

/* ─── PROFILE SECTION ────────────────────────────────────────── */
.prof-grid {
  display:grid; grid-template-columns:1fr 1fr; gap:12px;
}
@media(max-width:600px){.prof-grid{grid-template-columns:1fr}}
.prof-field { background:var(--surf-2); border-radius:var(--radius-sm); padding:11px 14px; }
.prof-field .pf-lbl { font-size:10px; font-weight:700; text-transform:uppercase; letter-spacing:.05em; color:var(--ink-5); margin-bottom:4px; }
.prof-field .pf-val { font-size:13px; font-weight:600; color:var(--ink-2); }
.prof-full { grid-column:1/-1; }

/* ─── STAT STRIP ─────────────────────────────────────────────── */
.stat-strip { display:flex; gap:10px; flex-wrap:wrap; margin-bottom:18px; }
.stat-chip {
  background:var(--surf-2); border-radius:10px; border:1.5px solid var(--surf-4);
  padding:12px 18px; flex:1; min-width:100px; text-align:center;
}
.stat-chip .s-val { font-family:var(--f-display); font-size:1.6rem; font-weight:800; }
.stat-chip .s-lbl { font-size:10px; font-weight:600; color:var(--ink-4); text-transform:uppercase; letter-spacing:.04em; margin-top:2px; }

/* ─── PROGRESS BAR ───────────────────────────────────────────── */
.progress-wrap { background:var(--surf-3); border-radius:30px; height:8px; overflow:hidden; }
.progress-fill {
  height:100%; border-radius:30px;
  transition:width 1.2s cubic-bezier(.4,0,.2,1);
  position:relative;
}
.progress-fill::after {
  content:''; position:absolute; top:0; left:0; right:0; bottom:0;
  background:linear-gradient(90deg,transparent,rgba(255,255,255,.35),transparent);
  animation:shimmer 2s infinite;
}
@keyframes shimmer { 0%{transform:translateX(-100%)} 100%{transform:translateX(100%)} }

/* ─── TABLE GENERIC ──────────────────────────────────────────── */
.sd-table-wrap { overflow-x:auto; border-radius:var(--radius-sm); }
.sd-table { width:100%; border-collapse:collapse; min-width:520px; }
.sd-table thead th {
  background:linear-gradient(135deg,#4f46e5,#6366f1);
  color:#fff; padding:11px 14px; font-size:11px; font-weight:700;
  text-transform:uppercase; letter-spacing:.04em; white-space:nowrap; text-align:left;
}
.sd-table tbody td {
  padding:11px 14px; border-bottom:1px solid var(--surf-3);
  font-size:13px; vertical-align:middle; color:var(--ink-2);
}
.sd-table tbody tr:last-child td { border-bottom:none; }
.sd-table tbody tr { transition:background var(--transition); }
.sd-table tbody tr:hover { background:var(--surf-2); }

/* ─── STATUS TAGS ────────────────────────────────────────────── */
.tag {
  display:inline-flex; align-items:center; gap:4px;
  border-radius:6px; padding:3px 9px; font-size:11px; font-weight:700; white-space:nowrap;
}
.tag-graded   { background:#dcfce7; color:#15803d; }
.tag-submitted{ background:#dbeafe; color:#1d4ed8; }
.tag-pending  { background:#fef9c3; color:#854d0e; }
.tag-missed   { background:#fee2e2; color:#b91c1c; }
.tag-present  { background:#dcfce7; color:#15803d; }
.tag-absent   { background:#fee2e2; color:#b91c1c; }
.tag-leave    { background:#fef9c3; color:#854d0e; }

/* ─── CHARTS ─────────────────────────────────────────────────── */
.chart-row {
  display:grid; grid-template-columns:1fr 1fr; gap:18px; margin-bottom:18px;
}
@media(max-width:768px){.chart-row{grid-template-columns:1fr}}
.chart-box {
  background:var(--surf); border-radius:var(--radius);
  border:1.5px solid var(--surf-4); box-shadow:var(--shadow);
  padding:20px 22px;
}
.chart-title { font-size:13px; font-weight:700; color:var(--ink-3); margin-bottom:14px; display:flex; align-items:center; gap:6px; }
canvas { max-height:220px; }

/* ─── CALENDAR HEATMAP ───────────────────────────────────────── */
.cal-grid { display:flex; flex-wrap:wrap; gap:3px; padding:4px 0; }
.cal-day {
  width:14px; height:14px; border-radius:3px; cursor:pointer;
  transition:transform .15s;
  position:relative;
}
.cal-day:hover { transform:scale(1.4); z-index:2; }
.cal-day[data-status="Present"] { background:#059669; }
.cal-day[data-status="Absent"]  { background:#dc2626; }
.cal-day[data-status="Leave"]   { background:#d97706; }
.cal-day[data-status="none"]    { background:var(--surf-3); }
.cal-tip {
  position:absolute; bottom:calc(100%+5px); left:50%; transform:translateX(-50%);
  background:var(--ink); color:#fff; font-size:10px; white-space:nowrap;
  border-radius:5px; padding:3px 7px; pointer-events:none; opacity:0;
  transition:opacity .15s; z-index:10;
}
.cal-day:hover .cal-tip { opacity:1; }
.cal-legend { display:flex; gap:12px; margin-top:10px; }
.cal-legend-item { display:flex; align-items:center; gap:5px; font-size:11px; color:var(--ink-4); }
.cal-legend-dot { width:10px; height:10px; border-radius:2px; }

/* ─── SUBJECT CARDS ──────────────────────────────────────────── */
.subj-grid {
  display:grid; grid-template-columns:repeat(auto-fill,minmax(300px,1fr)); gap:14px;
}
.subj-card {
  background:var(--surf); border:1.5px solid var(--surf-4);
  border-radius:var(--radius); box-shadow:var(--shadow);
  padding:18px 20px; transition:transform var(--transition),box-shadow var(--transition);
  position:relative; overflow:hidden;
}
.subj-card:hover { transform:translateY(-3px); box-shadow:var(--shadow-lg); }
.subj-card .sc-accent { position:absolute; top:0; left:0; width:4px; height:100%; }
.subj-card .sc-name { font-weight:700; color:var(--ink); margin-bottom:3px; }
.subj-card .sc-code { font-size:11px; color:var(--ink-5); font-family:var(--f-mono); margin-bottom:12px; }
.subj-metrics { display:grid; grid-template-columns:1fr 1fr 1fr; gap:8px; margin-bottom:12px; }
.subj-metric { background:var(--surf-2); border-radius:7px; padding:8px 10px; text-align:center; }
.subj-metric .sm-val { font-family:var(--f-display); font-size:1.1rem; font-weight:800; color:var(--ink); }
.subj-metric .sm-lbl { font-size:9px; font-weight:600; color:var(--ink-5); text-transform:uppercase; letter-spacing:.04em; }
.sc-teacher { font-size:11px; color:var(--ink-4); display:flex; align-items:center; gap:5px; margin-top:8px; }

/* ─── VIDEO LIST ─────────────────────────────────────────────── */
.vid-row {
  display:flex; align-items:center; gap:12px;
  padding:10px 12px; border-radius:var(--radius-sm);
  border:1px solid var(--surf-4); margin-bottom:8px;
  transition:background var(--transition);
}
.vid-row:hover { background:var(--surf-2); }
.vid-thumb {
  width:44px; height:44px; border-radius:8px; flex-shrink:0;
  background:var(--blue-lt); display:flex; align-items:center;
  justify-content:center; font-size:16px; color:var(--blue);
}
.vid-info { flex:1; min-width:0; }
.vid-title { font-size:13px; font-weight:600; color:var(--ink); white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
.vid-chapter { font-size:11px; color:var(--ink-5); }
.vid-prog { width:120px; flex-shrink:0; }
.vid-pct { font-size:11px; font-weight:600; color:var(--ink-4); text-align:right; margin-bottom:3px; }

/* ─── TIMELINE (Activity / Notifications) ────────────────────── */
.timeline { position:relative; padding-left:28px; }
.timeline::before { content:''; position:absolute; left:10px; top:0; bottom:0; width:2px; background:var(--surf-4); }
.tl-item { position:relative; margin-bottom:16px; }
.tl-dot {
  position:absolute; left:-24px; top:2px;
  width:20px; height:20px; border-radius:50%;
  display:flex; align-items:center; justify-content:center;
  font-size:9px; color:#fff; flex-shrink:0;
}
.tl-content { background:var(--surf-2); border-radius:var(--radius-sm); padding:10px 13px; border:1px solid var(--surf-4); }
.tl-title { font-size:13px; font-weight:600; color:var(--ink); }
.tl-time  { font-size:11px; color:var(--ink-5); margin-top:2px; }
.tl-body  { font-size:12px; color:var(--ink-3); margin-top:5px; }

/* ─── HELP THREAD ────────────────────────────────────────────── */
.help-card { background:var(--surf); border:1.5px solid var(--surf-4); border-radius:var(--radius); padding:16px 18px; margin-bottom:12px; }
.help-q { font-size:13px; font-weight:600; color:var(--ink); }
.help-time { font-size:11px; color:var(--ink-5); margin-top:3px; margin-bottom:10px; }
.help-reply {
  background:var(--blue-lt); border-radius:var(--radius-sm);
  padding:10px 13px; margin-top:8px; border-left:3px solid var(--blue);
}
.help-reply .hr-from { font-size:10px; font-weight:700; color:var(--blue); text-transform:uppercase; margin-bottom:4px; }
.help-reply .hr-text { font-size:12px; color:var(--ink-2); }
.help-pending { background:var(--amber-lt); border-radius:var(--radius-sm); padding:8px 13px; font-size:12px; color:var(--amber); font-weight:600; margin-top:8px; }

/* ─── PARENT CARDS ───────────────────────────────────────────── */
.parent-strip { display:flex; flex-wrap:wrap; gap:12px; }
.parent-card {
  background:var(--surf-2); border-radius:var(--radius-sm);
  border:1.5px solid var(--surf-4); padding:14px 18px; flex:1; min-width:200px;
  display:flex; align-items:center; gap:12px;
}
.parent-av { width:40px; height:40px; border-radius:50%; background:var(--purple-lt); color:var(--purple); display:flex; align-items:center; justify-content:center; font-weight:700; font-size:15px; flex-shrink:0; }
.parent-info .pi-name { font-weight:700; font-size:14px; color:var(--ink); }
.parent-info .pi-rel  { font-size:11px; color:var(--ink-4); }
.parent-info .pi-cont { font-size:12px; color:var(--ink-3); margin-top:3px; }

/* ─── RADAR / DONUT SUMMARY ──────────────────────────────────── */
.donut-wrap { position:relative; width:160px; height:160px; margin:0 auto; }
.donut-center {
  position:absolute; inset:0; display:flex; flex-direction:column;
  align-items:center; justify-content:center;
}
.donut-center .dc-val { font-family:var(--f-display); font-size:1.8rem; font-weight:800; color:var(--ink); line-height:1; }
.donut-center .dc-lbl { font-size:10px; font-weight:600; color:var(--ink-4); text-transform:uppercase; letter-spacing:.04em; }

/* ─── EMPTY STATE ────────────────────────────────────────────── */
.empty-state { text-align:center; padding:40px 20px; color:var(--ink-5); }
.empty-state i { font-size:2.2rem; opacity:.3; display:block; margin-bottom:10px; }
.empty-state p { font-size:13px; }

/* ─── ACCORDION (Video by subject) ──────────────────────────── */
.acc-hd {
  display:flex; align-items:center; justify-content:space-between;
  padding:12px 14px; background:var(--surf-2); border-radius:var(--radius-sm);
  cursor:pointer; user-select:none; border:1px solid var(--surf-4);
  transition:background var(--transition); margin-bottom:4px;
}
.acc-hd:hover { background:var(--surf-3); }
.acc-hd .ah-title { font-weight:600; font-size:13px; color:var(--ink); }
.acc-hd .ah-arrow { transition:transform var(--transition); font-size:12px; color:var(--ink-4); }
.acc-hd.open .ah-arrow { transform:rotate(90deg); }
.acc-body { display:none; padding:4px 0 10px; }
.acc-body.open { display:block; }

/* ─── ANIMATIONS ─────────────────────────────────────────────── */
.animate-in { animation:fadeUp .4s var(--transition) both; }
@keyframes countUp { from { opacity:0; transform:translateY(6px); } to { opacity:1; transform:translateY(0); } }

/* ─── RESPONSIVE ─────────────────────────────────────────────── */
@media(max-width:768px) {
  .sd-hero { padding:20px 16px; gap:16px; }
  .kpi-ribbon { grid-template-columns:repeat(2,1fr); }
  .sd-hero-right { align-items:flex-start; }
  .prof-grid { grid-template-columns:1fr; }
  .chart-row { grid-template-columns:1fr; }
  .subj-grid { grid-template-columns:1fr; }
}
@media(max-width:480px) {
  .sd-tabs { gap:2px; }
  .sd-tab-btn { padding:7px 10px; font-size:12px; }
  .kpi-ribbon { grid-template-columns:1fr 1fr; }
}
</style>

<div class="sd-root">

<%-- ── TOPBAR ── --%>
<div class="sd-topbar animate-in">
    <a href="StudentsList.aspx" class="sd-back">
        <i class="fa fa-arrow-left"></i> Back to Students
    </a>
    <div class="sd-session-wrap">
        <label><i class="fa fa-calendar-alt me-1"></i>Session:</label>
        <asp:DropDownList ID="ddlViewSession" runat="server"
            CssClass="sd-session-sel"
            AutoPostBack="true"
            OnSelectedIndexChanged="ddlViewSession_Changed" />
    </div>
</div>

<%-- ── HERO CARD ── --%>
<div class="sd-hero animate-in" style="animation-delay:.05s">
    <div class="sd-avatar-ring"
         style="background:<%=AvatarColor%>; color:<%=AvatarColor%>">
        <%=StudentInitials%>
    </div>
    <div class="sd-hero-info">
        <div class="sd-hero-name"><%=StudentName%></div>
        <div class="sd-hero-meta">
            <span class="sd-pill"><i class="fa fa-id-badge me-1"></i><%=RollNumber%></span>
            <asp:Label ID="lblIsActive" runat="server" CssClass="status-badge active" />
            <span class="sd-pill" style="background:var(--blue-lt);color:var(--blue)">
                <i class="fa fa-layer-group me-1"></i><%=StreamCourse%>
            </span>
            <span class="sd-pill">
                <i class="fa fa-calendar me-1"></i>
                <asp:Label ID="lblReEnrolled" runat="server" />
            </span>
        </div>
        <div class="sd-hero-stream">
            <asp:Label ID="lblSessionName" runat="server" />
        </div>
    </div>
    <div class="sd-hero-right">
        <div style="text-align:right">
            <div style="font-size:11px;color:var(--ink-5);margin-bottom:4px;font-weight:600;text-transform:uppercase;letter-spacing:.05em">Overall Score</div>
            <div style="font-family:var(--f-display);font-size:1.2rem;font-weight:800;color:var(--blue);line-height:1">
                <%=OverallScore%><span style="font-size:1rem;color:var(--ink-4)">%</span>
            </div>
        </div>
    </div>
</div>

<%-- ── KPI RIBBON ── --%>
<div class="kpi-ribbon">
    <div class="kpi-card" style="--accent:var(--green);animation-delay:.08s">
        <div class="kpi-icon" style="background:var(--green-lt);color:var(--green)">
            <i class="fa fa-calendar-check"></i>
        </div>
        <div class="kpi-val kpi-count" data-target="<%=AttScore%>">—</div>
        <div class="kpi-lbl">Attendance</div>
        <div class="kpi-sub">% of classes attended</div>
    </div>
    <div class="kpi-card" style="--accent:var(--blue);animation-delay:.12s">
        <div class="kpi-icon" style="background:var(--blue-lt);color:var(--blue)">
            <i class="fa fa-tasks"></i>
        </div>
        <div class="kpi-val kpi-count" data-target="<%=AssScore%>">—</div>
        <div class="kpi-lbl">Assignments</div>
        <div class="kpi-sub">% completion rate</div>
    </div>
    <div class="kpi-card" style="--accent:var(--purple);animation-delay:.16s">
        <div class="kpi-icon" style="background:var(--purple-lt);color:var(--purple)">
            <i class="fa fa-brain"></i>
        </div>
        <div class="kpi-val kpi-count" data-target="<%=QuizScoreVal%>">—</div>
        <div class="kpi-lbl">Quiz Avg</div>
        <div class="kpi-sub">% avg score</div>
    </div>
    <div class="kpi-card" style="--accent:var(--cyan);animation-delay:.20s">
        <div class="kpi-icon" style="background:var(--cyan-lt);color:var(--cyan)">
            <i class="fa fa-play-circle"></i>
        </div>
        <div class="kpi-val kpi-count" data-target="<%=VideoScoreVal%>">—</div>
        <div class="kpi-lbl">Videos Done</div>
        <div class="kpi-sub">% watched (≥80%)</div>
    </div>
    <div class="kpi-card" style="--accent:var(--amber);animation-delay:.24s">
        <div class="kpi-icon" style="background:var(--amber-lt);color:var(--amber)">
            <i class="fa fa-robot"></i>
        </div>
        <div class="kpi-val" id="aiKpiVal"><%=AIUsageTotal%></div>
        <div class="kpi-lbl">AI Interactions</div>
        <div class="kpi-sub">total this session</div>
    </div>
    <div class="kpi-card" style="--accent:var(--pink);animation-delay:.28s">
        <div class="kpi-icon" style="background:var(--pink-lt);color:var(--pink)">
            <i class="fa fa-bell"></i>
        </div>
        <div class="kpi-val" id="notifKpiVal"><%=UnreadNotifsVal%></div>
        <div class="kpi-lbl">Unread Notifs</div>
        <div class="kpi-sub">pending notifications</div>
    </div>
</div>

<%-- ── SECTION TABS ── --%>
<div class="sd-tabs" role="tablist">
    <button class="sd-tab-btn active" onclick="switchTab('profile',this)" type="button">
        <i class="fa fa-user-circle"></i> Profile
    </button>
    <button class="sd-tab-btn" onclick="switchTab('attendance',this)" type="button">
        <i class="fa fa-calendar-alt"></i> Attendance
    </button>
    <button class="sd-tab-btn" onclick="switchTab('subjects',this)" type="button">
        <i class="fa fa-book-open"></i> Subjects
    </button>
    <button class="sd-tab-btn" onclick="switchTab('assignments',this)" type="button">
        <i class="fa fa-file-alt"></i> Assignments
    </button>
    <button class="sd-tab-btn" onclick="switchTab('quizzes',this)" type="button">
        <i class="fa fa-question-circle"></i> Quizzes
    </button>
    <button class="sd-tab-btn" onclick="switchTab('ai',this)" type="button">
        <i class="fa fa-robot"></i> AI Usage
    </button>
    <button class="sd-tab-btn" onclick="switchTab('activity',this)" type="button">
        <i class="fa fa-stream"></i> Activity
    </button>
    <button class="sd-tab-btn" onclick="switchTab('parents',this)" type="button">
        <i class="fa fa-users"></i> Parents
        <span class="tab-dot"><asp:Label ID="lblParentCount" runat="server">0</asp:Label></span>
    </button>
</div>

<%-- ══════════════════════════════════════════════════════════════════
     TAB 1: PROFILE
══════════════════════════════════════════════════════════════════ --%>
<div id="tab-profile" class="sd-panel active">

    <div style="display:grid;grid-template-columns:1fr 1fr;gap:18px">

        <%-- Personal Info --%>
        <div class="sd-card">
            <div class="sec-hd">
                <div class="sec-title">
                    <span class="ico" style="background:var(--blue-lt);color:var(--blue)"><i class="fa fa-user"></i></span>
                    Personal Information
                </div>
            </div>
            <div class="prof-grid">
                <div class="prof-field">
                    <div class="pf-lbl">Full Name</div>
                    <div class="pf-val"><asp:Label ID="lblFullName" runat="server" /></div>
                </div>
                <div class="prof-field">
                    <div class="pf-lbl">Gender</div>
                    <div class="pf-val"><asp:Label ID="lblGender" runat="server" /></div>
                </div>
                <div class="prof-field">
                    <div class="pf-lbl">Date of Birth</div>
                    <div class="pf-val"><asp:Label ID="lblDOB" runat="server" /></div>
                </div>
                <div class="prof-field">
                    <div class="pf-lbl">Contact No.</div>
                    <div class="pf-val"><asp:Label ID="lblContact" runat="server" /></div>
                </div>
                <div class="prof-field">
                    <div class="pf-lbl">Father's Name</div>
                    <div class="pf-val"><asp:Label ID="lblFather" runat="server" /></div>
                </div>
                <div class="prof-field">
                    <div class="pf-lbl">Mother's Name</div>
                    <div class="pf-val"><asp:Label ID="lblMother" runat="server" /></div>
                </div>
                <div class="prof-field prof-full">
                    <div class="pf-lbl">Emergency Contact</div>
                    <div class="pf-val"><asp:Label ID="lblEmerContact" runat="server" /></div>
                </div>
                <div class="prof-field prof-full">
                    <div class="pf-lbl">Address</div>
                    <div class="pf-val"><asp:Label ID="lblAddress" runat="server" /></div>
                </div>
                <div class="prof-field">
                    <div class="pf-lbl">Skills</div>
                    <div class="pf-val"><asp:Label ID="lblSkills" runat="server" /></div>
                </div>
                <div class="prof-field">
                    <div class="pf-lbl">Hobbies</div>
                    <div class="pf-val"><asp:Label ID="lblHobbies" runat="server" /></div>
                </div>
                <div class="prof-field">
                    <div class="pf-lbl">Joined Date</div>
                    <div class="pf-val"><asp:Label ID="lblJoinedDate" runat="server" /></div>
                </div>
                <div class="prof-field">
                    <div class="pf-lbl">Enrolled On</div>
                    <div class="pf-val"><asp:Label ID="lblEnrolledOn" runat="server" /></div>
                </div>
            </div>
        </div>

        <%-- Academic Info --%>
        <div class="sd-card">
            <div class="sec-hd">
                <div class="sec-title">
                    <span class="ico" style="background:var(--purple-lt);color:var(--purple)"><i class="fa fa-graduation-cap"></i></span>
                    Academic Details
                </div>
            </div>
            <div class="prof-grid">
                <div class="prof-field">
                    <div class="pf-lbl">Username</div>
                    <div class="pf-val" style="font-family:var(--f-mono)"><asp:Label ID="lblUsername" runat="server" /></div>
                </div>
                <div class="prof-field">
                    <div class="pf-lbl">Email</div>
                    <div class="pf-val"><asp:Label ID="lblEmail" runat="server" /></div>
                </div>
                <div class="prof-field">
                    <div class="pf-lbl">Roll Number</div>
                    <div class="pf-val" style="font-family:var(--f-mono);font-weight:700;color:var(--blue)"><asp:Label ID="lblRollNo" runat="server" /></div>
                </div>
                <div class="prof-field">
                    <div class="pf-lbl">Stream</div>
                    <div class="pf-val"><asp:Label ID="lblStream" runat="server" /></div>
                </div>
                <div class="prof-field">
                    <div class="pf-lbl">Course</div>
                    <div class="pf-val"><asp:Label ID="lblCourse" runat="server" /></div>
                </div>
                <div class="prof-field">
                    <div class="pf-lbl">Year / Class</div>
                    <div class="pf-val"><asp:Label ID="lblLevel" runat="server" /></div>
                </div>
                <div class="prof-field">
                    <div class="pf-lbl">Semester</div>
                    <div class="pf-val"><asp:Label ID="lblSemester" runat="server" /></div>
                </div>
                <div class="prof-field">
                    <div class="pf-lbl">Section</div>
                    <div class="pf-val"><asp:Label ID="lblSection" runat="server" /></div>
                </div>
                <div class="prof-field prof-full">
                    <div class="pf-lbl">Session</div>
                    <div class="pf-val" style="color:var(--blue);font-weight:700"><asp:Label ID="lblSessionName2" runat="server" /></div>
                </div>
            </div>

            <%-- Performance radar mini --%>
            <div style="margin-top:18px">
                <div class="chart-title"><i class="fa fa-chart-radar" style="color:var(--blue)"></i> Performance Radar</div>
                <canvas id="radarChart" height="180"></canvas>
            </div>
        </div>

    </div>
</div>

<%-- ══════════════════════════════════════════════════════════════════
     TAB 2: ATTENDANCE
══════════════════════════════════════════════════════════════════ --%>
<div id="tab-attendance" class="sd-panel">

    <%-- Summary chips --%>
    <div class="stat-strip">
        <div class="stat-chip">
            <div class="s-val" style="color:var(--ink)"><asp:Label ID="lblAttTotal" runat="server">0</asp:Label></div>
            <div class="s-lbl">Total Days</div>
        </div>
        <div class="stat-chip">
            <div class="s-val" style="color:var(--green)"><asp:Label ID="lblAttPresent" runat="server">0</asp:Label></div>
            <div class="s-lbl">Present</div>
        </div>
        <div class="stat-chip">
            <div class="s-val" style="color:var(--red)"><asp:Label ID="lblAttAbsent" runat="server">0</asp:Label></div>
            <div class="s-lbl">Absent</div>
        </div>
        <div class="stat-chip">
            <div class="s-val" style="color:var(--amber)"><asp:Label ID="lblAttLeave" runat="server">0</asp:Label></div>
            <div class="s-lbl">Leave</div>
        </div>
        <div class="stat-chip" style="background:linear-gradient(135deg,var(--green-lt),#bbf7d0)">
            <div class="s-val" style="color:var(--green)"><asp:Label ID="lblAttPct" runat="server">0%</asp:Label></div>
            <div class="s-lbl">Overall %</div>
        </div>
    </div>

    <div class="chart-row">
        <%-- Monthly trend --%>
        <div class="chart-box">
            <div class="chart-title"><i class="fa fa-chart-bar" style="color:var(--blue)"></i> Monthly Attendance Trend</div>
            <canvas id="attMonthChart"></canvas>
        </div>
        <%-- Overall donut --%>
        <div class="chart-box" style="display:flex;flex-direction:column;align-items:center;justify-content:center">
            <div class="chart-title"><i class="fa fa-circle-notch" style="color:var(--green)"></i> Attendance Distribution</div>
            <div class="donut-wrap">
                <canvas id="attDonut"></canvas>
                <div class="donut-center">
                    <div class="dc-val" id="donutPct">—</div>
                    <div class="dc-lbl">Present</div>
                </div>
            </div>
        </div>
    </div>

    <%-- Attendance calendar heatmap --%>
    <div class="sd-card">
        <div class="sec-hd">
            <div class="sec-title"><span class="ico" style="background:var(--green-lt);color:var(--green)"><i class="fa fa-calendar"></i></span> Attendance Calendar</div>
        </div>
        <div class="cal-grid" id="calGrid"></div>
        <div class="cal-legend">
            <div class="cal-legend-item"><div class="cal-legend-dot" style="background:#059669"></div>Present</div>
            <div class="cal-legend-item"><div class="cal-legend-dot" style="background:#dc2626"></div>Absent</div>
            <div class="cal-legend-item"><div class="cal-legend-dot" style="background:#d97706"></div>Leave</div>
            <div class="cal-legend-item"><div class="cal-legend-dot" style="background:var(--surf-3)"></div>No Record</div>
        </div>
    </div>

    <%-- Per-subject attendance --%>
    <div class="sd-card">
        <div class="sec-hd">
            <div class="sec-title"><span class="ico" style="background:var(--blue-lt);color:var(--blue)"><i class="fa fa-book"></i></span> Subject-wise Attendance</div>
        </div>
        <div class="sd-table-wrap">
            <table class="sd-table">
                <thead>
                    <tr>
                        <th>Subject</th>
                        <th>Code</th>
                        <th>Total</th>
                        <th>Present</th>
                        <th>Absent</th>
                        <th>Leave</th>
                        <th>Progress</th>
                        <th>%</th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptAttSubject" runat="server">
                        <ItemTemplate>
                            <tr>
                                <td style="font-weight:600"><%# Eval("SubjectName") %></td>
                                <td style="font-family:var(--f-mono);color:var(--ink-4);font-size:11px"><%# Eval("SubjectCode") %></td>
                                <td><%# Eval("TotalClasses") %></td>
                                <td style="color:var(--green);font-weight:600"><%# Eval("Present") %></td>
                                <td style="color:var(--red);font-weight:600"><%# Eval("Absent") %></td>
                                <td style="color:var(--amber);font-weight:600"><%# Eval("Leave") %></td>
                                <td style="min-width:100px">
                                    <div class="progress-wrap">
                                        <div class="progress-fill"
                                             style="width:<%# BarWidth(Eval("Percentage")) %>%;background:<%# GetAttColor(Eval("Percentage")) %>">
                                        </div>
                                    </div>
                                </td>
                                <td>
                                    <span class="tag" style="background:<%# GetAttColor(Eval("Percentage")) %>22;color:<%# GetAttColor(Eval("Percentage")) %>">
                                        <%# string.Format("{0:F1}%", Eval("Percentage")) %>
                                    </span>
                                </td>
                            </tr>
                        </ItemTemplate>
                        <FooterTemplate>
                            <asp:Panel runat="server" Visible='<%# rptAttSubject.Items.Count==0 %>'>
                                <tr><td colspan="8"><div class="empty-state"><i class="fa fa-calendar-times"></i><p>No attendance records for this session.</p></div></td></tr>
                            </asp:Panel>
                        </FooterTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
        </div>
    </div>
</div>

<%-- ══════════════════════════════════════════════════════════════════
     TAB 3: SUBJECTS & VIDEO PROGRESS
══════════════════════════════════════════════════════════════════ --%>
<div id="tab-subjects" class="sd-panel">

    <div class="subj-grid">
        <asp:Repeater ID="rptSubjects" runat="server">
            <ItemTemplate>
                <div class="subj-card">
                    <div class="sc-accent" style="background:var(--blue)"></div>
                    <div class="sc-name"><%# Eval("SubjectName") %></div>
                    <div class="sc-code"><%# Eval("SubjectCode") %> &bull; <%# Eval("Duration") %></div>

                    <div class="subj-metrics">
                        <div class="subj-metric">
                            <div class="sm-val"><%# Eval("VideosCompleted") %>/<%# Eval("TotalVideos") %></div>
                            <div class="sm-lbl">Videos</div>
                        </div>
                        <div class="subj-metric">
                            <div class="sm-val"><%# Eval("AssignmentsSubmitted") %>/<%# Eval("TotalAssignments") %></div>
                            <div class="sm-lbl">Tasks</div>
                        </div>
                        <div class="subj-metric">
                            <div class="sm-val"><%# Eval("QuizzesAttempted") %>/<%# Eval("TotalQuizzes") %></div>
                            <div class="sm-lbl">Quizzes</div>
                        </div>
                    </div>

                    <%-- Attendance bar --%>
                    <div style="margin-bottom:8px">
                        <div style="display:flex;justify-content:space-between;margin-bottom:4px">
                            <span style="font-size:11px;color:var(--ink-4);font-weight:600">Attendance</span>
                            <span style="font-size:11px;font-weight:700;color:<%# GetAttColor(Eval("AttendancePercent")) %>">
                                <%# string.Format("{0:F1}%", Eval("AttendancePercent")) %>
                            </span>
                        </div>
                        <div class="progress-wrap">
                            <div class="progress-fill"
                                 style="width:<%# BarWidth(Eval("AttendancePercent")) %>%;background:<%# GetAttColor(Eval("AttendancePercent")) %>">
                            </div>
                        </div>
                    </div>

                    <%-- Video progress bar --%>
                    <div style="margin-bottom:4px">
                        <div style="display:flex;justify-content:space-between;margin-bottom:4px">
                            <span style="font-size:11px;color:var(--ink-4);font-weight:600">Video Progress</span>
                        </div>
                        <div class="progress-wrap">
                            <div class="progress-fill"
                                 style="width:<%# Eval("TotalVideos").ToString()=="0" ? "0" : BarWidth(decimal.Parse(Eval("VideosCompleted").ToString()) * 100m / decimal.Parse(Eval("TotalVideos").ToString() == "0" ? "1" : Eval("TotalVideos").ToString())) %>%;background:var(--cyan)">
                            </div>
                        </div>
                    </div>

                    <div class="sc-teacher">
                        <i class="fa fa-chalkboard-teacher"></i>
                        <%# Eval("TeacherName") %>
                        <span style="margin-left:auto;font-size:11px;color:var(--purple)">
                            <i class="fa fa-robot me-1"></i><%# Eval("AIInteractions") %> AI uses
                        </span>
                    </div>
                </div>
            </ItemTemplate>
            <FooterTemplate>
                <asp:Panel runat="server" Visible='<%# rptSubjects.Items.Count==0 %>'>
                    <div class="sd-card"><div class="empty-state"><i class="fa fa-book-open"></i><p>No subjects assigned for this session.</p></div></div>
                </asp:Panel>
            </FooterTemplate>
        </asp:Repeater>
    </div>

    <%-- Video Progress Detail --%>
    <div class="sd-card" style="margin-top:6px">
        <div class="sec-hd">
            <div class="sec-title"><span class="ico" style="background:var(--cyan-lt);color:var(--cyan)"><i class="fa fa-play-circle"></i></span> Video Watch Progress</div>
        </div>
        <div id="vidAccordion">
            <asp:Repeater ID="rptVideoProgress" runat="server">
                <ItemTemplate>
                    <div class="vid-row">
                        <div class="vid-thumb">
                            <%# Convert.ToBoolean(Eval("IsCompleted")) ? "✅" : "▶" %>
                        </div>
                        <div class="vid-info">
                            <div class="vid-title"><%# Eval("VideoTitle") %></div>
                            <div class="vid-chapter">
                                <i class="fa fa-bookmark me-1"></i><%# Eval("ChapterName") %>
                                &bull; <%# Eval("SubjectName") %>
                                <span style="margin-left:8px;color:var(--purple)">
                                    <i class="fa fa-sticky-note me-1"></i><%# Eval("NotesCount") %> notes
                                    &nbsp;<i class="fa fa-question-circle me-1"></i><%# Eval("DoubtsCount") %> doubts
                                </span>
                            </div>
                        </div>
                        <div class="vid-prog">
                            <div class="vid-pct"><%# Eval("WatchedPercent") %>%</div>
                            <div class="progress-wrap">
                                <div class="progress-fill"
                                     style="width:<%# BarWidth(Eval("WatchedPercent")) %>%;background:<%# Convert.ToInt32(Eval("WatchedPercent"))>=80?"var(--green)":"var(--blue)" %>">
                                </div>
                            </div>
                        </div>
                        <div style="width:50px;text-align:center;font-size:13px">
                            <%# Eval("Rating").ToString()!="0" ? "⭐"+Eval("Rating") : "" %>
                        </div>
                    </div>
                </ItemTemplate>
                <FooterTemplate>
                    <asp:Panel runat="server" Visible='<%# rptVideoProgress.Items.Count==0 %>'>
                        <div class="empty-state"><i class="fa fa-video-slash"></i><p>No video activity recorded yet.</p></div>
                    </asp:Panel>
                </FooterTemplate>
            </asp:Repeater>
        </div>
    </div>
</div>

<%-- ══════════════════════════════════════════════════════════════════
     TAB 4: ASSIGNMENTS
══════════════════════════════════════════════════════════════════ --%>
<div id="tab-assignments" class="sd-panel">

    <div class="chart-row" style="margin-bottom:18px">
        <div class="sd-card">
            <div class="sec-title" style="margin-bottom:14px"><span class="ico" style="background:var(--blue-lt);color:var(--blue)"><i class="fa fa-tasks"></i></span> Summary</div>
            <div class="stat-strip">
                <div class="stat-chip"><div class="s-val"><asp:Label ID="lblAsgTotal"   runat="server">0</asp:Label></div><div class="s-lbl">Total</div></div>
                <div class="stat-chip"><div class="s-val" style="color:var(--green)"><asp:Label ID="lblAsgGraded"  runat="server">0</asp:Label></div><div class="s-lbl">Graded</div></div>
                <div class="stat-chip"><div class="s-val" style="color:var(--blue)"><asp:Label ID="lblAsgSubmit"  runat="server">0</asp:Label></div><div class="s-lbl">Submitted</div></div>
                <div class="stat-chip"><div class="s-val" style="color:var(--amber)"><asp:Label ID="lblAsgPending" runat="server">0</asp:Label></div><div class="s-lbl">Pending</div></div>
                <div class="stat-chip"><div class="s-val" style="color:var(--red)"><asp:Label ID="lblAsgMissed"  runat="server">0</asp:Label></div><div class="s-lbl">Missed</div></div>
            </div>
        </div>
        <div class="chart-box">
            <div class="chart-title"><i class="fa fa-chart-pie" style="color:var(--blue)"></i> Assignment Status Breakdown</div>
            <canvas id="asgChart"></canvas>
        </div>
    </div>

    <div class="sd-card">
        <div class="sd-table-wrap">
            <table class="sd-table">
                <thead>
                    <tr>
                        <th>Assignment</th>
                        <th>Subject</th>
                        <th>Due Date</th>
                        <th>Max Marks</th>
                        <th>Score</th>
                        <th>Class Avg</th>
                        <th>%</th>
                        <th>Status</th>
                        <th>Feedback</th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptAssignments" runat="server">
                        <ItemTemplate>
                            <tr>
                                <td style="font-weight:600;max-width:180px">
                                    <div style="white-space:nowrap;overflow:hidden;text-overflow:ellipsis;max-width:170px" title="<%# Eval("Title") %>"><%# Eval("Title") %></div>
                                    <div style="font-size:10px;color:var(--ink-5)"><%# Eval("Description") %></div>
                                </td>
                                <td><span class="tag tag-submitted"><%# Eval("SubjectCode") %></span></td>
                                <td style="white-space:nowrap;font-size:12px"><%# Eval("DueDate") != DBNull.Value ? Convert.ToDateTime(Eval("DueDate")).ToString("dd MMM yyyy") : "—" %></td>
                                <td style="font-family:var(--f-mono)"><%# Eval("MaxMarks") %></td>
                                <td style="font-family:var(--f-mono);font-weight:700;color:var(--blue)">
                                    <%# Eval("MarksObtained") != DBNull.Value ? Eval("MarksObtained").ToString() : "—" %>
                                </td>
                                <td style="font-family:var(--f-mono);color:var(--ink-4)"><%# string.Format("{0:F1}", Eval("ClassAvgMarks")) %></td>
                                <td>
                                    <div style="display:flex;align-items:center;gap:6px">
                                        <div class="progress-wrap" style="width:50px">
                                            <div class="progress-fill" style="width:<%# BarWidth(Eval("ScorePercent")) %>%;background:var(--blue)"></div>
                                        </div>
                                        <span style="font-size:11px;font-weight:600"><%# string.Format("{0:F0}%", Eval("ScorePercent")) %></span>
                                    </div>
                                </td>
                                <td><span class="tag <%# GetStatusClass(Eval("SubmissionStatus")) %>"><%# Eval("SubmissionStatus") %></span></td>
                                <td style="font-size:11px;color:var(--ink-4);max-width:120px">
                                    <div style="white-space:nowrap;overflow:hidden;text-overflow:ellipsis;max-width:110px" title="<%# Eval("Feedback") %>"><%# Eval("Feedback") %></div>
                                </td>
                            </tr>
                        </ItemTemplate>
                        <FooterTemplate>
                            <asp:Panel runat="server" Visible='<%# rptAssignments.Items.Count==0 %>'>
                                <tr><td colspan="9"><div class="empty-state"><i class="fa fa-file"></i><p>No assignments found.</p></div></td></tr>
                            </asp:Panel>
                        </FooterTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
        </div>
    </div>
</div>

<%-- ══════════════════════════════════════════════════════════════════
     TAB 5: QUIZZES
══════════════════════════════════════════════════════════════════ --%>
<div id="tab-quizzes" class="sd-panel">

    <div class="chart-row" style="margin-bottom:18px">
        <div class="sd-card">
            <div class="sec-title" style="margin-bottom:14px"><span class="ico" style="background:var(--purple-lt);color:var(--purple)"><i class="fa fa-brain"></i></span> Quiz Summary</div>
            <div class="stat-strip">
                <div class="stat-chip"><div class="s-val"><asp:Label ID="lblQzTotal"  runat="server">0</asp:Label></div><div class="s-lbl">Total</div></div>
                <div class="stat-chip"><div class="s-val" style="color:var(--green)"><asp:Label ID="lblQzPassed" runat="server">0</asp:Label></div><div class="s-lbl">Passed</div></div>
                <div class="stat-chip"><div class="s-val" style="color:var(--red)"><asp:Label ID="lblQzFailed" runat="server">0</asp:Label></div><div class="s-lbl">Failed</div></div>
                <div class="stat-chip"><div class="s-val" style="color:var(--ink-4)"><asp:Label ID="lblQzNA"    runat="server">0</asp:Label></div><div class="s-lbl">Not Attempted</div></div>
                <div class="stat-chip" style="background:var(--purple-lt)"><div class="s-val" style="color:var(--purple)"><asp:Label ID="lblQzAvg"   runat="server">—</asp:Label></div><div class="s-lbl">Avg Score</div></div>
            </div>
        </div>
        <div class="chart-box">
            <div class="chart-title"><i class="fa fa-chart-pie" style="color:var(--purple)"></i> Quiz Results Breakdown</div>
            <canvas id="qzChart"></canvas>
        </div>
    </div>

    <div class="sd-card">
        <div class="sd-table-wrap">
            <table class="sd-table">
                <thead>
                    <tr>
                        <th>Quiz</th>
                        <th>Subject</th>
                        <th>Due</th>
                        <th>Total Marks</th>
                        <th>Score</th>
                        <th>Correct</th>
                        <th>Class Avg</th>
                        <th>Time Taken</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptQuizzes" runat="server">
                        <ItemTemplate>
                            <tr>
                                <td style="font-weight:600"><%# Eval("QuizTitle") %></td>
                                <td><span class="tag tag-submitted"><%# Eval("SubjectCode") %></span></td>
                                <td style="font-size:12px;white-space:nowrap"><%# Eval("DueDate") != DBNull.Value ? Convert.ToDateTime(Eval("DueDate")).ToString("dd MMM yyyy") : "—" %></td>
                                <td style="font-family:var(--f-mono)"><%# Eval("TotalMarks") %></td>
                                <td>
                                    <div style="display:flex;align-items:center;gap:5px">
                                        <span style="font-family:var(--f-mono);font-weight:700;color:var(--purple)"><%# Eval("Score") %></span>
                                        <div class="progress-wrap" style="width:40px"><div class="progress-fill" style="width:<%# BarWidth(Eval("ScorePercent")) %>%;background:var(--purple)"></div></div>
                                        <span style="font-size:10px;color:var(--ink-4)"><%# string.Format("{0:F0}%", Eval("ScorePercent")) %></span>
                                    </div>
                                </td>
                                <td style="font-family:var(--f-mono)"><%# Eval("CorrectAnswers") %>/<%# Eval("TotalQuestions") %></td>
                                <td style="font-family:var(--f-mono);color:var(--ink-4)"><%# string.Format("{0:F1}", Eval("ClassAvgScore")) %></td>
                                <td style="font-size:12px;color:var(--ink-4)"><%# Eval("TimeTaken") != DBNull.Value ? Eval("TimeTaken") + " min" : "—" %></td>
                                <td><span class="tag <%# GetQuizClass(Eval("QuizStatus")) %>"><%# Eval("QuizStatus") %></span></td>
                            </tr>
                        </ItemTemplate>
                        <FooterTemplate>
                            <asp:Panel runat="server" Visible='<%# rptQuizzes.Items.Count==0 %>'>
                                <tr><td colspan="9"><div class="empty-state"><i class="fa fa-question-circle"></i><p>No quizzes found.</p></div></td></tr>
                            </asp:Panel>
                        </FooterTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
        </div>
    </div>
</div>

<%-- ══════════════════════════════════════════════════════════════════
     TAB 6: AI USAGE
══════════════════════════════════════════════════════════════════ --%>
<div id="tab-ai" class="sd-panel">
    <div class="chart-row">
        <div class="chart-box">
            <div class="chart-title"><i class="fa fa-chart-bar" style="color:var(--amber)"></i> AI Usage by Type</div>
            <canvas id="aiChart"></canvas>
        </div>
        <div class="sd-card" style="margin-bottom:0">
            <div class="sec-title" style="margin-bottom:14px"><span class="ico" style="background:var(--amber-lt);color:var(--amber)"><i class="fa fa-robot"></i></span> Type Breakdown</div>
            <asp:Repeater ID="rptAISummary" runat="server">
                <ItemTemplate>
                    <div style="display:flex;align-items:center;gap:10px;margin-bottom:10px">
                        <div style="width:34px;height:34px;border-radius:9px;display:flex;align-items:center;justify-content:center;font-size:13px;color:#fff;background:<%# GetAITypeColor(Eval("Type")) %>">
                            <i class="fa fa-sparkles"></i>
                        </div>
                        <div style="flex:1">
                            <div style="font-weight:600;font-size:13px;color:var(--ink)"><%# Eval("Type") %></div>
                            <div style="font-size:11px;color:var(--ink-5)">Last: <%# FormatDate(Eval("LastUsed")) %></div>
                        </div>
                        <div style="font-family:var(--f-display);font-size:1.4rem;font-weight:800;color:<%# GetAITypeColor(Eval("Type")) %>">
                            <%# Eval("UsageCount") %>
                        </div>
                    </div>
                </ItemTemplate>
                <FooterTemplate>
                    <asp:Panel runat="server" Visible='<%# rptAISummary.Items.Count==0 %>'>
                        <div class="empty-state"><i class="fa fa-robot"></i><p>No AI usage recorded.</p></div>
                    </asp:Panel>
                </FooterTemplate>
            </asp:Repeater>
        </div>
    </div>

    <div class="sd-card">
        <div class="sec-title" style="margin-bottom:14px"><span class="ico" style="background:var(--amber-lt);color:var(--amber)"><i class="fa fa-history"></i></span> Recent AI Interactions</div>
        <asp:Repeater ID="rptAIHistory" runat="server">
            <ItemTemplate>
                <div style="border:1px solid var(--surf-4);border-radius:var(--radius-sm);padding:12px 14px;margin-bottom:8px">
                    <div style="display:flex;align-items:center;gap:8px;margin-bottom:6px">
                        <span class="tag" style="background:<%# GetAITypeColor(Eval("Type")) %>20;color:<%# GetAITypeColor(Eval("Type")) %>"><%# Eval("Type") %></span>
                        <span style="font-size:11px;color:var(--ink-5)"><%# Eval("SubjectName") %> &bull; <%# Eval("VideoTitle") %></span>
                        <span style="margin-left:auto;font-size:11px;color:var(--ink-5)"><%# FormatDateTime(Eval("CreatedOn")) %></span>
                    </div>
                    <div style="font-size:13px;font-weight:600;color:var(--ink-2);margin-bottom:4px">Q: <%# Eval("Question") %></div>
                    <div style="font-size:12px;color:var(--ink-4)">A: <%# Eval("Response") %></div>
                </div>
            </ItemTemplate>
            <FooterTemplate>
                <asp:Panel runat="server" Visible='<%# rptAIHistory.Items.Count==0 %>'>
                    <div class="empty-state"><i class="fa fa-comment-slash"></i><p>No AI history available.</p></div>
                </asp:Panel>
            </FooterTemplate>
        </asp:Repeater>
    </div>
</div>

<%-- ══════════════════════════════════════════════════════════════════
     TAB 7: ACTIVITY / NOTIFICATIONS / HELP
══════════════════════════════════════════════════════════════════ --%>
<div id="tab-activity" class="sd-panel">
    <div style="display:grid;grid-template-columns:1fr 1fr;gap:18px">

        <%-- Activity log --%>
        <div class="sd-card">
            <div class="sec-title" style="margin-bottom:14px"><span class="ico" style="background:var(--blue-lt);color:var(--blue)"><i class="fa fa-stream"></i></span> Activity Log</div>
            <div class="timeline">
                <asp:Repeater ID="rptActivity" runat="server">
                    <ItemTemplate>
                        <div class="tl-item">
                            <div class="tl-dot" style="background:var(--blue)">
                                <i class="fa <%# GetActivityIcon(Eval("ActivityType")) %>"></i>
                            </div>
                            <div class="tl-content">
                                <div class="tl-title"><%# Eval("ActivityType") %></div>
                                <div class="tl-time"><i class="fa fa-clock me-1"></i><%# FormatDateTime(Eval("ActionTime")) %></div>
                            </div>
                        </div>
                    </ItemTemplate>
                    <FooterTemplate>
                        <asp:Panel runat="server" Visible='<%# rptActivity.Items.Count==0 %>'>
                            <div class="empty-state"><i class="fa fa-history"></i><p>No activity recorded.</p></div>
                        </asp:Panel>
                    </FooterTemplate>
                </asp:Repeater>
            </div>
        </div>

        <%-- Notifications --%>
        <div class="sd-card">
            <div class="sec-title" style="margin-bottom:14px"><span class="ico" style="background:var(--amber-lt);color:var(--amber)"><i class="fa fa-bell"></i></span> Notifications</div>
            <div class="timeline">
                <asp:Repeater ID="rptNotifications" runat="server">
                    <ItemTemplate>
                        <div class="tl-item">
                            <div class="tl-dot" style="background:<%# Convert.ToBoolean(Eval("IsRead")) ? "var(--ink-4)" : "var(--amber)" %>">
                                <i class="fa fa-bell"></i>
                            </div>
                            <div class="tl-content">
                                <div class="tl-title" style="<%# !Convert.ToBoolean(Eval("IsRead")) ? "color:var(--amber)" : "" %>">
                                    <%# Eval("Message") %>
                                    <%# !Convert.ToBoolean(Eval("IsRead")) ? "<span class='tag tag-pending' style='margin-left:4px;font-size:9px'>Unread</span>" : "" %>
                                </div>
                                <div class="tl-time">
                                    <i class="fa fa-tag me-1"></i><%# Eval("NotificationType") %>
                                    &bull; <%# FormatDateTime(Eval("CreatedOn")) %>
                                </div>
                            </div>
                        </div>
                    </ItemTemplate>
                    <FooterTemplate>
                        <asp:Panel runat="server" Visible='<%# rptNotifications.Items.Count==0 %>'>
                            <div class="empty-state"><i class="fa fa-bell-slash"></i><p>No notifications.</p></div>
                        </asp:Panel>
                    </FooterTemplate>
                </asp:Repeater>
            </div>
        </div>
    </div>

    <%-- Help Requests --%>
    <div class="sd-card" style="margin-top:18px">
        <div class="sec-title" style="margin-bottom:14px"><span class="ico" style="background:var(--green-lt);color:var(--green)"><i class="fa fa-question-circle"></i></span> Help Requests & Replies</div>
        <asp:Repeater ID="rptHelp" runat="server">
            <ItemTemplate>
                <div class="help-card">
                    <div class="help-q"><i class="fa fa-question-circle me-1" style="color:var(--blue)"></i><%# Eval("Question") %></div>
                    <div class="help-time"><i class="fa fa-clock me-1"></i>Asked on <%# FormatDateTime(Eval("AskedOn")) %></div>
                    <%# Convert.ToBoolean(Eval("HasReply"))
                        ? "<div class='help-reply'><div class='hr-from'><i class='fa fa-user-shield me-1'></i>" + Eval("RepliedBy") + " replied on " + FormatDateTime(Eval("RepliedOn")) + "</div><div class='hr-text'>" + Eval("Reply") + "</div></div>"
                        : "<div class='help-pending'><i class='fa fa-hourglass-half me-1'></i>Awaiting admin reply...</div>" %>
                </div>
            </ItemTemplate>
            <FooterTemplate>
                <asp:Panel runat="server" Visible='<%# rptHelp.Items.Count==0 %>'>
                    <div class="empty-state"><i class="fa fa-comment-slash"></i><p>No help requests raised.</p></div>
                </asp:Panel>
            </FooterTemplate>
        </asp:Repeater>
    </div>
</div>

<%-- ══════════════════════════════════════════════════════════════════
     TAB 8: PARENTS
══════════════════════════════════════════════════════════════════ --%>
<div id="tab-parents" class="sd-panel">
    <div class="sd-card">
        <div class="sec-title" style="margin-bottom:16px">
            <span class="ico" style="background:var(--purple-lt);color:var(--purple)"><i class="fa fa-users"></i></span>
            Linked Parents / Guardians
        </div>
        <div class="parent-strip">
            <asp:Repeater ID="rptParents" runat="server">
                <ItemTemplate>
                    <div class="parent-card">
                        <div class="parent-av"><%# Eval("ParentName").ToString().Substring(0,1).ToUpper() %></div>
                        <div class="parent-info">
                            <div class="pi-name"><%# Eval("ParentName") %>
                                <%# Convert.ToBoolean(Eval("IsPrimaryGuardian")) ? "<span class='tag tag-graded' style='margin-left:4px;font-size:9px'>Primary</span>" : "" %>
                            </div>
                            <div class="pi-rel"><i class="fa fa-heart me-1" style="color:var(--pink)"></i><%# Eval("RelationshipType") %></div>
                            <div class="pi-cont"><i class="fa fa-phone me-1"></i><%# Eval("ParentContact") %></div>
                            <div class="pi-cont"><i class="fa fa-envelope me-1"></i><%# Eval("ParentEmail") %></div>
                        </div>
                    </div>
                </ItemTemplate>
                <FooterTemplate>
                    <asp:Panel runat="server" Visible='<%# rptParents.Items.Count==0 %>'>
                        <div class="empty-state" style="width:100%">
                            <i class="fa fa-user-friends"></i>
                            <p>No parents linked for this session.</p>
                            <a href="ParentManagement.aspx" style="color:var(--blue);font-weight:600;font-size:13px">
                                <i class="fa fa-plus me-1"></i> Link a Parent
                            </a>
                        </div>
                    </asp:Panel>
                </FooterTemplate>
            </asp:Repeater>
        </div>
    </div>
</div>

</div><%-- /sd-root --%>

<%-- ══ CHART.JS ═════════════════════════════════════════════════════ --%>
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>

<script>
/* ═══════════════════════════════════════════════════════════════
   HELPERS
═══════════════════════════════════════════════════════════════ */
function hf(id){
    var el=document.getElementById(id);
    return el ? el.value : '';
}
function parseHF(id){
    try{ return JSON.parse(hf(id)||'[]'); }catch(e){ return []; }
}

/* ═══════════════════════════════════════════════════════════════
   TAB SWITCHING
═══════════════════════════════════════════════════════════════ */
var chartsInit = {};
function switchTab(name, btn){
    document.querySelectorAll('.sd-panel').forEach(function(p){ p.classList.remove('active'); });
    document.querySelectorAll('.sd-tab-btn').forEach(function(b){ b.classList.remove('active'); });
    var panel = document.getElementById('tab-'+name);
    if(panel) panel.classList.add('active');
    if(btn) btn.classList.add('active');
    // lazy-init charts
    if(!chartsInit[name]){
        chartsInit[name]=true;
        initChartsFor(name);
    }
}

/* ═══════════════════════════════════════════════════════════════
   CHART INIT PER TAB
═══════════════════════════════════════════════════════════════ */
function initChartsFor(tab){
    if(tab==='profile')    initRadar();
    if(tab==='attendance') { initAttMonth(); initAttDonut(); buildCalendar(); }
    if(tab==='assignments'){ initAsgChart(); }
    if(tab==='quizzes')    { initQzChart(); }
    if(tab==='ai')         { initAIChart(); }
}

/* ── Chart defaults ───────────────────────────────────────── */
Chart.defaults.font.family = "'DM Sans', system-ui, sans-serif";
Chart.defaults.color       = '#64748b';

/* ── Animated number count-up ─────────────────────────────── */
document.addEventListener('DOMContentLoaded', function(){
    // KPI count-up
    document.querySelectorAll('.kpi-count').forEach(function(el){
        var target = parseFloat(el.dataset.target || 0);
        var duration = 1200;
        var start = performance.now();
        function step(now){
            var p = Math.min((now-start)/duration,1);
            var eased = 1-Math.pow(1-p,3);
            el.textContent = (target * eased).toFixed(1) + '%';
            if(p<1) requestAnimationFrame(step);
        }
        requestAnimationFrame(step);
    });
    // init profile tab charts right away
    initChartsFor('profile');
});

/* ═══════════════════════════════════════════════════════════════
   RADAR CHART (Performance overview)
═══════════════════════════════════════════════════════════════ */
function initRadar(){
    var ctx = document.getElementById('radarChart');
    if(!ctx) return;
    var att  = parseFloat(hf('<%= hfAttScore.ClientID %>'))  || 0;
    var ass  = parseFloat(hf('<%= hfAssScore.ClientID %>'))  || 0;
    var quiz = parseFloat(hf('<%= hfQuizScore.ClientID %>')) || 0;
    var vid  = parseFloat(hf('<%= hfVideoScore.ClientID %>'))|| 0;
    new Chart(ctx,{
        type:'radar',
        data:{
            labels:['Attendance','Assignments','Quiz Score','Video Progress'],
            datasets:[{
                label:'Student',
                data:[att,ass,quiz,vid],
                backgroundColor:'rgba(79,70,229,.15)',
                borderColor:'#4f46e5',
                borderWidth:2.5,
                pointBackgroundColor:'#4f46e5',
                pointRadius:5,
                pointHoverRadius:7
            }]
        },
        options:{
            responsive:true,
            animation:{ duration:1200, easing:'easeOutQuart' },
            scales:{
                r:{
                    min:0, max:100,
                    ticks:{ stepSize:25, backdropColor:'transparent', font:{size:10} },
                    grid:{ color:'rgba(0,0,0,.06)' },
                    angleLines:{ color:'rgba(0,0,0,.06)' },
                    pointLabels:{ font:{size:11,weight:'600'} }
                }
            },
            plugins:{ legend:{display:false}, tooltip:{
                callbacks:{ label:function(c){ return c.raw.toFixed(1)+'%'; } }
            }}
        }
    });
}

/* ═══════════════════════════════════════════════════════════════
   ATTENDANCE MONTHLY BAR CHART
═══════════════════════════════════════════════════════════════ */
function initAttMonth(){
    var ctx = document.getElementById('attMonthChart');
    if(!ctx) return;
    var labels  = parseHF('<%= hfAttMonthLabels.ClientID %>');
    var present = parseHF('<%= hfAttMonthPresent.ClientID %>');
    var pct     = parseHF('<%= hfAttMonthPct.ClientID %>');
    if(!labels.length){ ctx.parentElement.innerHTML='<div class="empty-state"><i class="fa fa-chart-bar"></i><p>No attendance data.</p></div>'; return; }
    new Chart(ctx,{
        type:'bar',
        data:{
            labels: labels,
            datasets:[
                {
                    label:'Present Days',
                    data: present,
                    backgroundColor:'rgba(5,150,105,.75)',
                    borderRadius:6,
                    borderSkipped:false,
                    yAxisID:'y'
                },
                {
                    label:'% Rate',
                    data: pct,
                    type:'line',
                    borderColor:'#4f46e5',
                    backgroundColor:'rgba(79,70,229,.1)',
                    borderWidth:2.5,
                    pointRadius:4,
                    pointHoverRadius:6,
                    tension:.4,
                    fill:true,
                    yAxisID:'y1'
                }
            ]
        },
        options:{
            responsive:true,
            animation:{ duration:1000, easing:'easeOutQuart' },
            interaction:{ mode:'index', intersect:false },
            scales:{
                y:{ position:'left', grid:{ color:'rgba(0,0,0,.04)' }, ticks:{font:{size:10}}, title:{display:true,text:'Days',font:{size:10}} },
                y1:{ position:'right', min:0, max:100, grid:{drawOnChartArea:false}, ticks:{callback:function(v){return v+'%';},font:{size:10}}, title:{display:true,text:'%',font:{size:10}} }
            },
            plugins:{
                legend:{ position:'top', labels:{font:{size:11}} },
                tooltip:{ callbacks:{ label:function(c){
                    return c.datasetIndex===1 ? c.raw.toFixed(1)+'%' : c.raw+' days';
                }}}
            }
        }
    });
}

/* ═══════════════════════════════════════════════════════════════
   ATTENDANCE DONUT
═══════════════════════════════════════════════════════════════ */
function initAttDonut(){
    var ctx = document.getElementById('attDonut');
    if(!ctx) return;
    var pct   = parseFloat(hf('<%= hfAttPct.ClientID %>')) || 0;
    var total = 100;
    var absent = Math.max(0, (100-pct)*(2/3));
    var leave  = Math.max(0, (100-pct)*(1/3));
    document.getElementById('donutPct').textContent = pct.toFixed(1)+'%';
    new Chart(ctx,{
        type:'doughnut',
        data:{
            labels:['Present','Absent','Leave'],
            datasets:[{
                data:[pct, absent, leave],
                backgroundColor:['#059669','#dc2626','#d97706'],
                borderWidth:2, borderColor:'#fff',
                hoverOffset:8
            }]
        },
        options:{
            cutout:'72%',
            animation:{ animateRotate:true, duration:1200, easing:'easeOutQuart' },
            plugins:{ legend:{display:false} }
        }
    });
}

/* ═══════════════════════════════════════════════════════════════
   ATTENDANCE CALENDAR HEATMAP
═══════════════════════════════════════════════════════════════ */
function buildCalendar(){
    var grid = document.getElementById('calGrid');
    if(!grid) return;
    var data = parseHF('<%= hfCalData.ClientID %>');
    if(!data.length){
        grid.innerHTML='<div class="empty-state" style="width:100%"><i class="fa fa-calendar-times"></i><p>No attendance calendar data.</p></div>';
        return;
    }
    var map={};
    data.forEach(function(d){ map[d.date]=d.status; });
    // Show last 90 days
    var days=[];
    for(var i=89;i>=0;i--){
        var d=new Date(); d.setDate(d.getDate()-i);
        var key=d.toISOString().split('T')[0];
        days.push({date:key, status:map[key]||'none'});
    }
    grid.innerHTML='';
    days.forEach(function(d){
        var el=document.createElement('div');
        el.className='cal-day';
        el.dataset.status=d.status;
        el.innerHTML='<div class="cal-tip">'+d.date+': '+d.status+'</div>';
        grid.appendChild(el);
    });
}

/* ═══════════════════════════════════════════════════════════════
   ASSIGNMENT DONUT
═══════════════════════════════════════════════════════════════ */
function initAsgChart(){
    var ctx = document.getElementById('asgChart');
    if(!ctx) return;
    var raw = hf('<%= hfAsgChartData.ClientID %>');
    var vals = [];
    try{ vals=JSON.parse(raw); }catch(e){}
    if(!vals.length||vals.every(function(v){return v===0;})){
        ctx.parentElement.innerHTML='<div class="empty-state"><i class="fa fa-tasks"></i><p>No assignment data.</p></div>';
        return;
    }
    new Chart(ctx,{
        type:'doughnut',
        data:{
            labels:['Graded','Submitted','Pending','Missed'],
            datasets:[{ data:vals,
                backgroundColor:['#059669','#2563eb','#d97706','#dc2626'],
                borderWidth:2, borderColor:'#fff', hoverOffset:8 }]
        },
        options:{
            cutout:'65%',
            animation:{ duration:1000, easing:'easeOutQuart' },
            plugins:{ legend:{ position:'bottom', labels:{ font:{size:11}, padding:12 } } }
        }
    });
}

/* ═══════════════════════════════════════════════════════════════
   QUIZ DONUT
═══════════════════════════════════════════════════════════════ */
function initQzChart(){
    var ctx = document.getElementById('qzChart');
    if(!ctx) return;
    var raw=hf('<%= hfQzChartData.ClientID %>');
    var vals=[];
    try{ vals=JSON.parse(raw); }catch(e){}
    if(!vals.length||vals.every(function(v){return v===0;})){
        ctx.parentElement.innerHTML='<div class="empty-state"><i class="fa fa-brain"></i><p>No quiz data.</p></div>';
        return;
    }
    new Chart(ctx,{
        type:'doughnut',
        data:{
            labels:['Passed','Failed','Not Attempted'],
            datasets:[{ data:vals,
                backgroundColor:['#059669','#dc2626','#94a3b8'],
                borderWidth:2, borderColor:'#fff', hoverOffset:8 }]
        },
        options:{
            cutout:'65%',
            animation:{ duration:1000, easing:'easeOutQuart' },
            plugins:{ legend:{ position:'bottom', labels:{ font:{size:11}, padding:12 } } }
        }
    });
}

/* ═══════════════════════════════════════════════════════════════
   AI USAGE BAR CHART
═══════════════════════════════════════════════════════════════ */
function initAIChart(){
    var ctx = document.getElementById('aiChart');
    if(!ctx) return;
    var labels = parseHF('<%= hfAILabels.ClientID %>');
    var counts = parseHF('<%= hfAICounts.ClientID %>');
    if(!labels.length){
        ctx.parentElement.innerHTML='<div class="empty-state"><i class="fa fa-robot"></i><p>No AI usage data.</p></div>';
        return;
    }
    new Chart(ctx,{
        type:'bar',
        data:{
            labels: labels,
            datasets:[{
                label:'Interactions',
                data: counts,
                backgroundColor:['rgba(79,70,229,.75)','rgba(5,150,105,.75)','rgba(217,119,6,.75)','rgba(2,132,199,.75)'],
                borderRadius:8, borderSkipped:false
            }]
        },
        options:{
            responsive:true,
            animation:{ duration:900, easing:'easeOutQuart' },
            scales:{
                y:{ beginAtZero:true, grid:{color:'rgba(0,0,0,.04)'}, ticks:{font:{size:10}} },
                x:{ grid:{display:false}, ticks:{font:{size:11,weight:'600'}} }
            },
            plugins:{ legend:{display:false} }
        }
    });
}

/* ═══════════════════════════════════════════════════════════════
   PROGRESS BAR ANIMATE-ON-SCROLL
═══════════════════════════════════════════════════════════════ */
document.addEventListener('DOMContentLoaded', function(){
    // Animate progress bars that are visible
    var observer = new IntersectionObserver(function(entries){
        entries.forEach(function(entry){
            if(entry.isIntersecting){
                var fill = entry.target;
                var w = fill.style.width;
                fill.style.width = '0%';
                setTimeout(function(){ fill.style.width = w; }, 50);
                observer.unobserve(fill);
            }
        });
    },{ threshold:0.1 });
    document.querySelectorAll('.progress-fill').forEach(function(el){
        observer.observe(el);
    });
});

/* assign lblSessionName2 from lblSessionName content */
document.addEventListener('DOMContentLoaded', function(){
    var s1 = document.getElementById('<%= lblSessionName.ClientID %>');
    var s2 = document.getElementById('<%= lblSessionName2.ClientID %>');
    if (s1 && s2) s2.innerHTML = s1.innerHTML;
});
</script>

</asp:Content>
