<%@ Page Title="Course List"
    Language="C#"
    MasterPageFile="~/Admin/AdminMaster.master"
    AutoEventWireup="true"
    CodeBehind="CourseList.aspx.cs"
    Inherits="LearningManagementSystem.Admin.CourseList" %>

<asp:Content ID="cHead" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<style>

/* ===== FONT SYSTEM (FROM RESULTS PAGE) ===== */
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

/* SUMMARY CARDS */
.summary-row { display:flex; gap:14px; flex-wrap:wrap; margin-bottom:20px; }

.summary-card {
    background:#fff;
    border-radius:14px;
    padding:16px;
    flex:1; min-width:160px;
    display:flex; align-items:center; gap:12px;
    box-shadow:0 2px 8px rgba(0,0,0,.06);
    border-left:4px solid transparent;
}

.summary-card.blue { border-left-color:#1565c0; }
.summary-card.green { border-left-color:#2e7d32; }
.summary-card.red { border-left-color:#c62828; }

.summary-card:hover {
    transform: translateY(-4px);
    box-shadow: 0 15px 35px rgba(0,0,0,0.15);
}

.sc-icon {
    width:44px; height:44px;
    border-radius:12px;
    display:flex; align-items:center; justify-content:center;
    font-size:18px;
}
.sc-icon.blue { background:#e3f2fd; color:#1565c0; }
.sc-icon.green { background:#e8f5e9; color:#2e7d32; }
.sc-icon.red { background:#ffebee; color:#c62828; }

.sc-val { font-size:24px; font-weight:900; color:#263238; }
.sc-lbl { font-size:11px; font-weight:700; color:#90a4ae; }

/* SEARCH */
.filter-bar {
    background:#fff;
    border-radius:12px;
    padding:12px;
    margin-bottom:16px;
    box-shadow:0 1px 5px rgba(0,0,0,.05);
}

/* STREAM CARD */
.stream-card {
    background:#fff;
    border-radius:12px;
    margin-bottom:14px;
    box-shadow:0 1px 6px rgba(0,0,0,.06);
    overflow:hidden;
}

.stream-card:hover {
    transform: translateY(-4px);
    box-shadow: 0 15px 35px rgba(0,0,0,0.15);
}

/* STREAM HEADER */
.stream-header {
    padding:14px 18px;
    background:#1565c0;
    color:#fff;
    cursor:pointer;
}

.stream-header:hover {
    background: linear-gradient(135deg, #4338ca, #4f46e5);
}
.stream-title {
    font-size:14px;
    font-weight:800;
}

.stream-badge {
    font-size:11px;
    font-weight:700;
    margin-left:10px;
}

/* COURSE TABLE */
.course-table {
    font-size:13px;
}

.course-table tr:hover {
    background:#f5f9ff;
}


/* COURSE TEXT */
.course-item {
    font-size:13px;
    font-weight:700;
}

.course-code {
    font-size:11px;
    font-weight:700;
    color:#1565c0;
}

.empty-state {
    text-align:center;
    padding:40px;
    color:#90a4ae;
}

</style>

</asp:Content>

<asp:Content ID="cBody" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

<!-- HEADER -->
<div class="page-header">
    <div>
        <h4><i class="fas fa-book me-2"></i>Courses</h4>
        <small class="text-muted">Admin Panel to manage courses</small>
        <span class="badge bg-primary rounded-pill">
            <%# Eval("CourseCount") %> Courses
        </span>
        <span>|</span>
        <small class="text-muted">
            Last updated: <%= DateTime.Now.ToString("dd MMM yyyy hh:mm tt") %>
        </small>
    </div>

    <div class="d-flex gap-2">
        <div class="dropdown">
            <button class="btn btn-outline-primary rounded-pill dropdown-toggle"
                data-bs-toggle="dropdown">
                Filter
            </button>
            <ul class="dropdown-menu">
                <li><asp:LinkButton runat="server" CssClass="dropdown-item"
                    OnClick="FilterStatus_Click" CommandArgument="1">Active</asp:LinkButton></li>
                <li><asp:LinkButton runat="server" CssClass="dropdown-item"
                    OnClick="FilterStatus_Click" CommandArgument="0">Inactive</asp:LinkButton></li>
            </ul>
        </div>
    </div>
</div>


<!-- SUMMARY -->
<div class="summary-row">

    <div class="summary-card blue">
        <div class="sc-icon blue"><i class="fas fa-book"></i></div>
        <div>
            <div class="sc-val"><asp:Label ID="lblTotal" runat="server" /></div>
            <div class="sc-lbl">Total Courses</div>
        </div>
    </div>

    <div class="summary-card green">
        <div class="sc-icon green"><i class="fas fa-check"></i></div>
        <div>
            <div class="sc-val"><asp:Label ID="lblActive" runat="server" /></div>
            <div class="sc-lbl">Active</div>
        </div>
    </div>

    <div class="summary-card red">
        <div class="sc-icon red"><i class="fas fa-times"></i></div>
        <div>
            <div class="sc-val"><asp:Label ID="lblInactive" runat="server" /></div>
            <div class="sc-lbl">Inactive</div>
        </div>
    </div>

</div>

<!-- SEARCH -->
<div class="filter-bar">
    <input type="text" id="txtSearch" runat="server"
        class="form-control"
        placeholder="Search course..."
        onkeyup="this.form.submit();" />
</div>

<!-- STREAM + COURSE -->
<asp:Repeater ID="rptStreams" runat="server" OnItemDataBound="rptStreams_ItemDataBound">

    <ItemTemplate>

        <div class="stream-card ">

            <div class="stream-header "
                data-bs-toggle="collapse"
                data-bs-target="#stream_<%# Eval("StreamId") %>">
                
                <span class="stream-title">
                    📚 <%# Eval("StreamName") %>
                </span>

                <span class="stream-badge">
                    <%# Eval("CourseCount") %> Courses
                </span>

            </div>

            <div id="stream_<%# Eval("StreamId") %>" class="collapse show">

                <asp:GridView ID="gvInnerCourses" runat="server"
                    CssClass="table course-table mb-0"
                    AutoGenerateColumns="false"
                    GridLines="None">

                    <Columns>

                        <asp:TemplateField HeaderText="Course">
                            <ItemTemplate>
                                <div class="course-item">
                                    🎓 <%# Eval("CourseName") %>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Code">
                            <ItemTemplate>
                                <span class="course-code">
                                    <%# Eval("CourseCode") %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>


                    </Columns>

                </asp:GridView>

            </div>

        </div>

    </ItemTemplate>

</asp:Repeater>

</asp:Content>