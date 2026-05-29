using System;
using System.Data;
using System.Web;
using System.Web.Services;
using Newtonsoft.Json;

namespace LearningManagementSystem.Admin
{
    public partial class VideoPlayer : BasePage
    {
        VideoPlayerBL _bl = new VideoPlayerBL();

        public string VideoPath = "";

        public int VideoId =>
            int.TryParse(Request.QueryString["VideoId"], out int id) && id > 0 ? id : 0;

        protected void Page_Load(object sender, EventArgs e)
        {
            try
            {
                if (VideoId == 0) { ShowMsg("Invalid Video ID.", "warning"); return; }
                if (!IsPostBack)
                {
                    if (SessionId == 0) { ShowMsg("No active session.", "warning"); return; }
                    hfVideoId.Value = VideoId.ToString();
                    hfSessionId.Value = SessionId.ToString();
                    hfAdminName.Value = _bl.GetUserDisplayName(UserId)?["FullName"]?.ToString() ?? "Admin";
                    LoadVideo();
                    LoadTopics();
                    LoadPlaylist();
                    LoadEngagement();
                    LoadAIStats();
                    LoadStats();
                    LoadRating();
                    // Admin view — NOT counted in student views
                    _bl.LogActivity(UserId, SocietyId, InstituteId, SessionId, "VideoView", VideoId);
                }
            }
            catch (Exception ex) { ShowMsg("Error: " + ex.Message, "danger"); }
        }

        private void LoadVideo()
        {
            DataTable dt = _bl.GetVideoDetails(VideoId, SessionId);

            if (dt == null || dt.Rows.Count == 0)
            {
                ShowMsg("Video not found.", "warning");
                btnNext.Visible = btnPrev.Visible = false;
                return;
            }

            DataRow r = dt.Rows[0];

            pageTitle.InnerText = r["Title"]?.ToString() ?? "";
            lblVideoTitle.InnerText = r["Title"]?.ToString() ?? "—";
            lblDesc.InnerText = r["Description"]?.ToString() ?? "";
            lblInstructor.InnerText = r["InstructorName"]?.ToString() ?? "Unknown";
            liveViews.InnerText = r["UniqueStudentViews"]?.ToString() ?? "0";

            if (r["UploadedOn"] != DBNull.Value)
                lblUploadDate.InnerText =
                    Convert.ToDateTime(r["UploadedOn"]).ToString("dd MMM yyyy");

            string path = r["VideoPath"]?.ToString() ?? "";
            if (!string.IsNullOrWhiteSpace(path))
                VideoPath = ResolveUrl(path.Replace("..", "~"));

            int nextId = _bl.GetNextVideo(VideoId, SessionId);
            int prevId = _bl.GetPrevVideo(VideoId, SessionId);
            btnNext.Visible = nextId > 0 && nextId != VideoId;
            btnPrev.Visible = prevId > 0 && prevId != VideoId;
        }

        private void LoadRating()
        {
            DataRow r = _bl.GetRatingSummary(VideoId);
            if (r == null) { avgRatingVal.InnerText = "N/A"; return; }
            double avg = r["AvgRating"] != DBNull.Value ? Convert.ToDouble(r["AvgRating"]) : 0;
            int count = r["RatingCount"] != DBNull.Value ? Convert.ToInt32(r["RatingCount"]) : 0;
            avgRatingVal.InnerText = avg > 0 ? avg.ToString("F1") : "N/A";
            ratingCount.InnerText = count + " rating" + (count != 1 ? "s" : "");
            string stars = "";
            for (int i = 1; i <= 5; i++)
                stars += i <= Math.Round(avg)
                    ? "<i class='fa fa-star son'></i>"
                    : "<i class='fa fa-star soff'></i>";
            ratingStars.InnerHtml = stars;
        }

        private void LoadTopics()
        {
            rptTopics.DataSource = _bl.GetVideoTopics(VideoId, SessionId);
            rptTopics.DataBind();
        }

        private void LoadPlaylist()
        {
            rptPlaylist.DataSource = _bl.GetPlaylist(VideoId, SessionId);
            rptPlaylist.DataBind();
        }

        private void LoadEngagement()
        {
            rptEngagement.DataSource = _bl.GetEngagement(VideoId, SessionId);
            rptEngagement.DataBind();
        }

        private void LoadAIStats()
        {
            rptAIStats.DataSource = _bl.GetAIUsageStats(VideoId);
            rptAIStats.DataBind();
        }

        private void LoadStats()
        {
            DataTable dt = _bl.GetVideoStats(VideoId, SessionId);
            if (dt == null || dt.Rows.Count == 0) return;
            DataRow r = dt.Rows[0];
            statViews.InnerText = r["StudentViews"]?.ToString() ?? "0";
            statStudents.InnerText = r["UniqueStudents"]?.ToString() ?? "0";
            statCompletion.InnerText = (r["AvgCompletion"]?.ToString() ?? "0") + "%";
            statComments.InnerText = r["CommentCount"]?.ToString() ?? "0";
        }

        protected void btnNext_Click(object sender, EventArgs e)
        {
            int n = _bl.GetNextVideo(VideoId, SessionId);
            if (n > 0 && n != VideoId) Response.Redirect("VideoPlayer.aspx?VideoId=" + n);
        }

        protected void btnPrev_Click(object sender, EventArgs e)
        {
            int p = _bl.GetPrevVideo(VideoId, SessionId);
            if (p > 0 && p != VideoId) Response.Redirect("VideoPlayer.aspx?VideoId=" + p);
        }

        // ═══════════════════════════════════════════════════════════════════════
        //  AJAX WEBMETHODS — Comments
        //
        //  GetComments : returns top-level comments with nested Replies list.
        //                Each item includes Username, Role, Comment, CommentedOn,
        //                ReplyCount, and Replies[].
        //
        //  AddComment  : posts a new top-level comment (any role).
        //  AddReply    : posts a reply to an existing comment (any role).
        //  DeleteCommentAjax : hard-deletes comment + cascades replies.
        //  SaveProgress      : upserts watch progress every 10 s.
        // ═══════════════════════════════════════════════════════════════════════

        /// <summary>
        /// Returns all top-level comments for the video, each with a Replies list.
        /// Role names are included so the JS can render role-coloured avatars and
        /// badges exactly as the StudyMaterial page does.
        /// </summary>
        [WebMethod(EnableSession = true)]
        public static string GetComments(int vid, int sessId)
        {
            try
            {
                // sessId comes from hfSessionId hidden field (set server-side from BasePage.SessionId)
                // Fallback: try common session keys used by admin BasePage
                if (sessId == 0)
                    sessId = GetSessMulti("SessionId", "CurrentSessionId", "AcademicSessionId");
                var bl = new VideoPlayerBL();

                DataTable dt = bl.GetComments(vid, sessId);

                var result = new System.Collections.Generic.List<object>();

                foreach (DataRow r in dt.Rows)
                {
                    int cmtId = Convert.ToInt32(r["CommentId"]);

                    // Load replies for this parent comment
                    DataTable rDt = bl.GetReplies(cmtId, sessId);
                    var replies = new System.Collections.Generic.List<object>();

                    foreach (DataRow rr in rDt.Rows)
                    {
                        replies.Add(new
                        {
                            CommentId = Convert.ToInt32(rr["CommentId"]),
                            ParentCommentId = rr["ParentCommentId"] != DBNull.Value
                                ? Convert.ToInt32(rr["ParentCommentId"]) : 0,

                            // Display name (FullName preferred, falls back to Username)
                            Username = rr["Username"]?.ToString() ?? "",
                            Role = rr["RoleName"]?.ToString() ?? "",
                            Comment = rr["Comment"]?.ToString() ?? "",
                            CommentedOn = rr["CommentedOn"] != DBNull.Value
                                ? Convert.ToDateTime(rr["CommentedOn"])
                                    .ToString("dd MMM yyyy, hh:mm tt") : ""
                        });
                    }

                    result.Add(new
                    {
                        CommentId = cmtId,
                        ParentCommentId = r["ParentCommentId"] != DBNull.Value
                            ? Convert.ToInt32(r["ParentCommentId"]) : 0,

                        Username = r["Username"]?.ToString() ?? "",
                        Role = r["RoleName"]?.ToString() ?? "",
                        Comment = r["Comment"]?.ToString() ?? "",
                        CommentedOn = r["CommentedOn"] != DBNull.Value
                            ? Convert.ToDateTime(r["CommentedOn"])
                                .ToString("dd MMM yyyy, hh:mm tt") : "",

                        ReplyCount = replies.Count,
                        Replies = replies
                    });
                }

                return JsonConvert.SerializeObject(result);
            }
            catch (Exception ex)
            {
                return JsonConvert.SerializeObject(new { error = ex.Message });
            }
        }

        /// <summary>Posts a top-level comment (any role: admin, teacher, student).</summary>
        [WebMethod(EnableSession = true)]
        public static void AddComment(int vid, string msg, int sessId)
        {
            if (string.IsNullOrWhiteSpace(msg)) return;
            try
            {
                if (sessId == 0)
                    sessId = GetSessMulti("SessionId", "CurrentSessionId", "AcademicSessionId");
                new VideoPlayerBL().SaveComment(
                    vid,
                    sessId,
                    GetSess("UserId"),
                    msg.Trim(),
                    GetSess("SocietyId"),
                    GetSess("InstituteId"),
                    null);   // null parentId → top-level
            }
            catch { }
        }

        /// <summary>Posts a reply to an existing comment (any role).</summary>
        [WebMethod(EnableSession = true)]
        public static void AddReply(int vid, int parentId, string msg, int sessId)
        {
            if (string.IsNullOrWhiteSpace(msg)) return;
            try
            {
                if (sessId == 0)
                    sessId = GetSessMulti("SessionId", "CurrentSessionId", "AcademicSessionId");
                new VideoPlayerBL().SaveComment(
                    vid,
                    sessId,
                    GetSess("UserId"),
                    msg.Trim(),
                    GetSess("SocietyId"),
                    GetSess("InstituteId"),
                    parentId);
            }
            catch { }
        }

        /// <summary>
        /// Deletes a comment and all its replies.
        /// Replies are deleted first to handle databases without ON DELETE CASCADE.
        /// </summary>
        [WebMethod(EnableSession = true)]
        public static void DeleteCommentAjax(int commentId, int sessId)
        {
            try
            {
                if (sessId == 0)
                    sessId = GetSessMulti("SessionId", "CurrentSessionId", "AcademicSessionId");
                new VideoPlayerBL().DeleteComment(commentId, sessId);
            }
            catch { }
        }

        /// <summary>
        /// Saves watch progress called every 10 s from JS.
        /// Updates VideoWatchProgress; marks IsCompleted=1 at 100%.
        /// Student-only view counting is also handled here (RoleId=4).
        /// </summary>
        [WebMethod(EnableSession = true)]
        public static string SaveProgress(int vid, int watchedSec, int totalSec)
        {
            try
            {
                if (totalSec <= 0) return "error";

                int userId = GetSess("UserId");
                int sessionId = GetSessMulti("SessionId", "CurrentSessionId", "AcademicSessionId");
                int societyId = GetSess("SocietyId");
                int instituteId = GetSess("InstituteId");
                int roleId = GetSess("RoleId");

                int pct = (int)Math.Min(100, Math.Round((double)watchedSec / totalSec * 100));

                var bl = new VideoPlayerBL();
                bl.UpsertWatchProgress(
                    vid, sessionId, userId, societyId, instituteId,
                    watchedSec, totalSec, pct, watchedSec);

                // Track view only for students (RoleId = 4)
                if (roleId == 4)
                    bl.TrackStudentView(vid, sessionId, userId, societyId, instituteId);

                return pct >= 100 ? "completed" : "ok";
            }
            catch { return "error"; }
        }

        // ── Session helpers ──────────────────────────────────────────────────
        /// <summary>
        /// Reads a single key from ASP.NET Session.
        /// </summary>
        private static int GetSess(string key)
        {
            var v = HttpContext.Current.Session[key];
            return v != null && int.TryParse(v.ToString(), out int r) ? r : 0;
        }

        /// <summary>
        /// Tries multiple session key names in order, returns the first non-zero value.
        /// Handles differences between Admin BasePage ("SessionId") and
        /// Student BasePage ("CurrentSessionId" / "AcademicSessionId").
        /// </summary>
        private static int GetSessMulti(params string[] keys)
        {
            var session = HttpContext.Current.Session;
            foreach (var key in keys)
            {
                var v = session[key];
                if (v != null && int.TryParse(v.ToString(), out int r) && r > 0)
                    return r;
            }
            return 0;
        }

        private void ShowMsg(string msg, string type)
        {
            lblMsg.Text = msg;
            lblMsg.CssClass = $"alert alert-{type} alert-box";
            lblMsg.Visible = true;
        }
    }
}