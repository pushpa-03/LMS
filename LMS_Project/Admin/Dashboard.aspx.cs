using LearningManagementSystem.BL;
using System;
using System.Data;
using System.Data.SqlClient;

namespace LearningManagementSystem.Admin
{
    //public partial class Dashboard : System.Web.UI.Page
    //{
    //    int instituteId;
    //    int sessionId;

    //    //protected void Page_Load(object sender, EventArgs e)
    //    //{
    //    //    // 🔐 Check login only
    //    //    if (Session["UserId"] == null)
    //    //    {
    //    //        Response.Redirect("~/Default.aspx");
    //    //        return;
    //    //    }

    //    //    string role = Session["Role"]?.ToString();

    //    //    // 🚫 Only Admin & SuperAdmin allowed
    //    //    if (role != "Admin" && role != "SuperAdmin")
    //    //    {
    //    //        Response.Redirect("~/Default.aspx");
    //    //        return;
    //    //    }

    ////        // ✅ SUPERADMIN SWITCH INSTITUTE LOGIC
    ////        if (role == "SuperAdmin" && Request.QueryString["InstituteId"] != null)
    ////        {
    ////            int instituteId = Convert.ToInt32(Request.QueryString["InstituteId"]);

    ////    DataLayer dl = new DataLayer();
    ////    SqlCommand cmd = new SqlCommand();
    ////    cmd.CommandText = @"SELECT InstituteName, SocietyId, LogoURL 
    ////                    FROM Institutes 
    ////                    WHERE InstituteId = @Id";

    ////            cmd.Parameters.AddWithValue("@Id", instituteId);

    ////            DataTable dt = dl.GetDataTable(cmd);

    ////            if (dt != null && dt.Rows.Count > 0)
    ////            {
    ////                Session["InstituteId"] = instituteId;
    ////                Session["InstituteName"] = dt.Rows[0]["InstituteName"].ToString();
    ////    Session["ActiveInstituteName"] = dt.Rows[0]["InstituteName"].ToString();
    ////    Session["SocietyId"] = dt.Rows[0]["SocietyId"];

    ////                // ✅ Proper Logo Handling
    ////                if (dt.Rows[0]["LogoURL"] != DBNull.Value &&
    ////                    !string.IsNullOrEmpty(dt.Rows[0]["LogoURL"].ToString()))
    ////                {
    ////                    Session["LogoURL"] = dt.Rows[0]["LogoURL"].ToString();
    ////}
    ////                else
    ////                {
    ////                    Session["LogoURL"] = "~/assets/images/logo.png";
    ////                }
    ////            }
    ////        }

    //    //    if (!IsPostBack)
    //    //    {
    //    //        instituteId = Convert.ToInt32(Session["InstituteId"]);
    //    //        LoadSessions();
    //    //        LoadDashboard();
    //    //    }
    //    //}

    //    protected void Page_Load(object sender, EventArgs e)
    //    {
    //        if (Session["UserId"] == null)
    //        {
    //            Response.Redirect("~/Default.aspx");
    //            return;
    //        }

    //        if (Session["InstituteId"] == null)
    //            return;

    //        instituteId = Convert.ToInt32(Session["InstituteId"]);

    //        // ✅ STEP 1: If session NOT set → load default from DB
    //        if (Session["CurrentSessionId"] == null)
    //        {
    //            SetDefaultSession();
    //        }

    //        // ✅ STEP 2: Now ALWAYS load dashboard
    //        sessionId = Convert.ToInt32(Session["CurrentSessionId"]);

    //        string role = Session["Role"]?.ToString();

    //        if (role != "Admin" && role != "SuperAdmin")
    //        {
    //            Response.Redirect("~/Default.aspx");
    //            return;
    //        }

    //        // ✅ SUPERADMIN SWITCH INSTITUTE LOGIC
    //        if (role == "SuperAdmin" && Request.QueryString["InstituteId"] != null)
    //        {
    //            int instituteId = Convert.ToInt32(Request.QueryString["InstituteId"]);

    //            DataLayer dl = new DataLayer();
    //            SqlCommand cmd = new SqlCommand();
    //            cmd.CommandText = @"SELECT InstituteName, SocietyId, LogoURL 
    //                    FROM Institutes 
    //                    WHERE InstituteId = @Id";

    //            cmd.Parameters.AddWithValue("@Id", instituteId);

    //            DataTable dt = dl.GetDataTable(cmd);

    //            if (dt != null && dt.Rows.Count > 0)
    //            {
    //                Session["InstituteId"] = instituteId;
    //                Session["InstituteName"] = dt.Rows[0]["InstituteName"].ToString();
    //                Session["ActiveInstituteName"] = dt.Rows[0]["InstituteName"].ToString();
    //                Session["SocietyId"] = dt.Rows[0]["SocietyId"];

    //                // ✅ Proper Logo Handling
    //                if (dt.Rows[0]["LogoURL"] != DBNull.Value &&
    //                    !string.IsNullOrEmpty(dt.Rows[0]["LogoURL"].ToString()))
    //                {
    //                    Session["LogoURL"] = dt.Rows[0]["LogoURL"].ToString();
    //                }
    //                else
    //                {
    //                    Session["LogoURL"] = "~/assets/images/logo.png";
    //                }
    //            }
    //        }

    //        if (!IsPostBack)
    //        {
    //            LoadDashboard();
    //        }
    //    }

    //    private void SetDefaultSession()
    //    {
    //        AcademicSessionBL bl = new AcademicSessionBL();

    //        DataTable dt = bl.GetCurrentSession(instituteId);

    //        if (dt != null && dt.Rows.Count > 0)
    //        {
    //            Session["CurrentSessionId"] = dt.Rows[0]["SessionId"];
    //            Session["SessionName"] = dt.Rows[0]["SessionName"];

    //            lblSelectedSession.Text = "Session: " + dt.Rows[0]["SessionName"].ToString();
    //        }
    //    }

    //    private void LoadDashboard()
    //    {
    //        if (Session["InstituteId"] == null || Session["CurrentSessionId"] == null)
    //            return;

    //        instituteId = Convert.ToInt32(Session["InstituteId"]);
    //        sessionId = Convert.ToInt32(Session["CurrentSessionId"]);

    //        lblSelectedSession.Text = "Current Session: " + Session["SessionName"]?.ToString();

    //        AdminDashboardBL bl = new AdminDashboardBL();
    //        DataTable dt = bl.GetCounts(instituteId, sessionId);

    //        if (dt != null && dt.Rows.Count > 0)
    //        {
    //            DataRow r = dt.Rows[0];

    //            lblStudents.Text = r["Students"].ToString();
    //            lblTeachers.Text = r["Teachers"].ToString();
    //            lblSubjects.Text = r["Subjects"].ToString();
    //            lblCourses.Text = r["Courses"].ToString();
    //        }
    //        else
    //        {
    //            lblStudents.Text = "0";
    //            lblTeachers.Text = "0";
    //            lblSubjects.Text = "0";
    //            lblCourses.Text = "0";
    //        }
    //    }
    //}


    public partial class Dashboard : BasePage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            string role = Session["Role"]?.ToString();

            if (role != "Admin" && role != "SuperAdmin")
            {
                Response.Redirect("~/Default.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadDashboard();
            }
        }

        private void LoadDashboard()
        {
            lblSelectedSession.Text = "Current Session: " + Session["SessionName"];

            AdminDashboardBL bl = new AdminDashboardBL();
            DataTable dt = bl.GetCounts(InstituteId, SessionId);

            if (dt.Rows.Count > 0)
            {
                var r = dt.Rows[0];

                lblStudents.Text = r["Students"].ToString();
                lblTeachers.Text = r["Teachers"].ToString();
                lblSubjects.Text = r["Subjects"].ToString();
                lblCourses.Text = r["Courses"].ToString();
            }
        }
    }
}