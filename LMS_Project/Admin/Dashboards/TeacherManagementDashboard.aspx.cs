using System;
using System.Collections.Generic;
using System.Data;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace LearningManagementSystem.Admin
{
    public partial class TeacherManagementDashboard : Page
    {
        private readonly TeacherManagementDashboardBL bl = new TeacherManagementDashboardBL();
        private int InstituteId, SessionId;
        private const int PAGE_SIZE = 12;

        // ── Filters ──────────────────────────────────────────────
        private int StreamId => SafeInt(ddlStream.SelectedValue);
        private int SectionId => SafeInt(ddlSection.SelectedValue);
        private string Designation => ddlDesignation.SelectedValue;
        private string JoinMonth => ddlMonth.SelectedValue;
        private string JoinYear => ddlYear.SelectedValue;

        // ════════════════════════════════════════════════════════
        // PAGE LOAD
        // ════════════════════════════════════════════════════════
        protected void Page_Load(object sender, EventArgs e)
        {
           

            InstituteId = Convert.ToInt32(Session["InstituteId"]);
            SessionId = Convert.ToInt32(Session["SessionId"]);

            // AJAX route — returns JSON, no page render
            if (Request.QueryString["ajax"] == "1")
            {
                HandleAjax();
                Response.End();
                return;
            }

            if (!IsPostBack)
            {
                InitDropdowns();
                hdnInstId.Value = InstituteId.ToString();
                hdnSessId.Value = SessionId.ToString();
                lblSession.Text = Session["SessionName"]?.ToString() ?? "";
            }
        }

        // ════════════════════════════════════════════════════════
        // AJAX HANDLER
        // ════════════════════════════════════════════════════════
        private void HandleAjax()
        {
            Response.ContentType = "application/json";
            Response.Cache.SetCacheability(HttpCacheability.NoCache);

            int instId = SafeInt(Request.QueryString["inst"]);
            int sessId = SafeInt(Request.QueryString["sess"]);
            int streamId = SafeInt(Request.QueryString["stream"]);
            int secId = SafeInt(Request.QueryString["section"]);
            string desig = Request.QueryString["desig"] ?? "";
            string month = Request.QueryString["month"] ?? "";
            string year = Request.QueryString["year"] ?? "";
            string search = Request.QueryString["search"] ?? "";
            int pageIdx = SafeInt(Request.QueryString["page"]);

            try
            {
                var obj = new Dictionary<string, object>();

                // ── KPIs ──────────────────────────────────────
                DataTable dtKPI = bl.GetKPISummary(instId, sessId, streamId, secId, desig, month, year);
                if (dtKPI?.Rows.Count > 0)
                {
                    var r = dtKPI.Rows[0];
                    obj["kpi"] = new
                    {
                        total = r["TotalTeachers"],
                        active = r["ActiveTeachers"],
                        inactive = r["InactiveTeachers"],
                        newJoined = r["NewJoined"],
                        videos = r["TotalVideos"],
                        assignments = r["TotalAssignments"],
                        quizzes = r["TotalQuizzes"],
                        avgExp = r["AvgExperience"],
                        subjects = r["SubjectsTaught"],
                        students = r["TotalStudents"],
                        males = r["Males"],
                        females = r["Females"]
                    };
                }

                // ── Charts ────────────────────────────────────
                obj["joiningTrend"] = DtToList(bl.GetMonthlyJoiningTrend(instId, sessId),
                                            "Mon", "Teachers");
                obj["streamWise"] = DtToList(bl.GetStreamWiseTeachers(instId, sessId),
                                            "StreamName", "Teachers");
                obj["designation"] = DtToList(bl.GetDesignationWiseCount(instId, sessId),
                                            "Designation", "Teachers");
                obj["experience"] = DtToList(bl.GetExperienceDistribution(instId, sessId),
                                            "ExpBucket", "Teachers");
                obj["gender"] = DtToList(bl.GetGenderDistribution(instId, sessId, streamId),
                                            "Gender", "Total");
                obj["contentTrend"] = DtToList(bl.GetContentOutputTrend(instId, sessId, streamId),
                                            "WeekLabel", "Videos", "Assignments", "Quizzes");
                obj["subjectWise"] = DtToList(bl.GetSubjectWiseTeachers(instId, sessId, streamId),
                                            "SubjectName", "Teachers", "Videos", "Assignments");
                obj["qualification"] = DtToList(bl.GetQualificationDistribution(instId, sessId),
                                            "Qualification", "Teachers");
                obj["recentActivity"] = DtToRows(bl.GetRecentActivity(instId, sessId, streamId));

                // ── Performance metrics ────────────────────────
                DataTable dtMetrics = bl.GetTeacherPerformanceMetrics(instId, sessId, streamId);
                if (dtMetrics?.Rows.Count > 0)
                {
                    var r = dtMetrics.Rows[0];
                    obj["perfMetrics"] = new
                    {
                        avgVideos = r["AvgVideos"],
                        avgAssignments = r["AvgAssignments"],
                        avgQuizzes = r["AvgQuizzes"],
                        avgStudents = r["AvgStudents"],
                        avgVideoViews = r["AvgVideoViews"],
                        avgScore = r["AvgStudentScore"]
                    };
                }

                // ── Top teachers ──────────────────────────────
                obj["topTeachers"] = DtToRows(bl.GetTopTeachersByContent(instId, sessId, streamId));

                // ── Teacher list + pagination ──────────────────
                int total = bl.GetTeacherCount(instId, sessId, streamId, secId, desig, month, year, search);
                DataTable dtList = bl.GetTeacherList(instId, sessId, streamId, secId, desig,
                                        month, year, search, pageIdx, PAGE_SIZE);
                obj["teachers"] = DtToRows(dtList);
                obj["totalCount"] = total;
                obj["pageSize"] = PAGE_SIZE;
                obj["pageIndex"] = pageIdx;
                obj["pageCount"] = (int)Math.Ceiling((double)total / PAGE_SIZE);

                // Cascade: courses for stream
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
        // INIT DROPDOWNS
        // ════════════════════════════════════════════════════════
        private void InitDropdowns()
        {
            // Streams
            ddlStream.Items.Clear();
            ddlStream.Items.Add(new ListItem("All Streams", "0"));
            var dt = bl.GetStreams(InstituteId, SessionId);
            foreach (DataRow r in dt.Rows)
                ddlStream.Items.Add(new ListItem(r["StreamName"].ToString(), r["StreamId"].ToString()));

            // Sections
            ddlSection.Items.Clear();
            ddlSection.Items.Add(new ListItem("All Sections", "0"));
            dt = bl.GetSections(InstituteId, SessionId);
            foreach (DataRow r in dt.Rows)
                ddlSection.Items.Add(new ListItem(r["SectionName"].ToString(), r["SectionId"].ToString()));

            // Designations
            ddlDesignation.Items.Clear();
            ddlDesignation.Items.Add(new ListItem("All Designations", ""));
            dt = bl.GetDesignations(InstituteId, SessionId);
            foreach (DataRow r in dt.Rows)
                ddlDesignation.Items.Add(new ListItem(r["Designation"].ToString(), r["Designation"].ToString()));

            // Month
            ddlMonth.Items.Clear();
            ddlMonth.Items.Add(new ListItem("All Months", ""));
            string[] months = {"January","February","March","April","May","June",
                                "July","August","September","October","November","December"};
            for (int i = 1; i <= 12; i++)
                ddlMonth.Items.Add(new ListItem(months[i - 1], i.ToString()));

            // Year
            ddlYear.Items.Clear();
            ddlYear.Items.Add(new ListItem("All Years", ""));
            int cur = DateTime.Now.Year;
            for (int y = cur; y >= cur - 5; y--)
                ddlYear.Items.Add(new ListItem(y.ToString(), y.ToString()));
        }

        // ════════════════════════════════════════════════════════
        // HELPERS
        // ════════════════════════════════════════════════════════
        private int SafeInt(string v) { int r; return int.TryParse(v, out r) ? r : 0; }

        private List<Dictionary<string, object>> DtToList(DataTable dt, params string[] cols)
        {
            var list = new List<Dictionary<string, object>>();
            if (dt == null) return list;
            foreach (DataRow row in dt.Rows)
            {
                var d = new Dictionary<string, object>();
                foreach (var c in cols)
                    d[c] = dt.Columns.Contains(c) ? (row[c] == DBNull.Value ? null : row[c]) : null;
                list.Add(d);
            }
            return list;
        }

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