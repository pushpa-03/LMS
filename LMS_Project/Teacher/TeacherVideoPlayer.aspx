<%@ Page Title="Teacher Video Player"
    Language="C#"
    MasterPageFile="~/Teacher/TeacherMaster.master"
    AutoEventWireup="true"
    CodeBehind="TeacherVideoPlayer.aspx.cs"
    Inherits="LMS_Project.Teacher.TeacherVideoPlayer" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"/>

<style>
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
:root {
    --primary:       #c62828;
    --primary-dark:  #b71c1c;
    --primary-light: #fce4ec;
    --success:  #059669;
    --danger:   #dc2626;
    --warn:     #d97706;
    --amber:    #f59e0b;
    --purple:   #7c3aed;
    --bg:       #f1f5f9;
    --card:     #ffffff;
    --border:   #e2e8f0;
    --text:     #0f172a;
    --muted:    #64748b;
    --dim:      #94a3b8;
    --shadow:    0 1px 3px rgba(0,0,0,.07), 0 4px 16px rgba(0,0,0,.05);
    --shadow-lg: 0 8px 32px rgba(0,0,0,.12);
    --radius: 12px;
    --font: 'Inter', system-ui, sans-serif;
    /* Role colours */
    --blue:    #1565c0; --blue-l:   #e3f2fd;
    --green:   #2e7d32; --green-l:  #e8f5e9;
    --red:     #c62828; --red-l:    #fce4ec;
}
body { font-family: var(--font); background: var(--bg); color: var(--text); font-size: 14px; line-height: 1.6; }

/* ── PAGE WRAPPER ── */
.vp-wrap { max-width: 1480px; margin: 0 auto; padding: 20px 22px; }
@media(max-width:700px){ .vp-wrap { padding: 12px; } }

/* ── BACK BAR ── */
.back-bar { display: flex; align-items: center; gap: 12px; margin-bottom: 18px; }
.btn-back {
    display: inline-flex; align-items: center; gap: 6px;
    background: var(--card); border: 1px solid var(--border); border-radius: 10px;
    padding: 7px 14px; font-size: 13px; font-weight: 600; color: var(--muted);
    text-decoration: none; transition: .18s;
}
.btn-back:hover { border-color: var(--primary); color: var(--primary); }
.page-head { font-size: 1.1rem; font-weight: 800; color: var(--text); flex: 1;
    white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }

/* ── GRID ── */
.vp-grid { display: grid; grid-template-columns: 1fr 320px; gap: 18px; align-items: start; }
@media(max-width:1100px){ .vp-grid { grid-template-columns: 1fr; } }

/* ── VIDEO BOX ── */
.vid-box {
    background: #000; border-radius: var(--radius);
    overflow: hidden; position: relative; width: 100%; aspect-ratio: 16/9;
    box-shadow: var(--shadow-lg);
}
.vid-box video { width: 100%; height: 100%; display: block; }

.skip-z {
    position: absolute; top: 0; bottom: 0; width: 28%;
    display: flex; align-items: center; justify-content: center;
    opacity: 0; transition: .2s; cursor: pointer; color: #fff;
}
.skip-z.L { left: 0;  background: linear-gradient(90deg,rgba(0,0,0,.45),transparent); }
.skip-z.R { right: 0; background: linear-gradient(270deg,rgba(0,0,0,.45),transparent); }
.vid-box:hover .skip-z { opacity: 1; }
.sk-lbl { display: flex; flex-direction: column; align-items: center; font-size: 11px; font-weight: 700; gap: 2px; }

.vid-ov { position: absolute; top: 12px; right: 12px; display: flex; gap: 8px; z-index: 10; }
.vbtn {
    background: rgba(0,0,0,.55); backdrop-filter: blur(6px); color: #fff;
    border: none; border-radius: 8px; padding: 7px 11px; font-size: 12px;
    cursor: pointer; transition: .18s; display: flex; align-items: center; gap: 5px;
    font-family: var(--font);
}
.vbtn:hover { background: rgba(0,0,0,.8); }

/* Settings dropdown */
.sett {
    position: absolute; top: 46px; right: 12px; width: 230px;
    background: var(--card); border: 1px solid var(--border);
    border-radius: var(--radius); padding: 14px; z-index: 20;
    display: none; box-shadow: var(--shadow-lg);
}
.srow { display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px; font-size: 13px; font-weight: 500; }
.srow:last-child { margin-bottom: 0; }
.sw { position: relative; width: 38px; height: 20px; flex-shrink: 0; }
.sw input { opacity: 0; width: 0; height: 0; position: absolute; }
.sw-t { position: absolute; inset: 0; background: var(--border); border-radius: 20px; cursor: pointer; transition: .3s; }
.sw-t::before { content:''; position: absolute; height: 14px; width: 14px; left: 3px; top: 3px; background: #fff; border-radius: 50%; transition: .3s; }
.sw input:checked + .sw-t { background: var(--primary); }
.sw input:checked + .sw-t::before { transform: translateX(18px); }
.spds { display: flex; gap: 4px; flex-wrap: wrap; margin-top: 6px; }
.spd { background: var(--bg); border: 1px solid var(--border); border-radius: 6px; padding: 2px 8px; font-size: 12px; font-weight: 600; cursor: pointer; color: var(--text); transition: .18s; font-family: var(--font); }
.spd.on, .spd:hover { background: var(--primary); color: #fff; border-color: var(--primary); }

/* ── INFO CARD ── */
.info-card { background: var(--card); border: 1px solid var(--border); border-radius: var(--radius); padding: 18px; margin-top: 14px; box-shadow: var(--shadow); }
.vid-title { font-size: 1.1rem; font-weight: 800; color: var(--text); line-height: 1.35; margin-bottom: 10px; }
.vid-meta { display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 8px; }
.meta-chips { display: flex; gap: 14px; font-size: 12px; color: var(--muted); flex-wrap: wrap; align-items: center; }
.meta-chips span { display: flex; align-items: center; gap: 4px; }
.stars { display: flex; gap: 2px; font-size: 13px; }
.son { color: #f59e0b; } .soff { color: var(--border); }

/* Description expand */
.desc-wrap { margin-top: 12px; }
.desc-body { font-size: 13px; color: var(--muted); line-height: 1.7; overflow: hidden; transition: max-height .3s ease; }
.desc-body.clamp { max-height: 48px; }
.desc-body.open  { max-height: 4000px; }
.btn-more {
    background: none; border: none; color: var(--primary); font-size: 12px;
    font-weight: 700; cursor: pointer; padding: 5px 0; font-family: var(--font);
    display: flex; align-items: center; gap: 4px; margin-top: 4px;
}

/* Topics strip */
.topics { background: var(--bg); border: 1px solid var(--border); border-radius: 9px; padding: 12px; margin-top: 10px; display: none; }
.topics.open { display: block; }
.t-row { display: flex; align-items: center; gap: 10px; padding: 7px 0; border-bottom: 1px solid var(--border); cursor: pointer; font-size: 13px; transition: .15s; }
.t-row:last-child { border-bottom: none; }
.t-row:hover { color: var(--primary); }
.t-ts { font-size: 11px; font-weight: 700; background: var(--primary-light); color: var(--primary); border-radius: 5px; padding: 2px 7px; min-width: 48px; text-align: center; flex-shrink: 0; font-family: monospace; }

/* Teacher notice (replaces student restriction notice) */
.teacher-notice {
    display: flex; align-items: center; gap: 8px;
    background: #fff8e1; border: 1px solid #fde68a; border-radius: 9px;
    padding: 9px 13px; font-size: 12px; color: #7c4a03; margin-top: 12px;
}

/* ── STATS ── */
.stats-strip { display: grid; grid-template-columns: repeat(4,1fr); gap: 10px; margin-top: 14px; }
@media(max-width:600px){ .stats-strip { grid-template-columns: repeat(2,1fr); } }
.stat-b { background: var(--card); border: 1px solid var(--border); border-radius: var(--radius); padding: 14px; text-align: center; box-shadow: var(--shadow); }
.sn { font-size: 1.5rem; font-weight: 800; color: var(--text); line-height: 1; font-family: monospace; }
.sl { font-size: 10px; font-weight: 700; text-transform: uppercase; letter-spacing: .06em; color: var(--muted); margin-top: 4px; }

/* ══════════════════════════════════
   COMMENTS
   ══════════════════════════════════ */
.cmts-card {
    background: var(--card); border: 1px solid var(--border);
    border-radius: var(--radius); margin-top: 14px; box-shadow: var(--shadow);
    overflow: hidden;
}
.cmts-hdr {
    display: flex; align-items: center; justify-content: space-between;
    flex-wrap: wrap; gap: 10px;
    padding: 14px 18px; border-bottom: 1px solid var(--border);
}
.cmts-hdr h5 { font-size: 15px; font-weight: 800; color: var(--text); margin: 0; }
.cmt-count { font-size: 12px; color: var(--muted); font-weight: 500; margin-top: 2px; }

.cmt-filters { display: flex; gap: 6px; flex-wrap: wrap; }
.cf {
    border: 1.5px solid var(--border); border-radius: 20px;
    padding: 3px 12px; font-size: 11px; font-weight: 700; cursor: pointer;
    background: var(--card); color: var(--muted); font-family: var(--font);
    transition: .18s;
}
.cf.active, .cf:hover { background: var(--primary); color: #fff; border-color: var(--primary); }

/* New-comment input area */
.new-cmt { display: flex; gap: 10px; padding: 14px 18px; border-bottom: 1px solid var(--border); }
.av {
    width: 36px; height: 36px; border-radius: 50%;
    background: var(--primary); color: #fff;
    display: flex; align-items: center; justify-content: center;
    font-weight: 700; font-size: 13px; flex-shrink: 0;
}
.cinput-wrap { flex: 1; }
.ctxt {
    width: 100%; background: var(--bg); border: 1.5px solid var(--border);
    border-radius: 9px; padding: 9px 13px; font-size: 13px; color: var(--text);
    resize: none; font-family: var(--font); transition: .18s; min-height: 56px;
}
.ctxt:focus { border-color: var(--primary); outline: none; box-shadow: 0 0 0 3px rgba(198,40,40,.1); }
.cmt-actions { display: flex; justify-content: flex-end; gap: 8px; margin-top: 7px; }
.btn-cancel {
    background: none; border: 1px solid var(--border); border-radius: 8px;
    padding: 6px 12px; font-size: 12px; color: var(--muted);
    cursor: pointer; font-family: var(--font);
}
.btn-post {
    background: var(--primary); color: #fff; border: none; border-radius: 8px;
    padding: 6px 16px; font-size: 12px; font-weight: 700;
    cursor: pointer; font-family: var(--font); transition: .18s;
    display: inline-flex; align-items: center; gap: 5px;
}
.btn-post:hover { background: var(--primary-dark); }
.btn-post:disabled { opacity: .5; pointer-events: none; }

#cmtList { padding: 0 18px; }

/* Single comment row */
.cmt-row {
    display: flex; gap: 10px;
    padding: 12px 0; border-bottom: 1px solid #f0f4f8;
    animation: fadeUp .3s ease;
}
.cmt-row:last-child { border-bottom: none; }

.c-av {
    width: 32px; height: 32px; border-radius: 50%;
    display: flex; align-items: center; justify-content: center;
    font-size: 12px; font-weight: 700; color: #fff; flex-shrink: 0;
}
.av-student { background: var(--blue); }
.av-teacher { background: var(--green); }
.av-admin   { background: var(--red); }
.av-other   { background: var(--purple); }

.cmt-body { flex: 1; min-width: 0; }
.cmt-top { display: flex; align-items: center; gap: 6px; flex-wrap: wrap; margin-bottom: 3px; }
.c-nm { font-size: 13px; font-weight: 700; color: var(--text); }
.c-rl { font-size: 10px; font-weight: 700; padding: 1px 7px; border-radius: 9px; }
.rl-student { background: var(--blue-l);  color: var(--blue); }
.rl-teacher { background: var(--green-l); color: var(--green); }
.rl-admin   { background: var(--red-l);   color: var(--red); }
.rl-other   { background: var(--bg);      color: var(--muted); }
.c-ts { font-size: 10px; color: var(--dim); }
.c-tx { font-size: 13px; color: var(--muted); line-height: 1.65; margin: 3px 0 6px; }
.c-meta { display: flex; gap: 12px; align-items: center; }
.btn-rep, .btn-del {
    background: none; border: none; font-size: 11px; font-weight: 600;
    cursor: pointer; font-family: var(--font); transition: .15s;
    padding: 0; display: inline-flex; align-items: center; gap: 4px;
}
.btn-rep { color: var(--muted); } .btn-rep:hover { color: var(--primary); }
.btn-del { color: var(--dim); }   .btn-del:hover { color: var(--danger); }

/* Reply box */
.reply-box { margin: 8px 0 4px 0; background: var(--bg); border-radius: 9px; padding: 12px; display: none; }
.reply-box.open { display: block; }
.reply-input-row { display: flex; gap: 8px; margin-bottom: 8px; align-items: flex-start; }
.reply-input-row textarea {
    flex: 1; border: 1.5px solid var(--border); border-radius: 8px;
    padding: 8px 10px; font-size: 12px; font-family: var(--font);
    resize: none; height: 48px; color: var(--text); transition: .2s;
    background: var(--card);
}
.reply-input-row textarea:focus { border-color: var(--primary); outline: none; box-shadow: 0 0 0 3px rgba(198,40,40,.1); }
.btn-reply-post {
    background: var(--primary); color: #fff; border: none; border-radius: 8px;
    padding: 8px 13px; font-size: 12px; font-weight: 700;
    cursor: pointer; font-family: var(--font); transition: .15s; flex-shrink: 0;
}
.btn-reply-post:hover { background: var(--primary-dark); }
.btn-reply-cancel {
    background: none; border: 1px solid var(--border); border-radius: 8px;
    padding: 5px 10px; font-size: 11px; color: var(--muted);
    cursor: pointer; font-family: var(--font);
}
.replies-list { margin-top: 8px; padding-left: 14px; border-left: 2px solid var(--border); }
.reply-row { display: flex; gap: 8px; padding: 8px 0; border-bottom: 1px dashed var(--border); }
.reply-row:last-child { border-bottom: none; }

.cmts-empty { text-align: center; padding: 28px 18px; color: var(--muted); font-size: 13px; }

@keyframes fadeUp { from{opacity:0;transform:translateY(8px)} to{opacity:1;transform:translateY(0)} }

/* ── RIGHT PANEL ── */
.right-col { display: flex; flex-direction: column; gap: 14px; }
.panel { background: var(--card); border: 1px solid var(--border); border-radius: var(--radius); overflow: hidden; box-shadow: var(--shadow); }
.ph { padding: 12px 16px; border-bottom: 1px solid var(--border); display: flex; justify-content: space-between; align-items: center; }
.ph h6 { font-size: 13px; font-weight: 700; color: var(--text); }
.badge-pill { background: var(--primary-light); color: var(--primary); border-radius: 20px; padding: 2px 10px; font-size: 11px; font-weight: 700; }

/* Playlist */
.pl-scroll { max-height: 300px; overflow-y: auto; }
.pli { display: flex; gap: 10px; padding: 10px 14px; cursor: pointer; border-bottom: 1px solid var(--border); transition: .15s; }
.pli:hover { background: var(--bg); }
.pli.on { background: var(--primary-light); border-left: 3px solid var(--primary); }
.pl-thumb { width: 68px; height: 40px; background: #7c1d1d; border-radius: 6px; flex-shrink: 0; display: flex; align-items: center; justify-content: center; color: #fff; font-size: 13px; }
.pli-info strong { font-size: 12px; font-weight: 600; color: var(--text); display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; }
.pli-info span { font-size: 11px; color: var(--muted); }

.nav-btns { display: grid; grid-template-columns: 1fr 1fr; gap: 8px; padding: 12px; }
.bn { border-radius: 9px; padding: 8px; font-size: 12px; font-weight: 700; cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 5px; text-decoration: none; transition: .18s; border: none; font-family: var(--font); }
.bn.prev { background: var(--bg); color: var(--muted); border: 1px solid var(--border); }
.bn.next { background: var(--primary); color: #fff; }
.bn:hover { opacity: .85; } .bn:disabled { opacity: .35; pointer-events: none; }

/* Rating */
.rat-body { padding: 14px; }
.big-n { font-size: 2.6rem; font-weight: 800; color: var(--text); line-height: 1; font-family: monospace; }
.rat-sub { font-size: 12px; color: var(--muted); margin-top: 4px; }

/* Engagement */
.eng-list { max-height: 230px; overflow-y: auto; }
.er { display: flex; align-items: center; gap: 10px; padding: 9px 14px; border-bottom: 1px solid var(--border); font-size: 13px; }
.er:last-child { border-bottom: none; }
.en { flex: 1; font-weight: 500; color: var(--text); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.pt { background: var(--border); border-radius: 20px; height: 5px; width: 80px; overflow: hidden; flex-shrink: 0; }
.pb { height: 100%; border-radius: 20px; background: linear-gradient(90deg, var(--primary), var(--purple)); transition: width .5s ease; }
.ep { font-size: 12px; font-weight: 700; color: var(--primary); min-width: 34px; text-align: right; font-family: monospace; }

/* AI Stats */
.ai-body { padding: 14px; }
.air { display: flex; justify-content: space-between; font-size: 13px; padding: 6px 0; border-bottom: 1px solid var(--border); }
.air:last-child { border-bottom: none; }
.air span { color: var(--muted); }
.air strong { color: var(--text); font-family: monospace; }

/* ── TOAST ── */
#toast-root { position: fixed; bottom: 24px; right: 24px; z-index: 9999; display: flex; flex-direction: column; gap: 8px; pointer-events: none; }
.toast { border-radius: 10px; padding: 10px 16px; font-size: 13px; font-weight: 600; color: #fff; animation: slideIn .3s ease; max-width: 320px; pointer-events: auto; box-shadow: var(--shadow-lg); }
.toast.ok  { background: #059669; }
.toast.err { background: #dc2626; }
.toast.inf { background: var(--primary); }
@keyframes slideIn { from{opacity:0;transform:translateX(40px)} to{opacity:1;transform:translateX(0)} }
.alert-box { border-radius: 10px; padding: 10px 14px; font-size: 13px; margin-bottom: 14px; }
</style>

<div class="vp-wrap">

<!-- BACK BAR -->
<div class="back-bar">
    <a href="javascript:history.back()" class="btn-back"><i class="fa fa-arrow-left"></i> Back</a>
    <span class="page-head" id="pageTitle" runat="server"></span>
</div>

<asp:Label ID="lblMsg" runat="server" CssClass="alert-box" Visible="false" />

<div class="vp-grid">
<!-- ═══ LEFT ═══ -->
<div>
    <!-- VIDEO -->
    <div class="vid-box">
        <video id="videoPlayer"
               controls
               controlsList="nodownload"
               preload="metadata"
               oncontextmenu="return false">
            <source id="vpSrc" src="" type="video/mp4">
            Your browser does not support HTML5 video.
        </video>

        <div class="skip-z L" onclick="seek(-10)">
            <div class="sk-lbl"><i class="fas fa-backward"></i><span>10s</span></div>
        </div>
        <div class="skip-z R" onclick="seek(10)">
            <div class="sk-lbl"><i class="fas fa-forward"></i><span>10s</span></div>
        </div>

        <div class="vid-ov">
            <button type="button" class="vbtn" onclick="takeShot()"><i class="fas fa-camera"></i></button>
            <button type="button" class="vbtn" onclick="toggleSett()"><i class="fas fa-cog"></i></button>
        </div>

        <div class="sett" id="settPanel">
            <div class="srow"><span>Loop</span>
                <label class="sw"><input type="checkbox" id="chkLoop" onchange="vid.loop=this.checked"><span class="sw-t"></span></label>
            </div>
            <div class="srow"><span>Auto Next</span>
                <label class="sw"><input type="checkbox" id="chkAN"><span class="sw-t"></span></label>
            </div>
            <div class="srow" style="flex-direction:column;align-items:flex-start;gap:8px">
                <span>Speed</span>
                <div class="spds">
                    <button class="spd"    type="button" onclick="setSpd(0.5)">0.5×</button>
                    <button class="spd"    type="button" onclick="setSpd(0.75)">0.75×</button>
                    <button class="spd on" type="button" onclick="setSpd(1)">1×</button>
                    <button class="spd"    type="button" onclick="setSpd(1.5)">1.5×</button>
                    <button class="spd"    type="button" onclick="setSpd(2)">2×</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Teacher notice (teachers CAN seek freely) -->
    <div class="teacher-notice">
        <i class="fas fa-chalkboard-teacher"></i>
        <span><strong>Teacher view</strong> — Full seek and playback control enabled. Students cannot seek on first watch until 100% completion.</span>
    </div>

    <!-- INFO -->
    <div class="info-card">
        <div class="vid-title" id="lblVideoTitle" runat="server">Loading…</div>
        <div class="vid-meta">
            <div class="meta-chips">
                <span><i class="fas fa-eye"></i> <span id="liveViews" runat="server">0</span> student views</span>
                <span><i class="fas fa-user"></i> <span id="lblInstructor" runat="server">—</span></span>
                <span><i class="fas fa-calendar"></i> <span id="lblUploadDate" runat="server">—</span></span>
            </div>
            <div class="stars" id="starRating" runat="server"></div>
        </div>
        <div class="desc-wrap">
            <div class="desc-body clamp" id="descBody">
                <span id="lblDesc" runat="server" style="font-size:13px;color:var(--muted);line-height:1.7"></span>
            </div>
            <button type="button" class="btn-more" id="btnMore" onclick="toggleMore()">
                <i class="fas fa-chevron-down"></i> Show more
            </button>
            <div class="topics" id="topicsDiv">
                <asp:Repeater ID="rptTopics" runat="server">
                    <ItemTemplate>
                        <div class="t-row" onclick="jumpTo('<%# Eval("StartTime") %>')">
                            <span class="t-ts"><%# Eval("StartTime") %></span>
                            <span><%# Server.HtmlEncode(Eval("TopicTitle").ToString()) %></span>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>
    </div>

    <!-- STATS -->
    <div class="stats-strip">
        <div class="stat-b"><div class="sn" id="statViews"      runat="server">—</div><div class="sl">Student Views</div></div>
        <div class="stat-b"><div class="sn" id="statStudents"   runat="server">—</div><div class="sl">Unique Students</div></div>
        <div class="stat-b"><div class="sn" id="statCompletion" runat="server">—</div><div class="sl">Avg Completion</div></div>
        <div class="stat-b"><div class="sn" id="statComments"   runat="server">—</div><div class="sl">All Comments</div></div>
    </div>

    <!-- COMMENTS -->
    <div class="cmts-card">
        <div class="cmts-hdr">
            <div>
                <h5><i class="fas fa-comments me-2" style="color:var(--primary)"></i>Discussion</h5>
                <div class="cmt-count" id="cntBadge"></div>
            </div>
            <div class="cmt-filters">
                <button type="button" class="cf active" onclick="filterCmts('all',this)">All</button>
                <button type="button" class="cf" onclick="filterCmts('Student',this)">Students</button>
                <button type="button" class="cf" onclick="filterCmts('Teacher',this)">Teachers</button>
                <button type="button" class="cf" onclick="filterCmts('Admin',this)">Admins</button>
            </div>
        </div>

        <!-- New comment input -->
        <div class="new-cmt">
            <div class="av" id="teacherInitial" runat="server">T</div>
            <div class="cinput-wrap">
                <textarea id="txtCmt" class="ctxt" rows="2"
                    placeholder="Add a comment — visible to students, teachers, and admins…"
                    onfocus="this.rows=4" onblur="if(!this.value.trim())this.rows=2"></textarea>
                <div class="cmt-actions">
                    <button class="btn-cancel" type="button"
                            onclick="document.getElementById('txtCmt').value=''">Cancel</button>
                    <button class="btn-post" type="button" id="btnPost" onclick="postCmt()">
                        <i class="fas fa-paper-plane"></i> Comment
                    </button>
                </div>
            </div>
        </div>

        <!-- Comment list (JS rendered) -->
        <div id="cmtList">
            <div class="cmts-empty">
                <i class="fas fa-spinner fa-spin me-2"></i>Loading comments…
            </div>
        </div>
    </div>
</div><!-- /left -->

<!-- ═══ RIGHT ═══ -->
<div class="right-col">

    <!-- Playlist -->
    <div class="panel">
        <div class="ph"><h6><i class="fas fa-list me-2"></i>Playlist</h6><span class="badge-pill">Teacher View</span></div>
        <div class="pl-scroll">
            <asp:Repeater ID="rptPlaylist" runat="server">
                <ItemTemplate>
                    <div class='pli <%# Convert.ToInt32(Eval("VideoId"))==((LMS_Project.Teacher.TeacherVideoPlayer)Page).VideoId?"on":"" %>'
                         onclick="location='TeacherVideoPlayer.aspx?VideoId=<%# Eval("VideoId") %>'">
                        <div class="pl-thumb"><i class="fas fa-play"></i></div>
                        <div class="pli-info">
                            <strong><%# Server.HtmlEncode(Eval("Title").ToString()) %></strong>
                            <span><i class="fas fa-users me-1"></i><%# Eval("UniqueViews") %> students</span>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
        <div class="nav-btns">
            <asp:LinkButton ID="btnPrev" runat="server" CssClass="bn prev" OnClick="btnPrev_Click">
                <i class="fas fa-chevron-left"></i> Prev
            </asp:LinkButton>
            <asp:LinkButton ID="btnNext" runat="server" CssClass="bn next" OnClick="btnNext_Click">
                Next <i class="fas fa-chevron-right"></i>
            </asp:LinkButton>
        </div>
    </div>

    <!-- Rating -->
    <div class="panel">
        <div class="ph"><h6><i class="fas fa-star me-2" style="color:#f59e0b"></i>Instructor Rating</h6></div>
        <div class="rat-body">
            <div class="big-n" id="avgRatingVal" runat="server">—</div>
            <div class="stars" style="margin-top:6px" id="ratingStars" runat="server"></div>
            <div class="rat-sub" id="ratingCount" runat="server"></div>
        </div>
    </div>

    <!-- Student Progress -->
    <div class="panel">
        <div class="ph">
            <h6><i class="fas fa-users me-2"></i>Student Watch Progress</h6>
            <span class="badge-pill" id="engBadge"></span>
        </div>
        <div class="eng-list">
            <asp:Repeater ID="rptEngagement" runat="server">
                <ItemTemplate>
                    <div class="er">
                        <span class="en" title="<%# Server.HtmlEncode(Eval("UserName").ToString()) %>">
                            <%# Server.HtmlEncode(Eval("UserName").ToString()) %>
                        </span>
                        <div class="pt"><div class="pb" style="width:<%# Eval("WatchedPercent") %>%"></div></div>
                        <span class="ep"><%# Eval("WatchedPercent") %>%</span>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
    </div>

    <!-- AI Stats -->
    <div class="panel">
        <div class="ph"><h6><i class="fas fa-robot me-2"></i>AI Feature Usage</h6></div>
        <div class="ai-body">
            <asp:Repeater ID="rptAIStats" runat="server">
                <ItemTemplate>
                    <div class="air">
                        <span><%# Eval("Type") %></span>
                        <strong><%# Eval("UsageCount") %></strong>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
    </div>

</div><!-- /right -->
</div><!-- /grid -->
</div><!-- /wrap -->

<asp:HiddenField ID="hfVideoId"     runat="server" />
<asp:HiddenField ID="hfTeacherName" runat="server" />
<asp:HiddenField ID="hfSessionId"   runat="server" />
<div id="toast-root"></div>

<script>
/* ── State ── */
const vid = document.getElementById('videoPlayer');

/* ── Video path ── */
const path = '<%= VideoPath %>';
if (path) {
    const enc = path.split('/').map(s => encodeURIComponent(s)).join('/');
    document.getElementById('vpSrc').src = enc;
    vid.load();
}

const VID_ID  = parseInt('<%= VideoId %>') || 0;
const SESS_ID = parseInt(document.getElementById('<%= hfSessionId.ClientID %>').value) || 0;
const SKEY    = 'lms_tvpos_' + VID_ID;   // different prefix from admin to avoid collision
let ptimer = null, lastSec = -1, moreOpen = false;
let allCmts = [], activeFilter = 'all';

/* ── Toast ── */
function toast(msg, t) {
    const w = document.getElementById('toast-root');
    const d = document.createElement('div');
    d.className = 'toast ' + (t || 'inf');
    d.textContent = msg;
    w.appendChild(d);
    setTimeout(() => d.remove(), 4500);
}

/* ── Resume position ── */
vid.addEventListener('loadedmetadata', () => {
    const s = parseFloat(localStorage.getItem(SKEY) || 0);
    if (s > 5) { vid.currentTime = s; toast('Resumed from ' + fmt(s), 'inf'); }
});
vid.addEventListener('timeupdate', () => {
    if (!isNaN(vid.currentTime) && vid.currentTime > 1)
        localStorage.setItem(SKEY, vid.currentTime);
});

/* ── Progress tracking (saves every 10 s, same as admin) ── */
vid.addEventListener('play',  () => { clearInterval(ptimer); ptimer = setInterval(() => saveProg(false), 10000); });
vid.addEventListener('pause', () => clearInterval(ptimer));
vid.addEventListener('ended', () => {
    clearInterval(ptimer);
    localStorage.removeItem(SKEY);
    saveProg(true);
    if (document.getElementById('chkAN').checked) {
        const b = document.getElementById('<%= btnNext.ClientID %>');
        if (b && !b.disabled) b.click();
    }
});

function saveProg(force) {
    if (!vid.duration || vid.duration === 0) return;
    const ws  = force ? Math.floor(vid.duration) : Math.floor(vid.currentTime);
    const dur = Math.floor(vid.duration);
    if (ws === lastSec && !force) return;
    lastSec = ws;
    fetch('TeacherVideoPlayer.aspx/SaveProgress', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json;charset=utf-8' },
        body: JSON.stringify({ vid: VID_ID, watchedSec: ws, totalSec: dur })
    }).catch(() => {});
}

/* ── Seek / Jump ── */
function seek(d) { vid.currentTime = Math.max(0, Math.min(vid.duration || 0, vid.currentTime + d)); }
function jumpTo(ts) {
    const p = ts.split(':').map(Number); let s = 0;
    if (p.length === 2) s = p[0]*60 + p[1];
    else if (p.length === 3) s = p[0]*3600 + p[1]*60 + p[2];
    vid.currentTime = s; vid.play();
}
function fmt(s) { const m = Math.floor(s/60), sc = Math.floor(s%60); return m + ':' + (sc<10?'0':'') + sc; }

/* ── Settings ── */
function toggleSett() {
    const p = document.getElementById('settPanel');
    p.style.display = p.style.display === 'block' ? 'none' : 'block';
}
document.addEventListener('click', e => {
    if (!e.target.closest('.sett') && !e.target.closest('.vbtn'))
        document.getElementById('settPanel').style.display = 'none';
});
function setSpd(s) {
    vid.playbackRate = s;
    document.querySelectorAll('.spd').forEach(b =>
        b.classList.toggle('on', parseFloat(b.textContent) === s));
}

/* ── Screenshot ── */
function takeShot() {
    try {
        const c = document.createElement('canvas');
        c.width = vid.videoWidth; c.height = vid.videoHeight;
        c.getContext('2d').drawImage(vid, 0, 0);
        const a = document.createElement('a');
        a.href = c.toDataURL('image/png'); a.download = 'cap_' + Date.now() + '.png'; a.click();
        toast('Screenshot saved!', 'ok');
    } catch (e) { toast('Screenshot failed', 'err'); }
}

/* ── Show More / Topics ── */
function toggleMore() {
    moreOpen = !moreOpen;
    document.getElementById('descBody').className = 'desc-body ' + (moreOpen ? 'open' : 'clamp');
    document.getElementById('topicsDiv').className = 'topics' + (moreOpen ? ' open' : '');
    document.getElementById('btnMore').innerHTML =
        `<i class="fas fa-chevron-${moreOpen?'up':'down'}"></i> Show ${moreOpen?'less':'more'}`;
}

/* ── Helpers ── */
function esc(s) {
    return String(s || '')
        .replace(/&/g,'&amp;').replace(/</g,'&lt;')
        .replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

/* ════════════════════════════════════════════
   COMMENTS — identical render logic to admin
   ════════════════════════════════════════════ */
function avClass(role) {
    const r = (role || '').toLowerCase();
    if (r === 'student') return 'av-student';
    if (r === 'teacher') return 'av-teacher';
    if (r === 'admin' || r === 'superadmin') return 'av-admin';
    return 'av-other';
}
function roleBadge(role) {
    const r = (role || '').toLowerCase();
    let cls = 'rl-other', label = esc(role || 'User');
    if (r === 'student')                       { cls = 'rl-student'; label = 'Student'; }
    else if (r === 'teacher')                   { cls = 'rl-teacher'; label = 'Teacher'; }
    else if (r === 'admin' || r === 'superadmin') { cls = 'rl-admin'; label = 'Admin'; }
    return `<span class="c-rl ${cls}">${label}</span>`;
}
function renderOneCmt(c, isReply) {
    const ini    = (c.Username || '?').charAt(0).toUpperCase();
    const rowCls = isReply ? 'reply-row' : 'cmt-row';
    const repliesHtml = (!isReply && c.Replies && c.Replies.length)
        ? `<div class="replies-list">${c.Replies.map(r => renderOneCmt(r, true)).join('')}</div>` : '';
    const replyBoxHtml = !isReply ? `
        <div class="reply-box" id="rb-${c.CommentId}">
            <div class="reply-input-row">
                <textarea id="rt-${c.CommentId}" placeholder="Write a reply…"></textarea>
                <button class="btn-reply-post" type="button" onclick="postReply(${c.CommentId})">
                    <i class="fas fa-paper-plane"></i>
                </button>
            </div>
            <div style="display:flex;justify-content:flex-end;margin-top:4px">
                <button class="btn-reply-cancel" type="button" onclick="toggleRep(${c.CommentId})">Cancel</button>
            </div>
        </div>` : '';
    const actionHtml = !isReply ? `
        <div class="c-meta">
            <button class="btn-rep" type="button" onclick="toggleRep(${c.CommentId})">
                <i class="fas fa-reply"></i>
                Reply${c.ReplyCount > 0 ? ' (' + c.ReplyCount + ')' : ''}
            </button>
            <button class="btn-del" type="button" onclick="delCmt(${c.CommentId})">
                <i class="fas fa-trash"></i> Delete
            </button>
        </div>` : '';
    return `
<div class="${rowCls}" id="ci-${c.CommentId}" data-role="${esc(c.Role || '')}">
    <div class="c-av ${avClass(c.Role)}">${ini}</div>
    <div class="cmt-body">
        <div class="cmt-top">
            <span class="c-nm">${esc(c.Username || 'Unknown')}</span>
            ${roleBadge(c.Role)}
            <span class="c-ts">${esc(c.CommentedOn || '')}</span>
        </div>
        <div class="c-tx">${esc(c.Comment || '')}</div>
        ${actionHtml}${replyBoxHtml}${repliesHtml}
    </div>
</div>`;
}

function filterCmts(role, btn) {
    activeFilter = role;
    document.querySelectorAll('.cf').forEach(b => b.classList.remove('active'));
    btn.classList.add('active');
    renderCmts(allCmts);
}

function loadCmts() {
    fetch('TeacherVideoPlayer.aspx/GetComments', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json;charset=utf-8' },
        body: JSON.stringify({ vid: VID_ID, sessId: SESS_ID })
    })
    .then(r => r.json())
    .then(res => {
        allCmts = typeof res.d === 'string' ? JSON.parse(res.d) : (res.d || []);
        renderCmts(allCmts);
    })
    .catch(() => toast('Failed to load comments', 'err'));
}

function renderCmts(data) {
    const list  = document.getElementById('cmtList');
    const badge = document.getElementById('cntBadge');
    const filtered = activeFilter === 'all'
        ? data
        : data.filter(c => (c.Role || '').toLowerCase() === activeFilter.toLowerCase());

    if (badge) badge.textContent =
        '(' + data.length + ' total' +
        (filtered.length !== data.length ? ', ' + filtered.length + ' shown' : '') + ')';

    const stat = document.getElementById('<%= statComments.ClientID %>');
    if (stat) stat.textContent = data.length;

    if (!filtered.length) {
        list.innerHTML = `<div class="cmts-empty">
            <i class="fas fa-comments" style="font-size:2rem;opacity:.2;display:block;margin-bottom:8px"></i>
            No ${activeFilter === 'all' ? '' : activeFilter + ' '}comments yet.
        </div>`;
        return;
    }
    list.innerHTML = filtered.map(c => renderOneCmt(c, false)).join('');
}

function toggleRep(id) {
    const rb = document.getElementById('rb-' + id);
    if (!rb) return;
    rb.classList.toggle('open');
    if (rb.classList.contains('open')) document.getElementById('rt-' + id)?.focus();
}

function postReply(parentId) {
    const t = (document.getElementById('rt-' + parentId)?.value || '').trim();
    if (!t) { toast('Please type a reply', 'err'); return; }
    fetch('TeacherVideoPlayer.aspx/AddReply', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json;charset=utf-8' },
        body: JSON.stringify({ vid: VID_ID, parentId, msg: t, sessId: SESS_ID })
    })
    .then(r => r.json())
    .then(() => { loadCmts(); toast('Reply posted!', 'ok'); })
    .catch(() => toast('Failed to post reply', 'err'));
}

function postCmt() {
    const box = document.getElementById('txtCmt');
    const msg = (box.value || '').trim();
    if (!msg) { toast('Please type a comment', 'err'); return; }
    const btn = document.getElementById('btnPost');
    btn.disabled = true;
    fetch('TeacherVideoPlayer.aspx/AddComment', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json;charset=utf-8' },
        body: JSON.stringify({ vid: VID_ID, msg, sessId: SESS_ID })
    })
    .then(r => r.json())
    .then(() => { box.value = ''; loadCmts(); toast('Comment posted!', 'ok'); })
    .catch(() => toast('Failed', 'err'))
    .finally(() => btn.disabled = false);
}

function delCmt(id) {
    if (!confirm('Delete this comment and its replies?')) return;
    fetch('TeacherVideoPlayer.aspx/DeleteCommentAjax', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json;charset=utf-8' },
        body: JSON.stringify({ commentId: id, sessId: SESS_ID })
    })
    .then(() => { loadCmts(); toast('Deleted', 'ok'); })
    .catch(() => toast('Failed', 'err'));
}

/* ── Init ── */
document.addEventListener('DOMContentLoaded', () => {
    loadCmts();

    // Set teacher avatar initial
    const tn = document.getElementById('<%= hfTeacherName.ClientID %>');
    const ti = document.getElementById('<%= teacherInitial.ClientID %>');
    if (tn && ti && tn.value) ti.textContent = tn.value.charAt(0).toUpperCase();

    // Engagement badge
    const rows = document.querySelectorAll('.er');
    const eb = document.getElementById('engBadge');
    if (eb) eb.textContent = rows.length + ' student' + (rows.length !== 1 ? 's' : '');
});

    /* ── Keyboard shortcuts ── */
    document.addEventListener('keydown', e => {
        if (['INPUT', 'TEXTAREA'].includes(document.activeElement?.tagName)) return;
        if (e.key === 'ArrowLeft') seek(-10);
        if (e.key === 'ArrowRight') seek(10);
        if (e.key === ' ') { e.preventDefault(); vid.paused ? vid.play() : vid.pause(); }
    });
</script>
</asp:Content>
