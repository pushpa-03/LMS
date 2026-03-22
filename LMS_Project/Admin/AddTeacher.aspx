<%@ Page Title="Teachers" Language="C#" MasterPageFile="~/Admin/AdminMaster.master" AutoEventWireup="true" CodeBehind="AddTeacher.aspx.cs" Inherits="LearningManagementSystem.Admin.Teachers" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server" />

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">
    <asp:HiddenField ID="hfTeacherUserId" runat="server" />
    <asp:Label ID="lblMsg" runat="server" CssClass="fw-bold mb-2 d-block" />

    <div class="toast-container position-fixed top-0 end-0 p-3">
    <div id="liveToast" class="toast align-items-center text-white border-0">
        <div class="d-flex">
            <div class="toast-body" id="toastMsg"></div>
            <button type="button" class="btn-close btn-close-white me-2 m-auto"
                data-bs-dismiss="toast"></button>
        </div>
    </div>
</div>

   <!-- HEADER -->
<div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-3">

    <!-- LEFT -->
    <div>
        <h3 class="fw-bold mb-1">Teacher Management</h3>
        <small class="text-muted">Manage teachers efficiently</small>
        <span class="mx-2 text-muted">|</span>
        <small class="text-muted">
            Last updated: <%= DateTime.Now.ToString("dd MMM yyyy hh:mm tt") %>
        </small>
    </div>

    <!-- RIGHT -->
    <div class="d-flex align-items-center gap-2 flex-wrap">

        <!-- 🔍 SEARCH -->
        <div class="search-box">
            <i class="fa fa-search"></i>
            <asp:TextBox ID="txtSearch" runat="server"
                CssClass="form-control"
                placeholder="Search teachers..."
                AutoPostBack="true"
                OnTextChanged="Search_Click" />
        </div>

        <!-- 👁 TOGGLE -->
        <asp:LinkButton ID="btnToggleView" runat="server"
            CssClass="btn btn-outline-dark rounded-pill px-3"
            OnClick="ToggleView_Click">
            👁 View Inactive
        </asp:LinkButton>

        <!-- ➕ ADD -->
        <button type="button"
            class="btn btn-primary rounded-pill px-4 fw-semibold shadow-sm"
            onclick="showModal()">
            <i class="fa fa-plus"></i> Add Teacher
        </button>

    </div>
</div>

<%----------stat------------%>
<div class="row mb-4">

    <div class="col-md-3">
        <div class="card stat-card">
            <div class="card-body">
                <h6>Total</h6>
                <h3><%= TotalTeachers %></h3>
            </div>
        </div>
    </div>

    <div class="col-md-3">
        <div class="card stat-card bg-success text-white">
            <div class="card-body">
                <h6>Active</h6>
                <h3 class="stat-active"><%= ActiveTeachers %></h3>
            </div>
        </div>
    </div>

    <div class="col-md-3">
        <div class="card stat-card bg-warning">
            <div class="card-body">
                <h6>Inactive</h6>
                <h3 class="stat-inactive"><%= InactiveTeachers %></h3>
            </div>
        </div>
    </div>

</div>


    <div class="card shadow-sm border-0 mt-4">
        <div class="card-body p-0">
            <div class="table-responsive">
                <asp:GridView ID="gvTeachers" runat="server" CssClass="table align-middle mb-0 modern-table"
                    AutoGenerateColumns="false" GridLines="None" OnRowCommand="gvTeachers_RowCommand">
                    <HeaderStyle CssClass="table-header text-white" />

                    <Columns>
                        <asp:BoundField DataField="EmployeeId" HeaderText="Emp ID" />
                        <asp:BoundField DataField="FullName" HeaderText="Name" />
                        <asp:BoundField DataField="Email" HeaderText="Email" />
                        <asp:BoundField DataField="Stream" HeaderText="Stream" />
                        <asp:BoundField DataField="Designation" HeaderText="Designation" />
                        
                        <asp:TemplateField HeaderText="Actions">
                            <ItemTemplate>
                                <asp:LinkButton runat="server" CssClass="btn btn-sm btn-info text-white me-1"
                                    CommandName="ViewRow" CommandArgument='<%# Eval("UserId") %>' ToolTip="View Details">
                                     <i class="fa-solid fa-eye"></i>
                                 </asp:LinkButton>
                                <asp:LinkButton runat="server" CssClass="btn btn-sm btn-primary me-2" CommandName="EditRow" CommandArgument='<%# Eval("UserId") %>'>
                                    <i class="fa-regular fa-pen-to-square"></i>
                                </asp:LinkButton>
                                <asp:LinkButton runat="server" CssClass="btn btn-sm btn-warning me-2" CommandName="Toggle" CommandArgument='<%# Eval("UserId") %>' OnClientClick="return confirm('Change Status?');">
                                    <i class="fa-solid fa-toggle-on"></i>
                                </asp:LinkButton>
                                <asp:LinkButton runat="server" CssClass="btn btn-sm btn-danger" CommandName="DeleteRow" CommandArgument='<%# Eval("UserId") %>' OnClientClick="return confirm('Delete Teacher?');">
                                    <i class="fa-solid fa-trash-can"></i>
                                </asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </div>
    </div>

    <%--create module--%>
    <div class="modal fade" id="CreateModal" tabindex="-1">
        <div class="modal-dialog modal-lg modal-dialog-scrollable">
            <div class="modal-content modal-dialog-scrollable">
                <div class="modal-header bg-primary text-white">
                    <h5>Add Teacher</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="row g-3">
                        
                        <div class="col-md-4">
                            <label>Stream*</label>
                            <asp:DropDownList ID="ddlStream" runat="server" CssClass="form-select" />
                        </div>
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
                        <div class="col-md-3">
                            <label>Gender*</label>
                            <asp:DropDownList ID="ddlGender" runat="server" CssClass="form-select">
                                <asp:ListItem Text="Male" Value="Male" />
                                <asp:ListItem Text="Female" Value="Female" />
                            </asp:DropDownList>
                        </div>
                        <div class="col-md-3">
                            <label>DOB*</label>
                            <asp:TextBox ID="txtDOB" runat="server" CssClass="form-control" TextMode="Date" />
                        </div>
                        <div class="col-md-6">
                            <label>Contact*</label>
                            <asp:TextBox ID="txtContact" runat="server" CssClass="form-control" MaxLength="10" />
                        </div>
                        <div class="col-md-6">
                            <label>Employee ID*</label>
                            <asp:TextBox ID="txtEmpId" runat="server" CssClass="form-control" />
                        </div>
                        <div class="col-md-6">
                            <label>Designation*</label>
                            <asp:TextBox ID="txtDesignation" runat="server" CssClass="form-control" />
                        </div>
                        <div class="col-md-6">
                            <label>Exp (Years)*</label>
                            <asp:TextBox ID="txtExperience" runat="server" CssClass="form-control" TextMode="Number" />
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <asp:Button ID="btnSave" runat="server" Text="Register" CssClass="btn btn-primary" OnClick="btnSave_Click" />
                </div>
            </div>
        </div>
    </div>

    <div class="modal fade" id="EditModal" tabindex="-1">
        <div class="modal-dialog modal-lg modal-dialog-scrollable">
            <div class="modal-content">
                <div class="modal-header bg-primary text-white">
                    <h5>Edit Teacher</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="row g-3">
                        <div class="col-md-4">
                            <label>Stream*</label>
                            <asp:DropDownList ID="ddlStreamEdit" runat="server" CssClass="form-select" />
                        </div>
                        <div class="col-md-6">
                            <label>Email*</label>
                            <asp:TextBox ID="txtEmailEdit" runat="server" CssClass="form-control" />
                        </div>
                        <div class="col-md-6">
                            <label>Full Name*</label>
                            <asp:TextBox ID="txtFullNameEdit" runat="server" CssClass="form-control" />
                        </div>
                        <div class="col-md-6">
                            <label>Contact*</label>
                            <asp:TextBox ID="txtContactEdit" runat="server" CssClass="form-control" MaxLength="10" />
                        </div>
                        <div class="col-md-6">
                            <label>Designation*</label>
                            <asp:TextBox ID="txtDesignationEdit" runat="server" CssClass="form-control" />
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <asp:Button ID="btnUpdate" runat="server" Text="Update" CssClass="btn btn-primary" OnClick="btnUpdate_Click" />
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
.search-box {
    position: relative;
}
.search-box i {
    position: absolute;
    top: 10px;
    left: 10px;
    color: #6b7280;
}
.search-box input {
    padding-left: 30px;
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

.table-header th {
    background: linear-gradient(135deg, #4f46e5, #6366f1) !important;
    color: white;
    padding: 14px !important;
}

    </style>
    <script>
        function showModal() {
            var myModal = new bootstrap.Modal(document.getElementById('CreateModal'));
            myModal.show();
        }
    

        function hideMsg() {

            var alertBox = document.getElementById('<%= lblMsg.ClientID %>');

            if (!alertBox || alertBox.innerText.trim() === "")
                return;

            setTimeout(function () {

                // Smooth animation properties
                alertBox.style.transition =
                    "opacity 0.5s ease, transform 0.5s ease, height 0.5s ease, margin 0.5s ease, padding 0.5s ease";

                alertBox.style.opacity = "0";
                alertBox.style.transform = "translateY(-20px)";
                alertBox.style.height = "0";
                alertBox.style.marginTop = "0";
                alertBox.style.marginBottom = "0";
                alertBox.style.paddingTop = "0";
                alertBox.style.paddingBottom = "0";
                alertBox.style.overflow = "hidden";

                setTimeout(function () {
                    alertBox.remove();
                }, 500);

            }, 5000);
        }  
    </script>

</asp:Content>
