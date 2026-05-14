using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using Newtonsoft.Json;   // or use a manual JSON builder below if Newtonsoft not available

namespace LMS_Project.Teacher
{
    public partial class SubjectAnalytics : BasePage
    {
        SubjectAnalyticsBL bl = new SubjectAnalyticsBL();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Request.QueryString["SubjectId"] != null &&
                    int.TryParse(Request.QueryString["SubjectId"], out int subjectId))
                {
                    hfSubjectId.Value = subjectId.ToString();
                    LoadAll(subjectId);
                }
                else
                    Response.Redirect("Subjects_T_Side.aspx");
            }
        }

        private void LoadAll(int subjectId)
        {
            // ── Subject Header ──
            DataTable dtSubject = bl.GetSubjectInfo(subjectId, SessionId);
            if (dtSubject != null && dtSubject.Rows.Count > 0)
            {
                var r = dtSubject.Rows[0];
                litSubjectName.Text = r["SubjectName"].ToString();
                litSubjectCode.Text = r["SubjectCode"].ToString();
                litStatusBadge.Text = Convert.ToBoolean(r["IsActive"])
                    ? "<span class='badge bg-success'>Active</span>"
                    : "<span class='badge bg-danger'>Inactive</span>";
            }

            // ── KPIs ──
            DataTable dtKpi = bl.GetSubjectKPIs(subjectId, SessionId);
            if (dtKpi != null && dtKpi.Rows.Count > 0)
            {
                var k = dtKpi.Rows[0];
                litTotalStudents.Text = k["TotalStudents"].ToString();
                litTotalStudents2.Text = k["TotalStudents"].ToString();
                litTotalChapters.Text = k["TotalChapters"].ToString();
                litTotalVideos.Text = k["TotalVideos"].ToString();
                litTotalMaterials.Text = k["TotalMaterials"].ToString();
                litTotalAssignments.Text = k["TotalAssignments"].ToString();
                litTotalSubmissions.Text = k["TotalSubmissions"].ToString();
                litAvgMarks.Text = string.Format("{0:F2}", Convert.ToDecimal(k["AvgMarks"]));
                litAvgAttendance.Text = string.Format("{0:F2}", Convert.ToDecimal(k["AvgAttendancePct"])) + "%";
            }

            // ── Attendance chart data ──
            DataTable dtAtt = bl.GetAttendanceByDate(subjectId, SessionId);
            var labels = new System.Collections.Generic.List<string>();
            var present = new System.Collections.Generic.List<int>();
            var absent = new System.Collections.Generic.List<int>();
            var leave = new System.Collections.Generic.List<int>();
            int pTotal = 0, aTotal = 0, lTotal = 0;

            if (dtAtt != null)
                foreach (DataRow r in dtAtt.Rows)
                {
                    labels.Add(Convert.ToDateTime(r["AttDate"]).ToString("dd MMM"));
                    int p = Convert.ToInt32(r["PresentCount"]);
                    int a = Convert.ToInt32(r["AbsentCount"]);
                    int l = Convert.ToInt32(r["LeaveCount"]);
                    present.Add(p); absent.Add(a); leave.Add(l);
                    pTotal += p; aTotal += a; lTotal += l;
                }

            hfAttendanceLabels.Value = ToJson(labels);
            hfAttendancePresent.Value = ToJson(present);
            hfAttendanceAbsent.Value = ToJson(absent);
            hfAttendanceLeave.Value = ToJson(leave);
            hfPresentTotal.Value = pTotal.ToString();
            hfAbsentTotal.Value = aTotal.ToString();
            hfLeaveTotal.Value = lTotal.ToString();

            // ── Video views per chapter (student viewers only) ──
            DataTable dtVid = bl.GetVideoViewsPerChapter(subjectId, SessionId);
            var vLabels = new System.Collections.Generic.List<string>();
            var vChapterNames = new System.Collections.Generic.List<string>();
            var vTotalViews = new System.Collections.Generic.List<int>();
            var vUniqueViewers = new System.Collections.Generic.List<int>();

            if (dtVid != null)
                foreach (DataRow r in dtVid.Rows)
                {
                    // Label = "ChapterName – VideoTitle" for x-axis
                    vLabels.Add(r["ChapterName"] + " – " + r["VideoTitle"]);
                    vChapterNames.Add(r["ChapterName"].ToString());
                    vTotalViews.Add(Convert.ToInt32(r["TotalViews"]));
                    vUniqueViewers.Add(Convert.ToInt32(r["UniqueViewers"]));
                }

            hfVideoLabels.Value = ToJson(vLabels);
            hfVideoChapterNames.Value = ToJson(vChapterNames);
            hfVideoTotalViews.Value = ToJson(vTotalViews);
            hfVideoUniqueViewers.Value = ToJson(vUniqueViewers);

            // ── Assignment chart data ──
            DataTable dtAsg = bl.GetAssignmentStats(subjectId, SessionId);
            var asgTitles = new System.Collections.Generic.List<string>();
            var asgSubs = new System.Collections.Generic.List<int>();
            if (dtAsg != null)
                foreach (DataRow r in dtAsg.Rows)
                {
                    asgTitles.Add(r["Title"].ToString());
                    asgSubs.Add(Convert.ToInt32(r["SubmissionCount"]));
                }
            hfAssignmentTitles.Value = ToJson(asgTitles);
            hfAssignmentSubs.Value = ToJson(asgSubs);
            // total enrolled students for the bar baseline
            hfAssignmentTotal.Value = dtKpi?.Rows.Count > 0
                ? dtKpi.Rows[0]["TotalStudents"].ToString() : "0";

            // ── Chapter content summary repeater ──
            DataTable dtChCon = bl.GetChapterContentSummary(subjectId, SessionId);
            rptChapterContent.DataSource = dtChCon;
            rptChapterContent.DataBind();

            // ── Student progress repeater ──
            DataTable dtSP = bl.GetStudentProgress(subjectId, SessionId);
            rptStudentProgress.DataSource = dtSP;
            rptStudentProgress.DataBind();

            // ── Assignment detail repeater ──
            DataTable dtAD = bl.GetAssignmentDetailStats(subjectId, SessionId);
            rptAssignmentDetail.DataSource = dtAD;
            rptAssignmentDetail.DataBind();
        }

        // ── Helpers used in ASPX ──────────────────────────────────
        protected string GetInitials(string name)
        {
            if (string.IsNullOrWhiteSpace(name)) return "?";
            var parts = name.Trim().Split(' ');
            return parts.Length >= 2
                ? (parts[0][0].ToString() + parts[parts.Length - 1][0].ToString()).ToUpper()
                : name.Substring(0, Math.Min(2, name.Length)).ToUpper();
        }

        protected string GetScoreClass(object val)
        {
            if (val == null || val == DBNull.Value) return "bg-secondary";
            decimal v = Convert.ToDecimal(val);
            if (v >= 75) return "bg-success";
            if (v >= 50) return "bg-warning text-dark";
            return "bg-danger";
        }

        // ── Simple JSON builder (no Newtonsoft needed) ────────────
        private string ToJson(System.Collections.Generic.List<string> list)
        {
            var sb = new System.Text.StringBuilder("[");
            for (int i = 0; i < list.Count; i++)
            {
                if (i > 0) sb.Append(",");
                sb.Append("\"").Append(list[i].Replace("\"", "\\\"")).Append("\"");
            }
            sb.Append("]");
            return sb.ToString();
        }
        private string ToJson(System.Collections.Generic.List<int> list)
        {
            return "[" + string.Join(",", list) + "]";
        }
        private string ToJson(System.Collections.Generic.List<decimal> list)
        {
            return "[" + string.Join(",", list) + "]";
        }
    }
}