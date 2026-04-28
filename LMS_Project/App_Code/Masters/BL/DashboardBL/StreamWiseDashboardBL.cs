using System;
using System.Data;
using System.Data.SqlClient;

public class StreamWiseDashboardBL
{
    DataLayer dl = new DataLayer();

    // All streams for this institute/session
    public DataTable GetAllStreams(int instituteId, int sessionId)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT StreamId, StreamName
            FROM Streams
            WHERE InstituteId=@InstituteId AND SessionId=@SessionId AND IsActive=1
            ORDER BY StreamName;");
        cmd.Parameters.AddWithValue("@InstituteId", instituteId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);
        return dl.GetDataTable(cmd);
    }

    // Top-level KPIs per stream (or all streams if streamId=0)
    public DataTable GetStreamKPIs(int instituteId, int sessionId, int streamId)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT
                st.StreamId,
                st.StreamName,
                COUNT(DISTINCT sa.UserId)     AS TotalStudents,
                COUNT(DISTINCT c.CourseId)    AS TotalCourses,
                COUNT(DISTINCT sub.SubjectId) AS TotalSubjects,
                COUNT(DISTINCT td.UserId)     AS TotalTeachers,
                COUNT(DISTINCT sec.SectionId) AS TotalSections,
                CAST(
                    100.0 * SUM(CASE WHEN a.Status='Present' THEN 1 ELSE 0 END)
                    / NULLIF(COUNT(a.AttendanceId),0)
                AS DECIMAL(5,2))              AS AttendancePct
            FROM Streams st
            LEFT JOIN StudentAcademicDetails sa  ON sa.StreamId=st.StreamId AND sa.SessionId=@SessionId
            LEFT JOIN Courses      c   ON c.StreamId=st.StreamId  AND c.SessionId=@SessionId  AND c.IsActive=1
            LEFT JOIN LevelSemesterSubjects lss ON lss.StreamId=st.StreamId AND lss.SessionId=@SessionId
            LEFT JOIN Subjects sub ON sub.SubjectId=lss.SubjectId
            LEFT JOIN TeacherDetails td  ON td.StreamId=st.StreamId AND td.SessionId=@SessionId
            LEFT JOIN Sections sec ON sec.InstituteId=@InstituteId  AND sec.SessionId=@SessionId
            LEFT JOIN Attendance a   ON a.UserId=sa.UserId AND a.SessionId=@SessionId
            WHERE st.InstituteId=@InstituteId AND st.SessionId=@SessionId AND st.IsActive=1
              AND (@StreamId=0 OR st.StreamId=@StreamId)
            GROUP BY st.StreamId, st.StreamName
            ORDER BY TotalStudents DESC;");
        cmd.Parameters.AddWithValue("@InstituteId", instituteId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);
        cmd.Parameters.AddWithValue("@StreamId", streamId);
        return dl.GetDataTable(cmd);
    }

    // Course-wise student count for selected stream
    public DataTable GetCourseWiseStudents(int instituteId, int sessionId, int streamId)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT c.CourseName,
                   COUNT(DISTINCT sa.UserId) AS Students
            FROM Courses c
            LEFT JOIN StudentAcademicDetails sa ON sa.CourseId=c.CourseId AND sa.SessionId=@SessionId
            WHERE c.InstituteId=@InstituteId AND c.SessionId=@SessionId AND c.IsActive=1
              AND (@StreamId=0 OR c.StreamId=@StreamId)
            GROUP BY c.CourseName
            ORDER BY Students DESC;");
        cmd.Parameters.AddWithValue("@InstituteId", instituteId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);
        cmd.Parameters.AddWithValue("@StreamId", streamId);
        return dl.GetDataTable(cmd);
    }

    // Monthly enrollment trend per stream (last 6 months)
    public DataTable GetMonthlyEnrollmentTrend(int instituteId, int sessionId, int streamId)
    {
        SqlCommand cmd = new SqlCommand(@"
            WITH Months AS (
                SELECT TOP 6
                    MONTH(DATEADD(MONTH,-n,GETDATE())) M,
                    YEAR(DATEADD(MONTH,-n,GETDATE()))  Y,
                    DATENAME(MONTH,DATEADD(MONTH,-n,GETDATE())) MName
                FROM (VALUES(0),(1),(2),(3),(4),(5)) T(n)
            )
            SELECT m.MName AS MonthName, m.M, m.Y,
                   ISNULL(COUNT(sa.UserId),0) AS Students
            FROM Months m
            LEFT JOIN StudentAcademicDetails sa
                ON MONTH(sa.JoinedOn)=m.M AND YEAR(sa.JoinedOn)=m.Y
               AND sa.InstituteId=@InstituteId AND sa.SessionId=@SessionId
               AND (@StreamId=0 OR sa.StreamId=@StreamId)
            GROUP BY m.MName,m.M,m.Y
            ORDER BY m.Y,m.M;");
        cmd.Parameters.AddWithValue("@InstituteId", instituteId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);
        cmd.Parameters.AddWithValue("@StreamId", streamId);
        return dl.GetDataTable(cmd);
    }

    // Attendance by stream over last 7 days
    public DataTable GetAttendanceLast7Days(int instituteId, int sessionId, int streamId)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT CONVERT(VARCHAR(10), a.Date, 105) AS DayLabel,
                   CAST(100.0*SUM(CASE WHEN a.Status='Present' THEN 1 ELSE 0 END)
                        /NULLIF(COUNT(*),0) AS DECIMAL(5,2)) AS AttPct
            FROM Attendance a
            JOIN StudentAcademicDetails sa ON a.UserId=sa.UserId
            WHERE a.InstituteId=@InstituteId AND a.SessionId=@SessionId
              AND a.Date >= CAST(DATEADD(DAY,-6,GETDATE()) AS DATE)
              AND (@StreamId=0 OR sa.StreamId=@StreamId)
            GROUP BY a.Date
            ORDER BY a.Date;");
        cmd.Parameters.AddWithValue("@InstituteId", instituteId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);
        cmd.Parameters.AddWithValue("@StreamId", streamId);
        return dl.GetDataTable(cmd);
    }

    // Subject list with stats for selected stream
    public DataTable GetSubjectsForStream(int instituteId, int sessionId, int streamId)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT TOP 10
                sub.SubjectName, sub.SubjectCode,
                COUNT(DISTINCT v.VideoId)         AS Videos,
                COUNT(DISTINCT a.AssignmentId)    AS Assignments,
                COUNT(DISTINCT q.QuizId)          AS Quizzes,
                COUNT(DISTINCT vv.ViewId)         AS VideoViews
            FROM LevelSemesterSubjects lss
            JOIN Subjects sub ON lss.SubjectId=sub.SubjectId
            LEFT JOIN Videos v      ON v.SessionId=@SessionId AND v.InstituteId=@InstituteId
            LEFT JOIN Assignments a ON a.SubjectId=sub.SubjectId AND a.SessionId=@SessionId
            LEFT JOIN Quizzes q     ON q.SubjectId=sub.SubjectId AND q.SessionId=@SessionId
            LEFT JOIN VideoViews vv ON vv.VideoId=v.VideoId AND vv.SessionId=@SessionId
            WHERE lss.InstituteId=@InstituteId AND lss.SessionId=@SessionId
              AND (@StreamId=0 OR lss.StreamId=@StreamId)
            GROUP BY sub.SubjectName, sub.SubjectCode
            ORDER BY VideoViews DESC;");
        cmd.Parameters.AddWithValue("@InstituteId", instituteId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);
        cmd.Parameters.AddWithValue("@StreamId", streamId);
        return dl.GetDataTable(cmd);
    }

    // Quiz performance per stream
    public DataTable GetQuizPassRateByStream(int instituteId, int sessionId, int streamId)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT st.StreamName,
                   COUNT(DISTINCT qr.ResultId) AS Attempts,
                   CAST(AVG(CAST(qr.Score AS FLOAT)) AS DECIMAL(5,2)) AS AvgScore,
                   CAST(100.0*SUM(CASE WHEN qr.Score>=q.PassMarks THEN 1 ELSE 0 END)
                        /NULLIF(COUNT(qr.ResultId),0) AS DECIMAL(5,2)) AS PassRate
            FROM QuizResults qr
            JOIN Quizzes q  ON qr.QuizId=q.QuizId
            JOIN StudentAcademicDetails sa ON qr.StudentId=sa.UserId AND sa.SessionId=@SessionId
            JOIN Streams st ON sa.StreamId=st.StreamId
            WHERE q.InstituteId=@InstituteId AND q.SessionId=@SessionId
              AND (@StreamId=0 OR sa.StreamId=@StreamId)
            GROUP BY st.StreamName
            ORDER BY PassRate DESC;");
        cmd.Parameters.AddWithValue("@InstituteId", instituteId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);
        cmd.Parameters.AddWithValue("@StreamId", streamId);
        return dl.GetDataTable(cmd);
    }

    // Top teachers per stream
    public DataTable GetTeachersForStream(int instituteId, int sessionId, int streamId)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT TOP 5
                up.FullName, up.ProfileImage,
                ISNULL(td.Designation,'Teacher') AS Designation,
                ISNULL(td.ExperienceYears,0)     AS ExperienceYears,
                ISNULL(td.Qualification,'')      AS Qualification,
                (SELECT COUNT(*) FROM Videos vv WHERE vv.InstructorId=u.UserId
                 AND vv.SessionId=@SessionId) AS Videos,
                (SELECT COUNT(*) FROM Assignments asgn WHERE asgn.CreatedBy=u.UserId
                 AND asgn.SessionId=@SessionId) AS Assignments
            FROM TeacherDetails td
            JOIN Users u       ON td.UserId=u.UserId
            JOIN UserProfile up ON u.UserId=up.UserId
            WHERE td.InstituteId=@InstituteId AND td.SessionId=@SessionId AND u.IsActive=1
              AND (@StreamId=0 OR td.StreamId=@StreamId)
            ORDER BY Videos DESC;");
        cmd.Parameters.AddWithValue("@InstituteId", instituteId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);
        cmd.Parameters.AddWithValue("@StreamId", streamId);
        return dl.GetDataTable(cmd);
    }

    // Gender distribution per stream
    public DataTable GetGenderDistribution(int instituteId, int sessionId, int streamId)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT up.Gender, COUNT(*) AS Total
            FROM StudentAcademicDetails sa
            JOIN UserProfile up ON sa.UserId=up.UserId
            WHERE sa.InstituteId=@InstituteId AND sa.SessionId=@SessionId
              AND (@StreamId=0 OR sa.StreamId=@StreamId)
            GROUP BY up.Gender;");
        cmd.Parameters.AddWithValue("@InstituteId", instituteId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);
        cmd.Parameters.AddWithValue("@StreamId", streamId);
        return dl.GetDataTable(cmd);
    }

    // Assignment submission rate per stream
    public DataTable GetAssignmentCompletionRate(int instituteId, int sessionId, int streamId)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT st.StreamName,
                   COUNT(DISTINCT asub.SubmissionId) AS Submitted,
                   COUNT(DISTINCT a.AssignmentId)*
                   NULLIF(COUNT(DISTINCT sa.UserId),0) AS TotalExpected
            FROM Streams st
            LEFT JOIN StudentAcademicDetails sa ON sa.StreamId=st.StreamId AND sa.SessionId=@SessionId
            LEFT JOIN Assignments a ON a.InstituteId=@InstituteId AND a.SessionId=@SessionId
            LEFT JOIN AssignmentSubmissions asub ON asub.AssignmentId=a.AssignmentId
                AND asub.StudentId=sa.UserId
            WHERE st.InstituteId=@InstituteId AND st.SessionId=@SessionId AND st.IsActive=1
              AND (@StreamId=0 OR st.StreamId=@StreamId)
            GROUP BY st.StreamName
            ORDER BY Submitted DESC;");
        cmd.Parameters.AddWithValue("@InstituteId", instituteId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);
        cmd.Parameters.AddWithValue("@StreamId", streamId);
        return dl.GetDataTable(cmd);
    }

    // Stream banner save/load (uses Institutes table LogoURL or a simple file convention)
    public void SaveStreamBanner(int streamId, string filePath)
    {
        SqlCommand cmd = new SqlCommand(@"
            UPDATE Streams SET StreamName=StreamName -- placeholder; store banner in file system
            WHERE StreamId=@StreamId;");
        // Banner path stored in file system as /Uploads/StreamBanners/stream_{id}.ext
        cmd.Parameters.AddWithValue("@StreamId", streamId);
        // No-op DB call; actual file already saved in code-behind
    }
}