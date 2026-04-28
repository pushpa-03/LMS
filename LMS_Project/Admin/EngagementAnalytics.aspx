<%@ Page Title="Engagement Analytics" Language="C#" 
MasterPageFile="~/Admin/AdminMaster.Master"
AutoEventWireup="true"
CodeBehind="EngagementAnalytics.aspx.cs"
Inherits="LearningManagementSystem.Admin.EngagementAnalytics" %>

<asp:Content ID="cHead" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<style>

/* ===== HEADER ===== */
.page-title {
    font-weight:800;
    color:#1565c0;
    margin-bottom:15px;
}

/* ===== KPI CARDS ===== */
.kpi-card {
    background:#fff;
    border-radius:16px;
    padding:20px;
    box-shadow:0 4px 15px rgba(0,0,0,.06);
    transition:.3s;
}
.kpi-card:hover {
    transform:translateY(-5px);
}

.kpi-value {
    font-size:28px;
    font-weight:800;
}

.kpi-label {
    font-size:12px;
    color:#90a4ae;
}

/* ===== CHART CARD ===== */
.chart-card {
    background:#fff;
    border-radius:16px;
    padding:20px;
    box-shadow:0 4px 12px rgba(0,0,0,.05);
}

</style>

</asp:Content>


<asp:Content ID="cBody" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

<h4 class="page-title">📊 Engagement Analytics</h4>

<!-- KPI ROW -->
<div class="row g-3 mb-4">

    <div class="col-md-3">
        <div class="kpi-card">
            <div class="kpi-value"><%=TotalViews%></div>
            <div class="kpi-label">Video Views</div>
        </div>
    </div>

    <div class="col-md-3">
        <div class="kpi-card">
            <div class="kpi-value"><%=Completed%>%</div>
            <div class="kpi-label">Completion Rate</div>
        </div>
    </div>

    <div class="col-md-3">
        <div class="kpi-card">
            <div class="kpi-value"><%=ActiveUsers%></div>
            <div class="kpi-label">Active Users</div>
        </div>
    </div>

    <div class="col-md-3">
        <div class="kpi-card">
            <div class="kpi-value"><%=AvgTime%> min</div>
            <div class="kpi-label">Avg Watch Time</div>
        </div>
    </div>

</div>

<!-- CHARTS -->
<div class="row g-3">

    <!-- Engagement Trend -->
    <div class="col-md-6">
        <div class="chart-card">
            <h6>📈 Engagement Trend</h6>
            <canvas id="trendChart"></canvas>
        </div>
    </div>

    <!-- Completion Pie -->
    <div class="col-md-6">
        <div class="chart-card">
            <h6>🎯 Completion Distribution</h6>
            <canvas id="completionChart"></canvas>
        </div>
    </div>

    <!-- Top Students -->
    <div class="col-md-6">
        <div class="chart-card">
            <h6>🏆 Top Engaged Students</h6>
            <canvas id="studentChart"></canvas>
        </div>
    </div>

    <!-- Subject Engagement -->
    <div class="col-md-6">
        <div class="chart-card">
            <h6>📚 Subject Engagement</h6>
            <canvas id="subjectChart"></canvas>
        </div>
    </div>

</div>


<script>

function chart(id, type, labels, data, color) {
    new Chart(document.getElementById(id), {
        type: type,
        data: {
            labels: labels,
            datasets: [{
                data: data,
                backgroundColor: color,
                borderWidth: 2,
                tension: 0.4,
                fill: true
            }]
        },
        options: {
            responsive: true,
            animation: {
                duration: 1500
            }
        }
    });
}

// TREND
chart("trendChart", "line",
    <%=TrendLabels%>,
    <%=TrendData%>,
    "#42a5f5");

// COMPLETION
chart("completionChart", "doughnut",
    ['Completed','Pending'],
    [<%=Completed%>, <%=Pending%>],
    ['#2e7d32','#ef5350']);

// STUDENTS
chart("studentChart", "bar",
    <%=StudentLabels%>,
    <%=StudentData%>,
    "#7b1fa2");

// SUBJECT
chart("subjectChart", "bar",
    <%=SubjectLabels%>,
    <%=SubjectData%>,
    "#f57c00");

</script>

</asp:Content>