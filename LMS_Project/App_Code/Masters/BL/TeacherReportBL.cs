using LMS_Project.GC;
using System;
using System.Data;
using System.Data.SqlClient;

namespace LMS_Project.BL
{
    public class TeacherReportBL
    {
        DataLayer objDL = new DataLayer();

        // ===============================
        // 1️⃣ ALL TEACHERS BASIC REPORT
        // ===============================
        public DataTable GetAllTeachers(int instituteId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT u.UserId,
                       u.Username,
                       u.Email,
                       u.IsActive,
                       u.CreatedOn,
                       u.LastLogin,
                       up.FullName,
                       s.StreamName
                FROM Users u
                INNER JOIN UserProfile up ON u.UserId = up.UserId
                INNER JOIN TeacherDetails td ON u.UserId = td.UserId
                LEFT JOIN Streams s ON td.StreamId = s.StreamId
                WHERE u.RoleId = (SELECT RoleId FROM Roles WHERE RoleName='Teacher')
                AND u.InstituteId = @InstituteId");

            cmd.Parameters.AddWithValue("@InstituteId", instituteId);
            return objDL.GetDataTable(cmd);
        }

        // ===============================
        // 2️⃣ STREAM WISE FILTER
        // ===============================
        public DataTable GetTeachersByStream(int instituteId, int streamId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT u.UserId, up.FullName, s.StreamName
                FROM Users u
                INNER JOIN TeacherDetails td ON u.UserId = td.UserId
                INNER JOIN Streams s ON td.StreamId = s.StreamId
                INNER JOIN UserProfile up ON up.UserId = u.UserId
                WHERE u.RoleId = (SELECT RoleId FROM Roles WHERE RoleName='Teacher')
                AND u.InstituteId=@InstituteId
                AND td.StreamId=@StreamId");

            cmd.Parameters.AddWithValue("@InstituteId", instituteId);
            cmd.Parameters.AddWithValue("@StreamId", streamId);

            return objDL.GetDataTable(cmd);
        }

        // ===============================
        // 3️⃣ TEACHERS WITH MOST STUDENTS
        // ===============================
        public DataTable GetTeachersByStudentCount(int instituteId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT u.UserId,
                       up.FullName,
                       COUNT(sc.UserId) AS TotalStudents
                FROM TeacherCourses tc
                INNER JOIN StudentCourses sc ON tc.SubjectId = sc.SubjectId
                INNER JOIN Users u ON tc.UserId = u.UserId
                INNER JOIN UserProfile up ON up.UserId = u.UserId
                WHERE u.RoleId = (SELECT RoleId FROM Roles WHERE RoleName='Teacher')
                AND u.InstituteId=@InstituteId
                GROUP BY u.UserId, up.FullName
                ORDER BY TotalStudents DESC");

            cmd.Parameters.AddWithValue("@InstituteId", instituteId);
            return objDL.GetDataTable(cmd);
        }

        // ===============================
        // 4️⃣ TEACHERS WITH ZERO STUDENTS
        // ===============================
        public DataTable GetTeachersWithZeroStudents(int instituteId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT u.UserId, up.FullName
                FROM Users u
                INNER JOIN UserProfile up ON up.UserId = u.UserId
                WHERE u.RoleId = (SELECT RoleId FROM Roles WHERE RoleName='Teacher')
                AND u.InstituteId=@InstituteId
                AND u.UserId NOT IN
                (
                    SELECT DISTINCT tc.UserId
                    FROM TeacherCourses tc
                    INNER JOIN StudentCourses sc 
                        ON tc.SubjectId=sc.SubjectId
                )");

            cmd.Parameters.AddWithValue("@InstituteId", instituteId);
            return objDL.GetDataTable(cmd);
        }

        // ===============================
        // 5️⃣ NEW TEACHERS THIS MONTH
        // ===============================
        public DataTable GetNewTeachersThisMonth(int instituteId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT u.UserId, up.FullName, u.CreatedOn
                FROM Users u
                INNER JOIN UserProfile up ON up.UserId = u.UserId
                WHERE u.RoleId = (SELECT RoleId FROM Roles WHERE RoleName='Teacher')
                AND u.InstituteId=@InstituteId
                AND MONTH(u.CreatedOn)=MONTH(GETDATE())
                AND YEAR(u.CreatedOn)=YEAR(GETDATE())");

            cmd.Parameters.AddWithValue("@InstituteId", instituteId);
            return objDL.GetDataTable(cmd);
        }

        // ===============================
        // 6️⃣ TEACHERS WITHOUT LOGIN
        // ===============================
        public DataTable GetTeachersWithoutLogin(int instituteId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT u.UserId, up.FullName
                FROM Users u
                INNER JOIN UserProfile up ON up.UserId=u.UserId
                WHERE u.RoleId = (SELECT RoleId FROM Roles WHERE RoleName='Teacher')
                AND u.InstituteId=@InstituteId
                AND u.LastLogin IS NULL");

            cmd.Parameters.AddWithValue("@InstituteId", instituteId);
            return objDL.GetDataTable(cmd);
        }

        // ===============================
        // 7️⃣ FILTERED REPORT
        // ===============================
        public DataTable GetFilteredTeachers(int instituteId,
     int streamId,
     int courseId,
     int subjectId,
     int academicYearId,
     int semesterId)
        {
            SqlCommand cmd = new SqlCommand(@"
        SELECT DISTINCT u.UserId,
               up.FullName,
               u.Email,
               s.StreamName,
               c.CourseName,
               sub.SubjectName,
               ay.SessionName AS AcademicYear,
               sem.SemesterName
        FROM Users u
        INNER JOIN UserProfile up ON u.UserId = up.UserId
        INNER JOIN TeacherCourses tc ON u.UserId = tc.UserId
        INNER JOIN Subjects sub ON tc.SubjectId = sub.SubjectId

        LEFT JOIN Courses c ON sub.CourseId = c.CourseId
        LEFT JOIN Streams s ON sub.StreamId = s.StreamId
        LEFT JOIN AcademicSessions ay ON tc.SessionId = ay.SessionId
        LEFT JOIN Semesters sem ON sub.SemesterId = sem.SemesterId

        WHERE u.RoleId = (SELECT RoleId FROM Roles WHERE RoleName='Teacher')
        AND u.InstituteId=@InstituteId

        AND (@StreamId=0 OR sub.StreamId=@StreamId)
        AND (@CourseId=0 OR sub.CourseId=@CourseId)
        AND (@SubjectId=0 OR sub.SubjectId=@SubjectId)
        AND (@AcademicYearId=0 OR tc.SessionId=@AcademicYearId)
        AND (@SemesterId=0 OR sub.SemesterId=@SemesterId)
    ");

            cmd.Parameters.AddWithValue("@InstituteId", instituteId);
            cmd.Parameters.AddWithValue("@StreamId", streamId);
            cmd.Parameters.AddWithValue("@CourseId", courseId);
            cmd.Parameters.AddWithValue("@SubjectId", subjectId);
            cmd.Parameters.AddWithValue("@AcademicYearId", academicYearId);
            cmd.Parameters.AddWithValue("@SemesterId", semesterId);

            return objDL.GetDataTable(cmd);
        }

        // ===============================
        // DASHBOARD COUNTS (NO ExecuteScalar)
        // ===============================

        public int GetTotalTeachers(int instituteId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT COUNT(*) AS TotalCount
                FROM Users
                WHERE RoleId = (SELECT RoleId FROM Roles WHERE RoleName='Teacher')
                AND InstituteId=@InstituteId");

            cmd.Parameters.AddWithValue("@InstituteId", instituteId);

            DataTable dt = objDL.GetDataTable(cmd);
            return dt.Rows.Count > 0 ? Convert.ToInt32(dt.Rows[0][0]) : 0;
        }

        public int GetActiveTeachersThisMonth(int instituteId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT COUNT(*) AS TotalCount
                FROM Users
                WHERE RoleId = (SELECT RoleId FROM Roles WHERE RoleName='Teacher')
                AND InstituteId=@InstituteId
                AND MONTH(LastLogin)=MONTH(GETDATE())
                AND YEAR(LastLogin)=YEAR(GETDATE())");

            cmd.Parameters.AddWithValue("@InstituteId", instituteId);

            DataTable dt = objDL.GetDataTable(cmd);
            return dt.Rows.Count > 0 ? Convert.ToInt32(dt.Rows[0][0]) : 0;
        }

        public int GetNewTeachersThisMonthCount(int instituteId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT COUNT(*) AS TotalCount
                FROM Users
                WHERE RoleId = (SELECT RoleId FROM Roles WHERE RoleName='Teacher')
                AND InstituteId=@InstituteId
                AND MONTH(CreatedOn)=MONTH(GETDATE())
                AND YEAR(CreatedOn)=YEAR(GETDATE())");

            cmd.Parameters.AddWithValue("@InstituteId", instituteId);

            DataTable dt = objDL.GetDataTable(cmd);
            return dt.Rows.Count > 0 ? Convert.ToInt32(dt.Rows[0][0]) : 0;
        }

        public int GetAverageStudentLoad(int instituteId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT ISNULL(AVG(StudentCount),0)
                FROM (
                    SELECT COUNT(sc.UserId) AS StudentCount
                    FROM TeacherCourses tc
                    LEFT JOIN StudentCourses sc ON tc.SubjectId=sc.SubjectId
                    GROUP BY tc.UserId
                ) AS T");

            DataTable dt = objDL.GetDataTable(cmd);
            return dt.Rows.Count > 0 ? Convert.ToInt32(dt.Rows[0][0]) : 0;
        }

        public DataTable GetInactiveTeachers(int instituteId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT u.UserId, up.FullName, u.Email
                FROM Users u
                INNER JOIN UserProfile up ON up.UserId=u.UserId
                WHERE u.RoleId = (SELECT RoleId FROM Roles WHERE RoleName='Teacher')
                AND u.InstituteId=@InstituteId
                AND u.LastLogin IS NULL");

            cmd.Parameters.AddWithValue("@InstituteId", instituteId);
            return objDL.GetDataTable(cmd);
        }
        // ===============================
        // DROPDOWN LOADERS
        // ===============================

        public DataTable GetStreams(int instituteId)
        {
            SqlCommand cmd = new SqlCommand(@"
        SELECT StreamId, StreamName
        FROM Streams
        WHERE InstituteId=@InstituteId
        AND IsActive=1");

            cmd.Parameters.AddWithValue("@InstituteId", instituteId);
            return objDL.GetDataTable(cmd);
        }

        public DataTable GetCourses(int instituteId)
        {
            SqlCommand cmd = new SqlCommand(@"
        SELECT CourseId, CourseName
        FROM Courses
        WHERE InstituteId=@InstituteId
        AND IsActive=1");

            cmd.Parameters.AddWithValue("@InstituteId", instituteId);
            return objDL.GetDataTable(cmd);
        }

        public DataTable GetSubjects(int instituteId)
        {
            SqlCommand cmd = new SqlCommand(@"
        SELECT SubjectId, SubjectName
        FROM Subjects
        WHERE InstituteId=@InstituteId
        AND IsActive=1");

            cmd.Parameters.AddWithValue("@InstituteId", instituteId);
            return objDL.GetDataTable(cmd);
        }

        public DataTable GetAcademicYears(int instituteId)
        {
            SqlCommand cmd = new SqlCommand(@"
        SELECT SessionId, SessionName
        FROM AcademicSessions
        WHERE InstituteId=@InstituteId
        AND IsActive=1");

            cmd.Parameters.AddWithValue("@InstituteId", instituteId);
            return objDL.GetDataTable(cmd);
        }

        public DataTable GetSemesters(int instituteId)
        {
            SqlCommand cmd = new SqlCommand(@"
        SELECT SemesterId, SemesterName
        FROM Semesters
        WHERE InstituteId=@InstituteId");

            cmd.Parameters.AddWithValue("@InstituteId", instituteId);
            return objDL.GetDataTable(cmd);
        }
    }
}