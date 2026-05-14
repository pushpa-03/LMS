using System;
using System.Data;
using System.Data.SqlClient;

/// <summary>
/// BL for AI Insights Dashboard
/// Tracks which students use AI features (Summary / Notes / Quiz / Doubt)
/// from VideoAIHistory and MaterialAIHistory tables
/// All filter params: 0 / "" = no filter
/// </summary>
public class AIInsightsDashboardBL
{
    DataLayer dl = new DataLayer();

    // ═══════════════════════════════════════════════════════
    // DROPDOWN LOADERS
    // ═══════════════════════════════════════════════════════
    public DataTable GetStreams(int inst, int sess)
    {
        var cmd = new SqlCommand(@"
            SELECT StreamId, StreamName FROM Streams
            WHERE InstituteId=@I AND SessionId=@S AND IsActive=1
            ORDER BY StreamName;");
        cmd.Parameters.AddWithValue("@I", inst);
        cmd.Parameters.AddWithValue("@S", sess);
        return dl.GetDataTable(cmd);
    }

    public DataTable GetCourses(int inst, int sess, int streamId)
    {
        var cmd = new SqlCommand(@"
            SELECT CourseId,
                   CourseName + ISNULL(' ('+CourseCode+')','') AS CourseDisplay
            FROM Courses
            WHERE InstituteId=@I AND SessionId=@S AND IsActive=1
              AND (@Str=0 OR StreamId=@Str)
            ORDER BY CourseName;");
        cmd.Parameters.AddWithValue("@I", inst);
        cmd.Parameters.AddWithValue("@S", sess);
        cmd.Parameters.AddWithValue("@Str", streamId);
        return dl.GetDataTable(cmd);
    }

    public DataTable GetSections(int inst, int sess)
    {
        var cmd = new SqlCommand(@"
            SELECT SectionId, SectionName FROM Sections
            WHERE InstituteId=@I AND SessionId=@S AND IsActive=1
            ORDER BY SectionName;");
        cmd.Parameters.AddWithValue("@I", inst);
        cmd.Parameters.AddWithValue("@S", sess);
        return dl.GetDataTable(cmd);
    }

    public DataTable GetSubjects(int inst, int sess, int streamId, int courseId)
    {
        var cmd = new SqlCommand(@"
            SELECT DISTINCT s.SubjectId,
                   LTRIM(RTRIM(s.SubjectName)) AS SubjectName
            FROM Subjects s
            LEFT JOIN LevelSemesterSubjects lss
                ON lss.SubjectId=s.SubjectId 
               AND lss.InstituteId=@I 
               AND lss.SessionId=@S
            WHERE s.InstituteId=@I 
              AND s.SessionId=@S 
              AND s.IsActive=1
              AND (@Str=0 OR lss.StreamId=@Str)
              AND (@Crs=0 OR lss.CourseId=@Crs)
            ORDER BY SubjectName;");
        cmd.Parameters.AddWithValue("@I", inst);
        cmd.Parameters.AddWithValue("@S", sess);
        cmd.Parameters.AddWithValue("@Str", streamId);
        cmd.Parameters.AddWithValue("@Crs", courseId);
        return dl.GetDataTable(cmd);
    }

    // ═══════════════════════════════════════════════════════
    // KPI SUMMARY
    // Total AI interactions, unique users, breakdown by type
    // ═══════════════════════════════════════════════════════
    public DataTable GetKPISummary(int inst, int sess,
        int streamId, int courseId, int sectionId,
        string aiType, string dateFrom, string dateTo)
    {
        var cmd = new SqlCommand(@"
            SELECT
              -- Total AI uses (video + material)
              COUNT(DISTINCT v.Id) + COUNT(DISTINCT m.Id)          AS TotalInteractions,

              -- Unique students using AI
              COUNT(DISTINCT COALESCE(v.UserId, m.UserId))         AS UniqueUsers,

              -- Total enrolled students (for adoption rate)
              (SELECT COUNT(DISTINCT UserId) FROM StudentAcademicDetails
               WHERE InstituteId=@I AND SessionId=@S
                 AND (@Str=0 OR StreamId=@Str)
                 AND (@Crs=0 OR CourseId=@Crs)
                 AND (@Sec=0 OR SectionId=@Sec))                   AS TotalEnrolled,

              -- Video AI breakdown
              SUM(CASE WHEN v.Type='Summary' THEN 1 ELSE 0 END)    AS VideoSummary,
              SUM(CASE WHEN v.Type='Notes'   THEN 1 ELSE 0 END)    AS VideoNotes,
              SUM(CASE WHEN v.Type='Quiz'    THEN 1 ELSE 0 END)    AS VideoQuiz,
              SUM(CASE WHEN v.Type='Doubt'   THEN 1 ELSE 0 END)    AS VideoDoubt,

              -- Material AI breakdown
              SUM(CASE WHEN m.Type='Quiz'  THEN 1 ELSE 0 END)      AS MaterialQuiz,
              SUM(CASE WHEN m.Type='Doubt' THEN 1 ELSE 0 END)      AS MaterialDoubt,
              SUM(CASE WHEN m.Type='Notes' THEN 1 ELSE 0 END)      AS MaterialNotes,

              -- Today's interactions
              SUM(CASE WHEN CAST(v.CreatedOn AS DATE)=CAST(GETDATE() AS DATE) THEN 1 ELSE 0 END)
            + SUM(CASE WHEN CAST(m.CreatedOn AS DATE)=CAST(GETDATE() AS DATE) THEN 1 ELSE 0 END)
                                                                    AS TodayInteractions

            FROM StudentAcademicDetails sa

            LEFT JOIN VideoAIHistory v
                ON v.UserId = sa.UserId
               AND (@AIType='' OR v.Type=@AIType)
               AND (CAST(@DFr AS DATE) IS NULL OR CAST(v.CreatedOn AS DATE)>=CAST(@DFr AS DATE))
               AND (CAST(@DTo AS DATE) IS NULL OR CAST(v.CreatedOn AS DATE)<=CAST(@DTo AS DATE))

            LEFT JOIN MaterialAIHistory m
                ON m.UserId = sa.UserId
               AND (@AIType='' OR m.Type=@AIType)
               AND (CAST(@DFr AS DATE) IS NULL OR CAST(m.CreatedOn AS DATE)>=CAST(@DFr AS DATE))
               AND (CAST(@DTo AS DATE) IS NULL OR CAST(m.CreatedOn AS DATE)<=CAST(@DTo AS DATE))

            WHERE sa.InstituteId=@I AND sa.SessionId=@S
              AND (@Str=0 OR sa.StreamId  =@Str)
              AND (@Crs=0 OR sa.CourseId  =@Crs)
              AND (@Sec=0 OR sa.SectionId =@Sec);");

        AddP(cmd, inst, sess, streamId, courseId, sectionId, aiType, dateFrom, dateTo);
        return dl.GetDataTable(cmd);
    }

    // ═══════════════════════════════════════════════════════
    // AI USAGE TREND — daily for date range
    // ═══════════════════════════════════════════════════════
    public DataTable GetDailyTrend(int inst, int sess,
        int streamId, int courseId, string aiType, string dateFrom, string dateTo)
    {
        var cmd = new SqlCommand(@"
            SELECT
              CONVERT(VARCHAR(10), dt, 23) AS DateStr,
              SUM(VideoCount)    AS VideoAI,
              SUM(MaterialCount) AS MaterialAI,
              SUM(VideoCount)+SUM(MaterialCount) AS Total,
              COUNT(DISTINCT UserId) AS UniqueUsers
            FROM (
              SELECT CAST(v.CreatedOn AS DATE) AS dt,
                     v.UserId, COUNT(*) AS VideoCount, 0 AS MaterialCount
              FROM VideoAIHistory v
              JOIN StudentAcademicDetails sa ON sa.UserId=v.UserId
              WHERE sa.InstituteId=@I AND sa.SessionId=@S
                AND (@Str=0 OR sa.StreamId=@Str)
                AND (@Crs=0 OR sa.CourseId=@Crs)
                AND (@AIType='' OR v.Type=@AIType)
                AND (CAST(@DFr AS DATE) IS NULL OR CAST(v.CreatedOn AS DATE)>=CAST(@DFr AS DATE))
                AND (CAST(@DTo AS DATE) IS NULL OR CAST(v.CreatedOn AS DATE)<=CAST(@DTo AS DATE))
              GROUP BY CAST(v.CreatedOn AS DATE), v.UserId

              UNION ALL

              SELECT CAST(m.CreatedOn AS DATE) AS dt,
                     m.UserId, 0 AS VideoCount, COUNT(*) AS MaterialCount
              FROM MaterialAIHistory m
              JOIN StudentAcademicDetails sa ON sa.UserId=m.UserId
              WHERE sa.InstituteId=@I AND sa.SessionId=@S
                AND (@Str=0 OR sa.StreamId=@Str)
                AND (@Crs=0 OR sa.CourseId=@Crs)
                AND (@AIType='' OR m.Type=@AIType)
                AND (CAST(@DFr AS DATE) IS NULL OR CAST(m.CreatedOn AS DATE)>=CAST(@DFr AS DATE))
                AND (CAST(@DTo AS DATE) IS NULL OR CAST(m.CreatedOn AS DATE)<=CAST(@DTo AS DATE))
              GROUP BY CAST(m.CreatedOn AS DATE), m.UserId
            ) X
            GROUP BY dt ORDER BY dt;");
        AddP(cmd, inst, sess, streamId, courseId, 0, aiType, dateFrom, dateTo);
        return dl.GetDataTable(cmd);
    }

    // ═══════════════════════════════════════════════════════
    // AI TYPE BREAKDOWN (Summary / Notes / Quiz / Doubt)
    // ═══════════════════════════════════════════════════════
    public DataTable GetTypeBreakdown(int inst, int sess,
        int streamId, int courseId, string dateFrom, string dateTo)
    {
        var cmd = new SqlCommand(@"
            SELECT AIType, SUM(Cnt) AS Total FROM (
              SELECT ISNULL(v.Type,'Unknown') AS AIType, COUNT(*) AS Cnt
              FROM VideoAIHistory v
              JOIN StudentAcademicDetails sa ON sa.UserId=v.UserId
              WHERE sa.InstituteId=@I AND sa.SessionId=@S
                AND (@Str=0 OR sa.StreamId=@Str)
                AND (@Crs=0 OR sa.CourseId=@Crs)
                AND (CAST(@DFr AS DATE) IS NULL OR CAST(v.CreatedOn AS DATE)>=CAST(@DFr AS DATE))
                AND (CAST(@DTo AS DATE) IS NULL OR CAST(v.CreatedOn AS DATE)<=CAST(@DTo AS DATE))
              GROUP BY v.Type
              UNION ALL
              SELECT ISNULL(m.Type,'Unknown') AS AIType, COUNT(*) AS Cnt
              FROM MaterialAIHistory m
              JOIN StudentAcademicDetails sa ON sa.UserId=m.UserId
              WHERE sa.InstituteId=@I AND sa.SessionId=@S
                AND (@Str=0 OR sa.StreamId=@Str)
                AND (@Crs=0 OR sa.CourseId=@Crs)
                AND (CAST(@DFr AS DATE) IS NULL OR CAST(m.CreatedOn AS DATE)>=CAST(@DFr AS DATE))
                AND (CAST(@DTo AS DATE) IS NULL OR CAST(m.CreatedOn AS DATE)<=CAST(@DTo AS DATE))
              GROUP BY m.Type
            ) X GROUP BY AIType ORDER BY Total DESC;");
        cmd.Parameters.AddWithValue("@I", inst);
        cmd.Parameters.AddWithValue("@S", sess);
        cmd.Parameters.AddWithValue("@Str", streamId);
        cmd.Parameters.AddWithValue("@Crs", courseId);
        cmd.Parameters.AddWithValue("@DFr", Dt(dateFrom));
        cmd.Parameters.AddWithValue("@DTo", Dt(dateTo));
        return dl.GetDataTable(cmd);
    }

    // ═══════════════════════════════════════════════════════
    // STREAM-WISE AI USAGE
    // ═══════════════════════════════════════════════════════
    public DataTable GetStreamWiseUsage(int inst, int sess,
        string aiType, string dateFrom, string dateTo)
    {
        var cmd = new SqlCommand(@"
            SELECT ISNULL(st.StreamName,'Unassigned') AS StreamName,
                   COUNT(DISTINCT sa.UserId)          AS TotalStudents,
                   COUNT(DISTINCT users.UserId)        AS AIUsers,
                   ISNULL(SUM(users.Cnt),0)            AS TotalUses,
                   CAST(100.0*COUNT(DISTINCT users.UserId)
                        /NULLIF(COUNT(DISTINCT sa.UserId),0) AS DECIMAL(5,1)) AS AdoptionRate
            FROM StudentAcademicDetails sa
            LEFT JOIN Streams st ON st.StreamId=sa.StreamId
            LEFT JOIN (
              SELECT v.UserId, COUNT(*) AS Cnt FROM VideoAIHistory v
              WHERE (@AIType='' OR v.Type=@AIType)
                AND (CAST(@DFr AS DATE) IS NULL OR CAST(v.CreatedOn AS DATE)>=CAST(@DFr AS DATE))
                AND (CAST(@DTo AS DATE) IS NULL OR CAST(v.CreatedOn AS DATE)<=CAST(@DTo AS DATE))
              GROUP BY v.UserId
              UNION ALL
              SELECT m.UserId, COUNT(*) AS Cnt FROM MaterialAIHistory m
              WHERE (@AIType='' OR m.Type=@AIType)
                AND (CAST(@DFr AS DATE) IS NULL OR CAST(m.CreatedOn AS DATE)>=CAST(@DFr AS DATE))
                AND (CAST(@DTo AS DATE) IS NULL OR CAST(m.CreatedOn AS DATE)<=CAST(@DTo AS DATE))
              GROUP BY m.UserId
            ) users ON users.UserId=sa.UserId
            WHERE sa.InstituteId=@I AND sa.SessionId=@S
            GROUP BY st.StreamName ORDER BY TotalUses DESC;");
        cmd.Parameters.AddWithValue("@I", inst);
        cmd.Parameters.AddWithValue("@S", sess);
        cmd.Parameters.AddWithValue("@AIType", aiType ?? "");
        cmd.Parameters.AddWithValue("@DFr", Dt(dateFrom));
        cmd.Parameters.AddWithValue("@DTo", Dt(dateTo));
        return dl.GetDataTable(cmd);
    }

    // ═══════════════════════════════════════════════════════
    // COURSE-WISE AI USAGE
    // ═══════════════════════════════════════════════════════
    public DataTable GetCourseWiseUsage(int inst, int sess,
        int streamId, string aiType, string dateFrom, string dateTo)
    {
        var cmd = new SqlCommand(@"
            SELECT ISNULL(c.CourseName,'Unassigned') AS CourseName,
                   COUNT(DISTINCT sa.UserId)          AS TotalStudents,
                   COUNT(DISTINCT u.UserId)            AS AIUsers,
                   ISNULL(SUM(u.Cnt),0)               AS TotalUses,
                   CAST(100.0*COUNT(DISTINCT u.UserId)
                        /NULLIF(COUNT(DISTINCT sa.UserId),0) AS DECIMAL(5,1)) AS AdoptionRate
            FROM StudentAcademicDetails sa
            LEFT JOIN Courses c ON c.CourseId=sa.CourseId
            LEFT JOIN (
              SELECT v.UserId, COUNT(*) AS Cnt FROM VideoAIHistory v
              WHERE (@AIType='' OR v.Type=@AIType)
                AND (CAST(@DFr AS DATE) IS NULL OR CAST(v.CreatedOn AS DATE)>=CAST(@DFr AS DATE))
                AND (CAST(@DTo AS DATE) IS NULL OR CAST(v.CreatedOn AS DATE)<=CAST(@DTo AS DATE))
              GROUP BY v.UserId
              UNION ALL
              SELECT m.UserId, COUNT(*) AS Cnt FROM MaterialAIHistory m
              WHERE (@AIType='' OR m.Type=@AIType)
                AND (CAST(@DFr AS DATE) IS NULL OR CAST(m.CreatedOn AS DATE)>=CAST(@DFr AS DATE))
                AND (CAST(@DTo AS DATE) IS NULL OR CAST(m.CreatedOn AS DATE)<=CAST(@DTo AS DATE))
              GROUP BY m.UserId
            ) u ON u.UserId=sa.UserId
            WHERE sa.InstituteId=@I AND sa.SessionId=@S
              AND (@Str=0 OR sa.StreamId=@Str)
            GROUP BY c.CourseName ORDER BY TotalUses DESC;");
        cmd.Parameters.AddWithValue("@I", inst);
        cmd.Parameters.AddWithValue("@S", sess);
        cmd.Parameters.AddWithValue("@Str", streamId);
        cmd.Parameters.AddWithValue("@AIType", aiType ?? "");
        cmd.Parameters.AddWithValue("@DFr", Dt(dateFrom));
        cmd.Parameters.AddWithValue("@DTo", Dt(dateTo));
        return dl.GetDataTable(cmd);
    }

    // ═══════════════════════════════════════════════════════
    // SECTION-WISE AI USAGE
    // ═══════════════════════════════════════════════════════
    public DataTable GetSectionWiseUsage(int inst, int sess,
        int streamId, string aiType, string dateFrom, string dateTo)
    {
        var cmd = new SqlCommand(@"
            SELECT ISNULL(sec.SectionName,'Unassigned') AS SectionName,
                   COUNT(DISTINCT sa.UserId)             AS TotalStudents,
                   COUNT(DISTINCT u.UserId)              AS AIUsers,
                   ISNULL(SUM(u.Cnt),0)                 AS TotalUses,
                   CAST(100.0*COUNT(DISTINCT u.UserId)
                        /NULLIF(COUNT(DISTINCT sa.UserId),0) AS DECIMAL(5,1)) AS AdoptionRate
            FROM StudentAcademicDetails sa
            LEFT JOIN Sections sec ON sec.SectionId=sa.SectionId
            LEFT JOIN (
              SELECT v.UserId, COUNT(*) AS Cnt FROM VideoAIHistory v
              WHERE (@AIType='' OR v.Type=@AIType)
                AND (CAST(@DFr AS DATE) IS NULL OR CAST(v.CreatedOn AS DATE)>=CAST(@DFr AS DATE))
                AND (CAST(@DTo AS DATE) IS NULL OR CAST(v.CreatedOn AS DATE)<=CAST(@DTo AS DATE))
              GROUP BY v.UserId
              UNION ALL
              SELECT m.UserId, COUNT(*) AS Cnt FROM MaterialAIHistory m
              WHERE (@AIType='' OR m.Type=@AIType)
                AND (CAST(@DFr AS DATE) IS NULL OR CAST(m.CreatedOn AS DATE)>=CAST(@DFr AS DATE))
                AND (CAST(@DTo AS DATE) IS NULL OR CAST(m.CreatedOn AS DATE)<=CAST(@DTo AS DATE))
              GROUP BY m.UserId
            ) u ON u.UserId=sa.UserId
            WHERE sa.InstituteId=@I AND sa.SessionId=@S
              AND (@Str=0 OR sa.StreamId=@Str)
            GROUP BY sec.SectionName ORDER BY TotalUses DESC;");
        cmd.Parameters.AddWithValue("@I", inst);
        cmd.Parameters.AddWithValue("@S", sess);
        cmd.Parameters.AddWithValue("@Str", streamId);
        cmd.Parameters.AddWithValue("@AIType", aiType ?? "");
        cmd.Parameters.AddWithValue("@DFr", Dt(dateFrom));
        cmd.Parameters.AddWithValue("@DTo", Dt(dateTo));
        return dl.GetDataTable(cmd);
    }

    // ═══════════════════════════════════════════════════════
    // SUBJECT-WISE AI USAGE (via VideoAIHistory → Videos → Chapters)
    // ═══════════════════════════════════════════════════════
    public DataTable GetSubjectWiseUsage(int inst, int sess,
        int streamId, int courseId, string aiType, string dateFrom, string dateTo)
    {
        var cmd = new SqlCommand(@"
            SELECT TOP 10
              LTRIM(RTRIM(sub.SubjectName)) AS SubjectName,
              COUNT(DISTINCT v.Id)          AS VideoAIUses,
              COUNT(DISTINCT m.Id)          AS MaterialAIUses,
              COUNT(DISTINCT v.Id)+COUNT(DISTINCT m.Id) AS TotalUses,
              COUNT(DISTINCT v.UserId)      AS UniqueVideoUsers,
              COUNT(DISTINCT m.UserId)      AS UniqueMaterialUsers
            FROM Subjects sub
            INNER JOIN LevelSemesterSubjects lss
                ON lss.SubjectId=sub.SubjectId AND lss.InstituteId=@I AND lss.SessionId=@S
               AND (@Str=0 OR lss.StreamId=@Str)
               AND (@Crs=0 OR lss.CourseId=@Crs)
            LEFT JOIN Chapters ch ON ch.SubjectId=sub.SubjectId AND ch.InstituteId=@I
            LEFT JOIN Videos vid ON vid.ChapterId=ch.ChapterId AND vid.InstituteId=@I
            LEFT JOIN VideoAIHistory v
                ON v.VideoId=vid.VideoId
               AND (@AIType='' OR v.Type=@AIType)
               AND (CAST(@DFr AS DATE) IS NULL OR CAST(v.CreatedOn AS DATE)>=CAST(@DFr AS DATE))
               AND (CAST(@DTo AS DATE) IS NULL OR CAST(v.CreatedOn AS DATE)<=CAST(@DTo AS DATE))
            LEFT JOIN Materials mat ON mat.ChapterId=ch.ChapterId
            LEFT JOIN MaterialAIHistory m
                ON m.MaterialId=mat.MaterialId
               AND (@AIType='' OR m.Type=@AIType)
               AND (CAST(@DFr AS DATE) IS NULL OR CAST(m.CreatedOn AS DATE)>=CAST(@DFr AS DATE))
               AND (CAST(@DTo AS DATE) IS NULL OR CAST(m.CreatedOn AS DATE)<=CAST(@DTo AS DATE))
            WHERE sub.InstituteId=@I AND sub.SessionId=@S AND sub.IsActive=1
            GROUP BY sub.SubjectId, sub.SubjectName
            ORDER BY TotalUses DESC;");
        cmd.Parameters.AddWithValue("@I", inst);
        cmd.Parameters.AddWithValue("@S", sess);
        cmd.Parameters.AddWithValue("@Str", streamId);
        cmd.Parameters.AddWithValue("@Crs", courseId);
        cmd.Parameters.AddWithValue("@AIType", aiType ?? "");
        cmd.Parameters.AddWithValue("@DFr", Dt(dateFrom));
        cmd.Parameters.AddWithValue("@DTo", Dt(dateTo));
        return dl.GetDataTable(cmd);
    }

    // ═══════════════════════════════════════════════════════
    // TOP AI USERS (most interactions)
    // ═══════════════════════════════════════════════════════
    public DataTable GetTopAIUsers(int inst, int sess,
        int streamId, int courseId, string aiType, string dateFrom, string dateTo)
    {
        var cmd = new SqlCommand(@"
            SELECT TOP 10
              up.FullName,
              ISNULL(sa.RollNumber,'—')   AS RollNumber,
              ISNULL(c.CourseName,'—')    AS CourseName,
              ISNULL(sec.SectionName,'—') AS SectionName,
              ISNULL(up.ProfileImage,'')  AS ProfileImage,
              ISNULL(SUM(v.Cnt),0)        AS VideoAIUses,
              ISNULL(SUM(m.Cnt),0)        AS MaterialAIUses,
              ISNULL(SUM(v.Cnt),0)+ISNULL(SUM(m.Cnt),0) AS TotalUses,
              ISNULL(SUM(v.SumCnt),0)     AS SummaryCnt,
              ISNULL(SUM(v.NoteCnt),0)    AS NotesCnt,
              ISNULL(SUM(v.QuizCnt),0)    AS QuizCnt,
              ISNULL(SUM(v.DbtCnt),0)     AS DoubtCnt
            FROM StudentAcademicDetails sa
            INNER JOIN UserProfile up ON up.UserId=sa.UserId
            LEFT JOIN Courses   c   ON c.CourseId  =sa.CourseId
            LEFT JOIN Sections  sec ON sec.SectionId=sa.SectionId
            LEFT JOIN (
              SELECT UserId,
                COUNT(*) AS Cnt,
                SUM(CASE WHEN Type='Summary' THEN 1 ELSE 0 END) AS SumCnt,
                SUM(CASE WHEN Type='Notes'   THEN 1 ELSE 0 END) AS NoteCnt,
                SUM(CASE WHEN Type='Quiz'    THEN 1 ELSE 0 END) AS QuizCnt,
                SUM(CASE WHEN Type='Doubt'   THEN 1 ELSE 0 END) AS DbtCnt
              FROM VideoAIHistory
              WHERE (@AIType='' OR Type=@AIType)
                AND (CAST(@DFr AS DATE) IS NULL OR CAST(CreatedOn AS DATE)>=CAST(@DFr AS DATE))
                AND (CAST(@DTo AS DATE) IS NULL OR CAST(CreatedOn AS DATE)<=CAST(@DTo AS DATE))
              GROUP BY UserId
            ) v ON v.UserId=sa.UserId
            LEFT JOIN (
              SELECT UserId, COUNT(*) AS Cnt
              FROM MaterialAIHistory
              WHERE (@AIType='' OR Type=@AIType)
                AND (CAST(@DFr AS DATE) IS NULL OR CAST(CreatedOn AS DATE)>=CAST(@DFr AS DATE))
                AND (CAST(@DTo AS DATE) IS NULL OR CAST(CreatedOn AS DATE)<=CAST(@DTo AS DATE))
              GROUP BY UserId
            ) m ON m.UserId=sa.UserId
            WHERE sa.InstituteId=@I AND sa.SessionId=@S
              AND (@Str=0 OR sa.StreamId=@Str)
              AND (@Crs=0 OR sa.CourseId=@Crs)
            GROUP BY sa.UserId, up.FullName, sa.RollNumber,
                     c.CourseName, sec.SectionName, up.ProfileImage
            HAVING ISNULL(SUM(v.Cnt),0)+ISNULL(SUM(m.Cnt),0) > 0
            ORDER BY TotalUses DESC;");
        cmd.Parameters.AddWithValue("@I", inst);
        cmd.Parameters.AddWithValue("@S", sess);
        cmd.Parameters.AddWithValue("@Str", streamId);
        cmd.Parameters.AddWithValue("@Crs", courseId);
        cmd.Parameters.AddWithValue("@AIType", aiType ?? "");
        cmd.Parameters.AddWithValue("@DFr", Dt(dateFrom));
        cmd.Parameters.AddWithValue("@DTo", Dt(dateTo));
        return dl.GetDataTable(cmd);
    }

    // ═══════════════════════════════════════════════════════
    // NON-USERS — students who never used AI
    // ═══════════════════════════════════════════════════════
    public DataTable GetNonAIUsers(int inst, int sess,
        int streamId, int courseId, string dateFrom, string dateTo)
    {
        var cmd = new SqlCommand(@"
            SELECT TOP 15
              up.FullName,
              ISNULL(sa.RollNumber,'—')   AS RollNumber,
              ISNULL(c.CourseName,'—')    AS CourseName,
              ISNULL(sec.SectionName,'—') AS SectionName,
              ISNULL(up.ProfileImage,'')  AS ProfileImage
            FROM StudentAcademicDetails sa
            INNER JOIN UserProfile up  ON up.UserId  = sa.UserId
            LEFT  JOIN Courses     c   ON c.CourseId  = sa.CourseId
            LEFT  JOIN Sections    sec ON sec.SectionId= sa.SectionId
            WHERE sa.InstituteId=@I AND sa.SessionId=@S
              AND (@Str=0 OR sa.StreamId=@Str)
              AND (@Crs=0 OR sa.CourseId=@Crs)
              AND NOT EXISTS (
                SELECT 1 FROM VideoAIHistory v
                WHERE v.UserId=sa.UserId
                  AND (CAST(@DFr AS DATE) IS NULL OR CAST(v.CreatedOn AS DATE)>=CAST(@DFr AS DATE))
                  AND (CAST(@DTo AS DATE) IS NULL OR CAST(v.CreatedOn AS DATE)<=CAST(@DTo AS DATE))
              )
              AND NOT EXISTS (
                SELECT 1 FROM MaterialAIHistory m
                WHERE m.UserId=sa.UserId
                  AND (CAST(@DFr AS DATE) IS NULL OR CAST(m.CreatedOn AS DATE)>=CAST(@DFr AS DATE))
                  AND (CAST(@DTo AS DATE) IS NULL OR CAST(m.CreatedOn AS DATE)<=CAST(@DTo AS DATE))
              )
            ORDER BY up.FullName;");
        cmd.Parameters.AddWithValue("@I", inst);
        cmd.Parameters.AddWithValue("@S", sess);
        cmd.Parameters.AddWithValue("@Str", streamId);
        cmd.Parameters.AddWithValue("@Crs", courseId);
        cmd.Parameters.AddWithValue("@DFr", Dt(dateFrom));
        cmd.Parameters.AddWithValue("@DTo", Dt(dateTo));
        return dl.GetDataTable(cmd);
    }

    // ═══════════════════════════════════════════════════════
    // HOURLY USAGE PATTERN
    // ═══════════════════════════════════════════════════════
    public DataTable GetHourlyPattern(int inst, int sess,
        int streamId, string dateFrom, string dateTo)
    {
        var cmd = new SqlCommand(@"
            SELECT Hr, SUM(Cnt) AS Total FROM (
              SELECT DATEPART(HOUR, v.CreatedOn) AS Hr, COUNT(*) AS Cnt
              FROM VideoAIHistory v
              JOIN StudentAcademicDetails sa ON sa.UserId=v.UserId
              WHERE sa.InstituteId=@I AND sa.SessionId=@S
                AND (@Str=0 OR sa.StreamId=@Str)
                AND (CAST(@DFr AS DATE) IS NULL OR CAST(v.CreatedOn AS DATE)>=CAST(@DFr AS DATE))
                AND (CAST(@DTo AS DATE) IS NULL OR CAST(v.CreatedOn AS DATE)<=CAST(@DTo AS DATE))
              GROUP BY DATEPART(HOUR, v.CreatedOn)
              UNION ALL
              SELECT DATEPART(HOUR, m.CreatedOn) AS Hr, COUNT(*) AS Cnt
              FROM MaterialAIHistory m
              JOIN StudentAcademicDetails sa ON sa.UserId=m.UserId
              WHERE sa.InstituteId=@I AND sa.SessionId=@S
                AND (@Str=0 OR sa.StreamId=@Str)
                AND (CAST(@DFr AS DATE) IS NULL OR CAST(m.CreatedOn AS DATE)>=CAST(@DFr AS DATE))
                AND (CAST(@DTo AS DATE) IS NULL OR CAST(m.CreatedOn AS DATE)<=CAST(@DTo AS DATE))
              GROUP BY DATEPART(HOUR, m.CreatedOn)
            ) X GROUP BY Hr ORDER BY Hr;");
        cmd.Parameters.AddWithValue("@I", inst);
        cmd.Parameters.AddWithValue("@S", sess);
        cmd.Parameters.AddWithValue("@Str", streamId);
        cmd.Parameters.AddWithValue("@DFr", Dt(dateFrom));
        cmd.Parameters.AddWithValue("@DTo", Dt(dateTo));
        return dl.GetDataTable(cmd);
    }

    // ═══════════════════════════════════════════════════════
    // RECENT AI ACTIVITY FEED
    // ═══════════════════════════════════════════════════════
    public DataTable GetRecentActivity(int inst, int sess,
        int streamId, string aiType, string dateFrom, string dateTo)
    {
        var cmd = new SqlCommand(@"
            SELECT TOP 20
              up.FullName,
              ISNULL(up.ProfileImage,'') AS ProfileImage,
              AIType, Source, Question, UsedOn,
              ISNULL(c.CourseName,'—') AS CourseName,
              ISNULL(sec.SectionName,'—') AS SectionName
            FROM (
              SELECT v.UserId, v.Type AS AIType, 'Video' AS Source,
                     LEFT(ISNULL(v.Question,''),120) AS Question,
                     v.CreatedOn AS UsedOn
              FROM VideoAIHistory v
              JOIN StudentAcademicDetails sa ON sa.UserId=v.UserId
              WHERE sa.InstituteId=@I AND sa.SessionId=@S
                AND (@Str=0 OR sa.StreamId=@Str)
                AND (@AIType='' OR v.Type=@AIType)
                AND (CAST(@DFr AS DATE) IS NULL OR CAST(v.CreatedOn AS DATE)>=CAST(@DFr AS DATE))
                AND (CAST(@DTo AS DATE) IS NULL OR CAST(v.CreatedOn AS DATE)<=CAST(@DTo AS DATE))
              UNION ALL
              SELECT m.UserId, m.Type AS AIType, 'Material' AS Source,
                     LEFT(ISNULL(m.Question,''),120) AS Question,
                     m.CreatedOn AS UsedOn
              FROM MaterialAIHistory m
              JOIN StudentAcademicDetails sa ON sa.UserId=m.UserId
              WHERE sa.InstituteId=@I AND sa.SessionId=@S
                AND (@Str=0 OR sa.StreamId=@Str)
                AND (@AIType='' OR m.Type=@AIType)
                AND (CAST(@DFr AS DATE) IS NULL OR CAST(m.CreatedOn AS DATE)>=CAST(@DFr AS DATE))
                AND (CAST(@DTo AS DATE) IS NULL OR CAST(m.CreatedOn AS DATE)<=CAST(@DTo AS DATE))
            ) act
            INNER JOIN UserProfile up ON up.UserId=act.UserId
            INNER JOIN StudentAcademicDetails sa ON sa.UserId=act.UserId AND sa.SessionId=@S
            LEFT  JOIN Courses  c   ON c.CourseId  =sa.CourseId
            LEFT  JOIN Sections sec ON sec.SectionId=sa.SectionId
            ORDER BY UsedOn DESC;");
        cmd.Parameters.AddWithValue("@I", inst);
        cmd.Parameters.AddWithValue("@S", sess);
        cmd.Parameters.AddWithValue("@Str", streamId);
        cmd.Parameters.AddWithValue("@AIType", aiType ?? "");
        cmd.Parameters.AddWithValue("@DFr", Dt(dateFrom));
        cmd.Parameters.AddWithValue("@DTo", Dt(dateTo));
        return dl.GetDataTable(cmd);
    }

    // ═══════════════════════════════════════════════════════
    // WEEKLY TREND (last 8 weeks)
    // ═══════════════════════════════════════════════════════
    public DataTable GetWeeklyTrend(int inst, int sess, int streamId, string dateFrom, string dateTo)
    {
        var cmd = new SqlCommand(@"
            WITH Weeks AS (
              SELECT TOP 8
                DATEADD(WEEK,-n,GETDATE()) AS WkStart,
                DATEPART(ISO_WEEK,DATEADD(WEEK,-n,GETDATE())) AS WNum,
                'Wk '+CAST(ROW_NUMBER() OVER(ORDER BY n DESC) AS VARCHAR) AS WLabel
              FROM (VALUES(0),(1),(2),(3),(4),(5),(6),(7)) T(n)
            )
            SELECT w.WLabel,
              ISNULL(COUNT(DISTINCT v.Id),0)+ISNULL(COUNT(DISTINCT m.Id),0) AS Total,
              COUNT(DISTINCT COALESCE(v.UserId,m.UserId)) AS UniqueUsers
            FROM Weeks w
            LEFT JOIN VideoAIHistory v
              ON DATEPART(ISO_WEEK,v.CreatedOn)=w.WNum AND YEAR(v.CreatedOn)=YEAR(w.WkStart)
            LEFT JOIN MaterialAIHistory m
              ON DATEPART(ISO_WEEK,m.CreatedOn)=w.WNum AND YEAR(m.CreatedOn)=YEAR(w.WkStart)
            LEFT JOIN StudentAcademicDetails sa ON sa.UserId=COALESCE(v.UserId,m.UserId)
              AND sa.InstituteId=@I AND sa.SessionId=@S
              AND (@Str=0 OR sa.StreamId=@Str)
            GROUP BY w.WLabel, w.WNum ORDER BY w.WNum;");
        cmd.Parameters.AddWithValue("@I", inst);
        cmd.Parameters.AddWithValue("@S", sess);
        cmd.Parameters.AddWithValue("@Str", streamId);
        cmd.Parameters.AddWithValue("@DFr", Dt(dateFrom));
        cmd.Parameters.AddWithValue("@DTo", Dt(dateTo));
        return dl.GetDataTable(cmd);
    }

    // ═══════════════════════════════════════════════════════
    // HELPER
    // ═══════════════════════════════════════════════════════
    private void AddP(SqlCommand cmd, int inst, int sess,
        int str, int crs, int sec, string aiType, string dFr, string dTo)
    {
        cmd.Parameters.AddWithValue("@I", inst);
        cmd.Parameters.AddWithValue("@S", sess);
        cmd.Parameters.AddWithValue("@Str", str);
        cmd.Parameters.AddWithValue("@Crs", crs);
        cmd.Parameters.AddWithValue("@Sec", sec);
        cmd.Parameters.AddWithValue("@AIType", aiType ?? "");
        cmd.Parameters.AddWithValue("@DFr", Dt(dFr));
        cmd.Parameters.AddWithValue("@DTo", Dt(dTo));
    }

    private object Dt(string s) =>
        string.IsNullOrWhiteSpace(s) ? (object)DBNull.Value : (object)s;
}