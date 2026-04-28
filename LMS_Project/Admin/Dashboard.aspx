<%@ Page Title="Admin Dashboard" Language="C#" 
    MasterPageFile="~/Admin/AdminMaster.Master"
    AutoEventWireup="true"
    CodeBehind="Dashboard.aspx.cs"
    Inherits="LearningManagementSystem.Admin.Dashboard" %>

<asp:Content ID="cHead" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<style>

.toast-msg {
    position: fixed;
    top: 20px;
    right: 20px;
    background: #323232;
    color: #fff;
    padding: 12px 20px;
    border-radius: 8px;
    display:none;
    z-index:9999;
}
    
/* ── Welcome Banner ── */
.welcome-banner {
    background: linear-gradient(135deg, #1565c0 0%, #1976d2 60%, #42a5f5 100%);
    border-radius: 16px;
    padding: 28px 32px;
    color: #fff;
    margin-bottom: 24px;
    position: relative;
    overflow: hidden;
}
.welcome-banner::after {
    content: "\f0c0"; /* users icon */
    font-family: "Font Awesome 6 Free";
    font-weight: 900;
    position: absolute;
    right: 32px;
    top: 50%;
    transform: translateY(-50%);
    font-size: 90px;
    opacity: .12;
}
.welcome-banner h4 { font-weight: 800; margin-bottom: 5px; }
.welcome-banner p { opacity: .85; font-size: 14px; }

.meta-pill {
    display: inline-block;
    background: rgba(255,255,255,.2);
    padding: 4px 14px;
    border-radius: 20px;
    font-size: 12px;
    margin-top: 10px;
}

/* ── Stat Cards (Same as Student) ── */
.stat-card {
    border-radius: 14px;
    padding: 22px;
    display: flex;
    gap: 16px;
    align-items: center;
    box-shadow: 0 2px 10px rgba(0,0,0,.07);
    transition: .2s;
}
.stat-card:hover {
    transform: translateY(-4px);
    box-shadow: 0 6px 18px rgba(0,0,0,.12);
}

.icon-box {
    width: 54px; height: 54px;
    border-radius: 14px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 22px;
}

.stat-label {
    font-size: 11px;
    text-transform: uppercase;
    font-weight: 700;
    color: #78909c;
}

.stat-value {
    font-size: 30px;
    font-weight: 800;
}

.stat-sub {
    font-size: 11px;
    color: #90a4ae;
}

/* COLORS */
.card-blue { background: #e3f2fd; }
.card-orange { background: #fff3e0; }
.card-purple { background: #f3e5f5; }
.card-green { background: #e8f5e9; }

.icon-blue { background: #1976d2; color:#fff; }
.icon-orange { background: #f57c00; color:#fff; }
.icon-purple { background: #7b1fa2; color:#fff; }
.icon-green { background: #2e7d32; color:#fff; }

/* ── Panel Card ── */
.panel-card {
    background:#fff;
    border-radius:14px;
    padding:20px;
    box-shadow:0 2px 8px rgba(0,0,0,.06);
}

/* ── Section Header ── */
.section-header {
    display:flex;
    justify-content:space-between;
    align-items:center;
    margin-bottom:12px;
}
.section-header h6 {
    font-weight:700;
    color:#1565c0;
    margin:0;
}

/* ── Quick Actions (modern pills) ── */
.quick-btn {
    display:inline-block;
    padding:8px 16px;
    background:#e3f2fd;
    border-radius:20px;
    margin:6px;
    font-size:12px;
    font-weight:600;
    color:#1565c0;
    text-decoration:none;
    transition:.2s;
}
.quick-btn:hover {
    background:#1565c0;
    color:#fff;
}

/* ── Activity Rows ── */
.activity-row {
    display:flex;
    align-items:center;
    gap:12px;
    padding:10px 0;
    border-bottom:1px solid #f0f4f8;
}
.activity-row:last-child { border:none; }

.activity-icon {
    width:38px; height:38px;
    border-radius:10px;
    background:#e3f2fd;
    display:flex;
    align-items:center;
    justify-content:center;
    color:#1976d2;
}

/* ── Responsive ── */
@media(max-width:768px){
    .welcome-banner { padding:20px; }
}

</style>

</asp:Content>


<asp:Content ID="cBody" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">
<asp:UpdatePanel ID="UpdatePanel1" runat="server">
<ContentTemplate>

<div id="toastMsg" class="toast-msg"></div>

<!-- ═════ WELCOME ═════ -->
<div class="welcome-banner">
    <h4>Admin Dashboard 👑</h4>
    <p>Monitor and manage your LMS platform efficiently.</p>

   

    <asp:Label ID="lblSelectedSession" runat="server"
        CssClass="meta-pill" />
</div>

<div class="panel-card mb-3">
    <div class="row g-2 align-items-center">

        <div class="col-md-2">
            <asp:TextBox ID="txtFromDate" runat="server" CssClass="form-control" TextMode="Date" />
        </div>

        <div class="col-md-2">
            <asp:TextBox ID="txtToDate" runat="server" CssClass="form-control" TextMode="Date" />
        </div>


        <div class="col-md-2">
            <asp:DropDownList ID="ddlCourse" runat="server"
            CssClass="form-select"
            AutoPostBack="true"
            OnSelectedIndexChanged="FilterChanged" />
        </div>

        <div class="col-md-2">
            <asp:DropDownList ID="ddlSubject" runat="server"
            CssClass="form-select"
            AutoPostBack="true"
            OnSelectedIndexChanged="FilterChanged" />
        </div>

        <div class="col-md-2">
            <asp:Button ID="btnFilter" runat="server" Text="Apply"
                CssClass="btn btn-primary w-100"
                OnClick="btnFilter_Click" />
        </div>

        <div class="col-md-2">
            <asp:Button ID="btnReset" runat="server" Text="Reset"
                CssClass="btn btn-outline-secondary w-100"
                OnClick="btnReset_Click" />
        </div>

    </div>
</div>


<!-- ═════ STATS ═════ -->
<div class="row g-3 mb-4">

    <div class="col-6 col-md-3">
        <div class="stat-card card-blue">
            <div class="icon-box icon-blue"><i class="fas fa-users"></i></div>
            <div>
                <div class="stat-label">Students</div>
                <div class="stat-value"><asp:Label ID="lblStudents" runat="server" /></div>
                <div class="stat-sub">Active</div>
            </div>
        </div>
    </div>

    <div class="col-6 col-md-3">
        <div class="stat-card card-orange">
            <div class="icon-box icon-orange"><i class="fas fa-chalkboard-teacher"></i></div>
            <div>
                <div class="stat-label">Teachers</div>
                <div class="stat-value"><asp:Label ID="lblTeachers" runat="server" /></div>
                <div class="stat-sub">Faculty</div>
            </div>
        </div>
    </div>

    <div class="col-6 col-md-3">
        <div class="stat-card card-purple">
            <div class="icon-box icon-purple"><i class="fas fa-book"></i></div>
            <div>
                <div class="stat-label">Subjects</div>
                <div class="stat-value"><asp:Label ID="lblSubjects" runat="server" /></div>
                <div class="stat-sub">All courses</div>
            </div>
        </div>
    </div>

    <div class="col-6 col-md-3">
        <div class="stat-card card-green">
            <div class="icon-box icon-green"><i class="fas fa-layer-group"></i></div>
            <div>
                <div class="stat-label">Courses</div>
                <div class="stat-value"><asp:Label ID="lblCourses" runat="server" /></div>
                <div class="stat-sub">Programs</div>
            </div>
        </div>
    </div>

</div>

<!-- ═════ ROW 2 ═════ -->
<div class="row g-3">

    <!-- QUICK ACTIONS -->
    <div class="col-md-6">
        <div class="panel-card">
            <div class="section-header">
                <h6><i class="fas fa-bolt me-2"></i>Quick Actions</h6>
            </div>

            <a href="AddStudent.aspx" class="quick-btn">+ Student</a>
            <a href="AddTeacher.aspx" class="quick-btn">+ Teacher</a>
            <a href="AddSubject.aspx" class="quick-btn">+ Subject</a>
            <a href="AddCourse.aspx" class="quick-btn">+ Course</a>
            <a href="AcademicSetup.aspx" class="quick-btn">Academic Setup</a>
            <a href="AssignSubjectFaculty.aspx" class="quick-btn">Assign Teacher</a>
        </div>
    </div>

  

    <div class="col-md-6">
    <div class="panel-card">
        <div class="section-header">
            <h6><i class="fas fa-chart-line me-2"></i>System Activity</h6>
        </div>

        <asp:Repeater ID="rptActivity" runat="server">
            <ItemTemplate>
                <div class="activity-row">
                    <div class="activity-icon">
                        <i class='<%# Eval("Icon") %>'></i>
                    </div>
                    <div>
                        <%# Eval("Message") %>
                        <div class="text-muted small">
                            <%# Eval("TimeAgo") %>
                        </div>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>

        </div>
    </div>

</div>

<div class="row g-3 mt-2">

    <div class="col-md-6">
        <div class="panel-card">
            <h6>📈 Enrollment Trend</h6>
            <canvas id="enrollmentChart" height="180"></canvas>
        </div>
    </div>

    <div class="col-md-6">
        <div class="panel-card">
            <h6>🎯 Course Popularity</h6>
            <canvas id="courseChart" height="180"></canvas>
        </div>
    </div>

</div>

<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<script>
    let enrollmentChartInstance;
    let courseChartInstance;

    function loadCharts(enrollLabels, enrollData, courseLabels, courseData) {

        if (enrollmentChartInstance) enrollmentChartInstance.destroy();
        if (courseChartInstance) courseChartInstance.destroy();

        enrollmentChartInstance = new Chart(document.getElementById("enrollmentChart"), {
            type: 'line',
            data: {
                labels: enrollLabels,
                datasets: [{ data: enrollData, tension: 0.4, fill: true }]
            },
            options: { plugins: { legend: { display: false } } }
        });

        courseChartInstance = new Chart(document.getElementById("courseChart"), {
            type: 'doughnut',
            data: {
                labels: courseLabels,
                datasets: [{ data: courseData }]
            }
        });
    }

    function showToast(msg) {
        let t = document.getElementById("toastMsg");
        t.innerText = msg;
        t.style.display = "block";

        setTimeout(() => {
            t.style.display = "none";
        }, 5000);
    }

    setInterval(function () {
        __doPostBack('<%= UpdatePanel1.UniqueID %>', '');
    }, 15000);

    


</script>

</ContentTemplate>
</asp:UpdatePanel>
</asp:Content>
