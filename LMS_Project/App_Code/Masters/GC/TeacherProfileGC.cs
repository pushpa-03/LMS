using System;

namespace LMS_Project.GC
{
    public class TeacherProfileGC
    {
        public int UserId { get; set; }

        // Users table
        public string Username { get; set; }
        public string Email { get; set; }

        // UserProfile table
        public string FullName { get; set; }
        public string Gender { get; set; }
        public DateTime DOB { get; set; }
        public string ContactNo { get; set; }
        public string Address { get; set; }
        public string City { get; set; }
        public string Country { get; set; }
        public int? Pincode { get; set; }
        // TeacherDetails table
        public string EmployeeId { get; set; }
        public int? ExperienceYears { get; set; }
        public string Qualification { get; set; }
        public string Designation { get; set; }
        public string StreamName { get; set; }

        public string ProfileImage { get; set; }
    }
}