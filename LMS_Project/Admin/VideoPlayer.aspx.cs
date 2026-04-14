//using System;
//using System.Data;
//using System.IO;
//using System.Web.UI.WebControls;

//namespace LearningManagementSystem.Admin
//{
//    public partial class VideoPlayer : System.Web.UI.Page
//    {
//        VideoPlayerBL bl = new VideoPlayerBL();

//        int VideoId
//        {
//            get
//            {
//                if (Request.QueryString["VideoId"] != null)
//                    return Convert.ToInt32(Request.QueryString["VideoId"]);
//                return 0;
//            }
//        }

//        public int NextVideoId = 0;

//        protected void Page_Load(object sender, EventArgs e)
//        {
//            if (!IsPostBack)
//            {
//                NextVideoId = bl.GetNextVideo(VideoId);
//                hfVideoId.Value = VideoId.ToString();
//                LoadVideo();
//                LoadStats();
//                LoadComments();
//                LoadPlaylist();
//                LoadEngagement();
//                LoadTopics();
//            }
//        }

//        void LoadVideo()
//        {
//            DataTable dt = bl.GetVideoDetails(VideoId);

//            if (dt.Rows.Count > 0)
//            {
//                var row = dt.Rows[0];

//                lblVideoTitle.InnerText = row["Title"].ToString();

//                string path = row["VideoPath"].ToString();
//                string virtualPath = path.Replace("..", "~");
//                string resolvedUrl = ResolveUrl(virtualPath);




//                videoPlayer.Attributes["src"] = resolvedUrl.Replace("#", "%23");

//                bl.IncreaseViewCount(VideoId);
//            }
//        }

//        void LoadStats()
//        {
//            var dt = bl.GetVideoStats(VideoId);

//            if (dt.Rows.Count > 0)
//            {
//                lblViews.InnerText = dt.Rows[0]["Views"].ToString();
//                lblStudents.InnerText = dt.Rows[0]["Students"].ToString();
//                lblCompletion.InnerText = dt.Rows[0]["Completion"].ToString() + "%";
//                lblComments.InnerText = dt.Rows[0]["Comments"].ToString();
//            }
//        }

//        void LoadComments()
//        {
//            rptComments.DataSource = bl.GetComments(VideoId);
//            rptComments.DataBind();
//        }

//        void LoadPlaylist()
//        {
//            rptPlaylist.DataSource = bl.GetPlaylist(VideoId);
//            rptPlaylist.DataBind();
//        }

//        void LoadTopics()
//        {
//            rptTopics.DataSource = bl.GetVideoTopics(VideoId);
//            rptTopics.DataBind();
//        }

//        void LoadEngagement()
//        {
//            DataTable dt = bl.GetEngagement(VideoId);
//            string html = "";

//            foreach (DataRow r in dt.Rows)
//            {
//                html += "<tr>";
//                html += "<td>" + r["UserName"] + "</td>";
//                html += "<td>" + r["WatchedPercent"] + "%</td>";
//                html += "<td>" + (Convert.ToInt32(r["WatchedPercent"]) > 90 ? "Complete" : "Watching") + "</td>";
//                html += "</tr>";
//            }

//            engagementBody.InnerHtml = html;
//        }

//        protected void DeleteComment(object sender, CommandEventArgs e)
//        {
//            int id = Convert.ToInt32(e.CommandArgument);
//            bl.DeleteComment(id);
//            LoadComments();
//        }

//        protected void btnNext_Click(object sender, EventArgs e)
//        {
//            Response.Redirect("VideoPlayer.aspx?VideoId=" + bl.GetNextVideo(VideoId));
//        }

//        protected void btnPrev_Click(object sender, EventArgs e)
//        {
//            Response.Redirect("VideoPlayer.aspx?VideoId=" + bl.GetPrevVideo(VideoId));
//        }
//    }
//}

//-------------------------------------------------------------------------------------------------------------------

using System;
using System.Data;
using System.Web.Services;
using Newtonsoft.Json;

namespace LearningManagementSystem.Admin
{
    public partial class VideoPlayer : BasePage
    {
        VideoPlayerBL bl = new VideoPlayerBL();


        public int VideoId => Request.QueryString["VideoId"] != null ? Convert.ToInt32(Request.QueryString["VideoId"]) : 0;

        protected void Page_Load(object sender, EventArgs e)
        {
            
            try
            {
                if (!IsPostBack)
                {
                    if (SessionId == 0) return;

                    LoadVideoData();
                    LoadEngagement();
                    LoadTopics();
                }
            }
            catch (Exception ex)
            {
                // Log the error (optional)
                // Response.Write("Something went wrong. Please try again later.");
                lblVideoTitle.InnerText = "Video Not Found";
                // Optionally redirect to an error page: Response.Redirect("Error.aspx");
            }
        }

        private void LoadVideoData()
        {
            try
            {
                DataTable dt = bl.GetVideoDetails(VideoId,SessionId);
                if (dt.Rows != null && dt.Rows.Count > 0)
                {
                    var row = dt.Rows[0];
                    lblVideoTitle.InnerText = row["Title"].ToString();
                    lblDesc.InnerText = row["Description"].ToString();
                    lblUploadDate.InnerText = Convert.ToDateTime(row["UploadedOn"]).ToString("MMM dd, yyyy");

                    string path = row["VideoPath"].ToString().Replace("..", "~");
                    videoPlayer.Attributes["src"] = ResolveUrl(path).Replace("#", "%23");

                    // RATING LOGIC (Dynamic)
                    double avgRating = bl.GetAverageRating(VideoId); // You need to add this to BL
                    string starsHtml = "";
                    for (int i = 1; i <= 5; i++)
                    {
                        starsHtml += i <= avgRating ? "<i class='fas fa-star star-active'></i>" : "<i class='fas fa-star star-inactive'></i>";
                    }
                    dynamicRating.InnerHtml = starsHtml + $" <span class='ms-1'>{avgRating:F1} Rating</span>";

                    // SYNCED PLAYLIST LOGIC
                    int nextId = bl.GetNextVideo(VideoId,SessionId);
                    int prevId = bl.GetPrevVideo(VideoId,SessionId);

                    // Hide buttons if same as current (meaning no further videos)
                    btnNext.Visible = (nextId != VideoId);
                    btnPrev.Visible = (prevId != VideoId);

                    rptPlaylist.DataSource = bl.GetPlaylist(VideoId,SessionId);
                    rptPlaylist.DataBind();

                    // Stats
                    var stats = bl.GetVideoStats(VideoId,SessionId);
                    if (stats.Rows.Count > 0)
                    {
                        liveViews.InnerText = stats.Rows[0]["Views"].ToString();
                        lblCommentsCount.InnerText = stats.Rows[0]["Comments"].ToString();
                        string progress = stats.Rows[0]["Completion"].ToString();
                        progressText.InnerText = progress + "%";
                        progressBar.Style["width"] = progress + "%";
                    }
                }
                else
                {
                    lblVideoTitle.InnerText = "Select a video to play";
                    btnNext.Visible = false;
                    btnPrev.Visible = false;
                }
            }
            catch (Exception)
            {
                // Silently fail or show a default message
            }
        }

        void LoadTopics()
        {
            rptTopics.DataSource = bl.GetVideoTopics(VideoId,SessionId);
            rptTopics.DataBind();
        }
        private void LoadEngagement()
        {
            DataTable dt = bl.GetEngagement(VideoId,SessionId);
            string html = "<table class='table table-borderless small'><thead><tr class='text-muted'><th>Student</th><th>Progress</th></tr></thead><tbody>";
            foreach (DataRow r in dt.Rows)
            {
                html += $"<tr><td>{r["UserName"]}</td><td><span class='badge bg-soft-primary text-primary'>{r["WatchedPercent"]}%</span></td></tr>";
            }
            html += "</tbody></table>";
            engagementLive.InnerHtml = html;
        }

        // AJAX METHODS FOR LIVE UPDATE
        [WebMethod]
        public static string GetComments(int vid,int SessionId)
        {
            VideoPlayerBL bl = new VideoPlayerBL();
            return JsonConvert.SerializeObject(bl.GetComments(vid, SessionId));
        }

        [WebMethod]
        public static void AddComment(int vid, int SessionId, string msg)
        {
            VideoPlayerBL bl = new VideoPlayerBL();
            // Assuming current admin ID is 1 for this context
            bl.SaveComment(vid,SessionId, 1, msg);
        }

        protected void btnNext_Click(object sender, EventArgs e) => Response.Redirect("VideoPlayer.aspx?VideoId=" + bl.GetNextVideo(VideoId,SessionId));
        protected void btnPrev_Click(object sender, EventArgs e) => Response.Redirect("VideoPlayer.aspx?VideoId=" + bl.GetPrevVideo(VideoId,SessionId));
    }
}