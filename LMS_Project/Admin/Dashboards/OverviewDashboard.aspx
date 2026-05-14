<%@ Page Title="Overview Dashboard" Language="C#"
    MasterPageFile="~/Admin/AdminMaster.Master"
    AutoEventWireup="true"
    CodeBehind="OverviewDashboard.aspx.cs"
    Inherits="LearningManagementSystem.Admin.OverviewDashboard" %>

<asp:Content ID="cHead" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet"/>
<style>
:root {
    --primary: #4f46e5;
    --primary-light: #ede9fe;
    --success: #10b981;
    --success-light: #d1fae5;
    --warning: #f59e0b;
    --warning-light: #fef3c7;
    --danger: #ef4444;
    --danger-light: #fee2e2;
    --info: #3b82f6;
    --info-light: #dbeafe;
    --purple: #8b5cf6;
    --purple-light: #ede9fe;
    --text-primary: #1e293b;
    --text-secondary: #64748b;
    --border: #e2e8f0;
    --card-bg: #ffffff;
    --page-bg: #f8fafc;
    --radius: 12px;
    --shadow: 0 1px 3px rgba(0,0,0,.08), 0 1px 2px rgba(0,0,0,.06);
    --shadow-md: 0 4px 6px rgba(0,0,0,.07), 0 2px 4px rgba(0,0,0,.06);
}
* { box-sizing: border-box; margin: 0; padding: 0; }
body { background: var(--page-bg); font-family: 'Inter', 'Segoe UI', sans-serif; color: var(--text-primary); }

.dash-header {
    display: flex; align-items: center; justify-content: space-between;
    margin-bottom: 24px; flex-wrap: wrap; gap: 12px;
}
.dash-header h1 { font-size: 22px; font-weight: 700; color: var(--text-primary); }
.dash-header .sub { font-size: 13px; color: var(--text-secondary); margin-top: 2px; }
.badge-session {
    background: var(--primary-light); color: var(--primary);
    padding: 6px 14px; border-radius: 20px; font-size: 13px; font-weight: 500;
}

/* ── Stat cards ── */
.stat-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(170px,1fr)); gap: 16px; margin-bottom: 24px; }
.stat-card {
    background: var(--card-bg); border-radius: var(--radius); padding: 12px 15px;
    box-shadow: var(--shadow); border: 1px solid var(--border);
    display: flex; align-items: center; gap: 14px;
    transition: transform .2s, box-shadow .2s;
}
.stat-card:hover { transform: translateY(-2px); box-shadow: var(--shadow-md); }
.stat-icon {
    width: 48px; height: 48px; border-radius: 12px;
    display: flex; align-items: center; justify-content: center; font-size: 20px; flex-shrink: 0;
}
.stat-icon.blue   { background: var(--info-light);    color: var(--info); }
.stat-icon.green  { background: var(--success-light);  color: var(--success); }
.stat-icon.purple { background: var(--purple-light);   color: var(--purple); }
.stat-icon.amber  { background: var(--warning-light);  color: var(--warning); }
.stat-icon.red    { background: var(--danger-light);   color: var(--danger); }
.stat-icon.indigo { background: #e0e7ff; color: var(--primary); }
.stat-icon.teal   { background: #ccfbf1; color: #0d9488; }
.stat-icon.cyan   { background: #cffafe; color: #0891b2; }
.stat-label { font-size: 12px; color: var(--text-secondary); font-weight: 500; margin-bottom: 4px; }
.stat-value { font-size: 24px; font-weight: 700; color: var(--text-primary); line-height: 1; }
.stat-trend { font-size: 11px; margin-top: 4px; }
.trend-up   { color: var(--success); }
.trend-down { color: var(--danger); }

/* ── Chart grid ── */
.chart-grid { display: grid; grid-template-columns: 2fr 1fr; gap: 16px; margin-bottom: 24px; }
.chart-grid-3 { display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 16px; margin-bottom: 24px; }
.chart-grid-2 { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 24px; }

.card {
    background: var(--card-bg); border-radius: var(--radius);
    box-shadow: var(--shadow); border: 1px solid var(--border);
    padding: 20px;
}
.card-header {
    display: flex; align-items: center; justify-content: space-between;
    margin-bottom: 16px;
}
.card-title { font-size: 14px; font-weight: 600; color: var(--text-primary); }
.card-sub   { font-size: 12px; color: var(--text-secondary); margin-top: 2px; }
.chart-wrap { position: relative; width: 100%; }
.chart-wrap canvas { width: 100% !important; }

/* ── Attendance ring ── */
.ring-wrap { display: flex; flex-direction: column; align-items: center; justify-content: center; padding: 10px 0; }
.ring-label { font-size: 28px; font-weight: 700; color: var(--primary); margin-top: 8px; }
.ring-sub   { font-size: 12px; color: var(--text-secondary); }

/* ── Activity feed ── */
.activity-list { list-style: none; }
.activity-item {
    display: flex; align-items: flex-start; gap: 10px;
    padding: 10px 0; border-bottom: 1px solid var(--border);
}
.activity-item:last-child { border-bottom: none; }
.act-dot {
    width: 8px; height: 8px; border-radius: 50%;
    background: var(--primary); margin-top: 5px; flex-shrink: 0;
}
.act-name  { font-size: 13px; font-weight: 500; color: var(--text-primary); }
.act-type  { font-size: 12px; color: var(--text-secondary); }
.act-time  { font-size: 11px; color: var(--text-secondary); margin-left: auto; white-space: nowrap; }

/* ── Progress bars ── */
.progress-item { margin-bottom: 14px; }
.progress-label { display: flex; justify-content: space-between; font-size: 13px; margin-bottom: 6px; }
.progress-bar-bg { background: var(--border); border-radius: 99px; height: 8px; overflow: hidden; }
.progress-bar { height: 8px; border-radius: 99px; transition: width 1s ease; }

/* ── Top courses table ── */
.mini-table { width: 100%; border-collapse: collapse; font-size: 13px; }
.mini-table th { font-size: 11px; font-weight: 600; color: var(--text-secondary); text-transform: uppercase; padding: 0 0 8px; border-bottom: 1px solid var(--border); }
.mini-table td { padding: 10px 0; border-bottom: 1px solid var(--border); vertical-align: middle; }
.mini-table tr:last-child td { border-bottom: none; }
.rank-badge {
    width: 22px; height: 22px; border-radius: 50%;
    background: var(--primary-light); color: var(--primary);
    font-size: 11px; font-weight: 700;
    display: inline-flex; align-items: center; justify-content: center;
}

@media (max-width: 900px) {
    .chart-grid, .chart-grid-3 { grid-template-columns: 1fr; }
    .chart-grid-2 { grid-template-columns: 1fr; }
}
</style>
</asp:Content>

<asp:Content ID="cBody" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

<!-- Hidden fields for chart data -->
<asp:HiddenField ID="hdnMonthlyGrowth" runat="server" />
<asp:HiddenField ID="hdnTopCourses"    runat="server" />
<asp:HiddenField ID="hdnTopSubjects"   runat="server" />
<asp:HiddenField ID="hdnStreamData"    runat="server" />

<div style="padding: 24px;">

    <!-- Header -->
    <div class="dash-header">
        <div>
            <h1><i class="fa fa-gauge-high" style="color:var(--primary);margin-right:8px;"></i>Overview Dashboard</h1>
            <div class="sub">Yearly snapshot of your institution's performance</div>
        </div>
        <span class="badge-session"><i class="fa fa-calendar me-1"></i> Session: <%=Session["SessionName"] %></span>
    </div>

    <!-- Stat Cards -->
    <div class="stat-grid">
        <div class="stat-card">
            <div class="stat-icon blue"><i class="fa fa-users"></i></div>
            <div>
                <div class="stat-label">Total Students</div>
                <div class="stat-value"><asp:Label ID="lblTotalStudents" runat="server" Text="0"/></div>
                <%--<div class="stat-trend trend-up"><i class="fa fa-arrow-up"></i> Active</div>--%>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon green"><i class="fa fa-chalkboard-user"></i></div>
            <div>
                <div class="stat-label">Total Teachers</div>
                <div class="stat-value"><asp:Label ID="lblTotalTeachers" runat="server" Text="0"/></div>
                <%--<div class="stat-trend trend-up"><i class="fa fa-arrow-up"></i> Active</div>--%>
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-icon purple"><i class="fa-solid fa-layer-group"></i></div>
            <div>
                <div class="stat-label">Total Streams</div>
                <div class="stat-value"><asp:Label ID="lblTotalStreams" runat="server" Text="0"/></div>
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-icon amber"><i class="fa fa-graduation-cap"></i></div>
            <div>
                <div class="stat-label">Total Courses</div>
                <div class="stat-value"><asp:Label ID="lblTotalCourses" runat="server" Text="0"/></div>
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-icon purple"><i class="fa fa-book-open"></i></div>
            <div>
                <div class="stat-label">Total Subjects</div>
                <div class="stat-value"><asp:Label ID="lblTotalSubjects" runat="server" Text="0"/></div>
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-icon purple"><i class="fa-solid fa-book"></i></div>
            <div>
                <div class="stat-label">Total Chapters</div>
                <div class="stat-value"><asp:Label ID="lblTotalChapters" runat="server" Text="0"/></div>
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-icon red"><i class="fa fa-clipboard-list"></i></div>
            <div>
                <div class="stat-label">Assignments</div>
                <div class="stat-value"><asp:Label ID="lblTotalAssignments" runat="server" Text="0"/></div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon indigo"><i class="fa fa-video"></i></div>
            <div>
                <div class="stat-label">Videos</div>
                <div class="stat-value"><asp:Label ID="lblTotalVideos" runat="server" Text="0"/></div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon teal"><i class="fa fa-question-circle"></i></div>
            <div>
                <div class="stat-label">Quizzes</div>
                <div class="stat-value"><asp:Label ID="lblTotalQuizzes" runat="server" Text="0"/></div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon cyan"><i class="fa fa-layer-group"></i></div>
            <div>
                <div class="stat-label">Sections</div>
                <div class="stat-value"><asp:Label ID="lblTotalSections" runat="server" Text="0"/></div>
            </div>
        </div>
    </div>

    <!-- Row 2: Growth Chart + Attendance Ring + Stream Donut -->
    <div class="chart-grid">
        <div class="card">
            <div class="card-header">
                <div>
                    <div class="card-title">Monthly Student Enrollment</div>
                    <div class="card-sub">New students registered each month this year</div>
                </div>
            </div>
            <div class="chart-wrap" style="height:240px;">
                <canvas id="chartGrowth"></canvas>
            </div>
        </div>
        <div class="card">
            <div class="card-header">
                <div class="card-title">Overall Attendance</div>
                <div class="card-sub">Current session average</div>
            </div>
            <div class="ring-wrap">
                <canvas id="chartAttRing" width="160" height="160"></canvas>
                <div class="ring-label"><asp:Label ID="lblAttendance" runat="server" Text="0%"/></div>
                <div class="ring-sub">Institute Average</div>
            </div>
        </div>
    </div>

    <!-- Row 3: Stream Pie + Top Courses + Top Subjects -->
    <div class="chart-grid-3">
        <div class="card">
            <div class="card-header">
                <div class="card-title">Students by Stream</div>
            </div>
            <div class="chart-wrap" style="height:220px;">
                <canvas id="chartStream"></canvas>
            </div>
        </div>
        <div class="card">
            <div class="card-header">
                <div class="card-title">Top Courses</div>
                <div class="card-sub">By enrollment</div>
            </div>
            <div id="topCoursesList"></div>
        </div>
        <div class="card">
            <div class="card-header">
                <div class="card-title">Top Subjects</div>
                <div class="card-sub">By video content</div>
            </div>
            <div class="chart-wrap" style="height:220px;">
                <canvas id="chartSubjects"></canvas>
            </div>
        </div>
    </div>

    <!-- Row 4: Recent Activity -->
    <div class="chart-grid-2">
        <div class="card">
            <div class="card-header">
                <div class="card-title">Recent Activity</div>
                <div class="card-sub">Last 10 actions</div>
            </div>
            <ul class="activity-list" id="activityFeed">
                <asp:Repeater ID="rptRecentActivity" runat="server">
                    <ItemTemplate>
                        <li class="activity-item">
                            <span class="act-dot"></span>
                            <div>
                                <div class="act-name"><%# Eval("FullName") %></div>
                                <div class="act-type"><%# Eval("ActivityType") %></div>
                            </div>
                            <span class="act-time"><%# ((DateTime)Eval("ActionTime")).ToString("dd MMM, hh:mm tt") %></span>
                        </li>
                    </ItemTemplate>
                </asp:Repeater>
            </ul>
        </div>
        <div class="card">
            <div class="card-header">
                <div class="card-title">Quick Stats</div>
            </div>
            <div style="padding-top:8px;">
                <div class="progress-item">
                    <div class="progress-label"><span>Student Engagement</span><span id="pctEngagement">--</span></div>
                    <div class="progress-bar-bg"><div class="progress-bar" id="barEngagement" style="background:var(--primary);width:0%"></div></div>
                </div>
                <div class="progress-item">
                    <div class="progress-label"><span>Assignment Completion</span><span id="pctAssign">--</span></div>
                    <div class="progress-bar-bg"><div class="progress-bar" id="barAssign" style="background:var(--success);width:0%"></div></div>
                </div>
                <div class="progress-item">
                    <div class="progress-label"><span>Quiz Participation</span><span id="pctQuiz">--</span></div>
                    <div class="progress-bar-bg"><div class="progress-bar" id="barQuiz" style="background:var(--warning);width:0%"></div></div>
                </div>
                <div class="progress-item">
                    <div class="progress-label"><span>Video Watch Rate</span><span id="pctVideo">--</span></div>
                    <div class="progress-bar-bg"><div class="progress-bar" id="barVideo" style="background:var(--purple);width:0%"></div></div>
                </div>
            </div>
        </div>
    </div>

</div>

<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.4.1/chart.umd.min.js"></script>
<script>
    (function () {
        const COLORS = ['#4f46e5', '#10b981', '#f59e0b', '#ef4444', '#8b5cf6', '#3b82f6', '#0d9488', '#0891b2'];

        function safeJson(id) {
            try { return JSON.parse(document.getElementById(id).value || '[]'); } catch { return []; }
        }

        // ── Monthly growth line chart ──
        const growthData = safeJson('<%= hdnMonthlyGrowth.ClientID %>');
    const allMonths = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    const growthVals = Array(12).fill(0);
    growthData.forEach(d => { growthVals[parseInt(d.label) - 1] = d.value; });

    new Chart(document.getElementById('chartGrowth'), {
        type: 'line',
        data: {
            labels: allMonths,
            datasets: [{
                label: 'New Students',
                data: growthVals,
                borderColor: '#4f46e5',
                backgroundColor: 'rgba(79,70,229,0.1)',
                borderWidth: 2.5,
                tension: 0.4,
                fill: true,
                pointBackgroundColor: '#4f46e5',
                pointRadius: 4,
                pointHoverRadius: 6
            }]
        },
        options: {
            responsive: true, maintainAspectRatio: false,
            plugins: { legend: { display: false } },
            scales: {
                x: { grid: { display: false }, ticks: { font: { size: 11 } } },
                y: { beginAtZero: true, grid: { color: '#f1f5f9' }, ticks: { font: { size: 11 } } }
            },
            animation: { duration: 1200, easing: 'easeInOutQuart' }
        }
    });

    // ── Attendance ring ──
    const attText = document.getElementById('<%= lblAttendance.ClientID %>').innerText || '0%';
    const attVal = parseFloat(attText) || 0;
    new Chart(document.getElementById('chartAttRing'), {
        type: 'doughnut',
        data: {
            datasets: [{
                data: [attVal, 100 - attVal],
                backgroundColor: ['#4f46e5', '#e2e8f0'],
                borderWidth: 0
            }]
        },
        options: {
            cutout: '75%',
            plugins: { legend: { display: false }, tooltip: { enabled: false } },
            animation: { animateRotate: true, duration: 1200 }
        }
    });

    // ── Stream donut ──
    const streamData = safeJson('<%= hdnStreamData.ClientID %>');
    if (streamData.length) {
        new Chart(document.getElementById('chartStream'), {
            type: 'doughnut',
            data: {
                labels: streamData.map(d => d.label),
                datasets: [{ data: streamData.map(d => d.value), backgroundColor: COLORS, borderWidth: 0 }]
            },
            options: {
                cutout: '55%',
                plugins: { legend: { position: 'bottom', labels: { boxWidth: 10, font: { size: 11 } } } },
                animation: { duration: 1200 }
            }
        });
    }

    // ── Top Courses progress bars ──
    const coursesData = safeJson('<%= hdnTopCourses.ClientID %>');
    const maxC = coursesData.length ? Math.max(...coursesData.map(d => d.value)) : 1;
    const cWrap = document.getElementById('topCoursesList');
    coursesData.forEach((d, i) => {
        const pct = Math.round((d.value / maxC) * 100);
        cWrap.innerHTML += `
        <div class="progress-item">
            <div class="progress-label"><span style="font-size:12px;">${d.label}</span><span style="font-size:12px;font-weight:600;">${d.value}</span></div>
            <div class="progress-bar-bg"><div class="progress-bar" style="background:${COLORS[i%COLORS.length]};width:0%" data-w="${pct}%"></div></div>
        </div>`;
    });

    // ── Subjects bar chart ──
    const subjData = safeJson('<%= hdnTopSubjects.ClientID %>');
        if (subjData.length) {
            new Chart(document.getElementById('chartSubjects'), {
                type: 'bar',
                data: {
                    labels: subjData.map(d => d.label),
                    datasets: [{ label: 'Videos', data: subjData.map(d => d.value), backgroundColor: COLORS, borderRadius: 6 }]
                },
                options: {
                    responsive: true, maintainAspectRatio: false,
                    plugins: { legend: { display: false } },
                    scales: {
                        x: { grid: { display: false }, ticks: { font: { size: 10 } } },
                        y: { beginAtZero: true, grid: { color: '#f1f5f9' } }
                    },
                    animation: { duration: 1000 }
                }
            });
        }

        // Animate progress bars after chart load
        setTimeout(() => {
            document.querySelectorAll('.progress-bar[data-w]').forEach(el => {
                el.style.width = el.dataset.w;
            });
            // Fake quick stats bars (replace with real data if available)
            const quickStats = [
                ['barEngagement', 'pctEngagement', 72],
                ['barAssign', 'pctAssign', 58],
                ['barQuiz', 'pctQuiz', 65],
                ['barVideo', 'pctVideo', 81]
            ];

            quickStats.forEach(([barId, labelId, val]) => {
                const bar = document.getElementById(barId);
                if (bar) bar.style.width = val + '%';

                if (labelId) {
                    const lbl = document.getElementById(labelId);
                    if (lbl) lbl.innerText = val + '%';
                }
            });
        }, 300);
    })();
</script>
</asp:Content>
