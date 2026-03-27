using System;
using System.Web.UI;

namespace LMS_Project.Teacher
{
    public partial class TeacherMaster : MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserName"] != null)
            {
                lblTeacherName.Text = Session["UserName"].ToString();

                // Set first letter as avatar
                lblInitial.Text = Session["UserName"].ToString().Substring(0, 1).ToUpper();
            }
        }
    }
}