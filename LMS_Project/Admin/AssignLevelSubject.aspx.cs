using LearningManagementSystem.BL;
using LearningManagementSystem.GC;
using System;
using System.Data;
using System.Web.UI.WebControls;

namespace LearningManagementSystem.Admin
{
    public partial class AssignLevelSubject : System.Web.UI.Page
    {
        AssignLevelSubjectBL bl = new AssignLevelSubjectBL();

        int InstituteId => Convert.ToInt32(Session["InstituteId"]);
        int SocietyId => Convert.ToInt32(Session["SocietyId"]);
        int CurrentSessionId => bl.GetCurrentSession(InstituteId);

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["InstituteId"] == null)
            {
                Response.Redirect("~/Default.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadStreams();
                LoadLevels();
                LoadSemesters();
                LoadSubjects();
            }
        }


        private void LoadStreams()
        {
            ddlStream.DataSource = bl.GetStreams(InstituteId);
            ddlStream.DataTextField = "StreamName";
            ddlStream.DataValueField = "StreamId";
            ddlStream.DataBind();

            ddlStream.Items.Insert(0, new ListItem("--Select Stream--", "0"));
        }

        private void LoadCourses()
        {
            ddlCourse.DataSource = bl.GetCourses(Convert.ToInt32(ddlStream.SelectedValue));
            ddlCourse.DataTextField = "CourseName";
            ddlCourse.DataValueField = "CourseId";
            ddlCourse.DataBind();

            ddlCourse.Items.Insert(0, new ListItem("--Select Course--", "0"));
        }

        private void LoadLevels()
        {
            ddlLevel.DataSource = bl.GetLevels(InstituteId);
            ddlLevel.DataTextField = "LevelName";
            ddlLevel.DataValueField = "LevelId";
            ddlLevel.DataBind();

            ddlLevel.Items.Insert(0, new ListItem("--Select Level--", "0"));
        }

        private void LoadSemesters()
        {
            ddlSemester.DataSource = bl.GetSemesters(InstituteId);
            ddlSemester.DataTextField = "SemesterName";
            ddlSemester.DataValueField = "SemesterId";
            ddlSemester.DataBind();

            ddlSemester.Items.Insert(0, new ListItem("--Select Semester--", "0"));
        }
        protected void ddlStream_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadCourses();
        }
        private void LoadSubjects()
        {
            gvSubjects.DataSource = bl.GetSubjects(InstituteId);
            gvSubjects.DataBind();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            foreach (GridViewRow row in gvSubjects.Rows)
            {
                CheckBox chk = (CheckBox)row.FindControl("chkSelect");

                if (chk.Checked)
                {
                    int subjectId = Convert.ToInt32(gvSubjects.DataKeys[row.RowIndex].Value);

                    bool isMandatory =
                    ((CheckBox)row.FindControl("chkMandatory")).Checked;

                    LevelSemesterSubjectGC obj = new LevelSemesterSubjectGC
                    {
                        SocietyId = SocietyId,
                        InstituteId = InstituteId,
                        SessionId = CurrentSessionId,
                        StreamId = Convert.ToInt32(ddlStream.SelectedValue),
                        CourseId = Convert.ToInt32(ddlCourse.SelectedValue),
                        LevelId = Convert.ToInt32(ddlLevel.SelectedValue),
                        SemesterId = Convert.ToInt32(ddlSemester.SelectedValue),
                        SubjectId = subjectId,
                        IsMandatory = isMandatory
                    };

                    bl.InsertLevelSubject(obj);
                }
            }

            lblMsg.Text = "Subjects Assigned Successfully";
        }
    }
}