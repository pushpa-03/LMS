using System;
using System.Data;
using System.Data.SqlClient;
    public class SubjectDetailsBL
    {
        private readonly DataLayer _dl = new DataLayer();

        // ── Subject Header ─────────────────────────────────────────────────────
        public DataTable GetSubjectDetails(int subjectId, int sessionId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT TOP 1
                    S.SubjectId, S.SubjectName, S.SubjectCode,
                    S.Duration, S.Description, S.IsActive,
                    So.SocietyName,
                    I.InstituteName,
                    ISNULL(St.StreamName,  'N/A') AS StreamName,
                    ISNULL(C.CourseName,   'N/A') AS CourseName,
                    ISNULL(SL.LevelName,   'N/A') AS LevelName,
                    ISNULL(Sem.SemesterName,'N/A') AS SemesterName
                FROM Subjects S
                LEFT JOIN Societies   So  ON S.SocietyId   = So.SocietyId
                LEFT JOIN Institutes  I   ON S.InstituteId  = I.InstituteId
                LEFT JOIN LevelSemesterSubjects LSS
                    ON S.SubjectId = LSS.SubjectId AND LSS.SessionId = @SessionId
                LEFT JOIN Streams     St  ON LSS.StreamId   = St.StreamId
                LEFT JOIN Courses     C   ON LSS.CourseId   = C.CourseId
                LEFT JOIN StudyLevels SL  ON LSS.LevelId    = SL.LevelId
                LEFT JOIN Semesters   Sem ON LSS.SemesterId = Sem.SemesterId
                WHERE S.SubjectId = @SubjectId");

            cmd.Parameters.AddWithValue("@SubjectId", subjectId);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        // ── Chapters ───────────────────────────────────────────────────────────
        public DataTable GetChapters(int subjectId, int sessionId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT ChapterId, ChapterName, OrderNo, IsActive
                FROM Chapters
                WHERE SubjectId = @SubjectId AND SessionId = @SessionId AND IsActive = 1
                ORDER BY OrderNo, ChapterId");
            cmd.Parameters.AddWithValue("@SubjectId", subjectId);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        public DataTable GetChapterById(int chapterId, int sessionId)
        {
            SqlCommand cmd = new SqlCommand(
                "SELECT ChapterId, ChapterName, OrderNo FROM Chapters WHERE ChapterId = @Id AND SessionId = @SessionId");
            cmd.Parameters.AddWithValue("@Id", chapterId);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        public void SaveChapter(string chapterId, int sessionId, string subjectId,
            string name, string orderNo, int societyId, int instituteId)
        {
            SqlCommand cmd = new SqlCommand();
            int order = 0; int.TryParse(orderNo, out order);

            if (string.IsNullOrEmpty(chapterId) || chapterId == "0")
            {
                cmd.CommandText = @"
                    INSERT INTO Chapters (SocietyId, InstituteId, SessionId, SubjectId, ChapterName, OrderNo, IsActive)
                    VALUES (@SocId, @InstId, @SessionId, @SubjectId, @Name, @OrderNo, 1)";
                cmd.Parameters.AddWithValue("@SocId", societyId);
                cmd.Parameters.AddWithValue("@InstId", instituteId);
            }
            else
            {
                cmd.CommandText = @"
                    UPDATE Chapters SET ChapterName = @Name, OrderNo = @OrderNo
                    WHERE ChapterId = @ChapterId AND SessionId = @SessionId";
                cmd.Parameters.AddWithValue("@ChapterId", chapterId);
            }

            cmd.Parameters.AddWithValue("@SubjectId", subjectId);
            cmd.Parameters.AddWithValue("@Name", name);
            cmd.Parameters.AddWithValue("@OrderNo", order);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);
            _dl.ExecuteCMD(cmd);
        }

        public void DeleteChapter(int chapterId, int sessionId)
        {
            // Soft delete: mark IsActive = 0 (preserves history)
            SqlCommand cmd = new SqlCommand(
                "UPDATE Chapters SET IsActive = 0 WHERE ChapterId = @Id AND SessionId = @SessionId");
            cmd.Parameters.AddWithValue("@Id", chapterId);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);
            _dl.ExecuteCMD(cmd);
        }

        // ── Videos ────────────────────────────────────────────────────────────
        public DataTable GetVideosByChapter(int chapterId, int sessionId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT
                    V.VideoId, V.Title, V.Duration, V.VideoPath,
                    V.ViewCount, V.UploadedOn, V.IsActive,
                    ISNULL(UP.FullName, 'Unknown') AS InstructorName
                FROM Videos V
                LEFT JOIN UserProfile UP ON V.InstructorId = UP.UserId
                WHERE V.ChapterId = @Cid AND V.SessionId = @SessionId AND V.IsActive = 1
                ORDER BY V.VideoId");
            cmd.Parameters.AddWithValue("@Cid", chapterId);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        public int InsertVideo(int societyId, int instituteId, int sessionId,
            int chapterId, int subjectId, string title, string desc,
            string path, int instructorId, int uploadedBy)
        {
            SqlCommand cmd = new SqlCommand(@"
                INSERT INTO Videos
                    (SocietyId, InstituteId, SessionId, ChapterId, SubjectId,
                     Title, Duration, Description, VideoPath,
                     InstructorId, ViewCount, UploadedBy, UploadedOn, IsActive)
                VALUES
                    (@SocId, @InstId, @SessionId, @ChapterId, @SubjectId,
                     @Title, '', @Desc, @Path,
                     @InstructorId, 0, @UploadedBy, GETDATE(), 1);
                SELECT CAST(SCOPE_IDENTITY() AS INT);");

            cmd.Parameters.AddWithValue("@SocId", societyId);
            cmd.Parameters.AddWithValue("@InstId", instituteId);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);
            cmd.Parameters.AddWithValue("@ChapterId", chapterId);
            cmd.Parameters.AddWithValue("@SubjectId", subjectId);
            cmd.Parameters.AddWithValue("@Title", title);
            cmd.Parameters.AddWithValue("@Desc", desc);
            cmd.Parameters.AddWithValue("@Path", path);
            cmd.Parameters.AddWithValue("@InstructorId", instructorId > 0 ? (object)instructorId : DBNull.Value);
            cmd.Parameters.AddWithValue("@UploadedBy", uploadedBy);

            DataTable dt = _dl.GetDataTable(cmd);
            return (dt != null && dt.Rows.Count > 0) ? Convert.ToInt32(dt.Rows[0][0]) : 0;
        }

        public void InsertVideoTopics(int societyId, int instituteId, int sessionId,
            int videoId, string[] times, string[] titles)
        {
            for (int i = 0; i < Math.Min(times.Length, titles.Length); i++)
            {
                if (string.IsNullOrWhiteSpace(titles[i])) continue;
                SqlCommand cmd = new SqlCommand(@"
                    INSERT INTO VideoTopics (SocietyId, InstituteId, SessionId, VideoId, StartTime, TopicTitle)
                    VALUES (@SocId, @InstId, @SessionId, @VideoId, @Time, @Title)");
                cmd.Parameters.AddWithValue("@SocId", societyId);
                cmd.Parameters.AddWithValue("@InstId", instituteId);
                cmd.Parameters.AddWithValue("@SessionId", sessionId);
                cmd.Parameters.AddWithValue("@VideoId", videoId);
                cmd.Parameters.AddWithValue("@Time", times[i].Trim());
                cmd.Parameters.AddWithValue("@Title", titles[i].Trim());
                _dl.ExecuteCMD(cmd);
            }
        }

        public void DeleteVideo(int videoId, int sessionId)
        {
            SqlCommand cmd = new SqlCommand(
                "UPDATE Videos SET IsActive = 0 WHERE VideoId = @Id AND SessionId = @SessionId");
            cmd.Parameters.AddWithValue("@Id", videoId);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);
            _dl.ExecuteCMD(cmd);
        }

        // ── Materials ─────────────────────────────────────────────────────────
        public DataTable GetMaterialsByChapter(int chapterId, int sessionId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT MaterialId, Title, FilePath, FileType, UploadedOn
                FROM Materials
                WHERE ChapterId = @Cid AND SessionId = @SessionId
                ORDER BY UploadedOn DESC");
            cmd.Parameters.AddWithValue("@Cid", chapterId);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        public void InsertMaterial(int societyId, int instituteId, int sessionId,
            int chapterId, string title, string path, string fileType)
        {
            SqlCommand cmd = new SqlCommand(@"
                INSERT INTO Materials (SocietyId, InstituteId, SessionId, ChapterId, Title, FilePath, FileType, UploadedOn)
                VALUES (@SocId, @InstId, @SessionId, @ChapterId, @Title, @Path, @Type, GETDATE())");
            cmd.Parameters.AddWithValue("@SocId", societyId);
            cmd.Parameters.AddWithValue("@InstId", instituteId);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);
            cmd.Parameters.AddWithValue("@ChapterId", chapterId);
            cmd.Parameters.AddWithValue("@Title", title);
            cmd.Parameters.AddWithValue("@Path", path);
            cmd.Parameters.AddWithValue("@Type", fileType);
            _dl.ExecuteCMD(cmd);
        }

        public void DeleteMaterial(int materialId, int sessionId)
        {
            SqlCommand cmd = new SqlCommand(
                "DELETE FROM Materials WHERE MaterialId = @Id AND SessionId = @SessionId");
            cmd.Parameters.AddWithValue("@Id", materialId);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);
            _dl.ExecuteCMD(cmd);
        }

        // ── Assignments ───────────────────────────────────────────────────────
        public DataTable GetAssignmentsBySubject(int subjectId, int sessionId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT AssignmentId, Title, Description, MaxMarks, DueDate, CreatedOn
                FROM Assignments
                WHERE SubjectId = @SubjectId AND SessionId = @SessionId AND IsActive = 1
                ORDER BY CreatedOn DESC");
            cmd.Parameters.AddWithValue("@SubjectId", subjectId);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        // ── Teacher search for instructor dropdown ────────────────────────────
        public DataTable SearchTeachersForSubject(string query, int subjectId, int instituteId, int sessionId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT DISTINCT
                    U.UserId,
                    ISNULL(UP.FullName, U.Username) AS FullName,
                    ISNULL(TD.Designation, 'Teacher') AS Designation
                FROM SubjectFaculty SF
                INNER JOIN Users       U  ON SF.TeacherId = U.UserId
                LEFT JOIN  UserProfile UP ON U.UserId     = UP.UserId
                LEFT JOIN  TeacherDetails TD ON U.UserId  = TD.UserId
                WHERE SF.SubjectId   = @SubjectId
                  AND SF.InstituteId = @InstId
                  AND SF.SessionId   = @SessionId
                  AND SF.IsActive    = 1
                  AND (UP.FullName LIKE @Q OR U.Username LIKE @Q)
                ORDER BY FullName");

            cmd.Parameters.AddWithValue("@SubjectId", subjectId);
            cmd.Parameters.AddWithValue("@InstId", instituteId);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);
            cmd.Parameters.AddWithValue("@Q", "%" + query + "%");
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        // ── Notify enrolled students ──────────────────────────────────────────
        public void NotifyStudents(int societyId, int instituteId, int sessionId,
            int subjectId, string message)
        {
            SqlCommand cmd = new SqlCommand(@"
                INSERT INTO Notifications (SocietyId, InstituteId, SessionId, UserId, Message, NotificationType, IsRead, CreatedOn)
                SELECT @SocId, @InstId, @SessionId, ASS.UserId, @Message, 'Content', 0, GETDATE()
                FROM AssignStudentSubject ASS
                WHERE ASS.SubjectId  = @SubjectId
                  AND ASS.SessionId  = @SessionId
                  AND ASS.InstituteId = @InstId");
            cmd.Parameters.AddWithValue("@SocId", societyId);
            cmd.Parameters.AddWithValue("@InstId", instituteId);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);
            cmd.Parameters.AddWithValue("@SubjectId", subjectId);
            cmd.Parameters.AddWithValue("@Message", message);
            _dl.ExecuteCMD(cmd);
        }

        // ── Activity log ──────────────────────────────────────────────────────
        public void LogActivity(int userId, int societyId, int instituteId,
            int sessionId, string activityType)
        {
            try
            {
                SqlCommand cmd = new SqlCommand(@"
                    INSERT INTO UserActivityLog (UserId, SocietyId, InstituteId, SessionId, ActivityType, ActionTime)
                    VALUES (@UserId, @SocId, @InstId, @SessionId, @Activity, GETDATE())");
                cmd.Parameters.AddWithValue("@UserId", userId);
                cmd.Parameters.AddWithValue("@SocId", societyId);
                cmd.Parameters.AddWithValue("@InstId", instituteId);
                cmd.Parameters.AddWithValue("@SessionId", sessionId);
                cmd.Parameters.AddWithValue("@Activity", activityType);
                _dl.ExecuteCMD(cmd);
            }
            catch { /* Non-critical – don't let logging break main flow */ }
        }
    }
