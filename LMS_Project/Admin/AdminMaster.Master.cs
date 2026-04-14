//using System;
//using System.Drawing;
//using System.Xml.Linq;

//namespace LearningManagementSystem.Admin
//{
//    public partial class AdminMaster : System.Web.UI.MasterPage
//    {
//        protected void Page_Load(object sender, EventArgs e)
//        {
//            if (!IsPostBack)
//            {
//                string displayName = "LMS Portal";
//                string logoUrl = "~/assets/images/logo.png";
//                string profileUrl = "~/assets/images/default-user.png";

//                if (Session["ActiveInstituteName"] != null)
//                    displayName = Session["ActiveInstituteName"].ToString();
//                else if (Session["InstituteName"] != null)
//                    displayName = Session["InstituteName"].ToString();

//                // ✅ Proper Logo Handling
//                if (Session["LogoURL"] != null && !string.IsNullOrEmpty(Session["LogoURL"].ToString()))
//                {
//                    logoUrl = Session["LogoURL"].ToString();
//                }

//                lblHeaderInstituteName.Text = displayName;

//                imgInstituteLogo.ImageUrl = ResolveUrl(logoUrl);
//                imgProfilePhoto.ImageUrl = ResolveUrl(profileUrl);
//            }
//        }
//    }
//}

//--------------------------------------------------------------------------------------------------------------------------------------------------

using LearningManagementSystem.BL;
using System;
using System.Data;

namespace LearningManagementSystem.Admin
{
    public partial class AdminMaster : System.Web.UI.MasterPage
    {
        int instituteId;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null)
            {
                Response.Redirect("~/Default.aspx");
                return;
            }

            if (Session["InstituteId"] != null)
                instituteId = Convert.ToInt32(Session["InstituteId"]);
            else
                return;

            if (!IsPostBack)
            {
                LoadSessions();
                SetUI();
            }
        }

        //private void LoadSessions()
        //{
        //    AcademicSessionBL bl = new AcademicSessionBL();
        //    DataTable dt = bl.GetSessionsByInstitute(instituteId);

        //    ddlGlobalSession.DataSource = dt;
        //    ddlGlobalSession.DataTextField = "SessionName";
        //    ddlGlobalSession.DataValueField = "SessionId";
        //    ddlGlobalSession.DataBind();

        //    // ✅ Set Selected Session
        //    if (Session["CurrentSessionId"] != null)
        //    {
        //        ddlGlobalSession.SelectedValue = Session["CurrentSessionId"].ToString();
        //        lblGlobalSession.Text = ddlGlobalSession.SelectedItem.Text;
        //    }
        //    else
        //    {
        //        // fallback → current DB session
        //        DataTable current = bl.GetCurrentSession(instituteId);

        //        if (current.Rows.Count > 0)
        //        {
        //            string sessionId = current.Rows[0]["SessionId"].ToString();

        //            ddlGlobalSession.SelectedValue = sessionId;
        //            Session["CurrentSessionId"] = sessionId;

        //            lblGlobalSession.Text = current.Rows[0]["SessionName"].ToString();
        //        }
        //    }
        //}

        private void LoadSessions()
        {
            AcademicSessionBL bl = new AcademicSessionBL();
            DataTable dt = bl.GetSessionsByInstitute(instituteId);

            ddlGlobalSession.DataSource = dt;
            ddlGlobalSession.DataTextField = "SessionName";
            ddlGlobalSession.DataValueField = "SessionId";
            ddlGlobalSession.DataBind();

            // 🔥 IMPORTANT FIX START

            if (Session["CurrentSessionId"] == null)
            {
                DataTable current = bl.GetCurrentSession(instituteId);

                if (current.Rows.Count > 0)
                {
                    string sessionId = current.Rows[0]["SessionId"].ToString();

                    Session["CurrentSessionId"] = sessionId;

                    ddlGlobalSession.SelectedValue = sessionId;
                    lblGlobalSession.Text = current.Rows[0]["SessionName"].ToString();
                }
            }
            else
            {
                ddlGlobalSession.SelectedValue = Session["CurrentSessionId"].ToString();
                lblGlobalSession.Text = ddlGlobalSession.SelectedItem.Text;
            }

            // 🔥 IMPORTANT FIX END
        }
        protected void ddlGlobalSession_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (ddlGlobalSession.SelectedValue != null)
            {
                Session["CurrentSessionId"] = ddlGlobalSession.SelectedValue;

                lblGlobalSession.Text = ddlGlobalSession.SelectedItem.Text;

                // 🔥 reload current page (VERY IMPORTANT)
                Response.Redirect(Request.RawUrl,true);
            }
        }

        //protected void ddlGlobalSession_SelectedIndexChanged(object sender, EventArgs e)
        //{
        //    Session["CurrentSessionId"] = ddlGlobalSession.SelectedValue;

        //    // 🔥 FORCE FULL RELOAD (NO CACHE)
        //    Response.Redirect(Request.RawUrl, true);
        //}

        private void SetUI()
        {
            string displayName = "LMS Portal";
            string logoUrl = "~/assets/images/logo.png";
            string profileUrl = "~/assets/images/default-user.png";

            if (Session["ActiveInstituteName"] != null)
                displayName = Session["ActiveInstituteName"].ToString();
            else if (Session["InstituteName"] != null)
                displayName = Session["InstituteName"].ToString();

            if (Session["LogoURL"] != null && !string.IsNullOrEmpty(Session["LogoURL"].ToString()))
                logoUrl = Session["LogoURL"].ToString();

            lblHeaderInstituteName.Text = displayName;

            imgInstituteLogo.ImageUrl = ResolveUrl(logoUrl);
            imgProfilePhoto.ImageUrl = ResolveUrl(profileUrl);
        }
    }
}