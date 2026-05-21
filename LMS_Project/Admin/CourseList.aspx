<%@ Page Title="Course List"
    Language="C#"
    MasterPageFile="~/Admin/AdminMaster.master"
    AutoEventWireup="true"
    CodeBehind="CourseList.aspx.cs"
    Inherits="LearningManagementSystem.Admin.CourseList" %>

<asp:Content ID="cHead" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<style>
:root { --pri:#4f46e5; --pri-lt:#eef2ff; }

body { font-family:'Segoe UI','Inter',sans-serif; }

/* ── Header ── */
.cl-hdr-icon { width:38px;height:38px;border-radius:12px;background:var(--pri-lt);color:var(--pri);display:inline-flex;align-items:center;justify-content:center;font-size:16px; }
.cl-dot { width:4px;height:4px;background:#cbd5e1;border-radius:50%;display:inline-block; }

/* ── Stat cards ── */
.cl-stat { background:#fff;border-radius:14px;padding:16px;display:flex;align-items:center;gap:12px;box-shadow:0 2px 8px rgba(0,0,0,.06);border:1px solid #f1f5f9;transition:transform .2s,box-shadow .2s; }
.cl-stat:hover { transform:translateY(-3px);box-shadow:0 8px 24px rgba(0,0,0,.1); }
.cl-stat-ico { width:44px;height:44px;border-radius:12px;display:flex;align-items:center;justify-content:center;font-size:18px;flex-shrink:0; }
.cl-stat-val { font-size:26px;font-weight:900;line-height:1;color:#1e293b; }
.cl-stat-lbl { font-size:11px;font-weight:700;color:#94a3b8;text-transform:uppercase;letter-spacing:.5px;margin-top:2px; }

/* ── Filter bar ── */
.cl-filter-bar { background:#fff;border-radius:12px;padding:14px 20px;box-shadow:0 1px 6px rgba(0,0,0,.06);border:1px solid #f1f5f9; }
.cl-srch-wrap { position:relative; }
.cl-srch-ico  { position:absolute;top:50%;left:12px;transform:translateY(-50%);color:#94a3b8;font-size:13px;z-index:1; }
.cl-srch-inp  { padding-left:36px;border-radius:10px;height:38px;font-size:13px;border:1.5px solid #e2e8f0; }
.cl-srch-inp:focus { border-color:var(--pri);box-shadow:0 0 0 3px rgba(79,70,229,.15);outline:none; }

/* ── Stream card ── */
.cl-stream-card { background:#fff;border-radius:14px;overflow:hidden;box-shadow:0 2px 10px rgba(0,0,0,.07);border:1px solid #f1f5f9;transition:box-shadow .2s; }
.cl-stream-card:hover { box-shadow:0 8px 28px rgba(0,0,0,.11); }
.cl-stream-hdr { padding:14px 18px;background:linear-gradient(135deg,#4f46e5,#6366f1);color:#fff;cursor:pointer;display:flex;justify-content:space-between;align-items:center;user-select:none; }
.cl-stream-hdr:hover { background:linear-gradient(135deg,#4338ca,#4f46e5); }
.cl-stream-title { font-size:14px;font-weight:800;display:flex;align-items:center;gap:8px; }
.cl-stream-ico { width:28px;height:28px;background:rgba(255,255,255,.2);border-radius:8px;display:inline-flex;align-items:center;justify-content:center;font-size:12px; }
.cl-stream-badge { background:rgba(255,255,255,.25);color:#fff;padding:3px 10px;border-radius:20px;font-size:11px;font-weight:700;display:flex;align-items:center;gap:4px; }
.cl-chevron { transition:transform .25s; }
.cl-stream-hdr.collapsed .cl-chevron { transform:rotate(-90deg); }

/* ── Course table ── */
.cl-course-tbl { font-size:13px; }
.cl-course-tbl thead th { background:#f8fafc;color:#64748b;font-size:11px;font-weight:700;text-transform:uppercase;letter-spacing:.4px;padding:10px 16px;border-bottom:2px solid #e2e8f0; }
.cl-course-tbl tbody td { padding:11px 16px;border-bottom:1px solid #f1f5f9;vertical-align:middle; }
.cl-course-tbl tbody tr:last-child td { border-bottom:none; }
.cl-course-tbl tbody tr:hover { background:#f8f8ff; }
.course-name-cell { display:flex;align-items:center;gap:8px; }
.course-dot { width:8px;height:8px;border-radius:50%;background:var(--pri);flex-shrink:0; }
.course-name { font-weight:700;color:#1e293b;font-size:13px; }
.course-code-badge { background:#eef2ff;color:#4f46e5;font-size:10px;font-weight:700;padding:2px 8px;border-radius:6px;font-family:monospace; }
.course-status { padding:3px 10px;border-radius:20px;font-size:11px;font-weight:700; }
.status-active   { background:#dcfce7;color:#16a34a; }
.status-inactive { background:#f1f5f9;color:#64748b; }

/* ── Empty state ── */
.cl-empty { text-align:center;padding:48px 24px;color:#94a3b8; }
.cl-empty i { font-size:36px;display:block;margin-bottom:12px;opacity:.3; }

/* ── Pagination ── */
.cl-pager-wrap { display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:8px;margin-top:20px; }
.cl-pager-info { font-size:13px;color:#64748b;font-weight:500; }
.cl-pager { display:flex;align-items:center;gap:4px;flex-wrap:wrap; }
.cl-pg-btn {
    display:inline-flex;align-items:center;justify-content:center;
    min-width:34px;height:34px;padding:0 8px;
    border-radius:9px;border:1.5px solid #e2e8f0;
    background:#fff;font-size:13px;color:#475569;
    cursor:pointer;transition:.15s;font-weight:500;
    user-select:none;
}
.cl-pg-btn:hover  { background:var(--pri);color:#fff;border-color:var(--pri); }
.cl-pg-btn.active { background:var(--pri);color:#fff;border-color:var(--pri);font-weight:700; }
.cl-pg-btn.disabled { opacity:.35;pointer-events:none;cursor:default; }

/* ── No results ── */
.cl-no-results { background:#fff;border-radius:14px;padding:48px 24px;text-align:center;box-shadow:0 2px 8px rgba(0,0,0,.06); }

/* Responsive */
@media (max-width:767px) {
    .cl-stat-val { font-size:20px; }
    .cl-pg-btn { min-width:30px;height:30px;font-size:12px; }
    .cl-pager-wrap { justify-content:center; }
}
</style>
</asp:Content>

<asp:Content ID="cBody" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

<%-- Hidden fields --%>
<asp:HiddenField ID="hfCardsPerPage" runat="server" Value="5" />
<%-- Server search value (carries search text across postbacks) --%>
<input type="hidden" id="txtSearch" runat="server" />

<%-- ══ HEADER ══════════════════════════════════════════════ --%>
<div class="d-flex flex-wrap justify-content-between align-items-center mb-4 gap-3">
    <div>
        <h4 class="fw-bold mb-1 d-flex align-items-center gap-2">
            <span class="cl-hdr-icon"><i class="fa fa-book"></i></span>
            Courses
        </h4>
        <div class="text-muted small d-flex align-items-center gap-2 flex-wrap">
            <span>Manage courses grouped by stream</span>
            <span class="cl-dot"></span>
            <i class="fa fa-clock me-1"></i>Updated:
            <%= DateTime.Now.ToString("dd MMM yyyy, hh:mm tt") %>
        </div>
    </div>
    <div class="d-flex gap-2">
        <div class="dropdown">
            <button class="btn btn-outline-primary rounded-pill px-4 fw-semibold dropdown-toggle"
                    data-bs-toggle="dropdown">
                <i class="fa fa-filter me-1"></i>Filter
            </button>
            <ul class="dropdown-menu shadow-sm border-0 rounded-3">
                <li>
                    <asp:LinkButton runat="server" CssClass="dropdown-item"
                        OnClick="FilterStatus_Click" CommandArgument="All">
                        <i class="fa fa-list me-2 text-muted"></i>All Courses
                    </asp:LinkButton>
                </li>
                <li>
                    <asp:LinkButton runat="server" CssClass="dropdown-item"
                        OnClick="FilterStatus_Click" CommandArgument="1">
                        <i class="fa fa-check-circle me-2 text-success"></i>Active Only
                    </asp:LinkButton>
                </li>
                <li>
                    <asp:LinkButton runat="server" CssClass="dropdown-item"
                        OnClick="FilterStatus_Click" CommandArgument="0">
                        <i class="fa fa-times-circle me-2 text-secondary"></i>Inactive Only
                    </asp:LinkButton>
                </li>
            </ul>
        </div>
    </div>
</div>

<%-- ══ STATS ══════════════════════════════════════════════ --%>
<div class="row g-3 mb-4">
    <div class="col-12 col-sm-4">
        <div class="cl-stat">
            <div class="cl-stat-ico" style="background:#eef2ff;color:#4f46e5;"><i class="fa fa-book"></i></div>
            <div>
                <div class="cl-stat-val"><asp:Label ID="lblTotal" runat="server" Text="0" /></div>
                <div class="cl-stat-lbl">Total Courses</div>
            </div>
        </div>
    </div>
    <div class="col-12 col-sm-4">
        <div class="cl-stat">
            <div class="cl-stat-ico" style="background:#f0fdf4;color:#16a34a;"><i class="fa fa-check-circle"></i></div>
            <div>
                <div class="cl-stat-val text-success"><asp:Label ID="lblActive" runat="server" Text="0" /></div>
                <div class="cl-stat-lbl">Active</div>
            </div>
        </div>
    </div>
    <div class="col-12 col-sm-4">
        <div class="cl-stat">
            <div class="cl-stat-ico" style="background:#fef2f2;color:#dc2626;"><i class="fa fa-times-circle"></i></div>
            <div>
                <div class="cl-stat-val text-danger"><asp:Label ID="lblInactive" runat="server" Text="0" /></div>
                <div class="cl-stat-lbl">Inactive</div>
            </div>
        </div>
    </div>
</div>

<%-- ══ FILTER BAR ══════════════════════════════════════════ --%>
<div class="cl-filter-bar mb-4">
    <div class="d-flex align-items-center gap-3 flex-wrap">
        <%-- Client-side search (no postback) --%>
        <div class="cl-srch-wrap" style="flex:1;min-width:180px;max-width:340px;">
            <i class="fa fa-search cl-srch-ico"></i>
            <input type="text" id="txtSearchClient"
                   class="form-control cl-srch-inp"
                   placeholder="Search course or code..."
                   oninput="clientSearch(this.value)" />
        </div>
        <span class="text-muted small ms-auto fw-semibold" id="searchInfo"></span>
    </div>
</div>

<%-- ══ STREAM CARDS (rendered server-side, paginated client-side) ═══ --%>
<div id="streamContainer">

    <asp:Repeater ID="rptStreams" runat="server" OnItemDataBound="rptStreams_ItemDataBound">
        <ItemTemplate>
            <div class="cl-stream-card mb-3 cl-card-item">

                <div class="cl-stream-hdr"
                     onclick="toggleCard(this)"
                     data-bs-toggle="collapse"
                     data-bs-target="#stream_<%# Eval("StreamId") %>">
                    <div class="cl-stream-title">
                        <span class="cl-stream-ico"><i class="fa fa-layer-group"></i></span>
                        <%# Eval("StreamName") %>
                    </div>
                    <div class="d-flex align-items-center gap-2">
                        <span class="cl-stream-badge">
                            <i class="fa fa-book"></i>
                            <%# Eval("CourseCount") %> Course<%# Convert.ToInt32(Eval("CourseCount")) == 1 ? "" : "s" %>
                        </span>
                        <i class="fa fa-chevron-down cl-chevron" style="font-size:12px;opacity:.8;"></i>
                    </div>
                </div>

                <div id="stream_<%# Eval("StreamId") %>" class="collapse show">
                    <asp:GridView ID="gvInnerCourses" runat="server"
                        CssClass="table cl-course-tbl mb-0"
                        AutoGenerateColumns="false"
                        GridLines="None"
                        ShowHeaderWhenEmpty="true">
                        <HeaderStyle CssClass="" />
                        <Columns>

                            <asp:TemplateField HeaderText="Course Name">
                                <ItemTemplate>
                                    <div class="course-name-cell">
                                        <div class="course-dot"></div>
                                        <span class="course-name"><%# Eval("CourseName") %></span>
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="Code" ItemStyle-Width="100px">
                                <ItemTemplate>
                                    <span class="course-code-badge"><%# Eval("CourseCode") %></span>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="Status" ItemStyle-Width="90px">
                                <ItemTemplate>
                                    <%# Convert.ToBoolean(Eval("IsActive"))
                                        ? "<span class='course-status status-active'><i class='fa fa-circle' style='font-size:7px;vertical-align:middle;'></i> Active</span>"
                                        : "<span class='course-status status-inactive'><i class='fa fa-circle' style='font-size:7px;vertical-align:middle;'></i> Inactive</span>" %>
                                </ItemTemplate>
                            </asp:TemplateField>

                        </Columns>
                        <EmptyDataTemplate>
                            <div class="cl-empty">
                                <i class="fa fa-book"></i>
                                <p class="mb-0">No courses in this stream.</p>
                            </div>
                        </EmptyDataTemplate>
                    </asp:GridView>
                </div>

            </div>
        </ItemTemplate>
    </asp:Repeater>

</div><%-- /streamContainer --%>

<%-- Empty panel (server-controlled) --%>
<asp:Panel ID="pnlEmpty" runat="server" Visible="false">
    <div class="cl-no-results">
        <i class="fa fa-book fa-3x text-muted mb-3 d-block opacity-25"></i>
        <h5 class="fw-bold text-muted">No Courses Found</h5>
        <p class="text-muted small">Try adjusting the filter or adding courses first.</p>
    </div>
</asp:Panel>

<%-- ══ PAGINATION ═══════════════════════════════════════════
     ★ Pure client-side — zero postback.
     JS slices the .cl-card-item elements into pages and
     rebuilds « ‹ 1 2 › » buttons on every navigation.
--%>
<div class="cl-pager-wrap" id="pagerWrap" style="display:none;">
    <div class="cl-pager-info" id="pagerInfo"></div>
    <div class="cl-pager" id="pager"></div>
</div>

<%-- ══ SCRIPTS ════════════════════════════════════════════ --%>
<script>
(function(){
'use strict';

/* ── Config ────────────────────────────────────────────── */
var hf = document.getElementById('<%= hfCardsPerPage.ClientID %>');
var PAGE_SIZE = hf ? (parseInt(hf.value) || 5) : 5;
var currentPage = 1;
var allCards    = [];   // all .cl-card-item elements
var filteredCards = []; // after client search

/* ── Init ──────────────────────────────────────────────── */
document.addEventListener('DOMContentLoaded', function() {
    allCards      = Array.from(document.querySelectorAll('.cl-card-item'));
    filteredCards = allCards.slice();
    render(1);
});

/* ── Stream header toggle ──────────────────────────────── */
window.toggleCard = function(hdr) {
    hdr.classList.toggle('collapsed');
};

/* ── Client-side search ────────────────────────────────── */
window.clientSearch = function(val) {
    val = (val || '').toLowerCase().trim();

    filteredCards = allCards.filter(function(card) {
        if (!val) return true;
        // Check stream name and all course names/codes in the card
        return card.innerText.toLowerCase().includes(val);
    });

    // Show/hide individual rows within each visible card too
    allCards.forEach(function(card) {
        var rows = card.querySelectorAll('tbody tr');
        var anyVisible = false;

        rows.forEach(function(row) {
            var txt = row.innerText.toLowerCase();
            var show = !val || txt.includes(val);
            row.style.display = show ? '' : 'none';
            if (show) anyVisible = true;
        });

        // If no rows match in this card, exclude from filteredCards
        if (val && !anyVisible) {
            filteredCards = filteredCards.filter(function(c){ return c !== card; });
        }
    });

    // Update search info
    var info = document.getElementById('searchInfo');
    if (info) {
        info.textContent = val
            ? filteredCards.length + ' stream' + (filteredCards.length !== 1 ? 's' : '') + ' match'
            : '';
    }

    render(1);
};

/* ── Render a page ─────────────────────────────────────── */
function render(page) {
    currentPage = page;
    var total = filteredCards.length;
    var totalPages = Math.max(1, Math.ceil(total / PAGE_SIZE));
    if (currentPage > totalPages) currentPage = totalPages;
    if (currentPage < 1)          currentPage = 1;

    var start = (currentPage - 1) * PAGE_SIZE;
    var end   = Math.min(start + PAGE_SIZE, total);

    // Show/hide all cards
    allCards.forEach(function(card) {
        var inFiltered = filteredCards.indexOf(card) !== -1;
        var inPage     = inFiltered && filteredCards.indexOf(card) >= start
                                    && filteredCards.indexOf(card) < end;
        card.style.display = inPage ? '' : 'none';
    });

    // Pager bar
    var wrap = document.getElementById('pagerWrap');
    var info = document.getElementById('pagerInfo');
    var pager = document.getElementById('pager');

    if (total === 0 || totalPages <= 1) {
        if (wrap) wrap.style.display = 'none';
    } else {
        if (wrap) wrap.style.display = 'flex';
        if (info) {
            info.textContent = total === 0
                ? 'No streams found'
                : 'Showing streams ' + (start + 1) + '–' + end + ' of ' + total;
        }
        buildPager(pager, totalPages, currentPage);
    }
}

/* ── Build « ‹ 1 2 › » pager ───────────────────────────── */
function buildPager(wrap, totalPages, cur) {
    if (!wrap) return;
    wrap.innerHTML = '';

    function btn(label, page, disabled, active) {
        var b = document.createElement('button');
        b.type = 'button';
        b.className = 'cl-pg-btn'
            + (active   ? ' active'   : '')
            + (disabled ? ' disabled' : '');
        b.textContent = label;
        b.setAttribute('aria-label', label);
        if (!disabled) {
            b.addEventListener('click', function(e) {
                e.preventDefault();
                render(page);
                // Scroll to top of stream container smoothly
                var sc = document.getElementById('streamContainer');
                if (sc) sc.scrollIntoView({ behavior: 'smooth', block: 'start' });
            });
        }
        wrap.appendChild(b);
    }

    function ellipsis() {
        var sp = document.createElement('span');
        sp.className = 'cl-pg-btn';
        sp.textContent = '…';
        sp.style.cssText = 'cursor:default;pointer-events:none;border:none;';
        wrap.appendChild(sp);
    }

    // « First
    btn('«', 1, cur === 1);
    // ‹ Prev
    btn('‹', cur - 1, cur === 1);

    // Numbered buttons
    var from = Math.max(1, cur - 2);
    var to   = Math.min(totalPages, cur + 2);

    if (from > 1) {
        btn('1', 1, false);
        if (from > 2) ellipsis();
    }
    for (var p = from; p <= to; p++) {
        btn(p.toString(), p, false, p === cur);
    }
    if (to < totalPages) {
        if (to < totalPages - 1) ellipsis();
        btn(totalPages.toString(), totalPages, false);
    }

    // › Next
    btn('›', cur + 1, cur === totalPages);
    // » Last
    btn('»', totalPages, cur === totalPages);
}

})();
</script>

</asp:Content>
