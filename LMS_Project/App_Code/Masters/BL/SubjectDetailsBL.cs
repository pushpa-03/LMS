using System;
using System.Data;
using System.Data.SqlClient;

public class SubjectDetailsBL
{
    DataLayer dl = new DataLayer();

    // ================= SUBJECT =================
    public DataTable GetSubjectDetails(int subjectId)
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

    WHERE S.SubjectId = @SubjectId
    ");

        cmd.Parameters.AddWithValue("@SubjectId", subjectId);

        return dl.GetDataTable(cmd);
    }
    // ================= CHAPTER =================
    public DataTable GetChapters(int subjectId)
    {
        SqlCommand cmd = new SqlCommand(
            "SELECT * FROM Chapters WHERE SubjectId=@SubjectId ORDER BY OrderNo");

        cmd.Parameters.AddWithValue("@SubjectId", subjectId);

        return dl.GetDataTable(cmd);
    }

    public DataTable GetChapterById(int chapterId)
    {
        SqlCommand cmd = new SqlCommand(
            "SELECT * FROM Chapters WHERE ChapterId=@Id");

        cmd.Parameters.AddWithValue("@Id", chapterId);

        return dl.GetDataTable(cmd);
    }

    public void SaveChapter(string chapterId, string subjectId, string name, string orderNo)
    {
        SqlCommand cmd = new SqlCommand();

        if (string.IsNullOrEmpty(chapterId))
        {
            cmd.CommandText = @"INSERT INTO Chapters
            (SocietyId, InstituteId, SubjectId, ChapterName, OrderNo)
            SELECT SocietyId, InstituteId, SubjectId, @Name, @OrderNo
            FROM Subjects WHERE SubjectId=@SubjectId";
        }
        else
        {
            cmd.CommandText = @"UPDATE Chapters
                                SET ChapterName=@Name, OrderNo=@OrderNo
                                WHERE ChapterId=@ChapterId";
            cmd.Parameters.AddWithValue("@ChapterId", chapterId);
        }

        cmd.Parameters.AddWithValue("@SubjectId", subjectId);
        cmd.Parameters.AddWithValue("@Name", name);
        cmd.Parameters.AddWithValue("@OrderNo", orderNo);

        dl.ExecuteCMD(cmd);
    }

    public void DeleteChapter(int chapterId)
    {
        SqlCommand cmd = new SqlCommand(
            "DELETE FROM Chapters WHERE ChapterId=@Id");

        cmd.Parameters.AddWithValue("@Id", chapterId);

        dl.ExecuteCMD(cmd);
    }

    // ================= VIDEOS =================
    public DataTable GetVideosByChapter(int chapterId)
    {
        SqlCommand cmd = new SqlCommand(
            "SELECT * FROM Videos WHERE ChapterId=@Cid");

        cmd.Parameters.AddWithValue("@Cid", chapterId);

        return dl.GetDataTable(cmd);
    }

    public int InsertVideo(int societyId, int instituteId, int chapterId,
                           string title, string desc, string path,
                           string instructor, int userId)
    {
        SqlCommand cmd = new SqlCommand(@"
        INSERT INTO Videos
        (SocietyId, InstituteId, ChapterId, Title, Duration,
         Description, VideoPath, InstructorName,
         UploadedBy, UploadedOn, IsActive)
        VALUES
        (@SocietyId, @InstituteId, @ChapterId, @Title, '',
         @Desc, @Path, @Instructor,
         @UserId, GETDATE(), 1);

        SELECT SCOPE_IDENTITY();");

        cmd.Parameters.AddWithValue("@SocietyId", societyId);
        cmd.Parameters.AddWithValue("@InstituteId", instituteId);
        cmd.Parameters.AddWithValue("@ChapterId", chapterId);
        cmd.Parameters.AddWithValue("@Title", title);
        cmd.Parameters.AddWithValue("@Desc", desc);
        cmd.Parameters.AddWithValue("@Path", path);
        cmd.Parameters.AddWithValue("@Instructor", instructor);
        cmd.Parameters.AddWithValue("@UserId", userId);

        return Convert.ToInt32(dl.GetDataTable(cmd).Rows[0][0]);
    }

    public void InsertVideoTopics(int societyId, int instituteId,
                                  int videoId,
                                  string[] times, string[] titles)
    {
        for (int i = 0; i < times.Length; i++)
        {
            if (!string.IsNullOrEmpty(titles[i]))
            {
                SqlCommand cmd = new SqlCommand(@"
                INSERT INTO VideoTopics
                (SocietyId, InstituteId, VideoId, StartTime, TopicTitle)
                VALUES
                (@SocietyId, @InstituteId, @VideoId, @Time, @Title)");

                cmd.Parameters.AddWithValue("@SocietyId", societyId);
                cmd.Parameters.AddWithValue("@InstituteId", instituteId);
                cmd.Parameters.AddWithValue("@VideoId", videoId);
                cmd.Parameters.AddWithValue("@Time", times[i]);
                cmd.Parameters.AddWithValue("@Title", titles[i]);

                dl.ExecuteCMD(cmd);
            }
        }
    }

    // ================= MATERIALS =================
    public DataTable GetMaterialsByChapter(int chapterId)
    {
        SqlCommand cmd = new SqlCommand(
            "SELECT * FROM Materials WHERE ChapterId=@Cid");

        cmd.Parameters.AddWithValue("@Cid", chapterId);

        return dl.GetDataTable(cmd);
    }

    public void InsertMaterial(int societyId, int instituteId,
                               int chapterId, string title,
                               string path, string fileType)
    {
        SqlCommand cmd = new SqlCommand(@"
        INSERT INTO Materials
        (SocietyId, InstituteId, ChapterId,
         Title, FilePath, FileType, UploadedOn)
        VALUES
        (@SocietyId, @InstituteId, @ChapterId,
         @Title, @Path, @Type, GETDATE())");

        cmd.Parameters.AddWithValue("@SocietyId", societyId);
        cmd.Parameters.AddWithValue("@InstituteId", instituteId);
        cmd.Parameters.AddWithValue("@ChapterId", chapterId);
        cmd.Parameters.AddWithValue("@Title", title);
        cmd.Parameters.AddWithValue("@Path", path);
        cmd.Parameters.AddWithValue("@Type", fileType);

        dl.ExecuteCMD(cmd);
    }
}