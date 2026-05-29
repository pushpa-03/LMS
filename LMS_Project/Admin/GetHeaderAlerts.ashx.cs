using System;
using System.Data.SqlClient;
using System.Web;
using System.Web.SessionState;

namespace LMS_Project.Admin
{
    public class GetHeaderAlerts : IHttpHandler, IRequiresSessionState
    {
        public void ProcessRequest(HttpContext ctx)
        {
            ctx.Response.ContentType = "application/json";
            ctx.Response.Cache.SetNoStore();

            try
            {
                var sessInstitute = ctx.Session["InstituteId"];
                var sessSession = ctx.Session["SessionId"];
                var sessUser = ctx.Session["UserId"];

                if (sessInstitute == null || sessUser == null)
                { WriteZero(ctx); return; }

                int instituteId = Convert.ToInt32(sessInstitute);
                int sessionId = Convert.ToInt32(sessSession ?? 0);
                int adminUserId = Convert.ToInt32(sessUser);

                if (instituteId == 0 || adminUserId == 0)
                { WriteZero(ctx); return; }

                var csEntry = System.Configuration.ConfigurationManager
                                    .ConnectionStrings["DefaultConnection"];
                if (csEntry == null)
                { ctx.Response.Write("{\"error\":\"No connection string\"}"); return; }

                int unreadHelp = 0, newEvents = 0, unreadNotif = 0;

                using (var con = new SqlConnection(csEntry.ConnectionString))
                {
                    con.Open();

                    // ── Help: NO SessionId filter (matches HelpBL.GetUnrepliedCount) ──
                    using (var cmd = new SqlCommand(@"
                        SELECT COUNT(*) FROM HelpRequests hr
                        WHERE hr.InstituteId = @iid
                          AND NOT EXISTS (
                              SELECT 1 FROM HelpReplies rp
                              WHERE rp.HelpId = hr.HelpId
                          )", con))
                    {
                        cmd.Parameters.AddWithValue("@iid", instituteId);
                        unreadHelp = (int)cmd.ExecuteScalar();
                    }

                    // ── Calendar: events by others in last 24 h ──────────────────
                    using (var cmd = new SqlCommand(@"
                        SELECT COUNT(*) FROM CalendarEvents
                        WHERE InstituteId = @iid
                          AND UserId     <> @uid
                          AND CreatedAt  >= DATEADD(HOUR,-24,GETDATE())", con))
                    {
                        cmd.Parameters.AddWithValue("@iid", instituteId);
                        cmd.Parameters.AddWithValue("@uid", adminUserId);
                        newEvents = (int)cmd.ExecuteScalar();
                    }

                    // ── Notifications: unread for this admin ─────────────────────
                    using (var cmd = new SqlCommand(@"
                        SELECT COUNT(*) FROM Notifications
                        WHERE InstituteId = @iid
                          AND (UserId = @uid OR UserId IS NULL)
                          AND IsRead = 0", con))
                    {
                        cmd.Parameters.AddWithValue("@iid", instituteId);
                        cmd.Parameters.AddWithValue("@uid", adminUserId);
                        unreadNotif = (int)cmd.ExecuteScalar();
                    }
                }

                ctx.Response.Write(string.Format(
                    "{{\"unreadHelp\":{0},\"newEvents\":{1},\"unreadNotif\":{2}}}",
                    unreadHelp, newEvents, unreadNotif));
            }
            catch (Exception ex)
            {
                ctx.Response.StatusCode = 200;
                ctx.Response.Write("{\"error\":" + JsonString(ex.Message) + "}");
            }
        }

        private static void WriteZero(HttpContext ctx)
        {
            ctx.Response.Write("{\"unreadHelp\":0,\"newEvents\":0,\"unreadNotif\":0}");
        }

        private static string JsonString(string s)
        {
            if (s == null) return "null";
            return "\"" + s.Replace("\\", "\\\\")
                           .Replace("\"", "\\\"")
                           .Replace("\r", "\\r")
                           .Replace("\n", "\\n") + "\"";
        }

        public bool IsReusable => false;
    }
}