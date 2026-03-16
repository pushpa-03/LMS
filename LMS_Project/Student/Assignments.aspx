<%@ Page Title="Assignments" Language="C#"
    MasterPageFile="~/Student/StudentMaster.Master"
    AutoEventWireup="true"
    CodeBehind="Assignments.aspx.cs"
    Inherits="LMS_Project.Student.Assignments" %>

<asp:Content ID="cHead" ContentPlaceHolderID="head" runat="server">
<style>

/* ── Page header ── */
.page-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 22px;
    flex-wrap: wrap;
    gap: 12px;
}
.page-header h4 {
    margin: 0; font-weight: 800;
    color: #1565c0; font-size: 20px;
}

/* ── Summary chips ── */
.summary-strip {
    display: flex; gap: 12px;
    margin-bottom: 22px;
    flex-wrap: wrap;
}
.summary-chip {
    background: #fff;
    border: 1.5px solid #e3e8f0;
    border-radius: 10px;
    padding: 10px 20px;
    display: flex; align-items: center; gap: 10px;
    box-shadow: 0 1px 4px rgba(0,0,0,.05);
    cursor: pointer;
    transition: all .2s;
    text-decoration: none;
}
.summary-chip:hover, .summary-chip.active {
    border-color: #1976d2;
    background: #e3f2fd;
}
.summary-chip .chip-icon {
    width: 36px; height: 36px;
    border-radius: 9px;
    display: flex; align-items: center; justify-content: center;
    font-size: 15px; flex-shrink: 0;
}
.summary-chip .chip-label {
    font-size: 11px; font-weight: 700;
    text-transform: uppercase;
    letter-spacing: .5px; color: #90a4ae;
}
.summary-chip .chip-value {
    font-size: 22px; font-weight: 800;
    color: #263238; line-height: 1;
}

/* ── Filter bar ── */
.filter-bar {
    background: #fff;
    border-radius: 12px;
    padding: 14px 18px;
    box-shadow: 0 1px 6px rgba(0,0,0,.06);
    display: flex;
    align-items: center;
    gap: 12px;
    margin-bottom: 20px;
    flex-wrap: wrap;
}
.filter-bar label {
    font-size: 12px; font-weight: 700;
    color: #546e7a; margin: 0;
    white-space: nowrap;
}
.filter-bar select {
    border: 1.5px solid #e3e8f0;
    border-radius: 8px;
    padding: 6px 12px;
    font-size: 13px;
    color: #263238;
    background: #f8fbff;
    outline: none;
    cursor: pointer;
}
.filter-bar select:focus { border-color: #1976d2; }
.btn-reset-filter {
    padding: 6px 16px;
    background: #f0f4f8;
    color: #546e7a;
    border: 1.5px solid #e3e8f0;
    border-radius: 8px;
    font-size: 12px;
    font-weight: 600;
    cursor: pointer;
    transition: all .2s;
}
.btn-reset-filter:hover { background: #e3e8f0; }

/* ── Assignment card ── */
.assignment-card {
    background: #fff;
    border-radius: 14px;
    box-shadow: 0 2px 8px rgba(0,0,0,.06);
    padding: 18px 20px;
    margin-bottom: 14px;
    display: flex;
    align-items: flex-start;
    gap: 16px;
    transition: transform .15s, box-shadow .15s;
    border-left: 4px solid #e3e8f0;
}
.assignment-card:hover {
    transform: translateY(-2px);
    box-shadow: 0 5px 16px rgba(0,0,0,.09);
}
.assignment-card.status-pending  { border-left-color: #fb8c00; }
.assignment-card.status-submitted{ border-left-color: #2e7d32; }
.assignment-card.status-overdue  { border-left-color: #c62828; }

.asg-icon {
    width: 46px; height: 46px;
    border-radius: 12px;
    display: flex; align-items: center; justify-content: center;
    font-size: 20px; flex-shrink: 0;
}
.icon-pending   { background: #fff3e0; color: #fb8c00; }
.icon-submitted { background: #e8f5e9; color: #2e7d32; }
.icon-overdue   { background: #ffebee; color: #c62828; }

.asg-body { flex: 1; min-width: 0; }
.asg-title {
    font-size: 15px; font-weight: 800;
    color: #1a237e; margin-bottom: 5px;
}
.asg-subject {
    font-size: 12px; color: #1976d2;
    font-weight: 600; margin-bottom: 8px;
}
.asg-desc {
    font-size: 12px; color: #78909c;
    margin-bottom: 10px;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
}
.asg-meta {
    display: flex; gap: 14px; flex-wrap: wrap;
    font-size: 12px; color: #90a4ae;
}
.asg-meta span { display: flex; align-items: center; gap: 4px; }
.asg-meta i { color: #1976d2; }

.asg-right {
    display: flex; flex-direction: column;
    align-items: flex-end; gap: 10px;
    flex-shrink: 0;
}

/* Status badges */
.badge-pending   { background: #fff3e0; color: #e65100;
                   padding: 4px 12px; border-radius: 20px;
                   font-size: 11px; font-weight: 700;
                   border: 1.5px solid #ffcc80; }
.badge-submitted { background: #e8f5e9; color: #2e7d32;
                   padding: 4px 12px; border-radius: 20px;
                   font-size: 11px; font-weight: 700;
                   border: 1.5px solid #a5d6a7; }
.badge-overdue   { background: #ffebee; color: #c62828;
                   padding: 4px 12px; border-radius: 20px;
                   font-size: 11px; font-weight: 700;
                   border: 1.5px solid #ef9a9a; }

/* Due date urgency */
.due-normal  { font-size: 12px; color: #78909c; }
.due-soon    { font-size: 12px; color: #e65100; font-weight: 700; }
.due-overdue { font-size: 12px; color: #c62828; font-weight: 700; }

/* Submit button */
.btn-submit-asg {
    padding: 6px 16px;
    background: linear-gradient(135deg, #1565c0, #1976d2);
    color: #fff; border: none;
    border-radius: 8px; font-size: 12px;
    font-weight: 700; cursor: pointer;
    transition: opacity .2s;
}
.btn-submit-asg:hover { opacity: .88; }

/* Marks chip */
.marks-chip {
    background: #e3f2fd; color: #1565c0;
    padding: 3px 10px; border-radius: 8px;
    font-size: 11px; font-weight: 700;
}
.marks-obtained {
    background: #e8f5e9; color: #2e7d32;
    padding: 3px 10px; border-radius: 8px;
    font-size: 11px; font-weight: 700;
}

/* ── Submit modal ── */
.modal-header-blue {
    background: linear-gradient(135deg, #1565c0, #1976d2);
    color: #fff; padding: 16px 20px;
    border-radius: 14px 14px 0 0;
}
.modal-header-blue .btn-close { filter: invert(1); }
.modal-asg-info {
    background: #f0f4f8;
    border-radius: 10px;
    padding: 12px 16px;
    margin-bottom: 16px;
    font-size: 13px;
}
.modal-asg-info .asg-info-title {
    font-weight: 800; color: #1565c0;
    font-size: 15px; margin-bottom: 6px;
}
.modal-asg-info .asg-info-row {
    display: flex; gap: 16px;
    font-size: 12px; color: #546e7a;
    flex-wrap: wrap;
}

/* ── Empty state ── */
.empty-state {
    background: #fff;
    border-radius: 14px;
    box-shadow: 0 2px 8px rgba(0,0,0,.06);
    padding: 60px 30px;
    text-align: center;
    color: #90a4ae;
}
.empty-state i { font-size: 56px; color: #cfd8dc; display: block; margin-bottom: 16px; }
.empty-state h5 { color: #546e7a; font-weight: 700; }
.empty-state p  { font-size: 13px; margin: 0; }

</style>
</asp:Content>

<asp:Content ID="cBody" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<%-- Hidden fields --%>
<asp:HiddenField ID="hfAssignmentId"   runat="server" Value="0" />
<asp:HiddenField ID="hfAssignmentTitle" runat="server" />

<%-- Alert message --%>
<asp:Label ID="lblMsg" runat="server" Visible="false" CssClass="alert d-block mb-3" />

<%-- ══ PAGE HEADER ══ --%>
<div class="page-header">
    <h4><i class="fas fa-tasks me-2"></i>Assignments</h4>
</div>

<%-- ══ SUMMARY CHIPS ══ --%>
<div class="summary-strip">
    <div class="summary-chip" onclick="filterByStatus('All')">
        <div class="chip-icon" style="background:#e3f2fd; color:#1976d2;">
            <i class="fas fa-tasks"></i>
        </div>
        <div>
            <div class="chip-label">Total</div>
            <div class="chip-value"><asp:Label ID="lblTotal" runat="server" Text="0" /></div>
        </div>
    </div>
    <div class="summary-chip" onclick="filterByStatus('Pending')">
        <div class="chip-icon" style="background:#fff3e0; color:#fb8c00;">
            <i class="fas fa-clock"></i>
        </div>
        <div>
            <div class="chip-label">Pending</div>
            <div class="chip-value"><asp:Label ID="lblPending" runat="server" Text="0" /></div>
        </div>
    </div>
    <div class="summary-chip" onclick="filterByStatus('Submitted')">
        <div class="chip-icon" style="background:#e8f5e9; color:#2e7d32;">
            <i class="fas fa-check-circle"></i>
        </div>
        <div>
            <div class="chip-label">Submitted</div>
            <div class="chip-value"><asp:Label ID="lblSubmitted" runat="server" Text="0" /></div>
        </div>
    </div>
    <div class="summary-chip" onclick="filterByStatus('Overdue')">
        <div class="chip-icon" style="background:#ffebee; color:#c62828;">
            <i class="fas fa-exclamation-triangle"></i>
        </div>
        <div>
            <div class="chip-label">Overdue</div>
            <div class="chip-value"><asp:Label ID="lblOverdue" runat="server" Text="0" /></div>
        </div>
    </div>
</div>

<%-- ══ FILTER BAR ══ --%>
<div class="filter-bar">
    <label><i class="fas fa-filter me-1"></i>Filter:</label>

    <label>Subject</label>
    <asp:DropDownList ID="ddlSubjectFilter" runat="server"
        AutoPostBack="true"
        OnSelectedIndexChanged="ddlFilter_Changed" />

    <label>Status</label>
    <asp:DropDownList ID="ddlStatusFilter" runat="server"
        AutoPostBack="true"
        OnSelectedIndexChanged="ddlFilter_Changed">
        <asp:ListItem Text="All"       Value="All" />
        <asp:ListItem Text="Pending"   Value="Pending" />
        <asp:ListItem Text="Submitted" Value="Submitted" />
        <asp:ListItem Text="Overdue"   Value="Overdue" />
    </asp:DropDownList>

    <asp:LinkButton ID="btnResetFilter" runat="server"
        OnClick="btnResetFilter_Click"
        CssClass="btn-reset-filter">
        <i class="fas fa-undo me-1"></i>Reset
    </asp:LinkButton>
</div>

<%-- ══ ASSIGNMENT LIST ══ --%>
<asp:Panel ID="pnlAssignments" runat="server">
    <asp:Repeater ID="rptAssignments" runat="server"
        OnItemCommand="rptAssignments_ItemCommand">
        <ItemTemplate>

            <div class='assignment-card status-<%# Eval("Status")?.ToString().ToLower() %>'>

                <%-- Left icon --%>
                <div class='asg-icon icon-<%# Eval("Status")?.ToString().ToLower() %>'>
                    <%# Eval("Status")?.ToString() == "Submitted"
                        ? "<i class='fas fa-check'></i>"
                        : Eval("Status")?.ToString() == "Overdue"
                            ? "<i class='fas fa-exclamation-triangle'></i>"
                            : "<i class='fas fa-file-alt'></i>" %>
                </div>

                <%-- Body --%>
                <div class="asg-body">
                    <div class="asg-title"><%# Eval("Title") %></div>
                    <div class="asg-subject">
                        <i class="fas fa-book me-1"></i>
                        <%# Eval("SubjectCode") %> — <%# Eval("SubjectName") %>
                    </div>
                    <div class="asg-desc"><%# Eval("Description") %></div>
                    <div class="asg-meta">
                        <span>
                            <i class="fas fa-calendar-alt"></i>
                            Due: <%# Eval("DueDate", "{0:dd MMM yyyy}") %>
                        </span>
                        <span>
                            <i class="fas fa-star"></i>
                            <%# Eval("MaxMarks") %> marks
                        </span>
                        <%# Eval("Status")?.ToString() == "Submitted"
                            ? "<span><i class='fas fa-clock'></i>Submitted: " + Eval("SubmittedOn", "{0:dd MMM yyyy}") + "</span>"
                            : "" %>
                    </div>
                </div>

                <%-- Right side --%>
                <div class="asg-right">

                    <%-- Status badge --%>
                    <%# Eval("Status")?.ToString() == "Submitted"
                        ? "<span class='badge-submitted'><i class='fas fa-check me-1'></i>Submitted</span>"
                        : Eval("Status")?.ToString() == "Overdue"
                            ? "<span class='badge-overdue'><i class='fas fa-exclamation-triangle me-1'></i>Overdue</span>"
                            : "<span class='badge-pending'><i class='fas fa-clock me-1'></i>Pending</span>" %>

                    <%-- Due countdown --%>
                    <%# GetDueLabel(Convert.ToInt32(Eval("DaysRemaining")),
                                   Eval("Status")?.ToString()) %>

                    <%-- Marks --%>
                    <%# Eval("Status")?.ToString() == "Submitted" && Eval("MarksObtained") != DBNull.Value
                        ? "<span class='marks-obtained'><i class='fas fa-star me-1'></i>" + Eval("MarksObtained") + " / " + Eval("MaxMarks") + "</span>"
                        : "<span class='marks-chip'>" + Eval("MaxMarks") + " marks</span>" %>

                    <%-- Submit button (only for Pending) --%>
                    <%# Eval("Status")?.ToString() == "Pending"
                        ? ""  : "" %>

                    <asp:LinkButton runat="server"
                        CommandName="Submit"
                        CommandArgument='<%# Eval("AssignmentId") + "|" + Eval("Title") %>'
                        CssClass='btn-submit-asg<%# Eval("Status")?.ToString() != "Pending" ? " d-none" : "" %>'>
                        <i class="fas fa-upload me-1"></i>Submit
                    </asp:LinkButton>

                </div>
            </div>

        </ItemTemplate>
    </asp:Repeater>
</asp:Panel>

<%-- ══ EMPTY STATE ══ --%>
<asp:Panel ID="pnlEmpty" runat="server" Visible="false">
    <div class="empty-state">
        <i class="fas fa-tasks"></i>
        <h5>No Assignments Found</h5>
        <p id="emptyMsg" runat="server">No assignments have been posted yet.</p>
    </div>
</asp:Panel>

<%-- ══ SUBMIT MODAL ══ --%>
<div class="modal fade" id="submitModal" tabindex="-1">
    <div class="modal-dialog modal-md">
        <div class="modal-content border-0" style="border-radius:14px; overflow:hidden;">

            <div class="modal-header-blue d-flex align-items-center justify-content-between">
                <h5 class="mb-0 fw-bold">
                    <i class="fas fa-upload me-2"></i>Submit Assignment
                </h5>
                <button type="button" class="btn-close btn-close-white"
                    data-bs-dismiss="modal"></button>
            </div>

            <div class="modal-body p-4">

                <%-- Assignment info summary --%>
                <div class="modal-asg-info">
                    <div class="asg-info-title" id="modalAsgTitle">—</div>
                    <div class="asg-info-row">
                        <span><i class="fas fa-book me-1 text-primary"></i>
                            <span id="modalAsgSubject">—</span></span>
                        <span><i class="fas fa-calendar me-1 text-primary"></i>
                            Due: <span id="modalAsgDue">—</span></span>
                        <span><i class="fas fa-star me-1 text-primary"></i>
                            <span id="modalAsgMarks">—</span> marks</span>
                    </div>
                </div>

                <%-- File upload --%>
                <div class="mb-3">
                    <label class="fw-bold mb-1" style="font-size:13px;">
                        Upload Your Work <span class="text-danger">*</span>
                    </label>
                    <asp:FileUpload ID="fuAssignment" runat="server"
                        CssClass="form-control" />
                    <div class="text-muted mt-1" style="font-size:11px;">
                        Accepted: PDF, DOC, DOCX, ZIP (max 10 MB)
                    </div>
                </div>

                <%-- Remarks --%>
                <div class="mb-3">
                    <label class="fw-bold mb-1" style="font-size:13px;">
                        Remarks / Notes (optional)
                    </label>
                    <asp:TextBox ID="txtRemarks" runat="server"
                        CssClass="form-control"
                        TextMode="MultiLine" Rows="3"
                        placeholder="Any notes for your teacher..." />
                </div>

                <asp:Label ID="lblModalMsg" runat="server"
                    Visible="false" CssClass="alert d-block" />

            </div>

            <div class="modal-footer border-0 pt-0 pb-3 px-4">
                <button type="button" class="btn btn-light border"
                    data-bs-dismiss="modal" style="border-radius:8px;">
                    Cancel
                </button>
                <asp:Button ID="btnConfirmSubmit" runat="server"
                    Text="Submit Assignment"
                    CssClass="btn-submit-asg ms-2"
                    style="padding:8px 22px;"
                    OnClick="btnConfirmSubmit_Click"
                    OnClientClick="return validateSubmitForm();" />
            </div>

        </div>
    </div>
</div>

<script>

// ── Open submit modal with assignment info ────────────────
function openSubmitModal(id, title, subject, due, marks) {
    document.getElementById('<%= hfAssignmentId.ClientID %>').value = id;
    document.getElementById('modalAsgTitle').innerText   = title;
    document.getElementById('modalAsgSubject').innerText = subject;
    document.getElementById('modalAsgDue').innerText     = due;
    document.getElementById('modalAsgMarks').innerText   = marks;

    // Clear previous
    document.getElementById('<%= txtRemarks.ClientID %>').value = '';
    var modalMsg = document.getElementById('<%= lblModalMsg.ClientID %>');
    if (modalMsg) modalMsg.style.display = 'none';

    new bootstrap.Modal(document.getElementById('submitModal')).show();
}

// ── Filter chips click → set dropdown + postback ──────────
function filterByStatus(status) {
    var ddl = document.getElementById('<%= ddlStatusFilter.ClientID %>');
    if (ddl) {
        ddl.value = status;
        ddl.dispatchEvent(new Event('change'));
        __doPostBack('<%= ddlStatusFilter.ClientID %>', '');
    }
}

// ── Validate before submit ────────────────────────────────
function validateSubmitForm() {
    var fu = document.getElementById('<%= fuAssignment.ClientID %>');
    if (!fu || !fu.value) {
        alert('Please select a file to upload.');
        return false;
    }
    var ext = fu.value.split('.').pop().toLowerCase();
    var allowed = ['pdf', 'doc', 'docx', 'zip'];
    if (allowed.indexOf(ext) === -1) {
        alert('Only PDF, DOC, DOCX, ZIP files are allowed.');
        return false;
    }
    return true;
}

</script>

</asp:Content>
