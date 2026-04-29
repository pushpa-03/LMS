using System;
using System.Data;
using System.Data.SqlClient;

/// <summary>
/// BL for Attendance Analytics Dashboard
/// All filter params: 0 / "" = no filter (show all)
/// Date range: dateFrom / dateTo as strings "yyyy-MM-dd"
/// </summary>
public class AttendanceAnalyticsDashboardBL
{
    DataLayer dl = new DataLayer();

    // ═══════════════════════════════════════════════════════════
    // DROPDOWN LOADERS
    // ═══════════════════════════════════════════════════════════
    public DataTable GetStreams(int instituteId, int sessionId)
    {
        var cmd = new SqlCommand(@"
            SELECT StreamId, StreamName FROM Streams
            WHERE InstituteId=@Inst AND SessionId=@Sess AND IsActive=1
            ORDER BY StreamName;");
        cmd.Parameters.AddWithValue("@Inst", instituteId);
        cmd.Parameters.AddWithValue("@Sess", sessionId);
        return dl.GetDataTable(cmd);
    }

    public DataTable GetCourses(int instituteId, int sessionId, int streamId)
    {
        var cmd = new SqlCommand(@"
            SELECT CourseId,
                   CourseName + ISNULL(' ('+CourseCode+')','') AS CourseDisplay
            FROM Courses
            WHERE InstituteId=@Inst AND SessionId=@Sess AND IsActive=1
              AND (@Stream=0 OR StreamId=@Stream)
            ORDER BY CourseName;");
        cmd.Parameters.AddWithValue("@Inst", instituteId);
        cmd.Parameters.AddWithValue("@Sess", sessionId);
        cmd.Parameters.AddWithValue("@Stream", streamId);
        return dl.GetDataTable(cmd);
    }

    public DataTable GetSections(int instituteId, int sessionId)
    {
        var cmd = new SqlCommand(@"
            SELECT SectionId, SectionName FROM Sections
            WHERE InstituteId=@Inst AND SessionId=@Sess AND IsActive=1
            ORDER BY SectionName;");
        cmd.Parameters.AddWithValue("@Inst", instituteId);
        cmd.Parameters.AddWithValue("@Sess", sessionId);
        return dl.GetDataTable(cmd);
    }

    public DataTable GetSubjects(int instituteId, int sessionId, int streamId, int courseId)
    {
        var cmd = new SqlCommand(@"
            SELECT DISTINCT 
                s.SubjectId,
                LTRIM(RTRIM(s.SubjectName)) AS SubjectName
            FROM Subjects s
            LEFT JOIN LevelSemesterSubjects lss
                ON lss.SubjectId = s.SubjectId 
                AND lss.InstituteId = @Inst 
                AND lss.SessionId = @Sess
            WHERE s.InstituteId = @Inst 
              AND s.SessionId = @Sess 
              AND s.IsActive = 1
              AND (@Stream = 0 OR lss.StreamId = @Stream)
              AND (@Course = 0 OR lss.CourseId = @Course)
            ORDER BY SubjectName;");
        cmd.Parameters.AddWithValue("@Inst", instituteId);
        cmd.Parameters.AddWithValue("@Sess", sessionId);
        cmd.Parameters.AddWithValue("@Stream", streamId);
        cmd.Parameters.AddWithValue("@Course", courseId);
        return dl.GetDataTable(cmd);
    }

    public DataTable GetSemesters(int instituteId, int sessionId)
    {
        var cmd = new SqlCommand(@"
            SELECT SemesterId, SemesterName FROM Semesters
            WHERE InstituteId=@Inst AND SessionId=@Sess ORDER BY SemesterName;");
        cmd.Parameters.AddWithValue("@Inst", instituteId);
        cmd.Parameters.AddWithValue("@Sess", sessionId);
        return dl.GetDataTable(cmd);
    }

    // ═══════════════════════════════════════════════════════════
    // KPI SUMMARY
    // ═══════════════════════════════════════════════════════════
    public DataTable GetKPISummary(int instituteId, int sessionId,
        int streamId, int courseId, int sectionId, int subjectId,
        string dateFrom, string dateTo, string gender)
    {
        var cmd = new SqlCommand(@"
            SELECT
              COUNT(*)                                                          AS TotalRecords,
              COUNT(DISTINCT a.UserId)                                          AS TotalStudents,
              COUNT(DISTINCT a.Date)                                            AS TotalDays,
              SUM(CASE WHEN a.Status='Present' THEN 1 ELSE 0 END)              AS TotalPresent,
              SUM(CASE WHEN a.Status='Absent'  THEN 1 ELSE 0 END)              AS TotalAbsent,
              SUM(CASE WHEN a.Status='Leave'   THEN 1 ELSE 0 END)              AS TotalLeave,

              CAST(100.0*SUM(CASE WHEN a.Status='Present' THEN 1 ELSE 0 END)
                   /NULLIF(COUNT(*),0) AS DECIMAL(5,2))                        AS OverallPct,

              -- Students with >= 75%
              (SELECT COUNT(*) FROM (
                SELECT a2.UserId,
                  CAST(100.0*SUM(CASE WHEN a2.Status='Present' THEN 1 ELSE 0 END)
                       /NULLIF(COUNT(*),0) AS DECIMAL(5,2)) AS Pct
                FROM Attendance a2
                INNER JOIN StudentAcademicDetails sa2 ON sa2.UserId=a2.UserId
                LEFT  JOIN UserProfile up2 ON up2.UserId=a2.UserId
                WHERE a2.InstituteId=@Inst AND a2.SessionId=@Sess
                  AND (@Stream  =0  OR sa2.StreamId  =@Stream)
                  AND (@Course  =0  OR sa2.CourseId  =@Course)
                  AND (@Section =0  OR sa2.SectionId =@Section)
                  AND (@Subject =0  OR a2.SubjectId  =@Subject)
                  AND (@Gender  ='' OR up2.Gender     =@Gender)
                  AND (CAST(@DFrom AS DATE) IS NULL OR a2.Date >= CAST(@DFrom AS DATE))
                  AND (CAST(@DTo   AS DATE) IS NULL OR a2.Date <= CAST(@DTo   AS DATE))
                GROUP BY a2.UserId
                HAVING CAST(100.0*SUM(CASE WHEN a2.Status='Present' THEN 1 ELSE 0 END)
                            /NULLIF(COUNT(*),0) AS DECIMAL(5,2)) >= 75
              ) X)                                                              AS StudentsAbove75,

              -- Students below 75%
              (SELECT COUNT(*) FROM (
                SELECT a3.UserId,
                  CAST(100.0*SUM(CASE WHEN a3.Status='Present' THEN 1 ELSE 0 END)
                       /NULLIF(COUNT(*),0) AS DECIMAL(5,2)) AS Pct
                FROM Attendance a3
                INNER JOIN StudentAcademicDetails sa3 ON sa3.UserId=a3.UserId
                LEFT  JOIN UserProfile up3 ON up3.UserId=a3.UserId
                WHERE a3.InstituteId=@Inst AND a3.SessionId=@Sess
                  AND (@Stream  =0  OR sa3.StreamId  =@Stream)
                  AND (@Course  =0  OR sa3.CourseId  =@Course)
                  AND (@Section =0  OR sa3.SectionId =@Section)
                  AND (@Subject =0  OR a3.SubjectId  =@Subject)
                  AND (@Gender  ='' OR up3.Gender     =@Gender)
                  AND (CAST(@DFrom AS DATE) IS NULL OR a3.Date >= CAST(@DFrom AS DATE))
                  AND (CAST(@DTo   AS DATE) IS NULL OR a3.Date <= CAST(@DTo   AS DATE))
                GROUP BY a3.UserId
                HAVING CAST(100.0*SUM(CASE WHEN a3.Status='Present' THEN 1 ELSE 0 END)
                            /NULLIF(COUNT(*),0) AS DECIMAL(5,2)) < 75
              ) X2)                                                             AS StudentsBelow75,

              -- Today's attendance
              ISNULL(CAST(100.0*SUM(CASE WHEN a.Status='Present' AND a.Date=CAST(GETDATE() AS DATE) THEN 1 ELSE 0 END)
                   /NULLIF(SUM(CASE WHEN a.Date=CAST(GETDATE() AS DATE) THEN 1 ELSE 0 END),0)
              AS DECIMAL(5,2)),0)                                               AS TodayPct

            FROM Attendance a
            INNER JOIN StudentAcademicDetails sa ON sa.UserId=a.UserId
            LEFT  JOIN UserProfile up ON up.UserId=a.UserId
            WHERE a.InstituteId=@Inst AND a.SessionId=@Sess
              AND (@Stream  =0  OR sa.StreamId  =@Stream)
              AND (@Course  =0  OR sa.CourseId  =@Course)
              AND (@Section =0  OR sa.SectionId =@Section)
              AND (@Subject =0  OR a.SubjectId  =@Subject)
              AND (@Gender  ='' OR up.Gender     =@Gender)
              AND (CAST(@DFrom AS DATE) IS NULL OR a.Date >= CAST(@DFrom AS DATE))
              AND (CAST(@DTo   AS DATE) IS NULL OR a.Date <= CAST(@DTo   AS DATE));");

        AddFilters(cmd, instituteId, sessionId, streamId, courseId,
                   sectionId, subjectId, dateFrom, dateTo, gender);
        return dl.GetDataTable(cmd);
    }

    // ═══════════════════════════════════════════════════════════
    // DAILY TREND — last N days or date range
    // ═══════════════════════════════════════════════════════════
    public DataTable GetDailyTrend(int instituteId, int sessionId,
        int streamId, int courseId, int sectionId, int subjectId,
        string dateFrom, string dateTo)
    {
        var cmd = new SqlCommand(@"
            SELECT
              CONVERT(VARCHAR(10), a.Date, 23)  AS DateStr,
              DATENAME(WEEKDAY, a.Date)          AS DayName,
              COUNT(*)                           AS Total,
              SUM(CASE WHEN a.Status='Present' THEN 1 ELSE 0 END) AS Present,
              SUM(CASE WHEN a.Status='Absent'  THEN 1 ELSE 0 END) AS Absent,
              SUM(CASE WHEN a.Status='Leave'   THEN 1 ELSE 0 END) AS OnLeave,
              CAST(100.0*SUM(CASE WHEN a.Status='Present' THEN 1 ELSE 0 END)
                   /NULLIF(COUNT(*),0) AS DECIMAL(5,2))           AS AttPct
            FROM Attendance a
            INNER JOIN StudentAcademicDetails sa ON sa.UserId=a.UserId
            WHERE a.InstituteId=@Inst AND a.SessionId=@Sess
              AND (@Stream  =0 OR sa.StreamId  =@Stream)
              AND (@Course  =0 OR sa.CourseId  =@Course)
              AND (@Section =0 OR sa.SectionId =@Section)
              AND (@Subject =0 OR a.SubjectId  =@Subject)
              AND (CAST(@DFrom AS DATE) IS NULL OR a.Date >= CAST(@DFrom AS DATE))
              AND (CAST(@DTo   AS DATE) IS NULL OR a.Date <= CAST(@DTo   AS DATE))
            GROUP BY a.Date
            ORDER BY a.Date;");
        AddFilters(cmd, instituteId, sessionId, streamId, courseId,
                   sectionId, subjectId, dateFrom, dateTo, "");
        return dl.GetDataTable(cmd);
    }

    // ═══════════════════════════════════════════════════════════
    // WEEKLY SUMMARY
    // ═══════════════════════════════════════════════════════════
    public DataTable GetWeeklySummary(int instituteId, int sessionId,
        int streamId, int courseId, string dateFrom, string dateTo)
    {
        var cmd = new SqlCommand(@"
            SELECT
              DATEPART(ISO_WEEK, a.Date)          AS WeekNum,
              MIN(a.Date)                          AS WeekStart,
              'Wk '+ CAST(ROW_NUMBER() OVER(ORDER BY DATEPART(ISO_WEEK,a.Date)) AS VARCHAR) AS WeekLabel,
              COUNT(*)                             AS Total,
              SUM(CASE WHEN a.Status='Present' THEN 1 ELSE 0 END) AS Present,
              SUM(CASE WHEN a.Status='Absent'  THEN 1 ELSE 0 END) AS Absent,
              CAST(100.0*SUM(CASE WHEN a.Status='Present' THEN 1 ELSE 0 END)
                   /NULLIF(COUNT(*),0) AS DECIMAL(5,2))           AS AttPct
            FROM Attendance a
            INNER JOIN StudentAcademicDetails sa ON sa.UserId=a.UserId
            WHERE a.InstituteId=@Inst AND a.SessionId=@Sess
              AND (@Stream=0 OR sa.StreamId=@Stream)
              AND (@Course=0 OR sa.CourseId=@Course)
              AND (CAST(@DFrom AS DATE) IS NULL OR a.Date >= CAST(@DFrom AS DATE))
              AND (CAST(@DTo   AS DATE) IS NULL OR a.Date <= CAST(@DTo   AS DATE))
            GROUP BY DATEPART(ISO_WEEK, a.Date)
            ORDER BY WeekNum;");
        cmd.Parameters.AddWithValue("@Inst", instituteId);
        cmd.Parameters.AddWithValue("@Sess", sessionId);
        cmd.Parameters.AddWithValue("@Stream", streamId);
        cmd.Parameters.AddWithValue("@Course", courseId);
        cmd.Parameters.AddWithValue("@DFrom", string.IsNullOrEmpty(dateFrom) ? (object)DBNull.Value : dateFrom);
        cmd.Parameters.AddWithValue("@DTo", string.IsNullOrEmpty(dateTo) ? (object)DBNull.Value : dateTo);
        return dl.GetDataTable(cmd);
    }

    // ═══════════════════════════════════════════════════════════
    // MONTHLY SUMMARY
    // ═══════════════════════════════════════════════════════════
    public DataTable GetMonthlySummary(int instituteId, int sessionId,
        int streamId, int courseId)
    {
        var cmd = new SqlCommand(@"
            SELECT
              YEAR(a.Date)  AS Yr,
              MONTH(a.Date) AS Mon,
              LEFT(DATENAME(MONTH,a.Date),3) + ' ' + CAST(YEAR(a.Date) AS VARCHAR) AS MonLabel,
              COUNT(*)  AS Total,
              SUM(CASE WHEN a.Status='Present' THEN 1 ELSE 0 END) AS Present,
              SUM(CASE WHEN a.Status='Absent'  THEN 1 ELSE 0 END) AS Absent,
              CAST(100.0*SUM(CASE WHEN a.Status='Present' THEN 1 ELSE 0 END)
                   /NULLIF(COUNT(*),0) AS DECIMAL(5,2))           AS AttPct
            FROM Attendance a
            INNER JOIN StudentAcademicDetails sa ON sa.UserId=a.UserId
            WHERE a.InstituteId=@Inst AND a.SessionId=@Sess
              AND (@Stream=0 OR sa.StreamId=@Stream)
              AND (@Course=0 OR sa.CourseId=@Course)
            GROUP BY YEAR(a.Date), MONTH(a.Date), DATENAME(MONTH,a.Date)
            ORDER BY Yr, Mon;");
        cmd.Parameters.AddWithValue("@Inst", instituteId);
        cmd.Parameters.AddWithValue("@Sess", sessionId);
        cmd.Parameters.AddWithValue("@Stream", streamId);
        cmd.Parameters.AddWithValue("@Course", courseId);
        return dl.GetDataTable(cmd);
    }

    // ═══════════════════════════════════════════════════════════
    // STREAM-WISE ATTENDANCE
    // ═══════════════════════════════════════════════════════════
    public DataTable GetStreamWiseAttendance(int instituteId, int sessionId,
        string dateFrom, string dateTo)
    {
        var cmd = new SqlCommand(@"
            SELECT
              ISNULL(st.StreamName,'Unassigned') AS StreamName,
              COUNT(*) AS Total,
              SUM(CASE WHEN a.Status='Present' THEN 1 ELSE 0 END) AS Present,
              SUM(CASE WHEN a.Status='Absent'  THEN 1 ELSE 0 END) AS Absent,
              CAST(100.0*SUM(CASE WHEN a.Status='Present' THEN 1 ELSE 0 END)
                   /NULLIF(COUNT(*),0) AS DECIMAL(5,2))           AS AttPct
            FROM Attendance a
            INNER JOIN StudentAcademicDetails sa ON sa.UserId=a.UserId
            LEFT  JOIN Streams st ON st.StreamId=sa.StreamId
            WHERE a.InstituteId=@Inst AND a.SessionId=@Sess
              AND (CAST(@DFrom AS DATE) IS NULL OR a.Date >= CAST(@DFrom AS DATE))
              AND (CAST(@DTo   AS DATE) IS NULL OR a.Date <= CAST(@DTo   AS DATE))
            GROUP BY st.StreamName ORDER BY AttPct DESC;");
        cmd.Parameters.AddWithValue("@Inst", instituteId);
        cmd.Parameters.AddWithValue("@Sess", sessionId);
        cmd.Parameters.AddWithValue("@DFrom", string.IsNullOrEmpty(dateFrom) ? (object)DBNull.Value : dateFrom);
        cmd.Parameters.AddWithValue("@DTo", string.IsNullOrEmpty(dateTo) ? (object)DBNull.Value : dateTo);
        return dl.GetDataTable(cmd);
    }

    // ═══════════════════════════════════════════════════════════
    // COURSE-WISE ATTENDANCE
    // ═══════════════════════════════════════════════════════════
    public DataTable GetCourseWiseAttendance(int instituteId, int sessionId,
        int streamId, string dateFrom, string dateTo)
    {
        var cmd = new SqlCommand(@"
            SELECT
              ISNULL(c.CourseName,'Unassigned') AS CourseName,
              COUNT(*) AS Total,
              SUM(CASE WHEN a.Status='Present' THEN 1 ELSE 0 END) AS Present,
              SUM(CASE WHEN a.Status='Absent'  THEN 1 ELSE 0 END) AS Absent,
              CAST(100.0*SUM(CASE WHEN a.Status='Present' THEN 1 ELSE 0 END)
                   /NULLIF(COUNT(*),0) AS DECIMAL(5,2))           AS AttPct
            FROM Attendance a
            INNER JOIN StudentAcademicDetails sa ON sa.UserId=a.UserId
            LEFT  JOIN Courses c ON c.CourseId=sa.CourseId
            WHERE a.InstituteId=@Inst AND a.SessionId=@Sess
              AND (@Stream=0 OR sa.StreamId=@Stream)
              AND (CAST(@DFrom AS DATE) IS NULL OR a.Date >= CAST(@DFrom AS DATE))
              AND (CAST(@DTo   AS DATE) IS NULL OR a.Date <= CAST(@DTo   AS DATE))
            GROUP BY c.CourseName ORDER BY AttPct DESC;");
        cmd.Parameters.AddWithValue("@Inst", instituteId);
        cmd.Parameters.AddWithValue("@Sess", sessionId);
        cmd.Parameters.AddWithValue("@Stream", streamId);
        cmd.Parameters.AddWithValue("@DFrom", string.IsNullOrEmpty(dateFrom) ? (object)DBNull.Value : dateFrom);
        cmd.Parameters.AddWithValue("@DTo", string.IsNullOrEmpty(dateTo) ? (object)DBNull.Value : dateTo);
        return dl.GetDataTable(cmd);
    }

    // ═══════════════════════════════════════════════════════════
    // SUBJECT-WISE ATTENDANCE
    // ═══════════════════════════════════════════════════════════
    public DataTable GetSubjectWiseAttendance(int instituteId, int sessionId,
        int streamId, int courseId, string dateFrom, string dateTo)
    {
        var cmd = new SqlCommand(@"
            SELECT TOP 10
              LTRIM(RTRIM(sub.SubjectName)) AS SubjectName,
              ISNULL(sub.SubjectCode,'')    AS SubjectCode,
              COUNT(*) AS Total,
              SUM(CASE WHEN a.Status='Present' THEN 1 ELSE 0 END) AS Present,
              SUM(CASE WHEN a.Status='Absent'  THEN 1 ELSE 0 END) AS Absent,
              CAST(100.0*SUM(CASE WHEN a.Status='Present' THEN 1 ELSE 0 END)
                   /NULLIF(COUNT(*),0) AS DECIMAL(5,2))           AS AttPct
            FROM Attendance a
            INNER JOIN Subjects sub ON sub.SubjectId=a.SubjectId
            INNER JOIN StudentAcademicDetails sa ON sa.UserId=a.UserId
            LEFT  JOIN LevelSemesterSubjects lss
                ON lss.SubjectId=sub.SubjectId AND lss.SessionId=@Sess
            WHERE a.InstituteId=@Inst AND a.SessionId=@Sess
              AND (@Stream=0 OR sa.StreamId=@Stream)
              AND (@Course=0 OR sa.CourseId=@Course)
              AND (CAST(@DFrom AS DATE) IS NULL OR a.Date >= CAST(@DFrom AS DATE))
              AND (CAST(@DTo   AS DATE) IS NULL OR a.Date <= CAST(@DTo   AS DATE))
            GROUP BY sub.SubjectId, sub.SubjectName, sub.SubjectCode
            ORDER BY AttPct DESC;");
        cmd.Parameters.AddWithValue("@Inst", instituteId);
        cmd.Parameters.AddWithValue("@Sess", sessionId);
        cmd.Parameters.AddWithValue("@Stream", streamId);
        cmd.Parameters.AddWithValue("@Course", courseId);
        cmd.Parameters.AddWithValue("@DFrom", string.IsNullOrEmpty(dateFrom) ? (object)DBNull.Value : dateFrom);
        cmd.Parameters.AddWithValue("@DTo", string.IsNullOrEmpty(dateTo) ? (object)DBNull.Value : dateTo);
        return dl.GetDataTable(cmd);
    }

    // ═══════════════════════════════════════════════════════════
    // SECTION-WISE ATTENDANCE
    // ═══════════════════════════════════════════════════════════
    public DataTable GetSectionWiseAttendance(int instituteId, int sessionId,
        int streamId, string dateFrom, string dateTo)
    {
        var cmd = new SqlCommand(@"
            SELECT
              ISNULL(sec.SectionName,'Unassigned') AS SectionName,
              COUNT(*) AS Total,
              SUM(CASE WHEN a.Status='Present' THEN 1 ELSE 0 END) AS Present,
              SUM(CASE WHEN a.Status='Absent'  THEN 1 ELSE 0 END) AS Absent,
              CAST(100.0*SUM(CASE WHEN a.Status='Present' THEN 1 ELSE 0 END)
                   /NULLIF(COUNT(*),0) AS DECIMAL(5,2))           AS AttPct
            FROM Attendance a
            INNER JOIN StudentAcademicDetails sa ON sa.UserId=a.UserId
            LEFT  JOIN Sections sec ON sec.SectionId=sa.SectionId
            WHERE a.InstituteId=@Inst AND a.SessionId=@Sess
              AND (@Stream=0 OR sa.StreamId=@Stream)
              AND (CAST(@DFrom AS DATE) IS NULL OR a.Date >= CAST(@DFrom AS DATE))
              AND (CAST(@DTo   AS DATE) IS NULL OR a.Date <= CAST(@DTo   AS DATE))
            GROUP BY sec.SectionName ORDER BY AttPct DESC;");
        cmd.Parameters.AddWithValue("@Inst", instituteId);
        cmd.Parameters.AddWithValue("@Sess", sessionId);
        cmd.Parameters.AddWithValue("@Stream", streamId);
        cmd.Parameters.AddWithValue("@DFrom", string.IsNullOrEmpty(dateFrom) ? (object)DBNull.Value : dateFrom);
        cmd.Parameters.AddWithValue("@DTo", string.IsNullOrEmpty(dateTo) ? (object)DBNull.Value : dateTo);
        return dl.GetDataTable(cmd);
    }

    // ═══════════════════════════════════════════════════════════
    // STUDENT-WISE ATTENDANCE (paginated)
    // ═══════════════════════════════════════════════════════════
    public DataTable GetStudentWiseAttendance(int instituteId, int sessionId,
        int streamId, int courseId, int sectionId, int subjectId,
        string dateFrom, string dateTo, string gender,
        string search, int pageIndex, int pageSize)
    {
        var cmd = new SqlCommand(@"
            SELECT * FROM (
              SELECT
                ROW_NUMBER() OVER (ORDER BY AttPct DESC) AS RowNum,
                UserId, FullName, RollNumber, CourseName, SectionName,
                ProfileImage, Gender,
                Total, Present, Absent, OnLeave, AttPct,
                CASE
                  WHEN AttPct >= 90 THEN 'Excellent'
                  WHEN AttPct >= 75 THEN 'Good'
                  WHEN AttPct >= 60 THEN 'Average'
                  ELSE 'Low'
                END AS AttCategory,
                CASE
                  WHEN AttPct >= 75 THEN 0 ELSE 1
                END AS IsAtRisk
              FROM (
                SELECT
                  sa.UserId,
                  LTRIM(RTRIM(up.FullName))            AS FullName,
                  ISNULL(sa.RollNumber,'—')             AS RollNumber,
                  ISNULL(c.CourseName,'—')              AS CourseName,
                  ISNULL(sec.SectionName,'—')           AS SectionName,
                  ISNULL(up.ProfileImage,'')            AS ProfileImage,
                  ISNULL(up.Gender,'—')                 AS Gender,
                  COUNT(a.AttendanceId)                 AS Total,
                  SUM(CASE WHEN a.Status='Present' THEN 1 ELSE 0 END) AS Present,
                  SUM(CASE WHEN a.Status='Absent'  THEN 1 ELSE 0 END) AS Absent,
                  SUM(CASE WHEN a.Status='Leave'   THEN 1 ELSE 0 END) AS OnLeave,
                  CAST(100.0*SUM(CASE WHEN a.Status='Present' THEN 1 ELSE 0 END)
                       /NULLIF(COUNT(a.AttendanceId),0) AS DECIMAL(5,1))   AS AttPct
                FROM StudentAcademicDetails sa
                INNER JOIN UserProfile up  ON up.UserId  = sa.UserId
                LEFT  JOIN Courses     c   ON c.CourseId = sa.CourseId
                LEFT  JOIN Sections    sec ON sec.SectionId=sa.SectionId
                LEFT  JOIN Attendance  a
                    ON a.UserId      = sa.UserId
                   AND a.InstituteId = @Inst
                   AND a.SessionId   = @Sess
                   AND (@Subject=0 OR a.SubjectId=@Subject)
                   AND (CAST(@DFrom AS DATE) IS NULL OR a.Date >= CAST(@DFrom AS DATE))
                   AND (CAST(@DTo   AS DATE) IS NULL OR a.Date <= CAST(@DTo   AS DATE))
                WHERE sa.InstituteId=@Inst AND sa.SessionId=@Sess
                  AND (@Stream  =0  OR sa.StreamId  =@Stream)
                  AND (@Course  =0  OR sa.CourseId  =@Course)
                  AND (@Section =0  OR sa.SectionId =@Section)
                  AND (@Gender  ='' OR up.Gender     =@Gender)
                  AND (@Search  ='' OR up.FullName   LIKE '%'+@Search+'%'
                                    OR sa.RollNumber LIKE '%'+@Search+'%')
                GROUP BY sa.UserId,up.FullName,sa.RollNumber,
                         c.CourseName,sec.SectionName,up.ProfileImage,up.Gender
              ) Q
            ) T
            WHERE RowNum BETWEEN @Skip+1 AND @Skip+@Size;");

        AddFilters(cmd, instituteId, sessionId, streamId, courseId,
                   sectionId, subjectId, dateFrom, dateTo, gender);
        cmd.Parameters.AddWithValue("@Search", search ?? "");
        cmd.Parameters.AddWithValue("@Skip", pageIndex * pageSize);
        cmd.Parameters.AddWithValue("@Size", pageSize);
        return dl.GetDataTable(cmd);
    }

    public int GetStudentAttCount(int instituteId, int sessionId,
        int streamId, int courseId, int sectionId,
        string gender, string search)
    {
        var cmd = new SqlCommand(@"
            SELECT COUNT(DISTINCT sa.UserId)
            FROM StudentAcademicDetails sa
            INNER JOIN UserProfile up ON up.UserId=sa.UserId
            WHERE sa.InstituteId=@Inst AND sa.SessionId=@Sess
              AND (@Stream  =0  OR sa.StreamId  =@Stream)
              AND (@Course  =0  OR sa.CourseId  =@Course)
              AND (@Section =0  OR sa.SectionId =@Section)
              AND (@Gender  ='' OR up.Gender     =@Gender)
              AND (@Search  ='' OR up.FullName   LIKE '%'+@Search+'%'
                                OR sa.RollNumber LIKE '%'+@Search+'%');");
        cmd.Parameters.AddWithValue("@Inst", instituteId);
        cmd.Parameters.AddWithValue("@Sess", sessionId);
        cmd.Parameters.AddWithValue("@Stream", streamId);
        cmd.Parameters.AddWithValue("@Course", courseId);
        cmd.Parameters.AddWithValue("@Section", sectionId);
        cmd.Parameters.AddWithValue("@Gender", gender ?? "");
        cmd.Parameters.AddWithValue("@Search", search ?? "");
        var dt = dl.GetDataTable(cmd);
        return dt?.Rows.Count > 0 ? Convert.ToInt32(dt.Rows[0][0]) : 0;
    }

    // ═══════════════════════════════════════════════════════════
    // DEFAULTERS (attendance < threshold)
    // ═══════════════════════════════════════════════════════════
    public DataTable GetDefaulters(int instituteId, int sessionId,
        int streamId, int courseId, decimal threshold,
        string dateFrom, string dateTo)
    {
        var cmd = new SqlCommand(@"
            SELECT TOP 20
              sa.UserId,
              LTRIM(RTRIM(up.FullName))   AS FullName,
              ISNULL(sa.RollNumber,'—')   AS RollNumber,
              ISNULL(c.CourseName,'—')    AS CourseName,
              ISNULL(sec.SectionName,'—') AS SectionName,
              ISNULL(up.ProfileImage,'')  AS ProfileImage,
              COUNT(a.AttendanceId) AS Total,
              SUM(CASE WHEN a.Status='Present' THEN 1 ELSE 0 END) AS Present,
              SUM(CASE WHEN a.Status='Absent'  THEN 1 ELSE 0 END) AS Absent,
              CAST(100.0*SUM(CASE WHEN a.Status='Present' THEN 1 ELSE 0 END)
                   /NULLIF(COUNT(a.AttendanceId),0) AS DECIMAL(5,1)) AS AttPct
            FROM StudentAcademicDetails sa
            INNER JOIN UserProfile up  ON up.UserId  = sa.UserId
            LEFT  JOIN Courses     c   ON c.CourseId = sa.CourseId
            LEFT  JOIN Sections    sec ON sec.SectionId=sa.SectionId
            LEFT  JOIN Attendance  a
                ON a.UserId=sa.UserId AND a.InstituteId=@Inst AND a.SessionId=@Sess
               AND (CAST(@DFrom AS DATE) IS NULL OR a.Date >= CAST(@DFrom AS DATE))
               AND (CAST(@DTo   AS DATE) IS NULL OR a.Date <= CAST(@DTo   AS DATE))
            WHERE sa.InstituteId=@Inst AND sa.SessionId=@Sess
              AND (@Stream=0 OR sa.StreamId=@Stream)
              AND (@Course=0 OR sa.CourseId=@Course)
            GROUP BY sa.UserId,up.FullName,sa.RollNumber,
                     c.CourseName,sec.SectionName,up.ProfileImage
            HAVING CAST(100.0*SUM(CASE WHEN a.Status='Present' THEN 1 ELSE 0 END)
                        /NULLIF(COUNT(a.AttendanceId),0) AS DECIMAL(5,1)) < @Threshold
            ORDER BY AttPct ASC;");
        cmd.Parameters.AddWithValue("@Inst", instituteId);
        cmd.Parameters.AddWithValue("@Sess", sessionId);
        cmd.Parameters.AddWithValue("@Stream", streamId);
        cmd.Parameters.AddWithValue("@Course", courseId);
        cmd.Parameters.AddWithValue("@Threshold", threshold);
        cmd.Parameters.AddWithValue("@DFrom", string.IsNullOrEmpty(dateFrom) ? (object)DBNull.Value : dateFrom);
        cmd.Parameters.AddWithValue("@DTo", string.IsNullOrEmpty(dateTo) ? (object)DBNull.Value : dateTo);
        return dl.GetDataTable(cmd);
    }

    // ═══════════════════════════════════════════════════════════
    // DAY-OF-WEEK PATTERN
    // ═══════════════════════════════════════════════════════════
    public DataTable GetDayOfWeekPattern(int instituteId, int sessionId,
        int streamId, string dateFrom, string dateTo)
    {
        var cmd = new SqlCommand(@"
            SELECT
              DATENAME(WEEKDAY, a.Date)  AS DayName,
              DATEPART(WEEKDAY, a.Date)  AS DayNum,
              COUNT(*) AS Total,
              SUM(CASE WHEN a.Status='Present' THEN 1 ELSE 0 END) AS Present,
              CAST(100.0*SUM(CASE WHEN a.Status='Present' THEN 1 ELSE 0 END)
                   /NULLIF(COUNT(*),0) AS DECIMAL(5,2)) AS AttPct
            FROM Attendance a
            INNER JOIN StudentAcademicDetails sa ON sa.UserId=a.UserId
            WHERE a.InstituteId=@Inst AND a.SessionId=@Sess
              AND (@Stream=0 OR sa.StreamId=@Stream)
              AND (CAST(@DFrom AS DATE) IS NULL OR a.Date >= CAST(@DFrom AS DATE))
              AND (CAST(@DTo   AS DATE) IS NULL OR a.Date <= CAST(@DTo   AS DATE))
            GROUP BY DATENAME(WEEKDAY,a.Date), DATEPART(WEEKDAY,a.Date)
            ORDER BY DayNum;");
        cmd.Parameters.AddWithValue("@Inst", instituteId);
        cmd.Parameters.AddWithValue("@Sess", sessionId);
        cmd.Parameters.AddWithValue("@Stream", streamId);
        cmd.Parameters.AddWithValue("@DFrom", string.IsNullOrEmpty(dateFrom) ? (object)DBNull.Value : dateFrom);
        cmd.Parameters.AddWithValue("@DTo", string.IsNullOrEmpty(dateTo) ? (object)DBNull.Value : dateTo);
        return dl.GetDataTable(cmd);
    }

    // ═══════════════════════════════════════════════════════════
    // ATTENDANCE BUCKET DISTRIBUTION (>90%, 75-90%, 60-75%, <60%)
    // ═══════════════════════════════════════════════════════════
    public DataTable GetAttendanceBuckets(int instituteId, int sessionId,
        int streamId, int courseId, string dateFrom, string dateTo)
    {
        var cmd = new SqlCommand(@"
            SELECT
              CASE
                WHEN AttPct >= 90 THEN '≥90% Excellent'
                WHEN AttPct >= 75 THEN '75–89% Good'
                WHEN AttPct >= 60 THEN '60–74% Average'
                ELSE '<60% Critical'
              END AS Bucket,
              COUNT(*) AS Students,
              CAST(AVG(AttPct) AS DECIMAL(5,1)) AS AvgPct
            FROM (
              SELECT sa.UserId,
                CAST(100.0*SUM(CASE WHEN a.Status='Present' THEN 1 ELSE 0 END)
                     /NULLIF(COUNT(a.AttendanceId),0) AS DECIMAL(5,1)) AS AttPct
              FROM StudentAcademicDetails sa
              LEFT JOIN Attendance a
                ON a.UserId=sa.UserId AND a.InstituteId=@Inst AND a.SessionId=@Sess
               AND (CAST(@DFrom AS DATE) IS NULL OR a.Date >= CAST(@DFrom AS DATE))
               AND (CAST(@DTo   AS DATE) IS NULL OR a.Date <= CAST(@DTo   AS DATE))
              WHERE sa.InstituteId=@Inst AND sa.SessionId=@Sess
                AND (@Stream=0 OR sa.StreamId=@Stream)
                AND (@Course=0 OR sa.CourseId=@Course)
              GROUP BY sa.UserId
            ) X
            GROUP BY
              CASE
                WHEN AttPct >= 90 THEN '≥90% Excellent'
                WHEN AttPct >= 75 THEN '75–89% Good'
                WHEN AttPct >= 60 THEN '60–74% Average'
                ELSE '<60% Critical'
              END
            ORDER BY MIN(AttPct) DESC;");
        cmd.Parameters.AddWithValue("@Inst", instituteId);
        cmd.Parameters.AddWithValue("@Sess", sessionId);
        cmd.Parameters.AddWithValue("@Stream", streamId);
        cmd.Parameters.AddWithValue("@Course", courseId);
        cmd.Parameters.AddWithValue("@DFrom", string.IsNullOrEmpty(dateFrom) ? (object)DBNull.Value : dateFrom);
        cmd.Parameters.AddWithValue("@DTo", string.IsNullOrEmpty(dateTo) ? (object)DBNull.Value : dateTo);
        return dl.GetDataTable(cmd);
    }

    // ═══════════════════════════════════════════════════════════
    // HEATMAP — day x hour presence density
    // ═══════════════════════════════════════════════════════════
    public DataTable GetHeatmapData(int instituteId, int sessionId,
        int streamId, string dateFrom, string dateTo)
    {
        var cmd = new SqlCommand(@"
            SELECT
              DATEPART(WEEKDAY, a.Date) - 1 AS DayIdx,
              DATENAME(WEEKDAY, a.Date)     AS DayName,
              MONTH(a.Date)                 AS MonNum,
              LEFT(DATENAME(MONTH,a.Date),3) AS MonName,
              CAST(100.0*SUM(CASE WHEN a.Status='Present' THEN 1 ELSE 0 END)
                   /NULLIF(COUNT(*),0) AS DECIMAL(5,2)) AS AttPct,
              COUNT(*) AS Total
            FROM Attendance a
            INNER JOIN StudentAcademicDetails sa ON sa.UserId=a.UserId
            WHERE a.InstituteId=@Inst AND a.SessionId=@Sess
              AND (@Stream=0 OR sa.StreamId=@Stream)
              AND (CAST(@DFrom AS DATE) IS NULL OR a.Date >= CAST(@DFrom AS DATE))
              AND (CAST(@DTo   AS DATE) IS NULL OR a.Date <= CAST(@DTo   AS DATE))
            GROUP BY DATEPART(WEEKDAY,a.Date), DATENAME(WEEKDAY,a.Date),
                     MONTH(a.Date), DATENAME(MONTH,a.Date)
            ORDER BY MonNum, DayIdx;");
        cmd.Parameters.AddWithValue("@Inst", instituteId);
        cmd.Parameters.AddWithValue("@Sess", sessionId);
        cmd.Parameters.AddWithValue("@Stream", streamId);
        cmd.Parameters.AddWithValue("@DFrom", string.IsNullOrEmpty(dateFrom) ? (object)DBNull.Value : dateFrom);
        cmd.Parameters.AddWithValue("@DTo", string.IsNullOrEmpty(dateTo) ? (object)DBNull.Value : dateTo);
        return dl.GetDataTable(cmd);
    }

    // ═══════════════════════════════════════════════════════════
    // HELPER: add all common filter parameters
    // ═══════════════════════════════════════════════════════════
    private void AddFilters(SqlCommand cmd, int instituteId, int sessionId,
        int streamId, int courseId, int sectionId, int subjectId,
        string dateFrom, string dateTo, string gender)
    {
        cmd.Parameters.AddWithValue("@Inst", instituteId);
        cmd.Parameters.AddWithValue("@Sess", sessionId);
        cmd.Parameters.AddWithValue("@Stream", streamId);
        cmd.Parameters.AddWithValue("@Course", courseId);
        cmd.Parameters.AddWithValue("@Section", sectionId);
        cmd.Parameters.AddWithValue("@Subject", subjectId);
        cmd.Parameters.AddWithValue("@Gender", gender ?? "");
        cmd.Parameters.AddWithValue("@DFrom", string.IsNullOrEmpty(dateFrom) ? (object)DBNull.Value : dateFrom);
        cmd.Parameters.AddWithValue("@DTo", string.IsNullOrEmpty(dateTo) ? (object)DBNull.Value : dateTo);
    }
}