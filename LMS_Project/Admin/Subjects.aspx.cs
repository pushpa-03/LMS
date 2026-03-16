using System;
using System.Data;

namespace LearningManagementSystem.Admin
{
    public partial class Subjects : System.Web.UI.Page
    {
        SubjectsBL bl = new SubjectsBL();

        int SocietyId => Convert.ToInt32(Session["SocietyId"]);
        int InstituteId => Convert.ToInt32(Session["InstituteId"]);

        int CurrentSessionId
        {
            get { return GetCurrentSessionId(); }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindSubjects();
            }
        }

        private int GetCurrentSessionId()
        {
            if (Session["CurrentSessionId"] != null)
                return Convert.ToInt32(Session["CurrentSessionId"]);

            int id = bl.GetCurrentSession(InstituteId);

            if (id > 0)
            {
                Session["CurrentSessionId"] = id;
                return id;
            }

            // Instead of throwing exception
            return 0;
        }

        void BindSubjects()
        {
            int sessionId = CurrentSessionId;

            if (sessionId == 0)
            {
                lblMsg.Text = "No Current Academic Session Set.";
                lblMsg.Visible = true;
                return;
            }

            DataTable dt = bl.GetSubjects(SocietyId, InstituteId, sessionId);

            rptSubjects.DataSource = dt;
            rptSubjects.DataBind();
        }

        protected void rptSubjects_ItemCommand(object source,
        System.Web.UI.WebControls.RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "Toggle")
            {
                int subjectId = Convert.ToInt32(e.CommandArgument);

                bl.ToggleSubjectStatus(subjectId);

                BindSubjects();
            }
        }
    }
}