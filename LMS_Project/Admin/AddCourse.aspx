<%@ Page Title="Courses"
    Language="C#"
    MasterPageFile="~/Admin/AdminMaster.master"
    AutoEventWireup="true"
    CodeBehind="AddCourse.aspx.cs"
    Inherits="LearningManagementSystem.Admin.AddCourse" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server" />

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

    <asp:HiddenField ID="hfCourseId" runat="server" />

    <asp:Label ID="lblMsg" runat="server" CssClass="fw-bold mb-2 d-block" />

    <!-- HEADER -->
    <div class="d-flex justify-content-between align-items-center mb-3">
        <h3 class="mb-0">Courses</h3>

        <div class="d-flex gap-2">
            <div class="dropdown">
                <button class="btn btn-light border dropdown-toggle"
                    type="button" data-bs-toggle="dropdown">
                    <i class="fa-solid fa-filter"></i> Filter Status
                </button>
                <ul class="dropdown-menu">
                    <li>
                        <asp:LinkButton ID="lnkAll" runat="server"
                            CssClass="dropdown-item"
                            OnClick="FilterStatus_Click"
                            CommandArgument="All">All Courses</asp:LinkButton>
                    </li>
                    <li>
                        <asp:LinkButton ID="lnkActive" runat="server"
                            CssClass="dropdown-item"
                            OnClick="FilterStatus_Click"
                            CommandArgument="1">Active Only</asp:LinkButton>
                    </li>
                    <li>
                        <asp:LinkButton ID="lnkInactive" runat="server"
                            CssClass="dropdown-item"
                            OnClick="FilterStatus_Click"
                            CommandArgument="0">Inactive Only</asp:LinkButton>
                    </li>
                </ul>
            </div>

            <a href="#" data-bs-toggle="modal"
                data-bs-target="#CreateModal"
                class="btn btn-success">
                <i class="fa-solid fa-plus"></i> Add Course
            </a>
        </div>
    </div>

    <!-- GRID -->
    <div class="card shadow-sm border-0 mt-4">
        <div class="card-body p-0">
            <div class="table-responsive">

                <asp:GridView ID="gvCourses" runat="server"
                    CssClass="table align-middle mb-0"
                    AutoGenerateColumns="false"
                    GridLines="None"
                    OnRowCommand="gvCourses_RowCommand">

                    <Columns>

                        <asp:BoundField DataField="StreamName" HeaderText="Stream" />
                        <asp:BoundField DataField="CourseName" HeaderText="Course" />
                        <asp:BoundField DataField="CourseCode" HeaderText="Code" />

                        <asp:TemplateField HeaderText="Status">
                            <ItemTemplate>
                                <span class='badge <%# (bool)Eval("IsActive") ? "bg-success" : "bg-danger" %>'>
                                    <%# (bool)Eval("IsActive") ? "Active" : "Inactive" %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Actions">
                            <ItemTemplate>

                                <asp:LinkButton runat="server"
                                    CssClass="btn btn-sm btn-primary me-2"
                                    CommandName="EditRow"
                                    CommandArgument='<%# Eval("CourseId") %>'>
                                    <i class="fa-regular fa-pen-to-square"></i>
                                </asp:LinkButton>

                                <asp:LinkButton runat="server"
                                    CssClass="btn btn-sm btn-warning me-2"
                                    CommandName="Toggle"
                                    CommandArgument='<%# Eval("CourseId") %>'
                                    OnClientClick="return confirm('Change status?');">
                                    <i class="fa-solid fa-toggle-on"></i>
                                </asp:LinkButton>

                                <asp:LinkButton runat="server"
                                    CssClass="btn btn-sm btn-danger"
                                    CommandName="DeleteRow"
                                    CommandArgument='<%# Eval("CourseId") %>'
                                    OnClientClick="return confirm('Delete course?');">
                                    <i class="fa-solid fa-trash-can"></i>
                                </asp:LinkButton>

                            </ItemTemplate>
                        </asp:TemplateField>

                    </Columns>
                </asp:GridView>

            </div>
        </div>
    </div>

    <!-- ADD MODAL -->
    <div class="modal fade" id="CreateModal" tabindex="-1">
        <div class="modal-dialog modal-dialog-scrollable">
            <div class="modal-content">
                <div class="modal-header bg-success text-white">
                    <h5>Add Course</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>

                <div class="modal-body">

                    <label>Stream</label>
                    <asp:DropDownList ID="ddlStream" runat="server"
                        CssClass="form-select mb-2" />

                    <label>Course Name</label>
                    <asp:TextBox ID="txtCourseName" runat="server"
                        CssClass="form-control mb-2"
                        placeholder="Course Name" />

                    <label>Course Code</label>
                    <asp:TextBox ID="txtCourseCode" runat="server"
                        CssClass="form-control"
                        MaxLength="10"
                        placeholder="Course Code" />
                </div>

                <div class="modal-footer">
                    <button class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>

                    <asp:Button ID="btnSave" runat="server"
                        Text="Save"
                        CssClass="btn btn-success"
                        OnClick="btnSave_Click" />
                </div>
            </div>
        </div>
    </div>

    <!-- EDIT MODAL -->
    <div class="modal fade" id="EditModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header bg-success text-white">
                    <h5>Edit Course</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>

                <div class="modal-body">

                    <label>Stream</label>
                    <asp:DropDownList ID="ddlStreamEdit" runat="server"
                        CssClass="form-select mb-2" />

                    <label>Course Name</label>
                    <asp:TextBox ID="txtCourseNameEdit" runat="server"
                        CssClass="form-control mb-2" />

                    <label>Course Code</label>
                    <asp:TextBox ID="txtCourseCodeEdit" runat="server"
                        CssClass="form-control"
                        MaxLength="10" />
                </div>

                <div class="modal-footer">
                    <button class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>

                    <asp:Button ID="btnUpdate" runat="server"
                        Text="Update"
                        CssClass="btn btn-success"
                        OnClick="btnUpdate_Click" />
                </div>
            </div>
        </div>
    </div>

</asp:Content>