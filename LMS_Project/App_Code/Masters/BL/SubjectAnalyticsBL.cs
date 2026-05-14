using System;
using System.Data;
using System.Data.SqlClient;

public class SubjectAnalyticsBL
{
    DataLayer dl = new DataLayer();

    // ── Subject basic info ───────────────────────────────────────
    public DataTable GetSubjectInfo(int subjectId, int sessionId)
    {
        var cmd = new SqlCommand(@"
            SELECT S.SubjectName, S.SubjectCode, S.IsActive
            FROM   Subjects S
            WHERE  S.SubjectId = @SubjectId");
        cmd.Parameters.AddWithValue("@SubjectId", subjectId);
        return dl.GetDataTable(cmd);
    }

    // ── Aggregated KPIs ──────────────────────────────────────────
    public DataTable GetSubjectKPIs(int subjectId, int sessionId)
    {
        var cmd = new SqlCommand(@"
            SELECT
                -- Enrolled students
                (SELECT COUNT(*) FROM AssignStudentSubject
                 WHERE SubjectId=@SubjectId AND SessionId=@SessionId) AS TotalStudents,

                -- Chapters
                (SELECT COUNT(*) FROM Chapters
                 WHERE SubjectId=@SubjectId AND SessionId=@SessionId) AS TotalChapters,

                -- Videos
                (SELECT COUNT(*) FROM Videos V
                 INNER JOIN Chapters C ON V.ChapterId=C.ChapterId
                 WHERE C.SubjectId=@SubjectId AND V.SessionId=@SessionId) AS TotalVideos,

                -- Materials
                (SELECT COUNT(*) FROM Materials M
                 INNER JOIN Chapters C ON M.ChapterId=C.ChapterId
                 WHERE C.SubjectId=@SubjectId AND M.SessionId=@SessionId) AS TotalMaterials,

                -- Assignments
                (SELECT COUNT(*) FROM Assignments
                 WHERE SubjectId=@SubjectId AND SessionId=@SessionId AND IsActive=1) AS TotalAssignments,

                -- Submissions
                (SELECT COUNT(*) FROM AssignmentSubmissions ASub
                 INNER JOIN Assignments A ON ASub.AssignmentId=A.AssignmentId
                 WHERE A.SubjectId=@SubjectId AND A.SessionId=@SessionId) AS TotalSubmissions,

                -- Avg Marks (graded submissions only)
                ISNULL((SELECT ROUND(AVG(CAST(ASub.MarksObtained AS FLOAT)),1)
                        FROM AssignmentSubmissions ASub
                        INNER JOIN Assignments A ON ASub.AssignmentId=A.AssignmentId
                        WHERE A.SubjectId=@SubjectId AND A.SessionId=@SessionId
                          AND ASub.MarksObtained IS NOT NULL), 0) AS AvgMarks,

                -- Avg Attendance %
                ISNULL((SELECT ROUND(
                    100.0 * SUM(CASE WHEN Status='Present' THEN 1 ELSE 0 END)
                          / NULLIF(COUNT(*),0), 1)
                 FROM Attendance
                 WHERE SubjectId=@SubjectId AND SessionId=@SessionId), 0) AS AvgAttendancePct
        ");
        cmd.Parameters.AddWithValue("@SubjectId", subjectId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);
        return dl.GetDataTable(cmd);
    }

    // ── Attendance by date (last 30 days) ────────────────────────
    public DataTable GetAttendanceByDate(int subjectId, int sessionId)
    {
        var cmd = new SqlCommand(@"
            SELECT
                CAST(Date AS DATE) AS AttDate,
                SUM(CASE WHEN Status='Present' THEN 1 ELSE 0 END) AS PresentCount,
                SUM(CASE WHEN Status='Absent'  THEN 1 ELSE 0 END) AS AbsentCount,
                SUM(CASE WHEN Status='Leave'   THEN 1 ELSE 0 END) AS LeaveCount
            FROM Attendance
            WHERE SubjectId = @SubjectId
              AND SessionId = @SessionId
              AND Date >= DATEADD(DAY,-30,GETDATE())
            GROUP BY CAST(Date AS DATE)
            ORDER BY AttDate");
        cmd.Parameters.AddWithValue("@SubjectId", subjectId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);
        return dl.GetDataTable(cmd);
    }

    // ── Video views per chapter ───────────────────────────────────
    public DataTable GetVideoViewsPerChapter(int subjectId, int sessionId)
    {
        var cmd = new SqlCommand(@"
        SELECT
            C.ChapterName,
            V.Title AS VideoTitle,
            COUNT(VV.ViewId)                          AS TotalViews,
            COUNT(DISTINCT VV.UserId)                 AS UniqueViewers
        FROM Chapters C
        INNER JOIN Videos V  ON V.ChapterId  = C.ChapterId
                             AND V.SessionId  = @SessionId
        LEFT JOIN  VideoViews VV ON VV.VideoId   = V.VideoId
                                AND VV.SessionId  = @SessionId
                                AND VV.UserId IN (
                                    SELECT UserId FROM Users
                                    WHERE  RoleId = 4          -- Students only
                                      AND  SessionId = @SessionId
                                )
        WHERE C.SubjectId  = @SubjectId
          AND C.SessionId  = @SessionId
        GROUP BY C.ChapterId, C.ChapterName, C.OrderNo,
                 V.VideoId,  V.Title,        V.UploadedOn
        ORDER BY C.OrderNo, V.UploadedOn");

        cmd.Parameters.AddWithValue("@SubjectId", subjectId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);
        return dl.GetDataTable(cmd);
    }
    // ── Assignment submission count per assignment ────────────────
    public DataTable GetAssignmentStats(int subjectId, int sessionId)
    {
        var cmd = new SqlCommand(@"
            SELECT
                A.Title,
                A.MaxMarks,
                A.DueDate,
                COUNT(ASub.SubmissionId) AS SubmissionCount,
                ISNULL(ROUND(AVG(CAST(ASub.MarksObtained AS FLOAT)),1),0) AS AvgScore
            FROM Assignments A
            LEFT JOIN AssignmentSubmissions ASub ON ASub.AssignmentId=A.AssignmentId
            WHERE A.SubjectId=@SubjectId AND A.SessionId=@SessionId AND A.IsActive=1
            GROUP BY A.AssignmentId, A.Title, A.MaxMarks, A.DueDate, A.CreatedOn
            ORDER BY A.CreatedOn DESC");
        cmd.Parameters.AddWithValue("@SubjectId", subjectId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);
        return dl.GetDataTable(cmd);
    }

    // ── Assignment detail stats (for table + chart) ───────────────
    public DataTable GetAssignmentDetailStats(int subjectId, int sessionId)
    {
        var cmd = new SqlCommand(@"
            SELECT
                A.Title,
                A.DueDate,
                A.MaxMarks,
                COUNT(ASub.SubmissionId) AS SubmissionCount,
                ISNULL(ROUND(AVG(CAST(ASub.MarksObtained AS FLOAT)),1),0) AS AvgScore,
                -- submission rate % vs enrolled students
                ISNULL(ROUND(
                    100.0 * COUNT(ASub.SubmissionId)
                          / NULLIF((SELECT COUNT(*) FROM AssignStudentSubject
                                    WHERE SubjectId=A.SubjectId AND SessionId=A.SessionId),0)
                ,1),0) AS SubmissionRate
            FROM Assignments A
            LEFT JOIN AssignmentSubmissions ASub ON ASub.AssignmentId=A.AssignmentId
            WHERE A.SubjectId=@SubjectId AND A.SessionId=@SessionId AND A.IsActive=1
            GROUP BY A.AssignmentId, A.Title, A.DueDate, A.MaxMarks, A.SubjectId, A.SessionId, A.CreatedOn
            ORDER BY A.CreatedOn DESC");
        cmd.Parameters.AddWithValue("@SubjectId", subjectId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);
        return dl.GetDataTable(cmd);
    }

    // ── Quiz avg scores ───────────────────────────────────────────
    public DataTable GetQuizAvgScores(int subjectId, int sessionId)
    {
        var cmd = new SqlCommand(@"
            SELECT
                Q.Title,
                ISNULL(ROUND(AVG(
                    100.0 * QR.Score / NULLIF(QR.TotalMarks,0)
                ),1),0) AS AvgPct
            FROM Quizzes Q
            LEFT JOIN QuizResults QR ON QR.QuizId=Q.QuizId AND QR.SessionId=@SessionId
            WHERE Q.SubjectId=@SubjectId AND Q.SessionId=@SessionId AND Q.IsEnabled=1
            GROUP BY Q.QuizId, Q.Title, Q.CreatedOn
            ORDER BY Q.CreatedOn");
        cmd.Parameters.AddWithValue("@SubjectId", subjectId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);
        return dl.GetDataTable(cmd);
    }

    // ── Chapter content summary ───────────────────────────────────
    public DataTable GetChapterContentSummary(int subjectId, int sessionId)
    {
        var cmd = new SqlCommand(@"
            SELECT
                C.ChapterName,
                (SELECT COUNT(*) FROM Videos V
                 WHERE V.ChapterId=C.ChapterId AND V.SessionId=@SessionId) AS VideoCount,
                (SELECT COUNT(*) FROM Materials M
                 WHERE M.ChapterId=C.ChapterId AND M.SessionId=@SessionId) AS MaterialCount
            FROM Chapters C
            WHERE C.SubjectId=@SubjectId AND C.SessionId=@SessionId
            ORDER BY C.OrderNo");
        cmd.Parameters.AddWithValue("@SubjectId", subjectId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);
        return dl.GetDataTable(cmd);
    }

    // ── Per-student progress ──────────────────────────────────────
    public DataTable GetStudentProgress(int subjectId, int sessionId)
    {
        var cmd = new SqlCommand(@"
            SELECT
                UP.FullName,

                -- Attendance %
                ISNULL(ROUND(
                    100.0 * SUM(CASE WHEN AT.Status='Present' THEN 1 ELSE 0 END)
                          / NULLIF(COUNT(AT.AttendanceId),0)
                ,0),0) AS AttendancePct,

                -- Assignments done
                (SELECT COUNT(*) FROM AssignmentSubmissions ASub
                 INNER JOIN Assignments A ON ASub.AssignmentId=A.AssignmentId
                 WHERE A.SubjectId=@SubjectId AND A.SessionId=@SessionId
                   AND ASub.StudentId=ASS.UserId) AS AssignmentsDone,

                -- Total assignments
                (SELECT COUNT(*) FROM Assignments
                 WHERE SubjectId=@SubjectId AND SessionId=@SessionId AND IsActive=1) AS TotalAssignments,

                -- Avg marks
                ISNULL(ROUND((SELECT AVG(CAST(ASub.MarksObtained AS FLOAT))
                              FROM AssignmentSubmissions ASub
                              INNER JOIN Assignments A ON ASub.AssignmentId=A.AssignmentId
                              WHERE A.SubjectId=@SubjectId AND A.SessionId=@SessionId
                                AND ASub.StudentId=ASS.UserId
                                AND ASub.MarksObtained IS NOT NULL),1),0) AS AvgMarks,

                -- Videos watched (ViewCount proxy via VideoViews)
                (SELECT COUNT(*) FROM VideoViews VV
                 INNER JOIN Videos V ON VV.VideoId=V.VideoId
                 INNER JOIN Chapters C ON V.ChapterId=C.ChapterId
                 WHERE C.SubjectId=@SubjectId AND VV.SessionId=@SessionId
                   AND VV.UserId=ASS.UserId) AS VideosWatched,

                -- Overall progress % = avg of attendance%, assignment completion%, video watch%
                ISNULL(ROUND((
                    ISNULL(100.0*SUM(CASE WHEN AT.Status='Present' THEN 1 ELSE 0 END)/NULLIF(COUNT(AT.AttendanceId),0),0)
                  + ISNULL(100.0*(SELECT COUNT(*) FROM AssignmentSubmissions ASub
                                  INNER JOIN Assignments A ON ASub.AssignmentId=A.AssignmentId
                                  WHERE A.SubjectId=@SubjectId AND A.SessionId=@SessionId AND ASub.StudentId=ASS.UserId)
                          /NULLIF((SELECT COUNT(*) FROM Assignments WHERE SubjectId=@SubjectId AND SessionId=@SessionId AND IsActive=1),0),0)
                ) / 2.0, 0), 0) AS OverallProgress

            FROM AssignStudentSubject ASS
            INNER JOIN UserProfile UP ON UP.UserId=ASS.UserId AND UP.SessionId=@SessionId
            LEFT JOIN  Attendance   AT ON AT.UserId=ASS.UserId
                                      AND AT.SubjectId=@SubjectId
                                      AND AT.SessionId=@SessionId
            WHERE ASS.SubjectId=@SubjectId AND ASS.SessionId=@SessionId
            GROUP BY ASS.UserId, UP.FullName
            ORDER BY OverallProgress DESC");
        cmd.Parameters.AddWithValue("@SubjectId", subjectId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);
        return dl.GetDataTable(cmd);
    }
}