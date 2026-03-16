using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace LearningManagementSystem.SuperAdmin
{
    public partial class SuperAdminMaster : System.Web.UI.MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                lblSidebarInstituteName.Text = "LMS Portal"; // Fallback name

            }
        }
    }
}