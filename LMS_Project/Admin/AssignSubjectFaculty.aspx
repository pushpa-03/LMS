<%@ Page Title="Assign Subject Faculty" Language="C#"
    MasterPageFile="~/Admin/AdminMaster.master"
    AutoEventWireup="true"
    CodeBehind="AssignSubjectFaculty.aspx.cs"
    Inherits="LearningManagementSystem.Admin.AssignSubjectFaculty" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

<link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet" />

<asp:Label ID="lblMsg" runat="server" CssClass="fw-bold mb-2 d-block" />

<div class="d-flex justify-content-between align-items-center mb-3">
    <h3>Assign Teacher To Subject</h3>

    <a href="#" data-bs-toggle="modal" data-bs-target="#AssignModal"
       class="btn btn-success">
       + Assign
    </a>
</div>

<!-- GRID -->
<asp:GridView ID="gvAssign" runat="server"
    CssClass="table"
    AutoGenerateColumns="false"
    OnRowCommand="gvAssign_RowCommand">

    <Columns>
        <asp:BoundField DataField="TeacherName" HeaderText="Teacher" />
        <asp:BoundField DataField="SubjectName" HeaderText="Subject" />
        <asp:BoundField DataField="SectionName" HeaderText="Section" />
        <asp:BoundField DataField="SessionName" HeaderText="Session" />

        <asp:TemplateField HeaderText="Status">
            <ItemTemplate>
                <span class='<%# (bool)Eval("IsActive") ? "text-success" : "text-danger" %>'>
                    <%# (bool)Eval("IsActive") ? "Active" : "Inactive" %>
                </span>
            </ItemTemplate>
        </asp:TemplateField>

        <asp:TemplateField HeaderText="Actions">
            <ItemTemplate>
                <asp:LinkButton runat="server"
                    CommandName="Toggle"
                    CommandArgument='<%# Eval("SubjectFacultyId") %>'>
                    Toggle
                </asp:LinkButton>

                <asp:LinkButton runat="server"
                    CommandName="DeleteRow"
                    CommandArgument='<%# Eval("SubjectFacultyId") %>'>
                    Delete
                </asp:LinkButton>
            </ItemTemplate>
        </asp:TemplateField>
    </Columns>

</asp:GridView>

<!-- MODAL -->
<div class="modal fade" id="AssignModal">
<div class="modal-dialog">
<div class="modal-content">

<div class="modal-header">
    <h5>Assign Subject</h5>
</div>

<div class="modal-body">

    <!-- Teacher Search -->
    <label>Teacher</label>
    <select id="ddlTeacherSearch" style="width:100%"></select>
    <asp:HiddenField ID="hfTeacherId" runat="server" />

    <br /><br />

    <!-- Section -->
    <label>Section</label>
    <asp:DropDownList ID="ddlSection" runat="server" CssClass="form-control" />

    <br />

    <!-- Subject -->
    <label>Subject</label>
    <asp:DropDownList ID="ddlSubject" runat="server" CssClass="form-control" />

</div>

<div class="modal-footer">
    <asp:Button ID="btnSave" runat="server"
        Text="Assign"
        CssClass="btn btn-success"
        OnClick="btnSave_Click" />
</div>

</div>
</div>
</div>

<!-- SCRIPTS -->
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>

<script>
$(document).ready(function () {

    $('#ddlTeacherSearch').select2({
        dropdownParent: $('#AssignModal'),
        placeholder: "Search Teacher",
        minimumInputLength: 1,
        ajax: {
            url: 'AssignSubjectFaculty.aspx/SearchTeachers',
            type: 'POST',
            dataType: 'json',
            contentType: 'application/json; charset=utf-8',
            data: function (params) {
                return JSON.stringify({ prefix: params.term });
            },
            processResults: function (data) {
                return {
                    results: $.map(data.d, function (item) {
                        return { id: item.UserId, text: item.FullName };
                    })
                };
            }
        }
    });

    $('#ddlTeacherSearch').on('select2:select', function (e) {
        $('#<%=hfTeacherId.ClientID%>').val(e.params.data.id);
    });

});
</script>

</asp:Content>
