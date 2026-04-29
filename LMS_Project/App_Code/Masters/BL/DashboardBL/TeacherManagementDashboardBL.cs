using System;
using System.Data;
using System.Data.SqlClient;

/// <summary>
/// BL for Teacher Management Dashboard
/// All filter params default to 0/"" = no filter applied
/// </summary>
public class TeacherManagementDashboardBL
{
    DataLayer dl = new DataLayer();

    // ═══════════════════════════════════════════════════════════
    // DROPDOWN HELPERS
    // ═══════════════════════════════════════════════════════════

    public DataTable GetStreams(int instituteId, int sessionId)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT StreamId, StreamName FROM Streams
            WHERE InstituteId=@Inst AND SessionId=@Sess AND IsActive=1
            ORDER BY StreamName;");
        cmd.Parameters.AddWithValue("@Inst", instituteId);
        cmd.Parameters.AddWithValue("@Sess", sessionId);
        return dl.GetDataTable(cmd);
    }

    public DataTable GetCoursesByStream(int instituteId, int sessionId, int streamId)
    {
        SqlCommand cmd = new SqlCommand(@"
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
        SqlCommand cmd = new SqlCommand(@"
            SELECT SectionId, SectionName FROM Sections
            WHERE InstituteId=@Inst AND SessionId=@Sess AND IsActive=1
            ORDER BY SectionName;");
        cmd.Parameters.AddWithValue("@Inst", instituteId);
        cmd.Parameters.AddWithValue("@Sess", sessionId);
        return dl.GetDataTable(cmd);
    }

    public DataTable GetDesignations(int instituteId, int sessionId)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT DISTINCT ISNULL(LTRIM(RTRIM(Designation)),'—') AS Designation
            FROM TeacherDetails
            WHERE InstituteId=@Inst AND SessionId=@Sess
              AND Designation IS NOT NULL AND Designation<>''
            ORDER BY Designation;");
        cmd.Parameters.AddWithValue("@Inst", instituteId);
        cmd.Parameters.AddWithValue("@Sess", sessionId);
        return dl.GetDataTable(cmd);
    }

    // ═══════════════════════════════════════════════════════════
    // KPI SUMMARY
    // ═══════════════════════════════════════════════════════════
    public DataTable GetKPISummary(int instituteId, int sessionId,
        int streamId, int sectionId, string designation,
        string joinMonth, string joinYear)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT
                COUNT(DISTINCT td.UserId)                           AS TotalTeachers,
                SUM(CASE WHEN u.IsActive=1 THEN 1 ELSE 0 END)      AS ActiveTeachers,
                SUM(CASE WHEN u.IsActive=0 THEN 1 ELSE 0 END)      AS InactiveTeachers,
                SUM(CASE WHEN u.IsFirstLogin=1 THEN 1 ELSE 0 END)  AS NewJoined,

                -- Total videos uploaded
                COUNT(DISTINCT v.VideoId)                           AS TotalVideos,

                -- Total assignments created
                COUNT(DISTINCT a.AssignmentId)                      AS TotalAssignments,

                -- Total quizzes created
                COUNT(DISTINCT q.QuizId)                            AS TotalQuizzes,

                -- Avg experience
                ISNULL(AVG(CAST(td.ExperienceYears AS FLOAT)),0)   AS AvgExperience,

                -- Unique subjects taught
                COUNT(DISTINCT sf.SubjectId)                        AS SubjectsTaught,

                -- Total students across all teachers
                COUNT(DISTINCT sa.UserId)                           AS TotalStudents,

                -- Gender
                SUM(CASE WHEN up.Gender='Male'   THEN 1 ELSE 0 END) AS Males,
                SUM(CASE WHEN up.Gender='Female' THEN 1 ELSE 0 END) AS Females

            FROM TeacherDetails td
            INNER JOIN Users       u   ON u.UserId    = td.UserId
            INNER JOIN UserProfile up  ON up.UserId   = td.UserId

            LEFT JOIN SubjectFaculty sf
                ON sf.TeacherId  = td.UserId
               AND sf.InstituteId= @Inst
               AND sf.SessionId  = @Sess
               AND sf.IsActive   = 1

            LEFT JOIN TeacherCourses tc
                ON tc.TeacherId  = td.UserId
               AND tc.InstituteId= @Inst
               AND tc.SessionId  = @Sess

            LEFT JOIN Videos v
                ON v.InstructorId = td.UserId
               AND v.InstituteId  = @Inst
               AND v.SessionId    = @Sess
               AND v.IsActive     = 1

            LEFT JOIN Assignments a
                ON a.CreatedBy   = td.UserId
               AND a.InstituteId = @Inst
               AND a.SessionId   = @Sess
               AND a.IsActive    = 1

            LEFT JOIN Quizzes q
                ON q.CreatedBy   = td.UserId
               AND q.InstituteId = @Inst
               AND q.SessionId   = @Sess
               AND q.IsEnabled   = 1

            LEFT JOIN StudentAcademicDetails sa
                ON sa.StreamId   = td.StreamId
               AND sa.InstituteId= @Inst
               AND sa.SessionId  = @Sess

            WHERE td.InstituteId = @Inst
              AND td.SessionId   = @Sess
              AND u.IsActive IS NOT NULL
              AND (@Stream  =0   OR td.StreamId  =@Stream)
              AND (@Section =0   OR td.SectionId =@Section)
              AND (@Desig   =''  OR ISNULL(td.Designation,'')=@Desig)
              AND (@Month   =''  OR MONTH(up.JoinedDate)=TRY_CAST(@Month AS INT))
              AND (@Year    =''  OR YEAR(up.JoinedDate) =TRY_CAST(@Year  AS INT));");

        AddCommonParams(cmd, instituteId, sessionId, streamId, sectionId,
                        designation, joinMonth, joinYear);
        return dl.GetDataTable(cmd);
    }

    // ═══════════════════════════════════════════════════════════
    // TEACHER LIST — paginated with search
    // ═══════════════════════════════════════════════════════════
    public DataTable GetTeacherList(int instituteId, int sessionId,
        int streamId, int sectionId, string designation,
        string joinMonth, string joinYear, string search,
        int pageIndex, int pageSize)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT * FROM (
              SELECT
                ROW_NUMBER() OVER (ORDER BY up.FullName) AS RowNum,
                td.UserId,
                up.FullName,
                ISNULL(td.EmployeeId,'—')           AS EmployeeId,
                ISNULL(st.StreamName,'—')            AS StreamName,
                ISNULL(sec.SectionName,'—')          AS SectionName,
                ISNULL(td.Designation,'—')           AS Designation,
                ISNULL(td.Qualification,'—')         AS Qualification,
                ISNULL(td.ExperienceYears,0)         AS ExperienceYears,
                up.Gender,
                up.ContactNo,
                up.Email                             AS TeacherEmail,
                ISNULL(up.ProfileImage,'')           AS ProfileImage,
                CONVERT(VARCHAR(10),up.JoinedDate,105) AS JoinedDate,
                CASE WHEN u.IsActive=1 THEN 'Active' ELSE 'Inactive' END AS Status,
                CASE WHEN u.IsFirstLogin=1 THEN 'New' ELSE 'Returning' END AS JoinType,

                -- Activity counts
                (SELECT COUNT(*) FROM Videos v2
                 WHERE v2.InstructorId=td.UserId AND v2.InstituteId=@Inst
                   AND v2.SessionId=@Sess AND v2.IsActive=1)       AS VideoCount,

                (SELECT COUNT(*) FROM Assignments a2
                 WHERE a2.CreatedBy=td.UserId AND a2.InstituteId=@Inst
                   AND a2.SessionId=@Sess AND a2.IsActive=1)        AS AssignCount,

                (SELECT COUNT(*) FROM Quizzes q2
                 WHERE q2.CreatedBy=td.UserId AND q2.InstituteId=@Inst
                   AND q2.SessionId=@Sess AND q2.IsEnabled=1)       AS QuizCount,

                (SELECT COUNT(DISTINCT sf2.SubjectId)
                 FROM SubjectFaculty sf2
                 WHERE sf2.TeacherId=td.UserId AND sf2.InstituteId=@Inst
                   AND sf2.SessionId=@Sess AND sf2.IsActive=1)      AS SubjectCount,

                -- Avg student performance in their classes
                ISNULL(CAST(AVG(CAST(qr.Score AS FLOAT)) AS DECIMAL(5,1)),0) AS AvgStudentScore

              FROM TeacherDetails td
              INNER JOIN Users       u   ON u.UserId   = td.UserId
              INNER JOIN UserProfile up  ON up.UserId  = td.UserId
              LEFT  JOIN Streams     st  ON st.StreamId= td.StreamId
              LEFT  JOIN Sections    sec ON sec.SectionId=td.SectionId

              -- Student quiz scores in teacher's quizzes
              LEFT JOIN Quizzes q3     ON q3.CreatedBy=td.UserId AND q3.InstituteId=@Inst AND q3.SessionId=@Sess
              LEFT JOIN QuizResults qr ON qr.QuizId=q3.QuizId AND qr.InstituteId=@Inst AND qr.SessionId=@Sess

              WHERE td.InstituteId=@Inst AND td.SessionId=@Sess
                AND (@Stream  =0  OR td.StreamId  =@Stream)
                AND (@Section =0  OR td.SectionId =@Section)
                AND (@Desig   ='' OR ISNULL(td.Designation,'')=@Desig)
                AND (@Month   ='' OR MONTH(up.JoinedDate)=TRY_CAST(@Month AS INT))
                AND (@Year    ='' OR YEAR(up.JoinedDate) =TRY_CAST(@Year  AS INT))
                AND (@Search  ='' OR up.FullName   LIKE '%'+@Search+'%'
                                  OR td.EmployeeId LIKE '%'+@Search+'%'
                                  OR up.ContactNo  LIKE '%'+@Search+'%'
                                  OR ISNULL(td.Designation,'') LIKE '%'+@Search+'%')

              GROUP BY td.UserId, up.FullName, td.EmployeeId, st.StreamName,
                sec.SectionName, td.Designation, td.Qualification,
                td.ExperienceYears, up.Gender, up.ContactNo,
                up.Email, up.ProfileImage, up.JoinedDate, u.IsActive, u.IsFirstLogin
            ) T
            WHERE RowNum BETWEEN @Skip+1 AND @Skip+@Size;");

        AddCommonParams(cmd, instituteId, sessionId, streamId, sectionId,
                        designation, joinMonth, joinYear);
        cmd.Parameters.AddWithValue("@Search", search ?? "");
        cmd.Parameters.AddWithValue("@Skip", pageIndex * pageSize);
        cmd.Parameters.AddWithValue("@Size", pageSize);
        return dl.GetDataTable(cmd);
    }

    public int GetTeacherCount(int instituteId, int sessionId,
        int streamId, int sectionId, string designation,
        string joinMonth, string joinYear, string search)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT COUNT(DISTINCT td.UserId)
            FROM TeacherDetails td
            INNER JOIN Users       u  ON u.UserId  = td.UserId
            INNER JOIN UserProfile up ON up.UserId = td.UserId
            WHERE td.InstituteId=@Inst AND td.SessionId=@Sess
              AND (@Stream  =0  OR td.StreamId  =@Stream)
              AND (@Section =0  OR td.SectionId =@Section)
              AND (@Desig   ='' OR ISNULL(td.Designation,'')=@Desig)
              AND (@Month   ='' OR MONTH(up.JoinedDate)=TRY_CAST(@Month AS INT))
              AND (@Year    ='' OR YEAR(up.JoinedDate) =TRY_CAST(@Year  AS INT))
              AND (@Search  ='' OR up.FullName   LIKE '%'+@Search+'%'
                                OR td.EmployeeId LIKE '%'+@Search+'%');");
        AddCommonParams(cmd, instituteId, sessionId, streamId, sectionId,
                        designation, joinMonth, joinYear);
        cmd.Parameters.AddWithValue("@Search", search ?? "");
        var dt = dl.GetDataTable(cmd);
        return dt?.Rows.Count > 0 ? Convert.ToInt32(dt.Rows[0][0]) : 0;
    }

    // ═══════════════════════════════════════════════════════════
    // MONTHLY JOINING TREND
    // ═══════════════════════════════════════════════════════════
    public DataTable GetMonthlyJoiningTrend(int instituteId, int sessionId)
    {
        SqlCommand cmd = new SqlCommand(@"
            WITH Months AS (
              SELECT TOP 12
                MONTH(DATEADD(MONTH,-n,GETDATE())) M,
                YEAR(DATEADD(MONTH,-n,GETDATE()))  Y,
                LEFT(DATENAME(MONTH,DATEADD(MONTH,-n,GETDATE())),3) MName
              FROM (VALUES(0),(1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11)) T(n)
            )
            SELECT m.MName AS Mon, m.M, m.Y,
                   COUNT(td.UserId) AS Teachers
            FROM Months m
            LEFT JOIN TeacherDetails td
                ON MONTH(td.SessionId) = m.M  -- JoinedDate via UserProfile
               AND td.InstituteId=@Inst AND td.SessionId=@Sess
            LEFT JOIN UserProfile up ON up.UserId=td.UserId
                AND MONTH(up.JoinedDate)=m.M AND YEAR(up.JoinedDate)=m.Y
            GROUP BY m.MName,m.M,m.Y
            ORDER BY m.Y,m.M;");
        cmd.Parameters.AddWithValue("@Inst", instituteId);
        cmd.Parameters.AddWithValue("@Sess", sessionId);
        return dl.GetDataTable(cmd);
    }

    // ═══════════════════════════════════════════════════════════
    // STREAM-WISE TEACHER COUNT
    // ═══════════════════════════════════════════════════════════
    public DataTable GetStreamWiseTeachers(int instituteId, int sessionId)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT ISNULL(st.StreamName,'Unassigned') AS StreamName,
                   COUNT(DISTINCT td.UserId) AS Teachers
            FROM TeacherDetails td
            LEFT JOIN Streams st ON st.StreamId=td.StreamId
            WHERE td.InstituteId=@Inst AND td.SessionId=@Sess
            GROUP BY st.StreamName ORDER BY Teachers DESC;");
        cmd.Parameters.AddWithValue("@Inst", instituteId);
        cmd.Parameters.AddWithValue("@Sess", sessionId);
        return dl.GetDataTable(cmd);
    }

    // ═══════════════════════════════════════════════════════════
    // DESIGNATION-WISE COUNT
    // ═══════════════════════════════════════════════════════════
    public DataTable GetDesignationWiseCount(int instituteId, int sessionId)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT ISNULL(LTRIM(RTRIM(td.Designation)),'Unassigned') AS Designation,
                   COUNT(DISTINCT td.UserId) AS Teachers
            FROM TeacherDetails td
            WHERE td.InstituteId=@Inst AND td.SessionId=@Sess
            GROUP BY td.Designation ORDER BY Teachers DESC;");
        cmd.Parameters.AddWithValue("@Inst", instituteId);
        cmd.Parameters.AddWithValue("@Sess", sessionId);
        return dl.GetDataTable(cmd);
    }

    // ═══════════════════════════════════════════════════════════
    // EXPERIENCE DISTRIBUTION (buckets)
    // ═══════════════════════════════════════════════════════════
    public DataTable GetExperienceDistribution(int instituteId, int sessionId)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT
              CASE
                WHEN ISNULL(td.ExperienceYears,0) < 2  THEN '0-1 yrs'
                WHEN td.ExperienceYears < 5             THEN '2-4 yrs'
                WHEN td.ExperienceYears < 10            THEN '5-9 yrs'
                WHEN td.ExperienceYears < 15            THEN '10-14 yrs'
                ELSE '15+ yrs'
              END AS ExpBucket,
              COUNT(*) AS Teachers
            FROM TeacherDetails td
            WHERE td.InstituteId=@Inst AND td.SessionId=@Sess
            GROUP BY
              CASE
                WHEN ISNULL(td.ExperienceYears,0) < 2  THEN '0-1 yrs'
                WHEN td.ExperienceYears < 5             THEN '2-4 yrs'
                WHEN td.ExperienceYears < 10            THEN '5-9 yrs'
                WHEN td.ExperienceYears < 15            THEN '10-14 yrs'
                ELSE '15+ yrs'
              END
            ORDER BY MIN(ISNULL(td.ExperienceYears,0));");
        cmd.Parameters.AddWithValue("@Inst", instituteId);
        cmd.Parameters.AddWithValue("@Sess", sessionId);
        return dl.GetDataTable(cmd);
    }

    // ═══════════════════════════════════════════════════════════
    // GENDER DISTRIBUTION
    // ═══════════════════════════════════════════════════════════
    public DataTable GetGenderDistribution(int instituteId, int sessionId,
        int streamId)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT ISNULL(up.Gender,'Unknown') AS Gender,
                   COUNT(*) AS Total
            FROM TeacherDetails td
            INNER JOIN UserProfile up ON up.UserId=td.UserId
            WHERE td.InstituteId=@Inst AND td.SessionId=@Sess
              AND (@Stream=0 OR td.StreamId=@Stream)
            GROUP BY up.Gender ORDER BY Total DESC;");
        cmd.Parameters.AddWithValue("@Inst", instituteId);
        cmd.Parameters.AddWithValue("@Sess", sessionId);
        cmd.Parameters.AddWithValue("@Stream", streamId);
        return dl.GetDataTable(cmd);
    }

    // ═══════════════════════════════════════════════════════════
    // TOP TEACHERS BY CONTENT OUTPUT
    // ═══════════════════════════════════════════════════════════
    public DataTable GetTopTeachersByContent(int instituteId, int sessionId,
        int streamId)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT TOP 10
                up.FullName,
                ISNULL(td.Designation,'Teacher')    AS Designation,
                ISNULL(st.StreamName,'—')           AS StreamName,
                ISNULL(td.ExperienceYears,0)        AS ExperienceYears,
                ISNULL(up.ProfileImage,'')          AS ProfileImage,

                COUNT(DISTINCT v.VideoId)           AS Videos,
                COUNT(DISTINCT a.AssignmentId)      AS Assignments,
                COUNT(DISTINCT q.QuizId)            AS Quizzes,
                COUNT(DISTINCT vv.ViewId)           AS VideoViews,

                -- Students in their classes
                COUNT(DISTINCT sa.UserId)           AS StudentsReached,

                -- Avg student score on their quizzes
                ISNULL(CAST(AVG(CAST(qr.Score AS FLOAT)) AS DECIMAL(5,1)),0) AS AvgStudentScore,

                -- Total activities
                COUNT(DISTINCT v.VideoId)+COUNT(DISTINCT a.AssignmentId)+COUNT(DISTINCT q.QuizId) AS TotalActivity

            FROM TeacherDetails td
            INNER JOIN Users       u  ON u.UserId   = td.UserId
            INNER JOIN UserProfile up ON up.UserId  = td.UserId
            LEFT  JOIN Streams     st ON st.StreamId= td.StreamId

            LEFT JOIN Videos v
                ON v.InstructorId=td.UserId AND v.InstituteId=@Inst
               AND v.SessionId=@Sess AND v.IsActive=1

            LEFT JOIN VideoViews vv ON vv.VideoId=v.VideoId AND vv.SessionId=@Sess

            LEFT JOIN Assignments a
                ON a.CreatedBy=td.UserId AND a.InstituteId=@Inst
               AND a.SessionId=@Sess AND a.IsActive=1

            LEFT JOIN Quizzes q
                ON q.CreatedBy=td.UserId AND q.InstituteId=@Inst
               AND q.SessionId=@Sess AND q.IsEnabled=1

            LEFT JOIN QuizResults qr
                ON qr.QuizId=q.QuizId AND qr.InstituteId=@Inst AND qr.SessionId=@Sess

            LEFT JOIN TeacherCourses tc
                ON tc.TeacherId=td.UserId AND tc.InstituteId=@Inst AND tc.SessionId=@Sess

            LEFT JOIN StudentAcademicDetails sa
                ON sa.StreamId=td.StreamId AND sa.InstituteId=@Inst AND sa.SessionId=@Sess

            WHERE td.InstituteId=@Inst AND td.SessionId=@Sess AND u.IsActive=1
              AND (@Stream=0 OR td.StreamId=@Stream)
            GROUP BY td.UserId,up.FullName,td.Designation,st.StreamName,
                     td.ExperienceYears,up.ProfileImage
            ORDER BY TotalActivity DESC, AvgStudentScore DESC;");

        cmd.Parameters.AddWithValue("@Inst", instituteId);
        cmd.Parameters.AddWithValue("@Sess", sessionId);
        cmd.Parameters.AddWithValue("@Stream", streamId);
        return dl.GetDataTable(cmd);
    }

    // ═══════════════════════════════════════════════════════════
    // SUBJECT-WISE TEACHER ASSIGNMENT
    // ═══════════════════════════════════════════════════════════
    public DataTable GetSubjectWiseTeachers(int instituteId, int sessionId,
        int streamId)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT TOP 10
                sub.SubjectName,
                COUNT(DISTINCT sf.TeacherId) AS Teachers,
                COUNT(DISTINCT v.VideoId)    AS Videos,
                COUNT(DISTINCT a.AssignmentId) AS Assignments
            FROM SubjectFaculty sf
            INNER JOIN Subjects sub ON sub.SubjectId=sf.SubjectId
            LEFT  JOIN Videos v
                ON v.InstituteId=@Inst AND v.SessionId=@Sess
               AND v.ChapterId IN (SELECT ChapterId FROM Chapters WHERE SubjectId=sub.SubjectId AND InstituteId=@Inst)
            LEFT JOIN Assignments a
                ON a.SubjectId=sub.SubjectId AND a.InstituteId=@Inst AND a.SessionId=@Sess
            WHERE sf.InstituteId=@Inst AND sf.SessionId=@Sess
              AND sf.IsActive=1
              AND (@Stream=0 OR EXISTS(
                SELECT 1 FROM LevelSemesterSubjects lss
                WHERE lss.SubjectId=sf.SubjectId AND lss.StreamId=@Stream
                  AND lss.InstituteId=@Inst AND lss.SessionId=@Sess))
            GROUP BY sub.SubjectId,sub.SubjectName
            ORDER BY Teachers DESC;");
        cmd.Parameters.AddWithValue("@Inst", instituteId);
        cmd.Parameters.AddWithValue("@Sess", sessionId);
        cmd.Parameters.AddWithValue("@Stream", streamId);
        return dl.GetDataTable(cmd);
    }

    // ═══════════════════════════════════════════════════════════
    // CONTENT OUTPUT TREND — weekly videos + assignments last 8 weeks
    // ═══════════════════════════════════════════════════════════
    public DataTable GetContentOutputTrend(int instituteId, int sessionId,
        int streamId)
    {
        SqlCommand cmd = new SqlCommand(@"
            WITH Weeks AS (
                SELECT TOP 8
                    DATEADD(WEEK,-n,GETDATE()) AS WeekStart,
                    DATEPART(ISO_WEEK,DATEADD(WEEK,-n,GETDATE())) AS WNum
                FROM (VALUES(0),(1),(2),(3),(4),(5),(6),(7)) T(n)
            )
            SELECT
                'W'+CAST(ROW_NUMBER() OVER(ORDER BY w.WeekStart) AS VARCHAR) AS WeekLabel,
                ISNULL(COUNT(DISTINCT v.VideoId),0)     AS Videos,
                ISNULL(COUNT(DISTINCT a.AssignmentId),0) AS Assignments,
                ISNULL(COUNT(DISTINCT q.QuizId),0)       AS Quizzes
            FROM Weeks w
            LEFT JOIN Videos v
                ON DATEPART(ISO_WEEK,v.UploadedOn)=w.WNum
               AND YEAR(v.UploadedOn)=YEAR(w.WeekStart)
               AND v.InstituteId=@Inst AND v.SessionId=@Sess AND v.IsActive=1
               AND (@Stream=0 OR EXISTS(
                   SELECT 1 FROM TeacherDetails td2
                   WHERE td2.UserId=v.InstructorId AND td2.StreamId=@Stream))
            LEFT JOIN Assignments a
                ON DATEPART(ISO_WEEK,a.CreatedOn)=w.WNum
               AND YEAR(a.CreatedOn)=YEAR(w.WeekStart)
               AND a.InstituteId=@Inst AND a.SessionId=@Sess AND a.IsActive=1
            LEFT JOIN Quizzes q
                ON DATEPART(ISO_WEEK,q.CreatedOn)=w.WNum
               AND YEAR(q.CreatedOn)=YEAR(w.WeekStart)
               AND q.InstituteId=@Inst AND q.SessionId=@Sess AND q.IsEnabled=1
            GROUP BY w.WeekStart,w.WNum
            ORDER BY w.WeekStart;");
        cmd.Parameters.AddWithValue("@Inst", instituteId);
        cmd.Parameters.AddWithValue("@Sess", sessionId);
        cmd.Parameters.AddWithValue("@Stream", streamId);
        return dl.GetDataTable(cmd);
    }

    // ═══════════════════════════════════════════════════════════
    // QUALIFICATION DISTRIBUTION
    // ═══════════════════════════════════════════════════════════
    public DataTable GetQualificationDistribution(int instituteId, int sessionId)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT ISNULL(LTRIM(RTRIM(td.Qualification)),'Not Specified') AS Qualification,
                   COUNT(*) AS Teachers
            FROM TeacherDetails td
            WHERE td.InstituteId=@Inst AND td.SessionId=@Sess
            GROUP BY td.Qualification ORDER BY Teachers DESC;");
        cmd.Parameters.AddWithValue("@Inst", instituteId);
        cmd.Parameters.AddWithValue("@Sess", sessionId);
        return dl.GetDataTable(cmd);
    }

    // ═══════════════════════════════════════════════════════════
    // TEACHER PERFORMANCE RADAR data (avg per teacher metrics)
    // ═══════════════════════════════════════════════════════════
    public DataTable GetTeacherPerformanceMetrics(int instituteId, int sessionId,
        int streamId)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT
                CAST(AVG(CAST(vid_cnt AS FLOAT)) AS DECIMAL(5,1)) AS AvgVideos,
                CAST(AVG(CAST(asn_cnt AS FLOAT)) AS DECIMAL(5,1)) AS AvgAssignments,
                CAST(AVG(CAST(quz_cnt AS FLOAT)) AS DECIMAL(5,1)) AS AvgQuizzes,
                CAST(AVG(CAST(stu_cnt AS FLOAT)) AS DECIMAL(5,1)) AS AvgStudents,
                CAST(AVG(CAST(vw_cnt  AS FLOAT)) AS DECIMAL(5,1)) AS AvgVideoViews,
                CAST(AVG(CAST(score   AS FLOAT)) AS DECIMAL(5,1)) AS AvgStudentScore
            FROM (
                SELECT
                    td.UserId,
                    COUNT(DISTINCT v.VideoId)         AS vid_cnt,
                    COUNT(DISTINCT a.AssignmentId)    AS asn_cnt,
                    COUNT(DISTINCT q.QuizId)          AS quz_cnt,
                    COUNT(DISTINCT sa.UserId)         AS stu_cnt,
                    COUNT(DISTINCT vv.ViewId)         AS vw_cnt,
                    ISNULL(AVG(CAST(qr.Score AS FLOAT)),0) AS score
                FROM TeacherDetails td
                LEFT JOIN Videos v ON v.InstructorId=td.UserId AND v.InstituteId=@Inst AND v.SessionId=@Sess
                LEFT JOIN VideoViews vv ON vv.VideoId=v.VideoId
                LEFT JOIN Assignments a ON a.CreatedBy=td.UserId AND a.InstituteId=@Inst AND a.SessionId=@Sess
                LEFT JOIN Quizzes q ON q.CreatedBy=td.UserId AND q.InstituteId=@Inst AND q.SessionId=@Sess
                LEFT JOIN QuizResults qr ON qr.QuizId=q.QuizId AND qr.SessionId=@Sess
                LEFT JOIN StudentAcademicDetails sa ON sa.StreamId=td.StreamId AND sa.SessionId=@Sess
                WHERE td.InstituteId=@Inst AND td.SessionId=@Sess
                  AND (@Stream=0 OR td.StreamId=@Stream)
                GROUP BY td.UserId
            ) X;");
        cmd.Parameters.AddWithValue("@Inst", instituteId);
        cmd.Parameters.AddWithValue("@Sess", sessionId);
        cmd.Parameters.AddWithValue("@Stream", streamId);
        return dl.GetDataTable(cmd);
    }

    // ═══════════════════════════════════════════════════════════
    // RECENT ACTIVITY LOG
    // ═══════════════════════════════════════════════════════════
    public DataTable GetRecentActivity(int instituteId, int sessionId,
        int streamId)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT TOP 15
                up.FullName,
                ISNULL(up.ProfileImage,'')  AS ProfileImage,
                ual.ActivityType,
                ual.ActionTime,
                ISNULL(td.Designation,'Teacher') AS Designation
            FROM UserActivityLog ual
            INNER JOIN Users u ON u.UserId=ual.UserId
            INNER JOIN UserProfile up ON up.UserId=ual.UserId
            INNER JOIN TeacherDetails td ON td.UserId=ual.UserId
                AND td.InstituteId=@Inst AND td.SessionId=@Sess
            WHERE ual.InstituteId=@Inst AND ual.SessionId=@Sess
              AND (@Stream=0 OR td.StreamId=@Stream)
            ORDER BY ual.ActionTime DESC;");
        cmd.Parameters.AddWithValue("@Inst", instituteId);
        cmd.Parameters.AddWithValue("@Sess", sessionId);
        cmd.Parameters.AddWithValue("@Stream", streamId);
        return dl.GetDataTable(cmd);
    }

    // ═══════════════════════════════════════════════════════════
    // HELPER
    // ═══════════════════════════════════════════════════════════
    private void AddCommonParams(SqlCommand cmd, int instituteId, int sessionId,
        int streamId, int sectionId, string designation,
        string joinMonth, string joinYear)
    {
        cmd.Parameters.AddWithValue("@Inst", instituteId);
        cmd.Parameters.AddWithValue("@Sess", sessionId);
        cmd.Parameters.AddWithValue("@Stream", streamId);
        cmd.Parameters.AddWithValue("@Section", sectionId);
        cmd.Parameters.AddWithValue("@Desig", designation ?? "");
        cmd.Parameters.AddWithValue("@Month", joinMonth ?? "");
        cmd.Parameters.AddWithValue("@Year", joinYear ?? "");
    }
}