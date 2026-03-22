using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using LearningManagementSystem.BL;
using LearningManagementSystem.GC;

namespace LearningManagementSystem.Admin
{
    public partial class AcademicSession : Page
    {
        AcademicSessionBL bl = new AcademicSessionBL();

        int InstituteId => Convert.ToInt32(Session["InstituteId"]);
        int SocietyId => Convert.ToInt32(Session["SocietyId"]);

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["InstituteId"] == null)
            {
                Response.Redirect("~/Default.aspx");
                return;
            }

            if (!IsPostBack)
                LoadSessions();
        }

        private void LoadSessions()
        {
            DataTable dt = bl.GetSessionsByInstitute(InstituteId);

            gvSessions.DataSource = dt;
            gvSessions.DataBind();

            lblTotal.Text = dt.Rows.Count.ToString();
            lblCurrent.Text = dt.Select("IsCurrent = true").Length.ToString();
            lblPast.Text = dt.Select("IsCurrent = false").Length.ToString();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtSessionName.Text))
            {
                ShowToast("Session name required", false);
                return;
            }

            AcademicSessionGC obj = new AcademicSessionGC
            {
                SessionId = string.IsNullOrEmpty(hfSessionId.Value) ? 0 : Convert.ToInt32(hfSessionId.Value),
                SocietyId = SocietyId,
                InstituteId = InstituteId,
                SessionName = txtSessionName.Text.Trim(),
                StartDate = Convert.ToDateTime(txtStartDate.Text),
                EndDate = Convert.ToDateTime(txtEndDate.Text),
                IsCurrent = chkCurrent.Checked
            };

            if (obj.EndDate <= obj.StartDate)
            {
                ShowToast("End date must be greater than start date", false);
                return;
            }

            if (obj.SessionId == 0)
                bl.InsertSession(obj);
            else
                bl.UpdateSession(obj);

            Clear();
            LoadSessions();
            ShowToast("Saved successfully", true);
        }

        protected void gvSessions_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int id = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "EditRow")
            {
                DataTable dt = bl.GetById(id, InstituteId);

                if (dt.Rows.Count > 0)
                {
                    hfSessionId.Value = id.ToString();
                    txtSessionName.Text = dt.Rows[0]["SessionName"].ToString();
                    txtStartDate.Text = Convert.ToDateTime(dt.Rows[0]["StartDate"]).ToString("yyyy-MM-dd");
                    txtEndDate.Text = Convert.ToDateTime(dt.Rows[0]["EndDate"]).ToString("yyyy-MM-dd");
                    chkCurrent.Checked = Convert.ToBoolean(dt.Rows[0]["IsCurrent"]);

                    ScriptManager.RegisterStartupScript(this, GetType(),
                        "modal", "new bootstrap.Modal(document.getElementById('SessionModal')).show();", true);
                }
            }
            else if (e.CommandName == "SetCurrent")
            {
                bl.SetCurrentSession(id, InstituteId);
                LoadSessions();
                ShowToast("Session set as current", true);
            }
            else if (e.CommandName == "DeleteRow")
            {
                bl.Delete(id, InstituteId);
                LoadSessions();
                ShowToast("Deleted successfully", false);
            }
        }

        private void Clear()
        {
            hfSessionId.Value = "";
            txtSessionName.Text = "";
            txtStartDate.Text = "";
            txtEndDate.Text = "";
            chkCurrent.Checked = false;
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
    }
}