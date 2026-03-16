using System;
using System.Data;
using System.Data.SqlClient;
using LearningManagementSystem.BL;
using LearningManagementSystem.GC;

namespace LMS_Project.Student
{
    public partial class MySubjects : System.Web.UI.Page
    {
        private int _userId;
        private int _instituteId;
        private int _sessionId;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                _userId = Convert.ToInt32(Session["UserId"]);
                _instituteId = Convert.ToInt32(Session["InstituteId"]);

                StudentSubjectsBL bl = new StudentSubjectsBL();

                // ── resolve session ───────────────────────────────────
                _sessionId = Session["CurrentSessionId"] != null
                             ? Convert.ToInt32(Session["CurrentSessionId"])
                             : bl.GetCurrentSessionId(_instituteId);

                if (_sessionId == 0)
                {
                    ShowEmpty("No active academic session found. Contact your administrator.");
                    return;
                }

                LoadSessionName();
                LoadSubjects(bl, string.Empty);
            }
        }

        // ============================================================
        // Search textbox changed
        // ============================================================
        protected void txtSearch_TextChanged(object sender, EventArgs e)
        {
            _userId = Convert.ToInt32(Session["UserId"]);
            _instituteId = Convert.ToInt32(Session["InstituteId"]);
            _sessionId = Convert.ToInt32(Session["CurrentSessionId"]);

            StudentSubjectsBL bl = new StudentSubjectsBL();
            LoadSubjects(bl, txtSearch.Text.Trim());
        }

        // ============================================================
        // Clear search
        // ============================================================
        protected void btnClear_Click(object sender, EventArgs e)
        {
            txtSearch.Text = string.Empty;

            _userId = Convert.ToInt32(Session["UserId"]);
            _instituteId = Convert.ToInt32(Session["InstituteId"]);
            _sessionId = Convert.ToInt32(Session["CurrentSessionId"]);

            StudentSubjectsBL bl = new StudentSubjectsBL();
            LoadSubjects(bl, string.Empty);
        }

        // ============================================================
        // Load & bind subjects
        // ============================================================
        private void LoadSubjects(StudentSubjectsBL bl, string keyword)
        {
            DataTable dt = string.IsNullOrEmpty(keyword)
                ? bl.GetMySubjects(_userId, _instituteId, _sessionId)
                : bl.SearchSubjects(_userId, _instituteId, _sessionId, keyword);

            if (dt.Rows.Count > 0)
            {
                // ── summary strip totals ──────────────────────────
                int totalChapters = 0;
                int totalVideos = 0;
                int totalMaterials = 0;

                foreach (DataRow r in dt.Rows)
                {
                    totalChapters += Convert.ToInt32(r["ChapterCount"]);
                    totalVideos += Convert.ToInt32(r["VideoCount"]);
                    totalMaterials += Convert.ToInt32(r["MaterialCount"]);
                }

                lblTotalSubjects.Text = dt.Rows.Count.ToString();
                lblTotalChapters.Text = totalChapters.ToString();
                lblTotalVideos.Text = totalVideos.ToString();
                lblTotalMaterials.Text = totalMaterials.ToString();

                rptSubjects.DataSource = dt;
                rptSubjects.DataBind();

                pnlSubjects.Visible = true;
                pnlEmpty.Visible = false;
            }
            else
            {
                string msg = string.IsNullOrEmpty(keyword)
                    ? "You are not enrolled in any subjects yet.<br/>Please contact your administrator."
                    : $"No subjects match <strong>\"{keyword}\"</strong>. Try a different keyword.";

                ShowEmpty(msg);
            }
        }

        // ============================================================
        // Session name label
        // ============================================================
        private void LoadSessionName()
        {
            StudentSubjectsBL bl = new StudentSubjectsBL();
            DataTable dt = new StudentDashboardBL().GetCurrentSession(_instituteId);

            if (dt.Rows.Count > 0)
                lblSessionName.Text = dt.Rows[0]["SessionName"].ToString();
        }

        // ============================================================
        // Empty state helper
        // ============================================================
        private void ShowEmpty(string message)
        {
            pnlSubjects.Visible = false;
            pnlEmpty.Visible = true;
            emptyMsg.InnerHtml = message;

            lblTotalSubjects.Text = "0";
            lblTotalChapters.Text = "0";
            lblTotalVideos.Text = "0";
            lblTotalMaterials.Text = "0";
        }

        // ============================================================
        // Stripe color helper — called from ASPX Repeater
        // ============================================================
        protected string GetStripeClass(int index)
        {
            string[] stripes = { "stripe-blue", "stripe-purple",
                                  "stripe-green", "stripe-orange" };
            return stripes[index % 4];
        }
    }
}