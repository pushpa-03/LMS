<%@ Page Title="Courses"
    Language="C#"
    MasterPageFile="~/Admin/AdminMaster.master"
    AutoEventWireup="true"
    CodeBehind="AddCourse.aspx.cs"
    Inherits="LearningManagementSystem.Admin.AddCourse" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=DM+Mono:wght@400;500&display=swap" rel="stylesheet">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

<%-- ══ HIDDEN / STATE ══════════════════════════════════════════════════ --%>
<asp:HiddenField ID="hfCourseId"      runat="server" />
<asp:HiddenField ID="hfFilterStatus"  runat="server" Value="All" />
<asp:HiddenField ID="hfToastMsg"      runat="server" />
<asp:HiddenField ID="hfToastType"     runat="server" />
<%-- Preserve client pagination/filter state across async postbacks --%>
<asp:HiddenField ID="hfClientPage"    runat="server" Value="1" />
<asp:HiddenField ID="hfClientFilter"  runat="server" Value="All" />

<style>
/* ═══════════════════════════════════════════════════════════════════
   COURSE MANAGEMENT — Blue Professional
   Plus Jakarta Sans · DM Mono
═══════════════════════════════════════════════════════════════════ */
:root {
  --blue:     #1565c0;
  --blue2:    #1976d2;
  --blue3:    #2196f3;
  --blue-lt:  #e3f2fd;
  --blue-mid: #bbdefb;
  --indigo:   #4f46e5;
  --indigo-lt:#eef2ff;
  --green:    #2e7d32;
  --green-lt: #e8f5e9;
  --amber:    #e65100;
  --amber-lt: #fff3e0;
  --red:      #c62828;
  --red-lt:   #ffebee;
  --surf:     #ffffff;
  --surf2:    #f7f9fd;
  --surf3:    #eef2f9;
  --bdr:      #e2e8f4;
  --bdr2:     #c8d4ec;
  --ink:      #0d1b2a;
  --ink2:     #1a2a3a;
  --ink3:     #334155;
  --muted:    #64748b;
  --dim:      #94a3b8;
  --f:        'Plus Jakarta Sans', system-ui, sans-serif;
  --mono:     'DM Mono', monospace;
  --r:        10px;
  --rlg:      14px;
  --sh:       0 1px 3px rgba(13,27,42,.06), 0 4px 14px rgba(13,27,42,.07);
  --sh2:      0 4px 20px rgba(13,27,42,.10), 0 10px 36px rgba(13,27,42,.08);
}

*, *::before, *::after { box-sizing: border-box; }
.ac-root { font-family: var(--f); color: var(--ink); font-size: 14px; }

/* ── PAGE HEADER ── */
.ac-header {
  display: flex; align-items: flex-start; justify-content: space-between;
  flex-wrap: wrap; gap: 14px; margin-bottom: 22px;
}
.ac-h-left {}
.ac-h-eyebrow {
  font-size: 10px; font-weight: 700; letter-spacing: .12em; text-transform: uppercase;
  color: var(--blue2); display: flex; align-items: center; gap: 6px; margin-bottom: 5px;
}
.ac-h-eyebrow::before {
  content: ''; width: 14px; height: 2px;
  background: linear-gradient(90deg, var(--blue), var(--blue3)); border-radius: 1px;
}
.ac-h-title { font-size: 1.45rem; font-weight: 800; color: var(--ink); }
.ac-h-title span { color: var(--blue2); }
.ac-h-sub { font-size: 12px; color: var(--muted); margin-top: 3px; }
.ac-h-right { display: flex; align-items: center; gap: 10px; flex-wrap: wrap; }

/* ── STAT CARDS ── */
.ac-stats { display: grid; grid-template-columns: repeat(3,1fr); gap: 14px; margin-bottom: 22px; }
@media(max-width:600px){ .ac-stats { grid-template-columns: 1fr; } }
.ac-stat {
  background: var(--surf); border: 1px solid var(--bdr); border-radius: var(--rlg);
  padding: 18px 20px; display: flex; align-items: center; gap: 14px;
  box-shadow: var(--sh); transition: transform .2s, box-shadow .2s;
  animation: statUp .4s both;
}
.ac-stat:hover { transform: translateY(-3px); box-shadow: var(--sh2); }
@keyframes statUp { from{opacity:0;transform:translateY(12px)} to{opacity:1;transform:translateY(0)} }
.ac-stat-ico {
  width: 44px; height: 44px; border-radius: 11px; flex-shrink: 0;
  display: flex; align-items: center; justify-content: center; font-size: 17px;
}
.ac-stat-val { font-size: 1.6rem; font-weight: 800; line-height: 1; color: var(--ink); font-family: var(--mono); }
.ac-stat-lbl { font-size: 11px; font-weight: 600; color: var(--muted); margin-top: 2px; text-transform: uppercase; letter-spacing: .05em; }

/* ── TOOLBAR ── */
.ac-toolbar {
  display: flex; align-items: center; gap: 10px; flex-wrap: wrap;
  padding: 12px 18px; background: var(--surf); border: 1px solid var(--bdr);
  border-radius: var(--rlg); box-shadow: var(--sh); margin-bottom: 20px;
}
.ac-search-wrap { position: relative; flex: 1; min-width: 180px; }
.ac-search-wrap i { position: absolute; left: 11px; top: 50%; transform: translateY(-50%); color: var(--dim); font-size: 12px; pointer-events: none; }
.ac-search-input {
  width: 100%; padding: 8px 13px 8px 34px;
  border: 1.5px solid var(--bdr); border-radius: 30px;
  font-family: var(--f); font-size: 13px; color: var(--ink2);
  background: var(--surf2); outline: none; transition: border-color .18s, box-shadow .18s;
}
.ac-search-input:focus { border-color: var(--blue2); box-shadow: 0 0 0 3px rgba(25,118,210,.10); }
.ac-filter-btn {
  display: inline-flex; align-items: center; gap: 6px;
  padding: 8px 16px; border-radius: 8px; border: 1.5px solid var(--bdr);
  font-family: var(--f); font-size: 12px; font-weight: 700; cursor: pointer;
  background: var(--surf); color: var(--ink3); transition: all .18s; white-space: nowrap;
}
.ac-filter-btn.active-filter  { background: var(--green-lt); color: var(--green); border-color: #a5d6a7; }
.ac-filter-btn.inactive-filter{ background: var(--red-lt);   color: var(--red);   border-color: #ef9a9a; }
.ac-filter-btn.all-filter     { background: var(--blue-lt);  color: var(--blue);  border-color: var(--blue-mid); }
.ac-filter-btn:hover { transform: translateY(-1px); }
.ac-add-btn {
  display: inline-flex; align-items: center; gap: 7px;
  padding: 8px 20px; border-radius: 9px; border: none;
  font-family: var(--f); font-size: 13px; font-weight: 700; cursor: pointer;
  background: linear-gradient(135deg, var(--blue), var(--blue2));
  color: #fff; box-shadow: 0 4px 12px rgba(21,101,192,.3); transition: all .18s; white-space: nowrap;
}
.ac-add-btn:hover { box-shadow: 0 6px 20px rgba(21,101,192,.45); transform: translateY(-1px); color: #fff; text-decoration: none; }

/* ── PAGE INFO BAR ── */
.ac-info-bar {
  display: flex; align-items: center; justify-content: space-between;
  flex-wrap: wrap; gap: 10px; margin-bottom: 14px;
}
.ac-showing { font-size: 12px; color: var(--muted); font-weight: 500; }
.ac-showing b { color: var(--ink3); }
.ac-filter-active-badge {
  display: inline-flex; align-items: center; gap: 5px;
  padding: 3px 11px; border-radius: 20px; font-size: 11px; font-weight: 700;
}

/* ── STREAM SECTION ── */
.ac-stream-section {
  background: var(--surf); border: 1px solid var(--bdr);
  border-radius: var(--rlg); box-shadow: var(--sh);
  overflow: hidden; margin-bottom: 18px;
  transition: box-shadow .22s; animation: cardIn .38s both;
}
.ac-stream-section:hover { box-shadow: var(--sh2); }
@keyframes cardIn { from{opacity:0;transform:translateY(10px)} to{opacity:1;transform:translateY(0)} }

.ac-stream-head {
  display: flex; align-items: center; justify-content: space-between;
  padding: 14px 20px; cursor: pointer; user-select: none;
  background: linear-gradient(135deg, #4f46e5 0%, #6366f1 100%);
  transition: filter .18s;
}
.ac-stream-head:hover { filter: brightness(1.08); }
.ac-stream-head-left { display: flex; align-items: center; gap: 12px; }
.ac-stream-icon {
  width: 36px; height: 36px; border-radius: 9px; flex-shrink: 0;
  background: rgba(255,255,255,.18); display: flex; align-items: center;
  justify-content: center; font-size: 16px; color: #fff;
}
.ac-stream-name  { font-size: 15px; font-weight: 700; color: #fff; }
.ac-stream-count {
  display: inline-flex; align-items: center; gap: 4px;
  background: rgba(255,255,255,.22); border-radius: 20px;
  padding: 2px 11px; font-size: 11px; font-weight: 700; color: #fff;
}
.ac-stream-chevron { color: rgba(255,255,255,.8); font-size: 13px; transition: transform .25s; }
.ac-stream-section.collapsed .ac-stream-chevron { transform: rotate(-90deg); }

.ac-stream-body { overflow: hidden; }
.ac-stream-body.hidden { display: none; }

/* ── COURSE TABLE ── */
.ac-table-wrap { overflow-x: auto; }
.ac-table { width: 100%; border-collapse: collapse; font-size: 13px; }
.ac-table thead th {
  padding: 10px 16px; text-align: left;
  font-size: 10px; font-weight: 700; text-transform: uppercase;
  letter-spacing: .07em; color: var(--muted);
  background: var(--surf3); border-bottom: 1px solid var(--bdr); white-space: nowrap;
}
.ac-table tbody tr { transition: background .15s; }
.ac-table tbody tr:hover { background: #f5f8ff; }
.ac-table tbody td {
  padding: 12px 16px; border-bottom: 1px solid var(--bdr);
  vertical-align: middle; color: var(--ink3);
}
.ac-table tbody tr:last-child td { border-bottom: none; }
.ac-course-name { font-weight: 600; color: var(--ink2); }
.ac-code-chip {
  display: inline-block; font-family: var(--mono); font-size: 11px;
  background: var(--blue-lt); color: var(--blue2); border: 1px solid var(--blue-mid);
  border-radius: 6px; padding: 2px 9px;
}
.ac-status-badge {
  display: inline-flex; align-items: center; gap: 3px;
  border-radius: 20px; padding: 2px 9px; font-size: 10px; font-weight: 700;
}
.ac-status-badge.active   { background: var(--green-lt); color: var(--green); }
.ac-status-badge.inactive { background: var(--red-lt);   color: var(--red); }
.ac-status-badge::before  { content: ''; width: 5px; height: 5px; border-radius: 50%; background: currentColor; }

/* Action btns */
.ac-act { display: flex; gap: 5px; }
.ac-act-btn {
  width: 30px; height: 30px; border-radius: 8px; border: 1.5px solid var(--bdr);
  background: var(--surf); display: inline-flex; align-items: center;
  justify-content: center; font-size: 11px; cursor: pointer;
  color: var(--ink3); transition: all .18s; text-decoration: none;
}
.ac-act-btn.edit:hover   { background: var(--blue-lt);  color: var(--blue2); border-color: var(--blue-mid); }
.ac-act-btn.toggle:hover { background: var(--amber-lt); color: var(--amber); border-color: #ffcc80; }
.ac-act-btn.del:hover    { background: var(--red-lt);   color: var(--red);   border-color: #ef9a9a; }
.ac-view-only { font-size: 11px; color: var(--dim); font-style: italic; }

/* ── EMPTY STATE ── */
.ac-empty {
  text-align: center; padding: 48px 20px;
  background: var(--surf); border: 1px solid var(--bdr);
  border-radius: var(--rlg); box-shadow: var(--sh);
}
.ac-empty-icon {
  width: 60px; height: 60px; border-radius: 16px;
  background: var(--blue-lt); border: 2px dashed var(--blue-mid);
  display: flex; align-items: center; justify-content: center;
  font-size: 22px; color: var(--blue2); margin: 0 auto 14px;
}
.ac-empty-title { font-size: 16px; font-weight: 700; color: var(--ink3); margin-bottom: 5px; }
.ac-empty-sub   { font-size: 13px; color: var(--dim); }

/* ── PAGINATION ── */
.ac-pagination-wrap {
  display: flex; align-items: center; justify-content: space-between;
  flex-wrap: wrap; gap: 12px; margin-top: 20px; padding: 14px 20px;
  background: var(--surf); border: 1px solid var(--bdr);
  border-radius: var(--rlg); box-shadow: var(--sh);
}
.ac-page-info { font-size: 12px; color: var(--muted); font-weight: 500; }
.ac-page-info b { color: var(--ink3); }
.ac-page-btns { display: flex; align-items: center; gap: 4px; flex-wrap: wrap; }
.ac-pg-btn {
  min-width: 36px; height: 36px; border-radius: 8px;
  border: 1.5px solid var(--bdr); background: var(--surf);
  font-family: var(--f); font-size: 13px; font-weight: 600;
  color: var(--ink3); cursor: pointer; transition: all .18s;
  display: inline-flex; align-items: center; justify-content: center; padding: 0 8px;
  text-decoration: none;
}
.ac-pg-btn:hover:not(.active):not(.disabled) {
  border-color: var(--blue2); color: var(--blue); background: var(--blue-lt);
}
.ac-pg-btn.active { background: var(--blue); border-color: var(--blue); color: #fff; box-shadow: 0 4px 12px rgba(21,101,192,.28); }
.ac-pg-btn.disabled { opacity: .35; cursor: not-allowed; pointer-events: none; }
.ac-pg-sep { width: 36px; height: 36px; display: inline-flex; align-items: center; justify-content: center; color: var(--dim); font-size: 13px; }

/* ── MODAL ── */
.modal { z-index: 99999 !important; }
.modal-backdrop { z-index: 99990 !important; }
.modal-dialog { margin-top: 88px !important; }
.modal-content { border: none !important; border-radius: 16px !important; box-shadow: var(--sh2); }
.modal-header-blue {
  background: linear-gradient(135deg, var(--blue), var(--blue2));
  border-radius: 15px 15px 0 0; padding: 16px 22px;
}
.modal-header-blue h5 { color: #fff; font-weight: 700; margin: 0; font-size: 15px; }
.modal-header-blue .btn-close { filter: invert(1) brightness(2); }

.ac-field { margin-bottom: 14px; }
.ac-field label { font-size: 11px; font-weight: 700; text-transform: uppercase; letter-spacing: .06em; color: var(--muted); margin-bottom: 5px; display: block; }
.ac-field label .req { color: var(--red); margin-left: 2px; }
.ac-fi {
  width: 100%; border: 1.5px solid var(--bdr); border-radius: var(--r);
  padding: 9px 13px; font-family: var(--f); font-size: 13px;
  color: var(--ink2); background: var(--surf2); outline: none;
  transition: border-color .18s, box-shadow .18s;
}
.ac-fi:focus { border-color: var(--blue2); background: var(--surf); box-shadow: 0 0 0 3px rgba(25,118,210,.11); }
.ac-fi.is-invalid { border-color: var(--red); background: #fff8f8; }
.ac-fi.is-valid   { border-color: var(--green); }
.ac-fi-err { font-size: 11px; font-weight: 600; color: var(--red); margin-top: 3px; min-height: 14px; }
.ac-modal-footer { display: flex; gap: 8px; justify-content: flex-end; padding: 14px 22px; border-top: 1px solid var(--bdr); }
.ac-modal-btn {
  display: inline-flex; align-items: center; gap: 6px;
  padding: 8px 20px; border-radius: 9px; border: none;
  font-family: var(--f); font-size: 13px; font-weight: 700; cursor: pointer; transition: all .18s;
}
.ac-modal-btn.primary { background: linear-gradient(135deg,var(--blue),var(--blue2)); color:#fff; box-shadow:0 4px 12px rgba(21,101,192,.3); }
.ac-modal-btn.primary:hover { box-shadow: 0 6px 20px rgba(21,101,192,.45); }
.ac-modal-btn.cancel { background: var(--surf3); color: var(--ink3); border: 1.5px solid var(--bdr); }
.ac-modal-btn.cancel:hover { background: var(--bdr); }

/* ── UpdatePanel loading overlay ── */
#gridLoadOverlay {
  display: none; position: absolute; inset: 0;
  background: rgba(255,255,255,.65); border-radius: var(--rlg);
  z-index: 50; align-items: center; justify-content: center;
}
#gridLoadOverlay.show { display: flex; }
.grid-spinner {
  width: 28px; height: 28px; border: 3px solid var(--bdr);
  border-top-color: var(--blue); border-radius: 50%;
  animation: spin .7s linear infinite;
}
@keyframes spin { to { transform: rotate(360deg); } }
.grid-relative { position: relative; }

/* ── TOAST ── */
.ac-toast {
  position: fixed; top: 20px; right: 20px; z-index: 999999;
  min-width: 290px; max-width: 400px;
  background: var(--surf); border: 1.5px solid var(--bdr); border-radius: 12px;
  padding: 13px 16px; box-shadow: var(--sh2);
  display: flex; align-items: center; gap: 11px;
  transform: translateX(440px); transition: transform .36s cubic-bezier(.4,0,.2,1);
  overflow: hidden;
}
.ac-toast.show { transform: translateX(0); }
.ac-toast.success { border-color: #a5d6a7; background: #f1f8f1; }
.ac-toast.error   { border-color: #ef9a9a; background: #fff5f5; }
.ac-toast.warning { border-color: #ffcc80; background: #fffdf0; }
.ac-toast-icon { width: 32px; height: 32px; border-radius: 8px; flex-shrink: 0; display: flex; align-items: center; justify-content: center; font-size: 14px; }
.ac-toast.success .ac-toast-icon { background: var(--green-lt); color: var(--green); }
.ac-toast.error   .ac-toast-icon { background: var(--red-lt);   color: var(--red); }
.ac-toast.warning .ac-toast-icon { background: var(--amber-lt); color: var(--amber); }
.ac-toast-msg { font-size: 13px; font-weight: 600; color: var(--ink3); flex: 1; }
.ac-toast-close { background: none; border: none; cursor: pointer; color: var(--dim); font-size: 14px; }
.ac-toast-bar { position: absolute; bottom: 0; left: 0; height: 3px; border-radius: 0 0 12px 12px; animation: shrinkBar 4.5s linear forwards; }
.ac-toast.success .ac-toast-bar { background: var(--green); }
.ac-toast.error   .ac-toast-bar { background: var(--red); }
.ac-toast.warning .ac-toast-bar { background: var(--amber); }
@keyframes shrinkBar { from{width:100%} to{width:0} }

/* ── RESPONSIVE ── */
@media(max-width:768px) {
  .ac-header { flex-direction: column; }
  .ac-h-right { width: 100%; }
  .ac-add-btn { width: 100%; justify-content: center; }
  .ac-toolbar { flex-direction: column; align-items: stretch; }
  .ac-search-wrap { min-width: unset; }
  .ac-table { min-width: 520px; }
  .modal-dialog { margin: 12px !important; }
}
</style>

<%-- ══ TOAST (outside UpdatePanel so it's never replaced) ══════════ --%>
<div class="ac-toast" id="acToast">
    <div class="ac-toast-icon" id="acToastIco"><i class="fa fa-check" id="acToastIcoI"></i></div>
    <div class="ac-toast-msg"  id="acToastMsg"></div>
    <button class="ac-toast-close" onclick="hideToast()" type="button"><i class="fa fa-times"></i></button>
    <div class="ac-toast-bar"  id="acToastBar"></div>
</div>

<div class="ac-root">

<%-- ══ PAGE HEADER (static — outside UpdatePanel) ═════════════════ --%>
<div class="ac-header">
    <div>
        <h3 class="fw-bold mb-1">Course Management</h3>
        <small class="text-muted">Manage all academic Courses</small>
        <span>|</span>
        <small class="text-muted">Last updated: <%= DateTime.Now.ToString("dd MMM yyyy hh:mm tt") %></small>
    </div>
    <div class="ac-h-right">
        <% if (!IsSuperAdmin) { %>
        <a href="#" data-bs-toggle="modal" data-bs-target="#CreateModal" class="ac-add-btn">
            <i class="fa fa-plus"></i> Add Course
        </a>
        <% } %>
    </div>
</div>

<%-- ══════════════════════════════════════════════════════════════════
     MAIN UPDATE PANEL — wraps everything that changes after CRUD
     UpdateMode=Always + ChildrenAsTriggers=true means any button
     inside (repeater LinkButtons, Save, Update) triggers async refresh.
══════════════════════════════════════════════════════════════════ --%>
<asp:UpdatePanel ID="upMain" runat="server" UpdateMode="Always" ChildrenAsTriggers="true">
<ContentTemplate>

    <%-- Stat cards — reflect live counts --%>
    <div class="ac-stats">
        <div class="ac-stat" style="animation-delay:.04s">
            <div class="ac-stat-ico" style="background:#e3f2fd;color:#1565c0"><i class="fa fa-book"></i></div>
            <div>
                <div class="ac-stat-val"><asp:Label ID="lblTotal"    runat="server" Text="0" /></div>
                <div class="ac-stat-lbl">Total Courses</div>
            </div>
        </div>
        <div class="ac-stat" style="animation-delay:.09s">
            <div class="ac-stat-ico" style="background:#e8f5e9;color:#2e7d32"><i class="fa fa-check-circle"></i></div>
            <div>
                <div class="ac-stat-val"><asp:Label ID="lblActive"   runat="server" Text="0" /></div>
                <div class="ac-stat-lbl">Active</div>
            </div>
        </div>
        <div class="ac-stat" style="animation-delay:.14s">
            <div class="ac-stat-ico" style="background:#ffebee;color:#c62828"><i class="fa fa-times-circle"></i></div>
            <div>
                <div class="ac-stat-val"><asp:Label ID="lblInactive" runat="server" Text="0" /></div>
                <div class="ac-stat-lbl">Inactive</div>
            </div>
        </div>
    </div>

    <%-- Toolbar — search + filter buttons --%>
    <div class="ac-toolbar">
        <div class="ac-search-wrap">
            <i class="fa fa-search"></i>
            <input type="text" id="txtSearch" runat="server"
                   class="ac-search-input"
                   placeholder="Search course name or code…"
                   onkeyup="this.form.submit()" />
        </div>
        <button type="button" class="ac-filter-btn all-filter"     id="btnFilterAll"      onclick="applyFilter('All',      this)"><i class="fa fa-list me-1"></i> All</button>
        <button type="button" class="ac-filter-btn"                id="btnFilterActive"   onclick="applyFilter('active',   this)"><i class="fa fa-check-circle me-1"></i> Active</button>
        <button type="button" class="ac-filter-btn"                id="btnFilterInactive" onclick="applyFilter('inactive', this)"><i class="fa fa-times-circle me-1"></i> Inactive</button>
    </div>

    <%-- Info bar --%>
    <div class="ac-info-bar">
        <div class="ac-showing">
            Showing streams <b><asp:Label ID="lblRangeFrom"     runat="server" Text="—" /></b>
            – <b><asp:Label ID="lblRangeTo"       runat="server" Text="—" /></b>
            of <b><asp:Label ID="lblTotalStreams"  runat="server" Text="0" /></b>
            &nbsp;·&nbsp; <b><asp:Label ID="lblTotalCourses" runat="server" Text="0" /></b> courses total
        </div>
        <span id="filterBadgeClient" class="ac-filter-active-badge ac-filter-btn all-filter">Showing: All courses</span>
    </div>

    <%-- Loading overlay wraps the grid --%>
    <div class="grid-relative">
        <div id="gridLoadOverlay"><div class="grid-spinner"></div></div>

        <%-- Stream groups --%>
        <asp:Repeater ID="rptStreams" runat="server"
            OnItemDataBound="rptStreams_ItemDataBound">
            <ItemTemplate>
                <div class="ac-stream-section" id='stream_<%# Eval("StreamId") %>'>

                    <div class="ac-stream-head" onclick="toggleStream('<%# Eval("StreamId") %>')">
                        <div class="ac-stream-head-left">
                            <div class="ac-stream-icon"><i class="fa fa-layer-group"></i></div>
                            <div>
                                <div class="ac-stream-name"><%# System.Web.HttpUtility.HtmlEncode(Eval("StreamName").ToString()) %></div>
                            </div>
                        </div>
                        <div style="display:flex;align-items:center;gap:10px">
                            <span class="ac-stream-count">
                                <i class="fa fa-book" style="font-size:10px"></i>
                                <%# Eval("CourseCount") %> courses
                            </span>
                            <i class="fa fa-chevron-down ac-stream-chevron" id='chev_<%# Eval("StreamId") %>'></i>
                        </div>
                    </div>

                    <div class="ac-stream-body" id='body_<%# Eval("StreamId") %>'>
                        <div class="ac-table-wrap">
                            <table class="ac-table">
                                <thead>
                                    <tr>
                                        <th style="width:40px">#</th>
                                        <th>Course Name</th>
                                        <th>Code</th>
                                        <th>Status</th>
                                        <th style="text-align:right">Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <asp:Repeater ID="rptCourses" runat="server"
                                        OnItemCommand="rptCourses_ItemCommand">
                                        <ItemTemplate>
                                            <tr>
                                                <td style="color:var(--dim);font-family:var(--mono);font-size:11px"><%# Container.ItemIndex + 1 %></td>
                                                <td><div class="ac-course-name"><%# System.Web.HttpUtility.HtmlEncode(Eval("CourseName").ToString()) %></div></td>
                                                <td>
                                                    <%# !string.IsNullOrWhiteSpace(Eval("CourseCode").ToString())
                                                        ? $"<span class='ac-code-chip'>{System.Web.HttpUtility.HtmlEncode(Eval("CourseCode").ToString())}</span>"
                                                        : "<span style='color:var(--dim);font-size:12px'>—</span>" %>
                                                </td>
                                                <td>
                                                    <%# Convert.ToBoolean(Eval("IsActive"))
                                                        ? "<span class='ac-status-badge active'>Active</span>"
                                                        : "<span class='ac-status-badge inactive'>Inactive</span>" %>
                                                </td>
                                                <td>
                                                    <div class="ac-act" style="justify-content:flex-end">
                                                        <% if (!IsSuperAdmin) { %>
                                                        <asp:LinkButton runat="server"
                                                            CommandName="EditRow"
                                                            CommandArgument='<%# Eval("CourseId") %>'
                                                            CssClass="ac-act-btn edit" ToolTip="Edit">
                                                            <i class="fa fa-pen"></i>
                                                        </asp:LinkButton>
                                                        <asp:LinkButton runat="server"
                                                            CommandName="Toggle"
                                                            CommandArgument='<%# Eval("CourseId") %>'
                                                            CssClass="ac-act-btn toggle" ToolTip="Toggle Status"
                                                            OnClientClick="return confirm('Change course status?');">
                                                            <i class="fa fa-toggle-on"></i>
                                                        </asp:LinkButton>
                                                        <asp:LinkButton runat="server"
                                                            CommandName="DeleteRow"
                                                            CommandArgument='<%# Eval("CourseId") %>'
                                                            CssClass="ac-act-btn del" ToolTip="Delete"
                                                            OnClientClick="return confirm('Delete this course? This cannot be undone.');">
                                                            <i class="fa fa-trash"></i>
                                                        </asp:LinkButton>
                                                        <% } else { %>
                                                        <span class="ac-view-only"><i class="fa fa-eye me-1"></i>View Only</span>
                                                        <% } %>
                                                    </div>
                                                </td>
                                            </tr>
                                        </ItemTemplate>
                                        <FooterTemplate>
                                            <asp:PlaceHolder ID="phEmpty" runat="server"
                                                Visible='<%# ((Repeater)Container.NamingContainer).Items.Count == 0 %>'>
                                                <tr>
                                                    <td colspan="5" style="text-align:center;padding:20px;color:var(--dim);font-size:12px">
                                                        <i class="fa fa-book me-2"></i>No courses in this stream
                                                    </td>
                                                </tr>
                                            </asp:PlaceHolder>
                                        </FooterTemplate>
                                    </asp:Repeater>
                                </tbody>
                            </table>
                        </div>
                    </div>

                </div>
            </ItemTemplate>
            <FooterTemplate>
                <%# rptStreams.Items.Count == 0
                    ? "<div class='ac-empty'><div class='ac-empty-icon'><i class='fa fa-book'></i></div><div class='ac-empty-title'>No Courses Found</div><div class='ac-empty-sub'>Add a course using the button above, or change the filter.</div></div>"
                    : "" %>
            </FooterTemplate>
        </asp:Repeater>

    </div><%-- /grid-relative --%>

    <%-- Pagination bar --%>
    <div class="ac-pagination-wrap" id="pagerWrap" style="display:none;">
        <div class="ac-page-info" id="pagerInfo"></div>
        <div class="ac-page-btns" id="pager"></div>
    </div>

</ContentTemplate>
</asp:UpdatePanel>

</div><%-- /ac-root --%>

<%-- ══ ADD MODAL (outside UpdatePanel — Bootstrap modals need to be in body root) ═ --%>
<div class="modal fade" id="CreateModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header-blue d-flex align-items-center justify-content-between">
                <h5><i class="fa fa-plus-circle me-2"></i>Add New Course</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body p-4">
                <div class="ac-field">
                    <label>Stream <span class="req">*</span></label>
                    <asp:DropDownList ID="ddlStream" runat="server" CssClass="ac-fi" />
                    <div class="ac-fi-err" id="errAddStream"></div>
                </div>
                <div class="ac-field">
                    <label>Course Name <span class="req">*</span></label>
                    <asp:TextBox ID="txtCourseName" runat="server" CssClass="ac-fi"
                        placeholder="e.g. Bachelor of Computer Applications"
                        oninput="validateName(this,'errAddName')" MaxLength="150" />
                    <div class="ac-fi-err" id="errAddName"></div>
                </div>
                <div class="ac-field">
                    <label>Course Code <span style="color:var(--dim);font-size:10px">(optional)</span></label>
                    <asp:TextBox ID="txtCourseCode" runat="server" CssClass="ac-fi"
                        placeholder="e.g. BCA"
                        oninput="validateCode(this,'errAddCode')" MaxLength="20" />
                    <div class="ac-fi-err" id="errAddCode"></div>
                </div>
            </div>
            <div class="ac-modal-footer">
                <button type="button" class="ac-modal-btn cancel" data-bs-dismiss="modal">
                    <i class="fa fa-times me-1"></i>Cancel
                </button>
                <asp:Button ID="btnSave" runat="server"
                    Text="Save Course" CssClass="ac-modal-btn primary"
                    OnClick="btnSave_Click"
                    OnClientClick="return clientValidateAdd()" />
            </div>
        </div>
    </div>
</div>

<%-- ══ EDIT MODAL ══════════════════════════════════════════════════════ --%>
<div class="modal fade" id="EditModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header-blue d-flex align-items-center justify-content-between">
                <h5><i class="fa fa-pen me-2"></i>Edit Course</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body p-4">
                <div class="ac-field">
                    <label>Stream <span class="req">*</span></label>
                    <asp:DropDownList ID="ddlStreamEdit" runat="server" CssClass="ac-fi" />
                    <div class="ac-fi-err" id="errEditStream"></div>
                </div>
                <div class="ac-field">
                    <label>Course Name <span class="req">*</span></label>
                    <asp:TextBox ID="txtCourseNameEdit" runat="server" CssClass="ac-fi"
                        placeholder="Course name"
                        oninput="validateName(this,'errEditName')" MaxLength="150" />
                    <div class="ac-fi-err" id="errEditName"></div>
                </div>
                <div class="ac-field">
                    <label>Course Code <span style="color:var(--dim);font-size:10px">(optional)</span></label>
                    <asp:TextBox ID="txtCourseCodeEdit" runat="server" CssClass="ac-fi"
                        placeholder="Course code"
                        oninput="validateCode(this,'errEditCode')" MaxLength="20" />
                    <div class="ac-fi-err" id="errEditCode"></div>
                </div>
            </div>
            <div class="ac-modal-footer">
                <button type="button" class="ac-modal-btn cancel" data-bs-dismiss="modal">
                    <i class="fa fa-times me-1"></i>Cancel
                </button>
                <asp:Button ID="btnUpdate" runat="server"
                    Text="Update Course" CssClass="ac-modal-btn primary"
                    OnClick="btnUpdate_Click"
                    OnClientClick="return clientValidateEdit()" />
            </div>
        </div>
    </div>
</div>

<script>
/* ═══════════════════════════════════════════════════════════════════
   TOAST  (lives outside UpdatePanel — never wiped by async refresh)
═══════════════════════════════════════════════════════════════════ */
var _toastTimer;
function showToast(msg, type) {
    type = type || 'success';
    var icons = { success:'fa-check-circle', error:'fa-exclamation-circle', warning:'fa-exclamation-triangle' };
    var toast = document.getElementById('acToast');
    var msgEl = document.getElementById('acToastMsg');
    var icoEl = document.getElementById('acToastIcoI');
    var barEl = document.getElementById('acToastBar');
    if (!toast) return;
    msgEl.textContent = msg;
    icoEl.className   = 'fa ' + (icons[type] || 'fa-info-circle');
    toast.className   = 'ac-toast ' + type;
    barEl.style.animation = 'none';
    barEl.offsetHeight;                           // reflow to restart animation
    barEl.style.animation = 'shrinkBar 4.5s linear forwards';
    toast.classList.add('show');
    clearTimeout(_toastTimer);
    _toastTimer = setTimeout(function(){ hideToast(); }, 4800);
}
function hideToast() {
    var t = document.getElementById('acToast');
    if (t) t.classList.remove('show');
}

/* ─── Fire toast from server hidden fields (works for async postback too) ─── */
function fireServerToast() {
    var hm = document.getElementById('<%= hfToastMsg.ClientID %>');
    var ht = document.getElementById('<%= hfToastType.ClientID %>');
    if (hm && hm.value && hm.value.trim()) {
        showToast(hm.value, ht ? ht.value : 'success');
        hm.value = ''; if (ht) ht.value = '';
    }
}
/* On first load */
document.addEventListener('DOMContentLoaded', fireServerToast);

/* ═══════════════════════════════════════════════════════════════════
   UPDATEPANEL HOOKS
   pageLoad fires after every async postback, replacing DOMContentLoaded.
   We use it to:
     1. Fire any pending toast from hidden fields
     2. Close open modals (after Save / Update)
     3. Restore the active filter + current pagination page
═══════════════════════════════════════════════════════════════════ */
var Sys = window.Sys || {};

/* pageLoad is called by ASP.NET ScriptManager after every async update */
function pageLoad() {
    fireServerToast();

    /* Close Add modal after successful save */
    var addModal = document.getElementById('CreateModal');
    if (addModal && addModal.classList.contains('show')) {
        var m = bootstrap.Modal.getInstance(addModal);
        if (m) m.hide();
    }

    /* Re-init pagination/filter with the previously active state */
    var savedFilter = document.getElementById('<%= hfClientFilter.ClientID %>').value || 'All';
    var savedPage   = parseInt(document.getElementById('<%= hfClientPage.ClientID %>').value  || '1', 10);

    /* Re-collect all cards (DOM was replaced by UpdatePanel) */
    _allCards      = Array.from(document.querySelectorAll('.ac-stream-section'));
    _filteredCards = _allCards.slice();

    /* Re-apply filter silently (no button click needed) */
    _applyFilterSilent(savedFilter);
    _render(savedPage);
}

/* ═══════════════════════════════════════════════════════════════════
   LOADING OVERLAY — show during async postback, hide when done
═══════════════════════════════════════════════════════════════════ */
if (typeof Sys !== 'undefined' && Sys.WebForms) {
    Sys.WebForms.PageRequestManager.getInstance().add_beginRequest(function() {
        var ov = document.getElementById('gridLoadOverlay');
        if (ov) ov.classList.add('show');
    });
    Sys.WebForms.PageRequestManager.getInstance().add_endRequest(function() {
        var ov = document.getElementById('gridLoadOverlay');
        if (ov) ov.classList.remove('show');
    });
}

/* ═══════════════════════════════════════════════════════════════════
   CLIENT-SIDE FILTER + PAGINATION
═══════════════════════════════════════════════════════════════════ */
var PAGE_SIZE      = 3;
var _currentPage   = 1;
var _currentFilter = 'All';
var _allCards      = [];
var _filteredCards = [];

document.addEventListener('DOMContentLoaded', function() {
    _allCards      = Array.from(document.querySelectorAll('.ac-stream-section'));
    _filteredCards = _allCards.slice();
    _render(1);
});

/* Public: called by filter buttons */
window.applyFilter = function(filter, btn) {
    /* Persist into hidden field so pageLoad can restore it */
    var hf = document.getElementById('<%= hfClientFilter.ClientID %>');
    if (hf) hf.value = filter;

    _applyFilterSilent(filter);
    _updateFilterBtnStyles(filter);
    _updateFilterBadge(filter);
    _render(1);
};

/* Internal: apply filter without updating button/badge styles */
function _applyFilterSilent(filter) {
    _currentFilter = filter;

    _allCards.forEach(function(card) {
        var rows = card.querySelectorAll('tbody tr');
        rows.forEach(function(row) {
            if (filter === 'All') { row.style.display = ''; return; }
            var badge = row.querySelector('.ac-status-badge');
            row.style.display = (badge && badge.classList.contains(filter)) ? '' : 'none';
        });
    });

    _filteredCards = _allCards.filter(function(card) {
        if (filter === 'All') return true;
        var badges = card.querySelectorAll('.ac-status-badge');
        for (var i = 0; i < badges.length; i++) {
            if (badges[i].classList.contains(filter)) return true;
        }
        return false;
    });
}

function _updateFilterBtnStyles(filter) {
    document.querySelectorAll('.ac-filter-btn').forEach(function(b) {
        b.classList.remove('all-filter','active-filter','inactive-filter');
    });
    var btnMap = { All:'btnFilterAll', active:'btnFilterActive', inactive:'btnFilterInactive' };
    var activeBtn = document.getElementById(btnMap[filter]);
    if (activeBtn) {
        if (filter === 'All')      activeBtn.classList.add('all-filter');
        if (filter === 'active')   activeBtn.classList.add('active-filter');
        if (filter === 'inactive') activeBtn.classList.add('inactive-filter');
    }
}

function _updateFilterBadge(filter) {
    var badge = document.getElementById('filterBadgeClient');
    if (!badge) return;
    var labels = { All:'Showing: All courses', active:'Showing: Active only', inactive:'Showing: Inactive only' };
    var classes = { All:'all-filter', active:'active-filter', inactive:'inactive-filter' };
    badge.textContent = labels[filter] || '';
    badge.className   = 'ac-filter-active-badge ac-filter-btn ' + (classes[filter] || 'all-filter');
}

/* ── Render one page of stream cards ── */
function _render(page) {
    _currentPage = page;
    var total      = _filteredCards.length;
    var totalPages = Math.max(1, Math.ceil(total / PAGE_SIZE));
    if (_currentPage > totalPages) _currentPage = totalPages;
    if (_currentPage < 1)          _currentPage = 1;

    /* Persist page into hidden field */
    var hfPg = document.getElementById('<%= hfClientPage.ClientID %>');
    if (hfPg) hfPg.value = _currentPage;

    var start = (_currentPage - 1) * PAGE_SIZE;
    var end   = Math.min(start + PAGE_SIZE, total);

    _allCards.forEach(function(card) {
        var idx = _filteredCards.indexOf(card);
        card.style.display = (idx >= start && idx < end) ? '' : 'none';
    });

    /* Info bar labels */
    var lFrom    = document.getElementById('<%= lblRangeFrom.ClientID %>');
    var lTo      = document.getElementById('<%= lblRangeTo.ClientID %>');
    var lTotStr  = document.getElementById('<%= lblTotalStreams.ClientID %>');

    if (lFrom)   lFrom.textContent   = total === 0 ? '0' : (start + 1).toString();
    if (lTo)     lTo.textContent     = end.toString();
    if (lTotStr) lTotStr.textContent = total.toString();

    /* Pagination bar */
    var wrap  = document.getElementById('pagerWrap');
    var info  = document.getElementById('pagerInfo');
    var pager = document.getElementById('pager');
    if (!wrap) return;

    if (total === 0 || totalPages <= 1) {
        wrap.style.display = 'none';
    } else {
        wrap.style.display = 'flex';
        if (info) info.innerHTML = 'Page <b>' + _currentPage + '</b> of <b>' + totalPages + '</b>';
        _buildPager(pager, totalPages, _currentPage);
    }
}

function _buildPager(wrap, totalPages, cur) {
    if (!wrap) return;
    wrap.innerHTML = '';

    function btn(label, page, disabled, active) {
        var b = document.createElement('button');
        b.type = 'button';
        b.className = 'ac-pg-btn' + (active ? ' active' : '') + (disabled ? ' disabled' : '');
        b.textContent = label;
        if (!disabled && !active) {
            b.addEventListener('click', function(e) {
                e.preventDefault();
                _render(page);
                var first = document.querySelector('.ac-stream-section');
                if (first) first.scrollIntoView({ behavior:'smooth', block:'start' });
            });
        }
        wrap.appendChild(b);
    }
    function ellipsis() {
        var sp = document.createElement('span');
        sp.className = 'ac-pg-sep'; sp.textContent = '…';
        wrap.appendChild(sp);
    }

    btn('«', 1,          cur === 1);
    btn('‹', cur - 1,    cur === 1);

    var from = Math.max(1, cur - 2);
    var to   = Math.min(totalPages, cur + 2);
    if (from > 1) { btn('1', 1, false); if (from > 2) ellipsis(); }
    for (var p = from; p <= to; p++) btn(p.toString(), p, false, p === cur);
    if (to < totalPages) { if (to < totalPages - 1) ellipsis(); btn(totalPages.toString(), totalPages, false); }

    btn('›', cur + 1,    cur === totalPages);
    btn('»', totalPages, cur === totalPages);
}

/* ═══════════════════════════════════════════════════════════════════
   STREAM COLLAPSE / EXPAND
═══════════════════════════════════════════════════════════════════ */
function toggleStream(id) {
    var body = document.getElementById('body_'   + id);
    var chev = document.getElementById('chev_'   + id);
    var card = document.getElementById('stream_' + id);
    if (!body) return;
    if (body.style.display === 'none') {
        body.style.display = '';
        if (chev) chev.style.transform = '';
        if (card) card.classList.remove('collapsed');
    } else {
        body.style.display = 'none';
        if (chev) chev.style.transform = 'rotate(-90deg)';
        if (card) card.classList.add('collapsed');
    }
}

/* ═══════════════════════════════════════════════════════════════════
   CLIENT-SIDE VALIDATION
═══════════════════════════════════════════════════════════════════ */
function validateName(inp, errId) {
    var v  = inp.value.trim();
    var e  = document.getElementById(errId);
    var ok = v.length >= 2 && /^[A-Za-z][A-Za-z0-9 ]*$/.test(v);
    inp.classList.toggle('is-invalid', !ok && v.length > 0);
    inp.classList.toggle('is-valid',    ok);
    if (e) e.textContent = (!ok && v.length > 0) ? 'Must start with a letter, only letters, numbers and spaces.' : '';
    return ok || v.length === 0;
}
function validateCode(inp, errId) {
    var v = inp.value.trim();
    var e = document.getElementById(errId);
    if (!v) { inp.classList.remove('is-invalid','is-valid'); if(e) e.textContent=''; return true; }
    var ok = /^[A-Za-z0-9]+$/.test(v);
    inp.classList.toggle('is-invalid', !ok);
    inp.classList.toggle('is-valid',    ok);
    if (e) e.textContent = !ok ? 'Only letters and numbers allowed.' : '';
    return ok;
}
function clientValidateAdd() {
    var ddl = document.getElementById('<%= ddlStream.ClientID %>');
    var nm  = document.getElementById('<%= txtCourseName.ClientID %>');
    var cd  = document.getElementById('<%= txtCourseCode.ClientID %>');
    var eS  = document.getElementById('errAddStream');
    var ok  = true;
    if (!ddl.value || ddl.value === '') { if(eS) eS.textContent='Please select a stream.'; ok=false; }
    else { if(eS) eS.textContent=''; }
    if (!nm.value.trim() || nm.value.trim().length < 2 || !/^[A-Za-z][A-Za-z0-9 ]*$/.test(nm.value.trim())) {
        nm.classList.add('is-invalid');
        document.getElementById('errAddName').textContent = 'Enter a valid course name (min 2 chars, start with letter).';
        ok = false;
    }
    if (!validateCode(cd,'errAddCode')) ok = false;
    if (!ok) showToast('Please fix the errors before saving.', 'error');
    return ok;
}
function clientValidateEdit() {
    var ddl = document.getElementById('<%= ddlStreamEdit.ClientID %>');
    var nm  = document.getElementById('<%= txtCourseNameEdit.ClientID %>');
    var cd  = document.getElementById('<%= txtCourseCodeEdit.ClientID %>');
        var eS = document.getElementById('errEditStream');
        var ok = true;
        if (!ddl.value || ddl.value === '') { if (eS) eS.textContent = 'Please select a stream.'; ok = false; }
        else { if (eS) eS.textContent = ''; }
        if (!nm.value.trim() || nm.value.trim().length < 2 || !/^[A-Za-z][A-Za-z0-9 ]*$/.test(nm.value.trim())) {
            nm.classList.add('is-invalid');
            document.getElementById('errEditName').textContent = 'Enter a valid course name.';
            ok = false;
        }
        if (!validateCode(cd, 'errEditCode')) ok = false;
        if (!ok) showToast('Please fix the errors before updating.', 'error');
        return ok;
    }
</script>

</asp:Content>
