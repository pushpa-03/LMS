//using LearningManagementSystem.BL;
//using System;
//using System.Data;
//using System.Data.SqlClient;

//namespace LearningManagementSystem.Admin
//{
//    public partial class Dashboard : System.Web.UI.Page
//    {
//        int instituteId;
//        int sessionId;

//        //    //protected void Page_Load(object sender, EventArgs e)
//        //    //{
//        //    //    // 🔐 Check login only
//        //    //    if (Session["UserId"] == null)
//        //    //    {
//        //    //        Response.Redirect("~/Default.aspx");
//        //    //        return;
//        //    //    }

//        //    //    string role = Session["Role"]?.ToString();

//        //    //    // 🚫 Only Admin & SuperAdmin allowed
//        //    //    if (role != "Admin" && role != "SuperAdmin")
//        //    //    {
//        //    //        Response.Redirect("~/Default.aspx");
//        //    //        return;
//        //    //    }

//        ////        // ✅ SUPERADMIN SWITCH INSTITUTE LOGIC
//        ////        if (role == "SuperAdmin" && Request.QueryString["InstituteId"] != null)
//        ////        {
//        ////            int instituteId = Convert.ToInt32(Request.QueryString["InstituteId"]);

//        ////    DataLayer dl = new DataLayer();
//        ////    SqlCommand cmd = new SqlCommand();
//        ////    cmd.CommandText = @"SELECT InstituteName, SocietyId, LogoURL 
//        ////                    FROM Institutes 
//        ////                    WHERE InstituteId = @Id";

//        ////            cmd.Parameters.AddWithValue("@Id", instituteId);

//        ////            DataTable dt = dl.GetDataTable(cmd);

//        ////            if (dt != null && dt.Rows.Count > 0)
//        ////            {
//        ////                Session["InstituteId"] = instituteId;
//        ////                Session["InstituteName"] = dt.Rows[0]["InstituteName"].ToString();
//        ////    Session["ActiveInstituteName"] = dt.Rows[0]["InstituteName"].ToString();
//        ////    Session["SocietyId"] = dt.Rows[0]["SocietyId"];

//        ////                // ✅ Proper Logo Handling
//        ////                if (dt.Rows[0]["LogoURL"] != DBNull.Value &&
//        ////                    !string.IsNullOrEmpty(dt.Rows[0]["LogoURL"].ToString()))
//        ////                {
//        ////                    Session["LogoURL"] = dt.Rows[0]["LogoURL"].ToString();
//        ////}
//        ////                else
//        ////                {
//        ////                    Session["LogoURL"] = "~/assets/images/logo.png";
//        ////                }
//        ////            }
//        ////        }

//        //    //    if (!IsPostBack)
//        //    //    {
//        //    //        instituteId = Convert.ToInt32(Session["InstituteId"]);
//        //    //        LoadSessions();
//        //    //        LoadDashboard();
//        //    //    }
//        //    //}

//        protected void Page_Load(object sender, EventArgs e)
//        {
//            if (Session["UserId"] == null)
//            {
//                Response.Redirect("~/Default.aspx");
//                return;
//            }

//            if (Session["InstituteId"] == null)
//                return;

//            instituteId = Convert.ToInt32(Session["InstituteId"]);

//            // ✅ STEP 1: If session NOT set → load default from DB
//            if (Session["CurrentSessionId"] == null)
//            {
//                SetDefaultSession();
//            }            

//            if (!IsPostBack)
//            {
//                LoadDashboard();
//            }
//        }

//        private void SetDefaultSession()
//        {
//            AcademicSessionBL bl = new AcademicSessionBL();

//            DataTable dt = bl.GetCurrentSession(instituteId);

//            if (dt != null && dt.Rows.Count > 0)
//            {
//                Session["CurrentSessionId"] = dt.Rows[0]["SessionId"];
//                Session["SessionName"] = dt.Rows[0]["SessionName"];

//                lblSelectedSession.Text = "Session: " + dt.Rows[0]["SessionName"].ToString();
//            }
//        }

//        private void LoadDashboard()
//        {
//            if (Session["InstituteId"] == null || Session["CurrentSessionId"] == null)
//                return;

//            instituteId = Convert.ToInt32(Session["InstituteId"]);
//            sessionId = Convert.ToInt32(Session["CurrentSessionId"]);

//            lblSelectedSession.Text = "Current Session: " + Session["SessionName"]?.ToString();

//            AdminDashboardBL bl = new AdminDashboardBL();
//            DataTable dt = bl.GetCounts(instituteId, sessionId);

//            if (dt != null && dt.Rows.Count > 0)
//            {
//                DataRow r = dt.Rows[0];

//                lblStudents.Text = r["Students"].ToString();
//                lblTeachers.Text = r["Teachers"].ToString();
//                lblSubjects.Text = r["Subjects"].ToString();
//                lblCourses.Text = r["Courses"].ToString();
//            }
//            else
//            {
//                lblStudents.Text = "0";
//                lblTeachers.Text = "0";
//                lblSubjects.Text = "0";
//                lblCourses.Text = "0";
//            }
//        }
//    }
//}

//-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

using LearningManagementSystem.BL;
using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace LearningManagementSystem.Admin
{

    public partial class Dashboard : BasePage
    {
        CourseBL blc = new CourseBL();
        AssignLevelSubjectBL bl = new AssignLevelSubjectBL();

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
                LoadFilters();
                LoadDashboard();
                LoadActivity();
            }
        }

        protected void btnFilter_Click(object sender, EventArgs e)
        {
            LoadDashboard();
            LoadActivity();
            // Load charts also
        }

        void LoadFilters()
        {
            ddlCourse.DataSource = blc.GetCourses(InstituteId, SessionId);
            ddlCourse.DataTextField = "CourseName";
            ddlCourse.DataValueField = "CourseId";
            ddlCourse.DataBind();
            ddlCourse.Items.Insert(0, new ListItem("All Courses", "0"));

            ddlSubject.DataSource = bl.GetSubjects(InstituteId,SessionId);
            ddlSubject.DataTextField = "SubjectName";
            ddlSubject.DataValueField = "SubjectId";
            ddlSubject.DataBind();
            ddlSubject.Items.Insert(0, new ListItem("All Subjects", "0"));

           
        }

        protected void btnReset_Click(object sender, EventArgs e)
        {
            txtFromDate.Text = "";
            txtToDate.Text = "";
            ddlCourse.SelectedIndex = 0;
            ddlSubject.SelectedIndex = 0;

            LoadDashboard();
            LoadActivity();
        }

        private void LoadDashboard()
        {
            if (SessionId == 0)
            {
                lblSelectedSession.Text = "No active session found";
                return;
            }

            lblSelectedSession.Text = "Current Session: " + (Session["SessionName"] ?? "N/A");

            AdminDashboardBL bl = new AdminDashboardBL();
            DataTable dt = bl.GetCounts(InstituteId, SessionId);

            if (dt != null && dt.Rows.Count > 0)
            {
                var r = dt.Rows[0];

                lblStudents.Text = r["Students"]?.ToString() ?? "0";
                lblTeachers.Text = r["Teachers"]?.ToString() ?? "0";
                lblSubjects.Text = r["Subjects"]?.ToString() ?? "0";
                lblCourses.Text = r["Courses"]?.ToString() ?? "0";
            }
        }

        private void LoadActivity()
        {
            try
            {
                AdminDashboardBL bl = new AdminDashboardBL();

                DateTime? fromDate = string.IsNullOrEmpty(txtFromDate.Text)
                    ? (DateTime?)null
                    : Convert.ToDateTime(txtFromDate.Text);

                DateTime? toDate = string.IsNullOrEmpty(txtToDate.Text)
                    ? (DateTime?)null
                    : Convert.ToDateTime(txtToDate.Text);

                int courseId = string.IsNullOrEmpty(ddlCourse.SelectedValue)
                    ? 0 : Convert.ToInt32(ddlCourse.SelectedValue);

                int subjectId = string.IsNullOrEmpty(ddlSubject.SelectedValue)
                    ? 0 : Convert.ToInt32(ddlSubject.SelectedValue);

                DataTable dt = bl.GetRecentActivity(
                    InstituteId,
                    SessionId,
                    fromDate,
                    toDate,
                    courseId,
                    subjectId
                );

                dt.Columns.Add("TimeAgo");

                foreach (DataRow row in dt.Rows)
                {
                    DateTime time = row["ActionTime"] != DBNull.Value
                        ? Convert.ToDateTime(row["ActionTime"])
                        : DateTime.Now;

                    row["TimeAgo"] = GetTimeAgo(time);
                }

                rptActivity.DataSource = dt;
                rptActivity.DataBind();
            }
            catch
            {
                ShowToast("Failed to load activity", false);
            }
        }

        protected void FilterChanged(object sender, EventArgs e)
        {
            LoadDashboard();
            LoadActivity();
        }

        private string GetTimeAgo(DateTime date)
        {
            var span = DateTime.Now - date;

            if (span.TotalMinutes < 1) return "Just now";
            if (span.TotalMinutes < 60) return $"{(int)span.TotalMinutes} min ago";
            if (span.TotalHours < 24) return $"{(int)span.TotalHours} hr ago";


            return $"{(int)span.TotalDays} days ago";
        }

        private void ShowToast(string msg, bool success)
        {
            string script = $"showToast('{msg}');";
            ScriptManager.RegisterStartupScript(this, GetType(), "toast", script, true);
        }
    }
}


//--------------------------------------------------------------------------------------------------------------------------------------------------------

//using LearningManagementSystem.BL;
//using System;
//using System.Data;
//using System.Data.SqlClient;

//namespace LearningManagementSystem.Admin
//{
//    public partial class Dashboard : System.Web.UI.Page
//    {
//        int instituteId;
//        int sessionId;

//        //protected void Page_Load(object sender, EventArgs e)
//        //{
//        //    // 🔐 Check login only
//        //    if (Session["UserId"] == null)
//        //    {
//        //        Response.Redirect("~/Default.aspx");
//        //        return;
//        //    }

//        //    string role = Session["Role"]?.ToString();

//        //    // 🚫 Only Admin & SuperAdmin allowed
//        //    if (role != "Admin" && role != "SuperAdmin")
//        //    {
//        //        Response.Redirect("~/Default.aspx");
//        //        return;
//        //    }

//        //    // ✅ SUPERADMIN SWITCH INSTITUTE LOGIC
//        //    if (role == "SuperAdmin" && Request.QueryString["InstituteId"] != null)
//        //    {
//        //        int instituteId = Convert.ToInt32(Request.QueryString["InstituteId"]);

//        //        DataLayer dl = new DataLayer();
//        //        SqlCommand cmd = new SqlCommand();

//        //        cmd.CommandText = @"SELECT InstituteName, SocietyId, LogoURL
//        //                            FROM Institutes
//        //                            WHERE InstituteId = @Id";

//        //        cmd.Parameters.AddWithValue("@Id", instituteId);

//        //        DataTable dt = dl.GetDataTable(cmd);

//        //        if (dt != null && dt.Rows.Count > 0)
//        //        {
//        //            Session["InstituteId"] = instituteId;
//        //            Session["InstituteName"] = dt.Rows[0]["InstituteName"].ToString();
//        //            Session["ActiveInstituteName"] = dt.Rows[0]["InstituteName"].ToString();
//        //            Session["SocietyId"] = dt.Rows[0]["SocietyId"];

//        //            // ✅ Proper Logo Handling
//        //            if (dt.Rows[0]["LogoURL"] != DBNull.Value &&
//        //                !string.IsNullOrEmpty(dt.Rows[0]["LogoURL"].ToString()))
//        //            {
//        //                Session["LogoURL"] = dt.Rows[0]["LogoURL"].ToString();
//        //            }
//        //            else
//        //            {
//        //                Session["LogoURL"] = "~/assets/images/logo.png";
//        //            }
//        //        }
//        //    }

//        //    if (!IsPostBack)
//        //    {
//        //        instituteId = Convert.ToInt32(Session["InstituteId"]);
//        //        LoadSessions();
//        //        LoadDashboard();
//        //    }
//        //}

//        protected void Page_Load(object sender, EventArgs e)
//        {
//            if (Session["UserId"] == null)
//            {
//                Response.Redirect("~/Default.aspx");
//                return;
//            }

//            if (Session["InstituteId"] == null)
//                return;

//            instituteId = Convert.ToInt32(Session["InstituteId"]);

//            // ✅ STEP 1: If session NOT set → load default from DB
//            if (Session["CurrentSessionId"] == null)
//            {
//                SetDefaultSession();
//            }

//            // ✅ STEP 2: Now ALWAYS load dashboard
//            sessionId = Convert.ToInt32(Session["CurrentSessionId"]);

//            string role = Session["Role"]?.ToString();

//            if (role != "Admin" && role != "SuperAdmin")
//            {
//                Response.Redirect("~/Default.aspx");
//                return;
//            }

//            // ✅ SUPERADMIN SWITCH INSTITUTE LOGIC
//            if (role == "SuperAdmin" && Request.QueryString["InstituteId"] != null)
//            {
//                int instituteId = Convert.ToInt32(Request.QueryString["InstituteId"]);

//                DataLayer dl = new DataLayer();
//                SqlCommand cmd = new SqlCommand();

//                cmd.CommandText = @"SELECT InstituteName, SocietyId, LogoURL 
//                                    FROM Institutes 
//                                    WHERE InstituteId = @Id";

//                cmd.Parameters.AddWithValue("@Id", instituteId);

//                DataTable dt = dl.GetDataTable(cmd);

//                if (dt != null && dt.Rows.Count > 0)
//                {
//                    Session["InstituteId"] = instituteId;
//                    Session["InstituteName"] = dt.Rows[0]["InstituteName"].ToString();
//                    Session["ActiveInstituteName"] = dt.Rows[0]["InstituteName"].ToString();
//                    Session["SocietyId"] = dt.Rows[0]["SocietyId"];

//                    // ✅ Proper Logo Handling
//                    if (dt.Rows[0]["LogoURL"] != DBNull.Value &&
//                        !string.IsNullOrEmpty(dt.Rows[0]["LogoURL"].ToString()))
//                    {
//                        Session["LogoURL"] = dt.Rows[0]["LogoURL"].ToString();
//                    }
//                    else
//                    {
//                        Session["LogoURL"] = "~/assets/images/logo.png";
//                    }
//                }
//            }

//            if (!IsPostBack)
//            {
//                LoadDashboard();
//            }
//        }

//        private void SetDefaultSession()
//        {
//            AcademicSessionBL bl = new AcademicSessionBL();
//            DataTable dt = bl.GetCurrentSession(instituteId);

//            if (dt != null && dt.Rows.Count > 0)
//            {
//                Session["CurrentSessionId"] = dt.Rows[0]["SessionId"];
//                Session["SessionName"] = dt.Rows[0]["SessionName"];

//                lblSelectedSession.Text = "Session: " + dt.Rows[0]["SessionName"].ToString();
//            }
//        }

//        private void LoadDashboard()
//        {
//            if (Session["InstituteId"] == null || Session["CurrentSessionId"] == null)
//                return;

//            instituteId = Convert.ToInt32(Session["InstituteId"]);
//            sessionId = Convert.ToInt32(Session["CurrentSessionId"]);

//            lblSelectedSession.Text = "Current Session: " + Session["SessionName"]?.ToString();

//            AdminDashboardBL bl = new AdminDashboardBL();
//            DataTable dt = bl.GetCounts(instituteId, sessionId);

//            if (dt != null && dt.Rows.Count > 0)
//            {
//                DataRow r = dt.Rows[0];

//                lblStudents.Text = r["Students"].ToString();
//                lblTeachers.Text = r["Teachers"].ToString();
//                lblSubjects.Text = r["Subjects"].ToString();
//                lblCourses.Text = r["Courses"].ToString();
//            }
//            else
//            {
//                lblStudents.Text = "0";
//                lblTeachers.Text = "0";
//                lblSubjects.Text = "0";
//                lblCourses.Text = "0";
//            }
//        }
//    }
//}