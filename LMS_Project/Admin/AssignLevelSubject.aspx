<%@ Page Title="Assign Level Subjects" Language="C#"
    MasterPageFile="~/Admin/AdminMaster.master"
    AutoEventWireup="true"
    CodeBehind="AssignLevelSubject.aspx.cs"
    Inherits="LearningManagementSystem.Admin.AssignLevelSubject" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server" />

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

<!-- ══ HIDDEN STATE ═════════════════════════════════════════ -->
<asp:HiddenField ID="hfLastStreamId"      runat="server" Value="0" />
<asp:HiddenField ID="hfLastCourseId"      runat="server" Value="0" />
<asp:HiddenField ID="hfLastLevelId"       runat="server" Value="0" />
<asp:HiddenField ID="hfLastSemesterId"    runat="server" Value="0" />
<!-- ★ FIX: captures checked SubjectIds + Mandatory flags BEFORE postback -->
<asp:HiddenField ID="hfSelectedSubjectIds" runat="server" Value="" />

<!-- ══ TOAST ════════════════════════════════════════════════ -->
<div class="toast-container position-fixed p-3"
     style="top:70px;right:16px;z-index:9999;">
    <div id="liveToast" class="toast align-items-center border-0 shadow-lg"
         role="alert" aria-atomic="true">
        <div class="d-flex">
            <div class="toast-body fw-semibold" id="toastMsg"
                 style="font-size:13px;"></div>
            <button type="button" class="btn-close me-2 m-auto"
                    data-bs-dismiss="toast"></button>
        </div>
    </div>
</div>

<!-- ══ PAGE HEADER ══════════════════════════════════════════ -->
<div class="als-page-header mb-4">
    <div class="d-flex flex-wrap justify-content-between align-items-start gap-3">

        <!-- Left -->
        <div>
            <h4 class="fw-bold mb-1 d-flex align-items-center gap-2">
                <span class="als-header-icon">
                    <i class="fa fa-layer-group"></i>
                </span>
                Assign Subjects to Class
            </h4>
            <div class="text-muted small d-flex align-items-center flex-wrap gap-2">
                <span>Map subjects across streams, courses, levels &amp; semesters</span>
                <span class="dot-sep"></span>
                <asp:Label ID="lblSessionName" runat="server"
                    CssClass="badge bg-primary bg-opacity-10 text-primary px-2 py-1" />
                <asp:Label ID="lblSuperAdminBadge" runat="server" Visible="false"
                    CssClass="badge bg-warning text-dark">
                    <i class="fa fa-eye me-1"></i>View Only
                </asp:Label>
            </div>
        </div>

        <!-- Right: quick stats -->
        <div class="d-flex gap-2 flex-wrap">
            <div class="als-mini-stat border rounded-3 px-3 py-2 text-center">
                <div class="text-muted" style="font-size:10px;text-transform:uppercase;letter-spacing:.4px">Total Assigned</div>
                <div class="fw-bold fs-5 text-primary">
                    <asp:Label ID="lblTotalAssigned" runat="server" Text="0" />
                </div>
            </div>
            <div class="als-mini-stat border rounded-3 px-3 py-2 text-center">
                <div class="text-muted" style="font-size:10px;text-transform:uppercase;letter-spacing:.4px">Active Subjects</div>
                <div class="fw-bold fs-5 text-success">
                    <asp:Label ID="lblActiveSubjects" runat="server" Text="0" />
                </div>
            </div>
        </div>

    </div>
</div>

<!-- ══ MAIN CONTENT: two-column layout ══════════════════════ -->
<div class="row g-4">

    <!-- ── LEFT: Assignment Form ──────────────────────────── -->
    <div class="col-12 col-lg-5">
        <div class="card shadow-sm border-0 rounded-4 h-100">
            <div class="card-header als-card-header text-white py-3">
                <h6 class="mb-0 fw-bold">
                    <i class="fa fa-sitemap me-2"></i>Select Class Structure
                </h6>
                <small class="opacity-75">Choose stream → course → level → semester</small>
            </div>

            <div class="card-body p-4">

                <!-- Academic path breadcrumb -->
                <div class="als-path-bar mb-4" id="pathBar" style="display:none">
                    <span class="path-chip chip-stream" id="pc_stream">—</span>
                    <i class="fa fa-chevron-right path-arr"></i>
                    <span class="path-chip chip-course" id="pc_course">—</span>
                    <i class="fa fa-chevron-right path-arr"></i>
                    <span class="path-chip chip-level" id="pc_level">—</span>
                    <i class="fa fa-chevron-right path-arr"></i>
                    <span class="path-chip chip-sem" id="pc_sem">—</span>
                </div>

                <div class="row g-3">

                    <!-- Stream -->
                    <div class="col-12">
                        <label class="form-label fw-semibold small">
                            Stream / Department <span class="req">*</span>
                        </label>
                        <asp:DropDownList ID="ddlStream" runat="server"
                            CssClass="form-select als-select"
                            AutoPostBack="true"
                            OnSelectedIndexChanged="ddlStream_Changed">
                            <asp:ListItem Value="0" Text="-- Select Stream --" />
                        </asp:DropDownList>
                        <div class="form-err" id="errStream"></div>
                    </div>

                    <!-- Course -->
                    <div class="col-12">
                        <label class="form-label fw-semibold small">Course / Branch</label>
                        <asp:DropDownList ID="ddlCourse" runat="server"
                            CssClass="form-select als-select"
                            AutoPostBack="true"
                            OnSelectedIndexChanged="ddlCourse_Changed">
                            <asp:ListItem Value="0" Text="-- Select Course --" />
                        </asp:DropDownList>
                    </div>

                    <!-- Level -->
                    <div class="col-12 col-sm-6">
                        <label class="form-label fw-semibold small">
                            Level / Year <span class="req">*</span>
                        </label>
                        <asp:DropDownList ID="ddlLevel" runat="server"
                            CssClass="form-select als-select"
                            AutoPostBack="true"
                            OnSelectedIndexChanged="ddlLevel_Changed">
                            <asp:ListItem Value="0" Text="-- Select Level --" />
                        </asp:DropDownList>
                        <div class="form-err" id="errLevel"></div>
                    </div>

                    <!-- Semester -->
                    <div class="col-12 col-sm-6">
                        <label class="form-label fw-semibold small">
                            Semester <span class="req">*</span>
                        </label>
                        <asp:DropDownList ID="ddlSemester" runat="server"
                            CssClass="form-select als-select"
                            AutoPostBack="true"
                            OnSelectedIndexChanged="ddlSemester_Changed">
                            <asp:ListItem Value="0" Text="-- Select Semester --" />
                        </asp:DropDownList>
                        <div class="form-err" id="errSemester"></div>
                    </div>

                    <!-- Section (optional) -->
                    <div class="col-12">
                        <label class="form-label fw-semibold small">Section (optional)</label>
                        <asp:DropDownList ID="ddlSection" runat="server"
                            CssClass="form-select als-select">
                            <asp:ListItem Value="0" Text="-- All Sections --" />
                        </asp:DropDownList>
                    </div>

                </div>

                <!-- Already assigned info box -->
                <asp:Panel ID="pnlAlreadyAssigned" runat="server"
                    CssClass="already-assigned-box mt-3" Visible="false">
                    <div class="d-flex align-items-center gap-2 mb-2">
                        <i class="fa fa-info-circle text-primary"></i>
                        <span class="fw-semibold small">Already Assigned Subjects</span>
                        <span class="badge bg-primary rounded-pill ms-auto"
                              id="assignedCount">0</span>
                    </div>
                    <div id="assignedTagsBox" class="d-flex flex-wrap gap-1">
                        <asp:Literal ID="litAssignedTags" runat="server" />
                    </div>
                </asp:Panel>

            </div>

            <!-- Subject list + select all -->
            <div class="card-body border-top pt-3 pb-2 px-4">
                <div class="d-flex align-items-center justify-content-between mb-3">
                    <span class="fw-semibold small text-muted">
                        <i class="fa fa-book me-1"></i>Available Subjects
                        <span class="badge bg-secondary rounded-pill ms-1"
                              id="subjectCount">0</span>
                    </span>
                    <div class="d-flex align-items-center gap-2">
                        <div class="als-sub-search-wrap">
                            <i class="fa fa-search als-sub-search-icon"></i>
                            <input type="text" id="subSearchBox"
                                   class="form-control als-sub-search"
                                   placeholder="Filter subjects..."
                                   oninput="filterSubjects(this.value)" />
                        </div>
                        <div class="form-check form-switch mb-0">
                            <input class="form-check-input" type="checkbox"
                                   id="chkSelAll" onchange="toggleAll(this)" />
                            <label class="form-check-label small"
                                   for="chkSelAll">All</label>
                        </div>
                    </div>
                </div>

                <!-- Subjects GridView -->
                <div class="als-subjects-list-wrap">
                    <asp:GridView ID="gvSubjects" runat="server"
                        CssClass="table table-sm als-subject-table mb-0"
                        AutoGenerateColumns="false"
                        GridLines="None"
                        DataKeyNames="SubjectId"
                        ShowHeader="false">

                        <EmptyDataTemplate>
                            <div class="text-center py-4">
                                <i class="fa fa-book fa-2x text-muted mb-2 d-block"></i>
                                <p class="text-muted small mb-0">
                                    No active subjects found in this session.
                                </p>
                            </div>
                        </EmptyDataTemplate>

                        <Columns>

                            <asp:TemplateField ItemStyle-Width="40px"
                                              ItemStyle-CssClass="chk-cell">
                                <ItemTemplate>
                                    <asp:CheckBox ID="chkSelect" runat="server"
                                    CssClass="form-check-input"
                                    InputAttributes="class=form-check-input sub-chk"
                                    onchange="updateSelCount(); updateHiddenSelection();" />
                                </ItemTemplate>
                            </asp:TemplateField>

                            
                            <asp:TemplateField>
                                <ItemTemplate>
                                    <div class="als-sub-row"
                                         data-search='<%# (Eval("SubjectName") + " " + Eval("SubjectCode")).ToString().ToLower() %>'>
                                        <div class="fw-semibold small">
                                            <%# Eval("SubjectName") %>
                                        </div>
                                        <div class="text-muted" style="font-size:11px">
                                            <span class="badge-code">
                                                <%# Eval("SubjectCode") %>
                                            </span>
                                            &nbsp;·&nbsp;
                                            <i class="fa fa-clock me-1"></i>
                                            <%# Eval("Duration") %>
                                        </div>
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateField>

                          
                            <asp:TemplateField HeaderText="Mandatory"
                                              ItemStyle-Width="90px"
                                              ItemStyle-CssClass="text-center">
                                <ItemTemplate>
                                    <div class="form-check form-switch d-flex justify-content-center mb-0">
                                        <asp:CheckBox ID="chkMandatory" runat="server"
                                            Checked="true"
                                            CssClass="form-check-input" />
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField ItemStyle-Width="30px"
                                              ItemStyle-CssClass="text-center">
                                <ItemTemplate>
                                    <%# Convert.ToBoolean(Eval("IsAlreadyAssigned"))
                                        ? "<span class='already-badge' title='Already assigned to this class'>✓</span>"
                                        : "" %>
                                </ItemTemplate>
                            </asp:TemplateField>

                        </Columns>
                    </asp:GridView>
                </div>

              
                <div class="mt-2 text-muted small" id="selCountBox" style="display:none">
                    <i class="fa fa-check-circle text-success me-1"></i>
                    <span id="selCount">0</span> subject(s) selected
                </div>
            </div>

            <div class="card-footer bg-transparent border-top px-4 py-3">
                <asp:Panel ID="pnlSaveBtn" runat="server">
                    <asp:Button ID="btnSave" runat="server"
                        Text="Assign Selected Subjects"
                        CssClass="btn btn-primary rounded-pill px-4 fw-semibold w-100"
                        OnClick="btnSave_Click"
                        OnClientClick="return validateAndConfirm();" />
                </asp:Panel>
                <asp:Panel ID="pnlSuperAdminNote" runat="server" Visible="false">
                    <div class="alert alert-warning border-0 rounded-3 py-2 mb-0"
                         style="font-size:12px">
                        <i class="fa fa-eye me-1"></i>
                        SuperAdmin has view-only access. Cannot assign subjects.
                    </div>
                </asp:Panel>
            </div>
        </div>
    </div>

    <!-- ── RIGHT: Assignment Tracker ──────────────────────── -->
    <div class="col-12 col-lg-7">

        <!-- Filter bar for tracker -->
        <div class="d-flex align-items-center gap-2 flex-wrap mb-3">
            <span class="fw-semibold small text-muted me-auto">
                <i class="fa fa-map-marker-alt me-1"></i>
                Subject Assignment Tracker
            </span>
            <div class="als-tracker-search-wrap">
                <i class="fa fa-search als-tracker-icon"></i>
                <input type="text" id="trackerSearch"
                       class="form-control als-tracker-search"
                       placeholder="Search tracker..."
                       onkeyup="filterTracker(this.value)" />
            </div>
            <asp:DropDownList ID="ddlTrackerStream" runat="server"
                CssClass="form-select als-tracker-filter"
                AutoPostBack="true"
                OnSelectedIndexChanged="ddlTrackerStream_Changed">
                <asp:ListItem Value="0" Text="All Streams" />
            </asp:DropDownList>
        </div>

        <!-- Tracker GridView -->
        <div class="card shadow-sm border-0 rounded-4 overflow-hidden">
            <div class="table-responsive">
                <asp:GridView ID="gvTracker" runat="server"
                    CssClass="table table-hover align-middle modern-table mb-0"
                    AutoGenerateColumns="false"
                    OnRowCommand="gvTracker_RowCommand"
                    GridLines="None">
                    <HeaderStyle CssClass="als-table-header" />
                    <EmptyDataTemplate>
                        <div class="text-center py-5">
                            <i class="fa fa-layer-group fa-3x text-muted mb-3 d-block"></i>
                            <p class="fw-semibold text-muted mb-1">No assignments yet</p>
                            <p class="text-muted small">
                                Use the form on the left to assign subjects to classes.
                            </p>
                        </div>
                    </EmptyDataTemplate>
                    <Columns>

                        <asp:TemplateField HeaderText="#" ItemStyle-Width="36px">
                            <ItemTemplate>
                                <span class="text-muted small">
                                    <%# Container.DataItemIndex + 1 %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Subject">
                            <ItemTemplate>
                                <div class="fw-semibold small"><%# Eval("SubjectName") %></div>
                                <span class="badge-code"><%# Eval("SubjectCode") %></span>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Academic Path">
                            <ItemTemplate>
                                <div class="d-flex flex-wrap gap-1">
                                    <span class="acad-tag tag-stream"><%# Eval("StreamName") %></span>
                                    <span class="acad-tag tag-course"><%# Eval("CourseName") %></span>
                                    <span class="acad-tag tag-level"><%# Eval("LevelName") %></span>
                                    <span class="acad-tag tag-sem"><%# Eval("SemesterName") %></span>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Type" ItemStyle-Width="80px">
                            <ItemTemplate>
                                <%# Convert.ToBoolean(Eval("IsMandatory"))
                                    ? "<span class='badge bg-danger bg-opacity-15 text-danger rounded-pill px-2' style='font-size:10px'>Mandatory</span>"
                                    : "<span class='badge bg-info bg-opacity-15 text-info rounded-pill px-2' style='font-size:10px'>Elective</span>" %>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Assigned On" ItemStyle-Width="100px">
                            <ItemTemplate>
                                <span class="text-muted small">
                                    <%# Eval("CreatedOn") != DBNull.Value
                                        ? Convert.ToDateTime(Eval("CreatedOn")).ToString("dd MMM yy")
                                        : "—" %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Action"
                                          ItemStyle-Width="50px"
                                          ItemStyle-CssClass="text-center">
                            <ItemTemplate>
                                <asp:Panel ID="pnlTrackerDel" runat="server">
                                    <asp:LinkButton runat="server"
                                        CommandName="RemoveAssign"
                                        CommandArgument='<%# Eval("Id") %>'
                                        CssClass="als-del-btn"
                                        title="Remove assignment"
                                        OnClientClick="return confirm('Remove this subject assignment?');">
                                        <i class="fa fa-times"></i>
                                    </asp:LinkButton>
                                </asp:Panel>
                            </ItemTemplate>
                        </asp:TemplateField>

                    </Columns>
                </asp:GridView>
            </div>
        </div>

        <!-- Tracker Pagination -->
        <div class="d-flex justify-content-center mt-3">
            <asp:Panel ID="pnlTrackerPager" runat="server"
                CssClass="d-flex align-items-center gap-2 flex-wrap justify-content-center" />
        </div>

    </div>
</div>

<!-- ══ STYLES ════════════════════════════════════════════════ -->
<style>
:root {
    --primary:#4f46e5;--primary-lt:#eef2ff;
    --success:#16a34a;--radius-lg:16px;
}

/* Header */
.als-header-icon {
    width:36px;height:36px;border-radius:10px;
    background:var(--primary-lt);color:var(--primary);
    display:inline-flex;align-items:center;justify-content:center;
}
.dot-sep { width:5px;height:5px;background:#cbd5e1;border-radius:50%;display:inline-block; }
.req { color:#dc2626; }
.form-err { color:#dc2626;font-size:11px;margin-top:3px;min-height:14px; }

/* Mini stats */
.als-mini-stat {
    background:#fff;min-width:100px;
    transition:transform .2s,box-shadow .2s;
}
.als-mini-stat:hover {
    transform:translateY(-2px);
    box-shadow:0 4px 12px rgba(0,0,0,.08)!important;
}

/* Card header */
.als-card-header {
    background:linear-gradient(135deg,#4f46e5,#6366f1);
    border-radius:16px 16px 0 0!important;
}

/* Path bar */
.als-path-bar {
    display:flex;align-items:center;gap:6px;flex-wrap:wrap;
    padding:8px 12px;background:#f8fafc;
    border-radius:10px;border:1px solid #e2e8f0;
}
.path-chip {
    font-size:11px;font-weight:600;padding:2px 8px;border-radius:6px;
}
.chip-stream { background:#eef2ff;color:#4f46e5; }
.chip-course { background:#e0f2fe;color:#0369a1; }
.chip-level  { background:#f0fdf4;color:#15803d; }
.chip-sem    { background:#fef9c3;color:#92400e; }
.path-arr    { color:#94a3b8;font-size:10px;flex-shrink:0; }

/* Selects */
.als-select {
    font-size:13px;border-radius:8px;
    transition:border-color .15s,box-shadow .15s;
}
.als-select:focus {
    border-color:#4f46e5;
    box-shadow:0 0 0 3px rgba(79,70,229,.15);
}

/* Already assigned box */
.already-assigned-box {
    background:#eef2ff;border-radius:10px;
    border:1px solid #c7d2fe;padding:10px 14px;
}

/* Subject search */
.als-sub-search-wrap { position:relative; }
.als-sub-search-icon {
    position:absolute;top:50%;left:8px;
    transform:translateY(-50%);color:#94a3b8;font-size:11px;
}
.als-sub-search {
    padding-left:26px;height:28px;font-size:12px;
    border-radius:7px;width:150px;
}

/* Subject list */
.als-subjects-list-wrap {
    max-height:360px;overflow-y:auto;
    border:1px solid #e2e8f0;border-radius:10px;
}
.als-subject-table td {
    padding:8px 12px;font-size:13px;
    border-bottom:1px solid #f1f5f9!important;vertical-align:middle;
}
.als-sub-row { padding:2px 0; }
.badge-code {
    background:#f1f5f9;color:#475569;font-size:10px;
    font-weight:600;padding:1px 7px;border-radius:5px;
    font-family:monospace;
}
.already-badge {
    display:inline-flex;width:18px;height:18px;border-radius:50%;
    background:#dcfce7;color:#15803d;font-size:10px;font-weight:700;
    align-items:center;justify-content:center;
}
.chk-cell { padding-left:12px!important; }

/* Academic tags */
.acad-tag {
    display:inline-block;padding:2px 7px;border-radius:5px;
    font-size:10px;font-weight:600;white-space:nowrap;
}
.tag-stream { background:#eef2ff;color:#4f46e5; }
.tag-course { background:#e0f2fe;color:#0369a1; }
.tag-level  { background:#f0fdf4;color:#15803d; }
.tag-sem    { background:#fef9c3;color:#92400e; }

/* Tracker */
.als-table-header th {
    background:linear-gradient(135deg,#4f46e5,#6366f1)!important;
    color:#fff!important;border:none!important;
    padding:12px 14px!important;font-weight:600;font-size:12px;white-space:nowrap;
}
.modern-table td {
    padding:10px 14px;font-size:13px;
    border-bottom:1px solid #f1f5f9!important;vertical-align:middle;
}
.als-tracker-search-wrap { position:relative; }
.als-tracker-icon {
    position:absolute;top:50%;left:8px;
    transform:translateY(-50%);color:#94a3b8;font-size:11px;
}
.als-tracker-search {
    padding-left:26px;height:30px;font-size:12px;
    border-radius:7px;width:160px;
}
.als-tracker-filter {
    height:30px;font-size:12px;border-radius:7px;
    padding:0 6px;min-width:120px;
}
.als-del-btn {
    width:24px;height:24px;border-radius:6px;border:none;
    background:#fee2e2;color:#b91c1c;
    display:inline-flex;align-items:center;justify-content:center;
    font-size:10px;cursor:pointer;transition:transform .15s;
    text-decoration:none;
}
.als-del-btn:hover { transform:scale(1.12); }

/* Pager */
.als-page-btn {
    padding:4px 10px;border-radius:7px;border:1px solid #e2e8f0;
    background:#fff;font-size:12px;cursor:pointer;color:#475569;
    transition:.15s;
}
.als-page-btn:hover,.als-page-btn.active {
    background:#4f46e5;color:#fff;border-color:#4f46e5;
}

/* Toast */
.toast { min-width:280px;border-radius:12px!important; }
.toast.bg-success { background:#16a34a!important;color:#fff!important; }
.toast.bg-danger  { background:#dc2626!important;color:#fff!important; }
.toast.bg-warning { background:#d97706!important;color:#fff!important; }
.toast.bg-info    { background:#0891b2!important;color:#fff!important; }

/* Form */
.form-label { font-size:13px;margin-bottom:4px; }

/* Responsive */
@media (max-width:767px) {
    .als-sub-search { width:120px; }
    .als-tracker-search { width:120px; }
    .modal-dialog { margin:8px; }
}
</style>

<!-- ══ SCRIPTS ════════════════════════════════════════════════ -->
<script>
    /* ── Role guard ─────────────────────────────────────────── */
    var isSuperAdmin = '<%= Session["Role"]?.ToString() %>' === 'SuperAdmin';

    /* ── Toast ──────────────────────────────────────────────── */
    function showToast(msg, type) {
        var icons = {
            success: 'check-circle', danger: 'times-circle',
            warning: 'exclamation-triangle', info: 'info-circle'
        };
        var t = document.getElementById('liveToast');
        var m = document.getElementById('toastMsg');
        m.innerHTML = '<i class="fa fa-' + (icons[type] || 'info-circle') + ' me-2"></i>' + msg;
        t.className = 'toast align-items-center border-0 shadow-lg text-white bg-' + (type || 'success');
        bootstrap.Toast.getOrCreateInstance(t, { delay: 4500 }).show();
    }
    function serverToast(msg, type) { showToast(msg, type); }

    /* ── Select All ─────────────────────────────────────────── */
    function toggleAll(chk) {
        document.querySelectorAll('.sub-chk').forEach(function (c) {
            // Only toggle visible (not filtered-out) rows
            var row = c.closest('tr');
            if (row && row.style.display !== 'none') c.checked = chk.checked;
        });
        updateSelCount();
    }

    /* ── Selection count ────────────────────────────────────── */
    function updateSelCount() {
        var n = 0;

        document.querySelectorAll('#<%= gvSubjects.ClientID %> tbody tr').forEach(function (row) {
            var chk = row.querySelector('input[id*="chkSelect"]');
            if (chk && chk.checked) {
                n++;
            }
        });

        var box = document.getElementById('selCountBox');
        document.getElementById('selCount').textContent = n;
        box.style.display = n > 0 ? '' : 'none';
        // update subject count badge
        var total = document.querySelectorAll('.sub-chk').length;
        var sc = document.getElementById('subjectCount');
        if (sc) sc.textContent = total;
    }

    function updateHiddenSelection() {
        var ids = [];
        document.querySelectorAll('#<%= gvSubjects.ClientID %> tbody tr').forEach(function (row) {
            var chk = row.querySelector('input[id*="chkSelect"]');
            if (chk && chk.checked) {
                ids.push(row.getAttribute('data-key'));
            }
        });

        document.getElementById('<%= hfSelectedSubjectIds.ClientID %>').value = ids.join(',');
    }

    /* ── Filter subjects ────────────────────────────────────── */
    function filterSubjects(val) {
        val = (val || '').toLowerCase().trim();
        document.querySelectorAll('#<%= gvSubjects.ClientID %> tbody tr').forEach(function (r) {
            var sub = r.querySelector('.als-sub-row');
            var d = sub ? (sub.dataset.search || '') : '';
            r.style.display = (!val || d.includes(val)) ? '' : 'none';
        });
    }

    /* ── Filter tracker ─────────────────────────────────────── */
    function filterTracker(val) {
        val = (val || '').toLowerCase().trim();
        document.querySelectorAll('#<%= gvTracker.ClientID %> tbody tr').forEach(function (r) {
            r.style.display = (!val || r.innerText.toLowerCase().includes(val)) ? '' : 'none';
        });
    }

    /* ── Validate before assign ─────────────────────────────── */
    function validateAndConfirm() {
        if (isSuperAdmin) {
            showToast('SuperAdmin has view-only access. Cannot assign subjects.', 'warning');
            return false;
        }

        var stream = document.getElementById('<%= ddlStream.ClientID %>');
        var level = document.getElementById('<%= ddlLevel.ClientID %>');
        var semester = document.getElementById('<%= ddlSemester.ClientID %>');
        var ok = true;

        if (!stream.value || stream.value === '0') {
            document.getElementById('errStream').textContent = 'Please select a stream.';
            ok = false;
        } else document.getElementById('errStream').textContent = '';

        if (!level.value || level.value === '0') {
            document.getElementById('errLevel').textContent = 'Please select a level.';
            ok = false;
        } else document.getElementById('errLevel').textContent = '';

        if (!semester.value || semester.value === '0') {
            document.getElementById('errSemester').textContent = 'Please select a semester.';
            ok = false;
        } else document.getElementById('errSemester').textContent = '';

        var sel = 0;

        document.querySelectorAll('#<%= gvSubjects.ClientID %> tbody tr').forEach(function (row) {
            var chk = row.querySelector('input[id*="chkSelect"]');
            if (chk && chk.checked) {
                sel++;
            }
        });

        if (sel === 0) {
            showToast('Please select at least one subject to assign.', 'warning');
            ok = false;
        }

        return ok;
    }

    /* ── Path bar update ────────────────────────────────────── */
    function updatePathBar() {
        var stream = document.getElementById('<%= ddlStream.ClientID %>');
        var course = document.getElementById('<%= ddlCourse.ClientID %>');
        var level = document.getElementById('<%= ddlLevel.ClientID %>');
        var semester = document.getElementById('<%= ddlSemester.ClientID %>');
        var bar = document.getElementById('pathBar');

        var sText = stream.value !== '0' ? stream.options[stream.selectedIndex].text : null;
        if (!sText) { bar.style.display = 'none'; return; }

        bar.style.display = '';
        document.getElementById('pc_stream').textContent = sText;
        document.getElementById('pc_course').textContent =
            (course && course.value !== '0') ? course.options[course.selectedIndex].text : '—';
        document.getElementById('pc_level').textContent =
            (level && level.value !== '0') ? level.options[level.selectedIndex].text : '—';
        document.getElementById('pc_sem').textContent =
            (semester && semester.value !== '0') ? semester.options[semester.selectedIndex].text : '—';
    }

    /* ── Init on page load ──────────────────────────────────── */
    document.addEventListener('DOMContentLoaded', function () {
        updateSelCount();
        updatePathBar();
        // count initial subjects
        var total = document.querySelectorAll('.sub-chk').length;
        var sc = document.getElementById('subjectCount');
        if (sc) sc.textContent = total;
    });
</script>

</asp:Content>
