using LearningManagementSystem.BL;
using System;
using System.Data;
using System.Web.UI.WebControls;

namespace LearningManagementSystem.Admin
{
    public partial class AssignStudentSubject : System.Web.UI.Page
    {
        AssignStudentSubjectBL bl = new AssignStudentSubjectBL();

        int InstituteId => Convert.ToInt32(Session["InstituteId"]);
        int SocietyId => Convert.ToInt32(Session["SocietyId"]);
        int CurrentSessionId => bl.GetCurrentSession(InstituteId);

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadStreams();
                LoadLevels();
                LoadSemesters();
                LoadAssigned();
            }
        }

        void LoadStreams()
        {
            ddlStream.DataSource = bl.GetStreams(InstituteId);
            ddlStream.DataTextField = "StreamName";
            ddlStream.DataValueField = "StreamId";
            ddlStream.DataBind();
            ddlStream.Items.Insert(0, new ListItem("--Select--", "0"));
        }

        void LoadCourses()
        {
            ddlCourse.DataSource = bl.GetCourses(Convert.ToInt32(ddlStream.SelectedValue));
            ddlCourse.DataTextField = "CourseName";
            ddlCourse.DataValueField = "CourseId";
            ddlCourse.DataBind();
            ddlCourse.Items.Insert(0, new ListItem("--Select--", "0"));
        }

        void LoadLevels()
        {
            ddlLevel.DataSource = bl.GetLevels(InstituteId);
            ddlLevel.DataTextField = "LevelName";
            ddlLevel.DataValueField = "LevelId";
            ddlLevel.DataBind();
            ddlLevel.Items.Insert(0, new ListItem("--Select--", "0"));
        }

        void LoadSemesters()
        {
            ddlSemester.DataSource = bl.GetSemesters(InstituteId);
            ddlSemester.DataTextField = "SemesterName";
            ddlSemester.DataValueField = "SemesterId";
            ddlSemester.DataBind();
            ddlSemester.Items.Insert(0, new ListItem("--Select--", "0"));
        }

        protected void FilterChanged(object sender, EventArgs e)
        {
            if (ddlStream.SelectedValue != "0")
                LoadCourses();

            LoadSubjects(); // reactive subject loading
        }

        void LoadSubjects()
        {
            int stream = Convert.ToInt32(ddlStream.SelectedValue);
            int course = Convert.ToInt32(ddlCourse.SelectedValue);
            int level = Convert.ToInt32(ddlLevel.SelectedValue);
            int sem = Convert.ToInt32(ddlSemester.SelectedValue);

            DataTable subjects = bl.GetSubjects(
                InstituteId,
                CurrentSessionId,
                stream,
                course,
                level,
                sem);

            gvSubjects.DataSource = subjects;
            gvSubjects.DataBind();
        }

        protected void btnLoadSubjects_Click(object sender, EventArgs e)
        {
            int stream = Convert.ToInt32(ddlStream.SelectedValue);
            int course = Convert.ToInt32(ddlCourse.SelectedValue);
            int level = Convert.ToInt32(ddlLevel.SelectedValue);
            int sem = Convert.ToInt32(ddlSemester.SelectedValue);

            DataTable students = bl.GetStudents(
                InstituteId,
                CurrentSessionId,
                stream,
                course,
                level,
                sem);

            gvStudents.DataSource = students;
            gvStudents.DataBind();
        }

        protected void btnAssign_Click(object sender, EventArgs e)
        {
            DataTable sub = new DataTable();
            sub.Columns.Add("SubjectId");

            foreach (GridViewRow r in gvSubjects.Rows)
            {
                CheckBox chk = (CheckBox)r.FindControl("chkSelect");

                if (chk != null && chk.Checked)
                {
                    int id = Convert.ToInt32(
                        gvSubjects.DataKeys[r.RowIndex].Value);

                    sub.Rows.Add(id);
                }
            }

            if (sub.Rows.Count == 0)
            {
                lblMsg.Text = "Select subject.";
                lblMsg.CssClass = "alert alert-warning";
                return;
            }

            DataTable students = bl.GetStudents(
                InstituteId,
                CurrentSessionId,
                Convert.ToInt32(ddlStream.SelectedValue),
                Convert.ToInt32(ddlCourse.SelectedValue),
                Convert.ToInt32(ddlLevel.SelectedValue),
                Convert.ToInt32(ddlSemester.SelectedValue));

            bl.AssignSubjects(students, sub,
                SocietyId,
                InstituteId,
                CurrentSessionId);

            lblMsg.Text = "Subjects assigned successfully.";
            lblMsg.CssClass = "alert alert-success";

            LoadAssigned();
        }

        void LoadAssigned()
        {
            gvAssigned.DataSource =
                bl.GetAssigned(InstituteId, CurrentSessionId);

            gvAssigned.DataBind();
        }

        protected void gvAssigned_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "DeleteRow")
            {
                bl.Delete(Convert.ToInt32(e.CommandArgument));
                LoadAssigned();
            }
        }
    }
}