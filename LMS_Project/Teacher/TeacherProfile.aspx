<%@ Page Language="C#" AutoEventWireup="true"
    MasterPageFile="~/Teacher/TeacherMaster.master"
    CodeBehind="TeacherProfile.aspx.cs"
    Inherits="LMS_Project.Teacher.TeacherProfile" %>

<asp:Content ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

<div class="container">
    
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h3 class="text-success">My Profile</h3>

        <asp:Button ID="btnEdit" runat="server"
            Text="Edit"
            CssClass="btn btn-outline-success"
            OnClick="btnEdit_Click" />
    </div>

    <div class="card shadow p-4">

        <div class="row mb-3">
            <div class="col-md-6">
                <label>Full Name</label>
                <asp:TextBox ID="txtFullName" runat="server"
                    CssClass="form-control" ReadOnly="true" />
            </div>

            <div class="col-md-6">
                <label>Email</label>
                <asp:TextBox ID="txtEmail" runat="server"
                    CssClass="form-control" ReadOnly="true" />
            </div>
        </div>

        <div class="row mb-3">
            <div class="col-md-6">
                <label>Contact</label>
                <asp:TextBox ID="txtContact" runat="server"
                    CssClass="form-control" ReadOnly="true" />
            </div>

            <div class="col-md-6">
                <label>Qualification</label>
                <asp:TextBox ID="txtQualification" runat="server"
                    CssClass="form-control" ReadOnly="true" />
            </div>
        </div>

        <div class="row mb-3">
            <div class="col-md-6">
                <label>Experience (Years)</label>
                <asp:TextBox ID="txtExperience" runat="server"
                    CssClass="form-control" ReadOnly="true" />
            </div>

            <div class="col-md-6">
                <label>Designation</label>
                <asp:TextBox ID="txtDesignation" runat="server"
                    CssClass="form-control" ReadOnly="true" />
            </div>
        </div>

        <div class="mb-3">
            <label>Address</label>
            <asp:TextBox ID="txtAddress" runat="server"
                CssClass="form-control" ReadOnly="true" />
        </div>

        <div class="row mb-3">
            <div class="col-md-6">
                <label>City</label>
                <asp:TextBox ID="txtCity" runat="server"
                    CssClass="form-control" ReadOnly="true" />
            </div>

            <div class="col-md-6">
                <label>Country</label>
                <asp:TextBox ID="txtCountry" runat="server"
                    CssClass="form-control" ReadOnly="true" />
            </div>
        </div>

        <div class="mb-3">
            <label>Pincode</label>
            <asp:TextBox ID="txtPincode" runat="server"
                CssClass="form-control" ReadOnly="true" />
        </div>

        <asp:Button ID="btnUpdate" runat="server"
            Text="Update Profile"
            CssClass="btn btn-success"
            Visible="false"
            OnClick="btnUpdate_Click" />

    </div>
</div>

</asp:Content>