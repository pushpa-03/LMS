using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace LMS_Project.Student
{
    public partial class Quizzes : System.Web.UI.Page
    {
        StudentQuizBL bl = new StudentQuizBL();

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
                LoadSubjectFilter();
                LoadQuizzes();
            }
        }

        private void LoadSummary()
        {
            DataTable dt = bl.GetQuizCounts(_userId, _instituteId, _sessionId);
            if (dt.Rows.Count == 0) return;

            DataRow r = dt.Rows[0];
            lblTotal.Text = r["Total"].ToString();
            lblAvailable.Text = r["Available"].ToString();
            lblAttempted.Text = r["Attempted"].ToString();
            lblExpired.Text = r["Expired"].ToString();
        }

        private void LoadSubjectFilter()
        {
            DataTable dt = bl.GetSubjectsForFilter(_userId, _instituteId, _sessionId);
            ddlSubjectFilter.Items.Clear();
            ddlSubjectFilter.Items.Add(new ListItem("All Subjects", "0"));
            foreach (DataRow r in dt.Rows)
                ddlSubjectFilter.Items.Add(new ListItem(
                    r["SubjectCode"] + " — " + r["SubjectName"],
                    r["SubjectId"].ToString()));
        }

        private void LoadQuizzes()
        {
            int subjectId = Convert.ToInt32(ddlSubjectFilter.SelectedValue);
            string state = ddlStateFilter.SelectedValue;

            DataTable dt = bl.GetQuizzes(_userId, _instituteId, _sessionId, subjectId);

            // Client-side state filter
            if (state != "All")
            {
                DataView dv = dt.DefaultView;
                dv.RowFilter = $"State = '{state}'";
                dt = dv.ToTable();
            }

            if (dt.Rows.Count > 0)
            {
                rptQuizzes.DataSource = dt;
                rptQuizzes.DataBind();
                pnlQuizzes.Visible = true;
                pnlEmpty.Visible = false;
            }
            else
            {
                pnlQuizzes.Visible = false;
                pnlEmpty.Visible = true;
            }
        }

        protected void ddlFilter_Changed(object sender, EventArgs e)
        {
            LoadQuizzes();
        }

        protected void btnReset_Click(object sender, EventArgs e)
        {
            ddlSubjectFilter.SelectedIndex = 0;
            ddlStateFilter.SelectedValue = "All";
            LoadQuizzes();
        }

        // Open instructions modal via JS
        protected void rptQuizzes_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "StartQuiz") return;

            string[] parts = e.CommandArgument.ToString().Split('|');
            int quizId = Convert.ToInt32(parts[0]);
            string title = parts.Length > 1 ? parts[1] : "Quiz";

            string script = $"showInstructions({quizId}, '{EscJs(title)}');";
            ScriptManager.RegisterStartupScript(this, GetType(), "openInst", script, true);
        }

        // ── Helpers called from ASPX ─────────────────────────
        protected string GetStateIcon(string state)
        {
            switch (state)
            {
                case "Available": return "<i class='fas fa-play-circle'></i>";
                case "Attempted": return "<i class='fas fa-check-circle'></i>";
                case "Expired": return "<i class='fas fa-clock'></i>";
                default: return "<i class='fas fa-ban'></i>";
            }
        }

        protected string GetDueLabel(DateTime dueDate, string state)
        {
            if (state == "Attempted")
                return "<span class='due-normal'>Completed</span>";

            int days = (int)(dueDate - DateTime.Now).TotalDays;

            if (days < 0)
                return $"<span class='due-expired'>Expired {Math.Abs(days)} days ago</span>";
            if (days == 0)
                return "<span class='due-soon'>Due Today!</span>";
            if (days <= 2)
                return $"<span class='due-soon'>{days} day{(days == 1 ? "" : "s")} left</span>";

            return $"<span class='due-normal'>Due: {dueDate:dd MMM yyyy}</span>";
        }

        protected string RenderScoreBar(int score, int total, int pass)
        {
            if (total == 0) return "";
            int pct = (int)((double)score / total * 100);
            bool passed = score >= pass;
            string barClass = passed ? "score-pass" : "score-fail";
            string label = passed
                ? $"<span style='color:#2e7d32'>{score}/{total} — Passed ✅</span>"
                : $"<span style='color:#c62828'>{score}/{total} — Failed ❌</span>";

            return $@"
            <div class='score-bar-wrap'>
                <div class='score-bar-label'>
                    <span style='font-size:12px;color:#546e7a;'>Score</span>
                    {label}
                </div>
                <div class='score-bar-track'>
                    <div class='score-bar-fill {barClass}' style='width:{pct}%'></div>
                </div>
            </div>";
        }

        private string EscJs(string s) =>
            s?.Replace("'", "\\'").Replace("\r", "").Replace("\n", " ") ?? "";
    }
}