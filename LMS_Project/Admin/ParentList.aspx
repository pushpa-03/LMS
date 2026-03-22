<%@ Page Title="Parent List" Language="C#" 
MasterPageFile="~/Admin/AdminMaster.master"
AutoEventWireup="true"
CodeBehind="ParentList.aspx.cs"
Inherits="LearningManagementSystem.Admin.ParentList" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server" />

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

<!-- HEADER -->
<div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-3">

    <div>
        <h3 class="fw-bold mb-1">Parent Directory</h3>
        <small class="text-muted">View all parents mapped with students</small>
        <span class="mx-2 text-muted">|</span>
        <small class="text-muted">
            Last updated: <%= DateTime.Now.ToString("dd MMM yyyy hh:mm tt") %>
        </small>
    </div>

    <div class="d-flex align-items-center gap-2 flex-wrap">

        <!-- SEARCH -->
        <div class="search-box">
            <asp:TextBox ID="txtSearch" runat="server"
                CssClass="form-control"
                placeholder="Search student / parent..."
                onkeyup="filterParents()" />
        </div>

        <!-- TOGGLE -->
        <asp:LinkButton ID="btnToggleView" runat="server"
            CssClass="btn btn-outline-primary rounded-pill px-3"
            OnClick="ToggleView_Click">
            👁 View Inactive
        </asp:LinkButton>

    </div>
</div>

<!-- STATS -->
<div class="row mb-4 g-3">

    <div class="col-md-3">
        <div class="stat-card modern blue">
            <div class="stat-icon">
                <i class="fa fa-users"></i>
            </div>
            <div>
                <h6>Total Parents</h6>
                <h3 class="counter"><%= TotalParents %></h3>
            </div>
        </div>
    </div>

    <div class="col-md-3">
        <div class="stat-card modern success">
            <div class="stat-icon">
                <i class="fa fa-user-check"></i>
            </div>
            <div>
                <h6>Active</h6>
                <h3 class="counter"><%= ActiveParents %></h3>
            </div>
        </div>
    </div>

    <div class="col-md-3">
        <div class="stat-card modern warning">
            <div class="stat-icon">
                <i class="fa fa-user-times"></i>
            </div>
            <div>
                <h6>Inactive</h6>
                <h3 class="counter"><%= InactiveParents %></h3>
            </div>
        </div>
    </div>

    <div class="col-md-3">
        <div class="stat-card modern info">
            <div class="stat-icon">
                <i class="fa fa-link"></i>
            </div>
            <div>
                <h6>Student Links</h6>
                <h3 class="counter"><%= TotalLinks %></h3>
            </div>
        </div>
    </div>

</div>

<!-- STUDENT + PARENT UI -->
<asp:Repeater ID="rptStudents" runat="server">
    <ItemTemplate>

        <!-- STUDENT CARD -->
        <div class="student-card mb-4">

            <div class="student-header">
                <h5><%# Eval("StudentName") %></h5>
                <div class="student-meta">
                    <%# Eval("Stream") %> • 
                    <%# Eval("Course") %> • 
                    <%# Eval("Level") %> • 
                    <%# Eval("Semester") %> • 
                    <%# Eval("Section") %> • 
                    <%# Eval("Session") %>
                </div>
            </div>

            <!-- PARENTS -->
            <div class="parent-list">
                <asp:Repeater ID="rptParents" runat="server" DataSource='<%# Eval("Parents") %>'>
                    <ItemTemplate>
                        <div class="parent-card">
                            <div>
                                <strong><%# Eval("ParentName") %></strong>
                                <div class="text-muted small">
                                    <%# Eval("Relation") %>
                                </div>
                            </div>

                            <div class="text-end">
                                <div><%# Eval("Email") %></div>
                                <div><%# Eval("ContactNo") %></div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>

        </div>

    </ItemTemplate>
</asp:Repeater>

<style>
/* SEARCH */
.search-box input {
    border-radius: 30px;
    padding-left: 15px;
}

/* STATS */
/* MODERN STAT CARD */
.stat-card.modern {
    position: relative;
    display: flex;
    align-items: center;
    gap: 15px;
    padding: 22px;
    border-radius: 18px;
    color: white;
    overflow: hidden;
    backdrop-filter: blur(12px);
    transition: 0.4s ease;
    box-shadow: 0 10px 25px rgba(0,0,0,0.08);
}

/* ICON */
.stat-icon {
    font-size: 22px;
    background: rgba(255,255,255,0.2);
    padding: 12px;
    border-radius: 12px;
}

/* GRADIENT COLORS */
.stat-card.blue {
    background: linear-gradient(135deg,#2563eb,#3b82f6);
}
.stat-card.success {
    background: linear-gradient(135deg,#16a34a,#22c55e);
}
.stat-card.warning {
    background: linear-gradient(135deg,#f59e0b,#fbbf24);
}
.stat-card.info {
    background: linear-gradient(135deg,#0ea5e9,#38bdf8);
}

/* TEXT */
.stat-card h6 {
    font-size: 13px;
    opacity: 0.85;
}
.stat-card h3 {
    margin: 0;
    font-weight: 700;
}

/* HOVER EFFECT */
.stat-card:hover {
    transform: translateY(-8px) scale(1.02);
    box-shadow: 0 15px 40px rgba(0,0,0,0.15);
}

/* SHINE EFFECT */
.stat-card::before {
    content: "";
    position: absolute;
    top: 0;
    left: -75%;
    width: 50%;
    height: 100%;
    background: linear-gradient(
        120deg,
        rgba(255,255,255,0.1),
        rgba(255,255,255,0.5),
        rgba(255,255,255,0.1)
    );
    transform: skewX(-25deg);
}

.stat-card:hover::before {
    animation: shine 0.9s ease;
}

@keyframes shine {
    100% {
        left: 125%;
    }
}

/* COUNTER ANIMATION */
.counter {
    animation: pop 0.6s ease;
}

@keyframes pop {
    0% { transform: scale(0.8); opacity: 0; }
    100% { transform: scale(1); opacity: 1; }
}

/* STUDENT CARD */
.student-card {
    border-radius: 16px;
    background: #f8fafc;
    border: 1px solid #e2e8f0;
    overflow: hidden;
}

/* HEADER */
.student-header {
    background: linear-gradient(135deg, #4f46e5, #6366f1);
    color: white;
    padding: 15px 20px;
}
.student-meta {
    font-size: 13px;
    opacity: 0.9;
}

/* PARENT LIST */
.parent-list {
    padding: 15px;
}

/* PARENT CARD */
.parent-card {
    display: flex;
    justify-content: space-between;
    background: white;
    border-radius: 10px;
    padding: 12px 15px;
    margin-bottom: 10px;
    border: 1px solid #e5e7eb;
    transition: 0.2s;
}
.parent-card:hover {
    background: #f1f5f9;
    transform: scale(1.01);
}
</style>

<script>
function filterParents() {
    let val = document.getElementById("<%= txtSearch.ClientID %>").value.toLowerCase();

    document.querySelectorAll(".student-card").forEach(card => {
        card.style.display =
            card.innerText.toLowerCase().includes(val) ? "" : "none";
    });

    LoadStat();
}
</script>

</asp:Content>