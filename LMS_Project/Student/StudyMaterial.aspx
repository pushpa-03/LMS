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
                                     data-vid='<%# Eval("VideoId") %>'
                                     data-title='<%# HttpUtility.HtmlAttributeEncode(Eval("Title")?.ToString()) %>'
                                     data-desc='<%# HttpUtility.HtmlAttributeEncode(Eval("Description")?.ToString() ?? "") %>'
                                     data-instr='<%# HttpUtility.HtmlAttributeEncode(Eval("InstructorName")?.ToString()) %>'
                                     data-path='<%# HttpUtility.HtmlAttributeEncode(Eval("VideoPath")?.ToString()) %>'
                                     data-views='<%# Eval("ViewCount") ?? 0 %>'
                                     onclick="selectVideoEl(this)">
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
                   <video id="vp" controls controlsList="nodownload" preload="metadata"
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

<script>
    /* ─── GLOBALS ─────────────────────────────────────────────────────────── */
    const AI_URL = 'http://localhost:8000';
    const vp = document.getElementById('vp');

    let curVid = 0, curVName = '', curMatPath = '';
    let completed = false, lastPos = 0, myRating = 0;
    let autoNext = false, ccOn = false, cmtFilter = 'all';
    let captTopics = [];
    let progTimer = null, notesTimer = null, matNotesTimer = null, engTimer = null;

    /* ─── HIDDEN FIELD READERS ────────────────────────────────────────────── */
    const hfSess = () => document.getElementById('<%= hfSessionId.ClientID %>').value;
    const hfSubj = () => document.getElementById('<%= hfSubjectId.ClientID %>').value;

    /* ─── INIT ────────────────────────────────────────────────────────────── */
    document.addEventListener('DOMContentLoaded', () => {
        loadOverallProgress();
        const saved = localStorage.getItem('lv_' + hfSubj());
        if (saved) {
            try { const d = JSON.parse(saved); const el = document.getElementById('vi_' + d.id); if (el) el.click(); } catch (_) { }
        }
    });

    /* ─── CHAPTER ACCORDION ───────────────────────────────────────────────── */
    function toggleCh(btn, bodyId) {
        const body = document.getElementById(bodyId);
        const wasOpen = body.classList.contains('open');
        document.querySelectorAll('.ch-body').forEach(b => b.classList.remove('open'));
        document.querySelectorAll('.ch-toggle').forEach(b => b.classList.remove('open'));
        if (!wasOpen) { body.classList.add('open'); btn.classList.add('open'); }
    }

    /* ─── VIDEO SELECTION ─────────────────────────────────────────────────── */
    function selectVideoEl(el) {
        selectVideo(+el.dataset.vid, el.dataset.title||'', el.dataset.desc||'',
            el.dataset.instr||'', el.dataset.path||'', +el.dataset.views||0, el);
    }

    function selectVideo(vid, title, desc, instr, path, views, el) {
        document.querySelectorAll('.ci').forEach(c => c.classList.remove('active'));
        el.classList.add('active');
        curVid = vid; curVName = title;

        $('dVideo'); $$('dMat'); $$('dPrompt');
        setText('vTitle', title); setText('vInstr', instr||'—');
        setText('vDesc', desc||''); setText('vViews', views||'0');

        // Reset AI panel on new video
        const res = document.getElementById('aiResult');
        res.className = 'ai-result dim';
        res.innerText = 'Select an action or ask a question above…';
        document.getElementById('aiInput').value = '';

        const encodedPath = path.split('/').map(s => encodeURIComponent(s)).join('/');
        document.getElementById('vpSrc').src = encodedPath;
        vp.load();
        vp.addEventListener('canplay', function cp() {
            vp.removeEventListener('canplay', cp);
            vp.play().catch(e => console.warn('Autoplay blocked:', e));
        }, { once: true });

        localStorage.setItem('lv_' + hfSubj(), JSON.stringify({ id: vid, title, path }));

        const hfT = document.getElementById('<%= hfTopicVideoId.ClientID %>');
        if (hfT) { hfT.value = String(vid); __doPostBack('<%= hfTopicVideoId.ClientID %>', ''); }

        ajPost('StudyMaterial.aspx/GetVideoStatus', { videoId: vid, sessionId: +hfSess() })
            .then(d => {
                completed = !!(d && d.IsCompleted); lastPos = (d && d.LastPosition) || 0;
                document.getElementById('btnFwd').disabled = !completed;
                if (!completed) {
                    const ov = document.getElementById('ovSkip');
                    ov.classList.remove('hidden'); setTimeout(() => ov.classList.add('hidden'), 3500);
                }
                if (lastPos > 3) vp.addEventListener('loadedmetadata', () => { vp.currentTime = lastPos; }, { once: true });
                updateWpFill(lastPos, vp.duration || 0);
            }).catch(() => { completed = false; lastPos = 0; });

        let viewTracked = false;
        const trackFn = () => {
            if (!viewTracked && vp.currentTime > 10) {
                viewTracked = true;
                ajPost('StudyMaterial.aspx/TrackView', { videoId: vid, sessionId: +hfSess() }).catch(() => { });
                vp.removeEventListener('timeupdate', trackFn);
            }
        };
        vp.addEventListener('timeupdate', trackFn);

        loadVStats(vid); loadRating(vid); loadComments(vid);
        loadNotes(vid); loadOverallProgress(); startEngagement(); startProgSave();
    }

    /* ─── VIDEO EVENTS ────────────────────────────────────────────────────── */
    vp.addEventListener('seeking', () => {
        if (!completed && vp.currentTime > lastPos + 1.5) { vp.currentTime = lastPos; flashSkipBanner(); }
    });
    vp.addEventListener('timeupdate', () => {
        if (!vp.duration) return;
        const pct = (vp.currentTime / vp.duration) * 100;
        updateWpFill(vp.currentTime, vp.duration);
        setText('pCurrent', Math.round(pct) + '%'); setText('pCurrentLbl', curVName || '—');
        setWidth('fCurrent', pct);
        if (!completed && vp.currentTime > lastPos) lastPos = vp.currentTime;
        if (pct >= 95 && !completed) { completed = true; document.getElementById('btnFwd').disabled = false; markComplete(); }
        if (ccOn) updateCC(vp.currentTime);
    });
    vp.addEventListener('ended', () => {
        markComplete(); const d = document.getElementById('vd_' + curVid); if (d) d.classList.add('show');
        if (autoNext) playNext(); loadOverallProgress(); stopProgSave();
    });
    vp.addEventListener('pause', () => saveProgress());

    function updateWpFill(pos, dur) { if (!dur) return; setWidth('wpFill', Math.min((pos / dur) * 100, 100)); }
    function flashSkipBanner() {
        const ov = document.getElementById('ovSkip'); ov.classList.remove('hidden');
        setTimeout(() => ov.classList.add('hidden'), 2200);
    }

    /* ─── PROGRESS SAVE ───────────────────────────────────────────────────── */
    function startProgSave() { stopProgSave(); progTimer = setInterval(saveProgress, 15000); }
    function stopProgSave() { clearInterval(progTimer); }
    function saveProgress() {
        if (!curVid || !vp.duration) return;
        ajPost('StudyMaterial.aspx/SaveProgress', {
            videoId: curVid, sessionId: +hfSess(),
            position: Math.floor(vp.currentTime),
            percentage: Math.round((vp.currentTime / vp.duration) * 100),
            isCompleted: completed
        }).catch(() => { });
    }
    function markComplete() {
        if (!curVid) return;
        ajPost('StudyMaterial.aspx/MarkComplete', { videoId: curVid, sessionId: +hfSess() })
            .then(() => { const d = document.getElementById('vd_' + curVid); if (d) d.classList.add('show'); loadOverallProgress(); })
            .catch(() => { });
    }

    /* ─── VIDEO CONTROLS ──────────────────────────────────────────────────── */
    function vSkip(sec) { if (sec > 0 && !completed) { flashSkipBanner(); return; } vp.currentTime = Math.max(0, vp.currentTime + sec); }
    function toggleLoop(btn) { vp.loop = !vp.loop; btn.classList.toggle('on', vp.loop); if (vp.loop) { autoNext = false; document.getElementById('btnAuto').classList.remove('on'); } }
    function toggleAuto(btn) { autoNext = !autoNext; btn.classList.toggle('on', autoNext); if (autoNext) { vp.loop = false; document.getElementById('btnLoop').classList.remove('on'); } }
    function toggleCC(btn) { ccOn = !ccOn; btn.classList.toggle('on', ccOn); const bar = document.getElementById('capBar'); bar.classList.toggle('show', ccOn); if (!ccOn) bar.innerText = ''; }
    function doPiP() { if (document.pictureInPictureElement) document.exitPictureInPicture(); else vp.requestPictureInPicture().catch(() => alert('PiP not supported.')); }
    function doFS() { const w = document.getElementById('vpWrap'); if (document.fullscreenElement) document.exitFullscreen(); else w.requestFullscreen(); }
    function doShot() {
        const c = document.createElement('canvas'); c.width = vp.videoWidth; c.height = vp.videoHeight;
        c.getContext('2d').drawImage(vp, 0, 0);
        const fl = document.getElementById('ssFlash'); fl.style.opacity = '.9'; setTimeout(() => fl.style.opacity = '0', 120);
        const a = document.createElement('a'); a.download = 'screenshot_' + Date.now() + '.png'; a.href = c.toDataURL(); a.click();
    }

    /* ─── LIVE CAPTIONS ───────────────────────────────────────────────────── */
    function updateCC(t) {
        const bar = document.getElementById('capBar'); let cur = '';
        captTopics.forEach(tp => { if (t >= toSecs(tp.time)) cur = tp.title; });
        bar.innerText = cur;
    }
    function toSecs(s) {
        const p = (s || '').split(':').map(Number);
        return p.length === 3 ? p[0] * 3600 + p[1] * 60 + p[2] : p.length === 2 ? p[0] * 60 + p[1] : +p[0] || 0;
    }

    /* ─── TOPICS ──────────────────────────────────────────────────────────── */
    function renderTopics() {
        captTopics = []; const list = document.getElementById('topicsList'); const strip = document.getElementById('topicsStrip');
        if (!list) return; list.innerHTML = '';
        document.querySelectorAll('.tdata').forEach(el => {
            const t = el.dataset.time, title = el.dataset.title; if (!t || !title) return;
            captTopics.push({ time: t, title });
            const div = document.createElement('div'); div.className = 'topic-row';
            div.innerHTML = '<span class="ttm" onclick="jumpTo(\'' + esc(t) + '\')">' + esc(t) + '</span>' + esc(title);
            list.appendChild(div);
        });
        strip.style.display = list.children.length ? 'block' : 'none';
    }
    if (typeof Sys !== 'undefined') Sys.WebForms.PageRequestManager.getInstance().add_endRequest(renderTopics);
    function jumpTo(ts) { vp.currentTime = toSecs(ts); vp.play(); }

    /* ─── ENGAGEMENT ──────────────────────────────────────────────────────── */
    const EQ = [
        { q: "Are you still watching?", o: ["Yes, I'm watching", "Checking phone", "Browsing other tabs", "Taking a break"], c: 0 },
        { q: "Quick check — click 'Watching' to continue.", o: ["Watching", "Distracted", "Almost asleep", "Away from screen"], c: 0 },
    ];
    function startEngagement() { clearInterval(engTimer); engTimer = setInterval(() => { if (!vp.paused && !vp.ended) showEngagement(); }, 120000); }
    function showEngagement() {
        vp.pause(); const q = EQ[Math.floor(Math.random() * EQ.length)];
        const ov = document.getElementById('ovEngage'); document.getElementById('engQ').innerText = q.q;
        const oEl = document.getElementById('engOpts'); oEl.innerHTML = '';
        q.o.forEach((opt, i) => {
            const b = document.createElement('button'); b.type = 'button'; b.className = 'engage-opt'; b.innerText = opt;
            b.onclick = () => {
                oEl.querySelectorAll('.engage-opt').forEach(x => x.onclick = null);
                if (i === q.c) { b.classList.add('correct'); setTimeout(() => { ov.classList.remove('show'); vp.play(); }, 700); }
                else { b.classList.add('wrong'); if (oEl.children[q.c]) oEl.children[q.c].classList.add('correct'); setTimeout(() => { ov.classList.remove('show'); vp.play(); }, 1500); }
            };
            oEl.appendChild(b);
        });
        ov.classList.add('show');
    }

    /* ─── AUTO NEXT ───────────────────────────────────────────────────────── */
    function playNext() {
        const all = [...document.querySelectorAll('.ci')]; const idx = all.findIndex(e => e.classList.contains('active'));
        if (idx >= 0 && idx < all.length - 1) all[idx + 1].click();
    }

    /* ─── STATS / RATING ──────────────────────────────────────────────────── */
    function loadVStats(vid) {
        ajPost('StudyMaterial.aspx/GetVideoStats', { videoId: vid, sessionId: +hfSess() })
            .then(d => { if (!d) return; setText('vViews', d.TotalViews || 0); setText('vUniq', d.UniqueStudents || 0); }).catch(() => { });
    }
    function loadRating(vid) {
        ajPost('StudyMaterial.aspx/GetRating', { videoId: vid, sessionId: +hfSess() })
            .then(d => {
                if (!d) return; myRating = d.MyRating || 0; renderStars(myRating);
                document.getElementById('ratingInfo').innerText = d.AvgRating ? d.AvgRating.toFixed(1) + ' (' + d.TotalRatings + ' ratings)' : 'No ratings yet';
            }).catch(() => { });
    }
    function renderStars(val) { document.querySelectorAll('#starRow .star').forEach(s => s.classList.toggle('on', +s.dataset.v <= val)); }
    function starHover(v) { document.querySelectorAll('#starRow .star').forEach(s => s.classList.toggle('hover', +s.dataset.v <= v)); }
    function starOut() { document.querySelectorAll('#starRow .star').forEach(s => s.classList.remove('hover')); renderStars(myRating); }
    function doRate(v) {
        if (!curVid) return; myRating = v; renderStars(v);
        ajPost('StudyMaterial.aspx/SaveRating', { videoId: curVid, sessionId: +hfSess(), rating: v }).then(() => loadRating(curVid)).catch(() => { });
    }

    /* ─── OVERALL PROGRESS ────────────────────────────────────────────────── */
    function loadOverallProgress() {
        ajPost('StudyMaterial.aspx/GetProgress', { subjectId: +hfSubj(), sessionId: +hfSess() })
            .then(raw => {
                const d = typeof raw === 'string' ? JSON.parse(raw) : raw; if (!d || d.error) return;
                const pct = d.TotalCount > 0 ? Math.round(d.WatchedCount / d.TotalCount * 100) : 0;
                const spct = d.TotalChapters > 0 ? Math.round(d.CompletedChapters / d.TotalChapters * 100) : 0;
                setText('pOverall', pct + '%'); setWidth('fOverall', pct);
                setText('pWatched', d.WatchedCount); setText('pWatchedSub', 'of ' + d.TotalCount + ' total');
                setText('pSyllabus', spct + '%'); setWidth('fSyllabus', spct);
                (d.ChapterProgress || []).forEach(cp => {
                    const bar = document.getElementById('cpb_' + cp.ChapterId);
                    const lbl = document.querySelector('.ch-pct-lbl[data-cid="' + cp.ChapterId + '"]');
                    if (bar) bar.style.width = cp.Pct + '%'; if (lbl) lbl.innerText = cp.Pct + '%';
                });
                (d.CompletedVideoIds || []).forEach(id => { const el = document.getElementById('vd_' + id); if (el) el.classList.add('show'); });
            }).catch(() => { });
    }
    function loadProgressDetail() {
        ajPost('StudyMaterial.aspx/GetProgress', { subjectId: +hfSubj(), sessionId: +hfSess() })
            .then(raw => {
                const d = typeof raw === 'string' ? JSON.parse(raw) : raw; if (!d || d.error) return;
                let h = '<div style="display:grid;grid-template-columns:1fr 1fr;gap:10px;margin-bottom:14px">'
                    + '<div class="prog-card"><div class="pc-lbl">Videos</div><div class="pc-val">' + d.WatchedCount + '/' + d.TotalCount + '</div></div>'
                    + '<div class="prog-card"><div class="pc-lbl">Chapters Done</div><div class="pc-val">' + d.CompletedChapters + '/' + d.TotalChapters + '</div></div></div>'
                    + '<div style="font-size:10px;font-weight:700;text-transform:uppercase;letter-spacing:.05em;color:var(--muted);margin-bottom:8px">Chapter Breakdown</div>';
                (d.ChapterProgress || []).forEach(cp => {
                    h += '<div style="margin-bottom:9px"><div style="display:flex;justify-content:space-between;font-size:13px;margin-bottom:3px">'
                        + '<span style="font-weight:600">' + esc(cp.ChapterName) + '</span>'
                        + '<span style="color:var(--muted)">' + cp.WatchedVideos + '/' + cp.TotalVideos + ' videos</span></div>'
                        + '<div class="prog-bar"><div class="prog-fill" style="width:' + cp.Pct + '%"></div></div></div>';
                });
                setHtml('progDetail', h);
            }).catch(() => { });
    }

    /* ════════════════════════════════════════════════════════════════════════
       VIDEO AI  —  all POST JSON body,  server returns { result: "..." }
    ════════════════════════════════════════════════════════════════════════ */
    function aiAct(type) {
        if (!curVName) { setAI('⚠ Please select a video first.'); return; }
        const res = document.getElementById('aiResult');
        res.className = 'ai-result typing';
        res.style.fontFamily = '';  // reset font; mindmap sets monospace
        const labels = { summary: 'Summarising…', notes: 'Generating notes…', quiz: 'Creating quiz…', mindmap: 'Building mind map…' };
        res.innerText = labels[type] || 'Generating…';

        fetch(AI_URL + '/generate-' + type, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ video_name: curVName })
        })
            .then(r => {
                if (!r.ok) return r.json().then(e => { throw new Error(e.detail || ('HTTP ' + r.status)); });
                return r.json();
            })
            .then(d => {
                const txt = d.result || d.error || JSON.stringify(d);
                setAI(txt, type);
                saveAIHist(type.charAt(0).toUpperCase() + type.slice(1) + ' — ' + curVName, txt);
            })
            .catch(err => setAI('⚠ AI error: ' + err.message + '\n\nMake sure:\n1. Ollama is running\n2. Server is on port 8000\n3. phi3 model is downloaded'));
    }

    function askAI() {
        const q = document.getElementById('aiInput').value.trim();
        if (!q) return;
        if (!curVName) { setAI('⚠ Please select a video first.'); return; }
        const res = document.getElementById('aiResult');
        res.className = 'ai-result typing'; res.style.fontFamily = ''; res.innerText = '';

        fetch(AI_URL + '/ask-ai?video_name=' + encodeURIComponent(curVName) + '&question=' + encodeURIComponent(q))
            .then(r => {
                if (!r.ok) throw new Error('HTTP ' + r.status);
                const reader = r.body.getReader(), dec = new TextDecoder();
                let txt = ''; res.className = 'ai-result';
                (function pump() {
                    reader.read().then(({ done, value }) => {
                        if (done) { saveAIHist(q, txt); return; }
                        txt += dec.decode(value); res.innerText = txt; pump();
                    });
                })();
            }).catch(err => setAI('⚠ ' + err.message));
    }

    /**
     * setAI — renders AI result text with proper styling.
     * type = 'mindmap' → monospace font so tree chars align.
     */
    function setAI(txt, type) {
        const r = document.getElementById('aiResult');
        r.className = 'ai-result';
        r.style.fontFamily = (type === 'mindmap') ? '"Courier New", Courier, monospace' : '';
        r.innerText = txt;   // innerText preserves whitespace/newlines correctly
    }

    function saveAIHist(q, a) {
        if (!curVid) return;
        ajPost('StudyMaterial.aspx/SaveAIHistory',
            { videoId: curVid, sessionId: +hfSess(), question: q, answer: a }).catch(() => { });
    }

    /* ─── AI HISTORY — full answer, no truncation ─────────────────────────── */
    function toggleHist() {
        const body = document.getElementById('histBody');
        const chev = document.getElementById('histChev');
        const open = body.classList.toggle('open');
        chev.className = open ? 'fas fa-chevron-up' : 'fas fa-chevron-down';
        if (open && curVid) loadAIHistory();
    }

    function loadAIHistory() {
        const el = document.getElementById('histList');
        el.innerHTML = '<div style="padding:8px 13px;font-size:12px;color:var(--dim)">Loading…</div>';
        ajPost('StudyMaterial.aspx/GetAIHistory', { videoId: curVid, sessionId: +hfSess() })
            .then(raw => {
                const d = typeof raw === 'string' ? JSON.parse(raw) : raw;
                if (!Array.isArray(d) || !d.length) {
                    el.innerHTML = '<div style="padding:8px 13px;font-size:12px;color:var(--dim)">No history yet.</div>'; return;
                }
                el.innerHTML = d.map((h, idx) => {
                    const isMindmap = (h.Question || '').toLowerCase().includes('mindmap') || (h.Question || '').toLowerCase().includes('mind map');
                    const ansFont = isMindmap ? '"Courier New",monospace' : 'inherit';
                    return `
                    <div class="hist-item">
                        <div class="hi-q">
                            <i class="fas fa-question-circle me-1"></i>${esc(h.Question)}
                        </div>
                        <div class="hi-a" style="font-family:${ansFont};white-space:pre-wrap;margin-top:6px;
                             max-height:400px;overflow-y:auto;font-size:12px;line-height:1.6">
                            ${esc(h.Answer || '')}
                        </div>
                        <div class="hi-t" style="margin-top:5px">
                            <i class="fas fa-clock me-1"></i>${h.CreatedOn}
                            <button type="button" onclick="copyHistItem(this)"
                                data-text="${h.Answer ? h.Answer.replace(/"/g, '&quot;') : ''}"
                                style="margin-left:10px;background:none;border:1px solid var(--purple);
                                       color:var(--purple);border-radius:5px;padding:1px 8px;
                                       font-size:10px;cursor:pointer;font-family:var(--f)">
                                <i class="fas fa-copy me-1"></i>Copy
                            </button>
                        </div>
                    </div>`;
                }).join('');
            }).catch(() => {
                el.innerHTML = '<div style="padding:8px 13px;font-size:12px;color:var(--dim)">Failed to load history.</div>';
            });
    }

    function copyHistItem(btn) {
        const text = btn.getAttribute('data-text') || '';
        navigator.clipboard.writeText(text).then(() => {
            btn.innerText = '✓ Copied'; setTimeout(() => { btn.innerHTML = '<i class="fas fa-copy me-1"></i>Copy'; }, 2000);
        }).catch(() => { });
    }

    /* ─── COMMENTS ────────────────────────────────────────────────────────── */
    function loadComments(vid) {
        const v = vid || curVid; if (!v) return;
        ajPost('StudyMaterial.aspx/GetComments', { videoId: v, sessionId: +hfSess() })
            .then(raw => { const d = typeof raw === 'string' ? JSON.parse(raw) : raw; renderCmts(Array.isArray(d) ? d : []); }).catch(() => { });
    }
    function renderCmts(data) {
        const list = document.getElementById('cmtList');
        const items = cmtFilter === 'all' ? data : data.filter(c => (c.Role || '').toLowerCase().includes(cmtFilter));
        list.innerHTML = items.length ? items.map(c => renderOneCmt(c)).join('') : '<div style="padding:12px;color:var(--dim);font-size:12px">No comments yet.</div>';
    }
    function renderOneCmt(c) {
        const cls = ({ student: 'rl-s', teacher: 'rl-t', admin: 'rl-a' })[(c.Role || '').toLowerCase()] || 'rl-s';
        const av = c.Role === 'Teacher' ? '#2e7d32' : c.Role === 'Admin' ? '#c62828' : '#1565c0';
        const ini = (c.FullName || c.Username || '?').charAt(0).toUpperCase();
        const reps = c.Replies && c.Replies.length ? '<div class="replies">' + c.Replies.map(r => renderOneCmt(r)).join('') + '</div>' : '';
        return '<div class="cmt" data-role="' + (c.Role || '').toLowerCase() + '">'
            + '<div class="c-av" style="background:' + av + '">' + ini + '</div>'
            + '<div style="flex:1;min-width:0"><span class="c-nm">' + esc(c.FullName || c.Username) + '</span>'
            + '<span class="c-rl ' + cls + '">' + (c.Role || 'Student') + '</span>'
            + '<div class="c-tx">' + esc(c.CommentText) + '</div>'
            + '<div class="c-mt"><span>' + c.CreatedOn + '</span>'
            + '<button type="button" class="rb" onclick="toggleReply(' + c.CommentId + ')"><i class="fas fa-reply me-1"></i>Reply</button></div>'
            + '<div id="rbox_' + c.CommentId + '" style="display:none;margin-top:7px">'
            + '<div class="cmt-input-row"><textarea id="rtxt_' + c.CommentId + '" placeholder="Write a reply…" style="height:46px"></textarea>'
            + '<button type="button" class="post-btn" onclick="postReply(' + c.CommentId + ')" style="padding:7px 11px"><i class="fas fa-paper-plane"></i></button></div></div>'
            + reps + '</div></div>';
    }
    function toggleReply(id) { const b = document.getElementById('rbox_' + id); if (b) b.style.display = b.style.display === 'none' ? 'block' : 'none'; }
    function postCmt() {
        const txt = document.getElementById('cmtTxt').value.trim(); if (!txt || !curVid) return;
        ajPost('StudyMaterial.aspx/PostComment', { videoId: curVid, sessionId: +hfSess(), commentText: txt, parentId: null })
            .then(() => { document.getElementById('cmtTxt').value = ''; loadComments(); }).catch(() => { });
    }
    function postReply(pid) {
        const el = document.getElementById('rtxt_' + pid); const txt = el ? el.value.trim() : ''; if (!txt || !curVid) return;
        ajPost('StudyMaterial.aspx/PostComment', { videoId: curVid, sessionId: +hfSess(), commentText: txt, parentId: pid })
            .then(() => loadComments()).catch(() => { });
    }
    function filterCmt(role, btn) {
        cmtFilter = role; document.querySelectorAll('.cf-btn').forEach(b => b.classList.remove('on')); btn.classList.add('on'); loadComments();
    }

    /* ─── VIDEO NOTES ─────────────────────────────────────────────────────── */
    function loadNotes(vid) {
        ajPost('StudyMaterial.aspx/GetNotes', { videoId: vid, sessionId: +hfSess() })
            .then(raw => {
                const d = typeof raw === 'string' ? JSON.parse(raw) : raw;
                document.getElementById('notesEd').innerHTML = (d && d.Content) || '';
                setText('nSt', d && d.Content ? 'Last saved: ' + (d.UpdatedOn || '') : 'No notes saved yet');
            }).catch(() => { });
    }
    function saveNotes() {
        if (!curVid) return;
        ajPost('StudyMaterial.aspx/SaveNotes', { videoId: curVid, sessionId: +hfSess(), content: document.getElementById('notesEd').innerHTML })
            .then(() => setText('nSt', 'Saved at ' + new Date().toLocaleTimeString())).catch(() => { });
    }
    function onNoteInput() { setText('nSt', 'Unsaved changes…'); clearTimeout(notesTimer); notesTimer = setTimeout(saveNotes, 3000); }
    function fmt(cmd, val) { document.getElementById('notesEd').focus(); document.execCommand(cmd, false, val || null); }
    function insertTbl() {
        const r = prompt('Rows:', '3'), c = prompt('Columns:', '3'); if (!r || !c) return;
        let t = '<table border="1" style="border-collapse:collapse;width:100%;margin:7px 0">';
        for (let i = 0; i < +r; i++) { t += '<tr>'; for (let j = 0; j < +c; j++)t += '<td style="padding:5px;border:1px solid #ccc">&nbsp;</td>'; t += '</tr>'; }
        t += '</table><br>'; document.getElementById('notesEd').focus(); document.execCommand('insertHTML', false, t);
    }
    function insertImg() {
        const u = prompt('Image URL:'); if (u) { document.getElementById('notesEd').focus(); document.execCommand('insertHTML', false, '<img src="' + u + '" style="max-width:100%;border-radius:7px;margin:7px 0">'); }
    }
    function clearNotes() { if (confirm('Clear all notes?')) { document.getElementById('notesEd').innerHTML = ''; onNoteInput(); } }

    /* ─── MATERIAL SELECTION ──────────────────────────────────────────────── */
    function selectMat(title, path, fileType, el) {
        document.querySelectorAll('.ci').forEach(c => c.classList.remove('active')); el.classList.add('active');
        curMatPath = path; $('dMat'); $$('dVideo'); $$('dPrompt');
        setText('matTitle', title); setText('matName', title); setText('matMeta', 'Type: ' + fileType);
        document.getElementById('matLink').href = path;

        // Reset AI
        const mr = document.getElementById('matAiRes'); mr.className = 'ai-result dim';
        mr.style.fontFamily = ''; mr.innerText = 'Select an action or ask a question above…';
        document.getElementById('matAiInput').value = '';

        const emb = document.getElementById('matEmbedArea'), fall = document.getElementById('matFallback');
        const ext = (fileType || '').toLowerCase().replace('.', '');
        emb.innerHTML = '';
        if (ext === 'pdf') { emb.innerHTML = '<iframe class="mat-embed-frame" src="' + path + '"></iframe>'; emb.style.display = 'block'; fall.style.display = 'none'; }
        else if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'svg'].includes(ext)) { emb.innerHTML = '<div style="padding:18px;text-align:center"><img src="' + path + '" style="max-width:100%;border-radius:8px;max-height:480px"></div>'; emb.style.display = 'block'; fall.style.display = 'none'; }
        else if (['mp4', 'webm'].includes(ext)) { emb.innerHTML = '<video controls style="width:100%"><source src="' + path + '"></video>'; emb.style.display = 'block'; fall.style.display = 'none'; }
        else if (['doc', 'docx', 'ppt', 'pptx', 'xls', 'xlsx'].includes(ext)) { const full = window.location.origin + '/' + path.replace(/^\//, ''); emb.innerHTML = '<iframe class="mat-embed-frame" src="https://docs.google.com/viewer?url=' + encodeURIComponent(full) + '&embedded=true"></iframe>'; emb.style.display = 'block'; fall.style.display = 'none'; }
        else { emb.style.display = 'none'; fall.style.display = 'block'; }

        const icons = { pdf: 'fa-file-pdf #c62828', doc: 'fa-file-word #1565c0', docx: 'fa-file-word #1565c0', ppt: 'fa-file-powerpoint #e65100', pptx: 'fa-file-powerpoint #e65100', xls: 'fa-file-excel #2e7d32', xlsx: 'fa-file-excel #2e7d32' };
        const iv = (icons[ext] || 'fa-file-alt #6a1b9a').split(' ');
        setHtml('matIcon', '<i class="fas ' + iv[0] + '" style="color:' + iv[1] + '"></i>');
        loadMatNotes();
    }

    /* ============================================================
      PASTE THIS BLOCK to REPLACE the two functions in StudyMaterial.aspx
      (inside the <script> tag, find matAI() and askMatAI() and swap them)
      ============================================================ */

    /* ════════════════════════════════════════════════════════════════════════
       MATERIAL AI — POST JSON {file_path}, returns {result}
       Shows a live "Generating…" spinner while waiting, then renders result.
    ════════════════════════════════════════════════════════════════════════ */
    function matAI(type) {
        if (!curMatPath) { showMatAI('⚠ Please select a material first.'); return; }
        const res = document.getElementById('matAiRes');
        res.className = 'ai-result';
        res.style.fontFamily = '';

        // Show animated waiting message while phi3 generates
        let dots = 0;
        const labels = { summary: 'Summarising', notes: 'Generating notes', quiz: 'Creating quiz', mindmap: 'Building mind map' };
        const baseLabel = labels[type] || 'Generating';
        res.innerText = baseLabel + '…';
        const spinner = setInterval(() => {
            dots = (dots + 1) % 4;
            res.innerText = baseLabel + '.'.repeat(dots + 1);
        }, 600);

        fetch(AI_URL + '/material-' + type, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ file_path: curMatPath })
        })
            .then(r => {
                if (!r.ok) return r.json().then(e => { throw new Error(e.detail || ('HTTP ' + r.status)); });
                return r.json();
            })
            .then(d => {
                clearInterval(spinner);
                const txt = d.result || d.error || JSON.stringify(d);
                showMatAI(txt, type);
            })
            .catch(err => {
                clearInterval(spinner);
                showMatAI('⚠ AI error: ' + err.message
                    + '\n\nMake sure:\n1. Ollama is running  (ollama serve)\n'
                    + '2. Server is on port 8000  (uvicorn ai_server:app --port 8000)\n'
                    + '3. phi3 model is pulled  (ollama pull phi3)');
            });
    }

    function askMatAI() {
        const q = document.getElementById('matAiInput').value.trim();
        if (!q) return;
        if (!curMatPath) { showMatAI('⚠ Please select a material first.'); return; }

        const res = document.getElementById('matAiRes');
        res.className = 'ai-result';
        res.style.fontFamily = '';

        // Show question header immediately, then stream answer below it
        res.innerHTML = '<div style="background:#e8f5e9;border-radius:8px;padding:9px 12px;'
            + 'margin-bottom:10px;font-size:12px">'
            + '<strong style="color:var(--green)"><i class="fas fa-question-circle me-1"></i>Question:</strong><br>'
            + esc(q) + '</div>'
            + '<div id="_matAnsDiv" style="white-space:pre-wrap;font-size:13px;line-height:1.65">'
            + '<em style="color:var(--dim)">Thinking…</em></div>';

        const ansDiv = document.getElementById('_matAnsDiv');

        fetch(AI_URL + '/material-ask', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ file_path: curMatPath, question: q })
        })
            .then(r => {
                if (!r.ok) return r.json().then(e => { throw new Error(e.detail || ('HTTP ' + r.status)); });
                return r.json();
            })
            .then(d => {
                const txt = d.result || d.error || JSON.stringify(d);
                ansDiv.innerText = txt;
                document.getElementById('matAiInput').value = '';
            })
            .catch(err => {
                ansDiv.innerText = '⚠ ' + err.message;
            });
    }

    /* ---- showMatAI helper (keep this in place of the old one) ---- */
    function showMatAI(txt, type) {
        const r = document.getElementById('matAiRes');
        r.className = 'ai-result';
        r.style.fontFamily = (type === 'mindmap') ? '"Courier New",Courier,monospace' : '';
        r.innerText = txt;
    }

    /* ─── MATERIAL NOTES ──────────────────────────────────────────────────── */
    function loadMatNotes() {
        if (!curMatPath) return;
        ajPost('StudyMaterial.aspx/GetMaterialNotes', { materialPath: curMatPath, sessionId: +hfSess() })
            .then(raw => {
                const d = typeof raw === 'string' ? JSON.parse(raw) : raw;
                document.getElementById('matNotesEd').innerHTML = (d && d.Content) || '';
                setText('mNSt', d && d.Content ? 'Last saved: ' + (d.UpdatedOn || '') : 'No notes saved');
            }).catch(() => { });
    }
    function saveMatNotes() {
        if (!curMatPath) return;
        ajPost('StudyMaterial.aspx/SaveMaterialNotes', { materialPath: curMatPath, sessionId: +hfSess(), content: document.getElementById('matNotesEd').innerHTML })
            .then(() => setText('mNSt', 'Saved at ' + new Date().toLocaleTimeString())).catch(() => { });
    }
    function onMatNoteInput() { setText('mNSt', 'Unsaved changes…'); clearTimeout(matNotesTimer); matNotesTimer = setTimeout(saveMatNotes, 3000); }
    function mFmt(cmd) { document.getElementById('matNotesEd').focus(); document.execCommand(cmd, false, null); }
    function clearMatNotes() { if (confirm('Clear material notes?')) { document.getElementById('matNotesEd').innerHTML = ''; onMatNoteInput(); } }

    /* ─── TABS ────────────────────────────────────────────────────────────── */
    function switchTab(btn, paneId, barId) {
        const bar = document.getElementById(barId); if (!bar) return;
        bar.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('on'));
        const card = btn.closest('.vc'); if (card) card.querySelectorAll('.tab-pane').forEach(p => p.classList.remove('on'));
        btn.classList.add('on'); const pane = document.getElementById(paneId); if (pane) pane.classList.add('on');
        if (paneId === 'tComments') loadComments();
        if (paneId === 'tNotes' && curVid) loadNotes(curVid);
        if (paneId === 'tProgress') loadProgressDetail();
    }

    /* ─── UTILITIES ───────────────────────────────────────────────────────── */
    function $(id) { const e = document.getElementById(id); if (e) e.style.display = 'block'; }
    function $$(id) { const e = document.getElementById(id); if (e) e.style.display = 'none'; }
    function setText(id, v) { const e = document.getElementById(id); if (e) e.innerText = String(v != null ? v : ''); }
    function setHtml(id, v) { const e = document.getElementById(id); if (e) e.innerHTML = v; }
    function setWidth(id, w) { const e = document.getElementById(id); if (e) e.style.width = Math.min(Math.max(+w || 0, 0), 100) + '%'; }
    function esc(s) { return String(s || '').replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;'); }
    async function ajPost(url, data) {
        const r = await fetch(url, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(data) });
        const j = await r.json(); const raw = (j && j.d !== undefined) ? j.d : j;
        if (typeof raw === 'string') { try { return JSON.parse(raw); } catch (_) { return raw; } } return raw;
    }
</script>

</asp:Content>


