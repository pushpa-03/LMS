<%@ Page Title="Students List" Language="C#" MasterPageFile="~/Admin/AdminMaster.master"
    AutoEventWireup="true" CodeBehind="StudentsList.aspx.cs"
    Inherits="LearningManagementSystem.Admin.StudentsList" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server" />
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

<!-- HEADER -->
<div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-3">

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

            <asp:LinkButton ID="btnResetFilters" runat="server"
            CssClass="btn btn-light border rounded-pill px-3"
            OnClick="btnResetFilters_Click">
            <i class="fas fa-undo me-1 text-primary"></i> Reset
        </asp:LinkButton>

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

<!-- ✅ MODERN STUDENT GRID VIEW -->
<div class="row g-3" id="studentsGrid">

<asp:Repeater ID="rptHierarchy" runat="server">
<ItemTemplate>

    <asp:Repeater runat="server" DataSource='<%# Eval("Courses") %>'>
    <ItemTemplate>

        <asp:Repeater runat="server" DataSource='<%# Eval("Levels") %>'>
        <ItemTemplate>

            <asp:Repeater runat="server" DataSource='<%# Eval("Semesters") %>'>
            <ItemTemplate>

                <asp:Repeater runat="server" DataSource='<%# Eval("Sections") %>'>
                <ItemTemplate>

                    <asp:Repeater runat="server" DataSource='<%# Eval("Students") %>'>
                    <ItemTemplate>

                        <!-- 🔥 STUDENT CARD -->
                        <div class="col-12 col-sm-6 col-md-4 col-xl-3 student-card-wrapper">

                            <div class="student-card">

                                <!-- Avatar -->
                                <div class="student-avatar">
                                    <i class="fas fa-user-graduate"></i>
                                </div>

                                <!-- Info -->
                                <div class="student-info">

                                    <div class="student-name">
                                        <%# Eval("FullName") %>
                                    </div>

                                    <div class="student-roll">
                                        <i class="fas fa-id-badge me-1"></i>
                                        <%# Eval("RollNumber") %>
                                    </div>

                                    <div class="student-meta">
                                        <i class="fas fa-envelope"></i>
                                        <%# Eval("Email") %>
                                    </div>

                                </div>

                                <!-- Status -->
                                <div class="student-status">
                                    <%# Convert.ToBoolean(Eval("IsActive")) 
                                        ? "<span class='badge-active'>Active</span>" 
                                        : "<span class='badge-inactive'>Inactive</span>" %>
                                </div>

                                <!-- Action -->
                                <a href='StudentDetails.aspx?id=<%# Eval("UserId") %>' 
                                   class="btn-view">
                                    View Profile
                                </a>

                            </div>

                        </div>

                    </ItemTemplate>
                    </asp:Repeater>

                </ItemTemplate>
                </asp:Repeater>

            </ItemTemplate>
            </asp:Repeater>

        </ItemTemplate>
        </asp:Repeater>

    </ItemTemplate>
    </asp:Repeater>

</ItemTemplate>
</asp:Repeater>

</div>

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



/* ===== SEARCH ===== */
.search-box {
    position: relative;
}
.search-box i {
    position: absolute;
    top: 10px;
    left: 12px;
    color: #90a4ae;
}
.search-box input {
    padding-left: 35px;
    border-radius: 20px;
    border: 1px solid #e3e8f0;
}

/* ===== FILTER CARD ===== */
.card {
    border-radius: 14px !important;
}

/* ===== STAT CARDS (Student Style) ===== */
.summary-row {
    display: flex;
    gap: 16px;
    flex-wrap: wrap;
}

.summary-card {
    background: #fff;
    border-radius: 14px;
    padding: 20px;
    flex: 1;
    min-width: 180px;
    display: flex;
    align-items: center;
    gap: 14px;
    box-shadow: 0 2px 10px rgba(0,0,0,.07);
    transition: .2s;
}
.summary-card:hover {
    transform: translateY(-4px);
    box-shadow: 0 6px 18px rgba(0,0,0,.12);
}

.sc-icon {
    width: 52px;
    height: 52px;
    border-radius: 14px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 20px;
}

/* COLORS */
.summary-card.blue  { background:#e3f2fd; }
.summary-card.green { background:#e8f5e9; }
.summary-card.red   { background:#ffebee; }

.sc-icon.blue  { background:#1976d2; color:#fff; }
.sc-icon.green { background:#2e7d32; color:#fff; }
.sc-icon.red   { background:#c62828; color:#fff; }

.sc-val {
    font-size: 28px;
    font-weight: 800;
}
.sc-lbl {
    font-size: 11px;
    font-weight: 700;
    color: #78909c;
}

/*===================Reset button ==================*/
.btn-light {
    background: #fff;
    border: 1px solid #e3e8f0;
    font-weight: 600;
    font-size: 13px;
    transition: .2s;
}

.btn-light:hover {
    background: #1565c0;
    color: #fff;
    border-color: #1565c0;
}

/* ================= STUDENT GRID ================= */

.student-card-wrapper {
    display: flex;
}

/* Card */
.student-card {
    background: #fff;
    border-radius: 16px;
    padding: 18px;
    width: 100%;
    position: relative;
    box-shadow: 0 2px 10px rgba(0,0,0,.07);
    transition: .25s;
    display: flex;
    flex-direction: column;
    align-items: center;
    text-align: center;
}

.student-card:hover {
    transform: translateY(-6px);
    box-shadow: 0 10px 25px rgba(0,0,0,.12);
}

/* Avatar */
.student-avatar {
    width: 60px;
    height: 60px;
    border-radius: 50%;
    background: #e3f2fd;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 26px;
    color: #1976d2;
    margin-bottom: 10px;
}

/* Name */
.student-name {
    font-weight: 700;
    font-size: 15px;
    color: #263238;
}

/* Roll */
.student-roll {
    font-size: 12px;
    font-weight: 600;
    color: #1976d2;
    margin-top: 4px;
}

/* Meta */
.student-meta {
    font-size: 12px;
    color: #78909c;
    margin-top: 6px;
}

/* Status */
.student-status {
    margin-top: 10px;
}

.badge-active {
    background: #e8f5e9;
    color: #2e7d32;
    padding: 4px 10px;
    border-radius: 12px;
    font-size: 11px;
    font-weight: 700;
}

.badge-inactive {
    background: #ffebee;
    color: #c62828;
    padding: 4px 10px;
    border-radius: 12px;
    font-size: 11px;
    font-weight: 700;
}

/* Button */
.btn-view {
    margin-top: 12px;
    display: inline-block;
    padding: 6px 16px;
    border-radius: 20px;
    font-size: 12px;
    font-weight: 600;
    background: #e3f2fd;
    color: #1565c0;
    text-decoration: none;
    transition: .2s;
}

.btn-view:hover {
    background: #1565c0;
    color: #fff;
}

/* ================= RESPONSIVE ================= */
@media(max-width:768px){
    .student-card {
        padding: 16px;
    }
}

/* ===== RESPONSIVE ===== */
@media(max-width:768px){
    .page-header {
        padding:18px;
    }
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