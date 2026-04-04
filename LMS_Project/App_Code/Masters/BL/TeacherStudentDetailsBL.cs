using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using LMS_Project.GC;

namespace LMS_Project.BL
{
    public class TeacherStudentDetailsBL
    {
        DataLayer dl = new DataLayer();

        // ── Main method returning full student details ────────────────
        public TeacherStudentGC GetStudentProfile(int userId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT 
                    U.Email, 
                    P.FullName, P.Gender, P.DOB, P.ContactNo, P.Address, 
                    P.City, P.Pincode,
                    P.EmergencyContactName, P.EmergencyContactNo, 
                    P.Skills, P.Hobbies, P.ProfileImage,
                    SAD.RollNumber, 
                    ISNULL(S.StreamName,   '')  AS StreamName, 
                    ISNULL(C.CourseName,   '')  AS CourseName, 
                    ISNULL(Sem.SemesterName,'') AS SemesterName, 
                    ISNULL(Sty.LevelName,  '')  AS LevelName,
                    SAD.StreamId, SAD.CourseId, SAD.LevelId, 
                    SAD.SemesterId, SAD.SectionId, SAD.SessionId,
                    SAD.InstituteId, SAD.SocietyId
                FROM Users U 
                JOIN UserProfile P                   ON U.UserId = P.UserId
                LEFT JOIN StudentAcademicDetails SAD  ON U.UserId = SAD.UserId
                LEFT JOIN Streams S                   ON SAD.StreamId   = S.StreamId
                LEFT JOIN Courses C                   ON SAD.CourseId   = C.CourseId
                LEFT JOIN Semesters Sem               ON SAD.SemesterId = Sem.SemesterId
                LEFT JOIN StudyLevels Sty             ON SAD.LevelId    = Sty.LevelId
                WHERE U.UserId = @U;
            ");
            cmd.Parameters.AddWithValue("@U", userId);

            DataTable dt = dl.GetDataTable(cmd);

            if (dt == null || dt.Rows.Count == 0)
                return null;

            DataRow r = dt.Rows[0];

            return new TeacherStudentGC
            {
                UserId = userId,
                Email = r["Email"].ToString(),
                FullName = r["FullName"].ToString(),
                Gender = r["Gender"].ToString(),
                DOB = r["DOB"] != DBNull.Value
                                ? (DateTime?)Convert.ToDateTime(r["DOB"])
                                : null,
                ContactNo = r["ContactNo"].ToString(),
                Address = r["Address"].ToString(),
                City = r["City"].ToString(),
                Pincode = r["Pincode"] != DBNull.Value
                                ? (int?)Convert.ToInt32(r["Pincode"])
                                : null,
                EmergencyContactName = r["EmergencyContactName"].ToString(),
                EmergencyContactNo = r["EmergencyContactNo"].ToString(),
                Skills = r["Skills"].ToString(),
                Hobbies = r["Hobbies"].ToString(),
                ProfileImage = r["ProfileImage"].ToString(),
                RollNumber = r["RollNumber"].ToString(),
                StreamName = r["StreamName"].ToString(),
                CourseName = r["CourseName"].ToString(),
                SemesterName = r["SemesterName"].ToString(),
                LevelName = r["LevelName"].ToString(),

                StreamId = r["StreamId"] != DBNull.Value ? (int?)Convert.ToInt32(r["StreamId"]) : null,
                CourseId = r["CourseId"] != DBNull.Value ? (int?)Convert.ToInt32(r["CourseId"]) : null,
                LevelId = r["LevelId"] != DBNull.Value ? (int?)Convert.ToInt32(r["LevelId"]) : null,
                SemesterId = r["SemesterId"] != DBNull.Value ? (int?)Convert.ToInt32(r["SemesterId"]) : null,
                SectionId = r["SectionId"] != DBNull.Value ? (int?)Convert.ToInt32(r["SectionId"]) : null,
                SessionId = r["SessionId"] != DBNull.Value ? Convert.ToInt32(r["SessionId"]) : 0,
                InstituteId = r["InstituteId"] != DBNull.Value ? Convert.ToInt32(r["InstituteId"]) : 0,
                SocietyId = r["SocietyId"] != DBNull.Value ? Convert.ToInt32(r["SocietyId"]) : 0,
            };
        }

        // ── Attendance ───────────────────────────────────────────────
        public TeacherStudentGC GetAttendanceSummary(int userId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT 
                    ISNULL(SUM(CASE WHEN Status='Present' THEN 1 ELSE 0 END), 0) AS Present,
                    ISNULL(SUM(CASE WHEN Status='Absent'  THEN 1 ELSE 0 END), 0) AS Absent
                FROM Attendance 
                WHERE UserId = @U;
            ");
            cmd.Parameters.AddWithValue("@U", userId);

            DataTable dt = dl.GetDataTable(cmd);

            if (dt == null || dt.Rows.Count == 0)
                return new TeacherStudentGC { Present = 0, Absent = 0 };

            DataRow r = dt.Rows[0];
            return new TeacherStudentGC
            {
                Present = Convert.ToInt32(r["Present"]),
                Absent = Convert.ToInt32(r["Absent"])
            };
        }

        // ── Subjects + Progress ──────────────────────────────────────
        public List<TeacherStudentSubjectGC> GetSubjects(int userId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT 
                    Sub.SubjectId, 
                    Sub.SubjectName, 
                    ISNULL(TProf.FullName, 'TBD') AS TeacherName,
                    ISNULL(
                        (
                            SELECT COUNT(*) 
                            FROM VideoViews VV 
                            JOIN Videos V    ON VV.VideoId  = V.VideoId 
                            JOIN Chapters Ch ON V.ChapterId = Ch.ChapterId 
                            WHERE VV.UserId      = @U 
                              AND VV.IsCompleted  = 1 
                              AND Ch.SubjectId   = Sub.SubjectId
                        ) * 100 / NULLIF(
                            (
                                SELECT COUNT(*) 
                                FROM Videos V 
                                JOIN Chapters Ch ON V.ChapterId = Ch.ChapterId 
                                WHERE Ch.SubjectId = Sub.SubjectId
                            ), 0
                        ), 0
                    ) AS Progress
                FROM AssignStudentSubject A
                JOIN Subjects Sub           ON A.SubjectId   = Sub.SubjectId
                LEFT JOIN SubjectFaculty SF  ON Sub.SubjectId = SF.SubjectId AND SF.IsActive = 1
                LEFT JOIN UserProfile TProf  ON SF.TeacherId  = TProf.UserId
                WHERE A.UserId = @U;
            ");
            cmd.Parameters.AddWithValue("@U", userId);

            DataTable dt = dl.GetDataTable(cmd);
            var list = new List<TeacherStudentSubjectGC>();

            if (dt == null) return list;

            foreach (DataRow r in dt.Rows)
            {
                list.Add(new TeacherStudentSubjectGC
                {
                    SubjectId = Convert.ToInt32(r["SubjectId"]),
                    SubjectName = r["SubjectName"].ToString(),
                    TeacherName = r["TeacherName"].ToString(),
                    Progress = Convert.ToInt32(r["Progress"])
                });
            }

            return list;
        }

        // ── Recent Activity ──────────────────────────────────────────
        public List<TeacherStudentActivityGC> GetRecentActivity(int userId)
        {
            var list = new List<TeacherStudentActivityGC>();

            SqlCommand cmd = new SqlCommand(@"
                IF OBJECT_ID('UserActivityLog', 'U') IS NOT NULL
                BEGIN
                    SELECT TOP 10 ActivityType, ActionTime 
                    FROM UserActivityLog 
                    WHERE UserId = @U 
                    ORDER BY ActionTime DESC;
                END
                ELSE
                BEGIN
                    SELECT TOP 0 
                        CAST(NULL AS NVARCHAR(100)) AS ActivityType, 
                        CAST(NULL AS DATETIME)      AS ActionTime;
                END
            ");
            cmd.Parameters.AddWithValue("@U", userId);

            DataTable dt = dl.GetDataTable(cmd);

            if (dt == null) return list;

            foreach (DataRow r in dt.Rows)
            {
                list.Add(new TeacherStudentActivityGC
                {
                    ActivityType = r["ActivityType"].ToString(),
                    ActionTime = Convert.ToDateTime(r["ActionTime"])
                });
            }

            return list;
        }

        // ── Overall Progress Stats ───────────────────────────────────
        public TeacherStudentGC GetProgressStats(int userId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT 
                    (SELECT COUNT(*) FROM VideoViews           WHERE UserId    = @U AND IsCompleted = 1) AS Videos,
                    (SELECT COUNT(*) FROM AssignmentSubmissions WHERE StudentId = @U)                    AS Assignments;
            ");
            cmd.Parameters.AddWithValue("@U", userId);

            DataTable dt = dl.GetDataTable(cmd);

            if (dt == null || dt.Rows.Count == 0)
                return new TeacherStudentGC { VideosCompleted = 0, AssignmentsSubmitted = 0 };

            DataRow r = dt.Rows[0];
            return new TeacherStudentGC
            {
                VideosCompleted = Convert.ToInt32(r["Videos"]),
                AssignmentsSubmitted = Convert.ToInt32(r["Assignments"])
            };
        }
    }
}