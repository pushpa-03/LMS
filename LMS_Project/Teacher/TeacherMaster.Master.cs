using System;

namespace LMS_Project.Teacher
{
    public partial class TeacherMaster : System.Web.UI.MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                string displayName = "LMS Portal";
                string logoUrl = "~/assets/images/logo.png";

                if (Session["ActiveInstituteName"] != null)
                    displayName = Session["ActiveInstituteName"].ToString();
                else if (Session["InstituteName"] != null)
                    displayName = Session["InstituteName"].ToString();

                // ✅ Same logo logic as AdminMaster
                if (Session["LogoURL"] != null && !string.IsNullOrEmpty(Session["LogoURL"].ToString()))
                {
                    logoUrl = Session["LogoURL"].ToString();
                }

                // Header labels
                lblHeaderInstituteName.Text = displayName;
                //hInstituteName.InnerText = displayName;

                // Logo
                imgInstituteLogo.ImageUrl = ResolveUrl(logoUrl);

                // Teacher name & initial from session
                if (Session["TeacherName"] != null)
                {
                    string teacherName = Session["TeacherName"].ToString();
                    lblTeacherName.Text = teacherName;
                    lblInitial.Text = teacherName.Length > 0
                        ? teacherName[0].ToString().ToUpper()
                        : "T";
                }
            }
        }
    }
}