using System;
using System.Data;
using System.Data.SqlClient;

/// <summary>
/// SystemUsageDashboard BL — DEFINITIVE FIXED VERSION
///
/// Schema confirmed from BasePage.LogActivity INSERT:
///   UserActivityLog(UserId, SocietyId, InstituteId, SessionId, ActivityType, ReferenceId)
///   NO Id, NO LogId, NO Description columns
///
/// All queries use COUNT(*) or COUNT(UserId) — never COUNT(Id/LogId)
/// GetInactiveUsers: no date params
/// HelpRequests: no Status column
/// Date params use SqlDbType.Date to avoid null cast issues
/// </summary>
public class SystemUsageDashboardBL
{
    private readonly DataLayer dl = new DataLayer();

    // ═══════════════════════════════════════════════════════
    // DROPDOWNS
    // ═══════════════════════════════════════════════════════
    public DataTable GetStreams(int inst, int sess)
    {
        var cmd = new SqlCommand(@"
            SELECT StreamId, StreamName FROM Streams
            WHERE InstituteId=@I AND SessionId=@S AND IsActive=1
            ORDER BY StreamName;");
        cmd.Parameters.Add("@I", SqlDbType.Int).Value = inst;
        cmd.Parameters.Add("@S", SqlDbType.Int).Value = sess;
        return dl.GetDataTable(cmd);
    }

    public DataTable GetRoles(int inst)
    {
        var cmd = new SqlCommand(@"
            SELECT DISTINCT r.RoleName
            FROM Roles r
            INNER JOIN Users u ON u.RoleId=r.RoleId
            WHERE u.InstituteId=@I AND ISNULL(r.RoleName,'')<>''
            ORDER BY r.RoleName;");
        cmd.Parameters.Add("@I", SqlDbType.Int).Value = inst;
        return dl.GetDataTable(cmd);
    }

    // ═══════════════════════════════════════════════════════
    // KPI SUMMARY — DECLARE vars pattern, avoids all issues
    // ═══════════════════════════════════════════════════════
    public DataTable GetKPISummary(int inst, int sess,
        string role, string dateFrom, string dateTo)
    {
        var cmd = new SqlCommand(@"
            DECLARE @TL  INT=0;
            DECLARE @AU  INT=0;
            DECLARE @TDL INT=0;
            DECLARE @VV  INT=0;
            DECLARE @QA  INT=0;
            DECLARE @AS  INT=0;
            DECLARE @AI  INT=0;
            DECLARE @HR  INT=0;
            DECLARE @TS  INT=0;
            DECLARE @TT  INT=0;

            SELECT @TL=COUNT(*)
            FROM UserActivityLog ual
            JOIN Users u ON u.UserId=ual.UserId
            LEFT JOIN Roles r ON r.RoleId=u.RoleId
            WHERE ual.InstituteId=@I AND ual.ActivityType='Login'
              AND (@Role='' OR ISNULL(r.RoleName,'')=@Role)
              AND (@DFr IS NULL OR CAST(ual.ActionTime AS DATE)>=@DFr)
              AND (@DTo IS NULL OR CAST(ual.ActionTime AS DATE)<=@DTo);

            SELECT @AU=COUNT(DISTINCT ual.UserId)
            FROM UserActivityLog ual
            JOIN Users u ON u.UserId=ual.UserId
            LEFT JOIN Roles r ON r.RoleId=u.RoleId
            WHERE ual.InstituteId=@I
              AND (@Role='' OR ISNULL(r.RoleName,'')=@Role)
              AND (@DFr IS NULL OR CAST(ual.ActionTime AS DATE)>=@DFr)
              AND (@DTo IS NULL OR CAST(ual.ActionTime AS DATE)<=@DTo);

            SELECT @TDL=COUNT(*) FROM UserActivityLog
            WHERE InstituteId=@I AND ActivityType='Login'
              AND CAST(ActionTime AS DATE)=CAST(GETDATE() AS DATE);

            SELECT @VV=COUNT(*)
            FROM VideoViews vv JOIN Videos v ON v.VideoId=vv.VideoId
            WHERE v.InstituteId=@I AND v.SessionId=@S
              AND (@DFr IS NULL OR CAST(vv.ViewedOn AS DATE)>=@DFr)
              AND (@DTo IS NULL OR CAST(vv.ViewedOn AS DATE)<=@DTo);

            SELECT @QA=COUNT(*) FROM QuizResults
            WHERE InstituteId=@I AND SessionId=@S
              AND (@DFr IS NULL OR CAST(AttemptedOn AS DATE)>=@DFr)
              AND (@DTo IS NULL OR CAST(AttemptedOn AS DATE)<=@DTo);

            SELECT @AS=COUNT(*) FROM AssignmentSubmissions
            WHERE InstituteId=@I AND SessionId=@S
              AND (@DFr IS NULL OR CAST(SubmittedOn AS DATE)>=@DFr)
              AND (@DTo IS NULL OR CAST(SubmittedOn AS DATE)<=@DTo);

            SELECT @AI=COUNT(*)
            FROM VideoAIHistory v2 JOIN Users u2 ON u2.UserId=v2.UserId
            WHERE u2.InstituteId=@I
              AND (@DFr IS NULL OR CAST(v2.CreatedOn AS DATE)>=@DFr)
              AND (@DTo IS NULL OR CAST(v2.CreatedOn AS DATE)<=@DTo);

            SELECT @AI=@AI+COUNT(*)
            FROM MaterialAIHistory m2 JOIN Users u3 ON u3.UserId=m2.UserId
            WHERE u3.InstituteId=@I
              AND (@DFr IS NULL OR CAST(m2.CreatedOn AS DATE)>=@DFr)
              AND (@DTo IS NULL OR CAST(m2.CreatedOn AS DATE)<=@DTo);

            SELECT @HR=ISNULL(COUNT(*),0) FROM HelpRequests
            WHERE InstituteId=@I AND SessionId=@S;

            SELECT @TS=COUNT(DISTINCT UserId) FROM StudentAcademicDetails
            WHERE InstituteId=@I AND SessionId=@S;

            SELECT @TT=COUNT(DISTINCT UserId) FROM TeacherDetails
            WHERE InstituteId=@I AND SessionId=@S;

            SELECT @TL AS TotalLogins,@AU AS ActiveUsers,@TDL AS TodayLogins,
                   @VV AS TotalVideoViews,@QA AS QuizAttempts,@AS AS AssignSubmissions,
                   @AI AS AIUses,@HR AS HelpRequests,@TS AS TotalStudents,@TT AS TotalTeachers;");

        cmd.Parameters.Add("@I", SqlDbType.Int).Value = inst;
        cmd.Parameters.Add("@S", SqlDbType.Int).Value = sess;
        cmd.Parameters.Add("@Role", SqlDbType.NVarChar, 100).Value = role ?? "";
        cmd.Parameters.Add("@DFr", SqlDbType.Date).Value = Dt(dateFrom);
        cmd.Parameters.Add("@DTo", SqlDbType.Date).Value = Dt(dateTo);
        return dl.GetDataTable(cmd);
    }

    // ═══════════════════════════════════════════════════════
    // DAILY LOGIN TREND
    // ═══════════════════════════════════════════════════════
    public DataTable GetDailyLoginTrend(int inst, int sess,
        string role, string dateFrom, string dateTo)
    {
        var cmd = new SqlCommand(@"
            SELECT
              CONVERT(VARCHAR(10),ual.ActionTime,23) AS DateStr,
              COUNT(*) AS Logins,
              COUNT(DISTINCT ual.UserId) AS UniqueUsers,
              SUM(CASE WHEN ISNULL(r.RoleName,'')='Student' THEN 1 ELSE 0 END) AS StudentLogins,
              SUM(CASE WHEN ISNULL(r.RoleName,'')='Teacher' THEN 1 ELSE 0 END) AS TeacherLogins,
              SUM(CASE WHEN ISNULL(r.RoleName,'')='Admin'   THEN 1 ELSE 0 END) AS AdminLogins
            FROM UserActivityLog ual
            JOIN Users u ON u.UserId=ual.UserId
            LEFT JOIN Roles r ON r.RoleId=u.RoleId
            WHERE ual.InstituteId=@I AND ual.ActivityType='Login'
              AND (@Role='' OR ISNULL(r.RoleName,'')=@Role)
              AND (@DFr IS NULL OR CAST(ual.ActionTime AS DATE)>=@DFr)
              AND (@DTo IS NULL OR CAST(ual.ActionTime AS DATE)<=@DTo)
            GROUP BY CONVERT(VARCHAR(10),ual.ActionTime,23)
            ORDER BY DateStr;");
        AddP(cmd, inst, sess, role, dateFrom, dateTo);
        return dl.GetDataTable(cmd);
    }

    // ═══════════════════════════════════════════════════════
    // HOURLY PATTERN
    // ═══════════════════════════════════════════════════════
    public DataTable GetHourlyPattern(int inst, int sess,
        string dateFrom, string dateTo)
    {
        var cmd = new SqlCommand(@"
            SELECT DATEPART(HOUR,ActionTime) AS Hr,
                   COUNT(*) AS Total,
                   COUNT(DISTINCT UserId) AS UniqueUsers
            FROM UserActivityLog
            WHERE InstituteId=@I
              AND (@DFr IS NULL OR CAST(ActionTime AS DATE)>=@DFr)
              AND (@DTo IS NULL OR CAST(ActionTime AS DATE)<=@DTo)
            GROUP BY DATEPART(HOUR,ActionTime)
            ORDER BY Hr;");
        cmd.Parameters.Add("@I", SqlDbType.Int).Value = inst;
        cmd.Parameters.Add("@DFr", SqlDbType.Date).Value = Dt(dateFrom);
        cmd.Parameters.Add("@DTo", SqlDbType.Date).Value = Dt(dateTo);
        return dl.GetDataTable(cmd);
    }

    // ═══════════════════════════════════════════════════════
    // ROLE-WISE ACTIVITY
    // ═══════════════════════════════════════════════════════
    public DataTable GetRoleWiseActivity(int inst, int sess,
        string dateFrom, string dateTo)
    {
        var cmd = new SqlCommand(@"
            SELECT ISNULL(r.RoleName,'Unknown') AS RoleName,
                   COUNT(*) AS TotalActions,
                   COUNT(DISTINCT ual.UserId) AS UniqueUsers
            FROM UserActivityLog ual
            JOIN Users u ON u.UserId=ual.UserId
            LEFT JOIN Roles r ON r.RoleId=u.RoleId
            WHERE ual.InstituteId=@I
              AND (@DFr IS NULL OR CAST(ual.ActionTime AS DATE)>=@DFr)
              AND (@DTo IS NULL OR CAST(ual.ActionTime AS DATE)<=@DTo)
            GROUP BY r.RoleName ORDER BY TotalActions DESC;");
        cmd.Parameters.Add("@I", SqlDbType.Int).Value = inst;
        cmd.Parameters.Add("@DFr", SqlDbType.Date).Value = Dt(dateFrom);
        cmd.Parameters.Add("@DTo", SqlDbType.Date).Value = Dt(dateTo);
        return dl.GetDataTable(cmd);
    }

    // ═══════════════════════════════════════════════════════
    // FEATURE USAGE
    // ═══════════════════════════════════════════════════════
    public DataTable GetFeatureUsage(int inst, int sess,
        string dateFrom, string dateTo)
    {
        var cmd = new SqlCommand(@"
            SELECT Feature, SUM(Cnt) AS Total, SUM(Usr) AS UniqueUsers FROM (
              SELECT 'Video Views' AS Feature,COUNT(*) AS Cnt,COUNT(DISTINCT vv.UserId) AS Usr
              FROM VideoViews vv JOIN Videos v ON v.VideoId=vv.VideoId
              WHERE v.InstituteId=@I AND v.SessionId=@S
                AND (@DFr IS NULL OR CAST(vv.ViewedOn AS DATE)>=@DFr)
                AND (@DTo IS NULL OR CAST(vv.ViewedOn AS DATE)<=@DTo)
              UNION ALL
              SELECT 'Quiz Attempts',COUNT(*),COUNT(DISTINCT StudentId)
              FROM QuizResults WHERE InstituteId=@I AND SessionId=@S
                AND (@DFr IS NULL OR CAST(AttemptedOn AS DATE)>=@DFr)
                AND (@DTo IS NULL OR CAST(AttemptedOn AS DATE)<=@DTo)
              UNION ALL
              SELECT 'Assignments',COUNT(*),COUNT(DISTINCT StudentId)
              FROM AssignmentSubmissions WHERE InstituteId=@I AND SessionId=@S
                AND (@DFr IS NULL OR CAST(SubmittedOn AS DATE)>=@DFr)
                AND (@DTo IS NULL OR CAST(SubmittedOn AS DATE)<=@DTo)
              UNION ALL
              SELECT 'AI Features',COUNT(*),COUNT(DISTINCT v2.UserId)
              FROM VideoAIHistory v2 JOIN Users u2 ON u2.UserId=v2.UserId
              WHERE u2.InstituteId=@I
                AND (@DFr IS NULL OR CAST(v2.CreatedOn AS DATE)>=@DFr)
                AND (@DTo IS NULL OR CAST(v2.CreatedOn AS DATE)<=@DTo)
              UNION ALL
              SELECT 'Notifications',COUNT(*),COUNT(DISTINCT UserId)
              FROM Notifications WHERE InstituteId=@I AND SessionId=@S
                AND (@DFr IS NULL OR CAST(CreatedOn AS DATE)>=@DFr)
                AND (@DTo IS NULL OR CAST(CreatedOn AS DATE)<=@DTo)
              UNION ALL
              SELECT 'Help Requests',COUNT(*),COUNT(DISTINCT UserId)
              FROM HelpRequests WHERE InstituteId=@I AND SessionId=@S
            ) X GROUP BY Feature ORDER BY Total DESC;");
        cmd.Parameters.Add("@I", SqlDbType.Int).Value = inst;
        cmd.Parameters.Add("@S", SqlDbType.Int).Value = sess;
        cmd.Parameters.Add("@DFr", SqlDbType.Date).Value = Dt(dateFrom);
        cmd.Parameters.Add("@DTo", SqlDbType.Date).Value = Dt(dateTo);
        return dl.GetDataTable(cmd);
    }

    // ═══════════════════════════════════════════════════════
    // TOP ACTIVE USERS
    // ═══════════════════════════════════════════════════════
    public DataTable GetTopActiveUsers(int inst, int sess,
        string role, string dateFrom, string dateTo)
    {
        var cmd = new SqlCommand(@"
            SELECT TOP 15
              ISNULL(up.FullName,u.UserName) AS FullName,
              ISNULL(up.ProfileImage,'')      AS ProfileImage,
              ISNULL(r.RoleName,'User')       AS RoleName,
              COUNT(*) AS TotalActions,
              COUNT(DISTINCT CAST(ual.ActionTime AS DATE)) AS ActiveDays,
              CONVERT(VARCHAR(10),MAX(ual.ActionTime),23) AS LastSeen,
              ISNULL((SELECT COUNT(*) FROM VideoViews vv
                WHERE vv.UserId=ual.UserId
                  AND (@DFr IS NULL OR CAST(vv.ViewedOn AS DATE)>=@DFr)
                  AND (@DTo IS NULL OR CAST(vv.ViewedOn AS DATE)<=@DTo)),0) AS VideoViews,
              ISNULL((SELECT COUNT(*) FROM QuizResults qr
                WHERE qr.StudentId=ual.UserId AND qr.InstituteId=@I AND qr.SessionId=@S
                  AND (@DFr IS NULL OR CAST(qr.AttemptedOn AS DATE)>=@DFr)
                  AND (@DTo IS NULL OR CAST(qr.AttemptedOn AS DATE)<=@DTo)),0) AS QuizAttempts
            FROM UserActivityLog ual
            JOIN Users u ON u.UserId=ual.UserId
            LEFT JOIN UserProfile up ON up.UserId=ual.UserId
            LEFT JOIN Roles r ON r.RoleId=u.RoleId
            WHERE ual.InstituteId=@I
              AND (@Role='' OR ISNULL(r.RoleName,'')=@Role)
              AND (@DFr IS NULL OR CAST(ual.ActionTime AS DATE)>=@DFr)
              AND (@DTo IS NULL OR CAST(ual.ActionTime AS DATE)<=@DTo)
            GROUP BY ual.UserId,up.FullName,u.UserName,up.ProfileImage,r.RoleName
            ORDER BY TotalActions DESC;");
        AddP(cmd, inst, sess, role, dateFrom, dateTo);
        return dl.GetDataTable(cmd);
    }

    // ═══════════════════════════════════════════════════════
    // INACTIVE USERS — no date params
    // ═══════════════════════════════════════════════════════
    public DataTable GetInactiveUsers(int inst, int sess)
    {
        var cmd = new SqlCommand(@"
            SELECT TOP 15
              ISNULL(up.FullName,u.UserName) AS FullName,
              ISNULL(up.ProfileImage,'')      AS ProfileImage,
              ISNULL(r.RoleName,'User')       AS RoleName,
              ISNULL(CONVERT(VARCHAR(10),MAX(ual.ActionTime),23),'Never') AS LastSeen,
              CASE WHEN MAX(ual.ActionTime) IS NULL THEN 999
                   ELSE DATEDIFF(DAY,MAX(ual.ActionTime),GETDATE()) END AS DaysSinceLogin
            FROM Users u
            LEFT JOIN UserProfile up ON up.UserId=u.UserId
            LEFT JOIN Roles r ON r.RoleId=u.RoleId
            LEFT JOIN UserActivityLog ual ON ual.UserId=u.UserId AND ual.InstituteId=@I
            WHERE u.InstituteId=@I AND u.IsActive=1
            GROUP BY u.UserId,up.FullName,u.UserName,up.ProfileImage,r.RoleName
            HAVING MAX(ual.ActionTime) IS NULL
                OR DATEDIFF(DAY,MAX(ual.ActionTime),GETDATE())>=14
            ORDER BY DaysSinceLogin DESC;");
        cmd.Parameters.Add("@I", SqlDbType.Int).Value = inst;
        return dl.GetDataTable(cmd);
    }

    // ═══════════════════════════════════════════════════════
    // DAY-OF-WEEK PATTERN
    // ═══════════════════════════════════════════════════════
    public DataTable GetDayOfWeekPattern(int inst, int sess,
        string dateFrom, string dateTo)
    {
        var cmd = new SqlCommand(@"
            SELECT DATENAME(WEEKDAY,ActionTime) AS DayName,
                   DATEPART(WEEKDAY,ActionTime) AS DayNum,
                   COUNT(*) AS Total,
                   COUNT(DISTINCT UserId) AS UniqueUsers
            FROM UserActivityLog
            WHERE InstituteId=@I
              AND (@DFr IS NULL OR CAST(ActionTime AS DATE)>=@DFr)
              AND (@DTo IS NULL OR CAST(ActionTime AS DATE)<=@DTo)
            GROUP BY DATENAME(WEEKDAY,ActionTime),DATEPART(WEEKDAY,ActionTime)
            ORDER BY DayNum;");
        cmd.Parameters.Add("@I", SqlDbType.Int).Value = inst;
        cmd.Parameters.Add("@DFr", SqlDbType.Date).Value = Dt(dateFrom);
        cmd.Parameters.Add("@DTo", SqlDbType.Date).Value = Dt(dateTo);
        return dl.GetDataTable(cmd);
    }

    // ═══════════════════════════════════════════════════════
    // STREAM-WISE USAGE
    // ═══════════════════════════════════════════════════════
    public DataTable GetStreamWiseUsage(int inst, int sess,
        string dateFrom, string dateTo)
    {
        var cmd = new SqlCommand(@"
            SELECT ISNULL(st.StreamName,'Unassigned') AS StreamName,
                   COUNT(DISTINCT sa.UserId) AS TotalStudents,
                   COUNT(DISTINCT ual.UserId) AS ActiveStudents,
                   COUNT(ual.UserId) AS TotalActions,
                   CAST(100.0*COUNT(DISTINCT ual.UserId)
                       /NULLIF(COUNT(DISTINCT sa.UserId),0) AS DECIMAL(5,1)) AS EngagementRate
            FROM StudentAcademicDetails sa
            LEFT JOIN Streams st ON st.StreamId=sa.StreamId
            LEFT JOIN UserActivityLog ual
              ON ual.UserId=sa.UserId AND ual.InstituteId=@I
              AND (@DFr IS NULL OR CAST(ual.ActionTime AS DATE)>=@DFr)
              AND (@DTo IS NULL OR CAST(ual.ActionTime AS DATE)<=@DTo)
            WHERE sa.InstituteId=@I AND sa.SessionId=@S
            GROUP BY st.StreamName ORDER BY TotalActions DESC;");
        cmd.Parameters.Add("@I", SqlDbType.Int).Value = inst;
        cmd.Parameters.Add("@S", SqlDbType.Int).Value = sess;
        cmd.Parameters.Add("@DFr", SqlDbType.Date).Value = Dt(dateFrom);
        cmd.Parameters.Add("@DTo", SqlDbType.Date).Value = Dt(dateTo);
        return dl.GetDataTable(cmd);
    }

    // ═══════════════════════════════════════════════════════
    // RECENT ACTIVITY — no Description column
    // ═══════════════════════════════════════════════════════
    public DataTable GetRecentActivity(int inst, int sess,
        string role, string dateFrom, string dateTo)
    {
        var cmd = new SqlCommand(@"
            SELECT TOP 20
              ISNULL(up.FullName,u.UserName) AS FullName,
              ISNULL(up.ProfileImage,'')      AS ProfileImage,
              ISNULL(r.RoleName,'User')       AS RoleName,
              ual.ActivityType,
              ual.ActionTime,
              CASE
                WHEN ual.ActivityType='Login'          THEN 'Login'
                WHEN ual.ActivityType='Logout'         THEN 'Logout'
                WHEN ual.ActivityType LIKE '%VIDEO%'   THEN 'View'
                WHEN ual.ActivityType LIKE '%QUIZ%'    THEN 'Quiz'
                WHEN ual.ActivityType LIKE '%ASSIGN%'  THEN 'Submit'
                WHEN ual.ActivityType LIKE '%UPLOAD%'  THEN 'Upload'
                WHEN ual.ActivityType LIKE '%TEACHER%' THEN 'Teacher'
                WHEN ual.ActivityType LIKE '%STUDENT%' THEN 'Student'
                ELSE LEFT(ual.ActivityType,20)
              END AS ActivityLabel,
              '' AS Description
            FROM UserActivityLog ual
            JOIN Users u ON u.UserId=ual.UserId
            LEFT JOIN UserProfile up ON up.UserId=ual.UserId
            LEFT JOIN Roles r ON r.RoleId=u.RoleId
            WHERE ual.InstituteId=@I
              AND (@Role='' OR ISNULL(r.RoleName,'')=@Role)
              AND (@DFr IS NULL OR CAST(ual.ActionTime AS DATE)>=@DFr)
              AND (@DTo IS NULL OR CAST(ual.ActionTime AS DATE)<=@DTo)
            ORDER BY ual.ActionTime DESC;");
        AddP(cmd, inst, sess, role, dateFrom, dateTo);
        return dl.GetDataTable(cmd);
    }

    // ═══════════════════════════════════════════════════════
    // WEEKLY TREND
    // ═══════════════════════════════════════════════════════
    public DataTable GetWeeklyTrend(int inst, int sess,
        string dateFrom, string dateTo)
    {
        var cmd = new SqlCommand(@"
            SELECT
              'Wk '+CAST(ROW_NUMBER() OVER(ORDER BY WkStart) AS VARCHAR) AS WLabel,
              WkStart,
              COUNT(*) AS TotalActions,
              COUNT(DISTINCT UserId) AS UniqueUsers
            FROM (
              SELECT
                DATEADD(DAY,-(DATEPART(WEEKDAY,ActionTime)-1),CAST(ActionTime AS DATE)) AS WkStart,
                UserId
              FROM UserActivityLog
              WHERE InstituteId=@I AND ActionTime>=DATEADD(WEEK,-7,GETDATE())
            ) W
            GROUP BY WkStart ORDER BY WkStart;");
        cmd.Parameters.Add("@I", SqlDbType.Int).Value = inst;
        cmd.Parameters.Add("@DFr", SqlDbType.Date).Value = Dt(dateFrom);
        cmd.Parameters.Add("@DTo", SqlDbType.Date).Value = Dt(dateTo);
        return dl.GetDataTable(cmd);
    }

    // ═══════════════════════════════════════════════════════
    // ADMIN STATS
    // ═══════════════════════════════════════════════════════
    public DataTable GetAdminStats(int inst, int sess)
    {
        var cmd = new SqlCommand(@"
            DECLARE @NLI INT=0;
            DECLARE @AVG DECIMAL(5,1)=0;
            DECLARE @PH  INT=0;
            DECLARE @A7  INT=0;
            DECLARE @OHR INT=0;
            DECLARE @NM  INT=0;

            SELECT @NLI=COUNT(*) FROM StudentAcademicDetails sa
            WHERE sa.InstituteId=@I AND sa.SessionId=@S
              AND NOT EXISTS(SELECT 1 FROM UserActivityLog
                WHERE UserId=sa.UserId AND InstituteId=@I);

            SELECT @AVG=ISNULL(CAST(AVG(CAST(Cnt AS FLOAT)) AS DECIMAL(5,1)),0)
            FROM (SELECT CAST(ActionTime AS DATE) AS Dt,COUNT(*) AS Cnt
                  FROM UserActivityLog
                  WHERE InstituteId=@I AND ActivityType='Login'
                    AND ActionTime>=DATEADD(DAY,-30,GETDATE())
                  GROUP BY CAST(ActionTime AS DATE)) X;

            SELECT TOP 1 @PH=DATEPART(HOUR,ActionTime)
            FROM UserActivityLog WHERE InstituteId=@I
            GROUP BY DATEPART(HOUR,ActionTime) ORDER BY COUNT(*) DESC;

            SELECT @A7=COUNT(DISTINCT UserId) FROM UserActivityLog
            WHERE InstituteId=@I AND ActionTime>=DATEADD(DAY,-7,GETDATE());

            SELECT @OHR=ISNULL(COUNT(*),0) FROM HelpRequests
            WHERE InstituteId=@I AND SessionId=@S;

            SELECT @NM=ISNULL(COUNT(*),0) FROM Notifications
            WHERE InstituteId=@I AND SessionId=@S
              AND MONTH(CreatedOn)=MONTH(GETDATE())
              AND YEAR(CreatedOn)=YEAR(GETDATE());

            SELECT @NLI AS NeverLoggedIn,@AVG AS AvgLoginsPerDay,
                   @PH AS PeakHour,@A7 AS ActiveLast7,
                   @OHR AS OpenHelpRequests,@NM AS NotifThisMonth;");
        cmd.Parameters.Add("@I", SqlDbType.Int).Value = inst;
        cmd.Parameters.Add("@S", SqlDbType.Int).Value = sess;
        return dl.GetDataTable(cmd);
    }

    // ═══════════════════════════════════════════════════════
    // HELPERS
    // ═══════════════════════════════════════════════════════
    private void AddP(SqlCommand cmd, int inst, int sess,
        string role, string dFr, string dTo)
    {
        cmd.Parameters.Add("@I", SqlDbType.Int).Value = inst;
        cmd.Parameters.Add("@S", SqlDbType.Int).Value = sess;
        cmd.Parameters.Add("@Role", SqlDbType.NVarChar, 100).Value = role ?? "";
        cmd.Parameters.Add("@DFr", SqlDbType.Date).Value = Dt(dFr);
        cmd.Parameters.Add("@DTo", SqlDbType.Date).Value = Dt(dTo);
    }

    // CRITICAL: Returns typed DBNull for null dates — prevents SQL cast errors
    private object Dt(string s)
    {
        if (string.IsNullOrWhiteSpace(s)) return DBNull.Value;
        DateTime d;
        return DateTime.TryParse(s, out d) ? (object)d.Date : DBNull.Value;
    }
}