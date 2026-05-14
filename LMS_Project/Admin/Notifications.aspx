<%@ Page Title="Notifications" Language="C#"
    MasterPageFile="~/Admin/AdminMaster.Master"
    AutoEventWireup="true"
    CodeBehind="Notifications.aspx.cs"
    Inherits="LearningManagementSystem.Admin.Notifications" %>

<asp:Content ID="cHead" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<style>
:root{
  --p:#4f46e5;--pl:#eef2ff;--pd:#3730a3;
  --g:#059669;--gl:#d1fae5;--r:#dc2626;--rl:#fee2e2;
  --w:#d97706;--wl:#fef3c7;--b:#0284c7;--bl:#e0f2fe;
  --pu:#7c3aed;--pul:#f3e8ff;
  --tx:#0f172a;--ts:#64748b;--tm:#94a3b8;
  --bd:#e2e8f0;--bg:#f1f5f9;--card:#fff;
  --sh:0 1px 3px rgba(0,0,0,.06),0 4px 16px rgba(0,0,0,.05);
  --shl:0 8px 32px rgba(0,0,0,.12);--rad:14px;--rads:9px;
}
*{box-sizing:border-box;margin:0;padding:0}
body{font-family:'Segoe UI',system-ui,sans-serif;background:var(--bg);color:var(--tx)}
.wrap{padding:22px 24px;max-width:1300px;margin:0 auto}

/* BANNER — my inbox stats */
.banner{background:linear-gradient(135deg,#1e1b4b 0%,#3730a3 50%,#4f46e5 100%);
  border-radius:var(--rad);padding:26px 32px;margin-bottom:20px;
  display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:16px;
  position:relative;overflow:hidden;box-shadow:var(--shl)}
.banner::before{content:'';position:absolute;top:-60px;right:-60px;width:240px;height:240px;
  border-radius:50%;background:rgba(255,255,255,.06)}
.b-left{position:relative;z-index:1}
.b-title{font-size:1.45rem;font-weight:800;color:#fff;margin-bottom:4px}
.b-sub{font-size:13px;color:rgba(255,255,255,.65);display:flex;align-items:center;gap:8px}
.live-dot{display:inline-block;width:8px;height:8px;border-radius:50%;background:#10b981;
  animation:lpulse 1.4s infinite}
@keyframes lpulse{0%,100%{opacity:1}50%{opacity:.35}}
.b-kpis{display:flex;gap:24px;flex-wrap:wrap;position:relative;z-index:1}
.bk{text-align:center}
.bk-v{font-size:1.9rem;font-weight:800;color:#fff;line-height:1}
.bk-l{font-size:10px;color:rgba(255,255,255,.55);text-transform:uppercase;
  letter-spacing:.06em;margin-top:2px}
.bdiv{width:1px;background:rgba(255,255,255,.18);align-self:stretch}

/* VIEW-ONLY BAR (SuperAdmin) */
.view-only-bar{background:linear-gradient(135deg,#78350f,#d97706);
  border-radius:var(--rads);padding:10px 18px;margin-bottom:16px;
  display:flex;align-items:center;gap:10px;color:#fff;font-size:13px;font-weight:600;box-shadow:var(--sh)}

/* STAT CARDS — institute-wide (different from banner) */
.stat-row{display:grid;grid-template-columns:repeat(5,1fr);gap:12px;margin-bottom:20px}
@media(max-width:900px){.stat-row{grid-template-columns:repeat(3,1fr)}}
@media(max-width:560px){.stat-row{grid-template-columns:1fr 1fr}}
.sc{background:var(--card);border:1px solid var(--bd);border-radius:var(--rad);
  padding:14px 16px;display:flex;align-items:center;gap:12px;box-shadow:var(--sh);transition:.2s}
.sc:hover{transform:translateY(-2px);box-shadow:var(--shl)}
.sc-ico{width:42px;height:42px;border-radius:10px;display:flex;align-items:center;
  justify-content:center;font-size:17px;flex-shrink:0}
.sc-val{font-size:1.5rem;font-weight:800;line-height:1}
.sc-lbl{font-size:10px;font-weight:700;text-transform:uppercase;letter-spacing:.05em;color:var(--ts);margin-top:3px}
.sc-sub{font-size:10px;color:var(--tm);margin-top:1px}

/* TABS */
.tab-bar{display:flex;gap:2px;background:var(--bg);border-radius:10px;padding:4px;
  margin-bottom:16px;flex-wrap:wrap;border:1px solid var(--bd)}
.tab-btn{padding:9px 20px;border:none;background:transparent;border-radius:8px;
  font-size:13px;font-weight:600;color:var(--ts);cursor:pointer;transition:.18s;
  display:flex;align-items:center;gap:6px;font-family:inherit}
.tab-btn.on{background:var(--card);color:var(--p);box-shadow:var(--sh)}
.tab-btn:hover:not(.on){background:rgba(255,255,255,.6)}
.tab-pane{display:none}.tab-pane.on{display:block}

/* TOOLBAR */
.toolbar{background:var(--card);border:1px solid var(--bd);border-radius:var(--rad);
  padding:12px 16px;margin-bottom:12px;display:flex;align-items:center;gap:10px;
  flex-wrap:wrap;box-shadow:var(--sh)}
.sb{position:relative;flex:1;min-width:200px}
.sb i{position:absolute;left:10px;top:50%;transform:translateY(-50%);color:var(--tm);
  font-size:12px;pointer-events:none}
.sb input{width:100%;border:1.5px solid var(--bd);border-radius:8px;
  padding:8px 11px 8px 30px;font-size:13px;font-family:inherit;color:var(--tx);background:var(--bg);transition:.18s}
.sb input:focus{border-color:var(--p);outline:none;box-shadow:0 0 0 3px rgba(79,70,229,.1)}
.fsel{border:1.5px solid var(--bd);border-radius:8px;padding:8px 10px;
  font-size:13px;font-family:inherit;color:var(--tx);background:var(--bg);cursor:pointer}
.fsel:focus{border-color:var(--p);outline:none}

/* PILLS */
.pill-bar{display:flex;gap:6px;flex-wrap:wrap;margin-bottom:12px}
.pill{padding:6px 16px;border-radius:99px;border:1.5px solid var(--bd);
  font-size:12px;font-weight:600;cursor:pointer;background:var(--card);color:var(--ts);
  transition:.15s;font-family:inherit}
.pill:hover,.pill.on{background:var(--p);color:#fff;border-color:var(--p)}

/* BUTTONS */
.btn-p{background:var(--p);color:#fff;border:none;border-radius:var(--rads);
  padding:9px 18px;font-size:13px;font-weight:700;cursor:pointer;font-family:inherit;
  display:inline-flex;align-items:center;gap:6px;transition:.18s}
.btn-p:hover{background:var(--pd)}
.btn-o{background:var(--card);color:var(--ts);border:1.5px solid var(--bd);
  border-radius:var(--rads);padding:8px 14px;font-size:13px;font-weight:600;cursor:pointer;
  font-family:inherit;display:inline-flex;align-items:center;gap:6px;transition:.18s}
.btn-o:hover{border-color:var(--p);color:var(--p)}
.btn-r{background:#fff0f0;color:var(--r);border:1.5px solid #fecaca;border-radius:var(--rads);
  padding:8px 14px;font-size:13px;font-weight:700;cursor:pointer;font-family:inherit;
  display:inline-flex;align-items:center;gap:6px;transition:.18s}
.btn-r:hover{background:var(--rl)}
.vo-disabled{opacity:.45;cursor:not-allowed;pointer-events:none}

/* NOTIF ITEMS */
.notif-list{display:flex;flex-direction:column;gap:8px;margin-bottom:16px}
.ni{background:var(--card);border:1.5px solid var(--bd);border-radius:var(--rad);
  padding:14px 16px;display:flex;align-items:flex-start;gap:14px;
  box-shadow:var(--sh);transition:.2s;position:relative}
.ni:hover{box-shadow:var(--shl);transform:translateY(-1px)}
.ni.unread{border-left:3px solid var(--p);background:#fafbff}
.ni-dot{position:absolute;top:14px;right:14px;width:8px;height:8px;
  border-radius:50%;background:var(--p)}
.ni-ico{width:44px;height:44px;border-radius:12px;display:flex;align-items:center;
  justify-content:center;font-size:17px;flex-shrink:0}
.ni-body{flex:1;min-width:0}
.ni-tag{display:inline-block;padding:2px 9px;border-radius:5px;font-size:10px;
  font-weight:700;letter-spacing:.04em;margin-bottom:5px}
.ni-msg{font-size:13px;font-weight:500;color:var(--tx);line-height:1.55;margin-bottom:5px}
.ni-meta{font-size:11px;color:var(--tm);display:flex;align-items:center;gap:8px;flex-wrap:wrap}
.ni-acts{display:flex;gap:5px;flex-shrink:0;margin-left:4px}
.na{width:30px;height:30px;border:none;border-radius:8px;cursor:pointer;
  display:flex;align-items:center;justify-content:center;font-size:12px;transition:.15s}
.na:hover{filter:brightness(.88);transform:scale(1.08)}
.na-read{background:#dbeafe;color:var(--b)}
.na-del{background:var(--rl);color:var(--r)}

/* SENT ITEMS */
.sent-item{background:var(--card);border:1.5px solid var(--bd);border-radius:var(--rad);
  padding:14px 16px;display:flex;align-items:flex-start;gap:14px;box-shadow:var(--sh);margin-bottom:8px}
.si-body{flex:1;min-width:0}
.si-tag{display:inline-block;padding:2px 9px;border-radius:5px;font-size:10px;
  font-weight:700;letter-spacing:.04em;margin-bottom:5px}
.si-msg{font-size:13px;font-weight:500;color:var(--tx);line-height:1.55;margin-bottom:5px}
.si-meta{font-size:11px;color:var(--tm);display:flex;align-items:center;gap:10px;flex-wrap:wrap}
.si-badge{background:var(--gl);color:var(--g);padding:2px 8px;border-radius:5px;font-size:11px;font-weight:700}

.empty{text-align:center;padding:60px 20px;color:var(--tm)}
.empty i{font-size:3rem;opacity:.13;display:block;margin-bottom:14px}
.empty h5{font-size:15px;font-weight:700;margin-bottom:6px;color:var(--ts)}
.empty p{font-size:13px}

/* PAGER */
.pager{display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:10px}
.pager-info{font-size:12px;color:var(--ts)}
.pager-btns{display:flex;gap:4px}
.pb{min-width:32px;height:32px;border:1.5px solid var(--bd);border-radius:8px;
  background:var(--card);color:var(--ts);font-size:12px;font-weight:600;cursor:pointer;
  font-family:inherit;display:flex;align-items:center;justify-content:center;padding:0 8px;transition:.15s}
.pb:hover{border-color:var(--p);color:var(--p)}
.pb.on{background:var(--p);color:#fff;border-color:var(--p)}
.pb:disabled{opacity:.35;cursor:default}

/* MODAL */
.mo{display:none;position:fixed;inset:0;background:rgba(0,0,0,.52);z-index:9999;
  backdrop-filter:blur(4px);align-items:center;justify-content:center;padding:20px}
.mo.open{display:flex}
.mb{background:var(--card);border-radius:var(--rad);box-shadow:var(--shl);
  width:100%;max-width:620px;animation:mIn .22s ease;max-height:92vh;overflow-y:auto}
@keyframes mIn{from{opacity:0;transform:scale(.96)}to{opacity:1;transform:scale(1)}}
.mh{padding:16px 20px;display:flex;justify-content:space-between;align-items:center;
  border-radius:var(--rad) var(--rad) 0 0;background:linear-gradient(135deg,var(--pd),var(--p))}
.mh h5{color:#fff;font-size:14px;font-weight:700;margin:0}
.mc{background:rgba(255,255,255,.2);border:none;color:#fff;border-radius:7px;width:28px;height:28px;
  cursor:pointer;display:flex;align-items:center;justify-content:center;font-size:13px;flex-shrink:0}
.mc:hover{background:rgba(255,255,255,.38)}
.mbody{padding:20px}
.mfoot{padding:10px 20px 18px;display:flex;justify-content:flex-end;gap:10px}
.fg{margin-bottom:14px}
.fg label{display:block;font-size:11px;font-weight:700;text-transform:uppercase;
  letter-spacing:.04em;color:var(--ts);margin-bottom:5px}
.fc{width:100%;border:1.5px solid var(--bd);border-radius:8px;padding:9px 11px;
  font-size:13px;font-family:inherit;color:var(--tx);background:var(--bg);transition:.18s}
.fc:focus{border-color:var(--p);outline:none;box-shadow:0 0 0 3px rgba(79,70,229,.1)}
.tbox{max-height:210px;overflow-y:auto;border:1.5px solid var(--bd);border-radius:8px;padding:8px}
.tu{display:flex;align-items:center;gap:8px;padding:6px 8px;border-radius:6px;
  font-size:13px;cursor:pointer;transition:.15s;font-family:inherit}
.tu:hover{background:var(--pl)}
.tu input{cursor:pointer;width:15px;height:15px;flex-shrink:0}
.char-c{font-size:11px;color:var(--tm);margin-top:3px}
.info-tip{background:var(--pl);border-radius:9px;padding:10px 13px;font-size:12px;
  color:var(--pd);display:flex;align-items:flex-start;gap:8px}

/* TOAST */
#toast-root{position:fixed;bottom:22px;right:22px;z-index:99999;
  display:flex;flex-direction:column;gap:8px;pointer-events:none}
.nt{border-radius:11px;padding:12px 16px;font-size:13px;font-weight:600;color:#fff;
  animation:tIn .3s ease;max-width:360px;pointer-events:auto;box-shadow:var(--shl);
  display:flex;align-items:center;gap:8px}
.nt.ok{background:#059669}.nt.err{background:#dc2626}
.nt.warn{background:#d97706}.nt.inf{background:var(--p)}
@keyframes tIn{from{opacity:0;transform:translateX(40px)}to{opacity:1;transform:none}}
@keyframes spin{to{transform:rotate(360deg)}}
.spinner{display:inline-block;width:22px;height:22px;border:2px solid var(--bd);
  border-top-color:var(--p);border-radius:50%;animation:spin .7s linear infinite}
</style>
</asp:Content>

<asp:Content ID="cBody" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

<asp:HiddenField ID="hfInstId"  runat="server"/>
<asp:HiddenField ID="hfSessId"  runat="server"/>
<asp:HiddenField ID="hfUserId"  runat="server"/>
<asp:HiddenField ID="hfSocId"   runat="server"/>
<asp:HiddenField ID="hfIsSuper" runat="server"/>

<div class="wrap">

  <%-- BANNER — My Inbox Stats --%>
  <div class="banner">
    <div class="b-left">
      <div class="b-title"><i class="fa fa-bell me-2"></i>Notifications Centre</div>
      <div class="b-sub">
        <span class="live-dot"></span>My Inbox &bull; Session:
        <strong style="color:#fff" id="bSessName">—</strong>
      </div>
    </div>
    <div class="b-kpis">
      <div class="bk"><div class="bk-v" id="bMyTotal">0</div><div class="bk-l">My Total</div></div>
      <div class="bdiv"></div>
      <div class="bk"><div class="bk-v" id="bMyUnread">0</div><div class="bk-l">My Unread</div></div>
      <div class="bdiv"></div>
      <div class="bk"><div class="bk-v" id="bMyToday">0</div><div class="bk-l">Today</div></div>
      <div class="bdiv"></div>
      <div class="bk"><div class="bk-v" id="bMyWeek">0</div><div class="bk-l">This Week</div></div>
    </div>
  </div>

  <%-- SuperAdmin view-only notice --%>
  <div class="view-only-bar" id="viewOnlyBar" style="display:none">
    <i class="fa fa-eye"></i>
    <span>Logged in as <strong>SuperAdmin</strong> — View-only. All write operations are disabled.</span>
  </div>

  <%-- STAT CARDS — Institute-wide overview (different from banner) --%>
  <div class="stat-row">
    <div class="sc">
      <div class="sc-ico" style="background:var(--pl);color:var(--p)"><i class="fa fa-paper-plane"></i></div>
      <div><div class="sc-val" id="scSentBatches">0</div>
        <div class="sc-lbl">Sent Batches</div>
        <div class="sc-sub">Total send actions</div></div>
    </div>
    <div class="sc">
      <div class="sc-ico" style="background:var(--bl);color:var(--b)"><i class="fa fa-users"></i></div>
      <div><div class="sc-val" id="scTotalDelivered">0</div>
        <div class="sc-lbl">Total Delivered</div>
        <div class="sc-sub">All recipients</div></div>
    </div>
    <div class="sc">
      <div class="sc-ico" style="background:var(--gl);color:var(--g)"><i class="fa fa-check-double"></i></div>
      <div><div class="sc-val" id="scTotalRead">0</div>
        <div class="sc-lbl">Total Read</div>
        <div class="sc-sub">Across all users</div></div>
    </div>
    <div class="sc">
      <div class="sc-ico" style="background:var(--rl);color:var(--r)"><i class="fa fa-circle-dot"></i></div>
      <div><div class="sc-val" id="scTotalUnread">0</div>
        <div class="sc-lbl">Total Unread</div>
        <div class="sc-sub">Across all users</div></div>
    </div>
    <div class="sc">
      <div class="sc-ico" style="background:var(--wl);color:var(--w)"><i class="fa fa-calendar-day"></i></div>
      <div><div class="sc-val" id="scSentToday">0</div>
        <div class="sc-lbl">Sent Today</div>
        <div class="sc-sub">Batches sent today</div></div>
    </div>
  </div>

  <%-- TABS --%>
  <div class="tab-bar" id="tabBar">
    <button type="button" class="tab-btn on" data-tab="received">
      <i class="fa fa-inbox"></i> Received</button>
    <button type="button" class="tab-btn" data-tab="sent">
      <i class="fa fa-paper-plane"></i> Sent</button>
  </div>

  <%-- TAB: RECEIVED --%>
  <div id="tab-received" class="tab-pane on">
    <div style="display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:10px;margin-bottom:12px">
      <div class="pill-bar" id="pillBar" style="margin:0">
        <button type="button" class="pill on" data-f="All">All</button>
        <button type="button" class="pill" data-f="Unread">🔴 Unread</button>
        <button type="button" class="pill" data-f="Read">✅ Read</button>
      </div>
      <div style="display:flex;gap:8px;flex-wrap:wrap">
        <button type="button" class="btn-o" id="btnMarkAll">
          <i class="fa fa-check-double"></i> Mark All Read</button>
        <button type="button" class="btn-r" id="btnDelAll">
          <i class="fa fa-trash-alt"></i> Clear All</button>
        <button type="button" class="btn-p" id="btnSendOpen">
          <i class="fa fa-paper-plane"></i> Send Notification</button>
      </div>
    </div>
    <div class="toolbar">
      <div class="sb"><i class="fa fa-search"></i>
        <input type="text" id="txtSearch" placeholder="Search notifications…"/></div>
      <select id="selType" class="fsel"><option value="">All Types</option></select>
      <select id="selPg" class="fsel">
        <option value="20">20 / page</option>
        <option value="50">50 / page</option>
        <option value="100">100 / page</option>
      </select>
      <span id="recInfo" style="font-size:12px;color:var(--ts);white-space:nowrap"></span>
    </div>
    <div id="notifList" class="notif-list">
      <div class="empty"><div class="spinner"></div></div>
    </div>
    <div class="pager" id="pager" style="display:none">
      <div class="pager-info" id="pagerInfo"></div>
      <div class="pager-btns" id="pagerBtns"></div>
    </div>
  </div>

  <%-- TAB: SENT --%>
  <div id="tab-sent" class="tab-pane">
    <div class="toolbar">
      <div class="sb"><i class="fa fa-search"></i>
        <input type="text" id="txtSentSearch" placeholder="Search sent notifications…"/></div>
      <select id="selSentType" class="fsel"><option value="">All Types</option></select>
      <select id="selSentPg" class="fsel">
        <option value="20">20 / page</option>
        <option value="50">50 / page</option>
      </select>
      <span id="sentRecInfo" style="font-size:12px;color:var(--ts);white-space:nowrap"></span>
    </div>
    <div id="sentList"></div>
    <div class="pager" id="sentPager" style="display:none">
      <div class="pager-info" id="sentPagerInfo"></div>
      <div class="pager-btns" id="sentPagerBtns"></div>
    </div>
  </div>

</div>

<%-- SEND MODAL --%>
<div class="mo" id="sendMo">
  <div class="mb">
    <div class="mh">
      <h5><i class="fa fa-paper-plane me-2"></i>Send Notification</h5>
      <button type="button" class="mc" id="btnCloseSend"><i class="fa fa-times"></i></button>
    </div>
    <div class="mbody">
      <div class="fg">
        <label>Notification Type *</label>
        <select id="sndType" class="fc">
          <option value="General">📢 General</option>
          <option value="Assignment">📋 Assignment</option>
          <option value="Attendance">📅 Attendance</option>
          <option value="Exam">📝 Exam</option>
          <option value="Fee">💰 Fee</option>
          <option value="Event">🎉 Event</option>
          <option value="Result">📊 Result</option>
          <option value="Holiday">🏖 Holiday</option>
          <option value="Alert">⚠️ Alert</option>
        </select>
      </div>
      <div class="fg">
        <label>Message *</label>
        <textarea id="sndMsg" class="fc" rows="3" maxlength="500"
          placeholder="Type your notification message here…" style="resize:vertical"></textarea>
        <div class="char-c"><span id="charLen">0</span>/500 characters</div>
      </div>
      <div class="fg">
        <label>Send To</label>
        <select id="sndRole" class="fc">
          <option value="">Everyone (Broadcast – all active users)</option>
          <option value="Student">All Students</option>
          <option value="Teacher">All Teachers</option>
          <option value="Parent">All Parents</option>
          <option value="custom">Pick Specific Users…</option>
        </select>
      </div>
      <div class="fg" id="userWrap" style="display:none">
        <label>Select Users</label>
        <div class="tbox" id="userList">
          <div style="text-align:center;padding:16px"><div class="spinner"></div></div>
        </div>
      </div>
      <div class="info-tip">
        <i class="fa fa-circle-info" style="margin-top:1px"></i>
        Notification appears instantly on recipients' screens.
      </div>
    </div>
    <div class="mfoot">
      <button type="button" class="btn-o" id="btnCancelSend">Cancel</button>
      <button type="button" class="btn-p" id="btnSendNow">
        <i class="fa fa-paper-plane"></i> Send Now</button>
    </div>
  </div>
</div>

<div id="toast-root"></div>

<script>
    (function () {
        'use strict';
        var INST = parseInt('<%= hfInstId.Value %>') || 0;
    var SESS = parseInt('<%= hfSessId.Value %>') || 0;
    var UID = parseInt('<%= hfUserId.Value %>')||0;
var SOC=parseInt('<%= hfSocId.Value %>')||0;
var IS_SUPER='<%= hfIsSuper.Value %>'==='1';
var BASE=location.pathname;
document.getElementById('bSessName').textContent='<%= Session["SessionName"] ?? "" %>';

        if (IS_SUPER) {
            document.getElementById('viewOnlyBar').style.display = 'flex';
            ['btnMarkAll', 'btnDelAll', 'btnSendOpen', 'btnSendNow'].forEach(function (id) {
                var el = document.getElementById(id); if (el) el.classList.add('vo-disabled');
            });
        }

        var rcv = { filter: 'All', type: '', search: '', page: 1, pgsize: 20 };
        var snt = { type: '', search: '', page: 1, pgsize: 20 };
        var debR = null, debS = null, lastUnread = -1;

        function toast(msg, type) {
            var w = document.getElementById('toast-root');
            var d = document.createElement('div'); d.className = 'nt ' + (type || 'inf');
            var ic = { ok: 'fa-check-circle', err: 'fa-times-circle', warn: 'fa-exclamation-triangle', inf: 'fa-info-circle' };
            d.innerHTML = '<i class="fa ' + (ic[type] || 'fa-info-circle') + '"></i><span>' + msg + '</span>';
            w.appendChild(d);
            setTimeout(function () {
                d.style.opacity = '0'; d.style.transition = 'opacity .4s';
                setTimeout(function () { d.remove(); }, 400);
            }, 5000);
        }
        function guardWrite(lbl) {
            if (IS_SUPER) { toast('View only — ' + lbl + ' disabled for SuperAdmin.', 'warn'); return true; }
            return false;
        }
        function api(action, extra, method) {
            var qs = '?ajax=' + action + '&inst=' + INST + '&sess=' + SESS + '&uid=' + UID + '&soc=' + SOC + (extra || '');
            if (!method || method === 'GET') return fetch(BASE + qs);
            return fetch(BASE + qs, {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'ajax=' + action + '&inst=' + INST + '&sess=' + SESS + '&uid=' + UID + '&soc=' + SOC + (extra || '')
            });
        }

        var PAL = ['#4f46e5', '#d97706', '#059669', '#dc2626', '#db2777', '#0d9488', '#0284c7', '#7c3aed', '#ea580c', '#0f766e'];
        var CC = {};
        function col(t) { if (!CC[t]) { var h = 0; for (var i = 0; i < t.length; i++)h = (h * 31 + t.charCodeAt(i)) & 0xffff; CC[t] = PAL[h % PAL.length]; } return CC[t]; }
        function fmtType(t) { return (t || 'General').replace(/([A-Z])/g, ' $1').trim(); }
        function fmtAgo(m) { if (!m || m < 1) return 'Just now'; if (m < 60) return m + 'm ago'; var h = Math.floor(m / 60); if (h < 24) return h + 'h ago'; return Math.floor(h / 24) + 'd ago'; }
        function esc(s) { return String(s || '').replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;'); }
        function cu(id, n) { var el = document.getElementById(id); if (!el) return; var s = parseInt(el.textContent) || 0, diff = n - s, steps = 20, i = 0; var iv = setInterval(function () { i++; el.textContent = Math.round(s + diff * (i / steps)); if (i >= steps) { el.textContent = n; clearInterval(iv); } }, 16); }
        function sv(id, n) { var el = document.getElementById(id); if (el) el.textContent = n; }
        function badge(n) {
            var dot = document.getElementById('headerNotifDot'), b = document.getElementById('headerNotifBadge');
            if (dot) dot.style.display = n > 0 ? 'block' : 'none';
            if (b) { b.textContent = n > 99 ? '99+' : n; b.style.display = n > 0 ? '' : 'none'; }
        }

        /* ══ MY INBOX STATS (banner) ══ */
        function fetchMyStats() {
            api('stats').then(function (r) { return r.json(); }).then(function (s) {
                cu('bMyTotal', s.Total || 0); cu('bMyUnread', s.Unread || 0);
                cu('bMyToday', s.Today || 0); cu('bMyWeek', s.ThisWeek || 0);
                var nu = s.Unread || 0;
                if (lastUnread >= 0 && nu > lastUnread) fetchReceived();
                lastUnread = nu; badge(nu);
            }).catch(function () { });
        }

        /* ══ INSTITUTE-WIDE STATS (cards) ══ */
        function fetchInstStats() {
            api('inststats').then(function (r) { return r.json(); }).then(function (s) {
                cu('scSentBatches', s.SentBatches || 0);
                cu('scTotalDelivered', s.TotalDelivered || 0);
                cu('scTotalRead', s.TotalRead || 0);
                cu('scTotalUnread', s.TotalUnread || 0);
                cu('scSentToday', s.SentToday || 0);
            }).catch(function () { });
        }

        /* ══ RECEIVED ══ */
        function fetchReceived() {
            document.getElementById('notifList').innerHTML = '<div class="empty"><div class="spinner"></div></div>';
            api('list', '&filter=' + encodeURIComponent(rcv.filter) + '&type=' + encodeURIComponent(rcv.type)
                + '&search=' + encodeURIComponent(rcv.search) + '&page=' + rcv.page + '&pgsize=' + rcv.pgsize)
                .then(function (r) { return r.json(); })
                .then(function (d) {
                    if (d.stats) {
                        var s = d.stats; cu('bMyTotal', s.Total || 0); cu('bMyUnread', s.Unread || 0);
                        cu('bMyToday', s.Today || 0); cu('bMyWeek', s.ThisWeek || 0); lastUnread = s.Unread || 0; badge(lastUnread);
                    }
                    renderItems(d.items || [], d.total || 0, d.page || 1, d.pgsize || 20);
                }).catch(function (e) { console.error(e); });
        }

        function renderItems(items, total, page, pgsize) {
            var list = document.getElementById('notifList');
            if (!items.length) {
                list.innerHTML = '<div class="empty"><i class="fa fa-bell-slash"></i>'
                    + '<h5>No notifications found</h5><p>Try a different filter or wait for new ones.</p></div>';
                document.getElementById('pager').style.display = 'none';
                document.getElementById('recInfo').textContent = '0 records'; return;
            }
            list.innerHTML = items.map(function (n) {
                var c = col(n.NotificationType || 'General'), u = !n.IsRead;
                return '<div class="ni' + (u ? ' unread' : '') + '" data-id="' + n.NotificationId + '">'
                    + (u ? '<div class="ni-dot"></div>' : '')
                    + '<div class="ni-ico" style="background:' + c + '20;color:' + c + '"><i class="fa fa-bell"></i></div>'
                    + '<div class="ni-body">'
                    + '<div class="ni-tag" style="background:' + c + '18;color:' + c + '">' + esc(fmtType(n.NotificationType)) + '</div>'
                    + '<div class="ni-msg">' + esc(n.Message || '') + '</div>'
                    + '<div class="ni-meta"><i class="fa fa-clock"></i>' + fmtAgo(n.MinutesAgo) + '</div>'
                    + '</div><div class="ni-acts">'
                    + (u && !IS_SUPER ? '<button type="button" class="na na-read" data-act="read" data-id="' + n.NotificationId + '"><i class="fa fa-check"></i></button>' : '')
                    + (!IS_SUPER ? '<button type="button" class="na na-del" data-act="del" data-id="' + n.NotificationId + '"><i class="fa fa-trash"></i></button>' : '')
                    + '</div></div>';
            }).join('');
            list.querySelectorAll('.na').forEach(function (btn) {
                btn.addEventListener('click', function (e) {
                    e.stopPropagation();
                    if (this.dataset.act === 'read') doMarkRead(this.dataset.id, this.closest('.ni'));
                    else doDelete(this.dataset.id, this.closest('.ni'));
                });
            });
            var from = Math.min((page - 1) * pgsize + 1, total), to = Math.min(page * pgsize, total);
            document.getElementById('recInfo').textContent = 'Showing ' + from + '–' + to + ' of ' + total;
            buildPager(total, page, pgsize, 'pager', 'pagerInfo', 'pagerBtns', function (p) { rcv.page = p; fetchReceived(); });
        }

        /* ══ SENT ══ */
        function fetchSent() {
            document.getElementById('sentList').innerHTML = '<div class="empty"><div class="spinner"></div></div>';
            api('sent', '&type=' + encodeURIComponent(snt.type) + '&search=' + encodeURIComponent(snt.search)
                + '&page=' + snt.page + '&pgsize=' + snt.pgsize)
                .then(function (r) { return r.json(); })
                .then(function (d) { renderSent(d.items || [], d.total || 0, d.page || 1, d.pgsize || 20); })
                .catch(function (e) { console.error(e); });
        }

        function renderSent(items, total, page, pgsize) {
            var wrap = document.getElementById('sentList');
            if (!items.length) {
                wrap.innerHTML = '<div class="empty"><i class="fa fa-paper-plane"></i>'
                    + '<h5>No sent notifications</h5><p>Use "Send Notification" to broadcast messages.</p></div>';
                document.getElementById('sentPager').style.display = 'none';
                document.getElementById('sentRecInfo').textContent = '0 records'; return;
            }
            wrap.innerHTML = items.map(function (n) {
                var c = col(n.NotificationType || 'General');
                var pct = n.RecipientCount > 0 ? Math.round((n.ReadCount / n.RecipientCount) * 100) : 0;
                return '<div class="sent-item">'
                    + '<div class="ni-ico" style="background:' + c + '20;color:' + c + '"><i class="fa fa-paper-plane"></i></div>'
                    + '<div class="si-body">'
                    + '<div class="si-tag" style="background:' + c + '18;color:' + c + '">' + esc(fmtType(n.NotificationType)) + '</div>'
                    + '<div class="si-msg">' + esc(n.Message || '') + '</div>'
                    + '<div class="si-meta">'
                    + '<span><i class="fa fa-clock me-1"></i>' + fmtAgo(n.MinutesAgo) + '</span>'
                    + '<span class="si-badge"><i class="fa fa-users me-1"></i>' + n.RecipientCount + ' recipients</span>'
                    + '<span class="si-badge" style="background:var(--bl);color:var(--b)">'
                    + '<i class="fa fa-eye me-1"></i>' + n.ReadCount + ' read (' + pct + '%)</span>'
                    + (n.TargetRoles ? '<span style="color:var(--ts)"><i class="fa fa-tag me-1"></i>' + esc(n.TargetRoles) + '</span>' : '')
                    + '</div></div></div>';
            }).join('');
            var from = Math.min((page - 1) * pgsize + 1, total), to = Math.min(page * pgsize, total);
            document.getElementById('sentRecInfo').textContent = 'Showing ' + from + '–' + to + ' of ' + total;
            buildPager(total, page, pgsize, 'sentPager', 'sentPagerInfo', 'sentPagerBtns', function (p) { snt.page = p; fetchSent(); });
        }

        /* ══ PAGER ══ */
        function buildPager(total, page, pgsize, pid, iid, bid, cb) {
            var tp = Math.max(1, Math.ceil(total / pgsize));
            var pg = document.getElementById(pid);
            document.getElementById(iid).textContent = 'Page ' + page + ' of ' + tp;
            if (tp <= 1) { pg.style.display = 'none'; return; }
            pg.style.display = 'flex';
            var btns = document.getElementById(bid); btns.innerHTML = '';
            function ab(t, p, dis, act) {
                var b = document.createElement('button'); b.type = 'button';
                b.className = 'pb' + (act ? ' on' : ''); b.textContent = t; b.disabled = dis;
                b.addEventListener('click', function () { cb(p); }); btns.appendChild(b);
            }
            ab('«', 1, page === 1, false); ab('‹', page - 1, page === 1, false);
            var st = Math.max(1, page - 2), en = Math.min(tp, st + 4);
            for (var p2 = st; p2 <= en; p2++) ab(p2, p2, false, p2 === page);
            ab('›', page + 1, page >= tp, false); ab('»', tp, page >= tp, false);
        }

        /* ══ ACTIONS ══ */
        function doMarkRead(id, el) {
            if (guardWrite('Mark Read')) return;
            api('markread', '&id=' + id, 'POST').then(function (r) { return r.json(); }).then(function () { fetchReceived(); });
        }
        function doDelete(id, el) {
            if (guardWrite('Delete')) return;
            if (!confirm('Delete this notification?')) return;
            api('delete', '&id=' + id, 'POST').then(function (r) { return r.json(); })
                .then(function () {
                    if (el) {
                        el.style.opacity = '0'; el.style.transition = 'opacity .3s';
                        setTimeout(function () { fetchReceived(); }, 300);
                    } toast('Deleted', 'ok');
                })
                .catch(function () { toast('Delete failed', 'err'); });
        }
        document.getElementById('btnMarkAll').addEventListener('click', function () {
            if (guardWrite('Mark All Read')) return;
            api('markall', '', 'POST').then(function (r) { return r.json(); })
                .then(function () { fetchReceived(); toast('All marked as read', 'ok'); })
                .catch(function () { toast('Failed', 'err'); });
        });
        document.getElementById('btnDelAll').addEventListener('click', function () {
            if (guardWrite('Clear All')) return;
            if (!confirm('Delete ALL notifications? This cannot be undone.')) return;
            api('deleteall', '', 'POST').then(function (r) { return r.json(); })
                .then(function () { fetchReceived(); toast('All cleared', 'ok'); })
                .catch(function () { toast('Failed', 'err'); });
        });

        /* ══ PILLS ══ */
        document.getElementById('pillBar').addEventListener('click', function (e) {
            var btn = e.target.closest('.pill'); if (!btn) return;
            document.querySelectorAll('.pill').forEach(function (p) { p.classList.remove('on'); });
            btn.classList.add('on'); rcv.filter = btn.dataset.f; rcv.page = 1; fetchReceived();
        });

        /* ══ TYPE DROPDOWNS ══ */
        function loadTypes() {
            api('types').then(function (r) { return r.json(); }).then(function (d) {
                var sel = document.getElementById('selType');
                (d.types || []).forEach(function (t) {
                    var o = document.createElement('option');
                    o.value = t; o.textContent = fmtType(t); sel.appendChild(o);
                });
            }).catch(function () { });
        }
        function loadSentTypes() {
            api('alltypes').then(function (r) { return r.json(); }).then(function (d) {
                var sel = document.getElementById('selSentType');
                (d.types || []).forEach(function (t) {
                    var o = document.createElement('option');
                    o.value = t; o.textContent = fmtType(t); sel.appendChild(o);
                });
            }).catch(function () { });
        }
        document.getElementById('selType').addEventListener('change', function () { rcv.type = this.value; rcv.page = 1; fetchReceived(); });
        document.getElementById('selSentType').addEventListener('change', function () { snt.type = this.value; snt.page = 1; fetchSent(); });
        document.getElementById('selPg').addEventListener('change', function () { rcv.pgsize = parseInt(this.value); rcv.page = 1; fetchReceived(); });
        document.getElementById('selSentPg').addEventListener('change', function () { snt.pgsize = parseInt(this.value); snt.page = 1; fetchSent(); });
        document.getElementById('txtSearch').addEventListener('input', function () {
            clearTimeout(debR); var v = this.value; debR = setTimeout(function () { rcv.search = v; rcv.page = 1; fetchReceived(); }, 400);
        });
        document.getElementById('txtSentSearch').addEventListener('input', function () {
            clearTimeout(debS); var v = this.value; debS = setTimeout(function () { snt.search = v; snt.page = 1; fetchSent(); }, 400);
        });

        /* ══ TABS ══ */
        document.getElementById('tabBar').addEventListener('click', function (e) {
            var btn = e.target.closest('.tab-btn'); if (!btn) return;
            var name = btn.dataset.tab;
            document.querySelectorAll('.tab-btn').forEach(function (b) { b.classList.remove('on'); });
            document.querySelectorAll('.tab-pane').forEach(function (p) { p.classList.remove('on'); });
            btn.classList.add('on'); document.getElementById('tab-' + name).classList.add('on');
            if (name === 'sent') fetchSent();
        });

        /* ══ SEND MODAL ══ */
        function openSend() { if (guardWrite('Send Notification')) return; document.getElementById('sendMo').classList.add('open'); }
        function closeSend() { document.getElementById('sendMo').classList.remove('open'); }
        document.getElementById('btnSendOpen').addEventListener('click', openSend);
        document.getElementById('btnCloseSend').addEventListener('click', closeSend);
        document.getElementById('btnCancelSend').addEventListener('click', closeSend);
        document.getElementById('sendMo').addEventListener('click', function (e) { if (e.target === this) closeSend(); });
        document.getElementById('sndMsg').addEventListener('input', function () {
            document.getElementById('charLen').textContent = this.value.length;
        });
        document.getElementById('sndRole').addEventListener('change', function () {
            var role = this.value, wrap = document.getElementById('userWrap');
            if (!role) { wrap.style.display = 'none'; return; }
            wrap.style.display = 'block';
            var box = document.getElementById('userList');
            box.innerHTML = '<div style="text-align:center;padding:16px"><div class="spinner"></div></div>';
            api('users', '&role=' + encodeURIComponent(role === 'custom' ? '' : role))
                .then(function (r) { return r.json(); })
                .then(function (d) {
                    if (!d.users || !d.users.length) {
                        box.innerHTML = '<p style="padding:10px;font-size:13px;color:var(--ts)">No users found.</p>'; return;
                    }
                    box.innerHTML = d.users.map(function (u) {
                        return '<label class="tu"><input type="checkbox" class="tu-chk" value="' + u.UserId + '"/>'
                            + '<span>' + esc(u.FullName || '') + '</span>'
                            + '<span style="font-size:11px;color:var(--tm);margin-left:auto">' + esc(u.RoleName || '') + '</span></label>';
                    }).join('');
                }).catch(function () { box.innerHTML = '<p style="color:var(--r);padding:10px;font-size:13px">Failed to load users.</p>'; });
        });
        document.getElementById('btnSendNow').addEventListener('click', function () {
            if (guardWrite('Send Notification')) return;
            var msg = document.getElementById('sndMsg').value.trim();
            var type = document.getElementById('sndType').value;
            var role = document.getElementById('sndRole').value;
            if (!msg) { toast('Message cannot be empty', 'warn'); return; }
            var uids = [];
            document.querySelectorAll('.tu-chk:checked').forEach(function (c) { uids.push(c.value); });
            var params = '&msg=' + encodeURIComponent(msg) + '&type=' + encodeURIComponent(type)
                + '&role=' + encodeURIComponent(role === 'custom' ? '' : role)
                + '&uids=' + encodeURIComponent(uids.join(','));
            var btn = this; btn.disabled = true; btn.innerHTML = '<i class="fa fa-spinner fa-spin"></i> Sending…';
            api('send', params, 'POST').then(function (r) { return r.json(); })
                .then(function (d) {
                    if (d.ok === false) { toast(d.error || 'Send failed', 'err'); return; }
                    toast('✓ Sent to ' + (d.sent || 0) + ' user(s)', 'ok');
                    closeSend();
                    document.getElementById('sndMsg').value = '';
                    document.getElementById('charLen').textContent = '0';
                    document.getElementById('sndRole').value = '';
                    document.getElementById('userWrap').style.display = 'none';
                    fetchReceived();
                    fetchInstStats();
                }).catch(function () { toast('Send failed', 'err'); })
                .finally(function () { btn.disabled = false; btn.innerHTML = '<i class="fa fa-paper-plane"></i> Send Now'; });
        });

        /* ══ INIT ══ */
        loadTypes();
        loadSentTypes();
        fetchMyStats();
        fetchInstStats();
        fetchReceived();
        setInterval(function () { fetchMyStats(); fetchInstStats(); }, 30000);
    })();
</script>
</asp:Content>
