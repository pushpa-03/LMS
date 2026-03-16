<%@ Page Title="Students" Language="C#" MasterPageFile="~/Admin/AdminMaster.master" AutoEventWireup="true" CodeBehind="AddStudent.aspx.cs" Inherits="LearningManagementSystem.Admin.Student" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server" />

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">
    <asp:HiddenField ID="hfStudentUserId" runat="server" />
    <asp:Label ID="lblMsg" runat="server" CssClass="fw-bold mb-2 d-block" />



    <div class="d-flex justify-content-between align-items-center mb-3">
        <h3 class="mb-0">Student Management</h3>
        <div class="d-flex gap-2">
            <div class="d-none d-md-block">
                <div class="input-group">
                    <span class="input-group-text bg-white border-e-none">
                        <i class="fa-solid fa-magnifying-glass text-color-1"></i>
                    </span>

                    <asp:TextBox ID="txtSearch" runat="server"
                        CssClass="form-control border-s-none ps-0"
                        placeholder="Search Name/EmpID"
                        AutoPostBack="true"
                        OnTextChanged="btnFilter_Click" />

                    <asp:Button ID="btnFilter" runat="server"
                        Text="Search"
                        CssClass="btn btn-primary"
                        OnClick="btnFilter_Click" />
                </div>
            </div>

            <div class="dropdown">
                <button class="btn btn-light border dropdown-toggle" type="button" data-bs-toggle="dropdown">
                    <i class="fa-solid fa-filter"></i>Filter
                </button>
                <ul class="dropdown-menu">
                    <li>
                        <asp:LinkButton ID="lnkAll" runat="server" Text="All" CssClass="dropdown-item" OnClick="FilterStatus_Click" CommandArgument="All" /></li>
                    <li>
                        <asp:LinkButton ID="lnkActive" runat="server" Text="Active" CssClass="dropdown-item" OnClick="FilterStatus_Click" CommandArgument="1" /></li>
                    <li>
                        <asp:LinkButton ID="lnkInactive" runat="server" Text="Inactive" CssClass="dropdown-item" OnClick="FilterStatus_Click" CommandArgument="0" /></li>
                </ul>
            </div>

            <a href="#" data-bs-toggle="modal" data-bs-target="#CreateModal" class="btn btn-success">
                <i class="fa-solid fa-plus"></i>Add Student
            </a>

           <a href="#" data-bs-toggle="modal" data-bs-target="#BulkModal" class="btn btn-success">
                <i class="fa-solid fa-file-import"></i>
            </a>
        </div>
    </div>

    <div class="card shadow-sm border-0 mt-4">
        <div class="card-body p-0">
            <div class="table-responsive">
                <asp:GridView ID="gvStudents" runat="server" CssClass="table align-middle mb-0"
                    AutoGenerateColumns="false" GridLines="None" OnRowCommand="gvStudents_RowCommand">
                    <Columns>
                        <asp:BoundField DataField="RollNumber" HeaderText="Roll No" />
                        <asp:BoundField DataField="FullName" HeaderText="Name" />
                        <asp:BoundField DataField="YearName" HeaderText="Class/Year" />
                        <asp:BoundField DataField="StreamName" HeaderText="Stream" />
                        <asp:BoundField DataField="CourseName" HeaderText="Course" />

                        <asp:TemplateField HeaderText="Status">
                            <ItemTemplate>
                                <span class='badge <%# (bool)Eval("IsActive") ? "bg-success" : "bg-danger" %>'>
                                    <%# (bool)Eval("IsActive") ? "Active" : "Inactive" %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Actions">
                            <ItemTemplate>
                                <asp:LinkButton runat="server" CssClass="btn btn-sm btn-info text-white me-1"
                                    CommandName="ViewRow" CommandArgument='<%# Eval("UserId") %>' ToolTip="View Details">
                                    <i class="fa-solid fa-eye"></i>
                                </asp:LinkButton>
                                <asp:LinkButton runat="server" CssClass="btn btn-sm btn-primary me-2" CommandName="EditRow" CommandArgument='<%# Eval("UserId") %>'>
                                    <i class="fa-regular fa-pen-to-square"></i>
                                </asp:LinkButton>
                                <asp:LinkButton runat="server" CssClass="btn btn-sm btn-warning me-2" CommandName="Toggle" CommandArgument='<%# Eval("UserId") %>' OnClientClick="return confirm('Toggle Status?');">
                                    <i class="fa-solid fa-toggle-on"></i>
                                </asp:LinkButton>
                                <asp:LinkButton runat="server" CssClass="btn btn-sm btn-danger" CommandName="DeleteRow" CommandArgument='<%# Eval("UserId") %>' OnClientClick="return confirm('Delete Student?');">
                                    <i class="fa-solid fa-trash-can"></i>
                                </asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </div>
    </div>

    <div class="modal fade" id="CreateModal" tabindex="-1">
        <div class="modal-dialog modal-lg modal-dialog-scrollable">
            <div class="modal-content">
                <div class="modal-header bg-success text-white">
                    <h5 class="modal-title">Add Student Registration</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="row g-3">
                         
                        <div class="col-md-4">
                            <label>Stream (Optional)</label>
                            <asp:DropDownList ID="ddlStream" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="ddlDepartment_SelectedIndexChanged" />
                        </div>
                        <div class="col-md-4">
                            <label>Course (Optional)</label>
                            <asp:DropDownList ID="ddlCourse" runat="server" CssClass="form-select" />
                        </div>
                         <div class="col-md-4">
                             <label>Year/Class (Optional)</label>
                             <asp:DropDownList ID="ddlStudyLevel" runat="server" CssClass="form-select" />
                        </div>
                        <div class="col-md-4">
                            <label>Semester (Optional)</label>
                            <asp:DropDownList ID="ddlSemester" runat="server" CssClass="form-select" />
                        </div>
                         <div class="col-md-4">
                             <label>Section (Optional)</label>
                             <asp:DropDownList ID="ddlSection" runat="server" CssClass="form-select" />
                         </div>
                        <div class="col-md-6">
                            <label>Username*</label>
                            <asp:TextBox ID="txtUsername" runat="server" CssClass="form-control" />
                        </div>
                        <div class="col-md-6">
                            <label>Email*</label>
                            <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" />
                        </div>
                        <div class="col-md-6">
                            <label>Full Name*</label>
                            <asp:TextBox ID="txtFullName" runat="server" CssClass="form-control" />
                        </div>
                        <div class="col-md-6">
                            <label>Roll Number*</label>
                            <asp:TextBox ID="txtRollNo" runat="server" CssClass="form-control" />
                        </div>
                        <div class="col-md-4">
                            <label>Gender*</label>
                            <asp:DropDownList ID="ddlGender" runat="server" CssClass="form-select">
                                <asp:ListItem Text="Male" Value="Male" />
                                <asp:ListItem Text="Female" Value="Female" />
                                <asp:ListItem Text="Other" Value="Other" />
                            </asp:DropDownList>
                        </div>
                        <div class="col-md-4">
                            <label>DOB*</label>
                            <asp:TextBox ID="txtDOB" runat="server" CssClass="form-control" TextMode="Date" />
                        </div>
                        <div class="col-md-4">
                            <label>Contact*</label>
                            <asp:TextBox ID="txtContact" runat="server" CssClass="form-control" MaxLength="10" />
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <asp:Button ID="btnSave" runat="server" Text="Register Student" CssClass="btn btn-success" OnClick="btnSave_Click" />
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

    
   <script>
       document.addEventListener("DOMContentLoaded", function () {
           var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'))
           var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
               return new bootstrap.Tooltip(tooltipTriggerEl)
           })
       });
</script>
    

    <script>
        function showCreateModal() {
            var myModal = new bootstrap.Modal(document.getElementById('CreateModal'));
            myModal.show();
        }
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

    </script>

</asp:Content>
