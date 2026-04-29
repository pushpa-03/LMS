//using System;
//using System.Data;
//using System.Web;
//using System.Web.Services;

//namespace LMS_Project.Admin
//{
//    public partial class MaterialPlayer : System.Web.UI.Page
//    {
//        MaterialBL bl = new MaterialBL();
//        int UserId => Session["UserId"] != null ? Convert.ToInt32(Session["UserId"]) : 0;

//        protected void Page_Load(object sender, EventArgs e)
//        {
//            if (UserId == 0) Response.Redirect("../Default.aspx");

//            if (!IsPostBack)
//            {
//                string mId = Request.QueryString["MaterialId"];
//                if (!string.IsNullOrEmpty(mId))
//                {
//                    int materialId = Convert.ToInt32(mId);
//                    LoadMaterial(materialId);
//                    LoadHistory(materialId);
//                    lnkEdit.NavigateUrl = "AddMaterial.aspx?MaterialId=" + materialId;
//                }
//            }
//        }

//        void LoadMaterial(int id)
//        {
//            DataTable dt = bl.GetMaterialById(id);
//            if (dt != null && dt.Rows.Count > 0)
//            {
//                lblTitle.Text = dt.Rows[0]["Title"].ToString();
//                string path = dt.Rows[0]["FilePath"].ToString();
//                string type = dt.Rows[0]["FileType"].ToString().ToLower();

//                hfFilePath.Value = path;
//                downloadLink.HRef = path;

//                if (type == ".pdf")
//                    fileViewer.InnerHtml = $"<iframe src='{path}' width='100%' height='100%'></iframe>";
//                else if (type == ".jpg" || type == ".png" || type == ".jpeg")
//                    fileViewer.InnerHtml = $"<img src='{path}' class='img-fluid' style='max-height:550px;' />";
//                else
//                    fileViewer.InnerHtml = $"<iframe src='https://view.officeapps.live.com/op/embed.aspx?src={Request.Url.GetLeftPart(UriPartial.Authority) + path}' width='100%' height='100%'></iframe>";
//            }
//        }

//        void LoadHistory(int id)
//        {
//            // Passing 0 usually indicates 'Get All' in your BL for Admins
//            rptHistory.DataSource = bl.GetHistory(id, 0);
//            rptHistory.DataBind();
//        }

//        [WebMethod]
//        public static string SaveToHistory(string materialId, string type, string question, string response)
//        {
//            try
//            {
//                MaterialBL bl = new MaterialBL();
//                int userId = Convert.ToInt32(HttpContext.Current.Session["UserId"]);

//                bl.SaveAIHistory(new MaterialGC
//                {
//                    MaterialId = Convert.ToInt32(materialId),
//                    UserId = userId,
//                    Type = type,
//                    Question = question,
//                    Response = response
//                });
//                return "Saved";
//            }
//            catch { return "Error"; }
//        }
//    }
//}

//-----------------------------------------------------------------------------------------------------------------------------------------------

using System;
using System.Collections.Generic;
using System.Data;
using System.Web;
using System.Web.Services;
using System.Web.UI.WebControls;

namespace LearningManagementSystem.Admin
{
    public partial class MaterialPlayer : BasePage
    {
        private readonly MaterialBL _bl = new MaterialBL();

        protected void Page_Load(object sender, EventArgs e)
        {
            try
            {
                if (!int.TryParse(Request.QueryString["MaterialId"], out int materialId) || materialId <= 0)
                {
                    ShowMsg("Invalid or missing Material ID.", "warning");
                    return;
                }

                if (!IsPostBack)
                {
                    hfMaterialId.Value = materialId.ToString();
                    LoadMaterial(materialId);
                    LoadHistory(materialId);
                    LogActivity(materialId);
                }
            }
            catch (Exception ex)
            {
                ShowMsg("Error loading material: " + ex.Message, "danger");
            }
        }

        // ── Load material & render viewer ─────────────────────────────────────
        private void LoadMaterial(int materialId)
        {
            DataTable dt = _bl.GetMaterialById(materialId);

            if (dt == null || dt.Rows.Count == 0)
            {
                ShowMsg("Material not found.", "warning");
                return;
            }

            DataRow r = dt.Rows[0];

            string title = r["Title"]?.ToString() ?? "Material";
            string rawPath = r["FilePath"]?.ToString() ?? "";
            string ext = (r["FileType"]?.ToString() ?? ".file").ToLower().Trim('.');
            string chapter = r["ChapterName"]?.ToString() ?? "—";
            string subject = r["SubjectName"]?.ToString() ?? "—";
            string uploaded = r["UploadedOn"] != DBNull.Value
                              ? Convert.ToDateTime(r["UploadedOn"]).ToString("dd MMM yyyy")
                              : "—";

            litTitle.Text = Server.HtmlEncode(title);
            toolbarTitle.InnerText = title;
            toolbarMeta.InnerHtml = $"<i class='fa fa-calendar me-1'></i>Uploaded: {uploaded}";
            lnkDownload.HRef = rawPath;
            hfFilePath.Value = rawPath;
            hfFileType.Value = ext;

            // File type badge
            string badgeClass = GetBadgeClass(ext);
            fileBadge.InnerText = "." + ext.ToUpper();
            fileBadge.Attributes["class"] = "file-badge " + badgeClass;

            // Render the viewer HTML
            fileViewer.InnerHtml = BuildViewer(rawPath, ext, title);

            // Info rows
            var infoRows = new[]
            {
                new { Label = "Title",     Value = title   },
                new { Label = "Chapter",   Value = chapter },
                new { Label = "Subject",   Value = subject },
                new { Label = "File Type", Value = "." + ext.ToUpper() },
                new { Label = "Uploaded",  Value = uploaded }
            };

            var infoTable = new DataTable();
            infoTable.Columns.Add("Label");
            infoTable.Columns.Add("Value");
            foreach (var row in infoRows)
            {
                DataRow nr = infoTable.NewRow();
                nr["Label"] = row.Label;
                nr["Value"] = row.Value;
                infoTable.Rows.Add(nr);
            }
            rptInfo.DataSource = infoTable;
            rptInfo.DataBind();
        }

        // ── Build viewer HTML based on file type ──────────────────────────────
        private string BuildViewer(string path, string ext, string title)
        {
            string safeTitle = Server.HtmlEncode(title);
            string absUrl = GetAbsoluteUrl(path);

            switch (ext)
            {
                case "pdf":
                    return $"<iframe src='{absUrl}#toolbar=1&navpanes=1' width='100%' height='100%' title='{safeTitle}'></iframe>";

                case "jpg":
                case "jpeg":
                case "png":
                case "gif":
                case "webp":
                case "svg":
                    return $"<img src='{absUrl}' alt='{safeTitle}' style='width:100%;height:100%;object-fit:contain;background:#f8f9fa' />";

                case "mp4":
                case "webm":
                case "ogg":
                case "mov":
                    return $"<video src='{absUrl}' controls style='width:100%;height:100%;background:#000'></video>";

                case "mp3":
                case "wav":
                case "ogg_audio":
                    return $@"<div style='display:flex;flex-direction:column;align-items:center;justify-content:center;height:100%;gap:16px;background:#f8f9fa'>
                                <i class='fa fa-music' style='font-size:4rem;color:var(--accent);opacity:.4'></i>
                                <p style='font-weight:600;color:var(--ink)'>{safeTitle}</p>
                                <audio src='{absUrl}' controls style='width:80%'></audio>
                              </div>";

                case "doc":
                case "docx":
                case "ppt":
                case "pptx":
                case "xls":
                case "xlsx":
                    // Office Online viewer
                    string officeUrl = $"https://view.officeapps.live.com/op/embed.aspx?src={Uri.EscapeDataString(absUrl)}";
                    return $"<iframe src='{officeUrl}' width='100%' height='100%' title='{safeTitle}' frameborder='0'></iframe>";

                case "txt":
                case "md":
                case "csv":
                    return $"<iframe src='{absUrl}' width='100%' height='100%' style='background:#fff;font-family:monospace'></iframe>";

                default:
                    return $@"<div class='unsupported-box'>
                                <i class='fa fa-file-alt'></i>
                                <h5>Preview not available</h5>
                                <p style='font-size:.85rem'>File type <strong>.{ext.ToUpper()}</strong> cannot be previewed in browser.</p>
                                <a href='{absUrl}' class='btn-action primary' target='_blank' style='display:inline-flex;align-items:center;gap:6px;margin-top:8px'>
                                    <i class='fa fa-download'></i> Download to view
                                </a>
                              </div>";
            }
        }

        private string GetAbsoluteUrl(string path)
        {
            if (string.IsNullOrEmpty(path)) return "#";
            string resolved = ResolveUrl(path.Replace("..", "~"));
            return $"{Request.Url.GetLeftPart(UriPartial.Authority)}{resolved}";
        }

        private string GetBadgeClass(string ext)
        {
            switch (ext)
            {
                case "pdf": return "pdf";
                case "doc": case "docx": return "doc";
                case "ppt": case "pptx": return "ppt";
                case "xls": case "xlsx": return "xls";
                case "jpg": case "jpeg": case "png": case "gif": case "webp": return "img";
                case "mp4": case "webm": case "mov": return "vid";
                default: return "gen";
            }
        }

        // ── Load AI history (all students for admin view) ─────────────────────
        private void LoadHistory(int materialId)
        {
            try
            {
                DataTable dt = _bl.GetAllHistory(materialId);
                rptHistory.DataSource = dt;
                rptHistory.DataBind();
            }
            catch (Exception ex)
            {
                ShowMsg("Error loading history: " + ex.Message, "danger");
            }
        }

        // ── Log admin activity ────────────────────────────────────────────────
        private void LogActivity(int materialId)
        {
            try { _bl.LogActivity(UserId, SocietyId, InstituteId, SessionId, "MaterialView", materialId); }
            catch { }
        }

        // ═══════════════════════════════════════════════════════════════════════
        //  AJAX WEB METHOD – called by JavaScript
        // ═══════════════════════════════════════════════════════════════════════

        [WebMethod(EnableSession = true)]
        public static string SaveToHistory(int materialId, string type, string question, string response)
        {
            try
            {
                int userId = 0;
                if (HttpContext.Current.Session["UserId"] != null)
                    int.TryParse(HttpContext.Current.Session["UserId"].ToString(), out userId);

                if (userId == 0) return "unauthorized";

                new MaterialBL().SaveAIHistory(materialId, userId, type,
                    question ?? "", response ?? "");
                return "saved";
            }
            catch (Exception ex) { return "error:" + ex.Message; }
        }

        private void ShowMsg(string msg, string type)
        {
            lblMsg.Text = msg;
            lblMsg.CssClass = $"alert alert-{type} alert-auto d-block mb-3";
            lblMsg.Visible = true;
        }
    }
}