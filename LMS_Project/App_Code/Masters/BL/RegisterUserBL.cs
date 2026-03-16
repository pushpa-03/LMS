using System;
using System.Data;
using System.Data.SqlClient;

public class RegisterUserBL
{
    DataLayer dl = new DataLayer();

    // ================= LOAD SOCIETIES =================
    public DataTable GetSocieties()
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "SELECT SocietyId, SocietyName FROM Societies WHERE IsActive = 1 ORDER BY SocietyName";

        return dl.GetDataTable(cmd);
    }

    // ================= LOAD INSTITUTES =================
    public DataTable GetInstitutes(int societyId)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "SELECT InstituteId, InstituteName FROM Institutes WHERE SocietyId=@sid AND IsActive=1 ORDER BY InstituteName";
        cmd.Parameters.AddWithValue("@sid", societyId);

        return dl.GetDataTable(cmd);
    }

    // ================= GET ADMIN ROLE ID =================
    public int GetAdminRoleId()
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "SELECT RoleId FROM Roles WHERE RoleName = 'Admin'";

        DataTable dt = dl.GetDataTable(cmd);

        if (dt.Rows.Count > 0)
            return Convert.ToInt32(dt.Rows[0]["RoleId"]);

        return 0;
    }

    // ================= CHECK USERNAME =================
    public int CheckUsernameExists(string username)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "SELECT COUNT(*) AS Total FROM Users WHERE Username=@u";
        cmd.Parameters.AddWithValue("@u", username);

        DataTable dt = dl.GetDataTable(cmd);

        if (dt.Rows.Count > 0)
            return Convert.ToInt32(dt.Rows[0]["Total"]);

        return 0;
    }

    // ================= INSERT USER =================
    public void InsertUser(RegisterUserGC obj)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = @"
            INSERT INTO Users
            (Username, PasswordHash, Email, RoleId, SocietyId, InstituteId, IsActive, IsFirstLogin)
            VALUES
            (@Username, @PasswordHash, @Email, @RoleId, @SocietyId, @InstituteId, 1, 1)";

        cmd.Parameters.AddWithValue("@Username", obj.Username);
        cmd.Parameters.AddWithValue("@PasswordHash", obj.PasswordHash);
        cmd.Parameters.AddWithValue("@Email", obj.Email);
        cmd.Parameters.AddWithValue("@RoleId", obj.RoleId);
        cmd.Parameters.AddWithValue("@SocietyId", obj.SocietyId);
        cmd.Parameters.AddWithValue("@InstituteId", obj.InstituteId);

        dl.ExecuteCMD(cmd);
    }
}