<%@ Page Title="Attendance Dashboard" Language="C#" 
    MasterPageFile="~/Admin/AdminMaster.Master"
    AutoEventWireup="true"
    CodeBehind="AttendanceDashboard.aspx.cs"
    Inherits="LearningManagementSystem.Admin.AttendanceDashboard" %>

<asp:Content ID="cBody" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<style>
.card-box {
    border-radius: 14px;
    padding: 18px;
    background: #fff;
    box-shadow: 0 6px 16px rgba(0,0,0,0.08);
}
.kpi { font-size: 24px; font-weight: 700; }
.trend-up { color: #16a34a; }
.trend-down { color: #dc2626; }
</style>

<div class="container-fluid">

    <div class="alert alert-warning mt-3" id="alertBox"></div>

    <!-- FILTERS -->
    <div class="row mb-3">
        <div class="col-md-2">
            <asp:TextBox ID="txtFrom" runat="server" CssClass="form-control" TextMode="Date" />
        </div>
        <div class="col-md-2">
            <asp:TextBox ID="txtTo" runat="server" CssClass="form-control" TextMode="Date" />
        </div>

        <div class="col-md-2">
            <asp:DropDownList ID="ddlStream" runat="server" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="ddlStream_Changed"/>
        </div>

        <div class="col-md-2">
            <asp:DropDownList ID="ddlCourse" runat="server" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="ddlCourse_Changed"/>
        </div>

        <div class="col-md-2">
            <asp:DropDownList ID="ddlSubject" runat="server" CssClass="form-control"/>
        </div>

        <div class="col-md-2">
            <asp:Button ID="btnApply" runat="server" Text="Apply" CssClass="btn btn-primary w-100"/>
        </div>
    </div>

    <!-- KPI -->
    <div class="row">
        <div class="col-md-3"><div class="card-box"><div>Attendance %</div><div id="kpiAttendance" class="kpi"></div><div id="kpiTrend"></div></div></div>
        <div class="col-md-3"><div class="card-box"><div>Present</div><div id="kpiPresent" class="kpi"></div></div></div>
        <div class="col-md-3"><div class="card-box"><div>Absent</div><div id="kpiAbsent" class="kpi"></div></div></div>
    </div>

    <!-- CHARTS -->
    <div class="row mt-4">
        <div class="col-md-6"><canvas id="trendChart"></canvas></div>
        <div class="col-md-6"><canvas id="pieChart"></canvas></div>
    </div>

</div>

<script>
    let trendChart, pieChart;

    function loadDashboard() {

        let filters = {
            from: document.getElementById('<%= txtFrom.ClientID %>').value,
        to: document.getElementById('<%= txtTo.ClientID %>').value,
        streamId: document.getElementById('<%= ddlStream.ClientID %>').value,
        courseId: document.getElementById('<%= ddlCourse.ClientID %>').value,
        subjectId: document.getElementById('<%= ddlSubject.ClientID %>').value
        };

        fetch('AttendanceDashboard.aspx/GetDashboardData', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ filter: filters })
        })
            .then(res => res.json())
            .then(res => {

                let data = res.d;

                document.getElementById("kpiAttendance").innerText = data.Attendance + "%";
                document.getElementById("kpiPresent").innerText = data.Present;
                document.getElementById("kpiAbsent").innerText = data.Absent;

                document.getElementById("kpiTrend").innerHTML =
                    data.Trend >= 0
                        ? `<span class='trend-up'>↑ ${data.Trend}%</span>`
                        : `<span class='trend-down'>↓ ${data.Trend}%</span>`;

                document.getElementById("alertBox").innerText =
                    "⚠ " + data.LowAttendance + " students below 75%";

                drawCharts(data);
            });
    }

    function drawCharts(data) {

        if (trendChart) trendChart.destroy();
        if (pieChart) pieChart.destroy();

        trendChart = new Chart(document.getElementById("trendChart"), {
            type: 'line',
            data: {
                labels: data.Dates,
                datasets: [{ label: 'Attendance %', data: data.TrendData }]
            }
        });

        pieChart = new Chart(document.getElementById("pieChart"), {
            type: 'doughnut',
            data: {
                labels: ['Present', 'Absent'],
                datasets: [{ data: [data.Present, data.Absent] }]
            }
        });
    }

    setInterval(loadDashboard, 10000);
    window.onload = loadDashboard;
</script>

</asp:Content>