using System;
using System.Data;
using System.Web.UI.WebControls;

namespace LMS_Project.Student
{
    public partial class Results : System.Web.UI.Page
    {
        StudentResultsBL bl = new StudentResultsBL();

        private int _userId;
        private int _instituteId;
        private int _sessionId;

        protected void Page_Load(object sender, EventArgs e)
        {
            _userId = Convert.ToInt32(Session["UserId"]);
            _instituteId = Convert.ToInt32(Session["InstituteId"]);

            StudentSubjectsBL subBL = new StudentSubjectsBL();
            _sessionId = Session["CurrentSessionId"] != null
                         ? Convert.ToInt32(Session["CurrentSessionId"])
                         : subBL.GetCurrentSessionId(_instituteId);

            if (!IsPostBack)
            {
                LoadSummary();
                LoadSubjectFilters();
                LoadAssignmentResults();
                LoadQuizResults();
            }
        }

        // ── Summary ─────────────────────────────────────────────
        private void LoadSummary()
        {
            DataTable dt = bl.GetSummaryCounts(_userId, _instituteId, _sessionId);
            if (dt.Rows.Count == 0) return;

            DataRow r = dt.Rows[0];
            lblTotalSubmissions.Text = r["TotalSubmissions"].ToString();
            lblGraded.Text = r["GradedCount"].ToString();
            lblTotalQuizzes.Text = r["TotalQuizzes"].ToString();
            lblQuizPassed.Text = r["QuizzesPassed"].ToString();
        }

        // ── Subject filter dropdowns ─────────────────────────────
        private void LoadSubjectFilters()
        {
            DataTable dt = bl.GetSubjectsForFilter(_userId, _instituteId, _sessionId);

            ddlAsgSubject.Items.Clear();
            ddlAsgSubject.Items.Add(new ListItem("All Subjects", "0"));

            ddlQuizSubject.Items.Clear();
            ddlQuizSubject.Items.Add(new ListItem("All Subjects", "0"));

            foreach (DataRow r in dt.Rows)
            {
                string text = r["SubjectCode"] + " — " + r["SubjectName"];
                string val = r["SubjectId"].ToString();
                ddlAsgSubject.Items.Add(new ListItem(text, val));
                ddlQuizSubject.Items.Add(new ListItem(text, val));
            }
        }

        // ── Assignment results ───────────────────────────────────
        private void LoadAssignmentResults()
        {
            int subjectId = Convert.ToInt32(ddlAsgSubject.SelectedValue);
            DataTable dt = bl.GetAssignmentResults(
                                _userId, _instituteId, _sessionId, subjectId);

            lblAsgTabCount.Text = dt.Rows.Count.ToString();

            if (dt.Rows.Count > 0)
            {
                rptAsgResults.DataSource = dt;
                rptAsgResults.DataBind();
                pnlAsgResults.Visible = true;
                pnlAsgEmpty.Visible = false;
            }
            else
            {
                pnlAsgResults.Visible = false;
                pnlAsgEmpty.Visible = true;
            }
        }

        // ── Quiz results ─────────────────────────────────────────
        private void LoadQuizResults()
        {
            int subjectId = Convert.ToInt32(ddlQuizSubject.SelectedValue);
            DataTable dt = bl.GetQuizResults(_userId, _instituteId, subjectId);

            lblQuizTabCount.Text = dt.Rows.Count.ToString();

            if (dt.Rows.Count > 0)
            {
                rptQuizResults.DataSource = dt;
                rptQuizResults.DataBind();
                pnlQuizResults.Visible = true;
                pnlQuizEmpty.Visible = false;
            }
            else
            {
                pnlQuizResults.Visible = false;
                pnlQuizEmpty.Visible = true;
            }
        }

        // ── Filter events ────────────────────────────────────────
        protected void ddlAsgSubject_Changed(object sender, EventArgs e)
        {
            hfActiveTab.Value = "assignments";
            LoadAssignmentResults();
        }

        protected void ddlQuizSubject_Changed(object sender, EventArgs e)
        {
            hfActiveTab.Value = "quizzes";
            LoadQuizResults();
        }

        protected void btnAsgReset_Click(object sender, EventArgs e)
        {
            ddlAsgSubject.SelectedIndex = 0;
            hfActiveTab.Value = "assignments";
            LoadAssignmentResults();
        }

        protected void btnQuizReset_Click(object sender, EventArgs e)
        {
            ddlQuizSubject.SelectedIndex = 0;
            hfActiveTab.Value = "quizzes";
            LoadQuizResults();
        }

        // ── Helpers (called from ASPX) ───────────────────────────
        protected string GetScoreRing(object score, object maxObj, string status)
        {
            if (status == "Pending" || score == DBNull.Value)
                return "<div class='score-ring ring-pending'>" +
                       "<div class='sr-val'>—</div></div>";

            int s = Convert.ToInt32(score);
            int max = Convert.ToInt32(maxObj);
            int pct = max > 0 ? (int)((double)s / max * 100) : 0;

            string cls = pct >= 75 ? "ring-high"
                       : pct >= 50 ? "ring-mid"
                       : "ring-low";

            return $"<div class='score-ring {cls}'>" +
                   $"<div class='sr-val'>{s}</div>" +
                   $"<div class='sr-of'>/ {max}</div>" +
                   $"</div>";
        }

        protected string GetGradeBadge(object pct, string status)
        {
            if (status == "Pending")
                return "<span class='grade-badge grade-P'>Pending</span>";

            int p = pct == DBNull.Value ? 0 : Convert.ToInt32(pct);

            if (p >= 90) return "<span class='grade-badge grade-A'>Grade A</span>";
            if (p >= 75) return "<span class='grade-badge grade-B'>Grade B</span>";
            if (p >= 50) return "<span class='grade-badge grade-C'>Grade C</span>";
            return "<span class='grade-badge grade-F'>Grade F</span>";
        }

        protected string GetQuizGradeBadge(string status)
        {
            return status == "Passed"
                ? "<span class='grade-badge grade-A'>Passed ✅</span>"
                : "<span class='grade-badge grade-F'>Failed ❌</span>";
        }

        protected string GetMiniBar(int pct)
        {
            string color = pct >= 75 ? "#2e7d32"
                         : pct >= 50 ? "#f57f17"
                         : "#c62828";
            return $@"<div class='mini-bar'>
                <div class='mini-bar-track'>
                    <div class='mini-bar-fill'
                         style='width:{pct}%;background:{color};'></div>
                </div>
              </div>";
        }

        protected string FormatTime(int seconds)
        {
            if (seconds <= 0) return "—";
            int m = seconds / 60;
            int s = seconds % 60;
            return $"{m}m {s}s";
        }
    }
}