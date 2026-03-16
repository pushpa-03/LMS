using System;
using System.Data;
using System.Data.SqlClient;

public class StudentAttendanceBL
{
    DataLayer dl = new DataLayer();

    // ============================================================
    // ✅ 1. Overall summary across all subjects
    // ============================================================
    public DataTable GetOverallSummary(int userId, int instituteId, int sessionId)
    {
        SqlCommand cmd = new SqlCommand(@"
    SELECT
        ISNULL(COUNT(*),0) AS Total,
        ISNULL(SUM(CASE WHEN Status = 'Present' THEN 1 ELSE 0 END),0) AS Present,
        ISNULL(SUM(CASE WHEN Status = 'Absent'  THEN 1 ELSE 0 END),0) AS Absent,
        ISNULL(SUM(CASE WHEN Status = 'Leave'   THEN 1 ELSE 0 END),0) AS Leave,
        CASE WHEN COUNT(*) > 0
             THEN CAST(ROUND(
                  SUM(CASE WHEN Status = 'Present' THEN 1.0 ELSE 0 END)
                  / COUNT(*) * 100, 1) AS DECIMAL(5,1))
             ELSE 0
        END AS Percentage
    FROM Attendance
    WHERE UserId      = @UserId
      AND InstituteId = @InstId
      AND SessionId   = @SessId");

        cmd.Parameters.AddWithValue("@UserId", userId);
        cmd.Parameters.AddWithValue("@InstId", instituteId);
        cmd.Parameters.AddWithValue("@SessId", sessionId);

        return dl.GetDataTable(cmd);
    }

    // ============================================================
    // ✅ 2. Per-subject breakdown (for subject cards)
    // ============================================================
    public DataTable GetSubjectWiseAttendance(int userId, int instituteId, int sessionId)
    {
        SqlCommand cmd = new SqlCommand(@"
        SELECT
            S.SubjectId,
            S.SubjectName,
            S.SubjectCode,
            COUNT(A.AttendanceId)                                       AS Total,
            SUM(CASE WHEN A.Status = 'Present' THEN 1 ELSE 0 END)      AS Present,
            SUM(CASE WHEN A.Status = 'Absent'  THEN 1 ELSE 0 END)      AS Absent,
            SUM(CASE WHEN A.Status = 'Leave'   THEN 1 ELSE 0 END)      AS Leave,
            CASE WHEN COUNT(A.AttendanceId) > 0
                 THEN CAST(ROUND(
                      SUM(CASE WHEN A.Status = 'Present' THEN 1.0 ELSE 0 END)
                      / COUNT(A.AttendanceId) * 100, 1) AS DECIMAL(5,1))
                 ELSE 0
            END AS Percentage
        FROM AssignStudentSubject ASS
        JOIN Subjects S ON ASS.SubjectId = S.SubjectId
        LEFT JOIN Attendance A
               ON A.SubjectId   = S.SubjectId
              AND A.UserId      = @UserId
              AND A.InstituteId = @InstId
              AND A.SessionId   = @SessId
        WHERE ASS.UserId      = @UserId
          AND ASS.InstituteId = @InstId
          AND ASS.SessionId   = @SessId
          AND S.IsActive      = 1
        GROUP BY S.SubjectId, S.SubjectName, S.SubjectCode
        ORDER BY Percentage ASC");

        cmd.Parameters.AddWithValue("@UserId", userId);
        cmd.Parameters.AddWithValue("@InstId", instituteId);
        cmd.Parameters.AddWithValue("@SessId", sessionId);

        return dl.GetDataTable(cmd);
    }

    // ============================================================
    // ✅ 3. Monthly calendar data for a subject
    // ============================================================
    public DataTable GetMonthlyAttendance(int userId, int subjectId,
                                          int instituteId, int year, int month)
    {
        SqlCommand cmd = new SqlCommand(@"
        SELECT Date, Status
        FROM Attendance
        WHERE UserId      = @UserId
          AND SubjectId   = @SubjId
          AND InstituteId = @InstId
          AND YEAR(Date)  = @Year
          AND MONTH(Date) = @Month
        ORDER BY Date");

        cmd.Parameters.AddWithValue("@UserId", userId);
        cmd.Parameters.AddWithValue("@SubjId", subjectId);
        cmd.Parameters.AddWithValue("@InstId", instituteId);
        cmd.Parameters.AddWithValue("@Year", year);
        cmd.Parameters.AddWithValue("@Month", month);

        return dl.GetDataTable(cmd);
    }

    // ============================================================
    // ✅ 4. Recent attendance log (last 10 records per subject)
    // ============================================================
    public DataTable GetRecentAttendance(int userId, int instituteId,
                                         int sessionId, int subjectId = 0)
    {
        SqlCommand cmd = new SqlCommand(@"
        SELECT TOP 30
            A.Date,
            A.Status,
            S.SubjectName,
            S.SubjectCode,
            DATENAME(WEEKDAY, A.Date) AS DayName
        FROM Attendance A
        JOIN Subjects S ON A.SubjectId = S.SubjectId
        WHERE A.UserId      = @UserId
          AND A.InstituteId = @InstId
          AND A.SessionId   = @SessId
          AND (@SubjId = 0 OR A.SubjectId = @SubjId)
        ORDER BY A.Date DESC");

        cmd.Parameters.AddWithValue("@UserId", userId);
        cmd.Parameters.AddWithValue("@InstId", instituteId);
        cmd.Parameters.AddWithValue("@SessId", sessionId);
        cmd.Parameters.AddWithValue("@SubjId", subjectId);

        return dl.GetDataTable(cmd);
    }

    // ============================================================
    // ✅ 5. Classes needed to reach target %
    // ============================================================
    public int ClassesNeededForTarget(int present, int total, int target = 75)
    {
        // How many consecutive classes needed to reach target%?
        // (present + x) / (total + x) >= target/100
        // present + x >= (total + x) * target/100
        // 100*present + 100x >= target*total + target*x
        // x(100 - target) >= target*total - 100*present
        // x >= (target*total - 100*present) / (100 - target)

        if (total == 0) return 0;
        double currentPct = (double)present / total * 100;
        if (currentPct >= target) return 0;

        double x = ((double)target * total - 100.0 * present) / (100.0 - target);
        return (int)Math.Ceiling(x);
    }
}