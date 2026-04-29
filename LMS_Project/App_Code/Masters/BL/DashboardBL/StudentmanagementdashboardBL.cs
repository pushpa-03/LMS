using System;
using System.Data;
using System.Data.SqlClient;

/// <summary>
/// BL for Student Management Dashboard
/// All methods accept optional filter parameters (0 = no filter applied)
/// </summary>
public class StudentManagementDashboardBL
{
    DataLayer dl = new DataLayer();

    // ════════════════════════════════════════════════════════════
    // DROPDOWN DATA METHODS
    // ════════════════════════════════════════════════════════════

    public DataTable GetStreams(int instituteId, int sessionId)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT StreamId, StreamName
            FROM   Streams
            WHERE  InstituteId=@Inst AND SessionId=@Sess AND IsActive=1
            ORDER  BY StreamName;");
        cmd.Parameters.AddWithValue("@Inst", instituteId);
        cmd.Parameters.AddWithValue("@Sess", sessionId);
        return dl.GetDataTable(cmd);
    }

    public DataTable GetCoursesByStream(int instituteId, int sessionId, int streamId)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT CourseId,
                   CourseName + ISNULL(' ('+CourseCode+')','') AS CourseDisplay
            FROM   Courses
            WHERE  InstituteId=@Inst AND SessionId=@Sess AND IsActive=1
              AND  (@Stream=0 OR StreamId=@Stream)
            ORDER  BY CourseName;");
        cmd.Parameters.AddWithValue("@Inst", instituteId);
        cmd.Parameters.AddWithValue("@Sess", sessionId);
        cmd.Parameters.AddWithValue("@Stream", streamId);
        return dl.GetDataTable(cmd);
    }

    public DataTable GetSemesters(int instituteId, int sessionId)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT SemesterId, SemesterName
            FROM   Semesters
            WHERE  InstituteId=@Inst AND SessionId=@Sess
            ORDER  BY SemesterName;");
        cmd.Parameters.AddWithValue("@Inst", instituteId);
        cmd.Parameters.AddWithValue("@Sess", sessionId);
        return dl.GetDataTable(cmd);
    }

    public DataTable GetSections(int instituteId, int sessionId)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT SectionId, SectionName
            FROM   Sections
            WHERE  InstituteId=@Inst AND SessionId=@Sess AND IsActive=1
            ORDER  BY SectionName;");
        cmd.Parameters.AddWithValue("@Inst", instituteId);
        cmd.Parameters.AddWithValue("@Sess", sessionId);
        return dl.GetDataTable(cmd);
    }

    // ════════════════════════════════════════════════════════════
    // KPI SUMMARY — live totals with all filters applied
    // ════════════════════════════════════════════════════════════
    public DataTable GetKPISummary(int instituteId, int sessionId,
        int streamId, int courseId, int semesterId, int sectionId,
        string gender, string joinMonth, string joinYear)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT
              COUNT(DISTINCT sa.UserId)                           AS TotalStudents,
              SUM(CASE WHEN u.IsActive=1 THEN 1 ELSE 0 END)      AS ActiveStudents,
              SUM(CASE WHEN u.IsActive=0 THEN 1 ELSE 0 END)      AS InactiveStudents,
              SUM(CASE WHEN u.IsFirstLogin=1 THEN 1 ELSE 0 END)  AS NewAdmissions,

              -- Attendance avg
              ISNULL(CAST(
                100.0*SUM(CASE WHEN a.Status='Present' THEN 1 ELSE 0 END)
                /NULLIF(COUNT(a.AttendanceId),0)
              AS DECIMAL(5,2)),0)                                 AS AttendancePct,

              -- Assignment submission rate
              ISNULL(CAST(
                100.0*COUNT(DISTINCT asub.SubmissionId)
                /NULLIF(COUNT(DISTINCT asgn.AssignmentId)*COUNT(DISTINCT sa.UserId),0)
              AS DECIMAL(5,2)),0)                                 AS AssignmentRate,

              -- Avg quiz score
              ISNULL(CAST(AVG(CAST(qr.Score AS FLOAT)) AS DECIMAL(5,2)),0) AS AvgQuizScore,

              -- Male/Female/Other counts
              SUM(CASE WHEN up.Gender='Male'   THEN 1 ELSE 0 END) AS Males,
              SUM(CASE WHEN up.Gender='Female' THEN 1 ELSE 0 END) AS Females,
              SUM(CASE WHEN up.Gender NOT IN ('Male','Female') OR up.Gender IS NULL THEN 1 ELSE 0 END) AS Others

            FROM StudentAcademicDetails sa
            INNER JOIN Users       u   ON u.UserId      = sa.UserId
            INNER JOIN UserProfile up  ON up.UserId     = sa.UserId
            LEFT  JOIN Attendance  a   ON a.UserId      = sa.UserId
                                      AND a.InstituteId = @Inst
                                      AND a.SessionId   = @Sess
            LEFT  JOIN Assignments asgn ON asgn.InstituteId=@Inst AND asgn.SessionId=@Sess
            LEFT  JOIN AssignmentSubmissions asub
                       ON asub.StudentId    = sa.UserId
                      AND asub.AssignmentId = asgn.AssignmentId
                      AND asub.SessionId    = @Sess
            LEFT  JOIN QuizResults qr  ON qr.StudentId  = sa.UserId
                                       AND qr.SessionId = @Sess
                                       AND qr.InstituteId=@Inst
            WHERE sa.InstituteId = @Inst
              AND sa.SessionId   = @Sess
              AND (@Stream   = 0 OR sa.StreamId   = @Stream)
              AND (@Course   = 0 OR sa.CourseId   = @Course)
              AND (@Semester = 0 OR sa.SemesterId = @Semester)
              AND (@Section  = 0 OR sa.SectionId  = @Section)
              AND (@Gender   = '' OR up.Gender     = @Gender)
              AND (@Month    = '' OR MONTH(up.JoinedDate) = TRY_CAST(@Month AS INT))
              AND (@Year     = '' OR YEAR(up.JoinedDate)  = TRY_CAST(@Year  AS INT));");

        AddCommonParams(cmd, instituteId, sessionId, streamId, courseId,
                        semesterId, sectionId, gender, joinMonth, joinYear);
        return dl.GetDataTable(cmd);
    }

    // ════════════════════════════════════════════════════════════
    // STUDENT LIST — paginated grid with search
    // ════════════════════════════════════════════════════════════
    public DataTable GetStudentList(int instituteId, int sessionId,
        int streamId, int courseId, int semesterId, int sectionId,
        string gender, string joinMonth, string joinYear,
        string search, int pageIndex, int pageSize)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT * FROM (
              SELECT
                ROW_NUMBER() OVER (ORDER BY up.FullName) AS RowNum,
                sa.UserId,
                up.FullName,
                ISNULL(sa.RollNumber,'—')           AS RollNumber,
                ISNULL(st.StreamName,'—')           AS StreamName,
                ISNULL(c.CourseName,'—')            AS CourseName,
                ISNULL(sem.SemesterName,'—')        AS SemesterName,
                ISNULL(sec.SectionName,'—')         AS SectionName,
                up.Gender,
                up.ContactNo,
                up.ProfileImage,
                CONVERT(VARCHAR(10),up.JoinedDate,105) AS JoinedDate,
                CASE WHEN u.IsActive=1 THEN 'Active' ELSE 'Inactive' END AS Status,
                CASE WHEN u.IsFirstLogin=1 THEN 'New' ELSE 'Returning' END AS AdmissionType,

                -- Attendance
                ISNULL(CAST(
                  100.0*SUM(CASE WHEN a.Status='Present' THEN 1 ELSE 0 END)
                  /NULLIF(COUNT(a.AttendanceId),0)
                AS DECIMAL(5,1)),0) AS AttPct,

                -- Quiz avg
                ISNULL(CAST(AVG(CAST(qr.Score AS FLOAT)) AS DECIMAL(5,1)),0) AS AvgScore,

                -- Submissions count
                COUNT(DISTINCT asub.SubmissionId) AS Submissions

              FROM StudentAcademicDetails sa
              INNER JOIN Users       u    ON u.UserId      = sa.UserId
              INNER JOIN UserProfile up   ON up.UserId     = sa.UserId
              LEFT  JOIN Streams     st   ON st.StreamId   = sa.StreamId
              LEFT  JOIN Courses     c    ON c.CourseId    = sa.CourseId
              LEFT  JOIN Semesters   sem  ON sem.SemesterId= sa.SemesterId
              LEFT  JOIN Sections    sec  ON sec.SectionId = sa.SectionId
              LEFT  JOIN Attendance  a    ON a.UserId      = sa.UserId
                                         AND a.InstituteId = @Inst
                                         AND a.SessionId   = @Sess
              LEFT  JOIN QuizResults qr   ON qr.StudentId  = sa.UserId
                                         AND qr.SessionId  = @Sess
                                         AND qr.InstituteId= @Inst
              LEFT  JOIN AssignmentSubmissions asub
                         ON asub.StudentId = sa.UserId
                        AND asub.SessionId = @Sess
                        AND asub.InstituteId=@Inst
              WHERE sa.InstituteId = @Inst
                AND sa.SessionId   = @Sess
                AND (@Stream   = 0 OR sa.StreamId   = @Stream)
                AND (@Course   = 0 OR sa.CourseId   = @Course)
                AND (@Semester = 0 OR sa.SemesterId = @Semester)
                AND (@Section  = 0 OR sa.SectionId  = @Section)
                AND (@Gender   = '' OR up.Gender     = @Gender)
                AND (@Month    = '' OR MONTH(up.JoinedDate) = TRY_CAST(@Month AS INT))
                AND (@Year     = '' OR YEAR(up.JoinedDate)  = TRY_CAST(@Year  AS INT))
                AND (@Search   = '' OR up.FullName   LIKE '%'+@Search+'%'
                                    OR sa.RollNumber LIKE '%'+@Search+'%'
                                    OR up.ContactNo  LIKE '%'+@Search+'%')
              GROUP BY
                sa.UserId, up.FullName, sa.RollNumber, st.StreamName,
                c.CourseName, sem.SemesterName, sec.SectionName,
                up.Gender, up.ContactNo, up.ProfileImage,
                up.JoinedDate, u.IsActive, u.IsFirstLogin
            ) T
            WHERE RowNum BETWEEN @Skip+1 AND @Skip+@Size;");

        AddCommonParams(cmd, instituteId, sessionId, streamId, courseId,
                        semesterId, sectionId, gender, joinMonth, joinYear);
        cmd.Parameters.AddWithValue("@Search", search ?? "");
        cmd.Parameters.AddWithValue("@Skip", pageIndex * pageSize);
        cmd.Parameters.AddWithValue("@Size", pageSize);
        return dl.GetDataTable(cmd);
    }

    public int GetStudentCount(int instituteId, int sessionId,
        int streamId, int courseId, int semesterId, int sectionId,
        string gender, string joinMonth, string joinYear, string search)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT COUNT(DISTINCT sa.UserId)
            FROM StudentAcademicDetails sa
            INNER JOIN Users       u   ON u.UserId  = sa.UserId
            INNER JOIN UserProfile up  ON up.UserId = sa.UserId
            WHERE sa.InstituteId = @Inst
              AND sa.SessionId   = @Sess
              AND (@Stream   = 0 OR sa.StreamId   = @Stream)
              AND (@Course   = 0 OR sa.CourseId   = @Course)
              AND (@Semester = 0 OR sa.SemesterId = @Semester)
              AND (@Section  = 0 OR sa.SectionId  = @Section)
              AND (@Gender   = '' OR up.Gender     = @Gender)
              AND (@Month    = '' OR MONTH(up.JoinedDate) = TRY_CAST(@Month AS INT))
              AND (@Year     = '' OR YEAR(up.JoinedDate)  = TRY_CAST(@Year  AS INT))
              AND (@Search   = '' OR up.FullName   LIKE '%'+@Search+'%'
                                  OR sa.RollNumber LIKE '%'+@Search+'%');");
        AddCommonParams(cmd, instituteId, sessionId, streamId, courseId,
                        semesterId, sectionId, gender, joinMonth, joinYear);
        cmd.Parameters.AddWithValue("@Search", search ?? "");
        object result = dl.GetDataTable(cmd)?.Rows[0][0];
        return result == null || result == DBNull.Value ? 0 : Convert.ToInt32(result);
    }

    // ════════════════════════════════════════════════════════════
    // MONTHLY ENROLLMENT TREND (12 months)
    // ════════════════════════════════════════════════════════════
    public DataTable GetMonthlyEnrollment(int instituteId, int sessionId,
        int streamId, int courseId)
    {
        SqlCommand cmd = new SqlCommand(@"
            WITH Months AS (
              SELECT TOP 12
                MONTH(DATEADD(MONTH,-n,GETDATE())) M,
                YEAR (DATEADD(MONTH,-n,GETDATE())) Y,
                LEFT(DATENAME(MONTH,DATEADD(MONTH,-n,GETDATE())),3) MName
              FROM (VALUES(0),(1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11)) T(n)
            )
            SELECT m.MName AS Mon, m.M, m.Y,
                   COUNT(sa.UserId) AS Students,
                   SUM(CASE WHEN u.IsActive=1 THEN 1 ELSE 0 END) AS Active
            FROM Months m
            LEFT JOIN StudentAcademicDetails sa
                ON MONTH(sa.JoinedOn)=m.M AND YEAR(sa.JoinedOn)=m.Y
               AND sa.InstituteId=@Inst AND sa.SessionId=@Sess
               AND (@Stream=0 OR sa.StreamId=@Stream)
               AND (@Course=0 OR sa.CourseId=@Course)
            LEFT JOIN Users u ON u.UserId=sa.UserId
            GROUP BY m.MName,m.M,m.Y
            ORDER BY m.Y,m.M;");
        cmd.Parameters.AddWithValue("@Inst", instituteId);
        cmd.Parameters.AddWithValue("@Sess", sessionId);
        cmd.Parameters.AddWithValue("@Stream", streamId);
        cmd.Parameters.AddWithValue("@Course", courseId);
        return dl.GetDataTable(cmd);
    }

    // ════════════════════════════════════════════════════════════
    // ATTENDANCE TREND — last 30 days
    // ════════════════════════════════════════════════════════════
    public DataTable GetAttendanceTrend(int instituteId, int sessionId,
        int streamId, int courseId, int sectionId)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT
              CONVERT(VARCHAR(6),a.Date,106) AS DayLbl,
              a.Date,
              CAST(100.0*SUM(CASE WHEN a.Status='Present' THEN 1 ELSE 0 END)
                   /NULLIF(COUNT(*),0) AS DECIMAL(5,1)) AS AttPct,
              SUM(CASE WHEN a.Status='Present' THEN 1 ELSE 0 END) AS Present,
              SUM(CASE WHEN a.Status='Absent'  THEN 1 ELSE 0 END) AS Absent,
              SUM(CASE WHEN a.Status='Leave'   THEN 1 ELSE 0 END) AS OnLeave
            FROM Attendance a
            JOIN StudentAcademicDetails sa ON a.UserId=sa.UserId
            WHERE a.InstituteId=@Inst AND a.SessionId=@Sess
              AND a.Date >= CAST(DATEADD(DAY,-29,GETDATE()) AS DATE)
              AND (@Stream  =0 OR sa.StreamId =@Stream)
              AND (@Course  =0 OR sa.CourseId =@Course)
              AND (@Section =0 OR sa.SectionId=@Section)
            GROUP BY a.Date
            ORDER BY a.Date;");
        cmd.Parameters.AddWithValue("@Inst", instituteId);
        cmd.Parameters.AddWithValue("@Sess", sessionId);
        cmd.Parameters.AddWithValue("@Stream", streamId);
        cmd.Parameters.AddWithValue("@Course", courseId);
        cmd.Parameters.AddWithValue("@Section", sectionId);
        return dl.GetDataTable(cmd);
    }

    // ════════════════════════════════════════════════════════════
    // GENDER DISTRIBUTION
    // ════════════════════════════════════════════════════════════
    public DataTable GetGenderDistribution(int instituteId, int sessionId,
        int streamId, int courseId)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT ISNULL(up.Gender,'Unknown') AS Gender, COUNT(*) AS Total
            FROM StudentAcademicDetails sa
            JOIN UserProfile up ON up.UserId=sa.UserId
            WHERE sa.InstituteId=@Inst AND sa.SessionId=@Sess
              AND (@Stream=0 OR sa.StreamId=@Stream)
              AND (@Course=0 OR sa.CourseId=@Course)
            GROUP BY up.Gender ORDER BY Total DESC;");
        cmd.Parameters.AddWithValue("@Inst", instituteId);
        cmd.Parameters.AddWithValue("@Sess", sessionId);
        cmd.Parameters.AddWithValue("@Stream", streamId);
        cmd.Parameters.AddWithValue("@Course", courseId);
        return dl.GetDataTable(cmd);
    }

    // ════════════════════════════════════════════════════════════
    // STREAM-WISE STUDENT COUNT
    // ════════════════════════════════════════════════════════════
    public DataTable GetStreamWiseCount(int instituteId, int sessionId)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT st.StreamName, COUNT(DISTINCT sa.UserId) AS Students
            FROM StudentAcademicDetails sa
            JOIN Streams st ON st.StreamId=sa.StreamId
            WHERE sa.InstituteId=@Inst AND sa.SessionId=@Sess
            GROUP BY st.StreamName ORDER BY Students DESC;");
        cmd.Parameters.AddWithValue("@Inst", instituteId);
        cmd.Parameters.AddWithValue("@Sess", sessionId);
        return dl.GetDataTable(cmd);
    }

    // ════════════════════════════════════════════════════════════
    // COURSE-WISE STUDENT COUNT
    // ════════════════════════════════════════════════════════════
    public DataTable GetCourseWiseCount(int instituteId, int sessionId, int streamId)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT c.CourseName, COUNT(DISTINCT sa.UserId) AS Students
            FROM StudentAcademicDetails sa
            JOIN Courses c ON c.CourseId=sa.CourseId
            WHERE sa.InstituteId=@Inst AND sa.SessionId=@Sess
              AND (@Stream=0 OR sa.StreamId=@Stream)
            GROUP BY c.CourseName ORDER BY Students DESC;");
        cmd.Parameters.AddWithValue("@Inst", instituteId);
        cmd.Parameters.AddWithValue("@Sess", sessionId);
        cmd.Parameters.AddWithValue("@Stream", streamId);
        return dl.GetDataTable(cmd);
    }

    // ════════════════════════════════════════════════════════════
    // QUIZ PERFORMANCE DISTRIBUTION (grade buckets)
    // ════════════════════════════════════════════════════════════
    public DataTable GetGradeDistribution(int instituteId, int sessionId,
        int streamId, int courseId)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT
              CASE
                WHEN avgScore >= 90 THEN 'A+ (90-100)'
                WHEN avgScore >= 80 THEN 'A  (80-89)'
                WHEN avgScore >= 70 THEN 'B+ (70-79)'
                WHEN avgScore >= 60 THEN 'B  (60-69)'
                WHEN avgScore >= 50 THEN 'C  (50-59)'
                WHEN avgScore >= 33 THEN 'D  (33-49)'
                ELSE                     'F  (<33)'
              END AS GradeLabel,
              COUNT(*) AS Students
            FROM (
              SELECT sa.UserId,
                     ISNULL(CAST(AVG(CAST(qr.Score AS FLOAT)) AS DECIMAL(5,1)),0) AS avgScore
              FROM StudentAcademicDetails sa
              LEFT JOIN QuizResults qr
                ON qr.StudentId=sa.UserId AND qr.SessionId=@Sess AND qr.InstituteId=@Inst
              WHERE sa.InstituteId=@Inst AND sa.SessionId=@Sess
                AND (@Stream=0 OR sa.StreamId=@Stream)
                AND (@Course=0 OR sa.CourseId=@Course)
              GROUP BY sa.UserId
            ) X
            GROUP BY
              CASE
                WHEN avgScore >= 90 THEN 'A+ (90-100)'
                WHEN avgScore >= 80 THEN 'A  (80-89)'
                WHEN avgScore >= 70 THEN 'B+ (70-79)'
                WHEN avgScore >= 60 THEN 'B  (60-69)'
                WHEN avgScore >= 50 THEN 'C  (50-59)'
                WHEN avgScore >= 33 THEN 'D  (33-49)'
                ELSE                     'F  (<33)'
              END
            ORDER BY MIN(avgScore) DESC;");
        cmd.Parameters.AddWithValue("@Inst", instituteId);
        cmd.Parameters.AddWithValue("@Sess", sessionId);
        cmd.Parameters.AddWithValue("@Stream", streamId);
        cmd.Parameters.AddWithValue("@Course", courseId);
        return dl.GetDataTable(cmd);
    }

    // ════════════════════════════════════════════════════════════
    // TOP 10 STUDENTS by performance
    // ════════════════════════════════════════════════════════════
    public DataTable GetTopStudents(int instituteId, int sessionId,
        int streamId, int courseId)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT TOP 10
              up.FullName,
              ISNULL(sa.RollNumber,'—')           AS RollNumber,
              ISNULL(c.CourseName,'—')            AS CourseName,
              ISNULL(sem.SemesterName,'—')        AS SemesterName,
              ISNULL(up.ProfileImage,'')          AS ProfileImage,
              ISNULL(CAST(AVG(CAST(qr.Score AS FLOAT)) AS DECIMAL(5,1)),0) AS AvgScore,
              ISNULL(CAST(
                100.0*SUM(CASE WHEN a.Status='Present' THEN 1 ELSE 0 END)
                /NULLIF(COUNT(DISTINCT a.AttendanceId),0)
              AS DECIMAL(5,1)),0) AS AttPct,
              COUNT(DISTINCT asub.SubmissionId) AS Submissions,
              COUNT(DISTINCT qr.ResultId)       AS QuizAttempts
            FROM StudentAcademicDetails sa
            INNER JOIN UserProfile up  ON up.UserId    = sa.UserId
            LEFT  JOIN Courses     c   ON c.CourseId   = sa.CourseId
            LEFT  JOIN Semesters   sem ON sem.SemesterId=sa.SemesterId
            LEFT  JOIN QuizResults qr  ON qr.StudentId = sa.UserId
                                       AND qr.SessionId= @Sess AND qr.InstituteId=@Inst
            LEFT  JOIN Attendance  a   ON a.UserId     = sa.UserId
                                       AND a.SessionId = @Sess AND a.InstituteId=@Inst
            LEFT  JOIN AssignmentSubmissions asub
                       ON asub.StudentId  = sa.UserId
                      AND asub.SessionId  = @Sess AND asub.InstituteId=@Inst
            WHERE sa.InstituteId=@Inst AND sa.SessionId=@Sess
              AND (@Stream=0 OR sa.StreamId=@Stream)
              AND (@Course=0 OR sa.CourseId=@Course)
            GROUP BY sa.UserId,up.FullName,sa.RollNumber,
                     c.CourseName,sem.SemesterName,up.ProfileImage
            ORDER BY AvgScore DESC, AttPct DESC;");
        cmd.Parameters.AddWithValue("@Inst", instituteId);
        cmd.Parameters.AddWithValue("@Sess", sessionId);
        cmd.Parameters.AddWithValue("@Stream", streamId);
        cmd.Parameters.AddWithValue("@Course", courseId);
        return dl.GetDataTable(cmd);
    }

    // ════════════════════════════════════════════════════════════
    // AT-RISK STUDENTS (low attendance OR low score)
    // ════════════════════════════════════════════════════════════
    public DataTable GetAtRiskStudents(int instituteId, int sessionId,
        int streamId, int courseId)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT TOP 10
              up.FullName,
              ISNULL(sa.RollNumber,'—')    AS RollNumber,
              ISNULL(c.CourseName,'—')     AS CourseName,
              ISNULL(up.ProfileImage,'')   AS ProfileImage,
              ISNULL(CAST(
                100.0*SUM(CASE WHEN a.Status='Present' THEN 1 ELSE 0 END)
                /NULLIF(COUNT(DISTINCT a.AttendanceId),0)
              AS DECIMAL(5,1)),0) AS AttPct,
              ISNULL(CAST(AVG(CAST(qr.Score AS FLOAT)) AS DECIMAL(5,1)),0) AS AvgScore,
              CASE
                WHEN ISNULL(CAST(
                  100.0*SUM(CASE WHEN a.Status='Present' THEN 1 ELSE 0 END)
                  /NULLIF(COUNT(DISTINCT a.AttendanceId),0)
                AS DECIMAL(5,1)),0) < 60 THEN 'Low Attendance'
                WHEN ISNULL(CAST(AVG(CAST(qr.Score AS FLOAT)) AS DECIMAL(5,1)),0) < 33 THEN 'Failing'
                ELSE 'At Risk'
              END AS RiskReason
            FROM StudentAcademicDetails sa
            INNER JOIN UserProfile up ON up.UserId=sa.UserId
            LEFT  JOIN Courses     c  ON c.CourseId=sa.CourseId
            LEFT  JOIN Attendance  a  ON a.UserId=sa.UserId
                                     AND a.SessionId=@Sess AND a.InstituteId=@Inst
            LEFT  JOIN QuizResults qr ON qr.StudentId=sa.UserId
                                     AND qr.SessionId=@Sess AND qr.InstituteId=@Inst
            WHERE sa.InstituteId=@Inst AND sa.SessionId=@Sess
              AND (@Stream=0 OR sa.StreamId=@Stream)
              AND (@Course=0 OR sa.CourseId=@Course)
            GROUP BY sa.UserId,up.FullName,sa.RollNumber,c.CourseName,up.ProfileImage
            HAVING
              ISNULL(CAST(
                100.0*SUM(CASE WHEN a.Status='Present' THEN 1 ELSE 0 END)
                /NULLIF(COUNT(DISTINCT a.AttendanceId),0)
              AS DECIMAL(5,1)),0) < 75
              OR
              ISNULL(CAST(AVG(CAST(qr.Score AS FLOAT)) AS DECIMAL(5,1)),0) < 40
            ORDER BY AttPct ASC, AvgScore ASC;");
        cmd.Parameters.AddWithValue("@Inst", instituteId);
        cmd.Parameters.AddWithValue("@Sess", sessionId);
        cmd.Parameters.AddWithValue("@Stream", streamId);
        cmd.Parameters.AddWithValue("@Course", courseId);
        return dl.GetDataTable(cmd);
    }

    // ════════════════════════════════════════════════════════════
    // NEW ADMISSIONS by month (bar chart)
    // ════════════════════════════════════════════════════════════
    public DataTable GetAdmissionsByMonth(int instituteId, int sessionId, string year)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT
              LEFT(DATENAME(MONTH,up.JoinedDate),3) AS Mon,
              MONTH(up.JoinedDate) AS MonNum,
              COUNT(*) AS Count
            FROM StudentAcademicDetails sa
            JOIN UserProfile up ON up.UserId=sa.UserId
            WHERE sa.InstituteId=@Inst AND sa.SessionId=@Sess
              AND (@Year='' OR YEAR(up.JoinedDate)=TRY_CAST(@Year AS INT))
            GROUP BY MONTH(up.JoinedDate), LEFT(DATENAME(MONTH,up.JoinedDate),3)
            ORDER BY MonNum;");
        cmd.Parameters.AddWithValue("@Inst", instituteId);
        cmd.Parameters.AddWithValue("@Sess", sessionId);
        cmd.Parameters.AddWithValue("@Year", year ?? "");
        return dl.GetDataTable(cmd);
    }

    // ════════════════════════════════════════════════════════════
    // SECTION-WISE COUNT
    // ════════════════════════════════════════════════════════════
    public DataTable GetSectionWiseCount(int instituteId, int sessionId,
        int streamId, int courseId)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT ISNULL(sec.SectionName,'Unassigned') AS SectionName,
                   COUNT(DISTINCT sa.UserId) AS Students
            FROM StudentAcademicDetails sa
            LEFT JOIN Sections sec ON sec.SectionId=sa.SectionId
            WHERE sa.InstituteId=@Inst AND sa.SessionId=@Sess
              AND (@Stream=0 OR sa.StreamId=@Stream)
              AND (@Course=0 OR sa.CourseId=@Course)
            GROUP BY sec.SectionName ORDER BY Students DESC;");
        cmd.Parameters.AddWithValue("@Inst", instituteId);
        cmd.Parameters.AddWithValue("@Sess", sessionId);
        cmd.Parameters.AddWithValue("@Stream", streamId);
        cmd.Parameters.AddWithValue("@Course", courseId);
        return dl.GetDataTable(cmd);
    }

    // ════════════════════════════════════════════════════════════
    // HELPER: add all common filter params
    // ════════════════════════════════════════════════════════════
    private void AddCommonParams(SqlCommand cmd,
        int instituteId, int sessionId,
        int streamId, int courseId, int semesterId, int sectionId,
        string gender, string joinMonth, string joinYear)
    {
        cmd.Parameters.AddWithValue("@Inst", instituteId);
        cmd.Parameters.AddWithValue("@Sess", sessionId);
        cmd.Parameters.AddWithValue("@Stream", streamId);
        cmd.Parameters.AddWithValue("@Course", courseId);
        cmd.Parameters.AddWithValue("@Semester", semesterId);
        cmd.Parameters.AddWithValue("@Section", sectionId);
        cmd.Parameters.AddWithValue("@Gender", gender ?? "");
        cmd.Parameters.AddWithValue("@Month", joinMonth ?? "");
        cmd.Parameters.AddWithValue("@Year", joinYear ?? "");
    }
}