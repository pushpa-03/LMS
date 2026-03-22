using System;
using System.Data;
using System.Data.SqlClient;

public class CalendarBL
{
    DataLayer dl = new DataLayer();

    // ── GET EVENTS BY DATE (Admin — institute-wide, no subject filter) ──
    public DataTable GetEvents(DateTime date, int instituteId)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = @"
            SELECT EventId, Title, EventType
            FROM CalendarEvents
            WHERE CAST(StartTime AS DATE) = @date
              AND InstituteId = @inst";
        cmd.Parameters.AddWithValue("@date", date.Date);
        cmd.Parameters.AddWithValue("@inst", instituteId);
        return dl.GetDataTable(cmd);
    }

    // ── GET EVENTS BY DATE FOR STUDENT (only subjects they are enrolled in) ──
    public DataTable GetEventsForStudent(DateTime date, int instituteId, int studentId)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = @"
            SELECT ce.EventId, ce.Title, ce.EventType
            FROM CalendarEvents ce
            WHERE CAST(ce.StartTime AS DATE) = @date
              AND ce.InstituteId = @inst
              AND (
                    ce.SubjectId IS NULL   -- institute-wide events (admin)
                    OR ce.SubjectId IN (
                        SELECT SubjectId 
                        FROM AssignStudentSubject 
                        WHERE UserId = @studentId
                    )
                  )";
        cmd.Parameters.AddWithValue("@date", date.Date);
        cmd.Parameters.AddWithValue("@inst", instituteId);
        cmd.Parameters.AddWithValue("@studentId", studentId);
        return dl.GetDataTable(cmd);
    }

    // ── GET EVENTS BY DATE FOR TEACHER (their subjects only + institute-wide) ──
    public DataTable GetEventsForTeacher(DateTime date, int instituteId, int teacherUserId)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = @"
        SELECT ce.EventId, ce.Title, ce.EventType
        FROM CalendarEvents ce
        WHERE CAST(ce.StartTime AS DATE) = @date
          AND ce.InstituteId = @inst
          AND (
                ce.SubjectId IS NULL
                OR ce.SubjectId IN (
                    SELECT SubjectId FROM SubjectFaculty
                    WHERE TeacherId = @teacherId AND IsActive = 1
                )
              )";
        cmd.Parameters.AddWithValue("@date", date.Date);
        cmd.Parameters.AddWithValue("@inst", instituteId);
        cmd.Parameters.AddWithValue("@teacherId", teacherUserId);
        return dl.GetDataTable(cmd);
    }

    // ── GET MONTHLY EVENTS (Admin) ──
    public DataTable GetEventsByMonth(int year, int month, int instituteId)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = @"
            SELECT 
                MIN(EventId)   AS EventId,
                Title,
                EventType,
                MIN(StartTime) AS StartDate,
                MAX(StartTime) AS EndDate,
                IsAllDay
            FROM CalendarEvents
            WHERE MONTH(StartTime) = @month
              AND YEAR(StartTime)  = @year
              AND InstituteId      = @inst
            GROUP BY Title, EventType, IsAllDay
            ORDER BY MIN(StartTime)";
        cmd.Parameters.AddWithValue("@month", month);
        cmd.Parameters.AddWithValue("@year", year);
        cmd.Parameters.AddWithValue("@inst", instituteId);
        return dl.GetDataTable(cmd);
    }

    // ── GET MONTHLY EVENTS FOR TEACHER (their subjects + institute-wide) ──
    public DataTable GetEventsByMonthForTeacher(int year, int month, int instituteId, int teacherUserId)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = @"
        SELECT 
            MIN(ce.EventId)   AS EventId,
            ce.Title,
            ce.EventType,
            MIN(ce.StartTime) AS StartDate,
            MAX(ce.StartTime) AS EndDate,
            ce.IsAllDay,
            ISNULL(s.SubjectName, 'Institute-wide') AS SubjectName
        FROM CalendarEvents ce
        LEFT JOIN Subjects s ON s.SubjectId = ce.SubjectId
        WHERE MONTH(ce.StartTime) = @month
          AND YEAR(ce.StartTime)  = @year
          AND ce.InstituteId      = @inst
          AND (
                ce.SubjectId IS NULL
                OR ce.SubjectId IN (
                    SELECT SubjectId FROM SubjectFaculty
                    WHERE TeacherId = @teacherId AND IsActive = 1
                )
              )
        GROUP BY ce.Title, ce.EventType, ce.IsAllDay, s.SubjectName
        ORDER BY MIN(ce.StartTime)";
        cmd.Parameters.AddWithValue("@month", month);
        cmd.Parameters.AddWithValue("@year", year);
        cmd.Parameters.AddWithValue("@inst", instituteId);
        cmd.Parameters.AddWithValue("@teacherId", teacherUserId);
        return dl.GetDataTable(cmd);
    }

    // ── GET TEACHER'S SUBJECTS (for dropdown in add event modal) ──
    public DataTable GetTeacherSubjects(int teacherUserId, int instituteId)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = @"
        SELECT DISTINCT sf.SubjectId, s.SubjectName
        FROM SubjectFaculty sf
        INNER JOIN Subjects s ON s.SubjectId = sf.SubjectId
        WHERE sf.TeacherId   = @teacherId
          AND sf.InstituteId = @inst
          AND sf.IsActive    = 1
          AND s.IsActive     = 1";
        cmd.Parameters.AddWithValue("@teacherId", teacherUserId);
        cmd.Parameters.AddWithValue("@inst", instituteId);
        return dl.GetDataTable(cmd);
    }

    // ── INSERT EVENT (one row per day) ──
    public void AddEvent(CalendarGC obj)
    {
        DateTime current = obj.StartTime.Date;
        DateTime end = obj.EndTime.Date;

        while (current <= end)
        {
            SqlCommand cmd = new SqlCommand();
            cmd.CommandText = @"
                INSERT INTO CalendarEvents
                (UserId, SocietyId, InstituteId, SubjectId, Title, EventType, StartTime, EndTime, IsAllDay)
                VALUES
                (@uid, @sid, @iid, @subjectId, @title, @type, @start, @end, @allday)";

            cmd.Parameters.AddWithValue("@uid", obj.UserId ?? (object)DBNull.Value);
            cmd.Parameters.AddWithValue("@sid", obj.SocietyId ?? (object)DBNull.Value);
            cmd.Parameters.AddWithValue("@iid", obj.InstituteId ?? (object)DBNull.Value);
            cmd.Parameters.AddWithValue("@subjectId", obj.SubjectId ?? (object)DBNull.Value);
            cmd.Parameters.AddWithValue("@title", obj.Title);
            cmd.Parameters.AddWithValue("@type", obj.EventType);
            cmd.Parameters.AddWithValue("@start", current);
            cmd.Parameters.AddWithValue("@end", current);
            cmd.Parameters.AddWithValue("@allday", obj.IsAllDay);

            dl.ExecuteCMD(cmd);
            current = current.AddDays(1);
        }
    }

    // ── GET SINGLE EVENT ──
    public CalendarGC GetEventById(int eventId)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = @"
            SELECT EventId, Title, EventType, StartTime, EndTime, IsAllDay,
                   InstituteId, UserId, SocietyId, SubjectId
            FROM CalendarEvents WHERE EventId = @id";
        cmd.Parameters.AddWithValue("@id", eventId);

        DataTable dt = dl.GetDataTable(cmd);
        if (dt.Rows.Count == 0) return null;

        DataRow row = dt.Rows[0];
        return new CalendarGC
        {
            EventId = Convert.ToInt32(row["EventId"]),
            Title = row["Title"].ToString(),
            EventType = row["EventType"].ToString(),
            StartTime = Convert.ToDateTime(row["StartTime"]),
            EndTime = Convert.ToDateTime(row["EndTime"]),
            IsAllDay = Convert.ToBoolean(row["IsAllDay"]),
            InstituteId = row["InstituteId"] == DBNull.Value ? (int?)null : Convert.ToInt32(row["InstituteId"]),
            UserId = row["UserId"] == DBNull.Value ? (int?)null : Convert.ToInt32(row["UserId"]),
            SocietyId = row["SocietyId"] == DBNull.Value ? (int?)null : Convert.ToInt32(row["SocietyId"]),
            SubjectId = row["SubjectId"] == DBNull.Value ? (int?)null : Convert.ToInt32(row["SubjectId"])
        };
    }

    // ── DELETE EVENT GROUP ──
    public void DeleteEventGroup(int eventId, int instituteId)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = @"
            DELETE FROM CalendarEvents
            WHERE InstituteId = @inst
              AND Title     = (SELECT Title     FROM CalendarEvents WHERE EventId = @id)
              AND EventType = (SELECT EventType FROM CalendarEvents WHERE EventId = @id)
              AND (SubjectId = (SELECT SubjectId FROM CalendarEvents WHERE EventId = @id)
                   OR (SubjectId IS NULL AND (SELECT SubjectId FROM CalendarEvents WHERE EventId = @id) IS NULL))";
        cmd.Parameters.AddWithValue("@id", eventId);
        cmd.Parameters.AddWithValue("@inst", instituteId);
        dl.ExecuteCMD(cmd);
    }

    // ── GET EVENT GROUP DATE RANGE ──
    public void GetEventGroupRange(int eventId, int instituteId, out DateTime groupStart, out DateTime groupEnd)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = @"
            SELECT MIN(StartTime) AS GroupStart, MAX(StartTime) AS GroupEnd
            FROM CalendarEvents
            WHERE InstituteId = @inst
              AND Title     = (SELECT Title     FROM CalendarEvents WHERE EventId = @id)
              AND EventType = (SELECT EventType FROM CalendarEvents WHERE EventId = @id)
              AND (SubjectId = (SELECT SubjectId FROM CalendarEvents WHERE EventId = @id)
                   OR (SubjectId IS NULL AND (SELECT SubjectId FROM CalendarEvents WHERE EventId = @id) IS NULL))";
        cmd.Parameters.AddWithValue("@id", eventId);
        cmd.Parameters.AddWithValue("@inst", instituteId);

        DataTable dt = dl.GetDataTable(cmd);
        groupStart = Convert.ToDateTime(dt.Rows[0]["GroupStart"]);
        groupEnd = Convert.ToDateTime(dt.Rows[0]["GroupEnd"]);
    }
    public DataTable GetEventsByMonthForStudent(int year, int month, int instituteId, int studentId)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = @"
        SELECT
            MIN(ce.EventId)   AS EventId,
            ce.Title,
            ce.EventType,
            MIN(ce.StartTime) AS StartDate,
            MAX(ce.StartTime) AS EndDate,
            ce.IsAllDay,
            ISNULL(s.SubjectName, 'Institute-wide') AS SubjectName
        FROM CalendarEvents ce
        LEFT JOIN Subjects s ON s.SubjectId = ce.SubjectId
        WHERE MONTH(ce.StartTime) = @month
          AND YEAR(ce.StartTime)  = @year
          AND ce.InstituteId      = @inst
          AND (
                ce.SubjectId IS NULL        -- admin institute-wide events
                OR ce.SubjectId IN (
                    SELECT SubjectId
                    FROM AssignStudentSubject
                    WHERE UserId = @studentId
                )
              )
        GROUP BY ce.Title, ce.EventType, ce.IsAllDay, s.SubjectName
        ORDER BY MIN(ce.StartTime)";
        cmd.Parameters.AddWithValue("@month", month);
        cmd.Parameters.AddWithValue("@year", year);
        cmd.Parameters.AddWithValue("@inst", instituteId);
        cmd.Parameters.AddWithValue("@studentId", studentId);
        return dl.GetDataTable(cmd);
    }
}