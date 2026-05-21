//using LearningManagementSystem.BL;
//using LearningManagementSystem.GC;
//using System;
//using System.Data;
//using System.Data.SqlClient;
//using System.Web.UI;
//using System.Web.UI.WebControls;

//namespace LearningManagementSystem.Admin
//{
//    public partial class AcademicSetup : BasePage
//    {
//        AcademicSetupBL bl = new AcademicSetupBL();

//        private bool IsSuperAdmin()
//        {
//            return Session["Role"]?.ToString() == "SuperAdmin";
//        }

//        protected void Page_Load(object sender, EventArgs e)
//        {
//            if (!IsPostBack)
//            {
//                BindAll();
//            }
//        }



//        private void BindAll()
//        {
//            DataTable dtLevel = bl.GetData("Level", InstituteId, SessionId);
//            DataTable dtSem = bl.GetData("Semester", InstituteId, SessionId);
//            DataTable dtSec = bl.GetData("Section", InstituteId, SessionId);

//            gvLevels.DataSource = dtLevel;
//            gvLevels.DataBind();

//            gvSemesters.DataSource = dtSem;
//            gvSemesters.DataBind();

//            gvSections.DataSource = dtSec;
//            gvSections.DataBind();

//            // 🔥 STATS
//            lblLevels.Text = dtLevel.Rows.Count.ToString();
//            lblSemesters.Text = dtSem.Rows.Count.ToString();
//            lblSections.Text = dtSec.Rows.Count.ToString();
//        }

//        protected void PrepareCreate_Click(object sender, EventArgs e)
//        {
//            if (IsSuperAdmin())
//            {
//                ShowToast("warning", "You have view-only access.");
//                return;
//            }

//            txtName.Text = "";
//            hfEntryId.Value = "";
//            hfEntryType.Value = (sender as LinkButton).CommandArgument;

//            ScriptManager.RegisterStartupScript(this, GetType(),
//                "pop", $"showSetupModal('Add {hfEntryType.Value}');", true);
//        }

//        protected void gv_RowCommand(object sender, GridViewCommandEventArgs e)
//        {
//            string[] args = e.CommandArgument.ToString().Split('|');
//            string type = args[0];
//            int id = Convert.ToInt32(args[1]);

//            if (IsSuperAdmin())
//            {
//                ShowToast("warning", "You have view-only access.");
//                return;
//            }

//            try
//            {
//                if (e.CommandName == "EditRow")
//                {
//                    hfEntryType.Value = type;
//                    hfEntryId.Value = id.ToString();

//                    DataTable dt = bl.GetById(type, id, InstituteId, SessionId);

//                    if (dt.Rows.Count > 0)
//                        txtName.Text = dt.Rows[0][0].ToString();

//                    ScriptManager.RegisterStartupScript(this, GetType(),
//                        "pop", $"showSetupModal('Edit {type}');", true);
//                }
//                else if (e.CommandName == "DeleteRow")
//                {
//                    bl.Delete(type, id, InstituteId, SessionId);
//                    BindAll();

//                    ShowToast("success", $"{type} deleted successfully!");
//                }
//            }
//            catch (SqlException ex)
//            {
//                if (ex.Number == 547) // FK constraint
//                {
//                    ShowToast("error", $"{type} is used in another table. You can deactivate it instead.");
//                }
//                else
//                {
//                    ShowToast("error", "Something went wrong.");
//                }
//            }
//        }
//        protected void btnSave_Click(object sender, EventArgs e)
//        {
//            if (IsSuperAdmin())
//            {
//                ShowToast("warning", "You have view-only access.");
//                return;
//            }

//            try
//            {
//                AcademicSetupGC obj = new AcademicSetupGC
//                {
//                    Id = string.IsNullOrEmpty(hfEntryId.Value) ? 0 : Convert.ToInt32(hfEntryId.Value),
//                    SocietyId = SocietyId,
//                    InstituteId = InstituteId,
//                    SessionId = SessionId,
//                    Name = txtName.Text.Trim(),
//                    Type = hfEntryType.Value
//                };

//                if (obj.Id == 0)
//                {
//                    bl.Insert(obj);
//                    ShowToast("success", "Saved successfully!");
//                }
//                else
//                {
//                    bl.Update(obj);
//                    ShowToast("info", "Updated successfully!");
//                }

//                BindAll();
//            }
//            catch
//            {
//                ShowToast("error", "Operation failed.");
//            }
//        }

//        private void ShowToast(string type, string message)
//        {
//            ScriptManager.RegisterStartupScript(this, GetType(),
//                "toast", $"showToast('{type}','{message}');", true);
//        }
//    }
//}


//================================================================================================================================================================

using LearningManagementSystem.BL;
using LearningManagementSystem.GC;
using System;
using System.Data;
using System.Data.SqlClient;
using System.Text.RegularExpressions;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace LearningManagementSystem.Admin
{
    public partial class AcademicSetup : BasePage
    {
        private readonly AcademicSetupBL _bl = new AcademicSetupBL();

        private bool IsSuperAdmin() =>
            Session["Role"]?.ToString() == "SuperAdmin";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
                BindAll();
        }

        private void BindAll()
        {
            DataTable dtLevel = _bl.GetData("Level", InstituteId, SessionId);
            DataTable dtSem = _bl.GetData("Semester", InstituteId, SessionId);
            DataTable dtSec = _bl.GetData("Section", InstituteId, SessionId);

            gvLevels.DataSource = dtLevel; gvLevels.DataBind();
            gvSemesters.DataSource = dtSem; gvSemesters.DataBind();
            gvSections.DataSource = dtSec; gvSections.DataBind();

            lblLevels.Text = dtLevel.Rows.Count.ToString();
            lblSemesters.Text = dtSem.Rows.Count.ToString();
            lblSections.Text = dtSec.Rows.Count.ToString();
        }

        protected void PrepareCreate_Click(object sender, EventArgs e)
        {
            if (IsSuperAdmin()) { ShowToast("warning", "You have view-only access."); return; }

            txtName.Text = "";
            hfEntryId.Value = "";
            hfEntryType.Value = (sender as LinkButton)?.CommandArgument ?? "";

            OpenModal($"Add {hfEntryType.Value}");
        }

        protected void gv_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            string[] args = e.CommandArgument.ToString().Split('|');
            string type = args[0];
            int id = Convert.ToInt32(args[1]);

            if (IsSuperAdmin()) { ShowToast("warning", "You have view-only access."); return; }

            try
            {
                if (e.CommandName == "EditRow")
                {
                    hfEntryType.Value = type;
                    hfEntryId.Value = id.ToString();

                    DataTable dt = _bl.GetById(type, id, InstituteId, SessionId);
                    if (dt.Rows.Count > 0)
                        txtName.Text = dt.Rows[0][0].ToString();

                    OpenModal($"Edit {type}");
                }
                else if (e.CommandName == "DeleteRow")
                {
                    _bl.Delete(type, id, InstituteId, SessionId);
                    BindAll();
                    ShowToast("success", $"{type} deleted successfully!");
                }
            }
            catch (SqlException ex)
            {
                if (ex.Number == 547)
                {
                    // FK violation — tell user exactly what is blocking deletion
                    string usedIn = GetFkMessage(type);
                    ShowToast("error",
                        $"Cannot delete — this {type} is already used in {usedIn}. " +
                        "Please remove those references first, or deactivate it instead.");
                }
                else
                {
                    ShowToast("error", "An unexpected database error occurred.");
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[AcademicSetup.RowCmd] {ex}");
                ShowToast("error", "Something went wrong. Please try again.");
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (IsSuperAdmin()) { ShowToast("warning", "You have view-only access."); ReopenModal(); return; }

            string type = hfEntryType.Value;
            string name = txtName.Text.Trim();
            int id = string.IsNullOrEmpty(hfEntryId.Value) ? 0 : Convert.ToInt32(hfEntryId.Value);

            // ── 1. Empty ──────────────────────────────────────
            if (string.IsNullOrWhiteSpace(name))
            {
                ShowToast("warning", "Name is required — please enter a value.");
                ReopenModal(); return;
            }

            // ── 2. Min length ──────────────────────────────────
            if (name.Length < 2)
            {
                ShowToast("warning", "Name must be at least 2 characters.");
                ReopenModal(); return;
            }

            // ── 3. Max length ──────────────────────────────────
            if (name.Length > 100)
            {
                ShowToast("warning", "Name must not exceed 100 characters.");
                ReopenModal(); return;
            }

            // ── 4. Allowed characters ──────────────────────────
            // Sections: letters, digits, spaces, hyphens (e.g. "A", "Sec-A", "Section 1")
            // Levels & Semesters: same + dots (e.g. "Year 1", "Sem.I", "Level-II")
            string pattern = type == "Section"
                ? @"^[a-zA-Z0-9\s\-]+$"
                : @"^[a-zA-Z0-9\s\-\.]+$";

            if (!Regex.IsMatch(name, pattern))
            {
                string allowed = type == "Section"
                    ? "letters, numbers, spaces, and hyphens"
                    : "letters, numbers, spaces, hyphens, and dots";
                ShowToast("warning", $"{type} name can only contain {allowed}. Special characters are not allowed.");
                ReopenModal(); return;
            }

            // ── 5. Duplicate check ─────────────────────────────
            if (_bl.IsDuplicate(type, name, InstituteId, SessionId, id))
            {
                ShowToast("warning",
                    $"A {type} named \"{name}\" already exists in this session. " +
                    "Please use a unique name.");
                ReopenModal(); return;
            }

            // ── 6. Save ────────────────────────────────────────
            try
            {
                var obj = new AcademicSetupGC
                {
                    Id = id,
                    SocietyId = SocietyId,
                    InstituteId = InstituteId,
                    SessionId = SessionId,
                    Name = name,
                    Type = type
                };

                if (id == 0)
                {
                    _bl.Insert(obj);
                    ShowToast("success", $"{type} \"{name}\" added successfully!");
                }
                else
                {
                    _bl.Update(obj);
                    ShowToast("info", $"{type} updated to \"{name}\" successfully!");
                }

                BindAll();
                // Modal closes on success (no ReopenModal call)
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[AcademicSetup.Save] {ex}");
                ShowToast("error", "Save failed. Please try again.");
                ReopenModal();
            }
        }

        // ── Helpers ───────────────────────────────────────────
        private static string GetFkMessage(string type) =>
            type == "Level" ? "Subjects, Student Records, or Class Assignments" :
            type == "Semester" ? "Subjects, Student Records, or Class Assignments" :
            type == "Section" ? "Students, Subject Assignments, or Attendance Records" :
                                 "another table";

        private void ShowToast(string type, string message)
        {
            message = message.Replace("'", "\\'").Replace("\r", "").Replace("\n", " ");
            ScriptManager.RegisterStartupScript(this, GetType(),
                "toast_" + Guid.NewGuid().ToString("N").Substring(0, 8),
                $"showToast('{type}','{message}');", true);
        }

        private void OpenModal(string title)
        {
            title = title.Replace("'", "\\'");
            ScriptManager.RegisterStartupScript(this, GetType(),
                "modal_" + Guid.NewGuid().ToString("N").Substring(0, 8),
                $"showSetupModal('{title}');", true);
        }

        private void ReopenModal()
        {
            string type = hfEntryType.Value;
            bool isNew = string.IsNullOrEmpty(hfEntryId.Value) || hfEntryId.Value == "0";
            OpenModal(isNew ? $"Add {type}" : $"Edit {type}");
        }
    }
}
