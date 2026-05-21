<%@ Page Title="Assign Subject Faculty" Language="C#"
    MasterPageFile="~/Admin/AdminMaster.master"
    AutoEventWireup="true"
    CodeBehind="AssignSubjectFaculty.aspx.cs"
    Inherits="LearningManagementSystem.Admin.AssignSubjectFaculty" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server" />
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

<%-- ══ HIDDEN FIELDS — all read by code-behind on postback ═══ --%>
<asp:HiddenField ID="hfTeacherId"       runat="server" Value="" />
<asp:HiddenField ID="hfSingleSubjectId" runat="server" Value="" />
<asp:HiddenField ID="hfBulkSubjectIds"  runat="server" Value="" />
<asp:HiddenField ID="hfBulkSectionId"   runat="server" Value="" />
<%-- Stores which tab was active so JS can restore it after postback --%>
<asp:HiddenField ID="hfActiveTab"       runat="server" Value="single" />

<%-- ══ TOAST ════════════════════════════════════════════════════ --%>
<div class="toast-container position-fixed p-3" style="top:70px;right:16px;z-index:9999;">
  <div id="liveToast" class="toast align-items-center border-0 shadow-lg" role="alert" aria-atomic="true">
    <div class="d-flex">
      <div class="toast-body fw-semibold" id="toastMsg" style="font-size:13px;"></div>
      <button type="button" class="btn-close me-2 m-auto" data-bs-dismiss="toast"></button>
    </div>
  </div>
</div>

<%-- ══ PAGE HEADER ════════════════════════════════════════════════ --%>
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

<%-- ══ TWO-COLUMN LAYOUT ═════════════════════════════════════════ --%>
<div class="row g-4">

  <%-- ── LEFT: Forms ──────────────────────────────────────────── --%>
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

    <%-- ════ SINGLE ASSIGN ════ --%>
    <div id="divSingle">
      <div class="card shadow-sm border-0 rounded-4">
        <div class="card-header asf-card-hdr text-white py-3">
          <h6 class="mb-0 fw-bold"><i class="fa fa-user-tag me-2"></i>Single Assignment</h6>
          <small class="opacity-75">Teacher → Subject → Section</small>
        </div>
        <div class="card-body p-4">

          <%-- Step 1: Teacher search --%>
          <div class="asf-step mb-4">
            <div class="asf-step-num">1</div>
            <div class="flex-fill">
              <label class="form-label fw-semibold small">
                Search Teacher <span class="req">*</span>
              </label>
              <div class="asf-search-wrap">
                <i class="fa fa-search asf-srch-ico"></i>
                <input type="text" id="txtSingleTeacher"
                       class="form-control asf-srch-input"
                       placeholder="Type 2+ chars to search..."
                       autocomplete="off" />
              </div>
              <%-- Dropdown rendered by JS — data-* attributes used for click selection --%>
              <div id="ddSingleTeacher" class="asf-tch-dropdown" style="display:none"></div>
              <div id="chipSingleTeacher" class="asf-tch-chip mt-2" style="display:none">
                <div class="d-flex align-items-center gap-2">
                  <div class="asf-mini-av" id="chipSingleAv"></div>
                  <div class="flex-fill">
                    <div class="fw-semibold small" id="chipSingleName"></div>
                    <div class="text-muted" style="font-size:11px" id="chipSingleDetail"></div>
                  </div>
                  <button type="button" class="btn-close"
                          onclick="clearSingleTeacher()" style="font-size:10px"></button>
                </div>
              </div>
              <div class="form-err" id="errSingleTeacher"></div>
            </div>
          </div>

          <%-- Step 2: Subject — loaded via AJAX from GetSubjectsWithDetails rendered as custom cards --%>
          <div class="asf-step mb-4">
            <div class="asf-step-num">2</div>
            <div class="flex-fill">
              <label class="form-label fw-semibold small">
                Select Subject <span class="req">*</span>
              </label>
              <div class="asf-sub-search-wrap mb-2">
                <i class="fa fa-search asf-sub-srch-ico"></i>
                <input type="text" id="txtSingleSubjSearch"
                       class="form-control asf-sub-srch-input"
                       placeholder="Filter subjects..."
                       oninput="filterSingleSubjects(this.value)" />
              </div>
              <%-- Subject list rendered by JS --%>
              <div id="singleSubjectList" class="asf-subj-list">
                <div class="text-center py-3 text-muted small">
                  <div class="spinner-border spinner-border-sm me-1"></div>
                  Loading subjects...
                </div>
              </div>
              <%-- Selected subject chip --%>
              <div id="chipSingleSubject" class="asf-subj-chip mt-2" style="display:none">
                <div class="d-flex align-items-center gap-2">
                  <i class="fa fa-book text-primary" style="font-size:14px"></i>
                  <div class="flex-fill">
                    <div class="fw-semibold small" id="chipSingleSubjectName"></div>
                    <div class="text-muted" style="font-size:11px" id="chipSingleSubjectMeta"></div>
                  </div>
                  <button type="button" class="btn-close"
                          onclick="clearSingleSubject()" style="font-size:10px"></button>
                </div>
              </div>
              <div class="form-err" id="errSingleSubject"></div>
              <div class="form-text text-muted mt-1" style="font-size:11px">
                <i class="fa fa-info-circle me-1"></i>
                Subjects shown from class assignments (Assign Level Subjects)
              </div>
            </div>
          </div>

          <%-- Step 3: Section — populated by JS when subject selected --%>
          <div class="asf-step mb-2">
            <div class="asf-step-num">3</div>
            <div class="flex-fill">
              <label class="form-label fw-semibold small">
                Select Section <span class="req">*</span>
              </label>
              <%-- ddlSection is the server control used in btnSave_Click --%>
              <asp:DropDownList ID="ddlSection" runat="server"
                CssClass="form-select asf-sel">
                <asp:ListItem Value="0" Text="-- Select Section --" />
              </asp:DropDownList>
              <div class="form-err" id="errSection"></div>
              <div class="form-text text-muted mt-1" style="font-size:11px" id="singleSectionNote"></div>
            </div>
          </div>

          <div class="alert alert-info border-0 rounded-3 py-2 px-3 mt-3 mb-0"
               style="font-size:12px">
            <i class="fa fa-info-circle me-1"></i>
            Same subject can be assigned to <strong>different sections</strong>.
            A teacher can teach <strong>multiple subjects</strong>.
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

    <%-- ════ BULK ASSIGN ════ --%>
    <div id="divBulk" style="display:none">
      <div class="card shadow-sm border-0 rounded-4">
        <div class="card-header asf-card-hdr text-white py-3">
          <h6 class="mb-0 fw-bold">
            <i class="fa fa-layer-group me-2"></i>Bulk Assignment
          </h6>
          <small class="opacity-75">Teacher → Section → Multiple Subjects</small>
        </div>
        <div class="card-body p-4">

          <%-- Step 1: Teacher --%>
          <div class="asf-step mb-4">
            <div class="asf-step-num">1</div>
            <div class="flex-fill">
              <label class="form-label fw-semibold small">
                Search Teacher <span class="req">*</span>
              </label>
              <div class="asf-search-wrap">
                <i class="fa fa-search asf-srch-ico"></i>
                <input type="text" id="txtBulkTeacher"
                       class="form-control asf-srch-input"
                       placeholder="Type 2+ chars to search..."
                       autocomplete="off" />
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
                          onclick="clearBulkTeacher()" style="font-size:10px"></button>
                </div>
              </div>
              <div class="form-err" id="errBulkTeacher"></div>
            </div>
          </div>

          <%-- Step 2: Section — pure client-side select, NO AutoPostBack
               Value is stored in hfBulkSectionId hidden field before postback --%>
          <div class="asf-step mb-4">
            <div class="asf-step-num">2</div>
            <div class="flex-fill">
              <label class="form-label fw-semibold small">
                Select Section <span class="req">*</span>
              </label>
              <%-- ddlBulkSection has NO AutoPostBack — change handled in JS --%>
              <asp:DropDownList ID="ddlBulkSection" runat="server"
                CssClass="form-select asf-sel"
                onchange="onBulkSectionChange(this.value)">
                <asp:ListItem Value="0" Text="-- Select Section --" />
              </asp:DropDownList>
              <div class="form-err" id="errBulkSection"></div>
              <div class="form-text text-muted mt-1" style="font-size:11px">
                <i class="fa fa-info-circle me-1"></i>
                Subjects below update when you choose a section
              </div>
            </div>
          </div>

          <%-- Step 3: Subjects — rendered by JS via AJAX, no Repeater/postback --%>
          <div class="asf-step mb-2">
            <div class="asf-step-num">3</div>
            <div class="flex-fill">
              <div class="d-flex align-items-center justify-content-between mb-2">
                <label class="form-label fw-semibold small mb-0">
                  Select Subjects <span class="req">*</span>
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
                           id="chkBulkAll" onchange="toggleAllBulk(this)" />
                    <label class="form-check-label small" for="chkBulkAll">All</label>
                  </div>
                </div>
              </div>

              <%-- Subject checklist rendered by JS into this container --%>
              <div id="bulkSubjectList" class="asf-bulk-list">
                <div class="text-center py-4 text-muted small" id="bulkSubjPlaceholder">
                  <i class="fa fa-arrow-up fa-lg d-block mb-2 opacity-25"></i>
                  Select a section above to load subjects
                </div>
              </div>

              <div id="bulkCountBox" class="mt-2 text-muted small" style="display:none">
                <i class="fa fa-check-circle text-success me-1"></i>
                <span id="bulkCount">0</span> subject(s) selected
              </div>
              <div class="form-err" id="errBulkSubjects"></div>
            </div>
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

  </div><%-- /col-lg-5 --%>

  <%-- ── RIGHT: Tracker + Workload ────────────────────────────── --%>
  <div class="col-12 col-lg-7">

    <%-- Tracker filters --%>
    <div class="d-flex align-items-center gap-2 flex-wrap mb-3">
      <span class="fw-semibold small text-muted me-auto">
        <i class="fa fa-clipboard-list me-1"></i>Assignment Tracker
      </span>
      <div class="asf-trk-srch-wrap">
        <i class="fa fa-search asf-trk-ico"></i>
        <input type="text" id="trackerSearch" class="form-control asf-trk-input"
               placeholder="Search..." onkeyup="filterTracker(this.value)" />
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

    <%-- Tracker Grid --%>
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
                <span class="text-muted small"><%# Container.DataItemIndex + 1 %></span>
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
                    <div class="fw-semibold small"><%# Eval("TeacherName") %></div>
                    <div class="text-muted" style="font-size:11px"><%# Eval("EmployeeId") %></div>
                  </div>
                </div>
              </ItemTemplate>
            </asp:TemplateField>

            <asp:TemplateField HeaderText="Subject / Class">
              <ItemTemplate>
                <div class="fw-semibold small"><%# Eval("SubjectName") %></div>
                <div class="d-flex flex-wrap gap-1 mt-1">
                  <span class="badge-code"><%# Eval("SubjectCode") %></span>
                  <%# !string.IsNullOrEmpty(Eval("StreamName").ToString()) && Eval("StreamName").ToString() != "—"
                      ? "<span class='acad-tag tag-stream'>" + Eval("StreamName") + "</span>" : "" %>
                  <%# !string.IsNullOrEmpty(Eval("CourseName").ToString())
                      ? "<span class='acad-tag tag-course'>" + Eval("CourseName") + "</span>" : "" %>
                  <%# !string.IsNullOrEmpty(Eval("LevelName").ToString())
                      ? "<span class='acad-tag tag-level'>" + Eval("LevelName") + "</span>" : "" %>
                  <%# !string.IsNullOrEmpty(Eval("SemesterName").ToString())
                      ? "<span class='acad-tag tag-sem'>" + Eval("SemesterName") + "</span>" : "" %>
                </div>
              </ItemTemplate>
            </asp:TemplateField>

            <asp:TemplateField HeaderText="Section" ItemStyle-Width="70px">
              <ItemTemplate>
                <span class="acad-tag tag-sec"><%# Eval("SectionName") %></span>
              </ItemTemplate>
            </asp:TemplateField>

            <asp:TemplateField HeaderText="Status" ItemStyle-Width="80px">
              <ItemTemplate>
                <%# Convert.ToBoolean(Eval("IsActive"))
                    ? "<span class='badge bg-success bg-opacity-15 text-success rounded-pill px-2 py-1' style='font-size:10px'>Active</span>"
                    : "<span class='badge bg-secondary bg-opacity-15 text-secondary rounded-pill px-2 py-1' style='font-size:10px'>Inactive</span>" %>
              </ItemTemplate>
            </asp:TemplateField>

            <asp:TemplateField HeaderText="" ItemStyle-Width="65px"
                               ItemStyle-CssClass="text-center">
              <ItemTemplate>
                <div class="d-flex gap-1 justify-content-center">
                  <asp:LinkButton runat="server"
                    CommandName="Toggle"
                    CommandArgument='<%# Eval("SubjectFacultyId") %>'
                    CssClass="asf-act-btn act-tog"
                    title="Toggle Active/Inactive"
                    OnClientClick="return confirm('Toggle this assignment status?');">
                    <i class="fa fa-power-off"></i>
                  </asp:LinkButton>
                  <asp:LinkButton runat="server"
                    CommandName="DeleteRow"
                    CommandArgument='<%# Eval("SubjectFacultyId") %>'
                    CssClass="asf-act-btn act-del"
                    title="Remove assignment"
                    OnClientClick="return confirm('Remove this assignment?\nPrefer Deactivate if attendance records exist.');">
                    <i class="fa fa-times"></i>
                  </asp:LinkButton>
                </div>
              </ItemTemplate>
            </asp:TemplateField>

          </Columns>
        </asp:GridView>
      </div>
    </div>

    <%-- Tracker pager — LinkButtons added dynamically in code-behind --%>
    <div class="d-flex justify-content-center mt-3">
      <asp:Panel ID="pnlPager" runat="server"
        CssClass="d-flex align-items-center gap-1 flex-wrap justify-content-center" />
    </div>

    <%-- Workload Summary --%>
    <div class="card shadow-sm border-0 rounded-4 mt-4">
      <div class="card-header bg-transparent border-bottom py-3 px-4">
        <span class="fw-semibold small">
          <i class="fa fa-chart-bar me-1 text-primary"></i>
          Teacher Workload Summary (Active)
        </span>
      </div>
      <div class="table-responsive" style="max-height:280px;overflow-y:auto">
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
      </div>
      <div class="d-flex justify-content-center py-2">
        <asp:Panel ID="pnlWorkloadPager" runat="server"
          CssClass="d-flex align-items-center gap-1 flex-wrap justify-content-center" />
      </div>
    </div>

  </div><%-- /col-lg-7 --%>
</div><%-- /row --%>

<%-- ══ STYLES ══════════════════════════════════════════════════════ --%>
<style>
:root { --pri:#4f46e5; --pri-lt:#eef2ff; }

/* Header */
.asf-hdr-icon { width:36px;height:36px;border-radius:10px;background:var(--pri-lt);
  color:var(--pri);display:inline-flex;align-items:center;justify-content:center; }
.dot-sep { width:5px;height:5px;background:#cbd5e1;border-radius:50%;display:inline-block; }
.req { color:#dc2626; }
.form-err { color:#dc2626;font-size:11px;margin-top:3px;min-height:14px; }

/* Stat cards */
.asf-stat { background:#fff;min-width:90px;transition:transform .2s; }
.asf-stat:hover { transform:translateY(-2px); }
.asf-stat-lbl { font-size:10px;text-transform:uppercase;letter-spacing:.4px;color:#94a3b8; }

/* Card header */
.asf-card-hdr { background:linear-gradient(135deg,#4f46e5,#6366f1);
  border-radius:16px 16px 0 0!important; }

/* Steps */
.asf-step { display:flex;gap:12px;align-items:flex-start; }
.asf-step-num { width:24px;height:24px;border-radius:50%;background:var(--pri);color:#fff;
  font-size:11px;font-weight:700;display:flex;align-items:center;justify-content:center;
  flex-shrink:0;margin-top:2px; }

/* Tabs */
.asf-tabs { display:flex;gap:4px;border-bottom:2px solid #f1f5f9; }
.asf-tab { padding:8px 16px;font-size:13px;font-weight:500;color:#64748b;border:none;
  background:none;border-bottom:2px solid transparent;margin-bottom:-2px;
  border-radius:8px 8px 0 0;cursor:pointer;transition:.15s; }
.asf-tab:hover { color:var(--pri);background:#f8fafc; }
.asf-tab.active { color:var(--pri);border-bottom-color:var(--pri);background:#fff; }

/* Select */
.asf-sel { font-size:13px;border-radius:8px; }
.asf-sel:focus { border-color:var(--pri);box-shadow:0 0 0 3px rgba(79,70,229,.15); }

/* Teacher search */
.asf-search-wrap { position:relative; }
.asf-srch-ico { position:absolute;top:50%;left:10px;transform:translateY(-50%);
  color:#94a3b8;font-size:12px;z-index:2;pointer-events:none; }
.asf-srch-input { padding-left:32px;border-radius:8px;font-size:13px; }
.asf-srch-input:focus { border-color:var(--pri);box-shadow:0 0 0 3px rgba(79,70,229,.15); }

/* Teacher dropdown */
.asf-tch-dropdown { position:absolute;z-index:99999;left:0;right:0;background:#fff;
  border:1px solid #e2e8f0;border-radius:10px;
  box-shadow:0 8px 24px rgba(0,0,0,.12);max-height:230px;overflow-y:auto; }
.asf-tch-item { padding:10px 14px;display:flex;align-items:center;gap:10px;
  border-bottom:1px solid #f1f5f9;font-size:13px;transition:background .15s;
  cursor:pointer;user-select:none; }
.asf-tch-item:last-child { border-bottom:none; }
.asf-tch-item:hover { background:#f0f4ff; }
.asf-mini-av { width:32px;height:32px;border-radius:50%;display:flex;align-items:center;
  justify-content:center;font-weight:700;font-size:11px;color:#fff;flex-shrink:0; }
.asf-tch-chip { background:#eef2ff;border:1px solid #c7d2fe;border-radius:10px;
  padding:8px 12px; }

/* Subject search (single) */
.asf-sub-search-wrap { position:relative; }
.asf-sub-srch-ico { position:absolute;top:50%;left:10px;transform:translateY(-50%);
  color:#94a3b8;font-size:12px;z-index:2;pointer-events:none; }
.asf-sub-srch-input { padding-left:32px;border-radius:8px;font-size:12px;height:34px; }
.asf-sub-srch-input:focus { border-color:var(--pri);box-shadow:0 0 0 3px rgba(79,70,229,.12); }

/* Subject list (single) */
.asf-subj-list { max-height:240px;overflow-y:auto;border:1px solid #e2e8f0;
  border-radius:10px;background:#fafafa; }
.asf-subj-item { display:flex;align-items:flex-start;gap:10px;padding:9px 12px;
  border-bottom:1px solid #f1f5f9;cursor:pointer;transition:background .12s;
  user-select:none; }
.asf-subj-item:last-child { border-bottom:none; }
.asf-subj-item:hover { background:#f0f4ff; }
.asf-subj-item.selected { background:#eef2ff;border-left:3px solid var(--pri); }
.asf-subj-chip { background:#eef2ff;border:1px solid #c7d2fe;border-radius:10px;
  padding:8px 12px; }

/* Bulk subjects */
.asf-bulk-list { max-height:270px;overflow-y:auto;border:1px solid #e2e8f0;
  border-radius:10px;background:#fafafa; }
.asf-bulk-item { border-bottom:1px solid #f1f5f9; }
.asf-bulk-item:last-child { border-bottom:none; }
.asf-bulk-item:hover { background:#f1f5f9; }
.asf-bulk-lbl { display:flex;align-items:flex-start;padding:9px 12px;
  cursor:pointer;margin:0;gap:8px; }
.asf-bulk-srch-wrap { position:relative; }
.asf-bsrch-ico { position:absolute;top:50%;left:8px;transform:translateY(-50%);
  color:#94a3b8;font-size:11px;pointer-events:none; }
.asf-bsrch-input { padding-left:26px;height:28px;font-size:12px;border-radius:7px;width:120px; }

/* Academic tags */
.acad-tag { display:inline-block;padding:1px 6px;border-radius:5px;font-size:10px;
  font-weight:600;white-space:nowrap; }
.tag-stream { background:#eef2ff;color:#4f46e5; }
.tag-course { background:#e0f2fe;color:#0369a1; }
.tag-level  { background:#f0fdf4;color:#15803d; }
.tag-sem    { background:#fef9c3;color:#92400e; }
.tag-sec    { background:#f0fdf4;color:#15803d; }
.badge-code { background:#f1f5f9;color:#475569;font-size:10px;font-weight:600;
  padding:1px 7px;border-radius:5px;font-family:monospace; }

/* Table */
.asf-tbl-hdr th { background:linear-gradient(135deg,#4f46e5,#6366f1)!important;
  color:#fff!important;border:none!important;padding:11px 12px!important;
  font-weight:600;font-size:12px;white-space:nowrap; }
.modern-table td { padding:9px 12px;font-size:13px;
  border-bottom:1px solid #f1f5f9!important;vertical-align:middle; }
.asf-tbl-av { width:30px;height:30px;border-radius:50%;display:flex;align-items:center;
  justify-content:center;font-weight:700;font-size:11px;color:#fff;flex-shrink:0; }
.asf-act-btn { width:26px;height:26px;border-radius:6px;border:none;display:inline-flex;
  align-items:center;justify-content:center;font-size:11px;cursor:pointer;
  transition:transform .15s;text-decoration:none; }
.asf-act-btn:hover { transform:scale(1.12); }
.act-tog { background:#fef9c3;color:#92400e; }
.act-del { background:#fee2e2;color:#b91c1c; }

/* Tracker search */
.asf-trk-srch-wrap { position:relative; }
.asf-trk-ico { position:absolute;top:50%;left:8px;transform:translateY(-50%);
  color:#94a3b8;font-size:11px;pointer-events:none; }
.asf-trk-input { padding-left:26px;height:30px;font-size:12px;border-radius:7px;width:140px; }
.asf-trk-sel   { height:30px;font-size:12px;border-radius:7px;padding:0 6px;min-width:110px; }

/* Workload bar */
.asf-load-wrap { height:6px;background:#e2e8f0;border-radius:3px;margin-bottom:2px;overflow:hidden; }
.asf-load-bar  { height:100%;border-radius:3px;transition:width .4s; }

/* Pager */
.asf-page-btn { display:inline-flex;align-items:center;justify-content:center;
  min-width:32px;height:32px;padding:0 8px;border-radius:8px;border:1px solid #e2e8f0;
  background:#fff;font-size:13px;color:#475569;text-decoration:none;
  transition:.15s;line-height:1;cursor:pointer; }
.asf-page-btn:hover { background:var(--pri);color:#fff;border-color:var(--pri); }
.asf-page-btn.active { background:var(--pri);color:#fff;border-color:var(--pri);font-weight:700; }
.asf-page-btn.disabled,.asf-page-btn[disabled] { opacity:.4;pointer-events:none; }

/* Toast */
.toast { min-width:280px;border-radius:12px!important; }
.toast.bg-success { background:#16a34a!important;color:#fff!important; }
.toast.bg-danger  { background:#dc2626!important;color:#fff!important; }
.toast.bg-warning { background:#d97706!important;color:#fff!important; }
.toast.bg-info    { background:#0891b2!important;color:#fff!important; }
.form-label { font-size:13px;margin-bottom:4px; }

@media(max-width:767px) {
  .asf-trk-input { width:100px; }
  .asf-trk-sel   { min-width:90px; }
  .asf-tab       { padding:6px 10px;font-size:12px; }
}
</style>

<%-- ══ SCRIPTS ═════════════════════════════════════════════════════ --%>
<script>
(function () {
'use strict';

/* ── Server-injected constants ───────────────────────────────── */
var INST     = '<%= InstituteId %>';
var SESS     = '<%= SessionId %>';
var IS_SUPER = '<%= Session["Role"]?.ToString() %>' === 'SuperAdmin';

/* Hidden field element references */
var hfTeacherId       = document.getElementById('<%= hfTeacherId.ClientID %>');
var hfSingleSubjectId = document.getElementById('<%= hfSingleSubjectId.ClientID %>');
var hfBulkSubjectIds  = document.getElementById('<%= hfBulkSubjectIds.ClientID %>');
var hfBulkSectionId   = document.getElementById('<%= hfBulkSectionId.ClientID %>');
var hfActiveTab       = document.getElementById('<%= hfActiveTab.ClientID %>');

var ddlSection        = document.getElementById('<%= ddlSection.ClientID %>');
var ddlBulkSection    = document.getElementById('<%= ddlBulkSection.ClientID %>');

var COLORS = ['#4f46e5','#0891b2','#059669','#d97706','#dc2626','#7c3aed','#db2777','#0d9488'];

/* ── Toast ───────────────────────────────────────────────────── */
function showToast(msg, type) {
  var icons = {success:'check-circle',danger:'times-circle',warning:'exclamation-triangle',info:'info-circle'};
  var t = document.getElementById('liveToast');
  var m = document.getElementById('toastMsg');
  m.innerHTML = '<i class="fa fa-'+(icons[type]||'info-circle')+' me-2"></i>'+msg;
  t.className = 'toast align-items-center border-0 shadow-lg text-white bg-'+(type||'success');
  bootstrap.Toast.getOrCreateInstance(t,{delay:5000}).show();
}
window.serverToast = function(msg,type){ showToast(msg,type); };

/* ── Avatar helpers ──────────────────────────────────────────── */
function avatarColor(text) {
  if (!text) return COLORS[0];
  var h = 0;
  for (var i = 0; i < text.length; i++) h = (Math.imul(31, h) + text.charCodeAt(i)) | 0;
  return COLORS[Math.abs(h) % COLORS.length];
}
function initials(name) {
  if (!name) return '?';
  var p = name.trim().split(/\s+/);
  return p.length === 1 ? p[0].substring(0,2).toUpperCase()
                        : (p[0][0]+p[p.length-1][0]).toUpperCase();
}

/* ── Tab switching ───────────────────────────────────────────── */
window.switchTab = function(tab) {
  var isSingle = (tab === 'single');
  document.getElementById('divSingle').style.display   = isSingle ? '' : 'none';
  document.getElementById('divBulk').style.display     = isSingle ? 'none' : '';
  document.getElementById('tabSingleBtn').classList.toggle('active', isSingle);
  document.getElementById('tabBulkBtn').classList.toggle('active', !isSingle);
  if (hfActiveTab) hfActiveTab.value = tab;   // persists through postback
};

/* Restore active tab after postback using hfActiveTab value */
function restoreTab() {
  var tab = hfActiveTab ? hfActiveTab.value : 'single';
  switchTab(tab || 'single');
}

/* ═════════════════════════════════════════════════════════════
   TEACHER SEARCH — pure JS, no postback
   Uses event delegation on the dropdown div so clicks register
   even on dynamically created children.
   ═════════════════════════════════════════════════════════════ */
var _searchTimer = null;
var _currentMode = 'single';   // which search box is active

function wireTeacherSearch(inputId, dropdownId, mode) {
  var input = document.getElementById(inputId);
  var dd    = document.getElementById(dropdownId);

  input.addEventListener('input', function () {
    clearTimeout(_searchTimer);
    var val = this.value.trim();
    if (val.length < 2) { dd.style.display = 'none'; return; }
    _currentMode = mode;
    _searchTimer = setTimeout(function () { fetchTeachers(val, mode); }, 280);
  });

  input.addEventListener('focus', function() {
    if (this.value.trim().length >= 2) dd.style.display = 'block';
  });

  /* ★ KEY FIX: event delegation — click on any child of the dropdown --%>
     fires this handler. Never use onclick="" in the generated HTML. */
  dd.addEventListener('mousedown', function(e) {
    var item = e.target.closest('.asf-tch-item[data-uid]');
    if (!item) return;
    e.preventDefault();   // prevent blur before click
    selectTeacher(
      item.getAttribute('data-uid'),
      item.getAttribute('data-name'),
      item.getAttribute('data-emp'),
      item.getAttribute('data-stream'),
      mode
    );
  });
}

function fetchTeachers(term, mode) {
  fetch('AssignSubjectFaculty.aspx/SearchTeachers', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json; charset=utf-8' },
    body: JSON.stringify({ prefix: term, instituteId: INST, sessionId: SESS })
  })
  .then(function(r){ return r.ok ? r.json() : Promise.reject(r.status); })
  .then(function(d){ renderTeacherDropdown(d.d||[], mode); })
  .catch(function(){
    var dd = document.getElementById(mode==='single'?'ddSingleTeacher':'ddBulkTeacher');
    dd.innerHTML = '<div class="asf-tch-item text-danger">Search failed. Try again.</div>';
    dd.style.display = 'block';
  });
}

function renderTeacherDropdown(items, mode) {
  var dd = document.getElementById(mode==='single'?'ddSingleTeacher':'ddBulkTeacher');
  if (!items.length) {
    dd.innerHTML = '<div class="asf-tch-item text-muted">No teachers found</div>';
    dd.style.display = 'block';
    return;
  }
  /* Use data-* attributes — NO inline onclick — so event delegation works */
  dd.innerHTML = items.map(function(t) {
    var fn  = (t.FullName   || '').replace(/"/g,'&quot;');
    var emp = (t.EmployeeId || '').replace(/"/g,'&quot;');
    var str = (t.StreamName || '').replace(/"/g,'&quot;');
    var uid = (t.UserId     || '');
    var col = avatarColor(t.FullName);
    var ini = initials(t.FullName);
    return '<div class="asf-tch-item" data-uid="'+uid+'" data-name="'+fn
          +'" data-emp="'+emp+'" data-stream="'+str+'">'
          +'<div class="asf-mini-av" style="background:'+col+'">'+ini+'</div>'
          +'<div>'
          +'<div class="fw-semibold" style="font-size:13px">'+fn+'</div>'
          +'<div class="text-muted" style="font-size:11px">'+emp+(str&&str!=='—'?' · '+str:'')+'</div>'
          +'</div></div>';
  }).join('');
  dd.style.display = 'block';
}

function selectTeacher(uid, name, emp, stream, mode) {
  /* Write to server hidden field so btnSave_Click can read it */
  hfTeacherId.value = uid;

  var dd = document.getElementById(mode==='single'?'ddSingleTeacher':'ddBulkTeacher');
  dd.style.display = 'none';

  var col = avatarColor(name);
  var ini = initials(name);
  var detail = emp + (stream && stream!=='—' ? ' · '+stream : '');

  if (mode === 'single') {
    document.getElementById('txtSingleTeacher').value = name;
    document.getElementById('chipSingleAv').textContent   = ini;
    document.getElementById('chipSingleAv').style.background = col;
    document.getElementById('chipSingleName').textContent   = name;
    document.getElementById('chipSingleDetail').textContent = detail;
    document.getElementById('chipSingleTeacher').style.display = 'block';
    document.getElementById('errSingleTeacher').textContent = '';
  } else {
    document.getElementById('txtBulkTeacher').value = name;
    document.getElementById('chipBulkAv').textContent   = ini;
    document.getElementById('chipBulkAv').style.background = col;
    document.getElementById('chipBulkName').textContent   = name;
    document.getElementById('chipBulkDetail').textContent = detail;
    document.getElementById('chipBulkTeacher').style.display = 'block';
    document.getElementById('errBulkTeacher').textContent = '';
  }
}

window.clearSingleTeacher = function() {
  hfTeacherId.value = '';
  document.getElementById('txtSingleTeacher').value = '';
  document.getElementById('chipSingleTeacher').style.display = 'none';
};
window.clearBulkTeacher = function() {
  hfTeacherId.value = '';
  document.getElementById('txtBulkTeacher').value = '';
  document.getElementById('chipBulkTeacher').style.display = 'none';
};

/* Close dropdowns on outside click */
document.addEventListener('click', function(e) {
  if (!e.target.closest('.asf-search-wrap') && !e.target.closest('.asf-tch-dropdown'))
    document.querySelectorAll('.asf-tch-dropdown').forEach(function(d){ d.style.display='none'; });
});

/* ═════════════════════════════════════════════════════════════
   SINGLE ASSIGN — Subject list (AJAX, no postback)
   ═════════════════════════════════════════════════════════════ */
var _allSingleSubjects = [];   // cache
var _selectedSubjectId  = '';

function loadSingleSubjects() {
  var list = document.getElementById('singleSubjectList');
  list.innerHTML = '<div class="text-center py-3 text-muted small">'
    +'<div class="spinner-border spinner-border-sm me-1"></div>Loading subjects...</div>';

  fetch('AssignSubjectFaculty.aspx/GetSubjectsForSection', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json; charset=utf-8' },
    body: JSON.stringify({ sectionId: '0', instituteId: INST, sessionId: SESS })
  })
  .then(function(r){ return r.ok ? r.json() : Promise.reject(r.status); })
  .then(function(d){
    _allSingleSubjects = d.d || [];
    renderSingleSubjects(_allSingleSubjects);
  })
  .catch(function(){
    document.getElementById('singleSubjectList').innerHTML =
      '<div class="text-center py-3 text-danger small">Failed to load subjects.</div>';
  });
}

function renderSingleSubjects(items) {
  var list = document.getElementById('singleSubjectList');
  if (!items.length) {
    list.innerHTML = '<div class="text-center py-3 text-muted small">'
      +'<i class="fa fa-book fa-2x d-block mb-2 opacity-25"></i>'
      +'No subjects found. Assign subjects to classes first.</div>';
    return;
  }
  list.innerHTML = items.map(function(s) {
    var meta = buildMeta(s);
    var isSelected = (s.SubjectId === _selectedSubjectId);
    return '<div class="asf-subj-item'+(isSelected?' selected':'')+'"'
      +' data-id="'+s.SubjectId+'" data-name="'+escAttr(s.SubjectName)+'"'
      +' data-meta="'+escAttr(meta)+'">'
      +'<div class="flex-fill">'
      +'<div class="fw-semibold small">'+esc(s.SubjectName)+'</div>'
      +'<div class="d-flex flex-wrap gap-1 mt-1">'
      +(s.SubjectCode ? '<span class="badge-code">'+esc(s.SubjectCode)+'</span>' : '')
      +(s.StreamName  ? '<span class="acad-tag tag-stream">'+esc(s.StreamName)+'</span>' : '')
      +(s.CourseName  ? '<span class="acad-tag tag-course">'+esc(s.CourseName)+'</span>' : '')
      +(s.LevelName   ? '<span class="acad-tag tag-level">'+esc(s.LevelName)+'</span>'   : '')
      +(s.SemesterName? '<span class="acad-tag tag-sem">'+esc(s.SemesterName)+'</span>'  : '')
      +(s.IsMandatory==='True'||s.IsMandatory===true
        ? '<span class="badge bg-danger bg-opacity-15 text-danger rounded-pill" style="font-size:9px">Mandatory</span>'
        : '<span class="badge bg-info bg-opacity-15 text-info rounded-pill" style="font-size:9px">Elective</span>')
      +'</div></div></div>';
  }).join('');

  /* Event delegation — click anywhere on item row to select */
  list.addEventListener('click', function(e) {
    var item = e.target.closest('.asf-subj-item[data-id]');
    if (!item) return;
    selectSingleSubject(item.getAttribute('data-id'),
                        item.getAttribute('data-name'),
                        item.getAttribute('data-meta'));
  });
}

function selectSingleSubject(id, name, meta) {
  _selectedSubjectId    = id;
  hfSingleSubjectId.value = id;

  /* Highlight selected row */
  document.querySelectorAll('#singleSubjectList .asf-subj-item').forEach(function(el) {
    el.classList.toggle('selected', el.getAttribute('data-id') === id);
  });

  /* Show chip */
  document.getElementById('chipSingleSubjectName').textContent = name;
  document.getElementById('chipSingleSubjectMeta').textContent = meta;
  document.getElementById('chipSingleSubject').style.display   = 'block';
  document.getElementById('errSingleSubject').textContent      = '';

  /* Load valid sections for this subject via AJAX */
  loadSectionsForSubject(id);
}

window.clearSingleSubject = function() {
  _selectedSubjectId    = '';
  hfSingleSubjectId.value = '';
  document.getElementById('chipSingleSubject').style.display = 'none';
  document.querySelectorAll('#singleSubjectList .asf-subj-item')
          .forEach(function(el){ el.classList.remove('selected'); });
  resetSectionDropdown(ddlSection, '-- Select Section --');
  document.getElementById('singleSectionNote').textContent = '';
};

window.filterSingleSubjects = function(val) {
  val = (val||'').toLowerCase().trim();
  var filtered = !val ? _allSingleSubjects
    : _allSingleSubjects.filter(function(s) {
        return (s.SubjectName+' '+s.SubjectCode+' '+s.StreamName+' '
               +s.CourseName+' '+s.LevelName+' '+s.SemesterName)
               .toLowerCase().includes(val);
      });
  renderSingleSubjects(filtered);
};

/* Load sections valid for a subject (single assign) */
function loadSectionsForSubject(subjectId) {
  resetSectionDropdown(ddlSection, 'Loading sections...');
  document.getElementById('singleSectionNote').textContent = '';

  fetch('AssignSubjectFaculty.aspx/GetSectionsForSubject', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json; charset=utf-8' },
    body: JSON.stringify({ subjectId: subjectId, instituteId: INST, sessionId: SESS })
  })
  .then(function(r){ return r.ok ? r.json() : Promise.reject(r.status); })
  .then(function(d){
    var secs = d.d || [];
    populateDropdown(ddlSection, secs, 'SectionId', 'SectionName', '-- Select Section --');
    if (secs.length === 0) {
      document.getElementById('singleSectionNote').textContent =
        'No sections found for this subject — showing all sections.';
    } else {
      document.getElementById('singleSectionNote').textContent =
        secs.length + ' valid section(s) for this subject.';
    }
  })
  .catch(function(){ resetSectionDropdown(ddlSection, '-- Select Section --'); });
}

/* ═════════════════════════════════════════════════════════════
   BULK ASSIGN — Section change handled client-side (NO postback)
   ═════════════════════════════════════════════════════════════ */
window.onBulkSectionChange = function(sectionId) {
  hfBulkSectionId.value = sectionId;   // write to hidden field for code-behind
  document.getElementById('errBulkSection').textContent = '';

  if (!sectionId || sectionId === '0') {
    document.getElementById('bulkSubjectList').innerHTML =
      '<div class="text-center py-4 text-muted small" id="bulkSubjPlaceholder">'
      +'<i class="fa fa-arrow-up fa-lg d-block mb-2 opacity-25"></i>'
      +'Select a section above to load subjects</div>';
    updateBulkCount();
    return;
  }
  loadBulkSubjects(sectionId);
};

function loadBulkSubjects(sectionId) {
  var list = document.getElementById('bulkSubjectList');
  list.innerHTML = '<div class="text-center py-3 text-muted small">'
    +'<div class="spinner-border spinner-border-sm me-1"></div>Loading subjects...</div>';

  fetch('AssignSubjectFaculty.aspx/GetSubjectsForSection', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json; charset=utf-8' },
    body: JSON.stringify({ sectionId: sectionId, instituteId: INST, sessionId: SESS })
  })
  .then(function(r){ return r.ok ? r.json() : Promise.reject(r.status); })
  .then(function(d){ renderBulkSubjects(d.d||[]); })
  .catch(function(){
    list.innerHTML = '<div class="text-center py-3 text-danger small">Failed to load subjects.</div>';
  });
}

function renderBulkSubjects(items) {
  var list = document.getElementById('bulkSubjectList');
  if (!items.length) {
    list.innerHTML = '<div class="text-center py-4 text-muted small">'
      +'<i class="fa fa-book fa-2x d-block mb-2 opacity-25"></i>'
      +'No subjects found for this section.</div>';
    updateBulkCount();
    return;
  }
  list.innerHTML = items.map(function(s) {
    return '<div class="asf-bulk-item"'
      +' data-s="'+(s.SubjectName+' '+s.SubjectCode+' '+s.StreamName
                    +' '+s.CourseName+' '+s.LevelName).toLowerCase()+'">'
      +'<label class="asf-bulk-lbl w-100">'
      +'<input type="checkbox" class="form-check-input bulk-subj-chk flex-shrink-0"'
      +' value="'+s.SubjectId+'" onchange="updateBulkCount()" />'
      +'<div class="flex-fill">'
      +'<div class="fw-semibold small">'+esc(s.SubjectName)+'</div>'
      +'<div class="d-flex flex-wrap gap-1 mt-1">'
      +(s.SubjectCode ? '<span class="badge-code">'+esc(s.SubjectCode)+'</span>' : '')
      +(s.StreamName  ? '<span class="acad-tag tag-stream">'+esc(s.StreamName)+'</span>' : '')
      +(s.CourseName  ? '<span class="acad-tag tag-course">'+esc(s.CourseName)+'</span>' : '')
      +(s.LevelName   ? '<span class="acad-tag tag-level">'+esc(s.LevelName)+'</span>'   : '')
      +(s.SemesterName? '<span class="acad-tag tag-sem">'+esc(s.SemesterName)+'</span>'  : '')
      +(s.IsMandatory==='True'||s.IsMandatory===true
        ? '<span class="badge bg-danger bg-opacity-15 text-danger rounded-pill" style="font-size:9px">Mandatory</span>'
        : '<span class="badge bg-info bg-opacity-15 text-info rounded-pill" style="font-size:9px">Elective</span>')
      +'</div></div></label></div>';
  }).join('');
  updateBulkCount();
}

window.toggleAllBulk = function(chk) {
  document.querySelectorAll('.bulk-subj-chk').forEach(function(c) {
    var row = c.closest('.asf-bulk-item');
    if (!row || row.style.display !== 'none') c.checked = chk.checked;
  });
  updateBulkCount();
};

window.updateBulkCount = function() {
  var n = document.querySelectorAll('.bulk-subj-chk:checked').length;
  document.getElementById('bulkCount').textContent = n;
  document.getElementById('bulkCountBox').style.display = n > 0 ? '' : 'none';
};

window.filterBulkSubjects = function(val) {
  val = (val||'').toLowerCase().trim();
  document.querySelectorAll('#bulkSubjectList .asf-bulk-item').forEach(function(item) {
    item.style.display = (!val || (item.dataset.s||'').includes(val)) ? '' : 'none';
  });
};

/* ═════════════════════════════════════════════════════════════
   VALIDATION — writes hidden fields right before postback
   ═════════════════════════════════════════════════════════════ */
window.validateSingle = function() {
  if (IS_SUPER) { showToast('SuperAdmin has view-only access.','warning'); return false; }
  var ok = true;

  if (!hfTeacherId.value) {
    document.getElementById('errSingleTeacher').textContent = 'Please select a teacher.';
    ok = false;
  } else document.getElementById('errSingleTeacher').textContent = '';

  if (!hfSingleSubjectId.value) {
    document.getElementById('errSingleSubject').textContent = 'Please select a subject.';
    ok = false;
  } else document.getElementById('errSingleSubject').textContent = '';

  if (!ddlSection.value || ddlSection.value === '0') {
    document.getElementById('errSection').textContent = 'Please select a section.';
    ok = false;
  } else document.getElementById('errSection').textContent = '';

  if (!ok) showToast('Please fill all required fields.','warning');
  return ok;
};

window.validateBulk = function() {
  if (IS_SUPER) { showToast('SuperAdmin has view-only access.','warning'); return false; }
  var ok = true;

  if (!hfTeacherId.value) {
    document.getElementById('errBulkTeacher').textContent = 'Please select a teacher.';
    ok = false;
  } else document.getElementById('errBulkTeacher').textContent = '';

  var secVal = ddlBulkSection.value;
  if (!secVal || secVal === '0') {
    document.getElementById('errBulkSection').textContent = 'Please select a section.';
    ok = false;
  } else {
    hfBulkSectionId.value = secVal;   // ensure written
    document.getElementById('errBulkSection').textContent = '';
  }

  var checked = Array.from(document.querySelectorAll('.bulk-subj-chk:checked'))
                     .map(function(c){ return c.value; });
  if (checked.length === 0) {
    document.getElementById('errBulkSubjects').textContent = 'Select at least one subject.';
    ok = false;
  } else {
    hfBulkSubjectIds.value = checked.join(',');
    document.getElementById('errBulkSubjects').textContent = '';
  }

  if (!ok) showToast('Please fix errors before saving.','warning');
  return ok;
};

/* ═════════════════════════════════════════════════════════════
   POST-SAVE CALLBACKS (called by ScriptManager from code-behind)
   ═════════════════════════════════════════════════════════════ */
window.afterSingleSave = function() {
  clearSingleTeacher();
  clearSingleSubject();
  resetSectionDropdown(ddlSection, '-- Select Section --');
  document.getElementById('txtSingleSubjSearch').value = '';
  filterSingleSubjects('');
  switchTab('single');
};

window.afterBulkSave = function() {
  clearBulkTeacher();
  ddlBulkSection.value = '0';
  hfBulkSectionId.value = '';
  document.getElementById('bulkSubjectList').innerHTML =
    '<div class="text-center py-4 text-muted small">'
    +'<i class="fa fa-arrow-up fa-lg d-block mb-2 opacity-25"></i>'
    +'Select a section above to load subjects</div>';
  document.getElementById('bulkSubjFilter').value = '';
  document.getElementById('chkBulkAll').checked = false;
  updateBulkCount();
  switchTab('bulk');
};

/* ═════════════════════════════════════════════════════════════
   TRACKER SEARCH
   ═════════════════════════════════════════════════════════════ */
window.filterTracker = function(val) {
  val = (val||'').toLowerCase().trim();
  document.querySelectorAll('#<%= gvAssign.ClientID %> tbody tr').forEach(function (r) {
                r.style.display = (!val || r.innerText.toLowerCase().includes(val)) ? '' : 'none';
            });
        };

        /* ═════════════════════════════════════════════════════════════
           HELPERS
           ═════════════════════════════════════════════════════════════ */
        function buildMeta(s) {
            return [s.StreamName, s.CourseName, s.LevelName, s.SemesterName]
                .filter(Boolean).join(' · ');
        }

        function populateDropdown(ddl, items, valField, textField, placeholder) {
            ddl.innerHTML = '';
            var opt0 = document.createElement('option');
            opt0.value = '0'; opt0.textContent = placeholder;
            ddl.appendChild(opt0);
            items.forEach(function (item) {
                var opt = document.createElement('option');
                opt.value = item[valField]; opt.textContent = item[textField];
                ddl.appendChild(opt);
            });
        }

        function resetSectionDropdown(ddl, placeholder) {
            ddl.innerHTML = '';
            var opt = document.createElement('option');
            opt.value = '0'; opt.textContent = placeholder;
            ddl.appendChild(opt);
        }

        function esc(s) {
            return String(s || '').replace(/&/g, '&amp;').replace(/</g, '&lt;')
                .replace(/>/g, '&gt;').replace(/"/g, '&quot;');
        }
        function escAttr(s) {
            return String(s || '').replace(/"/g, '&quot;').replace(/'/g, '&#39;');
        }

        /* ═════════════════════════════════════════════════════════════
           INIT
           ═════════════════════════════════════════════════════════════ */
        document.addEventListener('DOMContentLoaded', function () {
            /* Wire teacher search inputs */
            wireTeacherSearch('txtSingleTeacher', 'ddSingleTeacher', 'single');
            wireTeacherSearch('txtBulkTeacher', 'ddBulkTeacher', 'bulk');

            /* Load single subject list */
            loadSingleSubjects();

            /* Restore tab state after postback */
            restoreTab();

            /* Restore bulk section subjects if section was selected before postback */
            var bulkSecVal = ddlBulkSection ? ddlBulkSection.value : '0';
            if (bulkSecVal && bulkSecVal !== '0') {
                hfBulkSectionId.value = bulkSecVal;
                loadBulkSubjects(bulkSecVal);
            }

            /* Restore teacher chips if hfTeacherId has value (from postback round-trip) */
            /* Teacher is cleared by code-behind after successful save, so no restore needed */
        });

    })();
</script>

</asp:Content>
