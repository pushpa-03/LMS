<%--<%@ Page Title="Admin Video Player" Language="C#" MasterPageFile="~/Admin/AdminMaster.master"
    AutoEventWireup="true"
    CodeBehind="VideoPlayer.aspx.cs"
    Inherits="LearningManagementSystem.Admin.VideoPlayer" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

<style>

/* ===== PAGE ===== */
body{
    background:#f4f7fb;
    color:#263238;
}

/* ===== CARD ===== */
.card-glass{
    background:#fff;
    border-radius:14px;
    box-shadow:0 2px 10px rgba(0,0,0,.08);
}

/* ===== VIDEO ===== */
.video-container{
    position:relative;
    border-radius:12px;
    overflow:hidden;
    background:#000;
}

/* SKIP BUTTONS */
.yt-skip{
    position:absolute;
    top:50%;
    transform:translateY(-50%);
    width:80px;
    height:80px;
    border-radius:50%;
    background:rgba(0,0,0,0.6);
    color:white;
    display:flex;
    justify-content:center;
    align-items:center;
    cursor:pointer;
    opacity:0;
    transition:.3s;
}
.yt-left{ left:20px;}
.yt-right{ right:20px;}

.video-container.show-controls .yt-skip{
    opacity:1;
}

/* TOP ICONS */
.video-top-icons{
    position:absolute;
    top:10px;
    right:10px;
    display:flex;
    gap:10px;
}
.video-icon{
    background:rgba(0,0,0,0.6);
    color:#fff;
    padding:8px;
    border-radius:50%;
    cursor:pointer;
}

/* SETTINGS */
.settings-panel{
    position:absolute;
    top:60px;
    right:10px;
    background:#fff;
    padding:12px;
    border-radius:10px;
    box-shadow:0 4px 10px rgba(0,0,0,.2);
    display:none;
}

/* ── STAT CARDS (Dashboard Style) ── */
.stat-card {
    border: none;
    border-radius: 14px;
    padding: 22px 20px;
    display: flex;
    align-items: center;
    gap: 16px;
    box-shadow: 0 2px 10px rgba(0,0,0,.07);
    transition: transform .2s, box-shadow .2s;
    height: 100%;
    background:#fff;
}
.stat-card:hover {
    transform: translateY(-4px);
    box-shadow: 0 6px 18px rgba(0,0,0,.12);
}

/* ICON BOX */
.icon-box {
    width: 54px;
    height: 54px;
    border-radius: 14px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 22px;
    flex-shrink: 0;
}

/* TEXT */
.stat-label {
    font-size: 11px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: .6px;
    color: #78909c;
}

.stat-value {
    font-size: 30px;
    font-weight: 800;
    color: #263238;
}

.stat-sub {
    font-size: 11px;
    color: #90a4ae;
}

/* COLORS (MATCH DASHBOARD) */
.card-blue   { background: #e3f2fd; }
.card-orange { background: #fff3e0; }
.card-purple { background: #f3e5f5; }
.card-green  { background: #e8f5e9; }

.icon-blue   { background: #1976d2; color: #fff; }
.icon-orange { background: #f57c00; color: #fff; }
.icon-purple { background: #7b1fa2; color: #fff; }
.icon-green  { background: #2e7d32; color: #fff; }

/* PLAYLIST */
.play-item{
    padding:10px;
    cursor:pointer;
    border-bottom:1px solid #eee;
}
.play-item:hover{
    background:#e3f2fd;
}
.active-video{
    background:#1565c0;
    color:#fff;
}

/* BUTTON */
.btn-light{
    background:#e3f2fd;
    color:#1565c0;
    border:none;
    border-radius:20px;
}

</style>

<div class="container-fluid mt-3">

    <div class="mb-4 p-1 text-primary fw-bolder"> <h2 id="lblVideoTitle" runat="server"></h2> </div>

    <!-- STATS -->
    <div class="row g-3 mb-4">

    <!-- Views -->
    <div class="col-6 col-md-3">
        <div class="stat-card card-blue">
            <div class="icon-box icon-blue">
                <i class="fas fa-eye"></i>
            </div>
            <div>
                <div class="stat-label">Views</div>
                <div class="stat-value">
                    <span id="lblViews" runat="server"></span>
                </div>
                <div class="stat-sub">Total video views</div>
            </div>
        </div>
    </div>

    <!-- Students -->
    <div class="col-6 col-md-3">
        <div class="stat-card card-orange">
            <div class="icon-box icon-orange">
                <i class="fas fa-users"></i>
            </div>
            <div>
                <div class="stat-label">Students</div>
                <div class="stat-value">
                    <span id="lblStudents" runat="server"></span>
                </div>
                <div class="stat-sub">Watching this video</div>
            </div>
        </div>
    </div>

    <!-- Completion -->
    <div class="col-6 col-md-3">
        <div class="stat-card card-purple">
            <div class="icon-box icon-purple">
                <i class="fas fa-chart-line"></i>
            </div>
            <div>
                <div class="stat-label">Completion</div>
                <div class="stat-value">
                    <span id="lblCompletion" runat="server"></span>
                </div>
                <div class="stat-sub">Avg watch progress</div>
            </div>
        </div>
    </div>

    <!-- Comments -->
    <div class="col-6 col-md-3">
        <div class="stat-card card-green">
            <div class="icon-box icon-green">
                <i class="fas fa-comments"></i>
            </div>
            <div>
                <div class="stat-label">Comments</div>
                <div class="stat-value">
                    <span id="lblComments" runat="server"></span>
                </div>
                <div class="stat-sub">User interactions</div>
            </div>
        </div>
    </div>

</div>


    <div class="row">

        <!-- VIDEO -->
        <div class="col-lg-8">

            <div class="video-container card-glass">
                <video id="videoPlayer" runat="server" controls width="100%" height="450"></video>
                
                <div id="skipLeft" class="yt-skip yt-left">⏪ 10</div>
                <div id="skipRight" class="yt-skip yt-right">10 ⏩</div>

                <div class="video-top-icons">
                <i class="fa fa-camera video-icon" onclick="takeScreenshot()"></i>
                <i class="fa fa-gear video-icon" onclick="toggleSettings()"></i>
                </div>

                <div id="settingsPanel" class="settings-panel">
                <label>Loop <input type="checkbox" id="loopToggle"></label><br>
                <label>Auto Next <input type="checkbox" id="autoNextToggle"></label>
                </div>

            </div>

            <!---Nav----->
            <div class="d-flex justify-content-between mt-3">
                <asp:Button ID="btnPrev" runat="server" Text="⬅ Previous" CssClass="btn btn-light" OnClick="btnPrev_Click"/>
                <asp:Button ID="btnNext" runat="server" Text="Next ➡" CssClass="btn btn-light" OnClick="btnNext_Click"/>
            </div>

            <!-- COMMENTS -->
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

            <!-- ENGAGEMENT -->
            <div class="card-glass mt-4 p-3">
                <h5>Student Progress</h5>
                <table class="table text-white">
                    <thead>
                        <tr><th>Student</th><th>Progress</th><th>Status</th></tr>
                    </thead>
                    <tbody id="engagementBody" runat="server"></tbody>
                </table>
            </div>

        </div>

        <!-- SIDEBAR -->
        <div class="col-lg-4">

            <div class="card-glass sidebar-scroll">
                <div class="p-3 fw-bold">Playlist</div>

                <asp:Repeater ID="rptPlaylist" runat="server">
                    <ItemTemplate>
                        <div class="p-2"
                             onclick="location.href='VideoPlayer.aspx?VideoId=<%# Eval("VideoId") %>'">
                            <%# Eval("Title") %>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>

            <div class="card-glass mt-3 p-3">
                <h6>Topics</h6>

                <asp:Repeater ID="rptTopics" runat="server">
                    <ItemTemplate>
                        <div>⏱ <%# Eval("StartTime") %> - <%# Eval("TopicTitle") %></div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>

        </div>

    </div>

</div>

    <asp:HiddenField ID="hfVideoId" runat="server" />

<script>

    var v = document.getElementById("<%= videoPlayer.ClientID %>");
    var videoId = document.getElementById("<%= hfVideoId.ClientID %>").value;

/* Resume */
window.onload=function(){
let t=localStorage.getItem("video-"+videoId);
if(t) v.currentTime=t;
}

/* Save */
v.ontimeupdate=function(){
localStorage.setItem("video-"+videoId,v.currentTime);
}

/* Skip */
skipLeft.onclick=()=>v.currentTime-=10;
skipRight.onclick=()=>v.currentTime+=10;

/* Controls */
v.onclick=()=>{
document.querySelector(".video-container").classList.add("show-controls");
setTimeout(()=>document.querySelector(".video-container").classList.remove("show-controls"),1500);
}

/* Screenshot */
function takeScreenshot(){
let c=document.createElement("canvas");
c.width=v.videoWidth;
c.height=v.videoHeight;
c.getContext("2d").drawImage(v,0,0);
let a=document.createElement("a");
a.href=c.toDataURL();
a.download="shot.png";
a.click();
}

/* Settings */
function toggleSettings(){
let p=document.getElementById("settingsPanel");
p.style.display=p.style.display=="block"?"none":"block";
}

/* LOOP */
document.getElementById("loopToggle").onchange=function(){
v.loop=this.checked;
}

/* AUTO NEXT */
v.onended=function(){
if(document.getElementById("autoNextToggle").checked){
window.location.href="VideoPlayer.aspx?VideoId=<%= NextVideoId %>";
        }
    }

</script>

</asp:Content>--%>


<%-------------------------------------------------------------------------------------------------------------------------------------------------%>

<%@ Page Title="Admin Video Player" Language="C#" MasterPageFile="~/Admin/AdminMaster.master" AutoEventWireup="true" CodeBehind="VideoPlayer.aspx.cs" Inherits="LearningManagementSystem.Admin.VideoPlayer" %>

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