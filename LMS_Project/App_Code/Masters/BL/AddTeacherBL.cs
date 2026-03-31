using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

public class TeacherBL
{
    DataLayer dl = new DataLayer();

    // ===============================
    // GET TEACHERS
    // ===============================
    public DataTable GetTeachers(int instituteId, string search = "", string status = "All")
    {
        string query = @"
        SELECT S.StreamName AS Stream,
               U.UserId,
               U.IsActive,
               P.FullName,
               U.Email,
               T.EmployeeId,
               T.Designation
        FROM Users U
        INNER JOIN UserProfile P ON U.UserId = P.UserId
        INNER JOIN TeacherDetails T ON U.UserId = T.UserId
        INNER JOIN Streams S ON T.StreamId = S.StreamId
        WHERE U.RoleId = (SELECT RoleId FROM Roles WHERE RoleName='Teacher')
        AND U.InstituteId=@InstituteId";

        if (!string.IsNullOrEmpty(search))
            query += " AND (P.FullName LIKE @Search OR T.EmployeeId LIKE @Search)";

        if (status != "All")
            query += " AND U.IsActive=@Status";

        SqlCommand cmd = new SqlCommand(query);
        cmd.Parameters.AddWithValue("@InstituteId", instituteId);

        if (!string.IsNullOrEmpty(search))
            cmd.Parameters.AddWithValue("@Search", "%" + search + "%");

        if (status != "All")
            cmd.Parameters.AddWithValue("@Status", status == "1");

        return dl.GetDataTable(cmd);
    }

    // ===============================
    // INSERT TEACHER
    // ===============================
    public void InsertTeacher(TeacherGC t)
    {
        List<SqlCommand> cmds = new List<SqlCommand>();

        // Insert User
        SqlCommand cmdUser = new SqlCommand(@"
        INSERT INTO Users (Username, PasswordHash, RoleId, Email, SocietyId, InstituteId)
        VALUES (@U, HASHBYTES('SHA2_256','Teacher@123'),
        (SELECT RoleId FROM Roles WHERE RoleName='Teacher'),
        @E,@S,@I)");

        cmdUser.Parameters.AddWithValue("@U", t.Username);
        cmdUser.Parameters.AddWithValue("@E", t.Email);
        cmdUser.Parameters.AddWithValue("@S", t.SocietyId);
        cmdUser.Parameters.AddWithValue("@I", t.InstituteId);

        cmds.Add(cmdUser);

        // Insert Profile
        SqlCommand cmdProfile = new SqlCommand(@"
        INSERT INTO UserProfile
        (SocietyId, InstituteId, UserId, FullName, Gender, DOB,
         ContactNo, EmergencyContactName, EmergencyContactNo,
         Address, JoinedDate)
        VALUES
        (@S,@I,(SELECT UserId FROM Users WHERE Username=@U),
         @F,@G,@D,@C,'N/A','0000000000','N/A',GETDATE())");

        cmdProfile.Parameters.AddWithValue("@S", t.SocietyId);
        cmdProfile.Parameters.AddWithValue("@I", t.InstituteId);
        cmdProfile.Parameters.AddWithValue("@U", t.Username);
        cmdProfile.Parameters.AddWithValue("@F", t.FullName);
        cmdProfile.Parameters.AddWithValue("@G", t.Gender);
        cmdProfile.Parameters.AddWithValue("@D", t.DOB);
        cmdProfile.Parameters.AddWithValue("@C", t.ContactNo);

        cmds.Add(cmdProfile);

        // Insert TeacherDetails (✔ Correct Column Order)
        SqlCommand cmdTeacher = new SqlCommand(@"
        INSERT INTO TeacherDetails
        (UserId, SocietyId, InstituteId, StreamId,
         EmployeeId, ExperienceYears, Qualification, Designation)
        VALUES
        ((SELECT UserId FROM Users WHERE Username=@U),
         @S,@I,@Stream,@Emp,@Exp,'N/A',@Des)");

        cmdTeacher.Parameters.AddWithValue("@U", t.Username);
        cmdTeacher.Parameters.AddWithValue("@S", t.SocietyId);
        cmdTeacher.Parameters.AddWithValue("@I", t.InstituteId);
        cmdTeacher.Parameters.AddWithValue("@Stream", t.StreamId);
        cmdTeacher.Parameters.AddWithValue("@Emp", t.EmployeeId);
        cmdTeacher.Parameters.AddWithValue("@Exp", t.ExperienceYears);
        cmdTeacher.Parameters.AddWithValue("@Des", t.Designation);

        cmds.Add(cmdTeacher);

        dl.ExecuteTransaction(cmds);
    }

    // ===============================
    // UPDATE
    // ===============================
    public void UpdateTeacher(TeacherGC t)
    {
        List<SqlCommand> cmds = new List<SqlCommand>();

        SqlCommand cmd1 = new SqlCommand("UPDATE Users SET Email=@E WHERE UserId=@U");
        cmd1.Parameters.AddWithValue("@E", t.Email);
        cmd1.Parameters.AddWithValue("@U", t.UserId);
        cmds.Add(cmd1);

        SqlCommand cmd2 = new SqlCommand(@"
        UPDATE UserProfile
        SET FullName=@F, ContactNo=@C
        WHERE UserId=@U");

        cmd2.Parameters.AddWithValue("@F", t.FullName);
        cmd2.Parameters.AddWithValue("@C", t.ContactNo);
        cmd2.Parameters.AddWithValue("@U", t.UserId);
        cmds.Add(cmd2);

        SqlCommand cmd3 = new SqlCommand(@"
        UPDATE TeacherDetails
        SET Designation=@D,
            StreamId=@Stream
        WHERE UserId=@U");

        cmd3.Parameters.AddWithValue("@D", t.Designation);
        cmd3.Parameters.AddWithValue("@Stream", t.StreamId);
        cmd3.Parameters.AddWithValue("@U", t.UserId);
        cmds.Add(cmd3);

        dl.ExecuteTransaction(cmds);
    }

    // ===============================
    // DELETE
    // ===============================
    public void DeleteTeacher(int userId)
    {
        List<SqlCommand> cmds = new List<SqlCommand>();

        SqlCommand cmd1 = new SqlCommand("DELETE FROM TeacherDetails WHERE UserId=@U");
        cmd1.Parameters.AddWithValue("@U", userId);

        SqlCommand cmd2 = new SqlCommand("DELETE FROM UserProfile WHERE UserId=@U");
        cmd2.Parameters.AddWithValue("@U", userId);

        SqlCommand cmd3 = new SqlCommand("DELETE FROM Users WHERE UserId=@U");
        cmd3.Parameters.AddWithValue("@U", userId);

        cmds.Add(cmd1);
        cmds.Add(cmd2);
        cmds.Add(cmd3);

        dl.ExecuteTransaction(cmds);
    }

    public DataTable GetStreams(int instituteId)
    {
        SqlCommand cmd = new SqlCommand(
            "SELECT StreamId, StreamName FROM Streams WHERE InstituteId=@I ORDER BY StreamName");

        cmd.Parameters.AddWithValue("@I", instituteId);
        return dl.GetDataTable(cmd);
    }
    public DataTable GetTeacherById(int userId)
    {
        SqlCommand cmd = new SqlCommand(@"
        SELECT U.UserId, U.Email, U.IsActive,
               P.FullName, P.FatherName, P.MotherName, P.Gender, P.DOB, 
               P.ContactNo, P.EmergencyContactName, P.EmergencyContactNo,
               P.Address, P.City, P.Country, P.Pincode, P.JoinedDate,
               P.Skills, P.Hobbies, P.Description, P.ProfileImage,
               T.EmployeeId, T.ExperienceYears, T.Qualification, T.Designation,
               S.StreamName
        FROM Users U
        INNER JOIN UserProfile P ON U.UserId = P.UserId
        INNER JOIN TeacherDetails T ON U.UserId = T.UserId
        LEFT JOIN Streams S ON T.StreamId = S.StreamId
        WHERE U.UserId = @U");

        cmd.Parameters.AddWithValue("@U", userId);
        return dl.GetDataTable(cmd);
    }
    public void ToggleStatus(int userId)
    {
        SqlCommand cmd = new SqlCommand(
            "UPDATE Users SET IsActive = 1 - IsActive WHERE UserId=@U");

        cmd.Parameters.AddWithValue("@U", userId);
        dl.ExecuteCMD(cmd);
    }

    public DataTable GetFilteredTeachers(int instId, string search, int streamId, string status)
    {
        string query = @"
            SELECT S.StreamName AS Stream, U.UserId, U.IsActive, P.FullName, 
                   U.Email, T.EmployeeId, T.Designation
            FROM Users U
            JOIN UserProfile P ON U.UserId = P.UserId
            JOIN TeacherDetails T ON U.UserId = T.UserId
            JOIN Streams S ON T.StreamId = S.StreamId
            WHERE U.InstituteId = @instId 
            AND U.RoleId = (SELECT RoleId FROM Roles WHERE RoleName='Teacher')";

        if (!string.IsNullOrEmpty(search))
            query += " AND (P.FullName LIKE @search OR T.EmployeeId LIKE @search)";

        if (streamId > 0)
            query += " AND T.StreamId = @streamId";

        if (status != "All")
            query += " AND U.IsActive = @status";

        SqlCommand cmd = new SqlCommand(query);
        cmd.Parameters.AddWithValue("@instId", instId);
        cmd.Parameters.AddWithValue("@search", "%" + search + "%");
        cmd.Parameters.AddWithValue("@streamId", streamId);
        cmd.Parameters.AddWithValue("@status", status == "1");

        return dl.GetDataTable(cmd);
    }

    //public DataTable GetTeacherById(int userId)
    //{
    //    SqlCommand cmd = new SqlCommand(@"
    //        SELECT P.FullName, T.EmployeeId, T.Designation, U.Email, S.StreamName
    //        FROM Users U
    //        JOIN UserProfile P ON U.UserId = P.UserId
    //        JOIN TeacherDetails T ON U.UserId = T.UserId
    //        JOIN Streams S ON T.StreamId = S.StreamId
    //        WHERE U.UserId = @userId");
    //    cmd.Parameters.AddWithValue("@userId", userId);
    //    return dl.GetDataTable(cmd);
    //}

    //public DataTable GetStreams(int instId)
    //{
    //    return dl.GetDataTable(new SqlCommand($"SELECT StreamId, StreamName FROM Streams WHERE InstituteId={instId}"));
    //}
}