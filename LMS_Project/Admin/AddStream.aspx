<%@ Page Title="Streams"
    Language="C#"
    MasterPageFile="~/Admin/AdminMaster.master"
    AutoEventWireup="true"
    CodeBehind="AddStream.aspx.cs"
    Inherits="LearningManagementSystem.Admin.AddStream" %>

<asp:Content ID="c1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
</asp:Content>

<asp:Content ID="c2" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

    <!-- Hidden -->
    <asp:HiddenField ID="hfStreamId" runat="server" />

    <!-- Message -->
    <asp:Label ID="lblMsg" runat="server"
        Visible="false"
        CssClass="alert d-block mb-3"
        EnableViewState="false" />

    <!-- Header -->
    <div class="d-flex justify-content-between align-items-center mb-4 p-3 bg-white rounded-4 shadow-sm">
        <h3 class="mb-0 fw-bold text-success">Streams</h3>

        <div class="d-flex gap-2">
            <div class="dropdown">
                <button class="btn btn-outline-secondary dropdown-toggle rounded-pill px-3"
                    type="button" data-bs-toggle="dropdown">
                    <i class="fa-solid fa-filter"></i> Filter Status
                </button>

                <ul class="dropdown-menu">
                    <li><asp:LinkButton ID="btnAll" runat="server"
                        CssClass="dropdown-item"
                        OnClick="Filter_Click"
                        CommandArgument="All">All</asp:LinkButton></li>

                    <li><asp:LinkButton ID="btnActive" runat="server"
                        CssClass="dropdown-item"
                        OnClick="Filter_Click"
                        CommandArgument="1">Active</asp:LinkButton></li>

                    <li><asp:LinkButton ID="btnInactive" runat="server"
                        CssClass="dropdown-item"
                        OnClick="Filter_Click"
                        CommandArgument="0">Inactive</asp:LinkButton></li>
                </ul>
            </div>

            <a href="#" data-bs-toggle="modal"
                data-bs-target="#CreateModal"
               class="btn btn-success rounded-pill px-4 fw-semibold shadow-sm">
                <i class="fa-solid fa-plus"></i> Add Stream
            </a>
        </div>
    </div>

    <!-- Grid -->
    <div class="card border-0 shadow rounded-4 mt-4">
        <div class="card-body p-0">
            <div class="table-responsive">

                <asp:GridView ID="gvStreams" runat="server"
                    CssClass="table table-hover table-striped align-middle mb-0"
                    AutoGenerateColumns="false"
                    GridLines="None"
                    OnRowCommand="gvStreams_RowCommand">

                    <Columns>

                        <asp:BoundField DataField="StreamName"
                            HeaderText="Stream Name" />

                     
                        <asp:TemplateField HeaderText="Status">
                            <ItemTemplate>
                                <span class='badge <%# (bool)Eval("IsActive") ? "bg-success-subtle text-success border border-success-subtle" : "bg-danger-subtle text-danger border border-danger-subtle" %>'>
                                    <%# (bool)Eval("IsActive") ? "Active" : "Inactive" %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>

                      
                        <asp:TemplateField HeaderText="Actions">
                            <ItemTemplate>

                               
                                <asp:LinkButton runat="server"
                                    CssClass="btn btn-sm btn-outline-primary rounded-circle me-2"
                                    CommandName="EditRow"
                                    CommandArgument='<%# Eval("StreamId") %>'>
                                    <i class="fa-regular fa-pen-to-square"></i>
                                </asp:LinkButton>

                                
                                <asp:LinkButton runat="server"
                                    CssClass="btn btn-sm btn-outline-warning rounded-circle me-2"
                                    CommandName="Toggle"
                                    CommandArgument='<%# Eval("StreamId") %>'
                                    OnClientClick="return confirm('Change status?');">
                                    <i class="fa-solid fa-toggle-on"></i>
                                </asp:LinkButton>

                              
                                <asp:LinkButton runat="server"
                                    CssClass="btn btn-sm btn-outline-danger rounded-circle"
                                    CommandName="DeleteRow"
                                    CommandArgument='<%# Eval("StreamId") %>'
                                    OnClientClick="return confirm('Delete stream?');">
                                    <i class="fa-solid fa-trash-can"></i>
                                </asp:LinkButton>

                            </ItemTemplate>
                        </asp:TemplateField>

                    </Columns>
                </asp:GridView>

            </div>
        </div>
    </div>

    <!-- ADD MODAL -->
    <div class="modal fade" id="CreateModal" tabindex="-1">
        <div class="modal-dialog modal-dialog-scrollable">
            <div class="modal-content rounded-4 shadow">

                <div class="modal-header bg-success bg-gradient text-white rounded-top-4">
                    <h5>Add Stream</h5>
                    <button type="button"
                        class="btn-close"
                        data-bs-dismiss="modal"></button>
                </div>

                <div class="modal-body">
                    <label class="form-label fw-bold">Stream Name</label>
                    <asp:TextBox ID="txtStreamName"
                        runat="server"
                        CssClass="form-control"
                        placeholder="Stream Name" />
                </div>

                <div class="modal-footer">
                    <button class="btn btn-secondary"
                        data-bs-dismiss="modal">Cancel</button>

                    <asp:Button ID="btnSave"
                        runat="server"
                        Text="Save"
                        class="btn btn-success px-4 rounded-pill fw-semibold"
                        OnClick="btnSave_Click" />
                </div>

            </div>
        </div>
    </div>

    <!-- EDIT MODAL -->
    <div class="modal fade" id="EditModal" tabindex="-1">
        <div class="modal-dialog modal-dialog-scrollable">
            <div class="modal-content">

                <div class="modal-header bg-success text-white">
                    <h5>Edit Stream</h5>
                    <button type="button"
                        class="btn-close"
                        data-bs-dismiss="modal"></button>
                </div>

                <div class="modal-body">
                    <label>Stream Name</label>
                    <asp:TextBox ID="txtStreamNameEdit"
                        runat="server"
                        CssClass="form-control mb-2" />
                </div>

                <div class="modal-footer">
                    <button class="btn btn-secondary"
                        data-bs-dismiss="modal">Cancel</button>

                    <asp:Button ID="btnUpdate"
                        runat="server"
                        Text="Update"
                        class="btn btn-success px-4 rounded-pill fw-semibold"
                        OnClick="btnUpdate_Click" />
                </div>

            </div>
        </div>
    </div>

</asp:Content>