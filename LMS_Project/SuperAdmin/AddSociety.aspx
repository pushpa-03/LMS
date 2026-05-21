<%@ Page Title="Society Management"
    Language="C#"
    MasterPageFile="~/SuperAdmin/SuperAdminMaster.master"
    AutoEventWireup="true"
    CodeBehind="AddSociety.aspx.cs"
    Inherits="LMS.SuperAdmin.AddSociety" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<link href="https://fonts.googleapis.com/css2?family=Syne:wght@500;600;700;800&family=DM+Sans:opsz,wght@9..40,400;9..40,500;9..40,600;9..40,700&family=DM+Mono:wght@400;500&display=swap" rel="stylesheet">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

<%-- Hidden fields: toast plumbing (set server-side, read by JS after postback) --%>
<asp:HiddenField ID="hfToastMsg"  runat="server" />
<asp:HiddenField ID="hfToastType" runat="server" />
<asp:HiddenField ID="hfDeleteId"  runat="server" />

<style>
/* ═══════════════════════════════════════════════════════════════
   SOCIETY MANAGEMENT — Refined Blue Professional
   Syne (display) · DM Sans (body) · DM Mono (codes)
═══════════════════════════════════════════════════════════════ */
:root {
  --bg:        #f0f4fa;
  --surf:      #ffffff;
  --surf2:     #f7f9fd;
  --surf3:     #eef2f9;
  --bdr:       #e2e8f4;
  --bdr2:      #c8d4ec;

  --blue:      #1565c0;
  --blue2:     #1976d2;
  --blue3:     #2196f3;
  --blue-lt:   #e3f2fd;
  --blue-mid:  #bbdefb;

  --green:     #2e7d32;
  --green-lt:  #e8f5e9;
  --amber:     #e65100;
  --amber-lt:  #fff3e0;
  --red:       #c62828;
  --red-lt:    #ffebee;
  --sky:       #0277bd;
  --sky-lt:    #e1f5fe;

  --ink:       #0d1b2a;
  --ink2:      #1a2a3a;
  --ink3:      #334155;
  --muted:     #64748b;
  --dim:       #94a3b8;
  --faint:     #cbd5e1;

  --f:         'DM Sans', system-ui, sans-serif;
  --fd:        'Inter','Segoe UI', system-ui, sans-serif;
  --mono:      'DM Mono', monospace;

  --r:         10px;
  --rlg:       14px;
  --rxl:       18px;
  --sh:        0 1px 3px rgba(13,27,42,.06), 0 4px 14px rgba(13,27,42,.07);
  --sh2:       0 4px 20px rgba(13,27,42,.10), 0 10px 36px rgba(13,27,42,.08);
  --sh-blue:   0 4px 14px rgba(21,101,192,.28);
}

*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
.sm-root { font-family: var(--f); color: var(--ink); font-size: 14px; line-height: 1.55; }
::-webkit-scrollbar { width: 5px; }
::-webkit-scrollbar-thumb { background: var(--bdr2); border-radius: 3px; }

/* ── PAGE HEADER ── */
.sm-header {
  display: flex; align-items: flex-start; justify-content: space-between;
  flex-wrap: wrap; gap: 12px; margin-bottom: 24px;
}
.sm-h-eyebrow {
  font-size: 10px; font-weight: 700; letter-spacing: .12em; text-transform: uppercase;
  color: var(--blue2); display: flex; align-items: center; gap: 6px; margin-bottom: 5px;
}
.sm-h-eyebrow::before {
  content: ''; width: 16px; height: 2px;
  background: linear-gradient(90deg, var(--blue), var(--blue3)); border-radius: 1px;
}
.sm-h-title {
  font-family: var(--fd); font-size: 1.5rem; font-weight: 800; color: var(--ink);
}
.sm-h-title span { color: var(--blue2); }
.sm-h-sub { font-size: 12px; color: var(--muted); margin-top: 3px; }

/* ── TOAST ── */
.sm-toast {
  position: fixed; top: 20px; right: 20px; z-index: 99999;
  display: flex; align-items: flex-start; gap: 12px;
  min-width: 300px; max-width: 420px;
  background: var(--surf); border-radius: 12px;
  padding: 14px 16px 12px; box-shadow: var(--sh2);
  border: 1.5px solid var(--bdr);
  transform: translateX(460px);
  transition: transform .36s cubic-bezier(.4,0,.2,1);
  overflow: hidden;
}
.sm-toast.show { transform: translateX(0); }
.sm-toast.success { border-color: #a5d6a7; background: #f1f8f1; }
.sm-toast.error   { border-color: #ef9a9a; background: #fff5f5; }
.sm-toast.warning { border-color: #ffcc80; background: #fffdf0; }
.sm-toast.info    { border-color: var(--blue-mid); background: var(--blue-lt); }

.sm-toast-icon {
  width: 34px; height: 34px; border-radius: 9px; flex-shrink: 0;
  display: flex; align-items: center; justify-content: center; font-size: 15px;
  margin-top: 1px;
}
.sm-toast.success .sm-toast-icon { background: var(--green-lt); color: var(--green); }
.sm-toast.error   .sm-toast-icon { background: var(--red-lt);   color: var(--red);   }
.sm-toast.warning .sm-toast-icon { background: var(--amber-lt); color: var(--amber); }
.sm-toast.info    .sm-toast-icon { background: var(--blue-lt);  color: var(--blue);  }

.sm-toast-body { flex: 1; min-width: 0; }
.sm-toast-title { font-size: 13px; font-weight: 700; color: var(--ink2); margin-bottom: 2px; }
.sm-toast-msg   { font-size: 12px; color: var(--muted); line-height: 1.5; }

.sm-toast-close {
  background: none; border: none; cursor: pointer;
  color: var(--dim); font-size: 16px; padding: 0; line-height: 1; flex-shrink: 0;
  margin-top: 2px;
}
.sm-toast-close:hover { color: var(--ink3); }

/* Progress bar */
.sm-toast-bar {
  position: absolute; bottom: 0; left: 0; height: 3px; width: 100%;
  border-radius: 0 0 12px 12px;
  transform-origin: left;
  animation: shrinkBar 5s linear forwards;
}
.sm-toast.success .sm-toast-bar { background: var(--green); }
.sm-toast.error   .sm-toast-bar { background: var(--red); }
.sm-toast.warning .sm-toast-bar { background: var(--amber); }
.sm-toast.info    .sm-toast-bar { background: var(--blue2); }
@keyframes shrinkBar { from { transform: scaleX(1); } to { transform: scaleX(0); } }

/* ── MAIN LAYOUT ── */
.sm-layout {
  display: grid;
  grid-template-columns: 340px 1fr;
  gap: 22px;
  align-items: start;
}
@media(max-width:1050px) { .sm-layout { grid-template-columns: 1fr; } }

/* ── FORM CARD ── */
.sm-form-card {
  background: var(--surf); border: 1px solid var(--bdr);
  border-radius: var(--rxl); box-shadow: var(--sh);
  overflow: hidden; position: sticky; top: 18px;
  animation: fadeUp .4s both;
  transition: box-shadow .2s;
}
.sm-form-card:focus-within { box-shadow: var(--sh2); }
@keyframes fadeUp { from { opacity:0; transform:translateY(16px); } to { opacity:1; transform:translateY(0); } }

.sm-card-head {
  display: flex; align-items: center; gap: 12px;
  padding: 16px 20px; border-bottom: 1px solid var(--bdr);
  background: linear-gradient(135deg, #f5f9ff 0%, #edf3fc 100%);
}
.sm-card-head-icon {
  width: 38px; height: 38px; border-radius: 9px; flex-shrink: 0;
  background: linear-gradient(135deg, var(--blue), var(--blue2));
  display: flex; align-items: center; justify-content: center;
  color: #fff; font-size: 15px;
  box-shadow: var(--sh-blue);
}
.sm-card-head-title {
  font-family: var(--fd); font-size: 14px; font-weight: 700; color: var(--ink2);
}
.sm-card-head-sub { font-size: 11px; color: var(--muted); margin-top: 1px; }

.sm-form-body { padding: 20px; }

.sm-field { display: flex; flex-direction: column; gap: 5px; margin-bottom: 16px; }
.sm-field:last-of-type { margin-bottom: 0; }
.sm-label {
  font-size: 10px; font-weight: 700; text-transform: uppercase;
  letter-spacing: .07em; color: var(--muted);
  display: flex; align-items: center; gap: 4px;
}
.sm-label .req { color: var(--red); font-size: 12px; }

.sm-input {
  width: 100%; border: 1.5px solid var(--bdr);
  border-radius: var(--r); padding: 9px 13px;
  font-family: var(--f); font-size: 13px; font-weight: 500;
  color: var(--ink2); background: var(--surf2);
  transition: border-color .18s, box-shadow .18s, background .18s;
  outline: none;
}
.sm-input:focus {
  border-color: var(--blue2); background: var(--surf);
  box-shadow: 0 0 0 3px rgba(25,118,210,.12);
}
.sm-input.invalid {
  border-color: var(--red); background: #fff8f8;
  box-shadow: 0 0 0 3px rgba(198,40,40,.08);
}
.sm-input.valid { border-color: var(--green); }

.sm-hint { font-size: 11px; color: var(--dim); }
.sm-err  {
  font-size: 11px; font-weight: 600; color: var(--red);
  display: none; align-items: center; gap: 4px; margin-top: 2px;
}
.sm-err.show { display: flex; }

/* ── BUTTON ROW ── */
.sm-btn-row {
  display: flex; gap: 10px; align-items: center;
  margin-top: 20px; padding-top: 16px; border-top: 1px solid var(--bdr);
  flex-wrap: wrap;
}
.sm-btn {
  display: inline-flex; align-items: center; gap: 7px;
  padding: 9px 20px; border-radius: 9px; border: none;
  font-family: var(--f); font-size: 13px; font-weight: 700;
  cursor: pointer; transition: all .18s; white-space: nowrap;
}
.sm-btn.primary {
  background: linear-gradient(135deg, var(--blue), var(--blue2));
  color: #fff; flex: 1; justify-content: center;
  box-shadow: var(--sh-blue);
}
.sm-btn.primary:hover { box-shadow: 0 6px 22px rgba(21,101,192,.4); transform: translateY(-1px); }
.sm-btn.ghost {
  background: var(--surf3); color: var(--ink3);
  border: 1.5px solid var(--bdr);
}
.sm-btn.ghost:hover { background: var(--bdr); }

/* ── EDITING MODE BANNER ── */
.sm-edit-banner {
  display: none; align-items: center; gap: 9px;
  padding: 10px 14px; border-radius: 8px; margin-bottom: 16px;
  background: var(--blue-lt); border: 1px solid var(--blue-mid);
  font-size: 12px; font-weight: 600; color: var(--blue);
}
.sm-edit-banner.show { display: flex; }
.sm-edit-banner i { font-size: 13px; }

/* ── LIST CARD ── */
.sm-list-card {
  background: var(--surf); border: 1px solid var(--bdr);
  border-radius: var(--rxl); box-shadow: var(--sh);
  overflow: hidden; animation: fadeUp .4s .06s both;
}
.sm-list-head {
  display: flex; align-items: center; justify-content: space-between;
  padding: 16px 22px; border-bottom: 1px solid var(--bdr);
  background: linear-gradient(135deg, #f5f9ff 0%, #edf3fc 100%);
  flex-wrap: wrap; gap: 10px;
}
.sm-list-title {
  font-family: var(--fd); font-size: 15px; font-weight: 700; color: var(--ink2);
  display: flex; align-items: center; gap: 9px;
}
.sm-count-chip {
  display: inline-flex; align-items: center; gap: 5px;
  background: var(--blue-lt); border: 1px solid var(--blue-mid);
  border-radius: 20px; padding: 3px 11px;
  font-size: 11px; font-weight: 700; color: var(--blue);
}

/* ── SEARCH BAR ── */
.sm-search-wrap {
  padding: 12px 20px; border-bottom: 1px solid var(--bdr);
  background: var(--surf2);
}
.sm-search-inner { position: relative; max-width: 360px; }
.sm-search-inner i {
  position: absolute; left: 12px; top: 50%; transform: translateY(-50%);
  color: var(--dim); font-size: 13px; pointer-events: none;
}
.sm-search-input {
  width: 100%; padding: 8px 13px 8px 36px;
  border: 1.5px solid var(--bdr); border-radius: 30px;
  font-family: var(--f); font-size: 13px; font-weight: 500;
  color: var(--ink2); background: var(--surf); outline: none;
  transition: border-color .18s, box-shadow .18s;
}
.sm-search-input:focus {
  border-color: var(--blue2); box-shadow: 0 0 0 3px rgba(25,118,210,.10);
}

/* ── TABLE ── */
.sm-table-wrap { overflow-x: auto; }
.sm-table {
  width: 100%; border-collapse: collapse;
  font-size: 13px; min-width: 560px;
}
.sm-table thead th {
  padding: 11px 16px; text-align: left; white-space: nowrap;
  font-size: 10px; font-weight: 700; text-transform: uppercase;
  letter-spacing: .07em; color: var(--muted);
  background: var(--surf3); border-bottom: 1px solid var(--bdr);
}
.sm-table thead th:first-child { border-radius: 0; }
.sm-table tbody tr { transition: background .15s; }
.sm-table tbody tr:hover { background: #f5f8ff; }
.sm-table tbody td {
  padding: 13px 16px; border-bottom: 1px solid var(--bdr);
  vertical-align: middle; color: var(--ink3);
}
.sm-table tbody tr:last-child td { border-bottom: none; }

/* Society name cell */
.sm-soc-name {
  display: flex; align-items: center; gap: 11px;
}
.sm-soc-av {
  width: 36px; height: 36px; border-radius: 9px; flex-shrink: 0;
  background: linear-gradient(135deg, var(--blue-lt), var(--blue-mid));
  display: flex; align-items: center; justify-content: center;
  font-family: var(--fd); font-size: 13px; font-weight: 800; color: var(--blue);
}
.sm-soc-nm { font-weight: 700; color: var(--ink2); font-size: 13px; }
.sm-soc-dt { font-size: 11px; color: var(--dim); margin-top: 1px; }

/* Code cell */
.sm-code-chip {
  display: inline-block; font-family: var(--mono); font-size: 11px;
  background: var(--surf3); border: 1px solid var(--bdr);
  border-radius: 6px; padding: 2px 9px; color: var(--ink3); font-weight: 500;
}

/* Status badge */
.sm-badge {
  display: inline-flex; align-items: center; gap: 4px;
  border-radius: 20px; padding: 3px 11px;
  font-size: 11px; font-weight: 700;
}
.sm-badge::before { content: ''; width: 6px; height: 6px; border-radius: 50%; background: currentColor; }
.sm-badge.active   { background: var(--green-lt); color: var(--green); }
.sm-badge.inactive { background: var(--red-lt);   color: var(--red); }

/* Action buttons */
.sm-actions { display: flex; gap: 6px; align-items: center; }
.sm-act {
  display: inline-flex; align-items: center; gap: 5px;
  padding: 5px 11px; border-radius: 7px; border: 1.5px solid var(--bdr);
  font-family: var(--f); font-size: 11px; font-weight: 700;
  cursor: pointer; background: var(--surf); color: var(--ink3);
  transition: all .18s; white-space: nowrap;
}
.sm-act.edit:hover   { background: var(--blue-lt); color: var(--blue2); border-color: var(--blue-mid); }
.sm-act.toggle:hover { background: var(--amber-lt); color: var(--amber); border-color: #ffcc80; }
.sm-act.del:hover    { background: var(--red-lt); color: var(--red); border-color: #ef9a9a; }

/* ── CONFIRM DIALOG ── */
.sm-confirm-overlay {
  position: fixed; inset: 0; background: rgba(13,27,42,.45);
  backdrop-filter: blur(4px); z-index: 9998;
  display: flex; align-items: center; justify-content: center;
  opacity: 0; visibility: hidden; transition: all .22s;
}
.sm-confirm-overlay.show { opacity: 1; visibility: visible; }
.sm-confirm-box {
  background: var(--surf); border: 1px solid var(--bdr);
  border-radius: var(--rxl); padding: 28px 28px 22px;
  box-shadow: var(--sh2); max-width: 420px; width: 92%;
  transform: scale(.92); transition: transform .22s;
}
.sm-confirm-overlay.show .sm-confirm-box { transform: scale(1); }
.sm-confirm-icon {
  width: 50px; height: 50px; border-radius: 14px;
  background: var(--red-lt); display: flex; align-items: center;
  justify-content: center; font-size: 20px; color: var(--red); margin-bottom: 16px;
}
.sm-confirm-title { font-family: var(--fd); font-size: 16px; font-weight: 800; color: var(--ink); margin-bottom: 7px; }
.sm-confirm-msg   { font-size: 13px; color: var(--muted); line-height: 1.65; margin-bottom: 22px; }
.sm-confirm-btns  { display: flex; gap: 10px; }
.sm-confirm-btns .sm-btn { flex: 1; justify-content: center; }
.sm-btn.danger { background: var(--red); color: #fff; box-shadow: 0 4px 14px rgba(198,40,40,.3); }
.sm-btn.danger:hover { background: #b71c1c; }

/* ── EMPTY STATE ── */
.sm-empty {
  text-align: center; padding: 48px 20px;
}
.sm-empty-icon {
  width: 60px; height: 60px; border-radius: 16px;
  background: var(--blue-lt); border: 2px dashed var(--blue-mid);
  display: flex; align-items: center; justify-content: center;
  font-size: 22px; color: var(--blue2); margin: 0 auto 14px;
}
.sm-empty-title { font-family: var(--fd); font-size: 15px; font-weight: 700; color: var(--ink3); margin-bottom: 5px; }
.sm-empty-sub   { font-size: 12px; color: var(--dim); }

/* ── RESPONSIVE ── */
@media(max-width:640px) {
  .sm-form-card { position: relative; top: 0; }
  .sm-act span  { display: none; }
  .sm-act       { padding: 6px 9px; }
}
</style>

<!-- TOAST -->
<div class="sm-toast" id="smToast">
    <div class="sm-toast-icon" id="toastIcon"><i class="fa fa-check" id="toastIco"></i></div>
    <div class="sm-toast-body">
        <div class="sm-toast-title" id="toastTitle">Success</div>
        <div class="sm-toast-msg"   id="toastMsg"></div>
    </div>
    <button class="sm-toast-close" onclick="hideToast()" type="button"><i class="fa fa-times"></i></button>
    <div class="sm-toast-bar" id="toastBar"></div>
</div>

<!-- CONFIRM DIALOG -->
<div class="sm-confirm-overlay" id="confirmOverlay">
    <div class="sm-confirm-box">
        <div class="sm-confirm-icon"><i class="fa fa-trash-alt"></i></div>
        <div class="sm-confirm-title">Delete Society?</div>
        <div class="sm-confirm-msg" id="confirmMsg">
            This action cannot be undone. Are you sure?
        </div>
        <div class="sm-confirm-btns">
            <button class="sm-btn ghost" type="button" onclick="closeConfirm()">
                <i class="fa fa-times"></i> Cancel
            </button>
            <button class="sm-btn danger" type="button" id="confirmOkBtn">
                <i class="fa fa-trash"></i> Yes, Delete
            </button>
        </div>
    </div>
</div>

<div class="sm-root">

<!-- ══ PAGE HEADER ══════════════════════════════════════════════════ -->
<div class="sm-header">
    <div>
        <div class="sm-h-eyebrow">SuperAdmin Panel</div>
        <div class="sm-h-title">Society <span>Management</span></div>
        <div class="sm-h-sub">Create and manage client societies across the platform</div>
    </div>
</div>

<div class="sm-layout">

<!-- ══ LEFT: FORM ════════════════════════════════════════════════════ -->
<div class="sm-form-card">

    <div class="sm-card-head">
        <div class="sm-card-head-icon"><i class="fa fa-building"></i></div>
        <div>
            <div class="sm-card-head-title">
                <asp:Label ID="lblFormTitle" runat="server" Text="Add New Society" />
            </div>
            <div class="sm-card-head-sub">Fill all required fields to save</div>
        </div>
    </div>

    <div class="sm-form-body">

        <asp:HiddenField ID="hfSocietyId" runat="server" />

        <!-- Edit mode banner -->
        <div class="sm-edit-banner" id="editBanner">
            <i class="fa fa-pen"></i>
            <span id="editBannerText">Editing: —</span>
        </div>

        <!-- Society Name -->
        <div class="sm-field">
            <label class="sm-label" for="<%= txtSocietyName.ClientID %>">
                Society Name <span class="req">*</span>
            </label>
            <asp:TextBox ID="txtSocietyName" runat="server"
                CssClass="sm-input"
                placeholder="e.g. Greenfield Education Group"
                MaxLength="100"
                onblur="validateName(this)"
                oninput="clearErr('errName');clearInvalid(this)" />
            <div class="sm-err" id="errName"></div>
            <div class="sm-hint">Full legal / trade name of the society</div>
        </div>

        <!-- Society Code -->
        <div class="sm-field">
            <label class="sm-label" for="<%= txtSocietyCode.ClientID %>">
                Society Code <span class="req">*</span>
            </label>
            <asp:TextBox ID="txtSocietyCode" runat="server"
                CssClass="sm-input"
                placeholder="e.g. SOC001"
                MaxLength="20"
                onblur="validateCode(this)"
                oninput="clearErr('errCode');clearInvalid(this);this.value=this.value.toUpperCase().replace(/[^A-Z0-9\-_]/g,'')" />
            <div class="sm-err" id="errCode"></div>
            <div class="sm-hint">Unique identifier — 2 to 20 uppercase alphanumeric characters</div>
        </div>

        <!-- Button row -->
        <div class="sm-btn-row">
            <asp:Button ID="btnSave" runat="server"
                Text="Save Society" CssClass="sm-btn primary"
                OnClick="btnSave_Click"
                OnClientClick="return clientValidate()" />
            <asp:Button ID="btnCancel" runat="server"
                Text="Cancel" CssClass="sm-btn ghost"
                OnClick="btnCancel_Click"
                CausesValidation="false" />
        </div>

    </div>
</div>

<!-- ══ RIGHT: LIST ════════════════════════════════════════════════════ -->
<div class="sm-list-card">

    <div class="sm-list-head">
        <div class="sm-list-title">
            <i class="fa fa-list-ul" style="color:var(--blue2)"></i>
            Existing Societies
        </div>
        <span class="sm-count-chip">
            <i class="fa fa-building"></i>
            <asp:Label ID="lblCount" runat="server" Text="0" /> societies
        </span>
    </div>

    <!-- Search -->
    <div class="sm-search-wrap">
        <div class="sm-search-inner">
            <i class="fa fa-search"></i>
            <input type="text" class="sm-search-input"
                placeholder="Search by name or code…"
                oninput="filterTable(this.value)" />
        </div>
    </div>

    <!-- Table -->
    <div class="sm-table-wrap">
        <table class="sm-table" id="smTable">
            <thead>
                <tr>
                    <th style="width:44px">#</th>
                    <th>Society</th>
                    <th>Code</th>
                    <th>Status</th>
                    <th>Created</th>
                    <th style="text-align:right">Actions</th>
                </tr>
            </thead>
            <tbody>
                <asp:Repeater ID="rptSocieties" runat="server"
                    OnItemCommand="rptSocieties_ItemCommand">
                    <ItemTemplate>
                        <tr class="sm-row">
                            <td style="color:var(--dim);font-family:var(--mono);font-size:12px"><%# Container.ItemIndex+1 %></td>
                            <td>
                                <div class="sm-soc-name">
                                    <div class="sm-soc-av">
                                        <%# Eval("SocietyName").ToString().Substring(0, Math.Min(2, Eval("SocietyName").ToString().Length)).ToUpper() %>
                                    </div>
                                    <div>
                                        <div class="sm-soc-nm"><%# System.Web.HttpUtility.HtmlEncode(Eval("SocietyName")) %></div>
                                        <div class="sm-soc-dt"><i class="fa fa-university" style="opacity:.5"></i> Society</div>
                                    </div>
                                </div>
                            </td>
                            <td>
                                <span class="sm-code-chip"><%# System.Web.HttpUtility.HtmlEncode(Eval("SocietyCode")) %></span>
                            </td>
                            <td>
                                <%# Convert.ToBoolean(Eval("IsActive"))
                                    ? "<span class='sm-badge active'>Active</span>"
                                    : "<span class='sm-badge inactive'>Inactive</span>" %>
                            </td>
                            <td style="font-size:11px;color:var(--dim);white-space:nowrap">
                                <%# Eval("CreatedOn") != DBNull.Value
                                    ? Convert.ToDateTime(Eval("CreatedOn")).ToString("dd MMM yyyy")
                                    : "—" %>
                            </td>
                            <td>
                                <div class="sm-actions" style="justify-content:flex-end">

                                    <asp:LinkButton runat="server"
                                        CommandName="EditSoc"
                                        CommandArgument='<%# Eval("SocietyId") %>'
                                        CssClass="sm-act edit">
                                        <i class="fa fa-pen"></i><span> Edit</span>
                                    </asp:LinkButton>

                                    <asp:LinkButton runat="server"
                                        CommandName="ToggleStatus"
                                        CommandArgument='<%# Eval("SocietyId") %>'
                                        CssClass="sm-act toggle"
                                        ToolTip='<%# Convert.ToBoolean(Eval("IsActive")) ? "Deactivate" : "Activate" %>'>
                                        <i class='fa <%# Convert.ToBoolean(Eval("IsActive")) ? "fa-toggle-on" : "fa-toggle-off" %>'></i>
                                        <span><%# Convert.ToBoolean(Eval("IsActive")) ? " Deactivate" : " Activate" %></span>
                                    </asp:LinkButton>

                                    <button type="button" class="sm-act del"
                                        onclick="openConfirm('<%# Eval("SocietyId") %>','<%# System.Web.HttpUtility.JavaScriptStringEncode(Eval("SocietyName").ToString()) %>')">
                                        <i class="fa fa-trash"></i><span> Delete</span>
                                    </button>

                                </div>
                            </td>
                        </tr>
                    </ItemTemplate>
                    <FooterTemplate>
                        <%# rptSocieties.Items.Count == 0
                            ? "<tr><td colspan='6'><div class='sm-empty'><div class='sm-empty-icon'><i class='fa fa-building'></i></div><div class='sm-empty-title'>No societies yet</div><div class='sm-empty-sub'>Use the form on the left to add your first society.</div></div></td></tr>"
                            : "" %>
                    </FooterTemplate>
                </asp:Repeater>
            </tbody>
        </table>
    </div>

</div><%-- /sm-list-card --%>

</div><%-- /sm-layout --%>

<%-- Hidden delete trigger --%>
<asp:Button ID="btnDoDelete" runat="server"
    CssClass="d-none" OnClick="btnDoDelete_Click"
    CausesValidation="false" style="display:none" />

</div><%-- /sm-root --%>

<script>
/* ═══════════════════════════════════════════════════════════════
   CLIENT-SIDE VALIDATION
═══════════════════════════════════════════════════════════════ */
function showErr(id, msg) {
    var e = document.getElementById(id);
    if (!e) return;
    e.textContent = msg; e.classList.add('show');
}
function clearErr(id) {
    var e = document.getElementById(id);
    if (e) { e.textContent = ''; e.classList.remove('show'); }
}
function markInvalid(el) { el.classList.add('invalid'); el.classList.remove('valid'); }
function markValid(el)   { el.classList.remove('invalid'); el.classList.add('valid'); }
function clearInvalid(el){ el.classList.remove('invalid','valid'); }

function validateName(inp) {
    var v = inp.value.trim();
    if (!v)         { markInvalid(inp); showErr('errName','Society name is required.'); return false; }
    if (v.length<3) { markInvalid(inp); showErr('errName','Society name must be at least 3 characters.'); return false; }
    if (v.length>100){ markInvalid(inp); showErr('errName','Society name cannot exceed 100 characters.'); return false; }
    markValid(inp); clearErr('errName'); return true;
}
function validateCode(inp) {
    var v = inp.value.trim();
    if (!v) { markInvalid(inp); showErr('errCode','Society code is required.'); return false; }
    if (!/^[A-Za-z0-9\-_]{2,20}$/.test(v)) {
        markInvalid(inp);
        showErr('errCode','Code must be 2–20 characters: letters, numbers, hyphens, underscores only.');
        return false;
    }
    markValid(inp); clearErr('errCode'); return true;
}

function clientValidate() {
    var nm  = document.getElementById('<%= txtSocietyName.ClientID %>');
    var cd  = document.getElementById('<%= txtSocietyCode.ClientID %>');
    var ok  = true;
    if (!validateName(nm)) ok = false;
    if (!validateCode(cd)) ok = false;
    if (!ok) {
        showToast('Please fix the highlighted fields before saving.','error','Validation Error');
        return false;
    }
    return true;
}

/* ═══════════════════════════════════════════════════════════════
   TABLE SEARCH FILTER
═══════════════════════════════════════════════════════════════ */
function filterTable(val) {
    val = val.toLowerCase();
    document.querySelectorAll('.sm-row').forEach(function(row) {
        var text = row.textContent.toLowerCase();
        row.style.display = text.includes(val) ? '' : 'none';
    });
}

/* ═══════════════════════════════════════════════════════════════
   TOAST (no postback, purely CSS-animated bar)
═══════════════════════════════════════════════════════════════ */
var _toastTimer;
function showToast(msg, type, title) {
    type  = type  || 'success';
    title = title || { success:'Success', error:'Error', warning:'Warning', info:'Info' }[type] || 'Notice';
    var icons = { success:'fa-check-circle', error:'fa-exclamation-circle', warning:'fa-exclamation-triangle', info:'fa-info-circle' };

    var toast = document.getElementById('smToast');
    var tTitle = document.getElementById('toastTitle');
    var tMsg   = document.getElementById('toastMsg');
    var tIco   = document.getElementById('toastIco');
    var tBar   = document.getElementById('toastBar');
    if (!toast) return;

    tTitle.textContent = title;
    tMsg.textContent   = msg;
    tIco.className     = 'fa ' + (icons[type] || 'fa-info-circle');
    toast.className    = 'sm-toast ' + type;

    /* restart progress bar animation */
    tBar.style.animation = 'none';
    tBar.offsetHeight;                    /* force reflow */
    tBar.style.animation = 'shrinkBar 5s linear forwards';

    toast.classList.add('show');
    clearTimeout(_toastTimer);
    _toastTimer = setTimeout(hideToast, 5200);
}
function hideToast() {
    var t = document.getElementById('smToast');
    if (t) t.classList.remove('show');
}

/* ═══════════════════════════════════════════════════════════════
   READ TOAST FROM SERVER HIDDEN FIELDS (postback fire)
═══════════════════════════════════════════════════════════════ */
function fireServerToast() {
    var hfMsg  = document.getElementById('<%= hfToastMsg.ClientID %>');
    var hfType = document.getElementById('<%= hfToastType.ClientID %>');
    if (hfMsg && hfMsg.value && hfMsg.value.trim()) {
        showToast(hfMsg.value, hfType ? hfType.value : 'success');
        hfMsg.value  = '';
        if(hfType) hfType.value = '';
    }
}
document.addEventListener('DOMContentLoaded', function() {
    fireServerToast();
    applyEditBanner();
});

/* ═══════════════════════════════════════════════════════════════
   EDIT BANNER (show when hfSocietyId has a value)
═══════════════════════════════════════════════════════════════ */
function applyEditBanner() {
    var hf    = document.getElementById('<%= hfSocietyId.ClientID %>');
    var banner = document.getElementById('editBanner');
    var btnTxt = document.getElementById('<%= btnSave.ClientID %>');
    if (!hf || !banner) return;
    if (hf.value && hf.value.trim() && hf.value !== '0') {
        banner.classList.add('show');
    } else {
        banner.classList.remove('show');
    }
}

/* ═══════════════════════════════════════════════════════════════
   CONFIRM DELETE DIALOG
═══════════════════════════════════════════════════════════════ */
var _pendingDeleteId = '';
function openConfirm(id, name) {
    _pendingDeleteId = id;
    document.getElementById('confirmMsg').innerHTML =
        'You are about to permanently delete <strong>"' + name + '"</strong>.<br>'
        + 'If it has linked institutes, this will fail and a message will explain why.';
    document.getElementById('confirmOverlay').classList.add('show');
    document.getElementById('confirmOkBtn').onclick = function() {
        closeConfirm();
        document.getElementById('<%= hfDeleteId.ClientID %>').value = _pendingDeleteId;
        document.getElementById('<%= btnDoDelete.ClientID %>').click();
    };
}
function closeConfirm() {
    document.getElementById('confirmOverlay').classList.remove('show');
    _pendingDeleteId = '';
}
document.addEventListener('click', function(e) {
    if (e.target === document.getElementById('confirmOverlay')) closeConfirm();
});

/* ═══════════════════════════════════════════════════════════════
   STAGGER ROW ANIMATIONS
═══════════════════════════════════════════════════════════════ */
(function stagger() {
    document.querySelectorAll('.sm-row').forEach(function(r, i) {
        r.style.animation    = 'fadeUp .35s ease both';
        r.style.animationDelay = (i * 0.04) + 's';
    });
})();
</script>

</asp:Content>
