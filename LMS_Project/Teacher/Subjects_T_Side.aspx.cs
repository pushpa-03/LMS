using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace LMS_Project.Teacher
{
    public partial class Subjects : BasePage
    {
        SubjectsBL bl = new SubjectsBL();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (SessionId == 0)
                {
                    lblMsg.Text = "No active academic session found!";
                    lblMsg.Visible = true;
                    return;
                }

                LoadDashboard();
            }
        }

        private void LoadDashboard()
        {
            if (SessionId == 0) return;

            int teacherUserId = Convert.ToInt32(Session["UserId"]);
            int statusFilter = chkStatus.Checked ? 0 : 1;

            DataTable dtStats = bl.GetAdminStats(InstituteId, SessionId);
            rptStats.DataSource = dtStats;
            rptStats.DataBind();

            DataTable dt = bl.GetTeacherSubjects(teacherUserId, InstituteId, SessionId, statusFilter);

            rptSubjects.DataSource = dt;
            rptSubjects.DataBind();

            phEmpty.Visible = dt.Rows.Count == 0;

            int active = dt.Select("IsActive = 1").Length;
            int inactive = dt.Select("IsActive = 0").Length;
            int totalEnroll = 0;

            foreach (DataRow r in dt.Rows)
            {
                if (r["StudentCount"] != DBNull.Value)
                    totalEnroll += Convert.ToInt32(r["StudentCount"]);
            }

            string script = $"loadCharts({active},{inactive},{totalEnroll});";
            ScriptManager.RegisterStartupScript(this, GetType(), "chart", script, true);
        }

        protected void chkStatus_CheckedChanged(object sender, EventArgs e)
        {
            LoadDashboard();
        }
    }
}