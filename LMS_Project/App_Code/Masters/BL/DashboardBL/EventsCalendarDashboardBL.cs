//using System;
//using System.Data;
//using System.Data.SqlClient;

///// <summary>
///// Events Calendar Dashboard BL — Safe Version
///// Every method has try/catch. Uses only the guaranteed CalendarEvents columns.
///// No complex subqueries that reference columns that may not exist.
///// </summary>
//public class EventsCalendarDashboardBL
//{
//    private readonly DataLayer _dl = new DataLayer();

//    private DataTable Safe(SqlCommand cmd, string tag)
//    {
//        try { return _dl.GetDataTable(cmd); }
//        catch (Exception ex)
//        {
//            System.Diagnostics.Debug.WriteLine("[EventsCal." + tag + "] " + ex.Message);
//            return new DataTable();
//        }
//    }

//    private object DV(string s) => string.IsNullOrEmpty(s) ? (object)DBNull.Value : s;

//    // ── Dropdowns ──────────────────────────────────────────────
//    public DataTable GetStreams(int inst, int sess)
//    {
//        var c = new SqlCommand("SELECT StreamId,StreamName FROM Streams WHERE InstituteId=@I AND SessionId=@S AND IsActive=1 ORDER BY StreamName");
//        c.Parameters.AddWithValue("@I", inst); c.Parameters.AddWithValue("@S", sess);
//        return Safe(c, "GetStreams");
//    }

//    public DataTable GetEventTypes(int inst, int sess)
//    {
//        var c = new SqlCommand("SELECT DISTINCT ISNULL(LTRIM(RTRIM(EventType)),'General') AS EventType FROM CalendarEvents WHERE InstituteId=@I AND SessionId=@S AND EventType IS NOT NULL AND LTRIM(RTRIM(EventType))<>'' ORDER BY EventType");
//        c.Parameters.AddWithValue("@I", inst); c.Parameters.AddWithValue("@S", sess);
//        return Safe(c, "EventTypes");
//    }

//    // ── KPI Summary ────────────────────────────────────────────
//    public DataTable GetKPISummary(int inst, int sess,
//        string eventType, string dateFrom, string dateTo)
//    {
//        var result = new DataTable();
//        result.Columns.Add("TotalEvents", typeof(int));
//        result.Columns.Add("UpcomingNext30", typeof(int));
//        result.Columns.Add("PastEvents", typeof(int));
//        result.Columns.Add("TodayEvents", typeof(int));
//        result.Columns.Add("EventCategories", typeof(int));
//        result.Columns.Add("NotificationsSent", typeof(int));
//        result.Columns.Add("ThisMonthEvents", typeof(int));
//        result.Columns.Add("Next7Days", typeof(int));
//        var row = result.NewRow();
//        foreach (DataColumn col in result.Columns) row[col] = 0;

//        try
//        {
//            var c = new SqlCommand(@"
//SELECT
//  COUNT(*)                                                                   AS TotalEvents,
//  SUM(CASE WHEN CAST(EventDate AS DATE)>=CAST(GETDATE() AS DATE)
//             AND CAST(EventDate AS DATE)<=CAST(DATEADD(DAY,30,GETDATE()) AS DATE) THEN 1 ELSE 0 END) AS UpcomingNext30,
//  SUM(CASE WHEN CAST(EventDate AS DATE) < CAST(GETDATE() AS DATE)          THEN 1 ELSE 0 END)        AS PastEvents,
//  SUM(CASE WHEN CAST(EventDate AS DATE) = CAST(GETDATE() AS DATE)          THEN 1 ELSE 0 END)        AS TodayEvents,
//  COUNT(DISTINCT ISNULL(EventType,'General'))                                AS EventCategories,
//  SUM(CASE WHEN MONTH(EventDate)=MONTH(GETDATE()) AND YEAR(EventDate)=YEAR(GETDATE()) THEN 1 ELSE 0 END) AS ThisMonthEvents,
//  SUM(CASE WHEN CAST(EventDate AS DATE)>=CAST(GETDATE() AS DATE)
//             AND CAST(EventDate AS DATE)<=CAST(DATEADD(DAY,7,GETDATE()) AS DATE) THEN 1 ELSE 0 END)  AS Next7Days
//FROM CalendarEvents
//WHERE InstituteId=@I AND SessionId=@S
//  AND (@Type='' OR ISNULL(EventType,'')=@Type)
//  AND (@DFr IS NULL OR CAST(EventDate AS DATE)>=TRY_CAST(@DFr AS DATE))
//  AND (@DTo IS NULL OR CAST(EventDate AS DATE)<=TRY_CAST(@DTo AS DATE))");
//            c.Parameters.AddWithValue("@I", inst);
//            c.Parameters.AddWithValue("@S", sess);
//            c.Parameters.AddWithValue("@Type", eventType ?? "");
//            c.Parameters.AddWithValue("@DFr", DV(dateFrom));
//            c.Parameters.AddWithValue("@DTo", DV(dateTo));
//            var dt = _dl.GetDataTable(c);
//            if (dt?.Rows.Count > 0)
//            {
//                row["TotalEvents"] = dt.Rows[0]["TotalEvents"];
//                row["UpcomingNext30"] = dt.Rows[0]["UpcomingNext30"];
//                row["PastEvents"] = dt.Rows[0]["PastEvents"];
//                row["TodayEvents"] = dt.Rows[0]["TodayEvents"];
//                row["EventCategories"] = dt.Rows[0]["EventCategories"];
//                row["ThisMonthEvents"] = dt.Rows[0]["ThisMonthEvents"];
//                row["Next7Days"] = dt.Rows[0]["Next7Days"];
//            }
//        }
//        catch (Exception ex) { System.Diagnostics.Debug.WriteLine("[EventsCal.KPI] " + ex.Message); }

//        // Notifications — completely separate, safe query
//        try
//        {
//            var c = new SqlCommand("SELECT COUNT(*) AS N FROM Notifications WHERE InstituteId=@I AND (@DFr IS NULL OR CAST(CreatedOn AS DATE)>=TRY_CAST(@DFr AS DATE)) AND (@DTo IS NULL OR CAST(CreatedOn AS DATE)<=TRY_CAST(@DTo AS DATE))");
//            c.Parameters.AddWithValue("@I", inst);
//            c.Parameters.AddWithValue("@DFr", DV(dateFrom));
//            c.Parameters.AddWithValue("@DTo", DV(dateTo));
//            var dt = _dl.GetDataTable(c);
//            row["NotificationsSent"] = dt?.Rows.Count > 0 ? dt.Rows[0]["N"] : 0;
//        }
//        catch (Exception ex) { System.Diagnostics.Debug.WriteLine("[EventsCal.KPI.Notif] " + ex.Message); }

//        result.Rows.Add(row);
//        return result;
//    }

//    // ── Upcoming Events ────────────────────────────────────────
//    public DataTable GetUpcomingEvents(int inst, int sess,
//        string eventType, string dateFrom, string dateTo)
//    {
//        var c = new SqlCommand(@"
//SELECT TOP 20
//  EventId, LTRIM(RTRIM(Title)) AS Title, ISNULL(Description,'') AS Description,
//  ISNULL(EventType,'General') AS EventType,
//  CONVERT(VARCHAR(10),EventDate,23) AS EventDateStr,
//  EventDate,
//  ISNULL(CONVERT(VARCHAR(5),StartTime,108),'') AS StartTime,
//  ISNULL(CONVERT(VARCHAR(5),EndTime,  108),'') AS EndTime,
//  ISNULL(Location,'') AS Location, ISNULL(OrganisedBy,'') AS OrganisedBy,
//  ISNULL(IsAllDay,0)  AS IsAllDay,
//  DATEDIFF(DAY,GETDATE(),EventDate) AS DaysFromNow, 0 AS NotifCount
//FROM CalendarEvents
//WHERE InstituteId=@I AND SessionId=@S
//  AND CAST(EventDate AS DATE) >= CAST(GETDATE() AS DATE)
//  AND (@Type='' OR ISNULL(EventType,'')=@Type)
//  AND (@DFr IS NULL OR CAST(EventDate AS DATE)>=TRY_CAST(@DFr AS DATE))
//  AND (@DTo IS NULL OR CAST(EventDate AS DATE)<=TRY_CAST(@DTo AS DATE))
//ORDER BY EventDate ASC");
//        c.Parameters.AddWithValue("@I", inst);
//        c.Parameters.AddWithValue("@S", sess);
//        c.Parameters.AddWithValue("@Type", eventType ?? "");
//        c.Parameters.AddWithValue("@DFr", DV(dateFrom));
//        c.Parameters.AddWithValue("@DTo", DV(dateTo));
//        return Safe(c, "Upcoming");
//    }

//    // ── All Events ─────────────────────────────────────────────
//    public DataTable GetAllEvents(int inst, int sess,
//        string eventType, string dateFrom, string dateTo)
//    {
//        var c = new SqlCommand(@"
//SELECT
//  EventId, LTRIM(RTRIM(Title)) AS Title,
//  ISNULL(EventType,'General') AS EventType,
//  CONVERT(VARCHAR(10),EventDate,23) AS EventDateStr,
//  YEAR(EventDate) AS Yr, MONTH(EventDate) AS Mon, DAY(EventDate) AS Dy,
//  ISNULL(CONVERT(VARCHAR(5),StartTime,108),'') AS StartTime,
//  ISNULL(Location,'') AS Location, ISNULL(IsAllDay,0) AS IsAllDay,
//  CASE WHEN CAST(EventDate AS DATE) < CAST(GETDATE() AS DATE) THEN 'past'
//       WHEN CAST(EventDate AS DATE) = CAST(GETDATE() AS DATE) THEN 'today'
//       ELSE 'upcoming' END AS Status,
//  DATEDIFF(DAY,GETDATE(),EventDate) AS DaysFromNow
//FROM CalendarEvents
//WHERE InstituteId=@I AND SessionId=@S
//  AND (@Type='' OR ISNULL(EventType,'')=@Type)
//  AND (@DFr IS NULL OR CAST(EventDate AS DATE)>=TRY_CAST(@DFr AS DATE))
//  AND (@DTo IS NULL OR CAST(EventDate AS DATE)<=TRY_CAST(@DTo AS DATE))
//ORDER BY EventDate ASC");
//        c.Parameters.AddWithValue("@I", inst);
//        c.Parameters.AddWithValue("@S", sess);
//        c.Parameters.AddWithValue("@Type", eventType ?? "");
//        c.Parameters.AddWithValue("@DFr", DV(dateFrom));
//        c.Parameters.AddWithValue("@DTo", DV(dateTo));
//        return Safe(c, "AllEvents");
//    }

//    // ── Event Type Distribution ────────────────────────────────
//    public DataTable GetEventTypeDistribution(int inst, int sess,
//        string dateFrom, string dateTo)
//    {
//        var c = new SqlCommand(@"
//SELECT ISNULL(LTRIM(RTRIM(EventType)),'General') AS EventType,
//  COUNT(*) AS Total,
//  SUM(CASE WHEN CAST(EventDate AS DATE)>=CAST(GETDATE() AS DATE) THEN 1 ELSE 0 END) AS Upcoming,
//  SUM(CASE WHEN CAST(EventDate AS DATE)< CAST(GETDATE() AS DATE) THEN 1 ELSE 0 END) AS Past
//FROM CalendarEvents
//WHERE InstituteId=@I AND SessionId=@S
//  AND (@DFr IS NULL OR CAST(EventDate AS DATE)>=TRY_CAST(@DFr AS DATE))
//  AND (@DTo IS NULL OR CAST(EventDate AS DATE)<=TRY_CAST(@DTo AS DATE))
//GROUP BY EventType ORDER BY Total DESC");
//        c.Parameters.AddWithValue("@I", inst);
//        c.Parameters.AddWithValue("@S", sess);
//        c.Parameters.AddWithValue("@DFr", DV(dateFrom));
//        c.Parameters.AddWithValue("@DTo", DV(dateTo));
//        return Safe(c, "TypeDist");
//    }

//    // ── Monthly Event Count ────────────────────────────────────
//    public DataTable GetMonthlyEventCount(int inst, int sess, string eventType)
//    {
//        var c = new SqlCommand(@"
//WITH Mo AS (
//  SELECT n, MONTH(DATEADD(MONTH,-n,GETDATE())) AS M, YEAR(DATEADD(MONTH,-n,GETDATE())) AS Y,
//    LEFT(DATENAME(MONTH,DATEADD(MONTH,-n,GETDATE())),3)+' '+
//    RIGHT(CAST(YEAR(DATEADD(MONTH,-n,GETDATE())) AS VARCHAR),2) AS ML
//  FROM (VALUES(0),(1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11)) T(n)
//)
//SELECT mo.ML AS MonLabel,mo.M,mo.Y,COUNT(e.EventId) AS EventCount
//FROM Mo mo
//LEFT JOIN CalendarEvents e ON MONTH(e.EventDate)=mo.M AND YEAR(e.EventDate)=mo.Y
//  AND e.InstituteId=@I AND e.SessionId=@S
//  AND (@Type='' OR ISNULL(e.EventType,'')=@Type)
//GROUP BY mo.ML,mo.M,mo.Y,mo.n ORDER BY mo.Y,mo.M");
//        c.Parameters.AddWithValue("@I", inst);
//        c.Parameters.AddWithValue("@S", sess);
//        c.Parameters.AddWithValue("@Type", eventType ?? "");
//        return Safe(c, "Monthly");
//    }

//    // ── Day-of-Week Pattern ────────────────────────────────────
//    public DataTable GetDayOfWeekPattern(int inst, int sess,
//        string dateFrom, string dateTo)
//    {
//        var c = new SqlCommand(@"
//SELECT DATENAME(WEEKDAY,EventDate) AS DayName,
//       DATEPART(WEEKDAY,EventDate) AS DayNum,
//       COUNT(*) AS Total
//FROM CalendarEvents
//WHERE InstituteId=@I AND SessionId=@S
//  AND (@DFr IS NULL OR CAST(EventDate AS DATE)>=TRY_CAST(@DFr AS DATE))
//  AND (@DTo IS NULL OR CAST(EventDate AS DATE)<=TRY_CAST(@DTo AS DATE))
//GROUP BY DATENAME(WEEKDAY,EventDate),DATEPART(WEEKDAY,EventDate)
//ORDER BY DayNum");
//        c.Parameters.AddWithValue("@I", inst);
//        c.Parameters.AddWithValue("@S", sess);
//        c.Parameters.AddWithValue("@DFr", DV(dateFrom));
//        c.Parameters.AddWithValue("@DTo", DV(dateTo));
//        return Safe(c, "DayOfWeek");
//    }

//    // ── Notification Trend ─────────────────────────────────────
//    public DataTable GetNotificationTrend(int inst, int sess,
//        string dateFrom, string dateTo)
//    {
//        var c = new SqlCommand(@"
//SELECT CONVERT(VARCHAR(10),CreatedOn,23) AS DateStr,
//       COUNT(*) AS NotifCount, COUNT(DISTINCT UserId) AS UniqueRecipients
//FROM Notifications
//WHERE InstituteId=@I
//  AND (@DFr IS NULL OR CAST(CreatedOn AS DATE)>=TRY_CAST(@DFr AS DATE))
//  AND (@DTo IS NULL OR CAST(CreatedOn AS DATE)<=TRY_CAST(@DTo AS DATE))
//GROUP BY CONVERT(VARCHAR(10),CreatedOn,23)
//ORDER BY DateStr");
//        c.Parameters.AddWithValue("@I", inst);
//        c.Parameters.AddWithValue("@DFr", DV(dateFrom));
//        c.Parameters.AddWithValue("@DTo", DV(dateTo));
//        return Safe(c, "NotifTrend");
//    }

//    // ── Past Events ────────────────────────────────────────────
//    public DataTable GetPastEvents(int inst, int sess,
//        string eventType, string dateFrom, string dateTo)
//    {
//        var c = new SqlCommand(@"
//SELECT TOP 15
//  EventId, LTRIM(RTRIM(Title)) AS Title,
//  ISNULL(EventType,'General') AS EventType,
//  CONVERT(VARCHAR(10),EventDate,23) AS EventDateStr,
//  ISNULL(CONVERT(VARCHAR(5),StartTime,108),'') AS StartTime,
//  ISNULL(Location,'') AS Location,
//  ABS(DATEDIFF(DAY,GETDATE(),EventDate)) AS DaysAgo
//FROM CalendarEvents
//WHERE InstituteId=@I AND SessionId=@S
//  AND CAST(EventDate AS DATE) < CAST(GETDATE() AS DATE)
//  AND (@Type='' OR ISNULL(EventType,'')=@Type)
//  AND (@DFr IS NULL OR CAST(EventDate AS DATE)>=TRY_CAST(@DFr AS DATE))
//  AND (@DTo IS NULL OR CAST(EventDate AS DATE)<=TRY_CAST(@DTo AS DATE))
//ORDER BY EventDate DESC");
//        c.Parameters.AddWithValue("@I", inst);
//        c.Parameters.AddWithValue("@S", sess);
//        c.Parameters.AddWithValue("@Type", eventType ?? "");
//        c.Parameters.AddWithValue("@DFr", DV(dateFrom));
//        c.Parameters.AddWithValue("@DTo", DV(dateTo));
//        return Safe(c, "PastEvents");
//    }

//    // ── Calendar Heatmap ───────────────────────────────────────
//    public DataTable GetCalendarHeatmap(int inst, int sess,
//        int year, int month, string eventType)
//    {
//        var c = new SqlCommand(@"
//SELECT DAY(EventDate) AS Day,
//       ISNULL(EventType,'General') AS EventType,
//       COUNT(*) AS EventCount,
//       MAX(LTRIM(RTRIM(Title))) AS EventTitles
//FROM CalendarEvents
//WHERE InstituteId=@I AND SessionId=@S
//  AND MONTH(EventDate)=@Mon AND YEAR(EventDate)=@Yr
//  AND (@Type='' OR ISNULL(EventType,'')=@Type)
//GROUP BY DAY(EventDate),EventType
//ORDER BY DAY(EventDate)");
//        c.Parameters.AddWithValue("@I", inst);
//        c.Parameters.AddWithValue("@S", sess);
//        c.Parameters.AddWithValue("@Mon", month);
//        c.Parameters.AddWithValue("@Yr", year);
//        c.Parameters.AddWithValue("@Type", eventType ?? "");
//        return Safe(c, "Heatmap");
//    }

//    // ── Admin Stats ────────────────────────────────────────────
//    public DataTable GetAdminStats(int inst, int sess)
//    {
//        var result = new DataTable();
//        result.Columns.Add("Next7", typeof(int));
//        result.Columns.Add("MonthsWithEvents", typeof(int));
//        result.Columns.Add("NotifThisMonth", typeof(int));
//        result.Columns.Add("UpcomingNoDesc", typeof(int));
//        result.Columns.Add("TotalThisYear", typeof(int));
//        result.Columns.Add("BusiestType", typeof(string));
//        var row = result.NewRow();
//        row["Next7"] = 0; row["MonthsWithEvents"] = 0; row["NotifThisMonth"] = 0;
//        row["UpcomingNoDesc"] = 0; row["TotalThisYear"] = 0; row["BusiestType"] = "—";

//        try
//        {
//            var c = new SqlCommand(@"
//SELECT
//  (SELECT COUNT(*) FROM CalendarEvents WHERE InstituteId=@I AND SessionId=@S
//   AND CAST(EventDate AS DATE) BETWEEN CAST(GETDATE() AS DATE) AND CAST(DATEADD(DAY,7,GETDATE()) AS DATE)) AS Next7,
//  (SELECT COUNT(DISTINCT MONTH(EventDate)) FROM CalendarEvents WHERE InstituteId=@I AND SessionId=@S AND YEAR(EventDate)=YEAR(GETDATE())) AS MonthsWithEvents,
//  (SELECT COUNT(*) FROM CalendarEvents WHERE InstituteId=@I AND SessionId=@S AND YEAR(EventDate)=YEAR(GETDATE())) AS TotalThisYear,
//  (SELECT COUNT(*) FROM CalendarEvents WHERE InstituteId=@I AND SessionId=@S
//   AND (Description IS NULL OR LTRIM(RTRIM(Description))='')
//   AND CAST(EventDate AS DATE)>=CAST(GETDATE() AS DATE)) AS UpcomingNoDesc,
//  ISNULL((SELECT TOP 1 ISNULL(EventType,'General') FROM CalendarEvents
//   WHERE InstituteId=@I AND SessionId=@S GROUP BY EventType ORDER BY COUNT(*) DESC),'—') AS BusiestType");
//            c.Parameters.AddWithValue("@I", inst); c.Parameters.AddWithValue("@S", sess);
//            var dt = _dl.GetDataTable(c);
//            if (dt?.Rows.Count > 0)
//            {
//                row["Next7"] = dt.Rows[0]["Next7"];
//                row["MonthsWithEvents"] = dt.Rows[0]["MonthsWithEvents"];
//                row["TotalThisYear"] = dt.Rows[0]["TotalThisYear"];
//                row["UpcomingNoDesc"] = dt.Rows[0]["UpcomingNoDesc"];
//                row["BusiestType"] = dt.Rows[0]["BusiestType"];
//            }
//        }
//        catch (Exception ex) { System.Diagnostics.Debug.WriteLine("[EventsCal.AdminStats] " + ex.Message); }

//        try
//        {
//            var c = new SqlCommand("SELECT COUNT(*) AS N FROM Notifications WHERE InstituteId=@I AND MONTH(CreatedOn)=MONTH(GETDATE()) AND YEAR(CreatedOn)=YEAR(GETDATE())");
//            c.Parameters.AddWithValue("@I", inst);
//            var dt = _dl.GetDataTable(c);
//            row["NotifThisMonth"] = dt?.Rows.Count > 0 ? dt.Rows[0]["N"] : 0;
//        }
//        catch (Exception ex) { System.Diagnostics.Debug.WriteLine("[EventsCal.AdminStats.Notif] " + ex.Message); }

//        result.Rows.Add(row);
//        return result;
//    }
//}



//=====================================================================================================


using System;
using System.Data;
using System.Data.SqlClient;

/// <summary>
/// Events Calendar Dashboard BL — Fixed for actual CalendarEvents schema:
/// EventId, UserId, SocietyId, InstituteId, SessionId, SubjectId,
/// ReferenceId, Title, EventType, StartTime, EndTime, IsAllDay, CreatedAt
/// NOTE: No EventDate, Location, Description, OrganisedBy columns.
///       StartTime is used as the event date.
/// </summary>
public class EventsCalendarDashboardBL
{
    private readonly DataLayer _dl = new DataLayer();

    private DataTable Safe(SqlCommand cmd, string tag)
    {
        try { return _dl.GetDataTable(cmd); }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("[EventsCal." + tag + "] " + ex.Message);
            return new DataTable();
        }
    }

    private object DV(string s) =>
        string.IsNullOrWhiteSpace(s) ? (object)DBNull.Value : s.Trim();

    // ── Dropdowns ──────────────────────────────────────────────
    public DataTable GetStreams(int inst, int sess)
    {
        var c = new SqlCommand(@"
            SELECT StreamId, StreamName FROM Streams
            WHERE InstituteId=@I AND SessionId=@S AND IsActive=1
            ORDER BY StreamName");
        c.Parameters.AddWithValue("@I", inst);
        c.Parameters.AddWithValue("@S", sess);
        return Safe(c, "Streams");
    }

    public DataTable GetEventTypes(int inst, int sess)
    {
        var c = new SqlCommand(@"
            SELECT DISTINCT
                ISNULL(LTRIM(RTRIM(EventType)),'General') AS EventType
            FROM CalendarEvents
            WHERE InstituteId=@I AND SessionId=@S
              AND EventType IS NOT NULL
              AND LTRIM(RTRIM(EventType)) <> ''
            ORDER BY EventType");
        c.Parameters.AddWithValue("@I", inst);
        c.Parameters.AddWithValue("@S", sess);
        return Safe(c, "EventTypes");
    }

    // ── KPI Summary ────────────────────────────────────────────
    // Uses CAST(StartTime AS DATE) as the event date
    public DataTable GetKPISummary(int inst, int sess,
        string eventType, string dateFrom, string dateTo)
    {
        var result = new DataTable();
        foreach (var col in new[] {
            "TotalEvents","UpcomingNext30","PastEvents","TodayEvents",
            "EventCategories","NotificationsSent","ThisMonthEvents","Next7Days"
        }) result.Columns.Add(col, typeof(int));

        var row = result.NewRow();
        foreach (DataColumn col in result.Columns) row[col] = 0;

        try
        {
            var c = new SqlCommand(@"
                SELECT
                    COUNT(*)   AS TotalEvents,
                    SUM(CASE WHEN CAST(StartTime AS DATE) >= CAST(GETDATE() AS DATE)
                              AND CAST(StartTime AS DATE) <= CAST(DATEADD(DAY,30,GETDATE()) AS DATE)
                         THEN 1 ELSE 0 END) AS UpcomingNext30,
                    SUM(CASE WHEN CAST(StartTime AS DATE) <  CAST(GETDATE() AS DATE)
                         THEN 1 ELSE 0 END) AS PastEvents,
                    SUM(CASE WHEN CAST(StartTime AS DATE) =  CAST(GETDATE() AS DATE)
                         THEN 1 ELSE 0 END) AS TodayEvents,
                    COUNT(DISTINCT ISNULL(EventType,'General')) AS EventCategories,
                    SUM(CASE WHEN MONTH(StartTime)=MONTH(GETDATE())
                              AND YEAR(StartTime)=YEAR(GETDATE())
                         THEN 1 ELSE 0 END) AS ThisMonthEvents,
                    SUM(CASE WHEN CAST(StartTime AS DATE) >= CAST(GETDATE() AS DATE)
                              AND CAST(StartTime AS DATE) <= CAST(DATEADD(DAY,7,GETDATE()) AS DATE)
                         THEN 1 ELSE 0 END) AS Next7Days
                FROM CalendarEvents
                WHERE InstituteId=@I AND SessionId=@S
                  AND (@Type='' OR ISNULL(EventType,'')=@Type)
                  AND (@DFr IS NULL OR CAST(StartTime AS DATE)>=TRY_CAST(@DFr AS DATE))
                  AND (@DTo IS NULL OR CAST(StartTime AS DATE)<=TRY_CAST(@DTo AS DATE))");
            c.Parameters.AddWithValue("@I", inst);
            c.Parameters.AddWithValue("@S", sess);
            c.Parameters.AddWithValue("@Type", eventType ?? "");
            c.Parameters.AddWithValue("@DFr", DV(dateFrom));
            c.Parameters.AddWithValue("@DTo", DV(dateTo));
            var dt = _dl.GetDataTable(c);
            if (dt?.Rows.Count > 0)
            {
                row["TotalEvents"] = dt.Rows[0]["TotalEvents"];
                row["UpcomingNext30"] = dt.Rows[0]["UpcomingNext30"];
                row["PastEvents"] = dt.Rows[0]["PastEvents"];
                row["TodayEvents"] = dt.Rows[0]["TodayEvents"];
                row["EventCategories"] = dt.Rows[0]["EventCategories"];
                row["ThisMonthEvents"] = dt.Rows[0]["ThisMonthEvents"];
                row["Next7Days"] = dt.Rows[0]["Next7Days"];
            }
        }
        catch (Exception ex)
        { System.Diagnostics.Debug.WriteLine("[EventsCal.KPI] " + ex.Message); }

        try
        {
            var c = new SqlCommand(@"
                SELECT COUNT(*) AS N FROM Notifications
                WHERE InstituteId=@I
                  AND (@DFr IS NULL OR CAST(CreatedOn AS DATE)>=TRY_CAST(@DFr AS DATE))
                  AND (@DTo IS NULL OR CAST(CreatedOn AS DATE)<=TRY_CAST(@DTo AS DATE))");
            c.Parameters.AddWithValue("@I", inst);
            c.Parameters.AddWithValue("@DFr", DV(dateFrom));
            c.Parameters.AddWithValue("@DTo", DV(dateTo));
            var dt = _dl.GetDataTable(c);
            row["NotificationsSent"] = dt?.Rows.Count > 0 ? dt.Rows[0]["N"] : 0;
        }
        catch (Exception ex)
        { System.Diagnostics.Debug.WriteLine("[EventsCal.KPI.Notif] " + ex.Message); }

        result.Rows.Add(row);
        return result;
    }

    // ── Upcoming Events ────────────────────────────────────────
    public DataTable GetUpcomingEvents(int inst, int sess,
        string eventType, string dateFrom, string dateTo)
    {
        var c = new SqlCommand(@"
            SELECT TOP 30
                ce.EventId,
                LTRIM(RTRIM(ce.Title))          AS Title,
                ISNULL(ce.EventType,'General')  AS EventType,
                CONVERT(VARCHAR(10),ce.StartTime,23) AS EventDateStr,
                ce.StartTime,
                ce.EndTime,
                ISNULL(CONVERT(VARCHAR(5),ce.StartTime,108),'') AS StartTime,
                ISNULL(CONVERT(VARCHAR(5),ce.EndTime,  108),'') AS EndTime,
                ISNULL(ce.IsAllDay,0)            AS IsAllDay,
                DATEDIFF(DAY,GETDATE(),ce.StartTime) AS DaysFromNow,
                ISNULL(sub.SubjectName,'')       AS SubjectName,
                0                                AS NotifCount
            FROM CalendarEvents ce
            LEFT JOIN Subjects sub ON sub.SubjectId=ce.SubjectId
            WHERE ce.InstituteId=@I AND ce.SessionId=@S
              AND CAST(ce.StartTime AS DATE) >= CAST(GETDATE() AS DATE)
              AND (@Type='' OR ISNULL(ce.EventType,'')=@Type)
              AND (@DFr IS NULL OR CAST(ce.StartTime AS DATE)>=TRY_CAST(@DFr AS DATE))
              AND (@DTo IS NULL OR CAST(ce.StartTime AS DATE)<=TRY_CAST(@DTo AS DATE))
            ORDER BY ce.StartTime ASC");
        c.Parameters.AddWithValue("@I", inst);
        c.Parameters.AddWithValue("@S", sess);
        c.Parameters.AddWithValue("@Type", eventType ?? "");
        c.Parameters.AddWithValue("@DFr", DV(dateFrom));
        c.Parameters.AddWithValue("@DTo", DV(dateTo));
        return Safe(c, "Upcoming");
    }

    // ── All Events ─────────────────────────────────────────────
    public DataTable GetAllEvents(int inst, int sess,
        string eventType, string dateFrom, string dateTo)
    {
        var c = new SqlCommand(@"
            SELECT
                ce.EventId,
                LTRIM(RTRIM(ce.Title))          AS Title,
                ISNULL(ce.EventType,'General')  AS EventType,
                CONVERT(VARCHAR(10),ce.StartTime,23) AS EventDateStr,
                YEAR(ce.StartTime)              AS Yr,
                MONTH(ce.StartTime)             AS Mon,
                DAY(ce.StartTime)               AS Dy,
                ISNULL(CONVERT(VARCHAR(5),ce.StartTime,108),'') AS StartTime,
                ISNULL(ce.IsAllDay,0)           AS IsAllDay,
                CASE
                    WHEN CAST(ce.StartTime AS DATE) < CAST(GETDATE() AS DATE) THEN 'past'
                    WHEN CAST(ce.StartTime AS DATE) = CAST(GETDATE() AS DATE) THEN 'today'
                    ELSE 'upcoming'
                END AS Status,
                DATEDIFF(DAY,GETDATE(),ce.StartTime) AS DaysFromNow,
                '' AS Location
            FROM CalendarEvents ce
            WHERE ce.InstituteId=@I AND ce.SessionId=@S
              AND (@Type='' OR ISNULL(ce.EventType,'')=@Type)
              AND (@DFr IS NULL OR CAST(ce.StartTime AS DATE)>=TRY_CAST(@DFr AS DATE))
              AND (@DTo IS NULL OR CAST(ce.StartTime AS DATE)<=TRY_CAST(@DTo AS DATE))
            ORDER BY ce.StartTime ASC");
        c.Parameters.AddWithValue("@I", inst);
        c.Parameters.AddWithValue("@S", sess);
        c.Parameters.AddWithValue("@Type", eventType ?? "");
        c.Parameters.AddWithValue("@DFr", DV(dateFrom));
        c.Parameters.AddWithValue("@DTo", DV(dateTo));
        return Safe(c, "AllEvents");
    }

    // ── Event Type Distribution ────────────────────────────────
    public DataTable GetEventTypeDistribution(int inst, int sess,
        string dateFrom, string dateTo)
    {
        var c = new SqlCommand(@"
            SELECT
                ISNULL(LTRIM(RTRIM(EventType)),'General') AS EventType,
                COUNT(*) AS Total,
                SUM(CASE WHEN CAST(StartTime AS DATE)>=CAST(GETDATE() AS DATE) THEN 1 ELSE 0 END) AS Upcoming,
                SUM(CASE WHEN CAST(StartTime AS DATE)< CAST(GETDATE() AS DATE) THEN 1 ELSE 0 END) AS Past
            FROM CalendarEvents
            WHERE InstituteId=@I AND SessionId=@S
              AND (@DFr IS NULL OR CAST(StartTime AS DATE)>=TRY_CAST(@DFr AS DATE))
              AND (@DTo IS NULL OR CAST(StartTime AS DATE)<=TRY_CAST(@DTo AS DATE))
            GROUP BY EventType
            ORDER BY Total DESC");
        c.Parameters.AddWithValue("@I", inst);
        c.Parameters.AddWithValue("@S", sess);
        c.Parameters.AddWithValue("@DFr", DV(dateFrom));
        c.Parameters.AddWithValue("@DTo", DV(dateTo));
        return Safe(c, "TypeDist");
    }

    // ── Monthly Event Count (last 12 months) ───────────────────
    public DataTable GetMonthlyEventCount(int inst, int sess, string eventType)
    {
        var c = new SqlCommand(@"
            WITH Mo AS (
                SELECT n,
                    MONTH(DATEADD(MONTH,-n,GETDATE())) AS M,
                    YEAR( DATEADD(MONTH,-n,GETDATE())) AS Y,
                    LEFT(DATENAME(MONTH,DATEADD(MONTH,-n,GETDATE())),3)+' '+
                    RIGHT(CAST(YEAR(DATEADD(MONTH,-n,GETDATE())) AS VARCHAR),2) AS ML
                FROM (VALUES(0),(1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11)) T(n)
            )
            SELECT mo.ML AS MonLabel, mo.M, mo.Y,
                   COUNT(e.EventId) AS EventCount
            FROM Mo mo
            LEFT JOIN CalendarEvents e
                   ON MONTH(e.StartTime)=mo.M AND YEAR(e.StartTime)=mo.Y
                  AND e.InstituteId=@I AND e.SessionId=@S
                  AND (@Type='' OR ISNULL(e.EventType,'')=@Type)
            GROUP BY mo.ML,mo.M,mo.Y,mo.n
            ORDER BY mo.Y,mo.M");
        c.Parameters.AddWithValue("@I", inst);
        c.Parameters.AddWithValue("@S", sess);
        c.Parameters.AddWithValue("@Type", eventType ?? "");
        return Safe(c, "Monthly");
    }

    // ── Day-of-Week Pattern ────────────────────────────────────
    public DataTable GetDayOfWeekPattern(int inst, int sess,
        string dateFrom, string dateTo)
    {
        var c = new SqlCommand(@"
            SELECT
                DATENAME(WEEKDAY,StartTime)  AS DayName,
                DATEPART(WEEKDAY,StartTime)  AS DayNum,
                COUNT(*)                     AS Total
            FROM CalendarEvents
            WHERE InstituteId=@I AND SessionId=@S
              AND (@DFr IS NULL OR CAST(StartTime AS DATE)>=TRY_CAST(@DFr AS DATE))
              AND (@DTo IS NULL OR CAST(StartTime AS DATE)<=TRY_CAST(@DTo AS DATE))
            GROUP BY DATENAME(WEEKDAY,StartTime), DATEPART(WEEKDAY,StartTime)
            ORDER BY DayNum");
        c.Parameters.AddWithValue("@I", inst);
        c.Parameters.AddWithValue("@S", sess);
        c.Parameters.AddWithValue("@DFr", DV(dateFrom));
        c.Parameters.AddWithValue("@DTo", DV(dateTo));
        return Safe(c, "DayOfWeek");
    }

    // ── Notification Trend ─────────────────────────────────────
    public DataTable GetNotificationTrend(int inst, int sess,
        string dateFrom, string dateTo)
    {
        var c = new SqlCommand(@"
            SELECT
                CONVERT(VARCHAR(10),CreatedOn,23) AS DateStr,
                COUNT(*) AS NotifCount,
                COUNT(DISTINCT UserId) AS UniqueRecipients
            FROM Notifications
            WHERE InstituteId=@I
              AND (@DFr IS NULL OR CAST(CreatedOn AS DATE)>=TRY_CAST(@DFr AS DATE))
              AND (@DTo IS NULL OR CAST(CreatedOn AS DATE)<=TRY_CAST(@DTo AS DATE))
            GROUP BY CONVERT(VARCHAR(10),CreatedOn,23)
            ORDER BY DateStr");
        c.Parameters.AddWithValue("@I", inst);
        c.Parameters.AddWithValue("@DFr", DV(dateFrom));
        c.Parameters.AddWithValue("@DTo", DV(dateTo));
        return Safe(c, "NotifTrend");
    }

    // ── Past Events ────────────────────────────────────────────
    public DataTable GetPastEvents(int inst, int sess,
        string eventType, string dateFrom, string dateTo)
    {
        var c = new SqlCommand(@"
            SELECT TOP 20
                ce.EventId,
                LTRIM(RTRIM(ce.Title))          AS Title,
                ISNULL(ce.EventType,'General')  AS EventType,
                CONVERT(VARCHAR(10),ce.StartTime,23) AS EventDateStr,
                ISNULL(CONVERT(VARCHAR(5),ce.StartTime,108),'') AS StartTime,
                '' AS Location,
                ABS(DATEDIFF(DAY,GETDATE(),ce.StartTime)) AS DaysAgo
            FROM CalendarEvents ce
            WHERE ce.InstituteId=@I AND ce.SessionId=@S
              AND CAST(ce.StartTime AS DATE) < CAST(GETDATE() AS DATE)
              AND (@Type='' OR ISNULL(ce.EventType,'')=@Type)
              AND (@DFr IS NULL OR CAST(ce.StartTime AS DATE)>=TRY_CAST(@DFr AS DATE))
              AND (@DTo IS NULL OR CAST(ce.StartTime AS DATE)<=TRY_CAST(@DTo AS DATE))
            ORDER BY ce.StartTime DESC");
        c.Parameters.AddWithValue("@I", inst);
        c.Parameters.AddWithValue("@S", sess);
        c.Parameters.AddWithValue("@Type", eventType ?? "");
        c.Parameters.AddWithValue("@DFr", DV(dateFrom));
        c.Parameters.AddWithValue("@DTo", DV(dateTo));
        return Safe(c, "PastEvents");
    }

    // ── Calendar Heatmap ───────────────────────────────────────
    public DataTable GetCalendarHeatmap(int inst, int sess,
        int year, int month, string eventType)
    {
        var c = new SqlCommand(@"
            SELECT
                DAY(StartTime)                 AS Day,
                ISNULL(EventType,'General')    AS EventType,
                COUNT(*)                       AS EventCount,
                MAX(LTRIM(RTRIM(Title)))       AS EventTitles
            FROM CalendarEvents
            WHERE InstituteId=@I AND SessionId=@S
              AND MONTH(StartTime)=@Mon AND YEAR(StartTime)=@Yr
              AND (@Type='' OR ISNULL(EventType,'')=@Type)
            GROUP BY DAY(StartTime), EventType
            ORDER BY DAY(StartTime)");
        c.Parameters.AddWithValue("@I", inst);
        c.Parameters.AddWithValue("@S", sess);
        c.Parameters.AddWithValue("@Mon", month);
        c.Parameters.AddWithValue("@Yr", year);
        c.Parameters.AddWithValue("@Type", eventType ?? "");
        return Safe(c, "Heatmap");
    }

    // ── Admin Stats ────────────────────────────────────────────
    public DataTable GetAdminStats(int inst, int sess)
    {
        var result = new DataTable();
        foreach (var col in new[] {
            "Next7","MonthsWithEvents","NotifThisMonth",
            "UpcomingNoDesc","TotalThisYear","BusiestType"
        })
        {
            if (col == "BusiestType") result.Columns.Add(col, typeof(string));
            else result.Columns.Add(col, typeof(int));
        }

        var row = result.NewRow();
        row["Next7"] = 0; row["MonthsWithEvents"] = 0; row["NotifThisMonth"] = 0;
        row["UpcomingNoDesc"] = 0; row["TotalThisYear"] = 0; row["BusiestType"] = "—";

        try
        {
            // Note: no Description column — UpcomingNoDesc always 0 for this schema
            var c = new SqlCommand(@"
                SELECT
                  (SELECT COUNT(*) FROM CalendarEvents
                   WHERE InstituteId=@I AND SessionId=@S
                     AND CAST(StartTime AS DATE) BETWEEN CAST(GETDATE() AS DATE)
                         AND CAST(DATEADD(DAY,7,GETDATE()) AS DATE))   AS Next7,
                  (SELECT COUNT(DISTINCT MONTH(StartTime)) FROM CalendarEvents
                   WHERE InstituteId=@I AND SessionId=@S
                     AND YEAR(StartTime)=YEAR(GETDATE()))               AS MonthsWithEvents,
                  (SELECT COUNT(*) FROM CalendarEvents
                   WHERE InstituteId=@I AND SessionId=@S
                     AND YEAR(StartTime)=YEAR(GETDATE()))               AS TotalThisYear,
                  0                                                     AS UpcomingNoDesc,
                  ISNULL((SELECT TOP 1 ISNULL(EventType,'General')
                          FROM CalendarEvents
                          WHERE InstituteId=@I AND SessionId=@S
                          GROUP BY EventType
                          ORDER BY COUNT(*) DESC),'—')                 AS BusiestType");
            c.Parameters.AddWithValue("@I", inst);
            c.Parameters.AddWithValue("@S", sess);
            var dt = _dl.GetDataTable(c);
            if (dt?.Rows.Count > 0)
            {
                row["Next7"] = dt.Rows[0]["Next7"];
                row["MonthsWithEvents"] = dt.Rows[0]["MonthsWithEvents"];
                row["TotalThisYear"] = dt.Rows[0]["TotalThisYear"];
                row["UpcomingNoDesc"] = dt.Rows[0]["UpcomingNoDesc"];
                row["BusiestType"] = dt.Rows[0]["BusiestType"];
            }
        }
        catch (Exception ex)
        { System.Diagnostics.Debug.WriteLine("[EventsCal.AdminStats] " + ex.Message); }

        try
        {
            var c = new SqlCommand(@"
                SELECT COUNT(*) AS N FROM Notifications
                WHERE InstituteId=@I
                  AND MONTH(CreatedOn)=MONTH(GETDATE())
                  AND YEAR(CreatedOn)=YEAR(GETDATE())");
            c.Parameters.AddWithValue("@I", inst);
            var dt = _dl.GetDataTable(c);
            row["NotifThisMonth"] = dt?.Rows.Count > 0 ? dt.Rows[0]["N"] : 0;
        }
        catch (Exception ex)
        { System.Diagnostics.Debug.WriteLine("[EventsCal.AdminStats.Notif] " + ex.Message); }

        result.Rows.Add(row);
        return result;
    }
}