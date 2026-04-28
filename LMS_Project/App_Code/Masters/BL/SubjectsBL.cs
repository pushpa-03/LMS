using System;
using System.Data;
using System.Data.SqlClient;

public class SubjectsBL
{
    DataLayer dl = new DataLayer();

    public DataTable GetAdminStats(int instituteId, int sessionId)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT 
    (SELECT COUNT(*) FROM Subjects WHERE InstituteId = @InstId And SessionId = @SessId) as TotalSubjects,

    (SELECT COUNT(*) FROM Subjects 
     WHERE InstituteId = @InstId AND IsActive = 1 AND SessionId = @SessId) as ActiveCount,

    (SELECT COUNT(*) FROM Subjects 
     WHERE InstituteId = @InstId AND IsActive = 0 AND SessionId = @SessId) as InactiveCount,

    (SELECT COUNT(*) FROM LevelSemesterSubjects 
     WHERE InstituteId = @InstId AND IsMandatory = 1 AND SessionId = @SessId) as MandatoryCount,

    (SELECT COUNT(*) FROM AssignStudentSubject 
     WHERE InstituteId = @InstId AND SessionId = @SessId) as TotalEnrollments,

ISNULL(
    CAST(ROUND(AVG(CAST(EnrollCount AS FLOAT)), 1) AS VARCHAR),
    '0'
) as AvgPerSubject

FROM (
    SELECT COUNT(Id) as EnrollCount 
    FROM AssignStudentSubject 
    WHERE InstituteId = @InstId AND SessionId = @SessId 
    GROUP BY SubjectId
) as SubTable");

        cmd.Parameters.AddWithValue("@InstId", instituteId);
        cmd.Parameters.AddWithValue("@SessId", sessionId);
        DataTable dt = dl.GetDataTable(cmd);

        // Handle empty case to prevent crash
        if (dt.Rows.Count == 0)
        {
            DataRow row = dt.NewRow();
            row["TotalSubjects"] = 0;
            row["ActiveCount"] = 0;
            row["InactiveCount"] = 0;
            row["MandatoryCount"] = 0;
            row["TotalEnrollments"] = 0;
            row["AvgPerSubject"] = "0";
            dt.Rows.Add(row);
        }
        return dt;
    }

    public DataTable GetHierarchicalSubjects(int societyId, int instituteId, int sessionId, int isActive)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT 
                S.SubjectId, S.SubjectName, S.SubjectCode, S.IsActive,
                ST.StreamName, C.CourseName, SL.LevelName, Sem.SemesterName,
                LSS.IsMandatory,
                ISNULL((SELECT COUNT(*) FROM AssignStudentSubject ASS 
                        WHERE ASS.SubjectId = S.SubjectId AND ASS.SessionId = @SessId), 0) as StudentCount
            FROM Subjects S
            INNER JOIN LevelSemesterSubjects LSS ON S.SubjectId = LSS.SubjectId
            LEFT JOIN Streams ST ON LSS.StreamId = ST.StreamId
            LEFT JOIN Courses C ON LSS.CourseId = C.CourseId
            LEFT JOIN StudyLevels SL ON LSS.LevelId = SL.LevelId
            LEFT JOIN Semesters Sem ON LSS.SemesterId = Sem.SemesterId
            WHERE LSS.InstituteId = @InstId 
              AND LSS.SessionId = @SessId 
              AND S.IsActive = @IsActive
            ORDER BY ST.StreamName, C.CourseName, SL.LevelId, Sem.SemesterId");

        cmd.Parameters.AddWithValue("@InstId", instituteId);
        cmd.Parameters.AddWithValue("@SessId", sessionId);
        cmd.Parameters.AddWithValue("@IsActive", isActive);

        return dl.GetDataTable(cmd);
    }

    public void ToggleSubjectStatus(int subjectId)
    {
        SqlCommand cmd = new SqlCommand("UPDATE Subjects SET IsActive = CASE WHEN IsActive = 1 THEN 0 ELSE 1 END WHERE SubjectId=@SubId");
        cmd.Parameters.AddWithValue("@SubId", subjectId);
        dl.ExecuteCMD(cmd);
    }

    public DataTable GetFilterData(int instituteId)
    {
        SqlCommand cmd = new SqlCommand(@"
    SELECT 
        'Stream' AS Type, StreamId AS Id, StreamName AS Name FROM Streams WHERE InstituteId=@InstId
    UNION ALL
    SELECT 
        'Course', CourseId, CourseName FROM Courses WHERE InstituteId=@InstId
    UNION ALL
    SELECT 
        'Level', LevelId, LevelName FROM StudyLevels WHERE InstituteId=@InstId
    UNION ALL
    SELECT 
        'Semester', SemesterId, SemesterName FROM Semesters WHERE InstituteId=@InstId
    ");

        cmd.Parameters.AddWithValue("@InstId", instituteId);
        return dl.GetDataTable(cmd);
    }

    public DataTable GetFilteredSubjects(int societyId, int instituteId, int sessionId,
    int isActive, int? streamId, int? courseId, int? levelId, int? semId)
    {
        SqlCommand cmd = new SqlCommand(@"
        SELECT 
            S.SubjectId, S.SubjectName, S.SubjectCode, S.IsActive,
            ST.StreamName, C.CourseName, SL.LevelName, Sem.SemesterName,
            LSS.IsMandatory,
            ISNULL((SELECT COUNT(*) FROM AssignStudentSubject ASS 
                    WHERE ASS.SubjectId = S.SubjectId AND ASS.SessionId = @SessId), 0) as StudentCount
        FROM Subjects S
        INNER JOIN LevelSemesterSubjects LSS ON S.SubjectId = LSS.SubjectId
        LEFT JOIN Streams ST ON LSS.StreamId = ST.StreamId
        LEFT JOIN Courses C ON LSS.CourseId = C.CourseId
        LEFT JOIN StudyLevels SL ON LSS.LevelId = SL.LevelId
        LEFT JOIN Semesters Sem ON LSS.SemesterId = Sem.SemesterId
        WHERE LSS.InstituteId = @InstId 
          AND LSS.SessionId = @SessId 
          AND S.IsActive = @IsActive
          AND (@StreamId IS NULL OR LSS.StreamId = @StreamId)
          AND (@CourseId IS NULL OR LSS.CourseId = @CourseId)
          AND (@LevelId IS NULL OR LSS.LevelId = @LevelId)
          AND (@SemId IS NULL OR LSS.SemesterId = @SemId)
    ");

        cmd.Parameters.AddWithValue("@InstId", instituteId);
        cmd.Parameters.AddWithValue("@SessId", sessionId);
        cmd.Parameters.AddWithValue("@IsActive", isActive);
        cmd.Parameters.AddWithValue("@StreamId", (object)streamId ?? DBNull.Value);
        cmd.Parameters.AddWithValue("@CourseId", (object)courseId ?? DBNull.Value);
        cmd.Parameters.AddWithValue("@LevelId", (object)levelId ?? DBNull.Value);
        cmd.Parameters.AddWithValue("@SemId", (object)semId ?? DBNull.Value);

        return dl.GetDataTable(cmd);
    }
    public DataTable GetTeacherSubjects(int teacherUserId, int instituteId, int sessionId, int isActive)
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT DISTINCT
                S.SubjectId, S.SubjectName, S.SubjectCode, S.IsActive,
                ST.StreamName, C.CourseName, SL.LevelName, Sem.SemesterName,
                LSS.IsMandatory,
                ISNULL((SELECT COUNT(*) FROM AssignStudentSubject ASS 
                        WHERE ASS.SubjectId = S.SubjectId AND ASS.SessionId = @SessId), 0) AS StudentCount
            FROM SubjectFaculty SF
            INNER JOIN Subjects S ON SF.SubjectId = S.SubjectId
            LEFT JOIN LevelSemesterSubjects LSS ON S.SubjectId = LSS.SubjectId
                AND LSS.InstituteId = @InstId
                AND LSS.SessionId = @SessId
            LEFT JOIN Streams ST ON LSS.StreamId = ST.StreamId
            LEFT JOIN Courses C ON LSS.CourseId = C.CourseId
            LEFT JOIN StudyLevels SL ON LSS.LevelId = SL.LevelId
            LEFT JOIN Semesters Sem ON LSS.SemesterId = Sem.SemesterId
            WHERE SF.TeacherId = @TeacherId
              AND SF.InstituteId = @InstId
              AND SF.SessionId = @SessId
              AND ISNULL(SF.IsActive, 1) = 1
              AND S.IsActive = @IsActive
        ");

        cmd.Parameters.AddWithValue("@TeacherId", teacherUserId);
        cmd.Parameters.AddWithValue("@InstId", instituteId);
        cmd.Parameters.AddWithValue("@SessId", sessionId);
        cmd.Parameters.AddWithValue("@IsActive", isActive);

        return dl.GetDataTable(cmd);
    }
}

