<%@ Page Title="Courses"
    Language="C#"
    MasterPageFile="~/Admin/AdminMaster.master"
    AutoEventWireup="true"
    CodeBehind="AddCourse.aspx.cs"
    Inherits="LearningManagementSystem.Admin.AddCourse" %>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

        <div class="toast-container position-fixed top-0 end-0 p-3">
            <div id="liveToast" class="toast align-items-center text-white bg-success border-0">
                <div class="d-flex">
                    <div class="toast-body" id="toastMsg"></div>
                    <button type="button" class="btn-close btn-close-white me-2 m-auto"
                        data-bs-dismiss="toast"></button>
                </div>
            </div>
        </div>
    <asp:HiddenField ID="hfCourseId" runat="server" />

    <asp:Label ID="lblMsg" runat="server"
    Visible="false"
    CssClass="alert d-block mb-3"
    EnableViewState="false" />

    <!-- HEADER -->
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h3 class="fw-bold mb-1">Courses Management</h3>
            <small class="text-muted">Admin Panel to manage courses</small>
            <span class="badge bg-primary rounded-pill">
                <%# Eval("CourseCount") %> Courses
            </span>
            <span>|</span>
            <small class="text-muted">
                Last updated: <%= DateTime.Now.ToString("dd MMM yyyy hh:mm tt") %>
            </small>
        </div>

        <div class="d-flex gap-2">
            <%--<button class="btn btn-sm btn-outline-dark rounded-pill px-3"
                data-bs-toggle="collapse"
                data-bs-target="#stream_<%# Eval("StreamId") %>">
                👁 View
            </button>--%>

            <div class="dropdown">
                <button class="btn btn-outline-dark rounded-pill dropdown-toggle"
                    data-bs-toggle="dropdown">
                    Filter
                </button>
                <ul class="dropdown-menu">
                    <li><asp:LinkButton runat="server" CssClass="dropdown-item"
                        OnClick="FilterStatus_Click" CommandArgument="1">Active</asp:LinkButton></li>
                    <li><asp:LinkButton runat="server" CssClass="dropdown-item"
                        OnClick="FilterStatus_Click" CommandArgument="0">Inactive</asp:LinkButton></li>
                </ul>
            </div>

            <a href="#" data-bs-toggle="modal" data-bs-target="#CreateModal"
               class="btn btn-primary rounded-pill px-4">
                + Add Course
            </a>

        </div>
    </div>

    <!-- ================= STATS ================= -->
    <div class="row g-3 mb-4">

    <div class="col-md-4">
        <div class="card border-0 shadow-sm stat-card d-flex flex-row align-items-center p-3">
            <div class="icon-box bg-primary me-3">
                <i class="fa fa-book"></i>
            </div>
            <div>
                <h6 class="text-muted mb-1">Total Courses</h6>
                <h4 class="fw-bold mb-0">
                    <asp:Label ID="lblTotal" runat="server" />
                </h4>
            </div>
        </div>
    </div>

    <div class="col-md-4">
        <div class="card border-0 shadow-sm stat-card d-flex flex-row align-items-center p-3">
            <div class="icon-box bg-success me-3">
                <i class="fa fa-check-circle"></i>
            </div>
            <div>
                <h6 class="text-success mb-1">Active</h6>
                <h4 class="fw-bold mb-0">
                    <asp:Label ID="lblActive" runat="server" />
                </h4>
            </div>
        </div>
    </div>

    <div class="col-md-4">
        <div class="card border-0 shadow-sm stat-card d-flex flex-row align-items-center p-3">
            <div class="icon-box bg-danger me-3">
                <i class="fa fa-times-circle"></i>
            </div>
            <div>
                <h6 class="text-danger mb-1">Inactive</h6>
                <h4 class="fw-bold mb-0">
                    <asp:Label ID="lblInactive" runat="server" />
                </h4>
            </div>
        </div>
    </div>

</div>

    <!-- SEARCH -->
    <div class="card p-3 mb-3 shadow-sm border-0">
        <div class="input-group">
            <span class="input-group-text bg-white">🔍</span>


            <input type="text" id="txtSearch" runat="server"
                   class="form-control"
                   placeholder="Search course..."
                   list="courseList"
                   onkeyup="this.form.submit();" />

            <datalist id="courseList">
                <asp:Repeater ID="rptCourseSuggestions" runat="server">
                    <ItemTemplate>
                        <option value='<%# Eval("CourseName") %>' />
                    </ItemTemplate>
                </asp:Repeater>
            </datalist>
        </div>
    </div>

    <!-- TABLE -->
    <div class="card border-0 shadow rounded-4">

        <div class="table-responsive">
            

            <!-- ================= STREAM + COURSE VIEW ================= -->
                <asp:Repeater ID="rptStreams" runat="server" OnItemDataBound="rptStreams_ItemDataBound">
                    <ItemTemplate>
                        
                        <div class="stream-card mb-4">

                            <!-- STREAM HEADER -->
                            <div class="stream-header d-flex justify-content-between align-items-center"
                                data-bs-toggle="collapse"
                                data-bs-target="#stream_<%# Eval("StreamId") %>">

                                <div>
                                    <h5 class="stream-title">
                                        📚 <%# Eval("StreamName") %>
                                    </h5>

                                    <span class="badge stream-badge">
                                        <%# Eval("CourseCount") %> Courses
                                    </span>
                                </div>

                                <div class="stream-toggle">
                                    <i class="fa-solid fa-chevron-down"></i>
                                </div>

                            </div>

                            <!-- COURSE LIST -->
                            <div id="stream_<%# Eval("StreamId") %>" class="collapse show">

                                <div class="course-container">

                                    <asp:GridView ID="gvInnerCourses" runat="server"
                                        CssClass="table course-table mb-0"
                                        AutoGenerateColumns="false"
                                        GridLines="None"
                                        OnRowCommand="gvCourses_RowCommand"
                                        AllowPaging="true"
                                        PageSize="5"
                                        OnPageIndexChanging="gvCourses_PageIndexChanging">

                                        <EmptyDataTemplate>
                                            <div class="text-center p-4">
                                                <i class="fa fa-book fa-2x text-muted mb-2"></i>
                                                <p class="text-muted">No Courses in this Stream</p>
                                            </div>
                                        </EmptyDataTemplate>

                                        <Columns>

                                            <asp:TemplateField HeaderText="Course">
                                                <ItemTemplate>
                                                    <div class="course-item">
                                                        🎓 <span class="fw-semibold"><%# Eval("CourseName") %></span>
                                                    </div>
                                                </ItemTemplate>
                                            </asp:TemplateField>

                                            <asp:TemplateField HeaderText="Code">
                                                <ItemTemplate>
                                                    <span class="course-code">
                                                        <%# Eval("CourseCode") %>
                                                    </span>
                                                </ItemTemplate>
                                            </asp:TemplateField>

                                            <asp:TemplateField HeaderText="Actions">
                                                <ItemTemplate>

                                                    <asp:LinkButton runat="server"
                                                        CssClass="btn btn-sm action-btn edit"
                                                        ToolTip="Edit Course"
                                                        CommandName="EditRow"
                                                        CommandArgument='<%# Eval("CourseId") %>'>
                                                        ✏
                                                    </asp:LinkButton>

                                                    <asp:LinkButton runat="server"
                                                        CssClass="btn btn-sm action-btn toggle"
                                                        ToolTip="Toggle Status"
                                                        CommandName="Toggle"
                                                        OnClientClick="return confirm('Change course status?');"
                                                        CommandArgument='<%# Eval("CourseId") %>'>
                                                        🔄
                                                    </asp:LinkButton>

                                                    <asp:LinkButton runat="server"
                                                        CssClass="btn btn-sm action-btn delete"
                                                        ToolTip="Delete Course"
                                                        OnClientClick="return confirm('Are you sure to delete?');"
                                                        CommandName="DeleteRow"
                                                        CommandArgument='<%# Eval("CourseId") %>'>
                                                        🗑
                                                    </asp:LinkButton>

                                                </ItemTemplate>
                                            </asp:TemplateField>

                                        </Columns>

                                    </asp:GridView>

                                </div>

                            </div>

                        </div>

                    </ItemTemplate>

                    <FooterTemplate>
                        <asp:PlaceHolder runat="server" Visible='<%# rptStreams.Items.Count == 0 %>'>
                            <div class="text-center p-5">
                                <i class="fa fa-database fa-3x text-muted mb-3"></i>
                                <h5>No Streams Found</h5>
                                <p class="text-muted">Click "Add Course" to create one</p>
                            </div>
                        </asp:PlaceHolder>
                    </FooterTemplate>

                </asp:Repeater>

        </div>
    </div>

    <!-- ADD MODAL -->
    <div class="modal fade" id="CreateModal">
        <div class="modal-dialog">
            <div class="modal-content">

                <div class="modal-header bg-primary text-white">
                    <h5>Add Course</h5>
                    <button class="btn-close" data-bs-dismiss="modal"></button>
                </div>

                <div class="modal-body">

                    <asp:DropDownList ID="ddlStream" runat="server"
                        CssClass="form-select mb-2" />

                    <asp:TextBox ID="txtCourseName" runat="server"
                        CssClass="form-control mb-2"
                        placeholder="Course Name" />

                    <asp:TextBox ID="txtCourseCode" runat="server"
                        CssClass="form-control"
                        placeholder="Course Code" />

                </div>

                <div class="modal-footer">
                    <button class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <asp:Button ID="btnSave" runat="server"
                        Text="Save"
                        CssClass="btn btn-primary"
                        OnClick="btnSave_Click" />
                </div>

            </div>
        </div>
    </div>

    <!-- EDIT MODAL -->
    <div class="modal fade" id="EditModal">
        <div class="modal-dialog">
            <div class="modal-content">

                <div class="modal-header bg-primary text-white">
                    <h5>Edit Course</h5>
                    <button class="btn-close" data-bs-dismiss="modal"></button>
                </div>

                <div class="modal-body">

                    <asp:DropDownList ID="ddlStreamEdit" runat="server"
                        CssClass="form-select mb-2" />

                    <asp:TextBox ID="txtCourseNameEdit" runat="server"
                        CssClass="form-control mb-2" />

                    <asp:TextBox ID="txtCourseCodeEdit" runat="server"
                        CssClass="form-control" />

                </div>

                <div class="modal-footer">
                    <button class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <asp:Button ID="btnUpdate" runat="server"
                        Text="Update"
                        CssClass="btn btn-primary"
                        OnClick="btnUpdate_Click" />
                </div>

            </div>
        </div>
    </div>

    

    <style>
        .stat-card {
            border-radius: 16px;
            transition: all .25s ease;
            cursor: pointer;
        }

        .stat-card:hover {
            transform: translateY(-5px) scale(1.02);
            box-shadow: 0 12px 30px rgba(0,0,0,0.15);
        }

        .icon-box {
            width: 50px;
            height: 50px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 20px;
        }

        .badge {
            font-size: 0.75rem;
            padding: 6px 10px;
        }

        /* ================= STREAM CARD ================= */
        .stream-card {
            border-radius: 16px;
            overflow: hidden;
            background: white;
            box-shadow: 0 6px 18px rgba(0,0,0,0.08);
            transition: all .25s ease;
        }

        .stream-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 15px 35px rgba(0,0,0,0.15);
        }

        /* ================= STREAM HEADER ================= */
        .stream-header {
            padding: 16px 20px;
            background: linear-gradient(135deg, #4f46e5, #6366f1);
            color: white;
            cursor: pointer;
            transition: all .3s ease;
        }

        .stream-header:hover {
            background: linear-gradient(135deg, #4338ca, #4f46e5);
        }

        .stream-title {
            margin: 0;
            font-size: 18px;
            font-weight: 600;
        }

        /* ================= BADGE ================= */
        .stream-badge {
            background: rgba(255,255,255,0.2);
            padding: 4px 10px;
            border-radius: 50px;
            font-size: 12px;
        }

        /* ================= COURSE AREA ================= */
        .course-container {
            background: #f8fafc;
            padding: 10px 15px;
        }

        /* ================= COURSE ITEM ================= */
        .course-item {
            padding: 6px 0;
            font-size: 15px;
        }

        /* ================= COURSE CODE ================= */
        .course-code {
            background: #e0f2fe;
            color: #0369a1;
            padding: 4px 10px;
            border-radius: 20px;
            font-size: 12px;
        }

        /* ================= TABLE ================= */
        .course-table tr {
            transition: all .2s ease;
        }

        .course-table tr:hover {
            background: #eef2ff;
            transform: scale(1.01);
        }

        /* ================= ACTION BUTTONS ================= */
        .action-btn {
            border-radius: 50%;
            width: 32px;
            height: 32px;
            padding: 0;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            transition: all .2s ease;
        }

        .action-btn.edit { background: #e0f2fe; }
        .action-btn.toggle { background: #fef3c7; }
        .action-btn.delete { background: #fee2e2; }

        .action-btn:hover {
            transform: scale(1.1);
        }

        /* ================= ANIMATION ================= */
        .collapse {
            transition: all .3s ease;
        }

        .btn {
            transition: all .2s ease;
        }

        .btn:hover {
            transform: translateY(-2px);
        }
    </style>

</asp:Content>