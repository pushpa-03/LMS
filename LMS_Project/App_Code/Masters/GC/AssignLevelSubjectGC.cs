//namespace LearningManagementSystem.GC
//{
//    public class LevelSemesterSubjectGC
//    {
//        public int SocietyId { get; set; }
//        public int InstituteId { get; set; }
//        public int SessionId { get; set; }
//        public int StreamId { get; set; }
//        public int CourseId { get; set; }
//        public int LevelId { get; set; }
//        public int SemesterId { get; set; }
//        public int SubjectId { get; set; }
//        public bool IsMandatory { get; set; }
//    }
//}

//------------------------------------------------------------------------------

using System;

namespace LearningManagementSystem.GC
{
    /// <summary>
    /// Global Class (model) for the LevelSemesterSubjects table.
    /// Carries assignment data between the ASPX page, code-behind,
    /// and AssignLevelSubjectBL.
    ///
    /// Nullable FKs (CourseId, LevelId, SemesterId) mirror the DB schema
    /// where these columns allow NULL so an admin can assign a subject
    /// at just the stream level without specifying every dimension.
    /// </summary>
    public class LevelSemesterSubjectGC
    {
        // ── Primary key ───────────────────────────────────────────────────────
        /// <summary>Auto-generated PK from LevelSemesterSubjects.Id.</summary>
        public int Id { get; set; }

        // ── Tenant / session identifiers ──────────────────────────────────────
        public int SocietyId { get; set; }
        public int InstituteId { get; set; }
        public int SessionId { get; set; }

        // ── Academic hierarchy FKs ────────────────────────────────────────────

        /// <summary>
        /// FK → Streams.StreamId. Required — every assignment must have a stream.
        /// </summary>
        public int StreamId { get; set; }

        /// <summary>
        /// FK → Courses.CourseId. Optional (NULL = applies to all courses in stream).
        /// </summary>
        public int? CourseId { get; set; }

        /// <summary>
        /// FK → StudyLevels.LevelId. Optional (NULL = all levels).
        /// </summary>
        public int? LevelId { get; set; }

        /// <summary>
        /// FK → Semesters.SemesterId. Optional (NULL = all semesters).
        /// </summary>
        public int? SemesterId { get; set; }

        // ── Subject FK ────────────────────────────────────────────────────────

        /// <summary>FK → Subjects.SubjectId. Required.</summary>
        public int SubjectId { get; set; }

        // ── Assignment metadata ───────────────────────────────────────────────

        /// <summary>
        /// True  = Mandatory subject (student must take it).
        /// False = Elective subject (student may choose it).
        /// Defaults to true (most assigned subjects are mandatory).
        /// </summary>
        public bool IsMandatory { get; set; } = true;

        /// <summary>Timestamp set automatically by the DB (GETDATE()).</summary>
        public DateTime CreatedOn { get; set; } = DateTime.Now;
    }
}