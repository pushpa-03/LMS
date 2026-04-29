<%@ Page Title="Subject Details" Language="C#" MasterPageFile="~/Teacher/TeacherMaster.master" AutoEventWireup="true" CodeBehind="SubjectDetails_T_Side.aspx.cs" Inherits="LMS_Project.Teacher.SubjectDetails_T_Side" %>

<asp:Content ID="bodyContent" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

    <asp:HiddenField ID="hfSubjectId" runat="server" />
    <asp:HiddenField ID="hfChapterId" runat="server" />
<asp:Label ID="lblMsg" runat="server" CssClass="alert d-block mt-3" Visible="false"></asp:Label>

    <div class="d-flex align-items-center mb-4">
        <a href="Subjects_T_Side.aspx" class="btn btn-outline-secondary me-3">
            <i class="fa-solid fa-arrow-left"></i>
        </a>
        <h3 class="mb-0">Course Details</h3>
    </div>

    <div class="card shadow-sm border-0">
        <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center">
            <h5 class="mb-0 text-primary">General Information</h5>
            <div>
                <button type="button" class="btn btn-primary btn-sm me-2" data-bs-toggle="modal" data-bs-target="#UploadModal">
                    <i class="fa-solid fa-upload"></i>Upload Content
                </button>
                <button type="button" class="btn btn-primary btn-sm" data-bs-toggle="modal" data-bs-target="#ChapterModal">
                    <i class="fa-solid fa-plus"></i>Add Chapters
                </button>
            </div>
        </div>
        <div class="card-body">
            <div class="row g-4">
                <div class="col-md-3">
                    <label class="small text-muted fw-bold">Subject Name</label>
                    <asp:Literal ID="litSubjectName" runat="server" />
                </div>
                <div class="col-md-3">
                    <label class="small text-muted fw-bold">Subject Code</label>
                    <asp:Literal ID="litSubjectCode" runat="server" />
                </div>
                <div class="col-md-3">
                    <label class="small text-muted fw-bold">Duration</label>
                    <asp:Literal ID="litDuration" runat="server" />
                </div>
                <div class="col-md-3">
                    <label class="small text-muted fw-bold">Status</label>
                    <asp:Literal ID="litStatus" runat="server" />
                </div>

                <div class="col-md-3">
                    <label class="small text-muted fw-bold">Society</label>
                    <asp:Literal ID="litSociety" runat="server" />
                </div>

                <div class="col-md-3">
                    <label class="small text-muted fw-bold">Institute</label>
                    <asp:Literal ID="litInstitute" runat="server" />
                </div>

                <div class="col-md-3">
                    <label class="small text-muted fw-bold">Stream</label>
                    <asp:Literal ID="litStream" runat="server" />
                </div>

                <div class="col-md-3">
                    <label class="small text-muted fw-bold">Course</label>
                    <asp:Literal ID="litCourse" runat="server" />
                </div>

                <div class="col-md-3">
                    <label class="small text-muted fw-bold">Level</label>
                    <asp:Literal ID="litLevel" runat="server" />
                </div>

                <div class="col-md-3">
                    <label class="small text-muted fw-bold">Semester</label>
                    <asp:Literal ID="litSemester" runat="server" />
                </div>

                <div class="col-12">
                    <label class="small text-muted fw-bold">Description</label>
                    <asp:Literal ID="litDescription" runat="server" />
                </div>
            </div>
        </div>
    </div>

    <br />
    <%--<h4 class="mb-3">Course Content</h4>

    <div class="accordion shadow-sm" id="accordionChapters">
        <asp:Repeater ID="rptChapters" runat="server" OnItemCommand="rptChapters_ItemCommand" OnItemDataBound="rptChapters_ItemDataBound">
            <ItemTemplate>
                <div class="accordion-item border-0 mb-2 shadow-sm">
                    <h2 class="accordion-header d-flex align-items-center bg-danger text-white rounded">
                        <button class="accordion-button collapsed bg-danger text-white border-0 shadow-none" type="button"
                            data-bs-toggle="collapse" data-bs-target="#collapse<%# Eval("ChapterId") %>">
                            <i class="fa-solid fa-book-open me-2"></i>
                            Chapter <%# Container.ItemIndex + 1 %>: <%# Eval("ChapterName") %>
                        </button>
                        <div class="pe-3 d-flex gap-1">
                            <asp:LinkButton ID="btnEdit" runat="server" CssClass="text-white btn btn-sm" CommandName="EditChapter" CommandArgument='<%# Eval("ChapterId") %>'>
                                <i class="fa-regular fa-pen-to-square"></i>
                            </asp:LinkButton>
                            <asp:LinkButton ID="btnDelete" runat="server" CssClass="text-white btn btn-sm" CommandName="DeleteChapter" CommandArgument='<%# Eval("ChapterId") %>' OnClientClick="return confirm('Delete chapter?');">
                                <i class="fa-solid fa-trash-can"></i>
                            </asp:LinkButton>
                        </div>
                    </h2>

                    <div id="collapse<%# Eval("ChapterId") %>" class="accordion-collapse collapse" data-bs-parent="#accordionChapters">
                        <div class="accordion-body bg-light">
                            <ul class="nav nav-tabs border-bottom-0" id="tab<%# Eval("ChapterId") %>">
                                <li class="nav-item"><a class="nav-link active fw-bold text-dark" data-bs-toggle="tab" href="#pre<%# Eval("ChapterId") %>">Pre Session</a></li>
                                <li class="nav-item"><a class="nav-link fw-bold text-dark" data-bs-toggle="tab" href="#in<%# Eval("ChapterId") %>">In Session</a></li>
                                <li class="nav-item"><a class="nav-link fw-bold text-dark" data-bs-toggle="tab" href="#post<%# Eval("ChapterId") %>">Post Session</a></li>
                            </ul>

                            <div class="tab-content border bg-white p-3 rounded-bottom shadow-sm">
                                <div class="tab-pane fade show active" id="pre<%# Eval("ChapterId") %>">
                                    <h6 class="text-primary border-bottom pb-2"><i class="fa-solid fa-video me-2"></i>Video Lectures</h6>
                                    <asp:HiddenField ID="hfRowChapterId" runat="server" Value='<%# Eval("ChapterId") %>' />
                                    <asp:Repeater ID="rptVideos" runat="server">
                                        <ItemTemplate>
                                            <div class="d-flex justify-content-between align-items-center p-2 border-bottom hover-bg">
                                                <span><i class="fa-regular fa-circle-play me-2 text-danger"></i><%# Eval("Title") %></span>
                                                <a href='VideoPlayer.aspx?VideoId=<%# Eval("VideoId") %>' class="btn btn-outline-danger btn-sm">Watch Now</a>
                                            </div>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                </div>

                                <div class="tab-pane fade" id="in<%# Eval("ChapterId") %>">
                                    <h6 class="text-success border-bottom pb-2"><i class="fa-solid fa-file-pdf me-2"></i>Learning Materials</h6>
                                    <asp:Repeater ID="rptMaterials" runat="server">
                                        <ItemTemplate>
                                            <div class="d-flex justify-content-between align-items-center p-2 border-bottom">
                                                <span><i class="fa-solid fa-file-lines me-2"></i><%# Eval("Title") %> (<%# Eval("FileType") %>)</span>
                                                <a href='MaterialPlayer.aspx?MaterialId=<%# Eval("MaterialId") %>' class="btn btn-outline-success btn-sm">View</a>
                                            </div>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                </div>


                                <!-- ✅ ASSIGNMENTS -->
                                <div class="tab-pane fade"
                                    id="post<%# Eval("ChapterId") %>">

                                    <h6 class="text-warning border-bottom pb-2"><i class="fa-solid fa-tasks me-2"></i>Assignments</h6>
                                    <p class="small text-muted">Assessment for this chapter will appear here.</p>
                               
                                    <asp:Repeater ID="rptAssignments" runat="server">
                                        <ItemTemplate>
                                            <div class="assignment-card">
                                                <b><%# Eval("Title") %></b><br />
                                                <small><%# Eval("Description") %></small><br />
                                                <small>Due: <%# Eval("DueDate") %></small><br />
                                                <small>Marks: <%# Eval("MaxMarks") %></small>
                                            </div>
                                        </ItemTemplate>
                                    </asp:Repeater>

                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>--%>

    <div class="row">
        <div class="col-md-3 mb-4">
            <div class="card shadow-sm border-0 sticky-top" style="top: 20px;">
                <div class="card-header bg-dark text-white py-3">
                    <h6 class="mb-0"><i class="fa-solid fa-list-ol me-2"></i>Quick Access</h6>
                </div>
                <div class="list-group list-group-flush" id="quickAccessList" style="max-height: 400px; overflow-y: auto;">
                    </div>
            </div>
        </div>

        <div class="col-md-9">
            <h4 class="mb-3">Course Content</h4>
            <div class="accordion shadow-sm mb-5" id="accordionChapters">
                <asp:Repeater ID="rptChapters" runat="server" OnItemCommand="rptChapters_ItemCommand" OnItemDataBound="rptChapters_ItemDataBound">
                    <ItemTemplate>
                        <div class="accordion-item border-0 mb-2 shadow-sm chapter-item" data-title='<%# Eval("ChapterName") %>'>
                            <h2 class="accordion-header d-flex align-items-center bg-danger text-white rounded">
                                <button class="accordion-button collapsed bg-danger text-white border-0 shadow-none" type="button"
                                    data-bs-toggle="collapse" data-bs-target="#collapse<%# Eval("ChapterId") %>">
                                    <i class="fa-solid fa-book-open me-2"></i>
                                    Chapter <%# Container.ItemIndex + 1 %>: <%# Eval("ChapterName") %>
                                </button>
                                <div class="pe-3 d-flex gap-1">
                                    <asp:LinkButton ID="btnEdit" runat="server" CssClass="text-white btn btn-sm" CommandName="EditChapter" CommandArgument='<%# Eval("ChapterId") %>'>
                                        <i class="fa-regular fa-pen-to-square"></i>
                                    </asp:LinkButton>
                                    <asp:LinkButton ID="btnDelete" runat="server" CssClass="text-white btn btn-sm" CommandName="DeleteChapter" CommandArgument='<%# Eval("ChapterId") %>' OnClientClick="return confirm('Delete chapter?');">
                                        <i class="fa-solid fa-trash-can"></i>
                                    </asp:LinkButton>
                                </div>
                            </h2>

                            <div id="collapse<%# Eval("ChapterId") %>" class="accordion-collapse collapse" data-bs-parent="#accordionChapters">
                                <div class="accordion-body bg-light">
                                    <ul class="nav nav-tabs border-bottom-0">
                                        <li class="nav-item"><a class="nav-link active fw-bold text-dark" data-bs-toggle="tab" href="#pre<%# Eval("ChapterId") %>">Pre Session</a></li>
                                        <li class="nav-item"><a class="nav-link fw-bold text-dark" data-bs-toggle="tab" href="#in<%# Eval("ChapterId") %>">In Session</a></li>
                                        </ul>

                                    <div class="tab-content border bg-white p-3 rounded-bottom shadow-sm">
                                        <div class="tab-pane fade show active" id="pre<%# Eval("ChapterId") %>">
                                            <h6 class="text-primary border-bottom pb-2"><i class="fa-solid fa-video me-2"></i>Video Lectures</h6>
                                            <asp:HiddenField ID="hfRowChapterId" runat="server" Value='<%# Eval("ChapterId") %>' />
                                            <asp:Repeater ID="rptVideos" runat="server">
                                                <ItemTemplate>
                                                    <div class="d-flex justify-content-between align-items-center p-2 border-bottom hover-bg">
                                                        <span><i class="fa-regular fa-circle-play me-2 text-danger"></i><%# Eval("Title") %></span>
                                                        <a href='TeacherVideoPlayer.aspx?VideoId=<%# Eval("VideoId") %>' class="btn btn-outline-danger btn-sm">Watch Now</a>
                                                    </div>
                                                </ItemTemplate>
                                            </asp:Repeater>
                                        </div>

                                        <div class="tab-pane fade" id="in<%# Eval("ChapterId") %>">
                                            <h6 class="text-success border-bottom pb-2"><i class="fa-solid fa-file-pdf me-2"></i>Learning Materials</h6>
                                            <asp:Repeater ID="rptMaterials" runat="server">
                                                <ItemTemplate>
                                                    <div class="d-flex justify-content-between align-items-center p-2 border-bottom">
                                                        <span><i class="fa-solid fa-file-lines me-2"></i><%# Eval("Title") %> (<%# Eval("FileType") %>)</span>
                                                        <a href='MaterialPlayer.aspx?MaterialId=<%# Eval("MaterialId") %>' class="btn btn-outline-success btn-sm">View</a>
                                                    </div>
                                                </ItemTemplate>
                                            </asp:Repeater>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>

            <div class="card shadow-sm border-0">
                <div class="card-header bg-warning text-dark py-3 d-flex justify-content-between align-items-center">
                    <h5 class="mb-0 fw-bold"><i class="fa-solid fa-tasks me-2"></i>Subject Assignments</h5>
                    
                </div>
                <div class="card-body bg-white">
                    <div class="row g-3">
                        <asp:Repeater ID="rptAssignments" runat="server">
                            <ItemTemplate>
                                <div class="col-md-6">
                                    <div class="p-3 border rounded shadow-sm hover-bg">
                                        <div class="d-flex justify-content-between align-items-start">
                                            <h6 class="text-primary mb-1"><%# Eval("Title") %></h6>
                                            <span class="badge bg-secondary"><%# Eval("MaxMarks") %> Marks</span>
                                        </div>
                                        <p class="small text-muted mb-2 text-truncate-2"><%# Eval("Description") %></p>
                                        <div class="d-flex justify-content-between align-items-center mt-2 pt-2 border-top">
                                            <small class="text-danger fw-bold"><i class="fa-regular fa-calendar-days me-1"></i>Due: <%# Eval("DueDate") %></small>
                                            <%--<a href="#" class="btn btn-link btn-sm p-0">View Submissions</a>--%>
                                        </div>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="modal fade" id="UploadModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header bg-primary text-white">
                    <h5 class="modal-title">Upload Content</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="fw-bold">Select Chapter</label>
                            <asp:DropDownList ID="ddlChapters" runat="server" CssClass="form-select"></asp:DropDownList>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="fw-bold">Content Type</label>
                            <asp:DropDownList ID="ddlContentType" runat="server" CssClass="form-select" onchange="toggleVideoFields()">
                                <asp:ListItem Text="Video" Value="Video" />
                                <asp:ListItem Text="Material (PDF/Doc)" Value="Material" />
                            </asp:DropDownList>
                        </div>
                    </div>

                    <div class="mb-3">
                        <label class="fw-bold">Title</label>
                        <asp:TextBox ID="txtContentTitle" runat="server" CssClass="form-control" placeholder="e.g. Introduction to OOPS" />
                    </div>

                    <div id="videoFields">
                        <div class="mb-3">
                            <label class="fw-bold">Instructor / Profession Name</label>
                            <asp:TextBox ID="txtInstructor" runat="server" CssClass="form-control" placeholder="e.g. Dr. Smith" />
                        </div>
                        <div class="mb-3">
                            <label class="fw-bold">Description (Bibliography)</label>
                            <asp:TextBox ID="txtVideoDesc" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3" />
                        </div>

                        <div class="mt-3 p-3 border rounded bg-light">
                            <label class="fw-bold mb-2 text-secondary">Video Topics / Timestamps (Breakdown)</label>
                            <div id="topicContainer">
                                <div class="row g-2 mb-2 topic-row">
                                    <div class="col-4">
                                        <input type="text" name="topicTime" class="form-control form-control-sm" placeholder="e.g. 02:30">
                                    </div>
                                    <div class="col-8">
                                        <input type="text" name="topicTitle" class="form-control form-control-sm" placeholder="Topic Name">
                                    </div>
                                </div>
                            </div>
                            <button type="button" class="btn btn-outline-secondary btn-sm mt-1" onclick="addTopicRow()">+ Add More Topics</button>
                        </div>
                    </div>

                    <div class="mb-3 mt-3">
                        <label class="fw-bold">Select File</label>
                        <asp:FileUpload ID="fuContent" runat="server" CssClass="form-control" />
                    </div>
                </div>
                <div class="modal-footer">
                    <asp:Button ID="btnUploadSave" runat="server" Text="Save Content" CssClass="btn btn-primary" OnClick="btnUploadSave_Click" />
                </div>
            </div>
        </div>
    </div>


    <div class="modal fade" id="ChapterModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header bg-primary text-white">
                    <h5 class="modal-title">Chapter Details</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label>Chapter Name</label>
                        <asp:TextBox ID="txtChapterName" runat="server" CssClass="form-control" />
                    </div>
                    <div class="mb-3">
                        <label>Order Number</label>
                        <asp:TextBox ID="txtOrderNo" runat="server" CssClass="form-control" TextMode="Number" />
                    </div>
                </div>
                <div class="modal-footer">
                    <asp:Button ID="btnSaveChapter" runat="server" Text="Save" CssClass="btn btn-primary" OnClick="btnSaveChapter_Click" />
                </div>
            </div>
        </div>
    </div>

    <style>
        .hover-bg:hover {
            background-color: #f8f9fa;
            cursor: pointer;
        }

        .nav-tabs .nav-link.active {
            border-color: transparent transparent #dc3545;
            border-bottom-width: 3px;
            color: #dc3545 !important;
        }
        .hover-bg:hover { background-color: #f8f9fa; cursor: pointer; }
        .nav-tabs .nav-link.active { border-color: transparent transparent #dc3545; border-bottom-width: 3px; color: #dc3545 !important; }
        .text-truncate-2 { display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; }
        .list-group-item-action:hover { background-color: #f8f9fa; color: #dc3545; }
    </style>


    <script>
        function addTopicRow() {
            const container = document.getElementById('topicContainer');
            const row = document.createElement('div');
            row.className = 'row g-2 mb-2 topic-row';
            row.innerHTML = `
            <div class="col-4"><input type="text" name="topicTime" class="form-control form-control-sm" placeholder="00:00"></div>
            <div class="col-8"><input type="text" name="topicTitle" class="form-control form-control-sm" placeholder="Topic Name"></div>`;
            container.appendChild(row);
        }

        // SCRIPT FOR QUICK ACCESS (Automated)
        document.addEventListener("DOMContentLoaded", function () {
            const chapterItems = document.querySelectorAll('.chapter-item');
            const quickAccessList = document.getElementById('quickAccessList');

            chapterItems.forEach((item, index) => {
                const title = item.getAttribute('data-title');
                const targetId = item.querySelector('.accordion-collapse').id;

                const link = document.createElement('a');
                link.className = 'list-group-item list-group-item-action small py-2';
                link.href = "#" + targetId;
                link.innerHTML = `<strong>${index + 1}.</strong> ${title}`;

                link.onclick = function (e) {
                    e.preventDefault();
                    const collapseEl = document.getElementById(targetId);
                    const bsCollapse = new bootstrap.Collapse(collapseEl, { toggle: false });
                    bsCollapse.show();
                    collapseEl.scrollIntoView({ behavior: 'smooth', block: 'center' });
                };

                quickAccessList.appendChild(link);
            });
        });

        

        function toggleVideoFields() {
            var ddl = document.getElementById('<%= ddlContentType.ClientID %>');
            var videoDiv = document.getElementById('videoFields');
            if (ddl) {
                videoDiv.style.display = (ddl.value === 'Video') ? 'block' : 'none';
            }
        }
    </script>

    <script>
        function showChapterModal() { new bootstrap.Modal(document.getElementById('ChapterModal')).show(); }
    </script>


    <script>
        document.addEventListener("DOMContentLoaded", function () {
            // 1. Remove 'active' from all sidebar links
            var links = document.querySelectorAll('.sidebar-link');
            links.forEach(function (link) {
                link.classList.remove('active');
            });

            // 2. Find the link that goes to Courses.aspx and make it active
            var courseLink = document.querySelector('a[href*="Courses.aspx"]');
            if (courseLink) {
                courseLink.classList.add('active');
            }
        });
    </script>
</asp:Content>