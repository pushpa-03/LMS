<%@ Page Title="Subject Management" Language="C#" MasterPageFile="~/Admin/AdminMaster.master"
    AutoEventWireup="true" CodeBehind="AddSubject.aspx.cs"
    Inherits="LearningManagementSystem.Admin.AddSubject" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server" >

</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

    <!-- Hidden -->
    <asp:HiddenField ID="hfSubjectId" runat="server" />
    <asp:Label ID="lblMsg" runat="server" CssClass="fw-bold mb-2 d-block" />

    <!-- Header -->
    <div class="d-flex justify-content-between align-items-center mb-3">
        <h3 class="mb-0">Subject Management</h3>
        <div class="d-flex gap-2">
        <div class="d-none d-md-block">

            <!-- Search -->
            <div class="input-group">
                <span class="input-group-text bg-white border-e-none">
                    <i class="fa-solid fa-magnifying-glass text-color-1"></i>
                </span>

                <asp:TextBox ID="txtSearch" runat="server"
                    CssClass="form-control border-s-none ps-0"
                    placeholder="Search Subject Name/Code"
                    AutoPostBack="true"
                    OnTextChanged="btnFilter_Click" />

                <asp:Button ID="btnFilter" runat="server"
                    Text="Search"
                    CssClass="btn btn-primary"
                    OnClick="btnFilter_Click" />
            </div>
            </div>

            <!-- Filter -->
            <div class="dropdown">
                <button class="btn btn-light border dropdown-toggle"
                    type="button" data-bs-toggle="dropdown"> <i class="fa-solid fa-filter"></i>
                    Filter
                </button>

                <ul class="dropdown-menu">
                    <li>
                        <asp:LinkButton ID="lnkAll" runat="server"
                            CssClass="dropdown-item"
                            OnClick="FilterStatus_Click"
                            CommandArgument="All">All</asp:LinkButton></li>

                    <li>
                        <asp:LinkButton ID="lnkActive" runat="server"
                            CssClass="dropdown-item"
                            OnClick="FilterStatus_Click"
                            CommandArgument="1">Active</asp:LinkButton></li>

                    <li>
                        <asp:LinkButton ID="lnkInactive" runat="server"
                            CssClass="dropdown-item"
                            OnClick="FilterStatus_Click"
                            CommandArgument="0">Inactive</asp:LinkButton></li>
                </ul>
            </div>

            <!-- Add Button -->
            <button type="button" class="btn btn-success"
                data-bs-toggle="modal" data-bs-target="#CreateModal">
                 <i class="fa-solid fa-plus"></i> Add Subject
            </button>
            
        </div>
    </div>

    <!-- GRID -->
    <asp:GridView ID="gvSubjects"
            runat="server"
            CssClass="table align-middle"
            AutoGenerateColumns="false"
            OnRowCommand="gvSubjects_RowCommand">

            <Columns>

            <asp:BoundField DataField="SubjectCode" HeaderText="Code" />
            <asp:BoundField DataField="SubjectName" HeaderText="Subject Name" />
            <asp:BoundField DataField="Duration" HeaderText="Duration" />

            <asp:TemplateField HeaderText="Status">
            <ItemTemplate>

            <span class='badge <%# (bool)Eval("IsActive") ? "bg-success" : "bg-danger" %>'>
            <%# (bool)Eval("IsActive") ? "Active" : "Inactive" %>
            </span>
            </ItemTemplate>
            </asp:TemplateField>

            </Columns>

            </asp:GridView>

    <!-- CREATE MODAL -->
    <div class="modal fade" id="CreateModal">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">

                <div class="modal-header bg-success text-white">
                    <h5>Add Subject</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>

                <div class="modal-body">
                    <div class="row g-3">

                    <div class="col-md-4">
                    <label>Subject Code*</label>
                    <asp:TextBox ID="txtSubjectCode"
                    runat="server"
                    CssClass="form-control" />
                    </div>

                    <div class="col-md-8">
                    <label>Subject Name*</label>
                    <asp:TextBox ID="txtSubjectName"
                    runat="server"
                    CssClass="form-control" />
                    </div>

                    <div class="col-md-6">
                    <label>Duration</label>
                    <asp:TextBox ID="txtDuration"
                    runat="server"
                    CssClass="form-control" />
                    </div>

                    <div class="col-md-12">
                    <label>Description</label>
                    <asp:TextBox ID="txtDescription"
                    runat="server"
                    CssClass="form-control"
                    TextMode="MultiLine"
                    Rows="2" />
                    </div>

                    </div>
                    </div>

                <div class="modal-footer">
                    <asp:Button ID="btnSave"
                        runat="server"
                        Text="Save Subject"
                        CssClass="btn btn-success"
                        OnClick="btnSave_Click" />
                </div>

            </div>
        </div>
    </div>

    <%-- EditModel --%>
    <div class="modal fade" id="EditModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header bg-success text-white">
                <h5>Edit Subject</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <div class="row g-3">
                    <div class="col-md-6">
                        <label>Subject Code</label>
                        <asp:TextBox ID="txtSubjectCodeEdit" runat="server" CssClass="form-control" />
                    </div>
                    <div class="col-md-6">
                        <label>Subject Name</label>
                        <asp:TextBox ID="txtSubjectNameEdit" runat="server" CssClass="form-control" />
                    </div>
                    <div class="col-md-12">
                        <label>Duration</label>
                        <asp:TextBox ID="txtDurationEdit" runat="server" CssClass="form-control" />
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <asp:Button ID="btnUpdate" runat="server" Text="Update Course" CssClass="btn btn-success" OnClick="btnUpdate_Click" />
            </div>
        </div>
    </div>
</div>

<script>
    function showCreateModal() {
        var myModal = new bootstrap.Modal(document.getElementById('CreateModal'));
        myModal.show();
    }
    function showEditModal() {
        var myModal = new bootstrap.Modal(document.getElementById('EditModal'));
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
