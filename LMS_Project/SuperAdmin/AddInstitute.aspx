<%@ Page Title="Institutes"
    Language="C#"
    MasterPageFile="~/SuperAdmin/SuperAdminMaster.master"
    AutoEventWireup="true"
    CodeBehind="AddInstitute.aspx.cs"
    Inherits="LMS.SuperAdmin.AddInstitute" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<link href="https://fonts.googleapis.com/css2?family=Syne:wght@500;600;700;800&family=DM+Sans:opsz,wght@9..40,300;9..40,400;9..40,500;9..40,600;9..40,700&family=DM+Mono:wght@400;500&display=swap" rel="stylesheet">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

<style>
/* ═══════════════════════════════════════════════════
   INSTITUTE MANAGEMENT — Refined Light Premium
   Fonts: Syne (display) · DM Sans (body) · DM Mono
═══════════════════════════════════════════════════ */
:root {
  --bg:       #f0f4fa;
  --bg2:      #e8edf6;
  --surf:     #ffffff;
  --surf2:    #f7f9fd;
  --surf3:    #eef2f9;
  --bdr:      #e2e8f4;
  --bdr2:     #c8d4ec;

  --blue:     #2563eb;
  --blue2:    #3b82f6;
  --blue3:    #60a5fa;
  --blue-lt:  #eff6ff;
  --blue-mid: #dbeafe;
  --navy:     #1e3a8a;

  --green:    #059669;
  --green-lt: #ecfdf5;
  --amber:    #d97706;
  --amber-lt: #fffbeb;
  --red:      #dc2626;
  --red-lt:   #fef2f2;
  --purple:   #7c3aed;
  --purple-lt:#f5f3ff;
  --teal:     #0891b2;
  --teal-lt:  #ecfeff;

  --ink:      #0f172a;
  --ink2:     #1e293b;
  --ink3:     #334155;
  --muted:    #64748b;
  --dim:      #94a3b8;
  --faint:    #cbd5e1;

  --f:        'DM Sans', system-ui, sans-serif;
  --fd:       'Inter','Segoe UI', system-ui, sans-serif;
  --mono:     'DM Mono', monospace;

  --r:        12px;
  --rlg:      16px;
  --rxl:      20px;
  --sh:       0 1px 3px rgba(15,23,42,.06), 0 4px 16px rgba(15,23,42,.07);
  --sh2:      0 4px 20px rgba(15,23,42,.10), 0 12px 40px rgba(15,23,42,.08);
  --sh3:      0 8px 40px rgba(15,23,42,.14), 0 24px 64px rgba(15,23,42,.10);
}

*,*::before,*::after { box-sizing: border-box; margin: 0; padding: 0; }
body { font-family: var(--f); background: var(--bg); color: var(--ink); font-size: 14px; line-height: 1.5; }
a { text-decoration: none; }

/* ── SCROLLBAR ── */
::-webkit-scrollbar { width: 5px; }
::-webkit-scrollbar-track { background: transparent; }
::-webkit-scrollbar-thumb { background: var(--faint); border-radius: 3px; }

/* ══════════════════════════════════════════════════
   ROOT WRAPPER
══════════════════════════════════════════════════ */
.ai-root { max-width: 1440px; margin: 0 auto; padding: 0 4px 60px; }

/* ══════════════════════════════════════════════════
   PAGE HEADER
══════════════════════════════════════════════════ */
.ai-ph {
  display: flex; align-items: flex-start; justify-content: space-between;
  flex-wrap: wrap; gap: 14px; margin-bottom: 26px; padding-top: 2px;
}
.ai-ph-eyebrow {
  font-size: 10px; font-weight: 700; letter-spacing: .12em;
  text-transform: uppercase; color: var(--blue2);
  display: flex; align-items: center; gap: 6px; margin-bottom: 5px;
}
.ai-ph-eyebrow::before {
  content: ''; width: 18px; height: 2px;
  background: linear-gradient(90deg, var(--blue), var(--blue3));
  border-radius: 1px;
}
.ai-ph-title {
  font-family: var(--fd); font-size: 1.6rem; font-weight: 800;
  color: var(--ink); line-height: 1.1;
}
.ai-ph-title span { color: var(--blue); }
.ai-ph-sub { font-size: 13px; color: var(--muted); margin-top: 4px; }
.ai-ph-actions { display: flex; gap: 10px; align-items: center; flex-wrap: wrap; }
.ai-count-chip {
  display: inline-flex; align-items: center; gap: 6px;
  background: var(--blue-lt); border: 1px solid var(--blue-mid);
  border-radius: 20px; padding: 5px 14px;
  font-size: 12px; font-weight: 700; color: var(--blue);
}
.ai-count-chip i { font-size: 11px; }

/* ══════════════════════════════════════════════════
   FORM SECTION
══════════════════════════════════════════════════ */
.ai-form-wrap {
  background: var(--surf);
  border: 1px solid var(--bdr);
  border-radius: var(--rxl);
  box-shadow: var(--sh);
  overflow: hidden;
  margin-bottom: 28px;
  transition: box-shadow .25s;
  animation: slideUp .45s both;
}
.ai-form-wrap:focus-within { box-shadow: var(--sh2); }
@keyframes slideUp { from { opacity:0; transform:translateY(20px); } to { opacity:1; transform:translateY(0); } }

.ai-form-head {
  display: flex; align-items: center; justify-content: space-between;
  padding: 18px 24px; flex-wrap: wrap; gap: 10px;
  background: linear-gradient(135deg, #f8faff 0%, #eff6ff 100%);
  border-bottom: 1px solid var(--bdr);
}
.ai-form-head-left { display: flex; align-items: center; gap: 12px; }
.ai-form-head-icon {
  width: 40px; height: 40px; border-radius: 10px;
  background: linear-gradient(135deg, var(--blue), var(--blue2));
  display: flex; align-items: center; justify-content: center;
  color: #fff; font-size: 16px; box-shadow: 0 4px 12px rgba(37,99,235,.25);
}
.ai-form-head-title {
  font-family: var(--fd); font-size: 15px; font-weight: 700; color: var(--ink2);
}
.ai-form-head-sub { font-size: 12px; color: var(--muted); margin-top: 1px; }

.ai-form-body { padding: 24px 28px; }

/* FIELD GROUPS */
.ai-field-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
  gap: 18px 20px;
}
.ai-field { display: flex; flex-direction: column; gap: 6px; }
.ai-field.span2 { grid-column: span 2; }
.ai-field label {
  font-size: 11px; font-weight: 700; text-transform: uppercase;
  letter-spacing: .06em; color: var(--muted);
}
.ai-field label .req { color: var(--red); margin-left: 2px; }

.ai-input, .ai-select {
  width: 100%; border: 1.5px solid var(--bdr);
  border-radius: var(--r); padding: 9px 13px;
  font-family: var(--f); font-size: 13px; font-weight: 500;
  color: var(--ink2); background: var(--surf2);
  transition: border-color .18s, box-shadow .18s, background .18s;
  outline: none;
}
.ai-input:focus, .ai-select:focus {
  border-color: var(--blue2);
  background: var(--surf);
  box-shadow: 0 0 0 3px rgba(59,130,246,.12);
}
.ai-input.readonly-code {
  background: #f1f5f9; color: var(--muted);
  cursor: not-allowed; user-select: none;
}
.ai-select { cursor: pointer; }

/* FILE INPUT */
.ai-file-wrap {
  border: 2px dashed var(--bdr2); border-radius: var(--r);
  padding: 14px; text-align: center; transition: border-color .18s, background .18s;
  cursor: pointer;
}
.ai-file-wrap:hover { border-color: var(--blue2); background: var(--blue-lt); }
.ai-file-wrap input { display: none; }
.ai-file-wrap label {
  cursor: pointer; font-size: 12px; font-weight: 600;
  color: var(--blue); display: flex; align-items: center; justify-content: center; gap: 8px;
  text-transform: none; letter-spacing: 0;
}
.ai-file-wrap label i { font-size: 16px; }

/* STATUS MESSAGE */
.ai-msg {
  padding: 8px 14px; border-radius: 8px; font-size: 13px; font-weight: 600;
  display: inline-flex; align-items: center; gap: 6px;
}
.ai-msg.ok  { background: var(--green-lt); color: var(--green); border: 1px solid #a7f3d0; }
.ai-msg.err { background: var(--red-lt);   color: var(--red);   border: 1px solid #fca5a5; }
.ai-msg.info{ background: var(--blue-lt);  color: var(--blue);  border: 1px solid var(--blue-mid); }

/* BUTTONS */
.ai-btn-row { display: flex; gap: 10px; align-items: center; flex-wrap: wrap; margin-top: 22px; padding-top: 18px; border-top: 1px solid var(--bdr); }
.ai-btn {
  display: inline-flex; align-items: center; gap: 7px;
  padding: 9px 20px; border-radius: 10px; border: none;
  font-family: var(--f); font-size: 13px; font-weight: 700;
  cursor: pointer; transition: all .18s; white-space: nowrap;
}
.ai-btn.primary {
  background: linear-gradient(135deg, var(--blue), var(--blue2));
  color: #fff; box-shadow: 0 4px 14px rgba(37,99,235,.3);
}
.ai-btn.primary:hover { box-shadow: 0 6px 20px rgba(37,99,235,.45); transform: translateY(-1px); }
.ai-btn.secondary {
  background: var(--surf3); color: var(--ink3); border: 1.5px solid var(--bdr);
}
.ai-btn.secondary:hover { background: var(--bdr); }

/* ══════════════════════════════════════════════════
   FILTER BAR
══════════════════════════════════════════════════ */
.ai-filter-bar {
  display: flex; align-items: center; gap: 12px; flex-wrap: wrap;
  padding: 14px 20px;
  background: var(--surf); border: 1px solid var(--bdr);
  border-radius: var(--rlg); box-shadow: var(--sh);
  margin-bottom: 20px;
}
.ai-filter-bar label { font-size: 11px; font-weight: 700; color: var(--muted); white-space: nowrap; }
.ai-filter-select {
  border: 1.5px solid var(--bdr); border-radius: 8px;
  padding: 7px 12px; font-family: var(--f); font-size: 13px;
  background: var(--surf2); color: var(--ink2); cursor: pointer;
  transition: border-color .18s; outline: none; min-width: 180px;
}
.ai-filter-select:focus { border-color: var(--blue2); }
.ai-page-info { font-size: 12px; color: var(--muted); margin-left: auto; }
.ai-page-btn {
  padding: 6px 14px; border-radius: 8px; border: 1.5px solid var(--bdr);
  background: var(--surf); font-family: var(--f); font-size: 12px; font-weight: 600;
  color: var(--ink3); cursor: pointer; transition: all .18s;
}
.ai-page-btn:hover:not(:disabled) { border-color: var(--blue2); color: var(--blue); background: var(--blue-lt); }
.ai-page-btn:disabled { opacity: .4; cursor: not-allowed; }

/* ══════════════════════════════════════════════════
   SOCIETY GROUP LABEL
══════════════════════════════════════════════════ */
.ai-soc-label {
  display: flex; align-items: center; gap: 10px;
  font-family: var(--fd); font-size: 12px; font-weight: 700;
  text-transform: uppercase; letter-spacing: .08em; color: var(--muted);
  margin: 24px 0 14px;
}
.ai-soc-label::before, .ai-soc-label::after {
  content: ''; flex: 1; height: 1px; background: var(--bdr);
}
.ai-soc-label:first-child { margin-top: 8px; }

/* ══════════════════════════════════════════════════
   INSTITUTE CARDS GRID
══════════════════════════════════════════════════ */
.ai-inst-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(290px, 1fr));
  gap: 18px;
}

/* ── SINGLE INSTITUTE CARD ── */
.ai-inst-card {
  background: var(--surf);
  border: 1px solid var(--bdr);
  border-radius: var(--rlg);
  overflow: hidden;
  box-shadow: var(--sh);
  transition: transform .22s, box-shadow .22s, border-color .22s;
  cursor: pointer;
  position: relative;
  animation: cardPop .4s both;
}
.ai-inst-card:hover {
  transform: translateY(-5px);
  box-shadow: var(--sh2);
  border-color: var(--bdr2);
}
.ai-inst-card.inactive-card { opacity: .7; }

@keyframes cardPop {
  from { opacity:0; transform:translateY(14px) scale(.97); }
  to   { opacity:1; transform:translateY(0) scale(1); }
}

/* TOP ACCENT STRIPE */
.ai-inst-card::before {
  content: '';
  position: absolute; top: 0; left: 0; right: 0; height: 3px;
  background: linear-gradient(90deg, var(--blue), var(--blue3), #a78bfa);
  opacity: 0; transition: opacity .22s;
}
.ai-inst-card:hover::before { opacity: 1; }

/* CARD HEADER */
.aic-head {
  display: flex; align-items: flex-start; gap: 14px;
  padding: 18px 18px 14px;
  border-bottom: 1px solid var(--bdr);
  background: linear-gradient(135deg, #fafcff 0%, #f4f7fe 100%);
}
.aic-logo {
  width: 54px; height: 54px; border-radius: 12px;
  object-fit: contain; background: var(--surf);
  border: 1.5px solid var(--bdr); flex-shrink: 0;
  padding: 4px;
}
.aic-logo-placeholder {
  width: 54px; height: 54px; border-radius: 12px; flex-shrink: 0;
  background: linear-gradient(135deg, var(--blue-lt), var(--blue-mid));
  border: 1.5px solid var(--bdr2);
  display: flex; align-items: center; justify-content: center;
  font-family: var(--fd); font-size: 18px; font-weight: 800;
  color: var(--blue); letter-spacing: -.02em;
}
.aic-info { flex: 1; min-width: 0; }
.aic-name {
  font-family: var(--fd); font-size: 14px; font-weight: 700;
  color: var(--ink); line-height: 1.3; margin-bottom: 3px;
  white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
}
.aic-code {
  display: inline-block;
  font-family: var(--mono); font-size: 10px; font-weight: 500;
  background: var(--blue-lt); color: var(--blue);
  border: 1px solid var(--blue-mid); border-radius: 5px;
  padding: 1px 7px; margin-bottom: 5px;
}
.aic-type { font-size: 11px; color: var(--muted); }
.aic-status-wrap { display: flex; align-items: flex-start; gap: 6px; }

/* STATUS BADGE */
.aic-badge {
  display: inline-flex; align-items: center; gap: 3px;
  border-radius: 20px; padding: 2px 8px;
  font-size: 10px; font-weight: 700; white-space: nowrap;
}
.aic-badge::before { content: ''; width: 5px; height: 5px; border-radius: 50%; }
.aic-badge.active  { background: var(--green-lt); color: var(--green); }
.aic-badge.active::before  { background: var(--green); }
.aic-badge.inactive{ background: var(--red-lt);   color: var(--red);   }
.aic-badge.inactive::before{ background: var(--red); }

/* CARD BODY — stats row */
.aic-body { padding: 14px 18px; }
.aic-stats-row {
  display: grid; grid-template-columns: repeat(3,1fr);
  gap: 8px; margin-bottom: 14px;
}
.aic-stat {
  background: var(--surf2); border-radius: 9px; padding: 8px 10px; text-align: center;
  border: 1px solid var(--bdr); transition: background .15s;
}
.aic-stat:hover { background: var(--blue-lt); }
.aic-stat-val {
  font-family: var(--mono); font-size: 1rem; font-weight: 500;
  line-height: 1; color: var(--ink2);
}
.aic-stat-lbl {
  font-size: 9px; font-weight: 700; text-transform: uppercase;
  letter-spacing: .04em; color: var(--dim); margin-top: 3px;
}

/* ── NAVIGATION BUTTONS ── */
.aic-nav-grid {
  display: grid; grid-template-columns: 1fr 1fr; gap: 8px;
  margin-bottom: 12px;
}
.aic-nav-btn {
  display: flex; align-items: center; justify-content: center; gap: 6px;
  padding: 8px 10px; border-radius: 9px; border: 1.5px solid var(--bdr);
  font-family: var(--f); font-size: 11px; font-weight: 700;
  cursor: pointer; transition: all .18s; background: var(--surf2);
  color: var(--ink3); text-decoration: none; white-space: nowrap;
}
.aic-nav-btn i { font-size: 12px; }
.aic-nav-btn.student:hover {
  background: var(--blue-lt); border-color: var(--blue2);
  color: var(--blue); box-shadow: 0 3px 10px rgba(37,99,235,.15);
}
.aic-nav-btn.teacher:hover {
  background: var(--green-lt); border-color: var(--green);
  color: var(--green); box-shadow: 0 3px 10px rgba(5,150,105,.15);
}
.aic-nav-btn.overview:hover {
  background: var(--purple-lt); border-color: var(--purple);
  color: var(--purple); box-shadow: 0 3px 10px rgba(124,58,237,.15);
}
.aic-nav-btn.admin:hover {
  background: var(--amber-lt); border-color: var(--amber);
  color: var(--amber); box-shadow: 0 3px 10px rgba(217,119,6,.15);
}

/* ── CARD FOOTER — action buttons ── */
.aic-footer {
  display: flex; gap: 6px; padding: 12px 18px;
  border-top: 1px solid var(--bdr);
  background: var(--surf2);
}
.aic-action {
  flex: 1; display: flex; align-items: center; justify-content: center; gap: 5px;
  padding: 7px 8px; border-radius: 8px; border: 1.5px solid var(--bdr);
  font-family: var(--f); font-size: 11px; font-weight: 700;
  cursor: pointer; background: var(--surf); color: var(--ink3);
  transition: all .18s; text-decoration: none;
}
.aic-action.edit:hover  { background: var(--blue-lt);  color: var(--blue);  border-color: var(--blue2); }
.aic-action.del:hover   { background: var(--red-lt);   color: var(--red);   border-color: var(--red); }
.aic-action.toggle:hover{ background: var(--amber-lt); color: var(--amber); border-color: var(--amber); }

/* ══════════════════════════════════════════════════
   SECTION HEADING
══════════════════════════════════════════════════ */
.ai-section-title {
  font-family: var(--fd); font-size: 15px; font-weight: 700;
  color: var(--ink2); margin-bottom: 16px;
  display: flex; align-items: center; gap: 10px;
}
.ai-section-title .line { flex: 1; height: 1px; background: var(--bdr); }

/* ══════════════════════════════════════════════════
   EMPTY STATE
══════════════════════════════════════════════════ */
.ai-empty {
  text-align: center; padding: 48px 20px;
  color: var(--muted); grid-column: 1 / -1;
}
.ai-empty-icon {
  width: 64px; height: 64px; border-radius: 18px;
  background: var(--blue-lt); border: 2px dashed var(--bdr2);
  display: flex; align-items: center; justify-content: center;
  font-size: 24px; color: var(--blue2); margin: 0 auto 14px;
}
.ai-empty-title { font-family: var(--fd); font-size: 16px; font-weight: 700; color: var(--ink3); margin-bottom: 6px; }
.ai-empty-sub   { font-size: 13px; color: var(--dim); }

/* ══════════════════════════════════════════════════
   RESPONSIVE
══════════════════════════════════════════════════ */
@media(max-width:768px){
  .ai-form-body { padding: 18px 16px; }
  .ai-field-grid { grid-template-columns: 1fr; }
  .ai-field.span2 { grid-column: span 1; }
  .ai-inst-grid { grid-template-columns: 1fr; }
  .ai-ph-title { font-size: 1.3rem; }
}
</style>

<div class="ai-root">

<%-- ══ PAGE HEADER ══════════════════════════════════════════════════════ --%>
<div class="ai-ph">
    <div>
        <div class="ai-ph-eyebrow">Institute Management</div>
        <div class="ai-ph-title">Institute <span>Directory</span></div>
        <div class="ai-ph-sub">Manage institutes and navigate to student &amp; teacher dashboards</div>
    </div>
    <div class="ai-ph-actions">
        <asp:Label ID="lblMsg" runat="server" />
    </div>
</div>

<asp:HiddenField ID="hfInstituteId" runat="server" Value="0" />

<%-- ══ ADD / EDIT FORM ════════════════════════════════════════════════ --%>
<asp:UpdatePanel ID="upForm" runat="server">
<ContentTemplate>
<div class="ai-form-wrap" id="formCard">

    <div class="ai-form-head">
        <div class="ai-form-head-left">
            <div class="ai-form-head-icon"><i class="fa fa-university"></i></div>
            <div>
                <div class="ai-form-head-title">Add / Edit Institute</div>
                <div class="ai-form-head-sub">Fill in the details below and save</div>
            </div>
        </div>
        <asp:Label ID="lblFormStatus" runat="server" />
    </div>

    <div class="ai-form-body">
        <div class="ai-field-grid">

            <div class="ai-field">
                <label>Society <span class="req">*</span></label>
                <asp:DropDownList ID="ddlSocieties" runat="server" CssClass="ai-select" />
            </div>

            <div class="ai-field">
                <label>Institute Name <span class="req">*</span></label>
                <asp:TextBox ID="txtInstName"
                    runat="server"
                    CssClass="form-control"
                    onkeypress="return allowLetters(event)">
                </asp:TextBox>
            </div>

            <div class="ai-field">
                <label>Institute Code <span class="req">*</span></label>
                <asp:TextBox ID="txtInstCode"
                    runat="server"
                    CssClass="form-control"
                    onkeypress="return allowAlphaNumeric(event)">
                </asp:TextBox>
            </div>

            <div class="ai-field">
                <label>Education Type</label>
                <asp:TextBox ID="txtEducationType" runat="server" CssClass="ai-input"
                    placeholder="e.g. Engineering, Arts" />
            </div>

            <div class="ai-field">
                <label>Short Name</label>
                <asp:TextBox ID="txtShortName" runat="server" CssClass="ai-input"
                    placeholder="e.g. GFU" />
            </div>

            <div class="ai-field">
                <label>Phone</label>
                <asp:TextBox ID="txtPhone"
                    runat="server"
                    CssClass="form-control"
                    MaxLength="10"
                    onkeypress="return allowNumbers(event)">
                </asp:TextBox>
            </div>

            <div class="ai-field">
                <label>Email</label>
                <asp:TextBox ID="txtEmail" runat="server" CssClass="ai-input"
                    TextMode="Email" placeholder="info@institute.edu" />
            </div>

            <div class="ai-field">
                <label>Institute Logo</label>
                <div class="ai-file-wrap" onclick="document.getElementById('<%= fuLogo.ClientID %>').click()">
                    <asp:FileUpload ID="fuLogo" runat="server" />
                    <label>
                        <i class="fa fa-cloud-upload-alt"></i>
                        <span id="fileLabel">Click to upload logo (PNG / JPG)</span>
                    </label>
                </div>
            </div>

        </div>

        <div class="ai-btn-row">
            <asp:Button ID="btnAddInst" runat="server" Text="Save Institute"
                CssClass="ai-btn primary"
                OnClick="btnAddInst_Click" />
            <asp:Button ID="btnClear" runat="server"
                Text="Cancel"
                CssClass="ai-btn secondary"
                OnClick="btnClear_Click"
                CausesValidation="false"
                UseSubmitBehavior="false" />
        </div>
    </div>

</div>
</ContentTemplate>
<Triggers>
    <asp:PostBackTrigger ControlID="btnAddInst" />
</Triggers>
</asp:UpdatePanel>

<%-- ══ INSTITUTE DIRECTORY ════════════════════════════════════════════ --%>
<asp:UpdatePanel ID="upnlInstitutes" runat="server" UpdateMode="Conditional">
<ContentTemplate>

    <%-- FILTER BAR --%>
    <div class="ai-filter-bar">
        <label><i class="fa fa-filter me-1"></i>Filter by Society:</label>
        <asp:DropDownList ID="ddlFilterSociety" runat="server"
            CssClass="ai-filter-select"
            AutoPostBack="true"
            OnSelectedIndexChanged="ddlFilterSociety_SelectedIndexChanged" />

        <div class="ai-page-info">
            <asp:Label ID="lblPageInfo" runat="server" />
        </div>

        <asp:Button ID="btnPrev" runat="server" Text="← Prev"
            CssClass="ai-page-btn" OnClick="btnPrev_Click" />
        <asp:Button ID="btnNext" runat="server" Text="Next →"
            CssClass="ai-page-btn" OnClick="btnNext_Click" />
    </div>

    <%-- SOCIETY GROUPS --%>
    <asp:Repeater ID="rptSocietyGroup" runat="server">
        <ItemTemplate>

            <div class="ai-soc-label">
                <i class="fa fa-building"></i>
                <%# Eval("SocietyName") %>
            </div>

            <div class="ai-inst-grid">

                <asp:Repeater ID="rptInstitutes" runat="server"
                    DataSource='<%# Eval("Institutes") %>'
                    OnItemCommand="rptInstitutes_ItemCommand">
                    <ItemTemplate>

                        <div class="ai-inst-card <%# !Convert.ToBoolean(Eval("IsActive")) ? "inactive-card" : "" %>">

                            <%-- TOP: Logo + info + status --%>
                            <div class="aic-head">

                                <%-- Logo or placeholder --%>

                                <asp:PlaceHolder runat="server"
                                    Visible='<%# Eval("LogoURL") != DBNull.Value 
                                        && !string.IsNullOrEmpty(Eval("LogoURL").ToString())
                                        && Eval("LogoURL").ToString() != "~/assets/images/logo.png" %>'>

                                    <img src='<%# ResolveUrl(Eval("LogoURL").ToString()) %>'
                                        class="aic-logo"
                                        alt="logo" />

                                </asp:PlaceHolder>

                                <asp:PlaceHolder runat="server"
                                    Visible='<%# Eval("LogoURL") == DBNull.Value 
                                        || string.IsNullOrEmpty(Eval("LogoURL").ToString())
                                        || Eval("LogoURL").ToString() == "~/assets/images/logo.png" %>'>

                                    <div class="aic-logo-placeholder">
                                        <%# Eval("InstituteName").ToString().Length > 0
                                            ? Eval("InstituteName").ToString()
                                                .Substring(0, Math.Min(2, Eval("InstituteName").ToString().Length))
                                                .ToUpper()
                                            : "?" %>
                                    </div>

                                </asp:PlaceHolder>

                                <div class="aic-info">
                                    <div class="aic-name" title='<%# Eval("InstituteName") %>'><%# Eval("InstituteName") %></div>
                                    <div class="aic-code"><%# Eval("InstituteCode") %></div>
                                    <div class="aic-type"><%# Eval("EducationType") %></div>
                                </div>

                                <div class="aic-status-wrap">
                                    <%# Convert.ToBoolean(Eval("IsActive"))
                                        ? "<span class='aic-badge active'>Active</span>"
                                        : "<span class='aic-badge inactive'>Inactive</span>" %>
                                </div>

                            </div>

                            <%-- BODY: Stats --%>
                            <div class="aic-body">

                                <div class="aic-stats-row">
                                    <div class="aic-stat">
                                        <div class="aic-stat-val" style="color:var(--blue)">
                                            <%# Eval("Phone") != null && Eval("Phone").ToString() != "" ? "✓" : "—" %>
                                        </div>
                                        <div class="aic-stat-lbl">Phone</div>
                                    </div>
                                    <div class="aic-stat">
                                        <div class="aic-stat-val" style="color:var(--green)">
                                            <%# Eval("Email") != null && Eval("Email").ToString() != "" ? "✓" : "—" %>
                                        </div>
                                        <div class="aic-stat-lbl">Email</div>
                                    </div>
                                    <div class="aic-stat">
                                        <div class="aic-stat-val" style="color:var(--purple)">
                                            <%# Eval("ShortName") %>
                                        </div>
                                        <div class="aic-stat-lbl">Short</div>
                                    </div>
                                </div>

                                <%-- NAVIGATION BUTTONS --%>
                                <div style="margin-bottom:8px;font-size:10px;font-weight:700;text-transform:uppercase;letter-spacing:.06em;color:var(--dim)">
                                    <i class="fa fa-compass me-1"></i>Navigate to
                                </div>

                                <div class="aic-nav-grid">

                                    <%-- Student Dashboard --%>
                                    <a class="aic-nav-btn student"
                                       href='<%# ResolveUrl("~/Admin/StudentsList.aspx") %>?InstituteId=<%# Eval("InstituteId") %>'
                                       onclick="setInstitute(<%# Eval("InstituteId") %>, event)"
                                       title="Student Dashboard">
                                        <i class="fa fa-user-graduate"></i>
                                        Students
                                    </a>

                                    <%-- Teacher Dashboard --%>
                                    <a class="aic-nav-btn teacher"
                                       href='<%# ResolveUrl("~/Admin/TeacherList.aspx") %>?InstituteId=<%# Eval("InstituteId") %>'
                                       onclick="setInstitute(<%# Eval("InstituteId") %>, event)"
                                       title="Teacher Dashboard">
                                        <i class="fa fa-chalkboard-teacher"></i>
                                        Teachers
                                    </a>

                                    <%-- Overview Dashboard --%>
                                    <a class="aic-nav-btn overview"
                                       href='<%# ResolveUrl("~/Admin/Dashboards/OverviewDashboard.aspx") %>?InstituteId=<%# Eval("InstituteId") %>'
                                       onclick="setInstitute(<%# Eval("InstituteId") %>, event)"
                                       title="Overview Dashboard">
                                        <i class="fa fa-chart-bar"></i>
                                        Dashboard
                                    </a>

                                    <%-- Admin Panel --%>
                                    <a class="aic-nav-btn admin"
                                       href='<%# ResolveUrl("~/Admin/AddStudent.aspx") %>?InstituteId=<%# Eval("InstituteId") %>'
                                       onclick="setInstitute(<%# Eval("InstituteId") %>, event)"
                                       title="Student Management">
                                        <i class="fa fa-users-cog"></i>
                                        Manage
                                    </a>

                                </div>

                            </div>

                            <%-- FOOTER: Edit / Delete / Toggle --%>
                            <div class="aic-footer" onclick="event.stopPropagation()">

                                <asp:LinkButton runat="server"
                                    CommandName="EditRow"
                                    CommandArgument='<%# Eval("InstituteId") %>'
                                    CssClass="aic-action edit"
                                    OnClientClick="event.stopPropagation();">
                                    <i class="fa fa-pen"></i> Edit
                                </asp:LinkButton>

                                <asp:LinkButton runat="server"
                                    CommandName="DeleteRow"
                                    CommandArgument='<%# Eval("InstituteId") %>'
                                    CssClass="aic-action del"
                                    OnClientClick="event.stopPropagation(); return confirm('Delete this institute? This cannot be undone.');">
                                    <i class="fa fa-trash"></i> Delete
                                </asp:LinkButton>

                                <asp:LinkButton runat="server"
                                    CommandName="Toggle"
                                    CommandArgument='<%# Eval("InstituteId") %>'
                                    CssClass="aic-action toggle"
                                    OnClientClick="event.stopPropagation();">
                                    <i class="fa fa-toggle-on"></i>
                                    <%# Convert.ToBoolean(Eval("IsActive")) ? "Deactivate" : "Activate" %>
                                </asp:LinkButton>

                            </div>

                        </div>

                    </ItemTemplate>
                    <FooterTemplate>
                        <%# ((Repeater)Container.NamingContainer).Items.Count == 0
                            ? "<div class='ai-empty'><div class='ai-empty-icon'><i class='fa fa-university'></i></div><div class='ai-empty-title'>No institutes yet</div><div class='ai-empty-sub'>Add your first institute using the form above</div></div>"
                            : "" %>
                    </FooterTemplate>
                </asp:Repeater>

            </div>

        </ItemTemplate>
    </asp:Repeater>

</ContentTemplate>
</asp:UpdatePanel>

</div><%-- /ai-root --%>

<script>
/* ── File upload label update ── */
(function(){
    var fu = document.getElementById('<%= fuLogo.ClientID %>');
        if (fu) {
            fu.addEventListener('change', function () {
                var lbl = document.getElementById('fileLabel');
                if (lbl) lbl.textContent = this.files.length > 0
                    ? this.files[0].name
                    : 'Click to upload logo (PNG / JPG)';
            });
        }

        /* ── Highlight active nav link ── */
        var curr = window.location.pathname.split('/').pop().toLowerCase();
        document.querySelectorAll('.aic-nav-btn').forEach(function (a) {
            var href = a.getAttribute('href');
            if (href && href.toLowerCase().indexOf(curr) > -1)
                a.style.fontWeight = '800';
        });

        /* ── Scroll to form on edit (re-bind after UpdatePanel) ── */
        if (typeof Sys !== 'undefined') {
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(function () {
                var msg = document.querySelector('[id$="lblMsg"]');
                if (msg && msg.textContent.trim()) {
                    msg.className = msg.textContent.toLowerCase().indexOf('delet') > -1
                        ? 'ai-msg err' : 'ai-msg ok';
                }
            });
        }

        /* ── Staggered card animation ── */
        var cards = document.querySelectorAll('.ai-inst-card');
        cards.forEach(function (c, i) {
            c.style.animationDelay = (i * 0.04) + 's';
        });

        /* ── Apply correct class to lblMsg on load ── */
        var msg = document.querySelector('[id$="lblMsg"]');
        if (msg && msg.textContent.trim()) {
            var t = msg.textContent.toLowerCase();
            msg.className = t.indexOf('delet') > -1 || t.indexOf('error') > -1
                ? 'ai-msg err'
                : t.indexOf('edit') > -1 ? 'ai-msg info'
                    : 'ai-msg ok';
        }
    })();

    /* ── Navigate to institute (sets context then redirects) ── */
    function setInstitute(id, evt) {
        /* Let the anchor navigate naturally — the BasePage.OnLoad()
           will pick up the InstituteId querystring and set session.
           No additional work needed here. */
    }


        function allowNumbers(e) {
            var charCode = (e.which) ? e.which : e.keyCode;

            if (charCode >= 48 && charCode <= 57)
                return true;

            return false;
        }

        function allowLetters(e) {
            var charCode = (e.which) ? e.which : e.keyCode;

            // A-Z a-z space
            if ((charCode >= 65 && charCode <= 90) ||
                (charCode >= 97 && charCode <= 122) ||
                charCode == 32)
                return true;

            return false;
        }

        function allowAlphaNumeric(e) {
            var charCode = (e.which) ? e.which : e.keyCode;

            // 0-9 A-Z a-z
            if ((charCode >= 48 && charCode <= 57) ||
                (charCode >= 65 && charCode <= 90) ||
                (charCode >= 97 && charCode <= 122))
                return true;

            return false;
        }

                    </script>

</asp:Content>
