<%@ Page Title="My Courses"
    Language="C#"
    MasterPageFile="~/Teacher/TeacherMaster.master"
    AutoEventWireup="true"
    CodeBehind="TeacherCourses.aspx.cs"
    Inherits="LMS_Project.Teacher.TeacherCourses" %>

<asp:Content ID="cHead" ContentPlaceHolderID="head" runat="server">
<style>

/* ── Page Header Banner ── */
.page-banner {
    background: linear-gradient(135deg, #1565c0 0%, #1976d2 60%, #42a5f5 100%);
    border-radius: 16px;
    padding: 24px 32px;
    color: #fff;
    margin-bottom: 24px;
    position: relative;
    overflow: hidden;
}
.page-banner::after {
    content: "\f19d";
    font-family: "Font Awesome 6 Free";
    font-weight: 900;
    position: absolute;
    right: 32px;
    top: 50%;
    transform: translateY(-50%);
    font-size: 80px;
    opacity: .12;
    color: #fff;
}
.page-banner h4 {
    margin: 0 0 4px;
    font-weight: 800;
    font-size: 20px;
}
.page-banner p {
    margin: 0;
    opacity: .85;
    font-size: 13px;
}

/* ── Subject Card ── */
.subject-card {
    background: #fff;
    border-radius: 14px;
    box-shadow: 0 2px 10px rgba(0,0,0,.06);
    padding: 20px;
    height: 100%;
    border-left: 4px solid #1976d2;
    transition: transform .2s, box-shadow .2s;
    display: flex;
    flex-direction: column;
}
.subject-card:hover {
    transform: translateY(-4px);
    box-shadow: 0 8px 20px rgba(0,0,0,.11);
}

/* ── Card top icon row ── */
.subject-card .card-icon {
    width: 44px; height: 44px;
    border-radius: 12px;
    background: #e3f2fd;
    display: flex; align-items: center; justify-content: center;
    font-size: 18px;
    color: #1565c0;
    margin-bottom: 14px;
    flex-shrink: 0;
}

.subject-card .subject-name {
    font-size: 15px;
    font-weight: 700;
    color: #263238;
    margin-bottom: 12px;
    line-height: 1.3;
}

.subject-card .meta-row {
    display: flex;
    align-items: center;
    gap: 8px;
    font-size: 12px;
    color: #78909c;
    margin-bottom: 7px;
}
.subject-card .meta-row i {
    width: 14px;
    color: #1976d2;
    font-size: 12px;
}

/* ── Pills ── */
.pill {
    display: inline-block;
    padding: 3px 12px;
    border-radius: 20px;
    font-size: 11px;
    font-weight: 700;
}
.pill-green  { background: #e3f2fd; color: #1565c0; }
.pill-teal   { background: #e0f2f1; color: #00796b; }
.pill-lime   { background: #e8eaf6; color: #283593; }

/* ── Card footer ── */
.subject-card .card-footer-row {
    margin-top: auto;
    padding-top: 14px;
    border-top: 1px solid #e3f2fd;
    display: flex;
    align-items: center;
    justify-content: space-between;
}
.btn-manage {
    display: inline-block;
    padding: 5px 16px;
    background: #e3f2fd;
    color: #1565c0;
    border-radius: 20px;
    font-size: 12px;
    font-weight: 600;
    text-decoration: none;
    transition: background .2s, color .2s;
}
.btn-manage:hover {
    background: #1565c0;
    color: #fff;
    text-decoration: none;
}

/* ── Summary strip ── */
.summary-strip {
    background: #fff;
    border-radius: 14px;
    box-shadow: 0 2px 8px rgba(0,0,0,.06);
    padding: 16px 24px;
    display: flex;
    align-items: center;
    gap: 10px;
    margin-bottom: 20px;
    font-size: 14px;
    color: #455a64;
}
.summary-strip i { color: #1976d2; font-size: 18px; }
.summary-strip strong { color: #1565c0; }

/* ── Empty state ── */
.empty-state {
    text-align: center;
    padding: 50px 20px;
    color: #90a4ae;
    background: #fff;
    border-radius: 14px;
    box-shadow: 0 2px 8px rgba(0,0,0,.06);
}
.empty-state i { font-size: 48px; margin-bottom: 12px; display: block; color: #90caf9; }
.empty-state h6 { font-weight: 700; color: #78909c; margin-bottom: 4px; }
.empty-state p  { font-size: 13px; margin: 0; }

</style>
</asp:Content>

<asp:Content ID="cBody" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

<%-- ══ PAGE BANNER ══ --%>
<div class="page-banner">
    <h4><i class="fas fa-book-open me-2"></i>My Subjects</h4>
    <p>All subjects assigned to you for the current session.</p>
</div>

<%-- ══ SUMMARY STRIP ══ --%>
<asp:Panel ID="pnlSummary" runat="server">
    <div class="summary-strip">
        <i class="fas fa-layer-group"></i>
        You have <strong>&nbsp;<asp:Label ID="lblSubjectCount" runat="server" Text="0" />&nbsp;</strong>
        subject(s) assigned this session.
    </div>
</asp:Panel>

<%-- ══ SUBJECT CARDS ══ --%>
<asp:Panel ID="pnlCourses" runat="server">
    <div class="row g-3">
        <asp:Repeater ID="rptCourses" runat="server">
            <ItemTemplate>
                <div class="col-md-6 col-lg-4">
                    <div class="subject-card">

                        <div class="card-icon">
                            <i class="fas fa-book-open"></i>
                        </div>

                        <div class="subject-name"><%# Eval("SubjectName") %></div>

                        <div class="meta-row">
                            <i class="fas fa-users"></i>
                            <span>Section: <strong><%# Eval("SectionName") %></strong></span>
                        </div>

                        <div class="meta-row">
                            <i class="fas fa-calendar-alt"></i>
                            <span>Session: <strong><%# Eval("SessionName") %></strong></span>
                        </div>

                        <div class="meta-row" runat="server"
                             visible='<%# Eval("SubjectCode") != null && Eval("SubjectCode").ToString() != "" %>'>
                            <i class="fas fa-tag"></i>
                            <span>Code: <strong><%# Eval("SubjectCode") %></strong></span>
                        </div>

                        <div class="mt-2">
                            <span class="pill pill-green me-1">
                                <i class="fas fa-circle me-1" style="font-size:7px;"></i>Active
                            </span>
                            <span class="pill pill-teal">
                                <i class="fas fa-clock me-1"></i><%# Eval("Duration") %>
                            </span>
                        </div>

                        <div class="card-footer-row">
                            <span class="pill pill-lime">
                                <i class="fas fa-calendar me-1"></i><%# Eval("SessionName") %>
                            </span>
                            <a href='CourseVideos.aspx?SubjectId=<%# Eval("SubjectId") %>'
                               class="btn-manage">
                                <i class="fas fa-play-circle me-1"></i>Manage
                            </a>
                        </div>

                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>
</asp:Panel>

<%-- ══ EMPTY STATE ══ --%>
<asp:Panel ID="pnlEmpty" runat="server" Visible="false">
    <div class="empty-state">
        <i class="fas fa-book-open"></i>
        <h6>No Subjects Assigned Yet</h6>
        <p>You have no subjects for the current session.<br />Please contact your administrator.</p>
    </div>
</asp:Panel>

</asp:Content>