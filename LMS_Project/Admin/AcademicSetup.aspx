<%@ Page Title="Academic Setup" Language="C#" MasterPageFile="~/Admin/AdminMaster.master" AutoEventWireup="true" CodeBehind="AcademicSetup.aspx.cs" Inherits="LearningManagementSystem.Admin.AcademicSetup" %>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">
    <asp:HiddenField ID="hfEntryId" runat="server" />
    <asp:HiddenField ID="hfEntryType" runat="server" />
    <asp:Label ID="lblMsg" runat="server" CssClass="fw-bold mb-2 d-block" />

    <div class="row g-4">
        <div class="col-md-4">
            <div class="card shadow-sm border-0">
                <div class="card-header bg-white d-flex justify-content-between align-items-center">
                   <h5 class="mb-0">Study Levels</h5>
                    <asp:LinkButton ID="btnAddYear" runat="server" CssClass="btn btn-sm btn-success" OnClick="PrepareCreate_Click" CommandArgument="Level">
                        <i class="fa-solid fa-plus"></i> Add
                    </asp:LinkButton>
                </div>
                <div class="card-body p-0">    
                    <asp:GridView ID="gvLevels" runat="server"
                        CssClass="table mb-0 align-middle"
                        AutoGenerateColumns="false"
                        OnRowCommand="gv_RowCommand"
                        GridLines="None">

                        <Columns>
                            <asp:BoundField DataField="LevelName" HeaderText="Level Name" />
                            <asp:TemplateField HeaderText="Actions">
                                <ItemTemplate>
                                    <asp:LinkButton runat="server"
                                        CommandName="EditRow"
                                        CommandArgument='<%# "Level|"+Eval("LevelId") %>'
                                        CssClass="text-primary me-2">
                                        <i class="fa-solid fa-pen"></i>
                                    </asp:LinkButton>

                                    <asp:LinkButton runat="server"
                                        CommandName="DeleteRow"
                                        CommandArgument='<%# "Level|"+Eval("LevelId") %>'
                                        CssClass="text-danger"
                                        OnClientClick="return confirm('Are you sure?');">
                                        <i class="fa-solid fa-trash"></i>
                                    </asp:LinkButton>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </div>
            </div>
        </div>

        <div class="col-md-4">
            <div class="card shadow-sm border-0">
                <div class="card-header bg-white d-flex justify-content-between align-items-center">
                    <h5 class="mb-0">Semesters</h5>
                    <asp:LinkButton ID="btnAddSem" runat="server" CssClass="btn btn-sm btn-info text-white" OnClick="PrepareCreate_Click" CommandArgument="Semester">
                        <i class="fa-solid fa-plus"></i> Add
                    </asp:LinkButton>
                </div>
                <div class="card-body p-0">
                    <asp:GridView ID="gvSemesters" runat="server" CssClass="table mb-0 align-middle" AutoGenerateColumns="false" OnRowCommand="gv_RowCommand" GridLines="None">
                        <Columns>
                            <asp:BoundField DataField="SemesterName" HeaderText="Semester Name" />
                            <asp:TemplateField HeaderText="Actions" ItemStyle-Width="80px">
                                <ItemTemplate>
                                    <asp:LinkButton runat="server" CommandName="EditRow" CommandArgument='<%# "Semester|"+Eval("SemesterId") %>' CssClass="text-primary me-2"><i class="fa-solid fa-pen"></i></asp:LinkButton>
                                    <asp:LinkButton runat="server" CommandName="DeleteRow" CommandArgument='<%# "Semester|"+Eval("SemesterId") %>' CssClass="text-danger" OnClientClick="return confirm('Are you sure?');"><i class="fa-solid fa-trash"></i></asp:LinkButton>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </div>
            </div>
        </div>

        <div class="col-md-4">
            <div class="card shadow-sm border-0">
                <div class="card-header bg-white d-flex justify-content-between align-items-center">
                    <h5 class="mb-0">Sections</h5>
                    <asp:LinkButton ID="btnAddSection" runat="server" CssClass="btn btn-sm btn-primary" OnClick="PrepareCreate_Click" CommandArgument="Section">
                        <i class="fa-solid fa-plus"></i> Add
                    </asp:LinkButton>
                </div>
                <div class="card-body p-0">
                    <asp:GridView ID="gvSections" runat="server" CssClass="table mb-0 align-middle" AutoGenerateColumns="false" OnRowCommand="gv_RowCommand" GridLines="None">
                        <Columns>
                            <asp:BoundField DataField="SectionName" HeaderText="Section Name" />
                            <asp:TemplateField HeaderText="Actions" ItemStyle-Width="80px">
                                <ItemTemplate>
                                    <asp:LinkButton runat="server" CommandName="EditRow" CommandArgument='<%# "Section|"+Eval("SectionId") %>' CssClass="text-primary me-2"><i class="fa-solid fa-pen"></i></asp:LinkButton>
                                    <asp:LinkButton runat="server" CommandName="DeleteRow" CommandArgument='<%# "Section|"+Eval("SectionId") %>' CssClass="text-danger" OnClientClick="return confirm('Are you sure?');"><i class="fa-solid fa-trash"></i></asp:LinkButton>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </div>
            </div>
        </div>
    </div>

    <div class="modal fade" id="SetupModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header bg-success text-white">
                    <h5 class="modal-title" id="modalTitle">Academic Detail</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label fw-bold">Enter Value</label>
                        <asp:TextBox ID="txtName" runat="server" CssClass="form-control" placeholder="Enter name" />
                        <asp:RequiredFieldValidator ID="rfvName" runat="server" ControlToValidate="txtName" ErrorMessage="Name is required" ForeColor="Red" ValidationGroup="vgSetup" Display="Dynamic" CssClass="small" />
                    </div>
                </div>
                <div class="modal-footer">
                    <button class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <asp:Button ID="btnSave" runat="server" Text="Save Record" CssClass="btn btn-success" ValidationGroup="vgSetup" OnClick="btnSave_Click" />
                </div>
            </div>
        </div>
    </div>

    <script>
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