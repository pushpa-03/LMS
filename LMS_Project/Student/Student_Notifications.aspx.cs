using System;
using System.Collections.Generic;
using System.Data;
using System.Web;
using System.Web.Script.Serialization;

namespace LearningManagementSystem.Student
{
    public partial class Notifications : BasePage
    {
        private readonly NotificationBL _bl = new NotificationBL();
        private const int PAGE_SIZE = 20;

        protected override void OnLoad(EventArgs e)
        {
            string action = Request.QueryString["ajax"] ?? Request.Form["ajax"] ?? "";
            if (!string.IsNullOrEmpty(action))
            {
                HandleAjax(action);
                Response.End();
                return;
            }
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

            try
            {
                object result;
                switch (action)
                {
                    case "list": result = DoList(inst, sess, uid); break;
                    case "stats": result = DoStats(inst, sess, uid); break;
                    case "preview": result = DoPreview(inst, sess, uid); break;
                    case "types": result = DoTypes(inst, sess, uid); break;
                    case "markread": result = DoMarkRead(uid); break;
                    case "markall": result = DoMarkAll(inst, sess, uid); break;
                    case "delete": result = DoDelete(uid); break;
                    case "deleteall": result = DoDeleteAll(inst, sess, uid); break;
                    default: result = new { error = "Unknown action: " + action }; break;
                }
                Emit(result);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("[StudentNotif] " + ex);
                Response.StatusCode = 500;
                Emit(new { error = ex.Message });
            }
        }

        private object DoList(int inst, int sess, int uid)
        {
            string filter = Get("filter"); if (string.IsNullOrEmpty(filter)) filter = "All";
            string type = Get("type");
            string search = Get("search");
            int page = Math.Max(1, GetI("page"));
            int pgsz = GetI("pgsize"); if (pgsz < 1) pgsz = PAGE_SIZE;

            int total = _bl.GetListCount(inst, sess, uid, filter, type, search);
            DataTable dt = _bl.GetList(inst, sess, uid, filter, type, search, page, pgsz);
            return new { items = Rows(dt), total, page, pgsize = pgsz, stats = BuildStats(inst, sess, uid) };
        }

        private object DoStats(int inst, int sess, int uid) => BuildStats(inst, sess, uid);

        private object BuildStats(int inst, int sess, int uid)
        {
            DataTable dt = _bl.GetStats(inst, sess, uid);
            if (dt == null || dt.Rows.Count == 0)
                return new { Total = 0, Unread = 0, ReadCount = 0, Today = 0, ThisWeek = 0 };
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

        private object DoPreview(int inst, int sess, int uid)
        {
            int unread = _bl.GetUnreadCount(inst, sess, uid);
            DataTable dt = _bl.GetTopPreview(inst, sess, uid, 2);
            return new { unread, items = Rows(dt) };
        }

        private object DoTypes(int inst, int sess, int uid)
        {
            DataTable dt = _bl.GetDistinctTypes(inst, sess, uid);
            var list = new List<string>();
            if (dt != null) foreach (DataRow r in dt.Rows) list.Add(r["T"]?.ToString() ?? "General");
            return new { types = list };
        }

        private object DoMarkRead(int uid)
        {
            int id = GetI("id"); if (id > 0) _bl.MarkRead(id, uid);
            return new { ok = true };
        }
        private object DoMarkAll(int inst, int sess, int uid)
        {
            _bl.MarkAllRead(inst, sess, uid); return new { ok = true };
        }
        private object DoDelete(int uid)
        {
            int id = GetI("id"); if (id > 0) _bl.DeleteOne(id, uid);
            return new { ok = true };
        }
        private object DoDeleteAll(int inst, int sess, int uid)
        {
            _bl.DeleteAll(inst, sess, uid); return new { ok = true };
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