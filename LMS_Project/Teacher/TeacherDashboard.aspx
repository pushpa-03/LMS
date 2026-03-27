<%@ Page Title="Dashboard" Language="C#"
    MasterPageFile="~/Teacher/TeacherMaster.Master"
    AutoEventWireup="true"
    CodeBehind="TeacherDashboard.aspx.cs"
    Inherits="LMS_Project.Teacher.TeacherDashboard" %>

<asp:Content ID="cHead" ContentPlaceHolderID="head" runat="server">
<style>

/* ── Welcome Banner ── */
.welcome-banner {
    background: linear-gradient(135deg, #2e7d32 0%, #388e3c 60%, #66bb6a 100%);
    border-radius: 16px;
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

.card-green   { background: #e8f5e9; }
.card-teal    { background: #e0f2f1; }
.card-lime    { background: #f9fbe7; }
.card-orange  { background: #fff3e0; }
.card-purple  { background: #f3e5f5; }

.icon-green   { background: #2e7d32; color: #fff; }
.icon-teal    { background: #00796b; color: #fff; }
.icon-lime    { background: #558b2f; color: #fff; }
.icon-orange  { background: #f57c00; color: #fff; }
.icon-purple  { background: #7b1fa2; color: #fff; }

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
    border-left: 4px solid #388e3c;
    background: #fff;
}
.subject-card:hover {
    transform: translateY(-3px);
    box-shadow: 0 6px 16px rgba(0,0,0,.1);
}
.subject-card .subject-code {
    font-size: 11px; font-weight: 700;
    color: #388e3c;
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
    background: #e8f5e9;
    color: #2e7d32;
    border-radius: 20px;
    font-size: 12px;
    font-weight: 600;
    text-decoration: none;
    transition: background .2s;
}
.subject-card .btn-view:hover { background: #2e7d32; color: #fff; }

/* ── Student rows ── */
.student-row {
    display: flex; align-items: center;
    padding: 12px 0;
    border-bottom: 1px solid #f0f7f2;
    gap: 12px;
}
.student-row:last-child { border-bottom: none; }
.student-row .s-avatar {
    width: 38px; height: 38px;
    border-radius: 50%;
    background: #e8f5e9;
    display: flex; align-items: center; justify-content: center;
    flex-shrink: 0;
    color: #2e7d32; font-size: 15px; font-weight: 700;
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
    border-bottom: 1px solid #f0f7f2;
    gap: 12px;
}
.assignment-row:last-child { border-bottom: none; }
.assignment-row .a-icon {
    width: 38px; height: 38px;
    border-radius: 10px;
    background: #e8f5e9;
    display: flex; align-items: center; justify-content: center;
    flex-shrink: 0;
    color: #2e7d32; font-size: 16px;
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
    background: #e8f5e9; color: #2e7d32;
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
.qa-green  { background: #e8f5e9; color: #2e7d32; }
.qa-teal   { background: #e0f2f1; color: #00796b; }
.qa-orange { background: #fff3e0; color: #e65100; }
.qa-purple { background: #f3e5f5; color: #7b1fa2; }

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
.empty-state i { font-size: 36px; margin-bottom: 8px; display: block; }
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
            <div class="row g-2">
                <div class="col-6 col-md-3">
                    <a href="TeacherAssignment.aspx" class="quick-action qa-green">
                        <i class="fas fa-upload"></i>
                        Upload Assignment
                    </a>
                </div>
                <div class="col-6 col-md-3">
                    <a href="CourseVideos.aspx" class="quick-action qa-teal">
                        <i class="fas fa-video"></i>
                        Add Course Video
                    </a>
                </div>
                <div class="col-6 col-md-3">
                    <a href="MyStudents.aspx" class="quick-action qa-purple">
                        <i class="fas fa-users"></i>
                        View My Students
                    </a>
                </div>
                <div class="col-6 col-md-3">
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

    <div class="col-md-8">
        <div class="panel-card">
            <div class="section-header">
                <h6><i class="fas fa-book-open me-2"></i>My Subjects</h6>
                <a href="TeacherCourses.aspx">View all &rarr;</a>
            </div>

            <asp:Panel ID="pnlSubjects" runat="server">
                <div class="row g-3">
                    <asp:Repeater ID="rptSubjects" runat="server">
                        <ItemTemplate>
                            <div class="col-md-6">
                                <div class="subject-card">
                                    <div class="subject-code"><%# Eval("SubjectCode") %></div>
                                    <div class="subject-name"><%# Eval("SubjectName") %></div>
                                    <div class="subject-meta">
                                        <i class="fas fa-layer-group"></i> <%# Eval("StreamName") %>
                                    </div>
                                    <div class="subject-meta">
                                        <i class="fas fa-users"></i> <%# Eval("StudentCount") %> students
                                    </div>
                                    <div class="subject-meta">
                                        <i class="fas fa-clock"></i> <%# Eval("Duration") %>
                                    </div>
                                    <a href='CourseVideos.aspx?SubjectId=<%# Eval("SubjectId") %>' class="btn-view">
                                        <i class="fas fa-play-circle me-1"></i>Manage
                                    </a>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </asp:Panel>

            <asp:Panel ID="pnlNoSubjects" runat="server" Visible="false">
                <div class="empty-state">
                    <i class="fas fa-book-open"></i>
                    <p>No subjects assigned yet.<br />Contact your admin.</p>
                </div>
            </asp:Panel>
        </div>
    </div>

    <div class="col-md-4">
        <div class="panel-card">
            <div class="section-header">
                <h6><i class="fas fa-users me-2"></i>Recent Students</h6>
                <a href="MyStudents.aspx">View all &rarr;</a>
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
                                <span class="badge-active">
                                    <i class="fas fa-circle me-1" style="font-size:7px;"></i>Active
                                </span>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </asp:Panel>

            <asp:Panel ID="pnlNoStudents" runat="server" Visible="false">
                <div class="empty-state">
                    <i class="fas fa-user-slash"></i>
                    <p>No students enrolled yet.</p>
                </div>
            </asp:Panel>
        </div>
    </div>

</div>

<%-- ══ RECENT ASSIGNMENTS ══ --%>
<div class="row g-3">
    <div class="col-12">
        <div class="panel-card">
            <div class="section-header">
                <h6><i class="fas fa-tasks me-2"></i>Recent Assignments</h6>
                <a href="TeacherAssignment.aspx">View all &rarr;</a>
            </div>

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
                                    <%# Eval("SubmissionCount") %> submitted
                                </div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </asp:Panel>

            <asp:Panel ID="pnlNoAssignments" runat="server" Visible="false">
                <div class="empty-state">
                    <i class="fas fa-clipboard-check" style="color:#2e7d32;"></i>
                    <p>No assignments created yet.<br />
                        <a href="TeacherAssignment.aspx" style="color:#2e7d32;">
                            Create your first assignment &rarr;
                        </a>
                    </p>
                </div>
            </asp:Panel>

        </div>
    </div>
</div>

</asp:Content>