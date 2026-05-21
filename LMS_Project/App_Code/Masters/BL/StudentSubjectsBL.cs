using System;
using System.Data;
using System.Data.SqlClient;

public class StudentSubjectsBL
{
    DataLayer dl = new DataLayer();

    // ============================================================
    // Get all enrolled subjects for a student (full detail)
    // Includes WatchedVideos, CompletedVideos, AttendancePct
    // for the progress bar and pills on each subject card.
    // ============================================================
    public DataTable GetMySubjects(int userId, int instituteId, int sessionId)
    {
        SqlCommand cmd = new SqlCommand(@"

    SELECT DISTINCT
        S.SubjectId,
        S.SubjectCode,
        S.SubjectName,
        S.Description,
        S.Duration,

        ST.StreamName,
        C.CourseName,
        SL.LevelName,
        SM.SemesterName,

        ISNULL(T.TeacherName,  'Not Assigned') AS TeacherName,
        ISNULL(T.TeacherEmail, '')             AS TeacherEmail,

        -- Chapter count
        (
            SELECT COUNT(*)
            FROM Chapters CH
            WHERE CH.SubjectId = S.SubjectId
        ) AS ChapterCount,

        -- Video count
        (
            SELECT COUNT(*)
            FROM Videos VD
            INNER JOIN Chapters CH2
                ON VD.ChapterId = CH2.ChapterId
            WHERE CH2.SubjectId = S.SubjectId
        ) AS VideoCount,

        -- Material count
        (
            SELECT COUNT(*)
            FROM Materials MT
            INNER JOIN Chapters CH3
                ON MT.ChapterId = CH3.ChapterId
            WHERE CH3.SubjectId = S.SubjectId
        ) AS MaterialCount,

        -- Videos this STUDENT has watched (distinct, any view)
        (
            SELECT COUNT(DISTINCT VV.VideoId)
            FROM VideoViews VV
            JOIN Videos V2     ON VV.VideoId   = V2.VideoId
            JOIN Chapters CH4  ON V2.ChapterId = CH4.ChapterId
            WHERE VV.UserId        = @UserId
              AND CH4.SubjectId    = S.SubjectId
              AND VV.InstituteId   = @InstId
        ) AS WatchedVideos,

        -- Videos this student has COMPLETED (IsCompleted = 1)
        (
            SELECT COUNT(DISTINCT VV2.VideoId)
            FROM VideoViews VV2
            JOIN Videos V3     ON VV2.VideoId   = V3.VideoId
            JOIN Chapters CH5  ON V3.ChapterId  = CH5.ChapterId
            WHERE VV2.UserId      = @UserId
              AND CH5.SubjectId   = S.SubjectId
              AND VV2.IsCompleted = 1
        ) AS CompletedVideos,

        -- Attendance % for this subject in this session
        ISNULL(
            (
                SELECT CAST(ROUND(
                    SUM(CASE WHEN Status = 'Present' THEN 1.0 ELSE 0 END)
                    / NULLIF(COUNT(*), 0) * 100, 0) AS INT)
                FROM Attendance
                WHERE UserId      = @UserId
                  AND SubjectId   = S.SubjectId
                  AND InstituteId = @InstId
                  AND SessionId   = @SessId
            ), 0) AS AttendancePct

    FROM AssignStudentSubject ASS

    INNER JOIN Subjects S
        ON ASS.SubjectId = S.SubjectId

    LEFT JOIN StudentAcademicDetails SAD
        ON SAD.UserId    = ASS.UserId
       AND SAD.SessionId = ASS.SessionId

    LEFT JOIN LevelSemesterSubjects LS
        ON LS.SubjectId  = ASS.SubjectId
       AND LS.StreamId   = SAD.StreamId
       AND LS.CourseId   = SAD.CourseId
       AND LS.LevelId    = SAD.LevelId
       AND LS.SemesterId = SAD.SemesterId
       AND LS.SessionId  = ASS.SessionId

    LEFT JOIN Streams     ST  ON LS.StreamId   = ST.StreamId
    LEFT JOIN Courses     C   ON LS.CourseId   = C.CourseId
    LEFT JOIN StudyLevels SL  ON LS.LevelId    = SL.LevelId
    LEFT JOIN Semesters   SM  ON LS.SemesterId = SM.SemesterId

    -- Only one teacher per subject
    OUTER APPLY
    (
        SELECT TOP 1
            UP.FullName AS TeacherName,
            U.Email     AS TeacherEmail
        FROM SubjectFaculty SF
        INNER JOIN Users       U   ON SF.TeacherId = U.UserId
        LEFT  JOIN UserProfile UP  ON U.UserId     = UP.UserId
        WHERE SF.SubjectId   = S.SubjectId
          AND SF.InstituteId = @InstId
          AND SF.SessionId   = @SessId
          AND SF.IsActive    = 1
    ) T

    WHERE ASS.UserId      = @UserId
      AND ASS.InstituteId = @InstId
      AND ASS.SessionId   = @SessId
      AND S.IsActive      = 1

    ORDER BY S.SubjectName
    ");

        cmd.Parameters.AddWithValue("@UserId", userId);
        cmd.Parameters.AddWithValue("@InstId", instituteId);
        cmd.Parameters.AddWithValue("@SessId", sessionId);

        return dl.GetDataTable(cmd);
    }

    // ============================================================
    // Get single subject detail (for subject info card on top)
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
        FROM Subjects S
        INNER JOIN LevelSemesterSubjects LS ON S.SubjectId = LS.SubjectId
        LEFT JOIN Streams     ST  ON LS.StreamId   = ST.StreamId
        LEFT JOIN Courses     C   ON LS.CourseId   = C.CourseId
        LEFT JOIN StudyLevels SL  ON LS.LevelId    = SL.LevelId
        LEFT JOIN Semesters   SM  ON LS.SemesterId = SM.SemesterId
        LEFT JOIN SubjectFaculty SF
               ON SF.SubjectId   = S.SubjectId
              AND SF.InstituteId = @InstId
              AND SF.SessionId   = @SessId
              AND SF.IsActive    = 1
        LEFT JOIN Users       U   ON SF.TeacherId = U.UserId
        LEFT JOIN UserProfile UP  ON U.UserId     = UP.UserId
        WHERE S.SubjectId = @SubjectId");

        cmd.Parameters.AddWithValue("@SubjectId", subjectId);
        cmd.Parameters.AddWithValue("@InstId", instituteId);
        cmd.Parameters.AddWithValue("@SessId", sessionId);

        return dl.GetDataTable(cmd);
    }

    // ============================================================
    // Search subjects by name or code
    // Includes WatchedVideos, CompletedVideos, AttendancePct
    // so the card progress section works on search results too.
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
             WHERE CH3.SubjectId = S.SubjectId) AS MaterialCount,

            -- Videos watched (any view) by this student
            (
                SELECT COUNT(DISTINCT VV.VideoId)
                FROM VideoViews VV
                JOIN Videos V2    ON VV.VideoId   = V2.VideoId
                JOIN Chapters CH4 ON V2.ChapterId = CH4.ChapterId
                WHERE VV.UserId       = @UserId
                  AND CH4.SubjectId   = S.SubjectId
                  AND VV.InstituteId  = @InstId
            ) AS WatchedVideos,

            -- Videos completed by this student
            (
                SELECT COUNT(DISTINCT VV2.VideoId)
                FROM VideoViews VV2
                JOIN Videos V3    ON VV2.VideoId   = V3.VideoId
                JOIN Chapters CH5 ON V3.ChapterId  = CH5.ChapterId
                WHERE VV2.UserId      = @UserId
                  AND CH5.SubjectId   = S.SubjectId
                  AND VV2.IsCompleted = 1
            ) AS CompletedVideos,

            -- Attendance %
            ISNULL(
                (
                    SELECT CAST(ROUND(
                        SUM(CASE WHEN Status = 'Present' THEN 1.0 ELSE 0 END)
                        / NULLIF(COUNT(*), 0) * 100, 0) AS INT)
                    FROM Attendance
                    WHERE UserId      = @UserId
                      AND SubjectId   = S.SubjectId
                      AND InstituteId = @InstId
                      AND SessionId   = @SessId
                ), 0) AS AttendancePct

        FROM AssignStudentSubject ASS
        JOIN Subjects              S   ON ASS.SubjectId  = S.SubjectId
        JOIN LevelSemesterSubjects LS  ON ASS.SubjectId  = LS.SubjectId
        LEFT JOIN Streams     ST  ON LS.StreamId   = ST.StreamId
        LEFT JOIN Courses     C   ON LS.CourseId   = C.CourseId
        LEFT JOIN StudyLevels SL  ON LS.LevelId    = SL.LevelId
        LEFT JOIN Semesters   SM  ON LS.SemesterId = SM.SemesterId
        LEFT JOIN SubjectFaculty SF
               ON SF.SubjectId   = S.SubjectId
              AND SF.InstituteId = @InstId
              AND SF.SessionId   = @SessId
              AND SF.IsActive    = 1
        LEFT JOIN Users       U   ON SF.TeacherId = U.UserId
        LEFT JOIN UserProfile UP  ON U.UserId     = UP.UserId
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
    // Get current session
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

    // ============================================================
    // Chapters for a subject with student progress
    // ============================================================
    public DataTable GetChaptersWithProgress(int subjectId, int userId,
                                             int instituteId, int sessionId)
    {
        SqlCommand cmd = new SqlCommand(@"
        SELECT
            CH.ChapterId,
            CH.ChapterName,
            CH.OrderNo,
            (SELECT COUNT(*) FROM Videos V
             WHERE V.ChapterId  = CH.ChapterId
               AND V.IsActive   = 1)                               AS TotalVideos,
            (SELECT COUNT(DISTINCT VV.VideoId)
             FROM VideoViews VV
             JOIN Videos V2 ON VV.VideoId = V2.VideoId
             WHERE V2.ChapterId   = CH.ChapterId
               AND VV.UserId      = @UserId
               AND VV.IsCompleted = 1)                             AS CompletedVideos,
            (SELECT COUNT(*) FROM Materials M
             WHERE M.ChapterId = CH.ChapterId)                     AS MaterialCount
        FROM Chapters CH
        WHERE CH.SubjectId   = @SubjId
          AND CH.InstituteId = @InstId
        ORDER BY CH.OrderNo, CH.ChapterId");

        cmd.Parameters.AddWithValue("@SubjId", subjectId);
        cmd.Parameters.AddWithValue("@UserId", userId);
        cmd.Parameters.AddWithValue("@InstId", instituteId);
        return dl.GetDataTable(cmd);
    }

    // ============================================================
    // Videos in a chapter with student watch state
    // ============================================================
    public DataTable GetVideosWithProgress(int chapterId, int userId, int instituteId)
    {
        SqlCommand cmd = new SqlCommand(@"
        SELECT
            V.VideoId,
            V.Title,
            V.Duration,
            V.Description,
            V.VideoPath,
            V.InstructorName,
            CASE WHEN VV.ViewId IS NOT NULL THEN 1 ELSE 0 END    AS HasViewed,
            ISNULL(VV.IsCompleted, 0)                            AS IsCompleted,
            ISNULL(WP.LastPosition, 0)                           AS LastPosition,
            ISNULL(WP.WatchedPercent, 0)                         AS WatchedPercent
        FROM Videos V
        LEFT JOIN VideoViews VV
               ON VV.VideoId = V.VideoId
              AND VV.UserId  = @UserId
        LEFT JOIN VideoWatchProgress WP
               ON WP.VideoId = V.VideoId
              AND WP.UserId  = @UserId
        WHERE V.ChapterId   = @ChapId
          AND V.InstituteId = @InstId
          AND V.IsActive    = 1
        ORDER BY V.VideoId");

        cmd.Parameters.AddWithValue("@ChapId", chapterId);
        cmd.Parameters.AddWithValue("@UserId", userId);
        cmd.Parameters.AddWithValue("@InstId", instituteId);
        return dl.GetDataTable(cmd);
    }

    // ============================================================
    // Save / update watch progress  (called on timeupdate event)
    // ============================================================
    public void SaveWatchProgress(int videoId, int userId, int societyId,
                                  int instituteId, int sessionId,
                                  int watchedSeconds, int totalSeconds,
                                  int lastPosition)
    {
        if (totalSeconds <= 0) return;

        int pct = (int)((double)watchedSeconds / totalSeconds * 100);
        bool completed = pct >= 90;

        // Upsert VideoWatchProgress
        SqlCommand cmd = new SqlCommand(@"
        IF EXISTS (SELECT 1 FROM VideoWatchProgress
                   WHERE VideoId=@Vid AND UserId=@Uid)
        BEGIN
            UPDATE VideoWatchProgress SET
                WatchedSeconds = @WatchedSec,
                WatchedPercent = @Pct,
                LastPosition   = @LastPos,
                VideoDuration  = @Total,
                UpdatedOn      = GETDATE()
            WHERE VideoId=@Vid AND UserId=@Uid
        END
        ELSE
        BEGIN
            INSERT INTO VideoWatchProgress
            (SocietyId,InstituteId,SessionId,VideoId,UserId,
             WatchedSeconds,VideoDuration,WatchedPercent,LastPosition,UpdatedOn)
            VALUES
            (@SocId,@InstId,@SessId,@Vid,@Uid,
             @WatchedSec,@Total,@Pct,@LastPos,GETDATE())
        END");

        cmd.Parameters.AddWithValue("@Vid", videoId);
        cmd.Parameters.AddWithValue("@Uid", userId);
        cmd.Parameters.AddWithValue("@SocId", societyId);
        cmd.Parameters.AddWithValue("@InstId", instituteId);
        cmd.Parameters.AddWithValue("@SessId", sessionId);
        cmd.Parameters.AddWithValue("@WatchedSec", watchedSeconds);
        cmd.Parameters.AddWithValue("@Total", totalSeconds);
        cmd.Parameters.AddWithValue("@Pct", pct);
        cmd.Parameters.AddWithValue("@LastPos", lastPosition);
        dl.ExecuteCMD(cmd);

        // Upsert VideoViews — only mark completed once
        SqlCommand vCmd = new SqlCommand(@"
        IF NOT EXISTS (SELECT 1 FROM VideoViews
                       WHERE VideoId=@Vid AND UserId=@Uid)
        BEGIN
            INSERT INTO VideoViews
            (SocietyId,InstituteId,SessionId,VideoId,UserId,ViewedOn,IsCompleted)
            VALUES(@SocId,@InstId,@SessId,@Vid,@Uid,GETDATE(),@Comp)
        END
        ELSE IF @Comp = 1
        BEGIN
            UPDATE VideoViews SET IsCompleted=1
            WHERE VideoId=@Vid AND UserId=@Uid AND IsCompleted=0
        END");

        vCmd.Parameters.AddWithValue("@Vid", videoId);
        vCmd.Parameters.AddWithValue("@Uid", userId);
        vCmd.Parameters.AddWithValue("@SocId", societyId);
        vCmd.Parameters.AddWithValue("@InstId", instituteId);
        vCmd.Parameters.AddWithValue("@SessId", sessionId);
        vCmd.Parameters.AddWithValue("@Comp", completed ? 1 : 0);
        dl.ExecuteCMD(vCmd);

        // Update ViewCount on Videos (one per student)
        if (completed)
        {
            SqlCommand vcCmd = new SqlCommand(@"
            UPDATE Videos SET ViewCount = (
                SELECT COUNT(*) FROM VideoViews
                WHERE VideoId=@Vid AND IsCompleted=1
            ) WHERE VideoId=@Vid");
            vcCmd.Parameters.AddWithValue("@Vid", videoId);
            dl.ExecuteCMD(vcCmd);
        }
    }

    // ============================================================
    // Get resume position for a video
    // ============================================================
    public DataTable GetResumePosition(int videoId, int userId)
    {
        SqlCommand cmd = new SqlCommand(@"
        SELECT
            ISNULL(WP.LastPosition,   0) AS LastPosition,
            ISNULL(WP.WatchedPercent, 0) AS WatchedPercent,
            ISNULL(VV.IsCompleted,    0) AS IsCompleted
        FROM Videos V
        LEFT JOIN VideoWatchProgress WP
               ON WP.VideoId=V.VideoId AND WP.UserId=@Uid
        LEFT JOIN VideoViews VV
               ON VV.VideoId=V.VideoId AND VV.UserId=@Uid
        WHERE V.VideoId=@Vid");

        cmd.Parameters.AddWithValue("@Vid", videoId);
        cmd.Parameters.AddWithValue("@Uid", userId);
        return dl.GetDataTable(cmd);
    }

    // ============================================================
    // Summary counts for summary strip
    // ============================================================
    public DataTable GetSubjectSummary(int userId, int instituteId, int sessionId)
    {
        SqlCommand cmd = new SqlCommand(@"
        WITH EnrolledSubjects AS (
            SELECT S.SubjectId
            FROM AssignStudentSubject ASS
            JOIN Subjects S ON ASS.SubjectId = S.SubjectId
            WHERE ASS.UserId      = @UserId
              AND ASS.InstituteId = @InstId
              AND ASS.SessionId   = @SessId
              AND S.IsActive      = 1
        ),
        ChapterCounts AS (
            SELECT CH.SubjectId, COUNT(*) AS Cnt
            FROM Chapters CH
            JOIN EnrolledSubjects ES ON CH.SubjectId = ES.SubjectId
            WHERE CH.InstituteId = @InstId
            GROUP BY CH.SubjectId
        ),
        VideoCounts AS (
            SELECT CH.SubjectId, COUNT(*) AS Cnt
            FROM Videos V
            JOIN Chapters CH ON V.ChapterId = CH.ChapterId
            JOIN EnrolledSubjects ES ON CH.SubjectId = ES.SubjectId
            WHERE V.InstituteId = @InstId AND V.IsActive = 1
            GROUP BY CH.SubjectId
        ),
        MaterialCounts AS (
            SELECT CH.SubjectId, COUNT(*) AS Cnt
            FROM Materials M
            JOIN Chapters CH ON M.ChapterId = CH.ChapterId
            JOIN EnrolledSubjects ES ON CH.SubjectId = ES.SubjectId
            WHERE M.InstituteId = @InstId
            GROUP BY CH.SubjectId
        )
        SELECT
            (SELECT COUNT(*) FROM EnrolledSubjects)           AS TotalSubjects,
            ISNULL((SELECT SUM(Cnt) FROM ChapterCounts),  0) AS TotalChapters,
            ISNULL((SELECT SUM(Cnt) FROM VideoCounts),    0) AS TotalVideos,
            ISNULL((SELECT SUM(Cnt) FROM MaterialCounts), 0) AS TotalMaterials");

        cmd.Parameters.AddWithValue("@UserId", userId);
        cmd.Parameters.AddWithValue("@InstId", instituteId);
        cmd.Parameters.AddWithValue("@SessId", sessionId);
        return dl.GetDataTable(cmd);
    }
}