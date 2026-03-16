<%@ Page Title="Study Material" Language="C#"
    MasterPageFile="~/Student/StudentMaster.Master"
    AutoEventWireup="true"
    CodeBehind="StudyMaterial.aspx.cs"
    Inherits="LMS_Project.Student.StudyMaterial" %>

<asp:Content ID="cHead" ContentPlaceHolderID="head" runat="server">
<style>

/* ── Back bar ── */
.back-bar {
    display: flex;
    align-items: center;
    gap: 14px;
    margin-bottom: 20px;
}
.back-bar a {
    display: flex; align-items: center; justify-content: center;
    width: 36px; height: 36px;
    border-radius: 9px;
    background: #e3f2fd;
    color: #1565c0;
    text-decoration: none;
    font-size: 14px;
    transition: background .2s;
}
.back-bar a:hover { background: #1565c0; color: #fff; }
.back-bar h4 { margin: 0; font-weight: 800; color: #1565c0; font-size: 18px; }
.back-bar .subject-code-badge {
    background: #e3f2fd;
    color: #1565c0;
    font-size: 11px;
    font-weight: 700;
    padding: 3px 12px;
    border-radius: 20px;
    border: 1.5px solid #90caf9;
}

/* ── Subject info strip ── */
.subject-info-strip {
    background: linear-gradient(135deg, #1565c0, #1976d2);
    border-radius: 14px;
    padding: 18px 24px;
    color: #fff;
    margin-bottom: 22px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    flex-wrap: wrap;
    gap: 12px;
}
.subject-info-strip .info-left h5 {
    margin: 0 0 4px;
    font-weight: 800;
    font-size: 17px;
}
.subject-info-strip .info-left p {
    margin: 0;
    font-size: 12px;
    opacity: .85;
}
.subject-info-strip .info-chips {
    display: flex; gap: 8px; flex-wrap: wrap;
}
.info-chip {
    background: rgba(255,255,255,.2);
    border-radius: 20px;
    padding: 4px 14px;
    font-size: 12px;
    font-weight: 600;
}

/* ── Two-panel layout ── */
.study-layout {
    display: flex;
    gap: 20px;
    align-items: flex-start;
}

/* LEFT — chapter list */
.chapter-panel {
    width: 300px;
    flex-shrink: 0;
    background: #fff;
    border-radius: 14px;
    box-shadow: 0 2px 10px rgba(0,0,0,.07);
    overflow: hidden;
    position: sticky;
    top: 20px;
}
.chapter-panel-header {
    background: #1565c0;
    color: #fff;
    padding: 14px 18px;
    font-size: 13px;
    font-weight: 700;
    display: flex;
    align-items: center;
    gap: 8px;
}
.chapter-list { padding: 8px 0; }

.chapter-item {
    border-bottom: 1px solid #f0f4f8;
}
.chapter-item:last-child { border-bottom: none; }

.chapter-toggle {
    width: 100%;
    background: none;
    border: none;
    padding: 12px 18px;
    display: flex;
    align-items: center;
    gap: 10px;
    cursor: pointer;
    text-align: left;
    transition: background .15s;
    font-size: 13px;
    font-weight: 600;
    color: #263238;
}
.chapter-toggle:hover { background: #f5f9ff; }
.chapter-toggle.active { background: #e3f2fd; color: #1565c0; }

.chapter-toggle .ch-num {
    width: 24px; height: 24px;
    border-radius: 50%;
    background: #e3f2fd;
    color: #1565c0;
    font-size: 11px;
    font-weight: 800;
    display: flex; align-items: center; justify-content: center;
    flex-shrink: 0;
}
.chapter-toggle.active .ch-num {
    background: #1565c0; color: #fff;
}
.chapter-toggle .ch-arrow {
    margin-left: auto;
    font-size: 10px;
    color: #90a4ae;
    transition: transform .2s;
}
.chapter-toggle.active .ch-arrow { transform: rotate(90deg); }

/* Content items under chapter */
.chapter-content-list {
    display: none;
    padding: 4px 0 8px 0;
    background: #f8fbff;
}
.chapter-content-list.open { display: block; }

.content-item {
    display: flex;
    align-items: center;
    gap: 10px;
    padding: 8px 18px 8px 40px;
    cursor: pointer;
    font-size: 12px;
    color: #546e7a;
    transition: background .15s, color .15s;
    border-left: 3px solid transparent;
}
.content-item:hover { background: #e3f2fd; color: #1565c0; }
.content-item.selected {
    background: #e3f2fd;
    color: #1565c0;
    border-left-color: #1565c0;
    font-weight: 600;
}
.content-item .ci-icon {
    width: 22px; height: 22px;
    border-radius: 6px;
    display: flex; align-items: center; justify-content: center;
    font-size: 11px;
    flex-shrink: 0;
}
.ci-video    { background: #fce4ec; color: #c62828; }
.ci-material { background: #e8f5e9; color: #2e7d32; }

/* RIGHT — content viewer */
.content-panel {
    flex: 1;
    min-width: 0;
}

/* Video player card */
.video-card {
    background: #fff;
    border-radius: 14px;
    box-shadow: 0 2px 10px rgba(0,0,0,.07);
    overflow: hidden;
    margin-bottom: 20px;
}
.video-player-area {
    background: #000;
    position: relative;
    width: 100%;
    padding-top: 56.25%; /* 16:9 */
}
.video-player-area video,
.video-player-area iframe {
    position: absolute;
    top: 0; left: 0;
    width: 100%; height: 100%;
    border: none;
}
.video-placeholder {
    position: absolute;
    top: 0; left: 0;
    width: 100%; height: 100%;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    color: #546e7a;
    background: #f0f4f8;
}
.video-placeholder i { font-size: 56px; color: #cfd8dc; margin-bottom: 12px; }
.video-placeholder p { font-size: 13px; margin: 0; }

.video-info { padding: 18px 20px; }
.video-info h5 {
    font-size: 16px; font-weight: 800;
    color: #1a237e; margin-bottom: 6px;
}
.video-info .vi-meta {
    font-size: 12px; color: #90a4ae;
    display: flex; gap: 16px; flex-wrap: wrap;
    margin-bottom: 10px;
}
.video-info .vi-desc {
    font-size: 13px; color: #546e7a;
    line-height: 1.6;
}

/* Topics timeline */
.topics-list {
    border-top: 1px solid #f0f4f8;
    padding: 14px 20px;
}
.topics-list h6 {
    font-size: 12px; font-weight: 700;
    text-transform: uppercase;
    letter-spacing: .5px;
    color: #90a4ae;
    margin-bottom: 10px;
}
.topic-item {
    display: flex; align-items: center;
    gap: 10px;
    padding: 5px 0;
    font-size: 12px;
    color: #546e7a;
    border-bottom: 1px dashed #f0f4f8;
}
.topic-item:last-child { border-bottom: none; }
.topic-time {
    background: #e3f2fd;
    color: #1565c0;
    font-size: 11px;
    font-weight: 700;
    padding: 2px 8px;
    border-radius: 6px;
    flex-shrink: 0;
    font-family: monospace;
}

/* Materials card */
.materials-card {
    background: #fff;
    border-radius: 14px;
    box-shadow: 0 2px 10px rgba(0,0,0,.07);
    overflow: hidden;
}
.materials-card-header {
    background: #e8f5e9;
    padding: 14px 18px;
    font-size: 13px;
    font-weight: 700;
    color: #2e7d32;
    display: flex; align-items: center; gap: 8px;
}
.material-row {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 12px 18px;
    border-bottom: 1px solid #f0f4f8;
    transition: background .15s;
}
.material-row:last-child { border-bottom: none; }
.material-row:hover { background: #f5fff5; }
.material-row .mat-icon {
    width: 36px; height: 36px;
    border-radius: 9px;
    display: flex; align-items: center; justify-content: center;
    font-size: 16px;
    flex-shrink: 0;
}
.mat-pdf  { background: #fce4ec; color: #c62828; }
.mat-doc  { background: #e3f2fd; color: #1565c0; }
.mat-ppt  { background: #fff3e0; color: #e65100; }
.mat-other{ background: #f3e5f5; color: #6a1b9a; }

.material-row .mat-title {
    font-size: 13px; font-weight: 600;
    color: #263238; flex: 1;
}
.material-row .mat-type {
    font-size: 11px; color: #90a4ae;
    margin-top: 2px;
}
.btn-download {
    padding: 5px 14px;
    background: #e8f5e9;
    color: #2e7d32;
    border-radius: 8px;
    font-size: 12px;
    font-weight: 600;
    text-decoration: none;
    border: 1.5px solid #a5d6a7;
    transition: all .2s;
    flex-shrink: 0;
}
.btn-download:hover {
    background: #2e7d32; color: #fff;
    border-color: #2e7d32;
}

/* Empty states */
.panel-empty {
    padding: 30px;
    text-align: center;
    color: #90a4ae;
}
.panel-empty i { font-size: 36px; display: block; margin-bottom: 8px; }
.panel-empty p { font-size: 13px; margin: 0; }

/* No subject selected */
.no-subject {
    background: #fff;
    border-radius: 14px;
    box-shadow: 0 2px 10px rgba(0,0,0,.07);
    padding: 60px 30px;
    text-align: center;
    color: #90a4ae;
}
.no-subject i { font-size: 64px; color: #cfd8dc; display: block; margin-bottom: 16px; }
.no-subject h5 { color: #546e7a; font-weight: 700; }

@media (max-width: 768px) {
    .study-layout { flex-direction: column; }
    .chapter-panel { width: 100%; position: static; }
}

</style>
</asp:Content>

<asp:Content ID="cBody" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<asp:HiddenField ID="hfSubjectId" runat="server" />

<%-- ══ BACK BAR ══ --%>
<div class="back-bar">
    <a href="MySubjects.aspx"><i class="fas fa-arrow-left"></i></a>
    <h4>Study Material</h4>
    <asp:Label ID="lblSubjectCodeBadge" runat="server" CssClass="subject-code-badge" />
</div>

<%-- ══ NO SUBJECT SELECTED ══ --%>
<asp:Panel ID="pnlNoSubject" runat="server" Visible="false">
    <div class="no-subject">
        <i class="fas fa-book-open"></i>
        <h5>No Subject Selected</h5>
        <p>Please select a subject from My Subjects page.</p>
        <a href="MySubjects.aspx" class="btn btn-primary mt-3" style="border-radius:9px;">
            <i class="fas fa-arrow-left me-2"></i>Go to My Subjects
        </a>
    </div>
</asp:Panel>

<%-- ══ SUBJECT CONTENT ══ --%>
<asp:Panel ID="pnlContent" runat="server" Visible="false">

    <%-- Subject info strip --%>
    <div class="subject-info-strip">
        <div class="info-left">
            <h5><asp:Label ID="lblSubjectName" runat="server" /></h5>
            <p><asp:Label ID="lblSubjectDesc" runat="server" /></p>
        </div>
        <div class="info-chips">
            <span class="info-chip">
                <i class="fas fa-user-tie me-1"></i>
                <asp:Label ID="lblTeacherName" runat="server" />
            </span>
            <span class="info-chip">
                <i class="fas fa-clock me-1"></i>
                <asp:Label ID="lblDuration" runat="server" />
            </span>
            <span class="info-chip">
                <i class="fas fa-list-ul me-1"></i>
                <asp:Label ID="lblChapterCount" runat="server" /> Chapters
            </span>
        </div>
    </div>

    <%-- Two-panel layout --%>
    <div class="study-layout">

        <%-- ═══ LEFT — Chapter accordion ═══ --%>
        <div class="chapter-panel">
            <div class="chapter-panel-header">
                <i class="fas fa-list-ul"></i> Course Content
            </div>

            <div class="chapter-list">

                <asp:Panel ID="pnlNoChapters" runat="server" Visible="false">
                    <div class="panel-empty">
                        <i class="fas fa-folder-open"></i>
                        <p>No chapters added yet.</p>
                    </div>
                </asp:Panel>

                <asp:Repeater ID="rptChapters" runat="server"
                    OnItemDataBound="rptChapters_ItemDataBound">
                    <ItemTemplate>
                        <div class="chapter-item">

                            <%-- Chapter header button --%>
                            <button type="button"
                                class="chapter-toggle"
                                onclick="toggleChapter(this, 'ch_<%# Eval("ChapterId") %>')">
                                <span class="ch-num"><%# Container.ItemIndex + 1 %></span>
                                <span class="ch-name"><%# Eval("ChapterName") %></span>
                                <i class="fas fa-chevron-right ch-arrow"></i>
                            </button>

                            <%-- Videos + Materials under chapter --%>
                            <div class="chapter-content-list" id="ch_<%# Eval("ChapterId") %>">

                                <asp:HiddenField ID="hfChapterId" runat="server"
                                    Value='<%# Eval("ChapterId") %>' />

                                <%-- Videos --%>
                                <asp:Repeater ID="rptVideos" runat="server">
                                    <ItemTemplate>
                                        <div class="content-item"
                                            onclick="loadVideo(
                                                '<%# Eval("VideoId") %>',
                                                '<%# Server.HtmlEncode(Eval("Title")?.ToString()) %>',
                                                '<%# Server.HtmlEncode(Eval("Description")?.ToString()) %>',
                                                '<%# Server.HtmlEncode(Eval("InstructorName")?.ToString()) %>',
                                                '<%# Server.HtmlEncode(Eval("VideoPath")?.ToString()) %>',
                                                this)">
                                            <span class="ci-icon ci-video">
                                                <i class="fas fa-play"></i>
                                            </span>
                                            <%# Eval("Title") %>
                                        </div>
                                    </ItemTemplate>
                                </asp:Repeater>

                                <%-- Materials --%>
                                <asp:Repeater ID="rptMaterials" runat="server">
                                    <ItemTemplate>
                                        <div class="content-item"
                                            onclick="loadMaterial(
                                                '<%# Server.HtmlEncode(Eval("Title")?.ToString()) %>',
                                                '<%# Server.HtmlEncode(Eval("FilePath")?.ToString()) %>',
                                                '<%# Server.HtmlEncode(Eval("FileType")?.ToString()) %>',
                                                this)">
                                            <span class="ci-icon ci-material">
                                                <i class="fas fa-file-alt"></i>
                                            </span>
                                            <%# Eval("Title") %>
                                            <span style="font-size:10px;color:#90a4ae;margin-left:auto;">
                                                <%# Eval("FileType") %>
                                            </span>
                                        </div>
                                    </ItemTemplate>
                                </asp:Repeater>

                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>

            </div>
        </div>
        <%-- /LEFT --%>

        <%-- ═══ RIGHT — Content viewer ═══ --%>
        <div class="content-panel">

            <%-- Default: pick something prompt --%>
            <div id="divSelectPrompt">
                <div class="no-subject">
                    <i class="fas fa-hand-point-left" style="font-size:48px; color:#90caf9;"></i>
                    <h5 style="margin-top:12px;">Select a video or material</h5>
                    <p>Click any item from the chapter list on the left to start studying.</p>
                </div>
            </div>

            <%-- Video viewer --%>
            <div id="divVideoViewer" style="display:none;">
                <div class="video-card">
                    <div class="video-player-area">
                        <video id="videoPlayer" controls controlsList="nodownload">
                            <source id="videoSource" src="" type="video/mp4" />
                            Your browser does not support HTML5 video.
                        </video>
                    </div>
                    <div class="video-info">
                        <h5 id="videoTitle"></h5>
                        <div class="vi-meta">
                            <span><i class="fas fa-user-tie me-1"></i><span id="videoInstructor"></span></span>
                        </div>
                        <div class="vi-desc" id="videoDesc"></div>
                    </div>
                    <div class="topics-list" id="topicsSection" style="display:none;">
                        <h6><i class="fas fa-list me-1"></i>Topics Covered</h6>
                        <div id="topicsList"></div>
                    </div>
                </div>
            </div>

            <%-- Material viewer --%>
            <div id="divMaterialViewer" style="display:none;">
                <div class="materials-card">
                    <div class="materials-card-header">
                        <i class="fas fa-file-alt"></i>
                        <span id="materialTitle"></span>
                    </div>
                    <div style="padding:30px; text-align:center;">
                        <div id="materialIconArea" style="margin-bottom:20px; font-size:64px;"></div>
                        <p style="font-size:14px; color:#546e7a;" id="materialName"></p>
                        <a id="materialDownloadLink" href="#" target="_blank"
                           class="btn-download" style="font-size:14px; padding:10px 28px;">
                            <i class="fas fa-download me-2"></i>Open / Download
                        </a>
                    </div>
                </div>
            </div>

            <%-- Topics fetch (hidden) — loaded via AJAX on video click --%>
            <asp:UpdatePanel ID="upTopics" runat="server" UpdateMode="Conditional">
                <ContentTemplate>
                    <asp:HiddenField ID="hfVideoId" runat="server" />
                    <asp:Repeater ID="rptTopics" runat="server">
                        <ItemTemplate>
                            <div class="topic-item" style="display:none;"
                                 data-time='<%# Eval("StartTime") %>'
                                 data-title='<%# Eval("TopicTitle") %>'>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </ContentTemplate>
                <Triggers>
                    <asp:AsyncPostBackTrigger ControlID="hfVideoId" EventName="ValueChanged" />
                </Triggers>
            </asp:UpdatePanel>

        </div>
        <%-- /RIGHT --%>

    </div>
</asp:Panel>

<script>

// ── Chapter accordion toggle ──────────────────────────────
function toggleChapter(btn, contentId) {
    var content = document.getElementById(contentId);
    var isOpen  = content.classList.contains('open');

    // Close all
    document.querySelectorAll('.chapter-content-list').forEach(function(el) {
        el.classList.remove('open');
    });
    document.querySelectorAll('.chapter-toggle').forEach(function(el) {
        el.classList.remove('active');
    });

    if (!isOpen) {
        content.classList.add('open');
        btn.classList.add('active');
    }
}

// ── Clear selected state from all content items ───────────
function clearSelected() {
    document.querySelectorAll('.content-item').forEach(function(el) {
        el.classList.remove('selected');
    });
}

// ── Load video into right panel ───────────────────────────
function loadVideo(videoId, title, desc, instructor, path, el) {
    clearSelected();
    el.classList.add('selected');

    // Hide others, show video
    document.getElementById('divSelectPrompt').style.display  = 'none';
    document.getElementById('divMaterialViewer').style.display = 'none';
    document.getElementById('divVideoViewer').style.display   = 'block';

    // Set video
    var player = document.getElementById('videoPlayer');
    document.getElementById('videoSource').src = path;
    player.load();

    // Set info
    document.getElementById('videoTitle').innerText      = title;
    document.getElementById('videoInstructor').innerText = instructor || 'N/A';
    document.getElementById('videoDesc').innerText       = desc || '';

    // Load topics via hidden field postback
    document.getElementById('<%= hfVideoId.ClientID %>').value = videoId;
    __doPostBack('<%= hfVideoId.ClientID %>', '');
    }

    // ── Load material into right panel ────────────────────────
    function loadMaterial(title, path, fileType, el) {
        clearSelected();
        el.classList.add('selected');

        document.getElementById('divSelectPrompt').style.display = 'none';
        document.getElementById('divVideoViewer').style.display = 'none';
        document.getElementById('divMaterialViewer').style.display = 'block';

        document.getElementById('materialTitle').innerText = title;
        document.getElementById('materialName').innerText = title + ' (' + fileType + ')';
        document.getElementById('materialDownloadLink').href = path;

        // Icon by file type
        var iconArea = document.getElementById('materialIconArea');
        var ext = fileType.toLowerCase().replace('.', '');
        if (ext === 'pdf') {
            iconArea.innerHTML = '<i class="fas fa-file-pdf" style="color:#c62828;"></i>';
        } else if (ext === 'doc' || ext === 'docx') {
            iconArea.innerHTML = '<i class="fas fa-file-word" style="color:#1565c0;"></i>';
        } else if (ext === 'ppt' || ext === 'pptx') {
            iconArea.innerHTML = '<i class="fas fa-file-powerpoint" style="color:#e65100;"></i>';
        } else {
            iconArea.innerHTML = '<i class="fas fa-file-alt" style="color:#6a1b9a;"></i>';
        }
    }

    // ── After topics UpdatePanel refreshes, populate topics list ──
    function Sys_Application_Load() {
        var topicItems = document.querySelectorAll('.topic-item[data-time]');
        var list = document.getElementById('topicsList');
        var section = document.getElementById('topicsSection');

        if (!list) return;
        list.innerHTML = '';

        topicItems.forEach(function (item) {
            var time = item.getAttribute('data-time');
            var title = item.getAttribute('data-title');
            if (time && title) {
                list.innerHTML +=
                    '<div class="topic-item">' +
                    '<span class="topic-time">' + time + '</span>' +
                    title +
                    '</div>';
            }
        });

        if (section) {
            section.style.display = list.innerHTML.trim() ? 'block' : 'none';
        }
    }

    // Hook into UpdatePanel complete
    if (typeof Sys !== 'undefined') {
        Sys.WebForms.PageRequestManager.getInstance()
            .add_endRequest(Sys_Application_Load);
    }

</script>

</asp:Content>
