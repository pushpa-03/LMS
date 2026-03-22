using LMS.BL;
using LMS.GC;
using System;
using System.Data;
using System.Web.UI;

namespace LearningManagementSystem.Admin
{
    public partial class AddStream : System.Web.UI.Page
    {
        StreamBL bl = new StreamBL();

        private int CurrentInstituteId
        {
            get { return Convert.ToInt32(Session["InstituteId"]); }
        }

        private int CurrentSocietyId
        {
            get { return Convert.ToInt32(Session["SocietyId"]); }
        }

        private string CurrentFilter
        {
            get { return ViewState["Filter"] != null ? ViewState["Filter"].ToString() : "1"; } // default ACTIVE
            set { ViewState["Filter"] = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["InstituteId"] == null)
            {
                Response.Redirect("~/Default.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadStreams();
            }
            else
            {
                // 🔥 Always reload on postback to apply search
                LoadStreams();
            }
        }

        // ================= LOAD =================
        void LoadStreams()
        {
            DataTable dt = bl.GetStreams(CurrentInstituteId, CurrentFilter);

            // 🔥 SEARCH FILTER
            if (!string.IsNullOrWhiteSpace(txtSearch.Value))
            {
                string search = txtSearch.Value.Replace("'", "''"); // prevent error

                DataRow[] rows = dt.Select($"StreamName LIKE '%{search}%'");

                if (rows.Length > 0)
                    dt = rows.CopyToDataTable();
                else
                    dt = dt.Clone(); // ✅ prevents crash
            }

            gvStreams.DataSource = dt;
            gvStreams.DataBind();

            lblTotal.Text = dt.Rows.Count.ToString();

            int active = dt.Select("IsActive = true").Length;
            int inactive = dt.Select("IsActive = false").Length;

            lblActive.Text = active.ToString();
            lblInactive.Text = inactive.ToString();
        }

        // ================= SAVE =================
        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtStreamName.Text))
            {
                ShowMsg("Stream name required.", false);
                return;
            }

            if (bl.IsStreamExists(CurrentInstituteId, txtStreamName.Text.Trim()))
            {
                ShowMsg("Stream already exists.", false);
                return;
            }

            StreamGC model = new StreamGC
            {
                SocietyId = CurrentSocietyId,
                InstituteId = CurrentInstituteId,
                StreamName = txtStreamName.Text.Trim()
            };

            bl.InsertStream(model);

            txtStreamName.Text = "";
            LoadStreams();
            ShowMsg("Stream added successfully.", true);
        }

        // ================= GRID COMMAND =================
        protected void gvStreams_RowCommand(object sender, System.Web.UI.WebControls.GridViewCommandEventArgs e)
        {
            int id = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "EditRow")
            {
                DataTable dt = bl.GetStreamById(id, CurrentInstituteId);

                if (dt.Rows.Count > 0)
                {
                    hfStreamId.Value = id.ToString();
                    txtStreamNameEdit.Text = dt.Rows[0]["StreamName"].ToString();

                    ScriptManager.RegisterStartupScript(
                        this, GetType(), "Edit",
                        "var m=new bootstrap.Modal(document.getElementById('EditModal'));m.show();", true);
                }
            }
            else if (e.CommandName == "Toggle")
            {
                bl.ToggleStreamStatus(id, CurrentInstituteId);
                LoadStreams();
            }
            else if (e.CommandName == "DeleteRow")
            {
                bl.DeleteStream(id, CurrentInstituteId);
                LoadStreams();
            }
        }

        // ================= UPDATE =================
        protected void btnUpdate_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(hfStreamId.Value))
            {
                ShowMsg("Invalid update.", false);
                return;
            }

            if (bl.IsStreamExists(CurrentInstituteId, txtStreamNameEdit.Text.Trim(),
                                  Convert.ToInt32(hfStreamId.Value)))
            {
                ShowMsg("Stream already exists.", false);
                return;
            }

            StreamGC model = new StreamGC
            {
                StreamId = Convert.ToInt32(hfStreamId.Value),
                InstituteId = CurrentInstituteId,
                StreamName = txtStreamNameEdit.Text.Trim()
            };

            bl.UpdateStream(model);

            LoadStreams();
            ShowMsg("Stream updated successfully.", true);
        }

        // ================= FILTER =================
        protected void Filter_Click(object sender, EventArgs e)
        {
            var btn = (System.Web.UI.WebControls.LinkButton)sender;

            if (btn.CommandArgument == "Toggle")
            {
                // switch between active/inactive
                CurrentFilter = CurrentFilter == "1" ? "0" : "1";

                btnToggleView.Text = CurrentFilter == "1"
                    ? "👁 View Inactive"
                    : "👁 View Active";
            }
            else
            {
                CurrentFilter = btn.CommandArgument;
            }

            LoadStreams();
        }


        // ================= MESSAGE =================
        void ShowMsg(string msg, bool success)
        {
            string script = $@"
        var toastEl = document.getElementById('liveToast');
        var toastMsg = document.getElementById('toastMsg');

        toastMsg.innerText = '{msg}';
        toastEl.classList.remove('bg-success','bg-danger');
        toastEl.classList.add('{(success ? "bg-success" : "bg-danger")}');

        var toast = new bootstrap.Toast(toastEl);
        toast.show();
    ";

            ScriptManager.RegisterStartupScript(this, GetType(), "toast", script, true);
        }
    }
}