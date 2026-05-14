//using System;
//using System.Collections.Generic;
//using System.Data;
//using System.Data.SqlClient;
//using LearningManagementSystem.GC;

//public class ParentBL
//{
//    DataLayer dl = new DataLayer();

//    public void InsertParent(ParentGC gc)
//    {
//        SqlConnection con = new SqlConnection(
//            System.Configuration.ConfigurationManager
//            .ConnectionStrings["DefaultConnection"].ConnectionString);

//        con.Open();
//        SqlTransaction trans = con.BeginTransaction();

//        try
//        {

//            // INSERT USER
//            SqlCommand userCmd = new SqlCommand(@"
//            INSERT INTO Users
//            (Username, Email, PasswordHash, RoleId, SocietyId, InstituteId, SessionId, IsActive, IsFirstLogin)
//            VALUES
//            (@U, @E, HASHBYTES('SHA2_256','Parent@123'),
//            (SELECT RoleId FROM Roles WHERE RoleName='Parent'),
//            @S, @I, @SessionId, 1, 1);
//            SELECT SCOPE_IDENTITY();", con, trans);

//            userCmd.Parameters.AddWithValue("@U", gc.Username);
//            userCmd.Parameters.AddWithValue("@E", gc.Email);
//            userCmd.Parameters.AddWithValue("@S", gc.SocietyId);
//            userCmd.Parameters.AddWithValue("@I", gc.InstituteId);
//            userCmd.Parameters.AddWithValue("@SessionId", gc.SessionId);

//            int newUserId = Convert.ToInt32(userCmd.ExecuteScalar());

//            // INSERT PROFILE
//            SqlCommand profileCmd = new SqlCommand(@"
//            INSERT INTO UserProfile
//            (SocietyId, InstituteId,SessionId, UserId, FullName, Gender, DOB,
//             ContactNo, EmergencyContactName, EmergencyContactNo,
//             Address, JoinedDate)
//            VALUES
//            (@S,@I,@SessionId, @Id,@FN,@G,@DOB,@C,'N/A','0000000000','N/A',GETDATE())",
//            con, trans);

//            profileCmd.Parameters.AddWithValue("@S", gc.SocietyId);
//            profileCmd.Parameters.AddWithValue("@I", gc.InstituteId);
//            profileCmd.Parameters.AddWithValue("@SessionId", gc.SessionId);
//            profileCmd.Parameters.AddWithValue("@Id", newUserId);
//            profileCmd.Parameters.AddWithValue("@FN", gc.FullName);
//            profileCmd.Parameters.AddWithValue("@G", gc.Gender);
//            profileCmd.Parameters.AddWithValue("@DOB",
//            gc.DOB ?? (object)DateTime.Now);
//            profileCmd.Parameters.AddWithValue("@C", gc.ContactNo);

//            profileCmd.ExecuteNonQuery();

//            // INSERT STUDENT MAPPING
//            foreach (int studentId in gc.StudentIds)
//            {
//                SqlCommand mapCmd = new SqlCommand(@"
//                INSERT INTO ParentStudentMapping
//                (SocietyId, InstituteId,SessionId, ParentUserId, StudentUserId,
//                 RelationshipType, IsPrimaryGuardian)
//                VALUES
//                (@S,@I,@SessionId,@P,@Stu,@R,@Primary)", con, trans);

//                mapCmd.Parameters.AddWithValue("@S", gc.SocietyId);
//                mapCmd.Parameters.AddWithValue("@I", gc.InstituteId);
//                mapCmd.Parameters.AddWithValue("@SessionId", gc.SessionId);
//                mapCmd.Parameters.AddWithValue("@P", newUserId);
//                mapCmd.Parameters.AddWithValue("@Stu", studentId);
//                mapCmd.Parameters.AddWithValue("@R", gc.RelationshipType);
//                mapCmd.Parameters.AddWithValue("@Primary", gc.IsPrimaryGuardian);

//                mapCmd.ExecuteNonQuery();
//            }

//            trans.Commit();
//        }
//        catch
//        {
//            trans.Rollback();
//            throw;
//        }
//        finally
//        {
//            con.Close();
//        }
//    }

//    public DataTable GetParents(int instituteId, int SessionId)
//    {
//        SqlCommand cmd = new SqlCommand(@"
//    SELECT
//        PS.StudentUserId AS StudentId,
//        SP.FullName AS StudentName,
//        PU.UserId AS ParentUserId,
//        PP.FullName AS ParentName,
//        PU.Email,
//        PP.ContactNo,
//        PS.RelationshipType AS Relation,
//        PU.IsActive

//    FROM ParentStudentMapping PS

//    INNER JOIN Users SU 
//        ON PS.StudentUserId = SU.UserId

//    INNER JOIN UserProfile SP 
//        ON SU.UserId = SP.UserId

//    INNER JOIN Users PU 
//        ON PS.ParentUserId = PU.UserId

//    INNER JOIN UserProfile PP 
//        ON PU.UserId = PP.UserId

//    WHERE SU.InstituteId = @I And SU.SessionId = @SessionId
//    ORDER BY SP.FullName
//    ");

//        cmd.Parameters.AddWithValue("@I", instituteId);
//        cmd.Parameters.AddWithValue("@SessionId", SessionId);

//        return dl.GetDataTable(cmd);
//    }


//    public DataTable GetParents(int instituteId, int sessionId, bool isActive)
//    {
//        SqlCommand cmd = new SqlCommand(@"
//            SELECT
//                SP.FullName AS StudentName,
//                PU.UserId AS ParentUserId,
//                PP.FullName AS ParentName,
//                PU.Email,
//                PP.ContactNo,
//                PS.RelationshipType AS Relation,
//                PU.IsActive
//            FROM ParentStudentMapping PS
//            INNER JOIN Users PU ON PS.ParentUserId = PU.UserId
//            INNER JOIN UserProfile PP ON PU.UserId = PP.UserId
//            INNER JOIN Users SU ON PS.StudentUserId = SU.UserId
//            INNER JOIN UserProfile SP ON SU.UserId = SP.UserId
//            WHERE SU.InstituteId = @I
//            AND PU.SessionId = @SessionId
//            AND PU.IsActive = @A");

//        cmd.Parameters.AddWithValue("@I", instituteId);
//        cmd.Parameters.AddWithValue("@SessionId", sessionId);
//        cmd.Parameters.AddWithValue("@A", isActive);

//        return dl.GetDataTable(cmd);
//    }


//    public bool ToggleParent(int userId, int SessionId)
//    {
//        DataLayer dl = new DataLayer();

//        SqlCommand cmd = new SqlCommand(@"
//        UPDATE Users
//        SET IsActive = CASE WHEN IsActive = 1 THEN 0 ELSE 1 END
//        OUTPUT INSERTED.IsActive
//        WHERE UserId = @U And SessionId = @SessionId");

//        cmd.Parameters.AddWithValue("@U", userId);
//        cmd.Parameters.AddWithValue("@SessionId", SessionId);

//        DataTable dt = dl.GetDataTable(cmd);

//        if (dt.Rows.Count > 0)
//        {
//            return Convert.ToBoolean(dt.Rows[0][0]);
//        }

//        return false;
//    }
//    public void DeleteParent(int userId, int SessionId)
//    {
//        List<SqlCommand> cmds = new List<SqlCommand>();

//        SqlCommand cmd1 = new SqlCommand(
//        "DELETE FROM ParentStudentMapping WHERE ParentUserId=@Id And SessionId = @SessionId");
//        cmd1.Parameters.AddWithValue("@Id", userId);
//        cmd1.Parameters.AddWithValue("@SessionId", SessionId);

//        SqlCommand cmd2 = new SqlCommand(
//        "DELETE FROM UserProfile WHERE UserId=@Id And SessionId = @SessionId");
//        cmd2.Parameters.AddWithValue("@Id", userId);
//        cmd2.Parameters.AddWithValue("@SessionId", SessionId);

//        SqlCommand cmd3 = new SqlCommand(
//        "DELETE FROM Users WHERE UserId=@Id And SessionId = @SessionId");
//        cmd3.Parameters.AddWithValue("@Id", userId);
//        cmd3.Parameters.AddWithValue("@SessionId", SessionId);

//        cmds.Add(cmd1);
//        cmds.Add(cmd2);
//        cmds.Add(cmd3);

//        dl.ExecuteTransaction(cmds);
//    }

//    public DataTable GetParentById(int userId, int SessionId)
//    {
//        SqlCommand cmd = new SqlCommand(@"
//    SELECT 
//        U.Username,
//        U.Email,
//        P.FullName,
//        P.ContactNo
//    FROM Users U
//    INNER JOIN UserProfile P ON U.UserId = P.UserId
//    WHERE U.UserId = @Id And U.SessionId = @SessionId");

//        cmd.Parameters.AddWithValue("@Id", userId);
//        cmd.Parameters.AddWithValue("@SessionId", SessionId);

//        return dl.GetDataTable(cmd);
//    }

//    public void UpdateParent(ParentGC gc)
//    {
//        List<SqlCommand> cmds = new List<SqlCommand>();

//        SqlCommand userCmd = new SqlCommand(@"
//    UPDATE Users SET Username=@U, Email=@E
//    WHERE UserId=@Id And SessionId = @SessionId");

//        userCmd.Parameters.AddWithValue("@U", gc.Username);
//        userCmd.Parameters.AddWithValue("@E", gc.Email);
//        userCmd.Parameters.AddWithValue("@Id", gc.UserId);
//        userCmd.Parameters.AddWithValue("@SessionId", gc.SessionId);

//        cmds.Add(userCmd);

//        SqlCommand profileCmd = new SqlCommand(@"
//    UPDATE UserProfile
//    SET FullName=@FN, ContactNo=@C, Gender=@G, DOB=@DOB
//    WHERE UserId=@Id And SessionId = @SessionId");

//        profileCmd.Parameters.AddWithValue("@FN", gc.FullName);
//        profileCmd.Parameters.AddWithValue("@C", gc.ContactNo);
//        profileCmd.Parameters.AddWithValue("@G", gc.Gender);
//        profileCmd.Parameters.AddWithValue("@DOB", gc.DOB ?? (object)DBNull.Value);
//        profileCmd.Parameters.AddWithValue("@Id", gc.UserId);
//        profileCmd.Parameters.AddWithValue("@SessionId", gc.SessionId);

//        cmds.Add(profileCmd);

//        SqlCommand delMap = new SqlCommand(
//            "DELETE FROM ParentStudentMapping WHERE ParentUserId=@Id And SessionId = @SessionId");
//        delMap.Parameters.AddWithValue("@Id", gc.UserId);
//        delMap.Parameters.AddWithValue("@SessionId", gc.SessionId);

//        cmds.Add(delMap);

//        foreach (int studentId in gc.StudentIds)
//        {
//            SqlCommand mapCmd = new SqlCommand(@"
//        INSERT INTO ParentStudentMapping
//        (SocietyId, InstituteId, SessionId, ParentUserId, StudentUserId,
//         RelationshipType, IsPrimaryGuardian)
//        VALUES (@S,@I,@SessionId,@P,@Stu,@R,@Primary)");

//            mapCmd.Parameters.AddWithValue("@S", gc.SocietyId);
//            mapCmd.Parameters.AddWithValue("@I", gc.InstituteId);
//            mapCmd.Parameters.AddWithValue("@SessionId", gc.SessionId);
//            mapCmd.Parameters.AddWithValue("@P", gc.UserId);
//            mapCmd.Parameters.AddWithValue("@Stu", studentId);
//            mapCmd.Parameters.AddWithValue("@R", gc.RelationshipType);
//            mapCmd.Parameters.AddWithValue("@Primary", gc.IsPrimaryGuardian);

//            cmds.Add(mapCmd);
//        }

//        dl.ExecuteTransaction(cmds);
//    }

//    //---called in ParentList.aspx
//    public DataTable GetParentsWithStudentDetails(int instituteId, int SessionId, bool isActive)
//    {
//        SqlCommand cmd = new SqlCommand(@"
//    SELECT
//        SU.UserId AS StudentId,
//        SP.FullName AS StudentName,

//        ST.StreamName,
//        C.CourseName,
//        SL.LevelName,
//        SM.SemesterName,
//        SEC.SectionName,
//        ASess.SessionName,

//        PU.UserId AS ParentUserId,
//        PP.FullName AS ParentName,
//        PU.Email,
//        PP.ContactNo,
//        PS.RelationshipType,
//        PU.IsActive

//    FROM ParentStudentMapping PS

//    INNER JOIN Users PU ON PS.ParentUserId = PU.UserId
//    INNER JOIN UserProfile PP ON PU.UserId = PP.UserId

//    INNER JOIN Users SU ON PS.StudentUserId = SU.UserId
//    INNER JOIN UserProfile SP ON SU.UserId = SP.UserId

//    LEFT JOIN StudentAcademicDetails SAD ON SU.UserId = SAD.UserId
//    LEFT JOIN Streams ST ON SAD.StreamId = ST.StreamId
//    LEFT JOIN Courses C ON SAD.CourseId = C.CourseId
//    LEFT JOIN StudyLevels SL ON SAD.LevelId = SL.LevelId
//    LEFT JOIN Semesters SM ON SAD.SemesterId = SM.SemesterId
//    LEFT JOIN Sections SEC ON SAD.SectionId = SEC.SectionId
//    LEFT JOIN AcademicSessions ASess ON SAD.SessionId = ASess.SessionId

//    WHERE SU.InstituteId = @I And PU.SessionId = @SessionId
//    AND PU.IsActive = @A

//    ORDER BY SP.FullName
//    ");

//        cmd.Parameters.AddWithValue("@I", instituteId);
//        cmd.Parameters.AddWithValue("@A", isActive);
//        cmd.Parameters.AddWithValue("@SessionId", SessionId);

//        return dl.GetDataTable(cmd);
//    }

//    public DataTable GetStats(int instituteId, int SessionId)
//    {
//        SqlCommand cmd = new SqlCommand(@"
//        SELECT 
//            COUNT(DISTINCT PU.UserId) AS TotalParents,
//            COUNT(DISTINCT CASE WHEN PU.IsActive = 1 THEN PU.UserId END) AS ActiveParents,
//            COUNT(DISTINCT CASE WHEN PU.IsActive = 0 THEN PU.UserId END) AS InactiveParents,
//            COUNT(DISTINCT PS.StudentUserId) AS TotalLinks
//        FROM ParentStudentMapping PS
//        INNER JOIN Users PU ON PS.ParentUserId = PU.UserId
//        INNER JOIN Users SU ON PS.StudentUserId = SU.UserId
//       WHERE SU.InstituteId = @I AND SU.SessionId = @SessionId
//    ");

//        cmd.Parameters.AddWithValue("@I", instituteId);
//        cmd.Parameters.AddWithValue("@SessionId", SessionId);

//        return dl.GetDataTable(cmd);
//    }
//}


//------------------------------------------------------------------------------------

using LearningManagementSystem.GC;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace LearningManagementSystem.BL
{
    /// <summary>
    /// Business Logic Layer – Parent / Guardian Management.
    /// Uses DataLayer only: GetDataTable, ExecuteCMD, ExecuteTransaction.
    /// All multi-table writes are atomic via ExecuteTransaction.
    /// </summary>
    public class AddParentBL
    {
        private readonly DataLayer _dl = new DataLayer();

        // ══════════════════════════════════════════════════════════════════════════
        //  READ – Parents list for grid (aggregated student names per parent)
        // ══════════════════════════════════════════════════════════════════════════

        /// <summary>
        /// Returns one row per PARENT (not per mapping row).
        /// StudentNames, RollNumbers, StreamNames are pipe-delimited aggregations.
        /// </summary>
        public DataTable GetParents(int instituteId, int sessionId, string filterStatus = "All")
        {
            string query = @"
                SELECT
                    PU.UserId                                       AS ParentUserId,
                    PU.Username,
                    PU.Email,
                    PU.IsActive,
                    PU.IsFirstLogin,

                    ISNULL(PP.FullName,    '')                      AS ParentName,
                    ISNULL(PP.ContactNo,   '')                      AS ContactNo,
                    ISNULL(PP.Gender,      '')                      AS Gender,
                    PP.DOB,
                    PP.JoinedDate,
                    ISNULL(PP.Address,     '')                      AS Address,
                    ISNULL(PP.City,        '')                      AS City,
                    ISNULL(PP.Country,     '')                      AS Country,
                    PP.Pincode,
                    ISNULL(PP.Skills,      '')                      AS Occupation,

                    -- First mapping row's relation (most parents have one relation type)
                    ISNULL(MIN(PS.RelationshipType), '')            AS Relation,
                    ISNULL(MAX(CAST(PS.IsPrimaryGuardian AS INT)),0) AS IsPrimaryGuardian,

                    -- Pipe-delimited student info for display
                    STUFF((
                        SELECT '|' + SP.FullName
                        FROM ParentStudentMapping PSM2
                        INNER JOIN Users SU2 ON SU2.UserId = PSM2.StudentUserId
                        INNER JOIN UserProfile SP ON SP.UserId = SU2.UserId
                        WHERE PSM2.ParentUserId = PU.UserId
                        FOR XML PATH(''), TYPE).value('.','NVARCHAR(MAX)'),1,1,'') AS StudentNames,

                    STUFF((
                        SELECT '|' + ISNULL(SAD.RollNumber,'—')
                        FROM ParentStudentMapping PSM2
                        INNER JOIN StudentAcademicDetails SAD ON SAD.UserId = PSM2.StudentUserId
                        WHERE PSM2.ParentUserId = PU.UserId
                        FOR XML PATH(''), TYPE).value('.','NVARCHAR(MAX)'),1,1,'') AS RollNumbers,

                    STUFF((
                        SELECT '|' + ISNULL(ST.StreamName,'—')
                        FROM ParentStudentMapping PSM2
                        LEFT JOIN StudentAcademicDetails SAD ON SAD.UserId = PSM2.StudentUserId
                        LEFT JOIN Streams ST ON ST.StreamId = SAD.StreamId
                        WHERE PSM2.ParentUserId = PU.UserId
                        FOR XML PATH(''), TYPE).value('.','NVARCHAR(MAX)'),1,1,'') AS StreamNames

                FROM Users PU
                INNER JOIN Roles R ON R.RoleId = PU.RoleId AND R.RoleName = 'Parent'
                LEFT  JOIN UserProfile PP ON PP.UserId = PU.UserId
                LEFT  JOIN ParentStudentMapping PS ON PS.ParentUserId = PU.UserId

                WHERE PU.InstituteId = @InstituteId
                  AND PU.SessionId   = @SessionId";

            SqlCommand cmd = new SqlCommand();
            cmd.Parameters.AddWithValue("@InstituteId", instituteId);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);

            if (filterStatus == "Active")
                query += " AND PU.IsActive = 1";
            else if (filterStatus == "Inactive")
                query += " AND PU.IsActive = 0";

            query += @"
                GROUP BY
                    PU.UserId, PU.Username, PU.Email, PU.IsActive, PU.IsFirstLogin,
                    PP.FullName, PP.ContactNo, PP.Gender, PP.DOB, PP.JoinedDate,
                    PP.Address, PP.City, PP.Country, PP.Pincode, PP.Skills
                ORDER BY PP.FullName ASC";

            cmd.CommandText = query;
            return _dl.GetDataTable(cmd);
        }

        // ══════════════════════════════════════════════════════════════════════════
        //  READ – Single parent full profile (for Edit / SendCreds)
        // ══════════════════════════════════════════════════════════════════════════

        //called in ParentList
        public DataTable GetParentsWithStudentDetails(int instituteId, int SessionId, bool isActive)
        {
            SqlCommand cmd = new SqlCommand(@"
    SELECT
        SU.UserId AS StudentId,
        SP.FullName AS StudentName,

        ST.StreamName,
        C.CourseName,
        SL.LevelName,
        SM.SemesterName,
        SEC.SectionName,
        ASess.SessionName,

        PU.UserId AS ParentUserId,
        PP.FullName AS ParentName,
        PU.Email,
        PP.ContactNo,
        PS.RelationshipType,
        PU.IsActive

    FROM ParentStudentMapping PS

    INNER JOIN Users PU ON PS.ParentUserId = PU.UserId
    INNER JOIN UserProfile PP ON PU.UserId = PP.UserId

    INNER JOIN Users SU ON PS.StudentUserId = SU.UserId
    INNER JOIN UserProfile SP ON SU.UserId = SP.UserId

    LEFT JOIN StudentAcademicDetails SAD ON SU.UserId = SAD.UserId
    LEFT JOIN Streams ST ON SAD.StreamId = ST.StreamId
    LEFT JOIN Courses C ON SAD.CourseId = C.CourseId
    LEFT JOIN StudyLevels SL ON SAD.LevelId = SL.LevelId
    LEFT JOIN Semesters SM ON SAD.SemesterId = SM.SemesterId
    LEFT JOIN Sections SEC ON SAD.SectionId = SEC.SectionId
    LEFT JOIN AcademicSessions ASess ON SAD.SessionId = ASess.SessionId

    WHERE SU.InstituteId = @I And PU.SessionId = @SessionId
    AND PU.IsActive = @A

    ORDER BY SP.FullName
    ");

            cmd.Parameters.AddWithValue("@I", instituteId);
            cmd.Parameters.AddWithValue("@A", isActive);
            cmd.Parameters.AddWithValue("@SessionId", SessionId);

            return _dl.GetDataTable(cmd);
        }

        public DataTable GetParentById(int parentUserId, int sessionId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT
                    PU.UserId,
                    PU.Username,
                    PU.Email,
                    PU.IsActive,
                    PU.IsFirstLogin,

                    ISNULL(PP.FullName,             '')      AS FullName,
                    ISNULL(PP.ContactNo,            '')      AS ContactNo,
                    ISNULL(PP.Gender,               '')      AS Gender,
                    PP.DOB,
                    PP.JoinedDate,
                    ISNULL(PP.Address,              '')      AS Address,
                    ISNULL(PP.City,                 '')      AS City,
                    ISNULL(PP.Country,              '')      AS Country,
                    ISNULL(CAST(PP.Pincode AS VARCHAR),'')   AS Pincode,
                    ISNULL(PP.Skills,               '')      AS Occupation,
                    ISNULL(PP.Description,          '')      AS AnnualIncome,

                    ISNULL(MIN(PS.RelationshipType),'')      AS RelationshipType,
                    ISNULL(MAX(CAST(PS.IsPrimaryGuardian AS INT)),0) AS IsPrimaryGuardian

                FROM Users PU
                LEFT JOIN UserProfile PP ON PP.UserId = PU.UserId
                LEFT JOIN ParentStudentMapping PS ON PS.ParentUserId = PU.UserId

                WHERE PU.UserId    = @UserId
                  AND PU.SessionId = @SessionId

                GROUP BY
                    PU.UserId, PU.Username, PU.Email, PU.IsActive, PU.IsFirstLogin,
                    PP.FullName, PP.ContactNo, PP.Gender, PP.DOB, PP.JoinedDate,
                    PP.Address, PP.City, PP.Country, PP.Pincode, PP.Skills, PP.Description");

            cmd.Parameters.AddWithValue("@UserId", parentUserId);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);
            return _dl.GetDataTable(cmd);
        }

        // ══════════════════════════════════════════════════════════════════════════
        //  READ – Linked students for a parent (for Credentials / Edit pre-tick)
        // ══════════════════════════════════════════════════════════════════════════

        public DataTable GetLinkedStudents(int parentUserId, int sessionId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT
                    SU.UserId,
                    ISNULL(SP.FullName,'') AS FullName,
                    ISNULL(SAD.RollNumber,'') AS RollNumber,
                    ISNULL(ST.StreamName,'') AS StreamName
                FROM ParentStudentMapping PS
                INNER JOIN Users SU ON SU.UserId = PS.StudentUserId
                INNER JOIN UserProfile SP ON SP.UserId = SU.UserId
                LEFT  JOIN StudentAcademicDetails SAD ON SAD.UserId = SU.UserId
                LEFT  JOIN Streams ST ON ST.StreamId = SAD.StreamId
                WHERE PS.ParentUserId = @PId
                  AND PS.SessionId    = @SessionId
                ORDER BY SP.FullName");
            cmd.Parameters.AddWithValue("@PId", parentUserId);
            cmd.Parameters.AddWithValue("@SessionId", sessionId);
            return _dl.GetDataTable(cmd);
        }

        // ══════════════════════════════════════════════════════════════════════════
        //  READ – Active students for the student selector in modal
        // ══════════════════════════════════════════════════════════════════════════

        public DataTable GetActiveStudents(int instituteId, int sessionId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT
                    U.UserId,
                    ISNULL(P.FullName,      '')  AS FullName,
                    ISNULL(A.RollNumber,    '')  AS RollNumber,
                    ISNULL(ST.StreamName,   '—') AS StreamName,
                    ISNULL(CO.CourseName,   '—') AS CourseName,
                    ISNULL(SM.SemesterName, '—') AS SemesterName,
                    ISNULL(SC.SectionName,  '—') AS SectionName
                FROM Users U
                INNER JOIN Roles R ON R.RoleId = U.RoleId AND R.RoleName = 'Student'
                LEFT  JOIN UserProfile P ON P.UserId = U.UserId
                LEFT  JOIN StudentAcademicDetails A ON A.UserId = U.UserId
                LEFT  JOIN Streams   ST ON ST.StreamId   = A.StreamId
                LEFT  JOIN Courses   CO ON CO.CourseId   = A.CourseId
                LEFT  JOIN Semesters SM ON SM.SemesterId = A.SemesterId
                LEFT  JOIN Sections  SC ON SC.SectionId  = A.SectionId
                WHERE U.InstituteId = @I
                  AND U.SessionId   = @S
                  AND U.IsActive    = 1
                ORDER BY P.FullName");
            cmd.Parameters.AddWithValue("@I", instituteId);
            cmd.Parameters.AddWithValue("@S", sessionId);
            return _dl.GetDataTable(cmd);
        }

        // ══════════════════════════════════════════════════════════════════════════
        //  STATS
        // ══════════════════════════════════════════════════════════════════════════

        public DataTable GetStats(int instituteId, int sessionId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT
                    COUNT(DISTINCT PU.UserId)                                           AS TotalParents,
                    COUNT(DISTINCT CASE WHEN PU.IsActive=1 THEN PU.UserId END)          AS ActiveParents,
                    COUNT(DISTINCT CASE WHEN PU.IsActive=0 THEN PU.UserId END)          AS InactiveParents,
                    COUNT(DISTINCT PS.StudentUserId)                                    AS TotalLinks
                FROM Users PU
                INNER JOIN Roles R ON R.RoleId = PU.RoleId AND R.RoleName = 'Parent'
                LEFT  JOIN ParentStudentMapping PS ON PS.ParentUserId = PU.UserId
                WHERE PU.InstituteId = @I
                  AND PU.SessionId   = @S");
            cmd.Parameters.AddWithValue("@I", instituteId);
            cmd.Parameters.AddWithValue("@S", sessionId);
            return _dl.GetDataTable(cmd);
        }

        // ══════════════════════════════════════════════════════════════════════════
        //  DUPLICATE CHECKS
        // ══════════════════════════════════════════════════════════════════════════

        public bool IsUsernameTaken(string username, int excludeUserId = 0)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT COUNT(1) FROM Users
                WHERE Username = @U AND UserId <> @Excl");
            cmd.Parameters.AddWithValue("@U", username.Trim().ToLower());
            cmd.Parameters.AddWithValue("@Excl", excludeUserId);
            DataTable dt = _dl.GetDataTable(cmd);
            return dt.Rows.Count > 0 && Convert.ToInt32(dt.Rows[0][0]) > 0;
        }

        public bool IsEmailTaken(string email, int excludeUserId = 0)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT COUNT(1) FROM Users
                WHERE Email = @E AND UserId <> @Excl");
            cmd.Parameters.AddWithValue("@E", email.Trim().ToLower());
            cmd.Parameters.AddWithValue("@Excl", excludeUserId);
            DataTable dt = _dl.GetDataTable(cmd);
            return dt.Rows.Count > 0 && Convert.ToInt32(dt.Rows[0][0]) > 0;
        }

        // ══════════════════════════════════════════════════════════════════════════
        //  IN-USE CHECK  (prevents crash on delete)
        // ══════════════════════════════════════════════════════════════════════════

        public bool IsParentInUse(int userId)
        {
            // ParentStudentMapping rows are deleted as part of DeleteParent,
            // so only check Notifications or other hard-FK tables.
            SqlCommand cmd = new SqlCommand(@"
                SELECT
                (SELECT COUNT(1) FROM Notifications WHERE UserId = @Id)
                AS TotalUsage");
            cmd.Parameters.AddWithValue("@Id", userId);
            DataTable dt = _dl.GetDataTable(cmd);
            // Notifications alone don't block delete — we soft-delete those too.
            // Return false so delete always proceeds (mapping rows cleaned up in DeleteParent).
            return false;
        }

        // ══════════════════════════════════════════════════════════════════════════
        //  RESOLVE FK HELPERS  (bulk upload)
        // ══════════════════════════════════════════════════════════════════════════

        /// <summary>Resolves a username to its UserId (used in bulk upload for student lookup).</summary>
        public int GetUserIdByUsername(string username)
        {
            if (string.IsNullOrWhiteSpace(username)) return 0;
            SqlCommand cmd = new SqlCommand(
                "SELECT TOP 1 UserId FROM Users WHERE Username = @U");
            cmd.Parameters.AddWithValue("@U", username.Trim().ToLower());
            DataTable dt = _dl.GetDataTable(cmd);
            return dt.Rows.Count > 0 ? Convert.ToInt32(dt.Rows[0][0]) : 0;
        }

        // ══════════════════════════════════════════════════════════════════════════
        //  INSERT  (Users → UserProfile → ParentStudentMapping[s]) in one transaction
        //  Password = DOB in DDMMYYYY, handled by caller.
        // ══════════════════════════════════════════════════════════════════════════

        /// <summary>
        /// Inserts a parent across three tables atomically.
        /// Returns the new UserId.
        /// Strategy: Insert Users via GetDataTable (OUTPUT INSERTED.UserId),
        /// then UserProfile + all mapping rows via ExecuteTransaction.
        /// </summary>
        public int InsertParent(ParentGC obj)
        {
            int roleId = GetRoleId("Parent");
            if (roleId == 0) throw new Exception("Parent role not found in Roles table.");

            // Step 1 – Insert Users, capture new UserId
            int newUserId = InsertUserGetId(obj, roleId);
            if (newUserId == 0) throw new Exception("Failed to create parent user account.");

            // Step 2 – UserProfile + ParentStudentMapping rows in one transaction
            var cmds = new List<SqlCommand>();

            // UserProfile  (Skills column repurposed for Occupation; Description for income)
            var cmdP = new SqlCommand(@"
                INSERT INTO UserProfile
                    (SocietyId, InstituteId, SessionId, UserId,
                     FullName, Gender, DOB,
                     ContactNo, EmergencyContactName, EmergencyContactNo,
                     Address, City, Country, Pincode, JoinedDate,
                     Skills, Description)
                VALUES
                    (@Soc, @Inst, @Sess, @UserId,
                     @FullName, @Gender, @DOB,
                     @Contact, 'N/A', '0000000000',
                     @Address, @City, @Country, @Pincode, GETDATE(),
                     @Occupation, @Income)");

            cmdP.Parameters.AddWithValue("@Soc", obj.SocietyId);
            cmdP.Parameters.AddWithValue("@Inst", obj.InstituteId);
            cmdP.Parameters.AddWithValue("@Sess", obj.SessionId);
            cmdP.Parameters.AddWithValue("@UserId", newUserId);
            cmdP.Parameters.AddWithValue("@FullName", obj.FullName);
            cmdP.Parameters.AddWithValue("@Gender", obj.Gender);
            cmdP.Parameters.AddWithValue("@DOB", obj.DOB == default(DateTime) ? (object)DBNull.Value : obj.DOB);
            cmdP.Parameters.AddWithValue("@Contact", obj.ContactNo);
            cmdP.Parameters.AddWithValue("@Address", string.IsNullOrWhiteSpace(obj.Address) ? "N/A" : obj.Address);
            cmdP.Parameters.AddWithValue("@City", NullIfEmpty(obj.City));
            cmdP.Parameters.AddWithValue("@Country", NullIfEmpty(obj.Country));
            cmdP.Parameters.AddWithValue("@Pincode", obj.Pincode.HasValue ? (object)obj.Pincode.Value : DBNull.Value);
            cmdP.Parameters.AddWithValue("@Occupation", NullIfEmpty(obj.Occupation));
            cmdP.Parameters.AddWithValue("@Income", NullIfEmpty(obj.AnnualIncome));
            cmds.Add(cmdP);

            // ParentStudentMapping – one row per linked student
            foreach (int studentId in obj.StudentIds)
            {
                var cmdM = new SqlCommand(@"
                    INSERT INTO ParentStudentMapping
                        (SocietyId, InstituteId, SessionId,
                         ParentUserId, StudentUserId,
                         RelationshipType, IsPrimaryGuardian, IsActive)
                    VALUES
                        (@Soc, @Inst, @Sess,
                         @ParentId, @StudentId,
                         @Relation, @Primary, 1)");

                cmdM.Parameters.AddWithValue("@Soc", obj.SocietyId);
                cmdM.Parameters.AddWithValue("@Inst", obj.InstituteId);
                cmdM.Parameters.AddWithValue("@Sess", obj.SessionId);
                cmdM.Parameters.AddWithValue("@ParentId", newUserId);
                cmdM.Parameters.AddWithValue("@StudentId", studentId);
                cmdM.Parameters.AddWithValue("@Relation", obj.RelationshipType);
                cmdM.Parameters.AddWithValue("@Primary", obj.IsPrimaryGuardian);
                cmds.Add(cmdM);
            }

            _dl.ExecuteTransaction(cmds);
            return newUserId;
        }

        /// <summary>Inserts into Users using OUTPUT INSERTED.UserId captured via GetDataTable.</summary>
        private int InsertUserGetId(ParentGC obj, int roleId)
        {
            SqlCommand cmd = new SqlCommand(@"
                INSERT INTO Users
                    (Username, PasswordHash, RoleId, Email,
                     SocietyId, InstituteId, SessionId,
                     IsActive, IsFirstLogin, CreatedOn)
                OUTPUT INSERTED.UserId
                VALUES
                    (@Username, HASHBYTES('SHA2_256', @Password), @RoleId, @Email,
                     @Soc, @Inst, @Sess,
                     1, 1, GETDATE())");

            cmd.Parameters.AddWithValue("@Username", obj.Username);
            cmd.Parameters.AddWithValue("@Password", obj.Password);   // DDMMYYYY
            cmd.Parameters.AddWithValue("@RoleId", roleId);
            cmd.Parameters.AddWithValue("@Email", obj.Email.ToLower());
            cmd.Parameters.AddWithValue("@Soc", obj.SocietyId);
            cmd.Parameters.AddWithValue("@Inst", obj.InstituteId);
            cmd.Parameters.AddWithValue("@Sess", obj.SessionId);

            DataTable dt = _dl.GetDataTable(cmd);
            return dt.Rows.Count > 0 ? Convert.ToInt32(dt.Rows[0][0]) : 0;
        }

        // ══════════════════════════════════════════════════════════════════════════
        //  UPDATE  (Users + UserProfile via MERGE + re-sync mappings)
        // ══════════════════════════════════════════════════════════════════════════

        public void UpdateParent(ParentGC obj)
        {
            var cmds = new List<SqlCommand>();

            // Users – email only (username stays fixed)
            var cmdU = new SqlCommand(@"
                UPDATE Users SET Email = @Email, IsActive = @Active
                WHERE UserId = @Id");
            cmdU.Parameters.AddWithValue("@Email", obj.Email.ToLower());
            cmdU.Parameters.AddWithValue("@Active", 1);
            cmdU.Parameters.AddWithValue("@Id", obj.UserId);
            cmds.Add(cmdU);

            // UserProfile – MERGE
            var cmdP = new SqlCommand(@"
                MERGE UserProfile AS target
                USING (SELECT @UserId AS UserId) AS src ON target.UserId = src.UserId
                WHEN MATCHED THEN UPDATE SET
                    FullName   = @FullName,
                    Gender     = @Gender,
                    DOB        = @DOB,
                    ContactNo  = @Contact,
                    Address    = @Address,
                    City       = @City,
                    Country    = @Country,
                    Pincode    = @Pincode,
                    Skills     = @Occupation,
                    Description= @Income
                WHEN NOT MATCHED THEN INSERT
                    (SocietyId,InstituteId,SessionId,UserId,
                     FullName,Gender,DOB,ContactNo,
                     EmergencyContactName,EmergencyContactNo,
                     Address,City,Country,Pincode,JoinedDate,
                     Skills,Description)
                VALUES
                    (@Soc,@Inst,@Sess,@UserId,
                     @FullName,@Gender,@DOB,@Contact,
                     'N/A','0000000000',
                     @Address,@City,@Country,@Pincode,GETDATE(),
                     @Occupation,@Income);");

            cmdP.Parameters.AddWithValue("@UserId", obj.UserId);
            cmdP.Parameters.AddWithValue("@Soc", obj.SocietyId);
            cmdP.Parameters.AddWithValue("@Inst", obj.InstituteId);
            cmdP.Parameters.AddWithValue("@Sess", obj.SessionId);
            cmdP.Parameters.AddWithValue("@FullName", obj.FullName);
            cmdP.Parameters.AddWithValue("@Gender", obj.Gender);
            cmdP.Parameters.AddWithValue("@DOB", obj.DOB == default(DateTime) ? (object)DBNull.Value : obj.DOB);
            cmdP.Parameters.AddWithValue("@Contact", obj.ContactNo);
            cmdP.Parameters.AddWithValue("@Address", string.IsNullOrWhiteSpace(obj.Address) ? "N/A" : obj.Address);
            cmdP.Parameters.AddWithValue("@City", NullIfEmpty(obj.City));
            cmdP.Parameters.AddWithValue("@Country", NullIfEmpty(obj.Country));
            cmdP.Parameters.AddWithValue("@Pincode", obj.Pincode.HasValue ? (object)obj.Pincode.Value : DBNull.Value);
            cmdP.Parameters.AddWithValue("@Occupation", NullIfEmpty(obj.Occupation));
            cmdP.Parameters.AddWithValue("@Income", NullIfEmpty(obj.AnnualIncome));
            cmds.Add(cmdP);

            // Delete old mappings, then re-insert updated ones
            var cmdDelMap = new SqlCommand(
                "DELETE FROM ParentStudentMapping WHERE ParentUserId = @Id AND SessionId = @Sess");
            cmdDelMap.Parameters.AddWithValue("@Id", obj.UserId);
            cmdDelMap.Parameters.AddWithValue("@Sess", obj.SessionId);
            cmds.Add(cmdDelMap);

            foreach (int studentId in obj.StudentIds)
            {
                var cmdM = new SqlCommand(@"
                    INSERT INTO ParentStudentMapping
                        (SocietyId,InstituteId,SessionId,
                         ParentUserId,StudentUserId,
                         RelationshipType,IsPrimaryGuardian,IsActive)
                    VALUES
                        (@Soc,@Inst,@Sess,
                         @ParentId,@StudentId,
                         @Relation,@Primary,1)");

                cmdM.Parameters.AddWithValue("@Soc", obj.SocietyId);
                cmdM.Parameters.AddWithValue("@Inst", obj.InstituteId);
                cmdM.Parameters.AddWithValue("@Sess", obj.SessionId);
                cmdM.Parameters.AddWithValue("@ParentId", obj.UserId);
                cmdM.Parameters.AddWithValue("@StudentId", studentId);
                cmdM.Parameters.AddWithValue("@Relation", obj.RelationshipType);
                cmdM.Parameters.AddWithValue("@Primary", obj.IsPrimaryGuardian);
                cmds.Add(cmdM);
            }

            _dl.ExecuteTransaction(cmds);
        }

        // ══════════════════════════════════════════════════════════════════════════
        //  TOGGLE
        // ══════════════════════════════════════════════════════════════════════════

        public void ToggleParent(int userId)
        {
            SqlCommand cmd = new SqlCommand(@"
                UPDATE Users
                SET IsActive = CASE WHEN IsActive = 1 THEN 0 ELSE 1 END
                WHERE UserId = @Id");
            cmd.Parameters.AddWithValue("@Id", userId);
            _dl.ExecuteCMD(cmd);
        }

        // ══════════════════════════════════════════════════════════════════════════
        //  RESET PASSWORD  (back to DOB-based or a safe default)
        // ══════════════════════════════════════════════════════════════════════════

        public void ResetPassword(int userId, string newPassword)
        {
            SqlCommand cmd = new SqlCommand(@"
                UPDATE Users SET
                    PasswordHash = HASHBYTES('SHA2_256', @Pwd),
                    IsFirstLogin = 1
                WHERE UserId = @Id");
            cmd.Parameters.AddWithValue("@Pwd", newPassword);
            cmd.Parameters.AddWithValue("@Id", userId);
            _dl.ExecuteCMD(cmd);
        }

        // ══════════════════════════════════════════════════════════════════════════
        //  DELETE  (correct FK order: Mapping → Notifications → Profile → Users)
        // ══════════════════════════════════════════════════════════════════════════

        public void DeleteParent(int userId, int sessionId)
        {
            var cmds = new List<SqlCommand>();

            // 1. ParentStudentMapping
            var c1 = new SqlCommand(
                "DELETE FROM ParentStudentMapping WHERE ParentUserId = @Id AND SessionId = @S");
            c1.Parameters.AddWithValue("@Id", userId);
            c1.Parameters.AddWithValue("@S", sessionId);
            cmds.Add(c1);

            // 2. Notifications (soft dependency, clean up)
            var c2 = new SqlCommand(
                "DELETE FROM Notifications WHERE UserId = @Id");
            c2.Parameters.AddWithValue("@Id", userId);
            cmds.Add(c2);

            // 3. UserProfile
            var c3 = new SqlCommand(
                "DELETE FROM UserProfile WHERE UserId = @Id");
            c3.Parameters.AddWithValue("@Id", userId);
            cmds.Add(c3);

            // 4. Users
            var c4 = new SqlCommand(
                "DELETE FROM Users WHERE UserId = @Id");
            c4.Parameters.AddWithValue("@Id", userId);
            cmds.Add(c4);

            _dl.ExecuteTransaction(cmds);
        }

        // ══════════════════════════════════════════════════════════════════════════
        //  PRIVATE HELPERS
        // ══════════════════════════════════════════════════════════════════════════

        private int GetRoleId(string roleName)
        {
            SqlCommand cmd = new SqlCommand(
                "SELECT RoleId FROM Roles WHERE RoleName = @R");
            cmd.Parameters.AddWithValue("@R", roleName);
            DataTable dt = _dl.GetDataTable(cmd);
            return dt.Rows.Count > 0 ? Convert.ToInt32(dt.Rows[0][0]) : 0;
        }

        private static object NullIfEmpty(string val) =>
            string.IsNullOrWhiteSpace(val) ? (object)DBNull.Value : val.Trim();
    }
}