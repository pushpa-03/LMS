using LearningManagementSystem.BL;
using LearningManagementSystem.GC;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace LearningManagementSystem.Admin
{
    public partial class AddCourse : BasePage
    {
        CourseBL bl = new CourseBL();
        public bool IsSuperAdmin => Session["Role"]?.ToString() == "SuperAdmin";


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

                //var rows = dt.Select($"CourseName LIKE '%{search}%' OR CourseCode LIKE '%{search}%'");
                //dt = SafeCopy(rows, dt);

                var filtered = dt.AsEnumerable()
                .Where(r => r["CourseName"].ToString().ToLower().Contains(search)
                         || r["CourseCode"].ToString().ToLower().Contains(search));

                 dt = filtered.Any() ? filtered.CopyToDataTable() : dt.Clone();
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

            if (!IsValidCourseName(txtCourseName.Text))
            {
                ShowMsg("Course name must start with letter and no special characters.", false);
                return;
            }

            if (!string.IsNullOrWhiteSpace(txtCourseCode.Text) && !IsValidCourseCode(txtCourseCode.Text))
            {
                ShowMsg("Course code must contain only letters and numbers.", false);
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

            //LoadActivity method implemented in BaseBL.cs page
            LogActivity(UserId, SocietyId, InstituteId, SessionId,
                "Course Created: " + c.CourseName, 0);

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

                //LoadActivity method implemented in BaseBL.cs page
                LogActivity(UserId, SocietyId, InstituteId, SessionId,
                    "Course Status Changed", id);

                LoadCourses();
                ShowMsg("Status Changes successfully.", true);
            }
            else if (e.CommandName == "DeleteRow")
            {

                if (IsSuperAdmin)
                {
                    ShowMsg("SuperAdmin has view-only access.", false);
                    return;
                }

                string msg;
                bool isDeleted = bl.Delete(id, InstituteId, SessionId, out msg);

                if (isDeleted)
                {
                    //LoadActivity method implemented in BaseBL.cs page
                    LogActivity(UserId, SocietyId, InstituteId, SessionId,
                        "Course Deleted", id);
                }
                LoadStreams();
                ShowMsg(msg, isDeleted);

            }
        }

        protected void gvCourses_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (IsSuperAdmin && e.Row.RowType == DataControlRowType.DataRow)
            {
                e.Row.Cells[2].Controls.Clear(); // ❌ remove buttons completely

                Literal l = new Literal();
                l.Text = "<span class='text-muted'>View Only</span>";
                e.Row.Cells[2].Controls.Add(l);
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

            if (!IsValidCourseName(txtCourseNameEdit.Text))
            {
                ShowMsg("Invalid course name.", false);
                return;
            }

            if (!string.IsNullOrWhiteSpace(txtCourseCodeEdit.Text) && !IsValidCourseCode(txtCourseCodeEdit.Text))
            {
                ShowMsg("Invalid course code.", false);
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

            //LoadActivity method implemented in BaseBL.cs page
            LogActivity(UserId, SocietyId, InstituteId, SessionId,
                "Course Updated: " + c.CourseName, c.CourseId);

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

        private bool IsValidCourseName(string name)
        {
            return System.Text.RegularExpressions.Regex
                .IsMatch(name, @"^[A-Za-z][A-Za-z0-9 ]*$");
        }

        private bool IsValidCourseCode(string code)
        {
            return System.Text.RegularExpressions.Regex
                .IsMatch(code, @"^[A-Za-z0-9]+$");
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