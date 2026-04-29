using System;
using System.Data;
using System.Data.SqlClient;

/// <summary>
/// BL for Course Wise Dashboard - all queries scoped by InstituteId + SessionId + CourseId
/// CourseId=0 means "All Courses"
/// </summary>
public class CourseWiseDashboardBL
{
    DataLayer dl = new DataLayer();

    // ─────────────────────────────────────────────────────────────
    // 1. Dropdown: All active courses grouped by stream
    // ─────────────────────────────────────────────────────────────
    public DataTable GetAllCourses(int instituteId, int sessionId)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT
                c.CourseId,
                LTRIM(RTRIM(c.CourseName))                     AS CourseName,
                ISNULL(LTRIM(RTRIM(c.CourseCode)),'')          AS CourseCode,
                LTRIM(RTRIM(s.StreamName))                     AS StreamName,
                s.StreamId
            FROM   Courses c
            INNER JOIN Streams s ON s.StreamId = c.StreamId
            WHERE  c.InstituteId = @InstituteId
              AND  c.SessionId   = @SessionId
              AND  c.IsActive    = 1
              AND  s.IsActive    = 1
            ORDER BY s.StreamName, c.CourseName;");
        cmd.Parameters.AddWithValue("@InstituteId", instituteId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);
        return dl.GetDataTable(cmd);
    }

    // ─────────────────────────────────────────────────────────────
    // 2. KPI summary per course (or aggregated for all)
    //    FIX: Sections scoped to course via StudentAcademicDetails
    // ─────────────────────────────────────────────────────────────
    public DataTable GetCourseKPIs(int instituteId, int sessionId, int courseId)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT
                c.CourseId,
                LTRIM(RTRIM(c.CourseName))   AS CourseName,
                ISNULL(c.CourseCode,'')      AS CourseCode,
                s.StreamName,

                -- Students enrolled
                COUNT(DISTINCT sa.UserId)    AS TotalStudents,

                -- Subjects mapped to this course
                COUNT(DISTINCT lss.SubjectId) AS TotalSubjects,

                -- Sections students actually sit in
                COUNT(DISTINCT sa.SectionId) AS TotalSections,

                -- Attendance %
                CAST(
                    100.0 * SUM(CASE WHEN a.Status='Present' THEN 1 ELSE 0 END)
                    / NULLIF(COUNT(a.AttendanceId), 0)
                AS DECIMAL(5,2)) AS AttendancePct,

                -- Assignment submissions by these students
                COUNT(DISTINCT asub.SubmissionId) AS AssignmentSubmissions,

                -- Quiz attempts
                COUNT(DISTINCT qr.ResultId)  AS QuizAttempts,

                -- Avg quiz score
                CAST(
                    AVG(CAST(qr.Score AS FLOAT))
                AS DECIMAL(5,2))             AS AvgQuizScore

            FROM Courses c
            INNER JOIN Streams s ON s.StreamId = c.StreamId

            -- Students in this course
            LEFT JOIN StudentAcademicDetails sa
                ON  sa.CourseId    = c.CourseId
                AND sa.InstituteId = @InstituteId
                AND sa.SessionId   = @SessionId

            -- Subjects mapped to this course
            LEFT JOIN LevelSemesterSubjects lss
                ON  lss.CourseId   = c.CourseId
                AND lss.InstituteId= @InstituteId
                AND lss.SessionId  = @SessionId

            -- Attendance for those students
            LEFT JOIN Attendance a
                ON  a.UserId      = sa.UserId
                AND a.InstituteId = @InstituteId
                AND a.SessionId   = @SessionId

            -- Assignment submissions
            LEFT JOIN AssignmentSubmissions asub
                ON  asub.StudentId  = sa.UserId
                AND asub.InstituteId= @InstituteId
                AND asub.SessionId  = @SessionId

            -- Quiz results
            LEFT JOIN QuizResults qr
                ON  qr.StudentId   = sa.UserId
                AND qr.InstituteId = @InstituteId
                AND qr.SessionId   = @SessionId

            WHERE c.InstituteId = @InstituteId
              AND c.SessionId   = @SessionId
              AND c.IsActive    = 1
              AND (@CourseId = 0 OR c.CourseId = @CourseId)

            GROUP BY c.CourseId, c.CourseName, c.CourseCode, s.StreamName
            ORDER BY TotalStudents DESC;");

        cmd.Parameters.AddWithValue("@InstituteId", instituteId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);
        cmd.Parameters.AddWithValue("@CourseId", courseId);
        return dl.GetDataTable(cmd);
    }

    // ─────────────────────────────────────────────────────────────
    // 3. Enrollment trend – last 6 calendar months
    //    FIX: Use JoinedOn from StudentAcademicDetails (not Users)
    // ─────────────────────────────────────────────────────────────
    public DataTable GetEnrollmentTrend(int instituteId, int sessionId, int courseId)
    {
        SqlCommand cmd = new SqlCommand(@"
            WITH Months AS (
                SELECT TOP 6
                    MONTH(DATEADD(MONTH, -n, GETDATE())) AS M,
                    YEAR (DATEADD(MONTH, -n, GETDATE())) AS Y,
                    DATENAME(MONTH, DATEADD(MONTH, -n, GETDATE())) AS MName
                FROM (VALUES(0),(1),(2),(3),(4),(5)) AS T(n)
            )
            SELECT
                m.MName AS MonthName,
                m.M,
                m.Y,
                COUNT(sa.UserId) AS Students
            FROM Months m
            LEFT JOIN StudentAcademicDetails sa
                ON  MONTH(sa.JoinedOn) = m.M
                AND YEAR (sa.JoinedOn) = m.Y
                AND sa.InstituteId     = @InstituteId
                AND sa.SessionId       = @SessionId
                AND (@CourseId = 0 OR sa.CourseId = @CourseId)
            GROUP BY m.MName, m.M, m.Y
            ORDER BY m.Y ASC, m.M ASC;");

        cmd.Parameters.AddWithValue("@InstituteId", instituteId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);
        cmd.Parameters.AddWithValue("@CourseId", courseId);
        return dl.GetDataTable(cmd);
    }

    // ─────────────────────────────────────────────────────────────
    // 4. Level-wise student count
    // ─────────────────────────────────────────────────────────────
    public DataTable GetLevelWiseStudents(int instituteId, int sessionId, int courseId)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT
                ISNULL(sl.LevelName,'Unassigned') AS LevelName,
                COUNT(DISTINCT sa.UserId)          AS Students
            FROM StudentAcademicDetails sa
            LEFT JOIN StudyLevels sl
                ON  sl.LevelId     = sa.LevelId
                AND sl.InstituteId = @InstituteId
            WHERE sa.InstituteId = @InstituteId
              AND sa.SessionId   = @SessionId
              AND (@CourseId = 0 OR sa.CourseId = @CourseId)
            GROUP BY sl.LevelName
            ORDER BY Students DESC;");

        cmd.Parameters.AddWithValue("@InstituteId", instituteId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);
        cmd.Parameters.AddWithValue("@CourseId", courseId);
        return dl.GetDataTable(cmd);
    }

    // ─────────────────────────────────────────────────────────────
    // 5. Semester-wise student count
    // ─────────────────────────────────────────────────────────────
    public DataTable GetSemesterWiseStudents(int instituteId, int sessionId, int courseId)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT
                ISNULL(sem.SemesterName,'Unassigned') AS SemesterName,
                COUNT(DISTINCT sa.UserId)              AS Students
            FROM StudentAcademicDetails sa
            LEFT JOIN Semesters sem
                ON  sem.SemesterId  = sa.SemesterId
                AND sem.InstituteId = @InstituteId
            WHERE sa.InstituteId = @InstituteId
              AND sa.SessionId   = @SessionId
              AND (@CourseId = 0 OR sa.CourseId = @CourseId)
            GROUP BY sem.SemesterName
            ORDER BY Students DESC;");

        cmd.Parameters.AddWithValue("@InstituteId", instituteId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);
        cmd.Parameters.AddWithValue("@CourseId", courseId);
        return dl.GetDataTable(cmd);
    }

    // ─────────────────────────────────────────────────────────────
    // 6. Attendance week-over-week (last 4 weeks)
    //    FIX: DATEPART(WEEK) computed once in base query
    // ─────────────────────────────────────────────────────────────
    public DataTable GetAttendanceByWeek(int instituteId, int sessionId, int courseId)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT
                'Week ' + CAST(
                    ROW_NUMBER() OVER (ORDER BY DATEPART(ISO_WEEK, a.Date))
                AS VARCHAR) AS WeekLabel,
                CAST(
                    100.0 * SUM(CASE WHEN a.Status='Present' THEN 1 ELSE 0 END)
                    / NULLIF(COUNT(*), 0)
                AS DECIMAL(5,2)) AS AttPct,
                SUM(CASE WHEN a.Status='Present' THEN 1 ELSE 0 END) AS Present,
                SUM(CASE WHEN a.Status='Absent'  THEN 1 ELSE 0 END) AS Absent,
                SUM(CASE WHEN a.Status='Leave'   THEN 1 ELSE 0 END) AS OnLeave
            FROM Attendance a
            INNER JOIN StudentAcademicDetails sa
                ON  sa.UserId      = a.UserId
                AND sa.InstituteId = @InstituteId
                AND sa.SessionId   = @SessionId
                AND (@CourseId = 0 OR sa.CourseId = @CourseId)
            WHERE a.InstituteId = @InstituteId
              AND a.SessionId   = @SessionId
              AND a.Date >= CAST(DATEADD(DAY, -27, GETDATE()) AS DATE)
            GROUP BY DATEPART(ISO_WEEK, a.Date)
            ORDER BY DATEPART(ISO_WEEK, a.Date);");

        cmd.Parameters.AddWithValue("@InstituteId", instituteId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);
        cmd.Parameters.AddWithValue("@CourseId", courseId);
        return dl.GetDataTable(cmd);
    }

    // ─────────────────────────────────────────────────────────────
    // 7. Subject performance with correct SubjectId-scoped joins
    //    FIX: Videos joined via SubjectId (requires SubjectId on Videos table)
    //         If SubjectId not on Videos, count is 0 safely
    // ─────────────────────────────────────────────────────────────
    public DataTable GetSubjectPerformance(int instituteId, int sessionId, int courseId)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT TOP 8
                sub.SubjectId,
                LTRIM(RTRIM(sub.SubjectName))      AS SubjectName,
                ISNULL(sub.SubjectCode,'')         AS SubjectCode,

                -- Videos: count distinct videos for this subject
                (SELECT COUNT(*) FROM Videos v2
                 WHERE v2.InstituteId = @InstituteId
                   AND v2.SessionId  = @SessionId
                   AND v2.ChapterId  IN (
                       SELECT ChapterId FROM Chapters ch
                       WHERE ch.SubjectId  = sub.SubjectId
                         AND ch.InstituteId= @InstituteId
                         AND ch.SessionId  = @SessionId)
                 ) AS Videos,

                -- Assignments
                COUNT(DISTINCT a.AssignmentId)     AS Assignments,

                -- Quizzes
                COUNT(DISTINCT q.QuizId)           AS Quizzes,

                -- Avg quiz score for this subject
                CAST(
                    AVG(CAST(qr.Score AS FLOAT))
                AS DECIMAL(5,2))                   AS AvgScore,

                -- Attendance % for this subject
                CAST(
                    100.0 * SUM(CASE WHEN att.Status='Present' THEN 1 ELSE 0 END)
                    / NULLIF(COUNT(att.AttendanceId),0)
                AS DECIMAL(5,2))                   AS AttPct

            FROM LevelSemesterSubjects lss
            INNER JOIN Subjects sub
                ON  sub.SubjectId  = lss.SubjectId
                AND sub.InstituteId= @InstituteId

            LEFT JOIN Assignments a
                ON  a.SubjectId   = sub.SubjectId
                AND a.InstituteId = @InstituteId
                AND a.SessionId   = @SessionId

            LEFT JOIN Quizzes q
                ON  q.SubjectId   = sub.SubjectId
                AND q.InstituteId = @InstituteId
                AND q.SessionId   = @SessionId

            LEFT JOIN QuizResults qr
                ON  qr.QuizId = q.QuizId
                AND qr.InstituteId = @InstituteId
                AND qr.SessionId   = @SessionId

            LEFT JOIN Attendance att
                ON  att.SubjectId  = sub.SubjectId
                AND att.InstituteId= @InstituteId
                AND att.SessionId  = @SessionId

            WHERE lss.InstituteId = @InstituteId
              AND lss.SessionId   = @SessionId
              AND (@CourseId = 0 OR lss.CourseId = @CourseId)

            GROUP BY sub.SubjectId, sub.SubjectName, sub.SubjectCode
            ORDER BY Assignments DESC, Quizzes DESC;");

        cmd.Parameters.AddWithValue("@InstituteId", instituteId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);
        cmd.Parameters.AddWithValue("@CourseId", courseId);
        return dl.GetDataTable(cmd);
    }

    // ─────────────────────────────────────────────────────────────
    // 8. Quiz performance per quiz title
    // ─────────────────────────────────────────────────────────────
    public DataTable GetQuizPerformance(int instituteId, int sessionId, int courseId)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT TOP 6
                LTRIM(RTRIM(q.Title))                           AS QuizTitle,
                COUNT(DISTINCT qr.StudentId)                    AS Attempts,
                CAST(AVG(CAST(qr.Score AS FLOAT)) AS DECIMAL(5,2)) AS AvgScore,
                ISNULL(MAX(qr.Score), 0)                        AS HighScore,
                ISNULL(MIN(qr.Score), 0)                        AS LowScore,
                CAST(
                    100.0 * SUM(CASE WHEN qr.Score >= q.PassMarks THEN 1 ELSE 0 END)
                    / NULLIF(COUNT(qr.ResultId), 0)
                AS DECIMAL(5,2))                                AS PassRate
            FROM Quizzes q
            LEFT JOIN QuizResults qr
                ON  qr.QuizId      = q.QuizId
                AND qr.InstituteId = @InstituteId
                AND qr.SessionId   = @SessionId
            INNER JOIN Subjects sub ON sub.SubjectId = q.SubjectId
            LEFT JOIN LevelSemesterSubjects lss
                ON  lss.SubjectId   = sub.SubjectId
                AND lss.InstituteId = @InstituteId
                AND lss.SessionId   = @SessionId
            WHERE q.InstituteId = @InstituteId
              AND q.SessionId   = @SessionId
              AND q.IsEnabled   = 1
              AND (@CourseId = 0 OR lss.CourseId = @CourseId)
            GROUP BY q.QuizId, q.Title, q.PassMarks
            ORDER BY Attempts DESC, AvgScore DESC;");

        cmd.Parameters.AddWithValue("@InstituteId", instituteId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);
        cmd.Parameters.AddWithValue("@CourseId", courseId);
        return dl.GetDataTable(cmd);
    }

    // ─────────────────────────────────────────────────────────────
    // 9. Gender distribution
    // ─────────────────────────────────────────────────────────────
    public DataTable GetGenderDistribution(int instituteId, int sessionId, int courseId)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT
                ISNULL(LTRIM(RTRIM(up.Gender)),'Unknown') AS Gender,
                COUNT(*) AS Total
            FROM StudentAcademicDetails sa
            INNER JOIN UserProfile up ON up.UserId = sa.UserId
            WHERE sa.InstituteId = @InstituteId
              AND sa.SessionId   = @SessionId
              AND (@CourseId = 0 OR sa.CourseId = @CourseId)
            GROUP BY up.Gender
            ORDER BY Total DESC;");

        cmd.Parameters.AddWithValue("@InstituteId", instituteId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);
        cmd.Parameters.AddWithValue("@CourseId", courseId);
        return dl.GetDataTable(cmd);
    }

    // ─────────────────────────────────────────────────────────────
    // 10. Section-wise student count
    // ─────────────────────────────────────────────────────────────
    public DataTable GetSectionWiseStudents(int instituteId, int sessionId, int courseId)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT
                ISNULL(sec.SectionName,'Unassigned') AS SectionName,
                COUNT(DISTINCT sa.UserId)             AS Students
            FROM StudentAcademicDetails sa
            LEFT JOIN Sections sec
                ON  sec.SectionId  = sa.SectionId
                AND sec.InstituteId= @InstituteId
            WHERE sa.InstituteId = @InstituteId
              AND sa.SessionId   = @SessionId
              AND (@CourseId = 0 OR sa.CourseId = @CourseId)
            GROUP BY sec.SectionName
            ORDER BY Students DESC;");

        cmd.Parameters.AddWithValue("@InstituteId", instituteId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);
        cmd.Parameters.AddWithValue("@CourseId", courseId);
        return dl.GetDataTable(cmd);
    }

    // ─────────────────────────────────────────────────────────────
    // 11. Assignment submission rate per subject
    //     FIX: Proper scoping via LevelSemesterSubjects + CourseId
    // ─────────────────────────────────────────────────────────────
    public DataTable GetAssignmentSubmissionRate(int instituteId, int sessionId, int courseId)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT TOP 6
                LTRIM(RTRIM(sub.SubjectName))         AS SubjectName,
                COUNT(DISTINCT a.AssignmentId)        AS TotalAssign,
                COUNT(DISTINCT asub.SubmissionId)     AS Submitted,
                CAST(
                    100.0 * COUNT(DISTINCT asub.SubmissionId)
                    / NULLIF(
                        COUNT(DISTINCT a.AssignmentId) *
                        (SELECT COUNT(DISTINCT sa2.UserId)
                         FROM StudentAcademicDetails sa2
                         WHERE sa2.InstituteId = @InstituteId
                           AND sa2.SessionId   = @SessionId
                           AND (@CourseId = 0 OR sa2.CourseId = @CourseId))
                    , 0)
                AS DECIMAL(5,2)) AS SubRate

            FROM LevelSemesterSubjects lss
            INNER JOIN Subjects sub
                ON  sub.SubjectId  = lss.SubjectId
                AND sub.InstituteId= @InstituteId

            LEFT JOIN Assignments a
                ON  a.SubjectId   = sub.SubjectId
                AND a.InstituteId = @InstituteId
                AND a.SessionId   = @SessionId
                AND a.IsActive    = 1

            LEFT JOIN AssignmentSubmissions asub
                ON  asub.AssignmentId = a.AssignmentId
                AND asub.InstituteId  = @InstituteId
                AND asub.SessionId    = @SessionId

            WHERE lss.InstituteId = @InstituteId
              AND lss.SessionId   = @SessionId
              AND (@CourseId = 0 OR lss.CourseId = @CourseId)

            GROUP BY sub.SubjectId, sub.SubjectName
            HAVING COUNT(DISTINCT a.AssignmentId) > 0
            ORDER BY Submitted DESC;");

        cmd.Parameters.AddWithValue("@InstituteId", instituteId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);
        cmd.Parameters.AddWithValue("@CourseId", courseId);
        return dl.GetDataTable(cmd);
    }

    // ─────────────────────────────────────────────────────────────
    // 12. Top students ranked by avg score + attendance
    //     FIX: ISNULL on SemesterName; proper NULL handling
    // ─────────────────────────────────────────────────────────────
    public DataTable GetTopStudents(int instituteId, int sessionId, int courseId)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT TOP 8
                up.FullName,
                ISNULL(up.ProfileImage,'')                                    AS ProfileImage,
                ISNULL(sa.RollNumber,'N/A')                                   AS RollNumber,
                ISNULL(sem.SemesterName,'—')                                  AS SemesterName,
                ISNULL(CAST(
                    100.0 * SUM(CASE WHEN a.Status='Present' THEN 1 ELSE 0 END)
                    / NULLIF(COUNT(a.AttendanceId),0)
                AS DECIMAL(5,2)), 0)                                           AS AttPct,
                ISNULL(CAST(AVG(CAST(qr.Score AS FLOAT)) AS DECIMAL(5,2)), 0) AS AvgScore,
                COUNT(DISTINCT asub.SubmissionId)                             AS Submissions
            FROM StudentAcademicDetails sa
            INNER JOIN UserProfile up ON up.UserId = sa.UserId
            LEFT JOIN Semesters sem
                ON  sem.SemesterId  = sa.SemesterId
                AND sem.InstituteId = @InstituteId
            LEFT JOIN Attendance a
                ON  a.UserId      = sa.UserId
                AND a.InstituteId = @InstituteId
                AND a.SessionId   = @SessionId
            LEFT JOIN QuizResults qr
                ON  qr.StudentId   = sa.UserId
                AND qr.InstituteId = @InstituteId
                AND qr.SessionId   = @SessionId
            LEFT JOIN AssignmentSubmissions asub
                ON  asub.StudentId  = sa.UserId
                AND asub.InstituteId= @InstituteId
                AND asub.SessionId  = @SessionId
            WHERE sa.InstituteId = @InstituteId
              AND sa.SessionId   = @SessionId
              AND (@CourseId = 0 OR sa.CourseId = @CourseId)
            GROUP BY
                sa.UserId, up.FullName, up.ProfileImage,
                sa.RollNumber, sem.SemesterName
            ORDER BY AvgScore DESC, AttPct DESC;");

        cmd.Parameters.AddWithValue("@InstituteId", instituteId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);
        cmd.Parameters.AddWithValue("@CourseId", courseId);
        return dl.GetDataTable(cmd);
    }
}