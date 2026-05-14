<%@ Page Title="Super Admin Dashboard"
    Language="C#"
    MasterPageFile="~/SuperAdmin/SuperAdminMaster.master"
    AutoEventWireup="true"
    CodeBehind="Dashboard.aspx.cs"
    Inherits="LMS_Project.SuperAdmin.Dashboard" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<link href="https://fonts.googleapis.com/css2?family=Syne:wght@400;500;600;700;800&family=DM+Sans:ital,opsz,wght@0,9..40,300;0,9..40,400;0,9..40,500;0,9..40,600;1,9..40,400&family=DM+Mono:wght@400;500&display=swap" rel="stylesheet">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

<%-- ══ ALL HIDDEN FIELDS ══ --%>
<asp:HiddenField ID="hfSocieties"     runat="server" />
<asp:HiddenField ID="hfInstitutes"    runat="server" />
<asp:HiddenField ID="hfUsers"         runat="server" />
<asp:HiddenField ID="hfStudents"      runat="server" />
<asp:HiddenField ID="hfTeachers"      runat="server" />
<asp:HiddenField ID="hfVideos"        runat="server" />
<asp:HiddenField ID="hfAssignments"   runat="server" />
<asp:HiddenField ID="hfSessions"      runat="server" />
<asp:HiddenField ID="hfActiveSoc"     runat="server" />
<asp:HiddenField ID="hfActiveInst"    runat="server" />
<asp:HiddenField ID="hfNewStudents"   runat="server" />
<asp:HiddenField ID="hfInstThisMonth" runat="server" />
<asp:HiddenField ID="hfTodayAct"      runat="server" />
<asp:HiddenField ID="hfTotalViews"    runat="server" />
<asp:HiddenField ID="hfGrowthLabels"  runat="server" />
<asp:HiddenField ID="hfGrowthStudents" runat="server" />
<asp:HiddenField ID="hfGrowthTeachers" runat="server" />
<asp:HiddenField ID="hfGrowthTotal"   runat="server" />
<asp:HiddenField ID="hfRoleLabels"    runat="server" />
<asp:HiddenField ID="hfRoleCounts"    runat="server" />
<asp:HiddenField ID="hfSocLabels"     runat="server" />
<asp:HiddenField ID="hfSocActive"     runat="server" />
<asp:HiddenField ID="hfSocInactive"   runat="server" />
<asp:HiddenField ID="hfInstGrowLabels" runat="server" />
<asp:HiddenField ID="hfInstGrowCounts" runat="server" />
<asp:HiddenField ID="hfHealthVideos"  runat="server" />
<asp:HiddenField ID="hfHealthViews"   runat="server" />
<asp:HiddenField ID="hfHealthAssign"  runat="server" />
<asp:HiddenField ID="hfHealthSubs"    runat="server" />
<asp:HiddenField ID="hfHealthAtt"     runat="server" />
<asp:HiddenField ID="hfHealthSubjects" runat="server" />
<asp:HiddenField ID="hfHealthLoginsToday" runat="server" />
<asp:HiddenField ID="hfHealthActiveWeek"  runat="server" />

<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>

<style>
/* ════════════════════════════════════════════════
   SUPERADMIN DASHBOARD — Deep Navy + Electric Blue
   Font: Syne (display) + DM Sans (body) + DM Mono
════════════════════════════════════════════════ */
:root{
  --bg:#080c14;--bg2:#0d1421;--bg3:#111827;--bg4:#161f2e;
  --surf:#131c2b;--surf2:#18243a;--surf3:#1e2d45;
  --bdr:rgba(255,255,255,.07);--bdr2:rgba(255,255,255,.12);

  --blue:#3b82f6;--blue2:#60a5fa;--blue3:#93c5fd;--blue-lt:rgba(59,130,246,.12);
  --electric:#00d4ff;--electric2:rgba(0,212,255,.15);
  --green:#10b981;--green-lt:rgba(16,185,129,.12);
  --amber:#f59e0b;--amber-lt:rgba(245,158,11,.12);
  --red:#ef4444;--red-lt:rgba(239,68,68,.12);
  --purple:#8b5cf6;--purple-lt:rgba(139,92,246,.12);
  --pink:#ec4899;--pink-lt:rgba(236,72,153,.12);
  --text:#f0f6ff;--text2:#94a3b8;--text3:#64748b;
  --gold:#fbbf24;

  --f:'DM Sans',system-ui,sans-serif;
  --fd:'Syne',system-ui,sans-serif;
  --mono:'DM Mono',monospace;

  --r:12px;--rlg:18px;
  --sh:0 1px 3px rgba(0,0,0,.4),0 4px 20px rgba(0,0,0,.3);
  --shl:0 8px 40px rgba(0,0,0,.5);
  --glow:0 0 30px rgba(59,130,246,.25);
}

*,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
body{font-family:var(--f);background:var(--bg);color:var(--text);font-size:14px;line-height:1.5}

/* ── SCROLLBAR ── */
::-webkit-scrollbar{width:5px;height:5px}
::-webkit-scrollbar-track{background:transparent}
::-webkit-scrollbar-thumb{background:var(--surf3);border-radius:3px}

/* ── ROOT WRAPPER ── */
.sa-dash{max-width:1600px;margin:0 auto;padding:0 4px 60px}

/* ── PAGE HEADER ── */
.sa-header{
  display:flex;align-items:flex-start;justify-content:space-between;
  flex-wrap:wrap;gap:16px;margin-bottom:32px;padding-top:4px;
}
.sa-header-left{}
.sa-header-eyebrow{
  font-size:11px;font-weight:600;letter-spacing:.12em;text-transform:uppercase;
  color:var(--electric);margin-bottom:6px;display:flex;align-items:center;gap:6px;
}
.sa-header-eyebrow::before{
  content:'';width:20px;height:2px;background:var(--electric);border-radius:1px;
}
.sa-header-title{
  font-family:var(--fd);font-size:1.9rem;font-weight:800;
  color:var(--text);line-height:1.1;
}
.sa-header-title span{color:var(--electric)}
.sa-header-sub{font-size:13px;color:var(--text3);margin-top:4px}
.sa-live-badge{
  display:inline-flex;align-items:center;gap:6px;
  background:var(--green-lt);border:1px solid rgba(16,185,129,.3);
  border-radius:20px;padding:5px 12px;font-size:11px;font-weight:600;color:var(--green);
}
.sa-live-badge::before{
  content:'';width:7px;height:7px;border-radius:50%;background:var(--green);
  animation:pulse-dot 1.5s infinite;
}
@keyframes pulse-dot{0%,100%{opacity:1;transform:scale(1)}50%{opacity:.5;transform:scale(.7)}}

/* ── KPI GRID ── */
.kpi-grid{
  display:grid;
  grid-template-columns:repeat(auto-fill,minmax(190px,1fr));
  gap:14px;margin-bottom:24px;
}
.kpi-card{
  background:var(--surf);border:1px solid var(--bdr);border-radius:var(--r);
  padding:20px;position:relative;overflow:hidden;
  cursor:default;transition:transform .22s,box-shadow .22s,border-color .22s;
  animation:rise .5s both;
}
.kpi-card::before{
  content:'';position:absolute;top:0;left:0;right:0;height:2px;
  background:var(--ac,var(--blue));
}
.kpi-card::after{
  content:'';position:absolute;bottom:-30px;right:-20px;
  width:80px;height:80px;border-radius:50%;
  background:radial-gradient(circle, var(--ac,var(--blue)) 0%, transparent 70%);
  opacity:.08;transition:opacity .22s;
}
.kpi-card:hover{
  transform:translateY(-5px);
  box-shadow:0 12px 40px rgba(0,0,0,.4),0 0 20px var(--ac-glow,rgba(59,130,246,.15));
  border-color:var(--bdr2);
}
.kpi-card:hover::after{opacity:.18}
.kpi-ico{
  width:38px;height:38px;border-radius:10px;margin-bottom:14px;
  display:flex;align-items:center;justify-content:center;font-size:15px;
  flex-shrink:0;
}
.kpi-val{
  font-family:var(--mono);font-size:1.7rem;font-weight:500;
  line-height:1;color:var(--text);margin-bottom:4px;letter-spacing:-.02em;
}
.kpi-label{font-size:11px;font-weight:600;color:var(--text3);text-transform:uppercase;letter-spacing:.05em}
.kpi-delta{
  display:inline-flex;align-items:center;gap:3px;
  font-size:11px;font-weight:600;margin-top:6px;
}
.kpi-delta.up{color:var(--green)}
.kpi-delta.neu{color:var(--text3)}
@keyframes rise{from{opacity:0;transform:translateY(18px)}to{opacity:1;transform:translateY(0)}}

/* ── SECTION LABEL ── */
.sec-lbl{
  font-family:var(--fd);font-size:12px;font-weight:700;text-transform:uppercase;
  letter-spacing:.1em;color:var(--text3);margin-bottom:14px;
  display:flex;align-items:center;gap:8px;
}
.sec-lbl::after{content:'';flex:1;height:1px;background:var(--bdr)}

/* ── CHART GRID ── */
.chart-grid-2{display:grid;grid-template-columns:1fr 1fr;gap:16px;margin-bottom:20px}
.chart-grid-3{display:grid;grid-template-columns:1fr 1fr 1fr;gap:16px;margin-bottom:20px}
.chart-grid-70{display:grid;grid-template-columns:1fr 380px;gap:16px;margin-bottom:20px}
@media(max-width:1100px){
  .chart-grid-2,.chart-grid-3,.chart-grid-70{grid-template-columns:1fr}
}
@media(max-width:768px){.kpi-grid{grid-template-columns:1fr 1fr}}

/* ── GLASS CARD ── */
.gc{
  background:var(--surf);border:1px solid var(--bdr);border-radius:var(--rlg);
  overflow:hidden;transition:border-color .22s,box-shadow .22s;
}
.gc:hover{border-color:var(--bdr2)}
.gc-head{
  display:flex;align-items:center;justify-content:space-between;
  padding:16px 20px;border-bottom:1px solid var(--bdr);
}
.gc-title{
  font-family:var(--fd);font-size:13px;font-weight:700;color:var(--text);
  display:flex;align-items:center;gap:8px;
}
.gc-title .dot{
  width:8px;height:8px;border-radius:50%;flex-shrink:0;
}
.gc-body{padding:18px 20px}
.gc-body.p0{padding:0}

/* ── CHART BOX ── */
.ch-box{position:relative;height:230px}
.ch-box.tall{height:280px}
.ch-box.sm{height:180px}

/* ── SOCIETIES TABLE ── */
.sa-table{width:100%;border-collapse:collapse;font-size:12px}
.sa-table thead th{
  padding:9px 14px;text-align:left;
  font-size:10px;font-weight:700;text-transform:uppercase;letter-spacing:.06em;
  color:var(--text3);border-bottom:1px solid var(--bdr);background:var(--bg4);
  white-space:nowrap;
}
.sa-table tbody td{
  padding:11px 14px;border-bottom:1px solid var(--bdr);
  vertical-align:middle;color:var(--text2);
}
.sa-table tbody tr:last-child td{border-bottom:none}
.sa-table tbody tr:hover{background:var(--surf2)}
.sa-table .mono{font-family:var(--mono);font-size:11px}

/* ── BADGES ── */
.sa-badge{
  display:inline-flex;align-items:center;gap:4px;
  border-radius:6px;padding:2px 8px;font-size:10px;font-weight:700;
  white-space:nowrap;
}
.sa-badge::before{content:'';width:5px;height:5px;border-radius:50%}
.sa-badge.green{background:var(--green-lt);color:var(--green)}
.sa-badge.green::before{background:var(--green)}
.sa-badge.red{background:var(--red-lt);color:var(--red)}
.sa-badge.red::before{background:var(--red)}
.sa-badge.blue{background:var(--blue-lt);color:var(--blue2)}
.sa-badge.amber{background:var(--amber-lt);color:var(--amber)}

/* ── INSTITUTE CARD ── */
.inst-grid{
  display:grid;
  grid-template-columns:repeat(auto-fill,minmax(260px,1fr));
  gap:14px;
}
.inst-card{
  background:var(--surf);border:1px solid var(--bdr);border-radius:var(--r);
  padding:16px;transition:.22s;position:relative;overflow:hidden;
}
.inst-card:hover{transform:translateY(-4px);border-color:var(--blue);box-shadow:var(--glow)}
.inst-card::before{
  content:'';position:absolute;top:0;left:0;width:3px;height:100%;
  background:var(--blue);border-radius:0 3px 3px 0;opacity:0;transition:opacity .22s;
}
.inst-card:hover::before{opacity:1}
.ic-header{display:flex;align-items:flex-start;justify-content:space-between;margin-bottom:12px}
.ic-logo{
  width:42px;height:42px;border-radius:10px;background:var(--surf3);
  display:flex;align-items:center;justify-content:center;
  font-family:var(--fd);font-size:14px;font-weight:800;color:var(--blue2);flex-shrink:0;
}
.ic-name{font-size:13px;font-weight:700;color:var(--text);line-height:1.3}
.ic-soc{font-size:11px;color:var(--text3);margin-top:2px}
.ic-stats{display:grid;grid-template-columns:1fr 1fr;gap:8px;margin-top:12px}
.ic-stat{background:var(--bg4);border-radius:8px;padding:8px 10px;text-align:center}
.ic-stat-val{font-family:var(--mono);font-size:.95rem;font-weight:500;color:var(--text)}
.ic-stat-lbl{font-size:9px;font-weight:600;color:var(--text3);text-transform:uppercase;letter-spacing:.04em;margin-top:1px}

/* ── ACTIVITY TIMELINE ── */
.act-list{display:flex;flex-direction:column;gap:0}
.act-item{
  display:flex;align-items:flex-start;gap:12px;
  padding:12px 0;border-bottom:1px solid var(--bdr);
  transition:background .15s;
}
.act-item:last-child{border-bottom:none}
.act-dot{
  width:32px;height:32px;border-radius:10px;flex-shrink:0;
  display:flex;align-items:center;justify-content:center;font-size:12px;
}
.act-body{flex:1;min-width:0}
.act-type{font-size:12px;font-weight:600;color:var(--text);white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.act-meta{font-size:11px;color:var(--text3);margin-top:2px}
.act-time{font-size:10px;color:var(--text3);white-space:nowrap;font-family:var(--mono)}

/* ── HEALTH GRID ── */
.health-grid{
  display:grid;grid-template-columns:repeat(4,1fr);gap:10px;
}
@media(max-width:900px){.health-grid{grid-template-columns:repeat(2,1fr)}}
.health-item{
  background:var(--bg4);border:1px solid var(--bdr);border-radius:var(--r);
  padding:14px 16px;text-align:center;transition:.2s;
}
.health-item:hover{border-color:var(--bdr2);background:var(--surf2)}
.health-val{
  font-family:var(--mono);font-size:1.35rem;font-weight:500;
  line-height:1;margin-bottom:4px;
}
.health-lbl{font-size:10px;font-weight:600;color:var(--text3);text-transform:uppercase;letter-spacing:.05em}

/* ── SCROLL AREA ── */
.scroll-y{max-height:380px;overflow-y:auto;padding-right:2px}

/* ── OVERVIEW STRIP ── */
.overview-strip{
  display:grid;grid-template-columns:repeat(auto-fill,minmax(140px,1fr));
  gap:10px;margin-bottom:20px;
}
.ov-chip{
  background:var(--surf);border:1px solid var(--bdr);border-radius:var(--r);
  padding:14px;display:flex;flex-direction:column;gap:4px;
  transition:.2s;
}
.ov-chip:hover{border-color:var(--bdr2);background:var(--surf2)}
.ov-chip-val{font-family:var(--mono);font-size:1.4rem;font-weight:500;color:var(--text)}
.ov-chip-lbl{font-size:10px;font-weight:600;color:var(--text3);text-transform:uppercase;letter-spacing:.05em}
.ov-chip-icon{font-size:16px;margin-bottom:2px}

/* ── EMPTY ── */
.sa-empty{text-align:center;padding:32px;color:var(--text3)}
.sa-empty i{font-size:2rem;opacity:.2;display:block;margin-bottom:8px}

/* ── ANIMATIONS ── */
@keyframes slideIn{from{opacity:0;transform:translateX(-10px)}to{opacity:1;transform:translateX(0)}}
.anim-kpi-1{animation-delay:.05s}
.anim-kpi-2{animation-delay:.10s}
.anim-kpi-3{animation-delay:.15s}
.anim-kpi-4{animation-delay:.20s}
.anim-kpi-5{animation-delay:.25s}
.anim-kpi-6{animation-delay:.30s}
.anim-kpi-7{animation-delay:.35s}
.anim-kpi-8{animation-delay:.40s}
</style>

<div class="sa-dash">

<%-- ══ PAGE HEADER ══════════════════════════════════════════════════════ --%>
<div class="sa-header">
    <div class="sa-header-left">
        <div class="sa-header-eyebrow">Platform Analytics</div>
        <div class="sa-header-title">Super Admin <span>Dashboard</span></div>
        <div class="sa-header-sub">Complete platform overview — all societies &amp; institutes</div>
    </div>
    <div style="display:flex;flex-direction:column;align-items:flex-end;gap:8px">
        <div class="sa-live-badge">Live Data</div>
        <div style="font-size:11px;color:var(--text3)">
            <i class="fa fa-clock me-1"></i>Last refresh: <%= DateTime.Now.ToString("hh:mm tt, dd MMM yyyy") %>
        </div>
    </div>
</div>

<%-- ══ KPI CARDS ════════════════════════════════════════════════════════ --%>
<div class="kpi-grid">

    <div class="kpi-card anim-kpi-1" style="--ac:var(--electric);--ac-glow:rgba(0,212,255,.2)">
        <div class="kpi-ico" style="background:rgba(0,212,255,.12);color:var(--electric)"><i class="fa fa-building"></i></div>
        <div class="kpi-val kpi-num" id="kSoc">—</div>
        <div class="kpi-label">Total Societies</div>
        <div class="kpi-delta up"><i class="fa fa-check-circle"></i> <span id="kActiveSoc">—</span> active</div>
    </div>

    <div class="kpi-card anim-kpi-2" style="--ac:var(--blue);--ac-glow:rgba(59,130,246,.2)">
        <div class="kpi-ico" style="background:var(--blue-lt);color:var(--blue2)"><i class="fa fa-university"></i></div>
        <div class="kpi-val kpi-num" id="kInst">—</div>
        <div class="kpi-label">Institutes</div>
        <div class="kpi-delta up"><i class="fa fa-plus-circle"></i> <span id="kInstMonth">—</span> this month</div>
    </div>

    <div class="kpi-card anim-kpi-3" style="--ac:var(--purple);--ac-glow:rgba(139,92,246,.2)">
        <div class="kpi-ico" style="background:var(--purple-lt);color:var(--purple)"><i class="fa fa-users"></i></div>
        <div class="kpi-val kpi-num" id="kUsers">—</div>
        <div class="kpi-label">Total Active Users</div>
        <div class="kpi-delta up"><i class="fa fa-calendar"></i> Platform-wide</div>
    </div>

    <div class="kpi-card anim-kpi-4" style="--ac:var(--green);--ac-glow:rgba(16,185,129,.2)">
        <div class="kpi-ico" style="background:var(--green-lt);color:var(--green)"><i class="fa fa-user-graduate"></i></div>
        <div class="kpi-val kpi-num" id="kStudents">—</div>
        <div class="kpi-label">Students</div>
        <div class="kpi-delta up"><i class="fa fa-user-plus"></i> <span id="kNewStu">—</span> new this month</div>
    </div>

    <div class="kpi-card anim-kpi-5" style="--ac:var(--amber);--ac-glow:rgba(245,158,11,.2)">
        <div class="kpi-ico" style="background:var(--amber-lt);color:var(--amber)"><i class="fa fa-chalkboard-teacher"></i></div>
        <div class="kpi-val kpi-num" id="kTeachers">—</div>
        <div class="kpi-label">Teachers</div>
        <div class="kpi-delta neu"><i class="fa fa-circle"></i> All institutes</div>
    </div>

    <div class="kpi-card anim-kpi-6" style="--ac:var(--pink);--ac-glow:rgba(236,72,153,.2)">
        <div class="kpi-ico" style="background:var(--pink-lt);color:var(--pink)"><i class="fa fa-video"></i></div>
        <div class="kpi-val kpi-num" id="kVideos">—</div>
        <div class="kpi-label">Total Videos</div>
        <div class="kpi-delta up"><i class="fa fa-eye"></i> <span id="kViews">—</span> views</div>
    </div>

    <div class="kpi-card anim-kpi-7" style="--ac:#10b981;--ac-glow:rgba(16,185,129,.2)">
        <div class="kpi-ico" style="background:var(--green-lt);color:var(--green)"><i class="fa fa-tasks"></i></div>
        <div class="kpi-val kpi-num" id="kAssign">—</div>
        <div class="kpi-label">Assignments</div>
        <div class="kpi-delta neu"><i class="fa fa-file-alt"></i> All sessions</div>
    </div>

    <div class="kpi-card anim-kpi-8" style="--ac:var(--electric)">
        <div class="kpi-ico" style="background:rgba(0,212,255,.1);color:var(--electric)"><i class="fa fa-bolt"></i></div>
        <div class="kpi-val kpi-num" id="kTodayAct">—</div>
        <div class="kpi-label">Activities Today</div>
        <div class="kpi-delta up"><i class="fa fa-calendar-alt"></i> <span id="kSessions">—</span> active sessions</div>
    </div>

</div>

<%-- ══ CHARTS ROW 1: USER GROWTH + ROLES DONUT ══════════════════════════ --%>
<div class="sec-lbl" style="margin-top:8px">User Analytics</div>
<div class="chart-grid-70" style="margin-bottom:20px">

    <div class="gc">
        <div class="gc-head">
            <div class="gc-title">
                <div class="dot" style="background:var(--blue)"></div>
                Monthly User Growth (Last 12 Months)
            </div>
            <div style="font-size:11px;color:var(--text3)">Students &amp; Teachers</div>
        </div>
        <div class="gc-body">
            <div class="ch-box tall"><canvas id="growthChart"></canvas></div>
        </div>
    </div>

    <div class="gc">
        <div class="gc-head">
            <div class="gc-title">
                <div class="dot" style="background:var(--purple)"></div>
                Users by Role
            </div>
        </div>
        <div class="gc-body" style="display:flex;flex-direction:column;align-items:center">
            <div class="ch-box" style="height:200px;width:200px"><canvas id="rolesDonut"></canvas></div>
            <div id="rolesLegend" style="display:flex;flex-wrap:wrap;gap:8px;margin-top:16px;justify-content:center"></div>
        </div>
    </div>

</div>

<%-- ══ CHARTS ROW 2: INSTITUTES BY SOCIETY + INSTITUTE GROWTH ════════ --%>
<div class="sec-lbl">Institute Analytics</div>
<div class="chart-grid-2" style="margin-bottom:20px">

    <div class="gc">
        <div class="gc-head">
            <div class="gc-title">
                <div class="dot" style="background:var(--electric)"></div>
                Institutes per Society
            </div>
            <span style="font-size:10px;color:var(--text3)">Active vs Inactive</span>
        </div>
        <div class="gc-body">
            <div class="ch-box"><canvas id="instBySocChart"></canvas></div>
        </div>
    </div>

    <div class="gc">
        <div class="gc-head">
            <div class="gc-title">
                <div class="dot" style="background:var(--amber)"></div>
                New Institutes / Sessions Over Time
            </div>
        </div>
        <div class="gc-body">
            <div class="ch-box"><canvas id="instGrowChart"></canvas></div>
        </div>
    </div>

</div>

<%-- ══ SYSTEM HEALTH STRIP ════════════════════════════════════════════ --%>
<div class="sec-lbl">System Health</div>
<div class="health-grid" style="margin-bottom:24px">
    <div class="health-item">
        <div class="health-val" style="color:var(--blue2)" id="hVideos">—</div>
        <div class="health-lbl"><i class="fa fa-video me-1"></i>Videos</div>
    </div>
    <div class="health-item">
        <div class="health-val" style="color:var(--electric)" id="hViews">—</div>
        <div class="health-lbl"><i class="fa fa-eye me-1"></i>Total Views</div>
    </div>
    <div class="health-item">
        <div class="health-val" style="color:var(--purple)" id="hSubjects">—</div>
        <div class="health-lbl"><i class="fa fa-book me-1"></i>Subjects</div>
    </div>
    <div class="health-item">
        <div class="health-val" style="color:var(--amber)" id="hAssign">—</div>
        <div class="health-lbl"><i class="fa fa-tasks me-1"></i>Assignments</div>
    </div>
    <div class="health-item">
        <div class="health-val" style="color:var(--green)" id="hSubs">—</div>
        <div class="health-lbl"><i class="fa fa-paper-plane me-1"></i>Submissions</div>
    </div>
    <div class="health-item">
        <div class="health-val" style="color:var(--pink)" id="hAtt">—</div>
        <div class="health-lbl"><i class="fa fa-calendar-check me-1"></i>Attendance</div>
    </div>
    <div class="health-item">
        <div class="health-val" style="color:var(--electric)" id="hLogins">—</div>
        <div class="health-lbl"><i class="fa fa-sign-in-alt me-1"></i>Logins Today</div>
    </div>
    <div class="health-item">
        <div class="health-val" style="color:var(--green)" id="hActiveWeek">—</div>
        <div class="health-lbl"><i class="fa fa-users me-1"></i>Active (7 days)</div>
    </div>
</div>

<%-- ══ TOP INSTITUTES + RECENT ACTIVITY ════════════════════════════════ --%>
<div class="sec-lbl">Top Institutes &amp; Activity</div>
<div class="chart-grid-70" style="margin-bottom:24px">

    <div class="gc">
        <div class="gc-head">
            <div class="gc-title">
                <div class="dot" style="background:var(--green)"></div>
                Top Institutes by Student Count
            </div>
        </div>
        <div class="gc-body p0">
            <div class="scroll-y">
                <table class="sa-table">
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>Institute</th>
                            <th>Society</th>
                            <th>Students</th>
                            <th>Teachers</th>
                            <th>Videos</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <asp:Repeater ID="rptTopInstitutes" runat="server">
                            <ItemTemplate>
                                <tr>
                                    <td class="mono" style="color:var(--text3)"><%# Container.ItemIndex+1 %></td>
                                    <td>
                                        <div style="font-weight:600;color:var(--text);font-size:12px"><%# H(Eval("InstituteName")) %></div>
                                        <div style="font-size:10px;color:var(--text3);font-family:var(--mono)"><%# H(Eval("InstituteCode")) %></div>
                                    </td>
                                    <td style="font-size:11px;color:var(--text3)"><%# H(Eval("SocietyName")) %></td>
                                    <td style="font-family:var(--mono);font-weight:600;color:var(--blue2)"><%# Eval("StudentCount") %></td>
                                    <td style="font-family:var(--mono);color:var(--green)"><%# Eval("TeacherCount") %></td>
                                    <td style="font-family:var(--mono);color:var(--amber)"><%# Eval("VideoCount") %></td>
                                    <td><%# StatusBadge(Eval("IsActive")) %></td>
                                </tr>
                            </ItemTemplate>
                            <FooterTemplate>
                                <%# rptTopInstitutes.Items.Count == 0
                                    ? "<tr><td colspan='7'><div class='sa-empty'><i class='fa fa-university'></i><p>No institutes found</p></div></td></tr>"
                                    : "" %>
                            </FooterTemplate>
                        </asp:Repeater>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <div class="gc">
        <div class="gc-head">
            <div class="gc-title">
                <div class="dot" style="background:var(--amber)"></div>
                Recent Activity
            </div>
        </div>
        <div class="gc-body p0">
            <div class="act-list scroll-y" style="padding:0 16px">
                <asp:Repeater ID="rptActivity" runat="server">
                    <ItemTemplate>
                        <div class="act-item">
                            <div class="act-dot" style="background:<%# RoleColor(Eval("RoleName")) %>22;color:<%# RoleColor(Eval("RoleName")) %>">
                                <i class="fa <%# ActivityIcon(Eval("ActivityType")) %>"></i>
                            </div>
                            <div class="act-body">
                                <div class="act-type"><%# H(Eval("ActivityType")) %></div>
                                <div class="act-meta">
                                    <span style="color:<%# RoleColor(Eval("RoleName")) %>"><%# H(Eval("UserName")) %></span>
                                    &bull; <%# H(Eval("InstituteName")) %>
                                </div>
                            </div>
                            <div class="act-time"><%# FmtDateTime(Eval("ActionTime")) %></div>
                        </div>
                    </ItemTemplate>
                    <FooterTemplate>
                        <%# rptActivity.Items.Count == 0
                            ? "<div class='sa-empty'><i class='fa fa-history'></i><p>No activity</p></div>"
                            : "" %>
                    </FooterTemplate>
                </asp:Repeater>
            </div>
        </div>
    </div>

</div>

<%-- ══ SOCIETIES OVERVIEW TABLE ════════════════════════════════════════ --%>
<div class="sec-lbl">Societies Overview</div>
<div class="gc" style="margin-bottom:24px">
    <div class="gc-head">
        <div class="gc-title">
            <div class="dot" style="background:var(--electric)"></div>
            All Societies — Platform Summary
        </div>
        <a href="AddSociety.aspx" style="font-size:12px;color:var(--blue2);text-decoration:none;font-weight:600">
            <i class="fa fa-plus me-1"></i>Add Society
        </a>
    </div>
    <div class="gc-body p0">
        <table class="sa-table">
            <thead>
                <tr>
                    <th>#</th>
                    <th>Society</th>
                    <th>Code</th>
                    <th>Institutes</th>
                    <th>Students</th>
                    <th>Teachers</th>
                    <th>Sessions</th>
                    <th>Status</th>
                    <th>Created</th>
                </tr>
            </thead>
            <tbody>
                <asp:Repeater ID="rptSocieties" runat="server">
                    <ItemTemplate>
                        <tr>
                            <td class="mono" style="color:var(--text3)"><%# Container.ItemIndex+1 %></td>
                            <td>
                                <div style="font-weight:700;color:var(--text);font-size:13px"><%# H(Eval("SocietyName")) %></div>
                            </td>
                            <td>
                                <span style="font-family:var(--mono);font-size:11px;background:var(--bg4);
                                             border-radius:5px;padding:2px 6px;color:var(--electric)">
                                    <%# H(Eval("SocietyCode")) %>
                                </span>
                            </td>
                            <td style="font-family:var(--mono);font-weight:600;color:var(--blue2)"><%# Eval("InstituteCount") %></td>
                            <td style="font-family:var(--mono);color:var(--green)"><%# Eval("StudentCount") %></td>
                            <td style="font-family:var(--mono);color:var(--amber)"><%# Eval("TeacherCount") %></td>
                            <td style="font-family:var(--mono);color:var(--text3)"><%# Eval("SessionCount") %></td>
                            <td><%# StatusBadge(Eval("IsActive")) %></td>
                            <td style="font-size:11px;color:var(--text3)"><%# FmtDate(Eval("CreatedOn")) %></td>
                        </tr>
                    </ItemTemplate>
                    <FooterTemplate>
                        <%# rptSocieties.Items.Count == 0
                            ? "<tr><td colspan='9'><div class='sa-empty'><i class='fa fa-building'></i><p>No societies found</p></div></td></tr>"
                            : "" %>
                    </FooterTemplate>
                </asp:Repeater>
            </tbody>
        </table>
    </div>
</div>

</div><%-- /sa-dash --%>

<%-- ══ SCRIPTS ══════════════════════════════════════════════════════════ --%>
<script>
(function () {
    'use strict';

    /* ── HELPERS ── */
    function hf(id) { var e = document.getElementById(id); return e ? e.value : ''; }
    function jp(id) { try { return JSON.parse(hf(id) || '[]'); } catch (e) { return []; } }
    function jpn(id) { var v = parseInt(hf(id)); return isNaN(v) ? 0 : v; }

    /* ── CHART.JS DEFAULTS ── */
    Chart.defaults.font.family = "'DM Sans', system-ui, sans-serif";
    Chart.defaults.font.size = 11;
    Chart.defaults.color = '#64748b';
    Chart.defaults.plugins.legend.display = false;

    /* ── POPULATE KPI DOM ── */
    var kpiMap = {
        kSoc:       '<%= hfSocieties.ClientID %>',
        kActiveSoc: '<%= hfActiveSoc.ClientID %>',
        kInst:      '<%= hfInstitutes.ClientID %>',
        kInstMonth: '<%= hfInstThisMonth.ClientID %>',
        kUsers:     '<%= hfUsers.ClientID %>',
        kStudents:  '<%= hfStudents.ClientID %>',
        kNewStu:    '<%= hfNewStudents.ClientID %>',
        kTeachers:  '<%= hfTeachers.ClientID %>',
        kVideos:    '<%= hfVideos.ClientID %>',
        kViews:     '<%= hfTotalViews.ClientID %>',
        kAssign:    '<%= hfAssignments.ClientID %>',
        kTodayAct:  '<%= hfTodayAct.ClientID %>',
        kSessions:  '<%= hfSessions.ClientID %>'
    };

    /* ── HEALTH MAP ── */
    var healthMap = {
        hVideos:     '<%= hfHealthVideos.ClientID %>',
        hViews:      '<%= hfHealthViews.ClientID %>',
        hSubjects:   '<%= hfHealthSubjects.ClientID %>',
        hAssign:     '<%= hfHealthAssign.ClientID %>',
        hSubs:       '<%= hfHealthSubs.ClientID %>',
        hAtt:        '<%= hfHealthAtt.ClientID %>',
        hLogins:     '<%= hfHealthLoginsToday.ClientID %>',
        hActiveWeek: '<%= hfHealthActiveWeek.ClientID %>'
    };

    /* ── COUNT-UP ANIMATION ── */
    function countUp(el, target, dur) {
        dur = dur || 1100;
        var start = performance.now();
        (function step(now) {
            var p = Math.min((now - start) / dur, 1);
            var ease = 1 - Math.pow(1 - p, 3);
            var val = Math.round(target * ease);
            el.textContent = val >= 1000 ? (val / 1000).toFixed(1) + 'K' : val;
            if (p < 1) requestAnimationFrame(step);
        })(performance.now());
    }

    /* ── INIT ON DOM READY ── */
    document.addEventListener('DOMContentLoaded', function () {

        // KPI count-ups
        Object.keys(kpiMap).forEach(function (k) {
            var el = document.getElementById(k);
            if (el) countUp(el, jpn(kpiMap[k]));
        });

        // Health count-ups
        Object.keys(healthMap).forEach(function (k) {
            var el = document.getElementById(k);
            if (el) countUp(el, jpn(healthMap[k]));
        });

        // Build charts
        buildGrowthChart();
        buildRolesDonut();
        buildInstBySoc();
        buildInstGrow();
    });

    /* ── GROWTH CHART (line + bar combo) ── */
    function buildGrowthChart() {
        var ctx = document.getElementById('growthChart');
        if (!ctx) return;
        var L = jp('<%= hfGrowthLabels.ClientID %>');
        var S = jp('<%= hfGrowthStudents.ClientID %>');
        var T = jp('<%= hfGrowthTeachers.ClientID %>');
        if (!L.length) { emptyChart(ctx); return; }

        new Chart(ctx, {
            type: 'bar',
            data: {
                labels: L,
                datasets: [
                    {
                        label: 'Students',
                        data: S,
                        backgroundColor: 'rgba(59,130,246,.7)',
                        borderRadius: 5,
                        borderSkipped: false,
                        hoverBackgroundColor: '#3b82f6',
                        yAxisID: 'y'
                    },
                    {
                        label: 'Teachers',
                        data: T,
                        type: 'line',
                        borderColor: '#00d4ff',
                        backgroundColor: 'rgba(0,212,255,.08)',
                        borderWidth: 2.5,
                        pointBackgroundColor: '#00d4ff',
                        pointRadius: 4,
                        pointHoverRadius: 7,
                        tension: 0.4,
                        fill: true,
                        yAxisID: 'y2'
                    }
                ]
            },
            options: {
                responsive: true, maintainAspectRatio: false,
                animation: { duration: 1200, easing: 'easeOutQuart' },
                interaction: { mode: 'index', intersect: false },
                plugins: {
                    legend: {
                        display: true, position: 'top',
                        labels: { color: '#94a3b8', font: { size: 11 }, boxWidth: 12, usePointStyle: true }
                    },
                    tooltip: {
                        backgroundColor: 'rgba(8,12,20,.95)',
                        titleColor: '#e0f2fe',
                        bodyColor: '#94a3b8',
                        padding: 12, cornerRadius: 10,
                        borderColor: 'rgba(59,130,246,.3)', borderWidth: 1
                    }
                },
                scales: {
                    x: {
                        grid: { color: 'rgba(255,255,255,.04)' },
                        ticks: { color: '#64748b', maxRotation: 40 }
                    },
                    y: {
                        position: 'left',
                        grid: { color: 'rgba(255,255,255,.04)' },
                        ticks: { color: '#64748b' }
                    },
                    y2: {
                        position: 'right',
                        grid: { drawOnChartArea: false },
                        ticks: { color: '#00d4ff' }
                    }
                }
            }
        });
    }

    /* ── ROLES DONUT ── */
    function buildRolesDonut() {
        var ctx = document.getElementById('rolesDonut');
        if (!ctx) return;
        var L = jp('<%= hfRoleLabels.ClientID %>');
        var D = jp('<%= hfRoleCounts.ClientID %>');
        if (!L.length) { emptyChart(ctx); return; }

        var colors = ['#4f46e5', '#10b981', '#f59e0b', '#0891b2', '#ec4899'];

        new Chart(ctx, {
            type: 'doughnut',
            data: {
                labels: L,
                datasets: [{
                    data: D,
                    backgroundColor: colors.slice(0, L.length),
                    borderWidth: 3,
                    borderColor: '#080c14',
                    hoverOffset: 12,
                    hoverBorderColor: '#131c2b'
                }]
            },
            options: {
                cutout: '72%',
                animation: { duration: 1400, easing: 'easeOutQuart' },
                plugins: {
                    legend: { display: false },
                    tooltip: {
                        backgroundColor: 'rgba(8,12,20,.95)',
                        padding: 12, cornerRadius: 10,
                        callbacks: {
                            label: function (c) {
                                var total = c.dataset.data.reduce(function (a, b) { return a + b; }, 0);
                                var pct = total > 0 ? Math.round(c.raw / total * 100) : 0;
                                return ' ' + c.raw.toLocaleString() + ' (' + pct + '%)';
                            }
                        }
                    }
                }
            }
        });

        // Build legend
        var legend = document.getElementById('rolesLegend');
        if (legend) {
            legend.innerHTML = L.map(function (lbl, i) {
                return '<div style="display:flex;align-items:center;gap:5px;font-size:11px;color:#94a3b8">'
                    + '<div style="width:10px;height:10px;border-radius:3px;background:' + (colors[i] || '#ccc') + '"></div>'
                    + '<span>' + lbl + ' <strong style="color:#f0f6ff">' + (D[i] || 0) + '</strong></span>'
                    + '</div>';
            }).join('');
        }
    }

    /* ── INSTITUTES BY SOCIETY (grouped bar) ── */
    function buildInstBySoc() {
        var ctx = document.getElementById('instBySocChart');
        if (!ctx) return;
        var L = jp('<%= hfSocLabels.ClientID %>');
        var A = jp('<%= hfSocActive.ClientID %>');
        var I = jp('<%= hfSocInactive.ClientID %>');
        if (!L.length) { emptyChart(ctx); return; }

        new Chart(ctx, {
            type: 'bar',
            data: {
                labels: L,
                datasets: [
                    {
                        label: 'Active',
                        data: A,
                        backgroundColor: 'rgba(0,212,255,.75)',
                        borderRadius: 6,
                        borderSkipped: false,
                        hoverBackgroundColor: '#00d4ff'
                    },
                    {
                        label: 'Inactive',
                        data: I,
                        backgroundColor: 'rgba(239,68,68,.4)',
                        borderRadius: 6,
                        borderSkipped: false,
                        hoverBackgroundColor: '#ef4444'
                    }
                ]
            },
            options: {
                responsive: true, maintainAspectRatio: false,
                animation: { duration: 1000, easing: 'easeOutQuart' },
                interaction: { mode: 'index', intersect: false },
                plugins: {
                    legend: {
                        display: true, position: 'top',
                        labels: { color: '#94a3b8', boxWidth: 12, usePointStyle: true }
                    },
                    tooltip: {
                        backgroundColor: 'rgba(8,12,20,.95)',
                        padding: 12, cornerRadius: 10
                    }
                },
                scales: {
                    x: { grid: { color: 'rgba(255,255,255,.04)' }, ticks: { color: '#64748b' } },
                    y: { grid: { color: 'rgba(255,255,255,.04)' }, ticks: { color: '#64748b', precision: 0 } }
                }
            }
        });
    }

    /* ── INSTITUTE GROWTH (area line) ── */
    function buildInstGrow() {
        var ctx = document.getElementById('instGrowChart');
        if (!ctx) return;
        var L = jp('<%= hfInstGrowLabels.ClientID %>');
        var D = jp('<%= hfInstGrowCounts.ClientID %>');
        if (!L.length) { emptyChart(ctx); return; }

        new Chart(ctx, {
            type: 'line',
            data: {
                labels: L,
                datasets: [{
                    label: 'Institutes/Sessions',
                    data: D,
                    borderColor: '#f59e0b',
                    backgroundColor: 'rgba(245,158,11,.12)',
                    borderWidth: 2.5,
                    pointBackgroundColor: '#f59e0b',
                    pointRadius: 4,
                    pointHoverRadius: 7,
                    tension: 0.4,
                    fill: true
                }]
            },
            options: {
                responsive: true, maintainAspectRatio: false,
                animation: { duration: 1100, easing: 'easeOutQuart' },
                plugins: {
                    tooltip: {
                        backgroundColor: 'rgba(8,12,20,.95)',
                        padding: 12, cornerRadius: 10
                    }
                },
                scales: {
                    x: { grid: { color: 'rgba(255,255,255,.04)' }, ticks: { color: '#64748b', maxRotation: 40 } },
                    y: { grid: { color: 'rgba(255,255,255,.04)' }, ticks: { color: '#64748b', precision: 0 } }
                }
            }
        });
    }

    /* ── EMPTY CHART PLACEHOLDER ── */
    function emptyChart(ctx) {
        ctx.parentElement.innerHTML = '<div class="sa-empty" style="height:100%;display:flex;flex-direction:column;align-items:center;justify-content:center"><i class="fa fa-chart-bar"></i><p>No data yet</p></div>';
    }

    /* ── INTERSECTION OBSERVER (animate on scroll) ── */
    if ('IntersectionObserver' in window) {
        var io = new IntersectionObserver(function (entries) {
            entries.forEach(function (e) {
                if (e.isIntersecting) {
                    e.target.style.opacity = '1';
                    e.target.style.transform = 'translateY(0)';
                    io.unobserve(e.target);
                }
            });
        }, { threshold: 0.08 });

        document.querySelectorAll('.gc, .kpi-card, .health-item').forEach(function (el) {
            el.style.opacity = '0';
            el.style.transform = 'translateY(16px)';
            el.style.transition = 'opacity .5s ease, transform .5s ease';
            io.observe(el);
        });
    }

})();
</script>

</asp:Content>
