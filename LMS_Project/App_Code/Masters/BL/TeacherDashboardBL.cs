using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Web.Script.Serialization;

namespace LearningManagementSystem.BL
{
    public class TeacherDashboardBL
    {
        DataLayer dl = new DataLayer();

        // ════════════════════════════════════════════════════════════
        // WELCOME BANNER
        // ════════════════════════════════════════════════════════════
        public DataTable GetTeacherWelcomeInfo(int teacherId, int instituteId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT 
                    up.FullName,
                    ISNULL(s.StreamName, '')   AS Department,
                    ISNULL(td.Designation, '') AS Designation,
                    ISNULL(ac.SessionName, '') AS SessionName
                FROM UserProfile       up
                JOIN TeacherDetails    td  ON td.UserId     = up.UserId
                LEFT JOIN Streams      s   ON s.StreamId    = td.StreamId
                LEFT JOIN AcademicSessions ac
                       ON ac.InstituteId = @InstituteId AND ac.IsCurrent = 1
                WHERE up.UserId = @TeacherId");

            cmd.Parameters.AddWithValue("@TeacherId", teacherId);
            cmd.Parameters.AddWithValue("@InstituteId", instituteId);
            return dl.GetDataTable(cmd);
        }

        // ════════════════════════════════════════════════════════════
        // STAT CARDS
        // ════════════════════════════════════════════════════════════
        public DataTable GetDashboardStats(int teacherId, int instituteId, int sessionId)
        {
            SqlCommand cmd = new SqlCommand(@"
        SELECT
            (
                SELECT COUNT(DISTINCT SF.SubjectId)
                FROM   SubjectFaculty SF
                WHERE  SF.TeacherId   = @TeacherId
                  AND  SF.InstituteId = @InstituteId
                  AND  SF.SessionId   = @SessionId
                  AND  ISNULL(SF.IsActive, 1) = 1
            ) AS TotalSubjects,

            (
                SELECT COUNT(DISTINCT ass.UserId)
                FROM   AssignStudentSubject ass
                JOIN   SubjectFaculty SF
                       ON  SF.SubjectId = ass.SubjectId
                       AND SF.SessionId = ass.SessionId
                WHERE  SF.TeacherId   = @TeacherId
                  AND  SF.InstituteId = @InstituteId
                  AND  ISNULL(SF.IsActive, 1) = 1
            ) AS TotalStudents,

            (
                SELECT COUNT(DISTINCT a.AssignmentId)
                FROM   Assignments    a
                JOIN   SubjectFaculty SF ON SF.SubjectId = a.SubjectId
                WHERE  SF.TeacherId   = @TeacherId
                  AND  SF.InstituteId = @InstituteId
                  AND  SF.SessionId   = @SessionId
                  AND  ISNULL(SF.IsActive, 1) = 1
                  AND  a.IsActive     = 1
            ) AS TotalAssignments,

            (
                SELECT COUNT(DISTINCT v.VideoId)
                FROM   Videos         v
                JOIN   Chapters       c  ON c.ChapterId  = v.ChapterId
                JOIN   SubjectFaculty SF ON SF.SubjectId = c.SubjectId
                WHERE  SF.TeacherId   = @TeacherId
                  AND  SF.InstituteId = @InstituteId
                  AND  SF.SessionId   = @SessionId
                  AND  ISNULL(SF.IsActive, 1) = 1
                  AND  v.IsActive     = 1
            ) AS TotalVideos
    ");

            cmd.Parameters.AddWithValue("@TeacherId", teacherId);
            cmd.Parameters.AddWithValue("@InstituteId", instituteId);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);
            return dl.GetDataTable(cmd);
        }

        // ════════════════════════════════════════════════════════════
        // FILTER DROPDOWNS
        // ════════════════════════════════════════════════════════════
        public DataTable GetSessionsForFilter(int instituteId, int societyId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT SessionId, SessionName
                FROM   AcademicSessions
                WHERE  InstituteId = @InstituteId
                  AND  SocietyId   = @SocietyId
                ORDER  BY StartDate DESC");

            cmd.Parameters.AddWithValue("@InstituteId", instituteId);
            cmd.Parameters.AddWithValue("@SocietyId", societyId);
            return dl.GetDataTable(cmd);
        }

        public int GetCurrentSessionId(int instituteId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT TOP 1 SessionId
                FROM   AcademicSessions
                WHERE  InstituteId = @InstituteId
                  AND  IsCurrent   = 1");

            cmd.Parameters.AddWithValue("@InstituteId", instituteId);
            DataTable dt = dl.GetDataTable(cmd);
            return dt.Rows.Count > 0 ? Convert.ToInt32(dt.Rows[0]["SessionId"]) : 0;
        }

        public DataTable GetSectionsForFilter(int teacherId, int instituteId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT DISTINCT sec.SectionId, sec.SectionName
                FROM   SubjectFaculty SF
                JOIN   Sections       sec ON sec.SectionId = SF.SectionId
                WHERE  SF.TeacherId   = @TeacherId
                  AND  SF.InstituteId = @InstituteId
                  AND  ISNULL(SF.IsActive, 1) = 1
                ORDER  BY sec.SectionName");

            cmd.Parameters.AddWithValue("@TeacherId", teacherId);
            cmd.Parameters.AddWithValue("@InstituteId", instituteId);
            return dl.GetDataTable(cmd);
        }

        public DataTable GetStreamsForFilter(int teacherId, int instituteId)
        {
            SqlCommand cmd = new SqlCommand(@"
        SELECT DISTINCT st.StreamId, st.StreamName
        FROM   SubjectFaculty SF
        JOIN   Subjects       S   ON S.SubjectId  = SF.SubjectId
        JOIN   LevelSemesterSubjects LSS 
                             ON LSS.SubjectId = SF.SubjectId
        JOIN   Streams        st  ON st.StreamId  = LSS.StreamId
        WHERE  SF.TeacherId   = @TeacherId
          AND  SF.InstituteId = @InstituteId
          AND  ISNULL(SF.IsActive, 1) = 1
        ORDER  BY st.StreamName");

            cmd.Parameters.AddWithValue("@TeacherId", teacherId);
            cmd.Parameters.AddWithValue("@InstituteId", instituteId);
            return dl.GetDataTable(cmd);
        }

        // ════════════════════════════════════════════════════════════
        // SUBJECTS
        // ════════════════════════════════════════════════════════════
        public DataTable GetTeacherSubjects(
     int teacherId, int instituteId, int societyId,
     int sessionId, int sectionId, int streamId)
        {
            SqlCommand cmd = new SqlCommand(@"
        SELECT
            S.SubjectId,
            ISNULL(S.SubjectCode, '')    AS SubjectCode,
            S.SubjectName,
            ISNULL(S.Duration, '')       AS Duration,
            ISNULL(SEC.SectionName, '')  AS SectionName,
            ASY.SessionName,
            ''                           AS StreamName,
            ''                           AS CourseName,
            (
                SELECT COUNT(DISTINCT ass.UserId)
                FROM   AssignStudentSubject ass
                WHERE  ass.SubjectId   = SF.SubjectId
                  AND  ass.SessionId   = SF.SessionId
                  AND  ass.InstituteId = SF.InstituteId
            ) AS StudentCount
        FROM   SubjectFaculty       SF
        INNER JOIN Subjects         S   ON S.SubjectId   = SF.SubjectId
        LEFT  JOIN Sections         SEC ON SEC.SectionId = SF.SectionId
        INNER JOIN AcademicSessions ASY ON ASY.SessionId = SF.SessionId
        WHERE  SF.TeacherId   = @TeacherId
          AND  SF.InstituteId = @InstituteId
          AND  SF.SessionId   = @SessionId
          AND  ISNULL(SF.IsActive, 1) = 1
          AND (@SectionId = 0 OR SF.SectionId = @SectionId)
        ORDER BY S.SubjectName");

            cmd.Parameters.AddWithValue("@TeacherId", teacherId);
            cmd.Parameters.AddWithValue("@InstituteId", instituteId);
            cmd.Parameters.AddWithValue("@SessionId", sessionId == 0 ? 1 : sessionId);
            cmd.Parameters.AddWithValue("@SectionId", sectionId);
            return dl.GetDataTable(cmd);
        }

        public string GetSubjectChartJson(DataTable dt)
        {
            var list = new List<object>();
            foreach (DataRow row in dt.Rows)
                list.Add(new
                {
                    SubjectId = Convert.ToInt32(row["SubjectId"]),
                    SubjectName = row["SubjectName"].ToString(),
                    StudentCount = Convert.ToInt32(row["StudentCount"])
                });

            return new JavaScriptSerializer().Serialize(list);
        }

        // ════════════════════════════════════════════════════════════
        // RECENT STUDENTS
        // ════════════════════════════════════════════════════════════
        public DataTable GetRecentStudents(
    int teacherId, int instituteId,
    int sessionId, int sectionId, int streamId)
        {
            SqlCommand cmd = new SqlCommand(@"
        SELECT TOP 6
            up.FullName                  AS StudentName,
            ISNULL(co.CourseName,  '')   AS CourseName,
            ISNULL(sec.SectionName,'')   AS SectionName
        FROM   AssignStudentSubject      ass
        JOIN   SubjectFaculty            SF
               ON  SF.SubjectId = ass.SubjectId
               AND SF.SessionId = ass.SessionId
        JOIN   UserProfile               up  ON up.UserId    = ass.UserId
        LEFT JOIN StudentAcademicDetails sad ON sad.UserId   = ass.UserId
        LEFT JOIN Courses                co  ON co.CourseId  = sad.CourseId
        LEFT JOIN Sections               sec ON sec.SectionId = sad.SectionId
        LEFT JOIN LevelSemesterSubjects  LSS ON LSS.SubjectId = SF.SubjectId
                                            AND LSS.SessionId = SF.SessionId
        WHERE  SF.TeacherId   = @TeacherId
          AND  SF.InstituteId = @InstituteId
          AND  ISNULL(SF.IsActive, 1) = 1
          AND (@SessionId = 0 OR SF.SessionId   = @SessionId)
          AND (@SectionId = 0 OR sad.SectionId  = @SectionId)
          AND (@StreamId  = 0 OR LSS.StreamId   = @StreamId)
        ORDER BY ass.UserId DESC
    ");

            cmd.Parameters.AddWithValue("@TeacherId", teacherId);
            cmd.Parameters.AddWithValue("@InstituteId", instituteId);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);
            cmd.Parameters.AddWithValue("@SectionId", sectionId);
            cmd.Parameters.AddWithValue("@StreamId", streamId);
            return dl.GetDataTable(cmd);
        }
        // ════════════════════════════════════════════════════════════
        // ASSIGNMENT SUBJECT FILTER DROPDOWN
        // ════════════════════════════════════════════════════════════
        public DataTable GetTeacherSubjectsForFilter(int teacherId, int instituteId, int sessionId)
        {
            SqlCommand cmd = new SqlCommand(@"
        SELECT DISTINCT
            S.SubjectId,
            S.SubjectName
        FROM   SubjectFaculty SF
        JOIN   Subjects       S ON S.SubjectId = SF.SubjectId
        WHERE  SF.TeacherId   = @TeacherId
          AND  SF.InstituteId = @InstituteId
          AND  SF.SessionId   = @SessionId
          AND  ISNULL(SF.IsActive, 1) = 1
        ORDER  BY S.SubjectName
    ");

            cmd.Parameters.AddWithValue("@TeacherId", teacherId);
            cmd.Parameters.AddWithValue("@InstituteId", instituteId);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);
            return dl.GetDataTable(cmd);
        }

        // ════════════════════════════════════════════════════════════
        // RECENT ASSIGNMENTS WITH SUBJECT FILTER
        // ════════════════════════════════════════════════════════════
        public DataTable GetRecentAssignments(int teacherId, int instituteId, int subjectId)
        {
            SqlCommand cmd = new SqlCommand(@"
        SELECT TOP 8
            a.AssignmentId,
            a.Title,
            sub.SubjectName,
            ISNULL(a.MaxMarks, 0)   AS MaxMarks,
            a.DueDate,
            (
                SELECT COUNT(*)
                FROM   AssignmentSubmissions asub
                WHERE  asub.AssignmentId = a.AssignmentId
            ) AS SubmissionCount,
            (
                SELECT COUNT(DISTINCT ass.UserId)
                FROM   AssignStudentSubject ass
                JOIN   SubjectFaculty SF2
                       ON  SF2.SubjectId = ass.SubjectId
                       AND SF2.SessionId = ass.SessionId
                WHERE  SF2.SubjectId   = a.SubjectId
                  AND  SF2.TeacherId   = @TeacherId
                  AND  SF2.InstituteId = @InstituteId
            ) AS TotalStudents
        FROM   Assignments    a
        JOIN   Subjects       sub ON sub.SubjectId = a.SubjectId
        JOIN   SubjectFaculty SF  ON SF.SubjectId  = a.SubjectId
        WHERE  SF.TeacherId   = @TeacherId
          AND  SF.InstituteId = @InstituteId
          AND  ISNULL(SF.IsActive, 1) = 1
          AND  a.IsActive     = 1
          AND (@SubjectId = 0 OR a.SubjectId = @SubjectId)
        ORDER  BY a.CreatedOn DESC
    ");

            cmd.Parameters.AddWithValue("@TeacherId", teacherId);
            cmd.Parameters.AddWithValue("@InstituteId", instituteId);
            cmd.Parameters.AddWithValue("@SubjectId", subjectId);
            return dl.GetDataTable(cmd);
        }

        // ════════════════════════════════════════════════════════════
        // ASSIGNMENT CHART JSON
        // ════════════════════════════════════════════════════════════
        public string GetAssignmentChartJson(DataTable dt)
        {
            var list = new List<object>();
            foreach (DataRow row in dt.Rows)
            {
                int submitted = Convert.ToInt32(row["SubmissionCount"]);
                int total = Convert.ToInt32(row["TotalStudents"]);
                int pending = total > submitted ? total - submitted : 0;

                list.Add(new
                {
                    Title = row["Title"].ToString(),
                    SubmissionCount = submitted,
                    Pending = pending,
                    TotalStudents = total
                });
            }
            return new JavaScriptSerializer().Serialize(list);
        }

        // ════════════════════════════════════════════════════════════
        // ASSIGNMENT SUMMARY (progress bars)
        // ════════════════════════════════════════════════════════════
        public DataTable GetAssignmentSummary(DataTable dt)
        {
            // Calculate percent and return as new DataTable
            DataTable result = new DataTable();
            result.Columns.Add("Title");
            result.Columns.Add("SubmissionCount", typeof(int));
            result.Columns.Add("TotalStudents", typeof(int));
            result.Columns.Add("SubmissionPercent", typeof(int));

            foreach (DataRow row in dt.Rows)
            {
                int submitted = Convert.ToInt32(row["SubmissionCount"]);
                int total = Convert.ToInt32(row["TotalStudents"]);
                int percent = total > 0 ? (int)Math.Round((double)submitted / total * 100) : 0;

                result.Rows.Add(
                    row["Title"].ToString(),
                    submitted,
                    total,
                    percent
                );
            }
            return result;
        }

        public DataTable GetStudentsByDivision(int teacherId, int instituteId, int sessionId)
        {
            SqlCommand cmd = new SqlCommand(@"
        SELECT 
            ISNULL(sec.SectionName, 'Unassigned') AS Division,
            COUNT(DISTINCT ass.UserId)             AS StudentCount
        FROM   SubjectFaculty            SF
        JOIN   AssignStudentSubject      ass 
               ON  ass.SubjectId   = SF.SubjectId
               AND ass.SessionId   = SF.SessionId
        LEFT JOIN StudentAcademicDetails sad 
               ON  sad.UserId      = ass.UserId
        LEFT JOIN Sections               sec 
               ON  sec.SectionId   = sad.SectionId
        WHERE  SF.TeacherId   = @TeacherId
          AND  SF.InstituteId = @InstituteId
          AND  SF.SessionId   = @SessionId
          AND  ISNULL(SF.IsActive, 1) = 1
        GROUP BY sec.SectionName
        ORDER BY StudentCount DESC
    ");

            cmd.Parameters.AddWithValue("@TeacherId", teacherId);
            cmd.Parameters.AddWithValue("@InstituteId", instituteId);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);
            return dl.GetDataTable(cmd);
        }

        public DataTable GetStudentAnalytics(int teacherId, int instituteId, int sessionId)
        {
            SqlCommand cmd = new SqlCommand(@"
        SELECT
            COUNT(DISTINCT ass.UserId) AS TotalStudents,
            COUNT(DISTINCT SF.SubjectId) AS TotalSubjects,
            COUNT(DISTINCT sad.SectionId) AS TotalDivisions,
            ISNULL(
                CAST(ROUND(
                    CAST(COUNT(DISTINCT ass.UserId) AS FLOAT) / 
                    NULLIF(COUNT(DISTINCT SF.SubjectId), 0)
                , 1) AS VARCHAR), '0'
            ) AS AvgStudentsPerSubject
        FROM   SubjectFaculty            SF
        JOIN   AssignStudentSubject      ass 
               ON  ass.SubjectId   = SF.SubjectId
               AND ass.SessionId   = SF.SessionId
        LEFT JOIN StudentAcademicDetails sad 
               ON  sad.UserId      = ass.UserId
        WHERE  SF.TeacherId   = @TeacherId
          AND  SF.InstituteId = @InstituteId
          AND  SF.SessionId   = @SessionId
          AND  ISNULL(SF.IsActive, 1) = 1
    ");

            cmd.Parameters.AddWithValue("@TeacherId", teacherId);
            cmd.Parameters.AddWithValue("@InstituteId", instituteId);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);
            return dl.GetDataTable(cmd);
        }

        public string GetDivisionChartJson(DataTable dt)
        {
            var list = new List<object>();
            foreach (DataRow row in dt.Rows)
                list.Add(new
                {
                    Division = row["Division"].ToString(),
                    StudentCount = Convert.ToInt32(row["StudentCount"])
                });
            return new JavaScriptSerializer().Serialize(list);
        }
        // ════════════════════════════════════════════════════════════
        // STUDENT PERFORMANCE — KPI SUMMARY
        // ════════════════════════════════════════════════════════════
        public DataTable GetPerformanceKPIs(int teacherId, int instituteId, int sessionId)
        {
            SqlCommand cmd = new SqlCommand(@"
        SELECT
            ISNULL(CAST(ROUND(AVG(CAST(asub.MarksObtained AS FLOAT)), 1) AS VARCHAR), '0') AS AvgMarks,
            ISNULL(MAX(asub.MarksObtained), 0)   AS HighestMarks,
            ISNULL(MIN(asub.MarksObtained), 0)   AS LowestMarks,
            COUNT(asub.SubmissionId)              AS TotalGraded
        FROM   AssignmentSubmissions asub
        JOIN   Assignments           a    ON a.AssignmentId  = asub.AssignmentId
        JOIN   SubjectFaculty        SF   ON SF.SubjectId    = a.SubjectId
        WHERE  SF.TeacherId    = @TeacherId
          AND  SF.InstituteId  = @InstituteId
          AND  SF.SessionId    = @SessionId
          AND  ISNULL(SF.IsActive, 1) = 1
          AND  asub.MarksObtained IS NOT NULL");

            cmd.Parameters.AddWithValue("@TeacherId", teacherId);
            cmd.Parameters.AddWithValue("@InstituteId", instituteId);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);
            return dl.GetDataTable(cmd);
        }

        // ════════════════════════════════════════════════════════════
        // TOP 5 STUDENTS
        // ════════════════════════════════════════════════════════════
        public DataTable GetTopStudents(int teacherId, int instituteId, int sessionId)
        {
            SqlCommand cmd = new SqlCommand(@"
        SELECT TOP 5
            asub.StudentId,
            up.FullName                                           AS StudentName,
            sub.SubjectName,
            asub.MarksObtained,
            a.MaxMarks,
            ISNULL(
                CAST(ROUND(
                    CAST(asub.MarksObtained AS FLOAT) /
                    NULLIF(a.MaxMarks, 0) * 100, 0)
                AS INT), 0)                                       AS Percentage
        FROM   AssignmentSubmissions asub
        JOIN   Assignments           a    ON a.AssignmentId  = asub.AssignmentId
        JOIN   Subjects              sub  ON sub.SubjectId   = a.SubjectId
        JOIN   SubjectFaculty        SF   ON SF.SubjectId    = a.SubjectId
        JOIN   UserProfile           up   ON up.UserId       = asub.StudentId
        WHERE  SF.TeacherId    = @TeacherId
          AND  SF.InstituteId  = @InstituteId
          AND  SF.SessionId    = @SessionId
          AND  ISNULL(SF.IsActive, 1) = 1
          AND  asub.MarksObtained IS NOT NULL
          AND  a.MaxMarks > 0
        ORDER BY
            CAST(asub.MarksObtained AS FLOAT) / NULLIF(a.MaxMarks, 0) DESC");

            cmd.Parameters.AddWithValue("@TeacherId", teacherId);
            cmd.Parameters.AddWithValue("@InstituteId", instituteId);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);
            return dl.GetDataTable(cmd);
        }

        public DataTable GetLowPerformers(int teacherId, int instituteId, int sessionId)
        {
            SqlCommand cmd = new SqlCommand(@"
        SELECT TOP 5
            asub.StudentId,
            up.FullName                                           AS StudentName,
            sub.SubjectName,
            asub.MarksObtained,
            a.MaxMarks,
            ISNULL(
                CAST(ROUND(
                    CAST(asub.MarksObtained AS FLOAT) /
                    NULLIF(a.MaxMarks, 0) * 100, 0)
                AS INT), 0)                                       AS Percentage
        FROM   AssignmentSubmissions asub
        JOIN   Assignments           a    ON a.AssignmentId  = asub.AssignmentId
        JOIN   Subjects              sub  ON sub.SubjectId   = a.SubjectId
        JOIN   SubjectFaculty        SF   ON SF.SubjectId    = a.SubjectId
        JOIN   UserProfile           up   ON up.UserId       = asub.StudentId
        WHERE  SF.TeacherId    = @TeacherId
          AND  SF.InstituteId  = @InstituteId
          AND  SF.SessionId    = @SessionId
          AND  ISNULL(SF.IsActive, 1) = 1
          AND  asub.MarksObtained IS NOT NULL
          AND  a.MaxMarks > 0
          AND  (CAST(asub.MarksObtained AS FLOAT) / NULLIF(a.MaxMarks, 0) * 100) < 50
        ORDER BY
            CAST(asub.MarksObtained AS FLOAT) / NULLIF(a.MaxMarks, 0) ASC");

            cmd.Parameters.AddWithValue("@TeacherId", teacherId);
            cmd.Parameters.AddWithValue("@InstituteId", instituteId);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);
            return dl.GetDataTable(cmd);
        }


        // ════════════════════════════════════════════════════════════
        // AVG MARKS PER SUBJECT
        // ════════════════════════════════════════════════════════════
        public DataTable GetAvgMarksPerSubject(int teacherId, int instituteId, int sessionId)
        {
            SqlCommand cmd = new SqlCommand(@"
        SELECT
            sub.SubjectName,
            ISNULL(a.MaxMarks, 0)                                AS MaxMarks,
            CAST(ROUND(AVG(CAST(asub.MarksObtained AS FLOAT)), 1)
                 AS DECIMAL(5,1))                                AS AvgMarks
        FROM   AssignmentSubmissions asub
        JOIN   Assignments           a    ON a.AssignmentId  = asub.AssignmentId
        JOIN   Subjects              sub  ON sub.SubjectId   = a.SubjectId
        JOIN   SubjectFaculty        SF   ON SF.SubjectId    = a.SubjectId
        WHERE  SF.TeacherId    = @TeacherId
          AND  SF.InstituteId  = @InstituteId
          AND  SF.SessionId    = @SessionId
          AND  ISNULL(SF.IsActive, 1) = 1
          AND  asub.MarksObtained IS NOT NULL
        GROUP BY sub.SubjectName, a.MaxMarks
        ORDER BY AvgMarks DESC");

            cmd.Parameters.AddWithValue("@TeacherId", teacherId);
            cmd.Parameters.AddWithValue("@InstituteId", instituteId);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);

            DataTable dt = dl.GetDataTable(cmd);

            // Assign a color to each row for the pie legend
            string[] colors = {
        "#1565c0","#0288d1","#5e35b1","#2e7d32",
        "#ef6c00","#c62828","#00838f","#4527a0"
    };
            dt.Columns.Add("Color", typeof(string));
            int i = 0;
            foreach (DataRow row in dt.Rows)
            {
                row["Color"] = colors[i % colors.Length];
                i++;
            }

            return dt;
        }

        // ════════════════════════════════════════════════════════════
        // AVG MARKS CHART JSON (for pie chart)
        // ════════════════════════════════════════════════════════════
        public string GetAvgMarksChartJson(DataTable dt)
        {
            var list = new List<object>();
            foreach (DataRow row in dt.Rows)
                list.Add(new
                {
                    SubjectName = row["SubjectName"].ToString(),
                    AvgMarks = Convert.ToDouble(row["AvgMarks"]),
                    MaxMarks = Convert.ToInt32(row["MaxMarks"]),
                    Color = row["Color"].ToString()
                });

            return new JavaScriptSerializer().Serialize(list);
        }
        public DataTable GetStudentMarksDetail(int studentId, int teacherId, int instituteId, int sessionId)
        {
            SqlCommand cmd = new SqlCommand(@"
        SELECT
            asub.SubmissionId,
            a.Title                                               AS AssignmentTitle,
            sub.SubjectName,
            asub.MarksObtained,
            a.MaxMarks,
            ISNULL(
                CAST(ROUND(
                    CAST(asub.MarksObtained AS FLOAT) /
                    NULLIF(a.MaxMarks, 0) * 100, 0)
                AS INT), 0)                                       AS Percentage,
            CONVERT(VARCHAR(11), asub.SubmittedOn, 106)          AS SubmittedOn
        FROM   AssignmentSubmissions asub
        JOIN   Assignments           a    ON a.AssignmentId  = asub.AssignmentId
        JOIN   Subjects              sub  ON sub.SubjectId   = a.SubjectId
        JOIN   SubjectFaculty        SF   ON SF.SubjectId    = a.SubjectId
        WHERE  asub.StudentId  = @StudentId
          AND  SF.TeacherId    = @TeacherId
          AND  SF.InstituteId  = @InstituteId
          AND  SF.SessionId    = @SessionId
          AND  ISNULL(SF.IsActive, 1) = 1
          AND  asub.MarksObtained IS NOT NULL
        ORDER BY asub.SubmittedOn ASC");

            cmd.Parameters.AddWithValue("@StudentId", studentId);
            cmd.Parameters.AddWithValue("@TeacherId", teacherId);
            cmd.Parameters.AddWithValue("@InstituteId", instituteId);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);
            return dl.GetDataTable(cmd);
        }
    }
}