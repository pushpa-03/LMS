<%@ Page Title="" Language="C#" MasterPageFile="~/Teacher/TeacherMaster.Master" AutoEventWireup="true" CodeBehind="TeacherCalendar.aspx.cs" Inherits="LMS_Project.Teacher.TeacherCalendar" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">
<style>
.calendar-modern {
    width: 100%;
    border: none !important;
    background: #fff;
    border-radius: 14px;
    overflow: hidden;
    box-shadow: 0 2px 8px rgba(0,0,0,.06);
}
.calendar-modern th {
    background: linear-gradient(135deg, #1565c0, #42a5f5);
    color: #fff !important;
    text-align: center;
    padding: 12px !important;
    font-weight: 600;
    font-size: 14px;
}
.calendar-modern .day-header {
    background: #e3f2fd;
    color: #1565c0 !important;
    font-weight: 700;
    font-size: 12px;
}
.calendar-modern td {
    height: 90px;
    vertical-align: top;
    padding: 6px !important;
    border: 1px solid #e3f2fd;
    position: relative;
    transition: background .2s;
}
.day-number {
    font-weight: bold;
    color: #263238;
    display: block;
    margin-bottom: 4px;
}
.calendar-modern td:hover {
    background: #f5faff;
}
.calendar-modern .today {
    border: 2px solid #1565c0;
    background: #e3f2fd;
}
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
.event-holiday    { background: #c62828; }
.event-exam       { background: #ef6c00; }
.event-assignment { background: #1976d2; }

.badge-general    { background-color: #e3f2fd !important; color:#1565c0; }
.badge-holiday    { background-color: #ffebee !important; color:#c62828; }
.badge-exam       { background-color: #fff3e0 !important; color:#ef6c00; }
.badge-assignment { background-color: #e3f2fd !important; color:#1976d2; }
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

    <!-- ADD EVENT BUTTON -->
    <div class="mb-3 text-end">
        <button type="button" class="btn btn-primary btn-sm"
            data-bs-toggle="modal" data-bs-target="#addEventModal">
            + Add Event
        </button>
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

    <div class="d-flex justify-content-between align-items-center mb-3">
        <h5 class="mb-0">
            Events in <asp:Label ID="lblTableMonthYear" runat="server" />
        </h5>
    </div>

    <asp:GridView ID="gvEvents" runat="server"
        CssClass="table table-bordered table-hover table-sm align-middle mb-0"
        AutoGenerateColumns="false"
        GridLines="None"
        EmptyDataText="No events this month."
        OnRowCommand="gvEvents_RowCommand">

        <Columns>

            <asp:BoundField DataField="Title"     HeaderText="Title" />

            <asp:TemplateField HeaderText="Type">
                <ItemTemplate>
                    <span class='badge badge-<%# Eval("EventType").ToString().ToLower() %>'>
                        <%# Eval("EventType") %>
                    </span>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:BoundField DataField="SubjectName" HeaderText="Subject" />
            <asp:BoundField DataField="StartDate" HeaderText="Start"
                DataFormatString="{0:dd MMM yyyy}" />

            <asp:BoundField DataField="EndDate"   HeaderText="End"
                DataFormatString="{0:dd MMM yyyy}" />

            <asp:TemplateField HeaderText="All Day">
                <ItemTemplate>
                    <%# Convert.ToBoolean(Eval("IsAllDay")) ? "✅" : "—" %>
                </ItemTemplate>
            </asp:TemplateField>

            <asp:TemplateField HeaderText="Actions">
                <ItemTemplate>
                    <asp:LinkButton ID="btnEdit" runat="server"
                        CommandName="EditEvent"
                        CommandArgument='<%# Eval("EventId") %>'
                        CssClass="btn btn-sm btn-outline-primary me-1">
                        ✏️ Edit
                    </asp:LinkButton>
                    <asp:LinkButton ID="btnDel" runat="server"
                        CommandName="DeleteEvent"
                        CommandArgument='<%# Eval("EventId") %>'
                        CssClass="btn btn-sm btn-outline-danger"
                        OnClientClick="return confirm('Delete this event from all days it appears?');">
                        🗑️ Delete
                    </asp:LinkButton>
                </ItemTemplate>
            </asp:TemplateField>

        </Columns>
    </asp:GridView>

</div>

<!-- ===== ADD EVENT MODAL ===== -->
<div class="modal fade" id="addEventModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Add Event</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <div class="mb-3">
                    <label class="form-label fw-semibold">Title <span class="text-danger">*</span></label>
                    <asp:TextBox ID="txtTitle" runat="server" CssClass="form-control" placeholder="Event Title" />
                    <asp:RequiredFieldValidator ID="rfvTitle" runat="server"
                        ControlToValidate="txtTitle" ErrorMessage="Title is required."
                        CssClass="text-danger small" Display="Dynamic" ValidationGroup="AddForm" />
                </div>
                <div class="mb-3">
    <label class="form-label fw-semibold">Subject <span class="text-danger">*</span></label>
    <asp:DropDownList ID="ddlSubject" runat="server" CssClass="form-select">
        <asp:ListItem Text="-- Select Subject --" Value="" />
    </asp:DropDownList>
    <small class="text-muted">Only students enrolled in this subject will see the event.</small>
</div>
                <div class="mb-3">
                    <label class="form-label fw-semibold">Event Type</label>
                    <asp:DropDownList ID="ddlEventType" runat="server" CssClass="form-select">
                        <asp:ListItem Text="General"    Value="General" />
                        <asp:ListItem Text="Holiday"    Value="Holiday" />
                        <asp:ListItem Text="Exam"       Value="Exam" />
                        <asp:ListItem Text="Assignment" Value="Assignment" />
                    </asp:DropDownList>
                </div>
                <div class="mb-3">
                    <label class="form-label fw-semibold">Start Date <span class="text-danger">*</span></label>
                    <asp:TextBox ID="txtStartDate" runat="server" CssClass="form-control" TextMode="Date" />
                    <asp:RequiredFieldValidator ID="rfvStart" runat="server"
                        ControlToValidate="txtStartDate" ErrorMessage="Start date is required."
                        CssClass="text-danger small" Display="Dynamic" ValidationGroup="AddForm" />
                </div>
                <div class="mb-3">
                    <label class="form-label fw-semibold">End Date <span class="text-danger">*</span></label>
                    <asp:TextBox ID="txtEndDate" runat="server" CssClass="form-control" TextMode="Date" />
                    <asp:RequiredFieldValidator ID="rfvEnd" runat="server"
                        ControlToValidate="txtEndDate" ErrorMessage="End date is required."
                        CssClass="text-danger small" Display="Dynamic" ValidationGroup="AddForm" />
                </div>
                <div class="mb-3 form-check">
                    <asp:CheckBox ID="chkAllDay" runat="server" CssClass="form-check-input" />
                    <label class="form-check-label">All Day Event</label>
                </div>
                <asp:Label ID="lblMessage" runat="server" Visible="false" />
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                <asp:Button ID="btnSave" runat="server" Text="Save Event"
                    CssClass="btn btn-success" OnClick="btnSave_Click" ValidationGroup="AddForm" />
            </div>
        </div>
    </div>
</div>

<!-- ===== EDIT EVENT MODAL ===== -->
<div class="modal fade" id="editEventModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Edit Event</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <asp:HiddenField ID="hfEditEventId" runat="server" />
                <div class="mb-3">
                    <label class="form-label fw-semibold">Title <span class="text-danger">*</span></label>
                    <asp:TextBox ID="txtEditTitle" runat="server" CssClass="form-control" />
                    <asp:RequiredFieldValidator ID="rfvEditTitle" runat="server"
                        ControlToValidate="txtEditTitle" ErrorMessage="Title is required."
                        CssClass="text-danger small" Display="Dynamic" ValidationGroup="EditForm" />
                </div>
                <div class="mb-3">
    <label class="form-label fw-semibold">Subject</label>
    <asp:DropDownList ID="ddlEditSubject" runat="server" CssClass="form-select" />
</div>
                <div class="mb-3">
                    <label class="form-label fw-semibold">Event Type</label>
                    <asp:DropDownList ID="ddlEditEventType" runat="server" CssClass="form-select">
                        <asp:ListItem Text="General"    Value="General" />
                        <asp:ListItem Text="Holiday"    Value="Holiday" />
                        <asp:ListItem Text="Exam"       Value="Exam" />
                        <asp:ListItem Text="Assignment" Value="Assignment" />
                    </asp:DropDownList>
                </div>
                <div class="mb-3">
                    <label class="form-label fw-semibold">Start Date <span class="text-danger">*</span></label>
                    <asp:TextBox ID="txtEditStartDate" runat="server" CssClass="form-control" TextMode="Date" />
                    <asp:RequiredFieldValidator ID="rfvEditStart" runat="server"
                        ControlToValidate="txtEditStartDate" ErrorMessage="Start date is required."
                        CssClass="text-danger small" Display="Dynamic" ValidationGroup="EditForm" />
                </div>
                <div class="mb-3">
                    <label class="form-label fw-semibold">End Date <span class="text-danger">*</span></label>
                    <asp:TextBox ID="txtEditEndDate" runat="server" CssClass="form-control" TextMode="Date" />
                    <asp:RequiredFieldValidator ID="rfvEditEnd" runat="server"
                        ControlToValidate="txtEditEndDate" ErrorMessage="End date is required."
                        CssClass="text-danger small" Display="Dynamic" ValidationGroup="EditForm" />
                </div>
                <div class="mb-3 form-check">
                    <asp:CheckBox ID="chkEditAllDay" runat="server" CssClass="form-check-input" />
                    <label class="form-check-label">All Day Event</label>
                </div>
                <asp:Label ID="lblEditMessage" runat="server" Visible="false" />
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                <asp:Button ID="btnUpdate" runat="server" Text="Update Event"
                    CssClass="btn btn-primary" OnClick="btnUpdate_Click" ValidationGroup="EditForm" />
            </div>
        </div>
    </div>
</div>

<!-- Hidden field to control modal reopen after postback -->
<asp:HiddenField ID="hfReopenModal" runat="server" Value="" />

<script>
    window.addEventListener('DOMContentLoaded', function () {
        var target = document.getElementById('<%= hfReopenModal.ClientID %>').value;
        if (target && target !== '') {
            var modal = new bootstrap.Modal(document.getElementById(target));
            modal.show();
        }
    });
</script>
</asp:Content>