//using Newtonsoft.Json;
//using System;
//using System.Data;
//using System.Web;
//using System.Web.Services;
//using System.Web.UI.WebControls;
//using System.Xml.Linq;

//namespace LearningManagementSystem.Admin
//{
//    public partial class VideoPlayer : BasePage
//    {
//        VideoPlayerBL bl = new VideoPlayerBL();


//        public int VideoId => Request.QueryString["VideoId"] != null ? Convert.ToInt32(Request.QueryString["VideoId"]) : 0;

//        protected void Page_Load(object sender, EventArgs e)
//        {

//            try
//            {
//                if (!IsPostBack)
//                {
//                    if (SessionId == 0) return;

//                    LoadVideoData();
//                    LoadEngagement();
//                    LoadTopics();
//                    LoadComments();
//                    LoadPlaylist();
//                }
//            }
//            catch (Exception ex)
//            {
//                // Log the error (optional)
//                // Response.Write("Something went wrong. Please try again later.");
//                lblVideoTitle.InnerText = "Video Not Found";
//                // Optionally redirect to an error page: Response.Redirect("Error.aspx");
//            }
//        }


//        void LoadComments()
//        {
//            rptComments.DataSource = bl.GetComments(VideoId, SessionId);
//            rptComments.DataBind();
//        }

//        protected void DeleteComment(object sender, CommandEventArgs e)
//        {
//            int id = Convert.ToInt32(e.CommandArgument);
//            bl.DeleteComment(id, SessionId);
//            LoadComments();
//        }

//        void LoadPlaylist()
//        {
//            rptPlaylist.DataSource = bl.GetPlaylist(VideoId, SessionId);
//            rptPlaylist.DataBind();
//        }

//        private void LoadVideoData()
//        {
//            try
//            {
//                DataTable dt = bl.GetVideoDetails(VideoId, SessionId);
//                if (dt.Rows != null && dt.Rows.Count > 0)
//                {
//                    var row = dt.Rows[0];
//                    lblVideoTitle.InnerText = row["Title"].ToString();
//                    lblDesc.InnerText = row["Description"].ToString();
//                    lblUploadDate.InnerText = Convert.ToDateTime(row["UploadedOn"]).ToString("MMM dd, yyyy");

//                    string path = row["VideoPath"].ToString().Replace("..", "~");
//                    videoPlayer.Attributes["src"] = ResolveUrl(path).Replace("#", "%23");

//                    // RATING LOGIC (Dynamic)
//                    double avgRating = bl.GetAverageRating(VideoId); // You need to add this to BL
//                    string starsHtml = "";
//                    for (int i = 1; i <= 5; i++)
//                    {
//                        starsHtml += i <= avgRating ? "<i class='fas fa-star star-active'></i>" : "<i class='fas fa-star star-inactive'></i>";
//                    }
//                    dynamicRating.InnerHtml = starsHtml + $" <span class='ms-1'>{avgRating:F1} Rating</span>";

//                    // SYNCED PLAYLIST LOGIC
//                    int nextId = bl.GetNextVideo(VideoId, SessionId);
//                    int prevId = bl.GetPrevVideo(VideoId, SessionId);

//                    // Hide buttons if same as current (meaning no further videos)
//                    btnNext.Visible = (nextId != VideoId);
//                    btnPrev.Visible = (prevId != VideoId);

//                    rptPlaylist.DataSource = bl.GetPlaylist(VideoId, SessionId);
//                    rptPlaylist.DataBind();

//                    // Stats
//                    var stats = bl.GetVideoStats(VideoId, SessionId);
//                    if (stats.Rows.Count > 0)
//                    {
//                        liveViews.InnerText = stats.Rows[0]["Views"].ToString();
//                        lblCommentsCount.InnerText = stats.Rows[0]["Comments"].ToString();
//                        string progress = stats.Rows[0]["Completion"].ToString();
//                        progressText.InnerText = progress + "%";
//                        progressBar.Style["width"] = progress + "%";
//                    }
//                }
//                else
//                {
//                    lblVideoTitle.InnerText = "Select a video to play";
//                    btnNext.Visible = false;
//                    btnPrev.Visible = false;
//                }
//            }
//            catch (Exception)
//            {
//                // Silently fail or show a default message
//            }
//        }

//        void LoadTopics()
//        {
//            rptTopics.DataSource = bl.GetVideoTopics(VideoId, SessionId);
//            rptTopics.DataBind();
//        }
//        private void LoadEngagement()
//        {
//            DataTable dt = bl.GetEngagement(VideoId, SessionId);
//            string html = "<table class='table table-borderless small'><thead><tr class='text-muted'><th>Student</th><th>Progress</th></tr></thead><tbody>";
//            foreach (DataRow r in dt.Rows)
//            {
//                html += $"<tr><td>{r["UserName"]}</td><td><span class='badge bg-soft-primary text-primary'>{r["WatchedPercent"]}%</span></td></tr>";
//            }
//            html += "</tbody></table>";
//            engagementLive.InnerHtml = html;
//        }

//        // AJAX METHODS FOR LIVE UPDATE
//        [WebMethod]
//        public static string GetComments(int vid, int SessionId)
//        {
//            VideoPlayerBL bl = new VideoPlayerBL();
//            return JsonConvert.SerializeObject(bl.GetComments(vid, SessionId));
//        }

//        [WebMethod]
//        public static void AddComment(int vid, int SessionId, string msg)
//        {
//            VideoPlayerBL bl = new VideoPlayerBL();

//            int userId = Convert.ToInt32(HttpContext.Current.Session["UserId"]);
//            int societyId = Convert.ToInt32(HttpContext.Current.Session["SocietyId"]);
//            int instituteId = Convert.ToInt32(HttpContext.Current.Session["InstituteId"]);

//            bl.SaveComment(vid, SessionId, userId, msg, societyId, instituteId);
//        }

//        protected void btnNext_Click(object sender, EventArgs e) => Response.Redirect("VideoPlayer.aspx?VideoId=" + bl.GetNextVideo(VideoId, SessionId));
//        protected void btnPrev_Click(object sender, EventArgs e) => Response.Redirect("VideoPlayer.aspx?VideoId=" + bl.GetPrevVideo(VideoId, SessionId));
//    }
//}


//-------------------------------------------------------------------------------------------------------------------

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
                lblUploadDate.InnerText = Convert.ToDateTime(r["UploadedOn"]).ToString("dd MMM yyyy");

            string path = r["VideoPath"]?.ToString() ?? "";
            if (!string.IsNullOrEmpty(path))
                videoPlayer.Attributes["src"] = ResolveUrl(path.Replace("~", "~").Replace("..", "~"));

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
                stars += i <= Math.Round(avg) ? "<i class='fa fa-star son'></i>" : "<i class='fa fa-star soff'></i>";
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
            // Views = unique STUDENT views only (admin/teacher roles excluded)
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

        // ═══════════ AJAX WEBMETHODS ═══════════════════════════════════════════

        /// <summary>
        /// Get all top-level comments with their replies and reply count.
        /// </summary>
        [WebMethod(EnableSession = true)]
        public static string GetComments(int vid)
        {
            try
            {
                int sessId = GetSess("SessionId");
                var bl = new VideoPlayerBL();
                DataTable dt = bl.GetComments(vid, sessId);
                var result = new System.Collections.Generic.List<object>();

                foreach (DataRow r in dt.Rows)
                {
                    int cmtId = Convert.ToInt32(r["CommentId"]);
                    // Load replies for this comment
                    DataTable rDt = bl.GetReplies(cmtId, sessId);
                    var replies = new System.Collections.Generic.List<object>();
                    foreach (DataRow rr in rDt.Rows)
                    {
                        replies.Add(new
                        {
                            CommentId = rr["CommentId"],
                            Username = rr["Username"]?.ToString() ?? "",
                            Comment = rr["Comment"]?.ToString() ?? "",
                            CommentedOn = rr["CommentedOn"] != DBNull.Value
                                ? Convert.ToDateTime(rr["CommentedOn"]).ToString("dd MMM yyyy, hh:mm tt") : ""
                        });
                    }
                    result.Add(new
                    {
                        CommentId = cmtId,
                        Username = r["Username"]?.ToString() ?? "",
                        Comment = r["Comment"]?.ToString() ?? "",
                        CommentedOn = r["CommentedOn"] != DBNull.Value
                            ? Convert.ToDateTime(r["CommentedOn"]).ToString("dd MMM yyyy, hh:mm tt") : "",
                        ReplyCount = replies.Count,
                        Replies = replies
                    });
                }
                return JsonConvert.SerializeObject(result);
            }
            catch { return "[]"; }
        }

        /// <summary>Post a top-level comment (any role: admin, teacher, student).</summary>
        [WebMethod(EnableSession = true)]
        public static void AddComment(int vid, string msg)
        {
            if (string.IsNullOrWhiteSpace(msg)) return;
            try
            {
                new VideoPlayerBL().SaveComment(vid, GetSess("SessionId"), GetSess("UserId"),
                    msg.Trim(), GetSess("SocietyId"), GetSess("InstituteId"), null);
            }
            catch { }
        }

        /// <summary>Post a reply to a comment (any role).</summary>
        [WebMethod(EnableSession = true)]
        public static void AddReply(int vid, int parentId, string msg)
        {
            if (string.IsNullOrWhiteSpace(msg)) return;
            try
            {
                new VideoPlayerBL().SaveComment(vid, GetSess("SessionId"), GetSess("UserId"),
                    msg.Trim(), GetSess("SocietyId"), GetSess("InstituteId"), parentId);
            }
            catch { }
        }

        /// <summary>Delete a comment (and cascades to replies via FK).</summary>
        [WebMethod(EnableSession = true)]
        public static void DeleteCommentAjax(int commentId)
        {
            try { new VideoPlayerBL().DeleteComment(commentId, GetSess("SessionId")); }
            catch { }
        }

        /// <summary>
        /// Save watch progress called every 10s from JS.
        /// Updates VideoWatchProgress; marks IsCompleted=1 when 100%.
        /// Student-only view counting is handled here too.
        /// </summary>
        [WebMethod(EnableSession = true)]
        public static string SaveProgress(int vid, int watchedSec, int totalSec)
        {
            try
            {
                if (totalSec <= 0) return "error";
                int userId = GetSess("UserId");
                int sessionId = GetSess("SessionId");
                int societyId = GetSess("SocietyId");
                int instituteId = GetSess("InstituteId");
                int roleId = GetSess("RoleId");

                int pct = (int)Math.Min(100, Math.Round((double)watchedSec / totalSec * 100));

                var bl = new VideoPlayerBL();
                bl.UpsertWatchProgress(vid, sessionId, userId, societyId, instituteId,
                    watchedSec, totalSec, pct, watchedSec);

                // Count view only for students (RoleId = 4 = Student)
                if (roleId == 4)
                    bl.TrackStudentView(vid, sessionId, userId, societyId, instituteId);

                return pct >= 100 ? "completed" : "ok";
            }
            catch { return "error"; }
        }

        // ── Session helpers ─────────────────────────────────────────────────────
        private static int GetSess(string key)
        {
            var v = HttpContext.Current.Session[key];
            return v != null && int.TryParse(v.ToString(), out int r) ? r : 0;
        }

        private void ShowMsg(string msg, string type)
        {
            lblMsg.Text = msg;
            lblMsg.CssClass = $"alert alert-{type} alert-box";
            lblMsg.Visible = true;
        }
    }
}