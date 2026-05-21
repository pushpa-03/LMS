using System.Data;
using System.Data.SqlClient;
using LearningManagementSystem.GC;

namespace LearningManagementSystem.BL
{
    public class AcademicSetupBL
    {
        DataLayer dl = new DataLayer();

        // ── GET LIST ──────────────────────────────────────────
        public DataTable GetData(string type, int instituteId, int sessionId)
        {
            string table = GetTable(type);
            string col = GetColumn(type);
            string pk = GetPk(type);
            SqlCommand cmd = new SqlCommand(
                $"SELECT {pk},{col} FROM {table} " +
                $"WHERE InstituteId=@Inst AND SessionId=@S " +
                $"ORDER BY {col} ASC");
            cmd.Parameters.AddWithValue("@Inst", instituteId);
            cmd.Parameters.AddWithValue("@S", sessionId);
            return dl.GetDataTable(cmd);
        }

        // ── DUPLICATE CHECK ───────────────────────────────────
        /// <summary>
        /// Returns true if a record with the same name already exists
        /// (case-insensitive, trimmed). Excludes the current record on edit.
        /// </summary>
        public bool IsDuplicate(string type, string name, int instituteId,
                                int sessionId, int excludeId = 0)
        {
            string table = GetTable(type);
            string col = GetColumn(type);
            string pk = GetPk(type);
            SqlCommand cmd = new SqlCommand(
                $"SELECT COUNT(1) FROM {table} " +
                $"WHERE InstituteId=@Inst AND SessionId=@S " +
                $"AND LOWER(LTRIM(RTRIM({col})))=LOWER(LTRIM(RTRIM(@N))) " +
                $"AND {pk}<>@ExId");
            cmd.Parameters.AddWithValue("@Inst", instituteId);
            cmd.Parameters.AddWithValue("@S", sessionId);
            cmd.Parameters.AddWithValue("@N", name.Trim());
            cmd.Parameters.AddWithValue("@ExId", excludeId);
            DataTable dt = dl.GetDataTable(cmd);
            return dt.Rows.Count > 0 && System.Convert.ToInt32(dt.Rows[0][0]) > 0;
        }

        // ── INSERT ────────────────────────────────────────────
        public void Insert(AcademicSetupGC obj)
        {
            string table = GetTable(obj.Type);
            string col = GetColumn(obj.Type);
            SqlCommand cmd = new SqlCommand(
                $"INSERT INTO {table} (SocietyId,InstituteId,SessionId,{col}) " +
                $"VALUES (@S,@I,@Sess,@N)");
            cmd.Parameters.AddWithValue("@S", obj.SocietyId);
            cmd.Parameters.AddWithValue("@I", obj.InstituteId);
            cmd.Parameters.AddWithValue("@Sess", obj.SessionId);
            cmd.Parameters.AddWithValue("@N", obj.Name.Trim());
            dl.ExecuteCMD(cmd);
        }

        // ── UPDATE ────────────────────────────────────────────
        public void Update(AcademicSetupGC obj)
        {
            string table = GetTable(obj.Type);
            string col = GetColumn(obj.Type);
            string pk = GetPk(obj.Type);
            SqlCommand cmd = new SqlCommand(
                $"UPDATE {table} SET {col}=@N " +
                $"WHERE {pk}=@Id AND InstituteId=@Inst AND SessionId=@Sess");
            cmd.Parameters.AddWithValue("@N", obj.Name.Trim());
            cmd.Parameters.AddWithValue("@Id", obj.Id);
            cmd.Parameters.AddWithValue("@Inst", obj.InstituteId);
            cmd.Parameters.AddWithValue("@Sess", obj.SessionId);
            dl.ExecuteCMD(cmd);
        }

        // ── DELETE ────────────────────────────────────────────
        public void Delete(string type, int id, int instituteId, int sessionId)
        {
            string table = GetTable(type);
            string pk = GetPk(type);
            SqlCommand cmd = new SqlCommand(
                $"DELETE FROM {table} " +
                $"WHERE {pk}=@Id AND InstituteId=@Inst AND SessionId=@Sess");
            cmd.Parameters.AddWithValue("@Id", id);
            cmd.Parameters.AddWithValue("@Inst", instituteId);
            cmd.Parameters.AddWithValue("@Sess", sessionId);
            dl.ExecuteCMD(cmd);
        }

        // ── GET BY ID ─────────────────────────────────────────
        public DataTable GetById(string type, int id, int instituteId, int sessionId)
        {
            string table = GetTable(type);
            string col = GetColumn(type);
            string pk = GetPk(type);
            SqlCommand cmd = new SqlCommand(
                $"SELECT {col} FROM {table} " +
                $"WHERE {pk}=@Id AND InstituteId=@Inst AND SessionId=@Sess");
            cmd.Parameters.AddWithValue("@Id", id);
            cmd.Parameters.AddWithValue("@Inst", instituteId);
            cmd.Parameters.AddWithValue("@Sess", sessionId);
            return dl.GetDataTable(cmd);
        }

        // ── HELPERS ───────────────────────────────────────────
        private string GetTable(string type)
            => type == "Level" ? "StudyLevels"
             : type == "Semester" ? "Semesters"
             : "Sections";

        private string GetColumn(string type)
            => type == "Level" ? "LevelName"
             : type == "Semester" ? "SemesterName"
             : "SectionName";

        public string GetPk(string type)
            => type == "Level" ? "LevelId"
             : type == "Semester" ? "SemesterId"
             : "SectionId";
    }
}