using System;
using System.Data;
using System.IO;
using System.Runtime.InteropServices.ComTypes;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace LearningManagementSystem.Admin
{
    public partial class SubjectDetails : BasePage
    {
        SubjectDetailsBL bl = new SubjectDetailsBL();

        int UserId => UserId;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (SessionId == 0)
                {
                    lblMsg.Text = "No active academic session found!";
                    lblMsg.Visible = true;
                    return;
                }

                if (Request.QueryString["SubjectId"] != null &&
                    int.TryParse(Request.QueryString["SubjectId"], out int subjectId))
                {
                    hfSubjectId.Value = subjectId.ToString();

                    LoadSubject();
                    BindChapters();
                    BindSubjectAssignments();
                }
                else
                {
                    Response.Redirect("Subjects.aspx");
                }
            }
        }
        private void LoadSubject()
        {
            DataTable dt = bl.GetSubjectDetails(Convert.ToInt32(hfSubjectId.Value), SessionId);

            if (dt != null && dt.Rows.Count > 0)
            {
                DataRow r = dt.Rows[0];

                litSubjectName.Text = "<strong>" + r["SubjectName"] + "</strong>";
                litSubjectCode.Text = r["SubjectCode"]?.ToString() ?? "";
                litDuration.Text = r["Duration"]?.ToString() ?? "";

                litStatus.Text = Convert.ToBoolean(r["IsActive"])
                    ? "<span class='badge bg-success'>Active</span>"
                    : "<span class='badge bg-danger'>Inactive</span>";

                litSociety.Text = r["SocietyName"]?.ToString() ?? "";
                litInstitute.Text = r["InstituteName"]?.ToString() ?? "";
                litStream.Text = r["StreamName"]?.ToString() ?? "";
                litCourse.Text = r["CourseName"]?.ToString() ?? "";
                litLevel.Text = r["LevelName"]?.ToString() ?? "";
                litSemester.Text = r["SemesterName"]?.ToString() ?? "";
                litDescription.Text = r["Description"]?.ToString() ?? "";
            }
        }

        private void BindChapters()
        {
            DataTable dt = bl.GetChapters(Convert.ToInt32(hfSubjectId.Value),SessionId);

            rptChapters.DataSource = dt;
            rptChapters.DataBind();

            if (dt != null && dt.Rows.Count > 0)
            {
                ddlChapters.DataSource = dt;
                ddlChapters.DataTextField = "ChapterName";
                ddlChapters.DataValueField = "ChapterId";
                ddlChapters.DataBind();
            }
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

                rptVideos.DataSource = bl.GetVideosByChapter(Convert.ToInt32(chapterId),SessionId);
                rptVideos.DataBind();

                rptMaterials.DataSource = bl.GetMaterialsByChapter(Convert.ToInt32(chapterId),SessionId);
                rptMaterials.DataBind();


                //Repeater rptAssignments = (Repeater)e.Item.FindControl("rptAssignments");

                //rptAssignments.DataSource = bl.GetAssignmentsBySubject(
                //    Convert.ToInt32(hfSubjectId.Value)
                //);
                //rptAssignments.DataBind();
            }
        }

        private void BindSubjectAssignments()
        {
            try
            {
                // Use the Subject ID from your HiddenField
                int subjectId = Convert.ToInt32(hfSubjectId.Value);

                // Bind directly to the Repeater that is now outside the chapters
                rptAssignments.DataSource = bl.GetAssignmentsBySubject(subjectId,SessionId);
                rptAssignments.DataBind();
            }
            catch (Exception ex)
            {
                lblMsg.Text = "Error loading assignments: " + ex.Message;
                lblMsg.Visible = true;
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
                SessionId,
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
                DataTable dt = bl.GetChapterById(id,SessionId);

                if (dt != null && dt.Rows.Count > 0)
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
                bl.DeleteChapter(id,SessionId);

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

                string dbPath = folderRelPath.Replace("~", "") + fileName;


                if (ddlContentType.SelectedValue == "Video")
                {
                    if (!int.TryParse(ddlChapters.SelectedValue, out int chapterId))
                    {
                        ShowMsg("Invalid chapter selected", false);
                        return;
                    }

                    int newVideoId = bl.InsertVideo(
                        SocietyId,
                        InstituteId,
                        SessionId,
                        chapterId,
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
                             SessionId,
                             newVideoId,
                             times,
                             titles
                         );
                    }
                }
                else
                {
                    // ✅ Validate first
                    if (!int.TryParse(ddlChapters.SelectedValue, out int chapterId))
                    {
                        ShowMsg("Invalid chapter selected", false);
                        return;
                    }

                    // ✅ Then call method
                    bl.InsertMaterial(
                         SocietyId,
                         InstituteId,
                         SessionId,
                         chapterId,
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