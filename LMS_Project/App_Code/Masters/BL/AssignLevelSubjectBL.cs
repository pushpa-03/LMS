//using LearningManagementSystem.GC;
//using System;
//using System.Data;
//using System.Data.SqlClient;

//namespace LearningManagementSystem.BL
//{
//    public class AssignLevelSubjectBL
//    {
//        DataLayer dl = new DataLayer();

//        public DataTable GetSubjects(int instituteId)
//        {
//            SqlCommand cmd = new SqlCommand();

//            cmd.CommandText =
//            "SELECT SubjectId,SubjectName FROM Subjects WHERE InstituteId=@I and IsActive =1";

//            cmd.Parameters.AddWithValue("@I", instituteId);

//            return dl.GetDataTable(cmd);
//        }

//        public DataTable GetStreams(int instituteId)
//        {
//            SqlCommand cmd = new SqlCommand();

//            cmd.CommandText =
//            "SELECT StreamId,StreamName FROM Streams WHERE InstituteId=@I AND IsActive=1";

//            cmd.Parameters.AddWithValue("@I", instituteId);

//            return dl.GetDataTable(cmd);
//        }

//        public DataTable GetCourses(int streamId)
//        {
//            SqlCommand cmd = new SqlCommand();

//            cmd.CommandText =
//            "SELECT CourseId,CourseName FROM Courses WHERE StreamId=@S AND IsActive=1";

//            cmd.Parameters.AddWithValue("@S", streamId);

//            return dl.GetDataTable(cmd);
//        }

//        public DataTable GetLevels(int instituteId)
//        {
//            SqlCommand cmd = new SqlCommand();

//            cmd.CommandText =
//            "SELECT LevelId,LevelName FROM StudyLevels WHERE InstituteId=@I";

//            cmd.Parameters.AddWithValue("@I", instituteId);

//            return dl.GetDataTable(cmd);
//        }

//        public DataTable GetSemesters(int instituteId)
//        {
//            SqlCommand cmd = new SqlCommand();

//            cmd.CommandText =
//            "SELECT SemesterId,SemesterName FROM Semesters WHERE InstituteId=@I";

//            cmd.Parameters.AddWithValue("@I", instituteId);

//            return dl.GetDataTable(cmd);
//        }
//        public void InsertLevelSubject(LevelSemesterSubjectGC obj)
//        {
//            SqlCommand cmd = new SqlCommand();

//            cmd.CommandText = @"INSERT INTO LevelSemesterSubjects
//            (SocietyId,InstituteId,SessionId,StreamId,CourseId,
//            LevelId,SemesterId,SubjectId,IsMandatory)

//            VALUES
//            (@SocietyId,@InstituteId,@SessionId,@StreamId,@CourseId,
//            @LevelId,@SemesterId,@SubjectId,@IsMandatory)";

//            cmd.Parameters.AddWithValue("@SocietyId", obj.SocietyId);
//            cmd.Parameters.AddWithValue("@InstituteId", obj.InstituteId);
//            cmd.Parameters.AddWithValue("@SessionId", obj.SessionId);
//            cmd.Parameters.AddWithValue("@StreamId", obj.StreamId);
//            cmd.Parameters.AddWithValue("@CourseId", obj.CourseId);
//            cmd.Parameters.AddWithValue("@LevelId", obj.LevelId);
//            cmd.Parameters.AddWithValue("@SemesterId", obj.SemesterId);
//            cmd.Parameters.AddWithValue("@SubjectId", obj.SubjectId);
//            cmd.Parameters.AddWithValue("@IsMandatory", obj.IsMandatory);

//            dl.ExecuteCMD(cmd);
//        }

//        public int GetCurrentSession(int instituteId)
//        {
//            SqlCommand cmd = new SqlCommand();
//            cmd.CommandText =
//            "SELECT SessionId FROM AcademicSessions WHERE InstituteId=@I AND IsCurrent=1";

//            cmd.Parameters.AddWithValue("@I", instituteId);

//            DataTable dt = dl.GetDataTable(cmd);

//            if (dt.Rows.Count > 0)
//                return Convert.ToInt32(dt.Rows[0]["SessionId"]);

//            return 0;
//        }
//public void CloneLevelSubjects(int instituteId, int oldSessionId, int newSessionId)
//{
//    SqlCommand cmd = new SqlCommand(@"

//    INSERT INTO LevelSemesterSubjects
//    (
//        SocietyId,
//        InstituteId,
//        SessionId,
//        StreamId,
//        CourseId,
//        LevelId,
//        SemesterId,
//        SubjectId,
//        SubjectType
//    )

//    SELECT
//        SocietyId,
//        InstituteId,
//        @NewSession,
//        StreamId,
//        CourseId,
//        LevelId,
//        SemesterId,
//        SubjectId,
//        SubjectType

//    FROM LevelSemesterSubjects

//    WHERE InstituteId=@Institute
//    AND SessionId=@OldSession

//    ");

//    cmd.Parameters.AddWithValue("@Institute", instituteId);
//    cmd.Parameters.AddWithValue("@OldSession", oldSessionId);
//    cmd.Parameters.AddWithValue("@NewSession", newSessionId);

//    dl.ExecuteCMD(cmd);
//}

//    }
//}

//----------------------------------------------------------------------------------------------------------------------------------------------------------------

using LearningManagementSystem.GC;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace LearningManagementSystem.BL
{
    /// <summary>
    /// Business Logic Layer – Assign Level Subjects.
    /// Every method is called directly from AssignLevelSubject.aspx.cs.
    /// Uses DataLayer only: GetDataTable, ExecuteCMD, ExecuteTransaction.
    /// </summary>
    public class AssignLevelSubjectBL
    {
        private readonly DataLayer _dl = new DataLayer();

        // ══════════════════════════════════════════════════════════════════════
        //  STATS  — called by UpdateHeaderStats()
        // ══════════════════════════════════════════════════════════════════════

        /// <summary>
        /// Returns TotalAssigned (rows in LevelSemesterSubjects for this session)
        /// and ActiveSubjects (distinct active subjects in this session).
        /// </summary>
        public DataTable GetStats(int instituteId, int sessionId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT
                    (SELECT COUNT(1)
                     FROM   LevelSemesterSubjects
                     WHERE  InstituteId = @I AND SessionId = @S)        AS TotalAssigned,

                    (SELECT COUNT(1)
                     FROM   Subjects
                     WHERE  InstituteId = @I AND SessionId = @S
                       AND  IsActive = 1)                               AS ActiveSubjects");

            cmd.Parameters.AddWithValue("@I", instituteId);
            cmd.Parameters.AddWithValue("@S", sessionId);
            return _dl.GetDataTable(cmd);
        }

        // ══════════════════════════════════════════════════════════════════════
        //  DROPDOWNS
        // ══════════════════════════════════════════════════════════════════════

        /// <summary>Active streams for this institute + session.</summary>
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

        /// <summary>
        /// Active courses filtered by stream and session.
        /// Called after ddlStream_Changed so courses are always in sync.
        /// </summary>
        public DataTable GetCourses(int streamId, int sessionId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT CourseId, CourseName
                FROM   Courses
                WHERE  StreamId  = @Stream
                  AND  SessionId = @S
                  AND  IsActive  = 1
                ORDER  BY CourseName");
            cmd.Parameters.AddWithValue("@Stream", streamId);
            cmd.Parameters.AddWithValue("@S", sessionId);
            return _dl.GetDataTable(cmd);
        }

        /// <summary>Study levels for this institute + session.</summary>
        public DataTable GetLevels(int instituteId, int sessionId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT LevelId, LevelName
                FROM   StudyLevels
                WHERE  InstituteId = @I AND SessionId = @S
                ORDER  BY LevelName");
            cmd.Parameters.AddWithValue("@I", instituteId);
            cmd.Parameters.AddWithValue("@S", sessionId);
            return _dl.GetDataTable(cmd);
        }

        /// <summary>Semesters for this institute + session.</summary>
        public DataTable GetSemesters(int instituteId, int sessionId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT SemesterId, SemesterName
                FROM   Semesters
                WHERE  InstituteId = @I AND SessionId = @S
                ORDER  BY SemesterName");
            cmd.Parameters.AddWithValue("@I", instituteId);
            cmd.Parameters.AddWithValue("@S", sessionId);
            return _dl.GetDataTable(cmd);
        }

        /// <summary>Active sections for this institute + session.</summary>
        public DataTable GetSections(int instituteId, int sessionId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT SectionId, SectionName
                FROM   Sections
                WHERE  InstituteId = @I AND SessionId = @S AND IsActive = 1
                ORDER  BY SectionName");
            cmd.Parameters.AddWithValue("@I", instituteId);
            cmd.Parameters.AddWithValue("@S", sessionId);
            return _dl.GetDataTable(cmd);
        }

        //used in Dashboard.aspx.cs page
        public DataTable GetSubjects(int instituteId,int sessionId)
        {
            SqlCommand cmd = new SqlCommand();

            cmd.CommandText =
            "SELECT SubjectId,SubjectName FROM Subjects WHERE InstituteId=@I and  SessionId = @S AND IsActive =1";

            cmd.Parameters.AddWithValue("@I", instituteId);
            cmd.Parameters.AddWithValue("@S", sessionId);

            return _dl.GetDataTable(cmd);
        }

        // ══════════════════════════════════════════════════════════════════════
        //  SUBJECTS WITH IsAlreadyAssigned FLAG
        //  Called by LoadSubjectsGrid()
        // ══════════════════════════════════════════════════════════════════════

        /// <summary>
        /// Returns all active subjects for this session, each with a computed
        /// IsAlreadyAssigned bit that is TRUE when the subject is already mapped
        /// to the selected stream / course / level / semester combination.
        /// The ASPX GridView uses this to show the green "✓" badge on rows.
        /// </summary>
        public DataTable GetSubjectsWithAssignedFlag(
            int instituteId, int sessionId,
            int streamId, int courseId,
            int levelId, int semesterId)
        {
            // Build the EXISTS sub-query dynamically based on which FKs are selected.
            // Only non-zero values are added as filter criteria.
            string existsFilter = "InstituteId = @I AND SessionId = @S AND SubjectId = sub.SubjectId";

            if (streamId > 0) existsFilter += " AND StreamId   = @StreamId";
            if (courseId > 0) existsFilter += " AND CourseId   = @CourseId";
            if (levelId > 0) existsFilter += " AND LevelId    = @LevelId";
            if (semesterId > 0) existsFilter += " AND SemesterId = @SemesterId";

            string query = $@"
                SELECT
                    sub.SubjectId,
                    sub.SubjectCode,
                    sub.SubjectName,
                    ISNULL(sub.Duration, '—')      AS Duration,
                    sub.IsActive,
                    CAST(
                        CASE WHEN EXISTS (
                            SELECT 1
                            FROM   LevelSemesterSubjects
                            WHERE  {existsFilter}
                        ) THEN 1 ELSE 0 END
                    AS BIT)                         AS IsAlreadyAssigned
                FROM  Subjects sub
                WHERE sub.InstituteId = @I
                  AND sub.SessionId   = @S
                  AND sub.IsActive    = 1
                ORDER BY sub.SubjectName";

            SqlCommand cmd = new SqlCommand(query);
            cmd.Parameters.AddWithValue("@I", instituteId);
            cmd.Parameters.AddWithValue("@S", sessionId);
            if (streamId > 0) cmd.Parameters.AddWithValue("@StreamId", streamId);
            if (courseId > 0) cmd.Parameters.AddWithValue("@CourseId", courseId);
            if (levelId > 0) cmd.Parameters.AddWithValue("@LevelId", levelId);
            if (semesterId > 0) cmd.Parameters.AddWithValue("@SemesterId", semesterId);

            return _dl.GetDataTable(cmd);
        }

        // ══════════════════════════════════════════════════════════════════════
        //  ALREADY-ASSIGNED INFO BOX
        //  Called by ShowAlreadyAssignedBox()
        // ══════════════════════════════════════════════════════════════════════

        /// <summary>
        /// Returns the list of subjects already assigned to the selected class
        /// (stream + course + level + semester). Used to populate the info panel
        /// with coloured tags so the admin can see what is already mapped.
        /// </summary>
        public DataTable GetAlreadyAssigned(
            int instituteId, int sessionId,
            int streamId, int courseId,
            int levelId, int semesterId)
        {
            string query = @"
                SELECT
                    lss.Id,
                    sub.SubjectName,
                    sub.SubjectCode,
                    lss.IsMandatory
                FROM  LevelSemesterSubjects lss
                INNER JOIN Subjects sub ON sub.SubjectId = lss.SubjectId
                WHERE lss.InstituteId = @I
                  AND lss.SessionId   = @S
                  AND lss.StreamId    = @StreamId";

            SqlCommand cmd = new SqlCommand();
            cmd.Parameters.AddWithValue("@I", instituteId);
            cmd.Parameters.AddWithValue("@S", sessionId);
            cmd.Parameters.AddWithValue("@StreamId", streamId);

            if (courseId > 0)
            {
                query += " AND lss.CourseId = @CourseId";
                cmd.Parameters.AddWithValue("@CourseId", courseId);
            }
            else
            {
                query += " AND (lss.CourseId IS NULL OR lss.CourseId = 0)";
            }

            if (levelId > 0)
            {
                query += " AND lss.LevelId = @LevelId";
                cmd.Parameters.AddWithValue("@LevelId", levelId);
            }

            if (semesterId > 0)
            {
                query += " AND lss.SemesterId = @SemesterId";
                cmd.Parameters.AddWithValue("@SemesterId", semesterId);
            }

            query += " ORDER BY sub.SubjectName";
            cmd.CommandText = query;
            return _dl.GetDataTable(cmd);
        }

        // ══════════════════════════════════════════════════════════════════════
        //  SINGLE DUPLICATE CHECK
        //  Called per subject inside btnSave_Click loop
        // ══════════════════════════════════════════════════════════════════════

        /// <summary>
        /// Returns true if this exact subject is already assigned to the given
        /// stream / course / level / semester combination in this session.
        /// Prevents duplicate inserts without crashing on the UNIQUE constraint.
        /// </summary>
        public bool IsAlreadyAssigned(
            int instituteId, int sessionId,
            int streamId, int courseId,
            int levelId, int semesterId,
            int subjectId)
        {
            string query = @"
                SELECT COUNT(1)
                FROM   LevelSemesterSubjects
                WHERE  InstituteId = @I
                  AND  SessionId   = @S
                  AND  StreamId    = @StreamId
                  AND  SubjectId   = @SubjectId";

            SqlCommand cmd = new SqlCommand();
            cmd.Parameters.AddWithValue("@I", instituteId);
            cmd.Parameters.AddWithValue("@S", sessionId);
            cmd.Parameters.AddWithValue("@StreamId", streamId);
            cmd.Parameters.AddWithValue("@SubjectId", subjectId);

            if (courseId > 0)
            {
                query += " AND CourseId = @CourseId";
                cmd.Parameters.AddWithValue("@CourseId", courseId);
            }
            else
            {
                query += " AND (CourseId IS NULL OR CourseId = 0)";
            }

            if (levelId > 0)
            {
                query += " AND LevelId = @LevelId";
                cmd.Parameters.AddWithValue("@LevelId", levelId);
            }

            if (semesterId > 0)
            {
                query += " AND SemesterId = @SemesterId";
                cmd.Parameters.AddWithValue("@SemesterId", semesterId);
            }

            cmd.CommandText = query;
            DataTable dt = _dl.GetDataTable(cmd);
            return dt.Rows.Count > 0 && Convert.ToInt32(dt.Rows[0][0]) > 0;
        }

        // ══════════════════════════════════════════════════════════════════════
        //  INSERT BATCH  — called by btnSave_Click after duplicate filtering
        // ══════════════════════════════════════════════════════════════════════

        /// <summary>
        /// Inserts all non-duplicate subject assignments in a single DB transaction.
        /// Uses IF NOT EXISTS as a final safety net at the DB level.
        /// </summary>
        public void InsertBatch(List<LevelSemesterSubjectGC> items)
        {
            if (items == null || items.Count == 0) return;

            var cmds = new List<SqlCommand>();

            foreach (var obj in items)
            {
                var cmd = new SqlCommand(@"
                    IF NOT EXISTS (
                        SELECT 1 FROM LevelSemesterSubjects
                        WHERE  InstituteId = @InstituteId
                          AND  SessionId   = @SessionId
                          AND  StreamId    = @StreamId
                          AND  ISNULL(CourseId,   0) = ISNULL(@CourseId,   0)
                          AND  ISNULL(LevelId,    0) = ISNULL(@LevelId,    0)
                          AND  ISNULL(SemesterId, 0) = ISNULL(@SemesterId, 0)
                          AND  SubjectId   = @SubjectId
                    )
                    BEGIN
                        INSERT INTO LevelSemesterSubjects
                            (SocietyId, InstituteId, SessionId,
                             StreamId, CourseId, LevelId, SemesterId,
                             SubjectId, IsMandatory, CreatedOn)
                        VALUES
                            (@SocietyId, @InstituteId, @SessionId,
                             @StreamId, @CourseId, @LevelId, @SemesterId,
                             @SubjectId, @IsMandatory, GETDATE())
                    END");

                cmd.Parameters.AddWithValue("@SocietyId", obj.SocietyId);
                cmd.Parameters.AddWithValue("@InstituteId", obj.InstituteId);
                cmd.Parameters.AddWithValue("@SessionId", obj.SessionId);
                cmd.Parameters.AddWithValue("@StreamId", obj.StreamId);

                cmd.Parameters.AddWithValue("@CourseId",
                    obj.CourseId.HasValue && obj.CourseId.Value > 0
                        ? (object)obj.CourseId.Value : DBNull.Value);

                cmd.Parameters.AddWithValue("@LevelId",
                    obj.LevelId.HasValue && obj.LevelId.Value > 0
                        ? (object)obj.LevelId.Value : DBNull.Value);

                cmd.Parameters.AddWithValue("@SemesterId",
                    obj.SemesterId.HasValue && obj.SemesterId.Value > 0
                        ? (object)obj.SemesterId.Value : DBNull.Value);

                cmd.Parameters.AddWithValue("@SubjectId", obj.SubjectId);
                cmd.Parameters.AddWithValue("@IsMandatory", obj.IsMandatory);

                cmds.Add(cmd);
            }

            _dl.ExecuteTransaction(cmds);
        }

        // ══════════════════════════════════════════════════════════════════════
        //  SINGLE INSERT  (kept for backward compat with old BL callers)
        // ══════════════════════════════════════════════════════════════════════

        /// <summary>
        /// Inserts a single assignment with an IF NOT EXISTS guard.
        /// Prefer InsertBatch() when assigning multiple subjects at once.
        /// </summary>
        public void InsertLevelSubject(LevelSemesterSubjectGC obj)
        {
            InsertBatch(new List<LevelSemesterSubjectGC> { obj });
        }

        // ══════════════════════════════════════════════════════════════════════
        //  REMOVE ASSIGNMENT  — called by gvTracker_RowCommand
        // ══════════════════════════════════════════════════════════════════════

        /// <summary>
        /// Deletes a single LevelSemesterSubjects row by primary key.
        /// Safe — does NOT cascade to SubjectGroupSubjects or other tables.
        /// If other tables reference this assignment, the DB FK will prevent
        /// deletion and the exception is caught in the code-behind.
        /// </summary>
        public void RemoveAssignment(int id)
        {
            SqlCommand cmd = new SqlCommand(
                "DELETE FROM LevelSemesterSubjects WHERE Id = @Id");
            cmd.Parameters.AddWithValue("@Id", id);
            _dl.ExecuteCMD(cmd);
        }

        // ══════════════════════════════════════════════════════════════════════
        //  TRACKER GRID  — called by BindTracker()
        // ══════════════════════════════════════════════════════════════════════

        /// <summary>
        /// Returns all subject assignments for this institute + session,
        /// joined with subject, stream, course, level and semester names.
        /// Optional filterStreamId narrows to one stream (tracker dropdown).
        /// </summary>
        public DataTable GetAssignmentTracker(
            int instituteId, int sessionId, int filterStreamId = 0)
        {
            string query = @"
                SELECT
                    lss.Id,
                    lss.IsMandatory,
                    lss.CreatedOn,

                    ISNULL(sub.SubjectCode, '')     AS SubjectCode,
                    ISNULL(sub.SubjectName, '—')    AS SubjectName,

                    ISNULL(st.StreamName,   '—')    AS StreamName,
                    ISNULL(co.CourseName,   '—')    AS CourseName,
                    ISNULL(lv.LevelName,    '—')    AS LevelName,
                    ISNULL(sm.SemesterName, '—')    AS SemesterName

                FROM  LevelSemesterSubjects lss
                INNER JOIN Subjects    sub ON sub.SubjectId  = lss.SubjectId
                LEFT  JOIN Streams     st  ON st.StreamId    = lss.StreamId
                LEFT  JOIN Courses     co  ON co.CourseId    = lss.CourseId
                LEFT  JOIN StudyLevels lv  ON lv.LevelId     = lss.LevelId
                LEFT  JOIN Semesters   sm  ON sm.SemesterId  = lss.SemesterId

                WHERE lss.InstituteId = @I
                  AND lss.SessionId   = @S";

            SqlCommand cmd = new SqlCommand();
            cmd.Parameters.AddWithValue("@I", instituteId);
            cmd.Parameters.AddWithValue("@S", sessionId);

            if (filterStreamId > 0)
            {
                query += " AND lss.StreamId = @StreamId";
                cmd.Parameters.AddWithValue("@StreamId", filterStreamId);
            }

            query += " ORDER BY st.StreamName, co.CourseName, lv.LevelName, sm.SemesterName, sub.SubjectName";
            cmd.CommandText = query;
            return _dl.GetDataTable(cmd);
        }

        // ══════════════════════════════════════════════════════════════════════
        //  CLONE  (session rollover utility — kept from original BL)
        // ══════════════════════════════════════════════════════════════════════

        /// <summary>
        /// Copies all LevelSemesterSubjects rows from one session to another.
        /// Used during academic session rollover / new year setup.
        /// Skips rows that already exist in the new session (IF NOT EXISTS guard).
        /// </summary>
        public void CloneLevelSubjects(int instituteId, int oldSessionId, int newSessionId)
        {
            SqlCommand cmd = new SqlCommand(@"
                INSERT INTO LevelSemesterSubjects
                    (SocietyId, InstituteId, SessionId,
                     StreamId, CourseId, LevelId, SemesterId,
                     SubjectId, IsMandatory, CreatedOn)

                SELECT
                    SocietyId,
                    InstituteId,
                    @NewSession,
                    StreamId,
                    CourseId,
                    LevelId,
                    SemesterId,
                    SubjectId,
                    IsMandatory,
                    GETDATE()

                FROM  LevelSemesterSubjects

                WHERE InstituteId = @Institute
                  AND SessionId   = @OldSession
                  AND NOT EXISTS (
                        SELECT 1
                        FROM   LevelSemesterSubjects n
                        WHERE  n.InstituteId  = @Institute
                          AND  n.SessionId    = @NewSession
                          AND  n.StreamId     = LevelSemesterSubjects.StreamId
                          AND  ISNULL(n.CourseId,   0) = ISNULL(LevelSemesterSubjects.CourseId,   0)
                          AND  ISNULL(n.LevelId,    0) = ISNULL(LevelSemesterSubjects.LevelId,    0)
                          AND  ISNULL(n.SemesterId, 0) = ISNULL(LevelSemesterSubjects.SemesterId, 0)
                          AND  n.SubjectId    = LevelSemesterSubjects.SubjectId
                  )");

            cmd.Parameters.AddWithValue("@Institute", instituteId);
            cmd.Parameters.AddWithValue("@OldSession", oldSessionId);
            cmd.Parameters.AddWithValue("@NewSession", newSessionId);

            _dl.ExecuteCMD(cmd);
        }
    }
}