using LearningManagementSystem.BL;
using System;
using System.Data;
using System.IO;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace LearningManagementSystem.Admin
{
    public partial class AdminProfile : BasePage
    {
        private readonly AdminProfileBL _bl = new AdminProfileBL();

        // ── Exposed to ASPX ──────────────────────────────────────────────────
        protected string AdminName = "Admin";
        protected string AdminInitials = "A";
        protected string AdminRole = "Admin";
        protected string AvatarBg = "#2563eb";
        protected string ProfileImagePath = "";
        protected bool HasPhoto = false;

        protected int StatStudents = 0;
        protected int StatTeachers = 0;
        protected int StatSubjects = 0;
        protected int StatVideos = 0;
        protected int StatAssignments = 0;
        protected string StatAttendance = "—";

        private static readonly string[] AvatarColors = {
            "#2563eb","#7c3aed","#059669","#d97706","#0891b2","#dc2626"
        };

        // ══════════════════════════════════════════════════════════════════════
        //  PAGE LOAD
        // ══════════════════════════════════════════════════════════════════════
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadProfile();
                LoadStats();
                LoadActivity();
            }
        }

        // ── LOAD PROFILE ────────────────────────────────────────────────────
        private void LoadProfile()
        {
            DataTable dt = _bl.GetAdminProfile(UserId);
            if (dt.Rows.Count == 0) return;
            DataRow r = dt.Rows[0];

            AdminName = r["FullName"].ToString();
            AdminRole = r["RoleName"].ToString();
            ProfileImagePath = r["ProfileImage"].ToString();
            HasPhoto = !string.IsNullOrWhiteSpace(ProfileImagePath);

            // Initials
            string[] parts = AdminName.Trim().Split(' ');
            AdminInitials = parts.Length == 1
                ? AdminName.Substring(0, Math.Min(2, AdminName.Length)).ToUpper()
                : (parts[0][0].ToString() + parts[parts.Length - 1][0]).ToUpper();
            AvatarBg = AvatarColors[Math.Abs(AdminName.GetHashCode()) % AvatarColors.Length];

            // Bind form fields
            txtFullName.Text = H(r["FullName"]);
            txtEmail.Text = H(r["Email"]);
            txtUsername.Text = H(r["Username"]);
            txtGender.SelectedValue = r["Gender"].ToString();
            txtDOB.Text = r["DOB"].ToString();
            txtContact.Text = H(r["ContactNo"]);
            txtEmgName.Text = H(r["EmergencyContactName"]);
            txtEmgNo.Text = H(r["EmergencyContactNo"]);
            txtAddress.Text = H(r["Address"]);
            txtCity.Text = H(r["City"]);
            txtCountry.Text = H(r["Country"]);
            txtPincode.Text = H(r["Pincode"]);
            txtSkills.Text = H(r["Skills"]);
            txtBio.Text = H(r["Bio"]);
            txtFather.Text = H(r["FatherName"]);
            txtMother.Text = H(r["MotherName"]);

            // Read-only info labels
            lblInstitute.Text = H(r["InstituteName"]);
            lblSociety.Text = H(r["SocietyName"]);
            lblJoined.Text = FormatDate(r["JoinedDate"]);
            lblLastLogin.Text = FormatDateTime(r["LastLogin"]);
            lblCreated.Text = FormatDate(r["CreatedOn"]);
            lblFirstLogin.Text = Convert.ToBoolean(r["IsFirstLogin"]) ? "Yes — password not yet changed" : "No";
        }

        // ── LOAD STATS ──────────────────────────────────────────────────────
        private void LoadStats()
        {
            DataTable dt = _bl.GetAdminStats(InstituteId, SessionId);
            if (dt.Rows.Count == 0) return;
            DataRow r = dt.Rows[0];

            StatStudents = Convert.ToInt32(r["TotalStudents"]);
            StatTeachers = Convert.ToInt32(r["TotalTeachers"]);
            StatSubjects = Convert.ToInt32(r["TotalSubjects"]);
            StatVideos = Convert.ToInt32(r["TotalVideos"]);
            StatAssignments = Convert.ToInt32(r["TotalAssignments"]);

            double att = 0;
            double.TryParse(r["AvgAttendance"].ToString(), out att);
            StatAttendance = att.ToString("F1") + "%";
        }

        // ── LOAD ACTIVITY ───────────────────────────────────────────────────
        private void LoadActivity()
        {
            DataTable dt = _bl.GetActivityLog(UserId, SessionId);
            rptActivity.DataSource = dt;
            rptActivity.DataBind();
        }

        // ══════════════════════════════════════════════════════════════════════
        //  SAVE PROFILE
        // ══════════════════════════════════════════════════════════════════════
        protected void btnSaveProfile_Click(object sender, EventArgs e)
        {
            bool ok = _bl.UpdateAdminProfile(
                UserId, SocietyId, InstituteId, SessionId,
                txtFullName.Text.Trim(),
                txtGender.SelectedValue,
                txtDOB.Text.Trim(),
                txtContact.Text.Trim(),
                txtEmgName.Text.Trim(),
                txtEmgNo.Text.Trim(),
                txtAddress.Text.Trim(),
                txtCity.Text.Trim(),
                txtCountry.Text.Trim(),
                txtPincode.Text.Trim(),
                txtSkills.Text.Trim(),
                txtBio.Text.Trim(),
                txtFather.Text.Trim(),
                txtMother.Text.Trim()
            );

            // Update session display name
            if (ok && !string.IsNullOrWhiteSpace(txtFullName.Text))
                Session["AdminName"] = txtFullName.Text.Trim();

            ShowToast(ok ? "Profile updated successfully!" : "Failed to update profile.", ok);
            if (ok) { LoadProfile(); LoadStats(); }
        }

        // ══════════════════════════════════════════════════════════════════════
        //  SAVE EMAIL
        // ══════════════════════════════════════════════════════════════════════
        protected void btnSaveEmail_Click(object sender, EventArgs e)
        {
            string newEmail = txtNewEmail.Text.Trim();
            if (string.IsNullOrWhiteSpace(newEmail))
            {
                ShowToast("Please enter a valid email address.", false); return;
            }
            bool ok = _bl.UpdateEmail(UserId, newEmail);
            ShowToast(ok ? "Email updated successfully!" : "Email already in use by another account.", ok);
            if (ok) { txtEmail.Text = newEmail; txtNewEmail.Text = ""; }
        }

        // ══════════════════════════════════════════════════════════════════════
        //  CHANGE PASSWORD
        // ══════════════════════════════════════════════════════════════════════
        protected void btnChangePassword_Click(object sender, EventArgs e)
        {
            string current = txtCurrentPwd.Text;
            string newPwd = txtNewPwd.Text;
            string confirm = txtConfirmPwd.Text;

            if (string.IsNullOrWhiteSpace(current) || string.IsNullOrWhiteSpace(newPwd))
            {
                ShowToast("Please fill in all password fields.", false); return;
            }
            if (newPwd != confirm)
            {
                ShowToast("New password and confirm password do not match.", false); return;
            }
            if (newPwd.Length < 8)
            {
                ShowToast("Password must be at least 8 characters.", false); return;
            }
            if (!_bl.VerifyCurrentPassword(UserId, current))
            {
                ShowToast("Current password is incorrect.", false); return;
            }
            bool ok = _bl.ChangePassword(UserId, newPwd);
            ShowToast(ok ? "Password changed successfully!" : "Failed to change password.", ok);
            if (ok) { txtCurrentPwd.Text = txtNewPwd.Text = txtConfirmPwd.Text = ""; }
        }

        // ══════════════════════════════════════════════════════════════════════
        //  UPLOAD PHOTO
        // ══════════════════════════════════════════════════════════════════════
        protected void btnUploadPhoto_Click(object sender, EventArgs e)
        {
            if (!fuPhoto.HasFile)
            {
                ShowToast("Please select a photo to upload.", false); return;
            }

            string ext = Path.GetExtension(fuPhoto.FileName).ToLower();
            if (ext != ".jpg" && ext != ".jpeg" && ext != ".png" && ext != ".webp")
            {
                ShowToast("Only JPG, PNG, or WEBP files are allowed.", false); return;
            }
            if (fuPhoto.PostedFile.ContentLength > 2 * 1024 * 1024)
            {
                ShowToast("File size must be under 2 MB.", false); return;
            }

            string folder = Server.MapPath("~/Uploads/ProfilePhotos/");
            if (!Directory.Exists(folder)) Directory.CreateDirectory(folder);

            string fileName = $"admin_{UserId}_{Guid.NewGuid():N}{ext}";
            string savePath = Path.Combine(folder, fileName);
            fuPhoto.SaveAs(savePath);

            string dbPath = "~/Uploads/ProfilePhotos/" + fileName;
            bool ok = _bl.UpdateProfilePhoto(UserId, dbPath);

            ShowToast(ok ? "Profile photo updated!" : "Failed to save photo.", ok);
            if (ok) { LoadProfile(); }
        }

        // ══════════════════════════════════════════════════════════════════════
        //  HELPERS
        // ══════════════════════════════════════════════════════════════════════
        private void ShowToast(string msg, bool success)
        {
            hfToastMsg.Value = msg;
            hfToastType.Value = success ? "success" : "error";
            ScriptManager.RegisterStartupScript(this, GetType(), "toast",
                $"showToast('{msg.Replace("'", "\\'")}','{(success ? "success" : "error")}');", true);
        }

        protected string FormatDate(object v)
            => v != null && v != DBNull.Value && DateTime.TryParse(v.ToString(), out DateTime d)
               ? d.ToString("dd MMM yyyy") : "—";

        protected string FormatDateTime(object v)
            => v != null && v != DBNull.Value && DateTime.TryParse(v.ToString(), out DateTime d)
               ? d.ToString("dd MMM yyyy, hh:mm tt") : "Never";

        protected string H(object v)
            => System.Web.HttpUtility.HtmlEncode(v?.ToString() ?? "");

        protected string ActivityIcon(object t)
        {
            switch (t?.ToString())
            {
                case "StudentAdded": return "fa-user-plus";
                case "TeacherAdded": return "fa-chalkboard-teacher";
                case "VideoUploaded": return "fa-video";
                case "AssignmentAdded": return "fa-file-alt";
                case "Login": return "fa-sign-in-alt";
                case "StudentReEnrolled": return "fa-sync";
                case "ProfileUpdated": return "fa-user-edit";
                default: return "fa-circle";
            }
        }

        protected string ActivityColor(object t)
        {
            switch (t?.ToString())
            {
                case "StudentAdded": return "#2563eb";
                case "TeacherAdded": return "#059669";
                case "VideoUploaded": return "#7c3aed";
                case "AssignmentAdded": return "#d97706";
                case "Login": return "#0891b2";
                case "StudentReEnrolled": return "#db2777";
                default: return "#94a3b8";
            }
        }
    }
}