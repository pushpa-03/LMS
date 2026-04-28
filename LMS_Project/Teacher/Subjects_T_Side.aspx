<%@ Page Title="Admin | Subject Management" Language="C#" MasterPageFile="~/Teacher/TeacherMaster.master" AutoEventWireup="true" CodeBehind="Subjects_T_Side.aspx.cs" Inherits="LMS_Project.Teacher.Subjects" %>

<asp:Content ID="headContent" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="bodyContent" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">
    <style>
        body { font-family: 'Segoe UI', sans-serif; }

        .page-header {
            display:flex; justify-content:space-between;
            align-items:center; flex-wrap:wrap;
            margin-bottom:20px;
        }
        .page-header h4 { font-weight:800; color:#1565c0; }

        .summary-card {
            background:#fff; border-radius:14px; padding:14px;
            display:flex; align-items:center; gap:12px;
            box-shadow:0 2px 8px rgba(0,0,0,.06);
            border-left:4px solid transparent; transition:all .2s ease;
        }
        .summary-card.blue   { border-left-color:#1565c0; }
        .summary-card.green  { border-left-color:#2e7d32; }
        .summary-card.red    { border-left-color:#c62828; }
        .summary-card.pink   { border-left-color:#9c4d9b; }
        .summary-card.yellow { border-left-color:#facc15; }
        .summary-card.orange { border-left-color:#f97316; }
        .summary-card:hover  { transform:translateY(-4px); box-shadow:0 12px 28px rgba(0,0,0,0.12); }

        .sc-icon {
            width:42px; height:42px; border-radius:12px;
            display:flex; align-items:center; justify-content:center; font-size:16px;
        }
        .sc-icon.blue   { background:#e3f2fd; color:#1565c0; }
        .sc-icon.green  { background:#e8f5e9; color:#2e7d32; }
        .sc-icon.red    { background:#ffebee; color:#c62828; }
        .sc-icon.pink   { background:#fce4ec; color:#9c4d9b; }
        .sc-icon.yellow { background:#fff8e1; color:#f59e0b; }
        .sc-icon.orange { background:#fff3e0; color:#f97316; }

        .sc-val { font-size:20px; font-weight:800; color:#263238; }
        .sc-lbl { font-size:11px; font-weight:700; color:#90a4ae; }

        .action-btn {
            padding:8px 12px; border-radius:8px; transition:0.2s;
            text-decoration:none; display:inline-flex;
            align-items:center; justify-content:center;
        }

        .badge-mandatory { background:#dcfce7; color:#166534; border:1px solid #bbf7d0; }
        .badge-elective  { background:#fef9c3; color:#854d0e; border:1px solid #fef08a; }
        .text-muted-custom { color:#64748b; font-size:0.85rem; }
    </style>

    <div class="container-fluid">

        <%-- HEADER --%>
        <div class="page-header">
            <div>
                <h4><i class="fa fa-book me-2"></i>My Subjects</h4>
                <small class="text-muted">Subjects assigned to you</small>
                <span>|</span>
                <small class="text-muted">
                    Last updated: <%= DateTime.Now.ToString("dd MMM yyyy hh:mm tt") %>
                </small>
            </div>

            <div class="d-flex align-items-center gap-3">
                <div class="form-check form-switch mb-0 bg-light rounded-pill px-3 py-1 border d-flex align-items-center gap-2" style="min-height:38px;">
                    <asp:CheckBox ID="chkStatus" runat="server" AutoPostBack="true"
                        OnCheckedChanged="chkStatus_CheckedChanged"
                        CssClass="form-check-input ms-0 mt-0" role="switch" />
                    <label class="form-check-label fw-semibold small mb-0" for="<%= chkStatus.ClientID %>">
                        <%= chkStatus.Checked ? "Viewing Inactive" : "Viewing Active" %>
                    </label>
                </div>
            </div>
        </div>

        <%-- STATS --%>
        <div class="row g-3 mb-4 my-3">
            <asp:Repeater ID="rptStats" runat="server">
                <ItemTemplate>
                    <div class="col-md-2">
                        <div class="summary-card blue">
                            <div class="sc-icon blue"><i class="fa fa-book"></i></div>
                            <div>
                                <div class="sc-val"><%# Eval("TotalSubjects") %></div>
                                <div class="sc-lbl">Total</div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-2">
                        <div class="summary-card yellow">
                            <div class="sc-icon yellow"><i class="fa fa-star"></i></div>
                            <div>
                                <div class="sc-val"><%# Eval("MandatoryCount") %></div>
                                <div class="sc-lbl">Mandatory</div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-2">
                        <div class="summary-card pink">
                            <div class="sc-icon pink"><i class="fa fa-users"></i></div>
                            <div>
                                <div class="sc-val"><%# Eval("TotalEnrollments") %></div>
                                <div class="sc-lbl">Enrollments</div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-2">
                        <div class="summary-card orange">
                            <div class="sc-icon orange"><i class="fa fa-chart-line"></i></div>
                            <div>
                                <div class="sc-val"><%# Eval("AvgPerSubject") %></div>
                                <div class="sc-lbl">Average</div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-2">
                        <div class="summary-card green">
                            <div class="sc-icon green"><i class="fa fa-check"></i></div>
                            <div>
                                <div class="sc-val"><%# Eval("ActiveCount") %></div>
                                <div class="sc-lbl">Active</div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-2">
                        <div class="summary-card red">
                            <div class="sc-icon red"><i class="fa fa-times"></i></div>
                            <div>
                                <div class="sc-val"><%# Eval("InactiveCount") %></div>
                                <div class="sc-lbl">Inactive</div>
                            </div>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>

        <asp:Label ID="lblMsg" runat="server" CssClass="alert alert-info d-block mb-4" Visible="false"></asp:Label>

        <%-- SUBJECT CARDS --%>
        <div class="row g-4">
            <asp:Repeater ID="rptSubjects" runat="server">
                <ItemTemplate>
                    <div class="col-xl-4 col-md-6">
                        <div class="card h-100 border-0 shadow-sm rounded-4">
                            <div class="card-body p-4">

                                <div class="d-flex justify-content-between align-items-start mb-3">
                                    <div>
                                        <h5 class="fw-bold mb-1"><%# Eval("SubjectName") %></h5>
                                        <span class="badge bg-light text-dark border small">
                                            Code: <%# Eval("SubjectCode") %>
                                        </span>
                                    </div>
                                    <%# (Eval("IsMandatory") != DBNull.Value && Convert.ToBoolean(Eval("IsMandatory")))
                                        ? "<span class='badge rounded-pill px-3 py-2 badge-mandatory'>MANDATORY</span>"
                                        : "<span class='badge rounded-pill px-3 py-2 badge-elective'>ELECTIVE</span>" %>
                                </div>

                                <div class="mb-4">
                                    <div class="d-flex align-items-center text-primary fw-semibold small mb-1">
                                        <i class="fa fa-layer-group me-2"></i>
                                        <%# Eval("StreamName") ?? "—" %>
                                    </div>
                                    <div class="text-muted small">
                                        <i class="fa fa-graduation-cap me-2"></i>
                                        <%# Eval("CourseName") ?? "—" %>
                                    </div>
                                </div>

                                <div class="row g-2 mb-4">
                                    <div class="col-6">
                                        <div class="p-2 rounded bg-light border text-center">
                                            <div class="text-muted" style="font-size:0.7rem;">SEMESTER</div>
                                            <div class="fw-bold small"><%# Eval("SemesterName") ?? "—" %></div>
                                        </div>
                                    </div>
                                    <div class="col-6">
                                        <div class="p-2 rounded bg-light border text-center">
                                            <div class="text-muted" style="font-size:0.7rem;">STUDENTS</div>
                                            <div class="fw-bold small"><%# Eval("StudentCount") %></div>
                                        </div>
                                    </div>
                                </div>

                                <div>
                                    <a href='SubjectDetails_T_Side.aspx?SubjectId=<%# Eval("SubjectId") %>'
                                       class="btn btn-primary action-btn w-100 fw-semibold">
                                        <i class="fa fa-cog me-2"></i> Manage Content
                                    </a>
                                </div>

                            </div>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>

        <asp:PlaceHolder ID="phEmpty" runat="server" Visible="false">
            <div class="card p-5 text-center mt-4">
                <i class="fa fa-search-minus fa-3x text-muted mb-3"></i>
                <h5 class="text-muted">No subjects found</h5>
                <p class="mb-0 text-muted-custom">Use the toggle to view inactive subjects.</p>
            </div>
        </asp:PlaceHolder>

    </div>
</asp:Content>