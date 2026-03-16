<%@ Page Title="Dashboard" Language="C#"
    MasterPageFile="~/Student/StudentMaster.Master"
    AutoEventWireup="true"
    CodeBehind="Dashboard.aspx.cs"
    Inherits="LMS_Project.Student.Dashboard" %>

<%-- ── HEAD (extra styles for this page) ── --%>
<asp:Content ID="cHead" ContentPlaceHolderID="head" runat="server">
<style>

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
    content: "\f19d";            /* fa-graduation-cap */
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

/* Card color themes */
.card-blue   { background: #e3f2fd; }
.card-orange { background: #fff3e0; }
.card-purple { background: #f3e5f5; }
.card-green  { background: #e8f5e9; }
.icon-blue   { background: #1976d2; color: #fff; }
.icon-orange { background: #f57c00; color: #fff; }
.icon-purple { background: #7b1fa2; color: #fff; }
.icon-green  { background: #2e7d32; color: #fff; }

/* ── Section headers ── */
.section-header {
    display: flex; align-items: center;
    justify-content: space-between;
    margin-bottom: 14px;
}
.section-header h6 {
    font-weight: 700; font-size: 15px;
    color: #1565c0; margin: 0;
}
.section-header a {
    font-size: 12px; color: #1976d2;
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
.subject-card .subject-meta i {
    width: 14px; color: #1976d2;
}
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
.subject-card .btn-view:hover {
    background: #1565c0; color: #fff;
}

/* ── Assignment rows ── */
.assignment-row {
    display: flex; align-items: center;
    padding: 12px 0;
    border-bottom: 1px solid #f0f4f8;
    gap: 12px;
}
.assignment-row:last-child { border-bottom: none; }
.assignment-row .a-icon {
    width: 38px; height: 38px;
    border-radius: 10px;
    background: #e3f2fd;
    display: flex; align-items: center; justify-content: center;
    flex-shrink: 0;
    color: #1976d2; font-size: 16px;
}
.assignment-row .a-title {
    font-size: 13px; font-weight: 600;
    color: #263238;
}
.assignment-row .a-sub {
    font-size: 11px; color: #90a4ae;
}
.assignment-row .a-due {
    font-size: 11px;
    margin-left: auto;
    flex-shrink: 0;
    text-align: right;
}

/* ── Status badges ── */
.badge-pending  { background: #fff3e0; color: #e65100;
                  padding: 3px 10px; border-radius: 10px;
                  font-size: 11px; font-weight: 700; }
.badge-submitted{ background: #e8f5e9; color: #2e7d32;
                  padding: 3px 10px; border-radius: 10px;
                  font-size: 11px; font-weight: 700; }
.badge-overdue  { background: #ffebee; color: #c62828;
                  padding: 3px 10px; border-radius: 10px;
                  font-size: 11px; font-weight: 700; }

/* ── Notification feed ── */
.notif-item {
    display: flex; gap: 10px;
    padding: 10px 0;
    border-bottom: 1px solid #f0f4f8;
    align-items: flex-start;
}
.notif-item:last-child { border-bottom: none; }
.notif-dot {
    width: 8px; height: 8px;
    border-radius: 50%;
    background: #1976d2;
    flex-shrink: 0;
    margin-top: 6px;
}
.notif-dot.read { background: #cfd8dc; }
.notif-msg  { font-size: 13px; color: #455a64; line-height: 1.4; }
.notif-time { font-size: 11px; color: #90a4ae; margin-top: 2px; }

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

<%-- ── MAIN CONTENT ── --%>
<asp:Content ID="cBody" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<%-- ══════════════════════════════════════════
     WELCOME BANNER
══════════════════════════════════════════ --%>
<div class="welcome-banner">
    <h4>Welcome back, <asp:Label ID="lblWelcomeName" runat="server" />! 👋</h4>
    <p>Here's what's happening in your academic journey today.</p>

    <asp:Label ID="lblRollPill"    runat="server" CssClass="meta-pill" />
    <asp:Label ID="lblCoursePill"  runat="server" CssClass="meta-pill" />
    <asp:Label ID="lblSemPill"     runat="server" CssClass="meta-pill" />
    <asp:Label ID="lblSessionPill" runat="server" CssClass="meta-pill" />
</div>

<%-- ══════════════════════════════════════════
     STAT CARDS ROW
══════════════════════════════════════════ --%>
<div class="row g-3 mb-4">

    <div class="col-6 col-md-3">
        <div class="stat-card card-blue">
            <div class="icon-box icon-blue">
                <i class="fas fa-book-open"></i>
            </div>
            <div>
                <div class="stat-label">Subjects</div>
                <div class="stat-value">
                    <asp:Label ID="lblTotalSubjects" runat="server" Text="0" />
                </div>
                <div class="stat-sub">Enrolled this session</div>
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
                <div class="stat-value">
                    <asp:Label ID="lblPendingAssignments" runat="server" Text="0" />
                </div>
                <div class="stat-sub">Pending submission</div>
            </div>
        </div>
    </div>

    <div class="col-6 col-md-3">
        <div class="stat-card card-purple">
            <div class="icon-box icon-purple">
                <i class="fas fa-clipboard-list"></i>
            </div>
            <div>
                <div class="stat-label">Quizzes</div>
                <div class="stat-value">
                    <asp:Label ID="lblUpcomingQuizzes" runat="server" Text="0" />
                </div>
                <div class="stat-sub">Available to attempt</div>
            </div>
        </div>
    </div>

    <div class="col-6 col-md-3">
        <div class="stat-card card-green">
            <div class="icon-box icon-green">
                <i class="fas fa-bell"></i>
            </div>
            <div>
                <div class="stat-label">Notifications</div>
                <div class="stat-value">
                    <asp:Label ID="lblUnreadNotifications" runat="server" Text="0" />
                </div>
                <div class="stat-sub">Unread messages</div>
            </div>
        </div>
    </div>

</div>

<%-- ══════════════════════════════════════════
     SUBJECTS + NOTIFICATIONS ROW
══════════════════════════════════════════ --%>
<div class="row g-3 mb-4">

    <%-- Enrolled Subjects (left, 8 cols) --%>
    <div class="col-md-8">
        <div class="panel-card">
            <div class="section-header">
                <h6><i class="fas fa-book-open me-2"></i>My Subjects</h6>
                <a href="MySubjects.aspx">View all &rarr;</a>
            </div>

            <asp:Panel ID="pnlSubjects" runat="server">
                <div class="row g-3" id="subjectsGrid">
                    <asp:Repeater ID="rptSubjects" runat="server">
                        <ItemTemplate>
                            <div class="col-md-6">
                                <div class="subject-card">
                                    <div class="subject-code"><%# Eval("SubjectCode") %></div>
                                    <div class="subject-name"><%# Eval("SubjectName") %></div>
                                    <div class="subject-meta">
                                        <i class="fas fa-layer-group"></i>
                                        <%# Eval("StreamName") %>
                                    </div>
                                    <div class="subject-meta">
                                        <i class="fas fa-user-tie"></i>
                                        <%# Eval("TeacherName") %>
                                    </div>
                                    <div class="subject-meta">
                                        <i class="fas fa-clock"></i>
                                        <%# Eval("Duration") %>
                                    </div>
                                    <a href='StudyMaterial.aspx?SubjectId=<%# Eval("SubjectId") %>'
                                       class="btn-view">
                                        <i class="fas fa-play-circle me-1"></i>View Material
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
                    <p>No subjects enrolled yet.<br/>Contact your admin.</p>
                </div>
            </asp:Panel>

        </div>
    </div>

    <%-- Notifications (right, 4 cols) --%>
    <div class="col-md-4">
        <div class="panel-card">
            <div class="section-header">
                <h6><i class="fas fa-bell me-2"></i>Notifications</h6>
                <a href="Notifications.aspx">View all &rarr;</a>
            </div>

            <asp:Panel ID="pnlNotifications" runat="server">
                <asp:Repeater ID="rptNotifications" runat="server">
                    <ItemTemplate>
                        <div class="notif-item">
                            <div class='notif-dot <%# Convert.ToBoolean(Eval("IsRead")) ? "read" : "" %>'></div>
                            <div>
                                <div class="notif-msg"><%# Eval("Message") %></div>
                                <div class="notif-time">
                                    <i class="far fa-clock me-1"></i>
                                    <%# Eval("CreatedOn", "{0:dd MMM, hh:mm tt}") %>
                                </div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </asp:Panel>

            <asp:Panel ID="pnlNoNotifications" runat="server" Visible="false">
                <div class="empty-state">
                    <i class="fas fa-bell-slash"></i>
                    <p>No notifications yet.</p>
                </div>
            </asp:Panel>

        </div>
    </div>

</div>

<%-- ══════════════════════════════════════════
     UPCOMING ASSIGNMENTS
══════════════════════════════════════════ --%>
<div class="row g-3">
    <div class="col-12">
        <div class="panel-card">
            <div class="section-header">
                <h6><i class="fas fa-tasks me-2"></i>Upcoming Assignments</h6>
                <a href="Assignments.aspx">View all &rarr;</a>
            </div>

            <asp:Panel ID="pnlAssignments" runat="server">
                <asp:Repeater ID="rptAssignments" runat="server">
                    <ItemTemplate>
                        <div class="assignment-row">
                            <div class="a-icon">
                                <i class="fas fa-file-alt"></i>
                            </div>
                            <div>
                                <div class="a-title"><%# Eval("Title") %></div>
                                <div class="a-sub">
                                    <i class="fas fa-book me-1"></i><%# Eval("SubjectName") %>
                                    &nbsp;|&nbsp;
                                    <i class="fas fa-star me-1"></i><%# Eval("MaxMarks") %> marks
                                </div>
                            </div>
                            <div class="a-due">
                                <div class="mb-1">
                                    <i class="far fa-calendar-alt me-1"></i>
                                    <%# Eval("DueDate", "{0:dd MMM yyyy}") %>
                                </div>
                                <%# Eval("Status").ToString() == "Submitted" ? "<span class='badge-submitted'><i class='fas fa-check me-1'></i>Submitted</span>" : Eval("Status").ToString() == "Overdue" ? "<span class='badge-overdue'><i class='fas fa-exclamation-triangle me-1'></i>Overdue</span>" : "<span class='badge-pending'><i class='fas fa-clock me-1'></i>Pending</span>" %>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </asp:Panel>

            <asp:Panel ID="pnlNoAssignments" runat="server" Visible="false">
                <div class="empty-state">
                    <i class="fas fa-check-circle" style="color:#2e7d32;"></i>
                    <p>All caught up! No pending assignments.</p>
                </div>
            </asp:Panel>

        </div>
    </div>
</div>

</asp:Content>
