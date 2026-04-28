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
    <a href="Subjects_T_Side.aspx" class="quick-action qa-lime">
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

            <%-- Toolbar --%>
            <div class="d-flex flex-wrap align-items-center gap-2 mb-3">

                <div class="btn-group btn-group-sm" role="group">
                    <button type="button" id="btnList" onclick="setView('list')"
                            class="btn btn-primary" title="List View">
                        <i class="fas fa-list"></i>
                    </button>
                    <button type="button" id="btnChart" onclick="setView('chart')"
                            class="btn btn-outline-primary" title="Chart View">
                        <i class="fas fa-chart-bar"></i>
                    </button>
                </div>

                <asp:DropDownList ID="ddlFilterSession" runat="server"
                    CssClass="form-select form-select-sm"
                    Style="width:auto; min-width:130px;"
                    AutoPostBack="true"
                    OnSelectedIndexChanged="ddlFilterSession_SelectedIndexChanged">
                </asp:DropDownList>

                <asp:DropDownList ID="ddlFilterSection" runat="server"
                    CssClass="form-select form-select-sm"
                    Style="width:auto; min-width:120px;"
                    AutoPostBack="true"
                    OnSelectedIndexChanged="ddlFilterSection_SelectedIndexChanged">
                </asp:DropDownList>

                <asp:DropDownList ID="ddlFilterStream" runat="server"
                    CssClass="form-select form-select-sm"
                    Style="width:auto; min-width:130px;"
                    AutoPostBack="true"
                    OnSelectedIndexChanged="ddlFilterStream_SelectedIndexChanged">
                </asp:DropDownList>

            </div>

            <%-- LIST VIEW (default) --%>
            <asp:Panel ID="pnlSubjectsList" runat="server">
                <div class="table-responsive">
                    <table class="table table-hover table-sm align-middle" style="font-size:13px;">
                        <thead style="background:#e3f2fd; color:#1565c0;">
                            <tr>
                                <th>#</th>
                                <th>Code</th>
                                <th>Subject</th>
                                <th>Stream</th>
                                <th>Course</th>
                                <th>Section</th>
                                <th>Students</th>
                                <th>Duration</th>
                                <th></th>
                            </tr>
                        </thead>
                        <tbody>
                            <asp:Repeater ID="rptSubjectsList" runat="server">
                                <ItemTemplate>
                                    <tr>
                                        <td><%# Container.ItemIndex + 1 %></td>
                                        <td><span class="badge" style="background:#1976d2;font-size:11px;">
                                            <%# Eval("SubjectCode") %></span></td>
                                        <td><strong><%# Eval("SubjectName") %></strong></td>
                                        <td><%# Eval("StreamName") %></td>
                                        <td><%# Eval("CourseName") %></td>
                                        <td><%# Eval("SectionName") %></td>
                                        <td>
                                            <span class="badge-active">
                                                <i class="fas fa-users me-1" style="font-size:9px;"></i>
                                                <%# Eval("StudentCount") %>
                                            </span>
                                        </td>
                                        <td><%# Eval("Duration") %></td>
                                        <td>
                                            <a href='CourseVideos.aspx?SubjectId=<%# Eval("SubjectId") %>'
                                               class="btn-view" style="padding:3px 10px;">
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

            <%-- CHART VIEW --%>
            <asp:Panel ID="pnlSubjectsChart" runat="server" Visible="false">
                <div style="position:relative; height:280px;">
                    <canvas id="subjectChart"></canvas>
                </div>
                <asp:HiddenField ID="hfChartData" runat="server" />
            </asp:Panel>

            <%-- EMPTY STATE --%>
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
            <h6><i class="fas fa-users me-2"></i>Recent Students</h6>
            <a href="MyStudents.aspx">View all &rarr;</a>
        </div>

        <%-- Student Filters --%>
        <div class="d-flex flex-column gap-2 mb-3">
            <asp:DropDownList ID="ddlStudentSession" runat="server"
                CssClass="form-select form-select-sm"
                AutoPostBack="true"
                OnSelectedIndexChanged="ddlStudentSession_SelectedIndexChanged">
            </asp:DropDownList>

            <div class="d-flex gap-2">
                <asp:DropDownList ID="ddlStudentSection" runat="server"
                    CssClass="form-select form-select-sm"
                    AutoPostBack="true"
                    OnSelectedIndexChanged="ddlStudentSection_SelectedIndexChanged">
                </asp:DropDownList>

                <asp:DropDownList ID="ddlStudentStream" runat="server"
                    CssClass="form-select form-select-sm"
                    AutoPostBack="true"
                    OnSelectedIndexChanged="ddlStudentStream_SelectedIndexChanged">
                </asp:DropDownList>
            </div>
        </div>

        <asp:Panel ID="pnlStudents" runat="server">
            <asp:Repeater ID="rptStudents" runat="server">
                <ItemTemplate>
                    <div class="student-row">
                        <div class="s-avatar">
                            <%# Eval("StudentName").ToString().Length > 0
                                ? Eval("StudentName").ToString().Substring(0,1).ToUpper()
                                : "S" %>
                        </div>
                        <div>
                            <div class="s-name"><%# Eval("StudentName") %></div>
                            <div class="s-sub"><%# Eval("CourseName") %></div>
                        </div>
                        <div class="s-right">
                            <div class="mb-1">
                                <span class="badge-active">
                                    <i class="fas fa-circle me-1" style="font-size:7px;"></i>Active
                                </span>
                            </div>
                            <div style="font-size:10px; color:#90a4ae;">
                                <%# Eval("SectionName") %>
                            </div>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
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


<%-- Chart.js (only loaded once, safe to add here) --%>
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
<script>
    var currentView = 'list';

    function setView(v) {
        currentView = v;

        // Toggle button styles
        ['btnList', 'btnChart'].forEach(function (id) {
            var el = document.getElementById(id);
            if (!el) return;
            el.className = el.className.replace('btn-primary', 'btn-outline-primary');
        });
        var activeEl = document.getElementById(v === 'list' ? 'btnList' : 'btnChart');
        if (activeEl)
            activeEl.className = activeEl.className.replace('btn-outline-primary', 'btn-primary');

        var list = document.getElementById('<%= pnlSubjectsList.ClientID %>');
        var chart = document.getElementById('<%= pnlSubjectsChart.ClientID %>');

        if (list)  list.style.display  = (v === 'list')  ? '' : 'none';
        if (chart) chart.style.display = (v === 'chart') ? '' : 'none';

        if (v === 'chart') renderChart();
    }

    var chartInstance = null;

    function renderChart() {
        var hf = document.getElementById('<%= hfChartData.ClientID %>');
        if (!hf || !hf.value) return;

        var data;
        try { data = JSON.parse(hf.value); } catch (e) { return; }

        var ctx = document.getElementById('subjectChart');
        if (!ctx) return;

        if (chartInstance) { chartInstance.destroy(); chartInstance = null; }

        var labels = data.map(function (d) { return d.SubjectName; });
        var counts = data.map(function (d) { return d.StudentCount; });
        var colors = [
            '#1565c0', '#0288d1', '#1976d2', '#ef6c00', '#5e35b1',
            '#388e3c', '#c62828', '#00838f', '#4527a0', '#2e7d32'
        ];

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
                    tooltip: {
                        callbacks: {
                            label: function (ctx) { return ' ' + ctx.parsed.y + ' students'; }
                        }
                    }
                },
                scales: {
                    y: { beginAtZero: true, ticks: { stepSize: 1, font: { size: 11 } }, grid: { color: '#e3f2fd' } },
                    x: { ticks: { font: { size: 11 }, maxRotation: 30 }, grid: { display: false } }
                }
            }
        });
    }
    /* ── Assignment view switcher ── */
    function setAsgView(v) {
        ['btnAsgList', 'btnAsgChart'].forEach(function (id) {
            var el = document.getElementById(id);
            if (!el) return;
            el.className = el.className.replace('btn-primary', 'btn-outline-primary');
        });
        var activeEl = document.getElementById(v === 'list' ? 'btnAsgList' : 'btnAsgChart');
        if (activeEl)
            activeEl.className = activeEl.className.replace('btn-outline-primary', 'btn-primary');

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

        var labels = data.map(function (d) { return d.Title; });
        var submitted = data.map(function (d) { return d.SubmissionCount; });
        var pending = data.map(function (d) { return d.Pending; });

        asgChartInstance = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: labels,
                datasets: [
                    {
                        label: 'Submitted',
                        data: submitted,
                        backgroundColor: '#1565c0cc',
                        borderColor: '#1565c0',
                        borderWidth: 2,
                        borderRadius: 6
                    },
                    {
                        label: 'Pending',
                        data: pending,
                        backgroundColor: '#ef6c00cc',
                        borderColor: '#ef6c00',
                        borderWidth: 2,
                        borderRadius: 6
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
                            label: function (ctx) {
                                return ' ' + ctx.dataset.label + ': ' + ctx.parsed.y + ' students';
                            }
                        }
                    }
                },
                scales: {
                    x: {
                        stacked: false,
                        ticks: { font: { size: 10 }, maxRotation: 30 },
                        grid: { display: false }
                    },
                    y: {
                        beginAtZero: true,
                        ticks: { stepSize: 1, font: { size: 11 } },
                        grid: { color: '#e3f2fd' }
                    }
                }
            }
        });
    }
</script>
</asp:Content>