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
            if (!IsPostBack)
            {
                BindSocieties();
            }
        }

        private void BindSocieties()
        {
            gvSocieties.DataSource = bl.GetAllSocieties();
            gvSocieties.DataBind();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(txtSocietyName.Text) ||
                string.IsNullOrEmpty(txtSocietyCode.Text))
                return;

            SocietyGC soc = new SocietyGC
            {
                SocietyName = txtSocietyName.Text.Trim(),
                SocietyCode = txtSocietyCode.Text.Trim()
            };

            if (string.IsNullOrEmpty(hfSocietyId.Value))
            {
                // INSERT
                bl.InsertSociety(soc);
            }
            else
            {
                // UPDATE
                soc.SocietyId = Convert.ToInt32(hfSocietyId.Value);
                bl.UpdateSociety(soc);
            }

            ClearForm();
            BindSocieties();
        }

        protected void gvSocieties_RowCommand(object sender,
                                              System.Web.UI.WebControls.GridViewCommandEventArgs e)
        {
            int societyId = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "ToggleStatus")
            {
                bl.ToggleSocietyStatus(societyId);
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
                }
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