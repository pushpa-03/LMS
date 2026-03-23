<%@ Page Title="" Language="C#" MasterPageFile="~/Student/StudentMaster.Master" 
    AutoEventWireup="true" CodeBehind="StudentCalendar.aspx.cs" 
    Inherits="LMS_Project.Student.StudentCalendar" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<style>
.calendar-modern {
    width: 100%;
    border: none !important;
    background: white;
    border-radius: 8px;
    overflow: hidden;
    box-shadow: 0px 1px 3px 0px #364A630D;
}
.calendar-modern th {
    background: #28a745;
    color: #fff !important;
    text-align: center;
    padding: 12px !important;
    font-weight: 600;
    font-size: 14px;
}
.calendar-modern .day-header {
    background: #e8f5e9;
    color: #28a745 !important;
    font-weight: 600;
    font-size: 13px;
}
.calendar-modern td {
    height: 90px;
    vertical-align: top;
    padding: 6px !important;
    border: 1px solid #EEF1F5;
    position: relative;
}
.day-number {
    font-weight: bold;
    color: #333;
    display: block;
    margin-bottom: 4px;
}
.calendar-modern td:hover { background: #f8fafc; }
.calendar-modern .today   { border: 2px solid #28a745; background: #ecf9ec; }

.event-dot {
    font-size: 11px;
    margin-top: 2px;
    display: block;
    padding: 2px 6px;
    border-radius: 4px;
    color: white;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    max-width: 100%;
}
.event-general    { background: #41A141; }
.event-holiday    { background: #e74c3c; }
.event-exam       { background: #f39c12; }
.event-assignment { background: #3498db; }

.badge-general    { background-color: #41A141 !important; }
.badge-holiday    { background-color: #e74c3c !important; }
.badge-exam       { background-color: #f39c12 !important; }
.badge-assignment { background-color: #3498db !important; }

/* Legend */
.legend-dot {
    display: inline-block;
    width: 12px; height: 12px;
    border-radius: 3px;
    margin-right: 4px;
}
</style>

<div class="card shadow p-3 mb-4">

    <!-- HEADER -->
    <div class="d-flex justify-content-between align-items-center mb-3">
        <asp:Button ID="btnPrev" runat="server" Text="←"
            CssClass="btn btn-light btn-sm" OnClick="btnPrev_Click" />
        <h4 class="mb-0"><asp:Label ID="lblMonthYear" runat="server" /></h4>
        <asp:Button ID="btnNext" runat="server" Text="→"
            CssClass="btn btn-light btn-sm" OnClick="btnNext_Click" />
    </div>

    <!-- LEGEND -->
    <div class="mb-3 d-flex flex-wrap gap-3 small">
        <span><span class="legend-dot event-general"></span>General</span>
        <span><span class="legend-dot event-holiday"></span>Holiday</span>
        <span><span class="legend-dot event-exam"></span>Exam</span>
        <span><span class="legend-dot event-assignment"></span>Assignment</span>
    </div>

    <!-- CALENDAR -->
    <asp:Calendar ID="calEvents" runat="server"
        CssClass="calendar-modern"
        ShowTitle="false"
        OnDayRender="calEvents_DayRender">
        <DayHeaderStyle CssClass="day-header" />
        <TodayDayStyle CssClass="today" />
    </asp:Calendar>

</div>

<!-- EVENTS TABLE FOR THIS MONTH -->
<div class="card shadow p-3">
    <h5 class="mb-3">
        Events in <asp:Label ID="lblTableMonthYear" runat="server" />
    </h5>

    <asp:GridView ID="gvEvents" runat="server"
        CssClass="table table-bordered table-hover table-sm align-middle mb-0"
        AutoGenerateColumns="false"
        GridLines="None"
        EmptyDataText="No events this month.">
        <Columns>
            <asp:BoundField DataField="Title" HeaderText="Title" />

            <asp:TemplateField HeaderText="Type">
                <ItemTemplate>
                    <span class='badge badge-<%# Eval("EventType").ToString().ToLower() %>'>
                        <%# Eval("EventType") %>
                    </span>
                </ItemTemplate>
            </asp:TemplateField>

            <asp:BoundField DataField="StartDate" HeaderText="Start"
                DataFormatString="{0:dd MMM yyyy}" />
            <asp:BoundField DataField="EndDate" HeaderText="End"
                DataFormatString="{0:dd MMM yyyy}" />

            <asp:BoundField DataField="SubjectName" HeaderText="Subject" />

            <asp:TemplateField HeaderText="All Day">
                <ItemTemplate>
                    <%# Convert.ToBoolean(Eval("IsAllDay")) ? "✅" : "—" %>
                </ItemTemplate>
            </asp:TemplateField>
        </Columns>
    </asp:GridView>
</div>

</asp:Content>