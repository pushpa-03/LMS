using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

public class NotificationBL
{
    private readonly DataLayer _dl = new DataLayer();

    // ══════════════════════════════════════════════════════════════
    //  MY INBOX STATS  (banner — current user + current session)
    // ══════════════════════════════════════════════════════════════
    public DataTable GetStats(int instituteId, int sessionId, int userId)
    {
        var cmd = new SqlCommand(@"
            SELECT
                COUNT(*)                                                    AS Total,
                SUM(CASE WHEN IsRead=0 THEN 1 ELSE 0 END)                   AS Unread,
                SUM(CASE WHEN IsRead=1 THEN 1 ELSE 0 END)                   AS ReadCount,
                SUM(CASE WHEN CAST(CreatedOn AS DATE)=CAST(GETDATE() AS DATE)
                         THEN 1 ELSE 0 END)                                 AS Today,
                SUM(CASE WHEN CreatedOn >= DATEADD(DAY,-7,GETDATE())
                         THEN 1 ELSE 0 END)                                 AS ThisWeek
            FROM Notifications
            WHERE InstituteId=@I AND SessionId=@S AND UserId=@U;");
        cmd.Parameters.AddWithValue("@I", instituteId);
        cmd.Parameters.AddWithValue("@S", sessionId);
        cmd.Parameters.AddWithValue("@U", userId);
        return _dl.GetDataTable(cmd) ?? new DataTable();
    }

    // ══════════════════════════════════════════════════════════════
    //  INSTITUTE-WIDE STATS  (stat cards — admin overview)
    //  SentBatches    = distinct GUID batches (one per send action)
    //  TotalDelivered = total rows in institute
    //  TotalRead      = rows where IsRead=1
    //  TotalUnread    = rows where IsRead=0
    //  SentToday      = distinct batches created today
    // ══════════════════════════════════════════════════════════════
    public DataTable GetInstStats(int instituteId)
    {
        var cmd = new SqlCommand(@"
            SELECT
                COUNT(DISTINCT CASE WHEN SentBatchId IS NOT NULL
                                    THEN SentBatchId END)               AS SentBatches,
                COUNT(*)                                                 AS TotalDelivered,
                SUM(CASE WHEN IsRead=1 THEN 1 ELSE 0 END)               AS TotalRead,
                SUM(CASE WHEN IsRead=0 THEN 1 ELSE 0 END)               AS TotalUnread,
                COUNT(DISTINCT CASE
                    WHEN SentBatchId IS NOT NULL
                     AND CAST(CreatedOn AS DATE)=CAST(GETDATE() AS DATE)
                    THEN SentBatchId END)                                AS SentToday
            FROM Notifications
            WHERE InstituteId=@I;");
        cmd.Parameters.AddWithValue("@I", instituteId);
        return _dl.GetDataTable(cmd) ?? new DataTable();
    }

    // ══════════════════════════════════════════════════════════════
    //  UNREAD COUNT  (header badge)
    // ══════════════════════════════════════════════════════════════
    public int GetUnreadCount(int instituteId, int sessionId, int userId)
    {
        var cmd = new SqlCommand(@"
            SELECT COUNT(*) FROM Notifications
            WHERE InstituteId=@I AND SessionId=@S AND UserId=@U AND IsRead=0;");
        cmd.Parameters.AddWithValue("@I", instituteId);
        cmd.Parameters.AddWithValue("@S", sessionId);
        cmd.Parameters.AddWithValue("@U", userId);
        var dt = _dl.GetDataTable(cmd);
        return dt?.Rows.Count > 0 ? Convert.ToInt32(dt.Rows[0][0]) : 0;
    }

    // ══════════════════════════════════════════════════════════════
    //  TOP-2 PREVIEW  (header dropdown)
    // ══════════════════════════════════════════════════════════════
    public DataTable GetTopPreview(int instituteId, int sessionId, int userId, int topN = 2)
    {
        var cmd = new SqlCommand(@"
            SELECT TOP (@N)
                NotificationId,
                Message,
                ISNULL(LTRIM(RTRIM(NotificationType)),'General') AS NotificationType,
                IsRead, CreatedOn,
                DATEDIFF(MINUTE, CreatedOn, GETDATE()) AS MinutesAgo
            FROM Notifications
            WHERE InstituteId=@I AND SessionId=@S AND UserId=@U
            ORDER BY CreatedOn DESC;");
        cmd.Parameters.AddWithValue("@N", topN);
        cmd.Parameters.AddWithValue("@I", instituteId);
        cmd.Parameters.AddWithValue("@S", sessionId);
        cmd.Parameters.AddWithValue("@U", userId);
        return _dl.GetDataTable(cmd) ?? new DataTable();
    }

    // ══════════════════════════════════════════════════════════════
    //  RECEIVED LIST  (paginated — current user + session)
    // ══════════════════════════════════════════════════════════════
    public DataTable GetList(int instituteId, int sessionId, int userId,
        string readFilter, string typeFilter, string search, int page, int pageSize)
    {
        var cmd = new SqlCommand(@"
            SELECT * FROM (
                SELECT
                    ROW_NUMBER() OVER (ORDER BY n.CreatedOn DESC) AS RowNum,
                    n.NotificationId, n.Message,
                    ISNULL(LTRIM(RTRIM(n.NotificationType)),'General') AS NotificationType,
                    n.IsRead, n.CreatedOn,
                    DATEDIFF(MINUTE, n.CreatedOn, GETDATE()) AS MinutesAgo
                FROM Notifications n
                WHERE n.InstituteId=@I AND n.SessionId=@S AND n.UserId=@U
                  AND (@Type=''   OR LTRIM(RTRIM(n.NotificationType))=@Type)
                  AND (@Search='' OR n.Message         LIKE '%'+@Search+'%'
                                 OR n.NotificationType LIKE '%'+@Search+'%')
                  AND (@Filter='All'
                       OR (@Filter='Unread' AND n.IsRead=0)
                       OR (@Filter='Read'   AND n.IsRead=1))
            ) T WHERE RowNum BETWEEN @Skip+1 AND @Skip+@Size;");
        cmd.Parameters.AddWithValue("@I", instituteId);
        cmd.Parameters.AddWithValue("@S", sessionId);
        cmd.Parameters.AddWithValue("@U", userId);
        cmd.Parameters.AddWithValue("@Type", typeFilter?.Trim() ?? "");
        cmd.Parameters.AddWithValue("@Search", search?.Trim() ?? "");
        cmd.Parameters.AddWithValue("@Filter", readFilter ?? "All");
        cmd.Parameters.AddWithValue("@Skip", (page - 1) * pageSize);
        cmd.Parameters.AddWithValue("@Size", pageSize);
        return _dl.GetDataTable(cmd) ?? new DataTable();
    }

    public int GetListCount(int instituteId, int sessionId, int userId,
        string readFilter, string typeFilter, string search)
    {
        var cmd = new SqlCommand(@"
            SELECT COUNT(*) FROM Notifications
            WHERE InstituteId=@I AND SessionId=@S AND UserId=@U
              AND (@Type=''   OR LTRIM(RTRIM(NotificationType))=@Type)
              AND (@Search='' OR Message         LIKE '%'+@Search+'%'
                             OR NotificationType LIKE '%'+@Search+'%')
              AND (@Filter='All'
                   OR (@Filter='Unread' AND IsRead=0)
                   OR (@Filter='Read'   AND IsRead=1));");
        cmd.Parameters.AddWithValue("@I", instituteId);
        cmd.Parameters.AddWithValue("@S", sessionId);
        cmd.Parameters.AddWithValue("@U", userId);
        cmd.Parameters.AddWithValue("@Type", typeFilter?.Trim() ?? "");
        cmd.Parameters.AddWithValue("@Search", search?.Trim() ?? "");
        cmd.Parameters.AddWithValue("@Filter", readFilter ?? "All");
        var dt = _dl.GetDataTable(cmd);
        return dt?.Rows.Count > 0 ? Convert.ToInt32(dt.Rows[0][0]) : 0;
    }

    // ══════════════════════════════════════════════════════════════
    //  DISTINCT TYPES — received tab (user + session scoped)
    // ══════════════════════════════════════════════════════════════
    public DataTable GetDistinctTypes(int instituteId, int sessionId, int userId)
    {
        var cmd = new SqlCommand(@"
            SELECT DISTINCT ISNULL(LTRIM(RTRIM(NotificationType)),'General') AS T
            FROM Notifications
            WHERE InstituteId=@I AND SessionId=@S AND UserId=@U ORDER BY T;");
        cmd.Parameters.AddWithValue("@I", instituteId);
        cmd.Parameters.AddWithValue("@S", sessionId);
        cmd.Parameters.AddWithValue("@U", userId);
        return _dl.GetDataTable(cmd) ?? new DataTable();
    }

    // ══════════════════════════════════════════════════════════════
    //  DISTINCT TYPES — sent tab (institute-wide, all sessions)
    // ══════════════════════════════════════════════════════════════
    public DataTable GetAllDistinctTypes(int instituteId)
    {
        var cmd = new SqlCommand(@"
            SELECT DISTINCT ISNULL(LTRIM(RTRIM(NotificationType)),'General') AS T
            FROM Notifications
            WHERE InstituteId=@I AND SentBatchId IS NOT NULL ORDER BY T;");
        cmd.Parameters.AddWithValue("@I", instituteId);
        return _dl.GetDataTable(cmd) ?? new DataTable();
    }

    // ══════════════════════════════════════════════════════════════
    //  SENT LIST — GROUP BY SentBatchId (simple, always works)
    // ══════════════════════════════════════════════════════════════
    public DataTable GetSentList(int instituteId,
        string typeFilter, string search, int page, int pageSize)
    {
        var cmd = new SqlCommand(@"
            SELECT * FROM (
                SELECT
                    ROW_NUMBER() OVER (ORDER BY MAX(n.CreatedOn) DESC) AS RowNum,
                    n.SentBatchId,
                    MIN(n.NotificationId)                               AS NotificationId,
                    n.Message,
                    ISNULL(LTRIM(RTRIM(n.NotificationType)),'General')  AS NotificationType,
                    n.SessionId,
                    COUNT(*)                                             AS RecipientCount,
                    SUM(CASE WHEN n.IsRead=1 THEN 1 ELSE 0 END)         AS ReadCount,
                    MAX(n.CreatedOn)                                     AS CreatedOn,
                    DATEDIFF(MINUTE, MAX(n.CreatedOn), GETDATE())        AS MinutesAgo
                FROM Notifications n
                WHERE n.InstituteId = @I
                  AND n.SentBatchId IS NOT NULL
                  AND (@Type='' OR ISNULL(LTRIM(RTRIM(n.NotificationType)),'General')=@Type)
                  AND (@Search='' OR n.Message LIKE '%'+@Search+'%'
                                 OR n.NotificationType LIKE '%'+@Search+'%')
                GROUP BY n.SentBatchId, n.Message, n.NotificationType,
                         n.SessionId, n.InstituteId
            ) T WHERE RowNum BETWEEN @Skip+1 AND @Skip+@Size;");
        cmd.Parameters.AddWithValue("@I", instituteId);
        cmd.Parameters.AddWithValue("@Type", typeFilter?.Trim() ?? "");
        cmd.Parameters.AddWithValue("@Search", search?.Trim() ?? "");
        cmd.Parameters.AddWithValue("@Skip", (page - 1) * pageSize);
        cmd.Parameters.AddWithValue("@Size", pageSize);

        DataTable dt = _dl.GetDataTable(cmd) ?? new DataTable();
        if (dt.Rows.Count == 0) return dt;

        // Collect batch GUIDs and fetch roles in one separate query
        var batchIds = new List<string>();
        foreach (DataRow r in dt.Rows)
            if (r["SentBatchId"] != DBNull.Value)
                batchIds.Add(r["SentBatchId"].ToString());

        if (batchIds.Count > 0)
        {
            string inList = "'" + string.Join("','", batchIds) + "'";
            var cmd2 = new SqlCommand(
                "SELECT n.SentBatchId, ISNULL(r.RoleName,'User') AS RoleName " +
                "FROM Notifications n " +
                "LEFT JOIN Users u ON u.UserId=n.UserId " +
                "LEFT JOIN Roles r ON r.RoleId=u.RoleId " +
                "WHERE n.SentBatchId IN (" + inList + ") " +
                "GROUP BY n.SentBatchId, ISNULL(r.RoleName,'User');");

            DataTable dtR = _dl.GetDataTable(cmd2) ?? new DataTable();
            var lookup = new Dictionary<string, HashSet<string>>(StringComparer.OrdinalIgnoreCase);
            foreach (DataRow r in dtR.Rows)
            {
                string k = r["SentBatchId"].ToString();
                if (!lookup.ContainsKey(k)) lookup[k] = new HashSet<string>();
                lookup[k].Add(r["RoleName"].ToString());
            }

            if (!dt.Columns.Contains("TargetRoles"))
                dt.Columns.Add("TargetRoles", typeof(string));

            foreach (DataRow row in dt.Rows)
            {
                string k = row["SentBatchId"]?.ToString() ?? "";
                row["TargetRoles"] = lookup.ContainsKey(k) ? string.Join(", ", lookup[k]) : "";
            }
        }
        return dt;
    }

    public int GetSentCount(int instituteId, string typeFilter, string search)
    {
        var cmd = new SqlCommand(@"
            SELECT COUNT(DISTINCT SentBatchId) FROM Notifications
            WHERE InstituteId=@I AND SentBatchId IS NOT NULL
              AND (@Type='' OR ISNULL(LTRIM(RTRIM(NotificationType)),'General')=@Type)
              AND (@Search='' OR Message LIKE '%'+@Search+'%'
                             OR NotificationType LIKE '%'+@Search+'%');");
        cmd.Parameters.AddWithValue("@I", instituteId);
        cmd.Parameters.AddWithValue("@Type", typeFilter?.Trim() ?? "");
        cmd.Parameters.AddWithValue("@Search", search?.Trim() ?? "");
        var dt = _dl.GetDataTable(cmd);
        return dt?.Rows.Count > 0 ? Convert.ToInt32(dt.Rows[0][0]) : 0;
    }

    public void MarkRead(int notificationId, int userId)
    {
        var cmd = new SqlCommand("UPDATE Notifications SET IsRead=1 WHERE NotificationId=@Id AND UserId=@U;");
        cmd.Parameters.AddWithValue("@Id", notificationId);
        cmd.Parameters.AddWithValue("@U", userId);
        _dl.ExecuteCMD(cmd);
    }

    public void MarkAllRead(int instituteId, int sessionId, int userId)
    {
        var cmd = new SqlCommand("UPDATE Notifications SET IsRead=1 WHERE InstituteId=@I AND SessionId=@S AND UserId=@U AND IsRead=0;");
        cmd.Parameters.AddWithValue("@I", instituteId);
        cmd.Parameters.AddWithValue("@S", sessionId);
        cmd.Parameters.AddWithValue("@U", userId);
        _dl.ExecuteCMD(cmd);
    }

    public void DeleteOne(int notificationId, int userId)
    {
        var cmd = new SqlCommand("DELETE FROM Notifications WHERE NotificationId=@Id AND UserId=@U;");
        cmd.Parameters.AddWithValue("@Id", notificationId);
        cmd.Parameters.AddWithValue("@U", userId);
        _dl.ExecuteCMD(cmd);
    }

    public void DeleteAll(int instituteId, int sessionId, int userId)
    {
        var cmd = new SqlCommand("DELETE FROM Notifications WHERE InstituteId=@I AND SessionId=@S AND UserId=@U;");
        cmd.Parameters.AddWithValue("@I", instituteId);
        cmd.Parameters.AddWithValue("@S", sessionId);
        cmd.Parameters.AddWithValue("@U", userId);
        _dl.ExecuteCMD(cmd);
    }

    // ══════════════════════════════════════════════════════════════
    //  SEND — stamps every row with same GUID (SentBatchId)
    // ══════════════════════════════════════════════════════════════
    public int SendNotification(int societyId, int instituteId, int sessionId,
        string message, string notifType, List<int> targetUserIds)
    {
        if (string.IsNullOrWhiteSpace(message)) return 0;

        if (targetUserIds == null || targetUserIds.Count == 0)
        {
            var all = new SqlCommand("SELECT UserId FROM Users WHERE InstituteId=@I AND SessionId=@S AND IsActive=1;");
            all.Parameters.AddWithValue("@I", instituteId);
            all.Parameters.AddWithValue("@S", sessionId);
            var dtAll = _dl.GetDataTable(all);
            targetUserIds = new List<int>();
            if (dtAll != null) foreach (DataRow r in dtAll.Rows) targetUserIds.Add(Convert.ToInt32(r["UserId"]));
        }
        if (targetUserIds.Count == 0) return 0;

        string safeType = string.IsNullOrWhiteSpace(notifType) ? "General" : notifType.Trim();
        Guid batch = Guid.NewGuid();

        var cmds = new List<SqlCommand>();
        foreach (int uid in targetUserIds)
        {
            var c = new SqlCommand(@"
                INSERT INTO Notifications
                    (SocietyId,InstituteId,SessionId,UserId,Message,NotificationType,IsRead,CreatedOn,SentBatchId)
                VALUES(@Soc,@I,@S,@U,@Msg,@Type,0,GETDATE(),@B);");
            c.Parameters.AddWithValue("@Soc", societyId);
            c.Parameters.AddWithValue("@I", instituteId);
            c.Parameters.AddWithValue("@S", sessionId);
            c.Parameters.AddWithValue("@U", uid);
            c.Parameters.AddWithValue("@Msg", message.Trim());
            c.Parameters.AddWithValue("@Type", safeType);
            c.Parameters.AddWithValue("@B", batch);
            cmds.Add(c);
        }
        _dl.ExecuteTransaction(cmds);
        return targetUserIds.Count;
    }

    public DataTable GetUsersByRole(int instituteId, int sessionId, string role)
    {
        var cmd = new SqlCommand(@"
            SELECT u.UserId, ISNULL(up.FullName,u.Username) AS FullName,
                   ISNULL(r.RoleName,'User') AS RoleName, u.Email
            FROM Users u
            LEFT JOIN UserProfile up ON up.UserId=u.UserId
            LEFT JOIN Roles r        ON r.RoleId =u.RoleId
            WHERE u.InstituteId=@I AND u.SessionId=@S AND u.IsActive=1
              AND (@Role='' OR r.RoleName=@Role)
              AND ISNULL(r.RoleName,'') NOT IN ('SuperAdmin','Admin')
            ORDER BY r.RoleName, ISNULL(up.FullName,u.Username);");
        cmd.Parameters.AddWithValue("@I", instituteId);
        cmd.Parameters.AddWithValue("@S", sessionId);
        cmd.Parameters.AddWithValue("@Role", role?.Trim() ?? "");
        return _dl.GetDataTable(cmd) ?? new DataTable();
    }
}