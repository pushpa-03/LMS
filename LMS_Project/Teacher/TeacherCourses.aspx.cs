using System;
using System.Data;
using System.Data.SqlClient;

namespace LMS_Project.Teacher
{
    public partial class TeacherCourses : System.Web.UI.Page
    {
        DataLayer dl = new DataLayer();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadCourses();
            }
        }

        private void LoadCourses()
        {
            if (Session["UserId"] == null || Session["InstituteId"] == null)
            {
                Response.Redirect("../Default.aspx");
                return;
            }

            int teacherUserId = Convert.ToInt32(Session["UserId"]);
            int instituteId = Convert.ToInt32(Session["InstituteId"]);

            SubjectFacultyBL bl = new SubjectFacultyBL();
            int sessionId = bl.GetCurrentSession(instituteId); // ✅ FIX

            SqlCommand cmd = new SqlCommand(@"
    SELECT 
        S.SubjectId,
        S.SubjectName,
        ISNULL(S.SubjectCode, '') AS SubjectCode,
        ISNULL(S.Duration, '')    AS Duration,
        ISNULL(SEC.SectionName, '') AS SectionName,
        ASY.SessionName
    FROM SubjectFaculty SF
    INNER JOIN Subjects S ON SF.SubjectId = S.SubjectId
    LEFT JOIN Sections SEC ON SF.SectionId = SEC.SectionId
    INNER JOIN AcademicSessions ASY ON SF.SessionId = ASY.SessionId
    WHERE SF.TeacherId = @UserId
    AND SF.InstituteId = @InstituteId
    AND SF.SessionId = @SessionId
    AND ISNULL(SF.IsActive, 1) = 1
    ");

            cmd.Parameters.AddWithValue("@UserId", teacherUserId);
            cmd.Parameters.AddWithValue("@InstituteId", instituteId);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);

            DataTable dt = dl.GetDataTable(cmd);

            if (dt.Rows.Count > 0)
            {
                rptCourses.DataSource = dt;
                rptCourses.DataBind();
                lblSubjectCount.Text = dt.Rows.Count.ToString(); // ← ADD THIS LINE

                pnlCourses.Visible = true;
                pnlEmpty.Visible = false;
            }
            else
            {
                pnlCourses.Visible = false;
                pnlEmpty.Visible = true;
            }
        }
    }
}