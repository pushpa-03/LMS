using System;
using System.Collections.Generic;
using System.Data;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace LearningManagementSystem.Admin
{
    public partial class TeacherManagementDashboard : BasePage
    {
        private TeacherManagementDashboardBL _bl;
        private const int PAGE_SIZE = 12;

        // ══════════════════════════════════════════════════════════
        // CRITICAL: Override OnLoad to catch AJAX BEFORE BasePage
        // runs its redirect logic. Without this, BasePage.OnLoad()
        // calls Response.Redirect → kills JSON response → 500/empty.
        // ══════════════════════════════════════════════════════════
        protected override void OnLoad(EventArgs e)
        {
            if (Request.QueryString["ajax"] == "1")
            {
                _bl = new TeacherManagementDashboardBL();
                HandleAjax();
                Response.End();
                return;
            }
            base.OnLoad(e); // only for normal page loads
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            _bl = new TeacherManagementDashboardBL();
            if (!IsPostBack)
            {
                hdnInstId.Value = InstituteId.ToString();
                hdnSessId.Value = SessionId.ToString();
                lblSession.Text = (Session["SessionName"] ?? "").ToString();
                InitDropdowns();
            }
        }

        // ══════════════════════════════════════════════════════════
        // AJAX HANDLER — pure JSON, no HTML
        // ══════════════════════════════════════════════════════════
        private void HandleAjax()
        {
            Response.Clear();
            Response.ContentType = "application/json";
            Response.Cache.SetCacheability(HttpCacheability.NoCache);
            Response.AddHeader("Cache-Control", "no-cache, no-store, must-revalidate");

            int inst = ToInt(Request.QueryString["inst"]);
            int sess = ToInt(Request.QueryString["sess"]);
            int stream = ToInt(Request.QueryString["stream"]);
            int sec = ToInt(Request.QueryString["section"]);
            string desig = (Request.QueryString["desig"] ?? "").Trim();
            string month = (Request.QueryString["month"] ?? "").Trim();
            string year = (Request.QueryString["year"] ?? "").Trim();
            string search = (Request.QueryString["search"] ?? "").Trim();
            int page = ToInt(Request.QueryString["page"]);

            // Fallback to session values
            if (inst == 0 && Session["InstituteId"] != null) inst = Convert.ToInt32(Session["InstituteId"]);
            if (sess == 0 && Session["CurrentSessionId"] != null) sess = Convert.ToInt32(Session["CurrentSessionId"]);

            if (inst == 0 || sess == 0)
            {
                Response.Write("{\"error\":\"Session missing\",\"kpi\":{\"total\":0,\"active\":0,\"inactive\":0,\"newJoined\":0,\"videos\":0,\"assignments\":0,\"quizzes\":0,\"avgExp\":0,\"subjects\":0,\"students\":0,\"males\":0,\"females\":0},\"teachers\":[],\"totalCount\":0,\"pageSize\":12,\"pageIndex\":0,\"pageCount\":0}");
                return;
            }

            try
            {
                var obj = new Dictionary<string, object>();

                // KPIs
                DataTable dtK = _bl.GetKPISummary(inst, sess, stream, sec, desig, month, year);
                if (dtK != null && dtK.Rows.Count > 0)
                {
                    var r = dtK.Rows[0];
                    obj["kpi"] = new
                    {
                        total = ToI(r["TotalTeachers"]),
                        active = ToI(r["ActiveTeachers"]),
                        inactive = ToI(r["InactiveTeachers"]),
                        newJoined = ToI(r["NewJoined"]),
                        videos = ToI(r["TotalVideos"]),
                        assignments = ToI(r["TotalAssignments"]),
                        quizzes = ToI(r["TotalQuizzes"]),
                        avgExp = ToD(r["AvgExperience"]),
                        subjects = ToI(r["SubjectsTaught"]),
                        students = ToI(r["TotalStudents"]),
                        males = ToI(r["Males"]),
                        females = ToI(r["Females"])
                    };
                }
                else
                {
                    obj["kpi"] = new { total = 0, active = 0, inactive = 0, newJoined = 0, videos = 0, assignments = 0, quizzes = 0, avgExp = 0.0, subjects = 0, students = 0, males = 0, females = 0 };
                }

                // Charts
                obj["joiningTrend"] = Rows(_bl.GetMonthlyJoiningTrend(inst, sess));
                obj["streamWise"] = Rows(_bl.GetStreamWiseTeachers(inst, sess));
                obj["designation"] = Rows(_bl.GetDesignationWiseCount(inst, sess));
                obj["experience"] = Rows(_bl.GetExperienceDistribution(inst, sess));
                obj["gender"] = Rows(_bl.GetGenderDistribution(inst, sess, stream));
                obj["contentTrend"] = Rows(_bl.GetContentOutputTrend(inst, sess, stream));
                obj["subjectWise"] = Rows(_bl.GetSubjectWiseTeachers(inst, sess, stream));
                obj["qualification"] = Rows(_bl.GetQualificationDistribution(inst, sess));
                obj["recentActivity"] = Rows(_bl.GetRecentActivity(inst, sess, stream));
                obj["topTeachers"] = Rows(_bl.GetTopTeachersByContent(inst, sess, stream));
                obj["courses"] = Rows(_bl.GetCoursesByStream(inst, sess, stream));

                // Perf metrics
                DataTable dtM = _bl.GetTeacherPerformanceMetrics(inst, sess, stream);
                if (dtM != null && dtM.Rows.Count > 0)
                {
                    var r = dtM.Rows[0];
                    obj["perfMetrics"] = new
                    {
                        avgVideos = ToD(r["AvgVideos"]),
                        avgAssignments = ToD(r["AvgAssignments"]),
                        avgQuizzes = ToD(r["AvgQuizzes"]),
                        avgStudents = ToD(r["AvgStudents"]),
                        avgVideoViews = ToD(r["AvgVideoViews"]),
                        avgScore = ToD(r["AvgStudentScore"])
                    };
                }
                else { obj["perfMetrics"] = new { avgVideos = 0.0, avgAssignments = 0.0, avgQuizzes = 0.0, avgStudents = 0.0, avgVideoViews = 0.0, avgScore = 0.0 }; }

                // Teacher list
                int total = _bl.GetTeacherCount(inst, sess, stream, sec, desig, month, year, search);
                obj["teachers"] = Rows(_bl.GetTeacherList(inst, sess, stream, sec, desig, month, year, search, page, PAGE_SIZE));
                obj["totalCount"] = total;
                obj["pageSize"] = PAGE_SIZE;
                obj["pageIndex"] = page;
                obj["pageCount"] = (int)Math.Ceiling((double)Math.Max(total, 1) / PAGE_SIZE);

                Response.Write(new JavaScriptSerializer { MaxJsonLength = int.MaxValue }.Serialize(obj));
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("[TMD] " + ex.ToString());
                string msg = ex.Message.Replace("\"", "'").Replace("\r", " ").Replace("\n", " ");
                Response.Write("{\"error\":\"" + msg + "\"}");
            }
        }

        private void InitDropdowns()
        {
            BindDdl(ddlStream, _bl.GetStreams(InstituteId, SessionId), "StreamId", "StreamName", "All Streams", "0");
            BindDdl(ddlSection, _bl.GetSections(InstituteId, SessionId), "SectionId", "SectionName", "All Sections", "0");
            BindDdl(ddlDesignation, _bl.GetDesignations(InstituteId, SessionId), "Designation", "Designation", "All Designations", "");
            ddlYear.Items.Clear();
            ddlYear.Items.Add(new ListItem("All Years", ""));
            int cur = DateTime.Now.Year;
            for (int y = cur; y >= cur - 5; y--)
                ddlYear.Items.Add(new ListItem(y.ToString(), y.ToString()));
        }

        private void BindDdl(DropDownList d, DataTable dt, string vc, string tc, string ft, string fv)
        {
            d.Items.Clear(); d.Items.Add(new ListItem(ft, fv));
            if (dt == null) return;
            foreach (DataRow r in dt.Rows) d.Items.Add(new ListItem(r[tc].ToString(), r[vc].ToString()));
        }

        private int ToInt(string v) { int r; return int.TryParse(v, out r) ? r : 0; }
        private int ToI(object v) => v == null || v == DBNull.Value ? 0 : Convert.ToInt32(v);
        private double ToD(object v) => v == null || v == DBNull.Value ? 0.0 : Convert.ToDouble(v);

        private List<Dictionary<string, object>> Rows(DataTable dt)
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