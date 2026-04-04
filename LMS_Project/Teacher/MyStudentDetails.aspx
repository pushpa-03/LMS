<%@ Page Title="Student Details" Language="C#"
    MasterPageFile="~/Teacher/TeacherMaster.Master"
    AutoEventWireup="true"
    CodeBehind="MyStudentDetails.aspx.cs"
    Inherits="LMS_Project.Teacher.MyStudentDetails" %>

<asp:Content ID="cHead" ContentPlaceHolderID="head" runat="server">
<style>
.profile-hero {
    background: linear-gradient(135deg, #1565c0 0%, #1976d2 60%, #42a5f5 100%);
    border-radius: 16px;
    padding: 28px 32px;
    color: #fff;
    margin-bottom: 24px;
    position: relative;
    overflow: hidden;
}
.profile-hero::after {
    content: "\f007";
    font-family: "Font Awesome 6 Free";
    font-weight: 900;
    position: absolute;
    right: 32px; top: 50%;
    transform: translateY(-50%);
    font-size: 100px;
    opacity: .08;
}
.avatar-lg {
    width: 72px; height: 72px;
    border-radius: 50%;
    background: rgba(255,255,255,0.25);
    color: #fff;
    font-size: 28px;
    font-weight: 700;
    display: flex; align-items: center; justify-content: center;
    border: 3px solid rgba(255,255,255,0.4);
    flex-shrink: 0;
}
.info-card {
    background: #fff;
    border-radius: 14px;
    box-shadow: 0 2px 8px rgba(0,0,0,.06);
    margin-bottom: 20px;
}
.info-card .card-header-custom {
    padding: 14px 20px;
    border-bottom: 1px solid #f0f4f8;
    font-weight: 700;
    font-size: 14px;
    color: #1565c0;
    display: flex; align-items: center; gap: 8px;
}
.info-card .card-body-custom { padding: 18px 20px; }
.info-row { display: flex; flex-wrap: wrap; gap: 20px; }
.info-item { min-width: 160px; flex: 1; }
.info-item label { font-size: 11px; font-weight: 700; text-transform: uppercase;
    letter-spacing: .6px; color: #90a4ae; display: block; margin-bottom: 4px; }
.info-item span { font-size: 14px; color: #263238; font-weight: 500; }

.stat-box {
    background: #fff;
    border-radius: 14px;
    box-shadow: 0 2px 8px rgba(0,0,0,.06);
    padding: 20px;
    text-align: center;
}
.stat-box .stat-num { font-size: 32px; font-weight: 800; }
.stat-box .stat-lbl { font-size: 12px; color: #90a4ae; margin-top: 4px; }

.progress-bar-custom {
    height: 8px; border-radius: 4px;
    background: #e3f2fd;
    overflow: hidden; margin-top: 6px;
}
.progress-fill { height: 100%; border-radius: 4px; background: #1976d2; transition: width .4s; }

.subject-row {
    display: flex; justify-content: space-between; align-items: center;
    padding: 12px 0; border-bottom: 1px solid #f0f4f8;
    font-size: 13px; color: #455a64;
}
.subject-row:last-child { border-bottom: none; }
.subject-row .s-name { font-weight: 600; color: #263238; }
.subject-row .s-teacher { font-size: 11px; color: #90a4ae; }

.activity-item {
    display: flex; align-items: center; gap: 10px;
    padding: 9px 0; border-bottom: 1px solid #f0f4f8;
    font-size: 13px; color: #455a64;
}
.activity-item:last-child { border-bottom: none; }
.activity-dot { width: 8px; height: 8px; border-radius: 50%; background: #42a5f5; flex-shrink: 0; }
</style>
</asp:Content>

<asp:Content ID="cBody" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

<asp:Label ID="lblError" runat="server" Visible="false" CssClass="alert alert-danger d-block mb-3" />

<%-- Back button --%>
<div class="d-flex align-items-center mb-4">
    <a href="MyStudents.aspx" class="btn btn-outline-secondary me-3">
        <i class="fas fa-arrow-left"></i>
    </a>
    <h5 class="mb-0">Student Details</h5>
</div>

<%-- Hero --%>
<div class="profile-hero">
    <div class="d-flex align-items-center gap-4">
        <div class="avatar-lg">
            <asp:Label ID="lblInitialHero" runat="server" Text="S" />
        </div>
        <div>
            <h4 class="mb-1 fw-bold"><asp:Label ID="lblFullName" runat="server" /></h4>
            <div style="opacity:.85;font-size:13px;">
                <i class="fas fa-envelope me-1"></i>
                <asp:Label ID="lblEmail" runat="server" />
            </div>
            <div style="opacity:.85;font-size:13px;margin-top:4px;">
                <i class="fas fa-id-badge me-1"></i>Roll:
                <asp:Label ID="lblRoll" runat="server" />
                &nbsp;|&nbsp;
                <asp:Label ID="lblCourse" runat="server" />
                &nbsp;|&nbsp;
                <asp:Label ID="lblSemester" runat="server" />
            </div>
        </div>
    </div>
</div>

<%-- Stats row --%>
<div class="row g-3 mb-4">
    <div class="col-6 col-md-3">
        <div class="stat-box">
            <div class="stat-num text-success"><asp:Label ID="lblPresent" runat="server" Text="0" /></div>
            <div class="stat-lbl"><i class="fas fa-check-circle text-success me-1"></i>Present</div>
        </div>
    </div>
    <div class="col-6 col-md-3">
        <div class="stat-box">
            <div class="stat-num text-danger"><asp:Label ID="lblAbsent" runat="server" Text="0" /></div>
            <div class="stat-lbl"><i class="fas fa-times-circle text-danger me-1"></i>Absent</div>
        </div>
    </div>
    <div class="col-6 col-md-3">
        <div class="stat-box">
            <div class="stat-num text-primary"><asp:Label ID="lblVideos" runat="server" Text="0" /></div>
            <div class="stat-lbl"><i class="fas fa-video text-primary me-1"></i>Videos Done</div>
        </div>
    </div>
    <div class="col-6 col-md-3">
        <div class="stat-box">
            <div class="stat-num text-warning"><asp:Label ID="lblAssignments" runat="server" Text="0" /></div>
            <div class="stat-lbl"><i class="fas fa-tasks text-warning me-1"></i>Assignments</div>
        </div>
    </div>
</div>

<div class="row g-4">
    <%-- Left: Personal info + Subjects --%>
    <div class="col-md-7">

        <%-- Personal Info --%>
        <div class="info-card">
            <div class="card-header-custom">
                <i class="fas fa-user"></i> Personal Information
            </div>
            <div class="card-body-custom">
                <div class="info-row">
                    <div class="info-item">
                        <label>Gender</label>
                        <span><asp:Label ID="lblGender" runat="server" Text="—" /></span>
                    </div>
                    <div class="info-item">
                        <label>Date of Birth</label>
                        <span><asp:Label ID="lblDOB" runat="server" Text="—" /></span>
                    </div>
                    <div class="info-item">
                        <label>Contact</label>
                        <span><asp:Label ID="lblContact" runat="server" Text="—" /></span>
                    </div>
                    <div class="info-item">
                        <label>City</label>
                        <span><asp:Label ID="lblCity" runat="server" Text="—" /></span>
                    </div>
                    <div class="info-item">
                        <label>Stream</label>
                        <span><asp:Label ID="lblStream" runat="server" Text="—" /></span>
                    </div>
                    <div class="info-item">
                        <label>Level</label>
                        <span><asp:Label ID="lblLevel" runat="server" Text="—" /></span>
                    </div>
                </div>
            </div>
        </div>

        <%-- Subjects & Progress --%>
        <div class="info-card">
            <div class="card-header-custom">
                <i class="fas fa-book-open"></i> Enrolled Subjects
            </div>
            <div class="card-body-custom">
                <asp:Repeater ID="rptSubjects" runat="server">
                    <ItemTemplate>
                        <div class="subject-row">
                            <div>
                                <div class="s-name"><%# Eval("SubjectName") %></div>
                                <div class="s-teacher">
                                    <i class="fas fa-chalkboard-teacher me-1"></i><%# Eval("TeacherName") %>
                                </div>
                                <div class="progress-bar-custom" style="width:200px;">
                                    <div class="progress-fill" style="width:<%# Eval("Progress") %>%;"></div>
                                </div>
                            </div>
                            <span class="badge bg-primary" style="font-size:12px;">
                                <%# Eval("Progress") %>%
                            </span>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>

    </div>

    <%-- Right: Recent Activity --%>
    <div class="col-md-5">
        <div class="info-card">
            <div class="card-header-custom">
                <i class="fas fa-clock"></i> Recent Activity
            </div>
            <div class="card-body-custom">
                <asp:Repeater ID="rptActivity" runat="server">
                    <ItemTemplate>
                        <div class="activity-item">
                            <div class="activity-dot"></div>
                            <div>
                                <div style="font-weight:600;font-size:13px;color:#263238;">
                                    <%# Eval("ActivityType") %>
                                </div>
                                <div style="font-size:11px;color:#90a4ae;">
                                    <%# Eval("ActionTime", "{0:dd MMM yyyy, hh:mm tt}") %>
                                </div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
                <asp:Panel ID="pnlNoActivity" runat="server" Visible="false">
                    <div style="text-align:center;padding:30px;color:#90a4ae;font-size:13px;">
                        <i class="fas fa-history" style="font-size:32px;margin-bottom:8px;display:block;"></i>
                        No recent activity
                    </div>
                </asp:Panel>
            </div>
        </div>
    </div>
</div>

</asp:Content>