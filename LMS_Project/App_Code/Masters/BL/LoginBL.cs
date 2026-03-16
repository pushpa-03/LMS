using System;
using System.Data;
using System.Data.SqlClient;

public class LoginBL
{
    DataLayer dl = new DataLayer();

    public LoginGC ValidateUser(string username, byte[] passwordHash)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = @"
        SELECT 
            U.UserId, U.Username, R.RoleName, U.IsActive,
            U.SocietyId, S.SocietyName, 
            U.InstituteId, I.InstituteName,
            I.LogoURL
        FROM Users U
        INNER JOIN Roles R ON U.RoleId = R.RoleId
        LEFT JOIN Societies S ON U.SocietyId = S.SocietyId
        LEFT JOIN Institutes I ON U.InstituteId = I.InstituteId
        WHERE (U.Username=@u OR U.Email=@u)
        AND U.PasswordHash=@p
        AND U.IsActive = 1";

        cmd.Parameters.AddWithValue("@u", username);
        cmd.Parameters.AddWithValue("@p", passwordHash);

        DataTable dt = dl.GetDataTable(cmd);

        if (dt.Rows.Count > 0)
        {
            DataRow row = dt.Rows[0];

            LoginGC obj = new LoginGC();
            obj.UserId = Convert.ToInt32(row["UserId"]);
            obj.Username = row["Username"].ToString();
            obj.RoleName = row["RoleName"].ToString();
            obj.IsActive = Convert.ToBoolean(row["IsActive"]);

            obj.SocietyId = row["SocietyId"] == DBNull.Value
                            ? (int?)null
                            : Convert.ToInt32(row["SocietyId"]);

            obj.SocietyName = row["SocietyName"]?.ToString();

            obj.InstituteId = row["InstituteId"] == DBNull.Value
                              ? (int?)null
                              : Convert.ToInt32(row["InstituteId"]);

            obj.InstituteName = row["InstituteName"]?.ToString();
            obj.LogoURL = row["LogoURL"]?.ToString();

            return obj;
        }

        return null;
    }

    public void UpdateLoginAudit(string username)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = @"UPDATE Users 
                            SET LastLogin=GETDATE(), IsFirstLogin=0 
                            WHERE Username=@u";

        cmd.Parameters.AddWithValue("@u", username);

        dl.ExecuteCMD(cmd);
    }
}