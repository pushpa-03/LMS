using LearningManagementSystem.GC;
using System;
using System.Data;
using System.Data.SqlClient;

namespace LearningManagementSystem.BL
{
    public class AssignStudentSubjectBL
    {
        DataLayer dl = new DataLayer();

        // GET SUBJECTS BASED ON FILTER
        public DataTable GetSubjects(int instituteId, int sessionId,
            int streamId, int courseId, int levelId, int semesterId)
        {
            SqlCommand cmd = new SqlCommand();

            cmd.CommandText = @"

SELECT
S.SubjectId,
S.SubjectName,
LSS.IsMandatory

FROM LevelSemesterSubjects LSS

JOIN Subjects S
ON LSS.SubjectId = S.SubjectId

WHERE
S.IsActive = 1
AND LSS.InstituteId = @Institute
AND LSS.SessionId = @Session
AND LSS.StreamId = @Stream
AND LSS.LevelId = @Level

AND (@Course = 0 OR LSS.CourseId = @Course)
AND (@Semester = 0 OR LSS.SemesterId = @Semester)

ORDER BY S.SubjectName";

            cmd.Parameters.AddWithValue("@Institute", instituteId);
            cmd.Parameters.AddWithValue("@Session", sessionId);
            cmd.Parameters.AddWithValue("@Stream", streamId);
            cmd.Parameters.AddWithValue("@Course", courseId);
            cmd.Parameters.AddWithValue("@Level", levelId);
            cmd.Parameters.AddWithValue("@Semester", semesterId);

            return dl.GetDataTable(cmd);
        }

        // GET STUDENTS
        public DataTable GetStudents(int instituteId, int sessionId,
            int streamId, int courseId, int levelId, int semesterId)
        {
            SqlCommand cmd = new SqlCommand();

            cmd.CommandText = @"

SELECT
U.UserId,
P.FullName,
SAD.RollNumber

FROM StudentAcademicDetails SAD

JOIN Users U ON SAD.UserId=U.UserId
JOIN UserProfile P ON U.UserId=P.UserId

WHERE
SAD.InstituteId=@Institute
AND SAD.SessionId=@Session
AND SAD.StreamId=@Stream
AND SAD.LevelId=@Level

AND (@Course=0 OR SAD.CourseId=@Course)
AND (@Semester=0 OR SAD.SemesterId=@Semester)

ORDER BY P.FullName";

            cmd.Parameters.AddWithValue("@Institute", instituteId);
            cmd.Parameters.AddWithValue("@Session", sessionId);
            cmd.Parameters.AddWithValue("@Stream", streamId);
            cmd.Parameters.AddWithValue("@Course", courseId);
            cmd.Parameters.AddWithValue("@Level", levelId);
            cmd.Parameters.AddWithValue("@Semester", semesterId);

            return dl.GetDataTable(cmd);
        }

        // ASSIGN SUBJECTS
        public void AssignSubjects(DataTable students, DataTable subjects,
            int societyId, int instituteId, int sessionId)
        {
            foreach (DataRow st in students.Rows)
            {
                foreach (DataRow sb in subjects.Rows)
                {
                    SqlCommand cmd = new SqlCommand();

                    cmd.CommandText = @"

IF NOT EXISTS(
SELECT 1 FROM AssignStudentSubject
WHERE UserId=@UserId
AND SubjectId=@SubjectId
AND SessionId=@SessionId
)

INSERT INTO AssignStudentSubject
(UserId,SocietyId,InstituteId,SubjectId,SessionId)

VALUES
(@UserId,@SocietyId,@InstituteId,@SubjectId,@SessionId)";

                    cmd.Parameters.AddWithValue("@UserId", st["UserId"]);
                    cmd.Parameters.AddWithValue("@SocietyId", societyId);
                    cmd.Parameters.AddWithValue("@InstituteId", instituteId);
                    cmd.Parameters.AddWithValue("@SubjectId", sb["SubjectId"]);
                    cmd.Parameters.AddWithValue("@SessionId", sessionId);

                    dl.ExecuteCMD(cmd);
                }
            }
        }

        // GRID
        public DataTable GetAssigned(int instituteId, int sessionId)
        {
            SqlCommand cmd = new SqlCommand();

            cmd.CommandText = @"

SELECT
A.Id,
P.FullName,
S.SubjectName,
AC.SessionName

FROM AssignStudentSubject A

JOIN Users U ON A.UserId=U.UserId
JOIN UserProfile P ON U.UserId=P.UserId
JOIN Subjects S ON A.SubjectId=S.SubjectId
JOIN AcademicSessions AC ON A.SessionId=AC.SessionId

WHERE
A.InstituteId=@Institute
AND A.SessionId=@Session

ORDER BY P.FullName,S.SubjectName";

            cmd.Parameters.AddWithValue("@Institute", instituteId);
            cmd.Parameters.AddWithValue("@Session", sessionId);

            return dl.GetDataTable(cmd);
        }

        public void Delete(int id)
        {
            SqlCommand cmd = new SqlCommand(
            "DELETE FROM AssignStudentSubject WHERE Id=@Id");

            cmd.Parameters.AddWithValue("@Id", id);

            dl.ExecuteCMD(cmd);
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
    }
}