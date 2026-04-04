<%@ Page Title="Societies"
    Language="C#"
    MasterPageFile="~/SuperAdmin/SuperAdminMaster.master"
    AutoEventWireup="true"
    CodeBehind="AddSociety.aspx.cs"
    Inherits="LMS.SuperAdmin.AddSociety" %>


<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

<style>

/* ===== PAGE CARD ===== */
.custom-card {
    border: none;
    border-radius: 14px;
    background: #ffffff;
    box-shadow: 0 4px 14px rgba(0,0,0,0.08);
    overflow: hidden;
}

/* ===== HEADER ===== */
.custom-card-header {
    padding: 16px 20px;
    border-bottom: 1px solid #e3e8f0;
    background: #f9fbfd;
}

.custom-card-header h4 {
    margin: 0;
    font-weight: 700;
    color: #1565c0;
}

/* ===== BODY ===== */
.custom-card-body {
    padding: 20px;
}

/* ===== INPUT ===== */
.form-label {
    font-weight: 600;
    color: #455a64;
    margin-bottom: 6px;
}

.form-control {
    border-radius: 8px;
    padding: 10px;
    border: 1px solid #dce3ec;
    transition: .2s;
}

.form-control:focus {
    border-color: #1976d2;
    box-shadow: 0 0 0 2px rgba(25,118,210,0.1);
}

/* ===== BUTTON ===== */
.btn-primary {
    background: linear-gradient(135deg, #1565c0, #1976d2);
    border: none;
    border-radius: 10px;
    padding: 10px;
    font-weight: 600;
}

.btn-primary:hover {
    background: linear-gradient(135deg, #0d47a1, #1565c0);
}

/* ===== TABLE ===== */
.table {
    border-radius: 10px;
    overflow: hidden;
}

.table thead {
    background: #f1f5fb;
}

.table th {
    font-weight: 600;
    color: #37474f;
    border-bottom: 1px solid #e0e6ed;
}

.table td {
    vertical-align: middle;
}

/* ===== STATUS BADGE ===== */
.badge-active {
    background: #2e7d32;
    color: #fff;
    padding: 5px 10px;
    border-radius: 6px;
    font-size: 12px;
}

.badge-inactive {
    background: #c62828;
    color: #fff;
    padding: 5px 10px;
    border-radius: 6px;
    font-size: 12px;
}

/* ===== ACTION BUTTONS ===== */
.btn-warning {
    background: #ffb300;
    border: none;
    color: #000;
}

.btn-warning:hover {
    background: #ffa000;
}

.btn-info {
    background: #29b6f6;
    border: none;
    color: #fff;
}

.btn-info:hover {
    background: #0288d1;
}

/* ===== RESPONSIVE ===== */
@media(max-width:768px){
    .row > div {
        margin-bottom: 20px;
    }
}

</style>

<div class="row">

    <!-- LEFT FORM -->
    <div class="col-lg-4">
        <div class="custom-card">

            <div class="custom-card-header">
                <h4>Add / Edit Society</h4>
            </div>

            <div class="custom-card-body">

                <asp:HiddenField ID="hfSocietyId" runat="server" />

                <div class="mb-3">
                    <label class="form-label">Society Name</label>
                    <asp:TextBox ID="txtSocietyName" runat="server"
                        CssClass="form-control"
                        placeholder="Enter Name"></asp:TextBox>
                </div>

                <div class="mb-3">
                    <label class="form-label">Society Code</label>
                    <asp:TextBox ID="txtSocietyCode" runat="server"
                        CssClass="form-control"
                        placeholder="Ex: SOC001"></asp:TextBox>
                </div>

                <asp:Button ID="btnSave" runat="server"
                    Text="Save Society"
                    CssClass="btn btn-primary w-100"
                    OnClick="btnSave_Click" />

            </div>
        </div>
    </div>

    <!-- RIGHT TABLE -->
    <div class="col-lg-8">
        <div class="custom-card">

            <div class="custom-card-header">
                <h4>Existing Societies</h4>
            </div>

            <div class="custom-card-body">

                <asp:GridView ID="gvSocieties"
                    runat="server"
                    CssClass="table table-hover"
                    AutoGenerateColumns="false"
                    OnRowCommand="gvSocieties_RowCommand">

                    <Columns>

                        <asp:BoundField DataField="SocietyName" HeaderText="Name" />
                        <asp:BoundField DataField="SocietyCode" HeaderText="Code" />

                        <asp:TemplateField HeaderText="Status">
                            <ItemTemplate>
                                <span class='<%# Convert.ToBoolean(Eval("IsActive")) ? "badge-active" : "badge-inactive" %>'>
                                    <%# Convert.ToBoolean(Eval("IsActive")) ? "Active" : "Inactive" %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Actions">
                            <ItemTemplate>

                                <asp:LinkButton ID="btnToggle"
                                    runat="server"
                                    CommandName="ToggleStatus"
                                    CommandArgument='<%# Eval("SocietyId") %>'
                                    CssClass="btn btn-sm btn-warning me-1">
                                    Toggle
                                </asp:LinkButton>

                                <asp:LinkButton ID="btnEdit"
                                    runat="server"
                                    CommandName="EditSoc"
                                    CommandArgument='<%# Eval("SocietyId") %>'
                                    CssClass="btn btn-sm btn-info">
                                    Edit
                                </asp:LinkButton>

                            </ItemTemplate>
                        </asp:TemplateField>

                    </Columns>

                </asp:GridView>

            </div>
        </div>
    </div>

</div>

</asp:Content>