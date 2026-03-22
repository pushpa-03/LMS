using LearningManagementSystem.BL;
using LearningManagementSystem.GC;
using LMS_Project.Student;
using System;
using System.Data;
using System.IO;

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
                LoadSubjects();
                LoadAssignments();
            }
        }

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
                new System.Web.UI.WebControls.ListItem("-- Select Subject --", "0"));
        }

        private void LoadAssignments()
        {
            int userId = Convert.ToInt32(Session["UserId"]);
            int instituteId = Convert.ToInt32(Session["InstituteId"]);
            int societyId = Convert.ToInt32(Session["SocietyId"]);

            DataTable dt = bl.GetTeacherAssignments(userId, instituteId, societyId);

            rptAssignments.DataSource = dt;
            rptAssignments.DataBind();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (ddlSubject.SelectedValue == "0")
            {
                Response.Write("<script>alert('Please select a subject');</script>");
                return;
            }

            string filePath = null;

            if (fuAssignment.HasFile)
            {
                string folderPath = Server.MapPath("~/Uploads/Assignments/");
                if (!Directory.Exists(folderPath))
                    Directory.CreateDirectory(folderPath);

                string fileName = Guid.NewGuid().ToString() + "_" +
                                  Path.GetFileName(fuAssignment.FileName);

                string fullPath = Path.Combine(folderPath, fileName);
                fuAssignment.SaveAs(fullPath);

                filePath = "~/Uploads/Assignments/" + fileName;
            }

            AssignmentGC obj = new AssignmentGC
            {
                SocietyId = Convert.ToInt32(Session["SocietyId"]),
                InstituteId = Convert.ToInt32(Session["InstituteId"]),
                SubjectId = Convert.ToInt32(ddlSubject.SelectedValue),
                Title = txtTitle.Text.Trim(),
                Description = txtDescription.Text.Trim(),
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

            Response.Write("<script>alert('Assignment Created Successfully');</script>");

            // Clear form
            txtTitle.Text = "";
            txtDescription.Text = "";
            txtDueDate.Text = "";
            txtMarks.Text = "";
            ddlSubject.SelectedIndex = 0;

            LoadAssignments();
        }
    }
}