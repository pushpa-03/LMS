using System;
using System.Data;
using System.Data.SqlClient;

public class CourseWiseDashboardBL
{
    DataLayer dl = new DataLayer();

    // All courses for filter dropdown
    public DataTable GetAllCourses(int instituteId, int sessionId)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT c.CourseId, c.CourseName, c.CourseCode,
                   s.StreamName
            FROM Courses c
            JOIN Streams s ON c.StreamId = s.StreamId
            WHERE c.InstituteId=@InstituteId AND c.SessionId=@SessionId AND c.IsActive=1
            ORDER BY s.StreamName, c.CourseName;");
        cmd.Parameters.AddWithValue("@InstituteId", instituteId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);
        return dl.GetDataTable(cmd);
    }

    // Summary KPIs per course (or all if courseId=0)
    public DataTable GetCourseKPIs(int instituteId, int sessionId, int courseId)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT
                c.CourseId,
                c.CourseName,
                c.CourseCode,
                s.StreamName,
                COUNT(DISTINCT sa.UserId)          AS TotalStudents,
                COUNT(DISTINCT lss.SubjectId)      AS TotalSubjects,
                COUNT(DISTINCT sec.SectionId)      AS TotalSections,
                CAST(
                    100.0 * SUM(CASE WHEN a.Status='Present' THEN 1 ELSE 0 END)
                    / NULLIF(COUNT(a.AttendanceId),0)
                AS DECIMAL(5,2))                   AS AttendancePct,
                COUNT(DISTINCT asub.SubmissionId)  AS AssignmentSubmissions,
                COUNT(DISTINCT qr.ResultId)        AS QuizAttempts,
                CAST(AVG(CAST(qr.Score AS FLOAT)) AS DECIMAL(5,2)) AS AvgQuizScore
            FROM Courses c
            JOIN Streams s ON c.StreamId=s.StreamId
            LEFT JOIN StudentAcademicDetails sa  ON sa.CourseId=c.CourseId AND sa.SessionId=@SessionId
            LEFT JOIN LevelSemesterSubjects lss  ON lss.CourseId=c.CourseId AND lss.SessionId=@SessionId
            LEFT JOIN Sections sec ON sec.InstituteId=@InstituteId AND sec.SessionId=@SessionId
            LEFT JOIN Attendance a ON a.UserId=sa.UserId AND a.SessionId=@SessionId
            LEFT JOIN AssignmentSubmissions asub ON asub.StudentId=sa.UserId AND asub.SessionId=@SessionId
            LEFT JOIN QuizResults qr ON qr.StudentId=sa.UserId
            WHERE c.InstituteId=@InstituteId AND c.SessionId=@SessionId AND c.IsActive=1
              AND (@CourseId=0 OR c.CourseId=@CourseId)
            GROUP BY c.CourseId,c.CourseName,c.CourseCode,s.StreamName
            ORDER BY TotalStudents DESC;");
        cmd.Parameters.AddWithValue("@InstituteId", instituteId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);
        cmd.Parameters.AddWithValue("@CourseId", courseId);
        return dl.GetDataTable(cmd);
    }

    // Monthly enrollment trend last 6 months
    public DataTable GetEnrollmentTrend(int instituteId, int sessionId, int courseId)
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
               AND (@CourseId=0 OR sa.CourseId=@CourseId)
            GROUP BY m.MName,m.M,m.Y
            ORDER BY m.Y,m.M;");
        cmd.Parameters.AddWithValue("@InstituteId", instituteId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);
        cmd.Parameters.AddWithValue("@CourseId", courseId);
        return dl.GetDataTable(cmd);
    }

    // Level/Semester-wise student distribution
    public DataTable GetLevelWiseStudents(int instituteId, int sessionId, int courseId)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT sl.LevelName,
                   COUNT(DISTINCT sa.UserId) AS Students
            FROM StudentAcademicDetails sa
            JOIN StudyLevels sl ON sa.LevelId=sl.LevelId
            WHERE sa.InstituteId=@InstituteId AND sa.SessionId=@SessionId
              AND (@CourseId=0 OR sa.CourseId=@CourseId)
            GROUP BY sl.LevelName
            ORDER BY Students DESC;");
        cmd.Parameters.AddWithValue("@InstituteId", instituteId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);
        cmd.Parameters.AddWithValue("@CourseId", courseId);
        return dl.GetDataTable(cmd);
    }

    // Semester-wise student count
    public DataTable GetSemesterWiseStudents(int instituteId, int sessionId, int courseId)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT sem.SemesterName,
                   COUNT(DISTINCT sa.UserId) AS Students
            FROM StudentAcademicDetails sa
            JOIN Semesters sem ON sa.SemesterId=sem.SemesterId
            WHERE sa.InstituteId=@InstituteId AND sa.SessionId=@SessionId
              AND (@CourseId=0 OR sa.CourseId=@CourseId)
            GROUP BY sem.SemesterName
            ORDER BY Students DESC;");
        cmd.Parameters.AddWithValue("@InstituteId", instituteId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);
        cmd.Parameters.AddWithValue("@CourseId", courseId);
        return dl.GetDataTable(cmd);
    }

    // Attendance last 30 days, grouped by week
    public DataTable GetAttendanceByWeek(int instituteId, int sessionId, int courseId)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT
                'Wk ' + CAST(DATEPART(WEEK,a.Date)-DATEPART(WEEK,DATEADD(DAY,-29,GETDATE()))+1 AS VARCHAR) AS WeekLabel,
                CAST(100.0*SUM(CASE WHEN a.Status='Present' THEN 1 ELSE 0 END)
                     /NULLIF(COUNT(*),0) AS DECIMAL(5,2)) AS AttPct,
                SUM(CASE WHEN a.Status='Present' THEN 1 ELSE 0 END) AS Present,
                SUM(CASE WHEN a.Status='Absent'  THEN 1 ELSE 0 END) AS Absent
            FROM Attendance a
            JOIN StudentAcademicDetails sa ON a.UserId=sa.UserId
            WHERE a.InstituteId=@InstituteId AND a.SessionId=@SessionId
              AND a.Date >= CAST(DATEADD(DAY,-29,GETDATE()) AS DATE)
              AND (@CourseId=0 OR sa.CourseId=@CourseId)
            GROUP BY DATEPART(WEEK,a.Date)
            ORDER BY DATEPART(WEEK,a.Date);");
        cmd.Parameters.AddWithValue("@InstituteId", instituteId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);
        cmd.Parameters.AddWithValue("@CourseId", courseId);
        return dl.GetDataTable(cmd);
    }

    // Subject-wise performance (video, assignment, quiz, attendance)
    public DataTable GetSubjectPerformance(int instituteId, int sessionId, int courseId)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT TOP 8
                sub.SubjectName,
                sub.SubjectCode,
                COUNT(DISTINCT v.VideoId)    AS Videos,
                COUNT(DISTINCT a.AssignmentId) AS Assignments,
                COUNT(DISTINCT q.QuizId)     AS Quizzes,
                CAST(AVG(CAST(qr.Score AS FLOAT)) AS DECIMAL(5,2)) AS AvgScore,
                CAST(100.0*SUM(CASE WHEN att.Status='Present' THEN 1 ELSE 0 END)
                     /NULLIF(COUNT(att.AttendanceId),0) AS DECIMAL(5,2)) AS AttPct
            FROM LevelSemesterSubjects lss
            JOIN Subjects sub ON lss.SubjectId=sub.SubjectId
            LEFT JOIN Videos v      ON v.InstituteId=@InstituteId AND v.SessionId=@SessionId
            LEFT JOIN Assignments a ON a.SubjectId=sub.SubjectId AND a.SessionId=@SessionId
            LEFT JOIN Quizzes q     ON q.SubjectId=sub.SubjectId AND q.SessionId=@SessionId
            LEFT JOIN QuizResults qr ON qr.QuizId=q.QuizId
            LEFT JOIN Attendance att ON att.SubjectId=sub.SubjectId AND att.SessionId=@SessionId
            WHERE lss.InstituteId=@InstituteId AND lss.SessionId=@SessionId
              AND (@CourseId=0 OR lss.CourseId=@CourseId)
            GROUP BY sub.SubjectName,sub.SubjectCode
            ORDER BY Videos DESC;");
        cmd.Parameters.AddWithValue("@InstituteId", instituteId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);
        cmd.Parameters.AddWithValue("@CourseId", courseId);
        return dl.GetDataTable(cmd);
    }

    // Top students for this course
    public DataTable GetTopStudents(int instituteId, int sessionId, int courseId)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT TOP 8
                up.FullName, up.ProfileImage,
                ISNULL(sa.RollNumber,'—')   AS RollNumber,
                sem.SemesterName,
                CAST(100.0*SUM(CASE WHEN a.Status='Present' THEN 1 ELSE 0 END)
                     /NULLIF(COUNT(a.AttendanceId),0) AS DECIMAL(5,2)) AS AttPct,
                ISNULL(CAST(AVG(CAST(qr.Score AS FLOAT)) AS DECIMAL(5,2)),0) AS AvgScore,
                COUNT(DISTINCT asub.SubmissionId) AS Submissions
            FROM StudentAcademicDetails sa
            JOIN UserProfile up  ON sa.UserId=up.UserId
            LEFT JOIN Semesters sem ON sa.SemesterId=sem.SemesterId
            LEFT JOIN Attendance a  ON a.UserId=sa.UserId AND a.SessionId=@SessionId
            LEFT JOIN QuizResults qr ON qr.StudentId=sa.UserId
            LEFT JOIN AssignmentSubmissions asub ON asub.StudentId=sa.UserId AND asub.SessionId=@SessionId
            WHERE sa.InstituteId=@InstituteId AND sa.SessionId=@SessionId
              AND (@CourseId=0 OR sa.CourseId=@CourseId)
            GROUP BY sa.UserId,up.FullName,up.ProfileImage,sa.RollNumber,sem.SemesterName
            ORDER BY AvgScore DESC, AttPct DESC;");
        cmd.Parameters.AddWithValue("@InstituteId", instituteId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);
        cmd.Parameters.AddWithValue("@CourseId", courseId);
        return dl.GetDataTable(cmd);
    }

    // Quiz performance for this course
    public DataTable GetQuizPerformance(int instituteId, int sessionId, int courseId)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT TOP 6
                q.Title AS QuizTitle,
                COUNT(DISTINCT qr.StudentId)  AS Attempts,
                CAST(AVG(CAST(qr.Score AS FLOAT)) AS DECIMAL(5,2)) AS AvgScore,
                MAX(qr.Score) AS HighScore,
                CAST(100.0*SUM(CASE WHEN qr.Score>=q.PassMarks THEN 1 ELSE 0 END)
                     /NULLIF(COUNT(qr.ResultId),0) AS DECIMAL(5,2)) AS PassRate
            FROM Quizzes q
            LEFT JOIN QuizResults qr ON qr.QuizId=q.QuizId
            JOIN Subjects sub ON q.SubjectId=sub.SubjectId
            LEFT JOIN LevelSemesterSubjects lss ON lss.SubjectId=sub.SubjectId AND lss.SessionId=@SessionId
            WHERE q.InstituteId=@InstituteId AND q.SessionId=@SessionId
              AND (@CourseId=0 OR lss.CourseId=@CourseId)
            GROUP BY q.QuizId,q.Title,q.PassMarks
            ORDER BY Attempts DESC;");
        cmd.Parameters.AddWithValue("@InstituteId", instituteId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);
        cmd.Parameters.AddWithValue("@CourseId", courseId);
        return dl.GetDataTable(cmd);
    }

    // Gender distribution for course
    public DataTable GetGenderDistribution(int instituteId, int sessionId, int courseId)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT up.Gender, COUNT(*) AS Total
            FROM StudentAcademicDetails sa
            JOIN UserProfile up ON sa.UserId=up.UserId
            WHERE sa.InstituteId=@InstituteId AND sa.SessionId=@SessionId
              AND (@CourseId=0 OR sa.CourseId=@CourseId)
            GROUP BY up.Gender;");
        cmd.Parameters.AddWithValue("@InstituteId", instituteId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);
        cmd.Parameters.AddWithValue("@CourseId", courseId);
        return dl.GetDataTable(cmd);
    }

    // Section-wise student count
    public DataTable GetSectionWiseStudents(int instituteId, int sessionId, int courseId)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT sec.SectionName,
                   COUNT(DISTINCT sa.UserId) AS Students
            FROM StudentAcademicDetails sa
            JOIN Sections sec ON sa.SectionId=sec.SectionId
            WHERE sa.InstituteId=@InstituteId AND sa.SessionId=@SessionId
              AND (@CourseId=0 OR sa.CourseId=@CourseId)
            GROUP BY sec.SectionName
            ORDER BY Students DESC;");
        cmd.Parameters.AddWithValue("@InstituteId", instituteId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);
        cmd.Parameters.AddWithValue("@CourseId", courseId);
        return dl.GetDataTable(cmd);
    }

    // Assignment submission rate per subject
    public DataTable GetAssignmentSubmissionRate(int instituteId, int sessionId, int courseId)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT TOP 6
                sub.SubjectName,
                COUNT(DISTINCT a.AssignmentId)    AS TotalAssign,
                COUNT(DISTINCT asub.SubmissionId) AS Submitted,
                CAST(100.0*COUNT(DISTINCT asub.SubmissionId)
                     /NULLIF(COUNT(DISTINCT a.AssignmentId)*
                       (SELECT COUNT(*) FROM StudentAcademicDetails sa2
                        WHERE sa2.InstituteId=@InstituteId AND sa2.SessionId=@SessionId
                          AND (@CourseId=0 OR sa2.CourseId=@CourseId)),0)
                AS DECIMAL(5,2)) AS SubRate
            FROM Subjects sub
            LEFT JOIN Assignments a ON a.SubjectId=sub.SubjectId AND a.SessionId=@SessionId
            LEFT JOIN AssignmentSubmissions asub ON asub.AssignmentId=a.AssignmentId
            WHERE sub.InstituteId=@InstituteId AND sub.SessionId=@SessionId
            GROUP BY sub.SubjectId,sub.SubjectName
            HAVING COUNT(DISTINCT a.AssignmentId)>0
            ORDER BY Submitted DESC;");
        cmd.Parameters.AddWithValue("@InstituteId", instituteId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);
        cmd.Parameters.AddWithValue("@CourseId", courseId);
        return dl.GetDataTable(cmd);
    }
}