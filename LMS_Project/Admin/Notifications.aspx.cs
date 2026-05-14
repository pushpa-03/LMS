using System;
using System.Collections.Generic;
using System.Data;
using System.Web;
using System.Web.Script.Serialization;

namespace LearningManagementSystem.Admin
{
    public partial class Notifications : BasePage
    {
        private readonly NotificationBL _bl = new NotificationBL();
        private const int PAGE_SIZE = 20;
        private bool IsSuperAdmin => Session["Role"]?.ToString() == "SuperAdmin";

        protected override void OnLoad(EventArgs e)
        {
            string action = Request.QueryString["ajax"] ?? Request.Form["ajax"] ?? "";
            if (!string.IsNullOrEmpty(action)) { HandleAjax(action); Response.End(); return; }
            base.OnLoad(e);
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                hfInstId.Value = InstituteId.ToString();
                hfSessId.Value = SessionId.ToString();
                hfUserId.Value = UserId.ToString();
                hfSocId.Value = SocietyId.ToString();
                hfIsSuper.Value = IsSuperAdmin ? "1" : "0";
            }
        }

        private void HandleAjax(string action)
        {
            Response.Clear();
            Response.ContentType = "application/json; charset=utf-8";
            Response.Cache.SetCacheability(HttpCacheability.NoCache);
            Response.AddHeader("Cache-Control", "no-cache, no-store");

            int inst = GetI("inst"); if (inst == 0) inst = InstituteId;
            int sess = GetI("sess"); if (sess == 0) sess = SessionId;
            int uid = GetI("uid"); if (uid == 0) uid = UserId;
            int soc = GetI("soc"); if (soc == 0) soc = SocietyId;

            bool isWrite = action == "markread" || action == "markall" ||
                           action == "delete" || action == "deleteall" || action == "send";
            if (isWrite && IsSuperAdmin)
            { Emit(new { ok = false, error = "View only — write operations disabled for SuperAdmin." }); return; }

            try
            {
                object result;
                switch (action)
                {
                    case "list": result = DoList(inst, sess, uid); break;
                    case "stats": result = DoMyStats(inst, sess, uid); break;
                    case "inststats": result = DoInstStats(inst); break;
                    case "preview": result = DoPreview(inst, sess, uid); break;
                    case "types": result = DoTypes(inst, sess, uid); break;
                    case "alltypes": result = DoAllTypes(inst); break;
                    case "markread": result = DoMarkRead(uid); break;
                    case "markall": result = DoMarkAll(inst, sess, uid); break;
                    case "delete": result = DoDelete(uid); break;
                    case "deleteall": result = DoDeleteAll(inst, sess, uid); break;
                    case "send": result = DoSend(soc, inst, sess); break;
                    case "users": result = DoUsers(inst, sess); break;
                    case "sent": result = DoSentList(inst); break;
                    default: result = new { error = "Unknown: " + action }; break;
                }
                Emit(result);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("[AdminNotif] " + ex);
                Response.StatusCode = 500;
                Emit(new { error = ex.Message.Replace("\"", "'").Replace("\r", "").Replace("\n", " ") });
            }
        }

        private object DoMyStats(int inst, int sess, int uid)
        {
            var dt = _bl.GetStats(inst, sess, uid);
            if (dt == null || dt.Rows.Count == 0) return new { Total = 0, Unread = 0, ReadCount = 0, Today = 0, ThisWeek = 0 };
            var r = dt.Rows[0];
            return new
            {
                Total = ToI(r["Total"]),
                Unread = ToI(r["Unread"]),
                ReadCount = ToI(r["ReadCount"]),
                Today = ToI(r["Today"]),
                ThisWeek = ToI(r["ThisWeek"])
            };
        }

        private object DoInstStats(int inst)
        {
            var dt = _bl.GetInstStats(inst);
            if (dt == null || dt.Rows.Count == 0)
                return new { SentBatches = 0, TotalDelivered = 0, TotalRead = 0, TotalUnread = 0, SentToday = 0 };
            var r = dt.Rows[0];
            return new
            {
                SentBatches = ToI(r["SentBatches"]),
                TotalDelivered = ToI(r["TotalDelivered"]),
                TotalRead = ToI(r["TotalRead"]),
                TotalUnread = ToI(r["TotalUnread"]),
                SentToday = ToI(r["SentToday"])
            };
        }

        private object DoList(int inst, int sess, int uid)
        {
            string filter = Get("filter"); if (string.IsNullOrEmpty(filter)) filter = "All";
            string type = Get("type"), search = Get("search");
            int page = Math.Max(1, GetI("page")), pgsz = GetI("pgsize"); if (pgsz < 1) pgsz = PAGE_SIZE;
            int total = _bl.GetListCount(inst, sess, uid, filter, type, search);
            var dt = _bl.GetList(inst, sess, uid, filter, type, search, page, pgsz);
            return new { items = Rows(dt), total, page, pgsize = pgsz, stats = DoMyStats(inst, sess, uid) };
        }

        private object DoPreview(int inst, int sess, int uid)
        {
            int unread = _bl.GetUnreadCount(inst, sess, uid);
            var dt = _bl.GetTopPreview(inst, sess, uid, 2);
            return new { unread, items = Rows(dt) };
        }

        private object DoTypes(int inst, int sess, int uid)
        {
            var dt = _bl.GetDistinctTypes(inst, sess, uid);
            var list = new List<string>();
            if (dt != null) foreach (DataRow r in dt.Rows) list.Add(r["T"]?.ToString() ?? "General");
            return new { types = list };
        }

        private object DoAllTypes(int inst)
        {
            var dt = _bl.GetAllDistinctTypes(inst);
            var list = new List<string>();
            if (dt != null) foreach (DataRow r in dt.Rows) list.Add(r["T"]?.ToString() ?? "General");
            return new { types = list };
        }

        private object DoMarkRead(int uid)
        { int id = GetI("id"); if (id > 0) _bl.MarkRead(id, uid); return new { ok = true }; }

        private object DoMarkAll(int inst, int sess, int uid)
        { _bl.MarkAllRead(inst, sess, uid); return new { ok = true }; }

        private object DoDelete(int uid)
        { int id = GetI("id"); if (id > 0) _bl.DeleteOne(id, uid); return new { ok = true }; }

        private object DoDeleteAll(int inst, int sess, int uid)
        { _bl.DeleteAll(inst, sess, uid); return new { ok = true }; }

        private object DoSend(int soc, int inst, int sess)
        {
            string msg = Get("msg").Trim(), type = Get("type").Trim(),
                   role = Get("role").Trim(), uids = Get("uids").Trim();
            if (string.IsNullOrWhiteSpace(msg)) return new { ok = false, error = "Message cannot be empty." };

            var ids = new List<int>();
            if (!string.IsNullOrWhiteSpace(uids))
                foreach (var s in uids.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries))
                    if (int.TryParse(s.Trim(), out int pid)) ids.Add(pid);

            if (ids.Count == 0 && !string.IsNullOrWhiteSpace(role))
            {
                var dtU = _bl.GetUsersByRole(inst, sess, role);
                if (dtU != null) foreach (DataRow r in dtU.Rows) ids.Add(Convert.ToInt32(r["UserId"]));
            }

            int sent = _bl.SendNotification(soc, inst, sess, msg, type, ids);
            try { LogActivity(UserId, soc, inst, sess, "NotifSent:" + sent, 0); } catch { }
            return new { ok = true, sent };
        }

        private object DoUsers(int inst, int sess)
        { var dt = _bl.GetUsersByRole(inst, sess, Get("role")); return new { users = Rows(dt) }; }

        private object DoSentList(int inst)
        {
            int page = Math.Max(1, GetI("page")), pgsz = GetI("pgsize"); if (pgsz < 1) pgsz = PAGE_SIZE;
            string type = Get("type").Trim(), search = Get("search");
            var dt = _bl.GetSentList(inst, type, search, page, pgsz);
            int total = _bl.GetSentCount(inst, type, search);
            return new { items = Rows(dt), total, page, pgsize = pgsz };
        }

        private string Get(string k) => Request.QueryString[k] ?? Request.Form[k] ?? "";
        private int GetI(string k) { int v; int.TryParse(Get(k), out v); return v; }
        private int ToI(object v) => v == null || v == DBNull.Value ? 0 : Convert.ToInt32(v);
        private void Emit(object o) =>
            Response.Write(new JavaScriptSerializer { MaxJsonLength = int.MaxValue }.Serialize(o));

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