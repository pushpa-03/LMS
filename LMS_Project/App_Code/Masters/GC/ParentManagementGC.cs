using System;
using System.Collections.Generic;

namespace LearningManagementSystem.GC
{
    public class ParentGC
    {
        public int SocietyId { get; set; }
        public int InstituteId { get; set; }

        public string Username { get; set; }
        public string Email { get; set; }

        public string FullName { get; set; }
        public string Gender { get; set; }
        public DateTime? DOB { get; set; }

        public string ContactNo { get; set; }

        // NEW FIELDS
        public List<int> StudentIds { get; set; }
        public string RelationshipType { get; set; }
        public bool IsPrimaryGuardian { get; set; }
    }
}