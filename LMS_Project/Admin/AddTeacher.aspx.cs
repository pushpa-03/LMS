using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace LearningManagementSystem.Admin
{
    public partial class Teachers : BasePage
    {
        TeacherBL bl = new TeacherBL();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (SessionId == 0)
                {
                    ShowMsg("No active academic session found!", false);
                    return;
                }

                CurrentFilter = "1";
                LoadStreams();
                LoadTeachers();
                LoadStats();
            }
        }



        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (SessionId == 0)
            {
                ShowMsg("No active session!", false);
                return;
            }

            TeacherGC t = new TeacherGC
            {
                StreamId = Convert.ToInt32(ddlStream.SelectedValue),
                Username = txtUsername.Text.Trim(),
                Email = txtEmail.Text.Trim(),
                SocietyId = Convert.ToInt32(Session["SocietyId"]),
                InstituteId = Convert.ToInt32(Session["InstituteId"]),
                SessionId = SessionId,
                FullName = txtFullName.Text.Trim(),
                Gender = ddlGender.SelectedValue,
                DOB = Convert.ToDateTime(txtDOB.Text),
                ContactNo = txtContact.Text.Trim(),
                EmployeeId = txtEmpId.Text.Trim(),
                ExperienceYears = Convert.ToInt32(txtExperience.Text),
                Designation = txtDesignation.Text.Trim()
            };

            bl.InsertTeacher(t);

            //LoadTeachers(txtSearch.Text.Trim());
            LoadTeachers();
            LoadStats();
            ShowMsg("Parent added successfully", true);
        }

        protected void gvTeachers_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int userId = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "Toggle")
            {
                bl.ToggleStatus(userId,SessionId);
                //LoadTeachers(txtSearch.Text.Trim());
                LoadTeachers();
                LoadStats();
                ShowMsg("Status changed successfully", true);
            }
            else if (e.CommandName == "DeleteRow")
            {
                bl.DeleteTeacher(userId,SessionId);
                //LoadTeachers(txtSearch.Text.Trim());
                LoadTeachers();
                LoadStats();
                ShowMsg("parent deleted successfully", true);
            }
            else if (e.CommandName == "EditRow")
            {
                DataTable dt = bl.GetTeacherById(userId, SessionId);

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
            int instituteId = InstituteId;

            DataTable dt = bl.GetStreams(instituteId,SessionId);

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
            //LoadTeachers(txtSearch.Text.Trim(), "All");
            LoadTeachers();
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
            //LoadTeachers(txtSearch.Text.Trim());
            LoadTeachers();
            LoadStats();
            ShowMsg("Updated successfully", true);
        }
        protected void FilterStatus_Click(object sender, EventArgs e)
        {
            string status = ((LinkButton)sender).CommandArgument;
            //LoadTeachers(txtSearch.Text.Trim(), status);
            LoadTeachers();
        }

        public int TotalTeachers = 0;
        public int ActiveTeachers = 0;
        public int InactiveTeachers = 0;

        string CurrentFilter
        {
            get { return ViewState["Filter"]?.ToString() ?? "1"; }
            set { ViewState["Filter"] = value; }
        }

        //private void LoadTeachers(string search = "", string status = "All")
        //{
        //    int instituteId = Convert.ToInt32(Session["InstituteId"]);
        //    gvTeachers.DataSource = bl.GetTeachers(instituteId, search, status);
        //    gvTeachers.DataBind();


        //}

        //private void LoadTeachers(string search = "")
        //{
        //    int instituteId = Convert.ToInt32(Session["InstituteId"]);

        //    string status = CurrentFilter == "1" ? "1" : "0";

        //    gvTeachers.DataSource = bl.GetTeachers(instituteId, search, status);
        //    gvTeachers.DataBind();
        //}

        private void LoadTeachers()
        {
            string search = txtSearch.Text.Trim();
            string status = CurrentFilter;

            gvTeachers.DataSource = bl.GetTeachers(InstituteId, SessionId, search, status);
            gvTeachers.DataBind();
        }

        protected void ToggleView_Click(object sender, EventArgs e)
        {
            CurrentFilter = CurrentFilter == "1" ? "0" : "1";

            btnToggleView.Text = CurrentFilter == "1"
                ? "👁 View Inactive"
                : "👁 View Active";

            //LoadTeachers(txtSearch.Text.Trim());
            LoadTeachers();
            LoadStats();
        }

        protected void Search_Click(object sender, EventArgs e)
        {
            //LoadTeachers(txtSearch.Text.Trim());
            LoadTeachers();
        }

        private void LoadStats()
        {
            int instituteId = InstituteId;

            DataTable dt = bl.GetTeachers(InstituteId, SessionId, "", "All");

            TotalTeachers = dt.Rows.Count;
            ActiveTeachers = dt.Select("IsActive = 1").Length;
            InactiveTeachers = dt.Select("IsActive = 0").Length;
        }

        void ShowMsg(string msg, bool success)
        {
            string safeMsg = msg.Replace("'", "\\'");

            string script = $@"
            var toastEl = document.getElementById('liveToast');
            var toastMsg = document.getElementById('toastMsg');

            toastMsg.innerText = '{safeMsg}';

            toastEl.classList.remove('bg-success','bg-danger');
            toastEl.classList.add('{(success ? "bg-success" : "bg-danger")}');

            var toast = new bootstrap.Toast(toastEl, {{ delay: 3000 }});
            toast.show();
            ";

            ScriptManager.RegisterStartupScript(this, GetType(), "toast", script, true);
        }
    }
}