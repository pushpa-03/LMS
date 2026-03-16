using LearningManagementSystem.GC;
using System;
using System.Data;
using System.Data.SqlClient;

namespace LearningManagementSystem.BL
{
    public class AddSubjectBL
    {
        DataLayer dl = new DataLayer();

        // ================= GRID =================

        public DataTable GetSubjects(int instituteId, string status, string search)
        {
            string query = @"
            SELECT
            SubjectId,
            SubjectCode,
            SubjectName,
            Duration,
            IsActive
            FROM Subjects
            WHERE InstituteId=@I";

            SqlCommand cmd = new SqlCommand();
            cmd.Parameters.AddWithValue("@I", instituteId);

            if (status != "All")
            {
                query += " AND IsActive=@Status";
                cmd.Parameters.AddWithValue("@Status", status);
            }

            if (!string.IsNullOrEmpty(search))
            {
                query += " AND (SubjectName LIKE @Search OR SubjectCode LIKE @Search)";
                cmd.Parameters.AddWithValue("@Search", "%" + search + "%");
            }

            cmd.CommandText = query;

            return dl.GetDataTable(cmd);
        }

        // ================= INSERT =================

        public void Insert(AddSubjectGC obj)
        {
            SqlCommand cmd = new SqlCommand(@"

    INSERT INTO Subjects
    (SocietyId,InstituteId,SessionId,SubjectCode,SubjectName,Description,Duration)

    VALUES
    (@Society,@Institute,@SessionId,@Code,@Name,@Desc,@Duration)
    ");

            cmd.Parameters.AddWithValue("@Society", obj.SocietyId);
            cmd.Parameters.AddWithValue("@Institute", obj.InstituteId);
            cmd.Parameters.AddWithValue("@SessionId", obj.SessionId);
            cmd.Parameters.AddWithValue("@Code", obj.SubjectCode);
            cmd.Parameters.AddWithValue("@Name", obj.SubjectName);
            cmd.Parameters.AddWithValue("@Desc", obj.Description);
            cmd.Parameters.AddWithValue("@Duration", obj.Duration);

            dl.ExecuteCMD(cmd);
        }

        // ================= UPDATE =================

        public void Update(AddSubjectGC obj)
        {
            SqlCommand cmd = new SqlCommand(@"

            UPDATE Subjects SET
            SubjectCode=@Code,
            SubjectName=@Name,
            Description=@Desc,
            Duration=@Duration
            WHERE SubjectId=@Id
            ");

            cmd.Parameters.AddWithValue("@Id", obj.SubjectId);
            cmd.Parameters.AddWithValue("@Code", obj.SubjectCode);
            cmd.Parameters.AddWithValue("@Name", obj.SubjectName);
            cmd.Parameters.AddWithValue("@Desc", obj.Description);
            cmd.Parameters.AddWithValue("@Duration", obj.Duration);

            dl.ExecuteCMD(cmd);
        }

        // ================= OTHER =================
        public int GetCurrentSession(int instituteId)
        {
            SqlCommand cmd = new SqlCommand();
            cmd.CommandText =
            "SELECT SessionId FROM AcademicSessions WHERE InstituteId=@I AND IsCurrent=1";

            cmd.Parameters.AddWithValue("@I", instituteId);

            DataTable dt = dl.GetDataTable(cmd);

            if (dt.Rows.Count > 0)
                return Convert.ToInt32(dt.Rows[0]["SessionId"]);

            return 0;
        }
        public void Toggle(int id)
        {
            SqlCommand cmd = new SqlCommand(
                "UPDATE Subjects SET IsActive = IIF(IsActive=1,0,1) WHERE SubjectId=@Id");

            cmd.Parameters.AddWithValue("@Id", id);

            dl.ExecuteCMD(cmd);
        }

        public void Delete(int id)
        {
            SqlCommand cmd = new SqlCommand(
                "DELETE FROM Subjects WHERE SubjectId=@Id");

            cmd.Parameters.AddWithValue("@Id", id);

            dl.ExecuteCMD(cmd);
        }

        public DataTable GetById(int id)
        {
            SqlCommand cmd = new SqlCommand(
                "SELECT * FROM Subjects WHERE SubjectId=@Id");

            cmd.Parameters.AddWithValue("@Id", id);

            return dl.GetDataTable(cmd);
        }
    }
}