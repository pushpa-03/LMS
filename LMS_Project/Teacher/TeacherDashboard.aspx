<%@ Page Title="Dashboard" Language="C#"
    MasterPageFile="~/Teacher/TeacherMaster.Master"
    AutoEventWireup="true"
    CodeBehind="TeacherDashboard.aspx.cs"
    Inherits="LMS_Project.Teacher.TeacherDashboard" %>

<asp:Content ID="cHead" ContentPlaceHolderID="head" runat="server">
<style>

/* ── Welcome Banner ── */
.welcome-banner {
background: linear-gradient(135deg, #1565c0 0%, #1976d2 60%, #42a5f5 100%);    border-radius: 16px;
    padding: 28px 32px;
    color: #fff;
    margin-bottom: 24px;
    position: relative;
    overflow: hidden;
}
.welcome-banner::after {
    content: "\f51c";
    font-family: "Font Awesome 6 Free";
    font-weight: 900;
    position: absolute;
    right: 32px;
    top: 50%;
    transform: translateY(-50%);
    font-size: 90px;
    opacity: .12;
    color: #fff;
}
.welcome-banner h4 { margin: 0 0 4px; font-weight: 800; font-size: 22px; }
.welcome-banner p  { margin: 0; opacity: .85; font-size: 14px; }
.welcome-banner .meta-pill {
    display: inline-block;
    background: rgba(255,255,255,.2);
    border-radius: 20px;
    padding: 3px 14px;
    font-size: 12px;
    margin-right: 6px;
    margin-top: 10px;
}

/* ── Stat Cards ── */
.stat-card {
    border: none;
    border-radius: 14px;
    padding: 22px 20px;
    display: flex;
    align-items: center;
    gap: 16px;
    box-shadow: 0 2px 10px rgba(0,0,0,.07);
    transition: transform .2s, box-shadow .2s;
    cursor: default;
    height: 100%;
}
.stat-card:hover {
    transform: translateY(-4px);
    box-shadow: 0 6px 18px rgba(0,0,0,.12);
}
.stat-card .icon-box {
    width: 54px; height: 54px;
    border-radius: 14px;
    display: flex; align-items: center; justify-content: center;
    font-size: 22px;
    flex-shrink: 0;
}
.stat-card .stat-label {
    font-size: 11px; font-weight: 700;
    text-transform: uppercase;
    letter-spacing: .6px;
    color: #78909c;
    margin-bottom: 2px;
}
.stat-card .stat-value {
    font-size: 32px; font-weight: 800;
    line-height: 1;
    color: #263238;
}
.stat-card .stat-sub {
    font-size: 11px; color: #90a4ae;
    margin-top: 3px;
}

.card-green   { background: #e3f2fd; }
.card-teal    { background: #e1f5fe; }
.card-lime    { background: #f3f8ff; }
.card-orange  { background: #fff3e0; }
.card-purple  { background: #ede7f6; }

.icon-green   { background: #1565c0; color: #fff; }
.icon-teal    { background: #0288d1; color: #fff; }
.icon-lime    { background: #1976d2; color: #fff; }
.icon-orange  { background: #ef6c00; color: #fff; }
.icon-purple  { background: #5e35b1; color: #fff; }
/* ── Section headers ── */
.section-header {
    display: flex; align-items: center;
    justify-content: space-between;
    margin-bottom: 14px;
}
.section-header h6 {
    font-weight: 700; font-size: 15px;
    color: #2e7d32; margin: 0;
}
.section-header a {
    font-size: 12px; color: #388e3c;
    text-decoration: none;
}
.section-header a:hover { text-decoration: underline; }

/* ── Subject Cards ── */
.subject-card {
    border: none;
    border-radius: 12px;
    box-shadow: 0 2px 8px rgba(0,0,0,.06);
    padding: 18px;
    height: 100%;
    transition: transform .2s, box-shadow .2s;
    border-left: 4px solid #1976d2;
    background: #fff;
}
.subject-card:hover {
    transform: translateY(-3px);
    box-shadow: 0 6px 16px rgba(0,0,0,.1);
}
.subject-card .subject-code {
    font-size: 11px; font-weight: 700;
    color: #1976d2;
    text-transform: uppercase;
    letter-spacing: .5px;
    margin-bottom: 4px;
}
.subject-card .subject-name {
    font-size: 14px; font-weight: 700;
    color: #263238;
    margin-bottom: 10px;
    line-height: 1.3;
}
.subject-card .subject-meta {
    font-size: 12px; color: #78909c;
    margin-bottom: 4px;
}
.subject-card .subject-meta i { width: 14px; color: #388e3c; }
.subject-card .btn-view {
    display: inline-block;
    margin-top: 12px;
    padding: 5px 16px;
    background: #e3f2fd;
    color: #1565c0;
    border-radius: 20px;
    font-size: 12px;
    font-weight: 600;
    text-decoration: none;
    transition: background .2s;
}
.subject-card .btn-view:hover { background: #1565c0; color: #fff; }

/* ── Student rows ── */
.student-row {
    display: flex; align-items: center;
    padding: 12px 0;
    border-bottom: 1px solid #e3f2fd;
    gap: 12px;
}
.student-row:last-child { border-bottom: none; }
.student-row .s-avatar {
    width: 38px; height: 38px;
    border-radius: 50%;
    background: #e3f2fd;
    display: flex; align-items: center; justify-content: center;
    flex-shrink: 0;
    color: #1565c0; font-size: 15px; font-weight: 700;
}
.student-row .s-name { font-size: 13px; font-weight: 600; color: #263238; }
.student-row .s-sub  { font-size: 11px; color: #90a4ae; }
.student-row .s-right {
    font-size: 11px;
    margin-left: auto;
    flex-shrink: 0;
    text-align: right;
}

/* ── Assignment rows ── */
.assignment-row {
    display: flex; align-items: center;
    padding: 12px 0;
    border-bottom: 1px solid #e3f2fd;
    gap: 12px;
}
.assignment-row:last-child { border-bottom: none; }
.assignment-row .a-icon {
    width: 38px; height: 38px;
    border-radius: 10px;
    background: #e3f2fd;
    display: flex; align-items: center; justify-content: center;
    flex-shrink: 0;
    color: #1565c0; font-size: 16px;
}
.assignment-row .a-title { font-size: 13px; font-weight: 600; color: #263238; }
.assignment-row .a-sub   { font-size: 11px; color: #90a4ae; }
.assignment-row .a-right {
    font-size: 11px;
    margin-left: auto;
    flex-shrink: 0;
    text-align: right;
}

/* ── Status badges ── */
.badge-active {
    background: #e3f2fd; color: #1565c0;
    padding: 3px 10px; border-radius: 10px;
    font-size: 11px; font-weight: 700;
}

/* ── Quick Actions ── */
.quick-action {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 8px;
    padding: 18px 10px;
    border-radius: 12px;
    text-decoration: none;
    transition: transform .2s, box-shadow .2s;
    font-size: 12px;
    font-weight: 600;
    text-align: center;
}
.quick-action:hover {
    transform: translateY(-3px);
    box-shadow: 0 6px 16px rgba(0,0,0,.12);
    text-decoration: none;
}
.quick-action i { font-size: 22px; }
/* ── Quick Actions ── */
.qa-green  { background: #e3f2fd; color: #1565c0; }
.qa-teal   { background: #e1f5fe; color: #0288d1; }
.qa-orange { background: #fff3e0; color: #ef6c00; }
.qa-purple { background: #ede7f6; color: #5e35b1; }
.qa-lime {background: #f3f8ff; color: #1976d2 }
 .quick-actions-container {
    display: flex;
    flex-wrap: wrap;
    gap: 10px;
}

.qa-item {
    width: calc(20% - 10px); /* 5 items per row */
}

/* Responsive */
@media (max-width: 992px) {
    .qa-item { width: calc(33.33% - 10px); } /* 3 per row */
}

@media (max-width: 576px) {
    .qa-item { width: calc(50% - 10px); } /* 2 per row */
}

/* ── White panel card ── */
.panel-card {
    background: #fff;
    border-radius: 14px;
    box-shadow: 0 2px 8px rgba(0,0,0,.06);
    padding: 20px;
    height: 100%;
}

/* ── Empty state ── */
.empty-state {
    text-align: center;
    padding: 30px 10px;
    color: #90a4ae;
}
.empty-state i { font-size: 36px; margin-bottom: 8px; display: block;  color: #90caf9; }
.empty-state p { font-size: 13px; margin: 0; }


</style>
</asp:Content>

<asp:Content ID="cBody" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

<%-- ══ WELCOME BANNER ══ --%>
<div class="welcome-banner">
    <h4>Welcome back, <asp:Label ID="lblWelcomeName" runat="server" />! 👋</h4>
    <p>Here's an overview of your classes and activities today.</p>
    <asp:Label ID="lblDeptPill"        runat="server" CssClass="meta-pill" />
    <asp:Label ID="lblDesignationPill" runat="server" CssClass="meta-pill" />
    <asp:Label ID="lblSessionPill"     runat="server" CssClass="meta-pill" />
</div>

<%-- ══ STAT CARDS ══ --%>
<div class="row g-3 mb-4">

    <div class="col-6 col-md-3">
        <div class="stat-card card-green">
            <div class="icon-box icon-green">
                <i class="fas fa-book-open"></i>
            </div>
            <div>
                <div class="stat-label">Subjects</div>
                <div class="stat-value"><asp:Label ID="lblTotalSubjects" runat="server" Text="0" /></div>
                <div class="stat-sub">Assigned this session</div>
            </div>
        </div>
    </div>

    <div class="col-6 col-md-3">
        <div class="stat-card card-teal">
            <div class="icon-box icon-teal">
                <i class="fas fa-users"></i>
            </div>
            <div>
                <div class="stat-label">Students</div>
                <div class="stat-value"><asp:Label ID="lblTotalStudents" runat="server" Text="0" /></div>
                <div class="stat-sub">Under your courses</div>
            </div>
        </div>
    </div>

    <div class="col-6 col-md-3">
        <div class="stat-card card-orange">
            <div class="icon-box icon-orange">
                <i class="fas fa-tasks"></i>
            </div>
            <div>
                <div class="stat-label">Assignments</div>
                <div class="stat-value"><asp:Label ID="lblTotalAssignments" runat="server" Text="0" /></div>
                <div class="stat-sub">Active assignments</div>
            </div>
        </div>
    </div>

    <div class="col-6 col-md-3">
        <div class="stat-card card-lime">
            <div class="icon-box icon-lime">
                <i class="fas fa-video"></i>
            </div>
            <div>
                <div class="stat-label">Videos</div>
                <div class="stat-value"><asp:Label ID="lblTotalVideos" runat="server" Text="0" /></div>
                <div class="stat-sub">Course videos uploaded</div>
            </div>
        </div>
    </div>

</div>

<%-- ══ QUICK ACTIONS ══ --%>
<div class="row g-3 mb-4">
    <div class="col-12">
        <div class="panel-card">
            <div class="section-header">
                <h6><i class="fas fa-bolt me-2"></i>Quick Actions</h6>
            </div>
            <div class="quick-actions-container">
                <div class="qa-item">
                    <a href="TeacherAssignment.aspx" class="quick-action qa-green">
                        <i class="fas fa-upload"></i>
                        Upload Assignment
                    </a>
                </div>
                <div class="qa-item">
                    <a href="TeacherAttendance.aspx" class="quick-action qa-teal">
                        <i class="fas fa-clipboard-check"></i>
                        Attendance
                    </a>
                </div>
                <div class="qa-item">
    <a href="Subjects.aspx" class="quick-action qa-lime">
        <i class="fas fa-video"></i>
        Course Videos
    </a>
</div>
                <div class="qa-item">
                    <a href="MyStudents.aspx" class="quick-action qa-purple">
                        <i class="fas fa-users"></i>
                        View My Students
                    </a>
                </div>
                <div class="qa-item">
                    <a href="TeacherCalendar.aspx" class="quick-action qa-orange">
                        <i class="fas fa-calendar-alt"></i>
                        Open Calendar
                    </a>
                </div>
            </div>
        </div>
    </div>
</div>

<%-- ══ SUBJECTS + RECENT STUDENTS ══ --%>
<div class="row g-3 mb-4">

    <%-- LEFT: Subjects (col-md-8) --%>
    <div class="col-md-8">
    <div class="panel-card">
        <div class="section-header">
            <h6><i class="fas fa-book-open me-2"></i>My Subjects</h6>
            <a href="TeacherCourses.aspx">View all &rarr;</a>
        </div>

        <%-- KPI Mini Cards --%>
        <asp:Panel ID="pnlSubjectKPIs" runat="server">
            <div class="row g-2 mb-3">
                <div class="col-6 col-md-3">
                    <div style="background:#e3f2fd;border-radius:10px;padding:10px 12px;">
                        <div style="font-size:10px;font-weight:700;color:#1565c0;text-transform:uppercase;letter-spacing:.5px;">Total Subjects</div>
                        <div style="font-size:22px;font-weight:800;color:#1565c0;">
                            <asp:Label ID="lblKpiTotalSubjects" runat="server" Text="0" />
                        </div>
                    </div>
                </div>
                <div class="col-6 col-md-3">
                    <div style="background:#e8f5e9;border-radius:10px;padding:10px 12px;">
                        <div style="font-size:10px;font-weight:700;color:#2e7d32;text-transform:uppercase;letter-spacing:.5px;">Total Students</div>
                        <div style="font-size:22px;font-weight:800;color:#2e7d32;">
                            <asp:Label ID="lblKpiTotalStudents" runat="server" Text="0" />
                        </div>
                    </div>
                </div>
                <div class="col-6 col-md-3">
                    <div style="background:#fff3e0;border-radius:10px;padding:10px 12px;">
                        <div style="font-size:10px;font-weight:700;color:#ef6c00;text-transform:uppercase;letter-spacing:.5px;">Avg / Subject</div>
                        <div style="font-size:22px;font-weight:800;color:#ef6c00;">
                            <asp:Label ID="lblKpiAvgStudents" runat="server" Text="0" />
                        </div>
                    </div>
                </div>
                <div class="col-6 col-md-3">
                    <div style="background:#ede7f6;border-radius:10px;padding:10px 12px;">
                        <div style="font-size:10px;font-weight:700;color:#5e35b1;text-transform:uppercase;letter-spacing:.5px;">Most Enrolled</div>
                        <div style="font-size:15px;font-weight:800;color:#5e35b1;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">
                            <asp:Label ID="lblKpiTopSubject" runat="server" Text="-" />
                        </div>
                    </div>
                </div>
            </div>
        </asp:Panel>

        <%-- Chart --%>
        <asp:Panel ID="pnlSubjectsChart" runat="server">
            <div style="font-size:11px;font-weight:700;color:#78909c;text-transform:uppercase;letter-spacing:.5px;margin-bottom:6px;">
                Students per Subject &nbsp;<span style="font-size:10px;color:#90a4ae;font-weight:400;">(click any bar to manage)</span>
            </div>
            <div style="position:relative;height:260px;">
                <canvas id="subjectChart"
                        role="img"
                        aria-label="Bar chart showing number of students per subject"></canvas>
            </div>
            <asp:HiddenField ID="hfChartData" runat="server" />
        </asp:Panel>

        <%-- Top subjects table --%>
        <asp:Panel ID="pnlSubjectTable" runat="server">
            <div style="font-size:11px;font-weight:700;color:#78909c;text-transform:uppercase;letter-spacing:.5px;margin:16px 0 8px;">
                Subject Breakdown
            </div>
            <div class="table-responsive">
                <table class="table table-sm align-middle" style="font-size:12px;">
                    <thead style="background:#e3f2fd;color:#1565c0;">
                        <tr>
                            <th>#</th>
                            <th>Subject</th>
                            <th>Code</th>
                            <th>Students</th>
                            <th>Enrolment</th>
                            <th></th>
                        </tr>
                    </thead>
                    <tbody>
                        <asp:Repeater ID="rptSubjectTable" runat="server">
                            <ItemTemplate>
                                <tr>
                                    <td style="color:#90a4ae;"><%# Container.ItemIndex + 1 %></td>
                                    <td><strong><%# Eval("SubjectName") %></strong></td>
                                    <td>
                                        <span class="badge" style="background:#e3f2fd;color:#1565c0;font-size:10px;">
                                            <%# Eval("SubjectCode") %>
                                        </span>
                                    </td>
                                    <td>
                                        <span style="font-weight:700;color:#263238;"><%# Eval("StudentCount") %></span>
                                    </td>
                                    <td style="min-width:100px;">
                                        <div class="progress" style="height:6px;border-radius:10px;">
                                            <div class="progress-bar"
                                                 role="progressbar"
                                                 style="width:<%# Eval("EnrolmentPercent") %>%;background:#1565c0;border-radius:10px;"
                                                 aria-valuenow='<%# Eval("EnrolmentPercent") %>'
                                                 aria-valuemin="0" aria-valuemax="100">
                                            </div>
                                        </div>
                                        <div style="font-size:10px;color:#90a4ae;margin-top:2px;">
                                            <%# Eval("EnrolmentPercent") %>% of total
                                        </div>
                                    </td>
                                    <td>
                                        <a href='CourseVideos.aspx?SubjectId=<%# Eval("SubjectId") %>'
                                           class="btn-view" style="padding:3px 10px;font-size:11px;">
                                            <i class="fas fa-play-circle me-1"></i>Manage
                                        </a>
                                    </td>
                                </tr>
                            </ItemTemplate>
                        </asp:Repeater>
                    </tbody>
                </table>
            </div>
        </asp:Panel>

        <%-- Empty state --%>
        <asp:Panel ID="pnlNoSubjects" runat="server" Visible="false">
            <div class="empty-state">
                <i class="fas fa-book-open"></i>
                <p>No subjects assigned yet.<br />Contact your admin.</p>
            </div>
        </asp:Panel>

    </div>
</div>

    <%-- RIGHT: Recent Students (col-md-4) --%>
    <div class="col-md-4">
    <div class="panel-card">
        <div class="section-header">
            <h6><i class="fas fa-users me-2"></i>Student Analytics</h6>
            <a href="MyStudents.aspx">View all &rarr;</a>
        </div>
        <div class="d-flex flex-wrap gap-2 mb-3">

    <asp:DropDownList ID="ddlStudentSession" runat="server"
        CssClass="form-select form-select-sm"
        Style="width:auto; min-width:120px;"
        AutoPostBack="true"
        OnSelectedIndexChanged="ddlStudentSession_SelectedIndexChanged">
    </asp:DropDownList>

    <asp:DropDownList ID="ddlStudentSection" runat="server"
        CssClass="form-select form-select-sm"
        Style="width:auto; min-width:120px;"
        AutoPostBack="true"
        OnSelectedIndexChanged="ddlStudentSection_SelectedIndexChanged">
    </asp:DropDownList>

    <asp:DropDownList ID="ddlStudentStream" runat="server"
        CssClass="form-select form-select-sm"
        Style="width:auto; min-width:120px;"
        AutoPostBack="true"
        OnSelectedIndexChanged="ddlStudentStream_SelectedIndexChanged">
    </asp:DropDownList>

</div>
        <%-- KPI mini cards --%>
        <div class="row g-2 mb-3">
            <div class="col-6">
                <div style="background:#e3f2fd;border-radius:10px;padding:10px 12px;">
                    <div style="font-size:10px;font-weight:700;color:#1565c0;text-transform:uppercase;letter-spacing:.5px;">Total Students</div>
                    <div style="font-size:22px;font-weight:800;color:#1565c0;">
                        <asp:Label ID="lblAnalyticStudents" runat="server" Text="0" />
                    </div>
                </div>
            </div>
            <div class="col-6">
                <div style="background:#e8f5e9;border-radius:10px;padding:10px 12px;">
                    <div style="font-size:10px;font-weight:700;color:#2e7d32;text-transform:uppercase;letter-spacing:.5px;">Divisions</div>
                    <div style="font-size:22px;font-weight:800;color:#2e7d32;">
                        <asp:Label ID="lblAnalyticDivisions" runat="server" Text="0" />
                    </div>
                </div>
            </div>
            <div class="col-6">
                <div style="background:#fff3e0;border-radius:10px;padding:10px 12px;">
                    <div style="font-size:10px;font-weight:700;color:#ef6c00;text-transform:uppercase;letter-spacing:.5px;">Subjects</div>
                    <div style="font-size:22px;font-weight:800;color:#ef6c00;">
                        <asp:Label ID="lblAnalyticSubjects" runat="server" Text="0" />
                    </div>
                </div>
            </div>
            <div class="col-6">
                <div style="background:#ede7f6;border-radius:10px;padding:10px 12px;">
                    <div style="font-size:10px;font-weight:700;color:#5e35b1;text-transform:uppercase;letter-spacing:.5px;">Avg / Subject</div>
                    <div style="font-size:22px;font-weight:800;color:#5e35b1;">
                        <asp:Label ID="lblAnalyticAvg" runat="server" Text="0" />
                    </div>
                </div>
            </div>
        </div>

        <%-- Division chart --%>
        <asp:Panel ID="pnlStudents" runat="server">
            <div style="font-size:11px;font-weight:700;color:#78909c;text-transform:uppercase;letter-spacing:.5px;margin-bottom:8px;">
                Students by Division
            </div>
            <asp:HiddenField ID="hfDivisionData" runat="server" />
            <div style="position:relative; height:200px;">
                <canvas id="divisionChart" 
                    role="img" 
                    aria-label="Bar chart showing number of students per division">
                </canvas>
            </div>
        </asp:Panel>

        <asp:Panel ID="pnlNoStudents" runat="server" Visible="false">
            <div class="empty-state">
                <i class="fas fa-user-slash"></i>
                <p>No students found.</p>
            </div>
        </asp:Panel>

    </div>
</div>

<%-- ══ RECENT ASSIGNMENTS ══ --%>
<div class="row g-3">
    <div class="col-md-8">
        <div class="panel-card">
            <div class="section-header">
                <h6><i class="fas fa-tasks me-2"></i>Recent Assignments</h6>
                <a href="TeacherAssignment.aspx">View all &rarr;</a>
            </div>

            <%-- Filter + View Toggle --%>
            <div class="d-flex flex-wrap align-items-center gap-2 mb-3">

                <div class="btn-group btn-group-sm" role="group">
                    <button type="button" id="btnAsgList" onclick="setAsgView('list')"
                            class="btn btn-primary" title="List View">
                        <i class="fas fa-list"></i>
                    </button>
                    <button type="button" id="btnAsgChart" onclick="setAsgView('chart')"
                            class="btn btn-outline-primary" title="Chart View">
                        <i class="fas fa-chart-bar"></i>
                    </button>
                </div>

                <asp:DropDownList ID="ddlAsgSubject" runat="server"
                    CssClass="form-select form-select-sm"
                    Style="width:auto; min-width:160px;"
                    AutoPostBack="true"
                    OnSelectedIndexChanged="ddlAsgSubject_SelectedIndexChanged">
                </asp:DropDownList>

            </div>

            <%-- LIST VIEW --%>
            <asp:Panel ID="pnlAssignments" runat="server">
                <asp:Repeater ID="rptAssignments" runat="server">
                    <ItemTemplate>
                        <div class="assignment-row">
                            <div class="a-icon"><i class="fas fa-file-alt"></i></div>
                            <div>
                                <div class="a-title"><%# Eval("Title") %></div>
                                <div class="a-sub">
                                    <i class="fas fa-book me-1"></i><%# Eval("SubjectName") %>
                                    &nbsp;|&nbsp;
                                    <i class="fas fa-star me-1"></i><%# Eval("MaxMarks") %> marks
                                </div>
                            </div>
                            <div class="a-right">
                                <div class="mb-1">
                                    <i class="far fa-calendar-alt me-1"></i>
                                    Due: <%# Eval("DueDate", "{0:dd MMM yyyy}") %>
                                </div>
                                <div>
                                    <i class="fas fa-paper-plane me-1 text-success"></i>
                                    <%# Eval("SubmissionCount") %> / <%# Eval("TotalStudents") %> submitted
                                </div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </asp:Panel>

            <%-- CHART VIEW --%>
            <asp:Panel ID="pnlAsgChart" runat="server" Visible="false">
                <div style="position:relative; height:300px;">
                    <canvas id="asgChart"></canvas>
                </div>
                <asp:HiddenField ID="hfAsgChartData" runat="server" />
            </asp:Panel>

            <%-- EMPTY STATE --%>
            <asp:Panel ID="pnlNoAssignments" runat="server" Visible="false">
                <div class="empty-state">
                    <i class="fas fa-clipboard-check" style="color:#2e7d32;"></i>
                    <p>No assignments found.<br />
                        <a href="TeacherAssignment.aspx" style="color:#2e7d32;">
                            Create your first assignment &rarr;
                        </a>
                    </p>
                </div>
            </asp:Panel>

        </div>
    </div>

    <%-- Submission summary side card --%>
    <div class="col-md-4">
        <div class="panel-card">
            <div class="section-header">
                <h6><i class="fas fa-paper-plane me-2"></i>Submission Summary</h6>
            </div>

            <asp:Panel ID="pnlAsgSummary" runat="server">
                <asp:Repeater ID="rptAsgSummary" runat="server">
                    <ItemTemplate>
                        <div style="margin-bottom:14px;">
                            <div class="d-flex justify-content-between mb-1">
                                <span style="font-size:12px; font-weight:600; color:#263238;">
                                    <%# Eval("Title") %>
                                </span>
                                <span style="font-size:11px; color:#78909c;">
                                    <%# Eval("SubmissionCount") %>/<%# Eval("TotalStudents") %>
                                </span>
                            </div>
                            <div class="progress" style="height:7px; border-radius:10px;">
                                <div class="progress-bar"
                                     role="progressbar"
                                     style="width:<%# Eval("SubmissionPercent") %>%;
                                            background:#1565c0; border-radius:10px;"
                                     aria-valuenow='<%# Eval("SubmissionPercent") %>'
                                     aria-valuemin="0" aria-valuemax="100">
                                </div>
                            </div>
                            <div style="font-size:10px; color:#90a4ae; margin-top:2px;">
                                <%# Eval("SubmissionPercent") %>% submitted
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </asp:Panel>

            <asp:Panel ID="pnlNoAsgSummary" runat="server" Visible="false">
                <div class="empty-state">
                    <i class="fas fa-chart-pie"></i>
                    <p>No submission data yet.</p>
                </div>
            </asp:Panel>

        </div>
    </div>
</div>
<%-- ══ STUDENT PERFORMANCE ══ --%>
<div class="row g-3 mt-2">
    <div class="col-12">
        <div class="panel-card">
            <div class="section-header">
                <h6><i class="fas fa-chart-line me-2"></i>Student Performance</h6>
                <a href="MyStudents.aspx">View all &rarr;</a>
            </div>

            <%-- KPI Row --%>
            <asp:Panel ID="pnlPerfKPIs" runat="server">
                <div class="row g-2 mb-4">
                    <div class="col-6 col-md-3">
                        <div style="background:#e3f2fd;border-radius:10px;padding:10px 14px;">
                            <div style="font-size:10px;font-weight:700;color:#1565c0;text-transform:uppercase;letter-spacing:.5px;">Avg Marks</div>
                            <div style="font-size:26px;font-weight:800;color:#1565c0;">
                                <asp:Label ID="lblPerfAvgMarks" runat="server" Text="0" />
                            </div>
                            <div style="font-size:10px;color:#90a4ae;">across all subjects</div>
                        </div>
                    </div>
                    <div class="col-6 col-md-3">
                        <div style="background:#e8f5e9;border-radius:10px;padding:10px 14px;">
                            <div style="font-size:10px;font-weight:700;color:#2e7d32;text-transform:uppercase;letter-spacing:.5px;">Highest Score</div>
                            <div style="font-size:26px;font-weight:800;color:#2e7d32;">
                                <asp:Label ID="lblPerfHighest" runat="server" Text="0" />
                            </div>
                            <div style="font-size:10px;color:#90a4ae;">best submission</div>
                        </div>
                    </div>
                    <div class="col-6 col-md-3">
                        <div style="background:#fff3e0;border-radius:10px;padding:10px 14px;">
                            <div style="font-size:10px;font-weight:700;color:#ef6c00;text-transform:uppercase;letter-spacing:.5px;">Lowest Score</div>
                            <div style="font-size:26px;font-weight:800;color:#ef6c00;">
                                <asp:Label ID="lblPerfLowest" runat="server" Text="0" />
                            </div>
                            <div style="font-size:10px;color:#90a4ae;">needs attention</div>
                        </div>
                    </div>
                    <div class="col-6 col-md-3">
                        <div style="background:#ede7f6;border-radius:10px;padding:10px 14px;">
                            <div style="font-size:10px;font-weight:700;color:#5e35b1;text-transform:uppercase;letter-spacing:.5px;">Submissions</div>
                            <div style="font-size:26px;font-weight:800;color:#5e35b1;">
                                <asp:Label ID="lblPerfSubmissions" runat="server" Text="0" />
                            </div>
                            <div style="font-size:10px;color:#90a4ae;">total graded</div>
                        </div>
                    </div>
                </div>
            </asp:Panel>

            <%-- Three columns side by side --%>
            <div class="row g-3">

                <%-- TOP 5 STUDENTS --%>
                <div class="col-md-4">
                    <div style="background:#f8fbff;border-radius:12px;padding:16px;height:100%;">
                        <div style="font-size:11px;font-weight:700;color:#1565c0;text-transform:uppercase;letter-spacing:.5px;margin-bottom:12px;">
                            <i class="fas fa-trophy me-1" style="color:#f9a825;"></i> Top 5 Students
                        </div>
                        <asp:Panel ID="pnlTopStudents" runat="server">
                            <asp:Repeater ID="rptTopStudents" runat="server">
                                <ItemTemplate>
                                    <div onclick='openStudentModal(<%# Eval("StudentId") %>, "<%# Eval("StudentName") %>", "<%# Eval("SubjectName") %>")'
                                         style="display:flex;align-items:center;gap:10px;padding:9px 0;border-bottom:1px solid #e3f2fd;cursor:pointer;border-radius:8px;transition:background .15s;"
                                         onmouseover="this.style.background='#f0f7ff';this.style.paddingLeft='6px'"
                                         onmouseout="this.style.background='';this.style.paddingLeft='0'">
                                        <div style="width:26px;height:26px;border-radius:50%;background:<%# GetRankColor(Container.ItemIndex) %>;display:flex;align-items:center;justify-content:center;font-size:11px;font-weight:800;color:#fff;flex-shrink:0;">
                                            <%# Container.ItemIndex + 1 %>
                                        </div>
                                        <div style="flex:1;min-width:0;">
                                            <div style="font-size:12px;font-weight:700;color:#263238;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">
                                                <%# Eval("StudentName") %>
                                            </div>
                                            <div style="font-size:10px;color:#90a4ae;">
                                                <%# Eval("SubjectName") %>
                                            </div>
                                        </div>
                                        <div style="text-align:right;flex-shrink:0;">
                                            <div style="font-size:13px;font-weight:800;color:#1565c0;">
                                                <%# Eval("MarksObtained") %><span style="font-size:10px;color:#90a4ae;">/<%# Eval("MaxMarks") %></span>
                                            </div>
                                            <div style="font-size:10px;color:#2e7d32;font-weight:600;">
                                                <%# Eval("Percentage") %>%
                                            </div>
                                        </div>
                                        <div style="flex-shrink:0;color:#90a4ae;font-size:11px;">
                                            <i class="fas fa-chevron-right"></i>
                                        </div>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                        </asp:Panel>
                        <asp:Panel ID="pnlNoTopStudents" runat="server" Visible="false">
                            <div class="empty-state">
                                <i class="fas fa-user-graduate" style="font-size:28px;color:#90caf9;display:block;margin-bottom:6px;"></i>
                                <p style="font-size:12px;color:#90a4ae;margin:0;">No graded submissions yet.</p>
                            </div>
                        </asp:Panel>
                    </div>
                </div>

                <%-- LOW PERFORMERS --%>
                <div class="col-md-4">
                    <div style="background:#fff8f5;border-radius:12px;padding:16px;height:100%;">
                        <div style="font-size:11px;font-weight:700;color:#ef6c00;text-transform:uppercase;letter-spacing:.5px;margin-bottom:12px;">
                            <i class="fas fa-exclamation-triangle me-1" style="color:#ef6c00;"></i> Needs Attention
                        </div>
                        <asp:Panel ID="pnlLowStudents" runat="server">
                            <asp:Repeater ID="rptLowStudents" runat="server">
                                <ItemTemplate>
                                    <div onclick='openStudentModal(<%# Eval("StudentId") %>, "<%# Eval("StudentName") %>", "<%# Eval("SubjectName") %>")'
                                         style="display:flex;align-items:center;gap:10px;padding:9px 0;border-bottom:1px solid #ffe0cc;cursor:pointer;border-radius:8px;transition:background .15s;"
                                         onmouseover="this.style.background='#fff3ee';this.style.paddingLeft='6px'"
                                         onmouseout="this.style.background='';this.style.paddingLeft='0'">
                                        <div style="width:26px;height:26px;border-radius:50%;background:#ffccbc;display:flex;align-items:center;justify-content:center;flex-shrink:0;">
                                            <i class="fas fa-user" style="font-size:11px;color:#bf360c;"></i>
                                        </div>
                                        <div style="flex:1;min-width:0;">
                                            <div style="font-size:12px;font-weight:700;color:#263238;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">
                                                <%# Eval("StudentName") %>
                                            </div>
                                            <div style="font-size:10px;color:#90a4ae;">
                                                <%# Eval("SubjectName") %>
                                            </div>
                                        </div>
                                        <div style="text-align:right;flex-shrink:0;">
                                            <div style="font-size:13px;font-weight:800;color:#ef6c00;">
                                                <%# Eval("MarksObtained") %><span style="font-size:10px;color:#90a4ae;">/<%# Eval("MaxMarks") %></span>
                                            </div>
                                            <div style="font-size:10px;color:#c62828;font-weight:600;">
                                                <%# Eval("Percentage") %>%
                                            </div>
                                        </div>
                                        <div style="flex-shrink:0;color:#90a4ae;font-size:11px;">
                                            <i class="fas fa-chevron-right"></i>
                                        </div>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                        </asp:Panel>
                        <asp:Panel ID="pnlNoLowStudents" runat="server" Visible="false">
                            <div class="empty-state">
                                <i class="fas fa-check-circle" style="font-size:28px;color:#a5d6a7;display:block;margin-bottom:6px;"></i>
                                <p style="font-size:12px;color:#90a4ae;margin:0;">All students performing well!</p>
                            </div>
                        </asp:Panel>
                    </div>
                </div>

                <%-- AVG MARKS PER SUBJECT + PIE --%>
                <div class="col-md-4">
                    <div style="background:#f5f5f5;border-radius:12px;padding:16px;height:100%;">
                        <div style="font-size:11px;font-weight:700;color:#5e35b1;text-transform:uppercase;letter-spacing:.5px;margin-bottom:12px;">
                            <i class="fas fa-chart-pie me-1"></i> Avg Marks per Subject
                        </div>

                        <asp:Panel ID="pnlAvgMarksChart" runat="server">
                            <div style="position:relative;height:180px;margin-bottom:12px;">
                                <canvas id="avgMarksChart"
                                        role="img"
                                        aria-label="Pie chart showing average marks per subject"></canvas>
                            </div>
                            <asp:HiddenField ID="hfAvgMarksData" runat="server" />

                            <asp:Repeater ID="rptAvgMarks" runat="server">
                                <ItemTemplate>
                                    <div style="display:flex;align-items:center;justify-content:space-between;padding:5px 0;border-bottom:1px solid #ede7f6;font-size:11px;">
                                        <div style="display:flex;align-items:center;gap:6px;">
                                            <div style="width:10px;height:10px;border-radius:50%;background:<%# Eval("Color") %>;flex-shrink:0;"></div>
                                            <span style="color:#263238;font-weight:600;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;max-width:120px;">
                                                <%# Eval("SubjectName") %>
                                            </span>
                                        </div>
                                        <div style="text-align:right;">
                                            <span style="font-weight:800;color:#5e35b1;"><%# Eval("AvgMarks") %></span>
                                            <span style="color:#90a4ae;"> / <%# Eval("MaxMarks") %></span>
                                        </div>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                        </asp:Panel>

                        <asp:Panel ID="pnlNoAvgMarks" runat="server" Visible="false">
                            <div class="empty-state">
                                <i class="fas fa-chart-pie" style="font-size:28px;color:#ce93d8;display:block;margin-bottom:6px;"></i>
                                <p style="font-size:12px;color:#90a4ae;margin:0;">No marks data available yet.</p>
                            </div>
                        </asp:Panel>
                    </div>
                </div>

            </div>
        </div>
    </div>
</div>


<%-- Chart.js (only loaded once, safe to add here) --%>
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
<script>
    // ── Subject Chart ────────────────────────────────────────────
    var chartInstance = null;

    function renderSubjectChart() {
        var hf = document.getElementById('<%= hfChartData.ClientID %>');
        if (!hf || !hf.value) return;
        var data;
        try { data = JSON.parse(hf.value); } catch (e) { return; }
        var ctx = document.getElementById('subjectChart');
        if (!ctx) return;
        if (chartInstance) { chartInstance.destroy(); chartInstance = null; }

        var labels = data.map(function (d) { return d.SubjectName; });
        var counts = data.map(function (d) { return d.StudentCount; });
        var subIds = data.map(function (d) { return d.SubjectId; });
        var colors = ['#1565c0', '#0288d1', '#1976d2', '#ef6c00', '#5e35b1',
            '#388e3c', '#c62828', '#00838f', '#4527a0', '#2e7d32'];

        chartInstance = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: labels,
                datasets: [{
                    label: 'Students Enrolled',
                    data: counts,
                    backgroundColor: labels.map(function (_, i) { return colors[i % colors.length] + 'cc'; }),
                    borderColor: labels.map(function (_, i) { return colors[i % colors.length]; }),
                    borderWidth: 2,
                    borderRadius: 8
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: false },
                    tooltip: { callbacks: { label: function (c) { return ' ' + c.parsed.y + ' students'; } } }
                },
                scales: {
                    y: { beginAtZero: true, ticks: { stepSize: 1, font: { size: 11 } }, grid: { color: '#e3f2fd' } },
                    x: { ticks: { font: { size: 11 }, maxRotation: 30 }, grid: { display: false } }
                },
                onClick: function (evt, elements) {
                    if (elements.length > 0)
                        window.location.href = 'CourseVideos.aspx?SubjectId=' + subIds[elements[0].index];
                }
            }
        });
        ctx.style.cursor = 'pointer';
    }

    // ── Assignment View Switcher ──────────────────────────────────
    function setAsgView(v) {
        ['btnAsgList', 'btnAsgChart'].forEach(function (id) {
            var el = document.getElementById(id);
            if (!el) return;
            el.className = el.className.replace('btn-primary', 'btn-outline-primary');
        });
        var activeEl = document.getElementById(v === 'list' ? 'btnAsgList' : 'btnAsgChart');
        if (activeEl) activeEl.className = activeEl.className.replace('btn-outline-primary', 'btn-primary');

        var list = document.getElementById('<%= pnlAssignments.ClientID %>');
        var chart = document.getElementById('<%= pnlAsgChart.ClientID %>');
        if (list)  list.style.display  = (v === 'list')  ? '' : 'none';
        if (chart) chart.style.display = (v === 'chart') ? '' : 'none';
        if (v === 'chart') renderAsgChart();
    }

    var asgChartInstance = null;

    function renderAsgChart() {
        var hf = document.getElementById('<%= hfAsgChartData.ClientID %>');
        if (!hf || !hf.value) return;
        var data;
        try { data = JSON.parse(hf.value); } catch (e) { return; }
        var ctx = document.getElementById('asgChart');
        if (!ctx) return;
        if (asgChartInstance) { asgChartInstance.destroy(); asgChartInstance = null; }

        asgChartInstance = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: data.map(function (d) { return d.Title; }),
                datasets: [
                    { label: 'Submitted', data: data.map(function (d) { return d.SubmissionCount; }),
                      backgroundColor: '#1565c0cc', borderColor: '#1565c0', borderWidth: 2, borderRadius: 6 },
                    { label: 'Pending',   data: data.map(function (d) { return d.Pending; }),
                      backgroundColor: '#ef6c00cc', borderColor: '#ef6c00', borderWidth: 2, borderRadius: 6 }
                ]
            },
            options: {
                responsive: true, maintainAspectRatio: false,
                plugins: {
                    legend: { display: true, position: 'top', labels: { font: { size: 11 } } },
                    tooltip: { callbacks: { label: function (c) { return ' ' + c.dataset.label + ': ' + c.parsed.y + ' students'; } } }
                },
                scales: {
                    x: { ticks: { font: { size: 10 }, maxRotation: 30 }, grid: { display: false } },
                    y: { beginAtZero: true, ticks: { stepSize: 1, font: { size: 11 } }, grid: { color: '#e3f2fd' } }
                }
            }
        });
    }

    // ── Division Chart ────────────────────────────────────────────
    function renderDivisionChart() {
        var hf = document.getElementById('<%= hfDivisionData.ClientID %>');
        if (!hf || !hf.value) return;
        var data;
        try { data = JSON.parse(hf.value); } catch (e) { return; }
        var ctx = document.getElementById('divisionChart');
        if (!ctx) return;

        var colors = ['#1565c0','#2e7d32','#ef6c00','#5e35b1','#0288d1','#c62828'];
        new Chart(ctx, {
            type: 'bar',
            data: {
                labels: data.map(function (d) { return d.Division; }),
                datasets: [{
                    label: 'Students',
                    data: data.map(function (d) { return d.StudentCount; }),
                    backgroundColor: data.map(function (_, i) { return colors[i % colors.length] + 'cc'; }),
                    borderColor:     data.map(function (_, i) { return colors[i % colors.length]; }),
                    borderWidth: 2, borderRadius: 6
                }]
            },
            options: {
                responsive: true, maintainAspectRatio: false,
                plugins: { legend: { display: false },
                    tooltip: { callbacks: { label: function (c) { return ' ' + c.parsed.y + ' students'; } } } },
                scales: {
                    y: { beginAtZero: true, ticks: { stepSize: 1, font: { size: 10 } }, grid: { color: '#e3f2fd' } },
                    x: { ticks: { font: { size: 10 }, maxRotation: 30 }, grid: { display: false } }
                }
            }
        });
    }

    // ── Avg Marks Pie Chart ───────────────────────────────────────
    function renderAvgMarksChart() {
        var hf = document.getElementById('<%= hfAvgMarksData.ClientID %>');
        if (!hf || !hf.value) return;
        var data;
        try { data = JSON.parse(hf.value); } catch (e) { return; }
        var ctx = document.getElementById('avgMarksChart');
        if (!ctx) return;

        new Chart(ctx, {
            type: 'pie',
            data: {
                labels: data.map(function (d) { return d.SubjectName; }),
                datasets: [{
                    data: data.map(function (d) { return d.AvgMarks; }),
                    backgroundColor: data.map(function (d) { return d.Color + 'cc'; }),
                    borderColor: data.map(function (d) { return d.Color; }),
                    borderWidth: 2
                }]
            },
            options: {
                responsive: true, maintainAspectRatio: false,
                plugins: {
                    legend: { display: false },
                    tooltip: { callbacks: { label: function (c) { return ' ' + c.label + ': ' + c.parsed + ' avg marks'; } } }
                }
            }
        });
    }

    // ── Student Marks Modal ───────────────────────────────────────
    var studentMarksChartInstance = null;

    function openStudentModal(studentId, studentName, subjectName) {
        // Set header info
        document.getElementById('modalStudentName').textContent = studentName;
        document.getElementById('modalStudentMeta').textContent = subjectName;

        // Reset UI
        document.getElementById('modalLoader').style.display = 'block';
        document.getElementById('modalKpiRow').style.display = 'none';
        document.getElementById('studentMarksChart').style.display = 'none';
        document.getElementById('modalAsgTable').style.display = 'none';
        document.getElementById('modalEmpty').style.display = 'none';

        // Show modal
        var modal = new bootstrap.Modal(document.getElementById('studentMarksModal'));
        modal.show();

        // Fetch data
        fetch('GetStudentMarks.ashx?studentId=' + studentId)
            .then(function (r) { return r.json(); })
            .then(function (data) {
                document.getElementById('modalLoader').style.display = 'none';

                if (!Array.isArray(data) || data.length === 0) {
                    document.getElementById('modalEmpty').style.display = 'block';
                    return;
                }

                // ── KPIs ──
                var total = data.length;
                var sumMarks = data.reduce(function (s, d) { return s + d.MarksObtained; }, 0);
                var avg = Math.round(sumMarks / total);
                var highest = Math.max.apply(null, data.map(function (d) { return d.MarksObtained; }));
                var lowest = Math.min.apply(null, data.map(function (d) { return d.MarksObtained; }));

                document.getElementById('modalTotalAsg').textContent = total;
                document.getElementById('modalAvgMarks').textContent = avg;
                document.getElementById('modalHighest').textContent = highest;
                document.getElementById('modalLowest').textContent = lowest;
                document.getElementById('modalKpiRow').style.display = '';

                // ── Chart ──
                var canvas = document.getElementById('studentMarksChart');
                canvas.style.display = '';

                if (studentMarksChartInstance) {
                    studentMarksChartInstance.destroy();
                    studentMarksChartInstance = null;
                }

                var labels = data.map(function (d) { return d.AssignmentTitle; });
                var obtained = data.map(function (d) { return d.MarksObtained; });
                var maxMarks = data.map(function (d) { return d.MaxMarks; });
                var pcts = data.map(function (d) { return d.Percentage; });

                // Color bar by performance
                var barColors = pcts.map(function (p) {
                    if (p >= 80) return '#2e7d32cc';
                    if (p >= 60) return '#1565c0cc';
                    if (p >= 50) return '#ef6c00cc';
                    return '#c62828cc';
                });
                var borderColors = pcts.map(function (p) {
                    if (p >= 80) return '#2e7d32';
                    if (p >= 60) return '#1565c0';
                    if (p >= 50) return '#ef6c00';
                    return '#c62828';
                });

                studentMarksChartInstance = new Chart(canvas, {
                    type: 'bar',
                    data: {
                        labels: labels,
                        datasets: [
                            {
                                label: 'Marks Obtained',
                                data: obtained,
                                backgroundColor: barColors,
                                borderColor: borderColors,
                                borderWidth: 2,
                                borderRadius: 8,
                                order: 1
                            },
                            {
                                label: 'Max Marks',
                                data: maxMarks,
                                type: 'line',
                                borderColor: '#90a4ae',
                                borderWidth: 2,
                                borderDash: [6, 3],
                                pointRadius: 4,
                                pointBackgroundColor: '#90a4ae',
                                fill: false,
                                tension: 0.3,
                                order: 0
                            }
                        ]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: {
                            legend: {
                                display: true,
                                position: 'top',
                                labels: { font: { size: 11 } }
                            },
                            tooltip: {
                                callbacks: {
                                    label: function (c) {
                                        if (c.datasetIndex === 0)
                                            return ' Marks: ' + c.parsed.y + ' (' + pcts[c.dataIndex] + '%)';
                                        return ' Max: ' + c.parsed.y;
                                    }
                                }
                            }
                        },
                        scales: {
                            y: {
                                beginAtZero: true,
                                ticks: { stepSize: 1, font: { size: 11 } },
                                grid: { color: '#e3f2fd' }
                            },
                            x: {
                                ticks: { font: { size: 10 }, maxRotation: 35 },
                                grid: { display: false }
                            }
                        }
                    }
                });

                // ── Table ──
                var tbody = document.getElementById('modalAsgTableBody');
                tbody.innerHTML = '';
                data.forEach(function (d, i) {
                    var gradeColor = d.Percentage >= 80 ? '#2e7d32'
                        : d.Percentage >= 60 ? '#1565c0'
                            : d.Percentage >= 50 ? '#ef6c00'
                                : '#c62828';
                    tbody.innerHTML +=
                        '<tr>' +
                        '<td style="color:#90a4ae;">' + (i + 1) + '</td>' +
                        '<td><strong>' + d.AssignmentTitle + '</strong></td>' +
                        '<td style="color:#78909c;">' + d.SubjectName + '</td>' +
                        '<td><strong style="color:#263238;">' + d.MarksObtained + '</strong></td>' +
                        '<td style="color:#90a4ae;">' + d.MaxMarks + '</td>' +
                        '<td><strong style="color:' + gradeColor + ';">' + d.Percentage + '%</strong></td>' +
                        '<td><span style="background:' + gradeColor + '22;color:' + gradeColor + ';padding:2px 8px;border-radius:8px;font-size:11px;font-weight:700;">' + d.Grade + '</span></td>' +
                        '<td style="color:#90a4ae;">' + d.SubmittedOn + '</td>' +
                        '</tr>';
                });
                document.getElementById('modalAsgTable').style.display = '';
            })
            .catch(function () {
                document.getElementById('modalLoader').style.display = 'none';
                document.getElementById('modalEmpty').style.display = 'block';
            });
    }

    // ── Init ─────────────────────────────────────────────────────
    document.addEventListener('DOMContentLoaded', function () {
        renderDivisionChart();
        renderSubjectChart();
        renderAvgMarksChart();
    });
</script>
</asp:Content>