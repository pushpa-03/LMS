<%@ Page Title="Student Analytics Pro" Language="C#" MasterPageFile="~/Admin/AdminMaster.master" AutoEventWireup="true" CodeBehind="StudentDetails.aspx.cs" Inherits="LearningManagementSystem.Admin.StudentDetails" %>

<asp:Content ID="c2" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;600;800&display=swap" rel="stylesheet">

    <style>
        :root {
            --glass-bg: rgba(255, 255, 255, 0.75);
            --glass-border: rgba(255, 255, 255, 0.4);
            --primary-blue: #1e40af;
            --accent-blue: #3b82f6;
            --bg-gradient: linear-gradient(135deg, #f0f9ff 0%, #e0f2fe 100%);
        }

        body { background: var(--bg-gradient); font-family: 'Plus Jakarta Sans', sans-serif; color: #1e293b; }

        /* Glassmorphism Card System */
        .glass-card {            
            background: var(--glass-bg);
            backdrop-filter: blur(15px);
            -webkit-backdrop-filter: blur(15px);
            border: 1px solid var(--glass-border);
            border-radius: 24px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.04);
            border-left:4px solid transparent;
            border-top:2px solid transparent;
            transition:all .2s ease;
            border-left-color:#1565c0;
            border-top-color:#1565c0;
            padding: 24px;
            margin-bottom: 24px;
        }

        .glass-card h6 {
            color:#1565c0;
        }

        /* Pro Profile Banner */
        .profile-hero {
            background: linear-gradient(135deg, #1e3a8a 0%, #3b82f6 100%);
            border-radius: 24px;
            padding: 40px;
            color: white;
            display: flex;
            justify-content: space-between;
            align-items: center;
            position: relative;
            overflow: hidden;
            box-shadow: 0 20px 40px rgba(30, 58, 138, 0.2);
        }

        .user-avatar {
            width: 100px; height: 100px;
            background: white; color: var(--primary-blue);
            border-radius: 50%; display: flex; align-items: center; justify-content: center;
            font-size: 38px; font-weight: 800; border: 5px solid rgba(255,255,255,0.2);
        }

        /* Stats Grid */
        .stat-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; }
        .stat-item { text-align: center; border-right: 1px solid rgba(0,0,0,0.05); }
        .stat-item:last-child { border-right: none; }
        .stat-value { font-size: 26px; font-weight: 800; color: var(--primary-blue); }
        .stat-label { font-size: 11px; text-transform: uppercase; color: #64748b; letter-spacing: 1px;  }

        /* Subject Interactive Rows */
        .subject-card {
            background: white; border-radius: 16px; padding: 18px;
            margin-bottom: 12px; display: flex; align-items: center; justify-content: space-between;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            border: 1px solid transparent; text-decoration: none !important; color: inherit;
        }
        .subject-card:hover {
            transform: scale(1.02); border-color: var(--accent-blue);
            box-shadow: 0 10px 20px rgba(59, 130, 246, 0.1);
        }

        /* Custom Progress Bars */
        .progress-track { height: 10px; width: 120px; background: #f1f5f9; border-radius: 20px; overflow: hidden; }
        .progress-fill { height: 100%; background: linear-gradient(90deg, #3b82f6, #60a5fa); border-radius: 20px; }

        /* Filter Pills */
        .filter-bar {
            background: white; border-radius: 50px; padding: 8px 24px;
            display: inline-flex; align-items: center; gap: 15px; box-shadow: 0 4px 12px rgba(0,0,0,0.05);
        }

        .status-pill { padding: 6px 16px; border-radius: 50px; font-size: 11px; font-weight: 700; }
        .status-at-risk { background: #fee2e2; color: #ef4444; }
        .status-good { background: #dcfce7; color: #22c55e; }
    </style>

    <div class="container-fluid py-4">
        <div class="d-flex justify-content-between align-items-center mb-4">           

            <div class="filter-bar">
                <asp:HyperLink ID="btnBack" runat="server" NavigateUrl="StudentsList.aspx" CssClass="btn btn-light rounded-circle shadow-sm me-2" style="width:45px; height:45px; display:flex; align-items:center; justify-content:center;">
                    <i class="fas fa-arrow-left text-primary"></i>
                </asp:HyperLink>

                <i class="fas fa-calendar-alt text-primary"></i>
                <asp:DropDownList ID="ddlAcademicScope" runat="server" CssClass="form-select border-0 shadow-none bg-transparent" AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed">
                    <asp:ListItem Text="Current Academic Session" Value="Current" />
                    <asp:ListItem Text="Show All History" Value="All" />
                </asp:DropDownList>
            </div>
            <asp:LinkButton ID="btnExport" runat="server" CssClass="btn btn-primary rounded-pill px-4 shadow-sm" OnClick="btnDownload_Click">
                <i class="fas fa-cloud-download-alt me-2"></i>Download Analysis
            </asp:LinkButton>
        </div>

        <div class="profile-hero mb-4">
            <div class="d-flex align-items-center gap-4">              

                <div class="user-avatar"><asp:Literal ID="litInitial" runat="server" /></div>
                <div>
                    <h1 class="fw-bold mb-1"><asp:Label ID="lblName" runat="server" /></h1>
                    <div class="d-flex gap-3 align-items-center opacity-90">
                        <span> <i class="fas fa-fingerprint me-2"></i><asp:Label ID="lblRoll" runat="server" /></span>
                        <span><i class="fas fa-envelope me-2"></i><asp:Label ID="lblEmail" runat="server" /></span>
                    </div>
                    <div class="mt-3"><asp:Literal ID="litRiskBadge" runat="server" /></div>
                </div>
            </div>
            <div class="text-end">
                <div class="h4 mb-0"><asp:Label ID="lblCourseHeader" runat="server" /></div>
                <div class="opacity-75">Semester <asp:Label ID="lblSemHeader" runat="server" /></div>
            </div>
        </div>

        <div class="col-lg-12">
            <div class="glass-card">
                <h6 class="fw-bold border-bottom pb-3 mb-3">
                    <i class="fas fa-user-circle me-2"></i>Profile Details
                </h6>
        
                <div class="detail-row mb-3">
                    <label class="small text-muted d-block">Department & Course</label>
                    <span class="fw-bold text-dark"><asp:Label ID="lbl_Stream" runat="server" /></span>
                </div>

                <div class="row mb-3">
                    <div class="col-6">
                        <label class="small text-muted d-block">Gender</label>
                        <span class="fw-bold"><asp:Label ID="lblGender" runat="server" /></span>
                    </div>
                    <div class="col-6">
                        <label class="small text-muted d-block">DOB</label>
                        <span class="fw-bold"><asp:Label ID="lblDOB" runat="server" /></span>
                    </div>
                </div>

                <div class="mb-3">
                    <label class="small text-muted d-block">Contact Number</label>
                    <span class="fw-bold"><i class="fas fa-phone-alt me-2 small text-primary"></i><asp:Label ID="lblPhone" runat="server" /></span>
                </div>

                <div class="mb-3">
                    <label class="small text-muted d-block">Address</label>
                    <span class="small fw-semibold text-dark"><asp:Label ID="lblAddress" runat="server" /></span>
                </div>

                <div class="p-3 bg-light rounded-3 mb-3">
                    <label class="small text-muted d-block mb-1">Emergency Contact</label>
                    <div class="fw-bold small"><asp:Label ID="lblEmerName" runat="server" /></div>
                    <div class="text-primary small"><asp:Label ID="lblEmerPhone" runat="server" /></div>
                </div>

                <div class="mb-0">
                    <label class="small text-muted d-block mb-2">Technical Skills</label>
                    <div class="d-flex flex-wrap gap-2">
                        <asp:Literal ID="lbl_Skills" runat="server" />
                    </div>
                </div>
            </div>
        </div>

        <div class="glass-card stat-grid">
            <div class="stat-item">
                <div class="stat-value"><asp:Label ID="lblSubCount" runat="server" /></div>
                <div class="stat-label">Active Subjects</div>
            </div>
            <div class="stat-item">
                <div class="stat-value text-success"><asp:Label ID="lblAttPer" runat="server" /></div>
                <div class="stat-label">Avg Attendance</div>
            </div>
            <div class="stat-item">
                <div class="stat-value text-primary"><asp:Label ID="lblOverallProgress" runat="server" />%</div>
                <div class="stat-label">Course Completion</div>
            </div>
            <div class="stat-item">
                <div class="stat-value text-warning"><asp:Label ID="lblTaskCount" runat="server" /></div>
                <div class="stat-label">Total Assignments</div>
            </div>
        </div>

        <div class="row">
            <div class="col-lg-8">
                <div class="row mb-4">
                    <div class="col-md-6">
                        <div class="glass-card">
                            <h6 class="fw-bold mb-4"><i class="fas fa-chart-pie me-2 text-primary"></i>Attendance Mix</h6>
                            <canvas id="chartAttendance" height="200"></canvas>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="glass-card">
                            <h6 class="fw-bold mb-4"><i class="fas fa-chart-bar me-2 text-primary"></i>Learning Engagement</h6>
                            <canvas id="chartActivity" height="300"></canvas>
                        </div>
                    </div>
                </div>                
         </div>
        

            <div class="col-lg-4">
               <%-- <div class="glass-card">
                    <h6 class="fw-bold border-bottom pb-2 mb-3">Academic Snapshot</h6>
                    <div class="mb-3">
                        <label class="small text-muted d-block">Department & Course</label>
                        <span class="fw-bold"><asp:Label ID="lblStream" runat="server" /></span>
                    </div>
                    <div class="mb-3">
                        <label class="small text-muted d-block">Skills Profile</label>
                        <div class="d-flex flex-wrap gap-2 mt-1">
                            <asp:Literal ID="litSkills" runat="server" />
                        </div>
                    </div>
                </div>--%>

                <div class="glass-card" style="max-height: 450px; overflow-y: auto;">
                    <h6 class="fw-bold border-bottom pb-2 mb-3">Live Activity Feed</h6>
                    <asp:Repeater ID="rptActivity" runat="server">
                        <ItemTemplate>
                            <div class="d-flex gap-3 mb-3 border-start ps-3 border-2 border-primary border-opacity-25">
                                <div>
                                    <div class="small fw-bold text-dark"><%# Eval("ActivityType") %></div>
                                    <div class="text-muted" style="font-size: 11px;">
                                        <i class="far fa-clock me-1"></i><%# Eval("ActionTime", "{0:MMM dd, HH:mm}") %>
                                    </div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </div>
        </div>

        <div class="row">
        <div class="col-lg-12">
            <div class="glass-card">
                <div class="d-flex justify-content-between mb-4">
                    <h6 class="fw-bold">Subject-Wise Deep Dive</h6>
                    <span class="small text-muted">Click a subject for full details</span>
                </div>
                <asp:Repeater ID="rptSubjects" runat="server">
                    <ItemTemplate>
                        <a href='SubjectDetails.aspx?id=<%# Eval("SubjectId") %>' class="subject-card shadow-sm">
                            <div class="d-flex align-items-center gap-3">
                                <div class="bg-primary bg-opacity-10 p-3 rounded-circle text-primary">
                                    <i class="fas fa-book"></i>
                                </div>
                                <div>
                                    <div class="fw-bold text-dark"><%# Eval("SubjectName") %></div>
                                    <div class="small text-muted">Faculty: <span class="fw-bold text-primary"><%# Eval("TeacherName") %></span></div>
                                </div>
                            </div>
                            <div class="text-end">
                                <div class="small fw-bold mb-1"><%# Eval("Progress") %>% Completed</div>
                                <div class="progress-track">
                                    <div class="progress-fill" style='width:<%# Eval("Progress") %>%'></div>
                                </div>
                            </div>
                        </a>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>
    </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script>
        const attData = <%= AttendanceJson %>;
        const engData = <%= ProgressJson %>;

        // Attendance Chart
        new Chart(document.getElementById("chartAttendance"), {
            type: 'doughnut',
            data: {
                labels: ['Present', 'Absent'],
                datasets: [{
                    data: attData,
                    backgroundColor: ['#3b82f6', '#f1f5f9'],
                    borderWidth: 0,
                    hoverOffset: 10
                }]
            },
            options: { cutout: '80%', plugins: { legend: { position: 'bottom' } } }
        });

        // Engagement Chart
        new Chart(document.getElementById("chartActivity"), {
            type: 'bar',
            data: {
                labels: ['Videos', 'Assignments', 'Quizzes'],
                datasets: [{
                    label: 'Completed',
                    data: engData,
                    backgroundColor: '#1e3a8a',
                    borderRadius: 10
                }]
            },
            options: {
                scales: { y: { display: false }, x: { grid: { display: false } } },
                plugins: { legend: { display: false } }
            }
        });
    </script>
</asp:Content>