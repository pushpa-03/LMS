using System;
using System.Data;
using System.Data.SqlClient;


    public class SubjectsBL
    {
        private readonly DataLayer _dl = new DataLayer();

        
        // ── Admin Dashboard Stats ──────────────────────────────────────────────
        public DataTable GetAdminStats(int instituteId, int sessionId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT
                    (SELECT COUNT(*) FROM Subjects
                     WHERE InstituteId = @InstId AND SessionId = @SessId) AS TotalSubjects,

                    (SELECT COUNT(*) FROM Subjects
                     WHERE InstituteId = @InstId AND SessionId = @SessId AND IsActive = 1) AS ActiveCount,

                    (SELECT COUNT(*) FROM Subjects
                     WHERE InstituteId = @InstId AND SessionId = @SessId AND IsActive = 0) AS InactiveCount,

                    (SELECT COUNT(*) FROM LevelSemesterSubjects
                     WHERE InstituteId = @InstId AND SessionId = @SessId AND IsMandatory = 1) AS MandatoryCount,

                    (SELECT COUNT(*) FROM AssignStudentSubject
                     WHERE InstituteId = @InstId AND SessionId = @SessId) AS TotalEnrollments,

                    ISNULL(CAST(ROUND(
                        (SELECT AVG(CAST(EnrollCount AS FLOAT))
                         FROM (SELECT COUNT(*) AS EnrollCount
                               FROM AssignStudentSubject
                               WHERE InstituteId = @InstId AND SessionId = @SessId
                               GROUP BY SubjectId) AS sub
                    ), 1) AS VARCHAR), '0') AS AvgPerSubject");

            cmd.Parameters.AddWithValue("@InstId", instituteId);
            cmd.Parameters.AddWithValue("@SessId", sessionId);

            DataTable dt = _dl.GetDataTable(cmd);

            if (dt == null || dt.Rows.Count == 0)
            {
                if (dt == null) dt = new DataTable();
                if (dt.Columns.Count == 0)
                {
                    dt.Columns.Add("TotalSubjects");
                    dt.Columns.Add("ActiveCount");
                    dt.Columns.Add("InactiveCount");
                    dt.Columns.Add("MandatoryCount");
                    dt.Columns.Add("TotalEnrollments");
                    dt.Columns.Add("AvgPerSubject");
                }
                DataRow r = dt.NewRow();
                r["TotalSubjects"] = 0; r["ActiveCount"] = 0; r["InactiveCount"] = 0;
                r["MandatoryCount"] = 0; r["TotalEnrollments"] = 0; r["AvgPerSubject"] = "0";
                dt.Rows.Add(r);
            }
            return dt;
        }

        // ── Filtered Subjects (with VideoCount & ChapterCount) ─────────────────
        public DataTable GetFilteredSubjects(int societyId, int instituteId, int sessionId,
            int isActive, int? streamId, int? courseId, int? levelId, int? semId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT
                    S.SubjectId, S.SubjectName, S.SubjectCode, S.IsActive,
                    ISNULL(ST.StreamName,   'N/A') AS StreamName,
                    ISNULL(C.CourseName,    'N/A') AS CourseName,
                    ISNULL(SL.LevelName,    'N/A') AS LevelName,
                    ISNULL(Sem.SemesterName,'N/A') AS SemesterName,
                    ISNULL(LSS.IsMandatory, 1)     AS IsMandatory,

                    ISNULL((SELECT COUNT(*)
                            FROM AssignStudentSubject ASS
                            WHERE ASS.SubjectId = S.SubjectId
                              AND ASS.SessionId = @SessId), 0) AS StudentCount,

                    ISNULL((SELECT COUNT(*)
                            FROM Chapters CH
                            WHERE CH.SubjectId = S.SubjectId
                              AND CH.SessionId = @SessId
                              AND CH.IsActive  = 1), 0) AS ChapterCount,

                    ISNULL((SELECT COUNT(*)
                            FROM Videos V
                            INNER JOIN Chapters CH2 ON V.ChapterId = CH2.ChapterId
                            WHERE CH2.SubjectId = S.SubjectId
                              AND V.SessionId   = @SessId
                              AND V.IsActive    = 1), 0) AS VideoCount

                FROM Subjects S
                INNER JOIN LevelSemesterSubjects LSS
                    ON S.SubjectId   = LSS.SubjectId
                    AND LSS.InstituteId = @InstId
                    AND LSS.SessionId  = @SessId
                LEFT JOIN Streams     ST  ON LSS.StreamId   = ST.StreamId
                LEFT JOIN Courses     C   ON LSS.CourseId   = C.CourseId
                LEFT JOIN StudyLevels SL  ON LSS.LevelId    = SL.LevelId
                LEFT JOIN Semesters   Sem ON LSS.SemesterId = Sem.SemesterId
                WHERE S.InstituteId = @InstId
                  AND S.IsActive    = @IsActive
                  AND (@StreamId IS NULL OR LSS.StreamId   = @StreamId)
                  AND (@CourseId IS NULL OR LSS.CourseId   = @CourseId)
                  AND (@LevelId  IS NULL OR LSS.LevelId    = @LevelId)
                  AND (@SemId    IS NULL OR LSS.SemesterId = @SemId)
                ORDER BY ST.StreamName, C.CourseName, SL.LevelId, Sem.SemesterId, S.SubjectName");

            cmd.Parameters.AddWithValue("@InstId", instituteId);
            cmd.Parameters.AddWithValue("@SessId", sessionId);
            cmd.Parameters.AddWithValue("@IsActive", isActive);
            cmd.Parameters.AddWithValue("@StreamId", (object)streamId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@CourseId", (object)courseId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@LevelId", (object)levelId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@SemId", (object)semId ?? DBNull.Value);

            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

    public DataTable GetTeacherSubjects(int teacherUserId, int instituteId, int sessionId, int isActive)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT DISTINCT
                S.SubjectId, S.SubjectName, S.SubjectCode, S.IsActive,
                ST.StreamName, C.CourseName, SL.LevelName, Sem.SemesterName,
                LSS.IsMandatory,
                ISNULL((SELECT COUNT(*) FROM AssignStudentSubject ASS 
                        WHERE ASS.SubjectId = S.SubjectId AND ASS.SessionId = @SessId), 0) AS StudentCount
            FROM SubjectFaculty SF
            INNER JOIN Subjects S ON SF.SubjectId = S.SubjectId
            LEFT JOIN LevelSemesterSubjects LSS ON S.SubjectId = LSS.SubjectId
                AND LSS.InstituteId = @InstId
                AND LSS.SessionId = @SessId
            LEFT JOIN Streams ST ON LSS.StreamId = ST.StreamId
            LEFT JOIN Courses C ON LSS.CourseId = C.CourseId
            LEFT JOIN StudyLevels SL ON LSS.LevelId = SL.LevelId
            LEFT JOIN Semesters Sem ON LSS.SemesterId = Sem.SemesterId
            WHERE SF.TeacherId = @TeacherId
              AND SF.InstituteId = @InstId
              AND SF.SessionId = @SessId
              AND ISNULL(SF.IsActive, 1) = 1
              AND S.IsActive = @IsActive
        ");

        cmd.Parameters.AddWithValue("@TeacherId", teacherUserId);
        cmd.Parameters.AddWithValue("@InstId", instituteId);
        cmd.Parameters.AddWithValue("@SessId", sessionId);
        cmd.Parameters.AddWithValue("@IsActive", isActive);

        return _dl.GetDataTable(cmd);
    }

    // ── Toggle Status & return descriptive message ─────────────────────────
    public string ToggleSubjectStatus(int subjectId)
        {
            SqlCommand check = new SqlCommand(
                "SELECT SubjectName, IsActive FROM Subjects WHERE SubjectId = @Id");
            check.Parameters.AddWithValue("@Id", subjectId);
            DataTable dt = _dl.GetDataTable(check);

            if (dt == null || dt.Rows.Count == 0) return "Subject not found.";

            string name = dt.Rows[0]["SubjectName"].ToString();
            bool current = Convert.ToBoolean(dt.Rows[0]["IsActive"]);

            SqlCommand cmd = new SqlCommand(
                "UPDATE Subjects SET IsActive = CASE WHEN IsActive = 1 THEN 0 ELSE 1 END WHERE SubjectId = @Id");
            cmd.Parameters.AddWithValue("@Id", subjectId);
            _dl.ExecuteCMD(cmd);

            return current
                ? $"'{name}' deactivated successfully."
                : $"'{name}' activated successfully.";
        }

        // ── Filter Dropdowns ──────────────────────────────────────────────────
        public DataTable GetFilterData(int instituteId, int sessionId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT 'Stream'   AS Type, StreamId   AS Id, StreamName   AS Name FROM Streams     WHERE InstituteId = @InstId AND IsActive = 1
                UNION ALL
                SELECT 'Course',           CourseId,         CourseName          FROM Courses     WHERE InstituteId = @InstId AND IsActive = 1
                UNION ALL
                SELECT 'Level',            LevelId,          LevelName           FROM StudyLevels WHERE InstituteId = @InstId AND SessionId = @SessId
                UNION ALL
                SELECT 'Semester',         SemesterId,       SemesterName        FROM Semesters   WHERE InstituteId = @InstId AND SessionId = @SessId
                ORDER BY Type, Name");

            cmd.Parameters.AddWithValue("@InstId", instituteId);
            cmd.Parameters.AddWithValue("@SessId", sessionId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }
 }
