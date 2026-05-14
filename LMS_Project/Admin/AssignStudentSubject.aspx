<%@ Page Title="Assign Student Subjects" Language="C#"
    MasterPageFile="~/Admin/AdminMaster.master"
    AutoEventWireup="true"
    CodeBehind="AssignStudentSubject.aspx.cs"
    Inherits="LearningManagementSystem.Admin.AssignStudentSubject" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server" >
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

<%-- ══ HIDDEN FIELDS ══ --%>
<asp:HiddenField ID="hfStreamId"        runat="server" Value="0" />
<asp:HiddenField ID="hfCourseId"        runat="server" Value="0" />
<asp:HiddenField ID="hfLevelId"         runat="server" Value="0" />
<asp:HiddenField ID="hfSemesterId"      runat="server" Value="0" />
<asp:HiddenField ID="hfSectionId"       runat="server" Value="0" />
<%--
    CRITICAL: NO ClientIDMode="Static" here.
    JS reads the value via the server-rendered ClientID.
--%>
<asp:HiddenField ID="hfSelectedSubjects" runat="server" />

<%-- ══ TOAST ══ --%>
<div class="toast-container position-fixed p-3" style="top:70px;right:16px;z-index:9999;">
    <div id="liveToast" class="toast align-items-center border-0 shadow-lg" role="alert" aria-atomic="true">
        <div class="d-flex">
            <div class="toast-body fw-semibold" id="toastMsg" style="font-size:13px;"></div>
            <button type="button" class="btn-close me-2 m-auto" data-bs-dismiss="toast"></button>
        </div>
    </div>
</div>

<%-- ══ HEADER ══ --%>
<div class="ass-page-header mb-4">
    <div class="d-flex flex-wrap justify-content-between align-items-start gap-3">
        <div>
            <h4 class="fw-bold mb-1 d-flex align-items-center gap-2">
                <span class="ass-header-icon"><i class="fa fa-user-tag"></i></span>
                Assign Subjects to Students
            </h4>
            <div class="text-muted small d-flex align-items-center flex-wrap gap-2">
                <span>Select class → load → select subjects → assign</span>
                <asp:Label ID="lblSessionName"      runat="server"
                    CssClass="badge bg-primary bg-opacity-10 text-primary px-2 py-1" />
                <asp:Label ID="lblSuperAdminBadge"  runat="server" Visible="false"
                    CssClass="badge bg-warning text-dark">
                    <i class="fa fa-eye me-1"></i>View Only
                </asp:Label>
            </div>
        </div>
        <div class="d-flex gap-2 flex-wrap">
            <div class="ass-mini-stat border rounded-3 px-3 py-2 text-center">
                <div class="text-muted" style="font-size:10px;text-transform:uppercase;">Total Assignments</div>
                <div class="fw-bold fs-5 text-primary"><asp:Label ID="lblTotalAssigned"    runat="server" Text="0" /></div>
            </div>
            <div class="ass-mini-stat border rounded-3 px-3 py-2 text-center">
                <div class="text-muted" style="font-size:10px;text-transform:uppercase;">Students Assigned</div>
                <div class="fw-bold fs-5 text-success"><asp:Label ID="lblStudentsAssigned" runat="server" Text="0" /></div>
            </div>
            <div class="ass-mini-stat border rounded-3 px-3 py-2 text-center">
                <div class="text-muted" style="font-size:10px;text-transform:uppercase;">Pending</div>
                <div class="fw-bold fs-5 text-warning"><asp:Label ID="lblPending"          runat="server" Text="0" /></div>
            </div>
        </div>
    </div>
</div>

<%-- ══ TWO-COLUMN LAYOUT ══ --%>
<div class="row g-4">

    <%-- ── LEFT COLUMN ── --%>
    <div class="col-12 col-lg-5">

        <%-- Filter Card --%>
        <div class="card shadow-sm border-0 rounded-4 mb-4">
            <div class="card-header ass-card-header text-white py-3">
                <h6 class="mb-0 fw-bold"><i class="fa fa-filter me-2"></i>Select Class</h6>
                <small class="opacity-75">Choose stream / level / semester then click Load</small>
            </div>
            <div class="card-body p-4">
                <div class="ass-path-bar mb-3" id="pathBar" style="display:none">
                    <span class="path-chip chip-stream" id="pc_stream">—</span>
                    <i class="fa fa-chevron-right path-arr"></i>
                    <span class="path-chip chip-course" id="pc_course">—</span>
                    <i class="fa fa-chevron-right path-arr"></i>
                    <span class="path-chip chip-level"  id="pc_level">—</span>
                    <i class="fa fa-chevron-right path-arr"></i>
                    <span class="path-chip chip-sem"    id="pc_sem">—</span>
                </div>
                <div class="row g-3">
                    <div class="col-12">
                        <label class="form-label fw-semibold small">Stream <span class="req">*</span></label>
                        <asp:DropDownList ID="ddlStream" runat="server" CssClass="form-select ass-select"
                            AutoPostBack="true" OnSelectedIndexChanged="ddlStream_Changed">
                            <asp:ListItem Value="0">-- Select Stream --</asp:ListItem>
                        </asp:DropDownList>
                        <div class="form-err" id="errStream"></div>
                    </div>
                    <div class="col-12">
                        <label class="form-label fw-semibold small">Course / Branch</label>
                        <asp:DropDownList ID="ddlCourse" runat="server" CssClass="form-select ass-select"
                            AutoPostBack="true" OnSelectedIndexChanged="ddlCourse_Changed">
                            <asp:ListItem Value="0">-- Select Course --</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div class="col-6">
                        <label class="form-label fw-semibold small">Level / Year <span class="req">*</span></label>
                        <asp:DropDownList ID="ddlLevel" runat="server" CssClass="form-select ass-select"
                            AutoPostBack="true" OnSelectedIndexChanged="ddlLevel_Changed">
                            <asp:ListItem Value="0">-- Level --</asp:ListItem>
                        </asp:DropDownList>
                        <div class="form-err" id="errLevel"></div>
                    </div>
                    <div class="col-6">
                        <label class="form-label fw-semibold small">Semester <span class="req">*</span></label>
                        <asp:DropDownList ID="ddlSemester" runat="server" CssClass="form-select ass-select"
                            AutoPostBack="true" OnSelectedIndexChanged="ddlSemester_Changed">
                            <asp:ListItem Value="0">-- Semester --</asp:ListItem>
                        </asp:DropDownList>
                        <div class="form-err" id="errSemester"></div>
                    </div>
                    <div class="col-12">
                        <label class="form-label fw-semibold small">Section (optional)</label>
                        <asp:DropDownList ID="ddlSection" runat="server" CssClass="form-select ass-select"
                            AutoPostBack="true" OnSelectedIndexChanged="ddlSection_Changed">
                            <asp:ListItem Value="0">-- All Sections --</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div class="col-12">
                        <asp:Panel ID="pnlLoadBtn" runat="server">
                            <asp:Button ID="btnLoad" runat="server"
                                Text="Load Students &amp; Subjects"
                                CssClass="btn btn-outline-primary rounded-pill px-4 w-100 fw-semibold"
                                OnClick="btnLoad_Click"
                                OnClientClick="return validateFilters();" />
                        </asp:Panel>
                    </div>
                </div>
            </div>
        </div>

        <%-- Subjects Card --%>
        <div class="card shadow-sm border-0 rounded-4 mb-4">
            <div class="card-header bg-transparent border-bottom py-3 px-4 d-flex align-items-center justify-content-between">
                <div>
                    <span class="fw-semibold small">
                        <i class="fa fa-book me-1 text-primary"></i>Subjects for this Class
                    </span>
                    <span class="badge bg-primary rounded-pill ms-2" id="subjCount">0</span>
                </div>
                <div class="form-check form-switch mb-0">
                    <input type="checkbox" class="form-check-input" id="chkSelAllSubj"
                           onchange="toggleAllSubjects(this)" />
                    <label class="form-check-label small" for="chkSelAllSubj">All</label>
                </div>
            </div>
            <div class="ass-subj-list-wrap">
                <asp:GridView ID="gvSubjects" runat="server"
                    CssClass="table table-sm ass-subj-table mb-0"
                    AutoGenerateColumns="false"
                    GridLines="None"
                    ShowHeader="false"
                    OnRowDataBound="gvSubjects_RowDataBound">
                    <EmptyDataTemplate>
                        <div class="text-center py-4">
                            <i class="fa fa-book fa-2x text-muted mb-2 d-block"></i>
                            <p class="text-muted small mb-0">Select a class and click Load to see subjects.</p>
                        </div>
                    </EmptyDataTemplate>
                    <Columns>
                        <asp:TemplateField ItemStyle-Width="36px" ItemStyle-CssClass="chk-cell">
                            <ItemTemplate>
                                <%-- HiddenField holds SubjectId; checkbox is what user ticks --%>
                                <asp:HiddenField ID="hfSubjectId" runat="server" />
                                <input type="checkbox" class="form-check-input subj-chk" onchange="updateSubjCount()" />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField>
                            <ItemTemplate>
                                <div class="ass-subj-row">
                                    <div class="fw-semibold small"><%# Eval("SubjectName") %></div>
                                    <div class="text-muted" style="font-size:11px;">
                                        <span class="badge-code"><%# Eval("SubjectCode") %></span>
                                        <%# Convert.ToBoolean(Eval("IsMandatory"))
                                            ? "&nbsp;<span class='badge bg-danger bg-opacity-10 text-danger' style='font-size:10px'>Mandatory</span>"
                                            : "&nbsp;<span class='badge bg-info bg-opacity-10 text-info' style='font-size:10px'>Elective</span>" %>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
            <%-- Subject pagination --%>
            <asp:Panel ID="pnlSubjPager" runat="server" Visible="false"
                CssClass="d-flex align-items-center justify-content-between px-3 py-2 border-top">
                <asp:Button ID="btnSubjPrev" runat="server" Text="‹ Prev"
                    CssClass="ass-page-btn" OnClick="SubjPrev_Click" />
                <asp:Label  ID="lblSubjPage" runat="server" CssClass="text-muted small" />
                <asp:Button ID="btnSubjNext" runat="server" Text="Next ›"
                    CssClass="ass-page-btn" OnClick="SubjNext_Click" />
            </asp:Panel>
            <div class="px-4 py-2 border-top" id="subjSelBox" style="display:none">
                <span class="text-muted small">
                    <i class="fa fa-check-circle text-success me-1"></i>
                    <span id="subjSelCount">0</span> selected (across all pages)
                </span>
            </div>
        </div>

        <%-- Assign Button --%>
        <asp:Panel ID="pnlAssignBtn" runat="server">
            <asp:Button ID="btnAssign" runat="server"
                Text="Assign Selected Subjects to All Students"
                CssClass="btn btn-primary rounded-pill px-4 fw-semibold shadow-sm w-100 mb-4"
                OnClick="btnAssign_Click"
                OnClientClick="return collectAndConfirm();"
                UseSubmitBehavior="true" />
        </asp:Panel>
        <asp:Panel ID="pnlSuperAdminNote" runat="server" Visible="false">
            <div class="alert alert-warning border-0 rounded-3 py-2 mb-4" style="font-size:12px">
                <i class="fa fa-eye me-1"></i>SuperAdmin has view-only access. Cannot assign subjects.
            </div>
        </asp:Panel>

    </div>

    <%-- ── RIGHT COLUMN ── --%>
    <div class="col-12 col-lg-7">

        <%-- Students --%>
        <div class="card shadow-sm border-0 rounded-4 mb-4">
            <div class="card-header bg-transparent border-bottom py-3 px-4 d-flex align-items-center justify-content-between flex-wrap gap-2">
                <div>
                    <span class="fw-semibold small">
                        <i class="fa fa-users me-1 text-primary"></i>Students in Selected Class
                    </span>
                    <span class="badge bg-primary rounded-pill ms-2" id="studCount">0</span>
                </div>
                <div class="ass-search-wrap">
                    <i class="fa fa-search ass-search-icon"></i>
                    <input type="text" id="studSearchBox" class="form-control ass-search-input"
                           placeholder="Search students…"
                           oninput="filterRows('<%= gvStudents.ClientID %>',this.value)" />
                </div>
            </div>
            <div class="table-responsive" style="max-height:320px;overflow-y:auto">
                <asp:GridView ID="gvStudents" runat="server"
                    CssClass="table table-sm align-middle modern-table mb-0"
                    AutoGenerateColumns="false"
                    GridLines="None">
                    <HeaderStyle CssClass="ass-table-header" />
                    <EmptyDataTemplate>
                        <div class="text-center py-4">
                            <i class="fa fa-users fa-2x text-muted mb-2 d-block"></i>
                            <p class="text-muted small mb-0">Select a class and click Load to see students.</p>
                        </div>
                    </EmptyDataTemplate>
                    <Columns>
                        <asp:TemplateField HeaderText="#" ItemStyle-Width="36px">
                            <ItemTemplate><span class="text-muted small"><%# Container.DataItemIndex + 1 %></span></ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Student">
                            <ItemTemplate>
                                <div class="d-flex align-items-center gap-2">
                                    <div class="ass-avatar" style="background:<%# GetAvatarColor(Eval("FullName").ToString()) %>">
                                        <%# GetInitials(Eval("FullName").ToString()) %>
                                    </div>
                                    <div>
                                        <div class="fw-semibold small"><%# Eval("FullName") %></div>
                                        <div class="text-muted" style="font-size:11px;"><%# Eval("Username") %></div>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="RollNumber" HeaderText="Roll No" />
                        <asp:TemplateField HeaderText="Subjects Assigned">
                            <ItemTemplate>
                                <span class="badge <%# Convert.ToInt32(Eval("AssignedCount")) > 0 ? "bg-success bg-opacity-15 text-success" : "bg-warning bg-opacity-15 text-warning" %> rounded-pill px-2">
                                    <%# Eval("AssignedCount") %> assigned
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Subjects">
                            <ItemTemplate>
                                <div class="text-muted" style="font-size:11px;max-width:200px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;"
                                     title="<%# Eval("AssignedSubjects") %>">
                                    <%# string.IsNullOrEmpty(Eval("AssignedSubjects")?.ToString())
                                        ? "<span class='text-danger'>None assigned</span>"
                                        : Eval("AssignedSubjects").ToString() %>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
            <%-- Student pagination --%>
            <asp:Panel ID="pnlStudPager" runat="server" Visible="false"
                CssClass="d-flex align-items-center justify-content-between px-3 py-2 border-top">
                <asp:Button ID="btnStudPrev" runat="server" Text="‹ Prev"
                    CssClass="ass-page-btn" OnClick="StudPrev_Click" />
                <asp:Label  ID="lblStudPage" runat="server" CssClass="text-muted small" />
                <asp:Button ID="btnStudNext" runat="server" Text="Next ›"
                    CssClass="ass-page-btn" OnClick="StudNext_Click" />
            </asp:Panel>
        </div>

        <%-- Tracker --%>
        <div class="d-flex align-items-center gap-2 flex-wrap mb-3">
            <span class="fw-semibold small text-muted me-auto">
                <i class="fa fa-clipboard-list me-1"></i>Assignment Tracker
            </span>
            <div class="ass-search-wrap">
                <i class="fa fa-search ass-search-icon"></i>
                <input type="text" id="trackerSearch" class="form-control ass-search-input"
                       placeholder="Search tracker…"
                       oninput="filterRows('<%= gvAssigned.ClientID %>',this.value)" />
            </div>
            <asp:DropDownList ID="ddlTrackerFilter" runat="server"
                CssClass="form-select ass-tracker-filter"
                AutoPostBack="true"
                OnSelectedIndexChanged="ddlTrackerFilter_Changed">
                <asp:ListItem Value="All">All Students</asp:ListItem>
                <asp:ListItem Value="Assigned">Assigned</asp:ListItem>
                <asp:ListItem Value="Pending">Not Assigned</asp:ListItem>
            </asp:DropDownList>
        </div>

        <div class="card shadow-sm border-0 rounded-4 overflow-hidden">
            <div class="table-responsive">
                <asp:GridView ID="gvAssigned" runat="server"
                    CssClass="table table-hover align-middle modern-table mb-0"
                    AutoGenerateColumns="false"
                    OnRowCommand="gvAssigned_RowCommand"
                    GridLines="None">
                    <HeaderStyle CssClass="ass-table-header" />
                    <EmptyDataTemplate>
                        <div class="text-center py-5">
                            <i class="fa fa-clipboard-list fa-3x text-muted mb-3 d-block"></i>
                            <p class="fw-semibold text-muted mb-1">No assignments yet</p>
                            <p class="text-muted small">Use the form on the left to assign subjects.</p>
                        </div>
                    </EmptyDataTemplate>
                    <Columns>
                        <asp:TemplateField HeaderText="#" ItemStyle-Width="36px">
                            <ItemTemplate><span class="text-muted small"><%# Container.DataItemIndex + 1 %></span></ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Student">
                            <ItemTemplate>
                                <div class="d-flex align-items-center gap-2">
                                    <div class="ass-tbl-avatar" style="background:<%# GetAvatarColor(Eval("FullName").ToString()) %>">
                                        <%# GetInitials(Eval("FullName").ToString()) %>
                                    </div>
                                    <div>
                                        <div class="fw-semibold small"><%# Eval("FullName") %></div>
                                        <div class="text-muted" style="font-size:11px;"><%# Eval("RollNumber") %></div>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Subject">
                            <ItemTemplate>
                                <div class="fw-semibold small"><%# Eval("SubjectName") %></div>
                                <span class="badge-code"><%# Eval("SubjectCode") %></span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Class">
                            <ItemTemplate>
                                <div class="d-flex flex-wrap gap-1">
                                    <span class="acad-tag tag-stream"><%# Eval("StreamName") %></span>
                                    <span class="acad-tag tag-sem"><%# Eval("SemesterName") %></span>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Assigned On" ItemStyle-Width="100px">
                            <ItemTemplate>
                                <span class="text-muted small">
                                    <%# Eval("AssignedOn") != DBNull.Value
                                        ? Convert.ToDateTime(Eval("AssignedOn")).ToString("dd MMM yy")
                                        : "—" %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="" ItemStyle-Width="40px" ItemStyle-CssClass="text-center">
                            <ItemTemplate>
                                <asp:LinkButton runat="server"
                                    CommandName="DeleteRow"
                                    CommandArgument='<%# Eval("Id") %>'
                                    CssClass="ass-del-btn"
                                    title="Remove"
                                    OnClientClick="return confirm('Remove this assignment?');">
                                    <i class="fa fa-times"></i>
                                </asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </div>

        <div class="d-flex justify-content-center mt-3">
            <asp:Panel ID="pnlTrackerPager" runat="server"
                CssClass="d-flex align-items-center gap-2 flex-wrap justify-content-center" />
        </div>

    </div>
</div>

<%-- ══ STYLES ══ --%>
<style>
:root{--primary:#4f46e5;--primary-lt:#eef2ff;}
.ass-header-icon{width:36px;height:36px;border-radius:10px;background:var(--primary-lt);color:var(--primary);display:inline-flex;align-items:center;justify-content:center;}
.req{color:#dc2626;}
.form-err{color:#dc2626;font-size:11px;margin-top:3px;min-height:14px;}
.ass-mini-stat{background:#fff;min-width:100px;transition:transform .2s,box-shadow .2s;}
.ass-mini-stat:hover{transform:translateY(-2px);box-shadow:0 4px 12px rgba(0,0,0,.08)!important;}
.ass-card-header{background:linear-gradient(135deg,#4f46e5,#6366f1);border-radius:16px 16px 0 0!important;}
.ass-path-bar{display:flex;align-items:center;gap:6px;flex-wrap:wrap;padding:8px 12px;background:#f8fafc;border-radius:10px;border:1px solid #e2e8f0;}
.path-chip{font-size:11px;font-weight:600;padding:2px 8px;border-radius:6px;}
.chip-stream{background:#eef2ff;color:#4f46e5;}
.chip-course{background:#e0f2fe;color:#0369a1;}
.chip-level{background:#f0fdf4;color:#15803d;}
.chip-sem{background:#fef9c3;color:#92400e;}
.path-arr{color:#94a3b8;font-size:10px;}
.ass-select{font-size:13px;border-radius:8px;}
.ass-select:focus{border-color:#4f46e5;box-shadow:0 0 0 3px rgba(79,70,229,.15);}
.ass-subj-list-wrap{max-height:300px;overflow-y:auto;}
.ass-subj-table td{padding:8px 12px;font-size:13px;border-bottom:1px solid #f1f5f9!important;vertical-align:middle;}
.badge-code{background:#f1f5f9;color:#475569;font-size:10px;font-weight:600;padding:1px 7px;border-radius:5px;font-family:monospace;}
.chk-cell{padding-left:12px!important;}
.acad-tag{display:inline-block;padding:2px 7px;border-radius:5px;font-size:10px;font-weight:600;white-space:nowrap;}
.tag-stream{background:#eef2ff;color:#4f46e5;}
.tag-sem{background:#fef9c3;color:#92400e;}
.ass-table-header th{background:linear-gradient(135deg,#4f46e5,#6366f1)!important;color:#fff!important;border:none!important;padding:12px 14px!important;font-weight:600;font-size:12px;white-space:nowrap;}
.modern-table td{padding:10px 14px;font-size:13px;border-bottom:1px solid #f1f5f9!important;vertical-align:middle;}
.ass-avatar{width:34px;height:34px;border-radius:50%;display:flex;align-items:center;justify-content:center;font-weight:700;font-size:12px;color:#fff;flex-shrink:0;}
.ass-tbl-avatar{width:28px;height:28px;border-radius:50%;display:flex;align-items:center;justify-content:center;font-weight:700;font-size:10px;color:#fff;flex-shrink:0;}
.ass-search-wrap{position:relative;}
.ass-search-icon{position:absolute;top:50%;left:8px;transform:translateY(-50%);color:#94a3b8;font-size:11px;}
.ass-search-input{padding-left:26px;height:30px;font-size:12px;border-radius:7px;width:150px;}
.ass-tracker-filter{height:30px;font-size:12px;border-radius:7px;padding:0 6px;min-width:130px;}
.ass-del-btn{width:24px;height:24px;border-radius:6px;border:none;background:#fee2e2;color:#b91c1c;display:inline-flex;align-items:center;justify-content:center;font-size:10px;cursor:pointer;transition:transform .15s;text-decoration:none;}
.ass-del-btn:hover{transform:scale(1.12);}
.ass-page-btn{padding:4px 10px;border-radius:7px;border:1px solid #e2e8f0;background:#fff;font-size:12px;cursor:pointer;color:#475569;transition:.15s;}
.ass-page-btn:hover,.ass-page-btn.active{background:#4f46e5;color:#fff;border-color:#4f46e5;}
.toast{min-width:280px;border-radius:12px!important;}
.toast.bg-success{background:#16a34a!important;color:#fff!important;}
.toast.bg-danger{background:#dc2626!important;color:#fff!important;}
.toast.bg-warning{background:#d97706!important;color:#fff!important;}
.toast.bg-info{background:#0891b2!important;color:#fff!important;}
</style>

<%-- ══ SCRIPTS ══ --%>
<script>
    // ── Toast ──────────────────────────────────────────────────────
    function showToast(msg, type) {
        var icons = { success: 'check-circle', danger: 'times-circle', warning: 'exclamation-triangle', info: 'info-circle' };
        var t = document.getElementById('liveToast');
        var m = document.getElementById('toastMsg');
        m.innerHTML = '<i class="fa fa-' + (icons[type] || 'info-circle') + ' me-2"></i>' + msg;
        t.className = 'toast align-items-center border-0 shadow-lg text-white bg-' + (type || 'success');
        bootstrap.Toast.getOrCreateInstance(t, { delay: 5000 }).show();
    }
    function serverToast(msg, type) { showToast(msg, type); }

    // ── Validate filters before Load ───────────────────────────────
    function validateFilters() {
        var stream = document.getElementById('<%= ddlStream.ClientID %>');
    var level = document.getElementById('<%= ddlLevel.ClientID %>');
    var sem = document.getElementById('<%= ddlSemester.ClientID %>');
        var ok = true;
        document.getElementById('errStream').textContent = (!stream.value || stream.value === '0') ? (ok = false, 'Required') : '';
        document.getElementById('errLevel').textContent = (!level.value || level.value === '0') ? (ok = false, 'Required') : '';
        document.getElementById('errSemester').textContent = (!sem.value || sem.value === '0') ? (ok = false, 'Required') : '';
        if (!ok) showToast('Please complete all required filters.', 'warning');
        return ok;
    }

    // ── CRITICAL: collect IDs and write to hidden field ─────────────
    // Called by OnClientClick of btnAssign BEFORE postback fires.
    // Reads every HiddenField in the subjects GridView rows where the
    // sibling checkbox is checked.
    function collectAndConfirm() {
        var gv = document.getElementById('<%= gvSubjects.ClientID %>');
    var hfEl = document.getElementById('<%= hfSelectedSubjects.ClientID %>');

        if (!gv || !hfEl) { showToast('Page not ready — please wait.', 'warning'); return false; }

        // Each row in tbody has: td > [HiddenField input, checkbox input] then td > subject info
        var rows = gv.querySelectorAll('tbody tr');
        var ids = [];

        rows.forEach(function (row) {
            // Find the checkbox (type=checkbox) and hidden field (type=hidden) in the first cell
            var firstCell = row.cells[0];
            if (!firstCell) return;
            var chk = firstCell.querySelector('input[type="checkbox"]');
            var hf = firstCell.querySelector('input[type="hidden"]');
            if (chk && chk.checked && hf && hf.value) {
                ids.push(hf.value);
            }
        });

        if (ids.length === 0) {
            showToast('Please tick at least one subject checkbox.', 'warning');
            return false;
        }

        hfEl.value = ids.join(',');
        console.log('[Assign] hfSelectedSubjects =', hfEl.value); // debug

        return confirm('Assign ' + ids.length + ' subject(s) to all students in this class?\n\nStudents already assigned will be skipped automatically.');
    }

    // ── Select all checkboxes ───────────────────────────────────────
    function toggleAllSubjects(masterChk) {
        var gv = document.getElementById('<%= gvSubjects.ClientID %>');
        if (!gv) return;
        gv.querySelectorAll('tbody tr td:first-child input[type="checkbox"]')
            .forEach(function (c) { c.checked = masterChk.checked; });
        updateSubjCount();
    }

    function updateSubjCount() {
        var gv = document.getElementById('<%= gvSubjects.ClientID %>');
        if (!gv) return;
        var n = gv.querySelectorAll('tbody tr td:first-child input[type="checkbox"]:checked').length;
        var box = document.getElementById('subjSelBox');
        var sp = document.getElementById('subjSelCount');
        if (sp) sp.textContent = n;
        if (box) box.style.display = n > 0 ? '' : 'none';
    }

    // ── Table row search ────────────────────────────────────────────
    function filterRows(gvId, val) {
        val = (val || '').toLowerCase().trim();
        var gv = document.getElementById(gvId);
        if (!gv) return;
        gv.querySelectorAll('tbody tr').forEach(function (r) {
            r.style.display = (!val || r.innerText.toLowerCase().includes(val)) ? '' : 'none';
        });
    }

    // ── Path bar ────────────────────────────────────────────────────
    function updatePathBar() {
        var st = document.getElementById('<%= ddlStream.ClientID %>');
    var co = document.getElementById('<%= ddlCourse.ClientID %>');
    var lv = document.getElementById('<%= ddlLevel.ClientID %>');
    var sm = document.getElementById('<%= ddlSemester.ClientID %>');
        var bar = document.getElementById('pathBar');
        if (!st || st.value === '0') { if (bar) bar.style.display = 'none'; return; }
        if (bar) bar.style.display = '';
        document.getElementById('pc_stream').textContent = st.options[st.selectedIndex].text;
        document.getElementById('pc_course').textContent = (co && co.value !== '0') ? co.options[co.selectedIndex].text : '—';
        document.getElementById('pc_level').textContent = (lv && lv.value !== '0') ? lv.options[lv.selectedIndex].text : '—';
        document.getElementById('pc_sem').textContent = (sm && sm.value !== '0') ? sm.options[sm.selectedIndex].text : '—';
    }

    document.addEventListener('DOMContentLoaded', function () {
        updateSubjCount();
        updatePathBar();
        var sc = document.getElementById('subjCount');
        var stc = document.getElementById('studCount');
        var gvS = document.getElementById('<%= gvSubjects.ClientID %>');
    var gvT = document.getElementById('<%= gvStudents.ClientID %>');
    if (sc && gvS) sc.textContent = gvS.querySelectorAll('tbody tr').length;
    if (stc && gvT) stc.textContent = gvT.querySelectorAll('tbody tr').length;
});
</script>
</asp:Content>