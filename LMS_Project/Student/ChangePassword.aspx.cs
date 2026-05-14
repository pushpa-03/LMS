using System;

namespace LMS_Project.Student
{
    public partial class ChangePassword : System.Web.UI.Page
    {
        StudentProfileBL bl = new StudentProfileBL();
        private int _userId;
        private bool _isFirstLogin;

        protected void Page_Load(object sender, EventArgs e)
        {
            _userId = Convert.ToInt32(Session["UserId"]);

            // Check IsFirstLogin from DB
            System.Data.DataTable dtUser = new System.Data.DataTable();
            using (System.Data.SqlClient.SqlCommand cmd =
                new System.Data.SqlClient.SqlCommand(
                    "SELECT IsFirstLogin FROM Users WHERE UserId = @Id"))
            {
                cmd.Parameters.AddWithValue("@Id", _userId);
                DataLayer dl = new DataLayer();
                dtUser = dl.GetDataTable(cmd);
            }

            _isFirstLogin = dtUser.Rows.Count > 0 &&
                            Convert.ToBoolean(dtUser.Rows[0]["IsFirstLogin"]);

            if (!IsPostBack)
            {
                // Show first-login banner and hide current password field
                if (_isFirstLogin)
                {
                    pnlFirstLogin.Visible = true;
                    pnlCurrentPwd.Visible = false;
                }
            }
        }

        protected void btnChange_Click(object sender, EventArgs e)
        {
            string newPwd = txtNewPwd.Text.Trim();
            string confirmPwd = txtConfirmPwd.Text.Trim();

            // Basic server-side validation
            if (string.IsNullOrEmpty(newPwd) || newPwd.Length < 8)
            {
                ShowMsg("Password must be at least 8 characters.", false);
                return;
            }

            if (newPwd != confirmPwd)
            {
                ShowMsg("Passwords do not match.", false);
                return;
            }

            // Verify current password (skip for first-login)
            if (!_isFirstLogin)
            {
                string currentPwd = txtCurrentPwd.Text.Trim();
                if (string.IsNullOrEmpty(currentPwd))
                {
                    ShowMsg("Please enter your current password.", false);
                    return;
                }

                if (!bl.VerifyCurrentPassword(_userId, currentPwd))
                {
                    ShowMsg("Current password is incorrect.", false);
                    return;
                }

                // Prevent reusing the same password
                if (bl.VerifyCurrentPassword(_userId, newPwd))
                {
                    ShowMsg("New password cannot be the same as your current password.", false);
                    return;
                }
            }

            // Change it
            bl.ChangePassword(_userId, newPwd);

            if (_isFirstLogin)
            {
                // Redirect to dashboard after first-login password change
                Response.Redirect("~/Student/Dashboard.aspx", false);
            }
            else
            {
                txtCurrentPwd.Text = "";
                txtNewPwd.Text = "";
                txtConfirmPwd.Text = "";
                ShowMsg("Password changed successfully! ✅", true);
            }
        }

        private void ShowMsg(string msg, bool success)
        {
            lblMsg.Text = msg;
            lblMsg.CssClass = "cp-alert d-block " + (success ? "cp-success" : "cp-error");
            lblMsg.Visible = true;
        }
    }
}