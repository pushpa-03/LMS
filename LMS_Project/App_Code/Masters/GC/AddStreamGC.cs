using System;

namespace LMS.GC
{
    public class StreamGC
    {
        public int StreamId { get; set; }
        public int SocietyId { get; set; }
        public int InstituteId { get; set; }

        public string StreamName { get; set; }

        public bool IsActive { get; set; }
    }
}