using LearningManagementSystem.BL;
using LearningManagementSystem.GC;
using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace LearningManagementSystem.Admin
{
    public partial class AddSubject : BasePage
    {
        AddSubjectBL bl = new AddSubjectBL();



        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
                BindGrid();
        }


        private void BindGrid()
        {

            string status = ViewStateStatus;
            string search = txtSearch?.Text?.Trim() ?? "";

            DataTable dt = bl.GetSubjects(InstituteId, SessionId, status, search);

            if (SessionId == 0)
            {
                gvSubjects.DataSource = null;
                gvSubjects.DataBind();
                return;
            }

            gvSubjects.DataSource = dt;
            gvSubjects.DataBind();

            lblTotal.Text = dt.Rows.Count.ToString();
            lblActive.Text = dt.Select("IsActive = 1").Length.ToString();
            lblInactive.Text = dt.Select("IsActive = 0").Length.ToString();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            try
            {
                if (SessionId == 0)
                {
                    ShowToast("No active academic session found!", false);
                    return;
                }

                if (string.IsNullOrWhiteSpace(txtSubjectCode.Text) ||
                    string.IsNullOrWhiteSpace(txtSubjectName.Text))
                {
                    ShowToast("Code & Name required", false);
                    return;
                }

                AddSubjectGC obj = new AddSubjectGC
                {
                    SubjectId = string.IsNullOrEmpty(hfSubjectId.Value)
                        ? 0
                        : Convert.ToInt32(hfSubjectId.Value),

                    SocietyId = SocietyId,
                    InstituteId = InstituteId,
                    SessionId = SessionId,

                    SubjectCode = txtSubjectCode.Text.Trim(),
                    SubjectName = txtSubjectName.Text.Trim(),
                    Description = txtDescription.Text.Trim(),
                    Duration = txtDuration.Text.Trim()
                };

                if (obj.SubjectId == 0)
                    bl.Insert(obj);
                else
                    bl.Update(obj);

                BindGrid();
                Clear();

                ShowToast("Saved successfully", true);
            }
            catch (Exception ex)
            {
                ShowToast("Error: " + ex.Message, false);
            }
        }

        protected void gvSubjects_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandArgument == null) return;

            int id;
            if (!int.TryParse(e.CommandArgument.ToString(), out id))
                return;


            if (e.CommandName == "EditRow")
            {
                hfSubjectId.Value = id.ToString();

                DataTable dt = bl.GetById(id,SessionId);

                if (dt.Rows.Count > 0)
                {
                    DataRow dr = dt.Rows[0];

                    txtSubjectCode.Text = dr["SubjectCode"].ToString();
                    txtSubjectName.Text = dr["SubjectName"].ToString();
                    txtDescription.Text = dr["Description"].ToString();
                    txtDuration.Text = dr["Duration"].ToString();

                    ScriptManager.RegisterStartupScript(
                            this, GetType(),
                            "open", "openModal();", true);
                }
            }
            else if (e.CommandName == "Toggle")
            {
                bl.Toggle(id,SessionId);
                BindGrid();
            }
            else if (e.CommandName == "DeleteRow")
            {
                bl.Delete(id, SessionId);
                BindGrid();
            }
        }

        protected void btnUpdate_Click(object sender, EventArgs e)
        {
            AddSubjectGC obj = new AddSubjectGC
            {
                SubjectId = Convert.ToInt32(hfSubjectId.Value),

                SocietyId = SocietyId,
                InstituteId = InstituteId,

                SubjectCode = txtSubjectCode.Text.Trim(),
                SubjectName = txtSubjectName.Text.Trim(),
                Duration = txtDuration.Text.Trim(),
                Description = txtDescription.Text.Trim()
            };

            bl.Update(obj);

            BindGrid();
        }

        protected void btnFilter_Click(object sender, EventArgs e)
        {
            BindGrid();
        }

        protected void FilterStatus_Click(object sender, EventArgs e)
        {
            string status = ((LinkButton)sender).CommandArgument;

            BindGrid();
        }
        private void ShowToast(string msg, bool success)
        {
            string script = $@"
                var t = document.getElementById('liveToast');
                var m = document.getElementById('toastMsg');

                m.innerText = '{msg}';
                t.classList.remove('bg-success','bg-danger');
                t.classList.add('{(success ? "bg-success" : "bg-danger")}');

                new bootstrap.Toast(t).show();
            ";

            ScriptManager.RegisterStartupScript(this, GetType(), "toast", script, true);
        }

        private void Clear()
        {
            hfSubjectId.Value = "";
            txtSubjectCode.Text = "";
            txtSubjectName.Text = "";
            txtDescription.Text = "";
            txtDuration.Text = "";
        }

        string ViewStateStatus
        {
            get => ViewState["Status"]?.ToString() ?? "1"; // default Active
            set => ViewState["Status"] = value;
        }

        protected void btnToggleView_Click(object sender, EventArgs e)
        {
            if (ViewStateStatus == "1")
            {
                ViewStateStatus = "0";
                btnToggleView.Text = "Show Active";
            }
            else
            {
                ViewStateStatus = "1";
                btnToggleView.Text = "Show Inactive";
            }

            BindGrid();
        }
    }
}