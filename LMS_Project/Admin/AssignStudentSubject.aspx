<%@ Page Title="Assign Student Subjects" Language="C#"
MasterPageFile="~/Admin/AdminMaster.master"
AutoEventWireup="true"
CodeBehind="AssignStudentSubject.aspx.cs"
Inherits="LearningManagementSystem.Admin.AssignStudentSubject" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server" />

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

<asp:Label ID="lblMsg" runat="server" CssClass="fw-bold mb-2 d-block" />

<div class="card shadow-sm border-0">

<div class="card-header bg-dark text-white">
<h5>Assign Student Subjects</h5>
</div>

<div class="card-body">

<div class="row g-3">

<div class="col-md-3">
<label>Stream</label>
<asp:DropDownList ID="ddlStream" runat="server"
AutoPostBack="true"
CssClass="form-select"
OnSelectedIndexChanged="FilterChanged"/>
</div>

<div class="col-md-3">
<label>Course</label>
<asp:DropDownList ID="ddlCourse" runat="server"
AutoPostBack="true"
CssClass="form-select"
OnSelectedIndexChanged="FilterChanged"/>
</div>

<div class="col-md-3">
<label>Level</label>
<asp:DropDownList ID="ddlLevel" runat="server"
AutoPostBack="true"
CssClass="form-select"
OnSelectedIndexChanged="FilterChanged"/>
</div>

<div class="col-md-3">
<label>Semester</label>
<asp:DropDownList ID="ddlSemester" runat="server"
AutoPostBack="true"
CssClass="form-select"
OnSelectedIndexChanged="FilterChanged"/>
</div>

<div class="col-md-12">

<asp:Button ID="btnLoadSubjects"
runat="server"
Text="Load Students"
CssClass="btn btn-primary"
OnClick="btnLoadSubjects_Click"/>

<asp:Button ID="btnAssign"
runat="server"
Text="Assign Subjects"
CssClass="btn btn-success"
OnClick="btnAssign_Click"/>

</div>

</div>

</div>
</div>


<!-- SUBJECTS -->

<div class="card mt-3">
<div class="card-header">Subjects</div>
<div class="card-body p-0">

<asp:GridView ID="gvSubjects"
runat="server"
CssClass="table"
AutoGenerateColumns="false"
DataKeyNames="SubjectId">

<Columns>

<asp:TemplateField>
<ItemTemplate>
<asp:CheckBox ID="chkSelect" runat="server"/>
</ItemTemplate>
</asp:TemplateField>

<asp:BoundField DataField="SubjectName" HeaderText="Subject"/>
<asp:CheckBoxField DataField="IsMandatory" HeaderText="Mandatory"/>

</Columns>

</asp:GridView>

</div>
</div>


<!-- STUDENTS -->

<div class="card mt-3">
<div class="card-header">Students</div>
<div class="card-body p-0">

<asp:GridView ID="gvStudents"
runat="server"
CssClass="table"
AutoGenerateColumns="false">

<Columns>

<asp:BoundField DataField="RollNumber" HeaderText="Roll"/>
<asp:BoundField DataField="FullName" HeaderText="Student"/>

</Columns>

</asp:GridView>

</div>
</div>


<!-- ASSIGNED -->

<div class="card mt-3">
<div class="card-header">Assigned Subjects</div>
<div class="card-body p-0">

<asp:GridView ID="gvAssigned"
runat="server"
CssClass="table"
AutoGenerateColumns="false"
OnRowCommand="gvAssigned_RowCommand">

<Columns>

<asp:BoundField DataField="FullName" HeaderText="Student"/>
<asp:BoundField DataField="SubjectName" HeaderText="Subject"/>
<asp:BoundField DataField="SessionName" HeaderText="Session"/>

<asp:TemplateField>
<ItemTemplate>


<asp:LinkButton
runat="server"
CommandName="DeleteRow"
CommandArgument='<%# Eval("Id") %>'
CssClass="btn btn-danger btn-sm">

Delete

</asp:LinkButton>

</ItemTemplate>
</asp:TemplateField>

</Columns>

</asp:GridView>

</div>
</div>

</asp:Content>