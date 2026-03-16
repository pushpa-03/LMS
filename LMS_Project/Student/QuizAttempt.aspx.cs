using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Web.Script.Serialization;
using System.Web.UI;

namespace LMS_Project.Student
{
    public partial class QuizAttempt : System.Web.UI.Page
    {
        StudentQuizBL bl = new StudentQuizBL();

        private int _userId;
        private int _instituteId;
        private int _societyId;
        private int _sessionId;

        protected void Page_Load(object sender, EventArgs e)
        {
            _userId = Convert.ToInt32(Session["UserId"]);
            _instituteId = Convert.ToInt32(Session["InstituteId"]);
            _societyId = Convert.ToInt32(Session["SocietyId"]);

            StudentSubjectsBL subBL = new StudentSubjectsBL();
            _sessionId = Session["CurrentSessionId"] != null
                         ? Convert.ToInt32(Session["CurrentSessionId"])
                         : subBL.GetCurrentSessionId(_instituteId);

            if (!IsPostBack)
            {
                // ── Validate querystring ─────────────────────────
                if (Request.QueryString["QuizId"] == null)
                {
                    Block("Invalid quiz link.");
                    return;
                }

                int quizId = Convert.ToInt32(Request.QueryString["QuizId"]);
                hfQuizId.Value = quizId.ToString();

                // ── Get quiz info ────────────────────────────────
                DataTable dtQuiz = bl.GetQuizById(quizId);
                if (dtQuiz.Rows.Count == 0)
                {
                    Block("Quiz not found.");
                    return;
                }

                DataRow q = dtQuiz.Rows[0];

                // ── Guards ───────────────────────────────────────
                if (!Convert.ToBoolean(q["IsEnabled"]))
                {
                    Block("This quiz is not enabled.");
                    return;
                }

                if (Convert.ToDateTime(q["DueDate"]) < DateTime.Now)
                {
                    Block("This quiz has expired.");
                    return;
                }

                if (bl.IsAttempted(quizId, _userId))
                {
                    Block("You have already attempted this quiz.");
                    return;
                }

                // ── All good — load quiz ─────────────────────────
                pnlBlocked.Visible = false;
                pnlQuiz.Visible = true;
                pnlResult.Visible = false;

                lblQuizTitle.Text = q["Title"].ToString();
                lblQuizMeta.Text =
                    q["SubjectCode"] + " — " + q["SubjectName"] +
                    " | " + q["QuestionCount"] + " Questions | " +
                    q["Duration"] + " mins | " + q["TotalMarks"] + " marks";

                hfDuration.Value = q["Duration"].ToString();
                hfStartTime.Value = DateTime.Now.ToString("o");

                // ── Load questions as JSON ───────────────────────
                DataTable dtQ = bl.GetQuestions(quizId);
                litQuestionsJson.Text = BuildQuestionsJson(dtQ);
            }
        }

        // ============================================================
        // Submit button click (triggered by JS)
        // ============================================================
        protected void btnDoSubmit_Click(object sender, EventArgs e)
        {
            int quizId = Convert.ToInt32(hfQuizId.Value);
            bool isAutoSubmit = hfIsAutoSubmit.Value == "1";

            // ── Parse answers from hidden field ──────────────────
            string answersJson = hfAnswers.Value;
            var answers = new Dictionary<int, string>();

            if (!string.IsNullOrEmpty(answersJson) && answersJson != "{}")
            {
                try
                {
                    var jss = new JavaScriptSerializer();
                    var raw = jss.Deserialize<Dictionary<string, string>>(answersJson);
                    foreach (var kv in raw)
                        answers[Convert.ToInt32(kv.Key)] = kv.Value;
                }
                catch { /* empty answers */ }
            }

            // ── Time taken ───────────────────────────────────────
            int timeTaken = 0;
            int.TryParse(hfStartTime.Value, out timeTaken);

            // ── Submit ───────────────────────────────────────────
            int resultId = bl.SubmitQuiz(
                quizId, _userId, _societyId, _instituteId,
                answers, timeTaken, isAutoSubmit);

            hfResultId.Value = resultId.ToString();

            // ── Show result ──────────────────────────────────────
            ShowResult(resultId, isAutoSubmit);
        }

        // ============================================================
        // Result screen
        // ============================================================
        private void ShowResult(int resultId, bool wasAutoSubmit)
        {
            pnlQuiz.Visible = false;
            pnlResult.Visible = true;

            DataTable dt = bl.GetResult(resultId);
            if (dt.Rows.Count == 0) return;

            DataRow r = dt.Rows[0];
            int score = Convert.ToInt32(r["Score"]);
            int total = Convert.ToInt32(r["TotalMarks"]);
            int pass = Convert.ToInt32(r["PassMarks"]);
            int correct = Convert.ToInt32(r["Correct"]);
            int wrong = Convert.ToInt32(r["Wrong"]);
            int skipped = Convert.ToInt32(r["Skipped"]);
            int timeSec = Convert.ToInt32(r["TimeTaken"]);
            bool passed = score >= pass;

            // Result circle
            string circleClass = passed ? "result-pass" : "result-fail";
            lblResultIcon.Text =
                $"<div class='result-circle {circleClass}'>" +
                $"<div class='r-score'>{score}</div>" +
                $"<div class='r-total'>/ {total}</div>" +
                $"</div>";

            lblResultTitle.Text =
                passed ? "🎉 Congratulations, You Passed!" : "Better luck next time!";

            string subtitle = $"{r["SubjectName"]} — {r["Title"]}";
            if (wasAutoSubmit)
                subtitle += " (Auto-submitted — time ran out)";
            lblResultSubtitle.Text = subtitle;

            lblCorrect.Text = correct.ToString();
            lblWrong.Text = wrong.ToString();
            lblSkipped.Text = skipped.ToString();
            lblTimeTaken.Text = FormatTime(timeSec);
        }

        // ============================================================
        // Helpers
        // ============================================================
        private void Block(string message)
        {
            pnlBlocked.Visible = true;
            pnlQuiz.Visible = false;
            pnlResult.Visible = false;
            lblBlockedMsg.Text = message;
        }

        private string BuildQuestionsJson(DataTable dt)
        {
            var sb = new StringBuilder("[");
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                DataRow r = dt.Rows[i];
                if (i > 0) sb.Append(",");
                sb.Append("{");
                sb.Append($"\"id\":{r["QuestionId"]},");
                sb.Append($"\"text\":{JsonStr(r["QuestionText"])},");
                sb.Append($"\"optA\":{JsonStr(r["OptionA"])},");
                sb.Append($"\"optB\":{JsonStr(r["OptionB"])},");
                sb.Append($"\"optC\":{JsonStr(r["OptionC"])},");
                sb.Append($"\"optD\":{JsonStr(r["OptionD"])},");
                sb.Append($"\"marks\":{r["Marks"]}");
                sb.Append("}");
            }
            sb.Append("]");
            return sb.ToString();
        }

        private string JsonStr(object val)
        {
            string s = val?.ToString() ?? "";
            s = s.Replace("\\", "\\\\")
                 .Replace("\"", "\\\"")
                 .Replace("\r", "\\r")
                 .Replace("\n", "\\n");
            return $"\"{s}\"";
        }

        private string FormatTime(int seconds)
        {
            int m = seconds / 60;
            int s = seconds % 60;
            return $"{m}m {s}s";
        }
    }
}