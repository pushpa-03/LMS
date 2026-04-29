using LearningManagementSystem.BL;
using System;
using System.Data;
using System.Web;
using System.Web.Script.Serialization;


namespace LMS_Project.Teacher
{
    public class GetStudentMarks : IHttpHandler, System.Web.SessionState.IRequiresSessionState
    {
        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/json";

            try
            {
                if (context.Session["UserId"] == null)
                {
                    context.Response.Write("{\"error\":\"Not authenticated\"}");
                    return;
                }

                int studentId = Convert.ToInt32(context.Request["studentId"]);
                int teacherId = Convert.ToInt32(context.Session["UserId"]);
                int instituteId = Convert.ToInt32(context.Session["InstituteId"]);
                int sessionId = context.Session["CurrentSessionId"] != null
                                  ? Convert.ToInt32(context.Session["CurrentSessionId"])
                                  : 1;

                TeacherDashboardBL bl = new TeacherDashboardBL();
                DataTable dt = bl.GetStudentMarksDetail(studentId, teacherId, instituteId, sessionId);

                var rows = new System.Collections.Generic.List<object>();
                foreach (DataRow row in dt.Rows)
                {
                    int marks = Convert.ToInt32(row["MarksObtained"]);
                    int maxMarks = Convert.ToInt32(row["MaxMarks"]);
                    int pct = Convert.ToInt32(row["Percentage"]);

                    string grade;
                    if (pct >= 90) grade = "A+";
                    else if (pct >= 80) grade = "A";
                    else if (pct >= 70) grade = "B";
                    else if (pct >= 60) grade = "C";
                    else if (pct >= 50) grade = "D";
                    else grade = "F";

                    rows.Add(new
                    {
                        AssignmentTitle = row["AssignmentTitle"].ToString(),
                        SubjectName = row["SubjectName"].ToString(),
                        MarksObtained = marks,
                        MaxMarks = maxMarks,
                        Percentage = pct,
                        Grade = grade,
                        SubmittedOn = row["SubmittedOn"].ToString()
                    });
                }

                context.Response.Write(new JavaScriptSerializer().Serialize(rows));
            }
            catch (Exception ex)
            {
                context.Response.Write("{\"error\":\"" + ex.Message + "\"}");
            }
        }

        public bool IsReusable => false;
    }
}