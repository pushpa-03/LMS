<%@ Page Title="Attendance" Language="C#" MasterPageFile="~/Teacher/TeacherMaster.master"
    AutoEventWireup="true" CodeBehind="TeacherAttendance.aspx.cs"
    Inherits="LMS_Project.Teacher.TeacherAttendance" %>

<asp:Content ID="headContent" ContentPlaceHolderID="head" runat="server">
<style>
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
.att-page-title { font-size:22px; font-weight:700; color:var(--blue-dark); margin-bottom:22px; }
.att-page-title i { margin-right:8px; color:var(--blue-light); }
.att-tabs { display:flex; gap:6px; background:#fff; border-radius:10px; padding:6px; box-shadow:var(--card-shadow); margin-bottom:20px; }
.att-tab-btn { flex:1; padding:9px 18px; border:none; border-radius:7px; font-size:14px; font-weight:600; cursor:pointer; background:transparent; color:#555; transition:.2s; }
.att-tab-btn.active { background:var(--blue-dark); color:#fff; box-shadow:0 2px 8px rgba(21,101,192,.3); }
.att-tab-btn:hover:not(.active) { background:var(--blue-pale); color:var(--blue-dark); }
.att-card { background:#fff; border-radius:12px; padding:22px 24px; box-shadow:var(--card-shadow); margin-bottom:20px; }
.att-card-title { font-size:15px; font-weight:700; color:var(--blue-dark); margin-bottom:16px; display:flex; align-items:center; gap:8px; }
.att-filter-row { display:flex; flex-wrap:wrap; gap:14px; align-items:flex-end; }
.att-filter-group { display:flex; flex-direction:column; gap:5px; min-width:180px; }
.att-filter-group label { font-size:12px; font-weight:600; color:#555; text-transform:uppercase; letter-spacing:.5px; }
.att-filter-group select, .att-filter-group input[type=date] { padding:8px 12px; border:1.5px solid #dce6f0; border-radius:7px; font-size:14px; color:#333; background:#fafcff; outline:none; transition:.2s; }
.att-filter-group select:focus, .att-filter-group input[type=date]:focus { border-color:var(--blue-light); box-shadow:0 0 0 3px rgba(66,165,245,.15); }
.att-btn { padding:9px 22px; border:none; border-radius:8px; font-size:14px; font-weight:600; cursor:pointer; transition:.2s; display:inline-flex; align-items:center; gap:7px; }
.att-btn-primary { background:var(--blue-dark); color:#fff; }
.att-btn-primary:hover { background:var(--blue-mid); }
.att-btn-success { background:var(--green); color:#fff; }
.att-btn-success:hover { background:#1b5e20; }
.att-alert { padding:10px 16px; border-radius:8px; font-size:13px; font-weight:500; margin-bottom:14px; display:flex; align-items:center; gap:8px; }
.att-alert-info    { background:var(--blue-pale);   color:var(--blue-dark); }
.att-alert-success { background:var(--green-light); color:var(--green); }
.att-alert-warning { background:var(--amber-light); color:var(--amber); }
.att-alert-danger  { background:var(--red-light);   color:var(--red); }
.att-table-wrap { overflow-x:auto; }
.att-table { width:100%; border-collapse:separate; border-spacing:0; font-size:14px; }
.att-table thead th { background:var(--blue-dark); color:#fff; padding:11px 14px; font-weight:600; font-size:12px; text-transform:uppercase; letter-spacing:.5px; }
.att-table thead th:first-child { border-radius:8px 0 0 0; }
.att-table thead th:last-child  { border-radius:0 8px 0 0; }
.att-table tbody tr:hover { background:var(--blue-pale); }
.att-table tbody td { padding:10px 14px; border-bottom:1px solid #eef2f7; vertical-align:middle; }
.att-table tbody tr:last-child td { border-bottom:none; }
.status-group { display:flex; gap:6px; }
.status-radio { display:none; }
.status-label { padding:5px 14px; border-radius:20px; font-size:12px; font-weight:600; cursor:pointer; border:1.5px solid transparent; transition:.15s; user-select:none; }
.status-label.present { background:var(--green-light); color:var(--green);   border-color:#a5d6a7; }
.status-label.absent  { background:var(--red-light);   color:var(--red);     border-color:#ef9a9a; }
.status-label.leave   { background:var(--amber-light); color:var(--amber);   border-color:#ffcc80; }
.status-radio:checked + .status-label.present { background:var(--green); color:#fff; }
.status-radio:checked + .status-label.absent  { background:var(--red);   color:#fff; }
.status-radio:checked + .status-label.leave   { background:var(--amber); color:#fff; }
.att-badge { display:inline-block; padding:3px 10px; border-radius:12px; font-size:11px; font-weight:700; }
.att-badge-present { background:var(--green-light); color:var(--green); }
.att-badge-absent  { background:var(--red-light);   color:var(--red);   }
.att-badge-leave   { background:var(--amber-light);  color:var(--amber); }
.att-stats-row { display:flex; gap:14px; flex-wrap:wrap; margin-bottom:18px; }
.att-stat-card { flex:1; min-width:110px; background:#fff; border-radius:10px; padding:14px 18px; box-shadow:var(--card-shadow); text-align:center; border-top:4px solid var(--blue-light); }
.att-stat-card.green-top { border-color:var(--green); }
.att-stat-card.red-top   { border-color:var(--red); }
.att-stat-num { font-size:26px; font-weight:800; color:var(--blue-dark); }
.att-stat-lbl { font-size:11px; font-weight:600; color:#888; text-transform:uppercase; letter-spacing:.5px; margin-top:3px; }
.mark-all-row { display:flex; gap:10px; align-items:center; margin-bottom:14px; padding:10px 14px; background:var(--blue-pale); border-radius:8px; font-size:13px; font-weight:600; color:var(--blue-dark); flex-wrap:wrap; }
.att-progress-wrap { background:#eee; border-radius:10px; height:8px; overflow:hidden; }
.att-progress-bar  { height:100%; border-radius:10px; background:var(--green); transition:width .4s; }
.att-progress-bar.warn { background:var(--amber); }
.att-progress-bar.low  { background:var(--red); }
.att-panel { display:none; }
.att-panel.active { display:block; }
@media(max-width:600px){ .att-filter-row{flex-direction:column;} .att-filter-group{min-width:100%;} .att-stats-row{flex-direction:column;} }
</style>
</asp:Content>

<asp:Content ID="bodyContent" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

<div class="att-page-title"><i class="fas fa-clipboard-check"></i> Attendance Management</div>

<div class="att-tabs">
    <button class="att-tab-btn active" onclick="switchTab('mark',this)"><i class="fas fa-pen me-1"></i> Mark Attendance</button>
    <button class="att-tab-btn" onclick="switchTab('report',this)"><i class="fas fa-chart-bar me-1"></i> Attendance Report</button>
    <button class="att-tab-btn" onclick="switchTab('daywise',this)"><i class="fas fa-calendar-day me-1"></i> Day-wise Summary</button>
</div>

<!-- ===== TAB 1: MARK ATTENDANCE ===== -->
<div id="tab-mark" class="att-panel active">
    <div class="att-card">
        <div class="att-card-title"><i class="fas fa-sliders-h"></i> Select Subject & Date</div>
        <div class="att-filter-row">
            <div class="att-filter-group">
                <label>Subject</label>
                <asp:DropDownList ID="ddlSubject" runat="server"><asp:ListItem Value="">-- Select Subject --</asp:ListItem></asp:DropDownList>
            </div>
            <div class="att-filter-group">
                <label>Date</label>
                <asp:TextBox ID="txtDate" runat="server" TextMode="Date" />
            </div>
            <div style="display:flex;align-items:flex-end;">
                <asp:Button ID="btnLoadStudents" runat="server" Text="Load Students" CssClass="att-btn att-btn-primary" OnClick="btnLoadStudents_Click" />
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
                <span style="margin-left:auto;font-size:13px;font-weight:500;color:#888;">
                    Date: <asp:Label ID="lblSelectedDate" runat="server" />
                </span>
            </div>
            <div class="mark-all-row">
                <span>Mark All:</span>
                <button type="button" class="att-btn att-btn-success" style="padding:5px 14px;font-size:12px;" onclick="markAll('Present')"><i class="fas fa-check"></i> Present</button>
                <button type="button" class="att-btn" style="padding:5px 14px;font-size:12px;background:var(--red);color:#fff;" onclick="markAll('Absent')"><i class="fas fa-times"></i> Absent</button>
                <button type="button" class="att-btn" style="padding:5px 14px;font-size:12px;background:var(--amber);color:#fff;" onclick="markAll('Leave')"><i class="fas fa-umbrella-beach"></i> Leave</button>
            </div>
            <div class="att-table-wrap">
                <table class="att-table">
                    <thead><tr><th>#</th><th>Roll No</th><th>Student Name</th><th>Status</th></tr></thead>
                    <tbody>
                        <asp:Repeater ID="rptStudents" runat="server">
                            <ItemTemplate>
                                <tr>
                                    <td><%# Container.ItemIndex + 1 %></td>
                                    <td><%# Eval("RollNumber") %></td>
                                    <td style="font-weight:600;"><%# Eval("FullName") %></td>
                                    <td>
                                        <div class="status-group" data-userid="<%# Eval("UserId") %>">
                                            <input type="radio" class="status-radio" name="status_<%# Eval("UserId") %>" id="p_<%# Eval("UserId") %>" value="Present" <%# Eval("Status").ToString()=="Present"?"checked":"" %> />
                                            <label for="p_<%# Eval("UserId") %>" class="status-label present"><i class="fas fa-check"></i> Present</label>
                                            <input type="radio" class="status-radio" name="status_<%# Eval("UserId") %>" id="a_<%# Eval("UserId") %>" value="Absent" <%# Eval("Status").ToString()=="Absent"?"checked":"" %> />
                                            <label for="a_<%# Eval("UserId") %>" class="status-label absent"><i class="fas fa-times"></i> Absent</label>
                                            <input type="radio" class="status-radio" name="status_<%# Eval("UserId") %>" id="l_<%# Eval("UserId") %>" value="Leave" <%# Eval("Status").ToString()=="Leave"?"checked":"" %> />
                                            <label for="l_<%# Eval("UserId") %>" class="status-label leave"><i class="fas fa-umbrella-beach"></i> Leave</label>
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
                <asp:Button ID="btnSaveAttendance" runat="server" Text="Save Attendance"
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
                <asp:DropDownList ID="ddlReportSubject" runat="server"><asp:ListItem Value="">-- Select Subject --</asp:ListItem></asp:DropDownList>
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
                <asp:Button ID="btnLoadReport" runat="server" Text="Generate Report" CssClass="att-btn att-btn-primary" OnClick="btnLoadReport_Click" />
            </div>
        </div>
    </div>

    <asp:Panel ID="pnlReportStats" runat="server" Visible="false">
        <div class="att-stats-row">
            <div class="att-stat-card">
                <div class="att-stat-num"><asp:Label ID="lblTotalStudents" runat="server" Text="0" /></div>
                <div class="att-stat-lbl">Students</div>
            </div>
            <div class="att-stat-card green-top">
                <div class="att-stat-num" style="color:var(--green)"><asp:Label ID="lblAvgPresent" runat="server" Text="0" /></div>
                <div class="att-stat-lbl">Avg Present %</div>
            </div>
            <div class="att-stat-card red-top">
                <div class="att-stat-num" style="color:var(--red)"><asp:Label ID="lblLowAttendance" runat="server" Text="0" /></div>
                <div class="att-stat-lbl">Below 75%</div>
            </div>
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlReport" runat="server" Visible="false">
        <div class="att-card">
            <div class="att-card-title"><i class="fas fa-table"></i> Student-wise Attendance Report</div>
            <div class="att-table-wrap">
                <table class="att-table">
                    <thead><tr><th>#</th><th>Roll No</th><th>Student Name</th><th>Total</th><th>Present</th><th>Absent</th><th>Leave</th><th>Percentage</th></tr></thead>
                    <tbody>
                        <asp:Repeater ID="rptReport" runat="server">
                            <ItemTemplate>
                                <tr>
                                    <td><%# Container.ItemIndex + 1 %></td>
                                    <td><%# Eval("RollNumber") %></td>
                                    <td style="font-weight:600;"><%# Eval("FullName") %></td>
                                    <td><%# Eval("TotalClasses") %></td>
                                    <td><span class="att-badge att-badge-present"><%# Eval("PresentCount") %></span></td>
                                    <td><span class="att-badge att-badge-absent"><%# Eval("AbsentCount") %></span></td>
                                    <td><span class="att-badge att-badge-leave"><%# Eval("LeaveCount") %></span></td>
                                    <td>
                                        <div style="display:flex;align-items:center;gap:8px;">
                                            <div class="att-progress-wrap" style="width:80px;">
                                                <div class="att-progress-bar <%# Convert.ToDouble(Eval("Percentage")) >= 75 ? "" : Convert.ToDouble(Eval("Percentage")) >= 50 ? "warn" : "low" %>"
                                                     style="width:<%# Eval("Percentage") %>%"></div>
                                            </div>
                                            <span style="font-weight:700;font-size:13px;"><%# Eval("Percentage") %>%</span>
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
                <asp:DropDownList ID="ddlDaySubject" runat="server"><asp:ListItem Value="">-- Select Subject --</asp:ListItem></asp:DropDownList>
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
                <asp:Button ID="btnLoadDaywise" runat="server" Text="View Summary" CssClass="att-btn att-btn-primary" OnClick="btnLoadDaywise_Click" />
            </div>
        </div>
    </div>

    <asp:Panel ID="pnlDaywise" runat="server" Visible="false">
        <div class="att-card">
            <div class="att-card-title"><i class="fas fa-calendar-alt"></i> Day-wise Attendance Summary</div>
            <div class="att-table-wrap">
                <table class="att-table">
                    <thead><tr><th>Date</th><th>Total Students</th><th>Present</th><th>Absent</th><th>Leave</th></tr></thead>
                    <tbody>
                        <asp:Repeater ID="rptDaywise" runat="server">
                            <ItemTemplate>
                                <tr>
                                    <td style="font-weight:600;"><i class="fas fa-calendar-day me-2" style="color:var(--blue-light);"></i><%# Convert.ToDateTime(Eval("Date")).ToString("dd MMM yyyy") %></td>
                                    <td><%# Eval("TotalStudents") %></td>
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

<asp:HiddenField ID="hfActiveTab" runat="server" Value="mark" />

<script>
    // On page load, restore active tab
    window.onload = function () {
        var activeTab = document.getElementById('<%= hfActiveTab.ClientID %>').value || 'mark';
        var allPanels = document.querySelectorAll('.att-panel');
        var allBtns = document.querySelectorAll('.att-tab-btn');

        allPanels.forEach(p => p.classList.remove('active'));
        allBtns.forEach(b => b.classList.remove('active'));

        var panel = document.getElementById('tab-' + activeTab);
        if (panel) panel.classList.add('active');

        // Find matching button by onclick attribute
        allBtns.forEach(function (b) {
            if (b.getAttribute('onclick') && b.getAttribute('onclick').indexOf("'" + activeTab + "'") !== -1) {
                b.classList.add('active');
            }
        });
    };

    function switchTab(tab, el) {
        document.querySelectorAll('.att-panel').forEach(p => p.classList.remove('active'));
        document.querySelectorAll('.att-tab-btn').forEach(b => b.classList.remove('active'));
        document.getElementById('tab-' + tab).classList.add('active');
        el.classList.add('active');
        // Save active tab
        document.getElementById('<%= hfActiveTab.ClientID %>').value = tab;
    }

    function markAll(status) {
        document.querySelectorAll('.status-group').forEach(function (grp) {
            var uid = grp.dataset.userid;
            var radio = document.querySelector('input[name="status_' + uid + '"][value="' + status + '"]');
            if (radio) radio.checked = true;
        });
    }

    function collectAttendance() {
        var data = [];
        document.querySelectorAll('.status-group').forEach(function (grp) {
            var uid = grp.dataset.userid;
            var checked = document.querySelector('input[name="status_' + uid + '"]:checked');
            if (checked) data.push(uid + ':' + checked.value);
        });
        document.getElementById('<%= hfAttendanceData.ClientID %>').value = data.join(',');
    }
</script>
</asp:Content>