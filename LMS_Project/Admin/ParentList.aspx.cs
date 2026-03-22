using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web.UI;

namespace LearningManagementSystem.Admin
{
    public partial class ParentList : Page
    {
        ParentBL bl = new ParentBL();

        public string CurrentFilter
        {
            get { return ViewState["Filter"] == null ? "1" : ViewState["Filter"].ToString(); }
            set { ViewState["Filter"] = value; }
        }

        public int TotalParents = 0;
        public int ActiveParents = 0;
        public int InactiveParents = 0;
        public int TotalLinks = 0;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["InstituteId"] == null)
                Response.Redirect("~/Default.aspx");

            if (!IsPostBack)
            {
                CurrentFilter = "1";
                LoadData();
                LoadStats();
            }
        }

        protected void ToggleView_Click(object sender, EventArgs e)
        {
            CurrentFilter = CurrentFilter == "1" ? "0" : "1";

            btnToggleView.Text = CurrentFilter == "1"
                ? "👁 View Inactive"
                : "👁 View Active";

            LoadData();
            LoadStats();
        }

        private void LoadData()
        {
            int instituteId = Convert.ToInt32(Session["InstituteId"]);
            bool isActive = CurrentFilter == "1";

            DataTable dt = bl.GetParentsWithStudentDetails(instituteId, isActive);

            var grouped = dt.AsEnumerable()
                .GroupBy(r => new
                {
                    StudentId = r["StudentId"],
                    StudentName = r["StudentName"],
                    Stream = r["StreamName"],
                    Course = r["CourseName"],
                    Level = r["LevelName"],
                    Semester = r["SemesterName"],
                    Section = r["SectionName"],
                    Session = r["SessionName"]
                })
                .Select(g => new
                {
                    StudentName = g.Key.StudentName,
                    Stream = g.Key.Stream == DBNull.Value ? "-" : g.Key.Stream.ToString(),
                    Course = g.Key.Course == DBNull.Value ? "-" : g.Key.Course.ToString(),
                    Level = g.Key.Level == DBNull.Value ? "-" : g.Key.Level.ToString(),
                    Semester = g.Key.Semester == DBNull.Value ? "-" : g.Key.Semester.ToString(),
                    Section = g.Key.Section == DBNull.Value ? "-" : g.Key.Section.ToString(),
                    Session = g.Key.Session == DBNull.Value ? "-" : g.Key.Session.ToString(),

                    Parents = g.Select(x => new
                    {
                        ParentName = x["ParentName"],
                        Relation = x["RelationshipType"],
                        Email = x["Email"],
                        ContactNo = x["ContactNo"]
                    })
                });

            rptStudents.DataSource = grouped;
            rptStudents.DataBind();
        }

        private void LoadStats()
        {
            int instituteId = Convert.ToInt32(Session["InstituteId"]);
            DataTable dt = bl.GetStats(instituteId);

            if (dt.Rows.Count > 0)
            {
                TotalParents = Convert.ToInt32(dt.Rows[0]["TotalParents"]);
                ActiveParents = Convert.ToInt32(dt.Rows[0]["ActiveParents"]);
                InactiveParents = Convert.ToInt32(dt.Rows[0]["InactiveParents"]);
                TotalLinks = Convert.ToInt32(dt.Rows[0]["TotalLinks"]);
            }
        }
    }
}