using System;
using System.Data;
using System.Data.SqlClient;
using LMS.GC;

namespace LMS.BL
{
    public class InstituteBL
    {
        DataLayer dl = new DataLayer();

        // ================= INSERT =================
        public void InsertInstitute(InstituteGC model)
        {
            SqlCommand cmd = new SqlCommand();
            cmd.CommandText = @"INSERT INTO Institutes
                                (SocietyId, InstituteName, InstituteCode, EducationType,
                                 LogoURL, Phone, Email, ShortName, IsActive)
                                VALUES
                                (@SocietyId, @InstituteName, @InstituteCode, @EducationType,
                                 @LogoURL, @Phone, @Email, @ShortName, 1)";

            AddCommonParameters(cmd, model);
            dl.ExecuteCMD(cmd);
        }

        // ================= UPDATE =================
        public void UpdateInstitute(InstituteGC model)
        {
            SqlCommand cmd = new SqlCommand();
            cmd.CommandText = @"UPDATE Institutes SET
                                SocietyId=@SocietyId,
                                InstituteName=@InstituteName,
                                InstituteCode=@InstituteCode,
                                EducationType=@EducationType,
                                LogoURL=@LogoURL,
                                Phone=@Phone,
                                Email=@Email,
                                ShortName=@ShortName
                                WHERE InstituteId=@InstituteId";

            cmd.Parameters.AddWithValue("@InstituteId", model.InstituteId);
            AddCommonParameters(cmd, model);

            dl.ExecuteCMD(cmd);
        }

        private void AddCommonParameters(SqlCommand cmd, InstituteGC model)
        {
            cmd.Parameters.AddWithValue("@SocietyId", model.SocietyId);
            cmd.Parameters.AddWithValue("@InstituteName", model.InstituteName);
            cmd.Parameters.AddWithValue("@InstituteCode", model.InstituteCode);
            cmd.Parameters.AddWithValue("@EducationType", model.EducationType ?? "");
            cmd.Parameters.AddWithValue("@LogoURL", model.LogoURL ?? "");
            cmd.Parameters.AddWithValue("@Phone", model.Phone ?? "");
            cmd.Parameters.AddWithValue("@Email", model.Email ?? "");
            cmd.Parameters.AddWithValue("@ShortName", model.ShortName ?? "");
        }

        // ================= DUPLICATE CHECK =================
        public bool IsDuplicate(int societyId, string name, string code, int instituteId = 0)
        {
            SqlCommand cmd = new SqlCommand();
            cmd.CommandText = @"SELECT InstituteId 
                        FROM Institutes
                        WHERE SocietyId=@Sid
                        AND (InstituteCode=@Code OR InstituteName=@Name)
                        AND InstituteId<>@Id";

            cmd.Parameters.AddWithValue("@Sid", societyId);
            cmd.Parameters.AddWithValue("@Code", code);
            cmd.Parameters.AddWithValue("@Name", name);
            cmd.Parameters.AddWithValue("@Id", instituteId);

            DataTable dt = dl.GetDataTable(cmd);
            return dt.Rows.Count > 0;
        }

        // ================= GET BY ID =================
        public DataTable GetInstituteById(int id)
        {
            SqlCommand cmd = new SqlCommand();
            cmd.CommandText = "SELECT * FROM Institutes WHERE InstituteId=@Id";
            cmd.Parameters.AddWithValue("@Id", id);

            return dl.GetDataTable(cmd);
        }

        // ================= GET ALL =================
        public DataTable GetInstitutes(int societyId = 0)
        {
            SqlCommand cmd = new SqlCommand();

            cmd.CommandText = @"SELECT I.*, S.SocietyName
                                FROM Institutes I
                                INNER JOIN Societies S ON I.SocietyId = S.SocietyId
                                WHERE 1=1";

            if (societyId > 0)
            {
                cmd.CommandText += " AND I.SocietyId=@Sid";
                cmd.Parameters.AddWithValue("@Sid", societyId);
            }

            cmd.CommandText += " ORDER BY S.SocietyName, I.InstituteName";

            return dl.GetDataTable(cmd);
        }

        // ================= TOGGLE STATUS =================
        public void ToggleInstituteStatus(int instituteId)
        {
            SqlCommand cmd = new SqlCommand();
            cmd.CommandText = "UPDATE Institutes SET IsActive = IsActive ^ 1 WHERE InstituteId=@Id";
            cmd.Parameters.AddWithValue("@Id", instituteId);

            dl.ExecuteCMD(cmd);
        }

        public void DeleteInstitute(int instituteId)
        {
            SqlCommand cmd = new SqlCommand();
            cmd.CommandText = "DELETE FROM Institutes WHERE InstituteId=@Id";
            cmd.Parameters.AddWithValue("@Id", instituteId);
            dl.ExecuteCMD(cmd);
        }

        // ================= SOCIETIES =================
        public DataTable GetActiveSocieties()
        {
            SqlCommand cmd = new SqlCommand();
            cmd.CommandText = "SELECT SocietyId, SocietyName FROM Societies WHERE IsActive=1 ORDER BY SocietyName";
            return dl.GetDataTable(cmd);
        }

        public int GetSocietyIdByInstitute(int instituteId)
        {
            SqlCommand cmd = new SqlCommand();
            cmd.CommandText = "SELECT SocietyId FROM Institutes WHERE InstituteId=@Id";
            cmd.Parameters.AddWithValue("@Id", instituteId);

            DataTable dt = dl.GetDataTable(cmd);
            if (dt.Rows.Count > 0)
                return Convert.ToInt32(dt.Rows[0]["SocietyId"]);

            return 0;
        }
    }
}