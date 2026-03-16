using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using LearningManagementSystem.GC;

public class StudentQuizBL
{
    DataLayer dl = new DataLayer();

    // ============================================================
    // ✅ 1. Get all quizzes for student with state
    // ============================================================
    public DataTable GetQuizzes(int userId, int instituteId, int sessionId,
                                int filterSubjectId = 0)
    {
        SqlCommand cmd = new SqlCommand(@"
        SELECT
            Q.QuizId,
            Q.SubjectId,
            Q.Title,
            Q.Description,
            Q.Duration,
            Q.TotalMarks,
            Q.PassMarks,
            Q.DueDate,
            Q.IsEnabled,
            S.SubjectName,
            S.SubjectCode,

            -- Question count
            (SELECT COUNT(*) FROM QuizQuestions QQ
             WHERE QQ.QuizId = Q.QuizId) AS QuestionCount,

            -- Attempt info
            QR.ResultId,
            QR.Score,
            QR.SubmittedOn AS AttemptedOn,

            -- State
            CASE
                WHEN QR.ResultId IS NOT NULL              THEN 'Attempted'
                WHEN Q.IsEnabled = 0                      THEN 'Disabled'
                WHEN Q.DueDate   < GETDATE()              THEN 'Expired'
                ELSE 'Available'
            END AS State

        FROM Quizzes Q
        JOIN Subjects S ON Q.SubjectId = S.SubjectId
        LEFT JOIN QuizResults QR
               ON QR.QuizId    = Q.QuizId
              AND QR.StudentId = @UserId
        WHERE Q.InstituteId = @InstId
          AND Q.SessionId   = @SessId
          AND Q.SubjectId IN (
                SELECT SubjectId FROM AssignStudentSubject
                WHERE UserId      = @UserId
                  AND InstituteId = @InstId
                  AND SessionId   = @SessId
          )
          AND (@SubjectId = 0 OR Q.SubjectId = @SubjectId)
        ORDER BY
            CASE
                WHEN QR.ResultId IS NULL AND Q.IsEnabled = 1
                     AND Q.DueDate >= GETDATE() THEN 0
                WHEN QR.ResultId IS NULL AND Q.DueDate < GETDATE() THEN 1
                WHEN QR.ResultId IS NOT NULL THEN 2
                ELSE 3
            END,
            Q.DueDate ASC");

        cmd.Parameters.AddWithValue("@UserId", userId);
        cmd.Parameters.AddWithValue("@InstId", instituteId);
        cmd.Parameters.AddWithValue("@SessId", sessionId);
        cmd.Parameters.AddWithValue("@SubjectId", filterSubjectId);

        return dl.GetDataTable(cmd);
    }

    // ============================================================
    // ✅ 2. Get quiz header info (for attempt page top bar)
    // ============================================================
    public DataTable GetQuizById(int quizId)
    {
        SqlCommand cmd = new SqlCommand(@"
        SELECT Q.*, S.SubjectName, S.SubjectCode,
               (SELECT COUNT(*) FROM QuizQuestions WHERE QuizId = Q.QuizId)
               AS QuestionCount
        FROM Quizzes Q
        JOIN Subjects S ON Q.SubjectId = S.SubjectId
        WHERE Q.QuizId = @QuizId");

        cmd.Parameters.AddWithValue("@QuizId", quizId);
        return dl.GetDataTable(cmd);
    }

    // ============================================================
    // ✅ 3. Get all questions for a quiz (shuffled order)
    // ============================================================
    public DataTable GetQuestions(int quizId)
    {
        SqlCommand cmd = new SqlCommand(@"
        SELECT QuestionId, QuizId, QuestionText,
               OptionA, OptionB, OptionC, OptionD,
               Marks, OrderNo
        FROM QuizQuestions
        WHERE QuizId = @QuizId
        ORDER BY OrderNo, QuestionId");

        cmd.Parameters.AddWithValue("@QuizId", quizId);
        return dl.GetDataTable(cmd);
    }

    // ============================================================
    // ✅ 4. Check if student already attempted
    // ============================================================
    public bool IsAttempted(int quizId, int studentId)
    {
        SqlCommand cmd = new SqlCommand(@"
        SELECT COUNT(*) FROM QuizResults
        WHERE QuizId = @QuizId AND StudentId = @StudId");

        cmd.Parameters.AddWithValue("@QuizId", quizId);
        cmd.Parameters.AddWithValue("@StudId", studentId);

        return Convert.ToInt32(dl.GetDataTable(cmd).Rows[0][0]) > 0;
    }

    // ============================================================
    // ✅ 5. Submit quiz — calculate score and save
    // ============================================================
    public int SubmitQuiz(int quizId, int studentId,
                          int societyId, int instituteId,
                          Dictionary<int, string> answers,
                          int timeTaken, bool isAutoSubmit)
    {
        // ── Get correct answers ──────────────────────────────
        SqlCommand qCmd = new SqlCommand(@"
            SELECT QuestionId, CorrectOption, Marks
            FROM QuizQuestions WHERE QuizId = @QuizId");
        qCmd.Parameters.AddWithValue("@QuizId", quizId);
        DataTable dtQ = dl.GetDataTable(qCmd);

        int score = 0;
        int totalMarks = 0;

        foreach (DataRow r in dtQ.Rows)
            totalMarks += Convert.ToInt32(r["Marks"]);

        // ── Insert QuizResult ────────────────────────────────
        SqlCommand resCmd = new SqlCommand(@"
            INSERT INTO QuizResults
            (QuizId, StudentId, SocietyId, InstituteId,
             Score, TotalMarks, TimeTaken, IsAutoSubmit, SubmittedOn)
            VALUES
            (@QuizId, @StudId, @SocId, @InstId,
             0, @Total, @Time, @Auto, GETDATE());
            SELECT SCOPE_IDENTITY();");

        resCmd.Parameters.AddWithValue("@QuizId", quizId);
        resCmd.Parameters.AddWithValue("@StudId", studentId);
        resCmd.Parameters.AddWithValue("@SocId", societyId);
        resCmd.Parameters.AddWithValue("@InstId", instituteId);
        resCmd.Parameters.AddWithValue("@Total", totalMarks);
        resCmd.Parameters.AddWithValue("@Time", timeTaken);
        resCmd.Parameters.AddWithValue("@Auto", isAutoSubmit);

        int resultId = Convert.ToInt32(dl.GetDataTable(resCmd).Rows[0][0]);

        // ── Insert attempt details + calculate score ─────────
        foreach (DataRow r in dtQ.Rows)
        {
            int questionId = Convert.ToInt32(r["QuestionId"]);
            string correctOption = r["CorrectOption"].ToString();
            int marks = Convert.ToInt32(r["Marks"]);

            string selected = answers.ContainsKey(questionId)
                              ? answers[questionId] : null;

            bool isCorrect = !string.IsNullOrEmpty(selected)
                             && selected == correctOption;

            if (isCorrect) score += marks;

            SqlCommand detCmd = new SqlCommand(@"
                INSERT INTO QuizAttemptDetails
                (ResultId, QuestionId, SelectedOption, IsCorrect)
                VALUES
                (@ResId, @QId, @Sel, @Correct)");

            detCmd.Parameters.AddWithValue("@ResId", resultId);
            detCmd.Parameters.AddWithValue("@QId", questionId);
            detCmd.Parameters.AddWithValue("@Sel",
                (object)selected ?? DBNull.Value);
            detCmd.Parameters.AddWithValue("@Correct", isCorrect);

            dl.ExecuteCMD(detCmd);
        }

        // ── Update final score ───────────────────────────────
        SqlCommand updateCmd = new SqlCommand(@"
            UPDATE QuizResults SET Score = @Score
            WHERE ResultId = @ResId");

        updateCmd.Parameters.AddWithValue("@Score", score);
        updateCmd.Parameters.AddWithValue("@ResId", resultId);
        dl.ExecuteCMD(updateCmd);

        return resultId;
    }

    // ============================================================
    // ✅ 6. Get result detail (for result screen after submit)
    // ============================================================
    public DataTable GetResult(int resultId)
    {
        SqlCommand cmd = new SqlCommand(@"
        SELECT
            QR.ResultId, QR.Score, QR.TotalMarks, QR.TimeTaken,
            QR.IsAutoSubmit, QR.SubmittedOn,
            Q.Title, Q.PassMarks, Q.Duration,
            S.SubjectName,
            (SELECT COUNT(*) FROM QuizAttemptDetails
             WHERE ResultId = QR.ResultId AND IsCorrect = 1) AS Correct,
            (SELECT COUNT(*) FROM QuizAttemptDetails
             WHERE ResultId = QR.ResultId AND IsCorrect = 0
               AND SelectedOption IS NOT NULL)               AS Wrong,
            (SELECT COUNT(*) FROM QuizAttemptDetails
             WHERE ResultId = QR.ResultId
               AND SelectedOption IS NULL)                   AS Skipped
        FROM QuizResults QR
        JOIN Quizzes  Q ON QR.QuizId    = Q.QuizId
        JOIN Subjects S ON Q.SubjectId  = S.SubjectId
        WHERE QR.ResultId = @ResId");

        cmd.Parameters.AddWithValue("@ResId", resultId);
        return dl.GetDataTable(cmd);
    }

    // ============================================================
    // ✅ 7. Get attempt details (question-by-question review)
    // ============================================================
    public DataTable GetAttemptDetails(int resultId)
    {
        SqlCommand cmd = new SqlCommand(@"
        SELECT
            QQ.QuestionId, QQ.QuestionText,
            QQ.OptionA, QQ.OptionB, QQ.OptionC, QQ.OptionD,
            QQ.CorrectOption, QQ.Marks,
            AD.SelectedOption, AD.IsCorrect,
            QQ.OrderNo
        FROM QuizAttemptDetails AD
        JOIN QuizQuestions QQ ON AD.QuestionId = QQ.QuestionId
        WHERE AD.ResultId = @ResId
        ORDER BY QQ.OrderNo, QQ.QuestionId");

        cmd.Parameters.AddWithValue("@ResId", resultId);
        return dl.GetDataTable(cmd);
    }

    // ============================================================
    // ✅ 8. Summary counts for chips
    // ============================================================
    public DataTable GetQuizCounts(int userId, int instituteId, int sessionId)
    {
        SqlCommand cmd = new SqlCommand(@"
        SELECT
            COUNT(*) AS Total,
            SUM(CASE WHEN QR.ResultId IS NOT NULL              THEN 1 ELSE 0 END) AS Attempted,
            SUM(CASE WHEN QR.ResultId IS NULL AND Q.IsEnabled = 1
                          AND Q.DueDate >= GETDATE()           THEN 1 ELSE 0 END) AS Available,
            SUM(CASE WHEN QR.ResultId IS NULL
                          AND Q.DueDate < GETDATE()            THEN 1 ELSE 0 END) AS Expired
        FROM Quizzes Q
        LEFT JOIN QuizResults QR
               ON QR.QuizId = Q.QuizId AND QR.StudentId = @UserId
        WHERE Q.InstituteId = @InstId
          AND Q.SessionId   = @SessId
          AND Q.SubjectId IN (
                SELECT SubjectId FROM AssignStudentSubject
                WHERE UserId = @UserId AND InstituteId = @InstId
                  AND SessionId = @SessId
          )");

        cmd.Parameters.AddWithValue("@UserId", userId);
        cmd.Parameters.AddWithValue("@InstId", instituteId);
        cmd.Parameters.AddWithValue("@SessId", sessionId);

        return dl.GetDataTable(cmd);
    }

    // ============================================================
    // ✅ 9. Enrolled subjects for filter dropdown
    // ============================================================
    public DataTable GetSubjectsForFilter(int userId, int instituteId, int sessionId)
    {
        SqlCommand cmd = new SqlCommand(@"
        SELECT S.SubjectId, S.SubjectName, S.SubjectCode
        FROM AssignStudentSubject ASS
        JOIN Subjects S ON ASS.SubjectId = S.SubjectId
        WHERE ASS.UserId = @UserId AND ASS.InstituteId = @InstId
          AND ASS.SessionId = @SessId AND S.IsActive = 1
        ORDER BY S.SubjectName");

        cmd.Parameters.AddWithValue("@UserId", userId);
        cmd.Parameters.AddWithValue("@InstId", instituteId);
        cmd.Parameters.AddWithValue("@SessId", sessionId);

        return dl.GetDataTable(cmd);
    }
}