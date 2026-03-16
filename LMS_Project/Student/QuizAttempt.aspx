<%@ Page Title="Quiz Attempt" Language="C#"
    MasterPageFile="~/Student/StudentMaster.Master"
    AutoEventWireup="true"
    CodeBehind="QuizAttempt.aspx.cs"
    Inherits="LMS_Project.Student.QuizAttempt" %>

<asp:Content ID="cHead" ContentPlaceHolderID="head" runat="server">
<style>

/* ── Quiz attempt layout ── */
.quiz-attempt-wrapper {
    display: flex; gap: 20px; align-items: flex-start;
}

/* LEFT — question area */
.question-area {
    flex: 1; min-width: 0;
}

/* RIGHT — sidebar: timer + nav grid */
.quiz-sidebar {
    width: 260px; flex-shrink: 0;
    position: sticky; top: 20px;
}

/* ── Top info bar ── */
.quiz-top-bar {
    background: linear-gradient(135deg, #1565c0, #1976d2);
    border-radius: 14px; padding: 16px 22px;
    color: #fff; margin-bottom: 20px;
    display: flex; align-items: center;
    justify-content: space-between; flex-wrap: wrap; gap: 10px;
}
.quiz-top-bar h5 { margin: 0; font-weight: 800; font-size: 16px; }
.quiz-top-bar .meta { font-size: 12px; opacity: .85; margin-top: 2px; }
.quiz-top-bar .timer-chip {
    background: rgba(255,255,255,.2);
    border-radius: 10px; padding: 8px 18px;
    text-align: center;
}
.quiz-top-bar .timer-chip .timer-val {
    font-size: 24px; font-weight: 900;
    font-family: monospace; letter-spacing: 2px;
}
.quiz-top-bar .timer-chip .timer-lbl {
    font-size: 10px; opacity: .8; text-transform: uppercase;
    letter-spacing: .5px;
}
.timer-danger { background: rgba(198,40,40,.5) !important; animation: pulse 1s infinite; }

@keyframes pulse {
    0%, 100% { opacity: 1; }
    50%       { opacity: .7; }
}

/* ── Question card ── */
.question-card {
    background: #fff; border-radius: 14px;
    box-shadow: 0 2px 10px rgba(0,0,0,.07);
    padding: 24px; margin-bottom: 16px;
}
.question-number {
    font-size: 11px; font-weight: 700; color: #90a4ae;
    text-transform: uppercase; letter-spacing: .5px;
    margin-bottom: 10px;
}
.question-text {
    font-size: 16px; font-weight: 700; color: #1a237e;
    line-height: 1.6; margin-bottom: 20px;
}
.marks-badge {
    display: inline-block; background: #e3f2fd; color: #1565c0;
    padding: 2px 10px; border-radius: 8px; font-size: 11px;
    font-weight: 700; margin-left: 8px; vertical-align: middle;
}

/* Options */
.option-list { display: flex; flex-direction: column; gap: 10px; }

.option-item {
    display: flex; align-items: center; gap: 12px;
    padding: 13px 16px;
    border: 2px solid #e8f0fe; border-radius: 10px;
    cursor: pointer; transition: all .15s;
    background: #fff;
}
.option-item:hover { border-color: #90caf9; background: #f5f9ff; }
.option-item.selected {
    border-color: #1565c0; background: #e3f2fd;
}
.option-letter {
    width: 30px; height: 30px; border-radius: 50%;
    background: #e8f0fe; color: #1565c0;
    font-size: 13px; font-weight: 800;
    display: flex; align-items: center; justify-content: center;
    flex-shrink: 0; transition: all .15s;
}
.option-item.selected .option-letter {
    background: #1565c0; color: #fff;
}
.option-text { font-size: 14px; color: #263238; }

/* ── Navigation buttons ── */
.nav-buttons {
    display: flex; justify-content: space-between;
    align-items: center; gap: 10px;
}
.btn-nav {
    padding: 9px 22px; border-radius: 9px;
    font-size: 13px; font-weight: 700; cursor: pointer;
    border: none; transition: all .15s;
}
.btn-prev { background: #f0f4f8; color: #546e7a; }
.btn-prev:hover { background: #e0e7ef; }
.btn-next {
    background: linear-gradient(135deg, #1565c0, #1976d2);
    color: #fff;
}
.btn-next:hover { opacity: .88; }
.btn-submit-quiz {
    background: linear-gradient(135deg, #2e7d32, #43a047);
    color: #fff; padding: 9px 24px;
    border-radius: 9px; font-size: 13px;
    font-weight: 700; border: none; cursor: pointer;
    transition: opacity .15s;
}
.btn-submit-quiz:hover { opacity: .88; }

/* ── Sidebar timer ── */
.sidebar-card {
    background: #fff; border-radius: 14px;
    box-shadow: 0 2px 10px rgba(0,0,0,.07);
    overflow: hidden; margin-bottom: 14px;
}
.sidebar-card-header {
    background: #1565c0; color: #fff;
    padding: 10px 16px; font-size: 12px;
    font-weight: 700; text-transform: uppercase; letter-spacing: .5px;
    display: flex; align-items: center; gap: 6px;
}

/* Question navigation grid */
.q-nav-grid {
    display: grid;
    grid-template-columns: repeat(5, 1fr);
    gap: 6px; padding: 14px;
}
.q-nav-btn {
    width: 36px; height: 36px; border-radius: 8px;
    font-size: 12px; font-weight: 700; cursor: pointer;
    border: none; transition: all .15s;
    background: #f0f4f8; color: #546e7a;
}
.q-nav-btn:hover    { background: #e3f2fd; color: #1565c0; }
.q-nav-btn.answered { background: #1565c0; color: #fff; }
.q-nav-btn.current  { border: 2px solid #1565c0; background: #e3f2fd; color: #1565c0; }

/* Legend */
.nav-legend { padding: 0 14px 14px; display: flex; gap: 10px; flex-wrap: wrap; }
.legend-item { display: flex; align-items: center; gap: 5px;
    font-size: 11px; color: #546e7a; }
.legend-dot { width: 12px; height: 12px; border-radius: 3px; }

/* Progress bar */
.progress-bar-wrap { padding: 0 14px 14px; }
.prog-label { font-size:11px; color:#90a4ae; margin-bottom:4px;
    display:flex; justify-content:space-between; }
.prog-track { height:6px; background:#e8f0fe; border-radius:3px; }
.prog-fill  { height:100%; background:#1565c0; border-radius:3px; transition:width .3s; }

/* ── Result screen ── */
.result-screen {
    display: none;
    background: #fff; border-radius: 16px;
    box-shadow: 0 4px 20px rgba(0,0,0,.1);
    padding: 40px; text-align: center;
}
.result-circle {
    width: 120px; height: 120px; border-radius: 50%;
    display: flex; flex-direction: column;
    align-items: center; justify-content: center;
    margin: 0 auto 20px;
    font-weight: 900;
}
.result-pass { background: #e8f5e9; border: 4px solid #2e7d32; color: #2e7d32; }
.result-fail { background: #ffebee; border: 4px solid #c62828; color: #c62828; }
.result-circle .r-score { font-size: 30px; line-height: 1; }
.result-circle .r-total { font-size: 13px; opacity: .8; }

.result-stats {
    display: flex; gap: 16px; justify-content: center;
    margin: 20px 0; flex-wrap: wrap;
}
.result-stat {
    background: #f5f9ff; border-radius: 12px;
    padding: 14px 20px; text-align: center; min-width: 80px;
}
.result-stat .rs-val { font-size: 22px; font-weight: 800; color: #1565c0; }
.result-stat .rs-lbl { font-size: 11px; color: #90a4ae; text-transform: uppercase;
    letter-spacing: .4px; }

@media (max-width: 768px) {
    .quiz-attempt-wrapper { flex-direction: column; }
    .quiz-sidebar { width: 100%; position: static; }
}

</style>
</asp:Content>

<asp:Content ID="cBody" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<asp:HiddenField ID="hfQuizId"       runat="server" Value="0" />
<asp:HiddenField ID="hfResultId"     runat="server" Value="0" />
<asp:HiddenField ID="hfDuration"     runat="server" Value="0" />
<asp:HiddenField ID="hfStartTime"    runat="server" />
<asp:HiddenField ID="hfAnswers"      runat="server" Value="{}" />
<asp:HiddenField ID="hfCurrentQ"     runat="server" Value="0" />
<asp:HiddenField ID="hfIsAutoSubmit" runat="server" Value="0" />

<%-- ══ BLOCKED (already attempted / invalid) ══ --%>
<asp:Panel ID="pnlBlocked" runat="server" Visible="false">
    <div style="background:#fff;border-radius:14px;padding:50px 30px;text-align:center;
                box-shadow:0 2px 10px rgba(0,0,0,.07);">
        <i class="fas fa-lock" style="font-size:56px;color:#cfd8dc;display:block;margin-bottom:16px;"></i>
        <h5 style="color:#546e7a;font-weight:700;">
            <asp:Label ID="lblBlockedMsg" runat="server" />
        </h5>
        <a href="Quizzes.aspx" class="btn btn-primary mt-3" style="border-radius:9px;">
            <i class="fas fa-arrow-left me-2"></i>Back to Quizzes
        </a>
    </div>
</asp:Panel>

<%-- ══ QUIZ ATTEMPT AREA ══ --%>
<asp:Panel ID="pnlQuiz" runat="server" Visible="false">

    <%-- Top bar --%>
    <div class="quiz-top-bar">
        <div>
            <h5><asp:Label ID="lblQuizTitle" runat="server" /></h5>
            <div class="meta">
                <asp:Label ID="lblQuizMeta" runat="server" />
            </div>
        </div>
        <div class="timer-chip" id="timerChip">
            <div class="timer-val" id="timerDisplay">00:00</div>
            <div class="timer-lbl">Remaining</div>
        </div>
    </div>

    <div class="quiz-attempt-wrapper">

        <%-- ═══ LEFT — Question ═══ --%>
        <div class="question-area">

            <%-- Question card (rendered server-side, navigated client-side) --%>
            <div class="question-card">
                <div class="question-number" id="qNumber">Question 1</div>
                <div class="question-text"   id="qText"></div>
                <div class="option-list"     id="optionList"></div>
            </div>

            <%-- Nav buttons --%>
            <div class="nav-buttons">
                <button class="btn-nav btn-prev" onclick="navigate(-1)">
                    <i class="fas fa-chevron-left me-1"></i>Previous
                </button>
                <button class="btn-nav btn-next" id="btnNext" onclick="navigate(1)">
                    Next<i class="fas fa-chevron-right ms-1"></i>
                </button>
                <button class="btn-submit-quiz" id="btnSubmitQuiz"
                    style="display:none;"
                    onclick="confirmSubmit()">
                    <i class="fas fa-check me-1"></i>Submit Quiz
                </button>
            </div>

        </div>
        <%-- /LEFT --%>

        <%-- ═══ RIGHT — Sidebar ═══ --%>
        <div class="quiz-sidebar">

            <%-- Progress --%>
            <div class="sidebar-card">
                <div class="sidebar-card-header">
                    <i class="fas fa-tasks"></i> Progress
                </div>
                <div class="progress-bar-wrap" style="padding-top:14px;">
                    <div class="prog-label">
                        <span>Answered</span>
                        <span id="progressLabel">0 / 0</span>
                    </div>
                    <div class="prog-track">
                        <div class="prog-fill" id="progressBar" style="width:0%"></div>
                    </div>
                </div>
            </div>

            <%-- Question nav grid --%>
            <div class="sidebar-card">
                <div class="sidebar-card-header">
                    <i class="fas fa-th"></i> Questions
                </div>
                <div class="q-nav-grid" id="qNavGrid"></div>
                <div class="nav-legend">
                    <div class="legend-item">
                        <div class="legend-dot" style="background:#1565c0;"></div>Answered
                    </div>
                    <div class="legend-item">
                        <div class="legend-dot" style="background:#f0f4f8;border:1px solid #ccc;"></div>Not answered
                    </div>
                    <div class="legend-item">
                        <div class="legend-dot" style="border:2px solid #1565c0;"></div>Current
                    </div>
                </div>
            </div>

        </div>
        <%-- /RIGHT --%>

    </div>

    <%-- Hidden data store (questions JSON rendered server-side) --%>
    <script id="questionsData" type="application/json">
        <asp:Literal ID="litQuestionsJson" runat="server" />
    </script>

    <%-- Submit form (hidden, POSTed on submit) --%>
    <asp:Button ID="btnDoSubmit" runat="server"
        Text="Submit" style="display:none;"
        OnClick="btnDoSubmit_Click" />

</asp:Panel>

<%-- ══ RESULT SCREEN ══ --%>
<asp:Panel ID="pnlResult" runat="server" Visible="false">
    <div style="max-width:600px;margin:0 auto;">
        <div class="result-screen" id="resultScreen" style="display:block;">

            <asp:Label ID="lblResultIcon" runat="server" />

            <h4 style="font-weight:800;color:#263238;margin-bottom:4px;">
                <asp:Label ID="lblResultTitle" runat="server" />
            </h4>
            <p style="color:#90a4ae;font-size:13px;">
                <asp:Label ID="lblResultSubtitle" runat="server" />
            </p>

            <div class="result-stats">
                <div class="result-stat">
                    <div class="rs-val" style="color:#2e7d32;">
                        <asp:Label ID="lblCorrect" runat="server" /></div>
                    <div class="rs-lbl">Correct</div>
                </div>
                <div class="result-stat">
                    <div class="rs-val" style="color:#c62828;">
                        <asp:Label ID="lblWrong" runat="server" /></div>
                    <div class="rs-lbl">Wrong</div>
                </div>
                <div class="result-stat">
                    <div class="rs-val" style="color:#90a4ae;">
                        <asp:Label ID="lblSkipped" runat="server" /></div>
                    <div class="rs-lbl">Skipped</div>
                </div>
                <div class="result-stat">
                    <div class="rs-val">
                        <asp:Label ID="lblTimeTaken" runat="server" /></div>
                    <div class="rs-lbl">Time Taken</div>
                </div>
            </div>

            <div style="display:flex;gap:12px;justify-content:center;margin-top:10px;">
                <a href="Quizzes.aspx" class="btn btn-light border"
                   style="border-radius:9px;">
                    <i class="fas fa-arrow-left me-2"></i>Back to Quizzes
                </a>
                <a href="Results.aspx" class="btn btn-primary"
                   style="border-radius:9px;">
                    <i class="fas fa-chart-bar me-2"></i>View All Results
                </a>
            </div>

        </div>
    </div>
</asp:Panel>

<script>
// ═══════════════════════════════════════════════════════════════
// Quiz Attempt Engine
// ═══════════════════════════════════════════════════════════════

var questions   = [];
var answers     = {};           // { questionId: "A"/"B"/"C"/"D" }
var currentIdx  = 0;
var timerInterval;
var secondsLeft = 0;
var startedAt   = Date.now();

// ── Bootstrap ──────────────────────────────────────────────────
document.addEventListener("DOMContentLoaded", function () {
    var raw = document.getElementById("questionsData");
    if (!raw) return;

    try { questions = JSON.parse(raw.textContent.trim()); }
    catch(e) { questions = []; }

    if (questions.length === 0) return;

    // Duration from hidden field (minutes → seconds)
    var mins = parseInt(
        document.getElementById('<%= hfDuration.ClientID %>').value, 10);
    secondsLeft = mins * 60;

    buildNavGrid();
    showQuestion(0);
    startTimer();
});

// ── Timer ──────────────────────────────────────────────────────
function startTimer() {
    updateTimerDisplay();
    timerInterval = setInterval(function () {
        secondsLeft--;
        updateTimerDisplay();

        if (secondsLeft <= 0) {
            clearInterval(timerInterval);
            autoSubmit();
        }
        // Turn red in last 2 minutes
        if (secondsLeft <= 120) {
            document.getElementById('timerChip')
                    .classList.add('timer-danger');
        }
    }, 1000);
}

function updateTimerDisplay() {
    var m = Math.floor(Math.abs(secondsLeft) / 60);
    var s = Math.abs(secondsLeft) % 60;
    document.getElementById('timerDisplay').innerText =
        String(m).padStart(2,'0') + ':' + String(s).padStart(2,'0');
}

// ── Show question ──────────────────────────────────────────────
function showQuestion(idx) {
    if (idx < 0 || idx >= questions.length) return;
    currentIdx = idx;

    var q = questions[idx];

    document.getElementById('qNumber').innerText =
        'Question ' + (idx + 1) + ' of ' + questions.length;
    document.getElementById('qText').innerHTML =
        q.text + '<span class="marks-badge">' + q.marks + ' mark' +
        (q.marks > 1 ? 's' : '') + '</span>';

    // Options
    var opts  = ['A','B','C','D'];
    var texts = [q.optA, q.optB, q.optC, q.optD];
    var html  = '';
    opts.forEach(function (letter, i) {
        var sel = (answers[q.id] === letter) ? ' selected' : '';
        html +=
            '<div class="option-item' + sel + '" onclick="selectOption(' +
            q.id + ',\'' + letter + '\',this)">' +
            '  <div class="option-letter">' + letter + '</div>' +
            '  <div class="option-text">' + escHtml(texts[i]) + '</div>' +
            '</div>';
    });
    document.getElementById('optionList').innerHTML = html;

    // Next / Submit button visibility
    var btnNext   = document.getElementById('btnNext');
    var btnSubmit = document.getElementById('btnSubmitQuiz');
    if (idx === questions.length - 1) {
        btnNext.style.display   = 'none';
        btnSubmit.style.display = 'inline-block';
    } else {
        btnNext.style.display   = 'inline-block';
        btnSubmit.style.display = 'none';
    }

    updateNavGrid();
    updateProgress();
}

// ── Select option ──────────────────────────────────────────────
function selectOption(questionId, letter, el) {
    answers[questionId] = letter;

    // Update UI
    document.querySelectorAll('.option-item').forEach(function(o) {
        o.classList.remove('selected');
    });
    el.classList.add('selected');

    // Save to hidden field
    document.getElementById('<%= hfAnswers.ClientID %>').value =
        JSON.stringify(answers);

    updateNavGrid();
    updateProgress();
}

// ── Navigation ─────────────────────────────────────────────────
function navigate(dir) {
    showQuestion(currentIdx + dir);
}

function goToQuestion(idx) {
    showQuestion(idx);
}

// ── Nav grid ───────────────────────────────────────────────────
function buildNavGrid() {
    var grid = document.getElementById('qNavGrid');
    var html = '';
    questions.forEach(function (q, i) {
        html += '<button class="q-nav-btn" id="qnb_' + i + '" ' +
                'onclick="goToQuestion(' + i + ')">' + (i+1) + '</button>';
    });
    grid.innerHTML = html;
}

function updateNavGrid() {
    questions.forEach(function (q, i) {
        var btn = document.getElementById('qnb_' + i);
        if (!btn) return;
        btn.className = 'q-nav-btn';
        if (i === currentIdx)       btn.classList.add('current');
        if (answers[q.id])          btn.classList.add('answered');
    });
}

function updateProgress() {
    var answered = Object.keys(answers).length;
    var total    = questions.length;
    var pct      = total > 0 ? Math.round(answered / total * 100) : 0;

    document.getElementById('progressLabel').innerText =
        answered + ' / ' + total;
    document.getElementById('progressBar').style.width = pct + '%';
}

// ── Submit ─────────────────────────────────────────────────────
function confirmSubmit() {
    var unanswered = questions.length - Object.keys(answers).length;
    var msg = 'Submit quiz now?';
    if (unanswered > 0)
        msg = unanswered + ' question(s) unanswered. Submit anyway?';
    if (!confirm(msg)) return;
    doSubmit(false);
}

function autoSubmit() {
    document.getElementById('<%= hfIsAutoSubmit.ClientID %>').value = '1';
    doSubmit(true);
}

function doSubmit(isAuto) {
    clearInterval(timerInterval);

    // Time taken in seconds
    var timeTaken = Math.round((Date.now() - startedAt) / 1000);

    document.getElementById('<%= hfAnswers.ClientID %>').value =
        JSON.stringify(answers);
    document.getElementById('<%= hfIsAutoSubmit.ClientID %>').value =
        isAuto ? '1' : '0';

    // Store time taken in hidden field reusing hfStartTime
    document.getElementById('<%= hfStartTime.ClientID %>').value =
        timeTaken.toString();

    // Trigger server postback
    document.getElementById('<%= btnDoSubmit.ClientID %>').click();
}

// ── Helpers ───────────────────────────────────────────────────
function escHtml(s) {
    if (!s) return '';
    return s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
}

</script>

</asp:Content>
