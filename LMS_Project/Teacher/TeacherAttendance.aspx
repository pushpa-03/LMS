<%@ Page Title="Attendance" Language="C#" MasterPageFile="~/Teacher/TeacherMaster.master"
    AutoEventWireup="true" CodeBehind="TeacherAttendance.aspx.cs"
    Inherits="LMS_Project.Teacher.TeacherAttendance" %>

<asp:Content ID="headContent" ContentPlaceHolderID="head" runat="server">
<style>

/* ── Page Banner ── */
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
    content: "\f46d";
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
.page-banner h4 { margin: 0 0 4px; font-weight: 800; font-size: 20px; }
.page-banner p  { margin: 0; opacity: .85; font-size: 13px; }

/* ── CSS Variables ── */
:root {
    --blue-dark:   #1565c0;
    --blue-mid:    #1976d2;
    --blue-light:  #42a5f5;
    --blue-pale:   #e3f2fd;
    --green:       #2e7d32;
    --green-light: #e8f5e9;
    --red:         #c62828;
    --red-light:   #ffebee;
    --amber:       #f57c00;
    --amber-light: #fff3e0;
    --card-shadow: 0 2px 12px rgba(21,101,192,.10);
}

/* ── Tabs ── */
.att-tabs {
    display: flex;
    gap: 6px;
    background: #fff;
    border-radius: 12px;
    padding: 6px;
    box-shadow: var(--card-shadow);
    margin-bottom: 20px;
}
.att-tab-btn {
    flex: 1;
    padding: 10px 18px;
    border: none;
    border-radius: 9px;
    font-size: 13px;
    font-weight: 700;
    cursor: pointer;
    background: transparent;
    color: #78909c;
    transition: .2s;
    letter-spacing: .3px;
}
.att-tab-btn.active {
    background: var(--blue-dark);
    color: #fff;
    box-shadow: 0 2px 8px rgba(21,101,192,.3);
}
.att-tab-btn:hover:not(.active) {
    background: var(--blue-pale);
    color: var(--blue-dark);
}

/* ── Card ── */
.att-card {
    background: #fff;
    border-radius: 14px;
    padding: 22px 24px;
    box-shadow: var(--card-shadow);
    margin-bottom: 20px;
}
.att-card-title {
    font-size: 14px;
    font-weight: 700;
    color: var(--blue-dark);
    margin-bottom: 16px;
    display: flex;
    align-items: center;
    gap: 8px;
    padding-bottom: 12px;
    border-bottom: 2px solid var(--blue-pale);
}

/* ── Filter row ── */
.att-filter-row {
    display: flex;
    flex-wrap: wrap;
    gap: 14px;
    align-items: flex-end;
}
.att-filter-group {
    display: flex;
    flex-direction: column;
    gap: 5px;
    min-width: 180px;
}
.att-filter-group label {
    font-size: 11px;
    font-weight: 700;
    color: #78909c;
    text-transform: uppercase;
    letter-spacing: .5px;
}
.att-filter-group select,
.att-filter-group input[type=date] {
    padding: 9px 12px;
    border: 1.5px solid #bbdefb;
    border-radius: 10px;
    font-size: 13px;
    color: #455a64;
    background: #f0f7ff;
    outline: none;
    transition: .2s;
}
.att-filter-group select:focus,
.att-filter-group input[type=date]:focus {
    border-color: var(--blue-light);
    background: #fff;
    box-shadow: 0 0 0 3px rgba(66,165,245,.15);
}

/* ── Buttons ── */
.att-btn {
    padding: 9px 22px;
    border: none;
    border-radius: 10px;
    font-size: 13px;
    font-weight: 700;
    cursor: pointer;
    transition: .2s;
    display: inline-flex;
    align-items: center;
    gap: 7px;
}
.att-btn-primary { background: var(--blue-dark); color: #fff; }
.att-btn-primary:hover { background: var(--blue-mid); transform: translateY(-2px); }
.att-btn-success { background: var(--green); color: #fff; }
.att-btn-success:hover { background: #1b5e20; transform: translateY(-2px); }

/* ── Alerts ── */
.att-alert {
    padding: 10px 16px;
    border-radius: 10px;
    font-size: 13px;
    font-weight: 600;
    margin-bottom: 14px;
    display: flex;
    align-items: center;
    gap: 8px;
}
.att-alert-info    { background: var(--blue-pale);   color: var(--blue-dark); border-left: 4px solid var(--blue-dark); }
.att-alert-success { background: var(--green-light); color: var(--green);     border-left: 4px solid var(--green); }
.att-alert-warning { background: var(--amber-light); color: var(--amber);     border-left: 4px solid var(--amber); }
.att-alert-danger  { background: var(--red-light);   color: var(--red);       border-left: 4px solid var(--red); }

/* ── Table ── */
.att-table-wrap { overflow-x: auto; }
.att-table {
    width: 100%;
    border-collapse: collapse;
    font-size: 13px;
}
.att-table thead th {
    background: var(--blue-pale);
    color: var(--blue-dark);
    padding: 11px 14px;
    font-weight: 700;
    font-size: 11px;
    text-transform: uppercase;
    letter-spacing: .5px;
    border: none;
}
.att-table thead th:first-child { border-radius: 10px 0 0 0; }
.att-table thead th:last-child  { border-radius: 0 10px 0 0; }
.att-table tbody tr:hover { background: var(--blue-pale); }
.att-table tbody td {
    padding: 11px 14px;
    border-bottom: 1px solid #e3f2fd;
    vertical-align: middle;
    color: #455a64;
}
.att-table tbody tr:last-child td { border-bottom: none; }

/* ── Status radio buttons ── */
.status-group { display: flex; gap: 6px; }
.status-radio { display: none; }
.status-label {
    padding: 5px 14px;
    border-radius: 20px;
    font-size: 11px;
    font-weight: 700;
    cursor: pointer;
    border: 1.5px solid transparent;
    transition: .15s;
    user-select: none;
}
.status-label.present { background: var(--green-light); color: var(--green); border-color: #a5d6a7; }
.status-label.absent  { background: var(--red-light);   color: var(--red);   border-color: #ef9a9a; }
.status-label.leave   { background: var(--amber-light); color: var(--amber); border-color: #ffcc80; }
.status-radio:checked + .status-label.present { background: var(--green); color: #fff; }
.status-radio:checked + .status-label.absent  { background: var(--red);   color: #fff; }
.status-radio:checked + .status-label.leave   { background: var(--amber); color: #fff; }

/* ── Badges ── */
.att-badge { display: inline-block; padding: 3px 12px; border-radius: 12px; font-size: 11px; font-weight: 700; }
.att-badge-present { background: var(--green-light); color: var(--green); }
.att-badge-absent  { background: var(--red-light);   color: var(--red); }
.att-badge-leave   { background: var(--amber-light);  color: var(--amber); }

/* ── Stat cards ── */
.att-stats-row { display: flex; gap: 14px; flex-wrap: wrap; margin-bottom: 18px; }
.att-stat-card {
    flex: 1;
    min-width: 110px;
    background: #fff;
    border-radius: 12px;
    padding: 16px 18px;
    box-shadow: var(--card-shadow);
    text-align: center;
    border-top: 4px solid var(--blue-light);
}
.att-stat-card.green-top { border-color: var(--green); }
.att-stat-card.red-top   { border-color: var(--red); }
.att-stat-num { font-size: 28px; font-weight: 800; color: var(--blue-dark); }
.att-stat-num.green { color: var(--green); }
.att-stat-num.red   { color: var(--red); }
.att-stat-lbl { font-size: 11px; font-weight: 700; color: #90a4ae; text-transform: uppercase; letter-spacing: .5px; margin-top: 3px; }

/* ── Mark all row ── */
.mark-all-row {
    display: flex;
    gap: 10px;
    align-items: center;
    margin-bottom: 14px;
    padding: 10px 14px;
    background: var(--blue-pale);
    border-radius: 10px;
    font-size: 13px;
    font-weight: 700;
    color: var(--blue-dark);
    flex-wrap: wrap;
}

/* ── Progress bar ── */
.att-progress-wrap { background: #e0e0e0; border-radius: 10px; height: 8px; overflow: hidden; }
.att-progress-bar  { height: 100%; border-radius: 10px; background: var(--green); transition: width .4s; }
.att-progress-bar.warn { background: var(--amber); }
.att-progress-bar.low  { background: var(--red); }

/* ── Tab panels ── */
.att-panel { display: none; }
.att-panel.active { display: block; }

@media(max-width:600px) {
    .att-filter-row { flex-direction: column; }
    .att-filter-group { min-width: 100%; }
    .att-stats-row { flex-direction: column; }
}
/* ── Analytics ── */
.ana-kpi-row { display:flex; gap:12px; flex-wrap:wrap; margin-bottom:20px; }
.ana-kpi-card {
    flex:1; min-width:140px;
    background:#fff; border-radius:14px; padding:16px 18px;
    box-shadow:var(--card-shadow);
    display:flex; align-items:center; gap:14px;
}
.ana-kpi-icon {
    width:44px; height:44px; border-radius:12px;
    display:flex; align-items:center; justify-content:center;
    font-size:18px; flex-shrink:0;
}
.ana-kpi-val  { font-size:26px; font-weight:800; color:var(--blue-dark); line-height:1; }
.ana-kpi-lbl  { font-size:11px; font-weight:700; color:#90a4ae; text-transform:uppercase; letter-spacing:.5px; margin-top:4px; }
.ana-chart-row { display:flex; gap:16px; margin-bottom:20px; flex-wrap:wrap; }
.ana-chart-card { flex:1; min-width:280px; margin-bottom:0 !important; }
.ana-legend { display:flex; flex-wrap:wrap; gap:14px; margin-bottom:10px; font-size:12px; color:#607d8b; }
.ana-legend span { display:flex; align-items:center; gap:5px; }
.ana-legend-dot { width:10px; height:10px; border-radius:2px; flex-shrink:0; }
@media(max-width:640px) {
    .ana-kpi-row,.ana-chart-row { flex-direction:column; }
    .ana-chart-card { min-width:100%; }
}
</style>
</asp:Content>

<asp:Content ID="bodyContent" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

<%-- ══ PAGE BANNER ══ --%>
<div class="page-banner">
    <h4><i class="fas fa-clipboard-check me-2"></i>Attendance Management</h4>
    <p>Mark, review, and report student attendance across your subjects.</p>
</div>

<%-- ══ TABS ══ --%>
<div class="att-tabs">
    <button class="att-tab-btn active" onclick="switchTab('mark',this)">
        <i class="fas fa-pen me-1"></i> Mark Attendance
    </button>
    <button class="att-tab-btn" onclick="switchTab('report',this)">
        <i class="fas fa-chart-bar me-1"></i> Attendance Report
    </button>
    <button class="att-tab-btn" onclick="switchTab('daywise',this)">
        <i class="fas fa-calendar-day me-1"></i> Day-wise Summary
    </button>
    <button class="att-tab-btn" onclick="switchTab('analytics',this)">
    <i class="fas fa-chart-pie me-1"></i> Analytics
</button>
</div>

<!-- ===== TAB 1: MARK ATTENDANCE ===== -->
<div id="tab-mark" class="att-panel active">
    <div class="att-card">
        <div class="att-card-title">
            <i class="fas fa-sliders-h"></i> Select Subject &amp; Date
        </div>
        <div class="att-filter-row">
            <div class="att-filter-group">
                <label>Subject</label>
                <asp:DropDownList ID="ddlSubject" runat="server">
                    <asp:ListItem Value="">-- Select Subject --</asp:ListItem>
                </asp:DropDownList>
            </div>
            <div class="att-filter-group">
                <label>Date</label>
                <asp:TextBox ID="txtDate" runat="server" TextMode="Date" />
            </div>
            <div style="display:flex;align-items:flex-end;">
                <asp:Button ID="btnLoadStudents" runat="server" Text="Load Students"
                    CssClass="att-btn att-btn-primary"
                    OnClick="btnLoadStudents_Click" />
            </div>
        </div>
    </div>

    <asp:Panel ID="pnlAlert" runat="server" Visible="false">
        <div class="att-alert att-alert-info" id="markAlert" runat="server">
            <i class="fas fa-info-circle"></i>
            <asp:Label ID="lblAlert" runat="server" />
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlAttendanceGrid" runat="server" Visible="false">
        <div class="att-card">
            <div class="att-card-title">
                <i class="fas fa-users"></i>
                <asp:Label ID="lblGridTitle" runat="server" Text="Students" />
                <span style="margin-left:auto;font-size:12px;font-weight:600;color:#90a4ae;">
                    Date: <asp:Label ID="lblSelectedDate" runat="server" />
                </span>
            </div>
            <div class="mark-all-row">
                <span>Mark All:</span>
                <button type="button" class="att-btn att-btn-success"
                    style="padding:5px 14px;font-size:12px;"
                    onclick="markAll('Present')">
                    <i class="fas fa-check"></i> Present
                </button>
                <button type="button" class="att-btn"
                    style="padding:5px 14px;font-size:12px;background:var(--red);color:#fff;"
                    onclick="markAll('Absent')">
                    <i class="fas fa-times"></i> Absent
                </button>
                <button type="button" class="att-btn"
                    style="padding:5px 14px;font-size:12px;background:var(--amber);color:#fff;"
                    onclick="markAll('Leave')">
                    <i class="fas fa-umbrella-beach"></i> Leave
                </button>
            </div>
            <div class="att-table-wrap">
                <table class="att-table">
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>Roll No</th>
                            <th>Student Name</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <asp:Repeater ID="rptStudents" runat="server">
                            <ItemTemplate>
                                <tr>
                                    <td style="color:#b0bec5;font-size:12px;"><%# Container.ItemIndex + 1 %></td>
                                    <td>
                                        <span style="background:#e3f2fd;color:#1565c0;padding:2px 10px;border-radius:8px;font-size:12px;font-weight:700;">
                                            <%# Eval("RollNumber") %>
                                        </span>
                                    </td>
                                    <td style="font-weight:600;color:#263238;"><%# Eval("FullName") %></td>
                                    <td>
                                        <div class="status-group" data-userid="<%# Eval("UserId") %>">
                                            <input type="radio" class="status-radio"
                                                name="status_<%# Eval("UserId") %>"
                                                id="p_<%# Eval("UserId") %>"
                                                value="Present"
                                                <%# Eval("Status").ToString()=="Present"?"checked":"" %> />
                                            <label for="p_<%# Eval("UserId") %>" class="status-label present">
                                                <i class="fas fa-check"></i> Present
                                            </label>
                                            <input type="radio" class="status-radio"
                                                name="status_<%# Eval("UserId") %>"
                                                id="a_<%# Eval("UserId") %>"
                                                value="Absent"
                                                <%# Eval("Status").ToString()=="Absent"?"checked":"" %> />
                                            <label for="a_<%# Eval("UserId") %>" class="status-label absent">
                                                <i class="fas fa-times"></i> Absent
                                            </label>
                                            <input type="radio" class="status-radio"
                                                name="status_<%# Eval("UserId") %>"
                                                id="l_<%# Eval("UserId") %>"
                                                value="Leave"
                                                <%# Eval("Status").ToString()=="Leave"?"checked":"" %> />
                                            <label for="l_<%# Eval("UserId") %>" class="status-label leave">
                                                <i class="fas fa-umbrella-beach"></i> Leave
                                            </label>
                                        </div>
                                    </td>
                                </tr>
                            </ItemTemplate>
                        </asp:Repeater>
                    </tbody>
                </table>
            </div>
            <asp:HiddenField ID="hfAttendanceData" runat="server" />
            <div style="margin-top:18px;display:flex;gap:10px;justify-content:flex-end;">
                <asp:Button ID="btnSaveAttendance" runat="server" Text="💾 Save Attendance"
                    CssClass="att-btn att-btn-success"
                    OnClick="btnSaveAttendance_Click"
                    OnClientClick="collectAttendance(); return true;" />
            </div>
        </div>
    </asp:Panel>
</div>

<!-- ===== TAB 2: REPORT ===== -->
<div id="tab-report" class="att-panel">
    <div class="att-card">
        <div class="att-card-title"><i class="fas fa-filter"></i> Filter</div>
        <div class="att-filter-row">
            <div class="att-filter-group">
                <label>Subject</label>
                <asp:DropDownList ID="ddlReportSubject" runat="server">
                    <asp:ListItem Value="">-- Select Subject --</asp:ListItem>
                </asp:DropDownList>
            </div>
            <div class="att-filter-group">
                <label>From Date</label>
                <asp:TextBox ID="txtReportFrom" runat="server" TextMode="Date" />
            </div>
            <div class="att-filter-group">
                <label>To Date</label>
                <asp:TextBox ID="txtReportTo" runat="server" TextMode="Date" />
            </div>
            <div style="display:flex;align-items:flex-end;">
                <asp:Button ID="btnLoadReport" runat="server" Text="Generate Report"
                    CssClass="att-btn att-btn-primary"
                    OnClick="btnLoadReport_Click" />
            </div>
        </div>
    </div>

    <asp:Panel ID="pnlReportStats" runat="server" Visible="false">
        <div class="att-stats-row">
            <div class="att-stat-card">
                <div class="att-stat-num">
                    <asp:Label ID="lblTotalStudents" runat="server" Text="0" />
                </div>
                <div class="att-stat-lbl">Students</div>
            </div>
            <div class="att-stat-card green-top">
                <div class="att-stat-num green">
                    <asp:Label ID="lblAvgPresent" runat="server" Text="0" />
                </div>
                <div class="att-stat-lbl">Avg Present %</div>
            </div>
            <div class="att-stat-card red-top">
                <div class="att-stat-num red">
                    <asp:Label ID="lblLowAttendance" runat="server" Text="0" />
                </div>
                <div class="att-stat-lbl">Below 75%</div>
            </div>
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlReport" runat="server" Visible="false">
        <div class="att-card">
            <div class="att-card-title">
                <i class="fas fa-table"></i> Student-wise Attendance Report
            </div>
            <div class="att-table-wrap">
                <table class="att-table">
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>Roll No</th>
                            <th>Student Name</th>
                            <th>Total</th>
                            <th>Present</th>
                            <th>Absent</th>
                            <th>Leave</th>
                            <th>Percentage</th>
                        </tr>
                    </thead>
                    <tbody>
                        <asp:Repeater ID="rptReport" runat="server">
                            <ItemTemplate>
                                <tr>
                                    <td style="color:#b0bec5;font-size:12px;"><%# Container.ItemIndex + 1 %></td>
                                    <td>
                                        <span style="background:#e3f2fd;color:#1565c0;padding:2px 10px;border-radius:8px;font-size:12px;font-weight:700;">
                                            <%# Eval("RollNumber") %>
                                        </span>
                                    </td>
                                    <td style="font-weight:600;color:#263238;"><%# Eval("FullName") %></td>
                                    <td style="font-weight:600;"><%# Eval("TotalClasses") %></td>
                                    <td><span class="att-badge att-badge-present"><%# Eval("PresentCount") %></span></td>
                                    <td><span class="att-badge att-badge-absent"><%# Eval("AbsentCount") %></span></td>
                                    <td><span class="att-badge att-badge-leave"><%# Eval("LeaveCount") %></span></td>
                                    <td>
                                        <div style="display:flex;align-items:center;gap:8px;">
                                            <div class="att-progress-wrap" style="width:80px;">
                                                <div class="att-progress-bar <%# Convert.ToDouble(Eval("Percentage")) >= 75 ? "" : Convert.ToDouble(Eval("Percentage")) >= 50 ? "warn" : "low" %>"
                                                     style="width:<%# Eval("Percentage") %>%"></div>
                                            </div>
                                            <span style="font-weight:700;font-size:13px;color:<%# Convert.ToDouble(Eval("Percentage")) >= 75 ? "#2e7d32" : Convert.ToDouble(Eval("Percentage")) >= 50 ? "#f57c00" : "#c62828" %>">
                                                <%# Eval("Percentage") %>%
                                            </span>
                                        </div>
                                    </td>
                                </tr>
                            </ItemTemplate>
                        </asp:Repeater>
                    </tbody>
                </table>
            </div>
        </div>
    </asp:Panel>
</div>

<!-- ===== TAB 3: DAY-WISE ===== -->
<div id="tab-daywise" class="att-panel">
    <div class="att-card">
        <div class="att-card-title"><i class="fas fa-filter"></i> Filter</div>
        <div class="att-filter-row">
            <div class="att-filter-group">
                <label>Subject</label>
                <asp:DropDownList ID="ddlDaySubject" runat="server">
                    <asp:ListItem Value="">-- Select Subject --</asp:ListItem>
                </asp:DropDownList>
            </div>
            <div class="att-filter-group">
                <label>From Date</label>
                <asp:TextBox ID="txtDayFrom" runat="server" TextMode="Date" />
            </div>
            <div class="att-filter-group">
                <label>To Date</label>
                <asp:TextBox ID="txtDayTo" runat="server" TextMode="Date" />
            </div>
            <div style="display:flex;align-items:flex-end;">
                <asp:Button ID="btnLoadDaywise" runat="server" Text="View Summary"
                    CssClass="att-btn att-btn-primary"
                    OnClick="btnLoadDaywise_Click" />
            </div>
        </div>
    </div>

    <asp:Panel ID="pnlDaywise" runat="server" Visible="false">
        <div class="att-card">
            <div class="att-card-title">
                <i class="fas fa-calendar-alt"></i> Day-wise Attendance Summary
            </div>
            <div class="att-table-wrap">
                <table class="att-table">
                    <thead>
                        <tr>
                            <th>Date</th>
                            <th>Total Students</th>
                            <th>Present</th>
                            <th>Absent</th>
                            <th>Leave</th>
                        </tr>
                    </thead>
                    <tbody>
                        <asp:Repeater ID="rptDaywise" runat="server">
                            <ItemTemplate>
                                <tr>
                                    <td style="font-weight:600;color:#263238;">
                                        <i class="fas fa-calendar-day me-2" style="color:#42a5f5;"></i>
                                        <%# Convert.ToDateTime(Eval("Date")).ToString("dd MMM yyyy") %>
                                    </td>
                                    <td style="font-weight:600;"><%# Eval("TotalStudents") %></td>
                                    <td><span class="att-badge att-badge-present"><%# Eval("PresentCount") %></span></td>
                                    <td><span class="att-badge att-badge-absent"><%# Eval("AbsentCount") %></span></td>
                                    <td><span class="att-badge att-badge-leave"><%# Eval("LeaveCount") %></span></td>
                                </tr>
                            </ItemTemplate>
                        </asp:Repeater>
                    </tbody>
                </table>
            </div>
        </div>
    </asp:Panel>
</div>

<!-- ===== TAB 4: ANALYTICS (No Filters) ===== -->
<!-- ===== TAB 4: ANALYTICS (No Filters) ===== -->
<div id="tab-analytics" class="att-panel">
    
    <!-- Refresh Button Row -->
    <div style="margin-bottom: 16px; text-align: right;">
        <asp:Button ID="btnRefreshAnalytics" runat="server" Text="⟳ Refresh Analytics" 
            CssClass="att-btn att-btn-primary" OnClick="btnRefreshAnalytics_Click" />
    </div>

    <asp:Panel ID="pnlAnalytics" runat="server" Visible="false">
        <!-- KPI Row -->
        <div class="ana-kpi-row">
            <div class="ana-kpi-card">
                <div class="ana-kpi-icon" style="background:#e3f2fd;color:#1565c0;"><i class="fas fa-percent"></i></div>
                <div>
                    <div class="ana-kpi-val"><asp:Label ID="lblAnaAvgPct" runat="server" Text="0" />%</div>
                    <div class="ana-kpi-lbl">Avg Attendance (Current Month)</div>
                </div>
            </div>
            <div class="ana-kpi-card">
                <div class="ana-kpi-icon" style="background:#e8f5e9;color:#2e7d32;"><i class="fas fa-user-check"></i></div>
                <div>
                    <div class="ana-kpi-val" style="color:#2e7d32;"><asp:Label ID="lblAnaTotalPresent" runat="server" Text="0" /></div>
                    <div class="ana-kpi-lbl">Total Present</div>
                </div>
            </div>
            <div class="ana-kpi-card">
                <div class="ana-kpi-icon" style="background:#ffebee;color:#c62828;"><i class="fas fa-user-times"></i></div>
                <div>
                    <div class="ana-kpi-val" style="color:#c62828;"><asp:Label ID="lblAnaTotalAbsent" runat="server" Text="0" /></div>
                    <div class="ana-kpi-lbl">Total Absent</div>
                </div>
            </div>
            <div class="ana-kpi-card">
                <div class="ana-kpi-icon" style="background:#fff3e0;color:#f57c00;"><i class="fas fa-umbrella-beach"></i></div>
                <div>
                    <div class="ana-kpi-val" style="color:#f57c00;"><asp:Label ID="lblAnaTotalLeave" runat="server" Text="0" /></div>
                    <div class="ana-kpi-lbl">Total Leave</div>
                </div>
            </div>
            <div class="ana-kpi-card">
                <div class="ana-kpi-icon" style="background:#fce4ec;color:#880e4f;"><i class="fas fa-exclamation-triangle"></i></div>
                <div>
                    <div class="ana-kpi-val" style="color:#880e4f;"><asp:Label ID="lblAnaLowCount" runat="server" Text="0" /></div>
                    <div class="ana-kpi-lbl">Below 75%</div>
                </div>
            </div>
            <div class="ana-kpi-card">
                <div class="ana-kpi-icon" style="background:#e8eaf6;color:#3949ab;"><i class="fas fa-calendar-check"></i></div>
                <div>
                    <div class="ana-kpi-val" style="color:#3949ab;"><asp:Label ID="lblAnaTotalDays" runat="server" Text="0" /></div>
                    <div class="ana-kpi-lbl">Total Class Days</div>
                </div>
            </div>
        </div>

        <!-- Row 1: Pie + Subject Donut -->
        <div class="ana-chart-row">
            <div class="att-card ana-chart-card">
                <div class="att-card-title"><i class="fas fa-chart-pie"></i> Overall Status Split (Current Month)</div>
                <div class="ana-legend" id="pieLegend"></div>
                <div style="position:relative;height:260px;">
                    <canvas id="pieChart" role="img" aria-label="Pie chart of present, absent, leave totals"></canvas>
                </div>
            </div>
            <div class="att-card ana-chart-card">
                <div class="att-card-title"><i class="fas fa-circle-notch"></i> Subject-wise Avg Attendance %</div>
                <div class="ana-legend" id="subjectLegend"></div>
                <div style="position:relative;height:260px;">
                    <canvas id="subjectDonut" role="img" aria-label="Donut chart of average attendance per subject"></canvas>
                </div>
            </div>
        </div>

        <!-- Row 2: Monthly Trend -->
        <div class="att-card" style="margin-bottom:20px;">
            <div class="att-card-title"><i class="fas fa-chart-line"></i> Monthly Attendance Trend (Last 6 Months)</div>
            <div class="ana-legend" id="trendLegend"></div>
            <div style="position:relative;height:280px;">
                <canvas id="trendChart" role="img" aria-label="Monthly line chart for present, absent, leave counts"></canvas>
            </div>
        </div>

        <!-- Row 3: Day-of-Week + Distribution -->
        <div class="ana-chart-row">
            <div class="att-card ana-chart-card">
                <div class="att-card-title"><i class="fas fa-calendar-alt"></i> Day-of-Week Attendance Pattern</div>
                <div style="position:relative;height:230px;">
                    <canvas id="dowChart" role="img" aria-label="Bar chart of average attendance by day of week"></canvas>
                </div>
            </div>
            <div class="att-card ana-chart-card">
                <div class="att-card-title"><i class="fas fa-signal"></i> Student Attendance Distribution</div>
                <div style="position:relative;height:230px;">
                    <canvas id="distChart" role="img" aria-label="Histogram of how many students fall in each attendance % band"></canvas>
                </div>
            </div>
        </div>

        <!-- Row 4: Subject Grouped Bar -->
        <div class="att-card" style="margin-bottom:20px;">
            <div class="att-card-title"><i class="fas fa-chart-bar"></i> Subject-wise Present / Absent / Leave</div>
            <div class="ana-legend" id="subBarLegend"></div>
            <div id="subBarWrap" style="position:relative;height:280px;">
                <canvas id="subBarChart" role="img" aria-label="Grouped bar chart comparing present, absent, leave per subject"></canvas>
            </div>
        </div>

        <!-- Row 5: Daily Attendance Calendar View -->
        <div class="att-card" style="margin-bottom:20px;">
            <div class="att-card-title"><i class="fas fa-calendar-day"></i> Daily Attendance (Current Month)</div>
            <div style="overflow-x:auto;">
                <asp:Repeater ID="rptDailyAttendance" runat="server">
                    <HeaderTemplate>
                        <table class="att-table">
                            <thead>
                                <tr>
                                    <th>Date</th>
                                    <th>Day</th>
                                    <th>Total Students</th>
                                    <th>Present</th>
                                    <th>Absent</th>
                                    <th>Leave</th>
                                    <th>Attendance %</th>
                                </tr>
                            </thead>
                            <tbody>
                    </HeaderTemplate>
                    <ItemTemplate>
                        <tr>
                            <td><%# Convert.ToDateTime(Eval("Date")).ToString("dd MMM yyyy") %></td>
                            <td><%# Convert.ToDateTime(Eval("Date")).ToString("dddd") %></td>
                            <td><%# Eval("TotalStudents") %></td>
                            <td><span class="att-badge att-badge-present"><%# Eval("PresentCount") %></span></td>
                            <td><span class="att-badge att-badge-absent"><%# Eval("AbsentCount") %></span></td>
                            <td><span class="att-badge att-badge-leave"><%# Eval("LeaveCount") %></span></td>
                            <td>
                                <div style="display:flex;align-items:center;gap:8px;">
                                    <div class="att-progress-wrap" style="width:80px;">
                                        <div class="att-progress-bar" style="width:<%# GetPercentage(Eval("PresentCount"), Eval("TotalStudents")) %>%"></div>
                                    </div>
                                    <span style="font-weight:700;"><%# GetPercentage(Eval("PresentCount"), Eval("TotalStudents")) %>%</span>
                                </div>
                            </td>
                        </tr>
                    </ItemTemplate>
                    <FooterTemplate>
                            </tbody>
                        </table>
                    </FooterTemplate>
                </asp:Repeater>
            </div>
        </div>

        <!-- Row 6: Top Absentees + Leaderboard -->
        <div class="ana-chart-row">
            <div class="att-card ana-chart-card">
                <div class="att-card-title"><i class="fas fa-user-slash"></i> Top 10 Absentees (Current Month)</div>
                <div id="absenteeBarWrap" style="position:relative;height:320px;">
                    <canvas id="absenteeChart" role="img" aria-label="Horizontal bar of students with most absences"></canvas>
                </div>
            </div>
            <div class="att-card ana-chart-card">
                <div class="att-card-title"><i class="fas fa-trophy"></i> Attendance Leaderboard (Top 10)</div>
                <div id="topStudentsWrap" style="position:relative;height:320px;">
                    <canvas id="topStudentChart" role="img" aria-label="Horizontal bar of students with highest attendance percentage"></canvas>
                </div>
            </div>
        </div>

        <!-- Row 7: Risk Stacked + Cumulative -->
        <div class="ana-chart-row">
            <div class="att-card ana-chart-card">
                <div class="att-card-title"><i class="fas fa-layer-group"></i> Risk Category per Subject</div>
                <div class="ana-legend" id="riskLegend"></div>
                <div style="position:relative;height:240px;">
                    <canvas id="riskChart" role="img" aria-label="Stacked bar grouping students by attendance risk per subject"></canvas>
                </div>
            </div>
            <div class="att-card ana-chart-card">
                <div class="att-card-title"><i class="fas fa-chart-area"></i> Cumulative Present Days Over Time</div>
                <div style="position:relative;height:240px;">
                    <canvas id="cumulChart" role="img" aria-label="Cumulative present count over the selected date range"></canvas>
                </div>
            </div>
        </div>

        <!-- hidden JSON data islands -->
        <asp:HiddenField ID="hfPieData" runat="server" />
        <asp:HiddenField ID="hfSubjectData" runat="server" />
        <asp:HiddenField ID="hfMonthlyData" runat="server" />
        <asp:HiddenField ID="hfDowData" runat="server" />
        <asp:HiddenField ID="hfDistData" runat="server" />
        <asp:HiddenField ID="hfSubBarData" runat="server" />
        <asp:HiddenField ID="hfAbsenteeData" runat="server" />
        <asp:HiddenField ID="hfTopStudentData" runat="server" />
        <asp:HiddenField ID="hfRiskData" runat="server" />
        <asp:HiddenField ID="hfCumulData" runat="server" />
    </asp:Panel>
</div>
<asp:HiddenField ID="hfActiveTab" runat="server" Value="mark" />

<script>
    window.onload = function () {
        var activeTab = document.getElementById('<%= hfActiveTab.ClientID %>').value || 'mark';
        var allPanels = document.querySelectorAll('.att-panel');
        var allBtns   = document.querySelectorAll('.att-tab-btn');

        allPanels.forEach(function (p) { p.classList.remove('active'); });
        allBtns.forEach(function (b)   { b.classList.remove('active'); });

        var panel = document.getElementById('tab-' + activeTab);
        if (panel) panel.classList.add('active');

        allBtns.forEach(function (b) {
            if (b.getAttribute('onclick') &&
                b.getAttribute('onclick').indexOf("'" + activeTab + "'") !== -1) {
                b.classList.add('active');
            }
        });
    };

    function switchTab(tab, el) {
        document.querySelectorAll('.att-panel').forEach(function (p) { p.classList.remove('active'); });
        document.querySelectorAll('.att-tab-btn').forEach(function (b) { b.classList.remove('active'); });
        document.getElementById('tab-' + tab).classList.add('active');
        el.classList.add('active');
        document.getElementById('<%= hfActiveTab.ClientID %>').value = tab;
    }

    function markAll(status) {
        document.querySelectorAll('.status-group').forEach(function (grp) {
            var uid   = grp.dataset.userid;
            var radio = document.querySelector('input[name="status_' + uid + '"][value="' + status + '"]');
            if (radio) radio.checked = true;
        });
    }

    function collectAttendance() {
        var data = [];
        document.querySelectorAll('.status-group').forEach(function (grp) {
            var uid     = grp.dataset.userid;
            var checked = document.querySelector('input[name="status_' + uid + '"]:checked');
            if (checked) data.push(uid + ':' + checked.value);
        });
        document.getElementById('<%= hfAttendanceData.ClientID %>').value = data.join(',');
    }
</script>
  <%--  <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.4.1/chart.umd.js"></script>
<script>
    (function () {
        var C = {
            present: '#2e7d32', presentL: 'rgba(46,125,50,.12)',
            absent: '#c62828', absentL: 'rgba(198,40,40,.12)',
            leave: '#f57c00', leaveL: 'rgba(245,124,0,.12)',
            blue: '#1565c0', blueL: 'rgba(21,101,192,.12)',
            teal: '#00695c', amber: '#f9a825',
            risk: ['#2e7d32', '#1565c0', '#f57c00', '#c62828']
        };
        var subjColors = ['#1565c0', '#6a1b9a', '#00695c', '#e65100', '#37474f', '#880e4f', '#1b5e20', '#0d47a1'];

        function makeLegend(id, items) {
            var el = document.getElementById(id); if (!el) return;
            el.innerHTML = items.map(function (i) {
                return '<span><span class="ana-legend-dot" style="background:' + i.c + '"></span>' + i.l + '</span>';
            }).join('');
        }
        function safe(id) {
            var el = document.getElementById(id); if (!el || !el.value) return null;
            try { return JSON.parse(el.value); } catch (e) { return null; }
        }
        Chart.defaults.font.family = "'Segoe UI',sans-serif";
        Chart.defaults.font.size = 12;
        Chart.defaults.color = '#607d8b';
        function grid() { return { color: 'rgba(0,0,0,.06)', drawBorder: false }; }
        function tip() { return { backgroundColor: '#263238', titleColor: '#fff', bodyColor: '#cfd8dc', padding: 10, cornerRadius: 8 }; }

        window.addEventListener('load', function () {
            var pie = safe('<%= hfPieData.ClientID %>');
        var subj = safe('<%= hfSubjectData.ClientID %>');
        var monthly = safe('<%= hfMonthlyData.ClientID %>');
        var dow = safe('<%= hfDowData.ClientID %>');
        var dist = safe('<%= hfDistData.ClientID %>');
        var subBar  =safe('<%= hfSubBarData.ClientID %>');
        var absen   =safe('<%= hfAbsenteeData.ClientID %>');
        var topS    =safe('<%= hfTopStudentData.ClientID %>');
        var risk    =safe('<%= hfRiskData.ClientID %>');
        var cumul   =safe('<%= hfCumulData.ClientID %>');

        /* 1. Pie */
        if (pie) {
            makeLegend('pieLegend', [
                { c: C.present, l: 'Present ' + pie.present },
                { c: C.absent, l: 'Absent ' + pie.absent },
                { c: C.leave, l: 'Leave ' + pie.leave }
            ]);
            new Chart(document.getElementById('pieChart'), {
                type: 'pie',
                data: {
                    labels: ['Present', 'Absent', 'Leave'],
                    datasets: [{
                        data: [pie.present, pie.absent, pie.leave],
                        backgroundColor: [C.present, C.absent, C.leave],
                        borderWidth: 2, borderColor: '#fff'
                    }]
                },
                options: {
                    responsive: true, maintainAspectRatio: false,
                    plugins: { legend: { display: false }, tooltip: tip() }
                }
            });
        }

        /* 2. Subject Donut */
        if (subj && subj.labels) {
            makeLegend('subjectLegend', subj.labels.map(function (l, i) {
                return { c: subjColors[i % subjColors.length], l: l + ' ' + subj.values[i] + '%' };
            }));
            new Chart(document.getElementById('subjectDonut'), {
                type: 'doughnut',
                data: {
                    labels: subj.labels,
                    datasets: [{
                        data: subj.values,
                        backgroundColor: subj.labels.map(function (_, i) { return subjColors[i % subjColors.length]; }),
                        borderWidth: 2, borderColor: '#fff'
                    }]
                },
                options: {
                    responsive: true, maintainAspectRatio: false, cutout: '62%',
                    plugins: { legend: { display: false }, tooltip: tip() }
                }
            });
        }

        /* 3. Monthly Trend */
        if (monthly && monthly.labels) {
            makeLegend('trendLegend', [
                { c: C.present, l: 'Present' }, { c: C.absent, l: 'Absent' }, { c: C.leave, l: 'Leave' }
            ]);
            new Chart(document.getElementById('trendChart'), {
                type: 'line',
                data: {
                    labels: monthly.labels, datasets: [
                        { label: 'Present', data: monthly.present, borderColor: C.present, backgroundColor: C.presentL, fill: true, tension: .4, pointRadius: 4, borderDash: [] },
                        { label: 'Absent', data: monthly.absent, borderColor: C.absent, backgroundColor: C.absentL, fill: true, tension: .4, pointRadius: 4, borderDash: [5, 3] },
                        { label: 'Leave', data: monthly.leave, borderColor: C.leave, backgroundColor: C.leaveL, fill: true, tension: .4, pointRadius: 4, borderDash: [2, 2] }
                    ]
                },
                options: {
                    responsive: true, maintainAspectRatio: false,
                    interaction: { mode: 'index', intersect: false },
                    plugins: { legend: { display: false }, tooltip: tip() },
                    scales: { x: { grid: grid() }, y: { grid: grid(), beginAtZero: true } }
                }
            });
        }

        /* 4. Day-of-Week */
        if (dow && dow.labels) {
            new Chart(document.getElementById('dowChart'), {
                type: 'bar',
                data: {
                    labels: dow.labels, datasets: [{
                        label: 'Avg Present %', data: dow.values, borderRadius: 6,
                        backgroundColor: dow.values.map(function (v) { return v >= 75 ? C.present : v >= 50 ? C.leave : C.absent; })
                    }]
                },
                options: {
                    responsive: true, maintainAspectRatio: false,
                    plugins: { legend: { display: false }, tooltip: tip() },
                    scales: {
                        x: { grid: { display: false }, ticks: { autoSkip: false } },
                        y: {
                            grid: grid(), beginAtZero: true, max: 100,
                            ticks: { callback: function (v) { return v + '%'; } }
                        }
                    }
                }
            });
        }

        /* 5. Distribution Histogram */
        if (dist && dist.labels) {
            new Chart(document.getElementById('distChart'), {
                type: 'bar',
                data: {
                    labels: dist.labels, datasets: [{
                        label: 'Students', data: dist.values, borderRadius: 6,
                        backgroundColor: dist.labels.map(function (l) {
                            var v = parseInt(l); return v >= 75 ? C.present : v >= 50 ? C.leave : C.absent;
                        })
                    }]
                },
                options: {
                    responsive: true, maintainAspectRatio: false,
                    plugins: { legend: { display: false }, tooltip: tip() },
                    scales: {
                        x: { grid: { display: false }, ticks: { autoSkip: false, maxRotation: 30 } },
                        y: { grid: grid(), beginAtZero: true, ticks: { precision: 0 } }
                    }
                }
            });
        }

        /* 6. Subject Grouped Bar */
        if (subBar && subBar.labels) {
            makeLegend('subBarLegend', [
                { c: C.present, l: 'Present' }, { c: C.absent, l: 'Absent' }, { c: C.leave, l: 'Leave' }
            ]);
            new Chart(document.getElementById('subBarChart'), {
                type: 'bar',
                data: {
                    labels: subBar.labels, datasets: [
                        { label: 'Present', data: subBar.present, backgroundColor: C.present, borderRadius: 4 },
                        { label: 'Absent', data: subBar.absent, backgroundColor: C.absent, borderRadius: 4 },
                        { label: 'Leave', data: subBar.leave, backgroundColor: C.leave, borderRadius: 4 }
                    ]
                },
                options: {
                    responsive: true, maintainAspectRatio: false,
                    plugins: { legend: { display: false }, tooltip: tip() },
                    scales: {
                        x: { grid: { display: false }, ticks: { autoSkip: false } },
                        y: { grid: grid(), beginAtZero: true }
                    }
                }
            });
        }

        /* 7. Top Absentees */
        if (absen && absen.labels) {
            document.getElementById('absenteeBarWrap').style.height = Math.max(260, absen.labels.length * 36 + 60) + 'px';
            new Chart(document.getElementById('absenteeChart'), {
                type: 'bar', indexAxis: 'y',
                data: {
                    labels: absen.labels, datasets: [{
                        label: 'Absences', data: absen.values, backgroundColor: C.absent, borderRadius: 4
                    }]
                },
                options: {
                    responsive: true, maintainAspectRatio: false,
                    plugins: { legend: { display: false }, tooltip: tip() },
                    scales: {
                        x: { grid: grid(), beginAtZero: true, ticks: { precision: 0 } },
                        y: { grid: { display: false } }
                    }
                }
            });
        }

        /* 8. Leaderboard */
        if (topS && topS.labels) {
            document.getElementById('topStudentsWrap').style.height = Math.max(260, topS.labels.length * 36 + 60) + 'px';
            new Chart(document.getElementById('topStudentChart'), {
                type: 'bar', indexAxis: 'y',
                data: {
                    labels: topS.labels, datasets: [{
                        label: 'Attendance %', data: topS.values, borderRadius: 4,
                        backgroundColor: topS.values.map(function (v) { return v >= 90 ? C.teal : v >= 75 ? C.present : C.amber; })
                    }]
                },
                options: {
                    responsive: true, maintainAspectRatio: false,
                    plugins: { legend: { display: false }, tooltip: tip() },
                    scales: {
                        x: {
                            grid: grid(), beginAtZero: true, max: 100,
                            ticks: { callback: function (v) { return v + '%'; } }
                        },
                        y: { grid: { display: false } }
                    }
                }
            });
        }

        /* 9. Risk Stacked */
        if (risk && risk.labels) {
            makeLegend('riskLegend', [
                { c: C.risk[0], l: 'Safe ≥90%' }, { c: C.risk[1], l: 'Good 75–89%' },
                { c: C.risk[2], l: 'Warning 50–74%' }, { c: C.risk[3], l: 'Danger <50%' }
            ]);
            new Chart(document.getElementById('riskChart'), {
                type: 'bar',
                data: {
                    labels: risk.labels, datasets: [
                        { label: 'Safe ≥90%', data: risk.safe, backgroundColor: C.risk[0], borderRadius: 4 },
                        { label: 'Good 75–89%', data: risk.good, backgroundColor: C.risk[1], borderRadius: 4 },
                        { label: 'Warning 50–74%', data: risk.warning, backgroundColor: C.risk[2], borderRadius: 4 },
                        { label: 'Danger <50%', data: risk.danger, backgroundColor: C.risk[3], borderRadius: 4 }
                    ]
                },
                options: {
                    responsive: true, maintainAspectRatio: false,
                    plugins: { legend: { display: false }, tooltip: tip() },
                    scales: {
                        x: { stacked: true, grid: { display: false }, ticks: { autoSkip: false } },
                        y: { stacked: true, grid: grid(), beginAtZero: true, ticks: { precision: 0 } }
                    }
                }
            });
        }

        /* 10. Cumulative Line */
        if (cumul && cumul.labels) {
            new Chart(document.getElementById('cumulChart'), {
                type: 'line',
                data: {
                    labels: cumul.labels, datasets: [{
                        label: 'Cumulative Present', data: cumul.values,
                        borderColor: C.blue, backgroundColor: C.blueL,
                        fill: true, tension: .35, pointRadius: 3, borderDash: []
                    }]
                },
                options: {
                    responsive: true, maintainAspectRatio: false,
                    plugins: { legend: { display: false }, tooltip: tip() },
                    scales: {
                        x: { grid: grid(), ticks: { maxTicksLimit: 10, maxRotation: 30 } },
                        y: { grid: grid(), beginAtZero: true }
                    }
                }
            });
        }
    });
    })();
</script> --%>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.4.1/chart.umd.js"></script>
<script>
    (function () {
        // Dashboard-style soft colors (matching the dashboard theme)
        var C = {
            present: '#2e7d32',
            presentL: 'rgba(46,125,50,0.15)',
            presentSoft: 'rgba(46,125,50,0.25)',
            absent: '#c62828',
            absentL: 'rgba(198,40,40,0.12)',
            absentSoft: 'rgba(198,40,40,0.22)',
            leave: '#f57c00',
            leaveL: 'rgba(245,124,0,0.12)',
            leaveSoft: 'rgba(245,124,0,0.22)',
            blue: '#1565c0',
            blueL: 'rgba(21,101,192,0.1)',
            blueSoft: 'rgba(21,101,192,0.2)',
            teal: '#00695c',
            tealL: 'rgba(0,105,92,0.15)',
            amber: '#f9a825',
            amberL: 'rgba(249,168,37,0.15)',
            purple: '#5e35b1',
            purpleL: 'rgba(94,53,177,0.15)',
            risk: ['#2e7d32', '#1565c0', '#f57c00', '#c62828']
        };

        // Dashboard-style subject colors (softer variants)
        var subjColors = [
            'rgba(21,101,192,0.7)',   // blue
            'rgba(94,53,177,0.7)',    // purple
            'rgba(0,105,92,0.7)',     // teal
            'rgba(230,81,0,0.7)',     // orange
            'rgba(55,71,79,0.7)',     // dark grey
            'rgba(136,14,79,0.7)',    // deep purple
            'rgba(27,94,32,0.7)',     // green
            'rgba(13,71,161,0.7)'     // darker blue
        ];

        var subjBorderColors = [
            '#1565c0', '#5e35b1', '#00695c', '#e65100', '#37474f', '#880e4f', '#1b5e20', '#0d47a1'
        ];

        function makeLegend(id, items) {
            var el = document.getElementById(id); if (!el) return;
            el.innerHTML = items.map(function (i) {
                return '<span><span class="ana-legend-dot" style="background:' + i.c + '"></span>' + i.l + '</span>';
            }).join('');
        }

        function safe(id) {
            var el = document.getElementById(id); if (!el || !el.value) return null;
            try { return JSON.parse(el.value); } catch (e) { return null; }
        }

        Chart.defaults.font.family = "'Segoe UI',sans-serif";
        Chart.defaults.font.size = 12;
        Chart.defaults.color = '#607d8b';

        function grid() { return { color: 'rgba(0,0,0,.04)', drawBorder: false, lineWidth: 1 }; }
        function tip() {
            return {
                backgroundColor: '#ffffff',
                titleColor: '#1565c0',
                bodyColor: '#607d8b',
                padding: 10,
                cornerRadius: 8,
                borderColor: '#e3f2fd',
                borderWidth: 1,
                boxShadow: '0 2px 8px rgba(0,0,0,0.1)'
            };
        }

        window.addEventListener('load', function () {
            var pie = safe('<%= hfPieData.ClientID %>');
            var subj = safe('<%= hfSubjectData.ClientID %>');
            var monthly = safe('<%= hfMonthlyData.ClientID %>');
            var dow = safe('<%= hfDowData.ClientID %>');
            var dist = safe('<%= hfDistData.ClientID %>');
            var subBar = safe('<%= hfSubBarData.ClientID %>');
            var absen = safe('<%= hfAbsenteeData.ClientID %>');
            var topS = safe('<%= hfTopStudentData.ClientID %>');
            var risk = safe('<%= hfRiskData.ClientID %>');
            var cumul = safe('<%= hfCumulData.ClientID %>');

            /* 1. Pie Chart - Dashboard style soft colors */
            if (pie) {
                makeLegend('pieLegend', [
                    { c: C.presentSoft, l: 'Present ' + pie.present },
                    { c: C.absentSoft, l: 'Absent ' + pie.absent },
                    { c: C.leaveSoft, l: 'Leave ' + pie.leave }
                ]);
                new Chart(document.getElementById('pieChart'), {
                    type: 'pie',
                    data: {
                        labels: ['Present', 'Absent', 'Leave'],
                        datasets: [{
                            data: [pie.present, pie.absent, pie.leave],
                            backgroundColor: [C.presentSoft, C.absentSoft, C.leaveSoft],
                            borderColor: [C.present, C.absent, C.leave],
                            borderWidth: 2,
                            hoverOffset: 8
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: {
                            legend: { display: false },
                            tooltip: { ...tip(), callbacks: { label: function (ctx) { return ' ' + ctx.label + ': ' + ctx.parsed + ' students'; } } }
                        }
                    }
                });
            }

            /* 2. Subject Donut - Dashboard gradient style */
            if (subj && subj.labels) {
                makeLegend('subjectLegend', subj.labels.map(function (l, i) {
                    return { c: subjColors[i % subjColors.length], l: l + ' ' + subj.values[i] + '%' };
                }));
                new Chart(document.getElementById('subjectDonut'), {
                    type: 'doughnut',
                    data: {
                        labels: subj.labels,
                        datasets: [{
                            data: subj.values,
                            backgroundColor: subj.labels.map(function (_, i) { return subjColors[i % subjColors.length]; }),
                            borderColor: subj.labels.map(function (_, i) { return subjBorderColors[i % subjBorderColors.length]; }),
                            borderWidth: 2,
                            hoverOffset: 8
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        cutout: '65%',
                        plugins: {
                            legend: { display: false },
                            tooltip: { ...tip(), callbacks: { label: function (ctx) { return ' ' + ctx.label + ': ' + ctx.parsed + '%'; } } }
                        }
                    }
                });
            }

            /* 3. Monthly Trend - Soft fills */
            if (monthly && monthly.labels) {
                makeLegend('trendLegend', [
                    { c: C.present, l: 'Present' },
                    { c: C.absent, l: 'Absent' },
                    { c: C.leave, l: 'Leave' }
                ]);
                new Chart(document.getElementById('trendChart'), {
                    type: 'line',
                    data: {
                        labels: monthly.labels,
                        datasets: [
                            {
                                label: 'Present',
                                data: monthly.present,
                                borderColor: C.present,
                                backgroundColor: C.presentL,
                                fill: true,
                                tension: 0.4,
                                pointRadius: 4,
                                pointBackgroundColor: C.present,
                                pointBorderColor: '#fff',
                                pointBorderWidth: 2,
                                borderWidth: 2
                            },
                            {
                                label: 'Absent',
                                data: monthly.absent,
                                borderColor: C.absent,
                                backgroundColor: C.absentL,
                                fill: true,
                                tension: 0.4,
                                pointRadius: 4,
                                pointBackgroundColor: C.absent,
                                pointBorderColor: '#fff',
                                pointBorderWidth: 2,
                                borderWidth: 2,
                                borderDash: [5, 5]
                            },
                            {
                                label: 'Leave',
                                data: monthly.leave,
                                borderColor: C.leave,
                                backgroundColor: C.leaveL,
                                fill: true,
                                tension: 0.4,
                                pointRadius: 4,
                                pointBackgroundColor: C.leave,
                                pointBorderColor: '#fff',
                                pointBorderWidth: 2,
                                borderWidth: 2,
                                borderDash: [3, 3]
                            }
                        ]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        interaction: { mode: 'index', intersect: false },
                        plugins: { legend: { display: false }, tooltip: tip() },
                        scales: {
                            x: { grid: grid(), ticks: { font: { size: 11 } } },
                            y: { grid: grid(), beginAtZero: true, ticks: { stepSize: 1, font: { size: 11 } } }
                        }
                    }
                });
            }

            /* 4. Day-of-Week - Soft gradient bars */
            if (dow && dow.labels) {
                new Chart(document.getElementById('dowChart'), {
                    type: 'bar',
                    data: {
                        labels: dow.labels,
                        datasets: [{
                            label: 'Avg Present %',
                            data: dow.values,
                            borderRadius: 8,
                            backgroundColor: dow.values.map(function (v) {
                                return v >= 75 ? C.presentSoft : v >= 50 ? C.leaveSoft : C.absentSoft;
                            }),
                            borderColor: dow.values.map(function (v) {
                                return v >= 75 ? C.present : v >= 50 ? C.leave : C.absent;
                            }),
                            borderWidth: 1.5,
                            hoverBackgroundColor: dow.values.map(function (v) {
                                return v >= 75 ? C.present : v >= 50 ? C.leave : C.absent;
                            }),
                            barPercentage: 0.65,
                            categoryPercentage: 0.8
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: {
                            legend: { display: false },
                            tooltip: { ...tip(), callbacks: { label: function (ctx) { return ' Avg: ' + ctx.parsed.y + '%'; } } }
                        },
                        scales: {
                            x: { grid: { display: false }, ticks: { font: { size: 11 }, autoSkip: false } },
                            y: {
                                grid: grid(),
                                beginAtZero: true,
                                max: 100,
                                ticks: { callback: function (v) { return v + '%'; }, font: { size: 11 } }
                            }
                        }
                    }
                });
            }

            /* 5. Distribution Histogram - Soft colors */
            if (dist && dist.labels) {
                new Chart(document.getElementById('distChart'), {
                    type: 'bar',
                    data: {
                        labels: dist.labels,
                        datasets: [{
                            label: 'Students',
                            data: dist.values,
                            borderRadius: 8,
                            backgroundColor: dist.labels.map(function (l) {
                                var v = parseInt(l);
                                return v >= 75 ? C.presentSoft : v >= 50 ? C.leaveSoft : C.absentSoft;
                            }),
                            borderColor: dist.labels.map(function (l) {
                                var v = parseInt(l);
                                return v >= 75 ? C.present : v >= 50 ? C.leave : C.absent;
                            }),
                            borderWidth: 1.5,
                            barPercentage: 0.7
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: {
                            legend: { display: false },
                            tooltip: { ...tip(), callbacks: { label: function (ctx) { return ' ' + ctx.parsed.y + ' students'; } } }
                        },
                        scales: {
                            x: { grid: { display: false }, ticks: { font: { size: 10 }, maxRotation: 30, autoSkip: false } },
                            y: { grid: grid(), beginAtZero: true, ticks: { precision: 0, font: { size: 11 } } }
                        }
                    }
                });
            }

            /* 6. Subject Grouped Bar - Soft stacked colors */
            if (subBar && subBar.labels) {
                makeLegend('subBarLegend', [
                    { c: C.presentSoft, l: 'Present' },
                    { c: C.absentSoft, l: 'Absent' },
                    { c: C.leaveSoft, l: 'Leave' }
                ]);
                new Chart(document.getElementById('subBarChart'), {
                    type: 'bar',
                    data: {
                        labels: subBar.labels,
                        datasets: [
                            { label: 'Present', data: subBar.present, backgroundColor: C.presentSoft, borderColor: C.present, borderWidth: 1, borderRadius: 6 },
                            { label: 'Absent', data: subBar.absent, backgroundColor: C.absentSoft, borderColor: C.absent, borderWidth: 1, borderRadius: 6 },
                            { label: 'Leave', data: subBar.leave, backgroundColor: C.leaveSoft, borderColor: C.leave, borderWidth: 1, borderRadius: 6 }
                        ]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: {
                            legend: { display: false },
                            tooltip: { ...tip(), callbacks: { label: function (ctx) { return ' ' + ctx.dataset.label + ': ' + ctx.parsed.y; } } }
                        },
                        scales: {
                            x: { grid: { display: false }, ticks: { font: { size: 10 }, autoSkip: false, maxRotation: 25 } },
                            y: { grid: grid(), beginAtZero: true, ticks: { stepSize: 1, font: { size: 11 } } }
                        }
                    }
                });
            }

            /* 7. Top Absentees - Soft horizontal bars */
            if (absen && absen.labels) {
                document.getElementById('absenteeBarWrap').style.height = Math.max(280, absen.labels.length * 38 + 60) + 'px';
                new Chart(document.getElementById('absenteeChart'), {
                    type: 'bar',
                    indexAxis: 'y',
                    data: {
                        labels: absen.labels,
                        datasets: [{
                            label: 'Absences',
                            data: absen.values,
                            backgroundColor: C.absentSoft,
                            borderColor: C.absent,
                            borderWidth: 1.5,
                            borderRadius: 6,
                            barPercentage: 0.7
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: {
                            legend: { display: false },
                            tooltip: { ...tip(), callbacks: { label: function (ctx) { return ' ' + ctx.parsed.x + ' days absent'; } } }
                        },
                        scales: {
                            x: { grid: grid(), beginAtZero: true, ticks: { precision: 0, font: { size: 11 } } },
                            y: { grid: { display: false }, ticks: { font: { size: 11 } } }
                        }
                    }
                });
            }

            /* 8. Leaderboard - Soft gradient bars */
            if (topS && topS.labels) {
                document.getElementById('topStudentsWrap').style.height = Math.max(280, topS.labels.length * 38 + 60) + 'px';
                new Chart(document.getElementById('topStudentChart'), {
                    type: 'bar',
                    indexAxis: 'y',
                    data: {
                        labels: topS.labels,
                        datasets: [{
                            label: 'Attendance %',
                            data: topS.values,
                            borderRadius: 6,
                            backgroundColor: topS.values.map(function (v) {
                                return v >= 90 ? C.tealL : v >= 75 ? C.presentSoft : C.amberL;
                            }),
                            borderColor: topS.values.map(function (v) {
                                return v >= 90 ? C.teal : v >= 75 ? C.present : C.amber;
                            }),
                            borderWidth: 1.5,
                            barPercentage: 0.7
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: {
                            legend: { display: false },
                            tooltip: { ...tip(), callbacks: { label: function (ctx) { return ' ' + ctx.parsed.x + '% attendance'; } } }
                        },
                        scales: {
                            x: {
                                grid: grid(),
                                beginAtZero: true,
                                max: 100,
                                ticks: { callback: function (v) { return v + '%'; }, font: { size: 11 } }
                            },
                            y: { grid: { display: false }, ticks: { font: { size: 11 } } }
                        }
                    }
                });
            }

            /* 9. Risk Stacked - Dashboard risk colors */
            if (risk && risk.labels) {
                makeLegend('riskLegend', [
                    { c: C.risk[0] + '40', l: 'Safe ≥90%' },
                    { c: C.risk[1] + '40', l: 'Good 75–89%' },
                    { c: C.risk[2] + '40', l: 'Warning 50–74%' },
                    { c: C.risk[3] + '40', l: 'Danger <50%' }
                ]);
                new Chart(document.getElementById('riskChart'), {
                    type: 'bar',
                    data: {
                        labels: risk.labels,
                        datasets: [
                            { label: 'Safe ≥90%', data: risk.safe, backgroundColor: C.risk[0] + '30', borderColor: C.risk[0], borderWidth: 1, borderRadius: 6, stack: 'stack' },
                            { label: 'Good 75–89%', data: risk.good, backgroundColor: C.risk[1] + '30', borderColor: C.risk[1], borderWidth: 1, borderRadius: 6, stack: 'stack' },
                            { label: 'Warning 50–74%', data: risk.warning, backgroundColor: C.risk[2] + '30', borderColor: C.risk[2], borderWidth: 1, borderRadius: 6, stack: 'stack' },
                            { label: 'Danger <50%', data: risk.danger, backgroundColor: C.risk[3] + '30', borderColor: C.risk[3], borderWidth: 1, borderRadius: 6, stack: 'stack' }
                        ]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: {
                            legend: { display: false },
                            tooltip: { ...tip(), callbacks: { label: function (ctx) { return ' ' + ctx.dataset.label + ': ' + ctx.parsed.y + ' students'; } } }
                        },
                        scales: {
                            x: { stacked: true, grid: { display: false }, ticks: { font: { size: 10 }, autoSkip: false, maxRotation: 25 } },
                            y: { stacked: true, grid: grid(), beginAtZero: true, ticks: { precision: 0, font: { size: 11 } } }
                        }
                    }
                });
            }

            /* 10. Cumulative Line - Soft gradient area */
            if (cumul && cumul.labels) {
                new Chart(document.getElementById('cumulChart'), {
                    type: 'line',
                    data: {
                        labels: cumul.labels,
                        datasets: [{
                            label: 'Cumulative Present',
                            data: cumul.values,
                            borderColor: C.blue,
                            backgroundColor: function (context) {
                                var chart = context.chart;
                                var ctx = chart.ctx;
                                var gradient = ctx.createLinearGradient(0, 0, 0, 250);
                                gradient.addColorStop(0, C.blue + '40');
                                gradient.addColorStop(1, C.blue + '05');
                                return gradient;
                            }(),
                            fill: true,
                            tension: 0.35,
                            pointRadius: 4,
                            pointBackgroundColor: C.blue,
                            pointBorderColor: '#fff',
                            pointBorderWidth: 2,
                            borderWidth: 2.5
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: {
                            legend: { display: false },
                            tooltip: { ...tip(), callbacks: { label: function (ctx) { return ' Total: ' + ctx.parsed.y + ' students'; } } }
                        },
                        scales: {
                            x: { grid: grid(), ticks: { maxTicksLimit: 10, maxRotation: 30, font: { size: 10 } } },
                            y: { grid: grid(), beginAtZero: true, ticks: { stepSize: 1, font: { size: 11 } } }
                        }
                    }
                });
            }
        });
    })();
</script>
</asp:Content>