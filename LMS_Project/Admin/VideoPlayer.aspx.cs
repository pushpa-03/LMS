using System;
using System.Data;
using System.IO;

namespace LearningManagementSystem.Admin
{
    public partial class VideoPlayer : System.Web.UI.Page
    {
        VideoPlayerBL bl = new VideoPlayerBL();

        int UserId => Convert.ToInt32(Session["UserId"]);

        int VideoId
        {
            get
            {
                if (Request.QueryString["VideoId"] != null)
                    return Convert.ToInt32(Request.QueryString["VideoId"]);

                return 0;
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["InstituteId"] == null)
            {
                Response.Redirect("~/Default.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadVideo();
                LoadNotes();
            }
        }

        void LoadVideo()
        {
            // Inside LoadVideo method, add a null check for UserRole
            if (Session["Role"] != null && (Session["Role"].ToString() == "Admin" || Session["Role"].ToString() == "Teacher"))
            {
                liEngagement.Visible = true;
                LoadEngagementMeter();
            }
            else
            {
                liEngagement.Visible = false;
            }
            hfVideoId.Value = VideoId.ToString();

            DataTable dt = bl.GetVideoDetails(VideoId);
            if (dt != null && dt.Rows.Count > 0)
            {
                var row = dt.Rows[0];

                // Update UI Labels
                lblVideoTitle.InnerText = row["Title"].ToString();
                lblInstructorTop.InnerText = row["InstructorName"].ToString();
                lblInstructorName.InnerText = row["InstructorName"].ToString();
                lblDescription.InnerText = row["Description"].ToString();

                // --- VIDEO PATH FIX ---
                string path = row["VideoPath"].ToString();
                hfVideoName.Value = Path.GetFileName(path);

                string virtualPath = path.Replace("..", "~");
                string resolvedUrl = ResolveUrl(virtualPath);

                // This replaces the '#' in "C#" or spaces that cause "File Not Found" errors
                videoPlayerControl.Attributes["src"] = resolvedUrl.Replace("#", "%23");
                // ----------------------

                // Load Engagement if User is Admin/Teacher (Check both 'Role' and 'RoleName' depending on your Session key)
                var userRole = Session["Role"] != null ? Session["Role"].ToString() : "";
                if (userRole == "Admin" || userRole == "Teacher")
                {
                    liEngagement.Visible = true;
                    LoadEngagementMeter();
                }
                else
                {
                    liEngagement.Visible = false;
                }

                LoadTopics();
                bl.IncreaseViewCount(VideoId); // Keep the view counter active
            }
        }

        void LoadTopics()
        {
            rptTopics.DataSource = bl.GetVideoTopics(VideoId); // Need to add this in BL
            rptTopics.DataBind();
        }

        void LoadEngagementMeter()
        {
            DataTable dt = bl.GetEngagement(VideoId); // Get from VideoWatchProgress table
            string html = "";
            foreach (DataRow r in dt.Rows)
            {
                html += $"<tr><td>{r["UserName"]}</td><td>{r["WatchedPercent"]}%</td><td>{(Convert.ToInt32(r["WatchedPercent"]) > 90 ? "✅ Complete" : "⏳ Watching")}</td></tr>";
            }
            engagementBody.InnerHtml = html;
        }

        void LoadNotes()
        {
            rptNotes.DataSource = bl.GetNotes(VideoId, UserId);
            rptNotes.DataBind();
        }

        protected void btnSaveNote_Click(object sender, EventArgs e)
        {
            int seconds = Convert.ToInt32(hfTime.Value);

            bl.SaveNote(VideoId, UserId, txtNote.Text, seconds);

            txtNote.Text = "";

            LoadNotes();
        }

        protected void btnDoubt_Click(object sender, EventArgs e)
        {
            int seconds = Convert.ToInt32(hfTime.Value);

            bl.SaveDoubt(VideoId, UserId, txtDoubt.Text, seconds);

            txtDoubt.Text = "";
        }

        protected void btnComment_Click(object sender, EventArgs e)
        {
            bl.SaveComment(VideoId, UserId, txtComment.Text);

            txtComment.Text = "";
        }
    }
}