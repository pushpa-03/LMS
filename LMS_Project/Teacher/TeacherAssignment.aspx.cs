using LearningManagementSystem.BL;
using LearningManagementSystem.GC;
using System;
using System.Data;
using System.IO;
using System.Web.UI.WebControls;

namespace LearningManagementSystem.Teacher
{
    public partial class TeacherAssignment : System.Web.UI.Page
    {
        AssignmentBL bl = new AssignmentBL();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null ||
                Session["InstituteId"] == null ||
                Session["SocietyId"] == null)
            {
                Response.Redirect("~/Default.aspx");
                return;
            }

            if (!IsPostBack)
            {
                btnSave.Text = "Create Assignment";

                LoadSubjects();

                // ✅ Initialize Chapter dropdown
                ddlChapter.Items.Clear();
                ddlChapter.Items.Insert(0,
                    new ListItem("-- Select Chapter (Optional) --", "0"));

                LoadAssignments();
            }
        }

        // ================= LOAD SUBJECTS =================
        private void LoadSubjects()
        {
            int userId = Convert.ToInt32(Session["UserId"]);
            int instituteId = Convert.ToInt32(Session["InstituteId"]);

            DataTable dt = bl.GetTeacherSubjects(userId, instituteId);

            ddlSubject.DataSource = dt;
            ddlSubject.DataTextField = "SubjectName";
            ddlSubject.DataValueField = "SubjectId";
            ddlSubject.DataBind();

            ddlSubject.Items.Insert(0,
                new ListItem("-- Select Subject --", "0"));
        }

        // ================= SUBJECT CHANGE → LOAD CHAPTERS =================
        protected void ddlSubject_SelectedIndexChanged(object sender, EventArgs e)
        {
            int subjectId = Convert.ToInt32(ddlSubject.SelectedValue);

            ddlChapter.Items.Clear();

            if (subjectId == 0)
            {
                ddlChapter.Items.Insert(0,
                    new ListItem("-- Select Chapter (Optional) --", "0"));
                return;
            }

            int instituteId = Convert.ToInt32(Session["InstituteId"]);
            int societyId = Convert.ToInt32(Session["SocietyId"]);

            DataTable dt = bl.GetChaptersBySubject(subjectId, instituteId, societyId);

            ddlChapter.DataSource = dt;
            ddlChapter.DataTextField = "ChapterName";
            ddlChapter.DataValueField = "ChapterId";
            ddlChapter.DataBind();

            ddlChapter.Items.Insert(0,
                new ListItem("-- Select Chapter (Optional) --", "0"));
        }

        // ================= LOAD ASSIGNMENTS =================
        private void LoadAssignments()
        {
            int userId = Convert.ToInt32(Session["UserId"]);
            int instituteId = Convert.ToInt32(Session["InstituteId"]);
            int societyId = Convert.ToInt32(Session["SocietyId"]);

            DataTable dt = bl.GetTeacherAssignments(userId, instituteId, societyId);

            if (dt.Rows.Count > 0)
            {
                rptAssignments.DataSource = dt;
                rptAssignments.DataBind();

                lblAssignmentCount.Text = dt.Rows.Count.ToString();

                pnlAssignments.Visible = true;
                pnlEmpty.Visible = false;
            }
            else
            {
                pnlAssignments.Visible = false;
                pnlEmpty.Visible = true;
            }
        }

        // ================= SAVE ASSIGNMENT =================
        protected void btnSave_Click(object sender, EventArgs e)
        {
            // ❗ SUBJECT VALIDATION
            if (ddlSubject.SelectedValue == "0")
            {
                Response.Write("<script>alert('Please select a subject');</script>");
                return;
            }

            // ❗ FILE MANDATORY (IMPORTANT FIX)
            if (!fuAssignment.HasFile)
            {
                Response.Write("<script>alert('File is mandatory for assignment');</script>");
                return;
            }

            // ================= FILE UPLOAD =================
            string folderPath = Server.MapPath("~/Uploads/Assignments/");
            if (!Directory.Exists(folderPath))
                Directory.CreateDirectory(folderPath);

            string fileName = Guid.NewGuid().ToString() + "_" +
                              Path.GetFileName(fuAssignment.FileName);

            string fullPath = Path.Combine(folderPath, fileName);
            fuAssignment.SaveAs(fullPath);

            string filePath = "~/Uploads/Assignments/" + fileName;

            // ================= CREATE OBJECT =================
            AssignmentGC obj = new AssignmentGC
            {
                SocietyId = Convert.ToInt32(Session["SocietyId"]),
                InstituteId = Convert.ToInt32(Session["InstituteId"]),
                SubjectId = Convert.ToInt32(ddlSubject.SelectedValue),

                // ✅ NEW: Chapter (Optional)
                ChapterId = ddlChapter.SelectedValue == "0"
                            ? (int?)null
                            : Convert.ToInt32(ddlChapter.SelectedValue),

                Title = txtTitle.Text.Trim(),
                Description = string.IsNullOrWhiteSpace(txtDescription.Text)
                                ? null
                                : txtDescription.Text.Trim(),

                FilePath = filePath,

                DueDate = string.IsNullOrEmpty(txtDueDate.Text)
                            ? (DateTime?)null
                            : Convert.ToDateTime(txtDueDate.Text),

                MaxMarks = string.IsNullOrEmpty(txtMarks.Text)
                            ? (int?)null
                            : Convert.ToInt32(txtMarks.Text),

                CreatedBy = Convert.ToInt32(Session["UserId"])
            };

            bl.AddAssignment(obj);

            // ================= SUCCESS =================
            lblSuccessMessage.Text = "Assignment created successfully!";
            pnlSuccess.Visible = true;

            // ================= CLEAR FORM =================
            txtTitle.Text = "";
            txtDescription.Text = "";
            txtDueDate.Text = "";
            txtMarks.Text = "";

            ddlSubject.SelectedIndex = 0;

            ddlChapter.Items.Clear();
            ddlChapter.Items.Insert(0,
                new ListItem("-- Select Chapter (Optional) --", "0"));

            // ================= RELOAD =================
            LoadAssignments();
        }

        // ================= DUE BADGE =================
        protected string GetDueBadge(object dueDateObj)
        {
            if (dueDateObj == DBNull.Value || dueDateObj == null)
                return "";

            DateTime due = Convert.ToDateTime(dueDateObj);
            int days = (due.Date - DateTime.Today).Days;

            if (days < 0)
                return "<span class='pill pill-red'><i class='fas fa-exclamation-triangle'></i> Overdue</span>";

            if (days <= 3)
                return "<span class='pill pill-orange'><i class='fas fa-clock'></i> Due in " + days + " day(s)</span>";

            return "<span class='pill pill-green'><i class='fas fa-check'></i> Upcoming</span>";
        }
        protected void rptAssignments_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "DeleteAssignment")
            {
                int assignmentId = Convert.ToInt32(e.CommandArgument);

                bl.DeleteAssignment(assignmentId);
                lblSuccessMessage.Text = "Assignment deleted successfully!";
                pnlSuccess.Visible = true;

                // Refresh UI
                LoadAssignments();

                // Optional success message
                pnlSuccess.Visible = true;
            }
        }
    }
}