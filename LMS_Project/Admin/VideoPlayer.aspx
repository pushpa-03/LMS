<%@ Page Title="Admin Video Player" Language="C#" MasterPageFile="~/Admin/AdminMaster.master"
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

</asp:Content>