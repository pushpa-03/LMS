using System;
using System.Data;
using System.Data.SqlClient;

public class VideoPlayerBL
{
    DataLayer dl = new DataLayer();

    public DataTable GetVideoDetails(int videoId)
    {
        SqlCommand cmd = new SqlCommand(@"
        SELECT *
        FROM Videos
        WHERE VideoId=@VideoId AND IsActive=1
        ");

        cmd.Parameters.AddWithValue("@VideoId", videoId);

        return dl.GetDataTable(cmd);
    }

    public void IncreaseViewCount(int videoId)
    {
        SqlCommand cmd = new SqlCommand(@"
        UPDATE Videos
        SET ViewCount = ISNULL(ViewCount,0) + 1
        WHERE VideoId=@VideoId
        ");

        cmd.Parameters.AddWithValue("@VideoId", videoId);

        dl.ExecuteCMD(cmd);
    }

    public void SaveNote(int videoId, int userId, string note, int seconds)
    {
        SqlCommand cmd = new SqlCommand(@"
        INSERT INTO VideoNotes(VideoId,UserId,NoteText,TimeStampSeconds)
        VALUES(@V,@U,@N,@T)
        ");

        cmd.Parameters.AddWithValue("@V", videoId);
        cmd.Parameters.AddWithValue("@U", userId);
        cmd.Parameters.AddWithValue("@N", note);
        cmd.Parameters.AddWithValue("@T", seconds);

        dl.ExecuteCMD(cmd);
    }

    public DataTable GetNotes(int videoId, int userId)
    {
        SqlCommand cmd = new SqlCommand(@"
        SELECT *
        FROM VideoNotes
        WHERE VideoId=@V AND UserId=@U
        ORDER BY TimeStampSeconds
        ");

        cmd.Parameters.AddWithValue("@V", videoId);
        cmd.Parameters.AddWithValue("@U", userId);

        return dl.GetDataTable(cmd);
    }

    public void SaveDoubt(int videoId, int userId, string doubt, int seconds)
    {
        SqlCommand cmd = new SqlCommand(@"
        INSERT INTO VideoDoubts(VideoId,UserId,DoubtText,TimeStampSeconds)
        VALUES(@V,@U,@D,@T)
        ");

        cmd.Parameters.AddWithValue("@V", videoId);
        cmd.Parameters.AddWithValue("@U", userId);
        cmd.Parameters.AddWithValue("@D", doubt);
        cmd.Parameters.AddWithValue("@T", seconds);

        dl.ExecuteCMD(cmd);
    }
    public DataTable GetVideoTopics(int videoId)
    {
        // Fetches timestamps/topics defined for this video
        SqlCommand cmd = new SqlCommand(@"
        SELECT StartTime, TopicTitle 
        FROM VideoTopics 
        WHERE VideoId = @VideoId 
        ORDER BY StartTime");
        cmd.Parameters.AddWithValue("@VideoId", videoId);
        return dl.GetDataTable(cmd);
    }

    public DataTable GetEngagement(int videoId)
    {
        // Joins Progress with Users to show who is watching
        SqlCommand cmd = new SqlCommand(@"
        SELECT U.UserName, P.WatchedPercent 
        FROM VideoWatchProgress P
        INNER JOIN Users U ON P.UserId = U.UserId
        WHERE P.VideoId = @VideoId");
        cmd.Parameters.AddWithValue("@VideoId", videoId);
        return dl.GetDataTable(cmd);
    }

    public void SaveComment(int videoId, int userId, string comment)
    {
        SqlCommand cmd = new SqlCommand(@"
        INSERT INTO VideoComments(VideoId,UserId,Comment)
        VALUES(@V,@U,@C)
        ");

        cmd.Parameters.AddWithValue("@V", videoId);
        cmd.Parameters.AddWithValue("@U", userId);
        cmd.Parameters.AddWithValue("@C", comment);

        dl.ExecuteCMD(cmd);
    }

    public DataTable GetVideoStats(int videoId)
    {
        SqlCommand cmd = new SqlCommand(@"
    SELECT 
        (SELECT COUNT(*) FROM VideoViews WHERE VideoId=@V) Views,
        (SELECT COUNT(DISTINCT UserId) FROM VideoViews WHERE VideoId=@V) Students,
        (SELECT ISNULL(AVG(WatchedPercent),0) FROM VideoWatchProgress WHERE VideoId=@V) Completion,
        (SELECT COUNT(*) FROM VideoComments WHERE VideoId=@V) Comments
    ");

        cmd.Parameters.AddWithValue("@V", videoId);
        return dl.GetDataTable(cmd);
    }

    public DataTable GetComments(int videoId)
    {
        SqlCommand cmd = new SqlCommand(@"
    SELECT C.CommentId,U.Username,C.Comment
    FROM VideoComments C
    JOIN Users U ON U.UserId=C.UserId
    WHERE C.VideoId=@V
    ORDER BY C.CommentedOn DESC");

        cmd.Parameters.AddWithValue("@V", videoId);
        return dl.GetDataTable(cmd);
    }

    public void DeleteComment(int id)
    {
        SqlCommand cmd = new SqlCommand("DELETE FROM VideoComments WHERE CommentId=@Id");
        cmd.Parameters.AddWithValue("@Id", id);
        dl.ExecuteCMD(cmd);
    }

    public DataTable GetPlaylist(int videoId)
    {
        SqlCommand cmd = new SqlCommand(@"
    SELECT VideoId,Title
    FROM Videos
    WHERE IsActive=1");

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

    public int GetNextVideo(int videoId)
    {
        SqlCommand cmd = new SqlCommand(@"
        SELECT TOP 1 VideoId 
        FROM Videos 
        WHERE VideoId > @V AND IsActive=1
        ORDER BY VideoId");

        cmd.Parameters.AddWithValue("@V", videoId);

        DataTable dt = dl.GetDataTable(cmd);

        if (dt.Rows.Count > 0)
            return Convert.ToInt32(dt.Rows[0]["VideoId"]);

        return videoId; // fallback
    }

    public int GetPrevVideo(int videoId)
    {
        SqlCommand cmd = new SqlCommand(@"
        SELECT TOP 1 VideoId 
        FROM Videos 
        WHERE VideoId < @V AND IsActive=1
        ORDER BY VideoId DESC");

        cmd.Parameters.AddWithValue("@V", videoId);

        DataTable dt = dl.GetDataTable(cmd);

        if (dt.Rows.Count > 0)
            return Convert.ToInt32(dt.Rows[0]["VideoId"]);

        return videoId; // fallback
    }
}