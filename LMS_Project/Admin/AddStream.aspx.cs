using LearningManagementSystem.BL;
using LMS.BL;
using LMS.GC;
using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace LearningManagementSystem.Admin
{
    public partial class AddStream : BasePage
    {
        StreamBL bl = new StreamBL();       

        private string CurrentFilter
        {
            get { return ViewState["Filter"] != null ? ViewState["Filter"].ToString() : "1"; } // default ACTIVE
            set { ViewState["Filter"] = value; }
        }

        private bool IsSuperAdmin
        {
            get { return Session["Role"]?.ToString() == "SuperAdmin"; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadStreams();
            }
            else
            {
                LoadStreams(); // for search/filter
            }
        }


        // ================= LOAD =================
        void LoadStreams()
        {
            int sessionId = SessionId;

            DataTable dt = bl.GetStreams(InstituteId, sessionId, CurrentFilter);

            // 🔍 SEARCH FILTER
            if (!string.IsNullOrWhiteSpace(txtSearch.Value))
            {
                string search = txtSearch.Value.Replace("'", "''");

                DataRow[] rows = dt.Select($"StreamName LIKE '%{search}%'");

                dt = rows.Length > 0 ? rows.CopyToDataTable() : dt.Clone();
            }

            gvStreams.DataSource = dt;
            gvStreams.DataBind();

            lblTotal.Text = dt.Rows.Count.ToString();

            lblActive.Text = dt.Select("IsActive = true").Length.ToString();
            lblInactive.Text = dt.Select("IsActive = false").Length.ToString();
        }


        // ================= SAVE =================
        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (IsSuperAdmin)
            {
                ShowMsg("SuperAdmin is restricted to view only.", false);
                return;
            }

            if (string.IsNullOrWhiteSpace(txtStreamName.Text))
            {
                ShowMsg("Stream name required.", false);
                return;
            }

            if (bl.IsStreamExists(InstituteId, txtStreamName.Text.Trim()))
            {
                ShowMsg("Stream already exists (case-insensitive).", false);
                return;
            }

            if (!System.Text.RegularExpressions.Regex.IsMatch(txtStreamName.Text.Trim(), @"^[A-Za-z\s]+$"))
            {
                ShowMsg("Only alphabets allowed. Numbers and special characters are not permitted.", false);
                return;
            }

            StreamGC model = new StreamGC
            {
                SocietyId = SocietyId,
                InstituteId = InstituteId,
                SessionId = SessionId,
                StreamName = txtStreamName.Text.Trim()
            };

            bl.InsertStream(model);

            txtStreamName.Text = "";
            LoadStreams();
            ShowMsg("Stream added successfully.", true);
        }


        // ================= GRID COMMAND =================
        protected void gvStreams_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (IsSuperAdmin)
            {
                ShowMsg("SuperAdmin cannot perform this action.", false);
                return;
            }

            int id = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "EditRow")
            {
                DataTable dt = bl.GetStreamById(id, InstituteId);

                if (dt.Rows.Count > 0)
                {
                    hfStreamId.Value = id.ToString();
                    txtStreamNameEdit.Text = dt.Rows[0]["StreamName"].ToString();

                    ScriptManager.RegisterStartupScript(
                        this, GetType(), "Edit",
                        "new bootstrap.Modal(document.getElementById('EditModal')).show();", true);
                }
            }
            else if (e.CommandName == "Toggle")
            {
                bl.ToggleStreamStatus(id, InstituteId);
                LoadStreams();
                ShowMsg("Status updated.", true);
            }
            else if (e.CommandName == "DeleteRow")
            {
                string msg;
                bool isDeleted = bl.DeleteStream(id, InstituteId, out msg);

                LoadStreams();
                ShowMsg(msg, isDeleted);
            }
        }

        protected void gvStreams_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow && IsSuperAdmin)
            {
                foreach (Control ctrl in e.Row.Cells[1].Controls)
                {
                    if (ctrl is LinkButton btn)
                    {
                        btn.Enabled = false;
                        btn.CssClass += " disabled";
                    }
                }
            }
        }

        // ================= UPDATE =================
        protected void btnUpdate_Click(object sender, EventArgs e)
        {
            if (IsSuperAdmin)
            {
                ShowMsg("SuperAdmin cannot update data.", false);
                return;
            }

            if (string.IsNullOrEmpty(hfStreamId.Value))
            {
                ShowMsg("Invalid update.", false);
                return;
            }

            if (bl.IsStreamExists(InstituteId, txtStreamNameEdit.Text,
                                  Convert.ToInt32(hfStreamId.Value)))
            {
                ShowMsg("Duplicate stream not allowed.", false);
                return;
            }

            if (!System.Text.RegularExpressions.Regex.IsMatch(txtStreamNameEdit.Text.Trim(), @"^[A-Za-z\s]+$"))
            {
                ShowMsg("Only alphabets allowed. Numbers and special characters are not permitted.", false);
                return;
            }

            StreamGC model = new StreamGC
            {
                StreamId = Convert.ToInt32(hfStreamId.Value),
                InstituteId = InstituteId,
                SessionId = SessionId, 
                StreamName = txtStreamNameEdit.Text.Trim()
            };

            bl.UpdateStream(model);

            LoadStreams();
            ShowMsg("Stream updated.", true);
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
        private void ShowMsg(string msg, bool success)
        {
            msg = msg.Replace("'", "\\'");

            string script = $@"
                setTimeout(function() {{

                    var toastEl = document.getElementById('liveToast');
                    var toastMsg = document.getElementById('toastMsg');

                    if (!toastEl || !toastMsg) return;

                    toastMsg.innerText = '{msg}';

                    toastEl.classList.remove('bg-success','bg-danger');
                    toastEl.classList.add('{(success ? "bg-success" : "bg-danger")}');

                    var toast = bootstrap.Toast.getOrCreateInstance(toastEl, {{
                        delay: 5000
                    }});

                    toast.show();

                }}, 200);
            ";

            ScriptManager.RegisterStartupScript(this, GetType(), Guid.NewGuid().ToString(), script, true);
        }
    }
}