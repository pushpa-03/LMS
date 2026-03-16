using System;
using System.Data;
using System.Data.SqlClient;
using System.Security.Cryptography;
using System.Text;
using System.Configuration;
using System.Web.UI.WebControls;

namespace LMS
{
    public partial class RegisterUser : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadSocieties();
            }
        }

        private void LoadSocieties()
        {
            RegisterUserBL bl = new RegisterUserBL();
            DataTable dt = bl.GetSocieties();

            ddlSociety.DataSource = dt;
            ddlSociety.DataTextField = "SocietyName";
            ddlSociety.DataValueField = "SocietyId";
            ddlSociety.DataBind();

            ddlSociety.Items.Insert(0, new ListItem("-- Select Society --", "0"));
        }

        protected void ddlSociety_SelectedIndexChanged(object sender, EventArgs e)
        {
            ddlInstitute.Items.Clear();

            if (ddlSociety.SelectedValue == "0")
            {
                ddlInstitute.Items.Insert(0, new ListItem("-- Select Society First --", "0"));
                return;
            }

            RegisterUserBL bl = new RegisterUserBL();
            DataTable dt = bl.GetInstitutes(Convert.ToInt32(ddlSociety.SelectedValue));

            ddlInstitute.DataSource = dt;
            ddlInstitute.DataTextField = "InstituteName";
            ddlInstitute.DataValueField = "InstituteId";
            ddlInstitute.DataBind();

            ddlInstitute.Items.Insert(0, new ListItem("-- Select Institute --", "0"));
        }
        protected void btnRegister_Click(object sender, EventArgs e)
        {
            lblMsg.CssClass = "text-danger small mb-3 d-block";
            lblMsg.Text = "";

            if (string.IsNullOrWhiteSpace(txtUsername.Text) ||
                string.IsNullOrWhiteSpace(txtEmail.Text) ||
                string.IsNullOrWhiteSpace(txtPassword.Text))
            {
                lblMsg.Text = "All fields are required.";
                return;
            }

            if (txtPassword.Text != txtConfirm.Text)
            {
                lblMsg.Text = "Passwords do not match.";
                return;
            }

            if (ddlSociety.SelectedValue == "0" || ddlInstitute.SelectedValue == "0")
            {
                lblMsg.Text = "Please select a valid Society and Institute.";
                return;
            }

            try
            {
                RegisterUserBL bl = new RegisterUserBL();

                int roleId = bl.GetAdminRoleId();

                if (roleId == 0)
                {
                    lblMsg.Text = "Required roles not found. Contact system administrator.";
                    return;
                }

                int exists = bl.CheckUsernameExists(txtUsername.Text.Trim());

                if (exists > 0)
                {
                    lblMsg.Text = "Username already exists.";
                    return;
                }

                RegisterUserGC obj = new RegisterUserGC();
                obj.Username = txtUsername.Text.Trim();
                obj.PasswordHash = Hash(txtPassword.Text);
                obj.Email = txtEmail.Text.Trim();
                obj.RoleId = roleId;
                obj.SocietyId = Convert.ToInt32(ddlSociety.SelectedValue);
                obj.InstituteId = Convert.ToInt32(ddlInstitute.SelectedValue);

                bl.InsertUser(obj);

                lblMsg.CssClass = "text-success small mb-3 d-block";
                lblMsg.Text = "Registration successful. Please login.";

                ClearForm();
            }
            catch
            {
                lblMsg.Text = "Registration failed. Please try again.";
            }
        }
        private byte[] Hash(string input)
        {
            using (SHA256 sha = SHA256.Create())
            {
                return sha.ComputeHash(Encoding.UTF8.GetBytes(input));
            }
        }

        private void ClearForm()
        {
            txtUsername.Text = "";
            txtEmail.Text = "";
            txtPassword.Text = "";
            txtConfirm.Text = "";
            ddlSociety.SelectedIndex = 0;
            ddlInstitute.Items.Clear();
            ddlInstitute.Items.Insert(0, new ListItem("-- Select Society First --", "0"));
        }
    }
}
