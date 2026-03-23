using System;
using System.Data;
using System.IO;
using System.Web.UI.WebControls;

namespace LearningManagementSystem.Admin
{
    public partial class VideoPlayer : System.Web.UI.Page
    {
        VideoPlayerBL bl = new VideoPlayerBL();

        int VideoId
        {
            get
            {
                if (Request.QueryString["VideoId"] != null)
                    return Convert.ToInt32(Request.QueryString["VideoId"]);
                return 0;
            }
        }

        public int NextVideoId = 0;
       
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                NextVideoId = bl.GetNextVideo(VideoId);
                hfVideoId.Value = VideoId.ToString();
                LoadVideo();
                LoadStats();
                LoadComments();
                LoadPlaylist();
                LoadEngagement();
                LoadTopics();
            }
        }

        void LoadVideo()
        {
            DataTable dt = bl.GetVideoDetails(VideoId);

            if (dt.Rows.Count > 0)
            {
                var row = dt.Rows[0];

                lblVideoTitle.InnerText = row["Title"].ToString();

                string path = row["VideoPath"].ToString();
                string virtualPath = path.Replace("..", "~");
                string resolvedUrl = ResolveUrl(virtualPath);

                videoPlayer.Attributes["src"] = resolvedUrl.Replace("#", "%23");

                bl.IncreaseViewCount(VideoId);
            }
        }

        void LoadStats()
        {
            var dt = bl.GetVideoStats(VideoId);

            if (dt.Rows.Count > 0)
            {
                lblViews.InnerText = dt.Rows[0]["Views"].ToString();
                lblStudents.InnerText = dt.Rows[0]["Students"].ToString();
                lblCompletion.InnerText = dt.Rows[0]["Completion"].ToString() + "%";
                lblComments.InnerText = dt.Rows[0]["Comments"].ToString();
            }
        }

        void LoadComments()
        {
            rptComments.DataSource = bl.GetComments(VideoId);
            rptComments.DataBind();
        }

        void LoadPlaylist()
        {
            rptPlaylist.DataSource = bl.GetPlaylist(VideoId);
            rptPlaylist.DataBind();
        }

        void LoadTopics()
        {
            rptTopics.DataSource = bl.GetVideoTopics(VideoId);
            rptTopics.DataBind();
        }

        void LoadEngagement()
        {
            DataTable dt = bl.GetEngagement(VideoId);
            string html = "";

            foreach (DataRow r in dt.Rows)
            {
                html += "<tr>";
                html += "<td>" + r["UserName"] + "</td>";
                html += "<td>" + r["WatchedPercent"] + "%</td>";
                html += "<td>" + (Convert.ToInt32(r["WatchedPercent"]) > 90 ? "Complete" : "Watching") + "</td>";
                html += "</tr>";
            }

            engagementBody.InnerHtml = html;
        }

        protected void DeleteComment(object sender, CommandEventArgs e)
        {
            int id = Convert.ToInt32(e.CommandArgument);
            bl.DeleteComment(id);
            LoadComments();
        }

        protected void btnNext_Click(object sender, EventArgs e)
        {
            Response.Redirect("VideoPlayer.aspx?VideoId=" + bl.GetNextVideo(VideoId));
        }

        protected void btnPrev_Click(object sender, EventArgs e)
        {
            Response.Redirect("VideoPlayer.aspx?VideoId=" + bl.GetPrevVideo(VideoId));
        }
    }
}