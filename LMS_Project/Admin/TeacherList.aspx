<%@ Page Title="Teacher Directory" Language="C#" MasterPageFile="~/Admin/AdminMaster.master" AutoEventWireup="true" CodeBehind="TeacherList.aspx.cs" Inherits="LearningManagementSystem.Admin.TeacherList" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">
    <style>
        :root { --primary: #4e73df; --success: #1cc88a; --info: #36b9cc; --secondary: #858796; }
        body { font-family: 'Plus Jakarta Sans', sans-serif; color: #1e293b; }
        /* HEADER */
.page-header {
    display:flex; justify-content:space-between;
    align-items:center; flex-wrap:wrap;
    margin-bottom:20px;
}
.page-header h4 {
    font-weight:800; color:#1565c0;
}
        .card-hover { transition: all 0.3s ease; border: none; border-radius: 15px; overflow: hidden; }
        .card-hover:hover { transform: translateY(-5px); shadow: 0 10px 20px rgba(0,0,0,0.1); }
        .filter-section { background: #f8f9fc; padding: 20px; border-radius: 15px; margin-bottom: 25px; border: 1px solid #e3e6f0; }
        .teacher-avatar { width: 45px; height: 45px; background: #eaecf4; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: bold; color: #4e73df; }
        .badge-pill { padding: 0.5em 1em; border-radius: 50px; }
        .search-container { position: relative; }
        .search-container i { position: absolute; left: 15px; top: 12px; color: #b7b9cc; }
        .search-container .form-control { padding-left: 40px; border-radius: 25px; }

    </style>

    <div class="container-fluid py-1">
         
        <div class="d-flex justify-content-between align-items-center mb-4  ">           

             <div class="page-header">
                 <div>
                     <h4><i class="fa fa-book me-2"></i>Teacher Directory</h4>
                     <small class="text-muted">Analyze and manage your institute's faculty</small>
                     <span class="badge bg-primary rounded-pill">
                          Teachers
                     </span>
                     <span>|</span>
                     <small class="text-muted">
                         Last updated: <%= DateTime.Now.ToString("dd MMM yyyy hh:mm tt") %>
                     </small>
                 </div>
            </div>


            <a href="AddTeacher.aspx" class="btn btn-primary rounded-pill px-4 shadow-sm">
                <i class="fas fa-plus me-2"></i>New Teacher
            </a>
        </div>

        <div class="row g-4 mb-4">
            <div class="col-md-3">
                <div class="card card-hover border-start border-primary border-4 shadow-sm h-100 py-2">
                    <div class="card-body">
                        <div class="row align-items-center">
                            <div class="col mr-2">
                                <div class="text-xs font-weight-bold text-primary text-uppercase mb-1">Total Faculty</div>
                                <div class="h5 mb-0 font-weight-bold text-gray-800"><asp:Literal ID="litTotal" runat="server" Text="0" /></div>
                            </div>
                            <div class="col-auto"><i class="fas fa-users fa-2x text-gray-300"></i></div>
                        </div>
                    </div>
                </div>
            </div>
            </div>

        <div class="filter-section shadow-sm">
            <div class="row g-3 align-items-end">
                <div class="col-md-4">
                    <label class="form-label small fw-bold">Search Name/ID</label>
                    <div class="search-container">
                        <i class="fas fa-search"></i>
                        <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" placeholder="Type here..." AutoPostBack="true" OnTextChanged="Filter_Changed" />
                    </div>
                </div>
                <div class="col-md-3">
                    <label class="form-label small fw-bold">Stream</label>
                    <asp:DropDownList ID="ddlStream" runat="server" CssClass="form-select rounded-pill" AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed" />
                </div>
                <div class="col-md-3">
                    <label class="form-label small fw-bold">Status</label>
                    <asp:DropDownList ID="ddlStatus" runat="server" CssClass="form-select rounded-pill" AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed">
                        <asp:ListItem Text="All Status" Value="All" />
                        <asp:ListItem Text="Active Only" Value="1" />
                        <asp:ListItem Text="Inactive" Value="0" />
                    </asp:DropDownList>
                </div>
                <div class="col-md-2">
                    <asp:LinkButton ID="btnClear" runat="server" CssClass="btn btn-outline-secondary w-100 rounded-pill" OnClick="btnClear_Click">Reset</asp:LinkButton>
                </div>
            </div>
        </div>

        <div class="card shadow-sm border-0 rounded-4">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <asp:GridView ID="gvTeachers" runat="server" AutoGenerateColumns="false" CssClass="table table-hover align-middle mb-0" 
                        GridLines="None" OnRowCommand="gvTeachers_RowCommand">
                        <HeaderStyle CssClass="bg-light text-muted small text-uppercase" />
                        <Columns>
                            <asp:TemplateField HeaderText="Faculty Profile">
                                <ItemTemplate>
                                    <div class="d-flex align-items-center p-2">
                                        <div class="teacher-avatar me-3">
                                            <%# Eval("FullName").ToString().Substring(0,1) %>
                                        </div>
                                        <div>
                                            <div class="fw-bold text-dark"><%# Eval("FullName") %></div>
                                            <small class="text-muted"><%# Eval("EmployeeId") %></small>
                                        </div>
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:BoundField DataField="Stream" HeaderText="Department" />
                            <asp:BoundField DataField="Designation" HeaderText="Designation" />
                            
                            <asp:TemplateField HeaderText="Actions">
                                <ItemTemplate>
                                    <asp:LinkButton runat="server" CommandName="ViewDetails" CommandArgument='<%# Eval("UserId") %>' CssClass="btn btn-sm btn-white shadow-sm rounded-circle me-1" ToolTip="View Full Profile">
                                        <i class="fas fa-chart-line text-primary"></i>
                                    </asp:LinkButton>
                                    <asp:LinkButton runat="server" CommandName="EditRow" CommandArgument='<%# Eval("UserId") %>' CssClass="btn btn-sm btn-white shadow-sm rounded-circle">
                                        <i class="fas fa-edit text-info"></i>
                                    </asp:LinkButton>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                        <EmptyDataTemplate>
                            <div class="text-center p-5">
                                <img src="../assets/img/no-data.svg" style="width:150px" />
                                <p class="mt-3 text-muted">No teachers found matching your filters.</p>
                            </div>
                        </EmptyDataTemplate>
                    </asp:GridView>
                </div>
            </div>
        </div>
    </div>
</asp:Content>