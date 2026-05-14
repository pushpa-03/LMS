using System;
using System.Collections.Generic;
using System.Data;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace LearningManagementSystem.Admin
{
    public partial class SystemUsageDashboard : BasePage
    {
        private readonly SystemUsageDashboardBL bl = new SystemUsageDashboardBL();

        // ── KEY FIX #1: Override OnLoad to bypass BasePage redirect logic for AJAX calls ──
        // BasePage.OnLoad() calls Response.Redirect() which kills AJAX responses.
        // When request is AJAX (?ajax=1), we skip the base page lifecycle entirely.
        protected override void OnLoad(EventArgs e)
        {
            if (Request.QueryString["ajax"] == "1")
            {
                // Skip BasePage.OnLoad — handle AJAX immediately and end
                HandleAjax();
                Response.End();
                return;
            }
            // Normal page load — let BasePage run its session/login checks
            base.OnLoad(e);
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            // AJAX is already handled in OnLoad above, so this only runs for normal loads
            if (!IsPostBack)
            {
                hdnInst.Value = InstituteId.ToString();
                hdnSess.Value = SessionId.ToString();
                lblSess.Text = (Session["SessionName"] ?? "").ToString();

                // Default: last 30 days
                hdnDfr.Value = DateTime.Today.AddDays(-29).ToString("yyyy-MM-dd");
                hdnDto.Value = DateTime.Today.ToString("yyyy-MM-dd");

                InitDropdowns();
            }
        }

        private void HandleAjax()
        {
            Response.ContentType = "application/json";
            Response.Cache.SetCacheability(HttpCacheability.NoCache);
            Response.AddHeader("Cache-Control", "no-cache, no-store");

            // ── KEY FIX #2: Read inst/sess from QueryString directly ──
            // We can't use InstituteId/SessionId properties here because
            // they depend on Session which requires BasePage.OnLoad to have run.
            int inst = SI("inst");
            int sess = SI("sess");
            string role = QS("role");
            string dateFrom = QS("datefrom");
            string dateTo = QS("dateto");

            // Fallback to Session values if QS params are missing
            if (inst == 0 && Session["InstituteId"] != null)
                inst = Convert.ToInt32(Session["InstituteId"]);
            if (sess == 0 && Session["CurrentSessionId"] != null)
                sess = Convert.ToInt32(Session["CurrentSessionId"]);

            if (inst == 0 || sess == 0)
            {
                Response.StatusCode = 400;
                Response.Write("{\"error\":\"Missing institute or session context.\"}");
                return;
            }

            try
            {
                var obj = new Dictionary<string, object>();

                // KPIs
                DataTable dtK = bl.GetKPISummary(inst, sess, role, dateFrom, dateTo);
                if (dtK != null && dtK.Rows.Count > 0)
                {
                    var r = dtK.Rows[0];
                    obj["kpi"] = new
                    {
                        totalLogins = ToI(r["TotalLogins"]),
                        activeUsers = ToI(r["ActiveUsers"]),
                        todayLogins = ToI(r["TodayLogins"]),
                        totalVideoViews = ToI(r["TotalVideoViews"]),
                        quizAttempts = ToI(r["QuizAttempts"]),
                        assignSubmissions = ToI(r["AssignSubmissions"]),
                        aiUses = ToI(r["AIUses"]),
                        helpRequests = ToI(r["HelpRequests"]),
                        totalStudents = ToI(r["TotalStudents"]),
                        totalTeachers = ToI(r["TotalTeachers"])
                    };
                }
                else
                {
                    obj["kpi"] = new
                    {
                        totalLogins = 0,
                        activeUsers = 0,
                        todayLogins = 0,
                        totalVideoViews = 0,
                        quizAttempts = 0,
                        assignSubmissions = 0,
                        aiUses = 0,
                        helpRequests = 0,
                        totalStudents = 0,
                        totalTeachers = 0
                    };
                }

                obj["dailyTrend"] = ToRows(bl.GetDailyLoginTrend(inst, sess, role, dateFrom, dateTo));
                obj["hourly"] = ToRows(bl.GetHourlyPattern(inst, sess, dateFrom, dateTo));
                obj["roleWise"] = ToRows(bl.GetRoleWiseActivity(inst, sess, dateFrom, dateTo));
                obj["featureUsage"] = ToRows(bl.GetFeatureUsage(inst, sess, dateFrom, dateTo));
                obj["topUsers"] = ToRows(bl.GetTopActiveUsers(inst, sess, role, dateFrom, dateTo));
                obj["inactiveUsers"] = ToRows(bl.GetInactiveUsers(inst, sess));
                obj["dayOfWeek"] = ToRows(bl.GetDayOfWeekPattern(inst, sess, dateFrom, dateTo));
                obj["streamWise"] = ToRows(bl.GetStreamWiseUsage(inst, sess, dateFrom, dateTo));
                obj["recentActivity"] = ToRows(bl.GetRecentActivity(inst, sess, role, dateFrom, dateTo));
                obj["weeklyTrend"] = ToRows(bl.GetWeeklyTrend(inst, sess, dateFrom, dateTo));
                obj["adminStats"] = ToRows(bl.GetAdminStats(inst, sess));

                Response.Write(new JavaScriptSerializer { MaxJsonLength = int.MaxValue }
                    .Serialize(obj));
            }
            catch (Exception ex)
            {
                Response.StatusCode = 500;
                Response.Write("{\"error\":\"" +
                    ex.Message.Replace("\"", "'").Replace("\r", "").Replace("\n", " ") + "\"}");
            }
        }

        private void InitDropdowns()
        {
            Fill(aspRole, bl.GetRoles(InstituteId),
                 "RoleName", "RoleName", "All Roles", "");
            Fill(aspStream, bl.GetStreams(InstituteId, SessionId),
                 "StreamId", "StreamName", "All Streams", "0");
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

        private int SI(string k) { int v; int.TryParse(QS(k), out v); return v; }
        private string QS(string k) => Request.QueryString[k] ?? "";
        private int ToI(object v) =>
            (v == null || v == DBNull.Value) ? 0 : Convert.ToInt32(v);

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
    }
}