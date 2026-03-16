using System;
using System.Data;
using System.Web.UI;
using LearningManagementSystem.BL;
using LearningManagementSystem.GC;

namespace LMS_Project.Student
{
    public partial class Dashboard : System.Web.UI.Page
    {
        // ── pulled once and reused across methods ──
        private int _userId;
        private int _instituteId;
        private int _sessionId;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                _userId = Convert.ToInt32(Session["UserId"]);
                _instituteId = Convert.ToInt32(Session["InstituteId"]);

                // ── resolve current session ──────────────────────────
                StudentDashboardBL bl = new StudentDashboardBL();

                DataTable dtSession = bl.GetCurrentSession(_instituteId);

                if (dtSession.Rows.Count == 0)
                {
                    // No current session — show a friendly warning
                    ShowNoSessionWarning();
                    return;
                }

                _sessionId = Convert.ToInt32(dtSession.Rows[0]["SessionId"]);

                // store in Session so other pages can use it too
                if (Session["CurrentSessionId"] == null)
                    Session["CurrentSessionId"] = _sessionId;

                // ── load all sections ─────────────────────────────────
                LoadStudentInfo(bl);
                LoadStatCards(bl);
                LoadSubjects(bl);
                LoadAssignments(bl);
                LoadNotifications(bl);
            }
        }

        // ============================================================
        // Welcome banner + meta pills
        // ============================================================
        private void LoadStudentInfo(StudentDashboardBL bl)
        {
            DataTable dt = bl.GetStudentInfo(_userId);

            if (dt.Rows.Count == 0) return;

            DataRow r = dt.Rows[0];

            lblWelcomeName.Text = r["FullName"].ToString().Split(' ')[0]; // first name

            // Meta pills
            if (!string.IsNullOrEmpty(r["RollNumber"]?.ToString()))
                lblRollPill.Text = "🎓 Roll: " + r["RollNumber"];

            if (!string.IsNullOrEmpty(r["CourseName"]?.ToString()))
                lblCoursePill.Text = "📚 " + r["CourseName"];

            if (!string.IsNullOrEmpty(r["SemesterName"]?.ToString()))
                lblSemPill.Text = "📅 " + r["SemesterName"];

            // Current session name
            StudentDashboardBL bl2 = new StudentDashboardBL();
            DataTable dtSess = bl2.GetCurrentSession(_instituteId);
            if (dtSess.Rows.Count > 0)
                lblSessionPill.Text = "🗓 " + dtSess.Rows[0]["SessionName"];
        }

        // ============================================================
        // 4 stat cards
        // ============================================================
        private void LoadStatCards(StudentDashboardBL bl)
        {
            DataTable dt = bl.GetDashboardCounts(_userId, _instituteId, _sessionId);

            if (dt.Rows.Count == 0) return;

            DataRow r = dt.Rows[0];

            lblTotalSubjects.Text = r["TotalSubjects"].ToString();
            lblPendingAssignments.Text = r["PendingAssignments"].ToString();
            lblUpcomingQuizzes.Text = r["UpcomingQuizzes"].ToString();
            lblUnreadNotifications.Text = r["UnreadNotifications"].ToString();
        }

        // ============================================================
        // Subject cards grid
        // ============================================================
        private void LoadSubjects(StudentDashboardBL bl)
        {
            DataTable dt = bl.GetEnrolledSubjects(_userId, _instituteId, _sessionId);

            if (dt.Rows.Count > 0)
            {
                rptSubjects.DataSource = dt;
                rptSubjects.DataBind();
                pnlSubjects.Visible = true;
                pnlNoSubjects.Visible = false;
            }
            else
            {
                pnlSubjects.Visible = false;
                pnlNoSubjects.Visible = true;
            }
        }

        // ============================================================
        // Upcoming assignments list
        // ============================================================
        private void LoadAssignments(StudentDashboardBL bl)
        {
            DataTable dt = bl.GetUpcomingAssignments(_userId, _instituteId, _sessionId);

            if (dt.Rows.Count > 0)
            {
                rptAssignments.DataSource = dt;
                rptAssignments.DataBind();
                pnlAssignments.Visible = true;
                pnlNoAssignments.Visible = false;
            }
            else
            {
                pnlAssignments.Visible = false;
                pnlNoAssignments.Visible = true;
            }
        }

        // ============================================================
        // Notifications feed
        // ============================================================
        private void LoadNotifications(StudentDashboardBL bl)
        {
            DataTable dt = bl.GetRecentNotifications(_userId, _instituteId);

            if (dt.Rows.Count > 0)
            {
                rptNotifications.DataSource = dt;
                rptNotifications.DataBind();
                pnlNotifications.Visible = true;
                pnlNoNotifications.Visible = false;
            }
            else
            {
                pnlNotifications.Visible = false;
                pnlNoNotifications.Visible = true;
            }
        }

        // ============================================================
        // No session warning
        // ============================================================
        private void ShowNoSessionWarning()
        {
            lblWelcomeName.Text = Session["Username"]?.ToString();
            // All panels remain hidden — show a gentle message
            pnlNoSubjects.Visible = true;
            pnlNoAssignments.Visible = true;
            pnlNoNotifications.Visible = true;
        }
    }
}