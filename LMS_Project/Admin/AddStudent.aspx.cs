using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.IO;
using ExcelDataReader;

namespace LearningManagementSystem.Admin
{
    public partial class Student : Page
    {
        StudentBL bl = new StudentBL();

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
                LoadStudyLevels();   // ADD
                LoadSemesters();     // ADD
                LoadSections();
                LoadEditDropdowns();
                LoadStudents();
            }
        }

        private void LoadStudents(string search = "", string status = "All")
        {
            int instituteId = Convert.ToInt32(Session["InstituteId"]);
            gvStudents.DataSource = bl.GetStudents(instituteId, search, status);
            gvStudents.DataBind();
        }


        protected void btnUploadBulk_Click(object sender, EventArgs e)
        {
            if (!fuBulk.HasFile)
            {
                ShowMsg("Please select CSV or Excel file.", false);
                return;
            }

            try
            {
                int societyId = Convert.ToInt32(Session["SocietyId"]);
                int instituteId = Convert.ToInt32(Session["InstituteId"]);

                int successCount = 0;
                int duplicateCount = 0;

                List<string> duplicateStudents = new List<string>();

                DataTable dt = new DataTable();

                string ext = Path.GetExtension(fuBulk.FileName).ToLower();

                // ================= READ FILE =================
                if (ext == ".csv")
                {
                    using (StreamReader sr = new StreamReader(fuBulk.FileContent))
                    {
                        bool isFirstRow = true;

                        while (!sr.EndOfStream)
                        {
                            string line = sr.ReadLine();
                            string[] cols = line.Split(',');

                            if (isFirstRow)
                            {
                                // Create columns from header
                                foreach (string col in cols)
                                    dt.Columns.Add(col);

                                isFirstRow = false;
                            }
                            else
                            {
                                if (cols.Length >= 12) // we access index 0–11
                                    dt.Rows.Add(cols);
                            }
                        }
                    }
                }
                else if (ext == ".xlsx" || ext == ".xls")
                {
                    using (var stream = fuBulk.FileContent)
                    using (var reader = ExcelReaderFactory.CreateReader(stream))
                    {
                        var result = reader.AsDataSet(new ExcelDataSetConfiguration()
                        {
                            ConfigureDataTable = (_) => new ExcelDataTableConfiguration()
                            {
                                UseHeaderRow = true
                            }
                        });

                        dt = result.Tables[0];
                    }
                }
                else
                {
                    ShowMsg("Only CSV or Excel files allowed.", false);
                    return;
                }

                // ================= PROCESS ROWS =================

                foreach (DataRow row in dt.Rows)
                {
                    string username = row[0].ToString().Trim();
                    string email = row[1].ToString().Trim();
                    string fullName = row[2].ToString().Trim();
                    string rollNo = row[3].ToString().Trim();

                    int? streamId = string.IsNullOrWhiteSpace(row[4].ToString()) ? (int?)null : Convert.ToInt32(row[4]);
                    int? levelId = string.IsNullOrWhiteSpace(row[5].ToString()) ? (int?)null : Convert.ToInt32(row[5]);
                    int? semesterId = string.IsNullOrWhiteSpace(row[6].ToString()) ? (int?)null : Convert.ToInt32(row[6]);
                    int? courseId = string.IsNullOrWhiteSpace(row[7].ToString()) ? (int?)null : Convert.ToInt32(row[7]);
                    int? sectionId = string.IsNullOrWhiteSpace(row[8].ToString()) ? (int?)null : Convert.ToInt32(row[8]);

                    string gender = row[9].ToString().Trim();

                    DateTime dob;
                    DateTime.TryParse(row[10].ToString(), out dob);

                    string contact = row[11].ToString().Trim();

                    // 🔎 Duplicate check
                    if (bl.StudentExists(username, email, rollNo, instituteId))
                    {
                        duplicateCount++;
                        duplicateStudents.Add(fullName + " (" + rollNo + ")");
                        continue;
                    }

                    bl.InsertStudent(
                        societyId,
                        instituteId,
                        username,
                        email,
                        fullName,
                        gender,
                        dob,
                        contact,
                        streamId,
                        levelId,
                        semesterId,
                        courseId,
                        sectionId,
                        rollNo
                    );

                    successCount++;
                }

                LoadStudents();

                string msg = successCount + " Students Uploaded Successfully.";

                if (duplicateCount > 0)
                {
                    msg += "<br/>" + duplicateCount + " Duplicate Students Ignored:<br/>"
                           + string.Join("<br/>", duplicateStudents);
                }

                ShowMsg(msg, true);
            }
            catch (Exception ex)
            {
                ShowMsg("Bulk Upload Failed: " + ex.Message, false);
            }
        }

        // ================= SAVE =================

        protected void btnSave_Click(object sender, EventArgs e)
        {
            try
            {
                int societyId = Convert.ToInt32(Session["SocietyId"]);
                int instituteId = Convert.ToInt32(Session["InstituteId"]);

                bl.InsertStudent(
                     societyId,
                     instituteId,
                     txtUsername.Text.Trim(),
                     txtEmail.Text.Trim(),
                     txtFullName.Text.Trim(),
                     ddlGender.SelectedValue,
                     Convert.ToDateTime(txtDOB.Text),
                     txtContact.Text.Trim(),
                     string.IsNullOrEmpty(ddlStream.SelectedValue) ? (int?)null : Convert.ToInt32(ddlStream.SelectedValue),
                     string.IsNullOrEmpty(ddlStudyLevel.SelectedValue) ? (int?)null : Convert.ToInt32(ddlStudyLevel.SelectedValue),
                     string.IsNullOrEmpty(ddlSemester.SelectedValue) ? (int?)null : Convert.ToInt32(ddlSemester.SelectedValue),
                     string.IsNullOrEmpty(ddlCourse.SelectedValue) ? (int?)null : Convert.ToInt32(ddlCourse.SelectedValue),
                     string.IsNullOrEmpty(ddlSection.SelectedValue) ? (int?)null : Convert.ToInt32(ddlSection.SelectedValue),
                     txtRollNo.Text.Trim()
                 );

                ShowMsg("Student Registered Successfully!", true);
                LoadStudents();
            }
            catch (Exception ex)
            {
                ShowMsg(ex.Message, false);
            }
        }

        // ================= UPDATE =================

        protected void btnUpdate_Click(object sender, EventArgs e)
        {
            try
            {
                int userId = Convert.ToInt32(hfStudentUserId.Value);

                bl.UpdateStudent(
                    userId,
                    txtEmailEdit.Text.Trim(),
                    txtFullNameEdit.Text.Trim(),
                    txtContactEdit.Text.Trim()
                );

                ShowMsg("Student Updated Successfully!", true);
                LoadStudents();
            }
            catch (Exception ex)
            {
                ShowMsg(ex.Message, false);
            }
        }
        // ================= STREAM CHANGE =================
        protected void ddlDepartment_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(ddlStream.SelectedValue))
            {
                ddlCourse.Items.Clear();
                ddlCourse.Items.Insert(0, new ListItem("-- Optional Course --", ""));
                return;
            }

            DataLayer dl = new DataLayer();
            SqlCommand cmd = new SqlCommand("SELECT CourseId, CourseName FROM Courses WHERE StreamId=@S");
            cmd.Parameters.AddWithValue("@S", ddlStream.SelectedValue);

            ddlCourse.DataSource = dl.GetDataTable(cmd);
            ddlCourse.DataTextField = "CourseName";
            ddlCourse.DataValueField = "CourseId";
            ddlCourse.DataBind();
            ddlCourse.Items.Insert(0, new ListItem("-- Optional Course --", ""));
        }

        private void LoadStudyLevels()
        {
            DataLayer dl = new DataLayer();
            SqlCommand cmd = new SqlCommand("SELECT LevelId, LevelName FROM StudyLevels WHERE InstituteId=@I");
            cmd.Parameters.AddWithValue("@I", Session["InstituteId"]);

            ddlStudyLevel.DataSource = dl.GetDataTable(cmd);
            ddlStudyLevel.DataTextField = "LevelName";
            ddlStudyLevel.DataValueField = "LevelId";
            ddlStudyLevel.DataBind();
            ddlStudyLevel.Items.Insert(0, new ListItem("-- Optional Year/Class --", ""));
        }
        private void LoadSemesters()
        {
            DataLayer dl = new DataLayer();
            SqlCommand cmd = new SqlCommand("SELECT SemesterId, SemesterName FROM Semesters WHERE InstituteId=@I");
            cmd.Parameters.AddWithValue("@I", Session["InstituteId"]);

            ddlSemester.DataSource = dl.GetDataTable(cmd);
            ddlSemester.DataTextField = "SemesterName";
            ddlSemester.DataValueField = "SemesterId";
            ddlSemester.DataBind();
            ddlSemester.Items.Insert(0, new ListItem("-- Optional Semester --", ""));
        }
        private void LoadEditDropdowns()
        {
            DataLayer dl = new DataLayer();

            // Load Courses
            SqlCommand cmdCourse = new SqlCommand("SELECT CourseId, CourseName FROM Courses WHERE InstituteId=@I");
            cmdCourse.Parameters.AddWithValue("@I", Session["InstituteId"]);

            txtCourseEdit.DataSource = dl.GetDataTable(cmdCourse);
            txtCourseEdit.DataTextField = "CourseName";
            txtCourseEdit.DataValueField = "CourseId";
            txtCourseEdit.DataBind();
            txtCourseEdit.Items.Insert(0, new ListItem("-- Optional Course --", ""));

            // Load Sections
            SqlCommand cmdSection = new SqlCommand("SELECT SectionId, SectionName FROM Sections WHERE InstituteId=@I");
            cmdSection.Parameters.AddWithValue("@I", Session["InstituteId"]);

            txtSecctionEdit.DataSource = dl.GetDataTable(cmdSection);
            txtSecctionEdit.DataTextField = "SectionName";
            txtSecctionEdit.DataValueField = "SectionId";
            txtSecctionEdit.DataBind();
            txtSecctionEdit.Items.Insert(0, new ListItem("-- Optional Section --", ""));
        }
        // ================= GRID COMMAND =================

        protected void gvStudents_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (string.IsNullOrEmpty(e.CommandArgument?.ToString()))
                return;

            int userId = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "ViewRow")
            {
                Response.Redirect("StudentDetails.aspx?UserId=" + userId);
            }
            else if (e.CommandName == "EditRow")
            {
                DataRow dr = bl.GetStudentById(userId);

                if (dr != null)
                {
                    hfStudentUserId.Value = userId.ToString();
                    txtEmailEdit.Text = dr["Email"].ToString();
                    txtFullNameEdit.Text = dr["FullName"].ToString();
                    txtContactEdit.Text = dr["ContactNo"].ToString();

                    ScriptManager.RegisterStartupScript(this, GetType(), "edit", "showEditModal();", true);
                }
            }
            else if (e.CommandName == "Toggle")
            {
                bl.ToggleStudent(userId);
                LoadStudents();
            }
            else if (e.CommandName == "DeleteRow")
            {
                bl.DeleteStudent(userId);
                LoadStudents();
            }
        }

        // ================= FILTER =================

        protected void btnFilter_Click(object sender, EventArgs e)
        {
            LoadStudents(txtSearch.Text.Trim());
        }

        protected void FilterStatus_Click(object sender, EventArgs e)
        {
            string status = ((LinkButton)sender).CommandArgument;
            LoadStudents(txtSearch.Text.Trim(), status);
        }

        // ================= DROPDOWNS =================

        private void LoadStreams()
        {
            DataLayer dl = new DataLayer();
            SqlCommand cmd = new SqlCommand("SELECT StreamId, StreamName FROM Streams WHERE InstituteId=@I");
            cmd.Parameters.AddWithValue("@I", Session["InstituteId"]);

            ddlStream.DataSource = dl.GetDataTable(cmd);
            ddlStream.DataTextField = "StreamName";
            ddlStream.DataValueField = "StreamId";
            ddlStream.DataBind();
            ddlStream.Items.Insert(0, new ListItem("-- Select Stream --", ""));
        }

        private void LoadSections()
        {
            DataLayer dl = new DataLayer();
            SqlCommand cmd = new SqlCommand("SELECT SectionId, SectionName FROM Sections WHERE InstituteId=@I");
            cmd.Parameters.AddWithValue("@I", Session["InstituteId"]);

            ddlSection.DataSource = dl.GetDataTable(cmd);
            ddlSection.DataTextField = "SectionName";
            ddlSection.DataValueField = "SectionId";
            ddlSection.DataBind();
            ddlSection.Items.Insert(0, new ListItem("-- Optional Section --", ""));
        }

        // ================= MESSAGE =================

        private void ShowMsg(string msg, bool success)
        {
            lblMsg.Text = msg;
            lblMsg.CssClass = success ? "alert alert-success d-block" : "alert alert-danger d-block";
        }
    }
}