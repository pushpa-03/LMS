using System;
using System.Data;
using System.Data.SqlClient;

public class StudentDashboardBL
{
    DataLayer dl = new DataLayer();

    // ============================================================
    // ✅ 1. Summary Counts (4 stat cards)
    // ============================================================
    public DataTable GetDashboardCounts(int userId, int instituteId, int sessionId)
    {
        SqlCommand cmd = new SqlCommand(@"
        SELECT

            -- Total enrolled subjects
            (SELECT COUNT(*)
             FROM AssignStudentSubject
             WHERE UserId      = @UserId
               AND InstituteId = @InstId
               AND SessionId   = @SessId
            ) AS TotalSubjects,

            -- Pending assignments (due date not passed, not yet submitted)
            (SELECT COUNT(*)
             FROM Assignments A
             WHERE A.InstituteId = @InstId
               AND A.IsActive    = 1
               AND A.DueDate     >= GETDATE()
               AND A.SubjectId IN (
                    SELECT SubjectId FROM AssignStudentSubject
                    WHERE UserId = @UserId AND SessionId = @SessId
               )
               AND A.AssignmentId NOT IN (
                    SELECT AssignmentId FROM AssignmentSubmissions
                    WHERE StudentId = @UserId
               )
            ) AS PendingAssignments,

            -- Upcoming quizzes (enabled, not yet attempted)
            (SELECT COUNT(*)
             FROM Quizzes Q
             WHERE Q.InstituteId = @InstId
               AND Q.IsEnabled   = 1
               AND Q.DueDate     >= GETDATE()
               AND Q.SubjectId IN (
                    SELECT SubjectId FROM AssignStudentSubject
                    WHERE UserId = @UserId AND SessionId = @SessId
               )
               AND Q.QuizId NOT IN (
                    SELECT QuizId FROM QuizResults
                    WHERE StudentId = @UserId
               )
            ) AS UpcomingQuizzes,

            -- Unread notifications
            (SELECT COUNT(*)
             FROM Notifications
             WHERE UserId      = @UserId
               AND InstituteId = @InstId
               AND IsRead      = 0
            ) AS UnreadNotifications");

        cmd.Parameters.AddWithValue("@UserId", userId);
        cmd.Parameters.AddWithValue("@InstId", instituteId);
        cmd.Parameters.AddWithValue("@SessId", sessionId);

        return dl.GetDataTable(cmd);
    }

    // ============================================================
    // ✅ 2. Enrolled Subjects (recent 6 — subject cards)
    // ============================================================
    public DataTable GetEnrolledSubjects(int userId, int instituteId, int sessionId)
    {
        SqlCommand cmd = new SqlCommand(@"
        SELECT TOP 6
            S.SubjectId,
            S.SubjectName,
            S.SubjectCode,
            S.Duration,
            ST.StreamName,
            C.CourseName,
            -- Teacher name (from SubjectFaculty)
            ISNULL(UP.FullName, 'Not Assigned') AS TeacherName
        FROM AssignStudentSubject ASS
        JOIN Subjects  S  ON ASS.SubjectId  = S.SubjectId
        JOIN LevelSemesterSubjects  LS  ON ASS.SubjectId  = LS.SubjectId
        LEFT JOIN Streams   ST ON LS.StreamId    = ST.StreamId
        LEFT JOIN Courses   C  ON LS.CourseId    = C.CourseId
        LEFT JOIN SubjectFaculty SF
               ON SF.SubjectId   = S.SubjectId
              AND SF.InstituteId = @InstId
              AND SF.SessionId   = @SessId
              AND SF.IsActive    = 1
        LEFT JOIN Users     U  ON SF.TeacherId  = U.UserId
        LEFT JOIN UserProfile UP ON U.UserId    = UP.UserId
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
    // ✅ 3. Upcoming Assignments (due within 14 days, not submitted)
    // ============================================================
    public DataTable GetUpcomingAssignments(int userId, int instituteId, int sessionId)
    {
        SqlCommand cmd = new SqlCommand(@"
        SELECT TOP 5
            A.AssignmentId,
            A.Title,
            A.DueDate,
            A.MaxMarks,
            S.SubjectName,
            -- Submission status
            CASE
                WHEN SUB.SubmissionId IS NOT NULL THEN 'Submitted'
                WHEN A.DueDate < GETDATE()        THEN 'Overdue'
                ELSE 'Pending'
            END AS Status
        FROM Assignments A
        JOIN Subjects S ON A.SubjectId = S.SubjectId
        LEFT JOIN AssignmentSubmissions SUB
               ON SUB.AssignmentId = A.AssignmentId
              AND SUB.StudentId    = @UserId
        WHERE A.InstituteId = @InstId
          AND A.IsActive    = 1
          AND A.SubjectId IN (
                SELECT SubjectId FROM AssignStudentSubject
                WHERE UserId    = @UserId
                  AND SessionId = @SessId
          )
        ORDER BY A.DueDate ASC");

        cmd.Parameters.AddWithValue("@UserId", userId);
        cmd.Parameters.AddWithValue("@InstId", instituteId);
        cmd.Parameters.AddWithValue("@SessId", sessionId);

        return dl.GetDataTable(cmd);
    }

    // ============================================================
    // ✅ 4. Recent Notifications (last 5 unread)
    // ============================================================
    public DataTable GetRecentNotifications(int userId, int instituteId)
    {
        SqlCommand cmd = new SqlCommand(@"
        SELECT TOP 5
            NotificationId,
            Message,
            NotificationType,
            IsRead,
            CreatedOn
        FROM Notifications
        WHERE UserId      = @UserId
          AND InstituteId = @InstId
        ORDER BY CreatedOn DESC");

        cmd.Parameters.AddWithValue("@UserId", userId);
        cmd.Parameters.AddWithValue("@InstId", instituteId);

        return dl.GetDataTable(cmd);
    }

    // ============================================================
    // ✅ 5. Current Session Info
    // ============================================================
    public DataTable GetCurrentSession(int instituteId)
    {
        SqlCommand cmd = new SqlCommand(@"
        SELECT SessionId, SessionName, StartDate, EndDate
        FROM AcademicSessions
        WHERE InstituteId = @InstId
          AND IsCurrent   = 1");

        cmd.Parameters.AddWithValue("@InstId", instituteId);

        return dl.GetDataTable(cmd);
    }

    // ============================================================
    // ✅ 6. Student Academic Info (for welcome banner)
    // ============================================================
    public DataTable GetStudentInfo(int userId)
    {
        SqlCommand cmd = new SqlCommand(@"
        SELECT
            UP.FullName,
            UP.ProfileImage,
            SAD.RollNumber,
            ST.StreamName,
            C.CourseName,
            SL.LevelName,
            SM.SemesterName,
            SC.SectionName
        FROM Users U
        JOIN UserProfile          UP  ON U.UserId      = UP.UserId
        JOIN StudentAcademicDetails SAD ON U.UserId    = SAD.UserId
        LEFT JOIN Streams          ST  ON SAD.StreamId = ST.StreamId
        LEFT JOIN Courses          C   ON SAD.CourseId = C.CourseId
        LEFT JOIN StudyLevels      SL  ON SAD.LevelId  = SL.LevelId
        LEFT JOIN Semesters        SM  ON SAD.SemesterId = SM.SemesterId
        LEFT JOIN Sections         SC  ON SAD.SectionId  = SC.SectionId
        WHERE U.UserId = @UserId");

        cmd.Parameters.AddWithValue("@UserId", userId);

        return dl.GetDataTable(cmd);
    }
}