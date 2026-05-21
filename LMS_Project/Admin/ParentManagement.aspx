<%@ Page Title="Parent Management" Language="C#"
    MasterPageFile="~/Admin/AdminMaster.master"
    AutoEventWireup="true" CodeBehind="ParentManagement.aspx.cs"
    Inherits="LearningManagementSystem.Admin.ParentManagement" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server" />

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

<!-- ══ HIDDEN STATE ══ -->
<asp:HiddenField ID="hfParentUserId"  runat="server" />
<asp:HiddenField ID="hfReenrolIds"    runat="server" />
<asp:HiddenField ID="hfSelectedStuds" runat="server" />

<!-- ══ TOAST ══ -->
<div class="toast-container position-fixed p-3"
     style="top:70px;right:16px;z-index:99999;">
    <div id="liveToast" class="toast align-items-center border-0 shadow-lg"
         role="alert" aria-atomic="true">
        <div class="d-flex">
            <div class="toast-body fw-semibold" id="toastMsg" style="font-size:13px;"></div>
            <button type="button" class="btn-close me-2 m-auto" data-bs-dismiss="toast"></button>
        </div>
    </div>
</div>

<!-- ══ PAGE HEADER ══ -->
<div class="par-page-header mb-3">
    <div class="par-header-row">

        <!-- Left: title -->
        <div class="par-title-block">
            <h4 class="fw-bold mb-1 d-flex align-items-center gap-2">
                <span class="par-header-icon"><i class="fa fa-users"></i></span>
                Parent &amp; Guardian Management
            </h4>
            <div class="text-muted small d-flex align-items-center flex-wrap gap-2">
                <span>Manage parents, guardians &amp; student links</span>
                <span class="dot-sep"></span>
                <asp:Label ID="lblSessionName" runat="server"
                    CssClass="badge bg-primary bg-opacity-10 text-primary px-2 py-1" />
                <asp:Label ID="lblSuperAdminBadge" runat="server" Visible="false"
                    CssClass="badge bg-warning text-dark">
                    <i class="fa fa-eye me-1"></i>View Only
                </asp:Label>
            </div>
        </div>

        <!-- Right: action buttons (Bulk + Add) -->
        <div class="par-header-actions">
            <asp:Panel ID="pnlBulkBtn" runat="server">
                <button type="button"
                    class="btn btn-outline-success btn-sm rounded-pill px-3 fw-semibold par-btn-icon"
                    onclick="openBulkModal()">
                    <i class="fa fa-file-excel me-1"></i><span class="btn-txt">Bulk Upload</span>
                </button>
            </asp:Panel>
            <asp:Panel ID="pnlAddBtn" runat="server">
                <button type="button"
                    class="btn btn-primary rounded-pill px-4 fw-semibold shadow-sm par-btn-icon"
                    onclick="openAddModal()">
                    <i class="fa fa-plus me-1"></i><span class="btn-txt">Add Parent</span>
                </button>
            </asp:Panel>
        </div>

    </div>
</div>

<!-- ══ STATS ══ -->
<div class="row g-3 mb-4">
    <div class="col-6 col-sm-3">
        <div class="par-stat-card card border-0 shadow-sm p-3">
            <div class="d-flex align-items-center gap-3">
                <div class="par-icon-box bg-primary bg-opacity-10 text-primary"><i class="fa fa-users"></i></div>
                <div>
                    <div class="par-stat-lbl text-muted">Total</div>
                    <div class="par-stat-val fw-bold fs-5"><asp:Label ID="lblTotal" runat="server" Text="0"/></div>
                </div>
            </div>
        </div>
    </div>
    <div class="col-6 col-sm-3">
        <div class="par-stat-card card border-0 shadow-sm p-3">
            <div class="d-flex align-items-center gap-3">
                <div class="par-icon-box bg-success bg-opacity-10 text-success"><i class="fa fa-user-check"></i></div>
                <div>
                    <div class="par-stat-lbl text-muted">Active</div>
                    <div class="par-stat-val fw-bold fs-5 text-success"><asp:Label ID="lblActive" runat="server" Text="0"/></div>
                </div>
            </div>
        </div>
    </div>
    <div class="col-6 col-sm-3">
        <div class="par-stat-card card border-0 shadow-sm p-3">
            <div class="d-flex align-items-center gap-3">
                <div class="par-icon-box bg-secondary bg-opacity-10 text-secondary"><i class="fa fa-user-times"></i></div>
                <div>
                    <div class="par-stat-lbl text-muted">Inactive</div>
                    <div class="par-stat-val fw-bold fs-5 text-secondary"><asp:Label ID="lblInactive" runat="server" Text="0"/></div>
                </div>
            </div>
        </div>
    </div>
    <div class="col-6 col-sm-3">
        <div class="par-stat-card card border-0 shadow-sm p-3">
            <div class="d-flex align-items-center gap-3">
                <div class="par-icon-box bg-info bg-opacity-10 text-info"><i class="fa fa-link"></i></div>
                <div>
                    <div class="par-stat-lbl text-muted">Student Links</div>
                    <div class="par-stat-val fw-bold fs-5 text-info"><asp:Label ID="lblLinks" runat="server" Text="0"/></div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- ══ FILTER BAR — search + status filter above table ══ -->
<div class="par-filter-bar mb-3">
    <!-- Search -->
    <div class="par-search-wrap">
        <i class="fa fa-search par-search-icon"></i>
        <input type="text" id="txtSearchClient"
               class="form-control par-search-input"
               placeholder="Search parents, students..."
               onkeyup="clientSearch(this.value)" />
    </div>

    <!-- Status filter -->
    <asp:DropDownList ID="ddlFilterStatus" runat="server"
        CssClass="form-select par-filter-sel"
        AutoPostBack="true"
        OnSelectedIndexChanged="ddlFilterStatus_Changed">
        <asp:ListItem Value="All"      Text="All Status" />
        <asp:ListItem Value="Active"   Text="Active" />
        <asp:ListItem Value="Inactive" Text="Inactive" />
    </asp:DropDownList>

    <!-- Record count -->
    <span class="par-record-count ms-auto" id="recordCount"></span>
</div>

<!-- ══ TABLE ══ -->
<div class="card shadow-sm border-0 rounded-4 overflow-hidden">
    <div class="table-responsive">
        <asp:GridView ID="gvParents" runat="server"
            CssClass="table table-hover align-middle par-table mb-0"
            AutoGenerateColumns="false"
            OnRowCommand="gvParents_RowCommand"
            EnableViewState="true"
            GridLines="None">
            <HeaderStyle CssClass="par-table-header" />
            <EmptyDataTemplate>
                <div class="text-center py-5">
                    <i class="fa fa-users fa-3x text-muted mb-3 d-block"></i>
                    <p class="fw-semibold text-muted mb-1">No parents found</p>
                    <p class="text-muted small">Click <strong>Add Parent</strong> to register a parent or guardian.</p>
                </div>
            </EmptyDataTemplate>
            <Columns>
                <asp:TemplateField HeaderText="#" ItemStyle-Width="38px">
                    <ItemTemplate>
                        <span class="text-muted small"><%# Container.DataItemIndex + 1 %></span>
                    </ItemTemplate>
                </asp:TemplateField>

                <asp:TemplateField HeaderText="Parent / Guardian">
                    <ItemTemplate>
                        <div class="d-flex align-items-center gap-2">
                            <div class="par-tbl-avatar"
                                 style="background:<%# GetAvatarColor(Eval("ParentName").ToString()) %>">
                                <%# GetInitials(Eval("ParentName").ToString()) %>
                            </div>
                            <div>
                                <div class="fw-semibold small"><%# Eval("ParentName") %></div>
                                <div class="text-muted" style="font-size:11px"><%# Eval("Username") %></div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:TemplateField>

                <asp:TemplateField HeaderText="Linked Student(s)" ItemStyle-CssClass="par-col-students">
                    <HeaderStyle CssClass="par-col-students" />
                    <ItemTemplate>
                        <div class="d-flex flex-wrap gap-1">
                            <%# BuildStudentTags(Eval("StudentNames").ToString(),
                                                 Eval("RollNumbers").ToString(),
                                                 Eval("StreamNames").ToString()) %>
                        </div>
                    </ItemTemplate>
                </asp:TemplateField>

                <asp:BoundField DataField="Email"     HeaderText="Email"   ItemStyle-CssClass="par-col-email" HeaderStyle-CssClass="par-col-email" />
                <asp:BoundField DataField="ContactNo" HeaderText="Contact" ItemStyle-CssClass="par-col-contact" HeaderStyle-CssClass="par-col-contact" />

                <asp:TemplateField HeaderText="Relation" ItemStyle-CssClass="par-col-relation">
                    <HeaderStyle CssClass="par-col-relation" />
                    <ItemTemplate>
                        <span class="par-rel-badge"><%# Eval("Relation") %></span>
                    </ItemTemplate>
                </asp:TemplateField>

                <asp:TemplateField HeaderText="Actions" ItemStyle-CssClass="par-act-cell">
                    <ItemTemplate>
                        <div class="d-flex gap-1 flex-nowrap">
                            <asp:LinkButton runat="server" CommandName="SendCreds"
                                CommandArgument='<%# Eval("ParentUserId") %>'
                                CssClass="par-act-btn act-creds" title="Send Credentials">
                                <i class="fa fa-envelope"></i>
                            </asp:LinkButton>
                            <asp:LinkButton runat="server" CommandName="EditRow"
                                CommandArgument='<%# Eval("ParentUserId") %>'
                                CssClass="par-act-btn act-edit" title="Edit">
                                <i class="fa fa-edit"></i>
                            </asp:LinkButton>
                            <asp:LinkButton runat="server" CommandName="ResetPwd"
                                CommandArgument='<%# Eval("ParentUserId") %>'
                                CssClass="par-act-btn act-key" title="Reset Password">
                                <i class="fa fa-key"></i>
                            </asp:LinkButton>
                            <asp:LinkButton runat="server" CommandName="Toggle"
                                CommandArgument='<%# Eval("ParentUserId") %>'
                                CssClass="par-act-btn act-toggle" title="Toggle Status"
                                OnClientClick="return confirm('Change parent status?');">
                                <i class="fa fa-power-off"></i>
                            </asp:LinkButton>
                            <asp:LinkButton runat="server" CommandName="DeleteRow"
                                CommandArgument='<%# Eval("ParentUserId") %>'
                                CssClass="par-act-btn act-del" title="Delete"
                                OnClientClick="return confirm('Delete this parent? This action cannot be undone.');">
                                <i class="fa fa-trash"></i>
                            </asp:LinkButton>
                        </div>
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
        </asp:GridView>
    </div>
</div>

<!-- ══ PAGINATION ══ -->
<div class="d-flex justify-content-center mt-4">
    <asp:Panel ID="pnlPager" runat="server"
        CssClass="d-flex align-items-center gap-2 flex-wrap justify-content-center" />
</div>

<!-- ══════════════════════════════════════════════════════════
     ADD / EDIT MODAL
══════════════════════════════════════════════════════════ -->
<div class="modal fade" id="ParentModal" tabindex="-1"
     aria-labelledby="parentModalLabel" aria-hidden="true"
     data-bs-backdrop="static" data-bs-keyboard="false">
    <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable par-modal-dialog">
        <div class="modal-content rounded-4 border-0 shadow-lg">

            <div class="modal-header par-modal-header text-white py-3">
                <div>
                    <h5 class="modal-title fw-bold mb-0" id="parentModalLabel">
                        <i class="fa fa-user-plus me-2"></i>
                        <span id="modalTitleText">Add New Parent</span>
                    </h5>
                    <small class="opacity-75" id="modalSubText">
                        Password is auto-set to DOB (DDMMYYYY)
                    </small>
                </div>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>

            <!-- Wizard tabs -->
            <ul class="nav par-wizard-nav px-3 pt-3 gap-1">
                <li class="nav-item">
                    <a class="par-wizard-tab active" href="#" onclick="gotoTab(1);return false;">
                        <span class="tab-num">1</span><span class="tab-label"> Account</span>
                    </a>
                </li>
                <li class="nav-item">
                    <a class="par-wizard-tab" href="#" onclick="gotoTab(2);return false;">
                        <span class="tab-num">2</span><span class="tab-label"> Link Students</span>
                    </a>
                </li>
                <li class="nav-item">
                    <a class="par-wizard-tab" href="#" onclick="gotoTab(3);return false;">
                        <span class="tab-num">3</span><span class="tab-label"> Personal</span>
                    </a>
                </li>
            </ul>

            <div class="modal-body p-3 p-md-4">

                <!-- ── Tab 1: Account ── -->
                <div id="ptab1" class="par-pane">
                    <div class="row g-3">
                        <div class="col-12 col-sm-6 col-md-4">
                            <label class="form-label fw-semibold small">Full Name <span class="req">*</span></label>
                            <asp:TextBox ID="txtFullName" runat="server" CssClass="form-control"
                                placeholder="e.g. Ramesh Sharma" MaxLength="150" oninput="autoUsername()" />
                            <div class="form-err" id="errFullName"></div>
                        </div>
                        <div class="col-12 col-sm-6 col-md-4">
                            <label class="form-label fw-semibold small">Username <span class="req">*</span></label>
                            <asp:TextBox ID="txtUsername" runat="server" CssClass="form-control"
                                placeholder="e.g. ramesh_sharma" MaxLength="50" />
                            <div class="form-err" id="errUsername"></div>
                            <div class="form-text" style="font-size:11px;color:#94a3b8">Lowercase, numbers, underscore only</div>
                        </div>
                        <div class="col-12 col-sm-6 col-md-4">
                            <label class="form-label fw-semibold small">Email <span class="req">*</span></label>
                            <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control"
                                placeholder="parent@email.com" MaxLength="100" TextMode="Email" />
                            <div class="form-err" id="errEmail"></div>
                        </div>
                        <div class="col-12 col-sm-6 col-md-4">
                            <label class="form-label fw-semibold small">Contact No <span class="req">*</span></label>
                            <asp:TextBox ID="txtContact" runat="server" CssClass="form-control"
                                placeholder="10-digit mobile" MaxLength="15"
                                oninput="this.value=this.value.replace(/[^0-9+]/g,'')" />
                            <div class="form-err" id="errContact"></div>
                        </div>
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
                        <div class="col-12">
                            <div class="alert alert-info border-0 rounded-3 py-2 px-3 mb-0" style="font-size:12px">
                                <i class="fa fa-info-circle me-2"></i>
                                <strong>Auto Password:</strong> Set to DOB in <strong>DDMMYYYY</strong> format
                                (e.g. 15-Jun-1985 → <code>15061985</code>). Changeable after first login.
                            </div>
                        </div>
                    </div>
                </div>

                <!-- ── Tab 2: Link Students ── -->
                <div id="ptab2" class="par-pane" style="display:none">
                    <div class="row g-3">
                        <div class="col-12 col-sm-6">
                            <label class="form-label fw-semibold small">Relationship Type <span class="req">*</span></label>
                            <asp:DropDownList ID="ddlRelation" runat="server" CssClass="form-select">
                                <asp:ListItem Value="">-- Select Relationship --</asp:ListItem>
                                <asp:ListItem Value="Father">Father</asp:ListItem>
                                <asp:ListItem Value="Mother">Mother</asp:ListItem>
                                <asp:ListItem Value="Guardian">Guardian</asp:ListItem>
                                <asp:ListItem Value="Grandfather">Grandfather</asp:ListItem>
                                <asp:ListItem Value="Grandmother">Grandmother</asp:ListItem>
                                <asp:ListItem Value="Elder Sibling">Elder Sibling</asp:ListItem>
                                <asp:ListItem Value="Other">Other</asp:ListItem>
                            </asp:DropDownList>
                            <div class="form-err" id="errRelation"></div>
                        </div>
                        <div class="col-12 col-sm-6 d-flex align-items-end pb-1">
                            <div class="form-check form-switch mt-2">
                                <asp:CheckBox ID="chkPrimary" runat="server" CssClass="form-check-input" />
                                <label class="form-check-label" for="<%= chkPrimary.ClientID %>">Primary Guardian</label>
                            </div>
                        </div>
                        <div class="col-12">
                            <label class="form-label fw-semibold small">Select Student(s) <span class="req">*</span></label>
                            <div class="par-stud-search-wrap mb-2">
                                <i class="fa fa-search par-stud-search-icon"></i>
                                <input type="text" id="studSearchBox"
                                       class="form-control par-stud-search-input"
                                       placeholder="Search by name, roll no, stream..."
                                       oninput="filterStudents(this.value)" />
                            </div>
                            <div class="par-stud-list-box" id="studListBox">
                                <asp:Repeater ID="rptStudents" runat="server">
                                    <ItemTemplate>
                                        <div class="par-stud-item"
                                             data-search='<%# (Eval("FullName") + " " + Eval("RollNumber") + " " + Eval("StreamName") + " " + Eval("CourseName")).ToString().ToLower() %>'>
                                            <label class="par-stud-label w-100">
                                                <input type="checkbox"
                                                       class="form-check-input stud-chk me-2"
                                                       value='<%# Eval("UserId") %>'
                                                       data-name='<%# Eval("FullName") %>'
                                                       data-roll='<%# Eval("RollNumber") %>'
                                                       data-stream='<%# Eval("StreamName") %>'
                                                       onchange="updateSelectedStuds()" />
                                                <div class="par-stud-card flex-fill">
                                                    <div class="d-flex align-items-center gap-2">
                                                        <div class="par-stud-mini-avatar"
                                                             style="background:<%# GetAvatarColor(Eval("FullName").ToString()) %>">
                                                            <%# GetInitials(Eval("FullName").ToString()) %>
                                                        </div>
                                                        <div class="flex-fill">
                                                            <div class="fw-semibold small"><%# Eval("FullName") %></div>
                                                            <div class="d-flex gap-1 flex-wrap mt-1">
                                                                <span class="acad-tag tag-roll">#<%# Eval("RollNumber") %></span>
                                                                <span class="acad-tag tag-stream"><%# Eval("StreamName") %></span>
                                                                <span class="acad-tag tag-course"><%# Eval("CourseName") %></span>
                                                                <span class="acad-tag tag-sem"><%# Eval("SemesterName") %></span>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </label>
                                        </div>
                                    </ItemTemplate>
                                    <FooterTemplate>
                                        <asp:Panel ID="pnlNoStudents" runat="server" Visible='<%# rptStudents.Items.Count==0 %>'>
                                            <div class="text-center py-4 text-muted small">
                                                <i class="fa fa-user-graduate fa-2x mb-2 d-block"></i>
                                                No students found in this session.
                                            </div>
                                        </asp:Panel>
                                    </FooterTemplate>
                                </asp:Repeater>
                            </div>
                            <div class="par-selected-preview mt-2" id="selectedPreview" style="display:none">
                                <div class="small fw-semibold text-muted mb-1">Selected Students:</div>
                                <div id="selectedTags" class="d-flex flex-wrap gap-1"></div>
                            </div>
                            <div class="form-err" id="errStudents"></div>
                        </div>
                    </div>
                </div>

                <!-- ── Tab 3: Personal ── -->
                <div id="ptab3" class="par-pane" style="display:none">
                    <div class="row g-3">
                        <div class="col-12">
                            <label class="form-label fw-semibold small">Address <span class="req">*</span></label>
                            <asp:TextBox ID="txtAddress" runat="server" CssClass="form-control"
                                TextMode="MultiLine" Rows="2"
                                placeholder="Full residential address" MaxLength="300" />
                            <div class="form-err" id="errAddress"></div>
                        </div>
                        <div class="col-12 col-sm-4">
                            <label class="form-label fw-semibold small">City</label>
                            <asp:TextBox ID="txtCity" runat="server" CssClass="form-control" placeholder="City" MaxLength="50" />
                        </div>
                        <div class="col-12 col-sm-4">
                            <label class="form-label fw-semibold small">Country</label>
                            <asp:TextBox ID="txtCountry" runat="server" CssClass="form-control" placeholder="Country" MaxLength="50" />
                        </div>
                        <div class="col-12 col-sm-4">
                            <label class="form-label fw-semibold small">Pincode</label>
                            <asp:TextBox ID="txtPincode" runat="server" CssClass="form-control"
                                placeholder="6-digit" MaxLength="6"
                                oninput="this.value=this.value.replace(/[^0-9]/g,'')" />
                        </div>
                        <div class="col-12 col-sm-6">
                            <label class="form-label fw-semibold small">Occupation</label>
                            <asp:TextBox ID="txtOccupation" runat="server" CssClass="form-control"
                                placeholder="e.g. Engineer, Businessman" MaxLength="100" />
                        </div>
                        <div class="col-12 col-sm-6">
                            <label class="form-label fw-semibold small">Annual Income (optional)</label>
                            <asp:TextBox ID="txtIncome" runat="server" CssClass="form-control"
                                placeholder="e.g. 500000" MaxLength="12"
                                oninput="this.value=this.value.replace(/[^0-9]/g,'')" />
                        </div>
                    </div>
                </div>

            </div><!-- /modal-body -->

            <div class="modal-footer border-top px-3 px-md-4 pb-3 pb-md-4 pt-0">
                <button type="button" class="btn btn-outline-secondary rounded-pill px-4"
                        id="btnWizPrev" onclick="wizNav(-1)" style="display:none">
                    <i class="fa fa-chevron-left me-1"></i>Previous
                </button>
                <div class="d-flex gap-2 ms-auto flex-wrap">
                    <button type="button" class="btn btn-outline-secondary rounded-pill px-4"
                            data-bs-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-primary rounded-pill px-4 fw-semibold"
                            id="btnWizNext" onclick="wizNav(1)">
                        Next <i class="fa fa-chevron-right ms-1"></i>
                    </button>
                    <asp:Button ID="btnSaveParent" runat="server"
                        Text="Save Parent"
                        CssClass="btn btn-success rounded-pill px-4 fw-semibold"
                        OnClick="btnSaveParent_Click"
                        OnClientClick="return finalValidate();"
                        style="display:none" />
                </div>
            </div>

        </div>
    </div>
</div>

<!-- ══ CREDENTIALS MODAL ══ -->
<div class="modal fade" id="CredsModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered par-modal-dialog-sm">
        <div class="modal-content rounded-4 border-0 shadow-lg">
            <div class="modal-header par-modal-header text-white">
                <h5 class="modal-title fw-bold"><i class="fa fa-envelope me-2"></i>Parent Login Credentials</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body p-4" id="credsBody">
                <div class="text-center py-3"><div class="spinner-border text-primary"></div></div>
            </div>
            <div class="modal-footer border-0 pb-4 px-4 pt-0">
                <button class="btn btn-outline-secondary rounded-pill px-4" data-bs-dismiss="modal">Close</button>
                <button class="btn btn-primary rounded-pill px-4 fw-semibold" onclick="copyCredsToClipboard()">
                    <i class="fa fa-copy me-1"></i>Copy
                </button>
            </div>
        </div>
    </div>
</div>

<!-- ══ BULK UPLOAD MODAL ══ -->
<div class="modal fade" id="BulkModal" tabindex="-1" aria-hidden="true" data-bs-backdrop="static">
    <div class="modal-dialog modal-lg modal-dialog-centered par-modal-dialog">
        <div class="modal-content rounded-4 border-0 shadow-lg">
            <div class="modal-header bg-success text-white">
                <h5 class="modal-title fw-bold"><i class="fa fa-file-excel me-2"></i>Bulk Upload Parents</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body p-4">
                <div class="alert alert-info border-0 rounded-3 mb-3" style="font-size:12px">
                    <i class="fa fa-info-circle me-2"></i>
                    Columns: <strong>FullName, Username, Email, ContactNo, Gender, DOB,
                    RelationshipType, IsPrimaryGuardian, StudentUsername,
                    Address, City, Country, Pincode, Occupation</strong>.
                    Duplicates skipped. Password = DOB in DDMMYYYY.
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
            <div class="modal-footer border-0 px-4 pb-4 pt-0">
                <button type="button" class="btn btn-outline-secondary rounded-pill px-4" data-bs-dismiss="modal">Close</button>
                <asp:Button ID="btnBulkUpload" runat="server"
                    Text="Upload &amp; Process"
                    CssClass="btn btn-success rounded-pill px-4 fw-semibold"
                    OnClick="btnBulkUpload_Click" />
            </div>
        </div>
    </div>
</div>

<!-- ══ STYLES ══ -->
<style>
:root {
    --par-primary:#4f46e5; --par-primary-lt:#eef2ff;
    --par-radius:16px; --par-shadow:0 4px 20px rgba(0,0,0,.08);
}

/* ─── HEADER ─────────────────────────────────────────────── */
.par-header-row {
    display:flex;
    align-items:center;
    justify-content:space-between;
    flex-wrap:wrap;
    gap:12px;
}
.par-title-block { flex:1;min-width:200px; }
.par-header-actions {
    display:flex;
    align-items:center;
    gap:8px;
    flex-shrink:0;
    flex-wrap:wrap;
}
.par-header-icon {
    width:36px;height:36px;border-radius:10px;
    background:var(--par-primary-lt);color:var(--par-primary);
    display:inline-flex;align-items:center;justify-content:center;flex-shrink:0;
}
.dot-sep { width:5px;height:5px;background:#cbd5e1;border-radius:50%;display:inline-block; }

/* ─── FILTER BAR (Search Left + Filter Right) ───────────────────────────── */
.par-filter-bar{
    display:flex;
    align-items:center;
    justify-content:space-between;
    gap:14px;
    width:100%;

    background:#fff;
    border:1px solid #e2e8f0;
    border-radius:12px;
    padding:10px 14px;
    box-shadow:0 1px 4px rgba(0,0,0,.05);
}

/* Search Box */
.par-search-wrap{
    position:relative;
    flex:1;
    max-width:500px;
}

.par-search-icon{
    position:absolute;
    top:50%;
    left:12px;
    transform:translateY(-50%);
    color:#94a3b8;
    font-size:12px;
    z-index:2;
    pointer-events:none;
}

.par-search-input{
    width:100%;
    height:38px;
    padding-left:34px;

    border:1px solid #e2e8f0;
    border-radius:8px;

    font-size:13px;
}

.par-search-input:focus{
    border-color:var(--par-primary);
    outline:none;
    box-shadow:0 0 0 3px rgba(79,70,229,.1);
}

/* Right Side Controls */
.par-filter-sel{
    width:160px;
    height:38px;

    border:1px solid #e2e8f0;
    border-radius:8px;

    font-size:13px;
    padding:0 12px;
    flex-shrink:0;
    cursor:pointer;
}

.par-filter-sel:focus{
    border-color:var(--par-primary);
    outline:none;
    box-shadow:0 0 0 3px rgba(79,70,229,.1);
}

/* Record Count */
.par-record-count{
    font-size:12px;
    color:#64748b;
    white-space:nowrap;
    margin-left:auto;
}


/* ─── STATS ──────────────────────────────────────────────── */
.par-stat-card { border-radius:var(--par-radius);transition:transform .2s,box-shadow .2s; }
.par-stat-card:hover { transform:translateY(-3px);box-shadow:0 6px 20px rgba(0,0,0,.1)!important; }
.par-icon-box { width:40px;height:40px;border-radius:10px;display:flex;align-items:center;justify-content:center;flex-shrink:0; }
.par-stat-lbl { font-size:11px; }

/* ─── TABLE ──────────────────────────────────────────────── */
.par-table-header th {
    background:linear-gradient(135deg,#4f46e5,#6366f1)!important;
    color:#fff!important;border:none!important;
    padding:12px 12px!important;font-weight:600;font-size:12px;white-space:nowrap;
}
.par-table td {
    padding:10px 12px;font-size:13px;
    border-bottom:1px solid #f1f5f9!important;vertical-align:middle;
}
.par-tbl-avatar {
    width:34px;height:34px;border-radius:50%;
    display:flex;align-items:center;justify-content:center;
    font-weight:700;font-size:12px;color:#fff;flex-shrink:0;
}
.par-act-btn {
    width:28px;height:28px;border-radius:7px;border:none;
    display:inline-flex;align-items:center;justify-content:center;
    font-size:11px;cursor:pointer;transition:transform .15s;text-decoration:none;
}
.par-act-btn:hover { transform:scale(1.12); }
.act-creds  { background:#e0f2fe;color:#0369a1; }
.act-edit   { background:#eef2ff;color:#4f46e5; }
.act-key    { background:#fef9c3;color:#92400e; }
.act-toggle { background:#f0fdf4;color:#15803d; }
.act-del    { background:#fee2e2;color:#b91c1c; }
.par-act-cell { white-space:nowrap; }
.par-rel-badge { display:inline-block;padding:2px 8px;border-radius:6px;font-size:10px;font-weight:600;background:#fef3c7;color:#92400e; }

/* ─── ACADEMIC TAGS ──────────────────────────────────────── */
.acad-tag { display:inline-block;padding:2px 7px;border-radius:5px;font-size:10px;font-weight:600;white-space:nowrap; }
.tag-stream { background:#eef2ff;color:#4f46e5; }
.tag-course { background:#e0f2fe;color:#0369a1; }
.tag-sem    { background:#fef9c3;color:#92400e; }
.tag-roll   { background:#f1f5f9;color:#475569; }
.tag-stud   { background:#dcfce7;color:#15803d; }

/* ─── MODAL — no header overlap ─────────────────────────── */
/* Bootstrap z-index override */
.modal { z-index:99999!important; }
.modal-backdrop { z-index:99990!important; }

/* Prevent modal sitting behind fixed nav/header */
.modal.show { padding-top:0!important; }
.par-modal-dialog {
    max-width:700px;
    margin-top:60px!important;    /* clear fixed header (~56px) */
    margin-bottom:20px!important;
}
.par-modal-dialog-sm {
    max-width:480px;
    margin-top:60px!important;
    margin-bottom:20px!important;
}

.modal-content { border-radius:var(--par-radius)!important;border:none!important;overflow:hidden; }
.par-modal-header { background:linear-gradient(135deg,#4f46e5,#6366f1); }

/* ─── WIZARD ─────────────────────────────────────────────── */
.par-wizard-nav {
    list-style:none;padding-left:0;
    border-bottom:2px solid #f1f5f9;margin:0;
    display:flex;flex-wrap:nowrap;overflow-x:auto;
    scrollbar-width:none;-webkit-overflow-scrolling:touch;
}
.par-wizard-nav::-webkit-scrollbar { display:none; }
.par-wizard-nav .nav-item { margin-bottom:-2px;flex-shrink:0; }
.par-wizard-tab {
    display:flex;align-items:center;gap:5px;
    padding:10px 14px;font-size:13px;font-weight:500;
    color:#64748b;border-bottom:2px solid transparent;
    text-decoration:none;transition:.15s;white-space:nowrap;
}
.par-wizard-tab:hover { color:var(--par-primary); }
.par-wizard-tab.active { color:var(--par-primary);border-bottom-color:var(--par-primary); }
.tab-num {
    width:20px;height:20px;border-radius:50%;flex-shrink:0;
    background:#e2e8f0;color:#64748b;font-size:11px;
    display:inline-flex;align-items:center;justify-content:center;font-weight:700;
}
.par-wizard-tab.active .tab-num { background:var(--par-primary);color:#fff; }

/* ─── STUDENT SELECTOR ───────────────────────────────────── */
.par-stud-search-wrap { position:relative; }
.par-stud-search-icon { position:absolute;top:50%;left:10px;transform:translateY(-50%);color:#94a3b8;font-size:12px;z-index:2;pointer-events:none; }
.par-stud-search-input { padding-left:32px;border-radius:8px;font-size:13px;border:1px solid #e2e8f0; }
.par-stud-search-input:focus { border-color:var(--par-primary);box-shadow:0 0 0 3px rgba(79,70,229,.1);outline:none; }
.par-stud-list-box { max-height:250px;overflow-y:auto;border:1px solid #e2e8f0;border-radius:10px;background:#fafafa; }
.par-stud-item { border-bottom:1px solid #f1f5f9;transition:background .15s; }
.par-stud-item:last-child { border-bottom:none; }
.par-stud-item:hover { background:#f1f5f9; }
.par-stud-label { display:flex;align-items:center;padding:10px 12px;cursor:pointer;margin:0; }
.par-stud-card { display:flex;align-items:center;gap:10px; }
.par-stud-mini-avatar { width:30px;height:30px;border-radius:50%;display:flex;align-items:center;justify-content:center;font-weight:700;font-size:11px;color:#fff;flex-shrink:0; }
.par-selected-preview { padding:10px 12px;background:#f0fdf4;border-radius:10px;border:1px solid #bbf7d0; }

/* ─── FORM ───────────────────────────────────────────────── */
.form-label { font-size:13px;margin-bottom:4px; }
.form-control,.form-select { font-size:13px;border-radius:8px; }
.form-control:focus,.form-select:focus { border-color:var(--par-primary);box-shadow:0 0 0 3px rgba(79,70,229,.15); }
.req { color:#dc2626; }
.form-err { color:#dc2626;font-size:11px;margin-top:3px;min-height:14px; }

/* ─── PAGINATION ─────────────────────────────────────────── */
.par-page-btn { padding:5px 12px;border-radius:8px;border:1px solid #e2e8f0;background:#fff;font-size:13px;cursor:pointer;color:#475569;transition:.15s; }
.par-page-btn:hover,.par-page-btn.active { background:var(--par-primary);color:#fff;border-color:var(--par-primary); }

/* ─── TOAST ──────────────────────────────────────────────── */
.toast { min-width:260px;border-radius:12px!important; }
.toast.bg-success { background:#16a34a!important;color:#fff!important; }
.toast.bg-danger  { background:#dc2626!important;color:#fff!important; }
.toast.bg-warning { background:#d97706!important;color:#fff!important; }

/* ─── BULK ───────────────────────────────────────────────── */
.bulk-res-box { border:1px solid #e2e8f0;border-radius:10px;padding:14px;font-size:13px;max-height:200px;overflow-y:auto;background:#fafafa; }

/* ─── CREDS ──────────────────────────────────────────────── */
.creds-box { background:#f8fafc;border-radius:12px;padding:16px;font-size:13px; }
.creds-field { display:flex;flex-direction:column;gap:2px;padding:8px 10px;background:#fff;border-radius:8px;border:1px solid #e2e8f0;margin-bottom:8px; }
.creds-label { font-size:10px;font-weight:600;color:#94a3b8;text-transform:uppercase;letter-spacing:.5px; }
.creds-val   { font-size:14px;font-weight:600;color:#1e293b;font-family:monospace; }

/* ═══════════════════════════════════════════════════════════
   RESPONSIVE BREAKPOINTS
═══════════════════════════════════════════════════════════ */

/* ── Tablet ≤992px ── */
@media (max-width:992px) {
    /* Modal header gap reduced */
    .par-modal-dialog    { margin-top:56px!important; }
    .par-modal-dialog-sm { margin-top:56px!important; }

    /* Filter bar: allow wrap */
    .par-filter-bar { flex-wrap:wrap; }
    .par-filter-sel  { min-width:110px; }
    .par-record-count { margin-left:0!important;order:3;width:100%;text-align:right; }

    /* Hide Contact column on tablet */
    .par-col-contact { display:none!important; }
}

/* ── Small tablet / large mobile ≤768px ── */
@media (max-width:768px) {
    /* Header */
    .par-header-row { flex-direction:column;align-items:flex-start; }
    .par-header-actions { width:100%;justify-content:flex-start; }

    /* Filter bar wraps fully */
    .par-filter-bar { padding:8px 12px;gap:8px; }
    .par-search-wrap { flex:1;min-width:0; }
    .par-filter-sel  { flex:1;min-width:90px; }
    .par-record-count { order:3;width:100%;text-align:left;font-size:11px; }

    /* Stats: 2 per row */
    .par-stat-card { padding:.75rem!important; }
    .par-icon-box  { width:34px;height:34px; }
    .par-stat-val.fw-bold { font-size:1rem!important; }

    /* Table: hide Email + Contact + Relation */
    .par-col-email,.par-col-contact,.par-col-relation { display:none!important; }
    .par-table td { padding:8px 10px;font-size:12px; }
    .par-table-header th { padding:10px 10px!important;font-size:11px; }
    .par-tbl-avatar { width:30px;height:30px;font-size:10px; }
    .par-act-btn    { width:26px;height:26px;font-size:10px; }

    /* Modal full-width */
    .par-modal-dialog,.par-modal-dialog-sm {
        max-width:calc(100vw - 16px)!important;
        margin-left:8px!important;
        margin-right:8px!important;
        margin-top:56px!important;
    }
    .modal-body    { padding:14px!important; }
    .modal-header  { padding:12px 14px!important; }
    .modal-footer  { padding:10px 14px 14px!important;flex-wrap:wrap;gap:8px; }
    .modal-footer .d-flex { flex-wrap:wrap;gap:8px; }
    .modal-footer .btn,
    .modal-footer input[type=submit] { flex:1;min-width:110px;text-align:center;justify-content:center; }

    /* Wizard tab text shorter */
    .par-wizard-tab { padding:8px 10px;font-size:12px; }

    /* Form: full width cols */
    .modal .col-12.col-sm-6,
    .modal .col-12.col-sm-4,
    .modal .col-12.col-md-4,
    .modal .col-12.col-sm-6.col-md-4 { flex:0 0 100%;max-width:100%; }

    /* Student list height reduced */
    .par-stud-list-box { max-height:200px; }
}

/* ── Mobile ≤540px ── */
@media (max-width:540px) {
    /* Header: stack buttons below title */
    .par-header-actions { gap:6px; }
    /* Button: icon only below 420px via .btn-txt visibility (see below) */

    /* Stats: 2 columns remain */
    .par-stat-lbl { font-size:10px; }

    /* Filter bar: single row still, minimal */
    .par-filter-bar { gap:6px;padding:7px 10px; }
    .par-search-input { height:34px;font-size:12px; }
    .par-filter-sel   { height:34px;font-size:12px; }

    /* Table: only #, Name, Actions */
    .par-col-students,.par-col-email,.par-col-contact,.par-col-relation { display:none!important; }
    .par-act-btn { width:24px;height:24px;font-size:9px; }

    /* Modal */
    .par-modal-dialog,.par-modal-dialog-sm {
        max-width:100vw!important;
        width:100%!important;
        margin:0!important;
        margin-top:56px!important;
        border-radius:0;
    }
    .modal-content { border-radius:0!important; }
    .modal-body    { padding:10px!important; }
    .modal-header  { padding:10px 12px!important; }
    .modal-footer  { padding:8px 12px 12px!important; }

    /* Wizard: show tab numbers only */
    .tab-label { display:none; }
    .par-wizard-tab { padding:8px 10px; }

    /* Form rows: always single column */
    .modal .row.g-3 > [class*="col-"] { flex:0 0 100%;max-width:100%; }

    /* Student list */
    .par-stud-list-box { max-height:170px; }
    .par-stud-mini-avatar { width:26px;height:26px;font-size:10px; }
    .par-stud-label { padding:8px 10px; }

    /* Pagination */
    .par-page-btn { padding:4px 9px;font-size:12px; }
}

/* Mobile Responsive */
@media (max-width:768px){
    .par-filter-bar{
        flex-direction:column;
        align-items:stretch;
    }

    .par-search-wrap,
    .par-filter-sel{
        width:100%;
        max-width:100%;
    }

    .par-record-count{
        margin-left:0;
        text-align:right;
    }
}

/* ── Very small ≤400px ── */
@media (max-width:400px) {
    /* Header buttons: icon only */
    .btn-txt { display:none; }
    .par-btn-icon { padding:8px 10px!important; }

    /* Stats single column feel */
    .par-stat-card { padding:.5rem!important; }
    .par-icon-box  { width:28px;height:28px;font-size:12px; }
    .par-stat-val.fw-bold { font-size:.9rem!important; }

    /* Very compact filter */
    .par-filter-bar { padding:6px 8px;gap:5px; }
    .par-search-input { font-size:12px;height:32px; }
    .par-filter-sel   { font-size:12px;height:32px;min-width:80px; }

    /* Action buttons minimal */
    .par-act-btn { width:22px;height:22px;font-size:9px; }

    /* Modal margin top for fixed header */
    .par-modal-dialog,.par-modal-dialog-sm { margin-top:52px!important; }
}

/* ── Landscape mobile fix ── */
@media (max-height:480px) and (max-width:768px) {
    .par-stud-list-box { max-height:130px; }
    .modal-dialog-scrollable .modal-body { max-height:calc(100vh - 180px); }
}
</style>

<!-- ══ SCRIPTS ══ -->
<script>
    /* ── Role guard ── */
    var isSuperAdmin = '<%= Session["Role"]?.ToString() %>' === 'SuperAdmin';
    if (isSuperAdmin) {
        ['<%= pnlAddBtn.ClientID %>','<%= pnlBulkBtn.ClientID %>']
            .forEach(function (id) { var el = document.getElementById(id); if (el) el.style.display = 'none'; });
    }

    /* ── Toast ── */
    function showToast(msg, type) {
        var icons = { success: 'check-circle', danger: 'times-circle', warning: 'exclamation-triangle', info: 'info-circle' };
        var t = document.getElementById('liveToast');
        var m = document.getElementById('toastMsg');
        m.innerHTML = '<i class="fa fa-' + (icons[type] || 'info-circle') + ' me-2"></i>' + msg;
        t.className = 'toast align-items-center border-0 shadow-lg text-white bg-' + (type || 'success');
        bootstrap.Toast.getOrCreateInstance(t, { delay: 4500 }).show();
    }
    function serverToast(msg, type) { showToast(msg, type); }

    /* ── Client search ── */
    function clientSearch(val) {
        val = (val || '').toLowerCase().trim();
        document.querySelectorAll('#<%= gvParents.ClientID %> tbody tr').forEach(function (r) {
            r.style.display = (!val || r.innerText.toLowerCase().includes(val)) ? '' : 'none';
        });
        updateRecordCount();
    }

    function updateRecordCount() {
        var total = document.querySelectorAll('#<%= gvParents.ClientID %> tbody tr').length;
        var vis = 0;
        document.querySelectorAll('#<%= gvParents.ClientID %> tbody tr').forEach(function (r) { if (r.style.display !== 'none') vis++; });
        var el = document.getElementById('recordCount');
        if (el) el.textContent = 'Showing ' + vis + ' of ' + total;
    }

    /* ── Wizard ── */
    var curTab = 1, totalTabs = 3;
    function gotoTab(n) {
        if (n < 1 || n > totalTabs) return;
        curTab = n;
        for (var i = 1; i <= totalTabs; i++) {
            var p = document.getElementById('ptab' + i);
            if (p) p.style.display = (i === n) ? '' : 'none';
        }
        document.querySelectorAll('.par-wizard-tab').forEach(function (t, idx) {
            t.classList.toggle('active', idx + 1 === n);
        });
        document.getElementById('btnWizPrev').style.display = n > 1 ? '' : 'none';
        document.getElementById('btnWizNext').style.display = n < totalTabs ? '' : 'none';
        document.getElementById('<%= btnSaveParent.ClientID %>').style.display = n === totalTabs ? '' : 'none';
    }
    function wizNav(dir) { if (dir === 1 && !validateCurTab()) return; gotoTab(curTab + dir); }

    /* ── Validation ── */
    function validateCurTab() { if (curTab === 1) return validateTab1(); if (curTab === 2) return validateTab2(); return true; }
    function setE(elId, errId, msg) {
        var e = document.getElementById(errId), el = document.getElementById(elId);
        if (msg) { if (e) e.textContent = msg; if (el) el.classList.add('is-invalid'); return false; }
        if (e) e.textContent = ''; if (el) { el.classList.remove('is-invalid'); el.classList.add('is-valid'); } return true;
    }
    function validateTab1() {
        var ok = true;
        var name = document.getElementById('<%= txtFullName.ClientID %>');
        var user = document.getElementById('<%= txtUsername.ClientID %>');
        var email = document.getElementById('<%= txtEmail.ClientID %>');
        var con = document.getElementById('<%= txtContact.ClientID %>');
        var gen = document.getElementById('<%= ddlGender.ClientID %>');
        var dob=document.getElementById('<%= txtDOB.ClientID %>');
        if(!name.value.trim()||name.value.trim().length<3) ok=setE('<%= txtFullName.ClientID %>','errFullName','Full name must be at least 3 characters.')&&ok;
        else setE('<%= txtFullName.ClientID %>','errFullName','');
        if(!user.value.trim()||!/^[a-z0-9_]{3,50}$/.test(user.value.trim())) ok=setE('<%= txtUsername.ClientID %>','errUsername','Lowercase, numbers, underscore only (3–50 chars).')&&ok;
        else setE('<%= txtUsername.ClientID %>','errUsername','');
        if(!email.value.trim()||!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email.value.trim())) ok=setE('<%= txtEmail.ClientID %>','errEmail','Enter a valid email address.')&&ok;
        else setE('<%= txtEmail.ClientID %>','errEmail','');
        if(!con.value.trim()||!/^[0-9+]{10,15}$/.test(con.value.trim())) ok=setE('<%= txtContact.ClientID %>','errContact','Enter a valid 10–15 digit contact number.')&&ok;
        else setE('<%= txtContact.ClientID %>','errContact','');
        if(!gen.value) ok=setE('<%= ddlGender.ClientID %>','errGender','Please select gender.')&&ok;
        else setE('<%= ddlGender.ClientID %>','errGender','');
        if(!dob.value) ok=setE('<%= txtDOB.ClientID %>','errDOB','Date of birth is required.')&&ok;
        else setE('<%= txtDOB.ClientID %>','errDOB','');
        return ok;
    }
    function validateTab2(){
        var ok=true;
        var rel=document.getElementById('<%= ddlRelation.ClientID %>');
        if(!rel.value) ok=setE('<%= ddlRelation.ClientID %>','errRelation','Please select a relationship type.')&&ok;
        else setE('<%= ddlRelation.ClientID %>','errRelation','');
        var selected=document.querySelectorAll('.stud-chk:checked');
        var se=document.getElementById('errStudents');
        if(selected.length===0){if(se)se.textContent='Please select at least one student.';ok=false;}
        else{if(se)se.textContent='';}
        return ok;
    }
    function finalValidate(){
        if(isSuperAdmin){showToast('SuperAdmin has view-only access.','warning');return false;}
        var addr=document.getElementById('<%= txtAddress.ClientID %>');
        var ae=document.getElementById('errAddress');
        if(!addr.value.trim()){if(ae)ae.textContent='Address is required.';return false;}
        if(ae)ae.textContent='';
        var ids=Array.from(document.querySelectorAll('.stud-chk:checked')).map(function(c){return c.value;});
        document.getElementById('<%= hfSelectedStuds.ClientID %>').value=ids.join(',');
        return ids.length>0;
    }

    /* ── Auto username ── */
    function autoUsername(){
        var name=document.getElementById('<%= txtFullName.ClientID %>').value.trim();
        var user=document.getElementById('<%= txtUsername.ClientID %>');
        if(!user.value){
            var gen=name.toLowerCase().replace(/\s+/g,'_').replace(/[^a-z0-9_]/g,'').substring(0,20);
            if(gen.length>=3)user.value=gen+new Date().getFullYear().toString().slice(-2);
        }
    }

    /* ── Student filter ── */
    function filterStudents(val){
        val=(val||'').toLowerCase().trim();
        document.querySelectorAll('.par-stud-item').forEach(function(item){
            item.style.display=(!val||(item.dataset.search||'').includes(val))?'':'none';
        });
    }

    /* ── Selected students preview ── */
    function updateSelectedStuds(){
        var checks=document.querySelectorAll('.stud-chk:checked');
        var preview=document.getElementById('selectedPreview');
        var tags=document.getElementById('selectedTags');
        if(checks.length===0){preview.style.display='none';return;}
        preview.style.display='';tags.innerHTML='';
        checks.forEach(function(c){
            var t=document.createElement('span');
            t.className='badge bg-success bg-opacity-15 text-success px-2 py-1';
            t.style.fontSize='11px';
            t.innerHTML='<i class="fa fa-user me-1"></i>'+(c.dataset.name||'Student');
            tags.appendChild(t);
        });
    }

    /* ── Modal openers ── */
    function openAddModal(){
        if(isSuperAdmin){showToast('SuperAdmin has view-only access.','warning');return;}
        clearParentForm();
        document.getElementById('modalTitleText').textContent='Add New Parent / Guardian';
        document.getElementById('<%= btnSaveParent.ClientID %>').value='Save Parent';
        gotoTab(1);
        new bootstrap.Modal(document.getElementById('ParentModal')).show();
    }
    function openModal(){
        document.getElementById('modalTitleText').textContent='Edit Parent / Guardian';
        document.getElementById('<%= btnSaveParent.ClientID %>').value='Update Parent';
        gotoTab(1);
        new bootstrap.Modal(document.getElementById('ParentModal')).show();
    }
    function openBulkModal(){
        if(isSuperAdmin){showToast('SuperAdmin has view-only access.','warning');return;}
        new bootstrap.Modal(document.getElementById('BulkModal')).show();
    }

    /* ── Clear form ── */
    function clearParentForm(){
        document.getElementById('<%= hfParentUserId.ClientID %>').value='';
        document.getElementById('<%= hfSelectedStuds.ClientID %>').value='';
        ['<%= txtFullName.ClientID %>','<%= txtUsername.ClientID %>',
         '<%= txtEmail.ClientID %>','<%= txtContact.ClientID %>',
         '<%= txtDOB.ClientID %>','<%= txtAddress.ClientID %>',
         '<%= txtCity.ClientID %>','<%= txtCountry.ClientID %>',
         '<%= txtPincode.ClientID %>','<%= txtOccupation.ClientID %>',
         '<%= txtIncome.ClientID %>'].forEach(function (id) {
                var el = document.getElementById(id);
                if (el) { el.value = ''; el.classList.remove('is-invalid', 'is-valid'); }
            });
        document.querySelectorAll('.form-err').forEach(function (e) { e.textContent = ''; });
        document.querySelectorAll('.stud-chk').forEach(function (c) { c.checked = false; });
        var sp = document.getElementById('selectedPreview'); if (sp) sp.style.display = 'none';
        var ssb = document.getElementById('studSearchBox'); if (ssb) ssb.value = '';
        filterStudents('');
    }

    /* ── Credentials modal ── */
    var _credsText = '';
    function showCredsModal(html, text) {
        _credsText = text;
        document.getElementById('credsBody').innerHTML = html;
        new bootstrap.Modal(document.getElementById('CredsModal')).show();
    }
    function copyCredsToClipboard() {
        if (!_credsText) return;
        navigator.clipboard.writeText(_credsText).then(function () {
            showToast('Credentials copied to clipboard!', 'success');
        }).catch(function () { showToast('Copy failed. Please copy manually.', 'warning'); });
    }

    /* ── Init ── */
    document.addEventListener('DOMContentLoaded', function () {
        updateSelectedStuds();
        updateRecordCount();
    });
</script>

</asp:Content>
