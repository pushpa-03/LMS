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

            <div class="d-flex justify-content-between align-items-center mb-3">
            <h3>Parent Management</h3>

            <a href="#" class="btn btn-success"
            data-bs-toggle="modal"
            data-bs-target="#CreateModal">
            Add Parent
            </a>
            </div>


           <asp:GridView ID="gvParents" runat="server"
CssClass="table table-hover"
AutoGenerateColumns="false"
OnRowCommand="gvParents_RowCommand">

<Columns>

<asp:BoundField DataField="StudentName" HeaderText="Student"/>

<asp:BoundField DataField="ParentName" HeaderText="Parent"/>

<asp:BoundField DataField="Relation" HeaderText="Relation"/>

<asp:BoundField DataField="Email" HeaderText="Email"/>

<asp:BoundField DataField="ContactNo" HeaderText="Contact"/>

<asp:TemplateField HeaderText="Status">
<ItemTemplate>

<asp:Label runat="server"
Text='<%# Convert.ToBoolean(Eval("IsActive")) ? "Active" : "Inactive" %>'
CssClass='<%# Convert.ToBoolean(Eval("IsActive")) ? "badge bg-success" : "badge bg-danger" %>' />

</ItemTemplate>
</asp:TemplateField>

<asp:TemplateField HeaderText="Actions">
<ItemTemplate>

<asp:LinkButton runat="server"
CssClass="btn btn-sm btn-warning me-2"
CommandName="Toggle"
CommandArgument='<%# Eval("ParentUserId") %>'>
Activate/Deactivate
</asp:LinkButton>

<asp:LinkButton runat="server"
CssClass="btn btn-sm btn-danger"
CommandName="DeleteRow"
CommandArgument='<%# Eval("ParentUserId") %>'>
Delete
</asp:LinkButton>

</ItemTemplate>
</asp:TemplateField>

</Columns>

</asp:GridView>


    <!-- CREATE MODAL -->
    <div class="modal fade" id="CreateModal">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">

                <div class="modal-header bg-success text-white">
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
                        CssClass="btn btn-success"
                        OnClick="btnSave_Click" />
                </div>

            </div>
        </div>
    </div>

</asp:Content>