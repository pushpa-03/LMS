<%@ Page Title="Teacher Insights" Language="C#" MasterPageFile="~/Admin/AdminMaster.master" AutoEventWireup="true" CodeBehind="TeacherDetails.aspx.cs" Inherits="LearningManagementSystem.Admin.TeacherDetails" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

    <div class="container py-4">
        <a href="javascript:history.back()" class="back-nav mb-3 d-inline-block text-decoration-none text-muted">
            <i class="fas fa-arrow-left"></i> Back to List
        </a>

        <div class="card shadow-sm border-0 mb-4 text-white rounded-4 overflow-hidden" 
             style="background: linear-gradient(135deg, #4e73df 0%, #224abe 50%, #1cc88a 100%);">
            <div class="card-body p-4">
                <div class="row align-items-center">
                    <div class="col-auto">
                        <asp:Image ID="imgProfile" runat="server" CssClass="rounded-circle bg-white shadow-lg object-fit-cover" 
                                  style="width:110px; height:110px; border: 4px solid rgba(255,255,255,0.2);" Visible="false" />
                        <div id="divInitial" runat="server" class="rounded-circle bg-white text-primary d-flex align-items-center justify-content-center shadow" 
                             style="width:100px; height:100px; font-size:40px; font-weight:bold;">
                            <asp:Literal ID="litInitial" runat="server" />
                        </div>
                    </div>
                    <div class="col">
                        <h2 class="fw-bold mb-1"><asp:Literal ID="litFullName" runat="server" /></h2>
                        <p class="mb-0 opacity-90">
                            <i class="fas fa-id-badge me-2"></i> <asp:Literal ID="litEmpId" runat="server" /> | 
                            <span class="badge bg-white text-primary px-3 rounded-pill ms-2"><asp:Literal ID="litDesignation" runat="server" /></span>
                        </p>
                    </div>
                    <div class="col-auto text-end">
                        <div class="h3 mb-0 fw-bold"><asp:Literal ID="litRating" runat="server" Text="4.8" /> <i class="fas fa-star text-warning"></i></div>
                        <small class="opacity-75">Instructor Performance</small>
                    </div>
                </div>
            </div>
        </div>

        <div class="row g-4">
            <div class="col-md-4">
                <div class="card border-0 shadow-sm rounded-4 mb-4">
                    <div class="card-body text-center py-4">
                        <h6 class="text-muted fw-bold mb-4 text-uppercase small">Syllabus Completion</h6>
                        <div style="width: 180px; margin: 0 auto; position: relative;">
                            <canvas id="progressChart"></canvas>
                            <div style="position: absolute; top: 60%; left: 50%; transform: translate(-50%, -10%); text-align: center;">
                                <h3 class="mb-0 fw-bold text-primary"><asp:Literal ID="litProgressText" runat="server" />%</h3>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="card border-0 shadow-sm rounded-4">
                    <div class="card-header bg-white border-0 pt-4 px-4">
                        <h5 class="fw-bold mb-0"><i class="fas fa-user-circle me-2 text-primary"></i>Personal Details</h5>
                    </div>
                    <div class="card-body px-4 pb-4">
                        <div class="detail-item mb-3">
                            <label class="text-muted small d-block">Contact Number</label>
                            <span class="fw-semibold"><asp:Literal ID="litContact" runat="server" /></span>
                        </div>
                        <div class="detail-item mb-3">
                            <label class="text-muted small d-block">Email Address</label>
                            <span class="fw-semibold"><asp:Literal ID="litEmail" runat="server" /></span>
                        </div>
                        <asp:PlaceHolder ID="phFullDetails" runat="server" Visible="false">
                            <div class="detail-item mb-3">
                                <label class="text-muted small d-block">Date of Birth</label>
                                <span class="fw-semibold"><asp:Literal ID="litDOB" runat="server" /></span>
                            </div>
                            <div class="detail-item mb-3">
                                <label class="text-muted small d-block">Experience</label>
                                <span class="fw-semibold"><asp:Literal ID="litExp" runat="server" /> Years</span>
                            </div>
                            <div class="detail-item">
                                <label class="text-muted small d-block">Address</label>
                                <span class="fw-semibold"><asp:Literal ID="litAddress" runat="server" /></span>
                            </div>
                        </asp:PlaceHolder>
                    </div>
                </div>
            </div>

            <div class="col-md-8">
                <div class="card border-0 shadow-sm rounded-4 h-100">
                    <div class="card-header bg-transparent border-0 pt-4 px-4 d-flex justify-content-between">
                        <h5 class="fw-bold mb-0">Assigned Subjects</h5>
                        <div class="badge bg-light text-primary border px-3 py-2 rounded-pill">Total: <asp:Literal ID="litSubCount" runat="server" /></div>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <asp:Repeater ID="rptSubjects" runat="server">
                                <HeaderTemplate>
                                    <table class="table table-hover align-middle">
                                        <thead class="bg-light small text-uppercase">
                                            <tr>
                                                <th>Subject</th>
                                                <th>Section</th>
                                                <th>Session</th>
                                                <%--<th>Status</th>--%>
                                            </tr>
                                        </thead>
                                        <tbody>
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <tr>
                                        <td class="fw-bold"><%# Eval("SubjectName") %></td>
                                        <td><span class="badge bg-light text-dark border"><%# Eval("SectionName") %></span></td>
                                        <td><%# Eval("SessionName") %></td>
                                        <%--<td>
                                            <span class='badge rounded-pill <%# Eval("Status").ToString() == "Present" ? "bg-success" : "bg-secondary" %>'>
                                                <%# Eval("Status") %>
                                            </span>
                                        </td>--%>
                                    </tr>
                                </ItemTemplate>
                                <FooterTemplate></tbody></table></FooterTemplate>
                            </asp:Repeater>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>


    <script>
        // Use C# variable for dynamic chart data
        const progressVal = <%= litProgressText.Text %>;
        const ctx = document.getElementById('progressChart').getContext('2d');
        new Chart(ctx, {
            type: 'doughnut',
            data: {
                datasets: [{
                    data: [progressVal, 100 - progressVal],
                    backgroundColor: ['#1cc88a', '#f8f9fc'],
                    borderWidth: 0,
                    circumference: 180,
                    rotation: 270,
                    cutout: '80%'
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                animation: { duration: 1500, easing: 'easeOutBounce' },
                plugins: { tooltip: { enabled: false } }
            }
        });
    </script>
</asp:Content>