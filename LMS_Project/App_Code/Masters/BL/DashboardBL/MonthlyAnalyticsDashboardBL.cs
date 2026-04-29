using System;
using System.Data;
using System.Data.SqlClient;

public class MonthlyAnalyticsDashboardBL
{
    DataLayer dl = new DataLayer();

    /// <summary>
    /// Summary KPIs for selected month/year
    /// </summary>
    public DataTable GetMonthlySummaryKPIs(int instituteId, int sessionId, int month, int year)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT
                -- New students this month
                (SELECT COUNT(*) FROM Users u
                 WHERE u.InstituteId = @InstituteId AND u.SessionID = SessionId
                   AND u.RoleId = (SELECT RoleId FROM Roles WHERE RoleName = 'Student')
                   AND MONTH(u.CreatedOn) = @Month AND YEAR(u.CreatedOn) = @Year
                ) AS NewStudents,

                -- New students prev month (for trend)
                (SELECT COUNT(*) FROM Users u
                 WHERE u.InstituteId = @InstituteId AND u.SessionID = SessionId
                   AND u.RoleId = (SELECT RoleId FROM Roles WHERE RoleName = 'Student')
                   AND MONTH(u.CreatedOn) = CASE WHEN @Month=1 THEN 12 ELSE @Month-1 END
                   AND YEAR(u.CreatedOn)  = CASE WHEN @Month=1 THEN @Year-1 ELSE @Year END
                ) AS PrevNewStudents,

                -- Total active students this session
                (SELECT COUNT(*) FROM Users u
                 WHERE u.InstituteId = @InstituteId AND u.SessionID = SessionId AND u.IsActive = 1
                   AND u.RoleId = (SELECT RoleId FROM Roles WHERE RoleName = 'Student')
                ) AS TotalActiveStudents,

                -- Attendance % this month
                (SELECT CAST(
                    100.0 * SUM(CASE WHEN Status='Present' THEN 1 ELSE 0 END)
                    / NULLIF(COUNT(*), 0)
                 AS DECIMAL(5,2))
                 FROM Attendance
                 WHERE InstituteId = @InstituteId AND SessionId = @SessionId
                   AND MONTH(Date) = @Month AND YEAR(Date) = @Year
                ) AS AttendancePct,

                -- Attendance prev month
                (SELECT CAST(
                    100.0 * SUM(CASE WHEN Status='Present' THEN 1 ELSE 0 END)
                    / NULLIF(COUNT(*), 0)
                 AS DECIMAL(5,2))
                 FROM Attendance
                 WHERE InstituteId = @InstituteId AND SessionId = @SessionId
                   AND MONTH(Date) = CASE WHEN @Month=1 THEN 12 ELSE @Month-1 END
                   AND YEAR(Date)  = CASE WHEN @Month=1 THEN @Year-1 ELSE @Year END
                ) AS PrevAttendancePct,

                -- Assignments created this month
                (SELECT COUNT(*) FROM Assignments
                 WHERE InstituteId = @InstituteId AND SessionId = @SessionId
                   AND MONTH(CreatedOn) = @Month AND YEAR(CreatedOn) = @Year
                ) AS AssignmentsCreated,

                -- Submissions this month
                (SELECT COUNT(*) FROM AssignmentSubmissions
                 WHERE InstituteId = @InstituteId AND SessionId = @SessionId
                   AND MONTH(SubmittedOn) = @Month AND YEAR(SubmittedOn) = @Year
                ) AS AssignmentSubmissions,

                -- Videos uploaded this month
                (SELECT COUNT(*) FROM Videos
                 WHERE InstituteId = @InstituteId AND SessionId = @SessionId
                   AND MONTH(UploadedOn) = @Month AND YEAR(UploadedOn) = @Year
                ) AS VideosUploaded,

                -- Video views this month
                (SELECT COUNT(*) FROM VideoViews
                 WHERE InstituteId = @InstituteId AND SessionId = @SessionId
                   AND MONTH(ViewedOn) = @Month AND YEAR(ViewedOn) = @Year
                ) AS VideoViews,

                -- Quizzes attempted this month
                (SELECT COUNT(*) FROM QuizResults qr
                 JOIN Quizzes q ON qr.QuizId = q.QuizId
                 WHERE q.InstituteId = @InstituteId AND q.SessionId = @SessionId
                   AND MONTH(qr.AttemptedOn) = @Month AND YEAR(qr.AttemptedOn) = @Year
                ) AS QuizAttempts,

                -- Avg quiz score this month
                (SELECT CAST(AVG(CAST(qr.Score AS FLOAT)) AS DECIMAL(5,2))
                 FROM QuizResults qr
                 JOIN Quizzes q ON qr.QuizId = q.QuizId
                 WHERE q.InstituteId = @InstituteId AND q.SessionId = @SessionId
                   AND MONTH(qr.AttemptedOn) = @Month AND YEAR(qr.AttemptedOn) = @Year
                ) AS AvgQuizScore,

                -- Help requests this month
                (SELECT COUNT(*) FROM HelpRequests
                 WHERE InstituteId = @InstituteId AND SessionId = @SessionId
                   AND MONTH(AskedOn) = @Month AND YEAR(AskedOn) = @Year
                ) AS HelpRequests,

                -- Notifications sent this month
                (SELECT COUNT(*) FROM Notifications
                 WHERE InstituteId = @InstituteId AND SessionId = @SessionId
                   AND MONTH(CreatedOn) = @Month AND YEAR(CreatedOn) = @Year
                ) AS NotificationsSent;
        ");
        cmd.Parameters.AddWithValue("@InstituteId", instituteId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);
        cmd.Parameters.AddWithValue("@Month", month);
        cmd.Parameters.AddWithValue("@Year", year);
        return dl.GetDataTable(cmd);
    }

    /// <summary>
    /// Day-by-day attendance for the selected month (for the area chart)
    /// </summary>
    public DataTable GetDailyAttendance(int instituteId, int sessionId, int month, int year)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT
                DAY(Date) AS DayNum,
                CAST(100.0 * SUM(CASE WHEN Status='Present' THEN 1 ELSE 0 END)
                     / NULLIF(COUNT(*), 0) AS DECIMAL(5,2)) AS AttPct,
                COUNT(*) AS Total,
                SUM(CASE WHEN Status='Present' THEN 1 ELSE 0 END) AS Present,
                SUM(CASE WHEN Status='Absent'  THEN 1 ELSE 0 END) AS Absent
            FROM Attendance
            WHERE InstituteId = @InstituteId AND SessionId = @SessionId
              AND MONTH(Date) = @Month AND YEAR(Date) = @Year
            GROUP BY DAY(Date)
            ORDER BY DayNum;
        ");
        cmd.Parameters.AddWithValue("@InstituteId", instituteId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);
        cmd.Parameters.AddWithValue("@Month", month);
        cmd.Parameters.AddWithValue("@Year", year);
        return dl.GetDataTable(cmd);
    }

    /// <summary>
    /// Weekly video views for the selected month
    /// </summary>
    public DataTable GetWeeklyVideoViews(int instituteId, int sessionId, int month, int year)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT
                'Week ' + CAST(DATEPART(WEEK, ViewedOn)
                    - DATEPART(WEEK, DATEFROMPARTS(@Year, @Month, 1)) + 1 AS VARCHAR) AS WeekLabel,
                COUNT(*) AS Views,
                SUM(CASE WHEN IsCompleted=1 THEN 1 ELSE 0 END) AS Completed
            FROM VideoViews
            WHERE InstituteId = @InstituteId AND SessionId = @SessionId
              AND MONTH(ViewedOn) = @Month AND YEAR(ViewedOn) = @Year
            GROUP BY DATEPART(WEEK, ViewedOn)
            ORDER BY DATEPART(WEEK, ViewedOn);
        ");
        cmd.Parameters.AddWithValue("@InstituteId", instituteId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);
        cmd.Parameters.AddWithValue("@Month", month);
        cmd.Parameters.AddWithValue("@Year", year);
        return dl.GetDataTable(cmd);
    }

    /// <summary>
    /// Subject-wise assignment submission rate this month
    /// </summary>
    public DataTable GetSubjectAssignmentStats(int instituteId, int sessionId, int month, int year)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT TOP 6
                s.SubjectName,
                COUNT(DISTINCT a.AssignmentId) AS TotalAssignments,
                COUNT(DISTINCT asub.SubmissionId) AS Submissions,
                CAST(100.0 * COUNT(DISTINCT asub.SubmissionId)
                     / NULLIF(COUNT(DISTINCT a.AssignmentId) * 
                       (SELECT COUNT(*) FROM Users u2
                        WHERE u2.InstituteId = @InstituteId AND u2.IsActive = 1
                          AND u2.RoleId = (SELECT RoleId FROM Roles WHERE RoleName='Student')), 0)
                 AS DECIMAL(5,2)) AS SubmissionRate
            FROM Assignments a
            JOIN Subjects s ON a.SubjectId = s.SubjectId
            LEFT JOIN AssignmentSubmissions asub
                ON asub.AssignmentId = a.AssignmentId
               AND MONTH(asub.SubmittedOn) = @Month AND YEAR(asub.SubmittedOn) = @Year
            WHERE a.InstituteId = @InstituteId AND a.SessionId = @SessionId
              AND MONTH(a.CreatedOn) = @Month AND YEAR(a.CreatedOn) = @Year
            GROUP BY s.SubjectName
            ORDER BY Submissions DESC;
        ");
        cmd.Parameters.AddWithValue("@InstituteId", instituteId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);
        cmd.Parameters.AddWithValue("@Month", month);
        cmd.Parameters.AddWithValue("@Year", year);
        return dl.GetDataTable(cmd);
    }

    /// <summary>
    /// Quiz performance by subject this month
    /// </summary>
    public DataTable GetQuizPerformanceBySubject(int instituteId, int sessionId, int month, int year)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT TOP 6
                s.SubjectName,
                COUNT(qr.ResultId) AS Attempts,
                CAST(AVG(CAST(qr.Score AS FLOAT)) AS DECIMAL(5,2)) AS AvgScore,
                MAX(qr.Score) AS MaxScore,
                CAST(100.0 * SUM(CASE WHEN qr.Score >= q.PassMarks THEN 1 ELSE 0 END)
                     / NULLIF(COUNT(qr.ResultId),0) AS DECIMAL(5,2)) AS PassRate
            FROM QuizResults qr
            JOIN Quizzes q ON qr.QuizId = q.QuizId
            JOIN Subjects s ON q.SubjectId = s.SubjectId
            WHERE q.InstituteId = @InstituteId AND q.SessionId = @SessionId
              AND MONTH(qr.AttemptedOn) = @Month AND YEAR(qr.AttemptedOn) = @Year
            GROUP BY s.SubjectName
            ORDER BY Attempts DESC;
        ");
        cmd.Parameters.AddWithValue("@InstituteId", instituteId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);
        cmd.Parameters.AddWithValue("@Month", month);
        cmd.Parameters.AddWithValue("@Year", year);
        return dl.GetDataTable(cmd);
    }

    /// <summary>
    /// Attendance breakdown by stream this month
    /// </summary>
    public DataTable GetAttendanceByStream(int instituteId, int sessionId, int month, int year)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT
                st.StreamName,
                CAST(100.0 * SUM(CASE WHEN a.Status='Present' THEN 1 ELSE 0 END)
                     / NULLIF(COUNT(*), 0) AS DECIMAL(5,2)) AS AttPct
            FROM Attendance a
            JOIN StudentAcademicDetails sad ON a.UserId = sad.UserId
            JOIN Streams st ON sad.StreamId = st.StreamId
            WHERE a.InstituteId = @InstituteId AND a.SessionId = @SessionId
              AND MONTH(a.Date) = @Month AND YEAR(a.Date) = @Year
            GROUP BY st.StreamName
            ORDER BY AttPct DESC;
        ");
        cmd.Parameters.AddWithValue("@InstituteId", instituteId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);
        cmd.Parameters.AddWithValue("@Month", month);
        cmd.Parameters.AddWithValue("@Year", year);
        return dl.GetDataTable(cmd);
    }

    /// <summary>
    /// Top 5 active teachers by activity this month
    /// </summary>
    public DataTable GetTopActiveTeachers(int instituteId, int sessionId, int month, int year)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT TOP 5
                up.FullName,
                up.ProfileImage,
                ISNULL(td.Designation, 'Teacher') AS Designation,
                COUNT(ual.LogId) AS ActivityCount,
                (SELECT COUNT(*) FROM Videos v WHERE v.InstructorId = u.UserId
                   AND MONTH(v.UploadedOn)=@Month AND YEAR(v.UploadedOn)=@Year) AS VideosUploaded,
                (SELECT COUNT(*) FROM Assignments a WHERE a.CreatedBy = u.UserId
                   AND MONTH(a.CreatedOn)=@Month AND YEAR(a.CreatedOn)=@Year) AS AssignmentsCreated
            FROM Users u
            JOIN UserProfile up ON u.UserId = up.UserId
            LEFT JOIN TeacherDetails td ON u.UserId = td.UserId
            LEFT JOIN UserActivityLog ual ON u.UserId = ual.UserId
                AND MONTH(ual.ActionTime)=@Month AND YEAR(ual.ActionTime)=@Year
            WHERE u.InstituteId = @InstituteId
              AND u.RoleId = (SELECT RoleId FROM Roles WHERE RoleName='Teacher')
              AND u.IsActive = 1
            GROUP BY u.UserId, up.FullName, up.ProfileImage, td.Designation
            ORDER BY ActivityCount DESC;
        ");
        cmd.Parameters.AddWithValue("@InstituteId", instituteId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);
        cmd.Parameters.AddWithValue("@Month", month);
        cmd.Parameters.AddWithValue("@Year", year);
        return dl.GetDataTable(cmd);
    }

    /// <summary>
    /// Month-over-month comparison for last 6 months
    /// </summary>
    public DataTable GetLast6MonthsTrend(int instituteId, int sessionId)
    {
        SqlCommand cmd = new SqlCommand(@"
            WITH Months AS (
                SELECT TOP 6
                    MONTH(DATEADD(MONTH, -n, GETDATE())) AS M,
                    YEAR(DATEADD(MONTH, -n, GETDATE()))  AS Y,
                    DATENAME(MONTH, DATEADD(MONTH, -n, GETDATE())) AS MName
                FROM (VALUES(0),(1),(2),(3),(4),(5)) AS T(n)
            )
            SELECT
                m.MName AS MonthName,
                m.M, m.Y,
                ISNULL((SELECT COUNT(*) FROM Users u
                        WHERE u.InstituteId=@InstituteId
                          AND u.RoleId=(SELECT RoleId FROM Roles WHERE RoleName='Student')
                          AND MONTH(u.CreatedOn)=m.M AND YEAR(u.CreatedOn)=m.Y), 0) AS NewStudents,
                ISNULL((SELECT CAST(100.0*SUM(CASE WHEN Status='Present' THEN 1 ELSE 0 END)
                                   /NULLIF(COUNT(*),0) AS DECIMAL(5,2))
                        FROM Attendance
                        WHERE InstituteId=@InstituteId AND SessionId=@SessionId
                          AND MONTH(Date)=m.M AND YEAR(Date)=m.Y), 0) AS AvgAttendance,
                ISNULL((SELECT COUNT(*) FROM VideoViews vv
                        WHERE vv.InstituteId=@InstituteId AND vv.SessionId=@SessionId
                          AND MONTH(vv.ViewedOn)=m.M AND YEAR(vv.ViewedOn)=m.Y), 0) AS VideoViews
            FROM Months m
            ORDER BY m.Y, m.M;
        ");
        cmd.Parameters.AddWithValue("@InstituteId", instituteId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);
        return dl.GetDataTable(cmd);
    }

    /// <summary>
    /// Recent announcements/notifications this month
    /// </summary>
    public DataTable GetRecentNotifications(int instituteId, int sessionId, int month, int year)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT TOP 8
                n.Message,
                n.NotificationType,
                n.CreatedOn,
                n.IsRead,
                up.FullName AS SentTo
            FROM Notifications n
            LEFT JOIN UserProfile up ON n.UserId = up.UserId
            WHERE n.InstituteId = @InstituteId AND n.SessionId = @SessionId
              AND MONTH(n.CreatedOn) = @Month AND YEAR(n.CreatedOn) = @Year
            ORDER BY n.CreatedOn DESC;
        ");
        cmd.Parameters.AddWithValue("@InstituteId", instituteId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);
        cmd.Parameters.AddWithValue("@Month", month);
        cmd.Parameters.AddWithValue("@Year", year);
        return dl.GetDataTable(cmd);
    }

    /// <summary>
    /// Calendar events this month
    /// </summary>
    public DataTable GetMonthlyEvents(int instituteId, int sessionId, int month, int year)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT
                Title,
                EventType,
                StartTime,
                EndTime,
                IsAllDay
            FROM CalendarEvents
            WHERE InstituteId = @InstituteId AND SessionId = @SessionId
              AND MONTH(StartTime) = @Month AND YEAR(StartTime) = @Year
            ORDER BY StartTime;
        ");
        cmd.Parameters.AddWithValue("@InstituteId", instituteId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);
        cmd.Parameters.AddWithValue("@Month", month);
        cmd.Parameters.AddWithValue("@Year", year);
        return dl.GetDataTable(cmd);
    }

    // ── Upload banner image ──
    // NOTE: Banner images are stored as file path in DB.
    // We store them in a separate config table or use Institutes.LogoURL.
    // For monthly banner, store path in a new MonthlyBanners table (see note below).
    // Alternatively pass the saved path from code-behind after file upload.
}