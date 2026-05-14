using ExcelDataReader;
using LearningManagementSystem.BL;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace LearningManagementSystem.Admin
{
    public partial class Student : BasePage
    {
        private readonly StudentBL _bl = new StudentBL();

        private static readonly string[] AvatarColors = {
            "#6366f1","#059669","#d97706","#7c3aed",
            "#0284c7","#dc2626","#0891b2","#4f46e5"
        };

        // ── ViewState helpers ──────────────────────────────────────────────────
        private int CurrentPage
        {
            get { return ViewState["CurPage"] is int p && p > 0 ? p : 1; }
            set { ViewState["CurPage"] = value; hfCurrentPage.Value = value.ToString(); }
        }

        private int PageSize
        {
            get { return int.TryParse(ddlPageSize.SelectedValue, out int ps) && ps > 0 ? ps : 10; }
        }

        // ══════════════════════════════════════════════════════════════════════
        //  PAGE LOAD
        // ══════════════════════════════════════════════════════════════════════
        protected void Page_Load(object sender, EventArgs e)
        {
            hfIsSuperAdmin.Value = IsSuperAdmin() ? "1" : "0";

            if (!IsPostBack)
            {
                LoadFilterDropdowns();
                LoadAcademicDropdowns();
                LoadReEnrolDropdowns();
                CurrentPage = 1;
            }
        }

        // ══════════════════════════════════════════════════════════════════════
        //  PAGE PRE-RENDER — runs AFTER all event handlers
        // ══════════════════════════════════════════════════════════════════════
        protected void Page_PreRender(object sender, EventArgs e)
        {
            LoadStudents();
            LoadStats();
            LoadStreamCourseStats();
        }

        // ══════════════════════════════════════════════════════════════════════
        //  LOAD DATA
        // ══════════════════════════════════════════════════════════════════════
        private void LoadStudents()
        {
            string status = ddlFilterStatus.SelectedValue;
            int.TryParse(ddlFilterStream.SelectedValue, out int streamId);

            DataTable all = _bl.GetStudents(InstituteId, SessionId, "", status, streamId);
            int total = all.Rows.Count;

            int totalPages = Math.Max(1, (int)Math.Ceiling((double)total / PageSize));
            if (CurrentPage > totalPages) CurrentPage = totalPages;
            if (CurrentPage < 1) CurrentPage = 1;

            int skip = (CurrentPage - 1) * PageSize;

            DataTable paged = all.Clone();
            for (int i = skip; i < Math.Min(skip + PageSize, total); i++)
                paged.ImportRow(all.Rows[i]);

            gvStudents.DataSource = paged;
            gvStudents.DataBind();

            lblCurrentPage.Text = CurrentPage.ToString();
            lblTotalPages.Text = totalPages.ToString();

            int from = total == 0 ? 0 : skip + 1;
            int to = Math.Min(skip + PageSize, total);
            lblRecordInfo.Text = total == 0
                ? "No students found"
                : $"Showing {from}–{to} of {total} students";

            BuildPager(totalPages);
            btnFirst.Enabled = btnPrev.Enabled = CurrentPage > 1;
            btnNext.Enabled = btnLast.Enabled = CurrentPage < totalPages;
        }

        private void BuildPager(int totalPages)
        {
            phPages.Controls.Clear();
            int start = Math.Max(1, CurrentPage - 2);
            int end = Math.Min(totalPages, CurrentPage + 2);

            for (int i = start; i <= end; i++)
            {
                var lb = new LinkButton
                {
                    Text = i.ToString(),
                    CommandArgument = i.ToString(),
                    CssClass = "pb" + (i == CurrentPage ? " on" : "")
                };
                lb.Click += Pager_Click;
                phPages.Controls.Add(lb);
            }
        }

        private void LoadStats()
        {
            DataTable dt = _bl.GetStudentStats(InstituteId, SessionId);
            if (dt == null || dt.Rows.Count == 0) return;
            DataRow r = dt.Rows[0];
            lblTotalStudents.Text = S(r, "Total");
            lblActiveStudents.Text = S(r, "Active");
            lblInactiveStudents.Text = S(r, "Inactive");
            lblNewStudents.Text = S(r, "NewStudents");
            lblReEnrolled.Text = S(r, "ReEnrolled");
        }

        private void LoadStreamCourseStats()
        {
            rptStats.DataSource = _bl.GetStudentStatsByStreamCourse(InstituteId, SessionId);
            rptStats.DataBind();
        }

        // ── Dropdowns ──────────────────────────────────────────────────────────
        private void LoadFilterDropdowns()
        {
            Bind(ddlFilterStream, _bl.GetStreams(InstituteId, SessionId),
                 "StreamName", "StreamId", "All Streams");
            ddlFilterStatus.Items.Clear();
            ddlFilterStatus.Items.Add(new ListItem("Active", "1"));
            ddlFilterStatus.Items.Add(new ListItem("Inactive", "0"));
            ddlFilterStatus.SelectedIndex = 0;
        }

        private void LoadAcademicDropdowns()
        {
            Bind(ddlStream, _bl.GetStreams(InstituteId, SessionId), "StreamName", "StreamId", "-- Stream --");
            Bind(ddlCourse, _bl.GetCourses(InstituteId, SessionId), "CourseName", "CourseId", "-- Course --");
            Bind(ddlStudyLevel, _bl.GetStudyLevels(InstituteId, SessionId), "LevelName", "LevelId", "-- Year/Class --");
            Bind(ddlSemester, _bl.GetSemesters(InstituteId, SessionId), "SemesterName", "SemesterId", "-- Semester --");
            Bind(ddlSection, _bl.GetSections(InstituteId, SessionId), "SectionName", "SectionId", "-- Section --");

            Bind(ddlStreamEdit, _bl.GetStreams(InstituteId, SessionId), "StreamName", "StreamId", "-- Stream --");
            Bind(ddlCourseEdit, _bl.GetCourses(InstituteId, SessionId), "CourseName", "CourseId", "-- Course --");
            Bind(ddlStudyLevelEdit, _bl.GetStudyLevels(InstituteId, SessionId), "LevelName", "LevelId", "-- Year/Class --");
            Bind(ddlSemesterEdit, _bl.GetSemesters(InstituteId, SessionId), "SemesterName", "SemesterId", "-- Semester --");
            Bind(ddlSectionEdit, _bl.GetSections(InstituteId, SessionId), "SectionName", "SectionId", "-- Section --");
        }

        private void LoadReEnrolDropdowns()
        {
            DataTable sessions = _bl.GetAllSessions(InstituteId);
            ddlReEnrolSession.Items.Clear();
            ddlReEnrolSession.Items.Add(new ListItem("-- Select Session --", ""));
            foreach (DataRow r in sessions.Rows)
            {
                bool curr = Convert.ToBoolean(r["IsCurrent"]);
                ddlReEnrolSession.Items.Add(new ListItem(
                    r["SessionName"] + (curr ? " (Current)" : ""),
                    r["SessionId"].ToString()));
            }

            Bind(ddlReEnrolStream, _bl.GetStreams(InstituteId, SessionId), "StreamName", "StreamId", "-- Stream --");
            Bind(ddlReEnrolCourse, _bl.GetCourses(InstituteId, SessionId), "CourseName", "CourseId", "-- Course --");
            Bind(ddlReEnrolLevel, _bl.GetStudyLevels(InstituteId, SessionId), "LevelName", "LevelId", "-- Year/Class --");
            Bind(ddlReEnrolSemester, _bl.GetSemesters(InstituteId, SessionId), "SemesterName", "SemesterId", "-- Semester --");
            Bind(ddlReEnrolSection, _bl.GetSections(InstituteId, SessionId), "SectionName", "SectionId", "-- Section --");
        }

        private static void Bind(DropDownList ddl, DataTable dt, string tf, string vf, string def)
        {
            ddl.Items.Clear();
            ddl.Items.Add(new ListItem(def, ""));
            if (dt == null) return;
            foreach (DataRow r in dt.Rows)
                ddl.Items.Add(new ListItem(r[tf]?.ToString() ?? "", r[vf]?.ToString() ?? ""));
        }

        protected int GetRowNumber(int rowIndex) =>
            (CurrentPage - 1) * PageSize + rowIndex + 1;

        protected string GetInitial(string name) =>
            string.IsNullOrEmpty(name) ? "?" : name.Trim().Substring(0, 1).ToUpper();

        protected string GetAvatarColor(int index) =>
            AvatarColors[index % AvatarColors.Length];

        // ══════════════════════════════════════════════════════════════════════
        //  STREAM CASCADE
        // ══════════════════════════════════════════════════════════════════════
        protected void ddlStream_Changed(object sender, EventArgs e)
        {
            if (int.TryParse(ddlStream.SelectedValue, out int sid) && sid > 0)
                Bind(ddlCourse, _bl.GetCoursesByStream(InstituteId, SessionId, sid),
                     "CourseName", "CourseId", "-- Course --");
            else
                Bind(ddlCourse, _bl.GetCourses(InstituteId, SessionId),
                     "CourseName", "CourseId", "-- Course --");

            Script("openMo('addMo');");
        }

        // ══════════════════════════════════════════════════════════════════════
        //  FILTER / PAGE SIZE
        // ══════════════════════════════════════════════════════════════════════
        protected void Filter_Changed(object sender, EventArgs e) { CurrentPage = 1; }
        protected void PageSize_Changed(object sender, EventArgs e) { CurrentPage = 1; }

        // ══════════════════════════════════════════════════════════════════════
        //  PAGINATION
        // ══════════════════════════════════════════════════════════════════════
        protected void Pager_Click(object sender, EventArgs e)
        {
            string arg = (sender as LinkButton)?.CommandArgument ?? "1";
            int total = int.TryParse(lblTotalPages.Text, out int t) ? t : 1;

            switch (arg)
            {
                case "First": CurrentPage = 1; break;
                case "Prev": CurrentPage = Math.Max(1, CurrentPage - 1); break;
                case "Next": CurrentPage = Math.Min(total, CurrentPage + 1); break;
                case "Last": CurrentPage = total; break;
                default:
                    if (int.TryParse(arg, out int pg)) CurrentPage = pg; break;
            }
        }

        // ══════════════════════════════════════════════════════════════════════
        //  AGE / LEVEL VALIDATION
        // ══════════════════════════════════════════════════════════════════════
        private string ValidateAgeForLevel(DateTime dob, string levelName)
        {
            if (string.IsNullOrWhiteSpace(levelName)) return null;
            double ageYears = (DateTime.Today - dob).TotalDays / 365.25;
            string lv = levelName.ToLower();

            if (lv.Contains("1st") || lv.Contains("2nd") || lv.Contains("3rd") ||
                lv.Contains("4th") || lv.Contains("5th") || lv.Contains("primary"))
            {
                if (ageYears < 5) return $"Student age ({ageYears:F0} yrs) too young for {levelName} (min 5).";
                if (ageYears > 13) return $"Student age ({ageYears:F0} yrs) too old for {levelName} (max ~13).";
            }
            else if (lv.Contains("6th") || lv.Contains("7th") || lv.Contains("8th") || lv.Contains("middle"))
            {
                if (ageYears < 11) return $"Student must be at least 11 years old for {levelName}.";
            }
            else if (lv.Contains("9th") || lv.Contains("10th") || lv.Contains("matric") || lv.Contains("ssc"))
            {
                if (ageYears < 14) return $"Student must be at least 14 years old for {levelName}.";
            }
            else if (lv.Contains("11th") || lv.Contains("12th") || lv.Contains("inter") || lv.Contains("hsc"))
            {
                if (ageYears < 15) return $"Student must be at least 15 years old for {levelName}.";
            }
            else if (lv.Contains("engin") || lv.Contains("degree") || lv.Contains("bachelor") ||
                     lv.Contains("b.tech") || lv.Contains("bsc") || lv.Contains("first year") || lv.Contains("1st year"))
            {
                if (ageYears < 17) return $"Student must be at least 17 years old for {levelName}.";
            }
            else if (lv.Contains("master") || lv.Contains("m.tech") || lv.Contains("msc") || lv.Contains("pg"))
            {
                if (ageYears < 21) return $"Student must be at least 21 years old for {levelName}.";
            }
            return null;
        }

        // ══════════════════════════════════════════════════════════════════════
        //  SAVE STUDENT
        // ══════════════════════════════════════════════════════════════════════
        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (IsSuperAdmin())
            { Toast("warn", "Access Denied: SuperAdmin has view-only access."); return; }

            if (SessionId == 0)
            { Toast("warn", "No active academic session found. Please configure a session first."); return; }

            string fullName = txtFullName.Text.Trim();
            string username = txtUsername.Text.Trim();
            string email = txtEmail.Text.Trim();
            string rollNo = txtRollNo.Text.Trim();
            string contact = txtContact.Text.Trim();

            if (string.IsNullOrEmpty(fullName) || fullName.Length < 2)
            { Toast("warn", "Full name must be at least 2 characters."); ReOpen("addMo"); return; }

            if (string.IsNullOrEmpty(username) ||
                !System.Text.RegularExpressions.Regex.IsMatch(username, @"^[A-Za-z0-9_]{3,50}$"))
            { Toast("warn", "Username must be 3–50 chars: letters, numbers, underscore only."); ReOpen("addMo"); return; }

            if (string.IsNullOrEmpty(email) ||
                !System.Text.RegularExpressions.Regex.IsMatch(email, @"^[^@\s]+@[^@\s]+\.[^@\s]{2,}$"))
            { Toast("warn", "Enter a valid email address."); ReOpen("addMo"); return; }

            if (string.IsNullOrEmpty(rollNo))
            { Toast("warn", "Roll number is required."); ReOpen("addMo"); return; }

            if (!string.IsNullOrEmpty(contact) &&
                !System.Text.RegularExpressions.Regex.IsMatch(contact, @"^\d{10,15}$"))
            { Toast("warn", "Contact must be 10–15 digits."); ReOpen("addMo"); return; }

            DateTime dob = DateTime.Today.AddYears(-16);
            if (!string.IsNullOrEmpty(txtDOB.Text))
            {
                if (!DateTime.TryParse(txtDOB.Text, out dob))
                { Toast("warn", "Invalid date of birth."); ReOpen("addMo"); return; }

                double age = (DateTime.Today - dob).TotalDays / 365.25;
                if (age < 5)
                { Toast("warn", "Student must be at least 5 years old."); ReOpen("addMo"); return; }
                if (age > 60)
                { Toast("warn", "Date of birth seems incorrect — student age exceeds 60 years."); ReOpen("addMo"); return; }
            }

            if (!string.IsNullOrEmpty(ddlStudyLevel.SelectedValue) && ddlStudyLevel.SelectedIndex > 0)
            {
                string ageErr = ValidateAgeForLevel(dob, ddlStudyLevel.SelectedItem.Text);
                if (ageErr != null)
                { Toast("warn", ageErr); ReOpen("addMo"); return; }
            }

            if (_bl.StudentExists(username, email, rollNo, InstituteId, SessionId))
            { Toast("warn", "A student with the same username, email or roll number already exists."); ReOpen("addMo"); return; }

            try
            {
                int newStudentId = _bl.InsertStudent(
                    SocietyId, InstituteId, SessionId,
                    username, email, fullName,
                    ddlGender.SelectedValue, dob, contact, txtAddress.Text.Trim(),
                    NullInt(ddlStream.SelectedValue),
                    NullInt(ddlStudyLevel.SelectedValue),
                    NullInt(ddlSemester.SelectedValue),
                    NullInt(ddlCourse.SelectedValue),
                    NullInt(ddlSection.SelectedValue),
                    rollNo, UserId
                );

                LogActivity(UserId, SocietyId, InstituteId, SessionId, "StudentAdded", newStudentId);

                // Show success + parent enrollment suggestion
                Toast("ok", $"Student '{fullName}' added successfully. Default password: Student@123");
                Script("closeMo('addMo');");

                // Show parent enrollment suggestion banner
                string safeFullName = fullName.Replace("'", "\\'");
                Script($"showParentSuggestion('{safeFullName}', {newStudentId});");

                ClearAdd();
                CurrentPage = 1;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("[Add] " + ex);
                Toast("err", "Failed to add student: " + ex.Message);
                ReOpen("addMo");
            }
        }

        // ══════════════════════════════════════════════════════════════════════
        //  UPDATE STUDENT
        // ══════════════════════════════════════════════════════════════════════
        protected void btnUpdate_Click(object sender, EventArgs e)
        {
            if (IsSuperAdmin())
            { Toast("warn", "Access Denied: SuperAdmin has view-only access."); return; }

            if (!int.TryParse(hfStudentUserId.Value, out int userId) || userId == 0)
            { Toast("warn", "Invalid student record."); return; }

            string fullName = txtFullNameEdit.Text.Trim();
            string email = txtEmailEdit.Text.Trim();
            string rollNo = txtRollNumberEdit.Text.Trim();

            if (string.IsNullOrEmpty(fullName))
            { Toast("warn", "Full name is required."); ReOpen("editMo"); return; }

            if (string.IsNullOrEmpty(email) ||
                !System.Text.RegularExpressions.Regex.IsMatch(email, @"^[^@\s]+@[^@\s]+\.[^@\s]{2,}$"))
            { Toast("warn", "Valid email is required."); ReOpen("editMo"); return; }

            if (string.IsNullOrEmpty(rollNo))
            { Toast("warn", "Roll number is required."); ReOpen("editMo"); return; }

            DateTime? dob = null;
            if (!string.IsNullOrEmpty(txtDOBEdit.Text))
            {
                if (!DateTime.TryParse(txtDOBEdit.Text, out DateTime d))
                { Toast("warn", "Invalid date of birth."); ReOpen("editMo"); return; }
                dob = d;

                if (!string.IsNullOrEmpty(ddlStudyLevelEdit.SelectedValue) &&
                    ddlStudyLevelEdit.SelectedIndex > 0 && dob.HasValue)
                {
                    string ageErr = ValidateAgeForLevel(dob.Value, ddlStudyLevelEdit.SelectedItem.Text);
                    if (ageErr != null)
                    { Toast("warn", ageErr); ReOpen("editMo"); return; }
                }
            }

            try
            {
                _bl.UpdateStudent(
                    userId, SessionId,
                    email, fullName, txtContactEdit.Text.Trim(), rollNo,
                    ddlGenderEdit.SelectedValue, dob,
                    NullInt(ddlStreamEdit.SelectedValue),
                    NullInt(ddlCourseEdit.SelectedValue),
                    NullInt(ddlStudyLevelEdit.SelectedValue),
                    NullInt(ddlSemesterEdit.SelectedValue),
                    NullInt(ddlSectionEdit.SelectedValue)
                );

                LogActivity(UserId, SocietyId, InstituteId, SessionId, "StudentUpdated", userId);
                Toast("ok", $"Student '{fullName}' updated successfully.");
                Script("closeMo('editMo');");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("[Update] " + ex);
                Toast("err", "Update failed: " + ex.Message);
                ReOpen("editMo");
            }
        }

        // ══════════════════════════════════════════════════════════════════════
        //  RE-ENROL — auto re-enrolls parents
        // ══════════════════════════════════════════════════════════════════════
        protected void btnReEnrol_Click(object sender, EventArgs e)
        {
            if (IsSuperAdmin())
            { Toast("warn", "Access Denied: SuperAdmin has view-only access."); return; }

            if (!int.TryParse(hfReEnrolUserId.Value, out int userId) || userId == 0)
            { Toast("warn", "Invalid student record."); return; }

            if (!int.TryParse(ddlReEnrolSession.SelectedValue, out int tSessId) || tSessId == 0)
            { Toast("warn", "Please select a target session."); return; }

            if (_bl.IsStudentEnrolledInSession(userId, tSessId))
            { Toast("warn", "Student is already enrolled in the selected session."); return; }

            string newRoll = txtReEnrolRoll.Text.Trim();
            if (string.IsNullOrEmpty(newRoll))
            {
                DataRow curr = _bl.GetStudentById(userId, SessionId);
                newRoll = curr?["RollNumber"]?.ToString() ?? "";
            }

            try
            {
                // Re-enroll student (this also auto re-enrolls parents inside BL)
                _bl.ReEnrolStudent(
                    userId, SocietyId, InstituteId, tSessId,
                    NullInt(ddlReEnrolStream.SelectedValue),
                    NullInt(ddlReEnrolCourse.SelectedValue),
                    NullInt(ddlReEnrolLevel.SelectedValue),
                    NullInt(ddlReEnrolSemester.SelectedValue),
                    NullInt(ddlReEnrolSection.SelectedValue),
                    newRoll, UserId
                );

                // Check how many parents were auto re-enrolled
                int parentCount = _bl.GetParentCountForStudent(userId, tSessId);

                LogActivity(UserId, SocietyId, InstituteId, SessionId, "StudentReEnrolled", userId);

                string parentMsg = parentCount > 0
                    ? $" {parentCount} linked parent(s) were automatically re-enrolled."
                    : " No parents were found to re-enroll.";

                Toast("ok", "Student re-enrolled successfully into the selected session." + parentMsg);
                Script("closeMo('reenrolMo');");
                CurrentPage = 1;
            }
            catch (Exception ex)
            {
                Toast("err", "Re-enrolment failed: " + ex.Message);
            }
        }

        // ══════════════════════════════════════════════════════════════════════
        //  BULK UPLOAD
        // ══════════════════════════════════════════════════════════════════════
        protected void btnUploadBulk_Click(object sender, EventArgs e)
        {
            if (IsSuperAdmin())
            { Toast("warn", "Access Denied: SuperAdmin has view-only access."); return; }

            if (!fuBulk.HasFile)
            { Toast("warn", "Please select a CSV or Excel file."); return; }

            string ext = Path.GetExtension(fuBulk.FileName).ToLower();
            if (ext != ".csv" && ext != ".xlsx" && ext != ".xls")
            { Toast("warn", "Only .csv, .xlsx or .xls files are allowed."); return; }

            int ok = 0, dupes = 0, errs = 0;

            try
            {
                DataTable dt = ext == ".csv"
                    ? ReadCsv(fuBulk.FileContent)
                    : ReadExcel(fuBulk.FileContent);

                foreach (DataRow row in dt.Rows)
                {
                    try
                    {
                        string uname = RowStr(row, 0);
                        string eml = RowStr(row, 1);
                        string fname = RowStr(row, 2);
                        string rno = RowStr(row, 3);

                        if (string.IsNullOrEmpty(uname) ||
                            string.IsNullOrEmpty(eml) ||
                            string.IsNullOrEmpty(rno))
                        { errs++; continue; }

                        if (_bl.StudentExists(uname, eml, rno, InstituteId, SessionId))
                        { dupes++; continue; }

                        DateTime dob = DateTime.Today.AddYears(-18);
                        DateTime.TryParse(RowStr(row, 10), out dob);

                        _bl.InsertStudent(
                            SocietyId, InstituteId, SessionId,
                            uname, eml, fname,
                            RowStr(row, 9) ?? "Male", dob,
                            RowStr(row, 11) ?? "", "",
                            NullStr(RowStr(row, 4)),
                            NullStr(RowStr(row, 5)),
                            NullStr(RowStr(row, 6)),
                            NullStr(RowStr(row, 7)),
                            NullStr(RowStr(row, 8)),
                            rno, UserId
                        );
                        ok++;
                    }
                    catch { errs++; }
                }

                string msg = $"{ok} student(s) imported.";
                if (dupes > 0) msg += $" {dupes} duplicate(s) skipped.";
                if (errs > 0) msg += $" {errs} row(s) had errors.";

                LogActivity(UserId, SocietyId, InstituteId, SessionId,
                    $"BulkStudentUpload:{ok}Added", 0);

                Toast(ok > 0 ? "ok" : "warn", msg);
                Script("closeMo('bulkMo');");
                CurrentPage = 1;
            }
            catch (Exception ex)
            {
                Toast("err", "Bulk upload failed: " + ex.Message);
            }
        }

        // ─── Download Template ─────────────────────────────────────────────────
        protected void btnDownloadTemplate_Click(object sender, EventArgs e)
        {
            Response.Clear();
            Response.ContentType = "text/csv";
            Response.AddHeader("Content-Disposition",
                "attachment; filename=StudentUploadTemplate.csv");

            var sb = new System.Text.StringBuilder();
            sb.AppendLine("Username,Email,FullName,RollNumber,StreamId,LevelId," +
                          "SemesterId,CourseId,SectionId,Gender,DOB,Contact");
            sb.AppendLine("john_doe25,john@example.com,John Doe,24CS001,,,,,," +
                          "Male,2005-06-15,9876543210");

            Response.Write(sb.ToString());
            Response.Flush();
            Response.SuppressContent = true;
            HttpContext.Current.ApplicationInstance.CompleteRequest();
        }

        // ══════════════════════════════════════════════════════════════════════
        //  GRID ROW COMMANDS
        // ══════════════════════════════════════════════════════════════════════
        protected void gvStudents_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (!int.TryParse(e.CommandArgument?.ToString(), out int userId)) return;

            switch (e.CommandName)
            {
                case "ViewRow": DoView(userId); break;
                case "EditRow": DoEdit(userId); break;
                case "ReEnroll": DoReEnrol(userId); break;
                case "Toggle": DoToggle(userId); break;
                case "DeleteRow": DoDelete(userId); break;
            }
        }

        private void DoView(int userId)
        {
            DataRow r = _bl.GetStudentById(userId, SessionId);
            if (r == null) { Toast("warn", "Student not found."); return; }

            DataTable all = _bl.GetStudents(InstituteId, SessionId);
            int idx = 0;
            for (int i = 0; i < all.Rows.Count; i++)
                if (Convert.ToInt32(all.Rows[i]["UserId"]) == userId) { idx = i; break; }

            var data = new
            {
                uid = userId,
                idx = idx,
                name = r["FullName"]?.ToString() ?? "—",
                email = r["Email"]?.ToString() ?? "—",
                roll = r["RollNumber"]?.ToString() ?? "—",
                contact = r["ContactNo"]?.ToString() ?? "—",
                stream = r["StreamName"]?.ToString() ?? "—",
                course = r["CourseName"]?.ToString() ?? "—",
                level = r["LevelName"]?.ToString() ?? "—",
                sem = r["SemesterName"]?.ToString() ?? "—",
                section = r["SectionName"]?.ToString() ?? "—",
                gender = r["Gender"]?.ToString() ?? "—",
                dob = r["DOB"] != DBNull.Value
                            ? Convert.ToDateTime(r["DOB"]).ToString("dd MMM yyyy") : "—",
                joined = r["JoinedDate"] != DBNull.Value
                            ? Convert.ToDateTime(r["JoinedDate"]).ToString("dd MMM yyyy") : "—",
                active = r["IsActive"]?.ToString() ?? "False"
            };
            hfViewData.Value = JsonConvert.SerializeObject(data);
        }

        private void DoEdit(int userId)
        {
            LoadAcademicDropdowns();
            DataRow r = _bl.GetStudentById(userId, SessionId);
            if (r == null) { Toast("warn", "Student not found."); return; }

            hfStudentUserId.Value = userId.ToString();
            txtFullNameEdit.Text = r["FullName"]?.ToString() ?? "";
            txtEmailEdit.Text = r["Email"]?.ToString() ?? "";
            txtContactEdit.Text = r["ContactNo"]?.ToString() ?? "";
            txtRollNumberEdit.Text = r["RollNumber"]?.ToString() ?? "";
            ddlGenderEdit.SelectedValue = r["Gender"]?.ToString() ?? "Male";

            if (r["DOB"] != DBNull.Value)
                txtDOBEdit.Text = Convert.ToDateTime(r["DOB"]).ToString("yyyy-MM-dd");

            Sel(ddlStreamEdit, r["StreamId"]);
            Sel(ddlCourseEdit, r["CourseId"]);
            Sel(ddlStudyLevelEdit, r["LevelId"]);
            Sel(ddlSemesterEdit, r["SemesterId"]);
            Sel(ddlSectionEdit, r["SectionId"]);

            Script("openMo('editMo');");
        }

        private void DoReEnrol(int userId)
        {
            LoadReEnrolDropdowns();
            hfReEnrolUserId.Value = userId.ToString();

            DataRow r = _bl.GetStudentById(userId, SessionId);
            string name = r?["FullName"]?.ToString() ?? "Unknown";

            if (r != null)
            {
                Sel(ddlReEnrolStream, r["StreamId"]);
                Sel(ddlReEnrolCourse, r["CourseId"]);
                Sel(ddlReEnrolLevel, r["LevelId"]);
                Sel(ddlReEnrolSemester, r["SemesterId"]);
                Sel(ddlReEnrolSection, r["SectionId"]);
            }

            // Check parent count for info in modal
            int parentCount = _bl.GetParentCountForStudent(userId, SessionId);
            string safe = name.Replace("'", "\\'");
            Script($"openReEnrolModal('{safe}', {parentCount});");
        }

        private void DoToggle(int userId)
        {
            if (IsSuperAdmin())
            { Toast("warn", "Access Denied: SuperAdmin has view-only access."); return; }

            bool active = _bl.ToggleStudent(userId);
            LogActivity(UserId, SocietyId, InstituteId, SessionId,
                active ? "StudentActivated" : "StudentDeactivated", userId);
            Toast("ok", active
                ? "Student activated — they can now log in."
                : "Student deactivated — login disabled until reactivated.");
        }

        private void DoDelete(int userId)
        {
            if (IsSuperAdmin())
            { Toast("warn", "Access Denied: SuperAdmin has view-only access."); return; }

            try
            {
                DataRow r = _bl.GetStudentById(userId, SessionId);
                string name = r?["FullName"]?.ToString() ?? "Student";
                _bl.DeleteStudent(userId, SessionId);
                LogActivity(UserId, SocietyId, InstituteId, SessionId, "StudentDeleted", userId);
                Toast("ok", $"'{name}' deleted successfully.");
                CurrentPage = 1;
            }
            catch (SqlException ex)
            {
                Toast("err", ex.Number == 547
                    ? "Cannot delete: student has linked records. Deactivate instead."
                    : "DB error: " + ex.Message);
            }
            catch (Exception ex)
            {
                Toast("err", "Delete failed: " + ex.Message);
            }
        }

        // ══════════════════════════════════════════════════════════════════════
        //  ROW DATA BOUND
        // ══════════════════════════════════════════════════════════════════════
        protected void gvStudents_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType != DataControlRowType.DataRow) return;
            if (!(e.Row.DataItem is DataRowView drv)) return;
            bool active = Convert.ToBoolean(drv["IsActive"]);
            if (!active) e.Row.CssClass += " row-inactive";
        }

        // ══════════════════════════════════════════════════════════════════════
        //  CSV / EXCEL READERS
        // ══════════════════════════════════════════════════════════════════════
        private static DataTable ReadCsv(Stream stream)
        {
            var dt = new DataTable();
            using (var sr = new StreamReader(stream))
            {
                bool first = true;
                while (!sr.EndOfStream)
                {
                    string[] cols = (sr.ReadLine() ?? "").Split(',');
                    if (first) { foreach (string c in cols) dt.Columns.Add(c.Trim()); first = false; }
                    else if (cols.Length >= 4) dt.Rows.Add(cols);
                }
            }
            return dt;
        }

        private DataTable ReadExcel(Stream stream)
        {
            try
            {
                using (var reader = ExcelReaderFactory.CreateReader(stream))
                {
                    var ds = reader.AsDataSet(new ExcelDataSetConfiguration
                    {
                        ConfigureDataTable = _ =>
                            new ExcelDataTableConfiguration { UseHeaderRow = true }
                    });
                    return ds.Tables[0];
                }
            }
            catch { stream.Position = 0; return ReadCsv(stream); }
        }

        // ══════════════════════════════════════════════════════════════════════
        //  UTILITY
        // ══════════════════════════════════════════════════════════════════════
        private bool IsSuperAdmin() =>
            Session["Role"]?.ToString()
                .Equals("SuperAdmin", StringComparison.OrdinalIgnoreCase) == true;

        private static int? NullInt(string v) =>
            int.TryParse(v, out int r) && r > 0 ? (int?)r : null;

        private static int? NullStr(string v) =>
            int.TryParse(v?.Trim(), out int r) && r > 0 ? (int?)r : null;

        private static string RowStr(DataRow row, int col)
        { try { return row[col]?.ToString()?.Trim(); } catch { return null; } }

        private static string S(DataRow row, string col)
        { try { return row[col]?.ToString() ?? "0"; } catch { return "0"; } }

        private static void Sel(DropDownList ddl, object val)
        {
            if (val == null || val == DBNull.Value) return;
            var item = ddl.Items.FindByValue(val.ToString());
            if (item != null) item.Selected = true;
        }

        private void ClearAdd()
        {
            txtFullName.Text = txtUsername.Text = txtEmail.Text =
            txtRollNo.Text = txtContact.Text = txtAddress.Text = "";
            txtDOB.Text = "";
            ddlStream.SelectedIndex = ddlCourse.SelectedIndex =
            ddlStudyLevel.SelectedIndex = ddlSemester.SelectedIndex =
            ddlSection.SelectedIndex = 0;
        }

        // ── Toast: write to BOTH hidden fields AND startup script ──────────────
        // This ensures toast fires whether it's initial load or postback
        private void Toast(string type, string msg)
        {
            msg = (msg ?? "").Replace("'", "\\'").Replace("\"", "&quot;")
                             .Replace("\r", "").Replace("\n", " ");
            hfToastMsg.Value = msg;
            hfToastType.Value = type;
            // Also register as startup script so it fires on postback render
            //JS($"_showToast('{msg}','{type}');");
        }

        private void JS(string script) =>
            ScriptManager.RegisterStartupScript(this, GetType(),
                "js_" + Guid.NewGuid().ToString("N").Substring(0, 8), script, true);

        private void ReOpen(string modalId) =>
            Script($"openMo('{modalId}');");

        private void Script(string js) =>
            ScriptManager.RegisterStartupScript(this, GetType(),
                "sc_" + Guid.NewGuid().ToString("N").Substring(0, 8), js, true);
    }
}