using System;
using System.Data;
using System.Data.SqlClient;

namespace LMS.BL
{
    /// <summary>
    /// SuperAdmin Dashboard BL — platform-wide analytics.
    /// No InstituteId/SessionId scope — aggregates across ALL societies and institutes.
    /// Uses only: Societies, Institutes, Users, Roles, AcademicSessions,
    ///            StudentAcademicDetails, TeacherDetails, Videos, Assignments,
    ///            Attendance, UserActivityLog, VideoViews, AssignmentSubmissions.
    /// </summary>
    public class SuperAdminDashboardBL
    {
        private readonly DataLayer _dl = new DataLayer();

        // ══════════════════════════════════════════════════════════════════════
        //  PLATFORM-WIDE KPI SUMMARY
        // ══════════════════════════════════════════════════════════════════════
        public DataTable GetPlatformKPIs()
        {
            var cmd = new SqlCommand(@"
                SELECT
                    -- Societies
                    (SELECT COUNT(1)  FROM Societies)                           AS TotalSocieties,
                    (SELECT COUNT(1)  FROM Societies WHERE IsActive=1)          AS ActiveSocieties,

                    -- Institutes
                    (SELECT COUNT(1)  FROM Institutes)                          AS TotalInstitutes,
                    (SELECT COUNT(1)  FROM Institutes WHERE IsActive=1)         AS ActiveInstitutes,

                    -- Institutes added this month
                    (SELECT COUNT(1)  FROM Institutes
                     WHERE MONTH(GETDATE())=MONTH(GETDATE())
                       AND YEAR(GETDATE())=YEAR(GETDATE()))                     AS InstThisMonth,

                    -- Total Users (all roles, all institutes)
                    (SELECT COUNT(1)  FROM Users WHERE IsActive=1)              AS TotalUsers,

                    -- By role
                    (SELECT COUNT(1)  FROM Users U
                     INNER JOIN Roles R ON R.RoleId=U.RoleId AND R.RoleName='Student'
                     WHERE U.IsActive=1)                                        AS TotalStudents,

                    (SELECT COUNT(1)  FROM Users U
                     INNER JOIN Roles R ON R.RoleId=U.RoleId AND R.RoleName='Teacher'
                     WHERE U.IsActive=1)                                        AS TotalTeachers,

                    (SELECT COUNT(1)  FROM Users U
                     INNER JOIN Roles R ON R.RoleId=U.RoleId AND R.RoleName='Parent'
                     WHERE U.IsActive=1)                                        AS TotalParents,

                    (SELECT COUNT(1)  FROM Users U
                     INNER JOIN Roles R ON R.RoleId=U.RoleId AND R.RoleName='Admin'
                     WHERE U.IsActive=1)                                        AS TotalAdmins,

                    -- New students this month
                    (SELECT COUNT(1)  FROM Users U
                     INNER JOIN Roles R ON R.RoleId=U.RoleId AND R.RoleName='Student'
                     WHERE MONTH(U.CreatedOn)=MONTH(GETDATE())
                       AND YEAR(U.CreatedOn)=YEAR(GETDATE()))                   AS NewStudentsThisMonth,

                    -- Total sessions across all institutes
                    (SELECT COUNT(1)  FROM AcademicSessions)                   AS TotalSessions,
                    (SELECT COUNT(1)  FROM AcademicSessions WHERE IsCurrent=1) AS ActiveSessions,

                    -- Videos
                    (SELECT COUNT(1)  FROM Videos WHERE IsActive=1)            AS TotalVideos,

                    -- Assignments
                    (SELECT COUNT(1)  FROM Assignments WHERE IsActive=1)       AS TotalAssignments,

                    -- Video views (total)
                    (SELECT ISNULL(SUM(ViewCount),0) FROM Videos WHERE IsActive=1)
                                                                                AS TotalVideoViews,

                    -- Attendance records
                    (SELECT COUNT(1)  FROM Attendance)                         AS TotalAttendanceRecords,

                    -- Activity log entries today
                    (SELECT COUNT(1)  FROM UserActivityLog
                     WHERE CAST(ActionTime AS DATE) = CAST(GETDATE() AS DATE))  AS TodayActivities");

            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        // ══════════════════════════════════════════════════════════════════════
        //  SOCIETIES WITH INSTITUTE COUNT + STUDENT COUNT
        // ══════════════════════════════════════════════════════════════════════
        public DataTable GetSocietiesOverview()
        {
            var cmd = new SqlCommand(@"
                SELECT
                    S.SocietyId,
                    S.SocietyName,
                    S.SocietyCode,
                    S.IsActive,
                    S.CreatedOn,
                    COUNT(DISTINCT I.InstituteId)   AS InstituteCount,
                    COUNT(DISTINCT U.UserId)         AS UserCount,
                    COUNT(DISTINCT CASE WHEN R.RoleName='Student' THEN U.UserId END) AS StudentCount,
                    COUNT(DISTINCT CASE WHEN R.RoleName='Teacher' THEN U.UserId END) AS TeacherCount,
                    COUNT(DISTINCT ASess.SessionId) AS SessionCount
                FROM Societies S
                LEFT JOIN Institutes I ON I.SocietyId = S.SocietyId AND I.IsActive=1
                LEFT JOIN Users U ON U.SocietyId = S.SocietyId AND U.IsActive=1
                LEFT JOIN Roles R ON R.RoleId = U.RoleId
                LEFT JOIN AcademicSessions ASess ON ASess.SocietyId = S.SocietyId
                GROUP BY S.SocietyId, S.SocietyName, S.SocietyCode, S.IsActive, S.CreatedOn
                ORDER BY InstituteCount DESC, S.SocietyName");
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        // ══════════════════════════════════════════════════════════════════════
        //  TOP INSTITUTES BY STUDENT COUNT
        // ══════════════════════════════════════════════════════════════════════
        public DataTable GetTopInstitutes(int top = 10)
        {
            var cmd = new SqlCommand(@"
                SELECT TOP (@Top)
                    I.InstituteId,
                    I.InstituteName,
                    I.InstituteCode,
                    I.IsActive,
                    S.SocietyName,
                    COUNT(DISTINCT CASE WHEN R.RoleName='Student' THEN U.UserId END) AS StudentCount,
                    COUNT(DISTINCT CASE WHEN R.RoleName='Teacher' THEN U.UserId END) AS TeacherCount,
                    COUNT(DISTINCT CASE WHEN R.RoleName='Admin'   THEN U.UserId END) AS AdminCount,
                    COUNT(DISTINCT ASess.SessionId)                                  AS SessionCount,
                    COUNT(DISTINCT V.VideoId)                                        AS VideoCount
                FROM Institutes I
                INNER JOIN Societies S ON S.SocietyId = I.SocietyId
                LEFT JOIN Users U ON U.InstituteId = I.InstituteId AND U.IsActive=1
                LEFT JOIN Roles R ON R.RoleId = U.RoleId
                LEFT JOIN AcademicSessions ASess ON ASess.InstituteId = I.InstituteId
                LEFT JOIN Videos V ON V.InstituteId = I.InstituteId AND V.IsActive=1
                GROUP BY I.InstituteId, I.InstituteName, I.InstituteCode, I.IsActive, S.SocietyName
                ORDER BY StudentCount DESC, TeacherCount DESC");
            cmd.Parameters.AddWithValue("@Top", top);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        // ══════════════════════════════════════════════════════════════════════
        //  USER GROWTH — monthly new users (last 12 months)
        // ══════════════════════════════════════════════════════════════════════
        public DataTable GetUserGrowthTrend()
        {
            var cmd = new SqlCommand(@"
                SELECT
                    YEAR(U.CreatedOn)   AS Yr,
                    MONTH(U.CreatedOn)  AS Mo,
                    DATENAME(MONTH, U.CreatedOn) + ' '
                        + CAST(YEAR(U.CreatedOn) AS VARCHAR) AS MonthLabel,
                    COUNT(1)            AS TotalNew,
                    COUNT(CASE WHEN R.RoleName='Student' THEN 1 END) AS NewStudents,
                    COUNT(CASE WHEN R.RoleName='Teacher' THEN 1 END) AS NewTeachers
                FROM Users U
                INNER JOIN Roles R ON R.RoleId = U.RoleId
                WHERE U.CreatedOn >= DATEADD(MONTH, -11, DATEFROMPARTS(YEAR(GETDATE()),MONTH(GETDATE()),1))
                  AND R.RoleName IN ('Student','Teacher','Admin','Parent')
                GROUP BY YEAR(U.CreatedOn), MONTH(U.CreatedOn), DATENAME(MONTH, U.CreatedOn)
                ORDER BY Yr, Mo");
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        // ══════════════════════════════════════════════════════════════════════
        //  INSTITUTE GROWTH — monthly new institutes (last 12 months)
        // ══════════════════════════════════════════════════════════════════════
        public DataTable GetInstituteGrowthTrend()
        {
            var cmd = new SqlCommand(@"
                SELECT
                    YEAR(I.ROWGUID_)   AS Yr,
                    MONTH(I.ROWGUID_)  AS Mo,
                    DATENAME(MONTH, CreatedMonth) + ' '
                        + CAST(YEAR(CreatedMonth) AS VARCHAR) AS MonthLabel,
                    COUNT(1)            AS NewInstitutes
                FROM (
                    SELECT
                        InstituteId,
                        DATEFROMPARTS(
                            YEAR((SELECT MIN(CreatedOn) FROM AcademicSessions WHERE InstituteId = I2.InstituteId)),
                            MONTH((SELECT MIN(CreatedOn) FROM AcademicSessions WHERE InstituteId = I2.InstituteId)),
                            1
                        ) AS CreatedMonth
                    FROM Institutes I2
                    WHERE (SELECT COUNT(1) FROM AcademicSessions WHERE InstituteId=I2.InstituteId) > 0
                ) I
                WHERE I.CreatedMonth >= DATEADD(MONTH,-11, DATEFROMPARTS(YEAR(GETDATE()),MONTH(GETDATE()),1))
                GROUP BY YEAR(I.CreatedMonth), MONTH(I.CreatedMonth),
                         DATENAME(MONTH, I.CreatedMonth)
                ORDER BY Yr, Mo");
            // Simpler fallback using InstituteId as proxy for creation order
            var cmd2 = new SqlCommand(@"
                SELECT TOP 12
                    YEAR(ASess.CreatedOn)    AS Yr,
                    MONTH(ASess.CreatedOn)   AS Mo,
                    DATENAME(MONTH,ASess.CreatedOn)
                        + ' ' + CAST(YEAR(ASess.CreatedOn) AS VARCHAR) AS MonthLabel,
                    COUNT(DISTINCT ASess.InstituteId) AS NewInstitutes
                FROM AcademicSessions ASess
                GROUP BY YEAR(ASess.CreatedOn), MONTH(ASess.CreatedOn), DATENAME(MONTH,ASess.CreatedOn)
                ORDER BY Yr DESC, Mo DESC");
            return _dl.GetDataTable(cmd2) ?? new DataTable();
        }

        // ══════════════════════════════════════════════════════════════════════
        //  USERS BY ROLE — donut chart data
        // ══════════════════════════════════════════════════════════════════════
        public DataTable GetUsersByRole()
        {
            var cmd = new SqlCommand(@"
                SELECT
                    R.RoleName,
                    COUNT(U.UserId) AS UserCount
                FROM Roles R
                LEFT JOIN Users U ON U.RoleId = R.RoleId AND U.IsActive=1
                WHERE R.RoleName IN ('Student','Teacher','Admin','Parent')
                GROUP BY R.RoleName
                ORDER BY UserCount DESC");
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        // ══════════════════════════════════════════════════════════════════════
        //  INSTITUTES BY SOCIETY — bar chart data
        // ══════════════════════════════════════════════════════════════════════
        public DataTable GetInstitutesBySociety()
        {
            var cmd = new SqlCommand(@"
                SELECT
                    S.SocietyName,
                    COUNT(I.InstituteId) AS Total,
                    COUNT(CASE WHEN I.IsActive=1 THEN 1 END) AS Active,
                    COUNT(CASE WHEN I.IsActive=0 THEN 1 END) AS Inactive
                FROM Societies S
                LEFT JOIN Institutes I ON I.SocietyId = S.SocietyId
                GROUP BY S.SocietyId, S.SocietyName
                ORDER BY Total DESC");
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        // ══════════════════════════════════════════════════════════════════════
        //  ACTIVITY LOG — recent 20 platform-wide events
        // ══════════════════════════════════════════════════════════════════════
        public DataTable GetRecentActivity()
        {
            var cmd = new SqlCommand(@"
                SELECT TOP 20
                    UAL.LogId,
                    UAL.ActivityType,
                    UAL.ActionTime,
                    ISNULL(UP.FullName, U.Username) AS UserName,
                    R.RoleName,
                    ISNULL(I.InstituteName,'—')     AS InstituteName,
                    ISNULL(S.SocietyName, '—')      AS SocietyName
                FROM UserActivityLog UAL
                INNER JOIN Users U ON U.UserId = UAL.UserId
                INNER JOIN Roles R ON R.RoleId = U.RoleId
                LEFT JOIN UserProfile UP ON UP.UserId = U.UserId
                LEFT JOIN Institutes I ON I.InstituteId = UAL.InstituteId
                LEFT JOIN Societies  S ON S.SocietyId  = UAL.SocietyId
                ORDER BY UAL.ActionTime DESC");
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        // ══════════════════════════════════════════════════════════════════════
        //  SYSTEM HEALTH — storage/content metrics
        // ══════════════════════════════════════════════════════════════════════
        public DataTable GetSystemHealth()
        {
            var cmd = new SqlCommand(@"
                SELECT
                    (SELECT COUNT(1) FROM Videos   WHERE IsActive=1)        AS Videos,
                    (SELECT ISNULL(SUM(ViewCount),0) FROM Videos)           AS TotalViews,
                    (SELECT COUNT(1) FROM Assignments WHERE IsActive=1)     AS Assignments,
                    (SELECT COUNT(1) FROM AssignmentSubmissions)            AS Submissions,
                    (SELECT COUNT(1) FROM Attendance)                       AS AttendanceRecords,
                    (SELECT COUNT(1) FROM Chapters   WHERE IsActive=1)      AS Chapters,
                    (SELECT COUNT(1) FROM Subjects   WHERE IsActive=1)      AS Subjects,
                    (SELECT COUNT(1) FROM AcademicSessions WHERE IsCurrent=1) AS CurrentSessions,
                    -- Logins today
                    (SELECT COUNT(1) FROM Users WHERE CAST(LastLogin AS DATE)=CAST(GETDATE() AS DATE))
                                                                            AS LoginsToday,
                    -- Active users last 7 days
                    (SELECT COUNT(DISTINCT UserId) FROM UserActivityLog
                     WHERE ActionTime >= DATEADD(DAY,-7,GETDATE()))         AS ActiveUsersWeek");
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }
    }
}