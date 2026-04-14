using System;
using System.Data;
using System.Text;
using System.Web.UI.WebControls;


namespace LearningManagementSystem.Admin
{
    public partial class StudentDetails : BasePage
    {
        StudentDetailsBL bl = new StudentDetailsBL();
        protected string AttendanceJson = "[0,0]";
        protected string ProgressJson = "[0,0,0]";

        protected void Page_Load(object sender, EventArgs e)
        {
            //if (Session["InstituteId"] == null) Response.Redirect("~/Default.aspx");
            if (!IsPostBack)
            {
                int userId = Convert.ToInt32(Request.QueryString["id"] ?? "0");
                if (userId == 0) Response.Redirect("StudentsList.aspx");
                LoadFullDashboard(userId, "Current");
            }
        }

        protected void Filter_Changed(object sender, EventArgs e)
        {
            LoadFullDashboard(Convert.ToInt32(Request.QueryString["id"]), ddlAcademicScope.SelectedValue);
        }

        private void LoadFullDashboard(int userId, string filterScope)
        {
            DataSet ds = bl.GetStudentFullDetails(userId, filterScope);
            if (ds == null || ds.Tables.Count < 8 || ds.Tables[0].Rows.Count == 0) return;

            DataRow profile = ds.Tables[0].Rows[0];

            // Header Info
            lblName.Text = profile["FullName"].ToString();
            lblRoll.Text = profile["RollNumber"].ToString();
            lblEmail.Text = profile["Email"].ToString();
            litInitial.Text = profile["FullName"].ToString().Substring(0, 1).ToUpper();
            lblCourseHeader.Text = profile["CourseName"].ToString();
            lblSemHeader.Text = profile["SemesterName"].ToString();

            // --- Interactive Snapshot (Profile Details) ---
            lbl_Stream.Text = $"{profile["StreamName"]} - {profile["CourseName"]}";
            lblGender.Text = profile["Gender"].ToString();
            lblDOB.Text = Convert.ToDateTime(profile["DOB"]).ToString("dd MMM yyyy");
            lblPhone.Text = profile["ContactNo"].ToString();
            lblAddress.Text = $"{profile["Address"]}, {profile["City"]}, {profile["Pincode"]}";
            lblEmerName.Text = profile["EmergencyContactName"].ToString();
            lblEmerPhone.Text = profile["EmergencyContactNo"].ToString();
            //lbl_Skills.Text = profile["Skills"]?.ToString() ?? "N/A";

            //lblStream.Text = $"{profile["StreamName"]} - {profile["CourseName"]}";
            // --- Skills Section ---
            StringBuilder sb = new StringBuilder(); // First declaration
            string rawSkills = profile["Skills"]?.ToString();
            if (!string.IsNullOrEmpty(rawSkills))
            {
                foreach (var s in rawSkills.Split(','))
                {
                    sb.Append($"<span class='badge bg-primary...'>{s.Trim()}</span> ");
                }
                lbl_Skills.Text = sb.ToString();
            }

            // Stats Logic
            int present = Convert.ToInt32(ds.Tables[4].Rows[0]["Present"]);
            int absent = Convert.ToInt32(ds.Tables[4].Rows[0]["Absent"]);
            double attPer = (present + absent) > 0 ? (double)present * 100 / (present + absent) : 0;

            lblAttPer.Text = attPer.ToString("0") + "%";
            lblSubCount.Text = ds.Tables[5].Rows.Count.ToString();
            lblTaskCount.Text = ds.Tables[7].Rows[0]["Assignments"].ToString();


            // Out-of-the-box Risk Analysis
            if (attPer < 75)
                litRiskBadge.Text = "<span class='status-pill status-at-risk'><i class='fas fa-exclamation-triangle me-1'></i> LOW ATTENDANCE RISK</span>";
            else
                litRiskBadge.Text = "<span class='status-pill status-good'><i class='fas fa-check-circle me-1'></i> ACADEMICALLY STABLE</span>";

            // Bind Repeaters
            rptSubjects.DataSource = ds.Tables[5];
            rptSubjects.DataBind();
            rptActivity.DataSource = ds.Tables[6];
            rptActivity.DataBind();

            // JSON for Charts
            AttendanceJson = $"[{present}, {absent}]";
            ProgressJson = $"[{ds.Tables[7].Rows[0]["Videos"]}, {ds.Tables[7].Rows[0]["Assignments"]}, {ds.Tables[7].Rows[0]["Quiz"]}]";
            lblOverallProgress.Text = ((Convert.ToInt32(ds.Tables[7].Rows[0]["Videos"]) + Convert.ToInt32(ds.Tables[7].Rows[0]["Assignments"])) / 2).ToString();
        }

        protected void btnDownload_Click(object sender, EventArgs e) { /* Report logic */ }
    }
}