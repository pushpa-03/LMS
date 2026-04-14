using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using LearningManagementSystem.BL;
using LearningManagementSystem.GC;

namespace LearningManagementSystem.Admin
{
    public partial class AddCourse : BasePage
    {
        CourseBL bl = new CourseBL();

        protected void Page_Load(object sender, EventArgs e)
        {
            //if (Session["InstituteId"] == null)
            //{
            //    Response.Redirect("~/Default.aspx");
            //    return;
            //}
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
            int id = Convert.ToInt32(e.CommandArgument);
          

            if (e.CommandName == "EditRow")
            {
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
                bl.Toggle(id, InstituteId, SessionId);
                LoadCourses();
            }
            else if (e.CommandName == "DeleteRow")
            {
                bl.Delete(id, InstituteId, SessionId);
                LoadCourses();
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
        // ================= MESSAGE =================
        private void ShowMsg(string msg, bool isSuccess)
        {
            string script = $@"
                var toastEl = document.getElementById('liveToast');
                var toastMsg = document.getElementById('toastMsg');
                toastMsg.innerText = '{msg}';
                toastEl.classList.remove('bg-success','bg-danger');
                toastEl.classList.add('{(isSuccess ? "bg-success" : "bg-danger")}');
                var toast = new bootstrap.Toast(toastEl);
                toast.show();
            ";

            ScriptManager.RegisterStartupScript(this, GetType(), "toast", script, true);
        }
    }
}