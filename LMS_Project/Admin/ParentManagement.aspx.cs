using LearningManagementSystem.GC;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace LearningManagementSystem.Admin
{
    public partial class ParentManagement : BasePage
    {
        ParentBL bl = new ParentBL();

        // ✅ FIX: use ViewState instead of HiddenField
        public string CurrentFilter
        {
            get { return ViewState["Filter"] == null ? "1" : ViewState["Filter"].ToString(); }
            set { ViewState["Filter"] = value; }
        }

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
                LoadParents();
                LoadStudents();
                LoadStats();
            }
        }

        // ✅ FILTER BUTTON CLICK
        protected void Filter_Click(object sender, EventArgs e)
        {
            // toggle
            CurrentFilter = CurrentFilter == "1" ? "0" : "1";

            btnToggleView.Text = CurrentFilter == "1"
                ? "👁 View Inactive"
                : "👁 View Active";

            LoadParents();
            LoadStats();
        }

        private void LoadParents()
        {
            bool isActive = CurrentFilter == "1";

            gvParents.DataSource = bl.GetParents(InstituteId, SessionId, isActive);
            gvParents.DataBind();
        }

        private void LoadStudents()
        {
            DataLayer dl = new DataLayer();

            SqlCommand cmd = new SqlCommand(@"
            SELECT U.UserId, P.FullName
            FROM Users U
            INNER JOIN UserProfile P ON U.UserId = P.UserId
            WHERE U.RoleId = (SELECT RoleId FROM Roles WHERE RoleName='Student')
            AND U.InstituteId = @I
            AND U.SessionId = @SessionId
            AND U.IsActive = 1");

            cmd.Parameters.AddWithValue("@I", InstituteId);
            cmd.Parameters.AddWithValue("@SessionId", SessionId);

            lstStudents.DataSource = dl.GetDataTable(cmd);
            lstStudents.DataTextField = "FullName";
            lstStudents.DataValueField = "UserId";
            lstStudents.DataBind();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            try
            {
                ParentGC gc = new ParentGC();

                gc.SocietyId = SocietyId;
                gc.InstituteId = InstituteId;
                gc.SessionId = SessionId;

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
                    ShowMsg("Select at least one student", false);
                    return;
                }

                if (!string.IsNullOrEmpty(hfParentUserId.Value))
                {
                    gc.UserId = Convert.ToInt32(hfParentUserId.Value);
                    bl.UpdateParent(gc);
                    ShowMsg("Parent Updated", true);
                }
                else
                {
                    bl.InsertParent(gc);
                    ShowMsg("Parent Created", true);
                }

                ClearForm();
                LoadParents();
                LoadStats();
            }
            catch (Exception ex)
            {
                ShowMsg(ex.Message, false);
            }
        }

        protected void gvParents_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int userId = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "Toggle")
                bl.ToggleParent(userId,SessionId);

            else if (e.CommandName == "DeleteRow")
                bl.DeleteParent(userId,SessionId);

            else if (e.CommandName == "EditRow")
                LoadParentForEdit(userId);

            LoadParents();
            LoadStats();
        }

        private void LoadParentForEdit(int userId)
        {
            DataTable dt = bl.GetParentById(userId, SessionId);

            if (dt != null && dt.Rows.Count > 0)
            {
                txtUsername.Text = dt.Rows[0]["Username"].ToString();
                txtFullName.Text = dt.Rows[0]["FullName"].ToString();
                txtEmail.Text = dt.Rows[0]["Email"].ToString();
                txtContact.Text = dt.Rows[0]["ContactNo"].ToString();

                hfParentUserId.Value = userId.ToString();

                ScriptManager.RegisterStartupScript(this, GetType(),
                    "openModal", "openCreateModal();", true);
            }
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

        // ✅ STATS VARIABLES (fixes your 46 errors)
        public int TotalParents = 0;
        public int ActiveParents = 0;
        public int InactiveParents = 0;
        public int TotalLinks = 0;

        private void LoadStats()
        {
            DataLayer dl = new DataLayer();

            SqlCommand cmd = new SqlCommand(@"
                SELECT 
                    COUNT(*) Total,
                    ISNULL(SUM(CASE WHEN U.IsActive=1 THEN 1 ELSE 0 END),0) Active,
                    ISNULL(SUM(CASE WHEN U.IsActive=0 THEN 1 ELSE 0 END),0) Inactive,
                    ISNULL(COUNT(SP.StudentUserId),0) Links
                FROM Users U
                LEFT JOIN ParentStudentMapping SP ON U.UserId = SP.ParentUserId
                WHERE U.RoleId = (SELECT RoleId FROM Roles WHERE RoleName='Parent')
                AND U.InstituteId=@I AND U.SessionId = @SessionId");

            cmd.Parameters.AddWithValue("@I", InstituteId);
            cmd.Parameters.AddWithValue("@SessionId", SessionId);

            DataTable dt = dl.GetDataTable(cmd);

            if (dt.Rows.Count > 0)
            {
                TotalParents = dt.Rows[0]["Total"] != DBNull.Value ? Convert.ToInt32(dt.Rows[0]["Total"]) : 0;
                ActiveParents = dt.Rows[0]["Active"] != DBNull.Value ? Convert.ToInt32(dt.Rows[0]["Active"]) : 0;
                InactiveParents = dt.Rows[0]["Inactive"] != DBNull.Value ? Convert.ToInt32(dt.Rows[0]["Inactive"]) : 0;
                TotalLinks = dt.Rows[0]["Links"] != DBNull.Value ? Convert.ToInt32(dt.Rows[0]["Links"]) : 0;
            }
        }
    }
}