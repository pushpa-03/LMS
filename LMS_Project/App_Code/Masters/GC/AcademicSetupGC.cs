namespace LearningManagementSystem.GC
{
    public class AcademicSetupGC
    {
        public int Id { get; set; }
        public int SocietyId { get; set; }
        public int InstituteId { get; set; }
        public string Name { get; set; }
        public string Type { get; set; } // Level / Semester / Section
    }
}