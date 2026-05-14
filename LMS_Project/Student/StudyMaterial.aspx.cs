//using System;
//using System.Data;
//using System.Security.Cryptography;
//using System.Web;
//using System.Web.Services;
//using System.Web.UI;
//using System.Web.UI.WebControls;

//namespace LMS_Project.Student
//{
//    public partial class StudyMaterial : BasePage
//    {
//        SubjectDetailsBL bl = new SubjectDetailsBL();
//        StudentSubjectsBL subjectsBL = new StudentSubjectsBL();

//        private int _userId;
//        private int _instituteId;
//        private int _sessionId;

//        protected void Page_Load(object sender, EventArgs e)
//        {
//            _userId = UserId;
//            _instituteId = InstituteId;
//            _sessionId = SessionId;

//            if (!IsPostBack)
//            {
//                // ── Must have SubjectId in querystring ───────────────
//                if (Request.QueryString["SubjectId"] == null)
//                {
//                    pnlNoSubject.Visible = true;
//                    pnlContent.Visible = false;
//                    return;
//                }

//                int subjectId = Convert.ToInt32(Request.QueryString["SubjectId"]);
//                hfSubjectId.Value = subjectId.ToString();

//                // ── Verify student is enrolled in this subject ───────
//                if (!IsEnrolled(subjectId))
//                {
//                    pnlNoSubject.Visible = true;
//                    pnlContent.Visible = false;
//                    return;
//                }

//                pnlNoSubject.Visible = false;
//                pnlContent.Visible = true;

//                LoadSubjectInfo(subjectId);
//                LoadChapters(subjectId);
//            }
//            else
//            {
//                // ── UpdatePanel postback — load topics for selected video ──
//                if (hfVideoId.Value != "0" && !string.IsNullOrEmpty(hfVideoId.Value))
//                {
//                    LoadTopics(Convert.ToInt32(hfVideoId.Value));
//                }
//            }
//        }

//        // ============================================================
//        // Subject info strip
//        // ============================================================
//        private void LoadSubjectInfo(int subjectId)
//        {
//            DataTable dt = subjectsBL.GetSubjectById(subjectId, _instituteId, _sessionId);

//            if (dt == null || dt.Rows.Count == 0) return;

//            DataRow r = dt.Rows[0];

//            lblSubjectName.Text = r["SubjectName"].ToString();
//            lblSubjectCodeBadge.Text = r["SubjectCode"].ToString();
//            lblSubjectDesc.Text = r["Description"]?.ToString();
//            lblTeacherName.Text = r["TeacherName"].ToString();
//            lblDuration.Text = r["Duration"].ToString();

//            // Chapter count
//            DataTable dtChapters = bl.GetChapters(subjectId,SessionId);
//            lblChapterCount.Text = dtChapters.Rows.Count.ToString();
//        }

//        // ============================================================
//        // Chapter accordion + nested videos/materials
//        // ============================================================
//        private void LoadChapters(int subjectId)
//        {
//            DataTable dt = bl.GetChapters(subjectId,SessionId);

//            if (dt == null || dt.Rows.Count == 0)
//            {
//                pnlNoChapters.Visible = true;
//                rptChapters.Visible = false;
//                return;
//            }

//            pnlNoChapters.Visible = false;
//            rptChapters.Visible = true;

//            rptChapters.DataSource = dt;
//            rptChapters.DataBind();
//        }

//        // ============================================================
//        // Bind videos + materials inside each chapter row
//        // ============================================================
//        protected void rptChapters_ItemDataBound(object sender, RepeaterItemEventArgs e)
//        {
//            if (e.Item.ItemType != ListItemType.Item &&
//                e.Item.ItemType != ListItemType.AlternatingItem)
//                return;

//            HiddenField hfChapterId = (HiddenField)e.Item.FindControl("hfChapterId");
//            Repeater rptVideos = (Repeater)e.Item.FindControl("rptVideos");
//            Repeater rptMaterials = (Repeater)e.Item.FindControl("rptMaterials");

//            int chapterId = Convert.ToInt32(hfChapterId.Value);

//            rptVideos.DataSource = bl.GetVideosByChapter(chapterId,SessionId);
//            rptVideos.DataBind();

//            rptMaterials.DataSource = bl.GetMaterialsByChapter(chapterId,SessionId);
//            rptMaterials.DataBind();
//        }

//        // ============================================================
//        // Load topics for selected video (UpdatePanel postback)
//        // ============================================================
//        private void LoadTopics(int videoId)
//        {
//            DataLayer dl = new DataLayer();
//            System.Data.SqlClient.SqlCommand cmd =
//                new System.Data.SqlClient.SqlCommand(@"
//                SELECT StartTime, TopicTitle
//                FROM VideoTopics
//                WHERE VideoId = @VideoId
//                ORDER BY StartTime");

//            cmd.Parameters.AddWithValue("@VideoId", videoId);

//            rptTopics.DataSource = dl.GetDataTable(cmd);
//            rptTopics.DataBind();
//        }

//        // ============================================================
//        // Enrollment check — student must own this subject
//        // ============================================================
//        private bool IsEnrolled(int subjectId)
//        {
//            DataLayer dl = new DataLayer();
//            System.Data.SqlClient.SqlCommand cmd =
//                new System.Data.SqlClient.SqlCommand(@"
//                SELECT COUNT(*) FROM AssignStudentSubject
//                WHERE UserId      = @UserId
//                  AND SubjectId   = @SubjectId
//                  AND InstituteId = @InstId AND SessionId = @SessionId");

//            cmd.Parameters.AddWithValue("@UserId", _userId);
//            cmd.Parameters.AddWithValue("@SubjectId", subjectId);
//            cmd.Parameters.AddWithValue("@InstId", _instituteId);
//            cmd.Parameters.AddWithValue("@SessionId", SessionId);


//            DataTable dt = dl.GetDataTable(cmd);
//            if (dt == null || dt.Rows.Count == 0) return false;
//            return Convert.ToInt32(dt.Rows[0][0]) > 0;
//        }

//        [WebMethod]
//        public static void PostComment(int videoId,int SessionId, string comment)
//        {
//            VideoPlayerBL bl = new VideoPlayerBL();
//            int userId = Convert.ToInt32(HttpContext.Current.Session["UserId"]);
//            int societyId = Convert.ToInt32(HttpContext.Current.Session["SocietyId"]);
//            int instituteId = Convert.ToInt32(HttpContext.Current.Session["InstituteId"]);


//            bl.SaveCommentWithoutReply(videoId,SessionId, userId, comment, societyId, instituteId);
//        }

//        [WebMethod]
//        public static object GetComments(int videoId, int SessionId)
//        {
//            VideoPlayerBL bl = new VideoPlayerBL();
//            return bl.GetComments(videoId,SessionId);
//        }

//        //[WebMethod]
//        //public static void AddView(int videoId, int SessionId)
//        //{
//        //    VideoPlayerBL bl = new VideoPlayerBL();
//        //    bl.IncreaseViewCount(videoId,SessionId); 
//        //}

//        [WebMethod]
//        public static void AddView(int videoId)
//        {
//            if (HttpContext.Current.Session["UserId"] == null)
//                return;

//            VideoPlayerBL bl = new VideoPlayerBL();

//            int userId = Convert.ToInt32(HttpContext.Current.Session["UserId"]);
//            int sessionId = Convert.ToInt32(HttpContext.Current.Session["SessionId"]);
//            int instituteId = Convert.ToInt32(HttpContext.Current.Session["InstituteId"]);
//            int SocietyId = Convert.ToInt32(HttpContext.Current.Session["SocietyId"]);

//            bl.TrackStudentView(videoId, sessionId, userId, SocietyId, instituteId);
//        }

//        [WebMethod]
//        public static object GetStats(int videoId, int SessionId)
//        {
//            VideoPlayerBL bl = new VideoPlayerBL();
//            return bl.GetVideoStats(videoId,SessionId);
//        }

//        [WebMethod]
//        public static object GetPlaylist(int SessionId)
//        {
//            VideoPlayerBL bl = new VideoPlayerBL();
//            return bl.GetPlaylist(0,SessionId);
//        }
//    }
//}


//--------------------------------------------------------------------------------------------------------------------------------------


using System;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using Newtonsoft.Json;

namespace LMS_Project.Student
{
    public partial class StudyMaterial : BasePage
    {
        private readonly SubjectDetailsBL _sbl = new SubjectDetailsBL();
        private readonly StudentSubjectsBL _ssl = new StudentSubjectsBL();
        private readonly StudyMaterialBL _bl = new StudyMaterialBL();

        // ═══════════════════════════════════════════════════════════════════
        //  PAGE LOAD
        // ═══════════════════════════════════════════════════════════════════
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (!int.TryParse(Request.QueryString["SubjectId"], out int subjectId)
                    || subjectId == 0)
                {
                    pnlNoSubject.Visible = true;
                    pnlContent.Visible = false;
                    return;
                }

                if (!IsEnrolled(subjectId))
                {
                    pnlNoSubject.Visible = true;
                    pnlContent.Visible = false;
                    return;
                }

                pnlNoSubject.Visible = false;
                pnlContent.Visible = true;

                // ── Write session values into hidden fields for JS ──
                hfSubjectId.Value = subjectId.ToString();
                hfSessionId.Value = SessionId.ToString();
                hfUserId.Value = UserId.ToString();
                hfInstituteId.Value = InstituteId.ToString();
                hfSocietyId.Value = SocietyId.ToString();

                LoadSubjectInfo(subjectId);
                LoadChapters(subjectId);
            }
            else
            {
                // UpdatePanel async postback — MUST re-write hidden fields
                // because UpdatePanel re-renders ContentTemplate and the
                // hidden fields are inside pnlContent which may not re-render.
                // We write them unconditionally every postback.
                hfSessionId.Value = SessionId.ToString();
                hfUserId.Value = UserId.ToString();
                hfInstituteId.Value = InstituteId.ToString();
                hfSocietyId.Value = SocietyId.ToString();

                string tvid = hfTopicVideoId.Value;
                if (!string.IsNullOrEmpty(tvid) && tvid != "0")
                    LoadTopics(Convert.ToInt32(tvid));
            }
        }

        private void LoadSubjectInfo(int subjectId)
        {
            var dt = _ssl.GetSubjectById(subjectId, InstituteId, SessionId);
            if (dt == null || dt.Rows.Count == 0) return;
            var r = dt.Rows[0];
            lblSubjectName.Text = r["SubjectName"]?.ToString() ?? "";
            lblSubjectCodeBadge.Text = r["SubjectCode"]?.ToString() ?? "";
            lblSubjectDesc.Text = r["Description"]?.ToString() ?? "";
            lblTeacherName.Text = r["TeacherName"]?.ToString() ?? "Not Assigned";
            lblDuration.Text = r["Duration"]?.ToString() ?? "—";
            var dtC = _sbl.GetChapters(subjectId, SessionId);
            lblChapterCount.Text = (dtC?.Rows.Count ?? 0).ToString();
        }

        private void LoadChapters(int subjectId)
        {
            var dt = _sbl.GetChapters(subjectId, SessionId);
            if (dt == null || dt.Rows.Count == 0)
            {
                pnlNoChapters.Visible = true;
                rptChapters.Visible = false;
                return;
            }
            pnlNoChapters.Visible = false;
            rptChapters.Visible = true;
            rptChapters.DataSource = dt;
            rptChapters.DataBind();
        }

        protected void rptChapters_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item &&
                e.Item.ItemType != ListItemType.AlternatingItem) return;

            var hfCh = (HiddenField)e.Item.FindControl("hfChapterId");
            var rptVid = (Repeater)e.Item.FindControl("rptVideos");
            var rptMat = (Repeater)e.Item.FindControl("rptMaterials");
            if (hfCh == null) return;
            int chId = Convert.ToInt32(hfCh.Value);
            if (rptVid != null) { rptVid.DataSource = _sbl.GetVideosByChapter(chId, SessionId); rptVid.DataBind(); }
            if (rptMat != null) { rptMat.DataSource = _sbl.GetMaterialsByChapter(chId, SessionId); rptMat.DataBind(); }
        }

        private void LoadTopics(int videoId)
        {
            rptTopics.DataSource = _bl.GetVideoTopics(videoId);
            rptTopics.DataBind();
        }

        private bool IsEnrolled(int subjectId)
        {
            var cmd = new SqlCommand(@"
                SELECT COUNT(*) FROM AssignStudentSubject
                WHERE UserId=@U AND SubjectId=@S AND InstituteId=@I AND SessionId=@Sess");
            cmd.Parameters.AddWithValue("@U", UserId);
            cmd.Parameters.AddWithValue("@S", subjectId);
            cmd.Parameters.AddWithValue("@I", InstituteId);
            cmd.Parameters.AddWithValue("@Sess", SessionId);
            var dt = new DataLayer().GetDataTable(cmd);
            return dt != null && dt.Rows.Count > 0 && Convert.ToInt32(dt.Rows[0][0]) > 0;
        }

        // ═══════════════════════════════════════════════════════════════════
        //  WEB METHODS
        //
        //  CRITICAL RULE: Every method gets UserId + SessionId from the
        //  SERVER-SIDE ASP.NET Session object — NEVER from JS parameters.
        //  JS params are accepted in signatures only so JSON body parses OK.
        //  This ensures data persists correctly across logouts/logins.
        //
        //  All return string so ASP.NET does NOT double-serialize.
        //  JS receives { d: "JSON_STRING" } → unwrap .d → JSON.parse().
        // ═══════════════════════════════════════════════════════════════════

        [WebMethod(EnableSession = true)]
        public static string TrackView(int videoId, int sessionId)
        {
            try
            {
                int sess = Sess("CurrentSessionId");
                int uid = Sess("UserId");
                int soc = Sess("SocietyId");
                int inst = Sess("InstituteId");
                if (sess == 0 || uid == 0) return "err:no-session";
                new StudyMaterialBL().TrackView(videoId, sess, uid, soc, inst);
                return "ok";
            }
            catch (Exception ex) { return "err:" + ex.Message; }
        }

        [WebMethod(EnableSession = true)]
        public static string SaveProgress(
            int videoId, int sessionId, int position, int percentage, bool isCompleted)
        {
            try
            {
                int sess = Sess("CurrentSessionId");
                int uid = Sess("UserId");
                if (sess == 0 || uid == 0) return "err:no-session";
                new StudyMaterialBL().SaveWatchProgress(
                    videoId, sess, uid, position, percentage, isCompleted);
                return "ok";
            }
            catch (Exception ex) { return "err:" + ex.Message; }
        }

        [WebMethod(EnableSession = true)]
        public static string MarkComplete(int videoId, int sessionId)
        {
            try
            {
                int sess = Sess("CurrentSessionId");
                int uid = Sess("UserId");
                if (sess == 0 || uid == 0) return "err:no-session";
                new StudyMaterialBL().MarkVideoComplete(videoId, sess, uid);
                return "ok";
            }
            catch (Exception ex) { return "err:" + ex.Message; }
        }

        [WebMethod(EnableSession = true)]
        public static string GetVideoStatus(int videoId, int sessionId)
        {
            try
            {
                int sess = Sess("CurrentSessionId");
                int uid = Sess("UserId");
                if (sess == 0 || uid == 0)
                    return JsonConvert.SerializeObject(new { IsCompleted = false, LastPosition = 0, MaxPercentage = 0 });
                var d = new StudyMaterialBL().GetVideoStatus(videoId, sess, uid);
                return JsonConvert.SerializeObject(d);
            }
            catch
            {
                return JsonConvert.SerializeObject(new { IsCompleted = false, LastPosition = 0, MaxPercentage = 0 });
            }
        }

        [WebMethod(EnableSession = true)]
        public static string GetVideoStats(int videoId, int sessionId)
        {
            try
            {
                int sess = Sess("CurrentSessionId");
                return JsonConvert.SerializeObject(
                    new StudyMaterialBL().GetVideoStats(videoId, sess));
            }
            catch
            {
                return JsonConvert.SerializeObject(new { TotalViews = 0, UniqueStudents = 0 });
            }
        }

        [WebMethod(EnableSession = true)]
        public static string SaveRating(int videoId, int sessionId, int rating)
        {
            try
            {
                int sess = Sess("CurrentSessionId");
                int uid = Sess("UserId");
                if (sess == 0 || uid == 0) return "err:no-session";
                new StudyMaterialBL().SaveRating(videoId, sess, uid, rating);
                return "ok";
            }
            catch (Exception ex) { return "err:" + ex.Message; }
        }

        [WebMethod(EnableSession = true)]
        public static string GetRating(int videoId, int sessionId)
        {
            try
            {
                int sess = Sess("CurrentSessionId");
                int uid = Sess("UserId");
                return JsonConvert.SerializeObject(
                    new StudyMaterialBL().GetRating(videoId, sess, uid));
            }
            catch
            {
                return JsonConvert.SerializeObject(new { AvgRating = 0.0, TotalRatings = 0, MyRating = 0 });
            }
        }

        [WebMethod(EnableSession = true)]
        public static string GetProgress(int subjectId, int sessionId)
        {
            try
            {
                int sess = Sess("CurrentSessionId");
                int uid = Sess("UserId");
                if (sess == 0 || uid == 0)
                    return JsonConvert.SerializeObject(new
                    {
                        TotalCount = 0,
                        WatchedCount = 0,
                        TotalChapters = 0,
                        CompletedChapters = 0,
                        ChapterProgress = new object[0],
                        CompletedVideoIds = new int[0]
                    });
                return JsonConvert.SerializeObject(
                    new StudyMaterialBL().GetProgress(subjectId, sess, uid));
            }
            catch (Exception ex)
            {
                return JsonConvert.SerializeObject(new { error = ex.Message });
            }
        }

        [WebMethod(EnableSession = true)]
        public static string GetComments(int videoId, int sessionId)
        {
            try
            {
                int sess = Sess("CurrentSessionId");
                return JsonConvert.SerializeObject(
                    new StudyMaterialBL().GetComments(videoId, sess));
            }
            catch (Exception ex)
            {
                return JsonConvert.SerializeObject(new { error = ex.Message });
            }
        }

        [WebMethod(EnableSession = true)]
        public static string PostComment(
            int videoId, int sessionId, string commentText, int? parentId)
        {
            try
            {
                int sess = Sess("CurrentSessionId");
                int uid = Sess("UserId");
                int soc = Sess("SocietyId");
                int inst = Sess("InstituteId");
                if (sess == 0 || uid == 0) return "err:no-session";
                new StudyMaterialBL().PostComment(
                    videoId, sess, uid, soc, inst, commentText, parentId);
                return "ok";
            }
            catch (Exception ex) { return "err:" + ex.Message; }
        }

        [WebMethod(EnableSession = true)]
        public static string SaveAIHistory(
            int videoId, int sessionId, string question, string answer)
        {
            try
            {
                int sess = Sess("CurrentSessionId");
                int uid = Sess("UserId");
                if (sess == 0 || uid == 0) return "err:no-session";
                new StudyMaterialBL().SaveAIHistory(videoId, sess, uid, question, answer);
                return "ok";
            }
            catch (Exception ex) { return "err:" + ex.Message; }
        }

        [WebMethod(EnableSession = true)]
        public static string GetAIHistory(int videoId, int sessionId)
        {
            try
            {
                int sess = Sess("CurrentSessionId");
                int uid = Sess("UserId");
                if (sess == 0 || uid == 0)
                    return JsonConvert.SerializeObject(new object[0]);
                return JsonConvert.SerializeObject(
                    new StudyMaterialBL().GetAIHistory(videoId, sess, uid));
            }
            catch (Exception ex)
            {
                return JsonConvert.SerializeObject(new { error = ex.Message });
            }
        }

        [WebMethod(EnableSession = true)]
        public static string GetNotes(int videoId, int sessionId)
        {
            try
            {
                int sess = Sess("CurrentSessionId");
                int uid = Sess("UserId");
                if (sess == 0 || uid == 0)
                    return JsonConvert.SerializeObject(new { Content = "", UpdatedOn = "" });
                return JsonConvert.SerializeObject(
                    new StudyMaterialBL().GetNotes(videoId, sess, uid));
            }
            catch (Exception ex)
            {
                return JsonConvert.SerializeObject(new { error = ex.Message });
            }
        }

        [WebMethod(EnableSession = true)]
        public static string SaveNotes(int videoId, int sessionId, string content)
        {
            try
            {
                int sess = Sess("CurrentSessionId");
                int uid = Sess("UserId");
                if (sess == 0 || uid == 0) return "err:no-session";
                new StudyMaterialBL().SaveNotes(videoId, sess, uid, content);
                return "ok";
            }
            catch (Exception ex) { return "err:" + ex.Message; }
        }

        // ── Safe Session int reader ───────────────────────────────────────
        // Reads from SERVER Session only. Returns 0 if missing/null.
        private static int Sess(string key)
        {
            try
            {
                var v = HttpContext.Current?.Session?[key];
                return v == null ? 0 : Convert.ToInt32(v);
            }
            catch { return 0; }
        }
    }
}