using System;

namespace LMS_Project.GC
{
    public class TeacherReportGC
    {
        // =============================
        // BASIC USER INFO
        // =============================
        public int UserId { get; set; }
        public string Username { get; set; }
        public string FullName { get; set; }
        public string Email { get; set; }
        public string MobileNumber { get; set; }

        // =============================
        // ACADEMIC STRUCTURE
        // =============================
        public int StreamId { get; set; }
        public string StreamName { get; set; }

        public int CourseId { get; set; }
        public string CourseName { get; set; }

        public int SubjectId { get; set; }
        public string SubjectName { get; set; }

        public int AcademicYearId { get; set; }
        public string AcademicYear { get; set; }

        public int SemesterId { get; set; }
        public string SemesterName { get; set; }

        // =============================
        // PERFORMANCE & LOAD
        // =============================
        public int TotalStudents { get; set; }
        public int TotalSubjects { get; set; }
        public int TotalCourses { get; set; }

        // =============================
        // STATUS TRACKING
        // =============================
        public bool IsActive { get; set; }
        public DateTime CreatedOn { get; set; }
        public DateTime? LastLogin { get; set; }

        // =============================
        // FILTER PARAMETERS (INPUT USE)
        // =============================
        public int InstituteId { get; set; }
        public string ReportType { get; set; }

        public bool OnlyActive { get; set; }
        public bool OnlyInactive { get; set; }

        public bool OnlyWithoutCourse { get; set; }
        public bool OnlyWithoutLogin { get; set; }
        public bool OnlyZeroStudents { get; set; }
    }
}