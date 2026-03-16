<%@ Page Title="Video Player" Language="C#" MasterPageFile="~/Admin/AdminMaster.master"
    AutoEventWireup="true"
    CodeBehind="VideoPlayer.aspx.cs"
    Inherits="LearningManagementSystem.Admin.VideoPlayer" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

    <style>
        .video-container {
            background: #000;
            border-radius: 8px;
            overflow: hidden;
            position: relative;
        }

        video::cue {
            background: rgba(0,0,0,0.7);
            color: #fff;
            font-size: 16px;
            padding: 3px 6px;
        }

        .sidebar-scroll {
            max-height: 600px;
            overflow-y: auto;
        }

        .instructor-card {
            display: flex;
            align-items: center;
            gap: 15px;
            border-top: 1px solid #eee;
            padding-top: 15px;
        }

        .instructor-img {
            width: 60px;
            height: 60px;
            border-radius: 50%;
            object-fit: cover;
        }

        .timestamp-link {
            cursor: pointer;
            color: #007bff;
            text-decoration: none;
            font-weight: 500;
        }
        .yt-skip{
            position:absolute;
            top:50%;
            transform:translateY(-50%);
            width:90px;
            height:90px;
            border-radius:50%;
            background:rgba(0,0,0,0.6);
            color:white;
            display:flex;
            justify-content:center;
            align-items:center;
            font-size:18px;
            cursor:pointer;
            opacity:0;
            transition:opacity 0.3s;
        }

        .yt-left{ left:20px; }
        .yt-right{ right:20px; }

        .video-container.show-controls .yt-skip{
            opacity:1;
        }

        .video-menu{
            position:absolute;
            top:15px;
            right:15px;
            background:#222;
            border-radius:6px;
            display:none;
        }

        .video-menu button{
            background:none;
            border:none;
            color:white;
            padding:10px 15px;
            cursor:pointer;
        }

        .video-top-icons{
            position:absolute;
            top:10px;
            right:15px;
            display:flex;
            gap:15px;
            }

            .video-icon{
            color:white;
            font-size:20px;
            cursor:pointer;
            background:rgba(0,0,0,0.6);
            padding:8px;
            border-radius:50%;
            }

            .video-icon:hover{
            background:rgba(0,0,0,0.8);
            }

            .video-menu{
            position:absolute;
            top:45px;
            right:10px;
            background:#222;
            border-radius:6px;
            display:none;
            }

            .video-menu button{
            background:none;
            border:none;
            color:white;
            padding:10px 15px;
            width:150px;
            text-align:left;
            }

            .settings-panel{
            position:absolute;
            top:80px;
            right:10px;
            background:#222;
            color:white;
            padding:15px;
            border-radius:6px;
            display:none;
            font-size:14px;
            }

            .settings-panel label{
            display:flex;
            justify-content:space-between;
            align-items:center;
            margin-bottom:6px;
            }

            .settings-panel hr{
border-color:#444;
}
    </style>


    <div class="container-fluid mt-3">

        <div class="row mb-3">
            <div class="col-12">

                <div class="d-flex align-items-center mb-4">

                    <a href="SubjectDetails.aspx" class="btn btn-outline-secondary me-3">
                        <i class="fa-solid fa-arrow-left"></i>
                    </a>

                    <h2 class="fw-bold" id="lblVideoTitle" runat="server"></h2>

                </div>

                <p class="text-muted">
                    Subject:
                    <span id="lblSubject" runat="server">General</span>
                    | Instructor:
                    <span id="lblInstructorTop" runat="server"></span>
                </p>

            </div>
        </div>


        <div class="row">

            <div class="col-lg-8">

               <div class="video-container shadow">

                <video
                id="videoPlayerControl"
                runat="server"
                width="100%"
                height="480"
                controls
                preload="metadata"
                controlslist="nodownload noremoteplayback"
                disablepictureinpicture>

                <source id="videoSource" runat="server" type="video/mp4" />

                <track kind="subtitles" label="English" srclang="en" src="../Captions/english.vtt" default>

                </video>


                <!-- Skip overlays -->

                <div id="skipLeft" class="yt-skip yt-left">
                <i class="fa-solid fa-rotate-left"></i> 10
                </div>

                <div id="skipRight" class="yt-skip yt-right">
                10 <i class="fa-solid fa-rotate-right"></i>
                </div>


                <!-- Screenshot icon -->

                <div class="video-top-icons">

                <i
                class="fa-solid fa-camera video-icon"
                title="Screenshot"
                onclick="takeScreenshot()">
                </i>

                <i
                class="fa-solid fa-gear video-icon"
                title="Settings"
                onclick="toggleSettings()">
                </i>

                </div>




                <!-- Settings panel -->

                <div id="settingsPanel" class="settings-panel">

                <div class="mb-2 fw-bold">Playback Settings</div>

                <label class="d-block">
                Loop Video
                <input type="radio" name="loopVideo" value="on">
                </label>

                <label class="d-block">
                Loop Video Off
                <input type="radio" name="loopVideo" value="off" checked>
                </label>

                <hr>

                <label class="d-block">
                Auto Next Video
                <input type="radio" name="autoNext" value="on">
                </label>

                <label class="d-block">
                Auto Next Off
                <input type="radio" name="autoNext" value="off" checked>
                </label>

                </div>
        </div>


                <canvas id="canvas" style="display: none;"></canvas>
                <div class="card shadow mt-3 p-3">

                <div class="d-flex justify-content-between align-items-center">

                <h5 class="fw-bold mb-0">
                <i class="fa-solid fa-robot text-primary"></i>
                AI Video Summary
                </h5>

               <button 
                type="button"
                class="btn btn-sm btn-outline-primary"
                onclick="generateSummary()">
                Generate
                </button> 

                </div>

                <div id="aiSummary" class="mt-3 text-muted">

                Click "Generate" to create AI summary.

                </div>

                </div>

                <div class="card shadow mt-3 p-3">

                    <h5 class="fw-bold">
                    <i class="fa-solid fa-robot text-success"></i>
                    Ask AI about this lecture
                    </h5>

                    <div class="input-group mt-2">

                    <input id="aiQuestion"
                    class="form-control"
                    placeholder="Ask a doubt about the lecture">

                    <button class="btn btn-success"
                    onclick="askAI()">
                    Ask
                    </button>

                    </div>

                    <div id="aiAnswer" class="mt-3"></div>

                 </div>

                <div class="card shadow mt-3 p-3">

                    <h5 class="fw-bold">
                    <i class="fa-solid fa-robot text-success"></i>
                    Get Quiz from AI
                    </h5>    

                    <button 
                    type="button"
                    class="btn btn-sm btn-outline-success"
                    onclick="generateQuiz()">
                    Generate Quiz
                    </button>

                    <div id="aiQuiz" class="mt-3"></div>

                 </div>

                <div class="card shadow mt-3 p-3">

                    <h5 class="fw-bold">
                    <i class="fa-solid fa-robot text-success"></i>
                    Get Notes from AI
                    </h5>    

                    <button 
                    type="button"
                    class="btn btn-sm btn-outline-warning"
                    onclick="generateNotes()">
                    Generate Notes
                    </button>

                    <div id="aiNotes" class="mt-3"></div>

                 </div>

                

                <div class="card shadow mt-3 p-3">

                    <ul class="nav nav-tabs" id="myTab">

                        <li class="nav-item">
                            <a class="nav-link active" data-bs-toggle="tab" href="#desc">Description</a>
                        </li>

                        <li class="nav-item">
                            <a class="nav-link" data-bs-toggle="tab" href="#notes">Smart Notes</a>
                        </li>

                        <li class="nav-item">
                            <a class="nav-link" data-bs-toggle="tab" href="#doubts">Doubts</a>
                        </li>

                        <li class="nav-item">
                            <a class="nav-link" data-bs-toggle="tab" href="#comments">Comments</a>
                        </li>

                        <li id="liEngagement" runat="server" class="nav-item">
                            <a class="nav-link text-danger" data-bs-toggle="tab" href="#engagement">Admin: Progress</a>
                        </li>

                    </ul>


                    <div class="tab-content p-3">

                        <div id="desc" class="tab-pane fade show active">

                            <p id="lblDescription" runat="server"></p>

                            <div class="instructor-card">

                                <img src="../Uploads/avatar.png" class="instructor-img" />

                                <h6 id="lblInstructorName" runat="server"></h6>

                            </div>

                        </div>


                        <div id="notes" class="tab-pane fade">

                            <div class="input-group mb-2">

                                <asp:TextBox
                                    ID="txtNote"
                                    runat="server"
                                    CssClass="form-control"
                                    placeholder="Note at current time..."></asp:TextBox>

                                <asp:Button
                                    ID="btnSaveNote"
                                    runat="server"
                                    Text="Save"
                                    CssClass="btn btn-primary"
                                    OnClick="btnSaveNote_Click" />

                            </div>


                            <asp:Repeater ID="rptNotes" runat="server">

                                <ItemTemplate>

                                    <div class="mb-2">

                                        <a
                                            class="timestamp-link"
                                            onclick="jumpTo(<%# Eval("TimeStampSeconds") %>)">⏱ <%# Eval("TimeStampSeconds") %>s

                                        </a>

                                        :

                                        <%# Eval("NoteText") %>
                                    </div>

                                </ItemTemplate>

                            </asp:Repeater>

                        </div>


                        <div id="doubts" class="tab-pane fade">

                            <div class="input-group mb-2">

                                <asp:TextBox
                                    ID="txtDoubt"
                                    runat="server"
                                    CssClass="form-control"
                                    placeholder="Pin a doubt..."></asp:TextBox>

                                <asp:Button
                                    ID="btnDoubt"
                                    runat="server"
                                    Text="Pin"
                                    CssClass="btn btn-warning"
                                    OnClick="btnDoubt_Click" />

                            </div>

                        </div>


                        <div id="comments" class="tab-pane fade">

                            <asp:TextBox
                                ID="txtComment"
                                runat="server"
                                CssClass="form-control"
                                TextMode="MultiLine"
                                Rows="2"></asp:TextBox>

                            <asp:Button
                                ID="btnComment"
                                runat="server"
                                Text="Post Comment"
                                CssClass="btn btn-success mt-2"
                                OnClick="btnComment_Click" />

                        </div>


                        <div id="engagement" class="tab-pane fade">

                            <table class="table">

                                <thead>

                                    <tr>
                                        <th>Student</th>
                                        <th>Progress</th>
                                        <th>Status</th>
                                    </tr>

                                </thead>

                                <tbody id="engagementBody" runat="server"></tbody>

                            </table>

                        </div>

                    </div>

                </div>

            </div>


            <div class="col-lg-4">

                <div class="card shadow sidebar-scroll">

                    <div class="card-header fw-bold">
                        Video Topics
                    </div>

                    <div class="list-group list-group-flush">

                        <asp:Repeater ID="rptTopics" runat="server">

                            <ItemTemplate>

                                <div
                                    class="list-group-item d-flex justify-content-between"
                                    onclick="jumpToText('<%# Eval("StartTime") %>')"
                                    style="cursor: pointer">

                                    <%# Eval("TopicTitle") %>

                                    <span class="badge bg-secondary">

                                        <%# Eval("StartTime") %>

                                    </span>

                                </div>

                            </ItemTemplate>

                        </asp:Repeater>

                    </div>

                </div>

            </div>

        </div>

    </div>


    <asp:HiddenField ID="hfTime" runat="server" />
    <asp:HiddenField ID="hfVideoId" runat="server" />
    <asp:HiddenField ID="hfVideoName" runat="server" />


    <script>
        var v = document.getElementById("<%= videoPlayerControl.ClientID %>");
        var container = document.querySelector(".video-container");

        var videoId = document.getElementById("<%= hfVideoId.ClientID %>").value;

        /* caption */
        /* Force caption ON at start */

        window.addEventListener("load", function () {

            if (v.textTracks.length > 0) {

                v.textTracks[0].mode = "showing";

            }

        });

/* Resume */

window.onload=function(){

var savedTime=localStorage.getItem("video-"+videoId);

if(savedTime){
v.currentTime=savedTime;
}

}

/* Save progress */

v.ontimeupdate=function(){

            document.getElementById("<%= hfTime.ClientID %>").value =
                Math.floor(v.currentTime);

            localStorage.setItem("video-" + videoId, v.currentTime);

        }

        /* Smooth Skip */

        document.getElementById("skipLeft").onclick = function () {

            v.currentTime = Math.max(0, v.currentTime - 10);

        }

        document.getElementById("skipRight").onclick = function () {

            v.currentTime = Math.min(v.duration, v.currentTime + 10);

        }

        /* Show controls like YouTube */

        v.addEventListener("click", function () {

            container.classList.add("show-controls");

            setTimeout(function () {

                container.classList.remove("show-controls");

            }, 1500)

        })

        /* Screenshot */

        function takeScreenshot() {

            var canvas = document.getElementById("canvas");

            canvas.width = v.videoWidth;
            canvas.height = v.videoHeight;

            var ctx = canvas.getContext("2d");

            ctx.drawImage(v, 0, 0, canvas.width, canvas.height);

            var image = canvas.toDataURL("image/png");

            var a = document.createElement("a");

            a.href = image;
            a.download = "video-screenshot.png";

            a.click();

        }

        /* Menu */

        function toggleSettings() {

            var p = document.getElementById("settingsPanel");

            p.style.display = p.style.display == "block" ? "none" : "block";

        }

        /* LOOP VIDEO */

        document.querySelectorAll('input[name="loopVideo"]').forEach(r => {

            r.addEventListener("change", function () {

                if (this.value == "on") {

                    v.loop = true;

                    /* turn auto-next OFF */

                    document.querySelector('input[name="autoNext"][value="off"]').checked = true;

                }

                else {

                    v.loop = false;

                }

            })

        })

        /* AUTO NEXT */

        document.querySelectorAll('input[name="autoNext"]').forEach(r => {

            r.addEventListener("change", function () {

                if (this.value == "on") {

                    /* turn loop OFF */

                    document.querySelector('input[name="loopVideo"][value="off"]').checked = true;

                    v.loop = false;

                }

            })

        })

        /* CAPTION CONTROL */

        document.querySelectorAll('input[name="caption"]').forEach(r => {

            r.addEventListener("change", function () {

                var tracks = v.textTracks;

                for (let i = 0; i < tracks.length; i++) {

                    tracks[i].mode = this.value == "on" ? "showing" : "hidden";

                }

            })

        })

        document.getElementById("settingsPanel").addEventListener("click", function (e) {
            e.stopPropagation();
        });

        /* VIDEO END LOGIC */

        v.addEventListener("ended", function () {

            var autoNext = document.querySelector('input[name="autoNext"]:checked').value;

            var loop = document.querySelector('input[name="loopVideo"]:checked').value;

            if (autoNext == "on") {

                window.location.href = "NextVideo.aspx";

            }

            /* if both off do nothing */

        })

        /* Close settings when clicking video */

        v.addEventListener("click", function () {

            var panel = document.getElementById("settingsPanel");

            if (panel.style.display == "block") {
                panel.style.display = "none";
            }

        });

        async function generateSummary() {

            var box = document.getElementById("aiSummary");

            var videoName =
                document.getElementById("<%= hfVideoName.ClientID %>").value;

            box.innerHTML = "Generating AI summary...";

            let res = await fetch(
                "http://localhost:8000/generate-summary?video_name=" + encodeURIComponent(videoName),
                { method: "POST" }
            );

            let data = await res.json();

            if (data.error) {
                box.innerHTML = data.error;
                return;
            }

            box.innerHTML = "<pre>" + data.summary + "</pre>";
        }

        async function generateQuiz() {

            var videoName =
                document.getElementById("<%= hfVideoName.ClientID %>").value;

            let res = await fetch(
                "http://localhost:8000/generate-quiz?video_name=" + encodeURIComponent(videoName),
                { method: "POST" }
            );

            let data = await res.json();

            document.getElementById("aiQuiz").innerHTML =
                "<h6>AI Quiz</h6><pre>" + data.quiz + "</pre>";
        }

        async function generateNotes() {

            var videoName =
                document.getElementById("<%= hfVideoName.ClientID %>").value;

            let res = await fetch(
                "http://localhost:8000/generate-notes?video_name=" + encodeURIComponent(videoName),
                { method: "POST" }
            );

            let data = await res.json();

            document.getElementById("aiNotes").innerHTML =
                "<h6>AI Notes</h6><pre>" + data.notes + "</pre>";
        }

        async function askAI() {

            var q = document.getElementById("aiQuestion").value;

            var videoName =
                document.getElementById("<%= hfVideoName.ClientID %>").value;

            document.getElementById("aiAnswer").innerHTML = "Thinking...";

            let res = await fetch(
                "http://localhost:8000/ask-ai?video_name=" +
                encodeURIComponent(videoName) +
                "&question=" +
                encodeURIComponent(q),
                { method: "POST" }
            );

            let data = await res.json();

            document.getElementById("aiAnswer").innerHTML =
                "<pre>" + data.answer + "</pre>";
        }

    </script>

</asp:Content>

