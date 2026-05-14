<%--<%@ Page Title="Academic Session"
    Language="C#"
    MasterPageFile="~/Admin/AdminMaster.Master"
    AutoEventWireup="true"
    CodeBehind="AcademicSession.aspx.cs"
    Inherits="LearningManagementSystem.Admin.AcademicSession" %>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">


<div class="toast-container position-fixed top-0 end-0 p-3">
    <div id="liveToast" class="toast text-white bg-success border-0">
        <div class="d-flex">
            <div class="toast-body" id="toastMsg"></div>
            <button type="button" class="btn-close btn-close-white"
                data-bs-dismiss="toast"></button>
        </div>
    </div>
</div>

<asp:HiddenField ID="hfSessionId" runat="server" />
<asp:HiddenField ID="hfMode" runat="server" />


<div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-2">

    <div>
        <h3 class="fw-bold mb-1">Academic Sessions</h3>
        <small class="text-muted">
            Manage academic years, control active session & track history
        </small>
        <span>|</span>
        <small class="text-muted">
            Last updated: <%= DateTime.Now.ToString("dd MMM yyyy hh:mm tt") %>
        </small>
    </div>

    <div class="d-flex gap-2">

    
        <input type="text" id="txtSearch" class="form-control"
               placeholder="🔍 Search session..."
               onkeyup="filterTable()" />

    
        <button type="button"
            class="btn btn-success  btn-sm"
            onclick="autoGenerateSession()">
            ⚡ Auto Generate
        </button>


    </div>
</div>


<div class="row g-3 mb-4">

    <div class="col-md-4">
        <div class="card border-0 shadow-sm stat-card d-flex flex-row align-items-center p-3">
            <div class="icon-box bg-dark me-3">
                <i class="fa fa-layer-group"></i>
            </div>
            <div>
                <h6 class="text-muted mb-1">Total Sessions</h6>
                <h4 class="fw-bold mb-0">
                    <asp:Label ID="lblTotal" runat="server" />
                </h4>
            </div>
        </div>
    </div>

    <div class="col-md-4">
        <div class="card border-0 shadow-sm stat-card d-flex flex-row align-items-center p-3">
            <div class="icon-box bg-success me-3">
                <i class="fa fa-star"></i>
            </div>
            <div>
                <h6 class="text-success mb-1">Current Session</h6>
                <h4 class="fw-bold mb-0">
                    <asp:Label ID="lblCurrent" runat="server" />
                </h4>
            </div>
        </div>
    </div>

    <div class="col-md-4">
        <div class="card border-0 shadow-sm stat-card d-flex flex-row align-items-center p-3">
            <div class="icon-box bg-secondary me-3">
                <i class="fa fa-history"></i>
            </div>
            <div>
                <h6 class="text-danger mb-1">Past Sessions</h6>
                <h4 class="fw-bold mb-0">
                    <asp:Label ID="lblPast" runat="server" />
                </h4>
            </div>
        </div>
    </div>

</div>

<div class="card shadow border-0 rounded-4">
    <div class="table-responsive">

        <asp:GridView ID="gvSessions" runat="server"
            CssClass="table table-hover mb-0 modern-table"
            AutoGenerateColumns="false"
            OnRowCommand="gvSessions_RowCommand">

            <EmptyDataTemplate>
                <div class="text-center p-5 text-muted">
                    <i class="fa fa-database fa-3x mb-3"></i>
                    <h5>No Sessions Found</h5>
                </div>
            </EmptyDataTemplate>

            <HeaderStyle CssClass="table-header text-white" />

            <Columns>

                <asp:BoundField DataField="SessionName" HeaderText="Session" />

                <asp:TemplateField HeaderText="Duration">
                    <ItemTemplate>
                        <%# Convert.ToDateTime(Eval("StartDate")).ToString("dd MMM yyyy") %>
                        -
                        <%# Convert.ToDateTime(Eval("EndDate")).ToString("dd MMM yyyy") %>
                    </ItemTemplate>
                </asp:TemplateField>

                <asp:TemplateField HeaderText="Status">
                    <ItemTemplate>
                        <span class='<%# (bool)Eval("IsCurrent") ? "badge bg-success" : "badge bg-secondary" %>'>
                            <%# (bool)Eval("IsCurrent") ? "Current" : "Inactive" %>
                        </span>
                    </ItemTemplate>
                </asp:TemplateField>

                <asp:TemplateField HeaderText="Actions">
                    <ItemTemplate>

                        <asp:LinkButton runat="server"
                            CommandName="EditRow"
                            ToolTip="Edit session"
                            Tip="Edit"
                            CommandArgument='<%# Eval("SessionId") %>'
                            CssClass="btn btn-sm btn-light me-1">
                            ✏
                        </asp:LinkButton>

                        <asp:LinkButton runat="server"
                            CommandName="SetCurrent"
                            ToolTip="Set Current"
                            CommandArgument='<%# Eval("SessionId") %>'
                            CssClass="btn btn-sm btn-warning me-1"
                            OnClientClick="return confirm('Set as current session?');">
                            ⭐
                        </asp:LinkButton>

                        <asp:LinkButton runat="server"
                            CommandName="DeleteRow"
                            ToolTip="Delete"
                            CommandArgument='<%# Eval("SessionId") %>'
                            CssClass="btn btn-sm btn-danger"
                            OnClientClick="return confirm('Delete session?');">
                            🗑
                        </asp:LinkButton>

                    </ItemTemplate>
                </asp:TemplateField>

            </Columns>

        </asp:GridView>

    </div>
</div>

<div class="modal fade" id="SessionModal">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content rounded-4 shadow-lg">

         
            <div class="modal-header bg-primary text-white">
                <h5 >Academic Session</h5>
                <button class="btn-close " data-bs-dismiss="modal"></button>
            </div>

        
            <div class="modal-body">

          
                <div class="mb-3">
                    <label class="fw-bold">Academic Year</label>
                    <asp:TextBox ID="txtSessionName" runat="server"
                        CssClass="form-control"
                        placeholder="e.g. 2024-2025" />
                    <small class="text-muted">
                        Format: StartYear-EndYear (auto-filled from dates)
                    </small>
                </div>

          
                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label class="fw-bold">Start Date</label>
                        <asp:TextBox ID="txtStartDate" runat="server"
                            TextMode="Date"
                            CssClass="form-control"
                            onchange="autoFillSession()" />
                    </div>

                    <div class="col-md-6 mb-3">
                        <label class="fw-bold">End Date</label>
                        <asp:TextBox ID="txtEndDate" runat="server"
                            TextMode="Date"
                            CssClass="form-control"
                            onchange="validateDates()" />
                    </div>
                </div>

            
                <div class="form-check form-switch mt-2">
                    <asp:CheckBox ID="chkCurrent" runat="server" CssClass="form-check-input" />
                    <label class="form-check-label fw-semibold">
                        Set as Current Session
                    </label>
                </div>

                <div class="alert alert-info mt-3 small">
                    ℹ Setting this will automatically deactivate previous session.
                </div>

            </div>

            <div class="modal-footer">
                <button class="btn btn-light" data-bs-dismiss="modal">Cancel</button>

                <asp:Button ID="btnSave" runat="server"
                    Text="Save Session"
                    CssClass="btn btn-primary px-4 rounded-pill"
                    OnClick="btnSave_Click" />
            </div>

        </div>
    </div>
</div>

<style>
    .table-header {
    background: linear-gradient(135deg, #4f46e5, #6366f1);
}
.table-header th {
    background: linear-gradient(135deg, #4f46e5, #6366f1) !important;
    color: white;
    border: none;
    padding: 14px !important;
    font-weight: 600;
    letter-spacing: 0.5px;
}
.stat-card {
    color: black;
    padding: 20px;
    border-radius: 14px;
    text-align: center;
    transition: .3s;
}
.stat-card:hover {
    transform: translateY(-5px);
}
.bg-gradient {
    background: linear-gradient(135deg,#4f46e5,#6366f1);
}

.stat-card {
    border-radius: 16px;
    transition: all .25s ease;
    cursor: pointer;
}

.stat-card:hover {
    transform: translateY(-5px) scale(1.02);
    box-shadow: 0 12px 30px rgba(0,0,0,0.15);
}

.icon-box {
    width: 50px;
    height: 50px;
    border-radius: 12px;
    display: flex;
    align-items: center;
    justify-content: center;
    color: white;
    font-size: 20px;
}

@media (max-width: 992px) {
    .d-flex.justify-content-between {
        flex-direction: column;
        align-items: flex-start !important;
    }

    #txtSearch {
        width: 100%;
    }

    .stat-card {
        margin-bottom: 10px;
    }
}

@media (max-width: 576px) {

    .stat-card {
        flex-direction: column !important;
        text-align: center;
    }

    .icon-box {
        margin-bottom: 10px;
    }

    .table {
        font-size: 12px;
    }

    .btn {
        font-size: 12px;
        padding: 4px 8px;
    }

    .modal-dialog {
        margin: 10px;
    }
}
</style>

<script>

    // 🔥 AUTO GENERATE SESSION NAME
    function autoFillSession() {
        let start = document.getElementById("<%= txtStartDate.ClientID %>").value;

    if (start) {
        let year = new Date(start).getFullYear();
        document.getElementById("<%= txtSessionName.ClientID %>").value =
                year + "-" + (year + 1);
        }
    }

    // 🔥 VALIDATE DATES
    function validateDates() {
        let start = new Date(document.getElementById("<%= txtStartDate.ClientID %>").value);
    let end = new Date(document.getElementById("<%= txtEndDate.ClientID %>").value);

    if (end <= start) {
        alert("End date must be greater than Start date");
    }
}

// 🔥 AUTO GENERATE BUTTON
function autoGenerateSession() {
    let year = new Date().getFullYear();
    let name = year + "-" + (year + 1);

    document.getElementById("<%= txtSessionName.ClientID %>").value = name;
    document.getElementById("<%= txtStartDate.ClientID %>").value = year + "-06-01";
    document.getElementById("<%= txtEndDate.ClientID %>").value = (year + 1) + "-05-31";

        new bootstrap.Modal(document.getElementById('SessionModal')).show();
    }

</script>

</asp:Content>--%>


<%-- --------------------------------------------------------------------------------------------------------------------------------------------------------- --%>

<%@ Page Title="Academic Sessions"
    Language="C#"
    MasterPageFile="~/Admin/AdminMaster.Master"
    AutoEventWireup="true"
    CodeBehind="AcademicSession.aspx.cs"
    Inherits="LearningManagementSystem.Admin.AcademicSession" %>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">

<asp:HiddenField ID="hfSessionId"    runat="server" />
<asp:HiddenField ID="hfMode"         runat="server" />
<asp:HiddenField ID="hfCopyFrom"     runat="server" />  <%-- session to copy from when starting new --%>

<style>
*,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
:root{
  --primary:#6366f1;--primary-d:#4f46e5;--primary-l:#eef2ff;
  --success:#059669;--danger:#dc2626;--warn:#d97706;
  --bg:#f1f5f9;--card:#fff;--border:#e2e8f0;
  --text:#0f172a;--muted:#64748b;--dim:#94a3b8;
  --shadow:0 1px 3px rgba(0,0,0,.07),0 4px 16px rgba(0,0,0,.05);
  --shadow-lg:0 8px 32px rgba(0,0,0,.12);
  --radius:14px;
  --font:'Inter',system-ui,sans-serif;
}
body{font-family:var(--font);background:var(--bg);color:var(--text);font-size:14px}

/* ── PAGE WRAPPER ── */
.pg{max-width:1300px;margin:0 auto;padding:22px 20px}
@media(max-width:640px){.pg{padding:14px}}

/* ── HEADER ── */
.pg-hdr{display:flex;justify-content:space-between;align-items:flex-start;flex-wrap:wrap;gap:14px;margin-bottom:24px}
.pg-hdr-left h2{font-size:1.4rem;font-weight:800;color:var(--text)}
.pg-hdr-left p{font-size:13px;color:var(--muted);margin-top:2px}
.hdr-btns{display:flex;gap:8px;flex-wrap:wrap}

/* ── DEADLINE ALERT ── */
.deadline-alert{
  display:flex;align-items:flex-start;gap:12px;
  border-radius:var(--radius);padding:14px 18px;margin-bottom:20px;
  font-size:13px;font-weight:500;animation:slideDown .4s ease;
}
.deadline-alert.warn{background:#fffbeb;border:1px solid #fde68a;color:#92400e}
.deadline-alert.danger{background:#fef2f2;border:1px solid #fecaca;color:#991b1b}
.deadline-alert.info{background:var(--primary-l);border:1px solid #c7d2fe;color:#3730a3}
.deadline-alert i{font-size:16px;margin-top:1px;flex-shrink:0}
.deadline-alert .al-title{font-weight:700;margin-bottom:2px}
@keyframes slideDown{from{opacity:0;transform:translateY(-10px)}to{opacity:1;transform:translateY(0)}}

/* ── STATS ── */
.stats-row{display:grid;grid-template-columns:repeat(4,1fr);gap:14px;margin-bottom:24px}
@media(max-width:900px){.stats-row{grid-template-columns:repeat(2,1fr)}}
@media(max-width:480px){.stats-row{grid-template-columns:1fr 1fr}}
.sc{background:var(--card);border:1px solid var(--border);border-radius:var(--radius);
  padding:16px 18px;display:flex;align-items:center;gap:14px;
  box-shadow:var(--shadow);transition:.2s}
.sc:hover{transform:translateY(-3px);box-shadow:var(--shadow-lg)}
.sc-ico{width:44px;height:44px;border-radius:11px;display:flex;align-items:center;
  justify-content:center;font-size:17px;flex-shrink:0}
.sc-ico.indigo{background:#eef2ff;color:var(--primary)}
.sc-ico.green {background:#ecfdf5;color:var(--success)}
.sc-ico.amber {background:#fffbeb;color:var(--warn)}
.sc-ico.red   {background:#fef2f2;color:var(--danger)}
.sc-val{font-size:1.55rem;font-weight:800;line-height:1;font-family:monospace}
.sc-lbl{font-size:11px;font-weight:600;text-transform:uppercase;letter-spacing:.05em;color:var(--muted);margin-top:3px}

/* ── SEARCH + FILTER BAR ── */
.action-bar{background:var(--card);border:1px solid var(--border);border-radius:var(--radius);
  padding:14px 18px;margin-bottom:18px;display:flex;align-items:center;gap:12px;flex-wrap:wrap;box-shadow:var(--shadow)}
.search-box{position:relative;flex:1;min-width:180px}
.search-box i{position:absolute;left:11px;top:50%;transform:translateY(-50%);color:var(--muted);font-size:13px}
.search-box input{width:100%;border:1px solid var(--border);border-radius:9px;
  padding:8px 12px 8px 34px;font-size:13px;font-family:var(--font);color:var(--text);
  background:var(--bg);transition:.18s}
.search-box input:focus{border-color:var(--primary);outline:none;box-shadow:0 0 0 3px rgba(99,102,241,.1)}
.filter-pills{display:flex;gap:6px;flex-wrap:wrap}
.fp{background:var(--bg);border:1px solid var(--border);border-radius:20px;
  padding:5px 14px;font-size:12px;font-weight:600;cursor:pointer;color:var(--muted);
  transition:.18s;font-family:var(--font)}
.fp.active,.fp:hover{background:var(--primary);color:#fff;border-color:var(--primary)}

/* ── TABLE CARD ── */
.tbl-card{background:var(--card);border:1px solid var(--border);border-radius:var(--radius);
  box-shadow:var(--shadow);overflow:hidden}
.tbl-card table{width:100%;border-collapse:collapse;min-width:680px}
.tbl-card thead th{
   background:linear-gradient(135deg,var(--pd),var(--primary));
 color:#fff;padding:12px 14px;font-size:11px;font-weight:700;
 text-transform:uppercase;letter-spacing:.05em;white-space:nowrap;margin-left:35px;
 text-align:center;vertical-align:middle}
.tbl-card tbody td{padding:12px 14px;border-bottom:1px solid var(--border);
font-size:13px;vertical-align:middle;text-align:left}
.tbl-card tbody tr:last-child td{border-bottom:none}
.tbl-card tbody tr:hover{background:#fafbff}
.tbl-card tbody tr.is-current{background:#f0fdf4}

/* Session badges */
.badge-current{background:#dcfce7;color:#15803d;border-radius:6px;padding:3px 10px;font-size:11px;font-weight:700}
.badge-past   {background:#f1f5f9;color:#64748b;border-radius:6px;padding:3px 10px;font-size:11px;font-weight:700}
.badge-future {background:#eff6ff;color:#1d4ed8;border-radius:6px;padding:3px 10px;font-size:11px;font-weight:700}
.badge-ending {background:#fffbeb;color:#92400e;border-radius:6px;padding:3px 10px;font-size:11px;font-weight:700}

/* Session progress bar */
.sess-progress{height:5px;background:var(--border);border-radius:4px;overflow:hidden;margin-top:5px;min-width:80px}
.sess-fill{height:100%;border-radius:4px;background:linear-gradient(90deg,var(--primary),var(--success));transition:.5s}

/* Action buttons */
.act-btns{display:flex;gap:5px;flex-wrap:nowrap}
.btn-ico{width:30px;height:30px;border:none;border-radius:7px;cursor:pointer;
  display:inline-flex;align-items:center;justify-content:center;font-size:12px;
  transition:.18s;font-family:var(--font)}
.btn-ico.edit   {background:#eef2ff;color:var(--primary)}
.btn-ico.star   {background:#fffbeb;color:var(--warn)}
.btn-ico.copy   {background:#ecfdf5;color:var(--success)}
.btn-ico.del    {background:#fef2f2;color:var(--danger)}
.btn-ico:hover  {filter:brightness(.9);transform:scale(1.08)}
.btn-ico:disabled{opacity:.4;pointer-events:none}

/* Empty state */
.empty-state{text-align:center;padding:60px 20px;color:var(--muted)}
.empty-state i{font-size:3rem;opacity:.2;display:block;margin-bottom:14px}

/* ── BUTTONS ── */
.btn-primary{background:var(--primary);color:#fff;border:none;border-radius:9px;
  padding:8px 18px;font-size:13px;font-weight:700;cursor:pointer;font-family:var(--font);
  display:inline-flex;align-items:center;gap:6px;transition:.18s}
.btn-primary:hover{background:var(--primary-d)}
.btn-outline{background:var(--card);color:var(--muted);border:1px solid var(--border);
  border-radius:9px;padding:8px 16px;font-size:13px;font-weight:600;cursor:pointer;
  font-family:var(--font);display:inline-flex;align-items:center;gap:6px;transition:.18s}
.btn-outline:hover{border-color:var(--primary);color:var(--primary)}
.btn-success{background:#059669;color:#fff;border:none;border-radius:9px;
  padding:8px 18px;font-size:13px;font-weight:700;cursor:pointer;font-family:var(--font);
  display:inline-flex;align-items:center;gap:6px;transition:.18s}
.btn-success:hover{background:#047857}
.btn-auto{background:#fffbeb;color:#92400e;border:1px solid #fde68a;border-radius:9px;
  padding:8px 16px;font-size:13px;font-weight:700;cursor:pointer;font-family:var(--font);
  display:inline-flex;align-items:center;gap:6px;transition:.18s}
.btn-auto:hover{background:#fef3c7}

/* ── START NEW SESSION banner button ── */
.btn-new-session{
  background:linear-gradient(135deg,#059669,#10b981);
  color:#fff;border:none;border-radius:9px;padding:9px 20px;
  font-size:13px;font-weight:700;cursor:pointer;font-family:var(--font);
  display:inline-flex;align-items:center;gap:7px;transition:.18s;
  box-shadow:0 2px 8px rgba(5,150,105,.35);
}
.btn-new-session:hover{background:linear-gradient(135deg,#047857,#059669)}
.btn-new-session:disabled{opacity:.45;pointer-events:none;box-shadow:none}

/* ── MODAL ── */
.modal-overlay{
  display:none;position:fixed;inset:0;background:rgba(0,0,0,.45);
  z-index:9998;backdrop-filter:blur(3px);align-items:center;justify-content:center;padding:16px
}
.modal-overlay.open{display:flex}
.modal-box{
  background:var(--card);border-radius:var(--radius);box-shadow:var(--shadow-lg);
  width:100%;max-width:540px;max-height:90vh;overflow-y:auto;animation:modalIn .25s ease
}
@keyframes modalIn{from{opacity:0;transform:scale(.96)}to{opacity:1;transform:scale(1)}}
.modal-hdr{
  background:linear-gradient(135deg,var(--primary-d),var(--primary));
  padding:16px 20px;display:flex;justify-content:space-between;align-items:center;
  border-radius:var(--radius) var(--radius) 0 0;
}
.modal-hdr h5{color:#fff;font-size:15px;font-weight:700;margin:0}
.modal-close{background:rgba(255,255,255,.15);border:none;color:#fff;border-radius:7px;
  width:28px;height:28px;cursor:pointer;display:flex;align-items:center;justify-content:center;
  font-size:14px;transition:.18s}
.modal-close:hover{background:rgba(255,255,255,.3)}
.modal-body{padding:22px 22px 8px}
.modal-footer{padding:14px 22px 20px;display:flex;justify-content:flex-end;gap:10px}

/* Form elements */
.form-row{display:grid;grid-template-columns:1fr 1fr;gap:14px}
@media(max-width:480px){.form-row{grid-template-columns:1fr}}
.form-grp{margin-bottom:16px}
.form-grp label{display:block;font-size:12px;font-weight:700;text-transform:uppercase;
  letter-spacing:.04em;color:var(--muted);margin-bottom:6px}
.form-ctrl{width:100%;border:1px solid var(--border);border-radius:9px;padding:9px 13px;
  font-size:13px;font-family:var(--font);color:var(--text);background:var(--bg);transition:.18s}
.form-ctrl:focus{border-color:var(--primary);outline:none;box-shadow:0 0 0 3px rgba(99,102,241,.1)}
.form-ctrl.err{border-color:var(--danger);box-shadow:0 0 0 3px rgba(220,38,38,.1)}
.err-msg{font-size:11px;color:var(--danger);margin-top:4px;display:none}
.err-msg.show{display:block}
.form-hint{font-size:11px;color:var(--muted);margin-top:4px}
.form-switch-row{display:flex;justify-content:space-between;align-items:center;
  background:var(--bg);border:1px solid var(--border);border-radius:9px;padding:11px 14px;margin-bottom:14px}
.form-switch-lbl{font-size:13px;font-weight:600}
.sw{position:relative;width:40px;height:22px;flex-shrink:0}
.sw input{opacity:0;width:0;height:0;position:absolute}
.sw-t{position:absolute;inset:0;background:var(--border);border-radius:20px;cursor:pointer;transition:.3s}
.sw-t::before{content:'';position:absolute;height:16px;width:16px;left:3px;top:3px;background:#fff;border-radius:50%;transition:.3s}
.sw input:checked+.sw-t{background:var(--primary)}
.sw input:checked+.sw-t::before{transform:translateX(18px)}

/* Start new session modal - copy info box */
.copy-info{background:#f0fdf4;border:1px solid #bbf7d0;border-radius:9px;padding:14px;margin-bottom:16px}
.copy-info h6{font-size:13px;font-weight:700;color:#15803d;margin-bottom:8px}
.copy-row{display:flex;justify-content:space-between;font-size:12px;padding:3px 0;color:var(--muted)}
.copy-row span:last-child{font-weight:600;color:var(--text)}
.fresh-info{background:#fef2f2;border:1px solid #fecaca;border-radius:9px;padding:14px;margin-bottom:16px}
.fresh-info h6{font-size:13px;font-weight:700;color:#991b1b;margin-bottom:8px}

/* ── TOAST ── */
#toast-root{position:fixed;bottom:24px;right:24px;z-index:99999;display:flex;flex-direction:column;gap:8px;pointer-events:none}
.toast{border-radius:11px;padding:12px 18px;font-size:13px;font-weight:600;color:#fff;
  animation:slideIn .3s ease;max-width:340px;pointer-events:auto;box-shadow:var(--shadow-lg);
  display:flex;align-items:center;gap:8px}
.toast.ok  {background:#059669}.toast.err {background:#dc2626}
.toast.warn{background:#d97706}.toast.inf {background:var(--primary)}

@keyframes slideIn{from{opacity:0;transform:translateX(40px)}to{opacity:1;transform:translateX(0)}}

.mobile-scroll{overflow-x:auto}
@media(max-width:640px){.act-btns{gap:3px}}
</style>

<!-- PAGE WRAPPER -->
<div class="pg">

<!-- DEADLINE ALERTS (server-rendered) -->
<asp:PlaceHolder ID="phAlerts" runat="server"></asp:PlaceHolder>

<!-- HEADER -->
<div class="pg-hdr">
    <div class="pg-hdr-left">
        <h2><i class="fa fa-calendar-alt me-2" style="color:var(--primary)"></i>Academic Sessions</h2>
        <p>Manage academic years · control active session · analyse historical data</p>
    </div>
    <div class="hdr-btns">
        <button type="button" class="btn-auto" onclick="autoGenerate()">
            <i class="fa fa-magic"></i> Auto Generate
        </button>
        <button type="button" class="btn-outline" onclick="openModal('addModal')">
            <i class="fa fa-plus"></i> Add Session
        </button>
        <!-- Start New Session — enabled only when conditions met -->
        <asp:Button ID="btnStartNewSession" runat="server"
            CssClass="btn-new-session"
            OnClick="btnStartNewSession_Click"
            OnClientClick="return confirmNewSession()"
            Text="⚡ Start New Session" />
    </div>
</div>

<!-- STATS -->
<div class="stats-row">
    <div class="sc">
        <div class="sc-ico indigo"><i class="fa fa-calendar"></i></div>
        <div><div class="sc-val"><asp:Label ID="lblTotal"   runat="server">0</asp:Label></div>
             <div class="sc-lbl">Total Sessions</div></div>
    </div>
    <div class="sc">
        <div class="sc-ico green"><i class="fa fa-star"></i></div>
        <div><div class="sc-val"><asp:Label ID="lblCurrent" runat="server">0</asp:Label></div>
             <div class="sc-lbl">Current Session</div></div>
    </div>
    <div class="sc">
        <div class="sc-ico amber"><i class="fa fa-clock"></i></div>
        <div><div class="sc-val"><asp:Label ID="lblEnding"  runat="server">0</asp:Label></div>
             <div class="sc-lbl">Ending Soon</div></div>
    </div>
    <div class="sc">
        <div class="sc-ico red"><i class="fa fa-history"></i></div>
        <div><div class="sc-val"><asp:Label ID="lblPast"    runat="server">0</asp:Label></div>
             <div class="sc-lbl">Past Sessions</div></div>
    </div>
</div>

<!-- ACTION BAR -->
<div class="action-bar">
    <div class="search-box">
        <i class="fa fa-search"></i>
        <input type="text" id="txtSearch" placeholder="Search sessions…" oninput="filterTable(this.value)" />
    </div>
    <div class="filter-pills">
        <button type="button" class="fp active" onclick="setFilter('all',this)">All</button>
        <button type="button" class="fp" onclick="setFilter('current',this)">Current</button>
        <button type="button" class="fp" onclick="setFilter('past',this)">Past</button>
        <button type="button" class="fp" onclick="setFilter('future',this)">Future</button>
    </div>
</div>

<!-- TABLE -->
<div class="tbl-card mobile-scroll">
    <asp:GridView ID="gvSessions" runat="server"
        AutoGenerateColumns="false"
        CssClass="tbl-main"
        GridLines="None"
        OnRowCommand="gvSessions_RowCommand"
        OnRowDataBound="gvSessions_RowDataBound">
        <EmptyDataTemplate>
            <div class="empty-state">
                <i class="fa fa-calendar-times"></i>
                <h5>No Sessions Found</h5>
                <p>Click "Add Session" or "Auto Generate" to get started.</p>
            </div>
        </EmptyDataTemplate>
        <Columns>
            <asp:TemplateField HeaderText="Session Year">
                <ItemTemplate>
                    <div style="font-weight:700;font-size:14px"><%# Eval("SessionName") %></div>
                    <div style="font-size:11px;color:var(--muted);margin-top:2px">
                        Created: <%# Convert.ToDateTime(Eval("CreatedOn")).ToString("dd MMM yyyy") %>
                    </div>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Duration">
                <ItemTemplate>
                    <div style="font-size:13px">
                        <%# Convert.ToDateTime(Eval("StartDate")).ToString("dd MMM yyyy") %>
                        <span style="color:var(--muted)">→</span>
                        <%# Convert.ToDateTime(Eval("EndDate")).ToString("dd MMM yyyy") %>
                    </div>
                    <!-- Progress bar showing how far through the session we are -->
                    <div class="sess-progress">
                        <div class="sess-fill" id='prog_<%# Eval("SessionId") %>'
                            data-start='<%# Eval("StartDate") %>'
                            data-end='<%# Eval("EndDate") %>'
                            style="width:0%"></div>
                    </div>
                </ItemTemplate>
            </asp:TemplateField>
            <%--<asp:TemplateField HeaderText="Days Left">
                <ItemTemplate>
                    <span id='days_<%# Eval("SessionId") %>'
                          data-end='<%# Eval("EndDate") %>'
                          style="font-size:13px;font-weight:600"></span>
                </ItemTemplate>
            </asp:TemplateField>--%>
            <asp:TemplateField HeaderText="Status">
                <ItemTemplate>
                    <span id='status_<%# Eval("SessionId") %>'
                          data-current='<%# Eval("IsCurrent") %>'
                          data-start='<%# Eval("StartDate") %>'
                          data-end='<%# Eval("EndDate") %>'></span>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Summary">
                <ItemTemplate>
                    <div style="font-size:12px;color:var(--muted)">
                        <span id='summary_<%# Eval("SessionId") %>'
                              data-sid='<%# Eval("SessionId") %>'>—</span>
                    </div>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Actions">
                <ItemTemplate>
                    <div class="act-btns">
                        <asp:LinkButton runat="server" CssClass="btn-ico edit"
                            CommandName="EditRow"
                            CommandArgument='<%# Eval("SessionId") %>'
                            ToolTip="Edit Session"><i class="fa fa-pencil"></i></asp:LinkButton>

                        <asp:LinkButton runat="server" CssClass="btn-ico star"
                            CommandName="SetCurrent"
                            CommandArgument='<%# Eval("SessionId") %>'
                            ToolTip="Set as Current Session"
                            OnClientClick="return confirm('Set this as the current active session? All data entry will switch to this session.');">
                            <i class="fa fa-star"></i></asp:LinkButton>

                        <asp:LinkButton runat="server" CssClass="btn-ico copy"
                            CommandName="ViewAnalysis"
                            CommandArgument='<%# Eval("SessionId") %>'
                            ToolTip="View Session Analysis">
                            <i class="fa fa-chart-bar"></i></asp:LinkButton>

                        <asp:LinkButton runat="server" CssClass="btn-ico del"
                            CommandName="DeleteRow"
                            CommandArgument='<%# Eval("SessionId") %>'
                            ToolTip="Delete Session"
                            OnClientClick="return confirm('Delete this session? This cannot be undone.');">
                            <i class="fa fa-trash"></i></asp:LinkButton>
                    </div>
                </ItemTemplate>
            </asp:TemplateField>
        </Columns>
    </asp:GridView>
</div>

<!-- ANALYSIS PANEL (shown when admin clicks chart icon) -->
<div class="tbl-card" id="analysisPanel" style="margin-top:14px;display:none;padding:20px">
    <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:14px">
        <h5 style="font-weight:800;font-size:15px"><i class="fa fa-chart-bar me-2" style="color:var(--primary)"></i>Session Analysis</h5>
        <button type="button" class="btn-outline" style="padding:5px 12px;font-size:12px" onclick="document.getElementById('analysisPanel').style.display='none'">
            <i class="fa fa-times"></i> Close
        </button>
    </div>
    <div id="analysisContent" style="font-size:13px;color:var(--muted)">Select a session to view analysis.</div>
</div>

</div><!-- /pg -->

<!-- ═══════ ADD / EDIT MODAL ═══════ -->
<div class="modal-overlay" id="addModal">
    <div class="modal-box">
        <div class="modal-hdr">
            <h5 id="addModalTitle"><i class="fa fa-calendar me-2"></i>Add Academic Session</h5>
            <button type="button" class="modal-close" onclick="closeModal('addModal')"><i class="fa fa-times"></i></button>
        </div>
        <div class="modal-body">
            <div class="form-grp">
                <label>Academic Year *</label>
                <asp:TextBox ID="txtSessionName" runat="server" CssClass="form-ctrl"
                    placeholder="e.g. 2025-2026" MaxLength="20" />
                <div class="err-msg" id="errSessionName">Format must be YYYY-YYYY (e.g. 2025-2026)</div>
                <div class="form-hint">Tip: Use Start Session button to auto-fill from dates below.</div>
            </div>
            <div class="form-row">
                <div class="form-grp">
                    <label>Start Date *</label>
                    <asp:TextBox ID="txtStartDate" runat="server" TextMode="Date"
                        CssClass="form-ctrl" onchange="onStartDateChange()" />
                    <div class="err-msg" id="errStartDate">Start date is required.</div>
                </div>
                <div class="form-grp">
                    <label>End Date *</label>
                    <asp:TextBox ID="txtEndDate" runat="server" TextMode="Date"
                        CssClass="form-ctrl" onchange="validateDates()" />
                    <div class="err-msg" id="errEndDate">End date must be after start date.</div>
                </div>
            </div>
            <div class="form-switch-row">
                <div>
                    <div class="form-switch-lbl">Set as Current Session</div>
                    <div style="font-size:11px;color:var(--muted)">Will deactivate previous current session.</div>
                </div>
                <label class="sw">
                    <asp:CheckBox ID="chkCurrent" runat="server" />
                    <span class="sw-t"></span>
                </label>
            </div>
            <div class="form-grp" style="background:#fffbeb;border:1px solid #fde68a;border-radius:9px;padding:12px">
                <div style="font-size:12px;font-weight:700;color:#92400e;margin-bottom:4px">
                    <i class="fa fa-info-circle me-1"></i>Important Note
                </div>
                <div style="font-size:12px;color:#92400e">
                    After creating the session, use <strong>"Start New Session"</strong> button to automatically
                    copy Streams, Courses, Subjects and Chapters from the previous session into the new one.
                </div>
            </div>
        </div>
        <div class="modal-footer">
            <button type="button" class="btn-outline" onclick="closeModal('addModal')">Cancel</button>
            <asp:Button ID="btnSave" runat="server" CssClass="btn-primary"
                Text="Save Session" OnClick="btnSave_Click"
                OnClientClick="return validateAddForm()" />
        </div>
    </div>
</div>

<!-- ═══════ START NEW SESSION MODAL ═══════ -->
<div class="modal-overlay" id="newSessionModal">
    <div class="modal-box">
        <div class="modal-hdr" style="background:linear-gradient(135deg,#047857,#059669)">
            <h5><i class="fa fa-rocket me-2"></i>Start New Academic Session</h5>
            <button type="button" class="modal-close" onclick="closeModal('newSessionModal')"><i class="fa fa-times"></i></button>
        </div>
        <div class="modal-body">
            <div style="background:#fff7ed;border:1px solid #fed7aa;border-radius:9px;padding:14px;margin-bottom:16px">
                <div style="font-size:13px;font-weight:700;color:#9a3412;margin-bottom:5px">
                    <i class="fa fa-exclamation-triangle me-1"></i>Read Before Proceeding
                </div>
                <div style="font-size:12px;color:#9a3412;line-height:1.7">
                    This will create a fresh environment for the next academic year.
                    You must have already <strong>created the new session</strong> from "Add Session".
                </div>
            </div>

            <div class="copy-info">
                <h6><i class="fa fa-copy me-1"></i>What will be COPIED to new session:</h6>
                <div class="copy-row"><span>✅ Streams (departments)</span><span>Copied by name</span></div>
                <div class="copy-row"><span>✅ Courses (branches)</span><span>Copied by name</span></div>
                <div class="copy-row"><span>✅ Study Levels &amp; Semesters</span><span>Copied by name</span></div>
                <div class="copy-row"><span>✅ Sections</span><span>Copied by name</span></div>
                <div class="copy-row"><span>✅ Subjects &amp; Mappings</span><span>Copied by name</span></div>
                <div class="copy-row"><span>✅ Chapters (structure)</span><span>Copied</span></div>
                <div class="copy-row"><span>✅ Videos (links &amp; paths)</span><span>View count reset to 0</span></div>
            </div>

            <div class="fresh-info">
                <h6><i class="fa fa-broom me-1"></i>What will START FRESH (historical data kept):</h6>
                <div style="font-size:12px;color:#991b1b;line-height:1.9">
                    Attendance · Assignment Submissions · Quiz Results ·
                    Video Views · Watch Progress · Student Enrollments ·
                    Notifications · Comments · AI History
                </div>
            </div>

            <div class="form-grp">
                <label>Copy FROM (Source Session) *</label>
                <asp:DropDownList ID="ddlCopyFrom" runat="server" CssClass="form-ctrl"></asp:DropDownList>
                <div class="form-hint">Usually the current/most recent session.</div>
            </div>

            <div class="form-grp">
                <label>Copy TO (Target New Session) *</label>
                <asp:DropDownList ID="ddlCopyTo" runat="server" CssClass="form-ctrl"></asp:DropDownList>
                <div class="form-hint">The new session you just created.</div>
            </div>

            <div class="form-switch-row">
                <div>
                    <div class="form-switch-lbl">Set new session as Current</div>
                    <div style="font-size:11px;color:var(--muted)">Students and staff will see this session immediately.</div>
                </div>
                <label class="sw">
                    <asp:CheckBox ID="chkSetAsCurrent" runat="server" />
                    <span class="sw-t"></span>
                </label>
            </div>
        </div>
        <div class="modal-footer">
            <button type="button" class="btn-outline" onclick="closeModal('newSessionModal')">Cancel</button>
            <asp:Button ID="btnExecuteNewSession" runat="server"
                CssClass="btn-success" Text="Start New Session →"
                OnClick="btnExecuteNewSession_Click" />
        </div>
    </div>
</div>

<!-- TOAST ROOT -->
<div id="toast-root"></div>

<asp:HiddenField ID="HiddenField1" runat="server" />
<asp:HiddenField ID="hfToastType" runat="server" />
    <asp:HiddenField ID="hfToastMsg" runat="server" />

<script>
/* ── Toast ── */
function toast(msg, type='inf'){
    const w=document.getElementById('toast-root');
    const d=document.createElement('div');
    d.className='toast '+type;
    const icons={ok:'fa-check-circle',err:'fa-exclamation-circle',warn:'fa-exclamation-triangle',inf:'fa-info-circle'};
    d.innerHTML=`<i class="fa ${icons[type]||'fa-info-circle'}"></i>${msg}`;
    w.appendChild(d);
    setTimeout(()=>d.remove(), 5000);
}

/* ── Server toast on postback ── */
window.addEventListener('DOMContentLoaded',()=>{
    const hfMsg  = document.getElementById('<%= hfToastMsg.ClientID %>');
    const hfType = document.getElementById('<%= hfToastType.ClientID %>');
    if(hfMsg&&hfMsg.value.trim()){
        toast(hfMsg.value, hfType.value||'inf');
        hfMsg.value='';
    }

    // Compute progress bars + days left + status badges
    computeRowData();
    loadSessionSummaries();
});

/* ── Progress bars & status badges ── */
function computeRowData(){
    const now = new Date(); now.setHours(0,0,0,0);
    document.querySelectorAll('.sess-fill').forEach(el=>{
        const s=new Date(el.dataset.start), e=new Date(el.dataset.end);
        if(isNaN(s)||isNaN(e)) return;
        const total=(e-s)/(1000*60*60*24);
        const elapsed=(now-s)/(1000*60*60*24);
        const pct=Math.max(0,Math.min(100,Math.round(elapsed/total*100)));
        el.style.width=pct+'%';
    });

    document.querySelectorAll('[id^="days_"]').forEach(el=>{
        const end=new Date(el.dataset.end);
        if(isNaN(end)) return;
        const days=Math.round((end-now)/(1000*60*60*24));
        if(days<0) el.innerHTML=`<span style="color:var(--muted)">Ended ${Math.abs(days)}d ago</span>`;
        else if(days<=30) el.innerHTML=`<span style="color:var(--danger);font-weight:700">${days}d left ⚠</span>`;
        else if(days<=60) el.innerHTML=`<span style="color:var(--warn);font-weight:700">${days}d left</span>`;
        else el.innerHTML=`<span style="color:var(--success)">${days}d left</span>`;
    });

    document.querySelectorAll('[id^="status_"]').forEach(el=>{
        const isCurrent=el.dataset.current==='True';
        const start=new Date(el.dataset.start), end=new Date(el.dataset.end);
        const days=Math.round((end-now)/(1000*60*60*24));
        let badge='';
        if(isCurrent)        badge=`<span class="badge-current">★ Current</span>`;
        else if(days<0)      badge=`<span class="badge-past">Past</span>`;
        else if(start>now)   badge=`<span class="badge-future">Upcoming</span>`;
        else if(days<=30)    badge=`<span class="badge-ending">Ending Soon</span>`;
        else                 badge=`<span class="badge-past">Inactive</span>`;
        el.innerHTML=badge;
    });
}

/* ── Load session summaries via AJAX (counts) ── */
function loadSessionSummaries(){
    document.querySelectorAll('[id^="summary_"]').forEach(el=>{
        const sid=el.dataset.sid;
        fetch('AcademicSession.aspx/GetSessionSummary',{
            method:'POST',
            headers:{'Content-Type':'application/json;charset=utf-8'},
            body:JSON.stringify({sessionId:parseInt(sid)})
        })
        .then(r=>r.json())
        .then(res=>{
            const d=typeof res.d==='string'?JSON.parse(res.d):res.d;
            if(d) el.innerHTML=`${d.Streams}S · ${d.Subjects}Sub · ${d.Students}Stu · ${d.Videos}Vid`;
        }).catch(()=>{});
    });
}

/* ── Table filter ── */
let filterMode='all';
function setFilter(mode, btn){
    filterMode=mode;
    document.querySelectorAll('.fp').forEach(b=>b.classList.remove('active'));
    btn.classList.add('active');
    applyFilters();
}
function filterTable(q){
    applyFilters(q);
}
function applyFilters(q=''){
    q=q||document.getElementById('txtSearch').value;
    const rows=document.querySelectorAll('.tbl-main tbody tr');
    rows.forEach(row=>{
        const text=row.innerText.toLowerCase();
        const matchQ=!q||text.includes(q.toLowerCase());
        const statusEl=row.querySelector('[id^="status_"]');
        let matchF=true;
        if(filterMode!=='all'&&statusEl){
            const s=statusEl.innerText.toLowerCase();
            if(filterMode==='current') matchF=s.includes('current');
            else if(filterMode==='past') matchF=s.includes('past')||s.includes('ended');
            else if(filterMode==='future') matchF=s.includes('upcoming');
        }
        row.style.display=(matchQ&&matchF)?'':'none';
    });
}

/* ── Modal helpers ── */
function openModal(id){ document.getElementById(id).classList.add('open'); }
function closeModal(id){ document.getElementById(id).classList.remove('open'); }
document.querySelectorAll('.modal-overlay').forEach(m=>{
    m.addEventListener('click',e=>{ if(e.target===m) m.classList.remove('open'); });
});

/* ── Auto-generate session name from start date ── */
function onStartDateChange(){
    const sd=document.getElementById('<%= txtStartDate.ClientID %>').value;
    if(!sd) return;
    const yr=new Date(sd).getFullYear();
    const snEl=document.getElementById('<%= txtSessionName.ClientID %>');
    if(!snEl.value) snEl.value=yr+'-'+(yr+1);
}

function autoGenerate(){
    const yr=new Date().getFullYear();
    document.getElementById('<%= txtSessionName.ClientID %>').value=yr+'-'+(yr+1);
    document.getElementById('<%= txtStartDate.ClientID %>').value=yr+'-06-01';
    document.getElementById('<%= txtEndDate.ClientID %>').value=(yr+1)+'-05-31';
    document.getElementById('addModalTitle').innerHTML='<i class="fa fa-calendar me-2"></i>Add Academic Session';
    openModal('addModal');
}

/* ── Validate dates ── */
function validateDates(){
    const s=document.getElementById('<%= txtStartDate.ClientID %>').value;
    const e=document.getElementById('<%= txtEndDate.ClientID %>').value;
    if(s&&e&&new Date(e)<=new Date(s)){
        showErr('errEndDate',true,'End date must be after start date.');
        return false;
    }
    showErr('errEndDate',false);
    return true;
}

/* ── Validate add form ── */
function validateAddForm(){
    let valid=true;
    const sn=document.getElementById('<%= txtSessionName.ClientID %>').value.trim();
    if(!sn||!/^\d{4}-\d{4}$/.test(sn)){
        showErr('errSessionName',true,'Format must be YYYY-YYYY (e.g. 2025-2026)');
        valid=false;
    } else { showErr('errSessionName',false); }

    const sd=document.getElementById('<%= txtStartDate.ClientID %>').value;
        if (!sd) { showErr('errStartDate', true, 'Start date is required.'); valid = false; }
        else { showErr('errStartDate', false); }

        if (!validateDates()) valid = false;
        return valid;
    }

    function showErr(id, show, msg = '') {
        const el = document.getElementById(id);
        if (!el) return;
        el.classList.toggle('show', show);
        if (msg) el.textContent = msg;
        const input = el.previousElementSibling;
        if (input) input.classList.toggle('err', show);
    }

    /* ── Confirm new session start ── */
    function confirmNewSession() {
        openModal('newSessionModal');
        return false; // prevent postback — modal handles it
    }

    /* ── Analysis panel ── */
    function showAnalysis(sid) {
        const panel = document.getElementById('analysisPanel');
        const content = document.getElementById('analysisContent');
        panel.style.display = 'block';
        content.innerHTML = '<i class="fa fa-spinner fa-spin me-2"></i>Loading analysis…';
        panel.scrollIntoView({ behavior: 'smooth' });
        fetch('AcademicSession.aspx/GetSessionSummary', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json;charset=utf-8' },
            body: JSON.stringify({ sessionId: parseInt(sid) })
        })
            .then(r => r.json())
            .then(res => {
                const d = typeof res.d === 'string' ? JSON.parse(res.d) : res.d;
                if (!d) { content.innerHTML = 'No data available.'; return; }
                content.innerHTML = `
        <div style="display:grid;grid-template-columns:repeat(auto-fill,minmax(140px,1fr));gap:12px;margin-bottom:16px">
            ${[['Streams', d.Streams, 'fa-layer-group', '#eef2ff', '#4f46e5'],
                    ['Courses', d.Courses, 'fa-graduation-cap', '#ecfdf5', '#059669'],
                    ['Subjects', d.Subjects, 'fa-book', '#fffbeb', '#d97706'],
                    ['Students', d.Students, 'fa-users', '#fdf4ff', '#7c3aed'],
                    ['Videos', d.Videos, 'fa-video', '#eff6ff', '#1d4ed8'],
                    ['Attendance', d.Attendance, 'fa-calendar-check', '#fef2f2', '#dc2626']
                    ].map(([lbl, val, ico, bg, clr]) => `
            <div style="background:${bg};border-radius:10px;padding:14px;text-align:center">
                <i class="fa ${ico}" style="color:${clr};font-size:1.3rem;margin-bottom:6px;display:block"></i>
                <div style="font-size:1.4rem;font-weight:800;color:#0f172a;font-family:monospace">${val}</div>
                <div style="font-size:11px;font-weight:600;color:#64748b;text-transform:uppercase">${lbl}</div>
            </div>`).join('')}
        </div>
        <p style="font-size:12px;color:var(--muted)">Data filtered to this session only. Switch sessions from the header dropdown to compare.</p>`;
            }).catch(() => { content.innerHTML = '<span style="color:var(--danger)">Failed to load analysis.</span>'; });
    }
</script>
</asp:Content>
