using System;
using System.Data.SqlClient;
using System.Security.Cryptography;
using System.Text;
using System.Web;
using System.Web.UI.WebControls;

namespace LMS
{
    public partial class Default : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack && Request.Cookies["LMS_User"] != null)
            {
                txtUsername.Text = Request.Cookies["LMS_User"].Value;
                chkRemember.Checked = true;
            }
        }
        protected void btnLogin_Click(object sender, EventArgs e)
        {
            lblMsg.Text = "";

            string username = txtUsername.Text.Trim();
            string password = txtPassword.Text.Trim();

            if (username == "" || password == "")
            {
                lblMsg.Text = "Username and password required.";
                return;
            }

            byte[] passwordHash = HashPassword(password);

            LoginBL bl = new LoginBL();
            LoginGC user = bl.ValidateUser(username, passwordHash);

            if (user == null)
            {
                lblMsg.Text = "Invalid username or password.";
                return;
            }

            if (!user.IsActive)
            {
                lblMsg.Text = "Your account is inactive. Contact administrator.";
                return;
            }

            // Set Session
            Session["UserId"] = user.UserId;
            Session["Username"] = user.Username;
            Session["Role"] = user.RoleName;

            Session["SocietyId"] = user.SocietyId;
            Session["SocietyName"] = user.SocietyName;

            Session["InstituteId"] = user.InstituteId;
            Session["InstituteName"] = user.InstituteName;
            Session["LogoURL"] = user.LogoURL;

            if (!string.IsNullOrEmpty(user.InstituteName))
                Session["ActiveInstituteName"] = user.InstituteName;
            else
                Session["ActiveInstituteName"] = "LMS Management";

            // Cookie
            if (chkRemember.Checked)
            {
                HttpCookie ck = new HttpCookie("LMS_User", username);
                ck.Expires = DateTime.Now.AddDays(7);
                Response.Cookies.Add(ck);
            }
            else
            {
                if (Request.Cookies["LMS_User"] != null)
                    Response.Cookies["LMS_User"].Expires = DateTime.Now.AddDays(-1);
            }

            // Update login audit
            bl.UpdateLoginAudit(username);

            // Redirect
            if (user.RoleName == "SuperAdmin")
                Response.Redirect("~/SuperAdmin/AddSociety.aspx", false);

            else if (user.RoleName == "Admin" || user.RoleName == "SuperAdmin")
                Response.Redirect("~/Admin/Dashboard.aspx", false);

            else if (user.RoleName == "Teacher")
                Response.Redirect("~/Teacher/TeacherDashboard.aspx", false);

            else if (user.RoleName == "Student")
                Response.Redirect("~/Student/Dashboard.aspx", false);

            else if (user.RoleName == "Parent")
                Response.Redirect("~/Parent/ParentDashboard.aspx", false);
        }

        private byte[] HashPassword(string password)
        {
            using (SHA256 sha = SHA256.Create())
            {
                return sha.ComputeHash(Encoding.UTF8.GetBytes(password));
            }
        }
    }
}
