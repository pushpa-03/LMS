namespace LearningManagementSystem.Admin
{
    public class SubjectsGC
    {
        public int SubjectId { get; set; }
        public string SubjectCode { get; set; }
        public string SubjectName { get; set; }
        public bool IsActive { get; set; }
        public string StreamName { get; set; }
        public string CourseName { get; set; }
        public string SemesterName { get; set; }
        public bool IsMandatory { get; set; }
        public int StudentCount { get; set; }

    }
}