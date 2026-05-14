<%@ Page Title="Subject Analytics" Language="C#" MasterPageFile="~/Teacher/TeacherMaster.master"
    AutoEventWireup="true" CodeBehind="SubjectAnalytics.aspx.cs"
    Inherits="LMS_Project.Teacher.SubjectAnalytics" %>

<asp:Content ID="bodyContent" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

<asp:HiddenField ID="hfSubjectId" runat="server" />
<asp:Label ID="lblMsg" runat="server" CssClass="alert d-block mt-3" Visible="false"></asp:Label>

<!-- HEADER -->
<div class="d-flex align-items-center justify-content-between mb-4 flex-wrap gap-2">
    <div class="d-flex align-items-center gap-3">
        <a href='TeacherCourses.aspx?SubjectId=<%= Request.QueryString["SubjectId"] %>' class="btn btn-outline-secondary">
            <i class="fa-solid fa-arrow-left"></i>
        </a>
        <div>
            <small class="text-muted text-uppercase fw-bold" style="letter-spacing:.06em">Subject Analytics</small>
            <h3 class="mb-0 fw-bold">
                <asp:Literal ID="litSubjectName" runat="server" />
            </h3>
        </div>
    </div>
    <div class="d-flex gap-2 align-items-center">
        <span class="badge bg-light text-secondary border px-3 py-2">
            <i class="fa-solid fa-hashtag me-1"></i><asp:Literal ID="litSubjectCode" runat="server" />
        </span>
        <asp:Literal ID="litStatusBadge" runat="server" />
    </div>
</div>

<!-- KPI ROW 1 -->
<div class="row g-3 mb-3">
    <div class="col-6 col-md-3">
        <div class="kpi-card kpi-blue">
            <div class="kpi-icon"><i class="fa-solid fa-users"></i></div>
            <div class="kpi-val"><asp:Literal ID="litTotalStudents" runat="server" /></div>
            <div class="kpi-lbl">Enrolled Students</div>
        </div>
    </div>
    <div class="col-6 col-md-3">
        <div class="kpi-card kpi-indigo">
            <div class="kpi-icon"><i class="fa-solid fa-book-open"></i></div>
            <div class="kpi-val"><asp:Literal ID="litTotalChapters" runat="server" /></div>
            <div class="kpi-lbl">Chapters</div>
        </div>
    </div>
    <div class="col-6 col-md-3">
        <div class="kpi-card kpi-red">
            <div class="kpi-icon"><i class="fa-regular fa-circle-play"></i></div>
            <div class="kpi-val"><asp:Literal ID="litTotalVideos" runat="server" /></div>
            <div class="kpi-lbl">Video Lectures</div>
        </div>
    </div>
    <div class="col-6 col-md-3">
        <div class="kpi-card kpi-teal">
            <div class="kpi-icon"><i class="fa-solid fa-file-lines"></i></div>
            <div class="kpi-val"><asp:Literal ID="litTotalMaterials" runat="server" /></div>
            <div class="kpi-lbl">Materials</div>
        </div>
    </div>
</div>

<!-- KPI ROW 2 -->
<div class="row g-3 mb-4">
    <div class="col-6 col-md-3">
        <div class="kpi-card kpi-orange">
            <div class="kpi-icon"><i class="fa-solid fa-tasks"></i></div>
            <div class="kpi-val"><asp:Literal ID="litTotalAssignments" runat="server" /></div>
            <div class="kpi-lbl">Assignments</div>
        </div>
    </div>
    <div class="col-6 col-md-3">
        <div class="kpi-card kpi-purple">
            <div class="kpi-icon"><i class="fa-solid fa-circle-check"></i></div>
            <div class="kpi-val"><asp:Literal ID="litTotalSubmissions" runat="server" /></div>
            <div class="kpi-lbl">Total Submissions</div>
        </div>
    </div>
    <div class="col-6 col-md-3">
        <div class="kpi-card kpi-green">
            <div class="kpi-icon"><i class="fa-solid fa-chart-simple"></i></div>
            <div class="kpi-val"><asp:Literal ID="litAvgMarks" runat="server" /></div>
            <div class="kpi-lbl">Avg Assignment Score</div>
        </div>
    </div>
    <div class="col-6 col-md-3">
        <div class="kpi-card kpi-pink">
            <div class="kpi-icon"><i class="fa-solid fa-percent"></i></div>
            <div class="kpi-val"><asp:Literal ID="litAvgAttendance" runat="server" /></div>
            <div class="kpi-lbl">Avg Attendance %</div>
        </div>
    </div>
</div>
    <!-- CHARTS ROW 2 — Attendance (3/4) + Attendance Split (1/4) side by side -->
<div class="row g-4 mb-4">
    <div class="col-md-9">
        <div class="card border-0 shadow-sm h-100">
            <div class="card-header bg-white border-bottom fw-semibold py-3">
                <i class="fa-solid fa-calendar-check me-2 text-primary"></i>Attendance by Date (Last 30 Days)
            </div>
            <div class="card-body">
                <canvas id="attendanceChart" height="120"></canvas>
            </div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card border-0 shadow-sm h-100">
            <div class="card-header bg-white border-bottom fw-semibold py-3">
                <i class="fa-solid fa-circle-half-stroke me-2 text-info"></i>Attendance Split
            </div>
            <div class="card-body d-flex flex-column align-items-center justify-content-center">
                <canvas id="attendanceDoughnut" style="max-width:200px;max-height:200px;"></canvas>
                <div id="doughnutLegend" class="d-flex gap-3 mt-3 flex-wrap justify-content-center"></div>
            </div>
        </div>
    </div>
</div>
<!-- CHARTS ROW 1 — Video Views (3/4) + Content per Chapter (1/4) -->
<div class="row g-4 mb-4">
    <div class="col-md-9">
        <div class="card border-0 shadow-sm h-100">
            <div class="card-header bg-white border-bottom fw-semibold py-3">
                <i class="fa-solid fa-video me-2 text-danger"></i>Video Views per Chapter
            </div>
            <div class="card-body">
                <canvas id="videoViewsChart" height="120"></canvas>
            </div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card border-0 shadow-sm h-100">
            <div class="card-header bg-white border-bottom fw-semibold py-3">
                <i class="fa-solid fa-layer-group me-2 text-secondary"></i>Content per Chapter
            </div>
            <div class="card-body p-0" style="overflow-y:auto;max-height:320px;">
                <asp:Repeater ID="rptChapterContent" runat="server">
                    <ItemTemplate>
                        <div class="d-flex justify-content-between align-items-center px-3 py-2 border-bottom">
                            <span class="small text-truncate me-2" style="max-width:55%">
                                <strong><%# Container.ItemIndex+1 %>.</strong> <%# Eval("ChapterName") %>
                            </span>
                            <div class="d-flex gap-1 flex-shrink-0">
                                <span class="badge bg-danger bg-opacity-10 text-danger border border-danger border-opacity-25">
                                    <i class="fa-solid fa-video me-1"></i><%# Eval("VideoCount") %>
                                </span>
                                <span class="badge bg-success bg-opacity-10 text-success border border-success border-opacity-25">
                                    <i class="fa-solid fa-file me-1"></i><%# Eval("MaterialCount") %>
                                </span>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>
    </div>
</div>


<!-- STUDENT PROGRESS TABLE -->
<div class="card border-0 shadow-sm mb-4">
    <div class="card-header bg-white border-bottom fw-semibold py-3 d-flex justify-content-between align-items-center">
        <span><i class="fa-solid fa-table me-2 text-primary"></i>Student Progress</span>
        <div class="d-flex align-items-center gap-3">
            <div class="input-group input-group-sm" style="width:200px;">
                <span class="input-group-text bg-white border-end-0">
                    <i class="fa-solid fa-magnifying-glass text-muted" style="font-size:.75rem"></i>
                </span>
                <input type="text" id="studentSearchInput" class="form-control border-start-0 ps-0"
                       placeholder="Search student..." style="font-size:.82rem" />
            </div>
            <span class="badge bg-primary bg-opacity-10 text-primary border">
                <asp:Literal ID="litTotalStudents2" runat="server" /> Students
            </span>
        </div>
    </div>
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-hover mb-0 align-middle" id="studentProgressTable" style="font-size:.84rem">
                <thead class="table-light">
                    <tr>
                        <th>#</th>
                        <th>Student</th>
                        <th>Attendance %</th>
                        <th>Assignments Done</th>
                        <th>Avg Marks</th>
                        <th>Videos Watched</th>
                        <th>Overall Progress</th>
                    </tr>
                </thead>
                <tbody id="studentProgressBody">
<asp:Repeater ID="rptStudentProgress" runat="server">
    <ItemTemplate>
        <tr class="student-row">
            <td><span class="badge bg-secondary"><%# Container.ItemIndex+1 %></span></td>
            <td>
                <div class="d-flex align-items-center gap-2">
                    <div class="student-avatar"><%# GetInitials(Eval("FullName").ToString()) %></div>
                    <span class="fw-medium student-name"><%# Eval("FullName") %></span>
                </div>
            </td>
            <td>
                <div class="d-flex align-items-center gap-2">
                    <div class="mini-bar">
                        <div class="mini-bar-fill bg-primary" style="width:<%# Eval("AttendancePct") %>%"></div>
                    </div>
                    <small class="fw-bold"><%# string.Format("{0:F2}", Convert.ToDecimal(Eval("AttendancePct"))) %>%</small>
                </div>
            </td>
            <td><%# Eval("AssignmentsDone") %> / <%# Eval("TotalAssignments") %></td>
            <td>
                <span class="badge <%# GetScoreClass(Eval("AvgMarks")) %>">
                    <%# string.Format("{0:F2}", Convert.ToDecimal(Eval("AvgMarks"))) %>
                </span>
            </td>
            <td><%# Eval("VideosWatched") %></td>
            <td>
                <div class="d-flex align-items-center gap-2">
                    <div class="mini-bar">
                        <div class="mini-bar-fill bg-success" style="width:<%# Eval("OverallProgress") %>%"></div>
                    </div>
                    <small class="fw-bold"><%# string.Format("{0:F2}", Convert.ToDecimal(Eval("OverallProgress"))) %>%</small>
                </div>
            </td>
        </tr>
    </ItemTemplate>
</asp:Repeater>                </tbody>
            </table>
        </div>

        <!-- Pagination Footer -->
        <div class="d-flex align-items-center justify-content-between px-3 py-2 border-top bg-white flex-wrap gap-2"
             id="studentPaginationFooter">
            <small class="text-muted" id="studentPageInfo"></small>
            <nav>
                <ul class="pagination pagination-sm mb-0" id="studentPagination"></ul>
            </nav>
        </div>

        <!-- No results row -->
        <div id="studentNoResults" class="text-center text-muted py-4 d-none">
            <i class="fa-solid fa-user-slash fa-lg mb-2 d-block"></i>
            No students match your search.
        </div>
    </div>
</div>

    <%-- 
Overall Progress = (Attendance % + Assignment Completion %) / 2
Where:
Attendance % = (Number of days marked 'Present' / Total attendance days recorded) × 100
Assignment Completion % = (Number of assignments submitted / Total assignments in the subject) × 100
    --%>

<!-- CHARTS ROW 3 — Assignments (1/2) + Assignment Details (1/2) side by side -->
<div class="row g-4 mb-4">
    <div class="col-md-6">
        <div class="card border-0 shadow-sm h-100">
            <div class="card-header bg-white border-bottom fw-semibold py-3">
                <i class="fa-solid fa-tasks me-2 text-warning"></i>Assignment Submissions vs Students
            </div>
            <div class="card-body">
                <canvas id="assignmentChart" height="120"></canvas>
            </div>
        </div>
    </div>
    <div class="col-md-6">
        <div class="card border-0 shadow-sm h-100">
            <div class="card-header bg-white border-bottom fw-semibold py-3">
                <i class="fa-solid fa-clipboard-list me-2 text-warning"></i>Assignment Details
            </div>
            <div class="card-body p-0" style="overflow-y:auto; max-height:350px;">
                <div class="table-responsive">
                    <table class="table table-hover mb-0 align-middle" style="font-size:.84rem">
                        <thead class="table-light sticky-top">
                            <tr>
                                <th>Title</th>
                                <th>Due Date</th>
                                <th>Max Marks</th>
                                <th>Submissions</th>
                                <th>Avg Score</th>
                                <th>Submission Rate</th>
                            </tr>
                        </thead>
                        <tbody>
                            <asp:Repeater ID="rptAssignmentDetail" runat="server">
                                <ItemTemplate>
                                    <tr>
                                        <td class="fw-semibold"><%# Eval("Title") %></td>
                                        <td><small class="text-danger"><%# Eval("DueDate", "{0:dd MMM yyyy}") %></small></td>
                                        <td><%# Eval("MaxMarks") %></td>
                                        <td><%# Eval("SubmissionCount") %></td>
                                        <td>
                                            <span class="badge <%# GetScoreClass(Eval("AvgScore")) %>">
                                                <%# string.Format("{0:F2}", Convert.ToDecimal(Eval("AvgScore"))) %>
                                            </span>
                                        </td>
                                        <td>
                                            <div class="d-flex align-items-center gap-2">
                                                <div class="mini-bar">
                                                    <div class="mini-bar-fill bg-warning" style="width:<%# Eval("SubmissionRate") %>%"></div>
                                                </div>
                                                <small><%# string.Format("{0:F2}", Convert.ToDecimal(Eval("SubmissionRate"))) %>%</small>
                                            </div>
                                        </td>
                                    </tr>
                                </ItemTemplate>
                            </asp:Repeater>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Hidden fields for chart data -->
<asp:HiddenField ID="hfAttendanceLabels"  runat="server" />
<asp:HiddenField ID="hfAttendancePresent" runat="server" />
<asp:HiddenField ID="hfAttendanceAbsent" runat="server" />
<asp:HiddenField ID="hfAttendanceLeave"  runat="server" />
<asp:HiddenField ID="hfPresentTotal"     runat="server" />
<asp:HiddenField ID="hfAbsentTotal"      runat="server" />
<asp:HiddenField ID="hfLeaveTotal"       runat="server" />
<asp:HiddenField ID="hfVideoLabels"        runat="server" />
<asp:HiddenField ID="hfVideoChapterNames"  runat="server" />
<asp:HiddenField ID="hfVideoTotalViews"    runat="server" />
<asp:HiddenField ID="hfVideoUniqueViewers" runat="server" />
<asp:HiddenField ID="hfAssignmentTitles" runat="server" />
<asp:HiddenField ID="hfAssignmentSubs"   runat="server" />
<asp:HiddenField ID="hfAssignmentTotal"  runat="server" />


<!-- STYLES -->
<style>
    .kpi-card {
        background: #fff; border-radius: 12px; padding: 18px 16px 14px;
        box-shadow: 0 2px 10px rgba(0,0,0,.07); border-top: 4px solid transparent;
        transition: transform .2s;
    }
    .kpi-card:hover { transform: translateY(-3px); }
    .kpi-icon { font-size: 1.2rem; margin-bottom: 6px; }
    .kpi-val  { font-size: 2rem; font-weight: 800; color: #1a1e2e; line-height: 1; }
    .kpi-lbl  { font-size: .72rem; text-transform: uppercase; letter-spacing: .06em; color: #6b7280; margin-top: 4px; }
    .kpi-blue   { border-top-color: #3b82f6; color: #3b82f6; }
    .kpi-indigo { border-top-color: #6366f1; color: #6366f1; }
    .kpi-red    { border-top-color: #ef4444; color: #ef4444; }
    .kpi-teal   { border-top-color: #14b8a6; color: #14b8a6; }
    .kpi-orange { border-top-color: #f97316; color: #f97316; }
    .kpi-purple { border-top-color: #a855f7; color: #a855f7; }
    .kpi-green  { border-top-color: #22c55e; color: #22c55e; }
    .kpi-pink   { border-top-color: #ec4899; color: #ec4899; }

    .student-avatar {
        width: 32px; height: 32px; border-radius: 50%;
        background: linear-gradient(135deg,#6366f1,#3b82f6);
        color: #fff; font-size: .7rem; font-weight: 700;
        display: grid; place-items: center; flex-shrink: 0;
    }
    .mini-bar { width: 80px; height: 7px; background: #e9ecef; border-radius: 999px; overflow: hidden; }
    .mini-bar-fill { height: 100%; border-radius: 999px; transition: width .6s ease; }
</style>

<!-- Chart.js -->
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
<script>
    document.addEventListener("DOMContentLoaded", function () {

        // ── helpers ──────────────────────────────────────────────
        function parseHF(id) {
            var v = document.getElementById(id)?.value || '';
            if (!v) return [];
            try { return JSON.parse(v); } catch (e) { console.error('Parse error for', id, e); return []; }
        }

        // ── DATA ─────────────────────────────────────────────────
        var attLabels = parseHF('<%= hfAttendanceLabels.ClientID %>');
        var attPresent = parseHF('<%= hfAttendancePresent.ClientID %>');
        var attAbsent = parseHF('<%= hfAttendanceAbsent.ClientID %>');
        var attLeave = parseHF('<%= hfAttendanceLeave.ClientID %>');

        var pTotal = parseInt(document.getElementById('<%= hfPresentTotal.ClientID %>').value || '0');
        var aTotal = parseInt(document.getElementById('<%= hfAbsentTotal.ClientID %>').value || '0');
        var lTotal = parseInt(document.getElementById('<%= hfLeaveTotal.ClientID %>').value || '0');

        var asgTitles = parseHF('<%= hfAssignmentTitles.ClientID %>');
        var asgSubs   = parseHF('<%= hfAssignmentSubs.ClientID %>');
        var asgTotal  = parseInt(document.getElementById('<%= hfAssignmentTotal.ClientID %>').value || '0');

        // Check if we have data before creating charts
        console.log('Attendance data:', {attLabels, attPresent, attAbsent, attLeave});
        console.log('Video data available:', parseHF('<%= hfVideoLabels.ClientID %>').length);
        console.log('Assignment data:', {asgTitles, asgSubs, asgTotal});

        // ── 1. Attendance Bar Chart ───────────────────────────────
        if (attLabels.length > 0) {
            new Chart(document.getElementById('attendanceChart'), {
                type: 'bar',
                data: {
                    labels: attLabels,
                    datasets: [
                        { label: 'Present', data: attPresent, backgroundColor: '#22c55e', borderRadius: 4 },
                        { label: 'Absent',  data: attAbsent,  backgroundColor: '#ef4444', borderRadius: 4 },
                        { label: 'Leave',   data: attLeave,   backgroundColor: '#f59e0b', borderRadius: 4 }
                    ]
                },
                options: {
                    responsive: true, 
                    maintainAspectRatio: true,
                    plugins: { legend: { position: 'top' } },
                    scales: { x: { stacked: false }, y: { beginAtZero: true, ticks: { stepSize: 1 } } }
                }
            });
        } else {
            document.getElementById('attendanceChart').parentElement.innerHTML += '<div class="alert alert-warning mt-2">No attendance data available</div>';
        }

        // ── 2. Attendance Doughnut ────────────────────────────────
        if (pTotal + aTotal + lTotal > 0) {
            new Chart(document.getElementById('attendanceDoughnut'), {
                type: 'doughnut',
                data: {
                    labels: ['Present', 'Absent', 'Leave'],
                    datasets: [{ data: [pTotal, aTotal, lTotal], backgroundColor: ['#22c55e','#ef4444','#f59e0b'], borderWidth: 2 }]
                },
                options: { responsive: true, maintainAspectRatio: true, cutout: '65%', plugins: { legend: { display: false } } }
            });
            // manual legend
            var leg = document.getElementById('doughnutLegend');
            if (leg) {
                leg.innerHTML = '';
                [['Present','#22c55e',pTotal],['Absent','#ef4444',aTotal],['Leave','#f59e0b',lTotal]].forEach(function(d){
                    leg.innerHTML += '<span style="font-size:.8rem;display:flex;align-items:center;gap:5px">'
                        + '<span style="width:10px;height:10px;border-radius:50%;background:'+d[1]+';display:inline-block"></span>'
                        + d[0]+' ('+d[2]+')</span>';
                });
            }
        }

        // ── 3. Video Views Chart ─────────────────────────
        var vidLabels = parseHF('<%= hfVideoLabels.ClientID %>');
        var vidChapterNames = parseHF('<%= hfVideoChapterNames.ClientID %>');
        var vidTotalViews = parseHF('<%= hfVideoTotalViews.ClientID %>');
        var vidUniqueViewers = parseHF('<%= hfVideoUniqueViewers.ClientID %>');

        if (vidLabels.length > 0 && vidTotalViews.length > 0) {
            // Build background colors — one distinct color per chapter
            var chapterColors = {};
            var palette = [
                '#ef444488', '#3b82f688', '#f59e0b88', '#22c55e88',
                '#a855f788', '#14b8a688', '#f9731688', '#6366f188'
            ];
            var colorIdx = 0;

            vidChapterNames.forEach(function (ch) {
                if (!chapterColors[ch]) {
                    chapterColors[ch] = palette[colorIdx % palette.length];
                    colorIdx++;
                }
            });

            var totalBg = vidChapterNames.map(function (ch) { return chapterColors[ch]; });
            var uniqueBg = vidChapterNames.map(function (ch) {
                return chapterColors[ch].replace('88', 'cc');
            });

            new Chart(document.getElementById('videoViewsChart'), {
                type: 'bar',
                data: {
                    labels: vidLabels,
                    datasets: [
                        {
                            label: 'Total Views',
                            data: vidTotalViews,
                            backgroundColor: totalBg,
                            borderRadius: 6,
                            borderSkipped: false
                        },
                        {
                            label: 'Unique Student Viewers',
                            data: vidUniqueViewers,
                            backgroundColor: uniqueBg,
                            borderRadius: 6,
                            borderSkipped: false
                        }
                    ]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: true,
                    plugins: {
                        legend: { position: 'top' },
                        tooltip: {
                            callbacks: {
                                title: function (items) {
                                    return items[0].label;
                                }
                            }
                        }
                    },
                    scales: {
                        x: {
                            ticks: {
                                maxRotation: 45,
                                callback: function (val, idx) {
                                    var full = vidLabels[idx] || '';
                                    var parts = full.split(' – ');
                                    return parts.length > 1 ? parts[1] : full;
                                }
                            }
                        },
                        y: { beginAtZero: true, ticks: { stepSize: 1 } }
                    }
                }
            });
        } else {
            document.getElementById('videoViewsChart').parentElement.innerHTML += '<div class="alert alert-warning mt-2">No video data available</div>';
        }

        // ── 4. Assignment Submissions Chart ───────────────────────
        if (asgTitles.length > 0 && asgTotal > 0) {
            var asgTotalArr = asgTitles.map(function () { return asgTotal; });
            new Chart(document.getElementById('assignmentChart'), {
                type: 'bar',
                data: {
                    labels: asgTitles,
                    datasets: [
                        { label: 'Submitted', data: asgSubs, backgroundColor: '#3b82f6cc', borderRadius: 4 },
                        { label: 'Enrolled', data: asgTotalArr, backgroundColor: '#e5e7ebcc', borderRadius: 4 }
                    ]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: true,
                    plugins: { legend: { position: 'top' } },
                    scales: { y: { beginAtZero: true } }
                }
            });
        } else {
            document.getElementById('assignmentChart').parentElement.innerHTML += '<div class="alert alert-warning mt-2">No assignment data available</div>';
        }
    });
</script>

<!-- Sidebar active fix -->
<script>
    document.addEventListener("DOMContentLoaded", function () {
        document.querySelectorAll('.sidebar-link').forEach(function (l) { l.classList.remove('active'); });
        var c = document.querySelector('a[href*="TeacherCourses.aspx"]');
        if (c) c.classList.add('active');
    });
</script>
    <script>
        (function () {
            const PAGE_SIZE = 5;
            let currentPage = 1;
            let filteredRows = [];

            const tbody = document.getElementById('studentProgressBody');
            const searchInput = document.getElementById('studentSearchInput');
            const pagination = document.getElementById('studentPagination');
            const pageInfo = document.getElementById('studentPageInfo');
            const noResults = document.getElementById('studentNoResults');
            const footer = document.getElementById('studentPaginationFooter');

            // All rows rendered by the Repeater
            const allRows = Array.from(tbody.querySelectorAll('tr.student-row'));

            function getStudentName(row) {
                const el = row.querySelector('.student-name');
                return el ? el.textContent.toLowerCase() : '';
            }

            function applyFilter() {
                const q = searchInput.value.trim().toLowerCase();
                filteredRows = q
                    ? allRows.filter(r => getStudentName(r).includes(q))
                    : [...allRows];
                currentPage = 1;
                render();
            }

            function render() {
                const total = filteredRows.length;
                const totalPages = Math.max(1, Math.ceil(total / PAGE_SIZE));
                currentPage = Math.min(currentPage, totalPages);

                const start = (currentPage - 1) * PAGE_SIZE;
                const end = Math.min(start + PAGE_SIZE, total);

                // Hide all, show only current page slice
                allRows.forEach(r => r.style.display = 'none');
                filteredRows.forEach((r, i) => {
                    r.style.display = (i >= start && i < end) ? '' : 'none';
                });

                // No results state
                if (total === 0) {
                    noResults.classList.remove('d-none');
                    footer.style.display = 'none';
                } else {
                    noResults.classList.add('d-none');
                    footer.style.display = '';
                }

                // Page info text
                pageInfo.textContent = total === 0
                    ? ''
                    : 'Showing ' + (start + 1) + '–' + end + ' of ' + total + ' students';

                // Build pagination buttons
                buildPagination(totalPages);
            }

            function buildPagination(totalPages) {
                pagination.innerHTML = '';

                // Prev button
                pagination.appendChild(makeBtn('&laquo;', currentPage === 1, function () {
                    if (currentPage > 1) { currentPage--; render(); }
                }));

                // Page number buttons — show at most 5 around current
                const range = pageRange(currentPage, totalPages);
                range.forEach(function (p) {
                    if (p === '...') {
                        const li = document.createElement('li');
                        li.className = 'page-item disabled';
                        li.innerHTML = '<span class="page-link">…</span>';
                        pagination.appendChild(li);
                    } else {
                        pagination.appendChild(makeBtn(p, false, function () {
                            currentPage = p; render();
                        }, p === currentPage));
                    }
                });

                // Next button
                pagination.appendChild(makeBtn('&raquo;', currentPage === totalPages, function () {
                    if (currentPage < totalPages) { currentPage++; render(); }
                }));
            }

            function makeBtn(label, disabled, onClick, active) {
                const li = document.createElement('li');
                li.className = 'page-item' + (disabled ? ' disabled' : '') + (active ? ' active' : '');
                const a = document.createElement('a');
                a.className = 'page-link';
                a.href = '#';
                a.innerHTML = label;
                if (!disabled) a.addEventListener('click', function (e) { e.preventDefault(); onClick(); });
                li.appendChild(a);
                return li;
            }

            function pageRange(cur, total) {
                if (total <= 7) return Array.from({ length: total }, (_, i) => i + 1);
                const pages = [];
                pages.push(1);
                if (cur > 3) pages.push('...');
                for (let p = Math.max(2, cur - 1); p <= Math.min(total - 1, cur + 1); p++) pages.push(p);
                if (cur < total - 2) pages.push('...');
                pages.push(total);
                return pages;
            }

            // Wire up search
            searchInput.addEventListener('input', applyFilter);

            // Initial render
            filteredRows = [...allRows];
            render();
        })();
    </script>
</asp:Content>