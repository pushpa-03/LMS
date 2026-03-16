<%@ Page Title="Academic Session" Language="C#" 
MasterPageFile="~/Admin/AdminMaster.Master"
AutoEventWireup="true"
CodeBehind="AcademicSession.aspx.cs"
Inherits="LearningManagementSystem.Admin.AcademicSession" %>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

<h2>Academic Session Management</h2>

<table class="table">
    <tr>
        <td>Session Name</td>
        <td><asp:TextBox ID="txtSessionName" runat="server" CssClass="form-control" /></td>
    </tr>

    <tr>
        <td>Start Date</td>
        <td><asp:TextBox ID="txtStartDate" runat="server" TextMode="Date" CssClass="form-control" /></td>
    </tr>

    <tr>
        <td>End Date</td>
        <td><asp:TextBox ID="txtEndDate" runat="server" TextMode="Date" CssClass="form-control" /></td>
    </tr>

    <tr>
        <td>Set As Current</td>
        <td><asp:CheckBox ID="chkCurrent" runat="server" /></td>
    </tr>

    <tr>
        <td></td>
        <td>
            <asp:Button ID="btnSave" runat="server" Text="Save"
                CssClass="btn btn-primary"
                OnClick="btnSave_Click" />
        </td>
    </tr>
</table>

<hr />

<asp:GridView ID="gvSessions" runat="server"
    AutoGenerateColumns="false"
    CssClass="table table-bordered">

    <Columns>
        <asp:BoundField DataField="SessionName" HeaderText="Session" />
        <asp:BoundField DataField="StartDate" HeaderText="Start Date" />
        <asp:BoundField DataField="EndDate" HeaderText="End Date" />
        <asp:CheckBoxField DataField="IsCurrent" HeaderText="Current" />
    </Columns>

</asp:GridView>

</asp:Content>