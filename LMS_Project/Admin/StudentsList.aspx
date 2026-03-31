<%@ Page Title="Students List" Language="C#" MasterPageFile="~/Admin/AdminMaster.master"
    AutoEventWireup="true" CodeBehind="StudentsList.aspx.cs"
    Inherits="LearningManagementSystem.Admin.StudentsList" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server" />
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

<!-- HEADER -->
<div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-3">

    <%--<div class="title-header">
        <h3 class="fw-bold mb-1 ">Students Overview</h3>
        <small class="text-muted">View and analyze students structure</small>
    </div>--%>
    <div class="page-header">
    <div>
        <h4><i class="fa fa-book me-2"></i>Students Overview</h4>
        <small class="text-muted">View and analyze students structure</small>
        <span class="badge bg-primary rounded-pill">
            <%# Eval("TotalStudents") %> Students
        </span>
        <span>|</span>
        <small class="text-muted">
            Last updated: <%= DateTime.Now.ToString("dd MMM yyyy hh:mm tt") %>
        </small>
    </div>
   </div>

    <div class="d-flex gap-2 flex-wrap">

        <!-- SEARCH -->
        <div class="search-box">
            <i class="fa fa-search"></i>
            <asp:TextBox ID="txtSearch" runat="server"
                CssClass="form-control"
                placeholder="Search students..."
                onkeyup="filterStudents()" />
        </div>

        <!-- VIEW SWITCH -->
        <asp:LinkButton ID="btnToggleView" runat="server"
            CssClass="btn btn-outline-dark rounded-pill px-3"
            OnClick="ToggleView_Click">
            👁 View Inactive
        </asp:LinkButton>

    </div>
</div>

<!-- ✅ FILTERS -->
<div class="card shadow-sm border-0 rounded-4 mb-4">
    <div class="card-body">
        <div class="row g-3">

            <div class="col-md-2">
                <asp:DropDownList ID="ddlStream" runat="server" CssClass="form-select"
                    AutoPostBack="true" OnSelectedIndexChanged="FilterChanged" />
            </div>

            <div class="col-md-2">
                <asp:DropDownList ID="ddlCourse" runat="server" CssClass="form-select"
                    AutoPostBack="true" OnSelectedIndexChanged="FilterChanged" />
            </div>

            <div class="col-md-2">
                <asp:DropDownList ID="ddlLevel" runat="server" CssClass="form-select"
                    AutoPostBack="true" OnSelectedIndexChanged="FilterChanged" />
            </div>

            <div class="col-md-2">
                <asp:DropDownList ID="ddlSemester" runat="server" CssClass="form-select"
                    AutoPostBack="true" OnSelectedIndexChanged="FilterChanged" />
            </div>

            <div class="col-md-2">
                <asp:DropDownList ID="ddlSection" runat="server" CssClass="form-select"
                    AutoPostBack="true" OnSelectedIndexChanged="FilterChanged" />
            </div>

        </div>
    </div>
</div>

<!-- ✅ STAT CARDS -->
<div class="summary-row mb-4">

    <div class="summary-card blue">
        <div class="sc-icon blue"><i class="fas fa-users"></i></div>
        <div>
            <div class="sc-val"><%= TotalStudents %></div>
            <div class="sc-lbl">Total Students</div>
        </div>
    </div>

    <div class="summary-card green">
        <div class="sc-icon green"><i class="fas fa-check"></i></div>
        <div>
            <div class="sc-val"><%= ActiveStudents %></div>
            <div class="sc-lbl">Active</div>
        </div>
    </div>

    <div class="summary-card red">
        <div class="sc-icon red"><i class="fas fa-times"></i></div>
        <div>
            <div class="sc-val"><%= InactiveStudents %></div>
            <div class="sc-lbl">Inactive</div>
        </div>
    </div>

</div>

<!-- ✅ HIERARCHY VIEW -->
<asp:Repeater ID="rptHierarchy" runat="server">
<ItemTemplate>

<div class="stream-card">

    <h4 class="stream-title"><%# Eval("StreamName") %></h4>

    <asp:Repeater runat="server" DataSource='<%# Eval("Courses") %>'>
    <ItemTemplate>

        <div class="course-card">
            <h5><%# Eval("CourseName") %></h5>

            <asp:Repeater runat="server" DataSource='<%# Eval("Levels") %>'>
            <ItemTemplate>

                <div class="level-card">
                    <b><%# Eval("LevelName") %></b>

                    <asp:Repeater runat="server" DataSource='<%# Eval("Semesters") %>'>
                    <ItemTemplate>

                        <div class="semester-card">
                            <span>Semester: <%# Eval("SemesterName") %></span>

                            <asp:Repeater runat="server" DataSource='<%# Eval("Sections") %>'>
                            <ItemTemplate>

                                <div class="section-card">
                                    <b>Section <%# Eval("SectionName") %></b>

                                    <asp:Repeater runat="server" DataSource='<%# Eval("Students") %>'>
                                    <ItemTemplate>

                                        <div class="student-row">
                                            <span>
                                                <%# Eval("RollNumber") %> - <%# Eval("FullName") %>
                                            </span>

                                            <a href='StudentDetails.aspx?id=<%# Eval("UserId") %>' 
                                               class="btn btn-sm btn-primary">
                                               View
                                            </a>
                                        </div>

                                    </ItemTemplate>
                                    </asp:Repeater>

                                </div>

                            </ItemTemplate>
                            </asp:Repeater>

                        </div>

                    </ItemTemplate>
                    </asp:Repeater>

                </div>

            </ItemTemplate>
            </asp:Repeater>

        </div>

    </ItemTemplate>
    </asp:Repeater>

</div>

</ItemTemplate>
</asp:Repeater>

<style>
body {
    font-family: 'Segoe UI', sans-serif;
}

/* HEADER */
.page-header {
    display:flex; justify-content:space-between;
    align-items:center; flex-wrap:wrap;
    margin-bottom:20px;
}
.page-header h4 {
    font-weight:800; color:#1565c0;
}
.table-header {
    background: linear-gradient(135deg, #4f46e5, #6366f1) !important;
    color: white;
}

/* SUMMARY SAME AS SUBJECT */
.summary-row{display:flex;gap:14px;flex-wrap:wrap;}
.summary-card{background:#fff;border-radius:14px;padding:16px;flex:1;min-width:160px;display:flex;align-items:center;gap:12px;box-shadow:0 2px 8px rgba(0,0,0,.06);border-left:4px solid transparent;}
.summary-card.blue{border-left-color:#1565c0;}
.summary-card.green{border-left-color:#2e7d32;}
.summary-card.red{border-left-color:#c62828;}
.sc-icon{width:44px;height:44px;border-radius:12px;display:flex;align-items:center;justify-content:center;font-size:18px;}
.sc-icon.blue{background:#e3f2fd;color:#1565c0;}
.sc-icon.green{background:#e8f5e9;color:#2e7d32;}
.sc-icon.red{background:#ffebee;color:#c62828;}
.sc-val{font-size:24px;font-weight:900;}
.sc-lbl{font-size:11px;color:#90a4ae;font-weight:700;}

/* HIERARCHY */
.hierarchy-card{
    font-family: 'Segoe UI', sans-serif;
    background:#fff;
    border-radius:16px;
    padding:18px;
    margin-bottom:14px;
    box-shadow:0 4px 12px rgba(0,0,0,.08);
    transition:.3s;
}
.hierarchy-card:hover{transform:translateY(-4px);}

.h-stream{font-weight:800;color:#1565c0;font-size:16px; font-family: 'Segoe UI', sans-serif;}
.h-course{font-weight:700;color:#0f172a; font-family: 'Segoe UI', sans-serif;}
.h-meta{font-size:12px;color:#64748b;margin-bottom:10px; font-family: 'Segoe UI', sans-serif;}

.h-students{display:flex;flex-wrap:wrap;gap:8px; font-family: 'Segoe UI', sans-serif;}

.student-pill{
    background:#eef2ff;
    padding:6px 10px;
    border-radius:20px;
    font-size:12px;
    font-weight:600;
     font-family: 'Segoe UI', sans-serif;
}

/* SEARCH */
.search-box{position:relative;}
.search-box i{position:absolute;top:10px;left:12px;}
.search-box input{padding-left:35px;border-radius:20px;}

.stream-card{
    background:#fff;
    padding:18px;
    border-radius:16px;
    margin-bottom:15px;
    box-shadow:0 4px 10px rgba(0,0,0,.08);
}

.stream-title{
    color:#1565c0;
    font-weight:800;
    font-family: 'Segoe UI', sans-serif;
}

.course-card{
    margin-top:10px;
    padding-left:15px;
    font-family: 'Segoe UI', sans-serif;
}

.level-card{
    margin-top:8px;
    padding-left:20px;
    font-family: 'Segoe UI', sans-serif;
}

.semester-card{
    margin-top:6px;
    padding-left:25px;
    font-family: 'Segoe UI', sans-serif;
}

.section-card{
    margin-top:6px;
    padding-left:30px;
    font-family: 'Segoe UI', sans-serif;
}

.student-row{
    display:flex;
    justify-content:space-between;
    align-items:center;
    background:#f1f5f9;
    padding:6px 10px;
    border-radius:8px;
    margin-top:5px;
    font-family: 'Segoe UI', sans-serif;
}
</style>

<script>
function filterStudents(){
 let val=document.getElementById("<%= txtSearch.ClientID %>").value.toLowerCase();
 document.querySelectorAll(".hierarchy-card").forEach(c=>{
   c.style.display=c.innerText.toLowerCase().includes(val)?"":"none";
 });
}
</script>

</asp:Content>