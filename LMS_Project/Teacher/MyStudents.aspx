<%@ Page Title="" Language="C#" MasterPageFile="~/Teacher/TeacherMaster.Master" AutoEventWireup="true" CodeBehind="MyStudents.aspx.cs" Inherits="LMS_Project.Teacher.MyStudents" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

    <div class="card shadow">
        <div class="card-header bg-success text-white">
            <h5 class="mb-0">Assigned Students</h5>
        </div>

        <div class="card-body">

            <asp:GridView ID="gvStudents" runat="server"
                CssClass="table table-bordered table-striped"
                AutoGenerateColumns="false"
                EmptyDataText="No students assigned.">

                <Columns>
                    <asp:BoundField DataField="StudentName" HeaderText="Student Name" />
                    <asp:BoundField DataField="Email" HeaderText="Email" />
                    <asp:BoundField DataField="SubjectName" HeaderText="Subject" />
                    <asp:BoundField DataField="SessionName" HeaderText="Session" />
                </Columns>

            </asp:GridView>

        </div>
    </div>

</asp:Content>