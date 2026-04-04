using LearningManagementSystem.BL;
using System;
using System.Data;
using System.Data.SqlClient;

namespace LearningManagementSystem.Admin
{
    public partial class Dashboard : System.Web.UI.Page
    {
        int instituteId;
        int sessionId;

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
                Response.Redirect("~/Default.aspx");
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
                instituteId = Convert.ToInt32(Session["InstituteId"]);
                LoadSessions();
                LoadDashboard();
            }
        }

        private void LoadSessions()
        {
            AcademicSessionBL bl = new AcademicSessionBL();
            DataTable dt = bl.GetSessionsByInstitute(instituteId);

            ddlAcademicSession.DataSource = dt;
            ddlAcademicSession.DataTextField = "SessionName";
            ddlAcademicSession.DataValueField = "SessionId";
            ddlAcademicSession.DataBind();

            DataTable current = bl.GetCurrentSession(instituteId);
            if (current.Rows.Count > 0)
            {
                ddlAcademicSession.SelectedValue = current.Rows[0]["SessionId"].ToString();
                sessionId = Convert.ToInt32(current.Rows[0]["SessionId"]);
                Session["CurrentSessionId"] = sessionId;
            }
        }

        //protected void ddlAcademicSession_SelectedIndexChanged(object sender, EventArgs e)
        //{
        //    instituteId = Convert.ToInt32(Session["InstituteId"]);   // ✅ ADD THIS
        //    sessionId = Convert.ToInt32(ddlAcademicSession.SelectedValue);

        //    Session["CurrentSessionId"] = sessionId;

        //    lblSelectedSession.Text = "Session: " + ddlAcademicSession.SelectedItem.Text;

        //    LoadDashboard();
        //}
        //private void LoadDashboard()
        //{
        //    instituteId = Convert.ToInt32(Session["InstituteId"]);   // ✅ FIX
        //    sessionId = Convert.ToInt32(Session["CurrentSessionId"]);

        //    AdminDashboardBL bl = new AdminDashboardBL();

        //    DataRow r = bl.GetCounts(instituteId, sessionId).Rows[0];

        //    lblStudents.Text = r["Students"].ToString();
        //    lblTeachers.Text = r["Teachers"].ToString();
        //    lblSubjects.Text = r["Subjects"].ToString();
        //    lblCourses.Text = r["Courses"].ToString();
        //}

        protected void ddlAcademicSession_SelectedIndexChanged(object sender, EventArgs e)
        {
            sessionId = Convert.ToInt32(ddlAcademicSession.SelectedValue);
            Session["CurrentSessionId"] = sessionId;

            lblSelectedSession.Text = "Session: " + ddlAcademicSession.SelectedItem.Text;

            LoadDashboard();
        }

        private void LoadDashboard()
        {
            sessionId = Convert.ToInt32(Session["CurrentSessionId"]);

            AdminDashboardBL bl = new AdminDashboardBL();

            DataRow r = bl.GetCounts(instituteId, sessionId).Rows[0];

            lblStudents.Text = r["Students"].ToString();
            lblTeachers.Text = r["Teachers"].ToString();
            lblSubjects.Text = r["Subjects"].ToString();
            lblCourses.Text = r["Courses"].ToString();

        }
    }
}

