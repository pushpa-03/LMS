using System;
using System.Collections.Generic;
using LMS_Project.BL;
using LMS_Project.GC;

namespace LMS_Project.Teacher
{
    public partial class MyStudentDetails : System.Web.UI.Page
    {
        TeacherStudentDetailsBL bl = new TeacherStudentDetailsBL();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null)
            {
                Response.Redirect("../Default.aspx");
                return;
            }

            if (!IsPostBack)
            {
                if (Request.QueryString["UserId"] == null)
                {
                    Response.Redirect("MyStudents.aspx");
                    return;
                }

                int studentUserId = Convert.ToInt32(Request.QueryString["UserId"]);
                LoadStudentDetails(studentUserId);
            }
        }

        private void LoadStudentDetails(int userId)
        {
            try
            {
                // ── Profile ───────────────────────────────────────────
                TeacherStudentGC profile = bl.GetStudentProfile(userId);

                if (profile != null)
                {
                    string name = profile.FullName;
                    lblFullName.Text = name;
                    lblEmail.Text = profile.Email;
                    lblRoll.Text = profile.RollNumber;
                    lblCourse.Text = profile.CourseName;
                    lblSemester.Text = profile.SemesterName;
                    lblGender.Text = profile.Gender;
                    lblStream.Text = profile.StreamName;
                    lblLevel.Text = profile.LevelName;
                    lblCity.Text = profile.City;
                    lblContact.Text = profile.ContactNo;
                    lblDOB.Text = profile.DOB.HasValue
                                            ? profile.DOB.Value.ToString("dd MMM yyyy")
                                            : "—";
                    lblInitialHero.Text = name.Length > 0
                                            ? name.Substring(0, 1).ToUpper()
                                            : "S";
                }

                // ── Attendance ────────────────────────────────────────
                TeacherStudentGC att = bl.GetAttendanceSummary(userId);
                lblPresent.Text = att.Present.ToString();
                lblAbsent.Text = att.Absent.ToString();

                // ── Subjects ──────────────────────────────────────────
                List<TeacherStudentSubjectGC> subjects = bl.GetSubjects(userId);
                rptSubjects.DataSource = subjects;
                rptSubjects.DataBind();

                // ── Activity ──────────────────────────────────────────
                List<TeacherStudentActivityGC> activity = bl.GetRecentActivity(userId);
                if (activity.Count > 0)
                {
                    rptActivity.DataSource = activity;
                    rptActivity.DataBind();
                    pnlNoActivity.Visible = false;
                }
                else
                {
                    pnlNoActivity.Visible = true;
                }

                // ── Progress Stats ────────────────────────────────────
                TeacherStudentGC stats = bl.GetProgressStats(userId);
                lblVideos.Text = stats.VideosCompleted.ToString();
                lblAssignments.Text = stats.AssignmentsSubmitted.ToString();
            }
            catch (Exception ex)
            {
                lblError.Text = "Could not load student details: " + ex.Message;
                lblError.Visible = true;
            }
        }
    }
}