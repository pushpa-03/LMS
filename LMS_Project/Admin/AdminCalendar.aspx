<%@ Page Title="Admin Calendar"
    Language="C#"
    MasterPageFile="~/Admin/AdminMaster.master"
    AutoEventWireup="true"
    CodeBehind="AdminCalendar.aspx.cs"
    Inherits="LMS_Project.Admin.AdminCalendar" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

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
    background: var(--primary);
    color: #fff !important;
    text-align: center;
    padding: 12px !important;
    font-weight: 600;
    font-size: 14px;
}
.calendar-modern .day-header {
    background: #e8f5e9;          /* light green — adjust to match your --primary */
    color: var(--primary) !important;
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
.calendar-modern .today   { border: 2px solid var(--primary); background: #ecf9ec; }

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