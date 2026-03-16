using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using LearningManagementSystem.BL;
using LearningManagementSystem.GC;

namespace LearningManagementSystem.Admin
{
    public partial class AcademicSetup : Page
    {
        AcademicSetupBL bl = new AcademicSetupBL();

        int SocietyId => Convert.ToInt32(Session["SocietyId"]);
        int InstituteId => Convert.ToInt32(Session["InstituteId"]);

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["InstituteId"] == null)
            {
                Response.Redirect("~/Default.aspx");
                return;
            }

            if (!IsPostBack)
            {
                BindAll();
            }
        }

        private void BindAll()
        {
            gvLevels.DataSource = bl.GetData("Level", InstituteId);
            gvLevels.DataBind();

            gvSemesters.DataSource = bl.GetData("Semester", InstituteId);
            gvSemesters.DataBind();

            gvSections.DataSource = bl.GetData("Section", InstituteId);
            gvSections.DataBind();
        }

        protected void PrepareCreate_Click(object sender, EventArgs e)
        {
            txtName.Text = "";
            hfEntryId.Value = "";
            hfEntryType.Value = (sender as LinkButton).CommandArgument;

            ScriptManager.RegisterStartupScript(this, GetType(),
                "pop", $"showSetupModal('Add {hfEntryType.Value}');", true);
        }

        protected void gv_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            string[] args = e.CommandArgument.ToString().Split('|');
            string type = args[0];
            int id = Convert.ToInt32(args[1]);

            if (e.CommandName == "EditRow")
            {
                hfEntryType.Value = type;
                hfEntryId.Value = id.ToString();

                DataTable dt = bl.GetById(type, id, InstituteId);
                if (dt.Rows.Count > 0)
                    txtName.Text = dt.Rows[0][0].ToString();

                ScriptManager.RegisterStartupScript(this, GetType(),
                    "pop", $"showSetupModal('Edit {type}');", true);
            }
            else if (e.CommandName == "DeleteRow")
            {
                bl.Delete(type, id, InstituteId);
                BindAll();
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            AcademicSetupGC obj = new AcademicSetupGC
            {
                Id = string.IsNullOrEmpty(hfEntryId.Value) ? 0 : Convert.ToInt32(hfEntryId.Value),
                SocietyId = SocietyId,
                InstituteId = InstituteId,
                Name = txtName.Text.Trim(),
                Type = hfEntryType.Value
            };

            if (obj.Id == 0)
                bl.Insert(obj);
            else
                bl.Update(obj);

            BindAll();
        }
    }
}