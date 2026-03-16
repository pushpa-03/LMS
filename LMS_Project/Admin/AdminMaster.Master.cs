using System;

namespace LearningManagementSystem.Admin
{
    public partial class AdminMaster : System.Web.UI.MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                string displayName = "LMS Portal";
                string logoUrl = "~/assets/images/logo.png";
                string profileUrl = "~/assets/images/default-user.png";

                if (Session["ActiveInstituteName"] != null)
                    displayName = Session["ActiveInstituteName"].ToString();
                else if (Session["InstituteName"] != null)
                    displayName = Session["InstituteName"].ToString();

                // ✅ Proper Logo Handling
                if (Session["LogoURL"] != null && !string.IsNullOrEmpty(Session["LogoURL"].ToString()))
                {
                    logoUrl = Session["LogoURL"].ToString();
                }

                lblHeaderInstituteName.Text = displayName;

                imgInstituteLogo.ImageUrl = ResolveUrl(logoUrl);
                imgProfilePhoto.ImageUrl = ResolveUrl(profileUrl);
            }
        }
    }
}
