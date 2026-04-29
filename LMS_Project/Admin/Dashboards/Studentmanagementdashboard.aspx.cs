using LearningManagementSystem.Admin.Dashboards;
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Net.Security;
using System.Text;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace LearningManagementSystem.Admin
{
    public partial class StudentManagementDashboard : BasePage
    {
        private readonly StudentManagementDashboardBL bl = new StudentManagementDashboardBL();
        
        private const int PAGE_SIZE = 15;

        // ── Filters (read from controls each time) ──────────────
        private int StreamId => SafeInt(ddlStream.SelectedValue);
        private int CourseId => SafeInt(ddlCourse.SelectedValue);
        private int SemesterId => SafeInt(ddlSemester.SelectedValue);
        private int SectionId => SafeInt(ddlSection.SelectedValue);
        private string Gender => ddlGender.SelectedValue;
        private string JoinMonth => ddlMonth.SelectedValue;
        private string JoinYear => ddlYear.SelectedValue;
        private string Search => txtSearch.Text.Trim();
        private int PageIdx => SafeInt(hdnPage.Value);

        // ════════════════════════════════════════════════════════
        // PAGE LOAD
        // ════════════════════════════════════════════════════════
        protected void Page_Load(object sender, EventArgs e)
        {

            // AJAX handler — returns JSON, skips full page render
            if (Request.QueryString["ajax"] == "1")
            {
                HandleAjax();
                Response.End();
                return;
            }

            if (!IsPostBack)
            {
                InitDropdowns();
                lblSessionName.Text = Session["SessionName"]?.ToString() ?? "";
                LoadAll();
            }
        }

        // ════════════════════════════════════════════════════════
        // AJAX JSON HANDLER — live filter without full postback
        // ════════════════════════════════════════════════════════
        private void HandleAjax()
        {
            Response.ContentType = "application/json";
            Response.Cache.SetCacheability(HttpCacheability.NoCache);

            string action = Request.QueryString["action"] ?? "all";
            int instId = SafeInt(Request.QueryString["inst"]);
            int sessId = SafeInt(Request.QueryString["sess"]);
            int streamId = SafeInt(Request.QueryString["stream"]);
            int courseId = SafeInt(Request.QueryString["course"]);
            int semId = SafeInt(Request.QueryString["semester"]);
            int secId = SafeInt(Request.QueryString["section"]);
            string gender = Request.QueryString["gender"] ?? "";
            string month = Request.QueryString["month"] ?? "";
            string year = Request.QueryString["year"] ?? "";
            string search = Request.QueryString["search"] ?? "";
            int pageIdx = SafeInt(Request.QueryString["page"]);

            try
            {
                var obj = new System.Collections.Generic.Dictionary<string, object>();

                // KPIs
                DataTable dtKPI = bl.GetKPISummary(instId, sessId, streamId, courseId, semId, secId, gender, month, year);
                if (dtKPI?.Rows.Count > 0)
                {
                    var r = dtKPI.Rows[0];
                    obj["kpi"] = new
                    {
                        total = r["TotalStudents"],
                        active = r["ActiveStudents"],
                        inactive = r["InactiveStudents"],
                        newAdm = r["NewAdmissions"],
                        attPct = r["AttendancePct"],
                        assignRate = r["AssignmentRate"],
                        avgQuiz = r["AvgQuizScore"],
                        males = r["Males"],
                        females = r["Females"],
                        others = r["Others"]
                    };
                }

                // Charts
                obj["enrollment"] = DtToList(bl.GetMonthlyEnrollment(instId, sessId, streamId, courseId),
                    "Mon", "Students", "Active");
                obj["attendance"] = DtToList(bl.GetAttendanceTrend(instId, sessId, streamId, courseId, secId),
                    "DayLbl", "AttPct", "Present", "Absent");
                obj["gender"] = DtToList(bl.GetGenderDistribution(instId, sessId, streamId, courseId),
                    "Gender", "Total");
                obj["streamCount"] = DtToList(bl.GetStreamWiseCount(instId, sessId),
                    "StreamName", "Students");
                obj["courseCount"] = DtToList(bl.GetCourseWiseCount(instId, sessId, streamId),
                    "CourseName", "Students");
                obj["grades"] = DtToList(bl.GetGradeDistribution(instId, sessId, streamId, courseId),
                    "GradeLabel", "Students");
                obj["sectionCount"] = DtToList(bl.GetSectionWiseCount(instId, sessId, streamId, courseId),
                    "SectionName", "Students");
                obj["admByMonth"] = DtToList(bl.GetAdmissionsByMonth(instId, sessId, year),
                    "Mon", "Count");

                // Student list + pagination
                int total = bl.GetStudentCount(instId, sessId, streamId, courseId, semId, secId, gender, month, year, search);
                DataTable dtList = bl.GetStudentList(instId, sessId, streamId, courseId, semId, secId,
                    gender, month, year, search, pageIdx, PAGE_SIZE);
                obj["students"] = DtToRows(dtList);
                obj["totalCount"] = total;
                obj["pageSize"] = PAGE_SIZE;
                obj["pageIndex"] = pageIdx;
                obj["pageCount"] = (int)Math.Ceiling((double)total / PAGE_SIZE);

                // Top / At-risk
                obj["topStudents"] = DtToRows(bl.GetTopStudents(instId, sessId, streamId, courseId));
                obj["atRisk"] = DtToRows(bl.GetAtRiskStudents(instId, sessId, streamId, courseId));

                // Courses for cascade filter
                obj["courses"] = DtToList(bl.GetCoursesByStream(instId, sessId, streamId),
                    "CourseId", "CourseDisplay");

                Response.Write(new JavaScriptSerializer().Serialize(obj));
            }
            catch (Exception ex)
            {
                Response.StatusCode = 500;
                Response.Write("{\"error\":\"" + ex.Message.Replace("\"", "'") + "\"}");
            }
        }

        // ════════════════════════════════════════════════════════
        // INIT DROPDOWNS — only on first load
        // ════════════════════════════════════════════════════════
        private void InitDropdowns()
        {
            // Streams
            ddlStream.Items.Clear();
            ddlStream.Items.Add(new ListItem("All Streams", "0"));
            DataTable dt = bl.GetStreams(InstituteId, SessionId);
            foreach (DataRow r in dt.Rows)
                ddlStream.Items.Add(new ListItem(r["StreamName"].ToString(), r["StreamId"].ToString()));

            // Courses (all initially)
            ddlCourse.Items.Clear();
            ddlCourse.Items.Add(new ListItem("All Courses", "0"));
            DataTable dtC = bl.GetCoursesByStream(InstituteId, SessionId, 0);
            foreach (DataRow r in dtC.Rows)
                ddlCourse.Items.Add(new ListItem(r["CourseDisplay"].ToString(), r["CourseId"].ToString()));

            // Semesters
            ddlSemester.Items.Clear();
            ddlSemester.Items.Add(new ListItem("All Semesters", "0"));
            DataTable dtSem = bl.GetSemesters(InstituteId, SessionId);
            foreach (DataRow r in dtSem.Rows)
                ddlSemester.Items.Add(new ListItem(r["SemesterName"].ToString(), r["SemesterId"].ToString()));

            // Sections
            ddlSection.Items.Clear();
            ddlSection.Items.Add(new ListItem("All Sections", "0"));
            DataTable dtSec = bl.GetSections(InstituteId, SessionId);
            foreach (DataRow r in dtSec.Rows)
                ddlSection.Items.Add(new ListItem(r["SectionName"].ToString(), r["SectionId"].ToString()));

            // Gender
            ddlGender.Items.Clear();
            ddlGender.Items.Add(new ListItem("All Genders", ""));
            ddlGender.Items.Add(new ListItem("Male", "Male"));
            ddlGender.Items.Add(new ListItem("Female", "Female"));
            ddlGender.Items.Add(new ListItem("Other", "Other"));

            // Month
            ddlMonth.Items.Clear();
            ddlMonth.Items.Add(new ListItem("All Months", ""));
            string[] months = { "January","February","March","April","May","June",
                                 "July","August","September","October","November","December" };
            for (int i = 1; i <= 12; i++)
                ddlMonth.Items.Add(new ListItem(months[i - 1], i.ToString()));

            // Year
            ddlYear.Items.Clear();
            ddlYear.Items.Add(new ListItem("All Years", ""));
            int curY = DateTime.Now.Year;
            for (int y = curY; y >= curY - 5; y--)
                ddlYear.Items.Add(new ListItem(y.ToString(), y.ToString()));
        }

        // ════════════════════════════════════════════════════════
        // INITIAL SERVER-SIDE LOAD (for SEO + first render speed)
        // ════════════════════════════════════════════════════════
        private void LoadAll()
        {
            // Pass config to JS
            hdnInstId.Value = InstituteId.ToString();
            hdnSessId.Value = SessionId.ToString();
        }

        // ════════════════════════════════════════════════════════
        // HELPERS
        // ════════════════════════════════════════════════════════
        private int SafeInt(string v)
        {
            int r; return int.TryParse(v, out r) ? r : 0;
        }

        // Convert DataTable to list of objects (for JSON) — named cols
        private List<Dictionary<string, object>> DtToList(DataTable dt, params string[] cols)
        {
            var list = new List<Dictionary<string, object>>();
            if (dt == null) return list;
            foreach (DataRow row in dt.Rows)
            {
                var d = new Dictionary<string, object>();
                foreach (var c in cols)
                    d[c] = dt.Columns.Contains(c) ? row[c] : null;
                list.Add(d);
            }
            return list;
        }

        // Convert full DataTable rows to list of row dicts
        private List<Dictionary<string, object>> DtToRows(DataTable dt)
        {
            var list = new List<Dictionary<string, object>>();
            if (dt == null) return list;
            foreach (DataRow row in dt.Rows)
            {
                var d = new Dictionary<string, object>();
                foreach (DataColumn col in dt.Columns)
                    d[col.ColumnName] = row[col] == DBNull.Value ? null : row[col];
                list.Add(d);
            }
            return list;
        }
    }
}