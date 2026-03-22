<%@ Page Title="Academic Setup" Language="C#" MasterPageFile="~/Admin/AdminMaster.master" AutoEventWireup="true" CodeBehind="AcademicSetup.aspx.cs" Inherits="LearningManagementSystem.Admin.AcademicSetup" %>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">
    <asp:HiddenField ID="hfEntryId" runat="server" />
    <asp:HiddenField ID="hfEntryType" runat="server" />
    <asp:Label ID="lblMsg" runat="server" CssClass="fw-bold mb-2 d-block" />

    <!-- ================= MODAL ================= -->
<div class="modal fade" id="SetupModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content rounded-4">

            <div class="modal-header bg-primary text-white">
                <h5 class="modal-title" id="modalTitle">Academic Setup</h5>
                <button type="button" class="btn-close btn-close-white"
                        data-bs-dismiss="modal"></button>
            </div>

            <div class="modal-body">

                <label class="fw-bold mb-2">Enter Name</label>

                <!-- ✅ THIS WAS MISSING -->
                <asp:TextBox ID="txtName" runat="server"
                    CssClass="form-control"
                    placeholder="Enter value..." />

                <asp:RequiredFieldValidator ID="rfvName"
                    runat="server"
                    ControlToValidate="txtName"
                    ErrorMessage="Required"
                    CssClass="text-danger small"
                    ValidationGroup="vgSetup" />

            </div>

            <div class="modal-footer">
                <button class="btn btn-light" data-bs-dismiss="modal">Cancel</button>

                <asp:Button ID="btnSave" runat="server"
                    Text="Save"
                    CssClass="btn btn-primary px-4"
                    ValidationGroup="vgSetup"
                    OnClick="btnSave_Click" />
            </div>

        </div>
    </div>
</div>

    <div class="container-fluid">

    <!-- 🔥 HEADER -->
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h3 class="fw-bold">Academic Setup</h3>
            <small class="text-muted">Manage Levels, Semesters & Sections</small>
            <span>|</span>
            <small class="text-muted">
                Last updated: <%= DateTime.Now.ToString("dd MMM yyyy hh:mm tt") %>
            </small>
        </div>

        <input type="text" id="txtSearch" class="form-control w-25"
               placeholder="🔍 Search..."
               onkeyup="filterAll()" />        
    </div>

  <!-- 🔥 STATS -->
<div class="row g-3 mb-4">

    <!-- LEVELS -->
    <div class="col-md-4">
        <div class="card border-0 shadow-sm stat-card d-flex flex-row align-items-center p-3">
            
            <div class="icon-box bg-primary me-3">
                <i class="fa fa-graduation-cap"></i>
            </div>

            <div>
                <h6 class="text-muted mb-1">Levels</h6>
                <h4 class="fw-bold mb-0">
                    <asp:Label ID="lblLevels" runat="server" />
                </h4>
            </div>

        </div>
    </div>

    <!-- SEMESTERS -->
    <div class="col-md-4">
        <div class="card border-0 shadow-sm stat-card d-flex flex-row align-items-center p-3">
            
            <div class="icon-box bg-success me-3">
                <i class="fa fa-calendar"></i>
            </div>

            <div>
                <h6 class="text-success mb-1">Semesters</h6>
                <h4 class="fw-bold mb-0">
                    <asp:Label ID="lblSemesters" runat="server" />
                </h4>
            </div>

        </div>
    </div>

    <!-- SECTIONS -->
    <div class="col-md-4">
        <div class="card border-0 shadow-sm stat-card d-flex flex-row align-items-center p-3">
            
            <div class="icon-box bg-secondary me-3">
                <i class="fa fa-layer-group"></i>
            </div>

            <div>
                <h6 class="text-danger mb-1">Sections</h6>
                <h4 class="fw-bold mb-0">
                    <asp:Label ID="lblSections" runat="server" />
                </h4>
            </div>

        </div>
    </div>

</div>

    <!-- 🔥 MAIN CARDS -->
    <div class="row g-4">

        <!-- LEVEL -->
        <div class="col-md-4">
            <div class="setup-card">
                <div class="card-header d-flex justify-content-between">
                    <h5>🎓 Levels</h5>
                    <asp:LinkButton runat="server" CssClass="btn btn-sm btn-light"
                        OnClick="PrepareCreate_Click" CommandArgument="Level">
                        + Add
                    </asp:LinkButton>
                </div>

                <asp:GridView ID="gvLevels" runat="server"
                    CssClass="table table-hover"
                    AutoGenerateColumns="false"
                    OnRowCommand="gv_RowCommand">

                    <EmptyDataTemplate>
                        <div class="text-center p-4 text-muted">
                            No Levels Found
                        </div>
                    </EmptyDataTemplate>

                    <Columns>
                        <asp:BoundField DataField="LevelName" HeaderText="Level" />

                        <asp:TemplateField>
                            <ItemTemplate>
                                <asp:LinkButton runat="server"
                                    CommandName="EditRow"
                                    CommandArgument='<%# "Level|"+Eval("LevelId") %>'
                                    CssClass="action edit"
                                    ToolTip="Edit">
                                    ✏
                                </asp:LinkButton>

                                <asp:LinkButton runat="server"
                                    CommandName="DeleteRow"
                                    CommandArgument='<%# "Level|"+Eval("LevelId") %>'
                                    CssClass="action delete"
                                    OnClientClick="return confirm('Delete this Level?');"
                                    ToolTip="Delete">
                                    🗑
                                </asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </div>

        <!-- SEMESTER -->
        <div class="col-md-4">
            <div class="setup-card">
                <div class="card-header d-flex justify-content-between">
                    <h5>📅 Semesters</h5>
                    <asp:LinkButton runat="server" CssClass="btn btn-sm btn-light"
                        OnClick="PrepareCreate_Click" CommandArgument="Semester">
                        + Add
                    </asp:LinkButton>
                </div>

                <asp:GridView ID="gvSemesters" runat="server"
                    CssClass="table table-hover"
                    AutoGenerateColumns="false"
                    OnRowCommand="gv_RowCommand">

                    <EmptyDataTemplate>
                        <div class="text-center p-4 text-muted">
                            No Semesters Found
                        </div>
                    </EmptyDataTemplate>

                    <Columns>
                        <asp:BoundField DataField="SemesterName" HeaderText="Semester" />
                        <asp:TemplateField>
                            <ItemTemplate>
                                <asp:LinkButton runat="server"
                                    CommandName="EditRow"
                                    CommandArgument='<%# "Semester|"+Eval("SemesterId") %>'
                                    CssClass="action edit">✏</asp:LinkButton>

                                <asp:LinkButton runat="server"
                                    CommandName="DeleteRow"
                                    CommandArgument='<%# "Semester|"+Eval("SemesterId") %>'
                                    CssClass="action delete"
                                    OnClientClick="return confirm('Delete this Semester?');">🗑</asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </div>

        <!-- SECTION -->
        <div class="col-md-4">
            <div class="setup-card">
                <div class="card-header d-flex justify-content-between">
                    <h5>🏫 Sections</h5>
                    <asp:LinkButton runat="server" CssClass="btn btn-sm btn-light"
                        OnClick="PrepareCreate_Click" CommandArgument="Section">
                        + Add
                    </asp:LinkButton>
                </div>

                <asp:GridView ID="gvSections" runat="server"
                    CssClass="table table-hover"
                    AutoGenerateColumns="false"
                    OnRowCommand="gv_RowCommand">

                    <EmptyDataTemplate>
                        <div class="text-center p-4 text-muted">
                            No Sections Found
                        </div>
                    </EmptyDataTemplate>

                    <Columns>
                        <asp:BoundField DataField="SectionName" HeaderText="Section" />
                        <asp:TemplateField>
                            <ItemTemplate>
                                <asp:LinkButton runat="server"
                                    CommandName="EditRow"
                                    CommandArgument='<%# "Section|"+Eval("SectionId") %>'
                                    CssClass="action edit">✏</asp:LinkButton>

                                <asp:LinkButton runat="server"
                                    CommandName="DeleteRow"
                                    CommandArgument='<%# "Section|"+Eval("SectionId") %>'
                                    CssClass="action delete"
                                    OnClientClick="return confirm('Delete this Section?');">🗑</asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </div>

    </div>
</div>

    <style>
        .setup-card {
            background: #fff;
            border-radius: 16px;
            padding: 10px;
            box-shadow: 0 8px 20px rgba(0,0,0,0.08);
            transition: .3s;
        }
        .setup-card:hover {
            transform: translateY(-5px);
        }

        .stat-card {
            border-radius: 16px;
            transition: all .25s ease;
            cursor: pointer;
        }

        .stat-card:hover {
            transform: translateY(-5px) scale(1.02);
            box-shadow: 0 12px 30px rgba(0,0,0,0.15);
        }

        .icon-box {
            width: 50px;
            height: 50px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 20px;
        }
                
        .action {
            padding: 6px 10px;
            border-radius: 8px;
            margin-right: 5px;
            display: inline-block;
            transition: .2s;
        }
        .action.edit { background: #e0f2fe; }
        .action.delete { background: #fee2e2; }

        .action:hover {
            transform: scale(1.1);
        }

    </style>

    <script>
        function filterAll() {
            let value = document.getElementById("txtSearch").value.toLowerCase();

            document.querySelectorAll("table tbody tr").forEach(row => {
                row.style.display = row.innerText.toLowerCase().includes(value) ? "" : "none";
            });
        }

        function showSetupModal(title) {
            document.getElementById('modalTitle').innerText = title;
            var myModal = new bootstrap.Modal(document.getElementById('SetupModal'));
            myModal.show();
        }
      
        function hideMsg() {

            var alertBox = document.getElementById('<%= lblMsg.ClientID %>');

            if (!alertBox || alertBox.innerText.trim() === "")
                return;

            setTimeout(function () {

                // Smooth animation properties
                alertBox.style.transition =
                    "opacity 0.5s ease, transform 0.5s ease, height 0.5s ease, margin 0.5s ease, padding 0.5s ease";

                alertBox.style.opacity = "0";
                alertBox.style.transform = "translateY(-20px)";
                alertBox.style.height = "0";
                alertBox.style.marginTop = "0";
                alertBox.style.marginBottom = "0";
                alertBox.style.paddingTop = "0";
                alertBox.style.paddingBottom = "0";
                alertBox.style.overflow = "hidden";

                setTimeout(function () {
                    alertBox.remove();
                }, 500);

            }, 5000);
        }  

    </script>
</asp:Content>