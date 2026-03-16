using LearningManagementSystem.BL;
using LearningManagementSystem.GC;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

namespace LearningManagementSystem.Admin
{
    public partial class AdminMaster1 : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // 🔐 Check login only
            if (Session["UserId"] == null)
            {
                Response.Redirect("~/Default.aspx");
                return;
            }

            string role = Session["Role"]?.ToString();

            // 🚫 Only Admin & SuperAdmin allowed
            if (role != "Admin" && role != "SuperAdmin")
            {
                Response.Redirect("~/Unauthorized.aspx");
                return;
            }

            // ✅ SUPERADMIN SWITCH INSTITUTE LOGIC
            if (role == "SuperAdmin" && Request.QueryString["InstituteId"] != null)
            {
                int instituteId = Convert.ToInt32(Request.QueryString["InstituteId"]);

                DataLayer dl = new DataLayer();
                SqlCommand cmd = new SqlCommand();
                cmd.CommandText = @"SELECT InstituteName, SocietyId, LogoURL 
                        FROM Institutes 
                        WHERE InstituteId = @Id";

                cmd.Parameters.AddWithValue("@Id", instituteId);

                DataTable dt = dl.GetDataTable(cmd);

                if (dt != null && dt.Rows.Count > 0)
                {
                    Session["InstituteId"] = instituteId;
                    Session["InstituteName"] = dt.Rows[0]["InstituteName"].ToString();
                    Session["ActiveInstituteName"] = dt.Rows[0]["InstituteName"].ToString();
                    Session["SocietyId"] = dt.Rows[0]["SocietyId"];

                    // ✅ Proper Logo Handling
                    if (dt.Rows[0]["LogoURL"] != DBNull.Value &&
                        !string.IsNullOrEmpty(dt.Rows[0]["LogoURL"].ToString()))
                    {
                        Session["LogoURL"] = dt.Rows[0]["LogoURL"].ToString();
                    }
                    else
                    {
                        Session["LogoURL"] = "~/assets/images/logo.png";
                    }
                }
            }

            if (!IsPostBack)
            {
                LoadAcademicSessions();
            }
        }


        private void LoadAcademicSessions()
    {
        AcademicSessionBL bl = new AcademicSessionBL();
        int instituteId = Convert.ToInt32(Session["InstituteId"]);

        DataTable dt = bl.GetSessionsByInstitute(instituteId);

        ddlAcademicSession.DataSource = dt;
        ddlAcademicSession.DataTextField = "SessionName";
        ddlAcademicSession.DataValueField = "SessionId";
        ddlAcademicSession.DataBind();

        DataTable current = bl.GetCurrentSession(instituteId);
        if (current.Rows.Count > 0)
        {
            ddlAcademicSession.SelectedValue =
                current.Rows[0]["SessionId"].ToString();

            lblSelectedSession.Text =
                "Current Session: " +
                current.Rows[0]["SessionName"].ToString();
        }
    }

    protected void ddlAcademicSession_SelectedIndexChanged(object sender, EventArgs e)
    {
        int sessionId = Convert.ToInt32(ddlAcademicSession.SelectedValue);

        Session["CurrentSessionId"] = sessionId;

        lblSelectedSession.Text = "Selected Session: " +
            ddlAcademicSession.SelectedItem.Text;
    }


}
}