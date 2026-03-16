using System;

public class LoginGC
{
    public int UserId { get; set; }
    public string Username { get; set; }
    public string RoleName { get; set; }
    public bool IsActive { get; set; }

    public int? SocietyId { get; set; }
    public string SocietyName { get; set; }

    public int? InstituteId { get; set; }
    public string InstituteName { get; set; }
    public string LogoURL { get; set; }
}