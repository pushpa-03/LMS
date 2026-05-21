using System;
using System.Data;
using System.Data.SqlClient;


    public class VideoPlayerBL
    {
        private readonly DataLayer _dl = new DataLayer();

        // ══════════════════════════════════════════════════════════════════════
        //  VIDEO DETAILS  — includes UniqueStudentViews (students only, RoleId=4)
        // ══════════════════════════════════════════════════════════════════════
        public DataTable GetVideoDetails(int videoId, int sessionId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT
                    V.VideoId,
                    V.Title,
                    V.Description,
                    V.VideoPath,
                    V.ViewCount,
                    V.UploadedOn,
                    V.IsActive,
                    V.Duration,
                    ISNULL(UP.FullName, U.Username) AS InstructorName,
                    -- Only count STUDENT views (RoleId = 4), counted once per student
                    (SELECT COUNT(DISTINCT VV.UserId)
                     FROM VideoViews VV
                     INNER JOIN Users US ON VV.UserId = US.UserId
                     WHERE VV.VideoId    = V.VideoId
                       AND VV.SessionId = @SessionId
                       AND US.RoleId    = 4
                    ) AS UniqueStudentViews
                FROM Videos V
                LEFT JOIN Users       U  ON V.InstructorId = U.UserId
                LEFT JOIN UserProfile UP ON V.InstructorId = UP.UserId
                WHERE V.VideoId    = @Vid
                  AND V.SessionId  = @SessionId
                  AND V.IsActive   = 1");

            cmd.Parameters.AddWithValue("@Vid", videoId);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        // ══════════════════════════════════════════════════════════════════════
        //  RATING
        // ══════════════════════════════════════════════════════════════════════
        public DataRow GetRatingSummary(int videoId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT
                    ISNULL(AVG(CAST(Rating AS FLOAT)), 0) AS AvgRating,
                    COUNT(*)                               AS RatingCount
                FROM VideoRatings
                WHERE VideoId = @Vid AND Rating IS NOT NULL");
            cmd.Parameters.AddWithValue("@Vid", videoId);
            DataTable dt = _dl.GetDataTable(cmd);
            return (dt != null && dt.Rows.Count > 0) ? dt.Rows[0] : null;
        }

        public double GetAverageRating(int videoId)
        {
            DataRow r = GetRatingSummary(videoId);
            if (r == null) return 0;
            return r["AvgRating"] != DBNull.Value ? Convert.ToDouble(r["AvgRating"]) : 0;
        }

        // ══════════════════════════════════════════════════════════════════════
        //  TOPICS
        // ══════════════════════════════════════════════════════════════════════
        public DataTable GetVideoTopics(int videoId, int sessionId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT StartTime, TopicTitle
                FROM VideoTopics
                WHERE VideoId = @Vid AND SessionId = @SessionId
                ORDER BY StartTime");
            cmd.Parameters.AddWithValue("@Vid", videoId);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        // ══════════════════════════════════════════════════════════════════════
        //  PLAYLIST  — shows UniqueViews per video (student-only)
        // ══════════════════════════════════════════════════════════════════════
        public DataTable GetPlaylist(int videoId, int sessionId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT
                    V.VideoId,
                    V.Title,
                    V.ViewCount,
                    (SELECT COUNT(DISTINCT VV.UserId)
                     FROM VideoViews VV
                     INNER JOIN Users US ON VV.UserId = US.UserId
                     WHERE VV.VideoId   = V.VideoId
                       AND VV.SessionId = @SessionId
                       AND US.RoleId   = 4
                    ) AS UniqueViews
                FROM Videos V
                WHERE V.SessionId = @SessionId
                  AND V.IsActive  = 1
                  AND V.SubjectId = (
                        SELECT SubjectId FROM Videos WHERE VideoId = @Vid
                  )
                ORDER BY V.ChapterId, V.VideoId");
            cmd.Parameters.AddWithValue("@Vid", videoId);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        // ══════════════════════════════════════════════════════════════════════
        //  ENGAGEMENT — student watch progress (students only)
        // ══════════════════════════════════════════════════════════════════════
        public DataTable GetEngagement(int videoId, int sessionId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT
                    ISNULL(UP.FullName, U.Username)  AS UserName,
                    ISNULL(P.WatchedPercent, 0)       AS WatchedPercent
                FROM VideoViews VV
                INNER JOIN Users       U  ON VV.UserId = U.UserId
                LEFT  JOIN UserProfile UP ON VV.UserId = UP.UserId
                LEFT  JOIN VideoWatchProgress P
                    ON P.VideoId = VV.VideoId AND P.UserId = VV.UserId
                WHERE VV.VideoId   = @Vid
                  AND VV.SessionId = @SessionId
                  AND U.RoleId     = 4   -- Students only
                ORDER BY P.WatchedPercent DESC");
            cmd.Parameters.AddWithValue("@Vid", videoId);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        // ══════════════════════════════════════════════════════════════════════
        //  VIDEO STATS  — student-only view counts
        // ══════════════════════════════════════════════════════════════════════
        public DataTable GetVideoStats(int videoId, int sessionId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT
                    -- Total student view events (once per student, RoleId=4)
                    (SELECT COUNT(DISTINCT VV.UserId)
                     FROM VideoViews VV
                     INNER JOIN Users US ON VV.UserId = US.UserId
                     WHERE VV.VideoId   = @Vid
                       AND VV.SessionId = @SessionId
                       AND US.RoleId    = 4
                    ) AS StudentViews,

                    -- Unique students who viewed
                    (SELECT COUNT(DISTINCT VV.UserId)
                     FROM VideoViews VV
                     INNER JOIN Users US ON VV.UserId = US.UserId
                     WHERE VV.VideoId   = @Vid
                       AND VV.SessionId = @SessionId
                       AND US.RoleId    = 4
                    ) AS UniqueStudents,

                    -- Average completion % across ALL viewers
                    (SELECT ISNULL(AVG(WatchedPercent), 0)
                     FROM VideoWatchProgress
                     WHERE VideoId   = @Vid
                       AND SessionId = @SessionId
                    ) AS AvgCompletion,

                    -- Total comments (any role)
                    (SELECT COUNT(*)
                     FROM VideoComments
                     WHERE VideoId   = @Vid
                       AND SessionId = @SessionId
                    ) AS CommentCount");

            cmd.Parameters.AddWithValue("@Vid", videoId);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        // ══════════════════════════════════════════════════════════════════════
        //  AI USAGE STATS
        // ══════════════════════════════════════════════════════════════════════
        public DataTable GetAIUsageStats(int videoId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT Type, COUNT(*) AS UsageCount
                FROM VideoAIHistory
                WHERE VideoId = @Vid
                GROUP BY Type
                ORDER BY UsageCount DESC");
            cmd.Parameters.AddWithValue("@Vid", videoId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        // ══════════════════════════════════════════════════════════════════════
        //  COMMENTS  (top-level only — parent IS NULL)
        // ══════════════════════════════════════════════════════════════════════
        public DataTable GetComments(int videoId, int sessionId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT
                    C.CommentId,
                    U.Username,
                    C.Comment,
                    C.CommentedOn
                FROM VideoComments C
                INNER JOIN Users U ON C.UserId = U.UserId
                WHERE C.VideoId         = @Vid
                  AND C.SessionId       = @SessionId
                  AND C.ParentCommentId IS NULL
                ORDER BY C.CommentedOn DESC");
            cmd.Parameters.AddWithValue("@Vid", videoId);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        // ══════════════════════════════════════════════════════════════════════
        //  REPLIES  (child comments for a given parent)
        // ══════════════════════════════════════════════════════════════════════
        public DataTable GetReplies(int parentCommentId, int sessionId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT
                    C.CommentId,
                    U.Username,
                    C.Comment,
                    C.CommentedOn
                FROM VideoComments C
                INNER JOIN Users U ON C.UserId = U.UserId
                WHERE C.ParentCommentId = @ParentId
                  AND C.SessionId       = @SessionId
                ORDER BY C.CommentedOn ASC");
            cmd.Parameters.AddWithValue("@ParentId", parentCommentId);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        // ══════════════════════════════════════════════════════════════════════
        //  SAVE COMMENT / REPLY
        //  parentCommentId = null  → top-level comment
        //  parentCommentId = int   → reply
        // ══════════════════════════════════════════════════════════════════════
        public void SaveComment(int videoId, int sessionId, int userId,
            string comment, int societyId, int instituteId, int? parentCommentId)
        {
            if (string.IsNullOrWhiteSpace(comment)) return;

            SqlCommand cmd = new SqlCommand(@"
                INSERT INTO VideoComments
                    (SocietyId, InstituteId, VideoId, UserId, Comment,
                     SessionId, CommentedOn, ParentCommentId)
                VALUES
                    (@SocId, @InstId, @Vid, @UserId, @Comment,
                     @SessionId, GETDATE(), @ParentId)");

            cmd.Parameters.AddWithValue("@SocId", societyId);
            cmd.Parameters.AddWithValue("@InstId", instituteId);
            cmd.Parameters.AddWithValue("@Vid", videoId);
            cmd.Parameters.AddWithValue("@UserId", userId);
            cmd.Parameters.AddWithValue("@Comment", comment.Trim());
            cmd.Parameters.AddWithValue("@SessionId", sessionId);
            cmd.Parameters.AddWithValue("@ParentId",
                parentCommentId.HasValue ? (object)parentCommentId.Value : DBNull.Value);
            _dl.ExecuteCMD(cmd);
        }

        // ══════════════════════════════════════════════════════════════════════
        //  DELETE COMMENT  (hard delete — also removes replies via cascade)
        //  NOTE: Add ON DELETE CASCADE to FK_VideoComments_ParentCommentId in DB,
        //        OR use the soft-delete approach below which handles both.
        // ══════════════════════════════════════════════════════════════════════
        public void DeleteComment(int commentId, int sessionId)
        {
            // Delete replies first, then parent (handles DB without cascade)
            SqlCommand delReplies = new SqlCommand(@"
                DELETE FROM VideoComments
                WHERE ParentCommentId = @Id AND SessionId = @SessionId");
            delReplies.Parameters.AddWithValue("@Id", commentId);
            delReplies.Parameters.AddWithValue("@SessionId", sessionId);
            _dl.ExecuteCMD(delReplies);

            SqlCommand delParent = new SqlCommand(@"
                DELETE FROM VideoComments
                WHERE CommentId = @Id AND SessionId = @SessionId");
            delParent.Parameters.AddWithValue("@Id", commentId);
            delParent.Parameters.AddWithValue("@SessionId", sessionId);
            _dl.ExecuteCMD(delParent);
        }

        // ══════════════════════════════════════════════════════════════════════
        //  TRACK STUDENT VIEW  — once per student per video (RoleId=4 check in CS)
        // ══════════════════════════════════════════════════════════════════════
        public void TrackStudentView(int videoId, int sessionId, int userId,
            int societyId, int instituteId)
        {
            SqlCommand cmd = new SqlCommand(@"
                IF NOT EXISTS (
                    SELECT 1 FROM VideoViews
                    WHERE VideoId = @Vid AND UserId = @UserId AND SessionId = @SessionId
                )
                BEGIN
                    INSERT INTO VideoViews
                        (SocietyId, InstituteId, SessionId, VideoId, UserId, ViewedOn, IsCompleted)
                    VALUES
                        (@SocId, @InstId, @SessionId, @Vid, @UserId, GETDATE(), 0);
                END");

            cmd.Parameters.AddWithValue("@Vid", videoId);
            cmd.Parameters.AddWithValue("@UserId", userId);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);
            cmd.Parameters.AddWithValue("@SocId", societyId);
            cmd.Parameters.AddWithValue("@InstId", instituteId);
            _dl.ExecuteCMD(cmd);
        }

        // ══════════════════════════════════════════════════════════════════════
        //  UPSERT WATCH PROGRESS  — called every 10s from JS
        //  Progress bar logic:
        //    - Updated on every call with current watched seconds
        //    - IsCompleted set to 1 only when pct >= 100
        //    - Student skip-lock: student side checks IsCompleted before allowing seek
        // ══════════════════════════════════════════════════════════════════════
        public void UpsertWatchProgress(int videoId, int sessionId, int userId,
            int societyId, int instituteId,
            int watchedSeconds, int videoDuration, int watchedPercent, int lastPosition)
        {
            SqlCommand cmd = new SqlCommand(@"
                IF EXISTS (
                    SELECT 1 FROM VideoWatchProgress
                    WHERE UserId = @UserId AND VideoId = @Vid
                )
                BEGIN
                    UPDATE VideoWatchProgress
                    SET
                        WatchedSeconds = CASE WHEN @WatchedSec > WatchedSeconds
                                              THEN @WatchedSec ELSE WatchedSeconds END,
                        VideoDuration  = @Duration,
                        WatchedPercent = CASE WHEN @Pct > WatchedPercent
                                              THEN @Pct ELSE WatchedPercent END,
                        LastPosition   = @LastPos,
                        UpdatedOn      = GETDATE()
                    WHERE UserId = @UserId AND VideoId = @Vid;
                END
                ELSE
                BEGIN
                    INSERT INTO VideoWatchProgress
                        (SocietyId, InstituteId, SessionId, VideoId, UserId,
                         WatchedSeconds, VideoDuration, WatchedPercent, LastPosition, UpdatedOn)
                    VALUES
                        (@SocId, @InstId, @SessionId, @Vid, @UserId,
                         @WatchedSec, @Duration, @Pct, @LastPos, GETDATE());
                END

                -- Mark completed in VideoViews when 100%
                IF @Pct >= 100
                BEGIN
                    UPDATE VideoViews
                    SET IsCompleted = 1
                    WHERE VideoId = @Vid AND UserId = @UserId AND SessionId = @SessionId;
                END");

            cmd.Parameters.AddWithValue("@Vid", videoId);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);
            cmd.Parameters.AddWithValue("@UserId", userId);
            cmd.Parameters.AddWithValue("@SocId", societyId);
            cmd.Parameters.AddWithValue("@InstId", instituteId);
            cmd.Parameters.AddWithValue("@WatchedSec", watchedSeconds);
            cmd.Parameters.AddWithValue("@Duration", videoDuration);
            cmd.Parameters.AddWithValue("@Pct", watchedPercent);
            cmd.Parameters.AddWithValue("@LastPos", lastPosition);
            _dl.ExecuteCMD(cmd);
        }

        // ══════════════════════════════════════════════════════════════════════
        //  CHECK COMPLETION  — used by student side to allow/block seeking
        // ══════════════════════════════════════════════════════════════════════
        public bool HasStudentCompletedVideo(int videoId, int userId, int sessionId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT COUNT(*)
                FROM VideoViews
                WHERE VideoId   = @Vid
                  AND UserId    = @UserId
                  AND SessionId = @SessionId
                  AND IsCompleted = 1");
            cmd.Parameters.AddWithValue("@Vid", videoId);
            cmd.Parameters.AddWithValue("@UserId", userId);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);
            DataTable dt = _dl.GetDataTable(cmd);
            return dt != null && dt.Rows.Count > 0 && Convert.ToInt32(dt.Rows[0][0]) > 0;
        }

        // ══════════════════════════════════════════════════════════════════════
        //  NAVIGATION
        // ══════════════════════════════════════════════════════════════════════
        public int GetNextVideo(int videoId, int sessionId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT TOP 1 VideoId
                FROM Videos
                WHERE VideoId  > @Vid
                  AND SessionId = @SessionId
                  AND IsActive  = 1
                  AND SubjectId = (SELECT SubjectId FROM Videos WHERE VideoId = @Vid)
                ORDER BY VideoId ASC");
            cmd.Parameters.AddWithValue("@Vid", videoId);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);
            DataTable dt = _dl.GetDataTable(cmd);
            return (dt != null && dt.Rows.Count > 0) ? Convert.ToInt32(dt.Rows[0][0]) : 0;
        }

        public int GetPrevVideo(int videoId, int sessionId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT TOP 1 VideoId
                FROM Videos
                WHERE VideoId  < @Vid
                  AND SessionId = @SessionId
                  AND IsActive  = 1
                  AND SubjectId = (SELECT SubjectId FROM Videos WHERE VideoId = @Vid)
                ORDER BY VideoId DESC");
            cmd.Parameters.AddWithValue("@Vid", videoId);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);
            DataTable dt = _dl.GetDataTable(cmd);
            return (dt != null && dt.Rows.Count > 0) ? Convert.ToInt32(dt.Rows[0][0]) : 0;
        }

        // ══════════════════════════════════════════════════════════════════════
        //  USER DISPLAY NAME
        // ══════════════════════════════════════════════════════════════════════
        public DataRow GetUserDisplayName(int userId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT ISNULL(FullName, 'Admin') AS FullName
                FROM UserProfile
                WHERE UserId = @UserId");
            cmd.Parameters.AddWithValue("@UserId", userId);
            DataTable dt = _dl.GetDataTable(cmd);
            return (dt != null && dt.Rows.Count > 0) ? dt.Rows[0] : null;
        }

        // ══════════════════════════════════════════════════════════════════════
        //  AI HISTORY
        // ══════════════════════════════════════════════════════════════════════
        public void SaveAIHistory(int videoId, int userId, string type,
            string question, string response)
        {
            try
            {
                SqlCommand cmd = new SqlCommand(@"
                    INSERT INTO VideoAIHistory
                        (VideoId, UserId, Type, Question, Response, CreatedOn)
                    VALUES
                        (@Vid, @UserId, @Type, @Q, @R, GETDATE())");
                cmd.Parameters.AddWithValue("@Vid", videoId);
                cmd.Parameters.AddWithValue("@UserId", userId);
                cmd.Parameters.AddWithValue("@Type", type);
                cmd.Parameters.AddWithValue("@Q", question ?? "");
                cmd.Parameters.AddWithValue("@R", response ?? "");
                _dl.ExecuteCMD(cmd);
            }
            catch { /* Non-critical */ }
        }

        // ══════════════════════════════════════════════════════════════════════
        //  ACTIVITY LOG
        // ══════════════════════════════════════════════════════════════════════
        public void LogActivity(int userId, int societyId, int instituteId,
            int sessionId, string activityType, int referenceId = 0)
        {
            try
            {
                SqlCommand cmd = new SqlCommand(@"
                    INSERT INTO UserActivityLog
                        (UserId, SocietyId, InstituteId, SessionId,
                         ActivityType, ReferenceId, ActionTime)
                    VALUES
                        (@UserId, @SocId, @InstId, @SessionId,
                         @Activity, @RefId, GETDATE())");
                cmd.Parameters.AddWithValue("@UserId", userId);
                cmd.Parameters.AddWithValue("@SocId", societyId);
                cmd.Parameters.AddWithValue("@InstId", instituteId);
                cmd.Parameters.AddWithValue("@SessionId", sessionId);
                cmd.Parameters.AddWithValue("@Activity", activityType);
                cmd.Parameters.AddWithValue("@RefId", referenceId);
                _dl.ExecuteCMD(cmd);
            }
            catch { }
        }
   
    public void SaveCommentWithoutReply(int vid, int sessionId, int userId, string msg, int societyId, int instituteId)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = @"INSERT INTO VideoComments
        (SocietyId, InstituteId, VideoId, UserId, Comment, SessionId)
        VALUES
        (@SocietyId, @InstituteId, @VideoId, @UserId, @Comment, @SessionId)";

        cmd.Parameters.AddWithValue("@SocietyId", societyId);
        cmd.Parameters.AddWithValue("@InstituteId", instituteId);
        cmd.Parameters.AddWithValue("@VideoId", vid);
        cmd.Parameters.AddWithValue("@UserId", userId);
        cmd.Parameters.AddWithValue("@Comment", msg);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);

        new DataLayer().ExecuteCMD(cmd);
    }


    //used in progressTracker page

    // ═════════════════════════════════════════════════════════════════════=
    //  PROGRESS AGGREGATION
    //  - Subject level: average completion across videos in subject for a user
    //  - Chapter level: average completion across videos in chapter
    //  - Video level: individual video progress rows
    // ═════════════════════════════════════════════════════════════════════=
    public DataTable GetSubjectProgress(int userId, int sessionId)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT
                S.SubjectId,
                S.SubjectName,
                ISNULL(ROUND(AVG(CAST(ISNULL(P.WatchedPercent,0) AS FLOAT)),0),0) AS CompletionPercent,
                COUNT(DISTINCT V.VideoId) AS TotalVideos,
                SUM(CASE WHEN ISNULL(P.WatchedPercent,0) >= 100 THEN 1 ELSE 0 END) AS CompletedVideos
            FROM Subjects S
            INNER JOIN Videos V ON V.SubjectId = S.SubjectId AND V.SessionId = @SessionId AND V.IsActive = 1
            LEFT JOIN VideoWatchProgress P ON P.VideoId = V.VideoId AND P.UserId = @UserId
            GROUP BY S.SubjectId, S.SubjectName
            ORDER BY S.SubjectName");

        cmd.Parameters.AddWithValue("@UserId", userId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);
        return _dl.GetDataTable(cmd) ?? new DataTable();
    }

    public DataTable GetChapterProgress(int subjectId, int userId, int sessionId)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT
                C.ChapterId,
                C.ChapterName,
                ISNULL(ROUND(AVG(CAST(ISNULL(P.WatchedPercent,0) AS FLOAT)),0),0) AS CompletionPercent,
                COUNT(DISTINCT V.VideoId) AS TotalVideos,
                SUM(CASE WHEN ISNULL(P.WatchedPercent,0) >= 100 THEN 1 ELSE 0 END) AS CompletedVideos
            FROM Chapters C
            INNER JOIN Videos V ON V.ChapterId = C.ChapterId AND V.SessionId = @SessionId AND V.IsActive = 1
            LEFT JOIN VideoWatchProgress P ON P.VideoId = V.VideoId AND P.UserId = @UserId
            WHERE V.SubjectId = @SubjectId
            GROUP BY C.ChapterId, C.ChapterName
            ORDER BY C.ChapterName");

        cmd.Parameters.AddWithValue("@SubjectId", subjectId);
        cmd.Parameters.AddWithValue("@UserId", userId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);
        return _dl.GetDataTable(cmd) ?? new DataTable();
    }

    public DataTable GetVideoProgressByChapter(int chapterId, int userId, int sessionId)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT
                V.VideoId,
                V.Title,
                ISNULL(P.WatchedPercent, 0) AS WatchedPercent,
                CASE WHEN ISNULL(P.WatchedPercent,0) >= 100 OR ISNULL(VV.IsCompleted,0)=1 THEN 1 ELSE 0 END AS IsCompleted
            FROM Videos V
            LEFT JOIN VideoWatchProgress P ON P.VideoId = V.VideoId AND P.UserId = @UserId
            LEFT JOIN VideoViews VV ON VV.VideoId = V.VideoId AND VV.UserId = @UserId
            WHERE V.ChapterId = @ChapterId AND V.SessionId = @SessionId AND V.IsActive = 1
            ORDER BY V.VideoId");

        cmd.Parameters.AddWithValue("@ChapterId", chapterId);
        cmd.Parameters.AddWithValue("@UserId", userId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);
        return _dl.GetDataTable(cmd) ?? new DataTable();
    }
}
