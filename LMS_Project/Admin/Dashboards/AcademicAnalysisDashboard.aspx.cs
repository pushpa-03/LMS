using System;
using System.Collections.Generic;
using System.Data;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace LearningManagementSystem.Admin
{
    // ══════════════════════════════════════════════════════════════
    //  IMPORTANT: This page NEVER posts back after initial load.
    //  All data is loaded via AJAX (fetch) from the JS layer.
    //  BasePage supplies: InstituteId, SessionId, SocietyId, UserId
    // ══════════════════════════════════════════════════════════════
    public partial class AcademicAnalysisDashboard : BasePage
    {
        private readonly AcademicAnalysisDashboardBL bl = new AcademicAnalysisDashboardBL();

        protected void Page_Load(object sender, EventArgs e)
        {
            // ── AJAX route: return JSON and exit immediately ──────
            if (Request.QueryString["ajax"] == "1")
            {
                HandleAjax();
                Response.End();
                return;
            }

            // ── First page load: populate hidden fields & dropdowns ─
            if (!IsPostBack)
            {
                // Pass server values to client via hidden fields
                hdnInst.Value = InstituteId.ToString();
                hdnSess.Value = SessionId.ToString();
                lblSessName.Text = (Session["SessionName"] ?? "").ToString();

                // Default date range — first day of this year → today
                hdnDfr.Value = new DateTime(DateTime.Today.Year, 1, 1).ToString("yyyy-MM-dd");
                hdnDto.Value = DateTime.Today.ToString("yyyy-MM-dd");

                // Populate hidden ASP dropdowns so JS can clone their options
                InitDropdowns();
            }
        }

        // ════════════════════════════════════════════════════════
        // AJAX HANDLER — pure JSON, zero page render
        // ════════════════════════════════════════════════════════
        private void HandleAjax()
        {
            Response.ContentType = "application/json";
            Response.Cache.SetCacheability(HttpCacheability.NoCache);
            Response.AddHeader("Cache-Control", "no-cache, no-store, must-revalidate");

            // Read all filter params from query string
            int inst = SafeInt("inst");
            int sess = SafeInt("sess");
            int streamId = SafeInt("stream");
            int courseId = SafeInt("course");
            int semId = SafeInt("semester");
            int sectionId = SafeInt("section");
            int subjectId = SafeInt("subject");
            string gender = QS("gender");
            string dateFrom = QS("datefrom");
            string dateTo = QS("dateto");
            string action = QS("action");

            // Guard: fallback to session values if client sends 0
            if (inst == 0) inst = InstituteId;
            if (sess == 0) sess = SessionId;

            try
            {
                var obj = new Dictionary<string, object>();

                // ── Cascade: just return courses for a stream ────────
                if (action == "courses")
                {
                    obj["courses"] = ToList(bl.GetCourses(inst, sess, streamId),
                                        "CourseId", "CourseDisplay");
                    Response.Write(new JavaScriptSerializer().Serialize(obj));
                    return;
                }

                // ── KPIs ─────────────────────────────────────────────
                DataTable dtK = bl.GetKPISummary(inst, sess, streamId, courseId,
                                    semId, sectionId, subjectId, gender, dateFrom, dateTo);
                if (dtK != null && dtK.Rows.Count > 0)
                {
                    var r = dtK.Rows[0];
                    obj["kpi"] = new
                    {
                        totalStudents = SafeVal(r["TotalStudents"]),
                        totalAttempts = SafeVal(r["TotalQuizAttempts"]),
                        avgScore = SafeVal(r["AvgScore"]),
                        maxScore = SafeVal(r["MaxScore"]),
                        minScore = SafeVal(r["MinScore"]),
                        passRate = SafeVal(r["PassRate"]),
                        failRate = SafeVal(r["FailRate"]),
                        totalAssign = SafeVal(r["TotalAssignments"]),
                        totalSub = SafeVal(r["TotalSubmissions"]),
                        subRate = SafeVal(r["SubmissionRate"]),
                        avgAssignMarks = SafeVal(r["AvgAssignMarks"]),
                        totalVideos = SafeVal(r["TotalVideos"]),
                        totalViews = SafeVal(r["TotalVideoViews"]),
                        totalSubjects = SafeVal(r["TotalSubjects"])
                    };
                }
                else
                {
                    // Return zeroed KPIs so UI still renders
                    obj["kpi"] = new
                    {
                        totalStudents = 0,
                        totalAttempts = 0,
                        avgScore = 0,
                        maxScore = 0,
                        minScore = 0,
                        passRate = 0,
                        failRate = 0,
                        totalAssign = 0,
                        totalSub = 0,
                        subRate = 0,
                        avgAssignMarks = 0,
                        totalVideos = 0,
                        totalViews = 0,
                        totalSubjects = 0
                    };
                }

                // ── All chart & list data ────────────────────────────
                obj["grades"] = ToRows(bl.GetGradeDistribution(inst, sess, streamId, courseId, dateFrom, dateTo));
                obj["subjPerf"] = ToRows(bl.GetSubjectWisePerformance(inst, sess, streamId, courseId, dateFrom, dateTo));
                obj["quizTrend"] = ToRows(bl.GetQuizTrend(inst, sess, streamId, courseId, dateFrom, dateTo));
                obj["assignTrend"] = ToRows(bl.GetAssignmentTrend(inst, sess, streamId, courseId, dateFrom, dateTo));
                obj["topStudents"] = ToRows(bl.GetTopStudents(inst, sess, streamId, courseId, dateFrom, dateTo));
                obj["struggling"] = ToRows(bl.GetStrugglingStudents(inst, sess, streamId, courseId, dateFrom, dateTo));
                obj["streamPerf"] = ToRows(bl.GetStreamWisePerformance(inst, sess, dateFrom, dateTo));
                obj["videoEngage"] = ToRows(bl.GetVideoEngagement(inst, sess, streamId, dateFrom, dateTo));
                obj["quizList"] = ToRows(bl.GetQuizList(inst, sess, streamId, courseId, subjectId, dateFrom, dateTo));
                obj["genderPerf"] = ToRows(bl.GetGenderWisePerformance(inst, sess, streamId, dateFrom, dateTo));
                obj["suggestions"] = ToRows(bl.GetAdminSuggestions(inst, sess));

                // ── Cascade courses ──────────────────────────────────
                obj["courses"] = ToList(bl.GetCourses(inst, sess, streamId), "CourseId", "CourseDisplay");

                Response.Write(new JavaScriptSerializer { MaxJsonLength = int.MaxValue }
                    .Serialize(obj));
            }
            catch (Exception ex)
            {
                Response.StatusCode = 500;
                Response.Write("{\"error\":\"" +
                    ex.Message.Replace("\\", "\\\\").Replace("\"", "'") + "\"}");
            }
        }

        // ════════════════════════════════════════════════════════
        // DROPDOWN INIT — only on first page load
        // ════════════════════════════════════════════════════════
        private void InitDropdowns()
        {
            FillDDL(aspStream, bl.GetStreams(InstituteId, SessionId),
                    "StreamId", "StreamName", "All Streams", "0");
            FillDDL(aspCourse, bl.GetCourses(InstituteId, SessionId, 0),
                    "CourseId", "CourseDisplay", "All Courses", "0");
            FillDDL(aspSemester, bl.GetSemesters(InstituteId, SessionId),
                    "SemesterId", "SemesterName", "All Semesters", "0");
            FillDDL(aspSection, bl.GetSections(InstituteId, SessionId),
                    "SectionId", "SectionName", "All Sections", "0");
            FillDDL(aspSubject, bl.GetSubjects(InstituteId, SessionId, 0, 0),
                    "SubjectId", "SubjectName", "All Subjects", "0");

            aspGender.Items.Clear();
            aspGender.Items.Add(new ListItem("All Genders", ""));
            aspGender.Items.Add(new ListItem("Male", "Male"));
            aspGender.Items.Add(new ListItem("Female", "Female"));
            aspGender.Items.Add(new ListItem("Other", "Other"));
        }

        private void FillDDL(DropDownList ddl, DataTable dt,
            string valCol, string txtCol, string allText, string allVal)
        {
            ddl.Items.Clear();
            ddl.Items.Add(new ListItem(allText, allVal));
            if (dt == null) return;
            foreach (DataRow r in dt.Rows)
                ddl.Items.Add(new ListItem(
                    r[txtCol].ToString(),
                    r[valCol].ToString()));
        }

        // ════════════════════════════════════════════════════════
        // HELPERS
        // ════════════════════════════════════════════════════════
        private int SafeInt(string k) { int v; int.TryParse(QS(k), out v); return v; }
        private string QS(string k) => Request.QueryString[k] ?? "";
        private object SafeVal(object v) => (v == null || v == DBNull.Value) ? (object)0 : v;

        private List<Dictionary<string, object>> ToRows(DataTable dt)
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

        private List<Dictionary<string, object>> ToList(DataTable dt, params string[] cols)
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