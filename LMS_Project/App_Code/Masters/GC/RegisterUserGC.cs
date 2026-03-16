using System;

public class RegisterUserGC
{
    public int UserId { get; set; }

    public string Username { get; set; }
    public byte[] PasswordHash { get; set; }
    public string Email { get; set; }

    public int RoleId { get; set; }

    public int SocietyId { get; set; }
    public int InstituteId { get; set; }

    public bool IsActive { get; set; }
    public bool IsFirstLogin { get; set; }
}