using LearningManagementSystem.GC;
using System;
using System.Data;
using System.Data.SqlClient;

namespace LearningManagementSystem.BL
{
    public class AssignmentBL
    {
        DataLayer dl = new DataLayer();

        // ================= GET SUBJECTS FOR TEACHER =================
        public DataTable GetTeacherSubjects(int userId, int instituteId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT DISTINCT 
                    s.SubjectId,
                    s.SubjectName
                FROM SubjectFaculty sf
                INNER JOIN Subjects s
                    ON sf.SubjectId = s.SubjectId
                INNER JOIN AcademicSessions sess
                    ON sf.SessionId = sess.SessionId
                WHERE sf.TeacherId = @UserId
                AND sf.InstituteId = @Inst
                AND s.IsActive = 1
                AND sess.IsCurrent = 1
            ");

            cmd.Parameters.AddWithValue("@UserId", userId);
            cmd.Parameters.AddWithValue("@Inst", instituteId);

            return dl.GetDataTable(cmd);
        }

        // ================= GET CHAPTERS =================
        public DataTable GetChaptersBySubject(int subjectId, int instituteId, int societyId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT ChapterId, ChapterName
                FROM Chapters
                WHERE SubjectId = @Sub
                AND InstituteId = @Inst
                AND SocietyId = @Soc
                ORDER BY OrderNo
            ");

            cmd.Parameters.AddWithValue("@Sub", subjectId);
            cmd.Parameters.AddWithValue("@Inst", instituteId);
            cmd.Parameters.AddWithValue("@Soc", societyId);

            return dl.GetDataTable(cmd);
        }

        // ================= INSERT ASSIGNMENT =================
        public void AddAssignment(AssignmentGC obj)
        {
            SqlCommand cmd = new SqlCommand(@"
                INSERT INTO Assignments
                (SocietyId, InstituteId, SubjectId, ChapterId, Title, Description,
                 FilePath, DueDate, MaxMarks, CreatedBy, IsActive)
                VALUES
                (@S, @I, @Sub, @Chap, @T, @D, @F, @Due, @M, @C, 1)
            ");

            cmd.Parameters.AddWithValue("@S", obj.SocietyId);
            cmd.Parameters.AddWithValue("@I", obj.InstituteId);
            cmd.Parameters.AddWithValue("@Sub", obj.SubjectId);

            // ✅ FIX: Proper NULL handling
            cmd.Parameters.AddWithValue("@Chap",
                obj.ChapterId.HasValue ? (object)obj.ChapterId.Value : DBNull.Value);

            cmd.Parameters.AddWithValue("@T", obj.Title);
            cmd.Parameters.AddWithValue("@D",
                string.IsNullOrEmpty(obj.Description) ? (object)DBNull.Value : obj.Description);

            // ❗ File should NEVER be null now (since mandatory)
            cmd.Parameters.AddWithValue("@F", obj.FilePath);

            cmd.Parameters.AddWithValue("@Due",
                obj.DueDate.HasValue ? (object)obj.DueDate.Value : DBNull.Value);

            cmd.Parameters.AddWithValue("@M",
                obj.MaxMarks.HasValue ? (object)obj.MaxMarks.Value : DBNull.Value);

            cmd.Parameters.AddWithValue("@C", obj.CreatedBy);

            dl.ExecuteCMD(cmd);
        }

        // ================= GET ASSIGNMENTS =================
        public DataTable GetTeacherAssignments(int userId, int instituteId, int societyId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT 
                    a.AssignmentId,
                    s.SubjectName,
                    c.ChapterName,   -- ✅ NEW
                    a.Title,
                    a.Description,
                    a.FilePath,
                    a.DueDate,
                    a.MaxMarks,
                    a.CreatedOn
                FROM Assignments a
                INNER JOIN Subjects s 
                    ON a.SubjectId = s.SubjectId
                LEFT JOIN Chapters c
                    ON a.ChapterId = c.ChapterId   -- ✅ IMPORTANT (LEFT JOIN)
                WHERE a.CreatedBy = @UserId
                AND a.InstituteId = @Inst
                AND a.SocietyId = @Soc
                AND a.IsActive = 1
                ORDER BY a.AssignmentId DESC
            ");

            cmd.Parameters.AddWithValue("@UserId", userId);
            cmd.Parameters.AddWithValue("@Inst", instituteId);
            cmd.Parameters.AddWithValue("@Soc", societyId);

            return dl.GetDataTable(cmd);
        }

        // ================= GET SUBMISSIONS =================
        public DataTable GetSubmissionsByAssignment(int assignmentId, int societyId, int instituteId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT 
                    s.SubmissionId,
                    up.FullName,
                    s.SubmittedOn,
                    s.MarksObtained,
                    s.Feedback,
                    s.FilePath
                FROM AssignmentSubmissions s
                INNER JOIN UserProfile up 
                    ON s.StudentId = up.UserId
                WHERE s.AssignmentId = @AssignmentId
                AND s.SocietyId = @SocietyId
                AND s.InstituteId = @InstituteId
                ORDER BY s.SubmittedOn DESC
            ");

            cmd.Parameters.AddWithValue("@AssignmentId", assignmentId);
            cmd.Parameters.AddWithValue("@SocietyId", societyId);
            cmd.Parameters.AddWithValue("@InstituteId", instituteId);

            return dl.GetDataTable(cmd);
        }

        // ================= UPDATE MARKS =================
        public void UpdateSubmissionMarks(int submissionId, int marks, string feedback)
        {
            SqlCommand cmd = new SqlCommand(@"
                UPDATE AssignmentSubmissions
                SET MarksObtained = @Marks,
                    Feedback = @Feedback
                WHERE SubmissionId = @SubmissionId
            ");

            cmd.Parameters.AddWithValue("@Marks", marks);
            cmd.Parameters.AddWithValue("@Feedback",
                string.IsNullOrEmpty(feedback) ? (object)DBNull.Value : feedback);
            cmd.Parameters.AddWithValue("@SubmissionId", submissionId);

            dl.ExecuteCMD(cmd);
        }
        public void DeleteAssignment(int assignmentId)
        {
            SqlCommand cmd = new SqlCommand(@"
        UPDATE Assignments
        SET IsActive = 0
        WHERE AssignmentId = @Id
    ");

            cmd.Parameters.AddWithValue("@Id", assignmentId);

            dl.ExecuteCMD(cmd);
        }
    }
}