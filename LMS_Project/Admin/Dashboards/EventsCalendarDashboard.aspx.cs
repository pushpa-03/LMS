using System;
using System.Collections.Generic;
using System.Data;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;


namespace LearningManagementSystem.Admin.Dashboards
{
    public partial class EventsCalendarDashboard : BasePage
    {
        private EventsCalendarDashboardBL _bl;

        // ── KEY FIX: intercept AJAX BEFORE BasePage.OnLoad redirects ──
        protected override void OnLoad(EventArgs e)
        {
            if (Request.QueryString["ajax"] == "1")
            {
                _bl = new EventsCalendarDashboardBL();
                HandleAjax();
                Response.End();
                return;
            }
            base.OnLoad(e);
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            _bl = new EventsCalendarDashboardBL();
            if (!IsPostBack)
            {
                hdnInst.Value = InstituteId.ToString();
                hdnSess.Value = SessionId.ToString();
                lblSess.Text = (Session["SessionName"] ?? "").ToString();
                hdnDfr.Value = new DateTime(DateTime.Today.Year, 1, 1).ToString("yyyy-MM-dd");
                hdnDto.Value = new DateTime(DateTime.Today.Year, 12, 31).ToString("yyyy-MM-dd");
                hdnCurYear.Value = DateTime.Today.Year.ToString();
                hdnCurMonth.Value = DateTime.Today.Month.ToString();
                InitDropdowns();
            }
        }

        // ════════════════════════════════════════════════════════
        // AJAX HANDLER
        // ════════════════════════════════════════════════════════
        private void HandleAjax()
        {
            Response.Clear();
            Response.ContentType = "application/json";
            Response.Cache.SetCacheability(HttpCacheability.NoCache);
            Response.AddHeader("Cache-Control", "no-cache, no-store, must-revalidate");

            int inst = SI("inst");
            int sess = SI("sess");
            string eventType = QS("evtype");
            string dateFrom = QS("datefrom");
            string dateTo = QS("dateto");
            int calYear = SI("calyear");
            int calMonth = SI("calmonth");

            // Fallback to Session
            if (inst == 0 && Session["InstituteId"] != null)
                inst = Convert.ToInt32(Session["InstituteId"]);
            if (sess == 0 && Session["CurrentSessionId"] != null)
                sess = Convert.ToInt32(Session["CurrentSessionId"]);
            if (calYear == 0) calYear = DateTime.Today.Year;
            if (calMonth == 0) calMonth = DateTime.Today.Month;

            if (inst == 0 || sess == 0)
            {
                Response.StatusCode = 200;
                Response.Write("{\"error\":\"Session missing. inst=" + inst + " sess=" + sess + "\"}");
                return;
            }

            try
            {
                var obj = new Dictionary<string, object>();

                // ── KPIs ──────────────────────────────────────────────
                DataTable dtK = _bl.GetKPISummary(inst, sess, eventType, dateFrom, dateTo);
                if (dtK?.Rows.Count > 0)
                {
                    var r = dtK.Rows[0];
                    obj["kpi"] = new
                    {
                        totalEvents = ToI(r["TotalEvents"]),
                        upcomingNext30 = ToI(r["UpcomingNext30"]),
                        pastEvents = ToI(r["PastEvents"]),
                        todayEvents = ToI(r["TodayEvents"]),
                        eventCategories = ToI(r["EventCategories"]),
                        notificationsSent = ToI(r["NotificationsSent"]),
                        thisMonthEvents = ToI(r["ThisMonthEvents"]),
                        next7Days = ToI(r["Next7Days"])
                    };
                }
                else
                {
                    obj["kpi"] = new
                    {
                        totalEvents = 0,
                        upcomingNext30 = 0,
                        pastEvents = 0,
                        todayEvents = 0,
                        eventCategories = 0,
                        notificationsSent = 0,
                        thisMonthEvents = 0,
                        next7Days = 0
                    };
                }

                // ── Data ──────────────────────────────────────────────
                obj["upcoming"] = Rows(_bl.GetUpcomingEvents(inst, sess, eventType, dateFrom, dateTo));
                obj["allEvents"] = Rows(_bl.GetAllEvents(inst, sess, eventType, dateFrom, dateTo));
                obj["pastEvents"] = Rows(_bl.GetPastEvents(inst, sess, eventType, dateFrom, dateTo));
                obj["typeBreak"] = Rows(_bl.GetEventTypeDistribution(inst, sess, dateFrom, dateTo));
                obj["monthly"] = Rows(_bl.GetMonthlyEventCount(inst, sess, eventType));
                obj["dayOfWeek"] = Rows(_bl.GetDayOfWeekPattern(inst, sess, dateFrom, dateTo));
                obj["notifTrend"] = Rows(_bl.GetNotificationTrend(inst, sess, dateFrom, dateTo));
                obj["heatmap"] = Rows(_bl.GetCalendarHeatmap(inst, sess, calYear, calMonth, eventType));
                obj["adminStats"] = Rows(_bl.GetAdminStats(inst, sess));
                obj["calYear"] = calYear;
                obj["calMonth"] = calMonth;

                Response.Write(new JavaScriptSerializer { MaxJsonLength = int.MaxValue }.Serialize(obj));
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("[EventsCal.AJAX] " + ex.ToString());
                // Return 200 so JS can read the error body
                Response.StatusCode = 200;
                string msg = ex.Message
                    .Replace("\"", "'").Replace("\r", " ").Replace("\n", " ");
                Response.Write("{\"error\":\"" + msg + "\"}");
            }
        }

        // ════════════════════════════════════════════════════════
        // DROPDOWNS
        // ════════════════════════════════════════════════════════
        private void InitDropdowns()
        {
            Fill(aspEventType, _bl.GetEventTypes(InstituteId, SessionId),
                 "EventType", "EventType", "All Types", "");
            Fill(aspStream, _bl.GetStreams(InstituteId, SessionId),
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

        // ════════════════════════════════════════════════════════
        // HELPERS
        // ════════════════════════════════════════════════════════
        private int SI(string k) { int v; int.TryParse(QS(k), out v); return v; }
        private string QS(string k) => Request.QueryString[k] ?? "";
        private int ToI(object v) => (v == null || v == DBNull.Value) ? 0 : Convert.ToInt32(v);

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