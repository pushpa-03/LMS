<%@ Page Title="Institutes"
    Language="C#"
    MasterPageFile="~/SuperAdmin/SuperAdminMaster.master"
    AutoEventWireup="true"
    CodeBehind="AddInstitute.aspx.cs"
    Inherits="LMS.SuperAdmin.AddInstitute" %>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

<style>

/* ===== CARD ===== */
.admin-card {
    border: none;
    border-radius: 14px;
    box-shadow: 0 4px 14px rgba(0,0,0,0.08);
    transition: .2s;
    background: #fff;
}
.admin-card:hover {
    transform: translateY(-3px);
}

/* ===== HEADER ===== */
.card-header-custom {
    border-bottom: 1px solid #eef2f7;
    padding: 16px 20px;
    font-weight: 700;
    font-size: 16px;
    color: #1565c0;
}

/* ===== FORM ===== */
.form-label {
    font-size: 13px;
    font-weight: 600;
    color: #607d8b;
}

.form-control, .form-select {
    border-radius: 8px;
    font-size: 14px;
}

/* ===== BUTTONS ===== */
.btn-theme {
    background: linear-gradient(135deg,#1565c0,#1976d2);
    border: none;
    color: #fff;
    font-weight: 600;
    border-radius: 8px;
}
.btn-theme:hover {
    opacity: .9;
}

.btn-light-gray {
    background: #eceff1;
    border: none;
    border-radius: 8px;
}

/* ===== INSTITUTE CARD ===== */
.inst-card {
    border-radius: 12px;
    overflow: hidden;
    transition: .25s;
    border: none;
}

.inst-card:hover {
    transform: translateY(-4px);
    box-shadow: 0 6px 18px rgba(0,0,0,0.12);
}

/* ===== ACTION ICONS ===== */
.action-icons i {
    font-size: 14px;
    cursor: pointer;
}

.action-icons a {
    margin-left: 8px;
}

/* ===== MOBILE ===== */
@media (max-width:768px){
    .card-header-custom{
        font-size:14px;
    }
}

</style>

<div class="container-fluid">

    <asp:HiddenField ID="hfInstituteId" runat="server" Value="0" />

    <!-- ================= FORM ================= -->
    <asp:UpdatePanel ID="upForm" runat="server">
        <ContentTemplate>

            <div class="admin-card mb-4">

                <div class="card-header-custom d-flex justify-content-between align-items-center">
                    <span>Add / Edit Institute</span>
                    <asp:Label ID="lblMsg" runat="server" CssClass="fw-bold text-primary"></asp:Label>
                </div>

                <div class="p-4">

                    <div class="row g-3">

                        <div class="col-md-4 col-sm-6">
                            <label class="form-label">Select Society</label>
                            <asp:DropDownList ID="ddlSocieties" runat="server" CssClass="form-select"></asp:DropDownList>
                        </div>

                        <div class="col-md-4 col-sm-6">
                            <label class="form-label">Institute Name</label>
                            <asp:TextBox ID="txtInstName" runat="server" CssClass="form-control"></asp:TextBox>
                        </div>

                        <div class="col-md-4 col-sm-6">
                            <label class="form-label">Institute Code</label>
                            <asp:TextBox ID="txtInstCode" runat="server" CssClass="form-control"></asp:TextBox>
                        </div>

                        <div class="col-md-3 col-sm-6">
                            <label class="form-label">Education Type</label>
                            <asp:TextBox ID="txtEducationType" runat="server" CssClass="form-control"></asp:TextBox>
                        </div>

                        <div class="col-md-3 col-sm-6">
                            <label class="form-label">Short Name</label>
                            <asp:TextBox ID="txtShortName" runat="server" CssClass="form-control"></asp:TextBox>
                        </div>

                        <div class="col-md-3 col-sm-6">
                            <label class="form-label">Phone</label>
                            <asp:TextBox ID="txtPhone" runat="server" CssClass="form-control"></asp:TextBox>
                        </div>

                        <div class="col-md-3 col-sm-6">
                            <label class="form-label">Email</label>
                            <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" TextMode="Email"></asp:TextBox>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label">Institute Logo</label>
                            <asp:FileUpload ID="fuLogo" runat="server" CssClass="form-control" />
                        </div>

                        <div class="col-md-6 d-flex align-items-end gap-2">
                            <asp:Button ID="btnAddInst" runat="server"
                                Text="Save Institute"
                                CssClass="btn btn-theme w-100"
                                OnClick="btnAddInst_Click" />

                            <asp:Button ID="btnClear" runat="server"
                                Text="Cancel"
                                CssClass="btn btn-light-gray w-50"
                                OnClick="btnClear_Click"
                                CausesValidation="false" />
                        </div>

                    </div>

                </div>

            </div>

        </ContentTemplate>

        <Triggers>
            <asp:PostBackTrigger ControlID="btnAddInst" />
        </Triggers>
    </asp:UpdatePanel>


    <!-- ================= LIST ================= -->
    <asp:UpdatePanel ID="upnlInstitutes" runat="server" UpdateMode="Conditional">
        <ContentTemplate>

            <div class="admin-card">

                <div class="card-header-custom d-flex justify-content-between align-items-center">
                    <span>Institute Directory</span>

                    <asp:DropDownList ID="ddlFilterSociety" runat="server"
                        CssClass="form-select w-auto"
                        AutoPostBack="true"
                        OnSelectedIndexChanged="ddlFilterSociety_SelectedIndexChanged">
                    </asp:DropDownList>
                </div>

                <div class="p-4">

                    <asp:Repeater ID="rptSocietyGroup" runat="server">
                        <ItemTemplate>

                            <h6 class="fw-bold text-primary mb-3 mt-3">
                                <%# Eval("SocietyName") %>
                            </h6>

                            <div class="row">

                                <asp:Repeater ID="rptInstitutes" runat="server"
                                    OnItemCommand="rptInstitutes_ItemCommand"
                                    DataSource='<%# Eval("Institutes") %>'>

                                    <ItemTemplate>

                                        <div class="col-lg-3 col-md-4 col-sm-6 mb-4">

                                            <div class="card shadow-sm h-100 position-relative"
                                             style="cursor:pointer;"
                                             data-id='<%# Eval("InstituteId") %>'
                                             onclick="openInstituteDashboard(this.getAttribute('data-id'))">

                                                <!-- ACTIONS -->
                                                <div class="position-absolute top-0 end-0 p-2 action-icons">

                                                    <asp:LinkButton ID="btnEdit" runat="server"
                                                        CommandName="EditRow"
                                                        CommandArgument='<%# Eval("InstituteId") %>'
                                                        CssClass="text-primary"
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
                                                        CommandName="Toggle"
                                                        CommandArgument='<%# Eval("InstituteId") %>'
                                                        CssClass="text-warning"
                                                        OnClientClick="event.stopPropagation();">
                                                        <i class="fa-solid fa-toggle-on"></i>
                                                    </asp:LinkButton>

                                                </div>

                                                <!-- IMAGE -->
                                                <img src='<%# ResolveUrl(Eval("LogoURL").ToString()) %>'
                                                    class="card-img-top p-3"
                                                    style="height:110px; object-fit:contain;" />

                                                <!-- BODY -->
                                                <div class="card-body text-center">
                                                    <h6 class="fw-bold mb-1">
                                                        <%# Eval("InstituteName") %>
                                                    </h6>
                                                    <small class="text-muted">
                                                        <%# Eval("InstituteCode") %>
                                                    </small>
                                                </div>

                                            </div>

                                        </div>

                                    </ItemTemplate>
                                </asp:Repeater>

                            </div>

                        </ItemTemplate>
                    </asp:Repeater>


                    <!-- PAGINATION -->
                    <div class="d-flex justify-content-between align-items-center mt-3">

                        <asp:Label ID="lblPageInfo" runat="server" CssClass="text-muted"></asp:Label>

                        <div>
                            <asp:Button ID="btnPrev" runat="server"
                                Text="Previous"
                                CssClass="btn btn-sm btn-outline-primary"
                                OnClick="btnPrev_Click" />

                            <asp:Button ID="btnNext" runat="server"
                                Text="Next"
                                CssClass="btn btn-sm btn-outline-primary"
                                OnClick="btnNext_Click" />
                        </div>

                    </div>

                </div>

            </div>

        </ContentTemplate>
    </asp:UpdatePanel>

</div>

    <script>
        function openInstituteDashboard(id) {
            var url = '<%= ResolveUrl("~/Admin/OverviewDashboard.aspx") %>?InstituteId=' + id;
            window.location.href = url;
        }

        // FIX: Rebind after UpdatePanel refresh
        Sys.Application.add_load(function () {
            window.openInstituteDashboard = openInstituteDashboard;
        });
    </script>

</asp:Content>