using LearningManagementSystem.Admin;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace LMS_Project.Teacher
{
    public partial class TeacherVideoPlayer : BasePage
    {
        VideoPlayerBL bl = new VideoPlayerBL();


        public int VideoId => Request.QueryString["VideoId"] != null ? Convert.ToInt32(Request.QueryString["VideoId"]) : 0;

        protected void Page_Load(object sender, EventArgs e)
        {
            hfVideoId.Value = VideoId.ToString();

            try
            {
                if (!IsPostBack)
                {
                    if (SessionId == 0) return;

                    LoadVideoData();
                    LoadEngagement();
                    LoadTopics();
                    LoadComments();
                    LoadPlaylist();
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


        void LoadComments()
        {
            rptComments.DataSource = bl.GetComments(VideoId, SessionId);
            rptComments.DataBind();
        }

        protected void DeleteComment(object sender, CommandEventArgs e)
        {
            int id = Convert.ToInt32(e.CommandArgument);
            bl.DeleteComment(id, SessionId);
            LoadComments();
        }

        void LoadPlaylist()
        {
            rptPlaylist.DataSource = bl.GetPlaylist(VideoId, SessionId);
            rptPlaylist.DataBind();
        }

        private void LoadVideoData()
        {
            try
            {
                DataTable dt = bl.GetVideoDetails(VideoId, SessionId);
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
                    int nextId = bl.GetNextVideo(VideoId, SessionId);
                    int prevId = bl.GetPrevVideo(VideoId, SessionId);

                    // Hide buttons if same as current (meaning no further videos)
                    btnNext.Visible = (nextId != VideoId);
                    btnPrev.Visible = (prevId != VideoId);

                    rptPlaylist.DataSource = bl.GetPlaylist(VideoId, SessionId);
                    rptPlaylist.DataBind();

                    // Stats
                    var stats = bl.GetVideoStats(VideoId, SessionId);
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
            rptTopics.DataSource = bl.GetVideoTopics(VideoId, SessionId);
            rptTopics.DataBind();
        }
        private void LoadEngagement()
        {
            DataTable dt = bl.GetEngagement(VideoId, SessionId);
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
        public static void AddComment(int vid, string msg)
        {
            if (vid <= 0)
                throw new Exception("Invalid VideoId");

            VideoPlayerBL bl = new VideoPlayerBL();

            int sessionId = Convert.ToInt32(HttpContext.Current.Session["CurrentSessionId"]);
            int userId = Convert.ToInt32(HttpContext.Current.Session["UserId"]);
            int societyId = Convert.ToInt32(HttpContext.Current.Session["SocietyId"]);
            int instituteId = Convert.ToInt32(HttpContext.Current.Session["InstituteId"]);

            bl.SaveComment(vid, sessionId, userId, msg, societyId, instituteId);
        }

        [WebMethod]
        public static string GetComments(int vid)
        {
            VideoPlayerBL bl = new VideoPlayerBL();

            int sessionId = Convert.ToInt32(HttpContext.Current.Session["CurrentSessionId"]);

            return JsonConvert.SerializeObject(bl.GetComments(vid, sessionId));
        }


        protected void btnNext_Click(object sender, EventArgs e) => Response.Redirect("TeacherVideoPlayer.aspx?VideoId=" + bl.GetNextVideo(VideoId, SessionId));
        protected void btnPrev_Click(object sender, EventArgs e) => Response.Redirect("TeacherVideoPlayer.aspx?VideoId=" + bl.GetPrevVideo(VideoId, SessionId));
    }
}