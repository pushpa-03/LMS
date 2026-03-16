<%@ Page Title="Quizzes" Language="C#"
    MasterPageFile="~/Student/StudentMaster.Master"
    AutoEventWireup="true"
    CodeBehind="Quizzes.aspx.cs"
    Inherits="LMS_Project.Student.Quizzes" %>

<asp:Content ID="cHead" ContentPlaceHolderID="head" runat="server">
<style>

.page-header {
    display: flex; align-items: center;
    justify-content: space-between;
    margin-bottom: 22px; flex-wrap: wrap; gap: 12px;
}
.page-header h4 { margin:0; font-weight:800; color:#1565c0; font-size:20px; }

/* ── Summary chips ── */
.summary-strip { display:flex; gap:12px; margin-bottom:22px; flex-wrap:wrap; }
.summary-chip {
    background:#fff; border:1.5px solid #e3e8f0; border-radius:10px;
    padding:10px 20px; display:flex; align-items:center; gap:10px;
    box-shadow:0 1px 4px rgba(0,0,0,.05);
}
.chip-icon { width:36px; height:36px; border-radius:9px;
    display:flex; align-items:center; justify-content:center;
    font-size:15px; flex-shrink:0; }
.chip-label { font-size:11px; font-weight:700; text-transform:uppercase;
    letter-spacing:.5px; color:#90a4ae; }
.chip-value { font-size:22px; font-weight:800; color:#263238; line-height:1; }

/* ── Filter bar ── */
.filter-bar {
    background:#fff; border-radius:12px; padding:14px 18px;
    box-shadow:0 1px 6px rgba(0,0,0,.06);
    display:flex; align-items:center; gap:12px;
    margin-bottom:20px; flex-wrap:wrap;
}
.filter-bar label { font-size:12px; font-weight:700; color:#546e7a; margin:0; }
.filter-bar select {
    border:1.5px solid #e3e8f0; border-radius:8px; padding:6px 12px;
    font-size:13px; color:#263238; background:#f8fbff; outline:none;
}

/* ── Quiz card ── */
.quiz-card {
    background:#fff; border-radius:14px;
    box-shadow:0 2px 10px rgba(0,0,0,.07);
    overflow:hidden; height:100%;
    display:flex; flex-direction:column;
    transition:transform .2s, box-shadow .2s;
    border:1.5px solid #e8f0fe;
}
.quiz-card:hover { transform:translateY(-3px); box-shadow:0 6px 20px rgba(0,0,0,.1); }

/* Top stripe by state */
.stripe-available { background:linear-gradient(90deg,#1565c0,#42a5f5); height:5px; }
.stripe-attempted  { background:linear-gradient(90deg,#2e7d32,#66bb6a); height:5px; }
.stripe-expired    { background:linear-gradient(90deg,#546e7a,#90a4ae); height:5px; }
.stripe-disabled   { background:linear-gradient(90deg,#b0bec5,#cfd8dc); height:5px; }

.quiz-card-body { padding:18px; flex:1; display:flex; flex-direction:column; }

.quiz-state-badge {
    display:inline-flex; align-items:center; gap:5px;
    padding:3px 12px; border-radius:20px;
    font-size:11px; font-weight:700; margin-bottom:10px;
}
.state-available { background:#e3f2fd; color:#1565c0; border:1.5px solid #90caf9; }
.state-attempted  { background:#e8f5e9; color:#2e7d32; border:1.5px solid #a5d6a7; }
.state-expired    { background:#f5f5f5; color:#546e7a; border:1.5px solid #cfd8dc; }
.state-disabled   { background:#fafafa; color:#90a4ae; border:1.5px solid #e0e0e0; }

.quiz-subject { font-size:11px; color:#1976d2; font-weight:700;
    text-transform:uppercase; letter-spacing:.5px; margin-bottom:5px; }
.quiz-title { font-size:15px; font-weight:800; color:#1a237e;
    margin-bottom:8px; line-height:1.3; }
.quiz-desc { font-size:12px; color:#78909c; margin-bottom:14px; flex:1;
    display:-webkit-box; -webkit-line-clamp:2;
    -webkit-box-orient:vertical; overflow:hidden; }

/* Info grid */
.quiz-info-grid {
    display:grid; grid-template-columns:1fr 1fr;
    gap:8px; margin-bottom:14px;
    padding-bottom:14px; border-bottom:1px solid #f0f4f8;
}
.quiz-info-item { display:flex; align-items:center; gap:6px; font-size:12px; color:#546e7a; }
.quiz-info-item i { color:#1976d2; width:14px; font-size:11px; }

/* Score bar (for attempted) */
.score-bar-wrap { margin-bottom:14px; }
.score-bar-label {
    display:flex; justify-content:space-between;
    font-size:12px; font-weight:700; margin-bottom:4px;
}
.score-bar-track {
    height:8px; background:#e8f5e9; border-radius:4px; overflow:hidden;
}
.score-bar-fill { height:100%; border-radius:4px; transition:width .5s; }
.score-pass  { background:linear-gradient(90deg,#2e7d32,#66bb6a); }
.score-fail  { background:linear-gradient(90deg,#c62828,#ef5350); }

/* Action button */
.btn-start-quiz {
    display:block; width:100%; padding:10px;
    background:linear-gradient(135deg,#1565c0,#1976d2);
    color:#fff; border:none; border-radius:9px;
    font-size:13px; font-weight:700;
    text-align:center; text-decoration:none; cursor:pointer;
    transition:opacity .2s;
}
.btn-start-quiz:hover { opacity:.88; color:#fff; }
.btn-start-quiz:disabled,
.btn-start-quiz.disabled {
    background:#e0e0e0; color:#90a4ae; cursor:not-allowed; pointer-events:none;
}
.btn-view-result {
    display:block; width:100%; padding:10px;
    background:#e8f5e9; color:#2e7d32;
    border:1.5px solid #a5d6a7; border-radius:9px;
    font-size:13px; font-weight:700;
    text-align:center; text-decoration:none;
    transition:all .2s;
}
.btn-view-result:hover { background:#2e7d32; color:#fff; }

/* Due urgency */
.due-soon    { color:#e65100; font-weight:700; }
.due-normal  { color:#78909c; }
.due-expired { color:#c62828; }

/* Empty state */
.empty-state {
    background:#fff; border-radius:14px;
    box-shadow:0 2px 8px rgba(0,0,0,.06);
    padding:60px 30px; text-align:center; color:#90a4ae;
}
.empty-state i { font-size:56px; color:#cfd8dc; display:block; margin-bottom:16px; }
.empty-state h5 { color:#546e7a; font-weight:700; }

/* Instructions modal */
.modal-header-blue {
    background:linear-gradient(135deg,#1565c0,#1976d2);
    color:#fff; border-radius:14px 14px 0 0; padding:16px 20px;
}
.modal-header-blue .btn-close { filter:invert(1); }
.inst-item {
    display:flex; gap:10px; padding:8px 0;
    border-bottom:1px solid #f0f4f8; font-size:13px; color:#546e7a;
}
.inst-item:last-child { border-bottom:none; }
.inst-num {
    width:24px; height:24px; border-radius:50%;
    background:#e3f2fd; color:#1565c0;
    font-size:11px; font-weight:800;
    display:flex; align-items:center; justify-content:center; flex-shrink:0;
}

</style>
</asp:Content>

<asp:Content ID="cBody" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<asp:HiddenField ID="hfQuizId"    runat="server" Value="0" />
<asp:HiddenField ID="hfQuizTitle" runat="server" />

<%-- ══ PAGE HEADER ══ --%>
<div class="page-header">
    <h4><i class="fas fa-clipboard-list me-2"></i>Quizzes</h4>
</div>

<%-- ══ SUMMARY CHIPS ══ --%>
<div class="summary-strip">
    <div class="summary-chip">
        <div class="chip-icon" style="background:#e3f2fd;color:#1976d2;">
            <i class="fas fa-clipboard-list"></i></div>
        <div>
            <div class="chip-label">Total</div>
            <div class="chip-value"><asp:Label ID="lblTotal"     runat="server" Text="0"/></div>
        </div>
    </div>
    <div class="summary-chip">
        <div class="chip-icon" style="background:#e8f5e9;color:#2e7d32;">
            <i class="fas fa-play-circle"></i></div>
        <div>
            <div class="chip-label">Available</div>
            <div class="chip-value"><asp:Label ID="lblAvailable" runat="server" Text="0"/></div>
        </div>
    </div>
    <div class="summary-chip">
        <div class="chip-icon" style="background:#f3e5f5;color:#6a1b9a;">
            <i class="fas fa-check-double"></i></div>
        <div>
            <div class="chip-label">Attempted</div>
            <div class="chip-value"><asp:Label ID="lblAttempted" runat="server" Text="0"/></div>
        </div>
    </div>
    <div class="summary-chip">
        <div class="chip-icon" style="background:#f5f5f5;color:#546e7a;">
            <i class="fas fa-clock"></i></div>
        <div>
            <div class="chip-label">Expired</div>
            <div class="chip-value"><asp:Label ID="lblExpired"   runat="server" Text="0"/></div>
        </div>
    </div>
</div>

<%-- ══ FILTER BAR ══ --%>
<div class="filter-bar">
    <label><i class="fas fa-filter me-1"></i>Filter:</label>
    <label>Subject</label>
    <asp:DropDownList ID="ddlSubjectFilter" runat="server"
        AutoPostBack="true" OnSelectedIndexChanged="ddlFilter_Changed" />
    <label>Status</label>
    <asp:DropDownList ID="ddlStateFilter" runat="server"
        AutoPostBack="true" OnSelectedIndexChanged="ddlFilter_Changed">
        <asp:ListItem Text="All"       Value="All"       />
        <asp:ListItem Text="Available" Value="Available" />
        <asp:ListItem Text="Attempted" Value="Attempted" />
        <asp:ListItem Text="Expired"   Value="Expired"   />
    </asp:DropDownList>
    <asp:LinkButton ID="btnReset" runat="server" OnClick="btnReset_Click"
        CssClass="btn-reset-filter"
        style="padding:6px 16px;background:#f0f4f8;color:#546e7a;border:1.5px solid #e3e8f0;border-radius:8px;font-size:12px;font-weight:600;text-decoration:none;">
        <i class="fas fa-undo me-1"></i>Reset
    </asp:LinkButton>
</div>

<%-- ══ QUIZ CARDS ══ --%>
<asp:Panel ID="pnlQuizzes" runat="server">
    <div class="row g-4">
        <asp:Repeater ID="rptQuizzes" runat="server"
            OnItemCommand="rptQuizzes_ItemCommand">
            <ItemTemplate>
                <div class="col-md-6 col-lg-4">
                    <div class="quiz-card">

                        <div class='stripe-<%# Eval("State")?.ToString().ToLower() %>'></div>

                        <div class="quiz-card-body">

                            <span class='quiz-state-badge state-<%# Eval("State")?.ToString().ToLower() %>'>
                                <%# GetStateIcon(Eval("State")?.ToString()) %>
                                <%# Eval("State") %>
                            </span>

                            <div class="quiz-subject">
                                <i class="fas fa-book me-1"></i>
                                <%# Eval("SubjectCode") %> — <%# Eval("SubjectName") %>
                            </div>
                            <div class="quiz-title"><%# Eval("Title") %></div>
                            <div class="quiz-desc">
                                <%# string.IsNullOrEmpty(Eval("Description")?.ToString())
                                    ? "Test your knowledge on this topic."
                                    : Eval("Description") %>
                            </div>

                            <%-- Info grid --%>
                            <div class="quiz-info-grid">
                                <div class="quiz-info-item">
                                    <i class="fas fa-question-circle"></i>
                                    <%# Eval("QuestionCount") %> Questions
                                </div>
                                <div class="quiz-info-item">
                                    <i class="fas fa-stopwatch"></i>
                                    <%# Eval("Duration") %> mins
                                </div>
                                <div class="quiz-info-item">
                                    <i class="fas fa-star"></i>
                                    <%# Eval("TotalMarks") %> marks
                                </div>
                                <div class="quiz-info-item">
                                    <i class="fas fa-check-circle"></i>
                                    Pass: <%# Eval("PassMarks") %>
                                </div>
                            </div>

                            <%-- Score bar (attempted only) --%>
                            <%# Eval("State")?.ToString() == "Attempted"
                                ? RenderScoreBar(
                                    Convert.ToInt32(Eval("Score")),
                                    Convert.ToInt32(Eval("TotalMarks")),
                                    Convert.ToInt32(Eval("PassMarks")))
                                : "" %>

                            <%-- Due date --%>
                            <div class="quiz-info-item mb-3">
                                <i class="fas fa-calendar-alt"></i>
                                <%# GetDueLabel(
                                    Convert.ToDateTime(Eval("DueDate")),
                                    Eval("State")?.ToString()) %>
                            </div>

                            <%-- Action button --%>
                            <%# Eval("State")?.ToString() == "Attempted"
                                ? "" : "" %>

                            <asp:LinkButton runat="server"
                                CommandName="StartQuiz"
                                CommandArgument='<%# Eval("QuizId") + "|" + Eval("Title") %>'
                                CssClass='btn-start-quiz<%# Eval("State")?.ToString() != "Available" ? " disabled" : "" %>'>
                                <i class="fas fa-play me-1"></i>
                                <%# Eval("State")?.ToString() == "Attempted" ? "Already Attempted"
                                    : Eval("State")?.ToString() == "Expired"  ? "Quiz Expired"
                                    : Eval("State")?.ToString() == "Disabled" ? "Not Available"
                                    : "Start Quiz" %>
                            </asp:LinkButton>

                            <%# Eval("State")?.ToString() == "Attempted"
                                ? $"<a href='Results.aspx' class='btn-view-result mt-2'><i class='fas fa-chart-bar me-1'></i>View Result</a>"
                                : "" %>

                        </div>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>
</asp:Panel>

<%-- ══ EMPTY STATE ══ --%>
<asp:Panel ID="pnlEmpty" runat="server" Visible="false">
    <div class="empty-state">
        <i class="fas fa-clipboard-list"></i>
        <h5>No Quizzes Found</h5>
        <p>No quizzes have been assigned yet.</p>
    </div>
</asp:Panel>

<%-- ══ INSTRUCTIONS MODAL ══ --%>
<div class="modal fade" id="instructionsModal" tabindex="-1">
    <div class="modal-dialog modal-md">
        <div class="modal-content border-0" style="border-radius:14px;overflow:hidden;">

            <div class="modal-header-blue d-flex align-items-center justify-content-between">
                <h5 class="mb-0 fw-bold">
                    <i class="fas fa-info-circle me-2"></i>Quiz Instructions
                </h5>
                <button type="button" class="btn-close btn-close-white"
                    data-bs-dismiss="modal"></button>
            </div>

            <div class="modal-body p-4">
                <p class="fw-bold text-primary mb-3" id="modalQuizTitle"></p>

                <div class="inst-item">
                    <div class="inst-num">1</div>
                    Once started, the timer cannot be paused.
                </div>
                <div class="inst-item">
                    <div class="inst-num">2</div>
                    The quiz auto-submits when the timer reaches zero.
                </div>
                <div class="inst-item">
                    <div class="inst-num">3</div>
                    You can navigate between questions freely.
                </div>
                <div class="inst-item">
                    <div class="inst-num">4</div>
                    Each question has only one correct answer.
                </div>
                <div class="inst-item">
                    <div class="inst-num">5</div>
                    There is no negative marking.
                </div>
                <div class="inst-item">
                    <div class="inst-num">6</div>
                    Do not refresh or close the browser during the quiz.
                </div>
                <div class="inst-item">
                    <div class="inst-num">7</div>
                    You can only attempt this quiz once.
                </div>

                <div class="alert alert-warning mt-3 mb-0" style="font-size:13px; border-radius:10px;">
                    <i class="fas fa-exclamation-triangle me-1"></i>
                    <strong>Are you sure you want to start?</strong>
                    This action cannot be undone.
                </div>
            </div>

            <div class="modal-footer border-0 pt-0 pb-3 px-4">
                <button type="button" class="btn btn-light border"
                    data-bs-dismiss="modal" style="border-radius:8px;">
                    Cancel
                </button>
                <a id="btnProceedQuiz" href="#"
                   class="btn-start-quiz ms-2"
                   style="display:inline-block;width:auto;padding:8px 24px;text-decoration:none;">
                    <i class="fas fa-play me-1"></i>Start Now
                </a>
            </div>

        </div>
    </div>
</div>

<script>
function showInstructions(quizId, title) {
    document.getElementById('modalQuizTitle').innerText = title;
    document.getElementById('btnProceedQuiz').href =
        'QuizAttempt.aspx?QuizId=' + quizId;
    new bootstrap.Modal(document.getElementById('instructionsModal')).show();
}
</script>

</asp:Content>
