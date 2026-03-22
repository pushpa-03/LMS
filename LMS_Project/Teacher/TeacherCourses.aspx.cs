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
            int sessionId = Session["CurrentSessionId"] != null
                            ? Convert.ToInt32(Session["CurrentSessionId"])
                            : 1;

            SqlCommand cmd = new SqlCommand(@"
SELECT 
    S.SubjectName,
    SEC.SectionName,
    ASY.SessionName

FROM SubjectFaculty SF

INNER JOIN Subjects S 
    ON SF.SubjectId = S.SubjectId

INNER JOIN Sections SEC 
    ON SF.SectionId = SEC.SectionId

INNER JOIN AcademicSessions ASY 
    ON SF.SessionId = ASY.SessionId

WHERE SF.TeacherId = @UserId
AND SF.InstituteId = @InstituteId
AND SF.SessionId = @SessionId
AND ISNULL(SF.IsActive,1) = 1
");

            cmd.Parameters.AddWithValue("@UserId", teacherUserId);
            cmd.Parameters.AddWithValue("@InstituteId", instituteId);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);

            DataTable dt = dl.GetDataTable(cmd);

            if (dt.Rows.Count > 0)
            {
                rptCourses.DataSource = dt;
                rptCourses.DataBind();

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