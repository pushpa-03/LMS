<%@ Page Language="C#" AutoEventWireup="true"
    MasterPageFile="~/Teacher/TeacherMaster.master"
    CodeBehind="ViewSubmissions.aspx.cs"
    Inherits="LearningManagementSystem.Teacher.ViewSubmissions" %>

<asp:Content ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

<div class="container">
    <h4 class="mb-4 text-primary">Student Submissions</h4>

   <asp:GridView ID="gvSubmissions" runat="server"
    CssClass="table table-bordered table-striped"
    AutoGenerateColumns="false"
    DataKeyNames="SubmissionId"
    OnRowEditing="gvSubmissions_RowEditing"
    OnRowCancelingEdit="gvSubmissions_RowCancelingEdit"
    OnRowUpdating="gvSubmissions_RowUpdating">

    <Columns>

        <asp:BoundField DataField="FullName" HeaderText="Student Name" ReadOnly="true" />

        <asp:BoundField DataField="SubmittedOn"
            HeaderText="Submitted On"
            DataFormatString="{0:yyyy-MM-dd HH:mm}"
            ReadOnly="true" />

        <asp:TemplateField HeaderText="Marks">
            <ItemTemplate>
                <%# Eval("MarksObtained") %>
            </ItemTemplate>
            <EditItemTemplate>
                <asp:TextBox ID="txtMarks" runat="server"
                    Text='<%# Bind("MarksObtained") %>'
                    CssClass="form-control" />
            </EditItemTemplate>
        </asp:TemplateField>

        
        <asp:TemplateField HeaderText="Feedback">
            <ItemTemplate>
                <%# Eval("Feedback") %>
            </ItemTemplate>
            <EditItemTemplate>
                <asp:TextBox ID="txtFeedback" runat="server"
                    Text='<%# Bind("Feedback") %>'
                    CssClass="form-control" />
            </EditItemTemplate>
        </asp:TemplateField>

        <asp:TemplateField HeaderText="File">
            <ItemTemplate>
                <asp:HyperLink
                    runat="server"
                    NavigateUrl='<%# Eval("FilePath") %>'
                    Text="Download"
                    Target="_blank"
                    CssClass="btn btn-sm btn-info" />
            </ItemTemplate>
        </asp:TemplateField>

      
        <asp:CommandField ShowEditButton="true"
            EditText="Edit"
            UpdateText="Save"
            CancelText="Cancel" />

    </Columns>

</asp:GridView>
</div>

</asp:Content>