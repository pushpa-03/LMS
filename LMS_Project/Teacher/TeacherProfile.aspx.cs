using LMS_Project.BL;
using LMS_Project.GC;
using System;

namespace LMS_Project.Teacher
{
    public partial class TeacherProfile : System.Web.UI.Page
    {
        TeacherProfileBL objBL = new TeacherProfileBL();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadProfile();
            }
        }

        private void LoadProfile()
        {
            int userId = Convert.ToInt32(Session["UserId"]);
            TeacherProfileGC obj = objBL.GetTeacherProfile(userId);

            txtFullName.Text = obj.FullName;
            txtEmail.Text = obj.Email;
            txtContact.Text = obj.ContactNo;
            txtAddress.Text = obj.Address;
            txtCity.Text = obj.City;
            txtCountry.Text = obj.Country;
            txtPincode.Text = obj.Pincode?.ToString();
            txtQualification.Text = obj.Qualification;
            txtExperience.Text = obj.ExperienceYears?.ToString();
            txtDesignation.Text = obj.Designation;

            // ── NEW: populate avatar block ──
            lblDisplayName.Text = obj.FullName;
            lblDisplayEmail.Text = obj.Email;
            lblDisplayDesignation.Text = obj.Designation;
            lblInitialBig.Text = obj.FullName?.Length > 0
                                         ? obj.FullName.Substring(0, 1).ToUpper()
                                         : "T";
        }

        protected void btnEdit_Click(object sender, EventArgs e)
        {
            SetEditMode(true);
        }

        protected void btnUpdate_Click(object sender, EventArgs e)
        {
            TeacherProfileGC obj = new TeacherProfileGC();

            obj.UserId = Convert.ToInt32(Session["UserId"]);
            obj.FullName = txtFullName.Text;
            obj.ContactNo = txtContact.Text;
            obj.Address = txtAddress.Text;
            obj.City = txtCity.Text;
            obj.Country = txtCountry.Text;

            obj.Pincode = string.IsNullOrEmpty(txtPincode.Text)
                ? (int?)null
                : Convert.ToInt32(txtPincode.Text);

            obj.Qualification = txtQualification.Text;

            obj.ExperienceYears = string.IsNullOrEmpty(txtExperience.Text)
                ? (int?)null
                : Convert.ToInt32(txtExperience.Text);

            obj.Designation = txtDesignation.Text;

            objBL.UpdateTeacherProfile(obj);
            pnlSuccess.Visible = true;
            SetEditMode(false);
            LoadProfile();
        }

        private void SetEditMode(bool enable)
        {
            txtFullName.ReadOnly = !enable;
            txtContact.ReadOnly = !enable;
            txtAddress.ReadOnly = !enable;
            txtCity.ReadOnly = !enable;
            txtCountry.ReadOnly = !enable;
            txtPincode.ReadOnly = !enable;
            txtQualification.ReadOnly = !enable;
            txtExperience.ReadOnly = !enable;
            txtDesignation.ReadOnly = !enable;

            btnUpdate.Visible = enable;
            btnEdit.Visible = !enable;
        }
    }
}