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
using System.Web.UI;
using Newtonsoft.Json;

namespace LearningManagementSystem.Admin
{
    public partial class VideoPlayer : BasePage
    {
        private readonly VideoPlayerBL _bl = new VideoPlayerBL();

        // ── VideoId from query string ─────────────────────────────────────────
        public int VideoId
        {
            get
            {
                return int.TryParse(Request.QueryString["VideoId"], out int id) && id > 0 ? id : 0;
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            try
            {
                if (VideoId == 0)
                {
                    ShowMsg("Invalid or missing Video ID.", "warning");
                    return;
                }

                if (!IsPostBack)
                {
                    if (SessionId == 0)
                    {
                        ShowMsg("No active academic session found.", "warning");
                        return;
                    }

                    hfVideoId.Value = VideoId.ToString();
                    hfAdminName.Value = GetAdminDisplayName();

                    LoadVideoData();
                    LoadTopics();
                    LoadPlaylist();
                    LoadEngagement();
                    LoadAIStats();
                    LoadVideoStats();
                    LoadRating();

                    // Track admin view
                    _bl.TrackView(VideoId, SessionId, UserId, InstituteId, SocietyId);
                    _bl.LogActivity(UserId, SocietyId, InstituteId, SessionId,
                        "VideoView", VideoId);
                }
            }
            catch (Exception ex)
            {
                ShowMsg("Error loading video: " + ex.Message, "danger");
            }
        }

        // ── Load core video data ──────────────────────────────────────────────
        private void LoadVideoData()
        {
            DataTable dt = _bl.GetVideoDetails(VideoId, SessionId);

            if (dt == null || dt.Rows.Count == 0)
            {
                ShowMsg("Video not found or has been deactivated.", "warning");
                btnNext.Visible = false;
                btnPrev.Visible = false;
                return;
            }

            DataRow r = dt.Rows[0];

            pageTitle.InnerText = r["Title"]?.ToString() ?? "Video Player";
            lblVideoTitle.InnerText = r["Title"]?.ToString() ?? "—";
            lblDesc.InnerText = r["Description"]?.ToString() ?? "";
            lblInstructor.InnerText = r["InstructorName"]?.ToString() ?? "Unknown";
            liveViews.InnerText = r["ViewCount"]?.ToString() ?? "0";

            if (r["UploadedOn"] != DBNull.Value)
                lblUploadDate.InnerText = Convert.ToDateTime(r["UploadedOn"]).ToString("dd MMM yyyy");

            // Video source
            string path = r["VideoPath"]?.ToString() ?? "";
            if (!string.IsNullOrEmpty(path))
            {
                string resolved = ResolveUrl(path.Replace("~", "~").Replace("..", "~"));
                videoPlayer.Attributes["src"] = resolved;
            }

            // Prev / Next navigation
            int nextId = _bl.GetNextVideo(VideoId, SessionId);
            int prevId = _bl.GetPrevVideo(VideoId, SessionId);
            btnNext.Visible = (nextId > 0 && nextId != VideoId);
            btnPrev.Visible = (prevId > 0 && prevId != VideoId);
        }

        // ── Rating ────────────────────────────────────────────────────────────
        private void LoadRating()
        {
            DataRow rating = _bl.GetRatingSummary(VideoId);

            if (rating == null) { avgRatingVal.InnerText = "N/A"; return; }

            double avg = rating["AvgRating"] != DBNull.Value ? Convert.ToDouble(rating["AvgRating"]) : 0;
            int count = rating["RatingCount"] != DBNull.Value ? Convert.ToInt32(rating["RatingCount"]) : 0;

            avgRatingVal.InnerText = avg > 0 ? avg.ToString("F1") : "N/A";
            ratingCount.InnerText = count + " rating" + (count != 1 ? "s" : "");

            // Stars HTML
            string stars = "";
            for (int i = 1; i <= 5; i++)
                stars += i <= Math.Round(avg)
                    ? "<i class='fa fa-star star-filled'></i>"
                    : "<i class='fa fa-star star-empty'></i>";
            ratingStars.InnerHtml = stars;
        }

        // ── Topics ────────────────────────────────────────────────────────────
        private void LoadTopics()
        {
            rptTopics.DataSource = _bl.GetVideoTopics(VideoId, SessionId);
            rptTopics.DataBind();
        }

        // ── Playlist ──────────────────────────────────────────────────────────
        private void LoadPlaylist()
        {
            rptPlaylist.DataSource = _bl.GetPlaylist(VideoId, SessionId);
            rptPlaylist.DataBind();
        }

        // ── Student engagement ────────────────────────────────────────────────
        private void LoadEngagement()
        {
            rptEngagement.DataSource = _bl.GetEngagement(VideoId, SessionId);
            rptEngagement.DataBind();
        }

        // ── AI usage stats ────────────────────────────────────────────────────
        private void LoadAIStats()
        {
            rptAIStats.DataSource = _bl.GetAIUsageStats(VideoId);
            rptAIStats.DataBind();
        }

        // ── Video stats (views, students, completion, comments) ───────────────
        private void LoadVideoStats()
        {
            DataTable dt = _bl.GetVideoStats(VideoId, SessionId);
            if (dt == null || dt.Rows.Count == 0) return;

            DataRow r = dt.Rows[0];
            statViews.InnerText = r["Views"]?.ToString() ?? "0";
            statStudents.InnerText = r["Students"]?.ToString() ?? "0";
            statCompletion.InnerText = (r["Completion"]?.ToString() ?? "0") + "%";
            statComments.InnerText = r["Comments"]?.ToString() ?? "0";
        }

        // ── Navigation ────────────────────────────────────────────────────────
        protected void btnNext_Click(object sender, EventArgs e)
        {
            try
            {
                int next = _bl.GetNextVideo(VideoId, SessionId);
                if (next > 0 && next != VideoId)
                    Response.Redirect("VideoPlayer.aspx?VideoId=" + next);
            }
            catch (Exception ex) { ShowMsg("Navigation error: " + ex.Message, "danger"); }
        }

        protected void btnPrev_Click(object sender, EventArgs e)
        {
            try
            {
                int prev = _bl.GetPrevVideo(VideoId, SessionId);
                if (prev > 0 && prev != VideoId)
                    Response.Redirect("VideoPlayer.aspx?VideoId=" + prev);
            }
            catch (Exception ex) { ShowMsg("Navigation error: " + ex.Message, "danger"); }
        }

        // ── Server-side comment delete (postback) ─────────────────────────────
        protected void DeleteComment(object sender, System.Web.UI.WebControls.CommandEventArgs e)
        {
            try
            {
                int id = Convert.ToInt32(e.CommandArgument);
                _bl.DeleteComment(id, SessionId);
                ShowMsg("Comment deleted.", "success");
            }
            catch (Exception ex) { ShowMsg("Error: " + ex.Message, "danger"); }
        }

        // ═══════════════════════════════════════════════════════════════════════
        //  AJAX WEB METHODS
        // ═══════════════════════════════════════════════════════════════════════

        [WebMethod(EnableSession = true)]
        public static string GetComments(int vid)
        {
            try
            {
                int sessionId = GetSessionIdFromContext();
                VideoPlayerBL bl = new VideoPlayerBL();
                DataTable dt = bl.GetComments(vid, sessionId);

                var list = new System.Collections.Generic.List<object>();
                foreach (DataRow r in dt.Rows)
                {
                    string dateStr = r["CommentedOn"] != DBNull.Value
                        ? Convert.ToDateTime(r["CommentedOn"]).ToString("dd MMM yyyy, hh:mm tt")
                        : "";
                    list.Add(new
                    {
                        CommentId = r["CommentId"],
                        Username = r["Username"]?.ToString() ?? "User",
                        Comment = r["Comment"]?.ToString() ?? "",
                        CommentedOn = dateStr
                    });
                }
                return JsonConvert.SerializeObject(list);
            }
            catch { return "[]"; }
        }

        [WebMethod(EnableSession = true)]
        public static void AddComment(int vid, string msg)
        {
            if (string.IsNullOrWhiteSpace(msg)) return;
            try
            {
                int userId = GetUserIdFromContext();
                int sessionId = GetSessionIdFromContext();
                int societyId = GetIntSession("SocietyId");
                int instituteId = GetIntSession("InstituteId");

                VideoPlayerBL bl = new VideoPlayerBL();
                bl.SaveComment(vid, sessionId, userId, msg.Trim(), societyId, instituteId);
            }
            catch { /* Silently fail – client handles retry */ }
        }

        [WebMethod(EnableSession = true)]
        public static void DeleteCommentAjax(int commentId)
        {
            try
            {
                int sessionId = GetSessionIdFromContext();
                new VideoPlayerBL().DeleteComment(commentId, sessionId);
            }
            catch { }
        }

        [WebMethod(EnableSession = true)]
        public static string SaveWatchProgress(int vid, int watchedSeconds, int totalSeconds)
        {
            try
            {
                if (totalSeconds <= 0) return "error";
                int userId = GetUserIdFromContext();
                int sessionId = GetSessionIdFromContext();
                int societyId = GetIntSession("SocietyId");
                int instituteId = GetIntSession("InstituteId");

                int pct = (int)Math.Round((double)watchedSeconds / totalSeconds * 100);
                pct = Math.Min(pct, 100);

                new VideoPlayerBL().UpsertWatchProgress(
                    vid, sessionId, userId, societyId, instituteId,
                    watchedSeconds, totalSeconds, pct, watchedSeconds);

                return pct >= 100 ? "completed" : "ok";
            }
            catch { return "error"; }
        }

        // ── Context helpers ───────────────────────────────────────────────────
        private static int GetUserIdFromContext() =>
            GetIntSession("UserId");
        private static int GetSessionIdFromContext() =>
            GetIntSession("SessionId");
        private static int GetIntSession(string key)
        {
            var val = HttpContext.Current.Session[key];
            return val != null && int.TryParse(val.ToString(), out int r) ? r : 0;
        }

        private string GetAdminDisplayName()
        {
            try
            {
                DataRow r = _bl.GetUserDisplayName(UserId);
                return r?["FullName"]?.ToString() ?? "Admin";
            }
            catch { return "Admin"; }
        }

        private void ShowMsg(string msg, string type)
        {
            lblMsg.Text = msg;
            lblMsg.CssClass = $"alert alert-{type} alert-auto d-block mb-3";
            lblMsg.Visible = true;
        }
    }
}