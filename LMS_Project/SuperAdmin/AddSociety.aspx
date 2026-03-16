<%@ Page Title="Societies"
    Language="C#"
    MasterPageFile="~/SuperAdmin/SuperAdminMaster.master"
    AutoEventWireup="true"
    CodeBehind="AddSociety.aspx.cs"
    Inherits="LMS.SuperAdmin.AddSociety" %>


<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">
    
    <div class="row">
        <div class="col-lg-4">
            <div class="card shadow-sm border-0">
                <div class="card-header bg-white">
                    <h4 class="h4">Add/Edit Society</h4>
                </div>
                <div class="card-body">
                    <asp:HiddenField ID="hfSocietyId" runat="server" />
                    <div class="mb-3">
                        <label class="form-label">Society Name</label>
                        <asp:TextBox ID="txtSocietyName" runat="server" CssClass="form-control" placeholder="Enter Name"></asp:TextBox>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Society Code</label>
                        <asp:TextBox ID="txtSocietyCode" runat="server" CssClass="form-control" placeholder="Ex: SOC001"></asp:TextBox>
                    </div>
                    <asp:Button ID="btnSave" runat="server" Text="Save Society" CssClass="btn btn-primary w-100" OnClick="btnSave_Click" />
                </div>
            </div>
        </div>

        <div class="col-lg-8">
            <div class="card shadow-sm border-0">
                <div class="card-header bg-white">
                    <h4 class="h4">Existing Societies</h4>
                </div>
                <div class="card-body">
                    <asp:GridView ID="gvSocieties" runat="server" CssClass="table table-hover" AutoGenerateColumns="false" OnRowCommand="gvSocieties_RowCommand">
                        <Columns>
                            <asp:BoundField DataField="SocietyName" HeaderText="Name" />
                            <asp:BoundField DataField="SocietyCode" HeaderText="Code" />
                            <asp:TemplateField HeaderText="Status">
                                <ItemTemplate>
                                    <span class='<%# Convert.ToBoolean(Eval("IsActive")) ? "badge bg-success" : "badge bg-danger" %>'>
                                        <%# Convert.ToBoolean(Eval("IsActive")) ? "Active" : "Inactive" %>
                                    </span>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Actions">
                                <ItemTemplate>
                                    <asp:LinkButton ID="btnToggle" runat="server" CommandName="ToggleStatus" CommandArgument='<%# Eval("SocietyId") %>' CssClass="btn btn-sm btn-warning">Toggle</asp:LinkButton>
                                    <asp:LinkButton ID="btnEdit" runat="server" CommandName="EditSoc" CommandArgument='<%# Eval("SocietyId") %>' CssClass="btn btn-sm btn-info">Edit</asp:LinkButton>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </div>
            </div>
        </div>
    </div>
</asp:Content>