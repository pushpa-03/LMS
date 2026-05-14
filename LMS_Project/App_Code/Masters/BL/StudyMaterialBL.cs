//using System;
//using System.Collections.Generic;
//using System.Data;
//using System.Data.SqlClient;

//public class StudyMaterialBL
//{
//    private readonly DataLayer _dl = new DataLayer();

//    // ══════════════════════════════════════════════════════════════════════
//    //  VIDEO TOPICS
//    //  Called from UpdatePanel postback when student clicks a video.
//    // ══════════════════════════════════════════════════════════════════════
//    public DataTable GetVideoTopics(int videoId)
//    {
//        var cmd = new SqlCommand(@"
//            SELECT StartTime, TopicTitle
//            FROM   VideoTopics
//            WHERE  VideoId = @VideoId
//            ORDER  BY StartTime");
//        cmd.Parameters.AddWithValue("@VideoId", videoId);
//        return _dl.GetDataTable(cmd) ?? new DataTable();
//    }

//    // ══════════════════════════════════════════════════════════════════════
//    //  TRACK VIEW
//    //  Called after student watches > 10 seconds.
//    //  Inserts one row per student per video per session (UPSERT style).
//    //  Increments ViewCount on Videos table each call.
//    // ══════════════════════════════════════════════════════════════════════
//    public void TrackView(int videoId, int sessionId, int userId,
//        int societyId, int instituteId)
//    {
//        var cmds = new List<SqlCommand>();

//        // 1. Upsert StudentVideoViews (unique student tracking)
//        var viewCmd = new SqlCommand(@"
//            IF NOT EXISTS (
//                SELECT 1 FROM StudentVideoViews
//                WHERE  VideoId=@Vid AND SessionId=@Sess AND UserId=@Uid
//            )
//            BEGIN
//                INSERT INTO StudentVideoViews
//                    (VideoId, SessionId, UserId, SocietyId, InstituteId, ViewedOn)
//                VALUES
//                    (@Vid, @Sess, @Uid, @SocId, @InstId, GETDATE())
//            END");
//        viewCmd.Parameters.AddWithValue("@Vid", videoId);
//        viewCmd.Parameters.AddWithValue("@Sess", sessionId);
//        viewCmd.Parameters.AddWithValue("@Uid", userId);
//        viewCmd.Parameters.AddWithValue("@SocId", societyId);
//        viewCmd.Parameters.AddWithValue("@InstId", instituteId);
//        cmds.Add(viewCmd);

//        // 2. Increment total ViewCount on Videos
//        var incCmd = new SqlCommand(@"
//            UPDATE Videos
//            SET    ViewCount = ISNULL(ViewCount, 0) + 1
//            WHERE  VideoId   = @Vid");
//        incCmd.Parameters.AddWithValue("@Vid", videoId);
//        cmds.Add(incCmd);

//        _dl.ExecuteTransaction(cmds);
//    }

//    // ══════════════════════════════════════════════════════════════════════
//    //  SAVE WATCH PROGRESS
//    //  Called every 15 s while video is playing.
//    //  Upserts StudentWatchProgress — stores last position + max % reached.
//    // ══════════════════════════════════════════════════════════════════════
//    public void SaveWatchProgress(int videoId, int sessionId, int userId,
//        int position, int percentage, bool isCompleted)
//    {
//        var cmd = new SqlCommand(@"
//            IF EXISTS (
//                SELECT 1 FROM StudentWatchProgress
//                WHERE  VideoId=@Vid AND SessionId=@Sess AND UserId=@Uid
//            )
//            BEGIN
//                UPDATE StudentWatchProgress
//                SET    LastPosition  = @Pos,
//                       MaxPercentage = CASE WHEN @Pct > MaxPercentage
//                                            THEN @Pct
//                                            ELSE MaxPercentage END,
//                       IsCompleted   = CASE WHEN @Done=1 THEN 1 ELSE IsCompleted END,
//                       UpdatedOn     = GETDATE()
//                WHERE  VideoId=@Vid AND SessionId=@Sess AND UserId=@Uid
//            END
//            ELSE
//            BEGIN
//                INSERT INTO StudentWatchProgress
//                    (VideoId, SessionId, UserId,
//                     LastPosition, MaxPercentage, IsCompleted,
//                     StartedOn, UpdatedOn)
//                VALUES
//                    (@Vid, @Sess, @Uid,
//                     @Pos, @Pct, @Done,
//                     GETDATE(), GETDATE())
//            END");

//        cmd.Parameters.AddWithValue("@Vid", videoId);
//        cmd.Parameters.AddWithValue("@Sess", sessionId);
//        cmd.Parameters.AddWithValue("@Uid", userId);
//        cmd.Parameters.AddWithValue("@Pos", position);
//        cmd.Parameters.AddWithValue("@Pct", percentage);
//        cmd.Parameters.AddWithValue("@Done", isCompleted ? 1 : 0);
//        _dl.ExecuteCMD(cmd);
//    }

//    // ══════════════════════════════════════════════════════════════════════
//    //  MARK VIDEO COMPLETE
//    //  Sets IsCompleted=1 and MaxPercentage=100.
//    //  Called when student reaches 95 %+ of the video.
//    // ══════════════════════════════════════════════════════════════════════
//    public void MarkVideoComplete(int videoId, int sessionId, int userId)
//    {
//        var cmd = new SqlCommand(@"
//            IF EXISTS (
//                SELECT 1 FROM StudentWatchProgress
//                WHERE  VideoId=@Vid AND SessionId=@Sess AND UserId=@Uid
//            )
//            BEGIN
//                UPDATE StudentWatchProgress
//                SET    IsCompleted   = 1,
//                       MaxPercentage = 100,
//                       UpdatedOn     = GETDATE()
//                WHERE  VideoId=@Vid AND SessionId=@Sess AND UserId=@Uid
//            END
//            ELSE
//            BEGIN
//                INSERT INTO StudentWatchProgress
//                    (VideoId, SessionId, UserId,
//                     LastPosition, MaxPercentage, IsCompleted,
//                     StartedOn, UpdatedOn)
//                VALUES
//                    (@Vid, @Sess, @Uid,
//                     0, 100, 1,
//                     GETDATE(), GETDATE())
//            END");

//        cmd.Parameters.AddWithValue("@Vid", videoId);
//        cmd.Parameters.AddWithValue("@Sess", sessionId);
//        cmd.Parameters.AddWithValue("@Uid", userId);
//        _dl.ExecuteCMD(cmd);
//    }

//    // ══════════════════════════════════════════════════════════════════════
//    //  GET VIDEO STATUS
//    //  Returns IsCompleted + LastPosition so JS can:
//    //    a) Allow skip if already completed
//    //    b) Resume from last position
//    // ══════════════════════════════════════════════════════════════════════
//    public object GetVideoStatus(int videoId, int sessionId, int userId)
//    {
//        var cmd = new SqlCommand(@"
//            SELECT TOP 1
//                ISNULL(IsCompleted,   0) AS IsCompleted,
//                ISNULL(LastPosition,  0) AS LastPosition,
//                ISNULL(MaxPercentage, 0) AS MaxPercentage
//            FROM StudentWatchProgress
//            WHERE VideoId=@Vid AND SessionId=@Sess AND UserId=@Uid");
//        cmd.Parameters.AddWithValue("@Vid", videoId);
//        cmd.Parameters.AddWithValue("@Sess", sessionId);
//        cmd.Parameters.AddWithValue("@Uid", userId);

//        DataTable dt = _dl.GetDataTable(cmd);
//        if (dt == null || dt.Rows.Count == 0)
//            return new { IsCompleted = false, LastPosition = 0, MaxPercentage = 0 };

//        DataRow r = dt.Rows[0];
//        return new
//        {
//            IsCompleted = Convert.ToBoolean(r["IsCompleted"]),
//            LastPosition = Convert.ToInt32(r["LastPosition"]),
//            MaxPercentage = Convert.ToInt32(r["MaxPercentage"])
//        };
//    }

//    // ══════════════════════════════════════════════════════════════════════
//    //  GET VIDEO STATS
//    //  TotalViews  = total view-count from Videos.ViewCount
//    //  UniqueStudents = distinct students who have watched (StudentVideoViews)
//    // ══════════════════════════════════════════════════════════════════════
//    public object GetVideoStats(int videoId, int sessionId)
//    {
//        var cmd = new SqlCommand(@"
//            SELECT
//                ISNULL(V.ViewCount, 0)                        AS TotalViews,
//                (SELECT COUNT(DISTINCT UserId)
//                 FROM   StudentVideoViews
//                 WHERE  VideoId=@Vid AND SessionId=@Sess)      AS UniqueStudents,
//                (SELECT COUNT(*)
//                 FROM   StudentWatchProgress
//                 WHERE  VideoId=@Vid AND SessionId=@Sess
//                   AND  IsCompleted=1)                         AS CompletedCount
//            FROM Videos V
//            WHERE V.VideoId = @Vid");
//        cmd.Parameters.AddWithValue("@Vid", videoId);
//        cmd.Parameters.AddWithValue("@Sess", sessionId);

//        DataTable dt = _dl.GetDataTable(cmd);
//        if (dt == null || dt.Rows.Count == 0)
//            return new { TotalViews = 0, UniqueStudents = 0, CompletedCount = 0 };

//        DataRow r = dt.Rows[0];
//        return new
//        {
//            TotalViews = Convert.ToInt32(r["TotalViews"]),
//            UniqueStudents = Convert.ToInt32(r["UniqueStudents"]),
//            CompletedCount = Convert.ToInt32(r["CompletedCount"])
//        };
//    }

//    // ══════════════════════════════════════════════════════════════════════
//    //  GET PROGRESS
//    //  Returns full progress breakdown:
//    //    • WatchedCount / TotalCount (videos)
//    //    • CompletedChapters / TotalChapters
//    //    • Per-chapter: ChapterId, ChapterName, WatchedVideos, TotalVideos, Pct
//    //    • CompletedVideoIds list (to mark ✓ in left panel)
//    // ══════════════════════════════════════════════════════════════════════
//    public object GetProgress(int subjectId, int sessionId, int userId)
//    {
//        // Overall video counts
//        var overallCmd = new SqlCommand(@"
//            SELECT
//                COUNT(V.VideoId) AS TotalVideos,
//                SUM(CASE WHEN WP.IsCompleted=1 THEN 1 ELSE 0 END) AS WatchedCount
//            FROM   Chapters C
//            INNER JOIN Videos V ON V.ChapterId=C.ChapterId AND V.IsActive=1
//            LEFT  JOIN StudentWatchProgress WP
//                ON WP.VideoId=V.VideoId AND WP.SessionId=@Sess AND WP.UserId=@Uid
//            WHERE  C.SubjectId=@SubId AND C.SessionId=@Sess AND C.IsActive=1");
//        overallCmd.Parameters.AddWithValue("@SubId", subjectId);
//        overallCmd.Parameters.AddWithValue("@Sess", sessionId);
//        overallCmd.Parameters.AddWithValue("@Uid", userId);
//        DataTable dtOver = _dl.GetDataTable(overallCmd) ?? new DataTable();

//        int totalVideos = dtOver.Rows.Count > 0 ? Convert.ToInt32(dtOver.Rows[0]["TotalVideos"]) : 0;
//        int watchedCount = dtOver.Rows.Count > 0 ? Convert.ToInt32(dtOver.Rows[0]["WatchedCount"]) : 0;

//        // Per-chapter breakdown
//        var chCmd = new SqlCommand(@"
//            SELECT
//                C.ChapterId,
//                C.ChapterName,
//                COUNT(V.VideoId)                                    AS TotalVideos,
//                SUM(CASE WHEN WP.IsCompleted=1 THEN 1 ELSE 0 END)  AS WatchedVideos
//            FROM   Chapters C
//            LEFT   JOIN Videos V
//                ON V.ChapterId=C.ChapterId AND V.IsActive=1
//            LEFT   JOIN StudentWatchProgress WP
//                ON WP.VideoId=V.VideoId AND WP.SessionId=@Sess AND WP.UserId=@Uid
//            WHERE  C.SubjectId=@SubId AND C.SessionId=@Sess AND C.IsActive=1
//            GROUP  BY C.ChapterId, C.ChapterName
//            ORDER  BY C.OrderNo, C.ChapterId");
//        chCmd.Parameters.AddWithValue("@SubId", subjectId);
//        chCmd.Parameters.AddWithValue("@Sess", sessionId);
//        chCmd.Parameters.AddWithValue("@Uid", userId);
//        DataTable dtCh = _dl.GetDataTable(chCmd) ?? new DataTable();

//        int totalChapters = dtCh.Rows.Count;
//        int completedChapters = 0;
//        var chapterProgress = new List<object>();

//        foreach (DataRow row in dtCh.Rows)
//        {
//            int tv = Convert.ToInt32(row["TotalVideos"]);
//            int wv = Convert.ToInt32(row["WatchedVideos"]);
//            int pct = tv > 0 ? (int)Math.Round((double)wv / tv * 100) : 0;
//            if (tv > 0 && wv >= tv) completedChapters++;

//            chapterProgress.Add(new
//            {
//                ChapterId = Convert.ToInt32(row["ChapterId"]),
//                ChapterName = row["ChapterName"]?.ToString() ?? "",
//                TotalVideos = tv,
//                WatchedVideos = wv,
//                Pct = pct
//            });
//        }

//        // Completed video IDs (to show ✓ in left panel)
//        var doneCmd = new SqlCommand(@"
//            SELECT WP.VideoId
//            FROM   StudentWatchProgress WP
//            INNER  JOIN Videos V ON V.VideoId=WP.VideoId
//            INNER  JOIN Chapters C ON C.ChapterId=V.ChapterId
//            WHERE  WP.UserId=@Uid AND WP.SessionId=@Sess
//              AND  WP.IsCompleted=1
//              AND  C.SubjectId=@SubId");
//        doneCmd.Parameters.AddWithValue("@Uid", userId);
//        doneCmd.Parameters.AddWithValue("@Sess", sessionId);
//        doneCmd.Parameters.AddWithValue("@SubId", subjectId);
//        DataTable dtDone = _dl.GetDataTable(doneCmd) ?? new DataTable();

//        var doneIds = new List<int>();
//        foreach (DataRow dr in dtDone.Rows)
//            doneIds.Add(Convert.ToInt32(dr["VideoId"]));

//        return new
//        {
//            TotalCount = totalVideos,
//            WatchedCount = watchedCount,
//            TotalChapters = totalChapters,
//            CompletedChapters = completedChapters,
//            ChapterProgress = chapterProgress,
//            CompletedVideoIds = doneIds
//        };
//    }

//    // ══════════════════════════════════════════════════════════════════════
//    //  COMMENTS — GET
//    //  Returns top-level comments with nested replies.
//    //  Each comment includes Role for client-side filter (All/Student/Teacher/Admin).
//    // ══════════════════════════════════════════════════════════════════════
//    public List<object> GetComments(int videoId, int sessionId)
//    {
//        // Get top-level comments
//        var cmd = new SqlCommand(@"
//            SELECT
//                VC.CommentId,
//                VC.ParentCommentId,
//                VC.CommentText,
//                FORMAT(VC.CreatedOn,'dd MMM yyyy HH:mm') AS CreatedOn,
//                U.UserId,
//                ISNULL(UP.FullName, U.Username) AS FullName,
//                U.Username,
//                R.RoleName                              AS Role
//            FROM   VideoComments VC
//            INNER  JOIN Users U ON U.UserId = VC.UserId
//            LEFT   JOIN UserProfile UP ON UP.UserId = U.UserId
//            INNER  JOIN Roles R ON R.RoleId = U.RoleId
//            WHERE  VC.VideoId       = @Vid
//              AND  VC.SessionId     = @Sess
//              AND  VC.IsDeleted     = 0
//              AND  VC.ParentCommentId IS NULL
//            ORDER  BY VC.CreatedOn DESC");
//        cmd.Parameters.AddWithValue("@Vid", videoId);
//        cmd.Parameters.AddWithValue("@Sess", sessionId);

//        DataTable dtParent = _dl.GetDataTable(cmd) ?? new DataTable();

//        // Get all replies
//        var replyCmd = new SqlCommand(@"
//            SELECT
//                VC.CommentId,
//                VC.ParentCommentId,
//                VC.CommentText,
//                FORMAT(VC.CreatedOn,'dd MMM yyyy HH:mm') AS CreatedOn,
//                U.UserId,
//                ISNULL(UP.FullName, U.Username) AS FullName,
//                U.Username,
//                R.RoleName                              AS Role
//            FROM   VideoComments VC
//            INNER  JOIN Users U ON U.UserId = VC.UserId
//            LEFT   JOIN UserProfile UP ON UP.UserId = U.UserId
//            INNER  JOIN Roles R ON R.RoleId = U.RoleId
//            WHERE  VC.VideoId      = @Vid
//              AND  VC.SessionId    = @Sess
//              AND  VC.IsDeleted    = 0
//              AND  VC.ParentCommentId IS NOT NULL
//            ORDER  BY VC.CreatedOn ASC");
//        replyCmd.Parameters.AddWithValue("@Vid", videoId);
//        replyCmd.Parameters.AddWithValue("@Sess", sessionId);

//        DataTable dtReplies = _dl.GetDataTable(replyCmd) ?? new DataTable();

//        // Build nested structure
//        var result = new List<object>();
//        foreach (DataRow pr in dtParent.Rows)
//        {
//            int cid = Convert.ToInt32(pr["CommentId"]);
//            var replies = new List<object>();

//            foreach (DataRow rr in dtReplies.Rows)
//            {
//                if (rr["ParentCommentId"] == DBNull.Value) continue;
//                if (Convert.ToInt32(rr["ParentCommentId"]) != cid) continue;
//                replies.Add(new
//                {
//                    CommentId = Convert.ToInt32(rr["CommentId"]),
//                    ParentCommentId = cid,
//                    CommentText = rr["CommentText"]?.ToString() ?? "",
//                    CreatedOn = rr["CreatedOn"]?.ToString() ?? "",
//                    FullName = rr["FullName"]?.ToString() ?? "",
//                    Username = rr["Username"]?.ToString() ?? "",
//                    Role = rr["Role"]?.ToString() ?? "Student",
//                    Replies = new List<object>()
//                });
//            }

//            result.Add(new
//            {
//                CommentId = cid,
//                ParentCommentId = (int?)null,
//                CommentText = pr["CommentText"]?.ToString() ?? "",
//                CreatedOn = pr["CreatedOn"]?.ToString() ?? "",
//                FullName = pr["FullName"]?.ToString() ?? "",
//                Username = pr["Username"]?.ToString() ?? "",
//                Role = pr["Role"]?.ToString() ?? "Student",
//                Replies = replies
//            });
//        }
//        return result;
//    }

//    // ══════════════════════════════════════════════════════════════════════
//    //  COMMENTS — POST (new comment or reply)
//    //  parentId = null → top-level comment
//    //  parentId = int  → reply to that comment
//    // ══════════════════════════════════════════════════════════════════════
//    public void PostComment(int videoId, int sessionId, int userId,
//        int societyId, int instituteId,
//        string commentText, int? parentId)
//    {
//        if (string.IsNullOrWhiteSpace(commentText)) return;

//        var cmd = new SqlCommand(@"
//            INSERT INTO VideoComments
//                (VideoId, SessionId, UserId, SocietyId, InstituteId,
//                 CommentText, ParentCommentId, IsDeleted, CreatedOn)
//            VALUES
//                (@Vid, @Sess, @Uid, @SocId, @InstId,
//                 @Text, @Parent, 0, GETDATE())");

//        cmd.Parameters.AddWithValue("@Vid", videoId);
//        cmd.Parameters.AddWithValue("@Sess", sessionId);
//        cmd.Parameters.AddWithValue("@Uid", userId);
//        cmd.Parameters.AddWithValue("@SocId", societyId);
//        cmd.Parameters.AddWithValue("@InstId", instituteId);
//        cmd.Parameters.AddWithValue("@Text", commentText.Trim());
//        cmd.Parameters.AddWithValue("@Parent",
//            parentId.HasValue ? (object)parentId.Value : DBNull.Value);

//        _dl.ExecuteCMD(cmd);
//    }

//    // ══════════════════════════════════════════════════════════════════════
//    //  AI HISTORY — SAVE
//    //  One row per AI interaction (summary/notes/quiz/ask-doubt).
//    // ══════════════════════════════════════════════════════════════════════
//    public void SaveAIHistory(int videoId, int sessionId, int userId,
//        string question, string answer)
//    {
//        var cmd = new SqlCommand(@"
//            INSERT INTO AIHistory
//                (VideoId, SessionId, UserId, Question, Answer, CreatedOn)
//            VALUES
//                (@Vid, @Sess, @Uid, @Q, @A, GETDATE())");

//        cmd.Parameters.AddWithValue("@Vid", videoId);
//        cmd.Parameters.AddWithValue("@Sess", sessionId);
//        cmd.Parameters.AddWithValue("@Uid", userId);
//        cmd.Parameters.AddWithValue("@Q", (question ?? "").Length > 500
//            ? question.Substring(0, 500) : question ?? "");
//        cmd.Parameters.AddWithValue("@A", (answer ?? "").Length > 4000
//            ? answer.Substring(0, 4000) : answer ?? "");
//        _dl.ExecuteCMD(cmd);
//    }

//    // ══════════════════════════════════════════════════════════════════════
//    //  AI HISTORY — GET
//    //  Returns last 20 AI interactions for this student + video.
//    // ══════════════════════════════════════════════════════════════════════
//    public List<object> GetAIHistory(int videoId, int sessionId, int userId)
//    {
//        var cmd = new SqlCommand(@"
//            SELECT TOP 20
//                Question,
//                Answer,
//                FORMAT(CreatedOn,'dd MMM yyyy HH:mm') AS CreatedOn
//            FROM   AIHistory
//            WHERE  VideoId=@Vid AND SessionId=@Sess AND UserId=@Uid
//            ORDER  BY CreatedOn DESC");

//        cmd.Parameters.AddWithValue("@Vid", videoId);
//        cmd.Parameters.AddWithValue("@Sess", sessionId);
//        cmd.Parameters.AddWithValue("@Uid", userId);

//        DataTable dt = _dl.GetDataTable(cmd) ?? new DataTable();
//        var list = new List<object>();

//        foreach (DataRow row in dt.Rows)
//        {
//            list.Add(new
//            {
//                Question = row["Question"]?.ToString() ?? "",
//                Answer = row["Answer"]?.ToString() ?? "",
//                CreatedOn = row["CreatedOn"]?.ToString() ?? ""
//            });
//        }
//        return list;
//    }

//    // ══════════════════════════════════════════════════════════════════════
//    //  NOTES — GET
//    //  Returns the student's saved notes HTML for a specific video.
//    // ══════════════════════════════════════════════════════════════════════
//    public object GetNotes(int videoId, int sessionId, int userId)
//    {
//        var cmd = new SqlCommand(@"
//            SELECT TOP 1
//                Content,
//                FORMAT(UpdatedOn,'dd MMM yyyy HH:mm') AS UpdatedOn
//            FROM   StudentNotes
//            WHERE  VideoId=@Vid AND SessionId=@Sess AND UserId=@Uid");

//        cmd.Parameters.AddWithValue("@Vid", videoId);
//        cmd.Parameters.AddWithValue("@Sess", sessionId);
//        cmd.Parameters.AddWithValue("@Uid", userId);

//        DataTable dt = _dl.GetDataTable(cmd);

//        if (dt == null || dt.Rows.Count == 0)
//            return new { Content = "", UpdatedOn = "" };

//        return new
//        {
//            Content = dt.Rows[0]["Content"]?.ToString() ?? "",
//            UpdatedOn = dt.Rows[0]["UpdatedOn"]?.ToString() ?? ""
//        };
//    }

//    // ══════════════════════════════════════════════════════════════════════
//    //  NOTES — SAVE (UPSERT)
//    //  Content is rich HTML from contenteditable div.
//    // ══════════════════════════════════════════════════════════════════════
//    public void SaveNotes(int videoId, int sessionId, int userId, string content)
//    {
//        var cmd = new SqlCommand(@"
//            IF EXISTS (
//                SELECT 1 FROM StudentNotes
//                WHERE  VideoId=@Vid AND SessionId=@Sess AND UserId=@Uid
//            )
//            BEGIN
//                UPDATE StudentNotes
//                SET    Content   = @Content,
//                       UpdatedOn = GETDATE()
//                WHERE  VideoId=@Vid AND SessionId=@Sess AND UserId=@Uid
//            END
//            ELSE
//            BEGIN
//                INSERT INTO StudentNotes
//                    (VideoId, SessionId, UserId, Content, CreatedOn, UpdatedOn)
//                VALUES
//                    (@Vid, @Sess, @Uid, @Content, GETDATE(), GETDATE())
//            END");

//        cmd.Parameters.AddWithValue("@Vid", videoId);
//        cmd.Parameters.AddWithValue("@Sess", sessionId);
//        cmd.Parameters.AddWithValue("@Uid", userId);
//        cmd.Parameters.AddWithValue("@Content", content ?? "");
//        _dl.ExecuteCMD(cmd);
//    }
//}


//-------------------------------------------------------------------------------------------------------------


using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

/// <summary>
/// StudyMaterialBL — Business Logic for the Student Study Material page.
/// Tables used:
///   StudentVideoViews, StudentWatchProgress, VideoRatings,
///   VideoComments, AIHistory, StudentNotes, Videos, Chapters
/// </summary>
public class StudyMaterialBL
{
    private readonly DataLayer _dl = new DataLayer();

    // ══════════════════════════════════════════════════════════════════════
    //  VIDEO TOPICS  (UpdatePanel postback)
    // ══════════════════════════════════════════════════════════════════════
    public DataTable GetVideoTopics(int videoId)
    {
        var cmd = new SqlCommand(@"
            SELECT StartTime, TopicTitle
            FROM   VideoTopics
            WHERE  VideoId = @Vid
            ORDER  BY StartTime");
        cmd.Parameters.AddWithValue("@Vid", videoId);
        return _dl.GetDataTable(cmd) ?? new DataTable();
    }

    // ══════════════════════════════════════════════════════════════════════
    //  TRACK VIEW
    //  One unique row per student/video/session. Also bumps ViewCount.
    // ══════════════════════════════════════════════════════════════════════
    public void TrackView(int videoId, int sessionId, int userId,
                          int societyId, int instituteId)
    {
        // Unique view row
        var upsert = new SqlCommand(@"
            IF NOT EXISTS (
                SELECT 1 FROM StudentVideoViews
                WHERE VideoId=@Vid AND SessionId=@Sess AND UserId=@Uid)
            BEGIN
                INSERT INTO StudentVideoViews
                    (VideoId,SessionId,UserId,SocietyId,InstituteId,ViewedOn)
                VALUES(@Vid,@Sess,@Uid,@Soc,@Inst,GETDATE())
            END");
        upsert.Parameters.AddWithValue("@Vid", videoId);
        upsert.Parameters.AddWithValue("@Sess", sessionId);
        upsert.Parameters.AddWithValue("@Uid", userId);
        upsert.Parameters.AddWithValue("@Soc", societyId);
        upsert.Parameters.AddWithValue("@Inst", instituteId);
        _dl.ExecuteCMD(upsert);

        // Always bump raw view count
        var bump = new SqlCommand(
            "UPDATE Videos SET ViewCount=ISNULL(ViewCount,0)+1 WHERE VideoId=@Vid");
        bump.Parameters.AddWithValue("@Vid", videoId);
        _dl.ExecuteCMD(bump);
    }

    // ══════════════════════════════════════════════════════════════════════
    //  SAVE WATCH PROGRESS  (called every 15 s from JS)
    //  MaxPercentage only ever goes UP. IsCompleted only ever goes TRUE.
    // ══════════════════════════════════════════════════════════════════════
    public void SaveWatchProgress(int videoId, int sessionId, int userId,
                                  int position, int percentage, bool isCompleted)
    {
        var cmd = new SqlCommand(@"
            IF EXISTS (
                SELECT 1 FROM StudentWatchProgress
                WHERE VideoId=@Vid AND SessionId=@Sess AND UserId=@Uid)
            BEGIN
                UPDATE StudentWatchProgress
                SET    LastPosition  = @Pos,
                       MaxPercentage = CASE WHEN @Pct > MaxPercentage
                                            THEN @Pct ELSE MaxPercentage END,
                       IsCompleted   = CASE WHEN @Done=1 THEN 1 ELSE IsCompleted END,
                       UpdatedOn     = GETDATE()
                WHERE  VideoId=@Vid AND SessionId=@Sess AND UserId=@Uid
            END
            ELSE
            BEGIN
                INSERT INTO StudentWatchProgress
                    (VideoId,SessionId,UserId,LastPosition,MaxPercentage,
                     IsCompleted,StartedOn,UpdatedOn)
                VALUES(@Vid,@Sess,@Uid,@Pos,@Pct,@Done,GETDATE(),GETDATE())
            END");
        cmd.Parameters.AddWithValue("@Vid", videoId);
        cmd.Parameters.AddWithValue("@Sess", sessionId);
        cmd.Parameters.AddWithValue("@Uid", userId);
        cmd.Parameters.AddWithValue("@Pos", position);
        cmd.Parameters.AddWithValue("@Pct", percentage);
        cmd.Parameters.AddWithValue("@Done", isCompleted ? 1 : 0);
        _dl.ExecuteCMD(cmd);
    }

    // ══════════════════════════════════════════════════════════════════════
    //  MARK VIDEO COMPLETE  (called at 95 %)
    // ══════════════════════════════════════════════════════════════════════
    public void MarkVideoComplete(int videoId, int sessionId, int userId)
    {
        var cmd = new SqlCommand(@"
            IF EXISTS (
                SELECT 1 FROM StudentWatchProgress
                WHERE VideoId=@Vid AND SessionId=@Sess AND UserId=@Uid)
            BEGIN
                UPDATE StudentWatchProgress
                SET IsCompleted=1, MaxPercentage=100, UpdatedOn=GETDATE()
                WHERE VideoId=@Vid AND SessionId=@Sess AND UserId=@Uid
            END
            ELSE
            BEGIN
                INSERT INTO StudentWatchProgress
                    (VideoId,SessionId,UserId,LastPosition,MaxPercentage,
                     IsCompleted,StartedOn,UpdatedOn)
                VALUES(@Vid,@Sess,@Uid,0,100,1,GETDATE(),GETDATE())
            END");
        cmd.Parameters.AddWithValue("@Vid", videoId);
        cmd.Parameters.AddWithValue("@Sess", sessionId);
        cmd.Parameters.AddWithValue("@Uid", userId);
        _dl.ExecuteCMD(cmd);
    }

    // ══════════════════════════════════════════════════════════════════════
    //  GET VIDEO STATUS  — resume position + completed flag
    // ══════════════════════════════════════════════════════════════════════
    public object GetVideoStatus(int videoId, int sessionId, int userId)
    {
        var cmd = new SqlCommand(@"
            SELECT TOP 1
                ISNULL(IsCompleted,0)   AS IsCompleted,
                ISNULL(LastPosition,0)  AS LastPosition,
                ISNULL(MaxPercentage,0) AS MaxPercentage
            FROM StudentWatchProgress
            WHERE VideoId=@Vid AND SessionId=@Sess AND UserId=@Uid");
        cmd.Parameters.AddWithValue("@Vid", videoId);
        cmd.Parameters.AddWithValue("@Sess", sessionId);
        cmd.Parameters.AddWithValue("@Uid", userId);
        DataTable dt = _dl.GetDataTable(cmd);
        if (dt == null || dt.Rows.Count == 0)
            return new { IsCompleted = false, LastPosition = 0, MaxPercentage = 0 };
        var r = dt.Rows[0];
        return new
        {
            IsCompleted = Convert.ToBoolean(r["IsCompleted"]),
            LastPosition = Convert.ToInt32(r["LastPosition"]),
            MaxPercentage = Convert.ToInt32(r["MaxPercentage"])
        };
    }

    // ══════════════════════════════════════════════════════════════════════
    //  GET VIDEO STATS  — total views + unique students
    // ══════════════════════════════════════════════════════════════════════
    public object GetVideoStats(int videoId, int sessionId)
    {
        var cmd = new SqlCommand(@"
            SELECT
                ISNULL(V.ViewCount,0) AS TotalViews,
                (SELECT COUNT(DISTINCT UserId) FROM StudentVideoViews
                 WHERE VideoId=@Vid AND SessionId=@Sess) AS UniqueStudents,
                (SELECT COUNT(*) FROM StudentWatchProgress
                 WHERE VideoId=@Vid AND SessionId=@Sess AND IsCompleted=1) AS CompletedCount
            FROM Videos V WHERE V.VideoId=@Vid");
        cmd.Parameters.AddWithValue("@Vid", videoId);
        cmd.Parameters.AddWithValue("@Sess", sessionId);
        DataTable dt = _dl.GetDataTable(cmd);
        if (dt == null || dt.Rows.Count == 0)
            return new { TotalViews = 0, UniqueStudents = 0, CompletedCount = 0 };
        var r = dt.Rows[0];
        return new
        {
            TotalViews = Convert.ToInt32(r["TotalViews"]),
            UniqueStudents = Convert.ToInt32(r["UniqueStudents"]),
            CompletedCount = Convert.ToInt32(r["CompletedCount"])
        };
    }

    // ══════════════════════════════════════════════════════════════════════
    //  RATING  — save (upsert) and get
    //  Table: VideoRatings (RatingId PK, VideoId, SessionId, UserId,
    //                       Rating INT 1-5, CreatedOn)
    // ══════════════════════════════════════════════════════════════════════
    public void SaveRating(int videoId, int sessionId, int userId, int rating)
    {
        if (rating < 1 || rating > 5) return;
        var cmd = new SqlCommand(@"
            IF EXISTS (
                SELECT 1 FROM VideoRatings
                WHERE VideoId=@Vid AND SessionId=@Sess AND UserId=@Uid)
            BEGIN
                UPDATE VideoRatings SET Rating=@R
                WHERE VideoId=@Vid AND SessionId=@Sess AND UserId=@Uid
            END
            ELSE
            BEGIN
                INSERT INTO VideoRatings(VideoId,SessionId,UserId,Rating,CreatedOn)
                VALUES(@Vid,@Sess,@Uid,@R,GETDATE())
            END");
        cmd.Parameters.AddWithValue("@Vid", videoId);
        cmd.Parameters.AddWithValue("@Sess", sessionId);
        cmd.Parameters.AddWithValue("@Uid", userId);
        cmd.Parameters.AddWithValue("@R", rating);
        _dl.ExecuteCMD(cmd);
    }

    public object GetRating(int videoId, int sessionId, int userId)
    {
        var cmd = new SqlCommand(@"
            SELECT
                ISNULL(CAST(AVG(CAST(Rating AS FLOAT)) AS DECIMAL(3,1)),0) AS AvgRating,
                COUNT(*) AS TotalRatings,
                ISNULL((SELECT TOP 1 Rating FROM VideoRatings
                        WHERE VideoId=@Vid AND SessionId=@Sess AND UserId=@Uid),0) AS MyRating
            FROM VideoRatings
            WHERE VideoId=@Vid AND SessionId=@Sess");
        cmd.Parameters.AddWithValue("@Vid", videoId);
        cmd.Parameters.AddWithValue("@Sess", sessionId);
        cmd.Parameters.AddWithValue("@Uid", userId);
        DataTable dt = _dl.GetDataTable(cmd);
        if (dt == null || dt.Rows.Count == 0)
            return new { AvgRating = 0.0, TotalRatings = 0, MyRating = 0 };
        var r = dt.Rows[0];
        return new
        {
            AvgRating = Convert.ToDouble(r["AvgRating"]),
            TotalRatings = Convert.ToInt32(r["TotalRatings"]),
            MyRating = Convert.ToInt32(r["MyRating"])
        };
    }

    // ══════════════════════════════════════════════════════════════════════
    //  OVERALL PROGRESS
    //  Returns: TotalCount, WatchedCount, TotalChapters, CompletedChapters,
    //           ChapterProgress[], CompletedVideoIds[]
    // ══════════════════════════════════════════════════════════════════════
    public object GetProgress(int subjectId, int sessionId, int userId)
    {
        // ── Overall counts ────────────────────────────────────────────────
        var oCmd = new SqlCommand(@"
            SELECT
                COUNT(V.VideoId) AS Total,
                SUM(CASE WHEN WP.IsCompleted=1 THEN 1 ELSE 0 END) AS Watched
            FROM Chapters C
            INNER JOIN Videos V ON V.ChapterId=C.ChapterId AND V.IsActive=1
            LEFT  JOIN StudentWatchProgress WP
                   ON WP.VideoId=V.VideoId AND WP.SessionId=@Sess AND WP.UserId=@Uid
            WHERE C.SubjectId=@Sub AND C.SessionId=@Sess AND C.IsActive=1");
        oCmd.Parameters.AddWithValue("@Sub", subjectId);
        oCmd.Parameters.AddWithValue("@Sess", sessionId);
        oCmd.Parameters.AddWithValue("@Uid", userId);
        DataTable dtO = _dl.GetDataTable(oCmd) ?? new DataTable();
        int total = dtO.Rows.Count > 0 ? Convert.ToInt32(dtO.Rows[0]["Total"]) : 0;
        int watched = dtO.Rows.Count > 0 ? Convert.ToInt32(dtO.Rows[0]["Watched"]) : 0;

        // ── Per-chapter breakdown ─────────────────────────────────────────
        var cCmd = new SqlCommand(@"
            SELECT
                C.ChapterId, C.ChapterName,
                COUNT(V.VideoId) AS TotalVids,
                SUM(CASE WHEN WP.IsCompleted=1 THEN 1 ELSE 0 END) AS WatchedVids
            FROM Chapters C
            LEFT JOIN Videos V  ON V.ChapterId=C.ChapterId AND V.IsActive=1
            LEFT JOIN StudentWatchProgress WP
                   ON WP.VideoId=V.VideoId AND WP.SessionId=@Sess AND WP.UserId=@Uid
            WHERE C.SubjectId=@Sub AND C.SessionId=@Sess AND C.IsActive=1
            GROUP BY C.ChapterId, C.ChapterName
            ORDER BY C.OrderNo, C.ChapterId");
        cCmd.Parameters.AddWithValue("@Sub", subjectId);
        cCmd.Parameters.AddWithValue("@Sess", sessionId);
        cCmd.Parameters.AddWithValue("@Uid", userId);
        DataTable dtC = _dl.GetDataTable(cCmd) ?? new DataTable();

        int totalCh = dtC.Rows.Count, doneCh = 0;
        var chProg = new List<object>();
        foreach (DataRow row in dtC.Rows)
        {
            int tv = Convert.ToInt32(row["TotalVids"]);
            int wv = Convert.ToInt32(row["WatchedVids"]);
            int pct = tv > 0 ? (int)Math.Round((double)wv / tv * 100) : 0;
            if (tv > 0 && wv >= tv) doneCh++;
            chProg.Add(new
            {
                ChapterId = Convert.ToInt32(row["ChapterId"]),
                ChapterName = row["ChapterName"]?.ToString() ?? "",
                TotalVideos = tv,
                WatchedVideos = wv,
                Pct = pct
            });
        }

        // ── Completed video IDs (for ✓ marks in left panel) ───────────────
        var dCmd = new SqlCommand(@"
            SELECT WP.VideoId
            FROM StudentWatchProgress WP
            INNER JOIN Videos   V ON V.VideoId   = WP.VideoId
            INNER JOIN Chapters C ON C.ChapterId = V.ChapterId
            WHERE WP.UserId=@Uid AND WP.SessionId=@Sess
              AND WP.IsCompleted=1 AND C.SubjectId=@Sub");
        dCmd.Parameters.AddWithValue("@Uid", userId);
        dCmd.Parameters.AddWithValue("@Sess", sessionId);
        dCmd.Parameters.AddWithValue("@Sub", subjectId);
        DataTable dtD = _dl.GetDataTable(dCmd) ?? new DataTable();
        var doneIds = new List<int>();
        foreach (DataRow dr in dtD.Rows)
            doneIds.Add(Convert.ToInt32(dr["VideoId"]));

        return new
        {
            TotalCount = total,
            WatchedCount = watched,
            TotalChapters = totalCh,
            CompletedChapters = doneCh,
            ChapterProgress = chProg,
            CompletedVideoIds = doneIds
        };
    }

    // ══════════════════════════════════════════════════════════════════════
    //  COMMENTS — GET (nested: top-level + replies)
    // ══════════════════════════════════════════════════════════════════════
    public List<object> GetComments(int videoId, int sessionId)
    {
        string baseSql = @"
            SELECT VC.CommentId, VC.ParentCommentId, VC.CommentText,
                   FORMAT(VC.CreatedOn,'dd MMM yyyy HH:mm') AS CreatedOn,
                   ISNULL(UP.FullName, U.Username) AS FullName,
                   U.Username, R.RoleName AS Role
            FROM VideoComments VC
            INNER JOIN Users U ON U.UserId=VC.UserId
            LEFT  JOIN UserProfile UP ON UP.UserId=U.UserId
            INNER JOIN Roles R ON R.RoleId=U.RoleId
            WHERE VC.VideoId=@Vid AND VC.SessionId=@Sess AND VC.IsDeleted=0
              AND VC.ParentCommentId {0}
            ORDER BY VC.CreatedOn {1}";

        var pCmd = new SqlCommand(string.Format(baseSql, "IS NULL", "DESC"));
        pCmd.Parameters.AddWithValue("@Vid", videoId);
        pCmd.Parameters.AddWithValue("@Sess", sessionId);
        DataTable dtP = _dl.GetDataTable(pCmd) ?? new DataTable();

        var rCmd = new SqlCommand(string.Format(baseSql, "IS NOT NULL", "ASC"));
        rCmd.Parameters.AddWithValue("@Vid", videoId);
        rCmd.Parameters.AddWithValue("@Sess", sessionId);
        DataTable dtR = _dl.GetDataTable(rCmd) ?? new DataTable();

        var result = new List<object>();
        foreach (DataRow pr in dtP.Rows)
        {
            int cid = Convert.ToInt32(pr["CommentId"]);
            var reps = new List<object>();
            foreach (DataRow rr in dtR.Rows)
            {
                if (rr["ParentCommentId"] == DBNull.Value) continue;
                if (Convert.ToInt32(rr["ParentCommentId"]) != cid) continue;
                reps.Add(new
                {
                    CommentId = Convert.ToInt32(rr["CommentId"]),
                    ParentCommentId = cid,
                    CommentText = rr["CommentText"]?.ToString() ?? "",
                    CreatedOn = rr["CreatedOn"]?.ToString() ?? "",
                    FullName = rr["FullName"]?.ToString() ?? "",
                    Username = rr["Username"]?.ToString() ?? "",
                    Role = rr["Role"]?.ToString() ?? "Student",
                    Replies = new List<object>()
                });
            }
            result.Add(new
            {
                CommentId = cid,
                ParentCommentId = (int?)null,
                CommentText = pr["CommentText"]?.ToString() ?? "",
                CreatedOn = pr["CreatedOn"]?.ToString() ?? "",
                FullName = pr["FullName"]?.ToString() ?? "",
                Username = pr["Username"]?.ToString() ?? "",
                Role = pr["Role"]?.ToString() ?? "Student",
                Replies = reps
            });
        }
        return result;
    }

    // ══════════════════════════════════════════════════════════════════════
    //  COMMENTS — POST (new or reply)
    // ══════════════════════════════════════════════════════════════════════
    public void PostComment(int videoId, int sessionId, int userId,
                            int societyId, int instituteId,
                            string text, int? parentId)
    {
        if (string.IsNullOrWhiteSpace(text)) return;
        var cmd = new SqlCommand(@"
            INSERT INTO VideoComments
                (VideoId,SessionId,UserId,SocietyId,InstituteId,
                 CommentText,ParentCommentId,IsDeleted,CreatedOn)
            VALUES(@Vid,@Sess,@Uid,@Soc,@Inst,@Txt,@Par,0,GETDATE())");
        cmd.Parameters.AddWithValue("@Vid", videoId);
        cmd.Parameters.AddWithValue("@Sess", sessionId);
        cmd.Parameters.AddWithValue("@Uid", userId);
        cmd.Parameters.AddWithValue("@Soc", societyId);
        cmd.Parameters.AddWithValue("@Inst", instituteId);
        cmd.Parameters.AddWithValue("@Txt", text.Trim());
        cmd.Parameters.AddWithValue("@Par",
            parentId.HasValue ? (object)parentId.Value : DBNull.Value);
        _dl.ExecuteCMD(cmd);
    }

    // ══════════════════════════════════════════════════════════════════════
    //  AI HISTORY — SAVE / GET
    // ══════════════════════════════════════════════════════════════════════
    public void SaveAIHistory(int videoId, int sessionId, int userId,
                              string question, string answer)
    {
        var cmd = new SqlCommand(@"
            INSERT INTO AIHistory(VideoId,SessionId,UserId,Question,Answer,CreatedOn)
            VALUES(@Vid,@Sess,@Uid,@Q,@A,GETDATE())");
        cmd.Parameters.AddWithValue("@Vid", videoId);
        cmd.Parameters.AddWithValue("@Sess", sessionId);
        cmd.Parameters.AddWithValue("@Uid", userId);
        cmd.Parameters.AddWithValue("@Q",
            (question ?? "").Length > 500 ? question.Substring(0, 500) : question ?? "");
        cmd.Parameters.AddWithValue("@A",
            (answer ?? "").Length > 4000 ? answer.Substring(0, 4000) : answer ?? "");
        _dl.ExecuteCMD(cmd);
    }

    public List<object> GetAIHistory(int videoId, int sessionId, int userId)
    {
        var cmd = new SqlCommand(@"
            SELECT TOP 20 Question, Answer,
                   FORMAT(CreatedOn,'dd MMM yyyy HH:mm') AS CreatedOn
            FROM AIHistory
            WHERE VideoId=@Vid AND SessionId=@Sess AND UserId=@Uid
            ORDER BY CreatedOn DESC");
        cmd.Parameters.AddWithValue("@Vid", videoId);
        cmd.Parameters.AddWithValue("@Sess", sessionId);
        cmd.Parameters.AddWithValue("@Uid", userId);
        DataTable dt = _dl.GetDataTable(cmd) ?? new DataTable();
        var list = new List<object>();
        foreach (DataRow r in dt.Rows)
            list.Add(new
            {
                Question = r["Question"]?.ToString() ?? "",
                Answer = r["Answer"]?.ToString() ?? "",
                CreatedOn = r["CreatedOn"]?.ToString() ?? ""
            });
        return list;
    }

    // ══════════════════════════════════════════════════════════════════════
    //  NOTES — GET / SAVE (rich HTML, upsert)
    // ══════════════════════════════════════════════════════════════════════
    public object GetNotes(int videoId, int sessionId, int userId)
    {
        var cmd = new SqlCommand(@"
            SELECT TOP 1 Content, FORMAT(UpdatedOn,'dd MMM yyyy HH:mm') AS UpdatedOn
            FROM StudentNotes
            WHERE VideoId=@Vid AND SessionId=@Sess AND UserId=@Uid");
        cmd.Parameters.AddWithValue("@Vid", videoId);
        cmd.Parameters.AddWithValue("@Sess", sessionId);
        cmd.Parameters.AddWithValue("@Uid", userId);
        DataTable dt = _dl.GetDataTable(cmd);
        if (dt == null || dt.Rows.Count == 0)
            return new { Content = "", UpdatedOn = "" };
        return new
        {
            Content = dt.Rows[0]["Content"]?.ToString() ?? "",
            UpdatedOn = dt.Rows[0]["UpdatedOn"]?.ToString() ?? ""
        };
    }

    public void SaveNotes(int videoId, int sessionId, int userId, string content)
    {
        var cmd = new SqlCommand(@"
            IF EXISTS (SELECT 1 FROM StudentNotes
                       WHERE VideoId=@Vid AND SessionId=@Sess AND UserId=@Uid)
            BEGIN
                UPDATE StudentNotes
                SET Content=@C, UpdatedOn=GETDATE()
                WHERE VideoId=@Vid AND SessionId=@Sess AND UserId=@Uid
            END
            ELSE
            BEGIN
                INSERT INTO StudentNotes
                    (VideoId,SessionId,UserId,Content,CreatedOn,UpdatedOn)
                VALUES(@Vid,@Sess,@Uid,@C,GETDATE(),GETDATE())
            END");
        cmd.Parameters.AddWithValue("@Vid", videoId);
        cmd.Parameters.AddWithValue("@Sess", sessionId);
        cmd.Parameters.AddWithValue("@Uid", userId);
        cmd.Parameters.AddWithValue("@C", content ?? "");
        _dl.ExecuteCMD(cmd);
    }
}