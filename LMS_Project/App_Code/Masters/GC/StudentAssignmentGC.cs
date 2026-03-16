using System;

namespace LearningManagementSystem.GC
{
    public class StudentAssignmentGC
    {
        public int AssignmentId { get; set; }
        public int SocietyId { get; set; }
        public int InstituteId { get; set; }
        public int SubjectId { get; set; }
        public int CreatedBy { get; set; }

        public string Title { get; set; }
        public string Description { get; set; }
        public DateTime DueDate { get; set; }
        public int MaxMarks { get; set; }
        public bool IsActive { get; set; }

        // Joined fields
        public string SubjectName { get; set; }
        public string SubjectCode { get; set; }

        // Submission info
        public int? SubmissionId { get; set; }
        public string FilePath { get; set; }
        public string Remarks { get; set; }
        public int? MarksObtained { get; set; }
        public DateTime? SubmittedOn { get; set; }
        public string Status { get; set; }  // Pending / Submitted / Overdue
    }
}