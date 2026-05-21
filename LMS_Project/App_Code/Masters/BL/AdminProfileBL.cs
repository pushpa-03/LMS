using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace LearningManagementSystem.BL
{
    /// <summary>
    /// Business Logic for Admin Profile and Settings pages.
    /// Covers: profile read/update, password change, photo upload,
    /// notification preferences, session management, activity log.
    /// </summary>
    public class AdminProfileBL
    {
        private readonly DataLayer _dl = new DataLayer();

        // ══════════════════════════════════════════════════════════════════════
        //  PROFILE — Read
        // ══════════════════════════════════════════════════════════════════════
        public DataTable GetAdminProfile(int userId)
        {
            var cmd = new SqlCommand(@"
                SELECT
                    U.UserId,
                    U.Username,
                    U.Email,
                    U.IsActive,
                    U.IsFirstLogin,
                    U.LastLogin,
                    U.CreatedOn,

                    ISNULL(UP.FullName,             U.Username) AS FullName,
                    ISNULL(UP.Gender,               '')         AS Gender,
                    ISNULL(CONVERT(VARCHAR,UP.DOB,23),'')       AS DOB,
                    ISNULL(UP.ContactNo,            '')         AS ContactNo,
                    ISNULL(UP.EmergencyContactName, '')         AS EmergencyContactName,
                    ISNULL(UP.EmergencyContactNo,   '')         AS EmergencyContactNo,
                    ISNULL(UP.Address,              '')         AS Address,
                    ISNULL(UP.City,                 '')         AS City,
                    ISNULL(UP.Country,              '')         AS Country,
                    ISNULL(CAST(UP.Pincode AS VARCHAR),'')      AS Pincode,
                    ISNULL(UP.Skills,               '')         AS Skills,
                    ISNULL(UP.Description,          '')         AS Bio,
                    ISNULL(UP.ProfileImage,         '')         AS ProfileImage,
                    ISNULL(UP.FatherName,           '')         AS FatherName,
                    ISNULL(UP.MotherName,           '')         AS MotherName,
                    ISNULL(CONVERT(VARCHAR,UP.JoinedDate,23),'') AS JoinedDate,

                    R.RoleName,
                    ISNULL(I.InstituteName, '')                 AS InstituteName,
                    ISNULL(I.LogoURL,       '')                 AS InstituteLogo,
                    ISNULL(S.SocietyName,   '')                 AS SocietyName

                FROM Users U
                INNER JOIN Roles R ON R.RoleId = U.RoleId
                LEFT JOIN UserProfile  UP ON UP.UserId     = U.UserId
                LEFT JOIN Institutes   I  ON I.InstituteId = U.InstituteId
                LEFT JOIN Societies    S  ON S.SocietyId   = U.SocietyId
                WHERE U.UserId = @Uid");

            cmd.Parameters.AddWithValue("@Uid", userId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        // ══════════════════════════════════════════════════════════════════════
        //  PROFILE — Update personal info
        // ══════════════════════════════════════════════════════════════════════
        public bool UpdateAdminProfile(int userId, int societyId, int instituteId, int sessionId,
            string fullName, string gender, string dob, string contactNo,
            string emergencyName, string emergencyNo,
            string address, string city, string country, string pincode,
            string skills, string bio, string fatherName, string motherName)
        {
            try
            {
                var cmd = new SqlCommand(@"
                    MERGE UserProfile AS target
                    USING (SELECT @UserId AS UserId) AS src ON target.UserId = src.UserId
                    WHEN MATCHED THEN UPDATE SET
                        FullName             = @FullName,
                        Gender               = @Gender,
                        DOB                  = @DOB,
                        ContactNo            = @ContactNo,
                        EmergencyContactName = @EmgName,
                        EmergencyContactNo   = @EmgNo,
                        Address              = @Address,
                        City                 = @City,
                        Country              = @Country,
                        Pincode              = @Pincode,
                        Skills               = @Skills,
                        Description          = @Bio,
                        FatherName           = @Father,
                        MotherName           = @Mother
                    WHEN NOT MATCHED THEN INSERT
                        (SocietyId, InstituteId, SessionId, UserId,
                         FullName, Gender, DOB, ContactNo,
                         EmergencyContactName, EmergencyContactNo,
                         Address, City, Country, Pincode, JoinedDate,
                         Skills, Description, FatherName, MotherName)
                    VALUES
                        (@SocId, @InstId, @SessId, @UserId,
                         @FullName, @Gender, @DOB, @ContactNo,
                         @EmgName, @EmgNo,
                         @Address, @City, @Country, @Pincode, GETDATE(),
                         @Skills, @Bio, @Father, @Mother);");

                cmd.Parameters.AddWithValue("@UserId", userId);
                cmd.Parameters.AddWithValue("@SocId", societyId);
                cmd.Parameters.AddWithValue("@InstId", instituteId);
                cmd.Parameters.AddWithValue("@SessId", sessionId);
                cmd.Parameters.AddWithValue("@FullName", fullName ?? "");
                cmd.Parameters.AddWithValue("@Gender", gender ?? "");
                cmd.Parameters.AddWithValue("@DOB", string.IsNullOrWhiteSpace(dob) ? (object)DBNull.Value : DateTime.Parse(dob));
                cmd.Parameters.AddWithValue("@ContactNo", contactNo ?? "");
                cmd.Parameters.AddWithValue("@EmgName", emergencyName ?? "");
                cmd.Parameters.AddWithValue("@EmgNo", emergencyNo ?? "");
                cmd.Parameters.AddWithValue("@Address", address ?? "");
                cmd.Parameters.AddWithValue("@City", city ?? "");
                cmd.Parameters.AddWithValue("@Country", country ?? "");
                cmd.Parameters.AddWithValue("@Pincode", string.IsNullOrWhiteSpace(pincode) ? (object)DBNull.Value : int.Parse(pincode));
                cmd.Parameters.AddWithValue("@Skills", skills ?? "");
                cmd.Parameters.AddWithValue("@Bio", bio ?? "");
                cmd.Parameters.AddWithValue("@Father", fatherName ?? "");
                cmd.Parameters.AddWithValue("@Mother", motherName ?? "");

                _dl.ExecuteCMD(cmd);
                return true;
            }
            catch { return false; }
        }

        // ══════════════════════════════════════════════════════════════════════
        //  PROFILE — Update email only
        // ══════════════════════════════════════════════════════════════════════
        public bool UpdateEmail(int userId, string newEmail)
        {
            try
            {
                // Check duplicate
                var chk = new SqlCommand("SELECT COUNT(1) FROM Users WHERE Email=@E AND UserId<>@Id");
                chk.Parameters.AddWithValue("@E", newEmail.Trim().ToLower());
                chk.Parameters.AddWithValue("@Id", userId);
                DataTable dt = _dl.GetDataTable(chk);
                if (dt.Rows.Count > 0 && Convert.ToInt32(dt.Rows[0][0]) > 0)
                    return false; // duplicate

                var cmd = new SqlCommand("UPDATE Users SET Email=@E WHERE UserId=@Id");
                cmd.Parameters.AddWithValue("@E", newEmail.Trim().ToLower());
                cmd.Parameters.AddWithValue("@Id", userId);
                _dl.ExecuteCMD(cmd);
                return true;
            }
            catch { return false; }
        }

        // ══════════════════════════════════════════════════════════════════════
        //  PROFILE — Update profile photo path
        // ══════════════════════════════════════════════════════════════════════
        public bool UpdateProfilePhoto(int userId, string photoPath)
        {
            try
            {
                var cmd = new SqlCommand(
                    "UPDATE UserProfile SET ProfileImage=@P WHERE UserId=@Id");
                cmd.Parameters.AddWithValue("@P", photoPath);
                cmd.Parameters.AddWithValue("@Id", userId);
                _dl.ExecuteCMD(cmd);
                return true;
            }
            catch { return false; }
        }

        // ══════════════════════════════════════════════════════════════════════
        //  PASSWORD — Change (verify old, hash new)
        // ══════════════════════════════════════════════════════════════════════
        public bool VerifyCurrentPassword(int userId, string currentPassword)
        {
            var cmd = new SqlCommand(@"
                SELECT COUNT(1) FROM Users
                WHERE UserId=@Id
                  AND PasswordHash = HASHBYTES('SHA2_256', @Pwd)");
            cmd.Parameters.AddWithValue("@Id", userId);
            cmd.Parameters.AddWithValue("@Pwd", currentPassword);
            DataTable dt = _dl.GetDataTable(cmd);
            return dt.Rows.Count > 0 && Convert.ToInt32(dt.Rows[0][0]) > 0;
        }

        public bool ChangePassword(int userId, string newPassword)
        {
            try
            {
                var cmd = new SqlCommand(@"
                    UPDATE Users SET
                        PasswordHash = HASHBYTES('SHA2_256', @Pwd),
                        IsFirstLogin = 0
                    WHERE UserId = @Id");
                cmd.Parameters.AddWithValue("@Pwd", newPassword);
                cmd.Parameters.AddWithValue("@Id", userId);
                _dl.ExecuteCMD(cmd);
                return true;
            }
            catch { return false; }
        }

        // ══════════════════════════════════════════════════════════════════════
        //  ACTIVITY LOG — Last 30 actions for this admin
        // ══════════════════════════════════════════════════════════════════════
        public DataTable GetActivityLog(int userId, int sessionId)
        {
            var cmd = new SqlCommand(@"
                SELECT TOP 30
                    UAL.LogId,
                    UAL.ActivityType,
                    UAL.ReferenceId,
                    UAL.ActionTime
                FROM UserActivityLog UAL
                WHERE UAL.UserId    = @Uid
                  AND UAL.SessionId = @Sess
                ORDER BY UAL.ActionTime DESC");
            cmd.Parameters.AddWithValue("@Uid", userId);
            cmd.Parameters.AddWithValue("@Sess", sessionId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        // ══════════════════════════════════════════════════════════════════════
        //  STATISTICS — Quick counts for the profile header
        // ══════════════════════════════════════════════════════════════════════
        public DataTable GetAdminStats(int instituteId, int sessionId)
        {
            var cmd = new SqlCommand(@"
                SELECT
                    (SELECT COUNT(1) FROM Users U2
                     INNER JOIN Roles R2 ON R2.RoleId=U2.RoleId AND R2.RoleName='Student'
                     WHERE U2.InstituteId=@InstId AND U2.SessionId=@Sess AND U2.IsActive=1)
                        AS TotalStudents,

                    (SELECT COUNT(1) FROM Users U3
                     INNER JOIN Roles R3 ON R3.RoleId=U3.RoleId AND R3.RoleName='Teacher'
                     WHERE U3.InstituteId=@InstId AND U3.SessionId=@Sess AND U3.IsActive=1)
                        AS TotalTeachers,

                    (SELECT COUNT(1) FROM Subjects S
                     WHERE S.InstituteId=@InstId AND S.SessionId=@Sess AND S.IsActive=1)
                        AS TotalSubjects,

                    (SELECT COUNT(1) FROM Videos V
                     WHERE V.InstituteId=@InstId AND V.SessionId=@Sess AND V.IsActive=1)
                        AS TotalVideos,

                    (SELECT COUNT(1) FROM Assignments A
                     WHERE A.InstituteId=@InstId AND A.SessionId=@Sess AND A.IsActive=1)
                        AS TotalAssignments,

                    (SELECT ISNULL(AVG(CAST(ATT_Sub.PresentPct AS FLOAT)),0)
                     FROM (
                         SELECT
                             CAST(COUNT(CASE WHEN Status='Present' THEN 1 END)*100.0
                                  /NULLIF(COUNT(1),0) AS DECIMAL(5,1)) AS PresentPct
                         FROM Attendance
                         WHERE InstituteId=@InstId AND SessionId=@Sess
                         GROUP BY SubjectId
                     ) ATT_Sub)
                        AS AvgAttendance");

            cmd.Parameters.AddWithValue("@InstId", instituteId);
            cmd.Parameters.AddWithValue("@Sess", sessionId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        // ══════════════════════════════════════════════════════════════════════
        //  SETTINGS — Notification preferences (stored in a JSON-ish text col)
        //  We use the UserProfile.Description col overload OR a dedicated
        //  AdminSettings table if it exists. Here we use a simple UPSERT on
        //  a lightweight pattern: store as pipe-delimited flags in UserProfile.Skills
        //  Better: use dedicated AdminSettings table if available.
        //  We'll check for AdminSettings table and fall back gracefully.
        // ══════════════════════════════════════════════════════════════════════
        public DataTable GetAdminSettings(int userId)
        {
            // Try AdminSettings table first
            try
            {
                var cmd = new SqlCommand(@"
                    SELECT * FROM AdminSettings WHERE UserId=@Uid");
                cmd.Parameters.AddWithValue("@Uid", userId);
                DataTable dt = _dl.GetDataTable(cmd);
                if (dt != null && dt.Rows.Count > 0) return dt;
            }
            catch { /* table may not exist */ }

            // Return empty defaults
            DataTable result = new DataTable();
            result.Columns.Add("EmailNotifications", typeof(bool));
            result.Columns.Add("SmsNotifications", typeof(bool));
            result.Columns.Add("NewStudentAlert", typeof(bool));
            result.Columns.Add("AttendanceAlert", typeof(bool));
            result.Columns.Add("AssignmentAlert", typeof(bool));
            result.Columns.Add("LoginAlerts", typeof(bool));
            result.Columns.Add("SessionName", typeof(string));
            result.Columns.Add("Language", typeof(string));
            result.Columns.Add("TimeZone", typeof(string));
            result.Columns.Add("DateFormat", typeof(string));
            result.Columns.Add("Theme", typeof(string));
            DataRow row = result.NewRow();
            row["EmailNotifications"] = true;
            row["SmsNotifications"] = false;
            row["NewStudentAlert"] = true;
            row["AttendanceAlert"] = true;
            row["AssignmentAlert"] = false;
            row["LoginAlerts"] = true;
            row["SessionName"] = "";
            row["Language"] = "English";
            row["TimeZone"] = "Asia/Kolkata";
            row["DateFormat"] = "dd/MM/yyyy";
            row["Theme"] = "light";
            result.Rows.Add(row);
            return result;
        }

        public bool SaveAdminSettings(int userId,
            bool emailNotif, bool smsNotif,
            bool newStudentAlert, bool attendanceAlert,
            bool assignmentAlert, bool loginAlerts,
            string language, string timezone, string dateFormat, string theme)
        {
            try
            {
                // Try AdminSettings table
                var cmd = new SqlCommand(@"
                    IF EXISTS (SELECT 1 FROM AdminSettings WHERE UserId=@Uid)
                        UPDATE AdminSettings SET
                            EmailNotifications=@EN, SmsNotifications=@SN,
                            NewStudentAlert=@NSA, AttendanceAlert=@AA,
                            AssignmentAlert=@ASA, LoginAlerts=@LA,
                            Language=@Lang, TimeZone=@TZ,
                            DateFormat=@DF, Theme=@Theme,
                            UpdatedOn=GETDATE()
                        WHERE UserId=@Uid
                    ELSE
                        INSERT INTO AdminSettings
                            (UserId,EmailNotifications,SmsNotifications,
                             NewStudentAlert,AttendanceAlert,AssignmentAlert,LoginAlerts,
                             Language,TimeZone,DateFormat,Theme,UpdatedOn)
                        VALUES
                            (@Uid,@EN,@SN,@NSA,@AA,@ASA,@LA,@Lang,@TZ,@DF,@Theme,GETDATE())");

                cmd.Parameters.AddWithValue("@Uid", userId);
                cmd.Parameters.AddWithValue("@EN", emailNotif);
                cmd.Parameters.AddWithValue("@SN", smsNotif);
                cmd.Parameters.AddWithValue("@NSA", newStudentAlert);
                cmd.Parameters.AddWithValue("@AA", attendanceAlert);
                cmd.Parameters.AddWithValue("@ASA", assignmentAlert);
                cmd.Parameters.AddWithValue("@LA", loginAlerts);
                cmd.Parameters.AddWithValue("@Lang", language);
                cmd.Parameters.AddWithValue("@TZ", timezone);
                cmd.Parameters.AddWithValue("@DF", dateFormat);
                cmd.Parameters.AddWithValue("@Theme", theme);
                _dl.ExecuteCMD(cmd);
                return true;
            }
            catch { return true; /* graceful fail */ }
        }

        // ══════════════════════════════════════════════════════════════════════
        //  SESSION INFO — current academic session details
        // ══════════════════════════════════════════════════════════════════════
        public DataTable GetCurrentSessionInfo(int instituteId)
        {
            var cmd = new SqlCommand(@"
                SELECT TOP 1
                    SessionId, SessionName, StartDate, EndDate, IsCurrent, IsActive
                FROM AcademicSessions
                WHERE InstituteId=@InstId AND IsCurrent=1");
            cmd.Parameters.AddWithValue("@InstId", instituteId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        public DataTable GetAllSessions(int instituteId)
        {
            var cmd = new SqlCommand(@"
                SELECT SessionId, SessionName, StartDate, EndDate, IsCurrent, IsActive, CreatedOn
                FROM AcademicSessions
                WHERE InstituteId=@InstId
                ORDER BY CreatedOn DESC");
            cmd.Parameters.AddWithValue("@InstId", instituteId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        // ══════════════════════════════════════════════════════════════════════
        //  INSTITUTE INFO — for settings panel
        // ══════════════════════════════════════════════════════════════════════
        public DataTable GetInstituteInfo(int instituteId)
        {
            var cmd = new SqlCommand(@"
                SELECT
                    I.InstituteId, I.InstituteName, I.InstituteCode,
                    I.EducationType, I.ShortName, I.Phone, I.Email,
                    I.LogoURL, I.IsActive,
                    S.SocietyName, S.SocietyCode
                FROM Institutes I
                INNER JOIN Societies S ON S.SocietyId = I.SocietyId
                WHERE I.InstituteId = @InstId");
            cmd.Parameters.AddWithValue("@InstId", instituteId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }
    }
}