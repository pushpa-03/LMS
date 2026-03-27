using System;
using System.Data;
using System.Data.SqlClient;

public class SubjectFacultyBL
{
    DataLayer dl = new DataLayer();

    public DataTable GetTeachers(int instituteId)
    {
        SqlCommand cmd = new SqlCommand(
        @"SELECT U.UserId, P.FullName
          FROM Users U
          JOIN UserProfile P ON U.UserId=P.UserId
          WHERE U.RoleId=(SELECT RoleId FROM Roles WHERE RoleName='Teacher')
          AND U.InstituteId=@I");

        cmd.Parameters.AddWithValue("@I", instituteId);
        return dl.GetDataTable(cmd);
    }
    public DataTable GetSections(int instituteId)
    {
        SqlCommand cmd = new SqlCommand(
        @"SELECT SectionId, SectionName
      FROM Sections
      WHERE InstituteId=@I AND IsActive=1");

        cmd.Parameters.AddWithValue("@I", instituteId);

        return dl.GetDataTable(cmd);
    }
    public DataTable GetSubjects(int instituteId)
    {
        SqlCommand cmd = new SqlCommand(
        @"SELECT S.SubjectId, S.SubjectName
      FROM Subjects S
      JOIN AcademicSessions A ON S.SessionId = A.SessionId
      WHERE S.InstituteId = @I
      AND S.IsActive = 1
      AND A.IsCurrent = 1");

        cmd.Parameters.AddWithValue("@I", instituteId);

        return dl.GetDataTable(cmd);
    }
    public DataTable GetAll(int instituteId, int sessionId)
    {
        SqlCommand cmd = new SqlCommand(
        @"SELECT SF.SubjectFacultyId,
       SF.IsActive,
       P.FullName AS TeacherName,
       S.SubjectName,
       SEC.SectionName,
       ASY.SessionName
FROM SubjectFaculty SF
JOIN Users U ON SF.TeacherId=U.UserId
JOIN UserProfile P ON U.UserId=P.UserId
JOIN Subjects S ON SF.SubjectId=S.SubjectId
JOIN Sections SEC ON SF.SectionId = SEC.SectionId
JOIN AcademicSessions ASY ON SF.SessionId=ASY.SessionId
WHERE SF.InstituteId=@I
AND SF.SessionId=@S");

        cmd.Parameters.AddWithValue("@I", instituteId);
        cmd.Parameters.AddWithValue("@S", sessionId);

        return dl.GetDataTable(cmd);
    }

    public void Insert(SubjectFacultyGC obj)
    {
        SqlCommand cmd = new SqlCommand(
        @"INSERT INTO SubjectFaculty
      (SocietyId,InstituteId,SubjectId,
       SessionId,TeacherId,SectionId,AssignedBy)
      VALUES
      (@S,@I,@Sub,@Ses,@T,@Sec,@A)");

        cmd.Parameters.AddWithValue("@S", obj.SocietyId);
        cmd.Parameters.AddWithValue("@I", obj.InstituteId);
        cmd.Parameters.AddWithValue("@Sub", obj.SubjectId);
        cmd.Parameters.AddWithValue("@Ses", obj.SessionId);
        cmd.Parameters.AddWithValue("@T", obj.TeacherId);
        cmd.Parameters.AddWithValue("@Sec", obj.SectionId);
        cmd.Parameters.AddWithValue("@A", obj.AssignedBy);

        dl.ExecuteCMD(cmd);
    }

    public int GetCurrentSession(int instituteId)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = @"SELECT SessionId
                        FROM AcademicSessions
                        WHERE InstituteId=@I AND IsCurrent=1";

        cmd.Parameters.AddWithValue("@I", instituteId);

        DataTable dt = dl.GetDataTable(cmd);

        if (dt != null && dt.Rows.Count > 0)
            return Convert.ToInt32(dt.Rows[0]["SessionId"]);

        return 0;
    }
    public void Delete(int id)
    {
        SqlCommand cmd = new SqlCommand(
            "DELETE FROM SubjectFaculty WHERE SubjectFacultyId=@Id");
        cmd.Parameters.AddWithValue("@Id", id);
        dl.ExecuteCMD(cmd);
    }

    public void Toggle(int id)
    {
        SqlCommand cmd = new SqlCommand(
        @"UPDATE SubjectFaculty
          SET IsActive =
          CASE WHEN IsActive=1 THEN 0 ELSE 1 END
          WHERE SubjectFacultyId=@Id");

        cmd.Parameters.AddWithValue("@Id", id);
        dl.ExecuteCMD(cmd);
    }
}