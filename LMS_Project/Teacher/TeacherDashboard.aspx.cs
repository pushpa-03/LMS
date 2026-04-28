using LearningManagementSystem.BL;
using LMS_Project.Teacher;
using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace LMS_Project.Teacher
{
    public partial class TeacherDashboard : Page
    {
        TeacherDashboardBL bl = new TeacherDashboardBL();

        private int TeacherId => Convert.ToInt32(Session["UserId"]);
        private int InstituteId => Convert.ToInt32(Session["InstituteId"]);
        private int SocietyId => Convert.ToInt32(Session["SocietyId"]);

        private int SelSessionId
        {
            get => ViewState["SelSession"] != null ? (int)ViewState["SelSession"] : 0;
            set => ViewState["SelSession"] = value;
        }
        private int SelSectionId
        {
            get => ViewState["SelSection"] != null ? (int)ViewState["SelSection"] : 0;
            set => ViewState["SelSection"] = value;
        }
        private int SelStreamId
        {
            get => ViewState["SelStream"] != null ? (int)ViewState["SelStream"] : 0;
            set => ViewState["SelStream"] = value;
        }
        private int SelStudentSessionId
        {
            get => ViewState["SelStudentSession"] != null ? (int)ViewState["SelStudentSession"] : 0;
            set => ViewState["SelStudentSession"] = value;
        }
        private int SelStudentSectionId
        {
            get => ViewState["SelStudentSection"] != null ? (int)ViewState["SelStudentSection"] : 0;
            set => ViewState["SelStudentSection"] = value;
        }
        private int SelStudentStreamId
        {
            get => ViewState["SelStudentStream"] != null ? (int)ViewState["SelStudentStream"] : 0;
            set => ViewState["SelStudentStream"] = value;
        }
        private int SelAsgSubjectId
        {
            get => ViewState["SelAsgSubject"] != null ? (int)ViewState["SelAsgSubject"] : 0;
            set => ViewState["SelAsgSubject"] = value;
        }
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadWelcomeBanner();
                LoadFilterDropdowns();
                LoadStudentFilterDropdowns();
                LoadStatCards();
                LoadSubjects();
                LoadRecentStudents();
                LoadAssignmentFilterDropdowns(); // ← add
                LoadRecentAssignments();
            }
        }

        // ── Welcome Banner ──────────────────────────────────────────
        private void LoadWelcomeBanner()
        {
            DataTable dt = bl.GetTeacherWelcomeInfo(TeacherId, InstituteId);
            if (dt.Rows.Count > 0)
            {
                DataRow r = dt.Rows[0];
                lblWelcomeName.Text = r["FullName"].ToString();
                lblDeptPill.Text = "🏫 " + r["Department"].ToString();
                lblDesignationPill.Text = "👤 " + r["Designation"].ToString();
                lblSessionPill.Text = "📅 " + r["SessionName"].ToString();
            }
        }

        // ── Filter Dropdowns ────────────────────────────────────────
        private void LoadFilterDropdowns()
        {
            // Sessions
            ddlFilterSession.Items.Clear();
            ddlFilterSession.Items.Add(new ListItem("All Years", "0"));

            DataTable dtSess = bl.GetSessionsForFilter(InstituteId, SocietyId);
            foreach (DataRow row in dtSess.Rows)
                ddlFilterSession.Items.Add(
                    new ListItem(row["SessionName"].ToString(),
                                 row["SessionId"].ToString()));

            // Use Session["CurrentSessionId"] exactly like TeacherCourses does
            int currSession = Session["CurrentSessionId"] != null
                              ? Convert.ToInt32(Session["CurrentSessionId"])
                              : bl.GetCurrentSessionId(InstituteId);

            if (currSession > 0)
            {
                SelSessionId = currSession;
                ddlFilterSession.SelectedValue = currSession.ToString();
            }

            // Sections
            ddlFilterSection.Items.Clear();
            ddlFilterSection.Items.Add(new ListItem("All Sections", "0"));
            DataTable dtSec = bl.GetSectionsForFilter(TeacherId, InstituteId);
            foreach (DataRow row in dtSec.Rows)
                ddlFilterSection.Items.Add(
                    new ListItem(row["SectionName"].ToString(),
                                 row["SectionId"].ToString()));

            // Streams
            ddlFilterStream.Items.Clear();
            ddlFilterStream.Items.Add(new ListItem("All Streams", "0"));
            DataTable dtStr = bl.GetStreamsForFilter(TeacherId, InstituteId);
            foreach (DataRow row in dtStr.Rows)
                ddlFilterStream.Items.Add(
                    new ListItem(row["StreamName"].ToString(),
                                 row["StreamId"].ToString()));
        }
        // ── Stat Cards ──────────────────────────────────────────────
        private void LoadStatCards()
        {
            DataTable dt = bl.GetDashboardStats(TeacherId, InstituteId, SelSessionId);
            if (dt.Rows.Count > 0)
            {
                DataRow r = dt.Rows[0];
                lblTotalSubjects.Text = r["TotalSubjects"].ToString();
                lblTotalStudents.Text = r["TotalStudents"].ToString();
                lblTotalAssignments.Text = r["TotalAssignments"].ToString();
                lblTotalVideos.Text = r["TotalVideos"].ToString();
            }
        }

        // ── Subjects ────────────────────────────────────────────────
        private void LoadSubjects()
        {
            DataTable dt = bl.GetTeacherSubjects(
                TeacherId, InstituteId, SocietyId,
                SelSessionId, SelSectionId, SelStreamId);

            bool hasData = dt.Rows.Count > 0;

            rptSubjectsList.DataSource = dt;
            rptSubjectsList.DataBind();

            hfChartData.Value = bl.GetSubjectChartJson(dt);

            // List is default/visible, chart hidden, no-data panel toggled
            pnlSubjectsList.Visible = hasData;
            pnlSubjectsChart.Visible = hasData;
            pnlNoSubjects.Visible = !hasData;

            if (hasData)
            {
                pnlSubjectsList.Style["display"] = "";
                pnlSubjectsChart.Style["display"] = "none";
            }
        }
        private void LoadStudentFilterDropdowns()
        {
            // Session
            ddlStudentSession.Items.Clear();
            ddlStudentSession.Items.Add(new ListItem("All Years", "0"));
            DataTable dtSess = bl.GetSessionsForFilter(InstituteId, SocietyId);
            foreach (DataRow row in dtSess.Rows)
                ddlStudentSession.Items.Add(
                    new ListItem(row["SessionName"].ToString(),
                                 row["SessionId"].ToString()));

            int currSession = Session["CurrentSessionId"] != null
                              ? Convert.ToInt32(Session["CurrentSessionId"])
                              : bl.GetCurrentSessionId(InstituteId);
            if (currSession > 0)
            {
                SelStudentSessionId = currSession;
                ddlStudentSession.SelectedValue = currSession.ToString();
            }

            // Section
            ddlStudentSection.Items.Clear();
            ddlStudentSection.Items.Add(new ListItem("All Sections", "0"));
            DataTable dtSec = bl.GetSectionsForFilter(TeacherId, InstituteId);
            foreach (DataRow row in dtSec.Rows)
                ddlStudentSection.Items.Add(
                    new ListItem(row["SectionName"].ToString(),
                                 row["SectionId"].ToString()));

            // Stream
            ddlStudentStream.Items.Clear();
            ddlStudentStream.Items.Add(new ListItem("All Streams", "0"));
            DataTable dtStr = bl.GetStreamsForFilter(TeacherId, InstituteId);
            foreach (DataRow row in dtStr.Rows)
                ddlStudentStream.Items.Add(
                    new ListItem(row["StreamName"].ToString(),
                                 row["StreamId"].ToString()));
        }
        // ── Recent Students ─────────────────────────────────────────
        private void LoadRecentStudents()
        {
            DataTable dt = bl.GetRecentStudents(
                TeacherId, InstituteId,
                SelStudentSessionId, SelStudentSectionId, SelStudentStreamId);

            bool hasData = dt.Rows.Count > 0;

            rptStudents.DataSource = dt;
            rptStudents.DataBind();

            pnlStudents.Visible = hasData;
            pnlNoStudents.Visible = !hasData;
        }
        private void LoadAssignmentFilterDropdowns()
        {
            ddlAsgSubject.Items.Clear();
            ddlAsgSubject.Items.Add(new ListItem("All Subjects", "0"));

            DataTable dt = bl.GetTeacherSubjectsForFilter(TeacherId, InstituteId, SelSessionId);
            foreach (DataRow row in dt.Rows)
                ddlAsgSubject.Items.Add(
                    new ListItem(row["SubjectName"].ToString(),
                                 row["SubjectId"].ToString()));
        }
        // ── Recent Assignments ──────────────────────────────────────
        private void LoadRecentAssignments()
        {
            DataTable dt = bl.GetRecentAssignments(TeacherId, InstituteId, SelAsgSubjectId);
            bool hasData = dt.Rows.Count > 0;

            // List view
            rptAssignments.DataSource = dt;
            rptAssignments.DataBind();

            // Chart JSON
            hfAsgChartData.Value = bl.GetAssignmentChartJson(dt);

            // Summary progress bars
            DataTable dtSummary = bl.GetAssignmentSummary(dt);
            bool hasSummary = dtSummary.Rows.Count > 0;
            rptAsgSummary.DataSource = dtSummary;
            rptAsgSummary.DataBind();

            // Panel visibility
            pnlAssignments.Visible = hasData;
            pnlAsgChart.Visible = hasData;
            pnlNoAssignments.Visible = !hasData;
            pnlAsgSummary.Visible = hasSummary;
            pnlNoAsgSummary.Visible = !hasSummary;

            if (hasData)
            {
                pnlAssignments.Style["display"] = "";
                pnlAsgChart.Style["display"] = "none";
            }
        }

        // ── Filter Postbacks ────────────────────────────────────────
        protected void ddlFilterSession_SelectedIndexChanged(object sender, EventArgs e)
        {
            SelSessionId = Convert.ToInt32(ddlFilterSession.SelectedValue);
            LoadSubjects();
            LoadStatCards();
        }

        protected void ddlFilterSection_SelectedIndexChanged(object sender, EventArgs e)
        {
            SelSectionId = Convert.ToInt32(ddlFilterSection.SelectedValue);
            LoadSubjects();
        }

        protected void ddlFilterStream_SelectedIndexChanged(object sender, EventArgs e)
        {
            SelStreamId = Convert.ToInt32(ddlFilterStream.SelectedValue);
            LoadSubjects();
        }
        protected void ddlStudentSession_SelectedIndexChanged(object sender, EventArgs e)
        {
            SelStudentSessionId = Convert.ToInt32(ddlStudentSession.SelectedValue);
            LoadRecentStudents();
        }

        protected void ddlStudentSection_SelectedIndexChanged(object sender, EventArgs e)
        {
            SelStudentSectionId = Convert.ToInt32(ddlStudentSection.SelectedValue);
            LoadRecentStudents();
        }

        protected void ddlStudentStream_SelectedIndexChanged(object sender, EventArgs e)
        {
            SelStudentStreamId = Convert.ToInt32(ddlStudentStream.SelectedValue);
            LoadRecentStudents();
        }
        protected void ddlAsgSubject_SelectedIndexChanged(object sender, EventArgs e)
        {
            SelAsgSubjectId = Convert.ToInt32(ddlAsgSubject.SelectedValue);
            LoadRecentAssignments();
        }
    }
}