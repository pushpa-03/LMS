<%@ Page Title="Academic Session"
    Language="C#"
    MasterPageFile="~/Admin/AdminMaster.Master"
    AutoEventWireup="true"
    CodeBehind="AcademicSession.aspx.cs"
    Inherits="LearningManagementSystem.Admin.AcademicSession" %>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

<!-- 🔥 TOAST -->
<div class="toast-container position-fixed top-0 end-0 p-3">
    <div id="liveToast" class="toast text-white bg-success border-0">
        <div class="d-flex">
            <div class="toast-body" id="toastMsg"></div>
            <button type="button" class="btn-close btn-close-white"
                data-bs-dismiss="toast"></button>
        </div>
    </div>
</div>

<asp:HiddenField ID="hfSessionId" runat="server" />

<!-- 🔥 HEADER -->
<div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-2">

    <div>
        <h3 class="fw-bold mb-1">Academic Sessions</h3>
        <small class="text-muted">
            Manage academic years, control active session & track history
        </small>
        <span>|</span>
        <small class="text-muted">
            Last updated: <%= DateTime.Now.ToString("dd MMM yyyy hh:mm tt") %>
        </small>
    </div>

    <div class="d-flex gap-2">

        <!-- 🔍 SEARCH -->
        <input type="text" id="txtSearch" class="form-control"
               placeholder="🔍 Search session..."
               onkeyup="filterTable()" />

        <!-- 🔥 QUICK ADD -->
        <button type="button"
            class="btn btn-success  btn-sm"
            onclick="autoGenerateSession()">
            ⚡ Auto Generate
        </button>

        <!-- ADD -->
        <%--<a href="#" data-bs-toggle="modal" data-bs-target="#SessionModal"
           class="btn btn-primary  px-4 fw-semibold">
            + Add Session
        </a>--%>

    </div>
</div>

<%-------Stat-----------%>
<div class="row g-3 mb-4">

    <div class="col-md-4">
        <div class="card border-0 shadow-sm stat-card d-flex flex-row align-items-center p-3">
            <div class="icon-box bg-dark me-3">
                <i class="fa fa-layer-group"></i>
            </div>
            <div>
                <h6 class="text-muted mb-1">Total Sessions</h6>
                <h4 class="fw-bold mb-0">
                    <asp:Label ID="lblTotal" runat="server" />
                </h4>
            </div>
        </div>
    </div>

    <div class="col-md-4">
        <div class="card border-0 shadow-sm stat-card d-flex flex-row align-items-center p-3">
            <div class="icon-box bg-success me-3">
                <i class="fa fa-star"></i>
            </div>
            <div>
                <h6 class="text-success mb-1">Current Session</h6>
                <h4 class="fw-bold mb-0">
                    <asp:Label ID="lblCurrent" runat="server" />
                </h4>
            </div>
        </div>
    </div>

    <div class="col-md-4">
        <div class="card border-0 shadow-sm stat-card d-flex flex-row align-items-center p-3">
            <div class="icon-box bg-secondary me-3">
                <i class="fa fa-history"></i>
            </div>
            <div>
                <h6 class="text-danger mb-1">Past Sessions</h6>
                <h4 class="fw-bold mb-0">
                    <asp:Label ID="lblPast" runat="server" />
                </h4>
            </div>
        </div>
    </div>

</div>
<!-- 🔥 TABLE -->
<div class="card shadow border-0 rounded-4">
    <div class="table-responsive">

        <asp:GridView ID="gvSessions" runat="server"
            CssClass="table table-hover mb-0 modern-table"
            AutoGenerateColumns="false"
            OnRowCommand="gvSessions_RowCommand">

            <EmptyDataTemplate>
                <div class="text-center p-5 text-muted">
                    <i class="fa fa-database fa-3x mb-3"></i>
                    <h5>No Sessions Found</h5>
                </div>
            </EmptyDataTemplate>

            <HeaderStyle CssClass="table-header text-white" />

            <Columns>

                <asp:BoundField DataField="SessionName" HeaderText="Session" />

                <asp:TemplateField HeaderText="Duration">
                    <ItemTemplate>
                        <%# Convert.ToDateTime(Eval("StartDate")).ToString("dd MMM yyyy") %>
                        -
                        <%# Convert.ToDateTime(Eval("EndDate")).ToString("dd MMM yyyy") %>
                    </ItemTemplate>
                </asp:TemplateField>

                <asp:TemplateField HeaderText="Status">
                    <ItemTemplate>
                        <span class='<%# (bool)Eval("IsCurrent") ? "badge bg-success" : "badge bg-secondary" %>'>
                            <%# (bool)Eval("IsCurrent") ? "Current" : "Inactive" %>
                        </span>
                    </ItemTemplate>
                </asp:TemplateField>

                <asp:TemplateField HeaderText="Actions">
                    <ItemTemplate>

                        <asp:LinkButton runat="server"
                            CommandName="EditRow"
                            ToolTip="Edit session"
                            Tip="Edit"
                            CommandArgument='<%# Eval("SessionId") %>'
                            CssClass="btn btn-sm btn-light me-1">
                            ✏
                        </asp:LinkButton>

                        <asp:LinkButton runat="server"
                            CommandName="SetCurrent"
                            ToolTip="Set Current"
                            CommandArgument='<%# Eval("SessionId") %>'
                            CssClass="btn btn-sm btn-warning me-1"
                            OnClientClick="return confirm('Set as current session?');">
                            ⭐
                        </asp:LinkButton>

                        <asp:LinkButton runat="server"
                            CommandName="DeleteRow"
                            ToolTip="Delete"
                            CommandArgument='<%# Eval("SessionId") %>'
                            CssClass="btn btn-sm btn-danger"
                            OnClientClick="return confirm('Delete session?');">
                            🗑
                        </asp:LinkButton>

                    </ItemTemplate>
                </asp:TemplateField>

            </Columns>

        </asp:GridView>

    </div>
</div>

<div class="modal fade" id="SessionModal">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content rounded-4 shadow-lg">

            <!-- HEADER -->
            <div class="modal-header bg-primary text-white">
                <h5 >Academic Session</h5>
                <button class="btn-close " data-bs-dismiss="modal"></button>
            </div>

            <!-- BODY -->
            <div class="modal-body">

                <!-- SESSION NAME -->
                <div class="mb-3">
                    <label class="fw-bold">Academic Year</label>
                    <asp:TextBox ID="txtSessionName" runat="server"
                        CssClass="form-control"
                        placeholder="e.g. 2024-2025" />
                    <small class="text-muted">
                        Format: StartYear-EndYear (auto-filled from dates)
                    </small>
                </div>

                <!-- DATE RANGE -->
                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label class="fw-bold">Start Date</label>
                        <asp:TextBox ID="txtStartDate" runat="server"
                            TextMode="Date"
                            CssClass="form-control"
                            onchange="autoFillSession()" />
                    </div>

                    <div class="col-md-6 mb-3">
                        <label class="fw-bold">End Date</label>
                        <asp:TextBox ID="txtEndDate" runat="server"
                            TextMode="Date"
                            CssClass="form-control"
                            onchange="validateDates()" />
                    </div>
                </div>

                <!-- STATUS -->
                <div class="form-check form-switch mt-2">
                    <asp:CheckBox ID="chkCurrent" runat="server" CssClass="form-check-input" />
                    <label class="form-check-label fw-semibold">
                        Set as Current Session
                    </label>
                </div>

                <div class="alert alert-info mt-3 small">
                    ℹ Setting this will automatically deactivate previous session.
                </div>

            </div>

            <!-- FOOTER -->
            <div class="modal-footer">
                <button class="btn btn-light" data-bs-dismiss="modal">Cancel</button>

                <asp:Button ID="btnSave" runat="server"
                    Text="Save Session"
                    CssClass="btn btn-primary px-4 rounded-pill"
                    OnClick="btnSave_Click" />
            </div>

        </div>
    </div>
</div>

<style>
    .table-header {
    background: linear-gradient(135deg, #4f46e5, #6366f1);
}
.table-header th {
    background: linear-gradient(135deg, #4f46e5, #6366f1) !important;
    color: white;
    border: none;
    padding: 14px !important;
    font-weight: 600;
    letter-spacing: 0.5px;
}
.stat-card {
    color: black;
    padding: 20px;
    border-radius: 14px;
    text-align: center;
    transition: .3s;
}
.stat-card:hover {
    transform: translateY(-5px);
}
.bg-gradient {
    background: linear-gradient(135deg,#4f46e5,#6366f1);
}

.stat-card {
    border-radius: 16px;
    transition: all .25s ease;
    cursor: pointer;
}

.stat-card:hover {
    transform: translateY(-5px) scale(1.02);
    box-shadow: 0 12px 30px rgba(0,0,0,0.15);
}

.icon-box {
    width: 50px;
    height: 50px;
    border-radius: 12px;
    display: flex;
    align-items: center;
    justify-content: center;
    color: white;
    font-size: 20px;
}
</style>

<script>

    // 🔥 AUTO GENERATE SESSION NAME
    function autoFillSession() {
        let start = document.getElementById("<%= txtStartDate.ClientID %>").value;

    if (start) {
        let year = new Date(start).getFullYear();
        document.getElementById("<%= txtSessionName.ClientID %>").value =
                year + "-" + (year + 1);
        }
    }

    // 🔥 VALIDATE DATES
    function validateDates() {
        let start = new Date(document.getElementById("<%= txtStartDate.ClientID %>").value);
    let end = new Date(document.getElementById("<%= txtEndDate.ClientID %>").value);

    if (end <= start) {
        alert("End date must be greater than Start date");
    }
}

// 🔥 AUTO GENERATE BUTTON
function autoGenerateSession() {
    let year = new Date().getFullYear();
    let name = year + "-" + (year + 1);

    document.getElementById("<%= txtSessionName.ClientID %>").value = name;
    document.getElementById("<%= txtStartDate.ClientID %>").value = year + "-06-01";
    document.getElementById("<%= txtEndDate.ClientID %>").value = (year + 1) + "-05-31";

        new bootstrap.Modal(document.getElementById('SessionModal')).show();
    }

</script>

</asp:Content>