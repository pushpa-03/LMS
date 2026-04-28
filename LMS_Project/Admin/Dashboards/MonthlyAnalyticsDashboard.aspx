<%@ Page Title="Monthly Analytics Dashboard" Language="C#"
    MasterPageFile="~/Admin/AdminMaster.Master"
    AutoEventWireup="true"
    CodeBehind="MonthlyAnalyticsDashboard.aspx.cs"
    Inherits="LearningManagementSystem.Admin.Dashboards.MonthlyAnalyticsDashboard" %>

<asp:Content ID="cHead" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet"/>
<style>
/* ═══════════════════════════════════════════
   Design tokens
═══════════════════════════════════════════ */
:root{
  --primary:#4f46e5; --primary-light:#ede9fe; --primary-dark:#3730a3;
  --success:#10b981; --success-light:#d1fae5;
  --warning:#f59e0b; --warning-light:#fef3c7;
  --danger:#ef4444;  --danger-light:#fee2e2;
  --info:#3b82f6;    --info-light:#dbeafe;
  --purple:#8b5cf6;  --purple-light:#f3f0ff;
  --cyan:#0891b2;    --cyan-light:#cffafe;
  --rose:#f43f5e;    --rose-light:#ffe4e6;
  --teal:#0d9488;    --teal-light:#ccfbf1;
  --text-primary:#1e293b; --text-secondary:#64748b; --text-muted:#94a3b8;
  --border:#e2e8f0; --card-bg:#fff; --page-bg:#f8fafc;
  --radius:14px; --radius-sm:8px;
  --shadow:0 1px 3px rgba(0,0,0,.07),0 1px 2px rgba(0,0,0,.05);
  --shadow-md:0 4px 12px rgba(0,0,0,.08);
  --shadow-lg:0 8px 24px rgba(0,0,0,.10);
}
*{box-sizing:border-box;margin:0;padding:0;}
body{background:var(--page-bg);font-family:'Inter','Segoe UI',sans-serif;color:var(--text-primary);}

/* ── Wrapper ── */
.dash-wrap{padding:24px;}

/* ── Alert ── */
.dash-alert{
  display:flex;align-items:center;gap:10px;
  padding:12px 18px;border-radius:var(--radius-sm);
  font-size:13px;font-weight:500;margin-bottom:18px;
}
.alert-success{background:var(--success-light);color:#065f46;}
.alert-danger {background:var(--danger-light); color:#991b1b;}
.alert-warning{background:var(--warning-light);color:#92400e;}
.alert-info   {background:var(--info-light);   color:#1e40af;}

/* ── Top bar ── */
.top-bar{
  display:flex;align-items:center;justify-content:space-between;
  flex-wrap:wrap;gap:14px;margin-bottom:24px;
}
.top-bar h1{font-size:22px;font-weight:700;}
.top-bar h1 span{color:var(--primary);}
.filter-row{display:flex;align-items:center;gap:10px;flex-wrap:wrap;}
.filter-row select{
  padding:8px 12px;border:1px solid var(--border);border-radius:var(--radius-sm);
  font-size:13px;color:var(--text-primary);background:#fff;cursor:pointer;
  transition:border .2s;
}
.filter-row select:focus{border-color:var(--primary);outline:none;}
.btn-filter{
  padding:8px 20px;background:var(--primary);color:#fff;
  border:none;border-radius:var(--radius-sm);font-size:13px;font-weight:600;
  cursor:pointer;transition:background .2s,transform .15s;
}
.btn-filter:hover{background:var(--primary-dark);transform:translateY(-1px);}
.period-badge{
  background:var(--primary-light);color:var(--primary);
  padding:6px 16px;border-radius:20px;font-size:13px;font-weight:600;
}

/* ── Banner section ── */
.banner-section{
  background:var(--card-bg);border:1px solid var(--border);
  border-radius:var(--radius);box-shadow:var(--shadow);
  overflow:hidden;margin-bottom:24px;
}
.banner-inner{
  position:relative;min-height:160px;
  background:linear-gradient(135deg,#4f46e5 0%,#7c3aed 50%,#a855f7 100%);
  display:flex;align-items:center;justify-content:space-between;
  padding:28px 32px;gap:20px;flex-wrap:wrap;
}
.banner-inner.has-img{background:none;}
.banner-bg-img{
  position:absolute;inset:0;width:100%;height:100%;
  object-fit:cover;display:block;z-index:0;
}
.banner-overlay{
  position:absolute;inset:0;
  background:linear-gradient(90deg,rgba(30,10,80,.7) 0%,rgba(30,10,80,.3) 100%);
  z-index:1;
}
.banner-text{position:relative;z-index:2;}
.banner-text h2{font-size:24px;font-weight:800;color:#fff;margin-bottom:4px;}
.banner-text p{font-size:14px;color:rgba(255,255,255,.8);}
.banner-actions{position:relative;z-index:2;display:flex;gap:10px;flex-wrap:wrap;}

/* Upload area */
.upload-area{
  border:2px dashed rgba(255,255,255,.5);border-radius:var(--radius-sm);
  padding:16px 22px;cursor:pointer;text-align:center;
  transition:border .2s,background .2s;background:rgba(255,255,255,.08);
}
.upload-area:hover{border-color:#fff;background:rgba(255,255,255,.15);}
.upload-area i{font-size:22px;color:#fff;display:block;margin-bottom:6px;}
.upload-area span{font-size:12px;color:rgba(255,255,255,.85);}
.upload-area input[type=file]{display:none;}
.btn-upload,.btn-remove{
  padding:8px 18px;border:none;border-radius:var(--radius-sm);
  font-size:13px;font-weight:600;cursor:pointer;transition:.2s;
}
.btn-upload{background:#fff;color:var(--primary);}
.btn-upload:hover{background:#f3f4f6;}
.btn-remove{background:rgba(255,255,255,.2);color:#fff;border:1px solid rgba(255,255,255,.4);}
.btn-remove:hover{background:rgba(255,255,255,.35);}

/* ── KPI Grid ── */
.kpi-grid{
  display:grid;
  grid-template-columns:repeat(auto-fit,minmax(160px,1fr));
  gap:14px;margin-bottom:24px;
}
.kpi-card{
  background:var(--card-bg);
  border:1px solid var(--border);
  border-radius:var(--radius);
  padding:18px;
  box-shadow: var(--shadow);
  display:flex;flex-direction:column;gap:8px;
  transition:transform .2s,box-shadow .2s;position:relative;overflow:hidden;
}
.kpi-card:hover{transform:translateY(-2px);box-shadow:var(--shadow-md);}
.kpi-card::before{
  content:'';position:absolute;top:0;left:0;right:0;height:3px;
  border-radius:var(--radius) var(--radius) 0 0;
}
.kpi-card.blue::before{background:var(--info);}
.kpi-card.green::before{background:var(--success);}
.kpi-card.purple::before{background:var(--purple);}
.kpi-card.amber::before{background:var(--warning);}
.kpi-card.red::before{background:var(--danger);}
.kpi-card.cyan::before{background:var(--cyan);}
.kpi-card.rose::before{background:var(--rose);}
.kpi-card.teal::before{background:var(--teal);}
.kpi-card.indigo::before{background:var(--primary);}
.kpi-card.slate::before{background:#475569;}
.kpi-card.pink::before{background:#ec4899;}
.kpi-header{display:flex;align-items:center;justify-content:space-between;}
.kpi-icon{
  width:40px;height:40px;border-radius:10px;
  display:flex;align-items:center;justify-content:center;font-size:17px;
}
.kpi-icon.blue  {background:var(--info-light);   color:var(--info);}
.kpi-icon.green {background:var(--success-light); color:var(--success);}
.kpi-icon.purple{background:var(--purple-light);  color:var(--purple);}
.kpi-icon.amber {background:var(--warning-light); color:var(--warning);}
.kpi-icon.red   {background:var(--danger-light);  color:var(--danger);}
.kpi-icon.cyan  {background:var(--cyan-light);    color:var(--cyan);}
.kpi-icon.rose  {background:var(--rose-light);    color:var(--rose);}
.kpi-icon.teal  {background:var(--teal-light);    color:var(--teal);}
.kpi-icon.indigo{background:#e0e7ff;              color:var(--primary);}
.kpi-icon.slate {background:#f1f5f9;              color:#475569;}
.kpi-icon.pink  {background:#fce7f3;              color:#ec4899;}
.kpi-label{font-size:11px;font-weight:600;color:var(--text-secondary);text-transform:uppercase;letter-spacing:.04em;}
.kpi-value{font-size:26px;font-weight:800;color:var(--text-primary);line-height:1;}
.kpi-trend{font-size:11px;margin-top:2px;}
.trend-up{color:var(--success);}
.trend-dn{color:var(--danger);}
.trend-eq{color:var(--text-muted);}

/* ── Cards & Charts ── */
.card{
  background:var(--card-bg);border:1px solid var(--border);
  border-radius:var(--radius);box-shadow:var(--shadow);padding:20px;
}
.card-header{
  display:flex;align-items:center;justify-content:space-between;
  margin-bottom:16px;flex-wrap:wrap;gap:8px;
}
.card-title{font-size:14px;font-weight:700;color:var(--text-primary);}
.card-sub{font-size:12px;color:var(--text-secondary);margin-top:2px;}
.chart-wrap{position:relative;width:100%;}
.chart-wrap canvas{width:100%!important;}

.g2{display:grid;grid-template-columns:1fr 1fr;gap:16px;margin-bottom:24px;}
.g3{display:grid;grid-template-columns:1fr 1fr 1fr;gap:16px;margin-bottom:24px;}
.g21{display:grid;grid-template-columns:2fr 1fr;gap:16px;margin-bottom:24px;}
.g12{display:grid;grid-template-columns:1fr 2fr;gap:16px;margin-bottom:24px;}

/* ── Teachers list ── */
.teacher-item{
  display:flex;align-items:center;gap:12px;
  padding:10px 0;border-bottom:1px solid var(--border);
}
.teacher-item:last-child{border-bottom:none;}
.teacher-avatar{
  width:40px;height:40px;border-radius:50%;object-fit:cover;
  background:var(--primary-light);color:var(--primary);
  display:flex;align-items:center;justify-content:center;
  font-size:15px;font-weight:700;flex-shrink:0;overflow:hidden;
}
.teacher-avatar img{width:100%;height:100%;object-fit:cover;border-radius:50%;}
.teacher-name{font-size:13px;font-weight:600;color:var(--text-primary);}
.teacher-role{font-size:11px;color:var(--text-secondary);}
.teacher-meta{margin-left:auto;text-align:right;}
.teacher-meta .val{font-size:13px;font-weight:700;color:var(--primary);}
.teacher-meta .lbl{font-size:10px;color:var(--text-muted);}

/* ── Notification items ── */
.notif-item{
  display:flex;align-items:flex-start;gap:10px;
  padding:10px 0;border-bottom:1px solid var(--border);
}
.notif-item:last-child{border-bottom:none;}
.notif-dot{
  width:32px;height:32px;border-radius:8px;flex-shrink:0;
  display:flex;align-items:center;justify-content:center;font-size:13px;
}
.notif-dot.assignment{background:var(--warning-light);color:var(--warning);}
.notif-dot.quiz      {background:var(--purple-light); color:var(--purple);}
.notif-dot.general   {background:var(--info-light);   color:var(--info);}
.notif-dot.alert     {background:var(--danger-light); color:var(--danger);}
.notif-msg{font-size:12px;color:var(--text-primary);line-height:1.5;}
.notif-time{font-size:10px;color:var(--text-muted);margin-top:2px;}
.notif-read{margin-left:auto;}
.badge-read{
  font-size:10px;padding:2px 8px;border-radius:99px;font-weight:600;
  background:var(--success-light);color:#065f46;
}
.badge-unread{
  font-size:10px;padding:2px 8px;border-radius:99px;font-weight:600;
  background:var(--danger-light);color:#991b1b;
}

/* ── Event chips ── */
.event-item{
  display:flex;align-items:center;gap:10px;
  padding:8px 0;border-bottom:1px solid var(--border);
}
.event-item:last-child{border-bottom:none;}
.event-date{
  min-width:44px;text-align:center;
  background:var(--primary-light);color:var(--primary);
  border-radius:8px;padding:6px 4px;
}
.event-date .day{font-size:16px;font-weight:800;line-height:1;}
.event-date .mon{font-size:10px;font-weight:500;}
.event-title{font-size:13px;font-weight:600;color:var(--text-primary);}
.event-type{font-size:11px;color:var(--text-secondary);}

/* ── Responsive ── */
@media(max-width:1024px){
  .g3,.g2,.g21,.g12{grid-template-columns:1fr;}
}
@media(max-width:640px){
  .kpi-grid{grid-template-columns:1fr 1fr;}
  .top-bar{flex-direction:column;align-items:flex-start;}
}
</style>
</asp:Content>

<asp:Content ID="cBody" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

<!-- ══ Hidden fields for chart data ══ -->
<asp:HiddenField ID="hdnDailyAttDays"    runat="server"/>
<asp:HiddenField ID="hdnDailyAttPresent" runat="server"/>
<asp:HiddenField ID="hdnDailyAttAbsent"  runat="server"/>
<asp:HiddenField ID="hdnDailyAttPct"     runat="server"/>
<asp:HiddenField ID="hdnVideoWeeks"      runat="server"/>
<asp:HiddenField ID="hdnVideoViews"      runat="server"/>
<asp:HiddenField ID="hdnVideoCompleted"  runat="server"/>
<asp:HiddenField ID="hdnAssignSubjects"  runat="server"/>
<asp:HiddenField ID="hdnAssignTotal"     runat="server"/>
<asp:HiddenField ID="hdnAssignSub"       runat="server"/>
<asp:HiddenField ID="hdnQuizSubjects"    runat="server"/>
<asp:HiddenField ID="hdnQuizAvgScore"    runat="server"/>
<asp:HiddenField ID="hdnQuizPassRate"    runat="server"/>
<asp:HiddenField ID="hdnStreamLabels"    runat="server"/>
<asp:HiddenField ID="hdnStreamAtt"       runat="server"/>
<asp:HiddenField ID="hdnTrendMonths"     runat="server"/>
<asp:HiddenField ID="hdnTrendStudents"   runat="server"/>
<asp:HiddenField ID="hdnTrendAtt"        runat="server"/>
<asp:HiddenField ID="hdnTrendViews"      runat="server"/>
<asp:HiddenField ID="hdnBannerPath"      runat="server"/>

<div class="dash-wrap">

  <!-- Alert -->
  <asp:Panel ID="pnlAlert" runat="server" Visible="false" CssClass="dash-alert">
      <i class="fa fa-circle-info"></i>
      <asp:Label ID="lblAlert" runat="server"/>
  </asp:Panel>

  <!-- ══ TOP BAR ══ -->
  <div class="top-bar">
      <div>
          <h1><i class="fa fa-chart-line" style="color:var(--primary);margin-right:8px;"></i>
              Monthly Analytics — <span><asp:Label ID="lblSelectedPeriod" runat="server"/></span>
          </h1>
          <div style="font-size:13px;color:var(--text-secondary);margin-top:3px;">
              Detailed breakdown of institution activity for selected month
          </div>
      </div>
      <div class="filter-row">
          <asp:DropDownList ID="ddlMonth" runat="server" CssClass=""/>
          <asp:DropDownList ID="ddlYear"  runat="server" CssClass=""/>
          <asp:Button ID="btnFilter" runat="server" Text="Apply Filter"
              CssClass="btn-filter" OnClick="btnFilter_Click"/>
          <span class="period-badge">
              <i class="fa fa-calendar-check"></i>
              <asp:Label ID="lblSelectedPeriod2" runat="server"/>
          </span>
      </div>
  </div>

  <!-- ══ BANNER / IMAGE UPLOAD SECTION ══ -->
  <div class="banner-section">
      <div class="banner-inner" id="bannerInner">
          <!-- Background image (shown after upload) -->
          <asp:Image ID="imgBannerPreview" runat="server" Visible="false"
              CssClass="banner-bg-img" AlternateText="Monthly Banner"/>
          <div class="banner-overlay" id="bannerOverlay" style="display:none;"></div>

          <div class="banner-text">
              <h2><i class="fa fa-chart-bar" style="margin-right:8px;"></i>
                  Monthly Analytics Report</h2>
              <p>Upload a banner image to personalise this dashboard for
                 <asp:Label ID="lblBannerPeriod" runat="server" Text="this month"/></p>
          </div>

          <div class="banner-actions">
              <!-- Upload area -->
              <div class="upload-area" onclick="document.getElementById('fuBannerInput').click();">
                  <i class="fa fa-cloud-arrow-up"></i>
                  <span>Click to upload banner<br/><small style="opacity:.7;">JPG, PNG, WebP · Max 5MB</small></span>
                  <asp:FileUpload ID="fuBanner" runat="server" Style="display:none;" CssClass="d-none"/>
                  <input type="file" id="fuBannerInput" accept="image/*" style="display:none;"
                         onchange="syncFileUpload(this)"/>
              </div>
              <div style="display:flex;flex-direction:column;gap:8px;">
                  <asp:Button ID="btnUploadBanner" runat="server" Text="⬆ Upload"
                      CssClass="btn-upload" OnClick="btnUploadBanner_Click"
                      OnClientClick="return validateBannerFile();"/>
                  <asp:Button ID="btnRemoveBanner" runat="server" Text="✕ Remove"
                      CssClass="btn-remove" OnClick="btnRemoveBanner_Click"/>
              </div>
          </div>
      </div>

      <!-- Upload progress bar (client-side feedback) -->
      <div id="uploadProgress" style="display:none;padding:0 0 4px;">
          <div style="height:4px;background:var(--primary-light);">
              <div id="uploadBar" style="height:4px;background:var(--primary);width:0%;transition:width .3s;border-radius:0 0 4px 4px;"></div>
          </div>
      </div>
  </div>

  <!-- ══ KPI CARDS ══ -->
  <div class="kpi-grid">
      <div class="kpi-card blue">
          <div class="kpi-header">
              <span class="kpi-label">New Students</span>
              <div class="kpi-icon blue"><i class="fa fa-user-plus"></i></div>
          </div>
          <div class="kpi-value"><asp:Label ID="lblNewStudents" runat="server" Text="0"/></div>
          <div class="kpi-trend"><asp:Literal ID="lblStudentTrend" runat="server"/></div>
      </div>
      <div class="kpi-card green">
          <div class="kpi-header">
              <span class="kpi-label">Active Students</span>
              <div class="kpi-icon green"><i class="fa fa-users"></i></div>
          </div>
          <div class="kpi-value"><asp:Label ID="lblTotalActive" runat="server" Text="0"/></div>
          <div class="kpi-trend trend-up"><i class="fa fa-circle-check"></i> Total enrolled</div>
      </div>
      <div class="kpi-card purple">
          <div class="kpi-header">
              <span class="kpi-label">Attendance</span>
              <div class="kpi-icon purple"><i class="fa fa-calendar-check"></i></div>
          </div>
          <div class="kpi-value"><asp:Label ID="lblAttendancePct" runat="server" Text="0%"/></div>
          <div class="kpi-trend"><asp:Literal ID="lblAttTrend" runat="server"/></div>
      </div>
      <div class="kpi-card amber">
          <div class="kpi-header">
              <span class="kpi-label">Assignments</span>
              <div class="kpi-icon amber"><i class="fa fa-clipboard-list"></i></div>
          </div>
          <div class="kpi-value"><asp:Label ID="lblAssignCreated" runat="server" Text="0"/></div>
          <div class="kpi-trend" style="color:var(--text-secondary);">
              <asp:Label ID="lblAssignSub" runat="server" Text="0"/> submissions
          </div>
      </div>
      <div class="kpi-card indigo">
          <div class="kpi-header">
              <span class="kpi-label">Videos Uploaded</span>
              <div class="kpi-icon indigo"><i class="fa fa-video"></i></div>
          </div>
          <div class="kpi-value"><asp:Label ID="lblVideosUploaded" runat="server" Text="0"/></div>
          <div class="kpi-trend" style="color:var(--text-secondary);">
              <asp:Label ID="lblVideoViews" runat="server" Text="0"/> views
          </div>
      </div>
      <div class="kpi-card teal">
          <div class="kpi-header">
              <span class="kpi-label">Quiz Attempts</span>
              <div class="kpi-icon teal"><i class="fa fa-question-circle"></i></div>
          </div>
          <div class="kpi-value"><asp:Label ID="lblQuizAttempts" runat="server" Text="0"/></div>
          <div class="kpi-trend" style="color:var(--text-secondary);">
              Avg score: <asp:Label ID="lblAvgQuizScore" runat="server" Text="0"/>
          </div>
      </div>
      <div class="kpi-card rose">
          <div class="kpi-header">
              <span class="kpi-label">Help Requests</span>
              <div class="kpi-icon rose"><i class="fa fa-life-ring"></i></div>
          </div>
          <div class="kpi-value"><asp:Label ID="lblHelpRequests" runat="server" Text="0"/></div>
      </div>
      <div class="kpi-card cyan">
          <div class="kpi-header">
              <span class="kpi-label">Notifications Sent</span>
              <div class="kpi-icon cyan"><i class="fa fa-bell"></i></div>
          </div>
          <div class="kpi-value"><asp:Label ID="lblNotificationsSent" runat="server" Text="0"/></div>
      </div>
  </div>

  <!-- ══ ROW 1: Daily Attendance Area + Stream Donut ══ -->
  <div class="g21">
      <div class="card">
          <div class="card-header">
              <div>
                  <div class="card-title"><i class="fa fa-calendar-days" style="color:var(--success);margin-right:6px;"></i>Daily Attendance Overview</div>
                  <div class="card-sub">Present vs Absent count per day this month</div>
              </div>
              <span style="font-size:12px;color:var(--text-muted);" id="attSummaryBadge"></span>
          </div>
          <div class="chart-wrap" style="height:240px;">
              <canvas id="chartDailyAtt"></canvas>
          </div>
      </div>
      <div class="card">
          <div class="card-header">
              <div>
                  <div class="card-title"><i class="fa fa-layer-group" style="color:var(--purple);margin-right:6px;"></i>Attendance by Stream</div>
              </div>
          </div>
          <div class="chart-wrap" style="height:200px;">
              <canvas id="chartStreamAtt"></canvas>
          </div>
          <div id="streamLegend" style="margin-top:10px;"></div>
      </div>
  </div>

  <!-- ══ ROW 2: Video Views + Assignment Stats ══ -->
  <div class="g2">
      <div class="card">
          <div class="card-header">
              <div>
                  <div class="card-title"><i class="fa fa-play-circle" style="color:var(--info);margin-right:6px;"></i>Weekly Video Engagement</div>
                  <div class="card-sub">Views and completions per week</div>
              </div>
          </div>
          <div class="chart-wrap" style="height:230px;">
              <canvas id="chartVideoViews"></canvas>
          </div>
      </div>
      <div class="card">
          <div class="card-header">
              <div>
                  <div class="card-title"><i class="fa fa-clipboard-check" style="color:var(--warning);margin-right:6px;"></i>Assignment Submissions by Subject</div>
                  <div class="card-sub">Created vs submitted this month</div>
              </div>
          </div>
          <div class="chart-wrap" style="height:230px;">
              <canvas id="chartAssignments"></canvas>
          </div>
      </div>
  </div>

  <!-- ══ ROW 3: Quiz Performance + 6-month Trend ══ -->
  <div class="g12">
      <div class="card">
          <div class="card-header">
              <div>
                  <div class="card-title"><i class="fa fa-trophy" style="color:var(--warning);margin-right:6px;"></i>Quiz Performance</div>
                  <div class="card-sub">Avg score & pass rate by subject</div>
              </div>
          </div>
          <div class="chart-wrap" style="height:250px;">
              <canvas id="chartQuiz"></canvas>
          </div>
      </div>
      <div class="card">
          <div class="card-header">
              <div>
                  <div class="card-title"><i class="fa fa-arrow-trend-up" style="color:var(--primary);margin-right:6px;"></i>6-Month Trend</div>
                  <div class="card-sub">Students · Attendance · Video Views</div>
              </div>
          </div>
          <div class="chart-wrap" style="height:250px;">
              <canvas id="chartTrend"></canvas>
          </div>
      </div>
  </div>

  <!-- ══ ROW 4: Top Teachers + Notifications + Events ══ -->
  <div class="g3">
      <div class="card">
          <div class="card-header">
              <div class="card-title"><i class="fa fa-star" style="color:var(--warning);margin-right:6px;"></i>Top Active Teachers</div>
          </div>
          <asp:Repeater ID="rptTopTeachers" runat="server">
              <ItemTemplate>
                  <div class="teacher-item">
                      <div class="teacher-avatar">
                        <asp:Image ID="imgTeacher" runat="server"
                            ImageUrl='<%# Eval("ProfileImage") %>'
                            Visible='<%# !string.IsNullOrEmpty(Eval("ProfileImage")?.ToString()) %>' />

                        <asp:Label ID="lblInitial" runat="server"
                            Text='<%# Eval("FullName").ToString().Substring(0,1).ToUpper() %>'
                            Visible='<%# string.IsNullOrEmpty(Eval("ProfileImage")?.ToString()) %>' />
                    </div>
                      <div>
                          <div class="teacher-name"><%# Eval("FullName") %></div>
                          <div class="teacher-role"><%# Eval("Designation") %></div>
                      </div>
                      <div class="teacher-meta">
                          <div class="val"><%# Eval("ActivityCount") %></div>
                          <div class="lbl">Activities</div>
                          <div style="font-size:10px;color:var(--text-muted);margin-top:2px;">
                              <%# Eval("VideosUploaded") %> vids · <%# Eval("AssignmentsCreated") %> assigns
                          </div>
                      </div>
                  </div>
              </ItemTemplate>
          </asp:Repeater>
          <div id="noTeachers" style="display:none;text-align:center;padding:30px;color:var(--text-muted);">
              <i class="fa fa-chalkboard-user" style="font-size:28px;display:block;margin-bottom:8px;"></i>
              No teacher activity this month
          </div>
      </div>

      <div class="card">
          <div class="card-header">
              <div class="card-title"><i class="fa fa-bell" style="color:var(--info);margin-right:6px;"></i>Recent Notifications</div>
          </div>
          <asp:Repeater ID="rptNotifications" runat="server">
              <ItemTemplate>
                  <div class="notif-item">
                      <div class="notif-dot <%# GetNotifClass(Eval("NotificationType")?.ToString()) %>">
                          <i class="<%# GetNotifIcon(Eval("NotificationType")?.ToString()) %>"></i>
                      </div>
                      <div style="flex:1;min-width:0;">
                          <div class="notif-msg"><%# Server.HtmlEncode(Eval("Message")?.ToString()) %></div>
                          <div class="notif-time"><%# Eval("CreatedOn") is DateTime dt ? dt.ToString("dd MMM, hh:mm tt") : "" %></div>
                      </div>
                      <div class="notif-read">
                         <asp:Label runat="server"
                            Text='<%# Convert.ToBoolean(Eval("IsRead")) ? "Read" : "New" %>'
                            CssClass='<%# Convert.ToBoolean(Eval("IsRead")) ? "badge-read" : "badge-unread" %>' />
                      </div>
                  </div>
              </ItemTemplate>
          </asp:Repeater>
      </div>

      <div class="card">
          <div class="card-header">
              <div class="card-title"><i class="fa fa-calendar-days" style="color:var(--rose);margin-right:6px;"></i>Events This Month</div>
          </div>
          <asp:Repeater ID="rptEvents" runat="server">
              <ItemTemplate>
                  <div class="event-item">
                      <div class="event-date">
                          <div class="day"><%# ((DateTime)Eval("StartTime")).Day %></div>
                          <div class="mon"><%# ((DateTime)Eval("StartTime")).ToString("MMM") %></div>
                      </div>
                      <div>
                          <div class="event-title"><%# Eval("Title") %></div>
                          <div class="event-type"><%# Eval("EventType") %>
                              <%# Convert.ToBoolean(Eval("IsAllDay")) ? " · All Day" : " · " + ((DateTime)Eval("StartTime")).ToString("hh:mm tt") %>
                          </div>
                      </div>
                  </div>
              </ItemTemplate>
          </asp:Repeater>
          <div id="noEvents" style="display:none;text-align:center;padding:30px;color:var(--text-muted);">
              <i class="fa fa-calendar-xmark" style="font-size:28px;display:block;margin-bottom:8px;"></i>
              No events scheduled this month
          </div>
      </div>
  </div>

</div><!-- /dash-wrap -->

<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.4.1/chart.umd.min.js"></script>
<script>
(function(){
'use strict';

/* ── helpers ── */
const $ = id => document.getElementById(id);
function hf(id){ try{return JSON.parse($(id).value||'[]');}catch{return[];} }

const PALETTE = ['#4f46e5','#10b981','#f59e0b','#ef4444','#8b5cf6',
                 '#3b82f6','#0d9488','#0891b2','#f43f5e','#ec4899'];
const PALETTE_ALPHA = pct => PALETTE.map(c => c + (pct < 100 ? Math.round(pct/100*255).toString(16).padStart(2,'0') : ''));

const gridColor = 'rgba(148,163,184,.12)';
const tickFont  = { size: 11, family: "'Inter','Segoe UI',sans-serif" };
const baseScales = {
  x: { grid:{display:false}, ticks:{font:tickFont} },
  y: { beginAtZero:true, grid:{color:gridColor}, ticks:{font:tickFont} }
};
const noLegend  = { legend:{display:false} };
const animCfg   = { duration:900, easing:'easeInOutQuart' };

/* ─────────────────────────────────────────
   1. Daily Attendance — stacked bar
───────────────────────────────────────── */
(function(){
  const days    = hf('<%= hdnDailyAttDays.ClientID %>');
  const present = hf('<%= hdnDailyAttPresent.ClientID %>');
  const absent  = hf('<%= hdnDailyAttAbsent.ClientID %>');

  if(!days.length){
      $('chartDailyAtt').parentElement.innerHTML =
          '<div style="text-align:center;padding:60px;color:#94a3b8;"><i class="fa fa-calendar-xmark" style="font-size:32px;display:block;margin-bottom:8px;"></i>No attendance data for this month</div>';
      return;
  }

  new Chart($('chartDailyAtt'),{
      type:'bar',
      data:{
          labels: days,
          datasets:[
              { label:'Present', data:present, backgroundColor:'#10b981', borderRadius:4, stack:'s' },
              { label:'Absent',  data:absent,  backgroundColor:'#ef4444', borderRadius:4, stack:'s' }
          ]
      },
      options:{
          responsive:true, maintainAspectRatio:false,
          interaction:{ mode:'index', intersect:false },
          plugins:{
              legend:{ position:'top', labels:{boxWidth:10,font:tickFont} },
              tooltip:{ callbacks:{ footer: items => {
                  const total = items.reduce((a,b)=>a+b.raw,0);
                  const pct   = total ? Math.round(items[0].raw/total*100) : 0;
                  return `Attendance: ${pct}%`;
              }}}
          },
          scales:{ ...baseScales, x:{...baseScales.x}, y:{...baseScales.y,stacked:true} },
          animation:animCfg
      }
  });

  // Summary badge
  const totalP = present.reduce((a,b)=>a+b,0);
  const totalA = absent.reduce((a,b)=>a+b,0);
  const pct = totalP+totalA ? Math.round(totalP/(totalP+totalA)*100) : 0;
  $('attSummaryBadge').innerHTML =
      `<span style="background:#d1fae5;color:#065f46;padding:4px 10px;border-radius:99px;font-weight:600;">${pct}% avg</span>`;
})();

/* ─────────────────────────────────────────
   2. Stream Attendance — horizontal bar
───────────────────────────────────────── */
(function(){
  const labels = hf('<%= hdnStreamLabels.ClientID %>');
  const vals   = hf('<%= hdnStreamAtt.ClientID %>');
  if(!labels.length) return;

  new Chart($('chartStreamAtt'),{
      type:'doughnut',
      data:{
          labels,
          datasets:[{ data:vals, backgroundColor:PALETTE, borderWidth:2, borderColor:'#fff' }]
      },
      options:{
          cutout:'60%',
          plugins:{
              legend:{ display:false },
              tooltip:{ callbacks:{ label: ctx=>`${ctx.label}: ${ctx.raw}%` }}
          },
          animation:{ animateRotate:true, duration:1000 }
      }
  });

  // Custom legend
  const leg = $('streamLegend');
  labels.forEach((l,i)=>{
      leg.innerHTML += `<div style="display:flex;align-items:center;gap:6px;margin-bottom:5px;">
          <span style="width:10px;height:10px;border-radius:2px;background:${PALETTE[i]};flex-shrink:0;display:inline-block;"></span>
          <span style="font-size:12px;flex:1;">${l}</span>
          <span style="font-size:12px;font-weight:700;color:${PALETTE[i]};">${vals[i]}%</span>
      </div>`;
  });
})();

/* ─────────────────────────────────────────
   3. Video Views — grouped bar
───────────────────────────────────────── */
(function(){
  const weeks     = hf('<%= hdnVideoWeeks.ClientID %>');
  const views     = hf('<%= hdnVideoViews.ClientID %>');
  const completed = hf('<%= hdnVideoCompleted.ClientID %>');

  if(!weeks.length){
      $('chartVideoViews').parentElement.innerHTML =
          '<div style="text-align:center;padding:60px;color:#94a3b8;"><i class="fa fa-video" style="font-size:32px;display:block;margin-bottom:8px;"></i>No video data this month</div>';
      return;
  }

  new Chart($('chartVideoViews'),{
      type:'bar',
      data:{
          labels: weeks,
          datasets:[
              { label:'Total Views',  data:views,     backgroundColor:'#3b82f6', borderRadius:6 },
              { label:'Completed',    data:completed, backgroundColor:'#10b981', borderRadius:6 }
          ]
      },
      options:{
          responsive:true, maintainAspectRatio:false,
          plugins:{ legend:{ position:'top', labels:{boxWidth:10,font:tickFont} } },
          scales:{ ...baseScales },
          animation:animCfg
      }
  });
})();

/* ─────────────────────────────────────────
   4. Assignment Submissions — grouped bar
───────────────────────────────────────── */
(function(){
  const subjects = hf('<%= hdnAssignSubjects.ClientID %>');
  const total    = hf('<%= hdnAssignTotal.ClientID %>');
  const subs     = hf('<%= hdnAssignSub.ClientID %>');

  if(!subjects.length) return;

  new Chart($('chartAssignments'),{
      type:'bar',
      data:{
          labels: subjects,
          datasets:[
              { label:'Assigned', data:total, backgroundColor:'#f59e0b', borderRadius:6 },
              { label:'Submitted', data:subs, backgroundColor:'#10b981', borderRadius:6 }
          ]
      },
      options:{
          responsive:true, maintainAspectRatio:false,
          plugins:{ legend:{ position:'top', labels:{boxWidth:10,font:tickFont} } },
          scales:{
              x:{ grid:{display:false}, ticks:{font:{size:10}} },
              y:{ beginAtZero:true, grid:{color:gridColor}, ticks:{font:tickFont} }
          },
          animation:animCfg
      }
  });
})();

/* ─────────────────────────────────────────
   5. Quiz Performance — mixed bar + line
───────────────────────────────────────── */
(function(){
  const subjects  = hf('<%= hdnQuizSubjects.ClientID %>');
  const avgScore  = hf('<%= hdnQuizAvgScore.ClientID %>');
  const passRate  = hf('<%= hdnQuizPassRate.ClientID %>');

  if(!subjects.length) return;

  new Chart($('chartQuiz'),{
      type:'bar',
      data:{
          labels: subjects,
          datasets:[
              { label:'Avg Score', data:avgScore, backgroundColor:'#8b5cf6', borderRadius:6, yAxisID:'y' },
              { label:'Pass Rate %', data:passRate, type:'line', borderColor:'#f59e0b',
                backgroundColor:'rgba(245,158,11,.12)', borderWidth:2.5, tension:.4, fill:true,
                pointRadius:4, pointBackgroundColor:'#f59e0b', yAxisID:'y1' }
          ]
      },
      options:{
          responsive:true, maintainAspectRatio:false,
          interaction:{ mode:'index', intersect:false },
          plugins:{ legend:{ position:'top', labels:{boxWidth:10,font:tickFont} } },
          scales:{
              x:{ grid:{display:false}, ticks:{font:{size:10}} },
              y: { position:'left', beginAtZero:true, grid:{color:gridColor}, ticks:{font:tickFont} },
              y1:{ position:'right', beginAtZero:true, max:100, grid:{display:false},
                   ticks:{font:tickFont, callback:v=>v+'%'} }
          },
          animation:animCfg
      }
  });
})();

/* ─────────────────────────────────────────
   6. 6-Month Trend — multi-line
───────────────────────────────────────── */
(function(){
  const months   = hf('<%= hdnTrendMonths.ClientID %>');
  const students = hf('<%= hdnTrendStudents.ClientID %>');
  const att      = hf('<%= hdnTrendAtt.ClientID %>');
  const vviews   = hf('<%= hdnTrendViews.ClientID %>');

  if(!months.length) return;

  new Chart($('chartTrend'),{
      type:'line',
      data:{
          labels: months,
          datasets:[
              { label:'New Students', data:students, borderColor:'#4f46e5', backgroundColor:'rgba(79,70,229,.08)',
                borderWidth:2.5, tension:.4, fill:true, pointRadius:4, pointBackgroundColor:'#4f46e5', yAxisID:'y' },
              { label:'Attendance %', data:att, borderColor:'#10b981', backgroundColor:'rgba(16,185,129,.08)',
                borderWidth:2.5, tension:.4, fill:true, pointRadius:4, pointBackgroundColor:'#10b981', yAxisID:'y1' },
              { label:'Video Views', data:vviews, borderColor:'#f59e0b', backgroundColor:'rgba(245,158,11,.08)',
                borderWidth:2.5, tension:.4, fill:false, pointRadius:4, pointBackgroundColor:'#f59e0b', yAxisID:'y' }
          ]
      },
      options:{
          responsive:true, maintainAspectRatio:false,
          interaction:{ mode:'index', intersect:false },
          plugins:{ legend:{ position:'top', labels:{boxWidth:10,font:tickFont} } },
          scales:{
              x:{ grid:{display:false}, ticks:{font:tickFont} },
              y: { position:'left',  beginAtZero:true, grid:{color:gridColor}, ticks:{font:tickFont} },
              y1:{ position:'right', beginAtZero:true, max:100, grid:{display:false},
                   ticks:{font:tickFont, callback:v=>v+'%'} }
          },
          animation:animCfg
      }
  });
})();

/* ── Banner upload UX ── */
function syncFileUpload(input){
  if(!input.files || !input.files[0]) return;
  // Copy file to ASP.NET file upload control (workaround)
  const fuReal = document.getElementById('<%= fuBanner.ClientID %>');
  // We can't programmatically set files on an ASP FileUpload,
  // so show a filename preview and let user click Upload
  const name = input.files[0].name;
  const size = (input.files[0].size/1024/1024).toFixed(2);
  document.querySelector('.upload-area span').innerHTML =
      `<strong>${name}</strong><br/><small>${size} MB selected — click Upload ⬆</small>`;

  // Preview locally
  const reader = new FileReader();
  reader.onload = e => {
      const img = document.getElementById('<%= imgBannerPreview.ClientID %>');
      img.src = e.target.result;
      img.style.display = 'block';
      document.getElementById('bannerOverlay').style.display = 'block';
  };
  reader.readAsDataURL(input.files[0]);
}
window.syncFileUpload = syncFileUpload;

function validateBannerFile(){
  const fu = document.getElementById('fuBannerInput');
  if(!fu.files || !fu.files[0]){
      // copy from hidden input if needed
  }
  return true;
}
window.validateBannerFile = validateBannerFile;

/* ── Empty state guards ── */
document.querySelectorAll('[id$="rptTopTeachers"]').forEach(()=>{});
(function(){
  const tItems = document.querySelectorAll('.teacher-item');
  if(!tItems.length) $('noTeachers') && ($('noTeachers').style.display='block');
  const eItems = document.querySelectorAll('.event-item');
  if(!eItems.length) $('noEvents') && ($('noEvents').style.display='block');
})();

})();
</script>
</asp:Content>
