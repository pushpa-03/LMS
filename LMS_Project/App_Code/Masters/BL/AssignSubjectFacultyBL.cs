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
        //  STATS  → UpdateStats()
        // ══════════════════════════════════════════════════════════════════════
        public DataTable GetStats(int instituteId, int sessionId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT
                    COUNT(1)                                          AS TotalAssignments,
                    SUM(CASE WHEN IsActive=1 THEN 1 ELSE 0 END)      AS ActiveAssignments,
                    COUNT(DISTINCT TeacherId)                         AS TeachersAssigned
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
            SqlCommand cmd = new SqlCommand(@"
                SELECT StreamId, StreamName
                FROM   Streams
                WHERE  InstituteId=@I AND SessionId=@S AND IsActive=1
                ORDER  BY StreamName");
            cmd.Parameters.AddWithValue("@I", instituteId);
            cmd.Parameters.AddWithValue("@S", sessionId);
            return _dl.GetDataTable(cmd);
        }

        
        public DataTable GetSections(int instituteId, int sessionId, int streamId = 0)
        {
            string query = @"
                SELECT SectionId, SectionName
                FROM   Sections
                WHERE  InstituteId=@I AND SessionId=@S AND IsActive=1";

            SqlCommand cmd = new SqlCommand();
            cmd.Parameters.AddWithValue("@I", instituteId);
            cmd.Parameters.AddWithValue("@S", sessionId);

            if (streamId > 0)
            {
                query += @" AND SectionId IN (
                    SELECT DISTINCT SectionId FROM StudentAcademicDetails
                    WHERE  InstituteId=@I AND SessionId=@S
                      AND  StreamId=@St AND SectionId IS NOT NULL)";
                cmd.Parameters.AddWithValue("@St", streamId);
            }

            cmd.CommandText = query + " ORDER BY SectionName";
            return _dl.GetDataTable(cmd);
        }

        
        public DataTable GetSectionsBySubject(int subjectId, int instituteId, int sessionId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT DISTINCT sec.SectionId, sec.SectionName
                FROM   LevelSemesterSubjects lss
                INNER  JOIN StudentAcademicDetails sad
                         ON sad.StreamId    = lss.StreamId
                        AND sad.SessionId   = lss.SessionId
                        AND sad.InstituteId = lss.InstituteId
                        AND (lss.LevelId    IS NULL OR sad.LevelId    = lss.LevelId)
                        AND (lss.SemesterId IS NULL OR sad.SemesterId = lss.SemesterId)
                        AND (lss.CourseId   IS NULL OR sad.CourseId   = lss.CourseId)
                INNER  JOIN Sections sec
                         ON sec.SectionId   = sad.SectionId
                        AND sec.InstituteId = @I
                        AND sec.SessionId   = @S
                        AND sec.IsActive    = 1
                WHERE  lss.SubjectId   = @SubId
                  AND  lss.InstituteId = @I
                  AND  lss.SessionId   = @S
                  AND  sad.SectionId   IS NOT NULL
                ORDER  BY sec.SectionName");

            cmd.Parameters.AddWithValue("@SubId", subjectId);
            cmd.Parameters.AddWithValue("@I", instituteId);
            cmd.Parameters.AddWithValue("@S", sessionId);
            return _dl.GetDataTable(cmd);
        }

        
        public DataTable GetSubjects(int instituteId, int sessionId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT
                    SubjectId,
                    SubjectName,
                    ISNULL(SubjectCode,'') AS SubjectCode,
                    ISNULL(Duration,'—')   AS Duration
                FROM  Subjects
                WHERE InstituteId=@I AND SessionId=@S AND IsActive=1
                ORDER BY SubjectName");
            cmd.Parameters.AddWithValue("@I", instituteId);
            cmd.Parameters.AddWithValue("@S", sessionId);
            return _dl.GetDataTable(cmd);
        }


        public DataTable GetSubjectById(int subjectId, int instituteId, int sessionId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT SubjectId, SubjectName, ISNULL(SubjectCode,'') AS SubjectCode
                FROM   Subjects
                WHERE  SubjectId=@Id AND InstituteId=@I AND SessionId=@S");
            cmd.Parameters.AddWithValue("@Id", subjectId);
            cmd.Parameters.AddWithValue("@I", instituteId);
            cmd.Parameters.AddWithValue("@S", sessionId);
            return _dl.GetDataTable(cmd);
        }

       

        public DataTable SearchTeachers(string prefix, int instituteId, int sessionId)
        {
            SqlCommand cmd = new SqlCommand(@"

    SELECT TOP 10
        u.UserId,
        u.Username,
        ISNULL(p.FullName, u.Username) AS FullName,
        ISNULL(td.EmployeeId, '') AS EmployeeId,
        ISNULL(str.StreamName, '—') AS StreamName

    FROM Users u

    LEFT JOIN UserProfile p
        ON p.UserId = u.UserId

    OUTER APPLY
    (
        SELECT TOP 1
            t.EmployeeId,
            t.StreamId
        FROM TeacherDetails t
        WHERE t.UserId = u.UserId
        ORDER BY t.TeacherId DESC
    ) td

    LEFT JOIN Streams str
        ON str.StreamId = td.StreamId

    WHERE
            u.RoleId = 3
        AND u.InstituteId = @InstituteId
        AND u.IsActive = 1
        AND
        (
               u.Username LIKE @Search
            OR p.FullName LIKE @Search
            OR td.EmployeeId LIKE @Search
        )

    ORDER BY p.FullName, u.Username
");

            cmd.Parameters.AddWithValue("@InstituteId", instituteId);
            cmd.Parameters.AddWithValue("@Search", "%" + prefix.Trim() + "%");

            return _dl.GetDataTable(cmd);
        }
        // ══════════════════════════════════════════════════════════════════════
        //  GET TEACHER BY ID  (used in btnSave_Click for toast + notification)
        // ══════════════════════════════════════════════════════════════════════
        public DataTable GetTeacherById(int userId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT
                    u.UserId,
                    u.Email,
                    ISNULL(p.FullName,    '') AS FullName,
                    ISNULL(td.EmployeeId, '') AS EmployeeId,
                    ISNULL(str.StreamName,'') AS StreamName
                FROM  Users u
                LEFT  JOIN UserProfile p ON p.UserId = u.UserId
                OUTER APPLY (
                    SELECT TOP 1 t.EmployeeId, t.StreamId
                    FROM   TeacherDetails t
                    WHERE  t.UserId = u.UserId
                    ORDER  BY t.SessionId DESC
                ) td
                LEFT  JOIN Streams str ON str.StreamId = td.StreamId
                WHERE u.UserId = @Id");
            cmd.Parameters.AddWithValue("@Id", userId);
            return _dl.GetDataTable(cmd);
        }

       
        public bool IsAlreadyAssigned(int instituteId, int sessionId,
                                      int teacherId, int subjectId, int sectionId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT COUNT(1) FROM SubjectFaculty
                WHERE  InstituteId=@I AND SessionId=@S
                  AND  TeacherId=@T AND SubjectId=@Sub AND SectionId=@Sec");
            cmd.Parameters.AddWithValue("@I", instituteId);
            cmd.Parameters.AddWithValue("@S", sessionId);
            cmd.Parameters.AddWithValue("@T", teacherId);
            cmd.Parameters.AddWithValue("@Sub", subjectId);
            cmd.Parameters.AddWithValue("@Sec", sectionId);
            DataTable dt = _dl.GetDataTable(cmd);
            return dt.Rows.Count > 0 && Convert.ToInt32(dt.Rows[0][0]) > 0;
        }

       
        public void Insert(SubjectFacultyGC obj)
        {
            SqlCommand cmd = new SqlCommand(@"
                IF NOT EXISTS (
                    SELECT 1 FROM SubjectFaculty
                    WHERE  InstituteId=@InstId AND SessionId=@SessId
                      AND  TeacherId=@TeachId  AND SubjectId=@SubId AND SectionId=@SecId
                )
                BEGIN
                    INSERT INTO SubjectFaculty
                        (SocietyId,InstituteId,SessionId,
                         SubjectId,TeacherId,SectionId,
                         AssignedBy,AssignedOn,IsActive)
                    VALUES
                        (@SocId,@InstId,@SessId,
                         @SubId,@TeachId,@SecId,
                         @AssignBy,GETDATE(),1)
                END");

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
        //  TOGGLE  (soft deactivate — keeps attendance history)
        // ══════════════════════════════════════════════════════════════════════
        public void Toggle(int id)
        {
            SqlCommand cmd = new SqlCommand(@"
                UPDATE SubjectFaculty
                SET    IsActive=CASE WHEN IsActive=1 THEN 0 ELSE 1 END
                WHERE  SubjectFacultyId=@Id");
            cmd.Parameters.AddWithValue("@Id", id);
            _dl.ExecuteCMD(cmd);
        }

        // ══════════════════════════════════════════════════════════════════════
        //  DELETE  (hard — code-behind catches FK exception → suggests deactivate)
        // ══════════════════════════════════════════════════════════════════════
        public void Delete(int id)
        {
            SqlCommand cmd = new SqlCommand(
                "DELETE FROM SubjectFaculty WHERE SubjectFacultyId=@Id");
            cmd.Parameters.AddWithValue("@Id", id);
            _dl.ExecuteCMD(cmd);
        }

      
        public DataTable GetAll(int instituteId, int sessionId,
                                int filterStreamId = 0,
                                string filterStatus = "All")
        {
            // Pending = unassigned teachers → completely different query
            if (filterStatus == "Pending")
                return GetUnassignedTeachers(instituteId, sessionId);

            string query = @"
                SELECT
                    sf.SubjectFacultyId,
                    sf.IsActive,
                    sf.AssignedOn,
                    ISNULL(p.FullName,     '—') AS TeacherName,
                    ISNULL(td.EmployeeId,  '')  AS EmployeeId,
                    ISNULL(sub.SubjectName,'—') AS SubjectName,
                    ISNULL(sub.SubjectCode,'')  AS SubjectCode,
                    ISNULL(sec.SectionName,'—') AS SectionName,
                    ISNULL(str.StreamName, '—') AS StreamName,
                    u.UserId AS TeacherId
                FROM  SubjectFaculty sf
                INNER JOIN Users       u    ON u.UserId      = sf.TeacherId
                LEFT  JOIN UserProfile p    ON p.UserId      = sf.TeacherId
                OUTER APPLY (
                    SELECT TOP 1 t.EmployeeId, t.StreamId
                    FROM   TeacherDetails t
                    WHERE  t.UserId = sf.TeacherId
                    ORDER  BY t.SessionId DESC
                ) td
                LEFT  JOIN Subjects    sub  ON sub.SubjectId  = sf.SubjectId
                LEFT  JOIN Sections    sec  ON sec.SectionId  = sf.SectionId
                LEFT  JOIN Streams     str  ON str.StreamId   = td.StreamId
                WHERE sf.InstituteId=@I AND sf.SessionId=@S";

            SqlCommand cmd = new SqlCommand();
            cmd.Parameters.AddWithValue("@I", instituteId);
            cmd.Parameters.AddWithValue("@S", sessionId);

            if (filterStreamId > 0)
            {
                query += " AND td.StreamId=@StId";
                cmd.Parameters.AddWithValue("@StId", filterStreamId);
            }

            if (filterStatus == "Active") query += " AND sf.IsActive=1";
            else if (filterStatus == "Inactive") query += " AND sf.IsActive=0";

            cmd.CommandText = query +
                " ORDER BY str.StreamName, sec.SectionName, sub.SubjectName, p.FullName";
            return _dl.GetDataTable(cmd);
        }

        /// <summary>Teachers who have NO SubjectFaculty row in this session.</summary>
        private DataTable GetUnassignedTeachers(int instituteId, int sessionId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT
                    0                          AS SubjectFacultyId,
                    0                          AS IsActive,
                    NULL                       AS AssignedOn,
                    ISNULL(p.FullName,    '—') AS TeacherName,
                    ISNULL(td.EmployeeId, '')  AS EmployeeId,
                    'Not Assigned'             AS SubjectName,
                    ''                         AS SubjectCode,
                    '—'                        AS SectionName,
                    ISNULL(str.StreamName,'—') AS StreamName,
                    u.UserId                   AS TeacherId
                FROM  Users u
                INNER JOIN Roles r ON r.RoleId=u.RoleId AND r.RoleName='Teacher'
                LEFT  JOIN UserProfile p ON p.UserId=u.UserId
                OUTER APPLY (
                    SELECT TOP 1 t.EmployeeId, t.StreamId
                    FROM   TeacherDetails t
                    WHERE  t.UserId = u.UserId
                    ORDER  BY t.SessionId DESC
                ) td
                LEFT  JOIN Streams str ON str.StreamId=td.StreamId
                WHERE u.InstituteId=@I AND u.IsActive=1
                  AND NOT EXISTS (
                        SELECT 1 FROM SubjectFaculty sf
                        WHERE  sf.TeacherId=u.UserId
                          AND  sf.InstituteId=@I
                          AND  sf.SessionId=@S)
                ORDER BY p.FullName");
            cmd.Parameters.AddWithValue("@I", instituteId);
            cmd.Parameters.AddWithValue("@S", sessionId);
            return _dl.GetDataTable(cmd);
        }

        // ══════════════════════════════════════════════════════════════════════
        //  TEACHER WORKLOAD SUMMARY  → BindWorkload()
        // ══════════════════════════════════════════════════════════════════════
        public DataTable GetTeacherWorkload(int instituteId, int sessionId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT
                    ISNULL(p.FullName,'—')         AS TeacherName,
                    COUNT(DISTINCT sf.SubjectId)    AS SubjectCount,
                    COUNT(DISTINCT sf.SectionId)    AS SectionCount
                FROM  SubjectFaculty sf
                INNER JOIN Users       u ON u.UserId = sf.TeacherId
                LEFT  JOIN UserProfile p ON p.UserId = sf.TeacherId
                WHERE sf.InstituteId=@I AND sf.SessionId=@S AND sf.IsActive=1
                GROUP BY p.FullName, sf.TeacherId
                ORDER BY SubjectCount DESC, p.FullName");
            cmd.Parameters.AddWithValue("@I", instituteId);
            cmd.Parameters.AddWithValue("@S", sessionId);
            return _dl.GetDataTable(cmd);
        }

        // ══════════════════════════════════════════════════════════════════════
        //  NOTIFICATION
        // ══════════════════════════════════════════════════════════════════════
        public void SendNotification(int userId, int societyId,
                                     int instituteId, int sessionId,
                                     string message, string notificationType)
        {
            if (string.IsNullOrWhiteSpace(message)) return;
            if (message.Length > 900) message = message.Substring(0, 900) + "…";

            SqlCommand cmd = new SqlCommand(@"
                IF NOT EXISTS (
                    SELECT 1 FROM Notifications
                    WHERE  UserId=@UserId AND SessionId=@S
                      AND  NotificationType=@Type AND Message=@Msg
                )
                BEGIN
                    INSERT INTO Notifications
                        (SocietyId,InstituteId,SessionId,UserId,
                         Message,NotificationType,IsRead,CreatedOn)
                    VALUES
                        (@SocId,@InstId,@S,@UserId,
                         @Msg,@Type,0,GETDATE())
                END");

            cmd.Parameters.AddWithValue("@UserId", userId);
            cmd.Parameters.AddWithValue("@SocId", societyId);
            cmd.Parameters.AddWithValue("@InstId", instituteId);
            cmd.Parameters.AddWithValue("@S", sessionId);
            cmd.Parameters.AddWithValue("@Msg", message);
            cmd.Parameters.AddWithValue("@Type", notificationType);
            _dl.ExecuteCMD(cmd);
        }

        // ══════════════════════════════════════════════════════════════════════
        //  LEGACY  (kept for backward compat with old pages)
        // ══════════════════════════════════════════════════════════════════════
        public int GetCurrentSession(int instituteId)
        {
            SqlCommand cmd = new SqlCommand(
                "SELECT TOP 1 SessionId FROM AcademicSessions WHERE InstituteId=@I AND IsCurrent=1");
            cmd.Parameters.AddWithValue("@I", instituteId);
            DataTable dt = _dl.GetDataTable(cmd);
            return dt.Rows.Count > 0 ? Convert.ToInt32(dt.Rows[0][0]) : 0;
        }

        public DataTable GetAll(int instituteId, int sessionId) =>
            GetAll(instituteId, sessionId, 0, "All");

        public DataTable GetSections(int instituteId) =>
            GetSections(instituteId, 0, 0);

        public DataTable GetSubjects(int instituteId)
        {
            int s = GetCurrentSession(instituteId);
            return s > 0 ? GetSubjects(instituteId, s) : new DataTable();
        }

        public DataTable GetAllByTeacher(int instituteId, int teacherId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT sub.SubjectName, sec.SectionName, sess.SessionName, sf.IsActive,
                       CASE WHEN sess.IsCurrent=1 THEN 'Present' ELSE 'Past' END AS Status
                FROM  SubjectFaculty sf
                JOIN  Subjects sub         ON sub.SubjectId  = sf.SubjectId
                JOIN  Sections sec         ON sec.SectionId  = sf.SectionId
                JOIN  AcademicSessions sess ON sess.SessionId = sf.SessionId
                WHERE sf.InstituteId=@I AND sf.TeacherId=@T
                ORDER BY sess.IsCurrent DESC, sess.SessionId DESC");
            cmd.Parameters.AddWithValue("@I", instituteId);
            cmd.Parameters.AddWithValue("@T", teacherId);
            return _dl.GetDataTable(cmd);
        }
    }
}