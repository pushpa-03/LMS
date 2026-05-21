<%@ Page Title="Parent Directory" Language="C#"
    MasterPageFile="~/Admin/AdminMaster.master"
    AutoEventWireup="true"
    CodeBehind="ParentList.aspx.cs"
    Inherits="LearningManagementSystem.Admin.ParentList" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server" />

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet">

<style>
/* ═══════════════════════════════════════════════════
   PARENT DIRECTORY — Clean Blue-Slate Production UI
   Font: Plus Jakarta Sans · JetBrains Mono
═══════════════════════════════════════════════════ */
:root {
  --bg:       #f0f4fa;
  --surf:     #ffffff;
  --surf2:    #f7f9fd;
  --surf3:    #eef2f9;
  --bdr:      #e2e8f4;
  --bdr2:     #c8d4ec;

  --blue:     #2563eb;
  --blue2:    #3b82f6;
  --blue-lt:  #eff6ff;
  --blue-mid: #dbeafe;
  --navy:     #1e3a8a;

  --indigo:   #4f46e5;
  --indigo-lt:#eef2ff;
  --green:    #059669;
  --green-lt: #ecfdf5;
  --amber:    #d97706;
  --amber-lt: #fffbeb;
  --red:      #dc2626;
  --red-lt:   #fef2f2;
  --sky:      #0891b2;
  --sky-lt:   #ecfeff;

  --ink:      #0f172a;
  --ink2:     #1e293b;
  --ink3:     #334155;
  --muted:    #64748b;
  --dim:      #94a3b8;
  --faint:    #cbd5e1;

  --f:        'Plus Jakarta Sans', system-ui, sans-serif;
  --mono:     'JetBrains Mono', monospace;

  --r:        12px;
  --rlg:      16px;
  --rxl:      20px;
  --sh:       0 1px 3px rgba(15,23,42,.06), 0 4px 16px rgba(15,23,42,.07);
  --sh2:      0 4px 24px rgba(15,23,42,.10), 0 12px 40px rgba(15,23,42,.08);
}

*,*::before,*::after { box-sizing: border-box; margin: 0; padding: 0; }
.pl-root { font-family: var(--f); color: var(--ink); font-size: 14px; line-height: 1.5; }

/* ── PAGE HEADER ── */
.pl-header {
  display: flex; align-items: flex-start; justify-content: space-between;
  flex-wrap: wrap; gap: 16px; margin-bottom: 26px;
}
.pl-h-left {}
.pl-eyebrow {
  font-size: 10px; font-weight: 700; letter-spacing: .12em; text-transform: uppercase;
  color: var(--blue); display: flex; align-items: center; gap: 6px; margin-bottom: 5px;
}
.pl-eyebrow::before {
  content: ''; width: 16px; height: 2px;
  background: linear-gradient(90deg, var(--blue), var(--blue2));
  border-radius: 1px;
}
.pl-title {
  font-size: 1.55rem; font-weight: 800; color: var(--ink); line-height: 1.1; margin-bottom: 4px;
}
.pl-title span { color: var(--blue); }
.pl-sub { font-size: 12px; color: var(--muted); }
.pl-sub b { color: var(--ink3); }

.pl-h-right { display: flex; align-items: center; gap: 10px; flex-wrap: wrap; }

/* Search */
.pl-search-wrap {
  position: relative; display: flex; align-items: center;
}
.pl-search-wrap i {
  position: absolute; left: 12px; color: var(--dim); font-size: 13px; pointer-events: none;
}
.pl-search {
  padding: 8px 14px 8px 36px; border: 1.5px solid var(--bdr);
  border-radius: 30px; font-family: var(--f); font-size: 13px; font-weight: 500;
  color: var(--ink2); background: var(--surf); width: 230px;
  transition: border-color .18s, box-shadow .18s; outline: none;
}
.pl-search:focus { border-color: var(--blue2); box-shadow: 0 0 0 3px rgba(59,130,246,.12); }

/* Toggle button */
.pl-toggle-btn {
  display: inline-flex; align-items: center; gap: 7px;
  padding: 8px 18px; border-radius: 30px;
  border: 1.5px solid var(--bdr); background: var(--surf);
  font-family: var(--f); font-size: 13px; font-weight: 700;
  color: var(--ink3); cursor: pointer; transition: all .18s; white-space: nowrap;
}
.pl-toggle-btn:hover { border-color: var(--blue2); color: var(--blue); background: var(--blue-lt); }

/* ── STAT CARDS ── */
.pl-stats { display: grid; grid-template-columns: repeat(4, 1fr); gap: 14px; margin-bottom: 24px; }
@media(max-width:900px) { .pl-stats { grid-template-columns: 1fr 1fr; } }
@media(max-width:500px) { .pl-stats { grid-template-columns: 1fr; } }

.pl-stat {
  border-radius: var(--rlg); padding: 20px 22px;
  display: flex; align-items: center; gap: 16px;
  position: relative; overflow: hidden;
  box-shadow: var(--sh); transition: transform .22s, box-shadow .22s;
  animation: statPop .5s both;
}
.pl-stat:hover { transform: translateY(-4px); box-shadow: var(--sh2); }
.pl-stat::after {
  content: ''; position: absolute; bottom: -20px; right: -20px;
  width: 80px; height: 80px; border-radius: 50%;
  background: rgba(255,255,255,.15);
}
.pl-stat::before {
  content: ''; position: absolute; top: 0; left: 0; right: 0; bottom: 0;
  background: inherit; filter: brightness(1);
}
.pl-stat.blue   { background: linear-gradient(135deg, #1d4ed8, #3b82f6); color: #fff; }
.pl-stat.green  { background: linear-gradient(135deg, #047857, #10b981); color: #fff; }
.pl-stat.amber  { background: linear-gradient(135deg, #b45309, #f59e0b); color: #fff; }
.pl-stat.sky    { background: linear-gradient(135deg, #0369a1, #38bdf8); color: #fff; }

.pl-stat-icon {
  width: 48px; height: 48px; border-radius: 12px;
  background: rgba(255,255,255,.2); backdrop-filter: blur(8px);
  display: flex; align-items: center; justify-content: center;
  font-size: 18px; flex-shrink: 0; position: relative; z-index: 1;
}
.pl-stat-body { position: relative; z-index: 1; }
.pl-stat-val {
  font-size: 1.8rem; font-weight: 800; line-height: 1;
  font-family: var(--mono); margin-bottom: 3px;
  animation: countUp .6s ease;
}
.pl-stat-lbl { font-size: 11px; font-weight: 600; opacity: .85; letter-spacing: .02em; }

/* Shine sweep on hover */
.pl-stat::after { transition: opacity .3s; }
.pl-stat:hover::after { opacity: .25; }

@keyframes statPop {
  from { opacity:0; transform: translateY(16px) scale(.97); }
  to   { opacity:1; transform: translateY(0)    scale(1); }
}
@keyframes countUp {
  from { opacity:0; transform: translateY(8px); }
  to   { opacity:1; transform: translateY(0); }
}

/* ── FILTER/INFO BAR ── */
.pl-info-bar {
  display: flex; align-items: center; justify-content: space-between;
  flex-wrap: wrap; gap: 10px; margin-bottom: 16px;
}
.pl-info-left { display: flex; align-items: center; gap: 10px; }
.pl-showing {
  font-size: 13px; color: var(--muted); font-weight: 500;
}
.pl-showing b { color: var(--ink3); }
.pl-mode-badge {
  display: inline-flex; align-items: center; gap: 5px;
  padding: 3px 11px; border-radius: 20px; font-size: 11px; font-weight: 700;
}
.pl-mode-badge.active  { background: var(--green-lt); color: var(--green); border: 1px solid #a7f3d0; }
.pl-mode-badge.inactive{ background: var(--red-lt);   color: var(--red);   border: 1px solid #fca5a5; }
.pl-mode-badge::before { content:''; width:6px; height:6px; border-radius:50%; background:currentColor; }

/* ── STUDENT GROUP CARD ── */
.pl-student-group {
  background: var(--surf); border: 1px solid var(--bdr);
  border-radius: var(--rlg); overflow: hidden;
  box-shadow: var(--sh); margin-bottom: 16px;
  transition: box-shadow .22s, border-color .22s;
  animation: fadeUp .4s both;
}
.pl-student-group:hover { box-shadow: var(--sh2); border-color: var(--bdr2); }
@keyframes fadeUp { from{opacity:0;transform:translateY(12px)} to{opacity:1;transform:translateY(0)} }

/* Student header */
.pl-stu-head {
  display: flex; align-items: center; gap: 14px;
  padding: 16px 20px;
  background: linear-gradient(135deg, var(--indigo) 0%, #6366f1 100%);
}
.pl-stu-avatar {
  width: 42px; height: 42px; border-radius: 50%;
  background: rgba(255,255,255,.2); backdrop-filter: blur(6px);
  display: flex; align-items: center; justify-content: center;
  font-size: 16px; font-weight: 800; color: #fff; flex-shrink: 0;
  border: 2px solid rgba(255,255,255,.3);
}
.pl-stu-info { flex: 1; min-width: 0; }
.pl-stu-name { font-size: 15px; font-weight: 800; color: #fff; line-height: 1.2; margin-bottom: 4px; }
.pl-stu-meta {
  display: flex; flex-wrap: wrap; gap: 6px;
}
.pl-stu-tag {
  display: inline-flex; align-items: center; gap: 4px;
  background: rgba(255,255,255,.18); backdrop-filter: blur(4px);
  border-radius: 20px; padding: 2px 10px;
  font-size: 11px; font-weight: 600; color: rgba(255,255,255,.92);
  border: 1px solid rgba(255,255,255,.2);
}
.pl-stu-tag i { font-size: 10px; opacity: .8; }
.pl-stu-count {
  display: flex; align-items: center; justify-content: center;
  background: rgba(255,255,255,.2); border-radius: 10px;
  padding: 6px 12px; font-size: 12px; font-weight: 700; color: #fff; flex-shrink: 0;
  white-space: nowrap;
}

/* Parent rows */
.pl-parents-body { padding: 10px 16px 14px; }

.pl-parent-row {
  display: flex; align-items: center; gap: 14px;
  padding: 12px 14px; border-radius: 10px;
  border: 1px solid var(--bdr); background: var(--surf2);
  margin-bottom: 8px; transition: all .18s;
}
.pl-parent-row:last-child { margin-bottom: 0; }
.pl-parent-row:hover { background: var(--blue-lt); border-color: var(--blue-mid); }

.pl-parent-av {
  width: 40px; height: 40px; border-radius: 50%; flex-shrink: 0;
  display: flex; align-items: center; justify-content: center;
  font-size: 15px; font-weight: 800;
}

.pl-parent-info { flex: 1; min-width: 0; }
.pl-parent-name { font-size: 13px; font-weight: 700; color: var(--ink2); margin-bottom: 2px; }
.pl-parent-rel  { font-size: 11px; font-weight: 600; color: var(--blue); }

.pl-parent-contact { text-align: right; flex-shrink: 0; }
.pl-parent-email  { font-size: 12px; color: var(--ink3); margin-bottom: 2px; }
.pl-parent-phone  { font-size: 11px; font-family: var(--mono); color: var(--muted); }

/* Relation avatar colors */
.pl-av-father  { background: var(--blue-lt);    color: var(--blue); }
.pl-av-mother  { background: var(--indigo-lt);  color: var(--indigo); }
.pl-av-guardian{ background: var(--sky-lt);     color: var(--sky); }
.pl-av-default { background: var(--surf3);      color: var(--muted); }

/* No parents placeholder */
.pl-no-parents {
  text-align: center; padding: 20px; color: var(--dim); font-size: 13px;
  display: flex; align-items: center; justify-content: center; gap: 7px;
}

/* ── PAGINATION ── */
.pl-pagination-wrap {
  display: flex; align-items: center; justify-content: space-between;
  flex-wrap: wrap; gap: 12px; margin-top: 24px; padding: 16px 20px;
  background: var(--surf); border: 1px solid var(--bdr);
  border-radius: var(--rlg); box-shadow: var(--sh);
}
.pl-page-info { font-size: 12px; color: var(--muted); font-weight: 500; }
.pl-page-info b { color: var(--ink3); }
.pl-page-btns { display: flex; align-items: center; gap: 4px; }

.pl-pg-btn {
  min-width: 36px; height: 36px; border-radius: 8px;
  border: 1.5px solid var(--bdr); background: var(--surf);
  font-family: var(--f); font-size: 13px; font-weight: 600;
  color: var(--ink3); cursor: pointer; transition: all .18s;
  display: inline-flex; align-items: center; justify-content: center;
  padding: 0 8px;
}
.pl-pg-btn:hover:not(.active):not(:disabled) {
  border-color: var(--blue2); color: var(--blue); background: var(--blue-lt);
}
.pl-pg-btn.active {
  background: var(--blue); border-color: var(--blue);
  color: #fff; box-shadow: 0 4px 12px rgba(37,99,235,.3);
}
.pl-pg-btn:disabled {
  opacity: .35; cursor: not-allowed; pointer-events: none;
}
.pl-pg-sep {
  width: 36px; height: 36px; display: inline-flex; align-items: center;
  justify-content: center; color: var(--dim); font-size: 13px;
}

/* ── EMPTY STATE ── */
.pl-empty {
  text-align: center; padding: 52px 20px;
  background: var(--surf); border: 1px solid var(--bdr);
  border-radius: var(--rlg); box-shadow: var(--sh);
}
.pl-empty-icon {
  width: 68px; height: 68px; border-radius: 18px;
  background: var(--blue-lt); border: 2px dashed var(--bdr2);
  display: flex; align-items: center; justify-content: center;
  font-size: 26px; color: var(--blue2); margin: 0 auto 18px;
}
.pl-empty-title { font-size: 17px; font-weight: 800; color: var(--ink3); margin-bottom: 6px; }
.pl-empty-sub   { font-size: 13px; color: var(--dim); max-width: 340px; margin: 0 auto; }

/* ── RESPONSIVE ── */
@media(max-width:640px) {
  .pl-stu-head { flex-wrap: wrap; }
  .pl-parent-row { flex-wrap: wrap; }
  .pl-parent-contact { text-align: left; }
  .pl-search { width: 180px; }
}
</style>

<div class="pl-root">

<!-- ══ PAGE HEADER ══════════════════════════════════════════════════ -->
<div class="pl-header">
    <div class="pl-h-left">
        <div class="pl-eyebrow">Guardian Management</div>
        <div class="pl-title">Parent <span>Directory</span></div>
        <div class="pl-sub">
            All parent-student mappings &nbsp;·&nbsp;
            <b>Last updated: <%= DateTime.Now.ToString("dd MMM yyyy, hh:mm tt") %></b>
        </div>
    </div>
    <div class="pl-h-right">
        <!-- Search (client-side filter, keeps pagination in sync) -->
        <div class="pl-search-wrap">
            <i class="fa fa-search"></i>
            <asp:TextBox ID="txtSearch" runat="server"
                CssClass="pl-search"
                placeholder="Search parent / student…"
                onkeyup="filterParents()" />
        </div>

        <!-- Toggle Active / Inactive -->
        <asp:LinkButton ID="btnToggleView" runat="server"
            CssClass="pl-toggle-btn"
            OnClick="ToggleView_Click">
            <i class="fa fa-eye me-1"></i> View Inactive
        </asp:LinkButton>
    </div>
</div>

<!-- ══ STAT CARDS ════════════════════════════════════════════════════ -->
<div class="pl-stats">

    <div class="pl-stat blue" style="animation-delay:.04s">
        <div class="pl-stat-icon"><i class="fa fa-users"></i></div>
        <div class="pl-stat-body">
            <div class="pl-stat-val"><%= TotalParents %></div>
            <div class="pl-stat-lbl">Total Parents</div>
        </div>
    </div>

    <div class="pl-stat green" style="animation-delay:.10s">
        <div class="pl-stat-icon"><i class="fa fa-user-check"></i></div>
        <div class="pl-stat-body">
            <div class="pl-stat-val"><%= ActiveParents %></div>
            <div class="pl-stat-lbl">Active</div>
        </div>
    </div>

    <div class="pl-stat amber" style="animation-delay:.16s">
        <div class="pl-stat-icon"><i class="fa fa-user-times"></i></div>
        <div class="pl-stat-body">
            <div class="pl-stat-val"><%= InactiveParents %></div>
            <div class="pl-stat-lbl">Inactive</div>
        </div>
    </div>

    <div class="pl-stat sky" style="animation-delay:.22s">
        <div class="pl-stat-icon"><i class="fa fa-link"></i></div>
        <div class="pl-stat-body">
            <div class="pl-stat-val"><%= TotalLinks %></div>
            <div class="pl-stat-lbl">Student Links</div>
        </div>
    </div>

</div>

<!-- ══ INFO BAR ══════════════════════════════════════════════════════ -->
<div class="pl-info-bar">
    <div class="pl-info-left">
        <span class="pl-showing">
            Showing <b><asp:Label ID="lblShowRange" runat="server" Text="—" /></b>
            of <b><asp:Label ID="lblTotalCount" runat="server" Text="0" /></b> students
        </span>

        <asp:Label ID="lblModeBadge" runat="server" CssClass="pl-mode-badge active" Text="Active" />
    </div>
    <div>
        <asp:Label ID="lblPageSummary" runat="server"
            style="font-size:12px;color:var(--muted);font-weight:500" />
    </div>
</div>

<!-- ══ STUDENT-PARENT GROUPS ════════════════════════════════════════ -->
<asp:Repeater ID="rptStudents" runat="server">
    <ItemTemplate>
        <div class="pl-student-group">

            <!-- Student Header -->
            <div class="pl-stu-head">
                <div class="pl-stu-avatar">
                    <%# Eval("StudentName").ToString().Length > 0
                        ? Eval("StudentName").ToString().Substring(0,1).ToUpper() : "?" %>
                </div>
                <div class="pl-stu-info">
                    <div class="pl-stu-name"><%# Eval("StudentName") %></div>
                    <div class="pl-stu-meta">
                        <%# Eval("Stream").ToString() != "-" ? "<span class='pl-stu-tag'><i class='fa fa-layer-group'></i>" + Eval("Stream") + "</span>" : "" %>
                        <%# Eval("Course").ToString() != "-" ? "<span class='pl-stu-tag'><i class='fa fa-book'></i>" + Eval("Course") + "</span>" : "" %>
                        <%# Eval("Level").ToString()  != "-" ? "<span class='pl-stu-tag'><i class='fa fa-graduation-cap'></i>" + Eval("Level") + "</span>" : "" %>
                        <%# Eval("Semester").ToString() != "-" ? "<span class='pl-stu-tag'><i class='fa fa-calendar'></i>" + Eval("Semester") + "</span>" : "" %>
                        <%# Eval("Section").ToString() != "-" ? "<span class='pl-stu-tag'><i class='fa fa-users'></i>Sec " + Eval("Section") + "</span>" : "" %>
                    </div>
                </div>
                <div class="pl-stu-count">
                    <i class="fa fa-user-friends me-1"></i>
                    <%# ((System.Collections.IEnumerable)Eval("Parents")).Cast<object>().Count() %> guardian(s)
                </div>
            </div>

            <!-- Parent Rows -->
            <div class="pl-parents-body">
                <asp:Repeater ID="rptParents" runat="server" DataSource='<%# Eval("Parents") %>'>
                    <ItemTemplate>
                        <div class="pl-parent-row">
                            <%-- Avatar colour by relation --%>
                            <div class="pl-parent-av <%# GetRelationClass(Eval("Relation")) %>">
                                <%# Eval("ParentName").ToString().Length > 0
                                    ? Eval("ParentName").ToString().Substring(0,1).ToUpper() : "?" %>
                            </div>
                            <div class="pl-parent-info">
                                <div class="pl-parent-name"><%# Eval("ParentName") %></div>
                                <div class="pl-parent-rel">
                                    <i class="fa fa-heart me-1"></i><%# Eval("Relation") %>
                                </div>
                            </div>
                            <div class="pl-parent-contact">
                                <div class="pl-parent-email">
                                    <i class="fa fa-envelope me-1" style="color:var(--dim)"></i><%# Eval("Email") %>
                                </div>
                                <div class="pl-parent-phone">
                                    <i class="fa fa-phone me-1"></i><%# Eval("ContactNo") %>
                                </div>
                            </div>
                        </div>
                    </ItemTemplate>
                    
                </asp:Repeater>
            </div>

        </div>
    </ItemTemplate>
</asp:Repeater>

<!-- ══ EMPTY STATE ═══════════════════════════════════════════════════ -->
<asp:Panel ID="pnlEmpty" runat="server" Visible="false">
    <div class="pl-empty">
        <div class="pl-empty-icon"><i class="fa fa-user-slash"></i></div>
        <div class="pl-empty-title">No Parents Found</div>
        <div class="pl-empty-sub">
            Try adjusting your search or switch between Active&nbsp;/ Inactive view.
        </div>
    </div>
</asp:Panel>

<!-- ══ PAGINATION ════════════════════════════════════════════════════ -->
<asp:Panel ID="pnlPagination" runat="server" Visible="false">
<div class="pl-pagination-wrap">

    <div class="pl-page-info">
        Page <b><asp:Label ID="lblCurrentPage" runat="server" /></b>
        of <b><asp:Label ID="lblTotalPages" runat="server" /></b>
    </div>

    <div class="pl-page-btns">

        <%-- First --%>
        <asp:LinkButton ID="btnFirst" runat="server"
            CssClass="pl-pg-btn"
            CommandName="Page" CommandArgument="First"
            OnClick="Pager_Click" ToolTip="First page">
            «
        </asp:LinkButton>

        <%-- Prev --%>
        <asp:LinkButton ID="btnPrev" runat="server"
            CssClass="pl-pg-btn"
            CommandName="Page" CommandArgument="Prev"
            OnClick="Pager_Click" ToolTip="Previous page">
            ‹
        </asp:LinkButton>

        <%-- Numbered page buttons (rendered server-side) --%>
        <asp:PlaceHolder ID="phPageNumbers" runat="server" />

        <%-- Next --%>
        <asp:LinkButton ID="btnNext" runat="server"
            CssClass="pl-pg-btn"
            CommandName="Page" CommandArgument="Next"
            OnClick="Pager_Click" ToolTip="Next page">
            ›
        </asp:LinkButton>

        <%-- Last --%>
        <asp:LinkButton ID="btnLast" runat="server"
            CssClass="pl-pg-btn"
            CommandName="Page" CommandArgument="Last"
            OnClick="Pager_Click" ToolTip="Last page">
            »
        </asp:LinkButton>

    </div>

</div>
</asp:Panel>

</div><%-- /pl-root --%>

<script>
/* ── Client-side search (filters current page only) ── */
function filterParents() {
    var val = document.getElementById('<%= txtSearch.ClientID %>').value.toLowerCase();
    var groups = document.querySelectorAll('.pl-student-group');
    var visible = 0;

    groups.forEach(function(g) {
        var match = g.innerText.toLowerCase().indexOf(val) > -1;
        g.style.display = match ? '' : 'none';
        if (match) visible++;
    });

    var empty = document.getElementById('<%= pnlEmpty.ClientID %>');
        if (empty) empty.style.display = visible === 0 && val.length > 0 ? 'block' : 'none';
    }
</script>

</asp:Content>
