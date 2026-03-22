<%@ Page Title="Parent Management" Language="C#" 
MasterPageFile="~/Admin/AdminMaster.master"
AutoEventWireup="true"
CodeBehind="ParentManagement.aspx.cs"
Inherits="LearningManagementSystem.Admin.ParentManagement" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server" >
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

    <asp:HiddenField ID="hfParentUserId" runat="server" />
<asp:Label ID="lblMsg" runat="server" CssClass="fw-bold mb-2 d-block" />

<!-- HEADER -->
<!-- HEADER -->
<div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-3">

    <!-- LEFT -->
    <div>
        <h3 class="fw-bold mb-1">Parent Management</h3>
        <small class="text-muted">Manage parents & guardians</small>
        <span class="mx-2 text-muted">|</span>
        <small class="text-muted">
            Last updated: <%= DateTime.Now.ToString("dd MMM yyyy hh:mm tt") %>
        </small>
    </div>

    <!-- RIGHT -->
    <div class="d-flex align-items-center gap-2 flex-wrap">

        <!-- 🔍 SEARCH -->
        <div class="search-box">
            <asp:TextBox ID="txtSearch" runat="server"
                CssClass="form-control"
                placeholder="Search parents..."
                onkeyup="filterParents()" />
        </div>

        <!-- 👁 FILTER -->
        <asp:LinkButton ID="btnToggleView" runat="server"
            CssClass="btn btn-outline-dark rounded-pill px-3"
            OnClick="Filter_Click">
            👁 View Inactive
        </asp:LinkButton>

        <!-- ➕ ADD -->
        <button type="button"
            class="btn btn-primary rounded-pill px-4 fw-semibold shadow-sm"
            onclick="openCreateModal()">
            <i class="fa fa-plus"></i> Add Parent
        </button>

    </div>
</div>

<!-- STATS -->
<div class="row mb-4">

    <div class="col-md-3">
        <div class="card stat-card">
            <div class="card-body">
                <h6>Total</h6>
                <h3><%= TotalParents %></h3>
            </div>
        </div>
    </div>

    <div class="col-md-3">
        <div class="card stat-card bg-success text-white">
            <div class="card-body">
                <h6>Active</h6>
                <h3 class="stat-active"><%= ActiveParents %></h3>
            </div>
        </div>
    </div>

    <div class="col-md-3">
        <div class="card stat-card bg-warning">
            <div class="card-body">
                <h6>Inactive</h6>
                <h3 class="stat-inactive"><%= InactiveParents %></h3>
            </div>
        </div>
    </div>

    <div class="col-md-3">
        <div class="card stat-card bg-info text-white">
            <div class="card-body">
                <h6>Linked Students</h6>
                <h3><%= TotalLinks %></h3>
            </div>
        </div>
    </div>

</div>


<!-- TABLE -->
<div class="card shadow-sm rounded-4 border-0">
    <div class="table-responsive">

        <asp:GridView ID="gvParents" runat="server"
            CssClass="table table-hover modern-table"
            AutoGenerateColumns="false"
            OnRowCommand="gvParents_RowCommand">

            <HeaderStyle CssClass="table-header text-white" />

            <Columns>

                <asp:BoundField DataField="StudentName" HeaderText="Student"/>
                <asp:BoundField DataField="ParentName" HeaderText="Parent"/>
                <asp:BoundField DataField="Relation" HeaderText="Relation"/>
                <asp:BoundField DataField="Email" HeaderText="Email"/>
                <asp:BoundField DataField="ContactNo" HeaderText="Contact"/>

                
                <asp:TemplateField HeaderText="Actions">
                <ItemTemplate>

                    <!-- EDIT -->
                    <asp:LinkButton runat="server"
                        CommandName="EditRow"
                        CommandArgument='<%# Eval("ParentUserId") %>'
                        CssClass="action-btn edit">
                        <i class="fa fa-pen"></i>
                    </asp:LinkButton>

                    <!-- TOGGLE -->
                    <asp:LinkButton runat="server"
                        CommandName="Toggle"
                        CommandArgument='<%# Eval("ParentUserId") %>'
                        CssClass="action-btn toggle"
                        OnClientClick="return confirm('Do you what to change status?');">
                        <i class="fa fa-sync"></i>
                    </asp:LinkButton>

                    <!-- DELETE -->
                    <asp:LinkButton runat="server"
                        CommandName="DeleteRow"
                        CommandArgument='<%# Eval("ParentUserId") %>'
                        CssClass="action-btn delete"
                        OnClientClick="return confirm('Delete parent?');">
                        <i class="fa fa-trash"></i>
                    </asp:LinkButton>

                </ItemTemplate>
                </asp:TemplateField>

            </Columns>
        </asp:GridView>

    </div>
</div>


    <!-- CREATE MODAL -->
    <div class="modal fade" id="CreateModal">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">

                <div class="modal-header bg-primary text-white">
                    <h5>Add Parent</h5>
                     <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>

                <div class="modal-body">
                    <div class="row g-3">

                        <div class="col-md-6">
                            <label>Username*</label>
                            <asp:TextBox ID="txtUsername" runat="server" CssClass="form-control" />
                        </div>

                        <div class="col-md-6">
                            <label>Email*</label>
                            <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" />
                        </div>

                        <div class="col-md-6">
                            <label>Full Name*</label>
                            <asp:TextBox ID="txtFullName" runat="server" CssClass="form-control" />
                        </div>

                        <div class="col-md-6">
                            <label>Contact*</label>
                            <asp:TextBox ID="txtContact" runat="server" CssClass="form-control" />
                        </div>

                        <div class="col-md-6">
                            <label>Gender*</label>
                            <asp:DropDownList ID="ddlGender" runat="server" CssClass="form-select">
                                <asp:ListItem Text="Male" />
                                <asp:ListItem Text="Female" />
                            </asp:DropDownList>
                        </div>

                        <div class="col-md-6">
                            <label>DOB*</label>
                            <asp:TextBox ID="txtDOB" runat="server" TextMode="Date" CssClass="form-control"/>
                        </div>

                        <div class="col-md-12">
                            <label>Select Student(s)</label>
                            <asp:CheckBoxList
                            ID="lstStudents"
                            runat="server"
                            RepeatColumns="3"
                            CssClass="form-check">
                            </asp:CheckBoxList>
                        </div>

                        <div class="col-md-6">
                            <label>Relationship*</label>
                            <asp:DropDownList ID="ddlRelation" runat="server" CssClass="form-select">
                                <asp:ListItem Text="Father" />
                                <asp:ListItem Text="Mother" />
                                <asp:ListItem Text="Guardian" />
                            </asp:DropDownList>
                        </div>

                        <div class="col-md-6 mt-4">
                            <asp:CheckBox ID="chkPrimary" runat="server" 
                                Text="Primary Guardian" />
                        </div>

                    </div>
                </div>

                <div class="modal-footer">
                    <asp:Button ID="btnSave" runat="server"
                        Text="Save Parent"
                        CssClass="btn btn-primary"
                        OnClick="btnSave_Click" />
                </div>

            </div>
        </div>
    </div>

<style>
.table-header th {
    background: linear-gradient(135deg, #4f46e5, #6366f1) !important;
    color: white;
    padding: 14px !important;
}

.stat-card {
    border-radius: 16px;
    background: #f8fafc;
    border: 1px solid #e2e8f0;
    transition: 0.3s;
}
.stat-card:hover {
    transform: translateY(-4px);
}

.stat-active { color: #16a34a; }
.stat-inactive { color: #dc2626; }

.modern-table tbody tr {
    transition: 0.2s;
}
.modern-table tbody tr:hover {
    background: #f1f5f9;
    transform: scale(1.01);
}

.action-btn {
    padding: 6px 10px;
    border-radius: 8px;
    margin-right: 5px;
    cursor: pointer;
}
.action-btn.edit { background: #dbeafe; }
.action-btn.toggle { background: #fef9c3; }
.action-btn.delete { background: #fee2e2; }
</style>

<script>
    function filterParents() {
        let val = document.getElementById("<%= txtSearch.ClientID %>").value.toLowerCase();

        document.querySelectorAll("#<%= gvParents.ClientID %> tbody tr")
            .forEach(r => {
                r.style.display = r.innerText.toLowerCase().includes(val) ? "" : "none";
            });
    }

    function toggleParent(btn, userId) {

        let row = btn.closest("tr");

        fetch('ParentManagement.aspx/ToggleParentAjax', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ userId: userId })
        })
            .then(res => res.json())
            .then(data => {

                let status = data.d;

                row.style.opacity = "0";
                setTimeout(() => row.remove(), 300);

                updateStats(status);
            });

        return false;
    }

    function updateStats(status) {

        let active = document.querySelector(".stat-active");
        let inactive = document.querySelector(".stat-inactive");

        let a = parseInt(active.innerText);
        let i = parseInt(inactive.innerText);

        if (status === "1") {
            active.innerText = a + 1;
            inactive.innerText = i - 1;
        } else {
            active.innerText = a - 1;
            inactive.innerText = i + 1;
        }
    }

    function openCreateModal() {

        document.getElementById('<%= hfParentUserId.ClientID %>').value = '';

       let modalEl = document.getElementById('CreateModal');
       let modal = new bootstrap.Modal(modalEl);
       modal.show();
   }

    

    function scrollToTable() {
        document.querySelector(".card").scrollIntoView({
            behavior: 'smooth'
        });
    }
</script>
</asp:Content>