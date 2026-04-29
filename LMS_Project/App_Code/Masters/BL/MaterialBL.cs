using System;
using System.Data;
using System.Data.SqlClient;

namespace LearningManagementSystem.Admin
{
    public class MaterialBL
    {
        private readonly DataLayer _dl = new DataLayer();

        // ── Get material with chapter & subject info ───────────────────────────
        public DataTable GetMaterialById(int materialId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT
                    M.MaterialId,
                    M.Title,
                    M.FilePath,
                    M.FileType,
                    M.UploadedOn,
                    ISNULL(C.ChapterName, 'N/A') AS ChapterName,
                    ISNULL(S.SubjectName, 'N/A') AS SubjectName
                FROM Materials M
                LEFT JOIN Chapters C ON M.ChapterId = C.ChapterId
                LEFT JOIN Subjects S ON C.SubjectId = S.SubjectId
                WHERE M.MaterialId = @MaterialId");
            cmd.Parameters.AddWithValue("@MaterialId", materialId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        // ── Save AI interaction to history ────────────────────────────────────
        public void SaveAIHistory(int materialId, int userId, string type,
            string question, string response)
        {
            SqlCommand cmd = new SqlCommand(@"
                INSERT INTO MaterialAIHistory (MaterialId, UserId, Type, Question, Response, CreatedOn)
                VALUES (@MaterialId, @UserId, @Type, @Question, @Response, GETDATE())");
            cmd.Parameters.AddWithValue("@MaterialId", materialId);
            cmd.Parameters.AddWithValue("@UserId", userId);
            cmd.Parameters.AddWithValue("@Type", type);
            cmd.Parameters.AddWithValue("@Question", question ?? "");
            cmd.Parameters.AddWithValue("@Response", response ?? "");
            _dl.ExecuteCMD(cmd);
        }

        // ── Get AI history for ALL users (admin view) ─────────────────────────
        public DataTable GetAllHistory(int materialId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT
                    H.Type,
                    H.Question,
                    H.Response,
                    H.CreatedOn,
                    ISNULL(UP.FullName, U.Username) AS UserName
                FROM MaterialAIHistory H
                INNER JOIN Users       U  ON H.UserId = U.UserId
                LEFT  JOIN UserProfile UP ON H.UserId = UP.UserId
                WHERE H.MaterialId = @MaterialId
                ORDER BY H.CreatedOn DESC");
            cmd.Parameters.AddWithValue("@MaterialId", materialId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        // ── Get AI history for a SINGLE user ─────────────────────────────────
        public DataTable GetUserHistory(int materialId, int userId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT Type, Question, Response, CreatedOn
                FROM MaterialAIHistory
                WHERE MaterialId = @MaterialId AND UserId = @UserId
                ORDER BY CreatedOn DESC");
            cmd.Parameters.AddWithValue("@MaterialId", materialId);
            cmd.Parameters.AddWithValue("@UserId", userId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        // ── Get recent context for smarter AI prompts (last 3 interactions) ──
        public string GetRecentContext(int materialId, int userId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT TOP 3 Question + ' ' + Response AS Text
                FROM MaterialAIHistory
                WHERE MaterialId = @MaterialId AND UserId = @UserId
                ORDER BY CreatedOn DESC");
            cmd.Parameters.AddWithValue("@MaterialId", materialId);
            cmd.Parameters.AddWithValue("@UserId", userId);
            DataTable dt = _dl.GetDataTable(cmd);

            string ctx = "";
            if (dt != null)
                foreach (DataRow r in dt.Rows)
                    ctx += r["Text"]?.ToString() + "\n";
            return ctx;
        }

        // ── AI usage stats per type ───────────────────────────────────────────
        public DataTable GetAIUsageStats(int materialId)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT Type, COUNT(*) AS UsageCount
                FROM MaterialAIHistory
                WHERE MaterialId = @MaterialId
                GROUP BY Type
                ORDER BY UsageCount DESC");
            cmd.Parameters.AddWithValue("@MaterialId", materialId);
            return _dl.GetDataTable(cmd) ?? new DataTable();
        }

        // ── Activity log ──────────────────────────────────────────────────────
        public void LogActivity(int userId, int societyId, int instituteId,
            int sessionId, string activityType, int referenceId = 0)
        {
            try
            {
                SqlCommand cmd = new SqlCommand(@"
                    INSERT INTO UserActivityLog
                        (UserId, SocietyId, InstituteId, SessionId, ActivityType, ReferenceId, ActionTime)
                    VALUES
                        (@UserId, @SocId, @InstId, @SessionId, @Activity, @RefId, GETDATE())");
                cmd.Parameters.AddWithValue("@UserId", userId);
                cmd.Parameters.AddWithValue("@SocId", societyId);
                cmd.Parameters.AddWithValue("@InstId", instituteId);
                cmd.Parameters.AddWithValue("@SessionId", sessionId);
                cmd.Parameters.AddWithValue("@Activity", activityType);
                cmd.Parameters.AddWithValue("@RefId", referenceId);
                _dl.ExecuteCMD(cmd);
            }
            catch { }
        }
    }
}