using System;
using System.Data;
using System.IO;
using System.Net.Http;
using System.Text;
using System.Web;
using System.Web.Services;
using Newtonsoft.Json; // Make sure you have Newtonsoft.Json installed via NuGet

namespace LMS_Project.Admin
{
    public partial class MaterialPlayer : System.Web.UI.Page
    {
        MaterialBL bl = new MaterialBL();
        int UserId => Convert.ToInt32(HttpContext.Current.Session["UserId"]);

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                int materialId = Convert.ToInt32(Request.QueryString["MaterialId"]);


                LoadMaterial(materialId);
                LoadHistory(materialId);
            }
        }

        void LoadMaterial(int id)
        {
            DataTable dt = bl.GetMaterialById(id);

            if (dt.Rows.Count > 0)
            {
                lblTitle.Text = dt.Rows[0]["Title"].ToString();

                string path = dt.Rows[0]["FilePath"].ToString();
                string type = dt.Rows[0]["FileType"].ToString();

                // ✅ FIX HERE
                hfFilePath.Value = path;

                downloadLink.HRef = path;

                string viewer = "";

                if (type == ".pdf")
                    viewer = $"<iframe src='{path}' width='100%' height='400px'></iframe>";
                else
                    viewer = $"<iframe src='https://view.officeapps.live.com/op/embed.aspx?src={Request.Url.GetLeftPart(UriPartial.Authority) + path}' width='100%' height='400px'></iframe>";

                fileViewer.InnerHtml = viewer;
            }
        }

        void LoadHistory(int id)
        {
            rptHistory.DataSource = bl.GetHistory(id, UserId);
            rptHistory.DataBind();
        }

        // ---------------- AI CALLS ----------------

        [WebMethod]
        public static string GenerateQuiz(string materialId, string Path)
        {
            return SaveToHistory("material-quiz", materialId, Path, null);
        }

        [WebMethod]
        public static string GenerateNotes(string materialId, string filePath)
        {
            return SaveToHistory("material-notes", materialId, filePath, null);
        }

        [WebMethod]
        public static string AskDoubt(string materialId, string question, string filePath)
        {
            return SaveToHistory("material-ask", materialId, filePath, question);
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
            catch (Exception ex)
            {
                return "Error: " + ex.Message;
            }
        }


        //[WebMethod]
        //public static string GenerateNotes(string materialId)
        //{
        //    MaterialBL bl = new MaterialBL();
        //    int userId = Convert.ToInt32(HttpContext.Current.Session["UserId"]);

        //    string filePath = HttpContext.Current.Request.Form["hfFilePath"];

        //    var client = new HttpClient();

        //    var res = client.PostAsync("http://127.0.0.1:8000/material-notes",
        //        new StringContent(
        //            $"{{\"file_path\":\"{filePath}\"}}",
        //            Encoding.UTF8, "application/json")).Result;

        //    string result = res.Content.ReadAsStringAsync().Result;

        //    bl.SaveAIHistory(new MaterialGC
        //    {
        //        MaterialId = Convert.ToInt32(materialId),
        //        UserId = userId,
        //        Type = "Notes",
        //        Question = "Generated Notes",
        //        Response = result
        //    });

        //    return result;
        //}

        //[WebMethod]
        //public static string AskDoubt(string materialId, string question)
        //{
        //    MaterialBL bl = new MaterialBL();
        //    int userId = Convert.ToInt32(HttpContext.Current.Session["UserId"]);

        //    string filePath = HttpContext.Current.Request.Form["hfFilePath"];

        //    var client = new HttpClient();

        //    var res = client.PostAsync("http://127.0.0.1:8000/material-ask",
        //        new StringContent(
        //            $"{{\"file_path\":\"{filePath}\",\"question\":\"{question}\"}}",
        //            Encoding.UTF8, "application/json")).Result;

        //    string answer = res.Content.ReadAsStringAsync().Result;

        //    bl.SaveAIHistory(new MaterialGC
        //    {
        //        MaterialId = Convert.ToInt32(materialId),
        //        UserId = userId,
        //        Type = "Doubt",
        //        Question = question,
        //        Response = answer
        //    });

        //    return answer;
        //}
    }
}