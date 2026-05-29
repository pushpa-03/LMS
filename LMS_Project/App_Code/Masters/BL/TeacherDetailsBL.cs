using System;
using System.Data;
using System.Data.SqlClient;

namespace LearningManagementSystem.BL
{
    /// <summary>
    /// TeacherDetailsBL
    ///
    /// Key points:
    ///   GetAssignedSubjectsDistinct  — ONE row per unique SubjectId (not per section).
    ///                                   Also returns AvgAttendancePct for radar.
    ///   GetSectionsForSubject        — Per-section student count + avg video watch %.
    ///   GetTeacherKPIs               — Returns OverallSubmissionRate for radar.
    ///   TotalViews KPI               — SUM(Videos.ViewCount): raw, all-role play counter.
    ///   VideoRatings                 — No SessionId column; always joined via Videos.
    ///   VideoComments                — Column is "Comment", timestamp is "CommentedOn".
    /// </summary>
    public class TeacherDetailsBL
    {
        private readonly DataLayer _dl = new DataLayer();

        // ══════════════════════════════════════════════════════════════════════
        //  PROFILE
        // ══════════════════════════════════════════════════════════════════════
        public DataTable GetTeacherProfile(int userId, int sessionId)
        {
            var cmd = new SqlCommand(@"
                SELECT
                    U.UserId, U.Username, U.Email, U.IsActive,
                    U.IsFirstLogin, U.LastLogin, U.CreatedOn,
                    ISNULL(UP.FullName,             U.Username) AS FullName,
                    ISNULL(UP.ContactNo,            '')         AS ContactNo,
                    ISNULL(UP.Gender,               '')         AS Gender,
                    ISNULL(CONVERT(VARCHAR,UP.DOB,23),'')       AS DOB,
                    ISNULL(CONVERT(VARCHAR,UP.JoinedDate,23),'') AS JoinedDate,
                    ISNULL(UP.FatherName,           '')         AS FatherName,
                    ISNULL(UP.MotherName,           '')         AS MotherName,
                    ISNULL(UP.EmergencyContactName, '')         AS EmergencyContactName,
                    ISNULL(UP.EmergencyContactNo,   '')         AS EmergencyContactNo,
                    ISNULL(UP.Address,              '')         AS Address,
                    ISNULL(UP.City,                 '')         AS City,
                    ISNULL(UP.Country,              '')         AS Country,
                    ISNULL(CAST(UP.Pincode AS VARCHAR),'')      AS Pincode,
                    ISNULL(UP.Skills,               '')         AS Skills,
                    ISNULL(UP.ProfileImage,         '')         AS ProfileImage,
                    ISNULL(T.EmployeeId,            '')         AS EmployeeId,
                    ISNULL(T.Designation,           '')         AS Designation,
                    ISNULL(T.Qualification,         '')         AS Qualification,
                    ISNULL(T.ExperienceYears,        0)         AS ExperienceYears,
                    ISNULL(S.StreamName,            '—')        AS StreamName,
                    ISNULL(ASess.SessionName,       '')         AS SessionName
                FROM Users U
                LEFT JOIN UserProfile      UP    ON UP.UserId    = U.UserId
                LEFT JOIN TeacherDetails   T     ON T.UserId     = U.UserId
                                                AND T.SessionId  = @Sess
                LEFT JOIN Streams          S     ON S.StreamId   = T.StreamId
                LEFT JOIN AcademicSessions ASess ON ASess.SessionId = @Sess
                WHERE U.UserId = @Uid");
            cmd.Parameters.AddWithValue("@Uid", userId);
            cmd.Parameters.AddWithValue("@Sess", sessionId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        // ══════════════════════════════════════════════════════════════════════
        //  SESSIONS  (for the session dropdown)
        // ══════════════════════════════════════════════════════════════════════
        public DataTable GetTeacherSessions(int userId)
        {
            var cmd = new SqlCommand(@"
                SELECT DISTINCT
                    ASess.SessionId, ASess.SessionName, ASess.StartDate, ASess.IsCurrent
                FROM TeacherDetails T
                INNER JOIN AcademicSessions ASess ON ASess.SessionId = T.SessionId
                WHERE T.UserId = @Uid
                ORDER BY ASess.StartDate DESC");
            cmd.Parameters.AddWithValue("@Uid", userId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        // ══════════════════════════════════════════════════════════════════════
        //  KPIs
        //  TotalViews = SUM(Videos.ViewCount) — raw all-role play counter.
        //  OverallSubmissionRate is used by the radar chart.
        // ══════════════════════════════════════════════════════════════════════
        public DataTable GetTeacherKPIs(int userId, int sessionId)
        {
            var cmd = new SqlCommand(@"
                SELECT
                    -- Subject-section assignment count
                    (SELECT COUNT(1) FROM SubjectFaculty SF
                     WHERE SF.TeacherId = @Uid AND SF.SessionId = @Sess
                       AND ISNULL(SF.IsActive,1) = 1)                          AS TotalSubjects,

                    -- Videos uploaded
                    (SELECT COUNT(1) FROM Videos V
                     WHERE V.InstructorId = @Uid AND V.SessionId = @Sess
                       AND V.IsActive = 1)                                     AS TotalVideos,

                    -- Total Plays: SUM of Videos.ViewCount  (all roles, raw counter)
                    (SELECT ISNULL(SUM(V.ViewCount),0) FROM Videos V
                     WHERE V.InstructorId = @Uid AND V.SessionId = @Sess
                       AND V.IsActive = 1)                                     AS TotalViews,

                    -- Assignments created
                    (SELECT COUNT(1) FROM Assignments A
                     WHERE A.CreatedBy = @Uid AND A.SessionId = @Sess
                       AND A.IsActive = 1)                                     AS TotalAssignments,

                    -- Unique enrolled students (Student role only)
                    (SELECT COUNT(DISTINCT ASS.UserId)
                     FROM AssignStudentSubject ASS
                     INNER JOIN SubjectFaculty SF
                         ON SF.SubjectId = ASS.SubjectId AND SF.SessionId = ASS.SessionId
                     INNER JOIN Users U2 ON U2.UserId = ASS.UserId
                     INNER JOIN Roles R2 ON R2.RoleId = U2.RoleId AND R2.RoleName = 'Student'
                     WHERE SF.TeacherId = @Uid AND SF.SessionId = @Sess
                       AND ISNULL(SF.IsActive,1) = 1)                          AS TotalStudents,

                    -- Avg video rating (VideoRatings has no SessionId — join via Videos)
                    ISNULL(
                        (SELECT CAST(AVG(CAST(VR.Rating AS FLOAT)) AS DECIMAL(3,1))
                         FROM VideoRatings VR
                         INNER JOIN Videos V2 ON V2.VideoId = VR.VideoId
                         WHERE V2.InstructorId = @Uid AND V2.SessionId = @Sess
                           AND V2.IsActive = 1)
                    , 0)                                                        AS AvgVideoRating,

                    -- AI interactions by Students on this teacher's videos
                    (SELECT COUNT(1)
                     FROM VideoAIHistory AIH
                     INNER JOIN Videos V3 ON V3.VideoId = AIH.VideoId
                     INNER JOIN Users  UA ON UA.UserId  = AIH.UserId
                     INNER JOIN Roles  RA ON RA.RoleId  = UA.RoleId AND RA.RoleName = 'Student'
                     WHERE V3.InstructorId = @Uid AND V3.SessionId = @Sess)    AS AIInteractions,

                    -- Overall assignment submission rate % (used in radar)
                    ISNULL((SELECT CAST(
                        COUNT(DISTINCT SUB.SubmissionId) * 100.0
                        / NULLIF(
                            (SELECT COUNT(DISTINCT ASS2.UserId)
                             FROM AssignStudentSubject ASS2
                             INNER JOIN SubjectFaculty SF2
                                 ON SF2.SubjectId = ASS2.SubjectId AND SF2.SessionId = ASS2.SessionId
                             WHERE SF2.TeacherId = @Uid AND SF2.SessionId = @Sess
                               AND ISNULL(SF2.IsActive,1) = 1)
                            * NULLIF(
                                (SELECT COUNT(1) FROM Assignments A2
                                 WHERE A2.CreatedBy = @Uid AND A2.SessionId = @Sess AND A2.IsActive = 1)
                            , 0)
                        , 0) AS DECIMAL(5,1))
                     FROM AssignmentSubmissions SUB
                     INNER JOIN Assignments A3 ON A3.AssignmentId = SUB.AssignmentId
                     WHERE A3.CreatedBy = @Uid AND A3.SessionId = @Sess AND A3.IsActive = 1), 0)
                        AS OverallSubmissionRate");
            cmd.Parameters.AddWithValue("@Uid", userId);
            cmd.Parameters.AddWithValue("@Sess", sessionId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        // ══════════════════════════════════════════════════════════════════════
        //  ASSIGNED SUBJECTS — ONE ROW PER UNIQUE SUBJECT
        //
        //  Used by the Subjects tab cards and the radar/chart data.
        //  Each row = one unique subject (sections are NOT exploded here;
        //  they are fetched separately via GetSectionsForSubject).
        //
        //  Also returns AvgAttendancePct per subject (used for radar).
        // ══════════════════════════════════════════════════════════════════════
        public DataTable GetAssignedSubjectsDistinct(int userId, int sessionId)
        {
            var cmd = new SqlCommand(@"
                SELECT
                    S.SubjectId,
                    S.SubjectName,
                    ISNULL(S.SubjectCode, '') AS SubjectCode,
                    ISNULL(S.Duration,    '') AS Duration,

                    -- Breadcrumb from LevelSemesterSubjects (OUTER APPLY TOP 1)
                    ISNULL(LssInfo.StreamName,   '—') AS StreamName,
                    ISNULL(LssInfo.CourseName,   '—') AS CourseName,
                    ISNULL(LssInfo.LevelName,    '—') AS LevelName,
                    ISNULL(LssInfo.SemesterName, '—') AS SemesterName,

                    -- Content counts (same for every section of this subject)
                    (SELECT COUNT(1) FROM Chapters CH
                     WHERE CH.SubjectId = S.SubjectId AND CH.SessionId = @Sess
                       AND CH.IsActive = 1)                             AS ChapterCount,

                    (SELECT COUNT(1) FROM Videos V
                     WHERE V.SubjectId = S.SubjectId AND V.SessionId = @Sess
                       AND V.IsActive = 1)                              AS VideoCount,

                    (SELECT COUNT(1) FROM Materials M
                     INNER JOIN Chapters CH2 ON CH2.ChapterId = M.ChapterId
                     WHERE CH2.SubjectId = S.SubjectId AND M.SessionId = @Sess)
                                                                        AS MaterialCount,

                    -- Total enrolled students across ALL sections of this subject
                    (SELECT COUNT(DISTINCT ASS.UserId)
                     FROM AssignStudentSubject ASS
                     INNER JOIN Users UST ON UST.UserId = ASS.UserId
                     INNER JOIN Roles RST ON RST.RoleId = UST.RoleId AND RST.RoleName = 'Student'
                     WHERE ASS.SubjectId = S.SubjectId AND ASS.SessionId = @Sess)
                                                                        AS EnrolledStudents,

                    -- Students who completed ≥80% of ≥1 video (all sections)
                    (SELECT COUNT(DISTINCT WP.UserId)
                     FROM VideoWatchProgress WP
                     INNER JOIN Videos V2    ON V2.VideoId   = WP.VideoId
                     INNER JOIN Users  UST2  ON UST2.UserId  = WP.UserId
                     INNER JOIN Roles  RST2  ON RST2.RoleId  = UST2.RoleId AND RST2.RoleName = 'Student'
                     WHERE V2.SubjectId = S.SubjectId AND WP.SessionId = @Sess
                       AND WP.WatchedPercent >= 80)                     AS CompletedStudents,

                    -- Syllabus completion % (unique completed videos / total videos × 100)
                    ISNULL(CAST(
                        (SELECT COUNT(DISTINCT WP3.VideoId)
                         FROM VideoWatchProgress WP3
                         INNER JOIN Videos V3   ON V3.VideoId  = WP3.VideoId
                         INNER JOIN Users  UST3 ON UST3.UserId = WP3.UserId
                         INNER JOIN Roles  RST3 ON RST3.RoleId = UST3.RoleId AND RST3.RoleName = 'Student'
                         WHERE V3.SubjectId = S.SubjectId AND WP3.SessionId = @Sess
                           AND WP3.WatchedPercent >= 80)
                        * 100.0 / NULLIF(
                            (SELECT COUNT(DISTINCT V4.VideoId) FROM Videos V4
                             WHERE V4.SubjectId = S.SubjectId AND V4.SessionId = @Sess
                               AND V4.IsActive = 1), 0)
                    AS DECIMAL(5,1)), 0)                                AS SyllabusCompletedPct,

                    -- Avg attendance % for this subject (for radar)
                    ISNULL(CAST(
                        COUNT(DISTINCT
                            CASE WHEN A.Status = 'Present'
                                 THEN CAST(A.UserId AS VARCHAR(10))
                                      + '_' + CONVERT(VARCHAR, A.Date, 23)
                                 END)
                        * 100.0
                        / NULLIF(
                            COUNT(DISTINCT A.UserId) * COUNT(DISTINCT A.Date)
                        , 0)
                    AS DECIMAL(5,1)), 0)                                AS AvgAttendancePct

                FROM (
                    -- De-duplicate: one row per SubjectId
                    SELECT DISTINCT SubjectId
                    FROM SubjectFaculty
                    WHERE TeacherId            = @Uid
                      AND SessionId            = @Sess
                      AND ISNULL(IsActive, 1)  = 1
                ) SF_DEDUP

                INNER JOIN Subjects S ON S.SubjectId = SF_DEDUP.SubjectId

                -- Breadcrumb from LevelSemesterSubjects (TOP 1 per subject)
                OUTER APPLY (
                    SELECT TOP 1
                        ISNULL(ST.StreamName,    '—') AS StreamName,
                        ISNULL(C.CourseName,     '—') AS CourseName,
                        ISNULL(SL.LevelName,     '—') AS LevelName,
                        ISNULL(SEM.SemesterName, '—') AS SemesterName
                    FROM LevelSemesterSubjects LSS
                    LEFT JOIN Streams     ST  ON ST.StreamId    = LSS.StreamId
                    LEFT JOIN Courses     C   ON C.CourseId     = LSS.CourseId
                    LEFT JOIN StudyLevels SL  ON SL.LevelId     = LSS.LevelId
                    LEFT JOIN Semesters   SEM ON SEM.SemesterId = LSS.SemesterId
                    WHERE LSS.SubjectId = SF_DEDUP.SubjectId AND LSS.SessionId = @Sess
                ) AS LssInfo

                -- Attendance left-join (for AvgAttendancePct)
                LEFT JOIN Attendance A
                    ON A.SubjectId = S.SubjectId AND A.SessionId = @Sess
                LEFT JOIN Users UA ON UA.UserId = A.UserId
                LEFT JOIN Roles RA ON RA.RoleId = UA.RoleId AND RA.RoleName = 'Student'

                GROUP BY
                    S.SubjectId, S.SubjectName, S.SubjectCode, S.Duration,
                    LssInfo.StreamName, LssInfo.CourseName,
                    LssInfo.LevelName, LssInfo.SemesterName

                ORDER BY S.SubjectName");
            cmd.Parameters.AddWithValue("@Uid", userId);
            cmd.Parameters.AddWithValue("@Sess", sessionId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        // ══════════════════════════════════════════════════════════════════════
        //  SECTIONS FOR SUBJECT
        //  Returns one row per section assigned to this teacher for this subject.
        //  Each row has:
        //    SectionName     — e.g. "Section A"
        //    SectionStudents — enrolled students in that section
        //    AvgWatchPct     — avg video watch % for students in that section
        // ══════════════════════════════════════════════════════════════════════
        public DataTable GetSectionsForSubject(int userId, int subjectId, int sessionId)
        {
            var cmd = new SqlCommand(@"
                SELECT
                    ISNULL(SEC.SectionName, 'All')                              AS SectionName,
                    SF.SectionId,

                    -- Number of enrolled students in this section for this subject
                    ISNULL(
                        (SELECT COUNT(DISTINCT ASS.UserId)
                         FROM AssignStudentSubject ASS
                         INNER JOIN Users  UST ON UST.UserId = ASS.UserId
                         INNER JOIN Roles  RST ON RST.RoleId = UST.RoleId AND RST.RoleName = 'Student'
                         INNER JOIN StudentAcademicDetails SADS
                             ON SADS.UserId = ASS.UserId AND SADS.SessionId = @Sess
                         WHERE ASS.SubjectId  = @SubId
                           AND ASS.SessionId  = @Sess
                           AND (SF.SectionId IS NULL OR SADS.SectionId = SF.SectionId))
                    , 0)                                                        AS SectionStudents,

                    -- Avg watch % across all videos in the subject
                    -- for students in this section
                    ISNULL(
                        (SELECT CAST(AVG(CAST(WP.WatchedPercent AS FLOAT)) AS DECIMAL(5,1))
                         FROM VideoWatchProgress WP
                         INNER JOIN Videos V2    ON V2.VideoId   = WP.VideoId
                         INNER JOIN Users  UST2  ON UST2.UserId  = WP.UserId
                         INNER JOIN Roles  RST2  ON RST2.RoleId  = UST2.RoleId AND RST2.RoleName = 'Student'
                         INNER JOIN StudentAcademicDetails SADS2
                             ON SADS2.UserId = WP.UserId AND SADS2.SessionId = @Sess
                         WHERE V2.SubjectId  = @SubId
                           AND WP.SessionId  = @Sess
                           AND (SF.SectionId IS NULL OR SADS2.SectionId = SF.SectionId))
                    , 0)                                                        AS AvgWatchPct

                FROM SubjectFaculty SF
                LEFT JOIN Sections SEC ON SEC.SectionId = SF.SectionId

                WHERE SF.TeacherId            = @Uid
                  AND SF.SubjectId            = @SubId
                  AND SF.SessionId            = @Sess
                  AND ISNULL(SF.IsActive, 1)  = 1

                ORDER BY SEC.SectionName");
            cmd.Parameters.AddWithValue("@Uid", userId);
            cmd.Parameters.AddWithValue("@SubId", subjectId);
            cmd.Parameters.AddWithValue("@Sess", sessionId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        // ══════════════════════════════════════════════════════════════════════
        //  CHAPTERS WITH CONTENT COUNTS  (Content Tree tab)
        // ══════════════════════════════════════════════════════════════════════
        public DataTable GetChaptersWithContent(int subjectId, int sessionId)
        {
            var cmd = new SqlCommand(@"
                SELECT
                    CH.ChapterId, CH.ChapterName, CH.OrderNo,

                    (SELECT COUNT(1) FROM Videos V
                     WHERE V.ChapterId = CH.ChapterId AND V.SessionId = @Sess
                       AND V.IsActive = 1)                              AS VideoCount,

                    (SELECT COUNT(1) FROM Materials M
                     WHERE M.ChapterId = CH.ChapterId AND M.SessionId = @Sess) AS MaterialCount,


                    -- Student-only views (VideoViews table)
                    --ISNULL((
                    --    SELECT COUNT(DISTINCT VIW.UserId)
                    --    FROM Videos V2
                    --    LEFT JOIN VideoViews VIW ON VIW.VideoId = V2.VideoId AND VIW.SessionId = @Sess
                    --    LEFT JOIN Users UVIU ON UVIU.UserId = VIW.UserId
                    --    LEFT JOIN Roles RVIU ON RVIU.RoleId = UVIU.RoleId AND RVIU.RoleName = 'Student'
                    --    WHERE V2.ChapterId = CH.ChapterId AND V2.SessionId = @Sess
                    --      AND V2.IsActive = 1
                    --), 0) AS TotalViews,

                    -- Unique student viewers across ALL videos in the chapter
                    ISNULL((
                        SELECT COUNT(DISTINCT VIW.UserId)
                        FROM Videos V2
                        INNER JOIN VideoViews VIW
                            ON VIW.VideoId = V2.VideoId
                           AND VIW.SessionId = @Sess
                        INNER JOIN Users UVIU
                            ON UVIU.UserId = VIW.UserId
                        INNER JOIN Roles RVIU
                            ON RVIU.RoleId = UVIU.RoleId
                           AND RVIU.RoleName = 'Student'
                        WHERE V2.ChapterId = CH.ChapterId
                          AND V2.SessionId = @Sess
                          AND V2.IsActive = 1
                    ), 0) AS TotalViews,

                    -- Students who completed ≥80% of any video
                    (SELECT COUNT(DISTINCT WP.UserId)
                     FROM VideoWatchProgress WP
                     INNER JOIN Videos V3   ON V3.VideoId  = WP.VideoId
                     INNER JOIN Users  UST  ON UST.UserId  = WP.UserId
                     INNER JOIN Roles  RST  ON RST.RoleId  = UST.RoleId AND RST.RoleName = 'Student'
                     WHERE V3.ChapterId = CH.ChapterId AND WP.SessionId = @Sess
                       AND WP.WatchedPercent >= 80)                     AS StudentsCompleted

                FROM Chapters CH
                WHERE CH.SubjectId = @SubId AND CH.SessionId = @Sess AND CH.IsActive = 1
                ORDER BY CH.OrderNo, CH.ChapterId");
            cmd.Parameters.AddWithValue("@SubId", subjectId);
            cmd.Parameters.AddWithValue("@Sess", sessionId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        // ══════════════════════════════════════════════════════════════════════
        //  VIDEOS BY CHAPTER  (student-only stats)
        // ══════════════════════════════════════════════════════════════════════
        public DataTable GetVideosByChapterFull(int chapterId, int sessionId)
        {
            var cmd = new SqlCommand(@"
                SELECT
                    V.VideoId, V.Title,
                    ISNULL(V.Duration, '') AS Duration,
                    V.UploadedOn,

                    (SELECT COUNT(DISTINCT VV.UserId)
                     FROM VideoViews VV
                     INNER JOIN Users UV ON UV.UserId = VV.UserId
                     INNER JOIN Roles RV ON RV.RoleId = UV.RoleId AND RV.RoleName = 'Student'
                     WHERE VV.VideoId = V.VideoId AND VV.SessionId = @Sess)    AS ViewCount,

                    (SELECT COUNT(DISTINCT VV2.UserId)
                     FROM VideoViews VV2
                     INNER JOIN Users UV2 ON UV2.UserId = VV2.UserId
                     INNER JOIN Roles RV2 ON RV2.RoleId = UV2.RoleId AND RV2.RoleName = 'Student'
                     WHERE VV2.VideoId = V.VideoId AND VV2.SessionId = @Sess)  AS UniqueViewers,

                    (SELECT COUNT(DISTINCT WP.UserId)
                     FROM VideoWatchProgress WP
                     INNER JOIN Users UWCP ON UWCP.UserId = WP.UserId
                     INNER JOIN Roles RWCP ON RWCP.RoleId = UWCP.RoleId AND RWCP.RoleName = 'Student'
                     WHERE WP.VideoId = V.VideoId AND WP.SessionId = @Sess
                       AND WP.WatchedPercent >= 95)                             AS CompletedCount,

                    -- Avg student rating (VideoRatings has no SessionId)
                    ISNULL(
                        (SELECT CAST(AVG(CAST(VR.Rating AS FLOAT)) AS DECIMAL(3,1))
                         FROM VideoRatings VR
                         INNER JOIN Users UVR ON UVR.UserId = VR.UserId
                         INNER JOIN Roles RVR ON RVR.RoleId = UVR.RoleId AND RVR.RoleName = 'Student'
                         WHERE VR.VideoId = V.VideoId)
                    , 0)                                                        AS AvgRating,

                    (SELECT COUNT(1)
                     FROM VideoRatings VR2
                     INNER JOIN Users UVR2 ON UVR2.UserId = VR2.UserId
                     INNER JOIN Roles RVR2 ON RVR2.RoleId = UVR2.RoleId AND RVR2.RoleName = 'Student'
                     WHERE VR2.VideoId = V.VideoId)                             AS RatingCount

                FROM Videos V
                WHERE V.ChapterId = @ChId AND V.SessionId = @Sess AND V.IsActive = 1
                ORDER BY V.VideoId");
            cmd.Parameters.AddWithValue("@ChId", chapterId);
            cmd.Parameters.AddWithValue("@Sess", sessionId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        // ══════════════════════════════════════════════════════════════════════
        //  VIDEO RATINGS SUMMARY  (Ratings tab)
        // ══════════════════════════════════════════════════════════════════════
        public DataTable GetVideoRatingsSummary(int userId, int sessionId)
        {
            var cmd = new SqlCommand(@"
                SELECT
                    V.VideoId,
                    V.Title                         AS VideoTitle,
                    ISNULL(CH.ChapterName, '—')     AS ChapterName,
                    S.SubjectName,

                    -- Student views only
                    (SELECT COUNT(DISTINCT VV.UserId)
                     FROM VideoViews VV
                     INNER JOIN Users UVV ON UVV.UserId = VV.UserId
                     INNER JOIN Roles RVV ON RVV.RoleId = UVV.RoleId AND RVV.RoleName = 'Student'
                     WHERE VV.VideoId = V.VideoId AND VV.SessionId = @Sess) AS TotalViews,

                    ISNULL(CAST(AVG(CAST(VR.Rating AS FLOAT)) AS DECIMAL(3,1)), 0) AS AvgRating,
                    COUNT(VR.RatingId)                                              AS RatingCount

                FROM Videos V
                INNER JOIN Subjects S  ON S.SubjectId  = V.SubjectId
                LEFT  JOIN Chapters CH ON CH.ChapterId = V.ChapterId
                LEFT  JOIN VideoRatings VR  ON VR.VideoId = V.VideoId
                LEFT  JOIN Users        UVR ON UVR.UserId = VR.UserId
                LEFT  JOIN Roles        RVR ON RVR.RoleId = UVR.RoleId AND RVR.RoleName = 'Student'
                WHERE V.InstructorId = @Uid AND V.SessionId = @Sess AND V.IsActive = 1
                GROUP BY V.VideoId, V.Title, CH.ChapterName, S.SubjectName
                ORDER BY AvgRating DESC, TotalViews DESC");
            cmd.Parameters.AddWithValue("@Uid", userId);
            cmd.Parameters.AddWithValue("@Sess", sessionId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        // ══════════════════════════════════════════════════════════════════════
        //  ATTENDANCE BY SUBJECT
        // ══════════════════════════════════════════════════════════════════════
        public DataTable GetAttendanceBySubject(int userId, int sessionId)
        {
            var cmd = new SqlCommand(@"
                SELECT
                    S.SubjectId, S.SubjectName, S.SubjectCode,
                    COUNT(DISTINCT A.UserId) AS TotalStudents,
                    COUNT(DISTINCT A.Date)   AS TotalClasses,

                    COUNT(DISTINCT
                        CASE WHEN A.Status = 'Present'
                             THEN CAST(A.UserId AS VARCHAR(10))
                                  + '_' + CONVERT(VARCHAR, A.Date, 23)
                             END)            AS PresentCount,

                    ISNULL(CAST(
                        COUNT(DISTINCT
                            CASE WHEN A.Status = 'Present'
                                 THEN CAST(A.UserId AS VARCHAR(10))
                                      + '_' + CONVERT(VARCHAR, A.Date, 23)
                                 END)
                        * 100.0
                        / NULLIF(COUNT(DISTINCT A.UserId) * COUNT(DISTINCT A.Date), 0)
                    AS DECIMAL(5,1)), 0)     AS AvgAttendancePct

                FROM Attendance A
                INNER JOIN Subjects S ON S.SubjectId = A.SubjectId
                INNER JOIN SubjectFaculty SF
                    ON SF.SubjectId = A.SubjectId AND SF.SessionId = @Sess
                   AND ISNULL(SF.IsActive, 1) = 1
                INNER JOIN Users UA ON UA.UserId = A.UserId
                INNER JOIN Roles RA ON RA.RoleId = UA.RoleId AND RA.RoleName = 'Student'
                WHERE SF.TeacherId = @Uid AND A.SessionId = @Sess
                GROUP BY S.SubjectId, S.SubjectName, S.SubjectCode
                ORDER BY AvgAttendancePct DESC");
            cmd.Parameters.AddWithValue("@Uid", userId);
            cmd.Parameters.AddWithValue("@Sess", sessionId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        // ══════════════════════════════════════════════════════════════════════
        //  TOP ATTENDING CLASSES
        // ══════════════════════════════════════════════════════════════════════
        public DataTable GetTopAttendingClasses(int userId, int sessionId)
        {
            var cmd = new SqlCommand(@"
                SELECT TOP 10
                    S.SubjectName, S.SubjectCode,
                    ISNULL(SL.LevelName,    '—') AS LevelName,
                    ISNULL(Sec.SectionName, '—') AS SectionName,
                    COUNT(DISTINCT A.UserId)      AS StudentCount,
                    ISNULL(CAST(
                        COUNT(DISTINCT
                            CASE WHEN A.Status = 'Present'
                                 THEN CAST(A.UserId AS VARCHAR(10))
                                      + '_' + CONVERT(VARCHAR, A.Date, 23)
                                 END)
                        * 100.0
                        / NULLIF(COUNT(DISTINCT A.UserId) * COUNT(DISTINCT A.Date), 0)
                    AS DECIMAL(5,1)), 0)          AS AttendancePct
                FROM Attendance A
                INNER JOIN Subjects S ON S.SubjectId = A.SubjectId
                INNER JOIN SubjectFaculty SF
                    ON SF.SubjectId = A.SubjectId AND SF.SessionId = @Sess
                   AND ISNULL(SF.IsActive, 1) = 1
                INNER JOIN Users UA ON UA.UserId = A.UserId
                INNER JOIN Roles RA ON RA.RoleId = UA.RoleId AND RA.RoleName = 'Student'
                LEFT JOIN StudentAcademicDetails SADS
                    ON SADS.UserId = A.UserId AND SADS.SessionId = @Sess
                LEFT JOIN StudyLevels SL  ON SL.LevelId   = SADS.LevelId
                LEFT JOIN Sections    Sec ON Sec.SectionId = SADS.SectionId
                WHERE SF.TeacherId = @Uid AND A.SessionId = @Sess
                GROUP BY S.SubjectName, S.SubjectCode, SL.LevelName, Sec.SectionName
                ORDER BY AttendancePct DESC, StudentCount DESC");
            cmd.Parameters.AddWithValue("@Uid", userId);
            cmd.Parameters.AddWithValue("@Sess", sessionId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        // ══════════════════════════════════════════════════════════════════════
        //  ASSIGNMENTS
        // ══════════════════════════════════════════════════════════════════════
        public DataTable GetAssignments(int userId, int sessionId)
        {
            var cmd = new SqlCommand(@"
                SELECT
                    A.AssignmentId,
                    A.Title,
                    ISNULL(LEFT(A.Description, 60), '') AS Description,
                    ISNULL(A.MaxMarks, 0)               AS MaxMarks,
                    A.DueDate, A.CreatedOn,
                    S.SubjectName, S.SubjectCode,

                    (SELECT COUNT(DISTINCT ASS.UserId)
                     FROM AssignStudentSubject ASS
                     INNER JOIN Users UST ON UST.UserId = ASS.UserId
                     INNER JOIN Roles RST ON RST.RoleId = UST.RoleId AND RST.RoleName = 'Student'
                     WHERE ASS.SubjectId = A.SubjectId AND ASS.SessionId = @Sess)
                        AS TotalStudents,

                    (SELECT COUNT(DISTINCT SUB.SubmissionId)
                     FROM AssignmentSubmissions SUB
                     WHERE SUB.AssignmentId = A.AssignmentId)
                        AS Submissions,

                    (SELECT COUNT(DISTINCT SUB2.SubmissionId)
                     FROM AssignmentSubmissions SUB2
                     WHERE SUB2.AssignmentId = A.AssignmentId
                       AND SUB2.MarksObtained IS NOT NULL)
                        AS Graded,

                    ISNULL(
                        (SELECT CAST(AVG(CAST(SUB3.MarksObtained AS FLOAT)) AS DECIMAL(5,1))
                         FROM AssignmentSubmissions SUB3
                         WHERE SUB3.AssignmentId = A.AssignmentId
                           AND SUB3.MarksObtained IS NOT NULL)
                    , 0)                            AS AvgMarks

                FROM Assignments A
                INNER JOIN Subjects S ON S.SubjectId = A.SubjectId
                WHERE A.CreatedBy = @Uid AND A.SessionId = @Sess AND A.IsActive = 1
                ORDER BY A.CreatedOn DESC");
            cmd.Parameters.AddWithValue("@Uid", userId);
            cmd.Parameters.AddWithValue("@Sess", sessionId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        // ══════════════════════════════════════════════════════════════════════
        //  VIDEO UPLOAD TREND  (Analytics tab)
        // ══════════════════════════════════════════════════════════════════════
        public DataTable GetVideoUploadTrend(int userId, int sessionId)
        {
            var cmd = new SqlCommand(@"
                SELECT
                    YEAR(V.UploadedOn)  AS Yr,
                    MONTH(V.UploadedOn) AS Mo,
                    DATENAME(MONTH, V.UploadedOn) + ' ' + CAST(YEAR(V.UploadedOn) AS VARCHAR)
                        AS MonthLabel,
                    COUNT(1) AS VideoCount,
                    ISNULL(
                        (SELECT COUNT(DISTINCT VV.UserId)
                         FROM VideoViews VV
                         INNER JOIN Videos V_VV ON V_VV.VideoId = VV.VideoId
                         INNER JOIN Users  UVV  ON UVV.UserId   = VV.UserId
                         INNER JOIN Roles  RVV  ON RVV.RoleId   = UVV.RoleId AND RVV.RoleName = 'Student'
                         WHERE V_VV.InstructorId = @Uid AND V_VV.SessionId = @Sess
                           AND YEAR(VV.ViewedOn)  = YEAR(V.UploadedOn)
                           AND MONTH(VV.ViewedOn) = MONTH(V.UploadedOn))
                    , 0) AS TotalViews
                FROM Videos V
                WHERE V.InstructorId = @Uid AND V.SessionId = @Sess AND V.IsActive = 1
                GROUP BY YEAR(V.UploadedOn), MONTH(V.UploadedOn), DATENAME(MONTH, V.UploadedOn)
                ORDER BY Yr, Mo");
            cmd.Parameters.AddWithValue("@Uid", userId);
            cmd.Parameters.AddWithValue("@Sess", sessionId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        // ══════════════════════════════════════════════════════════════════════
        //  ACTIVITY LOG
        // ══════════════════════════════════════════════════════════════════════
        public DataTable GetActivityLog(int userId, int sessionId)
        {
            var cmd = new SqlCommand(@"
                SELECT TOP 50 UAL.LogId, UAL.ActivityType, UAL.ReferenceId, UAL.ActionTime
                FROM UserActivityLog UAL
                WHERE UAL.UserId = @Uid AND UAL.SessionId = @Sess
                ORDER BY UAL.ActionTime DESC");
            cmd.Parameters.AddWithValue("@Uid", userId);
            cmd.Parameters.AddWithValue("@Sess", sessionId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        // ══════════════════════════════════════════════════════════════════════
        //  NOTIFICATIONS
        // ══════════════════════════════════════════════════════════════════════
        public DataTable GetNotifications(int userId, int sessionId)
        {
            var cmd = new SqlCommand(@"
                SELECT TOP 30
                    N.NotificationId, N.Message, N.NotificationType, N.IsRead, N.CreatedOn
                FROM Notifications N
                WHERE N.UserId = @Uid AND N.SessionId = @Sess
                ORDER BY N.CreatedOn DESC");
            cmd.Parameters.AddWithValue("@Uid", userId);
            cmd.Parameters.AddWithValue("@Sess", sessionId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        // ══════════════════════════════════════════════════════════════════════
        //  HELP REQUESTS
        // ══════════════════════════════════════════════════════════════════════
        public DataTable GetHelpRequests(int userId, int sessionId)
        {
            var cmd = new SqlCommand(@"
                SELECT
                    HR.HelpId, HR.Question, HR.AskedOn,
                    ISNULL(REP.Reply, '')                   AS Reply,
                    REP.RepliedOn,
                    ISNULL(ADUP.FullName, ADU.Username)     AS RepliedBy,
                    CASE WHEN REP.ReplyId IS NOT NULL THEN 1 ELSE 0 END AS HasReply
                FROM HelpRequests HR
                LEFT JOIN HelpReplies REP  ON REP.HelpId  = HR.HelpId
                LEFT JOIN Users       ADU  ON ADU.UserId  = REP.AdminId
                LEFT JOIN UserProfile ADUP ON ADUP.UserId = REP.AdminId
                WHERE HR.UserId = @Uid AND HR.SessionId = @Sess
                ORDER BY HR.AskedOn DESC");
            cmd.Parameters.AddWithValue("@Uid", userId);
            cmd.Parameters.AddWithValue("@Sess", sessionId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        // ══════════════════════════════════════════════════════════════════════
        //  AI INTERACTIONS  (students on this teacher's videos only)
        // ══════════════════════════════════════════════════════════════════════
        public DataTable GetAIUsageOnVideos(int userId, int sessionId)
        {
            var cmd = new SqlCommand(@"
                SELECT TOP 100
                    ISNULL(LEFT(AIH.Question, 100), 'AI Interaction') AS Question,
                    ISNULL(LEFT(AIH.Response,  150), '')              AS Answer,
                    AIH.CreatedOn,
                    ISNULL(AIH.Type, '—')                             AS AIType,
                    V.Title                                           AS VideoTitle,
                    S.SubjectName,
                    ISNULL(UP.FullName, U.Username)                   AS StudentName
                FROM VideoAIHistory AIH
                INNER JOIN Videos      V  ON V.VideoId   = AIH.VideoId
                INNER JOIN Subjects    S  ON S.SubjectId = V.SubjectId
                INNER JOIN Users       U  ON U.UserId    = AIH.UserId
                INNER JOIN Roles       R  ON R.RoleId    = U.RoleId AND R.RoleName = 'Student'
                LEFT  JOIN UserProfile UP ON UP.UserId   = AIH.UserId
                WHERE V.InstructorId = @Uid AND V.SessionId = @Sess
                ORDER BY AIH.CreatedOn DESC");
            cmd.Parameters.AddWithValue("@Uid", userId);
            cmd.Parameters.AddWithValue("@Sess", sessionId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        // ══════════════════════════════════════════════════════════════════════
        //  VIDEO COMMENTS  (students only, top-level only)
        //  Column name: "Comment"   Timestamp: "CommentedOn"
        // ══════════════════════════════════════════════════════════════════════
        public DataTable GetVideoComments(int userId, int sessionId)
        {
            var cmd = new SqlCommand(@"
                SELECT TOP 50
                    VC.CommentId,
                    LEFT(VC.Comment, 200)           AS CommentText,
                    VC.CommentedOn                  AS CreatedOn,
                    V.Title                         AS VideoTitle,
                    S.SubjectName,
                    ISNULL(UP.FullName, U.Username) AS CommenterName,
                    R.RoleName                      AS CommenterRole
                FROM VideoComments VC
                INNER JOIN Videos      V  ON V.VideoId   = VC.VideoId
                INNER JOIN Subjects    S  ON S.SubjectId = V.SubjectId
                INNER JOIN Users       U  ON U.UserId    = VC.UserId
                INNER JOIN Roles       R  ON R.RoleId    = U.RoleId AND R.RoleName = 'Student'
                LEFT  JOIN UserProfile UP ON UP.UserId   = U.UserId
                WHERE V.InstructorId      = @Uid
                  AND V.SessionId         = @Sess
                  AND VC.ParentCommentId  IS NULL
                ORDER BY VC.CommentedOn DESC");
            cmd.Parameters.AddWithValue("@Uid", userId);
            cmd.Parameters.AddWithValue("@Sess", sessionId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }
    }
}