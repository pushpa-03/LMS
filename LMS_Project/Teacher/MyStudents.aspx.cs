using System;
using System.Data;
using System.Data.SqlClient;

namespace LMS_Project.Teacher
{
    public partial class MyStudents : System.Web.UI.Page
    {
        DataLayer dl = new DataLayer();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadStudents();
            }
        }

        private void LoadStudents()
        {
            if (Session["UserId"] == null)
            {
                Response.Redirect("../Default.aspx");
                return;
            }

            int teacherId = Convert.ToInt32(Session["UserId"]);
            int instituteId = Convert.ToInt32(Session["InstituteId"]);

            SqlCommand cmd = new SqlCommand(@"
                SELECT 
                    u.UserId,
                    up.FullName AS StudentName,
                    u.Email,
                    s.SubjectName,
                    sess.SessionName
                FROM SubjectFaculty sf

                INNER JOIN Subjects s 
                    ON sf.SubjectId = s.SubjectId

                INNER JOIN AssignStudentSubject ass
                    ON ass.SubjectId = sf.SubjectId
                    AND ass.SessionId = sf.SessionId

                INNER JOIN Users u
                    ON ass.UserId = u.UserId

                INNER JOIN UserProfile up
                    ON u.UserId = up.UserId

                INNER JOIN AcademicSessions sess
                    ON sf.SessionId = sess.SessionId

                WHERE sf.TeacherId = @TeacherId
                AND sf.InstituteId = @InstituteId
                AND u.RoleId = 4
            ");

            cmd.Parameters.AddWithValue("@TeacherId", teacherId);
            cmd.Parameters.AddWithValue("@InstituteId", instituteId);

            DataTable dt = dl.GetDataTable(cmd);

            gvStudents.DataSource = dt;
            gvStudents.DataBind();
        }
    }
}