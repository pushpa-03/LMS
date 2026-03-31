using System;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace LearningManagementSystem.Admin
{
    public partial class StudentsList : Page
    {
        StudentBL bl = new StudentBL();

        // ✅ FIXED (must be protected)
        protected int TotalStudents = 0;
        protected int ActiveStudents = 0;
        protected int InactiveStudents = 0;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["InstituteId"] == null)
                Response.Redirect("~/Default.aspx");

            if (!IsPostBack)
            {
                if (ViewState["ShowInactive"] == null)
                    ShowInactive = false;

                LoadFilters();
            }

            LoadAll(); // ✅ ALWAYS load like AddStudent
        }

        private void LoadAll()
        {
            LoadStats();
            LoadHierarchy();
        }

        private void LoadStats()
        {
            int instituteId = Convert.ToInt32(Session["InstituteId"]);

            DataTable dt = bl.GetStudents(
                instituteId,
                txtSearch.Text.Trim(),
                ShowInactive ? "0" : "1"
            );

            TotalStudents = dt.Rows.Count;
            ActiveStudents = dt.Select("IsActive=1").Length;
            InactiveStudents = dt.Select("IsActive=0").Length;
        }

        private void LoadHierarchy()
        {
            int instituteId = Convert.ToInt32(Session["InstituteId"]);

            DataTable dt = bl.GetStudents(
                instituteId,
                txtSearch.Text.Trim(),
                ShowInactive ? "0" : "1"
            );

            var data = dt.AsEnumerable();

            // ✅ APPLY FILTERS
            if (!string.IsNullOrEmpty(ddlStream.SelectedValue))
                data = data.Where(x => x["StreamId"].ToString() == ddlStream.SelectedValue);

            if (!string.IsNullOrEmpty(ddlCourse.SelectedValue))
                data = data.Where(x => x["CourseId"].ToString() == ddlCourse.SelectedValue);

            if (!string.IsNullOrEmpty(ddlLevel.SelectedValue))
                data = data.Where(x => x["LevelId"].ToString() == ddlLevel.SelectedValue);

            if (!string.IsNullOrEmpty(ddlSemester.SelectedValue))
                data = data.Where(x => x["SemesterId"].ToString() == ddlSemester.SelectedValue);

            if (!string.IsNullOrEmpty(ddlSection.SelectedValue))
                data = data.Where(x => x["SectionId"].ToString() == ddlSection.SelectedValue);

            if (!data.Any())
            {
                rptHierarchy.DataSource = null;
                rptHierarchy.DataBind();
                return;
            }

            // ✅ SORT STUDENTS BY ROLL NUMBER
            data = data.OrderBy(x => x["RollNumber"]);

            // ✅ MULTI-LEVEL GROUPING
            var result = data
                .GroupBy(s => s["StreamName"])
                .Select(stream => new
                {
                    StreamName = stream.Key,
                    Courses = stream.GroupBy(c => c["CourseName"])
                        .Select(course => new
                        {
                            CourseName = course.Key,
                            Levels = course.GroupBy(l => l["LevelName"])
                                .Select(level => new
                                {
                                    LevelName = level.Key,
                                    Semesters = level.GroupBy(se => se["SemesterName"])
                                        .Select(sem => new
                                        {
                                            SemesterName = sem.Key,
                                            Sections = sem.GroupBy(sec => sec["SectionName"])
                                                .Select(sec => new
                                                {
                                                    SectionName = sec.Key,
                                                    Students = sec.CopyToDataTable()
                                                })
                                        })
                                })
                        })
                });

            rptHierarchy.DataSource = result;
            rptHierarchy.DataBind();
        }

        public bool ShowInactive
        {
            get { return ViewState["ShowInactive"] != null && (bool)ViewState["ShowInactive"]; }
            set { ViewState["ShowInactive"] = value; }
        }

        protected void ToggleView_Click(object sender, EventArgs e)
        {
            ShowInactive = !ShowInactive;

            btnToggleView.Text = ShowInactive
                ? "👁 View Active"
                : "👁 View Inactive";

            LoadAll(); // ✅ works now correctly
            LoadStats();
        }

        protected void FilterChanged(object sender, EventArgs e)
        {
            LoadHierarchy();
            LoadAll();
        }

        private void LoadFilters()
        {
            int instituteId = Convert.ToInt32(Session["InstituteId"]);
            DataLayer dl = new DataLayer();

            // ✅ STREAM
            SqlCommand cmdStream = new SqlCommand(
                "SELECT StreamId, StreamName FROM Streams WHERE InstituteId=@I");
            cmdStream.Parameters.AddWithValue("@I", instituteId);

            ddlStream.DataSource = dl.GetDataTable(cmdStream);
            ddlStream.DataTextField = "StreamName";
            ddlStream.DataValueField = "StreamId";
            ddlStream.DataBind();
            ddlStream.Items.Insert(0, new ListItem("Stream", ""));

            // ✅ COURSE
            SqlCommand cmdCourse = new SqlCommand(
                "SELECT CourseId, CourseName FROM Courses WHERE InstituteId=@I");
            cmdCourse.Parameters.AddWithValue("@I", instituteId);

            ddlCourse.DataSource = dl.GetDataTable(cmdCourse);
            ddlCourse.DataTextField = "CourseName";
            ddlCourse.DataValueField = "CourseId";
            ddlCourse.DataBind();
            ddlCourse.Items.Insert(0, new ListItem("Course", ""));

            // ✅ LEVEL
            SqlCommand cmdLevel = new SqlCommand(
                "SELECT LevelId, LevelName FROM StudyLevels WHERE InstituteId=@I");
            cmdLevel.Parameters.AddWithValue("@I", instituteId);

            ddlLevel.DataSource = dl.GetDataTable(cmdLevel);
            ddlLevel.DataTextField = "LevelName";
            ddlLevel.DataValueField = "LevelId";
            ddlLevel.DataBind();
            ddlLevel.Items.Insert(0, new ListItem("Level", ""));

            // ✅ SEMESTER
            SqlCommand cmdSem = new SqlCommand(
                "SELECT SemesterId, SemesterName FROM Semesters WHERE InstituteId=@I");
            cmdSem.Parameters.AddWithValue("@I", instituteId);

            ddlSemester.DataSource = dl.GetDataTable(cmdSem);
            ddlSemester.DataTextField = "SemesterName";
            ddlSemester.DataValueField = "SemesterId";
            ddlSemester.DataBind();
            ddlSemester.Items.Insert(0, new ListItem("Semester", ""));

            // ✅ SECTION
            SqlCommand cmdSec = new SqlCommand(
                "SELECT SectionId, SectionName FROM Sections WHERE InstituteId=@I");
            cmdSec.Parameters.AddWithValue("@I", instituteId);

            ddlSection.DataSource = dl.GetDataTable(cmdSec);
            ddlSection.DataTextField = "SectionName";
            ddlSection.DataValueField = "SectionId";
            ddlSection.DataBind();
            ddlSection.Items.Insert(0, new ListItem("Section", ""));
        }
    }
}