<%@ Page Title="Course Dashboard" Language="C#" MasterPageFile="~/Admin/AdminMaster.Master"
    AutoEventWireup="true" CodeBehind="CourseWiseDashboard.aspx.cs"
    Inherits="LearningManagementSystem.Admin.Dashboards.CourseWiseDashboard" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server" />

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet"/>
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<style>
.card-modern{border-radius:16px;box-shadow:0 10px 25px rgba(0,0,0,.08);transition:.3s;}
.card-modern:hover{transform:translateY(-5px);}
.gradient-header{background:linear-gradient(135deg,#4f46e5,#06b6d4);color:#fff;padding:20px;border-radius:16px;}
.kpi{font-size:24px;font-weight:700;}
</style>

<!-- ALERT -->
<asp:Panel ID="pnlAlert" runat="server" Visible="false" CssClass="alert">
    <asp:Label ID="lblAlert" runat="server"></asp:Label>
</asp:Panel>

<!-- HEADER -->
<div class="gradient-header mb-3">
    <div class="row">
        <div class="col-md-6">
            <h3><asp:Label ID="lblCourseTitle" runat="server"/></h3>
            <asp:Label ID="lblStreamName" runat="server"/>
        </div>
        <div class="col-md-6 text-end">
            <asp:DropDownList ID="ddlCourse" runat="server" CssClass="form-select w-auto d-inline"
                AutoPostBack="true" OnSelectedIndexChanged="ddlCourse_SelectedIndexChanged"/>
        </div>
    </div>
</div>

<!-- KPI -->
<div class="row g-3 mb-3">
    <div class="col"><div class="card card-modern p-3 text-center"><div class="kpi"><asp:Label ID="lblStudents" runat="server"/></div>Students</div></div>
    <div class="col"><div class="card card-modern p-3 text-center"><div class="kpi"><asp:Label ID="lblSubjects" runat="server"/></div>Subjects</div></div>
    <div class="col"><div class="card card-modern p-3 text-center"><div class="kpi"><asp:Label ID="lblSections" runat="server"/></div>Sections</div></div>
    <div class="col"><div class="card card-modern p-3 text-center"><div class="kpi"><asp:Label ID="lblAttPct" runat="server"/></div>Attendance</div></div>
    <div class="col"><div class="card card-modern p-3 text-center"><div class="kpi"><asp:Label ID="lblAssignSub" runat="server"/></div>Assignments</div></div>
    <div class="col"><div class="card card-modern p-3 text-center"><div class="kpi"><asp:Label ID="lblQuizAttempts" runat="server"/></div>Quiz Attempts</div></div>
    <div class="col"><div class="card card-modern p-3 text-center"><div class="kpi"><asp:Label ID="lblAvgQuiz" runat="server"/></div>Avg Score</div></div>
</div>

<!-- BANNER -->
<div class="card p-3 mb-3">
    <h5>Course Banner</h5>
    <asp:Label ID="lblBannerCourse" runat="server"></asp:Label><br />
    <asp:FileUpload ID="fuBanner" runat="server"/>
    <asp:Button ID="btnUploadBanner" runat="server" Text="Upload" CssClass="btn btn-primary btn-sm"
        OnClick="btnUploadBanner_Click"/>
    <asp:Button ID="btnRemoveBanner" runat="server" Text="Remove" CssClass="btn btn-danger btn-sm"
        OnClick="btnRemoveBanner_Click"/>
    <br />
    <asp:Image ID="imgBanner" runat="server" Visible="false" CssClass="img-fluid mt-2"/>
    <asp:HiddenField ID="hdnBannerPath" runat="server"/>
</div>

<!-- COURSE CARDS -->
<asp:Repeater ID="rptCourseCards" runat="server">
    <ItemTemplate>
        <div><%# Eval("CourseName") %> - <%# Eval("TotalStudents") %></div>
    </ItemTemplate>
</asp:Repeater>

<!-- CHARTS -->
<div class="row">
    <div class="col-md-6"><canvas id="trendChart"></canvas></div>
    <div class="col-md-6"><canvas id="genderChart"></canvas></div>
</div>

<div class="row mt-3">
    <div class="col-md-6"><canvas id="attendanceChart"></canvas></div>
    <div class="col-md-6"><canvas id="levelChart"></canvas></div>
</div>

<!-- TOP STUDENTS -->
<h5 class="mt-4">Top Students</h5>
<asp:Repeater ID="rptTopStudents" runat="server">
    <ItemTemplate>
        <div><%# Eval("FullName") %> - <%# Eval("AvgScore") %></div>
    </ItemTemplate>
</asp:Repeater>

<!-- SUBJECT TABLE -->
<h5 class="mt-4">Subjects</h5>
<asp:Repeater ID="rptSubjects" runat="server">
    <ItemTemplate>
        <div><%# Eval("SubjectName") %> - <%# Eval("AvgScore") %></div>
    </ItemTemplate>
</asp:Repeater>

<!-- HIDDEN FIELDS -->
<asp:HiddenField ID="hdnTrendMonths" runat="server"/>
<asp:HiddenField ID="hdnTrendStudents" runat="server"/>
<asp:HiddenField ID="hdnGenderLabels" runat="server"/>
<asp:HiddenField ID="hdnGenderVals" runat="server"/>
<asp:HiddenField ID="hdnAttWeeks" runat="server"/>
<asp:HiddenField ID="hdnAttPct" runat="server"/>
<asp:HiddenField ID="hdnAttPresent" runat="server"/>
<asp:HiddenField ID="hdnAttAbsent" runat="server"/>
<asp:HiddenField ID="hdnLevelLabels" runat="server"/>
<asp:HiddenField ID="hdnLevelStudents" runat="server"/>

<asp:HiddenField ID="hdnSemLabels" runat="server"/>
<asp:HiddenField ID="hdnSemStudents" runat="server"/>

<asp:HiddenField ID="hdnSubjNames" runat="server"/>
<asp:HiddenField ID="hdnSubjVideos" runat="server"/>
<asp:HiddenField ID="hdnSubjAssign" runat="server"/>
<asp:HiddenField ID="hdnSubjQuizzes" runat="server"/>
<asp:HiddenField ID="hdnSubjAtt" runat="server"/>
<asp:HiddenField ID="hdnSubjScore" runat="server"/>

<asp:HiddenField ID="hdnQuizTitles" runat="server"/>
<asp:HiddenField ID="hdnQuizAvg" runat="server"/>
<asp:HiddenField ID="hdnQuizPass" runat="server"/>
<asp:HiddenField ID="hdnQuizHigh" runat="server"/>

<asp:HiddenField ID="hdnSecLabels" runat="server"/>
<asp:HiddenField ID="hdnSecStudents" runat="server"/>

<asp:HiddenField ID="hdnAssignSubjects" runat="server"/>
<asp:HiddenField ID="hdnAssignRate" runat="server"/>
<asp:HiddenField ID="hdnAssignTotal" runat="server"/>
<asp:HiddenField ID="hdnAssignSub2" runat="server"/>

<!-- JS -->
<script>
    function j(v) { try { return JSON.parse(v || "[]") } catch { return [] } }

    new Chart(document.getElementById("trendChart"), {
        type: 'line',
        data: {
            labels: j('<%=hdnTrendMonths.Value%>'),
        datasets: [{ data: j('<%=hdnTrendStudents.Value%>') }]
    }
});

    new Chart(document.getElementById("genderChart"), {
        type: 'doughnut',
        data: {
            labels: j('<%=hdnGenderLabels.Value%>'),
        datasets: [{ data: j('<%=hdnGenderVals.Value%>') }]
    }
});

    new Chart(document.getElementById("attendanceChart"), {
        type: 'bar',
        data: {
            labels: j('<%=hdnAttWeeks.Value%>'),
        datasets: [{ data: j('<%=hdnAttPct.Value%>') }]
    }
});

    new Chart(document.getElementById("levelChart"), {
        type: 'pie',
        data: {
            labels: j('<%=hdnLevelLabels.Value%>'),
        datasets: [{ data: j('<%=hdnLevelStudents.Value%>') }]
    }
});
</script>

</asp:Content>