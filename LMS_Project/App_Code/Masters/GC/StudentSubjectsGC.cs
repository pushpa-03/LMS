using System;

namespace LearningManagementSystem.GC
{
    public class StudentSubjectsGC
    {
        public int SubjectId { get; set; }
        public int SocietyId { get; set; }
        public int InstituteId { get; set; }
        public int SessionId { get; set; }
        public int StreamId { get; set; }
        public int CourseId { get; set; }

        public string SubjectCode { get; set; }
        public string SubjectName { get; set; }
        public string Description { get; set; }
        public string Duration { get; set; }

        public string StreamName { get; set; }
        public string CourseName { get; set; }
        public string LevelName { get; set; }
        public string SemesterName { get; set; }

        public string TeacherName { get; set; }
        public string TeacherEmail { get; set; }

        // Computed helpers
        public int ChapterCount { get; set; }
        public int VideoCount { get; set; }
        public int MaterialCount { get; set; }
    }
}