using LMS.BL;
using LMS.GC;
using System;
using System.Data;
using System.IO;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace LMS.SuperAdmin
{
    public partial class AddInstitute : System.Web.UI.Page
    {
        InstituteBL bl = new InstituteBL();
        private const int PageSize = 8;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                //if (Request.QueryString["InstituteId"] != null)
                //{
                //    int instituteId = Convert.ToInt32(Request.QueryString["InstituteId"]);

                //    InstituteBL bl = new InstituteBL();
                //    DataTable dt = bl.GetInstituteById(instituteId);

                //    if (dt.Rows.Count > 0)
                //    {
                //        DataRow dr = dt.Rows[0];

                //        Session["InstituteId"] = instituteId;
                //        Session["InstituteName"] = dr["InstituteName"].ToString();
                //        Session["ActiveInstituteName"] = dr["InstituteName"].ToString();
                //        Session["SocietyId"] = dr["SocietyId"];
                //    }
                //}
                CurrentPage = 0;
                LoadSocieties();
                BindInstitutes();
            }
        }

        private int CurrentPage
        {
            get { return ViewState["CurrentPage"] == null ? 0 : (int)ViewState["CurrentPage"]; }
            set { ViewState["CurrentPage"] = value; }
        }

        private void BindInstitutes()
        {
            int sid = Convert.ToInt32(ddlFilterSociety.SelectedValue);
            DataTable dt = bl.GetInstitutes(sid);

            if (dt != null && dt.Rows.Count > 0)
            {
                // Professional Pagination Logic
                int totalRows = dt.Rows.Count;
                var pagedData = dt.AsEnumerable()
                                  .Skip(CurrentPage * PageSize)
                                  .Take(PageSize);

                if (!pagedData.Any() && CurrentPage > 0)
                {
                    CurrentPage--; // Adjust if last item on page was deleted
                    BindInstitutes();
                    return;
                }

                var grouped = pagedData.GroupBy(r => r["SocietyName"])
                    .Select(g => new {
                        SocietyName = g.Key,
                        Institutes = g.CopyToDataTable()
                    });

                rptSocietyGroup.DataSource = grouped;
                rptSocietyGroup.DataBind();

                // UI State for Pagination
                btnPrev.Enabled = CurrentPage > 0;
                btnNext.Enabled = (CurrentPage + 1) * PageSize < totalRows;
                lblPageInfo.Text = $"Showing {CurrentPage + 1} of {Math.Ceiling((double)totalRows / PageSize)} Pages";
            }
            else
            {
                rptSocietyGroup.DataSource = null;
                rptSocietyGroup.DataBind();
                lblPageInfo.Text = "No records found.";
            }
            upnlInstitutes.Update();
        }

        protected void rptInstitutes_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int instId = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "EditRow")
            {
                DataTable dt = bl.GetInstituteById(instId);
                if (dt.Rows.Count > 0)
                {
                    DataRow dr = dt.Rows[0];
                    hfInstituteId.Value = instId.ToString();
                    txtInstName.Text = dr["InstituteName"].ToString();
                    txtInstCode.Text = dr["InstituteCode"].ToString();
                    txtEducationType.Text = dr["EducationType"].ToString();
                    txtPhone.Text = dr["Phone"].ToString();
                    txtEmail.Text = dr["Email"].ToString();
                    txtShortName.Text = dr["ShortName"].ToString();
                    ddlSocieties.SelectedValue = dr["SocietyId"].ToString();

                    // Requirement: Scroll up and disable code editing
                    txtInstCode.ReadOnly = true;
                    txtInstCode.BackColor = System.Drawing.Color.LightGray;
                    btnAddInst.Text = "Update Institute";
                    lblMsg.Text = "Editing Institute: " + dr["InstituteName"];
                    lblMsg.CssClass = "text-primary fw-bold";

                    ScriptManager.RegisterStartupScript(this, GetType(), "ScrollUp", "window.scrollTo({top: 0, behavior: 'smooth'});", true);
                }
            }
            else if (e.CommandName == "DeleteRow")
            {
                bl.DeleteInstitute(instId);
                lblMsg.Text = "Institute Deleted Successfully!";
                lblMsg.CssClass = "text-danger fw-bold";
                BindInstitutes(); // Card will automatically re-adjust
            }
        }


        private void LoadSocieties()
        {
            DataTable dt = bl.GetActiveSocieties();

            ddlSocieties.DataSource = dt;
            ddlSocieties.DataTextField = "SocietyName";
            ddlSocieties.DataValueField = "SocietyId";
            ddlSocieties.DataBind();
            ddlSocieties.Items.Insert(0, new ListItem("-- Select Society --", "0"));

            ddlFilterSociety.DataSource = dt;
            ddlFilterSociety.DataTextField = "SocietyName";
            ddlFilterSociety.DataValueField = "SocietyId";
            ddlFilterSociety.DataBind();
            ddlFilterSociety.Items.Insert(0, new ListItem("All Societies", "0"));
        }

        protected void btnAddInst_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            int instituteId = Convert.ToInt32(hfInstituteId.Value);
            int societyId = Convert.ToInt32(ddlSocieties.SelectedValue);
            string code = txtInstCode.Text.Trim();

            if (bl.IsDuplicate(societyId, txtInstName.Text.Trim(), code, instituteId))
            {
                lblMsg.Text = "Institute Name or Code already exists in this Society!";
                return;
            }

            InstituteGC model = new InstituteGC
            {
                InstituteId = instituteId,
                SocietyId = societyId,
                InstituteName = txtInstName.Text.Trim(),
                InstituteCode = code,
                EducationType = txtEducationType.Text.Trim(),
                Phone = txtPhone.Text.Trim(),
                Email = txtEmail.Text.Trim(),
                ShortName = txtShortName.Text.Trim()
            };

            if (fuLogo.HasFile)
            {
                string folderPath = Server.MapPath("~/Uploads/InstituteLogos/");
                if (!Directory.Exists(folderPath))
                    Directory.CreateDirectory(folderPath);

                string fileName = Guid.NewGuid() + Path.GetExtension(fuLogo.FileName);
                fuLogo.SaveAs(Path.Combine(folderPath, fileName));
                model.LogoURL = "~/Uploads/InstituteLogos/" + fileName;
            }

            if (instituteId == 0)
            {
                bl.InsertInstitute(model);
                lblMsg.Text = "Saved Successfully!";
            }

            else
                bl.UpdateInstitute(model);

            hfInstituteId.Value = "0";
            ClearForm();
            BindInstitutes();
        }

        protected void rptSocietyGroup_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int instituteId = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "OpenDashboard")
            {
                int societyId = bl.GetSocietyIdByInstitute(instituteId);

                Session["InstituteId"] = instituteId;
                Session["SocietyId"] = societyId;

                Response.Redirect("~/Admin/Dashboard.aspx");
            }
            else if (e.CommandName == "Toggle")
            {
                bl.ToggleInstituteStatus(instituteId);
                BindInstitutes();
            }
            else if (e.CommandName == "EditRow")
            {
                DataTable dt = bl.GetInstituteById(instituteId);
                if (dt.Rows.Count > 0)
                {
                    DataRow row = dt.Rows[0];

                    hfInstituteId.Value = instituteId.ToString();
                    ddlSocieties.SelectedValue = row["SocietyId"].ToString();
                    txtInstName.Text = row["InstituteName"].ToString();
                    txtInstCode.Text = row["InstituteCode"].ToString();
                    txtEducationType.Text = row["EducationType"].ToString();
                    txtPhone.Text = row["Phone"].ToString();
                    txtEmail.Text = row["Email"].ToString();
                    txtShortName.Text = row["ShortName"].ToString();
                }
            }
        }

        protected void btnNext_Click(object sender, EventArgs e) { CurrentPage++; BindInstitutes(); }
        protected void btnPrev_Click(object sender, EventArgs e) { CurrentPage--; BindInstitutes(); }
        protected void ddlFilterSociety_SelectedIndexChanged(object sender, EventArgs e) { CurrentPage = 0; BindInstitutes(); }

        protected void btnClear_Click(object sender, EventArgs e) { ClearForm();  }

        private void ClearForm()
        {
            hfInstituteId.Value = "0";
            txtInstName.Text = txtInstCode.Text = txtShortName.Text = txtEducationType.Text = txtPhone.Text = txtEmail.Text = "";
            txtInstCode.ReadOnly = false;
            txtInstCode.BackColor = System.Drawing.Color.White;            
            btnAddInst.Text = "Save Institute";
            ddlSocieties.SelectedIndex = 0;

        }
        
    }
}

