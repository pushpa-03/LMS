namespace LearningManagementSystem.GC
{
    /// <summary>
    /// Global Class (model) for Subject entity.
    /// Carries data between the UI layer (ASPX / code-behind) and the BL/DAL layers.
    /// </summary>
    public class AddSubjectGC
    {
        // ─── Primary Key ──────────────────────────────────────────────────────────
        public int SubjectId { get; set; }

        // ─── Tenant / Session Identifiers ─────────────────────────────────────────
        public int SocietyId { get; set; }
        public int InstituteId { get; set; }
        public int SessionId { get; set; }

        // ─── Subject Fields ────────────────────────────────────────────────────────
        /// <summary>Alphanumeric code, e.g. "CS101". No special characters.</summary>
        public string SubjectCode { get; set; }

        /// <summary>Full subject name, e.g. "Data Structures and Algorithms".</summary>
        public string SubjectName { get; set; }

        /// <summary>Optional description.</summary>
        public string Description { get; set; }

        /// <summary>Formatted duration string, e.g. "45 mins" or "2 hrs".</summary>
        public string Duration { get; set; }

        /// <summary>Active / Inactive flag.</summary>
        public bool IsActive { get; set; } = true;
    }
}