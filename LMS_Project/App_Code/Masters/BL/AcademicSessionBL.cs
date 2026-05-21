using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using LearningManagementSystem.GC;

namespace LearningManagementSystem.BL
{
    public class AcademicSessionBL
    {
        private readonly DataLayer _dl = new DataLayer();

        // ══════════════════════════════════════════════════════════════════════
        //  INSERT  — create a new session
        //  If IsCurrent = true, all other sessions for this institute
        //  are reset to IsCurrent = 0 in the same transaction.
        // ══════════════════════════════════════════════════════════════════════
        public void InsertSession(AcademicSessionGC obj)
        {
            var cmds = new List<SqlCommand>();

            if (obj.IsCurrent)
            {
                var reset = new SqlCommand(
                    "UPDATE AcademicSessions SET IsCurrent = 0 WHERE InstituteId = @InstId");
                reset.Parameters.AddWithValue("@InstId", obj.InstituteId);
                cmds.Add(reset);
            }

            var cmd = new SqlCommand(@"
                INSERT INTO AcademicSessions
                    (SocietyId, InstituteId, SessionName, StartDate, EndDate, IsActive, IsCurrent, CreatedOn)
                VALUES
                    (@SocId, @InstId, @Name, @Start, @End, 1, @IsCurrent, GETDATE())");

            cmd.Parameters.AddWithValue("@SocId", obj.SocietyId);
            cmd.Parameters.AddWithValue("@InstId", obj.InstituteId);
            cmd.Parameters.AddWithValue("@Name", obj.SessionName.Trim());
            cmd.Parameters.AddWithValue("@Start", obj.StartDate);
            cmd.Parameters.AddWithValue("@End", obj.EndDate);
            cmd.Parameters.AddWithValue("@IsCurrent", obj.IsCurrent);
            cmds.Add(cmd);

            _dl.ExecuteTransaction(cmds);
        }

        // ══════════════════════════════════════════════════════════════════════
        //  UPDATE  — edit an existing session
        // ══════════════════════════════════════════════════════════════════════
        public void UpdateSession(AcademicSessionGC obj)
        {
            var cmds = new List<SqlCommand>();

            if (obj.IsCurrent)
            {
                var reset = new SqlCommand(
                    "UPDATE AcademicSessions SET IsCurrent = 0 WHERE InstituteId = @InstId");
                reset.Parameters.AddWithValue("@InstId", obj.InstituteId);
                cmds.Add(reset);
            }

            var cmd = new SqlCommand(@"
                UPDATE AcademicSessions SET
                    SessionName = @Name,
                    StartDate   = @Start,
                    EndDate     = @End,
                    IsCurrent   = @IsCurrent
                WHERE SessionId   = @SessionId
                  AND InstituteId = @InstId");

            cmd.Parameters.AddWithValue("@SessionId", obj.SessionId);
            cmd.Parameters.AddWithValue("@InstId", obj.InstituteId);
            cmd.Parameters.AddWithValue("@Name", obj.SessionName.Trim());
            cmd.Parameters.AddWithValue("@Start", obj.StartDate);
            cmd.Parameters.AddWithValue("@End", obj.EndDate);
            cmd.Parameters.AddWithValue("@IsCurrent", obj.IsCurrent);
            cmds.Add(cmd);

            _dl.ExecuteTransaction(cmds);
        }

        // ══════════════════════════════════════════════════════════════════════
        //  DELETE  — only allowed if session has no related data
        // ══════════════════════════════════════════════════════════════════════
        public void Delete(int sessionId, int instituteId)
        {
            if (IsSessionInUse(sessionId, instituteId))
                throw new Exception("SESSION_IN_USE");

            var cmd = new SqlCommand(
                "DELETE FROM AcademicSessions WHERE SessionId = @Id AND InstituteId = @InstId");
            cmd.Parameters.AddWithValue("@Id", sessionId);
            cmd.Parameters.AddWithValue("@InstId", instituteId);
            _dl.ExecuteCMD(cmd);
        }

        // ══════════════════════════════════════════════════════════════════════
        //  GET ALL  — for a given institute, newest first
        // ══════════════════════════════════════════════════════════════════════
        public DataTable GetSessionsByInstitute(int instituteId)
        {
            var cmd = new SqlCommand(@"
                SELECT
                    SessionId, SocietyId, InstituteId,
                    SessionName, StartDate, EndDate,
                    IsActive, IsCurrent, CreatedOn
                FROM AcademicSessions
                WHERE InstituteId = @InstId
                ORDER BY CreatedOn DESC");
            cmd.Parameters.AddWithValue("@InstId", instituteId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        // ══════════════════════════════════════════════════════════════════════
        //  GET BY ID
        // ══════════════════════════════════════════════════════════════════════
        public DataTable GetById(int sessionId, int instituteId)
        {
            var cmd = new SqlCommand(@"
                SELECT *
                FROM AcademicSessions
                WHERE SessionId   = @Id
                  AND InstituteId = @InstId");
            cmd.Parameters.AddWithValue("@Id", sessionId);
            cmd.Parameters.AddWithValue("@InstId", instituteId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        // ══════════════════════════════════════════════════════════════════════
        //  GET CURRENT SESSION  — used by BasePage to set SessionId
        // ══════════════════════════════════════════════════════════════════════
        public DataTable GetCurrentSession(int instituteId)
        {
            var cmd = new SqlCommand(@"
                SELECT TOP 1 *
                FROM AcademicSessions
                WHERE InstituteId = @InstId AND IsCurrent = 1");
            cmd.Parameters.AddWithValue("@InstId", instituteId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        // ══════════════════════════════════════════════════════════════════════
        //  SET CURRENT SESSION
        //  Resets all → sets the chosen one → optionally copies level-subjects
        // ══════════════════════════════════════════════════════════════════════
        public void SetCurrentSession(int sessionId, int instituteId)
        {
            // Get the previous current session id
            int oldSessionId = 0;
            var getOld = new SqlCommand(@"
                SELECT TOP 1 SessionId
                FROM AcademicSessions
                WHERE InstituteId = @InstId AND IsCurrent = 1");
            getOld.Parameters.AddWithValue("@InstId", instituteId);
            DataTable dtOld = _dl.GetDataTable(getOld);
            if (dtOld != null && dtOld.Rows.Count > 0)
                oldSessionId = Convert.ToInt32(dtOld.Rows[0]["SessionId"]);

            var cmds = new List<SqlCommand>();

            // Reset all
            var reset = new SqlCommand(
                "UPDATE AcademicSessions SET IsCurrent = 0 WHERE InstituteId = @InstId");
            reset.Parameters.AddWithValue("@InstId", instituteId);
            cmds.Add(reset);

            // Set new
            var setNew = new SqlCommand(
                "UPDATE AcademicSessions SET IsCurrent = 1 WHERE SessionId = @Id");
            setNew.Parameters.AddWithValue("@Id", sessionId);
            cmds.Add(setNew);

            _dl.ExecuteTransaction(cmds);
        }

        // ══════════════════════════════════════════════════════════════════════
        //  IS SESSION NAME EXISTS  — duplicate check (excludes self on edit)
        // ══════════════════════════════════════════════════════════════════════
        public bool IsSessionNameExists(int instituteId, string sessionName, int excludeSessionId = 0)
        {
            var cmd = new SqlCommand(@"
                SELECT COUNT(*)
                FROM AcademicSessions
                WHERE InstituteId   = @InstId
                  AND SessionName   = @Name
                  AND SessionId    <> @ExcludeId");
            cmd.Parameters.AddWithValue("@InstId", instituteId);
            cmd.Parameters.AddWithValue("@Name", sessionName.Trim());
            cmd.Parameters.AddWithValue("@ExcludeId", excludeSessionId);
            DataTable dt = _dl.GetDataTable(cmd);
            return dt != null && dt.Rows.Count > 0 && Convert.ToInt32(dt.Rows[0][0]) > 0;
        }

        // ══════════════════════════════════════════════════════════════════════
        //  IS SESSION IN USE  — check if any related data exists
        //  Used before allowing delete
        // ══════════════════════════════════════════════════════════════════════
        public bool IsSessionInUse(int sessionId, int instituteId)
        {
            var cmd = new SqlCommand(@"
                SELECT
                (
                    (SELECT COUNT(*) FROM Streams               WHERE SessionId=@Id AND InstituteId=@Inst) +
                    (SELECT COUNT(*) FROM Courses               WHERE SessionId=@Id AND InstituteId=@Inst) +
                    (SELECT COUNT(*) FROM Subjects              WHERE SessionId=@Id AND InstituteId=@Inst) +
                    (SELECT COUNT(*) FROM StudyLevels           WHERE SessionId=@Id AND InstituteId=@Inst) +
                    (SELECT COUNT(*) FROM Semesters             WHERE SessionId=@Id AND InstituteId=@Inst) +
                    (SELECT COUNT(*) FROM Sections              WHERE SessionId=@Id AND InstituteId=@Inst) +
                    (SELECT COUNT(*) FROM Chapters              WHERE SessionId=@Id AND InstituteId=@Inst) +
                    (SELECT COUNT(*) FROM Videos                WHERE SessionId=@Id AND InstituteId=@Inst) +
                    (SELECT COUNT(*) FROM Attendance            WHERE SessionId=@Id AND InstituteId=@Inst) +
                    (SELECT COUNT(*) FROM Users                 WHERE SessionId=@Id AND InstituteId=@Inst)
                ) AS TotalCount");
            cmd.Parameters.AddWithValue("@Id", sessionId);
            cmd.Parameters.AddWithValue("@Inst", instituteId);
            DataTable dt = _dl.GetDataTable(cmd);
            if (dt == null || dt.Rows.Count == 0) return false;
            return Convert.ToInt32(dt.Rows[0]["TotalCount"]) > 0;
        }

        // ══════════════════════════════════════════════════════════════════════
        //  SESSION HAS DATA  — lighter check: does target session already
        //  have any streams copied? Used to warn before re-running copy.
        // ══════════════════════════════════════════════════════════════════════
        public bool SessionHasData(int sessionId, int instituteId)
        {
            var cmd = new SqlCommand(@"
                SELECT COUNT(*) FROM Streams
                WHERE SessionId = @Id AND InstituteId = @Inst");
            cmd.Parameters.AddWithValue("@Id", sessionId);
            cmd.Parameters.AddWithValue("@Inst", instituteId);
            DataTable dt = _dl.GetDataTable(cmd);
            return dt != null && dt.Rows.Count > 0 && Convert.ToInt32(dt.Rows[0][0]) > 0;
        }

        // ══════════════════════════════════════════════════════════════════════
        //  START NEW SESSION  — calls the stored procedure that copies
        //  Streams, Courses, Levels, Semesters, Sections, Subjects,
        //  LevelSemesterSubjects, Chapters, Videos, VideoTopics.
        //  Attendance / Progress / Views / Enrollments start FRESH.
        //
        //  ⚠ Make sure you have run SessionManagement.sql first to create
        //    the sp_StartNewSession stored procedure in your database.
        // ══════════════════════════════════════════════════════════════════════
        public void StartNewSession(int fromSessionId, int toSessionId,
            int instituteId, int societyId)
        {
            var cmd = new SqlCommand("sp_StartNewSession")
            {
                CommandType = System.Data.CommandType.StoredProcedure,
                CommandTimeout = 120  // give it 2 min for large data sets
            };
            cmd.Parameters.AddWithValue("@NewSessionId", toSessionId);
            cmd.Parameters.AddWithValue("@OldSessionId", fromSessionId);
            cmd.Parameters.AddWithValue("@InstituteId", instituteId);
            cmd.Parameters.AddWithValue("@SocietyId", societyId);
            _dl.ExecuteCMD(cmd);
        }

        // ══════════════════════════════════════════════════════════════════════
        //  GET SESSION SUMMARY  — counts for the analysis panel
        //  Returns: Streams, Courses, Subjects, Students, Videos, Attendance
        // ══════════════════════════════════════════════════════════════════════
        public DataTable GetSessionSummary(int sessionId, int instituteId)
        {
            var cmd = new SqlCommand(@"
                SELECT
                    (SELECT COUNT(*) FROM Streams
                     WHERE SessionId=@SessId AND InstituteId=@InstId AND IsActive=1)  AS Streams,

                    (SELECT COUNT(*) FROM Courses
                     WHERE SessionId=@SessId AND InstituteId=@InstId AND IsActive=1)  AS Courses,

                    (SELECT COUNT(*) FROM Subjects
                     WHERE SessionId=@SessId AND InstituteId=@InstId AND IsActive=1)  AS Subjects,

                    (SELECT COUNT(*) FROM Users
                     WHERE SessionId=@SessId AND InstituteId=@InstId
                       AND RoleId=(SELECT RoleId FROM Roles WHERE RoleName='Student')
                       AND IsActive=1)                                                 AS Students,

                    (SELECT COUNT(*) FROM Videos
                     WHERE SessionId=@SessId AND InstituteId=@InstId AND IsActive=1)  AS Videos,

                    (SELECT COUNT(*) FROM Attendance
                     WHERE SessionId=@SessId AND InstituteId=@InstId)                 AS Attendance");

            cmd.Parameters.AddWithValue("@SessId", sessionId);
            cmd.Parameters.AddWithValue("@InstId", instituteId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        // ══════════════════════════════════════════════════════════════════════
        //  GET SESSIONS FOR DROPDOWN  — used in header session switcher
        // ══════════════════════════════════════════════════════════════════════
        public DataTable GetSessionsForDropdown(int instituteId)
        {
            var cmd = new SqlCommand(@"
                SELECT SessionId, SessionName, IsCurrent
                FROM AcademicSessions
                WHERE InstituteId = @InstId
                ORDER BY StartDate DESC");
            cmd.Parameters.AddWithValue("@InstId", instituteId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        // ══════════════════════════════════════════════════════════════════════
        //  CHECK DEADLINE  — returns days left for current session
        //  Returns: negative = overdue, 0-30 = urgent, 31-60 = warning
        // ══════════════════════════════════════════════════════════════════════
        public int GetCurrentSessionDaysLeft(int instituteId)
        {
            DataTable dt = GetCurrentSession(instituteId);
            if (dt == null || dt.Rows.Count == 0) return int.MaxValue;
            DateTime endDate = Convert.ToDateTime(dt.Rows[0]["EndDate"]);
            return (endDate.Date - DateTime.Today).Days;
        }
    }
}

