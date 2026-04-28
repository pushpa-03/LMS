using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

/// <summary>
/// Business Logic Layer for Attendance Module
/// </summary>
public class AttendanceBL
{
    private readonly DataLayer _dl = new DataLayer();

    // ─────────────────────────────────────────────
    // 1. Get subjects assigned to a teacher
    // ─────────────────────────────────────────────
    /// <summary>
    /// Returns all active subjects assigned to the given teacher
    /// for the current active academic session.
    /// Joins SubjectFaculty → Subjects → AcademicSessions
    /// </summary>
    public DataTable GetTeacherSubjects(int teacherId, int instituteId, int societyId)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT DISTINCT
                sf.SubjectId,
                s.SubjectName,
                s.SubjectCode,
                sf.SessionId,
                acs.SessionName,
                sf.SectionId,
                sec.SectionName
            FROM SubjectFaculty sf
            INNER JOIN Subjects           s   ON s.SubjectId   = sf.SubjectId
            INNER JOIN AcademicSessions   acs ON acs.SessionId = sf.SessionId
            LEFT  JOIN Sections           sec ON sec.SectionId = sf.SectionId
            WHERE sf.TeacherId   = @TeacherId
              AND sf.InstituteId = @InstituteId
              AND sf.SocietyId   = @SocietyId
              AND sf.IsActive    = 1
              AND acs.IsCurrent  = 1
            ORDER BY s.SubjectName");

        cmd.Parameters.AddWithValue("@TeacherId", teacherId);
        cmd.Parameters.AddWithValue("@InstituteId", instituteId);
        cmd.Parameters.AddWithValue("@SocietyId", societyId);

        return _dl.GetDataTable(cmd);
    }

    // ─────────────────────────────────────────────
    // 2. Get students enrolled in a subject
    // ─────────────────────────────────────────────
    /// <summary>
    /// Returns students assigned to a subject in the given session.
    /// Also fetches today's attendance status if already marked.
    /// </summary>
    public DataTable GetStudentsForSubject(int subjectId, int sessionId, int instituteId, int societyId, DateTime date)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT
                u.UserId,
                up.FullName,
                sad.RollNumber,
                ISNULL(a.Status, '') AS Status,
                a.AttendanceId
            FROM AssignStudentSubject ass
            INNER JOIN Users              u   ON u.UserId     = ass.UserId
            INNER JOIN UserProfile        up  ON up.UserId    = u.UserId
            LEFT  JOIN StudentAcademicDetails sad ON sad.UserId = u.UserId
                                                  AND sad.InstituteId = ass.InstituteId
            LEFT  JOIN Attendance         a   ON a.UserId    = u.UserId
                                              AND a.SubjectId = ass.SubjectId
                                              AND a.Date      = @Date
            WHERE ass.SubjectId   = @SubjectId
              AND ass.SessionId   = @SessionId
              AND ass.InstituteId = @InstituteId
              AND ass.SocietyId   = @SocietyId
              AND u.IsActive      = 1
            ORDER BY sad.RollNumber, up.FullName");

        cmd.Parameters.AddWithValue("@SubjectId", subjectId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);
        cmd.Parameters.AddWithValue("@InstituteId", instituteId);
        cmd.Parameters.AddWithValue("@SocietyId", societyId);
        cmd.Parameters.AddWithValue("@Date", date.Date);

        return _dl.GetDataTable(cmd);
    }

    // ─────────────────────────────────────────────
    // 3. Check if attendance already marked
    // ─────────────────────────────────────────────
    public bool IsAttendanceAlreadyMarked(int subjectId, DateTime date, int instituteId, int societyId)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT COUNT(1)
            FROM Attendance
            WHERE SubjectId   = @SubjectId
              AND Date        = @Date
              AND InstituteId = @InstituteId
              AND SocietyId   = @SocietyId");

        cmd.Parameters.AddWithValue("@SubjectId", subjectId);
        cmd.Parameters.AddWithValue("@Date", date.Date);
        cmd.Parameters.AddWithValue("@InstituteId", instituteId);
        cmd.Parameters.AddWithValue("@SocietyId", societyId);

        DataTable dt = _dl.GetDataTable(cmd);
        if (dt != null && dt.Rows.Count > 0)
            return Convert.ToInt32(dt.Rows[0][0]) > 0;

        return false;
    }

    // ─────────────────────────────────────────────
    // 4. Save / Update Attendance (MERGE approach)
    // ─────────────────────────────────────────────
    /// <summary>
    /// Saves or updates attendance for a list of students.
    /// Uses individual MERGE statements in a single transaction.
    /// </summary>
    public bool SaveAttendance(List<AttendanceRecord> records, int markedBy, int societyId, int instituteId)
    {
        if (records == null || records.Count == 0)
            return false;

        List<SqlCommand> commands = new List<SqlCommand>();

        foreach (var rec in records)
        {
            SqlCommand cmd = new SqlCommand(@"
                MERGE Attendance AS target
                USING (SELECT @UserId AS UserId, @SubjectId AS SubjectId, @Date AS Date) AS source
                    ON target.UserId    = source.UserId
                   AND target.SubjectId = source.SubjectId
                   AND target.Date      = source.Date
                WHEN MATCHED THEN
                    UPDATE SET Status    = @Status,
                               MarkedBy  = @MarkedBy,
                               MarkedOn  = GETDATE()
                WHEN NOT MATCHED THEN
                    INSERT (SocietyId, InstituteId, UserId, SubjectId, SessionId, Date, Status, MarkedBy, MarkedOn)
                    VALUES (@SocietyId, @InstituteId, @UserId, @SubjectId, @SessionId, @Date, @Status, @MarkedBy, GETDATE());");

            cmd.Parameters.AddWithValue("@UserId", rec.UserId);
            cmd.Parameters.AddWithValue("@SubjectId", rec.SubjectId);
            cmd.Parameters.AddWithValue("@SessionId", rec.SessionId);
            cmd.Parameters.AddWithValue("@Date", rec.Date.Date);
            cmd.Parameters.AddWithValue("@Status", rec.Status);
            cmd.Parameters.AddWithValue("@MarkedBy", markedBy);
            cmd.Parameters.AddWithValue("@SocietyId", societyId);
            cmd.Parameters.AddWithValue("@InstituteId", instituteId);

            commands.Add(cmd);
        }

        return _dl.ExecuteTransaction(commands);
    }

    // ─────────────────────────────────────────────
    // 5. Get Attendance Report (by subject, date range)
    // ─────────────────────────────────────────────
    public DataTable GetAttendanceReport(int subjectId, int sessionId, int instituteId, int societyId,
                                         DateTime fromDate, DateTime toDate)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT
                up.FullName,
                sad.RollNumber,
                COUNT(a.AttendanceId)                                               AS TotalClasses,
                SUM(CASE WHEN a.Status = 'Present' THEN 1 ELSE 0 END)              AS PresentCount,
                SUM(CASE WHEN a.Status = 'Absent'  THEN 1 ELSE 0 END)              AS AbsentCount,
                SUM(CASE WHEN a.Status = 'Leave'   THEN 1 ELSE 0 END)              AS LeaveCount,
                CAST(
                    CASE WHEN COUNT(a.AttendanceId) = 0 THEN 0
                         ELSE ROUND(
                             100.0 * SUM(CASE WHEN a.Status = 'Present' THEN 1 ELSE 0 END)
                             / COUNT(a.AttendanceId), 2)
                    END AS DECIMAL(5,2))                                            AS Percentage
            FROM AssignStudentSubject ass
            INNER JOIN Users              u   ON u.UserId    = ass.UserId
            INNER JOIN UserProfile        up  ON up.UserId   = u.UserId
            LEFT  JOIN StudentAcademicDetails sad ON sad.UserId = u.UserId
                                                  AND sad.InstituteId = ass.InstituteId
            LEFT  JOIN Attendance         a   ON a.UserId    = u.UserId
                                              AND a.SubjectId = ass.SubjectId
                                              AND a.Date     BETWEEN @FromDate AND @ToDate
            WHERE ass.SubjectId   = @SubjectId
              AND ass.SessionId   = @SessionId
              AND ass.InstituteId = @InstituteId
              AND ass.SocietyId   = @SocietyId
              AND u.IsActive      = 1
            GROUP BY up.FullName, sad.RollNumber
            ORDER BY sad.RollNumber, up.FullName");

        cmd.Parameters.AddWithValue("@SubjectId", subjectId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);
        cmd.Parameters.AddWithValue("@InstituteId", instituteId);
        cmd.Parameters.AddWithValue("@SocietyId", societyId);
        cmd.Parameters.AddWithValue("@FromDate", fromDate.Date);
        cmd.Parameters.AddWithValue("@ToDate", toDate.Date);

        return _dl.GetDataTable(cmd);
    }

    // ─────────────────────────────────────────────
    // 6. Get day-wise attendance list for a subject
    // ─────────────────────────────────────────────
    public DataTable GetDayWiseAttendance(int subjectId, int sessionId, int instituteId, int societyId,
                                          DateTime fromDate, DateTime toDate)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT
                a.Date,
                COUNT(a.AttendanceId)                                          AS TotalStudents,
                SUM(CASE WHEN a.Status = 'Present' THEN 1 ELSE 0 END)         AS PresentCount,
                SUM(CASE WHEN a.Status = 'Absent'  THEN 1 ELSE 0 END)         AS AbsentCount,
                SUM(CASE WHEN a.Status = 'Leave'   THEN 1 ELSE 0 END)         AS LeaveCount
            FROM Attendance a
            WHERE a.SubjectId   = @SubjectId
              AND a.InstituteId = @InstituteId
              AND a.SocietyId   = @SocietyId
              AND a.Date        BETWEEN @FromDate AND @ToDate
            GROUP BY a.Date
            ORDER BY a.Date DESC");

        cmd.Parameters.AddWithValue("@SubjectId", subjectId);
        cmd.Parameters.AddWithValue("@InstituteId", instituteId);
        cmd.Parameters.AddWithValue("@SocietyId", societyId);
        cmd.Parameters.AddWithValue("@FromDate", fromDate.Date);
        cmd.Parameters.AddWithValue("@ToDate", toDate.Date);

        return _dl.GetDataTable(cmd);
    }
}

// ─────────────────────────────────────────────
// Helper model to pass attendance records
// ─────────────────────────────────────────────
public class AttendanceRecord
{
    public int UserId { get; set; }
    public int SubjectId { get; set; }
    public int SessionId { get; set; }
    public DateTime Date { get; set; }
    public string Status { get; set; }  // Present / Absent / Leave
}