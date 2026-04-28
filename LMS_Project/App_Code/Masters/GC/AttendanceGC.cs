using System;

/// <summary>
/// Global Constants for Attendance Module
/// </summary>
public class AttendanceGC
{
    // Attendance Status Values
    public const string STATUS_PRESENT = "Present";
    public const string STATUS_ABSENT = "Absent";
    public const string STATUS_LEAVE = "Leave";

    // Session Keys
    public const string SESSION_USER_ID = "UserId";
    public const string SESSION_SOCIETY_ID = "SocietyId";
    public const string SESSION_INSTITUTE_ID = "InstituteId";
    public const string SESSION_ROLE = "Role";

    // Role Names
    public const string ROLE_TEACHER = "Teacher";

    // Stored procedure / query column names returned from DB
    public const string COL_SUBJECT_ID = "SubjectId";
    public const string COL_SUBJECT_NAME = "SubjectName";
    public const string COL_SUBJECT_CODE = "SubjectCode";
    public const string COL_SESSION_ID = "SessionId";
    public const string COL_SESSION_NAME = "SessionName";
    public const string COL_SECTION_ID = "SectionId";
    public const string COL_SECTION_NAME = "SectionName";

    public const string COL_USER_ID = "UserId";
    public const string COL_FULL_NAME = "FullName";
    public const string COL_ROLL_NUMBER = "RollNumber";
    public const string COL_STATUS = "Status";
    public const string COL_DATE = "Date";

    public const string COL_ATTENDANCE_ID = "AttendanceId";
    public const string COL_MARKED_BY = "MarkedBy";
    public const string COL_MARKED_ON = "MarkedOn";

    // Summary columns
    public const string COL_TOTAL_CLASSES = "TotalClasses";
    public const string COL_PRESENT_COUNT = "PresentCount";
    public const string COL_ABSENT_COUNT = "AbsentCount";
    public const string COL_LEAVE_COUNT = "LeaveCount";
    public const string COL_PERCENTAGE = "Percentage";

    // Date format
    public const string DATE_FORMAT = "yyyy-MM-dd";

    // Messages
    public const string MSG_ATTENDANCE_SAVED = "Attendance saved successfully.";
    public const string MSG_ATTENDANCE_UPDATED = "Attendance updated successfully.";
    public const string MSG_NO_STUDENTS = "No students found for the selected subject and section.";
    public const string MSG_ALREADY_MARKED = "Attendance already marked for this date. You can update it.";
    public const string MSG_SELECT_SUBJECT = "Please select a subject.";
    public const string MSG_SELECT_DATE = "Please select a date.";
    public const string MSG_FUTURE_DATE = "Cannot mark attendance for a future date.";
    public const string MSG_ERROR = "An error occurred. Please try again.";
}