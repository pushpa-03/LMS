using System;

namespace LMS_Project.GC
{
    public class TeacherStudentGC
    {
        // ── Identity ──────────────────────────────────────
        public int UserId { get; set; }
        public int SocietyId { get; set; }
        public int InstituteId { get; set; }
        public int SessionId { get; set; }

        // ── Academic ──────────────────────────────────────
        public int? StreamId { get; set; }
        public int? CourseId { get; set; }
        public int? LevelId { get; set; }
        public int? SemesterId { get; set; }
        public int? SectionId { get; set; }

        public string RollNumber { get; set; }
        public string StreamName { get; set; }
        public string CourseName { get; set; }
        public string LevelName { get; set; }
        public string SemesterName { get; set; }

        // ── Login Info ────────────────────────────────────
        public string Username { get; set; }
        public string Email { get; set; }

        // ── Personal Info ─────────────────────────────────
        public string FullName { get; set; }
        public string Gender { get; set; }
        public DateTime? DOB { get; set; }
        public string ContactNo { get; set; }
        public string Address { get; set; }
        public string City { get; set; }
        public int? Pincode { get; set; }

        public string EmergencyContactName { get; set; }
        public string EmergencyContactNo { get; set; }

        public string Skills { get; set; }
        public string Hobbies { get; set; }
        public string ProfileImage { get; set; }

        // ── Attendance Summary ────────────────────────────
        public int Present { get; set; }
        public int Absent { get; set; }
        public double AttendancePercent =>
            (Present + Absent) == 0 ? 0 :
            Math.Round((double)Present / (Present + Absent) * 100, 1);

        // ── Progress Summary ──────────────────────────────
        public int VideosCompleted { get; set; }
        public int AssignmentsSubmitted { get; set; }
        public int QuizAttempts { get; set; }
    }

    public class TeacherStudentSubjectGC
    {
        public int SubjectId { get; set; }
        public string SubjectName { get; set; }
        public string TeacherName { get; set; }
        public int Progress { get; set; }
    }

    public class TeacherStudentActivityGC
    {
        public string ActivityType { get; set; }
        public DateTime ActionTime { get; set; }
    }
}