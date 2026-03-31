using System;
using System.Data;
using System.Web.UI;

namespace LearningManagementSystem.Admin
{
    public partial class TeacherDetails : Page
    {
        TeacherBL tbl = new TeacherBL();
        SubjectFacultyBL sbl = new SubjectFacultyBL();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null)
            {
                Response.Redirect("~/Default.aspx");
                return;
            }
            if (Request.QueryString["id"] != null && !IsPostBack)
            {
                int userId = Convert.ToInt32(Request.QueryString["id"]);
                LoadProfile(userId);
                LoadSubjectHistory(userId);
            }
        }

        //private void LoadProfile(int userId)
        //{
        //    DataTable dt = tbl.GetTeacherById(userId);
        //    if (dt != null && dt.Rows.Count > 0)
        //    {
        //        DataRow row = dt.Rows[0];
        //        litFullName.Text = row["FullName"].ToString();
        //        litEmpId.Text = row["EmployeeId"].ToString();
        //        litDesignation.Text = row["Designation"].ToString();
        //        litInitial.Text = row["FullName"].ToString().Substring(0, 1).ToUpper();
        //    }
        //}

        private void LoadProfile(int userId)
        {
            DataTable dt = tbl.GetTeacherById(userId);
            if (dt != null && dt.Rows.Count > 0)
            {
                DataRow row = dt.Rows[0];
                string fullName = row["FullName"].ToString();
                litFullName.Text = fullName;
                litEmpId.Text = row["EmployeeId"].ToString();
                litDesignation.Text = row["Designation"].ToString();
                litInitial.Text = fullName.Substring(0, 1).ToUpper();

                // Basic Info
                litContact.Text = row["ContactNo"].ToString();
                litEmail.Text = row["Email"].ToString();

                // Profile Image Logic
                if (row["ProfileImage"] != DBNull.Value && !string.IsNullOrEmpty(row["ProfileImage"].ToString()))
                {
                    imgProfile.ImageUrl = row["ProfileImage"].ToString();
                    imgProfile.Visible = true;
                    divInitial.Visible = false;
                }

                // Show Full Details only if they exist
                if (row["ExperienceYears"] != DBNull.Value || row["Address"] != DBNull.Value)
                {
                    phFullDetails.Visible = true;
                    litDOB.Text = Convert.ToDateTime(row["DOB"]).ToString("dd MMM yyyy");
                    litExp.Text = row["ExperienceYears"].ToString();
                    litAddress.Text = $"{row["Address"]}, {row["City"]}";
                }

                // DYNAMIC GRAPH CALCULATION
                // Typically: (Completed Topics / Total Topics) * 100
                // For now, setting a dynamic calculation or a default
                litProgressText.Text = "82"; // This should be calculated from a query to Materials/Syllabus table

                // DYNAMIC RATING
                litRating.Text = "4.9";
            }
        }

        private void LoadSubjectHistory(int userId)
        {
            int instituteId = Convert.ToInt32(Session["InstituteId"]);
            int currentSessionId = sbl.GetCurrentSession(instituteId);

            // Fetching subjects assigned to this specific teacher
            DataTable dt = sbl.GetAllByTeacher(instituteId, userId);
            rptSubjects.DataSource = dt;
            rptSubjects.DataBind();
            litSubCount.Text = dt.Rows.Count.ToString();
        }
    }
}