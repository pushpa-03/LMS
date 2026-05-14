using LearningManagementSystem.GC;
using System;
using System.Data;
using System.Data.SqlClient;

namespace LearningManagementSystem.BL
{
    public class AddSubjectBL
    {
        private readonly DataLayer _dl = new DataLayer();

        // ================= GET =================
        public DataTable GetSubjects(int instituteId, int sessionId, string status, string search)
        {
            string query = @"
            SELECT
                SubjectId,
                SubjectCode,
                SubjectName,
                Duration,
                IsActive,
                Description
            FROM Subjects
            WHERE InstituteId=@InstituteId
              AND SessionId=@SessionId";

            SqlCommand cmd = new SqlCommand();
            cmd.Parameters.AddWithValue("@InstituteId", instituteId);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);

            if (!string.IsNullOrEmpty(status) && status != "All")
            {
                query += " AND IsActive=@Status";
                cmd.Parameters.AddWithValue("@Status", status == "1" ? 1 : 0);
            }

            if (!string.IsNullOrEmpty(search))
            {
                query += " AND (SubjectName LIKE @Search OR SubjectCode LIKE @Search)";
                cmd.Parameters.AddWithValue("@Search", "%" + search + "%");
            }

            query += " ORDER BY SubjectName";

            cmd.CommandText = query;
            return _dl.GetDataTable(cmd);
        }

        // ================= GET BY ID =================
        public DataTable GetById(int id, int sessionId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT *
                FROM Subjects
                WHERE SubjectId=@Id AND SessionId=@SessionId");

            cmd.Parameters.AddWithValue("@Id", id);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);

            return _dl.GetDataTable(cmd);
        }

        // ================= INSERT =================
        public void Insert(AddSubjectGC obj)
        {
            SqlCommand cmd = new SqlCommand(@"
            INSERT INTO Subjects
            (SocietyId,InstituteId,SessionId,SubjectCode,SubjectName,Description,Duration,IsActive)
            VALUES
            (@Society,@Institute,@SessionId,@Code,@Name,@Desc,@Duration,@IsActive)");

            cmd.Parameters.AddWithValue("@Society", obj.SocietyId);
            cmd.Parameters.AddWithValue("@Institute", obj.InstituteId);
            cmd.Parameters.AddWithValue("@SessionId", obj.SessionId);
            cmd.Parameters.AddWithValue("@Code", obj.SubjectCode.ToUpper());
            cmd.Parameters.AddWithValue("@Name", obj.SubjectName);
            cmd.Parameters.AddWithValue("@Desc", string.IsNullOrEmpty(obj.Description) ? (object)DBNull.Value : obj.Description);
            cmd.Parameters.AddWithValue("@Duration", string.IsNullOrEmpty(obj.Duration) ? (object)DBNull.Value : obj.Duration);
            cmd.Parameters.AddWithValue("@IsActive", obj.IsActive);

            _dl.ExecuteCMD(cmd);
        }

        // ================= UPDATE =================
        public void Update(AddSubjectGC obj)
        {
            SqlCommand cmd = new SqlCommand(@"
            UPDATE Subjects SET
                SubjectCode=@Code,
                SubjectName=@Name,
                Description=@Desc,
                Duration=@Duration,
                IsActive=@IsActive
            WHERE SubjectId=@Id AND SessionId=@SessionId");

            cmd.Parameters.AddWithValue("@Id", obj.SubjectId);
            cmd.Parameters.AddWithValue("@SessionId", obj.SessionId);
            cmd.Parameters.AddWithValue("@Code", obj.SubjectCode.ToUpper());
            cmd.Parameters.AddWithValue("@Name", obj.SubjectName);
            cmd.Parameters.AddWithValue("@Desc", string.IsNullOrEmpty(obj.Description) ? (object)DBNull.Value : obj.Description);
            cmd.Parameters.AddWithValue("@Duration", string.IsNullOrEmpty(obj.Duration) ? (object)DBNull.Value : obj.Duration);
            cmd.Parameters.AddWithValue("@IsActive", obj.IsActive);

            _dl.ExecuteCMD(cmd);
        }

        // ================= TOGGLE =================
        public void Toggle(int id, int sessionId)
        {
            SqlCommand cmd = new SqlCommand(@"
            UPDATE Subjects
            SET IsActive = CASE WHEN IsActive=1 THEN 0 ELSE 1 END
            WHERE SubjectId=@Id AND SessionId=@SessionId");

            cmd.Parameters.AddWithValue("@Id", id);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);

            _dl.ExecuteCMD(cmd);
        }

        // ================= DELETE =================
        public void Delete(int id, int sessionId)
        {
            SqlCommand cmd = new SqlCommand(@"
            DELETE FROM Subjects
            WHERE SubjectId=@Id AND SessionId=@SessionId");

            cmd.Parameters.AddWithValue("@Id", id);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);

            _dl.ExecuteCMD(cmd);
        }

        // ================= DUPLICATE CHECK =================
        public bool IsCodeDuplicate(int instituteId, int sessionId, string code, int excludeId = 0)
        {
            SqlCommand cmd = new SqlCommand(@"
            SELECT COUNT(1) AS Cnt
            FROM Subjects
            WHERE InstituteId=@InstituteId
              AND SessionId=@SessionId
              AND UPPER(SubjectCode)=@Code
              AND SubjectId<>@ExcludeId");

            cmd.Parameters.AddWithValue("@InstituteId", instituteId);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);
            cmd.Parameters.AddWithValue("@Code", code.ToUpper());
            cmd.Parameters.AddWithValue("@ExcludeId", excludeId);

            DataTable dt = _dl.GetDataTable(cmd);

            return dt.Rows.Count > 0 && Convert.ToInt32(dt.Rows[0]["Cnt"]) > 0;
        }

        // ================= IN USE CHECK =================
        public bool IsSubjectInUse(int subjectId)
        {
            SqlCommand cmd = new SqlCommand(@"
            SELECT
            (
                SELECT COUNT(1) FROM LevelSemesterSubjects WHERE SubjectId=@Id
            ) +
            (
                SELECT COUNT(1) FROM SubjectGroupSubjects WHERE SubjectId=@Id
            ) +
            (
                SELECT COUNT(1) FROM StudentElectiveSubjects WHERE SubjectId=@Id
            ) +
            (
                SELECT COUNT(1) FROM AssignStudentSubject WHERE SubjectId=@Id
            ) +
            (
                SELECT COUNT(1) FROM SubjectFaculty WHERE SubjectId=@Id
            ) +
            (
                SELECT COUNT(1) FROM TeacherCourses WHERE SubjectId=@Id
            ) AS TotalUsage");

            cmd.Parameters.AddWithValue("@Id", subjectId);

            DataTable dt = _dl.GetDataTable(cmd);

            return dt.Rows.Count > 0 && Convert.ToInt32(dt.Rows[0]["TotalUsage"]) > 0;
        }
    }
}

//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

//using LearningManagementSystem.GC;
//using System;
//using System.Data;
//using System.Data.SqlClient;

//namespace LearningManagementSystem.BL
//{
//    public class AddSubjectBL
//    {
//        DataLayer dl = new DataLayer();

//        // ================= GRID =================

//        public DataTable GetSubjects(int instituteId, int sessionId, string status, string search)
//        {
//            string query = @"
//            SELECT
//                SubjectId,
//                SubjectCode,
//                SubjectName,
//                Duration,
//                IsActive
//            FROM Subjects
//            WHERE InstituteId=@I AND SessionId=@SessionId";

//            SqlCommand cmd = new SqlCommand();
//            cmd.Parameters.AddWithValue("@I", instituteId);
//            cmd.Parameters.AddWithValue("@SessionId", sessionId);

//            if (status != "All")
//            {
//                query += " AND IsActive=@Status";
//                cmd.Parameters.AddWithValue("@Status", status == "1");
//            }

//            if (!string.IsNullOrEmpty(search))
//            {
//                query += " AND (SubjectName LIKE @Search OR SubjectCode LIKE @Search)";
//                cmd.Parameters.AddWithValue("@Search", "%" + search + "%");
//            }

//            cmd.CommandText = query;

//            return dl.GetDataTable(cmd);
//        }

//        // ================= INSERT =================

//        public void Insert(AddSubjectGC obj)
//        {
//            SqlCommand cmd = new SqlCommand(@"

//    INSERT INTO Subjects
//    (SocietyId,InstituteId,SessionId,SubjectCode,SubjectName,Description,Duration)

//    VALUES
//    (@Society,@Institute,@SessionId,@Code,@Name,@Desc,@Duration)
//    ");

//            cmd.Parameters.AddWithValue("@Society", obj.SocietyId);
//            cmd.Parameters.AddWithValue("@Institute", obj.InstituteId);
//            cmd.Parameters.AddWithValue("@SessionId", obj.SessionId);
//            cmd.Parameters.AddWithValue("@Code", obj.SubjectCode);
//            cmd.Parameters.AddWithValue("@Name", obj.SubjectName);
//            cmd.Parameters.AddWithValue("@Desc", obj.Description);
//            cmd.Parameters.AddWithValue("@Duration", obj.Duration);

//            dl.ExecuteCMD(cmd);
//        }

//        // ================= UPDATE =================

//        public void Update(AddSubjectGC obj)
//        {
//            SqlCommand cmd = new SqlCommand(@"

//            UPDATE Subjects SET
//            SubjectCode=@Code,
//            SubjectName=@Name,
//            Description=@Desc,
//            Duration=@Duration
//            WHERE SubjectId=@Id AND SessionId=@SessionId
//            ");

//            cmd.Parameters.AddWithValue("@SessionId", obj.SessionId);
//            cmd.Parameters.AddWithValue("@Id", obj.SubjectId);
//            cmd.Parameters.AddWithValue("@Code", obj.SubjectCode);
//            cmd.Parameters.AddWithValue("@Name", obj.SubjectName);
//            cmd.Parameters.AddWithValue("@Desc", obj.Description);
//            cmd.Parameters.AddWithValue("@Duration", obj.Duration);

//            dl.ExecuteCMD(cmd);
//        }


//        public void Toggle(int id, int sessionId)
//        {
//            SqlCommand cmd = new SqlCommand(
//                "UPDATE Subjects SET IsActive = IIF(IsActive=1,0,1) WHERE SubjectId=@Id AND SessionId=@SessionId");

//            cmd.Parameters.AddWithValue("@Id", id);
//            cmd.Parameters.AddWithValue("@SessionId", sessionId);

//            dl.ExecuteCMD(cmd);
//        }

//        public void Delete(int id, int sessionId)
//        {
//            SqlCommand cmd = new SqlCommand(@"
//            IF EXISTS (SELECT 1 FROM OtherTable WHERE SubjectId=@Id)
//            BEGIN
//                RAISERROR('IN_USE',16,1)
//                RETURN
//            END

//            DELETE FROM Subjects WHERE SubjectId=@Id AND SessionId=@SessionId
//            ");

//            cmd.Parameters.AddWithValue("@Id", id);
//            cmd.Parameters.AddWithValue("@SessionId", sessionId);

//            dl.ExecuteCMD(cmd);
//        }

//        public DataTable GetById(int id, int sessionId)
//        {
//            SqlCommand cmd = new SqlCommand(
//                "SELECT * FROM Subjects WHERE SubjectId=@Id AND SessionId=@SessionId");

//            cmd.Parameters.AddWithValue("@Id", id);
//            cmd.Parameters.AddWithValue("@SessionId", sessionId);

//            return dl.GetDataTable(cmd);
//        }
//    }
//}