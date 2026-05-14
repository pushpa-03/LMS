using System;
using System.Collections.Generic;
using System.Data;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace LearningManagementSystem.Admin
{
    public partial class CommunicationSupportDashboard : BasePage
    {
        private CommunicationSupportDashboardBL _bl;
        private const int PAGE_SIZE = 10;

        // ══════════════════════════════════════════════════════════
        // CRITICAL: intercept AJAX BEFORE BasePage.OnLoad redirects
        // ══════════════════════════════════════════════════════════
        protected override void OnLoad(EventArgs e)
        {
            if (Request.QueryString["ajax"] == "1")
            {
                _bl = new CommunicationSupportDashboardBL();
                HandleAjax();
                Response.End();
                return;
            }
            base.OnLoad(e);
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            _bl = new CommunicationSupportDashboardBL();
            if (!IsPostBack)
            {
                hdnInst.Value = InstituteId.ToString();
                hdnSess.Value = SessionId.ToString();
                lblSess.Text = Session["SessionName"]?.ToString() ?? "";
                hdnDfr.Value = DateTime.Today.AddDays(-29).ToString("yyyy-MM-dd");
                hdnDto.Value = DateTime.Today.ToString("yyyy-MM-dd");
                InitDropdowns();
            }
        }

        // ══════════════════════════════════════════════════════════
        // AJAX HANDLER
        // ══════════════════════════════════════════════════════════
        private void HandleAjax()
        {
            Response.Clear();
            Response.ContentType = "application/json";
            Response.Cache.SetCacheability(HttpCacheability.NoCache);
            Response.AddHeader("Cache-Control", "no-cache, no-store, must-revalidate");

            // Parse params
            int inst = ToInt(QS("inst"));
            int sess = ToInt(QS("sess"));
            int page = ToInt(QS("page"));
            string dateFrom = QS("datefrom");
            string dateTo = QS("dateto");

            // Fallback to session
            if (inst == 0 && Session["InstituteId"] != null) inst = Convert.ToInt32(Session["InstituteId"]);
            if (sess == 0 && Session["CurrentSessionId"] != null) sess = Convert.ToInt32(Session["CurrentSessionId"]);

            if (inst == 0 || sess == 0)
            {
                Response.Write("{\"error\":\"Session missing — refresh the page.\"}");
                return;
            }

            var obj = new Dictionary<string, object>();

            // ── KPIs ─────────────────────────────────────────────
            try
            {
                DataTable dtK = _bl.GetKPISummary(inst, sess, dateFrom, dateTo);
                if (dtK != null && dtK.Rows.Count > 0)
                {
                    var r = dtK.Rows[0];
                    obj["kpi"] = new
                    {
                        totalNotifications = ToI(r["TotalNotifications"]),
                        unreadNotifications = ToI(r["UnreadNotifications"]),
                        totalHelpRequests = ToI(r["TotalHelpRequests"]),
                        openHelpRequests = ToI(r["OpenHelpRequests"]),
                        totalAnnouncements = ToI(r["TotalAnnouncements"]),
                        totalMessages = ToI(r["TotalMessages"]),
                        activeThreads = ToI(r["ActiveThreads"]),
                        totalUsers = ToI(r["TotalUsers"]),
                        engagedUsers = ToI(r["EngagedUsers"]),
                        resolutionRate = ToD(r["ResolutionRate"])
                    };
                }
                else { obj["kpi"] = EmptyKpi(); }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("[CommDash.KPI] " + ex.Message);
                obj["kpi"] = EmptyKpi();
            }

            // ── Charts ────────────────────────────────────────────
            obj["notifTrend"] = TryRows(() => _bl.GetNotificationTrend(inst, sess, dateFrom, dateTo), "notifTrend");
            obj["notifTypes"] = TryRows(() => _bl.GetNotificationTypes(inst, sess, dateFrom, dateTo), "notifTypes");
            obj["helpTrend"] = TryRows(() => _bl.GetHelpRequestTrend(inst, sess, dateFrom, dateTo), "helpTrend");
            obj["msgTrend"] = TryRows(() => _bl.GetMessageTrend(inst, sess, dateFrom, dateTo), "msgTrend");
            obj["weeklyTrend"] = TryRows(() => _bl.GetWeeklyCombinedTrend(inst, sess), "weeklyTrend");
            obj["streamReach"] = TryRows(() => _bl.GetStreamWiseNotifications(inst, sess, dateFrom, dateTo), "streamReach");
            obj["roleComm"] = TryRows(() => _bl.GetRoleWiseCommunication(inst, sess, dateFrom, dateTo), "roleComm");
            obj["hourlyPattern"] = TryRows(() => _bl.GetHourlyPattern(inst, sess, dateFrom, dateTo), "hourlyPattern");
            obj["topComm"] = TryRows(() => _bl.GetTopCommunicators(inst, sess, dateFrom, dateTo), "topComm");
            obj["recentMessages"] = TryRows(() => _bl.GetRecentMessages(inst, sess, dateFrom, dateTo), "recentMessages");

            // ── Help Requests ─────────────────────────────────────
            try
            {
                int helpTotal = _bl.GetHelpRequestCount(inst, sess, dateFrom, dateTo);
                obj["helpRequests"] = TryRows(() => _bl.GetHelpRequests(inst, sess, dateFrom, dateTo, page, PAGE_SIZE), "helpRequests");
                obj["helpTotal"] = helpTotal;
                obj["helpPage"] = page;
                obj["helpPageSize"] = PAGE_SIZE;
                obj["helpPageCount"] = (int)Math.Ceiling((double)Math.Max(helpTotal, 1) / PAGE_SIZE);
            }
            catch
            {
                obj["helpRequests"] = new List<Dictionary<string, object>>();
                obj["helpTotal"] = 0;
                obj["helpPage"] = 0;
                obj["helpPageSize"] = PAGE_SIZE;
                obj["helpPageCount"] = 0;
            }

            // ── Announcements ─────────────────────────────────────
            try
            {
                int annTotal = _bl.GetAnnouncementCount(inst, sess, dateFrom, dateTo);
                obj["announcements"] = TryRows(() => _bl.GetAnnouncements(inst, sess, dateFrom, dateTo, 0, 8), "announcements");
                obj["annTotal"] = annTotal;
            }
            catch
            {
                obj["announcements"] = new List<Dictionary<string, object>>();
                obj["annTotal"] = 0;
            }

            // ── Admin Stats ───────────────────────────────────────
            try
            {
                DataTable dtS = _bl.GetAdminStats(inst, sess);
                if (dtS != null && dtS.Rows.Count > 0)
                {
                    var r = dtS.Rows[0];
                    obj["adminStats"] = new
                    {
                        avgResolutionHours = ToD(r["AvgResolutionHours"]),
                        notificationsToday = ToI(r["NotificationsToday"]),
                        helpRequestsToday = ToI(r["HelpRequestsToday"]),
                        messagesToday = ToI(r["MessagesToday"]),
                        unrespondedOver24h = ToI(r["UnrespondedOver24h"]),
                        engagementRate30d = ToD(r["EngagementRate30d"])
                    };
                }
                else { obj["adminStats"] = EmptyStats(); }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("[CommDash.AdminStats] " + ex.Message);
                obj["adminStats"] = EmptyStats();
            }

            // ── Serialize ─────────────────────────────────────────
            try
            {
                Response.Write(new JavaScriptSerializer { MaxJsonLength = int.MaxValue }.Serialize(obj));
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("[CommDash.Serialize] " + ex.Message);
                Response.Write("{\"error\":\"Serialization failed: " + ex.Message.Replace("\"", "'") + "\"}");
            }
        }

        // ── Helper: try rows, return empty list on failure ────────
        private List<Dictionary<string, object>> TryRows(
            Func<DataTable> fn, string tag)
        {
            try { return Rows(fn()); }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("[CommDash." + tag + "] " + ex.Message);
                return new List<Dictionary<string, object>>();
            }
        }

        // ── Empty defaults ────────────────────────────────────────
        private object EmptyKpi() => new
        {
            totalNotifications = 0,
            unreadNotifications = 0,
            totalHelpRequests = 0,
            openHelpRequests = 0,
            totalAnnouncements = 0,
            totalMessages = 0,
            activeThreads = 0,
            totalUsers = 0,
            engagedUsers = 0,
            resolutionRate = 0.0
        };

        private object EmptyStats() => new
        {
            avgResolutionHours = 0.0,
            notificationsToday = 0,
            helpRequestsToday = 0,
            messagesToday = 0,
            unrespondedOver24h = 0,
            engagementRate30d = 0.0
        };

        // ── Dropdowns ─────────────────────────────────────────────
        private void InitDropdowns()
        {
            try { Fill(aspStream, _bl.GetStreams(InstituteId, SessionId), "StreamId", "StreamName", "All Streams", "0"); }
            catch { }
            try { Fill(aspRole, _bl.GetRoles(InstituteId), "RoleName", "RoleName", "All Roles", ""); }
            catch { }
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

        // ── Converters ────────────────────────────────────────────
        private int ToInt(string v) { int r; return int.TryParse(v, out r) ? r : 0; }
        private string QS(string k) => Request.QueryString[k] ?? "";
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