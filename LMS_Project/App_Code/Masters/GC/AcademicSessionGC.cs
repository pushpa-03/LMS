using System;

namespace LearningManagementSystem.GC
{
    public class AcademicSessionGC
    {
        public int SessionId { get; set; }
        public int SocietyId { get; set; }
        public int InstituteId { get; set; }
        public string SessionName { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public bool IsActive { get; set; }
        public bool IsCurrent { get; set; }
        public DateTime CreatedOn { get; set; }
    }
}