using System;
using System.Data;

namespace LMS_Project.Student
{
    public partial class Profile : System.Web.UI.Page
    {
        StudentProfileBL bl = new StudentProfileBL();
        private int _userId;

        protected void Page_Load(object sender, EventArgs e)
        {
            _userId = Convert.ToInt32(Session["UserId"]);

            if (!IsPostBack)
            {
                hfEditMode.Value = "0";
                LoadProfile();
            }
        }

        // ── Load and bind all profile data ──────────────────────
        private void LoadProfile()
        {
            DataTable dt = bl.GetProfile(_userId);
            if (dt.Rows.Count == 0) return;

            DataRow r = dt.Rows[0];

            // Hero
            lblHeroName.Text = r["FullName"].ToString();
            lblHeroRoll.Text = r["RollNumber"] != DBNull.Value
                                 ? "Roll: " + r["RollNumber"]
                                 : "Roll: —";
            lblHeroCourse.Text = r["CourseName"] != DBNull.Value
                                 ? r["CourseName"].ToString() : "—";
            lblHeroEmail.Text = r["Email"].ToString();

            // Profile photo
            string photo = r["ProfileImage"] != DBNull.Value
                           ? r["ProfileImage"].ToString() : "";
            imgPhoto.ImageUrl = string.IsNullOrEmpty(photo)
                ? ResolveUrl("~/assets/images/default-user.png")
                : ResolveUrl(photo);

            // Academic strip
            lblStream.Text = Val(r, "StreamName");
            lblCourse.Text = Val(r, "CourseName");
            lblLevel.Text = Val(r, "LevelName");
            lblSemester.Text = Val(r, "SemesterName");
            lblSection.Text = Val(r, "SectionName");
            lblSession.Text = Val(r, "SessionName");

            // Personal view
            lblFullName.Text = r["FullName"].ToString();
            lblUsername.Text = r["Username"].ToString();
            lblEmail.Text = r["Email"].ToString();
            lblGender.Text = Val(r, "Gender");
            lblDOB.Text = r["DOB"] != DBNull.Value
                               ? Convert.ToDateTime(r["DOB"]).ToString("dd MMM yyyy") : "—";
            lblContact.Text = Val(r, "ContactNo");
            lblFather.Text = Val(r, "FatherName");
            lblMother.Text = Val(r, "MotherName");

            // Address view
            lblAddress.Text = Val(r, "Address");
            lblCity.Text = Val(r, "City");
            lblCountry.Text = Val(r, "Country");
            lblPincode.Text = r["Pincode"] != DBNull.Value
                               ? r["Pincode"].ToString() : "—";
            lblEmerName.Text = Val(r, "EmergencyContactName");
            lblEmerNo.Text = Val(r, "EmergencyContactNo");

            // About view
            lblSkills.Text = ValOrEmpty(r, "Skills");
            lblHobbies.Text = ValOrEmpty(r, "Hobbies");
            lblDescription.Text = ValOrEmpty(r, "Description");

            // Populate edit fields
            txtFullName.Text = r["FullName"].ToString();
            txtEmail.Text = r["Email"].ToString();
            txtContact.Text = r["ContactNo"] != DBNull.Value ? r["ContactNo"].ToString() : "";
            txtFather.Text = r["FatherName"] != DBNull.Value ? r["FatherName"].ToString() : "";
            txtMother.Text = r["MotherName"] != DBNull.Value ? r["MotherName"].ToString() : "";
            txtAddress.Text = r["Address"] != DBNull.Value ? r["Address"].ToString() : "";
            txtCity.Text = r["City"] != DBNull.Value ? r["City"].ToString() : "";
            txtCountry.Text = r["Country"] != DBNull.Value ? r["Country"].ToString() : "";
            txtPincode.Text = r["Pincode"] != DBNull.Value ? r["Pincode"].ToString() : "";
            txtEmerName.Text = r["EmergencyContactName"] != DBNull.Value ? r["EmergencyContactName"].ToString() : "";
            txtEmerNo.Text = r["EmergencyContactNo"] != DBNull.Value ? r["EmergencyContactNo"].ToString() : "";
            txtSkills.Text = r["Skills"] != DBNull.Value ? r["Skills"].ToString() : "";
            txtHobbies.Text = r["Hobbies"] != DBNull.Value ? r["Hobbies"].ToString() : "";
            txtDescription.Text = r["Description"] != DBNull.Value ? r["Description"].ToString() : "";
        }

        // ── Toggle edit mode ─────────────────────────────────────
        protected void btnToggleEdit_Click(object sender, EventArgs e)
        {
            hfEditMode.Value = "1";
            pnlSaveBar.Visible = true;
            btnToggleEdit.Text = "<i class='fas fa-times me-1'></i>Cancel";
            LoadProfile();
        }

        protected void btnCancelEdit_Click(object sender, EventArgs e)
        {
            hfEditMode.Value = "0";
            pnlSaveBar.Visible = false;
            LoadProfile();
        }

        // ── Save profile ─────────────────────────────────────────
        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtFullName.Text))
            {
                ShowMsg("Full name is required.", false);
                hfEditMode.Value = "1";
                return;
            }

            try
            {
                bl.UpdateProfile(
                    _userId,
                    txtFullName.Text.Trim(),
                    txtFather.Text.Trim(),
                    txtMother.Text.Trim(),
                    txtContact.Text.Trim(),
                    txtEmerName.Text.Trim(),
                    txtEmerNo.Text.Trim(),
                    txtAddress.Text.Trim(),
                    txtCity.Text.Trim(),
                    txtCountry.Text.Trim(),
                    txtPincode.Text.Trim(),
                    txtSkills.Text.Trim(),
                    txtHobbies.Text.Trim(),
                    txtDescription.Text.Trim(),
                    txtEmail.Text.Trim()
                );

                hfEditMode.Value = "0";
                pnlSaveBar.Visible = false;
                ShowMsg("Profile updated successfully! ✅", true);
                LoadProfile();
            }
            catch (Exception ex)
            {
                ShowMsg("Error: " + ex.Message, false);
                hfEditMode.Value = "1";
            }
        }

        // ── Upload profile photo ─────────────────────────────────
        protected void btnUploadPhoto_Click(object sender, EventArgs e)
        {
            if (!fuPhoto.HasFile)
            {
                ShowMsg("Please select a photo.", false);
                return;
            }

            string path = bl.UpdateProfilePhoto(_userId, fuPhoto.PostedFile, Server);

            if (path == null)
                ShowMsg("Invalid file. Use JPG/PNG/GIF under 2 MB.", false);
            else
            {
                ShowMsg("Profile photo updated! ✅", true);
                LoadProfile();
            }
        }

        // ── Helpers ──────────────────────────────────────────────
        private string Val(DataRow r, string col)
        {
            return r[col] != DBNull.Value && !string.IsNullOrEmpty(r[col].ToString())
                   ? r[col].ToString() : "—";
        }

        private string ValOrEmpty(DataRow r, string col)
        {
            return r[col] != DBNull.Value ? r[col].ToString() : "";
        }

        private void ShowMsg(string msg, bool success)
        {
            lblMsg.Text = msg;
            lblMsg.CssClass = "profile-alert d-block " + (success ? "alert-success" : "alert-error");
            lblMsg.Visible = true;
        }
    }
}