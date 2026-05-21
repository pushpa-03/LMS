using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Web.Security;

namespace LearningManagementSystem.BL
{
    
    public class AddTeacherBL
    {
        private readonly DataLayer _dl = new DataLayer();

        // ══════════════════════════════════════════════════════════════════════════
        //  READ – Teachers list for grid / repeater
        // ══════════════════════════════════════════════════════════════════════════

        /// <summary>
        /// Returns all teachers for the given institute and session,
        /// optionally filtered by stream and active-status.
        /// </summary>
        public DataTable GetTeachers(int instituteId, int sessionId,
                                     int filterStreamId = 0,
                                     string filterStatus = "All")
        {
            string query = @"
                SELECT
                    u.UserId,
                    u.Username,
                    u.Email,
                    u.IsActive,
                    u.IsFirstLogin,
                    u.LastLogin,
                    u.CreatedOn,

                    ISNULL(p.FullName,             '')      AS FullName,
                    ISNULL(p.ContactNo,            '')      AS ContactNo,
                    ISNULL(p.Gender,               '')      AS Gender,
                    ISNULL(CONVERT(VARCHAR,p.DOB,23),'')    AS DOB,
                    ISNULL(CONVERT(VARCHAR,p.JoinedDate,23),'') AS JoinedDate,
                    ISNULL(p.FatherName,           '')      AS FatherName,
                    ISNULL(p.MotherName,           '')      AS MotherName,
                    ISNULL(p.EmergencyContactName, '')      AS EmergencyContactName,
                    ISNULL(p.EmergencyContactNo,   '')      AS EmergencyContactNo,
                    ISNULL(p.Address,              '')      AS Address,
                    ISNULL(p.City,                 '')      AS City,
                    ISNULL(p.Country,              '')      AS Country,
                    ISNULL(CAST(p.Pincode AS VARCHAR),'')   AS Pincode,
                    ISNULL(p.Skills,               '')      AS Skills,

                    ISNULL(t.EmployeeId,           '')      AS EmployeeId,
                    ISNULL(t.Designation,          '')      AS Designation,
                    ISNULL(t.Qualification,        '')      AS Qualification,
                    ISNULL(t.ExperienceYears,       0)      AS ExperienceYears,
                    ISNULL(t.StreamId,             0)       AS StreamId,

                    ISNULL(s.StreamName,           '—')     AS StreamName

                FROM Users u
                INNER JOIN Roles r
                    ON r.RoleId = u.RoleId AND r.RoleName = 'Teacher'
                LEFT  JOIN UserProfile    p ON p.UserId   = u.UserId
                LEFT  JOIN TeacherDetails t ON t.UserId   = u.UserId
                LEFT  JOIN Streams        s ON s.StreamId = t.StreamId

                WHERE u.InstituteId = @InstituteId
                  AND t.SessionId   = @SessionId";

            SqlCommand cmd = new SqlCommand();
            cmd.Parameters.AddWithValue("@InstituteId", instituteId);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);

            if (filterStreamId > 0)
            {
                query += " AND t.StreamId = @StreamId";
                cmd.Parameters.AddWithValue("@StreamId", filterStreamId);
            }

            if (filterStatus == "Active")
                query += " AND u.IsActive = 1";
            else if (filterStatus == "Inactive")
                query += " AND u.IsActive = 0";

            query += " ORDER BY p.FullName ASC";
            cmd.CommandText = query;
            return _dl.GetDataTable(cmd);
        }

        //this method is used in TeacherList page
        public DataTable GetFilteredTeachers(int instId, int SessionId, string search, int streamId, string status)
        {
                        string query = @"
            SELECT
                   S.StreamName AS Stream,
                   U.UserId,
                   U.IsActive,
                   U.Email,

                   P.FullName,
                   P.ContactNo,
                   P.JoinedDate,
                   P.Gender,
                   P.City,
                   P.Country,

                   T.EmployeeId,
                   T.Designation,
                   T.ExperienceYears,
                   T.Qualification

            FROM Users U
            JOIN UserProfile P ON U.UserId = P.UserId
            JOIN TeacherDetails T ON U.UserId = T.UserId
            JOIN Streams S ON T.StreamId = S.StreamId

            WHERE U.InstituteId = @instId
              AND T.SessionId = @SessionId
              AND U.RoleId = (
                    SELECT RoleId
                    FROM Roles
                    WHERE RoleName = 'Teacher'
              )";

            if (!string.IsNullOrEmpty(search))
                query += " AND (P.FullName LIKE @search OR T.EmployeeId LIKE @search)";

            if (streamId > 0)
                query += " AND T.StreamId = @streamId";

            query += " AND U.IsActive = @status";

            SqlCommand cmd = new SqlCommand(query);

            cmd.Parameters.AddWithValue("@instId", instId);
            cmd.Parameters.AddWithValue("@SessionId", SessionId);
            cmd.Parameters.AddWithValue("@search", "%" + search + "%");
            cmd.Parameters.AddWithValue("@streamId", streamId);
            cmd.Parameters.AddWithValue("@status", status == "1");

            return _dl.GetDataTable(cmd);
        }

        // ══════════════════════════════════════════════════════════════════════════
        //  READ – Single teacher (for Edit / View profile)
        // ══════════════════════════════════════════════════════════════════════════

        public DataTable GetTeacherById(int userId, int sessionId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT
                    u.UserId,
                    u.Username,
                    u.Email,
                    u.IsActive,
                    u.IsFirstLogin,

                    ISNULL(p.FullName,             '')      AS FullName,
                    ISNULL(p.ContactNo,            '')      AS ContactNo,
                    ISNULL(p.Gender,               '')      AS Gender,
                    p.DOB,
                    p.JoinedDate,
                    ISNULL(p.FatherName,           '')      AS FatherName,
                    ISNULL(p.MotherName,           '')      AS MotherName,
                    ISNULL(p.EmergencyContactName, '')      AS EmergencyContactName,
                    ISNULL(p.EmergencyContactNo,   '')      AS EmergencyContactNo,
                    ISNULL(p.Address,              '')      AS Address,
                    ISNULL(p.City,                 '')      AS City,
                    ISNULL(p.Country,              '')      AS Country,
                    ISNULL(CAST(p.Pincode AS VARCHAR),'')   AS Pincode,
                    ISNULL(p.Skills,               '')      AS Skills,

                    ISNULL(t.EmployeeId,           '')      AS EmployeeId,
                    ISNULL(t.Designation,          '')      AS Designation,
                    ISNULL(t.Qualification,        '')      AS Qualification,
                    ISNULL(t.ExperienceYears,       0)      AS ExperienceYears,
                    ISNULL(t.StreamId,             0)       AS StreamId,

                    ISNULL(s.StreamName,           '—')     AS StreamName

                FROM Users u
                LEFT  JOIN UserProfile    p ON p.UserId   = u.UserId
                LEFT  JOIN TeacherDetails t ON t.UserId   = u.UserId
                LEFT  JOIN Streams        s ON s.StreamId = t.StreamId

                WHERE u.UserId      = @UserId
                  AND t.SessionId   = @SessionId");

            cmd.Parameters.AddWithValue("@UserId", userId);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);
            return _dl.GetDataTable(cmd);
        }

        // ══════════════════════════════════════════════════════════════════════════
        //  DROP-DOWN HELPERS
        // ══════════════════════════════════════════════════════════════════════════

        public DataTable GetStreams(int instituteId, int sessionId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT StreamId, StreamName
                FROM   Streams
                WHERE  InstituteId = @I AND SessionId = @S AND IsActive = 1
                ORDER  BY StreamName");
            cmd.Parameters.AddWithValue("@I", instituteId);
            cmd.Parameters.AddWithValue("@S", sessionId);
            return _dl.GetDataTable(cmd);
        }

        public DataTable GetPreviousSessions(int instituteId, int currentSessionId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT SessionId, SessionName
                FROM   AcademicSessions
                WHERE  InstituteId = @I
                  AND  SessionId  <> @Curr
                  AND  IsActive    = 1
                ORDER  BY StartDate DESC");
            cmd.Parameters.AddWithValue("@I", instituteId);
            cmd.Parameters.AddWithValue("@Curr", currentSessionId);
            return _dl.GetDataTable(cmd);
        }

        /// <summary>Resolves a stream name to its StreamId (used in bulk upload).</summary>
        public int GetStreamIdByName(int instituteId, int sessionId, string name)
        {
            if (string.IsNullOrWhiteSpace(name)) return 0;
            SqlCommand cmd = new SqlCommand(@"
                SELECT TOP 1 StreamId FROM Streams
                WHERE  InstituteId = @I AND SessionId = @S AND StreamName = @N");
            cmd.Parameters.AddWithValue("@I", instituteId);
            cmd.Parameters.AddWithValue("@S", sessionId);
            cmd.Parameters.AddWithValue("@N", name.Trim());
            DataTable dt = _dl.GetDataTable(cmd);
            return dt.Rows.Count > 0 ? Convert.ToInt32(dt.Rows[0][0]) : 0;
        }

        // ══════════════════════════════════════════════════════════════════════════
        //  DUPLICATE / IN-USE CHECKS
        // ══════════════════════════════════════════════════════════════════════════

        public bool IsUsernameTaken(string username, int excludeUserId = 0)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT COUNT(1) FROM Users
                WHERE  Username = @U AND UserId <> @Excl");
            cmd.Parameters.AddWithValue("@U", username.Trim().ToLower());
            cmd.Parameters.AddWithValue("@Excl", excludeUserId);
            DataTable dt = _dl.GetDataTable(cmd);
            return dt.Rows.Count > 0 && Convert.ToInt32(dt.Rows[0][0]) > 0;
        }

        public bool IsEmailTaken(string email, int excludeUserId = 0)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT COUNT(1) FROM Users
                WHERE  Email = @E AND UserId <> @Excl");
            cmd.Parameters.AddWithValue("@E", email.Trim().ToLower());
            cmd.Parameters.AddWithValue("@Excl", excludeUserId);
            DataTable dt = _dl.GetDataTable(cmd);
            return dt.Rows.Count > 0 && Convert.ToInt32(dt.Rows[0][0]) > 0;
        }

        /// <summary>Checks if the Employee ID is already used in this session.</summary>
        public bool IsEmpIdTaken(int instituteId, int sessionId,
                                 string empId, int excludeUserId = 0)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT COUNT(1)
                FROM   TeacherDetails t
                INNER JOIN Users u ON u.UserId = t.UserId
                WHERE  u.InstituteId  = @I
                  AND  t.SessionId    = @S
                  AND  t.EmployeeId   = @E
                  AND  t.UserId      <> @Excl");
            cmd.Parameters.AddWithValue("@I", instituteId);
            cmd.Parameters.AddWithValue("@S", sessionId);
            cmd.Parameters.AddWithValue("@E", empId.Trim());
            cmd.Parameters.AddWithValue("@Excl", excludeUserId);
            DataTable dt = _dl.GetDataTable(cmd);
            return dt.Rows.Count > 0 && Convert.ToInt32(dt.Rows[0][0]) > 0;
        }

        /// <summary>
        /// Returns true if the teacher has any linked records that would block delete:
        /// SubjectFaculty, TeacherCourses, Attendance (MarkedBy), Assignments (CreatedBy),
        /// Quizzes (CreatedBy), Videos (InstructorId / UploadedBy).
        /// </summary>
        public bool IsTeacherInUse(int userId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT
                (SELECT COUNT(1) FROM SubjectFaculty  WHERE TeacherId  = @Id) +
                (SELECT COUNT(1) FROM TeacherCourses  WHERE TeacherId  = @Id) +
                (SELECT COUNT(1) FROM Attendance      WHERE MarkedBy   = @Id) +
                (SELECT COUNT(1) FROM Assignments     WHERE CreatedBy  = @Id) +
                (SELECT COUNT(1) FROM Quizzes         WHERE CreatedBy  = @Id) +
                (SELECT COUNT(1) FROM Videos          WHERE InstructorId = @Id OR UploadedBy = @Id)
                AS TotalUsage");
            cmd.Parameters.AddWithValue("@Id", userId);
            DataTable dt = _dl.GetDataTable(cmd);
            return dt.Rows.Count > 0 && Convert.ToInt32(dt.Rows[0][0]) > 0;
        }

        // ══════════════════════════════════════════════════════════════════════════
        //  INSERT  (Users → UserProfile → TeacherDetails  in one transaction)
        // ══════════════════════════════════════════════════════════════════════════

        /// <summary>
        /// Inserts a new teacher across three tables atomically.
        /// Returns the new UserId.
        /// Strategy: insert Users first (OUTPUT INSERTED.UserId via GetDataTable),
        /// then UserProfile + TeacherDetails together via ExecuteTransaction.
        /// </summary>
        public int InsertTeacher(TeacherGC obj)
        {
            int roleId = GetRoleId("Teacher");
            if (roleId == 0) throw new Exception("Teacher role not found in Roles table.");

            // ── Step 1: Insert Users, capture new UserId ─────────────────────────
            int newUserId = InsertUserGetId(obj, roleId);
            if (newUserId == 0) throw new Exception("Failed to create user account.");

            // ── Step 2: UserProfile + TeacherDetails in one transaction ──────────
            var cmds = new List<SqlCommand>();

            // UserProfile
            var cmdP = new SqlCommand(@"
                INSERT INTO UserProfile
                    (SocietyId, InstituteId, SessionId, UserId,
                     FullName, FatherName, MotherName, Gender, DOB,
                     ContactNo, EmergencyContactName, EmergencyContactNo,
                     Address, City, Country, Pincode, JoinedDate, Skills)
                VALUES
                    (@Soc, @Inst, @Sess, @UserId,
                     @FullName, @Father, @Mother, @Gender, @DOB,
                     @Contact, @EmgName, @EmgContact,
                     @Address, @City, @Country, @Pincode, @Joined, @Skills)");

            cmdP.Parameters.AddWithValue("@Soc", obj.SocietyId);
            cmdP.Parameters.AddWithValue("@Inst", obj.InstituteId);
            cmdP.Parameters.AddWithValue("@Sess", obj.SessionId);
            cmdP.Parameters.AddWithValue("@UserId", newUserId);
            cmdP.Parameters.AddWithValue("@FullName", obj.FullName);
            cmdP.Parameters.AddWithValue("@Father", NullIfEmpty(obj.FatherName));
            cmdP.Parameters.AddWithValue("@Mother", NullIfEmpty(obj.MotherName));
            cmdP.Parameters.AddWithValue("@Gender", obj.Gender);
            cmdP.Parameters.AddWithValue("@DOB",
                obj.DOB == DateTime.MinValue ? (object)DBNull.Value : obj.DOB);
            cmdP.Parameters.AddWithValue("@Contact", obj.ContactNo);
            cmdP.Parameters.AddWithValue("@EmgName", obj.EmgName);
            cmdP.Parameters.AddWithValue("@EmgContact", obj.EmgContact);
            cmdP.Parameters.AddWithValue("@Address", obj.Address);
            cmdP.Parameters.AddWithValue("@City", NullIfEmpty(obj.City));
            cmdP.Parameters.AddWithValue("@Country", NullIfEmpty(obj.Country));
            cmdP.Parameters.AddWithValue("@Pincode",
                obj.Pincode.HasValue ? (object)obj.Pincode.Value : DBNull.Value);
            cmdP.Parameters.AddWithValue("@Joined", obj.JoinedDate);
            cmdP.Parameters.AddWithValue("@Skills", NullIfEmpty(obj.Skills));
            cmds.Add(cmdP);

            // TeacherDetails
            var cmdT = new SqlCommand(@"
                INSERT INTO TeacherDetails
                    (UserId, SocietyId, InstituteId, SessionId, StreamId,
                     EmployeeId, ExperienceYears, Qualification, Designation)
                VALUES
                    (@UserId, @Soc, @Inst, @Sess, @StreamId,
                     @EmpId, @Exp, @Qual, @Desig)");

            cmdT.Parameters.AddWithValue("@UserId", newUserId);
            cmdT.Parameters.AddWithValue("@Soc", obj.SocietyId);
            cmdT.Parameters.AddWithValue("@Inst", obj.InstituteId);
            cmdT.Parameters.AddWithValue("@Sess", obj.SessionId);
            cmdT.Parameters.AddWithValue("@StreamId", obj.StreamId);
            cmdT.Parameters.AddWithValue("@EmpId", obj.EmployeeId);
            cmdT.Parameters.AddWithValue("@Exp", obj.ExperienceYears);
            cmdT.Parameters.AddWithValue("@Qual", string.IsNullOrWhiteSpace(obj.Qualification)
                                                     ? "N/A" : obj.Qualification);
            cmdT.Parameters.AddWithValue("@Desig", obj.Designation);
            cmds.Add(cmdT);

            _dl.ExecuteTransaction(cmds);
            return newUserId;
        }

        /// <summary>
        /// Inserts into Users via OUTPUT INSERTED.UserId (GetDataTable returns the new ID).
        /// </summary>
        private int InsertUserGetId(TeacherGC obj, int roleId)
        {
            SqlCommand cmd = new SqlCommand(@"
                INSERT INTO Users
                    (Username, PasswordHash, RoleId, Email,
                     SocietyId, InstituteId, SessionId,
                     IsActive, IsFirstLogin, CreatedOn)
                OUTPUT INSERTED.UserId
                VALUES
                    (@Username, HASHBYTES('SHA2_256', @Password), @RoleId, @Email,
                     @Soc, @Inst, @Sess,
                     @Active, 1, GETDATE())");

            cmd.Parameters.AddWithValue("@Username", obj.Username);
            cmd.Parameters.AddWithValue("@Password", obj.Password);
            cmd.Parameters.AddWithValue("@RoleId", roleId);
            cmd.Parameters.AddWithValue("@Email", obj.Email.ToLower());
            cmd.Parameters.AddWithValue("@Soc", obj.SocietyId);
            cmd.Parameters.AddWithValue("@Inst", obj.InstituteId);
            cmd.Parameters.AddWithValue("@Sess", obj.SessionId);
            cmd.Parameters.AddWithValue("@Active", obj.IsActive ? 1 : 0);

            DataTable dt = _dl.GetDataTable(cmd);
            return dt.Rows.Count > 0 ? Convert.ToInt32(dt.Rows[0][0]) : 0;
        }

        // ══════════════════════════════════════════════════════════════════════════
        //  UPDATE  (Users + UserProfile + TeacherDetails via MERGE)
        // ══════════════════════════════════════════════════════════════════════════

        public void UpdateTeacher(TeacherGC obj)
        {
            var cmds = new List<SqlCommand>();

            // Users – email + IsActive
            var cmdU = new SqlCommand(@"
                UPDATE Users SET
                    Email    = @Email,
                    IsActive = @Active
                WHERE UserId = @Id");
            cmdU.Parameters.AddWithValue("@Email", obj.Email.ToLower());
            cmdU.Parameters.AddWithValue("@Active", obj.IsActive ? 1 : 0);
            cmdU.Parameters.AddWithValue("@Id", obj.UserId);
            cmds.Add(cmdU);

            // UserProfile – MERGE so missing rows are inserted safely
            var cmdP = new SqlCommand(@"
                MERGE UserProfile AS target
                USING (SELECT @UserId AS UserId) AS src ON target.UserId = src.UserId
                WHEN MATCHED THEN UPDATE SET
                    FullName             = @FullName,
                    FatherName           = @Father,
                    MotherName           = @Mother,
                    Gender               = @Gender,
                    DOB                  = @DOB,
                    ContactNo            = @Contact,
                    EmergencyContactName = @EmgName,
                    EmergencyContactNo   = @EmgContact,
                    Address              = @Address,
                    City                 = @City,
                    Country              = @Country,
                    Pincode              = @Pincode,
                    JoinedDate           = @Joined,
                    Skills               = @Skills
                WHEN NOT MATCHED THEN INSERT
                    (SocietyId,InstituteId,SessionId,UserId,FullName,FatherName,MotherName,
                     Gender,DOB,ContactNo,EmergencyContactName,EmergencyContactNo,
                     Address,City,Country,Pincode,JoinedDate,Skills)
                VALUES
                    (@Soc,@Inst,@Sess,@UserId,@FullName,@Father,@Mother,
                     @Gender,@DOB,@Contact,@EmgName,@EmgContact,
                     @Address,@City,@Country,@Pincode,@Joined,@Skills);");

            cmdP.Parameters.AddWithValue("@UserId", obj.UserId);
            cmdP.Parameters.AddWithValue("@Soc", obj.SocietyId);
            cmdP.Parameters.AddWithValue("@Inst", obj.InstituteId);
            cmdP.Parameters.AddWithValue("@Sess", obj.SessionId);
            cmdP.Parameters.AddWithValue("@FullName", obj.FullName);
            cmdP.Parameters.AddWithValue("@Father", NullIfEmpty(obj.FatherName));
            cmdP.Parameters.AddWithValue("@Mother", NullIfEmpty(obj.MotherName));
            cmdP.Parameters.AddWithValue("@Gender", obj.Gender);
            cmdP.Parameters.AddWithValue("@DOB",
                obj.DOB == DateTime.MinValue ? (object)DBNull.Value : obj.DOB);
            cmdP.Parameters.AddWithValue("@Contact", obj.ContactNo);
            cmdP.Parameters.AddWithValue("@EmgName", obj.EmgName);
            cmdP.Parameters.AddWithValue("@EmgContact", obj.EmgContact);
            cmdP.Parameters.AddWithValue("@Address", obj.Address);
            cmdP.Parameters.AddWithValue("@City", NullIfEmpty(obj.City));
            cmdP.Parameters.AddWithValue("@Country", NullIfEmpty(obj.Country));
            cmdP.Parameters.AddWithValue("@Pincode",
                obj.Pincode.HasValue ? (object)obj.Pincode.Value : DBNull.Value);
            cmdP.Parameters.AddWithValue("@Joined", obj.JoinedDate);
            cmdP.Parameters.AddWithValue("@Skills", NullIfEmpty(obj.Skills));
            cmds.Add(cmdP);

            // TeacherDetails – MERGE
            var cmdT = new SqlCommand(@"
                MERGE TeacherDetails AS target
                USING (SELECT @UserId AS UserId) AS src ON target.UserId = src.UserId
                WHEN MATCHED THEN UPDATE SET
                    StreamId        = @StreamId,
                    EmployeeId      = @EmpId,
                    Designation     = @Desig,
                    ExperienceYears = @Exp,
                    Qualification   = @Qual
                WHEN NOT MATCHED THEN INSERT
                    (UserId,SocietyId,InstituteId,SessionId,
                     StreamId,EmployeeId,ExperienceYears,Qualification,Designation)
                VALUES
                    (@UserId,@Soc,@Inst,@Sess,
                     @StreamId,@EmpId,@Exp,@Qual,@Desig);");

            cmdT.Parameters.AddWithValue("@UserId", obj.UserId);
            cmdT.Parameters.AddWithValue("@Soc", obj.SocietyId);
            cmdT.Parameters.AddWithValue("@Inst", obj.InstituteId);
            cmdT.Parameters.AddWithValue("@Sess", obj.SessionId);
            cmdT.Parameters.AddWithValue("@StreamId", obj.StreamId);
            cmdT.Parameters.AddWithValue("@EmpId", obj.EmployeeId);
            cmdT.Parameters.AddWithValue("@Desig", obj.Designation);
            cmdT.Parameters.AddWithValue("@Exp", obj.ExperienceYears);
            cmdT.Parameters.AddWithValue("@Qual", string.IsNullOrWhiteSpace(obj.Qualification)
                                                      ? "N/A" : obj.Qualification);
            cmds.Add(cmdT);

            _dl.ExecuteTransaction(cmds);
        }

        // ══════════════════════════════════════════════════════════════════════════
        //  TOGGLE IsActive
        // ══════════════════════════════════════════════════════════════════════════

        public void ToggleTeacher(int userId)
        {
            SqlCommand cmd = new SqlCommand(@"
                UPDATE Users
                SET IsActive = CASE WHEN IsActive = 1 THEN 0 ELSE 1 END
                WHERE UserId = @Id");
            cmd.Parameters.AddWithValue("@Id", userId);
            _dl.ExecuteCMD(cmd);
        }

        // ══════════════════════════════════════════════════════════════════════════
        //  RESET PASSWORD
        // ══════════════════════════════════════════════════════════════════════════

        public void ResetPassword(int userId, string newPassword)
        {
            SqlCommand cmd = new SqlCommand(@"
                UPDATE Users SET
                    PasswordHash = HASHBYTES('SHA2_256', @Pwd),
                    IsFirstLogin = 1
                WHERE UserId = @Id");
            cmd.Parameters.AddWithValue("@Pwd", newPassword);
            cmd.Parameters.AddWithValue("@Id", userId);
            _dl.ExecuteCMD(cmd);
        }

        // ══════════════════════════════════════════════════════════════════════════
        //  DELETE  (correct FK order in one transaction)
        // ══════════════════════════════════════════════════════════════════════════

        public void DeleteTeacher(int userId, int sessionId)
        {
            var cmds = new List<SqlCommand>();

            // 1. TeacherDetails
            var c1 = new SqlCommand(
                "DELETE FROM TeacherDetails WHERE UserId = @Id AND SessionId = @S");
            c1.Parameters.AddWithValue("@Id", userId);
            c1.Parameters.AddWithValue("@S", sessionId);
            cmds.Add(c1);

            // 2. UserProfile
            var c2 = new SqlCommand(
                "DELETE FROM UserProfile WHERE UserId = @Id");
            c2.Parameters.AddWithValue("@Id", userId);
            cmds.Add(c2);

            // 3. Users
            var c3 = new SqlCommand(
                "DELETE FROM Users WHERE UserId = @Id");
            c3.Parameters.AddWithValue("@Id", userId);
            cmds.Add(c3);

            _dl.ExecuteTransaction(cmds);
        }

        // ══════════════════════════════════════════════════════════════════════════
        //  RE-ENROL  (copy teacher to new session)
        // ══════════════════════════════════════════════════════════════════════════

        /// <summary>
        /// Re-enrols a teacher from a previous session into the current session.
        /// Copies TeacherDetails row with updated SessionId.
        /// Optionally changes the stream if newStreamId is provided.
        /// Returns false if already enrolled in the target session.
        /// </summary>
        public bool ReenrolTeacher(int userId, int prevSessionId, int newSessionId,
                                   int societyId, int instituteId,
                                   int? newStreamId)
        {
            // Already enrolled in new session?
            SqlCommand chk = new SqlCommand(@"
                SELECT COUNT(1) FROM TeacherDetails
                WHERE UserId = @UserId AND SessionId = @NewSess");
            chk.Parameters.AddWithValue("@UserId", userId);
            chk.Parameters.AddWithValue("@NewSess", newSessionId);
            DataTable dtChk = _dl.GetDataTable(chk);
            if (dtChk.Rows.Count > 0 && Convert.ToInt32(dtChk.Rows[0][0]) > 0)
                return false;

            // Fetch previous TeacherDetails rowF
            SqlCommand getPrev = new SqlCommand(@"
                SELECT StreamId, EmployeeId, ExperienceYears,
                       Qualification, Designation
                FROM   TeacherDetails
                WHERE  UserId = @UserId AND SessionId = @PrevSess");
            getPrev.Parameters.AddWithValue("@UserId", userId);
            getPrev.Parameters.AddWithValue("@PrevSess", prevSessionId);
            DataTable dtPrev = _dl.GetDataTable(getPrev);
            if (dtPrev.Rows.Count == 0) return false;

            DataRow r = dtPrev.Rows[0];

            int streamId = newStreamId
                              ?? (r["StreamId"] != DBNull.Value
                                  ? Convert.ToInt32(r["StreamId"]) : 0);
            string empId = r["EmployeeId"].ToString();
            int exp = r["ExperienceYears"] != DBNull.Value
                              ? Convert.ToInt32(r["ExperienceYears"]) : 0;
            string qual = r["Qualification"].ToString();
            string desig = r["Designation"].ToString();

            var cmds = new List<SqlCommand>();

            // Update Users.SessionId so the teacher can login in new session
            var cmdU = new SqlCommand(@"
                UPDATE Users SET SessionId = @NewSess, IsFirstLogin = 0
                WHERE UserId = @UserId");
            cmdU.Parameters.AddWithValue("@NewSess", newSessionId);
            cmdU.Parameters.AddWithValue("@UserId", userId);
            cmds.Add(cmdU);

            // Insert new TeacherDetails row for new session
            var cmdT = new SqlCommand(@"
                INSERT INTO TeacherDetails
                    (UserId, SocietyId, InstituteId, SessionId,
                     StreamId, EmployeeId, ExperienceYears, Qualification, Designation)
                VALUES
                    (@UserId, @Soc, @Inst, @NewSess,
                     @StreamId, @EmpId, @Exp, @Qual, @Desig)");

            cmdT.Parameters.AddWithValue("@UserId", userId);
            cmdT.Parameters.AddWithValue("@Soc", societyId);
            cmdT.Parameters.AddWithValue("@Inst", instituteId);
            cmdT.Parameters.AddWithValue("@NewSess", newSessionId);
            cmdT.Parameters.AddWithValue("@StreamId", streamId > 0 ? (object)streamId : DBNull.Value);
            cmdT.Parameters.AddWithValue("@EmpId", empId);
            cmdT.Parameters.AddWithValue("@Exp", exp);
            cmdT.Parameters.AddWithValue("@Qual", string.IsNullOrWhiteSpace(qual) ? "N/A" : qual);
            cmdT.Parameters.AddWithValue("@Desig", desig);
            cmds.Add(cmdT);

            _dl.ExecuteTransaction(cmds);
            return true;
        }

        // ══════════════════════════════════════════════════════════════════════════
        //  PRIVATE HELPERS
        // ══════════════════════════════════════════════════════════════════════════

        private int GetRoleId(string roleName)
        {
            SqlCommand cmd = new SqlCommand(
                "SELECT RoleId FROM Roles WHERE RoleName = @R");
            cmd.Parameters.AddWithValue("@R", roleName);
            DataTable dt = _dl.GetDataTable(cmd);
            return dt.Rows.Count > 0 ? Convert.ToInt32(dt.Rows[0][0]) : 0;
        }

        /// <summary>Returns DBNull if string is null/whitespace; otherwise the string.</summary>
        private static object NullIfEmpty(string val) =>
            string.IsNullOrWhiteSpace(val) ? (object)DBNull.Value : val.Trim();
    }
}