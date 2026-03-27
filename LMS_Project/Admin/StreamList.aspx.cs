using LMS.BL;
using System;
using System.Data;

namespace LearningManagementSystem.Admin
{
    public partial class StreamList : System.Web.UI.Page
    {
        StreamBL bl = new StreamBL();

        private int CurrentInstituteId
        {
            get { return Convert.ToInt32(Session["InstituteId"]); }
        }

        private string CurrentFilter
        {
            get { return ViewState["Filter"] != null ? ViewState["Filter"].ToString() : "1"; }
            set { ViewState["Filter"] = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["InstituteId"] == null)
            {
                Response.Redirect("~/Default.aspx");
                return;
            }

            LoadStreams();
        }

        // ================= LOAD =================
        void LoadStreams()
        {
            DataTable dt = bl.GetStreams(CurrentInstituteId, CurrentFilter);

            // SERVER SEARCH SAFE
            if (!string.IsNullOrWhiteSpace(txtSearch.Value))
            {
                string search = txtSearch.Value.Replace("'", "''");

                DataRow[] rows = dt.Select($"StreamName LIKE '%{search}%'");

                if (rows.Length > 0)
                    dt = rows.CopyToDataTable();
                else
                    dt = dt.Clone();
            }

            rptStreams.DataSource = dt;
            rptStreams.DataBind();

            // ================= STATS =================
            int total = dt.Rows.Count;
            int active = dt.Select("IsActive = true").Length;
            int inactive = dt.Select("IsActive = false").Length;

            lblTotal.Text = total.ToString();
            lblActive.Text = active.ToString();
            lblInactive.Text = inactive.ToString();

            // 🔥 EXTRA ANALYTICS
            if (total > 0)
            {
                int percent = (active * 100) / total;
                lblPercent.Text = percent + "%";
            }
            else
            {
                lblPercent.Text = "0%";
            }
        }

        // ================= FILTER =================
        protected void Filter_Click(object sender, EventArgs e)
        {
            if (CurrentFilter == "1")
            {
                CurrentFilter = "0";
                btnToggleView.Text = "👁 View Active";
            }
            else
            {
                CurrentFilter = "1";
                btnToggleView.Text = "👁 View Inactive";
            }

            LoadStreams();
        }
    }
}