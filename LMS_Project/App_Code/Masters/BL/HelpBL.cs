using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using LearningManagementSystem.GC;

namespace LearningManagementSystem.BL
{
    public class HelpBL
    {
        private readonly DataLayer _dl = new DataLayer();

        // ─── GET ALL HELP REQUESTS FOR ADMIN (with last reply info) ───────────────
        public List<HelpRequestGC> GetAllHelpRequests(int societyId, int instituteId)
        {
            var list = new List<HelpRequestGC>();

            SqlCommand cmd = new SqlCommand(@"
                SELECT 
                    hr.HelpId, hr.UserId, hr.Question, hr.AskedOn,
                    u.Username,
                    r.RoleName,
                    rep.Reply     AS ReplyText,
                    rep.RepliedOn
                FROM HelpRequests hr
                INNER JOIN Users u ON u.UserId = hr.UserId
                INNER JOIN Roles r ON r.RoleId = u.RoleId
                LEFT JOIN (
                    SELECT HelpId, Reply, RepliedOn,
                           ROW_NUMBER() OVER (PARTITION BY HelpId ORDER BY RepliedOn DESC) AS rn
                    FROM HelpReplies
                    WHERE SocietyId = @SocietyId AND InstituteId = @InstituteId
                ) rep ON rep.HelpId = hr.HelpId AND rep.rn = 1
                WHERE hr.SocietyId = @SocietyId AND hr.InstituteId = @InstituteId
                ORDER BY hr.AskedOn DESC");

            cmd.Parameters.AddWithValue("@SocietyId", societyId);
            cmd.Parameters.AddWithValue("@InstituteId", instituteId);

            DataTable dt = _dl.GetDataTable(cmd);

            foreach (DataRow dr in dt.Rows)
            {
                list.Add(new HelpRequestGC
                {
                    HelpId = Convert.ToInt32(dr["HelpId"]),
                    UserId = Convert.ToInt32(dr["UserId"]),
                    Username = dr["Username"].ToString(),
                    RoleName = dr["RoleName"].ToString(),
                    Question = dr["Question"].ToString(),
                    AskedOn = Convert.ToDateTime(dr["AskedOn"]),
                    HasReply = dr["ReplyText"] != DBNull.Value,
                    ReplyText = dr["ReplyText"] == DBNull.Value ? null : dr["ReplyText"].ToString(),
                    RepliedOn = dr["RepliedOn"] == DBNull.Value
                                    ? (DateTime?)null
                                    : Convert.ToDateTime(dr["RepliedOn"])
                });
            }

            return list;
        }

        // ─── GET SINGLE HELP REQUEST BY ID ────────────────────────────────────────
        public HelpRequestGC GetHelpRequestById(int helpId, int societyId, int instituteId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT hr.HelpId, hr.UserId, hr.Question, hr.AskedOn,
                       u.Username, r.RoleName
                FROM HelpRequests hr
                INNER JOIN Users u ON u.UserId = hr.UserId
                INNER JOIN Roles r ON r.RoleId = u.RoleId
                WHERE hr.HelpId     = @HelpId
                  AND hr.SocietyId  = @SocietyId
                  AND hr.InstituteId = @InstituteId");

            cmd.Parameters.AddWithValue("@HelpId", helpId);
            cmd.Parameters.AddWithValue("@SocietyId", societyId);
            cmd.Parameters.AddWithValue("@InstituteId", instituteId);

            DataTable dt = _dl.GetDataTable(cmd);

            if (dt.Rows.Count == 0) return null;

            DataRow dr = dt.Rows[0];
            return new HelpRequestGC
            {
                HelpId = Convert.ToInt32(dr["HelpId"]),
                UserId = Convert.ToInt32(dr["UserId"]),
                Username = dr["Username"].ToString(),
                RoleName = dr["RoleName"].ToString(),
                Question = dr["Question"].ToString(),
                AskedOn = Convert.ToDateTime(dr["AskedOn"])
            };
        }

        // ─── GET ALL REPLIES FOR A SINGLE HELP REQUEST ───────────────────────────
        public List<HelpReplyGC> GetRepliesByHelpId(int helpId, int societyId, int instituteId)
        {
            var list = new List<HelpReplyGC>();

            SqlCommand cmd = new SqlCommand(@"
                SELECT ReplyId, HelpId, AdminId, Reply, RepliedOn
                FROM HelpReplies
                WHERE HelpId      = @HelpId
                  AND SocietyId   = @SocietyId
                  AND InstituteId = @InstituteId
                ORDER BY RepliedOn ASC");

            cmd.Parameters.AddWithValue("@HelpId", helpId);
            cmd.Parameters.AddWithValue("@SocietyId", societyId);
            cmd.Parameters.AddWithValue("@InstituteId", instituteId);

            DataTable dt = _dl.GetDataTable(cmd);

            foreach (DataRow dr in dt.Rows)
            {
                list.Add(new HelpReplyGC
                {
                    ReplyId = Convert.ToInt32(dr["ReplyId"]),
                    HelpId = Convert.ToInt32(dr["HelpId"]),
                    AdminId = Convert.ToInt32(dr["AdminId"]),
                    Reply = dr["Reply"].ToString(),
                    RepliedOn = Convert.ToDateTime(dr["RepliedOn"])
                });
            }

            return list;
        }

        // ─── POST A REPLY FROM ADMIN ──────────────────────────────────────────────
        public bool PostReply(HelpReplyGC gc)
        {
            SqlCommand cmd = new SqlCommand(@"
                INSERT INTO HelpReplies (SocietyId, InstituteId, HelpId, AdminId, Reply, RepliedOn)
                VALUES (@SocietyId, @InstituteId, @HelpId, @AdminId, @Reply, GETDATE())");

            cmd.Parameters.AddWithValue("@SocietyId", gc.SocietyId);
            cmd.Parameters.AddWithValue("@InstituteId", gc.InstituteId);
            cmd.Parameters.AddWithValue("@HelpId", gc.HelpId);
            cmd.Parameters.AddWithValue("@AdminId", gc.AdminId);
            cmd.Parameters.AddWithValue("@Reply", gc.Reply);

            try
            {
                _dl.ExecuteCMD(cmd);
                return true;
            }
            catch
            {
                return false;
            }
        }

        // ─── COUNT UNANSWERED REQUESTS (for badge in header) ─────────────────────
        public int GetUnrepliedCount(int societyId, int instituteId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT COUNT(*) FROM HelpRequests hr
                WHERE hr.SocietyId   = @SocietyId
                  AND hr.InstituteId = @InstituteId
                  AND NOT EXISTS (
                      SELECT 1 FROM HelpReplies rp
                      WHERE rp.HelpId      = hr.HelpId
                        AND rp.SocietyId   = @SocietyId
                        AND rp.InstituteId = @InstituteId
                  )");

            cmd.Parameters.AddWithValue("@SocietyId", societyId);
            cmd.Parameters.AddWithValue("@InstituteId", instituteId);

            DataTable dt = _dl.GetDataTable(cmd);

            if (dt.Rows.Count > 0 && dt.Rows[0][0] != DBNull.Value)
                return Convert.ToInt32(dt.Rows[0][0]);

            return 0;
        }

        // ─── DELETE A HELP REQUEST ────────────────────────────────────────────────
        public bool DeleteHelpRequest(int helpId, int societyId, int instituteId)
        {
            // DataLayer.ExecuteTransaction handles the two deletes in one transaction
            var commands = new List<SqlCommand>();

            SqlCommand del1 = new SqlCommand(@"
                DELETE FROM HelpReplies
                WHERE HelpId = @HelpId AND SocietyId = @S AND InstituteId = @I");
            del1.Parameters.AddWithValue("@HelpId", helpId);
            del1.Parameters.AddWithValue("@S", societyId);
            del1.Parameters.AddWithValue("@I", instituteId);

            SqlCommand del2 = new SqlCommand(@"
                DELETE FROM HelpRequests
                WHERE HelpId = @HelpId AND SocietyId = @S AND InstituteId = @I");
            del2.Parameters.AddWithValue("@HelpId", helpId);
            del2.Parameters.AddWithValue("@S", societyId);
            del2.Parameters.AddWithValue("@I", instituteId);

            commands.Add(del1);
            commands.Add(del2);

            try
            {
                return _dl.ExecuteTransaction(commands);
            }
            catch
            {
                return false;
            }
        }
    }
}