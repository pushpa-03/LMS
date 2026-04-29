<%--<%@ Page Title="Admin Video Player" Language="C#" MasterPageFile="~/Admin/AdminMaster.master" AutoEventWireup="true" CodeBehind="VideoPlayer.aspx.cs" Inherits="LearningManagementSystem.Admin.VideoPlayer" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

    <style>
        :root { --primary: #6366f1; --bg: #f8fafc; --glass: rgba(255, 255, 255, 0.9); }
        body { background: var(--bg); font-family: 'Inter', sans-serif; color: #1e293b; }

        /* Modern Glass Cards */
        .glass-card { background: var(--glass); backdrop-filter: blur(10px); border-radius: 16px; border: 1px solid rgba(255,255,255,0.3); box-shadow: 0 10px 15px -3px rgba(0,0,0,0.1); margin-bottom: 20px; transition: 0.3s; }
        
        /* BACK BUTTON */
        .back-nav { display: flex; align-items: center; gap: 10px; margin-bottom: 15px; text-decoration: none; color: #64748b; font-weight: 600; transition: 0.2s; }
        .back-nav:hover { color: var(--primary); }

        /* VIDEO PLAYER & SKIP */
        .video-wrapper { position: relative; border-radius: 16px; overflow: hidden; background: #000; }
        .main-video { width: 100%; height: 450px; cursor: pointer; }

        .yt-skip { 
            position: absolute; top: 50%; transform: translateY(-50%); 
            width: 70px; height: 70px; border-radius: 50%; 
            background: rgba(0,0,0,0.5); color: white; 
            display: flex; flex-direction: column; justify-content: center; align-items: center; 
            cursor: pointer; opacity: 0; transition: .3s; z-index: 5; pointer-events: none;
        }
        .yt-left { left: 10%; } .yt-right { right: 10%; }
        .video-wrapper:hover .yt-skip { opacity: 1; pointer-events: auto; }
        .yt-skip i { font-size: 1.5rem; }
        .yt-skip span { font-size: 0.7rem; font-weight: bold; }

        .video-container.show-controls .yt-skip{
            opacity:1;
        }

        /* TOPICS TOGGLE */
        #topicSection { display: none; margin-top: 15px; padding: 15px; background: #f1f5f9; border-radius: 12px; }
        
        /* RATING */
        .star-active { color: #fbbf24; }
        .star-inactive { color: #cbd5e1; }
        /* Floating Settings */
        .video-overlay-controls { position: absolute; top: 15px; right: 15px; display: flex; gap: 10px; z-index: 10; }
        .control-btn { background: rgba(0,0,0,0.5); color: white; border: none; padding: 10px; border-radius: 50%; cursor: pointer; backdrop-filter: blur(4px); }
        .settings-dropdown { position: absolute; top: 60px; right: 15px; width: 220px; padding: 15px; display: none; z-index: 100; }

        /* YouTube Style Comments */
        .comment-header { font-size: 1.2rem; font-weight: 800; margin-bottom: 15px; display: flex; align-items: center; gap: 10px; }
        .comment-item { display: flex; gap: 15px; padding: 15px 0; border-bottom: 1px solid #f1f5f9; animation: fadeInUp 0.5s ease forwards; }
        .avatar { width: 40px; height: 40px; border-radius: 50%; background: var(--primary); color: white; display: flex; align-items: center; justify-content: center; font-weight: bold; }
        .comment-content b { font-size: 0.9rem; color: #334155; }
        .comment-actions { font-size: 0.75rem; color: #64748b; margin-top: 5px; display: flex; gap: 15px; cursor: pointer; }

        /* Toggle Switches */
        .switch { position: relative; display: inline-block; width: 40px; height: 20px; }
        .switch input { opacity: 0; width: 0; height: 0; }
        .slider { position: absolute; cursor: pointer; top: 0; left: 0; right: 0; bottom: 0; background-color: #cbd5e1; transition: .4s; border-radius: 20px; }
        .slider:before { position: absolute; content: ""; height: 14px; width: 14px; left: 3px; bottom: 3px; background-color: white; transition: .4s; border-radius: 50%; }
        input:checked + .slider { background-color: var(--primary); }
        input:checked + .slider:before { transform: translateX(20px); }

        /* Interactive Progress Bar */
        .progress-container { height: 8px; background: #e2e8f0; border-radius: 10px; overflow: hidden; margin-top: 10px; }
        .progress-fill { height: 100%; background: linear-gradient(90deg, #6366f1, #a855f7); width: 0%; transition: width 1s ease; }

        /* Playlist Highlight */
        .playlist-item { padding: 12px; display: flex; gap: 10px; cursor: pointer; border-radius: 12px; transition: 0.2s; }
        .playlist-item:hover { background: #f1f5f9; }
        .playlist-active { background: #eef2ff !important; border-left: 4px solid var(--primary); }

        @keyframes fadeInUp { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }
    </style>

    <div class="container-fluid py-4">
        <a href="javascript:history.back()" class="back-nav">
            <i class="fas fa-arrow-left"></i> Back to Dashboard
        </a>

        <div class="row">
            <div class="col-lg-8">
                <div class="video-wrapper">
                     <video id="videoPlayer" runat="server" controls width="100%" height="450" class="main-video"></video>
 
                     <div id="skipLeft" class="yt-skip yt-left">⏪ 10</div>
                     <div id="skipRight" class="yt-skip yt-right">10 ⏩</div>

                    <div class="video-overlay-controls">
                        <button type="button" class="control-btn" title="Screenshot" onclick="takeShot()"><i class="fas fa-camera"></i></button>
                        <button type="button" class="control-btn" title="Settings" onclick="$('#settingsPanel').fadeToggle()"><i class="fas fa-cog"></i></button>
                    </div>

                    <div id="settingsPanel" class="glass-card settings-dropdown">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <span><i class="fas fa-sync me-2"></i> Loop</span>
                            <label class="switch"><input type="checkbox" id="chkLoop"><span class="slider"></span></label>
                        </div>
                        <div class="d-flex justify-content-between align-items-center">
                            <span><i class="fas fa-forward-step me-2"></i> Auto Next</span>
                            <label class="switch"><input type="checkbox" id="chkAutoNext"><span class="slider"></span></label>
                        </div>
                    </div>
                </div>

                <div class="glass-card p-4 mt-3">
                    <h2 class="fw-bold mb-1" id="lblVideoTitle" runat="server"></h2>
                    <div class="d-flex justify-content-between align-items-center text-muted small">
                        <span><span id="liveViews" runat="server">0</span> views • <span id="lblUploadDate" runat="server"></span></span>
                        <div id="dynamicRating" runat="server"></div>
                    </div>
                    <hr />
                    <div id="descBox">
                        <p id="lblDesc" runat="server" class="mb-0 text-secondary" style="display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden;"></p>
                        <div id="topicSection">
                            <h6 class="fw-bold"><i class="fas fa-list-ul me-2"></i>Video Topics</h6>

                            <asp:Repeater ID="rptTopics" runat="server">
                                <ItemTemplate>
                                    <div>⏱ <%# Eval("StartTime") %> - <%# Eval("TopicTitle") %></div>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>
                        <button type="button" id="btnToggleDesc" class="btn btn-link p-0 small fw-bold mt-2">Show More</button>
                        
                    </div>
                </div>

                <div class="row g-3 mb-4">
                    <div class="col-md-4">
                        <div class="glass-card p-3 text-center">
                            <div class="text-muted small uppercase">Comments</div>
                            <h3 class="fw-bold text-primary" id="lblCommentsCount" runat="server">0</h3>
                        </div>
                    </div>
                    <div class="col-md-8">
                        <div class="glass-card p-3">
                            <div class="d-flex justify-content-between small mb-1">
                                <span>Overall Student Progress</span>
                                <span id="progressText" runat="server">0%</span>
                            </div>
                            <div class="progress-container"><div id="progressBar" runat="server" class="progress-fill"></div></div>
                        </div>
                    </div>
                </div>

                <div class="glass-card p-4">
                    <div class="comment-header"><i class="fas fa-comments"></i> Discussion</div>
                    <div class="d-flex gap-3 mb-4">
                        <div class="avatar">U</div>
                        <div class="flex-grow-1">
                            <input type="text" id="txtComment" class="form-control border-0 border-bottom rounded-0 px-0" placeholder="Add a public comment...">
                            <div class="d-flex justify-content-end mt-2">
                                <button type="button" class="btn btn-primary btn-sm rounded-pill px-4" onclick="postComment()">Comment</button>
                            </div>
                        </div>
                    </div>
                    <div id="commentContainer">
                    
                        <div class="card-glass mt-4 p-3">
                            <h5>Comments</h5>

                            <asp:Repeater ID="rptComments" runat="server">
                                <ItemTemplate>
                                    <div class="mb-2">
                                        <b><%# Eval("Username") %></b> : <%# Eval("Comment") %>
                                        <asp:Button runat="server"
                                            CommandArgument='<%# Eval("CommentId") %>'
                                            OnCommand="DeleteComment"
                                            CssClass="btn btn-sm btn-danger float-end"
                                            Text="Delete"/>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>
                        </div>
                </div>
            </div>

            <div class="col-lg-4">
                <div class="glass-card overflow-hidden">
                    <div class="p-3 bg-light fw-bold border-bottom d-flex justify-content-between">
                        <span>Course Playlist</span>
                        <span class="badge bg-primary rounded-pill">Admin View</span>
                    </div>
                    <div style="max-height: 400px; overflow-y: auto;">
                        <asp:Repeater ID="rptPlaylist" runat="server">
                            <ItemTemplate>
                                <div class='playlist-item <%# Convert.ToInt32(Eval("VideoId")) == VideoId ? "playlist-active" : "" %>' 
                                     onclick="window.location.href='VideoPlayer.aspx?VideoId=<%# Eval("VideoId") %>'">
                                    <div style="width:100px; height:60px; background:#e2e8f0; border-radius:8px; flex-shrink:0; position:relative;">
                                        <i class="fas fa-play position-absolute top-50 start-50 translate-middle text-muted"></i>
                                    </div>
                                    <div>
                                        <div class="small fw-bold text-dark"><%# Eval("Title") %></div>
                                        <div class="x-small text-muted"><%# DataBinder.Eval(Container.DataItem, "Duration") ?? "00:00" %></div>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </div>

                <div class="d-flex gap-2 mb-4">
                    <asp:LinkButton ID="btnPrev" runat="server" CssClass="btn btn-white border flex-fill rounded-pill shadow-sm" OnClick="btnPrev_Click"><i class="fas fa-chevron-left me-2"></i>Previous</asp:LinkButton>
                    <asp:LinkButton ID="btnNext" runat="server" CssClass="btn btn-primary flex-fill rounded-pill shadow-lg" OnClick="btnNext_Click">Next<i class="fas fa-chevron-right ms-2"></i></asp:LinkButton>
                </div>

                <div class="glass-card p-3">
                    <h6 class="fw-bold mb-3"><i class="fas fa-users me-2"></i>Student Engagement</h6>
                    <div id="engagementLive" runat="server">
                        </div>
                </div>
            </div>
        </div>
    </div>

    <script>

        const v = document.getElementById('<%= videoPlayer.ClientID %>');
        const vId = '<%= VideoId %>';

        /* Resume */
        window.onload = function () {
            let t = localStorage.getItem("video-" + vId);
            if (t) v.currentTime = t;
        }

        /* Save */
        v.ontimeupdate = function () {
            localStorage.setItem("video-" + vId, v.currentTime);
        }

        // Skip logic
        $('#skipLeft').click(() => { v.currentTime -= 10; });
        $('#skipRight').click(() => { v.currentTime += 10; });

        // Show More/Less Logic
        $('#btnToggleDesc').click(function () {
            const isHidden = $('#topicSection').is(':hidden');
            if (isHidden) {
                $('#topicSection').slideDown();
                $(this).text('Show Less');
            } else {
                $('#topicSection').slideUp();
                $(this).text('Show More');
            }
        });

        /* Controls */
        v.onclick = () => {
            document.querySelector(".video-wrapper").classList.add("show-controls");
            setTimeout(() => document.querySelector(".video-wrapper").classList.remove("show-controls"), 1500);
        }

        // 1. SYNCED CONTROLS (Loop vs Auto-Next)
        const chkLoop = document.getElementById('chkLoop');
        const chkAutoNext = document.getElementById('chkAutoNext');

        chkLoop.onchange = function () {
            if (this.checked) { chkAutoNext.checked = false; v.loop = true; }
            else { v.loop = false; }
        };

        chkAutoNext.onchange = function () {
            if (this.checked) { chkLoop.checked = false; v.loop = false; }
        };

        v.onended = () => { if (chkAutoNext.checked) $('#<%= btnNext.ClientID %>')[0].click(); };

        // 2. AJAX LIVE COMMENTS
        function postComment() {
            let msg = $('#txtComment').val();
            if (!msg) return;
            $.ajax({
                type: "POST",
                url: "VideoPlayer.aspx/AddComment",
                data: JSON.stringify({ vid: vId, msg: msg }),
                contentType: "application/json; charset=utf-8",
                success: function () { $('#txtComment').val(''); loadComments(); }
            });
        }

        function loadComments() {
            $.ajax({
                type: "POST",
                url: "VideoPlayer.aspx/GetComments",
                data: JSON.stringify({ vid: vId }),
                contentType: "application/json; charset=utf-8",
                success: function (r) {
                    let data = JSON.parse(r.d);
                    let h = '';
                    data.forEach(c => {
                        h += `<div class="comment-item">
                                <div class="avatar">${c.Username.charAt(0)}</div>
                                <div class="comment-content">
                                    <b>${c.Username}</b> <span class="text-muted ms-2 small">Just now</span>
                                    <div class="mt-1">${c.Comment}</div>
                                    <div class="comment-actions"><span><i class="far fa-thumbs-up"></i> Like</span> <span>REPLY</span></div>
                                </div>
                              </div>`;
                    });
                    $('#commentContainer').html(h);
                    $('#<%= lblCommentsCount.ClientID %>').text(data.length);
                }
            });
        }

        function takeShot() {
            let c = document.createElement("canvas");
            c.width = v.videoWidth; c.height = v.videoHeight;
            c.getContext("2d").drawImage(v, 0, 0);
            let a = document.createElement("a");
            a.href = c.toDataURL(); a.download = "Capture.png"; a.click();
        }

        $(document).ready(loadComments);
    </script>
</asp:Content>

--%>


<%-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------%>


<%@ Page Title="Video Player" Language="C#" MasterPageFile="~/Admin/AdminMaster.master"
    AutoEventWireup="true" CodeBehind="VideoPlayer.aspx.cs"
    Inherits="LearningManagementSystem.Admin.VideoPlayer" %>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">
<link href="https://fonts.googleapis.com/css2?family=Syne:wght@400;600;700;800&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">

<style>
:root {
    --ink:#0d0f1a; --ink-soft:#4a4f6a; --surface:#f5f6fa; --card-bg:#fff;
    --border:#e4e7f0; --accent:#4f46e5; --accent-2:#7c3aed;
    --success:#059669; --danger:#dc2626; --warn:#d97706;
    --radius:14px; --shadow:0 4px 24px rgba(13,15,26,.07);
    --shadow-lg:0 12px 48px rgba(13,15,26,.13);
}
* { box-sizing:border-box; }
body { font-family:'DM Sans',sans-serif; background:var(--surface); color:var(--ink); }

/* ── BACK ── */
.back-bar { display:flex; align-items:center; gap:12px; margin-bottom:18px; }
.btn-back { display:inline-flex; align-items:center; gap:7px; background:var(--card-bg); border:1px solid var(--border); border-radius:10px; padding:8px 16px; font-size:.84rem; font-weight:600; color:var(--ink-soft); text-decoration:none; transition:.2s; }
.btn-back:hover { border-color:var(--accent); color:var(--accent); }
.back-bar h2 { font-family:'Syne',sans-serif; font-weight:800; font-size:1.25rem; flex:1; overflow:hidden; white-space:nowrap; text-overflow:ellipsis; }

/* ── MAIN LAYOUT ── */
.vp-layout { display:grid; grid-template-columns:1fr 340px; gap:20px; }
@media(max-width:1000px){ .vp-layout{grid-template-columns:1fr;} }

/* ── VIDEO WRAPPER ── */
.video-wrap { background:#000; border-radius:var(--radius); overflow:hidden; position:relative; aspect-ratio:16/9; }
video { width:100%; height:100%; display:block; background:#000; }

/* Skip overlays */
.skip-zone {
    position:absolute; top:0; bottom:0; width:30%;
    display:flex; align-items:center; justify-content:center;
    opacity:0; transition:opacity .2s; cursor:pointer;
    font-size:2rem; color:#fff;
}
.skip-zone.left  { left:0;  background:linear-gradient(90deg,rgba(0,0,0,.35),transparent); }
.skip-zone.right { right:0; background:linear-gradient(270deg,rgba(0,0,0,.35),transparent); }
.video-wrap:hover .skip-zone { opacity:1; }
.skip-label { display:flex; flex-direction:column; align-items:center; font-size:.7rem; font-weight:700; letter-spacing:.05em; }

/* Floating controls top-right */
.vid-controls { position:absolute; top:12px; right:12px; display:flex; gap:8px; z-index:10; }
.vid-ctrl-btn { background:rgba(0,0,0,.55); backdrop-filter:blur(6px); color:#fff; border:none; border-radius:8px; padding:7px 11px; font-size:.8rem; cursor:pointer; transition:.2s; display:flex; align-items:center; gap:5px; }
.vid-ctrl-btn:hover { background:rgba(0,0,0,.8); }

/* Settings panel */
.settings-panel {
    position:absolute; top:48px; right:12px; width:230px;
    background:var(--card-bg); border:1px solid var(--border);
    border-radius:var(--radius); box-shadow:var(--shadow-lg);
    padding:16px; z-index:20; display:none;
}
.settings-row { display:flex; justify-content:space-between; align-items:center; margin-bottom:12px; font-size:.83rem; font-weight:500; }
.settings-row:last-child { margin-bottom:0; }
.toggle-sw { position:relative; width:38px; height:20px; }
.toggle-sw input { opacity:0; width:0; height:0; }
.toggle-track { position:absolute; inset:0; background:#cbd5e1; border-radius:20px; cursor:pointer; transition:.3s; }
.toggle-track:before { content:''; position:absolute; height:14px; width:14px; left:3px; top:3px; background:#fff; border-radius:50%; transition:.3s; }
input:checked + .toggle-track { background:var(--accent); }
input:checked + .toggle-track:before { transform:translateX(18px); }

/* Speed selector */
.speed-btns { display:flex; gap:4px; }
.speed-btn { background:var(--surface); border:1px solid var(--border); border-radius:6px; padding:3px 8px; font-size:.76rem; font-weight:600; cursor:pointer; transition:.2s; }
.speed-btn.active, .speed-btn:hover { background:var(--accent); color:#fff; border-color:var(--accent); }

/* ── INFO CARD ── */
.vid-info { background:var(--card-bg); border-radius:var(--radius); border:1px solid var(--border); padding:20px; box-shadow:var(--shadow); margin-top:14px; }
.vid-title { font-family:'Syne',sans-serif; font-weight:800; font-size:1.2rem; }
.vid-meta-row { display:flex; justify-content:space-between; align-items:center; margin-top:8px; flex-wrap:wrap; gap:8px; }
.vid-meta-left { display:flex; gap:14px; font-size:.82rem; color:var(--ink-soft); align-items:center; }
.star-filled { color:#fbbf24; }
.star-empty  { color:#d1d5db; }

/* Tags / topics toggle */
.topics-strip { background:var(--surface); border:1px solid var(--border); border-radius:10px; padding:14px; margin-top:14px; }
.topic-item { display:flex; align-items:center; gap:10px; padding:6px 0; border-bottom:1px solid var(--border); cursor:pointer; transition:.15s; font-size:.83rem; }
.topic-item:last-child { border-bottom:none; }
.topic-item:hover { color:var(--accent); }
.topic-time { font-family:'Syne',sans-serif; font-weight:700; font-size:.75rem; background:#eef2ff; color:var(--accent); border-radius:6px; padding:2px 8px; min-width:50px; text-align:center; flex-shrink:0; }

/* ── STATS ROW ── */
.vid-stats { display:grid; grid-template-columns:repeat(4,1fr); gap:10px; margin-top:14px; }
@media(max-width:640px){ .vid-stats{grid-template-columns:repeat(2,1fr);} }
.stat-box { background:var(--card-bg); border:1px solid var(--border); border-radius:12px; padding:14px; text-align:center; box-shadow:var(--shadow); }
.stat-val { font-family:'Syne',sans-serif; font-size:1.5rem; font-weight:800; }
.stat-lbl { font-size:.7rem; font-weight:700; text-transform:uppercase; letter-spacing:.05em; color:var(--ink-soft); margin-top:2px; }

/* ── STUDENT RESTRICTION NOTICE (first-watch lock) ── */
.first-watch-notice { background:#fffbeb; border:1px solid #fde68a; border-radius:10px; padding:10px 14px; font-size:.82rem; color:#92400e; display:flex; align-items:center; gap:8px; margin-top:10px; }

/* ── COMMENTS ── */
.comment-section { background:var(--card-bg); border:1px solid var(--border); border-radius:var(--radius); padding:20px; box-shadow:var(--shadow); margin-top:14px; }
.comment-section h5 { font-family:'Syne',sans-serif; font-weight:700; margin-bottom:16px; }
.comment-input-row { display:flex; gap:10px; margin-bottom:20px; }
.cmt-avatar { width:38px; height:38px; border-radius:50%; background:var(--accent); color:#fff; display:flex; align-items:center; justify-content:center; font-weight:700; font-size:.85rem; flex-shrink:0; }
.cmt-input { flex:1; border:1px solid var(--border); border-radius:10px; padding:9px 14px; font-size:.85rem; font-family:'DM Sans',sans-serif; transition:.2s; resize:none; color:var(--ink); }
.cmt-input:focus { border-color:var(--accent); outline:none; box-shadow:0 0 0 3px rgba(79,70,229,.1); }
.btn-send { background:var(--accent); color:#fff; border:none; border-radius:10px; padding:9px 18px; font-weight:700; cursor:pointer; font-size:.83rem; white-space:nowrap; }
.cmt-item { display:flex; gap:12px; padding:12px 0; border-bottom:1px solid var(--border); animation:fadeUp .3s ease; }
.cmt-item:last-child { border-bottom:none; }
.cmt-body strong { font-size:.85rem; }
.cmt-body p { font-size:.82rem; color:#374151; margin:3px 0 0; }
.cmt-time { font-size:.72rem; color:var(--ink-soft); margin-top:4px; }
.cmt-del { background:none; border:none; color:var(--danger); cursor:pointer; font-size:.75rem; margin-left:auto; opacity:.6; transition:.2s; }
.cmt-del:hover { opacity:1; }
@keyframes fadeUp { from{opacity:0;transform:translateY(8px)} to{opacity:1;transform:translateY(0)} }

/* ── RIGHT PANEL ── */
.right-panel { display:flex; flex-direction:column; gap:14px; }

/* Playlist */
.playlist-card { background:var(--card-bg); border:1px solid var(--border); border-radius:var(--radius); box-shadow:var(--shadow); overflow:hidden; }
.playlist-header { padding:14px 16px; border-bottom:1px solid var(--border); display:flex; justify-content:space-between; align-items:center; }
.playlist-header h6 { font-family:'Syne',sans-serif; font-weight:700; margin:0; }
.playlist-list { max-height:340px; overflow-y:auto; }
.pl-item { display:flex; gap:10px; padding:10px 14px; cursor:pointer; border-bottom:1px solid var(--border); transition:.2s; }
.pl-item:hover { background:var(--surface); }
.pl-item.active { background:#eef2ff; border-left:3px solid var(--accent); }
.pl-thumb { width:72px; height:42px; background:#1e1b4b; border-radius:6px; flex-shrink:0; display:flex; align-items:center; justify-content:center; color:#fff; font-size:.8rem; }
.pl-meta strong { font-size:.8rem; display:block; line-height:1.3; color:var(--ink); }
.pl-meta span { font-size:.72rem; color:var(--ink-soft); }

/* Nav buttons */
.nav-btns { display:grid; grid-template-columns:1fr 1fr; gap:8px; }
.btn-nav { border:1px solid var(--border); border-radius:10px; padding:9px; font-size:.82rem; font-weight:700; cursor:pointer; transition:.2s; display:flex; align-items:center; justify-content:center; gap:6px; text-decoration:none; }
.btn-nav.prev { background:var(--card-bg); color:var(--ink); }
.btn-nav.next { background:var(--accent); color:#fff; border-color:var(--accent); }
.btn-nav:hover { opacity:.88; }
.btn-nav:disabled, .btn-nav[disabled] { opacity:.4; pointer-events:none; }

/* Engagement card */
.engagement-card { background:var(--card-bg); border:1px solid var(--border); border-radius:var(--radius); box-shadow:var(--shadow); overflow:hidden; }
.engagement-header { padding:13px 16px; border-bottom:1px solid var(--border); font-family:'Syne',sans-serif; font-weight:700; font-size:.88rem; display:flex; justify-content:space-between; }
.eng-row { display:flex; align-items:center; gap:10px; padding:9px 14px; border-bottom:1px solid var(--border); font-size:.8rem; }
.eng-row:last-child { border-bottom:none; }
.eng-name { flex:1; font-weight:500; }
.progress-pill { background:var(--surface); border-radius:20px; height:6px; width:70px; overflow:hidden; flex-shrink:0; }
.progress-fill { height:100%; background:linear-gradient(90deg,var(--accent),var(--accent-2)); border-radius:20px; }
.eng-pct { font-weight:700; font-size:.75rem; color:var(--accent); min-width:30px; text-align:right; }

/* AI usage card */
.ai-card { background:linear-gradient(135deg,#1e1b4b,#312e81); color:#fff; border-radius:var(--radius); padding:16px; box-shadow:var(--shadow-lg); }
.ai-card h6 { font-family:'Syne',sans-serif; font-weight:700; margin-bottom:12px; }
.ai-stat-row { display:flex; justify-content:space-between; font-size:.8rem; padding:5px 0; border-bottom:1px solid rgba(255,255,255,.1); }
.ai-stat-row:last-child { border-bottom:none; }

/* Rating card */
.rating-card { background:var(--card-bg); border:1px solid var(--border); border-radius:var(--radius); padding:16px; box-shadow:var(--shadow); }
.rating-card h6 { font-family:'Syne',sans-serif; font-weight:700; margin-bottom:10px; }
.big-rating { font-family:'Syne',sans-serif; font-size:3rem; font-weight:800; color:var(--ink); line-height:1; }
.rating-count { font-size:.78rem; color:var(--ink-soft); margin-top:4px; }

/* Toast */
#toast-wrap { position:fixed; bottom:24px; right:24px; z-index:9999; display:flex; flex-direction:column; gap:8px; }
.toast-msg { border-radius:12px; padding:11px 18px; font-size:.83rem; font-weight:500; box-shadow:var(--shadow-lg); animation:slideIn .3s; color:#fff; max-width:320px; }
.toast-msg.success { background:#059669; }
.toast-msg.danger  { background:#dc2626; }
@keyframes slideIn { from{opacity:0;transform:translateX(40px)} to{opacity:1;transform:translateX(0)} }

/* Alert */
.alert-auto { border-radius:10px; font-size:.85rem; padding:10px 16px; }
</style>

<!-- BACK BAR -->
<div class="back-bar">
    <a href="javascript:history.back()" class="btn-back"><i class="fa fa-arrow-left"></i> Back</a>
    <h2 id="pageTitle" runat="server"></h2>
</div>

<asp:Label ID="lblMsg" runat="server" CssClass="alert alert-danger alert-auto d-block mb-3" Visible="false"></asp:Label>

<div class="vp-layout">

    <!-- ═══════ LEFT: Video + Info + Comments ═══════ -->
    <div>
        <!-- VIDEO -->
        <div class="video-wrap" id="videoContainer">
            <video id="videoPlayer" runat="server" controls preload="metadata"></video>

            <div class="skip-zone left" onclick="seekVideo(-10)" title="Back 10s">
                <div class="skip-label"><i class="fa fa-backward"></i><span>10s</span></div>
            </div>
            <div class="skip-zone right" onclick="seekVideo(10)" title="Forward 10s">
                <div class="skip-label"><i class="fa fa-forward"></i><span>10s</span></div>
            </div>

            <!-- Floating controls -->
            <div class="vid-controls">
                <button class="vid-ctrl-btn" onclick="takeScreenshot()" title="Screenshot"><i class="fa fa-camera"></i></button>
                <button class="vid-ctrl-btn" onclick="toggleSettings()" title="Settings"><i class="fa fa-cog"></i></button>
            </div>

            <!-- Settings panel -->
            <div class="settings-panel" id="settingsPanel">
                <div class="settings-row">
                    <span><i class="fa fa-sync me-2"></i>Loop</span>
                    <label class="toggle-sw"><input type="checkbox" id="chkLoop" onchange="onLoopChange()"><span class="toggle-track"></span></label>
                </div>
                <div class="settings-row">
                    <span><i class="fa fa-forward me-2"></i>Auto Next</span>
                    <label class="toggle-sw"><input type="checkbox" id="chkAutoNext" onchange="onAutoNextChange()"><span class="toggle-track"></span></label>
                </div>
                <div class="settings-row" style="flex-direction:column;align-items:flex-start;gap:8px">
                    <span><i class="fa fa-tachometer-alt me-2"></i>Playback Speed</span>
                    <div class="speed-btns">
                        <button class="speed-btn" onclick="setSpeed(0.5)">0.5×</button>
                        <button class="speed-btn" onclick="setSpeed(1)">1×</button>
                        <button class="speed-btn active" onclick="setSpeed(1.25)">1.25×</button>
                        <button class="speed-btn" onclick="setSpeed(1.5)">1.5×</button>
                        <button class="speed-btn" onclick="setSpeed(2)">2×</button>
                    </div>
                </div>
            </div>
        </div>

        <!-- FIRST-WATCH LOCK NOTICE (admin info) -->
        <div class="first-watch-notice">
            <i class="fa fa-lock me-1"></i>
            <strong>Student restriction active:</strong>&nbsp;Students cannot skip this video on first watch. Seeking is unlocked after 100% completion.
        </div>

        <!-- VIDEO INFO -->
        <div class="vid-info">
            <div class="vid-title" id="lblVideoTitle" runat="server">Loading…</div>
            <div class="vid-meta-row">
                <div class="vid-meta-left">
                    <span><i class="fa fa-eye me-1"></i><span id="liveViews" runat="server">0</span> views</span>
                    <span><i class="fa fa-user me-1"></i><span id="lblInstructor" runat="server"></span></span>
                    <span><i class="fa fa-calendar me-1"></i><span id="lblUploadDate" runat="server"></span></span>
                </div>
                <div id="starRating" runat="server"></div>
            </div>

            <!-- Show More / Topics -->
            <div id="descBox" style="margin-top:12px">
                <p id="lblDesc" runat="server" style="font-size:.88rem;color:var(--ink-soft);margin:0"></p>
                <button id="btnToggleTopics" onclick="toggleTopics()" style="background:none;border:none;color:var(--accent);font-weight:700;font-size:.82rem;cursor:pointer;padding:6px 0;margin-top:6px">
                    <i class="fa fa-list-ul me-1"></i>Show Topics
                </button>
            </div>

            <div class="topics-strip" id="topicsStrip" style="display:none">
                <asp:Repeater ID="rptTopics" runat="server">
                    <ItemTemplate>
                        <div class="topic-item" onclick="jumpToTime('<%# Eval("StartTime") %>')">
                            <span class="topic-time"><%# Eval("StartTime") %></span>
                            <span><%# Eval("TopicTitle") %></span>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>

        <!-- STATS ROW -->
        <div class="vid-stats">
            <div class="stat-box">
                <div class="stat-val" id="statViews" runat="server">—</div>
                <div class="stat-lbl">Views</div>
            </div>
            <div class="stat-box">
                <div class="stat-val" id="statStudents" runat="server">—</div>
                <div class="stat-lbl">Unique Students</div>
            </div>
            <div class="stat-box">
                <div class="stat-val" id="statCompletion" runat="server">—</div>
                <div class="stat-lbl">Avg Completion</div>
            </div>
            <div class="stat-box">
                <div class="stat-val" id="statComments" runat="server">—</div>
                <div class="stat-lbl">Comments</div>
            </div>
        </div>

        <!-- COMMENTS -->
        <div class="comment-section">
            <h5><i class="fa fa-comments me-2" style="color:var(--accent)"></i>Discussion
                <span id="commentCountBadge" style="font-size:.78rem;font-weight:600;color:var(--ink-soft);margin-left:8px"></span>
            </h5>
            <div class="comment-input-row">
                <div class="cmt-avatar" id="adminInitial" runat="server">A</div>
                <textarea id="txtComment" class="cmt-input" rows="2" placeholder="Add a comment…"></textarea>
                <button class="btn-send" onclick="postComment()"><i class="fa fa-paper-plane"></i></button>
            </div>
            <div id="commentsList"></div>
        </div>
    </div>

    <!-- ═══════ RIGHT PANEL ═══════ -->
    <div class="right-panel">

        <!-- PLAYLIST -->
        <div class="playlist-card">
            <div class="playlist-header">
                <h6><i class="fa fa-list me-2"></i>Playlist</h6>
                <span class="badge" style="background:#eef2ff;color:var(--accent);border-radius:8px;padding:3px 10px;font-size:.74rem;font-weight:700">Admin View</span>
            </div>
            <div class="playlist-list">
                <asp:Repeater ID="rptPlaylist" runat="server">
                    <ItemTemplate>
                        <div class='pl-item <%# Convert.ToInt32(Eval("VideoId")) == VideoId ? "active" : "" %>'
                             onclick="window.location='VideoPlayer.aspx?VideoId=<%# Eval("VideoId") %>'">
                            <div class="pl-thumb"><i class="fa fa-play"></i></div>
                            <div class="pl-meta">
                                <strong><%# Server.HtmlEncode(Eval("Title").ToString()) %></strong>
                                <span><i class="fa fa-eye me-1"></i><%# Eval("ViewCount") %> views</span>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>

        <!-- NAV BUTTONS -->
        <div class="nav-btns">
            <asp:LinkButton ID="btnPrev" runat="server" CssClass="btn-nav prev" OnClick="btnPrev_Click">
                <i class="fa fa-chevron-left"></i> Previous
            </asp:LinkButton>
            <asp:LinkButton ID="btnNext" runat="server" CssClass="btn-nav next" OnClick="btnNext_Click">
                Next <i class="fa fa-chevron-right"></i>
            </asp:LinkButton>
        </div>

        <!-- INSTRUCTOR RATING -->
        <div class="rating-card">
            <h6><i class="fa fa-star me-2" style="color:#fbbf24"></i>Instructor Rating</h6>
            <div class="big-rating" id="avgRatingVal" runat="server">—</div>
            <div id="ratingStars" runat="server"></div>
            <div class="rating-count" id="ratingCount" runat="server"></div>
        </div>

        <!-- STUDENT ENGAGEMENT -->
        <div class="engagement-card">
            <div class="engagement-header">
                <span><i class="fa fa-users me-2"></i>Student Progress</span>
                <span id="engCount" style="font-size:.75rem;color:var(--ink-soft)"></span>
            </div>
            <div id="engagementList" style="max-height:250px;overflow-y:auto">
                <asp:Repeater ID="rptEngagement" runat="server">
                    <ItemTemplate>
                        <div class="eng-row">
                            <span class="eng-name"><%# Server.HtmlEncode(Eval("UserName").ToString()) %></span>
                            <div class="progress-pill">
                                <div class="progress-fill" style="width:<%# Eval("WatchedPercent") %>%"></div>
                            </div>
                            <span class="eng-pct"><%# Eval("WatchedPercent") %>%</span>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>

        <!-- AI USAGE STATS -->
        <div class="ai-card">
            <h6><i class="fa fa-robot me-2"></i>AI Feature Usage</h6>
            <asp:Repeater ID="rptAIStats" runat="server">
                <ItemTemplate>
                    <div class="ai-stat-row">
                        <span><%# Eval("Type") %></span>
                        <strong><%# Eval("UsageCount") %></strong>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>

    </div>
</div>

<!-- HIDDEN FIELDS -->
<asp:HiddenField ID="hfVideoId" runat="server" />
<asp:HiddenField ID="hfAdminName" runat="server" />

<!-- TOAST -->
<div id="toast-wrap"></div>

<script>
    const vid = document.getElementById('<%= videoPlayer.ClientID %>');
    const vidId = '<%= VideoId %>';
    const STORAGE_KEY = 'vp_pos_' + vidId;

    // ── Toast ──
    function toast(msg, type) {
        const w = document.getElementById('toast-wrap');
        const t = document.createElement('div');
        t.className = 'toast-msg ' + (type || 'success');
        t.textContent = msg;
        w.appendChild(t);
        setTimeout(() => t.remove(), 5000);
    }

    // ── Video resume (admin side – allowed to seek) ──
    window.addEventListener('load', () => {
        const saved = parseFloat(localStorage.getItem(STORAGE_KEY) || 0);
        if (saved > 5) {
            vid.currentTime = saved;
            toast('Resumed from ' + formatTime(saved), 'success');
        }
    });

    vid.addEventListener('timeupdate', () => {
        if (!isNaN(vid.currentTime) && vid.currentTime > 0)
            localStorage.setItem(STORAGE_KEY, vid.currentTime);
    });

    vid.addEventListener('ended', () => {
        localStorage.removeItem(STORAGE_KEY);
        if (document.getElementById('chkAutoNext').checked) {
            const btn = document.getElementById('<%= btnNext.ClientID %>');
        if (btn && !btn.disabled) btn.click();
    }
});

    function formatTime(s) {
        const m = Math.floor(s / 60), sec = Math.floor(s % 60);
        return m + ':' + (sec < 10 ? '0' : '') + sec;
    }

    // ── Skip / seek ──
    function seekVideo(delta) {
        vid.currentTime = Math.max(0, Math.min(vid.duration || 0, vid.currentTime + delta));
    }

    // ── Jump to topic timestamp ──
    function jumpToTime(ts) {
        if (!ts) return;
        const parts = ts.split(':').map(Number);
        let secs = 0;
        if (parts.length === 2) secs = parts[0] * 60 + parts[1];
        else if (parts.length === 3) secs = parts[0] * 3600 + parts[1] * 60 + parts[2];
        vid.currentTime = secs;
        vid.play();
    }

    // ── Topics toggle ──
    let topicsVisible = false;
    function toggleTopics() {
        topicsVisible = !topicsVisible;
        document.getElementById('topicsStrip').style.display = topicsVisible ? 'block' : 'none';
        document.getElementById('btnToggleTopics').innerHTML =
            `<i class="fa fa-list-ul me-1"></i>${topicsVisible ? 'Hide Topics' : 'Show Topics'}`;
    }

    // ── Settings panel ──
    function toggleSettings() {
        const p = document.getElementById('settingsPanel');
        p.style.display = p.style.display === 'block' ? 'none' : 'block';
    }
    document.addEventListener('click', e => {
        if (!e.target.closest('#settingsPanel') && !e.target.closest('.vid-ctrl-btn'))
            document.getElementById('settingsPanel').style.display = 'none';
    });

    // ── Loop / AutoNext ──
    function onLoopChange() {
        const chkLoop = document.getElementById('chkLoop');
        vid.loop = chkLoop.checked;
        if (chkLoop.checked) document.getElementById('chkAutoNext').checked = false;
    }
    function onAutoNextChange() {
        if (document.getElementById('chkAutoNext').checked)
            document.getElementById('chkLoop').checked = false;
    }

    // ── Speed ──
    function setSpeed(s) {
        vid.playbackRate = s;
        document.querySelectorAll('.speed-btn').forEach(b => {
            b.classList.toggle('active', parseFloat(b.textContent) === s);
        });
    }

    // ── Screenshot ──
    function takeScreenshot() {
        try {
            const c = document.createElement('canvas');
            c.width = vid.videoWidth; c.height = vid.videoHeight;
            c.getContext('2d').drawImage(vid, 0, 0);
            const a = document.createElement('a');
            a.href = c.toDataURL('image/png');
            a.download = 'capture_' + Date.now() + '.png';
            a.click();
            toast('Screenshot saved!', 'success');
        } catch (ex) { toast('Screenshot failed (CORS?)', 'danger'); }
    }

    // ── Comments (AJAX) ──
    function loadComments() {
        fetch('VideoPlayer.aspx/GetComments', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json; charset=utf-8' },
            body: JSON.stringify({ vid: parseInt(vidId) })
        })
            .then(r => r.json())
            .then(res => {
                const data = typeof res.d === 'string' ? JSON.parse(res.d) : res.d;
                const list = document.getElementById('commentsList');
                const badge = document.getElementById('commentCountBadge');
                if (!list) return;
                if (!data || data.length === 0) {
                    list.innerHTML = '<p style="color:var(--ink-soft);font-size:.83rem;text-align:center;padding:20px 0">No comments yet. Be the first!</p>';
                    if (badge) badge.textContent = '(0)';
                    return;
                }
                if (badge) badge.textContent = `(${data.length})`;
                list.innerHTML = data.map(c => `
            <div class="cmt-item">
                <div class="cmt-avatar" style="width:36px;height:36px;border-radius:50%;background:var(--accent);color:#fff;display:flex;align-items:center;justify-content:center;font-weight:700;font-size:.82rem;flex-shrink:0">
                    ${c.Username.charAt(0).toUpperCase()}
                </div>
                <div class="cmt-body" style="flex:1">
                    <strong>${escHtml(c.Username)}</strong>
                    <p>${escHtml(c.Comment)}</p>
                    <div style="display:flex;align-items:center;gap:10px">
                        <span class="cmt-time">${c.CommentedOn || ''}</span>
                        <button class="cmt-del" onclick="deleteComment(${c.CommentId})"><i class="fa fa-trash"></i> Delete</button>
                    </div>
                </div>
            </div>`).join('');
            })
            .catch(() => toast('Failed to load comments.', 'danger'));
    }

    function postComment() {
        const box = document.getElementById('txtComment');
        const msg = (box.value || '').trim();
        if (!msg) { toast('Please type a comment.', 'danger'); return; }
        fetch('VideoPlayer.aspx/AddComment', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json; charset=utf-8' },
            body: JSON.stringify({ vid: parseInt(vidId), msg })
        })
            .then(r => r.json())
            .then(() => { box.value = ''; loadComments(); })
            .catch(() => toast('Failed to post comment.', 'danger'));
    }

    function deleteComment(id) {
        if (!confirm('Delete this comment?')) return;
        fetch('VideoPlayer.aspx/DeleteCommentAjax', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json; charset=utf-8' },
            body: JSON.stringify({ commentId: id })
        })
            .then(() => { loadComments(); toast('Comment deleted.', 'success'); })
            .catch(() => toast('Failed to delete.', 'danger'));
    }

    function escHtml(s) {
        return String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
    }

    // ── Init ──
    window.addEventListener('DOMContentLoaded', () => {
        loadComments();
        // Set admin initial
        const adm = document.getElementById('<%= hfAdminName.ClientID %>');
    const ini = document.getElementById('<%= adminInitial.ClientID %>');
    if (adm && ini && adm.value) ini.textContent = adm.value.charAt(0).toUpperCase();

    // Engagement count badge
    const rows = document.querySelectorAll('.eng-row');
    const cnt = document.getElementById('engCount');
    if (cnt) cnt.textContent = rows.length + ' student' + (rows.length !== 1 ? 's' : '');
});

    // Keyboard shortcuts
    document.addEventListener('keydown', e => {
        if (document.activeElement && ['INPUT', 'TEXTAREA'].includes(document.activeElement.tagName)) return;
        if (e.key === 'ArrowLeft') seekVideo(-10);
        if (e.key === 'ArrowRight') seekVideo(10);
        if (e.key === ' ') { e.preventDefault(); vid.paused ? vid.play() : vid.pause(); }
    });
</script>
</asp:Content>
