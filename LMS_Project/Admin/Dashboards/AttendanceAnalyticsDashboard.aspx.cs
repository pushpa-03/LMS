using System;
using System.Collections.Generic;
using System.Data;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace LearningManagementSystem.Admin
{
    public partial class AttendanceAnalyticsDashboard : BasePage
    {
        private readonly AttendanceAnalyticsDashboardBL bl = new AttendanceAnalyticsDashboardBL();
 
        private const int PAGE_SIZE = 15;

        protected void Page_Load(object sender, EventArgs e)
        {
            

            if (Request.QueryString["ajax"] == "1")
            { HandleAjax(); Response.End(); return; }

            if (!IsPostBack)
            {
                InitDropdowns();
                hdnInstId.Value = InstituteId.ToString();
                hdnSessId.Value = SessionId.ToString();
                lblSession.Text = Session["SessionName"]?.ToString() ?? "";

                // Default date range: first day of current month → today
                string today = DateTime.Today.ToString("yyyy-MM-dd");
                string monthStart = new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1)
                                        .ToString("yyyy-MM-dd");
                hdnDateFrom.Value = monthStart;
                hdnDateTo.Value = today;
            }
        }

        // ══════════════════════════════════════════════════════
        // AJAX HANDLER
        // ══════════════════════════════════════════════════════
        private void HandleAjax()
        {
            Response.ContentType = "application/json";
            Response.Cache.SetCacheability(HttpCacheability.NoCache);

            int instId = SI("inst");
            int sessId = SI("sess");
            int streamId = SI("stream");
            int courseId = SI("course");
            int sectionId = SI("section");
            int subjectId = SI("subject");
            string dateFrom = QS("datefrom");
            string dateTo = QS("dateto");
            string gender = QS("gender");
            string search = QS("search");
            int pageIdx = SI("page");
            decimal threshold = SD("threshold", 75m);

            try
            {
                var obj = new Dictionary<string, object>();

                // KPIs
                DataTable dtK = bl.GetKPISummary(instId, sessId, streamId, courseId,
                                    sectionId, subjectId, dateFrom, dateTo, gender);
                if (dtK?.Rows.Count > 0)
                {
                    var r = dtK.Rows[0];
                    obj["kpi"] = new
                    {
                        totalRecords = r["TotalRecords"],
                        totalStudents = r["TotalStudents"],
                        totalDays = r["TotalDays"],
                        totalPresent = r["TotalPresent"],
                        totalAbsent = r["TotalAbsent"],
                        totalLeave = r["TotalLeave"],
                        overallPct = r["OverallPct"],
                        above75 = r["StudentsAbove75"],
                        below75 = r["StudentsBelow75"],
                        todayPct = r["TodayPct"]
                    };
                }

                // Charts
                obj["dailyTrend"] = DtToRows(bl.GetDailyTrend(instId, sessId, streamId, courseId,
                                            sectionId, subjectId, dateFrom, dateTo));
                obj["weeklySummary"] = DtToRows(bl.GetWeeklySummary(instId, sessId,
                                            streamId, courseId, dateFrom, dateTo));
                obj["monthlySummary"] = DtToRows(bl.GetMonthlySummary(instId, sessId,
                                            streamId, courseId));
                obj["streamWise"] = DtToRows(bl.GetStreamWiseAttendance(instId, sessId,
                                            dateFrom, dateTo));
                obj["courseWise"] = DtToRows(bl.GetCourseWiseAttendance(instId, sessId,
                                            streamId, dateFrom, dateTo));
                obj["subjectWise"] = DtToRows(bl.GetSubjectWiseAttendance(instId, sessId,
                                            streamId, courseId, dateFrom, dateTo));
                obj["sectionWise"] = DtToRows(bl.GetSectionWiseAttendance(instId, sessId,
                                            streamId, dateFrom, dateTo));
                obj["dayOfWeek"] = DtToRows(bl.GetDayOfWeekPattern(instId, sessId,
                                            streamId, dateFrom, dateTo));
                obj["buckets"] = DtToRows(bl.GetAttendanceBuckets(instId, sessId,
                                            streamId, courseId, dateFrom, dateTo));
                obj["heatmap"] = DtToRows(bl.GetHeatmapData(instId, sessId,
                                            streamId, dateFrom, dateTo));
                obj["defaulters"] = DtToRows(bl.GetDefaulters(instId, sessId,
                                            streamId, courseId, threshold, dateFrom, dateTo));

                // Student list
                int total = bl.GetStudentAttCount(instId, sessId, streamId, courseId,
                                  sectionId, gender, search);
                DataTable dtS = bl.GetStudentWiseAttendance(instId, sessId, streamId, courseId,
                                    sectionId, subjectId, dateFrom, dateTo, gender,
                                    search, pageIdx, PAGE_SIZE);
                obj["students"] = DtToRows(dtS);
                obj["totalCount"] = total;
                obj["pageSize"] = PAGE_SIZE;
                obj["pageIndex"] = pageIdx;
                obj["pageCount"] = (int)Math.Ceiling((double)total / PAGE_SIZE);

                // Cascade courses
                obj["courses"] = DtToList(bl.GetCourses(instId, sessId, streamId),
                                     "CourseId", "CourseDisplay");

                Response.Write(new JavaScriptSerializer().Serialize(obj));
            }
            catch (Exception ex)
            {
                Response.StatusCode = 500;
                Response.Write("{\"error\":\"" + ex.Message.Replace("\"", "'") + "\"}");
            }
        }

        // ══════════════════════════════════════════════════════
        // DROPDOWN INIT
        // ══════════════════════════════════════════════════════
        private void InitDropdowns()
        {
            Populate(ddlStream, bl.GetStreams(InstituteId, SessionId), "StreamId", "StreamName", "All Streams", "0");
            Populate(ddlCourse, bl.GetCourses(InstituteId, SessionId, 0), "CourseId", "CourseDisplay", "All Courses", "0");
            Populate(ddlSection, bl.GetSections(InstituteId, SessionId), "SectionId", "SectionName", "All Sections", "0");
            Populate(ddlSubject, bl.GetSubjects(InstituteId, SessionId, 0, 0), "SubjectId", "SubjectName", "All Subjects", "0");
            Populate(ddlSemester, bl.GetSemesters(InstituteId, SessionId), "SemesterId", "SemesterName", "All Semesters", "0");

            ddlGender.Items.Clear();
            ddlGender.Items.Add(new ListItem("All Genders", ""));
            ddlGender.Items.Add(new ListItem("Male", "Male"));
            ddlGender.Items.Add(new ListItem("Female", "Female"));
            ddlGender.Items.Add(new ListItem("Other", "Other"));
        }

        private void Populate(DropDownList ddl, DataTable dt,
            string valCol, string txtCol, string allText, string allVal)
        {
            ddl.Items.Clear();
            ddl.Items.Add(new ListItem(allText, allVal));
            if (dt == null) return;
            foreach (DataRow r in dt.Rows)
                ddl.Items.Add(new ListItem(r[txtCol].ToString(), r[valCol].ToString()));
        }

        // ══════════════════════════════════════════════════════
        // HELPERS
        // ══════════════════════════════════════════════════════
        private int SI(string k) { int v; int.TryParse(QS(k), out v); return v; }
        private string QS(string k) => Request.QueryString[k] ?? "";
        private decimal SD(string k, decimal def)
        { decimal v; return decimal.TryParse(QS(k), out v) ? v : def; }

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

        private List<Dictionary<string, object>> DtToList(DataTable dt, params string[] cols)
        {
            var list = new List<Dictionary<string, object>>();
            if (dt == null) return list;
            foreach (DataRow row in dt.Rows)
            {
                var d = new Dictionary<string, object>();
                foreach (var c in cols)
                    d[c] = dt.Columns.Contains(c) && row[c] != DBNull.Value ? row[c] : null;
                list.Add(d);
            }
            return list;
        }
    }
}