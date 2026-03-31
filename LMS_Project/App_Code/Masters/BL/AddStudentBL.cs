using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

public class StudentBL
{
    DataLayer dl = new DataLayer();

    // ============================================
    // ✅ Get Current Academic Session
    // ============================================
    public int GetCurrentSessionId(int instituteId)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT TOP 1 SessionId 
            FROM AcademicSessions 
            WHERE InstituteId=@I AND IsCurrent=1");

        cmd.Parameters.AddWithValue("@I", instituteId);

        DataTable dt = dl.GetDataTable(cmd);

        if (dt.Rows.Count > 0)
            return Convert.ToInt32(dt.Rows[0]["SessionId"]);

        return 0;
    }

    // ============================================
    // ✅ Insert Student
    // ============================================
    public bool InsertStudent(
    int societyId,
    int instituteId,
    string username,
    string email,
    string fullName,
    string gender,
    DateTime dob,
    string contact,
    int? streamId,
    int? levelId,
    int? semesterid,
    int? courseId,
    int? sectionId,
    string rollNo)
    {
        int sessionId = GetCurrentSessionId(instituteId);

        if (sessionId == 0)
            throw new Exception("No Current Academic Session Found.");

        // 1️⃣ Insert User
        SqlCommand userCmd = new SqlCommand(@"
            INSERT INTO Users
            (Username, Email, PasswordHash, RoleId, SocietyId, InstituteId, IsActive, IsFirstLogin)
            VALUES
            (@U, @E, HASHBYTES('SHA2_256','Student@123'),
             (SELECT RoleId FROM Roles WHERE RoleName='Student'),
             @S, @I, 1, 1);
            SELECT SCOPE_IDENTITY();");

        userCmd.Parameters.AddWithValue("@U", username);
        userCmd.Parameters.AddWithValue("@E", email);
        userCmd.Parameters.AddWithValue("@S", societyId);
        userCmd.Parameters.AddWithValue("@I", instituteId);

        dl.IntializeConnection();
        userCmd.Connection = new SqlConnection(
            System.Configuration.ConfigurationManager
            .ConnectionStrings["DefaultConnection"].ConnectionString);

        userCmd.Connection.Open();
        int newUserId = Convert.ToInt32(userCmd.ExecuteScalar());
        userCmd.Connection.Close();

        List<SqlCommand> cmds = new List<SqlCommand>();

        // 2️⃣ Insert Profile
        SqlCommand profileCmd = new SqlCommand(@"
            INSERT INTO UserProfile
            (SocietyId, InstituteId, UserId, FullName, Gender, DOB, ContactNo,
             EmergencyContactName, EmergencyContactNo, Address, JoinedDate)
            VALUES
            (@S, @I, @Id, @FN, @G, @DOB, @C,
             'N/A','0000000000','N/A',GETDATE())");

        profileCmd.Parameters.AddWithValue("@S", societyId);
        profileCmd.Parameters.AddWithValue("@I", instituteId);
        profileCmd.Parameters.AddWithValue("@Id", newUserId);
        profileCmd.Parameters.AddWithValue("@FN", fullName);
        profileCmd.Parameters.AddWithValue("@G", gender);
        profileCmd.Parameters.AddWithValue("@DOB", dob);
        profileCmd.Parameters.AddWithValue("@C", contact);

        cmds.Add(profileCmd);

        // 3️⃣ Insert Academic Details
        SqlCommand acadCmd = new SqlCommand(@"
            INSERT INTO StudentAcademicDetails
            (UserId, SocietyId, InstituteId, SessionId,
             StreamId, CourseId, LevelId,SemesterId,SectionId, RollNumber)
            VALUES
            (@Id, @S, @I, @Sess,
             @Stream, @Course, @Level,@Semester, @Section, @Roll)");

        acadCmd.Parameters.AddWithValue("@Id", newUserId);
        acadCmd.Parameters.AddWithValue("@S", societyId);
        acadCmd.Parameters.AddWithValue("@I", instituteId);
        acadCmd.Parameters.AddWithValue("@Sess", sessionId);
        acadCmd.Parameters.AddWithValue("@Stream", (object)streamId ?? DBNull.Value);
        acadCmd.Parameters.AddWithValue("@Course", (object)courseId ?? DBNull.Value);
        acadCmd.Parameters.AddWithValue("@Level", (object)levelId ?? DBNull.Value);
        acadCmd.Parameters.AddWithValue("@Semester", (object)semesterid ?? DBNull.Value);
        acadCmd.Parameters.AddWithValue("@Section", (object)sectionId ?? DBNull.Value);
        acadCmd.Parameters.AddWithValue("@Roll", rollNo);

        cmds.Add(acadCmd);

        return dl.ExecuteTransaction(cmds);
    }

    // ============================================
    // ✅ Get Students (Grid)
    // ============================================
    public DataTable GetStudents(int instituteId, string search = "", string status = "All")
    {
        string query = @"
        SELECT U.UserId,
               U.Email,
               U.IsActive,
               P.FullName,
               P.ContactNo,
               SAD.RollNumber,
               ASes.SessionName AS YearName,
               S.StreamName,
               SAD.StreamId,
               C.CourseName,
               SAD.CourseId,
               Sty.LevelName,
               SAD.LevelId,
               Sem.SemesterName,
               SAD.SemesterId,
               Sec.SectionName,
               SAD.SectionId,     
               SAD.RollNumber
                FROM Users U
        INNER JOIN UserProfile P ON U.UserId = P.UserId
        INNER JOIN StudentAcademicDetails SAD ON U.UserId = SAD.UserId
        INNER JOIN AcademicSessions ASes ON SAD.SessionId = ASes.SessionId
        LEFT JOIN Streams S ON SAD.StreamId = S.StreamId
        LEFT JOIN Courses C ON SAD.CourseId = C.CourseId
        LEFT JOIN StudyLevels Sty ON SAD.LevelId = Sty.LevelId
        LEFT JOIN Semesters Sem ON SAD.SemesterId = Sem.SemesterId
        LEFT JOIN Sections Sec ON SAD.SectionId = Sec.SectionId
        WHERE U.RoleId = (SELECT RoleId FROM Roles WHERE RoleName='Student')
        AND U.InstituteId=@I";

        SqlCommand cmd = new SqlCommand();
        cmd.Parameters.AddWithValue("@I", instituteId);

        if (!string.IsNullOrWhiteSpace(search))
        {
            query += " AND (P.FullName LIKE @S OR SAD.RollNumber LIKE @S)";
            cmd.Parameters.AddWithValue("@S", "%" + search + "%");
        }

        if (status != "All")
        {
            query += " AND U.IsActive=@Status";
            cmd.Parameters.AddWithValue("@Status", status == "1" ? 1 : 0);
        }

        cmd.CommandText = query;

        return dl.GetDataTable(cmd);
    }

    // ============================================
    // ✅ Get Single Student (For Edit Modal)
    // ============================================
    public DataRow GetStudentById(int userId)
    {
        SqlCommand cmd = new SqlCommand(@"
        SELECT 
            U.Username,
            U.Email,
            P.FullName,
            P.ContactNo,
            P.Gender,
            P.DOB,
            SAD.RollNumber,
            SAD.StreamId,
            SAD.CourseId,
            SAD.LevelId,
            SAD.SemesterId,
            SAD.SectionId
        FROM Users U
        INNER JOIN UserProfile P ON U.UserId = P.UserId
        INNER JOIN StudentAcademicDetails SAD ON U.UserId = SAD.UserId  -- ✅ JOIN
        WHERE U.UserId=@Id");

        cmd.Parameters.AddWithValue("@Id", userId);

        DataTable dt = dl.GetDataTable(cmd);

        if (dt.Rows.Count > 0)
            return dt.Rows[0];

        return null;
    }

    // ============================================
    // ✅ Update Student
    // ============================================
    public void UpdateStudent(int userId, string email, string fullName, string contact,
    string rollNo, int? streamId, int? courseId, int? levelId, int? semesterId, int? sectionId)
    {
        SqlCommand cmd = new SqlCommand(@"
        UPDATE Users 
        SET Email=@Email
        WHERE UserId=@UserId;

        UPDATE UserProfile
        SET FullName=@FullName, ContactNo=@Contact
        WHERE UserId=@UserId;

        UPDATE StudentAcademicDetails
        SET RollNumber=@RollNo,
            StreamId=@Stream,
            CourseId=@Course,
            LevelId=@Level,
            SemesterId=@Semester,
            SectionId=@Section
        WHERE UserId=@UserId;
    ");

        cmd.Parameters.AddWithValue("@Email", email);
        cmd.Parameters.AddWithValue("@FullName", fullName);
        cmd.Parameters.AddWithValue("@Contact", contact);
        cmd.Parameters.AddWithValue("@RollNo", rollNo);
        cmd.Parameters.AddWithValue("@Stream", (object)streamId ?? DBNull.Value);
        cmd.Parameters.AddWithValue("@Course", (object)courseId ?? DBNull.Value);
        cmd.Parameters.AddWithValue("@Level", (object)levelId ?? DBNull.Value);
        cmd.Parameters.AddWithValue("@Semester", (object)semesterId ?? DBNull.Value);
        cmd.Parameters.AddWithValue("@Section", (object)sectionId ?? DBNull.Value);
        cmd.Parameters.AddWithValue("@UserId", userId);

        dl.ExecuteCMD(cmd);
    }
    // ============================================
    // ✅ Toggle Active
    // ============================================
    public bool ToggleStudent(int userId)
    {
        DataLayer dl = new DataLayer();

        SqlCommand cmd = new SqlCommand(@"
        UPDATE Users
        SET IsActive = CASE WHEN IsActive = 1 THEN 0 ELSE 1 END
        OUTPUT INSERTED.IsActive
        WHERE UserId = @U");

        cmd.Parameters.AddWithValue("@U", userId);

        DataTable dt = dl.GetDataTable(cmd);

        if (dt.Rows.Count > 0)
        {
            return Convert.ToBoolean(dt.Rows[0][0]);
        }

        return false;
    }
    public DataTable GetStudentStatsByStreamCourse(int instituteId)
    {
        SqlCommand cmd = new SqlCommand(@"
    SELECT 
        S.StreamName,
        C.CourseName,
        COUNT(*) TotalStudents
    FROM StudentAcademicDetails SAD
    LEFT JOIN Streams S ON SAD.StreamId = S.StreamId
    LEFT JOIN Courses C ON SAD.CourseId = C.CourseId
    INNER JOIN Users U ON U.UserId = SAD.UserId
    WHERE U.InstituteId = @I AND U.IsActive = 1
    GROUP BY S.StreamName, C.CourseName
    ORDER BY S.StreamName, TotalStudents DESC");

        cmd.Parameters.AddWithValue("@I", instituteId);

        return dl.GetDataTable(cmd);
    }


    public bool StudentExists(string username, string email, string rollNo, int instituteId)
    {
        SqlCommand cmd = new SqlCommand(@"
        SELECT COUNT(*) 
        FROM Users U
        INNER JOIN StudentAcademicDetails SAD ON U.UserId = SAD.UserId
        WHERE U.InstituteId=@I
        AND (U.Username=@U OR U.Email=@E OR SAD.RollNumber=@R)");

        cmd.Parameters.AddWithValue("@I", instituteId);
        cmd.Parameters.AddWithValue("@U", username);
        cmd.Parameters.AddWithValue("@E", email);
        cmd.Parameters.AddWithValue("@R", rollNo);

        DataTable dt = dl.GetDataTable(cmd);

        return Convert.ToInt32(dt.Rows[0][0]) > 0;
    }

    public void DeleteStudent(int userId)
    {
        List<SqlCommand> cmds = new List<SqlCommand>();

        SqlCommand cmd1 = new SqlCommand(
            "DELETE FROM StudentAcademicDetails WHERE UserId=@Id");
        cmd1.Parameters.AddWithValue("@Id", userId);

        SqlCommand cmd2 = new SqlCommand(
            "DELETE FROM UserProfile WHERE UserId=@Id");
        cmd2.Parameters.AddWithValue("@Id", userId);

        SqlCommand cmd3 = new SqlCommand(
            "DELETE FROM Users WHERE UserId=@Id");
        cmd3.Parameters.AddWithValue("@Id", userId);

        cmds.Add(cmd1);
        cmds.Add(cmd2);
        cmds.Add(cmd3);

        dl.ExecuteTransaction(cmds);
    }
}