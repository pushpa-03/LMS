<%@ Page Title="My Students" Language="C#" 
    MasterPageFile="~/Teacher/TeacherMaster.Master" 
    AutoEventWireup="true" 
    CodeBehind="MyStudents.aspx.cs" 
    Inherits="LMS_Project.Teacher.MyStudents" %>

<asp:Content ID="cHead" ContentPlaceHolderID="head" runat="server">
<style>

/* ── Page Banner ── */
.page-banner {
    background: linear-gradient(135deg, #1565c0 0%, #1976d2 60%, #42a5f5 100%);
    border-radius: 16px;
    padding: 24px 32px;
    color: #fff;
    margin-bottom: 24px;
    position: relative;
    overflow: hidden;
}
.page-banner::after {
    content: "\f0c0";
    font-family: "Font Awesome 6 Free";
    font-weight: 900;
    position: absolute;
    right: 32px;
    top: 50%;
    transform: translateY(-50%);
    font-size: 80px;
    opacity: .12;
    color: #fff;
}
.page-banner h4 { margin: 0 0 4px; font-weight: 800; font-size: 20px; }
.page-banner p  { margin: 0; opacity: .85; font-size: 13px; }

/* ── Summary strip ── */
.summary-strip {
    background: #fff;
    border-radius: 14px;
    box-shadow: 0 2px 8px rgba(0,0,0,.06);
    padding: 16px 24px;
    display: flex;
    align-items: center;
    gap: 10px;
    margin-bottom: 20px;
    font-size: 14px;
    color: #455a64;
}
.summary-strip i      { color: #1976d2; font-size: 18px; }
.summary-strip strong { color: #1565c0; }

/* ── Search/Filter bar ── */
.filter-bar {
    background: #fff;
    border-radius: 14px;
    box-shadow: 0 2px 8px rgba(0,0,0,.06);
    padding: 14px 20px;
    margin-bottom: 20px;
    display: flex;
    align-items: center;
    gap: 12px;
    flex-wrap: wrap;
}
.filter-bar input {
    border: 1px solid #bbdefb;
    border-radius: 10px;
    padding: 8px 14px 8px 36px;
    font-size: 13px;
    outline: none;
    flex: 1;
    min-width: 200px;
    color: #455a64;
    background: #e3f2fd;
}
.filter-bar input:focus {
    border-color: #42a5f5;
    background: #fff;
}
.search-wrap {
    position: relative;
    flex: 1;
    min-width: 200px;
}
.search-wrap i {
    position: absolute;
    left: 12px;
    top: 50%;
    transform: translateY(-50%);
    color: #64b5f6;
    font-size: 13px;
}

/* ── Panel card ── */
.panel-card {
    background: #fff;
    border-radius: 14px;
    box-shadow: 0 2px 8px rgba(0,0,0,.06);
    padding: 20px;
}

/* ── Student table ── */
.student-table {
    width: 100%;
    border-collapse: collapse;
}
.student-table thead tr {
    background: #e3f2fd;
}
.student-table thead th {
    padding: 12px 16px;
    font-size: 11px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: .6px;
    color: #1565c0;
    border: none;
}
.student-table tbody tr {
    border-bottom: 1px solid #e3f2fd;
    transition: background .15s;
}
.student-table tbody tr:last-child { border-bottom: none; }
.student-table tbody tr:hover { background: #e8eaf6; }
.student-table td {
    padding: 13px 16px;
    font-size: 13px;
    color: #455a64;
    vertical-align: middle;
    border: none;
}

/* ── Avatar initials ── */
.s-avatar {
    width: 36px; height: 36px;
    border-radius: 50%;
    background: #e3f2fd;
    color: #1565c0;
    font-weight: 700;
    font-size: 14px;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
    margin-right: 10px;
}

/* ── Name cell ── */
.name-cell {
    display: flex;
    align-items: center;
}
.name-cell .s-name  { font-weight: 600; color: #263238; font-size: 13px; }
.name-cell .s-email { font-size: 11px; color: #90a4ae; margin-top: 1px; }

/* ── Pills ── */
.pill {
    display: inline-block;
    padding: 3px 12px;
    border-radius: 20px;
    font-size: 11px;
    font-weight: 700;
}
.pill-green  { background: #e3f2fd; color: #1565c0; }
.pill-teal   { background: #e0f2f1; color: #00796b; }
.pill-lime   { background: #e8eaf6; color: #283593; }

/* ── Empty state ── */
.empty-state {
    text-align: center;
    padding: 50px 20px;
    color: #90a4ae;
}
.empty-state i { font-size: 48px; margin-bottom: 12px; display: block; color: #90caf9; }
.empty-state h6 { font-weight: 700; color: #78909c; margin-bottom: 4px; }
.empty-state p  { font-size: 13px; margin: 0; }

</style>
</asp:Content>

<asp:Content ID="cBody" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

<%-- ══ PAGE BANNER ══ --%>
<div class="page-banner">
    <h4><i class="fas fa-users me-2"></i>My Students</h4>
    <p>All students enrolled in your subjects for the current session.</p>
</div>

<%-- ══ SUMMARY STRIP ══ --%>
<div class="summary-strip">
    <i class="fas fa-user-graduate"></i>
    You have <strong>&nbsp;<asp:Label ID="lblStudentCount" runat="server" Text="0" />&nbsp;</strong>
    student(s) assigned across your subjects.
</div>

<%-- ══ SEARCH BAR ══ --%>
<div class="filter-bar">
    <div class="search-wrap">
        <i class="fas fa-search"></i>
        <input type="text" id="txtSearch" placeholder="Search by name, email or subject..." 
               onkeyup="filterTable()" />
    </div>
</div>

<%-- ══ STUDENT TABLE ══ --%>
<div class="panel-card">

    <asp:Panel ID="pnlStudents" runat="server">
        <div style="overflow-x:auto;">
            <table class="student-table" id="studentTable">
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Student</th>
                        <th>Subject</th>
                        <th>Session</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptStudents" runat="server">
                        <ItemTemplate>
                           <tr style="cursor:pointer;" onclick="location.href='MyStudentDetails.aspx?UserId=<%# Eval("UserId") %>'">
                                <td style="color:#b0bec5; font-size:12px;">
                                    <%# Container.ItemIndex + 1 %>
                                </td>
                                <td>
                                    <div class="name-cell">
                                        <div class="s-avatar">
                                            <%# Eval("StudentName").ToString().Length > 0 
                                                ? Eval("StudentName").ToString().Substring(0,1).ToUpper() 
                                                : "S" %>
                                        </div>
                                        <div>
                                            <div class="s-name"><%# Eval("StudentName") %></div>
                                            <div class="s-email"><%# Eval("Email") %></div>
                                        </div>
                                    </div>
                                </td>
                                <td>
                                    <span class="pill pill-teal">
                                        <i class="fas fa-book me-1"></i><%# Eval("SubjectName") %>
                                    </span>
                                </td>
                                <td>
                                    <span class="pill pill-lime">
                                        <i class="fas fa-calendar me-1"></i><%# Eval("SessionName") %>
                                    </span>
                                </td>
                                <td>
                                    <span class="pill pill-green">
                                        <i class="fas fa-circle me-1" style="font-size:7px;"></i>Active
                                    </span>
                                </td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlEmpty" runat="server" Visible="false">
        <div class="empty-state">
            <i class="fas fa-user-slash"></i>
            <h6>No Students Found</h6>
            <p>No students are enrolled in your subjects yet.</p>
        </div>
    </asp:Panel>

</div>

<script>
    function filterTable() {
        const input = document.getElementById("txtSearch").value.toLowerCase();
        const rows = document.querySelectorAll("#studentTable tbody tr");
        rows.forEach(function (row) {
            row.style.display = row.innerText.toLowerCase().includes(input) ? "" : "none";
        });
    }
</script>

</asp:Content>