using System.Data;
using System.Data.SqlClient;
using LearningManagementSystem.GC;

namespace LearningManagementSystem.BL
{
    public class AdminDashboardBL
    {
        DataLayer dl = new DataLayer();

        public DataTable GetCounts(int instituteId, int sessionId)
        {
            SqlCommand cmd = new SqlCommand(@"
            SELECT 
            (SELECT COUNT(*) FROM Users WHERE RoleId = 4 AND InstituteId=@InstituteId and IsActive = '1') AS Students,
            (SELECT COUNT(*) FROM Users WHERE RoleId = 3 AND InstituteId=@InstituteId and IsActive = '1') AS Teachers,
            (SELECT COUNT(*) FROM Subjects WHERE InstituteId=@InstituteId and IsActive = '1') AS Subjects,
            (SELECT COUNT(*) FROM Courses WHERE InstituteId=@InstituteId and IsActive = '1') AS Courses
            ");
            cmd.Parameters.AddWithValue("@InstituteId", instituteId);

            return dl.GetDataTable(cmd);
        }

        public DataTable GetTeacherStats(int instituteId, int sessionId)
        {
            SqlCommand cmd = new SqlCommand(@"
            SELECT u.Username AS TeacherName, COUNT(t.SubjectId) AS Subjects
            FROM Users u
            LEFT JOIN TeacherCourses t ON u.UserId = t.TeacherId
            WHERE u.InstituteId=@InstituteId AND t.SessionId=@SessionId
            GROUP BY u.Username
            ");
            cmd.Parameters.AddWithValue("@InstituteId", instituteId);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);

            return dl.GetDataTable(cmd);
        }

        public DataTable GetStudentProgress(int instituteId, int sessionId)
        {
            SqlCommand cmd = new SqlCommand(@"
            SELECT TOP 10 u.Username AS StudentName,
            CAST(AVG(CASE WHEN vv.IsCompleted=1 THEN 100 ELSE 0 END) AS INT) AS Progress
            FROM Users u
            LEFT JOIN VideoViews vv ON u.UserId = vv.UserId
            WHERE u.InstituteId=@InstituteId
            GROUP BY u.Username
            ");
            cmd.Parameters.AddWithValue("@InstituteId", instituteId);

            return dl.GetDataTable(cmd);
        }
    }
}

//-------------------------------------------------------------------------------------------------------------------------

//using System;
//using System.Data;
//using System.Data.SqlClient;
//using System.Collections.Generic;

//namespace LearningManagementSystem.BL
//{
//    public class AdminDashboardBL
//    {
//        // Using DataLayer directly as requested
//        DataLayer dl = new DataLayer();

//        public DataTable GetSessions(int instId)
//        {
//            string query = $"SELECT SessionId, SessionName, IsCurrent FROM AcademicSessions WHERE InstituteId = {instId} AND IsActive = 1";
//            SqlCommand cmd = new SqlCommand(query);

//            // Using DataLayer.GetDataTable(SqlCommand cmd)
//            return dl.GetDataTable(cmd);
//        }

//        public DataSet GetAdminDashboardStats(int instId, int sessId)
//        {
//            string query = $@"
//                SELECT 
//                    (SELECT COUNT(*) FROM StudentAcademicDetails WHERE InstituteId = {instId} AND SessionId = {sessId}) as StudentCount,
//                    (SELECT COUNT(*) FROM TeacherDetails WHERE InstituteId = {instId}) as TeacherCount,
//                    (SELECT COUNT(*) FROM Subjects WHERE InstituteId = {instId} AND IsActive = 1) as SubjectCount,
//                    (SELECT COUNT(*) FROM CalendarEvents WHERE InstituteId = {instId} AND EndTime >= GETDATE()) as EventCount";

//            SqlCommand cmd = new SqlCommand(query);

//            // Using DataLayer.ReturnDataSet(SqlCommand cmd)
//            return dl.ReturnDataSet(cmd);
//        }

//        public DataTable GetStudentProgressSummary(int instId, int sessId)
//        {
//            string query = $@"
//                SELECT TOP 5 P.FullName, S.RollNumber, C.CourseName, Sem.SemesterName, S.UserId,
//                ISNULL((SELECT (COUNT(CASE WHEN IsCompleted = 1 THEN 1 END) * 100) / NULLIF(COUNT(*), 0) 
//                        FROM VideoViews WHERE UserId = S.UserId), 0) as Completion
//                FROM StudentAcademicDetails S
//                JOIN UserProfile P ON S.UserId = P.UserId
//                JOIN Courses C ON S.CourseId = C.CourseId
//                JOIN Semesters Sem ON S.SemesterId = Sem.SemesterId
//                WHERE S.InstituteId = {instId} AND S.SessionId = {sessId}";

//            SqlCommand cmd = new SqlCommand(query);
//            return dl.GetDataTable(cmd);
//        }

//        public DataTable GetTeacherPerformanceSummary(int instId, int sessId)
//        {
//            string query = $@"
//                SELECT TOP 5 P.FullName, T.UserId,
//                (SELECT COUNT(*) FROM TeacherCourses WHERE TeacherId = T.UserId AND SessionId = {sessId}) as SubjectCount,
//                4.5 as Rating 
//                FROM TeacherDetails T
//                JOIN UserProfile P ON T.UserId = P.UserId
//                WHERE T.InstituteId = {instId}";

//            SqlCommand cmd = new SqlCommand(query);
//            return dl.GetDataTable(cmd);
//        }
//    }
//}