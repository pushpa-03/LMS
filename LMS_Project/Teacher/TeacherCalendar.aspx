<%@ Page Title="Teacher Calendar" Language="C#" MasterPageFile="~/Teacher/TeacherMaster.Master" AutoEventWireup="true" CodeBehind="TeacherCalendar.aspx.cs" Inherits="LMS_Project.Teacher.TeacherCalendar" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
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
        
        .modal-lg-custom {
            max-width: 600px;
        }
        
        .event-details {
            font-size: 12px;
            margin-top: 5px;
        }
        
        .loading-overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.5);
            display: none;
            z-index: 9999;
        }
        
        .other-month {
            background-color: #f9f9f9;
            color: #ccc;
        }
        
        .weekend {
            background-color: #fef9e6;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">
    
    <div class="card shadow p-3 mb-4">

        <!-- HEADER -->
        <div class="d-flex justify-content-between align-items-center mb-3">
            <asp:Button ID="btnPrev" runat="server" Text="← Previous Month"
                CssClass="btn btn-outline-primary btn-sm" OnClick="btnPrev_Click" />
            <h4 class="mb-0">
                <asp:Label ID="lblMonthYear" runat="server" />
            </h4>
            <asp:Button ID="btnNext" runat="server" Text="Next Month →"
                CssClass="btn btn-outline-primary btn-sm" OnClick="btnNext_Click" />
        </div>

        <!-- ADD EVENT BUTTON -->
        <div class="mb-3 text-end">
            <button type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addEventModal">
                <i class="bi bi-plus-circle"></i> + Add New Event
            </button>
        </div>

        <!-- CALENDAR - Fixed version -->
        <asp:Calendar ID="calEvents" runat="server"
            CssClass="calendar-modern"
            ShowTitle="false"
            OnDayRender="calEvents_DayRender"
            ShowNextPrevMonth="False">
            <DayHeaderStyle CssClass="day-header" />
            <TodayDayStyle CssClass="today" />
            <WeekendDayStyle CssClass="weekend" />
            <OtherMonthDayStyle CssClass="other-month" />
        </asp:Calendar>

    </div>

    <!-- EVENTS TABLE FOR THIS MONTH -->
<div class="card shadow p-3">

    <div class="d-flex justify-content-between align-items-center mb-3">
        <h5 class="mb-0">
            📅 Events in <asp:Label ID="lblTableMonthYear" runat="server" />
        </h5>
        <asp:Label ID="lblEventCount" runat="server" CssClass="text-muted" />
    </div>


    <div class="table-responsive">
       <asp:GridView ID="gvEvents" runat="server"
    CssClass="table table-bordered table-hover table-sm align-middle"
    AutoGenerateColumns="false"
    GridLines="None"
    EmptyDataText="📭 No events scheduled for this month."
    OnRowCommand="gvEvents_RowCommand">

    <Columns>
        <asp:BoundField DataField="Title" HeaderText="Event Title" HeaderStyle-Width="25%" />
        
        <asp:TemplateField HeaderText="Type" HeaderStyle-Width="12%">
            <ItemTemplate>
                <span class='badge badge-<%# Eval("EventType").ToString().ToLower() %> p-2'>
                    <%# Eval("EventType") %>
                </span>
            </ItemTemplate>
        </asp:TemplateField>
        
        <asp:BoundField DataField="SubjectName" HeaderText="Subject" HeaderStyle-Width="20%" />
        
        <asp:BoundField DataField="StartDate" HeaderText="Start Date" 
            DataFormatString="{0:dd MMM yyyy}" HeaderStyle-Width="15%" />
        
        <asp:BoundField DataField="EndDate" HeaderText="End Date" 
            DataFormatString="{0:dd MMM yyyy}" HeaderStyle-Width="15%" />
        
        <asp:TemplateField HeaderText="All Day" HeaderStyle-Width="8%">
            <ItemTemplate>
                <span class="badge bg-secondary">
                    <%# Convert.ToBoolean(Eval("IsAllDay")) ? "✓ All Day" : "Timed" %>
                </span>
            </ItemTemplate>
        </asp:TemplateField>

        <asp:TemplateField HeaderText="Actions" HeaderStyle-Width="15%">
            <ItemTemplate>
                <asp:LinkButton ID="btnEdit" runat="server"
                    CommandName="EditEvent"
                    CommandArgument='<%# Eval("EventId") %>'
                    CssClass="btn btn-sm btn-outline-primary me-1"
                    ToolTip="Edit Event">
                    ✏️ Edit
                </asp:LinkButton>
                <asp:LinkButton ID="btnDel" runat="server"
                    CommandName="DeleteEvent"
                    CommandArgument='<%# Eval("EventId") %>'
                    CssClass="btn btn-sm btn-outline-danger"
                    OnClientClick="return confirm('⚠️ Delete this event from all days it appears?\n\nThis action cannot be undone.');"
                    ToolTip="Delete Event">
                    🗑️ Delete
                </asp:LinkButton>
            </ItemTemplate>
        </asp:TemplateField>
    </Columns>
    
    <EmptyDataRowStyle CssClass="text-center p-4" />
</asp:GridView>
    </div>

</div>

    <!-- ===== ADD EVENT MODAL ===== -->
    <div class="modal fade" id="addEventModal" tabindex="-1" data-bs-backdrop="static" data-bs-keyboard="false">
        <div class="modal-dialog modal-lg-custom">
            <div class="modal-content">
                <div class="modal-header bg-primary text-white">
                    <h5 class="modal-title">
                        <i class="bi bi-calendar-plus"></i> Add New Event
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    
                    <div class="mb-3">
                        <label class="form-label fw-semibold">
                            Event Title <span class="text-danger">*</span>
                        </label>
                        <asp:TextBox ID="txtTitle" runat="server" CssClass="form-control" 
                            placeholder="Enter event title" MaxLength="200" />
                        <asp:RequiredFieldValidator ID="rfvTitle" runat="server"
                            ControlToValidate="txtTitle" 
                            ErrorMessage="Title is required."
                            CssClass="text-danger small" 
                            Display="Dynamic" 
                            ValidationGroup="AddForm" />
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label fw-semibold">
                            Subject <span class="text-danger">*</span>
                        </label>
                        <asp:DropDownList ID="ddlSubject" runat="server" CssClass="form-select">
                            <asp:ListItem Text="-- Select Subject --" Value="" />
                        </asp:DropDownList>
                        <asp:RequiredFieldValidator ID="rfvSubject" runat="server"
                            ControlToValidate="ddlSubject"
                            InitialValue=""
                            ErrorMessage="Please select a subject"
                            CssClass="text-danger small"
                            Display="Dynamic"
                            ValidationGroup="AddForm" />
                        <small class="text-muted">ℹ️ Only students enrolled in this subject will see the event.</small>
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Event Type</label>
                        <asp:DropDownList ID="ddlEventType" runat="server" CssClass="form-select">
                            <asp:ListItem Text="📌 General" Value="General" />
                            <asp:ListItem Text="🎉 Holiday" Value="Holiday" />
                            <asp:ListItem Text="📝 Exam" Value="Exam" />
                            <asp:ListItem Text="📚 Assignment" Value="Assignment" />
                        </asp:DropDownList>
                    </div>
                    
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label fw-semibold">
                                Start Date <span class="text-danger">*</span>
                            </label>
                            <asp:TextBox ID="txtStartDate" runat="server" CssClass="form-control" 
                                TextMode="Date" />
                            <asp:RequiredFieldValidator ID="rfvStart" runat="server"
                                ControlToValidate="txtStartDate" 
                                ErrorMessage="Start date is required."
                                CssClass="text-danger small" 
                                Display="Dynamic" 
                                ValidationGroup="AddForm" />
                        </div>
                        
                        <div class="col-md-6 mb-3">
                            <label class="form-label fw-semibold">
                                End Date <span class="text-danger">*</span>
                            </label>
                            <asp:TextBox ID="txtEndDate" runat="server" CssClass="form-control" 
                                TextMode="Date" />
                            <asp:RequiredFieldValidator ID="rfvEnd" runat="server"
                                ControlToValidate="txtEndDate" 
                                ErrorMessage="End date is required."
                                CssClass="text-danger small" 
                                Display="Dynamic" 
                                ValidationGroup="AddForm" />
                            <asp:CompareValidator ID="cvDates" runat="server"
                                ControlToCompare="txtStartDate"
                                ControlToValidate="txtEndDate"
                                Operator="GreaterThanEqual"
                                Type="Date"
                                ErrorMessage="End date must be on or after start date"
                                CssClass="text-danger small"
                                Display="Dynamic"
                                ValidationGroup="AddForm" />
                        </div>
                    </div>
                    
                    <div class="mb-3 form-check">
                        <asp:CheckBox ID="chkAllDay" runat="server" CssClass="form-check-input" />
                        <label class="form-check-label fw-semibold">
                            All Day Event
                        </label>
                        <br />
                        <small class="text-muted">Check this if the event lasts the entire day(s)</small>
                    </div>
                    
                    <asp:Label ID="lblMessage" runat="server" Visible="false" CssClass="alert alert-info" />
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <asp:Button ID="btnSave" runat="server" Text="💾 Save Event"
                        CssClass="btn btn-success" OnClick="btnSave_Click" ValidationGroup="AddForm" />
                </div>
            </div>
        </div>
    </div>

    <!-- ===== EDIT EVENT MODAL ===== -->
    <div class="modal fade" id="editEventModal" tabindex="-1" data-bs-backdrop="static" data-bs-keyboard="false">
        <div class="modal-dialog modal-lg-custom">
            <div class="modal-content">
                <div class="modal-header bg-warning">
                    <h5 class="modal-title">
                        <i class="bi bi-pencil-square"></i> Edit Event
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <asp:HiddenField ID="hfEditEventId" runat="server" />
                    
                    <div class="mb-3">
                        <label class="form-label fw-semibold">
                            Event Title <span class="text-danger">*</span>
                        </label>
                        <asp:TextBox ID="txtEditTitle" runat="server" CssClass="form-control" MaxLength="200" />
                        <asp:RequiredFieldValidator ID="rfvEditTitle" runat="server"
                            ControlToValidate="txtEditTitle" 
                            ErrorMessage="Title is required."
                            CssClass="text-danger small" 
                            Display="Dynamic" 
                            ValidationGroup="EditForm" />
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label fw-semibold">
                            Subject <span class="text-danger">*</span>
                        </label>
                        <asp:DropDownList ID="ddlEditSubject" runat="server" CssClass="form-select">
                            <asp:ListItem Text="-- Select Subject --" Value="" />
                        </asp:DropDownList>
                        <asp:RequiredFieldValidator ID="rfvEditSubject" runat="server"
                            ControlToValidate="ddlEditSubject"
                            InitialValue=""
                            ErrorMessage="Please select a subject"
                            CssClass="text-danger small"
                            Display="Dynamic"
                            ValidationGroup="EditForm" />
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Event Type</label>
                        <asp:DropDownList ID="ddlEditEventType" runat="server" CssClass="form-select">
                            <asp:ListItem Text="📌 General" Value="General" />
                            <asp:ListItem Text="🎉 Holiday" Value="Holiday" />
                            <asp:ListItem Text="📝 Exam" Value="Exam" />
                            <asp:ListItem Text="📚 Assignment" Value="Assignment" />
                        </asp:DropDownList>
                    </div>
                    
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label fw-semibold">
                                Start Date <span class="text-danger">*</span>
                            </label>
                            <asp:TextBox ID="txtEditStartDate" runat="server" CssClass="form-control" 
                                TextMode="Date" />
                            <asp:RequiredFieldValidator ID="rfvEditStart" runat="server"
                                ControlToValidate="txtEditStartDate" 
                                ErrorMessage="Start date is required."
                                CssClass="text-danger small" 
                                Display="Dynamic" 
                                ValidationGroup="EditForm" />
                        </div>
                        
                        <div class="col-md-6 mb-3">
                            <label class="form-label fw-semibold">
                                End Date <span class="text-danger">*</span>
                            </label>
                            <asp:TextBox ID="txtEditEndDate" runat="server" CssClass="form-control" 
                                TextMode="Date" />
                            <asp:RequiredFieldValidator ID="rfvEditEnd" runat="server"
                                ControlToValidate="txtEditEndDate" 
                                ErrorMessage="End date is required."
                                CssClass="text-danger small" 
                                Display="Dynamic" 
                                ValidationGroup="EditForm" />
                            <asp:CompareValidator ID="cvEditDates" runat="server"
                                ControlToCompare="txtEditStartDate"
                                ControlToValidate="txtEditEndDate"
                                Operator="GreaterThanEqual"
                                Type="Date"
                                ErrorMessage="End date must be on or after start date"
                                CssClass="text-danger small"
                                Display="Dynamic"
                                ValidationGroup="EditForm" />
                        </div>
                    </div>
                    
                    <div class="mb-3 form-check">
                        <asp:CheckBox ID="chkEditAllDay" runat="server" CssClass="form-check-input" />
                        <label class="form-check-label fw-semibold">
                            All Day Event
                        </label>
                    </div>
                    
                    <asp:Label ID="lblEditMessage" runat="server" Visible="false" CssClass="alert alert-info" />
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <asp:Button ID="btnUpdate" runat="server" Text="🔄 Update Event"
                        CssClass="btn btn-primary" OnClick="btnUpdate_Click" ValidationGroup="EditForm" />
                </div>
            </div>
        </div>
    </div>

    <!-- Hidden field to control modal reopen after postback -->
    <asp:HiddenField ID="hfReopenModal" runat="server" Value="" />
    
    <!-- Loading Overlay -->
    <div id="loadingOverlay" class="loading-overlay">
        <div class="text-center text-white mt-5">
            <div class="spinner-border" role="status">
                <span class="visually-hidden">Loading...</span>
            </div>
            <div>Processing...</div>
        </div>
    </div>

    <!-- JavaScript for modal handling -->
    <script type="text/javascript">
        // Function to show loading overlay
        function showLoading() {
            var overlay = document.getElementById('loadingOverlay');
            if (overlay) overlay.style.display = 'block';
        }

        // Function to hide loading overlay
        function hideLoading() {
            var overlay = document.getElementById('loadingOverlay');
            if (overlay) overlay.style.display = 'none';
        }

        // Handle modal reopening after postback
        window.addEventListener('DOMContentLoaded', function () {
            var hfReopenModal = document.getElementById('<%= hfReopenModal.ClientID %>');
            if (hfReopenModal) {
                var target = hfReopenModal.value;
                if (target && target !== '') {
                    var modalElement = document.getElementById(target);
                    if (modalElement) {
                        var modal = new bootstrap.Modal(modalElement);
                        modal.show();
                    }
                }
            }
        });

        // Clean modal backdrop when closed
        document.addEventListener('hidden.bs.modal', function (event) {
            var backdrops = document.querySelectorAll('.modal-backdrop');
            backdrops.forEach(function (backdrop) {
                backdrop.remove();
            });
        });
    </script>
    
    <!-- Validation Summaries -->
    <asp:ValidationSummary ID="vsAddForm" runat="server" 
        ValidationGroup="AddForm" 
        ShowSummary="false" 
        ShowMessageBox="true" 
        HeaderText="Please correct the following errors:" />
    
    <asp:ValidationSummary ID="vsEditForm" runat="server" 
        ValidationGroup="EditForm" 
        ShowSummary="false" 
        ShowMessageBox="true"
        HeaderText="Please correct the following errors:" />
</asp:Content>