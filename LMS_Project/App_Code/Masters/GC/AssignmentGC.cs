using System;

namespace LearningManagementSystem.GC
{
    public class AssignmentGC
    {
        public int AssignmentId { get; set; }
        public int SocietyId { get; set; }
        public int InstituteId { get; set; }
        public int SubjectId { get; set; }

        public string Title { get; set; }
        public string Description { get; set; }
        public string FilePath { get; set; }

        public DateTime? DueDate { get; set; }
        public int? MaxMarks { get; set; }

        public int CreatedBy { get; set; }
    }
}