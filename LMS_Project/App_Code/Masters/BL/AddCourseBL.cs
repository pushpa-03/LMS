using LearningManagementSystem.GC;
using System;
//using System.Activities.Statements;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Web.Services.Description;

namespace LearningManagementSystem.BL
{
    public class CourseBL
    {
        DataLayer dl = new DataLayer();

        // ================= STREAM LIST =================
        public DataTable GetStreams(int instituteId, int sessionId)
        {
            SqlCommand cmd = new SqlCommand(@"
        SELECT StreamId, StreamName
        FROM Streams
        WHERE InstituteId=@InstId 
        AND SessionId=@SessionId
        AND IsActive=1");

            cmd.Parameters.AddWithValue("@InstId", instituteId);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);

            return dl.GetDataTable(cmd);
        }

        // ================= COURSE LIST =================
        public DataTable GetCourses(int instituteId, int sessionId, string status = "All")
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT 
                    C.CourseId,
                    C.CourseName,
                    C.CourseCode,
                    C.StreamId,
                    S.StreamName,
                    C.IsActive
                FROM Courses C
                INNER JOIN Streams S ON C.StreamId = S.StreamId
                WHERE C.InstituteId = @InstituteId
                AND C.SessionId = @SessionId
            ");

            cmd.Parameters.AddWithValue("@InstituteId", instituteId);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);

            if (status != "All")
            {
                cmd.CommandText += " AND C.IsActive = @Status";
                cmd.Parameters.AddWithValue("@Status", status == "1");
            }

            cmd.CommandText += " ORDER BY S.StreamName, C.CourseName";

            return dl.GetDataTable(cmd);
        }

        // ================= INSERT =================
        public void Insert(CourseGC c)
        {
            SqlCommand cmd = new SqlCommand(@"
                INSERT INTO Courses
                (SocietyId, InstituteId, SessionId, StreamId, CourseName, CourseCode, IsActive)
                VALUES (@S,@I,@SessionId,@St,@N,@C,1)");

            cmd.Parameters.AddWithValue("@S", c.SocietyId);
            cmd.Parameters.AddWithValue("@I", c.InstituteId);
            cmd.Parameters.AddWithValue("@SessionId", c.SessionId);
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
                WHERE CourseId=@Id AND InstituteId=@InstId  AND SessionId = @SessionId");

            cmd.Parameters.AddWithValue("@St", c.StreamId);
            cmd.Parameters.AddWithValue("@N", c.CourseName);
            cmd.Parameters.AddWithValue("@C", c.CourseCode);
            cmd.Parameters.AddWithValue("@Id", c.CourseId);
            cmd.Parameters.AddWithValue("@InstId", c.InstituteId);
            cmd.Parameters.AddWithValue("@SessionId", c.SessionId);

            dl.ExecuteCMD(cmd);
        }

        // ================= TOGGLE =================
        public void Toggle(int id, int instituteId, int SessionId)
        {
            SqlCommand cmd = new SqlCommand(@"
                UPDATE Courses
                SET IsActive = 1 - IsActive
                WHERE CourseId=@Id AND InstituteId=@InstId  AND SessionId = @SessionId");

            cmd.Parameters.AddWithValue("@Id", id);
            cmd.Parameters.AddWithValue("@InstId", instituteId);
            cmd.Parameters.AddWithValue("@SessionId", SessionId);

            dl.ExecuteCMD(cmd);
        }

        // ================= DELETE =================
        public bool Delete(int id, int instituteId,int SessionId, out string message)
        {
            try
            {
                SqlCommand cmd = new SqlCommand(@"
                DELETE FROM Courses
                WHERE CourseId=@Id AND InstituteId=@InstId  AND SessionId = @SessionId");

                cmd.Parameters.AddWithValue("@Id", id);
                cmd.Parameters.AddWithValue("@InstId", instituteId);
                cmd.Parameters.AddWithValue("@SessionId", SessionId);

                dl.ExecuteCMD(cmd);

                message = "Course deleted successfully.";
                return true;
            }

            catch (SqlException ex)
            {
                // FK constraint error number = 547
                if (ex.Number == 547)
                {
                    message = "This Course is already used. You can deactivate it instead.";
                    return false;
                }

                throw; // other errors
            }

        }

        // ================= GET BY ID =================
        public DataTable GetById(int id, int instituteId, int SessionId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT * FROM Courses
                WHERE CourseId=@Id AND InstituteId=@InstId  AND SessionId = @SessionId");

            cmd.Parameters.AddWithValue("@Id", id);
            cmd.Parameters.AddWithValue("@InstId", instituteId);
            cmd.Parameters.AddWithValue("@SessionId", SessionId);

            return dl.GetDataTable(cmd);
        }

        public bool IsCourseExists(int instituteId, int sessionId, int streamId, string name, int id = 0)
        {
            SqlCommand cmd = new SqlCommand(@"
        SELECT COUNT(*) AS Total FROM Courses
        WHERE InstituteId=@I AND SessionId=@S AND StreamId=@St
        AND LOWER(CourseName)=LOWER(@N)
        AND (@Id=0 OR CourseId<>@Id)");

            cmd.Parameters.AddWithValue("@I", instituteId);
            cmd.Parameters.AddWithValue("@S", sessionId);
            cmd.Parameters.AddWithValue("@St", streamId);
            cmd.Parameters.AddWithValue("@N", name);
            cmd.Parameters.AddWithValue("@Id", id);

            DataTable dt = dl.GetDataTable(cmd);

            if (dt != null && dt.Rows.Count > 0)
                return Convert.ToInt32(dt.Rows[0]["Total"]) > 0;

            return false;
        }

        internal void CopyAllCoursesToNextSession(int instituteId, int currentSessionId)
        {
            int nextSessionId = currentSessionId + 1; // or fetch from DB properly

            SqlCommand cmd = new SqlCommand(@"
            INSERT INTO Courses(SocietyId, InstituteId, SessionId, StreamId, CourseName, CourseCode, IsActive)
            SELECT SocietyId, InstituteId, @NextSessionId, StreamId, CourseName, CourseCode, 1
            FROM Courses
            WHERE SessionId = @CurrentSessionId
            AND InstituteId=@InstituteId
            AND NOT EXISTS (
                SELECT 1 FROM Courses C2
                WHERE C2.SessionId=@NextSessionId
                AND C2.CourseName = Courses.CourseName
                AND C2.StreamId = Courses.StreamId
                AND C2.InstituteId=@InstituteId
            )");

            cmd.Parameters.AddWithValue("@NextSessionId", nextSessionId);
            cmd.Parameters.AddWithValue("@CurrentSessionId", currentSessionId);
            cmd.Parameters.AddWithValue("@InstituteId", instituteId);

            dl.ExecuteCMD(cmd);
        }


    }
}