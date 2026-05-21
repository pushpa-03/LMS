<%@ Page Title="Teacher Directory" Language="C#"
    MasterPageFile="~/Admin/AdminMaster.master"
    AutoEventWireup="true"
    CodeBehind="TeacherList.aspx.cs"
    Inherits="LearningManagementSystem.Admin.TeacherList" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server" />

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

<%-- ══ TOAST ════════════════════════════════════════════════ --%>
<div class="toast-container position-fixed p-3" style="top:70px;right:16px;z-index:9999;">
    <div id="liveToast" class="toast align-items-center border-0 shadow-lg" role="alert" aria-atomic="true">
        <div class="d-flex">
            <div class="toast-body fw-semibold" id="toastMsg" style="font-size:13px;"></div>
            <button type="button" class="btn-close me-2 m-auto" data-bs-dismiss="toast"></button>
        </div>
    </div>
</div>

<%-- ══ PAGE HEADER ══════════════════════════════════════════ --%>
<div class="tl-page-header mb-4">
    <div class="d-flex flex-wrap justify-content-between align-items-center gap-3">
        <div>
            <h4 class="fw-bold mb-1 d-flex align-items-center gap-2">
                <span class="tl-hdr-icon"><i class="fa fa-chalkboard-teacher"></i></span>
                Teacher Directory
            </h4>
            <div class="text-muted small d-flex align-items-center flex-wrap gap-2">
                <span>Manage and analyse your institute's faculty</span>
                <span class="tl-dot"></span>
                <span class="text-muted">
                    <i class="fa fa-clock me-1"></i>
                    Updated <%= DateTime.Now.ToString("dd MMM yyyy, hh:mm tt") %>
                </span>
            </div>
        </div>
        <a href="AddTeacher.aspx" class="btn btn-primary rounded-pill px-4 fw-semibold shadow-sm">
            <i class="fa fa-plus me-2"></i>Add Teacher
        </a>
    </div>
</div>

<%-- ══ STAT CARDS ════════════════════════════════════════════ --%>
<div class="row g-3 mb-4">
    <div class="col-6 col-sm-3">
        <div class="tl-stat-card border rounded-4 px-3 py-3 h-100">
            <div class="d-flex align-items-center gap-3">
                <div class="tl-stat-icon bg-primary bg-opacity-10 text-primary">
                    <i class="fa fa-users"></i>
                </div>
                <div>
                    <div class="tl-stat-lbl">Total Faculty</div>
                    <div class="tl-stat-val text-primary">
                        <asp:Literal ID="litTotal" runat="server" Text="0" />
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div class="col-6 col-sm-3">
        <div class="tl-stat-card border rounded-4 px-3 py-3 h-100">
            <div class="d-flex align-items-center gap-3">
                <div class="tl-stat-icon bg-success bg-opacity-10 text-success">
                    <i class="fa fa-user-check"></i>
                </div>
                <div>
                    <div class="tl-stat-lbl">Active</div>
                    <div class="tl-stat-val text-success">
                        <asp:Literal ID="litActive" runat="server" Text="0" />
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div class="col-6 col-sm-3">
        <div class="tl-stat-card border rounded-4 px-3 py-3 h-100">
            <div class="d-flex align-items-center gap-3">
                <div class="tl-stat-icon bg-warning bg-opacity-10 text-warning">
                    <i class="fa fa-user-times"></i>
                </div>
                <div>
                    <div class="tl-stat-lbl">Inactive</div>
                    <div class="tl-stat-val text-warning">
                        <asp:Literal ID="litInactive" runat="server" Text="0" />
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div class="col-6 col-sm-3">
        <div class="tl-stat-card border rounded-4 px-3 py-3 h-100">
            <div class="d-flex align-items-center gap-3">
                <div class="tl-stat-icon bg-info bg-opacity-10 text-info">
                    <i class="fa fa-sitemap"></i>
                </div>
                <div>
                    <div class="tl-stat-lbl">Departments</div>
                    <div class="tl-stat-val text-info">
                        <asp:Literal ID="litDepts" runat="server" Text="0" />
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<%-- ══ FILTER BAR ════════════════════════════════════════════ --%>
<div class="card shadow-sm border-0 rounded-4 mb-4">
    <div class="card-body px-4 py-3">
        <div class="d-flex align-items-center flex-wrap gap-2">

            <%-- Search --%>
            <div class="tl-srch-wrap" style="flex:1;min-width:160px;max-width:280px">
                <i class="fa fa-search tl-srch-ico"></i>
                <asp:TextBox ID="txtSearch" runat="server"
                    CssClass="form-control tl-srch-inp"
                    placeholder="Search name, ID..."
                    AutoPostBack="true"
                    OnTextChanged="Filter_Changed" />
            </div>

            <%-- Stream filter --%>
            <asp:DropDownList ID="ddlStream" runat="server"
                CssClass="form-select tl-flt-sel"
                AutoPostBack="true"
                OnSelectedIndexChanged="Filter_Changed" />

         
           <%-- Status filter --%>
            <asp:DropDownList ID="ddlStatus" runat="server"
                CssClass="form-select tl-flt-sel"
                AutoPostBack="true"
                OnSelectedIndexChanged="Filter_Changed">
                <asp:ListItem Text="Active" Value="1" />
                <asp:ListItem Text="Inactive" Value="0" />
            </asp:DropDownList>

            <%-- Reset --%>
            <asp:LinkButton ID="btnClear" runat="server"
                CssClass="btn btn-outline-secondary rounded-pill px-3 fw-semibold"
                OnClick="btnClear_Click">
                <i class="fa fa-redo me-1"></i>Reset
            </asp:LinkButton>

            <%-- Record info --%>
            <span class="ms-auto text-muted small fw-semibold d-none d-sm-inline" id="pgInfo"></span>
        </div>
    </div>
</div>

<%-- ══ TEACHER TABLE ══════════════════════════════════════════ --%>
<div class="card shadow-sm border-0 rounded-4 overflow-hidden">
    <div class="table-responsive">
        <asp:GridView ID="gvTeachers" runat="server"
            AutoGenerateColumns="false"
            CssClass="table table-hover align-middle tl-table mb-0"
            GridLines="None"
            OnRowCommand="gvTeachers_RowCommand">
            <HeaderStyle CssClass="tl-tbl-hdr" />
            <EmptyDataTemplate>
                <div class="text-center py-5">
                    <i class="fa fa-user-slash fa-3x text-muted mb-3 d-block opacity-25"></i>
                    <p class="fw-semibold text-muted mb-1">No teachers found</p>
                    <p class="text-muted small mb-3">Try adjusting your search or filters.</p>
                    <a href="AddTeacher.aspx" class="btn btn-primary rounded-pill px-4">
                        <i class="fa fa-plus me-2"></i>Add First Teacher
                    </a>
                </div>
            </EmptyDataTemplate>
            <Columns>

                <%-- # --%>
                <asp:TemplateField HeaderText="#" ItemStyle-Width="44px">
                    <ItemTemplate>
                        <span class="text-muted small"><%# Container.DataItemIndex + 1 %></span>
                    </ItemTemplate>
                </asp:TemplateField>

                <%-- Faculty Profile --%>
                <asp:TemplateField HeaderText="Faculty">
                    <ItemTemplate>
                        <div class="d-flex align-items-center gap-3">
                            <div class="tl-av"
                                 style="background:<%# GetAvatarColor(Eval("FullName").ToString()) %>">
                                <%# GetInitials(Eval("FullName").ToString()) %>
                            </div>
                            <div>
                                <div class="fw-semibold text-dark" style="font-size:14px">
                                    <%# Eval("FullName") %>
                                </div>
                                <div class="text-muted" style="font-size:11px">
                                    <i class="fa fa-id-badge me-1 opacity-50"></i><%# Eval("EmployeeId") %>
                                </div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:TemplateField>

                <%-- Department / Stream --%>
                <asp:TemplateField HeaderText="Department">
                    <ItemTemplate>
                        <span class="tl-dept-badge">
                            <i class="fa fa-sitemap me-1 opacity-60"></i><%# Eval("Stream") %>
                        </span>
                    </ItemTemplate>
                </asp:TemplateField>

                <%-- Designation --%>
                <asp:TemplateField HeaderText="Designation">
                    <ItemTemplate>
                        <span class="text-muted small"><%# Eval("Designation") %></span>
                    </ItemTemplate>
                </asp:TemplateField>

                <%-- Contact --%>
                <asp:TemplateField HeaderText="Contact" ItemStyle-CssClass="d-none d-md-table-cell" HeaderStyle-CssClass="d-none d-md-table-cell">
                    <ItemTemplate>
                        <div style="font-size:12px">
                            <div class="text-muted">
                                <i class="fa fa-envelope me-1 opacity-50"></i><%# Eval("Email") %>
                            </div>
                            <div class="text-muted mt-1">
                                <i class="fa fa-phone me-1 opacity-50"></i><%# Eval("ContactNo") %>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:TemplateField>


                <%-- Joining --%>
                <asp:TemplateField HeaderText="Joined" ItemStyle-Width="100px" ItemStyle-CssClass="d-none d-lg-table-cell" HeaderStyle-CssClass="d-none d-lg-table-cell">
                    <ItemTemplate>
                        <span class="text-muted small">
                            <%# Eval("JoinedDate") != DBNull.Value && !string.IsNullOrEmpty(Eval("JoinedDate").ToString())
                            ? Convert.ToDateTime(Eval("JoinedDate")).ToString("dd MMM yy")
                            : "—" %>
                        </span>
                    </ItemTemplate>
                </asp:TemplateField>

                <%-- Actions --%>
                <asp:TemplateField HeaderText="" ItemStyle-Width="80px" ItemStyle-CssClass="text-center">
                    <ItemTemplate>
                        <div class="d-flex gap-1 justify-content-center">
                            <asp:LinkButton runat="server"
                                CommandName="ViewDetails"
                                CommandArgument='<%# Eval("UserId") %>'
                                CssClass="tl-act-btn act-view" title="View Profile">
                                <i class="fa fa-eye"></i>
                            </asp:LinkButton>
                            <asp:LinkButton runat="server"
                                CommandName="EditRow"
                                CommandArgument='<%# Eval("UserId") %>'
                                CssClass="tl-act-btn act-edit" title="Edit">
                                <i class="fa fa-pen"></i>
                            </asp:LinkButton>
                        </div>
                    </ItemTemplate>
                </asp:TemplateField>

            </Columns>
        </asp:GridView>
    </div>
</div>

<%-- ══ PAGINATION + INFO ══════════════════════════════════════ --%>
<div class="d-flex justify-content-between align-items-center flex-wrap gap-2 mt-3">
    <span class="text-muted small d-sm-none" id="pgInfoMobile"></span>
    <%--
        ★ pnlPager — BuildPager() in code-behind adds LinkButton controls here.
          BindTeacherData() is called in Page_Load on EVERY request, so buttons
          are always in the control tree and their Click events fire correctly.
    --%>
    <asp:Panel ID="pnlPager" runat="server"
        CssClass="d-flex align-items-center gap-1 flex-wrap mx-auto" />
    <span class="text-muted small d-none d-sm-inline" id="pgInfoDesk"></span>
</div>

<%-- ══ STYLES ════════════════════════════════════════════════ --%>
<style>
:root { --pri:#4f46e5; --pri-lt:#eef2ff; }

/* Header */
.tl-hdr-icon {
    width:38px;height:38px;border-radius:12px;
    background:var(--pri-lt);color:var(--pri);
    display:inline-flex;align-items:center;justify-content:center;font-size:16px;
}
.tl-dot { width:4px;height:4px;background:#cbd5e1;border-radius:50%;display:inline-block; }

/* Stat cards */
.tl-stat-card { background:#fff;transition:transform .2s,box-shadow .2s; }
.tl-stat-card:hover { transform:translateY(-3px);box-shadow:0 6px 20px rgba(0,0,0,.08)!important; }
.tl-stat-icon { width:42px;height:42px;border-radius:12px;display:flex;align-items:center;justify-content:center;font-size:16px;flex-shrink:0; }
.tl-stat-lbl  { font-size:10px;text-transform:uppercase;letter-spacing:.5px;color:#94a3b8;font-weight:600; }
.tl-stat-val  { font-size:22px;font-weight:800;line-height:1.1; }

/* Filter bar */
.tl-srch-wrap { position:relative; }
.tl-srch-ico  { position:absolute;top:50%;left:12px;transform:translateY(-50%);color:#94a3b8;font-size:13px;z-index:2; }
.tl-srch-inp  { padding-left:36px;border-radius:10px;height:36px;font-size:13px; }
.tl-srch-inp:focus { border-color:var(--pri);box-shadow:0 0 0 3px rgba(79,70,229,.15); }
.tl-flt-sel   { height:36px;font-size:13px;border-radius:10px;min-width:130px;max-width:180px; }
.tl-flt-sel:focus { border-color:var(--pri);box-shadow:0 0 0 3px rgba(79,70,229,.15); }

/* Table */
.tl-tbl-hdr th {
    background:linear-gradient(135deg,#4f46e5,#6366f1)!important;
    color:#fff!important;border:none!important;
    padding:12px 14px!important;font-weight:600;font-size:12px;
    white-space:nowrap;text-transform:uppercase;letter-spacing:.4px;
}
.tl-table td { padding:12px 14px;font-size:13px;border-bottom:1px solid #f1f5f9!important;vertical-align:middle; }
.tl-table tbody tr { transition:background .12s; }
.tl-table tbody tr:hover { background:#f8faff!important; }

/* Avatar */
.tl-av {
    width:40px;height:40px;border-radius:12px;
    display:flex;align-items:center;justify-content:center;
    font-weight:700;font-size:14px;color:#fff;flex-shrink:0;
}

/* Department badge */
.tl-dept-badge {
    display:inline-block;padding:3px 10px;border-radius:20px;
    background:#eef2ff;color:#4f46e5;font-size:11px;font-weight:600;
}

/* Action buttons */
.tl-act-btn {
    width:30px;height:30px;border-radius:8px;border:none;
    display:inline-flex;align-items:center;justify-content:center;
    font-size:11px;cursor:pointer;transition:transform .15s,box-shadow .15s;
    text-decoration:none;
}
.tl-act-btn:hover { transform:scale(1.12);box-shadow:0 2px 8px rgba(0,0,0,.12); }
.act-view { background:#eef2ff;color:#4f46e5; }
.act-edit { background:#e0f2fe;color:#0369a1; }

/* Pagination */
.tl-pg-btn {
    display:inline-flex;align-items:center;justify-content:center;
    min-width:34px;height:34px;padding:0 8px;
    border-radius:9px;border:1px solid #e2e8f0;
    background:#fff;font-size:13px;color:#475569;
    text-decoration:none;transition:.15s;cursor:pointer;line-height:1;
}
.tl-pg-btn:hover  { background:var(--pri);color:#fff;border-color:var(--pri); }
.tl-pg-btn.active { background:var(--pri);color:#fff;border-color:var(--pri);font-weight:700; }
.tl-pg-btn.disabled { opacity:.4;pointer-events:none; }

/* Responsive */
@media (max-width:767px) {
    .tl-flt-sel { min-width:100px;flex:1; }
    .tl-srch-inp { font-size:13px; }
    .tl-pg-btn { min-width:30px;height:30px;font-size:12px; }
    .tl-stat-val { font-size:18px; }
}
</style>

<%-- ══ SCRIPTS ════════════════════════════════════════════════ --%>
<script>
(function(){
    // Mirror pgInfo to both spans (desktop + mobile)
    var _orig = '';
    function _syncInfo() {
        var desk  = document.getElementById('pgInfoDesk');
        var mob   = document.getElementById('pgInfoMobile');
        var el    = document.getElementById('pgInfo'); // hidden relay set by ScriptManager
        if (!el) return;
        if (desk) desk.textContent  = el.textContent || _orig;
        if (mob)  mob.textContent   = el.textContent || _orig;
    }
    document.addEventListener('DOMContentLoaded', _syncInfo);
})();
</script>

<%-- Hidden relay span for pgInfo from ScriptManager --%>
<span id="pgInfo" style="display:none"></span>

</asp:Content>