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
            get { return ViewState["Filter"] != null ? ViewState["Filter"].ToString() : "All"; }
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
        }

        // ================= LOAD =================
        void LoadStreams()
        {
            gvStreams.DataSource = bl.GetStreams(CurrentInstituteId, CurrentFilter);
            gvStreams.DataBind();
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
            CurrentFilter = btn.CommandArgument;
            gvStreams.PageIndex = 0;
            LoadStreams();
        }

        // ================= MESSAGE =================
        void ShowMsg(string msg, bool success)
        {
            lblMsg.Text = msg;
            lblMsg.Visible = true;

            lblMsg.CssClass = success
                ? "alert alert-success d-block mb-3"
                : "alert alert-danger d-block mb-3";
        }
    }
}