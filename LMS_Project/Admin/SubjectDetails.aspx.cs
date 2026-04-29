//using System;
//using System.Data;
//using System.IO;
//using System.Runtime.InteropServices.ComTypes;
//using System.Web.UI;
//using System.Web.UI.WebControls;

//namespace LearningManagementSystem.Admin
//{
//    public partial class SubjectDetails : BasePage
//    {
//        SubjectDetailsBL bl = new SubjectDetailsBL();

//        int UserId => UserId;

//        protected void Page_Load(object sender, EventArgs e)
//        {
//            if (!IsPostBack)
//            {
//                if (SessionId == 0)
//                {
//                    lblMsg.Text = "No active academic session found!";
//                    lblMsg.Visible = true;
//                    return;
//                }

//                if (Request.QueryString["SubjectId"] != null &&
//                    int.TryParse(Request.QueryString["SubjectId"], out int subjectId))
//                {
//                    hfSubjectId.Value = subjectId.ToString();

//                    LoadSubject();
//                    BindChapters();
//                    BindSubjectAssignments();
//                }
//                else
//                {
//                    Response.Redirect("Subjects.aspx");
//                }
//            }
//        }
//        private void LoadSubject()
//        {
//            DataTable dt = bl.GetSubjectDetails(Convert.ToInt32(hfSubjectId.Value), SessionId);

//            if (dt != null && dt.Rows.Count > 0)
//            {
//                DataRow r = dt.Rows[0];

//                litSubjectName.Text = "<strong>" + r["SubjectName"] + "</strong>";
//                litSubjectCode.Text = r["SubjectCode"]?.ToString() ?? "";
//                litDuration.Text = r["Duration"]?.ToString() ?? "";

//                litStatus.Text = Convert.ToBoolean(r["IsActive"])
//                    ? "<span class='badge bg-success'>Active</span>"
//                    : "<span class='badge bg-danger'>Inactive</span>";

//                litSociety.Text = r["SocietyName"]?.ToString() ?? "";
//                litInstitute.Text = r["InstituteName"]?.ToString() ?? "";
//                litStream.Text = r["StreamName"]?.ToString() ?? "";
//                litCourse.Text = r["CourseName"]?.ToString() ?? "";
//                litLevel.Text = r["LevelName"]?.ToString() ?? "";
//                litSemester.Text = r["SemesterName"]?.ToString() ?? "";
//                litDescription.Text = r["Description"]?.ToString() ?? "";
//            }
//        }

//        private void BindChapters()
//        {
//            DataTable dt = bl.GetChapters(Convert.ToInt32(hfSubjectId.Value), SessionId);

//            rptChapters.DataSource = dt;
//            rptChapters.DataBind();

//            if (dt != null && dt.Rows.Count > 0)
//            {
//                ddlChapters.DataSource = dt;
//                ddlChapters.DataTextField = "ChapterName";
//                ddlChapters.DataValueField = "ChapterId";
//                ddlChapters.DataBind();
//            }
//        }

//        // ================= BIND VIDEOS & MATERIALS =================
//        protected void rptChapters_ItemDataBound(object sender, RepeaterItemEventArgs e)
//        {
//            if (e.Item.ItemType == ListItemType.Item ||
//                e.Item.ItemType == ListItemType.AlternatingItem)
//            {
//                string chapterId = ((HiddenField)e.Item.FindControl("hfRowChapterId")).Value;

//                Repeater rptVideos = (Repeater)e.Item.FindControl("rptVideos");
//                Repeater rptMaterials = (Repeater)e.Item.FindControl("rptMaterials");

//                rptVideos.DataSource = bl.GetVideosByChapter(Convert.ToInt32(chapterId), SessionId);
//                rptVideos.DataBind();

//                rptMaterials.DataSource = bl.GetMaterialsByChapter(Convert.ToInt32(chapterId), SessionId);
//                rptMaterials.DataBind();


//                //Repeater rptAssignments = (Repeater)e.Item.FindControl("rptAssignments");

//                //rptAssignments.DataSource = bl.GetAssignmentsBySubject(
//                //    Convert.ToInt32(hfSubjectId.Value)
//                //);
//                //rptAssignments.DataBind();
//            }
//        }

//        private void BindSubjectAssignments()
//        {
//            try
//            {
//                // Use the Subject ID from your HiddenField
//                int subjectId = Convert.ToInt32(hfSubjectId.Value);

//                // Bind directly to the Repeater that is now outside the chapters
//                rptAssignments.DataSource = bl.GetAssignmentsBySubject(subjectId, SessionId);
//                rptAssignments.DataBind();
//            }
//            catch (Exception ex)
//            {
//                lblMsg.Text = "Error loading assignments: " + ex.Message;
//                lblMsg.Visible = true;
//            }
//        }

//        // ================= SAVE CHAPTER =================
//        protected void btnSaveChapter_Click(object sender, EventArgs e)
//        {
//            if (string.IsNullOrWhiteSpace(txtChapterName.Text))
//            {
//                ShowMsg("Chapter name required", false);
//                return;
//            }

//            bl.SaveChapter(
//                hfChapterId.Value,
//                SessionId,
//                hfSubjectId.Value,
//                txtChapterName.Text.Trim(),
//                txtOrderNo.Text.Trim()
//            );

//            hfChapterId.Value = "";
//            txtChapterName.Text = "";
//            txtOrderNo.Text = "";

//            BindChapters();
//            ShowMsg("Chapter Saved Successfully", true);
//        }

//        // ================= EDIT / DELETE CHAPTER =================
//        protected void rptChapters_ItemCommand(object source, RepeaterCommandEventArgs e)
//        {
//            int id = Convert.ToInt32(e.CommandArgument);

//            if (e.CommandName == "EditChapter")
//            {
//                DataTable dt = bl.GetChapterById(id, SessionId);

//                if (dt != null && dt.Rows.Count > 0)
//                {
//                    hfChapterId.Value = id.ToString();
//                    txtChapterName.Text = dt.Rows[0]["ChapterName"].ToString();
//                    txtOrderNo.Text = dt.Rows[0]["OrderNo"].ToString();

//                    ScriptManager.RegisterStartupScript(this, GetType(),
//                        "modal", "showChapterModal();", true);
//                }
//            }
//            else if (e.CommandName == "DeleteChapter")
//            {
//                bl.DeleteChapter(id, SessionId);

//                BindChapters();
//                ShowMsg("Chapter Deleted Successfully", true);
//            }
//        }

//        // ================= UPLOAD CONTENT =================
//        protected void btnUploadSave_Click(object sender, EventArgs e)
//        {
//            if (!fuContent.HasFile)
//            {
//                ShowMsg("Please select file", false);
//                return;
//            }

//            try
//            {
//                string fileName = Path.GetFileName(fuContent.FileName);

//                string folderRelPath =
//                    ddlContentType.SelectedValue == "Video"
//                    ? "~/Uploads/Videos/"
//                    : "~/Uploads/Materials/";

//                string physicalPath = Server.MapPath(folderRelPath);

//                if (!Directory.Exists(physicalPath))
//                    Directory.CreateDirectory(physicalPath);

//                string fullPath = Path.Combine(physicalPath, fileName);
//                fuContent.SaveAs(fullPath);

//                string dbPath = folderRelPath.Replace("~", "") + fileName;


//                if (ddlContentType.SelectedValue == "Video")
//                {
//                    if (!int.TryParse(ddlChapters.SelectedValue, out int chapterId))
//                    {
//                        ShowMsg("Invalid chapter selected", false);
//                        return;
//                    }

//                    int newVideoId = bl.InsertVideo(
//                        SocietyId,
//                        InstituteId,
//                        SessionId,
//                        chapterId,
//                        txtContentTitle.Text.Trim(),
//                        txtVideoDesc.Text.Trim(),
//                        dbPath,
//                        txtInstructor.Text.Trim(),
//                        UserId
//                    );

//                    string[] times = Request.Form.GetValues("topicTime");
//                    string[] titles = Request.Form.GetValues("topicTitle");

//                    if (times != null && titles != null)
//                    {

//                        bl.InsertVideoTopics(
//                             SocietyId,
//                             InstituteId,
//                             SessionId,
//                             newVideoId,
//                             times,
//                             titles
//                         );
//                    }
//                }
//                else
//                {
//                    // ✅ Validate first
//                    if (!int.TryParse(ddlChapters.SelectedValue, out int chapterId))
//                    {
//                        ShowMsg("Invalid chapter selected", false);
//                        return;
//                    }

//                    // ✅ Then call method
//                    bl.InsertMaterial(
//                         SocietyId,
//                         InstituteId,
//                         SessionId,
//                         chapterId,
//                         txtContentTitle.Text.Trim(),
//                         dbPath,
//                         Path.GetExtension(fileName)
//                     );
//                }

//                txtContentTitle.Text = "";
//                txtVideoDesc.Text = "";
//                txtInstructor.Text = "";

//                BindChapters();
//                ShowMsg("Uploaded Successfully", true);
//            }
//            catch (Exception ex)
//            {
//                ShowMsg("Error: " + ex.Message, false);
//            }
//        }

//        private void ShowMsg(string msg, bool success)
//        {
//            lblMsg.Text = msg;
//            lblMsg.CssClass = success ? "alert alert-success" : "alert alert-danger";
//            lblMsg.Visible = true;
//        }
//    }
//}

//------------------------------------------------------------------------------------------------------------------------------

using System;
using System.Data;
using System.IO;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace LearningManagementSystem.Admin
{
    public partial class SubjectDetails : BasePage
    {
        private readonly SubjectDetailsBL _bl = new SubjectDetailsBL();

        protected void Page_Load(object sender, EventArgs e)
        {
            try
            {
                if (!IsPostBack)
                {
                    if (SessionId == 0)
                    {
                        ShowMsg("No active academic session found.", "warning");
                        return;
                    }

                    if (!int.TryParse(Request.QueryString["SubjectId"], out int subjectId) || subjectId <= 0)
                    {
                        Response.Redirect("Subjects.aspx");
                        return;
                    }

                    hfSubjectId.Value = subjectId.ToString();
                    LoadSubject(subjectId);
                    BindChapters(subjectId);
                    BindSubjectAssignments(subjectId);
                }
            }
            catch (Exception ex)
            {
                ShowMsg("Error loading page: " + ex.Message, "danger");
            }
        }

        // ── Load subject header info ──────────────────────────────────────────
        private void LoadSubject(int subjectId)
        {
            try
            {
                DataTable dt = _bl.GetSubjectDetails(subjectId, SessionId);
                if (dt == null || dt.Rows.Count == 0)
                {
                    ShowMsg("Subject not found.", "warning");
                    return;
                }

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
                litDescription.Text = Server.HtmlEncode(r["Description"]?.ToString() ?? "No description provided.");

                bool isActive = r["IsActive"] != DBNull.Value && Convert.ToBoolean(r["IsActive"]);
                litStatus.Text = isActive
                    ? "<span style='background:#dcfce7;color:#15803d;border-radius:6px;padding:3px 10px;font-size:.8rem;font-weight:700'>Active</span>"
                    : "<span style='background:#fee2e2;color:#991b1b;border-radius:6px;padding:3px 10px;font-size:.8rem;font-weight:700'>Inactive</span>";
            }
            catch (Exception ex)
            {
                ShowMsg("Error loading subject: " + ex.Message, "danger");
            }
        }

        // ── Bind chapters + nested repeaters ─────────────────────────────────
        private void BindChapters(int subjectId)
        {
            try
            {
                DataTable dt = _bl.GetChapters(subjectId, SessionId);
                rptChapters.DataSource = dt;
                rptChapters.DataBind();

                phNoChapters.Visible = (dt == null || dt.Rows.Count == 0);

                // Populate chapter dropdown in Upload Modal
                ddlChapters.Items.Clear();
                if (dt != null && dt.Rows.Count > 0)
                {
                    foreach (DataRow row in dt.Rows)
                    {
                        ddlChapters.Items.Add(new ListItem(
                            row["ChapterName"].ToString(),
                            row["ChapterId"].ToString()));
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMsg("Error loading chapters: " + ex.Message, "danger");
            }
        }

        // ── ItemDataBound: load nested videos & materials ─────────────────────
        protected void rptChapters_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item &&
                e.Item.ItemType != ListItemType.AlternatingItem) return;

            try
            {
                string chapterId = ((HiddenField)e.Item.FindControl("hfRowChapterId")).Value;
                int cid = Convert.ToInt32(chapterId);

                ((Repeater)e.Item.FindControl("rptVideos")).DataSource =
                    _bl.GetVideosByChapter(cid, SessionId);
                ((Repeater)e.Item.FindControl("rptVideos")).DataBind();

                ((Repeater)e.Item.FindControl("rptMaterials")).DataSource =
                    _bl.GetMaterialsByChapter(cid, SessionId);
                ((Repeater)e.Item.FindControl("rptMaterials")).DataBind();
            }
            catch { /* Silently skip broken chapter row */ }
        }

        // ── Assignments ───────────────────────────────────────────────────────
        private void BindSubjectAssignments(int subjectId)
        {
            try
            {
                rptAssignments.DataSource = _bl.GetAssignmentsBySubject(subjectId, SessionId);
                rptAssignments.DataBind();
            }
            catch (Exception ex)
            {
                ShowMsg("Error loading assignments: " + ex.Message, "danger");
            }
        }

        // ── Chapter commands ──────────────────────────────────────────────────
        protected void rptChapters_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int id = 0;
            int.TryParse(e.CommandArgument?.ToString(), out id);

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
                        ScriptManager.RegisterStartupScript(this, GetType(), "openChapterModal", "showChapterModal();", true);
                    }
                }
                else if (e.CommandName == "DeleteChapter")
                {
                    _bl.DeleteChapter(id, SessionId);
                    int subjectId = Convert.ToInt32(hfSubjectId.Value);
                    BindChapters(subjectId);
                    SetToast("Chapter deleted successfully.", "success");
                }
            }
            catch (Exception ex)
            {
                ShowMsg("Error: " + ex.Message, "danger");
            }
        }

        // ── Video delete ──────────────────────────────────────────────────────
        protected void rptVideos_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "DeleteVideo") return;
            try
            {
                int videoId = Convert.ToInt32(e.CommandArgument);
                int subjectId = Convert.ToInt32(hfSubjectId.Value);
                _bl.DeleteVideo(videoId, SessionId);
                BindChapters(subjectId);
                SetToast("Video deleted successfully.", "success");
            }
            catch (Exception ex)
            {
                ShowMsg("Error deleting video: " + ex.Message, "danger");
            }
        }

        // ── Material delete ───────────────────────────────────────────────────
        protected void rptMaterials_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "DeleteMaterial") return;
            try
            {
                int materialId = Convert.ToInt32(e.CommandArgument);
                int subjectId = Convert.ToInt32(hfSubjectId.Value);
                _bl.DeleteMaterial(materialId, SessionId);
                BindChapters(subjectId);
                SetToast("Material deleted.", "success");
            }
            catch (Exception ex)
            {
                ShowMsg("Error deleting material: " + ex.Message, "danger");
            }
        }

        // ── Save chapter ──────────────────────────────────────────────────────
        protected void btnSaveChapter_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtChapterName.Text))
            {
                ShowMsg("Chapter name is required.", "warning");
                return;
            }

            try
            {
                int subjectId = Convert.ToInt32(hfSubjectId.Value);
                _bl.SaveChapter(
                    hfChapterId.Value, SessionId,
                    subjectId.ToString(),
                    txtChapterName.Text.Trim(),
                    string.IsNullOrWhiteSpace(txtOrderNo.Text) ? "0" : txtOrderNo.Text.Trim(),
                    SocietyId, InstituteId
                );

                hfChapterId.Value = "";
                txtChapterName.Text = "";
                txtOrderNo.Text = "";
                litChapterModalTitle.Text = "Add Chapter";

                BindChapters(subjectId);
                SetToast("Chapter saved successfully.", "success");
            }
            catch (Exception ex)
            {
                ShowMsg("Error saving chapter: " + ex.Message, "danger");
            }
        }

        // ── Upload content (video or material) ────────────────────────────────
        protected void btnUploadSave_Click(object sender, EventArgs e)
        {
            try
            {
                if (!fuContent.HasFile)
                {
                    ShowMsg("Please select a file to upload.", "warning");
                    return;
                }
                if (string.IsNullOrWhiteSpace(txtContentTitle.Text))
                {
                    ShowMsg("Please provide a title.", "warning");
                    return;
                }
                if (!int.TryParse(ddlChapters.SelectedValue, out int chapterId))
                {
                    ShowMsg("Please select a valid chapter.", "warning");
                    return;
                }

                string ext = Path.GetExtension(fuContent.FileName).ToLower();
                string safeFile = Path.GetFileNameWithoutExtension(fuContent.FileName)
                                     .Replace(" ", "_")
                                     .Replace("..", "") + "_" + DateTime.Now.Ticks + ext;

                string contentType = ddlContentType.SelectedValue;
                string folder = contentType == "Video" ? "~/Uploads/Videos/" : "~/Uploads/Materials/";
                string physPath = Server.MapPath(folder);

                if (!Directory.Exists(physPath)) Directory.CreateDirectory(physPath);

                string fullPath = Path.Combine(physPath, safeFile);
                fuContent.SaveAs(fullPath);
                string dbPath = folder.Replace("~", "") + safeFile;

                int subjectId = Convert.ToInt32(hfSubjectId.Value);

                if (contentType == "Video")
                {
                    ValidateVideoFile(ext);

                    int instructorId = 0;
                    int.TryParse(hfInstructorId.Value, out instructorId);

                    int newVideoId = _bl.InsertVideo(
                        SocietyId, InstituteId, SessionId, chapterId, subjectId,
                        txtContentTitle.Text.Trim(),
                        txtVideoDesc.Text.Trim(),
                        dbPath, instructorId, UserId
                    );

                    string[] times = Request.Form.GetValues("topicTime");
                    string[] titles = Request.Form.GetValues("topicTitle");

                    if (times != null && titles != null)
                        _bl.InsertVideoTopics(SocietyId, InstituteId, SessionId, newVideoId, times, titles);

                    // Notify enrolled students
                    _bl.NotifyStudents(SocietyId, InstituteId, SessionId, subjectId,
                        $"New video uploaded: {txtContentTitle.Text.Trim()}");
                }
                else
                {
                    _bl.InsertMaterial(SocietyId, InstituteId, SessionId, chapterId,
                        txtContentTitle.Text.Trim(), dbPath, ext);

                    _bl.NotifyStudents(SocietyId, InstituteId, SessionId, subjectId,
                        $"New material uploaded: {txtContentTitle.Text.Trim()}");
                }

                // Log admin activity
                _bl.LogActivity(UserId, SocietyId, InstituteId, SessionId,
                    $"Uploaded {contentType}: {txtContentTitle.Text.Trim()}");

                // Reset form
                txtContentTitle.Text = "";
                txtVideoDesc.Text = "";
                hfInstructorId.Value = "";

                BindChapters(subjectId);
                SetToast($"{contentType} uploaded successfully! Students notified.", "success");
            }
            catch (InvalidOperationException ioex)
            {
                ShowMsg(ioex.Message, "warning");
            }
            catch (Exception ex)
            {
                ShowMsg("Upload failed: " + ex.Message, "danger");
            }
        }

        // ── Helper: file type validation ──────────────────────────────────────
        private void ValidateVideoFile(string ext)
        {
            string[] allowed = { ".mp4", ".webm", ".ogg", ".avi", ".mov", ".mkv", ".flv", ".wmv" };
            bool valid = false;
            foreach (string a in allowed) if (ext == a) { valid = true; break; }
            if (!valid) throw new InvalidOperationException("Invalid video format. Allowed: mp4, webm, ogg, avi, mov, mkv.");
        }

        // ── Teacher search (AJAX GET endpoint) ───────────────────────────────
        // Called by JS fetch: SubjectDetails.aspx/SearchTeachers?q=&subjectId=
        protected void Page_PreRender(object sender, EventArgs e)
        {
            if (Request.QueryString["action"] == "SearchTeachers")
            {
                string q = (Request.QueryString["q"] ?? "").Trim();
                string subjectIdQ = Request.QueryString["subjectId"] ?? "0";
                int.TryParse(subjectIdQ, out int sId);

                DataTable dt = _bl.SearchTeachersForSubject(q, sId, InstituteId, SessionId);
                Response.Clear();
                Response.ContentType = "application/json";

                var sb = new System.Text.StringBuilder("[");
                bool first = true;
                if (dt != null)
                {
                    foreach (DataRow row in dt.Rows)
                    {
                        if (!first) sb.Append(",");
                        sb.Append($"{{\"UserId\":{row["UserId"]},\"Name\":\"{row["FullName"].ToString().Replace("\"", "\\\"")}\",\"Designation\":\"{row["Designation"]?.ToString().Replace("\"", "\\\"") ?? ""}\"}}");
                        first = false;
                    }
                }
                sb.Append("]");
                Response.Write(sb.ToString());
                Response.End();
            }
        }

        // ── Code-behind helpers for ASPX markup ──────────────────────────────
        protected string GetFileIcon(string ext)
        {
            switch ((ext ?? "").ToLower().Trim('.'))
            {
                case "pdf": return "pdf";
                case "doc": case "docx": return "doc";
                case "ppt": case "pptx": return "ppt";
                case "jpg": case "jpeg": case "png": case "gif": case "webp": return "img";
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
                case "jpg": case "jpeg": case "png": case "gif": case "webp": return "fa fa-file-image";
                case "xls": case "xlsx": return "fa fa-file-excel";
                case "zip": case "rar": return "fa fa-file-archive";
                default: return "fa fa-file-alt";
            }
        }

        // ── Show messages / toasts ────────────────────────────────────────────
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