using System;
using System.Data;
using LearningManagementSystem.BL;
using LearningManagementSystem.GC;

namespace LearningManagementSystem.Admin
{
    public partial class AcademicSession : System.Web.UI.Page
    {
        AcademicSessionBL bl = new AcademicSessionBL();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["InstituteId"] == null)
            {
                Response.Redirect("~/Default.aspx");
                return;
            }
            if (!IsPostBack)
            {
                LoadSessions();
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            AcademicSessionGC obj = new AcademicSessionGC();

            obj.SocietyId = Convert.ToInt32(Session["SocietyId"]);
            obj.InstituteId = Convert.ToInt32(Session["InstituteId"]);
            obj.SessionName = txtSessionName.Text.Trim();
            obj.StartDate = Convert.ToDateTime(txtStartDate.Text);
            obj.EndDate = Convert.ToDateTime(txtEndDate.Text);
            obj.IsCurrent = chkCurrent.Checked;

            bl.InsertSession(obj);

            LoadSessions();
            Clear();
        }

        private void LoadSessions()
        {
            int instituteId = Convert.ToInt32(Session["InstituteId"]);
            gvSessions.DataSource = bl.GetSessionsByInstitute(instituteId);
            gvSessions.DataBind();
        }

        private void Clear()
        {
            txtSessionName.Text = "";
            txtStartDate.Text = "";
            txtEndDate.Text = "";
            chkCurrent.Checked = false;
        }
    }
}