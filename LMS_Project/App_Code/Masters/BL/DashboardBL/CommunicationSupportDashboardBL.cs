using System;
using System.Data;
using System.Data.SqlClient;

public class CommunicationSupportDashboardBL
{
    private readonly DataLayer dl = new DataLayer();

    // ── Safe wrappers — NEVER throw, always return empty DataTable/0 ──
    private DataTable Safe(SqlCommand cmd, string tag)
    {
        try { return dl.GetDataTable(cmd); }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("[CommBL." + tag + "] " + ex.Message);
            return new DataTable();
        }
    }

    private int SafeInt(SqlCommand cmd, string tag)
    {
        try
        {
            var dt = dl.GetDataTable(cmd);
            return dt?.Rows.Count > 0 && dt.Rows[0][0] != DBNull.Value
                ? Convert.ToInt32(dt.Rows[0][0]) : 0;
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("[CommBL." + tag + "] " + ex.Message);
            return 0;
        }
    }

    private object Dt(string s)
    {
        if (string.IsNullOrWhiteSpace(s)) return DBNull.Value;
        DateTime d;
        return DateTime.TryParse(s, out d) ? (object)d.Date : DBNull.Value;
    }

    // ═══════════════════════════════════════════════════════════
    // DROPDOWNS
    // ═══════════════════════════════════════════════════════════
    public DataTable GetStreams(int inst, int sess)
    {
        var cmd = new SqlCommand(
            "SELECT StreamId, StreamName FROM Streams " +
            "WHERE InstituteId=@I AND SessionId=@S AND IsActive=1 ORDER BY StreamName;");
        cmd.Parameters.AddWithValue("@I", inst);
        cmd.Parameters.AddWithValue("@S", sess);
        return Safe(cmd, "GetStreams");
    }

    public DataTable GetRoles(int inst)
    {
        var cmd = new SqlCommand(
            "SELECT DISTINCT r.RoleName FROM Roles r " +
            "INNER JOIN Users u ON u.RoleId=r.RoleId " +
            "WHERE u.InstituteId=@I AND ISNULL(r.RoleName,'')<>'' " +
            "ORDER BY r.RoleName;");
        cmd.Parameters.AddWithValue("@I", inst);
        return Safe(cmd, "GetRoles");
    }

    // ═══════════════════════════════════════════════════════════
    // KPI SUMMARY  — each block isolated
    // ═══════════════════════════════════════════════════════════
    public DataTable GetKPISummary(int inst, int sess, string dateFrom, string dateTo)
    {
        var result = new DataTable();
        result.Columns.Add("TotalNotifications", typeof(int));
        result.Columns.Add("UnreadNotifications", typeof(int));
        result.Columns.Add("TotalHelpRequests", typeof(int));
        result.Columns.Add("OpenHelpRequests", typeof(int));
        result.Columns.Add("TotalAnnouncements", typeof(int));
        result.Columns.Add("TotalMessages", typeof(int));
        result.Columns.Add("ActiveThreads", typeof(int));
        result.Columns.Add("TotalUsers", typeof(int));
        result.Columns.Add("EngagedUsers", typeof(int));
        result.Columns.Add("ResolutionRate", typeof(decimal));

        var row = result.NewRow();
        row["TotalNotifications"] = 0;
        row["UnreadNotifications"] = 0;
        row["TotalHelpRequests"] = 0;
        row["OpenHelpRequests"] = 0;
        row["TotalAnnouncements"] = 0;
        row["TotalMessages"] = 0;
        row["ActiveThreads"] = 0;
        row["TotalUsers"] = 0;
        row["EngagedUsers"] = 0;
        row["ResolutionRate"] = 0m;

        // 1. Notifications total
        try
        {
            var c = new SqlCommand(
                "SELECT COUNT(*) FROM Notifications " +
                "WHERE InstituteId=@I AND SessionId=@S " +
                "AND (@DFr IS NULL OR CAST(CreatedOn AS DATE)>=@DFr) " +
                "AND (@DTo IS NULL OR CAST(CreatedOn AS DATE)<=@DTo);");
            c.Parameters.AddWithValue("@I", inst);
            c.Parameters.AddWithValue("@S", sess);
            c.Parameters.AddWithValue("@DFr", Dt(dateFrom));
            c.Parameters.AddWithValue("@DTo", Dt(dateTo));
            row["TotalNotifications"] = SafeInt(c, "KPI.TotalNotif");
        }
        catch { }

        // 2. Unread notifications
        try
        {
            var c = new SqlCommand(
                "SELECT COUNT(*) FROM Notifications " +
                "WHERE InstituteId=@I AND SessionId=@S AND IsRead=0 " +
                "AND (@DFr IS NULL OR CAST(CreatedOn AS DATE)>=@DFr) " +
                "AND (@DTo IS NULL OR CAST(CreatedOn AS DATE)<=@DTo);");
            c.Parameters.AddWithValue("@I", inst);
            c.Parameters.AddWithValue("@S", sess);
            c.Parameters.AddWithValue("@DFr", Dt(dateFrom));
            c.Parameters.AddWithValue("@DTo", Dt(dateTo));
            row["UnreadNotifications"] = SafeInt(c, "KPI.UnreadNotif");
        }
        catch { }

        // 3. Total help requests
        try
        {
            var c = new SqlCommand(
                "SELECT COUNT(*) FROM HelpRequests " +
                "WHERE InstituteId=@I AND SessionId=@S " +
                "AND (@DFr IS NULL OR CAST(AskedOn AS DATE)>=@DFr) " +
                "AND (@DTo IS NULL OR CAST(AskedOn AS DATE)<=@DTo);");
            c.Parameters.AddWithValue("@I", inst);
            c.Parameters.AddWithValue("@S", sess);
            c.Parameters.AddWithValue("@DFr", Dt(dateFrom));
            c.Parameters.AddWithValue("@DTo", Dt(dateTo));
            row["TotalHelpRequests"] = SafeInt(c, "KPI.TotalHelp");
        }
        catch { }

        // 4. Open help requests (no reply)
        try
        {
            var c = new SqlCommand(
                "SELECT COUNT(*) FROM HelpRequests hr " +
                "WHERE hr.InstituteId=@I AND hr.SessionId=@S " +
                "AND (@DFr IS NULL OR CAST(hr.AskedOn AS DATE)>=@DFr) " +
                "AND (@DTo IS NULL OR CAST(hr.AskedOn AS DATE)<=@DTo) " +
                "AND NOT EXISTS (SELECT 1 FROM HelpReplies r WHERE r.HelpId=hr.HelpId);");
            c.Parameters.AddWithValue("@I", inst);
            c.Parameters.AddWithValue("@S", sess);
            c.Parameters.AddWithValue("@DFr", Dt(dateFrom));
            c.Parameters.AddWithValue("@DTo", Dt(dateTo));
            row["OpenHelpRequests"] = SafeInt(c, "KPI.OpenHelp");
        }
        catch { }

        // 5. Total messages (questions + replies)
        try
        {
            var c1 = new SqlCommand(
                "SELECT COUNT(*) FROM HelpRequests " +
                "WHERE InstituteId=@I AND SessionId=@S " +
                "AND (@DFr IS NULL OR CAST(AskedOn AS DATE)>=@DFr) " +
                "AND (@DTo IS NULL OR CAST(AskedOn AS DATE)<=@DTo);");
            c1.Parameters.AddWithValue("@I", inst); c1.Parameters.AddWithValue("@S", sess);
            c1.Parameters.AddWithValue("@DFr", Dt(dateFrom)); c1.Parameters.AddWithValue("@DTo", Dt(dateTo));
            int q = SafeInt(c1, "KPI.Msg1");

            var c2 = new SqlCommand(
                "SELECT COUNT(*) FROM HelpReplies " +
                "WHERE InstituteId=@I AND SessionId=@S " +
                "AND (@DFr IS NULL OR CAST(RepliedOn AS DATE)>=@DFr) " +
                "AND (@DTo IS NULL OR CAST(RepliedOn AS DATE)<=@DTo);");
            c2.Parameters.AddWithValue("@I", inst); c2.Parameters.AddWithValue("@S", sess);
            c2.Parameters.AddWithValue("@DFr", Dt(dateFrom)); c2.Parameters.AddWithValue("@DTo", Dt(dateTo));
            int r = SafeInt(c2, "KPI.Msg2");

            row["TotalMessages"] = q + r;
            row["ActiveThreads"] = q + r;
        }
        catch { }

        // 6. Total students
        try
        {
            var c = new SqlCommand(
                "SELECT COUNT(DISTINCT UserId) FROM StudentAcademicDetails " +
                "WHERE InstituteId=@I AND SessionId=@S;");
            c.Parameters.AddWithValue("@I", inst);
            c.Parameters.AddWithValue("@S", sess);
            row["TotalUsers"] = SafeInt(c, "KPI.TotalUsers");
        }
        catch { }

        // 7. Engaged users
        try
        {
            var c = new SqlCommand(
                "SELECT COUNT(DISTINCT UserId) FROM Notifications " +
                "WHERE InstituteId=@I AND SessionId=@S " +
                "AND (@DFr IS NULL OR CAST(CreatedOn AS DATE)>=@DFr) " +
                "AND (@DTo IS NULL OR CAST(CreatedOn AS DATE)<=@DTo);");
            c.Parameters.AddWithValue("@I", inst);
            c.Parameters.AddWithValue("@S", sess);
            c.Parameters.AddWithValue("@DFr", Dt(dateFrom));
            c.Parameters.AddWithValue("@DTo", Dt(dateTo));
            row["EngagedUsers"] = SafeInt(c, "KPI.EngagedUsers");
        }
        catch { }

        // 8. Resolution rate
        try
        {
            int total = Convert.ToInt32(row["TotalHelpRequests"]);
            int open = Convert.ToInt32(row["OpenHelpRequests"]);
            row["ResolutionRate"] = total > 0
                ? Math.Round((decimal)(total - open) / total * 100, 1)
                : 0m;
        }
        catch { }

        result.Rows.Add(row);
        return result;
    }

    // ═══════════════════════════════════════════════════════════
    // NOTIFICATION TREND
    // ═══════════════════════════════════════════════════════════
    public DataTable GetNotificationTrend(int inst, int sess, string dateFrom, string dateTo)
    {
        var cmd = new SqlCommand(
            "SELECT CONVERT(VARCHAR(10),CreatedOn,23) AS DateStr, " +
            "COUNT(*) AS Total, " +
            "SUM(CASE WHEN IsRead=1 THEN 1 ELSE 0 END) AS ReadCount, " +
            "SUM(CASE WHEN IsRead=0 THEN 1 ELSE 0 END) AS UnreadCount, " +
            "COUNT(DISTINCT UserId) AS Recipients " +
            "FROM Notifications " +
            "WHERE InstituteId=@I AND SessionId=@S " +
            "AND (@DFr IS NULL OR CAST(CreatedOn AS DATE)>=@DFr) " +
            "AND (@DTo IS NULL OR CAST(CreatedOn AS DATE)<=@DTo) " +
            "GROUP BY CONVERT(VARCHAR(10),CreatedOn,23) ORDER BY DateStr;");
        cmd.Parameters.AddWithValue("@I", inst);
        cmd.Parameters.AddWithValue("@S", sess);
        cmd.Parameters.AddWithValue("@DFr", Dt(dateFrom));
        cmd.Parameters.AddWithValue("@DTo", Dt(dateTo));
        return Safe(cmd, "NotifTrend");
    }

    // ═══════════════════════════════════════════════════════════
    // NOTIFICATION TYPE BREAKDOWN
    // ═══════════════════════════════════════════════════════════
    public DataTable GetNotificationTypes(int inst, int sess, string dateFrom, string dateTo)
    {
        var cmd = new SqlCommand(
            "SELECT ISNULL(LTRIM(RTRIM(NotificationType)),'General') AS NotifType, " +
            "COUNT(*) AS Total, " +
            "SUM(CASE WHEN IsRead=1 THEN 1 ELSE 0 END) AS ReadCount, " +
            "CAST(100.0*SUM(CASE WHEN IsRead=1 THEN 1 ELSE 0 END)/NULLIF(COUNT(*),0) AS DECIMAL(5,1)) AS ReadRate " +
            "FROM Notifications " +
            "WHERE InstituteId=@I AND SessionId=@S " +
            "AND (@DFr IS NULL OR CAST(CreatedOn AS DATE)>=@DFr) " +
            "AND (@DTo IS NULL OR CAST(CreatedOn AS DATE)<=@DTo) " +
            "GROUP BY LTRIM(RTRIM(NotificationType)) ORDER BY Total DESC;");
        cmd.Parameters.AddWithValue("@I", inst);
        cmd.Parameters.AddWithValue("@S", sess);
        cmd.Parameters.AddWithValue("@DFr", Dt(dateFrom));
        cmd.Parameters.AddWithValue("@DTo", Dt(dateTo));
        return Safe(cmd, "NotifTypes");
    }

    // ═══════════════════════════════════════════════════════════
    // HELP REQUESTS — paginated
    // ═══════════════════════════════════════════════════════════
    public DataTable GetHelpRequests(int inst, int sess,
        string dateFrom, string dateTo, int pageIndex, int pageSize)
    {
        var cmd = new SqlCommand(@"
            SELECT * FROM (
                SELECT ROW_NUMBER() OVER (ORDER BY hr.AskedOn DESC) AS RowNum,
                    hr.HelpId,
                    ISNULL(up.FullName, u.Username)  AS StudentName,
                    ISNULL(up.ProfileImage, '')       AS ProfileImage,
                    ISNULL(hr.Question, '')           AS Question,
                    hr.AskedOn,
                    CASE WHEN rep.RepliedOn IS NOT NULL THEN 'Resolved' ELSE 'Open' END AS Status,
                    ISNULL(DATEDIFF(HOUR, hr.AskedOn, ISNULL(rep.RepliedOn,GETDATE())),0) AS HoursOpen,
                    ISNULL(repUp.FullName, '')        AS ResolvedBy
                FROM HelpRequests hr
                JOIN Users u ON u.UserId=hr.UserId
                LEFT JOIN UserProfile up ON up.UserId=hr.UserId
                OUTER APPLY (
                    SELECT TOP 1 AdminId, RepliedOn FROM HelpReplies
                    WHERE HelpId=hr.HelpId ORDER BY RepliedOn ASC
                ) rep
                LEFT JOIN UserProfile repUp ON repUp.UserId=rep.AdminId
                WHERE hr.InstituteId=@I AND hr.SessionId=@S
                  AND (@DFr IS NULL OR CAST(hr.AskedOn AS DATE)>=@DFr)
                  AND (@DTo IS NULL OR CAST(hr.AskedOn AS DATE)<=@DTo)
            ) T WHERE RowNum BETWEEN @Skip+1 AND @Skip+@Size;");
        cmd.Parameters.AddWithValue("@I", inst);
        cmd.Parameters.AddWithValue("@S", sess);
        cmd.Parameters.AddWithValue("@DFr", Dt(dateFrom));
        cmd.Parameters.AddWithValue("@DTo", Dt(dateTo));
        cmd.Parameters.AddWithValue("@Skip", pageIndex * pageSize);
        cmd.Parameters.AddWithValue("@Size", pageSize);
        return Safe(cmd, "GetHelpRequests");
    }

    public int GetHelpRequestCount(int inst, int sess, string dateFrom, string dateTo)
    {
        var cmd = new SqlCommand(
            "SELECT COUNT(*) FROM HelpRequests " +
            "WHERE InstituteId=@I AND SessionId=@S " +
            "AND (@DFr IS NULL OR CAST(AskedOn AS DATE)>=@DFr) " +
            "AND (@DTo IS NULL OR CAST(AskedOn AS DATE)<=@DTo);");
        cmd.Parameters.AddWithValue("@I", inst);
        cmd.Parameters.AddWithValue("@S", sess);
        cmd.Parameters.AddWithValue("@DFr", Dt(dateFrom));
        cmd.Parameters.AddWithValue("@DTo", Dt(dateTo));
        return SafeInt(cmd, "HelpCount");
    }

    // ═══════════════════════════════════════════════════════════
    // HELP REQUEST TREND
    // ═══════════════════════════════════════════════════════════
    public DataTable GetHelpRequestTrend(int inst, int sess, string dateFrom, string dateTo)
    {
        var cmd = new SqlCommand(@"
            SELECT CONVERT(VARCHAR(10),hr.AskedOn,23) AS DateStr,
                COUNT(*) AS Total,
                SUM(CASE WHEN EXISTS(SELECT 1 FROM HelpReplies r WHERE r.HelpId=hr.HelpId) THEN 1 ELSE 0 END) AS Resolved,
                SUM(CASE WHEN NOT EXISTS(SELECT 1 FROM HelpReplies r WHERE r.HelpId=hr.HelpId) THEN 1 ELSE 0 END) AS Open
            FROM HelpRequests hr
            WHERE hr.InstituteId=@I AND hr.SessionId=@S
              AND (@DFr IS NULL OR CAST(hr.AskedOn AS DATE)>=@DFr)
              AND (@DTo IS NULL OR CAST(hr.AskedOn AS DATE)<=@DTo)
            GROUP BY CONVERT(VARCHAR(10),hr.AskedOn,23) ORDER BY DateStr;");
        cmd.Parameters.AddWithValue("@I", inst);
        cmd.Parameters.AddWithValue("@S", sess);
        cmd.Parameters.AddWithValue("@DFr", Dt(dateFrom));
        cmd.Parameters.AddWithValue("@DTo", Dt(dateTo));
        return Safe(cmd, "HelpTrend");
    }

    // ═══════════════════════════════════════════════════════════
    // ANNOUNCEMENTS — from Notifications table
    // ═══════════════════════════════════════════════════════════
    public DataTable GetAnnouncements(int inst, int sess,
        string dateFrom, string dateTo, int pageIndex, int pageSize)
    {
        var cmd = new SqlCommand(@"
            SELECT * FROM (
                SELECT ROW_NUMBER() OVER (ORDER BY n.CreatedOn DESC) AS RowNum,
                    n.NotificationId  AS AnnouncementId,
                    ISNULL(LTRIM(RTRIM(n.NotificationType)),'General') AS Title,
                    ISNULL(n.Message,'')            AS Content,
                    n.CreatedOn,
                    ISNULL(up.FullName, u.Username) AS CreatedBy,
                    ISNULL(up.ProfileImage,'')      AS ProfileImage,
                    'All'                           AS StreamName,
                    0                               AS NotifCount
                FROM Notifications n
                JOIN Users u ON u.UserId=n.UserId
                LEFT JOIN UserProfile up ON up.UserId=n.UserId
                WHERE n.InstituteId=@I AND n.SessionId=@S
                  AND (@DFr IS NULL OR CAST(n.CreatedOn AS DATE)>=@DFr)
                  AND (@DTo IS NULL OR CAST(n.CreatedOn AS DATE)<=@DTo)
            ) T WHERE RowNum BETWEEN @Skip+1 AND @Skip+@Size;");
        cmd.Parameters.AddWithValue("@I", inst);
        cmd.Parameters.AddWithValue("@S", sess);
        cmd.Parameters.AddWithValue("@DFr", Dt(dateFrom));
        cmd.Parameters.AddWithValue("@DTo", Dt(dateTo));
        cmd.Parameters.AddWithValue("@Skip", pageIndex * pageSize);
        cmd.Parameters.AddWithValue("@Size", pageSize);
        return Safe(cmd, "GetAnnouncements");
    }

    public int GetAnnouncementCount(int inst, int sess, string dateFrom, string dateTo)
    {
        var cmd = new SqlCommand(
            "SELECT COUNT(*) FROM Notifications " +
            "WHERE InstituteId=@I AND SessionId=@S " +
            "AND (@DFr IS NULL OR CAST(CreatedOn AS DATE)>=@DFr) " +
            "AND (@DTo IS NULL OR CAST(CreatedOn AS DATE)<=@DTo);");
        cmd.Parameters.AddWithValue("@I", inst);
        cmd.Parameters.AddWithValue("@S", sess);
        cmd.Parameters.AddWithValue("@DFr", Dt(dateFrom));
        cmd.Parameters.AddWithValue("@DTo", Dt(dateTo));
        return SafeInt(cmd, "AnnCount");
    }

    // ═══════════════════════════════════════════════════════════
    // RECENT MESSAGES — HelpRequests + HelpReplies
    // ═══════════════════════════════════════════════════════════
    public DataTable GetRecentMessages(int inst, int sess, string dateFrom, string dateTo)
    {
        var cmd = new SqlCommand(@"
            SELECT TOP 20 SenderName, ProfileImage, SenderRole, Preview, SentOn, ThreadId, Subject
            FROM (
                SELECT ISNULL(up.FullName,u.Username)    AS SenderName,
                    ISNULL(up.ProfileImage,'')            AS ProfileImage,
                    ISNULL(r.RoleName,'Student')          AS SenderRole,
                    ISNULL(LEFT(hr.Question,120),'')      AS Preview,
                    hr.AskedOn                            AS SentOn,
                    hr.HelpId                             AS ThreadId,
                    'Help Question'                       AS Subject
                FROM HelpRequests hr
                JOIN Users u ON u.UserId=hr.UserId
                LEFT JOIN UserProfile up ON up.UserId=hr.UserId
                LEFT JOIN Roles r ON r.RoleId=u.RoleId
                WHERE hr.InstituteId=@I AND hr.SessionId=@S
                  AND (@DFr IS NULL OR CAST(hr.AskedOn AS DATE)>=@DFr)
                  AND (@DTo IS NULL OR CAST(hr.AskedOn AS DATE)<=@DTo)

                UNION ALL

                SELECT ISNULL(up.FullName,u.Username)    AS SenderName,
                    ISNULL(up.ProfileImage,'')            AS ProfileImage,
                    ISNULL(r.RoleName,'Admin')            AS SenderRole,
                    ISNULL(LEFT(rep.Reply,120),'')        AS Preview,
                    rep.RepliedOn                         AS SentOn,
                    rep.HelpId                            AS ThreadId,
                    'Help Reply'                          AS Subject
                FROM HelpReplies rep
                JOIN Users u ON u.UserId=rep.AdminId
                LEFT JOIN UserProfile up ON up.UserId=rep.AdminId
                LEFT JOIN Roles r ON r.RoleId=u.RoleId
                WHERE rep.InstituteId=@I AND rep.SessionId=@S
                  AND (@DFr IS NULL OR CAST(rep.RepliedOn AS DATE)>=@DFr)
                  AND (@DTo IS NULL OR CAST(rep.RepliedOn AS DATE)<=@DTo)
            ) X ORDER BY SentOn DESC;");
        cmd.Parameters.AddWithValue("@I", inst);
        cmd.Parameters.AddWithValue("@S", sess);
        cmd.Parameters.AddWithValue("@DFr", Dt(dateFrom));
        cmd.Parameters.AddWithValue("@DTo", Dt(dateTo));
        return Safe(cmd, "RecentMessages");
    }

    public DataTable GetMessageTrend(int inst, int sess, string dateFrom, string dateTo)
    {
        var cmd = new SqlCommand(@"
            SELECT DateStr, SUM(Total) AS Total, SUM(UniqueUsers) AS UniqueUsers
            FROM (
                SELECT CONVERT(VARCHAR(10),AskedOn,23) AS DateStr,
                    COUNT(*) AS Total, COUNT(DISTINCT UserId) AS UniqueUsers
                FROM HelpRequests
                WHERE InstituteId=@I AND SessionId=@S
                  AND (@DFr IS NULL OR CAST(AskedOn AS DATE)>=@DFr)
                  AND (@DTo IS NULL OR CAST(AskedOn AS DATE)<=@DTo)
                GROUP BY CONVERT(VARCHAR(10),AskedOn,23)
                UNION ALL
                SELECT CONVERT(VARCHAR(10),RepliedOn,23) AS DateStr,
                    COUNT(*) AS Total, COUNT(DISTINCT AdminId) AS UniqueUsers
                FROM HelpReplies
                WHERE InstituteId=@I AND SessionId=@S
                  AND (@DFr IS NULL OR CAST(RepliedOn AS DATE)>=@DFr)
                  AND (@DTo IS NULL OR CAST(RepliedOn AS DATE)<=@DTo)
                GROUP BY CONVERT(VARCHAR(10),RepliedOn,23)
            ) X GROUP BY DateStr ORDER BY DateStr;");
        cmd.Parameters.AddWithValue("@I", inst);
        cmd.Parameters.AddWithValue("@S", sess);
        cmd.Parameters.AddWithValue("@DFr", Dt(dateFrom));
        cmd.Parameters.AddWithValue("@DTo", Dt(dateTo));
        return Safe(cmd, "MsgTrend");
    }

    // ═══════════════════════════════════════════════════════════
    // STREAM-WISE NOTIFICATION REACH
    // ═══════════════════════════════════════════════════════════
    public DataTable GetStreamWiseNotifications(int inst, int sess, string dateFrom, string dateTo)
    {
        var cmd = new SqlCommand(@"
            SELECT ISNULL(st.StreamName,'Unassigned') AS StreamName,
                COUNT(DISTINCT sa.UserId)             AS TotalStudents,
                COUNT(DISTINCT n.UserId)              AS Reached,
                CAST(100.0*COUNT(DISTINCT n.UserId)/NULLIF(COUNT(DISTINCT sa.UserId),0) AS DECIMAL(5,1)) AS ReachRate
            FROM StudentAcademicDetails sa
            LEFT JOIN Streams st ON st.StreamId=sa.StreamId
            LEFT JOIN Notifications n
                ON n.UserId=sa.UserId AND n.InstituteId=@I AND n.SessionId=@S
                AND (@DFr IS NULL OR CAST(n.CreatedOn AS DATE)>=@DFr)
                AND (@DTo IS NULL OR CAST(n.CreatedOn AS DATE)<=@DTo)
            WHERE sa.InstituteId=@I AND sa.SessionId=@S
            GROUP BY st.StreamName ORDER BY ReachRate DESC;");
        cmd.Parameters.AddWithValue("@I", inst);
        cmd.Parameters.AddWithValue("@S", sess);
        cmd.Parameters.AddWithValue("@DFr", Dt(dateFrom));
        cmd.Parameters.AddWithValue("@DTo", Dt(dateTo));
        return Safe(cmd, "StreamReach");
    }

    // ═══════════════════════════════════════════════════════════
    // ROLE-WISE COMMUNICATION
    // ═══════════════════════════════════════════════════════════
    public DataTable GetRoleWiseCommunication(int inst, int sess, string dateFrom, string dateTo)
    {
        var cmd = new SqlCommand(@"
            SELECT RoleName, SUM(Messages) AS Messages, SUM(Users) AS Users
            FROM (
                SELECT ISNULL(r.RoleName,'Unknown') AS RoleName,
                    COUNT(*) AS Messages, COUNT(DISTINCT hr.UserId) AS Users
                FROM HelpRequests hr
                JOIN Users u ON u.UserId=hr.UserId
                LEFT JOIN Roles r ON r.RoleId=u.RoleId
                WHERE hr.InstituteId=@I AND hr.SessionId=@S
                  AND (@DFr IS NULL OR CAST(hr.AskedOn AS DATE)>=@DFr)
                  AND (@DTo IS NULL OR CAST(hr.AskedOn AS DATE)<=@DTo)
                GROUP BY r.RoleName
                UNION ALL
                SELECT ISNULL(r.RoleName,'Admin') AS RoleName,
                    COUNT(*) AS Messages, COUNT(DISTINCT rep.AdminId) AS Users
                FROM HelpReplies rep
                JOIN Users u ON u.UserId=rep.AdminId
                LEFT JOIN Roles r ON r.RoleId=u.RoleId
                WHERE rep.InstituteId=@I AND rep.SessionId=@S
                  AND (@DFr IS NULL OR CAST(rep.RepliedOn AS DATE)>=@DFr)
                  AND (@DTo IS NULL OR CAST(rep.RepliedOn AS DATE)<=@DTo)
                GROUP BY r.RoleName
            ) X GROUP BY RoleName ORDER BY Messages DESC;");
        cmd.Parameters.AddWithValue("@I", inst);
        cmd.Parameters.AddWithValue("@S", sess);
        cmd.Parameters.AddWithValue("@DFr", Dt(dateFrom));
        cmd.Parameters.AddWithValue("@DTo", Dt(dateTo));
        return Safe(cmd, "RoleComm");
    }

    // ═══════════════════════════════════════════════════════════
    // HOURLY PATTERN
    // ═══════════════════════════════════════════════════════════
    public DataTable GetHourlyPattern(int inst, int sess, string dateFrom, string dateTo)
    {
        var cmd = new SqlCommand(
            "SELECT DATEPART(HOUR,CreatedOn) AS Hr, COUNT(*) AS Messages " +
            "FROM Notifications " +
            "WHERE InstituteId=@I AND SessionId=@S " +
            "AND (@DFr IS NULL OR CAST(CreatedOn AS DATE)>=@DFr) " +
            "AND (@DTo IS NULL OR CAST(CreatedOn AS DATE)<=@DTo) " +
            "GROUP BY DATEPART(HOUR,CreatedOn) ORDER BY Hr;");
        cmd.Parameters.AddWithValue("@I", inst);
        cmd.Parameters.AddWithValue("@S", sess);
        cmd.Parameters.AddWithValue("@DFr", Dt(dateFrom));
        cmd.Parameters.AddWithValue("@DTo", Dt(dateTo));
        return Safe(cmd, "HourlyPattern");
    }

    // ═══════════════════════════════════════════════════════════
    // TOP COMMUNICATORS
    // ═══════════════════════════════════════════════════════════
    public DataTable GetTopCommunicators(int inst, int sess, string dateFrom, string dateTo)
    {
        var cmd = new SqlCommand(@"
            SELECT TOP 10
                ISNULL(up.FullName,u.Username)           AS FullName,
                ISNULL(up.ProfileImage,'')               AS ProfileImage,
                ISNULL(r.RoleName,'User')                AS RoleName,
                COUNT(*)                                  AS MessageCount,
                COUNT(DISTINCT CAST(hr.AskedOn AS DATE)) AS ActiveDays,
                CONVERT(VARCHAR(10),MAX(hr.AskedOn),23)  AS LastActive
            FROM HelpRequests hr
            JOIN Users u ON u.UserId=hr.UserId
            LEFT JOIN UserProfile up ON up.UserId=hr.UserId
            LEFT JOIN Roles r ON r.RoleId=u.RoleId
            WHERE hr.InstituteId=@I AND hr.SessionId=@S
              AND (@DFr IS NULL OR CAST(hr.AskedOn AS DATE)>=@DFr)
              AND (@DTo IS NULL OR CAST(hr.AskedOn AS DATE)<=@DTo)
            GROUP BY hr.UserId, up.FullName, u.Username, up.ProfileImage, r.RoleName
            ORDER BY MessageCount DESC;");
        cmd.Parameters.AddWithValue("@I", inst);
        cmd.Parameters.AddWithValue("@S", sess);
        cmd.Parameters.AddWithValue("@DFr", Dt(dateFrom));
        cmd.Parameters.AddWithValue("@DTo", Dt(dateTo));
        return Safe(cmd, "TopComm");
    }

    // ═══════════════════════════════════════════════════════════
    // WEEKLY COMBINED TREND
    // ═══════════════════════════════════════════════════════════
    public DataTable GetWeeklyCombinedTrend(int inst, int sess)
    {
        var cmd = new SqlCommand(@"
            SELECT 'Wk '+CAST(ROW_NUMBER() OVER(ORDER BY WkStart) AS VARCHAR) AS WLabel,
                WkStart,
                ISNULL(Notifs,0) AS Notifications,
                ISNULL(Helps, 0) AS HelpRequests,
                ISNULL(Msgs,  0) AS Messages
            FROM (
                SELECT DATEADD(DAY, 1-DATEPART(WEEKDAY,dt), dt) AS WkStart,
                    SUM(CASE WHEN Src='N' THEN 1 ELSE 0 END) AS Notifs,
                    SUM(CASE WHEN Src='H' THEN 1 ELSE 0 END) AS Helps,
                    SUM(CASE WHEN Src='M' THEN 1 ELSE 0 END) AS Msgs
                FROM (
                    SELECT CAST(CreatedOn AS DATE) AS dt, 'N' AS Src
                    FROM Notifications
                    WHERE InstituteId=@I AND SessionId=@S
                      AND CreatedOn >= DATEADD(WEEK,-7,GETDATE())
                    UNION ALL
                    SELECT CAST(AskedOn AS DATE), 'H'
                    FROM HelpRequests
                    WHERE InstituteId=@I AND SessionId=@S
                      AND AskedOn >= DATEADD(WEEK,-7,GETDATE())
                    UNION ALL
                    SELECT CAST(RepliedOn AS DATE), 'M'
                    FROM HelpReplies
                    WHERE InstituteId=@I AND SessionId=@S
                      AND RepliedOn >= DATEADD(WEEK,-7,GETDATE())
                ) X GROUP BY DATEADD(DAY, 1-DATEPART(WEEKDAY,dt), dt)
            ) W ORDER BY WkStart;");
        cmd.Parameters.AddWithValue("@I", inst);
        cmd.Parameters.AddWithValue("@S", sess);
        return Safe(cmd, "WeeklyTrend");
    }

    // ═══════════════════════════════════════════════════════════
    // ADMIN STATS — each stat isolated
    // ═══════════════════════════════════════════════════════════
    public DataTable GetAdminStats(int inst, int sess)
    {
        var result = new DataTable();
        result.Columns.Add("AvgResolutionHours", typeof(double));
        result.Columns.Add("NotificationsToday", typeof(int));
        result.Columns.Add("HelpRequestsToday", typeof(int));
        result.Columns.Add("MessagesToday", typeof(int));
        result.Columns.Add("UnrespondedOver24h", typeof(int));
        result.Columns.Add("EngagementRate30d", typeof(double));

        var row = result.NewRow();
        row["AvgResolutionHours"] = 0.0;
        row["NotificationsToday"] = 0;
        row["HelpRequestsToday"] = 0;
        row["MessagesToday"] = 0;
        row["UnrespondedOver24h"] = 0;
        row["EngagementRate30d"] = 0.0;

        // Avg resolution hours
        try
        {
            var c = new SqlCommand(@"
                SELECT ISNULL(CAST(AVG(CAST(DATEDIFF(HOUR,hr.AskedOn,rep.FirstReply) AS FLOAT)) AS DECIMAL(5,1)),0) AS Avg
                FROM HelpRequests hr
                CROSS APPLY (SELECT MIN(RepliedOn) AS FirstReply FROM HelpReplies WHERE HelpId=hr.HelpId) rep
                WHERE hr.InstituteId=@I AND hr.SessionId=@S AND rep.FirstReply IS NOT NULL;");
            c.Parameters.AddWithValue("@I", inst); c.Parameters.AddWithValue("@S", sess);
            var dt = Safe(c, "Stats.AvgRes");
            if (dt.Rows.Count > 0 && dt.Rows[0][0] != DBNull.Value)
                row["AvgResolutionHours"] = Convert.ToDouble(dt.Rows[0][0]);
        }
        catch { }

        // Notifications today
        try
        {
            var c = new SqlCommand(
                "SELECT COUNT(*) FROM Notifications WHERE InstituteId=@I AND SessionId=@S " +
                "AND CAST(CreatedOn AS DATE)=CAST(GETDATE() AS DATE);");
            c.Parameters.AddWithValue("@I", inst); c.Parameters.AddWithValue("@S", sess);
            row["NotificationsToday"] = SafeInt(c, "Stats.NotifToday");
        }
        catch { }

        // Help today
        try
        {
            var c = new SqlCommand(
                "SELECT COUNT(*) FROM HelpRequests WHERE InstituteId=@I AND SessionId=@S " +
                "AND CAST(AskedOn AS DATE)=CAST(GETDATE() AS DATE);");
            c.Parameters.AddWithValue("@I", inst); c.Parameters.AddWithValue("@S", sess);
            row["HelpRequestsToday"] = SafeInt(c, "Stats.HelpToday");
        }
        catch { }

        // Messages today (replies)
        try
        {
            var c = new SqlCommand(
                "SELECT COUNT(*) FROM HelpReplies WHERE InstituteId=@I AND SessionId=@S " +
                "AND CAST(RepliedOn AS DATE)=CAST(GETDATE() AS DATE);");
            c.Parameters.AddWithValue("@I", inst); c.Parameters.AddWithValue("@S", sess);
            row["MessagesToday"] = SafeInt(c, "Stats.MsgToday");
        }
        catch { }

        // Unresponded > 24h
        try
        {
            var c = new SqlCommand(
                "SELECT COUNT(*) FROM HelpRequests hr WHERE hr.InstituteId=@I AND hr.SessionId=@S " +
                "AND DATEDIFF(HOUR,hr.AskedOn,GETDATE())>24 " +
                "AND NOT EXISTS(SELECT 1 FROM HelpReplies r WHERE r.HelpId=hr.HelpId);");
            c.Parameters.AddWithValue("@I", inst); c.Parameters.AddWithValue("@S", sess);
            row["UnrespondedOver24h"] = SafeInt(c, "Stats.Unresponded");
        }
        catch { }

        // 30-day engagement rate
        try
        {
            var c1 = new SqlCommand(
                "SELECT COUNT(DISTINCT UserId) FROM StudentAcademicDetails WHERE InstituteId=@I AND SessionId=@S;");
            c1.Parameters.AddWithValue("@I", inst); c1.Parameters.AddWithValue("@S", sess);
            int total = SafeInt(c1, "Stats.TotalStudents");

            if (total > 0)
            {
                var c2 = new SqlCommand(
                    "SELECT COUNT(DISTINCT UserId) FROM Notifications WHERE InstituteId=@I AND SessionId=@S " +
                    "AND CreatedOn>=DATEADD(DAY,-30,GETDATE());");
                c2.Parameters.AddWithValue("@I", inst); c2.Parameters.AddWithValue("@S", sess);
                int engaged = SafeInt(c2, "Stats.EngagedLast30");
                row["EngagementRate30d"] = Math.Round((double)engaged / total * 100, 1);
            }
        }
        catch { }

        result.Rows.Add(row);
        return result;
    }
}