using LMS_Project.GC;
using LMS_Project.Teacher;
using System;
using System.Data;
using System.Data.SqlClient;

namespace LMS_Project.BL
{
    public class TeacherProfileBL
    {
        DataLayer objDL = new DataLayer();

        public TeacherProfileGC GetTeacherProfile(int userId)
        {
            TeacherProfileGC obj = new TeacherProfileGC();

            SqlCommand cmd = new SqlCommand();
            cmd.CommandText = @"
                SELECT u.Username, u.Email,
                       up.*, 
                       td.EmployeeId, td.ExperienceYears,
                       td.Qualification, td.Designation,
                       s.StreamName
                FROM Users u
                INNER JOIN UserProfile up ON u.UserId = up.UserId
                INNER JOIN TeacherDetails td ON u.UserId = td.UserId
                LEFT JOIN Streams s ON td.StreamId = s.StreamId
                WHERE u.UserId = @UserId";

            cmd.Parameters.AddWithValue("@UserId", userId);

            DataTable dt = objDL.GetDataTable(cmd);

            if (dt.Rows.Count > 0)
            {
                DataRow dr = dt.Rows[0];

                obj.UserId = userId;
                obj.Username = dr["Username"].ToString();
                obj.Email = dr["Email"].ToString();
                obj.FullName = dr["FullName"].ToString();
                obj.Gender = dr["Gender"].ToString();
                obj.DOB = dr.Field<DateTime?>("DOB") ?? DateTime.Now; obj.ContactNo = dr["ContactNo"].ToString();
                obj.Address = dr["Address"].ToString();
                obj.City = dr["City"].ToString();
                obj.Country = dr["Country"].ToString();
                obj.Pincode = dr.Field<int?>("Pincode") ?? 0;
                obj.EmployeeId = dr["EmployeeId"].ToString();
                obj.ExperienceYears = dr.Field<int?>("ExperienceYears") ?? 0; obj.Qualification = dr["Qualification"].ToString();
                obj.Designation = dr["Designation"].ToString();
                obj.StreamName = dr["StreamName"].ToString();
                obj.ProfileImage = dr["ProfileImage"].ToString();
            }

            return obj;
        }

        public void UpdateTeacherProfile(TeacherProfileGC obj)
        {
            SqlCommand cmd = new SqlCommand();
            cmd.CommandText = @"
        UPDATE UserProfile
        SET FullName=@FullName,
            ContactNo=@ContactNo,
            Address=@Address,
            City=@City,
            Country=@Country,
            Pincode=@Pincode
        WHERE UserId=@UserId;

        UPDATE TeacherDetails
        SET Qualification=@Qualification,
            ExperienceYears=@ExperienceYears,
            Designation=@Designation
        WHERE UserId=@UserId;";

            cmd.Parameters.AddWithValue("@UserId", obj.UserId);
            cmd.Parameters.AddWithValue("@FullName", obj.FullName ?? (object)DBNull.Value);
            cmd.Parameters.AddWithValue("@ContactNo", obj.ContactNo ?? (object)DBNull.Value);
            cmd.Parameters.AddWithValue("@Address", obj.Address ?? (object)DBNull.Value);
            cmd.Parameters.AddWithValue("@City", obj.City ?? (object)DBNull.Value);
            cmd.Parameters.AddWithValue("@Country", obj.Country ?? (object)DBNull.Value);

            cmd.Parameters.AddWithValue("@Pincode",
                obj.Pincode.HasValue ? (object)obj.Pincode.Value : DBNull.Value);

            cmd.Parameters.AddWithValue("@Qualification", obj.Qualification ?? (object)DBNull.Value);

            cmd.Parameters.AddWithValue("@ExperienceYears",
                obj.ExperienceYears.HasValue ? (object)obj.ExperienceYears.Value : DBNull.Value);

            cmd.Parameters.AddWithValue("@Designation", obj.Designation ?? (object)DBNull.Value);

            objDL.ExecuteCMD(cmd);
        }
    }
}