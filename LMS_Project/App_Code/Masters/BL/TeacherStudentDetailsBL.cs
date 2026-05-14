using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using LMS_Project.GC;

namespace LMS_Project.BL
{
    public class TeacherStudentDetailsBL
    {
        DataLayer dl = new DataLayer();

        // ── Main method returning full student details ────────────────
        public TeacherStudentGC GetStudentProfile(int userId)
        {
            SqlCommand cmd = new SqlCommand(@"
        SELECT TOP 1
            U.Email, 
            ISNULL(P.FullName,            '')  AS FullName,
            ISNULL(P.Gender,              '')  AS Gender,
            P.DOB,
            ISNULL(P.ContactNo,           '')  AS ContactNo,
            ISNULL(P.Address,             '')  AS Address, 
            ISNULL(P.City,                '')  AS City,
            P.Pincode,
            ISNULL(P.EmergencyContactName,'')  AS EmergencyContactName,
            ISNULL(P.EmergencyContactNo,  '')  AS EmergencyContactNo, 
            ISNULL(P.Skills,              '')  AS Skills,
            ISNULL(P.Hobbies,             '')  AS Hobbies,
            ISNULL(P.ProfileImage,        '')  AS ProfileImage,
            ISNULL(SAD.RollNumber,        '')  AS RollNumber, 
            ISNULL(S.StreamName,          '')  AS StreamName, 
            ISNULL(C.CourseName,          '')  AS CourseName, 
            ISNULL(Sem.SemesterName,      '')  AS SemesterName, 
            ISNULL(Sty.LevelName,         '')  AS LevelName,
            ISNULL(Sec.SectionName,       '')  AS SectionName,
            ISNULL(Ses.SessionName,       '')  AS SessionName,
            ISNULL(SAD.StreamId,  0) AS StreamId,
            ISNULL(SAD.CourseId,  0) AS CourseId,
            ISNULL(SAD.LevelId,   0) AS LevelId,
            ISNULL(SAD.SemesterId,0) AS SemesterId,
            ISNULL(SAD.SectionId, 0) AS SectionId,
            ISNULL(SAD.SessionId, 0) AS SessionId,
            ISNULL(SAD.InstituteId,0) AS InstituteId,
            ISNULL(SAD.SocietyId, 0) AS SocietyId
        FROM Users U 
        LEFT JOIN UserProfile P               ON U.UserId      = P.UserId
        LEFT JOIN StudentAcademicDetails SAD  ON U.UserId      = SAD.UserId
        LEFT JOIN Streams S                   ON SAD.StreamId  = S.StreamId
        LEFT JOIN Courses C                   ON SAD.CourseId  = C.CourseId
        LEFT JOIN Semesters Sem               ON SAD.SemesterId = Sem.SemesterId
        LEFT JOIN StudyLevels Sty             ON SAD.LevelId   = Sty.LevelId
        LEFT JOIN Sections Sec                ON SAD.SectionId = Sec.SectionId
        LEFT JOIN AcademicSessions Ses        ON SAD.SessionId = Ses.SessionId
        WHERE U.UserId = @U;
    ");
            cmd.Parameters.AddWithValue("@U", userId);

            DataTable dt = dl.GetDataTable(cmd);
            if (dt == null || dt.Rows.Count == 0) return null;

            DataRow r = dt.Rows[0];
            return new TeacherStudentGC
            {
                UserId = userId,
                Email = r["Email"]?.ToString() ?? "",
                FullName = r["FullName"]?.ToString() ?? "",
                Gender = r["Gender"]?.ToString() ?? "",
                DOB = r["DOB"] != DBNull.Value ? (DateTime?)Convert.ToDateTime(r["DOB"]) : null,
                ContactNo = r["ContactNo"]?.ToString() ?? "",
                Address = r["Address"]?.ToString() ?? "",
                City = r["City"]?.ToString() ?? "",
                Pincode = r["Pincode"] != DBNull.Value ? (int?)Convert.ToInt32(r["Pincode"]) : null,
                EmergencyContactName = r["EmergencyContactName"]?.ToString() ?? "",
                EmergencyContactNo = r["EmergencyContactNo"]?.ToString() ?? "",
                Skills = r["Skills"]?.ToString() ?? "",
                Hobbies = r["Hobbies"]?.ToString() ?? "",
                ProfileImage = r["ProfileImage"]?.ToString() ?? "",
                RollNumber = r["RollNumber"]?.ToString() ?? "",
                StreamName = r["StreamName"]?.ToString() ?? "",
                CourseName = r["CourseName"]?.ToString() ?? "",
                SemesterName = r["SemesterName"]?.ToString() ?? "",
                LevelName = r["LevelName"]?.ToString() ?? "",
                SectionName = r["SectionName"]?.ToString() ?? "",
                SessionName = r["SessionName"]?.ToString() ?? "",

                StreamId = Convert.ToInt32(r["StreamId"]) > 0 ? (int?)Convert.ToInt32(r["StreamId"]) : null,
                CourseId = Convert.ToInt32(r["CourseId"]) > 0 ? (int?)Convert.ToInt32(r["CourseId"]) : null,
                LevelId = Convert.ToInt32(r["LevelId"]) > 0 ? (int?)Convert.ToInt32(r["LevelId"]) : null,
                SemesterId = Convert.ToInt32(r["SemesterId"]) > 0 ? (int?)Convert.ToInt32(r["SemesterId"]) : null,
                SectionId = Convert.ToInt32(r["SectionId"]) > 0 ? (int?)Convert.ToInt32(r["SectionId"]) : null,
                SessionId = Convert.ToInt32(r["SessionId"]),
                InstituteId = Convert.ToInt32(r["InstituteId"]),
                SocietyId = Convert.ToInt32(r["SocietyId"]),
            };
        }
        public TeacherStudentGC GetAttendanceSummary(int userId, int teacherUserId)
        {
            SqlCommand cmd = new SqlCommand(@"
        SELECT 
            ISNULL(SUM(CASE WHEN A.Status='Present' THEN 1 ELSE 0 END), 0) AS Present,
            ISNULL(SUM(CASE WHEN A.Status='Absent'  THEN 1 ELSE 0 END), 0) AS Absent,
            ISNULL(SUM(CASE WHEN A.Status='Leave'   THEN 1 ELSE 0 END), 0) AS Leave
        FROM Attendance A
        WHERE A.UserId = @U
          AND A.SubjectId IN (
              SELECT SF.SubjectId FROM SubjectFaculty SF
              WHERE SF.TeacherId = @T AND SF.IsActive = 1
          )
    ");
            cmd.Parameters.AddWithValue("@U", userId);
            cmd.Parameters.AddWithValue("@T", teacherUserId);

            DataTable dt = dl.GetDataTable(cmd);
            if (dt == null || dt.Rows.Count == 0)
                return new TeacherStudentGC { Present = 0, Absent = 0, Leave = 0 };

            DataRow r = dt.Rows[0];
            return new TeacherStudentGC
            {
                Present = Convert.ToInt32(r["Present"]),
                Absent = Convert.ToInt32(r["Absent"]),
                Leave = Convert.ToInt32(r["Leave"])
            };
        }        // ── Subjects + Progress ──────────────────────────────────────
        public List<TeacherStudentSubjectGC> GetSubjects(int userId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT 
                    Sub.SubjectId, 
                    Sub.SubjectName, 
                    ISNULL(TProf.FullName, 'TBD') AS TeacherName,
                    ISNULL(
                        (
                            SELECT COUNT(*) 
                            FROM VideoViews VV 
                            JOIN Videos V    ON VV.VideoId  = V.VideoId 
                            JOIN Chapters Ch ON V.ChapterId = Ch.ChapterId 
                            WHERE VV.UserId      = @U 
                              AND VV.IsCompleted  = 1 
                              AND Ch.SubjectId   = Sub.SubjectId
                        ) * 100 / NULLIF(
                            (
                                SELECT COUNT(*) 
                                FROM Videos V 
                                JOIN Chapters Ch ON V.ChapterId = Ch.ChapterId 
                                WHERE Ch.SubjectId = Sub.SubjectId
                            ), 0
                        ), 0
                    ) AS Progress
                FROM AssignStudentSubject A
                JOIN Subjects Sub           ON A.SubjectId   = Sub.SubjectId
                LEFT JOIN SubjectFaculty SF  ON Sub.SubjectId = SF.SubjectId AND SF.IsActive = 1
                LEFT JOIN UserProfile TProf  ON SF.TeacherId  = TProf.UserId
                WHERE A.UserId = @U;
            ");
            cmd.Parameters.AddWithValue("@U", userId);

            DataTable dt = dl.GetDataTable(cmd);
            var list = new List<TeacherStudentSubjectGC>();

            if (dt == null) return list;

            foreach (DataRow r in dt.Rows)
            {
                list.Add(new TeacherStudentSubjectGC
                {
                    SubjectId = Convert.ToInt32(r["SubjectId"]),
                    SubjectName = r["SubjectName"].ToString(),
                    TeacherName = r["TeacherName"].ToString(),
                    Progress = Convert.ToInt32(r["Progress"])
                });
            }

            return list;
        }

        // ── Recent Activity ──────────────────────────────────────────
        public List<TeacherStudentActivityGC> GetRecentActivity(int userId)
        {
            var list = new List<TeacherStudentActivityGC>();

            SqlCommand cmd = new SqlCommand(@"
                IF OBJECT_ID('UserActivityLog', 'U') IS NOT NULL
                BEGIN
                    SELECT TOP 10 ActivityType, ActionTime 
                    FROM UserActivityLog 
                    WHERE UserId = @U 
                    ORDER BY ActionTime DESC;
                END
                ELSE
                BEGIN
                    SELECT TOP 0 
                        CAST(NULL AS NVARCHAR(100)) AS ActivityType, 
                        CAST(NULL AS DATETIME)      AS ActionTime;
                END
            ");
            cmd.Parameters.AddWithValue("@U", userId);

            DataTable dt = dl.GetDataTable(cmd);

            if (dt == null) return list;

            foreach (DataRow r in dt.Rows)
            {
                list.Add(new TeacherStudentActivityGC
                {
                    ActivityType = r["ActivityType"].ToString(),
                    ActionTime = Convert.ToDateTime(r["ActionTime"])
                });
            }

            return list;
        }

        // ── Overall Progress Stats ───────────────────────────────────
        public TeacherStudentGC GetProgressStats(int userId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT 
                    (SELECT COUNT(*) FROM VideoViews           WHERE UserId    = @U AND IsCompleted = 1) AS Videos,
                    (SELECT COUNT(*) FROM AssignmentSubmissions WHERE StudentId = @U)                    AS Assignments;
            ");
            cmd.Parameters.AddWithValue("@U", userId);

            DataTable dt = dl.GetDataTable(cmd);

            if (dt == null || dt.Rows.Count == 0)
                return new TeacherStudentGC { VideosCompleted = 0, AssignmentsSubmitted = 0 };

            DataRow r = dt.Rows[0];
            return new TeacherStudentGC
            {
                VideosCompleted = Convert.ToInt32(r["Videos"]),
                AssignmentsSubmitted = Convert.ToInt32(r["Assignments"])
            };
        }
        // ── Recent Videos Watched ────────────────────────────────────
        public List<TeacherStudentActivityGC> GetRecentVideos(int userId)
        {
            var list = new List<TeacherStudentActivityGC>();
            SqlCommand cmd = new SqlCommand(@"
        SELECT TOP 10 
            V.Title        AS ActivityType,   -- ← was VideoTitle
            VV.ViewedOn    AS ActionTime,     -- ← was WatchedOn
            Sub.SubjectName
        FROM VideoViews VV
        JOIN Videos V    ON VV.VideoId   = V.VideoId
        JOIN Chapters Ch ON V.ChapterId  = Ch.ChapterId
        JOIN Subjects Sub ON Ch.SubjectId = Sub.SubjectId
        WHERE VV.UserId = @U AND VV.IsCompleted = 1
        ORDER BY VV.ViewedOn DESC;            -- ← was WatchedOn
    ");
            cmd.Parameters.AddWithValue("@U", userId);
            DataTable dt = dl.GetDataTable(cmd);
            if (dt == null) return list;
            foreach (DataRow r in dt.Rows)
                list.Add(new TeacherStudentActivityGC
                {
                    ActivityType = r["ActivityType"].ToString(),
                    ActionTime = Convert.ToDateTime(r["ActionTime"]),
                    SubjectName = r["SubjectName"].ToString()
                });
            return list;
        }
        // ── Recent Assignments Submitted ─────────────────────────────
        public List<TeacherStudentActivityGC> GetRecentAssignments(int userId)
        {
            var list = new List<TeacherStudentActivityGC>();
            SqlCommand cmd = new SqlCommand(@"
        SELECT TOP 10 
            A.Title AS ActivityType,
            ASub.SubmittedOn AS ActionTime,
            Sub.SubjectName
        FROM AssignmentSubmissions ASub
        JOIN Assignments A ON ASub.AssignmentId = A.AssignmentId
        JOIN Subjects Sub ON A.SubjectId = Sub.SubjectId
        WHERE ASub.StudentId = @U
        ORDER BY ASub.SubmittedOn DESC;
    ");
            cmd.Parameters.AddWithValue("@U", userId);
            DataTable dt = dl.GetDataTable(cmd);
            if (dt == null) return list;
            foreach (DataRow r in dt.Rows)
                list.Add(new TeacherStudentActivityGC
                {
                    ActivityType = r["ActivityType"].ToString(),
                    ActionTime = Convert.ToDateTime(r["ActionTime"]),
                    SubjectName = r["SubjectName"].ToString()
                });
            return list;
        }

        // ── Chart: Videos per Subject ────────────────────────────────
        public DataTable GetVideosBySubject(int userId, int teacherUserId)
        {
            SqlCommand cmd = new SqlCommand(@"
        SELECT Sub.SubjectName,
               COUNT(*) AS WatchedCount
        FROM VideoViews VV
        JOIN Videos V    ON VV.VideoId   = V.VideoId
        JOIN Chapters Ch ON V.ChapterId  = Ch.ChapterId
        JOIN Subjects Sub ON Ch.SubjectId = Sub.SubjectId
        WHERE VV.UserId = @U 
          AND VV.IsCompleted = 1
          AND Sub.SubjectId IN (
              SELECT SF.SubjectId FROM SubjectFaculty SF
              WHERE SF.TeacherId = @T AND SF.IsActive = 1
          )
        GROUP BY Sub.SubjectName;
    ");
            cmd.Parameters.AddWithValue("@U", userId);
            cmd.Parameters.AddWithValue("@T", teacherUserId);
            return dl.GetDataTable(cmd);
        }
        // ── Chart: Assignments Completed vs Due ─────────────────────
        public TeacherStudentGC GetAssignmentStats(int userId, int teacherUserId)
        {
            SqlCommand cmd = new SqlCommand(@"
        -- All assignments for this teacher's subjects that are assigned to this student
        ;WITH TeacherAssignments AS (
            SELECT DISTINCT Asgn.AssignmentId, Asgn.DueDate
            FROM Assignments Asgn
            WHERE Asgn.IsActive = 1
              AND Asgn.SubjectId IN (
                  SELECT SF.SubjectId FROM SubjectFaculty SF
                  WHERE SF.TeacherId = @T AND SF.IsActive = 1
              )
              AND Asgn.SubjectId IN (
                  SELECT A.SubjectId FROM AssignStudentSubject A
                  WHERE A.UserId = @U
              )
        ),
        SubmittedIds AS (
            SELECT AssignmentId FROM AssignmentSubmissions WHERE StudentId = @U
        )
        SELECT
            SUM(CASE WHEN s.AssignmentId IS NOT NULL THEN 1 ELSE 0 END) AS Submitted,
            SUM(CASE WHEN s.AssignmentId IS NULL 
                      AND ta.DueDate IS NOT NULL 
                      AND ta.DueDate < GETDATE() THEN 1 ELSE 0 END)     AS Overdue,
            SUM(CASE WHEN s.AssignmentId IS NULL 
                      AND (ta.DueDate IS NULL 
                           OR ta.DueDate >= GETDATE()) THEN 1 ELSE 0 END) AS Pending
        FROM TeacherAssignments ta
        LEFT JOIN SubmittedIds s ON ta.AssignmentId = s.AssignmentId;
    ");
            cmd.Parameters.AddWithValue("@U", userId);
            cmd.Parameters.AddWithValue("@T", teacherUserId);

            DataTable dt = dl.GetDataTable(cmd);
            if (dt == null || dt.Rows.Count == 0)
                return new TeacherStudentGC { AssignmentsSubmitted = 0, AssignmentsOverdue = 0, AssignmentsPending = 0 };

            DataRow r = dt.Rows[0];
            return new TeacherStudentGC
            {
                AssignmentsSubmitted = Convert.ToInt32(r["Submitted"]),
                AssignmentsOverdue = Convert.ToInt32(r["Overdue"]),
                AssignmentsPending = Convert.ToInt32(r["Pending"])   // ← add to GC
            };
        }

        // ── Marks detail per assignment (graded only) ────────────────
        public DataTable GetStudentMarksDetail(int userId, int teacherUserId, int sessionId)
        {
            SqlCommand cmd = new SqlCommand(@"
        SELECT
            A.Title        AS AssignmentTitle,
            Sub.SubjectName,
            ASub.MarksObtained,
            A.MaxMarks,
            ISNULL(ROUND(100.0 * ASub.MarksObtained / NULLIF(A.MaxMarks,0), 1), 0) AS Percentage,
            ASub.SubmittedOn
        FROM AssignmentSubmissions ASub
        JOIN Assignments A   ON ASub.AssignmentId = A.AssignmentId
        JOIN Subjects Sub    ON A.SubjectId = Sub.SubjectId
        WHERE ASub.StudentId = @U
          AND ASub.MarksObtained IS NOT NULL
          AND A.SessionId = @SessionId
          AND A.SubjectId IN (
              SELECT SF.SubjectId FROM SubjectFaculty SF
              WHERE SF.TeacherId = @T AND SF.IsActive = 1
          )
        ORDER BY ASub.SubmittedOn DESC
    ");
            cmd.Parameters.AddWithValue("@U", userId);
            cmd.Parameters.AddWithValue("@T", teacherUserId);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);
            return dl.GetDataTable(cmd);
        }

        // ── Attendance by subject ────────────────────────────────────
        public DataTable GetAttendanceBySubject(int userId, int teacherUserId)
        {
            SqlCommand cmd = new SqlCommand(@"
        SELECT
            Sub.SubjectName,
            SUM(CASE WHEN A.Status='Present' THEN 1 ELSE 0 END) AS PresentCount,
            SUM(CASE WHEN A.Status='Absent'  THEN 1 ELSE 0 END) AS AbsentCount
        FROM Attendance A
        JOIN Subjects Sub ON A.SubjectId = Sub.SubjectId
        WHERE A.UserId = @U
          AND A.SubjectId IN (
              SELECT SF.SubjectId FROM SubjectFaculty SF
              WHERE SF.TeacherId = @T AND SF.IsActive = 1
          )
        GROUP BY Sub.SubjectId, Sub.SubjectName
    ");
            cmd.Parameters.AddWithValue("@U", userId);
            cmd.Parameters.AddWithValue("@T", teacherUserId);
            return dl.GetDataTable(cmd);
        }

        // ── Quiz attempt count ───────────────────────────────────────
        public int GetQuizAttemptCount(int userId, int sessionId)
        {
            SqlCommand cmd = new SqlCommand(@"
        SELECT COUNT(*) FROM QuizResults
        WHERE StudentId = @U AND SessionId = @SessionId
    ");
            cmd.Parameters.AddWithValue("@U", userId);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);
            DataTable dt = dl.GetDataTable(cmd);
            if (dt == null || dt.Rows.Count == 0) return 0;
            return Convert.ToInt32(dt.Rows[0][0]);
        }
    }
}