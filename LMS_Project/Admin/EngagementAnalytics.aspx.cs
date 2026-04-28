using LearningManagementSystem.BL;
using System;
using System.Data;
using System.Linq;

namespace LearningManagementSystem.Admin
{
    public partial class EngagementAnalytics : BasePage
    {
        AdminDashboardBL bl = new AdminDashboardBL();

        protected string TrendLabels, TrendData;
        protected string StudentLabels, StudentData;
        protected string SubjectLabels, SubjectData;

        protected int TotalViews, ActiveUsers, Completed, Pending, AvgTime;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadData();
            }
        }

        void LoadData()
        {
            LoadKPI();
            LoadTrend();
            LoadStudents();
            LoadSubjects();
        }

        void LoadKPI()
        {
            DataTable dt = bl.GetEngagementKPI(InstituteId, SessionId);

            if (dt.Rows.Count > 0)
            {
                var r = dt.Rows[0];

                TotalViews = Convert.ToInt32(r["Views"]);
                ActiveUsers = Convert.ToInt32(r["Users"]);
                Completed = Convert.ToInt32(r["Completed"]);
                Pending = 100 - Completed;
                AvgTime = Convert.ToInt32(r["AvgTime"]);
            }
        }

        void LoadTrend()
        {
            DataTable dt = bl.GetEngagementTrend(InstituteId, SessionId);

            TrendLabels = "[" + string.Join(",", dt.AsEnumerable().Select(r => "'" + r["Day"] + "'")) + "]";
            TrendData = "[" + string.Join(",", dt.AsEnumerable().Select(r => r["Total"])) + "]";
        }

        void LoadStudents()
        {
            DataTable dt = bl.GetTopStudents(InstituteId, SessionId);

            StudentLabels = "[" + string.Join(",", dt.AsEnumerable().Select(r => "'" + r["Username"] + "'")) + "]";
            StudentData = "[" + string.Join(",", dt.AsEnumerable().Select(r => r["Views"])) + "]";
        }

        void LoadSubjects()
        {
            DataTable dt = bl.GetSubjectEngagement(InstituteId, SessionId);

            SubjectLabels = "[" + string.Join(",", dt.AsEnumerable().Select(r => "'" + r["SubjectName"] + "'")) + "]";
            SubjectData = "[" + string.Join(",", dt.AsEnumerable().Select(r => r["Total"])) + "]";
        }
    }
}