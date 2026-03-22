<%@ Page Title="Students" Language="C#" MasterPageFile="~/Admin/AdminMaster.master" AutoEventWireup="true" CodeBehind="AddStudent.aspx.cs" Inherits="LearningManagementSystem.Admin.Student" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server" />

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">
    <asp:HiddenField ID="hfStudentUserId" runat="server" />
    <asp:Label ID="lblMsg" runat="server" CssClass="fw-bold mb-2 d-block" />



    <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-3">

    <!-- LEFT -->
    <div>
        <h3 class="fw-bold mb-1">Students Management</h3>
        <small class="text-muted">Manage all students efficiently</small>
        <span class="mx-2 text-muted">|</span>
        <small class="text-muted">
            Last updated: <%= DateTime.Now.ToString("dd MMM yyyy hh:mm tt") %>
        </small>
    </div>

    <!-- RIGHT -->
    <div class="d-flex align-items-center gap-2 flex-wrap">

        <!-- 🔍 SEARCH -->
        <div class="search-box">
            <i class="fa fa-search"></i>
            <asp:TextBox ID="txtSearch" runat="server"
                CssClass="form-control"
                placeholder="Search students..."
                onkeyup="filterStudents()" />
        </div>

        <!-- 👁 FILTER -->
        <asp:LinkButton ID="btnToggleView" runat="server"
            CssClass="btn btn-outline-dark rounded-pill px-3"
            OnClick="ToggleView_Click">
            👁 View Inactive
        </asp:LinkButton>

        <!-- ➕ ADD -->
        <button type="button"
            class="btn btn-primary rounded-pill px-4 fw-semibold shadow-sm"
            onclick="openCreateModal()">
            <i class="fa fa-plus"></i> Add Student
        </button>

        <!-- 📂 BULK -->
        <button type="button"
            class="btn btn-success rounded-pill px-3"
            data-bs-toggle="modal"
            data-bs-target="#BulkModal">
            <i class="fa fa-file-import"></i>
        </button>

    </div>
</div>

  <%--stat--%>
    <div class="row mb-4">

    <div class="col-md-3">
        <div class="card stat-card shadow-sm border-0">
            <div class="card-body">
                <h6>Total Students</h6>
                <h3><%= TotalStudents %></h3>            
            </div>
        </div>
    </div>

    <div class="col-md-3">
        <div class="card stat-card bg-success text-white">
            <div class="card-body">
                <h6>Active</h6>
                <h3 class="stat-active"><%= ActiveStudents %></h3>
            </div>
        </div>
    </div>

    <div class="col-md-3">
        <div class="card stat-card bg-warning">
            <div class="card-body">
                <h6>Inactive</h6>
               <h3 class="stat-inactive"><%= InactiveStudents %></h3>
            </div>
        </div>
    </div>

    <div class="col-md-3">
        <div class="card stat-card bg-info text-white">
            <div class="card-body">
                <h6>New This Month</h6>
               <h3><%= NewStudents %></h3>
            </div>
        </div>
    </div>

</div>

<%---------------stat counts------------%>
  
<div class="card shadow-sm border-0 rounded-4 mb-4">
    <div class="card-body">
        <h5 class="fw-bold mb-3">📊 Students by Stream & Course</h5>

     <div class="stats-grid">
    <asp:Repeater ID="rptStats" runat="server">
        <ItemTemplate>
            <div class="stats-box">
                <div class="stats-header">
                    <span class="stream fw-bold text-dark"><%# Eval("StreamName") %></span>
                </div>

                <div class="stats-header">
                    <span class="course"><%# Eval("CourseName") %></span>
                </div>

                <div class="stats-body">
                    <h2><%# Eval("TotalStudents") %></h2>
                    <small>Students</small>
                </div>
            </div>
        </ItemTemplate>
    </asp:Repeater>
</div>

    </div>
</div>

<%--table--%>
   <div class="card border-0 shadow-sm rounded-4">
    <div class="table-responsive">

        <asp:GridView ID="gvStudents" runat="server"
            CssClass="table table-hover align-middle modern-table"
            AutoGenerateColumns="false"
            OnRowCommand="gvStudents_RowCommand">

            <HeaderStyle CssClass="table-header text-white" />

            <Columns>

                <asp:BoundField DataField="RollNumber" HeaderText="Roll No" />
                <asp:BoundField DataField="FullName" HeaderText="Student" />
                <asp:BoundField DataField="YearName" HeaderText="Year" />
                <asp:BoundField DataField="StreamName" HeaderText="Stream" />
                <asp:BoundField DataField="CourseName" HeaderText="Course" />


                <asp:TemplateField HeaderText="Actions">
                    <ItemTemplate>

                        <asp:LinkButton runat="server"
                            CommandName="ViewRow"
                            CommandArgument='<%# Eval("UserId") %>'
                            CssClass="action-btn view">
                            <i class="fa fa-eye"></i>
                        </asp:LinkButton>

                        <asp:LinkButton runat="server"
                            CommandName="EditRow"
                            CommandArgument='<%# Eval("UserId") %>'
                            CssClass="action-btn edit">
                            <i class="fa fa-pen"></i>
                        </asp:LinkButton>

                        <asp:LinkButton runat="server"
                            CommandName="Toggle"
                            CommandArgument='<%# Eval("UserId") %>'
                            CssClass="action-btn toggle"
                            OnClientClick='<%# "return toggleStudent(this," + Eval("UserId") + ");" %>'>
                            <i class="fa fa-sync"></i>
                        </asp:LinkButton>

                        <asp:LinkButton runat="server"
                            CommandName="DeleteRow"
                            CommandArgument='<%# Eval("UserId") %>'
                            CssClass="action-btn delete"
                            OnClientClick="return confirm('Delete student?');">
                            <i class="fa fa-trash"></i>
                        </asp:LinkButton>

                    </ItemTemplate>
                </asp:TemplateField>

            </Columns>

        </asp:GridView>

    </div>
</div>

<%--------------Ctreate model--------------%>
    <div class="modal fade" id="CreateModal">
    <div class="modal-dialog modal-lg modal-dialog-scrollable">
        <div class="modal-content rounded-4">

            <div class="modal-header bg-gradient-primary text-white">
                <h5 class="modal-title">Add Student</h5>
                <button class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>

            <div class="modal-body">
                <div class="row g-3">
                    <div class="col-md-4">
                        <label>Stream (Optional)</label>
                       <asp:DropDownList ID="ddlStream" runat="server"
                        CssClass="form-select"
                        AutoPostBack="true"
                        OnSelectedIndexChanged="ddlDepartment_SelectedIndexChanged" />
                    </div>
                     <div class="col-md-4">
                         <label>Course (Optional)</label>
                         <asp:DropDownList ID="ddlCourse" runat="server" CssClass="form-select" />
                     </div>
                    <div class="col-md-4">
                        <label>Course (Optional)</label>
                        <asp:DropDownList ID="ddlStudyLevel" runat="server" CssClass="form-select" />
                    </div>
                    <div class="col-md-4">
                        <label>Course (Optional)</label>
                        <asp:DropDownList ID="ddlSemester" runat="server" CssClass="form-select" />
                    </div>
                     <div class="col-md-4">
                         <label>Section (Optional)</label>
                         <asp:DropDownList ID="ddlSection" runat="server" CssClass="form-select" />
                     </div>

                    <div class="col-md-6">
                        <label>Username *</label>
                        <asp:TextBox ID="txtUsername" runat="server" CssClass="form-control" />
                    </div>

                    <div class="col-md-6">
                        <label>Email *</label>
                        <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" />
                    </div>

                    <div class="col-md-6">
                        <label>Full Name *</label>
                        <asp:TextBox ID="txtFullName" runat="server" CssClass="form-control" />
                    </div>

                    <div class="col-md-6">
                        <label>Roll Number *</label>
                        <asp:TextBox ID="txtRollNo" runat="server" CssClass="form-control" />                        
                    </div>

                    <div class="col-md-4">
                        <label>Gender</label>
                        <asp:DropDownList ID="ddlGender" runat="server" CssClass="form-select" />
                    </div>

                    <div class="col-md-4">
                        <label>DOB</label>
                        <asp:TextBox ID="txtDOB" runat="server" TextMode="Date" CssClass="form-control" />
                    </div>

                    <div class="col-md-4">
                        <label>Contact</label>
                        <asp:TextBox ID="txtContact" runat="server" CssClass="form-control" />
                    </div>

                </div>
            </div>

            <div class="modal-footer">
                <button class="btn btn-light" data-bs-dismiss="modal">Cancel</button>

                <asp:Button ID="btnSave" runat="server"
                    Text="Save Student"
                    CssClass="btn btn-primary"
                    OnClick="btnSave_Click"
                    OnClientClick="return validateStudent();" />
            </div>

        </div>
    </div>
</div>

    <div class="modal fade" id="EditModal" tabindex="-1">
        <div class="modal-dialog modal-lg modal-dialog-scrollable">
            <div class="modal-content">
                <div class="modal-header bg-success text-white">
                    <h5 class="modal-title">Edit Student Details</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="row g-3">
                        <div class="col-md-4">
                            <label>Course (Optional)</label>
                            <asp:DropDownList ID="txtCourseEdit" runat="server" CssClass="form-select" />
                        </div>
                        <div class="col-md-4">
                            <label>Section (Optional)</label>
                            <asp:DropDownList ID="txtSecctionEdit" runat="server" CssClass="form-select" />
                        </div>
                        <div class="col-md-6">
                            <label>Full Name*</label>
                            <asp:TextBox ID="txtFullNameEdit" runat="server" CssClass="form-control" />
                        </div>
                        <div class="col-md-6">
                            <label>Contact*</label>
                            <asp:TextBox ID="txtContactEdit" runat="server" CssClass="form-control" />
                        </div>
                        <div class="col-md-6">
                            <label>Email*</label>
                            <asp:TextBox ID="txtEmailEdit" runat="server" CssClass="form-control" />
                        </div>
                        <div class="col-md-6">
                            <label>Roll Number*</label>
                            <asp:TextBox ID="txtRollNumberEdit" runat="server" CssClass="form-control" />
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <asp:Button ID="btnUpdate" runat="server" Text="Update Student" CssClass="btn btn-success" OnClick="btnUpdate_Click" />
                </div>
            </div>
        </div>
    </div>

    <div class="modal fade" id="BulkModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header bg-primary text-white">
                    <h5 class="modal-title">Bulk Student Upload</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="alert alert-info small">
                        Please upload a CSV file with headers:
                        <br />
                      <strong>
                        Username, Email, FullName, RollNumber,
                        StreamId, LevelId, SemesterId, CourseId, SectionId,
                        Gender, DOB, Contact
                      </strong>

                    </div>
                    <div class="mb-3">
                        <label>Select CSV/Excel File</label>
                        <asp:FileUpload ID="fuBulk" runat="server" CssClass="form-control" />
                    </div>
                </div>
                <div class="modal-footer">
                    <button class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <asp:Button ID="btnUploadBulk" runat="server" Text="Upload & Process" CssClass="btn btn-primary" OnClick="btnUploadBulk_Click" />
                </div>
            </div>
        </div>
    </div>

<style>
.table-header {
    background: linear-gradient(135deg, #4f46e5, #6366f1);
}
.table-header th {
    background: linear-gradient(135deg, #4f46e5, #6366f1) !important;
    color: white;
    border: none;
    padding: 14px !important;
    font-weight: 600;
    letter-spacing: 0.5px;
}

.stats-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
    gap: 15px;
}

.stats-box {
    background: #908bef;
    color: white;
    border-radius: 18px;
    padding: 18px;
    transition: 0.3s;
    position: relative;
    overflow: hidden;
}

.stats-box:hover {
    transform: translateY(-6px) scale(1.03);
    box-shadow: 0 10px 30px rgba(0,0,0,0.2);
}

.stats-header {
    display: flex;
    justify-content: space-between;
    font-size: 13px;
    opacity: 0.9;
}

.stats-body h2 {
    font-size: 28px;
    margin: 10px 0 0;
    font-weight: bold;
}

.stats-body small {
    opacity: 0.8;
}
.search-box {
    position: relative;
}
.search-box i {
    position: absolute;
    top: 10px;
    left: 12px;
    color: #888;
}
.search-box input {
    padding-left: 35px;
    border-radius: 20px;
}
.modern-table tbody tr {
    transition: 0.2s;
    border-radius: 12px;
}

.modern-table tbody tr:hover {
    background: #f1f5f9;
    transform: scale(1.01);
}

.modern-table td {
    padding: 14px !important;
}

.action-btn {
    border-radius: 50%;
    padding: 8px;
}
.modern-table thead {
    background: #f8fafc;
    font-weight: 600;
}

.action-btn {
    padding: 6px 10px;
    border-radius: 8px;
    margin-right: 5px;
    display: inline-block;
    transition: .2s;
}

.action-btn.view { background: #e0f2fe; }
.action-btn.edit { background: #dcfce7; }
.action-btn.toggle { background: #fef9c3; }
.action-btn.delete { background: #fee2e2; }

.action-btn:hover {
    transform: scale(1.1);
}

.bg-gradient-primary {
    background: linear-gradient(45deg, #4f46e5, #6366f1);
}
.progress-bar {
    background: linear-gradient(90deg, #6366f1, #4f46e5);
    transition: width 0.5s ease-in-out;
}

.stat-card {
    border-radius: 18px;
    transition: all 0.3s ease;
    cursor: pointer;
    position: relative;
    overflow: hidden;
}

.stat-card:hover {
    transform: translateY(-8px) scale(1.02);
    box-shadow: 0 15px 35px rgba(0,0,0,0.15);
}

.stat-card::after {
    content: "";
    position: absolute;
    width: 100%;
    height: 100%;
    background: linear-gradient(120deg, transparent, rgba(255,255,255,0.3), transparent);
    top: 0;
    left: -100%;
    transition: 0.5s;
}

.stat-card:hover::after {
    left: 100%;
}
</style>
    
   <script>
       document.addEventListener("DOMContentLoaded", function () {
           var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'))
           var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
               return new bootstrap.Tooltip(tooltipTriggerEl)
           })
       });
    
        function showEditModal() {
            var myModal = new bootstrap.Modal(document.getElementById('EditModal'));
            myModal.show();
        }
       
        function hideMsg() {

        var alertBox = document.getElementById('<%= lblMsg.ClientID %>');

           if (!alertBox || alertBox.innerText.trim() === "")
           return;

           setTimeout(function () {

               // Smooth animation properties
               alertBox.style.transition =
               "opacity 0.5s ease, transform 0.5s ease, height 0.5s ease, margin 0.5s ease, padding 0.5s ease";

           alertBox.style.opacity = "0";
           alertBox.style.transform = "translateY(-20px)";
           alertBox.style.height = "0";
           alertBox.style.marginTop = "0";
           alertBox.style.marginBottom = "0";
           alertBox.style.paddingTop = "0";
           alertBox.style.paddingBottom = "0";
           alertBox.style.overflow = "hidden";

           setTimeout(function () {
               alertBox.remove();
            }, 500);

        }, 5000);
    }  

       function filterStudents() {
           let val = document.getElementById("<%= txtSearch.ClientID %>").value.toLowerCase();

        document.querySelectorAll("#<%= gvStudents.ClientID %> tbody tr")
               .forEach(r => {
                   r.style.display = r.innerText.toLowerCase().includes(val) ? "" : "none";
               });
       }

       function openCreateModal() {
           document.getElementById('<%= hfStudentUserId.ClientID %>').value = "";

    document.getElementById('<%= txtUsername.ClientID %>').value = "";
    document.getElementById('<%= txtEmail.ClientID %>').value = "";
    document.getElementById('<%= txtFullName.ClientID %>').value = "";
    document.getElementById('<%= txtRollNo.ClientID %>').value = "";
    document.getElementById('<%= txtContact.ClientID %>').value = "";

    new bootstrap.Modal(document.getElementById('CreateModal')).show();
}

       function validateStudent() {

           let email = document.getElementById('<%= txtEmail.ClientID %>').value;
    let name = document.getElementById('<%= txtFullName.ClientID %>').value;
    let roll = document.getElementById('<%= txtRollNo.ClientID %>').value;
    let dob = document.getElementById('<%= txtDOB.ClientID %>').value;
    let level = document.getElementById('<%= ddlStudyLevel.ClientID %>').selectedOptions[0].text;

    // ✅ Required fields
    if (!email || !name || !roll) {
        alert("Please fill all required fields");
        return false;
    }

    // ✅ Email validation
    let emailPattern = /^[^ ]+@[^ ]+\.[a-z]{2,3}$/;
    if (!email.match(emailPattern)) {
        alert("Invalid Email");
        return false;
    }

    // ✅ DOB + Age validation
    if (dob) {
        let age = new Date().getFullYear() - new Date(dob).getFullYear();

        if (level.includes("Engineering") && age < 16) {
            alert("Student too young for Engineering!");
            return false;
        }
    }

    return true;
}

       function toggleStudent(btn, userId) {

           let row = btn.closest("tr");

           fetch('AddStudent.aspx/ToggleStudentAjax', {
               method: 'POST',
               headers: { 'Content-Type': 'application/json' },
               body: JSON.stringify({ userId: userId })
           })
               .then(res => res.json())
               .then(data => {

                   let newStatus = data.d;
                   let showInactive = "<%= ShowInactive %>" === "True";

        // remove row visually
        if ((newStatus === "0" && !showInactive) ||
            (newStatus === "1" && showInactive)) {

            row.style.transition = "0.4s";
            row.style.opacity = "0";

            setTimeout(() => row.remove(), 400);
        }

        // update stats LIVE
        updateStatsLive(newStatus);

        // reload AFTER everything
        setTimeout(() => location.reload(), 500);
    });

           return false;
       }

       function updateStatsLive(status) {

           let active = document.querySelector(".stat-active");
           let inactive = document.querySelector(".stat-inactive");

           let activeCount = parseInt(active.innerText);
           let inactiveCount = parseInt(inactive.innerText);

           if (status === "1") {
               active.innerText = activeCount + 1;
               inactive.innerText = inactiveCount - 1;
           } else {
               active.innerText = activeCount - 1;
               inactive.innerText = inactiveCount + 1;
           }
       }
   </script>

</asp:Content>
