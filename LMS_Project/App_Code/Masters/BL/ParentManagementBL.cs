using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using LearningManagementSystem.GC;

public class ParentBL
{
    DataLayer dl = new DataLayer();

    public void InsertParent(ParentGC gc)
    {
        SqlConnection con = new SqlConnection(
            System.Configuration.ConfigurationManager
            .ConnectionStrings["DefaultConnection"].ConnectionString);

        con.Open();
        SqlTransaction trans = con.BeginTransaction();

        try
        {

            // INSERT USER
            SqlCommand userCmd = new SqlCommand(@"
            INSERT INTO Users
            (Username, Email, PasswordHash, RoleId, SocietyId, InstituteId, SessionId, IsActive, IsFirstLogin)
            VALUES
            (@U, @E, HASHBYTES('SHA2_256','Parent@123'),
            (SELECT RoleId FROM Roles WHERE RoleName='Parent'),
            @S, @I, @SessionId, 1, 1);
            SELECT SCOPE_IDENTITY();", con, trans);

            userCmd.Parameters.AddWithValue("@U", gc.Username);
            userCmd.Parameters.AddWithValue("@E", gc.Email);
            userCmd.Parameters.AddWithValue("@S", gc.SocietyId);
            userCmd.Parameters.AddWithValue("@I", gc.InstituteId);
            userCmd.Parameters.AddWithValue("@SessionId", gc.SessionId);

            int newUserId = Convert.ToInt32(userCmd.ExecuteScalar());

            // INSERT PROFILE
            SqlCommand profileCmd = new SqlCommand(@"
            INSERT INTO UserProfile
            (SocietyId, InstituteId,SessionId, UserId, FullName, Gender, DOB,
             ContactNo, EmergencyContactName, EmergencyContactNo,
             Address, JoinedDate)
            VALUES
            (@S,@I,@SessionId, @Id,@FN,@G,@DOB,@C,'N/A','0000000000','N/A',GETDATE())",
            con, trans);

            profileCmd.Parameters.AddWithValue("@S", gc.SocietyId);
            profileCmd.Parameters.AddWithValue("@I", gc.InstituteId);
            profileCmd.Parameters.AddWithValue("@SessionId", gc.SessionId);
            profileCmd.Parameters.AddWithValue("@Id", newUserId);
            profileCmd.Parameters.AddWithValue("@FN", gc.FullName);
            profileCmd.Parameters.AddWithValue("@G", gc.Gender);
            profileCmd.Parameters.AddWithValue("@DOB",
            gc.DOB ?? (object)DateTime.Now);
            profileCmd.Parameters.AddWithValue("@C", gc.ContactNo);

            profileCmd.ExecuteNonQuery();

            // INSERT STUDENT MAPPING
            foreach (int studentId in gc.StudentIds)
            {
                SqlCommand mapCmd = new SqlCommand(@"
                INSERT INTO ParentStudentMapping
                (SocietyId, InstituteId,SessionId, ParentUserId, StudentUserId,
                 RelationshipType, IsPrimaryGuardian)
                VALUES
                (@S,@I,@SessionId,@P,@Stu,@R,@Primary)", con, trans);

                mapCmd.Parameters.AddWithValue("@S", gc.SocietyId);
                mapCmd.Parameters.AddWithValue("@I", gc.InstituteId);
                mapCmd.Parameters.AddWithValue("@SessionId", gc.SessionId);
                mapCmd.Parameters.AddWithValue("@P", newUserId);
                mapCmd.Parameters.AddWithValue("@Stu", studentId);
                mapCmd.Parameters.AddWithValue("@R", gc.RelationshipType);
                mapCmd.Parameters.AddWithValue("@Primary", gc.IsPrimaryGuardian);

                mapCmd.ExecuteNonQuery();
            }

            trans.Commit();
        }
        catch
        {
            trans.Rollback();
            throw;
        }
        finally
        {
            con.Close();
        }
    }

    public DataTable GetParents(int instituteId, int SessionId)
    {
        SqlCommand cmd = new SqlCommand(@"
    SELECT
        PS.StudentUserId AS StudentId,
        SP.FullName AS StudentName,
        PU.UserId AS ParentUserId,
        PP.FullName AS ParentName,
        PU.Email,
        PP.ContactNo,
        PS.RelationshipType AS Relation,
        PU.IsActive

    FROM ParentStudentMapping PS

    INNER JOIN Users SU 
        ON PS.StudentUserId = SU.UserId

    INNER JOIN UserProfile SP 
        ON SU.UserId = SP.UserId

    INNER JOIN Users PU 
        ON PS.ParentUserId = PU.UserId

    INNER JOIN UserProfile PP 
        ON PU.UserId = PP.UserId

    WHERE SU.InstituteId = @I And SU.SessionId = @SessionId
    ORDER BY SP.FullName
    ");

        cmd.Parameters.AddWithValue("@I", instituteId);
        cmd.Parameters.AddWithValue("@SessionId", SessionId);

        return dl.GetDataTable(cmd);
    }


    public DataTable GetParents(int instituteId, int sessionId, bool isActive)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT
                SP.FullName AS StudentName,
                PU.UserId AS ParentUserId,
                PP.FullName AS ParentName,
                PU.Email,
                PP.ContactNo,
                PS.RelationshipType AS Relation,
                PU.IsActive
            FROM ParentStudentMapping PS
            INNER JOIN Users PU ON PS.ParentUserId = PU.UserId
            INNER JOIN UserProfile PP ON PU.UserId = PP.UserId
            INNER JOIN Users SU ON PS.StudentUserId = SU.UserId
            INNER JOIN UserProfile SP ON SU.UserId = SP.UserId
            WHERE SU.InstituteId = @I
            AND PU.SessionId = @SessionId
            AND PU.IsActive = @A");

        cmd.Parameters.AddWithValue("@I", instituteId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);
        cmd.Parameters.AddWithValue("@A", isActive);

        return dl.GetDataTable(cmd);
    }


    public bool ToggleParent(int userId, int SessionId)
    {
        DataLayer dl = new DataLayer();

        SqlCommand cmd = new SqlCommand(@"
        UPDATE Users
        SET IsActive = CASE WHEN IsActive = 1 THEN 0 ELSE 1 END
        OUTPUT INSERTED.IsActive
        WHERE UserId = @U And SessionId = @SessionId");

        cmd.Parameters.AddWithValue("@U", userId);
        cmd.Parameters.AddWithValue("@SessionId", SessionId);

        DataTable dt = dl.GetDataTable(cmd);

        if (dt.Rows.Count > 0)
        {
            return Convert.ToBoolean(dt.Rows[0][0]);
        }

        return false;
    }
    public void DeleteParent(int userId, int SessionId)
    {
        List<SqlCommand> cmds = new List<SqlCommand>();

        SqlCommand cmd1 = new SqlCommand(
        "DELETE FROM ParentStudentMapping WHERE ParentUserId=@Id And SessionId = @SessionId");
        cmd1.Parameters.AddWithValue("@Id", userId);
        cmd1.Parameters.AddWithValue("@SessionId", SessionId);

        SqlCommand cmd2 = new SqlCommand(
        "DELETE FROM UserProfile WHERE UserId=@Id And SessionId = @SessionId");
        cmd2.Parameters.AddWithValue("@Id", userId);
        cmd2.Parameters.AddWithValue("@SessionId", SessionId);

        SqlCommand cmd3 = new SqlCommand(
        "DELETE FROM Users WHERE UserId=@Id And SessionId = @SessionId");
        cmd3.Parameters.AddWithValue("@Id", userId);
        cmd3.Parameters.AddWithValue("@SessionId", SessionId);

        cmds.Add(cmd1);
        cmds.Add(cmd2);
        cmds.Add(cmd3);

        dl.ExecuteTransaction(cmds);
    }
  
    public DataTable GetParentById(int userId, int SessionId)
    {
        SqlCommand cmd = new SqlCommand(@"
    SELECT 
        U.Username,
        U.Email,
        P.FullName,
        P.ContactNo
    FROM Users U
    INNER JOIN UserProfile P ON U.UserId = P.UserId
    WHERE U.UserId = @Id And U.SessionId = @SessionId");

        cmd.Parameters.AddWithValue("@Id", userId);
        cmd.Parameters.AddWithValue("@SessionId", SessionId);

        return dl.GetDataTable(cmd);
    }

    public void UpdateParent(ParentGC gc)
    {
        List<SqlCommand> cmds = new List<SqlCommand>();

        SqlCommand userCmd = new SqlCommand(@"
    UPDATE Users SET Username=@U, Email=@E
    WHERE UserId=@Id And SessionId = @SessionId");

        userCmd.Parameters.AddWithValue("@U", gc.Username);
        userCmd.Parameters.AddWithValue("@E", gc.Email);
        userCmd.Parameters.AddWithValue("@Id", gc.UserId);
        userCmd.Parameters.AddWithValue("@SessionId", gc.SessionId);

        cmds.Add(userCmd);

        SqlCommand profileCmd = new SqlCommand(@"
    UPDATE UserProfile
    SET FullName=@FN, ContactNo=@C, Gender=@G, DOB=@DOB
    WHERE UserId=@Id And SessionId = @SessionId");

        profileCmd.Parameters.AddWithValue("@FN", gc.FullName);
        profileCmd.Parameters.AddWithValue("@C", gc.ContactNo);
        profileCmd.Parameters.AddWithValue("@G", gc.Gender);
        profileCmd.Parameters.AddWithValue("@DOB", gc.DOB ?? (object)DBNull.Value);
        profileCmd.Parameters.AddWithValue("@Id", gc.UserId);
        profileCmd.Parameters.AddWithValue("@SessionId", gc.SessionId);

        cmds.Add(profileCmd);

        SqlCommand delMap = new SqlCommand(
            "DELETE FROM ParentStudentMapping WHERE ParentUserId=@Id And SessionId = @SessionId");
        delMap.Parameters.AddWithValue("@Id", gc.UserId);
        delMap.Parameters.AddWithValue("@SessionId", gc.SessionId);

        cmds.Add(delMap);

        foreach (int studentId in gc.StudentIds)
        {
            SqlCommand mapCmd = new SqlCommand(@"
        INSERT INTO ParentStudentMapping
        (SocietyId, InstituteId, SessionId, ParentUserId, StudentUserId,
         RelationshipType, IsPrimaryGuardian)
        VALUES (@S,@I,@SessionId,@P,@Stu,@R,@Primary)");

            mapCmd.Parameters.AddWithValue("@S", gc.SocietyId);
            mapCmd.Parameters.AddWithValue("@I", gc.InstituteId);
            mapCmd.Parameters.AddWithValue("@SessionId", gc.SessionId);
            mapCmd.Parameters.AddWithValue("@P", gc.UserId);
            mapCmd.Parameters.AddWithValue("@Stu", studentId);
            mapCmd.Parameters.AddWithValue("@R", gc.RelationshipType);
            mapCmd.Parameters.AddWithValue("@Primary", gc.IsPrimaryGuardian);

            cmds.Add(mapCmd);
        }

        dl.ExecuteTransaction(cmds);
    }

    //---called in ParentList.aspx
    public DataTable GetParentsWithStudentDetails(int instituteId, int SessionId, bool isActive)
    {
        SqlCommand cmd = new SqlCommand(@"
    SELECT
        SU.UserId AS StudentId,
        SP.FullName AS StudentName,

        ST.StreamName,
        C.CourseName,
        SL.LevelName,
        SM.SemesterName,
        SEC.SectionName,
        ASess.SessionName,

        PU.UserId AS ParentUserId,
        PP.FullName AS ParentName,
        PU.Email,
        PP.ContactNo,
        PS.RelationshipType,
        PU.IsActive

    FROM ParentStudentMapping PS

    INNER JOIN Users PU ON PS.ParentUserId = PU.UserId
    INNER JOIN UserProfile PP ON PU.UserId = PP.UserId

    INNER JOIN Users SU ON PS.StudentUserId = SU.UserId
    INNER JOIN UserProfile SP ON SU.UserId = SP.UserId

    LEFT JOIN StudentAcademicDetails SAD ON SU.UserId = SAD.UserId
    LEFT JOIN Streams ST ON SAD.StreamId = ST.StreamId
    LEFT JOIN Courses C ON SAD.CourseId = C.CourseId
    LEFT JOIN StudyLevels SL ON SAD.LevelId = SL.LevelId
    LEFT JOIN Semesters SM ON SAD.SemesterId = SM.SemesterId
    LEFT JOIN Sections SEC ON SAD.SectionId = SEC.SectionId
    LEFT JOIN AcademicSessions ASess ON SAD.SessionId = ASess.SessionId

    WHERE SU.InstituteId = @I And PU.SessionId = @SessionId
    AND PU.IsActive = @A

    ORDER BY SP.FullName
    ");

        cmd.Parameters.AddWithValue("@I", instituteId);
        cmd.Parameters.AddWithValue("@A", isActive);
        cmd.Parameters.AddWithValue("@SessionId", SessionId);

        return dl.GetDataTable(cmd);
    }

    public DataTable GetStats(int instituteId, int SessionId)
    {
        SqlCommand cmd = new SqlCommand(@"
        SELECT 
            COUNT(DISTINCT PU.UserId) AS TotalParents,
            COUNT(DISTINCT CASE WHEN PU.IsActive = 1 THEN PU.UserId END) AS ActiveParents,
            COUNT(DISTINCT CASE WHEN PU.IsActive = 0 THEN PU.UserId END) AS InactiveParents,
            COUNT(DISTINCT PS.StudentUserId) AS TotalLinks
        FROM ParentStudentMapping PS
        INNER JOIN Users PU ON PS.ParentUserId = PU.UserId
        INNER JOIN Users SU ON PS.StudentUserId = SU.UserId
       WHERE SU.InstituteId = @I AND SU.SessionId = @SessionId
    ");

        cmd.Parameters.AddWithValue("@I", instituteId);
        cmd.Parameters.AddWithValue("@SessionId", SessionId);

        return dl.GetDataTable(cmd);
    }
}