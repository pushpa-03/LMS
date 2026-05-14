<%@ Page Title="My Notifications" Language="C#"
    MasterPageFile="~/Student/StudentMaster.Master"
    AutoEventWireup="true"
    CodeBehind="Student_Notifications.aspx.cs"
    Inherits="LearningManagementSystem.Student.Notifications" %>

<asp:Content ID="cHead" ContentPlaceHolderID="head" runat="server">
<style>
:root{
  --p:#4f46e5;--pl:#eef2ff;--pd:#3730a3;
  --g:#059669;--gl:#d1fae5;--r:#dc2626;--rl:#fee2e2;
  --w:#d97706;--wl:#fef3c7;--b:#0284c7;--bl:#e0f2fe;
  --tx:#0f172a;--ts:#64748b;--tm:#94a3b8;
  --bd:#e2e8f0;--bg:#f1f5f9;--card:#fff;
  --sh:0 1px 3px rgba(0,0,0,.06),0 4px 16px rgba(0,0,0,.05);
  --shl:0 8px 32px rgba(0,0,0,.12);--rad:14px;--rads:9px;
}
*{box-sizing:border-box;margin:0;padding:0}
body{font-family:'Segoe UI',system-ui,sans-serif;background:var(--bg);color:var(--tx)}
.wrap{padding:22px 24px;max-width:1100px;margin:0 auto}
.banner{background:linear-gradient(135deg,#1e1b4b 0%,#3730a3 50%,#4f46e5 100%);
  border-radius:var(--rad);padding:24px 28px;margin-bottom:20px;
  display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:14px;
  position:relative;overflow:hidden;box-shadow:var(--shl)}
.banner::before{content:'';position:absolute;top:-60px;right:-60px;width:200px;height:200px;
  border-radius:50%;background:rgba(255,255,255,.06)}
.b-left{position:relative;z-index:1}
.b-title{font-size:1.35rem;font-weight:800;color:#fff;margin-bottom:4px}
.b-sub{font-size:12px;color:rgba(255,255,255,.65)}
.live-dot{display:inline-block;width:7px;height:7px;border-radius:50%;background:#10b981;
  animation:lpulse 1.4s infinite;margin-right:6px}
@keyframes lpulse{0%,100%{opacity:1}50%{opacity:.35}}
.b-kpis{display:flex;gap:20px;flex-wrap:wrap;position:relative;z-index:1}
.bk{text-align:center}.bk-v{font-size:1.7rem;font-weight:800;color:#fff;line-height:1}
.bk-l{font-size:10px;color:rgba(255,255,255,.55);text-transform:uppercase;letter-spacing:.06em;margin-top:2px}
.bdiv{width:1px;background:rgba(255,255,255,.18);align-self:stretch}
.stat-row{display:grid;grid-template-columns:repeat(4,1fr);gap:12px;margin-bottom:20px}
@media(max-width:700px){.stat-row{grid-template-columns:1fr 1fr}}
.sc{background:var(--card);border:1px solid var(--bd);border-radius:var(--rad);
  padding:12px 14px;display:flex;align-items:center;gap:10px;box-shadow:var(--sh)}
.sc-ico{width:38px;height:38px;border-radius:9px;display:flex;align-items:center;justify-content:center;font-size:15px}
.sc-val{font-size:1.4rem;font-weight:800;line-height:1}
.sc-lbl{font-size:10px;font-weight:700;text-transform:uppercase;letter-spacing:.05em;color:var(--ts);margin-top:2px}
.toolbar{background:var(--card);border:1px solid var(--bd);border-radius:var(--rad);
  padding:11px 14px;margin-bottom:12px;display:flex;align-items:center;gap:10px;flex-wrap:wrap;box-shadow:var(--sh)}
.sb{position:relative;flex:1;min-width:180px}
.sb i{position:absolute;left:9px;top:50%;transform:translateY(-50%);color:var(--tm);font-size:12px;pointer-events:none}
.sb input{width:100%;border:1.5px solid var(--bd);border-radius:8px;
  padding:8px 10px 8px 28px;font-size:13px;font-family:inherit;color:var(--tx);background:var(--bg)}
.sb input:focus{border-color:var(--p);outline:none}
.fsel{border:1.5px solid var(--bd);border-radius:8px;padding:8px 10px;
  font-size:13px;font-family:inherit;color:var(--tx);background:var(--bg);cursor:pointer}
.pill-bar{display:flex;gap:6px;flex-wrap:wrap;margin-bottom:12px}
.pill{padding:5px 14px;border-radius:99px;border:1.5px solid var(--bd);font-size:12px;
  font-weight:600;cursor:pointer;background:var(--card);color:var(--ts);transition:.15s;font-family:inherit}
.pill:hover,.pill.on{background:var(--p);color:#fff;border-color:var(--p)}
.act-row{display:flex;gap:8px;flex-wrap:wrap;justify-content:flex-end;margin-bottom:12px}
.btn-o{background:var(--card);color:var(--ts);border:1.5px solid var(--bd);
  border-radius:var(--rads);padding:7px 13px;font-size:13px;font-weight:600;
  cursor:pointer;font-family:inherit;display:inline-flex;align-items:center;gap:6px;transition:.18s}
.btn-o:hover{border-color:var(--p);color:var(--p)}
.btn-r{background:#fff0f0;color:var(--r);border:1.5px solid #fecaca;
  border-radius:var(--rads);padding:7px 13px;font-size:13px;font-weight:700;
  cursor:pointer;font-family:inherit;display:inline-flex;align-items:center;gap:6px;transition:.18s}
.btn-r:hover{background:var(--rl)}
.notif-list{display:flex;flex-direction:column;gap:8px;margin-bottom:16px}
.ni{background:var(--card);border:1.5px solid var(--bd);border-radius:var(--rad);
  padding:13px 15px;display:flex;align-items:flex-start;gap:12px;box-shadow:var(--sh);transition:.2s;position:relative}
.ni:hover{box-shadow:var(--shl);transform:translateY(-1px)}
.ni.unread{border-left:3px solid var(--p);background:#fafbff}
.ni-dot{position:absolute;top:13px;right:13px;width:8px;height:8px;border-radius:50%;background:var(--p)}
.ni-ico{width:42px;height:42px;border-radius:11px;display:flex;align-items:center;justify-content:center;font-size:16px;flex-shrink:0}
.ni-body{flex:1;min-width:0}
.ni-tag{display:inline-block;padding:2px 8px;border-radius:5px;font-size:10px;font-weight:700;letter-spacing:.04em;margin-bottom:4px}
.ni-msg{font-size:13px;font-weight:500;color:var(--tx);line-height:1.55;margin-bottom:4px}
.ni-meta{font-size:11px;color:var(--tm);display:flex;align-items:center;gap:8px;flex-wrap:wrap}
.ni-acts{display:flex;gap:5px;flex-shrink:0}
.na{width:28px;height:28px;border:none;border-radius:7px;cursor:pointer;
  display:flex;align-items:center;justify-content:center;font-size:11px;transition:.15s}
.na:hover{filter:brightness(.88)}
.na-read{background:#dbeafe;color:var(--b)}
.na-del{background:var(--rl);color:var(--r)}
.empty{text-align:center;padding:56px 20px;color:var(--tm)}
.empty i{font-size:2.6rem;opacity:.13;display:block;margin-bottom:12px}
.empty h5{font-size:14px;font-weight:700;margin-bottom:5px;color:var(--ts)}
.empty p{font-size:13px}
.pager{display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:10px}
.pager-info{font-size:12px;color:var(--ts)}
.pager-btns{display:flex;gap:4px}
.pb{min-width:30px;height:30px;border:1.5px solid var(--bd);border-radius:7px;
  background:var(--card);color:var(--ts);font-size:12px;font-weight:600;
  cursor:pointer;font-family:inherit;display:flex;align-items:center;justify-content:center;padding:0 7px;transition:.15s}
.pb:hover{border-color:var(--p);color:var(--p)}
.pb.on{background:var(--p);color:#fff;border-color:var(--p)}
.pb:disabled{opacity:.35;cursor:default}
#toast-root{position:fixed;bottom:20px;right:20px;z-index:99999;display:flex;flex-direction:column;gap:8px;pointer-events:none}
.nt{border-radius:10px;padding:11px 15px;font-size:13px;font-weight:600;color:#fff;
  animation:tIn .3s ease;max-width:340px;pointer-events:auto;box-shadow:var(--shl);display:flex;align-items:center;gap:8px}
.nt.ok{background:#059669}.nt.err{background:#dc2626}.nt.warn{background:#d97706}.nt.inf{background:var(--p)}
@keyframes tIn{from{opacity:0;transform:translateX(40px)}to{opacity:1;transform:none}}
@keyframes spin{to{transform:rotate(360deg)}}
.spinner{display:inline-block;width:20px;height:20px;border:2px solid var(--bd);
  border-top-color:var(--p);border-radius:50%;animation:spin .7s linear infinite}
</style>
</asp:Content>

<asp:Content ID="cBody" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<asp:HiddenField ID="hfInstId" runat="server"/>
<asp:HiddenField ID="hfSessId" runat="server"/>
<asp:HiddenField ID="hfUserId" runat="server"/>
<asp:HiddenField ID="hfSocId"  runat="server"/>

<div class="wrap">
  <div class="banner">
    <div class="b-left">
      <div class="b-title"><i class="fa fa-bell me-2"></i>My Notifications</div>
      <div class="b-sub"><span class="live-dot"></span>Live &bull; Session: <strong style="color:#fff" id="bSessName">—</strong></div>
    </div>
    <div class="b-kpis">
      <div class="bk"><div class="bk-v" id="bTotal">0</div><div class="bk-l">Total</div></div>
      <div class="bdiv"></div>
      <div class="bk"><div class="bk-v" id="bUnread">0</div><div class="bk-l">Unread</div></div>
      <div class="bdiv"></div>
      <div class="bk"><div class="bk-v" id="bToday">0</div><div class="bk-l">Today</div></div>
    </div>
  </div>

  <div class="stat-row">
    <div class="sc"><div class="sc-ico" style="background:var(--pl);color:var(--p)"><i class="fa fa-bell"></i></div>
      <div><div class="sc-val" id="sTotal">0</div><div class="sc-lbl">Total</div></div></div>
    <div class="sc"><div class="sc-ico" style="background:var(--rl);color:var(--r)"><i class="fa fa-circle-dot"></i></div>
      <div><div class="sc-val" id="sUnread">0</div><div class="sc-lbl">Unread</div></div></div>
    <div class="sc"><div class="sc-ico" style="background:var(--gl);color:var(--g)"><i class="fa fa-check-circle"></i></div>
      <div><div class="sc-val" id="sRead">0</div><div class="sc-lbl">Read</div></div></div>
    <div class="sc"><div class="sc-ico" style="background:var(--bl);color:var(--b)"><i class="fa fa-calendar-day"></i></div>
      <div><div class="sc-val" id="sToday">0</div><div class="sc-lbl">Today</div></div></div>
  </div>

  <div class="act-row">
    <button type="button" class="btn-o" id="btnMarkAll"><i class="fa fa-check-double"></i> Mark All Read</button>
    <button type="button" class="btn-r" id="btnDelAll"><i class="fa fa-trash-alt"></i> Clear All</button>
  </div>

  <div class="pill-bar" id="pillBar">
    <button type="button" class="pill on" data-f="All">All</button>
    <button type="button" class="pill" data-f="Unread">🔴 Unread</button>
    <button type="button" class="pill" data-f="Read">✅ Read</button>
  </div>

  <div class="toolbar">
    <div class="sb"><i class="fa fa-search"></i>
      <input type="text" id="txtSearch" placeholder="Search notifications…"/></div>
    <select id="selType" class="fsel"><option value="">All Types</option></select>
    <select id="selPg" class="fsel">
      <option value="20">20 / page</option>
      <option value="50">50 / page</option>
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
<div id="toast-root"></div>

<script>
(function(){
    'use strict';
    var INST  = parseInt('<%= hfInstId.Value %>') || 0;
    var SESS  = parseInt('<%= hfSessId.Value %>') || 0;
    var UID   = parseInt('<%= hfUserId.Value %>') || 0;
    var SOC   = parseInt('<%= hfSocId.Value  %>') || 0;
    var BASE  = location.pathname;
    var SNAME = '<%= Session["SessionName"] ?? "" %>';
    document.getElementById('bSessName').textContent = SNAME;

    var state = { filter:'All', type:'', search:'', page:1, pgsize:20 };
    var debT = null, lastUnread = -1, liveTimer = null;

    function toast(msg,type){
        var w=document.getElementById('toast-root');
        var d=document.createElement('div'); d.className='nt '+(type||'inf');
        var ic={ok:'fa-check-circle',err:'fa-times-circle',warn:'fa-exclamation-triangle',inf:'fa-info-circle'};
        d.innerHTML='<i class="fa '+(ic[type]||'fa-info-circle')+'"></i><span>'+msg+'</span>';
        w.appendChild(d);
        setTimeout(function(){d.style.opacity='0';d.style.transition='opacity .4s';setTimeout(function(){d.remove();},400);},5000);
    }
    function api(action,extra,method){
        var qs='?ajax='+action+'&inst='+INST+'&sess='+SESS+'&uid='+UID+'&soc='+SOC+(extra||'');
        if(!method||method==='GET') return fetch(BASE+qs);
        return fetch(BASE+qs,{method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded'},
            body:'ajax='+action+'&inst='+INST+'&sess='+SESS+'&uid='+UID+'&soc='+SOC+(extra||'')});
    }

    var PALETTE=['#4f46e5','#d97706','#059669','#dc2626','#db2777','#0d9488','#0284c7','#7c3aed','#ea580c','#0f766e'];
    var typeCache={};
    function colorFor(t){ if(!typeCache[t]){var h=0;for(var i=0;i<t.length;i++)h=(h*31+t.charCodeAt(i))&0xffff;typeCache[t]=PALETTE[h%PALETTE.length];} return typeCache[t]; }
    function fmtType(t){ return (t||'General').replace(/([A-Z])/g,' $1').trim(); }
    function fmtAgo(m){ if(!m||m<1)return 'Just now'; if(m<60)return m+'m ago'; var h=Math.floor(m/60); if(h<24)return h+'h ago'; return Math.floor(h/24)+'d ago'; }
    function esc(s){ return String(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
    function cu(id,n){ var el=document.getElementById(id);if(!el)return; var s=parseInt(el.textContent)||0,diff=n-s,steps=20,i=0; var iv=setInterval(function(){i++;el.textContent=Math.round(s+diff*(i/steps));if(i>=steps){el.textContent=n;clearInterval(iv);}},16); }
    function sv(id,n){ var el=document.getElementById(id);if(el)el.textContent=n; }

    function fetchStats(){
        api('stats').then(function(r){return r.json();}).then(function(s){
            cu('sTotal',s.Total||0);cu('sUnread',s.Unread||0);cu('sRead',s.ReadCount||0);cu('sToday',s.Today||0);
            sv('bTotal',s.Total||0);sv('bUnread',s.Unread||0);sv('bToday',s.Today||0);
            var nu=s.Unread||0; if(lastUnread>=0&&nu>lastUnread) fetchList();
            lastUnread=nu; updateHeaderBadge(nu);
        }).catch(function(){});
    }

    function fetchList(){
        document.getElementById('notifList').innerHTML='<div class="empty"><div class="spinner"></div></div>';
        api('list','&filter='+encodeURIComponent(state.filter)+'&type='+encodeURIComponent(state.type)
            +'&search='+encodeURIComponent(state.search)+'&page='+state.page+'&pgsize='+state.pgsize)
        .then(function(r){return r.json();})
        .then(function(d){
            if(d.stats){ var s=d.stats;
                cu('sTotal',s.Total||0);cu('sUnread',s.Unread||0);cu('sRead',s.ReadCount||0);cu('sToday',s.Today||0);
                sv('bTotal',s.Total||0);sv('bUnread',s.Unread||0);sv('bToday',s.Today||0);
                lastUnread=s.Unread||0; updateHeaderBadge(lastUnread);
            }
            render(d.items||[],d.total||0,d.page||1,d.pgsize||20);
        }).catch(function(e){console.error(e);});
    }

    function render(items,total,page,pgsize){
        var list=document.getElementById('notifList');
        if(!items.length){
            list.innerHTML='<div class="empty"><i class="fa fa-bell-slash"></i><h5>No notifications</h5><p>You\'re all caught up!</p></div>';
            document.getElementById('pager').style.display='none';
            document.getElementById('recInfo').textContent='0 records'; return;
        }
        list.innerHTML=items.map(function(n){
            var col=colorFor(n.NotificationType||'General'),unread=!n.IsRead;
            return '<div class="ni'+(unread?' unread':'')+'" data-id="'+n.NotificationId+'">'
                +(unread?'<div class="ni-dot"></div>':'')
                +'<div class="ni-ico" style="background:'+col+'20;color:'+col+'"><i class="fa fa-bell"></i></div>'
                +'<div class="ni-body">'
                +'<div class="ni-tag" style="background:'+col+'18;color:'+col+'">'+esc(fmtType(n.NotificationType))+'</div>'
                +'<div class="ni-msg">'+esc(n.Message||'')+'</div>'
                +'<div class="ni-meta"><i class="fa fa-clock"></i>'+fmtAgo(n.MinutesAgo)+'</div>'
                +'</div>'
                +'<div class="ni-acts">'
                +(unread?'<button class="na na-read" data-act="read" data-id="'+n.NotificationId+'" title="Mark read"><i class="fa fa-check"></i></button>':'')
                +'<button class="na na-del" data-act="del" data-id="'+n.NotificationId+'" title="Delete"><i class="fa fa-trash"></i></button>'
                +'</div></div>';
        }).join('');
        list.querySelectorAll('.na').forEach(function(btn){
            btn.addEventListener('click',function(e){ e.stopPropagation();
                if(this.dataset.act==='read') doMarkRead(this.dataset.id,this.closest('.ni'));
                else doDelete(this.dataset.id,this.closest('.ni'));
            });
        });
        var from=Math.min((page-1)*pgsize+1,total),to=Math.min(page*pgsize,total);
        document.getElementById('recInfo').textContent='Showing '+from+'–'+to+' of '+total;
        buildPager(total,page,pgsize);
    }

    function buildPager(total,page,pgsize){
        var totalPages=Math.max(1,Math.ceil(total/pgsize));
        var pager=document.getElementById('pager');
        document.getElementById('pagerInfo').textContent='Page '+page+' of '+totalPages;
        if(totalPages<=1){pager.style.display='none';return;}
        pager.style.display='flex';
        var btns=document.getElementById('pagerBtns'); btns.innerHTML='';
        function ab(t,p,dis,act){var b=document.createElement('button');b.type='button';b.className='pb'+(act?' on':'');b.textContent=t;b.disabled=dis;b.addEventListener('click',function(){state.page=p;fetchList();});btns.appendChild(b);}
        ab('«',1,page===1,false);ab('‹',page-1,page===1,false);
        var st=Math.max(1,page-2),en=Math.min(totalPages,st+4);
        for(var p2=st;p2<=en;p2++) ab(p2,p2,false,p2===page);
        ab('›',page+1,page>=totalPages,false);ab('»',totalPages,page>=totalPages,false);
    }

    function doMarkRead(id,el){
        api('markread','&id='+id,'POST').then(function(r){return r.json();}).then(function(){fetchList();});
    }
    function doDelete(id,el){
        if(!confirm('Delete this notification?')) return;
        api('delete','&id='+id,'POST').then(function(r){return r.json();})
        .then(function(){ if(el){el.style.opacity='0';el.style.transition='opacity .3s';setTimeout(function(){fetchList();},300);} toast('Deleted','ok'); })
        .catch(function(){toast('Delete failed','err');});
    }
    document.getElementById('btnMarkAll').addEventListener('click',function(){
        api('markall','','POST').then(function(r){return r.json();}).then(function(){fetchList();toast('All marked as read','ok');}).catch(function(){toast('Failed','err');});
    });
    document.getElementById('btnDelAll').addEventListener('click',function(){
        if(!confirm('Delete ALL your notifications? This cannot be undone.')) return;
        api('deleteall','','POST').then(function(r){return r.json();}).then(function(){fetchList();toast('All cleared','ok');}).catch(function(){toast('Failed','err');});
    });

    document.getElementById('pillBar').addEventListener('click',function(e){
        var btn=e.target.closest('.pill'); if(!btn) return;
        document.querySelectorAll('.pill').forEach(function(p){p.classList.remove('on');});
        btn.classList.add('on'); state.filter=btn.dataset.f; state.page=1; fetchList();
    });
    function loadTypes(){
        api('types').then(function(r){return r.json();}).then(function(d){
            var sel=document.getElementById('selType');
            (d.types||[]).forEach(function(t){var o=document.createElement('option');o.value=t;o.textContent=fmtType(t);sel.appendChild(o);});
        });
    }
    document.getElementById('selType').addEventListener('change',function(){state.type=this.value;state.page=1;fetchList();});
    document.getElementById('selPg').addEventListener('change',function(){state.pgsize=parseInt(this.value);state.page=1;fetchList();});
    document.getElementById('txtSearch').addEventListener('input',function(){
        clearTimeout(debT);var v=this.value;debT=setTimeout(function(){state.search=v;state.page=1;fetchList();},400);
    });

    function updateHeaderBadge(unread){
        var dot=document.getElementById('headerNotifDot');
        var badge=document.getElementById('headerNotifBadge');
        if(dot) dot.style.display=unread>0?'block':'none';
        if(badge){badge.textContent=unread>99?'99+':unread;badge.style.display=unread>0?'':'none';}
    }

    loadTypes();
    fetchStats();
    fetchList();
    liveTimer = setInterval(fetchStats,30000);
})();
</script>
</asp:Content>
