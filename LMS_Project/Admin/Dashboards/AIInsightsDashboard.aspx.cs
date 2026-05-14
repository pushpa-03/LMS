using System;
using System.Collections.Generic;
using System.Data;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace LearningManagementSystem.Admin
{
    public partial class AIInsightsDashboard : BasePage
    {
        private readonly AIInsightsDashboardBL bl = new AIInsightsDashboardBL();

        protected void Page_Load(object sender, EventArgs e)
        {
            // Pure AJAX — return JSON and exit, no page render
            if (Request.QueryString["ajax"] == "1")
            {
                HandleAjax();
                Response.End();
                return;
            }

            if (!IsPostBack)
            {
                hdnInst.Value = InstituteId.ToString();
                hdnSess.Value = SessionId.ToString();
                lblSess.Text = (Session["SessionName"] ?? "").ToString();

                // Default: first day of current month → today
                hdnDfr.Value = new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1).ToString("yyyy-MM-dd");
                hdnDto.Value = DateTime.Today.ToString("yyyy-MM-dd");

                InitDropdowns();
            }
        }

        // ── AJAX handler ────────────────────────────────────
        private void HandleAjax()
        {
            Response.ContentType = "application/json";
            Response.Cache.SetCacheability(HttpCacheability.NoCache);
            Response.AddHeader("Cache-Control", "no-cache, no-store");

            int inst = SI("inst");
            int sess = SI("sess");
            int streamId = SI("stream");
            int courseId = SI("course");
            int sectionId = SI("section");
            int subjectId = SI("subject");
            string aiType = QS("aitype");   // Summary|Notes|Quiz|Doubt|""
            string dateFrom = QS("datefrom");
            string dateTo = QS("dateto");
            string action = QS("action");

            // Fallback to session values if client sends 0
            if (inst == 0) inst = InstituteId;
            if (sess == 0) sess = SessionId;

            try
            {
                var obj = new Dictionary<string, object>();

                // Cascade courses only
                if (action == "courses")
                {
                    obj["courses"] = ToList(bl.GetCourses(inst, sess, streamId),
                                        "CourseId", "CourseDisplay");
                    Write(obj); return;
                }

                // KPIs
                DataTable dtK = bl.GetKPISummary(inst, sess,
                    streamId, courseId, sectionId, aiType, dateFrom, dateTo);
                if (dtK != null && dtK.Rows.Count > 0)
                {
                    var r = dtK.Rows[0];
                    int total = ToI(r["TotalInteractions"]);
                    int enrolled = ToI(r["TotalEnrolled"]);
                    int users = ToI(r["UniqueUsers"]);
                    obj["kpi"] = new
                    {
                        totalInteractions = total,
                        uniqueUsers = users,
                        totalEnrolled = enrolled,
                        adoptionRate = enrolled > 0
                            ? Math.Round(100.0 * users / enrolled, 1) : 0,
                        videoSummary = ToI(r["VideoSummary"]),
                        videoNotes = ToI(r["VideoNotes"]),
                        videoQuiz = ToI(r["VideoQuiz"]),
                        videoDoubt = ToI(r["VideoDoubt"]),
                        materialQuiz = ToI(r["MaterialQuiz"]),
                        materialDoubt = ToI(r["MaterialDoubt"]),
                        materialNotes = ToI(r["MaterialNotes"]),
                        todayInteractions = ToI(r["TodayInteractions"])
                    };
                }
                else
                {
                    obj["kpi"] = new
                    {
                        totalInteractions = 0,
                        uniqueUsers = 0,
                        totalEnrolled = 0,
                        adoptionRate = 0,
                        videoSummary = 0,
                        videoNotes = 0,
                        videoQuiz = 0,
                        videoDoubt = 0,
                        materialQuiz = 0,
                        materialDoubt = 0,
                        materialNotes = 0,
                        todayInteractions = 0
                    };
                }

                // Charts
                obj["dailyTrend"] = ToRows(bl.GetDailyTrend(inst, sess, streamId, courseId, aiType, dateFrom, dateTo));
                obj["weeklyTrend"] = ToRows(bl.GetWeeklyTrend(inst, sess, streamId, dateFrom, dateTo));
                obj["typeBreak"] = ToRows(bl.GetTypeBreakdown(inst, sess, streamId, courseId, dateFrom, dateTo));
                obj["streamUsage"] = ToRows(bl.GetStreamWiseUsage(inst, sess, aiType, dateFrom, dateTo));
                obj["courseUsage"] = ToRows(bl.GetCourseWiseUsage(inst, sess, streamId, aiType, dateFrom, dateTo));
                obj["sectionUsage"] = ToRows(bl.GetSectionWiseUsage(inst, sess, streamId, aiType, dateFrom, dateTo));
                obj["subjectUsage"] = ToRows(bl.GetSubjectWiseUsage(inst, sess, streamId, courseId, aiType, dateFrom, dateTo));
                obj["hourly"] = ToRows(bl.GetHourlyPattern(inst, sess, streamId, dateFrom, dateTo));
                obj["topUsers"] = ToRows(bl.GetTopAIUsers(inst, sess, streamId, courseId, aiType, dateFrom, dateTo));
                obj["nonUsers"] = ToRows(bl.GetNonAIUsers(inst, sess, streamId, courseId, dateFrom, dateTo));
                obj["activity"] = ToRows(bl.GetRecentActivity(inst, sess, streamId, aiType, dateFrom, dateTo));

                // Cascade
                obj["courses"] = ToList(bl.GetCourses(inst, sess, streamId), "CourseId", "CourseDisplay");

                Write(obj);
            }
            catch (Exception ex)
            {
                Response.StatusCode = 500;
                Response.Write("{\"error\":\"" + ex.Message.Replace("\"", "'").Replace("\r", "").Replace("\n", " ") + "\"}");
            }
        }

        // ── Dropdown init ────────────────────────────────────
        private void InitDropdowns()
        {
            Fill(aspStream, bl.GetStreams(InstituteId, SessionId), "StreamId", "StreamName", "All Streams", "0");
            Fill(aspCourse, bl.GetCourses(InstituteId, SessionId, 0), "CourseId", "CourseDisplay", "All Courses", "0");
            Fill(aspSection, bl.GetSections(InstituteId, SessionId), "SectionId", "SectionName", "All Sections", "0");
            Fill(aspSubject, bl.GetSubjects(InstituteId, SessionId, 0, 0), "SubjectId", "SubjectName", "All Subjects", "0");
        }

        private void Fill(DropDownList ddl, DataTable dt,
            string valC, string txtC, string allTxt, string allVal)
        {
            ddl.Items.Clear();
            ddl.Items.Add(new ListItem(allTxt, allVal));
            if (dt == null) return;
            foreach (DataRow r in dt.Rows)
                ddl.Items.Add(new ListItem(r[txtC].ToString(), r[valC].ToString()));
        }

        // ── Helpers ──────────────────────────────────────────
        private int SI(string k) { int v; int.TryParse(QS(k), out v); return v; }
        private string QS(string k) => Request.QueryString[k] ?? "";
        private int ToI(object v) => (v == null || v == DBNull.Value) ? 0 : Convert.ToInt32(v);

        private void Write(object obj)
        {
            Response.Write(new JavaScriptSerializer { MaxJsonLength = int.MaxValue }.Serialize(obj));
        }

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