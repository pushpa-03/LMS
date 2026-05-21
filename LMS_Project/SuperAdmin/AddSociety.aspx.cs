using System;
using System.Data;
using System.Web.UI;

namespace LMS.SuperAdmin
{
    public partial class AddSociety : System.Web.UI.Page
    {
        SocietyBL bl = new SocietyBL();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null)
            {
                Response.Redirect("~/Default.aspx");
                return;
            }

            if (!IsPostBack)
            {
                BindSocieties();
            }
        }

        private void BindSocieties()
        {
            DataTable dt = bl.GetAllSocieties();

            rptSocieties.DataSource = dt;
            rptSocieties.DataBind();

            // Set count
            lblCount.Text = dt.Rows.Count.ToString();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(txtSocietyName.Text) ||
                string.IsNullOrEmpty(txtSocietyCode.Text))
            {
                hfToastMsg.Value = "Please fix the highlighted fields before saving.";
                hfToastType.Value = "error";
                return;
            }

            try
            {
                SocietyGC soc = new SocietyGC
                {
                    SocietyName = txtSocietyName.Text.Trim(),
                    SocietyCode = txtSocietyCode.Text.Trim()
                };

                if (string.IsNullOrEmpty(hfSocietyId.Value))
                {
                    // INSERT
                    bl.InsertSociety(soc);

                    hfToastMsg.Value = "Society added successfully.";
                    hfToastType.Value = "success";
                }
                else
                {
                    // UPDATE
                    soc.SocietyId = Convert.ToInt32(hfSocietyId.Value);
                    bl.UpdateSociety(soc);

                    hfToastMsg.Value = "Society updated successfully.";
                    hfToastType.Value = "success";
                }

                ClearForm();
                BindSocieties();
            }
            catch (Exception ex)
            {
                hfToastMsg.Value = ex.Message;
                hfToastType.Value = "error";
            }
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            ClearForm();
        }



        protected void rptSocieties_ItemCommand(object sender,
         System.Web.UI.WebControls.RepeaterCommandEventArgs e)
            {
                try
                {
                    int societyId = Convert.ToInt32(e.CommandArgument);

                    if (e.CommandName == "ToggleStatus")
                    {
                        bl.ToggleSocietyStatus(societyId);

                        hfToastMsg.Value = "Society status updated successfully.";
                        hfToastType.Value = "success";

                        BindSocieties();
                    }
                    else if (e.CommandName == "EditSoc")
                    {
                        DataTable dt = bl.GetSocietyById(societyId);

                        if (dt.Rows.Count > 0)
                        {
                            hfSocietyId.Value = dt.Rows[0]["SocietyId"].ToString();
                            txtSocietyName.Text = dt.Rows[0]["SocietyName"].ToString();
                            txtSocietyCode.Text = dt.Rows[0]["SocietyCode"].ToString();

                            btnSave.Text = "Update Society";

                            hfToastMsg.Value = "Society loaded for editing.";
                            hfToastType.Value = "info";
                        }
                    }
                }
                catch (Exception ex)
                {
                    hfToastMsg.Value = ex.Message;
                    hfToastType.Value = "error";
                }
            }
            protected void btnDoDelete_Click(object sender, EventArgs e)
            {
                try
                {
                    if (!string.IsNullOrEmpty(hfDeleteId.Value))
                    {
                        int societyId = Convert.ToInt32(hfDeleteId.Value);

                        bl.DeleteSociety(societyId);

                        hfToastMsg.Value = "Society deleted successfully.";
                        hfToastType.Value = "success";

                        BindSocieties();
                    }
                }
                catch (Exception ex)
                {
                    hfToastMsg.Value = ex.Message;
                    hfToastType.Value = "warning";
                }
                finally
                {
                    hfDeleteId.Value = "";
                }
            }

        private void ClearForm()
        {
            hfSocietyId.Value = "";
            txtSocietyName.Text = "";
            txtSocietyCode.Text = "";
            btnSave.Text = "Save Society";
        }
    }
}