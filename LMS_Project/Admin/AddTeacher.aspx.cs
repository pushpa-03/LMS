using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace LearningManagementSystem.Admin
{
    public partial class Teachers : Page
    {
        TeacherBL bl = new TeacherBL();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null)
            {
                Response.Redirect("~/Default.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadStreams();
                LoadTeachers();
            }
        }

        private void LoadTeachers(string search = "", string status = "All")
        {
            int instituteId = Convert.ToInt32(Session["InstituteId"]);
            gvTeachers.DataSource = bl.GetTeachers(instituteId, search, status);
            gvTeachers.DataBind();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            TeacherGC t = new TeacherGC
            {
                StreamId = Convert.ToInt32(ddlStream.SelectedValue),
                Username = txtUsername.Text.Trim(),
                Email = txtEmail.Text.Trim(),
                SocietyId = Convert.ToInt32(Session["SocietyId"]),
                InstituteId = Convert.ToInt32(Session["InstituteId"]),
                FullName = txtFullName.Text.Trim(),
                Gender = ddlGender.SelectedValue,
                DOB = Convert.ToDateTime(txtDOB.Text),
                ContactNo = txtContact.Text.Trim(),
                EmployeeId = txtEmpId.Text.Trim(),
                ExperienceYears = Convert.ToInt32(txtExperience.Text),
                Designation = txtDesignation.Text.Trim()
            };

            bl.InsertTeacher(t);

            LoadTeachers();
        }

        protected void gvTeachers_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int userId = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "Toggle")
            {
                bl.ToggleStatus(userId);
                LoadTeachers();
            }
            else if (e.CommandName == "DeleteRow")
            {
                bl.DeleteTeacher(userId);
                LoadTeachers();
            }
            else if (e.CommandName == "EditRow")
            {
                DataTable dt = bl.GetTeacherById(userId);

                if (dt.Rows.Count > 0)
                {
                    hfTeacherUserId.Value = userId.ToString();

                    txtEmailEdit.Text = dt.Rows[0]["Email"].ToString();
                    txtFullNameEdit.Text = dt.Rows[0]["FullName"].ToString();
                    txtContactEdit.Text = dt.Rows[0]["ContactNo"].ToString();
                    txtDesignationEdit.Text = dt.Rows[0]["Designation"].ToString();

                    ddlStreamEdit.SelectedValue = dt.Rows[0]["StreamId"].ToString();

                    // Open modal
                    ScriptManager.RegisterStartupScript(this, this.GetType(),
                        "Pop", "var myModal = new bootstrap.Modal(document.getElementById('EditModal')); myModal.show();", true);
                }
            }
        }


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
        protected void btnFilter_Click(object sender, EventArgs e)
        {
            LoadTeachers(txtSearch.Text.Trim(), "All");
        }
        protected void btnUpdate_Click(object sender, EventArgs e)
        {
            TeacherGC t = new TeacherGC
            {
                UserId = Convert.ToInt32(hfTeacherUserId.Value),
                Email = txtEmailEdit.Text.Trim(),
                FullName = txtFullNameEdit.Text.Trim(),
                ContactNo = txtContactEdit.Text.Trim(),
                Designation = txtDesignationEdit.Text.Trim(),
                StreamId = Convert.ToInt32(ddlStreamEdit.SelectedValue)
            };

            bl.UpdateTeacher(t);
            LoadTeachers();
        }
        protected void FilterStatus_Click(object sender, EventArgs e)
        {
            string status = ((LinkButton)sender).CommandArgument;
            LoadTeachers(txtSearch.Text.Trim(), status);
        }
    }
}