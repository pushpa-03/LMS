<%@ Page Title="Results" Language="C#"
    MasterPageFile="~/Student/StudentMaster.Master"
    AutoEventWireup="true"
    CodeBehind="Results.aspx.cs"
    Inherits="LMS_Project.Student.Results" %>

<asp:Content ID="cHead" ContentPlaceHolderID="head" runat="server">
<style>

.page-header {
    display:flex; align-items:center; justify-content:space-between;
    margin-bottom:22px; flex-wrap:wrap; gap:12px;
}
.page-header h4 { margin:0; font-weight:800; color:#1565c0; font-size:20px; }

/* ── Summary cards ── */
.summary-row { display:flex; gap:14px; margin-bottom:24px; flex-wrap:wrap; }
.summary-card {
    background:#fff; border-radius:14px;
    box-shadow:0 2px 8px rgba(0,0,0,.06);
    padding:16px 20px; flex:1; min-width:140px;
    display:flex; align-items:center; gap:14px;
    border-left:4px solid transparent;
}
.summary-card.blue   { border-left-color:#1565c0; }
.summary-card.green  { border-left-color:#2e7d32; }
.summary-card.purple { border-left-color:#6a1b9a; }
.summary-card.orange { border-left-color:#e65100; }

.sc-icon {
    width:44px; height:44px; border-radius:12px;
    display:flex; align-items:center; justify-content:center;
    font-size:18px; flex-shrink:0;
}
.sc-icon.blue   { background:#e3f2fd; color:#1565c0; }
.sc-icon.green  { background:#e8f5e9; color:#2e7d32; }
.sc-icon.purple { background:#f3e5f5; color:#6a1b9a; }
.sc-icon.orange { background:#fff3e0; color:#e65100; }

.sc-val  { font-size:24px; font-weight:900; color:#263238; line-height:1; }
.sc-lbl  { font-size:11px; font-weight:700; color:#90a4ae;
           text-transform:uppercase; letter-spacing:.4px; margin-top:2px; }

/* ── Tabs ── */
.results-tabs {
    display:flex; gap:0; margin-bottom:20px;
    border-bottom:2px solid #e3e8f0;
}
.tab-btn {
    padding:10px 26px; font-size:13px; font-weight:700;
    color:#78909c; background:none; border:none;
    cursor:pointer; border-bottom:3px solid transparent;
    margin-bottom:-2px; transition:all .2s;
    display:flex; align-items:center; gap:7px;
}
.tab-btn:hover  { color:#1565c0; }
.tab-btn.active { color:#1565c0; border-bottom-color:#1565c0; }
.tab-badge {
    background:#e3f2fd; color:#1565c0;
    padding:1px 8px; border-radius:10px;
    font-size:11px; font-weight:800;
}

/* ── Filter bar ── */
.filter-bar {
    background:#fff; border-radius:12px; padding:12px 16px;
    box-shadow:0 1px 5px rgba(0,0,0,.05);
    display:flex; align-items:center; gap:12px;
    margin-bottom:16px; flex-wrap:wrap;
}
.filter-bar label { font-size:12px; font-weight:700; color:#546e7a; margin:0; }
.filter-bar select {
    border:1.5px solid #e3e8f0; border-radius:8px; padding:5px 12px;
    font-size:13px; color:#263238; background:#f8fbff; outline:none;
}

/* ── Result row card ── */
.result-card {
    background:#fff; border-radius:12px;
    box-shadow:0 1px 6px rgba(0,0,0,.06);
    padding:16px 20px; margin-bottom:12px;
    display:flex; align-items:center; gap:16px;
    transition:transform .15s, box-shadow .15s;
}
.result-card:hover { transform:translateY(-1px); box-shadow:0 4px 14px rgba(0,0,0,.09); }

.rc-icon {
    width:46px; height:46px; border-radius:12px;
    display:flex; align-items:center; justify-content:center;
    font-size:19px; flex-shrink:0;
}
.rc-body { flex:1; min-width:0; }
.rc-title {
    font-size:14px; font-weight:800; color:#1a237e; margin-bottom:4px;
    white-space:nowrap; overflow:hidden; text-overflow:ellipsis;
}
.rc-subject {
    font-size:11px; color:#1976d2; font-weight:700; margin-bottom:6px;
}
.rc-meta { display:flex; gap:14px; flex-wrap:wrap; font-size:11px; color:#90a4ae; }
.rc-meta span { display:flex; align-items:center; gap:4px; }

.rc-right { display:flex; flex-direction:column; align-items:flex-end; gap:6px; }

/* Score ring */
.score-ring {
    width:54px; height:54px; border-radius:50%;
    display:flex; flex-direction:column;
    align-items:center; justify-content:center;
    border:3px solid; flex-shrink:0;
}
.score-ring .sr-val { font-size:14px; font-weight:900; line-height:1; }
.score-ring .sr-of  { font-size:9px; opacity:.7; }
.ring-high   { border-color:#2e7d32; background:#e8f5e9; color:#2e7d32; }
.ring-mid    { border-color:#f57f17; background:#fff8e1; color:#f57f17; }
.ring-low    { border-color:#c62828; background:#ffebee; color:#c62828; }
.ring-pending{ border-color:#90a4ae; background:#f5f5f5; color:#90a4ae; }

/* Grade badge */
.grade-badge {
    padding:3px 12px; border-radius:20px;
    font-size:11px; font-weight:700;
}
.grade-A  { background:#e8f5e9; color:#2e7d32; border:1.5px solid #a5d6a7; }
.grade-B  { background:#e3f2fd; color:#1565c0; border:1.5px solid #90caf9; }
.grade-C  { background:#fff8e1; color:#f57f17; border:1.5px solid #ffe082; }
.grade-F  { background:#ffebee; color:#c62828; border:1.5px solid #ef9a9a; }
.grade-P  { background:#f5f5f5; color:#90a4ae; border:1.5px solid #e0e0e0; }

/* Progress bar */
.mini-bar { width:100px; }
.mini-bar-track { height:5px; background:#e8f0fe; border-radius:3px; }
.mini-bar-fill  { height:100%; border-radius:3px; }

/* Empty state */
.empty-state {
    background:#fff; border-radius:14px;
    box-shadow:0 2px 8px rgba(0,0,0,.06);
    padding:50px 30px; text-align:center; color:#90a4ae;
}
.empty-state i { font-size:48px; color:#cfd8dc; display:block; margin-bottom:14px; }
.empty-state h6 { color:#546e7a; font-weight:700; margin:0; }

/* Quiz breakdown chips */
.breakdown-chips { display:flex; gap:8px; flex-wrap:wrap; }
.bc { padding:2px 10px; border-radius:8px; font-size:11px; font-weight:700; }
.bc-correct  { background:#e8f5e9; color:#2e7d32; }
.bc-wrong    { background:#ffebee; color:#c62828; }
.bc-skipped  { background:#f5f5f5; color:#78909c; }
.bc-auto     { background:#fff3e0; color:#e65100; }

</style>
</asp:Content>

<asp:Content ID="cBody" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<%-- ══ PAGE HEADER ══ --%>
<div class="page-header">
    <h4><i class="fas fa-chart-bar me-2"></i>Results</h4>
</div>

<%-- ══ SUMMARY CARDS ══ --%>
<div class="summary-row">
    <div class="summary-card blue">
        <div class="sc-icon blue"><i class="fas fa-file-alt"></i></div>
        <div>
            <div class="sc-val"><asp:Label ID="lblTotalSubmissions" runat="server" Text="0"/></div>
            <div class="sc-lbl">Assignments Submitted</div>
        </div>
    </div>
    <div class="summary-card green">
        <div class="sc-icon green"><i class="fas fa-check-circle"></i></div>
        <div>
            <div class="sc-val"><asp:Label ID="lblGraded" runat="server" Text="0"/></div>
            <div class="sc-lbl">Assignments Graded</div>
        </div>
    </div>
    <div class="summary-card purple">
        <div class="sc-icon purple"><i class="fas fa-clipboard-list"></i></div>
        <div>
            <div class="sc-val"><asp:Label ID="lblTotalQuizzes" runat="server" Text="0"/></div>
            <div class="sc-lbl">Quizzes Attempted</div>
        </div>
    </div>
    <div class="summary-card orange">
        <div class="sc-icon orange"><i class="fas fa-trophy"></i></div>
        <div>
            <div class="sc-val"><asp:Label ID="lblQuizPassed" runat="server" Text="0"/></div>
            <div class="sc-lbl">Quizzes Passed</div>
        </div>
    </div>
</div>

<%-- ══ TABS ══ --%>
<div class="results-tabs">
    <button class="tab-btn active" id="tabAsg" onclick="switchTab('assignments')">
        <i class="fas fa-file-alt"></i>
        Assignments
        <span class="tab-badge"><asp:Label ID="lblAsgTabCount" runat="server" Text="0"/></span>
    </button>
    <button class="tab-btn" id="tabQuiz" onclick="switchTab('quizzes')">
        <i class="fas fa-clipboard-list"></i>
        Quizzes
        <span class="tab-badge"><asp:Label ID="lblQuizTabCount" runat="server" Text="0"/></span>
    </button>
</div>

<%-- ══ ASSIGNMENT TAB ══ --%>
<div id="panelAssignments">

    <div class="filter-bar">
        <label><i class="fas fa-filter me-1"></i>Subject</label>
        <asp:DropDownList ID="ddlAsgSubject" runat="server"
            AutoPostBack="true" OnSelectedIndexChanged="ddlAsgSubject_Changed" />
        <asp:LinkButton ID="btnAsgReset" runat="server" OnClick="btnAsgReset_Click"
            style="padding:5px 14px;background:#f0f4f8;color:#546e7a;
                   border:1.5px solid #e3e8f0;border-radius:8px;
                   font-size:12px;font-weight:600;text-decoration:none;">
            <i class="fas fa-undo me-1"></i>Reset
        </asp:LinkButton>
    </div>

    <asp:Panel ID="pnlAsgResults" runat="server">
        <asp:Repeater ID="rptAsgResults" runat="server">
            <ItemTemplate>

                <div class='result-card'>

                    <%-- Icon --%>
                    <div class='rc-icon'
                         style='<%# Eval("GradeStatus")?.ToString()=="Graded"
                            ? "background:#e3f2fd;color:#1565c0;"
                            : "background:#f5f5f5;color:#90a4ae;" %>'>
                        <i class='fas <%# Eval("GradeStatus")?.ToString()=="Graded"
                            ? "fa-file-check" : "fa-hourglass-half" %>'></i>
                    </div>

                    <%-- Body --%>
                    <div class="rc-body">
                        <div class="rc-title"><%# Eval("Title") %></div>
                        <div class="rc-subject">
                            <i class="fas fa-book me-1"></i>
                            <%# Eval("SubjectCode") %> — <%# Eval("SubjectName") %>
                        </div>
                        <div class="rc-meta">
                            <span><i class="fas fa-calendar"></i>
                                Due: <%# Eval("DueDate", "{0:dd MMM yyyy}") %></span>
                            <span><i class="fas fa-upload"></i>
                                Submitted: <%# Eval("SubmittedOn", "{0:dd MMM yyyy}") %></span>
                            <span><i class="fas fa-star"></i>
                                Max: <%# Eval("MaxMarks") %> marks</span>
                        </div>
                        <%# Eval("Remarks") != DBNull.Value && !string.IsNullOrEmpty(Eval("Remarks")?.ToString())
                            ? $"<div class='mt-1' style='font-size:11px;color:#546e7a;'><i class='fas fa-comment me-1'></i>{Eval("Remarks")}</div>"
                            : "" %>
                    </div>

                    <%-- Right --%>
                    <div class="rc-right">
                        <%# GetScoreRing(Eval("MarksObtained"), Eval("MaxMarks"), Eval("GradeStatus")?.ToString()) %>
                        <%# GetGradeBadge(Eval("Percentage"), Eval("GradeStatus")?.ToString()) %>
                        <%# Eval("Percentage") != DBNull.Value
                            ? GetMiniBar(Convert.ToInt32(Eval("Percentage")))
                            : "" %>
                    </div>

                </div>

            </ItemTemplate>
        </asp:Repeater>
    </asp:Panel>

    <asp:Panel ID="pnlAsgEmpty" runat="server" Visible="false">
        <div class="empty-state">
            <i class="fas fa-file-alt"></i>
            <h6>No assignment results yet</h6>
        </div>
    </asp:Panel>

</div>

<%-- ══ QUIZ TAB ══ --%>
<div id="panelQuizzes" style="display:none;">

    <div class="filter-bar">
        <label><i class="fas fa-filter me-1"></i>Subject</label>
        <asp:DropDownList ID="ddlQuizSubject" runat="server"
            AutoPostBack="true" OnSelectedIndexChanged="ddlQuizSubject_Changed" />
        <asp:LinkButton ID="btnQuizReset" runat="server" OnClick="btnQuizReset_Click"
            style="padding:5px 14px;background:#f0f4f8;color:#546e7a;
                   border:1.5px solid #e3e8f0;border-radius:8px;
                   font-size:12px;font-weight:600;text-decoration:none;">
            <i class="fas fa-undo me-1"></i>Reset
        </asp:LinkButton>
    </div>

    <asp:Panel ID="pnlQuizResults" runat="server">
        <asp:Repeater ID="rptQuizResults" runat="server">
            <ItemTemplate>

                <div class='result-card'>

                    <%-- Icon --%>
                    <div class='rc-icon'
                         style='<%# Eval("QuizStatus")?.ToString()=="Passed"
                            ? "background:#e8f5e9;color:#2e7d32;"
                            : "background:#ffebee;color:#c62828;" %>'>
                        <i class='fas <%# Eval("QuizStatus")?.ToString()=="Passed"
                            ? "fa-check-circle" : "fa-times-circle" %>'></i>
                    </div>

                    <%-- Body --%>
                    <div class="rc-body">
                        <div class="rc-title"><%# Eval("Title") %></div>
                        <div class="rc-subject">
                            <i class="fas fa-book me-1"></i>
                            <%# Eval("SubjectCode") %> — <%# Eval("SubjectName") %>
                        </div>
                        <div class="rc-meta">
                            <span><i class="fas fa-calendar"></i>
                                <%# Eval("SubmittedOn", "{0:dd MMM yyyy}") %></span>
                            <span><i class="fas fa-stopwatch"></i>
                                <%# FormatTime(Convert.ToInt32(Eval("TimeTaken"))) %></span>
                            <span><i class="fas fa-star"></i>
                                Pass mark: <%# Eval("PassMarks") %></span>
                        </div>
                        <div class="breakdown-chips mt-2">
                            <span class="bc bc-correct">
                                <i class="fas fa-check me-1"></i><%# Eval("Correct") %> Correct
                            </span>
                            <span class="bc bc-wrong">
                                <i class="fas fa-times me-1"></i><%# Eval("Wrong") %> Wrong
                            </span>
                            <span class="bc bc-skipped">
                                <%# Eval("Skipped") %> Skipped
                            </span>
                            <%# Convert.ToBoolean(Eval("IsAutoSubmit"))
                                ? "<span class='bc bc-auto'><i class='fas fa-clock me-1'></i>Auto-submitted</span>"
                                : "" %>
                        </div>
                    </div>

                    <%-- Right --%>
                    <div class="rc-right">
                        <%# GetScoreRing(Eval("Score"), Eval("TotalMarks"), Eval("QuizStatus")?.ToString()) %>
                        <%# GetQuizGradeBadge(Eval("QuizStatus")?.ToString()) %>
                        <%# GetMiniBar(Convert.ToInt32(Eval("Percentage"))) %>
                    </div>

                </div>

            </ItemTemplate>
        </asp:Repeater>
    </asp:Panel>

    <asp:Panel ID="pnlQuizEmpty" runat="server" Visible="false">
        <div class="empty-state">
            <i class="fas fa-clipboard-list"></i>
            <h6>No quiz results yet</h6>
        </div>
    </asp:Panel>

</div>

<%-- Keep track of active tab across postbacks --%>
<asp:HiddenField ID="hfActiveTab" runat="server" Value="assignments" />

<script>
function switchTab(tab) {
    document.getElementById('panelAssignments').style.display =
        tab === 'assignments' ? 'block' : 'none';
    document.getElementById('panelQuizzes').style.display =
        tab === 'quizzes' ? 'block' : 'none';

    document.getElementById('tabAsg').className =
        'tab-btn' + (tab === 'assignments' ? ' active' : '');
    document.getElementById('tabQuiz').className =
        'tab-btn' + (tab === 'quizzes' ? ' active' : '');

    document.getElementById('<%= hfActiveTab.ClientID %>').value = tab;
}

// Restore active tab on postback
window.addEventListener('DOMContentLoaded', function () {
    var tab = document.getElementById('<%= hfActiveTab.ClientID %>').value;
    if (tab) switchTab(tab);
});
</script>

</asp:Content>
