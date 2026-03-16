using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using LearningManagementSystem.BL;
using LearningManagementSystem.GC;

namespace LearningManagementSystem.Admin
{
    public partial class AddCourse : Page
    {
        CourseBL bl = new CourseBL();

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
                LoadCourses();
            }
        }

        // ================= LOAD STREAMS =================
        private void LoadStreams()
        {
            int instituteId = Convert.ToInt32(Session["InstituteId"]);

            DataTable dt = bl.GetStreams(instituteId);

            ddlStream.DataSource = dt;
            ddlStream.DataTextField = "StreamName";
            ddlStream.DataValueField = "StreamId";
            ddlStream.DataBind();
            ddlStream.Items.Insert(0, new ListItem("-- Select Stream --", ""));

            ddlStreamEdit.DataSource = dt;
            ddlStreamEdit.DataTextField = "StreamName";
            ddlStreamEdit.DataValueField = "StreamId";
            ddlStreamEdit.DataBind();
            ddlStreamEdit.Items.Insert(0, new ListItem("-- Select Stream --", ""));
        }

        // ================= LOAD COURSES =================
        private void LoadCourses(string status = "All")
        {
            int instituteId = Convert.ToInt32(Session["InstituteId"]);

            gvCourses.DataSource = bl.GetCourses(instituteId, status);
            gvCourses.DataBind();
        }

        // ================= SAVE =================
        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (ddlStream.SelectedValue == "" ||
                string.IsNullOrWhiteSpace(txtCourseName.Text))
            {
                ShowMsg("All fields required.", false);
                return;
            }

            CourseGC c = new CourseGC
            {
                SocietyId = Convert.ToInt32(Session["SocietyId"]),
                InstituteId = Convert.ToInt32(Session["InstituteId"]),
                StreamId = Convert.ToInt32(ddlStream.SelectedValue),
                CourseName = txtCourseName.Text.Trim(),
                CourseCode = txtCourseCode.Text.Trim()
            };

            bl.Insert(c);

            txtCourseName.Text = "";
            txtCourseCode.Text = "";
            ddlStream.SelectedIndex = 0;

            LoadCourses();
            ShowMsg("Course added successfully.", true);
        }

        // ================= GRID COMMAND =================
        protected void gvCourses_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int id = Convert.ToInt32(e.CommandArgument);
            int instituteId = Convert.ToInt32(Session["InstituteId"]);

            if (e.CommandName == "EditRow")
            {
                DataTable dt = bl.GetById(id, instituteId);

                if (dt.Rows.Count > 0)
                {
                    hfCourseId.Value = id.ToString();
                    ddlStreamEdit.SelectedValue = dt.Rows[0]["StreamId"].ToString();
                    txtCourseNameEdit.Text = dt.Rows[0]["CourseName"].ToString();
                    txtCourseCodeEdit.Text = dt.Rows[0]["CourseCode"].ToString();

                    ScriptManager.RegisterStartupScript(
                        this, GetType(),
                        "edit",
                        "var m=new bootstrap.Modal(document.getElementById('EditModal'));m.show();",
                        true);
                }
            }
            else if (e.CommandName == "Toggle")
            {
                bl.Toggle(id, instituteId);
                LoadCourses();
            }
            else if (e.CommandName == "DeleteRow")
            {
                bl.Delete(id, instituteId);
                LoadCourses();
            }
        }

        // ================= UPDATE =================
        protected void btnUpdate_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(hfCourseId.Value) ||
                ddlStreamEdit.SelectedValue == "")
            {
                ShowMsg("All fields required.", false);
                return;
            }

            CourseGC c = new CourseGC
            {
                CourseId = Convert.ToInt32(hfCourseId.Value),
                InstituteId = Convert.ToInt32(Session["InstituteId"]),
                StreamId = Convert.ToInt32(ddlStreamEdit.SelectedValue),
                CourseName = txtCourseNameEdit.Text.Trim(),
                CourseCode = txtCourseCodeEdit.Text.Trim()
            };

            bl.Update(c);

            LoadCourses();
            ShowMsg("Course updated successfully.", true);
        }

        // ================= FILTER =================
        protected void FilterStatus_Click(object sender, EventArgs e)
        {
            LinkButton btn = (LinkButton)sender;
            LoadCourses(btn.CommandArgument);
        }

        // ================= MESSAGE =================
        private void ShowMsg(string msg, bool isSuccess)
        {
            lblMsg.Text = msg;
            lblMsg.CssClass = isSuccess
                ? "alert alert-success d-block"
                : "alert alert-danger d-block";
        }
    }
}