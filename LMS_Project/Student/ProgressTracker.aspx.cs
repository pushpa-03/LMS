using System;
using System.Collections.Generic;
using System.Data;
using System.Web.Services;
using Newtonsoft.Json;

namespace LMS_Project.Student
{
    public partial class ProgressTracker : BasePage
    {
        private readonly VideoPlayerBL _bl = new VideoPlayerBL();

        protected void Page_Load(object sender, EventArgs e)
        {
            try
            {
                if (UserId == 0 || SessionId == 0)
                {
                    Response.Redirect("~/Default.aspx");
                    return;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("ProgressTracker.Page_Load: " + ex);
            }
        }

        /// <summary>
        /// Returns subject-level progress: list of subjects with overall completion %
        /// </summary>
        [WebMethod(EnableSession = true)]
        public static string GetProgressData()
        {
            try
            {
                int userId = GetSessionInt("UserId");
                int sessionId = GetSessionInt("SessionId");

                if (userId == 0 || sessionId == 0)
                    return "[]";

                var bl = new VideoPlayerBL();
                DataTable dt = bl.GetSubjectProgress(userId, sessionId);
                var result = new List<object>();

                foreach (DataRow r in dt.Rows)
                {
                    result.Add(new
                    {
                        SubjectId = r["SubjectId"],
                        SubjectName = r["SubjectName"]?.ToString() ?? "",
                        CompletionPercent = r["CompletionPercent"] != DBNull.Value ? Convert.ToInt32(r["CompletionPercent"]) : 0,
                        TotalVideos = r["TotalVideos"] != DBNull.Value ? Convert.ToInt32(r["TotalVideos"]) : 0,
                        CompletedVideos = r["CompletedVideos"] != DBNull.Value ? Convert.ToInt32(r["CompletedVideos"]) : 0
                    });
                }

                return JsonConvert.SerializeObject(result);
            }
            catch
            {
                return "[]";
            }
        }

        /// <summary>
        /// Returns chapter-level progress for a given subject
        /// </summary>
        [WebMethod(EnableSession = true)]
        public static string GetChapterData(int subjectId)
        {
            try
            {
                int userId = GetSessionInt("UserId");
                int sessionId = GetSessionInt("SessionId");

                if (userId == 0 || sessionId == 0 || subjectId == 0)
                    return "[]";

                var bl = new VideoPlayerBL();
                DataTable dt = bl.GetChapterProgress(subjectId, userId, sessionId);
                var result = new List<object>();

                foreach (DataRow r in dt.Rows)
                {
                    result.Add(new
                    {
                        ChapterId = r["ChapterId"],
                        ChapterName = r["ChapterName"]?.ToString() ?? "",
                        CompletionPercent = r["CompletionPercent"] != DBNull.Value ? Convert.ToInt32(r["CompletionPercent"]) : 0,
                        TotalVideos = r["TotalVideos"] != DBNull.Value ? Convert.ToInt32(r["TotalVideos"]) : 0,
                        CompletedVideos = r["CompletedVideos"] != DBNull.Value ? Convert.ToInt32(r["CompletedVideos"]) : 0
                    });
                }

                return JsonConvert.SerializeObject(result);
            }
            catch
            {
                return "[]";
            }
        }

        /// <summary>
        /// Returns video-level progress for a given chapter
        /// </summary>
        [WebMethod(EnableSession = true)]
        public static string GetVideoData(int chapterId)
        {
            try
            {
                int userId = GetSessionInt("UserId");
                int sessionId = GetSessionInt("SessionId");

                if (userId == 0 || sessionId == 0 || chapterId == 0)
                    return "[]";

                var bl = new VideoPlayerBL();
                DataTable dt = bl.GetVideoProgressByChapter(chapterId, userId, sessionId);
                var result = new List<object>();

                foreach (DataRow r in dt.Rows)
                {
                    result.Add(new
                    {
                        VideoId = r["VideoId"],
                        Title = r["Title"]?.ToString() ?? "",
                        WatchedPercent = r["WatchedPercent"] != DBNull.Value ? Convert.ToInt32(r["WatchedPercent"]) : 0,
                        IsCompleted = r["IsCompleted"] != DBNull.Value ? Convert.ToInt32(r["IsCompleted"]) > 0 : false
                    });
                }

                return JsonConvert.SerializeObject(result);
            }
            catch
            {
                return "[]";
            }
        }

        /// <summary>
        /// Helper to get session value as int
        /// </summary>
        private static int GetSessionInt(string key)
        {
            try
            {
                var v = System.Web.HttpContext.Current.Session[key];
                if (v != null && int.TryParse(v.ToString(), out int result))
                    return result;
            }
            catch { }
            return 0;
        }
    }
}
