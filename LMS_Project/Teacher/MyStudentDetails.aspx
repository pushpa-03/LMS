<%@ Page Title="Student Details" Language="C#"
    MasterPageFile="~/Teacher/TeacherMaster.Master"
    AutoEventWireup="true"
    CodeBehind="MyStudentDetails.aspx.cs"
    Inherits="LMS_Project.Teacher.MyStudentDetails" %>

<asp:Content ID="cHead" ContentPlaceHolderID="head" runat="server">
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
<style>
.profile-hero {
    background: linear-gradient(135deg, #1565c0 0%, #1976d2 60%, #42a5f5 100%);
    border-radius: 16px; padding: 28px 32px;
    color: #fff; margin-bottom: 24px; position: relative; overflow: hidden;
}
.profile-hero::after {
    content: "\f007"; font-family: "Font Awesome 6 Free"; font-weight: 900;
    position: absolute; right: 32px; top: 50%; transform: translateY(-50%);
    font-size: 100px; opacity: .08;
}
.avatar-lg {
    width: 72px; height: 72px; border-radius: 50%;
    background: rgba(255,255,255,0.25); color: #fff; font-size: 28px; font-weight: 700;
    display: flex; align-items: center; justify-content: center;
    border: 3px solid rgba(255,255,255,0.4); flex-shrink: 0;
}
/* KPI cards (same as subject analytics) */
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

.mini-bar { width: 90px; height: 7px; background: #e9ecef; border-radius: 999px; overflow: hidden; display:inline-block; vertical-align:middle; }
.mini-bar-fill { height: 100%; border-radius: 999px; }

.info-card {
    background: #fff; border-radius: 14px;
    box-shadow: 0 2px 8px rgba(0,0,0,.06); margin-bottom: 20px;
}
.info-card .card-header-custom {
    padding: 14px 20px; border-bottom: 1px solid #f0f4f8;
    font-weight: 700; font-size: 14px; color: #1565c0;
    display: flex; align-items: center; gap: 8px;
}
.info-card .card-body-custom { padding: 18px 20px; }
.info-row { display: flex; flex-wrap: wrap; gap: 20px; }
.info-item { min-width: 150px; flex: 1; }
.info-item label {
    font-size: 11px; font-weight: 700; text-transform: uppercase;
    letter-spacing: .6px; color: #90a4ae; display: block; margin-bottom: 4px;
}
.info-item span { font-size: 14px; color: #263238; font-weight: 500; }

.subject-row {
    display: flex; justify-content: space-between; align-items: center;
    padding: 12px 0; border-bottom: 1px solid #f0f4f8; font-size: 13px;
}
.subject-row:last-child { border-bottom: none; }
.progress-bar-custom { height: 7px; border-radius: 4px; background: #e3f2fd; overflow: hidden; margin-top: 5px; width: 160px; }
.progress-fill { height: 100%; border-radius: 4px; background: #1976d2; }

.activity-item {
    display: flex; align-items: flex-start; gap: 10px;
    padding: 9px 0; border-bottom: 1px solid #f0f4f8; font-size: 13px;
}
.activity-item:last-child { border-bottom: none; }
.activity-dot { width: 8px; height: 8px; border-radius: 50%; flex-shrink: 0; margin-top: 4px; }
.dot-blue { background: #42a5f5; }
.dot-orange { background: #ffa726; }

.tab-btn {
    border: none; background: none; padding: 6px 14px; border-radius: 20px;
    font-size: 12px; font-weight: 600; cursor: pointer; color: #90a4ae; transition: all .2s;
}
.tab-btn.active { background: #1565c0; color: #fff; }

/* Marks table */
.marks-table { font-size: .84rem; }
.marks-table thead th { background: #f8faff; font-weight: 700; font-size: .75rem; text-transform: uppercase; letter-spacing: .04em; }
.grade-badge { display:inline-block; width:28px; height:28px; border-radius:50%; line-height:28px; text-align:center; font-weight:800; font-size:.75rem; }
.grade-aplus { background:#dcfce7; color:#16a34a; }
.grade-a     { background:#d1fae5; color:#059669; }
.grade-b     { background:#dbeafe; color:#2563eb; }
.grade-c     { background:#fef9c3; color:#ca8a04; }
.grade-d     { background:#ffedd5; color:#ea580c; }
.grade-f     { background:#fee2e2; color:#dc2626; }
</style>
</asp:Content>

<asp:Content ID="cBody" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

<%-- Hidden fields for charts --%>
<asp:HiddenField ID="hfAttPresent"      runat="server" />
<asp:HiddenField ID="hfAttAbsent"       runat="server" />
<asp:HiddenField ID="hfAttLeave"        runat="server" />
<asp:HiddenField ID="hfVideoLabels"     runat="server" />
<asp:HiddenField ID="hfVideoData"       runat="server" />
<asp:HiddenField ID="hfAsgnSubmitted"   runat="server" />
<asp:HiddenField ID="hfAsgnOverdue"     runat="server" />
<asp:HiddenField ID="hfAsgnPending"     runat="server" />
<asp:HiddenField ID="hfMarksLabels"     runat="server" />
<asp:HiddenField ID="hfMarksScores"     runat="server" />
<asp:HiddenField ID="hfMarksMax"        runat="server" />
<asp:HiddenField ID="hfAttBySubLabels"  runat="server" />
<asp:HiddenField ID="hfAttBySubPresent" runat="server" />
<asp:HiddenField ID="hfAttBySubAbsent"  runat="server" />

<asp:Label ID="lblError" runat="server" Visible="false" CssClass="alert alert-danger d-block mb-3" />

<%-- Back --%>
<div class="d-flex align-items-center mb-4">
    <a href="MyStudents.aspx" class="btn btn-outline-secondary me-3">
        <i class="fas fa-arrow-left"></i>
    </a>
    <div>
        <small class="text-muted text-uppercase fw-bold" style="letter-spacing:.06em">Student Profile</small>
        <h5 class="mb-0 fw-bold">Student Details & Analytics</h5>
    </div>
</div>

<%-- Hero Banner --%>
<div class="profile-hero">
    <div class="d-flex align-items-center gap-4 flex-wrap">
        <div class="avatar-lg">
            <asp:Label ID="lblInitialHero" runat="server" Text="S" />
        </div>
        <div>
            <h4 class="mb-1 fw-bold"><asp:Label ID="lblFullName" runat="server" /></h4>
            <div style="opacity:.85;font-size:13px;">
                <i class="fas fa-envelope me-1"></i><asp:Label ID="lblEmail" runat="server" />
            </div>
            <div style="opacity:.85;font-size:13px;margin-top:4px;">
                <i class="fas fa-id-badge me-1"></i>Roll: <asp:Label ID="lblRoll" runat="server" />
                &nbsp;|&nbsp; <asp:Label ID="lblCourse" runat="server" />
                &nbsp;|&nbsp; <asp:Label ID="lblSemester" runat="server" />
                &nbsp;|&nbsp;
                <asp:Label ID="lblAttPct" runat="server" Text="0%" />
                <span style="opacity:.7;font-size:11px;"> overall attendance</span>
            </div>
        </div>
    </div>
</div>

<%-- KPI Strip Row 1 --%>
<div class="row g-3 mb-3">
    <div class="col-6 col-md-3">
        <div class="kpi-card kpi-green">
            <div class="kpi-icon"><i class="fas fa-check-circle"></i></div>
            <div class="kpi-val"><asp:Label ID="lblPresent" runat="server" Text="0" /></div>
            <div class="kpi-lbl">Days Present</div>
        </div>
    </div>
    <div class="col-6 col-md-3">
        <div class="kpi-card kpi-red">
            <div class="kpi-icon"><i class="fas fa-times-circle"></i></div>
            <div class="kpi-val"><asp:Label ID="lblAbsent" runat="server" Text="0" /></div>
            <div class="kpi-lbl">Days Absent</div>
        </div>
    </div>
    <div class="col-6 col-md-3">
        <div class="kpi-card kpi-blue">
            <div class="kpi-icon"><i class="fas fa-video"></i></div>
            <div class="kpi-val"><asp:Label ID="lblVideos" runat="server" Text="0" /></div>
            <div class="kpi-lbl">Videos Completed</div>
        </div>
    </div>
    <div class="col-6 col-md-3">
        <div class="kpi-card kpi-orange">
            <div class="kpi-icon"><i class="fas fa-tasks"></i></div>
            <div class="kpi-val"><asp:Label ID="lblAssignments" runat="server" Text="0" /></div>
            <div class="kpi-lbl">Assignments Done</div>
        </div>
    </div>
</div>

<%-- KPI Strip Row 2 --%>
<div class="row g-3 mb-4">
    <div class="col-6 col-md-3">
        <div class="kpi-card kpi-purple">
            <div class="kpi-icon"><i class="fas fa-star"></i></div>
            <div class="kpi-val"><asp:Label ID="lblAvgScore" runat="server" Text="0%" /></div>
            <div class="kpi-lbl">Avg Assignment Score</div>
        </div>
    </div>
    <div class="col-6 col-md-3">
        <div class="kpi-card kpi-teal">
            <div class="kpi-icon"><i class="fas fa-book-open"></i></div>
            <div class="kpi-val"><asp:Label ID="lblSubjectCount" runat="server" Text="0" /></div>
            <div class="kpi-lbl">Enrolled Subjects</div>
        </div>
    </div>
    <div class="col-6 col-md-3">
        <div class="kpi-card kpi-indigo">
            <div class="kpi-icon"><i class="fas fa-graduation-cap"></i></div>
            <div class="kpi-val"><asp:Label ID="lblQuizAttempts" runat="server" Text="0" /></div>
            <div class="kpi-lbl">Quizzes Attempted</div>
        </div>
    </div>
    <div class="col-6 col-md-3">
        <div class="kpi-card kpi-pink">
            <div class="kpi-icon"><i class="fas fa-percent"></i></div>
            <div class="kpi-val"><asp:Label ID="lblSubmissionRate" runat="server" Text="0%" /></div>
            <div class="kpi-lbl">Submission Rate</div>
        </div>
    </div>
</div>

<%-- Charts Row 1 --%>
<div class="row g-4 mb-4">
    <div class="col-md-4">
        <div class="card border-0 shadow-sm h-100">
            <div class="card-header bg-white border-bottom fw-semibold py-3">
                <i class="fas fa-calendar-check me-2 text-primary"></i>Attendance Split
            </div>
            <div class="card-body d-flex flex-column align-items-center justify-content-center">
                <canvas id="chartAtt" style="max-width:200px;max-height:200px;"></canvas>
                <div id="attLegend" class="d-flex gap-3 mt-3 flex-wrap justify-content-center"></div>
            </div>
        </div>
    </div>
    <div class="col-md-4">
        <div class="card border-0 shadow-sm h-100">
            <div class="card-header bg-white border-bottom fw-semibold py-3">
                <i class="fas fa-tasks me-2 text-warning"></i>Assignment Status
            </div>
            <div class="card-body d-flex flex-column align-items-center justify-content-center">
                <canvas id="chartAsgn" style="max-width:200px;max-height:200px;"></canvas>
                <div id="asgnLegend" class="d-flex gap-3 mt-3 flex-wrap justify-content-center"></div>
            </div>
        </div>
    </div>
    <div class="col-md-4">
        <div class="card border-0 shadow-sm h-100">
            <div class="card-header bg-white border-bottom fw-semibold py-3">
                <i class="fas fa-video me-2 text-danger"></i>Videos Watched / Subject
            </div>
            <div class="card-body">
                <canvas id="chartVideos" height="200"></canvas>
            </div>
        </div>
    </div>
</div>

<%-- Charts Row 2 --%>
<div class="row g-4 mb-4">
    <div class="col-md-8">
        <div class="card border-0 shadow-sm h-100">
            <div class="card-header bg-white border-bottom fw-semibold py-3">
                <i class="fas fa-chart-line me-2 text-success"></i>Assignment Scores (Marks Obtained vs Max)
            </div>
            <div class="card-body">
                <canvas id="chartMarks" height="120"></canvas>
            </div>
        </div>
    </div>
    <div class="col-md-4">
        <div class="card border-0 shadow-sm h-100">
            <div class="card-header bg-white border-bottom fw-semibold py-3">
                <i class="fas fa-users me-2 text-info"></i>Attendance by Subject
            </div>
            <div class="card-body">
                <canvas id="chartAttSubject" height="200"></canvas>
            </div>
        </div>
    </div>
</div>

<%-- Marks Detail Table --%>
<div class="card border-0 shadow-sm mb-4">
    <div class="card-header bg-white border-bottom fw-semibold py-3 d-flex justify-content-between">
        <span><i class="fas fa-clipboard-list me-2 text-warning"></i>Assignment Marks Detail</span>
        <span class="badge bg-warning bg-opacity-10 text-warning border">Graded Submissions</span>
    </div>
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-hover mb-0 align-middle marks-table">
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Assignment</th>
                        <th>Subject</th>
                        <th>Marks</th>
                        <th>Score %</th>
                        <th>Grade</th>
                        <th>Submitted On</th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptMarks" runat="server">
                        <ItemTemplate>
                            <tr>
                                <td><span class="badge bg-secondary"><%# Container.ItemIndex+1 %></span></td>
                                <td class="fw-semibold"><%# Eval("AssignmentTitle") %></td>
                                <td><small class="text-primary"><%# Eval("SubjectName") %></small></td>
                                <td>
                                    <span class="fw-bold"><%# Eval("MarksObtained") %></span>
                                    <small class="text-muted">/ <%# Eval("MaxMarks") %></small>
                                </td>
                                <td>
                                    <div class="d-flex align-items-center gap-2">
                                        <div class="mini-bar">
                                            <div class="mini-bar-fill bg-primary" style="width:<%# Eval("Percentage") %>%"></div>
                                        </div>
                                        <small class="fw-bold"><%# Eval("Percentage") %>%</small>
                                    </div>
                                </td>
                                <td>
                                    <span class="grade-badge <%# GetGradeClass(Eval("Percentage")) %>">
                                        <%# GetGrade(Eval("Percentage")) %>
                                    </span>
                                </td>
                                <td><small class="text-muted"><%# Eval("SubmittedOn", "{0:dd MMM yyyy}") %></small></td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
        </div>
    </div>
</div>

<%-- Bottom Row: Personal Info + Subjects + Recent Activity --%>
<div class="row g-4 mb-4">

    <%-- Personal Info --%>
    <div class="col-md-5">
        <div class="info-card h-100">
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
                    <div class="info-item">
                        <label>Section</label>
                        <span><asp:Label ID="lblSection" runat="server" Text="—" /></span>
                    </div>
                    <div class="info-item">
                        <label>Session</label>
                        <span><asp:Label ID="lblSession" runat="server" Text="—" /></span>
                    </div>
                    <div class="info-item" style="flex-basis:100%">
                        <label>Address</label>
                        <span><asp:Label ID="lblAddress" runat="server" Text="—" /></span>
                    </div>
                    <div class="info-item" style="flex-basis:100%">
                        <label>Skills</label>
                        <span><asp:Label ID="lblSkills" runat="server" Text="—" /></span>
                    </div>
                    <div class="info-item" style="flex-basis:100%">
                        <label>Hobbies</label>
                        <span><asp:Label ID="lblHobbies" runat="server" Text="—" /></span>
                    </div>
                    <div class="info-item">
                        <label>Emergency Contact</label>
                        <span><asp:Label ID="lblEmergencyName" runat="server" Text="—" /></span>
                    </div>
                    <div class="info-item">
                        <label>Emergency No.</label>
                        <span><asp:Label ID="lblEmergencyNo" runat="server" Text="—" /></span>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <%-- Enrolled Subjects with progress --%>
    <div class="col-md-3">
        <div class="info-card h-100">
            <div class="card-header-custom">
                <i class="fas fa-book-open"></i> Enrolled Subjects
            </div>
            <div class="card-body-custom p-0" style="overflow-y:auto;max-height:400px;">
                <asp:Repeater ID="rptSubjects" runat="server">
                    <ItemTemplate>
                        <div class="subject-row px-3">
                            <div style="flex:1">
                                <div style="font-weight:600;font-size:13px;color:#263238;"><%# Eval("SubjectName") %></div>
                                <div style="font-size:11px;color:#90a4ae;">
                                    <i class="fas fa-chalkboard-teacher me-1"></i><%# Eval("TeacherName") %>
                                </div>
                                <div class="progress-bar-custom">
                                    <div class="progress-fill" style="width:<%# Eval("Progress") %>%"></div>
                                </div>
                            </div>
                            <span class="badge bg-primary ms-2"><%# Eval("Progress") %>%</span>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>
    </div>

    <%-- Recent Activity --%>
    <div class="col-md-4">
        <div class="info-card h-100">
            <div class="card-header-custom" style="justify-content:space-between;">
                <span><i class="fas fa-clock"></i> Recent Activity</span>
                <div>
                  <button class="tab-btn active" onclick="window.switchTab('videos',this); return false;">
    <i class="fas fa-video me-1"></i>Videos
</button>
<button class="tab-btn" onclick="window.switchTab('assignments',this); return false;">
    <i class="fas fa-tasks me-1"></i>Assignments
</button>
                </div>
            </div>
            <div class="card-body-custom" style="overflow-y:auto;max-height:380px;">
                <div id="tabVideos" style="display:block;">
                    <asp:Repeater ID="rptVideos" runat="server">
                        <ItemTemplate>
                            <div class="activity-item">
                                <div class="activity-dot dot-blue"></div>
                                <div>
                                    <div style="font-weight:600;font-size:13px;color:#263238;"><%# Eval("ActivityType") %></div>
                                    <div style="font-size:11px;color:#1976d2;font-weight:500;">
                                        <i class="fas fa-book me-1"></i><%# Eval("SubjectName") %>
                                    </div>
                                    <div style="font-size:11px;color:#90a4ae;">
                                        <%# Eval("ActionTime", "{0:dd MMM yyyy, hh:mm tt}") %>
                                    </div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                    <asp:Panel ID="pnlNoVideos" runat="server" Visible="false">
                        <div class="text-center py-4 text-muted" style="font-size:13px;">
                            <i class="fas fa-video fa-2x mb-2 d-block"></i>No videos watched yet
                        </div>
                    </asp:Panel>
                </div>
                <div id="tabAssignments" style="display:none;">
                    <asp:Repeater ID="rptAssignments" runat="server">
                        <ItemTemplate>
                            <div class="activity-item">
                                <div class="activity-dot dot-orange"></div>
                                <div>
                                    <div style="font-weight:600;font-size:13px;color:#263238;"><%# Eval("ActivityType") %></div>
                                    <div style="font-size:11px;color:#ffa726;font-weight:500;">
                                        <i class="fas fa-book me-1"></i><%# Eval("SubjectName") %>
                                    </div>
                                    <div style="font-size:11px;color:#90a4ae;">
                                        <%# Eval("ActionTime", "{0:dd MMM yyyy, hh:mm tt}") %>
                                    </div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                    <asp:Panel ID="pnlNoAssignments" runat="server" Visible="false">
                        <div class="text-center py-4 text-muted" style="font-size:13px;">
                            <i class="fas fa-tasks fa-2x mb-2 d-block"></i>No assignments submitted yet
                        </div>
                    </asp:Panel>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    // ── Tab state ──────────────────────────────────────────────────
    var _activeTab = 'videos';

    // Define switchTab as a global function
    window.switchTab = function (tab, btn) {
        _activeTab = tab;

        var videosDiv = document.getElementById('tabVideos');
        var assignmentsDiv = document.getElementById('tabAssignments');

        if (videosDiv) videosDiv.style.display = tab === 'videos' ? 'block' : 'none';
        if (assignmentsDiv) assignmentsDiv.style.display = tab === 'assignments' ? 'block' : 'none';

        // Update button active states
        document.querySelectorAll('.tab-btn').forEach(function (b) {
            b.classList.remove('active');
        });
        if (btn) btn.classList.add('active');

        // Prevent any default behavior
        return false;
    };

    function parseHF(id) {
        var el = document.getElementById(id);
        if (!el || !el.value) return [];
        try { return JSON.parse(el.value); } catch (e) { return []; }
    }

    function makeManualLegend(containerId, items) {
        var c = document.getElementById(containerId);
        if (!c) return;
        c.innerHTML = ''; // Clear existing
        items.forEach(function (d) {
            c.innerHTML += '<span style="font-size:.78rem;display:flex;align-items:center;gap:5px;">'
                + '<span style="width:10px;height:10px;border-radius:50%;background:' + d[1] + ';display:inline-block;"></span>'
                + d[0] + ' (' + d[2] + ')</span>';
        });
    }

    // Initialize charts after DOM is ready
    document.addEventListener('DOMContentLoaded', function () {
        // Set initial tab state
        var videosDiv = document.getElementById('tabVideos');
        var assignmentsDiv = document.getElementById('tabAssignments');

        if (videosDiv && assignmentsDiv) {
            videosDiv.style.display = 'block';
            assignmentsDiv.style.display = 'none';
        }

        var present = parseInt(document.getElementById('<%= hfAttPresent.ClientID %>').value) || 0;
        var absent = parseInt(document.getElementById('<%= hfAttAbsent.ClientID %>').value) || 0;
        var leave = parseInt(document.getElementById('<%= hfAttLeave.ClientID %>').value) || 0;

        var submitted = parseInt(document.getElementById('<%= hfAsgnSubmitted.ClientID %>').value) || 0;
        var overdue = parseInt(document.getElementById('<%= hfAsgnOverdue.ClientID %>').value) || 0;
        var pending = parseInt(document.getElementById('<%= hfAsgnPending.ClientID %>').value) || 0;

        var videoLabels = parseHF('<%= hfVideoLabels.ClientID %>');
        var videoData   = parseHF('<%= hfVideoData.ClientID %>');

        var marksLabels = parseHF('<%= hfMarksLabels.ClientID %>');
        var marksScores = parseHF('<%= hfMarksScores.ClientID %>');
        var marksMax    = parseHF('<%= hfMarksMax.ClientID %>');

        var attSubLabels  = parseHF('<%= hfAttBySubLabels.ClientID %>');
        var attSubPresent = parseHF('<%= hfAttBySubPresent.ClientID %>');
        var attSubAbsent  = parseHF('<%= hfAttBySubAbsent.ClientID %>');

        // 1. Attendance doughnut
        new Chart(document.getElementById('chartAtt'), {
            type: 'doughnut',
            data: {
                labels: ['Present', 'Absent', 'Leave'],
                datasets: [{
                    data: [present, absent, leave],
                    backgroundColor: ['#22c55e', '#ef4444', '#f59e0b'], borderWidth: 2
                }]
            },
            options: { cutout: '65%', plugins: { legend: { display: false } } }
        });
        makeManualLegend('attLegend', [['Present', '#22c55e', present], ['Absent', '#ef4444', absent], ['Leave', '#f59e0b', leave]]);

        // 2. Assignment pie
        new Chart(document.getElementById('chartAsgn'), {
            type: 'doughnut',
            data: {
                labels: ['Submitted', 'Overdue', 'Pending'],
                datasets: [{
                    data: [submitted, overdue, pending],
                    backgroundColor: ['#22c55e', '#ef4444', '#f97316'], borderWidth: 2
                }]
            },
            options: { cutout: '65%', plugins: { legend: { display: false } } }
        });
        makeManualLegend('asgnLegend', [['Submitted', '#22c55e', submitted], ['Overdue', '#ef4444', overdue], ['Pending', '#f97316', pending]]);

        // 3. Videos per subject bar
        new Chart(document.getElementById('chartVideos'), {
            type: 'bar',
            data: {
                labels: videoLabels,
                datasets: [{
                    label: 'Videos Watched', data: videoData,
                    backgroundColor: '#3b82f6cc', borderRadius: 4
                }]
            },
            options: { plugins: { legend: { display: false } }, scales: { y: { beginAtZero: true, ticks: { precision: 0 } } } }
        });

        // 4. Marks obtained vs max (grouped bar)
        new Chart(document.getElementById('chartMarks'), {
            type: 'bar',
            data: {
                labels: marksLabels,
                datasets: [
                    { label: 'Marks Obtained', data: marksScores, backgroundColor: '#3b82f6cc', borderRadius: 4 },
                    { label: 'Max Marks', data: marksMax, backgroundColor: '#e5e7ebcc', borderRadius: 4 }
                ]
            },
            options: {
                responsive: true,
                plugins: { legend: { position: 'top' } },
                scales: { y: { beginAtZero: true } }
            }
        });

        // 5. Attendance by subject (horizontal stacked bar)
        new Chart(document.getElementById('chartAttSubject'), {
            type: 'bar',
            data: {
                labels: attSubLabels,
                datasets: [
                    { label: 'Present', data: attSubPresent, backgroundColor: '#22c55ecc', borderRadius: 4 },
                    { label: 'Absent', data: attSubAbsent, backgroundColor: '#ef4444cc', borderRadius: 4 }
                ]
            },
            options: {
                indexAxis: 'y',
                plugins: { legend: { position: 'top' } },
                scales: { x: { stacked: true, beginAtZero: true }, y: { stacked: true } }
            }
        });
    });
</script>

</asp:Content>