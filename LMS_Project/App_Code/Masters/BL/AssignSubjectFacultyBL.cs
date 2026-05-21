using LearningManagementSystem.GC;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace LearningManagementSystem.BL
{
    public class AssignSubjectFacultyBL
    {
        private readonly DataLayer _dl = new DataLayer();

        // ══════════════════════════════════════════════════════════════════════
        //  STATS
        // ══════════════════════════════════════════════════════════════════════
        public DataTable GetStats(int instituteId, int sessionId)
        {
            var cmd = new SqlCommand(@"
                SELECT
                    COUNT(1)                                     AS TotalAssignments,
                    SUM(CASE WHEN IsActive=1 THEN 1 ELSE 0 END) AS ActiveAssignments,
                    COUNT(DISTINCT TeacherId)                    AS TeachersAssigned
                FROM SubjectFaculty
                WHERE InstituteId=@I AND SessionId=@S");
            cmd.Parameters.AddWithValue("@I", instituteId);
            cmd.Parameters.AddWithValue("@S", sessionId);
            return _dl.GetDataTable(cmd);
        }

        // ══════════════════════════════════════════════════════════════════════
        //  DROPDOWNS
        // ══════════════════════════════════════════════════════════════════════
        public DataTable GetStreams(int instituteId, int sessionId)
        {
            var cmd = new SqlCommand(@"
                SELECT StreamId, StreamName FROM Streams
                WHERE InstituteId=@I AND SessionId=@S AND IsActive=1
                ORDER BY StreamName");
            cmd.Parameters.AddWithValue("@I", instituteId);
            cmd.Parameters.AddWithValue("@S", sessionId);
            return _dl.GetDataTable(cmd);
        }

        public DataTable GetSections(int instituteId, int sessionId)
        {
            var cmd = new SqlCommand(@"
                SELECT SectionId, SectionName FROM Sections
                WHERE InstituteId=@I AND SessionId=@S AND IsActive=1
                ORDER BY SectionName");
            cmd.Parameters.AddWithValue("@I", instituteId);
            cmd.Parameters.AddWithValue("@S", sessionId);
            return _dl.GetDataTable(cmd);
        }

        // ══════════════════════════════════════════════════════════════════════
        //  SUBJECTS WITH CLASS DETAILS — for Single Assign subject list
        //
        //  KEY: returns LssId (LevelSemesterSubjects.Id) as a unique row key.
        //  This means DBMS in Sem1 and DBMS in Sem4 are TWO separate rows with
        //  different LssIds, so the teacher can pick the exact mapping they want.
        //
        //  The ASPX uses LssId as the unique item identifier (not SubjectId).
        //  hfSingleSubjectId stores "SubjectId|LssId" so code-behind can
        //  extract SubjectId for the insert and LssId for display context.
        // ══════════════════════════════════════════════════════════════════════
        public DataTable GetSubjectsWithDetails(int instituteId, int sessionId)
        {
            var cmd = new SqlCommand(@"
                SELECT
                    lss.Id                          AS LssId,
                    sub.SubjectId,
                    ISNULL(sub.SubjectCode,'')      AS SubjectCode,
                    sub.SubjectName,
                    ISNULL(sub.Duration,'—')        AS Duration,
                    lss.StreamId,
                    ISNULL(st.StreamName,'')        AS StreamName,
                    lss.CourseId,
                    ISNULL(co.CourseName,'')        AS CourseName,
                    lss.LevelId,
                    ISNULL(lv.LevelName,'')         AS LevelName,
                    lss.SemesterId,
                    ISNULL(sm.SemesterName,'')      AS SemesterName,
                    lss.IsMandatory
                FROM LevelSemesterSubjects lss
                INNER JOIN Subjects    sub ON sub.SubjectId   = lss.SubjectId
                LEFT  JOIN Streams     st  ON st.StreamId     = lss.StreamId
                LEFT  JOIN Courses     co  ON co.CourseId     = lss.CourseId
                LEFT  JOIN StudyLevels lv  ON lv.LevelId      = lss.LevelId
                LEFT  JOIN Semesters   sm  ON sm.SemesterId   = lss.SemesterId
                WHERE lss.InstituteId=@I AND lss.SessionId=@S
                  AND sub.IsActive=1
                ORDER BY sub.SubjectName, st.StreamName, lv.LevelName, sm.SemesterName");
            cmd.Parameters.AddWithValue("@I", instituteId);
            cmd.Parameters.AddWithValue("@S", sessionId);
            return _dl.GetDataTable(cmd);
        }

        // ══════════════════════════════════════════════════════════════════════
        //  ALL SUBJECTS (public fallback for WebMethod when sectionId=0)
        //  Called from GetSubjectsForSection WebMethod when no section selected.
        //  Same as GetSubjectsWithDetails — returns LssId for unique selection.
        // ══════════════════════════════════════════════════════════════════════
        public DataTable GetAllSubjectsPublic(int instituteId, int sessionId)
        {
            return GetSubjectsWithDetails(instituteId, sessionId);
        }

        // ══════════════════════════════════════════════════════════════════════
        //  SUBJECTS FOR SECTION — for Bulk Assign subject checklist
        //  Falls back to all subjects if no students enrolled in section.
        // ══════════════════════════════════════════════════════════════════════
        public DataTable GetSubjectsForSection(int instituteId, int sessionId, int sectionId)
        {
            var cmd = new SqlCommand(@"
                SELECT DISTINCT
                    lss.Id                          AS LssId,
                    sub.SubjectId,
                    ISNULL(sub.SubjectCode,'')      AS SubjectCode,
                    sub.SubjectName,
                    ISNULL(sub.Duration,'—')        AS Duration,
                    ISNULL(st.StreamName,'')        AS StreamName,
                    ISNULL(co.CourseName,'')        AS CourseName,
                    ISNULL(lv.LevelName,'')         AS LevelName,
                    ISNULL(sm.SemesterName,'')      AS SemesterName,
                    lss.IsMandatory
                FROM LevelSemesterSubjects lss
                INNER JOIN Subjects     sub ON sub.SubjectId   = lss.SubjectId
                LEFT  JOIN Streams      st  ON st.StreamId     = lss.StreamId
                LEFT  JOIN Courses      co  ON co.CourseId     = lss.CourseId
                LEFT  JOIN StudyLevels  lv  ON lv.LevelId      = lss.LevelId
                LEFT  JOIN Semesters    sm  ON sm.SemesterId   = lss.SemesterId
                WHERE lss.InstituteId=@I AND lss.SessionId=@S
                  AND sub.IsActive=1
                  AND EXISTS (
                      SELECT 1 FROM StudentAcademicDetails sad
                      WHERE sad.InstituteId=@I AND sad.SessionId=@S
                        AND sad.SectionId=@SecId
                        AND (lss.StreamId   IS NULL OR sad.StreamId   = lss.StreamId)
                        AND (lss.LevelId    IS NULL OR sad.LevelId    = lss.LevelId)
                        AND (lss.SemesterId IS NULL OR sad.SemesterId = lss.SemesterId)
                        AND (lss.CourseId   IS NULL OR sad.CourseId   = lss.CourseId)
                  )
                ORDER BY sub.SubjectName");
            cmd.Parameters.AddWithValue("@I", instituteId);
            cmd.Parameters.AddWithValue("@S", sessionId);
            cmd.Parameters.AddWithValue("@SecId", sectionId);

            DataTable dt = _dl.GetDataTable(cmd);
            if (dt == null || dt.Rows.Count == 0)
                return GetAllSubjectsPublic(instituteId, sessionId);
            return dt;
        }

        // ══════════════════════════════════════════════════════════════════════
        //  VALID SECTIONS FOR A SUBJECT MAPPING (LssId)
        //  Uses LssId to get sections valid for that SPECIFIC mapping row
        //  (e.g. DBMS-Sem1 vs DBMS-Sem4 give different sections).
        //  Falls back to all sections if no enrolled students found.
        // ══════════════════════════════════════════════════════════════════════
        public DataTable GetSectionsForSubject(int subjectId, int instituteId, int sessionId)
        {
            var cmd = new SqlCommand(@"
                SELECT DISTINCT sec.SectionId, sec.SectionName
                FROM LevelSemesterSubjects lss
                INNER JOIN StudentAcademicDetails sad
                        ON sad.InstituteId=lss.InstituteId AND sad.SessionId=lss.SessionId
                       AND sad.SectionId IS NOT NULL
                       AND (lss.StreamId   IS NULL OR sad.StreamId   = lss.StreamId)
                       AND (lss.LevelId    IS NULL OR sad.LevelId    = lss.LevelId)
                       AND (lss.SemesterId IS NULL OR sad.SemesterId = lss.SemesterId)
                       AND (lss.CourseId   IS NULL OR sad.CourseId   = lss.CourseId)
                INNER JOIN Sections sec ON sec.SectionId  = sad.SectionId
                        AND sec.InstituteId=@I AND sec.SessionId=@S AND sec.IsActive=1
                WHERE lss.SubjectId=@SubId
                  AND lss.InstituteId=@I AND lss.SessionId=@S
                ORDER BY sec.SectionName");
            cmd.Parameters.AddWithValue("@SubId", subjectId);
            cmd.Parameters.AddWithValue("@I", instituteId);
            cmd.Parameters.AddWithValue("@S", sessionId);

            DataTable dt = _dl.GetDataTable(cmd);
            if (dt == null || dt.Rows.Count == 0)
                return GetSections(instituteId, sessionId);
            return dt;
        }

        // ══════════════════════════════════════════════════════════════════════
        //  VALID SECTIONS FOR A SPECIFIC LSS ROW (by LssId)
        //  More precise than GetSectionsForSubject — uses the exact mapping row.
        //  DBMS-Sem1 (LssId=5) → sections of students in Sem1 stream.
        //  DBMS-Sem4 (LssId=9) → sections of students in Sem4 stream.
        // ══════════════════════════════════════════════════════════════════════
        public DataTable GetSectionsForLss(int lssId, int instituteId, int sessionId)
        {
            var cmd = new SqlCommand(@"
                SELECT DISTINCT sec.SectionId, sec.SectionName
                FROM LevelSemesterSubjects lss
                INNER JOIN StudentAcademicDetails sad
                        ON sad.InstituteId=lss.InstituteId AND sad.SessionId=lss.SessionId
                       AND sad.SectionId IS NOT NULL
                       AND (lss.StreamId   IS NULL OR sad.StreamId   = lss.StreamId)
                       AND (lss.LevelId    IS NULL OR sad.LevelId    = lss.LevelId)
                       AND (lss.SemesterId IS NULL OR sad.SemesterId = lss.SemesterId)
                       AND (lss.CourseId   IS NULL OR sad.CourseId   = lss.CourseId)
                INNER JOIN Sections sec ON sec.SectionId  = sad.SectionId
                        AND sec.InstituteId=@I AND sec.SessionId=@S AND sec.IsActive=1
                WHERE lss.Id=@LssId
                  AND lss.InstituteId=@I AND lss.SessionId=@S
                ORDER BY sec.SectionName");
            cmd.Parameters.AddWithValue("@LssId", lssId);
            cmd.Parameters.AddWithValue("@I", instituteId);
            cmd.Parameters.AddWithValue("@S", sessionId);

            DataTable dt = _dl.GetDataTable(cmd);
            if (dt == null || dt.Rows.Count == 0)
                return GetSections(instituteId, sessionId);
            return dt;
        }

        // ══════════════════════════════════════════════════════════════════════
        //  TEACHER LIVE SEARCH
        // ══════════════════════════════════════════════════════════════════════
        public DataTable SearchTeachers(string prefix, int instituteId, int sessionId)
        {
            if (string.IsNullOrWhiteSpace(prefix)) return new DataTable();
            var cmd = new SqlCommand(@"
                SELECT TOP 10
                    u.UserId,
                    ISNULL(p.FullName, u.Username)  AS FullName,
                    ISNULL(td.EmployeeId, '')        AS EmployeeId,
                    ISNULL(str.StreamName, '—')      AS StreamName
                FROM Users u
                LEFT JOIN UserProfile p ON p.UserId = u.UserId
                OUTER APPLY (
                    SELECT TOP 1 t.EmployeeId, t.StreamId
                    FROM TeacherDetails t WHERE t.UserId=u.UserId
                    ORDER BY t.TeacherId DESC
                ) td
                LEFT JOIN Streams str ON str.StreamId = td.StreamId
                WHERE u.RoleId = (SELECT TOP 1 RoleId FROM Roles WHERE RoleName='Teacher')
                  AND u.InstituteId=@I AND u.IsActive=1
                  AND (p.FullName LIKE @S OR u.Username LIKE @S OR td.EmployeeId LIKE @S)
                ORDER BY ISNULL(p.FullName, u.Username)");
            cmd.Parameters.AddWithValue("@I", instituteId);
            cmd.Parameters.AddWithValue("@S", "%" + prefix.Trim() + "%");
            return _dl.GetDataTable(cmd);
        }

        public DataTable GetTeacherById(int userId)
        {
            var cmd = new SqlCommand(@"
                SELECT u.UserId, u.Email,
                    ISNULL(p.FullName, u.Username) AS FullName,
                    ISNULL(td.EmployeeId,'')       AS EmployeeId,
                    ISNULL(str.StreamName,'')      AS StreamName
                FROM Users u
                LEFT JOIN UserProfile p ON p.UserId = u.UserId
                OUTER APPLY (
                    SELECT TOP 1 t.EmployeeId, t.StreamId
                    FROM TeacherDetails t WHERE t.UserId=u.UserId
                    ORDER BY t.TeacherId DESC
                ) td
                LEFT JOIN Streams str ON str.StreamId = td.StreamId
                WHERE u.UserId=@Id");
            cmd.Parameters.AddWithValue("@Id", userId);
            return _dl.GetDataTable(cmd);
        }

        public DataTable GetSubjectById(int subjectId, int instituteId, int sessionId)
        {
            var cmd = new SqlCommand(@"
                SELECT SubjectId, SubjectName, ISNULL(SubjectCode,'') AS SubjectCode
                FROM Subjects WHERE SubjectId=@Id AND InstituteId=@I AND SessionId=@S");
            cmd.Parameters.AddWithValue("@Id", subjectId);
            cmd.Parameters.AddWithValue("@I", instituteId);
            cmd.Parameters.AddWithValue("@S", sessionId);
            return _dl.GetDataTable(cmd);
        }

        // ══════════════════════════════════════════════════════════════════════
        //  DUPLICATE CHECK
        // ══════════════════════════════════════════════════════════════════════
        public bool IsAlreadyAssigned(int instituteId, int sessionId,
                                      int teacherId, int subjectId, int sectionId)
        {
            var cmd = new SqlCommand(@"
                SELECT COUNT(1) FROM SubjectFaculty
                WHERE InstituteId=@I AND SessionId=@S
                  AND TeacherId=@T AND SubjectId=@Sub AND SectionId=@Sec");
            cmd.Parameters.AddWithValue("@I", instituteId);
            cmd.Parameters.AddWithValue("@S", sessionId);
            cmd.Parameters.AddWithValue("@T", teacherId);
            cmd.Parameters.AddWithValue("@Sub", subjectId);
            cmd.Parameters.AddWithValue("@Sec", sectionId);
            var dt = _dl.GetDataTable(cmd);
            return dt?.Rows.Count > 0 && Convert.ToInt32(dt.Rows[0][0]) > 0;
        }

        // ══════════════════════════════════════════════════════════════════════
        //  INSERT
        // ══════════════════════════════════════════════════════════════════════
        public void Insert(SubjectFacultyGC obj)
        {
            var cmd = new SqlCommand(@"
                IF NOT EXISTS (
                    SELECT 1 FROM SubjectFaculty
                    WHERE InstituteId=@InstId AND SessionId=@SessId
                      AND TeacherId=@TeachId AND SubjectId=@SubId AND SectionId=@SecId
                )
                INSERT INTO SubjectFaculty
                    (SocietyId,InstituteId,SessionId,SubjectId,TeacherId,
                     SectionId,AssignedBy,AssignedOn,IsActive)
                VALUES
                    (@SocId,@InstId,@SessId,@SubId,@TeachId,
                     @SecId,@AssignBy,GETDATE(),1)");
            cmd.Parameters.AddWithValue("@SocId", obj.SocietyId);
            cmd.Parameters.AddWithValue("@InstId", obj.InstituteId);
            cmd.Parameters.AddWithValue("@SessId", obj.SessionId);
            cmd.Parameters.AddWithValue("@SubId", obj.SubjectId);
            cmd.Parameters.AddWithValue("@TeachId", obj.TeacherId);
            cmd.Parameters.AddWithValue("@SecId", obj.SectionId);
            cmd.Parameters.AddWithValue("@AssignBy", obj.AssignedBy);
            _dl.ExecuteCMD(cmd);
        }

        // ══════════════════════════════════════════════════════════════════════
        //  TOGGLE / DELETE
        // ══════════════════════════════════════════════════════════════════════
        public void Toggle(int id)
        {
            var cmd = new SqlCommand(@"
                UPDATE SubjectFaculty
                SET IsActive=CASE WHEN IsActive=1 THEN 0 ELSE 1 END
                WHERE SubjectFacultyId=@Id");
            cmd.Parameters.AddWithValue("@Id", id);
            _dl.ExecuteCMD(cmd);
        }

        public void Delete(int id)
        {
            var cmd = new SqlCommand(
                "DELETE FROM SubjectFaculty WHERE SubjectFacultyId=@Id");
            cmd.Parameters.AddWithValue("@Id", id);
            _dl.ExecuteCMD(cmd);
        }

        // ══════════════════════════════════════════════════════════════════════
        //  GET ALL ASSIGNMENTS (tracker)
        // ══════════════════════════════════════════════════════════════════════
        public DataTable GetAll(int instituteId, int sessionId,
                                int filterStreamId = 0, string filterStatus = "All")
        {
            string q = @"
                SELECT
                    sf.SubjectFacultyId,
                    sf.IsActive,
                    sf.AssignedOn,
                    ISNULL(p.FullName, u.Username)  AS TeacherName,
                    ISNULL(td.EmployeeId,'')         AS EmployeeId,
                    ISNULL(sub.SubjectName,'—')      AS SubjectName,
                    ISNULL(sub.SubjectCode,'')       AS SubjectCode,
                    ISNULL(sec.SectionName,'—')      AS SectionName,
                    ISNULL(str.StreamName,'—')       AS StreamName,
                    ISNULL(co.CourseName,'')         AS CourseName,
                    ISNULL(lv.LevelName,'')          AS LevelName,
                    ISNULL(sm.SemesterName,'')       AS SemesterName,
                    u.UserId AS TeacherId
                FROM SubjectFaculty sf
                INNER JOIN Users u       ON u.UserId    = sf.TeacherId
                LEFT  JOIN UserProfile p ON p.UserId    = sf.TeacherId
                OUTER APPLY (
                    SELECT TOP 1 t.EmployeeId, t.StreamId
                    FROM TeacherDetails t WHERE t.UserId=sf.TeacherId
                    ORDER BY t.SessionId DESC
                ) td
                LEFT JOIN Subjects    sub ON sub.SubjectId  = sf.SubjectId
                LEFT JOIN Sections    sec ON sec.SectionId  = sf.SectionId
                LEFT JOIN Streams     str ON str.StreamId   = td.StreamId
                LEFT JOIN (
                    SELECT SubjectId,
                           MIN(CourseId)   AS CourseId,
                           MIN(LevelId)    AS LevelId,
                           MIN(SemesterId) AS SemesterId
                    FROM LevelSemesterSubjects
                    WHERE InstituteId=@I AND SessionId=@S
                    GROUP BY SubjectId
                ) lss ON lss.SubjectId = sf.SubjectId
                LEFT JOIN Courses     co ON co.CourseId    = lss.CourseId
                LEFT JOIN StudyLevels lv ON lv.LevelId     = lss.LevelId
                LEFT JOIN Semesters   sm ON sm.SemesterId  = lss.SemesterId
                WHERE sf.InstituteId=@I AND sf.SessionId=@S";

            var cmd = new SqlCommand();
            cmd.Parameters.AddWithValue("@I", instituteId);
            cmd.Parameters.AddWithValue("@S", sessionId);

            if (filterStreamId > 0)
            {
                q += " AND td.StreamId=@StId";
                cmd.Parameters.AddWithValue("@StId", filterStreamId);
            }
            if (filterStatus == "Active") q += " AND sf.IsActive=1";
            else if (filterStatus == "Inactive") q += " AND sf.IsActive=0";

            cmd.CommandText = q +
                " ORDER BY str.StreamName,sec.SectionName,sub.SubjectName,p.FullName";
            return _dl.GetDataTable(cmd);
        }

        // ══════════════════════════════════════════════════════════════════════
        //  WORKLOAD
        // ══════════════════════════════════════════════════════════════════════
        public DataTable GetTeacherWorkload(int instituteId, int sessionId)
        {
            var cmd = new SqlCommand(@"
                SELECT
                    ISNULL(p.FullName, u.Username)  AS TeacherName,
                    COUNT(DISTINCT sf.SubjectId)     AS SubjectCount,
                    COUNT(DISTINCT sf.SectionId)     AS SectionCount
                FROM SubjectFaculty sf
                INNER JOIN Users u ON u.UserId=sf.TeacherId
                LEFT  JOIN UserProfile p ON p.UserId=sf.TeacherId
                WHERE sf.InstituteId=@I AND sf.SessionId=@S AND sf.IsActive=1
                GROUP BY p.FullName, u.Username, sf.TeacherId
                ORDER BY SubjectCount DESC, ISNULL(p.FullName,u.Username)");
            cmd.Parameters.AddWithValue("@I", instituteId);
            cmd.Parameters.AddWithValue("@S", sessionId);
            return _dl.GetDataTable(cmd);
        }

        // ══════════════════════════════════════════════════════════════════════
        //  NOTIFICATION
        // ══════════════════════════════════════════════════════════════════════
        public void SendNotification(int userId, int societyId, int instituteId,
                                     int sessionId, string message, string type)
        {
            if (string.IsNullOrWhiteSpace(message)) return;
            if (message.Length > 900) message = message.Substring(0, 900) + "…";
            var cmd = new SqlCommand(@"
                INSERT INTO Notifications
                    (SocietyId,InstituteId,SessionId,UserId,
                     Message,NotificationType,IsRead,CreatedOn)
                VALUES (@SocId,@InstId,@S,@UserId,@Msg,@Type,0,GETDATE())");
            cmd.Parameters.AddWithValue("@UserId", userId);
            cmd.Parameters.AddWithValue("@SocId", societyId);
            cmd.Parameters.AddWithValue("@InstId", instituteId);
            cmd.Parameters.AddWithValue("@S", sessionId);
            cmd.Parameters.AddWithValue("@Msg", message);
            cmd.Parameters.AddWithValue("@Type", type);
            _dl.ExecuteCMD(cmd);
        }
    }
}