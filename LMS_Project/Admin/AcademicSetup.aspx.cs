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
            DataTable dtLevel = bl.GetData("Level", InstituteId);
            DataTable dtSem = bl.GetData("Semester", InstituteId);
            DataTable dtSec = bl.GetData("Section", InstituteId);

            gvLevels.DataSource = dtLevel;
            gvLevels.DataBind();

            gvSemesters.DataSource = dtSem;
            gvSemesters.DataBind();

            gvSections.DataSource = dtSec;
            gvSections.DataBind();

            // 🔥 STATS
            lblLevels.Text = dtLevel.Rows.Count.ToString();
            lblSemesters.Text = dtSem.Rows.Count.ToString();
            lblSections.Text = dtSec.Rows.Count.ToString();
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

                lblMsg.Text = $"{type} deleted successfully!";
                lblMsg.CssClass = "alert alert-danger";
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
                {
                    bl.Insert(obj);
                    lblMsg.Text = "Saved successfully!";
                    lblMsg.CssClass = "alert alert-success";
                }
            else
                bl.Update(obj);

            BindAll();

            txtName.Text = "";
            hfEntryId.Value = "";

        }
    }
}