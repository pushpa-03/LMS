using LearningManagementSystem.BL;
using LearningManagementSystem.GC;
using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace LearningManagementSystem.Admin
{
    public partial class AcademicSetup : BasePage
    {
        AcademicSetupBL bl = new AcademicSetupBL();

        private bool IsSuperAdmin()
        {
            return Session["Role"]?.ToString() == "SuperAdmin";
        }

        protected void Page_Load(object sender, EventArgs e)
        { 
            if (!IsPostBack)
            {
                BindAll();
            }
        }       


       
        private void BindAll()
        {
            DataTable dtLevel = bl.GetData("Level", InstituteId,SessionId);
            DataTable dtSem = bl.GetData("Semester", InstituteId, SessionId);
            DataTable dtSec = bl.GetData("Section", InstituteId, SessionId);

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
            if (IsSuperAdmin())
            {
                ShowToast("warning", "You have view-only access.");
                return;
            }

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

            if (IsSuperAdmin())
            {
                ShowToast("warning", "You have view-only access.");
                return;
            }

            try
            {
                if (e.CommandName == "EditRow")
                {
                    hfEntryType.Value = type;
                    hfEntryId.Value = id.ToString();

                    DataTable dt = bl.GetById(type, id, InstituteId, SessionId);

                    if (dt.Rows.Count > 0)
                        txtName.Text = dt.Rows[0][0].ToString();

                    ScriptManager.RegisterStartupScript(this, GetType(),
                        "pop", $"showSetupModal('Edit {type}');", true);
                }
                else if (e.CommandName == "DeleteRow")
                {
                    bl.Delete(type, id, InstituteId, SessionId);
                    BindAll();

                    ShowToast("success", $"{type} deleted successfully!");
                }
            }
            catch (SqlException ex)
            {
                if (ex.Number == 547) // FK constraint
                {
                    ShowToast("error", $"{type} is used in another table. You can deactivate it instead.");
                }
                else
                {
                    ShowToast("error", "Something went wrong.");
                }
            }
        }
        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (IsSuperAdmin())
            {
                ShowToast("warning", "You have view-only access.");
                return;
            }

            try
            {
                AcademicSetupGC obj = new AcademicSetupGC
                {
                    Id = string.IsNullOrEmpty(hfEntryId.Value) ? 0 : Convert.ToInt32(hfEntryId.Value),
                    SocietyId = SocietyId,
                    InstituteId = InstituteId,
                    SessionId = SessionId,
                    Name = txtName.Text.Trim(),
                    Type = hfEntryType.Value
                };

                if (obj.Id == 0)
                {
                    bl.Insert(obj);
                    ShowToast("success", "Saved successfully!");
                }
                else
                {
                    bl.Update(obj);
                    ShowToast("info", "Updated successfully!");
                }

                BindAll();
            }
            catch
            {
                ShowToast("error", "Operation failed.");
            }
        }

        private void ShowToast(string type, string message)
        {
            ScriptManager.RegisterStartupScript(this, GetType(),
                "toast", $"showToast('{type}','{message}');", true);
        }
    }
}