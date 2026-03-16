<%@ Page Title="Assign Level Subjects" Language="C#"
MasterPageFile="~/Admin/AdminMaster.master"
AutoEventWireup="true"
CodeBehind="AssignLevelSubject.aspx.cs"
Inherits="LearningManagementSystem.Admin.AssignLevelSubject" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server" >

</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

<asp:Label ID="lblMsg" runat="server" CssClass="fw-bold mb-2 d-block" />

<div class="card shadow-sm border-0 mt-3">

<div class="card-header bg-primary text-white">
<h5 class="mb-0">Assign Subjects to Class</h5>
</div>

<div class="card-body">

<div class="row g-3">

<div class="col-md-3">
<label>Stream</label>
<asp:DropDownList ID="ddlStream" runat="server" AutoPostBack="true" CssClass="form-select"
OnSelectedIndexChanged="ddlStream_SelectedIndexChanged">
</asp:DropDownList>
</div>

<div class="col-md-3">
<label>Course</label>
<asp:DropDownList ID="ddlCourse" runat="server" CssClass="form-select"/>
</div>

<div class="col-md-3">
<label>Level</label>
<asp:DropDownList ID="ddlLevel" runat="server" CssClass="form-select"/>
</div>

<div class="col-md-3">
<label>Semester</label>
<asp:DropDownList ID="ddlSemester" runat="server" CssClass="form-select"/>
</div>

<div class="col-md-12">

<asp:GridView ID="gvSubjects"
runat="server"
AutoGenerateColumns="false"
CssClass="table"
DataKeyNames="SubjectId">

<Columns>

<asp:TemplateField>
<ItemTemplate>
<asp:CheckBox ID="chkSelect" runat="server"/>
</ItemTemplate>
</asp:TemplateField>

<asp:BoundField DataField="SubjectName" HeaderText="Subject"/>

<asp:TemplateField HeaderText="Mandatory">

<ItemTemplate>
<asp:CheckBox ID="chkMandatory" runat="server" Checked="true"/>
</ItemTemplate>

</asp:TemplateField>

</Columns>

</asp:GridView>

</div>

</div>

</div>

<div class="card-footer text-end">

<asp:Button ID="btnSave"
runat="server"
Text="Assign Subjects"
CssClass="btn btn-success"
OnClick="btnSave_Click"/>

</div>

</div>

</asp:Content>