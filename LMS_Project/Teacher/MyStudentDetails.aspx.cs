using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using LMS_Project.BL;
using LMS_Project.GC;

namespace LMS_Project.Teacher
{
    public partial class MyStudentDetails : System.Web.UI.Page
    {
        TeacherStudentDetailsBL bl = new TeacherStudentDetailsBL();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null) { Response.Redirect("../Default.aspx"); return; }
            if (!IsPostBack)
            {
                if (Request.QueryString["UserId"] == null) { Response.Redirect("MyStudents.aspx"); return; }
                LoadStudentDetails(Convert.ToInt32(Request.QueryString["UserId"]));
            }
        }

        private string Val(string s) => string.IsNullOrWhiteSpace(s) ? "—" : s;

        private void LoadStudentDetails(int userId)
        {
            try
            {
                int teacherUserId = Convert.ToInt32(Session["UserId"]);
                int sessionId = Session["CurrentSessionId"] != null
                                    ? Convert.ToInt32(Session["CurrentSessionId"]) : 1;

                // ── Profile ──────────────────────────────────────
                TeacherStudentGC profile = bl.GetStudentProfile(userId);
                if (profile == null)
                {
                    lblError.Text = "Student profile not found.";
                    lblError.Visible = true;
                    return;
                }

                string name = profile.FullName;
                lblFullName.Text = Val(name);
                lblEmail.Text = Val(profile.Email);
                lblRoll.Text = Val(profile.RollNumber);
                lblCourse.Text = Val(profile.CourseName);
                lblSemester.Text = Val(profile.SemesterName);
                lblGender.Text = Val(profile.Gender);
                lblStream.Text = Val(profile.StreamName);
                lblLevel.Text = Val(profile.LevelName);
                lblCity.Text = Val(profile.City);
                lblContact.Text = Val(profile.ContactNo);
                lblSection.Text = Val(profile.SectionName);
                lblSession.Text = Val(profile.SessionName);
                lblAddress.Text = Val(profile.Address);
                lblSkills.Text = Val(profile.Skills);
                lblHobbies.Text = Val(profile.Hobbies);
                lblEmergencyName.Text = Val(profile.EmergencyContactName);
                lblEmergencyNo.Text = Val(profile.EmergencyContactNo);
                lblDOB.Text = profile.DOB.HasValue
                                        ? profile.DOB.Value.ToString("dd MMM yyyy") : "—";
                lblInitialHero.Text = name.Length > 0
                                        ? name.Substring(0, 1).ToUpper() : "S";

                // ── Attendance KPIs ───────────────────────────────
                TeacherStudentGC att = bl.GetAttendanceSummary(userId, teacherUserId);
                lblPresent.Text = att.Present.ToString();
                lblAbsent.Text = att.Absent.ToString();
                int total = att.Present + att.Absent;
                int attPct = total > 0 ? (att.Present * 100 / total) : 0;
                lblAttPct.Text = attPct + "%";
                hfAttPresent.Value = att.Present.ToString();
                hfAttAbsent.Value = att.Absent.ToString();
                hfAttLeave.Value = att.Leave.ToString();

                // ── Subjects ──────────────────────────────────────
                List<TeacherStudentSubjectGC> subjects = bl.GetSubjects(userId);
                rptSubjects.DataSource = subjects;
                rptSubjects.DataBind();
                lblSubjectCount.Text = subjects.Count.ToString();

                // ── Video chart data ──────────────────────────────
                DataTable dtVid = bl.GetVideosBySubject(userId, teacherUserId);
                var sbVLabels = new StringBuilder("[");
                var sbVData = new StringBuilder("[");
                foreach (DataRow r in dtVid.Rows)
                {
                    sbVLabels.Append("\"").Append(r["SubjectName"].ToString().Replace("\"", "'")).Append("\",");
                    sbVData.Append(r["WatchedCount"]).Append(",");
                }
                hfVideoLabels.Value = sbVLabels.ToString().TrimEnd(',') + "]";
                hfVideoData.Value = sbVData.ToString().TrimEnd(',') + "]";

                // ── Assignment stats ──────────────────────────────
                TeacherStudentGC asgn = bl.GetAssignmentStats(userId, teacherUserId);
                hfAsgnSubmitted.Value = asgn.AssignmentsSubmitted.ToString();
                hfAsgnOverdue.Value = asgn.AssignmentsOverdue.ToString();
                hfAsgnPending.Value = asgn.AssignmentsPending.ToString();

                int totalAsgn = asgn.AssignmentsSubmitted + asgn.AssignmentsOverdue + asgn.AssignmentsPending;
                lblSubmissionRate.Text = totalAsgn > 0
                    ? Math.Round(100.0 * asgn.AssignmentsSubmitted / totalAsgn, 1) + "%" : "0%";

                // ── Progress stats ────────────────────────────────
                TeacherStudentGC stats = bl.GetProgressStats(userId);
                lblVideos.Text = stats.VideosCompleted.ToString();
                lblAssignments.Text = stats.AssignmentsSubmitted.ToString();

                // ── Marks detail (table + chart) ──────────────────
                DataTable dtMarks = bl.GetStudentMarksDetail(userId, teacherUserId, sessionId);
                rptMarks.DataSource = dtMarks;
                rptMarks.DataBind();

                decimal totalScore = 0; int scoredRows = 0;
                var sbMLabels = new StringBuilder("[");
                var sbMScores = new StringBuilder("[");
                var sbMMax = new StringBuilder("[");
                foreach (DataRow r in dtMarks.Rows)
                {
                    sbMLabels.Append("\"").Append(r["AssignmentTitle"].ToString().Replace("\"", "'")).Append("\",");
                    sbMScores.Append(r["MarksObtained"]).Append(",");
                    sbMMax.Append(r["MaxMarks"]).Append(",");
                    totalScore += Convert.ToDecimal(r["Percentage"]);
                    scoredRows++;
                }
                hfMarksLabels.Value = sbMLabels.ToString().TrimEnd(',') + "]";
                hfMarksScores.Value = sbMScores.ToString().TrimEnd(',') + "]";
                hfMarksMax.Value = sbMMax.ToString().TrimEnd(',') + "]";
                lblAvgScore.Text = scoredRows > 0
                    ? Math.Round(totalScore / scoredRows, 1) + "%" : "0%";

                // ── Quiz attempts ─────────────────────────────────
                int quizAttempts = bl.GetQuizAttemptCount(userId, sessionId);
                lblQuizAttempts.Text = quizAttempts.ToString();

                // ── Attendance by subject chart ───────────────────
                DataTable dtAttSub = bl.GetAttendanceBySubject(userId, teacherUserId);
                var sbASLabels = new StringBuilder("[");
                var sbASPresent = new StringBuilder("[");
                var sbASAbsent = new StringBuilder("[");
                foreach (DataRow r in dtAttSub.Rows)
                {
                    sbASLabels.Append("\"").Append(r["SubjectName"].ToString().Replace("\"", "'")).Append("\",");
                    sbASPresent.Append(r["PresentCount"]).Append(",");
                    sbASAbsent.Append(r["AbsentCount"]).Append(",");
                }
                hfAttBySubLabels.Value = sbASLabels.ToString().TrimEnd(',') + "]";
                hfAttBySubPresent.Value = sbASPresent.ToString().TrimEnd(',') + "]";
                hfAttBySubAbsent.Value = sbASAbsent.ToString().TrimEnd(',') + "]";

                // ── Recent activity ───────────────────────────────
                List<TeacherStudentActivityGC> videos = bl.GetRecentVideos(userId);
                rptVideos.DataSource = videos;
                rptVideos.DataBind();
                pnlNoVideos.Visible = videos.Count == 0;

                List<TeacherStudentActivityGC> assignments = bl.GetRecentAssignments(userId);
                rptAssignments.DataSource = assignments;
                rptAssignments.DataBind();
                pnlNoAssignments.Visible = assignments.Count == 0;
            }
            catch (Exception ex)
            {
                lblError.Text = "Could not load student details: " + ex.Message;
                lblError.Visible = true;
            }
        }

        // ── Grade helpers (used in ASPX <%# %>) ──────────────────
        protected string GetGrade(object pct)
        {
            if (pct == null || pct == DBNull.Value) return "—";
            decimal v;
            if (!decimal.TryParse(pct.ToString(), out v)) return "—";
            if (v >= 90) return "A+";
            if (v >= 80) return "A";
            if (v >= 70) return "B";
            if (v >= 60) return "C";
            if (v >= 50) return "D";
            return "F";
        }

        protected string GetGradeClass(object pct)
        {
            if (pct == null || pct == DBNull.Value) return "grade-f";
            decimal v;
            if (!decimal.TryParse(pct.ToString(), out v)) return "grade-f";
            if (v >= 90) return "grade-aplus";
            if (v >= 80) return "grade-a";
            if (v >= 70) return "grade-b";
            if (v >= 60) return "grade-c";
            if (v >= 50) return "grade-d";
            return "grade-f";
        }
    }
}