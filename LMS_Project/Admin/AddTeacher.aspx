<%@ Page Title="Teacher Management" Language="C#" MasterPageFile="~/Admin/AdminMaster.master"
    AutoEventWireup="true" CodeBehind="AddTeacher.aspx.cs"
    Inherits="LearningManagementSystem.Admin.AddTeacher" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server" />
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

<%-- ══ HIDDEN STATE ══════════════════════════════════════════ --%>
<asp:HiddenField ID="hfTeacherUserId" runat="server" />
<asp:HiddenField ID="hfReenrolIds"    runat="server" />

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
<div class="mb-4">
    <div class="d-flex flex-wrap justify-content-between align-items-start gap-3">
        <div>
            <h4 class="fw-bold mb-1 d-flex align-items-center gap-2">
                <span class="tch-hdr-icon"><i class="fa fa-chalkboard-teacher"></i></span>
                Teacher Management
            </h4>
            <div class="text-muted small d-flex align-items-center flex-wrap gap-2">
                <span>Hire, manage &amp; re-enrol teachers</span>
                <span class="dot-sep"></span>
                <asp:Label ID="lblSessionName" runat="server"
                    CssClass="badge bg-primary bg-opacity-10 text-primary px-2 py-1" />
                <asp:Label ID="lblSuperAdminBadge" runat="server" Visible="false"
                    CssClass="badge bg-warning text-dark">
                    <i class="fa fa-eye me-1"></i>View Only
                </asp:Label>
            </div>
        </div>
        <div class="d-flex align-items-center gap-2 flex-wrap">
            <asp:Panel ID="pnlBulkBtn" runat="server">
                <button type="button" class="btn btn-outline-success btn-sm rounded-pill px-3 fw-semibold"
                        onclick="openBulkModal()">
                    <i class="fa fa-file-excel me-1"></i><span class="tch-btn-text">Bulk Upload</span>
                </button>
            </asp:Panel>
            <asp:Panel ID="pnlReenrolBtn" runat="server">
                <button type="button" class="btn btn-outline-warning btn-sm rounded-pill px-3 fw-semibold"
                        onclick="openReenrolModal()">
                    <i class="fa fa-sync me-1"></i><span class="tch-btn-text">Re-Enrol</span>
                </button>
            </asp:Panel>
            <asp:Panel ID="pnlAddBtn" runat="server">
                <button type="button" class="btn btn-primary rounded-pill px-4 fw-semibold shadow-sm"
                        onclick="openAddModal()">
                    <i class="fa fa-plus me-1"></i><span class="tch-btn-text">Add Teacher</span>
                </button>
            </asp:Panel>
        </div>
    </div>
</div>

<%-- ══ STATS ════════════════════════════════════════════════ --%>
<div class="row g-3 mb-4">
    <div class="col-6 col-sm-3">
        <div class="tch-stat card border-0 shadow-sm p-3">
            <div class="d-flex align-items-center gap-3">
                <div class="tch-ico bg-primary bg-opacity-10 text-primary"><i class="fa fa-users-cog"></i></div>
                <div>
                    <div class="tch-stat-lbl text-muted">Total</div>
                    <div class="fw-bold fs-5"><asp:Label ID="lblTotal" runat="server" Text="0"/></div>
                </div>
            </div>
        </div>
    </div>
    <div class="col-6 col-sm-3">
        <div class="tch-stat card border-0 shadow-sm p-3">
            <div class="d-flex align-items-center gap-3">
                <div class="tch-ico bg-success bg-opacity-10 text-success"><i class="fa fa-user-check"></i></div>
                <div>
                    <div class="tch-stat-lbl text-muted">Active</div>
                    <div class="fw-bold fs-5 text-success"><asp:Label ID="lblActive" runat="server" Text="0"/></div>
                </div>
            </div>
        </div>
    </div>
    <div class="col-6 col-sm-3">
        <div class="tch-stat card border-0 shadow-sm p-3">
            <div class="d-flex align-items-center gap-3">
                <div class="tch-ico bg-warning bg-opacity-10 text-warning"><i class="fa fa-user-clock"></i></div>
                <div>
                    <div class="tch-stat-lbl text-muted">First Login</div>
                    <div class="fw-bold fs-5 text-warning"><asp:Label ID="lblPending" runat="server" Text="0"/></div>
                </div>
            </div>
        </div>
    </div>
    <div class="col-6 col-sm-3">
        <div class="tch-stat card border-0 shadow-sm p-3">
            <div class="d-flex align-items-center gap-3">
                <div class="tch-ico bg-secondary bg-opacity-10 text-secondary"><i class="fa fa-user-times"></i></div>
                <div>
                    <div class="tch-stat-lbl text-muted">Inactive</div>
                    <div class="fw-bold fs-5 text-secondary"><asp:Label ID="lblInactive" runat="server" Text="0"/></div>
                </div>
            </div>
        </div>
    </div>
</div>

<%-- ══ FILTER BAR — below stats, above table ═══════════════ --%>
<div class="tch-filter-bar card border-0 shadow-sm rounded-4 px-3 py-2 mb-3">
    <div class="tch-filter-row">
        <div class="tch-srch-wrap">
            <i class="fa fa-search tch-srch-ico"></i>
            <input type="text"
                   id="txtSearchClient"
                   class="form-control tch-srch-inp"
                   placeholder="Search teachers..."
                   onkeyup="clientSearch(this.value)" />
        </div>
        <asp:DropDownList ID="ddlFilterStream"
            runat="server"
            CssClass="form-select tch-flt-sel"
            AutoPostBack="true"
            OnSelectedIndexChanged="ddlFilterStream_Changed">
            <asp:ListItem Value="0" Text="All Streams" />
        </asp:DropDownList>
        <asp:DropDownList ID="ddlFilterStatus"
            runat="server"
            CssClass="form-select tch-flt-sel"
            AutoPostBack="true"
            OnSelectedIndexChanged="ddlFilterStatus_Changed">
            <asp:ListItem Value="All" Text="All Status" />
            <asp:ListItem Value="Active" Text="Active" />
            <asp:ListItem Value="Inactive" Text="Inactive" />
        </asp:DropDownList>
        <span id="recordCount" class="tch-record-count"></span>
    </div>
</div>

<%-- ══ TABLE ═══════════════════════════════════════════════ --%>
<div class="card shadow-sm border-0 rounded-4 overflow-hidden">
    <div class="table-responsive">
        <asp:GridView ID="gvTeachers" runat="server"
            CssClass="table table-hover align-middle modern-table mb-0"
            AutoGenerateColumns="false"
            OnRowCommand="gvTeachers_RowCommand"
            EnableViewState="true"
            GridLines="None">
            <HeaderStyle CssClass="tch-tbl-hdr" />
            <EmptyDataTemplate>
                <div class="text-center py-5">
                    <i class="fa fa-chalkboard-teacher fa-3x text-muted mb-3 d-block"></i>
                    <p class="fw-semibold text-muted mb-1">No teachers found</p>
                    <p class="text-muted small">Click <strong>Add Teacher</strong> to get started.</p>
                </div>
            </EmptyDataTemplate>
            <Columns>
                <asp:TemplateField HeaderText="#" ItemStyle-Width="42px">
                    <ItemTemplate>
                        <span class="text-muted small"><%# ((CurrentPage-1)*12)+Container.DataItemIndex+1 %></span>
                    </ItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Teacher">
                    <ItemTemplate>
                        <div class="d-flex align-items-center gap-2">
                            <div class="tch-av" style="background:<%# GetAvatarColor(Eval("FullName").ToString()) %>">
                                <%# GetInitials(Eval("FullName").ToString()) %>
                            </div>
                            <div>
                                <div class="fw-semibold small"><%# Eval("FullName") %></div>
                                <div class="text-muted" style="font-size:11px"><%# Eval("Username") %></div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:TemplateField>
                <asp:BoundField DataField="EmployeeId" HeaderText="Emp ID"
                    ItemStyle-CssClass="tch-col-empid"
                    HeaderStyle-CssClass="tch-col-empid" />
                <asp:BoundField DataField="Email" HeaderText="Email"
                    ItemStyle-CssClass="d-none d-md-table-cell"
                    HeaderStyle-CssClass="d-none d-md-table-cell" />
                <asp:TemplateField HeaderText="Stream / Designation">
                    <ItemTemplate>
                        <span class="acad-tag tag-stream"><%# Eval("StreamName") %></span><br/>
                        <span class="acad-tag tag-desig mt-1"><%# Eval("Designation") %></span>
                    </ItemTemplate>
                </asp:TemplateField>
                <asp:BoundField DataField="ExperienceYears" HeaderText="Exp"
                    ItemStyle-CssClass="d-none d-lg-table-cell text-center"
                    HeaderStyle-CssClass="d-none d-lg-table-cell text-center" />
                <asp:TemplateField HeaderText="Actions" ItemStyle-CssClass="tbl-act-cell">
                    <ItemTemplate>
                        <div class="d-flex gap-1 flex-nowrap">
                            <asp:LinkButton runat="server" CommandName="ViewTeacher"
                                CommandArgument='<%# Eval("UserId") %>'
                                CssClass="tbl-act-btn act-view" title="View Profile">
                                <i class="fa fa-eye"></i>
                            </asp:LinkButton>
                            <asp:LinkButton runat="server" CommandName="EditTeacher"
                                CommandArgument='<%# Eval("UserId") %>'
                                CssClass="tbl-act-btn act-edit" title="Edit">
                                <i class="fa fa-edit"></i>
                            </asp:LinkButton>
                            <asp:LinkButton runat="server" CommandName="ResetPassword"
                                CommandArgument='<%# Eval("UserId") %>'
                                CssClass="tbl-act-btn act-key" title="Reset Password">
                                <i class="fa fa-key"></i>
                            </asp:LinkButton>
                            <asp:LinkButton runat="server" CommandName="ToggleTeacher"
                                CommandArgument='<%# Eval("UserId") %>'
                                CssClass="tbl-act-btn act-toggle" title="Toggle Status"
                                OnClientClick="return confirm('Change teacher status?');">
                                <i class="fa fa-power-off"></i>
                            </asp:LinkButton>
                            <asp:LinkButton runat="server" CommandName="DeleteTeacher"
                                CommandArgument='<%# Eval("UserId") %>'
                                CssClass="tbl-act-btn act-del" title="Delete"
                                OnClientClick="return confirm('Delete this teacher? Cannot be undone.');">
                                <i class="fa fa-trash"></i>
                            </asp:LinkButton>
                        </div>
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
        </asp:GridView>
    </div>
</div>

<div class="d-flex justify-content-between align-items-center flex-wrap gap-2 mt-3">
    <span class="small text-muted" id="pagerInfo"></span>
    <asp:Panel ID="pnlPager" runat="server"
        CssClass="d-flex align-items-center gap-1 flex-wrap justify-content-center" />
</div>

<%-- ══ ADD / EDIT MODAL ══════════════════════════════════════ --%>
<div class="modal fade" id="TeacherModal" tabindex="-1"
     aria-labelledby="teacherModalLabel" aria-hidden="true"
     data-bs-backdrop="static" data-bs-keyboard="false">
    <div class="modal-dialog modal-lg modal-dialog-scrollable tch-modal-dialog">
        <div class="modal-content rounded-4 border-0 shadow-lg tch-modal-content">
            <div class="modal-header tch-modal-hdr text-white py-3">
                <div>
                    <h5 class="modal-title fw-bold mb-0" id="teacherModalLabel">
                        <i class="fa fa-user-tie me-2"></i>
                        <span id="modalTitleText">Add New Teacher</span>
                    </h5>
                    <small class="opacity-75" id="modalSubText">Fill all required fields marked *</small>
                </div>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <%-- Wizard tabs --%>
            <ul class="nav tch-wiz-nav px-3 pt-3 gap-1">
                <li class="nav-item">
                    <a class="tch-wiz-tab active" href="#" onclick="gotoTab(1);return false;">
                        <span class="tab-num">1</span><span class="tab-txt"> Account</span>
                    </a>
                </li>
                <li class="nav-item">
                    <a class="tch-wiz-tab" href="#" onclick="gotoTab(2);return false;">
                        <span class="tab-num">2</span><span class="tab-txt"> Professional</span>
                    </a>
                </li>
                <li class="nav-item">
                    <a class="tch-wiz-tab" href="#" onclick="gotoTab(3);return false;">
                        <span class="tab-num">3</span><span class="tab-txt"> Personal</span>
                    </a>
                </li>
            </ul>
            <div class="modal-body p-3 p-md-4">
                <%-- Tab 1 --%>
                <div id="tab1" class="tch-pane">
                    <div class="row g-3">
                        <div class="col-12 col-sm-6 col-md-4">
                            <label class="form-label fw-semibold small">Full Name <span class="req">*</span></label>
                            <asp:TextBox ID="txtFullName" runat="server" CssClass="form-control"
                                placeholder="e.g. Dr. Priya Sharma" MaxLength="150" oninput="autoUsername()" />
                            <div class="form-err" id="errFullName"></div>
                        </div>
                        <div class="col-12 col-sm-6 col-md-4">
                            <label class="form-label fw-semibold small">Username <span class="req">*</span></label>
                            <asp:TextBox ID="txtUsername" runat="server" CssClass="form-control"
                                placeholder="e.g. priya_sharma" MaxLength="50" />
                            <div class="form-err" id="errUsername"></div>
                            <div class="form-text text-muted" style="font-size:11px">Lowercase, numbers, underscore only</div>
                        </div>
                        <div class="col-12 col-sm-6 col-md-4">
                            <label class="form-label fw-semibold small">Email <span class="req">*</span></label>
                            <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control"
                                placeholder="teacher@school.edu" MaxLength="100" TextMode="Email" />
                            <div class="form-err" id="errEmail"></div>
                        </div>
                        <div class="col-12 col-sm-6 col-md-4">
                            <label class="form-label fw-semibold small">Password <span class="req">*</span></label>
                            <div class="input-group">
                                <asp:TextBox ID="txtPassword" runat="server" CssClass="form-control"
                                    placeholder="Min 8 chars" TextMode="Password" MaxLength="50"
                                    oninput="checkPwdStrength(this.value)" />
                                <button class="btn btn-outline-secondary" type="button"
                                        onclick="togglePwd(this)" tabindex="-1">
                                    <i class="fa fa-eye"></i>
                                </button>
                            </div>
                            <div class="pwd-strength mt-1" id="pwdBar" style="display:none">
                                <div class="pwd-fill" id="pwdFill"></div>
                            </div>
                            <div class="form-err" id="errPassword"></div>
                            <div class="form-text" id="pwdTxt" style="font-size:11px"></div>
                        </div>
                        <div class="col-12 col-sm-6 col-md-4">
                            <label class="form-label fw-semibold small">Contact <span class="req">*</span></label>
                            <asp:TextBox ID="txtContact" runat="server" CssClass="form-control"
                                placeholder="10-digit mobile" MaxLength="15"
                                oninput="this.value=this.value.replace(/[^0-9+]/g,'')" />
                            <div class="form-err" id="errContact"></div>
                        </div>
                        <div class="col-12 col-sm-6 col-md-4">
                            <label class="form-label fw-semibold small">Employee ID <span class="req">*</span></label>
                            <asp:TextBox ID="txtEmpId" runat="server" CssClass="form-control"
                                placeholder="e.g. EMP2025001" MaxLength="50" />
                            <div class="form-err" id="errEmpId"></div>
                        </div>
                    </div>
                </div>
                <%-- Tab 2 --%>
                <div id="tab2" class="tch-pane" style="display:none">
                    <div class="row g-3">
                        <div class="col-12 col-sm-6 col-md-4">
                            <label class="form-label fw-semibold small">Stream / Dept <span class="req">*</span></label>
                            <asp:DropDownList ID="ddlStream" runat="server" CssClass="form-select">
                                <asp:ListItem Value="0" Text="-- Select Stream --" />
                            </asp:DropDownList>
                            <div class="form-err" id="errStream"></div>
                        </div>
                        <div class="col-12 col-sm-6 col-md-4">
                            <label class="form-label fw-semibold small">Designation <span class="req">*</span></label>
                            <asp:TextBox ID="txtDesignation" runat="server" CssClass="form-control"
                                placeholder="e.g. Associate Professor" MaxLength="100" />
                            <div class="form-err" id="errDesig"></div>
                        </div>
                        <div class="col-12 col-sm-6 col-md-4">
                            <label class="form-label fw-semibold small">Experience (Years) <span class="req">*</span></label>
                            <asp:TextBox ID="txtExperience" runat="server" CssClass="form-control"
                                placeholder="e.g. 5" MaxLength="2"
                                oninput="this.value=this.value.replace(/[^0-9]/g,'')" />
                            <div class="form-err" id="errExp"></div>
                        </div>
                        <div class="col-12 col-sm-6 col-md-4">
                            <label class="form-label fw-semibold small">Qualification</label>
                            <asp:TextBox ID="txtQualification" runat="server" CssClass="form-control"
                                placeholder="e.g. M.Tech, Ph.D" MaxLength="100" />
                        </div>
                        <div class="col-12 col-sm-6 col-md-4">
                            <label class="form-label fw-semibold small">Joining Date <span class="req">*</span></label>
                            <asp:TextBox ID="txtJoinDate" runat="server" CssClass="form-control" TextMode="Date" />
                            <div class="form-err" id="errJoinDate"></div>
                        </div>
                        <div class="col-12 col-sm-6 col-md-4">
                            <label class="form-label fw-semibold small d-block">Status</label>
                            <div class="form-check form-switch mt-2">
                                <asp:CheckBox ID="chkActive" runat="server" Checked="true" CssClass="form-check-input" />
                                <label class="form-check-label" for="<%= chkActive.ClientID %>">Active</label>
                            </div>
                        </div>
                    </div>
                </div>
                <%-- Tab 3 --%>
                <div id="tab3" class="tch-pane" style="display:none">
                    <div class="row g-3">
                        <div class="col-12 col-sm-6 col-md-4">
                            <label class="form-label fw-semibold small">Gender <span class="req">*</span></label>
                            <asp:DropDownList ID="ddlGender" runat="server" CssClass="form-select">
                                <asp:ListItem Value="">-- Select --</asp:ListItem>
                                <asp:ListItem Value="Male">Male</asp:ListItem>
                                <asp:ListItem Value="Female">Female</asp:ListItem>
                                <asp:ListItem Value="Other">Other</asp:ListItem>
                            </asp:DropDownList>
                            <div class="form-err" id="errGender"></div>
                        </div>
                        <div class="col-12 col-sm-6 col-md-4">
                            <label class="form-label fw-semibold small">Date of Birth <span class="req">*</span></label>
                            <asp:TextBox ID="txtDOB" runat="server" CssClass="form-control" TextMode="Date" />
                            <div class="form-err" id="errDOB"></div>
                        </div>
                        <div class="col-12 col-sm-6 col-md-4">
                            <label class="form-label fw-semibold small">Father's Name</label>
                            <asp:TextBox ID="txtFatherName" runat="server" CssClass="form-control"
                                placeholder="Father's full name" MaxLength="100" />
                        </div>
                        <div class="col-12 col-sm-6 col-md-4">
                            <label class="form-label fw-semibold small">Mother's Name</label>
                            <asp:TextBox ID="txtMotherName" runat="server" CssClass="form-control"
                                placeholder="Mother's full name" MaxLength="100" />
                        </div>
                        <div class="col-12 col-sm-6 col-md-4">
                            <label class="form-label fw-semibold small">Emergency Contact Name <span class="req">*</span></label>
                            <asp:TextBox ID="txtEmgName" runat="server" CssClass="form-control"
                                placeholder="Guardian / spouse name" MaxLength="150" />
                            <div class="form-err" id="errEmgName"></div>
                        </div>
                        <div class="col-12 col-sm-6 col-md-4">
                            <label class="form-label fw-semibold small">Emergency Contact No <span class="req">*</span></label>
                            <asp:TextBox ID="txtEmgContact" runat="server" CssClass="form-control"
                                placeholder="10-digit" MaxLength="15"
                                oninput="this.value=this.value.replace(/[^0-9+]/g,'')" />
                            <div class="form-err" id="errEmgContact"></div>
                        </div>
                        <div class="col-12">
                            <label class="form-label fw-semibold small">Address <span class="req">*</span></label>
                            <asp:TextBox ID="txtAddress" runat="server" CssClass="form-control"
                                TextMode="MultiLine" Rows="2"
                                placeholder="Full residential address" MaxLength="300" />
                            <div class="form-err" id="errAddress"></div>
                        </div>
                        <div class="col-12 col-sm-4">
                            <label class="form-label fw-semibold small">City</label>
                            <asp:TextBox ID="txtCity" runat="server" CssClass="form-control"
                                placeholder="City" MaxLength="50" />
                        </div>
                        <div class="col-12 col-sm-4">
                            <label class="form-label fw-semibold small">Country</label>
                            <asp:TextBox ID="txtCountry" runat="server" CssClass="form-control"
                                placeholder="Country" MaxLength="50" />
                        </div>
                        <div class="col-12 col-sm-4">
                            <label class="form-label fw-semibold small">Pincode</label>
                            <asp:TextBox ID="txtPincode" runat="server" CssClass="form-control"
                                placeholder="6-digit" MaxLength="6"
                                oninput="this.value=this.value.replace(/[^0-9]/g,'')" />
                        </div>
                        <div class="col-12">
                            <label class="form-label fw-semibold small">Skills</label>
                            <asp:TextBox ID="txtSkills" runat="server" CssClass="form-control"
                                placeholder="e.g. Python, Machine Learning" MaxLength="200" />
                        </div>
                    </div>
                </div>
            </div><%-- /modal-body --%>
            <div class="modal-footer border-top-0 px-3 px-md-4 pb-4 pt-2 d-flex justify-content-between gap-2">
                <button type="button" class="btn btn-outline-secondary rounded-pill px-3 px-md-4"
                        id="btnWizPrev" onclick="wizNav(-1)" style="display:none">
                    <i class="fa fa-chevron-left me-1"></i>Prev
                </button>
                <div class="d-flex gap-2 ms-auto flex-wrap justify-content-end">
                    <button type="button" class="btn btn-outline-secondary rounded-pill px-3 px-md-4"
                            data-bs-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-primary rounded-pill px-3 px-md-4 fw-semibold"
                            id="btnWizNext" onclick="wizNav(1)">
                        Next <i class="fa fa-chevron-right ms-1"></i>
                    </button>
                    <asp:Button ID="btnSaveTeacher" runat="server"
                        Text="Add Teacher"
                        CssClass="btn btn-success rounded-pill px-3 px-md-4 fw-semibold"
                        OnClick="btnSaveTeacher_Click"
                        OnClientClick="return finalValidate();"
                        style="display:none" />
                </div>
            </div>
        </div>
    </div>
</div>

<%-- ══ VIEW MODAL ════════════════════════════════════════════ --%>
<div class="modal fade" id="ViewTeacherModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-scrollable tch-modal-dialog">
        <div class="modal-content rounded-4 border-0 shadow-lg tch-modal-content">
            <div class="modal-header tch-modal-hdr text-white">
                <h5 class="modal-title fw-bold"><i class="fa fa-id-card me-2"></i>Teacher Profile</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body p-3 p-md-4" id="teacherProfileBody">
                <div class="text-center py-4"><div class="spinner-border text-primary"></div></div>
            </div>
            <div class="modal-footer border-top pt-3 pb-3 px-3 px-md-4" id="viewModalFooter">
                <button type="button" class="btn btn-outline-secondary rounded-pill px-4"
                        data-bs-dismiss="modal">Close</button>
                <a id="btnGoToDetails" href="#"
                   class="btn btn-primary rounded-pill px-4 fw-semibold">
                    <i class="fa fa-user-graduate me-1"></i>Teacher Details
                </a>
            </div>
        </div>
    </div>
</div>

<%-- ══ BULK UPLOAD MODAL ═════════════════════════════════════ --%>
<div class="modal fade" id="BulkModal" tabindex="-1" aria-hidden="true" data-bs-backdrop="static">
    <div class="modal-dialog modal-lg tch-modal-dialog">
        <div class="modal-content rounded-4 border-0 shadow-lg tch-modal-content">
            <div class="modal-header bg-success text-white">
                <h5 class="modal-title fw-bold"><i class="fa fa-file-excel me-2"></i>Bulk Upload Teachers</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body p-3 p-md-4">
                <div class="alert alert-info border-0 rounded-3 mb-3" style="font-size:12px">
                    <i class="fa fa-info-circle me-2"></i>
                    Columns: <strong>FullName, Username, Email, Password, ContactNo, EmployeeId, StreamName,
                    Designation, ExperienceYears, Qualification, JoiningDate, Gender, DOB, FatherName,
                    MotherName, Address, City, Country, Pincode, Skills</strong>.
                    Duplicates skipped and reported.
                </div>
                <div class="mb-3">
                    <asp:LinkButton ID="lnkDownloadTemplate" runat="server"
                        CssClass="btn btn-outline-success btn-sm rounded-pill"
                        OnClick="lnkDownloadTemplate_Click">
                        <i class="fa fa-download me-1"></i>Download Template
                    </asp:LinkButton>
                </div>
                <div class="mb-3">
                    <label class="form-label fw-semibold small">Select Excel File <span class="req">*</span></label>
                    <asp:FileUpload ID="fuBulk" runat="server" CssClass="form-control" accept=".xlsx,.xls" />
                </div>
                <asp:Panel ID="pnlBulkResult" runat="server" Visible="false">
                    <div class="bulk-res-box"><asp:Literal ID="litBulkResult" runat="server" /></div>
                </asp:Panel>
            </div>
            <div class="modal-footer border-0 px-3 px-md-4 pb-4 pt-0 gap-2">
                <button type="button" class="btn btn-outline-secondary rounded-pill px-4"
                        data-bs-dismiss="modal">Close</button>
                <asp:Button ID="btnBulkUpload" runat="server"
                    Text="Upload &amp; Process"
                    CssClass="btn btn-success rounded-pill px-4 fw-semibold"
                    OnClick="btnBulkUpload_Click" />
            </div>
        </div>
    </div>
</div>

<%-- ══ RE-ENROL MODAL ════════════════════════════════════════ --%>
<div class="modal fade" id="ReenrolModal" tabindex="-1" aria-hidden="true" data-bs-backdrop="static">
    <div class="modal-dialog modal-lg modal-dialog-scrollable tch-modal-dialog">
        <div class="modal-content rounded-4 border-0 shadow-lg tch-modal-content">
            <div class="modal-header bg-warning text-dark">
                <h5 class="modal-title fw-bold"><i class="fa fa-sync me-2"></i>Re-Enrol Teachers</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body p-3 p-md-4">
                <p class="text-muted small mb-3">Select teachers from a previous session to re-enrol.</p>
                <div class="row g-3 mb-3">
                    <div class="col-12 col-md-6">
                        <label class="form-label fw-semibold small">Previous Session <span class="req">*</span></label>
                        <asp:DropDownList ID="ddlPrevSession" runat="server" CssClass="form-select"
                            AutoPostBack="true" OnSelectedIndexChanged="ddlPrevSession_Changed">
                            <asp:ListItem Value="0" Text="-- Select Previous Session --" />
                        </asp:DropDownList>
                    </div>
                    <div class="col-12 col-md-6">
                        <label class="form-label fw-semibold small">New Stream (optional)</label>
                        <asp:DropDownList ID="ddlReenrolStream" runat="server" CssClass="form-select">
                            <asp:ListItem Value="0" Text="-- Keep Same --" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="card border-0 rounded-3" style="background:#f8fafc">
                    <div class="card-header bg-transparent border-0 d-flex justify-content-between align-items-center py-2">
                        <span class="fw-semibold small">Teachers from Previous Session</span>
                        <div class="form-check form-switch mb-0">
                            <input class="form-check-input" type="checkbox" id="chkSelAll"
                                   onchange="toggleAll(this)" />
                            <label class="form-check-label small" for="chkSelAll">Select All</label>
                        </div>
                    </div>
                    <div class="card-body py-2" style="max-height:260px;overflow-y:auto">
                        <asp:Repeater ID="rptPrevTeachers" runat="server">
                            <ItemTemplate>
                                <div class="d-flex align-items-center gap-2 py-1 border-bottom">
                                    <input type="checkbox" class="form-check-input reenrol-chk"
                                           value='<%# Eval("UserId") %>' id='rchk_<%# Eval("UserId") %>' />
                                    <label for='rchk_<%# Eval("UserId") %>' class="mb-0 small flex-fill">
                                        <strong><%# Eval("FullName") %></strong>
                                        <span class="text-muted ms-2"><%# Eval("Username") %></span>
                                        <span class="acad-tag tag-stream ms-2"><%# Eval("StreamName") %></span>
                                    </label>
                                </div>
                            </ItemTemplate>
                            <FooterTemplate>
                                <asp:Panel ID="pnlNoPrev" runat="server"
                                           Visible='<%# rptPrevTeachers.Items.Count == 0 %>'>
                                    <p class="text-muted small py-3 text-center mb-0">Select a previous session.</p>
                                </asp:Panel>
                            </FooterTemplate>
                        </asp:Repeater>
                    </div>
                </div>
            </div>
            <div class="modal-footer border-0 px-3 px-md-4 pb-4 pt-0 gap-2">
                <button type="button" class="btn btn-outline-secondary rounded-pill px-4"
                        data-bs-dismiss="modal">Cancel</button>
                <asp:Button ID="btnReenrol" runat="server"
                    Text="Re-Enrol Selected"
                    CssClass="btn btn-warning rounded-pill px-4 fw-semibold text-dark"
                    OnClick="btnReenrol_Click"
                    OnClientClick="return gatherReenrolIds();" />
            </div>
        </div>
    </div>
</div>

<%-- ══ STYLES ════════════════════════════════════════════════ --%>
<style>
:root { --pri:#4f46e5; --pri-lt:#eef2ff; --rad:16px; }

/* ── Header ── */
.tch-hdr-icon {
    width:36px;height:36px;border-radius:10px;
    background:var(--pri-lt);color:var(--pri);
    display:inline-flex;align-items:center;justify-content:center;flex-shrink:0;
}
.dot-sep { width:5px;height:5px;background:#cbd5e1;border-radius:50%;display:inline-block; }

/* ── Stats ── */
.tch-stat { border-radius:var(--rad);transition:transform .2s,box-shadow .2s;height:100%; }
.tch-stat:hover { transform:translateY(-3px);box-shadow:0 6px 20px rgba(0,0,0,.1)!important; }
.tch-ico { width:40px;height:40px;border-radius:10px;display:flex;align-items:center;justify-content:center;flex-shrink:0; }
.tch-stat-lbl { font-size:11px; }

/* ── Filter bar ── */
.tch-filter-bar { background:#fff; }
.tch-filter-row {
    display:flex;align-items:center;gap:10px;
    width:100%;flex-wrap:wrap;           /* wrap on small screens */
}
.tch-srch-wrap {
    position:relative;flex:1;min-width:160px;
}
.tch-srch-ico {
    position:absolute;top:50%;left:10px;
    transform:translateY(-50%);color:#94a3b8;font-size:12px;z-index:2;
}
.tch-srch-inp { padding-left:32px;border-radius:8px;height:36px;font-size:13px;width:100%; }
.tch-flt-sel  { height:36px;border-radius:8px;font-size:13px;padding:0 10px;min-width:120px;flex-shrink:0; }
.tch-record-count { margin-left:auto;white-space:nowrap;font-size:13px;font-weight:600;color:#64748b; }

/* ── Table ── */
.tch-tbl-hdr th {
    background:linear-gradient(135deg,#4f46e5,#6366f1)!important;
    color:#fff!important;border:none!important;
    padding:12px 14px!important;font-weight:600;font-size:13px;white-space:nowrap;
}
.table-responsive { overflow-x:auto;-webkit-overflow-scrolling:touch; }
.modern-table     { min-width:700px; }
.modern-table td  { padding:10px 14px;font-size:13px;border-bottom:1px solid #f1f5f9!important;vertical-align:middle; }
.tch-av {
    width:34px;height:34px;border-radius:50%;
    display:flex;align-items:center;justify-content:center;
    font-weight:700;font-size:11px;color:#fff;flex-shrink:0;
}
.tbl-act-cell { white-space:nowrap;min-width:160px; }
.tbl-act-btn {
    width:28px;height:28px;border-radius:7px;border:none;
    display:inline-flex;align-items:center;justify-content:center;
    font-size:11px;cursor:pointer;transition:transform .15s;text-decoration:none;flex-shrink:0;
}
.tbl-act-btn:hover { transform:scale(1.1); }
.act-view   { background:#dbeafe;color:#1d4ed8; }
.act-edit   { background:#e0f2fe;color:#0369a1; }
.act-key    { background:#fef9c3;color:#92400e; }
.act-toggle { background:#f0fdf4;color:#15803d; }
.act-del    { background:#fee2e2;color:#b91c1c; }

/* ── Academic tags ── */
.acad-tag    { display:inline-block;padding:2px 8px;border-radius:6px;font-size:10px;font-weight:600;white-space:nowrap; }
.tag-stream  { background:#eef2ff;color:#4f46e5; }
.tag-desig   { background:#e0f2fe;color:#0369a1; }

/* ── Pagination ── */
.tch-page-btn {
    display:inline-flex;align-items:center;justify-content:center;
    min-width:34px;height:34px;padding:0 10px;border-radius:8px;
    border:1px solid #e2e8f0;background:#fff;font-size:13px;color:#475569;
    text-decoration:none;transition:.15s;line-height:1;
}
.tch-page-btn:hover          { background:var(--pri);color:#fff;border-color:var(--pri); }
.tch-page-btn.active         { background:var(--pri);color:#fff;border-color:var(--pri);font-weight:600; }
.tch-page-btn.disabled,
.tch-page-btn[disabled]      { opacity:.4;pointer-events:none;cursor:default; }

/* ══ MODAL — always below fixed header ══
   Bootstrap's .modal uses `padding-top` to push content down;
   We use it to clear the fixed navbar (~60px) + a bit of breathing room. */
.modal { padding-top:68px !important; }

/* Our modal dialog: fills available height minus header offset */
.tch-modal-dialog {
    margin-top:6px !important;
    margin-bottom:12px !important;
    max-width:860px;
}
/* Content box: scrolls internally */
.tch-modal-content {
    border:none !important;
    border-radius:16px !important;
    display:flex;
    flex-direction:column;
    /* Never exceed viewport, accounting for header offset */
    max-height:calc(100vh - 96px);
    overflow:hidden;
}
.tch-modal-content .modal-body {
    overflow-y:auto;
    overflow-x:hidden;
    flex:1 1 auto;
}

/* ── Modal header ── */
.tch-modal-hdr {
    background:linear-gradient(135deg,#4f46e5,#6366f1);
    border-radius:16px 16px 0 0 !important;
    flex-shrink:0;
}

/* ── Wizard ── */
.tch-wiz-nav {
    list-style:none;padding-left:0;
    border-bottom:2px solid #f1f5f9;margin:0;
    display:flex;flex-wrap:nowrap;overflow-x:auto;
    scrollbar-width:none;flex-shrink:0;
}
.tch-wiz-nav::-webkit-scrollbar { display:none; }
.tch-wiz-nav .nav-item { margin-bottom:-2px;flex-shrink:0; }
.tch-wiz-tab {
    display:flex;align-items:center;gap:6px;
    padding:10px 14px;font-size:13px;font-weight:500;
    color:#64748b;border-bottom:2px solid transparent;
    text-decoration:none;transition:.15s;white-space:nowrap;
}
.tch-wiz-tab:hover  { color:var(--pri); }
.tch-wiz-tab.active { color:var(--pri);border-bottom-color:var(--pri); }
.tab-num {
    width:20px;height:20px;border-radius:50%;
    background:#e2e8f0;color:#64748b;font-size:11px;
    display:inline-flex;align-items:center;justify-content:center;font-weight:700;flex-shrink:0;
}
.tch-wiz-tab.active .tab-num { background:var(--pri);color:#fff; }

/* ── Form ── */
.form-label  { font-size:13px;margin-bottom:4px; }
.form-control,.form-select { font-size:13px;border-radius:8px; }
.form-control:focus,.form-select:focus { border-color:var(--pri);box-shadow:0 0 0 3px rgba(79,70,229,.15); }
.req         { color:#dc2626; }
.form-err    { color:#dc2626;font-size:11px;margin-top:3px;min-height:14px; }

/* ── Password strength ── */
.pwd-strength { height:4px;background:#e2e8f0;border-radius:2px; }
.pwd-fill     { height:100%;border-radius:2px;transition:width .3s,background .3s; }

/* ── Profile viewer ── */
#teacherProfileBody { overflow-x:hidden;word-break:break-word; }
.pf-field  { display:flex;flex-direction:column;gap:2px;padding:8px 10px;background:#f8fafc;border-radius:8px;min-height:64px;height:100%;border:1px solid #eef2f7;transition:.2s; }
.pf-field:hover { transform:translateY(-2px);box-shadow:0 4px 14px rgba(0,0,0,.06); }
.pf-lbl    { font-size:10px;font-weight:600;color:#94a3b8;text-transform:uppercase;letter-spacing:.5px; }
.pf-val    { font-size:13px;font-weight:500;color:#1e293b; }

/* ── Bulk result ── */
.bulk-res-box { border:1px solid #e2e8f0;border-radius:10px;padding:14px;font-size:13px;max-height:200px;overflow-y:auto;background:#fafafa; }

/* ── Toast ── */
.toast             { min-width:280px;border-radius:12px!important; }
.toast.bg-success  { background:#16a34a!important;color:#fff!important; }
.toast.bg-danger   { background:#dc2626!important;color:#fff!important; }
.toast.bg-warning  { background:#d97706!important;color:#fff!important; }

/* ════════════════════════════════════════
   RESPONSIVE BREAKPOINTS
════════════════════════════════════════ */

/* ── Large tablet / small laptop (≤1100px) ── */
@media (max-width:1100px) {
    .tch-col-empid { display:none !important; }   /* hide Emp ID col */
}

/* ── Tablet (≤900px) ── */
@media (max-width:900px) {
    /* Modal: nearly full viewport width */
    .tch-modal-dialog { max-width:95vw !important; }
    .tch-modal-content { max-height:calc(100vh - 88px); }

    /* Filter row wraps but stays usable */
    .tch-srch-wrap { min-width:140px; }
    .tch-flt-sel   { min-width:110px; }
}

/* ── Mobile landscape / small tablet (≤768px) ── */
@media (max-width:768px) {
    /* Header */
    .tch-hdr-icon { width:30px;height:30px; }
    h4 { font-size:1.05rem; }

    /* Header action buttons: keep icons, hide text on very small */
    .tch-btn-text { font-size:12px; }

    /* Stats: 2 per row */
    .col-6.col-sm-3 { flex:0 0 50%;max-width:50%; }
    .tch-ico { width:34px;height:34px;font-size:14px; }

    /* Filter bar */
    .tch-filter-bar { padding:.625rem .875rem !important; }
    .tch-filter-row { gap:8px; }
    .tch-record-count { display:none; }

    /* Table */
    .modern-table    { min-width:580px; }
    .modern-table td { padding:8px 10px;font-size:12px; }
    .tch-tbl-hdr th  { padding:10px 10px !important;font-size:11px; }
    .tch-av          { width:28px;height:28px;font-size:10px; }
    .tbl-act-btn     { width:24px;height:24px;font-size:10px; }
    .tbl-act-cell    { min-width:130px; }

    /* Modal: full width, below header */
    .modal { padding-top:56px !important; }
    .tch-modal-dialog {
        max-width:calc(100vw - 12px) !important;
        margin-left:6px !important;
        margin-right:6px !important;
    }
    .tch-modal-content { max-height:calc(100vh - 76px); }

    /* Wizard tabs smaller */
    .tch-wiz-tab { padding:8px 10px;font-size:12px; }

    /* Footer buttons stack */
    .modal-footer .d-flex.flex-wrap { gap:6px; }
    .modal-footer .btn { flex:1;min-width:80px;justify-content:center;font-size:12px; }

    /* Form: 2-col on tablet */
    .col-12.col-sm-6.col-md-4 { flex:0 0 50%;max-width:50%; }
    .col-12.col-sm-4           { flex:0 0 50%;max-width:50%; }
}

/* ── Mobile portrait (≤560px) ── */
@media (max-width:560px) {
    /* Stats compact */
    .tch-stat { padding:.75rem !important; }

    /* Filter: wrap to two rows */
    .tch-srch-wrap { flex:1 1 100%;order:1; }
    .tch-flt-sel   { flex:1;min-width:100px;order:2; }

    /* Table */
    .modern-table { min-width:480px; }

    /* Modal */
    .modal { padding-top:50px !important; }
    .tch-modal-content { max-height:calc(100vh - 68px);border-radius:12px !important; }
    .modal-header  { padding:.75rem 1rem !important; }
    .modal-body    { padding:.75rem !important; }
    .modal-footer  { padding:.625rem .875rem !important; }

    /* Wizard: show number only */
    .tab-txt { display:none; }
    .tch-wiz-tab { padding:9px 12px; }

    /* Form: all single column */
    .col-12.col-sm-6.col-md-4,
    .col-12.col-sm-6,
    .col-12.col-sm-4,
    .col-12.col-md-4,
    .col-12.col-md-6 { flex:0 0 100%;max-width:100%; }

    /* Toast full width */
    .toast-container { left:8px !important;right:8px !important; }
    .toast { min-width:0;width:100%; }

    /* Pagination */
    .tch-page-btn { min-width:30px;height:30px;font-size:12px; }
}

/* ── Extra small (≤380px) ── */
@media (max-width:380px) {
    h4 { font-size:.95rem; }
    .tch-btn-text { display:none; }     /* icon-only header buttons */
    .tch-stat .fw-bold.fs-5 { font-size:.9rem !important; }
    .tbl-act-btn { width:22px;height:22px;font-size:9px; }
    .modal { padding-top:44px !important; }
    .tch-modal-content { max-height:calc(100vh - 60px); }
}
</style>

<%-- ══ SCRIPTS (all original JS intact) ═══════════════════════════ --%>
<script>
    /* ── Role guard ─────────────────────────────────────────── */
    var isSuperAdmin = '<%= Session["Role"]?.ToString() %>' === 'SuperAdmin';
    if (isSuperAdmin) {
        ['<%= pnlAddBtn.ClientID %>','<%= pnlBulkBtn.ClientID %>','<%= pnlReenrolBtn.ClientID %>']
            .forEach(function (id) { var el = document.getElementById(id); if (el) el.style.display = 'none'; });
    }

    /* ── Toast ──────────────────────────────────────────────── */
    function showToast(msg, type) {
        var icons = { success: 'check-circle', danger: 'times-circle', warning: 'exclamation-triangle', info: 'info-circle' };
        var t = document.getElementById('liveToast');
        var m = document.getElementById('toastMsg');
        m.innerHTML = '<i class="fa fa-' + (icons[type] || 'info-circle') + ' me-2"></i>' + msg;
        t.className = 'toast align-items-center border-0 shadow-lg text-white bg-' + (type || 'success');
        bootstrap.Toast.getOrCreateInstance(t, { delay: 5000 }).show();
    }
    function serverToast(msg, type) { showToast(msg, type); }

    /* ── Client-side table search ───────────────────────────── */
    function clientSearch(val) {
        val = (val || '').toLowerCase().trim();
        document.querySelectorAll('#<%= gvTeachers.ClientID %> tbody tr').forEach(function (r) {
            r.style.display = (!val || r.innerText.toLowerCase().includes(val)) ? '' : 'none';
        });
    }

    /* ── Wizard ─────────────────────────────────────────────── */
    var curTab = 1, totalTabs = 3;
    function gotoTab(n) {
        if (n < 1 || n > totalTabs) return;
        curTab = n;
        for (var i = 1; i <= totalTabs; i++) {
            var p = document.getElementById('tab' + i);
            if (p) p.style.display = (i === n) ? '' : 'none';
        }
        document.querySelectorAll('.tch-wiz-tab').forEach(function (t, idx) {
            t.classList.toggle('active', idx + 1 === n);
        });
        document.getElementById('btnWizPrev').style.display = n > 1 ? '' : 'none';
        document.getElementById('btnWizNext').style.display = n < totalTabs ? '' : 'none';
        document.getElementById('<%= btnSaveTeacher.ClientID %>').style.display = n === totalTabs ? '' : 'none';
    }
    function wizNav(dir) {
        if (dir === 1 && !validateCurTab()) return;
        gotoTab(curTab + dir);
    }

    /* ── Modal openers ──────────────────────────────────────── */
    function openAddModal() {
        if (isSuperAdmin) { showToast('SuperAdmin has view-only access.', 'warning'); return; }
        clearTeacherForm();
        document.getElementById('modalTitleText').textContent = 'Add New Teacher';
        document.getElementById('modalSubText').textContent = 'Fill all required fields marked *';
        document.getElementById('<%= btnSaveTeacher.ClientID %>').value = 'Add Teacher';
        gotoTab(1);
        new bootstrap.Modal(document.getElementById('TeacherModal')).show();
    }
    function openModal() {
        document.getElementById('modalTitleText').textContent = 'Edit Teacher';
        document.getElementById('modalSubText').textContent = 'Update teacher details';
        document.getElementById('<%= btnSaveTeacher.ClientID %>').value = 'Update Teacher';
        gotoTab(1);
        new bootstrap.Modal(document.getElementById('TeacherModal')).show();
    }
    function openBulkModal() {
        if (isSuperAdmin) { showToast('SuperAdmin has view-only access.', 'warning'); return; }
        new bootstrap.Modal(document.getElementById('BulkModal')).show();
    }
    function openReenrolModal() {
        if (isSuperAdmin) { showToast('SuperAdmin has view-only access.', 'warning'); return; }
        new bootstrap.Modal(document.getElementById('ReenrolModal')).show();
    }

    /* ── View: open profile + set Teacher Details link ──────── */
    function openViewModal(html, userId) {
        document.getElementById('teacherProfileBody').innerHTML = html;
        var link = document.getElementById('btnGoToDetails');
        if (link) link.href = 'TeacherDetails.aspx?userId=' + userId;
        new bootstrap.Modal(document.getElementById('ViewTeacherModal')).show();
    }

    /* ── Clear form ─────────────────────────────────────────── */
    function clearTeacherForm() {
        document.getElementById('<%= hfTeacherUserId.ClientID %>').value = '';
        ['<%= txtFullName.ClientID %>','<%= txtUsername.ClientID %>','<%= txtEmail.ClientID %>',
         '<%= txtPassword.ClientID %>','<%= txtContact.ClientID %>','<%= txtEmpId.ClientID %>',
         '<%= txtDesignation.ClientID %>','<%= txtExperience.ClientID %>',
         '<%= txtQualification.ClientID %>','<%= txtJoinDate.ClientID %>',
         '<%= txtDOB.ClientID %>','<%= txtFatherName.ClientID %>','<%= txtMotherName.ClientID %>',
         '<%= txtEmgName.ClientID %>','<%= txtEmgContact.ClientID %>','<%= txtAddress.ClientID %>',
         '<%= txtCity.ClientID %>','<%= txtCountry.ClientID %>','<%= txtPincode.ClientID %>',
         '<%= txtSkills.ClientID %>'].forEach(function (id) {
            var el = document.getElementById(id);
            if (el) { el.value = ''; el.classList.remove('is-invalid', 'is-valid'); }
        });
        document.querySelectorAll('.form-err').forEach(function (e) { e.textContent = ''; });
        document.getElementById('pwdBar').style.display = 'none';
        document.getElementById('pwdTxt').textContent = '';
    }

    /* ── Validation helpers ─────────────────────────────────── */
    function setE(elId, errId, msg) {
        var el = document.getElementById(elId), e = document.getElementById(errId);
        if (msg) { if (e) e.textContent = msg; if (el) el.classList.add('is-invalid'); return false; }
        if (e) e.textContent = ''; if (el) { el.classList.remove('is-invalid'); el.classList.add('is-valid'); }
        return true;
    }
    function validateCurTab() { return curTab === 1 ? validateTab1() : curTab === 2 ? validateTab2() : true; }

    function validateTab1() {
        var ok = true;
        var isEdit = document.getElementById('<%= hfTeacherUserId.ClientID %>').value !== '';
        if (!setE('<%= txtFullName.ClientID %>', 'errFullName',
            document.getElementById('<%= txtFullName.ClientID %>').value.trim().length < 3
                ? 'Full name must be at least 3 characters.' : '')) ok = false;
        if (!setE('<%= txtUsername.ClientID %>', 'errUsername',
            !/^[a-z0-9_]{3,50}$/.test(document.getElementById('<%= txtUsername.ClientID %>').value.trim())
                ? 'Lowercase, numbers, underscore only (3–50 chars).' : '')) ok = false;
        if (!setE('<%= txtEmail.ClientID %>', 'errEmail',
            !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(document.getElementById('<%= txtEmail.ClientID %>').value.trim())
                ? 'Enter a valid email address.' : '')) ok = false;
        if (!isEdit) {
            var pwd = document.getElementById('<%= txtPassword.ClientID %>').value;
            var pwdOk = pwd.length >= 8 && /[A-Z]/.test(pwd) && /[0-9]/.test(pwd);
            if (!setE('<%= txtPassword.ClientID %>', 'errPassword',
                !pwdOk ? 'Password must be 8+ chars with uppercase and a number.' : '')) ok = false;
        }
        if (!setE('<%= txtContact.ClientID %>', 'errContact',
            !/^[0-9+]{10,15}$/.test(document.getElementById('<%= txtContact.ClientID %>').value.trim())
                ? 'Enter a valid 10–15 digit contact number.' : '')) ok = false;
        if (!setE('<%= txtEmpId.ClientID %>', 'errEmpId',
            document.getElementById('<%= txtEmpId.ClientID %>').value.trim().length < 2
                ? 'Employee ID is required (min 2 chars).' : '')) ok = false;
        return ok;
    }

    function validateTab2() {
        var ok = true;
        var stream = document.getElementById('<%= ddlStream.ClientID %>');
        var desig  = document.getElementById('<%= txtDesignation.ClientID %>');
        var exp    = document.getElementById('<%= txtExperience.ClientID %>');
        var join   = document.getElementById('<%= txtJoinDate.ClientID %>');
        if (!setE('<%= ddlStream.ClientID %>', 'errStream',
            (!stream.value || stream.value === '0') ? 'Please select a stream.' : '')) ok = false;
        if (!setE('<%= txtDesignation.ClientID %>', 'errDesig',
            desig.value.trim().length < 2 ? 'Designation is required.' : '')) ok = false;
        if (!setE('<%= txtExperience.ClientID %>', 'errExp',
            (!exp.value || parseInt(exp.value) < 0 || parseInt(exp.value) > 60)
                ? 'Enter valid experience (0–60 years).' : '')) ok = false;
        var joinVal = join.value;
        if (!joinVal) {
            if (!setE('<%= txtJoinDate.ClientID %>', 'errJoinDate', 'Joining date is required.')) ok = false;
        } else {
            var jd = new Date(joinVal), now = new Date();
            var minJoin = new Date(); minJoin.setFullYear(now.getFullYear() - 50);
            var maxJoin = new Date(); maxJoin.setFullYear(now.getFullYear() + 1);
            if (jd < minJoin || jd > maxJoin)
                { if (!setE('<%= txtJoinDate.ClientID %>', 'errJoinDate', 'Joining date must be within the last 50 years.')) ok = false; }
            else setE('<%= txtJoinDate.ClientID %>', 'errJoinDate', '');
        }
        return ok;
    }

    function finalValidate() {
        if (isSuperAdmin) { showToast('SuperAdmin has view-only access.', 'warning'); return false; }
        var ok     = true;
        var gender = document.getElementById('<%= ddlGender.ClientID %>');
        var dob    = document.getElementById('<%= txtDOB.ClientID %>');
        var emgN   = document.getElementById('<%= txtEmgName.ClientID %>');
        var emgC   = document.getElementById('<%= txtEmgContact.ClientID %>');
        var addr   = document.getElementById('<%= txtAddress.ClientID %>');
        if (!setE('<%= ddlGender.ClientID %>', 'errGender', !gender.value ? 'Select gender.' : '')) ok = false;
        if (!dob.value) {
            if (!setE('<%= txtDOB.ClientID %>', 'errDOB', 'Date of birth is required.')) ok = false;
        } else {
            var d = new Date(dob.value), now = new Date();
            var age = now.getFullYear() - d.getFullYear();
            var m = now.getMonth() - d.getMonth();
            if (m < 0 || (m === 0 && now.getDate() < d.getDate())) age--;
            if (age < 18 || age > 80)
                { if (!setE('<%= txtDOB.ClientID %>', 'errDOB', 'Teacher age must be between 18 and 80 years.')) ok = false; }
            else setE('<%= txtDOB.ClientID %>', 'errDOB', '');
        }
        if (!setE('<%= txtEmgName.ClientID %>',    'errEmgName',    !emgN.value.trim() ? 'Emergency contact name required.' : '')) ok = false;
        if (!setE('<%= txtEmgContact.ClientID %>', 'errEmgContact', !/^[0-9+]{10,15}$/.test(emgC.value.trim()) ? 'Valid emergency contact required.' : '')) ok = false;
        if (!setE('<%= txtAddress.ClientID %>',    'errAddress',    !addr.value.trim() ? 'Address is required.' : '')) ok = false;
        if (!ok) showToast('Please fix errors before saving.', 'danger');
        return ok;
    }

    /* ── Username auto-generate ─────────────────────────────── */
    function autoUsername() {
        var name = document.getElementById('<%= txtFullName.ClientID %>').value.trim();
        var user = document.getElementById('<%= txtUsername.ClientID %>');
        if (!user.value) {
            var gen = name.toLowerCase().replace(/\s+/g, '_').replace(/[^a-z0-9_]/g, '').substring(0, 20);
            if (gen.length >= 3) user.value = gen + new Date().getFullYear().toString().slice(-2);
        }
    }

    /* ── Password visibility + strength ─────────────────────── */
    function togglePwd(btn) {
        var inp = btn.previousElementSibling;
        inp.type = inp.type === 'text' ? 'password' : 'text';
        btn.innerHTML = '<i class="fa fa-' + (inp.type === 'text' ? 'eye-slash' : 'eye') + '"></i>';
    }
    function checkPwdStrength(v) {
        var bar = document.getElementById('pwdBar'), fill = document.getElementById('pwdFill'), txt = document.getElementById('pwdTxt');
        if (!v) { bar.style.display = 'none'; txt.textContent = ''; return; }
        bar.style.display = '';
        var s = 0;
        if (v.length >= 8) s++; if (v.length >= 12) s++; if (/[A-Z]/.test(v)) s++; if (/[0-9]/.test(v)) s++; if (/[^A-Za-z0-9]/.test(v)) s++;
        var levels = [{w:20,c:'#ef4444',l:'Weak'},{w:40,c:'#f97316',l:'Fair'},{w:60,c:'#eab308',l:'Medium'},{w:80,c:'#84cc16',l:'Strong'},{w:100,c:'#22c55e',l:'Very Strong'}];
        var x = levels[Math.min(s, 4)];
        fill.style.width = x.w + '%'; fill.style.background = x.c; txt.textContent = x.l; txt.style.color = x.c;
    }

    /* ── Re-enrol helpers ───────────────────────────────────── */
    function toggleAll(chk) {
        document.querySelectorAll('.reenrol-chk').forEach(function (c) { c.checked = chk.checked; });
    }
    function gatherReenrolIds() {
        if (isSuperAdmin) { showToast('SuperAdmin has view-only access.', 'warning'); return false; }
        var ids = Array.from(document.querySelectorAll('.reenrol-chk:checked')).map(function (c) { return c.value; });
        if (!ids.length) { showToast('Please select at least one teacher to re-enrol.', 'warning'); return false; }
        document.getElementById('<%= hfReenrolIds.ClientID %>').value = ids.join(',');
        return true;
    }

    /* ── Default join date = today ──────────────────────────── */
    document.addEventListener('DOMContentLoaded', function () {
        var jd = document.getElementById('<%= txtJoinDate.ClientID %>');
        if (jd && !jd.value) jd.value = new Date().toISOString().split('T')[0];
    });
</script>

</asp:Content>

