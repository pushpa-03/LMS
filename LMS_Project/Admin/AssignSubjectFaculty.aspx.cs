
using System;
using System.Data;
using System.Web.Services;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Configuration;

namespace LearningManagementSystem.Admin
{
    public partial class AssignSubjectFaculty : System.Web.UI.Page
    {
        SubjectFacultyBL bl = new SubjectFacultyBL();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["InstituteId"] == null)
            {
                Response.Redirect("~/Default.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadSections();
                LoadSubjects();
                LoadGrid();
            }
        }

        private int InstituteId
        {
            get { return Convert.ToInt32(Session["InstituteId"]); }
        }

        private int CurrentSessionId
        {
            get
            {
                if (Session["CurrentSessionId"] != null)
                    return Convert.ToInt32(Session["CurrentSessionId"]);

                return bl.GetCurrentSession(InstituteId);
            }
        }

        private void LoadSections()
        {
            DataTable dt = bl.GetSections(InstituteId);

            ddlSection.DataSource = dt;
            ddlSection.DataTextField = "SectionName";
            ddlSection.DataValueField = "SectionId";
            ddlSection.DataBind();

            ddlSection.Items.Insert(0, new System.Web.UI.WebControls.ListItem("-- Select Section --", "0"));
        }

        private void LoadSubjects()
        {
            DataTable dt = bl.GetSubjects(InstituteId);

            ddlSubject.DataSource = dt;
            ddlSubject.DataTextField = "SubjectName";
            ddlSubject.DataValueField = "SubjectId";
            ddlSubject.DataBind();

            ddlSubject.Items.Insert(0, new System.Web.UI.WebControls.ListItem("-- Select Subject --", "0"));
        }

        private void LoadGrid()
        {
            gvAssign.DataSource = bl.GetAll(InstituteId, CurrentSessionId);
            gvAssign.DataBind();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(hfTeacherId.Value) ||
                ddlSubject.SelectedValue == "0" ||
                ddlSection.SelectedValue == "0")
            {
                ShowMsg("All fields required", false);
                return;
            }

            SubjectFacultyGC obj = new SubjectFacultyGC
            {
                SocietyId = Convert.ToInt32(Session["SocietyId"]),
                InstituteId = InstituteId,
                SessionId = CurrentSessionId,
                TeacherId = Convert.ToInt32(hfTeacherId.Value),
                SubjectId = Convert.ToInt32(ddlSubject.SelectedValue),
                SectionId = Convert.ToInt32(ddlSection.SelectedValue),
                AssignedBy = Convert.ToInt32(Session["UserId"])
            };

            bl.Insert(obj);

            ShowMsg("Assigned successfully!", true);
            LoadGrid();
        }

        protected void gvAssign_RowCommand(object sender,
            System.Web.UI.WebControls.GridViewCommandEventArgs e)
        {
            int id = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "DeleteRow")
                bl.Delete(id);
            else if (e.CommandName == "Toggle")
                bl.Toggle(id);

            LoadGrid();
        }

        private void ShowMsg(string msg, bool success)
        {
            lblMsg.Text = msg;
            lblMsg.CssClass = success ? "text-success" : "text-danger";
        }

        [WebMethod]
        public static List<object> SearchTeachers(string prefix)
        {
            List<object> list = new List<object>();

            string cs = ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString;

            using (SqlConnection con = new SqlConnection(cs))
            {
                string q = @"SELECT TOP 10 U.UserId, P.FullName
                             FROM Users U
                             JOIN UserProfile P ON U.UserId=P.UserId
                             JOIN Roles R ON U.RoleId=R.RoleId
                             WHERE R.RoleName='Teacher'
                             AND P.FullName LIKE @name";

                SqlCommand cmd = new SqlCommand(q, con);
                cmd.Parameters.AddWithValue("@name", "%" + prefix + "%");

                con.Open();
                SqlDataReader dr = cmd.ExecuteReader();

                while (dr.Read())
                {
                    list.Add(new
                    {
                        UserId = dr["UserId"],
                        FullName = dr["FullName"].ToString()
                    });
                }
            }

            return list;
        }
    }
}