using System;
using System.Data;
using System.Data.SqlClient;

public class StudentResultsBL
{
    DataLayer dl = new DataLayer();

    // ============================================================
    // ✅ 1. Assignment results — all graded submissions
    // ============================================================
    public DataTable GetAssignmentResults(int userId, int instituteId, int sessionId,
                                          int filterSubjectId = 0)
    {
        SqlCommand cmd = new SqlCommand(@"
        SELECT
            A.AssignmentId,
            A.Title,
            A.MaxMarks,
            A.DueDate,
            S.SubjectName,
            S.SubjectCode,
            SUB.SubmissionId,
            SUB.MarksObtained,
            SUB.SubmittedOn,
            SUB.Remarks,
            SUB.FilePath,

            -- Result status
            CASE
                WHEN SUB.MarksObtained IS NULL THEN 'Pending'
                ELSE 'Graded'
            END AS GradeStatus,

            -- Percentage
            CASE
                WHEN SUB.MarksObtained IS NOT NULL AND A.MaxMarks > 0
                THEN CAST(ROUND(SUB.MarksObtained * 100.0 / A.MaxMarks, 0) AS INT)
                ELSE NULL
            END AS Percentage

        FROM AssignmentSubmissions SUB
        JOIN Assignments A ON SUB.AssignmentId = A.AssignmentId
        JOIN Subjects    S ON A.SubjectId       = S.SubjectId
        WHERE SUB.StudentId   = @UserId
          AND A.InstituteId   = @InstId
          AND (@SubjectId = 0 OR A.SubjectId = @SubjectId)
        ORDER BY SUB.SubmittedOn DESC");

        cmd.Parameters.AddWithValue("@UserId", userId);
        cmd.Parameters.AddWithValue("@InstId", instituteId);
        cmd.Parameters.AddWithValue("@SubjectId", filterSubjectId);

        return dl.GetDataTable(cmd);
    }

    // ============================================================
    // ✅ 2. Quiz results — all attempted quizzes
    // ============================================================
    public DataTable GetQuizResults(int userId, int instituteId,
                                    int filterSubjectId = 0)
    {
        SqlCommand cmd = new SqlCommand(@"
        SELECT
            Q.QuizId,
            Q.Title,
            Q.TotalMarks,
            Q.PassMarks,
            Q.Duration,
            S.SubjectName,
            S.SubjectCode,
            QR.ResultId,
            QR.Score,
            QR.TimeTaken,
            QR.IsAutoSubmit,
            QR.SubmittedOn,

            -- Passed/Failed
            CASE
                WHEN QR.Score >= Q.PassMarks THEN 'Passed'
                ELSE 'Failed'
            END AS QuizStatus,

            -- Percentage
            CASE
                WHEN Q.TotalMarks > 0
                THEN CAST(ROUND(QR.Score * 100.0 / Q.TotalMarks, 0) AS INT)
                ELSE 0
            END AS Percentage,

            -- Correct / Wrong / Skipped counts
            (SELECT COUNT(*) FROM QuizAttemptDetails
             WHERE ResultId = QR.ResultId AND IsCorrect = 1)  AS Correct,
            (SELECT COUNT(*) FROM QuizAttemptDetails
             WHERE ResultId = QR.ResultId AND IsCorrect = 0
               AND SelectedOption IS NOT NULL)                AS Wrong,
            (SELECT COUNT(*) FROM QuizAttemptDetails
             WHERE ResultId = QR.ResultId
               AND SelectedOption IS NULL)                    AS Skipped

        FROM QuizResults QR
        JOIN Quizzes  Q ON QR.QuizId    = Q.QuizId
        JOIN Subjects S ON Q.SubjectId  = S.SubjectId
        WHERE QR.StudentId  = @UserId
          AND Q.InstituteId = @InstId
          AND (@SubjectId = 0 OR Q.SubjectId = @SubjectId)
        ORDER BY QR.SubmittedOn DESC");

        cmd.Parameters.AddWithValue("@UserId", userId);
        cmd.Parameters.AddWithValue("@InstId", instituteId);
        cmd.Parameters.AddWithValue("@SubjectId", filterSubjectId);

        return dl.GetDataTable(cmd);
    }

    // ============================================================
    // ✅ 3. Summary counts for both tabs
    // ============================================================
    public DataTable GetSummaryCounts(int userId, int instituteId, int sessionId)
    {
        SqlCommand cmd = new SqlCommand(@"
        SELECT
            -- Assignment stats
            (SELECT COUNT(*) FROM AssignmentSubmissions SUB
             JOIN Assignments A ON SUB.AssignmentId = A.AssignmentId
             WHERE SUB.StudentId = @UserId AND A.InstituteId = @InstId)
                AS TotalSubmissions,

            (SELECT COUNT(*) FROM AssignmentSubmissions SUB
             JOIN Assignments A ON SUB.AssignmentId = A.AssignmentId
             WHERE SUB.StudentId = @UserId AND A.InstituteId = @InstId
               AND SUB.MarksObtained IS NOT NULL)
                AS GradedCount,

            (SELECT ISNULL(AVG(CAST(SUB.MarksObtained AS FLOAT)
                 / NULLIF(A.MaxMarks,0) * 100), 0)
             FROM AssignmentSubmissions SUB
             JOIN Assignments A ON SUB.AssignmentId = A.AssignmentId
             WHERE SUB.StudentId = @UserId AND A.InstituteId = @InstId
               AND SUB.MarksObtained IS NOT NULL)
                AS AvgAssignmentScore,

            -- Quiz stats
            (SELECT COUNT(*) FROM QuizResults QR
             JOIN Quizzes Q ON QR.QuizId = Q.QuizId
             WHERE QR.StudentId = @UserId AND Q.InstituteId = @InstId)
                AS TotalQuizzes,

            (SELECT COUNT(*) FROM QuizResults QR
             JOIN Quizzes Q ON QR.QuizId = Q.QuizId
             WHERE QR.StudentId = @UserId AND Q.InstituteId = @InstId
               AND QR.Score >= Q.PassMarks)
                AS QuizzesPassed,

            (SELECT ISNULL(AVG(CAST(QR.Score AS FLOAT)
                 / NULLIF(Q.TotalMarks,0) * 100), 0)
             FROM QuizResults QR
             JOIN Quizzes Q ON QR.QuizId = Q.QuizId
             WHERE QR.StudentId = @UserId AND Q.InstituteId = @InstId)
                AS AvgQuizScore");

        cmd.Parameters.AddWithValue("@UserId", userId);
        cmd.Parameters.AddWithValue("@InstId", instituteId);

        return dl.GetDataTable(cmd);
    }

    // ============================================================
    // ✅ 4. Subjects for filter dropdown
    // ============================================================
    public DataTable GetSubjectsForFilter(int userId, int instituteId, int sessionId)
    {
        SqlCommand cmd = new SqlCommand(@"
        SELECT S.SubjectId, S.SubjectName, S.SubjectCode
        FROM AssignStudentSubject ASS
        JOIN Subjects S ON ASS.SubjectId = S.SubjectId
        WHERE ASS.UserId      = @UserId
          AND ASS.InstituteId = @InstId
          AND ASS.SessionId   = @SessId
          AND S.IsActive      = 1
        ORDER BY S.SubjectName");

        cmd.Parameters.AddWithValue("@UserId", userId);
        cmd.Parameters.AddWithValue("@InstId", instituteId);
        cmd.Parameters.AddWithValue("@SessId", sessionId);

        return dl.GetDataTable(cmd);
    }
}