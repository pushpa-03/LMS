using System;
using System.Data;
using System.Data.SqlClient;

public class SocietyBL
{
    DataLayer dl = new DataLayer();

    // 🔹 INSERT
    public void InsertSociety(SocietyGC soc)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = @"INSERT INTO Societies 
                            (SocietyName, SocietyCode, IsActive) 
                            VALUES (@Name, @Code, 1)";

        cmd.Parameters.AddWithValue("@Name", soc.SocietyName);
        cmd.Parameters.AddWithValue("@Code", soc.SocietyCode);

        dl.ExecuteCMD(cmd);
    }

    // 🔹 UPDATE
    public void UpdateSociety(SocietyGC soc)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = @"UPDATE Societies 
                            SET SocietyName=@Name, SocietyCode=@Code 
                            WHERE SocietyId=@Id";

        cmd.Parameters.AddWithValue("@Name", soc.SocietyName);
        cmd.Parameters.AddWithValue("@Code", soc.SocietyCode);
        cmd.Parameters.AddWithValue("@Id", soc.SocietyId);

        dl.ExecuteCMD(cmd);
    }

    // 🔹 TOGGLE STATUS
    public void ToggleSocietyStatus(int societyId)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = @"UPDATE Societies 
                            SET IsActive = IsActive ^ 1 
                            WHERE SocietyId = @Id";

        cmd.Parameters.AddWithValue("@Id", societyId);

        dl.ExecuteCMD(cmd);
    }

    // 🔹 GET BY ID
    public DataTable GetSocietyById(int societyId)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "SELECT * FROM Societies WHERE SocietyId = @Id";
        cmd.Parameters.AddWithValue("@Id", societyId);

        return dl.GetDataTable(cmd);
    }

    // 🔹 GET ALL
    public DataTable GetAllSocieties()
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "SELECT * FROM Societies ORDER BY CreatedOn DESC";

        return dl.GetDataTable(cmd);
    }
}