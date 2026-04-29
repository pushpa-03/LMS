<%--<%@ Page Title="Admin | Subject Management" Language="C#" MasterPageFile="~/Admin/AdminMaster.master" AutoEventWireup="true" CodeBehind="Subjects.aspx.cs" Inherits="LearningManagementSystem.Admin.Subjects" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">
    <style>
        /* ===== PAGE HEADER (Results style) ===== */
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

       /* SUMMARY ROW */
            .summary-card {
                background:#fff;
                border-radius:14px;
                padding:14px;
                display:flex;
                align-items:center;
                gap:12px;
                box-shadow:0 2px 8px rgba(0,0,0,.06);
                border-left:4px solid transparent;
                transition:all .2s ease;
            }

            /* COLORS */
            .summary-card.blue { border-left-color:#1565c0; }
            .summary-card.green { border-left-color:#2e7d32; }
            .summary-card.red { border-left-color:#c62828; }
            .summary-card.pink { border-left-color:#9c4d9b; }
            .summary-card.yellow { border-left-color:#facc15; }
            .summary-card.orange { border-left-color:#f97316; }

            /* HOVER */
            .summary-card:hover {
                transform: translateY(-4px);
                box-shadow: 0 12px 28px rgba(0,0,0,0.12);
            }

            /* ICON */
            .sc-icon {
                width:42px;
                height:42px;
                border-radius:12px;
                display:flex;
                align-items:center;
                justify-content:center;
                font-size:16px;
            }

            /* ICON COLORS */
            .sc-icon.blue { background:#e3f2fd; color:#1565c0; }
            .sc-icon.green { background:#e8f5e9; color:#2e7d32; }
            .sc-icon.red { background:#ffebee; color:#c62828; }
            .sc-icon.pink { background:#fce4ec; color:#9c4d9b; }
            .sc-icon.yellow { background:#fff8e1; color:#f59e0b; }
            .sc-icon.orange { background:#fff3e0; color:#f97316; }

            /* TEXT */
            .sc-val {
                font-size:20px;
                font-weight:800;
                color:#263238;
            }

            .sc-lbl {
                font-size:11px;
                font-weight:700;
                color:#90a4ae;
            }
        .action-btn {
            padding: 8px 12px;
            border-radius: 8px;
            transition: 0.2s;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            justify-content: center;
        }

        .action-btn.edit { background: #dbeafe; color: #1e40af; }
        .action-btn.toggle-off { background: #fee2e2; color: #991b1b; }
        .action-btn.toggle-on { background: #dcfce7; color: #166534; }

        .badge-mandatory { background: #dcfce7; color: #166534; border: 1px solid #bbf7d0; }
        .badge-elective { background: #fef9c3; color: #854d0e; border: 1px solid #fef08a; }
        
        .text-muted-custom { color: #64748b; font-size: 0.85rem; }
    </style>

    <div class="container-fluid ">
        
        <div class="page-header">
            <div>
                <h4><i class="fa fa-book me-2"></i>Subject Management</h4>
                <small class="text-muted">Admin Panel to manage subjects</small>
                <span class="badge bg-primary rounded-pill">
                    <%# Eval("TotalSubjects") %> Subjects
                </span>
                <span>|</span>
                <small class="text-muted">
                    Last updated: <%= DateTime.Now.ToString("dd MMM yyyy hh:mm tt") %>
                </small>
            </div>

            <div class="d-flex align-items-center gap-3">
                <div class="form-check form-switch mb-0 bg-light rounded-pill px-3 py-1 border d-flex align-items-center gap-2" style="min-height: 38px;">
                    <asp:CheckBox ID="chkStatus" runat="server" AutoPostBack="true" 
                        OnCheckedChanged="chkStatus_CheckedChanged" 
                        CssClass="form-check-input ms-0 mt-0" role="switch" />

                    <label class="form-check-label fw-semibold small mb-0 cursor-pointer" for="<%= chkStatus.ClientID %>">
                        <%= chkStatus.Checked ? "Viewing Inactive" : "Viewing Active" %>
                    </label>
                </div>
           </div>
    </div>

 <div class="row g-3 mb-4 my-3">
    <asp:Repeater ID="rptStats" runat="server">
        <ItemTemplate>

            <div class="col-md-2">
                <div class="summary-card blue">
                    <div class="sc-icon blue"><i class="fa fa-book"></i></div>
                    <div>
                        <div class="sc-val"><%# Eval("TotalSubjects") %></div>
                        <div class="sc-lbl">Total</div>
                    </div>
                </div>
            </div>

            <div class="col-md-2">
                <div class="summary-card yellow">
                    <div class="sc-icon yellow"><i class="fa fa-star"></i></div>
                    <div>
                        <div class="sc-val"><%# Eval("MandatoryCount") %></div>
                        <div class="sc-lbl">Mandatory</div>
                    </div>
                </div>
            </div>

            <div class="col-md-2">
                <div class="summary-card pink">
                    <div class="sc-icon pink"><i class="fa fa-users"></i></div>
                    <div>
                        <div class="sc-val"><%# Eval("TotalEnrollments") %></div>
                        <div class="sc-lbl">Enrollments</div>
                    </div>
                </div>
            </div>

            <div class="col-md-2">
                <div class="summary-card orange">
                    <div class="sc-icon orange"><i class="fa fa-chart-line"></i></div>
                    <div>
                        <div class="sc-val"><%# Eval("AvgPerSubject") %></div>
                        <div class="sc-lbl">Average</div>
                    </div>
                </div>
            </div>

            <div class="col-md-2">
                <div class="summary-card green">
                    <div class="sc-icon green"><i class="fa fa-check"></i></div>
                    <div>
                        <div class="sc-val"><%# Eval("ActiveCount") %></div>
                        <div class="sc-lbl">Active</div>
                    </div>
                </div>
            </div>

            <div class="col-md-2">
                <div class="summary-card red">
                    <div class="sc-icon red"><i class="fa fa-times"></i></div>
                    <div>
                        <div class="sc-val"><%# Eval("InactiveCount") %></div>
                        <div class="sc-lbl">Inactive</div>
                    </div>
                </div>
            </div>

        </ItemTemplate>
    </asp:Repeater>
</div>

<div class="card shadow-sm border-0 rounded-4 p-3 mb-3">

    <div class="row g-2">

        <div class="col-md-3">
            <asp:DropDownList ID="ddlStream" runat="server" CssClass="form-select"
                AutoPostBack="true" OnSelectedIndexChanged="FilterChanged">
            </asp:DropDownList>
        </div>

        <div class="col-md-3">
            <asp:DropDownList ID="ddlCourse" runat="server" CssClass="form-select"
                AutoPostBack="true" OnSelectedIndexChanged="FilterChanged">
            </asp:DropDownList>
        </div>

        <div class="col-md-3">
            <asp:DropDownList ID="ddlLevel" runat="server" CssClass="form-select"
                AutoPostBack="true" OnSelectedIndexChanged="FilterChanged">
            </asp:DropDownList>
        </div>

        <div class="col-md-3">
            <asp:DropDownList ID="ddlSemester" runat="server" CssClass="form-select"
                AutoPostBack="true" OnSelectedIndexChanged="FilterChanged">
            </asp:DropDownList>
        </div>

    </div>

</div>
            
       
        <asp:Label ID="lblMsg" runat="server" CssClass="alert alert-info d-block mb-4" Visible="false"></asp:Label>

        <div class="row g-4">
            <asp:Repeater ID="rptSubjects" runat="server" OnItemCommand="rptSubjects_ItemCommand">
                <ItemTemplate>
                    <div class="col-xl-4 col-md-6">
                        <div class="card subject-card h-100 border-0">
                            <div class="card-body p-4">
                                
                                <div class="d-flex justify-content-between align-items-start mb-3">
                                    <div>
                                        <h5 class="fw-bold mb-1"><%# Eval("SubjectName") %></h5>
                                        <span class="badge bg-light text-dark border small">Code: <%# Eval("SubjectCode") %></span>
                                    </div>
                                    <span class='badge rounded-pill px-3 py-2 <%# Convert.ToBoolean(Eval("IsMandatory")) ? "badge-mandatory" : "badge-elective" %>'>
                                        <%# Convert.ToBoolean(Eval("IsMandatory")) ? "MANDATORY" : "ELECTIVE" %>
                                    </span>
                                </div>

                                <div class="mb-4">
                                    <div class="d-flex align-items-center text-primary fw-semibold small mb-1">
                                        <i class="fa fa-layer-group me-2"></i> <%# Eval("StreamName") %>
                                    </div>
                                    <div class="text-muted small">
                                        <i class="fa fa-graduation-cap me-2"></i> <%# Eval("CourseName") %>
                                    </div>
                                </div>

                                <div class="row g-2 mb-4">
                                    <div class="col-6">
                                        <div class="p-2 rounded bg-light border text-center">
                                            <div class="text-muted" style="font-size: 0.7rem;">SEMESTER</div>
                                            <div class="fw-bold small"><%# Eval("SemesterName") %></div>
                                        </div>
                                    </div>
                                    <div class="col-6">
                                        <div class="p-2 rounded bg-light border text-center">
                                            <div class="text-muted" style="font-size: 0.7rem;">STUDENTS</div>
                                            <div class="fw-bold small"><%# Eval("StudentCount") %></div>
                                        </div>
                                    </div>
                                </div>

                                <div class="d-flex gap-2">
                                    <a href='SubjectDetails.aspx?SubjectId=<%# Eval("SubjectId") %>' class="btn btn-primary action-btn flex-grow-1 fw-semibold">
                                        <i class="fa fa-cog me-2"></i> Manage Content
                                    </a>
                                    <asp:LinkButton ID="btnToggle" runat="server" 
                                        CommandName="Toggle" CommandArgument='<%# Eval("SubjectId") %>'
                                        CssClass='<%# "action-btn " + (Convert.ToBoolean(Eval("IsActive")) ? "toggle-off" : "toggle-on") %>'>
                                        <i class='<%# Convert.ToBoolean(Eval("IsActive")) ? "fa fa-eye-slash" : "fa fa-eye" %>'></i>
                                    </asp:LinkButton>
                                </div>
                            </div>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>

        <asp:PlaceHolder ID="phEmpty" runat="server" Visible="false">
            <div class="card stat-card p-5 text-center mt-4">
                <i class="fa fa-search-minus fa-3x text-muted mb-3"></i>
                <h5 class="text-muted">No subjects found in this category</h5>
                <p class="mb-0 text-muted-custom">Use the filter switch to view other subjects.</p>
            </div>
        </asp:PlaceHolder>
    </div>

   
</asp:Content>--%>


<%------------------------------------------------------------------------------------------------------------------------------------------%>


<%@ Page Title="Subject Management" Language="C#" MasterPageFile="~/Admin/AdminMaster.master"
    AutoEventWireup="true" CodeBehind="Subjects.aspx.cs" Inherits="LearningManagementSystem.Admin.Subjects" %>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

<link href="https://fonts.googleapis.com/css2?family=Syne:wght@400;600;700;800&family=DM+Sans:ital,wght@0,300;0,400;0,500;1,300&display=swap" rel="stylesheet">
<style>
:root {
    --ink:       #0d0f1a;
    --ink-soft:  #4a4f6a;
    --surface:   #f5f6fa;
    --card-bg:   #ffffff;
    --border:    #e4e7f0;
    --accent:    #4f46e5;
    --accent-2:  #7c3aed;
    --success:   #059669;
    --danger:    #dc2626;
    --warn:      #d97706;
    --radius:    16px;
    --shadow:    0 4px 24px rgba(13,15,26,.07);
    --shadow-lg: 0 12px 48px rgba(13,15,26,.13);
}

* { box-sizing: border-box; margin: 0; padding: 0; }
body { font-family: 'DM Sans', sans-serif; background: var(--surface); color: var(--ink); }

/* ── PAGE HEADER ── */
.ph { display:flex; justify-content:space-between; align-items:flex-end; flex-wrap:wrap; gap:16px; margin-bottom:28px; }
.ph-left h1 { font-family:'Syne',sans-serif; font-size:2rem; font-weight:800; letter-spacing:-.5px; color:var(--ink); }
.ph-left p  { color:var(--ink-soft); font-size:.875rem; margin-top:2px; }
.ph-right   { display:flex; align-items:center; gap:10px; }

/* Toggle pill */
.toggle-pill { display:flex; align-items:center; gap:8px; background:var(--card-bg); border:1px solid var(--border); border-radius:50px; padding:6px 14px; cursor:pointer; font-size:.825rem; font-weight:500; transition:.2s; }
.toggle-pill:hover { border-color:var(--accent); }
.toggle-pill .form-check-input { cursor:pointer; }

/* ── STAT CARDS ── */
.stats-row { display:grid; grid-template-columns:repeat(6,1fr); gap:14px; margin-bottom:28px; }
@media(max-width:1100px){ .stats-row{grid-template-columns:repeat(3,1fr);} }
@media(max-width:640px) { .stats-row{grid-template-columns:repeat(2,1fr);} }

.sc {
    background:var(--card-bg); border-radius:var(--radius);
    padding:18px 16px; display:flex; align-items:center; gap:14px;
    border:1px solid var(--border); box-shadow:var(--shadow);
    transition:transform .25s, box-shadow .25s;
}
.sc:hover { transform:translateY(-4px); box-shadow:var(--shadow-lg); }
.sc-ico {
    width:46px; height:46px; border-radius:12px; flex-shrink:0;
    display:flex; align-items:center; justify-content:center; font-size:18px;
}
.sc-num { font-family:'Syne',sans-serif; font-size:1.6rem; font-weight:800; line-height:1; }
.sc-lbl { font-size:.72rem; font-weight:600; text-transform:uppercase; letter-spacing:.06em; color:var(--ink-soft); margin-top:2px; }

.sc.c-indigo .sc-ico { background:#eef2ff; color:#4f46e5; }
.sc.c-violet  .sc-ico { background:#f5f3ff; color:#7c3aed; }
.sc.c-emerald .sc-ico { background:#ecfdf5; color:#059669; }
.sc.c-red     .sc-ico { background:#fef2f2; color:#dc2626; }
.sc.c-amber   .sc-ico { background:#fffbeb; color:#d97706; }
.sc.c-sky     .sc-ico { background:#f0f9ff; color:#0284c7; }

/* ── FILTER BAR ── */
.filter-bar {
    background:var(--card-bg); border:1px solid var(--border); border-radius:var(--radius);
    padding:18px 20px; margin-bottom:24px; box-shadow:var(--shadow);
    display:flex; align-items:center; gap:12px; flex-wrap:wrap;
}
.filter-bar label { font-size:.8rem; font-weight:600; color:var(--ink-soft); white-space:nowrap; }
.filter-bar .form-select {
    border:1px solid var(--border); border-radius:10px; font-size:.85rem;
    color:var(--ink); padding:8px 14px; background:var(--surface);
    min-width:155px; flex:1; cursor:pointer; transition:.2s;
}
.filter-bar .form-select:focus { border-color:var(--accent); box-shadow:0 0 0 3px rgba(79,70,229,.12); outline:none; }

/* Search box */
.search-wrap { position:relative; flex:2; min-width:200px; }
.search-wrap input {
    width:100%; border:1px solid var(--border); border-radius:10px;
    padding:8px 14px 8px 38px; font-size:.85rem; background:var(--surface);
    transition:.2s; color:var(--ink);
}
.search-wrap input:focus { border-color:var(--accent); outline:none; box-shadow:0 0 0 3px rgba(79,70,229,.12); }
.search-wrap i { position:absolute; left:12px; top:50%; transform:translateY(-50%); color:var(--ink-soft); font-size:.85rem; }

/* ── SUBJECT CARDS GRID ── */
.subjects-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(320px,1fr)); gap:20px; }

.sub-card {
    background:var(--card-bg); border-radius:var(--radius);
    border:1px solid var(--border); box-shadow:var(--shadow);
    overflow:hidden; display:flex; flex-direction:column;
    transition:transform .25s, box-shadow .25s;
    animation: fadeUp .4s ease both;
}
.sub-card:hover { transform:translateY(-5px); box-shadow:var(--shadow-lg); }
@keyframes fadeUp { from{opacity:0;transform:translateY(16px)} to{opacity:1;transform:translateY(0)} }

/* Accent top strip */
.sub-card-accent { height:4px; background:linear-gradient(90deg,var(--accent),var(--accent-2)); }

.sub-card-body { padding:20px; flex:1; display:flex; flex-direction:column; gap:14px; }

.sub-card-top { display:flex; justify-content:space-between; align-items:flex-start; }
.sub-name { font-family:'Syne',sans-serif; font-weight:700; font-size:1.05rem; color:var(--ink); line-height:1.3; }
.sub-code { font-size:.75rem; color:var(--ink-soft); margin-top:3px; }

.badge-mandatory { background:#dcfce7; color:#15803d; border:1px solid #bbf7d0; border-radius:20px; padding:3px 10px; font-size:.72rem; font-weight:700; letter-spacing:.03em; white-space:nowrap; }
.badge-elective   { background:#fef9c3; color:#92400e; border:1px solid #fde68a; border-radius:20px; padding:3px 10px; font-size:.72rem; font-weight:700; letter-spacing:.03em; white-space:nowrap; }
.badge-inactive   { background:#fee2e2; color:#991b1b; border:1px solid #fecaca; border-radius:20px; padding:3px 10px; font-size:.72rem; font-weight:700; white-space:nowrap; }

.sub-meta { display:flex; flex-direction:column; gap:5px; }
.sub-meta-row { display:flex; align-items:center; gap:6px; font-size:.8rem; color:var(--ink-soft); }
.sub-meta-row i { width:14px; color:var(--accent); }

.sub-stats { display:grid; grid-template-columns:1fr 1fr 1fr; gap:8px; }
.sub-stat-box { background:var(--surface); border-radius:10px; padding:8px 6px; text-align:center; border:1px solid var(--border); }
.sub-stat-val { font-family:'Syne',sans-serif; font-weight:700; font-size:1.1rem; color:var(--ink); }
.sub-stat-lbl { font-size:.65rem; font-weight:600; text-transform:uppercase; color:var(--ink-soft); letter-spacing:.05em; }

.sub-card-footer { display:flex; gap:8px; padding:14px 20px; border-top:1px solid var(--border); background:#fafbff; }
.btn-manage {
    flex:1; background:linear-gradient(135deg,var(--accent),var(--accent-2));
    color:#fff; border:none; border-radius:10px; padding:9px 12px;
    font-size:.82rem; font-weight:600; cursor:pointer; transition:.2s;
    display:flex; align-items:center; justify-content:center; gap:6px; text-decoration:none;
}
.btn-manage:hover { opacity:.9; color:#fff; }
.btn-icon {
    width:36px; height:36px; border-radius:10px; border:none; cursor:pointer;
    display:flex; align-items:center; justify-content:center; font-size:.85rem; transition:.2s;
}
.btn-icon.deact { background:#fee2e2; color:#991b1b; }
.btn-icon.act   { background:#dcfce7; color:#15803d; }
.btn-icon:hover { filter:brightness(.92); }

/* ── EMPTY STATE ── */
.empty-state {
    text-align:center; padding:80px 20px; color:var(--ink-soft);
    background:var(--card-bg); border-radius:var(--radius);
    border:2px dashed var(--border);
}
.empty-state i { font-size:3.5rem; margin-bottom:16px; opacity:.3; display:block; }
.empty-state h4 { font-family:'Syne',sans-serif; font-weight:700; color:var(--ink); margin-bottom:8px; }

/* ── ALERT ── */
.alert-auto { border-radius:12px; font-size:.875rem; padding:12px 16px; }

/* ── Notification toast ── */
#toast-wrap { position:fixed; bottom:24px; right:24px; z-index:9999; display:flex; flex-direction:column; gap:10px; }
.toast-msg {
    background:var(--ink); color:#fff; border-radius:12px; padding:12px 20px;
    font-size:.85rem; font-weight:500; box-shadow:var(--shadow-lg);
    animation:slideIn .3s ease; max-width:320px;
}
@keyframes slideIn { from{opacity:0;transform:translateX(40px)} to{opacity:1;transform:translateX(0)} }

/* Stagger animation delay for cards */
.sub-card:nth-child(1){animation-delay:.05s}
.sub-card:nth-child(2){animation-delay:.1s}
.sub-card:nth-child(3){animation-delay:.15s}
.sub-card:nth-child(4){animation-delay:.2s}
.sub-card:nth-child(5){animation-delay:.25s}
.sub-card:nth-child(6){animation-delay:.3s}
</style>

<!-- PAGE HEADER -->
<div class="ph">
    <div class="ph-left">
        <h1><i class="fa fa-book-open me-2" style="color:var(--accent)"></i>Subject Management</h1>
        <p>Manage subjects across streams, courses & semesters &nbsp;·&nbsp;
           <span id="tsLabel" style="font-weight:600;color:var(--accent)">Loading…</span>
        </p>
    </div>
    <div class="ph-right">
        <div class="toggle-pill">
            <asp:CheckBox ID="chkStatus" runat="server" AutoPostBack="true"
                OnCheckedChanged="chkStatus_CheckedChanged"
                CssClass="form-check-input mt-0" />
            <label for="<%= chkStatus.ClientID %>" style="cursor:pointer">
                <asp:Literal ID="litToggleLabel" runat="server" Text="Show Active" />
            </label>
        </div>
    </div>
</div>

<!-- ALERT -->
<asp:Label ID="lblMsg" runat="server" CssClass="alert alert-info alert-auto d-block mb-3" Visible="false"></asp:Label>

<!-- STATS ROW -->
<div class="stats-row">
    <asp:Repeater ID="rptStats" runat="server">
        <ItemTemplate>
            <div class="sc c-indigo">
                <div class="sc-ico"><i class="fa fa-book"></i></div>
                <div><div class="sc-num"><%# Eval("TotalSubjects") %></div><div class="sc-lbl">Total</div></div>
            </div>
            <div class="sc c-emerald">
                <div class="sc-ico"><i class="fa fa-check-circle"></i></div>
                <div><div class="sc-num"><%# Eval("ActiveCount") %></div><div class="sc-lbl">Active</div></div>
            </div>
            <div class="sc c-red">
                <div class="sc-ico"><i class="fa fa-times-circle"></i></div>
                <div><div class="sc-num"><%# Eval("InactiveCount") %></div><div class="sc-lbl">Inactive</div></div>
            </div>
            <div class="sc c-amber">
                <div class="sc-ico"><i class="fa fa-star"></i></div>
                <div><div class="sc-num"><%# Eval("MandatoryCount") %></div><div class="sc-lbl">Mandatory</div></div>
            </div>
            <div class="sc c-violet">
                <div class="sc-ico"><i class="fa fa-users"></i></div>
                <div><div class="sc-num"><%# Eval("TotalEnrollments") %></div><div class="sc-lbl">Enrollments</div></div>
            </div>
            <div class="sc c-sky">
                <div class="sc-ico"><i class="fa fa-chart-bar"></i></div>
                <div><div class="sc-num"><%# Eval("AvgPerSubject") %></div><div class="sc-lbl">Avg/Subject</div></div>
            </div>
        </ItemTemplate>
    </asp:Repeater>
</div>

<!-- FILTER BAR -->
<div class="filter-bar">
    <i class="fa fa-filter" style="color:var(--ink-soft)"></i>
    <label>Stream</label>
    <asp:DropDownList ID="ddlStream" runat="server" CssClass="form-select"
        AutoPostBack="true" OnSelectedIndexChanged="FilterChanged"></asp:DropDownList>

    <label>Course</label>
    <asp:DropDownList ID="ddlCourse" runat="server" CssClass="form-select"
        AutoPostBack="true" OnSelectedIndexChanged="FilterChanged"></asp:DropDownList>

    <label>Level</label>
    <asp:DropDownList ID="ddlLevel" runat="server" CssClass="form-select"
        AutoPostBack="true" OnSelectedIndexChanged="FilterChanged"></asp:DropDownList>

    <label>Semester</label>
    <asp:DropDownList ID="ddlSemester" runat="server" CssClass="form-select"
        AutoPostBack="true" OnSelectedIndexChanged="FilterChanged"></asp:DropDownList>

    <div class="search-wrap">
        <i class="fa fa-search"></i>
        <input type="text" id="txtSearch" placeholder="Search subjects…" oninput="filterCards(this.value)" />
    </div>
</div>

<!-- SUBJECT CARDS -->
<div class="subjects-grid" id="subjectsGrid">
    <asp:Repeater ID="rptSubjects" runat="server" OnItemCommand="rptSubjects_ItemCommand">
        <ItemTemplate>
            <div class="sub-card" data-name='<%# Eval("SubjectName").ToString().ToLower() %>' data-code='<%# Eval("SubjectCode").ToString().ToLower() %>'>
                <div class="sub-card-accent"></div>
                <div class="sub-card-body">
                    <div class="sub-card-top">
                        <div>
                            <div class="sub-name"><%# Eval("SubjectName") %></div>
                            <div class="sub-code"><i class="fa fa-hashtag me-1"></i><%# Eval("SubjectCode") %></div>
                        </div>
                        <span class='<%# Convert.ToBoolean(Eval("IsActive")) ? (Convert.ToBoolean(Eval("IsMandatory")) ? "badge-mandatory" : "badge-elective") : "badge-inactive" %>'>
                            <%# !Convert.ToBoolean(Eval("IsActive")) ? "INACTIVE" : (Convert.ToBoolean(Eval("IsMandatory")) ? "MANDATORY" : "ELECTIVE") %>
                        </span>
                    </div>

                    <div class="sub-meta">
                        <div class="sub-meta-row"><i class="fa fa-layer-group"></i><span><%# Eval("StreamName") %></span></div>
                        <div class="sub-meta-row"><i class="fa fa-graduation-cap"></i><span><%# Eval("CourseName") %></span></div>
                        <div class="sub-meta-row"><i class="fa fa-calendar-alt"></i><span><%# Eval("SemesterName") %> &nbsp;·&nbsp; <%# Eval("LevelName") %></span></div>
                    </div>

                    <div class="sub-stats">
                        <div class="sub-stat-box">
                            <div class="sub-stat-val"><%# Eval("StudentCount") %></div>
                            <div class="sub-stat-lbl">Students</div>
                        </div>
                        <div class="sub-stat-box">
                            <div class="sub-stat-val"><%# Eval("VideoCount") %></div>
                            <div class="sub-stat-lbl">Videos</div>
                        </div>
                        <div class="sub-stat-box">
                            <div class="sub-stat-val"><%# Eval("ChapterCount") %></div>
                            <div class="sub-stat-lbl">Chapters</div>
                        </div>
                    </div>
                </div>

                <div class="sub-card-footer">
                    <a href='SubjectDetails.aspx?SubjectId=<%# Eval("SubjectId") %>' class="btn-manage">
                        <i class="fa fa-cog"></i> Manage Content
                    </a>
                    <asp:LinkButton ID="btnToggle" runat="server"
                        CommandName="Toggle" CommandArgument='<%# Eval("SubjectId") %>'
                        CssClass='<%# "btn-icon " + (Convert.ToBoolean(Eval("IsActive")) ? "deact" : "act") %>'
                        ToolTip='<%# Convert.ToBoolean(Eval("IsActive")) ? "Deactivate" : "Activate" %>'>
                        <i class='<%# Convert.ToBoolean(Eval("IsActive")) ? "fa fa-eye-slash" : "fa fa-eye" %>'></i>
                    </asp:LinkButton>
                </div>
            </div>
        </ItemTemplate>
    </asp:Repeater>
</div>

<!-- EMPTY STATE -->
<asp:PlaceHolder ID="phEmpty" runat="server" Visible="false">
    <div class="empty-state">
        <i class="fa fa-book-open"></i>
        <h4>No subjects found</h4>
        <p>Try adjusting the filters or switch the active/inactive toggle.</p>
    </div>
</asp:PlaceHolder>

<!-- TOAST CONTAINER -->
<div id="toast-wrap"></div>

<!-- Hidden field for last toggle action result -->
<asp:HiddenField ID="hfToastMsg" runat="server" Value="" />

<script>
    // Timestamp label
    document.getElementById('tsLabel').textContent =
        'Last updated: ' + new Date().toLocaleString('en-IN', {day:'2-digit',month:'short',year:'numeric',hour:'2-digit',minute:'2-digit'});

    // Client-side search filter
    function filterCards(q) {
        q = q.toLowerCase().trim();
        document.querySelectorAll('.sub-card').forEach(c => {
            const match = c.dataset.name.includes(q) || c.dataset.code.includes(q);
            c.style.display = match ? '' : 'none';
        });
    }

    // Toast
    function showToast(msg, color) {
        const wrap = document.getElementById('toast-wrap');
        const t = document.createElement('div');
        t.className = 'toast-msg';
        t.style.background = color || '#0d0f1a';
        t.textContent = msg;
        wrap.appendChild(t);
        setTimeout(() => t.remove(), 4000);
    }

    // Fire toast from server message if any
    window.addEventListener('DOMContentLoaded', () => {
        const hf = document.getElementById('<%= hfToastMsg.ClientID %>');
        if (hf && hf.value) { showToast(hf.value, '#059669'); hf.value = ''; }
    });
</script>
</asp:Content>
