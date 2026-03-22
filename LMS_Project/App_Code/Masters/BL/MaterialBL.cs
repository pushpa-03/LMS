using System.Data;
using System.Data.SqlClient;

public class MaterialBL
{
    DataLayer dl = new DataLayer();

    public DataTable GetMaterialById(int materialId)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT MaterialId, Title, FilePath, FileType
            FROM Materials
            WHERE MaterialId = @MaterialId");

        cmd.Parameters.AddWithValue("@MaterialId", materialId);
        return dl.GetDataTable(cmd);
    }

    public void SaveAIHistory(MaterialGC obj)
    {
        SqlCommand cmd = new SqlCommand(@"
            INSERT INTO MaterialAIHistory(MaterialId, UserId, Type, Question, Response)
            VALUES(@MaterialId, @UserId, @Type, @Question, @Response)");

        cmd.Parameters.AddWithValue("@MaterialId", obj.MaterialId);
        cmd.Parameters.AddWithValue("@UserId", obj.UserId);
        cmd.Parameters.AddWithValue("@Type", obj.Type);
        cmd.Parameters.AddWithValue("@Question", obj.Question ?? "");
        cmd.Parameters.AddWithValue("@Response", obj.Response);

        dl.ExecuteCMD(cmd);
    }

    public DataTable GetHistory(int materialId, int userId)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT Type, Question, Response, CreatedOn
            FROM MaterialAIHistory
            WHERE MaterialId=@MaterialId AND UserId=@UserId
            ORDER BY CreatedOn DESC");

        cmd.Parameters.AddWithValue("@MaterialId", materialId);
        cmd.Parameters.AddWithValue("@UserId", userId);

        return dl.GetDataTable(cmd);
    }

    // 🔥 Smart Memory (last 3 interactions)
    public string GetRecentContext(int materialId, int userId)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT TOP 3 Question + ' ' + Response AS Text
            FROM MaterialAIHistory
            WHERE MaterialId=@MaterialId AND UserId=@UserId
            ORDER BY CreatedOn DESC");

        cmd.Parameters.AddWithValue("@MaterialId", materialId);
        cmd.Parameters.AddWithValue("@UserId", userId);

        DataTable dt = dl.GetDataTable(cmd);

        string context = "";
        foreach (DataRow row in dt.Rows)
            context += row["Text"].ToString() + "\n";

        return context;
    }
}