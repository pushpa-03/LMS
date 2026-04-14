using LearningManagementSystem.Admin;
using System;
using System.Data;
using System.Data.SqlClient;

public class SubjectDetailsBL
{
    DataLayer dl = new DataLayer();

    // ================= SUBJECT =================
    public DataTable GetSubjectDetails(int subjectId, int sessionId)
    {
        SqlCommand cmd = new SqlCommand(@"

    SELECT
        S.*,
        So.SocietyName,
        I.InstituteName,
        St.StreamName,
        C.CourseName,
        SL.LevelName,
        Sem.SemesterName

    FROM Subjects S

    LEFT JOIN Societies So ON S.SocietyId = So.SocietyId
    LEFT JOIN Institutes I ON S.InstituteId = I.InstituteId

    LEFT JOIN LevelSemesterSubjects LSS
        ON S.SubjectId = LSS.SubjectId

    LEFT JOIN Streams St
        ON LSS.StreamId = St.StreamId

    LEFT JOIN Courses C
        ON LSS.CourseId = C.CourseId

    LEFT JOIN StudyLevels SL
        ON LSS.LevelId = SL.LevelId

    LEFT JOIN Semesters Sem
        ON LSS.SemesterId = Sem.SemesterId

    WHERE S.SubjectId = @SubjectId AND LSS.SessionId = @SessionId
    ");

        cmd.Parameters.AddWithValue("@SubjectId", subjectId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);


        return dl.GetDataTable(cmd);
    }
    // ================= CHAPTER =================
    public DataTable GetChapters(int subjectId, int SessionId)
    {
        SqlCommand cmd = new SqlCommand(
            "SELECT * FROM Chapters WHERE SubjectId=@SubjectId AND SessionId = @SessionId ORDER BY OrderNo");

        cmd.Parameters.AddWithValue("@SubjectId", subjectId);
        cmd.Parameters.AddWithValue("@SessionId", SessionId);

        return dl.GetDataTable(cmd);
    }

    public DataTable GetChapterById(int chapterId, int SessionId)
    {
        SqlCommand cmd = new SqlCommand(
            "SELECT * FROM Chapters WHERE ChapterId=@Id AND SessionID = @SessionID");

        cmd.Parameters.AddWithValue("@Id", chapterId);
        cmd.Parameters.AddWithValue("@SessionId", SessionId);

        return dl.GetDataTable(cmd);
    }

    public void SaveChapter(string chapterId, int SessionId, string subjectId, string name, string orderNo)
    {
        SqlCommand cmd = new SqlCommand();

        if (string.IsNullOrEmpty(chapterId))
        {
            cmd.CommandText = @"
        INSERT INTO Chapters
        (SocietyId, InstituteId, SessionId, SubjectId, ChapterName, OrderNo)
        SELECT SocietyId, InstituteId, SessionId, SubjectId, @Name, @OrderNo
        FROM LevelSemesterSubjects 
        WHERE SubjectId=@SubjectId AND SessionId=@SessionId";
        }
        else
        {
            cmd.CommandText = @"
        UPDATE Chapters
        SET ChapterName=@Name, OrderNo=@OrderNo
        WHERE ChapterId=@ChapterId AND SessionId=@SessionId";

            cmd.Parameters.AddWithValue("@ChapterId", chapterId);
        }

        cmd.Parameters.AddWithValue("@SubjectId", subjectId);
        cmd.Parameters.AddWithValue("@Name", name);
        cmd.Parameters.AddWithValue("@OrderNo", orderNo);
        cmd.Parameters.AddWithValue("@SessionId", SessionId);

        dl.ExecuteCMD(cmd);
    }
    public void DeleteChapter(int chapterId, int SessionId)
    {
        SqlCommand cmd = new SqlCommand(
            "DELETE FROM Chapters WHERE ChapterId=@Id And SessionId = @SessionId");

        cmd.Parameters.AddWithValue("@Id", chapterId);
        cmd.Parameters.AddWithValue("@SessionId", SessionId);

        dl.ExecuteCMD(cmd);
    }

    // ================= VIDEOS =================
    public DataTable GetVideosByChapter(int chapterId, int SessionId)
    {
        SqlCommand cmd = new SqlCommand(
            "SELECT * FROM Videos WHERE ChapterId=@Cid And SessionId = @SessionId");

        cmd.Parameters.AddWithValue("@Cid", chapterId);
        cmd.Parameters.AddWithValue("@SessionId", SessionId);

        return dl.GetDataTable(cmd);
    }

    public int InsertVideo(int societyId, int instituteId,int sessionId, int chapterId,
                           string title, string desc, string path,
                           string instructor, int userId)
    {
        SqlCommand cmd = new SqlCommand(@"
        INSERT INTO Videos
        (SocietyId, InstituteId, SessionId, ChapterId, Title, Duration,
         Description, VideoPath, InstructorName,
         UploadedBy, UploadedOn, IsActive)
        VALUES
        (@SocietyId, @InstituteId, @SessionId, @ChapterId, @Title, '',
         @Desc, @Path, @Instructor,
         @UserId, GETDATE(), 1);

        SELECT SCOPE_IDENTITY();");

        cmd.Parameters.AddWithValue("@SocietyId", societyId);
        cmd.Parameters.AddWithValue("@InstituteId", instituteId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);
        cmd.Parameters.AddWithValue("@ChapterId", chapterId);
        cmd.Parameters.AddWithValue("@Title", title);
        cmd.Parameters.AddWithValue("@Desc", desc);
        cmd.Parameters.AddWithValue("@Path", path);
        cmd.Parameters.AddWithValue("@Instructor", instructor);
        cmd.Parameters.AddWithValue("@UserId", userId);

        DataTable dt = dl.GetDataTable(cmd);
        if (dt.Rows.Count == 0) return 0;

        return Convert.ToInt32(dt.Rows[0][0]);
    }

    public void InsertVideoTopics(int societyId, int instituteId,int sessionId,
                                  int videoId,
                                  string[] times, string[] titles)
    {
        for (int i = 0; i < times.Length; i++)
        {
            if (!string.IsNullOrEmpty(titles[i]))
            {
                SqlCommand cmd = new SqlCommand(@"
                INSERT INTO VideoTopics
                (SocietyId, InstituteId, SessionId, VideoId, StartTime, TopicTitle)
                VALUES
                (@SocietyId, @InstituteId, @SessionId, @VideoId, @Time, @Title)");

                cmd.Parameters.AddWithValue("@SocietyId", societyId);
                cmd.Parameters.AddWithValue("@InstituteId", instituteId);
                cmd.Parameters.AddWithValue("@SessionId", sessionId);
                cmd.Parameters.AddWithValue("@VideoId", videoId);
                cmd.Parameters.AddWithValue("@Time", times[i]);
                cmd.Parameters.AddWithValue("@Title", titles[i]);

                dl.ExecuteCMD(cmd);
            }
        }
    }

    // ================= MATERIALS =================
    public DataTable GetMaterialsByChapter(int chapterId, int sessionId)
    {
        SqlCommand cmd = new SqlCommand(
            "SELECT * FROM Materials WHERE ChapterId=@Cid And SessionId = @SessionId");

        cmd.Parameters.AddWithValue("@Cid", chapterId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);

        return dl.GetDataTable(cmd);
    }

    public void InsertMaterial(int societyId, int instituteId,int sessionId,
                               int chapterId, string title,
                               string path, string fileType)
    {
        SqlCommand cmd = new SqlCommand(@"
        INSERT INTO Materials
        (SocietyId, InstituteId, SessionId, ChapterId,
         Title, FilePath, FileType, UploadedOn)
        VALUES
        (@SocietyId, @InstituteId, @SessionId, @ChapterId,
         @Title, @Path, @Type, GETDATE())");

        cmd.Parameters.AddWithValue("@SocietyId", societyId);
        cmd.Parameters.AddWithValue("@InstituteId", instituteId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);
        cmd.Parameters.AddWithValue("@ChapterId", chapterId);
        cmd.Parameters.AddWithValue("@Title", title);
        cmd.Parameters.AddWithValue("@Path", path);
        cmd.Parameters.AddWithValue("@Type", fileType);

        dl.ExecuteCMD(cmd);
    }

    // ================= ASSIGNMENTS =================
    public DataTable GetAssignmentsBySubject(int subjectId,int sessionId)
    {
        SqlCommand cmd = new SqlCommand(@"
        SELECT *
        FROM Assignments
        WHERE SubjectId = @SubjectId AND IsActive = 1 And SessionId = @SessionId
        ORDER BY CreatedOn DESC
    ");

        cmd.Parameters.AddWithValue("@SubjectId", subjectId);
        cmd.Parameters.AddWithValue("@SessionId", sessionId);

        return dl.GetDataTable(cmd);
    }
}