using System;
using System.Data;
using System.IO;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace LearningManagementSystem.Admin
{
    public partial class SubjectDetails : Page
    {
        SubjectDetailsBL bl = new SubjectDetailsBL();

        int SocietyId => Convert.ToInt32(Session["SocietyId"]);
        int InstituteId => Convert.ToInt32(Session["InstituteId"]);
        int UserId => Convert.ToInt32(Session["UserId"]);

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["InstituteId"] == null)
            {
                Response.Redirect("~/Default.aspx");
                return;
            }
            if (!IsPostBack)
            {
                if (Request.QueryString["SubjectId"] != null)
                {
                    hfSubjectId.Value = Request.QueryString["SubjectId"];
                    LoadSubject();
                    BindChapters();
                }
                else
                {
                    Response.Redirect("Subjects.aspx");
                }
            }
        }

        private void LoadSubject()
        {
            DataTable dt = bl.GetSubjectDetails(Convert.ToInt32(hfSubjectId.Value));

            if (dt.Rows.Count > 0)
            {
                DataRow r = dt.Rows[0];

                litSubjectName.Text = "<strong>" + r["SubjectName"] + "</strong>";
                litSubjectCode.Text = r["SubjectCode"].ToString();
                litDuration.Text = r["Duration"].ToString();
                litStatus.Text = Convert.ToBoolean(r["IsActive"])
                    ? "<span class='badge bg-success'>Active</span>"
                    : "<span class='badge bg-danger'>Inactive</span>";

                litSociety.Text = r["SocietyName"].ToString();
                litInstitute.Text = r["InstituteName"].ToString();
                litStream.Text = r["StreamName"].ToString();
                litCourse.Text = r["CourseName"].ToString();
                litLevel.Text = r["LevelName"].ToString();
                litSemester.Text = r["SemesterName"].ToString();
                litDescription.Text = r["Description"].ToString();
            }
        }

        private void BindChapters()
        {
            DataTable dt = bl.GetChapters(Convert.ToInt32(hfSubjectId.Value));

            rptChapters.DataSource = dt;
            rptChapters.DataBind();

            ddlChapters.DataSource = dt;
            ddlChapters.DataTextField = "ChapterName";
            ddlChapters.DataValueField = "ChapterId";
            ddlChapters.DataBind();
        }

        // ================= BIND VIDEOS & MATERIALS =================
        protected void rptChapters_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item ||
                e.Item.ItemType == ListItemType.AlternatingItem)
            {
                string chapterId = ((HiddenField)e.Item.FindControl("hfRowChapterId")).Value;

                Repeater rptVideos = (Repeater)e.Item.FindControl("rptVideos");
                Repeater rptMaterials = (Repeater)e.Item.FindControl("rptMaterials");

                rptVideos.DataSource = bl.GetVideosByChapter(Convert.ToInt32(chapterId));
                rptVideos.DataBind();

                rptMaterials.DataSource = bl.GetMaterialsByChapter(Convert.ToInt32(chapterId));
                rptMaterials.DataBind();
            }
        }

        // ================= SAVE CHAPTER =================
        protected void btnSaveChapter_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtChapterName.Text))
            {
                ShowMsg("Chapter name required", false);
                return;
            }

            bl.SaveChapter(
                hfChapterId.Value,
                hfSubjectId.Value,
                txtChapterName.Text.Trim(),
                txtOrderNo.Text.Trim()
            );

            hfChapterId.Value = "";
            txtChapterName.Text = "";
            txtOrderNo.Text = "";

            BindChapters();
            ShowMsg("Chapter Saved Successfully", true);
        }

        // ================= EDIT / DELETE CHAPTER =================
        protected void rptChapters_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int id = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "EditChapter")
            {
                DataTable dt = bl.GetChapterById(id);

                if (dt.Rows.Count > 0)
                {
                    hfChapterId.Value = id.ToString();
                    txtChapterName.Text = dt.Rows[0]["ChapterName"].ToString();
                    txtOrderNo.Text = dt.Rows[0]["OrderNo"].ToString();

                    ScriptManager.RegisterStartupScript(this, GetType(),
                        "modal", "showChapterModal();", true);
                }
            }
            else if (e.CommandName == "DeleteChapter")
            {
                bl.DeleteChapter(id);

                BindChapters();
                ShowMsg("Chapter Deleted Successfully", true);
            }
        }

        // ================= UPLOAD CONTENT =================
        protected void btnUploadSave_Click(object sender, EventArgs e)
        {
            if (!fuContent.HasFile)
            {
                ShowMsg("Please select file", false);
                return;
            }

            try
            {
                string fileName = Path.GetFileName(fuContent.FileName);

                string folderRelPath =
                    ddlContentType.SelectedValue == "Video"
                    ? "~/Uploads/Videos/"
                    : "~/Uploads/Materials/";

                string physicalPath = Server.MapPath(folderRelPath);

                if (!Directory.Exists(physicalPath))
                    Directory.CreateDirectory(physicalPath);

                string fullPath = Path.Combine(physicalPath, fileName);
                fuContent.SaveAs(fullPath);

                string dbPath = folderRelPath.Replace("~", "..") + fileName;

                if (ddlContentType.SelectedValue == "Video")
                {
                    int newVideoId = bl.InsertVideo(
                        SocietyId,
                        InstituteId,
                        Convert.ToInt32(ddlChapters.SelectedValue),
                        txtContentTitle.Text.Trim(),
                        txtVideoDesc.Text.Trim(),
                        dbPath,
                        txtInstructor.Text.Trim(),
                        UserId
                    );

                    string[] times = Request.Form.GetValues("topicTime");
                    string[] titles = Request.Form.GetValues("topicTitle");

                    if (times != null && titles != null)
                    {
                        bl.InsertVideoTopics(
                            SocietyId,
                            InstituteId,
                            newVideoId,
                            times,
                            titles
                        );
                    }
                }
                else
                {
                    bl.InsertMaterial(
                        SocietyId,
                        InstituteId,
                        Convert.ToInt32(ddlChapters.SelectedValue),
                        txtContentTitle.Text.Trim(),
                        dbPath,
                        Path.GetExtension(fileName)
                    );
                }

                txtContentTitle.Text = "";
                txtVideoDesc.Text = "";
                txtInstructor.Text = "";

                BindChapters();
                ShowMsg("Uploaded Successfully", true);
            }
            catch (Exception ex)
            {
                ShowMsg("Error: " + ex.Message, false);
            }
        }

        private void ShowMsg(string msg, bool success)
        {
            lblMsg.Text = msg;
            lblMsg.CssClass = success ? "alert alert-success" : "alert alert-danger";
            lblMsg.Visible = true;
        }
    }
}