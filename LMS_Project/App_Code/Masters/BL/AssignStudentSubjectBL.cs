using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

public class AssignStudentSubjectBL
{
    private readonly DataLayer _dl = new DataLayer();

    // ══════════════════════════════════════════════════════════════
    //  STATS
    // ══════════════════════════════════════════════════════════════
    public DataTable GetStats(int instituteId, int sessionId)
    {
        var cmd = new SqlCommand(@"
            SELECT
              (SELECT COUNT(1)
               FROM   AssignStudentSubject
               WHERE  InstituteId=@I AND SessionId=@S)            AS TotalAssignments,

              (SELECT COUNT(DISTINCT UserId)
               FROM   AssignStudentSubject
               WHERE  InstituteId=@I AND SessionId=@S)            AS StudentsAssigned,

              (SELECT COUNT(1)
               FROM   StudentAcademicDetails sad
               INNER  JOIN Users u ON u.UserId=sad.UserId
               WHERE  sad.InstituteId=@I AND sad.SessionId=@S
                 AND  u.IsActive=1
                 AND  NOT EXISTS(
                   SELECT 1 FROM AssignStudentSubject a
                   WHERE a.UserId=sad.UserId AND a.InstituteId=@I AND a.SessionId=@S
                 ))                                                AS StudentsPending");
        cmd.Parameters.AddWithValue("@I", instituteId);
        cmd.Parameters.AddWithValue("@S", sessionId);
        return _dl.GetDataTable(cmd);
    }

    // ══════════════════════════════════════════════════════════════
    //  DROPDOWNS
    // ══════════════════════════════════════════════════════════════
    public DataTable GetStreams(int instituteId, int sessionId)
    {
        var cmd = new SqlCommand(@"
            SELECT StreamId, StreamName FROM Streams
            WHERE  InstituteId=@I AND SessionId=@S AND IsActive=1
            ORDER  BY StreamName");
        cmd.Parameters.AddWithValue("@I", instituteId);
        cmd.Parameters.AddWithValue("@S", sessionId);
        return _dl.GetDataTable(cmd);
    }

    public DataTable GetCourses(int streamId, int sessionId)
    {
        var cmd = new SqlCommand(@"
            SELECT CourseId, CourseName FROM Courses
            WHERE  StreamId=@St AND SessionId=@S AND IsActive=1
            ORDER  BY CourseName");
        cmd.Parameters.AddWithValue("@St", streamId);
        cmd.Parameters.AddWithValue("@S", sessionId);
        return _dl.GetDataTable(cmd);
    }

    public DataTable GetLevels(int instituteId, int sessionId)
    {
        var cmd = new SqlCommand(@"
            SELECT LevelId, LevelName FROM StudyLevels
            WHERE  InstituteId=@I AND SessionId=@S ORDER BY LevelName");
        cmd.Parameters.AddWithValue("@I", instituteId);
        cmd.Parameters.AddWithValue("@S", sessionId);
        return _dl.GetDataTable(cmd);
    }

    public DataTable GetSemesters(int instituteId, int sessionId)
    {
        var cmd = new SqlCommand(@"
            SELECT SemesterId, SemesterName FROM Semesters
            WHERE  InstituteId=@I AND SessionId=@S ORDER BY SemesterName");
        cmd.Parameters.AddWithValue("@I", instituteId);
        cmd.Parameters.AddWithValue("@S", sessionId);
        return _dl.GetDataTable(cmd);
    }

    public DataTable GetSections(int instituteId, int sessionId)
    {
        var cmd = new SqlCommand(@"
            SELECT SectionId, SectionName FROM Sections
            WHERE  InstituteId=@I AND SessionId=@S AND IsActive=1
            ORDER  BY SectionName");
        cmd.Parameters.AddWithValue("@I", instituteId);
        cmd.Parameters.AddWithValue("@S", sessionId);
        return _dl.GetDataTable(cmd);
    }

    // ══════════════════════════════════════════════════════════════
    //  SUBJECTS FOR CLASS
    // ══════════════════════════════════════════════════════════════
    public DataTable GetSubjectsForClass(int instituteId, int sessionId,
        int streamId, int courseId, int levelId, int semesterId)
    {
        string q = @"
            SELECT sub.SubjectId,
                   ISNULL(sub.SubjectCode,'') AS SubjectCode,
                   sub.SubjectName,
                   ISNULL(sub.Duration,'—')   AS Duration,
                   lss.IsMandatory
            FROM   LevelSemesterSubjects lss
            INNER  JOIN Subjects sub ON sub.SubjectId=lss.SubjectId
            WHERE  lss.InstituteId=@I AND lss.SessionId=@S
              AND  lss.StreamId=@StreamId AND sub.IsActive=1";

        var cmd = new SqlCommand();
        cmd.Parameters.AddWithValue("@I", instituteId);
        cmd.Parameters.AddWithValue("@S", sessionId);
        cmd.Parameters.AddWithValue("@StreamId", streamId);

        if (courseId > 0) { q += " AND (lss.CourseId=@CourseId OR lss.CourseId IS NULL)"; cmd.Parameters.AddWithValue("@CourseId", courseId); }
        if (levelId > 0) { q += " AND lss.LevelId=@LevelId"; cmd.Parameters.AddWithValue("@LevelId", levelId); }
        if (semesterId > 0) { q += " AND lss.SemesterId=@SemesterId"; cmd.Parameters.AddWithValue("@SemesterId", semesterId); }

        q += " ORDER BY lss.IsMandatory DESC, sub.SubjectName";
        cmd.CommandText = q;
        return _dl.GetDataTable(cmd);
    }

    // ══════════════════════════════════════════════════════════════
    //  STUDENTS — lean (for assign loop, gets ALL pages)
    // ══════════════════════════════════════════════════════════════
    public DataTable GetStudentsForClass(int instituteId, int sessionId,
        int streamId, int courseId, int levelId, int semesterId, int sectionId)
    {
        string q = @"
            SELECT u.UserId,
                   ISNULL(p.FullName,   '') AS FullName,
                   ISNULL(a.RollNumber, '') AS RollNumber
            FROM   StudentAcademicDetails a
            INNER  JOIN Users       u ON u.UserId=a.UserId
            INNER  JOIN UserProfile p ON p.UserId=a.UserId
            WHERE  a.InstituteId=@I AND a.SessionId=@S
              AND  a.StreamId=@StreamId AND u.IsActive=1";

        var cmd = new SqlCommand();
        cmd.Parameters.AddWithValue("@I", instituteId);
        cmd.Parameters.AddWithValue("@S", sessionId);
        cmd.Parameters.AddWithValue("@StreamId", streamId);

        if (courseId > 0) { q += " AND a.CourseId=@CourseId"; cmd.Parameters.AddWithValue("@CourseId", courseId); }
        if (levelId > 0) { q += " AND a.LevelId=@LevelId"; cmd.Parameters.AddWithValue("@LevelId", levelId); }
        if (semesterId > 0) { q += " AND a.SemesterId=@SemesterId"; cmd.Parameters.AddWithValue("@SemesterId", semesterId); }
        if (sectionId > 0) { q += " AND a.SectionId=@SectionId"; cmd.Parameters.AddWithValue("@SectionId", sectionId); }

        q += " ORDER BY p.FullName";
        cmd.CommandText = q;
        return _dl.GetDataTable(cmd);
    }

    // ══════════════════════════════════════════════════════════════
    //  STUDENTS WITH ASSIGNMENT STATUS (for left panel grid)
    // ══════════════════════════════════════════════════════════════
    public DataTable GetStudentsWithAssignmentStatus(int instituteId, int sessionId,
        int streamId, int courseId, int levelId, int semesterId, int sectionId)
    {
        string q = @"
            SELECT u.UserId,
                   u.Username,
                   ISNULL(p.FullName,   '') AS FullName,
                   ISNULL(a.RollNumber, '') AS RollNumber,
                   (SELECT COUNT(1)
                    FROM   AssignStudentSubject ass
                    WHERE  ass.UserId=u.UserId
                      AND  ass.InstituteId=@I
                      AND  ass.SessionId=@S)  AS AssignedCount,
                   STUFF((
                       SELECT ', ' + sub.SubjectName
                       FROM   AssignStudentSubject ass2
                       INNER  JOIN Subjects sub ON sub.SubjectId=ass2.SubjectId
                       WHERE  ass2.UserId=u.UserId
                         AND  ass2.InstituteId=@I
                         AND  ass2.SessionId=@S
                       FOR XML PATH(''), TYPE).value('.','NVARCHAR(MAX)'),1,2,'') AS AssignedSubjects
            FROM   StudentAcademicDetails a
            INNER  JOIN Users       u ON u.UserId=a.UserId
            INNER  JOIN UserProfile p ON p.UserId=a.UserId
            WHERE  a.InstituteId=@I AND a.SessionId=@S
              AND  a.StreamId=@StreamId AND u.IsActive=1";

        var cmd = new SqlCommand();
        cmd.Parameters.AddWithValue("@I", instituteId);
        cmd.Parameters.AddWithValue("@S", sessionId);
        cmd.Parameters.AddWithValue("@StreamId", streamId);

        if (courseId > 0) { q += " AND a.CourseId=@CourseId"; cmd.Parameters.AddWithValue("@CourseId", courseId); }
        if (levelId > 0) { q += " AND a.LevelId=@LevelId"; cmd.Parameters.AddWithValue("@LevelId", levelId); }
        if (semesterId > 0) { q += " AND a.SemesterId=@SemesterId"; cmd.Parameters.AddWithValue("@SemesterId", semesterId); }
        if (sectionId > 0) { q += " AND a.SectionId=@SectionId"; cmd.Parameters.AddWithValue("@SectionId", sectionId); }

        q += " ORDER BY p.FullName";
        cmd.CommandText = q;
        return _dl.GetDataTable(cmd);
    }

    // ══════════════════════════════════════════════════════════════
    //  INSERT ONE ROW — returns true if inserted, false if skipped
    //  Uses IF NOT EXISTS so DB unique constraint is never violated.
    //  This replaces InsertBatch + IsAlreadyAssigned with a single
    //  round-trip per student/subject pair.
    // ══════════════════════════════════════════════════════════════
    public bool InsertIfNew(int userId, int subjectId,
                            int societyId, int instituteId, int sessionId)
    {
        // Use OUTPUT to know whether the row was actually inserted
        var cmd = new SqlCommand(@"
            IF NOT EXISTS (
                SELECT 1 FROM AssignStudentSubject
                WHERE  UserId=@UserId AND SubjectId=@SubjectId
                  AND  InstituteId=@I AND SessionId=@S
            )
            BEGIN
                INSERT INTO AssignStudentSubject
                    (UserId, SocietyId, InstituteId, SubjectId, SessionId, AssignedOn)
                VALUES
                    (@UserId, @SocietyId, @I, @SubjectId, @S, GETDATE());
                SELECT 1;   -- inserted
            END
            ELSE
                SELECT 0;   -- already existed");

        cmd.Parameters.AddWithValue("@UserId", userId);
        cmd.Parameters.AddWithValue("@SubjectId", subjectId);
        cmd.Parameters.AddWithValue("@SocietyId", societyId);
        cmd.Parameters.AddWithValue("@I", instituteId);
        cmd.Parameters.AddWithValue("@S", sessionId);

        DataTable dt = _dl.GetDataTable(cmd);
        return dt?.Rows.Count > 0 && Convert.ToInt32(dt.Rows[0][0]) == 1;
    }

    // ══════════════════════════════════════════════════════════════
    //  DELETE ASSIGNMENT
    // ══════════════════════════════════════════════════════════════
    public void DeleteAssignment(int id)
    {
        var cmd = new SqlCommand("DELETE FROM AssignStudentSubject WHERE Id=@Id");
        cmd.Parameters.AddWithValue("@Id", id);
        _dl.ExecuteCMD(cmd);
    }

    // ══════════════════════════════════════════════════════════════
    //  SUBJECT NAMES BY IDS
    // ══════════════════════════════════════════════════════════════
    public DataTable GetSubjectNamesByIds(List<int> ids, int sessionId, int instituteId)
    {
        if (ids == null || ids.Count == 0) return new DataTable();
        var pNames = new List<string>();
        var cmd = new SqlCommand();
        for (int i = 0; i < ids.Count; i++)
        {
            string p = "@s" + i;
            pNames.Add(p);
            cmd.Parameters.AddWithValue(p, ids[i]);
        }
        cmd.CommandText = $"SELECT SubjectName FROM Subjects WHERE SubjectId IN ({string.Join(",", pNames)}) AND IsActive=1 ORDER BY SubjectName";
        return _dl.GetDataTable(cmd);
    }

    // ══════════════════════════════════════════════════════════════
    //  TRACKER GRID
    // ══════════════════════════════════════════════════════════════
    public DataTable GetAssignmentTracker(int instituteId, int sessionId,
                                          string filter = "All")
    {
        if (filter == "Pending") return GetPendingStudents(instituteId, sessionId);

        var cmd = new SqlCommand(@"
            SELECT
                a.Id,
                u.UserId,
                ISNULL(p.FullName,      '') AS FullName,
                ISNULL(d.RollNumber,    '') AS RollNumber,
                ISNULL(sub.SubjectName, '') AS SubjectName,
                ISNULL(sub.SubjectCode, '') AS SubjectCode,
                ISNULL(st.StreamName,  '—') AS StreamName,
                ISNULL(sm.SemesterName,'—') AS SemesterName,
                a.AssignedOn
            FROM  AssignStudentSubject a
            INNER JOIN Users             u   ON u.UserId    = a.UserId
            INNER JOIN UserProfile       p   ON p.UserId    = a.UserId
            INNER JOIN Subjects          sub ON sub.SubjectId= a.SubjectId
            LEFT  JOIN StudentAcademicDetails d
                ON d.UserId=a.UserId AND d.SessionId=a.SessionId AND d.InstituteId=a.InstituteId
            LEFT  JOIN Streams  st ON st.StreamId  = d.StreamId
            LEFT  JOIN Semesters sm ON sm.SemesterId = d.SemesterId
            WHERE a.InstituteId=@I AND a.SessionId=@S
            ORDER BY p.FullName, sub.SubjectName");
        cmd.Parameters.AddWithValue("@I", instituteId);
        cmd.Parameters.AddWithValue("@S", sessionId);
        return _dl.GetDataTable(cmd);
    }

    private DataTable GetPendingStudents(int instituteId, int sessionId)
    {
        var cmd = new SqlCommand(@"
            SELECT
                0                          AS Id,
                u.UserId,
                ISNULL(p.FullName,   '')   AS FullName,
                ISNULL(d.RollNumber, '')   AS RollNumber,
                'No subjects assigned'      AS SubjectName,
                ''                          AS SubjectCode,
                ISNULL(st.StreamName,'—')  AS StreamName,
                ISNULL(sm.SemesterName,'—')AS SemesterName,
                NULL                        AS AssignedOn
            FROM  StudentAcademicDetails d
            INNER JOIN Users       u  ON u.UserId    = d.UserId
            INNER JOIN UserProfile p  ON p.UserId    = d.UserId
            LEFT  JOIN Streams     st ON st.StreamId  = d.StreamId
            LEFT  JOIN Semesters   sm ON sm.SemesterId= d.SemesterId
            WHERE d.InstituteId=@I AND d.SessionId=@S AND u.IsActive=1
              AND NOT EXISTS(
                    SELECT 1 FROM AssignStudentSubject a
                    WHERE a.UserId=d.UserId AND a.InstituteId=@I AND a.SessionId=@S)
            ORDER BY p.FullName");
        cmd.Parameters.AddWithValue("@I", instituteId);
        cmd.Parameters.AddWithValue("@S", sessionId);
        return _dl.GetDataTable(cmd);
    }

    // ══════════════════════════════════════════════════════════════
    //  SEND NOTIFICATION
    // ══════════════════════════════════════════════════════════════
    public void SendNotification(int userId, int societyId,
                                 int instituteId, int sessionId,
                                 string message, string type)
    {
        if (string.IsNullOrWhiteSpace(message)) return;
        if (message.Length > 900) message = message.Substring(0, 900) + "…";
        var cmd = new SqlCommand(@"
            INSERT INTO Notifications
                (SocietyId,InstituteId,SessionId,UserId,Message,NotificationType,IsRead,CreatedOn)
            VALUES
                (@Soc,@I,@S,@U,@Msg,@Type,0,GETDATE())");
        cmd.Parameters.AddWithValue("@Soc", societyId);
        cmd.Parameters.AddWithValue("@I", instituteId);
        cmd.Parameters.AddWithValue("@S", sessionId);
        cmd.Parameters.AddWithValue("@U", userId);
        cmd.Parameters.AddWithValue("@Msg", message);
        cmd.Parameters.AddWithValue("@Type", type);
        _dl.ExecuteCMD(cmd);
    }

    // ══════════════════════════════════════════════════════════════
    //  LEGACY OVERLOADS (keep other pages compiling)
    // ══════════════════════════════════════════════════════════════
    public DataTable GetStreams(int instituteId) => GetStreams(instituteId, 0);
    public DataTable GetCourses(int streamId) => GetCourses(streamId, 0);
    public DataTable GetLevels(int instituteId) => GetLevels(instituteId, 0);
    public DataTable GetSemesters(int instituteId) => GetSemesters(instituteId, 0);
    public DataTable GetAssigned(int i, int s) => GetAssignmentTracker(i, s, "All");
    public void Delete(int id) => DeleteAssignment(id);
    public int GetCurrentSession(int instituteId)
    {
        var cmd = new SqlCommand("SELECT TOP 1 SessionId FROM AcademicSessions WHERE InstituteId=@I AND IsCurrent=1");
        cmd.Parameters.AddWithValue("@I", instituteId);
        var dt = _dl.GetDataTable(cmd);
        return dt.Rows.Count > 0 ? Convert.ToInt32(dt.Rows[0][0]) : 0;
    }
}