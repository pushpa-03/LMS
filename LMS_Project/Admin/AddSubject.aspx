<%--<%@ Page Title="Subject Management" Language="C#" MasterPageFile="~/Admin/AdminMaster.master"
    AutoEventWireup="true" CodeBehind="AddSubject.aspx.cs"
    Inherits="LearningManagementSystem.Admin.AddSubject" %>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">


<div class="toast-container position-fixed top-0 end-0 p-3">
    <div id="liveToast" class="toast align-items-center text-white bg-success border-0">
        <div class="d-flex">
            <div class="toast-body" id="toastMsg"></div>
            <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button>
        </div>
    </div>
</div>

<asp:HiddenField ID="hfSubjectId" runat="server" />


<div class="mb-4">

    <div class="d-flex flex-wrap justify-content-between align-items-center gap-3">


        <div>
            <h3 class="fw-bold">Subject Management</h3>

            <div class="text-muted small d-flex align-items-center gap-2">
                <span>Manage subjects efficiently</span>
                <span class="dot"></span>
                <span>Updated: <%= DateTime.Now.ToString("dd MMM yyyy, hh:mm tt") %></span>
            </div>
        </div>

        <div class="d-flex align-items-center gap-2 flex-wrap">

      
            <div class="search-box">
                <i class="fa fa-search"></i>
                <asp:TextBox ID="txtSearch" runat="server"
                    CssClass="form-control m-1"
                    placeholder="Search subject..."
                    onkeyup="filterTable()" />
            </div>

       
            <asp:LinkButton ID="btnToggleView" runat="server"
                CssClass="btn btn-light rounded-pill btn-sm px-3"
                OnClick="btnToggleView_Click">
                <i class="fa fa-eye"></i> Toggle
            </asp:LinkButton>

     
            <button type="button"
                class="btn btn-primary rounded-pill px-4 fw-semibold shadow-sm"
                onclick="openAddModal()">
                <i class="fa fa-plus"></i> Add
            </button>

        </div>

    </div>
</div>


<div class="row g-3 mb-4">

    <div class="col-md-4">
        <div class="card stat-card d-flex flex-row align-items-center p-3">
            <div class="icon-box bg-dark me-3">
                <i class="fa fa-book"></i>
            </div>
            <div>
                <small class="text-muted">Total</small>
                <h4><asp:Label ID="lblTotal" runat="server" /></h4>
            </div>
        </div>
    </div>

    <div class="col-md-4">
        <div class="card stat-card d-flex flex-row align-items-center p-3">
            <div class="icon-box bg-success me-3">
                <i class="fa fa-check"></i>
            </div>
            <div>
                <small class="text-muted">Active</small>
                <h4><asp:Label ID="lblActive" runat="server" /></h4>
            </div>
        </div>
    </div>

    <div class="col-md-4">
        <div class="card stat-card d-flex flex-row align-items-center p-3">
            <div class="icon-box bg-secondary me-3">
                <i class="fa fa-ban"></i>
            </div>
            <div>
                <small class="text-muted">Inactive</small>
                <h4><asp:Label ID="lblInactive" runat="server" /></h4>
            </div>
        </div>
    </div>

</div>


<div class="card shadow-sm border-0 rounded-4">
    <div class="table-responsive">

        <asp:GridView ID="gvSubjects" runat="server"
            CssClass="table table-hover align-middle modern-table"
            AutoGenerateColumns="false"
            OnRowCommand="gvSubjects_RowCommand">

            <HeaderStyle CssClass="table-header text-white" />

            <EmptyDataTemplate>
                <div class="text-center p-4">
                    <i class="fa fa-book fa-2x text-muted mb-2"></i>
                    <p class="text-muted">
                        No Subjects added, click Add button to add new subjects
                    </p>
                </div>
            </EmptyDataTemplate>

            <Columns>

                <asp:BoundField DataField="SubjectCode" HeaderText="Code" />
                <asp:BoundField DataField="SubjectName" HeaderText="Subject Name" />
                <asp:BoundField DataField="Duration" HeaderText="Duration" />

                <asp:TemplateField HeaderText="Actions">
                    <ItemTemplate>

                        <asp:LinkButton runat="server"
                            CommandName="EditRow"
                            CommandArgument='<%# Eval("SubjectId") %>'
                            CssClass="action edit">
                            <i class="fa fa-edit"></i>
                        </asp:LinkButton>

                        <asp:LinkButton runat="server"
                            CommandName="Toggle"
                            CommandArgument='<%# Eval("SubjectId") %>'
                            CssClass="action toggle">
                            <i class="fa fa-sync"></i>
                        </asp:LinkButton>

                        <asp:LinkButton runat="server"
                            CommandName="DeleteRow"
                            CommandArgument='<%# Eval("SubjectId") %>'
                            CssClass="action delete"
                            OnClientClick="return confirm('Delete subject?');">
                            <i class="fa fa-trash"></i>
                        </asp:LinkButton>

                    </ItemTemplate>
                </asp:TemplateField>

            </Columns>

        </asp:GridView>

    </div>
</div>


<div class="modal fade" id="SubjectModal">
    <div class="modal-dialog modal-lg">
        <div class="modal-content rounded-4">

            <div class="modal-header bg-primary text-white">
                <h5>Add / Edit Subject</h5>
                <button class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>

            <div class="modal-body">
                <div class="row g-3">

                    <div class="col-md-4">
                        <label>Subject Code *</label>
                        <asp:TextBox ID="txtSubjectCode" runat="server" CssClass="form-control" OnClientClick="return validateForm();" />
                    </div>

                    <div class="col-md-8">
                        <label>Subject Name *</label>
                        <asp:TextBox ID="txtSubjectName" runat="server" CssClass="form-control" OnClientClick="return validateForm();" />
                    </div>

                    <div class="col-md-6">
                        <label>Duration</label>
                        <asp:TextBox ID="txtDuration" runat="server" CssClass="form-control" OnClientClick="return validateForm();" />
                    </div>

                    <div class="col-md-6">
                        <label>Status</label>
                        <asp:CheckBox ID="chkActive" runat="server" Checked="true" />
                    </div>

                    <div class="col-md-12">
                        <label>Description</label>
                        <asp:TextBox ID="txtDescription" runat="server"
                            CssClass="form-control" TextMode="MultiLine" Rows="2" />
                    </div>

                </div>
            </div>

            <div class="modal-footer">
                <button class="btn btn-light" data-bs-dismiss="modal">Cancel</button>

                <asp:Button ID="btnSave" runat="server"
                    Text="Save"
                    CssClass="btn btn-primary"
                    OnClick="btnSave_Click" />
            </div>

        </div>
    </div>
</div>

<!-- 🔥 STYLE -->
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
/* HEADER IMPROVEMENTS */
.search-box {
    position: relative;
}

.search-box i {
    position: absolute;
    top: 50%;
    left: 10px;
    transform: translateY(-50%);
    color: #999;
    font-size: 13px;
}

.search-box input {
    padding-left: 30px;
    border-radius: 8px;
    height: 34px;
    font-size: 13px;
}

/* Small dot separator */
.dot {
    width: 5px;
    height: 5px;
    background: #bbb;
    border-radius: 50%;
    display: inline-block;
}
.modal {
    z-index: 9999 !important;
}
.modal-backdrop {
    z-index: 9998 !important;
}
/* Compact buttons */
.btn-sm {
    height: 34px;
    display: flex;
    align-items: center;
    gap: 5px;
    font-size: 13px;
    border-radius: 8px;
}

/* Header card feel */
.card {
    backdrop-filter: blur(10px);
/*    background: linear-gradient(135deg, #ffffff, #f8f9fa);*/
}

.stat-card {
    border-radius: 16px;
    transition: .25s;
}
.stat-card:hover {
    transform: translateY(-5px);
    box-shadow: 0 12px 30px rgba(0,0,0,0.1);
}

.icon-box {
    width: 50px;
    height: 50px;
    border-radius: 12px;
    display: flex;
    align-items: center;
    justify-content: center;
    color: white;
    font-size: 18px;
}
.action {
    padding: 6px 10px;
    border-radius: 8px;
    margin-right: 5px;
    display: inline-block;
    transition: .2s;
}

.action.edit { background: #e0f2fe; }
.action.toggle { background: #fff3cd; }
.action.delete { background: #fee2e2; }

.action:hover {
    transform: scale(1.1);
}

.stat-card:hover {
    transform: translateY(-5px);
    box-shadow: 0 12px 25px rgba(0,0,0,0.1);
}
@media (max-width: 768px) {

    .modal-dialog {
        margin: 10px;
    }

    .modal-content {
        border-radius: 12px;
    }

    .row.g-3 > div {
        flex: 0 0 100%;
        max-width: 100%;
    }

    .search-box input {
        width: 100%;
    }

    .btn {
        width: 100%;
    }

    .stat-card {
        flex-direction: column;
        align-items: flex-start !important;
    }
}
</style>

<!-- 🔥 SEARCH -->
<script>
    function validateForm() {

        let code = document.getElementById('<%= txtSubjectCode.ClientID %>').value;
        let name = document.getElementById('<%= txtSubjectName.ClientID %>').value;
        let duration = document.getElementById('<%= txtDuration.ClientID %>').value;

        let codeRegex = /^[A-Za-z0-9]+$/;
        let nameRegex = /^[A-Za-z][A-Za-z0-9 ]*$/;
        let durationRegex = /^[0-9]+( min| hr)?$/;

        if (!codeRegex.test(code)) {
            showToast("Invalid Code (only letters & numbers)", false);
            return false;
        }

        if (!nameRegex.test(name)) {
            showToast("Name must start with letter", false);
            return false;
        }

        if (duration && !durationRegex.test(duration)) {
            showToast("Duration must be like 30 min or 2 hr", false);
            return false;
        }

        return true;
    }

    function filterTable() {
        let val = document.getElementById("<%= txtSearch.ClientID %>").value.toLowerCase();

    document.querySelectorAll("#<%= gvSubjects.ClientID %> tbody tr")
        .forEach(r => {
            r.style.display = r.innerText.toLowerCase().includes(val) ? "" : "none";
        });
    }

    function openModal() {
        new bootstrap.Modal(document.getElementById('SubjectModal')).show();
    }

    function openAddModal() {

        // Clear form before opening
        document.getElementById('<%= hfSubjectId.ClientID %>').value = "";

        document.getElementById('<%= txtSubjectCode.ClientID %>').value = "";
        document.getElementById('<%= txtSubjectName.ClientID %>').value = "";
        document.getElementById('<%= txtDuration.ClientID %>').value = "";
        document.getElementById('<%= txtDescription.ClientID %>').value = "";

        // Open modal
        var modal = new bootstrap.Modal(document.getElementById('SubjectModal'));
        modal.show();
    }

    function showToast(msg, success) {
        let t = document.getElementById('liveToast');
        let m = document.getElementById('toastMsg');

        m.innerText = msg;
        t.classList.remove('bg-success', 'bg-danger');
        t.classList.add(success ? 'bg-success' : 'bg-danger');

        new bootstrap.Toast(t).show();
    }
</script>

</asp:Content>--%>

<%-- -------------------------------------------------------------------------------------------------------------------------- --%>

<%@ Page Title="Subject Management" Language="C#" MasterPageFile="~/Admin/AdminMaster.master"
    AutoEventWireup="true" CodeBehind="AddSubject.aspx.cs"
    Inherits="LearningManagementSystem.Admin.AddSubject" %>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

<!-- ==================== TOAST ==================== -->
<div class="toast-container position-fixed p-3" style="top:70px;right:16px;z-index:9999;">
    <div id="liveToast" class="toast align-items-center border-0 shadow-lg" role="alert" aria-live="assertive" aria-atomic="true">
        <div class="d-flex">
            <div class="toast-body fw-semibold" id="toastMsg" style="font-size:14px;"></div>
            <button type="button" class="btn-close me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>
        </div>
    </div>
</div>

<!-- Hidden fields -->
<asp:HiddenField ID="hfSubjectId"    runat="server" />
<asp:HiddenField ID="hfIsSuperAdmin" runat="server" Value="false" />

<!-- ==================== PAGE HEADER ==================== -->
<div class="subject-page-header mb-4">
    <div class="d-flex flex-wrap justify-content-between align-items-center gap-3">
        <div>
            <h4 class="fw-bold mb-1 page-title-text">
                <i class="fa fa-book-open me-2 text-primary"></i>Subject Management
            </h4>
            <div class="text-muted small d-flex align-items-center flex-wrap gap-2">
                <span>Manage subjects efficiently</span>
                <span class="dot-sep"></span>
                <span>Last updated: <%= DateTime.Now.ToString("dd MMM yyyy, hh:mm tt") %></span>
                <asp:Label ID="lblSuperAdminBadge" runat="server" Visible="false"
                    CssClass="badge bg-warning text-dark ms-1">
                    <i class="fa fa-eye me-1"></i>View Only (SuperAdmin)
                </asp:Label>
            </div>
        </div>
        <div class="d-flex align-items-center gap-2 flex-wrap header-actions">
            <div class="search-wrapper">
                <i class="fa fa-search search-icon"></i>
                <asp:TextBox ID="txtSearch" runat="server"
                    CssClass="form-control search-input"
                    placeholder="Search subjects..."
                    onkeyup="filterTable(this.value)" />
            </div>
            <asp:LinkButton ID="btnToggleView" runat="server"
                CssClass="btn btn-outline-secondary btn-sm rounded-pill px-3"
                OnClick="btnToggleView_Click"
                ToolTip="Toggle between active and inactive subjects">
                <i class="fa fa-eye me-1"></i><span id="toggleBtnText">Show Inactive</span>
            </asp:LinkButton>
            <asp:Panel ID="pnlAddBtn" runat="server">
                <button type="button"
                    class="btn btn-primary rounded-pill px-4 fw-semibold shadow-sm add-btn"
                    onclick="openAddModal()"
                    title="Add new subject">
                    <i class="fa fa-plus me-1"></i>Add Subject
                </button>
            </asp:Panel>
        </div>
    </div>
</div>

<!-- ==================== STATS ==================== -->
<div class="row g-3 mb-4">
    <div class="col-6 col-md-4">
        <div class="stat-card card border-0 shadow-sm p-3 d-flex flex-row align-items-center gap-3">
            <div class="stat-icon-box bg-primary bg-opacity-10 text-primary">
                <i class="fa fa-book fa-lg"></i>
            </div>
            <div>
                <div class="stat-label text-muted small">Total Subjects</div>
                <div class="stat-value fw-bold fs-4"><asp:Label ID="lblTotal"    runat="server" Text="0" /></div>
            </div>
        </div>
    </div>
    <div class="col-6 col-md-4">
        <div class="stat-card card border-0 shadow-sm p-3 d-flex flex-row align-items-center gap-3">
            <div class="stat-icon-box bg-success bg-opacity-10 text-success">
                <i class="fa fa-check-circle fa-lg"></i>
            </div>
            <div>
                <div class="stat-label text-muted small">Active</div>
                <div class="stat-value fw-bold fs-4 text-success"><asp:Label ID="lblActive"   runat="server" Text="0" /></div>
            </div>
        </div>
    </div>
    <div class="col-6 col-md-4">
        <div class="stat-card card border-0 shadow-sm p-3 d-flex flex-row align-items-center gap-3">
            <div class="stat-icon-box bg-secondary bg-opacity-10 text-secondary">
                <i class="fa fa-ban fa-lg"></i>
            </div>
            <div>
                <div class="stat-label text-muted small">Inactive</div>
                <div class="stat-value fw-bold fs-4 text-secondary"><asp:Label ID="lblInactive" runat="server" Text="0" /></div>
            </div>
        </div>
    </div>
</div>

<!-- ==================== INFO BAR ==================== -->
<div class="d-flex align-items-center justify-content-between flex-wrap gap-2 mb-3">
    <div class="text-muted small">
        Showing <strong><asp:Label ID="lblRangeFrom" runat="server" Text="0" /></strong>
        –<strong><asp:Label ID="lblRangeTo" runat="server" Text="0" /></strong>
        of <strong><asp:Label ID="lblTotalCount" runat="server" Text="0" /></strong> subjects
    </div>
    <asp:Label ID="lblPageMeta" runat="server"
        style="font-size:12px;color:#94a3b8;font-weight:500" />
</div>

<!-- ==================== GRID TABLE ==================== -->
<div class="card shadow-sm border-0 rounded-4 overflow-hidden">
    <div class="table-responsive">
        <asp:GridView ID="gvSubjects" runat="server"
            CssClass="table table-hover align-middle modern-table mb-0"
            AutoGenerateColumns="false"
            OnRowCommand="gvSubjects_RowCommand"
            GridLines="None">
            <HeaderStyle CssClass="subject-table-header" />
            <RowStyle CssClass="subject-row" />
            <AlternatingRowStyle CssClass="subject-row-alt" />
            <EmptyDataTemplate>
                <div class="text-center py-5">
                    <i class="fa fa-book fa-3x text-muted mb-3 d-block"></i>
                    <p class="text-muted fw-semibold mb-1">No Subjects Found</p>
                    <p class="text-muted small">No subjects added yet. Click <strong>Add Subject</strong> to get started.</p>
                </div>
            </EmptyDataTemplate>
            <Columns>

                <asp:TemplateField HeaderText="#" ItemStyle-Width="50px">
                    <ItemTemplate>
                        <span class="text-muted small"><%# Container.DataItemIndex + 1 %></span>
                    </ItemTemplate>
                </asp:TemplateField>

                <asp:TemplateField HeaderText="Code">
                    <ItemTemplate>
                        <span class="badge-code"><%# Eval("SubjectCode") %></span>
                    </ItemTemplate>
                </asp:TemplateField>

                <asp:BoundField DataField="SubjectName" HeaderText="Subject Name" />

                <asp:TemplateField HeaderText="Duration">
                    <ItemTemplate>
                        <span class="text-muted small">
                            <i class="fa fa-clock me-1"></i><%# Eval("Duration") %>
                        </span>
                    </ItemTemplate>
                </asp:TemplateField>

                <asp:TemplateField HeaderText="Actions" ItemStyle-CssClass="action-cell">
                    <ItemTemplate>
                        <div class="d-flex gap-1 flex-nowrap action-btns-group">
                            <asp:LinkButton runat="server"
                                CommandName="EditRow"
                                CommandArgument='<%# Eval("SubjectId") %>'
                                CssClass="btn-action btn-edit"
                                ToolTip="Edit Subject">
                                <i class="fa fa-edit"></i>
                            </asp:LinkButton>
                            <asp:LinkButton runat="server"
                                CommandName="Toggle"
                                CommandArgument='<%# Eval("SubjectId") %>'
                                CssClass="btn-action btn-toggle"
                                ToolTip='<%# Convert.ToBoolean(Eval("IsActive")) ? "Deactivate" : "Activate" %>'>
                                <i class="fa fa-power-off"></i>
                            </asp:LinkButton>
                            <asp:LinkButton runat="server"
                                CommandName="DeleteRow"
                                CommandArgument='<%# Eval("SubjectId") %>'
                                CssClass="btn-action btn-delete"
                                ToolTip="Delete Subject"
                                OnClientClick="return confirmDelete(this);">
                                <i class="fa fa-trash"></i>
                            </asp:LinkButton>
                        </div>
                    </ItemTemplate>
                </asp:TemplateField>

            </Columns>
        </asp:GridView>
    </div>
</div>

<!-- ==================== PAGINATION ==================== -->
<asp:Panel ID="pnlPager" runat="server" Visible="false">
<div class="subj-pager-wrap">
    <div class="subj-pager-info">
        Page <strong><asp:Label ID="lblCurrentPage" runat="server" /></strong>
        of <strong><asp:Label ID="lblTotalPages"   runat="server" /></strong>
    </div>
    <div class="subj-pager-btns">

        <%-- First --%>
        <asp:LinkButton ID="btnFirst" runat="server" CssClass="spg-btn"
            CommandArgument="First" OnClick="Pager_Click">«</asp:LinkButton>

        <%-- Prev --%>
        <asp:LinkButton ID="btnPrev" runat="server" CssClass="spg-btn"
            CommandArgument="Prev"  OnClick="Pager_Click">‹</asp:LinkButton>

        <%-- Numbered buttons — built dynamically server-side --%>
        <asp:PlaceHolder ID="phPageNums" runat="server" />

        <%-- Next --%>
        <asp:LinkButton ID="btnNext" runat="server" CssClass="spg-btn"
            CommandArgument="Next"  OnClick="Pager_Click">›</asp:LinkButton>

        <%-- Last --%>
        <asp:LinkButton ID="btnLast" runat="server" CssClass="spg-btn"
            CommandArgument="Last"  OnClick="Pager_Click">»</asp:LinkButton>

    </div>
</div>
</asp:Panel>

<!-- ==================== ADD / EDIT MODAL ==================== -->
<div class="modal fade" id="SubjectModal" tabindex="-1"
     aria-labelledby="subjectModalLabel" aria-hidden="true"
     data-bs-backdrop="static" data-bs-keyboard="false">
    <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
        <div class="modal-content rounded-4 border-0 shadow-lg">
            <div class="modal-header modal-header-gradient text-white py-3">
                <div>
                    <h5 class="modal-title mb-0 fw-bold" id="subjectModalLabel">
                        <i class="fa fa-book me-2"></i>
                        <span id="modalTitleText">Add New Subject</span>
                    </h5>
                    <small class="opacity-75" id="modalSubtitle">Fill in the details below</small>
                </div>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body p-4">
                <div class="row g-3">

                    <div class="col-12 col-md-4">
                        <label class="form-label fw-semibold small">Subject Code <span class="text-danger">*</span></label>
                        <asp:TextBox ID="txtSubjectCode" runat="server"
                            CssClass="form-control" placeholder="e.g. CS101" MaxLength="20"
                            oninput="validateCode(this)" />
                        <div class="invalid-feedback" id="codeError">Only letters and numbers allowed.</div>
                        <div class="form-text text-muted" style="font-size:11px">Letters &amp; numbers only</div>
                    </div>

                    <div class="col-12 col-md-8">
                        <label class="form-label fw-semibold small">Subject Name <span class="text-danger">*</span></label>
                        <asp:TextBox ID="txtSubjectName" runat="server"
                            CssClass="form-control" placeholder="e.g. Data Structures and Algorithms" MaxLength="150"
                            oninput="validateName(this)" />
                        <div class="invalid-feedback" id="nameError">Subject name is required (min 3 characters).</div>
                    </div>

                    <div class="col-12 col-md-6">
                        <label class="form-label fw-semibold small">Duration</label>
                        <div class="input-group">
                            <asp:TextBox ID="txtDurationValue" runat="server"
                                CssClass="form-control" placeholder="e.g. 60" MaxLength="4"
                                type="number" oninput="validateDuration(this)" />
                            <asp:DropDownList ID="ddlDurationUnit" runat="server" CssClass="form-select" style="max-width:120px">
                                <asp:ListItem Value="hrs"   Text="Hours" />
                                <asp:ListItem Value="mins"  Text="Minutes" />
                                <asp:ListItem Value="days"  Text="Days" />
                                <asp:ListItem Value="weeks" Text="Weeks" />
                            </asp:DropDownList>
                        </div>
                        <div class="invalid-feedback d-block" id="durationError" style="display:none!important"></div>
                        <div class="form-text text-muted" style="font-size:11px">Numeric value only</div>
                    </div>

                    <div class="col-12 col-md-6">
                        <label class="form-label fw-semibold small d-block">Status</label>
                        <div class="form-check form-switch mt-2">
                            <asp:CheckBox ID="chkActive" runat="server" Checked="true" CssClass="form-check-input" />
                            <label class="form-check-label" for="<%= chkActive.ClientID %>">Active</label>
                        </div>
                    </div>

                    <div class="col-12">
                        <label class="form-label fw-semibold small">Description</label>
                        <asp:TextBox ID="txtDescription" runat="server"
                            CssClass="form-control" TextMode="MultiLine" Rows="3"
                            placeholder="Brief description (optional)..." MaxLength="500" />
                        <div class="form-text text-muted d-flex justify-content-between" style="font-size:11px">
                            <span>Optional</span>
                            <span id="descCount">0 / 500</span>
                        </div>
                    </div>

                </div>
            </div>
            <div class="modal-footer border-top-0 px-4 pb-4 pt-0 gap-2">
                <button type="button" class="btn btn-outline-secondary rounded-pill px-4" data-bs-dismiss="modal">
                    <i class="fa fa-times me-1"></i>Cancel
                </button>
                <asp:Button ID="btnSave" runat="server"
                    Text="Save Subject"
                    CssClass="btn btn-primary rounded-pill px-4 fw-semibold"
                    OnClick="btnSave_Click"
                    OnClientClick="return validateForm();" />
            </div>
        </div>
    </div>
</div>

<!-- ==================== STYLES ==================== -->
<style>
:root{
    --primary:#4f46e5;--primary-light:#eef2ff;
    --success:#16a34a;--danger:#dc2626;--warning:#d97706;
    --radius-lg:16px;--radius-md:10px;
    --shadow-sm:0 1px 3px rgba(0,0,0,.08),0 1px 2px rgba(0,0,0,.06);
    --shadow-md:0 4px 12px rgba(0,0,0,.1);
}

.page-title-text{font-size:clamp(16px,3vw,22px);}
.dot-sep{width:5px;height:5px;background:#cbd5e1;border-radius:50%;display:inline-block;}

/* Search */
.search-wrapper{position:relative;}
.search-icon{position:absolute;top:50%;left:10px;transform:translateY(-50%);color:#94a3b8;font-size:13px;z-index:2;}
.search-input{padding-left:32px;border-radius:8px;height:36px;font-size:13px;width:220px;}
@media(max-width:480px){.search-input{width:160px;}}

.add-btn{height:36px;font-size:13px;}

/* Stat Cards */
.stat-card{border-radius:var(--radius-lg);transition:transform .2s,box-shadow .2s;}
.stat-card:hover{transform:translateY(-3px);box-shadow:var(--shadow-md)!important;}
.stat-icon-box{width:44px;height:44px;border-radius:12px;display:flex;align-items:center;justify-content:center;flex-shrink:0;}

/* Table */
.subject-table-header th{
    background:linear-gradient(135deg,#4f46e5,#6366f1)!important;
    color:#fff!important;border:none!important;
    padding:14px 16px!important;font-weight:600;font-size:13px;
    letter-spacing:.3px;white-space:nowrap;
}
.modern-table td{padding:12px 16px;font-size:13px;vertical-align:middle;border-bottom:1px solid #f1f5f9!important;}
.subject-row{background:#fff;}
.subject-row-alt{background:#fafafa;}
.subject-row:hover td,.subject-row-alt:hover td{background:#f0f4ff;}
.badge-code{
    background:var(--primary-light);color:var(--primary);
    font-weight:700;font-size:11px;padding:3px 10px;
    border-radius:6px;font-family:monospace;letter-spacing:.5px;
}

/* Action Buttons */
.btn-action{
    width:30px;height:30px;border-radius:8px;border:none;
    display:inline-flex;align-items:center;justify-content:center;
    font-size:12px;cursor:pointer;transition:transform .15s,opacity .15s;text-decoration:none;
}
.btn-action:hover{transform:scale(1.12);opacity:.9;}
.btn-edit  {background:#dbeafe;color:#1d4ed8;}
.btn-toggle{background:#fef9c3;color:#92400e;}
.btn-delete{background:#fee2e2;color:#b91c1c;}
.action-cell{white-space:nowrap;}

/* Modal */
.modal-header-gradient{background:linear-gradient(135deg,#4f46e5,#6366f1);border-radius:16px 16px 0 0!important;}
.modal-content{border-radius:16px!important;}
.form-label{font-size:13px;margin-bottom:4px;}
.form-control,.form-select{font-size:13px;border-radius:8px;}
.form-control:focus,.form-select:focus{border-color:#4f46e5;box-shadow:0 0 0 3px rgba(79,70,229,.15);}

/* Toast */
.toast{min-width:280px;border-radius:12px!important;}
.toast.bg-success{background:#16a34a!important;color:#fff!important;}
.toast.bg-danger {background:#dc2626!important;color:#fff!important;}
.toast.bg-warning{background:#d97706!important;color:#fff!important;}
.toast-body{font-size:13px;}

/* ── PAGINATION ── */
.subj-pager-wrap{
    display:flex;align-items:center;justify-content:space-between;
    flex-wrap:wrap;gap:12px;margin-top:18px;padding:12px 18px;
    background:#fff;border:1px solid #e2e8f4;border-radius:12px;
    box-shadow:0 1px 3px rgba(15,23,42,.06),0 4px 12px rgba(15,23,42,.06);
}
.subj-pager-info{font-size:12px;color:#94a3b8;font-weight:500;}
.subj-pager-btns{display:flex;align-items:center;gap:4px;flex-wrap:wrap;}
.spg-btn{
    min-width:36px;height:36px;border-radius:8px;
    border:1.5px solid #e2e8f4;background:#fff;
    font-family:inherit;font-size:13px;font-weight:600;
    color:#334155;cursor:pointer;transition:all .18s;
    display:inline-flex;align-items:center;justify-content:center;
    padding:0 8px;text-decoration:none;
}
.spg-btn:hover:not(.active):not(.disabled){
    border-color:#4f46e5;color:#4f46e5;background:#eef2ff;
}
.spg-btn.active{
    background:#4f46e5;border-color:#4f46e5;
    color:#fff;box-shadow:0 4px 10px rgba(79,70,229,.3);
}
.spg-btn.disabled{opacity:.35;cursor:not-allowed;pointer-events:none;}
.spg-sep{
    width:36px;height:36px;display:inline-flex;
    align-items:center;justify-content:center;
    color:#94a3b8;font-size:13px;
}

/* Responsive */
@media(max-width:767px){
    .header-actions{width:100%;justify-content:flex-start;}
    .search-input{width:100%!important;flex:1;}
    .search-wrapper{flex:1;}
    .modern-table td,.subject-table-header th{font-size:12px;padding:10px 8px!important;}
    .stat-card{padding:10px!important;}
    .stat-value{font-size:20px!important;}
    .modal-dialog{margin:8px;}
    .btn-action{width:26px;height:26px;font-size:11px;}
    .subj-pager-wrap{flex-direction:column;align-items:flex-start;}
}
@media(max-width:400px){
    .modal-body{padding:1rem!important;}
    .modal-footer{padding:.75rem 1rem!important;}
    .spg-btn{min-width:30px;height:30px;font-size:12px;}
}

/* SuperAdmin hide */
body.superadmin-view .action-cell,
body.superadmin-view .subject-table-header th:last-child{display:none!important;}
body.superadmin-view #pnlAddBtn{display:none!important;}
</style>

<!-- ==================== SCRIPTS ==================== -->
<script>
    var isSuperAdmin = '<%= Session["Role"]?.ToString() %>' === 'SuperAdmin';
    if (isSuperAdmin) { document.body.classList.add('superadmin-view'); }

    function showToast(msg, type) {
        var t = document.getElementById('liveToast');
        var m = document.getElementById('toastMsg');
        m.innerHTML = '<i class="fa fa-' + (type === 'success' ? 'check-circle' : type === 'warning' ? 'exclamation-triangle' : 'times-circle') + ' me-2"></i>' + msg;
        t.className = 'toast align-items-center border-0 shadow-lg text-white bg-' + type;
        bootstrap.Toast.getOrCreateInstance(t, { delay: 4000 }).show();
    }

    function filterTable(val) {
        val = (val || '').toLowerCase().trim();
        document.querySelectorAll('#<%= gvSubjects.ClientID %> tbody tr').forEach(function (r) {
            r.style.display = r.innerText.toLowerCase().includes(val) ? '' : 'none';
        });
    }

    function openAddModal() {
        if (isSuperAdmin) { showToast('SuperAdmin has view-only access.', 'warning'); return; }
        document.getElementById('<%= hfSubjectId.ClientID %>').value = '';
        ['<%= txtSubjectCode.ClientID %>','<%= txtSubjectName.ClientID %>',
         '<%= txtDurationValue.ClientID %>','<%= txtDescription.ClientID %>']
            .forEach(function (id) { var el = document.getElementById(id); if (el) el.value = ''; });
        document.getElementById('modalTitleText').textContent = 'Add New Subject';
        document.getElementById('modalSubtitle').textContent = 'Fill in the details below';
        document.getElementById('descCount').textContent = '0 / 500';
        clearAllErrors();
        new bootstrap.Modal(document.getElementById('SubjectModal')).show();
    }

    function openModal() {
        clearAllErrors();
        document.getElementById('modalTitleText').textContent = 'Edit Subject';
        document.getElementById('modalSubtitle').textContent = 'Update the subject details';
        var desc = document.getElementById('<%= txtDescription.ClientID %>');
        document.getElementById('descCount').textContent = (desc ? desc.value.length : 0) + ' / 500';
        new bootstrap.Modal(document.getElementById('SubjectModal')).show();
    }

    function confirmDelete(btn) {
        if (isSuperAdmin) { showToast('SuperAdmin has view-only access.', 'warning'); return false; }
        return confirm('Are you sure you want to delete this subject?\n\nIf it is used elsewhere it cannot be deleted.');
    }

    function setInvalid(el, errId, msg) {
        el.classList.add('is-invalid'); el.classList.remove('is-valid');
        var err = document.getElementById(errId);
        if (err) { err.style.display = ''; err.textContent = msg; }
        return false;
    }
    function setValid(el) { el.classList.remove('is-invalid'); el.classList.add('is-valid'); }
    function clearAllErrors() {
        ['<%= txtSubjectCode.ClientID %>','<%= txtSubjectName.ClientID %>','<%= txtDurationValue.ClientID %>']
            .forEach(function (id) { var el = document.getElementById(id); if (el) { el.classList.remove('is-invalid', 'is-valid'); } });
    }

    function validateCode(el) {
        el.value = el.value.replace(/[^a-zA-Z0-9]/g, '');
        if (!el.value.trim()) return setInvalid(el, 'codeError', 'Subject code is required.');
        if (el.value.length < 2) return setInvalid(el, 'codeError', 'Code must be at least 2 characters.');
        setValid(el); return true;
    }
    function validateName(el) {
        if (!el.value.trim() || el.value.trim().length < 3)
            return setInvalid(el, 'nameError', 'Subject name must be at least 3 characters.');
        setValid(el); return true;
    }
    function validateDuration(el) {
        el.value = el.value.replace(/[^0-9]/g, '');
        var errEl = document.getElementById('durationError');
        if (el.value && parseInt(el.value) <= 0) {
            el.classList.add('is-invalid');
            if (errEl) { errEl.style.display = ''; errEl.textContent = 'Duration must be a positive number.'; }
            return false;
        }
        el.classList.remove('is-invalid');
        if (el.value) el.classList.add('is-valid');
        if (errEl) errEl.style.display = 'none';
        return true;
    }
    function validateForm() {
        if (isSuperAdmin) { showToast('SuperAdmin has view-only access.', 'warning'); return false; }
        var code = document.getElementById('<%= txtSubjectCode.ClientID %>');
        var name = document.getElementById('<%= txtSubjectName.ClientID %>');
        var dur = document.getElementById('<%= txtDurationValue.ClientID %>');
        var ok = true;
        if (!validateCode(code)) ok = false;
        if (!validateName(name)) ok = false;
        if (dur.value && !validateDuration(dur)) ok = false;
        if (!ok) showToast('Please fix the validation errors before saving.', 'danger');
        return ok;
    }

    document.addEventListener('DOMContentLoaded', function () {
        var desc = document.getElementById('<%= txtDescription.ClientID %>');
        if (desc) { desc.addEventListener('input', function () { document.getElementById('descCount').textContent = this.value.length + ' / 500'; }); }
    });

    function serverToast(msg, type) { showToast(msg, type); }
</script>

</asp:Content>

