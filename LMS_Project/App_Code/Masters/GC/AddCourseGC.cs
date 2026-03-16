namespace LearningManagementSystem.GC
{
    public class CourseGC
    {
        public int CourseId { get; set; }
        public int SocietyId { get; set; }
        public int InstituteId { get; set; }
        public int StreamId { get; set; }
        public string CourseName { get; set; }
        public string CourseCode { get; set; }
        public bool IsActive { get; set; }
    }
}