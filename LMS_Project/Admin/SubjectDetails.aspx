<%--<%@ Page Title="Subject Details" Language="C#" MasterPageFile="~/Admin/AdminMaster.master" AutoEventWireup="true" CodeBehind="SubjectDetails.aspx.cs" Inherits="LearningManagementSystem.Admin.SubjectDetails" %>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">
    <asp:HiddenField ID="hfSubjectId" runat="server" />
<asp:HiddenField ID="hfChapterId" runat="server" />
<asp:Label ID="lblMsg" runat="server" CssClass="alert d-block mt-3" Visible="false"></asp:Label>

    <div class="d-flex align-items-center mb-4">
        <a href="Subjects.aspx" class="btn btn-outline-secondary me-3">
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
</asp:Content>--%>

<%-- ------------------------------------------------------------------------------------------------------------------------------ --%>

<%@ Page Title="Subject Details" Language="C#" MasterPageFile="~/Admin/AdminMaster.master"
    AutoEventWireup="true" CodeBehind="SubjectDetails.aspx.cs"
    Inherits="LearningManagementSystem.Admin.SubjectDetails" %>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">
<link href="https://fonts.googleapis.com/css2?family=Syne:wght@400;600;700;800&family=DM+Sans:ital,wght@0,300;0,400;0,500;1,300&display=swap" rel="stylesheet">

<asp:HiddenField ID="hfSubjectId" runat="server" />
<asp:HiddenField ID="hfChapterId" runat="server" />

<style>
:root {
    --ink:#0d0f1a; --ink-soft:#4a4f6a; --surface:#f5f6fa; --card-bg:#fff;
    --border:#e4e7f0; --accent:#4f46e5; --accent-2:#7c3aed;
    --success:#059669; --danger:#dc2626; --warn:#d97706;
    --radius:16px; --shadow:0 4px 24px rgba(13,15,26,.07);
    --shadow-lg:0 12px 48px rgba(13,15,26,.13);
}
* { box-sizing:border-box; }
body { font-family:'DM Sans',sans-serif; background:var(--surface); color:var(--ink); }

/* ── TOP NAV ── */
.top-nav { display:flex; align-items:center; gap:14px; margin-bottom:24px; flex-wrap:wrap; }
.btn-back { display:inline-flex; align-items:center; gap:8px; background:var(--card-bg); border:1px solid var(--border); border-radius:10px; padding:8px 16px; font-size:.85rem; font-weight:600; color:var(--ink-soft); text-decoration:none; transition:.2s; }
.btn-back:hover { border-color:var(--accent); color:var(--accent); }
.top-nav h2 { font-family:'Syne',sans-serif; font-weight:800; font-size:1.4rem; flex:1; }

/* ── INFO CARD ── */
.info-card { background:var(--card-bg); border:1px solid var(--border); border-radius:var(--radius); box-shadow:var(--shadow); overflow:hidden; margin-bottom:24px; }
.info-card-header { background:linear-gradient(135deg,var(--accent),var(--accent-2)); padding:18px 24px; display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:12px; }
.info-card-header h4 { font-family:'Syne',sans-serif; font-weight:700; color:#fff; margin:0; }
.info-card-header .actions { display:flex; gap:10px; }
.btn-hdr { display:inline-flex; align-items:center; gap:6px; background:rgba(255,255,255,.18); backdrop-filter:blur(4px); color:#fff; border:1px solid rgba(255,255,255,.35); border-radius:9px; padding:7px 16px; font-size:.82rem; font-weight:600; cursor:pointer; transition:.2s; text-decoration:none; }
.btn-hdr:hover { background:rgba(255,255,255,.28); color:#fff; }
.info-card-body { padding:24px; display:grid; grid-template-columns:repeat(auto-fill,minmax(200px,1fr)); gap:20px; }
.info-field label { font-size:.72rem; font-weight:700; text-transform:uppercase; letter-spacing:.06em; color:var(--ink-soft); display:block; margin-bottom:4px; }
.info-field .val { font-size:.92rem; font-weight:500; color:var(--ink); }

/* ── LAYOUT ── */
.layout { display:grid; grid-template-columns:260px 1fr; gap:20px; }
@media(max-width:900px){ .layout{grid-template-columns:1fr;} }

/* ── SIDEBAR ── */
.sidebar-card { background:var(--card-bg); border:1px solid var(--border); border-radius:var(--radius); box-shadow:var(--shadow); position:sticky; top:16px; max-height:80vh; display:flex; flex-direction:column; overflow:hidden; }
.sidebar-card .sh { background:var(--ink); color:#fff; padding:14px 16px; font-family:'Syne',sans-serif; font-weight:700; font-size:.9rem; }
.sidebar-list { overflow-y:auto; flex:1; }
.sidebar-item { display:flex; align-items:center; gap:10px; padding:11px 16px; border-bottom:1px solid var(--border); cursor:pointer; transition:.2s; font-size:.83rem; }
.sidebar-item:hover { background:var(--surface); color:var(--accent); }
.sidebar-item .num { width:22px; height:22px; border-radius:6px; background:var(--accent); color:#fff; display:flex; align-items:center; justify-content:center; font-size:.7rem; font-weight:700; flex-shrink:0; }

/* ── CHAPTER ACCORDION ── */
.chapter-wrap { margin-bottom:10px; border-radius:var(--radius); overflow:hidden; border:1px solid var(--border); box-shadow:var(--shadow); }
.chapter-hdr { background:linear-gradient(90deg,#1e1b4b,#312e81); color:#fff; padding:14px 18px; display:flex; align-items:center; justify-content:space-between; cursor:pointer; user-select:none; }
.chapter-hdr-left { display:flex; align-items:center; gap:10px; font-family:'Syne',sans-serif; font-weight:700; font-size:.95rem; }
.chapter-hdr-left .cnum { background:rgba(255,255,255,.2); border-radius:6px; padding:2px 8px; font-size:.78rem; }
.chapter-actions { display:flex; gap:8px; }
.chapter-actions a, .chapter-actions button { background:rgba(255,255,255,.15); border:none; color:#fff; border-radius:7px; padding:5px 10px; font-size:.78rem; cursor:pointer; transition:.2s; text-decoration:none; display:inline-flex; align-items:center; gap:4px; }
.chapter-actions a:hover, .chapter-actions button:hover { background:rgba(255,255,255,.3); color:#fff; }
.chapter-body { background:var(--card-bg); }

/* Tabs inside chapter */
.ch-tabs { display:flex; border-bottom:1px solid var(--border); }
.ch-tab { padding:10px 20px; font-size:.82rem; font-weight:600; cursor:pointer; color:var(--ink-soft); border-bottom:3px solid transparent; transition:.2s; }
.ch-tab.active { color:var(--accent); border-bottom-color:var(--accent); }
.ch-tab-pane { display:none; padding:16px; }
.ch-tab-pane.active { display:block; }

/* Video rows */
.video-row { display:flex; align-items:center; justify-content:space-between; padding:10px 12px; border-radius:10px; border:1px solid var(--border); margin-bottom:8px; background:var(--surface); transition:.2s; }
.video-row:hover { border-color:var(--accent); background:#eef2ff; }
.video-row-left { display:flex; align-items:center; gap:10px; }
.vid-thumb { width:48px; height:34px; background:#312e81; border-radius:6px; display:flex; align-items:center; justify-content:center; color:#fff; font-size:.9rem; flex-shrink:0; }
.video-title { font-size:.85rem; font-weight:600; color:var(--ink); }
.video-meta  { font-size:.73rem; color:var(--ink-soft); }
.video-row-right { display:flex; gap:6px; }
.btn-sm-icon { width:30px; height:30px; border:none; border-radius:7px; cursor:pointer; display:flex; align-items:center; justify-content:center; font-size:.75rem; transition:.2s; text-decoration:none; }
.btn-sm-icon.watch { background:#eef2ff; color:var(--accent); }
.btn-sm-icon.del   { background:#fee2e2; color:var(--danger); }
.btn-sm-icon:hover { filter:brightness(.9); }

/* Material rows */
.mat-row { display:flex; align-items:center; justify-content:space-between; padding:10px 12px; border-radius:10px; border:1px solid var(--border); margin-bottom:8px; background:var(--surface); transition:.2s; }
.mat-row:hover { border-color:var(--success); background:#f0fdf4; }
.mat-icon { width:36px; height:36px; border-radius:8px; display:flex; align-items:center; justify-content:center; font-size:.9rem; flex-shrink:0; }
.mat-icon.pdf  { background:#fee2e2; color:#dc2626; }
.mat-icon.doc  { background:#dbeafe; color:#1d4ed8; }
.mat-icon.ppt  { background:#ffedd5; color:#ea580c; }
.mat-icon.img  { background:#fef9c3; color:#ca8a04; }
.mat-icon.file { background:#f3f4f6; color:#6b7280; }

/* ── ASSIGNMENT SECTION ── */
.section-hdr { display:flex; justify-content:space-between; align-items:center; margin-bottom:14px; }
.section-hdr h4 { font-family:'Syne',sans-serif; font-weight:800; font-size:1.1rem; }
.asgn-card { background:var(--card-bg); border:1px solid var(--border); border-radius:12px; padding:16px; margin-bottom:10px; transition:.2s; }
.asgn-card:hover { border-color:var(--warn); box-shadow:var(--shadow); }
.asgn-title { font-weight:700; font-size:.9rem; margin-bottom:4px; }
.asgn-desc  { font-size:.8rem; color:var(--ink-soft); display:-webkit-box; -webkit-line-clamp:2; -webkit-box-orient:vertical; overflow:hidden; }
.asgn-meta  { display:flex; gap:12px; margin-top:10px; font-size:.75rem; }
.badge-marks { background:#eef2ff; color:var(--accent); border-radius:6px; padding:2px 8px; font-weight:700; }
.badge-due   { background:#fff7ed; color:var(--warn);   border-radius:6px; padding:2px 8px; font-weight:700; }

/* ── MODAL STYLES ── */
.modal-content { border:none; border-radius:var(--radius); box-shadow:var(--shadow-lg); }
.modal-header-custom { background:linear-gradient(135deg,var(--accent),var(--accent-2)); padding:18px 22px; border-radius:var(--radius) var(--radius) 0 0; }
.modal-header-custom h5 { color:#fff; font-family:'Syne',sans-serif; font-weight:700; margin:0; }
.modal-header-custom .btn-close { filter:invert(1); }
.form-label-custom { font-size:.78rem; font-weight:700; text-transform:uppercase; letter-spacing:.05em; color:var(--ink-soft); }
.form-control-custom { border:1px solid var(--border); border-radius:10px; padding:9px 14px; font-size:.87rem; width:100%; transition:.2s; color:var(--ink); background:var(--surface); }
.form-control-custom:focus { border-color:var(--accent); outline:none; box-shadow:0 0 0 3px rgba(79,70,229,.12); }
.form-select-custom { border:1px solid var(--border); border-radius:10px; padding:9px 14px; font-size:.87rem; width:100%; color:var(--ink); background:var(--surface); cursor:pointer; }
.form-select-custom:focus { border-color:var(--accent); outline:none; box-shadow:0 0 0 3px rgba(79,70,229,.12); }
.btn-primary-custom { background:linear-gradient(135deg,var(--accent),var(--accent-2)); color:#fff; border:none; border-radius:10px; padding:10px 24px; font-weight:700; cursor:pointer; transition:.2s; font-size:.88rem; }
.btn-primary-custom:hover { opacity:.9; }
.btn-secondary-custom { background:var(--surface); color:var(--ink-soft); border:1px solid var(--border); border-radius:10px; padding:10px 20px; font-weight:600; cursor:pointer; font-size:.88rem; }

/* Teacher search */
.teacher-search-wrap { position:relative; }
.teacher-dropdown { position:absolute; top:100%; left:0; right:0; background:#fff; border:1px solid var(--border); border-radius:10px; box-shadow:var(--shadow-lg); z-index:200; max-height:200px; overflow-y:auto; display:none; }
.teacher-option { padding:10px 14px; cursor:pointer; font-size:.85rem; display:flex; align-items:center; gap:8px; transition:.15s; }
.teacher-option:hover { background:var(--surface); color:var(--accent); }
.teacher-avatar { width:30px; height:30px; border-radius:50%; background:var(--accent); color:#fff; display:flex; align-items:center; justify-content:center; font-size:.75rem; font-weight:700; flex-shrink:0; }
.selected-teacher { display:flex; align-items:center; gap:8px; background:#eef2ff; border:1px solid #c7d2fe; border-radius:8px; padding:8px 12px; margin-top:8px; font-size:.82rem; }
.selected-teacher .remove { cursor:pointer; color:var(--danger); margin-left:auto; }

/* Topic row */
.topic-row { display:grid; grid-template-columns:120px 1fr 32px; gap:8px; margin-bottom:6px; align-items:center; }
.topic-row input { padding:7px 10px; border:1px solid var(--border); border-radius:8px; font-size:.82rem; color:var(--ink); background:var(--surface); width:100%; }
.topic-row .del-btn { width:28px; height:28px; border:none; background:#fee2e2; color:var(--danger); border-radius:7px; cursor:pointer; display:flex; align-items:center; justify-content:center; font-size:.8rem; }

/* Progress bar */
.upload-progress { display:none; margin-top:10px; }
.upload-bar { height:6px; background:var(--border); border-radius:4px; overflow:hidden; }
.upload-fill { height:100%; background:linear-gradient(90deg,var(--accent),var(--accent-2)); width:0; transition:width .4s; }

/* Toast */
#toast-wrap { position:fixed; bottom:24px; right:24px; z-index:9999; display:flex; flex-direction:column; gap:10px; }
.toast-msg { border-radius:12px; padding:12px 20px; font-size:.85rem; font-weight:500; box-shadow:var(--shadow-lg); animation:slideIn .3s ease; max-width:340px; color:#fff; }
.toast-msg.success { background:#059669; }
.toast-msg.danger  { background:#dc2626; }
.toast-msg.info    { background:#0284c7; }
@keyframes slideIn { from{opacity:0;transform:translateX(40px)} to{opacity:1;transform:translateX(0)} }

/* Empty state mini */
.mini-empty { text-align:center; padding:28px; color:var(--ink-soft); font-size:.85rem; }
.mini-empty i { font-size:1.8rem; display:block; margin-bottom:8px; opacity:.3; }

/* Alert */
.alert-auto { border-radius:10px; font-size:.85rem; padding:10px 16px; }
</style>

<!-- TOP NAV -->
<div class="top-nav">
    <a href="Subjects.aspx" class="btn-back"><i class="fa fa-arrow-left"></i> Back</a>
    <h2><i class="fa fa-book-open me-2" style="color:var(--accent)"></i>
        <asp:Literal ID="litSubjectName" runat="server" /></h2>
</div>

<asp:Label ID="lblMsg" runat="server" CssClass="alert alert-info alert-auto d-block mb-3" Visible="false"></asp:Label>
<asp:HiddenField ID="hfToastMsg" runat="server" />
<asp:HiddenField ID="hfToastType" runat="server" />

<!-- INFO CARD -->
<div class="info-card">
    <div class="info-card-header">
        <h4><i class="fa fa-info-circle me-2"></i>Subject Information</h4>
        <div class="actions">
            <button type="button" class="btn-hdr" onclick="openModal('UploadModal')">
                <i class="fa fa-upload"></i> Upload Content
            </button>
            <button type="button" class="btn-hdr" onclick="openModal('ChapterModal')">
                <i class="fa fa-plus"></i> Add Chapter
            </button>
        </div>
    </div>
    <div class="info-card-body">
        <div class="info-field"><label>Subject Code</label>
            <div class="val"><asp:Literal ID="litSubjectCode" runat="server" /></div></div>
        <div class="info-field"><label>Duration</label>
            <div class="val"><asp:Literal ID="litDuration" runat="server" /></div></div>
        <div class="info-field"><label>Status</label>
            <div class="val"><asp:Literal ID="litStatus" runat="server" /></div></div>
        <div class="info-field"><label>Society</label>
            <div class="val"><asp:Literal ID="litSociety" runat="server" /></div></div>
        <div class="info-field"><label>Institute</label>
            <div class="val"><asp:Literal ID="litInstitute" runat="server" /></div></div>
        <div class="info-field"><label>Stream</label>
            <div class="val"><asp:Literal ID="litStream" runat="server" /></div></div>
        <div class="info-field"><label>Course</label>
            <div class="val"><asp:Literal ID="litCourse" runat="server" /></div></div>
        <div class="info-field"><label>Level</label>
            <div class="val"><asp:Literal ID="litLevel" runat="server" /></div></div>
        <div class="info-field"><label>Semester</label>
            <div class="val"><asp:Literal ID="litSemester" runat="server" /></div></div>
        <div class="info-field" style="grid-column:1/-1"><label>Description</label>
            <div class="val"><asp:Literal ID="litDescription" runat="server" /></div></div>
    </div>
</div>

<!-- MAIN LAYOUT -->
<div class="layout">

    <!-- SIDEBAR -->
    <div>
        <div class="sidebar-card">
            <div class="sh"><i class="fa fa-list-ol me-2"></i>Quick Navigation</div>
            <div class="sidebar-list" id="sidebarList"></div>
        </div>
    </div>

    <!-- CONTENT -->
    <div>
        <!-- CHAPTERS ACCORDION -->
        <div class="section-hdr">
            <h4><i class="fa fa-book me-2" style="color:var(--accent)"></i>Course Content</h4>
            <span id="chapterCountBadge" style="background:#eef2ff;color:var(--accent);border-radius:8px;padding:4px 12px;font-size:.78rem;font-weight:700;"></span>
        </div>

        <div id="chaptersContainer">
            <asp:Repeater ID="rptChapters" runat="server"
                OnItemCommand="rptChapters_ItemCommand"
                OnItemDataBound="rptChapters_ItemDataBound">
                <ItemTemplate>
                    <div class="chapter-wrap chapter-item" data-title='<%# Server.HtmlEncode(Eval("ChapterName").ToString()) %>'>
                        <div class="chapter-hdr" onclick="toggleChapter(this)">
                            <div class="chapter-hdr-left">
                                <span class="cnum">Ch <%# Container.ItemIndex + 1 %></span>
                                <%# Server.HtmlEncode(Eval("ChapterName").ToString()) %>
                            </div>
                            <div class="chapter-actions" onclick="event.stopPropagation()">
                                <asp:LinkButton ID="btnEdit" runat="server" CommandName="EditChapter"
                                    CommandArgument='<%# Eval("ChapterId") %>'>
                                    <i class="fa fa-pencil"></i> Edit
                                </asp:LinkButton>
                                <asp:LinkButton ID="btnDelete" runat="server" CommandName="DeleteChapter"
                                    CommandArgument='<%# Eval("ChapterId") %>'
                                    OnClientClick="return confirm('Delete this chapter and all its content?');">
                                    <i class="fa fa-trash"></i> Delete
                                </asp:LinkButton>
                                <span style="background:rgba(255,255,255,.15);border-radius:6px;padding:4px 8px;font-size:.75rem;">
                                    <i class="fa fa-chevron-down"></i>
                                </span>
                            </div>
                        </div>

                        <div class="chapter-body" style="display:none">
                            <div class="ch-tabs">
                                <div class="ch-tab active" onclick="switchTab(this,'vid<%# Eval("ChapterId") %>')">
                                    <i class="fa fa-video me-1"></i> Video Lectures
                                </div>
                                <div class="ch-tab" onclick="switchTab(this,'mat<%# Eval("ChapterId") %>')">
                                    <i class="fa fa-file-alt me-1"></i> Materials
                                </div>
                            </div>

                            <!-- VIDEOS TAB -->
                            <asp:HiddenField ID="hfRowChapterId" runat="server" Value='<%# Eval("ChapterId") %>' />
                            <div class="ch-tab-pane active" id="vid<%# Eval("ChapterId") %>">
                                <asp:Repeater ID="rptVideos" runat="server" OnItemCommand="rptVideos_ItemCommand">
                                    <ItemTemplate>
                                        <div class="video-row">
                                            <div class="video-row-left">
                                                <div class="vid-thumb"><i class="fa fa-play"></i></div>
                                                <div>
                                                    <div class="video-title"><%# Server.HtmlEncode(Eval("Title").ToString()) %></div>
                                                    <div class="video-meta">
                                                        <i class="fa fa-user me-1"></i><%# Eval("InstructorName") %> &nbsp;·&nbsp;
                                                        <i class="fa fa-eye me-1"></i><%# Eval("ViewCount") %> views
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="video-row-right">
                                                <a href='VideoPlayer.aspx?VideoId=<%# Eval("VideoId") %>' class="btn-sm-icon watch" title="Watch"><i class="fa fa-play"></i></a>
                                                <asp:LinkButton ID="btnDelVid" runat="server" CssClass="btn-sm-icon del"
                                                    CommandName="DeleteVideo" CommandArgument='<%# Eval("VideoId") %>'
                                                    OnClientClick="return confirm('Delete this video?');" Title="Delete">
                                                    <i class="fa fa-trash"></i>
                                                </asp:LinkButton>
                                            </div>
                                        </div>
                                    </ItemTemplate>
                                    <FooterTemplate>
                                        <asp:PlaceHolder ID="phNoVid" runat="server"
                                            Visible='<%# Container.ItemIndex < 0 %>'>
                                            <div class="mini-empty"><i class="fa fa-video"></i>No videos yet. Upload one!</div>
                                        </asp:PlaceHolder>
                                    </FooterTemplate>
                                </asp:Repeater>
                            </div>

                            <!-- MATERIALS TAB -->
                            <div class="ch-tab-pane" id="mat<%# Eval("ChapterId") %>">
                                <asp:Repeater ID="rptMaterials" runat="server" OnItemCommand="rptMaterials_ItemCommand">
                                    <ItemTemplate>
                                        <div class="mat-row">
                                            <div style="display:flex;align-items:center;gap:10px">
                                                <div class='mat-icon <%# GetFileIcon(Eval("FileType").ToString()) %>'>
                                                    <i class='<%# GetFileIconClass(Eval("FileType").ToString()) %>'></i>
                                                </div>
                                                <div>
                                                    <div style="font-size:.85rem;font-weight:600"><%# Server.HtmlEncode(Eval("Title").ToString()) %></div>
                                                    <div style="font-size:.72rem;color:var(--ink-soft)"><%# Eval("FileType") %> &nbsp;·&nbsp; <%# Convert.ToDateTime(Eval("UploadedOn")).ToString("dd MMM yyyy") %></div>
                                                </div>
                                            </div>
                                            <div style="display:flex;gap:6px">
                                                <a href='MaterialPlayer.aspx?MaterialId=<%# Eval("MaterialId") %>' class="btn-sm-icon watch" title="View"><i class="fa fa-eye"></i></a>
                                                <asp:LinkButton ID="btnDelMat" runat="server" CssClass="btn-sm-icon del"
                                                    CommandName="DeleteMaterial" CommandArgument='<%# Eval("MaterialId") %>'
                                                    OnClientClick="return confirm('Delete this material?');" Title="Delete">
                                                    <i class="fa fa-trash"></i>
                                                </asp:LinkButton>
                                            </div>
                                        </div>
                                    </ItemTemplate>
                                    <FooterTemplate>
                                        <asp:PlaceHolder ID="phNoMat" runat="server"
                                            Visible='<%# Container.ItemIndex < 0 %>'>
                                            <div class="mini-empty"><i class="fa fa-file-alt"></i>No materials yet.</div>
                                        </asp:PlaceHolder>
                                    </FooterTemplate>
                                </asp:Repeater>
                            </div>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>

        <asp:PlaceHolder ID="phNoChapters" runat="server" Visible="false">
            <div class="mini-empty" style="padding:60px;background:var(--card-bg);border-radius:var(--radius);border:2px dashed var(--border);">
                <i class="fa fa-book" style="font-size:2.5rem"></i>
                <h5 style="font-family:'Syne',sans-serif;margin-top:8px">No chapters yet</h5>
                <p>Click "Add Chapter" to get started.</p>
            </div>
        </asp:PlaceHolder>

        <!-- ── ASSIGNMENTS ── -->
        <div class="section-hdr mt-4">
            <h4><i class="fa fa-tasks me-2" style="color:var(--warn)"></i>Assignments</h4>
        </div>
        <div id="assignmentsContainer">
            <asp:Repeater ID="rptAssignments" runat="server">
                <ItemTemplate>
                    <div class="asgn-card">
                        <div style="display:flex;justify-content:space-between;align-items:flex-start">
                            <div class="asgn-title"><%# Server.HtmlEncode(Eval("Title").ToString()) %></div>
                        </div>
                        <div class="asgn-desc"><%# Server.HtmlEncode(Eval("Description").ToString()) %></div>
                        <div class="asgn-meta">
                            <span class="badge-marks"><i class="fa fa-star me-1"></i><%# Eval("MaxMarks") %> Marks</span>
                            <span class="badge-due"><i class="fa fa-calendar me-1"></i>Due: <%# Eval("DueDate") != DBNull.Value ? Convert.ToDateTime(Eval("DueDate")).ToString("dd MMM yyyy") : "No deadline" %></span>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
    </div>
</div>

<!-- ══════════════ UPLOAD MODAL ══════════════ -->
<div class="modal fade" id="UploadModal" tabindex="-1">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header-custom d-flex justify-content-between align-items-center">
                <h5><i class="fa fa-upload me-2"></i>Upload Content</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body p-4">
                <div class="row g-3">
                    <div class="col-md-6">
                        <label class="form-label-custom">Chapter *</label>
                        <asp:DropDownList ID="ddlChapters" runat="server" CssClass="form-select-custom"></asp:DropDownList>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label-custom">Content Type *</label>
                        <asp:DropDownList ID="ddlContentType" runat="server" CssClass="form-select-custom" onchange="toggleContentFields()">
                            <asp:ListItem Text="📹 Video Lecture" Value="Video" />
                            <asp:ListItem Text="📄 Material (PDF/Doc/Image/etc.)" Value="Material" />
                        </asp:DropDownList>
                    </div>
                    <div class="col-12">
                        <label class="form-label-custom">Title *</label>
                        <asp:TextBox ID="txtContentTitle" runat="server" CssClass="form-control-custom" placeholder="Enter a descriptive title…" />
                    </div>
                </div>

                <!-- VIDEO FIELDS -->
                <div id="videoFields" class="mt-3">
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label-custom">Instructor *</label>
                            <div class="teacher-search-wrap">
                                <input type="text" id="txtTeacherSearch" class="form-control-custom" placeholder="Search teacher by name…" oninput="searchTeachers(this.value)" autocomplete="off" />
                                <div class="teacher-dropdown" id="teacherDropdown"></div>
                            </div>
                            <div id="selectedTeacherWrap" style="display:none">
                                <div class="selected-teacher">
                                    <div class="teacher-avatar" id="selTeacherInitial">?</div>
                                    <span id="selTeacherName"></span>
                                    <span class="remove" onclick="clearTeacher()"><i class="fa fa-times"></i></span>
                                </div>
                            </div>
                            <asp:HiddenField ID="hfInstructorId" runat="server" />
                        </div>
                        <div class="col-md-6">
                            <label class="form-label-custom">Description / Bio</label>
                            <asp:TextBox ID="txtVideoDesc" runat="server" CssClass="form-control-custom" TextMode="MultiLine" Rows="3" placeholder="Brief description or instructor bio…" />
                        </div>
                    </div>

                    <!-- TOPICS / TIMESTAMPS -->
                    <div class="mt-3 p-3" style="background:var(--surface);border-radius:12px;border:1px solid var(--border)">
                        <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:10px">
                            <label class="form-label-custom mb-0">Video Topics / Timestamps</label>
                            <button type="button" class="btn-secondary-custom" style="padding:5px 12px;font-size:.78rem" onclick="addTopicRow()">+ Add Topic</button>
                        </div>
                        <div class="topic-row" style="font-size:.72rem;font-weight:700;color:var(--ink-soft);text-transform:uppercase">
                            <span>Start Time</span><span>Topic Title</span><span></span>
                        </div>
                        <div id="topicContainer">
                            <div class="topic-row">
                                <input type="text" name="topicTime" placeholder="00:00" />
                                <input type="text" name="topicTitle" placeholder="Introduction…" />
                                <button type="button" class="del-btn" onclick="removeTopicRow(this)"><i class="fa fa-times"></i></button>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="mt-3">
                    <label class="form-label-custom">Select File *</label>
                    <asp:FileUpload ID="fuContent" runat="server" CssClass="form-control-custom" style="padding:6px" />
                    <div class="upload-progress" id="uploadProgress">
                        <div style="font-size:.78rem;color:var(--ink-soft);margin-bottom:4px">Uploading…</div>
                        <div class="upload-bar"><div class="upload-fill" id="uploadFill"></div></div>
                    </div>
                </div>
            </div>
            <div class="modal-footer" style="border-top:1px solid var(--border);padding:16px 24px;display:flex;gap:10px">
                <button type="button" class="btn-secondary-custom" data-bs-dismiss="modal">Cancel</button>
                <asp:Button ID="btnUploadSave" runat="server" Text="Upload & Save"
                    CssClass="btn-primary-custom" OnClick="btnUploadSave_Click"
                    OnClientClick="showUploadProgress()" />
            </div>
        </div>
    </div>
</div>

<!-- ══════════════ CHAPTER MODAL ══════════════ -->
<div class="modal fade" id="ChapterModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header-custom d-flex justify-content-between align-items-center">
                <h5><i class="fa fa-book me-2"></i><asp:Literal ID="litChapterModalTitle" runat="server" Text="Add Chapter" /></h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body p-4">
                <div class="mb-3">
                    <label class="form-label-custom">Chapter Name *</label>
                    <asp:TextBox ID="txtChapterName" runat="server" CssClass="form-control-custom" placeholder="e.g. Introduction to Data Structures" />
                </div>
                <div class="mb-3">
                    <label class="form-label-custom">Order Number</label>
                    <asp:TextBox ID="txtOrderNo" runat="server" CssClass="form-control-custom" TextMode="Number" placeholder="1" />
                </div>
            </div>
            <div class="modal-footer" style="border-top:1px solid var(--border);padding:16px 24px;display:flex;gap:10px">
                <button type="button" class="btn-secondary-custom" data-bs-dismiss="modal">Cancel</button>
                <asp:Button ID="btnSaveChapter" runat="server" CssClass="btn-primary-custom"
                    Text="Save Chapter" OnClick="btnSaveChapter_Click" />
            </div>
        </div>
    </div>
</div>

<!-- TOAST CONTAINER -->
<div id="toast-wrap"></div>

<script>
// ── Toast ──
function showToast(msg, type) {
    const wrap = document.getElementById('toast-wrap');
    const t = document.createElement('div');
    t.className = 'toast-msg ' + (type || 'success');
    t.innerHTML = `<i class="fa fa-${type==='danger'?'times-circle':type==='info'?'info-circle':'check-circle'} me-2"></i>${msg}`;
    wrap.appendChild(t);
    setTimeout(() => t.remove(), 5000);
}

window.addEventListener('DOMContentLoaded', () => {
    // Server toast
    const hfMsg  = document.getElementById('<%= hfToastMsg.ClientID %>');
    const hfType = document.getElementById('<%= hfToastType.ClientID %>');
    if (hfMsg && hfMsg.value) { showToast(hfMsg.value, hfType.value || 'success'); hfMsg.value = ''; }

    // Build sidebar from chapters
    buildSidebar();

    // Chapter count badge
    const items = document.querySelectorAll('.chapter-item');
    const badge = document.getElementById('chapterCountBadge');
    if (badge) badge.textContent = items.length + ' Chapter' + (items.length !== 1 ? 's' : '');
});

// ── Sidebar ──
function buildSidebar() {
    const items = document.querySelectorAll('.chapter-item');
    const list  = document.getElementById('sidebarList');
    if (!list) return;
    if (items.length === 0) {
        list.innerHTML = '<div class="mini-empty"><i class="fa fa-book"></i>No chapters yet</div>';
        return;
    }
    items.forEach((item, i) => {
        const title = item.getAttribute('data-title');
        const div   = document.createElement('div');
        div.className = 'sidebar-item';
        div.innerHTML = `<span class="num">${i + 1}</span>${title}`;
        div.onclick = () => {
            item.scrollIntoView({ behavior:'smooth', block:'center' });
            const body = item.querySelector('.chapter-body');
            if (body && body.style.display === 'none') {
                body.style.display = 'block';
                const icon = item.querySelector('.chapter-hdr .fa-chevron-down');
                if (icon) icon.style.transform = 'rotate(180deg)';
            }
        };
        list.appendChild(div);
    });
}

// ── Chapter accordion ──
function toggleChapter(hdr) {
    const body = hdr.nextElementSibling;
    const icon = hdr.querySelector('.fa-chevron-down');
    const open = body.style.display !== 'none';
    body.style.display = open ? 'none' : 'block';
    if (icon) icon.style.transform = open ? '' : 'rotate(180deg)';
}

// ── Tab switching ──
function switchTab(tabEl, paneId) {
    const wrapper = tabEl.closest('.chapter-body');
    wrapper.querySelectorAll('.ch-tab').forEach(t => t.classList.remove('active'));
    wrapper.querySelectorAll('.ch-tab-pane').forEach(p => p.classList.remove('active'));
    tabEl.classList.add('active');
    const pane = document.getElementById(paneId);
    if (pane) pane.classList.add('active');
}

// ── Modal helpers ──
function openModal(id) { new bootstrap.Modal(document.getElementById(id)).show(); }
function showChapterModal() { openModal('ChapterModal'); }

// ── Content type toggle ──
function toggleContentFields() {
    const sel = document.getElementById('<%= ddlContentType.ClientID %>').value;
    document.getElementById('videoFields').style.display = sel === 'Video' ? 'block' : 'none';
}

// ── Teacher search (AJAX) ──
let selectedTeacherId = null;
function searchTeachers(q) {
    const drop = document.getElementById('teacherDropdown');
    if (!q || q.length < 2) { drop.style.display = 'none'; return; }
    const subjectId = document.getElementById('<%= hfSubjectId.ClientID %>').value;
    fetch(`SubjectDetails.aspx/SearchTeachers?q=${encodeURIComponent(q)}&subjectId=${subjectId}`)
        .then(r => r.json())
        .then(data => {
            drop.innerHTML = '';
            if (!data || data.length === 0) {
                drop.innerHTML = '<div class="teacher-option" style="color:var(--ink-soft)">No assigned teachers found</div>';
            } else {
                data.forEach(t => {
                    const d = document.createElement('div');
                    d.className = 'teacher-option';
                    d.innerHTML = `<div class="teacher-avatar">${t.Name.charAt(0).toUpperCase()}</div><div><strong>${t.Name}</strong><br><small style="color:var(--ink-soft)">${t.Designation || ''}</small></div>`;
                    d.onclick = () => selectTeacher(t.UserId, t.Name);
                    drop.appendChild(d);
                });
            }
            drop.style.display = 'block';
        })
        .catch(() => { drop.innerHTML = '<div class="teacher-option" style="color:var(--danger)">Search failed. Try again.</div>'; drop.style.display = 'block'; });
}

function selectTeacher(id, name) {
    selectedTeacherId = id;
    document.getElementById('<%= hfInstructorId.ClientID %>').value = id;
    document.getElementById('selTeacherName').textContent = name;
    document.getElementById('selTeacherInitial').textContent = name.charAt(0).toUpperCase();
    document.getElementById('selectedTeacherWrap').style.display = 'block';
    document.getElementById('teacherDropdown').style.display = 'none';
    document.getElementById('txtTeacherSearch').value = '';
}
function clearTeacher() {
    selectedTeacherId = null;
    document.getElementById('<%= hfInstructorId.ClientID %>').value = '';
        document.getElementById('selectedTeacherWrap').style.display = 'none';
    }

    document.addEventListener('click', e => {
        if (!e.target.closest('.teacher-search-wrap')) document.getElementById('teacherDropdown').style.display = 'none';
    });

    // ── Topic rows ──
    function addTopicRow() {
        const c = document.getElementById('topicContainer');
        const r = document.createElement('div');
        r.className = 'topic-row';
        r.innerHTML = `<input type="text" name="topicTime" placeholder="00:00"><input type="text" name="topicTitle" placeholder="Topic name…"><button type="button" class="del-btn" onclick="removeTopicRow(this)"><i class="fa fa-times"></i></button>`;
        c.appendChild(r);
    }
    function removeTopicRow(btn) {
        const rows = document.querySelectorAll('#topicContainer .topic-row');
        if (rows.length > 1) btn.closest('.topic-row').remove();
    }

    // ── Upload progress ──
    function showUploadProgress() {
        const p = document.getElementById('uploadProgress');
        const f = document.getElementById('uploadFill');
        if (p) p.style.display = 'block';
        if (f) { let w = 0; const iv = setInterval(() => { w = Math.min(w + 8, 90); f.style.width = w + '%'; if (w >= 90) clearInterval(iv); }, 200); }
        return true;
    }
</script>
</asp:Content>
