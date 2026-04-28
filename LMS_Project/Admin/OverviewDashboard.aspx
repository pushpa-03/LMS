<%@ Page Title="Overview Dashboard" Language="C#" MasterPageFile="~/Admin/AdminMaster.Master" AutoEventWireup="true" CodeBehind="OverviewDashboard.aspx.cs" Inherits="LMS_Project.Admin.OverviewDashboard" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

    <%-- Hidden fields to pass JSON data from code-behind to JS --%>
        <asp:HiddenField ID="hdnMonthlyGrowth" runat="server" />
        <asp:HiddenField ID="hdnTopCourses"    runat="server" />
        <asp:HiddenField ID="hdnTopSubjects"   runat="server" />
        <asp:HiddenField ID="hdnStreamData"    runat="server" />

<!-- ═══════════════════════════════════════════════════════
     EXTERNAL DEPENDENCIES
     ═══════════════════════════════════════════════════════ -->
<link  href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.2/css/bootstrap.min.css"    rel="stylesheet"/>
<link  href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css"       rel="stylesheet"/>
<link  href="https://fonts.googleapis.com/css2?family=Nunito:wght@400;600;700;800;900&family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet"/>
<script src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.2/js/bootstrap.bundle.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.4.1/chart.umd.min.js"></script>

<!-- ═══════════════════════════════════════════════════════
     PAGE STYLES
     ═══════════════════════════════════════════════════════ -->
<style>
/* ── Root tokens ── */
:root {
    --brand-1: #6366f1;   /* indigo  */
    --brand-2: #8b5cf6;   /* violet  */
    --brand-3: #06b6d4;   /* cyan    */
    --brand-4: #10b981;   /* emerald */
    --brand-5: #f59e0b;   /* amber   */
    --brand-6: #ef4444;   /* red     */
    --brand-7: #ec4899;   /* pink    */
    --brand-8: #3b82f6;   /* blue    */
    --bg-page: #f1f5fb;
    --bg-card: #ffffff;
    --text-main: #1e293b;
    --text-muted: #64748b;
    --radius: 16px;
    --shadow: 0 4px 24px rgba(99,102,241,.10);
    --shadow-hover: 0 8px 32px rgba(99,102,241,.20);
    --transition: .28s cubic-bezier(.4,0,.2,1);
}

/* ── Page wrapper ── */
body { background: var(--bg-page); font-family: 'Nunito', sans-serif; }

.lms-page { padding: 28px 20px 60px; }

/* ── Page header ── */
.page-header { margin-bottom: 28px; }
.page-header h2 {
    font-family: 'Poppins', sans-serif;
    font-weight: 700; font-size: 1.65rem;
    color: var(--text-main);
}
.page-header .breadcrumb { font-size: .82rem; }
.page-header .badge-live {
    display: inline-flex; align-items: center; gap: 6px;
    background: linear-gradient(135deg,#d1fae5,#a7f3d0);
    color: #065f46; font-size: .75rem; font-weight: 700;
    padding: 4px 12px; border-radius: 999px;
}
.page-header .badge-live span {
    width: 8px; height: 8px; background: #10b981;
    border-radius: 50%; animation: pulse 1.4s infinite;
}
@keyframes pulse { 0%,100%{opacity:1} 50%{opacity:.3} }

/* ── Stat cards ── */
.stat-card {
    background: var(--bg-card);
    border-radius: var(--radius);
    box-shadow: var(--shadow);
    padding: 20px 22px;
    display: flex; align-items: center; gap: 16px;
    transition: transform var(--transition), box-shadow var(--transition);
    position: relative; overflow: hidden;
}
.stat-card::before {
    content: ''; position: absolute; inset: 0;
    background: linear-gradient(135deg, var(--c1) 0%, var(--c2) 100%);
    opacity: 0; transition: opacity var(--transition);
    border-radius: var(--radius);
}
.stat-card:hover { transform: translateY(-4px); box-shadow: var(--shadow-hover); }
.stat-card:hover::before { opacity: .06; }

.stat-icon {
    width: 54px; height: 54px; border-radius: 14px; flex-shrink: 0;
    display: flex; align-items: center; justify-content: center;
    font-size: 1.35rem; color: #fff;
}
.stat-body { flex: 1; }
.stat-body .stat-label {
    font-size: .76rem; font-weight: 700; text-transform: uppercase;
    letter-spacing: .06em; color: var(--text-muted);
}
.stat-body .stat-value {
    font-family: 'Poppins', sans-serif; font-size: 1.75rem;
    font-weight: 700; color: var(--text-main);
    line-height: 1.1; margin: 2px 0;
}
.stat-body .stat-sub { font-size: .77rem; color: var(--text-muted); }
.stat-trend {
    font-size: .75rem; font-weight: 700; padding: 3px 9px;
    border-radius: 999px;
}
.stat-trend.up   { background:#d1fae5; color:#065f46; }
.stat-trend.down { background:#fee2e2; color:#991b1b; }

/* Individual card accent colours */
.card-students { --c1:#6366f1; --c2:#818cf8; }
.card-students .stat-icon { background: linear-gradient(135deg,#6366f1,#818cf8); }
.card-teachers { --c1:#8b5cf6; --c2:#a78bfa; }
.card-teachers .stat-icon { background: linear-gradient(135deg,#8b5cf6,#a78bfa); }
.card-subjects  { --c1:#06b6d4; --c2:#22d3ee; }
.card-subjects  .stat-icon { background: linear-gradient(135deg,#06b6d4,#22d3ee); }
.card-courses   { --c1:#10b981; --c2:#34d399; }
.card-courses   .stat-icon { background: linear-gradient(135deg,#10b981,#34d399); }
.card-assign    { --c1:#f59e0b; --c2:#fbbf24; }
.card-assign    .stat-icon { background: linear-gradient(135deg,#f59e0b,#fbbf24); }
.card-videos    { --c1:#ef4444; --c2:#f87171; }
.card-videos    .stat-icon { background: linear-gradient(135deg,#ef4444,#f87171); }
.card-quizzes   { --c1:#ec4899; --c2:#f472b6; }
.card-quizzes   .stat-icon { background: linear-gradient(135deg,#ec4899,#f472b6); }
.card-sections  { --c1:#3b82f6; --c2:#60a5fa; }
.card-sections  .stat-icon { background: linear-gradient(135deg,#3b82f6,#60a5fa); }

/* ── Chart cards ── */
.chart-card {
    background: var(--bg-card); border-radius: var(--radius);
    box-shadow: var(--shadow); padding: 22px 24px;
    transition: box-shadow var(--transition);
}
.chart-card:hover { box-shadow: var(--shadow-hover); }
.chart-card .card-title {
    font-family: 'Poppins', sans-serif; font-weight: 600;
    font-size: .95rem; color: var(--text-main); margin-bottom: 4px;
}
.chart-card .card-subtitle {
    font-size: .78rem; color: var(--text-muted); margin-bottom: 18px;
}
.chart-wrap { position: relative; }



/* ── Attendance ring ── */
.attendance-ring-wrap {
    display: flex; align-items: center; justify-content: center;
    flex-direction: column; gap: 4px;
}
.attendance-ring-wrap .att-label {
    font-family: 'Poppins', sans-serif; font-size: 2rem;
    font-weight: 800; color: var(--brand-4); line-height: 1;
}
.attendance-ring-wrap .att-sub { font-size: .78rem; color: var(--text-muted); }

/* ── Activity feed ── */
.activity-feed { list-style: none; padding: 0; margin: 0; }
.activity-feed li {
    display: flex; align-items: flex-start; gap: 12px;
    padding: 10px 0; border-bottom: 1px solid #f1f5f9;
}
.activity-feed li:last-child { border-bottom: none; }
.activity-avatar {
    width: 36px; height: 36px; border-radius: 10px; flex-shrink: 0;
    display: flex; align-items: center; justify-content: center;
    font-size: .85rem; font-weight: 800; color: #fff;
}
.activity-body { flex: 1; }
.activity-body .act-name { font-weight: 700; font-size: .85rem; color: var(--text-main); }
.activity-body .act-type { font-size: .78rem; color: var(--text-muted); }
.activity-body .act-time { font-size: .72rem; color: var(--text-muted); margin-top: 2px; }

/* ── Section title ── */
.section-label {
    font-family: 'Poppins', sans-serif; font-weight: 700;
    font-size: .82rem; letter-spacing: .07em; text-transform: uppercase;
    color: var(--text-muted); margin: 32px 0 14px;
    display: flex; align-items: center; gap: 8px;
}
.section-label::after {
    content: ''; flex: 1; height: 1px; background: #e2e8f0;
}

/* ── Entrance animations ── */
@keyframes fadeUp {
    from { opacity:0; transform: translateY(24px); }
    to   { opacity:1; transform: translateY(0); }
}
.anim { opacity:0; animation: fadeUp .55s ease forwards; }
.anim-1 { animation-delay:.05s }
.anim-2 { animation-delay:.10s }
.anim-3 { animation-delay:.15s }
.anim-4 { animation-delay:.20s }
.anim-5 { animation-delay:.25s }
.anim-6 { animation-delay:.30s }
.anim-7 { animation-delay:.35s }
.anim-8 { animation-delay:.40s }
.anim-9 { animation-delay:.45s }
.anim-10{ animation-delay:.50s }
.anim-11{ animation-delay:.55s }
.anim-12{ animation-delay:.60s }
</style>

<!-- ═══════════════════════════════════════════════════════
     PAGE MARKUP
     ═══════════════════════════════════════════════════════ -->
<div class="lms-page">

    <!-- ── Header ── -->
    <div class="page-header d-flex flex-wrap align-items-start justify-content-between gap-3 anim anim-1">
        <div>
            <h2 class="mb-1">
                <i class="fa-solid fa-chart-pie me-2" style="color:var(--brand-1)"></i>
                Overview Dashboard
            </h2>
            <nav aria-label="breadcrumb">
                <ol class="breadcrumb mb-0">
                    <li class="breadcrumb-item"><a href="#" class="text-decoration-none" style="color:var(--brand-1)">Home</a></li>
                    <li class="breadcrumb-item active">Overview (Yearly)</li>
                </ol>
            </nav>
        </div>
        <div class="d-flex align-items-center gap-2">
            <span class="badge-live"><span></span>Live Data</span>
            <button class="btn btn-sm" style="background:var(--brand-1);color:#fff;border-radius:10px;"
                    onclick="location.reload()">
                <i class="fa fa-rotate-right me-1"></i>Refresh
            </button>
        </div>

        

    </div>

    <!-- ══════════════════════════════
         ROW 1 — STAT CARDS (10 items)
    ══════════════════════════════ -->
    <div class="row g-3">

        <div class="col-xl-3 col-md-6 anim anim-2">
            <div class="stat-card card-students">
                <div class="stat-icon"><i class="fa-solid fa-user-graduate"></i></div>
                <div class="stat-body">
                    <div class="stat-label">Total Students</div>
                    <div class="stat-value">
                        <asp:Label ID="lblTotalStudents" runat="server" Text="—"></asp:Label>
                    </div>
                    <div class="stat-sub">Active enrollees</div>
                </div>
                <span class="stat-trend up"><i class="fa fa-arrow-up me-1"></i>+12%</span>
            </div>
        </div>

        <div class="col-xl-3 col-md-6 anim anim-3">
            <div class="stat-card card-teachers">
                <div class="stat-icon"><i class="fa-solid fa-chalkboard-user"></i></div>
                <div class="stat-body">
                    <div class="stat-label">Total Teachers</div>
                    <div class="stat-value">
                        <asp:Label ID="lblTotalTeachers" runat="server" Text="—"></asp:Label>
                    </div>
                    <div class="stat-sub">Active faculty</div>
                </div>
                <span class="stat-trend up"><i class="fa fa-arrow-up me-1"></i>+4%</span>
            </div>
        </div>

        <div class="col-xl-3 col-md-6 anim anim-4">
            <div class="stat-card" style="--c1:#14b8a6;--c2:#2dd4bf;">
                <div class="stat-icon" style="background:linear-gradient(135deg,#14b8a6,#2dd4bf)">
                    <i class="fa-solid fa-layer-group"></i>
                </div>
                <div class="stat-body">
                    <div class="stat-label">Streams</div>
                    <div class="stat-value">
                        <asp:Label ID="lblTotalStreams" runat="server" Text="—"></asp:Label>
                    </div>
                    <div class="stat-sub">Available streams</div>
                </div>
            </div>
        </div>

        <div class="col-xl-3 col-md-6 anim anim-5">
            <div class="stat-card card-courses">
                <div class="stat-icon"><i class="fa-solid fa-layer-group"></i></div>
                <div class="stat-body">
                    <div class="stat-label">Total Courses</div>
                    <div class="stat-value">
                        <asp:Label ID="lblTotalCourses" runat="server" Text="—"></asp:Label>
                    </div>
                    <div class="stat-sub">This session</div>
                </div>
                <span class="stat-trend up"><i class="fa fa-arrow-up me-1"></i>+6%</span>
            </div>
        </div>

        <div class="col-xl-3 col-md-6 anim anim-4">
            <div class="stat-card card-subjects">
                <div class="stat-icon"><i class="fa-solid fa-book-open"></i></div>
                <div class="stat-body">
                    <div class="stat-label">Total Subjects</div>
                    <div class="stat-value">
                        <asp:Label ID="lblTotalSubjects" runat="server" Text="—"></asp:Label>
                    </div>
                    <div class="stat-sub">This session</div>
                </div>
                <span class="stat-trend up"><i class="fa fa-arrow-up me-1"></i>+8%</span>
            </div>
        </div>

        <div class="col-xl-3 col-md-6 anim anim-5">
            <div class="stat-card" style="--c1:#f97316;--c2:#fb923c;">
                <div class="stat-icon" style="background:linear-gradient(135deg,#f97316,#fb923c)">
                    <i class="fa-solid fa-book"></i>
                </div>
                <div class="stat-body">
                    <div class="stat-label">Chapters</div>
                    <div class="stat-value">
                        <asp:Label ID="lblTotalChapters" runat="server" Text="—"></asp:Label>
                    </div>
                    <div class="stat-sub">This session</div>
                </div>
            </div>
        </div>
        

        <div class="col-xl-3 col-md-6 anim anim-6">
            <div class="stat-card card-assign">
                <div class="stat-icon"><i class="fa-solid fa-file-pen"></i></div>
                <div class="stat-body">
                    <div class="stat-label">Assignments</div>
                    <div class="stat-value">
                        <asp:Label ID="lblTotalAssignments" runat="server" Text="—"></asp:Label>
                    </div>
                    <div class="stat-sub">Posted this session</div>
                </div>
                <span class="stat-trend down"><i class="fa fa-arrow-down me-1"></i>-2%</span>
            </div>
        </div>

        <div class="col-xl-3 col-md-6 anim anim-7">
            <div class="stat-card card-videos">
                <div class="stat-icon"><i class="fa-solid fa-clapperboard"></i></div>
                <div class="stat-body">
                    <div class="stat-label">Videos</div>
                    <div class="stat-value">
                        <asp:Label ID="lblTotalVideos" runat="server" Text="—"></asp:Label>
                    </div>
                    <div class="stat-sub">Uploaded this session</div>
                </div>
                <span class="stat-trend up"><i class="fa fa-arrow-up me-1"></i>+18%</span>
            </div>
        </div>

        <div class="col-xl-3 col-md-6 anim anim-8">
            <div class="stat-card card-quizzes">
                <div class="stat-icon"><i class="fa-solid fa-circle-question"></i></div>
                <div class="stat-body">
                    <div class="stat-label">Quizzes</div>
                    <div class="stat-value">
                        <asp:Label ID="lblTotalQuizzes" runat="server" Text="—"></asp:Label>
                    </div>
                    <div class="stat-sub">Enabled this session</div>
                </div>
                <span class="stat-trend up"><i class="fa fa-arrow-up me-1"></i>+5%</span>
            </div>
        </div>

        <div class="col-xl-3 col-md-6 anim anim-9">
            <div class="stat-card card-sections">
                <div class="stat-icon"><i class="fa-solid fa-sitemap"></i></div>
                <div class="stat-body">
                    <div class="stat-label">Sections</div>
                    <div class="stat-value">
                        <asp:Label ID="lblTotalSections" runat="server" Text="—"></asp:Label>
                    </div>
                    <div class="stat-sub">Active this session</div>
                </div>
                <span class="stat-trend up"><i class="fa fa-arrow-up me-1"></i>+3%</span>
            </div>
        </div>

    </div><!-- /row stats -->

    <!-- ══════════════════════════════
         ROW 2 — CHARTS
    ══════════════════════════════ -->
    <div class="section-label anim anim-9">
        <i class="fa-solid fa-chart-line" style="color:var(--brand-1)"></i>
        Analytics &amp; Charts
    </div>

    <div class="row g-3">

        <!-- Monthly Student Growth (Line) -->
        <div class="col-xl-8 col-lg-7 anim anim-9">
            <div class="chart-card h-100">
                <div class="card-title"><i class="fa-solid fa-chart-line me-2" style="color:var(--brand-1)"></i>Monthly Student Growth</div>
                <div class="card-subtitle">New student registrations per month this year</div>
                <div class="chart-wrap" style="height:280px;">
                    <canvas id="chartGrowth" ></canvas>
                </div>
            </div>
        </div>

        <!-- Attendance Donut -->
        <div class="col-xl-4 col-lg-5 anim anim-10">
            <div class="chart-card h-100 d-flex flex-column">
                <div class="card-title"><i class="fa-solid fa-circle-check me-2" style="color:var(--brand-4)"></i>Overall Attendance</div>
                <div class="card-subtitle">Session-wide attendance rate</div>
                <div class="chart-wrap flex-grow-1 d-flex align-items-center justify-content-center" style="min-height:220px;">
                    <div style="position:relative;width:200px;height:200px;">
                        <canvas id="chartAttendance"></canvas>
                        <div style="position:absolute;inset:0;display:flex;flex-direction:column;align-items:center;justify-content:center;pointer-events:none;">
                            <div class="att-label">
                                <asp:Label ID="lblAttendance" runat="server" Text="—"></asp:Label>
                            </div>
                            <div class="att-sub">Attendance</div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Top Courses (Horizontal Bar) -->
        <div class="col-xl-6 anim anim-10">
            <div class="chart-card h-100">
                <div class="card-title"><i class="fa-solid fa-ranking-star me-2" style="color:var(--brand-5)"></i>Top Courses by Students</div>
                <div class="card-subtitle">Top 5 most enrolled courses</div>
                <div class="chart-wrap" style="height:260px;">
                    <canvas id="chartTopCourses"></canvas>
                </div>
            </div>
        </div>

        <!-- Stream-Wise (Doughnut) -->
        <div class="col-xl-3 col-sm-6 anim anim-11">
            <div class="chart-card h-100">
                <div class="card-title"><i class="fa-solid fa-chart-pie me-2" style="color:var(--brand-7)"></i>Stream-Wise Students</div>
                <div class="card-subtitle">Distribution by stream</div>
                <div class="chart-wrap" style="height:260px;">
                    <canvas id="chartStream"></canvas>
                </div>
            </div>
        </div>

        <!-- Top Subjects by Video (Polar) -->
        <div class="col-xl-3 col-sm-6 anim anim-11">
            <div class="chart-card h-100">
                <div class="card-title"><i class="fa-solid fa-video me-2" style="color:var(--brand-6)"></i>Top Subjects by Video</div>
                <div class="card-subtitle">Top 5 subjects with most videos</div>
                <div class="chart-wrap" style="height:260px;">
                    <canvas id="chartSubjectVideos"></canvas>
                </div>
            </div>
        </div>

    </div><!-- /row charts -->



    <!-- ══════════════════════════════
         ROW 3 — RECENT ACTIVITY
    ══════════════════════════════ -->
    <div class="section-label anim anim-12">
        <i class="fa-solid fa-bolt" style="color:var(--brand-5)"></i>
        Recent Activity
    </div>

    <div class="row g-3 anim anim-12">
        <div class="col-lg-8">
            <div class="chart-card">
                <div class="card-title mb-3"><i class="fa-solid fa-clock-rotate-left me-2" style="color:var(--brand-3)"></i>Latest Actions</div>
                <ul class="activity-feed">
                    <asp:Repeater ID="rptRecentActivity" runat="server">
                        <ItemTemplate>
                            <li>
                                <div class="activity-avatar"
                                     style="background:<%# GetAvatarColor(Container.ItemIndex) %>">
                                    <%# GetInitials(Eval("FullName").ToString()) %>
                                </div>
                                <div class="activity-body">
                                    <div class="act-name"><%# Eval("FullName") %></div>
                                    <div class="act-type">
                                        <i class="<%# GetActivityIcon(Eval("ActivityType").ToString()) %> me-1"></i>
                                        <%# Eval("ActivityType") %>
                                    </div>
                                    <div class="act-time">
                                        <i class="fa fa-clock me-1"></i>
                                        <%# FormatTime(Eval("ActionTime")) %>
                                    </div>
                                </div>
                            </li>
                        </ItemTemplate>
                        <FooterTemplate>
                            <asp:Panel runat="server" Visible='<%# rptRecentActivity.Items.Count == 0 %>'>
                                <li class="text-center py-4 text-muted" style="border:none;">
                                    <i class="fa fa-inbox fa-2x mb-2 d-block"></i>No recent activity found.
                                </li>
                            </asp:Panel>
                        </FooterTemplate>
                    </asp:Repeater>
                </ul>
            </div>
        </div>

        <!-- Quick stats sidebar -->
        <div class="col-lg-4">
            <div class="chart-card h-100">
                <div class="card-title mb-3"><i class="fa-solid fa-gauge-high me-2" style="color:var(--brand-2)"></i>Quick Summary</div>
                <div class="d-flex flex-column gap-3">
                    <div class="d-flex align-items-center justify-content-between p-3 rounded-3" style="background:#f8f5ff;">
                        <div>
                            <div class="fw-700" style="color:#6366f1;font-size:.85rem;">Students</div>
                            <div class="fw-800 fs-5" style="color:#1e293b;">
                                <asp:Label ID="lblTotalStudents2" runat="server" Text="—"></asp:Label>
                            </div>
                        </div>
                        <i class="fa-solid fa-user-graduate fa-2x" style="color:#6366f1;opacity:.35"></i>
                    </div>
                    <div class="d-flex align-items-center justify-content-between p-3 rounded-3" style="background:#f0fdf4;">
                        <div>
                            <div class="fw-700" style="color:#10b981;font-size:.85rem;">Attendance Rate</div>
                            <div class="fw-800 fs-5" style="color:#1e293b;">
                                <asp:Label ID="lblAttendance2" runat="server" Text="—"></asp:Label>
                            </div>
                        </div>
                        <i class="fa-solid fa-circle-check fa-2x" style="color:#10b981;opacity:.35"></i>
                    </div>
                    <div class="d-flex align-items-center justify-content-between p-3 rounded-3" style="background:#fff7ed;">
                        <div>
                            <div class="fw-700" style="color:#f59e0b;font-size:.85rem;">Assignments</div>
                            <div class="fw-800 fs-5" style="color:#1e293b;">
                                <asp:Label ID="lblTotalAssignments2" runat="server" Text="—"></asp:Label>
                            </div>
                        </div>
                        <i class="fa-solid fa-file-pen fa-2x" style="color:#f59e0b;opacity:.35"></i>
                    </div>
                    <div class="d-flex align-items-center justify-content-between p-3 rounded-3" style="background:#fdf2f8;">
                        <div>
                            <div class="fw-700" style="color:#ec4899;font-size:.85rem;">Quizzes</div>
                            <div class="fw-800 fs-5" style="color:#1e293b;">
                                <asp:Label ID="lblTotalQuizzes2" runat="server" Text="—"></asp:Label>
                            </div>
                        </div>
                        <i class="fa-solid fa-circle-question fa-2x" style="color:#ec4899;opacity:.35"></i>
                    </div>
                </div>
            </div>
        </div>
    </div><!-- /row activity -->

</div><!-- /lms-page -->

<!-- ═══════════════════════════════════════════════════════
     CHART INITIALISATION
     ═══════════════════════════════════════════════════════ -->
<script>
(function () {
    /* ── helpers ── */
    function safeJson(id) {
        var el = document.getElementById(id);
        try { return JSON.parse(el ? el.value : '[]') || []; }
        catch(e) { return []; }
    }
    function labels(arr)  { return arr.map(function(d){ return d.label; }); }
    function values(arr)  { return arr.map(function(d){ return d.value; }); }

    var PALETTE = ['#6366f1','#8b5cf6','#06b6d4','#10b981','#f59e0b','#ef4444','#ec4899','#3b82f6','#14b8a6','#a855f7'];
    function palette(n)  { return PALETTE.slice(0, n); }

    /* global Chart defaults */
    Chart.defaults.font.family = "'Nunito', sans-serif";
    Chart.defaults.animation   = { duration: 900, easing: 'easeInOutQuart' };

    Chart.defaults.plugins.tooltip = {
        enabled: true,
        backgroundColor: '#111827',
        titleColor: '#fff',
        bodyColor: '#fff',
        padding: 10,
        cornerRadius: 8,
        displayColors: false,
        callbacks: {
            label: function (context) {
                let label = context.label || '';
                let value = context.raw || 0;
                return label + " : " + value;
            }
        }
    };

    Chart.defaults.hover = {
        mode: 'nearest',
        intersect: true
    };


    /* ── 1. Monthly Student Growth (line) ── */
    var growthData = safeJson('<%= hdnMonthlyGrowth.ClientID %>');
    var ctxG = document.getElementById('chartGrowth');
    if (ctxG) {
        new Chart(ctxG, {
            type: 'line',
            data: {
                labels: labels(growthData),
                datasets: [{
                    label: 'New Students',
                    data: values(growthData),
                    borderColor: '#6366f1',
                    backgroundColor: 'rgba(99,102,241,.12)',
                    borderWidth: 3, pointRadius: 5,
                    pointBackgroundColor: '#6366f1',
                    pointBorderColor: '#fff', pointBorderWidth: 2,
                    tension: 0.45, fill: true
                }]
            },
            options: {
                responsive: true, maintainAspectRatio: false,
               
                scales: {
                    y: { beginAtZero: true, grid: { color:'#f1f5f9' },
                         ticks: { color:'#64748b', font:{ size:11 } } },
                    x: { grid: { display:false },
                         ticks: { color:'#64748b', font:{ size:11 } } }
                },

                plugins: {
                    legend: { display: false },
                    tooltip: {
                        callbacks: {
                            label: function (context) {
                                return "New Students : " + context.raw;
                            }
                        }
                    }
                },
                interaction: { mode: 'index', intersect: false },
                hover: { animationDuration: 400 }
            }

            
        });
    }

    /* ── 2. Attendance Doughnut ── */
    var attText = document.getElementById('<%= lblAttendance.ClientID %>');
    var attVal  = attText ? parseFloat(attText.innerText) || 0 : 0;
    var ctxA = document.getElementById('chartAttendance');
    if (ctxA) {
        new Chart(ctxA, {
            type: 'doughnut',
            data: {
                datasets: [{
                    data: [attVal, 100 - attVal],
                    backgroundColor: ['#10b981','#e2e8f0'],
                    borderWidth: 0,
                    hoverOffset: 4
                }]
            },
            options: {
                cutout: '76%', responsive: true, maintainAspectRatio: false,
                //plugins: { legend: { display: false }, tooltip: { enabled: false } }
                plugins: {
                    tooltip: {
                        callbacks: {
                            label: function (context) {
                                return context.raw + "%";
                            }
                        }
                    }
                },
                interaction: {
                    mode: 'nearest',
                    intersect: true
                },
                hover: {
                    animationDuration: 400
                }
            }
        });
    }

    /* ── 3. Top Courses (horizontal bar) ── */
    var coursesData = safeJson('<%= hdnTopCourses.ClientID %>');
    var ctxC = document.getElementById('chartTopCourses');
    if (ctxC) {
        new Chart(ctxC, {
            type: 'bar',
            data: {
                labels: labels(coursesData),
                datasets: [{
                    label: 'Students',
                    data: values(coursesData),
                    backgroundColor: palette(coursesData.length),
                    borderRadius: 8, borderSkipped: false
                }]
            },
            options: {
                indexAxis: 'y', responsive: true, maintainAspectRatio: false,
                scales: {
                    x: { beginAtZero:true, grid:{ color:'#f1f5f9' },
                         ticks:{ color:'#64748b', font:{ size:11 } } },
                    y: { grid:{ display:false },
                         ticks:{ color:'#1e293b', font:{ size:12, weight:'700' } } }
                },

                plugins: {
                    legend: { display: false },
                    tooltip: {
                        callbacks: {
                            label: function (context) {
                                return context.raw + " Students";
                            }
                        }
                    }
                },
                interaction: { mode: 'nearest', intersect: true },
                hover: { animationDuration: 400 }
            }
        });
    }

    /* ── 4. Stream-Wise Doughnut ── */
    var streamData = safeJson('<%= hdnStreamData.ClientID %>');
    var ctxS = document.getElementById('chartStream');
    if (ctxS) {
        new Chart(ctxS, {
            type: 'doughnut',
            data: {
                labels: labels(streamData),
                datasets: [{
                    data: values(streamData),
                    backgroundColor: palette(streamData.length),
                    borderWidth: 2, borderColor: '#fff', hoverOffset: 6
                }]
            },
            options: {
                cutout: '58%',
                responsive: true,
                maintainAspectRatio: false,

                interaction: {
                    mode: 'nearest',
                    intersect: true
                },

                plugins: {
                    legend: {
                        position: 'bottom',
                        labels: { boxWidth: 12, font: { size: 11 }, color: '#64748b' }
                    },
                    tooltip: {
                        callbacks: {
                            label: function (context) {
                                let label = context.label;
                                let value = context.raw;
                                return label + " : " + value + " Students";
                            }
                        }
                    }
                },

                hover: {
                    animationDuration: 400
                },

                elements: {
                    arc: {
                        hoverOffset: 12
                    },
                    bar: {
                        borderRadius: 10
                    }
                }
            }
        });
    }

    /* ── 5. Top Subjects by Video (PolarArea) ── */
    var subjectData = safeJson('<%= hdnTopSubjects.ClientID %>');
    var ctxSV = document.getElementById('chartSubjectVideos');
    if (ctxSV) {
        new Chart(ctxSV, {
            type: 'polarArea',
            data: {
                labels: labels(subjectData),
                datasets: [{
                    data: values(subjectData),
                    backgroundColor: palette(subjectData.length).map(function(c){ return c+'cc'; }),
                    borderColor: palette(subjectData.length),
                    borderWidth: 2
                }]
            },
            options: {
                responsive: true, maintainAspectRatio: false,
                scales: { r: { grid:{ color:'#f1f5f9' }, ticks:{ display:false } } },
               
                //plugins: {
                //    legend: {
                //        position: 'bottom',
                //        labels: { boxWidth: 12, font: { size: 11 }, color: '#64748b' }
                //    }
                //}
               plugins: {
                    legend: { position: 'bottom' },
                    tooltip: {
                        callbacks: {
                            label: function (context) {
                                return context.label + " : " + context.raw + " Videos";
                            }
                        }
                    }
                },
                interaction: { mode: 'nearest', intersect: true },
                hover: { animationDuration: 400 }
            }
        });
    }

    /* ── Mirror labels to sidebar quick-summary ── */
    function mirrorLabel(srcId, destId) {
        var src  = document.getElementById(srcId);
        var dest = document.getElementById(destId);
        if (src && dest) dest.innerText = src.innerText;
    }
    mirrorLabel('<%= lblTotalStudents.ClientID %>',   '<%= lblTotalStudents2.ClientID %>');
    mirrorLabel('<%= lblAttendance.ClientID %>',       '<%= lblAttendance2.ClientID %>');
    mirrorLabel('<%= lblTotalAssignments.ClientID %>', '<%= lblTotalAssignments2.ClientID %>');
    mirrorLabel('<%= lblTotalQuizzes.ClientID %>',     '<%= lblTotalQuizzes2.ClientID %>');

})();

    setInterval(function () {
        __doPostBack('', 'AutoRefresh');
    }, 60000); // refresh every 60 sec

</script>


</asp:Content>
