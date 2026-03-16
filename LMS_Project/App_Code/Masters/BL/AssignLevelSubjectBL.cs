using LearningManagementSystem.GC;
using System;
using System.Data;
using System.Data.SqlClient;

namespace LearningManagementSystem.BL
{
    public class AssignLevelSubjectBL
    {
        DataLayer dl = new DataLayer();

        public DataTable GetSubjects(int instituteId)
        {
            SqlCommand cmd = new SqlCommand();

            cmd.CommandText =
            "SELECT SubjectId,SubjectName FROM Subjects WHERE InstituteId=@I and IsActive =1";

            cmd.Parameters.AddWithValue("@I", instituteId);

            return dl.GetDataTable(cmd);
        }

        public DataTable GetStreams(int instituteId)
        {
            SqlCommand cmd = new SqlCommand();

            cmd.CommandText =
            "SELECT StreamId,StreamName FROM Streams WHERE InstituteId=@I AND IsActive=1";

            cmd.Parameters.AddWithValue("@I", instituteId);

            return dl.GetDataTable(cmd);
        }

        public DataTable GetCourses(int streamId)
        {
            SqlCommand cmd = new SqlCommand();

            cmd.CommandText =
            "SELECT CourseId,CourseName FROM Courses WHERE StreamId=@S AND IsActive=1";

            cmd.Parameters.AddWithValue("@S", streamId);

            return dl.GetDataTable(cmd);
        }

        public DataTable GetLevels(int instituteId)
        {
            SqlCommand cmd = new SqlCommand();

            cmd.CommandText =
            "SELECT LevelId,LevelName FROM StudyLevels WHERE InstituteId=@I";

            cmd.Parameters.AddWithValue("@I", instituteId);

            return dl.GetDataTable(cmd);
        }

        public DataTable GetSemesters(int instituteId)
        {
            SqlCommand cmd = new SqlCommand();

            cmd.CommandText =
            "SELECT SemesterId,SemesterName FROM Semesters WHERE InstituteId=@I";

            cmd.Parameters.AddWithValue("@I", instituteId);

            return dl.GetDataTable(cmd);
        }
        public void InsertLevelSubject(LevelSemesterSubjectGC obj)
        {
            SqlCommand cmd = new SqlCommand();

            cmd.CommandText = @"INSERT INTO LevelSemesterSubjects
            (SocietyId,InstituteId,SessionId,StreamId,CourseId,
            LevelId,SemesterId,SubjectId,IsMandatory)

            VALUES
            (@SocietyId,@InstituteId,@SessionId,@StreamId,@CourseId,
            @LevelId,@SemesterId,@SubjectId,@IsMandatory)";

            cmd.Parameters.AddWithValue("@SocietyId", obj.SocietyId);
            cmd.Parameters.AddWithValue("@InstituteId", obj.InstituteId);
            cmd.Parameters.AddWithValue("@SessionId", obj.SessionId);
            cmd.Parameters.AddWithValue("@StreamId", obj.StreamId);
            cmd.Parameters.AddWithValue("@CourseId", obj.CourseId);
            cmd.Parameters.AddWithValue("@LevelId", obj.LevelId);
            cmd.Parameters.AddWithValue("@SemesterId", obj.SemesterId);
            cmd.Parameters.AddWithValue("@SubjectId", obj.SubjectId);
            cmd.Parameters.AddWithValue("@IsMandatory", obj.IsMandatory);

            dl.ExecuteCMD(cmd);
        }

        public int GetCurrentSession(int instituteId)
        {
            SqlCommand cmd = new SqlCommand();
            cmd.CommandText =
            "SELECT SessionId FROM AcademicSessions WHERE InstituteId=@I AND IsCurrent=1";

            cmd.Parameters.AddWithValue("@I", instituteId);

            DataTable dt = dl.GetDataTable(cmd);

            if (dt.Rows.Count > 0)
                return Convert.ToInt32(dt.Rows[0]["SessionId"]);

            return 0;
        }
        public void CloneLevelSubjects(int instituteId, int oldSessionId, int newSessionId)
        {
            SqlCommand cmd = new SqlCommand(@"

    INSERT INTO LevelSemesterSubjects
    (
        SocietyId,
        InstituteId,
        SessionId,
        StreamId,
        CourseId,
        LevelId,
        SemesterId,
        SubjectId,
        SubjectType
    )

    SELECT
        SocietyId,
        InstituteId,
        @NewSession,
        StreamId,
        CourseId,
        LevelId,
        SemesterId,
        SubjectId,
        SubjectType

    FROM LevelSemesterSubjects

    WHERE InstituteId=@Institute
    AND SessionId=@OldSession

    ");

            cmd.Parameters.AddWithValue("@Institute", instituteId);
            cmd.Parameters.AddWithValue("@OldSession", oldSessionId);
            cmd.Parameters.AddWithValue("@NewSession", newSessionId);

            dl.ExecuteCMD(cmd);
        }

    }
}