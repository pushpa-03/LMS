using System;


    /// <summary>
    /// Global Class (model) for Teacher entity.
    /// Covers: Users + UserProfile + TeacherDetails tables.
    /// </summary>
    public class TeacherGC
    {
        // ── Primary key ───────────────────────────────────────────────────────
        public int UserId { get; set; }

        // ── Tenant / session identifiers ──────────────────────────────────────
        public int SocietyId { get; set; }
        public int InstituteId { get; set; }
        public int SessionId { get; set; }

        // ── Users table ───────────────────────────────────────────────────────
        public string Username { get; set; }
        public string Password { get; set; }
        public string Email { get; set; }
        public bool IsActive { get; set; } = true;

        // ── UserProfile table ─────────────────────────────────────────────────
        public string FullName { get; set; }
        public string FatherName { get; set; }
        public string MotherName { get; set; }
        public string Gender { get; set; }
        public DateTime DOB { get; set; }
        public string ContactNo { get; set; }
        public string EmgName { get; set; }
        public string EmgContact { get; set; }
        public string Address { get; set; }
        public string City { get; set; }
        public string Country { get; set; }
        public int? Pincode { get; set; }
        public string Skills { get; set; }
        public DateTime JoinedDate { get; set; } = DateTime.Today;

        // ── TeacherDetails table ──────────────────────────────────────────────
        public int StreamId { get; set; }
        public string EmployeeId { get; set; }
        public string Designation { get; set; }
        public string Qualification { get; set; }
        public int ExperienceYears { get; set; }
    }
