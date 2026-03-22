using System;

namespace LearningManagementSystem.GC
{
    public class HelpRequestGC
    {
        public int HelpId { get; set; }
        public int SocietyId { get; set; }
        public int InstituteId { get; set; }
        public int UserId { get; set; }
        public string Username { get; set; }
        public string RoleName { get; set; }
        public string Question { get; set; }
        public DateTime AskedOn { get; set; }
        public bool HasReply { get; set; }
        public string ReplyText { get; set; }
        public DateTime? RepliedOn { get; set; }
    }

    public class HelpReplyGC
    {
        public int ReplyId { get; set; }
        public int HelpId { get; set; }
        public int SocietyId { get; set; }
        public int InstituteId { get; set; }
        public int AdminId { get; set; }
        public string Reply { get; set; }
        public DateTime RepliedOn { get; set; }
    }
}