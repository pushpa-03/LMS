using LearningManagementSystem.GC;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace LearningManagementSystem.Admin
{
    public partial class ParentManagement : Page
    {
        ParentBL bl = new ParentBL();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["InstituteId"] == null)
                Response.Redirect("~/Default.aspx");

            if (!IsPostBack)
            {
                LoadParents();
                LoadStudents();
            }

        }

        private void LoadStudents()
        {
            DataLayer dl = new DataLayer();

            SqlCommand cmd = new SqlCommand(@"
            SELECT 
                U.UserId,
                P.FullName
            FROM Users U
            INNER JOIN UserProfile P 
                ON U.UserId = P.UserId
            WHERE U.RoleId = (SELECT RoleId FROM Roles WHERE RoleName='Student')
            AND U.InstituteId = @I
            AND U.IsActive = 1
            ");

            cmd.Parameters.AddWithValue("@I", Session["InstituteId"]);

            DataTable dt = dl.GetDataTable(cmd);

            lstStudents.DataSource = dt;
            lstStudents.DataTextField = "FullName";
            lstStudents.DataValueField = "UserId";
            lstStudents.DataBind();
        }
        private void LoadParents()
        {
            int instituteId = Convert.ToInt32(Session["InstituteId"]);
            gvParents.DataSource = bl.GetParents(instituteId);
            gvParents.DataBind();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            try
            {

                ParentGC gc = new ParentGC();

                gc.SocietyId = Convert.ToInt32(Session["SocietyId"]);
                gc.InstituteId = Convert.ToInt32(Session["InstituteId"]);

                gc.Username = txtUsername.Text.Trim();
                gc.Email = txtEmail.Text.Trim();
                gc.FullName = txtFullName.Text.Trim();
                gc.ContactNo = txtContact.Text.Trim();

                gc.Gender = ddlGender.SelectedValue;

                if (!string.IsNullOrEmpty(txtDOB.Text))
                    gc.DOB = Convert.ToDateTime(txtDOB.Text);

                gc.RelationshipType = ddlRelation.SelectedValue;
                gc.IsPrimaryGuardian = chkPrimary.Checked;

                gc.StudentIds = new List<int>();

                foreach (ListItem item in lstStudents.Items)
                {
                    if (item.Selected)
                        gc.StudentIds.Add(Convert.ToInt32(item.Value));
                }

                if (gc.StudentIds.Count == 0)
                {
                    ShowMsg("Please select at least one student", false);
                    return;
                }


                bl.InsertParent(gc);

                ShowMsg("Parent Created Successfully", true);

                ClearForm();
                LoadParents();
            }
            catch (Exception ex)
            {
                ShowMsg(ex.Message, false);
            }
        }

        //protected void EditParent(int userId)
        //{
        //    DataTable dt = bl.GetParentById(userId);

        //    txtUsername.Text = dt.Rows[0]["Username"].ToString();
        //    txtFullName.Text = dt.Rows[0]["FullName"].ToString();
        //    txtEmail.Text = dt.Rows[0]["Email"].ToString();
        //    txtContact.Text = dt.Rows[0]["ContactNo"].ToString();

        //    hfParentUserId.Value = userId.ToString();
        //}

        protected void gvParents_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int userId = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "Toggle")
                bl.ToggleParent(userId);

            else if (e.CommandName == "DeleteRow")
                bl.DeleteParent(userId);

            LoadParents();
        }

        private void ShowMsg(string msg, bool success)
        {
            lblMsg.Text = msg;
            lblMsg.CssClass = success ? "alert alert-success" : "alert alert-danger";
        }
        private void ClearForm()
        {
            txtUsername.Text = "";
            txtEmail.Text = "";
            txtFullName.Text = "";
            txtContact.Text = "";
            txtDOB.Text = "";

            ddlGender.SelectedIndex = 0;
            ddlRelation.SelectedIndex = 0;

            chkPrimary.Checked = false;

            foreach (ListItem item in lstStudents.Items)
                item.Selected = false;

            hfParentUserId.Value = "";
        }
    }
}