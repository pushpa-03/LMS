using LearningManagementSystem.GC;
using System;
using System.Data;
using System.Web.UI;

namespace LMS_Project.Admin
{
    public partial class OverviewDashboard : BasePage
    {
        OverviewDashboardBL bl = new OverviewDashboardBL();
        

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadDashboard();
            }
        }

        private void LoadDashboard()
        {
            DataSet ds = bl.GetYearlyOverviewStats(InstituteId, SessionId);

            if (ds != null && ds.Tables.Count > 0)
            {
                if (ds.Tables[0].Rows.Count > 0)
                {
                    DataRow r = ds.Tables[0].Rows[0];

                    lblTotalStudents.Text = r["TotalStudents"]?.ToString() ?? "0";
                    lblTotalTeachers.Text = r["TotalTeachers"]?.ToString() ?? "0";
                    lblTotalStreams.Text = r["TotalStreams"]?.ToString() ?? "0";
                    lblTotalCourses.Text = r["TotalCourses"]?.ToString() ?? "0";
                    lblTotalSubjects.Text = r["TotalSubjects"]?.ToString() ?? "0";                    
                    lblTotalChapters.Text = r["TotalChapters"]?.ToString() ?? "0";
                    lblTotalAssignments.Text = r["TotalAssignments"]?.ToString() ?? "0";
                    lblTotalVideos.Text = r["TotalVideos"]?.ToString() ?? "0";
                    lblTotalQuizzes.Text = r["TotalQuizzes"]?.ToString() ?? "0";
                    lblTotalSections.Text = r["TotalSections"]?.ToString() ?? "0";
                }

                if (ds.Tables.Count > 1)
                    hdnMonthlyGrowth.Value = DataTableToJson(ds.Tables[1], "Month", "NewStudents");

                if (ds.Tables.Count > 2)
                    hdnTopCourses.Value = DataTableToJson(ds.Tables[2], "CourseName", "StudentCount");

                if (ds.Tables.Count > 3 && ds.Tables[3].Rows.Count > 0)
                {
                    decimal att = Convert.ToDecimal(ds.Tables[3].Rows[0]["OverallAttendance"]);
                    lblAttendance.Text = att.ToString("0.##");
                }

                if (ds.Tables.Count > 4)
                    hdnTopSubjects.Value = DataTableToJson(ds.Tables[4], "SubjectName", "VideoCount");
            }

            rptRecentActivity.DataSource = bl.GetRecentActivities(InstituteId, SessionId);
            rptRecentActivity.DataBind();

            hdnStreamData.Value = DataTableToJson(
                bl.GetStreamWiseStudents(InstituteId, SessionId),
                "StreamName",
                "Students"
            );
        }

        private string DataTableToJson(DataTable dt, string labelCol, string valueCol)
        {
            if (dt == null || dt.Rows.Count == 0) return "[]";

            var sb = new System.Text.StringBuilder("[");
            foreach (DataRow row in dt.Rows)
            {
                sb.Append("{");
                sb.AppendFormat("\"label\":\"{0}\",", row[labelCol].ToString().Replace("\"", "\\\""));
                sb.AppendFormat("\"value\":{0}", string.IsNullOrEmpty(row[valueCol].ToString()) ? "0" : row[valueCol].ToString());
                sb.Append("},");
            }
            sb.Length--;
            sb.Append("]");
            return sb.ToString();
        }

        private static readonly string[] AvatarColors = {
            "#6366f1","#8b5cf6","#06b6d4","#10b981",
            "#f59e0b","#ef4444","#ec4899","#3b82f6","#a855f7","#14b8a6"
        };

        protected string GetAvatarColor(int index)
        {
            return AvatarColors[index % AvatarColors.Length];
        }

        protected string GetInitials(string name)
        {
            if (string.IsNullOrWhiteSpace(name)) return "?";

            var parts = name.Trim().Split(' ');
            return parts.Length >= 2
                ? (parts[0][0].ToString() + parts[parts.Length - 1][0]).ToUpper()
                : name.Substring(0, 1).ToUpper();
        }

        protected string GetActivityIcon(string activityType)
        {
            if (activityType == null) return "fa-solid fa-bolt";

            switch (activityType.ToLower())
            {
                case "login": return "fa-solid fa-right-to-bracket";
                case "logout": return "fa-solid fa-right-from-bracket";
                case "assignment": return "fa-solid fa-file-pen";
                case "quiz": return "fa-solid fa-circle-question";
                case "video": return "fa-solid fa-clapperboard";
                case "attendance": return "fa-solid fa-circle-check";
                case "submission": return "fa-solid fa-paper-plane";
                default: return "fa-solid fa-bolt";
            }
        }

        protected string FormatTime(object dt)
        {
            if (dt == null || dt == DBNull.Value) return "—";

            DateTime d = Convert.ToDateTime(dt);
            TimeSpan diff = DateTime.Now - d;

            if (diff.TotalMinutes < 1) return "Just now";
            if (diff.TotalMinutes < 60) return ((int)diff.TotalMinutes) + "m ago";
            if (diff.TotalHours < 24) return ((int)diff.TotalHours) + "h ago";

            return d.ToString("dd MMM, hh:mm tt");
        }

        protected override void RaisePostBackEvent(IPostBackEventHandler sourceControl, string eventArgument)
        {
            if (eventArgument == "AutoRefresh")
            {
                LoadDashboard();
            }
            base.RaisePostBackEvent(sourceControl, eventArgument);
        }


    }
}