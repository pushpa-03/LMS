using System;
using System.Data;
using System.Data.SqlClient;
using LMS.GC;

namespace LMS.BL
{
    public class StreamBL
    {
        DataLayer dl = new DataLayer();

        // ================= INSERT =================
        public void InsertStream(StreamGC model)
        {
            SqlCommand cmd = new SqlCommand();
            cmd.CommandText = @"INSERT INTO Streams
                                (SocietyId, InstituteId, StreamName, IsActive)
                                VALUES
                                (@SocietyId, @InstituteId, @StreamName, 1)";

            cmd.Parameters.AddWithValue("@SocietyId", model.SocietyId);
            cmd.Parameters.AddWithValue("@InstituteId", model.InstituteId);
            cmd.Parameters.AddWithValue("@StreamName", model.StreamName);

            dl.ExecuteCMD(cmd);
        }

        // ================= UPDATE =================
        public void UpdateStream(StreamGC model)
        {
            SqlCommand cmd = new SqlCommand();
            cmd.CommandText = @"UPDATE Streams
                                SET StreamName=@StreamName
                                WHERE StreamId=@StreamId
                                AND InstituteId=@InstituteId";

            cmd.Parameters.AddWithValue("@StreamName", model.StreamName);
            cmd.Parameters.AddWithValue("@StreamId", model.StreamId);
            cmd.Parameters.AddWithValue("@InstituteId", model.InstituteId);

            dl.ExecuteCMD(cmd);
        }

        // ================= DELETE =================
        public void DeleteStream(int streamId, int instituteId)
        {
            SqlCommand cmd = new SqlCommand();
            cmd.CommandText = @"DELETE FROM Streams
                                WHERE StreamId=@Id
                                AND InstituteId=@InstituteId";

            cmd.Parameters.AddWithValue("@Id", streamId);
            cmd.Parameters.AddWithValue("@InstituteId", instituteId);

            dl.ExecuteCMD(cmd);
        }

        // ================= TOGGLE STATUS =================
        public void ToggleStreamStatus(int streamId, int instituteId)
        {
            SqlCommand cmd = new SqlCommand();
            cmd.CommandText = @"UPDATE Streams
                                SET IsActive = 1 - IsActive
                                WHERE StreamId=@Id
                                AND InstituteId=@InstituteId";

            cmd.Parameters.AddWithValue("@Id", streamId);
            cmd.Parameters.AddWithValue("@InstituteId", instituteId);

            dl.ExecuteCMD(cmd);
        }

        // ================= GET ALL =================
        public DataTable GetStreams(int instituteId, string filter = "All")
        {
            SqlCommand cmd = new SqlCommand();

            cmd.CommandText = @"SELECT StreamId, StreamName, IsActive
                                FROM Streams
                                WHERE InstituteId=@InstituteId";

            cmd.Parameters.AddWithValue("@InstituteId", instituteId);

            if (filter != "All")
            {
                cmd.CommandText += " AND IsActive=@Status";
                cmd.Parameters.AddWithValue("@Status", filter == "1" ? 1 : 0);
            }

            cmd.CommandText += " ORDER BY StreamName";

            return dl.GetDataTable(cmd);
        }

        // ================= GET BY ID =================
        public DataTable GetStreamById(int streamId, int instituteId)
        {
            SqlCommand cmd = new SqlCommand();
            cmd.CommandText = @"SELECT * FROM Streams
                                WHERE StreamId=@Id
                                AND InstituteId=@InstituteId";

            cmd.Parameters.AddWithValue("@Id", streamId);
            cmd.Parameters.AddWithValue("@InstituteId", instituteId);

            return dl.GetDataTable(cmd);
        }

        // ================= DUPLICATE CHECK =================
        public bool IsStreamExists(int instituteId, string name, int streamId = 0)
        {
            SqlCommand cmd = new SqlCommand();
            cmd.CommandText = @"SELECT StreamId
                                FROM Streams
                                WHERE InstituteId=@InstituteId
                                AND StreamName=@Name
                                AND StreamId<>@Id";

            cmd.Parameters.AddWithValue("@InstituteId", instituteId);
            cmd.Parameters.AddWithValue("@Name", name);
            cmd.Parameters.AddWithValue("@Id", streamId);

            DataTable dt = dl.GetDataTable(cmd);
            return dt.Rows.Count > 0;
        }
    }
}