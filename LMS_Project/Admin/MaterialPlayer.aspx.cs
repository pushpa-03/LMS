//using System;
//using System.Data;
//using System.IO;
//using System.Net.Http;
//using System.Text;
//using System.Web;
//using System.Web.Services;
//using Newtonsoft.Json; // Make sure you have Newtonsoft.Json installed via NuGet

//namespace LMS_Project.Admin
//{
//    public partial class MaterialPlayer : System.Web.UI.Page
//    {
//        MaterialBL bl = new MaterialBL();
//        int UserId => Convert.ToInt32(HttpContext.Current.Session["UserId"]);

//        protected void Page_Load(object sender, EventArgs e)
//        {
//            if (!IsPostBack)
//            {
//                int materialId = Convert.ToInt32(Request.QueryString["MaterialId"]);


//                LoadMaterial(materialId);
//                LoadHistory(materialId);
//            }
//        }

//        void LoadMaterial(int id)
//        {
//            DataTable dt = bl.GetMaterialById(id);

//            if (dt.Rows.Count > 0)
//            {
//                lblTitle.Text = dt.Rows[0]["Title"].ToString();

//                string path = dt.Rows[0]["FilePath"].ToString();
//                string type = dt.Rows[0]["FileType"].ToString();

//                // ✅ FIX HERE
//                hfFilePath.Value = path;

//                downloadLink.HRef = path;

//                string viewer = "";

//                if (type == ".pdf")
//                    viewer = $"<iframe src='{path}' width='100%' height='400px'></iframe>";
//                else
//                    viewer = $"<iframe src='https://view.officeapps.live.com/op/embed.aspx?src={Request.Url.GetLeftPart(UriPartial.Authority) + path}' width='100%' height='400px'></iframe>";

//                fileViewer.InnerHtml = viewer;
//            }
//        }

//        void LoadHistory(int id)
//        {
//            rptHistory.DataSource = bl.GetHistory(id, UserId);
//            rptHistory.DataBind();
//        }

//        // ---------------- AI CALLS ----------------

//        [WebMethod]
//        public static string GenerateQuiz(string materialId, string Path)
//        {
//            return SaveToHistory("material-quiz", materialId, Path, null);
//        }

//        [WebMethod]
//        public static string GenerateNotes(string materialId, string filePath)
//        {
//            return SaveToHistory("material-notes", materialId, filePath, null);
//        }

//        [WebMethod]
//        public static string AskDoubt(string materialId, string question, string filePath)
//        {
//            return SaveToHistory("material-ask", materialId, filePath, question);
//        }

//        [WebMethod]
//        public static string SaveToHistory(string materialId, string type, string question, string response)
//        {
//            try
//            {
//                MaterialBL bl = new MaterialBL();
//                int userId = Convert.ToInt32(HttpContext.Current.Session["UserId"]);

//                bl.SaveAIHistory(new MaterialGC
//                {
//                    MaterialId = Convert.ToInt32(materialId),
//                    UserId = userId,
//                    Type = type,
//                    Question = question,
//                    Response = response
//                });

//                return "Saved";
//            }
//            catch (Exception ex)
//            {
//                return "Error: " + ex.Message;
//            }
//        }


//        //[WebMethod]
//        //public static string GenerateNotes(string materialId)
//        //{
//        //    MaterialBL bl = new MaterialBL();
//        //    int userId = Convert.ToInt32(HttpContext.Current.Session["UserId"]);

//        //    string filePath = HttpContext.Current.Request.Form["hfFilePath"];

//        //    var client = new HttpClient();

//        //    var res = client.PostAsync("http://127.0.0.1:8000/material-notes",
//        //        new StringContent(
//        //            $"{{\"file_path\":\"{filePath}\"}}",
//        //            Encoding.UTF8, "application/json")).Result;

//        //    string result = res.Content.ReadAsStringAsync().Result;

//        //    bl.SaveAIHistory(new MaterialGC
//        //    {
//        //        MaterialId = Convert.ToInt32(materialId),
//        //        UserId = userId,
//        //        Type = "Notes",
//        //        Question = "Generated Notes",
//        //        Response = result
//        //    });

//        //    return result;
//        //}

//        //[WebMethod]
//        //public static string AskDoubt(string materialId, string question)
//        //{
//        //    MaterialBL bl = new MaterialBL();
//        //    int userId = Convert.ToInt32(HttpContext.Current.Session["UserId"]);

//        //    string filePath = HttpContext.Current.Request.Form["hfFilePath"];

//        //    var client = new HttpClient();

//        //    var res = client.PostAsync("http://127.0.0.1:8000/material-ask",
//        //        new StringContent(
//        //            $"{{\"file_path\":\"{filePath}\",\"question\":\"{question}\"}}",
//        //            Encoding.UTF8, "application/json")).Result;

//        //    string answer = res.Content.ReadAsStringAsync().Result;

//        //    bl.SaveAIHistory(new MaterialGC
//        //    {
//        //        MaterialId = Convert.ToInt32(materialId),
//        //        UserId = userId,
//        //        Type = "Doubt",
//        //        Question = question,
//        //        Response = answer
//        //    });

//        //    return answer;
//        //}
//    }
//}

//----------------------------------------------------------------------------------------------------------------------------------

//using System;
//using System.Data;
//using System.Web;
//using System.Web.Services;

//namespace LMS_Project.Admin
//{
//    public partial class MaterialPlayer : System.Web.UI.Page
//    {
//        MaterialBL bl = new MaterialBL();
//        // Securely get UserId from Session
//        int UserId => Session["UserId"] != null ? Convert.ToInt32(Session["UserId"]) : 0;

//        protected void Page_Load(object sender, EventArgs e)
//        {
//            if (UserId == 0) Response.Redirect("../Default.aspx"); // Admin security check

//            if (!IsPostBack)
//            {
//                string mId = Request.QueryString["MaterialId"];
//                if (!string.IsNullOrEmpty(mId))
//                {
//                    int materialId = Convert.ToInt32(mId);
//                    LoadMaterial(materialId);
//                    LoadHistory(materialId);

//                    // Fix the Edit link - ensure the parameter name matches your AddMaterial page
//                    lnkEdit.NavigateUrl = "AddMaterial.aspx?MaterialId=" + materialId;
//                }
//            }
//        }

//        void LoadMaterial(int id)
//        {
//            DataTable dt = bl.GetMaterialById(id);
//            if (dt != null && dt.Rows.Count > 0)
//            {
//                lblTitle.Text = dt.Rows[0]["Title"].ToString();
//                string path = dt.Rows[0]["FilePath"].ToString();
//                string type = dt.Rows[0]["FileType"].ToString().ToLower();

//                hfFilePath.Value = path;
//                downloadLink.HRef = path;

//                string viewer = "";
//                // Handle different file types for the previewer
//                if (type == ".pdf")
//                {
//                    viewer = $"<embed src='{path}' width='100%' height='100%' type='application/pdf'>";
//                }
//                else if (type == ".jpg" || type == ".png" || type == ".jpeg")
//                {
//                    viewer = $"<div class='text-center'><img src='{path}' class='img-fluid' style='max-height:550px;' /></div>";
//                }
//                else
//                {
//                    // For Word/Excel/PPT - using Office Online Viewer
//                    string absolutePath = Request.Url.GetLeftPart(UriPartial.Authority) + path;
//                    viewer = $"<iframe src='https://view.officeapps.live.com/op/embed.aspx?src={absolutePath}' width='100%' height='100%' frameborder='0'></iframe>";
//                }

//                fileViewer.InnerHtml = viewer;
//            }
//        }

//        void LoadHistory(int id)
//        {
//            // Admin sees ALL history for this material to monitor AI quality
//            rptHistory.DataSource = bl.GetHistory(id, 0); // Pass 0 to get all users or modify BL
//            rptHistory.DataBind();
//        }

//        [WebMethod]
//        public static string SaveToHistory(string materialId, string type, string question, string response)
//        {
//            try
//            {
//                MaterialBL bl = new MaterialBL();
//                int userId = Convert.ToInt32(HttpContext.Current.Session["UserId"]);

//                bl.SaveAIHistory(new MaterialGC
//                {
//                    MaterialId = Convert.ToInt32(materialId),
//                    UserId = userId,
//                    Type = type,
//                    Question = question,
//                    Response = response
//                });

//                return "Saved";
//            }
//            catch { return "Error"; }
//        }
//    }
//}

//---------------------------------------------------------------------------------------------------------------------------

using System;
using System.Data;
using System.Web;
using System.Web.Services;

namespace LMS_Project.Admin
{
    public partial class MaterialPlayer : System.Web.UI.Page
    {
        MaterialBL bl = new MaterialBL();
        int UserId => Session["UserId"] != null ? Convert.ToInt32(Session["UserId"]) : 0;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (UserId == 0) Response.Redirect("../Default.aspx");

            if (!IsPostBack)
            {
                string mId = Request.QueryString["MaterialId"];
                if (!string.IsNullOrEmpty(mId))
                {
                    int materialId = Convert.ToInt32(mId);
                    LoadMaterial(materialId);
                    LoadHistory(materialId);
                    lnkEdit.NavigateUrl = "AddMaterial.aspx?MaterialId=" + materialId;
                }
            }
        }

        void LoadMaterial(int id)
        {
            DataTable dt = bl.GetMaterialById(id);
            if (dt != null && dt.Rows.Count > 0)
            {
                lblTitle.Text = dt.Rows[0]["Title"].ToString();
                string path = dt.Rows[0]["FilePath"].ToString();
                string type = dt.Rows[0]["FileType"].ToString().ToLower();

                hfFilePath.Value = path;
                downloadLink.HRef = path;

                if (type == ".pdf")
                    fileViewer.InnerHtml = $"<iframe src='{path}' width='100%' height='100%'></iframe>";
                else if (type == ".jpg" || type == ".png" || type == ".jpeg")
                    fileViewer.InnerHtml = $"<img src='{path}' class='img-fluid' style='max-height:550px;' />";
                else
                    fileViewer.InnerHtml = $"<iframe src='https://view.officeapps.live.com/op/embed.aspx?src={Request.Url.GetLeftPart(UriPartial.Authority) + path}' width='100%' height='100%'></iframe>";
            }
        }

        void LoadHistory(int id)
        {
            // Passing 0 usually indicates 'Get All' in your BL for Admins
            rptHistory.DataSource = bl.GetHistory(id, 0);
            rptHistory.DataBind();
        }

        [WebMethod]
        public static string SaveToHistory(string materialId, string type, string question, string response)
        {
            try
            {
                MaterialBL bl = new MaterialBL();
                int userId = Convert.ToInt32(HttpContext.Current.Session["UserId"]);

                bl.SaveAIHistory(new MaterialGC
                {
                    MaterialId = Convert.ToInt32(materialId),
                    UserId = userId,
                    Type = type,
                    Question = question,
                    Response = response
                });
                return "Saved";
            }
            catch { return "Error"; }
        }
    }
}