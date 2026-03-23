<%@ Page Title="Admin | Subject Management" Language="C#" MasterPageFile="~/Admin/AdminMaster.master" AutoEventWireup="true" CodeBehind="Subjects.aspx.cs" Inherits="LearningManagementSystem.Admin.Subjects" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">
    <style>
        .table-header {
            background: linear-gradient(135deg, #4f46e5, #6366f1) !important;
            color: white;
        }

        .stat-card {
            border-radius: 16px;
            background: #f8fafc;
            border: 1px solid #e2e8f0;
            transition: 0.3s;
            height: 100%;
        }

        .stat-card:hover {
            transform: translateY(-4px);
        }

        .subject-card {
            background: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 16px;
            transition: 0.3s;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
        }

        .subject-card:hover {
            border-color: #6366f1;
            transform: translateY(-2px);
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

    <div class="container-fluid py-4">
        
        <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-3">
            <div>
                <h3 class="fw-bold mb-1">Subject Management</h3>
                <small class="text-muted">Manage academic streams and curriculum mapping</small>
            
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

        <div class="row g-4 mb-4">
            <asp:Repeater ID="rptStats" runat="server">
                <ItemTemplate>
                    <div class="col-md-3">
                        <div class="card stat-card">
                            <div class="card-body">
                                <h6 class="text-muted-custom fw-bold">TOTAL SUBJECTS</h6>
                                <h3 class="fw-bold mb-0"><%# Eval("TotalSubjects") %></h3>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="card stat-card">
                            <div class="card-body">
                                <h6 class="text-muted-custom fw-bold">MANDATORY</h6>
                                <h3 class="fw-bold mb-0 text-success"><%# Eval("MandatoryCount") %></h3>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="card stat-card">
                            <div class="card-body">
                                <h6 class="text-muted-custom fw-bold">ENROLLMENTS</h6>
                                <h3 class="fw-bold mb-0 text-primary"><%# Eval("TotalEnrollments") %></h3>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="card stat-card">
                            <div class="card-body">
                                <h6 class="text-muted-custom fw-bold">AVG PER SUBJECT</h6>
                                <h3 class="fw-bold mb-0 text-info"><%# Eval("AvgPerSubject") %></h3>
                            </div>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
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
</asp:Content>