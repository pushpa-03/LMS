////using System;
////using System.Collections.Generic;
////using System.Configuration;
////using System.Data;
////using System.Data.SqlClient;

////namespace LearningManagementSystem.BL
////{
////    public class StudentBL
////    {
////        private readonly DataLayer _dl = new DataLayer();

////        // ══════════════════════════════════════════════════════════════════════
////        //  GET STUDENTS
////        //  KEY FIX: LEFT JOIN UserProfile (no SessionId filter on profile)
////        //           so bulk-uploaded students who lack a profile still appear.
////        //  Also LEFT JOIN StudentAcademicDetails so students without SAD show.
////        // ══════════════════════════════════════════════════════════════════════
////        public DataTable GetStudents(
////            int instituteId, int sessionId,
////            string search = "", string status = "1", int streamId = 0)
////        {
////            // We show all students for this institute who are in the given session.
////            // UserProfile is LEFT JOIN because bulk import may have skipped it.
////            string sql = @"
////                SELECT
////                    U.UserId,
////                    U.Email,
////                    U.IsActive,
////                    U.Username,
////                    ISNULL(UP.FullName, U.Username)   AS FullName,
////                    ISNULL(UP.ContactNo, '')           AS ContactNo,
////                    UP.Gender,
////                    UP.DOB,
////                    UP.JoinedDate,
////                    ISNULL(SAD.RollNumber, '')         AS RollNumber,
////                    SAD.StreamId,
////                    SAD.CourseId,
////                    SAD.LevelId,
////                    SAD.SemesterId,
////                    SAD.SectionId,
////                    ISNULL(SAD.IsReEnrolled, 0)        AS IsReEnrolled,
////                    ISNULL(St.StreamName,  '—')        AS StreamName,
////                    ISNULL(C.CourseName,   '—')        AS CourseName,
////                    ISNULL(SL.LevelName,   '—')        AS LevelName,
////                    ISNULL(Sem.SemesterName,'—')       AS SemesterName,
////                    ISNULL(Sec.SectionName, '—')       AS SectionName
////                FROM Users U
////                -- LEFT JOIN so students without profile still appear
////                LEFT JOIN UserProfile UP
////                    ON U.UserId = UP.UserId
////                -- LEFT JOIN so students without academic details still appear
////                LEFT JOIN StudentAcademicDetails SAD
////                    ON U.UserId = SAD.UserId
////                    AND SAD.SessionId = @SessId
////                LEFT JOIN Streams     St  ON SAD.StreamId   = St.StreamId
////                LEFT JOIN Courses     C   ON SAD.CourseId   = C.CourseId
////                LEFT JOIN StudyLevels SL  ON SAD.LevelId    = SL.LevelId
////                LEFT JOIN Semesters   Sem ON SAD.SemesterId = Sem.SemesterId
////                LEFT JOIN Sections    Sec ON SAD.SectionId  = Sec.SectionId
////                WHERE U.RoleId = (SELECT TOP 1 RoleId FROM Roles WHERE RoleName='Student')
////                  AND U.InstituteId = @InstId";

////            var cmd = new SqlCommand();
////            cmd.Parameters.AddWithValue("@InstId", instituteId);
////            cmd.Parameters.AddWithValue("@SessId", sessionId);

////            if (status == "1" || status == "0")
////            {
////                sql += " AND U.IsActive = @Status";
////                cmd.Parameters.AddWithValue("@Status", status == "1" ? 1 : 0);
////            }

////            if (!string.IsNullOrWhiteSpace(search))
////            {
////                sql += @" AND (
////                    ISNULL(UP.FullName, U.Username) LIKE @Search
////                    OR ISNULL(SAD.RollNumber,'') LIKE @Search
////                    OR U.Email LIKE @Search
////                    OR U.Username LIKE @Search)";
////                cmd.Parameters.AddWithValue("@Search", "%" + search.Trim() + "%");
////            }

////            if (streamId > 0)
////            {
////                sql += " AND SAD.StreamId = @StreamId";
////                cmd.Parameters.AddWithValue("@StreamId", streamId);
////            }

////            sql += " ORDER BY ISNULL(UP.FullName, U.Username)";
////            cmd.CommandText = sql;
////            return _dl.GetDataTable(cmd) ?? new DataTable();
////        }

////        // Overload for view-modal index lookup (no filter)
////        public DataTable GetStudents(int instituteId, int sessionId)
////            => GetStudents(instituteId, sessionId, "", "All", 0);

////        // ══════════════════════════════════════════════════════════════════════
////        //  GET SINGLE STUDENT (Edit / View / Re-enrol)
////        //  LEFT JOIN UserProfile — student may not have profile row
////        // ══════════════════════════════════════════════════════════════════════
////        public DataRow GetStudentById(int userId, int sessionId)
////        {
////            var cmd = new SqlCommand(@"
////                SELECT
////                    U.UserId, U.Username, U.Email, U.IsActive,
////                    ISNULL(UP.FullName, U.Username)  AS FullName,
////                    ISNULL(UP.ContactNo, '')          AS ContactNo,
////                    ISNULL(UP.Gender, 'Male')         AS Gender,
////                    UP.DOB,
////                    UP.JoinedDate,
////                    ISNULL(SAD.RollNumber, '')        AS RollNumber,
////                    SAD.StreamId,   SAD.CourseId,
////                    SAD.LevelId,    SAD.SemesterId,   SAD.SectionId,
////                    ISNULL(St.StreamName,   '—')      AS StreamName,
////                    ISNULL(C.CourseName,    '—')      AS CourseName,
////                    ISNULL(SL.LevelName,    '—')      AS LevelName,
////                    ISNULL(Sem.SemesterName,'—')      AS SemesterName,
////                    ISNULL(Sec.SectionName, '—')      AS SectionName
////                FROM Users U
////                LEFT JOIN UserProfile UP
////                    ON U.UserId = UP.UserId
////                LEFT JOIN StudentAcademicDetails SAD
////                    ON U.UserId = SAD.UserId AND SAD.SessionId = @SessId
////                LEFT JOIN Streams     St  ON SAD.StreamId   = St.StreamId
////                LEFT JOIN Courses     C   ON SAD.CourseId   = C.CourseId
////                LEFT JOIN StudyLevels SL  ON SAD.LevelId    = SL.LevelId
////                LEFT JOIN Semesters   Sem ON SAD.SemesterId = Sem.SemesterId
////                LEFT JOIN Sections    Sec ON SAD.SectionId  = Sec.SectionId
////                WHERE U.UserId = @UserId");
////            cmd.Parameters.AddWithValue("@UserId", userId);
////            cmd.Parameters.AddWithValue("@SessId", sessionId);
////            DataTable dt = _dl.GetDataTable(cmd);
////            return dt != null && dt.Rows.Count > 0 ? dt.Rows[0] : null;
////        }

////        // ══════════════════════════════════════════════════════════════════════
////        //  DUPLICATE CHECK
////        //  KEY FIX: Check Users table directly — do NOT join StudentAcademicDetails.
////        //           Bulk-uploaded users exist in Users but may not have SAD row.
////        // ══════════════════════════════════════════════════════════════════════
////        public bool StudentExists(
////            string username, string email, string rollNo,
////            int instituteId, int sessionId)
////        {
////            // Check username/email in Users (global, no session filter)
////            var cmd = new SqlCommand(@"
////                SELECT COUNT(*) FROM Users
////                WHERE InstituteId = @InstId
////                  AND (Username = @U OR Email = @E)");
////            cmd.Parameters.AddWithValue("@InstId", instituteId);
////            cmd.Parameters.AddWithValue("@U", username?.Trim() ?? "");
////            cmd.Parameters.AddWithValue("@E", email?.Trim() ?? "");
////            DataTable dt = _dl.GetDataTable(cmd);
////            if (dt != null && dt.Rows.Count > 0 && Convert.ToInt32(dt.Rows[0][0]) > 0)
////                return true;

////            // Check roll number in StudentAcademicDetails for this session
////            if (!string.IsNullOrEmpty(rollNo))
////            {
////                var cmd2 = new SqlCommand(@"
////                    SELECT COUNT(*) FROM StudentAcademicDetails
////                    WHERE RollNumber = @R AND SessionId = @SessId");
////                cmd2.Parameters.AddWithValue("@R", rollNo.Trim());
////                cmd2.Parameters.AddWithValue("@SessId", sessionId);
////                DataTable dt2 = _dl.GetDataTable(cmd2);
////                if (dt2 != null && dt2.Rows.Count > 0 && Convert.ToInt32(dt2.Rows[0][0]) > 0)
////                    return true;
////            }
////            return false;
////        }

////        // ══════════════════════════════════════════════════════════════════════
////        //  INSERT STUDENT
////        //  Creates: Users → UserProfile (optional) → StudentAcademicDetails → Log
////        //  Profile insert is wrapped in try-catch so bulk upload never fails on it.
////        // ══════════════════════════════════════════════════════════════════════
////        public void InsertStudent(
////            int societyId, int instituteId, int sessionId,
////            string username, string email, string fullName,
////            string gender, DateTime dob, string contact, string address,
////            int? streamId, int? levelId, int? semesterId,
////            int? courseId, int? sectionId,
////            string rollNo, int addedByUserId)
////        {
////            if (sessionId == 0)
////                throw new Exception("No active academic session. Please set a current session first.");

////            // ── Step 1: Insert into Users (returns new UserId) ─────────────────
////            int newUserId;
////            using (var con = new SqlConnection(
////                ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString))
////            {
////                con.Open();
////                var cmd = new SqlCommand(@"
////                    INSERT INTO Users
////                        (Username, Email, PasswordHash, RoleId,
////                         SocietyId, InstituteId, SessionId,
////                         IsActive, IsFirstLogin, CreatedOn)
////                    VALUES
////                        (@Username, @Email,
////                         HASHBYTES('SHA2_256', 'Student@123'),
////                         (SELECT TOP 1 RoleId FROM Roles WHERE RoleName='Student'),
////                         @SocId, @InstId, @SessId,
////                         1, 1, GETDATE());
////                    SELECT CAST(SCOPE_IDENTITY() AS INT);", con);

////                cmd.Parameters.AddWithValue("@Username", username.Trim());
////                cmd.Parameters.AddWithValue("@Email", email.Trim());
////                cmd.Parameters.AddWithValue("@SocId", societyId);
////                cmd.Parameters.AddWithValue("@InstId", instituteId);
////                cmd.Parameters.AddWithValue("@SessId", sessionId);

////                object result = cmd.ExecuteScalar();
////                if (result == null || result == DBNull.Value)
////                    throw new Exception("Failed to create user account.");
////                newUserId = Convert.ToInt32(result);
////            }

////            // ── Steps 2+3+4 in one transaction ────────────────────────────────
////            var cmds = new List<SqlCommand>();

////            // 2. UserProfile — only insert if fullName is provided
////            if (!string.IsNullOrWhiteSpace(fullName))
////            {
////                var profileCmd = new SqlCommand(@"
////                    IF NOT EXISTS (SELECT 1 FROM UserProfile WHERE UserId = @UserId)
////                    BEGIN
////                        INSERT INTO UserProfile
////                            (SocietyId, InstituteId, UserId,
////                             FullName, Gender, DOB, ContactNo, Address,
////                             EmergencyContactName, EmergencyContactNo,
////                             JoinedDate)
////                        VALUES
////                            (@SocId, @InstId, @UserId,
////                             @FullName, @Gender, @DOB, @Contact, @Address,
////                             'N/A', '0000000000',
////                             GETDATE())
////                    END");
////                profileCmd.Parameters.AddWithValue("@SocId", societyId);
////                profileCmd.Parameters.AddWithValue("@InstId", instituteId);
////                profileCmd.Parameters.AddWithValue("@UserId", newUserId);
////                profileCmd.Parameters.AddWithValue("@FullName", fullName.Trim());
////                profileCmd.Parameters.AddWithValue("@Gender", gender ?? "Male");
////                profileCmd.Parameters.AddWithValue("@DOB", (object)dob);
////                profileCmd.Parameters.AddWithValue("@Contact", contact ?? "");
////                profileCmd.Parameters.AddWithValue("@Address", address ?? "");
////                cmds.Add(profileCmd);
////            }

////            // 3. StudentAcademicDetails
////            var acadCmd = new SqlCommand(@"
////                IF NOT EXISTS (
////                    SELECT 1 FROM StudentAcademicDetails
////                    WHERE UserId = @UserId AND SessionId = @SessId
////                )
////                BEGIN
////                    INSERT INTO StudentAcademicDetails
////                        (UserId, SocietyId, InstituteId, SessionId,
////                         StreamId, CourseId, LevelId, SemesterId, SectionId,
////                         RollNumber, IsReEnrolled)
////                    VALUES
////                        (@UserId, @SocId, @InstId, @SessId,
////                         @StreamId, @CourseId, @LevelId, @SemId, @SecId,
////                         @RollNo, 0)
////                END");
////            acadCmd.Parameters.AddWithValue("@UserId", newUserId);
////            acadCmd.Parameters.AddWithValue("@SocId", societyId);
////            acadCmd.Parameters.AddWithValue("@InstId", instituteId);
////            acadCmd.Parameters.AddWithValue("@SessId", sessionId);
////            acadCmd.Parameters.AddWithValue("@StreamId", (object)streamId ?? DBNull.Value);
////            acadCmd.Parameters.AddWithValue("@CourseId", (object)courseId ?? DBNull.Value);
////            acadCmd.Parameters.AddWithValue("@LevelId", (object)levelId ?? DBNull.Value);
////            acadCmd.Parameters.AddWithValue("@SemId", (object)semesterId ?? DBNull.Value);
////            acadCmd.Parameters.AddWithValue("@SecId", (object)sectionId ?? DBNull.Value);
////            acadCmd.Parameters.AddWithValue("@RollNo", rollNo ?? "");
////            cmds.Add(acadCmd);

////            // 4. Activity log
////            var logCmd = new SqlCommand(@"
////                INSERT INTO UserActivityLog
////                    (UserId, SocietyId, InstituteId, SessionId,
////                     ActivityType, ReferenceId, ActionTime)
////                VALUES
////                    (@AddedBy, @SocId, @InstId, @SessId,
////                     'StudentAdded', @NewId, GETDATE())");
////            logCmd.Parameters.AddWithValue("@AddedBy", addedByUserId);
////            logCmd.Parameters.AddWithValue("@SocId", societyId);
////            logCmd.Parameters.AddWithValue("@InstId", instituteId);
////            logCmd.Parameters.AddWithValue("@SessId", sessionId);
////            logCmd.Parameters.AddWithValue("@NewId", newUserId);
////            cmds.Add(logCmd);

////            _dl.ExecuteTransaction(cmds);
////        }

////        // ══════════════════════════════════════════════════════════════════════
////        //  UPDATE STUDENT
////        // ══════════════════════════════════════════════════════════════════════
////        public void UpdateStudent(
////            int userId, int sessionId,
////            string email, string fullName, string contact, string rollNo,
////            string gender, DateTime? dob,
////            int? streamId, int? courseId, int? levelId,
////            int? semesterId, int? sectionId)
////        {
////            var cmds = new List<SqlCommand>();

////            // Update email in Users
////            var uCmd = new SqlCommand(
////                "UPDATE Users SET Email=@Email WHERE UserId=@UserId");
////            uCmd.Parameters.AddWithValue("@Email", email.Trim());
////            uCmd.Parameters.AddWithValue("@UserId", userId);
////            cmds.Add(uCmd);

////            // Upsert UserProfile (student may not have one — bulk uploaded)
////            var pCmd = new SqlCommand(@"
////                IF EXISTS (SELECT 1 FROM UserProfile WHERE UserId=@UserId)
////                BEGIN
////                    UPDATE UserProfile
////                    SET FullName=@FullName, ContactNo=@Contact,
////                        Gender=@Gender, DOB=@DOB
////                    WHERE UserId=@UserId
////                END
////                ELSE
////                BEGIN
////                    INSERT INTO UserProfile
////                        (UserId, FullName, ContactNo, Gender, DOB,
////                         EmergencyContactName, EmergencyContactNo, JoinedDate)
////                    VALUES
////                        (@UserId, @FullName, @Contact, @Gender, @DOB,
////                         'N/A', '0000000000', GETDATE())
////                END");
////            pCmd.Parameters.AddWithValue("@FullName", fullName.Trim());
////            pCmd.Parameters.AddWithValue("@Contact", contact ?? "");
////            pCmd.Parameters.AddWithValue("@Gender", gender ?? "Male");
////            pCmd.Parameters.AddWithValue("@DOB", dob.HasValue ? (object)dob.Value : DBNull.Value);
////            pCmd.Parameters.AddWithValue("@UserId", userId);
////            cmds.Add(pCmd);

////            // Upsert StudentAcademicDetails
////            var aCmd = new SqlCommand(@"
////                IF EXISTS (SELECT 1 FROM StudentAcademicDetails WHERE UserId=@UserId AND SessionId=@SessId)
////                BEGIN
////                    UPDATE StudentAcademicDetails
////                    SET RollNumber=@RollNo, StreamId=@StreamId,
////                        CourseId=@CourseId, LevelId=@LevelId,
////                        SemesterId=@SemId,  SectionId=@SecId
////                    WHERE UserId=@UserId AND SessionId=@SessId
////                END
////                ELSE
////                BEGIN
////                    INSERT INTO StudentAcademicDetails
////                        (UserId, SessionId, RollNumber, StreamId,
////                         CourseId, LevelId, SemesterId, SectionId, IsReEnrolled)
////                    VALUES
////                        (@UserId, @SessId, @RollNo, @StreamId,
////                         @CourseId, @LevelId, @SemId, @SecId, 0)
////                END");
////            aCmd.Parameters.AddWithValue("@RollNo", rollNo ?? "");
////            aCmd.Parameters.AddWithValue("@StreamId", (object)streamId ?? DBNull.Value);
////            aCmd.Parameters.AddWithValue("@CourseId", (object)courseId ?? DBNull.Value);
////            aCmd.Parameters.AddWithValue("@LevelId", (object)levelId ?? DBNull.Value);
////            aCmd.Parameters.AddWithValue("@SemId", (object)semesterId ?? DBNull.Value);
////            aCmd.Parameters.AddWithValue("@SecId", (object)sectionId ?? DBNull.Value);
////            aCmd.Parameters.AddWithValue("@UserId", userId);
////            aCmd.Parameters.AddWithValue("@SessId", sessionId);
////            cmds.Add(aCmd);

////            _dl.ExecuteTransaction(cmds);
////        }

////        // ══════════════════════════════════════════════════════════════════════
////        //  RE-ENROL STUDENT
////        // ══════════════════════════════════════════════════════════════════════
////        public void ReEnrolStudent(
////            int userId, int societyId, int instituteId, int targetSessionId,
////            int? streamId, int? courseId, int? levelId,
////            int? semesterId, int? sectionId,
////            string rollNo, int enrolledByUserId)
////        {
////            var cmds = new List<SqlCommand>();

////            var acadCmd = new SqlCommand(@"
////                INSERT INTO StudentAcademicDetails
////                    (UserId, SocietyId, InstituteId, SessionId,
////                     StreamId, CourseId, LevelId, SemesterId, SectionId,
////                     RollNumber, IsReEnrolled)
////                VALUES
////                    (@UserId, @SocId, @InstId, @SessId,
////                     @StreamId, @CourseId, @LevelId, @SemId, @SecId,
////                     @RollNo, 1)");
////            acadCmd.Parameters.AddWithValue("@UserId", userId);
////            acadCmd.Parameters.AddWithValue("@SocId", societyId);
////            acadCmd.Parameters.AddWithValue("@InstId", instituteId);
////            acadCmd.Parameters.AddWithValue("@SessId", targetSessionId);
////            acadCmd.Parameters.AddWithValue("@StreamId", (object)streamId ?? DBNull.Value);
////            acadCmd.Parameters.AddWithValue("@CourseId", (object)courseId ?? DBNull.Value);
////            acadCmd.Parameters.AddWithValue("@LevelId", (object)levelId ?? DBNull.Value);
////            acadCmd.Parameters.AddWithValue("@SemId", (object)semesterId ?? DBNull.Value);
////            acadCmd.Parameters.AddWithValue("@SecId", (object)sectionId ?? DBNull.Value);
////            acadCmd.Parameters.AddWithValue("@RollNo", rollNo ?? "");
////            cmds.Add(acadCmd);

////            var logCmd = new SqlCommand(@"
////                INSERT INTO UserActivityLog
////                    (UserId, SocietyId, InstituteId, SessionId,
////                     ActivityType, ReferenceId, ActionTime)
////                VALUES
////                    (@By, @SocId, @InstId, @SessId,
////                     'StudentReEnrolled', @UserId, GETDATE())");
////            logCmd.Parameters.AddWithValue("@By", enrolledByUserId);
////            logCmd.Parameters.AddWithValue("@SocId", societyId);
////            logCmd.Parameters.AddWithValue("@InstId", instituteId);
////            logCmd.Parameters.AddWithValue("@SessId", targetSessionId);
////            logCmd.Parameters.AddWithValue("@UserId", userId);
////            cmds.Add(logCmd);

////            _dl.ExecuteTransaction(cmds);
////        }

////        // ══════════════════════════════════════════════════════════════════════
////        //  DELETE STUDENT
////        // ══════════════════════════════════════════════════════════════════════
////        public void DeleteStudent(int userId, int sessionId)
////        {
////            // Delete academic record for this session
////            var a = new SqlCommand(
////                "DELETE FROM StudentAcademicDetails WHERE UserId=@Id AND SessionId=@Sess");
////            a.Parameters.AddWithValue("@Id", userId);
////            a.Parameters.AddWithValue("@Sess", sessionId);
////            _dl.ExecuteCMD(a);

////            // If student has no more academic records → remove profile + user
////            var chk = new SqlCommand(
////                "SELECT COUNT(*) FROM StudentAcademicDetails WHERE UserId=@Id");
////            chk.Parameters.AddWithValue("@Id", userId);
////            DataTable dt = _dl.GetDataTable(chk);
////            int others = dt != null && dt.Rows.Count > 0 ? Convert.ToInt32(dt.Rows[0][0]) : 0;

////            if (others == 0)
////            {
////                var cmds = new List<SqlCommand>();
////                var p = new SqlCommand("DELETE FROM UserProfile WHERE UserId=@Id");
////                p.Parameters.AddWithValue("@Id", userId);
////                cmds.Add(p);
////                var u = new SqlCommand("DELETE FROM Users WHERE UserId=@Id");
////                u.Parameters.AddWithValue("@Id", userId);
////                cmds.Add(u);
////                _dl.ExecuteTransaction(cmds);
////            }
////        }

////        // ══════════════════════════════════════════════════════════════════════
////        //  TOGGLE ACTIVE / INACTIVE
////        // ══════════════════════════════════════════════════════════════════════
////        public bool ToggleStudent(int userId)
////        {
////            var cmd = new SqlCommand(@"
////                UPDATE Users
////                SET IsActive = CASE WHEN IsActive=1 THEN 0 ELSE 1 END
////                OUTPUT INSERTED.IsActive
////                WHERE UserId=@Id");
////            cmd.Parameters.AddWithValue("@Id", userId);
////            DataTable dt = _dl.GetDataTable(cmd);
////            return dt != null && dt.Rows.Count > 0 && Convert.ToBoolean(dt.Rows[0][0]);
////        }

////        // ══════════════════════════════════════════════════════════════════════
////        //  CHECK ENROLMENT IN SESSION
////        // ══════════════════════════════════════════════════════════════════════
////        public bool IsStudentEnrolledInSession(int userId, int sessionId)
////        {
////            var cmd = new SqlCommand(@"
////                SELECT COUNT(*) FROM StudentAcademicDetails
////                WHERE UserId=@UserId AND SessionId=@SessId");
////            cmd.Parameters.AddWithValue("@UserId", userId);
////            cmd.Parameters.AddWithValue("@SessId", sessionId);
////            DataTable dt = _dl.GetDataTable(cmd);
////            return dt != null && dt.Rows.Count > 0 && Convert.ToInt32(dt.Rows[0][0]) > 0;
////        }

////        // ══════════════════════════════════════════════════════════════════════
////        //  STATS — for the 5 stat cards
////        //  Uses LEFT JOIN so bulk-uploaded students without UserProfile are counted.
////        // ══════════════════════════════════════════════════════════════════════
////        public DataTable GetStudentStats(int instituteId, int sessionId)
////        {
////            var cmd = new SqlCommand(@"
////                SELECT
////                    COUNT(*)                                                         AS Total,
////                    SUM(CASE WHEN U.IsActive=1 THEN 1 ELSE 0 END)                   AS Active,
////                    SUM(CASE WHEN U.IsActive=0 THEN 1 ELSE 0 END)                   AS Inactive,
////                    SUM(CASE WHEN MONTH(U.CreatedOn)=MONTH(GETDATE())
////                                  AND YEAR(U.CreatedOn)=YEAR(GETDATE())
////                             THEN 1 ELSE 0 END)                                     AS NewStudents,
////                    SUM(CASE WHEN ISNULL(SAD.IsReEnrolled,0)=1 THEN 1 ELSE 0 END)   AS ReEnrolled
////                FROM Users U
////                LEFT JOIN StudentAcademicDetails SAD
////                    ON U.UserId = SAD.UserId AND SAD.SessionId = @SessId
////                WHERE U.RoleId = (SELECT TOP 1 RoleId FROM Roles WHERE RoleName='Student')
////                  AND U.InstituteId = @InstId");
////            cmd.Parameters.AddWithValue("@InstId", instituteId);
////            cmd.Parameters.AddWithValue("@SessId", sessionId);
////            return _dl.GetDataTable(cmd) ?? new DataTable();
////        }

////        // ══════════════════════════════════════════════════════════════════════
////        //  STREAM/COURSE BREAKDOWN — for coloured cards (live-updateable)
////        // ══════════════════════════════════════════════════════════════════════
////        public DataTable GetStudentStatsByStreamCourse(int instituteId, int sessionId)
////        {
////            var cmd = new SqlCommand(@"
////                SELECT
////                    ISNULL(St.StreamName,'No Stream') AS StreamName,
////                    ISNULL(C.CourseName, 'No Course')  AS CourseName,
////                    COUNT(*)                            AS TotalStudents
////                FROM Users U
////                LEFT JOIN StudentAcademicDetails SAD
////                    ON U.UserId = SAD.UserId AND SAD.SessionId = @SessId
////                LEFT JOIN Streams     St ON SAD.StreamId = St.StreamId
////                LEFT JOIN Courses     C  ON SAD.CourseId = C.CourseId
////                WHERE U.RoleId = (SELECT TOP 1 RoleId FROM Roles WHERE RoleName='Student')
////                  AND U.InstituteId = @InstId
////                  AND U.IsActive = 1
////                GROUP BY St.StreamName, C.CourseName
////                ORDER BY TotalStudents DESC");
////            cmd.Parameters.AddWithValue("@InstId", instituteId);
////            cmd.Parameters.AddWithValue("@SessId", sessionId);
////            return _dl.GetDataTable(cmd) ?? new DataTable();
////        }

////        // ══════════════════════════════════════════════════════════════════════
////        //  ACADEMIC DROPDOWN LOADERS
////        // ══════════════════════════════════════════════════════════════════════
////        public DataTable GetStreams(int instituteId, int sessionId)
////        {
////            var cmd = new SqlCommand(@"
////                SELECT StreamId, StreamName FROM Streams
////                WHERE InstituteId=@InstId AND SessionId=@SessId AND IsActive=1
////                ORDER BY StreamName");
////            cmd.Parameters.AddWithValue("@InstId", instituteId);
////            cmd.Parameters.AddWithValue("@SessId", sessionId);
////            return _dl.GetDataTable(cmd) ?? new DataTable();
////        }

////        public DataTable GetCourses(int instituteId, int sessionId)
////        {
////            var cmd = new SqlCommand(@"
////                SELECT CourseId, CourseName FROM Courses
////                WHERE InstituteId=@InstId AND SessionId=@SessId AND IsActive=1
////                ORDER BY CourseName");
////            cmd.Parameters.AddWithValue("@InstId", instituteId);
////            cmd.Parameters.AddWithValue("@SessId", sessionId);
////            return _dl.GetDataTable(cmd) ?? new DataTable();
////        }

////        public DataTable GetCoursesByStream(int instituteId, int sessionId, int streamId)
////        {
////            var cmd = new SqlCommand(@"
////                SELECT CourseId, CourseName FROM Courses
////                WHERE InstituteId=@InstId AND SessionId=@SessId
////                  AND StreamId=@StreamId AND IsActive=1
////                ORDER BY CourseName");
////            cmd.Parameters.AddWithValue("@InstId", instituteId);
////            cmd.Parameters.AddWithValue("@SessId", sessionId);
////            cmd.Parameters.AddWithValue("@StreamId", streamId);
////            return _dl.GetDataTable(cmd) ?? new DataTable();
////        }

////        public DataTable GetStudyLevels(int instituteId, int sessionId)
////        {
////            var cmd = new SqlCommand(@"
////                SELECT LevelId, LevelName FROM StudyLevels
////                WHERE InstituteId=@InstId AND SessionId=@SessId
////                ORDER BY LevelName");
////            cmd.Parameters.AddWithValue("@InstId", instituteId);
////            cmd.Parameters.AddWithValue("@SessId", sessionId);
////            return _dl.GetDataTable(cmd) ?? new DataTable();
////        }

////        public DataTable GetSemesters(int instituteId, int sessionId)
////        {
////            var cmd = new SqlCommand(@"
////                SELECT SemesterId, SemesterName FROM Semesters
////                WHERE InstituteId=@InstId AND SessionId=@SessId
////                ORDER BY SemesterName");
////            cmd.Parameters.AddWithValue("@InstId", instituteId);
////            cmd.Parameters.AddWithValue("@SessId", sessionId);
////            return _dl.GetDataTable(cmd) ?? new DataTable();
////        }

////        public DataTable GetSections(int instituteId, int sessionId)
////        {
////            var cmd = new SqlCommand(@"
////                SELECT SectionId, SectionName FROM Sections
////                WHERE InstituteId=@InstId AND SessionId=@SessId AND IsActive=1
////                ORDER BY SectionName");
////            cmd.Parameters.AddWithValue("@InstId", instituteId);
////            cmd.Parameters.AddWithValue("@SessId", sessionId);
////            return _dl.GetDataTable(cmd) ?? new DataTable();
////        }

////        public DataTable GetAllSessions(int instituteId)
////        {
////            var cmd = new SqlCommand(@"
////                SELECT SessionId, SessionName, IsCurrent
////                FROM AcademicSessions
////                WHERE InstituteId=@InstId
////                ORDER BY CreatedOn DESC");
////            cmd.Parameters.AddWithValue("@InstId", instituteId);
////            return _dl.GetDataTable(cmd) ?? new DataTable();
////        }

////        public int GetCurrentSessionId(int instituteId)
////        {
////            var cmd = new SqlCommand(@"
////                SELECT TOP 1 SessionId FROM AcademicSessions
////                WHERE InstituteId=@InstId AND IsCurrent=1");
////            cmd.Parameters.AddWithValue("@InstId", instituteId);
////            DataTable dt = _dl.GetDataTable(cmd);
////            return dt != null && dt.Rows.Count > 0
////                ? Convert.ToInt32(dt.Rows[0]["SessionId"]) : 0;
////        }
////    }
////}


////--------------------------------------------------------------------------------------------------------------------------



//using System;
//using System.Collections.Generic;
//using System.Configuration;
//using System.Data;
//using System.Data.SqlClient;

//namespace LearningManagementSystem.BL
//{
//    public class StudentBL
//    {
//        private readonly DataLayer _dl = new DataLayer();

//        // ══════════════════════════════════════════════════════════════════════
//        //  GET STUDENTS
//        // ══════════════════════════════════════════════════════════════════════
//        public DataTable GetStudents(
//            int instituteId, int sessionId,
//            string search = "", string status = "1", int streamId = 0)
//        {
//            string sql = @"
//                SELECT
//                    U.UserId,
//                    U.Email,
//                    U.IsActive,
//                    U.Username,
//                    ISNULL(UP.FullName, U.Username)   AS FullName,
//                    ISNULL(UP.ContactNo, '')           AS ContactNo,
//                    UP.Gender,
//                    UP.DOB,
//                    UP.JoinedDate,
//                    ISNULL(SAD.RollNumber, '')         AS RollNumber,
//                    SAD.StreamId,
//                    SAD.CourseId,
//                    SAD.LevelId,
//                    SAD.SemesterId,
//                    SAD.SectionId,
//                    ISNULL(SAD.IsReEnrolled, 0)        AS IsReEnrolled,
//                    ISNULL(St.StreamName,  '—')        AS StreamName,
//                    ISNULL(C.CourseName,   '—')        AS CourseName,
//                    ISNULL(SL.LevelName,   '—')        AS LevelName,
//                    ISNULL(Sem.SemesterName,'—')       AS SemesterName,
//                    ISNULL(Sec.SectionName, '—')       AS SectionName
//                FROM Users U
//                LEFT JOIN UserProfile UP
//                    ON U.UserId = UP.UserId
//                LEFT JOIN StudentAcademicDetails SAD
//                    ON U.UserId = SAD.UserId
//                    AND SAD.SessionId = @SessId
//                LEFT JOIN Streams     St  ON SAD.StreamId   = St.StreamId
//                LEFT JOIN Courses     C   ON SAD.CourseId   = C.CourseId
//                LEFT JOIN StudyLevels SL  ON SAD.LevelId    = SL.LevelId
//                LEFT JOIN Semesters   Sem ON SAD.SemesterId = Sem.SemesterId
//                LEFT JOIN Sections    Sec ON SAD.SectionId  = Sec.SectionId
//                WHERE U.RoleId = (SELECT TOP 1 RoleId FROM Roles WHERE RoleName='Student')
//                  AND U.InstituteId = @InstId and U.SessionId = @SessId";

//            var cmd = new SqlCommand();
//            cmd.Parameters.AddWithValue("@InstId", instituteId);
//            cmd.Parameters.AddWithValue("@SessId", sessionId);

//            if (status == "1" || status == "0")
//            {
//                sql += " AND U.IsActive = @Status";
//                cmd.Parameters.AddWithValue("@Status", status == "1" ? 1 : 0);
//            }

//            if (!string.IsNullOrWhiteSpace(search))
//            {
//                sql += @" AND (
//                    ISNULL(UP.FullName, U.Username) LIKE @Search
//                    OR ISNULL(SAD.RollNumber,'') LIKE @Search
//                    OR U.Email LIKE @Search
//                    OR U.Username LIKE @Search)";
//                cmd.Parameters.AddWithValue("@Search", "%" + search.Trim() + "%");
//            }

//            if (streamId > 0)
//            {
//                sql += " AND SAD.StreamId = @StreamId";
//                cmd.Parameters.AddWithValue("@StreamId", streamId);
//            }

//            sql += " ORDER BY ISNULL(UP.FullName, U.Username)";
//            cmd.CommandText = sql;
//            return _dl.GetDataTable(cmd) ?? new DataTable();
//        }

//        // Overload with no filter (used for view-modal index lookup)
//        public DataTable GetStudents(int instituteId, int sessionId)
//            => GetStudents(instituteId, sessionId, "", "All", 0);

//        // ══════════════════════════════════════════════════════════════════════
//        //  GET SINGLE STUDENT
//        // ══════════════════════════════════════════════════════════════════════
//        public DataRow GetStudentById(int userId, int sessionId)
//        {
//            var cmd = new SqlCommand(@"
//                SELECT
//                    U.UserId, U.Username, U.Email, U.IsActive,
//                    ISNULL(UP.FullName, U.Username)  AS FullName,
//                    ISNULL(UP.ContactNo, '')          AS ContactNo,
//                    ISNULL(UP.Gender, 'Male')         AS Gender,
//                    UP.DOB,
//                    UP.JoinedDate,
//                    ISNULL(SAD.RollNumber, '')        AS RollNumber,
//                    SAD.StreamId,   SAD.CourseId,
//                    SAD.LevelId,    SAD.SemesterId,   SAD.SectionId,
//                    ISNULL(St.StreamName,   '—')      AS StreamName,
//                    ISNULL(C.CourseName,    '—')      AS CourseName,
//                    ISNULL(SL.LevelName,    '—')      AS LevelName,
//                    ISNULL(Sem.SemesterName,'—')      AS SemesterName,
//                    ISNULL(Sec.SectionName, '—')      AS SectionName
//                FROM Users U
//                LEFT JOIN UserProfile UP
//                    ON U.UserId = UP.UserId
//                LEFT JOIN StudentAcademicDetails SAD
//                    ON U.UserId = SAD.UserId AND SAD.SessionId = @SessId
//                LEFT JOIN Streams     St  ON SAD.StreamId   = St.StreamId
//                LEFT JOIN Courses     C   ON SAD.CourseId   = C.CourseId
//                LEFT JOIN StudyLevels SL  ON SAD.LevelId    = SL.LevelId
//                LEFT JOIN Semesters   Sem ON SAD.SemesterId = Sem.SemesterId
//                LEFT JOIN Sections    Sec ON SAD.SectionId  = Sec.SectionId
//                WHERE U.UserId = @UserId");
//            cmd.Parameters.AddWithValue("@UserId", userId);
//            cmd.Parameters.AddWithValue("@SessId", sessionId);
//            DataTable dt = _dl.GetDataTable(cmd);
//            return dt != null && dt.Rows.Count > 0 ? dt.Rows[0] : null;
//        }

//        // ══════════════════════════════════════════════════════════════════════
//        //  CHECK: Does this student already have a parent linked?
//        // ══════════════════════════════════════════════════════════════════════
//        public bool HasParentLinked(int studentUserId, int sessionId)
//        {
//            var cmd = new SqlCommand(@"
//                SELECT COUNT(1)
//                FROM ParentStudentMapping
//                WHERE StudentUserId = @StudId
//                  AND SessionId     = @SessId
//                  AND IsActive      = 1");
//            cmd.Parameters.AddWithValue("@StudId", studentUserId);
//            cmd.Parameters.AddWithValue("@SessId", sessionId);
//            DataTable dt = _dl.GetDataTable(cmd);
//            return dt != null && dt.Rows.Count > 0 && Convert.ToInt32(dt.Rows[0][0]) > 0;
//        }

//        // ══════════════════════════════════════════════════════════════════════
//        //  DUPLICATE CHECK
//        // ══════════════════════════════════════════════════════════════════════
//        public bool StudentExists(
//            string username, string email, string rollNo,
//            int instituteId, int sessionId)
//        {
//            var cmd = new SqlCommand(@"
//                SELECT COUNT(*) FROM Users
//                WHERE InstituteId = @InstId
//                  AND (Username = @U OR Email = @E)");
//            cmd.Parameters.AddWithValue("@InstId", instituteId);
//            cmd.Parameters.AddWithValue("@U", username?.Trim() ?? "");
//            cmd.Parameters.AddWithValue("@E", email?.Trim() ?? "");
//            DataTable dt = _dl.GetDataTable(cmd);
//            if (dt != null && dt.Rows.Count > 0 && Convert.ToInt32(dt.Rows[0][0]) > 0)
//                return true;

//            if (!string.IsNullOrEmpty(rollNo))
//            {
//                var cmd2 = new SqlCommand(@"
//                    SELECT COUNT(*) FROM StudentAcademicDetails
//                    WHERE RollNumber = @R AND SessionId = @SessId");
//                cmd2.Parameters.AddWithValue("@R", rollNo.Trim());
//                cmd2.Parameters.AddWithValue("@SessId", sessionId);
//                DataTable dt2 = _dl.GetDataTable(cmd2);
//                if (dt2 != null && dt2.Rows.Count > 0 && Convert.ToInt32(dt2.Rows[0][0]) > 0)
//                    return true;
//            }
//            return false;
//        }

//        // ══════════════════════════════════════════════════════════════════════
//        //  INSERT STUDENT — returns new UserId so caller can show parent suggestion
//        // ══════════════════════════════════════════════════════════════════════
//        public int InsertStudent(
//            int societyId, int instituteId, int sessionId,
//            string username, string email, string fullName,
//            string gender, DateTime dob, string contact, string address,
//            int? streamId, int? levelId, int? semesterId,
//            int? courseId, int? sectionId,
//            string rollNo, int addedByUserId)
//        {
//            if (sessionId == 0)
//                throw new Exception("No active academic session. Please set a current session first.");

//            // ── Step 1: Insert into Users ─────────────────────────────────────
//            int newUserId;
//            using (var con = new SqlConnection(
//                ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString))
//            {
//                con.Open();
//                var cmd = new SqlCommand(@"
//                    INSERT INTO Users
//                        (Username, Email, PasswordHash, RoleId,
//                         SocietyId, InstituteId, SessionId,
//                         IsActive, IsFirstLogin, CreatedOn)
//                    VALUES
//                        (@Username, @Email,
//                         HASHBYTES('SHA2_256', 'Student@123'),
//                         (SELECT TOP 1 RoleId FROM Roles WHERE RoleName='Student'),
//                         @SocId, @InstId, @SessId,
//                         1, 1, GETDATE());
//                    SELECT CAST(SCOPE_IDENTITY() AS INT);", con);

//                cmd.Parameters.AddWithValue("@Username", username.Trim());
//                cmd.Parameters.AddWithValue("@Email", email.Trim());
//                cmd.Parameters.AddWithValue("@SocId", societyId);
//                cmd.Parameters.AddWithValue("@InstId", instituteId);
//                cmd.Parameters.AddWithValue("@SessId", sessionId);

//                object result = cmd.ExecuteScalar();
//                if (result == null || result == DBNull.Value)
//                    throw new Exception("Failed to create user account.");
//                newUserId = Convert.ToInt32(result);
//            }

//            // ── Steps 2+3+4 in one transaction ────────────────────────────────
//            var cmds = new List<SqlCommand>();

//            if (!string.IsNullOrWhiteSpace(fullName))
//            {
//                var profileCmd = new SqlCommand(@"
//                    IF NOT EXISTS (SELECT 1 FROM UserProfile WHERE UserId = @UserId)
//                    BEGIN
//                        INSERT INTO UserProfile
//                            (SocietyId, InstituteId, UserId,
//                             FullName, Gender, DOB, ContactNo, Address,
//                             EmergencyContactName, EmergencyContactNo,
//                             JoinedDate)
//                        VALUES
//                            (@SocId, @InstId, @UserId,
//                             @FullName, @Gender, @DOB, @Contact, @Address,
//                             'N/A', '0000000000',
//                             GETDATE())
//                    END");
//                profileCmd.Parameters.AddWithValue("@SocId", societyId);
//                profileCmd.Parameters.AddWithValue("@InstId", instituteId);
//                profileCmd.Parameters.AddWithValue("@UserId", newUserId);
//                profileCmd.Parameters.AddWithValue("@FullName", fullName.Trim());
//                profileCmd.Parameters.AddWithValue("@Gender", gender ?? "Male");
//                profileCmd.Parameters.AddWithValue("@DOB", (object)dob);
//                profileCmd.Parameters.AddWithValue("@Contact", contact ?? "");
//                profileCmd.Parameters.AddWithValue("@Address", address ?? "");
//                cmds.Add(profileCmd);
//            }

//            var acadCmd = new SqlCommand(@"
//                IF NOT EXISTS (
//                    SELECT 1 FROM StudentAcademicDetails
//                    WHERE UserId = @UserId AND SessionId = @SessId
//                )
//                BEGIN
//                    INSERT INTO StudentAcademicDetails
//                        (UserId, SocietyId, InstituteId, SessionId,
//                         StreamId, CourseId, LevelId, SemesterId, SectionId,
//                         RollNumber, IsReEnrolled)
//                    VALUES
//                        (@UserId, @SocId, @InstId, @SessId,
//                         @StreamId, @CourseId, @LevelId, @SemId, @SecId,
//                         @RollNo, 0)
//                END");
//            acadCmd.Parameters.AddWithValue("@UserId", newUserId);
//            acadCmd.Parameters.AddWithValue("@SocId", societyId);
//            acadCmd.Parameters.AddWithValue("@InstId", instituteId);
//            acadCmd.Parameters.AddWithValue("@SessId", sessionId);
//            acadCmd.Parameters.AddWithValue("@StreamId", (object)streamId ?? DBNull.Value);
//            acadCmd.Parameters.AddWithValue("@CourseId", (object)courseId ?? DBNull.Value);
//            acadCmd.Parameters.AddWithValue("@LevelId", (object)levelId ?? DBNull.Value);
//            acadCmd.Parameters.AddWithValue("@SemId", (object)semesterId ?? DBNull.Value);
//            acadCmd.Parameters.AddWithValue("@SecId", (object)sectionId ?? DBNull.Value);
//            acadCmd.Parameters.AddWithValue("@RollNo", rollNo ?? "");
//            cmds.Add(acadCmd);

//            var logCmd = new SqlCommand(@"
//                INSERT INTO UserActivityLog
//                    (UserId, SocietyId, InstituteId, SessionId,
//                     ActivityType, ReferenceId, ActionTime)
//                VALUES
//                    (@AddedBy, @SocId, @InstId, @SessId,
//                     'StudentAdded', @NewId, GETDATE())");
//            logCmd.Parameters.AddWithValue("@AddedBy", addedByUserId);
//            logCmd.Parameters.AddWithValue("@SocId", societyId);
//            logCmd.Parameters.AddWithValue("@InstId", instituteId);
//            logCmd.Parameters.AddWithValue("@SessId", sessionId);
//            logCmd.Parameters.AddWithValue("@NewId", newUserId);
//            cmds.Add(logCmd);

//            _dl.ExecuteTransaction(cmds);

//            return newUserId; // ← Return so caller can show parent suggestion
//        }

//        // ══════════════════════════════════════════════════════════════════════
//        //  UPDATE STUDENT
//        // ══════════════════════════════════════════════════════════════════════
//        public void UpdateStudent(
//            int userId, int sessionId,
//            string email, string fullName, string contact, string rollNo,
//            string gender, DateTime? dob,
//            int? streamId, int? courseId, int? levelId,
//            int? semesterId, int? sectionId)
//        {
//            var cmds = new List<SqlCommand>();

//            var uCmd = new SqlCommand(
//                "UPDATE Users SET Email=@Email WHERE UserId=@UserId");
//            uCmd.Parameters.AddWithValue("@Email", email.Trim());
//            uCmd.Parameters.AddWithValue("@UserId", userId);
//            cmds.Add(uCmd);

//            var pCmd = new SqlCommand(@"
//                IF EXISTS (SELECT 1 FROM UserProfile WHERE UserId=@UserId)
//                BEGIN
//                    UPDATE UserProfile
//                    SET FullName=@FullName, ContactNo=@Contact,
//                        Gender=@Gender, DOB=@DOB
//                    WHERE UserId=@UserId
//                END
//                ELSE
//                BEGIN
//                    INSERT INTO UserProfile
//                        (UserId, FullName, ContactNo, Gender, DOB,
//                         EmergencyContactName, EmergencyContactNo, JoinedDate)
//                    VALUES
//                        (@UserId, @FullName, @Contact, @Gender, @DOB,
//                         'N/A', '0000000000', GETDATE())
//                END");
//            pCmd.Parameters.AddWithValue("@FullName", fullName.Trim());
//            pCmd.Parameters.AddWithValue("@Contact", contact ?? "");
//            pCmd.Parameters.AddWithValue("@Gender", gender ?? "Male");
//            pCmd.Parameters.AddWithValue("@DOB", dob.HasValue ? (object)dob.Value : DBNull.Value);
//            pCmd.Parameters.AddWithValue("@UserId", userId);
//            cmds.Add(pCmd);

//            var aCmd = new SqlCommand(@"
//                IF EXISTS (SELECT 1 FROM StudentAcademicDetails WHERE UserId=@UserId AND SessionId=@SessId)
//                BEGIN
//                    UPDATE StudentAcademicDetails
//                    SET RollNumber=@RollNo, StreamId=@StreamId,
//                        CourseId=@CourseId, LevelId=@LevelId,
//                        SemesterId=@SemId,  SectionId=@SecId
//                    WHERE UserId=@UserId AND SessionId=@SessId
//                END
//                ELSE
//                BEGIN
//                    INSERT INTO StudentAcademicDetails
//                        (UserId, SessionId, RollNumber, StreamId,
//                         CourseId, LevelId, SemesterId, SectionId, IsReEnrolled)
//                    VALUES
//                        (@UserId, @SessId, @RollNo, @StreamId,
//                         @CourseId, @LevelId, @SemId, @SecId, 0)
//                END");
//            aCmd.Parameters.AddWithValue("@RollNo", rollNo ?? "");
//            aCmd.Parameters.AddWithValue("@StreamId", (object)streamId ?? DBNull.Value);
//            aCmd.Parameters.AddWithValue("@CourseId", (object)courseId ?? DBNull.Value);
//            aCmd.Parameters.AddWithValue("@LevelId", (object)levelId ?? DBNull.Value);
//            aCmd.Parameters.AddWithValue("@SemId", (object)semesterId ?? DBNull.Value);
//            aCmd.Parameters.AddWithValue("@SecId", (object)sectionId ?? DBNull.Value);
//            aCmd.Parameters.AddWithValue("@UserId", userId);
//            aCmd.Parameters.AddWithValue("@SessId", sessionId);
//            cmds.Add(aCmd);

//            _dl.ExecuteTransaction(cmds);
//        }

//        // ══════════════════════════════════════════════════════════════════════
//        //  RE-ENROL STUDENT — also triggers parent auto re-enroll
//        // ══════════════════════════════════════════════════════════════════════
//        public void ReEnrolStudent(
//            int userId, int societyId, int instituteId, int targetSessionId,
//            int? streamId, int? courseId, int? levelId,
//            int? semesterId, int? sectionId,
//            string rollNo, int enrolledByUserId)
//        {
//            var cmds = new List<SqlCommand>();

//            var acadCmd = new SqlCommand(@"
//                INSERT INTO StudentAcademicDetails
//                    (UserId, SocietyId, InstituteId, SessionId,
//                     StreamId, CourseId, LevelId, SemesterId, SectionId,
//                     RollNumber, IsReEnrolled)
//                VALUES
//                    (@UserId, @SocId, @InstId, @SessId,
//                     @StreamId, @CourseId, @LevelId, @SemId, @SecId,
//                     @RollNo, 1)");
//            acadCmd.Parameters.AddWithValue("@UserId", userId);
//            acadCmd.Parameters.AddWithValue("@SocId", societyId);
//            acadCmd.Parameters.AddWithValue("@InstId", instituteId);
//            acadCmd.Parameters.AddWithValue("@SessId", targetSessionId);
//            acadCmd.Parameters.AddWithValue("@StreamId", (object)streamId ?? DBNull.Value);
//            acadCmd.Parameters.AddWithValue("@CourseId", (object)courseId ?? DBNull.Value);
//            acadCmd.Parameters.AddWithValue("@LevelId", (object)levelId ?? DBNull.Value);
//            acadCmd.Parameters.AddWithValue("@SemId", (object)semesterId ?? DBNull.Value);
//            acadCmd.Parameters.AddWithValue("@SecId", (object)sectionId ?? DBNull.Value);
//            acadCmd.Parameters.AddWithValue("@RollNo", rollNo ?? "");
//            cmds.Add(acadCmd);

//            var logCmd = new SqlCommand(@"
//                INSERT INTO UserActivityLog
//                    (UserId, SocietyId, InstituteId, SessionId,
//                     ActivityType, ReferenceId, ActionTime)
//                VALUES
//                    (@By, @SocId, @InstId, @SessId,
//                     'StudentReEnrolled', @UserId, GETDATE())");
//            logCmd.Parameters.AddWithValue("@By", enrolledByUserId);
//            logCmd.Parameters.AddWithValue("@SocId", societyId);
//            logCmd.Parameters.AddWithValue("@InstId", instituteId);
//            logCmd.Parameters.AddWithValue("@SessId", targetSessionId);
//            logCmd.Parameters.AddWithValue("@UserId", userId);
//            cmds.Add(logCmd);

//            _dl.ExecuteTransaction(cmds);

//            // ── Auto Re-Enroll linked parents via stored procedure ─────────────
//            AutoReEnrollParents(userId, targetSessionId, societyId, instituteId);
//        }

//        // ══════════════════════════════════════════════════════════════════════
//        //  AUTO RE-ENROLL PARENTS (calls the stored procedure)
//        // ══════════════════════════════════════════════════════════════════════
//        public int AutoReEnrollParents(int studentUserId, int newSessionId, int societyId, int instituteId)
//        {
//            try
//            {
//                using (var con = new SqlConnection(
//                    ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString))
//                {
//                    con.Open();
//                    var cmd = new SqlCommand("sp_AutoReEnrollParentsForStudent", con)
//                    {
//                        CommandType = CommandType.StoredProcedure
//                    };
//                    cmd.Parameters.AddWithValue("@StudentUserId", studentUserId);
//                    cmd.Parameters.AddWithValue("@NewSessionId", newSessionId);
//                    cmd.Parameters.AddWithValue("@SocietyId", societyId);
//                    cmd.Parameters.AddWithValue("@InstituteId", instituteId);
//                    cmd.ExecuteNonQuery();
//                }

//                // Count how many parents were re-enrolled
//                var countCmd = new SqlCommand(@"
//                    SELECT COUNT(1) FROM ParentStudentMapping
//                    WHERE StudentUserId = @StudId
//                      AND SessionId     = @SessId
//                      AND IsReEnrolled  = 1");
//                countCmd.Parameters.AddWithValue("@StudId", studentUserId);
//                countCmd.Parameters.AddWithValue("@SessId", newSessionId);
//                DataTable dt = _dl.GetDataTable(countCmd);
//                return dt != null && dt.Rows.Count > 0 ? Convert.ToInt32(dt.Rows[0][0]) : 0;
//            }
//            catch (Exception ex)
//            {
//                // Non-critical — log but don't throw (student re-enrolment already succeeded)
//                System.Diagnostics.Debug.WriteLine("[AutoReEnrollParents] " + ex.Message);
//                return 0;
//            }
//        }

//        // ══════════════════════════════════════════════════════════════════════
//        //  GET PARENT COUNT for a student in a session (for suggestion banner)
//        // ══════════════════════════════════════════════════════════════════════
//        public int GetParentCountForStudent(int studentUserId, int sessionId)
//        {
//            var cmd = new SqlCommand(@"
//                SELECT COUNT(1)
//                FROM ParentStudentMapping
//                WHERE StudentUserId = @StudId
//                  AND SessionId     = @SessId
//                  AND IsActive      = 1");
//            cmd.Parameters.AddWithValue("@StudId", studentUserId);
//            cmd.Parameters.AddWithValue("@SessId", sessionId);
//            DataTable dt = _dl.GetDataTable(cmd);
//            return dt != null && dt.Rows.Count > 0 ? Convert.ToInt32(dt.Rows[0][0]) : 0;
//        }

//        // ══════════════════════════════════════════════════════════════════════
//        //  DELETE STUDENT
//        // ══════════════════════════════════════════════════════════════════════
//        public void DeleteStudent(int userId, int sessionId)
//        {
//            var a = new SqlCommand(
//                "DELETE FROM StudentAcademicDetails WHERE UserId=@Id AND SessionId=@Sess");
//            a.Parameters.AddWithValue("@Id", userId);
//            a.Parameters.AddWithValue("@Sess", sessionId);
//            _dl.ExecuteCMD(a);

//            var chk = new SqlCommand(
//                "SELECT COUNT(*) FROM StudentAcademicDetails WHERE UserId=@Id");
//            chk.Parameters.AddWithValue("@Id", userId);
//            DataTable dt = _dl.GetDataTable(chk);
//            int others = dt != null && dt.Rows.Count > 0 ? Convert.ToInt32(dt.Rows[0][0]) : 0;

//            if (others == 0)
//            {
//                var cmds = new List<SqlCommand>();
//                var p = new SqlCommand("DELETE FROM UserProfile WHERE UserId=@Id");
//                p.Parameters.AddWithValue("@Id", userId);
//                cmds.Add(p);
//                var u = new SqlCommand("DELETE FROM Users WHERE UserId=@Id");
//                u.Parameters.AddWithValue("@Id", userId);
//                cmds.Add(u);
//                _dl.ExecuteTransaction(cmds);
//            }
//        }

//        // ══════════════════════════════════════════════════════════════════════
//        //  TOGGLE ACTIVE / INACTIVE
//        // ══════════════════════════════════════════════════════════════════════
//        public bool ToggleStudent(int userId)
//        {
//            var cmd = new SqlCommand(@"
//                UPDATE Users
//                SET IsActive = CASE WHEN IsActive=1 THEN 0 ELSE 1 END
//                OUTPUT INSERTED.IsActive
//                WHERE UserId=@Id");
//            cmd.Parameters.AddWithValue("@Id", userId);
//            DataTable dt = _dl.GetDataTable(cmd);
//            return dt != null && dt.Rows.Count > 0 && Convert.ToBoolean(dt.Rows[0][0]);
//        }

//        // ══════════════════════════════════════════════════════════════════════
//        //  CHECK ENROLMENT IN SESSION
//        // ══════════════════════════════════════════════════════════════════════
//        public bool IsStudentEnrolledInSession(int userId, int sessionId)
//        {
//            var cmd = new SqlCommand(@"
//                SELECT COUNT(*) FROM StudentAcademicDetails
//                WHERE UserId=@UserId AND SessionId=@SessId");
//            cmd.Parameters.AddWithValue("@UserId", userId);
//            cmd.Parameters.AddWithValue("@SessId", sessionId);
//            DataTable dt = _dl.GetDataTable(cmd);
//            return dt != null && dt.Rows.Count > 0 && Convert.ToInt32(dt.Rows[0][0]) > 0;
//        }

//        // ══════════════════════════════════════════════════════════════════════
//        //  STATS
//        // ══════════════════════════════════════════════════════════════════════
//        public DataTable GetStudentStats(int instituteId, int sessionId)
//        {
//            var cmd = new SqlCommand(@"
//                SELECT
//                    COUNT(*)                                                         AS Total,
//                    SUM(CASE WHEN U.IsActive=1 THEN 1 ELSE 0 END)                   AS Active,
//                    SUM(CASE WHEN U.IsActive=0 THEN 1 ELSE 0 END)                   AS Inactive,
//                    SUM(CASE WHEN MONTH(U.CreatedOn)=MONTH(GETDATE())
//                                  AND YEAR(U.CreatedOn)=YEAR(GETDATE())
//                             THEN 1 ELSE 0 END)                                     AS NewStudents,
//                    SUM(CASE WHEN ISNULL(SAD.IsReEnrolled,0)=1 THEN 1 ELSE 0 END)   AS ReEnrolled
//                FROM Users U
//                LEFT JOIN StudentAcademicDetails SAD
//                    ON U.UserId = SAD.UserId AND SAD.SessionId = @SessId
//                WHERE U.RoleId = (SELECT TOP 1 RoleId FROM Roles WHERE RoleName='Student')
//                  AND U.InstituteId = @InstId");
//            cmd.Parameters.AddWithValue("@InstId", instituteId);
//            cmd.Parameters.AddWithValue("@SessId", sessionId);
//            return _dl.GetDataTable(cmd) ?? new DataTable();
//        }

//        public DataTable GetStudentStatsByStreamCourse(int instituteId, int sessionId)
//        {
//            var cmd = new SqlCommand(@"
//                SELECT
//                    ISNULL(St.StreamName,'No Stream') AS StreamName,
//                    ISNULL(C.CourseName, 'No Course')  AS CourseName,
//                    COUNT(*)                            AS TotalStudents
//                FROM Users U
//                LEFT JOIN StudentAcademicDetails SAD
//                    ON U.UserId = SAD.UserId AND SAD.SessionId = @SessId
//                LEFT JOIN Streams     St ON SAD.StreamId = St.StreamId
//                LEFT JOIN Courses     C  ON SAD.CourseId = C.CourseId
//                WHERE U.RoleId = (SELECT TOP 1 RoleId FROM Roles WHERE RoleName='Student')
//                  AND U.InstituteId = @InstId
//                  AND U.IsActive = 1
//                GROUP BY St.StreamName, C.CourseName
//                ORDER BY TotalStudents DESC");
//            cmd.Parameters.AddWithValue("@InstId", instituteId);
//            cmd.Parameters.AddWithValue("@SessId", sessionId);
//            return _dl.GetDataTable(cmd) ?? new DataTable();
//        }

//        // ══════════════════════════════════════════════════════════════════════
//        //  ACADEMIC DROPDOWN LOADERS
//        // ══════════════════════════════════════════════════════════════════════
//        public DataTable GetStreams(int instituteId, int sessionId)
//        {
//            var cmd = new SqlCommand(@"
//                SELECT StreamId, StreamName FROM Streams
//                WHERE InstituteId=@InstId AND SessionId=@SessId AND IsActive=1
//                ORDER BY StreamName");
//            cmd.Parameters.AddWithValue("@InstId", instituteId);
//            cmd.Parameters.AddWithValue("@SessId", sessionId);
//            return _dl.GetDataTable(cmd) ?? new DataTable();
//        }

//        public DataTable GetCourses(int instituteId, int sessionId)
//        {
//            var cmd = new SqlCommand(@"
//                SELECT CourseId, CourseName FROM Courses
//                WHERE InstituteId=@InstId AND SessionId=@SessId AND IsActive=1
//                ORDER BY CourseName");
//            cmd.Parameters.AddWithValue("@InstId", instituteId);
//            cmd.Parameters.AddWithValue("@SessId", sessionId);
//            return _dl.GetDataTable(cmd) ?? new DataTable();
//        }

//        public DataTable GetCoursesByStream(int instituteId, int sessionId, int streamId)
//        {
//            var cmd = new SqlCommand(@"
//                SELECT CourseId, CourseName FROM Courses
//                WHERE InstituteId=@InstId AND SessionId=@SessId
//                  AND StreamId=@StreamId AND IsActive=1
//                ORDER BY CourseName");
//            cmd.Parameters.AddWithValue("@InstId", instituteId);
//            cmd.Parameters.AddWithValue("@SessId", sessionId);
//            cmd.Parameters.AddWithValue("@StreamId", streamId);
//            return _dl.GetDataTable(cmd) ?? new DataTable();
//        }

//        public DataTable GetStudyLevels(int instituteId, int sessionId)
//        {
//            var cmd = new SqlCommand(@"
//                SELECT LevelId, LevelName FROM StudyLevels
//                WHERE InstituteId=@InstId AND SessionId=@SessId
//                ORDER BY LevelName");
//            cmd.Parameters.AddWithValue("@InstId", instituteId);
//            cmd.Parameters.AddWithValue("@SessId", sessionId);
//            return _dl.GetDataTable(cmd) ?? new DataTable();
//        }

//        public DataTable GetSemesters(int instituteId, int sessionId)
//        {
//            var cmd = new SqlCommand(@"
//                SELECT SemesterId, SemesterName FROM Semesters
//                WHERE InstituteId=@InstId AND SessionId=@SessId
//                ORDER BY SemesterName");
//            cmd.Parameters.AddWithValue("@InstId", instituteId);
//            cmd.Parameters.AddWithValue("@SessId", sessionId);
//            return _dl.GetDataTable(cmd) ?? new DataTable();
//        }

//        public DataTable GetSections(int instituteId, int sessionId)
//        {
//            var cmd = new SqlCommand(@"
//                SELECT SectionId, SectionName FROM Sections
//                WHERE InstituteId=@InstId AND SessionId=@SessId AND IsActive=1
//                ORDER BY SectionName");
//            cmd.Parameters.AddWithValue("@InstId", instituteId);
//            cmd.Parameters.AddWithValue("@SessId", sessionId);
//            return _dl.GetDataTable(cmd) ?? new DataTable();
//        }

//        public DataTable GetAllSessions(int instituteId)
//        {
//            var cmd = new SqlCommand(@"
//                SELECT SessionId, SessionName, IsCurrent
//                FROM AcademicSessions
//                WHERE InstituteId=@InstId
//                ORDER BY CreatedOn DESC");
//            cmd.Parameters.AddWithValue("@InstId", instituteId);
//            return _dl.GetDataTable(cmd) ?? new DataTable();
//        }

//        public int GetCurrentSessionId(int instituteId)
//        {
//            var cmd = new SqlCommand(@"
//                SELECT TOP 1 SessionId FROM AcademicSessions
//                WHERE InstituteId=@InstId AND IsCurrent=1");
//            cmd.Parameters.AddWithValue("@InstId", instituteId);
//            DataTable dt = _dl.GetDataTable(cmd);
//            return dt != null && dt.Rows.Count > 0
//                ? Convert.ToInt32(dt.Rows[0]["SessionId"]) : 0;
//        }
//    }
//}


//---------------------------------------------------------------------------------------------------------------------------------------------

using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace LearningManagementSystem.BL
{
    public class StudentBL
    {
        private readonly DataLayer _dl = new DataLayer();

        // ══════════════════════════════════════════════════════════════════════
        //  GET STUDENTS
        //
        //  ROOT CAUSE OF BUG (and fix):
        //
        //  OLD (broken):
        //      LEFT JOIN StudentAcademicDetails SAD ON SAD.UserId = U.UserId
        //                                          AND SAD.SessionId = @SessId
        //      WHERE ... AND U.SessionId = @SessId          ← THIS IS WRONG
        //
        //  WHY IT BROKE re-enrolled students:
        //      When a student is re-enrolled, a new row is inserted in
        //      StudentAcademicDetails with the NEW session id.
        //      BUT the Users table row still has the ORIGINAL session id
        //      (Users.SessionId is set at account creation and never updated).
        //      So filtering "AND U.SessionId = @SessId" excluded re-enrolled
        //      students from the list for the new session.
        //
        //  FIX:
        //      Change LEFT JOIN → INNER JOIN on StudentAcademicDetails
        //      (SAD.SessionId = @SessId) and REMOVE the U.SessionId filter.
        //      This correctly shows every student who has an academic record
        //      in the selected session, whether original or re-enrolled.
        // ══════════════════════════════════════════════════════════════════════
        public DataTable GetStudents(
            int instituteId, int sessionId,
            string search = "", string status = "1", int streamId = 0)
        {
            string sql = @"
                SELECT
                    U.UserId,
                    U.Email,
                    U.IsActive,
                    U.Username,
                    ISNULL(UP.FullName,     U.Username) AS FullName,
                    ISNULL(UP.ContactNo,    '')          AS ContactNo,
                    UP.Gender,
                    UP.DOB,
                    UP.JoinedDate,
                    ISNULL(SAD.RollNumber,  '')          AS RollNumber,
                    SAD.StreamId,
                    SAD.CourseId,
                    SAD.LevelId,
                    SAD.SemesterId,
                    SAD.SectionId,
                    ISNULL(SAD.IsReEnrolled, 0)          AS IsReEnrolled,
                    ISNULL(St.StreamName,   N'—')        AS StreamName,
                    ISNULL(C.CourseName,    N'—')        AS CourseName,
                    ISNULL(SL.LevelName,    N'—')        AS LevelName,
                    ISNULL(Sem.SemesterName,N'—')        AS SemesterName,
                    ISNULL(Sec.SectionName, N'—')        AS SectionName
                FROM Users U

                -- LEFT JOIN so students without a UserProfile still appear
                LEFT JOIN UserProfile UP
                    ON UP.UserId = U.UserId

                -- ★ INNER JOIN on SAD.SessionId — KEY FIX ★
                -- This is the only reliable way to scope students to a session.
                -- Users.SessionId reflects account-creation session only and is
                -- NEVER updated on re-enrolment, so we must NOT filter on it.
                INNER JOIN StudentAcademicDetails SAD
                    ON  SAD.UserId    = U.UserId
                    AND SAD.SessionId = @SessId

                LEFT JOIN Streams     St  ON St.StreamId    = SAD.StreamId
                LEFT JOIN Courses     C   ON C.CourseId     = SAD.CourseId
                LEFT JOIN StudyLevels SL  ON SL.LevelId     = SAD.LevelId
                LEFT JOIN Semesters   Sem ON Sem.SemesterId  = SAD.SemesterId
                LEFT JOIN Sections    Sec ON Sec.SectionId   = SAD.SectionId

                WHERE U.RoleId = (SELECT TOP 1 RoleId FROM Roles WHERE RoleName = 'Student')
                  AND U.InstituteId = @InstId";

            var cmd = new SqlCommand();
            cmd.Parameters.AddWithValue("@InstId", instituteId);
            cmd.Parameters.AddWithValue("@SessId", sessionId);

            // Active / Inactive filter
            if (status == "1" || status == "0")
            {
                sql += " AND U.IsActive = @Status";
                cmd.Parameters.AddWithValue("@Status", status == "1" ? 1 : 0);
            }

            // Text search
            if (!string.IsNullOrWhiteSpace(search))
            {
                sql += @" AND (
                    ISNULL(UP.FullName, U.Username) LIKE @Search
                    OR ISNULL(SAD.RollNumber, '') LIKE @Search
                    OR U.Email    LIKE @Search
                    OR U.Username LIKE @Search)";
                cmd.Parameters.AddWithValue("@Search", "%" + search.Trim() + "%");
            }

            // Stream filter
            if (streamId > 0)
            {
                sql += " AND SAD.StreamId = @StreamId";
                cmd.Parameters.AddWithValue("@StreamId", streamId);
            }

            sql += " ORDER BY ISNULL(UP.FullName, U.Username)";
            cmd.CommandText = sql;
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        // Overload — no filter (used for view-modal index lookup)
        public DataTable GetStudents(int instituteId, int sessionId)
            => GetStudents(instituteId, sessionId, "", "All", 0);

        // ══════════════════════════════════════════════════════════════════════
        //  GET SINGLE STUDENT (Edit / View / Re-enrol)
        // ══════════════════════════════════════════════════════════════════════
        public DataRow GetStudentById(int userId, int sessionId)
        {
            var cmd = new SqlCommand(@"
                SELECT
                    U.UserId, U.Username, U.Email, U.IsActive,
                    ISNULL(UP.FullName,    U.Username) AS FullName,
                    ISNULL(UP.ContactNo,   '')          AS ContactNo,
                    ISNULL(UP.Gender,      'Male')      AS Gender,
                    UP.DOB,
                    UP.JoinedDate,
                    ISNULL(SAD.RollNumber, '')           AS RollNumber,
                    SAD.StreamId,  SAD.CourseId,
                    SAD.LevelId,   SAD.SemesterId,  SAD.SectionId,
                    ISNULL(St.StreamName,   N'—')        AS StreamName,
                    ISNULL(C.CourseName,    N'—')        AS CourseName,
                    ISNULL(SL.LevelName,    N'—')        AS LevelName,
                    ISNULL(Sem.SemesterName,N'—')        AS SemesterName,
                    ISNULL(Sec.SectionName, N'—')        AS SectionName
                FROM Users U
                LEFT JOIN UserProfile UP
                    ON UP.UserId = U.UserId
                LEFT JOIN StudentAcademicDetails SAD
                    ON  SAD.UserId    = U.UserId
                    AND SAD.SessionId = @SessId
                LEFT JOIN Streams     St  ON St.StreamId    = SAD.StreamId
                LEFT JOIN Courses     C   ON C.CourseId     = SAD.CourseId
                LEFT JOIN StudyLevels SL  ON SL.LevelId     = SAD.LevelId
                LEFT JOIN Semesters   Sem ON Sem.SemesterId  = SAD.SemesterId
                LEFT JOIN Sections    Sec ON Sec.SectionId   = SAD.SectionId
                WHERE U.UserId = @UserId");
            cmd.Parameters.AddWithValue("@UserId", userId);
            cmd.Parameters.AddWithValue("@SessId", sessionId);
            DataTable dt = _dl.GetDataTable(cmd);
            return dt != null && dt.Rows.Count > 0 ? dt.Rows[0] : null;
        }

        // ══════════════════════════════════════════════════════════════════════
        //  CHECK: parent linked for a student in a given session
        // ══════════════════════════════════════════════════════════════════════
        public bool HasParentLinked(int studentUserId, int sessionId)
        {
            var cmd = new SqlCommand(@"
                SELECT COUNT(1)
                FROM ParentStudentMapping
                WHERE StudentUserId = @StudId
                  AND SessionId     = @SessId
                  AND IsActive      = 1");
            cmd.Parameters.AddWithValue("@StudId", studentUserId);
            cmd.Parameters.AddWithValue("@SessId", sessionId);
            DataTable dt = _dl.GetDataTable(cmd);
            return dt != null && dt.Rows.Count > 0 && Convert.ToInt32(dt.Rows[0][0]) > 0;
        }

        // ══════════════════════════════════════════════════════════════════════
        //  DUPLICATE CHECK
        // ══════════════════════════════════════════════════════════════════════
        public bool StudentExists(
            string username, string email, string rollNo,
            int instituteId, int sessionId)
        {
            // Username / email are institute-wide unique
            var cmd = new SqlCommand(@"
                SELECT COUNT(*) FROM Users
                WHERE InstituteId = @InstId
                  AND (Username = @U OR Email = @E)");
            cmd.Parameters.AddWithValue("@InstId", instituteId);
            cmd.Parameters.AddWithValue("@U", username?.Trim() ?? "");
            cmd.Parameters.AddWithValue("@E", email?.Trim() ?? "");
            DataTable dt = _dl.GetDataTable(cmd);
            if (dt != null && dt.Rows.Count > 0 && Convert.ToInt32(dt.Rows[0][0]) > 0)
                return true;

            // Roll number is unique per session
            if (!string.IsNullOrEmpty(rollNo))
            {
                var cmd2 = new SqlCommand(@"
                    SELECT COUNT(*) FROM StudentAcademicDetails
                    WHERE RollNumber = @R AND SessionId = @SessId");
                cmd2.Parameters.AddWithValue("@R", rollNo.Trim());
                cmd2.Parameters.AddWithValue("@SessId", sessionId);
                DataTable dt2 = _dl.GetDataTable(cmd2);
                if (dt2 != null && dt2.Rows.Count > 0 && Convert.ToInt32(dt2.Rows[0][0]) > 0)
                    return true;
            }
            return false;
        }

        // ══════════════════════════════════════════════════════════════════════
        //  INSERT STUDENT — returns new UserId for parent-suggestion banner
        // ══════════════════════════════════════════════════════════════════════
        public int InsertStudent(
            int societyId, int instituteId, int sessionId,
            string username, string email, string fullName,
            string gender, DateTime dob, string contact, string address,
            int? streamId, int? levelId, int? semesterId,
            int? courseId, int? sectionId,
            string rollNo, int addedByUserId)
        {
            if (sessionId == 0)
                throw new Exception("No active academic session. Please set a current session first.");

            // ── Step 1: Insert into Users ──────────────────────────────────────
            int newUserId;
            using (var con = new SqlConnection(
                ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString))
            {
                con.Open();
                var insertCmd = new SqlCommand(@"
                    INSERT INTO Users
                        (Username, Email, PasswordHash, RoleId,
                         SocietyId, InstituteId, SessionId,
                         IsActive, IsFirstLogin, CreatedOn)
                    VALUES
                        (@Username, @Email,
                         HASHBYTES('SHA2_256', 'Student@123'),
                         (SELECT TOP 1 RoleId FROM Roles WHERE RoleName = 'Student'),
                         @SocId, @InstId, @SessId,
                         1, 1, GETDATE());
                    SELECT CAST(SCOPE_IDENTITY() AS INT);", con);

                insertCmd.Parameters.AddWithValue("@Username", username.Trim());
                insertCmd.Parameters.AddWithValue("@Email", email.Trim());
                insertCmd.Parameters.AddWithValue("@SocId", societyId);
                insertCmd.Parameters.AddWithValue("@InstId", instituteId);
                insertCmd.Parameters.AddWithValue("@SessId", sessionId);

                object result = insertCmd.ExecuteScalar();
                if (result == null || result == DBNull.Value)
                    throw new Exception("Failed to create user account.");
                newUserId = Convert.ToInt32(result);
            }

            // ── Steps 2 + 3 + 4 in one transaction ────────────────────────────
            var cmds = new List<SqlCommand>();

            // 2. UserProfile
            if (!string.IsNullOrWhiteSpace(fullName))
            {
                var profileCmd = new SqlCommand(@"
                    IF NOT EXISTS (SELECT 1 FROM UserProfile WHERE UserId = @UserId)
                    BEGIN
                        INSERT INTO UserProfile
                            (SocietyId, InstituteId, UserId,
                             FullName, Gender, DOB, ContactNo, Address,
                             EmergencyContactName, EmergencyContactNo, JoinedDate)
                        VALUES
                            (@SocId, @InstId, @UserId,
                             @FullName, @Gender, @DOB, @Contact, @Address,
                             'N/A', '0000000000', GETDATE())
                    END");
                profileCmd.Parameters.AddWithValue("@SocId", societyId);
                profileCmd.Parameters.AddWithValue("@InstId", instituteId);
                profileCmd.Parameters.AddWithValue("@UserId", newUserId);
                profileCmd.Parameters.AddWithValue("@FullName", fullName.Trim());
                profileCmd.Parameters.AddWithValue("@Gender", gender ?? "Male");
                profileCmd.Parameters.AddWithValue("@DOB", (object)dob);
                profileCmd.Parameters.AddWithValue("@Contact", contact ?? "");
                profileCmd.Parameters.AddWithValue("@Address", address ?? "");
                cmds.Add(profileCmd);
            }

            // 3. StudentAcademicDetails
            var acadCmd = new SqlCommand(@"
                IF NOT EXISTS (
                    SELECT 1 FROM StudentAcademicDetails
                    WHERE UserId = @UserId AND SessionId = @SessId)
                BEGIN
                    INSERT INTO StudentAcademicDetails
                        (UserId, SocietyId, InstituteId, SessionId,
                         StreamId, CourseId, LevelId, SemesterId, SectionId,
                         RollNumber, IsReEnrolled)
                    VALUES
                        (@UserId, @SocId, @InstId, @SessId,
                         @StreamId, @CourseId, @LevelId, @SemId, @SecId,
                         @RollNo, 0)
                END");
            acadCmd.Parameters.AddWithValue("@UserId", newUserId);
            acadCmd.Parameters.AddWithValue("@SocId", societyId);
            acadCmd.Parameters.AddWithValue("@InstId", instituteId);
            acadCmd.Parameters.AddWithValue("@SessId", sessionId);
            acadCmd.Parameters.AddWithValue("@StreamId", (object)streamId ?? DBNull.Value);
            acadCmd.Parameters.AddWithValue("@CourseId", (object)courseId ?? DBNull.Value);
            acadCmd.Parameters.AddWithValue("@LevelId", (object)levelId ?? DBNull.Value);
            acadCmd.Parameters.AddWithValue("@SemId", (object)semesterId ?? DBNull.Value);
            acadCmd.Parameters.AddWithValue("@SecId", (object)sectionId ?? DBNull.Value);
            acadCmd.Parameters.AddWithValue("@RollNo", rollNo ?? "");
            cmds.Add(acadCmd);

            // 4. Activity log
            var logCmd = new SqlCommand(@"
                INSERT INTO UserActivityLog
                    (UserId, SocietyId, InstituteId, SessionId,
                     ActivityType, ReferenceId, ActionTime)
                VALUES
                    (@AddedBy, @SocId, @InstId, @SessId, 'StudentAdded', @NewId, GETDATE())");
            logCmd.Parameters.AddWithValue("@AddedBy", addedByUserId);
            logCmd.Parameters.AddWithValue("@SocId", societyId);
            logCmd.Parameters.AddWithValue("@InstId", instituteId);
            logCmd.Parameters.AddWithValue("@SessId", sessionId);
            logCmd.Parameters.AddWithValue("@NewId", newUserId);
            cmds.Add(logCmd);

            _dl.ExecuteTransaction(cmds);
            return newUserId;
        }

        // ══════════════════════════════════════════════════════════════════════
        //  UPDATE STUDENT
        // ══════════════════════════════════════════════════════════════════════
        public void UpdateStudent(
            int userId, int sessionId,
            string email, string fullName, string contact, string rollNo,
            string gender, DateTime? dob,
            int? streamId, int? courseId, int? levelId,
            int? semesterId, int? sectionId)
        {
            var cmds = new List<SqlCommand>();

            var uCmd = new SqlCommand(
                "UPDATE Users SET Email = @Email WHERE UserId = @UserId");
            uCmd.Parameters.AddWithValue("@Email", email.Trim());
            uCmd.Parameters.AddWithValue("@UserId", userId);
            cmds.Add(uCmd);

            var pCmd = new SqlCommand(@"
                IF EXISTS (SELECT 1 FROM UserProfile WHERE UserId = @UserId)
                BEGIN
                    UPDATE UserProfile
                    SET FullName  = @FullName,
                        ContactNo = @Contact,
                        Gender    = @Gender,
                        DOB       = @DOB
                    WHERE UserId = @UserId
                END
                ELSE
                BEGIN
                    INSERT INTO UserProfile
                        (UserId, FullName, ContactNo, Gender, DOB,
                         EmergencyContactName, EmergencyContactNo, JoinedDate)
                    VALUES
                        (@UserId, @FullName, @Contact, @Gender, @DOB,
                         'N/A', '0000000000', GETDATE())
                END");
            pCmd.Parameters.AddWithValue("@FullName", fullName.Trim());
            pCmd.Parameters.AddWithValue("@Contact", contact ?? "");
            pCmd.Parameters.AddWithValue("@Gender", gender ?? "Male");
            pCmd.Parameters.AddWithValue("@DOB", dob.HasValue ? (object)dob.Value : DBNull.Value);
            pCmd.Parameters.AddWithValue("@UserId", userId);
            cmds.Add(pCmd);

            var aCmd = new SqlCommand(@"
                IF EXISTS (SELECT 1 FROM StudentAcademicDetails
                           WHERE UserId = @UserId AND SessionId = @SessId)
                BEGIN
                    UPDATE StudentAcademicDetails
                    SET RollNumber = @RollNo,
                        StreamId   = @StreamId,
                        CourseId   = @CourseId,
                        LevelId    = @LevelId,
                        SemesterId = @SemId,
                        SectionId  = @SecId
                    WHERE UserId = @UserId AND SessionId = @SessId
                END
                ELSE
                BEGIN
                    INSERT INTO StudentAcademicDetails
                        (UserId, SessionId, RollNumber, StreamId,
                         CourseId, LevelId, SemesterId, SectionId, IsReEnrolled)
                    VALUES
                        (@UserId, @SessId, @RollNo, @StreamId,
                         @CourseId, @LevelId, @SemId, @SecId, 0)
                END");
            aCmd.Parameters.AddWithValue("@RollNo", rollNo ?? "");
            aCmd.Parameters.AddWithValue("@StreamId", (object)streamId ?? DBNull.Value);
            aCmd.Parameters.AddWithValue("@CourseId", (object)courseId ?? DBNull.Value);
            aCmd.Parameters.AddWithValue("@LevelId", (object)levelId ?? DBNull.Value);
            aCmd.Parameters.AddWithValue("@SemId", (object)semesterId ?? DBNull.Value);
            aCmd.Parameters.AddWithValue("@SecId", (object)sectionId ?? DBNull.Value);
            aCmd.Parameters.AddWithValue("@UserId", userId);
            aCmd.Parameters.AddWithValue("@SessId", sessionId);
            cmds.Add(aCmd);

            _dl.ExecuteTransaction(cmds);
        }

        // ══════════════════════════════════════════════════════════════════════
        //  RE-ENROL STUDENT — also auto re-enrolls linked parents
        // ══════════════════════════════════════════════════════════════════════
        public void ReEnrolStudent(
            int userId, int societyId, int instituteId, int targetSessionId,
            int? streamId, int? courseId, int? levelId,
            int? semesterId, int? sectionId,
            string rollNo, int enrolledByUserId)
        {
            var cmds = new List<SqlCommand>();

            var acadCmd = new SqlCommand(@"
                INSERT INTO StudentAcademicDetails
                    (UserId, SocietyId, InstituteId, SessionId,
                     StreamId, CourseId, LevelId, SemesterId, SectionId,
                     RollNumber, IsReEnrolled)
                VALUES
                    (@UserId, @SocId, @InstId, @SessId,
                     @StreamId, @CourseId, @LevelId, @SemId, @SecId,
                     @RollNo, 1)");
            acadCmd.Parameters.AddWithValue("@UserId", userId);
            acadCmd.Parameters.AddWithValue("@SocId", societyId);
            acadCmd.Parameters.AddWithValue("@InstId", instituteId);
            acadCmd.Parameters.AddWithValue("@SessId", targetSessionId);
            acadCmd.Parameters.AddWithValue("@StreamId", (object)streamId ?? DBNull.Value);
            acadCmd.Parameters.AddWithValue("@CourseId", (object)courseId ?? DBNull.Value);
            acadCmd.Parameters.AddWithValue("@LevelId", (object)levelId ?? DBNull.Value);
            acadCmd.Parameters.AddWithValue("@SemId", (object)semesterId ?? DBNull.Value);
            acadCmd.Parameters.AddWithValue("@SecId", (object)sectionId ?? DBNull.Value);
            acadCmd.Parameters.AddWithValue("@RollNo", rollNo ?? "");
            cmds.Add(acadCmd);

            var logCmd = new SqlCommand(@"
                INSERT INTO UserActivityLog
                    (UserId, SocietyId, InstituteId, SessionId,
                     ActivityType, ReferenceId, ActionTime)
                VALUES
                    (@By, @SocId, @InstId, @SessId, 'StudentReEnrolled', @UserId, GETDATE())");
            logCmd.Parameters.AddWithValue("@By", enrolledByUserId);
            logCmd.Parameters.AddWithValue("@SocId", societyId);
            logCmd.Parameters.AddWithValue("@InstId", instituteId);
            logCmd.Parameters.AddWithValue("@SessId", targetSessionId);
            logCmd.Parameters.AddWithValue("@UserId", userId);
            cmds.Add(logCmd);

            _dl.ExecuteTransaction(cmds);

            // Auto re-enroll linked parents
            AutoReEnrollParents(userId, targetSessionId, societyId, instituteId);
        }

        // ══════════════════════════════════════════════════════════════════════
        //  AUTO RE-ENROLL PARENTS (calls stored procedure)
        // ══════════════════════════════════════════════════════════════════════
        public int AutoReEnrollParents(int studentUserId, int newSessionId,
                                       int societyId, int instituteId)
        {
            try
            {
                using (var con = new SqlConnection(
                    ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString))
                {
                    con.Open();
                    var cmd = new SqlCommand("sp_AutoReEnrollParentsForStudent", con)
                    {
                        CommandType = CommandType.StoredProcedure
                    };
                    cmd.Parameters.AddWithValue("@StudentUserId", studentUserId);
                    cmd.Parameters.AddWithValue("@NewSessionId", newSessionId);
                    cmd.Parameters.AddWithValue("@SocietyId", societyId);
                    cmd.Parameters.AddWithValue("@InstituteId", instituteId);
                    cmd.ExecuteNonQuery();
                }

                var countCmd = new SqlCommand(@"
                    SELECT COUNT(1) FROM ParentStudentMapping
                    WHERE StudentUserId = @StudId
                      AND SessionId     = @SessId
                      AND IsReEnrolled  = 1");
                countCmd.Parameters.AddWithValue("@StudId", studentUserId);
                countCmd.Parameters.AddWithValue("@SessId", newSessionId);
                DataTable dt = _dl.GetDataTable(countCmd);
                return dt != null && dt.Rows.Count > 0 ? Convert.ToInt32(dt.Rows[0][0]) : 0;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("[AutoReEnrollParents] " + ex.Message);
                return 0;
            }
        }

        // ══════════════════════════════════════════════════════════════════════
        //  GET PARENT COUNT for a student in a session
        // ══════════════════════════════════════════════════════════════════════
        public int GetParentCountForStudent(int studentUserId, int sessionId)
        {
            var cmd = new SqlCommand(@"
                SELECT COUNT(1)
                FROM ParentStudentMapping
                WHERE StudentUserId = @StudId
                  AND SessionId     = @SessId
                  AND IsActive      = 1");
            cmd.Parameters.AddWithValue("@StudId", studentUserId);
            cmd.Parameters.AddWithValue("@SessId", sessionId);
            DataTable dt = _dl.GetDataTable(cmd);
            return dt != null && dt.Rows.Count > 0 ? Convert.ToInt32(dt.Rows[0][0]) : 0;
        }

        // ══════════════════════════════════════════════════════════════════════
        //  DELETE STUDENT
        // ══════════════════════════════════════════════════════════════════════
        public void DeleteStudent(int userId, int sessionId)
        {
            // Remove this session's academic record
            var a = new SqlCommand(
                "DELETE FROM StudentAcademicDetails WHERE UserId = @Id AND SessionId = @Sess");
            a.Parameters.AddWithValue("@Id", userId);
            a.Parameters.AddWithValue("@Sess", sessionId);
            _dl.ExecuteCMD(a);

            // If no other session records remain, remove profile + user
            var chk = new SqlCommand(
                "SELECT COUNT(*) FROM StudentAcademicDetails WHERE UserId = @Id");
            chk.Parameters.AddWithValue("@Id", userId);
            DataTable dt = _dl.GetDataTable(chk);
            int others = dt != null && dt.Rows.Count > 0 ? Convert.ToInt32(dt.Rows[0][0]) : 0;

            if (others == 0)
            {
                var cmds = new List<SqlCommand>();
                var p = new SqlCommand("DELETE FROM UserProfile WHERE UserId = @Id");
                p.Parameters.AddWithValue("@Id", userId);
                cmds.Add(p);
                var u = new SqlCommand("DELETE FROM Users WHERE UserId = @Id");
                u.Parameters.AddWithValue("@Id", userId);
                cmds.Add(u);
                _dl.ExecuteTransaction(cmds);
            }
        }

        // ══════════════════════════════════════════════════════════════════════
        //  TOGGLE ACTIVE / INACTIVE
        // ══════════════════════════════════════════════════════════════════════
        public bool ToggleStudent(int userId)
        {
            var cmd = new SqlCommand(@"
                UPDATE Users
                SET IsActive = CASE WHEN IsActive = 1 THEN 0 ELSE 1 END
                OUTPUT INSERTED.IsActive
                WHERE UserId = @Id");
            cmd.Parameters.AddWithValue("@Id", userId);
            DataTable dt = _dl.GetDataTable(cmd);
            return dt != null && dt.Rows.Count > 0 && Convert.ToBoolean(dt.Rows[0][0]);
        }

        // ══════════════════════════════════════════════════════════════════════
        //  CHECK ENROLMENT IN SESSION
        // ══════════════════════════════════════════════════════════════════════
        public bool IsStudentEnrolledInSession(int userId, int sessionId)
        {
            var cmd = new SqlCommand(@"
                SELECT COUNT(*) FROM StudentAcademicDetails
                WHERE UserId = @UserId AND SessionId = @SessId");
            cmd.Parameters.AddWithValue("@UserId", userId);
            cmd.Parameters.AddWithValue("@SessId", sessionId);
            DataTable dt = _dl.GetDataTable(cmd);
            return dt != null && dt.Rows.Count > 0 && Convert.ToInt32(dt.Rows[0][0]) > 0;
        }

        // ══════════════════════════════════════════════════════════════════════
        //  STATS
        //  Also uses INNER JOIN on SAD.SessionId (same fix as GetStudents).
        // ══════════════════════════════════════════════════════════════════════
        public DataTable GetStudentStats(int instituteId, int sessionId)
        {
            var cmd = new SqlCommand(@"
                SELECT
                    COUNT(DISTINCT U.UserId)                                               AS Total,
                    COUNT(DISTINCT CASE WHEN U.IsActive = 1 THEN U.UserId END)             AS Active,
                    COUNT(DISTINCT CASE WHEN U.IsActive = 0 THEN U.UserId END)             AS Inactive,
                    COUNT(DISTINCT CASE
                        WHEN MONTH(U.CreatedOn) = MONTH(GETDATE())
                         AND YEAR(U.CreatedOn)  = YEAR(GETDATE())
                        THEN U.UserId END)                                                 AS NewStudents,
                    COUNT(DISTINCT CASE WHEN ISNULL(SAD.IsReEnrolled, 0) = 1
                        THEN U.UserId END)                                                 AS ReEnrolled
                FROM Users U
                INNER JOIN StudentAcademicDetails SAD
                    ON  SAD.UserId    = U.UserId
                    AND SAD.SessionId = @SessId
                WHERE U.RoleId = (SELECT TOP 1 RoleId FROM Roles WHERE RoleName = 'Student')
                  AND U.InstituteId = @InstId");
            cmd.Parameters.AddWithValue("@InstId", instituteId);
            cmd.Parameters.AddWithValue("@SessId", sessionId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        // ══════════════════════════════════════════════════════════════════════
        //  STREAM / COURSE BREAKDOWN CARDS
        // ══════════════════════════════════════════════════════════════════════
        public DataTable GetStudentStatsByStreamCourse(int instituteId, int sessionId)
        {
            var cmd = new SqlCommand(@"
                SELECT
                    ISNULL(St.StreamName, 'No Stream') AS StreamName,
                    ISNULL(C.CourseName,  'No Course')  AS CourseName,
                    COUNT(*)                             AS TotalStudents
                FROM Users U
                INNER JOIN StudentAcademicDetails SAD
                    ON  SAD.UserId    = U.UserId
                    AND SAD.SessionId = @SessId
                LEFT JOIN Streams St ON St.StreamId = SAD.StreamId
                LEFT JOIN Courses C  ON C.CourseId  = SAD.CourseId
                WHERE U.RoleId = (SELECT TOP 1 RoleId FROM Roles WHERE RoleName = 'Student')
                  AND U.InstituteId = @InstId
                  AND U.IsActive    = 1
                GROUP BY St.StreamName, C.CourseName
                ORDER BY TotalStudents DESC");
            cmd.Parameters.AddWithValue("@InstId", instituteId);
            cmd.Parameters.AddWithValue("@SessId", sessionId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        // ══════════════════════════════════════════════════════════════════════
        //  ACADEMIC DROPDOWN LOADERS
        // ══════════════════════════════════════════════════════════════════════
        public DataTable GetStreams(int instituteId, int sessionId)
        {
            var cmd = new SqlCommand(@"
                SELECT StreamId, StreamName FROM Streams
                WHERE InstituteId = @InstId AND SessionId = @SessId AND IsActive = 1
                ORDER BY StreamName");
            cmd.Parameters.AddWithValue("@InstId", instituteId);
            cmd.Parameters.AddWithValue("@SessId", sessionId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        public DataTable GetCourses(int instituteId, int sessionId)
        {
            var cmd = new SqlCommand(@"
                SELECT CourseId, CourseName FROM Courses
                WHERE InstituteId = @InstId AND SessionId = @SessId AND IsActive = 1
                ORDER BY CourseName");
            cmd.Parameters.AddWithValue("@InstId", instituteId);
            cmd.Parameters.AddWithValue("@SessId", sessionId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        public DataTable GetCoursesByStream(int instituteId, int sessionId, int streamId)
        {
            var cmd = new SqlCommand(@"
                SELECT CourseId, CourseName FROM Courses
                WHERE InstituteId = @InstId AND SessionId = @SessId
                  AND StreamId = @StreamId AND IsActive = 1
                ORDER BY CourseName");
            cmd.Parameters.AddWithValue("@InstId", instituteId);
            cmd.Parameters.AddWithValue("@SessId", sessionId);
            cmd.Parameters.AddWithValue("@StreamId", streamId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        public DataTable GetStudyLevels(int instituteId, int sessionId)
        {
            var cmd = new SqlCommand(@"
                SELECT LevelId, LevelName FROM StudyLevels
                WHERE InstituteId = @InstId AND SessionId = @SessId
                ORDER BY LevelName");
            cmd.Parameters.AddWithValue("@InstId", instituteId);
            cmd.Parameters.AddWithValue("@SessId", sessionId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        public DataTable GetSemesters(int instituteId, int sessionId)
        {
            var cmd = new SqlCommand(@"
                SELECT SemesterId, SemesterName FROM Semesters
                WHERE InstituteId = @InstId AND SessionId = @SessId
                ORDER BY SemesterName");
            cmd.Parameters.AddWithValue("@InstId", instituteId);
            cmd.Parameters.AddWithValue("@SessId", sessionId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        public DataTable GetSections(int instituteId, int sessionId)
        {
            var cmd = new SqlCommand(@"
                SELECT SectionId, SectionName FROM Sections
                WHERE InstituteId = @InstId AND SessionId = @SessId AND IsActive = 1
                ORDER BY SectionName");
            cmd.Parameters.AddWithValue("@InstId", instituteId);
            cmd.Parameters.AddWithValue("@SessId", sessionId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        public DataTable GetAllSessions(int instituteId)
        {
            var cmd = new SqlCommand(@"
                SELECT SessionId, SessionName, IsCurrent
                FROM AcademicSessions
                WHERE InstituteId = @InstId
                ORDER BY CreatedOn DESC");
            cmd.Parameters.AddWithValue("@InstId", instituteId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        public int GetCurrentSessionId(int instituteId)
        {
            var cmd = new SqlCommand(@"
                SELECT TOP 1 SessionId FROM AcademicSessions
                WHERE InstituteId = @InstId AND IsCurrent = 1");
            cmd.Parameters.AddWithValue("@InstId", instituteId);
            DataTable dt = _dl.GetDataTable(cmd);
            return dt != null && dt.Rows.Count > 0
                ? Convert.ToInt32(dt.Rows[0]["SessionId"]) : 0;
        }
    }
}