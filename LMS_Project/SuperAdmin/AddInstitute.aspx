<%@ Page Title="Institutes"
    Language="C#"
    MasterPageFile="~/SuperAdmin/SuperAdminMaster.master"
    AutoEventWireup="true"
    CodeBehind="AddInstitute.aspx.cs"
    Inherits="LMS.SuperAdmin.AddInstitute" %>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">
    <div class="container-fluid">
        <asp:HiddenField ID="hfInstituteId" runat="server" Value="0" />
        
        <asp:UpdatePanel ID="upForm" runat="server">
            <ContentTemplate>
                <div class="card shadow-sm border-0 mb-4">
                    <div class="card-header bg-white d-flex justify-content-between">
                        <h4>Add / Edit Institute</h4>
                        <asp:Label ID="lblMsg" runat="server" CssClass="fw-bold"></asp:Label>
                    </div>
                    <div class="card-body">
                        <div class="row g-3">
                            <div class="col-md-4">
                                <label class="form-label">Select Society</label>
                                <asp:DropDownList ID="ddlSocieties" runat="server" CssClass="form-select"></asp:DropDownList>
                            </div>
                            <div class="col-md-4">
                                <label class="form-label">Institute Name</label>
                                <asp:TextBox ID="txtInstName" runat="server" CssClass="form-control"></asp:TextBox>
                            </div>
                            <div class="col-md-4">
                                <label class="form-label">Institute Code (Non-Editable in Edit Mode)</label>
                                <asp:TextBox ID="txtInstCode" runat="server" CssClass="form-control"></asp:TextBox>
                            </div>
                             <div class="col-md-3">
                                <label class="form-label">Education Type</label>
                                <asp:TextBox ID="txtEducationType" runat="server" CssClass="form-control"></asp:TextBox>
                            </div>
                            <div class="col-md-3">
                                <label class="form-label">Short Name</label>
                                <asp:TextBox ID="txtShortName" runat="server" CssClass="form-control"></asp:TextBox>
                            </div>

                            <div class="col-md-3">
                               <label class="form-label">Phone</label>
                               <asp:TextBox ID="txtPhone" runat="server" CssClass="form-control"></asp:TextBox>
                            </div>

                            <div class="col-md-3">
                              <label class="form-label">Email</label>
                              <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" TextMode="Email"></asp:TextBox>
                            </div>


                            <div class="col-md-6">
                                <label class="form-label">Institute Logo</label>
                                <asp:FileUpload ID="fuLogo" runat="server" CssClass="form-control" />
                            </div>
                            <div class="col-md-6 d-flex align-items-end gap-2">
                                <asp:Button ID="btnAddInst" runat="server" Text="Save Institute" CssClass="btn btn-success w-100" OnClick="btnAddInst_Click" />
                                <asp:Button ID="btnClear" runat="server" Text="Cancel" CssClass="btn btn-secondary w-50" OnClick="btnClear_Click" CausesValidation="false" />
                            </div>
                        </div>
                    </div>
                </div>
            </ContentTemplate>
            <Triggers>
                <asp:PostBackTrigger ControlID="btnAddInst" />
            </Triggers>
        </asp:UpdatePanel>

        <asp:UpdatePanel ID="upnlInstitutes" runat="server" UpdateMode="Conditional">
            <ContentTemplate>
                <div class="card shadow-sm border-0">
                    <div class="card-header bg-white d-flex justify-content-between align-items-center">
                        <h4 class="mb-0">Institute Directory</h4>
                        <asp:DropDownList ID="ddlFilterSociety" runat="server" CssClass="form-select w-25" AutoPostBack="true" OnSelectedIndexChanged="ddlFilterSociety_SelectedIndexChanged"></asp:DropDownList>
                    </div>
                    <div class="card-body">
                        <asp:Repeater ID="rptSocietyGroup" runat="server">
                            <ItemTemplate>
                                <h5 class="mt-4 mb-3 text-primary fw-bold"><%# Eval("SocietyName") %></h5>
                                <div class="row">
                                    <asp:Repeater ID="rptInstitutes" runat="server" OnItemCommand="rptInstitutes_ItemCommand" DataSource='<%# Eval("Institutes") %>'>
                                        <ItemTemplate>
                                            <div class="col-md-3 mb-4">
    <div class="card shadow-sm h-100 position-relative"
         style="cursor:pointer;"
         onclick="openInstituteDashboard('<%# Eval("InstituteId") %>')">

        <div style="position: absolute; top: 8px; right: 10px; z-index: 10;">
            <asp:LinkButton ID="btnEdit" runat="server"
                CommandName="EditRow"
                CommandArgument='<%# Eval("InstituteId") %>'
                CssClass="text-primary me-2"
                OnClientClick="event.stopPropagation();">
                <i class="fa-solid fa-pen-to-square"></i>
            </asp:LinkButton>

            <asp:LinkButton ID="btnDelete" runat="server"
                CommandName="DeleteRow"
                CommandArgument='<%# Eval("InstituteId") %>'
                CssClass="text-danger"
                OnClientClick="event.stopPropagation(); return confirm('Delete this institute?');">
                <i class="fa-solid fa-trash"></i>
            </asp:LinkButton>

            <asp:LinkButton ID="btnStatus" runat="server"
                CssClass="text-warning"
                CommandName="Toggle"
                CommandArgument='<%# Eval("InstituteId") %>'
                OnClientClick="event.stopPropagation(); return confirm('Toggle Status?');">
                <i class="fa-solid fa-toggle-on"></i>
            </asp:LinkButton>
        </div>

        <img src='<%# ResolveUrl(Eval("LogoURL").ToString()) %>'
             class="card-img-top p-3"
             style="height:120px; object-fit:contain;" />

        <div class="card-body text-center">
            <h6 class="fw-bold"><%# Eval("InstituteName") %></h6>
            <small class="text-muted"><%# Eval("InstituteCode") %></small>
        </div>

    </div>
</div>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>

                        <div class="d-flex justify-content-between align-items-center mt-3">
                            <asp:Label ID="lblPageInfo" runat="server" CssClass="text-muted"></asp:Label>
                            <div>
                                <asp:Button ID="btnPrev" runat="server" Text="Previous" CssClass="btn btn-sm btn-outline-primary" OnClick="btnPrev_Click" />
                                <asp:Button ID="btnNext" runat="server" Text="Next" CssClass="btn btn-sm btn-outline-primary" OnClick="btnNext_Click" />
                            </div>
                        </div>
                    </div>
                </div>
            </ContentTemplate>
        </asp:UpdatePanel>
    </div>

    <script>
    function openInstituteDashboard(id) {
        window.location.href = '<%= ResolveUrl("~/Admin/Dashboard.aspx") %>?InstituteId=' + id;
    }
    </script>
</asp:Content>
