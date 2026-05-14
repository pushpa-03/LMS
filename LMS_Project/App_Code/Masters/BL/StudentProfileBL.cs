using System;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Web;

public class StudentProfileBL
{
    DataLayer dl = new DataLayer();

    // ============================================================
    // ✅ 1. Get full profile
    // ============================================================
    public DataTable GetProfile(int userId)
    {
        SqlCommand cmd = new SqlCommand(@"
        SELECT
            U.UserId,
            U.Username,
            U.Email,
            UP.FullName,
            UP.FatherName,
            UP.MotherName,
            UP.Gender,
            UP.DOB,
            UP.ContactNo,
            UP.EmergencyContactName,
            UP.EmergencyContactNo,
            UP.Address,
            UP.City,
            UP.Country,
            UP.Pincode,
            UP.Skills,
            UP.Hobbies,
            UP.Description,
            UP.ProfileImage,
            SAD.RollNumber,
            ST.StreamName,
            C.CourseName,
            SL.LevelName,
            SM.SemesterName,
            SC.SectionName,
            SESS.SessionName
        FROM Users U
        JOIN UserProfile UP ON U.UserId = UP.UserId
        LEFT JOIN StudentAcademicDetails SAD ON U.UserId    = SAD.UserId
        LEFT JOIN Streams      ST   ON SAD.StreamId   = ST.StreamId
        LEFT JOIN Courses      C    ON SAD.CourseId   = C.CourseId
        LEFT JOIN StudyLevels  SL   ON SAD.LevelId    = SL.LevelId
        LEFT JOIN Semesters    SM   ON SAD.SemesterId = SM.SemesterId
        LEFT JOIN Sections     SC   ON SAD.SectionId  = SC.SectionId
        LEFT JOIN AcademicSessions SESS ON SAD.SessionId = SESS.SessionId
        WHERE U.UserId = @UserId");

        cmd.Parameters.AddWithValue("@UserId", userId);
        return dl.GetDataTable(cmd);
    }

    // ============================================================
    // ✅ 2. Update editable profile fields
    // ============================================================
    public bool UpdateProfile(int userId,
                              string fullName, string fatherName,
                              string motherName, string contactNo,
                              string emerName, string emerNo,
                              string address, string city,
                              string country, string pincode,
                              string skills, string hobbies,
                              string description, string email)
    {
        SqlCommand upCmd = new SqlCommand(@"
        UPDATE UserProfile SET
            FullName             = @FullName,
            FatherName           = @FatherName,
            MotherName           = @MotherName,
            ContactNo            = @ContactNo,
            EmergencyContactName = @EmerName,
            EmergencyContactNo   = @EmerNo,
            Address              = @Address,
            City                 = @City,
            Country              = @Country,
            Pincode              = @Pincode,
            Skills               = @Skills,
            Hobbies              = @Hobbies,
            Description          = @Description
        WHERE UserId = @UserId");

        upCmd.Parameters.AddWithValue("@FullName", fullName ?? "");
        upCmd.Parameters.AddWithValue("@FatherName", fatherName ?? "");
        upCmd.Parameters.AddWithValue("@MotherName", motherName ?? "");
        upCmd.Parameters.AddWithValue("@ContactNo", contactNo ?? "");
        upCmd.Parameters.AddWithValue("@EmerName", emerName ?? "");
        upCmd.Parameters.AddWithValue("@EmerNo", emerNo ?? "");
        upCmd.Parameters.AddWithValue("@Address", address ?? "");
        upCmd.Parameters.AddWithValue("@City", city ?? "");
        upCmd.Parameters.AddWithValue("@Country", country ?? "");
        upCmd.Parameters.AddWithValue("@Pincode", pincode ?? "");
        upCmd.Parameters.AddWithValue("@Skills", skills ?? "");
        upCmd.Parameters.AddWithValue("@Hobbies", hobbies ?? "");
        upCmd.Parameters.AddWithValue("@Description", description ?? "");
        upCmd.Parameters.AddWithValue("@UserId", userId);
        dl.ExecuteCMD(upCmd);

        // Update email in Users table
        if (!string.IsNullOrWhiteSpace(email))
        {
            SqlCommand emailCmd = new SqlCommand(
                "UPDATE Users SET Email = @Email WHERE UserId = @UserId");
            emailCmd.Parameters.AddWithValue("@Email", email);
            emailCmd.Parameters.AddWithValue("@UserId", userId);
            dl.ExecuteCMD(emailCmd);
        }

        return true;
    }

    // ============================================================
    // ✅ 3. Upload profile photo
    // ============================================================
    public string UpdateProfilePhoto(int userId,
                                     HttpPostedFile file,
                                     HttpServerUtility server)
    {
        string ext = Path.GetExtension(file.FileName).ToLower();
        string[] valid = { ".jpg", ".jpeg", ".png", ".gif" };
        bool allowed = Array.Exists(valid, e => e == ext);

        if (!allowed || file.ContentLength > 2 * 1024 * 1024)
            return null;

        string folder = server.MapPath("~/Uploads/ProfilePhotos/");
        if (!Directory.Exists(folder))
            Directory.CreateDirectory(folder);

        string fileName = $"STU_{userId}_{DateTime.Now:yyyyMMddHHmmss}{ext}";
        string fullPath = Path.Combine(folder, fileName);
        file.SaveAs(fullPath);

        string dbPath = "../Uploads/ProfilePhotos/" + fileName;

        SqlCommand cmd = new SqlCommand(
            "UPDATE UserProfile SET ProfileImage = @Path WHERE UserId = @UserId");
        cmd.Parameters.AddWithValue("@Path", dbPath);
        cmd.Parameters.AddWithValue("@UserId", userId);
        dl.ExecuteCMD(cmd);

        return dbPath;
    }

    // ============================================================
    // ✅ 4. Change password
    // ============================================================
    public bool VerifyCurrentPassword(int userId, string currentPassword)
    {
        SqlCommand cmd = new SqlCommand(@"
        SELECT COUNT(*) FROM Users
        WHERE UserId      = @UserId
          AND PasswordHash = HASHBYTES('SHA2_256', @Password)");

        cmd.Parameters.AddWithValue("@UserId", userId);
        cmd.Parameters.AddWithValue("@Password", currentPassword);

        return Convert.ToInt32(dl.GetDataTable(cmd).Rows[0][0]) > 0;
    }

    public bool ChangePassword(int userId, string newPassword)
    {
        SqlCommand cmd = new SqlCommand(@"
        UPDATE Users SET
            PasswordHash = HASHBYTES('SHA2_256', @Password),
            IsFirstLogin = 0
        WHERE UserId = @UserId");

        cmd.Parameters.AddWithValue("@Password", newPassword);
        cmd.Parameters.AddWithValue("@UserId", userId);
        dl.ExecuteCMD(cmd);
        return true;
    }

    // ============================================================
    // ✅ 5. Notifications — full list
    // ============================================================
    public DataTable GetNotifications(int userId, int instituteId,
                                      int sessionId, string filter = "All")
    {
        SqlCommand cmd = new SqlCommand(@"
        SELECT
            NotificationId,
            Message,
            NotificationType,
            IsRead,
            CreatedOn
        FROM Notifications
        WHERE UserId      = @UserId
          AND InstituteId = @InstId
          AND SessionId   = @SessId
          AND (@Filter = 'All'
               OR (@Filter = 'Unread' AND IsRead = 0)
               OR (@Filter = 'Read'   AND IsRead = 1))
        ORDER BY CreatedOn DESC");

        cmd.Parameters.AddWithValue("@UserId", userId);
        cmd.Parameters.AddWithValue("@InstId", instituteId);
        cmd.Parameters.AddWithValue("@SessId", sessionId);
        cmd.Parameters.AddWithValue("@Filter", filter);

        return dl.GetDataTable(cmd);
    }

    // ============================================================
    // ✅ 6. Mark notification(s) as read
    // ============================================================
    public void MarkAsRead(int notificationId)
    {
        SqlCommand cmd = new SqlCommand(@"
        UPDATE Notifications SET IsRead = 1
        WHERE NotificationId = @Id");
        cmd.Parameters.AddWithValue("@Id", notificationId);
        dl.ExecuteCMD(cmd);
    }

    public void MarkAllAsRead(int userId, int instituteId, int sessionId)
    {
        SqlCommand cmd = new SqlCommand(@"
        UPDATE Notifications SET IsRead = 1
        WHERE UserId      = @UserId
          AND InstituteId = @InstId
          AND SessionId   = @SessId
          AND IsRead      = 0");
        cmd.Parameters.AddWithValue("@UserId", userId);
        cmd.Parameters.AddWithValue("@InstId", instituteId);
        cmd.Parameters.AddWithValue("@SessId", sessionId);
        dl.ExecuteCMD(cmd);
    }
}