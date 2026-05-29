using System;
using System.Data;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using Newtonsoft.Json;

namespace LMS_Project.Teacher
{
    public partial class TeacherVideoPlayer : BasePage
    {
        private readonly VideoPlayerBL _bl = new VideoPlayerBL();

        /// <summary>Resolved virtual path to the video file — read by inline JS.</summary>
        public string VideoPath = "";

        /// <summary>Current VideoId from query-string.</summary>
        public int VideoId =>
            int.TryParse(Request.QueryString["VideoId"], out int id) && id > 0 ? id : 0;

        // ═════════════════════════════════════════════════════════════════════
        //  PAGE LOAD
        // ═════════════════════════════════════════════════════════════════════
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
                    hfTeacherName.Value = GetTeacherDisplayName();

                    LoadVideo();
                    LoadTopics();
                    LoadPlaylist();
                    LoadEngagement();
                    LoadAIStats();
                    LoadStats();
                    LoadRating();

                    // Log teacher activity (NOT counted as student view)
                    _bl.LogActivity(UserId, SocietyId, InstituteId, SessionId, "TeacherVideoView", VideoId);
                }
            }
            catch (Exception ex) { ShowMsg("Error: " + ex.Message, "danger"); }
        }

        // ═════════════════════════════════════════════════════════════════════
        //  LOAD METHODS
        // ═════════════════════════════════════════════════════════════════════
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
                lblUploadDate.InnerText = Convert.ToDateTime(r["UploadedOn"]).ToString("dd MMM yyyy");

            string rawPath = r["VideoPath"]?.ToString() ?? "";
            if (!string.IsNullOrWhiteSpace(rawPath))
                VideoPath = ResolveUrl(rawPath.Replace("..", "~"));

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

        // ═════════════════════════════════════════════════════════════════════
        //  NAVIGATION
        // ═════════════════════════════════════════════════════════════════════
        protected void btnNext_Click(object sender, EventArgs e)
        {
            int n = _bl.GetNextVideo(VideoId, SessionId);
            if (n > 0 && n != VideoId) Response.Redirect("TeacherVideoPlayer.aspx?VideoId=" + n);
        }

        protected void btnPrev_Click(object sender, EventArgs e)
        {
            int p = _bl.GetPrevVideo(VideoId, SessionId);
            if (p > 0 && p != VideoId) Response.Redirect("TeacherVideoPlayer.aspx?VideoId=" + p);
        }

        // ═════════════════════════════════════════════════════════════════════
        //  AJAX WEBMETHODS
        // ═════════════════════════════════════════════════════════════════════

        /// <summary>
        /// Returns all top-level comments with nested Replies[], Username, Role, etc.
        /// Identical shape to the admin VideoPlayer.GetComments so the same JS renderer works.
        /// </summary>
        [WebMethod(EnableSession = true)]
        public static string GetComments(int vid, int sessId)
        {
            try
            {
                if (sessId == 0)
                    sessId = GetSessMulti("SessionId", "CurrentSessionId", "AcademicSessionId");

                var bl = new VideoPlayerBL();
                DataTable dt = bl.GetComments(vid, sessId);

                var result = new System.Collections.Generic.List<object>();
                foreach (DataRow r in dt.Rows)
                {
                    int cmtId = Convert.ToInt32(r["CommentId"]);

                    DataTable rDt = bl.GetReplies(cmtId, sessId);
                    var replies = new System.Collections.Generic.List<object>();
                    foreach (DataRow rr in rDt.Rows)
                    {
                        replies.Add(new
                        {
                            CommentId = Convert.ToInt32(rr["CommentId"]),
                            ParentCommentId = rr["ParentCommentId"] != DBNull.Value
                                                ? Convert.ToInt32(rr["ParentCommentId"]) : 0,
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

        /// <summary>Posts a top-level comment (any role).</summary>
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

        /// <summary>Posts a reply to an existing comment.</summary>
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

        /// <summary>Deletes a comment and all its replies.</summary>
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
        /// Saves teacher watch progress every 10 s.
        /// Teachers are NOT counted in student view metrics (RoleId check happens in BL).
        /// Progress is still tracked so teachers can resume playback.
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

                // Save resume position regardless of role
                bl.UpsertWatchProgress(
                    vid, sessionId, userId, societyId, instituteId,
                    watchedSec, totalSec, pct, watchedSec);

                // Only track view for students (RoleId = 4)
                if (roleId == 4)
                    bl.TrackStudentView(vid, sessionId, userId, societyId, instituteId);

                return pct >= 100 ? "completed" : "ok";
            }
            catch { return "error"; }
        }

        // ═════════════════════════════════════════════════════════════════════
        //  SESSION HELPERS
        // ═════════════════════════════════════════════════════════════════════
        private static int GetSess(string key)
        {
            var v = HttpContext.Current.Session[key];
            return v != null && int.TryParse(v.ToString(), out int r) ? r : 0;
        }

        /// <summary>
        /// Tries multiple session key names; handles BasePage differences between
        /// Admin ("SessionId") and Teacher ("CurrentSessionId" / "AcademicSessionId").
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

        // ═════════════════════════════════════════════════════════════════════
        //  HELPERS
        // ═════════════════════════════════════════════════════════════════════
        private string GetTeacherDisplayName()
        {
            try
            {
                DataRow r = _bl.GetUserDisplayName(UserId);
                return r?["FullName"]?.ToString() ?? "Teacher";
            }
            catch { return "Teacher"; }
        }

        private void ShowMsg(string msg, string type)
        {
            lblMsg.Text = msg;
            lblMsg.CssClass = $"alert alert-{type} alert-box";
            lblMsg.Visible = true;
        }
    }
}