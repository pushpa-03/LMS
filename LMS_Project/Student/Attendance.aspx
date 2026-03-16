<%@ Page Title="Attendance" Language="C#"
    MasterPageFile="~/Student/StudentMaster.Master"
    AutoEventWireup="true"
    CodeBehind="Attendance.aspx.cs"
    Inherits="LMS_Project.Student.Attendance" %>

<asp:Content ID="cHead" ContentPlaceHolderID="head" runat="server">
<style>

.page-header {
    display:flex; align-items:center; justify-content:space-between;
    margin-bottom:22px; flex-wrap:wrap; gap:12px;
}
.page-header h4 { margin:0; font-weight:800; color:#1565c0; font-size:20px; }

/* ── Overall banner ── */
.overall-banner {
    background: linear-gradient(135deg, #1565c0, #1976d2);
    border-radius:16px; padding:24px 28px;
    color:#fff; margin-bottom:22px;
    display:flex; align-items:center; gap:28px; flex-wrap:wrap;
}
.overall-ring-wrap { position:relative; flex-shrink:0; }
.overall-ring-wrap svg { display:block; }
.ring-center-text {
    position:absolute; top:50%; left:50%;
    transform:translate(-50%,-50%);
    text-align:center;
}
.ring-center-text .pct  { font-size:26px; font-weight:900; color:#1565c0; line-height:1; }
.ring-center-text .lbl  { font-size:10px; color:#90a4ae; font-weight:700;
    text-transform:uppercase; letter-spacing:.4px; }

.overall-stats { display:flex; gap:20px; flex-wrap:wrap; flex:1; }
.stat-pill {
    background:rgba(255,255,255,.15); border-radius:12px;
    padding:12px 18px; text-align:center; min-width:80px;
}
.stat-pill .sp-val { font-size:22px; font-weight:900; line-height:1; }
.stat-pill .sp-lbl { font-size:11px; opacity:.8; text-transform:uppercase;
    letter-spacing:.4px; margin-top:3px; }
.stat-pill.present { background:rgba(255,255,255,.2); }
.stat-pill.absent  { background:rgba(198,40,40,.3); }
.stat-pill.leave   { background:rgba(255,193,7,.2); }
.stat-pill.total   { background:rgba(255,255,255,.1); }

/* ── Subject cards ── */
.section-title {
    font-size:14px; font-weight:800; color:#546e7a;
    text-transform:uppercase; letter-spacing:.5px;
    margin-bottom:14px; display:flex; align-items:center; gap:8px;
}
.section-title::after {
    content:''; flex:1; height:1px; background:#e3e8f0;
}

.subject-atten-card {
    background:#fff; border-radius:14px;
    box-shadow:0 2px 8px rgba(0,0,0,.06);
    padding:18px 20px; height:100%;
    border-top:4px solid #e3e8f0;
    transition:transform .15s, box-shadow .15s;
    cursor:pointer;
}
.subject-atten-card:hover {
    transform:translateY(-2px); box-shadow:0 5px 16px rgba(0,0,0,.1);
}
.subject-atten-card.high   { border-top-color:#2e7d32; }
.subject-atten-card.medium { border-top-color:#f57f17; }
.subject-atten-card.low    { border-top-color:#c62828; }

.sac-top { display:flex; align-items:flex-start; justify-content:space-between; gap:10px; margin-bottom:14px; }
.sac-code { font-size:11px; font-weight:700; color:#1976d2;
    text-transform:uppercase; letter-spacing:.5px; margin-bottom:3px; }
.sac-name { font-size:14px; font-weight:800; color:#1a237e; }

/* Small donut */
.small-donut { position:relative; width:64px; height:64px; flex-shrink:0; }
.small-donut svg { display:block; }
.small-donut .sd-pct {
    position:absolute; top:50%; left:50%;
    transform:translate(-50%,-50%);
    font-size:12px; font-weight:900;
}
.small-donut .sd-pct.high   { color:#2e7d32; }
.small-donut .sd-pct.medium { color:#f57f17; }
.small-donut .sd-pct.low    { color:#c62828; }

.sac-bars { display:flex; flex-direction:column; gap:6px; }
.sac-bar-row { display:flex; align-items:center; gap:8px; font-size:11px; }
.sac-bar-label { width:50px; color:#78909c; text-align:right; }
.sac-bar-track { flex:1; height:6px; background:#f0f4f8; border-radius:3px; }
.sac-bar-fill  { height:100%; border-radius:3px; }
.sac-bar-count { width:24px; text-align:right; font-weight:700; color:#263238; }

/* Warning chip */
.warning-chip {
    display:inline-flex; align-items:center; gap:5px;
    background:#fff3e0; color:#e65100;
    border:1.5px solid #ffcc80;
    border-radius:8px; padding:3px 10px;
    font-size:11px; font-weight:700; margin-top:10px;
}
.safe-chip {
    display:inline-flex; align-items:center; gap:5px;
    background:#e8f5e9; color:#2e7d32;
    border:1.5px solid #a5d6a7;
    border-radius:8px; padding:3px 10px;
    font-size:11px; font-weight:700; margin-top:10px;
}

/* ── Calendar section ── */
.calendar-panel {
    background:#fff; border-radius:14px;
    box-shadow:0 2px 8px rgba(0,0,0,.06);
    padding:20px; margin-top:24px;
}
.cal-header {
    display:flex; align-items:center; justify-content:space-between;
    margin-bottom:16px; flex-wrap:wrap; gap:10px;
}
.cal-header h6 { margin:0; font-weight:800; color:#263238; font-size:15px; }
.cal-controls { display:flex; align-items:center; gap:10px; flex-wrap:wrap; }
.cal-controls select {
    border:1.5px solid #e3e8f0; border-radius:8px; padding:5px 12px;
    font-size:13px; color:#263238; background:#f8fbff; outline:none;
}
.btn-cal-nav {
    width:32px; height:32px; border-radius:8px;
    background:#f0f4f8; color:#546e7a;
    border:1.5px solid #e3e8f0; cursor:pointer;
    display:flex; align-items:center; justify-content:center;
    font-size:12px; transition:all .15s;
}
.btn-cal-nav:hover { background:#e3f2fd; color:#1565c0; }

/* Calendar grid */
.cal-grid { display:grid; grid-template-columns:repeat(7,1fr); gap:4px; }
.cal-day-header {
    text-align:center; font-size:11px; font-weight:700;
    color:#90a4ae; padding:6px 0; text-transform:uppercase; letter-spacing:.3px;
}
.cal-day {
    aspect-ratio:1; border-radius:8px;
    display:flex; align-items:center; justify-content:center;
    font-size:12px; font-weight:700; color:#263238;
    position:relative;
}
.cal-day.empty    { background:transparent; }
.cal-day.weekend  { background:#f9fafb; color:#cfd8dc; }
.cal-day.present  { background:#e8f5e9; color:#2e7d32; }
.cal-day.absent   { background:#ffebee; color:#c62828; }
.cal-day.leave    { background:#fff8e1; color:#f57f17; }
.cal-day.today    { border:2px solid #1565c0; }
.cal-day.no-class { background:#f5f5f5; color:#cfd8dc; }

/* Calendar legend */
.cal-legend { display:flex; gap:14px; margin-top:12px; flex-wrap:wrap; }
.leg-item { display:flex; align-items:center; gap:5px; font-size:11px; color:#78909c; }
.leg-dot  { width:12px; height:12px; border-radius:4px; }

/* ── Recent log ── */
.log-table {
    width:100%; border-collapse:collapse; font-size:13px;
    margin-top:20px;
}
.log-table th {
    background:#f8fbff; color:#546e7a; font-weight:700;
    font-size:11px; text-transform:uppercase; letter-spacing:.4px;
    padding:10px 14px; text-align:left;
    border-bottom:2px solid #e3e8f0;
}
.log-table td {
    padding:10px 14px; border-bottom:1px solid #f0f4f8; color:#263238;
}
.log-table tr:last-child td { border-bottom:none; }
.log-table tr:hover td { background:#f8fbff; }

.status-dot {
    display:inline-flex; align-items:center; gap:6px;
    padding:3px 12px; border-radius:20px; font-size:11px; font-weight:700;
}
.dot-present { background:#e8f5e9; color:#2e7d32; }
.dot-absent  { background:#ffebee; color:#c62828; }
.dot-leave   { background:#fff8e1; color:#f57f17; }

</style>
</asp:Content>

<asp:Content ID="cBody" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<%-- Hidden fields for calendar navigation --%>
<asp:HiddenField ID="hfSubjectId" runat="server" Value="0" />
<asp:HiddenField ID="hfYear"      runat="server" />
<asp:HiddenField ID="hfMonth"     runat="server" />

<%-- ══ PAGE HEADER ══ --%>
<div class="page-header">
    <h4><i class="fas fa-calendar-check me-2"></i>Attendance</h4>
</div>

<%-- ══ OVERALL BANNER ══ --%>
<div class="overall-banner">

    <%-- Overall ring (rendered server-side) --%>
    <div>
        <asp:Literal ID="litOverallRing" runat="server" />
    </div>

    <div>
        <div style="font-size:13px;opacity:.8;margin-bottom:8px;">Overall Attendance</div>
        <div class="overall-stats">
            <div class="stat-pill present">
                <div class="sp-val"><asp:Label ID="lblPresent" runat="server" Text="0"/></div>
                <div class="sp-lbl">Present</div>
            </div>
            <div class="stat-pill absent">
                <div class="sp-val"><asp:Label ID="lblAbsent" runat="server" Text="0"/></div>
                <div class="sp-lbl">Absent</div>
            </div>
            <div class="stat-pill leave">
                <div class="sp-val"><asp:Label ID="lblLeave" runat="server" Text="0"/></div>
                <div class="sp-lbl">Leave</div>
            </div>
            <div class="stat-pill total">
                <div class="sp-val"><asp:Label ID="lblTotal" runat="server" Text="0"/></div>
                <div class="sp-lbl">Total Classes</div>
            </div>
        </div>
    </div>

</div>

<%-- ══ SUBJECT CARDS ══ --%>
<div class="section-title">
    <i class="fas fa-book"></i> Subject-wise Breakdown
</div>

<div class="row g-3 mb-4">
    <asp:Repeater ID="rptSubjects" runat="server"
        OnItemCommand="rptSubjects_ItemCommand">
        <ItemTemplate>
            <div class="col-md-6 col-lg-4">
                <div class='subject-atten-card <%# GetAttendanceClass(Convert.ToDecimal(Eval("Percentage"))) %>'
                     onclick="selectSubject(<%# Eval("SubjectId") %>, '<%# Eval("SubjectName") %>')">

                    <div class="sac-top">
                        <div>
                            <div class="sac-code"><%# Eval("SubjectCode") %></div>
                            <div class="sac-name"><%# Eval("SubjectName") %></div>
                        </div>
                        <%# BuildSmallDonut(
                                Convert.ToDecimal(Eval("Percentage")),
                                Convert.ToInt32(Eval("Present")),
                                Convert.ToInt32(Eval("Total"))) %>
                    </div>

                    <div class="sac-bars">
                        <div class="sac-bar-row">
                            <div class="sac-bar-label" style="color:#2e7d32;">Present</div>
                            <div class="sac-bar-track">
                                <div class="sac-bar-fill"
                                     style="width:<%# Eval("Total") as int? > 0
                                        ? (Convert.ToInt32(Eval("Present")) * 100 / Convert.ToInt32(Eval("Total")))
                                        : 0 %>%;background:#2e7d32;"></div>
                            </div>
                            <div class="sac-bar-count"><%# Eval("Present") %></div>
                        </div>
                        <div class="sac-bar-row">
                            <div class="sac-bar-label" style="color:#c62828;">Absent</div>
                            <div class="sac-bar-track">
                                <div class="sac-bar-fill"
                                     style="width:<%# Eval("Total") as int? > 0
                                        ? (Convert.ToInt32(Eval("Absent")) * 100 / Convert.ToInt32(Eval("Total")))
                                        : 0 %>%;background:#c62828;"></div>
                            </div>
                            <div class="sac-bar-count"><%# Eval("Absent") %></div>
                        </div>
                        <div class="sac-bar-row">
                            <div class="sac-bar-label" style="color:#f57f17;">Leave</div>
                            <div class="sac-bar-track">
                                <div class="sac-bar-fill"
                                     style="width:<%# Eval("Total") as int? > 0
                                        ? (Convert.ToInt32(Eval("Leave")) * 100 / Convert.ToInt32(Eval("Total")))
                                        : 0 %>%;background:#f57f17;"></div>
                            </div>
                            <div class="sac-bar-count"><%# Eval("Leave") %></div>
                        </div>
                    </div>

                    <%-- Warning / Safe chip --%>
                    <%# GetAttendanceChip(
                            Convert.ToDecimal(Eval("Percentage")),
                            Convert.ToInt32(Eval("Present")),
                            Convert.ToInt32(Eval("Total"))) %>

                </div>
            </div>
        </ItemTemplate>
    </asp:Repeater>
</div>

<%-- ══ CALENDAR + LOG SECTION ══ --%>
<asp:Panel ID="pnlCalendar" runat="server" Visible="false">

    <div class="calendar-panel">
        <div class="cal-header">
            <h6>
                <i class="fas fa-calendar-alt me-2 text-primary"></i>
                <asp:Label ID="lblCalSubject" runat="server" />
            </h6>
            <div class="cal-controls">
                <asp:DropDownList ID="ddlCalSubject" runat="server"
                    AutoPostBack="true"
                    OnSelectedIndexChanged="ddlCalSubject_Changed" />

                <asp:LinkButton ID="btnPrevMonth" runat="server"
                    OnClick="btnPrevMonth_Click" CssClass="btn-cal-nav">
                    <i class="fas fa-chevron-left"></i>
                </asp:LinkButton>

                <strong style="font-size:13px;min-width:110px;text-align:center;">
                    <asp:Label ID="lblCalMonthYear" runat="server" />
                </strong>

                <asp:LinkButton ID="btnNextMonth" runat="server"
                    OnClick="btnNextMonth_Click" CssClass="btn-cal-nav">
                    <i class="fas fa-chevron-right"></i>
                </asp:LinkButton>
            </div>
        </div>

        <%-- Calendar grid --%>
        <asp:Literal ID="litCalendar" runat="server" />

        <%-- Legend --%>
        <div class="cal-legend">
            <div class="leg-item">
                <div class="leg-dot" style="background:#e8f5e9;border:1px solid #a5d6a7;"></div>Present
            </div>
            <div class="leg-item">
                <div class="leg-dot" style="background:#ffebee;border:1px solid #ef9a9a;"></div>Absent
            </div>
            <div class="leg-item">
                <div class="leg-dot" style="background:#fff8e1;border:1px solid #ffe082;"></div>Leave
            </div>
            <div class="leg-item">
                <div class="leg-dot" style="background:#f5f5f5;border:1px solid #e0e0e0;"></div>No Class
            </div>
            <div class="leg-item">
                <div class="leg-dot" style="border:2px solid #1565c0;"></div>Today
            </div>
        </div>

    </div>

</asp:Panel>

<%-- ══ RECENT LOG TABLE ══ --%>
<div class="section-title mt-4">
    <i class="fas fa-history"></i> Recent Attendance Log
</div>

<div style="background:#fff;border-radius:14px;box-shadow:0 2px 8px rgba(0,0,0,.06);overflow:hidden;">
    <table class="log-table">
        <thead>
            <tr>
                <th>Date</th>
                <th>Day</th>
                <th>Subject</th>
                <th>Status</th>
            </tr>
        </thead>
        <tbody>
            <asp:Repeater ID="rptLog" runat="server">
                <ItemTemplate>
                    <tr>
                        <td><strong><%# Eval("Date", "{0:dd MMM yyyy}") %></strong></td>
                        <td style="color:#90a4ae;"><%# Eval("DayName") %></td>
                        <td>
                            <span style="font-size:11px;color:#1976d2;font-weight:700;">
                                <%# Eval("SubjectCode") %>
                            </span>
                            <%# Eval("SubjectName") %>
                        </td>
                        <td>
                            <span class='status-dot dot-<%# Eval("Status")?.ToString().ToLower() %>'>
                                <i class='fas <%# Eval("Status")?.ToString() == "Present"
                                    ? "fa-check" : Eval("Status")?.ToString() == "Absent"
                                    ? "fa-times" : "fa-minus" %>'></i>
                                <%# Eval("Status") %>
                            </span>
                        </td>
                    </tr>
                </ItemTemplate>
            </asp:Repeater>
        </tbody>
    </table>
</div>

<script>
function selectSubject(subjectId, name) {
    document.getElementById('<%= hfSubjectId.ClientID %>').value = subjectId;
    // Trigger postback to load calendar
    __doPostBack('<%= btnPrevMonth.UniqueID %>', 'select:' + subjectId);
    }
</script>

</asp:Content>
