using System;
using System.Collections.Generic;

namespace LearningManagementSystem.GC
{
    /// <summary>
    /// Global Class (model) for Parent / Guardian entity.
    /// Covers: Users + UserProfile + ParentStudentMapping.
    /// Password is always set to parent's DOB in DDMMYYYY format (e.g. 15061985).
    /// </summary>
    public class ParentGC
    {
        // ── Primary key ────────────────────────────────────────────────────────────
        public int UserId { get; set; }

        // ── Tenant / session identifiers ───────────────────────────────────────────
        public int SocietyId { get; set; }
        public int InstituteId { get; set; }
        public int SessionId { get; set; }

        // ── Users table ────────────────────────────────────────────────────────────

        /// <summary>Login username. Lowercase alphanumeric + underscore, 3–50 chars.</summary>
        public string Username { get; set; }

        /// <summary>
        /// Plain-text password — always DOB in DDMMYYYY (e.g. "15061985").
        /// Hashed via SHA2_256 in the SQL INSERT.
        /// </summary>
        public string Password { get; set; }

        /// <summary>Parent login email.</summary>
        public string Email { get; set; }

        /// <summary>Whether the account is active.</summary>
        public bool IsActive { get; set; } = true;

        // ── UserProfile table ──────────────────────────────────────────────────────

        public string FullName { get; set; }

        /// <summary>Male / Female / Other</summary>
        public string Gender { get; set; }

        /// <summary>Used to derive the default password (DDMMYYYY).</summary>
        public DateTime DOB { get; set; }

        public string ContactNo { get; set; }
        public string Address { get; set; }
        public string City { get; set; }
        public string Country { get; set; }
        public int? Pincode { get; set; }

        /// <summary>Stored in UserProfile.Skills column.</summary>
        public string Occupation { get; set; }

        /// <summary>Stored in UserProfile.Description column.</summary>
        public string AnnualIncome { get; set; }

        // ── ParentStudentMapping table ─────────────────────────────────────────────

        /// <summary>
        /// One or more student UserId values to link to this parent.
        /// Each becomes a separate ParentStudentMapping row.
        /// </summary>
        public List<int> StudentIds { get; set; } = new List<int>();

        /// <summary>
        /// Relationship type: Father, Mother, Guardian, Grandfather,
        /// Grandmother, Elder Sibling, Other.
        /// </summary>
        public string RelationshipType { get; set; }

        /// <summary>
        /// Whether this parent is the primary guardian for all linked students.
        /// </summary>
        public bool IsPrimaryGuardian { get; set; }
    }
}