using System;
using System.Data;
using System.Data.SqlClient;
using LearningManagementSystem.GC;

namespace LearningManagementSystem.BL
{
    public class CourseBL
    {
        DataLayer dl = new DataLayer();

        // ================= STREAM LIST =================
        public DataTable GetStreams(int instituteId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT StreamId, StreamName
                FROM Streams
                WHERE InstituteId=@InstId AND IsActive=1");

            cmd.Parameters.AddWithValue("@InstId", instituteId);

            return dl.GetDataTable(cmd);
        }

        // ================= COURSE LIST =================
        public DataTable GetCourses(int instituteId, string status = "All")
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT C.CourseId,
                       S.StreamName,
                       C.CourseName,
                       C.CourseCode,
                       C.IsActive
                FROM Courses C
                JOIN Streams S ON S.StreamId = C.StreamId
                WHERE C.InstituteId=@InstId");

            cmd.Parameters.AddWithValue("@InstId", instituteId);

            if (status != "All")
            {
                cmd.CommandText += " AND C.IsActive=@Status";
                cmd.Parameters.AddWithValue("@Status", status == "1");
            }

            return dl.GetDataTable(cmd);
        }

        // ================= INSERT =================
        public void Insert(CourseGC c)
        {
            SqlCommand cmd = new SqlCommand(@"
                INSERT INTO Courses
                (SocietyId, InstituteId, StreamId, CourseName, CourseCode, IsActive)
                VALUES (@S,@I,@St,@N,@C,1)");

            cmd.Parameters.AddWithValue("@S", c.SocietyId);
            cmd.Parameters.AddWithValue("@I", c.InstituteId);
            cmd.Parameters.AddWithValue("@St", c.StreamId);
            cmd.Parameters.AddWithValue("@N", c.CourseName);
            cmd.Parameters.AddWithValue("@C", c.CourseCode);

            dl.ExecuteCMD(cmd);
        }

        // ================= UPDATE =================
        public void Update(CourseGC c)
        {
            SqlCommand cmd = new SqlCommand(@"
                UPDATE Courses
                SET StreamId=@St,
                    CourseName=@N,
                    CourseCode=@C
                WHERE CourseId=@Id AND InstituteId=@InstId");

            cmd.Parameters.AddWithValue("@St", c.StreamId);
            cmd.Parameters.AddWithValue("@N", c.CourseName);
            cmd.Parameters.AddWithValue("@C", c.CourseCode);
            cmd.Parameters.AddWithValue("@Id", c.CourseId);
            cmd.Parameters.AddWithValue("@InstId", c.InstituteId);

            dl.ExecuteCMD(cmd);
        }

        // ================= TOGGLE =================
        public void Toggle(int id, int instituteId)
        {
            SqlCommand cmd = new SqlCommand(@"
                UPDATE Courses
                SET IsActive = 1 - IsActive
                WHERE CourseId=@Id AND InstituteId=@InstId");

            cmd.Parameters.AddWithValue("@Id", id);
            cmd.Parameters.AddWithValue("@InstId", instituteId);

            dl.ExecuteCMD(cmd);
        }

        // ================= DELETE =================
        public void Delete(int id, int instituteId)
        {
            SqlCommand cmd = new SqlCommand(@"
                DELETE FROM Courses
                WHERE CourseId=@Id AND InstituteId=@InstId");

            cmd.Parameters.AddWithValue("@Id", id);
            cmd.Parameters.AddWithValue("@InstId", instituteId);

            dl.ExecuteCMD(cmd);
        }

        // ================= GET BY ID =================
        public DataTable GetById(int id, int instituteId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT * FROM Courses
                WHERE CourseId=@Id AND InstituteId=@InstId");

            cmd.Parameters.AddWithValue("@Id", id);
            cmd.Parameters.AddWithValue("@InstId", instituteId);

            return dl.GetDataTable(cmd);
        }
    }
}