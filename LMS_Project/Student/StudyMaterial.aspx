<%--<%@ Page Title="Study Material" Language="C#"
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

.ai-panel {
    background: rgba(255,255,255,0.6);
    backdrop-filter: blur(12px);
    border-radius: 12px;
    padding: 15px;
    margin-top: 15px;
}

.ai-tabs button {
    margin-right: 10px;
    background: linear-gradient(135deg,#1565c0,#42a5f5);
    border:none;
    color:#fff;
    padding:6px 12px;
    border-radius:8px;
}

.ai-chat {
    margin-top:10px;
    display:flex;
    gap:10px;
}

.ai-response {
    margin-top:10px;
    max-height:200px;
    overflow:auto;
    font-size:13px;
}

.comments-box {
    margin-top:20px;
}

.playlist-box {
    margin-top:20px;
}

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


<div class="back-bar">
    <a href="MySubjects.aspx"><i class="fas fa-arrow-left"></i></a>
    <h4>Study Material</h4>
    <asp:Label ID="lblSubjectCodeBadge" runat="server" CssClass="subject-code-badge" />
</div>


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


<asp:Panel ID="pnlContent" runat="server" Visible="false">

   
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

  
    <div class="study-layout">

     
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

                  
                            <button type="button"
                                class="chapter-toggle"
                                onclick="toggleChapter(this, 'ch_<%# Eval("ChapterId") %>')">
                                <span class="ch-num"><%# Container.ItemIndex + 1 %></span>
                                <span class="ch-name"><%# Eval("ChapterName") %></span>
                                <i class="fas fa-chevron-right ch-arrow"></i>
                            </button>

                        
                            <div class="chapter-content-list" id="ch_<%# Eval("ChapterId") %>">

                                <asp:HiddenField ID="hfChapterId" runat="server"
                                    Value='<%# Eval("ChapterId") %>' />

                                <asp:Repeater ID="rptVideos" runat="server">
                                    <ItemTemplate>
                                        <div class="content-item"
                                            onclick="loadVideo(
                                                '<%# Eval("VideoId") %>',
                                                '<%# Server.HtmlEncode(Eval("Title")?.ToString()) %>',
                                                '<%# Eval("Description") != DBNull.Value ? Server.HtmlEncode(Eval("Description").ToString()) : "" %>',
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
     
        <div class="content-panel">

           
            <div id="divSelectPrompt">
                <div class="no-subject">
                    <i class="fas fa-hand-point-left" style="font-size:48px; color:#90caf9;"></i>
                    <h5 style="margin-top:12px;">Select a video or material</h5>
                    <p>Click any item from the chapter list on the left to start studying.</p>
                </div>
            </div>

           
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

             
                <div class="ai-panel">

                    <div class="ai-tabs">
                        <button onclick="aiAction('summary')">Summary</button>
                        <button onclick="aiAction('notes')">Notes</button>
                        <button onclick="aiAction('quiz')">Quiz</button>
                    </div>

                    <div class="ai-chat">
                        <input type="text" id="aiQuestion" placeholder="Ask doubt..." />
                        <button onclick="askAI()">Ask</button>
                    </div>

                    <div id="aiResponse" class="ai-response"></div>

                </div>

                <div class="video-actions">
                    <span id="viewCount"></span>
                    <span id="ratingStars"></span>
                </div>

                <div class="comments-box">
                    <h6>Comments</h6>
                    <div id="commentsList"></div>

                    <input type="text" id="commentTxt" placeholder="Write comment..." />
                    <button onclick="postComment()">Post</button>
                </div>

                <div class="playlist-box">
                    <h6>Playlist</h6>
                    <div id="playlist"></div>
                </div>

            </div>

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
     

    </div>
</asp:Panel>

<script>

// ── Chapter accordion toggle ──────────────────────────────
function toggleChapter(btn, contentId) {
    var content = document.getElementById(contentId);
    var isOpen  = content.classList.contains('open');
    var currentVideoId = 0;
    var currentVideoName = "";

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

    currentVideoId = videoId;
    currentVideoName = title;

    // Hide others, show video
    document.getElementById('divSelectPrompt').style.display  = 'none';
    document.getElementById('divMaterialViewer').style.display = 'none';
    document.getElementById('divVideoViewer').style.display   = 'block';

    // Set video
    var player = document.getElementById('videoPlayer');
    document.getElementById('videoSource').src = path;
    player.load();
    player.play(); // ✅ ADD THIS

    // Set info
    document.getElementById('videoTitle').innerText      = title;
    document.getElementById('videoInstructor').innerText = instructor || 'N/A';
    document.getElementById('videoDesc').innerText       = desc || '';

    // Load topics via hidden field postback
    document.getElementById('<%= hfVideoId.ClientID %>').value = videoId;
    __doPostBack('<%= hfVideoId.ClientID %>', '');

    loadStats();
    loadComments();
    loadPlaylist();

    increaseView();
    }

    //-- video controls features
    const player = document.getElementById("videoPlayer");

    function skip(sec) {
        player.currentTime += sec;
    }

    function toggleLoop() {
        player.loop = !player.loop;
    }

    function changeSpeed(rate) {
        player.playbackRate = rate;
    }

    function screenshot() {
        let canvas = document.createElement("canvas");
        canvas.width = player.videoWidth;
        canvas.height = player.videoHeight;
        canvas.getContext("2d").drawImage(player, 0, 0);

        let link = document.createElement("a");
        link.download = "screenshot.png";
        link.href = canvas.toDataURL();
        link.click();
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
    //----- Summary / Notes / Quiz
    function aiAction(type) {
        let url = "";

        if (type === "summary") url = "http://localhost:8000/generate-summary";
        if (type === "notes") url = "http://localhost:8000/generate-notes";
        if (type === "quiz") url = "http://localhost:8000/generate-quiz";

        fetch(url, {
            method: "POST",
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(currentVideoName)
        })
            .then(res => res.json())
            .then(data => {
                document.getElementById("aiResponse").innerText = "Loading...";
            });
    }

    //---Ask AI doubts
    function askAI() {

        let q = document.getElementById("aiQuestion").value;

        fetch("http://localhost:8000/ask-ai?video_name=" + currentVideoName + "&question=" + q)
            .then(res => {
                const reader = res.body.getReader();
                const decoder = new TextDecoder();

                let result = "";

                function read() {
                    reader.read().then(({ done, value }) => {
                        if (done) return;

                        result += decoder.decode(value);
                        document.getElementById("aiResponse").innerText = result;

                        read();
                    });
                }
                read();
            });
    }

    //---comments
    function postComment() {

        fetch("StudyMaterial.aspx/PostComment", {
            method: "POST",
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ videoId: currentVideoId, comment: document.getElementById("commentTxt").value })
        }).then(() => loadComments());
    }

    function loadComments() {
        fetch("StudyMaterial.aspx/GetComments", {
            method: "POST",
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ videoId: currentVideoId })
        })
            .then(res => res.json())
            .then(data => {
                let html = "";
                data.d.forEach(c => {
                    html += `<div>${c.Username}: ${c.Comment}</div>`;
                });
                document.getElementById("commentsList").innerHTML = html;
            });
    }

    //---view counts
    function increaseView() {
        fetch("StudyMaterial.aspx/AddView", {
            method: "POST",
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ videoId: currentVideoId })
        });
    }

    function loadStats() {
        fetch("StudyMaterial.aspx/GetStats", {
            method: "POST",
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ videoId: currentVideoId })
        })
            .then(res => res.json())
            .then(d => {
                document.getElementById("viewCount").innerText = d.d.Views + " views";
            });
    }

    //---playlist
    function loadPlaylist() {
        fetch("StudyMaterial.aspx/GetPlaylist")
            .then(res => res.json())
            .then(data => {
                let html = "";
                data.d.forEach(v => {
                    html += `<div onclick="loadVideo('${v.VideoId}','${v.Title}','','','${v.VideoPath}',this)">
                        ▶ ${v.Title}
                    </div>`;
                });
                document.getElementById("playlist").innerHTML = html;
            });
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

    let counted = false;

    player.addEventListener("timeupdate", function () {
        if (!counted && player.currentTime > 10) {
            increaseView();
            counted = true;
        }
    });

</script>


</asp:Content>--%>


<%-- -------------------------------------------------------------------------------------------------------------------- --%>

<%@ Page Title="Study Material" Language="C#"
    MasterPageFile="~/Student/StudentMaster.Master"
    AutoEventWireup="true"
    CodeBehind="StudyMaterial.aspx.cs"
    Inherits="LMS_Project.Student.StudyMaterial" %>

<asp:Content ID="cHead" ContentPlaceHolderID="head" runat="server">
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
<style>
/* ═══════ CSS VARIABLES ═══════ */
:root{
  --blue:#1565c0;--blue-l:#e3f2fd;--blue-d:#0d47a1;
  --green:#2e7d32;--green-l:#e8f5e9;
  --purple:#6a1b9a;--purple-l:#f3e5f5;
  --amber:#e65100;--amber-l:#fff3e0;
  --red:#c62828;--red-l:#fce4ec;
  --gold:#f59e0b;
  --bg:#f0f4f8;--card:#fff;--border:#e0e7ef;
  --muted:#546e7a;--dim:#90a4ae;
  --sh:0 2px 12px rgba(21,101,192,.08);
  --shl:0 8px 32px rgba(21,101,192,.14);
  --r:14px;
  --f:'Plus Jakarta Sans',system-ui,sans-serif;
}
*,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
body{font-family:var(--f);background:var(--bg);color:#263238;font-size:14px}

/* ═══════ TOP BAR ═══════ */
.top-bar{display:flex;align-items:center;gap:14px;margin-bottom:18px;flex-wrap:wrap}
.back-btn{width:36px;height:36px;border-radius:9px;background:var(--blue-l);
  color:var(--blue);display:flex;align-items:center;justify-content:center;
  text-decoration:none;font-size:14px;flex-shrink:0;transition:.2s}
.back-btn:hover{background:var(--blue);color:#fff}
.top-bar h4{font-size:1.1rem;font-weight:800;color:var(--blue);margin:0;flex:1}
.sbadge{background:var(--blue-l);color:var(--blue);font-size:11px;font-weight:700;
  padding:3px 12px;border-radius:20px;border:1.5px solid #90caf9}

/* ═══════ SUBJECT STRIP ═══════ */
.subj-strip{background:linear-gradient(135deg,var(--blue),#1976d2);
  border-radius:var(--r);padding:16px 22px;color:#fff;margin-bottom:20px;
  display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;
  gap:12px;box-shadow:var(--shl)}
.subj-strip h5{font-size:16px;font-weight:800;margin:0 0 3px}
.subj-strip p{font-size:12px;opacity:.85;margin:0}
.chips{display:flex;gap:8px;flex-wrap:wrap}
.chip{background:rgba(255,255,255,.2);border-radius:20px;padding:4px 13px;
  font-size:12px;font-weight:600}

/* ═══════ PROGRESS CARDS ═══════ */
.prog-overview{display:grid;grid-template-columns:repeat(auto-fill,minmax(175px,1fr));
  gap:12px;margin-bottom:20px}
.prog-card{background:var(--card);border:1px solid var(--border);border-radius:12px;
  padding:14px;box-shadow:var(--sh)}
.pc-lbl{font-size:10px;font-weight:700;text-transform:uppercase;
  letter-spacing:.05em;color:var(--muted);margin-bottom:5px}
.pc-val{font-size:1.5rem;font-weight:800;color:var(--blue);font-family:monospace}
.pc-sub{font-size:11px;color:var(--muted);margin-top:2px}
.prog-bar{height:5px;background:var(--border);border-radius:4px;overflow:hidden;margin-top:8px}
.prog-fill{height:100%;border-radius:4px;
  background:linear-gradient(90deg,var(--blue),#42a5f5);transition:width .6s ease}

/* ═══════ LAYOUT ═══════ */
.study-layout{display:flex;gap:20px;align-items:flex-start}
@media(max-width:768px){.study-layout{flex-direction:column}}

/* ═══════ LEFT CHAPTER PANEL ═══════ */
.ch-panel{width:285px;flex-shrink:0;background:var(--card);border-radius:var(--r);
  box-shadow:var(--sh);border:1px solid var(--border);
  position:sticky;top:14px;max-height:calc(100vh - 120px);
  display:flex;flex-direction:column}
@media(max-width:768px){.ch-panel{width:100%;position:static;max-height:360px}}
.ch-hdr{background:var(--blue);color:#fff;padding:13px 16px;font-size:13px;
  font-weight:700;display:flex;align-items:center;gap:8px;flex-shrink:0}
.ch-scroll{overflow-y:auto;flex:1}
.ch-item{border-bottom:1px solid var(--border)}
.ch-item:last-child{border-bottom:none}
.ch-toggle{width:100%;background:none;border:none;padding:11px 14px;
  display:flex;align-items:center;gap:8px;cursor:pointer;
  font-size:12px;font-weight:600;color:#263238;transition:background .15s;
  font-family:var(--f);text-align:left}
.ch-toggle:hover{background:#f5f9ff}
.ch-toggle.open{background:var(--blue-l);color:var(--blue)}
.ch-num{width:22px;height:22px;border-radius:50%;background:var(--blue-l);
  color:var(--blue);font-size:10px;font-weight:800;
  display:flex;align-items:center;justify-content:center;flex-shrink:0}
.ch-toggle.open .ch-num{background:var(--blue);color:#fff}
.ch-name{flex:1}
.ch-pct-lbl{font-size:10px;color:var(--dim)}
.ch-arrow{font-size:10px;color:var(--dim);transition:transform .2s}
.ch-toggle.open .ch-arrow{transform:rotate(90deg)}
.ch-pbar-wrap{height:3px;background:var(--border);margin:0 14px 6px}
.ch-pbar{height:100%;background:linear-gradient(90deg,var(--blue),#42a5f5);
  border-radius:4px;transition:width .4s}
.ch-body{display:none;background:#f8fbff;padding:2px 0 6px}
.ch-body.open{display:block}

/* Content items */
.ci{display:flex;align-items:center;gap:8px;padding:7px 14px 7px 32px;
  cursor:pointer;font-size:12px;color:var(--muted);
  transition:background .15s,color .15s;border-left:3px solid transparent;
  position:relative}
.ci:hover{background:var(--blue-l);color:var(--blue)}
.ci.active{background:var(--blue-l);color:var(--blue);
  border-left-color:var(--blue);font-weight:600}
.ci-ico{width:18px;height:18px;border-radius:4px;
  display:flex;align-items:center;justify-content:center;
  font-size:9px;flex-shrink:0}
.ci-v{background:var(--red-l);color:var(--red)}
.ci-m{background:var(--green-l);color:var(--green)}
.ci-done{position:absolute;right:8px;color:#43a047;font-size:10px;display:none}
.ci-done.show{display:inline}

/* ═══════ RIGHT CONTENT PANEL ═══════ */
.content-panel{flex:1;min-width:0}
.select-prompt{background:var(--card);border:1px solid var(--border);
  border-radius:var(--r);box-shadow:var(--sh);
  padding:56px 28px;text-align:center;color:var(--muted)}
.no-subj{padding:56px 28px;text-align:center;color:var(--muted)}

/* ═══════ VIDEO CARD ═══════ */
.vc{background:var(--card);border-radius:var(--r);box-shadow:var(--sh);
  border:1px solid var(--border);overflow:hidden;margin-bottom:14px}

/* 16:9 wrapper */
.vp-wrap{background:#000;position:relative;width:100%;padding-top:56.25%}
#vp{position:absolute;top:0;left:0;width:100%;height:100%;border:none;display:block}

/* Overlays */
.ov{position:absolute;inset:0;display:flex;flex-direction:column;
  align-items:center;justify-content:center;color:#fff;z-index:15}
.ov-skip{background:rgba(0,0,0,.78);transition:opacity .3s}
.ov-skip.hidden{opacity:0;pointer-events:none}
.ov-skip h4{font-size:16px;margin-bottom:8px}
.ov-skip p{font-size:12px;opacity:.85;text-align:center;padding:0 24px;max-width:360px}

.ov-engage{background:rgba(0,0,0,.88);display:none}
.ov-engage.show{display:flex}
.engage-q{font-size:1.1rem;font-weight:700;margin-bottom:18px;
  text-align:center;padding:0 28px}
.engage-opts{display:flex;gap:10px;flex-wrap:wrap;justify-content:center}
.engage-opt{background:rgba(255,255,255,.15);border:2px solid rgba(255,255,255,.3);
  color:#fff;border-radius:9px;padding:9px 18px;cursor:pointer;
  font-size:13px;font-weight:600;font-family:var(--f);transition:.2s}
.engage-opt:hover{background:rgba(255,255,255,.3)}
.engage-opt.correct{border-color:#43a047;background:rgba(67,160,71,.3)}
.engage-opt.wrong{border-color:#e53935;background:rgba(229,57,53,.3)}
.ss-flash{position:absolute;inset:0;background:#fff;
  opacity:0;pointer-events:none;z-index:30;transition:opacity .08s}

/* Caption bar */
.cap-bar{background:rgba(0,0,0,.78);color:#fff;text-align:center;
  padding:5px 14px;font-size:13px;min-height:28px;display:none}
.cap-bar.show{display:block}

/* Control bar */
.ctrl-bar{display:flex;align-items:center;gap:6px;padding:8px 12px;
  background:#fafbff;border-top:1px solid var(--border);flex-wrap:wrap}
.cb{background:var(--blue-l);color:var(--blue);border:none;border-radius:7px;
  padding:5px 10px;font-size:12px;font-weight:600;cursor:pointer;
  font-family:var(--f);display:inline-flex;align-items:center;gap:4px;transition:.15s}
.cb:hover{background:var(--blue);color:#fff}
.cb.on{background:var(--blue);color:#fff}
.cb:disabled,.cb[disabled]{opacity:.35;cursor:not-allowed;pointer-events:none}
.csel{border:1px solid var(--border);border-radius:7px;padding:4px 7px;
  font-size:12px;font-family:var(--f);background:#fff;color:var(--blue);cursor:pointer}
.cdiv{width:1px;height:18px;background:var(--border);margin:0 2px;flex-shrink:0}

/* Video info area */
.vinfo{padding:14px 18px 10px}
.vinfo h5{font-size:15px;font-weight:800;color:var(--blue);margin-bottom:5px}
.vi-meta{display:flex;gap:14px;flex-wrap:wrap;font-size:12px;
  color:var(--muted);margin-bottom:6px;align-items:center}
.vi-desc{font-size:13px;color:var(--muted);line-height:1.6}

/* Watch progress bar under video */
.wp-strip{padding:6px 18px 12px}
.wp-lbl{font-size:10px;font-weight:700;color:var(--muted);margin-bottom:3px}
.wp-bar{height:5px;background:var(--border);border-radius:4px;overflow:hidden}
.wp-fill{height:100%;background:linear-gradient(90deg,#43a047,#66bb6a);
  border-radius:4px;transition:width .3s}

/* Rating stars */
.star-row{display:flex;align-items:center;gap:4px}
.star{font-size:18px;cursor:pointer;color:#d1d5db;transition:color .15s;line-height:1}
.star.on{color:var(--gold)}
.star:hover,.star.hover{color:var(--gold)}
.rating-info{font-size:12px;color:var(--muted);margin-left:6px}

/* Topics strip */
.topics-strip{border-top:1px solid var(--border);padding:10px 16px}
.topics-strip h6{font-size:10px;font-weight:700;text-transform:uppercase;
  letter-spacing:.05em;color:var(--muted);margin-bottom:7px}
.topic-row{display:flex;align-items:center;gap:8px;padding:3px 0;
  font-size:12px;color:var(--muted);border-bottom:1px dashed #f0f4f8}
.topic-row:last-child{border-bottom:none}
.ttm{background:var(--blue-l);color:var(--blue);font-size:10px;font-weight:700;
  padding:2px 7px;border-radius:4px;font-family:monospace;
  cursor:pointer;flex-shrink:0;transition:.15s}
.ttm:hover{background:var(--blue);color:#fff}

/* ═══════ TABS ═══════ */
.tabs{display:flex;border-bottom:2px solid var(--border);overflow-x:auto;flex-shrink:0}
.tab-btn{background:none;border:none;padding:10px 16px;font-size:12px;
  font-weight:600;color:var(--muted);cursor:pointer;font-family:var(--f);
  border-bottom:3px solid transparent;margin-bottom:-2px;
  white-space:nowrap;transition:.2s;flex-shrink:0}
.tab-btn:hover{color:var(--blue)}
.tab-btn.on{color:var(--blue);border-bottom-color:var(--blue)}
.tab-pane{display:none}
.tab-pane.on{display:block}

/* ═══════ AI PANEL ═══════ */
.ai-hdr{background:linear-gradient(135deg,#4527a0,#7b1fa2);
  padding:12px 16px;color:#fff;display:flex;align-items:center;gap:9px}
.ai-hdr h5{font-size:13px;font-weight:700;margin:0;flex:1}
.ai-actions{display:flex;gap:7px;padding:12px 14px;
  flex-wrap:wrap;border-bottom:1px solid var(--border)}
.ai-btn{background:var(--purple-l);color:var(--purple);
  border:1.5px solid #ce93d8;border-radius:8px;
  padding:7px 13px;font-size:12px;font-weight:700;cursor:pointer;
  font-family:var(--f);display:inline-flex;align-items:center;gap:5px;transition:.15s}
.ai-btn:hover{background:var(--purple);color:#fff;border-color:var(--purple)}
.ai-ask-row{display:flex;gap:7px;padding:10px 13px;
  border-bottom:1px solid var(--border)}
.ai-ask-row input{flex:1;border:1.5px solid var(--border);border-radius:8px;
  padding:7px 11px;font-size:13px;font-family:var(--f);color:#263238;transition:.2s}
.ai-ask-row input:focus{border-color:var(--purple);outline:none;
  box-shadow:0 0 0 3px rgba(106,27,154,.08)}
.ai-ask-row button{background:var(--purple);color:#fff;border:none;
  border-radius:8px;padding:7px 14px;font-size:13px;
  font-weight:700;cursor:pointer;font-family:var(--f);transition:.15s}
.ai-ask-row button:hover{background:#4527a0}
.ai-result{padding:13px;min-height:80px;max-height:320px;overflow-y:auto;
  font-size:13px;color:#263238;line-height:1.75;white-space:pre-wrap}
.ai-result.dim{color:var(--dim);font-style:italic}
.ai-result.typing::after{content:'▋';animation:blink .7s infinite}
@keyframes blink{0%,100%{opacity:1}50%{opacity:0}}
.hist-toggle{padding:7px 13px;border-top:1px solid var(--border);cursor:pointer;
  font-size:11px;font-weight:700;color:var(--purple);
  display:flex;align-items:center;gap:6px;user-select:none}
.hist-body{display:none;max-height:220px;overflow-y:auto;
  border-top:1px solid var(--border)}
.hist-body.open{display:block}
.hist-item{background:#f8f0ff;border-radius:8px;padding:8px 11px;
  margin:7px 13px;border-left:3px solid var(--purple)}
.hi-q{font-size:11px;font-weight:700;color:var(--purple);margin-bottom:2px}
.hi-a{font-size:11px;color:var(--muted)}
.hi-t{font-size:10px;color:var(--dim);margin-top:2px}

/* ═══════ COMMENTS ═══════ */
.cf-row{display:flex;gap:5px;margin-bottom:10px;flex-wrap:wrap}
.cf-btn{border:1.5px solid var(--border);border-radius:20px;padding:3px 12px;
  font-size:11px;font-weight:600;cursor:pointer;
  background:var(--card);color:var(--muted);font-family:var(--f);transition:.15s}
.cf-btn.on{background:var(--blue);color:#fff;border-color:var(--blue)}
.cmt-input-row{display:flex;gap:8px;margin-bottom:13px;align-items:flex-start}
.cmt-input-row textarea{flex:1;border:1.5px solid var(--border);border-radius:8px;
  padding:8px 10px;font-size:13px;font-family:var(--f);
  resize:none;height:56px;color:#263238;transition:.2s}
.cmt-input-row textarea:focus{border-color:var(--blue);outline:none;
  box-shadow:0 0 0 3px rgba(21,101,192,.08)}
.post-btn{background:var(--blue);color:#fff;border:none;border-radius:8px;
  padding:8px 13px;font-size:13px;font-weight:700;
  cursor:pointer;font-family:var(--f);transition:.15s;flex-shrink:0}
.post-btn:hover{background:var(--blue-d)}
.cmt{display:flex;gap:9px;padding:9px 0;border-bottom:1px solid #f0f4f8}
.cmt:last-child{border-bottom:none}
.c-av{width:30px;height:30px;border-radius:50%;
  display:flex;align-items:center;justify-content:center;
  font-size:12px;font-weight:700;color:#fff;flex-shrink:0}
.c-nm{font-size:13px;font-weight:700;color:#263238}
.c-rl{font-size:10px;font-weight:700;padding:1px 6px;
  border-radius:9px;margin-left:4px}
.rl-s{background:#e3f2fd;color:var(--blue)}
.rl-t{background:#e8f5e9;color:var(--green)}
.rl-a{background:#fce4ec;color:var(--red)}
.c-tx{font-size:13px;color:#546e7a;margin:3px 0;line-height:1.5}
.c-mt{font-size:10px;color:var(--dim);display:flex;gap:10px;align-items:center}
.rb{background:none;border:none;color:var(--blue);font-size:10px;
  font-weight:700;cursor:pointer;font-family:var(--f);padding:0}
.rb:hover{text-decoration:underline}
.replies{margin-top:6px;padding-left:13px;border-left:2px solid var(--border)}

/* ═══════ NOTES ═══════ */
.n-tb{display:flex;gap:5px;padding:8px 13px;background:#fafbff;
  border-bottom:1px solid var(--border);flex-wrap:wrap}
.nt{background:var(--blue-l);color:var(--blue);border:none;border-radius:6px;
  width:27px;height:27px;display:flex;align-items:center;justify-content:center;
  cursor:pointer;font-size:12px;transition:.15s;font-family:var(--f)}
.nt:hover{background:var(--blue);color:#fff}
.nsep{width:1px;height:22px;background:var(--border);margin:0 2px}
.n-ed{min-height:280px;padding:14px;font-size:13px;line-height:1.7;
  color:#263238;outline:none;overflow-y:auto}
.n-ed:empty::before{content:'Start typing your notes here…';
  color:var(--dim);font-style:italic;pointer-events:none}
.n-footer{display:flex;justify-content:space-between;align-items:center;
  padding:9px 13px;border-top:1px solid var(--border)}
.n-save-btn{background:var(--blue);color:#fff;border:none;border-radius:8px;
  padding:7px 18px;font-size:13px;font-weight:700;
  cursor:pointer;font-family:var(--f);transition:.15s}
.n-save-btn:hover{background:var(--blue-d)}
.n-st{font-size:11px;color:var(--muted)}

/* ═══════ MATERIAL VIEWER ═══════ */
.mat-card{background:var(--card);border:1px solid var(--border);
  border-radius:var(--r);box-shadow:var(--sh);overflow:hidden;margin-bottom:14px}
.mat-hdr{background:var(--green-l);padding:13px 16px;font-size:13px;
  font-weight:700;color:var(--green);display:flex;align-items:center;gap:8px;
  border-bottom:1px solid var(--border)}
.mat-embed-frame{width:100%;height:540px;border:none;display:block}
.mat-fallback{padding:28px;text-align:center}
.mat-icon{font-size:60px;margin-bottom:14px}
.mat-dl{display:inline-flex;align-items:center;gap:8px;
  background:var(--green-l);color:var(--green);
  border:1.5px solid #a5d6a7;border-radius:9px;
  padding:9px 22px;font-size:13px;font-weight:700;
  text-decoration:none;transition:.2s}
.mat-dl:hover{background:var(--green);color:#fff}

/* Mat AI header */
.ai-hdr-green{background:linear-gradient(135deg,#1b5e20,#2e7d32)}

/* scrollbar */
::-webkit-scrollbar{width:4px;height:4px}
::-webkit-scrollbar-thumb{background:#b0bec5;border-radius:4px}

@media(max-width:600px){
  .cb span{display:none}
  .vinfo h5{font-size:13px}
  .prog-overview{grid-template-columns:1fr 1fr}
}
</style>
</asp:Content>

<asp:Content ID="cBody" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<%-- ══ SERVER HIDDEN FIELDS — filled in Page_Load ══ --%>
<asp:HiddenField ID="hfSubjectId"   runat="server" />
<asp:HiddenField ID="hfSessionId"   runat="server" />
<asp:HiddenField ID="hfUserId"      runat="server" />
<asp:HiddenField ID="hfInstituteId" runat="server" />
<asp:HiddenField ID="hfSocietyId"   runat="server" />

<%-- ══ UPDATE PANEL — TOPICS ONLY (async, no full postback) ══ --%>
<asp:UpdatePanel ID="upTopics" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <asp:HiddenField ID="hfTopicVideoId" runat="server" />
        <span id="topicDataSpan">
            <asp:Repeater ID="rptTopics" runat="server">
                <ItemTemplate>
                    <span class="tdata"
                          data-time='<%# Eval("StartTime") %>'
                          data-title='<%# Eval("TopicTitle") %>'
                          style="display:none"></span>
                </ItemTemplate>
            </asp:Repeater>
        </span>
    </ContentTemplate>
    <Triggers>
        <asp:AsyncPostBackTrigger ControlID="hfTopicVideoId" EventName="ValueChanged" />
    </Triggers>
</asp:UpdatePanel>

<%-- ══ NO SUBJECT PANEL ══ --%>
<asp:Panel ID="pnlNoSubject" runat="server" Visible="false">
    <div class="no-subj">
        <i class="fas fa-book-open"
           style="font-size:56px;color:#cfd8dc;display:block;margin-bottom:14px"></i>
        <h5 style="font-weight:700;color:#546e7a;margin-bottom:8px">No Subject Selected</h5>
        <p>Please go back and select a subject.</p>
        <a href="MySubjects.aspx" class="btn btn-primary mt-3" style="border-radius:9px">
            <i class="fas fa-arrow-left me-2"></i>My Subjects
        </a>
    </div>
</asp:Panel>

<%-- ══ MAIN CONTENT ══ --%>
<asp:Panel ID="pnlContent" runat="server" Visible="false">

<%-- Top bar --%>
<div class="top-bar">
    <a href="MySubjects.aspx" class="back-btn"><i class="fas fa-arrow-left"></i></a>
    <h4>Study Material</h4>
    <asp:Label ID="lblSubjectCodeBadge" runat="server" CssClass="sbadge" />
</div>

<%-- Subject strip --%>
<div class="subj-strip">
    <div>
        <h5><asp:Label ID="lblSubjectName" runat="server" /></h5>
        <p><asp:Label ID="lblSubjectDesc" runat="server" /></p>
    </div>
    <div class="chips">
        <span class="chip">
            <i class="fas fa-user-tie me-1"></i>
            <asp:Label ID="lblTeacherName" runat="server" />
        </span>
        <span class="chip">
            <i class="fas fa-clock me-1"></i>
            <asp:Label ID="lblDuration" runat="server" />
        </span>
        <span class="chip">
            <i class="fas fa-list-ul me-1"></i>
            <asp:Label ID="lblChapterCount" runat="server" /> Chapters
        </span>
    </div>
</div>

<%-- Progress overview --%>
<div class="prog-overview">
    <div class="prog-card">
        <div class="pc-lbl">Overall Progress</div>
        <div class="pc-val" id="pOverall">—</div>
        <div class="pc-sub">of all videos</div>
        <div class="prog-bar"><div class="prog-fill" id="fOverall" style="width:0%"></div></div>
    </div>
    <div class="prog-card">
        <div class="pc-lbl">Videos Watched</div>
        <div class="pc-val" id="pWatched">—</div>
        <div class="pc-sub" id="pWatchedSub">of 0 total</div>
    </div>
    <div class="prog-card">
        <div class="pc-lbl">Syllabus Covered</div>
        <div class="pc-val" id="pSyllabus">—</div>
        <div class="pc-sub">chapters done</div>
        <div class="prog-bar"><div class="prog-fill" id="fSyllabus" style="width:0%"></div></div>
    </div>
    <div class="prog-card">
        <div class="pc-lbl">Current Video</div>
        <div class="pc-val" id="pCurrent">—</div>
        <div class="pc-sub" id="pCurrentLbl">No video selected</div>
        <div class="prog-bar"><div class="prog-fill" id="fCurrent" style="width:0%"></div></div>
    </div>
</div>

<%-- Two-panel layout --%>
<div class="study-layout">

    <%-- ══════ LEFT: CHAPTER PANEL ══════ --%>
    <div class="ch-panel">
        <div class="ch-hdr"><i class="fas fa-list-ul"></i>&nbsp;Course Content</div>
        <div class="ch-scroll">

            <asp:Panel ID="pnlNoChapters" runat="server" Visible="false">
                <div style="padding:20px;text-align:center;color:var(--muted)">
                    <i class="fas fa-folder-open"
                       style="font-size:2rem;opacity:.25;display:block;margin-bottom:7px"></i>
                    <p style="font-size:12px">No chapters added yet.</p>
                </div>
            </asp:Panel>

            <asp:Repeater ID="rptChapters" runat="server"
                          OnItemDataBound="rptChapters_ItemDataBound">
                <ItemTemplate>
                    <div class="ch-item">

                        <%-- Chapter header button — type="button" prevents postback --%>
                        <button type="button" class="ch-toggle"
                                onclick="toggleCh(this,'chb_<%# Eval("ChapterId") %>')">
                            <span class="ch-num"><%# Container.ItemIndex+1 %></span>
                            <span class="ch-name"><%# Eval("ChapterName") %></span>
                            <span class="ch-pct-lbl" data-cid="<%# Eval("ChapterId") %>">0%</span>
                            <i class="fas fa-chevron-right ch-arrow"></i>
                        </button>

                        <div class="ch-pbar-wrap">
                            <div class="ch-pbar" id="cpb_<%# Eval("ChapterId") %>"
                                 style="width:0%"></div>
                        </div>

                        <div class="ch-body" id="chb_<%# Eval("ChapterId") %>">
                            <asp:HiddenField ID="hfChapterId" runat="server"
                                             Value='<%# Eval("ChapterId") %>' />

                            <%-- Videos --%>
                            <asp:Repeater ID="rptVideos" runat="server">
                                <ItemTemplate>
                                    <div class="ci" id="vi_<%# Eval("VideoId") %>"
                                         onclick="selectVideo(
                                            <%# Eval("VideoId") %>,
                                            '<%# Server.HtmlEncode(Eval("Title")?.ToString()) %>',
                                            '<%# Server.HtmlEncode(Eval("Description")?.ToString() ?? "") %>',
                                            '<%# Server.HtmlEncode(Eval("InstructorName")?.ToString()) %>',
                                            '<%# Server.HtmlEncode(Eval("VideoPath")?.ToString()) %>',
                                            <%# Eval("ViewCount") ?? 0 %>,this)">
                                        <span class="ci-ico ci-v"><i class="fas fa-play"></i></span>
                                        <span style="flex:1"><%# Eval("Title") %></span>
                                        <span class="ci-done" id="vd_<%# Eval("VideoId") %>">
                                            <i class="fas fa-check-circle"></i>
                                        </span>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>

                            <%-- Materials --%>
                            <asp:Repeater ID="rptMaterials" runat="server">
                                <ItemTemplate>
                                    <div class="ci"
                                         onclick="selectMat(
                                            '<%# Server.HtmlEncode(Eval("Title")?.ToString()) %>',
                                            '<%# Server.HtmlEncode(Eval("FilePath")?.ToString()) %>',
                                            '<%# Server.HtmlEncode(Eval("FileType")?.ToString()) %>',
                                            this)">
                                        <span class="ci-ico ci-m"><i class="fas fa-file-alt"></i></span>
                                        <span style="flex:1"><%# Eval("Title") %></span>
                                        <span style="font-size:10px;color:var(--dim)">
                                            <%# Eval("FileType") %>
                                        </span>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>

                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>

        </div><%-- /ch-scroll --%>
    </div><%-- /ch-panel --%>

    <%-- ══════ RIGHT: CONTENT PANEL ══════ --%>
    <div class="content-panel">

        <%-- Default prompt --%>
        <div id="dPrompt" class="select-prompt">
            <i class="fas fa-hand-point-left"
               style="font-size:48px;color:#90caf9;display:block;margin-bottom:13px"></i>
            <h5 style="font-weight:700;color:#546e7a;margin-bottom:5px">
                Select a video or material</h5>
            <p>Click any item from the chapter list to start studying.</p>
        </div>

        <%-- ════ VIDEO VIEWER ════ --%>
        <div id="dVideo" style="display:none">

            <%-- Video card --%>
            <div class="vc">
                <div class="vp-wrap" id="vpWrap">
                    <%-- NOTE: no controls attribute — we use our own control bar --%>
                    <video id="vp" controlsList="nodownload" preload="metadata"
                           oncontextmenu="return false">
                        <source id="vpSrc" src="" type="video/mp4">
                        Your browser does not support HTML5 video.
                    </video>

                    <%-- Skip-lock overlay (first watch) --%>
                    <div class="ov ov-skip hidden" id="ovSkip">
                        <i class="fas fa-lock"
                           style="font-size:2rem;margin-bottom:9px;color:#90caf9"></i>
                        <h4>First Watch — Skipping Disabled</h4>
                        <p>Watch the full video once.
                           After that, you can freely skip, rewind, or re-watch.</p>
                    </div>

                    <%-- Engagement quiz overlay --%>
                    <div class="ov ov-engage" id="ovEngage">
                        <div class="engage-q" id="engQ"></div>
                        <div class="engage-opts" id="engOpts"></div>
                    </div>

                    <%-- Screenshot flash --%>
                    <div class="ss-flash" id="ssFlash"></div>
                </div>

                <%-- Live-caption bar (between video and controls) --%>
                <div class="cap-bar" id="capBar"></div>

                <%-- ——— CONTROL BAR — ALL type="button" ——— --%>
                <div class="ctrl-bar">
                    <button type="button" class="cb" onclick="vSkip(-10)"
                            title="Back 10 s">
                        <i class="fas fa-undo"></i><span> 10s</span>
                    </button>
                    <button type="button" class="cb" id="btnFwd" onclick="vSkip(10)"
                            title="Forward 10 s (unlocks after first full watch)" disabled>
                        <i class="fas fa-redo"></i><span> 10s</span>
                    </button>
                    <div class="cdiv"></div>

                    <select class="csel" title="Playback speed"
                            onchange="vp.playbackRate=parseFloat(this.value)">
                        <option value="0.5">0.5×</option>
                        <option value="0.75">0.75×</option>
                        <option value="1" selected>1×</option>
                        <option value="1.25">1.25×</option>
                        <option value="1.5">1.5×</option>
                        <option value="2">2×</option>
                    </select>

                    <select class="csel" title="Volume"
                            onchange="vp.volume=parseFloat(this.value)">
                        <option value="1" selected>🔊 100%</option>
                        <option value="0.75">🔉 75%</option>
                        <option value="0.5">🔉 50%</option>
                        <option value="0.25">🔈 25%</option>
                        <option value="0">🔇 Mute</option>
                    </select>
                    <div class="cdiv"></div>

                    <button type="button" class="cb" id="btnLoop"
                            onclick="toggleLoop(this)" title="Loop">
                        <i class="fas fa-sync-alt"></i><span> Loop</span>
                    </button>
                    <button type="button" class="cb" id="btnAuto"
                            onclick="toggleAuto(this)" title="Auto-next video">
                        <i class="fas fa-step-forward"></i><span> Auto</span>
                    </button>
                    <button type="button" class="cb" id="btnCC"
                            onclick="toggleCC(this)" title="Live captions">
                        <i class="fas fa-closed-captioning"></i><span> CC</span>
                    </button>
                    <div class="cdiv"></div>

                    <button type="button" class="cb" onclick="doShot()"
                            title="Screenshot">
                        <i class="fas fa-camera"></i><span> Shot</span>
                    </button>
                    <button type="button" class="cb" onclick="doPiP()"
                            title="Picture-in-picture">
                        <i class="fas fa-external-link-alt"></i><span> PiP</span>
                    </button>
                    <button type="button" class="cb" onclick="doFS()"
                            title="Fullscreen" style="margin-left:auto">
                        <i class="fas fa-expand"></i>
                    </button>
                </div>

                <%-- Video info --%>
                <div class="vinfo">
                    <h5 id="vTitle">—</h5>
                    <div class="vi-meta">
                        <span><i class="fas fa-user-tie me-1"></i>
                              <span id="vInstr">—</span></span>
                        <span><i class="fas fa-eye me-1"></i>
                              <span id="vViews">0</span> views</span>
                        <span><i class="fas fa-user-friends me-1"></i>
                              <span id="vUniq">0</span> students</span>
                        <%-- Rating --%>
                        <span id="ratingWrap" style="display:inline-flex;align-items:center;gap:4px">
                            <span class="star-row" id="starRow">
                                <span class="star" data-v="1"
                                      onmouseover="starHover(1)" onmouseout="starOut()"
                                      onclick="doRate(1)">★</span>
                                <span class="star" data-v="2"
                                      onmouseover="starHover(2)" onmouseout="starOut()"
                                      onclick="doRate(2)">★</span>
                                <span class="star" data-v="3"
                                      onmouseover="starHover(3)" onmouseout="starOut()"
                                      onclick="doRate(3)">★</span>
                                <span class="star" data-v="4"
                                      onmouseover="starHover(4)" onmouseout="starOut()"
                                      onclick="doRate(4)">★</span>
                                <span class="star" data-v="5"
                                      onmouseover="starHover(5)" onmouseout="starOut()"
                                      onclick="doRate(5)">★</span>
                            </span>
                            <span class="rating-info" id="ratingInfo"></span>
                        </span>
                    </div>
                    <div class="vi-desc" id="vDesc"></div>
                </div>

                <%-- Watch-progress bar --%>
                <div class="wp-strip">
                    <div class="wp-lbl">Your watch progress</div>
                    <div class="wp-bar">
                        <div class="wp-fill" id="wpFill" style="width:0%"></div>
                    </div>
                </div>

                <%-- Topics --%>
                <div class="topics-strip" id="topicsStrip" style="display:none">
                    <h6><i class="fas fa-list me-1"></i>Topics in this video</h6>
                    <div id="topicsList"></div>
                </div>
            </div><%-- /video card --%>

            <%-- ——— VIDEO TABS CARD ——— --%>
            <div class="vc">
                <div class="tabs" id="videoTabBar">
                    <button type="button" class="tab-btn on"
                            onclick="switchTab(this,'tAI','videoTabBar')">
                        <i class="fas fa-robot me-1"></i>AI</button>
                    <button type="button" class="tab-btn"
                            onclick="switchTab(this,'tComments','videoTabBar')">
                        <i class="fas fa-comments me-1"></i>Comments</button>
                    <button type="button" class="tab-btn"
                            onclick="switchTab(this,'tNotes','videoTabBar')">
                        <i class="fas fa-sticky-note me-1"></i>Notes</button>
                    <button type="button" class="tab-btn"
                            onclick="switchTab(this,'tProgress','videoTabBar')">
                        <i class="fas fa-chart-line me-1"></i>Progress</button>
                </div>

                <%-- AI TAB --%>
                <div class="tab-pane on" id="tAI">
                    <div class="ai-hdr">
                        <i class="fas fa-robot" style="font-size:17px"></i>
                        <h5>AI Study Assistant</h5>
                    </div>
                    <div class="ai-actions">
                        <button type="button" class="ai-btn" onclick="aiAct('summary')">
                            <i class="fas fa-file-alt"></i> Summary</button>
                        <button type="button" class="ai-btn" onclick="aiAct('notes')">
                            <i class="fas fa-sticky-note"></i> Notes</button>
                        <button type="button" class="ai-btn" onclick="aiAct('quiz')">
                            <i class="fas fa-question-circle"></i> Quiz</button>
                        <button type="button" class="ai-btn" onclick="aiAct('mindmap')">
                            <i class="fas fa-project-diagram"></i> Mind Map</button>
                    </div>
                    <div class="ai-ask-row">
                        <input type="text" id="aiInput"
                               placeholder="Ask a doubt about this video…"
                               onkeydown="if(event.key==='Enter'){
                                   event.preventDefault();askAI()}"/>
                        <button type="button" onclick="askAI()">
                            <i class="fas fa-paper-plane me-1"></i>Ask</button>
                    </div>
                    <div class="ai-result dim" id="aiResult">
                        Select an action or ask a question above…</div>
                    <div class="hist-toggle" onclick="toggleHist()">
                        <i class="fas fa-history"></i> AI History
                        <i class="fas fa-chevron-down" id="histChev"
                           style="margin-left:auto"></i>
                    </div>
                    <div class="hist-body" id="histBody">
                        <div id="histList" style="padding:4px 0"></div>
                    </div>
                </div>

                <%-- COMMENTS TAB --%>
                <div class="tab-pane" id="tComments" style="padding:14px">
                    <div class="cf-row">
                        <button type="button" class="cf-btn on"
                                onclick="filterCmt('all',this)">All</button>
                        <button type="button" class="cf-btn"
                                onclick="filterCmt('student',this)">Students</button>
                        <button type="button" class="cf-btn"
                                onclick="filterCmt('teacher',this)">Teachers</button>
                        <button type="button" class="cf-btn"
                                onclick="filterCmt('admin',this)">Admins</button>
                    </div>
                    <div class="cmt-input-row">
                        <textarea id="cmtTxt" placeholder="Write a comment…"></textarea>
                        <button type="button" class="post-btn" onclick="postCmt()">
                            <i class="fas fa-paper-plane"></i></button>
                    </div>
                    <div id="cmtList"></div>
                </div>

                <%-- NOTES TAB --%>
                <div class="tab-pane" id="tNotes">
                    <div class="n-tb">
                        <button type="button" class="nt" onclick="fmt('bold')"
                                title="Bold"><b>B</b></button>
                        <button type="button" class="nt" onclick="fmt('italic')"
                                title="Italic"><i>I</i></button>
                        <button type="button" class="nt" onclick="fmt('underline')"
                                title="Underline"><u>U</u></button>
                        <div class="nsep"></div>
                        <button type="button" class="nt"
                                onclick="fmt('insertUnorderedList')"
                                title="Bullet list">
                            <i class="fas fa-list-ul"></i></button>
                        <button type="button" class="nt"
                                onclick="fmt('insertOrderedList')"
                                title="Numbered list">
                            <i class="fas fa-list-ol"></i></button>
                        <div class="nsep"></div>
                        <button type="button" class="nt" onclick="insertTbl()"
                                title="Table">
                            <i class="fas fa-table"></i></button>
                        <button type="button" class="nt" onclick="insertImg()"
                                title="Image">
                            <i class="fas fa-image"></i></button>
                        <div class="nsep"></div>
                        <select class="csel" style="height:27px"
                                onchange="fmt('fontSize',this.value)">
                            <option value="2">Small</option>
                            <option value="3" selected>Normal</option>
                            <option value="4">Large</option>
                            <option value="5">Larger</option>
                        </select>
                        <input type="color" title="Text colour"
                               style="width:27px;height:27px;border:none;
                                      border-radius:5px;cursor:pointer;padding:2px"
                               onchange="fmt('foreColor',this.value)">
                        <div class="nsep"></div>
                        <button type="button" class="nt" onclick="clearNotes()"
                                title="Clear notes" style="color:var(--red)">
                            <i class="fas fa-trash"></i></button>
                    </div>
                    <div id="notesEd" class="n-ed" contenteditable="true"
                         oninput="onNoteInput()" spellcheck="true"></div>
                    <div class="n-footer">
                        <span class="n-st" id="nSt">No notes saved yet</span>
                        <button type="button" class="n-save-btn" onclick="saveNotes()">
                            <i class="fas fa-save me-1"></i>Save Notes</button>
                    </div>
                </div>

                <%-- PROGRESS TAB --%>
                <div class="tab-pane" id="tProgress" style="padding:14px">
                    <div id="progDetail"
                         style="font-size:13px;color:var(--muted)">
                        Select a video to see detailed progress.</div>
                </div>

            </div><%-- /video tabs card --%>

        </div><%-- /dVideo --%>

        <%-- ════ MATERIAL VIEWER ════ --%>
        <div id="dMat" style="display:none">

            <div class="mat-card">
                <div class="mat-hdr">
                    <i class="fas fa-file-alt"></i>
                    <span id="matTitle">Material</span>
                </div>
                <div id="matEmbedArea"></div>
                <div class="mat-fallback" id="matFallback">
                    <div class="mat-icon" id="matIcon"></div>
                    <div style="font-size:15px;font-weight:700;color:#263238;
                                margin-bottom:6px" id="matName"></div>
                    <div style="font-size:12px;color:var(--muted);margin-bottom:18px"
                         id="matMeta"></div>
                    <a id="matLink" href="#" target="_blank" class="mat-dl">
                        <i class="fas fa-external-link-alt"></i>&nbsp;Open / Download
                    </a>
                </div>
            </div>

            <%-- Material tabs (AI + Notes) --%>
            <div class="vc">
                <div class="tabs" id="matTabBar">
                    <button type="button" class="tab-btn on"
                            onclick="switchTab(this,'mAI','matTabBar')">
                        <i class="fas fa-robot me-1"></i>AI</button>
                    <button type="button" class="tab-btn"
                            onclick="switchTab(this,'mNotes','matTabBar')">
                        <i class="fas fa-sticky-note me-1"></i>Notes</button>
                </div>

                <%-- Material AI --%>
                <div class="tab-pane on" id="mAI">
                    <div class="ai-hdr ai-hdr-green">
                        <i class="fas fa-robot" style="font-size:17px"></i>
                        <h5>Material AI Assistant</h5>
                    </div>
                    <div class="ai-actions">
                        <button type="button" class="ai-btn" onclick="matAI('summary')">
                            <i class="fas fa-file-alt"></i> Summary</button>
                        <button type="button" class="ai-btn" onclick="matAI('notes')">
                            <i class="fas fa-sticky-note"></i> Notes</button>
                        <button type="button" class="ai-btn" onclick="matAI('quiz')">
                            <i class="fas fa-question-circle"></i> Quiz</button>
                        <button type="button" class="ai-btn" onclick="matAI('mindmap')">
                            <i class="fas fa-project-diagram"></i> Mind Map</button>
                    </div>
                    <div class="ai-ask-row">
                        <input type="text" id="matAiInput"
                               placeholder="Ask a question about this material…"
                               onkeydown="if(event.key==='Enter'){
                                   event.preventDefault();askMatAI()}"/>
                        <button type="button" onclick="askMatAI()">
                            <i class="fas fa-paper-plane me-1"></i>Ask</button>
                    </div>
                    <div class="ai-result dim" id="matAiRes">
                        Select an action or ask a question above…</div>
                </div>

                <%-- Material Notes --%>
                <div class="tab-pane" id="mNotes">
                    <div class="n-tb">
                        <button type="button" class="nt"
                                onclick="mFmt('bold')"><b>B</b></button>
                        <button type="button" class="nt"
                                onclick="mFmt('italic')"><i>I</i></button>
                        <button type="button" class="nt"
                                onclick="mFmt('underline')"><u>U</u></button>
                        <div class="nsep"></div>
                        <button type="button" class="nt"
                                onclick="mFmt('insertUnorderedList')">
                            <i class="fas fa-list-ul"></i></button>
                        <button type="button" class="nt"
                                onclick="mFmt('insertOrderedList')">
                            <i class="fas fa-list-ol"></i></button>
                        <div class="nsep"></div>
                        <button type="button" class="nt"
                                onclick="clearMatNotes()" style="color:var(--red)">
                            <i class="fas fa-trash"></i></button>
                    </div>
                    <div id="matNotesEd" class="n-ed" contenteditable="true"
                         oninput="onMatNoteInput()" spellcheck="true"></div>
                    <div class="n-footer">
                        <span class="n-st" id="mNSt">No notes saved</span>
                        <button type="button" class="n-save-btn" onclick="saveMatNotes()">
                            <i class="fas fa-save me-1"></i>Save</button>
                    </div>
                </div>

            </div><%-- /mat tabs card --%>

        </div><%-- /dMat --%>

    </div><%-- /content-panel --%>
</div><%-- /study-layout --%>

</asp:Panel>

<%-- ══════════════════════════════════════════════════════════════════════════
     JAVASCRIPT — zero-postback, fully synced with .aspx.cs
     All WebMethod calls → ajPost() → JSON.parse(raw) handles double-serialize
═══════════════════════════════════════════════════════════════════════════ --%>
<script>
    /* ─── GLOBALS ───────────────────────────────────────────────────────────── */
    const AI_URL = 'http://localhost:8000';
    const vp = document.getElementById('vp');

    // Current state
    let curVid = 0;       // current video id
    let curVName = '';      // video name (sent to AI server)
    let curMatPath = '';      // current material file path
    let completed = false;   // has student ever watched to 95%?
    let lastPos = 0;       // max position reached this session
    let myRating = 0;       // student's own rating for current video
    let autoNext = false;
    let ccOn = false;
    let cmtFilter = 'all';
    let captTopics = [];      // [{time, title}] for CC

    // Timers
    let progTimer = null;
    let notesTimer = null;
    let matNotesTimer = null;
    let engTimer = null;

    /* ─── SESSION HIDDEN FIELD READERS ─────────────────────────────────────── */
    const hfSess = () => document.getElementById('<%= hfSessionId.ClientID %>').value;
    const hfSubj = () => document.getElementById('<%= hfSubjectId.ClientID %>').value;

    /* ─── INIT ──────────────────────────────────────────────────────────────── */
    document.addEventListener('DOMContentLoaded', () => {
        loadOverallProgress();

        // Restore last watched video per subject
        const saved = localStorage.getItem('lv_' + hfSubj());
        if (saved) {
            try {
                const d = JSON.parse(saved);
                const el = document.getElementById('vi_' + d.id);
                if (el) el.click();
            } catch (_) { }
        }
    });

    /* ─── CHAPTER ACCORDION ────────────────────────────────────────────────── */
    function toggleCh(btn, bodyId) {
        const body = document.getElementById(bodyId);
        const wasOpen = body.classList.contains('open');
        // close all
        document.querySelectorAll('.ch-body').forEach(b => b.classList.remove('open'));
        document.querySelectorAll('.ch-toggle').forEach(b => b.classList.remove('open'));
        if (!wasOpen) {
            body.classList.add('open');
            btn.classList.add('open');
        }
    }

    /* ─── VIDEO SELECTION ───────────────────────────────────────────────────── */
    function selectVideo(vid, title, desc, instr, path, views, el) {
        // Mark active
        document.querySelectorAll('.ci').forEach(c => c.classList.remove('active'));
        el.classList.add('active');

        curVid = vid;
        curVName = title;

        // Switch panels
        $('dVideo'); $$('dMat'); $$('dPrompt');

        // Populate info
        setText('vTitle', title);
        setText('vInstr', instr || '—');
        setText('vDesc', desc || '');
        setText('vViews', views || '0');

        // ── Load video source (encode for special chars like spaces, #, etc.) ──
        const encodedPath = path.split('/').map(encodeURIComponent).join('/');
        document.getElementById('vpSrc').src = encodedPath;
        vp.load();

        // Remember last video for this subject
        localStorage.setItem('lv_' + hfSubj(),
            JSON.stringify({ id: vid, title, path }));

        // Trigger async UpdatePanel for topics (does NOT cause full postback)
        const hfT = document.getElementById('<%= hfTopicVideoId.ClientID %>');
    if (hfT) {
        hfT.value = String(vid);
        __doPostBack('<%= hfTopicVideoId.ClientID %>', '');
        }

        // ── Fetch saved status THEN seek and play ──
        ajPost('StudyMaterial.aspx/GetVideoStatus',
            { videoId: vid, sessionId: +hfSess() })
            .then(d => {
                completed = !!(d && d.IsCompleted);
                lastPos = (d && d.LastPosition) || 0;

                // Enable/disable skip-forward
                document.getElementById('btnFwd').disabled = !completed;

                // Show skip-lock banner briefly on first watch
                if (!completed) {
                    const ov = document.getElementById('ovSkip');
                    ov.classList.remove('hidden');
                    setTimeout(() => ov.classList.add('hidden'), 3500);
                }

                // Seek to resume position AFTER metadata is ready
                if (lastPos > 3) {
                    const seek = () => {
                        if (vp.readyState >= 1) {
                            vp.currentTime = lastPos;
                        } else {
                            vp.addEventListener('loadedmetadata', () => {
                                vp.currentTime = lastPos;
                            }, { once: true });
                        }
                    };
                    seek();
                }

                updateWpFill(lastPos, vp.duration || 0);
            })
            .catch(() => { completed = false; lastPos = 0; });

        // Track view after 10 s of playback
        let viewTracked = false;
        const trackFn = () => {
            if (!viewTracked && vp.currentTime > 10) {
                viewTracked = true;
                ajPost('StudyMaterial.aspx/TrackView',
                    { videoId: vid, sessionId: +hfSess() }).catch(() => { });
                vp.removeEventListener('timeupdate', trackFn);
            }
        };
        vp.addEventListener('timeupdate', trackFn);

        // Load supplementary data
        loadVStats(vid);
        loadRating(vid);
        loadComments(vid);
        loadNotes(vid);
        loadOverallProgress();
        startEngagement();
        startProgSave();

        vp.play().catch(() => { });
    }

    /* ─── VIDEO EVENTS ──────────────────────────────────────────────────────── */

    // Prevent seek forward on first watch
    vp.addEventListener('seeking', () => {
        if (!completed && vp.currentTime > lastPos + 1.5) {
            vp.currentTime = lastPos;
            flashSkipBanner();
        }
    });

    vp.addEventListener('timeupdate', () => {
        if (!vp.duration) return;
        const pct = (vp.currentTime / vp.duration) * 100;
        updateWpFill(vp.currentTime, vp.duration);

        // Update "Current Video" progress card
        setText('pCurrent', Math.round(pct) + '%');
        setText('pCurrentLbl', curVName || '—');
        setWidth('fCurrent', pct);

        // Update max position (for skip-lock)
        if (!completed && vp.currentTime > lastPos)
            lastPos = vp.currentTime;

        // Auto-complete at 95%
        if (pct >= 95 && !completed) {
            completed = true;
            document.getElementById('btnFwd').disabled = false;
            markComplete();
        }

        // Live captions
        if (ccOn) updateCC(vp.currentTime);
    });

    vp.addEventListener('ended', () => {
        markComplete();
        const d = document.getElementById('vd_' + curVid);
        if (d) d.classList.add('show');
        if (autoNext) playNext();
        loadOverallProgress();
        stopProgSave();
    });

    vp.addEventListener('pause', () => saveProgress());
    vp.addEventListener('play', () => { });

    function updateWpFill(pos, dur) {
        if (!dur) return;
        setWidth('wpFill', Math.min((pos / dur) * 100, 100));
    }

    function flashSkipBanner() {
        const ov = document.getElementById('ovSkip');
        ov.classList.remove('hidden');
        setTimeout(() => ov.classList.add('hidden'), 2200);
    }

    /* ─── PROGRESS SAVE (every 15 s) ────────────────────────────────────────── */
    function startProgSave() {
        stopProgSave();
        progTimer = setInterval(saveProgress, 15000);
    }
    function stopProgSave() { clearInterval(progTimer); }

    function saveProgress() {
        if (!curVid || !vp.duration) return;
        const pct = (vp.currentTime / vp.duration) * 100;
        ajPost('StudyMaterial.aspx/SaveProgress', {
            videoId: curVid,
            sessionId: +hfSess(),
            position: Math.floor(vp.currentTime),
            percentage: Math.round(pct),
            isCompleted: completed
        }).catch(() => { });
    }

    function markComplete() {
        if (!curVid) return;
        ajPost('StudyMaterial.aspx/MarkComplete',
            { videoId: curVid, sessionId: +hfSess() })
            .then(() => {
                const d = document.getElementById('vd_' + curVid);
                if (d) d.classList.add('show');
                loadOverallProgress();
            }).catch(() => { });
    }

    /* ─── VIDEO CONTROLS ─────────────────────────────────────────────────────── */
    function vSkip(sec) {
        if (sec > 0 && !completed) { flashSkipBanner(); return; }
        vp.currentTime = Math.max(0, vp.currentTime + sec);
    }

    function toggleLoop(btn) {
        vp.loop = !vp.loop;
        btn.classList.toggle('on', vp.loop);
        // Mutually exclusive with auto-next
        if (vp.loop) {
            autoNext = false;
            document.getElementById('btnAuto').classList.remove('on');
        }
    }

    function toggleAuto(btn) {
        autoNext = !autoNext;
        btn.classList.toggle('on', autoNext);
        // Mutually exclusive with loop
        if (autoNext) {
            vp.loop = false;
            document.getElementById('btnLoop').classList.remove('on');
        }
    }

    function toggleCC(btn) {
        ccOn = !ccOn;
        btn.classList.toggle('on', ccOn);
        const bar = document.getElementById('capBar');
        bar.classList.toggle('show', ccOn);
        if (!ccOn) bar.innerText = '';
    }

    function doPiP() {
        if (document.pictureInPictureElement) document.exitPictureInPicture();
        else vp.requestPictureInPicture().catch(() => alert('PiP not supported.'));
    }

    function doFS() {
        const w = document.getElementById('vpWrap');
        if (document.fullscreenElement) document.exitFullscreen();
        else w.requestFullscreen();
    }

    function doShot() {
        const c = document.createElement('canvas');
        c.width = vp.videoWidth; c.height = vp.videoHeight;
        c.getContext('2d').drawImage(vp, 0, 0);
        const fl = document.getElementById('ssFlash');
        fl.style.opacity = '.9';
        setTimeout(() => fl.style.opacity = '0', 120);
        const a = document.createElement('a');
        a.download = 'screenshot_' + Date.now() + '.png';
        a.href = c.toDataURL(); a.click();
    }

    /* ─── LIVE CAPTIONS ──────────────────────────────────────────────────────── */
    function updateCC(t) {
        const bar = document.getElementById('capBar');
        let cur = '';
        captTopics.forEach(tp => { if (t >= toSecs(tp.time)) cur = tp.title; });
        bar.innerText = cur;
    }
    function toSecs(s) {
        const p = (s || '').split(':').map(Number);
        return p.length === 3 ? p[0] * 3600 + p[1] * 60 + p[2]
            : p.length === 2 ? p[0] * 60 + p[1] : +p[0] || 0;
    }

    /* ─── TOPICS (UpdatePanel end-request callback) ──────────────────────────── */
    function renderTopics() {
        captTopics = [];
        const list = document.getElementById('topicsList');
        const strip = document.getElementById('topicsStrip');
        if (!list) return;
        list.innerHTML = '';
        document.querySelectorAll('.tdata').forEach(el => {
            const t = el.dataset.time, title = el.dataset.title;
            if (!t || !title) return;
            captTopics.push({ time: t, title });
            const div = document.createElement('div');
            div.className = 'topic-row';
            div.innerHTML =
                `<span class="ttm" onclick="jumpTo('${esc(t)}')">${esc(t)}</span>${esc(title)}`;
            list.appendChild(div);
        });
        strip.style.display = list.children.length ? 'block' : 'none';
    }
    if (typeof Sys !== 'undefined')
        Sys.WebForms.PageRequestManager.getInstance().add_endRequest(renderTopics);

    function jumpTo(ts) { vp.currentTime = toSecs(ts); vp.play(); }

    /* ─── ENGAGEMENT CHECK (every 2 min while playing) ──────────────────────── */
    const EQ = [
        {
            q: "Are you still watching?",
            o: ["Yes, I'm watching", "Checking phone", "Browsing other tabs", "Taking a break"], c: 0
        },
        {
            q: "Quick check — click 'Watching' to continue.",
            o: ["Watching", "Distracted", "Almost asleep", "Away from screen"], c: 0
        },
        {
            q: "Stay engaged! Pick the correct answer to resume.",
            o: ["I'm here and watching", "I walked away", "On my phone", "Sleeping"], c: 0
        }
    ];

    function startEngagement() {
        clearInterval(engTimer);
        engTimer = setInterval(() => {
            if (!vp.paused && !vp.ended) showEngagement();
        }, 120000); // 2 minutes
    }

    function showEngagement() {
        vp.pause();
        const q = EQ[Math.floor(Math.random() * EQ.length)];
        const ov = document.getElementById('ovEngage');
        const qEl = document.getElementById('engQ');
        const oEl = document.getElementById('engOpts');
        qEl.innerText = q.q;
        oEl.innerHTML = '';
        q.o.forEach((opt, i) => {
            const b = document.createElement('button');
            b.type = 'button';
            b.className = 'engage-opt';
            b.innerText = opt;
            b.onclick = () => {
                oEl.querySelectorAll('.engage-opt').forEach(x => x.onclick = null);
                if (i === q.c) {
                    b.classList.add('correct');
                    setTimeout(() => { ov.classList.remove('show'); vp.play(); }, 700);
                } else {
                    b.classList.add('wrong');
                    oEl.children[q.c]?.classList.add('correct');
                    setTimeout(() => { ov.classList.remove('show'); vp.play(); }, 1500);
                }
            };
            oEl.appendChild(b);
        });
        ov.classList.add('show');
    }

    /* ─── AUTO NEXT ─────────────────────────────────────────────────────────── */
    function playNext() {
        const all = [...document.querySelectorAll('.ci.ci-v')];
        const idx = all.findIndex(e => e.classList.contains('active'));
        if (idx >= 0 && idx < all.length - 1) all[idx + 1].click();
    }

    /* ─── VIDEO STATS ────────────────────────────────────────────────────────── */
    function loadVStats(vid) {
        ajPost('StudyMaterial.aspx/GetVideoStats',
            { videoId: vid, sessionId: +hfSess() })
            .then(d => {
                if (!d) return;
                setText('vViews', d.TotalViews || 0);
                setText('vUniq', d.UniqueStudents || 0);
            }).catch(() => { });
    }

    /* ─── RATING ─────────────────────────────────────────────────────────────── */
    function loadRating(vid) {
        ajPost('StudyMaterial.aspx/GetRating',
            { videoId: vid, sessionId: +hfSess() })
            .then(d => {
                if (!d) return;
                myRating = d.MyRating || 0;
                renderStars(myRating);
                document.getElementById('ratingInfo').innerText =
                    d.AvgRating
                        ? d.AvgRating.toFixed(1) + ' (' + d.TotalRatings + ' ratings)'
                        : 'No ratings yet';
            }).catch(() => { });
    }

    function renderStars(val) {
        document.querySelectorAll('#starRow .star').forEach(s => {
            s.classList.toggle('on', +s.dataset.v <= val);
        });
    }

    function starHover(v) {
        document.querySelectorAll('#starRow .star')
        .forEach(s => s.classList.toggle('hover', +s.dataset.v <= v));
    }
    function starOut() {
        document.querySelectorAll('#starRow .star')
        .forEach(s => s.classList.remove('hover')); renderStars(myRating);
    }

    function doRate(v) {
        if (!curVid) return;
        myRating = v;
        renderStars(v);
        ajPost('StudyMaterial.aspx/SaveRating',
            { videoId: curVid, sessionId: +hfSess(), rating: v })
            .then(() => loadRating(curVid))
            .catch(() => { });
    }

    /* ─── OVERALL PROGRESS ───────────────────────────────────────────────────── */
    function loadOverallProgress() {
        ajPost('StudyMaterial.aspx/GetProgress',
            { subjectId: +hfSubj(), sessionId: +hfSess() })
            .then(raw => {
                // GetProgress returns a JSON string (double-serialized)
                const d = typeof raw === 'string' ? JSON.parse(raw) : raw;
                if (!d || d.error) return;

                const pct = d.TotalCount > 0
                    ? Math.round(d.WatchedCount / d.TotalCount * 100) : 0;
                const spct = d.TotalChapters > 0
                    ? Math.round(d.CompletedChapters / d.TotalChapters * 100) : 0;

                setText('pOverall', pct + '%');
                setWidth('fOverall', pct);
                setText('pWatched', d.WatchedCount);
                setText('pWatchedSub', 'of ' + d.TotalCount + ' total');
                setText('pSyllabus', spct + '%');
                setWidth('fSyllabus', spct);

                // Chapter progress bars
                (d.ChapterProgress || []).forEach(cp => {
                    const bar = document.getElementById('cpb_' + cp.ChapterId);
                    const lbl = document.querySelector(
                        '.ch-pct-lbl[data-cid="' + cp.ChapterId + '"]');
                    if (bar) bar.style.width = cp.Pct + '%';
                    if (lbl) lbl.innerText = cp.Pct + '%';
                });

                // Completed video tick marks
                (d.CompletedVideoIds || []).forEach(id => {
                    const el = document.getElementById('vd_' + id);
                    if (el) el.classList.add('show');
                });
            }).catch(() => { });
    }

    function loadProgressDetail() {
        ajPost('StudyMaterial.aspx/GetProgress',
            { subjectId: +hfSubj(), sessionId: +hfSess() })
            .then(raw => {
                const d = typeof raw === 'string' ? JSON.parse(raw) : raw;
                if (!d || d.error) return;
                let h = `
        <div style="display:grid;grid-template-columns:1fr 1fr;gap:10px;margin-bottom:14px">
          <div class="prog-card">
            <div class="pc-lbl">Videos</div>
            <div class="pc-val">${d.WatchedCount}/${d.TotalCount}</div>
          </div>
          <div class="prog-card">
            <div class="pc-lbl">Chapters Done</div>
            <div class="pc-val">${d.CompletedChapters}/${d.TotalChapters}</div>
          </div>
        </div>
        <div style="font-size:10px;font-weight:700;text-transform:uppercase;
                    letter-spacing:.05em;color:var(--muted);margin-bottom:8px">
             Chapter Breakdown</div>`;
                (d.ChapterProgress || []).forEach(cp => {
                    h += `
            <div style="margin-bottom:9px">
              <div style="display:flex;justify-content:space-between;
                          font-size:13px;margin-bottom:3px">
                <span style="font-weight:600">${esc(cp.ChapterName)}</span>
                <span style="color:var(--muted)">
                    ${cp.WatchedVideos}/${cp.TotalVideos} videos</span>
              </div>
              <div class="prog-bar">
                <div class="prog-fill" style="width:${cp.Pct}%"></div>
              </div>
            </div>`;
                });
                setHtml('progDetail', h);
            }).catch(() => { });
    }

    /* ─── VIDEO AI ───────────────────────────────────────────────────────────── */
    function aiAct(type) {
        if (!curVName) { setAI('⚠ Select a video first.'); return; }
        const res = document.getElementById('aiResult');
        res.className = 'ai-result typing';
        res.innerText = 'Generating…';

        fetch(`${AI_URL}/generate-${type}`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ video_name: curVName })
        })
            .then(r => r.json())
            .then(d => {
                const txt = d.result || d.summary || d.notes || d.quiz || d.mindmap
                    || JSON.stringify(d);
                setAI(txt);
                saveAIHist(type + ': ' + curVName, txt);
            })
            .catch(() => setAI('⚠ AI server unavailable.\nRun: uvicorn ai_server:app --reload --port 8000'));
    }

    function askAI() {
        const q = document.getElementById('aiInput').value.trim();
        if (!q) return;
        if (!curVName) { setAI('⚠ Select a video first.'); return; }
        const res = document.getElementById('aiResult');
        res.className = 'ai-result typing';
        res.innerText = '';

        fetch(`${AI_URL}/ask-ai?video_name=${encodeURIComponent(curVName)}&question=${encodeURIComponent(q)}`)
            .then(r => {
                const reader = r.body.getReader();
                const dec = new TextDecoder();
                let txt = '';
                res.className = 'ai-result';
                (function pump() {
                    reader.read().then(({ done, value }) => {
                        if (done) { saveAIHist(q, txt); return; }
                        txt += dec.decode(value);
                        res.innerText = txt;
                        pump();
                    });
                })();
            })
            .catch(() => setAI('⚠ AI server unavailable.'));
    }

    function setAI(txt) {
        const r = document.getElementById('aiResult');
        r.className = 'ai-result';
        r.innerText = txt;
    }

    function saveAIHist(q, a) {
        if (!curVid) return;
        ajPost('StudyMaterial.aspx/SaveAIHistory',
            {
                videoId: curVid, sessionId: +hfSess(),
                question: q, answer: a
            }).catch(() => { });
    }

    function toggleHist() {
        const body = document.getElementById('histBody');
        const chev = document.getElementById('histChev');
        const open = body.classList.toggle('open');
        chev.className = open ? 'fas fa-chevron-up' : 'fas fa-chevron-down';
        if (open && curVid) {
            ajPost('StudyMaterial.aspx/GetAIHistory',
                { videoId: curVid, sessionId: +hfSess() })
                .then(raw => {
                    const d = typeof raw === 'string' ? JSON.parse(raw) : raw;
                    const el = document.getElementById('histList');
                    if (!Array.isArray(d) || !d.length) {
                        el.innerHTML =
                            '<div style="padding:8px 13px;font-size:12px;color:var(--dim)">No history yet.</div>';
                        return;
                    }
                    el.innerHTML = d.map(h => `
                <div class="hist-item">
                  <div class="hi-q">${esc(h.Question)}</div>
                  <div class="hi-a">
                    ${esc((h.Answer || '').substring(0, 200))}
                    ${(h.Answer || '').length > 200 ? '…' : ''}
                  </div>
                  <div class="hi-t">${h.CreatedOn}</div>
                </div>`).join('');
                }).catch(() => { });
        }
    }

    /* ─── COMMENTS ───────────────────────────────────────────────────────────── */
    function loadComments(vid) {
        const v = vid || curVid; if (!v) return;
        ajPost('StudyMaterial.aspx/GetComments',
            { videoId: v, sessionId: +hfSess() })
            .then(raw => {
                const d = typeof raw === 'string' ? JSON.parse(raw) : raw;
                renderCmts(Array.isArray(d) ? d : []);
            }).catch(() => { });
    }

    function renderCmts(data) {
        const list = document.getElementById('cmtList');
        const items = cmtFilter === 'all' ? data
            : data.filter(c => (c.Role || '').toLowerCase().includes(cmtFilter));
        if (!items.length) {
            list.innerHTML =
                '<div style="padding:12px;color:var(--dim);font-size:12px">No comments yet.</div>';
            return;
        }
        list.innerHTML = items.map(c => renderOneCmt(c)).join('');
    }

    function renderOneCmt(c) {
        const cls = { student: 'rl-s', teacher: 'rl-t', admin: 'rl-a' }[(c.Role || '').toLowerCase()] || 'rl-s';
        const av = c.Role === 'Teacher' ? '#2e7d32' : c.Role === 'Admin' ? '#c62828' : '#1565c0';
        const ini = (c.FullName || c.Username || '?').charAt(0).toUpperCase();
        const reps = c.Replies?.length
            ? `<div class="replies">${c.Replies.map(r => renderOneCmt(r)).join('')}</div>` : '';
        return `<div class="cmt" data-role="${(c.Role || '').toLowerCase()}">
      <div class="c-av" style="background:${av}">${ini}</div>
      <div style="flex:1;min-width:0">
        <span class="c-nm">${esc(c.FullName || c.Username)}</span>
        <span class="c-rl ${cls}">${c.Role || 'Student'}</span>
        <div class="c-tx">${esc(c.CommentText)}</div>
        <div class="c-mt">
          <span>${c.CreatedOn}</span>
          <button type="button" class="rb"
                  onclick="toggleReply(${c.CommentId})">
            <i class="fas fa-reply me-1"></i>Reply</button>
        </div>
        <div id="rbox_${c.CommentId}" style="display:none;margin-top:7px">
          <div class="cmt-input-row">
            <textarea id="rtxt_${c.CommentId}"
                      placeholder="Write a reply…" style="height:46px"></textarea>
            <button type="button" class="post-btn"
                    onclick="postReply(${c.CommentId})"
                    style="padding:7px 11px">
              <i class="fas fa-paper-plane"></i></button>
          </div>
        </div>
        ${reps}
      </div>
    </div>`;
    }

    function toggleReply(id) {
        const b = document.getElementById('rbox_' + id);
        if (b) b.style.display = b.style.display === 'none' ? 'block' : 'none';
    }

    function postCmt() {
        const txt = document.getElementById('cmtTxt').value.trim();
        if (!txt || !curVid) return;
        ajPost('StudyMaterial.aspx/PostComment',
            {
                videoId: curVid, sessionId: +hfSess(),
                commentText: txt, parentId: null
            })
            .then(() => { document.getElementById('cmtTxt').value = ''; loadComments(); })
            .catch(() => { });
    }

    function postReply(pid) {
        const txt = document.getElementById('rtxt_' + pid)?.value.trim();
        if (!txt || !curVid) return;
        ajPost('StudyMaterial.aspx/PostComment',
            {
                videoId: curVid, sessionId: +hfSess(),
                commentText: txt, parentId: pid
            })
            .then(() => loadComments()).catch(() => { });
    }

    function filterCmt(role, btn) {
        cmtFilter = role;
        document.querySelectorAll('.cf-btn').forEach(b => b.classList.remove('on'));
        btn.classList.add('on');
        loadComments();
    }

    /* ─── NOTES (video) ──────────────────────────────────────────────────────── */
    function loadNotes(vid) {
        ajPost('StudyMaterial.aspx/GetNotes',
            { videoId: vid, sessionId: +hfSess() })
            .then(raw => {
                const d = typeof raw === 'string' ? JSON.parse(raw) : raw;
                const ed = document.getElementById('notesEd');
                ed.innerHTML = (d && d.Content) || '';
                setText('nSt', d && d.Content
                    ? 'Last saved: ' + (d.UpdatedOn || '') : 'No notes saved yet');
            }).catch(() => { });
    }

    function saveNotes() {
        if (!curVid) return;
        ajPost('StudyMaterial.aspx/SaveNotes', {
            videoId: curVid,
            sessionId: +hfSess(),
            content: document.getElementById('notesEd').innerHTML
        })
            .then(() => setText('nSt', 'Saved at ' + new Date().toLocaleTimeString()))
            .catch(() => { });
    }

    function onNoteInput() {
        setText('nSt', 'Unsaved changes…');
        clearTimeout(notesTimer);
        notesTimer = setTimeout(saveNotes, 3000);
    }

    function fmt(cmd, val) {
        document.getElementById('notesEd').focus();
        document.execCommand(cmd, false, val || null);
    }

    function insertTbl() {
        const r = prompt('Rows:', '3'), c = prompt('Columns:', '3');
        if (!r || !c) return;
        let t = '<table border="1" style="border-collapse:collapse;width:100%;margin:7px 0">';
        for (let i = 0; i < +r; i++) {
            t += '<tr>';
            for (let j = 0; j < +c; j++)
                t += '<td style="padding:5px;border:1px solid #ccc">&nbsp;</td>';
            t += '</tr>';
        }
        t += '</table><br>';
        document.getElementById('notesEd').focus();
        document.execCommand('insertHTML', false, t);
    }

    function insertImg() {
        const u = prompt('Image URL:');
        if (u) {
            document.getElementById('notesEd').focus();
            document.execCommand('insertHTML', false,
                `<img src="${u}" style="max-width:100%;border-radius:7px;margin:7px 0">`);
        }
    }

    function clearNotes() {
        if (confirm('Clear all notes for this video?')) {
            document.getElementById('notesEd').innerHTML = '';
            onNoteInput();
        }
    }

    /* ─── MATERIAL SELECTION ─────────────────────────────────────────────────── */
    function selectMat(title, path, fileType, el) {
        document.querySelectorAll('.ci').forEach(c => c.classList.remove('active'));
        el.classList.add('active');
        curMatPath = path;

        $('dMat'); $$('dVideo'); $$('dPrompt');

        setText('matTitle', title);
        setText('matName', title);
        setText('matMeta', 'Type: ' + fileType);
        document.getElementById('matLink').href = path;

        const emb = document.getElementById('matEmbedArea');
        const fall = document.getElementById('matFallback');
        const ext = (fileType || '').toLowerCase().replace('.', '');

        emb.innerHTML = '';
        if (ext === 'pdf') {
            emb.innerHTML = `<iframe class="mat-embed-frame" src="${path}"></iframe>`;
            emb.style.display = 'block'; fall.style.display = 'none';
        } else if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'svg'].includes(ext)) {
            emb.innerHTML =
                `<div style="padding:18px;text-align:center">
               <img src="${path}"
                    style="max-width:100%;border-radius:8px;max-height:480px">
             </div>`;
            emb.style.display = 'block'; fall.style.display = 'none';
        } else if (['mp4', 'webm'].includes(ext)) {
            emb.innerHTML = `<video controls style="width:100%">
                           <source src="${path}"></video>`;
            emb.style.display = 'block'; fall.style.display = 'none';
        } else if (['doc', 'docx', 'ppt', 'pptx', 'xls', 'xlsx'].includes(ext)) {
            const full = window.location.origin + '/' + path.replace(/^\//, '');
            emb.innerHTML =
                `<iframe class="mat-embed-frame"
               src="https://docs.google.com/viewer?url=${encodeURIComponent(full)}&embedded=true">
             </iframe>`;
            emb.style.display = 'block'; fall.style.display = 'none';
        } else {
            emb.style.display = 'none'; fall.style.display = 'block';
        }

        // Icon
        const icons = {
            pdf: 'fa-file-pdf #c62828', doc: 'fa-file-word #1565c0',
            docx: 'fa-file-word #1565c0', ppt: 'fa-file-powerpoint #e65100',
            pptx: 'fa-file-powerpoint #e65100', xls: 'fa-file-excel #2e7d32',
            xlsx: 'fa-file-excel #2e7d32'
        };
        const iv = (icons[ext] || 'fa-file-alt #6a1b9a').split(' ');
        setHtml('matIcon',
            `<i class="fas ${iv[0]}" style="color:${iv[1]}"></i>`);

        // Reset material AI result
        const mr = document.getElementById('matAiRes');
        mr.className = 'ai-result dim';
        mr.innerText = 'Select an action or ask a question above…';

        loadMatNotes();
    }

    /* ─── MATERIAL AI ────────────────────────────────────────────────────────── */
    function matAI(type) {
        if (!curMatPath) { showMatAI('⚠ Select a material first.'); return; }
        const res = document.getElementById('matAiRes');
        res.className = 'ai-result typing';
        res.innerText = 'Generating…';
        fetch(`${AI_URL}/material-${type}`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ file_path: curMatPath })
        })
            .then(r => r.json())
            .then(d => showMatAI(d.result || d.error || JSON.stringify(d)))
            .catch(() => showMatAI('⚠ AI server unavailable.'));
    }

    function askMatAI() {
        const q = document.getElementById('matAiInput').value.trim();
        if (!q) return;
        if (!curMatPath) { showMatAI('⚠ Select a material first.'); return; }
        const res = document.getElementById('matAiRes');
        res.className = 'ai-result typing';
        res.innerText = 'Thinking…';
        fetch(`${AI_URL}/material-ask`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ file_path: curMatPath, question: q })
        })
            .then(r => r.json())
            .then(d => showMatAI(d.result || d.error || JSON.stringify(d)))
            .catch(() => showMatAI('⚠ AI server unavailable.'));
    }

    function showMatAI(txt) {
        const r = document.getElementById('matAiRes');
        r.className = 'ai-result';
        r.innerText = txt;
    }

    /* ─── MATERIAL NOTES (localStorage, path-keyed) ─────────────────────────── */
    function loadMatNotes() {
        const data = localStorage.getItem('mn_' + curMatPath);
        document.getElementById('matNotesEd').innerHTML = data || '';
        setText('mNSt', data ? 'Loaded' : 'No notes saved');
    }
    function saveMatNotes() {
        localStorage.setItem('mn_' + curMatPath,
            document.getElementById('matNotesEd').innerHTML);
        setText('mNSt', 'Saved at ' + new Date().toLocaleTimeString());
    }
    function onMatNoteInput() {
        setText('mNSt', 'Unsaved changes…');
        clearTimeout(matNotesTimer);
        matNotesTimer = setTimeout(saveMatNotes, 3000);
    }
    function mFmt(cmd) {
        document.getElementById('matNotesEd').focus();
        document.execCommand(cmd, false, null);
    }
    function clearMatNotes() {
        if (confirm('Clear material notes?')) {
            document.getElementById('matNotesEd').innerHTML = '';
            onMatNoteInput();
        }
    }

    /* ─── TABS ───────────────────────────────────────────────────────────────── */
    function switchTab(btn, paneId, barId) {
        const bar = document.getElementById(barId);
        if (!bar) return;
        bar.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('on'));
        // find all tab-pane siblings — they are in same parent .vc
        const card = btn.closest('.vc');
        if (card) card.querySelectorAll('.tab-pane').forEach(p => p.classList.remove('on'));
        btn.classList.add('on');
        const pane = document.getElementById(paneId);
        if (pane) pane.classList.add('on');

        // Side-effects
        if (paneId === 'tComments') loadComments();
        if (paneId === 'tNotes' && curVid) loadNotes(curVid);
        if (paneId === 'tProgress') loadProgressDetail();
    }

    /* ─── SMALL UTILITIES ────────────────────────────────────────────────────── */
    function $(id) { const e = document.getElementById(id); if (e) e.style.display = 'block'; }
    function $$(id) { const e = document.getElementById(id); if (e) e.style.display = 'none'; }
    function setText(id, v) { const e = document.getElementById(id); if (e) e.innerText = String(v ?? ''); }
    function setHtml(id, v) { const e = document.getElementById(id); if (e) e.innerHTML = v; }
    function setWidth(id, w) {
        const e = document.getElementById(id);
        if (e) e.style.width = Math.min(Math.max(+w || 0, 0), 100) + '%';
    }
    function esc(s) {
        return String(s || '')
            .replace(/&/g, '&amp;').replace(/</g, '&lt;')
            .replace(/>/g, '&gt;').replace(/"/g, '&quot;');
    }

    /*
     * ajPost — all WebMethods return JSON strings (not objects).
     * ASP.NET wraps them in {d: "..."}.
     * We unwrap .d, then parse the string if it is a string.
     */
    async function ajPost(url, data) {
        const r = await fetch(url, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(data)
        });
        const j = await r.json();
        // Unwrap ASP.NET wrapper
        const raw = (j && j.d !== undefined) ? j.d : j;
        // Parse string returned by serialised WebMethods
        if (typeof raw === 'string') {
            try { return JSON.parse(raw); } catch (_) { return raw; }
        }
        return raw;
    }
</script>

</asp:Content>


