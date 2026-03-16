using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace LMS_Project.Student
{
    public partial class Assignments : System.Web.UI.Page
    {
        StudentAssignmentBL bl = new StudentAssignmentBL();

        private int _userId;
        private int _instituteId;
        private int _societyId;
        private int _sessionId;

        protected void Page_Load(object sender, EventArgs e)
        {
            _userId = Convert.ToInt32(Session["UserId"]);
            _instituteId = Convert.ToInt32(Session["InstituteId"]);
            _societyId = Convert.ToInt32(Session["SocietyId"]);

            StudentSubjectsBL subBL = new StudentSubjectsBL();
            _sessionId = Session["CurrentSessionId"] != null
                         ? Convert.ToInt32(Session["CurrentSessionId"])
                         : subBL.GetCurrentSessionId(_instituteId);

            if (!IsPostBack)
            {
                LoadSummary();
                LoadSubjectFilter();
                LoadAssignments();
            }
        }

        // ============================================================
        // Summary chips
        // ============================================================
        private void LoadSummary()
        {
            DataTable dt = bl.GetAssignmentCounts(_userId, _instituteId, _sessionId);

            if (dt.Rows.Count == 0) return;

            DataRow r = dt.Rows[0];
            lblTotal.Text = r["Total"].ToString();
            lblPending.Text = r["Pending"].ToString();
            lblSubmitted.Text = r["Submitted"].ToString();
            lblOverdue.Text = r["Overdue"].ToString();
        }

        // ============================================================
        // Subject filter dropdown
        // ============================================================
        private void LoadSubjectFilter()
        {
            DataTable dt = bl.GetEnrolledSubjectsForFilter(
                               _userId, _instituteId, _sessionId);

            ddlSubjectFilter.Items.Clear();
            ddlSubjectFilter.Items.Add(new ListItem("All Subjects", "0"));

            foreach (DataRow r in dt.Rows)
            {
                ddlSubjectFilter.Items.Add(
                    new ListItem(
                        r["SubjectCode"] + " — " + r["SubjectName"],
                        r["SubjectId"].ToString()
                    )
                );
            }
        }

        // ============================================================
        // Load & bind assignments
        // ============================================================
        private void LoadAssignments()
        {
            string status = ddlStatusFilter.SelectedValue;
            int subjectId = Convert.ToInt32(ddlSubjectFilter.SelectedValue);

            DataTable dt = bl.GetAssignments(
                               _userId, _instituteId, _sessionId,
                               status, subjectId);

            if (dt.Rows.Count > 0)
            {
                rptAssignments.DataSource = dt;
                rptAssignments.DataBind();
                pnlAssignments.Visible = true;
                pnlEmpty.Visible = false;
            }
            else
            {
                pnlAssignments.Visible = false;
                pnlEmpty.Visible = true;

                string msg = status == "All"
                    ? "No assignments have been posted yet."
                    : $"No <strong>{status}</strong> assignments found.";
                emptyMsg.InnerHtml = msg;
            }
        }

        // ============================================================
        // Filter dropdowns changed
        // ============================================================
        protected void ddlFilter_Changed(object sender, EventArgs e)
        {
            LoadAssignments();
        }

        // ============================================================
        // Reset filters
        // ============================================================
        protected void btnResetFilter_Click(object sender, EventArgs e)
        {
            ddlStatusFilter.SelectedValue = "All";
            ddlSubjectFilter.SelectedIndex = 0;
            LoadAssignments();
        }

        // ============================================================
        // Repeater item command — open submit modal
        // ============================================================
        protected void rptAssignments_ItemCommand(object source,
            RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "Submit") return;

            // Parse "AssignmentId|Title" from CommandArgument
            string[] parts = e.CommandArgument.ToString().Split('|');
            int assignmentId = Convert.ToInt32(parts[0]);

            hfAssignmentId.Value = assignmentId.ToString();
            hfAssignmentTitle.Value = parts.Length > 1 ? parts[1] : "";

            // Get full assignment details for modal
            DataTable dt = bl.GetAssignmentById(assignmentId);

            if (dt.Rows.Count > 0)
            {
                DataRow r = dt.Rows[0];

                // Pass info to modal via JS
                string script = $@"
                openSubmitModal(
                    '{assignmentId}',
                    '{EscapeJs(r["Title"].ToString())}',
                    '{EscapeJs(r["SubjectCode"] + " — " + r["SubjectName"])}',
                    '{Convert.ToDateTime(r["DueDate"]):dd MMM yyyy}',
                    '{r["MaxMarks"]}'
                );";

                ScriptManager.RegisterStartupScript(
                    this, GetType(), "openModal", script, true);
            }
        }

        // ============================================================
        // Confirm submit button click
        // ============================================================
        protected void btnConfirmSubmit_Click(object sender, EventArgs e)
        {
            int assignmentId = Convert.ToInt32(hfAssignmentId.Value);

            if (assignmentId == 0)
            {
                ShowModalMsg("Invalid assignment. Please try again.", false);
                return;
            }

            if (!fuAssignment.HasFile)
            {
                ShowModalMsg("Please select a file to upload.", false);
                return;
            }

            long fileSize = fuAssignment.PostedFile.ContentLength;
            if (fileSize > 10 * 1024 * 1024) // 10 MB
            {
                ShowModalMsg("File size must be under 10 MB.", false);
                return;
            }

            try
            {
                bool success = bl.SubmitAssignment(
                    assignmentId,
                    _userId,
                    _societyId,
                    _instituteId,
                    fuAssignment.PostedFile,
                    txtRemarks.Text.Trim(),
                    Server
                );

                if (success)
                {
                    ShowMsg("Assignment submitted successfully! ✅", true);
                    LoadSummary();
                    LoadAssignments();

                    // Close modal
                    ScriptManager.RegisterStartupScript(
                        this, GetType(), "closeModal",
                        "bootstrap.Modal.getInstance(document.getElementById('submitModal'))?.hide();",
                        true);
                }
                else
                {
                    ShowModalMsg("You have already submitted this assignment.", false);
                }
            }
            catch (Exception ex)
            {
                ShowModalMsg("Error: " + ex.Message, false);
            }
        }

        // ============================================================
        // Helpers
        // ============================================================
        protected string GetDueLabel(int daysRemaining, string status)
        {
            if (status == "Submitted")
                return "";

            if (status == "Overdue")
                return $"<span class='due-overdue'><i class='fas fa-exclamation-circle me-1'></i>{Math.Abs(daysRemaining)} days overdue</span>";

            if (daysRemaining == 0)
                return "<span class='due-soon'>Due Today!</span>";

            if (daysRemaining <= 3)
                return $"<span class='due-soon'><i class='fas fa-fire me-1'></i>{daysRemaining} days left</span>";

            return $"<span class='due-normal'><i class='fas fa-calendar me-1'></i>{daysRemaining} days left</span>";
        }

        private void ShowMsg(string msg, bool success)
        {
            lblMsg.Text = msg;
            lblMsg.CssClass = success
                ? "alert alert-success d-block mb-3"
                : "alert alert-danger d-block mb-3";
            lblMsg.Visible = true;
        }

        private void ShowModalMsg(string msg, bool success)
        {
            lblModalMsg.Text = msg;
            lblModalMsg.CssClass = success
                ? "alert alert-success d-block"
                : "alert alert-danger d-block";
            lblModalMsg.Visible = true;

            // Re-open modal on postback
            ScriptManager.RegisterStartupScript(
                this, GetType(), "reopenModal",
                "new bootstrap.Modal(document.getElementById('submitModal')).show();",
                true);
        }

        private string EscapeJs(string s)
        {
            return s?.Replace("'", "\\'").Replace("\r", "").Replace("\n", " ") ?? "";
        }
    }
}