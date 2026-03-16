using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace LMS_Project.Student
{
    public partial class StudentMaster : System.Web.UI.MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // ============================================================
            // 🔐 ROLE GUARD — Must be logged in as Student
            // ============================================================
            if (Session["UserId"] == null)
            {
                Response.Redirect("~/Default.aspx", true);
                return;
            }

            string role = Session["Role"]?.ToString();

            if (role != "Student")
            {
                Response.Redirect("~/Default.aspx", true);
                return;
            }

            // ============================================================
            // 🔒 FIRST LOGIN CHECK — Force password change
            // ============================================================
            // Only check on pages other than ChangePassword itself
            string currentPage = System.IO.Path.GetFileName(
                Request.PhysicalPath).ToLower();

            if (currentPage != "changepassword.aspx")
            {
                DataLayer dl = new DataLayer();
                SqlCommand checkCmd = new SqlCommand(
                    "SELECT IsFirstLogin FROM Users WHERE UserId = @Id");
                checkCmd.Parameters.AddWithValue("@Id",
                    Convert.ToInt32(Session["UserId"]));

                DataTable dtCheck = dl.GetDataTable(checkCmd);

                if (dtCheck.Rows.Count > 0 &&
                    Convert.ToBoolean(dtCheck.Rows[0]["IsFirstLogin"]))
                {
                    Response.Redirect("~/Student/ChangePassword.aspx", true);
                    return;
                }
            }

            // ============================================================
            // ✅ Load layout data on every request (not just !IsPostBack)
            // so session changes are always reflected
            // ============================================================
            if (!IsPostBack)
            {
                LoadMasterData();
            }
        }

        private void LoadMasterData()
        {
            int userId = Convert.ToInt32(Session["UserId"]);
            int instituteId = Session["InstituteId"] != null
                              ? Convert.ToInt32(Session["InstituteId"]) : 0;

            // ── Institute name & logo ──────────────────────────────────
            string displayName = "LMS Student Portal";
            string logoUrl = "~/assets/images/logo.png";
            string profileUrl = "~/assets/images/default-user.png";

            if (Session["ActiveInstituteName"] != null)
                displayName = Session["ActiveInstituteName"].ToString();
            else if (Session["InstituteName"] != null)
                displayName = Session["InstituteName"].ToString();

            if (Session["LogoURL"] != null &&
                !string.IsNullOrEmpty(Session["LogoURL"].ToString()))
                logoUrl = Session["LogoURL"].ToString();

            lblHeaderInstituteName.Text = displayName;
            hInstituteName.InnerText = displayName;
            imgInstituteLogo.ImageUrl = ResolveUrl(logoUrl);

            // ── Student name & profile photo ──────────────────────────
            DataLayer dl = new DataLayer();

            SqlCommand profileCmd = new SqlCommand(@"
                SELECT UP.FullName, UP.ProfileImage
                FROM UserProfile UP
                WHERE UP.UserId = @UserId");
            profileCmd.Parameters.AddWithValue("@UserId", userId);

            DataTable dtProfile = dl.GetDataTable(profileCmd);

            if (dtProfile.Rows.Count > 0)
            {
                string fullName = dtProfile.Rows[0]["FullName"].ToString();
                lblStudentName.Text = fullName.Split(' ')[0]; // First name only
                lblDropdownName.Text = fullName;

                string profileImage = dtProfile.Rows[0]["ProfileImage"]?.ToString();
                if (!string.IsNullOrEmpty(profileImage))
                    profileUrl = profileImage;
            }

            imgProfilePhoto.ImageUrl = ResolveUrl(profileUrl);

            // ── Unread notification count ──────────────────────────────
            if (instituteId > 0)
            {
                SqlCommand notifyCmd = new SqlCommand(@"
                    SELECT TOP 5
                        Message,
                        CreatedOn
                    FROM Notifications
                    WHERE UserId      = @UserId
                      AND InstituteId = @InstId
                      AND IsRead      = 0
                    ORDER BY CreatedOn DESC");

                notifyCmd.Parameters.AddWithValue("@UserId", userId);
                notifyCmd.Parameters.AddWithValue("@InstId", instituteId);

                DataTable dtNotify = dl.GetDataTable(notifyCmd);

                if (dtNotify.Rows.Count > 0)
                {
                    // Bell badge in header
                    lblHeaderNotifyCount.Text = dtNotify.Rows.Count.ToString();
                    lblHeaderNotifyCount.Visible = true;

                    // Sidebar badge
                    lblNotifyCount.Text = dtNotify.Rows.Count.ToString();
                    lblNotifyCount.Visible = true;

                    // Dropdown preview list
                    rptHeaderNotifications.DataSource = dtNotify;
                    rptHeaderNotifications.DataBind();
                }
            }
        }
    }
}
