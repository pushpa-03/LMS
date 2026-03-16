using System;
using System.Data;
using System.Data.SqlClient;

namespace LearningManagementSystem.Admin
{
    public partial class AssignSubjectFaculty : System.Web.UI.Page
    {
        SubjectFacultyBL bl = new SubjectFacultyBL();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["InstituteId"] == null)
            {
                Response.Redirect("~/Default.aspx");
                return;
            }
           
            if (!IsPostBack)
            {
                LoadTeachers();
                LoadSubjects();
                LoadGrid();
            }
        }

        private int CurrentSessionId
        {
            get
            {
                if (Session["CurrentSessionId"] != null)
                    return Convert.ToInt32(Session["CurrentSessionId"]);

                int sessionId = bl.GetCurrentSession(
                    Convert.ToInt32(Session["InstituteId"]));

                if (sessionId == 0)
                {
                    lblMsg.Text = "No Current Academic Session Found. Please set one.";
                    lblMsg.CssClass = "alert alert-danger d-block";
                }

                return sessionId;
            }
        }
        private void LoadTeachers()
        {
            ddlTeacher.DataSource = bl.GetTeachers(
                Convert.ToInt32(Session["InstituteId"]));
            ddlTeacher.DataTextField = "FullName";
            ddlTeacher.DataValueField = "UserId";
            ddlTeacher.DataBind();
            ddlTeacher.Items.Insert(0, "-- Select Teacher --");
        }

        private void LoadSubjects()
        {
            ddlSubject.DataSource = bl.GetSubjects(
                Convert.ToInt32(Session["InstituteId"]));

            ddlSubject.DataTextField = "SubjectName";
            ddlSubject.DataValueField = "SubjectId";
            ddlSubject.DataBind();
            ddlSubject.Items.Insert(0, "-- Select Subject --");
        }

        private void LoadGrid()
        {
            gvAssign.DataSource = bl.GetAll(
            Convert.ToInt32(Session["InstituteId"]),
            CurrentSessionId);

            gvAssign.DataBind();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (ddlTeacher.SelectedIndex == 0 ||
                ddlSubject.SelectedIndex == 0)
            {
                ShowMsg("All fields required", false);
                return;
            }


            SubjectFacultyGC obj = new SubjectFacultyGC
            {
                SocietyId = Convert.ToInt32(Session["SocietyId"]),
                InstituteId = Convert.ToInt32(Session["InstituteId"]),
                SessionId = CurrentSessionId,   // ✅ automatic
                SubjectId = Convert.ToInt32(ddlSubject.SelectedValue),
                TeacherId = Convert.ToInt32(ddlTeacher.SelectedValue),
                AssignedBy = Convert.ToInt32(Session["UserId"])
            };

            try
            {
                bl.Insert(obj);
                ShowMsg("Assigned successfully!", true);
                LoadGrid();
            }
            catch (SqlException ex)
            {
                if (ex.Number == 2627 || ex.Number == 2601)
                    ShowMsg("This teacher is already assigned to this subject for this session.", false);
                else
                    ShowMsg("Database error: " + ex.Message, false);
            }
        }

        protected void gvAssign_RowCommand(object sender,
            System.Web.UI.WebControls.GridViewCommandEventArgs e)
        {
            int id = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "DeleteRow")
                bl.Delete(id);

            else if (e.CommandName == "Toggle")
                bl.Toggle(id);

            LoadGrid();
        }

        private void ShowMsg(string msg, bool success)
        {
            lblMsg.Text = msg;
            lblMsg.CssClass = success ?
                "alert alert-success d-block" :
                "alert alert-danger d-block";
        }
    }
}