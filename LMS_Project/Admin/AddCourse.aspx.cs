using LearningManagementSystem.BL;
using LearningManagementSystem.GC;
using System;
using System.Data;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace LearningManagementSystem.Admin
{
    public partial class AddCourse : BasePage
    {
        // ── BL ────────────────────────────────────────────────────────────────
        private readonly CourseBL bl = new CourseBL();

        // ── Role guard ────────────────────────────────────────────────────────
        public bool IsSuperAdmin => Session["Role"]?.ToString() == "SuperAdmin";

        // ═════════════════════════════════════════════════════════════════════
        //  PAGE LOAD
        // ═════════════════════════════════════════════════════════════════════
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadStreams();
            }

            // Always reload courses on every request (postback or not)
            LoadCourses();
        }

        // ═════════════════════════════════════════════════════════════════════
        //  LOAD STREAMS — populates both Add and Edit modal dropdowns
        // ═════════════════════════════════════════════════════════════════════
        private void LoadStreams()
        {
            DataTable dt = bl.GetStreams(InstituteId, SessionId);

            ddlStream.Items.Clear();
            ddlStream.DataSource = dt;
            ddlStream.DataTextField = "StreamName";
            ddlStream.DataValueField = "StreamId";
            ddlStream.DataBind();
            ddlStream.Items.Insert(0, new ListItem("-- Select Stream --", ""));

            ddlStreamEdit.Items.Clear();
            ddlStreamEdit.DataSource = dt;
            ddlStreamEdit.DataTextField = "StreamName";
            ddlStreamEdit.DataValueField = "StreamId";
            ddlStreamEdit.DataBind();
            ddlStreamEdit.Items.Insert(0, new ListItem("-- Select Stream --", ""));
        }

        // ═════════════════════════════════════════════════════════════════════
        //  LOAD COURSES
        //  All pagination and status filtering is handled client-side in JS.
        //  Server only applies the search box filter, then groups by stream
        //  and binds the repeater with ALL matching streams at once.
        // ═════════════════════════════════════════════════════════════════════
        private void LoadCourses()
        {
            // 1. Fetch full dataset (status filter is done in JS)
            DataTable dt = bl.GetCourses(InstituteId, SessionId, "All");

            // 2. Server-side search (txtSearch is an HtmlInputText / runat=server)
            string search = txtSearch.Value?.Trim().ToLower() ?? "";
            if (!string.IsNullOrEmpty(search))
            {
                var filtered = dt.AsEnumerable()
                    .Where(r => r["CourseName"].ToString().ToLower().Contains(search)
                             || r["CourseCode"].ToString().ToLower().Contains(search));
                dt = filtered.Any() ? filtered.CopyToDataTable() : dt.Clone();
            }

            // 3. Stats
            lblTotal.Text = dt.Rows.Count.ToString();
            lblActive.Text = dt.Select("IsActive = true").Length.ToString();
            lblInactive.Text = dt.Select("IsActive = false").Length.ToString();

            // 4. Build stream-grouped DataTable (ALL streams — JS pages them)
            DataTable streamTable = BuildStreamTable(dt);

            // 5. Info bar
            int totalStreams = streamTable.Rows.Count;
            int totalCourses = dt.Rows.Count;
            lblTotalStreams.Text = totalStreams.ToString();
            lblTotalCourses.Text = totalCourses.ToString();
            lblRangeFrom.Text = totalStreams == 0 ? "0" : "1";
            lblRangeTo.Text = totalStreams.ToString();

            // 6. Bind repeater
            rptStreams.DataSource = streamTable;
            rptStreams.DataBind();
        }

        // ── Build stream→courses grouped DataTable ────────────────────────────
        private DataTable BuildStreamTable(DataTable courseRows)
        {
            DataTable st = new DataTable();
            st.Columns.Add("StreamId");
            st.Columns.Add("StreamName");
            st.Columns.Add("CourseCount", typeof(int));
            st.Columns.Add("Courses", typeof(DataTable));

            if (courseRows.Rows.Count == 0) return st;

            DataTable distinctStreams = new DataView(courseRows)
                .ToTable(true, "StreamId", "StreamName");

            foreach (DataRow row in distinctStreams.Rows)
            {
                string sid = row["StreamId"].ToString();
                DataRow[] rows = courseRows.Select("StreamId=" + sid);

                DataRow nr = st.NewRow();
                nr["StreamId"] = sid;
                nr["StreamName"] = row["StreamName"];
                nr["CourseCount"] = rows.Length;
                if (rows.Length > 0)
                    nr["Courses"] = rows.CopyToDataTable();
                st.Rows.Add(nr);
            }
            return st;
        }

        // ═════════════════════════════════════════════════════════════════════
        //  ITEM DATABOUND — bind inner course Repeater for each stream row
        // ═════════════════════════════════════════════════════════════════════
        protected void rptStreams_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item &&
                e.Item.ItemType != ListItemType.AlternatingItem) return;

            DataRowView drv = (DataRowView)e.Item.DataItem;
            Repeater rptC = (Repeater)e.Item.FindControl("rptCourses");
            if (rptC == null) return;

            if (drv["Courses"] != DBNull.Value)
            {
                rptC.DataSource = (DataTable)drv["Courses"];
                rptC.DataBind();
            }
            else
            {
                rptC.DataSource = new DataTable();
                rptC.DataBind();
            }
        }

        // ═════════════════════════════════════════════════════════════════════
        //  INNER COURSE REPEATER — Edit / Toggle / Delete
        // ═════════════════════════════════════════════════════════════════════
        protected void rptCourses_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (!int.TryParse(e.CommandArgument?.ToString(), out int id))
            {
                ShowMsg("Invalid course.", false);
                return;
            }

            switch (e.CommandName)
            {
                case "EditRow": HandleEdit(id); break;
                case "Toggle": HandleToggle(id); break;
                case "DeleteRow": HandleDelete(id); break;
            }
        }

        private void HandleEdit(int id)
        {
            if (IsSuperAdmin) { ShowMsg("SuperAdmin has view-only access.", false); return; }

            DataTable dt = bl.GetById(id, InstituteId, SessionId);
            if (dt == null || dt.Rows.Count == 0) return;

            DataRow r = dt.Rows[0];
            hfCourseId.Value = id.ToString();

            SafeSelect(ddlStreamEdit, r["StreamId"].ToString());
            txtCourseNameEdit.Text = r["CourseName"].ToString();
            txtCourseCodeEdit.Text = r["CourseCode"].ToString();

            ScriptManager.RegisterStartupScript(this, GetType(), "editModal",
                "var m=new bootstrap.Modal(document.getElementById('EditModal'));m.show();",
                true);
        }

        private void HandleToggle(int id)
        {
            if (IsSuperAdmin) { ShowMsg("SuperAdmin has view-only access.", false); return; }
            bl.Toggle(id, InstituteId, SessionId);
            LogActivity(UserId, SocietyId, InstituteId, SessionId, "Course Status Changed", id);
            ShowMsg("Status changed successfully.", true);
        }

        private void HandleDelete(int id)
        {
            if (IsSuperAdmin) { ShowMsg("SuperAdmin has view-only access.", false); return; }

            bool ok = bl.Delete(id, InstituteId, SessionId, out string msg);
            if (ok)
                LogActivity(UserId, SocietyId, InstituteId, SessionId, "Course Deleted", id);

            // Refresh dropdowns in case a stream becomes empty
            LoadStreams();
            ShowMsg(msg, ok);
        }

        // ═════════════════════════════════════════════════════════════════════
        //  SAVE (INSERT)
        // ═════════════════════════════════════════════════════════════════════
        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (IsSuperAdmin) { ShowMsg("SuperAdmin has view-only access.", false); return; }

            string name = txtCourseName.Text.Trim();
            string code = txtCourseCode.Text.Trim();

            if (ddlStream.SelectedValue == "" || string.IsNullOrWhiteSpace(name))
            { ShowMsg("Please select a stream and enter a course name.", false); return; }

            if (!IsValidCourseName(name))
            { ShowMsg("Course name must start with a letter and contain no special characters.", false); return; }

            if (!string.IsNullOrWhiteSpace(code) && !IsValidCourseCode(code))
            { ShowMsg("Course code must contain only letters and numbers.", false); return; }

            int streamId = Convert.ToInt32(ddlStream.SelectedValue);

            if (bl.IsCourseExists(InstituteId, SessionId, streamId, name))
            { ShowMsg("A course with this name already exists in the selected stream.", false); return; }

            bl.Insert(new CourseGC
            {
                SocietyId = SocietyId,
                InstituteId = InstituteId,
                SessionId = SessionId,
                StreamId = streamId,
                CourseName = name,
                CourseCode = code
            });

            LogActivity(UserId, SocietyId, InstituteId, SessionId, "Course Created: " + name, 0);

            txtCourseName.Text = "";
            txtCourseCode.Text = "";
            ddlStream.SelectedIndex = 0;

            ShowMsg("Course added successfully.", true);
        }

        // ═════════════════════════════════════════════════════════════════════
        //  UPDATE
        // ═════════════════════════════════════════════════════════════════════
        protected void btnUpdate_Click(object sender, EventArgs e)
        {
            if (IsSuperAdmin) { ShowMsg("SuperAdmin has view-only access.", false); return; }

            if (string.IsNullOrEmpty(hfCourseId.Value) || ddlStreamEdit.SelectedValue == "")
            { ShowMsg("All fields are required.", false); return; }

            string name = txtCourseNameEdit.Text.Trim();
            string code = txtCourseCodeEdit.Text.Trim();
            int courseId = Convert.ToInt32(hfCourseId.Value);

            if (!IsValidCourseName(name))
            { ShowMsg("Invalid course name.", false); return; }

            if (!string.IsNullOrWhiteSpace(code) && !IsValidCourseCode(code))
            { ShowMsg("Invalid course code.", false); return; }

            int streamId = Convert.ToInt32(ddlStreamEdit.SelectedValue);

            if (bl.IsCourseExists(InstituteId, SessionId, streamId, name, courseId))
            { ShowMsg("A course with this name already exists in the selected stream.", false); return; }

            bl.Update(new CourseGC
            {
                CourseId = courseId,
                InstituteId = InstituteId,
                SessionId = SessionId,
                StreamId = streamId,
                CourseName = name,
                CourseCode = code
            });

            LogActivity(UserId, SocietyId, InstituteId, SessionId, "Course Updated: " + name, courseId);
            ShowMsg("Course updated successfully.", true);
        }

        // ═════════════════════════════════════════════════════════════════════
        //  HELPERS
        // ═════════════════════════════════════════════════════════════════════

        private static void SafeSelect(DropDownList ddl, string value)
        {
            if (ddl == null) return;
            foreach (ListItem item in ddl.Items) item.Selected = false;
            ListItem match = ddl.Items.FindByValue(value);
            if (match != null) match.Selected = true;
        }

        private static bool IsValidCourseName(string name) =>
            System.Text.RegularExpressions.Regex.IsMatch(name, @"^[A-Za-z][A-Za-z0-9 ]*$");

        private static bool IsValidCourseCode(string code) =>
            System.Text.RegularExpressions.Regex.IsMatch(code, @"^[A-Za-z0-9]+$");

        private void ShowMsg(string msg, bool success)
        {
            hfToastMsg.Value = msg;
            hfToastType.Value = success ? "success" : "error";

            string escaped = msg.Replace("'", "\\'");
            ScriptManager.RegisterStartupScript(this, GetType(),
                "toast_" + Guid.NewGuid().ToString("N").Substring(0, 6),
                $"document.addEventListener('DOMContentLoaded',function(){{" +
                $"showToast('{escaped}','{(success ? "success" : "error")}');}});",
                true);
        }
    }
}