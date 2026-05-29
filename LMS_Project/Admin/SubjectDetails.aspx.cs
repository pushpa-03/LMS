//using System;
//using System.Data;
//using System.IO;
//using System.Web;
//using System.Web.Services;
//using System.Web.UI;
//using System.Web.UI.WebControls;
//using Newtonsoft.Json;

//namespace LearningManagementSystem.Admin
//{
//    public partial class SubjectDetails : BasePage
//    {
//        private readonly SubjectDetailsBL _bl = new SubjectDetailsBL();

//        protected void Page_Load(object sender, EventArgs e)
//        {
//            try
//            {
//                if (!IsPostBack)
//                {
//                    if (SessionId == 0) { ShowMsg("No active academic session found.", "warning"); return; }

//                    if (!int.TryParse(Request.QueryString["SubjectId"], out int subjectId) || subjectId <= 0)
//                    { Response.Redirect("Subjects.aspx"); return; }

//                    hfSubjectId.Value = subjectId.ToString();
//                    LoadSubject(subjectId);
//                    BindChapters(subjectId);
//                    BindSubjectAssignments(subjectId);
//                }
//            }
//            catch (Exception ex) { ShowMsg("Error loading page: " + ex.Message, "danger"); }
//        }

//        // ── Subject info ──────────────────────────────────────────────────────
//        private void LoadSubject(int subjectId)
//        {
//            try
//            {
//                DataTable dt = _bl.GetSubjectDetails(subjectId, SessionId);
//                if (dt == null || dt.Rows.Count == 0) { ShowMsg("Subject not found.", "warning"); return; }
//                DataRow r = dt.Rows[0];
//                litSubjectName.Text = Server.HtmlEncode(r["SubjectName"]?.ToString() ?? "—");
//                litSubjectCode.Text = r["SubjectCode"]?.ToString() ?? "—";
//                litDuration.Text = r["Duration"]?.ToString() ?? "—";
//                litSociety.Text = r["SocietyName"]?.ToString() ?? "—";
//                litInstitute.Text = r["InstituteName"]?.ToString() ?? "—";
//                litStream.Text = r["StreamName"]?.ToString() ?? "—";
//                litCourse.Text = r["CourseName"]?.ToString() ?? "—";
//                litLevel.Text = r["LevelName"]?.ToString() ?? "—";
//                litSemester.Text = r["SemesterName"]?.ToString() ?? "—";
//                litDescription.Text = Server.HtmlEncode(r["Description"]?.ToString() ?? "No description.");
//                bool active = r["IsActive"] != DBNull.Value && Convert.ToBoolean(r["IsActive"]);
//                litStatus.Text = active
//                    ? "<span style='background:#dcfce7;color:#15803d;border-radius:6px;padding:3px 10px;font-size:.8rem;font-weight:700'>Active</span>"
//                    : "<span style='background:#fee2e2;color:#991b1b;border-radius:6px;padding:3px 10px;font-size:.8rem;font-weight:700'>Inactive</span>";
//            }
//            catch (Exception ex) { ShowMsg("Error loading subject: " + ex.Message, "danger"); }
//        }

//        // ── Chapters ──────────────────────────────────────────────────────────
//        private void BindChapters(int subjectId)
//        {
//            try
//            {
//                DataTable dt = _bl.GetChapters(subjectId, SessionId);
//                rptChapters.DataSource = dt;
//                rptChapters.DataBind();
//                phNoChapters.Visible = (dt == null || dt.Rows.Count == 0);
//                ddlChapters.Items.Clear();
//                ddlChapters.Items.Add(new ListItem("-- Select Chapter --", ""));
//                if (dt != null)
//                    foreach (DataRow row in dt.Rows)
//                        ddlChapters.Items.Add(new ListItem(row["ChapterName"].ToString(), row["ChapterId"].ToString()));
//            }
//            catch (Exception ex) { ShowMsg("Error loading chapters: " + ex.Message, "danger"); }
//        }

//        protected void rptChapters_ItemDataBound(object sender, RepeaterItemEventArgs e)
//        {
//            if (e.Item.ItemType != ListItemType.Item && e.Item.ItemType != ListItemType.AlternatingItem) return;
//            try
//            {
//                string chapterId = ((HiddenField)e.Item.FindControl("hfRowChapterId")).Value;
//                int cid = Convert.ToInt32(chapterId);
//                ((Repeater)e.Item.FindControl("rptVideos")).DataSource = _bl.GetVideosByChapter(cid, SessionId);
//                ((Repeater)e.Item.FindControl("rptVideos")).DataBind();
//                ((Repeater)e.Item.FindControl("rptMaterials")).DataSource = _bl.GetMaterialsByChapter(cid, SessionId);
//                ((Repeater)e.Item.FindControl("rptMaterials")).DataBind();
//            }
//            catch { }
//        }

//        // ── Assignments ───────────────────────────────────────────────────────
//        private void BindSubjectAssignments(int subjectId)
//        {
//            try
//            {
//                rptAssignments.DataSource = _bl.GetAssignmentsBySubject(subjectId, SessionId);
//                rptAssignments.DataBind();
//            }
//            catch (Exception ex) { ShowMsg("Error loading assignments: " + ex.Message, "danger"); }
//        }

//        // ── Chapter commands ──────────────────────────────────────────────────
//        protected void rptChapters_ItemCommand(object source, RepeaterCommandEventArgs e)
//        {
//            int.TryParse(e.CommandArgument?.ToString(), out int id);
//            try
//            {
//                if (e.CommandName == "EditChapter")
//                {
//                    DataTable dt = _bl.GetChapterById(id, SessionId);
//                    if (dt != null && dt.Rows.Count > 0)
//                    {
//                        hfChapterId.Value = id.ToString();
//                        txtChapterName.Text = dt.Rows[0]["ChapterName"].ToString();
//                        txtOrderNo.Text = dt.Rows[0]["OrderNo"].ToString();
//                        litChapterModalTitle.Text = "Edit Chapter";
//                        ScriptManager.RegisterStartupScript(this, GetType(), "ocm", "showChapterModal();", true);
//                    }
//                }
//                else if (e.CommandName == "DeleteChapter")
//                {
//                    _bl.DeleteChapter(id, SessionId);
//                    BindChapters(Convert.ToInt32(hfSubjectId.Value));
//                    SetToast("Chapter deleted.", "success");
//                }
//            }
//            catch (Exception ex) { ShowMsg("Error: " + ex.Message, "danger"); }
//        }

//        protected void rptVideos_ItemCommand(object source, RepeaterCommandEventArgs e)
//        {
//            if (e.CommandName != "DeleteVideo") return;
//            try
//            {
//                _bl.DeleteVideo(Convert.ToInt32(e.CommandArgument), SessionId);
//                BindChapters(Convert.ToInt32(hfSubjectId.Value));
//                SetToast("Video deleted.", "success");
//            }
//            catch (Exception ex) { ShowMsg("Error: " + ex.Message, "danger"); }
//        }

//        protected void rptMaterials_ItemCommand(object source, RepeaterCommandEventArgs e)
//        {
//            if (e.CommandName != "DeleteMaterial") return;
//            try
//            {
//                _bl.DeleteMaterial(Convert.ToInt32(e.CommandArgument), SessionId);
//                BindChapters(Convert.ToInt32(hfSubjectId.Value));
//                SetToast("Material deleted.", "success");
//            }
//            catch (Exception ex) { ShowMsg("Error: " + ex.Message, "danger"); }
//        }

//        // ── Save chapter ──────────────────────────────────────────────────────
//        protected void btnSaveChapter_Click(object sender, EventArgs e)
//        {
//            if (string.IsNullOrWhiteSpace(txtChapterName.Text)) { ShowMsg("Chapter name is required.", "warning"); return; }
//            try
//            {
//                int subjectId = Convert.ToInt32(hfSubjectId.Value);
//                _bl.SaveChapter(hfChapterId.Value, SessionId, subjectId.ToString(),
//                    txtChapterName.Text.Trim(),
//                    string.IsNullOrWhiteSpace(txtOrderNo.Text) ? "0" : txtOrderNo.Text.Trim(),
//                    SocietyId, InstituteId);
//                hfChapterId.Value = ""; txtChapterName.Text = ""; txtOrderNo.Text = "";
//                litChapterModalTitle.Text = "Add Chapter";
//                BindChapters(subjectId);
//                SetToast("Chapter saved!", "success");
//            }
//            catch (Exception ex) { ShowMsg("Error saving chapter: " + ex.Message, "danger"); }
//        }

//        // ── Upload content ────────────────────────────────────────────────────
//        protected void btnUploadSave_Click(object sender, EventArgs e)
//        {
//            try
//            {
//                // ── Validations ──
//                if (!fuContent.HasFile) { ShowMsg("Please select a file to upload.", "warning"); return; }
//                if (string.IsNullOrWhiteSpace(txtContentTitle.Text)) { ShowMsg("Title is required.", "warning"); return; }
//                if (string.IsNullOrEmpty(ddlChapters.SelectedValue)) { ShowMsg("Please select a chapter.", "warning"); return; }
//                if (!int.TryParse(ddlChapters.SelectedValue, out int chapterId)) { ShowMsg("Invalid chapter selected.", "warning"); return; }

//                string contentType = ddlContentType.SelectedValue;
//                string ext = Path.GetExtension(fuContent.FileName).ToLower().Trim();

//                if (string.IsNullOrEmpty(ext)) { ShowMsg("File has no extension. Please select a valid file.", "warning"); return; }

//                // ── Video-specific validations ──
//                if (contentType == "Video")
//                {
//                    ValidateVideoFile(ext); // throws if invalid
//                    int instructorId = 0;
//                    int.TryParse(hfInstructorId.Value, out instructorId);
//                    if (instructorId <= 0) { ShowMsg("Please select an instructor for the video.", "warning"); return; }
//                }

//                // ── Save file ──
//                string safeFile = Path.GetFileNameWithoutExtension(fuContent.FileName)
//                    .Replace(" ", "_").Replace("..", "").Replace("/", "").Replace("\\", "")
//                    + "_" + DateTime.Now.Ticks + ext;

//                string folder = contentType == "Video" ? "~/Uploads/Videos/" : "~/Uploads/Materials/";
//                string physPath = Server.MapPath(folder);
//                if (!Directory.Exists(physPath)) Directory.CreateDirectory(physPath);

//                string fullPath = Path.Combine(physPath, safeFile);
//                fuContent.SaveAs(fullPath);
//                string dbPath = folder.Replace("~", "") + safeFile;

//                int subjectId = Convert.ToInt32(hfSubjectId.Value);

//                if (contentType == "Video")
//                {
//                    int.TryParse(hfInstructorId.Value, out int instructorId);
//                    int newVideoId = _bl.InsertVideo(SocietyId, InstituteId, SessionId,
//                        chapterId, subjectId,
//                        txtContentTitle.Text.Trim(), txtVideoDesc.Text.Trim(),
//                        dbPath, instructorId, UserId);

//                    string[] times = Request.Form.GetValues("topicTime");
//                    string[] titles = Request.Form.GetValues("topicTitle");
//                    if (times != null && titles != null)
//                        _bl.InsertVideoTopics(SocietyId, InstituteId, SessionId, newVideoId, times, titles);

//                    _bl.NotifyStudents(SocietyId, InstituteId, SessionId, subjectId,
//                        $"New video: {txtContentTitle.Text.Trim()}");
//                }
//                else
//                {
//                    _bl.InsertMaterial(SocietyId, InstituteId, SessionId, chapterId,
//                        txtContentTitle.Text.Trim(), dbPath, ext);
//                    _bl.NotifyStudents(SocietyId, InstituteId, SessionId, subjectId,
//                        $"New material: {txtContentTitle.Text.Trim()}");
//                }

//                _bl.LogActivity(UserId, SocietyId, InstituteId, SessionId,
//                    $"Uploaded {contentType}: {txtContentTitle.Text.Trim()}");

//                txtContentTitle.Text = ""; txtVideoDesc.Text = ""; hfInstructorId.Value = "";
//                BindChapters(subjectId);
//                SetToast($"{contentType} uploaded! Students notified.", "success");
//            }
//            catch (InvalidOperationException ioex) { ShowMsg(ioex.Message, "warning"); }
//            catch (Exception ex) { ShowMsg("Upload failed: " + ex.Message, "danger"); }
//        }

//        // ── File type validation ──────────────────────────────────────────────
//        private void ValidateVideoFile(string ext)
//        {
//            string[] ok = { ".mp4", ".webm", ".ogg", ".avi", ".mov", ".mkv", ".flv", ".wmv" };
//            foreach (var a in ok) if (ext == a) return;
//            throw new InvalidOperationException("Invalid video format. Allowed: mp4, webm, ogg, avi, mov, mkv, flv, wmv.");
//        }

//        // ══════════════════════════════════════════════════════════════════════
//        //  TEACHER SEARCH — WebMethod (AJAX)
//        //  Called from JS: fetch('SubjectDetails.aspx/SearchTeachers', { method:'POST', ... })
//        //  This is the FIXED approach — no more Page_PreRender query string hack
//        // ══════════════════════════════════════════════════════════════════════
//        [WebMethod(EnableSession = true)]
//        public static string SearchTeachers(string q, int subjectId)
//        {
//            try
//            {
//                if (string.IsNullOrWhiteSpace(q) || q.Trim().Length < 1)
//                    return "[]";

//                int instituteId = GetSess("InstituteId");
//                int sessionId = GetSess("SessionId");

//                if (instituteId == 0) return "[]";

//                var bl = new SubjectDetailsBL();
//                DataTable dt = bl.SearchTeachersForSubject(q.Trim(), subjectId, instituteId, sessionId);

//                var list = new System.Collections.Generic.List<object>();
//                foreach (DataRow row in dt.Rows)
//                {
//                    list.Add(new
//                    {
//                        UserId = row["UserId"],
//                        Name = row["FullName"]?.ToString() ?? "",
//                        Designation = row["Designation"]?.ToString() ?? "Teacher"
//                    });
//                }
//                return JsonConvert.SerializeObject(list);
//            }
//            catch (Exception ex)
//            {
//                // Return error as JSON so JS can show a useful message
//                return JsonConvert.SerializeObject(new[] {
//                    new { UserId = 0, Name = "Error: " + ex.Message, Designation = "" }
//                });
//            }
//        }

//        // ── Session helper ────────────────────────────────────────────────────
//        private static int GetSess(string key)
//        {
//            var v = HttpContext.Current.Session[key];
//            return v != null && int.TryParse(v.ToString(), out int r) ? r : 0;
//        }

//        // ── ASPX markup helpers ───────────────────────────────────────────────
//        protected string GetFileIcon(string ext)
//        {
//            switch ((ext ?? "").ToLower().Trim('.'))
//            {
//                case "pdf": return "pdf";
//                case "doc": case "docx": return "doc";
//                case "ppt": case "pptx": return "ppt";
//                case "jpg": case "jpeg": case "png": case "gif": case "webp": return "img";
//                default: return "file";
//            }
//        }

//        protected string GetFileIconClass(string ext)
//        {
//            switch ((ext ?? "").ToLower().Trim('.'))
//            {
//                case "pdf": return "fa fa-file-pdf";
//                case "doc": case "docx": return "fa fa-file-word";
//                case "ppt": case "pptx": return "fa fa-file-powerpoint";
//                case "jpg": case "jpeg": case "png": case "gif": case "webp": return "fa fa-file-image";
//                case "xls": case "xlsx": return "fa fa-file-excel";
//                case "zip": case "rar": return "fa fa-file-archive";
//                default: return "fa fa-file-alt";
//            }
//        }

//        private void ShowMsg(string msg, string type)
//        {
//            lblMsg.Text = msg;
//            lblMsg.CssClass = $"alert alert-{type} alert-auto d-block mb-3";
//            lblMsg.Visible = true;
//        }

//        private void SetToast(string msg, string type)
//        {
//            hfToastMsg.Value = msg;
//            hfToastType.Value = type;
//        }
//    }
//}


//========================================================================================================


using System;
using System.Data;
using System.IO;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using Newtonsoft.Json;

namespace LearningManagementSystem.Admin
{
    public partial class SubjectDetails : BasePage
    {
        // ── File-size limits — must match JS constants in SubjectDetails.aspx ──
        private const long VIDEO_MAX_BYTES = 1024L * 1024 * 1024; // 1 GB
        private const long MATERIAL_MAX_BYTES = 100L * 1024 * 1024; // 100 MB

        private readonly SubjectDetailsBL _bl = new SubjectDetailsBL();

        protected void Page_Load(object sender, EventArgs e)
        {
            try
            {
                if (!IsPostBack)
                {
                    if (SessionId == 0) { ShowMsg("No active academic session found.", "warning"); return; }

                    if (!int.TryParse(Request.QueryString["SubjectId"], out int subjectId) || subjectId <= 0)
                    { Response.Redirect("Subjects.aspx"); return; }

                    hfSubjectId.Value = subjectId.ToString();
                    LoadSubject(subjectId);
                    BindChapters(subjectId);
                    BindSubjectAssignments(subjectId);
                }
            }
            catch (Exception ex) { ShowMsg("Error loading page: " + ex.Message, "danger"); }
        }

        // ── Subject info ──────────────────────────────────────────────────────
        private void LoadSubject(int subjectId)
        {
            try
            {
                DataTable dt = _bl.GetSubjectDetails(subjectId, SessionId);
                if (dt == null || dt.Rows.Count == 0) { ShowMsg("Subject not found.", "warning"); return; }
                DataRow r = dt.Rows[0];
                litSubjectName.Text = Server.HtmlEncode(r["SubjectName"]?.ToString() ?? "—");
                litSubjectCode.Text = r["SubjectCode"]?.ToString() ?? "—";
                litDuration.Text = r["Duration"]?.ToString() ?? "—";
                litSociety.Text = r["SocietyName"]?.ToString() ?? "—";
                litInstitute.Text = r["InstituteName"]?.ToString() ?? "—";
                litStream.Text = r["StreamName"]?.ToString() ?? "—";
                litCourse.Text = r["CourseName"]?.ToString() ?? "—";
                litLevel.Text = r["LevelName"]?.ToString() ?? "—";
                litSemester.Text = r["SemesterName"]?.ToString() ?? "—";
                litDescription.Text = Server.HtmlEncode(r["Description"]?.ToString() ?? "No description.");
                bool active = r["IsActive"] != DBNull.Value && Convert.ToBoolean(r["IsActive"]);
                litStatus.Text = active
                    ? "<span style='background:#dcfce7;color:#15803d;border-radius:6px;padding:3px 10px;font-size:.8rem;font-weight:700'>Active</span>"
                    : "<span style='background:#fee2e2;color:#991b1b;border-radius:6px;padding:3px 10px;font-size:.8rem;font-weight:700'>Inactive</span>";
            }
            catch (Exception ex) { ShowMsg("Error loading subject: " + ex.Message, "danger"); }
        }

        // ── Chapters ──────────────────────────────────────────────────────────
        private void BindChapters(int subjectId)
        {
            try
            {
                DataTable dt = _bl.GetChapters(subjectId, SessionId);
                rptChapters.DataSource = dt;
                rptChapters.DataBind();
                phNoChapters.Visible = (dt == null || dt.Rows.Count == 0);
                ddlChapters.Items.Clear();
                ddlChapters.Items.Add(new ListItem("-- Select Chapter --", ""));
                if (dt != null)
                    foreach (DataRow row in dt.Rows)
                        ddlChapters.Items.Add(new ListItem(row["ChapterName"].ToString(), row["ChapterId"].ToString()));
            }
            catch (Exception ex) { ShowMsg("Error loading chapters: " + ex.Message, "danger"); }
        }

        protected void rptChapters_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item && e.Item.ItemType != ListItemType.AlternatingItem) return;
            try
            {
                int cid = Convert.ToInt32(((HiddenField)e.Item.FindControl("hfRowChapterId")).Value);
                ((Repeater)e.Item.FindControl("rptVideos")).DataSource = _bl.GetVideosByChapter(cid, SessionId);
                ((Repeater)e.Item.FindControl("rptVideos")).DataBind();
                ((Repeater)e.Item.FindControl("rptMaterials")).DataSource = _bl.GetMaterialsByChapter(cid, SessionId);
                ((Repeater)e.Item.FindControl("rptMaterials")).DataBind();
            }
            catch { }
        }

        // ── Assignments ───────────────────────────────────────────────────────
        private void BindSubjectAssignments(int subjectId)
        {
            try
            {
                rptAssignments.DataSource = _bl.GetAssignmentsBySubject(subjectId, SessionId);
                rptAssignments.DataBind();
            }
            catch (Exception ex) { ShowMsg("Error loading assignments: " + ex.Message, "danger"); }
        }

        // ── Chapter commands ──────────────────────────────────────────────────
        protected void rptChapters_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int.TryParse(e.CommandArgument?.ToString(), out int id);
            try
            {
                if (e.CommandName == "EditChapter")
                {
                    DataTable dt = _bl.GetChapterById(id, SessionId);
                    if (dt != null && dt.Rows.Count > 0)
                    {
                        hfChapterId.Value = id.ToString();
                        txtChapterName.Text = dt.Rows[0]["ChapterName"].ToString();
                        txtOrderNo.Text = dt.Rows[0]["OrderNo"].ToString();
                        litChapterModalTitle.Text = "Edit Chapter";
                        ScriptManager.RegisterStartupScript(this, GetType(), "ocm", "showChapterModal();", true);
                    }
                }
                else if (e.CommandName == "DeleteChapter")
                {
                    _bl.DeleteChapter(id, SessionId);
                    BindChapters(Convert.ToInt32(hfSubjectId.Value));
                    SetToast("Chapter deleted.", "success");
                }
            }
            catch (Exception ex) { ShowMsg("Error: " + ex.Message, "danger"); }
        }

        protected void rptVideos_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "DeleteVideo") return;
            try
            {
                _bl.DeleteVideo(Convert.ToInt32(e.CommandArgument), SessionId);
                BindChapters(Convert.ToInt32(hfSubjectId.Value));
                SetToast("Video deleted.", "success");
            }
            catch (Exception ex) { ShowMsg("Error: " + ex.Message, "danger"); }
        }

        protected void rptMaterials_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "DeleteMaterial") return;
            try
            {
                _bl.DeleteMaterial(Convert.ToInt32(e.CommandArgument), SessionId);
                BindChapters(Convert.ToInt32(hfSubjectId.Value));
                SetToast("Material deleted.", "success");
            }
            catch (Exception ex) { ShowMsg("Error: " + ex.Message, "danger"); }
        }

        // ── Save chapter ──────────────────────────────────────────────────────
        protected void btnSaveChapter_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtChapterName.Text)) { ShowMsg("Chapter name is required.", "warning"); return; }
            try
            {
                int subjectId = Convert.ToInt32(hfSubjectId.Value);
                _bl.SaveChapter(hfChapterId.Value, SessionId, subjectId.ToString(),
                    txtChapterName.Text.Trim(),
                    string.IsNullOrWhiteSpace(txtOrderNo.Text) ? "0" : txtOrderNo.Text.Trim(),
                    SocietyId, InstituteId);
                hfChapterId.Value = ""; txtChapterName.Text = ""; txtOrderNo.Text = "";
                litChapterModalTitle.Text = "Add Chapter";
                BindChapters(subjectId);
                SetToast("Chapter saved!", "success");
            }
            catch (Exception ex) { ShowMsg("Error saving chapter: " + ex.Message, "danger"); }
        }

        // ═════════════════════════════════════════════════════════════════════
        //  UPLOAD CONTENT
        // ═════════════════════════════════════════════════════════════════════
        protected void btnUploadSave_Click(object sender, EventArgs e)
        {
            try
            {
                // ── Basic validations ──
                if (!fuContent.HasFile)
                { ShowMsg("Please select a file to upload.", "warning"); return; }
                if (string.IsNullOrWhiteSpace(txtContentTitle.Text))
                { ShowMsg("Title is required.", "warning"); return; }
                if (string.IsNullOrEmpty(ddlChapters.SelectedValue))
                { ShowMsg("Please select a chapter.", "warning"); return; }
                if (!int.TryParse(ddlChapters.SelectedValue, out int chapterId))
                { ShowMsg("Invalid chapter selected.", "warning"); return; }

                string contentType = ddlContentType.SelectedValue;
                string ext = Path.GetExtension(fuContent.FileName).ToLower().Trim();

                if (string.IsNullOrEmpty(ext))
                { ShowMsg("File has no extension. Please select a valid file.", "warning"); return; }

                // ── Server-side file size validation ──
                long fileSize = fuContent.PostedFile.ContentLength;
                if (contentType == "Video")
                {
                    if (fileSize > VIDEO_MAX_BYTES)
                    {
                        ShowMsg(
                            $"Video file is too large ({FormatBytes(fileSize)}). " +
                            $"Maximum allowed size is {FormatBytes(VIDEO_MAX_BYTES)}.", "warning");
                        return;
                    }
                    ValidateVideoFile(ext);   // throws InvalidOperationException if wrong type

                    int.TryParse(hfInstructorId.Value, out int instrCheck);
                    if (instrCheck <= 0)
                    { ShowMsg("Please select an instructor for the video.", "warning"); return; }
                }
                else
                {
                    if (fileSize > MATERIAL_MAX_BYTES)
                    {
                        ShowMsg(
                            $"Material file is too large ({FormatBytes(fileSize)}). " +
                            $"Maximum allowed size is {FormatBytes(MATERIAL_MAX_BYTES)}.", "warning");
                        return;
                    }
                    ValidateMaterialFile(ext); // throws InvalidOperationException if wrong type
                }

                // ── Save file to disk ──
                string safeFile = Path.GetFileNameWithoutExtension(fuContent.FileName)
                    .Replace(" ", "_").Replace("..", "").Replace("/", "").Replace("\\", "")
                    + "_" + DateTime.Now.Ticks + ext;

                string folder = contentType == "Video" ? "~/Uploads/Videos/" : "~/Uploads/Materials/";
                string physPath = Server.MapPath(folder);
                if (!Directory.Exists(physPath)) Directory.CreateDirectory(physPath);

                string fullPath = Path.Combine(physPath, safeFile);
                fuContent.SaveAs(fullPath);
                string dbPath = folder.Replace("~", "") + safeFile;

                int subjectId = Convert.ToInt32(hfSubjectId.Value);

                if (contentType == "Video")
                {
                    int.TryParse(hfInstructorId.Value, out int instructorId);
                    int newVideoId = _bl.InsertVideo(SocietyId, InstituteId, SessionId,
                        chapterId, subjectId,
                        txtContentTitle.Text.Trim(), txtVideoDesc.Text.Trim(),
                        dbPath, instructorId, UserId);

                    string[] times = Request.Form.GetValues("topicTime");
                    string[] titles = Request.Form.GetValues("topicTitle");
                    if (times != null && titles != null)
                        _bl.InsertVideoTopics(SocietyId, InstituteId, SessionId, newVideoId, times, titles);

                    _bl.NotifyStudents(SocietyId, InstituteId, SessionId, subjectId,
                        $"New video: {txtContentTitle.Text.Trim()}");
                }
                else
                {
                    _bl.InsertMaterial(SocietyId, InstituteId, SessionId, chapterId,
                        txtContentTitle.Text.Trim(), dbPath, ext);
                    _bl.NotifyStudents(SocietyId, InstituteId, SessionId, subjectId,
                        $"New material: {txtContentTitle.Text.Trim()}");
                }

                _bl.LogActivity(UserId, SocietyId, InstituteId, SessionId,
                    $"Uploaded {contentType}: {txtContentTitle.Text.Trim()}");

                txtContentTitle.Text = ""; txtVideoDesc.Text = ""; hfInstructorId.Value = "";
                BindChapters(subjectId);
                SetToast($"{contentType} uploaded! Students notified.", "success");
            }
            catch (InvalidOperationException ioex) { ShowMsg(ioex.Message, "warning"); }
            catch (Exception ex) { ShowMsg("Upload failed: " + ex.Message, "danger"); }
        }

        // ── File type validators ──────────────────────────────────────────────
        private void ValidateVideoFile(string ext)
        {
            string[] ok = { ".mp4", ".webm", ".ogg", ".avi", ".mov", ".mkv", ".flv", ".wmv" };
            foreach (var a in ok) if (ext == a) return;
            throw new InvalidOperationException(
                "Invalid video format. Allowed: mp4, webm, ogg, avi, mov, mkv, flv, wmv.");
        }

        private void ValidateMaterialFile(string ext)
        {
            string[] ok = {
                ".pdf", ".doc", ".docx", ".ppt", ".pptx",
                ".xls", ".xlsx", ".jpg", ".jpeg", ".png",
                ".gif", ".webp", ".zip", ".rar", ".txt"
            };
            foreach (var a in ok) if (ext == a) return;
            throw new InvalidOperationException(
                "Invalid material format. Allowed: pdf, doc, docx, ppt, pptx, xls, xlsx, jpg, png, gif, webp, zip, rar, txt.");
        }

        /// <summary>Formats a byte count into a human-readable string (KB / MB / GB).</summary>
        private static string FormatBytes(long bytes)
        {
            if (bytes >= 1024L * 1024 * 1024) return $"{bytes / (1024.0 * 1024 * 1024):F1} GB";
            if (bytes >= 1024L * 1024) return $"{bytes / (1024.0 * 1024):F1} MB";
            return $"{bytes / 1024.0:F1} KB";
        }

        // ═════════════════════════════════════════════════════════════════════
        //  TEACHER SEARCH — WebMethod (AJAX)
        // ═════════════════════════════════════════════════════════════════════
        [WebMethod(EnableSession = true)]
        public static string SearchTeachers(string q, int subjectId)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(q) || q.Trim().Length < 1) return "[]";

                int instituteId = GetSess("InstituteId");
                int sessionId = GetSess("SessionId");
                if (instituteId == 0) return "[]";

                var bl = new SubjectDetailsBL();
                DataTable dt = bl.SearchTeachersForSubject(q.Trim(), subjectId, instituteId, sessionId);
                var list = new System.Collections.Generic.List<object>();
                foreach (DataRow row in dt.Rows)
                {
                    list.Add(new
                    {
                        UserId = row["UserId"],
                        Name = row["FullName"]?.ToString() ?? "",
                        Designation = row["Designation"]?.ToString() ?? "Teacher"
                    });
                }
                return JsonConvert.SerializeObject(list);
            }
            catch (Exception ex)
            {
                return JsonConvert.SerializeObject(new[] {
                    new { UserId = 0, Name = "Error: " + ex.Message, Designation = "" }
                });
            }
        }

        // ── Session helper ────────────────────────────────────────────────────
        private static int GetSess(string key)
        {
            var v = HttpContext.Current.Session[key];
            return v != null && int.TryParse(v.ToString(), out int r) ? r : 0;
        }

        // ── ASPX markup helpers ───────────────────────────────────────────────
        protected string GetFileIcon(string ext)
        {
            switch ((ext ?? "").ToLower().Trim('.'))
            {
                case "pdf": return "pdf";
                case "doc": case "docx": return "doc";
                case "ppt": case "pptx": return "ppt";
                case "jpg":
                case "jpeg":
                case "png":
                case "gif":
                case "webp": return "img";
                default: return "file";
            }
        }

        protected string GetFileIconClass(string ext)
        {
            switch ((ext ?? "").ToLower().Trim('.'))
            {
                case "pdf": return "fa fa-file-pdf";
                case "doc": case "docx": return "fa fa-file-word";
                case "ppt": case "pptx": return "fa fa-file-powerpoint";
                case "jpg":
                case "jpeg":
                case "png":
                case "gif":
                case "webp": return "fa fa-file-image";
                case "xls": case "xlsx": return "fa fa-file-excel";
                case "zip": case "rar": return "fa fa-file-archive";
                default: return "fa fa-file-alt";
            }
        }

        // ── UI helpers ────────────────────────────────────────────────────────
        private void ShowMsg(string msg, string type)
        {
            lblMsg.Text = msg;
            lblMsg.CssClass = $"alert alert-{type} alert-auto d-block mb-3";
            lblMsg.Visible = true;
        }

        private void SetToast(string msg, string type)
        {
            hfToastMsg.Value = msg;
            hfToastType.Value = type;
        }
    }
}