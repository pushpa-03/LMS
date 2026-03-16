using LearningManagementSystem.BL;
using LearningManagementSystem.GC;
using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace LearningManagementSystem.Admin
{
    public partial class AddSubject : Page
    {
        AddSubjectBL bl = new AddSubjectBL();

        int SocietyId => Convert.ToInt32(Session["SocietyId"]);
        int InstituteId => Convert.ToInt32(Session["InstituteId"]);
        int CurrentSessionId => GetCurrentSessionId();
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["InstituteId"] == null)
            {
                Response.Redirect("~/Default.aspx");
                return;
            }

            if (!IsPostBack)
            {
                BindGrid();
            }
        }

        private int GetCurrentSessionId()
        {
            // If session already stored
            if (Session["CurrentSessionId"] != null)
                return Convert.ToInt32(Session["CurrentSessionId"]);

            // Otherwise fetch from DB
            int id = bl.GetCurrentSession(InstituteId);

            if (id > 0)
            {
                Session["CurrentSessionId"] = id; // store for later
                return id;
            }

            throw new Exception("No Current Academic Session Set.");
        }
        private void BindGrid(string status = "All")
        {
            gvSubjects.DataSource =
                bl.GetSubjects(InstituteId, status, txtSearch.Text.Trim());

            gvSubjects.DataBind();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            AddSubjectGC obj = new AddSubjectGC
            {
                SubjectId = string.IsNullOrEmpty(hfSubjectId.Value)
                    ? 0
                    : Convert.ToInt32(hfSubjectId.Value),

                SocietyId = SocietyId,
                InstituteId = InstituteId,
                SessionId = CurrentSessionId,
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

            lblMsg.Text = "Subject Saved Successfully";

            ScriptManager.RegisterStartupScript(
                this, GetType(), "hideModal",
                "$('#CreateModal').modal('hide');", true);
        }

        protected void gvSubjects_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int id = Convert.ToInt32(e.CommandArgument);


            if (e.CommandName == "EditRow")
            {
                hfSubjectId.Value = id.ToString();

                DataTable dt = bl.GetById(id);

                if (dt.Rows.Count > 0)
                {
                    DataRow dr = dt.Rows[0];

                    txtSubjectCode.Text = dr["SubjectCode"].ToString();
                    txtSubjectName.Text = dr["SubjectName"].ToString();
                    txtDescription.Text = dr["Description"].ToString();
                    txtDuration.Text = dr["Duration"].ToString();

                    ScriptManager.RegisterStartupScript(
                        this, GetType(),
                        "edit", "showCreateModal();", true);
                }
            }
            else if (e.CommandName == "Toggle")
            {
                bl.Toggle(id);
                BindGrid();
            }
            else if (e.CommandName == "DeleteRow")
            {
                bl.Delete(id);
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

                SubjectCode = txtSubjectCodeEdit.Text.Trim(),
                SubjectName = txtSubjectNameEdit.Text.Trim(),
                Duration = txtDurationEdit.Text.Trim(),
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

            BindGrid(status);
        }
    }
}