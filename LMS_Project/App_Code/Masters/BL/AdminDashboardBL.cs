using LearningManagementSystem.GC;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using static System.Collections.Specialized.BitVector32;

namespace LearningManagementSystem.BL
{
    public class AdminDashboardBL
    {
        DataLayer dl = new DataLayer();
               
        public DataTable GetCounts(int instituteId, int sessionId)
        {
            SqlCommand cmd = new SqlCommand();

            cmd.CommandText = @"
        SELECT 
        -- Students
        (SELECT COUNT(*) 
         FROM StudentAcademicDetails 
         WHERE InstituteId = @InstituteId 
         AND SessionId = @SessionId) AS Students,

        -- Teachers (no session table, so no session filter OR use mapping if exists)
        (SELECT COUNT(*) 
         FROM Users 
         WHERE InstituteId = @InstituteId AND SessionId = @SessionId
         AND RoleId = (SELECT RoleId FROM Roles WHERE RoleName = 'Teacher')) AS Teachers,

        -- Subjects (via mapping table)
        (SELECT COUNT(DISTINCT SubjectId) 
         FROM LevelSemesterSubjects 
         WHERE InstituteId = @InstituteId 
         AND SessionId = @SessionId) AS Subjects,

        -- Courses (via mapping table)
        (SELECT COUNT(DISTINCT CourseId) 
         FROM LevelSemesterSubjects 
         WHERE InstituteId = @InstituteId 
         AND SessionId = @SessionId) AS Courses
    ";

            cmd.Parameters.AddWithValue("@InstituteId", instituteId);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);

            return dl.GetDataTable(cmd);
        }


        public DataTable GetTeacherStats(int instituteId, int sessionId, int courseId, int semesterId, int sectionId)
        {
            SqlCommand cmd = new SqlCommand(@"
            SELECT u.Username AS TeacherName, COUNT(tc.SubjectId) AS Subjects

            FROM Users u

            LEFT JOIN TeacherCourses tc 
                ON u.UserId = tc.TeacherId 
                AND tc.SessionId = @SessionId

            LEFT JOIN StudentAcademicDetails s 
                ON s.CourseId = tc.CourseId
                AND s.SessionId = @SessionId

            WHERE u.InstituteId=@InstituteId
            AND u.RoleId = (SELECT RoleId FROM Roles WHERE RoleName = 'Teacher')

            AND (@CourseId = 0 OR s.CourseId = @CourseId)
            AND (@SemesterId = 0 OR s.SemesterId = @SemesterId)
            AND (@SectionId = 0 OR s.SectionId = @SectionId)

            GROUP BY u.Username
            ");

            cmd.Parameters.AddWithValue("@InstituteId", instituteId);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);
            cmd.Parameters.AddWithValue("@CourseId", courseId);
            cmd.Parameters.AddWithValue("@SemesterId", semesterId);
            cmd.Parameters.AddWithValue("@SectionId", sectionId);

            return dl.GetDataTable(cmd);
        }
        

        public DataTable GetStudentProgress(int instituteId, int sessionId)
        {
            SqlCommand cmd = new SqlCommand(@"
            SELECT TOP 10 
                u.Username AS StudentName,
                CAST(AVG(CASE WHEN vv.IsCompleted=1 THEN 100 ELSE 0 END) AS INT) AS Progress
            FROM Users u
            LEFT JOIN VideoViews vv 
            ON u.UserId = vv.UserId 
            AND vv.SessionId = @SessionId
            WHERE u.InstituteId=@InstituteId AND vv.SessionId = @SessionId
            GROUP BY u.Username
            ");

            cmd.Parameters.AddWithValue("@InstituteId", instituteId);
            cmd.Parameters.AddWithValue("@SessionId", sessionId); // ✅ REQUIRED

            return dl.GetDataTable(cmd);
        }

        public DataTable GetAttendanceStats(int instituteId, int sessionId, int courseId, int semesterId, int sectionId)
        {
            SqlCommand cmd = new SqlCommand(@"
            SELECT 
                SUM(CASE WHEN a.Status='Present' THEN 1 ELSE 0 END) AS Present,
                SUM(CASE WHEN a.Status='Absent' THEN 1 ELSE 0 END) AS Absent,
                SUM(CASE WHEN a.Status='Leave' THEN 1 ELSE 0 END) AS Leave

            FROM Attendance a

            INNER JOIN StudentAcademicDetails s 
                ON a.UserId = s.UserId   -- ✅ FIXED HERE
                AND s.SessionId = @SessionId

            WHERE a.InstituteId=@InstituteId
            AND a.SessionId=@SessionId

            AND (@CourseId = 0 OR s.CourseId = @CourseId)
            AND (@SemesterId = 0 OR s.SemesterId = @SemesterId)
            AND (@SectionId = 0 OR s.SectionId = @SectionId)
            ");

            cmd.Parameters.AddWithValue("@InstituteId", instituteId);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);
            cmd.Parameters.AddWithValue("@CourseId", courseId);
            cmd.Parameters.AddWithValue("@SemesterId", semesterId);
            cmd.Parameters.AddWithValue("@SectionId", sectionId);

            return dl.GetDataTable(cmd);
        }

        public DataTable GetCoursePopularity(int instituteId, int sessionId, int courseId, int semesterId, int sectionId)
        {
            SqlCommand cmd = new SqlCommand(@"
            SELECT TOP 6 c.CourseName, COUNT(s.UserId) AS Total
            FROM StudentAcademicDetails s
            JOIN Courses c ON s.CourseId = c.CourseId
           WHERE s.InstituteId=@InstituteId 
            AND s.SessionId=@SessionId

            AND (@CourseId = 0 OR s.CourseId = @CourseId)
            AND (@SemesterId = 0 OR s.SemesterId = @SemesterId)
            AND (@SectionId = 0 OR s.SectionId = @SectionId)
            GROUP BY c.CourseName
            ORDER BY Total DESC
            ");

            cmd.Parameters.AddWithValue("@InstituteId", instituteId);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);
            cmd.Parameters.AddWithValue("@CourseId", courseId);
            cmd.Parameters.AddWithValue("@SemesterId", semesterId);
            cmd.Parameters.AddWithValue("@SectionId", sectionId);

            return dl.GetDataTable(cmd);
        }

        public DataTable GetEnrollmentTrend(int instituteId, int sessionId, int courseId, int semesterId, int sectionId)
        {
            SqlCommand cmd = new SqlCommand(@"
            SELECT 
                FORMAT(s.JoinedOn,'MMM') AS Month, 
                COUNT(*) AS Total

            FROM StudentAcademicDetails s

            WHERE s.InstituteId=@InstituteId 
            AND s.SessionId=@SessionId

            AND (@CourseId = 0 OR s.CourseId = @CourseId)
            AND (@SemesterId = 0 OR s.SemesterId = @SemesterId)
            AND (@SectionId = 0 OR s.SectionId = @SectionId)

            GROUP BY FORMAT(s.JoinedOn,'MMM'), MONTH(s.JoinedOn)
            ORDER BY MONTH(s.JoinedOn)
            ");

            cmd.Parameters.AddWithValue("@InstituteId", instituteId);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);
            cmd.Parameters.AddWithValue("@CourseId", courseId);
            cmd.Parameters.AddWithValue("@SemesterId", semesterId);
            cmd.Parameters.AddWithValue("@SectionId", sectionId);

            return dl.GetDataTable(cmd);
        }


        public DataTable GetEngagementKPI(int instituteId, int sessionId)
        {
            SqlCommand cmd = new SqlCommand(@"
            SELECT 
                ISNULL(COUNT(*),0) AS Views,

                ISNULL(COUNT(DISTINCT UserId),0) AS Users,

                ISNULL(CAST(AVG(CASE WHEN IsCompleted=1 THEN 100 ELSE 0 END) AS INT),0) AS Completed,

                ISNULL(CAST(COUNT(*) * 1.0 / NULLIF(COUNT(DISTINCT UserId),0) AS INT),0) AS AvgTime

            FROM VideoViews
            WHERE InstituteId=@InstituteId AND SessionId=@SessionId
            ");

            cmd.Parameters.AddWithValue("@InstituteId", instituteId);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);

            return dl.GetDataTable(cmd);
        }

        // ===== TREND =====
        public DataTable GetEngagementTrend(int instituteId, int sessionId)
        {
            SqlCommand cmd = new SqlCommand(@"
            SELECT FORMAT(ViewedOn,'dd MMM') AS Day, COUNT(*) AS Total
            FROM VideoViews
            WHERE InstituteId=@InstituteId AND SessionId=@SessionId
            GROUP BY FORMAT(ViewedOn,'dd MMM'), CAST(ViewedOn AS DATE)
            ORDER BY CAST(ViewedOn AS DATE)
            ");

            cmd.Parameters.AddWithValue("@InstituteId", instituteId);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);

            return dl.GetDataTable(cmd);
        }

        // ===== TOP STUDENTS =====
        public DataTable GetTopStudents(int instituteId, int sessionId)
        {
            SqlCommand cmd = new SqlCommand(@"
            SELECT TOP 5 u.Username, COUNT(v.ViewId) AS Views
            FROM VideoViews v
            JOIN Users u ON v.UserId = u.UserId
            WHERE v.InstituteId=@InstituteId AND v.SessionId=@SessionId
            GROUP BY u.Username
            ORDER BY Views DESC
            ");

            cmd.Parameters.AddWithValue("@InstituteId", instituteId);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);

            return dl.GetDataTable(cmd);
        }

        // ===== SUBJECT ENGAGEMENT =====
        public DataTable GetSubjectEngagement(int instituteId, int sessionId)
        {
            SqlCommand cmd = new SqlCommand(@"
            SELECT s.SubjectName, COUNT(v.ViewId) AS Total
            FROM VideoViews v
            INNER JOIN Videos vid ON v.VideoId = vid.VideoId
            INNER JOIN Chapters c ON vid.ChapterId = c.ChapterId
            INNER JOIN Subjects s ON c.SubjectId = s.SubjectId
            WHERE v.InstituteId = @InstituteId 
              AND v.SessionId = @SessionId
            GROUP BY s.SubjectName
            ORDER BY Total DESC
            ");

            cmd.Parameters.AddWithValue("@InstituteId", instituteId);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);

            return dl.GetDataTable(cmd);
        }

        public DataTable GetAdminKPI(int instituteId, int sessionId)
        {
            SqlCommand cmd = new SqlCommand(@"
               SELECT 
                COUNT(DISTINCT a.AssignmentId) AS TotalAssignments,

                COUNT(DISTINCT s.SubmissionId) AS Submitted,

                COUNT(DISTINCT a.AssignmentId) - COUNT(DISTINCT s.SubmissionId) AS Pending,

                ISNULL(AVG(q.Score),0) AS AvgScore

            FROM Assignments a
            LEFT JOIN AssignmentSubmissions s 
                ON a.AssignmentId = s.AssignmentId
                AND s.SessionId = @SessionId

            LEFT JOIN QuizResults q 
                ON q.SessionId = @SessionId

            WHERE a.InstituteId = @InstituteId
            AND a.SessionId = @SessionId
    ");

            cmd.Parameters.AddWithValue("@InstituteId", instituteId);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);

            return dl.GetDataTable(cmd);
        }

        public DataTable GetLowPerformingStudents(int instituteId, int sessionId, int courseId, int semesterId, int sectionId)
        {
            SqlCommand cmd = new SqlCommand(@"
            SELECT TOP 20
                u.Username,
                ISNULL(AVG(q.Score),0) AS AvgScore

            FROM Users u

            INNER JOIN StudentAcademicDetails s 
                ON u.UserId = s.UserId
                AND s.SessionId = @SessionId

            LEFT JOIN QuizResults q 
                ON u.UserId = q.StudentId
                AND q.SessionId = @SessionId

            WHERE u.InstituteId = @InstituteId

            AND (@CourseId = 0 OR s.CourseId = @CourseId)
            AND (@SemesterId = 0 OR s.SemesterId = @SemesterId)
            AND (@SectionId = 0 OR s.SectionId = @SectionId)

            GROUP BY u.Username
            HAVING ISNULL(AVG(q.Score),0) < 40

            ORDER BY AvgScore ASC
");

            cmd.Parameters.AddWithValue("@InstituteId", instituteId);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);

            // 🔥 THIS WAS MISSING
            cmd.Parameters.AddWithValue("@CourseId", courseId);
            cmd.Parameters.AddWithValue("@SemesterId", semesterId);
            cmd.Parameters.AddWithValue("@SectionId", sectionId);

            return dl.GetDataTable(cmd);
        }

        public DataTable GetFacultyLoad(int instituteId, int sessionId)
        {
            SqlCommand cmd = new SqlCommand(@"
            SELECT 
            u.Username,
            COUNT(tc.SubjectId) AS Subjects

            FROM Users u

            LEFT JOIN TeacherCourses tc 
                ON u.UserId = tc.TeacherId
                AND tc.SessionId = @SessionId

            WHERE u.InstituteId = @InstituteId
            AND u.RoleId = (SELECT RoleId FROM Roles WHERE RoleName = 'Teacher')

            GROUP BY u.Username
            ");

            cmd.Parameters.AddWithValue("@InstituteId", instituteId);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);

            return dl.GetDataTable(cmd);
        }

        public DataTable GetRecentActivity(int instituteId, int sessionId)
        {
            SqlCommand cmd = new SqlCommand(@"
            SELECT TOP 10 
                ActivityType,
                ActionTime,
                CASE 
                    WHEN ActivityType = 'StudentAdded' THEN 'fas fa-user-plus'
                    WHEN ActivityType = 'SubjectAssigned' THEN 'fas fa-book'
                    WHEN ActivityType = 'CourseUpdated' THEN 'fas fa-layer-group'
                    ELSE 'fas fa-bell'
                END AS Icon,

                CASE 
                    WHEN ActivityType = 'StudentAdded' THEN 'New student registered'
                    WHEN ActivityType = 'SubjectAssigned' THEN 'Subject assigned to teacher'
                    WHEN ActivityType = 'CourseUpdated' THEN 'Course updated'
                    ELSE ActivityType
                END AS Message

            FROM UserActivityLog
            WHERE InstituteId=@InstituteId AND SessionId=@SessionId
            ORDER BY ActionTime DESC
            ");

            cmd.Parameters.AddWithValue("@InstituteId", instituteId);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);

            return dl.GetDataTable(cmd);
        }

        public DataTable GetRecentActivity(
        int instituteId,
        int sessionId,
        DateTime? fromDate,
        DateTime? toDate,
        int courseId,
        int subjectId)
        {
            SqlCommand cmd = new SqlCommand(@"
            SELECT TOP 10 
                ActivityType,
                ActionTime,
                CASE 
                    WHEN ActivityType = 'StudentAdded' THEN 'fas fa-user-plus'
                    WHEN ActivityType = 'SubjectAssigned' THEN 'fas fa-book'
                    WHEN ActivityType = 'CourseUpdated' THEN 'fas fa-layer-group'
                    ELSE 'fas fa-bell'
                END AS Icon,

                CASE 
                    WHEN ActivityType = 'StudentAdded' THEN 'New student registered'
                    WHEN ActivityType = 'SubjectAssigned' THEN 'Subject assigned to teacher'
                    WHEN ActivityType = 'CourseUpdated' THEN 'Course updated'
                    ELSE ActivityType
                END AS Message

            FROM UserActivityLog
            WHERE InstituteId=@InstituteId 
            AND SessionId=@SessionId

            AND (@FromDate IS NULL OR ActionTime >= @FromDate)
            AND (@ToDate IS NULL OR ActionTime <= @ToDate)

            ORDER BY ActionTime DESC
            ");

            cmd.Parameters.AddWithValue("@InstituteId", instituteId);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);
            cmd.Parameters.AddWithValue("@FromDate", (object)fromDate ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@ToDate", (object)toDate ?? DBNull.Value);

            return dl.GetDataTable(cmd);
        }

        public DataTable GetAlerts(int instituteId, int sessionId)
        {
            SqlCommand cmd = new SqlCommand(@"
            SELECT TOP 5 
                'Low attendance in ' + c.CourseName AS Message
            FROM Attendance a
            JOIN StudentAcademicDetails s ON a.UserId = s.UserId
            JOIN Courses c ON s.CourseId = c.CourseId
            WHERE a.Status='Absent'
            GROUP BY c.CourseName
            HAVING COUNT(*) > 10
            ");

            return dl.GetDataTable(cmd);
        }

        public DataTable GetDropoutTrend(int instituteId, int sessionId)
        {
            SqlCommand cmd = new SqlCommand(@"
            SELECT FORMAT(JoinedOn,'MMM') Month, COUNT(*) Total
            FROM StudentAcademicDetails
            WHERE IsActive = 0
            GROUP BY FORMAT(JoinedOn,'MMM'), MONTH(JoinedOn)
            ORDER BY MONTH(JoinedOn)
            ");

            return dl.GetDataTable(cmd);
        }

        public object GetAttendanceDashboard(string from, string to, string streamId, string courseId, string subjectId)
        {
            SqlCommand cmd = new SqlCommand(@"
DECLARE @FromDate DATE = @from
DECLARE @ToDate DATE = @to

SELECT 
    SUM(CASE WHEN A.Status='Present' THEN 1 ELSE 0 END) Present,
    SUM(CASE WHEN A.Status='Absent' THEN 1 ELSE 0 END) Absent
FROM Attendance A
INNER JOIN Users U ON U.UserId = A.UserId AND U.IsActive = 1
INNER JOIN Subjects S ON S.SubjectId = A.SubjectId AND S.IsActive = 1
INNER JOIN StudentAcademicDetails SAD ON SAD.UserId = U.UserId
WHERE A.Date BETWEEN @FromDate AND @ToDate
AND (@streamId='0' OR SAD.StreamId = @streamId)
AND (@courseId='0' OR SAD.CourseId = @courseId)
AND (@subjectId='0' OR A.SubjectId = @subjectId)
");

            cmd.Parameters.AddWithValue("@from", from);
            cmd.Parameters.AddWithValue("@to", to);
            cmd.Parameters.AddWithValue("@streamId", streamId);
            cmd.Parameters.AddWithValue("@courseId", courseId);
            cmd.Parameters.AddWithValue("@subjectId", subjectId);

            DataTable dt = dl.GetDataTable(cmd);

            int present = dt.Rows[0]["Present"] == DBNull.Value ? 0 : Convert.ToInt32(dt.Rows[0]["Present"]);
            int absent = dt.Rows[0]["Absent"] == DBNull.Value ? 0 : Convert.ToInt32(dt.Rows[0]["Absent"]);
            int total = present + absent;

            double percentage = total == 0 ? 0 : (present * 100.0 / total);

            // 📈 TREND DATA
            SqlCommand trendCmd = new SqlCommand(@"
SELECT 
    FORMAT(A.Date,'dd-MM') d,
    (SUM(CASE WHEN A.Status='Present' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) Attendance
FROM Attendance A
INNER JOIN StudentAcademicDetails SAD ON SAD.UserId = A.UserId
WHERE A.Date BETWEEN @FromDate AND @ToDate
AND (@streamId='0' OR SAD.StreamId = @streamId)
GROUP BY A.Date
ORDER BY A.Date
");

            trendCmd.Parameters.AddWithValue("@FromDate", from);
            trendCmd.Parameters.AddWithValue("@ToDate", to);
            trendCmd.Parameters.AddWithValue("@streamId", streamId);

            DataTable trendDt = dl.GetDataTable(trendCmd);

            List<string> dates = new List<string>();
            List<double> trendData = new List<double>();

            foreach (DataRow row in trendDt.Rows)
            {
                dates.Add(row["d"].ToString());
                trendData.Add(Convert.ToDouble(row["Attendance"]));
            }

            // 🔻 PREVIOUS PERIOD TREND
            SqlCommand prevCmd = new SqlCommand(@"
SELECT 
    (SUM(CASE WHEN Status='Present' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) Attendance
FROM Attendance
WHERE Date BETWEEN DATEADD(DAY,-DATEDIFF(DAY,@from,@to),@from) AND @from
");

            prevCmd.Parameters.AddWithValue("@from", from);
            prevCmd.Parameters.AddWithValue("@to", to);

            double prev = 0;
            var prevDt = dl.GetDataTable(prevCmd);
            if (prevDt.Rows.Count > 0 && prevDt.Rows[0][0] != DBNull.Value)
                prev = Convert.ToDouble(prevDt.Rows[0][0]);

            double trendPercent = prev == 0 ? 0 : ((percentage - prev) / prev) * 100;

            // 🚨 LOW ATTENDANCE STUDENTS
            SqlCommand lowCmd = new SqlCommand(@"
SELECT COUNT(*) 
FROM (
    SELECT A.UserId,
    (SUM(CASE WHEN Status='Present' THEN 1 ELSE 0 END)*100.0 / COUNT(*)) Att
    FROM Attendance A
    GROUP BY A.UserId
    HAVING (SUM(CASE WHEN Status='Present' THEN 1 ELSE 0 END)*100.0 / COUNT(*)) < 75
) X
");

            int lowCount = Convert.ToInt32(dl.GetDataTable(lowCmd).Rows[0][0]);

            return new
            {
                Attendance = Math.Round(percentage, 2),
                Present = present,
                Absent = absent,
                Trend = Math.Round(trendPercent, 2),
                Dates = dates,
                TrendData = trendData,
                LowAttendance = lowCount
            };
        }

        public DataTable GetStreamWise(string from, string to)
        {
            SqlCommand cmd = new SqlCommand(@"
SELECT 
    ST.StreamName,
    (SUM(CASE WHEN A.Status='Present' THEN 1 ELSE 0 END)*100.0 / COUNT(*)) Attendance
FROM Attendance A
INNER JOIN StudentAcademicDetails SAD ON SAD.UserId = A.UserId
INNER JOIN Streams ST ON ST.StreamId = SAD.StreamId AND ST.IsActive = 1
WHERE A.Date BETWEEN @from AND @to
GROUP BY ST.StreamName
");

            cmd.Parameters.AddWithValue("@from", from);
            cmd.Parameters.AddWithValue("@to", to);

            return dl.GetDataTable(cmd);
        }


        public DataTable GetStreams()
        {
            SqlCommand cmd = new SqlCommand(@"
    SELECT StreamId, StreamName 
    FROM Streams 
    WHERE IsActive = 1
    ORDER BY StreamName
    ");

            return dl.GetDataTable(cmd);
        }

        public DataTable GetCourses(string streamId)
        {
            SqlCommand cmd = new SqlCommand(@"
    SELECT CourseId, CourseName 
    FROM Courses 
    WHERE IsActive = 1
    AND (@streamId = '0' OR StreamId = @streamId)
    ORDER BY CourseName
    ");

            cmd.Parameters.AddWithValue("@streamId", streamId);

            return dl.GetDataTable(cmd);
        }

        public DataTable GetSubjects(string courseId)
        {
            SqlCommand cmd = new SqlCommand(@"
    SELECT DISTINCT S.SubjectId, S.SubjectName
    FROM Subjects S
    INNER JOIN AssignStudentSubject ASS 
        ON ASS.SubjectId = S.SubjectId
    INNER JOIN StudentAcademicDetails SAD 
        ON SAD.UserId = ASS.UserId
    WHERE S.IsActive = 1
    AND (@courseId = '0' OR SAD.CourseId = @courseId)
    ORDER BY S.SubjectName
    ");

            cmd.Parameters.AddWithValue("@courseId", courseId);

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