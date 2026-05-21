using System;
using System.Data;
using System.Data.SqlClient;

namespace LearningManagementSystem.BL
{
    /// <summary>
    /// Business Logic for the Student Details page.
    /// All queries use DISTINCT or aggregation to prevent FK-join duplication.
    /// Session-scoping is done via StudentAcademicDetails.SessionId (not Users.SessionId).
    /// </summary>
    public class StudentDetailsBL
    {
        private readonly DataLayer _dl = new DataLayer();

        // ══════════════════════════════════════════════════════════════════════
        //  PROFILE — Full profile + current session academics
        // ══════════════════════════════════════════════════════════════════════
        public DataTable GetStudentProfile(int userId, int sessionId)
        {
            var cmd = new SqlCommand(@"
                SELECT
                    U.UserId,
                    U.Username,
                    U.Email,
                    U.IsActive,
                    U.IsFirstLogin,
                    U.CreatedOn                                         AS AccountCreated,

                    ISNULL(UP.FullName,     U.Username)                 AS FullName,
                    ISNULL(UP.FatherName,   '')                         AS FatherName,
                    ISNULL(UP.MotherName,   '')                         AS MotherName,
                    ISNULL(UP.Gender,       '')                         AS Gender,
                    UP.DOB,
                    ISNULL(UP.ContactNo,    '')                         AS ContactNo,
                    ISNULL(UP.EmergencyContactName, '')                 AS EmergencyContactName,
                    ISNULL(UP.EmergencyContactNo,   '')                 AS EmergencyContactNo,
                    ISNULL(UP.Address,      '')                         AS Address,
                    ISNULL(UP.City,         '')                         AS City,
                    ISNULL(UP.Country,      '')                         AS Country,
                    ISNULL(CAST(UP.Pincode AS VARCHAR), '')             AS Pincode,
                    UP.JoinedDate,
                    ISNULL(UP.Skills,       '')                         AS Skills,
                    ISNULL(UP.Hobbies,      '')                         AS Hobbies,
                    ISNULL(UP.Description,  '')                         AS Description,
                    ISNULL(UP.ProfileImage, '')                         AS ProfileImage,

                    ISNULL(SAD.RollNumber,  '')                         AS RollNumber,
                    ISNULL(SAD.IsReEnrolled,0)                          AS IsReEnrolled,
                    SAD.JoinedOn                                        AS EnrolledOn,

                    ISNULL(St.StreamName,   '')                         AS StreamName,
                    ISNULL(C.CourseName,    '')                         AS CourseName,
                    ISNULL(SL.LevelName,    '')                         AS LevelName,
                    ISNULL(Sem.SemesterName,'')                         AS SemesterName,
                    ISNULL(Sec.SectionName, '')                         AS SectionName,
                    ISNULL(ASess.SessionName,'')                        AS SessionName,

                    SAD.StreamId,
                    SAD.CourseId,
                    SAD.LevelId,
                    SAD.SemesterId,
                    SAD.SectionId

                FROM Users U
                LEFT JOIN UserProfile UP
                    ON UP.UserId = U.UserId
                LEFT JOIN StudentAcademicDetails SAD
                    ON SAD.UserId = U.UserId AND SAD.SessionId = @SessId
                LEFT JOIN Streams      St    ON St.StreamId     = SAD.StreamId
                LEFT JOIN Courses      C     ON C.CourseId      = SAD.CourseId
                LEFT JOIN StudyLevels  SL    ON SL.LevelId      = SAD.LevelId
                LEFT JOIN Semesters    Sem   ON Sem.SemesterId   = SAD.SemesterId
                LEFT JOIN Sections     Sec   ON Sec.SectionId    = SAD.SectionId
                LEFT JOIN AcademicSessions ASess ON ASess.SessionId = @SessId
                WHERE U.UserId = @UserId");

            cmd.Parameters.AddWithValue("@UserId", userId);
            cmd.Parameters.AddWithValue("@SessId", sessionId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        // ══════════════════════════════════════════════════════════════════════
        //  ALL SESSIONS the student has been enrolled in (for session switcher)
        // ══════════════════════════════════════════════════════════════════════
        public DataTable GetStudentSessions(int userId)
        {
            var cmd = new SqlCommand(@"
                SELECT DISTINCT
                    ASess.SessionId,
                    ASess.SessionName,
                    ASess.StartDate,
                    ASess.EndDate,
                    ASess.IsCurrent,
                    ISNULL(SAD.IsReEnrolled, 0) AS IsReEnrolled
                FROM StudentAcademicDetails SAD
                INNER JOIN AcademicSessions ASess ON ASess.SessionId = SAD.SessionId
                WHERE SAD.UserId = @UserId
                ORDER BY ASess.StartDate DESC");
            cmd.Parameters.AddWithValue("@UserId", userId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        // ══════════════════════════════════════════════════════════════════════
        //  ATTENDANCE — Summary stats for current session
        // ══════════════════════════════════════════════════════════════════════
        public DataTable GetAttendanceSummary(int userId, int sessionId)
        {
            var cmd = new SqlCommand(@"
                SELECT
                    COUNT(DISTINCT A.Date)                                                      AS TotalDays,
                    COUNT(DISTINCT CASE WHEN A.Status='Present' THEN A.Date END)                AS PresentDays,
                    COUNT(DISTINCT CASE WHEN A.Status='Absent'  THEN A.Date END)                AS AbsentDays,
                    COUNT(DISTINCT CASE WHEN A.Status='Leave'   THEN A.Date END)                AS LeaveDays,
                    ISNULL(CAST(
                        COUNT(DISTINCT CASE WHEN A.Status='Present' THEN A.Date END) * 100.0
                        / NULLIF(COUNT(DISTINCT A.Date), 0)
                    AS DECIMAL(5,2)), 0)                                                        AS AttendancePercent
                FROM Attendance A
                WHERE A.UserId    = @UserId
                  AND A.SessionId = @SessId");
            cmd.Parameters.AddWithValue("@UserId", userId);
            cmd.Parameters.AddWithValue("@SessId", sessionId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        // ══════════════════════════════════════════════════════════════════════
        //  ATTENDANCE — Per subject breakdown
        // ══════════════════════════════════════════════════════════════════════
        public DataTable GetAttendanceBySubject(int userId, int sessionId)
        {
            var cmd = new SqlCommand(@"
                SELECT
                    S.SubjectId,
                    S.SubjectName,
                    S.SubjectCode,
                    COUNT(DISTINCT A.Date)                                                      AS TotalClasses,
                    COUNT(DISTINCT CASE WHEN A.Status='Present' THEN A.Date END)                AS Present,
                    COUNT(DISTINCT CASE WHEN A.Status='Absent'  THEN A.Date END)                AS Absent,
                    COUNT(DISTINCT CASE WHEN A.Status='Leave'   THEN A.Date END)                AS Leave,
                    ISNULL(CAST(
                        COUNT(DISTINCT CASE WHEN A.Status='Present' THEN A.Date END) * 100.0
                        / NULLIF(COUNT(DISTINCT A.Date),0)
                    AS DECIMAL(5,2)), 0)                                                        AS Percentage
                FROM Attendance A
                INNER JOIN Subjects S ON S.SubjectId = A.SubjectId
                WHERE A.UserId    = @UserId
                  AND A.SessionId = @SessId
                GROUP BY S.SubjectId, S.SubjectName, S.SubjectCode
                ORDER BY Percentage DESC");
            cmd.Parameters.AddWithValue("@UserId", userId);
            cmd.Parameters.AddWithValue("@SessId", sessionId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        // ══════════════════════════════════════════════════════════════════════
        //  ATTENDANCE — Daily calendar data (last 90 days or full session)
        // ══════════════════════════════════════════════════════════════════════
        //public DataTable GetAttendanceCalendar(int userId, int sessionId)
        //{
        //    var cmd = new SqlCommand(@"
        //        SELECT
        //            A.Date,
        //            -- Aggregate: if ANY subject = Present that day → Present; else check Leave; else Absent
        //            CASE
        //                WHEN MAX(CASE WHEN A.Status='Present' THEN 1 ELSE 0 END) = 1 THEN 'Present'
        //                WHEN MAX(CASE WHEN A.Status='Leave'   THEN 1 ELSE 0 END) = 1 THEN 'Leave'
        //                ELSE 'Absent'
        //            END                                                 AS DayStatus,
        //            COUNT(DISTINCT A.SubjectId)                         AS SubjectsThat Day,
        //            COUNT(DISTINCT CASE WHEN A.Status='Present' THEN A.SubjectId END) AS PresentSubjects
        //        FROM Attendance A
        //        WHERE A.UserId    = @UserId
        //          AND A.SessionId = @SessId
        //        GROUP BY A.Date
        //        ORDER BY A.Date");
        //    cmd.Parameters.AddWithValue("@UserId", userId);
        //    cmd.Parameters.AddWithValue("@SessId", sessionId);
        //    return _dl.GetDataTable(cmd) ?? new DataTable();
        //}


        public DataTable GetAttendanceCalendar(int userId, int sessionId)
        {
            var cmd = new SqlCommand(@"
        SELECT
            A.Date,
            -- Aggregate: if ANY subject = Present that day → Present; else check Leave; else Absent
            CASE
                WHEN MAX(CASE WHEN A.Status='Present' THEN 1 ELSE 0 END) = 1 THEN 'Present'
                WHEN MAX(CASE WHEN A.Status='Leave'   THEN 1 ELSE 0 END) = 1 THEN 'Leave'
                ELSE 'Absent'
            END AS DayStatus,

            COUNT(DISTINCT A.SubjectId) AS [SubjectsThatDay],

            COUNT(DISTINCT CASE 
                WHEN A.Status='Present' THEN A.SubjectId 
            END) AS PresentSubjects

        FROM Attendance A
        WHERE A.UserId    = @UserId
          AND A.SessionId = @SessId
        GROUP BY A.Date
        ORDER BY A.Date");

            cmd.Parameters.AddWithValue("@UserId", userId);
            cmd.Parameters.AddWithValue("@SessId", sessionId);

            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        // ══════════════════════════════════════════════════════════════════════
        //  ATTENDANCE — Monthly trend (for chart)
        // ══════════════════════════════════════════════════════════════════════
        public DataTable GetAttendanceMonthlyTrend(int userId, int sessionId)
        {
            var cmd = new SqlCommand(@"
                SELECT
                    YEAR(A.Date)                                        AS Yr,
                    MONTH(A.Date)                                       AS Mo,
                    DATENAME(MONTH, A.Date) + ' ' + CAST(YEAR(A.Date) AS VARCHAR) AS MonthLabel,
                    COUNT(DISTINCT A.Date)                              AS TotalDays,
                    COUNT(DISTINCT CASE WHEN A.Status='Present' THEN A.Date END) AS PresentDays,
                    ISNULL(CAST(
                        COUNT(DISTINCT CASE WHEN A.Status='Present' THEN A.Date END) * 100.0
                        / NULLIF(COUNT(DISTINCT A.Date),0)
                    AS DECIMAL(5,2)),0)                                 AS Percentage
                FROM Attendance A
                WHERE A.UserId    = @UserId
                  AND A.SessionId = @SessId
                GROUP BY YEAR(A.Date), MONTH(A.Date), DATENAME(MONTH, A.Date)
                ORDER BY Yr, Mo");
            cmd.Parameters.AddWithValue("@UserId", userId);
            cmd.Parameters.AddWithValue("@SessId", sessionId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        // ══════════════════════════════════════════════════════════════════════
        //  SUBJECTS — Enrolled subjects with progress metrics
        // ══════════════════════════════════════════════════════════════════════
        public DataTable GetEnrolledSubjects(int userId, int sessionId)
        {
            var cmd = new SqlCommand(@"
                SELECT DISTINCT
                    S.SubjectId,
                    S.SubjectName,
                    S.SubjectCode,
                    S.Duration,
                    St.StreamName,
                    C.CourseName,
                    SL.LevelName,
                    Sem.SemesterName,

                    -- Total videos in subject
                    (SELECT COUNT(DISTINCT V.VideoId)
                     FROM Videos V
                     WHERE V.SubjectId = S.SubjectId AND V.SessionId = @SessId AND V.IsActive=1)
                        AS TotalVideos,

                    -- Videos watched by this student
                    (SELECT COUNT(DISTINCT VWP.VideoId)
                     FROM VideoWatchProgress VWP
                     INNER JOIN Videos V2 ON V2.VideoId = VWP.VideoId
                     WHERE VWP.UserId = @UserId AND V2.SubjectId = S.SubjectId
                       AND VWP.WatchedPercent >= 80)
                        AS VideosCompleted,

                    -- Total chapters
                    (SELECT COUNT(DISTINCT CH.ChapterId)
                     FROM Chapters CH
                     WHERE CH.SubjectId = S.SubjectId AND CH.SessionId = @SessId AND CH.IsActive=1)
                        AS TotalChapters,

                    -- AI interactions
                    (SELECT COUNT(1)
                     FROM VideoAIHistory VAI
                     INNER JOIN Videos VA ON VA.VideoId = VAI.VideoId
                     WHERE VAI.UserId = @UserId AND VA.SubjectId = S.SubjectId)
                        AS AIInteractions,

                    -- Assignments
                    (SELECT COUNT(DISTINCT A.AssignmentId)
                     FROM Assignments A
                     WHERE A.SubjectId = S.SubjectId AND A.SessionId = @SessId AND A.IsActive=1)
                        AS TotalAssignments,

                    -- Assignments submitted
                    (SELECT COUNT(DISTINCT SUB.AssignmentId)
                     FROM AssignmentSubmissions SUB
                     INNER JOIN Assignments A2 ON A2.AssignmentId = SUB.AssignmentId
                     WHERE SUB.StudentId = @UserId AND A2.SubjectId = S.SubjectId)
                        AS AssignmentsSubmitted,

                    -- Quizzes
                    (SELECT COUNT(DISTINCT Q.QuizId)
                     FROM Quizzes Q
                     WHERE Q.SubjectId = S.SubjectId AND Q.SessionId = @SessId AND Q.IsActive=1)
                        AS TotalQuizzes,

                    -- Quizzes attempted
                    (SELECT COUNT(DISTINCT QR.QuizId)
                     FROM QuizResults QR
                     INNER JOIN Quizzes Q2 ON Q2.QuizId = QR.QuizId
                     WHERE QR.StudentId = @UserId AND Q2.SubjectId = S.SubjectId)
                        AS QuizzesAttempted,

                    -- Attendance %
                    ISNULL((SELECT CAST(
                        COUNT(DISTINCT CASE WHEN ATT.Status='Present' THEN ATT.Date END)*100.0
                        /NULLIF(COUNT(DISTINCT ATT.Date),0) AS DECIMAL(5,2))
                     FROM Attendance ATT
                     WHERE ATT.UserId=@UserId AND ATT.SubjectId=S.SubjectId AND ATT.SessionId=@SessId),0)
                        AS AttendancePercent,

                    -- Teacher name
                    ISNULL((SELECT TOP 1 ISNULL(TP.FullName, TU.Username)
                     FROM SubjectFaculty SF
                     INNER JOIN Users TU ON TU.UserId = SF.TeacherId
                     LEFT  JOIN UserProfile TP ON TP.UserId = TU.UserId
                     WHERE SF.SubjectId = S.SubjectId AND SF.SessionId = @SessId AND SF.IsActive=1),'—')
                        AS TeacherName

                FROM AssignStudentSubject ASS
                INNER JOIN Subjects S ON S.SubjectId = ASS.SubjectId
                LEFT  JOIN StudentAcademicDetails SAD ON SAD.UserId = @UserId AND SAD.SessionId = @SessId
                LEFT  JOIN Streams     St  ON St.StreamId    = SAD.StreamId
                LEFT  JOIN Courses     C   ON C.CourseId     = SAD.CourseId
                LEFT  JOIN StudyLevels SL  ON SL.LevelId     = SAD.LevelId
                LEFT  JOIN Semesters   Sem ON Sem.SemesterId  = SAD.SemesterId

                WHERE ASS.UserId    = @UserId
                  AND ASS.SessionId = @SessId
                ORDER BY S.SubjectName");
            cmd.Parameters.AddWithValue("@UserId", userId);
            cmd.Parameters.AddWithValue("@SessId", sessionId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        // ══════════════════════════════════════════════════════════════════════
        //  VIDEO PROGRESS — Per subject video watch details
        // ══════════════════════════════════════════════════════════════════════
        //public DataTable GetVideoProgress(int userId, int sessionId)
        //{
        //    var cmd = new SqlCommand(@"
        //        SELECT DISTINCT
        //            S.SubjectId,
        //            S.SubjectName,
        //            V.VideoId,
        //            V.Title                                             AS VideoTitle,
        //            V.Duration,
        //            CH.ChapterName,
        //            ISNULL(VWP.WatchedPercent, 0)                       AS WatchedPercent,
        //            ISNULL(VWP.WatchedSeconds, 0)                       AS WatchedSeconds,
        //            ISNULL(VWP.VideoDuration,  0)                       AS VideoDurationSec,
        //            ISNULL(VWP.IsCompleted,    0)                       AS IsCompleted,
        //            VWP.UpdatedOn                                       AS LastWatched,
        //            ISNULL(VR.Rating,          0)                       AS Rating,
        //            (SELECT COUNT(1) FROM VideoNotes VN WHERE VN.VideoId=V.VideoId AND VN.UserId=@UserId)
        //                AS NotesCount,
        //            (SELECT COUNT(1) FROM VideoDoubts VD WHERE VD.VideoId=V.VideoId AND VD.UserId=@UserId)
        //                AS DoubtsCount
        //        FROM Videos V
        //        INNER JOIN Subjects S   ON S.SubjectId  = V.SubjectId
        //        LEFT  JOIN Chapters CH  ON CH.ChapterId = V.ChapterId
        //        LEFT  JOIN VideoWatchProgress VWP
        //            ON VWP.VideoId = V.VideoId AND VWP.UserId = @UserId
        //        LEFT  JOIN VideoRatings VR
        //            ON VR.VideoId  = V.VideoId AND VR.UserId  = @UserId
        //        INNER JOIN AssignStudentSubject ASS
        //            ON ASS.SubjectId = S.SubjectId AND ASS.UserId = @UserId AND ASS.SessionId = @SessId
        //        WHERE V.SessionId  = @SessId
        //          AND V.IsActive   = 1
        //        ORDER BY S.SubjectName, CH.OrderNo, V.VideoId");
        //    cmd.Parameters.AddWithValue("@UserId", userId);
        //    cmd.Parameters.AddWithValue("@SessId", sessionId);
        //    return _dl.GetDataTable(cmd) ?? new DataTable();
        //}


        public DataTable GetVideoProgress(int userId, int sessionId)
        {
            var cmd = new SqlCommand(@"
        SELECT DISTINCT
            S.SubjectId,
            S.SubjectName,
            V.VideoId,
            V.Title                                             AS VideoTitle,
            V.Duration,
            CH.ChapterName,
            CH.OrderNo,

            ISNULL(VWP.WatchedPercent, 0)                       AS WatchedPercent,
            ISNULL(VWP.WatchedSeconds, 0)                       AS WatchedSeconds,
            ISNULL(VWP.VideoDuration,  0)                       AS VideoDurationSec,

            CASE 
                WHEN ISNULL(VWP.WatchedPercent,0) >= 80 THEN 1 
                ELSE 0 
            END                                                 AS IsCompleted,

            VWP.UpdatedOn                                       AS LastWatched,
            ISNULL(VR.Rating, 0)                                AS Rating,

            (SELECT COUNT(1)
             FROM VideoNotes VN
             WHERE VN.VideoId = V.VideoId
               AND VN.UserId  = @UserId)                        AS NotesCount,

            (SELECT COUNT(1)
             FROM VideoDoubts VD
             WHERE VD.VideoId = V.VideoId
               AND VD.UserId  = @UserId)                        AS DoubtsCount

        FROM Videos V

        INNER JOIN Subjects S
            ON S.SubjectId = V.SubjectId

        LEFT JOIN Chapters CH
            ON CH.ChapterId = V.ChapterId

        LEFT JOIN VideoWatchProgress VWP
            ON VWP.VideoId = V.VideoId
           AND VWP.UserId  = @UserId

        LEFT JOIN VideoRatings VR
            ON VR.VideoId = V.VideoId
           AND VR.UserId  = @UserId

        INNER JOIN AssignStudentSubject ASS
            ON ASS.SubjectId = S.SubjectId
           AND ASS.UserId    = @UserId
           AND ASS.SessionId = @SessId

        WHERE V.SessionId = @SessId
          AND V.IsActive  = 1

        ORDER BY S.SubjectName, CH.OrderNo, V.VideoId");

            cmd.Parameters.AddWithValue("@UserId", userId);
            cmd.Parameters.AddWithValue("@SessId", sessionId);

            return _dl.GetDataTable(cmd) ?? new DataTable();
        }


        // ══════════════════════════════════════════════════════════════════════
        //  ASSIGNMENTS — Detailed list with marks and class average
        // ══════════════════════════════════════════════════════════════════════
        public DataTable GetAssignments(int userId, int sessionId)
        {
            var cmd = new SqlCommand(@"
                SELECT DISTINCT
                    A.AssignmentId,
                    A.Title,
                    A.Description,
                    A.DueDate,
                    A.MaxMarks,
                    S.SubjectName,
                    S.SubjectCode,

                    -- Student submission
                    SUB.SubmissionId,
                    SUB.SubmittedOn,
                    SUB.MarksObtained,
                    ISNULL(SUB.Feedback,  '')                           AS Feedback,
                    ISNULL(SUB.Remarks,   '')                           AS Remarks,
                    SUB.GradedOn,

                    -- Status
                    CASE
                        WHEN SUB.SubmissionId IS NULL AND A.DueDate < GETDATE() THEN 'Missed'
                        WHEN SUB.SubmissionId IS NULL                            THEN 'Pending'
                        WHEN SUB.MarksObtained IS NULL                           THEN 'Submitted'
                        ELSE 'Graded'
                    END                                                 AS SubmissionStatus,

                    -- Class average for this assignment
                    ISNULL((SELECT CAST(AVG(CAST(S2.MarksObtained AS FLOAT)) AS DECIMAL(5,2))
                     FROM AssignmentSubmissions S2
                     WHERE S2.AssignmentId = A.AssignmentId
                       AND S2.MarksObtained IS NOT NULL), 0)            AS ClassAvgMarks,

                    -- Percentage scored
                    ISNULL(CAST(SUB.MarksObtained * 100.0
                        / NULLIF(A.MaxMarks,0) AS DECIMAL(5,2)), 0)     AS ScorePercent

                FROM Assignments A
                INNER JOIN Subjects S ON S.SubjectId = A.SubjectId
                INNER JOIN AssignStudentSubject ASS
                    ON ASS.SubjectId = A.SubjectId AND ASS.UserId = @UserId AND ASS.SessionId = @SessId
                LEFT JOIN AssignmentSubmissions SUB
                    ON SUB.AssignmentId = A.AssignmentId AND SUB.StudentId = @UserId
                WHERE A.SessionId = @SessId
                  AND A.IsActive  = 1
                ORDER BY A.DueDate DESC");
            cmd.Parameters.AddWithValue("@UserId", userId);
            cmd.Parameters.AddWithValue("@SessId", sessionId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        // ══════════════════════════════════════════════════════════════════════
        //  QUIZZES — With scores, class average, pass/fail
        // ══════════════════════════════════════════════════════════════════════
        public DataTable GetQuizResults(int userId, int sessionId)
        {
            var cmd = new SqlCommand(@"
                SELECT DISTINCT
                    Q.QuizId,
                    Q.Title                                             AS QuizTitle,
                    Q.TotalMarks,
                    Q.PassMarks,
                    Q.TimeLimit,
                    Q.DueDate,
                    S.SubjectName,
                    S.SubjectCode,

                    -- Student result
                    QR.ResultId,
                    QR.Score,
                    QR.Marks,
                    QR.TimeTaken,
                    QR.AttemptedOn,
                    QR.IsAutoSubmit,

                    CASE
                        WHEN QR.ResultId IS NULL THEN 'Not Attempted'
                        WHEN QR.Score >= Q.PassMarks THEN 'Passed'
                        ELSE 'Failed'
                    END                                                 AS QuizStatus,

                    ISNULL(CAST(QR.Score * 100.0 / NULLIF(Q.TotalMarks,0) AS DECIMAL(5,2)),0)
                        AS ScorePercent,

                    -- Class average
                    ISNULL((SELECT CAST(AVG(CAST(QR2.Score AS FLOAT)) AS DECIMAL(5,2))
                     FROM QuizResults QR2
                     WHERE QR2.QuizId = Q.QuizId), 0)                  AS ClassAvgScore,

                    -- Total questions
                    (SELECT COUNT(1) FROM QuizQuestions QQ WHERE QQ.QuizId = Q.QuizId)
                        AS TotalQuestions,

                    -- Correct answers
                    ISNULL((SELECT COUNT(1)
                     FROM QuizAttemptDetails QAD
                     WHERE QAD.ResultId = QR.ResultId AND QAD.IsCorrect = 1), 0)
                        AS CorrectAnswers

                FROM Quizzes Q
                INNER JOIN Subjects S ON S.SubjectId = Q.SubjectId
                INNER JOIN AssignStudentSubject ASS
                    ON ASS.SubjectId = Q.SubjectId AND ASS.UserId = @UserId AND ASS.SessionId = @SessId
                LEFT JOIN QuizResults QR
                    ON QR.QuizId = Q.QuizId AND QR.StudentId = @UserId
                WHERE Q.SessionId = @SessId
                  AND Q.IsActive  = 1
                ORDER BY Q.DueDate DESC");
            cmd.Parameters.AddWithValue("@UserId", userId);
            cmd.Parameters.AddWithValue("@SessId", sessionId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        // ══════════════════════════════════════════════════════════════════════
        //  AI USAGE — Summary and detail
        // ══════════════════════════════════════════════════════════════════════
        public DataTable GetAIUsageSummary(int userId, int sessionId)
        {
            var cmd = new SqlCommand(@"
                SELECT
                    VAI.Type,
                    COUNT(1)                                            AS UsageCount,
                    MAX(VAI.CreatedOn)                                  AS LastUsed
                FROM VideoAIHistory VAI
                INNER JOIN Videos V ON V.VideoId = VAI.VideoId
                WHERE VAI.UserId   = @UserId
                  AND V.SessionId  = @SessId
                GROUP BY VAI.Type
                ORDER BY UsageCount DESC");
            cmd.Parameters.AddWithValue("@UserId", userId);
            cmd.Parameters.AddWithValue("@SessId", sessionId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        public DataTable GetAIHistory(int userId, int sessionId)
        {
            var cmd = new SqlCommand(@"
                SELECT TOP 50
                    VAI.Id,
                    VAI.Type,
                    LEFT(VAI.Question, 120)                             AS Question,
                    LEFT(VAI.Response, 200)                             AS Response,
                    VAI.CreatedOn,
                    V.Title                                             AS VideoTitle,
                    S.SubjectName
                FROM VideoAIHistory VAI
                INNER JOIN Videos   V ON V.VideoId   = VAI.VideoId
                INNER JOIN Subjects S ON S.SubjectId = V.SubjectId
                WHERE VAI.UserId   = @UserId
                  AND V.SessionId  = @SessId
                ORDER BY VAI.CreatedOn DESC");
            cmd.Parameters.AddWithValue("@UserId", userId);
            cmd.Parameters.AddWithValue("@SessId", sessionId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        // ══════════════════════════════════════════════════════════════════════
        //  ACTIVITY LOG
        // ══════════════════════════════════════════════════════════════════════
        public DataTable GetActivityLog(int userId, int sessionId)
        {
            var cmd = new SqlCommand(@"
                SELECT TOP 50
                    UAL.LogId,
                    UAL.ActivityType,
                    UAL.ReferenceId,
                    UAL.ActionTime
                FROM UserActivityLog UAL
                WHERE UAL.UserId    = @UserId
                  AND UAL.SessionId = @SessId
                ORDER BY UAL.ActionTime DESC");
            cmd.Parameters.AddWithValue("@UserId", userId);
            cmd.Parameters.AddWithValue("@SessId", sessionId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        // ══════════════════════════════════════════════════════════════════════
        //  NOTIFICATIONS
        // ══════════════════════════════════════════════════════════════════════
        public DataTable GetNotifications(int userId, int sessionId)
        {
            var cmd = new SqlCommand(@"
                SELECT TOP 30
                    N.NotificationId,
                    N.Message,
                    N.NotificationType,
                    N.IsRead,
                    N.CreatedOn
                FROM Notifications N
                WHERE N.UserId    = @UserId
                  AND N.SessionId = @SessId
                ORDER BY N.CreatedOn DESC");
            cmd.Parameters.AddWithValue("@UserId", userId);
            cmd.Parameters.AddWithValue("@SessId", sessionId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        // ══════════════════════════════════════════════════════════════════════
        //  HELP REQUESTS + REPLIES
        // ══════════════════════════════════════════════════════════════════════
        public DataTable GetHelpRequests(int userId, int sessionId)
        {
            var cmd = new SqlCommand(@"
                SELECT
                    HR.HelpId,
                    HR.Question,
                    HR.AskedOn,
                    ISNULL(REP.Reply,    '')                            AS Reply,
                    ISNULL(REP.RepliedOn, NULL)                         AS RepliedOn,
                    ISNULL(ADUP.FullName, ADU.Username)                 AS RepliedBy,
                    CASE WHEN REP.ReplyId IS NOT NULL THEN 1 ELSE 0 END AS HasReply
                FROM HelpRequests HR
                LEFT JOIN HelpReplies REP ON REP.HelpId = HR.HelpId
                LEFT JOIN Users       ADU ON ADU.UserId = REP.AdminId
                LEFT JOIN UserProfile ADUP ON ADUP.UserId = REP.AdminId
                WHERE HR.UserId    = @UserId
                  AND HR.SessionId = @SessId
                ORDER BY HR.AskedOn DESC");
            cmd.Parameters.AddWithValue("@UserId", userId);
            cmd.Parameters.AddWithValue("@SessId", sessionId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        // ══════════════════════════════════════════════════════════════════════
        //  LINKED PARENTS
        // ══════════════════════════════════════════════════════════════════════
        public DataTable GetLinkedParents(int userId, int sessionId)
        {
            var cmd = new SqlCommand(@"
                SELECT DISTINCT
                    PSM.Id,
                    PSM.RelationshipType,
                    PSM.IsPrimaryGuardian,
                    PU.Email                                            AS ParentEmail,
                    ISNULL(PP.FullName,   PU.Username)                  AS ParentName,
                    ISNULL(PP.ContactNo,  '')                           AS ParentContact,
                    PU.IsActive                                         AS ParentActive
                FROM ParentStudentMapping PSM
                INNER JOIN Users       PU ON PU.UserId = PSM.ParentUserId
                LEFT  JOIN UserProfile PP ON PP.UserId = PU.UserId
                WHERE PSM.StudentUserId = @UserId
                  AND PSM.SessionId     = @SessId
                  AND PSM.IsActive      = 1");
            cmd.Parameters.AddWithValue("@UserId", userId);
            cmd.Parameters.AddWithValue("@SessId", sessionId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        // ══════════════════════════════════════════════════════════════════════
        //  OVERALL PERFORMANCE SCORE (dashboard KPI)
        // ══════════════════════════════════════════════════════════════════════
        public DataTable GetOverallPerformance(int userId, int sessionId)
        {
            var cmd = new SqlCommand(@"
                SELECT
                    -- Attendance score
                    ISNULL((SELECT CAST(
                        COUNT(DISTINCT CASE WHEN A.Status='Present' THEN A.Date END)*100.0
                        /NULLIF(COUNT(DISTINCT A.Date),0) AS DECIMAL(5,2))
                     FROM Attendance A WHERE A.UserId=@UserId AND A.SessionId=@SessId), 0)
                        AS AttendanceScore,

                    -- Assignment completion %
                    ISNULL((SELECT CAST(
                        COUNT(DISTINCT SUB.AssignmentId)*100.0
                        /NULLIF(COUNT(DISTINCT A2.AssignmentId),0) AS DECIMAL(5,2))
                     FROM Assignments A2
                     INNER JOIN AssignStudentSubject ASS2
                         ON ASS2.SubjectId=A2.SubjectId AND ASS2.UserId=@UserId AND ASS2.SessionId=@SessId
                     LEFT JOIN AssignmentSubmissions SUB ON SUB.AssignmentId=A2.AssignmentId AND SUB.StudentId=@UserId
                     WHERE A2.SessionId=@SessId AND A2.IsActive=1), 0)
                        AS AssignmentScore,

                    -- Quiz avg score %
                    ISNULL((SELECT CAST(AVG(CAST(QR.Score*100.0/NULLIF(Q.TotalMarks,0) AS FLOAT)) AS DECIMAL(5,2))
                     FROM QuizResults QR
                     INNER JOIN Quizzes Q ON Q.QuizId=QR.QuizId
                     WHERE QR.StudentId=@UserId AND Q.SessionId=@SessId), 0)
                        AS QuizScore,

                    -- Video completion %
                    ISNULL((SELECT CAST(
                        COUNT(DISTINCT CASE WHEN VWP.WatchedPercent>=80 THEN VWP.VideoId END)*100.0
                        /NULLIF(COUNT(DISTINCT V.VideoId),0) AS DECIMAL(5,2))
                     FROM Videos V
                     INNER JOIN AssignStudentSubject ASS3
                         ON ASS3.SubjectId=V.SubjectId AND ASS3.UserId=@UserId AND ASS3.SessionId=@SessId
                     LEFT JOIN VideoWatchProgress VWP ON VWP.VideoId=V.VideoId AND VWP.UserId=@UserId
                     WHERE V.SessionId=@SessId AND V.IsActive=1), 0)
                        AS VideoScore,

                    -- AI usage count
                    (SELECT COUNT(1) FROM VideoAIHistory VAI
                     INNER JOIN Videos VA ON VA.VideoId=VAI.VideoId
                     WHERE VAI.UserId=@UserId AND VA.SessionId=@SessId)
                        AS TotalAIUsage,

                    -- Total notifications unread
                    (SELECT COUNT(1) FROM Notifications N
                     WHERE N.UserId=@UserId AND N.SessionId=@SessId AND N.IsRead=0)
                        AS UnreadNotifications");
            cmd.Parameters.AddWithValue("@UserId", userId);
            cmd.Parameters.AddWithValue("@SessId", sessionId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }
    }
}