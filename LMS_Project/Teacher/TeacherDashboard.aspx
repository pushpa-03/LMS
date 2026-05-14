<%@ Page Title="Dashboard" Language="C#"
    MasterPageFile="~/Teacher/TeacherMaster.Master"
    AutoEventWireup="true"
    CodeBehind="TeacherDashboard.aspx.cs"
    Inherits="LMS_Project.Teacher.TeacherDashboard" %>

<asp:Content ID="cHead" ContentPlaceHolderID="head" runat="server">
    <!-- CSS Stylesheet -->
    <link rel="stylesheet" href="TeacherDashboard.css" />
    
    <!-- Font Awesome (if not already in master) -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css" />
    
    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
    <script src="TeacherDashboardScripts.js"></script>
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

<%-- ══ STAT CARDS + QUICK ACTIONS (side by side) ══ --%>

    <%-- LEFT: Stat Cards (col-md-5) --%>
    <div class="row g-3 mb-4">
        <div class="panel-card h-100">
            <div class="row g-2">

               <div class="col-md-3 col-6">
                    <div class="stat-card-sm card-green">
                        <div class="icon-box-sm icon-green">
                            <i class="fas fa-book-open"></i>
                        </div>
                        <div>
                            <div class="stat-label-sm">Subjects</div>
                            <div class="stat-value-sm"><asp:Label ID="lblTotalSubjects" runat="server" Text="0" /></div>
                            <div class="stat-sub-sm">This session</div>
                        </div>
                    </div>
                </div>

               <div class="col-md-3 col-6">
                    <div class="stat-card-sm card-teal">
                        <div class="icon-box-sm icon-teal">
                            <i class="fas fa-users"></i>
                        </div>
                        <div>
                            <div class="stat-label-sm">Students</div>
                            <div class="stat-value-sm"><asp:Label ID="lblTotalStudents" runat="server" Text="0" /></div>
                            <div class="stat-sub-sm">Your courses</div>
                        </div>
                    </div>
                </div>

                <div class="col-md-3 col-6">
                    <div class="stat-card-sm card-orange">
                        <div class="icon-box-sm icon-orange">
                            <i class="fas fa-tasks"></i>
                        </div>
                        <div>
                            <div class="stat-label-sm">Assignments</div>
                            <div class="stat-value-sm"><asp:Label ID="lblTotalAssignments" runat="server" Text="0" /></div>
                            <div class="stat-sub-sm">Active</div>
                        </div>
                    </div>
                </div>

               <div class="col-md-3 col-6">
                    <div class="stat-card-sm card-lime">
                        <div class="icon-box-sm icon-lime">
                            <i class="fas fa-video"></i>
                        </div>
                        <div>
                            <div class="stat-label-sm">Videos</div>
                            <div class="stat-value-sm"><asp:Label ID="lblTotalVideos" runat="server" Text="0" /></div>
                            <div class="stat-sub-sm">Uploaded</div>
                        </div>
                    </div>
                </div>

            </div>
        </div>
    </div>

    <%-- RIGHT: Quick Actions (col-md-7) --%>
    <%-- <div class="col-md-7">
        <div class="panel-card h-100">
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
--%>


<%-- ══ SUBJECTS + RECENT STUDENTS ══ --%>
<div class="row g-3 mb-4">

<%-- LEFT: My Subjects --%>
    <div class="col-md-6">
        <div class="panel-card h-100">
            <div class="section-header">
                <h6><i class="fas fa-book-open me-2"></i>My Subjects</h6>
                <a href="TeacherCourses.aspx">View all &rarr;</a>
            </div>


        <%-- KPI Mini Cards --%>
        <asp:Panel ID="pnlSubjectKPIs" runat="server">
            <div class="row g-2 mb-3">
              <%--   <div class="col-6 col-md-3">
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
                </div> --%>
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
                                  <%--   <td>
                                        <a href='SubjectAnalytics.aspx?SubjectId=<%# Eval("SubjectId") %>'
                                           class="btn-view" style="padding:3px 10px;font-size:11px;">
                                            <i class="fas fa-play-circle me-1"></i>Manage
                                        </a>
                                    </td>--%>
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

  <%-- RIGHT: Student Analytics --%>
    <div class="col-md-6">
        <div class="panel-card h-100">
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

<%-- ══ COMPARISON ANALYTICS SECTION ══ --%>
<div class="row g-3 mt-2">
    <div class="col-12">
        <div class="panel-card">
 
            <%-- Header --%>
            <div class="section-header mb-2">
                <h6><i class="fas fa-chart-bar me-2"></i>Comparison Analytics</h6>
            </div>
            <p style="font-size:12px;color:#90a4ae;margin:-6px 0 16px;">
                Compare sections or subjects across attendance, marks, and engagement.
            </p>
 
            <%-- Tab switcher --%>
            <div class="compare-tabs">
                <button type="button" class="compare-tab active" id="tabSec" onclick="switchCompareTab('section'); return false;">
                    <i class="fas fa-layer-group"></i>Section vs Section
                </button>
                <button type="button" class="compare-tab" id="tabSub" onclick="switchCompareTab('subject'); return false;">
                    <i class="fas fa-book-open"></i>Subject vs Subject
                </button>
            </div>
 
            <%-- Metric toggles --%>
            <div class="metric-toggle">
                <button type="button" class="metric-btn active marks" id="btnMarks" onclick="switchMetric('marks'); return false;">
                    <i class="fas fa-star me-1"></i>Marks
                </button>
                <button type="button" class="metric-btn attend" id="btnAttend" onclick="switchMetric('attendance'); return false;">
                    <i class="fas fa-clipboard-check me-1"></i>Attendance
                </button>
                <button type="button" class="metric-btn engage" id="btnEngage" onclick="switchMetric('engagement'); return false;">
                    <i class="fas fa-play-circle me-1"></i>Engagement
                </button>
            </div>
 
            <%-- ── SECTION vs SECTION panel ── --%>
            <div id="pnlCompareSections">
 
                <%-- KPI row --%>
                <asp:HiddenField ID="hfSecCompareData" runat="server" ClientIDMode="Static" />
 
                <div class="compare-kpi-grid" id="secKpiRow">
                    <div class="compare-kpi ck-blue">
                        <div class="ck-label">Sections</div>
                        <div class="ck-val"><asp:Label ID="lblCmpSecCount" runat="server" Text="0" /></div>
                        <div class="ck-sub">being compared</div>
                    </div>
                    <div class="compare-kpi ck-green">
                        <div class="ck-label">Best Section</div>
                        <div class="ck-val" style="font-size:16px;"><asp:Label ID="lblCmpSecBest" runat="server" Text="-" /></div>
                        <div class="ck-sub">highest avg marks</div>
                    </div>
                    <div class="compare-kpi ck-orange">
                        <div class="ck-label">Best Attendance</div>
                        <div class="ck-val" style="font-size:16px;"><asp:Label ID="lblCmpSecAttend" runat="server" Text="-" /></div>
                        <div class="ck-sub">% avg attendance</div>
                    </div>
                    <div class="compare-kpi ck-purple">
                        <div class="ck-label">Most Engaged</div>
                        <div class="ck-val" style="font-size:16px;"><asp:Label ID="lblCmpSecEngage" runat="server" Text="-" /></div>
                        <div class="ck-sub">by video views</div>
                    </div>
                </div>
 
                <%-- Auto-insights --%>
                <asp:Panel ID="pnlSecInsights" runat="server">
                    <div style="margin-bottom:14px;">
                        <asp:Repeater ID="rptSecInsights" runat="server">
                            <ItemTemplate>
                                <span class="insight-chip <%# Eval("CssClass") %>">
                                    <i class="fas <%# Eval("Icon") %>"></i>
                                    <%# Eval("Message") %>
                                </span>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </asp:Panel>
 
                <%-- Chart --%>
                <div style="position:relative;height:300px;">
                    <canvas id="secCompareChart"
                            role="img"
                            aria-label="Bar chart comparing sections across selected metric"></canvas>
                </div>
 
                <asp:Panel ID="pnlNoSecCompare" runat="server" Visible="false">
                    <div class="empty-state">
                        <i class="fas fa-layer-group"></i>
                        <p>No section comparison data available yet.</p>
                    </div>
                </asp:Panel>
 
            </div>
 
            <%-- ── SUBJECT vs SUBJECT panel ── --%>
            <div id="pnlCompareSubjects" style="display:none;"> 
                <asp:HiddenField ID="hfSubCompareData" runat="server" ClientIDMode="Static" />
 
                <div class="compare-kpi-grid" id="subKpiRow">
                    <div class="compare-kpi ck-blue">
                        <div class="ck-label">Subjects</div>
                        <div class="ck-val"><asp:Label ID="lblCmpSubCount" runat="server" Text="0" /></div>
                        <div class="ck-sub">being compared</div>
                    </div>
                    <div class="compare-kpi ck-green">
                        <div class="ck-label">Best Subject</div>
                        <div class="ck-val" style="font-size:14px;"><asp:Label ID="lblCmpSubBest" runat="server" Text="-" /></div>
                        <div class="ck-sub">highest avg marks</div>
                    </div>
                    <div class="compare-kpi ck-orange">
                        <div class="ck-label">Best Attendance</div>
                        <div class="ck-val" style="font-size:14px;"><asp:Label ID="lblCmpSubAttend" runat="server" Text="-" /></div>
                        <div class="ck-sub">% avg rate</div>
                    </div>
                    <div class="compare-kpi ck-purple">
                        <div class="ck-label">Most Watched</div>
                        <div class="ck-val" style="font-size:14px;"><asp:Label ID="lblCmpSubEngage" runat="server" Text="-" /></div>
                        <div class="ck-sub">by video views</div>
                    </div>
                </div>
 
                <asp:Panel ID="pnlSubInsights" runat="server">
                    <div style="margin-bottom:14px;">
                        <asp:Repeater ID="rptSubInsights" runat="server">
                            <ItemTemplate>
                                <span class="insight-chip <%# Eval("CssClass") %>">
                                    <i class="fas <%# Eval("Icon") %>"></i>
                                    <%# Eval("Message") %>
                                </span>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </asp:Panel>
 
                <div style="position:relative;height:300px;">
                    <canvas id="subCompareChart"
                            role="img"
                            aria-label="Bar chart comparing subjects across selected metric"></canvas>
                </div>
 
                <asp:Panel ID="pnlNoSubCompare" runat="server" Visible="false">
                    <div class="empty-state">
                        <i class="fas fa-book-open"></i>
                        <p>No subject comparison data available yet.</p>
                    </div>
                </asp:Panel>
 
            </div>
 
        </div>
    </div>
</div>

<%-- ══ RECENT ASSIGNMENTS ══ --%>
<div class="row g-3 mt-2">
    <div class="col-md-8">
        <div class="panel-card">
            <div class="section-header">
                <h6><i class="fas fa-tasks me-2"></i>Recent Assignments</h6>
                <a href="TeacherAssignment.aspx">View all &rarr;</a>
            </div>

            <%-- Filter + View Toggle --%>
            <div class="d-flex flex-wrap align-items-center gap-2 mb-3">

               <%--  <div class="btn-group btn-group-sm" role="group">
                    <button type="button" id="btnAsgList" onclick="setAsgView('list')"
                            class="btn btn-primary" title="List View">
                        <i class="fas fa-list"></i>
                    </button>
                    <button type="button" id="btnAsgChart" onclick="setAsgView('chart')"
                            class="btn btn-outline-primary" title="Chart View">
                        <i class="fas fa-chart-bar"></i>
                    </button>
                </div> --%>

              <%--   <asp:DropDownList ID="ddlAsgSubject" runat="server"
                    CssClass="form-select form-select-sm"
                    Style="width:auto; min-width:160px;"
                    AutoPostBack="true"
                    OnSelectedIndexChanged="ddlAsgSubject_SelectedIndexChanged">
                </asp:DropDownList>
              --%>
            </div>

            <%-- LIST VIEW --%>
            <asp:Panel ID="pnlAssignments" runat="server" Visible="false">
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
            <asp:Panel ID="pnlAsgChart" runat="server">
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


<%-- ══ CONTENT ENGAGEMENT SECTION ══ --%>
<div class="row g-3 mt-2">
    <div class="col-12">
        <div class="panel-card">
            <div class="section-header mb-2">
                <h6><i class="fas fa-play-circle me-2"></i>Content Engagement Analytics</h6>
                <a href="Subjects_T_Side.aspx" style="color:#1976d2;">View all videos &rarr;</a>
            </div>
            <p style="font-size:12px;color:#90a4ae;margin:-6px 0 16px;">
                Track video engagement metrics including views, watch time, and student progress.
            </p>

            <%-- Filter Row --%>
            <div class="d-flex flex-wrap align-items-center gap-3 mb-4">
                <div class="d-flex align-items-center gap-2">
                    <i class="fas fa-filter" style="color:#78909c;"></i>
                    <asp:DropDownList ID="ddlEngagementSubject" runat="server"
                        CssClass="form-select form-select-sm" Style="width:180px;"
                        AutoPostBack="true"
                        OnSelectedIndexChanged="ddlEngagementSubject_SelectedIndexChanged">
                    </asp:DropDownList>
                </div>
                <div class="d-flex align-items-center gap-2">
                    <i class="fas fa-chart-line" style="color:#78909c;"></i>
                    <asp:DropDownList ID="ddlEngagementChartType" runat="server"
                        CssClass="form-select form-select-sm" Style="width:150px;"
                        AutoPostBack="true"
                        OnSelectedIndexChanged="ddlEngagementChartType_SelectedIndexChanged">
                        <asp:ListItem Text="Bar Chart"      Value="bar"           Selected="True" />
                        <asp:ListItem Text="Horizontal Bar" Value="horizontalBar" />
                        <asp:ListItem Text="Pie Chart"      Value="pie" />
                    </asp:DropDownList>
                </div>
            </div>

            <%-- KPI Cards --%>
            <asp:Panel ID="pnlEngagementKPIs" runat="server">
                <div class="row g-3 mb-4">
                    <div class="col-md-3 col-6">
                        <div class="engagement-metric-card" style="background:linear-gradient(135deg,#e3f2fd,#bbdef5);border-radius:16px;padding:18px;text-align:center;">
                            <i class="fas fa-eye" style="font-size:28px;color:#1565c0;margin-bottom:8px;display:inline-block;"></i>
                            <div style="font-size:11px;font-weight:700;color:#1565c0;text-transform:uppercase;letter-spacing:.5px;">Total Views</div>
                            <div style="font-size:32px;font-weight:800;color:#0d47a1;">
                                <asp:Label ID="lblTotalViews" runat="server" Text="0" />
                            </div>
                            <div style="font-size:11px;color:#78909c;">
                                <i class="fas fa-chart-line"></i>
                                <asp:Label ID="lblViewsTrend" runat="server" Text="+0%" />
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3 col-6">
                        <div class="engagement-metric-card" style="background:linear-gradient(135deg,#e8f5e9,#c8e6c9);border-radius:16px;padding:18px;text-align:center;">
                            <i class="fas fa-hourglass-half" style="font-size:28px;color:#2e7d32;margin-bottom:8px;display:inline-block;"></i>
                            <div style="font-size:11px;font-weight:700;color:#2e7d32;text-transform:uppercase;letter-spacing:.5px;">Avg Watch %</div>
                            <div style="font-size:32px;font-weight:800;color:#1b5e20;">
                                <asp:Label ID="lblAvgWatchPercent" runat="server" Text="0" />%
                            </div>
                            <div style="font-size:11px;color:#78909c;">
                                <i class="fas fa-clock"></i> average completion
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3 col-6">
                        <div class="engagement-metric-card" style="background:linear-gradient(135deg,#fff3e0,#ffe0b2);border-radius:16px;padding:18px;text-align:center;">
                            <i class="fas fa-trophy" style="font-size:28px;color:#ef6c00;margin-bottom:8px;display:inline-block;"></i>
                            <div style="font-size:11px;font-weight:700;color:#ef6c00;text-transform:uppercase;letter-spacing:.5px;">Most Viewed</div>
                            <div style="font-size:16px;font-weight:800;color:#e65100;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">
                                <asp:Label ID="lblMostViewedVideo" runat="server" Text="-" />
                            </div>
                            <div style="font-size:11px;color:#78909c;">
                                <asp:Label ID="lblMostViewedCount" runat="server" Text="0" /> views
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3 col-6">
                        <div class="engagement-metric-card" style="background:linear-gradient(135deg,#ede7f6,#d1c4e9);border-radius:16px;padding:18px;text-align:center;">
                            <i class="fas fa-video" style="font-size:28px;color:#5e35b1;margin-bottom:8px;display:inline-block;"></i>
                            <div style="font-size:11px;font-weight:700;color:#5e35b1;text-transform:uppercase;letter-spacing:.5px;">Total Videos</div>
                            <div style="font-size:32px;font-weight:800;color:#4527a0;">
                                <asp:Label ID="lblTotalVideosEngaged" runat="server" Text="0" />
                            </div>
                            <div style="font-size:11px;color:#78909c;">
                                <i class="fas fa-video"></i> uploaded this session
                            </div>
                        </div>
                    </div>
                </div>
            </asp:Panel>

            <%-- Chart + Top Videos --%>
            <div class="row g-3">
                <div class="col-lg-7">
                    <div style="background:#fafafa;border-radius:12px;padding:16px;">
                        <div style="font-size:12px;font-weight:700;color:#78909c;text-transform:uppercase;letter-spacing:.5px;margin-bottom:12px;">
                            <i class="fas fa-chart-bar me-2"></i>Video Analytics
                        </div>
                        <div style="position:relative;height:350px;">
                            <canvas id="engagementChart" role="img" aria-label="Video engagement chart"></canvas>
                        </div>
                        <asp:HiddenField ID="hfEngagementData" runat="server" ClientIDMode="Static" />
                    </div>
                </div>
                <div class="col-lg-5">
                    <div style="background:#f5f5f5;border-radius:12px;padding:16px;height:100%;">
                        <div style="font-size:12px;font-weight:700;color:#2e7d32;text-transform:uppercase;letter-spacing:.5px;margin-bottom:12px;">
                            <i class="fas fa-fire me-2" style="color:#ef6c00;"></i>Most Watched Videos
                        </div>
                        <asp:Panel ID="pnlTopVideos" runat="server">
                            <asp:Repeater ID="rptTopVideos" runat="server">
                                <ItemTemplate>
                                    <div style="display:flex;align-items:center;gap:12px;padding:10px 0;border-bottom:1px solid #e0e0e0;">
                                        <div style="width:32px;height:32px;border-radius:8px;background:<%# GetRankColorEngagement(Container.ItemIndex) %>;display:flex;align-items:center;justify-content:center;flex-shrink:0;">
                                            <i class="fas fa-play" style="font-size:12px;color:#fff;"></i>
                                        </div>
                                        <div style="flex:1;min-width:0;">
                                            <div style="font-size:13px;font-weight:700;color:#263238;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">
                                                <%# Eval("Title") %>
                                            </div>
                                            <div style="font-size:11px;color:#90a4ae;">
                                                <i class="fas fa-eye me-1"></i><%# Eval("ViewCount") %> views
                                            </div>
                                        </div>
                                        <div style="text-align:right;flex-shrink:0;">
                                            <div style="font-size:14px;font-weight:800;color:#ef6c00;">
                                                <%# Eval("WatchPercent") %>%
                                            </div>
                                            <div style="font-size:10px;color:#90a4ae;">avg watch</div>
                                        </div>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                        </asp:Panel>
                        <asp:Panel ID="pnlNoTopVideos" runat="server" Visible="false">
                            <div class="empty-state">
                                <i class="fas fa-video-slash"></i>
                                <p>No video data available yet.</p>
                            </div>
                        </asp:Panel>
                    </div>
                </div>
            </div>

            <%-- Least Watched + Watch Time Leaders --%>
            <div class="row g-3 mt-3">
                <div class="col-md-6">
                    <div style="background:#fff8f5;border-radius:12px;padding:16px;">
                        <div style="font-size:12px;font-weight:700;color:#c62828;text-transform:uppercase;letter-spacing:.5px;margin-bottom:12px;">
                            <i class="fas fa-exclamation-triangle me-2"></i>Least Watched (Needs Attention)
                        </div>
                        <asp:Panel ID="pnlLowVideos" runat="server">
                            <asp:Repeater ID="rptLowVideos" runat="server">
                                <ItemTemplate>
                                    <div style="display:flex;align-items:center;gap:12px;padding:10px 0;border-bottom:1px solid #ffccbc;">
                                        <div style="width:32px;height:32px;border-radius:8px;background:#ffccbc;display:flex;align-items:center;justify-content:center;flex-shrink:0;">
                                            <i class="fas fa-eye-slash" style="font-size:12px;color:#bf360c;"></i>
                                        </div>
                                        <div style="flex:1;min-width:0;">
                                            <div style="font-size:13px;font-weight:700;color:#263238;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">
                                                <%# Eval("Title") %>
                                            </div>
                                            <div style="font-size:11px;color:#90a4ae;">
                                                <i class="fas fa-eye me-1"></i><%# Eval("ViewCount") %> views
                                                &nbsp;|&nbsp;
                                                <i class="fas fa-chart-line"></i> <%# Eval("WatchPercent") %>% watch
                                            </div>
                                        </div>
                                        <div style="text-align:right;flex-shrink:0;">
                                            <a href='CourseVideos.aspx?VideoId=<%# Eval("VideoId") %>'
                                               class="btn-view" style="padding:4px 12px;font-size:11px;">
                                                Improve <i class="fas fa-arrow-right ms-1"></i>
                                            </a>
                                        </div>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                        </asp:Panel>
                        <asp:Panel ID="pnlNoLowVideos" runat="server" Visible="false">
                            <div class="empty-state">
                                <i class="fas fa-check-circle" style="color:#4caf50;"></i>
                                <p>All videos are performing well!</p>
                            </div>
                        </asp:Panel>
                    </div>
                </div>
                <div class="col-md-6">
                    <div style="background:#e8f5e9;border-radius:12px;padding:16px;">
                        <div style="font-size:12px;font-weight:700;color:#2e7d32;text-transform:uppercase;letter-spacing:.5px;margin-bottom:12px;">
                            <i class="fas fa-award me-2"></i>Watch Time Leaders
                        </div>
                        <asp:Panel ID="pnlWatchTimeLeaders" runat="server">
                            <asp:Repeater ID="rptWatchTimeLeaders" runat="server">
                                <ItemTemplate>
                                    <div style="display:flex;align-items:center;gap:12px;padding:10px 0;border-bottom:1px solid #c8e6c9;">
                                        <div style="width:36px;text-align:center;font-size:14px;font-weight:800;color:#f9a825;">
                                            #<%# Container.ItemIndex + 1 %>
                                        </div>
                                        <div style="flex:1;min-width:0;">
                                            <div style="font-size:13px;font-weight:700;color:#263238;">
                                                <%# Eval("StudentName") %>
                                            </div>
                                            <div style="font-size:11px;color:#90a4ae;">
                                                <i class="fas fa-clock me-1"></i><%# FormatWatchTime(Eval("TotalWatchSeconds")) %>
                                            </div>
                                        </div>
                                        <div style="text-align:right;">
                                            <div style="font-size:14px;font-weight:800;color:#2e7d32;">
                                                <%# Eval("AvgWatchPercent") %>%
                                            </div>
                                            <div style="font-size:10px;color:#90a4ae;">avg completion</div>
                                        </div>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                        </asp:Panel>
                        <asp:Panel ID="pnlNoWatchTimeLeaders" runat="server" Visible="false">
                            <div class="empty-state">
                                <i class="fas fa-user-graduate"></i>
                                <p>No watch time data available.</p>
                            </div>
                        </asp:Panel>
                    </div>
                </div>
            </div>

        </div>
    </div>
</div>
<%-- ══ LEARNING PATH + ACTIVITY TRACKING ══ --%>
<div class="row g-3 mt-2">

    <%-- LEFT: Learning Path Progress (col-lg-7) --%>
    <div class="col-lg-7">
        <div class="panel-card" style="height:100%;">
            <div class="section-header mb-2">
                <h6><i class="fas fa-route me-2"></i>Learning Path Progress</h6>
                <a href="Subjects_T_Side.aspx" style="color:#1976d2;">View subjects &rarr;</a>
            </div>
            <p style="font-size:12px;color:#90a4ae;margin:-6px 0 20px;">
                Track syllabus completion, chapters covered, and video watch progress per subject.
            </p>

            <%-- ── Summary KPI Strip ── --%>
            <div class="row g-3 mb-4">
                <div class="col-6 col-md-3">
                    <div style="background:linear-gradient(135deg,#e3f2fd,#bbdefb);border-radius:14px;padding:16px;text-align:center;">
                        <i class="fas fa-book-open" style="font-size:24px;color:#1565c0;margin-bottom:6px;display:block;"></i>
                        <div style="font-size:11px;font-weight:700;color:#1565c0;text-transform:uppercase;letter-spacing:.5px;">Total Chapters</div>
                        <div style="font-size:30px;font-weight:800;color:#0d47a1;">
                            <asp:Label ID="lblLpTotalChapters" runat="server" Text="0" />
                        </div>
                        <div style="font-size:11px;color:#78909c;">across all subjects</div>
                    </div>
                </div>
                <div class="col-6 col-md-3">
                    <div style="background:linear-gradient(135deg,#e8f5e9,#c8e6c9);border-radius:14px;padding:16px;text-align:center;">
                        <i class="fas fa-video" style="font-size:24px;color:#2e7d32;margin-bottom:6px;display:block;"></i>
                        <div style="font-size:11px;font-weight:700;color:#2e7d32;text-transform:uppercase;letter-spacing:.5px;">Total Videos</div>
                        <div style="font-size:30px;font-weight:800;color:#1b5e20;">
                            <asp:Label ID="lblLpTotalVideos" runat="server" Text="0" />
                        </div>
                        <div style="font-size:11px;color:#78909c;">uploaded this session</div>
                    </div>
                </div>
                <div class="col-6 col-md-3">
                    <div style="background:linear-gradient(135deg,#fff3e0,#ffe0b2);border-radius:14px;padding:16px;text-align:center;">
                        <i class="fas fa-hourglass-half" style="font-size:24px;color:#ef6c00;margin-bottom:6px;display:block;"></i>
                        <div style="font-size:11px;font-weight:700;color:#ef6c00;text-transform:uppercase;letter-spacing:.5px;">Avg Watch %</div>
                        <div style="font-size:30px;font-weight:800;color:#e65100;">
                            <asp:Label ID="lblLpAvgWatch" runat="server" Text="0" />%
                        </div>
                        <div style="font-size:11px;color:#78909c;">student average</div>
                    </div>
                </div>
                <div class="col-6 col-md-3">
                    <div style="background:linear-gradient(135deg,#ede7f6,#d1c4e9);border-radius:14px;padding:16px;text-align:center;">
                        <i class="fas fa-chart-pie" style="font-size:24px;color:#5e35b1;margin-bottom:6px;display:block;"></i>
                        <div style="font-size:11px;font-weight:700;color:#5e35b1;text-transform:uppercase;letter-spacing:.5px;">Video Completion</div>
                        <div style="font-size:30px;font-weight:800;color:#4527a0;">
                            <asp:Label ID="lblLpVideoCompletion" runat="server" Text="0" />%
                        </div>
                        <div style="font-size:11px;color:#78909c;">videos watched</div>
                    </div>
                </div>
            </div>

            <%-- ── Per-Subject Breakdown ── --%>
            <asp:Panel ID="pnlLearningPath" runat="server">
                <div style="font-size:11px;font-weight:700;color:#78909c;text-transform:uppercase;letter-spacing:.5px;margin-bottom:14px;">
                    <i class="fas fa-layer-group me-1"></i> Subject-wise Breakdown
                </div>
                <%-- Syllabus Completion Pie Chart --%>
<div class="row g-3 mb-4">
    <div class="col-md-5">
        <div style="background:#fff;border-radius:12px;padding:16px;box-shadow:0 1px 6px rgba(0,0,0,.06);">
            <div style="font-size:11px;font-weight:700;color:#1565c0;text-transform:uppercase;letter-spacing:.5px;margin-bottom:10px;">
<i class="fas fa-chart-pie me-1"></i> Video Coverage by Subject            </div>
            <div style="position:relative;height:220px;">
                <canvas id="lpPieChart" role="img" aria-label="Pie chart of syllabus completion per subject"></canvas>
            </div>
            <asp:HiddenField ID="hfLpPieData" runat="server" ClientIDMode="Static" />
        </div>
    </div>
    <div class="col-md-7">
        <div style="background:#fff;border-radius:12px;padding:16px;box-shadow:0 1px 6px rgba(0,0,0,.06);height:100%;">
            <div style="font-size:11px;font-weight:700;color:#78909c;text-transform:uppercase;letter-spacing:.5px;margin-bottom:10px;">
                <i class="fas fa-list me-1"></i> Completion Legend
            </div>
<asp:Repeater ID="rptLpPieLegend" runat="server">
    <ItemTemplate>
        <div onclick='openSubjectProgress(<%# Container.ItemIndex %>)'
             style="display:flex;align-items:center;justify-content:space-between;padding:7px 0;border-bottom:1px solid #f0f4ff;cursor:pointer;border-radius:6px;transition:background .15s;"
             onmouseover="this.style.background='#f0f7ff';this.style.paddingLeft='6px'"
             onmouseout="this.style.background='';this.style.paddingLeft='0'">
            <div style="display:flex;align-items:center;gap:8px;">
                <div style="width:12px;height:12px;border-radius:50%;background:<%# Eval("Color") %>;flex-shrink:0;"></div>
                <span style="font-size:12px;font-weight:600;color:#263238;"><%# Eval("SubjectName") %></span>
            </div>
            <div style="display:flex;align-items:center;gap:10px;">
                <div style="background:#e0e0e0;border-radius:6px;height:6px;width:80px;overflow:hidden;">
                    <div style="width:<%# Eval("SyllabusCompletionPct") %>%;height:100%;background:<%# Eval("Color") %>;border-radius:6px;"></div>
                </div>
                <span style="font-size:12px;font-weight:800;color:<%# Eval("Color") %>;min-width:36px;text-align:right;">
                    <%# Eval("SyllabusCompletionPct") %>%
                </span>
                <i class="fas fa-chevron-right" style="font-size:10px;color:#90a4ae;"></i>
            </div>
        </div>
    </ItemTemplate>
</asp:Repeater>        </div>
    </div>
</div>
<%-- Replace the rptLearningPath repeater with just the hidden data store --%>
<asp:Repeater ID="rptLearningPath" runat="server" Visible="false">
    <ItemTemplate></ItemTemplate>
</asp:Repeater>

<%-- ── Subject Detail Modal ── --%>
<div class="modal fade" id="subjectProgressModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content" style="border-radius:16px;border:none;">
            <div class="modal-header" style="background:linear-gradient(135deg,#1565c0,#1976d2);border-radius:16px 16px 0 0;padding:18px 24px;">
                <div>
                    <h5 class="modal-title" id="modalSubjectName" style="color:#fff;font-weight:800;margin:0;font-size:18px;"></h5>
                    <div id="modalSubjectMeta" style="color:rgba(255,255,255,.75);font-size:12px;margin-top:3px;"></div>
                </div>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body" style="padding:24px;">

                <%-- KPI Strip --%>
                <div class="row g-2 mb-4" id="spKpiRow">
                    <div class="col-6 col-md-3">
                        <div style="background:#e3f2fd;border-radius:10px;padding:12px;text-align:center;">
                            <div style="font-size:10px;font-weight:700;color:#1565c0;text-transform:uppercase;letter-spacing:.5px;">Students</div>
                            <div style="font-size:26px;font-weight:800;color:#1565c0;" id="spStudents">0</div>
                        </div>
                    </div>
                    <div class="col-6 col-md-3">
                        <div style="background:#e8f5e9;border-radius:10px;padding:12px;text-align:center;">
                            <div style="font-size:10px;font-weight:700;color:#2e7d32;text-transform:uppercase;letter-spacing:.5px;">Syllabus</div>
                            <div style="font-size:26px;font-weight:800;color:#2e7d32;" id="spSyllabus">0%</div>
                        </div>
                    </div>
                    <div class="col-6 col-md-3">
                        <div style="background:#fff3e0;border-radius:10px;padding:12px;text-align:center;">
                            <div style="font-size:10px;font-weight:700;color:#ef6c00;text-transform:uppercase;letter-spacing:.5px;">Avg Watch</div>
                            <div style="font-size:26px;font-weight:800;color:#ef6c00;" id="spAvgWatch">0%</div>
                        </div>
                    </div>
                    <div class="col-6 col-md-3">
                        <div style="background:#ede7f6;border-radius:10px;padding:12px;text-align:center;">
                            <div style="font-size:10px;font-weight:700;color:#5e35b1;text-transform:uppercase;letter-spacing:.5px;">Videos</div>
                            <div style="font-size:22px;font-weight:800;color:#5e35b1;" id="spVideos">0/0</div>
                        </div>
                    </div>
                </div>

                <%-- Progress Bars --%>
                <div style="background:#f8fbff;border-radius:12px;padding:16px;margin-bottom:20px;">
                    <div style="margin-bottom:14px;">
                        <div style="display:flex;justify-content:space-between;font-size:12px;color:#78909c;margin-bottom:5px;">
                            <span><i class="fas fa-graduation-cap me-1" style="color:#1565c0;"></i>Syllabus Completion</span>
                            <span style="font-weight:700;" id="spSyllabusBarLbl">0%</span>
                        </div>
                        <div style="background:#e0e0e0;border-radius:8px;height:10px;overflow:hidden;">
                            <div id="spSyllabusBar" style="height:100%;border-radius:8px;background:#1565c0;transition:width .6s;width:0%;"></div>
                        </div>
                    </div>
                    <div style="margin-bottom:14px;">
                        <div style="display:flex;justify-content:space-between;font-size:12px;color:#78909c;margin-bottom:5px;">
                            <span><i class="fas fa-video me-1" style="color:#2e7d32;"></i>Videos Watched</span>
                            <span style="font-weight:700;" id="spVideosBarLbl">0/0</span>
                        </div>
                        <div style="background:#e0e0e0;border-radius:8px;height:10px;overflow:hidden;">
                            <div id="spVideosBar" style="height:100%;border-radius:8px;background:#2e7d32;transition:width .6s;width:0%;"></div>
                        </div>
                    </div>
                    <div>
                        <div style="display:flex;justify-content:space-between;font-size:12px;color:#78909c;margin-bottom:5px;">
                            <span><i class="fas fa-book-open me-1" style="color:#ef6c00;"></i>Chapters Covered</span>
                            <span style="font-weight:700;" id="spChaptersBarLbl">0/0</span>
                        </div>
                        <div style="background:#e0e0e0;border-radius:8px;height:10px;overflow:hidden;">
                            <div id="spChaptersBar" style="height:100%;border-radius:8px;background:#ef6c00;transition:width .6s;width:0%;"></div>
                        </div>
                    </div>
                </div>

                <%-- Chart --%>
                <div style="background:#fafafa;border-radius:12px;padding:16px;">
                    <div style="font-size:11px;font-weight:700;color:#78909c;text-transform:uppercase;letter-spacing:.5px;margin-bottom:12px;">
                        <i class="fas fa-chart-bar me-1"></i> Progress Overview
                    </div>
                    <div style="position:relative;height:220px;">
                        <canvas id="subjectProgressChart" role="img"></canvas>
                    </div>
                </div>

            </div>
        </div>
    </div>
</div>            </asp:Panel>
            <asp:Panel ID="pnlNoLearningPath" runat="server" Visible="false">
                <div class="empty-state">
                    <i class="fas fa-route" style="color:#90caf9;"></i>
                    <p>No learning path data yet.<br />Upload chapters and videos to track progress.</p>
                </div>
            </asp:Panel>
        </div>
    </div>

    <%-- RIGHT: Activity Tracking (col-lg-5) --%>
    <%-- ══ ACTIVITY TRACKING - FIXED VERSION ══ --%>
<div class="col-lg-5">
    <div class="panel-card" style="height:100%;">

        <div class="section-header mb-2">
            <h6><i class="fas fa-bolt me-2"></i>Activity Tracking</h6>
        </div>
        <p style="font-size:12px;color:#90a4ae;margin:-6px 0 16px;">
            Daily actions, last active time, and activity trends.
        </p>

        <%-- KPI Strip --%>
        <div class="row g-2 mb-3">
            <div class="col-6">
                <div style="background:linear-gradient(135deg,#e3f2fd,#bbdefb);border-radius:12px;padding:12px 14px;">
                    <div style="font-size:10px;font-weight:700;color:#1565c0;text-transform:uppercase;letter-spacing:.5px;">Assignments This Month</div>
                    <div style="font-size:28px;font-weight:800;color:#0d47a1;">
                        <asp:Label ID="lblActTodayCount" runat="server" Text="0" />
                    </div>
                    <div style="font-size:10px;color:#78909c;"><i class="fas fa-calendar-day me-1"></i>actions logged today</div>
                </div>
            </div>
            <div class="col-6">
                <div style="background:linear-gradient(135deg,#e8f5e9,#c8e6c9);border-radius:12px;padding:12px 14px;">
                    <div style="font-size:10px;font-weight:700;color:#2e7d32;text-transform:uppercase;letter-spacing:.5px;">Submissions Graded</div>
                    <div style="font-size:28px;font-weight:800;color:#1b5e20;">
                        <asp:Label ID="lblActWeekCount" runat="server" Text="0" />
                    </div>
                    <div style="font-size:10px;color:#78909c;"><i class="fas fa-calendar-week me-1"></i>actions this week</div>
                </div>
            </div>
            <div class="col-6">
                <div style="background:linear-gradient(135deg,#fff3e0,#ffe0b2);border-radius:12px;padding:12px 14px;">
                    <div style="font-size:10px;font-weight:700;color:#ef6c00;text-transform:uppercase;letter-spacing:.5px;">Last Assignment</div>
                    <div style="font-size:13px;font-weight:800;color:#e65100;line-height:1.3;margin-top:3px;">
                        <asp:Label ID="lblActLastActive" runat="server" Text="-" />
                    </div>
                    <div style="font-size:10px;color:#78909c;margin-top:2px;"><i class="fas fa-clock me-1"></i>most recent activity</div>
                </div>
            </div>
            <div class="col-6">
                <div style="background:linear-gradient(135deg,#ede7f6,#d1c4e9);border-radius:12px;padding:12px 14px;">
                    <div style="font-size:10px;font-weight:700;color:#5e35b1;text-transform:uppercase;letter-spacing:.5px;">Videos This Month</div>
                    <div style="font-size:28px;font-weight:800;color:#4527a0;">
                        <asp:Label ID="lblActActiveDays" runat="server" Text="0" />
                    </div>
                    <div style="font-size:10px;color:#78909c;"><i class="fas fa-fire me-1"></i>days active this month</div>
                </div>
            </div>
        </div>

        <%-- Chart type toggle --%>
        <div class="d-flex align-items-center gap-2 mb-3">
            <span style="font-size:11px;font-weight:700;color:#78909c;">View as:</span>
            <div class="btn-group btn-group-sm">
                <button type="button" id="btnActLine" onclick="setActChartType('line')"
                        class="btn btn-primary" title="Line Chart">
                    <i class="fas fa-chart-line"></i>
                </button>
                <button type="button" id="btnActBar" onclick="setActChartType('bar')"
                        class="btn btn-outline-primary" title="Bar Chart">
                    <i class="fas fa-chart-bar"></i>
                </button>
            </div>
            <span style="font-size:11px;color:#90a4ae;margin-left:4px;">Last 7 days</span>
        </div>

        <%-- Trend Chart --%>
        <asp:Panel ID="pnlActivityChart" runat="server">
            <div style="position:relative;height:180px;margin-bottom:16px;">
                <canvas id="activityTrendChart" role="img" aria-label="Teacher activity trend chart"></canvas>
            </div>
            <asp:HiddenField ID="hfActivityTrendData" runat="server" ClientIDMode="Static" />
        </asp:Panel>

        <%-- Recent Activity Log - ONLY ONE PANEL --%>
        <div style="font-size:11px;font-weight:700;color:#78909c;text-transform:uppercase;
                    letter-spacing:.5px;margin-bottom:10px;">
            <i class="fas fa-history me-1"></i> Recent Actions
        </div>

        <asp:Panel ID="pnlActivityLog" runat="server">
            <asp:Repeater ID="rptActivityLog" runat="server">
                <ItemTemplate>
                    <div class="activity-log-item"
                         style="display:flex;align-items:flex-start;gap:10px;padding:9px 0;
                                border-bottom:1px solid #e3f2fd;">
                        <div style="width:34px;height:34px;border-radius:9px;
                                    background:<%# GetActivityIconBg(Eval("ActionType").ToString()) %>;
                                    display:flex;align-items:center;justify-content:center;flex-shrink:0;">
                            <i class="fas <%# GetActivityIcon(Eval("ActionType").ToString()) %>"
                               style="font-size:13px;color:#fff;"></i>
                        </div>
                        <div style="flex:1;min-width:0;">
                            <div style="font-size:12px;font-weight:700;color:#263238;
                                        white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">
                                <%# Eval("ActionDescription") %>
                            </div>
                            <div style="font-size:10px;color:#90a4ae;">
                                <i class="fas fa-tag me-1"></i><%# Eval("ActionType") %>
                            </div>
                        </div>
                        <div style="text-align:right;flex-shrink:0;">
                            <div style="font-size:10px;color:#90a4ae;"><%# Eval("TimeAgo") %></div>
                            <div style="font-size:10px;color:#b0bec5;"><%# Eval("ActionDate") %></div>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>

            <%-- See more button --%>
            <div id="activitySeeMoreBtn" style="text-align:center;margin-top:10px;display:none;">
                <button type="button" onclick="openAllActivityModal()"
                        style="background:none;border:1.5px solid #bbdefb;border-radius:20px;
                               padding:5px 18px;font-size:11px;font-weight:700;color:#1565c0;
                               cursor:pointer;transition:all .2s;"
                        onmouseover="this.style.background='#e3f2fd'"
                        onmouseout="this.style.background='none'">
                    <i class="fas fa-chevron-down me-1"></i>See all activity
                </button>
            </div>
        </asp:Panel>

        <asp:Panel ID="pnlNoActivityLog" runat="server" Visible="false">
            <div class="empty-state">
                <i class="fas fa-history" style="color:#90caf9;"></i>
                <p>No activity recorded yet.</p>
            </div>
        </asp:Panel>

        <%-- Action breakdown mini-chips --%>
        <asp:Panel ID="pnlActivityBreakdown" runat="server">
            <div style="font-size:11px;font-weight:700;color:#78909c;text-transform:uppercase;letter-spacing:.5px;margin:14px 0 8px;">
                <i class="fas fa-layer-group me-1"></i> Action Breakdown
            </div>
            <div style="display:flex;flex-wrap:wrap;gap:6px;">
                <asp:Repeater ID="rptActivityBreakdown" runat="server">
                    <ItemTemplate>
                        <span style="display:inline-flex;align-items:center;gap:5px;background:<%# GetActivityIconBg(Eval("ActionType").ToString()) %>22;color:<%# GetActivityIconBg(Eval("ActionType").ToString()) %>;border:1.5px solid <%# GetActivityIconBg(Eval("ActionType").ToString()) %>44;border-radius:20px;padding:4px 11px;font-size:11px;font-weight:700;">
                            <i class="fas <%# GetActivityIcon(Eval("ActionType").ToString()) %>"></i>
                            <%# Eval("ActionType") %>
                            <span style="background:<%# GetActivityIconBg(Eval("ActionType").ToString()) %>;color:#fff;border-radius:10px;padding:1px 7px;font-size:10px;"><%# Eval("ActionCount") %></span>
                        </span>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </asp:Panel>

    </div>
</div>

</div>

    <%-- ══ SECTION STUDENTS MODAL ══ --%>
<div class="modal fade" id="sectionStudentsModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content" style="border-radius:16px;border:none;">
            <div class="modal-header"
                 style="background:linear-gradient(135deg,#1565c0,#42a5f5);
                        border-radius:16px 16px 0 0;padding:18px 24px;">
                <div>
                    <h5 class="modal-title" id="sectionModalTitle"
                        style="color:#fff;font-weight:800;margin:0;font-size:18px;">
                        Section Students
                    </h5>
                    <div id="sectionModalMeta"
                         style="color:rgba(255,255,255,.75);font-size:12px;margin-top:3px;">
                    </div>
                </div>
                <button type="button" class="btn-close btn-close-white"
                        data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body" style="padding:24px;">

                <%-- Search --%>
                <div style="margin-bottom:16px;">
                    <input type="text" id="sectionStudentSearch"
                           placeholder="Search student..."
                           oninput="filterSectionStudents(this.value)"
                           style="width:100%;padding:9px 14px;border:1.5px solid #bbdefb;
                                  border-radius:10px;font-size:13px;outline:none;" />
                </div>

                <%-- Loading --%>
                <div id="sectionStudentsLoading"
                     style="text-align:center;padding:30px;color:#90a4ae;">
                    <i class="fas fa-spinner fa-spin"
                       style="font-size:28px;margin-bottom:8px;display:block;"></i>
                    Loading students...
                </div>

                <%-- List --%>
                <div id="sectionStudentsList" style="display:none;"></div>

                <%-- Empty --%>
                <div id="sectionStudentsEmpty"
                     style="display:none;text-align:center;padding:30px;color:#90a4ae;">
                    <i class="fas fa-users"
                       style="font-size:32px;margin-bottom:8px;display:block;"></i>
                    No students found in this section.
                </div>

            </div>
        </div>
    </div>
</div>
    <%-- ══ ALL ACTIVITY MODAL ══ --%>
<div class="modal fade" id="allActivityModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-md modal-dialog-centered modal-dialog-scrollable">
        <div class="modal-content" style="border-radius:16px;border:none;">
            <div class="modal-header"
                 style="background:linear-gradient(135deg,#1565c0,#42a5f5);
                        border-radius:16px 16px 0 0;padding:18px 24px;">
                <div>
                    <h5 class="modal-title"
                        style="color:#fff;font-weight:800;margin:0;font-size:18px;">
                        <i class="fas fa-history me-2"></i>All Recent Actions
                    </h5>
                    <div style="color:rgba(255,255,255,.75);font-size:12px;margin-top:3px;">
                        Your latest assignments, videos, grading &amp; more
                    </div>
                </div>
                <button type="button" class="btn-close btn-close-white"
                        data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body" style="padding:20px;" id="allActivityModalBody">
                <div style="text-align:center;padding:30px;color:#90a4ae;">
                    <i class="fas fa-spinner fa-spin"
                       style="font-size:24px;margin-bottom:8px;display:block;"></i>
                    Loading...
                </div>
            </div>
        </div>
    </div>
</div>
  <script>
      // Initialize all charts when page loads
      document.addEventListener('DOMContentLoaded', function () {
          initTeacherDashboard(
              {
                  hfChartData: '<%= hfChartData.ClientID %>',
                  hfDivisionData: '<%= hfDivisionData.ClientID %>',
                  hfAvgMarksData: '<%= hfAvgMarksData.ClientID %>',
                  hfAsgChartData: '<%= hfAsgChartData.ClientID %>',
                  hfEngagementData: '<%= hfEngagementData.ClientID %>',
                  hfActivityTrendData: '<%= hfActivityTrendData.ClientID %>',
                  hfLpPieData: '<%= hfLpPieData.ClientID %>',
                    hfSecCompareData: '<%= hfSecCompareData.ClientID %>',
                    hfSubCompareData: '<%= hfSubCompareData.ClientID %>'
                },
                {
                    pnlAssignments: '<%= pnlAssignments.ClientID %>',
                    pnlAsgChart: '<%= pnlAsgChart.ClientID %>',
                    pnlNoSecCompare: '<%= pnlNoSecCompare.ClientID %>',
                    pnlNoSubCompare: '<%= pnlNoSubCompare.ClientID %>'
                },
                {
                    ddlEngagementChartType: '<%= ddlEngagementChartType.ClientID %>'
              }
          );
      });
  </script>
<script>
    document.addEventListener('DOMContentLoaded', function () {
        setTimeout(function () {
            var canvas = document.getElementById('divisionChart');
            if (canvas) {
                canvas.addEventListener('click', function (e) {
                    console.log('Canvas clicked', e);
                });
                console.log('Division chart canvas found');
            } else {
                console.log('ERROR: divisionChart canvas NOT found');
            }
        }, 2000);
    });
</script>
</asp:Content>