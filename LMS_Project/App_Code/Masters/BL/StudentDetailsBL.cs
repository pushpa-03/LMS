using System.Data;
using System.Data.SqlClient;

public class StudentDetailsBL
{
    DataLayer dl = new DataLayer();

    public DataSet GetStudentFullDetails(int userId, string scope)
    {
        // Define specific filters for each block to avoid ambiguity
        string attFilter = scope == "Current" ? " AND Attendance.SessionId = (SELECT SessionId FROM AcademicSessions WHERE IsCurrent=1)" : "";
        string subFilter = scope == "Current" ? " AND A.SessionId = (SELECT SessionId FROM AcademicSessions WHERE IsCurrent=1)" : "";

        SqlCommand cmd = new SqlCommand($@"
        -- 0: Profile
        SELECT 
                U.Email, 
                P.FullName, P.Gender, P.DOB, P.ContactNo, P.Address, P.City, P.Pincode,
                P.EmergencyContactName, P.EmergencyContactNo, P.Skills, P.Hobbies, P.ProfileImage,
                SAD.RollNumber, 
                S.StreamName, 
                C.CourseName, 
                Sem.SemesterName, 
                Sty.LevelName
            FROM Users U 
            JOIN UserProfile P ON U.UserId = P.UserId
            JOIN StudentAcademicDetails SAD ON U.UserId = SAD.UserId
            LEFT JOIN Streams S ON SAD.StreamId = S.StreamId
            LEFT JOIN Courses C ON SAD.CourseId = C.CourseId
            LEFT JOIN Semesters Sem ON SAD.SemesterId = Sem.SemesterId
            LEFT JOIN StudyLevels Sty ON SAD.LevelId = Sty.LevelId
            WHERE U.UserId = @U;

        -- 1, 2, 3 (Empty placeholders to keep Table indexes synced with your UI)
        SELECT 1; SELECT 1; SELECT 1;

        -- 4: Attendance Stats (Specific Alias used here)
        SELECT ISNULL(SUM(CASE WHEN Status='Present' THEN 1 END),0) Present,
               ISNULL(SUM(CASE WHEN Status='Absent' THEN 1 END),0) Absent
        FROM Attendance WHERE UserId=@U {attFilter};

        -- 5: Subjects + Real Progress + Teacher Name (Specific Alias 'A.' used here)
        SELECT Sub.SubjectId, Sub.SubjectName, 
               ISNULL(TProf.FullName, 'TBD') as TeacherName,
               ISNULL((SELECT COUNT(*) FROM VideoViews VV JOIN Videos V ON VV.VideoId=V.VideoId 
                       JOIN Chapters Ch ON V.ChapterId=Ch.ChapterId 
                       WHERE VV.UserId=@U AND VV.IsCompleted=1 AND Ch.SubjectId=Sub.SubjectId) * 100 / 
               NULLIF((SELECT COUNT(*) FROM Videos V JOIN Chapters Ch ON V.ChapterId=Ch.ChapterId 
                       WHERE Ch.SubjectId=Sub.SubjectId),0), 0) as Progress
        FROM AssignStudentSubject A
        JOIN Subjects Sub ON A.SubjectId = Sub.SubjectId
        LEFT JOIN SubjectFaculty SF ON Sub.SubjectId = SF.SubjectId AND SF.IsActive = 1
        LEFT JOIN UserProfile TProf ON SF.TeacherId = TProf.UserId
        WHERE A.UserId=@U {subFilter};

        -- 6: Activity
        SELECT TOP 10 ActivityType, ActionTime FROM UserActivityLog WHERE UserId=@U ORDER BY ActionTime DESC;

        -- 7: Overall Progress
        SELECT (SELECT COUNT(*) FROM VideoViews WHERE UserId=@U AND IsCompleted=1) Videos,
               (SELECT COUNT(*) FROM AssignmentSubmissions WHERE StudentId=@U) Assignments,
               (SELECT COUNT(*) FROM QuizResults WHERE StudentId=@U) Quiz
    "); // Use your existing connection method

        cmd.Parameters.AddWithValue("@U", userId);
        return dl.ReturnDataSet(cmd);
    }
}