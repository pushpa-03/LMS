using System;
public class CalendarGC
{
    public int EventId { get; set; }
    public int? UserId { get; set; }
    public int? SocietyId { get; set; }
    public int? InstituteId { get; set; }
    public int? SubjectId { get; set; }      // ✅ NEW
    public string Title { get; set; }
    public string EventType { get; set; }
    public DateTime StartTime { get; set; }
    public DateTime EndTime { get; set; }
    public bool IsAllDay { get; set; }
}