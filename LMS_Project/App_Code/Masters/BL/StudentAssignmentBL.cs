using System;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Web;

public class StudentAssignmentBL
{
    DataLayer dl = new DataLayer();

    // ============================================================
    // ✅ 1. Get all assignments for student (with submission status)
    // ============================================================
    public DataTable GetAssignments(int userId, int instituteId, int sessionId,
                                    string filterStatus = "All",
                                    int filterSubjectId = 0)
    {
        SqlCommand cmd = new SqlCommand(@"
        SELECT
            A.AssignmentId,
            A.Title,
            A.Description,
            A.DueDate,
            A.MaxMarks,
            A.IsActive,
            S.SubjectId,
            S.SubjectName,
            S.SubjectCode,

            -- Submission info
            SUB.SubmissionId,
            SUB.FilePath,
            SUB.Remarks,
            SUB.MarksObtained,
            SUB.SubmittedOn,

            -- Status
            CASE
                WHEN SUB.SubmissionId IS NOT NULL     THEN 'Submitted'
                WHEN A.DueDate < GETDATE()            THEN 'Overdue'
                ELSE 'Pending'
            END AS Status,

            -- Days remaining (negative = overdue)
            DATEDIFF(DAY, GETDATE(), A.DueDate) AS DaysRemaining

        FROM Assignments A
        JOIN Subjects S ON A.SubjectId = S.SubjectId
        LEFT JOIN AssignmentSubmissions SUB
               ON SUB.AssignmentId = A.AssignmentId
              AND SUB.StudentId    = @UserId
        WHERE A.InstituteId = @InstId
          AND A.IsActive    = 1
          AND A.SubjectId IN (
                SELECT SubjectId FROM AssignStudentSubject
                WHERE UserId      = @UserId
                  AND InstituteId = @InstId
                  AND SessionId   = @SessId
          )
          AND (@SubjectId = 0 OR A.SubjectId = @SubjectId)
          AND (
                @Status = 'All'
                OR (
                    @Status = 'Pending'
                    AND SUB.SubmissionId IS NULL
                    AND A.DueDate >= GETDATE()
                )
                OR (
                    @Status = 'Submitted'
                    AND SUB.SubmissionId IS NOT NULL
                )
                OR (
                    @Status = 'Overdue'
                    AND SUB.SubmissionId IS NULL
                    AND A.DueDate < GETDATE()
                )
          )
        ORDER BY
            CASE WHEN SUB.SubmissionId IS NULL AND A.DueDate >= GETDATE() THEN 0
                 WHEN SUB.SubmissionId IS NULL AND A.DueDate < GETDATE()  THEN 1
                 ELSE 2
            END,
            A.DueDate ASC");

        cmd.Parameters.AddWithValue("@UserId", userId);
        cmd.Parameters.AddWithValue("@InstId", instituteId);
        cmd.Parameters.AddWithValue("@SessId", sessionId);
        cmd.Parameters.AddWithValue("@Status", filterStatus);
        cmd.Parameters.AddWithValue("@SubjectId", filterSubjectId);

        return dl.GetDataTable(cmd);
    }

    // ============================================================
    // ✅ 2. Submit assignment (file upload)
    // ============================================================
    public bool SubmitAssignment(int assignmentId, int studentId,
                                  int societyId, int instituteId,
                                  HttpPostedFile file,
                                  string remarks, HttpServerUtility server)
    {
        // Check not already submitted
        SqlCommand checkCmd = new SqlCommand(@"
            SELECT COUNT(*) FROM AssignmentSubmissions
            WHERE AssignmentId = @AsgId AND StudentId = @StudId");

        checkCmd.Parameters.AddWithValue("@AsgId", assignmentId);
        checkCmd.Parameters.AddWithValue("@StudId", studentId);

        int existing = Convert.ToInt32(dl.GetDataTable(checkCmd).Rows[0][0]);
        if (existing > 0) return false; // Already submitted

        // Save file
        string ext = Path.GetExtension(file.FileName);
        string fileName = $"ASG_{assignmentId}_{studentId}_{DateTime.Now:yyyyMMddHHmmss}{ext}";
        string folderPath = server.MapPath("~/Uploads/Assignments/");

        if (!Directory.Exists(folderPath))
            Directory.CreateDirectory(folderPath);

        string fullPath = Path.Combine(folderPath, fileName);
        file.SaveAs(fullPath);

        string dbPath = "../Uploads/Assignments/" + fileName;

        // Insert submission
        SqlCommand cmd = new SqlCommand(@"
            INSERT INTO AssignmentSubmissions
            (AssignmentId, StudentId, SocietyId, InstituteId,
             FilePath, Remarks, SubmittedOn)
            VALUES
            (@AsgId, @StudId, @SocId, @InstId,
             @Path, @Remarks, GETDATE())");

        cmd.Parameters.AddWithValue("@AsgId", assignmentId);
        cmd.Parameters.AddWithValue("@StudId", studentId);
        cmd.Parameters.AddWithValue("@SocId", societyId);
        cmd.Parameters.AddWithValue("@InstId", instituteId);
        cmd.Parameters.AddWithValue("@Path", dbPath);
        cmd.Parameters.AddWithValue("@Remarks", remarks ?? "");

        dl.ExecuteCMD(cmd);
        return true;
    }

    // ============================================================
    // ✅ 3. Get enrolled subjects for filter dropdown
    // ============================================================
    public DataTable GetEnrolledSubjectsForFilter(int userId,
                                                   int instituteId,
                                                   int sessionId)
    {
        SqlCommand cmd = new SqlCommand(@"
        SELECT S.SubjectId, S.SubjectName, S.SubjectCode
        FROM AssignStudentSubject ASS
        JOIN Subjects S ON ASS.SubjectId = S.SubjectId
        WHERE ASS.UserId      = @UserId
          AND ASS.InstituteId = @InstId
          AND ASS.SessionId   = @SessId
          AND S.IsActive      = 1
        ORDER BY S.SubjectName");

        cmd.Parameters.AddWithValue("@UserId", userId);
        cmd.Parameters.AddWithValue("@InstId", instituteId);
        cmd.Parameters.AddWithValue("@SessId", sessionId);

        return dl.GetDataTable(cmd);
    }

    // ============================================================
    // ✅ 4. Get single assignment detail (for submit modal)
    // ============================================================
    public DataTable GetAssignmentById(int assignmentId)
    {
        SqlCommand cmd = new SqlCommand(@"
        SELECT A.*, S.SubjectName, S.SubjectCode
        FROM Assignments A
        JOIN Subjects S ON A.SubjectId = S.SubjectId
        WHERE A.AssignmentId = @Id");

        cmd.Parameters.AddWithValue("@Id", assignmentId);

        return dl.GetDataTable(cmd);
    }

    // ============================================================
    // ✅ 5. Summary counts
    // ============================================================
    public DataTable GetAssignmentCounts(int userId, int instituteId, int sessionId)
    {
        SqlCommand cmd = new SqlCommand(@"
        SELECT
            COUNT(*) AS Total,

            SUM(CASE WHEN SUB.SubmissionId IS NOT NULL THEN 1 ELSE 0 END)
                AS Submitted,

            SUM(CASE WHEN SUB.SubmissionId IS NULL
                      AND A.DueDate >= GETDATE() THEN 1 ELSE 0 END)
                AS Pending,

            SUM(CASE WHEN SUB.SubmissionId IS NULL
                      AND A.DueDate < GETDATE() THEN 1 ELSE 0 END)
                AS Overdue

        FROM Assignments A
        LEFT JOIN AssignmentSubmissions SUB
               ON SUB.AssignmentId = A.AssignmentId
              AND SUB.StudentId    = @UserId
        WHERE A.InstituteId = @InstId
          AND A.IsActive    = 1
          AND A.SubjectId IN (
                SELECT SubjectId FROM AssignStudentSubject
                WHERE UserId      = @UserId
                  AND InstituteId = @InstId
                  AND SessionId   = @SessId
          )");

        cmd.Parameters.AddWithValue("@UserId", userId);
        cmd.Parameters.AddWithValue("@InstId", instituteId);
        cmd.Parameters.AddWithValue("@SessId", sessionId);

        return dl.GetDataTable(cmd);
    }
}