using System;

public class TeacherGC
{
    // Users Table
    public int UserId { get; set; }
    public string Username { get; set; }
    public string Email { get; set; }
    public int RoleId { get; set; }
    public int SocietyId { get; set; }
    public int InstituteId { get; set; }
    public bool IsActive { get; set; }

    // UserProfile Table
    public string FullName { get; set; }
    public string Gender { get; set; }
    public DateTime DOB { get; set; }
    public string ContactNo { get; set; }

    // TeacherDetails Table
    public string EmployeeId { get; set; }
    public int ExperienceYears { get; set; }
    public string Qualification { get; set; }
    public string Designation { get; set; }

    public int StreamId { get; set; }
}