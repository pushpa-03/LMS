using System;
using System.Data;
using System.Data.SqlClient;

public class SubjectsBL
{
    DataLayer dl = new DataLayer();

    public DataTable GetSubjects(int societyId, int instituteId, int sessionId)
    {
        SqlCommand cmd = new SqlCommand(@"

        SELECT DISTINCT
            S.SubjectId,
            S.SubjectCode,
            S.SubjectName,
            S.IsActive

        FROM Subjects S
        INNER JOIN LevelSemesterSubjects LSS
            ON S.SubjectId = LSS.SubjectId

        WHERE
            LSS.SocietyId=@SocietyId
            AND LSS.InstituteId=@InstituteId
            AND LSS.SessionId=@SessionId 

        ORDER BY S.SubjectName
        ");

        cmd.Parameters.AddWithValue("@SocietyId", societyId);
        cmd.Parameters.AddWithValue("@InstituteId", instituteId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);

        return dl.GetDataTable(cmd);
    }

    public int GetCurrentSession(int instituteId)
    {
        SqlCommand cmd = new SqlCommand(@"
        SELECT TOP 1 SessionId
        FROM AcademicSessions
        WHERE InstituteId=@InstituteId AND IsCurrent=1
        ");

        cmd.Parameters.AddWithValue("@InstituteId", instituteId);

        DataTable dt = dl.GetDataTable(cmd);

        if (dt.Rows.Count > 0)
            return Convert.ToInt32(dt.Rows[0]["SessionId"]);

        return 0;
    }

    public void ToggleSubjectStatus(int subjectId)
    {
        SqlCommand cmd = new SqlCommand(@"

        UPDATE Subjects
        SET IsActive =
        CASE WHEN IsActive = 1 THEN 0 ELSE 1 END
        WHERE SubjectId=@SubjectId
        ");

        cmd.Parameters.AddWithValue("@SubjectId", subjectId);

        dl.ExecuteCMD(cmd);
    }
}