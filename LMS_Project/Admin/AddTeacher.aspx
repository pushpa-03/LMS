<%--<%@ Page Title="Teacher Management" Language="C#" MasterPageFile="~/Admin/AdminMaster.master"
    AutoEventWireup="true" CodeBehind="AddTeacher.aspx.cs"
    Inherits="LearningManagementSystem.Admin.AddTeacher" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server" />

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">


<asp:HiddenField ID="hfTeacherUserId" runat="server" />
<asp:HiddenField ID="hfReenrolIds"    runat="server" />
<asp:HiddenField ID="hfCurrentPage" runat="server" Value="1" />
<asp:HiddenField ID="hfPageSize" runat="server" Value="10" />
<asp:HiddenField ID="hfTotalRecords" runat="server" Value="0" />


<div class="toast-container position-fixed p-3" style="top:70px;right:16px;z-index:9999;">
    <div id="liveToast" class="toast align-items-center border-0 shadow-lg" role="alert" aria-atomic="true">
        <div class="d-flex">
            <div class="toast-body fw-semibold" id="toastMsg" style="font-size:13px;"></div>
            <button type="button" class="btn-close me-2 m-auto" data-bs-dismiss="toast"></button>
        </div>
    </div>
</div>

<div class="tch-page-header mb-4">
    <div class="d-flex flex-wrap justify-content-between align-items-start gap-3">

        
        <div>
            <h4 class="fw-bold mb-1 d-flex align-items-center gap-2">
                <span class="tch-header-icon"><i class="fa fa-chalkboard-teacher"></i></span>
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

      
        <div class="d-flex align-items-center gap-2 flex-wrap tch-actions-bar">

            
            <div class="tch-search-wrap">
                <i class="fa fa-search tch-search-icon"></i>
                <input type="text" id="txtSearchClient" class="form-control tch-search-input"
                       placeholder="Search teachers..." onkeyup="clientSearch(this.value)" />
            </div>

           
            <asp:DropDownList ID="ddlFilterStream" runat="server"
                CssClass="form-select tch-filter-sel"
                AutoPostBack="true" OnSelectedIndexChanged="ddlFilterStream_Changed">
                <asp:ListItem Value="0" Text="All Streams" />
            </asp:DropDownList>

           
            <asp:DropDownList ID="ddlFilterStatus" runat="server"
                CssClass="form-select tch-filter-sel"
                AutoPostBack="true" OnSelectedIndexChanged="ddlFilterStatus_Changed">
                <asp:ListItem Value="All"      Text="All Status" />
                <asp:ListItem Value="Active"   Text="Active" />
                <asp:ListItem Value="Inactive" Text="Inactive" />
            </asp:DropDownList>

          
            <asp:Panel ID="pnlBulkBtn" runat="server">
                <button type="button"
                    class="btn btn-outline-success btn-sm rounded-pill px-3 fw-semibold"
                    onclick="openBulkModal()">
                    <i class="fa fa-file-excel me-1"></i>Bulk Upload
                </button>
            </asp:Panel>

      
            <asp:Panel ID="pnlReenrolBtn" runat="server">
                <button type="button"
                    class="btn btn-outline-warning btn-sm rounded-pill px-3 fw-semibold"
                    onclick="openReenrolModal()">
                    <i class="fa fa-sync me-1"></i>Re-Enrol
                </button>
            </asp:Panel>

    
            <asp:Panel ID="pnlAddBtn" runat="server">
                <button type="button"
                    class="btn btn-primary rounded-pill px-4 fw-semibold shadow-sm tch-add-btn"
                    onclick="openAddModal()">
                    <i class="fa fa-plus me-1"></i>Add Teacher
                </button>
            </asp:Panel>

        </div>
    </div>
</div>

<div class="row g-3 mb-4">
    <div class="col-6 col-sm-3">
        <div class="tch-stat-card card border-0 shadow-sm p-3">
            <div class="d-flex align-items-center gap-3">
                <div class="tch-icon-box bg-primary bg-opacity-10 text-primary">
                    <i class="fa fa-users-cog"></i>
                </div>
                <div>
                    <div class="tch-stat-lbl text-muted">Total</div>
                    <div class="tch-stat-val fw-bold fs-5">
                        <asp:Label ID="lblTotal" runat="server" Text="0" />
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div class="col-6 col-sm-3">
        <div class="tch-stat-card card border-0 shadow-sm p-3">
            <div class="d-flex align-items-center gap-3">
                <div class="tch-icon-box bg-success bg-opacity-10 text-success">
                    <i class="fa fa-user-check"></i>
                </div>
                <div>
                    <div class="tch-stat-lbl text-muted">Active</div>
                    <div class="tch-stat-val fw-bold fs-5 text-success">
                        <asp:Label ID="lblActive" runat="server" Text="0" />
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div class="col-6 col-sm-3">
        <div class="tch-stat-card card border-0 shadow-sm p-3">
            <div class="d-flex align-items-center gap-3">
                <div class="tch-icon-box bg-warning bg-opacity-10 text-warning">
                    <i class="fa fa-user-clock"></i>
                </div>
                <div>
                    <div class="tch-stat-lbl text-muted">First Login</div>
                    <div class="tch-stat-val fw-bold fs-5 text-warning">
                        <asp:Label ID="lblPending" runat="server" Text="0" />
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div class="col-6 col-sm-3">
        <div class="tch-stat-card card border-0 shadow-sm p-3">
            <div class="d-flex align-items-center gap-3">
                <div class="tch-icon-box bg-secondary bg-opacity-10 text-secondary">
                    <i class="fa fa-user-times"></i>
                </div>
                <div>
                    <div class="tch-stat-lbl text-muted">Inactive</div>
                    <div class="tch-stat-val fw-bold fs-5 text-secondary">
                        <asp:Label ID="lblInactive" runat="server" Text="0" />
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="d-flex align-items-center justify-content-between mb-3 flex-wrap gap-2">
    <span class="fw-semibold text-muted small" id="recordCount"></span>
    <div class="btn-group btn-group-sm" role="group">
          <button type="button" class="btn btn-outline-secondary active" id="btnTableView"
              onclick="switchView('table')">
              <i class="fa fa-table"></i>
          </button>
        <button type="button" class="btn btn-outline-secondary " id="btnCardView"
                onclick="switchView('card')">
            <i class="fa fa-th-large"></i>
        </button>      
    </div>
</div>

<div id="cardViewContainer" style="display:none">
    <asp:Repeater ID="rptTeachers" runat="server" OnItemCommand="rptTeachers_ItemCommand">
        <ItemTemplate>
            <div class="tch-card-wrapper"
                 data-search='<%# (Eval("FullName") + " " + Eval("EmployeeId") + " " + Eval("Username") + " " + Eval("StreamName") + " " + Eval("Designation")).ToString().ToLower() %>'>
                <div class="tch-card card border-0 shadow-sm">

                    
                    <div class="tch-card-stripe"
                         style='background:<%# GetStreamColor(Convert.ToString(Eval("StreamId"))) %>'>
                    </div>
                    <div class="tch-card-body p-3">

                     
                        <div class="d-flex justify-content-between align-items-start mb-2">
                            <div class="tch-avatar"
                                 style="background:<%# GetAvatarColor(Eval("FullName").ToString()) %>">
                                <%# GetInitials(Eval("FullName").ToString()) %>
                            </div>
                            <div class="d-flex flex-column align-items-end gap-1">
                               
                                <%# Convert.ToBoolean(Eval("IsFirstLogin"))
                                    ? "<span class='badge bg-warning text-dark' style='font-size:10px'><i class='fa fa-clock me-1'></i>1st Login</span>"
                                    : "" %>
                            </div>
                        </div>

                        
                        <div class="fw-bold text-truncate tch-name"
                             title='<%# Eval("FullName") %>'><%# Eval("FullName") %></div>
                        <div class="text-muted small mb-2">
                            <i class="fa fa-id-badge me-1" style="font-size:10px"></i><%# Eval("EmployeeId") %>
                            &nbsp;·&nbsp;
                            <i class="fa fa-user me-1" style="font-size:10px"></i><%# Eval("Username") %>
                        </div>

                       
                        <div class="d-flex flex-wrap gap-1 mb-3">
                            <span class="acad-tag tag-stream"><%# Eval("StreamName") %></span>
                            <span class="acad-tag tag-desig"><%# Eval("Designation") %></span>
                            <span class="acad-tag tag-exp"><%# Eval("ExperienceYears") %> yrs exp</span>
                        </div>

                      
                        <div class="text-muted small mb-3 text-truncate"
                             title='<%# Eval("Email") %>'>
                            <i class="fa fa-envelope me-1"></i><%# Eval("Email") %>
                        </div>

                     
                        <div class="d-flex gap-1 pt-2 border-top flex-wrap">
                            <asp:LinkButton runat="server" CommandName="ViewTeacher"
                                CommandArgument='<%# Eval("UserId") %>'
                                CssClass="btn btn-sm btn-outline-primary flex-fill" title="View Profile">
                                <i class="fa fa-eye"></i>
                            </asp:LinkButton>
                            <asp:LinkButton runat="server" CommandName="EditTeacher"
                                CommandArgument='<%# Eval("UserId") %>'
                                CssClass="btn btn-sm btn-outline-secondary flex-fill" title="Edit">
                                <i class="fa fa-edit"></i>
                            </asp:LinkButton>
                            <asp:LinkButton runat="server" CommandName="ResetPassword"
                                CommandArgument='<%# Eval("UserId") %>'
                                CssClass="btn btn-sm btn-outline-warning flex-fill" title="Reset Password">
                                <i class="fa fa-key"></i>
                            </asp:LinkButton>
                            <asp:LinkButton runat="server" CommandName="ToggleTeacher"
                                CommandArgument='<%# Eval("UserId") %>'
                                CssClass="btn btn-sm btn-outline-info flex-fill" title="Toggle Status">
                                <i class="fa fa-power-off"></i>
                            </asp:LinkButton>
                            <asp:LinkButton runat="server" CommandName="DeleteTeacher"
                                CommandArgument='<%# Eval("UserId") %>'
                                CssClass="btn btn-sm btn-outline-danger flex-fill" title="Delete"
                                OnClientClick="return confirm('Delete this teacher? This cannot be undone.');">
                                <i class="fa fa-trash"></i>
                            </asp:LinkButton>
                        </div>

                    </div>
                </div>
            </div>
        </ItemTemplate>
        <FooterTemplate>
            <asp:Panel ID="pnlEmpty" runat="server"
                       Visible='<%# rptTeachers.Items.Count == 0 %>'>
                <div class="text-center py-5 col-12">
                    <i class="fa fa-chalkboard-teacher fa-3x text-muted mb-3 d-block"></i>
                    <p class="fw-semibold text-muted mb-1">No teachers found</p>
                    <p class="text-muted small">
                        Click <strong>Add Teacher</strong> to hire a new teacher.
                    </p>
                </div>
            </asp:Panel>
        </FooterTemplate>
    </asp:Repeater>
</div>


<div id="tableViewContainer">
    <div class="card shadow-sm border-0 rounded-4 overflow-hidden">
        <div class="table-responsive">
            <asp:GridView ID="gvTeachers" runat="server"
                CssClass="table table-hover align-middle modern-table mb-0"
                AutoGenerateColumns="false"
                OnRowCommand="gvTeachers_RowCommand"
                EnableViewState="true"
                GridLines="None">
                <HeaderStyle CssClass="tch-table-header" />
                <EmptyDataTemplate>
                    <div class="text-center py-5">
                        <i class="fa fa-chalkboard-teacher fa-3x text-muted mb-3 d-block"></i>
                        <p class="text-muted">No teachers found.</p>
                    </div>
                </EmptyDataTemplate>
                <Columns>
                    <asp:TemplateField HeaderText="#" ItemStyle-Width="40px">
                        <ItemTemplate>
                            <span class="text-muted small"><%# ((CurrentPage - 1) * 10) + Container.DataItemIndex + 1 %></span>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Teacher">
                        <ItemTemplate>
                            <div class="d-flex align-items-center gap-2">
                                <div class="tbl-avatar"
                                     style="background:<%# GetAvatarColor(Eval("FullName").ToString()) %>">
                                    <%# GetInitials(Eval("FullName").ToString()) %>
                                </div>
                                <div>
                                    <div class="fw-semibold small"><%# Eval("FullName") %></div>
                                    <div class="text-muted" style="font-size:11px">
                                        <%# Eval("Username") %>
                                    </div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:BoundField DataField="EmployeeId"  HeaderText="Emp ID" />
                    <asp:BoundField DataField="Email"       HeaderText="Email" />

                    <asp:TemplateField HeaderText="Stream / Designation">
                        <ItemTemplate>
                            <span class="acad-tag tag-stream"><%# Eval("StreamName") %></span><br/>
                            <span class="acad-tag tag-desig mt-1"><%# Eval("Designation") %></span>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:BoundField DataField="ExperienceYears" HeaderText="Exp (yrs)" />

                    

                    <asp:TemplateField HeaderText="Actions" ItemStyle-CssClass="tbl-act-cell">
                        <ItemTemplate>
                            <div class="d-flex gap-1">
                                <asp:LinkButton runat="server" CommandName="ViewTeacher"
                                    CommandArgument='<%# Eval("UserId") %>'
                                    CssClass="tbl-act-btn act-view" title="View">
                                    <i class="fa fa-eye"></i>
                                </asp:LinkButton>
                                <asp:LinkButton runat="server" CommandName="EditTeacher"
                                    CommandArgument='<%# Eval("UserId") %>'
                                    CssClass="tbl-act-btn act-edit" title="Edit">
                                    <i class="fa fa-edit"></i>
                                </asp:LinkButton>
                                <asp:LinkButton runat="server" CommandName="ResetPassword"
                                    CommandArgument='<%# Eval("UserId") %>'
                                    CssClass="tbl-act-btn act-key" title="Reset Pwd">
                                    <i class="fa fa-key"></i>
                                </asp:LinkButton>
                                <asp:LinkButton runat="server" CommandName="ToggleTeacher"
                                    CommandArgument='<%# Eval("UserId") %>'
                                    CssClass="tbl-act-btn act-toggle" title="Toggle"
                                    OnClientClick="return confirm('Change teacher status?');">
                                    <i class="fa fa-power-off"></i>
                                </asp:LinkButton>
                                <asp:LinkButton runat="server" CommandName="DeleteTeacher"
                                    CommandArgument='<%# Eval("UserId") %>'
                                    CssClass="tbl-act-btn act-del" title="Delete"
                                    OnClientClick="return confirm('Delete teacher?');">
                                    <i class="fa fa-trash"></i>
                                </asp:LinkButton>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </div>
    </div>
</div>


<div class="d-flex justify-content-between align-items-center flex-wrap gap-2 mt-4">

    <div class="small text-muted fw-semibold" id="paginationInfo">
        Showing 0 to 0 of 0 entries
    </div>

    <div id="paginationContainer"
         class="d-flex align-items-center gap-2 flex-wrap justify-content-center">
    </div>

</div>


<div class="modal fade" id="TeacherModal" tabindex="-1"
     aria-labelledby="teacherModalLabel" aria-hidden="true"
     data-bs-backdrop="static" data-bs-keyboard="false">
    <div class="modal-dialog modal-lg mt-5 modal-dialog-centered modal-dialog-scrollable">
        <div class="modal-content rounded-4 border-0 shadow-lg">

          
            <div class="modal-header tch-modal-header text-white py-3">
                <div>
                    <h5 class="modal-title fw-bold mb-0" id="teacherModalLabel">
                        <i class="fa fa-user-tie me-2"></i>
                        <span id="modalTitleText">Add New Teacher</span>
                    </h5>
                    <small class="opacity-75" id="modalSubText">Fill all required fields marked *</small>
                </div>
                <button type="button" class="btn-close btn-close-white"
                        data-bs-dismiss="modal"></button>
            </div>

      
            <ul class="nav tch-wizard-nav px-3 pt-3 gap-1" id="wizardTabs">
                <li class="nav-item">
                    <a class="tch-wizard-tab active" href="#"
                       onclick="gotoTab(1,this);return false;">
                        <span class="tab-num">1</span> Account
                    </a>
                </li>
                <li class="nav-item">
                    <a class="tch-wizard-tab" href="#"
                       onclick="gotoTab(2,this);return false;">
                        <span class="tab-num">2</span> Professional
                    </a>
                </li>
                <li class="nav-item">
                    <a class="tch-wizard-tab" href="#"
                       onclick="gotoTab(3,this);return false;">
                        <span class="tab-num">3</span> Personal
                    </a>
                </li>
            </ul>

            <div class="modal-body p-4">

                
                <div id="tab1" class="tch-pane active">
                    <div class="row g-3">

                        <div class="col-12 col-md-4">
                            <label class="form-label fw-semibold small">
                                Full Name <span class="req">*</span>
                            </label>
                            <asp:TextBox ID="txtFullName" runat="server"
                                CssClass="form-control" placeholder="e.g. Dr. Priya Sharma"
                                MaxLength="150" oninput="autoUsername()" />
                            <div class="form-err" id="errFullName"></div>
                        </div>

                        <div class="col-12 col-md-4">
                            <label class="form-label fw-semibold small">
                                Username <span class="req">*</span>
                            </label>
                            <asp:TextBox ID="txtUsername" runat="server"
                                CssClass="form-control" placeholder="e.g. priya_sharma"
                                MaxLength="50" />
                            <div class="form-err" id="errUsername"></div>
                            <div class="form-text text-muted" style="font-size:11px">
                                Lowercase, numbers, underscore only
                            </div>
                        </div>

                        <div class="col-12 col-md-4">
                            <label class="form-label fw-semibold small">
                                Email <span class="req">*</span>
                            </label>
                            <asp:TextBox ID="txtEmail" runat="server"
                                CssClass="form-control" placeholder="teacher@school.edu"
                                MaxLength="100" TextMode="Email" />
                            <div class="form-err" id="errEmail"></div>
                        </div>

                        <div class="col-12 col-md-4">
                            <label class="form-label fw-semibold small">
                                Password <span class="req">*</span>
                            </label>
                            <div class="input-group">
                                <asp:TextBox ID="txtPassword" runat="server"
                                    CssClass="form-control" placeholder="Min 6 characters"
                                    TextMode="Password" MaxLength="50" />
                                <button class="btn btn-outline-secondary" type="button"
                                        onclick="togglePwd(this)" tabindex="-1">
                                    <i class="fa fa-eye"></i>
                                </button>
                            </div>
                            <div class="form-err" id="errPassword"></div>
                            <div class="pwd-strength mt-1" id="pwdBar" style="display:none">
                                <div class="pwd-fill" id="pwdFill"></div>
                            </div>
                            <div class="form-text" id="pwdTxt" style="font-size:11px"></div>
                        </div>

                        <div class="col-12 col-md-4">
                            <label class="form-label fw-semibold small">
                                Contact <span class="req">*</span>
                            </label>
                            <asp:TextBox ID="txtContact" runat="server"
                                CssClass="form-control" placeholder="10-digit mobile"
                                MaxLength="15"
                                oninput="this.value=this.value.replace(/[^0-9+]/g,'')" />
                            <div class="form-err" id="errContact"></div>
                        </div>

                        <div class="col-12 col-md-4">
                            <label class="form-label fw-semibold small">
                                Employee ID <span class="req">*</span>
                            </label>
                            <asp:TextBox ID="txtEmpId" runat="server"
                                CssClass="form-control" placeholder="e.g. EMP2025001"
                                MaxLength="50" />
                            <div class="form-err" id="errEmpId"></div>
                        </div>

                    </div>
                </div>

                <div id="tab2" class="tch-pane" style="display:none">
                    <div class="row g-3">

                        <div class="col-12 col-md-4">
                            <label class="form-label fw-semibold small">
                                Stream / Department <span class="req">*</span>
                            </label>
                            <asp:DropDownList ID="ddlStream" runat="server"
                                CssClass="form-select">
                                <asp:ListItem Value="0" Text="-- Select Stream --" />
                            </asp:DropDownList>
                            <div class="form-err" id="errStream"></div>
                        </div>

                        <div class="col-12 col-md-4">
                            <label class="form-label fw-semibold small">
                                Designation <span class="req">*</span>
                            </label>
                            <asp:TextBox ID="txtDesignation" runat="server"
                                CssClass="form-control"
                                placeholder="e.g. Associate Professor" MaxLength="100" />
                            <div class="form-err" id="errDesig"></div>
                        </div>

                        <div class="col-12 col-md-4">
                            <label class="form-label fw-semibold small">
                                Experience (Years) <span class="req">*</span>
                            </label>
                            <asp:TextBox ID="txtExperience" runat="server"
                                CssClass="form-control" placeholder="e.g. 5"
                                MaxLength="2"
                                oninput="this.value=this.value.replace(/[^0-9]/g,'')" />
                            <div class="form-err" id="errExp"></div>
                        </div>

                        <div class="col-12 col-md-4">
                            <label class="form-label fw-semibold small">Qualification</label>
                            <asp:TextBox ID="txtQualification" runat="server"
                                CssClass="form-control"
                                placeholder="e.g. M.Tech, Ph.D" MaxLength="100" />
                        </div>

                        <div class="col-12 col-md-4">
                            <label class="form-label fw-semibold small">
                                Joining Date <span class="req">*</span>
                            </label>
                            <asp:TextBox ID="txtJoinDate" runat="server"
                                CssClass="form-control" TextMode="Date" />
                            <div class="form-err" id="errJoinDate"></div>
                        </div>

                        <div class="col-12 col-md-4">
                            <label class="form-label fw-semibold small d-block">
                                Status
                            </label>
                            <div class="form-check form-switch mt-2">
                                <asp:CheckBox ID="chkActive" runat="server" Checked="true"
                                    CssClass="form-check-input" />
                                <label class="form-check-label"
                                       for="<%= chkActive.ClientID %>">Active</label>
                            </div>
                        </div>

                      
                        <div class="col-12">
                            <div class="acad-path-vis" id="acadPathVis" style="display:none">
                                <span class="path-chip path-stream" id="pathStream">—</span>
                                <i class="fa fa-chevron-right path-arr"></i>
                                <span class="path-chip path-desig" id="pathDesig">—</span>
                            </div>
                        </div>

                    </div>
                </div>

               
                <div id="tab3" class="tch-pane" style="display:none">
                    <div class="row g-3">

                        <div class="col-12 col-md-4">
                            <label class="form-label fw-semibold small">
                                Gender <span class="req">*</span>
                            </label>
                            <asp:DropDownList ID="ddlGender" runat="server"
                                CssClass="form-select">
                                <asp:ListItem Value="">-- Select Gender --</asp:ListItem>
                                <asp:ListItem Value="Male">Male</asp:ListItem>
                                <asp:ListItem Value="Female">Female</asp:ListItem>
                                <asp:ListItem Value="Other">Other</asp:ListItem>
                            </asp:DropDownList>
                            <div class="form-err" id="errGender"></div>
                        </div>

                        <div class="col-12 col-md-4">
                            <label class="form-label fw-semibold small">
                                Date of Birth <span class="req">*</span>
                            </label>
                            <asp:TextBox ID="txtDOB" runat="server"
                                CssClass="form-control" TextMode="Date" />
                            <div class="form-err" id="errDOB"></div>
                        </div>

                        <div class="col-12 col-md-4">
                            <label class="form-label fw-semibold small">Father's Name</label>
                            <asp:TextBox ID="txtFatherName" runat="server"
                                CssClass="form-control" placeholder="Father's full name"
                                MaxLength="100" />
                        </div>

                        <div class="col-12 col-md-4">
                            <label class="form-label fw-semibold small">Mother's Name</label>
                            <asp:TextBox ID="txtMotherName" runat="server"
                                CssClass="form-control" placeholder="Mother's full name"
                                MaxLength="100" />
                        </div>

                        <div class="col-12 col-md-4">
                            <label class="form-label fw-semibold small">
                                Emergency Contact Name <span class="req">*</span>
                            </label>
                            <asp:TextBox ID="txtEmgName" runat="server"
                                CssClass="form-control" placeholder="Guardian / spouse name"
                                MaxLength="150" />
                            <div class="form-err" id="errEmgName"></div>
                        </div>

                        <div class="col-12 col-md-4">
                            <label class="form-label fw-semibold small">
                                Emergency Contact No <span class="req">*</span>
                            </label>
                            <asp:TextBox ID="txtEmgContact" runat="server"
                                CssClass="form-control" placeholder="10-digit" MaxLength="15"
                                oninput="this.value=this.value.replace(/[^0-9+]/g,'')" />
                            <div class="form-err" id="errEmgContact"></div>
                        </div>

                        <div class="col-12">
                            <label class="form-label fw-semibold small">
                                Address <span class="req">*</span>
                            </label>
                            <asp:TextBox ID="txtAddress" runat="server"
                                CssClass="form-control" TextMode="MultiLine" Rows="2"
                                placeholder="Full residential address" MaxLength="300" />
                            <div class="form-err" id="errAddress"></div>
                        </div>

                        <div class="col-12 col-md-4">
                            <label class="form-label fw-semibold small">City</label>
                            <asp:TextBox ID="txtCity" runat="server"
                                CssClass="form-control" placeholder="City" MaxLength="50" />
                        </div>

                        <div class="col-12 col-md-4">
                            <label class="form-label fw-semibold small">Country</label>
                            <asp:TextBox ID="txtCountry" runat="server"
                                CssClass="form-control" placeholder="Country" MaxLength="50" />
                        </div>

                        <div class="col-12 col-md-4">
                            <label class="form-label fw-semibold small">Pincode</label>
                            <asp:TextBox ID="txtPincode" runat="server"
                                CssClass="form-control" placeholder="6-digit" MaxLength="6"
                                oninput="this.value=this.value.replace(/[^0-9]/g,'')" />
                        </div>

                        <div class="col-12">
                            <label class="form-label fw-semibold small">Skills</label>
                            <asp:TextBox ID="txtSkills" runat="server"
                                CssClass="form-control"
                                placeholder="e.g. Python, Machine Learning, Data Science"
                                MaxLength="200" />
                        </div>

                    </div>
                </div>

            </div>

            <div class="modal-footer border-top-0 px-4 pb-4 pt-0 d-flex justify-content-between">
                <button type="button" class="btn btn-outline-secondary rounded-pill px-4"
                        id="btnWizPrev" onclick="wizNav(-1)" style="display:none">
                    <i class="fa fa-chevron-left me-1"></i>Previous
                </button>
                <div class="d-flex gap-2 ms-auto">
                    <button type="button"
                            class="btn btn-outline-secondary rounded-pill px-4"
                            data-bs-dismiss="modal">Cancel</button>
                    <button type="button"
                            class="btn btn-primary rounded-pill px-4 fw-semibold"
                            id="btnWizNext" onclick="wizNav(1)">
                        Next <i class="fa fa-chevron-right ms-1"></i>
                    </button>
                    <asp:Button ID="btnSaveTeacher" runat="server"
                        Text="Add Teacher"
                        CssClass="btn btn-success rounded-pill px-4 fw-semibold"
                        OnClick="btnSaveTeacher_Click"
                        OnClientClick="return finalValidate();"
                        style="display:none" />
                </div>
            </div>

        </div>
    </div>
</div>

<div class="modal fade" id="ViewTeacherModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
        <div class="modal-content rounded-4 border-0 shadow-lg">
            <div class="modal-header tch-modal-header text-white">
                <h5 class="modal-title fw-bold">
                    <i class="fa fa-id-card me-2"></i>Teacher Profile
                </h5>
                <button type="button" class="btn-close btn-close-white"
                        data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body p-4" id="teacherProfileBody">
                <div class="text-center py-4">
                    <div class="spinner-border text-primary" role="status"></div>
                </div>
            </div>
        </div>
    </div>
</div>



<div class="modal fade" id="BulkModal" tabindex="-1" aria-hidden="true"
     data-bs-backdrop="static">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content rounded-4 border-0 shadow-lg">
            <div class="modal-header bg-success text-white">
                <h5 class="modal-title fw-bold">
                    <i class="fa fa-file-excel me-2"></i>Bulk Upload Teachers
                </h5>
                <button type="button" class="btn-close btn-close-white"
                        data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body p-4">
                <div class="alert alert-info border-0 rounded-3 mb-3" style="font-size:13px">
                    <i class="fa fa-info-circle me-2"></i>
                    Upload <strong>.xlsx</strong> file. Columns (same order as manual form):
                    <strong>FullName, Username, Email, Password, ContactNo, EmployeeId,
                    StreamName, Designation, ExperienceYears, Qualification, JoiningDate,
                    Gender, DOB, FatherName, MotherName, Address, City, Country, Pincode, Skills</strong>.
                    Duplicates (by Username or Email) are skipped and reported.
                </div>
                <div class="mb-3">
                    <asp:LinkButton ID="lnkDownloadTemplate" runat="server"
                        CssClass="btn btn-outline-success btn-sm rounded-pill"
                        OnClick="lnkDownloadTemplate_Click">
                        <i class="fa fa-download me-1"></i>Download Template
                    </asp:LinkButton>
                </div>
                <div class="mb-3">
                    <label class="form-label fw-semibold small">
                        Select Excel File <span class="req">*</span>
                    </label>
                    <asp:FileUpload ID="fuBulk" runat="server"
                        CssClass="form-control" accept=".xlsx,.xls" />
                </div>
                <asp:Panel ID="pnlBulkResult" runat="server" Visible="false">
                    <div class="bulk-res-box">
                        <asp:Literal ID="litBulkResult" runat="server" />
                    </div>
                </asp:Panel>
            </div>
            <div class="modal-footer border-0 px-4 pb-4 pt-0">
                <button type="button"
                        class="btn btn-outline-secondary rounded-pill px-4"
                        data-bs-dismiss="modal">Close</button>
                <asp:Button ID="btnBulkUpload" runat="server"
                    Text="Upload &amp; Process"
                    CssClass="btn btn-success rounded-pill px-4 fw-semibold"
                    OnClick="btnBulkUpload_Click" />
            </div>
        </div>
    </div>
</div>


<div class="modal fade" id="ReenrolModal" tabindex="-1" aria-hidden="true"
     data-bs-backdrop="static">
    <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
        <div class="modal-content rounded-4 border-0 shadow-lg">
            <div class="modal-header bg-warning text-dark">
                <h5 class="modal-title fw-bold">
                    <i class="fa fa-sync me-2"></i>Re-Enrol Teachers
                </h5>
                <button type="button" class="btn-close"
                        data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body p-4">
                <p class="text-muted small mb-3">
                    Select teachers from a previous session to re-enrol into the current session.
                </p>
                <div class="row g-3 mb-3">
                    <div class="col-md-6">
                        <label class="form-label fw-semibold small">
                            Previous Session <span class="req">*</span>
                        </label>
                        <asp:DropDownList ID="ddlPrevSession" runat="server"
                            CssClass="form-select"
                            AutoPostBack="true"
                            OnSelectedIndexChanged="ddlPrevSession_Changed">
                            <asp:ListItem Value="0" Text="-- Select Previous Session --" />
                        </asp:DropDownList>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fw-semibold small">New Stream (optional)</label>
                        <asp:DropDownList ID="ddlReenrolStream" runat="server"
                            CssClass="form-select">
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
                            <label class="form-check-label small" for="chkSelAll">
                                Select All
                            </label>
                        </div>
                    </div>
                    <div class="card-body py-2" style="max-height:280px;overflow-y:auto">
                        <asp:Repeater ID="rptPrevTeachers" runat="server">
                            <ItemTemplate>
                                <div class="d-flex align-items-center gap-2 py-1 border-bottom">
                                    <input type="checkbox" class="form-check-input reenrol-chk"
                                           value='<%# Eval("UserId") %>'
                                           id='rchk_<%# Eval("UserId") %>' />
                                    <label for='rchk_<%# Eval("UserId") %>'
                                           class="mb-0 small flex-fill cursor-pointer">
                                        <strong><%# Eval("FullName") %></strong>
                                        <span class="text-muted ms-2"><%# Eval("Username") %></span>
                                        <span class="acad-tag tag-stream ms-2"><%# Eval("StreamName") %></span>
                                        <span class="acad-tag tag-desig ms-1"><%# Eval("Designation") %></span>
                                    </label>
                                </div>
                            </ItemTemplate>
                            <FooterTemplate>
                                <asp:Panel ID="pnlNoPrev" runat="server"
                                           Visible='<%# rptPrevTeachers.Items.Count == 0 %>'>
                                    <p class="text-muted small py-3 text-center mb-0">
                                        Select a previous session to load teachers.
                                    </p>
                                </asp:Panel>
                            </FooterTemplate>
                        </asp:Repeater>
                    </div>
                </div>
            </div>
            <div class="modal-footer border-0 px-4 pb-4 pt-0 gap-2">
                <button type="button"
                        class="btn btn-outline-secondary rounded-pill px-4"
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

<!-- ══ STYLES ════════════════════════════════════════════════ -->
<style>
/* ── Variables ──────────────────────────────────────────── */
:root {
    --primary:#4f46e5; --primary-lt:#eef2ff;
    --success:#16a34a; --warning:#d97706;
    --radius-lg:16px;  --radius-md:10px;
}

/* ── Header ─────────────────────────────────────────────── */
.tch-header-icon {
    width:36px;height:36px;border-radius:10px;
    background:var(--primary-lt);color:var(--primary);
    display:inline-flex;align-items:center;justify-content:center;
}
.dot-sep { width:5px;height:5px;background:#cbd5e1;border-radius:50%;display:inline-block; }
.tch-actions-bar { gap:8px; }
.tch-add-btn { font-size:13px; }
.tch-search-wrap { position:relative; }
.tch-search-icon {
    position:absolute;top:50%;left:10px;
    transform:translateY(-50%);color:#94a3b8;font-size:12px;z-index:2;
}
.tch-search-input {
    padding-left:32px;border-radius:8px;height:34px;font-size:13px;width:200px;
}
.tch-filter-sel {
    height:34px;font-size:13px;border-radius:8px;
    padding:0 8px;width:auto;min-width:130px;
}

/* ── Stats ──────────────────────────────────────────────── */
.tch-stat-card {
    border-radius:var(--radius-lg);
    transition:transform .2s,box-shadow .2s;
}
.tch-stat-card:hover {
    transform:translateY(-3px);
    box-shadow:0 6px 20px rgba(0,0,0,.1)!important;
}
.tch-icon-box {
    width:40px;height:40px;border-radius:10px;
    display:flex;align-items:center;justify-content:center;flex-shrink:0;
}
.tch-stat-lbl { font-size:11px; }

/* ── Card Grid ──────────────────────────────────────────── */
#cardViewContainer {
    display:grid;
    grid-template-columns:repeat(auto-fill,minmax(260px,1fr));
    gap:16px;
}
.tch-card-wrapper { display:contents; }
.tch-card {
    border-radius:var(--radius-lg)!important;
    transition:transform .2s,box-shadow .2s;
    overflow:hidden;
}
.tch-card:hover {
    transform:translateY(-4px);
    box-shadow:0 8px 25px rgba(0,0,0,.12)!important;
}
.tch-card-stripe { height:6px; }
.tch-avatar {
    width:42px;height:42px;border-radius:50%;
    display:flex;align-items:center;justify-content:center;
    font-weight:700;font-size:14px;color:#fff;flex-shrink:0;
}
.tch-name { font-size:14px; }
.tbl-avatar {
    width:32px;height:32px;border-radius:50%;
    display:flex;align-items:center;justify-content:center;
    font-weight:700;font-size:11px;color:#fff;flex-shrink:0;
}

/* ── Academic Tags ──────────────────────────────────────── */
.acad-tag {
    display:inline-block;padding:2px 8px;border-radius:6px;
    font-size:10px;font-weight:600;white-space:nowrap;
}
.tag-stream { background:#eef2ff;color:#4f46e5; }
.tag-desig  { background:#e0f2fe;color:#0369a1; }
.tag-exp    { background:#fef9c3;color:#92400e; }

/* ── Table ──────────────────────────────────────────────── */
.tch-table-header th {
    background:linear-gradient(135deg,#4f46e5,#6366f1)!important;
    color:#fff!important;border:none!important;
    padding:13px 14px!important;font-weight:600;
    font-size:13px;white-space:nowrap;
}
.modern-table td {
    padding:11px 14px;font-size:13px;
    border-bottom:1px solid #f1f5f9!important;vertical-align:middle;
}
.tbl-act-btn {
    width:28px;height:28px;border-radius:7px;border:none;
    display:inline-flex;align-items:center;justify-content:center;
    font-size:11px;cursor:pointer;transition:transform .15s;
    text-decoration:none;
}
.tbl-act-btn:hover { transform:scale(1.12); }
.act-view   { background:#dbeafe;color:#1d4ed8; }
.act-edit   { background:#e0f2fe;color:#0369a1; }
.act-key    { background:#fef9c3;color:#92400e; }
.act-toggle { background:#f0fdf4;color:#15803d; }
.act-del    { background:#fee2e2;color:#b91c1c; }
.tbl-act-cell { white-space:nowrap; }

/* ── View Toggle ────────────────────────────────────────── */
.btn-group .btn { border-radius:8px!important;padding:5px 10px;font-size:13px; }

/* ── Modal ──────────────────────────────────────────────── */
.tch-modal-header {
    background:linear-gradient(135deg,#4f46e5,#6366f1);
    border-radius:16px 16px 0 0!important; 
}
.modal-content { border-radius:16px!important; }

/* ── Wizard Tabs ─────────────────────────────────────────── */
.tch-wizard-nav {
    list-style:none;padding-left:0;
    border-bottom:2px solid #f1f5f9;margin:0;
}
.tch-wizard-nav .nav-item { margin-bottom:-2px; }
.tch-wizard-tab {
    display:flex;align-items:center;gap:6px;
    padding:10px 16px;font-size:13px;font-weight:500;
    color:#64748b;border-bottom:2px solid transparent;
    text-decoration:none;transition:.15s;
}
.tch-wizard-tab:hover { color:var(--primary); }
.tch-wizard-tab.active { color:var(--primary);border-bottom-color:var(--primary); }
.tab-num {
    width:20px;height:20px;border-radius:50%;
    background:#e2e8f0;color:#64748b;font-size:11px;
    display:inline-flex;align-items:center;justify-content:center;font-weight:700;
}
.tch-wizard-tab.active .tab-num { background:var(--primary);color:#fff; }

/* ── Academic path visual ───────────────────────────────── */
.acad-path-vis {
    display:flex;align-items:center;gap:8px;flex-wrap:wrap;
    padding:10px 14px;background:#f8fafc;
    border-radius:10px;border:1px solid #e2e8f0;
}
.path-chip {
    font-size:12px;font-weight:600;padding:3px 10px;border-radius:6px;
}
.path-stream { background:#eef2ff;color:#4f46e5; }
.path-desig  { background:#e0f2fe;color:#0369a1; }
.path-arr    { color:#94a3b8;font-size:10px; }

/* ── Form ───────────────────────────────────────────────── */
.form-label { font-size:13px;margin-bottom:4px; }
.form-control,.form-select { font-size:13px;border-radius:8px; }
.form-control:focus,.form-select:focus {
    border-color:#4f46e5;box-shadow:0 0 0 3px rgba(79,70,229,.15);
}
.req { color:#dc2626; }
.form-err { color:#dc2626;font-size:11px;margin-top:3px;min-height:14px; }

/* ── Password strength ──────────────────────────────────── */
.pwd-strength { height:4px;background:#e2e8f0;border-radius:2px; }
.pwd-fill { height:100%;border-radius:2px;transition:width .3s,background .3s; }

/* ── Bulk result ────────────────────────────────────────── */
.bulk-res-box {
    border:1px solid #e2e8f0;border-radius:10px;
    padding:14px;font-size:13px;
    max-height:200px;overflow-y:auto;background:#fafafa;
}

/* ── Pagination ─────────────────────────────────────────── */
.tch-page-btn {
    padding:5px 12px;border-radius:8px;
    border:1px solid #e2e8f0;background:#fff;
    font-size:13px;cursor:pointer;color:#475569;transition:.15s;
}
.tch-page-btn:hover,.tch-page-btn.active {
    background:#4f46e5;color:#fff;border-color:#4f46e5;
}
.tch-page-btn.disabled {
    opacity: .5;
    pointer-events: none;
}

.tch-page-btn.active {
    background: #4f46e5;
    color: #fff;
    border-color: #4f46e5;
}

/* ── Toast ──────────────────────────────────────────────── */
.toast { min-width:280px;border-radius:12px!important; }
.toast.bg-success { background:#16a34a!important;color:#fff!important; }
.toast.bg-danger  { background:#dc2626!important;color:#fff!important; }
.toast.bg-warning { background:#d97706!important;color:#fff!important; }
.toast-body { font-size:13px; }

/* ── Profile fields ─────────────────────────────────────── */
.pf-field {
    display:flex;flex-direction:column;gap:2px;
    padding:8px 10px;background:#f8fafc;border-radius:8px;
}
.pf-lbl {
    font-size:10px;font-weight:600;
    color:#94a3b8;text-transform:uppercase;letter-spacing:.5px;
}
.pf-val { font-size:13px;font-weight:500;color:#1e293b; }

/* ── Responsive ─────────────────────────────────────────── */
@media (max-width:767px) {
    #cardViewContainer { grid-template-columns:1fr 1fr; }
    .tch-actions-bar { width:100%; }
    .tch-search-input { width:100%;flex:1; }
    .tch-search-wrap { flex:1; }
    .tch-filter-sel { flex:1;min-width:0; }
    .modal-dialog { margin:8px; }
    .tbl-act-btn { width:24px;height:24px;font-size:10px; }
}
@media (max-width:480px) {
    #cardViewContainer { grid-template-columns:1fr; }
    .modal-body { padding:.875rem!important; }
    .modal-footer { padding:.75rem 1rem!important; }
    .tch-wizard-tab { padding:8px 10px;font-size:12px; }
}
</style>

<!-- ══ SCRIPTS ══════════════════════════════════════════════ -->
<script>
    /* ── Role guard ─────────────────────────────────────────── */
    var isSuperAdmin = '<%= Session["Role"]?.ToString() %>' === 'SuperAdmin';
    if (isSuperAdmin) {
        ['<%= pnlAddBtn.ClientID %>',
     '<%= pnlBulkBtn.ClientID %>',
     '<%= pnlReenrolBtn.ClientID %>']
            .forEach(function (id) {
                var el = document.getElementById(id);
                if (el) el.style.display = 'none';
            });
    }

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

    /* ── View switch ─────────────────────────────────────────── */
    function switchView(v) {
        document.getElementById('cardViewContainer').style.display = v === 'card' ? '' : 'none';
        document.getElementById('tableViewContainer').style.display = v === 'table' ? '' : 'none';
        document.getElementById('btnCardView').classList.toggle('active', v === 'card');
        document.getElementById('btnTableView').classList.toggle('active', v === 'table');
    }

    /* ── Client search ──────────────────────────────────────── */
    function clientSearch(val) {
        val = (val || '').toLowerCase().trim();
        document.querySelectorAll('.tch-card-wrapper').forEach(function (w) {
            var d = (w.dataset.search || '');
            w.querySelector('.tch-card').style.display =
                (!val || d.includes(val)) ? '' : 'none';
        });
        document.querySelectorAll('#<%= gvTeachers.ClientID %> tbody tr').forEach(function(r) {
        r.style.display =
            (!val || r.innerText.toLowerCase().includes(val)) ? '' : 'none';
    });
}

/* ── Wizard state ────────────────────────────────────────── */
var curTab = 1, totalTabs = 3;
function gotoTab(n, el) {
    if (n < 1 || n > totalTabs) return;
    curTab = n;
    for (var i = 1; i <= totalTabs; i++) {
        var p = document.getElementById('tab' + i);
        if (p) p.style.display = (i === n) ? '' : 'none';
    }
    document.querySelectorAll('.tch-wizard-tab').forEach(function(t, idx) {
        t.classList.toggle('active', idx + 1 === n);
    });
    document.getElementById('btnWizPrev').style.display = n > 1 ? '' : 'none';
    document.getElementById('btnWizNext').style.display = n < totalTabs ? '' : 'none';
    document.getElementById('<%= btnSaveTeacher.ClientID %>').style.display =
        n === totalTabs ? '' : 'none';
}
function wizNav(dir) {
    if (dir === 1 && !validateCurTab()) return;
    gotoTab(curTab + dir, null);
}

/* ── Modal openers ──────────────────────────────────────── */
function openAddModal() {
    if (isSuperAdmin) { showToast('SuperAdmin has view-only access.','warning'); return; }
    clearTeacherForm();
    document.getElementById('modalTitleText').textContent = 'Add New Teacher';
    document.getElementById('modalSubText').textContent   = 'Fill all required fields marked *';
    document.getElementById('<%= btnSaveTeacher.ClientID %>').value = 'Add Teacher';
    gotoTab(1, null);
    new bootstrap.Modal(document.getElementById('TeacherModal')).show();
}
function openModal() {
    document.getElementById('modalTitleText').textContent = 'Edit Teacher';
    document.getElementById('modalSubText').textContent   = 'Update teacher details';
    document.getElementById('<%= btnSaveTeacher.ClientID %>').value = 'Update Teacher';
    gotoTab(1, null);
    new bootstrap.Modal(document.getElementById('TeacherModal')).show();
}
function openBulkModal() {
    if (isSuperAdmin) { showToast('SuperAdmin has view-only access.','warning'); return; }
    new bootstrap.Modal(document.getElementById('BulkModal')).show();
}
function openReenrolModal() {
    if (isSuperAdmin) { showToast('SuperAdmin has view-only access.','warning'); return; }
    new bootstrap.Modal(document.getElementById('ReenrolModal')).show();
}

/* ── Clear form ─────────────────────────────────────────── */
function clearTeacherForm() {
    document.getElementById('<%= hfTeacherUserId.ClientID %>').value = '';
    var fields = [
        '<%= txtFullName.ClientID %>','<%= txtUsername.ClientID %>',
        '<%= txtEmail.ClientID %>','<%= txtPassword.ClientID %>',
        '<%= txtContact.ClientID %>','<%= txtEmpId.ClientID %>',
        '<%= txtDesignation.ClientID %>','<%= txtExperience.ClientID %>',
        '<%= txtQualification.ClientID %>','<%= txtJoinDate.ClientID %>',
        '<%= txtDOB.ClientID %>','<%= txtFatherName.ClientID %>',
        '<%= txtMotherName.ClientID %>','<%= txtEmgName.ClientID %>',
        '<%= txtEmgContact.ClientID %>','<%= txtAddress.ClientID %>',
        '<%= txtCity.ClientID %>','<%= txtCountry.ClientID %>',
        '<%= txtPincode.ClientID %>','<%= txtSkills.ClientID %>'
    ];
    fields.forEach(function(id) {
        var el = document.getElementById(id);
        if (el) { el.value = ''; el.classList.remove('is-invalid','is-valid'); }
    });
    document.querySelectorAll('.form-err').forEach(function(e){ e.textContent=''; });
    document.getElementById('acadPathVis').style.display = 'none';
}

/* ── Tab validation ─────────────────────────────────────── */
function validateCurTab() {
    if (curTab === 1) return validateTab1();
    if (curTab === 2) return validateTab2();
    return true;
}
function validateTab1() {
    var ok = true;
    var isEdit = document.getElementById('<%= hfTeacherUserId.ClientID %>').value !== '';

    function chk(selId, errId, test, msg) {
        var el = document.getElementById(selId);
        var e  = document.getElementById(errId);
        if (!test(el)) {
            e.textContent = msg; el.classList.add('is-invalid'); ok = false;
        } else {
            e.textContent = ''; el.classList.remove('is-invalid'); el.classList.add('is-valid');
        }
    }

    chk('<%= txtFullName.ClientID %>','errFullName',
        function(el){ return el.value.trim().length >= 3; },
        'Full name must be at least 3 characters.');

    chk('<%= txtUsername.ClientID %>','errUsername',
        function(el){ return /^[a-z0-9_]{3,50}$/.test(el.value.trim()); },
        'Lowercase letters, numbers, underscore only (3–50 chars).');

    chk('<%= txtEmail.ClientID %>','errEmail',
        function(el){ return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(el.value.trim()); },
        'Enter a valid email address.');

    if (!isEdit) {
        chk('<%= txtPassword.ClientID %>','errPassword',
            function(el){ return el.value.length >= 6; },
            'Password must be at least 6 characters.');
    }

    chk('<%= txtContact.ClientID %>','errContact',
        function(el){ return /^[0-9+]{10,15}$/.test(el.value.trim()); },
        'Enter a valid 10–15 digit contact number.');

    chk('<%= txtEmpId.ClientID %>','errEmpId',
        function(el){ return el.value.trim().length >= 2; },
        'Employee ID is required (min 2 characters).');

    return ok;
}
function validateTab2() {
    var ok = true;
    var stream = document.getElementById('<%= ddlStream.ClientID %>');
    var desig  = document.getElementById('<%= txtDesignation.ClientID %>');
    var exp    = document.getElementById('<%= txtExperience.ClientID %>');
    var join   = document.getElementById('<%= txtJoinDate.ClientID %>');

    function setE(el, errId, msg) {
        var e = document.getElementById(errId);
        if (msg) { e.textContent = msg; el.classList.add('is-invalid'); ok = false; }
        else      { e.textContent = ''; el.classList.remove('is-invalid'); el.classList.add('is-valid'); }
    }

    setE(stream, 'errStream',   (!stream.value || stream.value==='0') ? 'Please select a stream.' : '');
    setE(desig,  'errDesig',    desig.value.trim().length < 2         ? 'Designation is required.' : '');
    setE(exp,    'errExp',      (!exp.value || parseInt(exp.value) < 0) ? 'Enter valid experience (0+).' : '');
    setE(join,   'errJoinDate', !join.value                           ? 'Joining date is required.' : '');
    return ok;
}
function finalValidate() {
    if (isSuperAdmin) { showToast('SuperAdmin has view-only access.','warning'); return false; }
    var ok = true;
    var gender  = document.getElementById('<%= ddlGender.ClientID %>');
    var dob     = document.getElementById('<%= txtDOB.ClientID %>');
    var emgN    = document.getElementById('<%= txtEmgName.ClientID %>');
    var emgC    = document.getElementById('<%= txtEmgContact.ClientID %>');
    var addr    = document.getElementById('<%= txtAddress.ClientID %>');

    function setE(el, errId, msg) {
        var e = document.getElementById(errId);
        if (msg) { e.textContent = msg; ok = false; }
        else e.textContent = '';
    }
    setE(gender, 'errGender',  !gender.value                           ? 'Select gender.' : '');
    setE(dob,    'errDOB',     !dob.value                              ? 'DOB is required.' : '');
    setE(emgN,   'errEmgName', !emgN.value.trim()                      ? 'Emergency contact name required.' : '');
    setE(emgC,   'errEmgContact', !/^[0-9+]{10,15}$/.test(emgC.value.trim()) ? 'Valid emergency contact required.' : '');
    setE(addr,   'errAddress', !addr.value.trim()                      ? 'Address is required.' : '');
    if (!ok) showToast('Please fix errors before saving.','danger');
    return ok;
}

/* ── Username auto-generate ──────────────────────────────── */
function autoUsername() {
    var name = document.getElementById('<%= txtFullName.ClientID %>').value.trim();
    var user = document.getElementById('<%= txtUsername.ClientID %>');
    if (!user.value) {
        var gen = name.toLowerCase()
            .replace(/\s+/g,'_').replace(/[^a-z0-9_]/g,'').substring(0, 20);
        if (gen.length >= 3)
            user.value = gen + new Date().getFullYear().toString().slice(-2);
    }
}

/* ── Password visibility ─────────────────────────────────── */
function togglePwd(btn) {
    var inp = btn.previousElementSibling;
    var isText = inp.type === 'text';
    inp.type = isText ? 'password' : 'text';
    btn.innerHTML = '<i class="fa fa-' + (isText ? 'eye' : 'eye-slash') + '"></i>';
}

/* ── Password strength ──────────────────────────────────── */
document.addEventListener('DOMContentLoaded', function() {
    var pwdEl = document.getElementById('<%= txtPassword.ClientID %>');
    if (pwdEl) {
        pwdEl.addEventListener('input', function() {
            var v = this.value;
            var bar = document.getElementById('pwdBar');
            var fill = document.getElementById('pwdFill');
            var txt  = document.getElementById('pwdTxt');
            if (!v) { bar.style.display='none'; txt.textContent=''; return; }
            bar.style.display = '';
            var s = 0;
            if (v.length>=6) s++;
            if (v.length>=10) s++;
            if (/[A-Z]/.test(v)) s++;
            if (/[0-9]/.test(v)) s++;
            if (/[^A-Za-z0-9]/.test(v)) s++;
            var m = [{w:20,c:'#ef4444',l:'Weak'},{w:40,c:'#f97316',l:'Fair'},
                     {w:60,c:'#eab308',l:'Medium'},{w:80,c:'#84cc16',l:'Strong'},
                     {w:100,c:'#22c55e',l:'Very Strong'}];
            var x = m[Math.min(s,4)];
            fill.style.width = x.w+'%'; fill.style.background = x.c;
            txt.textContent = x.l; txt.style.color = x.c;
        });
    }

    // Default join date = today
    var jd = document.getElementById('<%= txtJoinDate.ClientID %>');
    if (jd && !jd.value) jd.value = new Date().toISOString().split('T')[0];
});

/* ── Re-enrol helpers ────────────────────────────────────── */
function toggleAll(chk) {
    document.querySelectorAll('.reenrol-chk').forEach(function(c) {
        c.checked = chk.checked;
    });
}
function gatherReenrolIds() {
    if (isSuperAdmin) { showToast('SuperAdmin has view-only access.','warning'); return false; }
    var ids = Array.from(document.querySelectorAll('.reenrol-chk:checked'))
                   .map(function(c){ return c.value; });
    if (!ids.length) {
        showToast('Please select at least one teacher to re-enrol.','warning');
        return false;
    }
    document.getElementById('<%= hfReenrolIds.ClientID %>').value = ids.join(',');
        return true;
    }

/* -------------Pagination---------------------------------*/
    var currentPage = 1;
    var pageSize = 10;
    var totalRecords = 0;

    function initPagination(total, page, size) {

        totalRecords = total;
        currentPage = page;
        pageSize = size;

        renderPagination();
        updatePaginationInfo();
    }

    function renderPagination() {

        var container = document.getElementById('paginationContainer');

        if (!container) return;

        container.innerHTML = '';

        var totalPages = Math.max(1, Math.ceil(totalRecords / pageSize));

        if (totalPages <= 1)
            return;

        container.appendChild(createPageBtn('‹ Prev', currentPage - 1, currentPage === 1));

        var start = Math.max(1, currentPage - 2);
        var end = Math.min(totalPages, currentPage + 2);

        if (start > 1) {
            container.appendChild(createPageBtn('1', 1, false, currentPage === 1));

            if (start > 2)
                container.appendChild(createDots());
        }

        for (var i = start; i <= end; i++) {
            container.appendChild(
                createPageBtn(i, i, false, currentPage === i)
            );
        }

        if (end < totalPages) {

            if (end < totalPages - 1)
                container.appendChild(createDots());

            container.appendChild(
                createPageBtn(totalPages, totalPages, false, currentPage === totalPages)
            );
        }

        container.appendChild(
            createPageBtn('Next ›', currentPage + 1, currentPage === totalPages)
        );
    }

    function createPageBtn(text, page, disabled, active) {

        var btn = document.createElement('button');

        btn.type = 'button';

        btn.className =
            'tch-page-btn'
            + (active ? ' active' : '')
            + (disabled ? ' disabled' : '');

        btn.innerHTML = text;

        if (!disabled) {

            btn.onclick = function () {
                goToPage(page);
            };
        }

        return btn;
    }

    function createDots() {

        var span = document.createElement('span');

        span.className = 'tch-page-btn disabled';

        span.innerHTML = '...';

        return span;
    }

    function goToPage(page) {

        document.getElementById('<%= hfCurrentPage.ClientID %>').value = page;

        __doPostBack('PageChange', page.toString());
   }

    function updatePaginationInfo() {

        var info = document.getElementById('paginationInfo');

        if (!info) return;

        if (totalRecords === 0) {
            info.innerHTML = 'No records found';
            return;
        }

        var start = ((currentPage - 1) * pageSize) + 1;

        var end = Math.min(currentPage * pageSize, totalRecords);

        info.innerHTML =
            'Showing ' + start +
            ' to ' + end +
            ' of ' + totalRecords +
            ' entries';
    }
</script>

</asp:Content>--%>

<%-- ================================================================================================ --%>




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
                    <i class="fa fa-file-excel me-1"></i>Bulk Upload
                </button>
            </asp:Panel>
            <asp:Panel ID="pnlReenrolBtn" runat="server">
                <button type="button" class="btn btn-outline-warning btn-sm rounded-pill px-3 fw-semibold"
                        onclick="openReenrolModal()">
                    <i class="fa fa-sync me-1"></i>Re-Enrol
                </button>
            </asp:Panel>
            <asp:Panel ID="pnlAddBtn" runat="server">
                <button type="button" class="btn btn-primary rounded-pill px-4 fw-semibold shadow-sm"
                        onclick="openAddModal()">
                    <i class="fa fa-plus me-1"></i>Add Teacher
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
<%--<div class="tch-filter-bar card border-0 shadow-sm rounded-4 px-3 py-2 mb-3">
    <div class="d-flex align-items-center gap-2 flex-wrap">
        <div class="tch-srch-wrap flex-grow-1" style="max-width:260px">
            <i class="fa fa-search tch-srch-ico"></i>
            <input type="text" id="txtSearchClient" class="form-control tch-srch-inp"
                   placeholder="Search teachers..." onkeyup="clientSearch(this.value)" />
        </div>
        <asp:DropDownList ID="ddlFilterStream" runat="server"
            CssClass="form-select tch-flt-sel"
            AutoPostBack="true" OnSelectedIndexChanged="ddlFilterStream_Changed">
            <asp:ListItem Value="0" Text="All Streams" />
        </asp:DropDownList>
        <asp:DropDownList ID="ddlFilterStatus" runat="server"
            CssClass="form-select tch-flt-sel"
            AutoPostBack="true" OnSelectedIndexChanged="ddlFilterStatus_Changed">
            <asp:ListItem Value="All"      Text="All Status" />
            <asp:ListItem Value="Active"   Text="Active" />
            <asp:ListItem Value="Inactive" Text="Inactive" />
        </asp:DropDownList>
        <span class="fw-semibold text-muted small ms-auto" id="recordCount"></span>
    </div>
</div>--%>


<%-- ══ FILTER BAR — below stats, above table ═══════════════ --%>
<div class="tch-filter-bar card border-0 shadow-sm rounded-4 px-3 py-2 mb-3">

    <div class="tch-filter-row">

        <!-- Search -->
        <div class="tch-srch-wrap">
            <i class="fa fa-search tch-srch-ico"></i>

            <input type="text"
                   id="txtSearchClient"
                   class="form-control tch-srch-inp"
                   placeholder="Search teachers..."
                   onkeyup="clientSearch(this.value)" />
        </div>

        <!-- Stream -->
        <asp:DropDownList ID="ddlFilterStream"
            runat="server"
            CssClass="form-select tch-flt-sel"
            AutoPostBack="true"
            OnSelectedIndexChanged="ddlFilterStream_Changed">

            <asp:ListItem Value="0" Text="All Streams" />

        </asp:DropDownList>

        <!-- Status -->
        <asp:DropDownList ID="ddlFilterStatus"
            runat="server"
            CssClass="form-select tch-flt-sel"
            AutoPostBack="true"
            OnSelectedIndexChanged="ddlFilterStatus_Changed">

            <asp:ListItem Value="All" Text="All Status" />
            <asp:ListItem Value="Active" Text="Active" />
            <asp:ListItem Value="Inactive" Text="Inactive" />

        </asp:DropDownList>

        <!-- Count -->
        <span id="recordCount" class="tch-record-count">
            Showing 11 of 12
        </span>

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

                <asp:BoundField DataField="EmployeeId" HeaderText="Emp ID" />
                <asp:BoundField DataField="Email"      HeaderText="Email"
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

<%-- ══ PAGINATION — server-side LinkButton pager ════════════
     KEY FIX: asp:Panel is required here. BuildPager() in code-behind
     dynamically adds LinkButton controls to this Panel on every request.
     Without this Panel the buttons have nowhere to render.
--%>
<div class="d-flex justify-content-between align-items-center flex-wrap gap-2 mt-3">
    <span class="small text-muted" id="pagerInfo"></span>
    <asp:Panel ID="pnlPager" runat="server"
        CssClass="d-flex align-items-center gap-1 flex-wrap justify-content-center" />
</div>

<%-- ══ ADD / EDIT MODAL ══════════════════════════════════════ --%>
<div class="modal fade" id="TeacherModal" tabindex="-1"
     aria-labelledby="teacherModalLabel" aria-hidden="true"
     data-bs-backdrop="static" data-bs-keyboard="false">
    <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
        <div class="modal-content rounded-4 border-0 shadow-lg">

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
                        <span class="tab-num">1</span> Account
                    </a>
                </li>
                <li class="nav-item">
                    <a class="tch-wiz-tab" href="#" onclick="gotoTab(2);return false;">
                        <span class="tab-num">2</span> Professional
                    </a>
                </li>
                <li class="nav-item">
                    <a class="tch-wiz-tab" href="#" onclick="gotoTab(3);return false;">
                        <span class="tab-num">3</span> Personal
                    </a>
                </li>
            </ul>

            <div class="modal-body p-4">

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

            <div class="modal-footer border-top-0 px-4 pb-4 pt-0 d-flex justify-content-between">
                <button type="button" class="btn btn-outline-secondary rounded-pill px-4"
                        id="btnWizPrev" onclick="wizNav(-1)" style="display:none">
                    <i class="fa fa-chevron-left me-1"></i>Prev
                </button>
                <div class="d-flex gap-2 ms-auto">
                    <button type="button" class="btn btn-outline-secondary rounded-pill px-4"
                            data-bs-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-primary rounded-pill px-4 fw-semibold"
                            id="btnWizNext" onclick="wizNav(1)">
                        Next <i class="fa fa-chevron-right ms-1"></i>
                    </button>
                    <asp:Button ID="btnSaveTeacher" runat="server"
                        Text="Add Teacher"
                        CssClass="btn btn-success rounded-pill px-4 fw-semibold"
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
    <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
        <div class="modal-content rounded-4 border-0 shadow-lg">
            <div class="modal-header tch-modal-hdr text-white">
                <h5 class="modal-title fw-bold"><i class="fa fa-id-card me-2"></i>Teacher Profile</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body p-4" id="teacherProfileBody">
                <div class="text-center py-4"><div class="spinner-border text-primary"></div></div>
            </div>
            <div class="modal-footer border-top pt-3 pb-3 px-4" id="viewModalFooter">
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
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content rounded-4 border-0 shadow-lg">
            <div class="modal-header bg-success text-white">
                <h5 class="modal-title fw-bold"><i class="fa fa-file-excel me-2"></i>Bulk Upload Teachers</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body p-4">
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
            <div class="modal-footer border-0 px-4 pb-4 pt-0">
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
    <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
        <div class="modal-content rounded-4 border-0 shadow-lg">
            <div class="modal-header bg-warning text-dark">
                <h5 class="modal-title fw-bold"><i class="fa fa-sync me-2"></i>Re-Enrol Teachers</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body p-4">
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
                    <div class="card-body py-2" style="max-height:280px;overflow-y:auto">
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
            <div class="modal-footer border-0 px-4 pb-4 pt-0 gap-2">
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

/* Header */
.tch-hdr-icon{
    width:36px;
    height:36px;
    border-radius:10px;
    background:var(--pri-lt);
    color:var(--pri);
    display:inline-flex;
    align-items:center;
    justify-content:center;
}

.dot-sep{
    width:5px;
    height:5px;
    background:#cbd5e1;
    border-radius:50%;
    display:inline-block;
}

/* Stats */
.tch-stat{
    border-radius:var(--rad);
    transition:transform .2s,box-shadow .2s;
    height:100%;
}

.tch-stat:hover{
    transform:translateY(-3px);
    box-shadow:0 6px 20px rgba(0,0,0,.1)!important;
}

.tch-stat .fs-5{
    word-break:break-word;
}

.tch-ico{
    width:40px;
    height:40px;
    border-radius:10px;
    display:flex;
    align-items:center;
    justify-content:center;
    flex-shrink:0;
}

.tch-stat-lbl{
    font-size:11px;
}

/* Filter bar */
.tch-filter-bar{
    background:#fff;
}

/* Filter Row */
.tch-filter-row{
    display:flex;
    align-items:center;
    gap:12px;
    width:100%;
    overflow-x:auto;
    padding-bottom:2px;
    flex-wrap:nowrap;
}

.tch-filter-row::-webkit-scrollbar{
    height:4px;
}

/* Search */
.tch-srch-wrap{
    position:relative;
    width:260px;
    min-width:240px;
    flex-shrink:0;
}

.tch-srch-ico{
    position:absolute;
    top:50%;
    left:10px;
    transform:translateY(-50%);
    color:#94a3b8;
    font-size:12px;
    z-index:2;
}

.tch-srch-inp{
    padding-left:32px;
    border-radius:8px;
    height:36px;
    font-size:13px;
}

/* Dropdowns */
.tch-flt-sel{
    width:150px;
    min-width:140px;
    height:36px;
    border-radius:8px;
    font-size:13px;
    padding:0 10px;
    flex-shrink:0;
}

/* Record Count */
.tch-record-count{
    margin-left:auto;
    min-width:max-content;
    white-space:nowrap;
    font-size:13px;
    font-weight:600;
    color:#64748b;
}

/* Table */
.tch-tbl-hdr th{
    background:linear-gradient(135deg,#4f46e5,#6366f1)!important;
    color:#fff!important;
    border:none!important;
    padding:12px 14px!important;
    font-weight:600;
    font-size:13px;
    white-space:nowrap;
}

.table-responsive{
    overflow-x:auto;
    -webkit-overflow-scrolling:touch;
}

.modern-table{
    min-width:900px;
}

.modern-table td{
    padding:10px 14px;
    font-size:13px;
    border-bottom:1px solid #f1f5f9!important;
    vertical-align:middle;
}

.tch-av{
    width:34px;
    height:34px;
    border-radius:50%;
    display:flex;
    align-items:center;
    justify-content:center;
    font-weight:700;
    font-size:11px;
    color:#fff;
    flex-shrink:0;
}

/* Action buttons */
.tbl-act-cell{
    white-space:nowrap;
    min-width:180px;
}

.tbl-act-btn{
    width:28px;
    height:28px;
    border-radius:7px;
    border:none;
    display:inline-flex;
    align-items:center;
    justify-content:center;
    font-size:11px;
    cursor:pointer;
    transition:transform .15s;
    text-decoration:none;
    flex-shrink:0;
}

.tbl-act-btn:hover{
    transform:scale(1.1);
}

.act-view{
    background:#dbeafe;
    color:#1d4ed8;
}

.act-edit{
    background:#e0f2fe;
    color:#0369a1;
}

.act-key{
    background:#fef9c3;
    color:#92400e;
}

.act-toggle{
    background:#f0fdf4;
    color:#15803d;
}

.act-del{
    background:#fee2e2;
    color:#b91c1c;
}

/* Academic tags */
.acad-tag{
    display:inline-block;
    padding:2px 8px;
    border-radius:6px;
    font-size:10px;
    font-weight:600;
    white-space:nowrap;
}

.tag-stream{
    background:#eef2ff;
    color:#4f46e5;
}

.tag-desig{
    background:#e0f2fe;
    color:#0369a1;
}

/* Pagination */
.tch-page-btn{
    display:inline-flex;
    align-items:center;
    justify-content:center;
    min-width:34px;
    height:34px;
    padding:0 10px;
    border-radius:8px;
    border:1px solid #e2e8f0;
    background:#fff;
    font-size:13px;
    color:#475569;
    text-decoration:none;
    transition:.15s;
    line-height:1;
}

.tch-page-btn:hover{
    background:var(--pri);
    color:#fff;
    border-color:var(--pri);
}

.tch-page-btn.active{
    background:var(--pri);
    color:#fff;
    border-color:var(--pri);
    font-weight:600;
}

.tch-page-btn.disabled,
.tch-page-btn[disabled]{
    opacity:.4;
    pointer-events:none;
    cursor:default;
}

/*════════════════════════════════════════════
  FIX MODALS HIDING BEHIND HEADER
════════════════════════════════════════════*/
.tch-modal-hdr { background:linear-gradient(135deg,#4f46e5,#6366f1);border-radius:16px 16px 0 0!important; }
.modal-content { border-radius:16px!important; }

.modal{
    z-index:99999 !important;
}

.modal-backdrop{
    z-index:99990 !important;
}

.modal-dialog{
    margin-top:90px !important;
}

/* Better modal content */
.modal-content{
    border:none !important;
    overflow:hidden;
    max-height:calc(100vh - 120px);
    border-radius:16px!important;
}

/* Scroll properly inside modal */
.modal-body{
    overflow-y:auto;
    overflow-x:hidden;
}

/* Responsive modal widths */
#TeacherModal .modal-dialog,
#ViewTeacherModal .modal-dialog,
#BulkModal .modal-dialog,
#ReenrolModal .modal-dialog{
    width:95%;
    max-width:1100px;
}

/* Wizard */
.tch-wiz-nav{
    list-style:none;
    padding-left:0;
    border-bottom:2px solid #f1f5f9;
    margin:0;
}

.tch-wiz-nav .nav-item{
    margin-bottom:-2px;
}

.tch-wiz-tab{
    display:flex;
    align-items:center;
    gap:6px;
    padding:10px 14px;
    font-size:13px;
    font-weight:500;
    color:#64748b;
    border-bottom:2px solid transparent;
    text-decoration:none;
    transition:.15s;
}

.tch-wiz-tab:hover{
    color:var(--pri);
}

.tch-wiz-tab.active{
    color:var(--pri);
    border-bottom-color:var(--pri);
}

.tab-num{
    width:20px;
    height:20px;
    border-radius:50%;
    background:#e2e8f0;
    color:#64748b;
    font-size:11px;
    display:inline-flex;
    align-items:center;
    justify-content:center;
    font-weight:700;
}

.tch-wiz-tab.active .tab-num{
    background:var(--pri);
    color:#fff;
}

/* Form */
.form-label{
    font-size:13px;
    margin-bottom:4px;
}

.form-control,
.form-select{
    font-size:13px;
    border-radius:8px;
}

.form-control:focus,
.form-select:focus{
    border-color:var(--pri);
    box-shadow:0 0 0 3px rgba(79,70,229,.15);
}

.req{
    color:#dc2626;
}

.form-err{
    color:#dc2626;
    font-size:11px;
    margin-top:3px;
    min-height:14px;
}

/* Password strength */
.pwd-strength{
    height:4px;
    background:#e2e8f0;
    border-radius:2px;
}

.pwd-fill{
    height:100%;
    border-radius:2px;
    transition:width .3s,background .3s;
}

/* Profile fields */
#teacherProfileBody{
    overflow-x:hidden;
    word-break:break-word;
}

.pf-field{
    display:flex;
    flex-direction:column;
    gap:2px;
    padding:8px 10px;
    background:#f8fafc;
    border-radius:8px;
    min-height:72px;
    height:100%;
    border:1px solid #eef2f7;
    transition:.2s;
}

.pf-field:hover{
    transform:translateY(-2px);
    box-shadow:0 4px 14px rgba(0,0,0,.06);
}

.pf-lbl{
    font-size:10px;
    font-weight:600;
    color:#94a3b8;
    text-transform:uppercase;
    letter-spacing:.5px;
}

.pf-val{
    font-size:13px;
    font-weight:500;
    color:#1e293b;
}

/* Bulk result */
.bulk-res-box{
    border:1px solid #e2e8f0;
    border-radius:10px;
    padding:14px;
    font-size:13px;
    max-height:200px;
    overflow-y:auto;
    background:#fafafa;
}

/* Toast */
.toast{
    min-width:280px;
    border-radius:12px!important;
}

.toast.bg-success{
    background:#16a34a!important;
    color:#fff!important;
}

.toast.bg-danger{
    background:#dc2626!important;
    color:#fff!important;
}

.toast.bg-warning{
    background:#d97706!important;
    color:#fff!important;
}

/*════════════════════════════════════════════
  TABLET RESPONSIVE
════════════════════════════════════════════*/
@media (max-width:992px){

    .modal-dialog{
        margin:70px auto 20px auto !important;
    }

    .modal-content{
        max-height:calc(100vh - 90px);
    }

    .tch-wiz-tab{
        padding:8px 10px;
        font-size:12px;
    }

    .modern-table{
        min-width:850px;
    }
}

/*════════════════════════════════════════════
  MOBILE RESPONSIVE
════════════════════════════════════════════*/
@media (max-width:768px){

    /* Header */
    .tch-hdr-icon{
        width:32px;
        height:32px;
    }

    h4{
        font-size:1.1rem;
    }

    /* Buttons */
    .btn{
        font-size:12px;
    }

    /* Stats */
    .tch-stat{
        padding:.9rem !important;
    }

    .tch-ico{
        width:34px;
        height:34px;
        font-size:13px;
    }

    /* Filters */
    .tch-filter-bar{
        padding:.75rem !important;
    }

    .tch-filter-row{
        gap:8px;
    }

    .tch-srch-wrap{
        min-width:190px;
    }

    .tch-flt-sel{
        min-width:120px;
        font-size:12px;
    }

    .tch-srch-inp{
        width:100%;
    }

    /* Modal */
    .modal-dialog{
        width:100% !important;
        margin:60px auto 10px auto !important;
        padding:0 8px;
    }

    .modal-content{
        border-radius:16px !important;
        max-height:calc(100vh - 70px);
    }

    .modal-body{
        padding:1rem !important;
    }

    .modal-footer{
        padding:.75rem 1rem!important;
        flex-wrap:wrap;
        gap:8px;
    }

    .modal-footer .btn,
    .modal-footer input[type=submit]{
        width:100%;
    }

    /* Wizard */
    .tch-wiz-nav{
        overflow-x:auto;
        flex-wrap:nowrap;
        white-space:nowrap;
        scrollbar-width:none;
    }

    .tch-wiz-nav::-webkit-scrollbar{
        display:none;
    }

    .tch-wiz-tab{
        flex-shrink:0;
        padding:8px 10px;
        font-size:12px;
    }

    /* Table */
    .modern-table{
        min-width:760px;
    }

    /* Profile */
    .pf-field{
        padding:10px;
    }

    .pf-val{
        font-size:12px;
    }

    /* Action buttons */
    .tbl-act-btn{
        width:26px;
        height:26px;
        font-size:10px;
    }

    /* Pagination */
    .tch-page-btn{
        min-width:30px;
        height:30px;
        font-size:12px;
    }
}

/*════════════════════════════════════════════
  EXTRA SMALL DEVICES
════════════════════════════════════════════*/
@media (max-width:480px){

    .modal-header h5{
        font-size:15px;
    }

    .tch-record-count{
        font-size:11px;
    }

    .tch-srch-wrap{
        min-width:170px;
    }

    .tch-flt-sel{
        min-width:110px;
    }

    .modern-table{
        min-width:700px;
    }

    .tch-stat .fs-5{
        font-size:15px !important;
    }

    .pf-field{
        min-height:auto;
    }
}
</style>

<%-- ══ SCRIPTS ════════════════════════════════════════════════ --%>
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
    var desig = document.getElementById('<%= txtDesignation.ClientID %>');
    var exp = document.getElementById('<%= txtExperience.ClientID %>');
    var join = document.getElementById('<%= txtJoinDate.ClientID %>');

    if (!setE('<%= ddlStream.ClientID %>', 'errStream',
        (!stream.value || stream.value === '0') ? 'Please select a stream.' : '')) ok = false;
    if (!setE('<%= txtDesignation.ClientID %>', 'errDesig',
        desig.value.trim().length < 2 ? 'Designation is required.' : '')) ok = false;
    if (!setE('<%= txtExperience.ClientID %>', 'errExp',
        (!exp.value || parseInt(exp.value) < 0 || parseInt(exp.value) > 60)
            ? 'Enter valid experience (0–60 years).' : '')) ok = false;

    // Joining date: must not be in future by more than 1 year, not too old
    var joinVal = join.value;
    if (!joinVal) {
        if (!setE('<%= txtJoinDate.ClientID %>', 'errJoinDate', 'Joining date is required.')) ok = false;
    } else {
        var jd = new Date(joinVal), now = new Date();
        var minJoin = new Date(); minJoin.setFullYear(now.getFullYear() - 50);
        var maxJoin = new Date(); maxJoin.setFullYear(now.getFullYear() + 1);
        if (jd < minJoin || jd > maxJoin) {
            if (!setE('<%= txtJoinDate.ClientID %>', 'errJoinDate', 'Joining date must be within the last 50 years.')) ok = false;
        } else setE('<%= txtJoinDate.ClientID %>', 'errJoinDate', '');
        }
        return ok;
    }

    function finalValidate() {
        if (isSuperAdmin) { showToast('SuperAdmin has view-only access.', 'warning'); return false; }
        var ok = true;
        var gender = document.getElementById('<%= ddlGender.ClientID %>');
    var dob = document.getElementById('<%= txtDOB.ClientID %>');
    var emgN = document.getElementById('<%= txtEmgName.ClientID %>');
    var emgC = document.getElementById('<%= txtEmgContact.ClientID %>');
    var addr = document.getElementById('<%= txtAddress.ClientID %>');

    if (!setE('<%= ddlGender.ClientID %>', 'errGender', !gender.value ? 'Select gender.' : '')) ok = false;

    // DOB: must be between 18 and 80 years old
    if (!dob.value) {
        if (!setE('<%= txtDOB.ClientID %>', 'errDOB', 'Date of birth is required.')) ok = false;
    } else {
        var d = new Date(dob.value), now = new Date();
        var age = now.getFullYear() - d.getFullYear();
        var m = now.getMonth() - d.getMonth();
        if (m < 0 || (m === 0 && now.getDate() < d.getDate())) age--;
        if (age < 18 || age > 80) {
            if (!setE('<%= txtDOB.ClientID %>', 'errDOB', 'Teacher age must be between 18 and 80 years.')) ok = false;
        } else setE('<%= txtDOB.ClientID %>', 'errDOB', '');
    }

    if (!setE('<%= txtEmgName.ClientID %>', 'errEmgName', !emgN.value.trim() ? 'Emergency contact name required.' : '')) ok = false;
    if (!setE('<%= txtEmgContact.ClientID %>', 'errEmgContact',
        !/^[0-9+]{10,15}$/.test(emgC.value.trim()) ? 'Valid emergency contact required.' : '')) ok = false;
    if (!setE('<%= txtAddress.ClientID %>', 'errAddress', !addr.value.trim() ? 'Address is required.' : '')) ok = false;

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
        var levels = [{ w: 20, c: '#ef4444', l: 'Weak' }, { w: 40, c: '#f97316', l: 'Fair' }, { w: 60, c: '#eab308', l: 'Medium' }, { w: 80, c: '#84cc16', l: 'Strong' }, { w: 100, c: '#22c55e', l: 'Very Strong' }];
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
