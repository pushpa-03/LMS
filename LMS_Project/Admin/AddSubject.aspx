<%@ Page Title="Subject Management" Language="C#" MasterPageFile="~/Admin/AdminMaster.master"
    AutoEventWireup="true" CodeBehind="AddSubject.aspx.cs"
    Inherits="LearningManagementSystem.Admin.AddSubject" %>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

<!-- 🔥 TOAST -->
<div class="toast-container position-fixed top-0 end-0 p-3">
    <div id="liveToast" class="toast align-items-center text-white bg-success border-0">
        <div class="d-flex">
            <div class="toast-body" id="toastMsg"></div>
            <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button>
        </div>
    </div>
</div>

<asp:HiddenField ID="hfSubjectId" runat="server" />

<!-- 🔥 HEADER -->
<div class="mb-4">

    <div class="d-flex flex-wrap justify-content-between align-items-center gap-3">

        <!-- LEFT -->
        <div>
            <h3 class="fw-bold">Subject Management</h3>

            <div class="text-muted small d-flex align-items-center gap-2">
                <span>Manage subjects efficiently</span>
                <span class="dot"></span>
                <span>Updated: <%= DateTime.Now.ToString("dd MMM yyyy, hh:mm tt") %></span>
            </div>
        </div>

        <!-- RIGHT -->
        <div class="d-flex align-items-center gap-2 flex-wrap">

            <!-- 🔍 SEARCH -->
            <div class="search-box">
                <i class="fa fa-search"></i>
                <asp:TextBox ID="txtSearch" runat="server"
                    CssClass="form-control m-1"
                    placeholder="Search subject..."
                    onkeyup="filterTable()" />
            </div>

            <!-- 🔁 TOGGLE -->
            <asp:LinkButton ID="btnToggleView" runat="server"
                CssClass="btn btn-light rounded-pill btn-sm px-3"
                OnClick="btnToggleView_Click">
                <i class="fa fa-eye"></i> Toggle
            </asp:LinkButton>

            <!-- ➕ ADD -->
            <button type="button"
                class="btn btn-primary rounded-pill px-4 fw-semibold shadow-sm"
                onclick="openAddModal()">
                <i class="fa fa-plus"></i> Add
            </button>

        </div>

    </div>
</div>

<!-- 🔥 STATS -->
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

<!-- 🔥 TABLE -->
<div class="card shadow-sm border-0 rounded-4">
    <div class="table-responsive">

        <asp:GridView ID="gvSubjects" runat="server"
            CssClass="table table-hover align-middle modern-table"
            AutoGenerateColumns="false"
            OnRowCommand="gvSubjects_RowCommand">

            <HeaderStyle CssClass="table-header text-white" />

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

<!-- 🔥 MODAL -->
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
                        <asp:TextBox ID="txtSubjectCode" runat="server" CssClass="form-control" />
                    </div>

                    <div class="col-md-8">
                        <label>Subject Name *</label>
                        <asp:TextBox ID="txtSubjectName" runat="server" CssClass="form-control" />
                    </div>

                    <div class="col-md-6">
                        <label>Duration</label>
                        <asp:TextBox ID="txtDuration" runat="server" CssClass="form-control" />
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
</style>

<!-- 🔥 SEARCH -->
<script>
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
</script>

</asp:Content>