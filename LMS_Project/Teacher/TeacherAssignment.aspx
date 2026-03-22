<%@ Page Language="C#" AutoEventWireup="true"
    MasterPageFile="~/Teacher/TeacherMaster.master"
    CodeBehind="TeacherAssignment.aspx.cs"
    Inherits="LearningManagementSystem.Teacher.TeacherAssignment" %>

<asp:Content ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

<div class="container">

    <h4 class="mb-4 text-success">Create Assignment</h4>

    <div class="card p-4 shadow-sm">

        <div class="mb-3">
            <label>Subject</label>
            <asp:DropDownList ID="ddlSubject" runat="server" CssClass="form-control" />
        </div>

        <div class="mb-3">
            <label>Title</label>
            <asp:TextBox ID="txtTitle" runat="server" CssClass="form-control" />
        </div>

        <div class="mb-3">
            <label>Description</label>
            <asp:TextBox ID="txtDescription" runat="server" TextMode="MultiLine" Rows="4" CssClass="form-control" />
        </div>

        <div class="mb-3">
            <label>Upload Assignment File</label>
            <asp:FileUpload ID="fuAssignment" runat="server" CssClass="form-control" />
        </div>

        <div class="mb-3">
            <label>Due Date</label>
            <asp:TextBox ID="txtDueDate" runat="server" TextMode="Date" CssClass="form-control" />
        </div>

        <div class="mb-3">
            <label>Max Marks</label>
            <asp:TextBox ID="txtMarks" runat="server" CssClass="form-control" />
        </div>

        <asp:Button ID="btnSave" runat="server" Text="Create Assignment"
            CssClass="btn btn-success"
            OnClick="btnSave_Click" />

    </div>

    <!-- Display Assignments in Bootstrap Cards -->
<h4 class="mt-5 mb-3 text-primary">Assignments Created</h4>

<asp:Repeater ID="rptAssignments" runat="server">
    <ItemTemplate>
        <div class="card mb-3 shadow-sm">
            <div class="card-body">

                <h5 class="card-title">
                    <%# Eval("Title") %> 
                    (<%# Eval("SubjectName") %>)
                </h5>

                <p><%# Eval("Description") %></p>

                <p>
                    <small class="text-muted">
                        Due: <%# Eval("DueDate", "{0:yyyy-MM-dd}") %> 
                        | Max Marks: <%# Eval("MaxMarks") %>
                    </small>
                </p>

                <!-- Download Assignment -->
                <asp:HyperLink 
                    runat="server"
                    NavigateUrl='<%# Eval("FilePath") %>'
                    Text="Download"
                    CssClass="btn btn-sm btn-primary"
                    Visible='<%# Eval("FilePath") != DBNull.Value %>'
                    Target="_blank" />

                <!-- View Submissions -->
                <asp:HyperLink 
                    runat="server"
                    NavigateUrl='<%# "ViewSubmissions.aspx?AssignmentId=" + Eval("AssignmentId") %>'
                    Text="View Submissions"
                    CssClass="btn btn-sm btn-success ms-2" />

            </div>
        </div>
    </ItemTemplate>
</asp:Repeater>

</div>
</asp:Content>