using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace LMS_Project.Student
{
    public partial class StudyMaterial : System.Web.UI.Page
    {
        SubjectDetailsBL bl = new SubjectDetailsBL();
        StudentSubjectsBL subjectsBL = new StudentSubjectsBL();

        private int _userId;
        private int _instituteId;
        private int _sessionId;

        protected void Page_Load(object sender, EventArgs e)
        {
            _userId = Convert.ToInt32(Session["UserId"]);
            _instituteId = Convert.ToInt32(Session["InstituteId"]);
            _sessionId = Session["CurrentSessionId"] != null
                           ? Convert.ToInt32(Session["CurrentSessionId"])
                           : subjectsBL.GetCurrentSessionId(_instituteId);

            if (!IsPostBack)
            {
                // ── Must have SubjectId in querystring ───────────────
                if (Request.QueryString["SubjectId"] == null)
                {
                    pnlNoSubject.Visible = true;
                    pnlContent.Visible = false;
                    return;
                }

                int subjectId = Convert.ToInt32(Request.QueryString["SubjectId"]);
                hfSubjectId.Value = subjectId.ToString();

                // ── Verify student is enrolled in this subject ───────
                if (!IsEnrolled(subjectId))
                {
                    pnlNoSubject.Visible = true;
                    pnlContent.Visible = false;
                    return;
                }

                pnlNoSubject.Visible = false;
                pnlContent.Visible = true;

                LoadSubjectInfo(subjectId);
                LoadChapters(subjectId);
            }
            else
            {
                // ── UpdatePanel postback — load topics for selected video ──
                if (hfVideoId.Value != "0" && !string.IsNullOrEmpty(hfVideoId.Value))
                {
                    LoadTopics(Convert.ToInt32(hfVideoId.Value));
                }
            }
        }

        // ============================================================
        // Subject info strip
        // ============================================================
        private void LoadSubjectInfo(int subjectId)
        {
            DataTable dt = subjectsBL.GetSubjectById(subjectId, _instituteId, _sessionId);

            if (dt.Rows.Count == 0) return;

            DataRow r = dt.Rows[0];

            lblSubjectName.Text = r["SubjectName"].ToString();
            lblSubjectCodeBadge.Text = r["SubjectCode"].ToString();
            lblSubjectDesc.Text = r["Description"]?.ToString();
            lblTeacherName.Text = r["TeacherName"].ToString();
            lblDuration.Text = r["Duration"].ToString();

            // Chapter count
            DataTable dtChapters = bl.GetChapters(subjectId);
            lblChapterCount.Text = dtChapters.Rows.Count.ToString();
        }

        // ============================================================
        // Chapter accordion + nested videos/materials
        // ============================================================
        private void LoadChapters(int subjectId)
        {
            DataTable dt = bl.GetChapters(subjectId);

            if (dt.Rows.Count == 0)
            {
                pnlNoChapters.Visible = true;
                rptChapters.Visible = false;
                return;
            }

            pnlNoChapters.Visible = false;
            rptChapters.Visible = true;

            rptChapters.DataSource = dt;
            rptChapters.DataBind();
        }

        // ============================================================
        // Bind videos + materials inside each chapter row
        // ============================================================
        protected void rptChapters_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item &&
                e.Item.ItemType != ListItemType.AlternatingItem)
                return;

            HiddenField hfChapterId = (HiddenField)e.Item.FindControl("hfChapterId");
            Repeater rptVideos = (Repeater)e.Item.FindControl("rptVideos");
            Repeater rptMaterials = (Repeater)e.Item.FindControl("rptMaterials");

            int chapterId = Convert.ToInt32(hfChapterId.Value);

            rptVideos.DataSource = bl.GetVideosByChapter(chapterId);
            rptVideos.DataBind();

            rptMaterials.DataSource = bl.GetMaterialsByChapter(chapterId);
            rptMaterials.DataBind();
        }

        // ============================================================
        // Load topics for selected video (UpdatePanel postback)
        // ============================================================
        private void LoadTopics(int videoId)
        {
            DataLayer dl = new DataLayer();
            System.Data.SqlClient.SqlCommand cmd =
                new System.Data.SqlClient.SqlCommand(@"
                SELECT StartTime, TopicTitle
                FROM VideoTopics
                WHERE VideoId = @VideoId
                ORDER BY StartTime");

            cmd.Parameters.AddWithValue("@VideoId", videoId);

            rptTopics.DataSource = dl.GetDataTable(cmd);
            rptTopics.DataBind();
        }

        // ============================================================
        // Enrollment check — student must own this subject
        // ============================================================
        private bool IsEnrolled(int subjectId)
        {
            DataLayer dl = new DataLayer();
            System.Data.SqlClient.SqlCommand cmd =
                new System.Data.SqlClient.SqlCommand(@"
                SELECT COUNT(*) FROM AssignStudentSubject
                WHERE UserId      = @UserId
                  AND SubjectId   = @SubjectId
                  AND InstituteId = @InstId");

            cmd.Parameters.AddWithValue("@UserId", _userId);
            cmd.Parameters.AddWithValue("@SubjectId", subjectId);
            cmd.Parameters.AddWithValue("@InstId", _instituteId);

            DataTable dt = dl.GetDataTable(cmd);
            return Convert.ToInt32(dt.Rows[0][0]) > 0;
        }
    }
}