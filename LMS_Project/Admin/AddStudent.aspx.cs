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
                if (ViewState["ShowInactive"] == null)
                    ShowInactive = false;

                LoadStreams();
                LoadStudyLevels();
                LoadSemesters();
                LoadSections();
                LoadEditDropdowns();
            }

            // ✅ ALWAYS LOAD DATA
            ReloadEverything();
        }
        private void BindStudents()
        {
            string status = ShowInactive ? "0" : "1"; // 1=Active, 0=Inactive
            LoadStudents(txtSearch.Text.Trim(), status);
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
        public bool ShowInactive
        {
            get { return ViewState["ShowInactive"] != null && (bool)ViewState["ShowInactive"]; }
            set { ViewState["ShowInactive"] = value; }
        }
        protected void ToggleView_Click(object sender, EventArgs e)
        {
            ShowInactive = !ShowInactive;

            btnToggleView.Text = ShowInactive ? "👁 View Active" : "👁 View Inactive";

            ReloadEverything();   // 🔥 FIX
        }

        public DataTable StreamCourseStats;

        private void LoadStreamCourseStats()
        {
            int instituteId = Convert.ToInt32(Session["InstituteId"]);
            StreamCourseStats = bl.GetStudentStatsByStreamCourse(instituteId);

            rptStats.DataSource = StreamCourseStats;
            rptStats.DataBind();
        }

        // ================= SAVE =================

        protected void btnSave_Click(object sender, EventArgs e)
        {
            try
            {
                int societyId = Convert.ToInt32(Session["SocietyId"]);
                int instituteId = Convert.ToInt32(Session["InstituteId"]);

                DateTime dob = Convert.ToDateTime(txtDOB.Text);
                int age = DateTime.Now.Year - dob.Year;

                if (ddlStudyLevel.SelectedItem.Text.Contains("Engineering") && age < 16)
                {
                    ShowMsg("Invalid Age for Engineering Course!", false);
                    return;
                }

                if (string.IsNullOrWhiteSpace(txtUsername.Text) ||
                    string.IsNullOrWhiteSpace(txtEmail.Text) ||
                    string.IsNullOrWhiteSpace(txtFullName.Text))
                {
                    ShowMsg("Required fields missing!", false);
                    return;
                }

                if (!txtEmail.Text.Contains("@"))
                {
                    ShowMsg("Invalid Email!", false);
                    return;
                }

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
                BindStudents();
            }
            catch (Exception ex)
            {
                ShowMsg(ex.Message, false);
            }
        }

        // ================= UPDATE =================
        private void ReloadEverything()
        {
            BindStudents();
            LoadStats();
            LoadStreamCourseStats();
        }
        protected void btnUpdate_Click(object sender, EventArgs e)
        {
            try
            {
                int userId = Convert.ToInt32(hfStudentUserId.Value);

                bl.UpdateStudent(
                    userId,
                    txtEmailEdit.Text.Trim(),
                    txtFullNameEdit.Text.Trim(),
                    txtContactEdit.Text.Trim(),
                    txtRollNumberEdit.Text.Trim(),
                    string.IsNullOrEmpty(ddlStreamEdit.SelectedValue) ? (int?)null : Convert.ToInt32(ddlStreamEdit.SelectedValue),
                    string.IsNullOrEmpty(txtCourseEdit.SelectedValue) ? (int?)null : Convert.ToInt32(txtCourseEdit.SelectedValue),
                    string.IsNullOrEmpty(ddlStudyLevelEdit.SelectedValue) ? (int?)null : Convert.ToInt32(ddlStudyLevelEdit.SelectedValue),
                    string.IsNullOrEmpty(ddlSemesterEdit.SelectedValue) ? (int?)null : Convert.ToInt32(ddlSemesterEdit.SelectedValue),
                    string.IsNullOrEmpty(txtSecctionEdit.SelectedValue) ? (int?)null : Convert.ToInt32(txtSecctionEdit.SelectedValue)
                );

                ShowMsg("Student Updated Successfully!", true);
                ReloadEverything();
            }
            catch (Exception ex)
            {
                ShowMsg(ex.Message, false);
            }
        }

        public int TotalStudents = 0;
        public int ActiveStudents = 0;
        public int InactiveStudents = 0;
        public int NewStudents = 0;

        private void LoadStats()
        {
            DataLayer dl = new DataLayer();

            SqlCommand cmd = new SqlCommand(@"
        SELECT 
            COUNT(*) Total,
            SUM(CASE WHEN IsActive = 1 THEN 1 ELSE 0 END) AS Active,
            SUM(CASE WHEN IsActive = 0 THEN 1 ELSE 0 END) AS Inactive,
            SUM(CASE WHEN MONTH(CreatedOn)=MONTH(GETDATE()) THEN 1 ELSE 0 END) NewStudents
        FROM Users WHERE RoleId = (SELECT RoleId FROM Roles WHERE RoleName='Student')
        AND InstituteId=@I");

            cmd.Parameters.AddWithValue("@I", Session["InstituteId"]);

            DataTable dt = dl.GetDataTable(cmd);

            if (dt.Rows.Count > 0)
            {
                TotalStudents = Convert.ToInt32(dt.Rows[0]["Total"]);
                ActiveStudents = Convert.ToInt32(dt.Rows[0]["Active"]);
                InactiveStudents = Convert.ToInt32(dt.Rows[0]["Inactive"]);
                NewStudents = Convert.ToInt32(dt.Rows[0]["NewStudents"]);
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

            ScriptManager.RegisterStartupScript(this, GetType(), "keepModal", "keepModalOpen();", true);
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
            int instituteId = Convert.ToInt32(Session["InstituteId"]);

            // ================= STREAM =================
            SqlCommand cmdStream = new SqlCommand("SELECT StreamId, StreamName FROM Streams WHERE InstituteId=@I");
            cmdStream.Parameters.AddWithValue("@I", instituteId);

            ddlStreamEdit.DataSource = dl.GetDataTable(cmdStream);
            ddlStreamEdit.DataTextField = "StreamName";
            ddlStreamEdit.DataValueField = "StreamId";
            ddlStreamEdit.DataBind();
            ddlStreamEdit.Items.Insert(0, new ListItem("-- Select Stream --", ""));

            // ================= COURSE =================
            SqlCommand cmdCourse = new SqlCommand("SELECT CourseId, CourseName FROM Courses WHERE InstituteId=@I");
            cmdCourse.Parameters.AddWithValue("@I", instituteId);

            txtCourseEdit.DataSource = dl.GetDataTable(cmdCourse);
            txtCourseEdit.DataTextField = "CourseName";
            txtCourseEdit.DataValueField = "CourseId";
            txtCourseEdit.DataBind();
            txtCourseEdit.Items.Insert(0, new ListItem("-- Optional Course --", ""));

            // ================= STUDY LEVEL =================
            SqlCommand cmdLevel = new SqlCommand("SELECT LevelId, LevelName FROM StudyLevels WHERE InstituteId=@I");
            cmdLevel.Parameters.AddWithValue("@I", instituteId);

            ddlStudyLevelEdit.DataSource = dl.GetDataTable(cmdLevel);
            ddlStudyLevelEdit.DataTextField = "LevelName";
            ddlStudyLevelEdit.DataValueField = "LevelId";
            ddlStudyLevelEdit.DataBind();
            ddlStudyLevelEdit.Items.Insert(0, new ListItem("-- Optional Class --", ""));

            // ================= SEMESTER =================
            SqlCommand cmdSem = new SqlCommand("SELECT SemesterId, SemesterName FROM Semesters WHERE InstituteId=@I");
            cmdSem.Parameters.AddWithValue("@I", instituteId);

            ddlSemesterEdit.DataSource = dl.GetDataTable(cmdSem);
            ddlSemesterEdit.DataTextField = "SemesterName";
            ddlSemesterEdit.DataValueField = "SemesterId";
            ddlSemesterEdit.DataBind();
            ddlSemesterEdit.Items.Insert(0, new ListItem("-- Optional Semester --", ""));

            // ================= SECTION =================
            SqlCommand cmdSection = new SqlCommand("SELECT SectionId, SectionName FROM Sections WHERE InstituteId=@I");
            cmdSection.Parameters.AddWithValue("@I", instituteId);

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

                LoadEditDropdowns();

                if (dr != null)
                {
                    hfStudentUserId.Value = userId.ToString();
                    txtUsernameEdit.Text = dr["Username"].ToString();
                    txtEmailEdit.Text = dr["Email"].ToString();
                    txtFullNameEdit.Text = dr["FullName"].ToString();
                    txtContactEdit.Text = dr["ContactNo"].ToString();
                    txtRollNumberEdit.Text = dr["RollNumber"].ToString();

                    ddlGenderEdit.SelectedValue = dr["Gender"].ToString();
                    txtDOBEdit.Text = Convert.ToDateTime(dr["DOB"]).ToString("yyyy-MM-dd");

                    ddlStreamEdit.SelectedValue = dr["StreamId"] == DBNull.Value ? "" : dr["StreamId"].ToString();
                    txtCourseEdit.SelectedValue = dr["CourseId"] == DBNull.Value ? "" : dr["CourseId"].ToString();
                    ddlStudyLevelEdit.SelectedValue = dr["LevelId"] == DBNull.Value ? "" : dr["LevelId"].ToString();
                    ddlSemesterEdit.SelectedValue = dr["SemesterId"] == DBNull.Value ? "" : dr["SemesterId"].ToString();
                    txtSecctionEdit.SelectedValue = dr["SectionId"] == DBNull.Value ? "" : dr["SectionId"].ToString();

                    ScriptManager.RegisterStartupScript(this, GetType(), "edit", "setTimeout(showEditModal, 100);", true);
                }
            }
            else if (e.CommandName == "DeleteRow")
            {
                bl.DeleteStudent(userId);
                ReloadEverything(); // 🔥 FIX
            }
        }




        [System.Web.Services.WebMethod]
        public static string ToggleStudentAjax(int userId)
        {
            StudentBL bl = new StudentBL();
            bool isActive = bl.ToggleStudent(userId);
            return isActive ? "1" : "0";
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