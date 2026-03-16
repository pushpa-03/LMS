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
            (Username, Email, PasswordHash, RoleId, SocietyId, InstituteId, IsActive, IsFirstLogin)
            VALUES
            (@U, @E, HASHBYTES('SHA2_256','Parent@123'),
            (SELECT RoleId FROM Roles WHERE RoleName='Parent'),
            @S, @I, 1, 1);
            SELECT SCOPE_IDENTITY();", con, trans);

            userCmd.Parameters.AddWithValue("@U", gc.Username);
            userCmd.Parameters.AddWithValue("@E", gc.Email);
            userCmd.Parameters.AddWithValue("@S", gc.SocietyId);
            userCmd.Parameters.AddWithValue("@I", gc.InstituteId);

            int newUserId = Convert.ToInt32(userCmd.ExecuteScalar());

            // INSERT PROFILE
            SqlCommand profileCmd = new SqlCommand(@"
            INSERT INTO UserProfile
            (SocietyId, InstituteId, UserId, FullName, Gender, DOB,
             ContactNo, EmergencyContactName, EmergencyContactNo,
             Address, JoinedDate)
            VALUES
            (@S,@I,@Id,@FN,@G,@DOB,@C,'N/A','0000000000','N/A',GETDATE())",
            con, trans);

            profileCmd.Parameters.AddWithValue("@S", gc.SocietyId);
            profileCmd.Parameters.AddWithValue("@I", gc.InstituteId);
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
                (SocietyId, InstituteId, ParentUserId, StudentUserId,
                 RelationshipType, IsPrimaryGuardian)
                VALUES
                (@S,@I,@P,@Stu,@R,@Primary)", con, trans);

                mapCmd.Parameters.AddWithValue("@S", gc.SocietyId);
                mapCmd.Parameters.AddWithValue("@I", gc.InstituteId);
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

    public DataTable GetParents(int instituteId)
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

    WHERE SU.InstituteId = @I
    ORDER BY SP.FullName
    ");

        cmd.Parameters.AddWithValue("@I", instituteId);

        return dl.GetDataTable(cmd);
    }


    public void ToggleParent(int userId)
    {
        SqlCommand cmd = new SqlCommand(
        "UPDATE Users SET IsActive = 1 - IsActive WHERE UserId=@Id");

        cmd.Parameters.AddWithValue("@Id", userId);

        dl.ExecuteCMD(cmd);
    }

    public void DeleteParent(int userId)
    {
        List<SqlCommand> cmds = new List<SqlCommand>();

        SqlCommand cmd1 = new SqlCommand(
        "DELETE FROM ParentStudentMapping WHERE ParentUserId=@Id");
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