using LearningManagementSystem.BL;
using System;
using System.Data;
using System.Data.SqlClient;

public class BasePage : System.Web.UI.Page
{
    protected int InstituteId
    {
        get
        {
            if (Session["InstituteId"] == null)
            {
                Response.Redirect("~/Default.aspx");
                return 0;
            }
            return Convert.ToInt32(Session["InstituteId"]);
        }
    }
    //protected override void OnLoad(EventArgs e)
    //{
    //    if (Session["InstituteId"] == null)
    //    {
    //        Response.Redirect("~/Default.aspx");
    //        return;
    //    }

    //    base.OnLoad(e);
    //}

    protected override void OnLoad(EventArgs e)
    {
        // 🔐 Login required
        if (Session["UserId"] == null)
        {
            Response.Redirect("~/Default.aspx");
            return;
        }

        string role = Session["Role"]?.ToString();

        // ✅ Allow SuperAdmin to pass InstituteId via QueryString
        if (role == "SuperAdmin" && Request.QueryString["InstituteId"] != null)
        {
            int instId = Convert.ToInt32(Request.QueryString["InstituteId"]);

            // ✅ Set ONLY if not already set OR changed
            if (Session["InstituteId"] == null || Convert.ToInt32(Session["InstituteId"]) != instId)
            {
                SetInstituteFromQuery(instId);
            }
        }

        // ❗ NOW check institute
        if (Session["InstituteId"] == null)
        {
            Response.Redirect("~/Default.aspx");
            return;
        }

        // ✅ Ensure session exists
        if (Session["CurrentSessionId"] == null)
        {
            SetDefaultSession();
        }

        base.OnLoad(e);
    }

    private void SetInstituteFromQuery(int instituteId)
    {
        DataLayer dl = new DataLayer();
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = @"SELECT InstituteName, SocietyId, LogoURL 
                        FROM Institutes 
                        WHERE InstituteId = @Id";

        cmd.Parameters.AddWithValue("@Id", instituteId);

        DataTable dt = dl.GetDataTable(cmd);

        if (dt.Rows.Count > 0)
        {
            Session["InstituteId"] = instituteId;
            Session["InstituteName"] = dt.Rows[0]["InstituteName"].ToString();
            Session["ActiveInstituteName"] = dt.Rows[0]["InstituteName"].ToString();
            Session["SocietyId"] = dt.Rows[0]["SocietyId"];

            Session["LogoURL"] = string.IsNullOrEmpty(dt.Rows[0]["LogoURL"]?.ToString())
                ? "~/assets/images/logo.png"
                : dt.Rows[0]["LogoURL"].ToString();

            // 🔥 RESET SESSION (VERY IMPORTANT)
            Session["CurrentSessionId"] = null;
            Session["SessionName"] = null;
        }
    }

    protected int SessionId
    {
        get
        {
            if (Session["CurrentSessionId"] == null)
            {
                SetDefaultSession();

                // 🚨 Safety check
                if (Session["CurrentSessionId"] == null)
                    return 0; // prevent crash
            }

            return Convert.ToInt32(Session["CurrentSessionId"]);
        }
    }

    protected int SocietyId
    {
        get
        {
            if (Session["SocietyId"] == null)
            {
                Response.Redirect("~/Default.aspx");
                return 0;
            }
            return Convert.ToInt32(Session["SocietyId"]);
        }
    }

    protected int UserId
    {
        get
        {
            if (Session["UserId"] == null)
            {
                Response.Redirect("~/Default.aspx");
                return 0;
            }
            return Convert.ToInt32(Session["UserId"]);
        }
    }

    private void SetDefaultSession()
    {
        AcademicSessionBL bl = new AcademicSessionBL();
        DataTable dt = bl.GetCurrentSession(InstituteId);

        if (dt.Rows.Count > 0)
        {
            Session["CurrentSessionId"] = dt.Rows[0]["SessionId"];
            Session["SessionName"] = dt.Rows[0]["SessionName"];
        }
    }
}