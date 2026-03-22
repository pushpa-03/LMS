<%@ Page Title="My Courses"
    Language="C#"
    MasterPageFile="~/Teacher/TeacherMaster.master"
    AutoEventWireup="true"
    CodeBehind="TeacherCourses.aspx.cs"
    Inherits="LMS_Project.Teacher.TeacherCourses" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

<style>
.subject-card {
    background:#fff;
    border-radius:12px;
    box-shadow:0 2px 10px rgba(0,0,0,.08);
    padding:16px;
    transition:.2s;
    border:1px solid #e3e8f0;
}
.subject-card:hover {
    transform:translateY(-4px);
    box-shadow:0 8px 20px rgba(0,0,0,.12);
}
.subject-title {
    font-weight:700;
    font-size:16px;
    color:#1565c0;
}
.subject-meta {
    font-size:13px;
    color:#607d8b;
    margin-top:6px;
}
.badge-session {
    display:inline-block;
    margin-top:10px;
    padding:4px 10px;
    background:#e3f2fd;
    color:#1565c0;
    border-radius:12px;
    font-size:12px;
}
</style>

<div class="card shadow">
    <div class="card-header bg-success text-white">
        <h5 class="mb-0">My Assigned Subjects</h5>
    </div>

    <div class="card-body">

        <!-- SUBJECT CARDS -->
        <asp:Panel ID="pnlCourses" runat="server">
            <div class="row g-3">
                <asp:Repeater ID="rptCourses" runat="server">
                    <ItemTemplate>
                        <div class="col-md-6 col-lg-4">
                            <div class="subject-card">

                                <div class="subject-title">
                                    <%# Eval("SubjectName") %>
                                </div>

                                <div class="subject-meta">
                                    <b>Section:</b> <%# Eval("SectionName") %>
                                </div>

                                <div class="badge-session">
                                    <%# Eval("SessionName") %>
                                </div>

                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </asp:Panel>

        <!-- EMPTY STATE -->
        <asp:Panel ID="pnlEmpty" runat="server" Visible="false">
            <div style="text-align:center; padding:40px; color:#90a4ae;">
                <h5>No subjects assigned yet</h5>
            </div>
        </asp:Panel>

    </div>
</div>

</asp:Content>