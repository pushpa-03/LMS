using System.Data;
using System.Data.SqlClient;
using LearningManagementSystem.GC;

namespace LearningManagementSystem.BL
{
    public class AcademicSetupBL
    {
        DataLayer dl = new DataLayer();

        // ================= GET LIST =================
        public DataTable GetData(string type, int instituteId)
        {
            string table = GetTable(type);
            SqlCommand cmd = new SqlCommand(
                $"SELECT * FROM {table} WHERE InstituteId=@Inst ORDER BY 1 DESC");

            cmd.Parameters.AddWithValue("@Inst", instituteId);

            return dl.GetDataTable(cmd);
        }

        // ================= INSERT =================
        public void Insert(AcademicSetupGC obj)
        {
            string table = GetTable(obj.Type);
            string col = GetColumn(obj.Type);

            SqlCommand cmd = new SqlCommand(
                $"INSERT INTO {table} (SocietyId,InstituteId,{col}) VALUES (@S,@I,@N)");

            cmd.Parameters.AddWithValue("@S", obj.SocietyId);
            cmd.Parameters.AddWithValue("@I", obj.InstituteId);
            cmd.Parameters.AddWithValue("@N", obj.Name);

            dl.ExecuteCMD(cmd);
        }

        // ================= UPDATE =================
        public void Update(AcademicSetupGC obj)
        {
            string table = GetTable(obj.Type);
            string col = GetColumn(obj.Type);
            string pk = GetPk(obj.Type);

            SqlCommand cmd = new SqlCommand(
                $"UPDATE {table} SET {col}=@N WHERE {pk}=@Id AND InstituteId=@Inst");

            cmd.Parameters.AddWithValue("@N", obj.Name);
            cmd.Parameters.AddWithValue("@Id", obj.Id);
            cmd.Parameters.AddWithValue("@Inst", obj.InstituteId);

            dl.ExecuteCMD(cmd);
        }

        // ================= DELETE =================
        public void Delete(string type, int id, int instituteId)
        {
            string table = GetTable(type);
            string pk = GetPk(type);

            SqlCommand cmd = new SqlCommand(
                $"DELETE FROM {table} WHERE {pk}=@Id AND InstituteId=@Inst");

            cmd.Parameters.AddWithValue("@Id", id);
            cmd.Parameters.AddWithValue("@Inst", instituteId);

            dl.ExecuteCMD(cmd);
        }

        // ================= GET BY ID =================
        public DataTable GetById(string type, int id, int instituteId)
        {
            string table = GetTable(type);
            string col = GetColumn(type);
            string pk = GetPk(type);

            SqlCommand cmd = new SqlCommand(
                $"SELECT {col} FROM {table} WHERE {pk}=@Id AND InstituteId=@Inst");

            cmd.Parameters.AddWithValue("@Id", id);
            cmd.Parameters.AddWithValue("@Inst", instituteId);

            return dl.GetDataTable(cmd);
        }

        // ================= HELPERS =================
        private string GetTable(string type)
            => type == "Level" ? "StudyLevels"
             : type == "Semester" ? "Semesters"
             : "Sections";

        private string GetColumn(string type)
            => type == "Level" ? "LevelName"
             : type == "Semester" ? "SemesterName"
             : "SectionName";

        private string GetPk(string type)
            => type == "Level" ? "LevelId"
             : type == "Semester" ? "SemesterId"
             : "SectionId";
    }
}