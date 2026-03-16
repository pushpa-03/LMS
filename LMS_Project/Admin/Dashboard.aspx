<%@ Page Title="" Language="C#" MasterPageFile="~/Admin/AdminMaster.Master" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="LearningManagementSystem.Admin.AdminMaster1" %>
<asp:Content ID="c1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
</asp:Content>

<asp:Content ID="c2" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">
    <asp:UpdatePanel ID="upSession" runat="server">
    <ContentTemplate>

        <asp:Label ID="lblSession" runat="server" Text="Academic Year:" />

        <asp:DropDownList ID="ddlAcademicSession"
            runat="server"
            AutoPostBack="true"
            OnSelectedIndexChanged="ddlAcademicSession_SelectedIndexChanged"
            CssClass="form-control">
        </asp:DropDownList>

        <br />

        <asp:Label ID="lblSelectedSession" runat="server"
            Font-Bold="true"
            ForeColor="Green" />

    </ContentTemplate>
</asp:UpdatePanel>

</asp:Content>
