using System;
using System.Data;
using System.Data.SqlClient;

public class OverviewDashboardBL
{
    DataLayer dl = new DataLayer();

    public DataSet GetYearlyOverviewStats(int instituteId, int sessionId)
    {
        SqlCommand cmd = new SqlCommand(@"
                -- COUNTS
                SELECT 
                (SELECT COUNT(*) FROM Users u 
                 WHERE u.InstituteId=@InstituteId AND u.SessionId=@SessionId
                 AND u.RoleId=(SELECT RoleId FROM Roles WHERE RoleName='Student') 
                 AND ISNULL(u.IsActive,1)=1) AS TotalStudents,

                (SELECT COUNT(*) FROM Users u 
                 WHERE u.InstituteId=@InstituteId AND u.SessionId=@SessionId
                 AND u.RoleId=(SELECT RoleId FROM Roles WHERE RoleName='Teacher') 
                 AND ISNULL(u.IsActive,1)=1) AS TotalTeachers,

                (SELECT COUNT(*) FROM Streams 
                 WHERE InstituteId=@InstituteId AND SessionId=@SessionId AND ISNULL(IsActive,1)=1) AS TotalStreams,

                (SELECT COUNT(*) FROM Subjects 
                 WHERE InstituteId=@InstituteId AND SessionId=@SessionId AND ISNULL(IsActive,1)=1) AS TotalSubjects,

                (SELECT COUNT(*) FROM Chapters 
                 WHERE InstituteId=@InstituteId AND SessionId=@SessionId AND ISNULL(IsActive,1)=1) AS TotalChapters,

                (SELECT COUNT(*) FROM Courses 
                 WHERE InstituteId=@InstituteId AND SessionId=@SessionId AND ISNULL(IsActive,1)=1) AS TotalCourses,

                (SELECT COUNT(*) FROM Assignments 
                 WHERE InstituteId=@InstituteId AND SessionId=@SessionId AND ISNULL(IsActive,1)=1) AS TotalAssignments,

                (SELECT COUNT(*) FROM Videos 
                 WHERE InstituteId=@InstituteId AND SessionId=@SessionId AND ISNULL(IsActive,1)=1) AS TotalVideos,

                (SELECT COUNT(*) FROM Quizzes 
                 WHERE InstituteId=@InstituteId AND SessionId=@SessionId AND ISNULL(IsEnabled,1)=1) AS TotalQuizzes,

                (SELECT COUNT(*) FROM Sections 
                 WHERE InstituteId=@InstituteId AND SessionId=@SessionId AND ISNULL(IsActive,1)=1) AS TotalSections;


                -- MONTHLY STUDENTS
                SELECT 
                    DATENAME(MONTH, u.CreatedOn) AS Month,
                    MONTH(u.CreatedOn) AS MonthNum,
                    COUNT(*) AS NewStudents
                FROM Users u
                WHERE u.InstituteId=@InstituteId 
                  AND u.RoleId=(SELECT RoleId FROM Roles WHERE RoleName='Student')
                  AND YEAR(u.CreatedOn)=YEAR(GETDATE())
                GROUP BY DATENAME(MONTH, u.CreatedOn), MONTH(u.CreatedOn)
                ORDER BY MonthNum;


                -- TOP COURSES
                SELECT TOP 5
                    c.CourseName,
                    COUNT(sa.UserId) AS StudentCount
                FROM StudentAcademicDetails sa
                JOIN Courses c ON sa.CourseId=c.CourseId
                WHERE sa.InstituteId=@InstituteId AND sa.SessionId=@SessionId
                GROUP BY c.CourseName
                ORDER BY StudentCount DESC;


                -- ATTENDANCE
                SELECT 
                    ISNULL(
                        CAST(
                            100.0 * SUM(CASE WHEN Status='Present' THEN 1 ELSE 0 END) 
                            / NULLIF(COUNT(*),0)
                        AS DECIMAL(5,2))
                    ,0) AS OverallAttendance
                FROM Attendance
                WHERE InstituteId=@InstituteId AND SessionId=@SessionId;


                -- TOP SUBJECTS
                SELECT TOP 5 
                    s.SubjectName, 
                    COUNT(v.VideoId) AS VideoCount
                FROM Videos v
                JOIN Chapters c ON v.ChapterId = c.ChapterId
                JOIN Subjects s ON c.SubjectId = s.SubjectId
                WHERE v.InstituteId = @InstituteId 
                  AND v.SessionId = @SessionId
                GROUP BY s.SubjectName 
                ORDER BY VideoCount DESC;
                ");
        cmd.Parameters.AddWithValue("@InstituteId", instituteId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);
        return dl.ReturnDataSet(cmd);
    }

    public DataTable GetMonthlyStudentGrowth(int instituteId)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT 
                DATENAME(MONTH, u.CreatedOn) AS Month,
                MONTH(u.CreatedOn) AS MonthNum,
                COUNT(*) AS NewStudents
            FROM Users
            WHERE InstituteId=@InstituteId AND SessionId=@SessionId
              AND RoleId=(SELECT RoleId FROM Roles WHERE RoleName='Student')
              AND YEAR(CreatedOn)=YEAR(GETDATE())
            GROUP BY DATENAME(MONTH, CreatedOn), MONTH(CreatedOn)
            ORDER BY MonthNum;
        ");
        cmd.Parameters.AddWithValue("@InstituteId", instituteId);
        return dl.GetDataTable(cmd);
    }

    public DataTable GetStreamWiseStudents(int instituteId, int sessionId)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT st.StreamName, COUNT(sa.UserId) AS Students
            FROM StudentAcademicDetails sa
            JOIN Streams st ON sa.StreamId=st.StreamId
            WHERE sa.InstituteId=@InstituteId AND sa.SessionId=@SessionId
            GROUP BY st.StreamName;
        ");
        cmd.Parameters.AddWithValue("@InstituteId", instituteId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);
        return dl.GetDataTable(cmd);
    }

    public DataTable GetRecentActivities(int instituteId, int sessionId)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT TOP 10
                ual.ActivityType,
                up.FullName,
                ual.ActionTime
            FROM UserActivityLog ual
            JOIN UserProfile up ON ual.UserId=up.UserId
            WHERE ual.InstituteId=@InstituteId AND ual.SessionId=@SessionId
            ORDER BY ual.ActionTime DESC;
        ");
        cmd.Parameters.AddWithValue("@InstituteId", instituteId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);
        return dl.GetDataTable(cmd);
    }

    public DataTable GetQuizPerformanceSummary(int instituteId, int sessionId)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT 
                AVG(CAST(qr.Score AS FLOAT)) AS AvgScore,
                MAX(qr.Score) AS MaxScore,
                COUNT(DISTINCT qr.StudentId) AS TotalAttempts
            FROM QuizResults qr
            JOIN Quizzes q ON qr.QuizId=q.QuizId
            WHERE q.InstituteId=@InstituteId AND q.SessionId=@SessionId;
        ");
        cmd.Parameters.AddWithValue("@InstituteId", instituteId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);
        return dl.GetDataTable(cmd);
    }
}