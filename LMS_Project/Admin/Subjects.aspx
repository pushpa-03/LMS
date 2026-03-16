<%@ Page Title="Subjects" Language="C#" MasterPageFile="~/Admin/AdminMaster.master"
AutoEventWireup="true" CodeBehind="Subjects.aspx.cs"
Inherits="LearningManagementSystem.Admin.Subjects" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

<div class="d-flex justify-content-between align-items-center mb-4">
    <h3 class="mb-0">Subjects</h3>
</div>

    <asp:Label ID="lblMsg" runat="server"
CssClass="alert alert-warning"
Visible="false"></asp:Label>

<asp:Repeater ID="rptSubjects" runat="server" OnItemCommand="rptSubjects_ItemCommand">

<ItemTemplate>

<div class="card shadow-sm mb-3 border-0 subject-card">
<div class="card-body">

<div class="row align-items-center">

<div class="col-md-2">
<span class="badge bg-secondary p-2">
<%# Eval("SubjectCode") %>
</span>
</div>

<div class="col-md-4">
<h5 class="mb-0"><%# Eval("SubjectName") %></h5>
</div>

<div class="col-md-2">

<%# Convert.ToBoolean(Eval("IsActive")) ?
"<span class='badge bg-success'>Active</span>" :
"<span class='badge bg-danger'>Inactive</span>" %>

</div>

<div class="col-md-4 text-end">

<a href='SubjectDetails.aspx?SubjectId=<%# Eval("SubjectId") %>'
class="btn btn-outline-primary btn-sm me-2">
<i class="fa-solid fa-eye"></i> View
</a>

<asp:LinkButton ID="btnToggle" runat="server"
CssClass="btn btn-outline-warning btn-sm"
CommandName="Toggle"
CommandArgument='<%# Eval("SubjectId") %>'>

<%# Convert.ToBoolean(Eval("IsActive")) ? "Deactivate" : "Activate" %>

</asp:LinkButton>

</div>

</div>

</div>
</div>

</ItemTemplate>

</asp:Repeater>


<style>

.subject-card{
transition:0.2s;
}

.subject-card:hover{
transform:translateY(-3px);
box-shadow:0 6px 20px rgba(0,0,0,0.15);
}

</style>

</asp:Content>