using LMS.BL;
using System;
using System.Data;
using System.Text;
using System.Web.UI;

namespace LMS_Project.SuperAdmin
{
    public partial class Dashboard : Page
    {
        private readonly SuperAdminDashboardBL _bl = new SuperAdminDashboardBL();

        // ── Hidden field IDs exposed to JS via ClientID ───────────────────────
        // All hf* controls declared in ASPX

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
                LoadAll();
        }

        private void LoadAll()
        {
            LoadKPIs();
            LoadSocieties();
            LoadTopInstitutes();
            LoadCharts();
            LoadActivity();
            LoadSystemHealth();
        }

        // ── KPIs ─────────────────────────────────────────────────────────────
        private void LoadKPIs()
        {
            DataTable dt = _bl.GetPlatformKPIs();
            if (dt.Rows.Count == 0) return;
            DataRow r = dt.Rows[0];

            // Bind to hidden fields for JS count-up
            hfSocieties.Value = S(r["TotalSocieties"]);
            hfInstitutes.Value = S(r["TotalInstitutes"]);
            hfUsers.Value = S(r["TotalUsers"]);
            hfStudents.Value = S(r["TotalStudents"]);
            hfTeachers.Value = S(r["TotalTeachers"]);
            hfVideos.Value = S(r["TotalVideos"]);
            hfAssignments.Value = S(r["TotalAssignments"]);
            hfSessions.Value = S(r["ActiveSessions"]);
            hfActiveSoc.Value = S(r["ActiveSocieties"]);
            hfActiveInst.Value = S(r["ActiveInstitutes"]);
            hfNewStudents.Value = S(r["NewStudentsThisMonth"]);
            hfInstThisMonth.Value = S(r["InstThisMonth"]);
            hfTodayAct.Value = S(r["TodayActivities"]);
            hfTotalViews.Value = S(r["TotalVideoViews"]);
        }

        // ── Societies Table ──────────────────────────────────────────────────
        private void LoadSocieties()
        {
            DataTable dt = _bl.GetSocietiesOverview();
            rptSocieties.DataSource = dt;
            rptSocieties.DataBind();
        }

        // ── Top Institutes ───────────────────────────────────────────────────
        private void LoadTopInstitutes()
        {
            DataTable dt = _bl.GetTopInstitutes(8);
            rptTopInstitutes.DataSource = dt;
            rptTopInstitutes.DataBind();
        }

        // ── Charts JSON ──────────────────────────────────────────────────────
        private void LoadCharts()
        {
            // User growth trend
            DataTable dtGrowth = _bl.GetUserGrowthTrend();
            hfGrowthLabels.Value = JsonArray(dtGrowth, "MonthLabel", true);
            hfGrowthStudents.Value = JsonArray(dtGrowth, "NewStudents", false);
            hfGrowthTeachers.Value = JsonArray(dtGrowth, "NewTeachers", false);
            hfGrowthTotal.Value = JsonArray(dtGrowth, "TotalNew", false);

            // Users by role
            DataTable dtRoles = _bl.GetUsersByRole();
            hfRoleLabels.Value = JsonArray(dtRoles, "RoleName", true);
            hfRoleCounts.Value = JsonArray(dtRoles, "UserCount", false);

            // Institutes by society
            DataTable dtInstBySoc = _bl.GetInstitutesBySociety();
            hfSocLabels.Value = JsonArray(dtInstBySoc, "SocietyName", true);
            hfSocActive.Value = JsonArray(dtInstBySoc, "Active", false);
            hfSocInactive.Value = JsonArray(dtInstBySoc, "Inactive", false);

            // Institute growth
            DataTable dtInstGrow = _bl.GetInstituteGrowthTrend();
            hfInstGrowLabels.Value = JsonArray(dtInstGrow, "MonthLabel", true);
            hfInstGrowCounts.Value = JsonArray(dtInstGrow, "NewInstitutes", false);
        }

        // ── Activity ─────────────────────────────────────────────────────────
        private void LoadActivity()
        {
            DataTable dt = _bl.GetRecentActivity();
            rptActivity.DataSource = dt;
            rptActivity.DataBind();
        }

        // ── System Health ────────────────────────────────────────────────────
        private void LoadSystemHealth()
        {
            DataTable dt = _bl.GetSystemHealth();
            if (dt.Rows.Count == 0) return;
            DataRow r = dt.Rows[0];

            hfHealthVideos.Value = S(r["Videos"]);
            hfHealthViews.Value = S(r["TotalViews"]);
            hfHealthAssign.Value = S(r["Assignments"]);
            hfHealthSubs.Value = S(r["Submissions"]);
            hfHealthAtt.Value = S(r["AttendanceRecords"]);
            hfHealthSubjects.Value = S(r["Subjects"]);
            hfHealthLoginsToday.Value = S(r["LoginsToday"]);
            hfHealthActiveWeek.Value = S(r["ActiveUsersWeek"]);
        }

        // ════════════════════════════════════════════════════════════════════
        //  HELPER METHODS
        // ════════════════════════════════════════════════════════════════════

        protected string FmtDate(object val)
            => val != null && val != DBNull.Value
               && DateTime.TryParse(val.ToString(), out DateTime d)
               ? d.ToString("dd MMM yyyy") : "—";

        protected string FmtDateTime(object val)
            => val != null && val != DBNull.Value
               && DateTime.TryParse(val.ToString(), out DateTime d)
               ? d.ToString("dd MMM yy, hh:mm tt") : "—";

        protected string ActivityIcon(object type)
        {
            switch (type?.ToString())
            {
                case "StudentAdded": return "fa-user-plus";
                case "TeacherAdded": return "fa-chalkboard-teacher";
                case "VideoUploaded": return "fa-video";
                case "AssignmentAdded": return "fa-file-alt";
                case "Login": return "fa-sign-in-alt";
                case "StudentReEnrolled": return "fa-sync";
                default: return "fa-circle";
            }
        }

        protected string RoleColor(object role)
        {
            switch (role?.ToString())
            {
                case "Student": return "#4f46e5";
                case "Teacher": return "#059669";
                case "Admin": return "#d97706";
                case "Parent": return "#0891b2";
                default: return "#94a3b8";
            }
        }

        protected string StatusBadge(object isActive)
        {
            bool active = isActive != null && isActive != DBNull.Value
                          && Convert.ToBoolean(isActive);
            return active
                ? "<span class='sa-badge green'>Active</span>"
                : "<span class='sa-badge red'>Inactive</span>";
        }

        protected string H(object v)
            => System.Web.HttpUtility.HtmlEncode(v?.ToString() ?? "");

        private static string S(object v) => v?.ToString() ?? "0";

        private static string JsonArray(DataTable dt, string col, bool isString)
        {
            if (dt == null || dt.Rows.Count == 0) return "[]";
            var sb = new StringBuilder("[");
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                if (i > 0) sb.Append(",");
                string val = dt.Rows[i][col]?.ToString() ?? "";
                if (isString) sb.Append($"\"{val.Replace("\"", "\\\"").Replace("'", "\\'")}\"");
                else sb.Append(string.IsNullOrEmpty(val) ? "0" : val);
            }
            sb.Append("]");
            return sb.ToString();
        }
    }
}