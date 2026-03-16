using System;

namespace LearningManagementSystem.GC
{
    public class StudentGC
    {
        public int UserId { get; set; }

        public int SocietyId { get; set; }
        public int InstituteId { get; set; }
        public int SessionId { get; set; }

        public int? StreamId { get; set; }
        public int? CourseId { get; set; }
        public int? SectionId { get; set; }

        public string Username { get; set; }
        public string Email { get; set; }

        public string FullName { get; set; }
        public string Gender { get; set; }
        public DateTime DOB { get; set; }
        public string ContactNo { get; set; }

        public string RollNumber { get; set; }
    }
}