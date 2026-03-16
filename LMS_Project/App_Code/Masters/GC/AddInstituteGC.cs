using System;

namespace LMS.GC
{
    public class InstituteGC
    {
        public int InstituteId { get; set; }
        public int SocietyId { get; set; }
        public string SocietyName { get; set; }

        public string InstituteName { get; set; }
        public string InstituteCode { get; set; }
        public string EducationType { get; set; }
        public string LogoURL { get; set; }
        public string Phone { get; set; }
        public string Email { get; set; }
        public string ShortName { get; set; }

        public bool IsActive { get; set; }
    }
}