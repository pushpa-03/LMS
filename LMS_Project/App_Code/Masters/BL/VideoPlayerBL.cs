using System;
using System.Data;
using System.Data.SqlClient;

    public class VideoPlayerBL
    {
        private readonly DataLayer _dl = new DataLayer();

        // ── Video Details ──────────────────────────────────────────────────────
        public DataTable GetVideoDetails(int videoId, int sessionId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT
                    V.VideoId, V.Title, V.Description, V.VideoPath,
                    V.ViewCount, V.UploadedOn, V.IsActive, V.Duration,
                    ISNULL(UP.FullName, U.Username) AS InstructorName
                FROM Videos V
                LEFT JOIN Users       U  ON V.InstructorId = U.UserId
                LEFT JOIN UserProfile UP ON V.InstructorId = UP.UserId
                WHERE V.VideoId = @Vid AND V.SessionId = @SessionId AND V.IsActive = 1");
            cmd.Parameters.AddWithValue("@Vid", videoId);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        public double GetAverageRating(int videoId)
        {
            // 1. Create the Command
            SqlCommand cmd = new SqlCommand("SELECT ISNULL(AVG(CAST(Rating AS FLOAT)), 4.5) AS AvgRating FROM VideoRatings WHERE VideoId = @vid");
            cmd.Parameters.AddWithValue("@vid", videoId);

            // 2. Use GetDataTable from your DataLayer
            DataTable dt = _dl.GetDataTable(cmd);

            // 3. Extract the value safely
            if (dt != null && dt.Rows.Count > 0)
            {
                return Convert.ToDouble(dt.Rows[0]["AvgRating"]);
            }

            return 4.5; // Default fallback if something goes wrong
        }

    // ── Rating Summary ─────────────────────────────────────────────────────
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

        // ── Topics ─────────────────────────────────────────────────────────────
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

        // ── Playlist (same subject) ────────────────────────────────────────────
        public DataTable GetPlaylist(int videoId, int sessionId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT V.VideoId, V.Title, V.ViewCount
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

        // ── Student engagement (watch progress) ────────────────────────────────
        public DataTable GetEngagement(int videoId, int sessionId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT
                    ISNULL(UP.FullName, U.Username) AS UserName,
                    ISNULL(P.WatchedPercent, 0)      AS WatchedPercent
                FROM VideoViews VV
                INNER JOIN Users       U  ON VV.UserId = U.UserId
                LEFT  JOIN UserProfile UP ON VV.UserId = UP.UserId
                LEFT  JOIN VideoWatchProgress P
                    ON P.VideoId = VV.VideoId AND P.UserId = VV.UserId
                WHERE VV.VideoId = @Vid AND VV.SessionId = @SessionId
                ORDER BY P.WatchedPercent DESC");
            cmd.Parameters.AddWithValue("@Vid", videoId);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        // ── AI usage stats ─────────────────────────────────────────────────────
        public DataTable GetAIUsageStats(int videoId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT
                    Type,
                    COUNT(*) AS UsageCount
                FROM VideoAIHistory
                WHERE VideoId = @Vid
                GROUP BY Type
                ORDER BY UsageCount DESC");
            cmd.Parameters.AddWithValue("@Vid", videoId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        // ── Video stats ────────────────────────────────────────────────────────
        public DataTable GetVideoStats(int videoId, int sessionId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT
                    (SELECT COUNT(*)         FROM VideoViews        WHERE VideoId=@Vid AND SessionId=@SessionId) AS Views,
                    (SELECT COUNT(DISTINCT UserId) FROM VideoViews  WHERE VideoId=@Vid AND SessionId=@SessionId) AS Students,
                    (SELECT ISNULL(AVG(WatchedPercent),0) FROM VideoWatchProgress WHERE VideoId=@Vid AND SessionId=@SessionId) AS Completion,
                    (SELECT COUNT(*)         FROM VideoComments      WHERE VideoId=@Vid AND SessionId=@SessionId) AS Comments");
            cmd.Parameters.AddWithValue("@Vid", videoId);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        // ── Comments ──────────────────────────────────────────────────────────
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
                WHERE C.VideoId = @Vid AND C.SessionId = @SessionId
                ORDER BY C.CommentedOn DESC");
            cmd.Parameters.AddWithValue("@Vid", videoId);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        public void SaveComment(int videoId, int sessionId, int userId,
            string comment, int societyId, int instituteId)
        {
            if (string.IsNullOrWhiteSpace(comment)) return;
            SqlCommand cmd = new SqlCommand(@"
                INSERT INTO VideoComments
                    (SocietyId, InstituteId, VideoId, UserId, Comment, SessionId, CommentedOn)
                VALUES
                    (@SocId, @InstId, @Vid, @UserId, @Comment, @SessionId, GETDATE())");
            cmd.Parameters.AddWithValue("@SocId", societyId);
            cmd.Parameters.AddWithValue("@InstId", instituteId);
            cmd.Parameters.AddWithValue("@Vid", videoId);
            cmd.Parameters.AddWithValue("@UserId", userId);
            cmd.Parameters.AddWithValue("@Comment", comment);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);
            _dl.ExecuteCMD(cmd);
        }

        public void DeleteComment(int commentId, int sessionId)
        {
            SqlCommand cmd = new SqlCommand(
                "DELETE FROM VideoComments WHERE CommentId = @Id AND SessionId = @SessionId");
            cmd.Parameters.AddWithValue("@Id", commentId);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);
            _dl.ExecuteCMD(cmd);
        }

        // ── Track view (once per user per video per session) ───────────────────
        public void TrackView(int videoId, int sessionId, int userId, int instituteId, int societyId)
        {
            SqlCommand cmd = new SqlCommand(@"
                IF NOT EXISTS (
                    SELECT 1 FROM VideoViews
                    WHERE VideoId=@Vid AND UserId=@UserId AND SessionId=@SessionId
                )
                BEGIN
                    INSERT INTO VideoViews (SocietyId, InstituteId, SessionId, VideoId, UserId, ViewedOn, IsCompleted)
                    VALUES (@SocId, @InstId, @SessionId, @Vid, @UserId, GETDATE(), 0);
                END

                UPDATE Videos
                SET ViewCount = ISNULL(ViewCount, 0) + 1
                WHERE VideoId = @Vid AND SessionId = @SessionId;");

            cmd.Parameters.AddWithValue("@Vid", videoId);
            cmd.Parameters.AddWithValue("@UserId", userId);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);
            cmd.Parameters.AddWithValue("@InstId", instituteId);
            cmd.Parameters.AddWithValue("@SocId", societyId);
            _dl.ExecuteCMD(cmd);
        }

        // ── Upsert watch progress (called from AJAX every 10s) ────────────────
        public void UpsertWatchProgress(int videoId, int sessionId, int userId,
            int societyId, int instituteId,
            int watchedSeconds, int videoDuration, int watchedPercent, int lastPosition)
        {
            SqlCommand cmd = new SqlCommand(@"
                IF EXISTS (SELECT 1 FROM VideoWatchProgress WHERE UserId=@UserId AND VideoId=@Vid)
                BEGIN
                    UPDATE VideoWatchProgress
                    SET WatchedSeconds  = @WatchedSec,
                        VideoDuration   = @Duration,
                        WatchedPercent  = @Pct,
                        LastPosition    = @LastPos,
                        UpdatedOn       = GETDATE()
                    WHERE UserId=@UserId AND VideoId=@Vid;
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

                -- Mark as completed in VideoViews if 100%
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

    public void IncreaseViewCount(int videoId, int sessionId, int userId, int instituteId)
    {
        SqlCommand cmd = new SqlCommand(@"
                INSERT INTO VideoViews(VideoId,SessionId,UserId,InstituteId)
                VALUES(@VideoId,@SessionId,@UserId,@InstituteId)");

        cmd.Parameters.AddWithValue("@VideoId", videoId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);
        cmd.Parameters.AddWithValue("@UserId", userId);
        cmd.Parameters.AddWithValue("@InstituteId", instituteId);

        _dl.ExecuteCMD(cmd);
    }

    // ── Navigation ─────────────────────────────────────────────────────────
    public int GetNextVideo(int videoId, int sessionId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT TOP 1 VideoId
                FROM Videos
                WHERE VideoId > @Vid
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
                WHERE VideoId < @Vid
                  AND SessionId = @SessionId
                  AND IsActive  = 1
                  AND SubjectId = (SELECT SubjectId FROM Videos WHERE VideoId = @Vid)
                ORDER BY VideoId DESC");
            cmd.Parameters.AddWithValue("@Vid", videoId);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);
            DataTable dt = _dl.GetDataTable(cmd);
            return (dt != null && dt.Rows.Count > 0) ? Convert.ToInt32(dt.Rows[0][0]) : 0;
        }

        // ── Check if student has completed the video (for skip-lock) ──────────
        public bool HasStudentCompletedVideo(int videoId, int userId, int sessionId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT COUNT(*)
                FROM VideoViews
                WHERE VideoId = @Vid AND UserId = @UserId
                  AND SessionId = @SessionId AND IsCompleted = 1");
            cmd.Parameters.AddWithValue("@Vid", videoId);
            cmd.Parameters.AddWithValue("@UserId", userId);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);
            DataTable dt = _dl.GetDataTable(cmd);
            return (dt != null && dt.Rows.Count > 0) && Convert.ToInt32(dt.Rows[0][0]) > 0;
        }

        // ── User display name ──────────────────────────────────────────────────
        public DataRow GetUserDisplayName(int userId)
        {
            SqlCommand cmd = new SqlCommand(
                "SELECT ISNULL(FullName, 'Admin') AS FullName FROM UserProfile WHERE UserId = @UserId");
            cmd.Parameters.AddWithValue("@UserId", userId);
            DataTable dt = _dl.GetDataTable(cmd);
            return (dt != null && dt.Rows.Count > 0) ? dt.Rows[0] : null;
        }

        // ── Save AI history (called from FastAPI proxy) ────────────────────────
        public void SaveAIHistory(int videoId, int userId, string type,
            string question, string response)
        {
            try
            {
                SqlCommand cmd = new SqlCommand(@"
                    INSERT INTO VideoAIHistory (VideoId, UserId, Type, Question, Response, CreatedOn)
                    VALUES (@Vid, @UserId, @Type, @Q, @R, GETDATE())");
                cmd.Parameters.AddWithValue("@Vid", videoId);
                cmd.Parameters.AddWithValue("@UserId", userId);
                cmd.Parameters.AddWithValue("@Type", type);
                cmd.Parameters.AddWithValue("@Q", question ?? "");
                cmd.Parameters.AddWithValue("@R", response ?? "");
                _dl.ExecuteCMD(cmd);
            }
            catch { /* Non-critical */ }
        }

        // ── Activity log ───────────────────────────────────────────────────────
        public void LogActivity(int userId, int societyId, int instituteId,
            int sessionId, string activityType, int referenceId = 0)
        {
            try
            {
                SqlCommand cmd = new SqlCommand(@"
                    INSERT INTO UserActivityLog
                        (UserId, SocietyId, InstituteId, SessionId, ActivityType, ReferenceId, ActionTime)
                    VALUES
                        (@UserId, @SocId, @InstId, @SessionId, @Activity, @RefId, GETDATE())");
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
    }
