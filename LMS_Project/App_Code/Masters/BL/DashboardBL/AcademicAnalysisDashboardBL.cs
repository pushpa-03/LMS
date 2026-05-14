using System;
using System.Data;
using System.Data.SqlClient;

/// <summary>
/// BL for Academic Analysis Dashboard
/// All params with 0/"" = no filter applied
/// </summary>
public class AcademicAnalysisDashboardBL
{
    DataLayer dl = new DataLayer();

    // ═══════════════════════════════════════════════════════════
    // DROPDOWN LOADERS
    // ═══════════════════════════════════════════════════════════
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

    public DataTable GetSemesters(int inst, int sess)
    {
        var cmd = new SqlCommand(@"
            SELECT SemesterId, SemesterName FROM Semesters
            WHERE InstituteId=@I AND SessionId=@S ORDER BY SemesterName;");
        cmd.Parameters.AddWithValue("@I", inst);
        cmd.Parameters.AddWithValue("@S", sess);
        return dl.GetDataTable(cmd);
    }

    public DataTable GetSections(int inst, int sess)
    {
        var cmd = new SqlCommand(@"
            SELECT SectionId, SectionName FROM Sections
            WHERE InstituteId=@I AND SessionId=@S AND IsActive=1 ORDER BY SectionName;");
        cmd.Parameters.AddWithValue("@I", inst);
        cmd.Parameters.AddWithValue("@S", sess);
        return dl.GetDataTable(cmd);
    }

    public DataTable GetSubjects(int inst, int sess, int streamId, int courseId)
    {
        var cmd = new SqlCommand(@"
            SELECT DISTINCT 
                s.SubjectId, 
                LTRIM(RTRIM(s.SubjectName)) AS SubjectName
            FROM Subjects s
            LEFT JOIN LevelSemesterSubjects lss
                ON lss.SubjectId = s.SubjectId 
                AND lss.InstituteId = @I 
                AND lss.SessionId = @S
            WHERE s.InstituteId = @I 
              AND s.SessionId = @S 
              AND s.IsActive = 1
              AND (@Str = 0 OR lss.StreamId = @Str)
              AND (@Crs = 0 OR lss.CourseId = @Crs)
            ORDER BY LTRIM(RTRIM(s.SubjectName));");
        cmd.Parameters.AddWithValue("@I", inst);
        cmd.Parameters.AddWithValue("@S", sess);
        cmd.Parameters.AddWithValue("@Str", streamId);
        cmd.Parameters.AddWithValue("@Crs", courseId);
        return dl.GetDataTable(cmd);
    }

    // ═══════════════════════════════════════════════════════════
    // KPI SUMMARY
    // ═══════════════════════════════════════════════════════════
    public DataTable GetKPISummary(int inst, int sess,
        int streamId, int courseId, int semId, int sectionId, int subjectId,
        string gender, string dateFrom, string dateTo)
    {
        var cmd = new SqlCommand(@"
            SELECT
              -- Total students
              COUNT(DISTINCT sa.UserId)                           AS TotalStudents,

              -- Quiz metrics
              COUNT(DISTINCT qr.ResultId)                        AS TotalQuizAttempts,
              ISNULL(CAST(AVG(CAST(qr.Score  AS FLOAT)) AS DECIMAL(5,2)),0) AS AvgScore,
              ISNULL(CAST(MAX(qr.Score) AS DECIMAL(5,2)),0)      AS MaxScore,
              ISNULL(CAST(MIN(qr.Score) AS DECIMAL(5,2)),0)      AS MinScore,

              -- Pass rate (score >= passMarks)
              ISNULL(CAST(
                100.0*SUM(CASE WHEN qr.Score>=q.PassMarks THEN 1 ELSE 0 END)
                /NULLIF(COUNT(qr.ResultId),0)
              AS DECIMAL(5,2)),0)                                AS PassRate,

              -- Fail rate
              ISNULL(CAST(
                100.0*SUM(CASE WHEN qr.Score<q.PassMarks THEN 1 ELSE 0 END)
                /NULLIF(COUNT(qr.ResultId),0)
              AS DECIMAL(5,2)),0)                                AS FailRate,

              -- Assignments
              COUNT(DISTINCT a.AssignmentId)                     AS TotalAssignments,
              COUNT(DISTINCT asub.SubmissionId)                  AS TotalSubmissions,
              ISNULL(CAST(
                100.0*COUNT(DISTINCT asub.SubmissionId)
                /NULLIF(COUNT(DISTINCT a.AssignmentId)*COUNT(DISTINCT sa.UserId),0)
              AS DECIMAL(5,2)),0)                                AS SubmissionRate,

              -- Avg marks obtained in assignments
              ISNULL(CAST(AVG(CAST(asub.MarksObtained AS FLOAT)) AS DECIMAL(5,2)),0) AS AvgAssignMarks,

              -- Videos & views
              COUNT(DISTINCT v.VideoId)                          AS TotalVideos,
              COUNT(DISTINCT vv.ViewId)                          AS TotalVideoViews,

              -- Subjects
              COUNT(DISTINCT lss.SubjectId)                      AS TotalSubjects

            FROM StudentAcademicDetails sa
            INNER JOIN UserProfile up ON up.UserId=sa.UserId

            LEFT JOIN QuizResults qr
                ON qr.StudentId=sa.UserId AND qr.InstituteId=@I AND qr.SessionId=@S
               AND (CAST(@DFr AS DATE) IS NULL OR CAST(qr.AttemptedOn AS DATE)>=CAST(@DFr AS DATE))
               AND (CAST(@DTo AS DATE) IS NULL OR CAST(qr.AttemptedOn AS DATE)<=CAST(@DTo AS DATE))
            LEFT JOIN Quizzes q ON q.QuizId=qr.QuizId
                AND (@Sub=0 OR q.SubjectId=@Sub)

            LEFT JOIN Assignments a
                ON a.InstituteId=@I AND a.SessionId=@S AND a.IsActive=1
               AND (@Sub=0 OR a.SubjectId=@Sub)
            LEFT JOIN AssignmentSubmissions asub
                ON asub.AssignmentId=a.AssignmentId AND asub.StudentId=sa.UserId
               AND (CAST(@DFr AS DATE) IS NULL OR CAST(asub.SubmittedOn AS DATE)>=CAST(@DFr AS DATE))
               AND (CAST(@DTo AS DATE) IS NULL OR CAST(asub.SubmittedOn AS DATE)<=CAST(@DTo AS DATE))

            LEFT JOIN LevelSemesterSubjects lss
                ON lss.InstituteId=@I AND lss.SessionId=@S
               AND (@Str=0 OR lss.StreamId=@Str)
               AND (@Crs=0 OR lss.CourseId=@Crs)

            LEFT JOIN Videos v
                ON v.InstituteId=@I AND v.SessionId=@S AND v.IsActive=1
            LEFT JOIN VideoViews vv ON vv.VideoId=v.VideoId AND vv.SessionId=@S

            WHERE sa.InstituteId=@I AND sa.SessionId=@S
              AND (@Str=0 OR sa.StreamId  =@Str)
              AND (@Crs=0 OR sa.CourseId  =@Crs)
              AND (@Sem=0 OR sa.SemesterId=@Sem)
              AND (@Sec=0 OR sa.SectionId =@Sec)
              AND (@Gen='' OR up.Gender   =@Gen);");

        P(cmd, inst, sess, streamId, courseId, semId, sectionId, subjectId, gender, dateFrom, dateTo);
        return dl.GetDataTable(cmd);
    }

    // ═══════════════════════════════════════════════════════════
    // GRADE DISTRIBUTION
    // ═══════════════════════════════════════════════════════════
    public DataTable GetGradeDistribution(int inst, int sess,
        int streamId, int courseId, string dateFrom, string dateTo)
    {
        var cmd = new SqlCommand(@"
            SELECT
              CASE
                WHEN avgScore>=90 THEN 'A+ (90-100)'
                WHEN avgScore>=80 THEN 'A  (80-89)'
                WHEN avgScore>=70 THEN 'B+ (70-79)'
                WHEN avgScore>=60 THEN 'B  (60-69)'
                WHEN avgScore>=50 THEN 'C  (50-59)'
                WHEN avgScore>=33 THEN 'D  (33-49)'
                ELSE                   'F  (<33)'
              END AS GradeLabel,
              COUNT(*) AS Students,
              CAST(AVG(avgScore) AS DECIMAL(5,1)) AS AvgInBucket
            FROM (
              SELECT sa.UserId,
                ISNULL(CAST(AVG(CAST(qr.Score AS FLOAT)) AS DECIMAL(5,1)),0) AS avgScore
              FROM StudentAcademicDetails sa
              LEFT JOIN QuizResults qr
                ON qr.StudentId=sa.UserId AND qr.InstituteId=@I AND qr.SessionId=@S
               AND (CAST(@DFr AS DATE) IS NULL OR CAST(qr.AttemptedOn AS DATE)>=CAST(@DFr AS DATE))
               AND (CAST(@DTo AS DATE) IS NULL OR CAST(qr.AttemptedOn AS DATE)<=CAST(@DTo AS DATE))
              WHERE sa.InstituteId=@I AND sa.SessionId=@S
                AND (@Str=0 OR sa.StreamId=@Str)
                AND (@Crs=0 OR sa.CourseId=@Crs)
              GROUP BY sa.UserId
            ) X
            GROUP BY CASE
              WHEN avgScore>=90 THEN 'A+ (90-100)'
              WHEN avgScore>=80 THEN 'A  (80-89)'
              WHEN avgScore>=70 THEN 'B+ (70-79)'
              WHEN avgScore>=60 THEN 'B  (60-69)'
              WHEN avgScore>=50 THEN 'C  (50-59)'
              WHEN avgScore>=33 THEN 'D  (33-49)'
              ELSE 'F  (<33)' END
            ORDER BY MIN(avgScore) DESC;");
        cmd.Parameters.AddWithValue("@I", inst);
        cmd.Parameters.AddWithValue("@S", sess);
        cmd.Parameters.AddWithValue("@Str", streamId);
        cmd.Parameters.AddWithValue("@Crs", courseId);
        cmd.Parameters.AddWithValue("@DFr", Dt(dateFrom));
        cmd.Parameters.AddWithValue("@DTo", Dt(dateTo));
        return dl.GetDataTable(cmd);
    }

    // ═══════════════════════════════════════════════════════════
    // SUBJECT-WISE PERFORMANCE
    // ═══════════════════════════════════════════════════════════
    public DataTable GetSubjectWisePerformance(int inst, int sess,
        int streamId, int courseId, string dateFrom, string dateTo)
    {
        var cmd = new SqlCommand(@"
            SELECT TOP 10
              LTRIM(RTRIM(sub.SubjectName))                                    AS SubjectName,
              ISNULL(sub.SubjectCode,'')                                       AS SubjectCode,
              COUNT(DISTINCT qr.ResultId)                                      AS Attempts,
              ISNULL(CAST(AVG(CAST(qr.Score AS FLOAT)) AS DECIMAL(5,2)),0)    AS AvgScore,
              ISNULL(MAX(qr.Score),0)                                          AS MaxScore,
              ISNULL(MIN(qr.Score),0)                                          AS MinScore,
              ISNULL(CAST(
                100.0*SUM(CASE WHEN qr.Score>=q2.PassMarks THEN 1 ELSE 0 END)
                /NULLIF(COUNT(qr.ResultId),0)
              AS DECIMAL(5,2)),0)                                              AS PassRate,
              COUNT(DISTINCT a.AssignmentId)                                   AS Assignments,
              COUNT(DISTINCT asub.SubmissionId)                                AS Submissions,
              (SELECT COUNT(*) FROM Chapters ch WHERE ch.SubjectId=sub.SubjectId AND ch.InstituteId=@I) AS Chapters,
              (SELECT COUNT(*) FROM Videos  v  JOIN Chapters ch2 ON v.ChapterId=ch2.ChapterId
               WHERE ch2.SubjectId=sub.SubjectId AND v.InstituteId=@I AND v.SessionId=@S) AS Videos
            FROM Subjects sub
            INNER JOIN LevelSemesterSubjects lss
                ON lss.SubjectId=sub.SubjectId AND lss.InstituteId=@I AND lss.SessionId=@S
                AND (@Str=0 OR lss.StreamId=@Str)
                AND (@Crs=0 OR lss.CourseId=@Crs)
            LEFT JOIN Quizzes q2
                ON q2.SubjectId=sub.SubjectId AND q2.InstituteId=@I AND q2.SessionId=@S
            LEFT JOIN QuizResults qr
                ON qr.QuizId=q2.QuizId AND qr.InstituteId=@I AND qr.SessionId=@S
               AND (CAST(@DFr AS DATE) IS NULL OR CAST(qr.AttemptedOn AS DATE)>=CAST(@DFr AS DATE))
               AND (CAST(@DTo AS DATE) IS NULL OR CAST(qr.AttemptedOn AS DATE)<=CAST(@DTo AS DATE))
            LEFT JOIN Assignments a
                ON a.SubjectId=sub.SubjectId AND a.InstituteId=@I AND a.SessionId=@S AND a.IsActive=1
            LEFT JOIN AssignmentSubmissions asub
                ON asub.AssignmentId=a.AssignmentId
               AND (CAST(@DFr AS DATE) IS NULL OR CAST(asub.SubmittedOn AS DATE)>=CAST(@DFr AS DATE))
            WHERE sub.InstituteId=@I AND sub.SessionId=@S AND sub.IsActive=1
            GROUP BY sub.SubjectId, sub.SubjectName, sub.SubjectCode
            ORDER BY AvgScore DESC;");
        cmd.Parameters.AddWithValue("@I", inst);
        cmd.Parameters.AddWithValue("@S", sess);
        cmd.Parameters.AddWithValue("@Str", streamId);
        cmd.Parameters.AddWithValue("@Crs", courseId);
        cmd.Parameters.AddWithValue("@DFr", Dt(dateFrom));
        cmd.Parameters.AddWithValue("@DTo", Dt(dateTo));
        return dl.GetDataTable(cmd);
    }

    // ═══════════════════════════════════════════════════════════
    // QUIZ PERFORMANCE TREND (monthly)
    // ═══════════════════════════════════════════════════════════
    public DataTable GetQuizTrend(int inst, int sess,
        int streamId, int courseId, string dateFrom, string dateTo)
    {
        var cmd = new SqlCommand(@"
            WITH Months AS (
              SELECT TOP 12
                MONTH(DATEADD(MONTH,-n,GETDATE())) M,
                YEAR(DATEADD(MONTH,-n,GETDATE()))  Y,
                LEFT(DATENAME(MONTH,DATEADD(MONTH,-n,GETDATE())),3)
                  +' '+RIGHT(CAST(YEAR(DATEADD(MONTH,-n,GETDATE())) AS VARCHAR),2) AS ML
              FROM (VALUES(0),(1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11)) T(n)
            )
            SELECT m.ML AS MonLabel, m.M, m.Y,
              ISNULL(CAST(AVG(CAST(qr.Score AS FLOAT)) AS DECIMAL(5,2)),0) AS AvgScore,
              ISNULL(CAST(
                100.0*SUM(CASE WHEN qr.Score>=q.PassMarks THEN 1 ELSE 0 END)
                /NULLIF(COUNT(qr.ResultId),0)
              AS DECIMAL(5,2)),0) AS PassRate,
              COUNT(DISTINCT qr.ResultId) AS Attempts
            FROM Months m
            LEFT JOIN QuizResults qr
              ON MONTH(qr.AttemptedOn)=m.M AND YEAR(qr.AttemptedOn)=m.Y
             AND qr.InstituteId=@I AND qr.SessionId=@S
            LEFT JOIN Quizzes q ON q.QuizId=qr.QuizId
            LEFT JOIN StudentAcademicDetails sa ON sa.UserId=qr.StudentId
              AND (@Str=0 OR sa.StreamId=@Str)
              AND (@Crs=0 OR sa.CourseId=@Crs)
            GROUP BY m.ML,m.M,m.Y
            ORDER BY m.Y,m.M;");
        cmd.Parameters.AddWithValue("@I", inst);
        cmd.Parameters.AddWithValue("@S", sess);
        cmd.Parameters.AddWithValue("@Str", streamId);
        cmd.Parameters.AddWithValue("@Crs", courseId);
        return dl.GetDataTable(cmd);
    }

    // ═══════════════════════════════════════════════════════════
    // ASSIGNMENT TREND
    // ═══════════════════════════════════════════════════════════
    public DataTable GetAssignmentTrend(int inst, int sess,
        int streamId, int courseId, string dateFrom, string dateTo)
    {
        var cmd = new SqlCommand(@"
            WITH Months AS (
              SELECT TOP 12
                MONTH(DATEADD(MONTH,-n,GETDATE())) M,
                YEAR(DATEADD(MONTH,-n,GETDATE()))  Y,
                LEFT(DATENAME(MONTH,DATEADD(MONTH,-n,GETDATE())),3)
                  +' '+RIGHT(CAST(YEAR(DATEADD(MONTH,-n,GETDATE())) AS VARCHAR),2) AS ML
              FROM (VALUES(0),(1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11)) T(n)
            )
            SELECT m.ML AS MonLabel, m.M, m.Y,
              COUNT(DISTINCT a.AssignmentId) AS Assigned,
              COUNT(DISTINCT asub.SubmissionId) AS Submitted,
              ISNULL(CAST(AVG(CAST(asub.MarksObtained AS FLOAT)) AS DECIMAL(5,2)),0) AS AvgMarks
            FROM Months m
            LEFT JOIN Assignments a
              ON MONTH(a.CreatedOn)=m.M AND YEAR(a.CreatedOn)=m.Y
             AND a.InstituteId=@I AND a.SessionId=@S AND a.IsActive=1
            LEFT JOIN AssignmentSubmissions asub
              ON asub.AssignmentId=a.AssignmentId
             AND MONTH(asub.SubmittedOn)=m.M AND YEAR(asub.SubmittedOn)=m.Y
            LEFT JOIN StudentAcademicDetails sa ON sa.UserId=asub.StudentId
              AND (@Str=0 OR sa.StreamId=@Str)
              AND (@Crs=0 OR sa.CourseId=@Crs)
            GROUP BY m.ML,m.M,m.Y ORDER BY m.Y,m.M;");
        cmd.Parameters.AddWithValue("@I", inst);
        cmd.Parameters.AddWithValue("@S", sess);
        cmd.Parameters.AddWithValue("@Str", streamId);
        cmd.Parameters.AddWithValue("@Crs", courseId);
        return dl.GetDataTable(cmd);
    }

    // ═══════════════════════════════════════════════════════════
    // TOP STUDENTS
    // ═══════════════════════════════════════════════════════════
    public DataTable GetTopStudents(int inst, int sess,
        int streamId, int courseId, string dateFrom, string dateTo)
    {
        var cmd = new SqlCommand(@"
            SELECT TOP 10
              up.FullName, ISNULL(sa.RollNumber,'—') AS RollNumber,
              ISNULL(c.CourseName,'—') AS CourseName,
              ISNULL(sem.SemesterName,'—') AS SemesterName,
              ISNULL(up.ProfileImage,'') AS ProfileImage,
              ISNULL(CAST(AVG(CAST(qr.Score AS FLOAT)) AS DECIMAL(5,1)),0) AS AvgScore,
              ISNULL(MAX(qr.Score),0) AS MaxScore,
              COUNT(DISTINCT qr.ResultId) AS QuizAttempts,
              COUNT(DISTINCT asub.SubmissionId) AS Submissions,
              ISNULL(CAST(AVG(CAST(asub.MarksObtained AS FLOAT)) AS DECIMAL(5,1)),0) AS AvgAssignMarks,
              CASE
                WHEN ISNULL(AVG(CAST(qr.Score AS FLOAT)),0)>=80 THEN 'A'
                WHEN ISNULL(AVG(CAST(qr.Score AS FLOAT)),0)>=60 THEN 'B'
                WHEN ISNULL(AVG(CAST(qr.Score AS FLOAT)),0)>=40 THEN 'C'
                ELSE 'D'
              END AS Grade
            FROM StudentAcademicDetails sa
            INNER JOIN UserProfile up ON up.UserId=sa.UserId
            LEFT JOIN Courses   c   ON c.CourseId   =sa.CourseId
            LEFT JOIN Semesters sem ON sem.SemesterId=sa.SemesterId
            LEFT JOIN QuizResults qr
              ON qr.StudentId=sa.UserId AND qr.InstituteId=@I AND qr.SessionId=@S
             AND (CAST(@DFr AS DATE) IS NULL OR CAST(qr.AttemptedOn AS DATE)>=CAST(@DFr AS DATE))
             AND (CAST(@DTo AS DATE) IS NULL OR CAST(qr.AttemptedOn AS DATE)<=CAST(@DTo AS DATE))
            LEFT JOIN AssignmentSubmissions asub
              ON asub.StudentId=sa.UserId AND asub.InstituteId=@I AND asub.SessionId=@S
            WHERE sa.InstituteId=@I AND sa.SessionId=@S
              AND (@Str=0 OR sa.StreamId=@Str)
              AND (@Crs=0 OR sa.CourseId=@Crs)
            GROUP BY sa.UserId,up.FullName,sa.RollNumber,c.CourseName,sem.SemesterName,up.ProfileImage
            ORDER BY AvgScore DESC, Submissions DESC;");
        cmd.Parameters.AddWithValue("@I", inst);
        cmd.Parameters.AddWithValue("@S", sess);
        cmd.Parameters.AddWithValue("@Str", streamId);
        cmd.Parameters.AddWithValue("@Crs", courseId);
        cmd.Parameters.AddWithValue("@DFr", Dt(dateFrom));
        cmd.Parameters.AddWithValue("@DTo", Dt(dateTo));
        return dl.GetDataTable(cmd);
    }

    // ═══════════════════════════════════════════════════════════
    // STRUGGLING STUDENTS (low score + low submission)
    // ═══════════════════════════════════════════════════════════
    public DataTable GetStrugglingStudents(int inst, int sess,
        int streamId, int courseId, string dateFrom, string dateTo)
    {
        var cmd = new SqlCommand(@"
            SELECT TOP 10
              up.FullName, ISNULL(sa.RollNumber,'—') AS RollNumber,
              ISNULL(c.CourseName,'—') AS CourseName,
              ISNULL(up.ProfileImage,'') AS ProfileImage,
              ISNULL(CAST(AVG(CAST(qr.Score AS FLOAT)) AS DECIMAL(5,1)),0) AS AvgScore,
              COUNT(DISTINCT qr.ResultId) AS QuizAttempts,
              COUNT(DISTINCT asub.SubmissionId) AS Submissions,
              CASE
                WHEN ISNULL(AVG(CAST(qr.Score AS FLOAT)),0)<33 THEN 'Failing'
                WHEN ISNULL(AVG(CAST(qr.Score AS FLOAT)),0)<50 THEN 'At Risk'
                ELSE 'Below Average'
              END AS RiskLevel
            FROM StudentAcademicDetails sa
            INNER JOIN UserProfile up ON up.UserId=sa.UserId
            LEFT JOIN Courses c ON c.CourseId=sa.CourseId
            LEFT JOIN QuizResults qr
              ON qr.StudentId=sa.UserId AND qr.InstituteId=@I AND qr.SessionId=@S
             AND (CAST(@DFr AS DATE) IS NULL OR CAST(qr.AttemptedOn AS DATE)>=CAST(@DFr AS DATE))
             AND (CAST(@DTo AS DATE) IS NULL OR CAST(qr.AttemptedOn AS DATE)<=CAST(@DTo AS DATE))
            LEFT JOIN AssignmentSubmissions asub
              ON asub.StudentId=sa.UserId AND asub.InstituteId=@I AND asub.SessionId=@S
            WHERE sa.InstituteId=@I AND sa.SessionId=@S
              AND (@Str=0 OR sa.StreamId=@Str)
              AND (@Crs=0 OR sa.CourseId=@Crs)
            GROUP BY sa.UserId,up.FullName,sa.RollNumber,c.CourseName,up.ProfileImage
            HAVING ISNULL(AVG(CAST(qr.Score AS FLOAT)),0)<60
            ORDER BY AvgScore ASC;");
        cmd.Parameters.AddWithValue("@I", inst);
        cmd.Parameters.AddWithValue("@S", sess);
        cmd.Parameters.AddWithValue("@Str", streamId);
        cmd.Parameters.AddWithValue("@Crs", courseId);
        cmd.Parameters.AddWithValue("@DFr", Dt(dateFrom));
        cmd.Parameters.AddWithValue("@DTo", Dt(dateTo));
        return dl.GetDataTable(cmd);
    }

    // ═══════════════════════════════════════════════════════════
    // STREAM-WISE PERFORMANCE
    // ═══════════════════════════════════════════════════════════
    public DataTable GetStreamWisePerformance(int inst, int sess,
        string dateFrom, string dateTo)
    {
        var cmd = new SqlCommand(@"
            SELECT ISNULL(st.StreamName,'Unassigned') AS StreamName,
              COUNT(DISTINCT sa.UserId) AS Students,
              ISNULL(CAST(AVG(CAST(qr.Score AS FLOAT)) AS DECIMAL(5,2)),0) AS AvgScore,
              ISNULL(CAST(
                100.0*SUM(CASE WHEN qr.Score>=q.PassMarks THEN 1 ELSE 0 END)
                /NULLIF(COUNT(qr.ResultId),0)
              AS DECIMAL(5,2)),0) AS PassRate
            FROM StudentAcademicDetails sa
            LEFT JOIN Streams st ON st.StreamId=sa.StreamId
            LEFT JOIN QuizResults qr
              ON qr.StudentId=sa.UserId AND qr.InstituteId=@I AND qr.SessionId=@S
             AND (CAST(@DFr AS DATE) IS NULL OR CAST(qr.AttemptedOn AS DATE)>=CAST(@DFr AS DATE))
             AND (CAST(@DTo AS DATE) IS NULL OR CAST(qr.AttemptedOn AS DATE)<=CAST(@DTo AS DATE))
            LEFT JOIN Quizzes q ON q.QuizId=qr.QuizId
            WHERE sa.InstituteId=@I AND sa.SessionId=@S
            GROUP BY st.StreamName ORDER BY AvgScore DESC;");
        cmd.Parameters.AddWithValue("@I", inst);
        cmd.Parameters.AddWithValue("@S", sess);
        cmd.Parameters.AddWithValue("@DFr", Dt(dateFrom));
        cmd.Parameters.AddWithValue("@DTo", Dt(dateTo));
        return dl.GetDataTable(cmd);
    }

    // ═══════════════════════════════════════════════════════════
    // VIDEO ENGAGEMENT
    // ═══════════════════════════════════════════════════════════
    public DataTable GetVideoEngagement(int inst, int sess,
        int streamId, string dateFrom, string dateTo)
    {
        var cmd = new SqlCommand(@"
            SELECT TOP 8
              LTRIM(RTRIM(v.Title)) AS VideoTitle,
              v.Duration,
              COUNT(DISTINCT vv.ViewId) AS Views,
              SUM(CASE WHEN vv.IsCompleted=1 THEN 1 ELSE 0 END) AS Completed,
              CAST(100.0*SUM(CASE WHEN vv.IsCompleted=1 THEN 1 ELSE 0 END)
                   /NULLIF(COUNT(DISTINCT vv.ViewId),0) AS DECIMAL(5,1)) AS CompletionRate,
              ISNULL(up2.FullName,'—') AS InstructorName
            FROM Videos v
            LEFT JOIN VideoViews vv ON vv.VideoId=v.VideoId
              AND (CAST(@DFr AS DATE) IS NULL OR CAST(vv.ViewedOn AS DATE)>=CAST(@DFr AS DATE))
              AND (CAST(@DTo AS DATE) IS NULL OR CAST(vv.ViewedOn AS DATE)<=CAST(@DTo AS DATE))
            LEFT JOIN UserProfile up2 ON up2.UserId=v.InstructorId
            WHERE v.InstituteId=@I AND v.SessionId=@S AND v.IsActive=1
            GROUP BY v.VideoId,v.Title,v.Duration,up2.FullName
            ORDER BY Views DESC;");
        cmd.Parameters.AddWithValue("@I", inst);
        cmd.Parameters.AddWithValue("@S", sess);
        cmd.Parameters.AddWithValue("@DFr", Dt(dateFrom));
        cmd.Parameters.AddWithValue("@DTo", Dt(dateTo));
        return dl.GetDataTable(cmd);
    }

    // ═══════════════════════════════════════════════════════════
    // QUIZ LIST WITH STATS (for quiz analysis tab)
    // ═══════════════════════════════════════════════════════════
    public DataTable GetQuizList(int inst, int sess,
        int streamId, int courseId, int subjectId, string dateFrom, string dateTo)
    {
        var cmd = new SqlCommand(@"
            SELECT TOP 10
              q.QuizId, LTRIM(RTRIM(q.Title)) AS Title,
              ISNULL(sub.SubjectName,'—') AS SubjectName,
              q.TotalMarks, q.PassMarks, q.Duration,
              COUNT(DISTINCT qr.StudentId) AS Attempts,
              ISNULL(CAST(AVG(CAST(qr.Score AS FLOAT)) AS DECIMAL(5,2)),0) AS AvgScore,
              ISNULL(MAX(qr.Score),0) AS HighScore,
              ISNULL(MIN(qr.Score),0) AS LowScore,
              ISNULL(CAST(
                100.0*SUM(CASE WHEN qr.Score>=q.PassMarks THEN 1 ELSE 0 END)
                /NULLIF(COUNT(qr.ResultId),0)
              AS DECIMAL(5,2)),0) AS PassRate
            FROM Quizzes q
            LEFT JOIN Subjects sub ON sub.SubjectId=q.SubjectId
            LEFT JOIN LevelSemesterSubjects lss
              ON lss.SubjectId=sub.SubjectId AND lss.InstituteId=@I AND lss.SessionId=@S
              AND (@Str=0 OR lss.StreamId=@Str)
              AND (@Crs=0 OR lss.CourseId=@Crs)
            LEFT JOIN QuizResults qr
              ON qr.QuizId=q.QuizId AND qr.InstituteId=@I AND qr.SessionId=@S
             AND (CAST(@DFr AS DATE) IS NULL OR CAST(qr.AttemptedOn AS DATE)>=CAST(@DFr AS DATE))
             AND (CAST(@DTo AS DATE) IS NULL OR CAST(qr.AttemptedOn AS DATE)<=CAST(@DTo AS DATE))
            WHERE q.InstituteId=@I AND q.SessionId=@S AND q.IsEnabled=1
              AND (@Sub=0 OR q.SubjectId=@Sub)
            GROUP BY q.QuizId,q.Title,sub.SubjectName,q.TotalMarks,q.PassMarks,q.Duration
            ORDER BY Attempts DESC, AvgScore DESC;");
        cmd.Parameters.AddWithValue("@I", inst);
        cmd.Parameters.AddWithValue("@S", sess);
        cmd.Parameters.AddWithValue("@Str", streamId);
        cmd.Parameters.AddWithValue("@Crs", courseId);
        cmd.Parameters.AddWithValue("@Sub", subjectId);
        cmd.Parameters.AddWithValue("@DFr", Dt(dateFrom));
        cmd.Parameters.AddWithValue("@DTo", Dt(dateTo));
        return dl.GetDataTable(cmd);
    }

    // ═══════════════════════════════════════════════════════════
    // GENDER-WISE ACADEMIC PERFORMANCE
    // ═══════════════════════════════════════════════════════════
    public DataTable GetGenderWisePerformance(int inst, int sess,
        int streamId, string dateFrom, string dateTo)
    {
        var cmd = new SqlCommand(@"
            SELECT ISNULL(up.Gender,'Unknown') AS Gender,
              COUNT(DISTINCT sa.UserId) AS Students,
              ISNULL(CAST(AVG(CAST(qr.Score AS FLOAT)) AS DECIMAL(5,2)),0) AS AvgScore,
              ISNULL(CAST(
                100.0*SUM(CASE WHEN qr.Score>=q.PassMarks THEN 1 ELSE 0 END)
                /NULLIF(COUNT(qr.ResultId),0)
              AS DECIMAL(5,2)),0) AS PassRate,
              COUNT(DISTINCT asub.SubmissionId) AS Submissions
            FROM StudentAcademicDetails sa
            INNER JOIN UserProfile up ON up.UserId=sa.UserId
            LEFT JOIN QuizResults qr
              ON qr.StudentId=sa.UserId AND qr.InstituteId=@I AND qr.SessionId=@S
             AND (CAST(@DFr AS DATE) IS NULL OR CAST(qr.AttemptedOn AS DATE)>=CAST(@DFr AS DATE))
             AND (CAST(@DTo AS DATE) IS NULL OR CAST(qr.AttemptedOn AS DATE)<=CAST(@DTo AS DATE))
            LEFT JOIN Quizzes q ON q.QuizId=qr.QuizId
            LEFT JOIN AssignmentSubmissions asub
              ON asub.StudentId=sa.UserId AND asub.InstituteId=@I AND asub.SessionId=@S
            WHERE sa.InstituteId=@I AND sa.SessionId=@S
              AND (@Str=0 OR sa.StreamId=@Str)
            GROUP BY up.Gender ORDER BY AvgScore DESC;");
        cmd.Parameters.AddWithValue("@I", inst);
        cmd.Parameters.AddWithValue("@S", sess);
        cmd.Parameters.AddWithValue("@Str", streamId);
        cmd.Parameters.AddWithValue("@DFr", Dt(dateFrom));
        cmd.Parameters.AddWithValue("@DTo", Dt(dateTo));
        return dl.GetDataTable(cmd);
    }

    // ═══════════════════════════════════════════════════════════
    // ADMIN SUGGESTIONS ENGINE
    // ═══════════════════════════════════════════════════════════
    public DataTable GetAdminSuggestions(int inst, int sess)
    {
        var cmd = new SqlCommand(@"
            SELECT
              -- Students with <75% attendance
              (SELECT COUNT(*) FROM (
                SELECT a.UserId,
                  CAST(100.0*SUM(CASE WHEN a.Status='Present' THEN 1 ELSE 0 END)
                       /NULLIF(COUNT(*),0) AS DECIMAL(5,1)) AS Pct
                FROM Attendance a WHERE a.InstituteId=@I AND a.SessionId=@S
                GROUP BY a.UserId HAVING
                  CAST(100.0*SUM(CASE WHEN a.Status='Present' THEN 1 ELSE 0 END)
                       /NULLIF(COUNT(*),0) AS DECIMAL(5,1)) < 75
              ) X) AS LowAttendanceCount,

              -- Quizzes with <50% pass rate
              (SELECT COUNT(*) FROM Quizzes q2
               LEFT JOIN QuizResults qr2 ON qr2.QuizId=q2.QuizId AND qr2.InstituteId=@I
               WHERE q2.InstituteId=@I AND q2.SessionId=@S AND q2.IsEnabled=1
               GROUP BY q2.QuizId
               HAVING CAST(100.0*SUM(CASE WHEN qr2.Score>=q2.PassMarks THEN 1 ELSE 0 END)
                           /NULLIF(COUNT(qr2.ResultId),0) AS DECIMAL(5,2)) < 50
              ) AS LowPassQuizzes,

              -- Assignments with <40% submission
              (SELECT COUNT(DISTINCT a2.AssignmentId) FROM Assignments a2
               WHERE a2.InstituteId=@I AND a2.SessionId=@S AND a2.IsActive=1
               AND a2.DueDate < GETDATE()
               AND (SELECT COUNT(*) FROM AssignmentSubmissions asub2
                    WHERE asub2.AssignmentId=a2.AssignmentId) <
                   (SELECT COUNT(*) FROM StudentAcademicDetails sa2
                    WHERE sa2.InstituteId=@I AND sa2.SessionId=@S)*0.4
              ) AS LowSubmissionAssignments,

              -- Avg overall score
              ISNULL(CAST(AVG(CAST(qr3.Score AS FLOAT)) AS DECIMAL(5,2)),0) AS OverallAvgScore,

              -- Videos with 0 views
              (SELECT COUNT(*) FROM Videos v WHERE v.InstituteId=@I AND v.SessionId=@S
               AND v.IsActive=1 AND v.ViewCount=0) AS UnwatchedVideos,

              -- Total active quizzes
              (SELECT COUNT(*) FROM Quizzes q WHERE q.InstituteId=@I AND q.SessionId=@S
               AND q.IsEnabled=1) AS ActiveQuizzes,

              -- Students with 0 quiz attempts
              (SELECT COUNT(DISTINCT sa.UserId) FROM StudentAcademicDetails sa
               WHERE sa.InstituteId=@I AND sa.SessionId=@S
               AND NOT EXISTS(SELECT 1 FROM QuizResults qrx
                WHERE qrx.StudentId=sa.UserId AND qrx.InstituteId=@I AND qrx.SessionId=@S)
              ) AS StudentsNoQuiz

            FROM QuizResults qr3
            WHERE qr3.InstituteId=@I AND qr3.SessionId=@S;");
        cmd.Parameters.AddWithValue("@I", inst);
        cmd.Parameters.AddWithValue("@S", sess);
        return dl.GetDataTable(cmd);
    }

    // ═══════════════════════════════════════════════════════════
    // HELPERS
    // ═══════════════════════════════════════════════════════════
    private void P(SqlCommand cmd, int inst, int sess,
        int str, int crs, int sem, int sec, int sub,
        string gen, string dFr, string dTo)
    {
        cmd.Parameters.AddWithValue("@I", inst);
        cmd.Parameters.AddWithValue("@S", sess);
        cmd.Parameters.AddWithValue("@Str", str);
        cmd.Parameters.AddWithValue("@Crs", crs);
        cmd.Parameters.AddWithValue("@Sem", sem);
        cmd.Parameters.AddWithValue("@Sec", sec);
        cmd.Parameters.AddWithValue("@Sub", sub);
        cmd.Parameters.AddWithValue("@Gen", gen ?? "");
        cmd.Parameters.AddWithValue("@DFr", Dt(dFr));
        cmd.Parameters.AddWithValue("@DTo", Dt(dTo));
    }

    private object Dt(string s) =>
        string.IsNullOrWhiteSpace(s) ? (object)DBNull.Value : (object)s;
}