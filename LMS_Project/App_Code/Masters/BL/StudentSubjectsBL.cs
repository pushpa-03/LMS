using System;
using System.Data;
using System.Data.SqlClient;

public class StudentSubjectsBL
{
    DataLayer dl = new DataLayer();

    // ============================================================
    // ✅ Get all enrolled subjects for a student (full detail)
    // ============================================================
    public DataTable GetMySubjects(int userId, int instituteId, int sessionId)
    {
        SqlCommand cmd = new SqlCommand(@"
        SELECT
            S.SubjectId,
            S.SubjectCode,
            S.SubjectName,
            S.Description,
            S.Duration,
            ST.StreamName,
            C.CourseName,
            SL.LevelName,
            SM.SemesterName,

            -- Assigned teacher
            ISNULL(UP.FullName,  'Not Assigned') AS TeacherName,
            ISNULL(U.Email,      '')             AS TeacherEmail,

            -- Content counts
            (SELECT COUNT(*) FROM Chapters CH
            WHERE CH.SubjectId = S.SubjectId) AS ChapterCount,

            (SELECT COUNT(*) FROM Videos VD
            JOIN Chapters CH2 ON VD.ChapterId = CH2.ChapterId
            WHERE CH2.SubjectId = S.SubjectId) AS VideoCount,

            (SELECT COUNT(*) FROM Materials MT
            JOIN Chapters CH3 ON MT.ChapterId = CH3.ChapterId
            WHERE CH3.SubjectId = S.SubjectId) AS MaterialCount

        FROM AssignStudentSubject ASS
        JOIN Subjects       S   ON ASS.SubjectId   = S.SubjectId
        JOIN LevelSemesterSubjects  LS  ON ASS.SubjectId  = LS.SubjectId
        LEFT JOIN Streams    ST  ON LS.StreamId      = ST.StreamId
        LEFT JOIN Courses    C   ON LS.CourseId      = C.CourseId
        LEFT JOIN StudyLevels SL ON LS.LevelId       = SL.LevelId
        LEFT JOIN Semesters  SM  ON LS.SemesterId    = SM.SemesterId

        -- Teacher assigned to this subject for this session
        LEFT JOIN SubjectFaculty SF
               ON SF.SubjectId   = S.SubjectId
              AND SF.InstituteId = @InstId
              AND SF.SessionId   = @SessId
              AND SF.IsActive    = 1
        LEFT JOIN Users      U   ON SF.TeacherId    = U.UserId
        LEFT JOIN UserProfile UP ON U.UserId        = UP.UserId

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

    // ============================================================
    // ✅ Get single subject detail (for subject info card on top)
    // ============================================================
    public DataTable GetSubjectById(int subjectId, int instituteId, int sessionId)
    {
        SqlCommand cmd = new SqlCommand(@"
        SELECT
            S.SubjectId,
            S.SubjectCode,
            S.SubjectName,
            S.Description,
            S.Duration,
            ST.StreamName,
            C.CourseName,
            SL.LevelName,
            SM.SemesterName,
            ISNULL(UP.FullName, 'Not Assigned') AS TeacherName,
            ISNULL(U.Email,     '')             AS TeacherEmail
        FROM Subjects       S 
        INNER JOIN LevelSemesterSubjects LS 
        ON S.SubjectId = LS.SubjectId
        LEFT JOIN Streams    ST  ON LS.StreamId   = ST.StreamId
        LEFT JOIN Courses    C   ON LS.CourseId   = C.CourseId
        LEFT JOIN StudyLevels SL ON LS.LevelId    = SL.LevelId
        LEFT JOIN Semesters  SM  ON LS.SemesterId = SM.SemesterId
        LEFT JOIN SubjectFaculty SF
               ON SF.SubjectId   = S.SubjectId
              AND SF.InstituteId = @InstId
              AND SF.SessionId   = @SessId
              AND SF.IsActive    = 1
        LEFT JOIN Users      U   ON SF.TeacherId = U.UserId
        LEFT JOIN UserProfile UP ON U.UserId     = UP.UserId
        WHERE S.SubjectId = @SubjectId");

        cmd.Parameters.AddWithValue("@SubjectId", subjectId);
        cmd.Parameters.AddWithValue("@InstId", instituteId);
        cmd.Parameters.AddWithValue("@SessId", sessionId);

        return dl.GetDataTable(cmd);
    }

    // ============================================================
    // ✅ Search subjects by name or code
    // ============================================================
    public DataTable SearchSubjects(int userId, int instituteId,
                                    int sessionId, string keyword)
    {
        SqlCommand cmd = new SqlCommand(@"
        SELECT
            S.SubjectId,
            S.SubjectCode,
            S.SubjectName,
            S.Description,
            S.Duration,
            ST.StreamName,
            C.CourseName,
            SL.LevelName,
            SM.SemesterName,
            ISNULL(UP.FullName, 'Not Assigned') AS TeacherName,
            (SELECT COUNT(*) FROM Chapters CH
            WHERE CH.SubjectId = S.SubjectId) AS ChapterCount,

            (SELECT COUNT(*) FROM Videos VD
            JOIN Chapters CH2 ON VD.ChapterId = CH2.ChapterId
            WHERE CH2.SubjectId = S.SubjectId) AS VideoCount,

            (SELECT COUNT(*) FROM Materials MT
            JOIN Chapters CH3 ON MT.ChapterId = CH3.ChapterId
            WHERE CH3.SubjectId = S.SubjectId) AS MaterialCount
        FROM AssignStudentSubject ASS
        JOIN Subjects       S   ON ASS.SubjectId   = S.SubjectId
        JOIN LevelSemesterSubjects  LS  ON ASS.SubjectId  = LS.SubjectId
        LEFT JOIN Streams    ST  ON LS.StreamId      = ST.StreamId
        LEFT JOIN Courses    C   ON LS.CourseId      = C.CourseId
        LEFT JOIN StudyLevels SL ON LS.LevelId       = SL.LevelId
        LEFT JOIN Semesters  SM  ON LS.SemesterId    = SM.SemesterId
        LEFT JOIN SubjectFaculty SF
               ON SF.SubjectId   = S.SubjectId
              AND SF.InstituteId = @InstId
              AND SF.SessionId   = @SessId
              AND SF.IsActive    = 1
        LEFT JOIN Users      U   ON SF.TeacherId    = U.UserId
        LEFT JOIN UserProfile UP ON U.UserId        = UP.UserId
        WHERE ASS.UserId      = @UserId
          AND ASS.InstituteId = @InstId
          AND ASS.SessionId   = @SessId
          AND S.IsActive      = 1
          AND (S.SubjectName LIKE @Kw OR S.SubjectCode LIKE @Kw)
        ORDER BY S.SubjectName");

        cmd.Parameters.AddWithValue("@UserId", userId);
        cmd.Parameters.AddWithValue("@InstId", instituteId);
        cmd.Parameters.AddWithValue("@SessId", sessionId);
        cmd.Parameters.AddWithValue("@Kw", "%" + keyword + "%");

        return dl.GetDataTable(cmd);
    }

    // ============================================================
    // ✅ Get current session
    // ============================================================
    public int GetCurrentSessionId(int instituteId)
    {
        SqlCommand cmd = new SqlCommand(@"
        SELECT TOP 1 SessionId
        FROM AcademicSessions
        WHERE InstituteId = @InstId AND IsCurrent = 1");

        cmd.Parameters.AddWithValue("@InstId", instituteId);

        DataTable dt = dl.GetDataTable(cmd);

        return dt.Rows.Count > 0
               ? Convert.ToInt32(dt.Rows[0]["SessionId"])
               : 0;
    }
}