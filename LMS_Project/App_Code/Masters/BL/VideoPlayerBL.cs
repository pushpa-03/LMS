using System;
using System.Data;
using System.Data.SqlClient;

public class VideoPlayerBL
{
    DataLayer dl = new DataLayer();

    public DataTable GetVideoDetails(int videoId,int sessionId)
    {
        SqlCommand cmd = new SqlCommand(@"
        SELECT *
        FROM Videos
        WHERE VideoId=@VideoId AND IsActive=1  And SessionId = @SessionId
        ");

        cmd.Parameters.AddWithValue("@VideoId", videoId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);

        return dl.GetDataTable(cmd);
    }

    //public void IncreaseViewCount(int videoId,int sessionId)
    //{
    //    SqlCommand cmd = new SqlCommand(@"
    //    UPDATE Videos
    //    SET ViewCount = ISNULL(ViewCount,0) + 1
    //    WHERE VideoId=@VideoId AND SessionId = @SessionId
    //    ");

    //    cmd.Parameters.AddWithValue("@VideoId", videoId);
    //    cmd.Parameters.AddWithValue("@SessionId", sessionId);

    //    dl.ExecuteCMD(cmd);
    //}

    public void IncreaseViewCount(int videoId, int sessionId, int userId, int instituteId)
    {
        SqlCommand cmd = new SqlCommand(@"

    -- 1. Insert into VideoViews (MAIN tracking table)
    IF NOT EXISTS (
    SELECT 1 FROM VideoViews
    WHERE VideoId=@VideoId 
      AND UserId=@UserId
      AND SessionId=@SessionId
)
BEGIN
    INSERT INTO VideoViews(VideoId, UserId, InstituteId, SessionId, ViewedOn)
    VALUES(@VideoId, @UserId, @InstituteId, @SessionId, GETDATE());
END

    -- 2. Optional counter (for fast display)
    UPDATE Videos
    SET ViewCount = ISNULL(ViewCount,0) + 1
    WHERE VideoId=@VideoId AND SessionId = @SessionId
    ");

        cmd.Parameters.AddWithValue("@VideoId", videoId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);
        cmd.Parameters.AddWithValue("@UserId", userId);
        cmd.Parameters.AddWithValue("@InstituteId", instituteId);

        dl.ExecuteCMD(cmd);
    }

    public void SaveNote(int videoId, int sessionId, int userId, string note, int seconds)
    {
        SqlCommand cmd = new SqlCommand(@"
        INSERT INTO VideoNotes(VideoId, SessionId,UserId,NoteText,TimeStampSeconds)
        VALUES(@V,@SessionId, @U,@N,@T)
        ");

        cmd.Parameters.AddWithValue("@V", videoId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);
        cmd.Parameters.AddWithValue("@U", userId);
        cmd.Parameters.AddWithValue("@N", note);
        cmd.Parameters.AddWithValue("@T", seconds);

        dl.ExecuteCMD(cmd);
    }

    public DataTable GetNotes(int videoId, int sessionId, int userId)
    {
        SqlCommand cmd = new SqlCommand(@"
        SELECT *
        FROM VideoNotes
        WHERE VideoId=@V AND UserId=@U AND SessionId = @SessionId
        ORDER BY TimeStampSeconds
        ");

        cmd.Parameters.AddWithValue("@V", videoId);
        cmd.Parameters.AddWithValue("@U", userId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);

        return dl.GetDataTable(cmd);
    }

    public void SaveDoubt(int videoId,int sessionId, int userId, string doubt, int seconds)
    {
        SqlCommand cmd = new SqlCommand(@"
        INSERT INTO VideoDoubts(VideoId, SessionId,UserId,DoubtText,TimeStampSeconds)
        VALUES(@V, @SessionId,@U,@D,@T)
        ");

        cmd.Parameters.AddWithValue("@V", videoId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);
        cmd.Parameters.AddWithValue("@U", userId);
        cmd.Parameters.AddWithValue("@D", doubt);
        cmd.Parameters.AddWithValue("@T", seconds);

        dl.ExecuteCMD(cmd);
    }
    public DataTable GetVideoTopics(int videoId, int sessionId)
    {
        // Fetches timestamps/topics defined for this video
        SqlCommand cmd = new SqlCommand(@"
        SELECT StartTime, TopicTitle 
        FROM VideoTopics 
        WHERE VideoId = @VideoId AND SessionId = @SessionId
        ORDER BY StartTime");
        cmd.Parameters.AddWithValue("@VideoId", videoId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);

        return dl.GetDataTable(cmd);
    }

    public DataTable GetEngagement(int videoId, int sessionId)
    {
        // Joins Progress with Users to show who is watching
        SqlCommand cmd = new SqlCommand(@"
        SELECT U.UserName, P.WatchedPercent 
        FROM VideoWatchProgress P
        INNER JOIN Users U ON P.UserId = U.UserId
        WHERE P.VideoId = @VideoId AND P.SessionId = @SessionId");
        cmd.Parameters.AddWithValue("@VideoId", videoId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);

        return dl.GetDataTable(cmd);
    }

    public void SaveComment(int vid, int sessionId, int userId, string msg, int societyId, int instituteId)
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

    public DataTable GetVideoStats(int videoId, int sessionId)
    {
        SqlCommand cmd = new SqlCommand(@"
    SELECT 
        (SELECT COUNT(*) FROM VideoViews WHERE VideoId=@V AND SessionId = @SessionId) Views,
        (SELECT COUNT(DISTINCT UserId) FROM VideoViews WHERE VideoId=@V AND SessionId = @SessionId) Students,
        (SELECT ISNULL(AVG(WatchedPercent),0) FROM VideoWatchProgress WHERE VideoId=@V AND SessionId = @SessionId) Completion,
        (SELECT COUNT(*) FROM VideoComments WHERE VideoId=@V AND SessionId = @SessionId) Comments
    ");

        cmd.Parameters.AddWithValue("@V", videoId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);
        return dl.GetDataTable(cmd);
    }

    public DataTable GetComments(int videoId,int sessionId)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT C.CommentId,U.Username,C.Comment
            FROM VideoComments C
            JOIN Users U ON U.UserId=C.UserId
            WHERE C.VideoId=@V AND C.SessionId = @SessionId
            ORDER BY C.CommentedOn DESC");

        cmd.Parameters.AddWithValue("@V", videoId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);
        return dl.GetDataTable(cmd);
    }

    public void DeleteComment(int id, int sessionId)
    {
        SqlCommand cmd = new SqlCommand("DELETE FROM VideoComments WHERE CommentId=@Id AND SessionId = @SessionId");
        cmd.Parameters.AddWithValue("@Id", id);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);
        dl.ExecuteCMD(cmd);
    }

    public DataTable GetPlaylist(int videoId,int sessionId)
    {
        // Added 'Duration' to the SELECT statement
        SqlCommand cmd = new SqlCommand(@"
        SELECT VideoId, Title, Duration 
        FROM Videos 
        WHERE IsActive = 1 AND SessionId = @SessionId
        ORDER BY VideoId ASC");

        cmd.Parameters.AddWithValue("@SessionId", sessionId);

        return dl.GetDataTable(cmd);
    }

    public void ToggleVideo(int videoId)
    {
        SqlCommand cmd = new SqlCommand(@"
    UPDATE Videos
    SET IsActive = CASE WHEN IsActive=1 THEN 0 ELSE 1 END
    WHERE VideoId=@V");

        cmd.Parameters.AddWithValue("@V", videoId);
        dl.ExecuteCMD(cmd);
    }

    public double GetAverageRating(int videoId)
    {
        // 1. Create the Command
        SqlCommand cmd = new SqlCommand("SELECT ISNULL(AVG(CAST(Rating AS FLOAT)), 4.5) AS AvgRating FROM VideoRatings WHERE VideoId = @vid");
        cmd.Parameters.AddWithValue("@vid", videoId);

        // 2. Use GetDataTable from your DataLayer
        DataTable dt = dl.GetDataTable(cmd);

        // 3. Extract the value safely
        if (dt != null && dt.Rows.Count > 0)
        {
            return Convert.ToDouble(dt.Rows[0]["AvgRating"]);
        }

        return 4.5; // Default fallback if something goes wrong
    }
    public int GetNextVideo(int videoId, int sessionId)
    {
        SqlCommand cmd = new SqlCommand(@"
        SELECT TOP 1 VideoId 
        FROM Videos 
        WHERE VideoId > @V AND IsActive=1 AND SessionId = @SessionId
        ORDER BY VideoId");

        cmd.Parameters.AddWithValue("@V", videoId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);

        DataTable dt = dl.GetDataTable(cmd);

        if (dt != null || dt.Rows.Count > 0)
            return Convert.ToInt32(dt.Rows[0]["VideoId"]);

        return videoId; // fallback
    }

    public int GetPrevVideo(int videoId, int sessionId)
    {
        SqlCommand cmd = new SqlCommand(@"
        SELECT TOP 1 VideoId 
        FROM Videos 
        WHERE VideoId < @V AND IsActive=1 AND SessionId
        ORDER BY VideoId DESC");

        cmd.Parameters.AddWithValue("@V", videoId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);

        DataTable dt = dl.GetDataTable(cmd);

        if (dt != null || dt.Rows.Count > 0)
            return Convert.ToInt32(dt.Rows[0]["VideoId"]);

        return videoId; // fallback
    }
}