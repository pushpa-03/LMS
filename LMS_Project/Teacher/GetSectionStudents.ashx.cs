
using System;
using System.Web;
using LearningManagementSystem.BL;

namespace LMS_Project.Teacher
{
    public class GetSectionStudents : IHttpHandler, System.Web.SessionState.IRequiresSessionState
    {
        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/json";
            context.Response.Cache.SetNoStore();

            // Auth check
            if (context.Session["UserId"] == null ||
                context.Session["InstituteId"] == null)
            {
                context.Response.Write("[]");
                return;
            }

            int teacherId = Convert.ToInt32(context.Session["UserId"]);
            int instituteId = Convert.ToInt32(context.Session["InstituteId"]);

            // Get current session
            int sessionId = 0;
            if (context.Session["CurrentSessionId"] != null)
            {
                sessionId = Convert.ToInt32(context.Session["CurrentSessionId"]);
            }
            else
            {
                var blTemp = new TeacherDashboardBL();
                sessionId = blTemp.GetCurrentSessionId(instituteId);
            }

            string sectionName = context.Request.QueryString["section"] ?? "";

            if (string.IsNullOrWhiteSpace(sectionName))
            {
                context.Response.Write("[]");
                return;
            }

            try
            {
                var bl = new TeacherDashboardBL();
                var dt = bl.GetStudentsBySection(teacherId, instituteId, sessionId, sectionName);
                context.Response.Write(bl.GetStudentsBySectionJson(dt));
            }
            catch (Exception ex)
            {
                context.Response.Write("[]");
            }
        }

        public bool IsReusable => false;
    }
}