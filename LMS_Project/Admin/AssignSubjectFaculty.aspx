<%@ Page Title="Assign Subject Faculty" Language="C#"
    MasterPageFile="~/Admin/AdminMaster.master"
    AutoEventWireup="true"
    CodeBehind="AssignSubjectFaculty.aspx.cs"
    Inherits="LearningManagementSystem.Admin.AssignSubjectFaculty" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server" />
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

<%-- ══ HIDDEN FIELDS ═══════════════════════════════════════ --%>
<%-- hfTeacherId : shared by single + bulk — JS sets it after live-search --%>
<asp:HiddenField ID="hfTeacherId"      runat="server" Value="" />
<%-- hfBulkSubjectIds : JS serialises checked subject IDs before bulk postback --%>
<asp:HiddenField ID="hfBulkSubjectIds" runat="server" Value="" />

<%-- ══ TOAST ════════════════════════════════════════════════ --%>
<div class="toast-container position-fixed p-3"
     style="top:70px;right:16px;z-index:9999;">
    <div id="liveToast" class="toast align-items-center border-0 shadow-lg"
         role="alert" aria-atomic="true">
        <div class="d-flex">
            <div class="toast-body fw-semibold" id="toastMsg" style="font-size:13px;"></div>
            <button type="button" class="btn-close me-2 m-auto"
                    data-bs-dismiss="toast"></button>
        </div>
    </div>
</div>

<%-- ══ PAGE HEADER ══════════════════════════════════════════ --%>
<div class="mb-4">
    <div class="d-flex flex-wrap justify-content-between align-items-start gap-3">

        <div>
            <h4 class="fw-bold mb-1 d-flex align-items-center gap-2">
                <span class="asf-hdr-icon"><i class="fa fa-chalkboard-teacher"></i></span>
                Assign Subjects to Teachers
            </h4>
            <div class="text-muted small d-flex align-items-center flex-wrap gap-2">
                <span>Map subjects to teachers — section-wise</span>
                <span class="dot-sep"></span>
                <asp:Label ID="lblSessionName" runat="server"
                    CssClass="badge bg-primary bg-opacity-10 text-primary px-2 py-1" />
                <asp:Label ID="lblSuperAdminBadge" runat="server" Visible="false"
                    CssClass="badge bg-warning text-dark">
                    <i class="fa fa-eye me-1"></i>View Only
                </asp:Label>
            </div>
        </div>

        <%-- Stats --%>
        <div class="d-flex gap-2 flex-wrap">
            <div class="asf-stat border rounded-3 px-3 py-2 text-center">
                <div class="asf-stat-lbl">Total</div>
                <div class="fw-bold fs-5 text-primary">
                    <asp:Label ID="lblTotalAssigned" runat="server" Text="0" />
                </div>
            </div>
            <div class="asf-stat border rounded-3 px-3 py-2 text-center">
                <div class="asf-stat-lbl">Active</div>
                <div class="fw-bold fs-5 text-success">
                    <asp:Label ID="lblActive" runat="server" Text="0" />
                </div>
            </div>
            <div class="asf-stat border rounded-3 px-3 py-2 text-center">
                <div class="asf-stat-lbl">Teachers</div>
                <div class="fw-bold fs-5 text-info">
                    <asp:Label ID="lblTeachersAssigned" runat="server" Text="0" />
                </div>
            </div>
        </div>

    </div>
</div>

<%-- ══ TWO-COLUMN LAYOUT ════════════════════════════════════ --%>
<div class="row g-4">

    <%-- ── LEFT: Forms ──────────────────────────────────────── --%>
    <div class="col-12 col-lg-5">

        <%-- Tab switcher --%>
        <div class="asf-tabs mb-3">
            <button type="button" class="asf-tab active" id="tabSingleBtn"
                    onclick="switchTab('single')">
                <i class="fa fa-user me-1"></i>Single Assign
            </button>
            <button type="button" class="asf-tab" id="tabBulkBtn"
                    onclick="switchTab('bulk')">
                <i class="fa fa-layer-group me-1"></i>Bulk Assign
            </button>
        </div>

        <%-- ════ SINGLE ASSIGN CARD ════ --%>
        <div id="divSingle">
            <div class="card shadow-sm border-0 rounded-4">
                <div class="card-header asf-card-hdr text-white py-3">
                    <h6 class="mb-0 fw-bold">
                        <i class="fa fa-user-tag me-2"></i>Single Assignment
                    </h6>
                    <small class="opacity-75">
                        One teacher → one subject → one section
                    </small>
                </div>
                <div class="card-body p-4">

                    <%-- Teacher live search --%>
                    <div class="mb-3 position-relative">
                        <label class="form-label fw-semibold small">
                            Teacher <span class="req">*</span>
                        </label>
                        <div class="asf-search-wrap">
                            <i class="fa fa-search asf-srch-ico"></i>
                            <input type="text" id="txtSingleTeacher"
                                   class="form-control asf-srch-input"
                                   placeholder="Type 2+ chars to search teacher..."
                                   autocomplete="off"
                                   oninput="doTeacherSearch(this.value,'single')" />
                        </div>
                        <div id="ddSingleTeacher" class="asf-tch-dropdown" style="display:none"></div>
                        <div id="chipSingleTeacher" class="asf-tch-chip mt-2" style="display:none">
                            <div class="d-flex align-items-center gap-2">
                                <div class="asf-mini-av" id="chipSingleAv"></div>
                                <div class="flex-fill">
                                    <div class="fw-semibold small" id="chipSingleName"></div>
                                    <div class="text-muted" style="font-size:11px" id="chipSingleDetail"></div>
                                </div>
                                <button type="button" class="btn-close"
                                        onclick="clearTeacherChip()" style="font-size:10px"></button>
                            </div>
                        </div>
                        <div class="form-err" id="errSingleTeacher"></div>
                    </div>

                    <%-- Stream filter (narrows sections) --%>
                    <div class="mb-3">
                        <label class="form-label fw-semibold small">
                            Stream <span class="text-muted">(filters sections)</span>
                        </label>
                        <asp:DropDownList ID="ddlStream" runat="server"
                            CssClass="form-select asf-sel"
                            AutoPostBack="true"
                            OnSelectedIndexChanged="ddlStream_Changed">
                            <asp:ListItem Value="0" Text="-- All Streams --" />
                        </asp:DropDownList>
                    </div>

                    <%-- Subject --%>
                    <div class="mb-3">
                        <label class="form-label fw-semibold small">
                            Subject <span class="req">*</span>
                        </label>
                        <asp:DropDownList ID="ddlSubject" runat="server"
                            CssClass="form-select asf-sel">
                            <asp:ListItem Value="0" Text="-- Select Subject --" />
                        </asp:DropDownList>
                        <div class="form-err" id="errSubject"></div>
                    </div>

                    <%-- Section --%>
                    <div class="mb-3">
                        <label class="form-label fw-semibold small">
                            Section <span class="req">*</span>
                        </label>
                        <asp:DropDownList ID="ddlSection" runat="server"
                            CssClass="form-select asf-sel">
                            <asp:ListItem Value="0" Text="-- Select Section --" />
                        </asp:DropDownList>
                        <div class="form-err" id="errSection"></div>
                    </div>

                    <%-- Info --%>
                    <div class="alert alert-info border-0 rounded-3 py-2 px-3 mb-0"
                         style="font-size:12px">
                        <i class="fa fa-info-circle me-1"></i>
                        Same subject can be assigned to <strong>different teachers per section</strong>.
                        One teacher can handle <strong>multiple subjects</strong>.
                    </div>
                </div>

                <div class="card-footer bg-transparent border-top px-4 py-3">
                    <asp:Panel ID="pnlSaveBtn" runat="server">
                        <asp:Button ID="btnSave" runat="server"
                            Text="Assign &amp; Notify Teacher"
                            CssClass="btn btn-primary rounded-pill px-4 fw-semibold w-100"
                            OnClick="btnSave_Click"
                            OnClientClick="return validateSingle();" />
                    </asp:Panel>
                    <asp:Panel ID="pnlSuperAdminNote" runat="server" Visible="false">
                        <div class="alert alert-warning border-0 rounded-3 py-2 mb-0"
                             style="font-size:12px">
                            <i class="fa fa-eye me-1"></i>SuperAdmin has view-only access.
                        </div>
                    </asp:Panel>
                </div>
            </div>
        </div>

        <%-- ════ BULK ASSIGN CARD ════ --%>
        <div id="divBulk" style="display:none">
            <div class="card shadow-sm border-0 rounded-4">
                <div class="card-header asf-card-hdr text-white py-3">
                    <h6 class="mb-0 fw-bold">
                        <i class="fa fa-layer-group me-2"></i>Bulk Assignment
                    </h6>
                    <small class="opacity-75">
                        One teacher → multiple subjects → one section
                    </small>
                </div>
                <div class="card-body p-4">

                    <%-- Bulk teacher live search --%>
                    <div class="mb-3 position-relative">
                        <label class="form-label fw-semibold small">
                            Teacher <span class="req">*</span>
                        </label>
                        <div class="asf-search-wrap">
                            <i class="fa fa-search asf-srch-ico"></i>
                            <input type="text" id="txtBulkTeacher"
                                   class="form-control asf-srch-input"
                                   placeholder="Type 2+ chars to search teacher..."
                                   autocomplete="off"
                                   oninput="doTeacherSearch(this.value,'bulk')" />
                        </div>
                        <div id="ddBulkTeacher" class="asf-tch-dropdown" style="display:none"></div>
                        <div id="chipBulkTeacher" class="asf-tch-chip mt-2" style="display:none">
                            <div class="d-flex align-items-center gap-2">
                                <div class="asf-mini-av" id="chipBulkAv"></div>
                                <div class="flex-fill">
                                    <div class="fw-semibold small" id="chipBulkName"></div>
                                    <div class="text-muted" style="font-size:11px" id="chipBulkDetail"></div>
                                </div>
                                <button type="button" class="btn-close"
                                        onclick="clearBulkTeacherChip()" style="font-size:10px"></button>
                            </div>
                        </div>
                        <div class="form-err" id="errBulkTeacher"></div>
                    </div>

                    <%-- Bulk section --%>
                    <div class="mb-3">
                        <label class="form-label fw-semibold small">
                            Section <span class="req">*</span>
                        </label>
                        <asp:DropDownList ID="ddlBulkSection" runat="server"
                            CssClass="form-select asf-sel">
                            <asp:ListItem Value="0" Text="-- Select Section --" />
                        </asp:DropDownList>
                        <div class="form-err" id="errBulkSection"></div>
                    </div>

                    <%-- Multi-subject checklist --%>
                    <div class="mb-3">
                        <div class="d-flex align-items-center justify-content-between mb-2">
                            <label class="form-label fw-semibold small mb-0">
                                Subjects <span class="req">*</span>
                            </label>
                            <div class="d-flex align-items-center gap-2">
                                <div class="asf-bulk-srch-wrap">
                                    <i class="fa fa-search asf-bsrch-ico"></i>
                                    <input type="text" id="bulkSubjFilter"
                                           class="form-control asf-bsrch-input"
                                           placeholder="Filter..."
                                           oninput="filterBulkSubjects(this.value)" />
                                </div>
                                <div class="form-check form-switch mb-0">
                                    <input type="checkbox" class="form-check-input"
                                           id="chkBulkAll"
                                           onchange="toggleAllBulkSubjs(this)" />
                                    <label class="form-check-label small"
                                           for="chkBulkAll">All</label>
                                </div>
                            </div>
                        </div>

                        <div class="asf-bulk-list">
                            <asp:Repeater ID="rptBulkSubjects" runat="server">
                                <ItemTemplate>
                                    <div class="asf-bulk-item"
                                         data-s='<%# (Eval("SubjectName")+" "+Eval("SubjectCode")).ToString().ToLower() %>'>
                                        <label class="asf-bulk-lbl w-100">
                                            <input type="checkbox"
                                                   class="form-check-input bulk-subj-chk me-2"
                                                   value='<%# Eval("SubjectId") %>'
                                                   onchange="updateBulkCount()" />
                                            <div class="flex-fill">
                                                <div class="fw-semibold small">
                                                    <%# Eval("SubjectName") %>
                                                </div>
                                                <div style="font-size:11px">
                                                    <span class="badge-code"><%# Eval("SubjectCode") %></span>
                                                    &nbsp;·&nbsp;
                                                    <span class="text-muted"><%# Eval("Duration") %></span>
                                                </div>
                                            </div>
                                        </label>
                                    </div>
                                </ItemTemplate>
                                <FooterTemplate>
                                    <asp:Panel ID="pnlNoBulkSubj" runat="server"
                                        Visible='<%# rptBulkSubjects.Items.Count == 0 %>'>
                                        <div class="text-center py-3 text-muted small">
                                            No subjects found for this session.
                                        </div>
                                    </asp:Panel>
                                </FooterTemplate>
                            </asp:Repeater>
                        </div>

                        <div id="bulkCountBox" class="mt-2 text-muted small"
                             style="display:none">
                            <i class="fa fa-check-circle text-success me-1"></i>
                            <span id="bulkCount">0</span> subject(s) selected
                        </div>
                        <div class="form-err" id="errBulkSubjects"></div>
                    </div>

                </div>
                <div class="card-footer bg-transparent border-top px-4 py-3">
                    <asp:Panel ID="pnlBulkSaveBtn" runat="server">
                        <asp:Button ID="btnBulkSave" runat="server"
                            Text="Bulk Assign &amp; Notify Teacher"
                            CssClass="btn btn-primary rounded-pill px-4 fw-semibold w-100"
                            OnClick="btnBulkSave_Click"
                            OnClientClick="return validateBulk();" />
                    </asp:Panel>
                </div>
            </div>
        </div>

    </div>

    <%-- ── RIGHT: Tracker + Workload ─────────────────────────── --%>
    <div class="col-12 col-lg-7">

        <%-- Tracker filters --%>
        <div class="d-flex align-items-center gap-2 flex-wrap mb-3">
            <span class="fw-semibold small text-muted me-auto">
                <i class="fa fa-clipboard-list me-1"></i>Assignment Tracker
            </span>
            <div class="asf-trk-srch-wrap">
                <i class="fa fa-search asf-trk-ico"></i>
                <input type="text" id="trackerSearch"
                       class="form-control asf-trk-input"
                       placeholder="Search..."
                       onkeyup="filterTracker(this.value)" />
            </div>
            <asp:DropDownList ID="ddlTrackerStream" runat="server"
                CssClass="form-select asf-trk-sel"
                AutoPostBack="true"
                OnSelectedIndexChanged="ddlTrackerStream_Changed">
                <asp:ListItem Value="0" Text="All Streams" />
            </asp:DropDownList>
            <asp:DropDownList ID="ddlTrackerStatus" runat="server"
                CssClass="form-select asf-trk-sel"
                AutoPostBack="true"
                OnSelectedIndexChanged="ddlTrackerStatus_Changed">
                <asp:ListItem Value="All"      Text="All Status" />
                <asp:ListItem Value="Active"   Text="Active" />
                <asp:ListItem Value="Inactive" Text="Inactive" />
            </asp:DropDownList>
        </div>

        <%-- Tracker GridView --%>
        <div class="card shadow-sm border-0 rounded-4 overflow-hidden">
            <div class="table-responsive">
                <asp:GridView ID="gvAssign" runat="server"
                    CssClass="table table-hover align-middle modern-table mb-0"
                    AutoGenerateColumns="false"
                    OnRowCommand="gvAssign_RowCommand"
                    GridLines="None">
                    <HeaderStyle CssClass="asf-tbl-hdr" />
                    <EmptyDataTemplate>
                        <div class="text-center py-5">
                            <i class="fa fa-chalkboard-teacher fa-3x text-muted mb-3 d-block"></i>
                            <p class="fw-semibold text-muted mb-1">No assignments yet</p>
                            <p class="text-muted small">
                                Use the form on the left to assign subjects to teachers.
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

                        <asp:TemplateField HeaderText="Teacher">
                            <ItemTemplate>
                                <div class="d-flex align-items-center gap-2">
                                    <div class="asf-tbl-av"
                                         style="background:<%# GetAvatarColor(Eval("TeacherName").ToString()) %>">
                                        <%# GetInitials(Eval("TeacherName").ToString()) %>
                                    </div>
                                    <div>
                                        <div class="fw-semibold small">
                                            <%# Eval("TeacherName") %>
                                        </div>
                                        <div class="text-muted" style="font-size:11px">
                                            <%# Eval("EmployeeId") %>
                                        </div>
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

                        <asp:TemplateField HeaderText="Stream / Section">
                            <ItemTemplate>
                                <span class="acad-tag tag-stream"><%# Eval("StreamName") %></span>
                                <span class="acad-tag tag-sec ms-1"><%# Eval("SectionName") %></span>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Status" ItemStyle-Width="80px">
                            <ItemTemplate>
                                <%# Convert.ToBoolean(Eval("IsActive"))
                                    ? "<span class='badge bg-success bg-opacity-15 text-success rounded-pill px-2' style='font-size:10px'>Active</span>"
                                    : "<span class='badge bg-secondary bg-opacity-15 text-secondary rounded-pill px-2' style='font-size:10px'>Inactive</span>" %>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Assigned" ItemStyle-Width="90px">
                            <ItemTemplate>
                                <span class="text-muted small">
                                    <%# Eval("AssignedOn") != DBNull.Value
                                        ? Convert.ToDateTime(Eval("AssignedOn")).ToString("dd MMM yy")
                                        : "—" %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="" ItemStyle-Width="70px"
                                           ItemStyle-CssClass="text-center">
                            <ItemTemplate>
                                <div class="d-flex gap-1 justify-content-center">
                                    <asp:LinkButton runat="server"
                                        CommandName="Toggle"
                                        CommandArgument='<%# Eval("SubjectFacultyId") %>'
                                        CssClass="asf-act-btn act-tog"
                                        title="Toggle Active/Inactive"
                                         OnClientClick="return confirm('change status of this assignment?');">
                                        <i class="fa fa-power-off"></i>
                                    </asp:LinkButton>
                                    <asp:LinkButton runat="server"
                                        CommandName="DeleteRow"
                                        CommandArgument='<%# Eval("SubjectFacultyId") %>'
                                        CssClass="asf-act-btn act-del"
                                        title="Remove"
                                        OnClientClick="return confirm('Remove this assignment? Prefer Deactivate if attendance exists.');">
                                        <i class="fa fa-times"></i>
                                    </asp:LinkButton>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>

                    </Columns>
                </asp:GridView>
            </div>
        </div>

        <%-- Pagination --%>
        <div class="d-flex justify-content-center mt-3">
            <asp:Panel ID="pnlPager" runat="server"
                CssClass="d-flex align-items-center gap-2 flex-wrap justify-content-center" />
        </div>

        <%-- Workload Summary --%>
        <div class="card shadow-sm border-0 rounded-4 mt-4">
            <div class="card-header bg-transparent border-bottom py-3 px-4">
                <span class="fw-semibold small">
                    <i class="fa fa-chart-bar me-1 text-primary"></i>
                    Teacher Workload Summary (Active)
                </span>
            </div>
            <div class="table-responsive" style="max-height:240px;overflow-y:auto">
                <asp:GridView ID="gvWorkload" runat="server"
                    CssClass="table table-sm align-middle modern-table mb-0"
                    AutoGenerateColumns="false"
                    GridLines="None">
                    <HeaderStyle CssClass="asf-tbl-hdr" />
                    <EmptyDataTemplate>
                        <div class="text-center py-3 text-muted small">No data yet.</div>
                    </EmptyDataTemplate>
                    <Columns>
                        <asp:TemplateField HeaderText="Teacher">
                            <ItemTemplate>
                                <div class="d-flex align-items-center gap-2">
                                    <div class="asf-tbl-av"
                                         style="background:<%# GetAvatarColor(Eval("TeacherName").ToString()) %>">
                                        <%# GetInitials(Eval("TeacherName").ToString()) %>
                                    </div>
                                    <span class="fw-semibold small"><%# Eval("TeacherName") %></span>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="SubjectCount" HeaderText="Subjects"
                            ItemStyle-CssClass="text-center" />
                        <asp:BoundField DataField="SectionCount" HeaderText="Sections"
                            ItemStyle-CssClass="text-center" />
                        <asp:TemplateField HeaderText="Load" ItemStyle-Width="130px">
                            <ItemTemplate>
                                <div class="asf-load-wrap">
                                    <div class="asf-load-bar"
                                         style="width:<%# GetLoadPercent(Eval("SubjectCount")) %>%;
                                                background:<%# GetLoadColor(Eval("SubjectCount")) %>">
                                    </div>
                                </div>
                                <span class="text-muted" style="font-size:10px">
                                    <%# Eval("SubjectCount") %> subj
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>

                <%-- Workload Pagination --%>
                <div class="d-flex justify-content-center mt-3">
                    <asp:Panel ID="pnlWorkloadPager" runat="server"
                        CssClass="d-flex align-items-center gap-2 flex-wrap justify-content-center" />
                </div>
            </div>
        </div>

    </div>
</div>

<%-- ══ STYLES ════════════════════════════════════════════════ --%>
<style>
:root { --pri:#4f46e5; --pri-lt:#eef2ff; }

/* Header */
.asf-hdr-icon { width:36px;height:36px;border-radius:10px;background:var(--pri-lt);color:var(--pri);display:inline-flex;align-items:center;justify-content:center; }
.dot-sep      { width:5px;height:5px;background:#cbd5e1;border-radius:50%;display:inline-block; }
.asf-stat     { background:#fff;min-width:90px;transition:transform .2s; }
.asf-stat:hover { transform:translateY(-2px); }
.asf-stat-lbl { font-size:10px;text-transform:uppercase;letter-spacing:.4px;color:#94a3b8; }
.req          { color:#dc2626; }
.form-err     { color:#dc2626;font-size:11px;margin-top:3px;min-height:14px; }

/* Card header */
.asf-card-hdr { background:linear-gradient(135deg,#4f46e5,#6366f1);border-radius:16px 16px 0 0!important; }

/* Tabs */
.asf-tabs   { display:flex;gap:4px;border-bottom:2px solid #f1f5f9; }
.asf-tab    { padding:8px 16px;font-size:13px;font-weight:500;color:#64748b;border:none;background:none;border-bottom:2px solid transparent;margin-bottom:-2px;border-radius:8px 8px 0 0;cursor:pointer;transition:.15s; }
.asf-tab:hover  { color:var(--pri);background:#f8fafc; }
.asf-tab.active { color:var(--pri);border-bottom-color:var(--pri);background:#fff; }

/* Select */
.asf-sel { font-size:13px;border-radius:8px; }
.asf-sel:focus { border-color:var(--pri);box-shadow:0 0 0 3px rgba(79,70,229,.15); }

/* Teacher live-search */
.asf-search-wrap  { position:relative; }
.asf-srch-ico     { position:absolute;top:50%;left:10px;transform:translateY(-50%);color:#94a3b8;font-size:12px;z-index:2; }
.asf-srch-input   { padding-left:32px;border-radius:8px;font-size:13px; }
.asf-srch-input:focus { border-color:var(--pri);box-shadow:0 0 0 3px rgba(79,70,229,.15); }
.asf-tch-dropdown { position:absolute;z-index:999;left:0;right:0;background:#fff;border:1px solid #e2e8f0;border-radius:10px;box-shadow:0 8px 24px rgba(0,0,0,.12);max-height:220px;overflow-y:auto; }
.asf-tch-item     { padding:10px 14px;cursor:pointer;display:flex;align-items:center;gap:8px;border-bottom:1px solid #f1f5f9;font-size:13px;transition:background .15s; }
.asf-tch-item:last-child { border-bottom:none; }
.asf-tch-item:hover { background:#f0f4ff; }
.asf-mini-av      { width:30px;height:30px;border-radius:50%;display:flex;align-items:center;justify-content:center;font-weight:700;font-size:11px;color:#fff;flex-shrink:0; }
.asf-tch-chip     { background:#eef2ff;border:1px solid #c7d2fe;border-radius:10px;padding:8px 12px; }

/* Bulk subjects */
.asf-bulk-list       { max-height:250px;overflow-y:auto;border:1px solid #e2e8f0;border-radius:10px;background:#fafafa; }
.asf-bulk-item       { border-bottom:1px solid #f1f5f9;transition:background .15s; }
.asf-bulk-item:last-child { border-bottom:none; }
.asf-bulk-item:hover { background:#f1f5f9; }
.asf-bulk-lbl        { display:flex;align-items:center;padding:9px 12px;cursor:pointer;margin:0; }
.asf-bulk-srch-wrap  { position:relative; }
.asf-bsrch-ico       { position:absolute;top:50%;left:8px;transform:translateY(-50%);color:#94a3b8;font-size:11px; }
.asf-bsrch-input     { padding-left:26px;height:28px;font-size:12px;border-radius:7px;width:130px; }

/* Academic tags */
.acad-tag   { display:inline-block;padding:2px 7px;border-radius:5px;font-size:10px;font-weight:600;white-space:nowrap; }
.tag-stream { background:#eef2ff;color:#4f46e5; }
.tag-sec    { background:#f0fdf4;color:#15803d; }
.badge-code { background:#f1f5f9;color:#475569;font-size:10px;font-weight:600;padding:1px 7px;border-radius:5px;font-family:monospace; }

/* Table */
.asf-tbl-hdr th { background:linear-gradient(135deg,#4f46e5,#6366f1)!important;color:#fff!important;border:none!important;padding:12px 14px!important;font-weight:600;font-size:12px;white-space:nowrap; }
.modern-table td { padding:10px 14px;font-size:13px;border-bottom:1px solid #f1f5f9!important;vertical-align:middle; }
.asf-tbl-av  { width:30px;height:30px;border-radius:50%;display:flex;align-items:center;justify-content:center;font-weight:700;font-size:11px;color:#fff;flex-shrink:0; }
.asf-act-btn { width:26px;height:26px;border-radius:6px;border:none;display:inline-flex;align-items:center;justify-content:center;font-size:10px;cursor:pointer;transition:transform .15s;text-decoration:none; }
.asf-act-btn:hover { transform:scale(1.12); }
.act-tog  { background:#fef9c3;color:#92400e; }
.act-del  { background:#fee2e2;color:#b91c1c; }

/* Tracker search */
.asf-trk-srch-wrap { position:relative; }
.asf-trk-ico       { position:absolute;top:50%;left:8px;transform:translateY(-50%);color:#94a3b8;font-size:11px; }
.asf-trk-input     { padding-left:26px;height:30px;font-size:12px;border-radius:7px;width:150px; }
.asf-trk-sel       { height:30px;font-size:12px;border-radius:7px;padding:0 6px;min-width:120px; }

/* Workload bar */
.asf-load-wrap { height:6px;background:#e2e8f0;border-radius:3px;margin-bottom:2px;overflow:hidden; }
.asf-load-bar  { height:100%;border-radius:3px;transition:width .4s; }

/* Pager */
.asf-page-btn { padding:4px 10px;border-radius:7px;border:1px solid #e2e8f0;background:#fff;font-size:12px;cursor:pointer;color:#475569;transition:.15s; }
.asf-page-btn:hover,.asf-page-btn.active { background:var(--pri);color:#fff;border-color:var(--pri); }

/* Toast */
.toast { min-width:280px;border-radius:12px!important; }
.toast.bg-success { background:#16a34a!important;color:#fff!important; }
.toast.bg-danger  { background:#dc2626!important;color:#fff!important; }
.toast.bg-warning { background:#d97706!important;color:#fff!important; }
.toast.bg-info    { background:#0891b2!important;color:#fff!important; }
.form-label { font-size:13px;margin-bottom:4px; }

.asf-tch-dropdown {
    position: absolute;
    z-index: 99999;
    left: 0;
    right: 0;
    background: #fff;
    border: 1px solid #e2e8f0;
    border-radius: 10px;
    box-shadow: 0 8px 24px rgba(0,0,0,.12);
    max-height: 220px;
    overflow-y: auto;
}

.asf-tch-item {
    cursor: pointer !important;
}

/* Responsive */
@media (max-width:767px) {
    .asf-trk-input  { width:110px; }
    .asf-trk-sel    { min-width:100px; }
    .asf-tab        { padding:6px 10px;font-size:12px; }
    .asf-bsrch-input{ width:100px; }
}
</style>

<script>
    /* =========================================================
       Assign Subject Faculty - Clean JS
       Safe refactor: preserves all existing functionality
    ========================================================= */

    /* ─────────────────────────────────────────────────────────
       Globals
    ───────────────────────────────────────────────────────── */
    const isSuperAdmin = '<%= Session["Role"]?.ToString() %>' === 'SuperAdmin';
    const _INST = '<%= InstituteId %>';
    const _SESS = '<%= SessionId %>';

    const hfTeacherId = document.getElementById('<%= hfTeacherId.ClientID %>');
    const hfBulkSubjectIds = document.getElementById('<%= hfBulkSubjectIds.ClientID %>');

    const COLORS = [
        '#4f46e5', '#0891b2', '#059669', '#d97706',
        '#dc2626', '#7c3aed', '#db2777', '#0d9488'
    ];

    /* =========================================================
       Toast
    ========================================================= */
    function showToast(message, type) {

        const iconMap = {
            success: 'check-circle',
            danger: 'times-circle',
            warning: 'exclamation-triangle',
            info: 'info-circle'
        };

        const toast = document.getElementById('liveToast');
        const toastMsg = document.getElementById('toastMsg');

        toastMsg.innerHTML =
            '<i class="fa fa-' + (iconMap[type] || 'info-circle') + ' me-2"></i>' +
            message;

        toast.className =
            'toast align-items-center border-0 shadow-lg text-white bg-' +
            (type || 'success');

        bootstrap.Toast
            .getOrCreateInstance(toast, { delay: 5000 })
            .show();
    }

    function serverToast(msg, type) {
        showToast(msg, type);
    }

    /* =========================================================
       Tabs
    ========================================================= */
    function switchTab(tab) {

        const isSingle = tab === 'single';

        document.getElementById('divSingle').style.display = isSingle ? '' : 'none';
        document.getElementById('divBulk').style.display = isSingle ? 'none' : '';

        document
            .getElementById('tabSingleBtn')
            .classList.toggle('active', isSingle);

        document
            .getElementById('tabBulkBtn')
            .classList.toggle('active', !isSingle);
    }

    /* =========================================================
       Avatar Helpers
    ========================================================= */
    function _avatarColor(text) {

        if (!text) return COLORS[0];

        let hash = 0;

        for (let i = 0; i < text.length; i++) {
            hash = (Math.imul(31, hash) + text.charCodeAt(i)) | 0;
        }

        return COLORS[Math.abs(hash) % COLORS.length];
    }

    function _initials(name) {

        if (!name) return '?';

        const parts = name.trim().split(/\s+/);

        return parts.length === 1
            ? parts[0].substring(0, 2).toUpperCase()
            : (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
    }

    /* =========================================================
       Teacher Search
    ========================================================= */
    let teacherSearchTimer = null;

    function doTeacherSearch(value, mode) {

        clearTimeout(teacherSearchTimer);

        const dropdownId =
            mode === 'single'
                ? 'ddSingleTeacher'
                : 'ddBulkTeacher';

        const dropdown = document.getElementById(dropdownId);

        if (!value || value.trim().length < 2) {
            dropdown.style.display = 'none';
            return;
        }

        teacherSearchTimer = setTimeout(function () {
            fetchTeachers(value.trim(), mode);
        }, 300);
    }

    function fetchTeachers(term, mode) {

        fetch('AssignSubjectFaculty.aspx/SearchTeachers', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=utf-8'
            },
            body: JSON.stringify({
                prefix: term,
                instituteId: _INST,
                sessionId: _SESS
            })
        })
            .then(function (response) {

                if (!response.ok) {
                    throw new Error('HTTP ' + response.status);
                }

                return response.json();
            })
            .then(function (data) {

                const teachers = data.d || [];
                renderTeacherDropdown(teachers, mode);
            })
            .catch(function (error) {

                console.error('Teacher Search Error:', error);
                renderTeacherDropdown([], mode);
            });
    }

    function renderTeacherDropdown(items, mode) {

        const dropdown = document.getElementById(
            mode === 'single'
                ? 'ddSingleTeacher'
                : 'ddBulkTeacher'
        );

        if (!items || items.length === 0) {

            dropdown.innerHTML =
                '<div class="asf-tch-item text-muted">No teachers found</div>';

            dropdown.style.display = 'block';
            return;
        }

        let html = '';

        items.forEach(function (teacher) {

            const fullName = teacher.FullName || '';
            const employeeId = teacher.EmployeeId || '';
            const streamName = teacher.StreamName || '';

            html += `
            <div class="asf-tch-item"
                 onclick="_selectTeacher(
                    '${teacher.UserId}',
                    '${encodeURIComponent(fullName)}',
                    '${encodeURIComponent(employeeId)}',
                    '${encodeURIComponent(streamName)}',
                    '${mode}'
                 )">

                <div class="asf-mini-av"
                     style="background:${_avatarColor(fullName)}">
                    ${_initials(fullName)}
                </div>

                <div>
                    <div class="fw-semibold" style="font-size:13px">
                        ${fullName}
                    </div>

                    <div class="text-muted" style="font-size:11px">
                        ${employeeId}
                        ${streamName ? ' · ' + streamName : ''}
                    </div>
                </div>
            </div>
        `;
        });

        dropdown.innerHTML = html;
        dropdown.style.display = 'block';
    }

    /* =========================================================
       Teacher Selection
    ========================================================= */
    function _selectTeacher(id, name, empId, stream, mode) {

        name = decodeURIComponent(name || '');
        empId = decodeURIComponent(empId || '');
        stream = decodeURIComponent(stream || '');

        if (hfTeacherId) {
            hfTeacherId.value = id;
        }

        saveTeacherState(id, name, empId, stream, mode);

        const details = buildTeacherDetails(empId, stream);
        const color = _avatarColor(name);
        const initials = _initials(name);

        if (mode === 'single') {

            setTeacherUI({
                inputId: 'txtSingleTeacher',
                dropdownId: 'ddSingleTeacher',
                chipId: 'chipSingleTeacher',
                avatarId: 'chipSingleAv',
                nameId: 'chipSingleName',
                detailId: 'chipSingleDetail',
                errorId: 'errSingleTeacher'
            }, {
                name,
                details,
                color,
                initials
            });
        }
        else {

            setTeacherUI({
                inputId: 'txtBulkTeacher',
                dropdownId: 'ddBulkTeacher',
                chipId: 'chipBulkTeacher',
                avatarId: 'chipBulkAv',
                nameId: 'chipBulkName',
                detailId: 'chipBulkDetail',
                errorId: 'errBulkTeacher'
            }, {
                name,
                details,
                color,
                initials
            });
        }
    }

    function setTeacherUI(ids, data) {

        document.getElementById(ids.inputId).value = data.name;
        document.getElementById(ids.dropdownId).style.display = 'none';

        const avatar = document.getElementById(ids.avatarId);

        avatar.textContent = data.initials;
        avatar.style.background = data.color;

        document.getElementById(ids.nameId).textContent = data.name;
        document.getElementById(ids.detailId).textContent = data.details;

        document.getElementById(ids.chipId).style.display = 'block';
        document.getElementById(ids.errorId).textContent = '';
    }

    function buildTeacherDetails(empId, stream) {

        let details = '';

        if (empId) {
            details += empId;
        }

        if (stream) {
            details += (details ? ' · ' : '') + stream;
        }

        return details;
    }

    /* =========================================================
       Session Storage
    ========================================================= */
    function saveTeacherState(id, name, empId, stream, mode) {

        sessionStorage.setItem('asfTeacherId', id || '');
        sessionStorage.setItem('asfTeacherName', name || '');
        sessionStorage.setItem('asfTeacherEmp', empId || '');
        sessionStorage.setItem('asfTeacherStream', stream || '');
        sessionStorage.setItem('asfTeacherMode', mode || 'single');
    }

    function clearTeacherState() {

        sessionStorage.removeItem('asfTeacherId');
        sessionStorage.removeItem('asfTeacherName');
        sessionStorage.removeItem('asfTeacherEmp');
        sessionStorage.removeItem('asfTeacherStream');
        sessionStorage.removeItem('asfTeacherMode');
    }

    function restoreTeacherAfterPostback() {

        const id = sessionStorage.getItem('asfTeacherId');
        const name = sessionStorage.getItem('asfTeacherName');

        if (!id || !name) return;

        _selectTeacher(
            id,
            encodeURIComponent(name),
            encodeURIComponent(sessionStorage.getItem('asfTeacherEmp') || ''),
            encodeURIComponent(sessionStorage.getItem('asfTeacherStream') || ''),
            sessionStorage.getItem('asfTeacherMode') || 'single'
        );
    }

    /* =========================================================
       Clear Teacher
    ========================================================= */
    function clearTeacherChip() {

        hfTeacherId.value = '';

        document.getElementById('chipSingleTeacher').style.display = 'none';
        document.getElementById('txtSingleTeacher').value = '';

        clearTeacherState();
    }

    function clearBulkTeacherChip() {

        hfTeacherId.value = '';

        document.getElementById('chipBulkTeacher').style.display = 'none';
        document.getElementById('txtBulkTeacher').value = '';

        clearTeacherState();
    }

    /* =========================================================
       Validation
    ========================================================= */
    function validateSingle() {

        if (isSuperAdmin) {
            showToast('SuperAdmin has view-only access.', 'warning');
            return false;
        }

        let isValid = true;

        const teacherId = hfTeacherId.value;

        const ddlSubject = document.getElementById('<%= ddlSubject.ClientID %>');
    const ddlSection = document.getElementById('<%= ddlSection.ClientID %>');

        if (!teacherId) {
            document.getElementById('errSingleTeacher').textContent =
                'Please select a teacher.';
            isValid = false;
        } else {
            document.getElementById('errSingleTeacher').textContent = '';
        }

        if (!ddlSubject.value || ddlSubject.value === '0') {
            document.getElementById('errSubject').textContent =
                'Please select a subject.';
            isValid = false;
        } else {
            document.getElementById('errSubject').textContent = '';
        }

        if (!ddlSection.value || ddlSection.value === '0') {
            document.getElementById('errSection').textContent =
                'Please select a section.';
            isValid = false;
        } else {
            document.getElementById('errSection').textContent = '';
        }

        if (!isValid) {
            showToast('Please fill all required fields.', 'warning');
        }

        return isValid;
    }

    function validateBulk() {

        if (isSuperAdmin) {
            showToast('SuperAdmin has view-only access.', 'warning');
            return false;
        }

        let isValid = true;

        const teacherId = hfTeacherId.value;

        const ddlSection =
            document.getElementById('<%= ddlBulkSection.ClientID %>');

        const selectedSubjects = Array
            .from(document.querySelectorAll('.bulk-subj-chk:checked'))
            .map(function (checkbox) {
                return checkbox.value;
            });

        if (!teacherId) {
            document.getElementById('errBulkTeacher').textContent =
                'Please select a teacher.';
            isValid = false;
        } else {
            document.getElementById('errBulkTeacher').textContent = '';
        }

        if (!ddlSection.value || ddlSection.value === '0') {
            document.getElementById('errBulkSection').textContent =
                'Please select a section.';
            isValid = false;
        } else {
            document.getElementById('errBulkSection').textContent = '';
        }

        if (selectedSubjects.length === 0) {
            document.getElementById('errBulkSubjects').textContent =
                'Select at least one subject.';
            isValid = false;
        } else {
            document.getElementById('errBulkSubjects').textContent = '';
        }

        if (isValid) {
            hfBulkSubjectIds.value = selectedSubjects.join(',');
        }

        if (!isValid) {
            showToast('Please fix errors before saving.', 'warning');
        }

        return isValid;
    }

    /* =========================================================
       Bulk Subject Helpers
    ========================================================= */
    function toggleAllBulkSubjs(chk) {

        document
            .querySelectorAll('.bulk-subj-chk')
            .forEach(function (checkbox) {

                const row = checkbox.closest('.asf-bulk-item');

                if (!row || row.style.display !== 'none') {
                    checkbox.checked = chk.checked;
                }
            });

        updateBulkCount();
    }

    function updateBulkCount() {

        const count =
            document.querySelectorAll('.bulk-subj-chk:checked').length;

        document.getElementById('bulkCount').textContent = count;

        document.getElementById('bulkCountBox').style.display =
            count > 0 ? '' : 'none';
    }

    function filterBulkSubjects(value) {

        value = (value || '').toLowerCase().trim();

        document
            .querySelectorAll('.asf-bulk-item')
            .forEach(function (item) {

                const searchableText = item.dataset.s || '';

                item.style.display =
                    !value || searchableText.includes(value)
                        ? ''
                        : 'none';
            });
    }

    /* =========================================================
       Tracker Filter
    ========================================================= */
    function filterTracker(value) {

        value = (value || '').toLowerCase().trim();

        document
            .querySelectorAll('#<%= gvAssign.ClientID %> tbody tr')
            .forEach(function (row) {

                row.style.display =
                    !value || row.innerText.toLowerCase().includes(value)
                        ? ''
                        : 'none';
            });
    }

    /* =========================================================
       Reset Forms
    ========================================================= */
    function resetSingleAssignForm() {

        clearTeacherChip();

        const ddlSubject =
            document.getElementById('<%= ddlSubject.ClientID %>');

    const ddlSection =
        document.getElementById('<%= ddlSection.ClientID %>');

    const ddlStream =
        document.getElementById('<%= ddlStream.ClientID %>');

        if (ddlSubject) ddlSubject.selectedIndex = 0;
        if (ddlSection) ddlSection.selectedIndex = 0;
        if (ddlStream) ddlStream.selectedIndex = 0;

        document.getElementById('errSingleTeacher').textContent = '';
        document.getElementById('errSubject').textContent = '';
        document.getElementById('errSection').textContent = '';
    }

    function resetBulkAssignForm() {

        clearBulkTeacherChip();

        const ddlSection =
            document.getElementById('<%= ddlBulkSection.ClientID %>');

        if (ddlSection) {
            ddlSection.selectedIndex = 0;
        }

        document
            .querySelectorAll('.bulk-subj-chk')
            .forEach(function (checkbox) {
                checkbox.checked = false;
            });

        document.getElementById('bulkSubjFilter').value = '';

        filterBulkSubjects('');
        updateBulkCount();

        document.getElementById('errBulkTeacher').textContent = '';
        document.getElementById('errBulkSection').textContent = '';
        document.getElementById('errBulkSubjects').textContent = '';
    }

    /* =========================================================
       Global Events
    ========================================================= */
    document.addEventListener('click', function (e) {

        const insideSearch =
            e.target.closest('.asf-search-wrap') ||
            e.target.closest('.asf-tch-dropdown');

        if (!insideSearch) {

            document
                .querySelectorAll('.asf-tch-dropdown')
                .forEach(function (dropdown) {
                    dropdown.style.display = 'none';
                });
        }
    });

    window.addEventListener('load', function () {
        restoreTeacherAfterPostback();
    });
</script>

</asp:Content>
