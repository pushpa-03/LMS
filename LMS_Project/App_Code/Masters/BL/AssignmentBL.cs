using LearningManagementSystem.GC;
using LMS_Project.Student;
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

        // ================= INSERT ASSIGNMENT =================
        public void AddAssignment(AssignmentGC obj)
        {
            SqlCommand cmd = new SqlCommand(@"
                INSERT INTO Assignments
                (SocietyId, InstituteId, SubjectId, Title, Description,
                 FilePath, DueDate, MaxMarks, CreatedBy, IsActive)
                VALUES
                (@S, @I, @Sub, @T, @D, @F, @Due, @M, @C, 1)
            ");

            cmd.Parameters.AddWithValue("@S", obj.SocietyId);
            cmd.Parameters.AddWithValue("@I", obj.InstituteId);
            cmd.Parameters.AddWithValue("@Sub", obj.SubjectId);
            cmd.Parameters.AddWithValue("@T", obj.Title);
            cmd.Parameters.AddWithValue("@D", (object)obj.Description ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@F", (object)obj.FilePath ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@Due", (object)obj.DueDate ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@M", (object)obj.MaxMarks ?? DBNull.Value);
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
                    a.Title,
                    a.Description,
                    a.FilePath,
                    a.DueDate,
                    a.MaxMarks,
                    a.CreatedOn
                FROM Assignments a
                INNER JOIN Subjects s 
                    ON a.SubjectId = s.SubjectId
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
                    s.SubmissionId,          -- 🔥 VERY IMPORTANT
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
    }
}