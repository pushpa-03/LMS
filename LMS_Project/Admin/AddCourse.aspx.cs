using LearningManagementSystem.BL;
using LearningManagementSystem.GC;
using System;
using System.Collections.Generic;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace LearningManagementSystem.Admin
{
    public partial class AddCourse : BasePage
    {
        CourseBL bl = new CourseBL();
        private bool IsSuperAdmin => Session["RoleName"]?.ToString() == "SuperAdmin";


        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadStreams();
                LoadCourses();
            }
        }

        // ================= LOAD STREAMS =================
        private void LoadStreams()
        {

            DataTable dt = bl.GetStreams(InstituteId, SessionId);

            ddlStream.DataSource = dt;
            ddlStream.DataTextField = "StreamName";
            ddlStream.DataValueField = "StreamId";
            ddlStream.DataBind();
            ddlStream.Items.Insert(0, new ListItem("-- Select Stream --", ""));

            ddlStreamEdit.DataSource = dt;
            ddlStreamEdit.DataTextField = "StreamName";
            ddlStreamEdit.DataValueField = "StreamId";
            ddlStreamEdit.DataBind();
            ddlStreamEdit.Items.Insert(0, new ListItem("-- Select Stream --", ""));
        }

        // ================= LOAD COURSES =================
        private void LoadCourses(string status = "All")
        {
            
            DataTable dt = bl.GetCourses(InstituteId, SessionId, status);

            // 🔥 SEARCH FILTER
            if (!string.IsNullOrEmpty(txtSearch.Value))
            {
                string search = txtSearch.Value.ToLower();

                var rows = dt.Select($"CourseName LIKE '%{search}%' OR CourseCode LIKE '%{search}%'");
                dt = SafeCopy(rows, dt);
            }


            // ================= STATS =================
            lblTotal.Text = dt.Rows.Count.ToString();
            lblActive.Text = dt.Select("IsActive = true").Length.ToString();
            lblInactive.Text = dt.Select("IsActive = false").Length.ToString();

            rptCourseSuggestions.DataSource = dt;
            rptCourseSuggestions.DataBind();

            // ================= GROUP STREAM =================
            DataTable streamTable = new DataTable();
            streamTable.Columns.Add("StreamId");
            streamTable.Columns.Add("StreamName");
            streamTable.Columns.Add("CourseCount");
            streamTable.Columns.Add("Courses", typeof(DataTable)); // 🔥 key

            DataView view = new DataView(dt);
            DataTable distinctStreams = view.ToTable(true, "StreamId", "StreamName");

            foreach (DataRow row in distinctStreams.Rows)
            {
                string streamId = row["StreamId"].ToString();

                DataRow newRow = streamTable.NewRow();
                newRow["StreamId"] = streamId;
                newRow["StreamName"] = row["StreamName"];

                DataRow[] rows = dt.Select("StreamId=" + streamId);

                newRow["CourseCount"] = rows.Length;

                if (rows.Length > 0)
                    newRow["Courses"] = rows.CopyToDataTable();

                streamTable.Rows.Add(newRow);
            }

            rptStreams.DataSource = streamTable;
            rptStreams.DataBind();
        }

        // ================= SAVE =================
        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (IsSuperAdmin)
            {
                ShowMsg("SuperAdmin has view-only access.", false);
                return;
            }

            if (ddlStream.SelectedValue == "" ||
                string.IsNullOrWhiteSpace(txtCourseName.Text))
            {
                ShowMsg("All fields required.", false);
                return;
            }

            CourseGC c = new CourseGC
            {
                SocietyId = Convert.ToInt32(Session["SocietyId"]),
                InstituteId = InstituteId,
                SessionId = SessionId,
                StreamId = Convert.ToInt32(ddlStream.SelectedValue),
                CourseName = txtCourseName.Text.Trim(),
                CourseCode = txtCourseCode.Text.Trim()
            };

            if (bl.IsCourseExists(InstituteId, SessionId, Convert.ToInt32(ddlStream.SelectedValue), txtCourseName.Text))
            {
                ShowMsg("Duplicate course not allowed in same stream.", false);
                return;
            }

            bl.Insert(c);

            txtCourseName.Text = "";
            txtCourseCode.Text = "";
            ddlStream.SelectedIndex = 0;

            LoadCourses();
            ShowMsg("Course added successfully.", true);
        }

        // ================= GRID COMMAND =================
        protected void gvCourses_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandArgument == null || !int.TryParse(e.CommandArgument.ToString(), out int id))
            {
                ShowMsg("Invalid course.", false);
                return;
            }


            if (e.CommandName == "EditRow")
            {
                if (IsSuperAdmin)
                {
                    ShowMsg("SuperAdmin has view-only access.", false);
                    return;
                }

                DataTable dt = bl.GetById(id, InstituteId,SessionId);

                if (dt != null && dt.Rows.Count > 0)
                {
                    hfCourseId.Value = id.ToString();
                    ddlStreamEdit.SelectedValue = dt.Rows[0]["StreamId"].ToString();
                    txtCourseNameEdit.Text = dt.Rows[0]["CourseName"].ToString();
                    txtCourseCodeEdit.Text = dt.Rows[0]["CourseCode"].ToString();

                    ScriptManager.RegisterStartupScript(
                        this, GetType(),
                        "edit",
                        "var m=new bootstrap.Modal(document.getElementById('EditModal'));m.show();",
                        true);
                }
            }
            else if (e.CommandName == "Toggle")
            {
                if (IsSuperAdmin)
                {
                    ShowMsg("SuperAdmin has view-only access.", false);
                    return;
                }

                bl.Toggle(id, InstituteId, SessionId);
                LoadCourses();
                ShowMsg("Status Changes successfully.", true);
            }
            else if (e.CommandName == "DeleteRow")
            {
                try
                {
                    if (IsSuperAdmin)
                    {
                        ShowMsg("SuperAdmin has view-only access.", false);
                        return;
                    }

                    bl.Delete(id, InstituteId, SessionId);
                    LoadCourses();
                    ShowMsg("Course deleted successfully.", true);
                }
                catch (Exception ex)
                {
                    if (ex.InnerException != null && ex.InnerException.Message.Contains("FOREIGN KEY"))
                    {
                        ShowMsg("Course is used in other modules. You can't delete it. Please inactive it.", false);
                    }
                    else
                    {
                        ShowMsg("Something went wrong.", false);
                    }
                }
            }
        }

        protected void gvCourses_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (IsSuperAdmin && e.Row.RowType == DataControlRowType.DataRow)
            {
                foreach (Control c in e.Row.Cells[2].Controls)
                {
                    if (c is LinkButton btn)
                    {
                        btn.Enabled = false;
                        btn.CssClass += " disabled";
                    }
                }
            }
        }

        protected void rptStreams_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item ||
                e.Item.ItemType == ListItemType.AlternatingItem)
            {
                DataRowView drv = (DataRowView)e.Item.DataItem;

                GridView gv = (GridView)e.Item.FindControl("gvInnerCourses");

                if (drv["Courses"] != DBNull.Value)
                {
                    gv.DataSource = (DataTable)drv["Courses"];
                    gv.DataBind();
                }
            }
        }
        // ================= UPDATE =================
        protected void btnUpdate_Click(object sender, EventArgs e)
        {
            if (IsSuperAdmin)
            {
                ShowMsg("SuperAdmin has view-only access.", false);
                return;
            }

            if (string.IsNullOrEmpty(hfCourseId.Value) ||
                ddlStreamEdit.SelectedValue == "")
            {
                ShowMsg("All fields required.", false);
                return;
            }

            CourseGC c = new CourseGC
            {
                CourseId = Convert.ToInt32(hfCourseId.Value),
                InstituteId = InstituteId,
                SessionId = SessionId,
                StreamId = Convert.ToInt32(ddlStreamEdit.SelectedValue),
                CourseName = txtCourseNameEdit.Text.Trim(),
                CourseCode = txtCourseCodeEdit.Text.Trim()
            };

            if (bl.IsCourseExists(InstituteId, SessionId,
                Convert.ToInt32(ddlStreamEdit.SelectedValue),
                txtCourseNameEdit.Text,
                Convert.ToInt32(hfCourseId.Value)))
            {
                ShowMsg("Duplicate course not allowed in same stream.", false);
                return;
            }

            bl.Update(c);

            LoadCourses();
            ShowMsg("Course updated successfully.", true);
        }

        // ================= FILTER =================
        protected void FilterStatus_Click(object sender, EventArgs e)
        {
            LinkButton btn = (LinkButton)sender;
            LoadCourses(btn.CommandArgument);
        }

        private DataTable SafeCopy(DataRow[] rows, DataTable original)
        {
            return rows.Length > 0 ? rows.CopyToDataTable() : original.Clone();
        }
        protected void gvCourses_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            GridView gv = (GridView)sender;

            gv.PageIndex = e.NewPageIndex;

            RepeaterItem item = (RepeaterItem)gv.NamingContainer;
            DataRowView drv = (DataRowView)item.DataItem;

            if (drv["Courses"] != DBNull.Value)
            {
                gv.DataSource = (DataTable)drv["Courses"];
                gv.DataBind();
            }
        }

        protected void ddlFromSession_SelectedIndexChanged(object sender, EventArgs e)
        {
            int sessionId = Convert.ToInt32(ddlFromSession.SelectedValue);

            gvMappingCourses.DataSource = bl.GetCoursesForMapping(InstituteId, sessionId);
            gvMappingCourses.DataBind();
        }

        protected void btnCopyAll_Click(object sender, EventArgs e)
        {
            int fromSession = Convert.ToInt32(ddlFromSession.SelectedValue);
            int toSession = Convert.ToInt32(ddlToSession.SelectedValue);

            bl.CopyAllCoursesToNextSession(InstituteId, fromSession);

            bl.LogActivity(
                Convert.ToInt32(Session["UserId"]),
                Convert.ToInt32(Session["SocietyId"]),
                InstituteId,
                toSession,
                "Copied ALL courses to new session"
            );

            ShowMsg("All courses copied successfully!", true);
        }

        protected void btnCopySelected_Click(object sender, EventArgs e)
        {
            List<int> selected = new List<int>();

            foreach (GridViewRow row in gvMappingCourses.Rows)
            {
                CheckBox chk = (CheckBox)row.FindControl("chkSelect");
                HiddenField hf = (HiddenField)row.FindControl("hfCourseId");

                if (chk.Checked)
                    selected.Add(Convert.ToInt32(hf.Value));
            }

            if (selected.Count == 0)
            {
                ShowMsg("Select at least one course.", false);
                return;
            }

            int fromSession = Convert.ToInt32(ddlFromSession.SelectedValue);
            int toSession = Convert.ToInt32(ddlToSession.SelectedValue);

            bl.CopySelectedCourses(selected, InstituteId, fromSession, toSession);

            bl.LogActivity(
                Convert.ToInt32(Session["UserId"]),
                Convert.ToInt32(Session["SocietyId"]),
                InstituteId,
                toSession,
                $"Copied {selected.Count} selected courses"
            );

            ShowMsg("Selected courses copied successfully!", true);
        }



        // ================= MESSAGE =================
        private void ShowMsg(string msg, bool success)
        {
            msg = msg.Replace("'", "\\'");

            string script = $@"
        setTimeout(function () {{

            var toastEl = document.getElementById('liveToast');
            var toastMsg = document.getElementById('toastMsg');

            if (!toastEl || !toastMsg) return;

            toastMsg.innerText = '{msg}';

            toastEl.classList.remove('bg-success','bg-danger');
            toastEl.classList.add('{(success ? "bg-success" : "bg-danger")}');

            var toast = bootstrap.Toast.getOrCreateInstance(toastEl, {{
                delay: 4000,
                autohide: true
            }});

            toast.show();

        }}, 300);
    ";

            ScriptManager.RegisterStartupScript(
                this,
                this.GetType(),
                Guid.NewGuid().ToString(),
                script,
                true
            );
        }
    }
}