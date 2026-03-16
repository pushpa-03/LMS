<%@ Page Title="Assign Subject Faculty" Language="C#"
    MasterPageFile="~/Admin/AdminMaster.master"
    AutoEventWireup="true"
    CodeBehind="AssignSubjectFaculty.aspx.cs"
    Inherits="LearningManagementSystem.Admin.AssignSubjectFaculty" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

    <asp:Label ID="lblMsg" runat="server" CssClass="fw-bold mb-2 d-block" />

    <div class="d-flex justify-content-between align-items-center mb-3">
        <h3 class="mb-0">Assign Teacher To Subject</h3>
        <a href="#" data-bs-toggle="modal" data-bs-target="#AssignModal"
            class="btn btn-success">
            <i class="fa-solid fa-plus"></i> Assign
        </a>
    </div>

    <div class="card shadow-sm border-0">
        <div class="card-body p-0">
            <div class="table-responsive">

                <asp:GridView ID="gvAssign" runat="server"
                    CssClass="table align-middle mb-0"
                    AutoGenerateColumns="false"
                    OnRowCommand="gvAssign_RowCommand">

                    <Columns>

                        <asp:BoundField DataField="TeacherName" HeaderText="Teacher" />
                        <asp:BoundField DataField="SubjectName" HeaderText="Subject" />
                        <asp:BoundField DataField="SessionName" HeaderText="Session" />

                        <asp:TemplateField HeaderText="Status">
                            <ItemTemplate>
                                <span class='badge <%# (bool)Eval("IsActive") ? "bg-success" : "bg-danger" %>'>
                                    <%# (bool)Eval("IsActive") ? "Active" : "Inactive" %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Actions">
                            <ItemTemplate>

                                <asp:LinkButton runat="server"
                                    CssClass="btn btn-sm btn-warning me-2"
                                    CommandName="Toggle"
                                    CommandArgument='<%# Eval("SubjectFacultyId") %>'
                                    OnClientClick="return confirm('Toggle status?');">
                                    <i class="fa-solid fa-toggle-on"></i>
                                </asp:LinkButton>

                                <asp:LinkButton runat="server"
                                    CssClass="btn btn-sm btn-danger"
                                    CommandName="DeleteRow"
                                    CommandArgument='<%# Eval("SubjectFacultyId") %>'
                                    OnClientClick="return confirm('Delete assignment?');">
                                    <i class="fa-solid fa-trash-can"></i>
                                </asp:LinkButton>

                            </ItemTemplate>
                        </asp:TemplateField>

                    </Columns>

                </asp:GridView>

            </div>
        </div>
    </div>


    <!-- MODAL -->
    <div class="modal fade" id="AssignModal">
        <div class="modal-dialog">
            <div class="modal-content">

                <div class="modal-header bg-success text-white">
                    <h5 class="modal-title">Assign Subject</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>

                <div class="modal-body">
                    <div class="row g-3">

                        <div class="col-md-12">
                            <label>Teacher*</label>
                            <asp:DropDownList ID="ddlTeacher"
                                runat="server"
                                CssClass="form-select" />
                        </div>

                        <div class="col-md-12">
                            <label>Subject*</label>
                            <asp:DropDownList ID="ddlSubject"
                                runat="server"
                                CssClass="form-select" />
                        </div>

                    </div>
                </div>

                <div class="modal-footer">
                    <button class="btn btn-secondary"
                        data-bs-dismiss="modal">Cancel</button>

                    <asp:Button ID="btnSave"
                        runat="server"
                        Text="Assign"
                        CssClass="btn btn-success"
                        OnClick="btnSave_Click" />
                </div>

            </div>
        </div>
    </div>

</asp:Content>