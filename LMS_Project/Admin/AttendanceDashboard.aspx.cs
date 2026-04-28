using LearningManagementSystem.BL;
using System;
using System.Collections.Generic;
using System.Data;
using System.Web.Services;
using System.Web.UI.WebControls;

namespace LearningManagementSystem.Admin
{
    public partial class AttendanceDashboard : System.Web.UI.Page
    {
        AdminDashboardBL bl = new AdminDashboardBL();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadDefaults();
                LoadStreams();
            }
        }

        void LoadStreams()
        {
            ddlStream.DataSource = bl.GetStreams();
            ddlStream.DataTextField = "StreamName";
            ddlStream.DataValueField = "StreamId";
            ddlStream.DataBind();
            ddlStream.Items.Insert(0, new ListItem("All Streams", "0"));
        }

        protected void ddlStream_Changed(object sender, EventArgs e)
        {
            ddlCourse.DataSource = bl.GetCourses(ddlStream.SelectedValue);
            ddlCourse.DataTextField = "CourseName";
            ddlCourse.DataValueField = "CourseId";
            ddlCourse.DataBind();
            ddlCourse.Items.Insert(0, new ListItem("All Courses", "0"));
        }

        protected void ddlCourse_Changed(object sender, EventArgs e)
        {
            ddlSubject.DataSource = bl.GetSubjects(ddlCourse.SelectedValue);
            ddlSubject.DataTextField = "SubjectName";
            ddlSubject.DataValueField = "SubjectId";
            ddlSubject.DataBind();
            ddlSubject.Items.Insert(0, new ListItem("All Subjects", "0"));


        }

        private void LoadDefaults()
        {
            txtFrom.Text = DateTime.Now.AddDays(-7).ToString("yyyy-MM-dd");
            txtTo.Text = DateTime.Now.ToString("yyyy-MM-dd");
        }

        protected void FilterChanged(object sender, EventArgs e)
        {
            LoadDefaults();
        }
        protected void btnApply_Click(object sender, EventArgs e)
        {
        }

        [WebMethod]
        public static object GetDashboardData(object filter)
        {
            var json = new System.Web.Script.Serialization.JavaScriptSerializer();
            var dict = json.ConvertToType<Dictionary<string, string>>(filter);

            AdminDashboardBL bl = new AdminDashboardBL();

            return bl.GetAttendanceDashboard(
                dict["from"],
                dict["to"],
                dict["streamId"],
                dict["courseId"],
                dict["subjectId"]
            );
        }
    }
}