using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;

/// <summary>
/// Business Logic Layer for Attendance Module
/// </summary>
public class AttendanceBL
{
    private readonly DataLayer _dl = new DataLayer();

    // ─────────────────────────────────────────────
    // 1. Get subjects assigned to a teacher
    // ─────────────────────────────────────────────
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
        // Use date only (no time)
        DateTime dateOnly = date.Date;

        SqlCommand cmd = new SqlCommand(@"
        SELECT COUNT(1) as AttendanceCount, 
               (SELECT TOP 1 Status FROM Attendance 
                WHERE SubjectId = @SubjectId 
                  AND CAST(Date AS DATE) = @Date
                  AND InstituteId = @InstituteId 
                  AND SocietyId = @SocietyId) as SampleStatus
        FROM Attendance
        WHERE SubjectId   = @SubjectId
          AND CAST(Date AS DATE) = @Date
          AND InstituteId = @InstituteId
          AND SocietyId   = @SocietyId");

        cmd.Parameters.AddWithValue("@SubjectId", subjectId);
        cmd.Parameters.AddWithValue("@Date", dateOnly.ToString("yyyy-MM-dd"));
        cmd.Parameters.AddWithValue("@InstituteId", instituteId);
        cmd.Parameters.AddWithValue("@SocietyId", societyId);

        DataTable dt = _dl.GetDataTable(cmd);
        if (dt != null && dt.Rows.Count > 0)
        {
            int count = Convert.ToInt32(dt.Rows[0]["AttendanceCount"]);

            // Debug output - check your Visual Studio Output window
            System.Diagnostics.Debug.WriteLine($"=== Attendance Check ===");
            System.Diagnostics.Debug.WriteLine($"SubjectId: {subjectId}");
            System.Diagnostics.Debug.WriteLine($"Date: {dateOnly}");
            System.Diagnostics.Debug.WriteLine($"InstituteId: {instituteId}");
            System.Diagnostics.Debug.WriteLine($"SocietyId: {societyId}");
            System.Diagnostics.Debug.WriteLine($"Found Count: {count}");
            if (count > 0 && dt.Rows[0]["SampleStatus"] != DBNull.Value)
            {
                System.Diagnostics.Debug.WriteLine($"Sample Status: {dt.Rows[0]["SampleStatus"]}");
            }

            return count > 0;
        }

        return false;
    }
    // ─────────────────────────────────────────────
    // 4. Save / Update Attendance
    // ─────────────────────────────────────────────
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
    // 5. Get Attendance Report
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

    public class AnalyticsResult
    {
        public double AvgAttendancePct { get; set; }
        public int TotalPresent { get; set; }
        public int TotalAbsent { get; set; }
        public int TotalLeave { get; set; }
        public int LowAttendanceCount { get; set; }
        public int TotalClassDays { get; set; }

        public List<string> SubjectNames { get; set; }
        public List<double> SubjectAvgPct { get; set; }
        public List<int> SubjectPresent { get; set; }
        public List<int> SubjectAbsent { get; set; }
        public List<int> SubjectLeave { get; set; }

        public List<string> MonthLabels { get; set; }
        public List<int> MonthPresent { get; set; }
        public List<int> MonthAbsent { get; set; }
        public List<int> MonthLeave { get; set; }

        public List<string> DowLabels { get; set; }
        public List<double> DowAvgPct { get; set; }

        public List<string> DistLabels { get; set; }
        public List<int> DistCounts { get; set; }

        public List<string> AbsenteeNames { get; set; }
        public List<int> AbsenteeCounts { get; set; }
        public List<string> TopStudentNames { get; set; }
        public List<double> TopStudentPct { get; set; }

        public List<int> RiskSafe { get; set; }
        public List<int> RiskGood { get; set; }
        public List<int> RiskWarning { get; set; }
        public List<int> RiskDanger { get; set; }

        public List<string> CumulDates { get; set; }
        public List<int> CumulPresent { get; set; }
    }

    public AnalyticsResult GetAnalyticsData(int teacherId, int subjectId, int sessionId,
        int instituteId, int societyId, DateTime from, DateTime to)
    {
        var result = new AnalyticsResult
        {
            SubjectNames = new List<string>(),
            SubjectAvgPct = new List<double>(),
            SubjectPresent = new List<int>(),
            SubjectAbsent = new List<int>(),
            SubjectLeave = new List<int>(),
            RiskSafe = new List<int>(),
            RiskGood = new List<int>(),
            RiskWarning = new List<int>(),
            RiskDanger = new List<int>(),
            MonthLabels = new List<string>(),
            MonthPresent = new List<int>(),
            MonthAbsent = new List<int>(),
            MonthLeave = new List<int>(),
            DowLabels = new List<string>(),
            DowAvgPct = new List<double>(),
            DistLabels = new List<string>(),
            DistCounts = new List<int>(),
            AbsenteeNames = new List<string>(),
            AbsenteeCounts = new List<int>(),
            TopStudentNames = new List<string>(),
            TopStudentPct = new List<double>(),
            CumulDates = new List<string>(),
            CumulPresent = new List<int>()
        };

        try
        {
            // ── 1. Per-student summary ──
            SqlCommand studentCmd = new SqlCommand(@"
            SELECT
                up.FullName,
                COUNT(a.AttendanceId)                                              AS Total,
                SUM(CASE WHEN a.Status='Present' THEN 1 ELSE 0 END)               AS Pres,
                SUM(CASE WHEN a.Status='Absent'  THEN 1 ELSE 0 END)               AS Abs,
                SUM(CASE WHEN a.Status='Leave'   THEN 1 ELSE 0 END)               AS Lve,
                CASE WHEN COUNT(a.AttendanceId)=0 THEN 0
                     ELSE CAST(ROUND(100.0*SUM(CASE WHEN a.Status='Present' THEN 1 ELSE 0 END)
                          /COUNT(a.AttendanceId),2) AS DECIMAL(5,2)) END           AS Pct
            FROM AssignStudentSubject ass
            INNER JOIN Users       u  ON u.UserId   = ass.UserId
            INNER JOIN UserProfile up ON up.UserId  = u.UserId
            LEFT  JOIN Attendance  a  ON a.UserId   = u.UserId
                                     AND a.SubjectId = ass.SubjectId
                                     AND a.InstituteId = @InstituteId
                                     AND a.SocietyId   = @SocietyId
                                     AND a.Date BETWEEN @From AND @To
            INNER JOIN SubjectFaculty sf ON sf.SubjectId  = ass.SubjectId
                                        AND sf.TeacherId  = @TeacherId
                                        AND sf.InstituteId= @InstituteId
                                        AND sf.SocietyId  = @SocietyId
                                        AND sf.IsActive   = 1
            WHERE ass.InstituteId = @InstituteId
              AND ass.SocietyId   = @SocietyId
              AND (@SubjectId = 0 OR ass.SubjectId = @SubjectId)
              AND u.IsActive = 1
            GROUP BY up.FullName");

            studentCmd.Parameters.AddWithValue("@TeacherId", teacherId);
            studentCmd.Parameters.AddWithValue("@SubjectId", subjectId);
            studentCmd.Parameters.AddWithValue("@InstituteId", instituteId);
            studentCmd.Parameters.AddWithValue("@SocietyId", societyId);
            studentCmd.Parameters.AddWithValue("@From", from.Date);
            studentCmd.Parameters.AddWithValue("@To", to.Date);

            DataTable dtStudent = _dl.GetDataTable(studentCmd);

            // ── 2. Subject-wise aggregates ──
            SqlCommand subjectCmd = new SqlCommand(@"
            SELECT
                s.SubjectName,
                COUNT(a.AttendanceId)                                              AS Total,
                SUM(CASE WHEN a.Status='Present' THEN 1 ELSE 0 END)               AS Pres,
                SUM(CASE WHEN a.Status='Absent'  THEN 1 ELSE 0 END)               AS Abs,
                SUM(CASE WHEN a.Status='Leave'   THEN 1 ELSE 0 END)               AS Lve,
                CASE WHEN COUNT(a.AttendanceId)=0 THEN 0
                     ELSE CAST(ROUND(100.0*SUM(CASE WHEN a.Status='Present' THEN 1 ELSE 0 END)
                          /COUNT(a.AttendanceId),2) AS DECIMAL(5,2)) END           AS AvgPct
            FROM SubjectFaculty sf
            INNER JOIN Subjects s ON s.SubjectId = sf.SubjectId
            LEFT  JOIN Attendance a ON a.SubjectId   = sf.SubjectId
                                   AND a.InstituteId = @InstituteId
                                   AND a.SocietyId   = @SocietyId
                                   AND a.Date BETWEEN @From AND @To
            WHERE sf.TeacherId   = @TeacherId
              AND sf.InstituteId = @InstituteId
              AND sf.SocietyId   = @SocietyId
              AND sf.IsActive    = 1
              AND (@SubjectId=0 OR sf.SubjectId=@SubjectId)
            GROUP BY s.SubjectName, sf.SubjectId");

            subjectCmd.Parameters.AddWithValue("@TeacherId", teacherId);
            subjectCmd.Parameters.AddWithValue("@SubjectId", subjectId);
            subjectCmd.Parameters.AddWithValue("@InstituteId", instituteId);
            subjectCmd.Parameters.AddWithValue("@SocietyId", societyId);
            subjectCmd.Parameters.AddWithValue("@From", from.Date);
            subjectCmd.Parameters.AddWithValue("@To", to.Date);

            DataTable dtSubject = _dl.GetDataTable(subjectCmd);

            // ── 3. Monthly trend ──
            SqlCommand monthCmd = new SqlCommand(@"
            SELECT
                FORMAT(a.Date,'MMM yyyy')                                          AS MonthLabel,
                MIN(a.Date)                                                        AS SortDate,
                SUM(CASE WHEN a.Status='Present' THEN 1 ELSE 0 END)               AS Pres,
                SUM(CASE WHEN a.Status='Absent'  THEN 1 ELSE 0 END)               AS Abs,
                SUM(CASE WHEN a.Status='Leave'   THEN 1 ELSE 0 END)               AS Lve
            FROM Attendance a
            INNER JOIN SubjectFaculty sf ON sf.SubjectId   = a.SubjectId
                                        AND sf.TeacherId   = @TeacherId
                                        AND sf.InstituteId = @InstituteId
                                        AND sf.SocietyId   = @SocietyId
                                        AND sf.IsActive    = 1
            WHERE a.InstituteId = @InstituteId
              AND a.SocietyId   = @SocietyId
              AND a.Date BETWEEN @From AND @To
              AND (@SubjectId=0 OR a.SubjectId=@SubjectId)
            GROUP BY FORMAT(a.Date,'MMM yyyy')
            ORDER BY MIN(a.Date)");

            monthCmd.Parameters.AddWithValue("@TeacherId", teacherId);
            monthCmd.Parameters.AddWithValue("@SubjectId", subjectId);
            monthCmd.Parameters.AddWithValue("@InstituteId", instituteId);
            monthCmd.Parameters.AddWithValue("@SocietyId", societyId);
            monthCmd.Parameters.AddWithValue("@From", from.Date);
            monthCmd.Parameters.AddWithValue("@To", to.Date);

            DataTable dtMonth = _dl.GetDataTable(monthCmd);

            // ── 4. Day-of-week ──
            SqlCommand dowCmd = new SqlCommand(@"
            SELECT
                DATENAME(WEEKDAY, a.Date)                                          AS DayName,
                DATEPART(WEEKDAY, a.Date)                                          AS DayNum,
                CAST(ROUND(100.0*SUM(CASE WHEN a.Status='Present' THEN 1 ELSE 0 END)
                     /NULLIF(COUNT(a.AttendanceId),0),1) AS DECIMAL(5,1))          AS AvgPct
            FROM Attendance a
            INNER JOIN SubjectFaculty sf ON sf.SubjectId   = a.SubjectId
                                        AND sf.TeacherId   = @TeacherId
                                        AND sf.InstituteId = @InstituteId
                                        AND sf.SocietyId   = @SocietyId
                                        AND sf.IsActive    = 1
            WHERE a.InstituteId = @InstituteId
              AND a.SocietyId   = @SocietyId
              AND a.Date BETWEEN @From AND @To
              AND (@SubjectId=0 OR a.SubjectId=@SubjectId)
            GROUP BY DATENAME(WEEKDAY,a.Date), DATEPART(WEEKDAY,a.Date)
            ORDER BY DATEPART(WEEKDAY,a.Date)");

            dowCmd.Parameters.AddWithValue("@TeacherId", teacherId);
            dowCmd.Parameters.AddWithValue("@SubjectId", subjectId);
            dowCmd.Parameters.AddWithValue("@InstituteId", instituteId);
            dowCmd.Parameters.AddWithValue("@SocietyId", societyId);
            dowCmd.Parameters.AddWithValue("@From", from.Date);
            dowCmd.Parameters.AddWithValue("@To", to.Date);

            DataTable dtDow = _dl.GetDataTable(dowCmd);

            // ── 5. Cumulative ──
            SqlCommand cumulCmd = new SqlCommand(@"
            SELECT
                CONVERT(VARCHAR(10), a.Date, 23)                                   AS DateStr,
                SUM(SUM(CASE WHEN a.Status='Present' THEN 1 ELSE 0 END))
                    OVER (ORDER BY a.Date ROWS UNBOUNDED PRECEDING)                AS CumulPres
            FROM Attendance a
            INNER JOIN SubjectFaculty sf ON sf.SubjectId   = a.SubjectId
                                        AND sf.TeacherId   = @TeacherId
                                        AND sf.InstituteId = @InstituteId
                                        AND sf.SocietyId   = @SocietyId
                                        AND sf.IsActive    = 1
            WHERE a.InstituteId = @InstituteId
              AND a.SocietyId   = @SocietyId
              AND a.Date BETWEEN @From AND @To
              AND (@SubjectId=0 OR a.SubjectId=@SubjectId)
            GROUP BY a.Date
            ORDER BY a.Date");

            cumulCmd.Parameters.AddWithValue("@TeacherId", teacherId);
            cumulCmd.Parameters.AddWithValue("@SubjectId", subjectId);
            cumulCmd.Parameters.AddWithValue("@InstituteId", instituteId);
            cumulCmd.Parameters.AddWithValue("@SocietyId", societyId);
            cumulCmd.Parameters.AddWithValue("@From", from.Date);
            cumulCmd.Parameters.AddWithValue("@To", to.Date);

            DataTable dtCumul = _dl.GetDataTable(cumulCmd);

            // Process Risk data
            DataTable dtRisk = GetRiskData(teacherId, subjectId, instituteId, societyId, from, to);

            // ── Assemble result ──
            if (dtStudent != null && dtStudent.Rows.Count > 0)
            {
                int totalPres = 0, totalAbs = 0, totalLve = 0, lowCount = 0;
                double sumPct = 0;
                var buckets = new int[10];

                var rows = dtStudent.AsEnumerable().ToList();

                foreach (DataRow r in rows)
                {
                    totalPres += Convert.ToInt32(r["Pres"]);
                    totalAbs += Convert.ToInt32(r["Abs"]);
                    totalLve += Convert.ToInt32(r["Lve"]);
                    double pct = Convert.ToDouble(r["Pct"]);
                    sumPct += pct;
                    if (pct < 75) lowCount++;
                    int bucket = Math.Min((int)(pct / 10), 9);
                    buckets[bucket]++;
                }

                result.TotalPresent = totalPres;
                result.TotalAbsent = totalAbs;
                result.TotalLeave = totalLve;
                result.LowAttendanceCount = lowCount;
                result.AvgAttendancePct = rows.Count > 0 ? Math.Round(sumPct / rows.Count, 1) : 0;

                string[] bandLabels = { "0-9%", "10-19%", "20-29%", "30-39%", "40-49%", "50-59%", "60-69%", "70-79%", "80-89%", "90-100%" };
                for (int i = 0; i < 10; i++) { result.DistLabels.Add(bandLabels[i]); result.DistCounts.Add(buckets[i]); }

                foreach (var r in rows.OrderByDescending(x => Convert.ToInt32(x["Abs"])).Take(10))
                {
                    result.AbsenteeNames.Add(r["FullName"].ToString());
                    result.AbsenteeCounts.Add(Convert.ToInt32(r["Abs"]));
                }

                foreach (var r in rows.OrderByDescending(x => Convert.ToDouble(x["Pct"])).Take(10))
                {
                    result.TopStudentNames.Add(r["FullName"].ToString());
                    result.TopStudentPct.Add(Convert.ToDouble(r["Pct"]));
                }
            }

            if (dtSubject != null && dtSubject.Rows.Count > 0)
            {
                int totalDays = 0;
                foreach (DataRow r in dtSubject.Rows)
                {
                    result.SubjectNames.Add(r["SubjectName"].ToString());
                    result.SubjectAvgPct.Add(Convert.ToDouble(r["AvgPct"]));
                    result.SubjectPresent.Add(Convert.ToInt32(r["Pres"]));
                    result.SubjectAbsent.Add(Convert.ToInt32(r["Abs"]));
                    result.SubjectLeave.Add(Convert.ToInt32(r["Lve"]));
                    totalDays += Convert.ToInt32(r["Total"]);
                }
                result.TotalClassDays = totalDays;
            }

            if (dtRisk != null && dtRisk.Rows.Count > 0)
            {
                foreach (DataRow r in dtRisk.Rows)
                {
                    result.RiskSafe.Add(Convert.ToInt32(r["RiskSafe"]));
                    result.RiskGood.Add(Convert.ToInt32(r["RiskGood"]));
                    result.RiskWarning.Add(Convert.ToInt32(r["RiskWarning"]));
                    result.RiskDanger.Add(Convert.ToInt32(r["RiskDanger"]));
                }
            }
            else if (result.SubjectNames.Count > 0)
            {
                for (int i = 0; i < result.SubjectNames.Count; i++)
                {
                    result.RiskSafe.Add(0);
                    result.RiskGood.Add(0);
                    result.RiskWarning.Add(0);
                    result.RiskDanger.Add(0);
                }
            }

            if (dtMonth != null)
                foreach (DataRow r in dtMonth.Rows)
                {
                    result.MonthLabels.Add(r["MonthLabel"].ToString());
                    result.MonthPresent.Add(Convert.ToInt32(r["Pres"]));
                    result.MonthAbsent.Add(Convert.ToInt32(r["Abs"]));
                    result.MonthLeave.Add(Convert.ToInt32(r["Lve"]));
                }

            if (dtDow != null)
                foreach (DataRow r in dtDow.Rows)
                {
                    string dayName = r["DayName"].ToString();
                    result.DowLabels.Add(dayName.Length > 3 ? dayName.Substring(0, 3) : dayName);
                    result.DowAvgPct.Add(Convert.ToDouble(r["AvgPct"]));
                }

            if (dtCumul != null)
                foreach (DataRow r in dtCumul.Rows)
                {
                    result.CumulDates.Add(Convert.ToDateTime(r["DateStr"]).ToString("dd MMM"));
                    result.CumulPresent.Add(Convert.ToInt32(r["CumulPres"]));
                }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Error in GetAnalyticsData: " + ex.Message);
        }

        return result;
    }

    private DataTable GetRiskData(int teacherId, int subjectId, int instituteId, int societyId, DateTime from, DateTime to)
    {
        SqlCommand riskCmd = new SqlCommand(@"
        SELECT
            sf.SubjectId,
            SUM(CASE WHEN ISNULL(att.Pct, 0) >= 90 THEN 1 ELSE 0 END) AS RiskSafe,
            SUM(CASE WHEN ISNULL(att.Pct, 0) BETWEEN 75 AND 89.99 THEN 1 ELSE 0 END) AS RiskGood,
            SUM(CASE WHEN ISNULL(att.Pct, 0) BETWEEN 50 AND 74.99 THEN 1 ELSE 0 END) AS RiskWarning,
            SUM(CASE WHEN ISNULL(att.Pct, 0) < 50 THEN 1 ELSE 0 END) AS RiskDanger
        FROM SubjectFaculty sf
        INNER JOIN AssignStudentSubject ass ON ass.SubjectId = sf.SubjectId
        LEFT JOIN (
            SELECT 
                a.SubjectId,
                a.UserId,
                CASE WHEN COUNT(a.AttendanceId) = 0 THEN 0
                     ELSE ROUND(100.0 * SUM(CASE WHEN a.Status = 'Present' THEN 1 ELSE 0 END) / COUNT(a.AttendanceId), 2)
                END AS Pct
            FROM Attendance a
            WHERE a.InstituteId = @InstituteId
                AND a.SocietyId = @SocietyId
                AND a.Date BETWEEN @From AND @To
            GROUP BY a.SubjectId, a.UserId
        ) att ON att.SubjectId = sf.SubjectId AND att.UserId = ass.UserId
        WHERE sf.TeacherId = @TeacherId
            AND sf.InstituteId = @InstituteId
            AND sf.SocietyId = @SocietyId
            AND sf.IsActive = 1
            AND (@SubjectId = 0 OR sf.SubjectId = @SubjectId)
        GROUP BY sf.SubjectId");

        riskCmd.Parameters.AddWithValue("@TeacherId", teacherId);
        riskCmd.Parameters.AddWithValue("@SubjectId", subjectId);
        riskCmd.Parameters.AddWithValue("@InstituteId", instituteId);
        riskCmd.Parameters.AddWithValue("@SocietyId", societyId);
        riskCmd.Parameters.AddWithValue("@From", from.Date);
        riskCmd.Parameters.AddWithValue("@To", to.Date);

        return _dl.GetDataTable(riskCmd);
    }

    // ─────────────────────────────────────────────
    // Get daily attendance for the month (SINGLE COPY)
    // ─────────────────────────────────────────────
    public DataTable GetDailyAttendanceForMonth(int teacherId, int instituteId, int societyId, int year, int month)
    {
        SqlCommand cmd = new SqlCommand(@"
        SELECT 
            a.Date,
            COUNT(DISTINCT a.UserId) AS TotalStudents,
            SUM(CASE WHEN a.Status = 'Present' THEN 1 ELSE 0 END) AS PresentCount,
            SUM(CASE WHEN a.Status = 'Absent' THEN 1 ELSE 0 END) AS AbsentCount,
            SUM(CASE WHEN a.Status = 'Leave' THEN 1 ELSE 0 END) AS LeaveCount
        FROM Attendance a
        INNER JOIN SubjectFaculty sf ON sf.SubjectId = a.SubjectId
            AND sf.TeacherId = @TeacherId
            AND sf.InstituteId = @InstituteId
            AND sf.SocietyId = @SocietyId
            AND sf.IsActive = 1
        WHERE a.InstituteId = @InstituteId
            AND a.SocietyId = @SocietyId
            AND YEAR(a.Date) = @Year
            AND MONTH(a.Date) = @Month
        GROUP BY a.Date
        ORDER BY a.Date");

        cmd.Parameters.AddWithValue("@TeacherId", teacherId);
        cmd.Parameters.AddWithValue("@InstituteId", instituteId);
        cmd.Parameters.AddWithValue("@SocietyId", societyId);
        cmd.Parameters.AddWithValue("@Year", year);
        cmd.Parameters.AddWithValue("@Month", month);

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
    public string Status { get; set; }
}