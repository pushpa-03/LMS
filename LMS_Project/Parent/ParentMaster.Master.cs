using System;

namespace LearningManagementSystem.Parent
{
    public partial class ParentMaster : System.Web.UI.MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // 🔐 Role Validation
            if (Session["UserId"] == null || Session["Role"].ToString() != "Parent")
            {
                Response.Redirect("~/Default.aspx");
            }

            if (!IsPostBack)
            {
                string displayName = "LMS Portal";
                string logoUrl = "~/assets/images/logo.png";
                string profileUrl = "~/assets/images/default-user.png";

                if (Session["ActiveInstituteName"] != null)
                    displayName = Session["ActiveInstituteName"].ToString();
                else if (Session["InstituteName"] != null)
                    displayName = Session["InstituteName"].ToString();

                if (Session["LogoURL"] != null &&
                    !string.IsNullOrEmpty(Session["LogoURL"].ToString()))
                {
                    logoUrl = Session["LogoURL"].ToString();
                }

                if (Session["ProfileImage"] != null &&
                    !string.IsNullOrEmpty(Session["ProfileImage"].ToString()))
                {
                    profileUrl = Session["ProfileImage"].ToString();
                }

                lblHeaderInstituteName.Text = displayName;

                imgInstituteLogo.ImageUrl = ResolveUrl(logoUrl);
                imgProfilePhoto.ImageUrl = ResolveUrl(profileUrl);
            }
        }
    }
}