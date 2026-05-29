using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

/// <summary>
/// StudyMaterialBL — Business Logic for the Student Study Material page.
/// Tables perfectly matched with database schema script:
///   VideoViews, VideoWatchProgress, VideoRatings, VideoComments, 
///   VideoNotes, VideoAIHistory, Materials, MaterialNotes
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
    //  Restricted calculation to ensure only RoleId = 4 (Student) tracks data.
    // ══════════════════════════════════════════════════════════════════════
    public void TrackView(int videoId, int sessionId, int userId, int societyId, int instituteId)
    {
        // 1. Double check from security perspective that user is a student (RoleId = 4)
        var checkRole = new SqlCommand("SELECT RoleId FROM Users WHERE UserId = @Uid");
        checkRole.Parameters.AddWithValue("@Uid", userId);
        DataTable dtRole = _dl.GetDataTable(checkRole);

        if (dtRole == null || dtRole.Rows.Count == 0 || Convert.ToInt32(dtRole.Rows[0]["RoleId"]) != 4)
        {
            return; // Exit silently if it's a teacher or admin trying to trigger calculation logs
        }

        // 2. Log unique student tracking row mapping database table layout
        var upsert = new SqlCommand(@"
            IF NOT EXISTS (
                SELECT 1 FROM VideoViews
                WHERE VideoId=@Vid AND SessionId=@Sess AND UserId=@Uid)
            BEGIN
                INSERT INTO VideoViews
                    (VideoId,SessionId,UserId,SocietyId,InstituteId,ViewedOn,IsCompleted)
                VALUES(@Vid,@Sess,@Uid,@Soc,@Inst,GETDATE(),0)
            END");
        upsert.Parameters.AddWithValue("@Vid", videoId);
        upsert.Parameters.AddWithValue("@Sess", sessionId);
        upsert.Parameters.AddWithValue("@Uid", userId);
        upsert.Parameters.AddWithValue("@Soc", societyId);
        upsert.Parameters.AddWithValue("@Inst", instituteId);
        _dl.ExecuteCMD(upsert);

        // Always increment running raw stream metrics tracker counter
        var bump = new SqlCommand(
            "UPDATE Videos SET ViewCount=ISNULL(ViewCount,0)+1 WHERE VideoId=@Vid");
        bump.Parameters.AddWithValue("@Vid", videoId);
        _dl.ExecuteCMD(bump);
    }

    // ══════════════════════════════════════════════════════════════════════
    //  SAVE WATCH PROGRESS (every 15 s check updates)
    // ══════════════════════════════════════════════════════════════════════
    public void SaveWatchProgress(int videoId, int sessionId, int userId, int position, int percentage, bool isCompleted)
    {
        var cmd = new SqlCommand(@"
            IF EXISTS (
                SELECT 1 FROM VideoWatchProgress
                WHERE VideoId=@Vid AND UserId=@Uid)
            BEGIN
                UPDATE VideoWatchProgress
                SET    LastPosition    = @Pos,
                       WatchedPercent  = CASE WHEN @Pct > WatchedPercent THEN @Pct ELSE WatchedPercent END,
                       UpdatedOn       = GETDATE()
                WHERE  VideoId=@Vid AND UserId=@Uid
            END
            ELSE
            BEGIN
                -- Extract tenant ids from the Video asset context natively
                DECLARE @Soc INT, @Inst INT
                SELECT @Soc=SocietyId, @Inst=InstituteId FROM Videos WHERE VideoId=@Vid

                INSERT INTO VideoWatchProgress
                    (SocietyId,InstituteId,SessionId,VideoId,UserId,LastPosition,WatchedPercent,UpdatedOn)
                VALUES(@Soc,@Inst,@Sess,@Vid,@Uid,@Pos,@Pct,GETDATE())
            END");
        cmd.Parameters.AddWithValue("@Vid", videoId);
        cmd.Parameters.AddWithValue("@Sess", sessionId);
        cmd.Parameters.AddWithValue("@Uid", userId);
        cmd.Parameters.AddWithValue("@Pos", position);
        cmd.Parameters.AddWithValue("@Pct", percentage);
        _dl.ExecuteCMD(cmd);
    }

    // ══════════════════════════════════════════════════════════════════════
    //  MARK VIDEO COMPLETE (called at 95% threshold)
    // ══════════════════════════════════════════════════════════════════════
    public void MarkVideoComplete(int videoId, int sessionId, int userId)
    {
        // 1. Set progress table tracking indicators
        var cmdProgress = new SqlCommand(@"
            IF EXISTS (SELECT 1 FROM VideoWatchProgress WHERE VideoId=@Vid AND UserId=@Uid)
            BEGIN
                UPDATE VideoWatchProgress
                SET WatchedPercent=100, UpdatedOn=GETDATE()
                WHERE VideoId=@Vid AND UserId=@Uid
            END");
        cmdProgress.Parameters.AddWithValue("@Vid", videoId);
        cmdProgress.Parameters.AddWithValue("@Uid", userId);
        _dl.ExecuteCMD(cmdProgress);

        // 2. Set distinct tracking status item in core log summary references
        var cmdViews = new SqlCommand(@"
            UPDATE VideoViews SET IsCompleted=1 
            WHERE VideoId=@Vid AND SessionId=@Sess AND UserId=@Uid");
        cmdViews.Parameters.AddWithValue("@Vid", videoId);
        cmdViews.Parameters.AddWithValue("@Sess", sessionId);
        cmdViews.Parameters.AddWithValue("@Uid", userId);
        _dl.ExecuteCMD(cmdViews);
    }

    // ══════════════════════════════════════════════════════════════════════
    //  GET VIDEO STATUS — resume position + completed flag
    // ══════════════════════════════════════════════════════════════════════
    public object GetVideoStatus(int videoId, int sessionId, int userId)
    {
        var cmd = new SqlCommand(@"
            SELECT TOP 1
                ISNULL((SELECT IsCompleted FROM VideoViews WHERE VideoId=@Vid AND SessionId=@Sess AND UserId=@Uid),0) AS IsCompleted,
                ISNULL(LastPosition,0)    AS LastPosition,
                ISNULL(WatchedPercent,0)  AS MaxPercentage
            FROM VideoWatchProgress
            WHERE VideoId=@Vid AND UserId=@Uid");
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
    //  GET VIDEO STATS — total views + unique students
    // ══════════════════════════════════════════════════════════════════════
    //public object GetVideoStats(int videoId, int sessionId)
    //{
    //    var cmd = new SqlCommand(@"
    //        SELECT
    //            ISNULL(V.ViewCount,0) AS TotalViews,
    //            (SELECT COUNT(DISTINCT UserId) FROM VideoViews
    //             WHERE VideoId=@Vid AND SessionId=@Sess) AS UniqueStudents,
    //            (SELECT COUNT(*) FROM VideoViews
    //             WHERE VideoId=@Vid AND SessionId=@Sess AND IsCompleted=1) AS CompletedCount
    //        FROM Videos V WHERE V.VideoId=@Vid");
    //    cmd.Parameters.AddWithValue("@Vid", videoId);
    //    cmd.Parameters.AddWithValue("@Sess", sessionId);
    //    DataTable dt = _dl.GetDataTable(cmd);
    //    if (dt == null || dt.Rows.Count == 0)
    //        return new { TotalViews = 0, UniqueStudents = 0, CompletedCount = 0 };
    //    var r = dt.Rows[0];
    //    return new
    //    {
    //        TotalViews = Convert.ToInt32(r["TotalViews"]),
    //        UniqueStudents = Convert.ToInt32(r["UniqueStudents"]),
    //        CompletedCount = Convert.ToInt32(r["CompletedCount"])
    //    };
    //}


    public object GetVideoStats(int videoId, int sessionId)
    {
        var cmd = new SqlCommand(@"
        SELECT
            -- Total student views (distinct students only)
            (
                SELECT COUNT(DISTINCT VV.UserId)
                FROM VideoViews VV
                INNER JOIN Users U
                    ON VV.UserId = U.UserId
                WHERE VV.VideoId   = @Vid
                  AND VV.SessionId = @Sess
                  AND U.RoleId     = 4
            ) AS TotalViews,

            -- Unique student viewers
            (
                SELECT COUNT(DISTINCT VV.UserId)
                FROM VideoViews VV
                INNER JOIN Users U
                    ON VV.UserId = U.UserId
                WHERE VV.VideoId   = @Vid
                  AND VV.SessionId = @Sess
                  AND U.RoleId     = 4
            ) AS UniqueStudents,

            -- Completed student count
            (
                SELECT COUNT(DISTINCT VV.UserId)
                FROM VideoViews VV
                INNER JOIN Users U
                    ON VV.UserId = U.UserId
                WHERE VV.VideoId    = @Vid
                  AND VV.SessionId  = @Sess
                  AND VV.IsCompleted = 1
                  AND U.RoleId      = 4
            ) AS CompletedCount");

        cmd.Parameters.AddWithValue("@Vid", videoId);
        cmd.Parameters.AddWithValue("@Sess", sessionId);

        DataTable dt = _dl.GetDataTable(cmd);

        if (dt == null || dt.Rows.Count == 0)
        {
            return new
            {
                TotalViews = 0,
                UniqueStudents = 0,
                CompletedCount = 0
            };
        }

        DataRow r = dt.Rows[0];

        return new
        {
            TotalViews = Convert.ToInt32(r["TotalViews"]),
            UniqueStudents = Convert.ToInt32(r["UniqueStudents"]),
            CompletedCount = Convert.ToInt32(r["CompletedCount"])
        };
    }


    // ══════════════════════════════════════════════════════════════════════
    //  RATING — save (upsert) and get
    // ══════════════════════════════════════════════════════════════════════
    public void SaveRating(int videoId, int sessionId, int userId, int rating)
    {
        if (rating < 1 || rating > 5) return;
        var cmd = new SqlCommand(@"
            IF EXISTS (
                SELECT 1 FROM VideoRatings
                WHERE VideoId=@Vid AND UserId=@Uid)
            BEGIN
                UPDATE VideoRatings SET Rating=@R, CreatedOn=GETDATE()
                WHERE VideoId=@Vid AND UserId=@Uid
            END
            ELSE
            BEGIN
                INSERT INTO VideoRatings(VideoId,UserId,Rating,CreatedOn)
                VALUES(@Vid,@Uid,@R,GETDATE())
            END");
        cmd.Parameters.AddWithValue("@Vid", videoId);
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
                        WHERE VideoId=@Vid AND UserId=@Uid),0) AS MyRating
            FROM VideoRatings
            WHERE VideoId=@Vid");
        cmd.Parameters.AddWithValue("@Vid", videoId);
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
    // ══════════════════════════════════════════════════════════════════════
    public object GetProgress(int subjectId, int sessionId, int userId)
    {
        var oCmd = new SqlCommand(@"
            SELECT
                COUNT(V.VideoId) AS Total,
                SUM(CASE WHEN VV.IsCompleted=1 THEN 1 ELSE 0 END) AS Watched
            FROM Chapters C
            INNER JOIN Videos V ON V.ChapterId=C.ChapterId AND V.IsActive=1
            LEFT  JOIN VideoViews VV
                   ON VV.VideoId=V.VideoId AND VV.SessionId=@Sess AND VV.UserId=@Uid
            WHERE C.SubjectId=@Sub AND C.SessionId=@Sess AND C.IsActive=1");
        oCmd.Parameters.AddWithValue("@Sub", subjectId);
        oCmd.Parameters.AddWithValue("@Sess", sessionId);
        oCmd.Parameters.AddWithValue("@Uid", userId);
        DataTable dtO = _dl.GetDataTable(oCmd) ?? new DataTable();
        int total = dtO.Rows.Count > 0 ? Convert.ToInt32(dtO.Rows[0]["Total"]) : 0;
        int watched = dtO.Rows.Count > 0 ? Convert.ToInt32(dtO.Rows[0]["Watched"]) : 0;

        var cCmd = new SqlCommand(@"
            SELECT
                C.ChapterId, C.ChapterName,
                COUNT(V.VideoId) AS TotalVids,
                SUM(CASE WHEN VV.IsCompleted=1 THEN 1 ELSE 0 END) AS WatchedVids
            FROM Chapters C
            LEFT JOIN Videos V  ON V.ChapterId=C.ChapterId AND V.IsActive=1
            LEFT JOIN VideoViews VV
                   ON VV.VideoId=V.VideoId AND VV.SessionId=@Sess AND VV.UserId=@Uid
            WHERE C.SubjectId=@Sub AND C.SessionId=@Sess AND C.IsActive=1
            GROUP BY C.ChapterId, C.ChapterName
            ORDER BY C.ChapterId");
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

        var dCmd = new SqlCommand(@"
            SELECT VV.VideoId
            FROM VideoViews VV
            INNER JOIN Videos   V ON V.VideoId   = VV.VideoId
            INNER JOIN Chapters C ON C.ChapterId = V.ChapterId
            WHERE VV.UserId=@Uid AND VV.SessionId=@Sess
              AND VV.IsCompleted=1 AND C.SubjectId=@Sub");
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
    //  COMMENTS — GET & POST
    // ══════════════════════════════════════════════════════════════════════
    public List<object> GetComments(int videoId, int sessionId)
    {
        string baseSql = @"
            SELECT VC.CommentId, VC.ParentCommentId, VC.Comment AS CommentText,
                   FORMAT(VC.CommentedOn,'dd MMM yyyy HH:mm') AS CreatedOn,
                   ISNULL(UP.FullName, U.Username) AS FullName,
                   U.Username, R.RoleName AS Role
            FROM VideoComments VC
            INNER JOIN Users U ON U.UserId=VC.UserId
            LEFT  JOIN UserProfile UP ON UP.UserId=U.UserId
            INNER JOIN Roles R ON R.RoleId=U.RoleId
            WHERE VC.VideoId=@Vid AND VC.SessionId=@Sess
              AND VC.ParentCommentId {0}
            ORDER BY VC.CommentedOn {1}";

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

    public void PostComment(int videoId, int sessionId, int userId, int societyId, int instituteId, string text, int? parentId)
    {
        if (string.IsNullOrWhiteSpace(text)) return;
        var cmd = new SqlCommand(@"
            INSERT INTO VideoComments
                (SocietyId,InstituteId,SessionId,VideoId,UserId,Comment,CommentedOn,ParentCommentId)
            VALUES(@Soc,@Inst,@Sess,@Vid,@Uid,@Txt,GETDATE(),@Par)");
        cmd.Parameters.AddWithValue("@Vid", videoId);
        cmd.Parameters.AddWithValue("@Sess", sessionId);
        cmd.Parameters.AddWithValue("@Uid", userId);
        cmd.Parameters.AddWithValue("@Soc", societyId);
        cmd.Parameters.AddWithValue("@Inst", instituteId);
        cmd.Parameters.AddWithValue("@Txt", text.Trim());
        cmd.Parameters.AddWithValue("@Par", parentId.HasValue ? (object)parentId.Value : DBNull.Value);
        _dl.ExecuteCMD(cmd);
    }

    // ══════════════════════════════════════════════════════════════════════
    //  AI HISTORY — SAVE / GET
    // ══════════════════════════════════════════════════════════════════════
    public void SaveAIHistory(int videoId, int sessionId, int userId, string question, string answer)
    {
        var cmd = new SqlCommand(@"
            INSERT INTO VideoAIHistory(VideoId,UserId,Type,Question,Response,CreatedOn)
            VALUES(@Vid,@Uid,'Doubt',@Q,@A,GETDATE())");
        cmd.Parameters.AddWithValue("@Vid", videoId);
        cmd.Parameters.AddWithValue("@Uid", userId);
        cmd.Parameters.AddWithValue("@Q", question ?? "");
        cmd.Parameters.AddWithValue("@A", answer ?? "");
        _dl.ExecuteCMD(cmd);
    }

    public List<object> GetAIHistory(int videoId, int sessionId, int userId)
    {
        var cmd = new SqlCommand(@"
            SELECT TOP 20 Question, Response AS Answer,
                   FORMAT(CreatedOn,'dd MMM yyyy HH:mm') AS CreatedOn
            FROM VideoAIHistory
            WHERE VideoId=@Vid AND UserId=@Uid
            ORDER BY CreatedOn DESC");
        cmd.Parameters.AddWithValue("@Vid", videoId);
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
    //  VIDEO STUDY NOTES — GET / SAVE (Rich HTML, upsert)
    // ══════════════════════════════════════════════════════════════════════
    public object GetNotes(int videoId, int sessionId, int userId)
    {
        var cmd = new SqlCommand(@"
            SELECT TOP 1 NoteText AS Content, FORMAT(CreatedOn,'dd MMM yyyy HH:mm') AS UpdatedOn
            FROM VideoNotes
            WHERE VideoId=@Vid AND SessionId=@Sess AND UserId=@Uid
            ORDER BY CreatedOn DESC");
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
            IF EXISTS (SELECT 1 FROM VideoNotes WHERE VideoId=@Vid AND SessionId=@Sess AND UserId=@Uid)
            BEGIN
                UPDATE VideoNotes
                SET NoteText=@C, CreatedOn=GETDATE()
                WHERE VideoId=@Vid AND SessionId=@Sess AND UserId=@Uid
            END
            ELSE
            BEGIN
                DECLARE @Soc INT, @Inst INT
                SELECT @Soc=SocietyId, @Inst=InstituteId FROM Videos WHERE VideoId=@Vid

                INSERT INTO VideoNotes(SocietyId,InstituteId,SessionId,VideoId,UserId,NoteText,CreatedOn)
                VALUES(@Soc,@Inst,@Sess,@Vid,@Uid,@C,GETDATE())
            END");
        cmd.Parameters.AddWithValue("@Vid", videoId);
        cmd.Parameters.AddWithValue("@Sess", sessionId);
        cmd.Parameters.AddWithValue("@Uid", userId);
        cmd.Parameters.AddWithValue("@C", content ?? "");
        _dl.ExecuteCMD(cmd);
    }

    // ══════════════════════════════════════════════════════════════════════
    //  NEW: MATERIAL STUDY NOTES (Integrated Database Ops)
    // ══════════════════════════════════════════════════════════════════════
    public object GetMaterialNotes(string materialPath, int sessionId, int userId)
    {
        var cmdId = new SqlCommand("SELECT MaterialId FROM Materials WHERE FilePath = @Path AND SessionId = @Sess");
        cmdId.Parameters.AddWithValue("@Path", materialPath);
        cmdId.Parameters.AddWithValue("@Sess", sessionId);
        DataTable dtId = _dl.GetDataTable(cmdId);

        if (dtId == null || dtId.Rows.Count == 0) return new { Content = "", UpdatedOn = "" };
        int materialId = Convert.ToInt32(dtId.Rows[0]["MaterialId"]);

        var cmdNotes = new SqlCommand(@"
            SELECT NoteText, FORMAT(UpdatedOn,'dd MMM yyyy HH:mm') AS UpdatedOn 
            FROM MaterialNotes 
            WHERE MaterialId = @MatId AND UserId = @UserId");
        cmdNotes.Parameters.AddWithValue("@MatId", materialId);
        cmdNotes.Parameters.AddWithValue("@UserId", userId);
        DataTable dtNotes = _dl.GetDataTable(cmdNotes);

        if (dtNotes != null && dtNotes.Rows.Count > 0)
        {
            return new
            {
                Content = dtNotes.Rows[0]["NoteText"]?.ToString() ?? "",
                UpdatedOn = dtNotes.Rows[0]["UpdatedOn"]?.ToString() ?? ""
            };
        }
        return new { Content = "", UpdatedOn = "" };
    }

    public void SaveMaterialNotes(string materialPath, int sessionId, int userId, string content)
    {
        var cmdId = new SqlCommand("SELECT MaterialId, SocietyId, InstituteId FROM Materials WHERE FilePath = @Path AND SessionId = @Sess");
        cmdId.Parameters.AddWithValue("@Path", materialPath);
        cmdId.Parameters.AddWithValue("@Sess", sessionId);
        DataTable dtId = _dl.GetDataTable(cmdId);

        if (dtId == null || dtId.Rows.Count == 0) return;

        int materialId = Convert.ToInt32(dtId.Rows[0]["MaterialId"]);
        int societyId = Convert.ToInt32(dtId.Rows[0]["SocietyId"]);
        int instituteId = Convert.ToInt32(dtId.Rows[0]["InstituteId"]);

        var cmdUpsert = new SqlCommand(@"
            IF EXISTS (SELECT 1 FROM MaterialNotes WHERE MaterialId = @MatId AND UserId = @UserId)
                UPDATE MaterialNotes SET NoteText = @Content, UpdatedOn = GETDATE() WHERE MaterialId = @MatId AND UserId = @UserId;
            ELSE
                INSERT INTO MaterialNotes (SocietyId, InstituteId, SessionId, MaterialId, UserId, NoteText, UpdatedOn)
                VALUES (@SocId, @InstId, @SessId, @MatId, @UserId, @Content, GETDATE());");
        cmdUpsert.Parameters.AddWithValue("@SocId", societyId);
        cmdUpsert.Parameters.AddWithValue("@InstId", instituteId);
        cmdUpsert.Parameters.AddWithValue("@SessId", sessionId);
        cmdUpsert.Parameters.AddWithValue("@MatId", materialId);
        cmdUpsert.Parameters.AddWithValue("@UserId", userId);
        cmdUpsert.Parameters.AddWithValue("@Content", content ?? "");

        _dl.ExecuteCMD(cmdUpsert);
    }
}