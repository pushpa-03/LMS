<%@ Page Title="Streams"
    Language="C#"
    MasterPageFile="~/Admin/AdminMaster.master"
    AutoEventWireup="true"
    CodeBehind="AddStream.aspx.cs"
    Inherits="LearningManagementSystem.Admin.AddStream" %>


<asp:Content ID="c2" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

    <!-- 🔥 TOAST -->
<div class="toast-container position-fixed top-3 end-0 p-3" style="z-index:9999;">
    <div id="liveToast" class="toast text-white border-0"
         role="alert"
         aria-live="assertive"
         aria-atomic="true">

        <div class="d-flex bg-body-primary">
            <div class="toast-body" id="toastMsg"></div>
            <button type="button"
                    class="btn-close btn-close-white me-2 m-auto"
                    data-bs-dismiss="toast"></button>
        </div>

    </div>
</div>

    <asp:HiddenField ID="hfStreamId" runat="server" />


    <!-- ================= HEADER ================= -->
   <div class="d-flex flex-column flex-md-row justify-content-between align-items-start align-items-md-center gap-3 mb-4">

        <div>
            <h3 class="fw-bold mb-1">Streams Management</h3>
            <small class="text-muted">Manage all academic streams</small>
            <span>|</span>
            <small class="text-muted">
                Last updated: <%= DateTime.Now.ToString("dd MMM yyyy hh:mm tt") %>
            </small>
        </div>

        <div class="d-flex gap-2 w-md-auto">

            <!-- Filter -->
            <div>    
                <!-- 👁 TOGGLE VIEW -->
                <asp:LinkButton ID="btnToggleView" runat="server"
                    CssClass="btn btn-outline-dark rounded-pill px-3"
                    OnClick="Filter_Click"
                    CommandArgument="Toggle">
                    👁 View Inactive
                </asp:LinkButton>
            </div>

            <!-- Add -->
            <a href="#" data-bs-toggle="modal" data-bs-target="#CreateModal"
               class="btn btn-primary rounded-pill px-4 fw-semibold shadow-sm">
                <i class="fa fa-plus"></i> Add Stream
            </a>

        </div>
    </div>

   <!-- ================= STATS ================= -->
    <div class="row g-3 mb-4">

        <div class="col-md-4">
            <div class="card shadow-sm border-0 rounded-4 p-3">
                <div class="d-flex align-items-center">
                    <div class="bg-primary text-white rounded-circle p-3 me-3">
                        <i class="fa fa-layer-group"></i>
                    </div>
                    <div>
                        <div class="text-muted small">Total Streams</div>
                        <h4 class="fw-bold mb-0"><asp:Label ID="lblTotal" runat="server" Text="0" /></h4>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-md-4">
            <div class="card shadow-sm border-0 rounded-4 p-3">
                <div class="d-flex align-items-center">
                    <div class="bg-success text-white rounded-circle p-3 me-3">
                        <i class="fa fa-check"></i>
                    </div>
                    <div>
                        <div class="text-muted small">Active</div>
                        <h4 class="fw-bold mb-0"><asp:Label ID="lblActive" runat="server" Text="0" /></h4>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-md-4">
            <div class="card shadow-sm border-0 rounded-4 p-3">
                <div class="d-flex align-items-center">
                    <div class="bg-danger text-white rounded-circle p-3 me-3">
                        <i class="fa fa-times"></i>
                    </div>
                    <div>
                        <div class="text-muted small">Inactive</div>
                        <h4 class="fw-bold mb-0"><asp:Label ID="lblInactive" runat="server" Text="0" /></h4>
                    </div>
                </div>
            </div>
        </div>

    </div>

    <!-- ================= TOP ACTION BAR ================= -->
<div class="card border-0 shadow-sm rounded-4 mb-3 p-3">

    <div class="d-flex justify-content-between align-items-center flex-wrap gap-2">

        <!-- 🔍 SEARCH -->
        <div class="input-group w-100 w-md-auto" style="min-width:200px;">
            <span class="input-group-text bg-white"><i class="fa fa-search"></i></span>
           <input type="text" id="txtSearch" runat="server"
                   class="form-control"
                   placeholder="Search streams..."
                   onkeypress="if(event.key==='Enter'){ __doPostBack('<%= txtSearch.UniqueID %>', ''); return false; }" />
        </div>

    </div>

</div>

    <!-- ================= TABLE ================= -->
    <div class="card border-0 shadow rounded-4">
        <div class="card-body p-0">

            <div class="table-responsive">

                <asp:GridView ID="gvStreams" runat="server"
                    CssClass="table table-hover align-middle mb-0 modern-table"
                    AutoGenerateColumns="false"
                    GridLines="None"
                    OnRowCommand="gvStreams_RowCommand" 
                    RowStyle-CssClass="stream-row"
                    OnRowDataBound="gvStreams_RowDataBound">

                    <EmptyDataTemplate>
                        <div class="text-center p-5">
                            <i class="fa fa-database fa-3x text-muted mb-3"></i>
                            <h5>No Streams Found</h5>
                            <p class="text-muted">Click "Add Stream" to create one</p>
                        </div>
                    </EmptyDataTemplate>

                     <HeaderStyle CssClass="table-header text-white" />

                    <Columns>

                        <asp:BoundField DataField="StreamName" HeaderText="Stream Name" />

                        <asp:TemplateField HeaderText="Actions">
                            <ItemTemplate>

                                <asp:LinkButton runat="server"
                                    CssClass="btn btn-sm action-btn edit"
                                    CommandName="EditRow"
                                    ToolTip="Edit Stream"
                                    CommandArgument='<%# Eval("StreamId") %>'>
                                    ✏
                                </asp:LinkButton>

                                <!-- Toggle active/inactive -->
                                <asp:LinkButton runat="server"
                                    CssClass="btn btn-sm action-btn toggle"
                                    CommandName="Toggle"
                                    ToolTip="Toggle Status"
                                    OnClientClick="return confirm('Change course status?');"
                                    CommandArgument='<%# Eval("StreamId") %>'>
                                    🔄
                                </asp:LinkButton>

                                <asp:LinkButton runat="server"
                                    CssClass="btn btn-sm action-btn delete"
                                    CommandName="DeleteRow"
                                    ToolTip="Delete Stream"
                                    CommandArgument='<%# Eval("StreamId") %>'
                                    OnClientClick="return confirm('Delete stream?');">
                                    🗑
                                </asp:LinkButton>

                            </ItemTemplate>
                        </asp:TemplateField>

                    </Columns>

                </asp:GridView>

                <div id="noDataMsg" style="display:none" class="text-center p-4 text-muted">
                    No matching streams found
                </div>
            </div>
        </div>
    </div>

    <!-- ================= ADD MODAL ================= -->
    <div class="modal fade" id="CreateModal">
        <div class="modal-dialog modal-dialog-centered modal-fullscreen-sm-down">
            <div class="modal-content rounded-4">

                <div class="modal-header bg-primary text-white">
                    <h5>Add Stream</h5>
                    <button class="btn-close" data-bs-dismiss="modal"></button>
                </div>

                <div class="modal-body">
                    <label class="fw-bold">Stream Name</label>
                    <asp:TextBox ID="txtStreamName" runat="server"
                        CssClass="form-control" />
                </div>

                <div class="modal-footer">
                    <button class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>

                    <asp:Button ID="btnSave" runat="server"
                        Text="Save"
                        CssClass="btn btn-primary px-4 rounded-pill"
                        OnClick="btnSave_Click" />
                </div>

            </div>
        </div>
    </div>

    <!-- ================= EDIT MODAL ================= -->
    <div class="modal fade" id="EditModal">
        <div class="modal-dialog">
            <div class="modal-content rounded-4">

                <div class="modal-header bg-primary text-white">
                    <h5>Edit Stream</h5>
                    <button class="btn-close" data-bs-dismiss="modal"></button>
                </div>

                <div class="modal-body">
                    <label class="fw-bold">Stream Name</label>
                    <asp:TextBox ID="txtStreamNameEdit" runat="server"
                        CssClass="form-control" />
                </div>

                <div class="modal-footer">
                    <button class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>

                    <asp:Button ID="btnUpdate" runat="server"
                        Text="Update"
                        CssClass="btn btn-primary px-4 rounded-pill"
                        OnClick="btnUpdate_Click" />
                </div>

            </div>
        </div>
    </div>

    <style>
.table-header {
    background: linear-gradient(135deg, #4f46e5, #6366f1);
}
.table-header th {
    background: linear-gradient(135deg, #4f46e5, #6366f1) !important;
    color: white;
    border: none;
    padding: 14px !important;
    font-weight: 600;
    letter-spacing: 0.5px;
}
/* 🔥 Stat card hover animation */
.card:hover {
    transform: translateY(-5px) scale(1.02);
    transition: all .25s ease;
    box-shadow: 0 10px 25px rgba(0,0,0,0.1);
}

/* 🔍 Smooth table filtering */
.table tbody tr {
    transition: all .2s ease;
}

.stat-card {
    border-radius: 14px;
    transition: all .3s ease;
    cursor: pointer;
}

.stat-card:hover {
    transform: translateY(-6px) scale(1.03);
    box-shadow: 0 15px 30px rgba(0,0,0,0.12);
}

/* smooth input */
.form-control:focus {
    box-shadow: 0 0 0 0.2rem rgba(13,110,253,.15);
}

/* invalid input */
.is-invalid {
    border: 2px solid red;
}

.modal {
    z-index: 9999 !important;
}

.modal-backdrop {
    z-index: 9990 !important;
}

/* center modal properly */
.modal-dialog {
    margin-top: 100px;
}

/* fix header overlap */
body.modal-open {
    padding-right: 0 !important;
}

/* 📱 Mobile optimization */
@media (max-width: 768px) {

    h3 {
        font-size: 20px;
    }

    .btn {
        font-size: 13px;
        padding: 6px 12px;
    }

    .table th, .table td {
        font-size: 13px;
        padding: 8px;
    }

    .card {
        padding: 10px !important;
    }

    .modal-content {
        border-radius: 12px;
    }

    .toast-container {
        width: 100%;
        right: 0;
        left: 0;
        padding: 10px;
    }

    .toast {
        width: 100%;
    }
}
</style>

    <script>        
        function highlightRow(id) {
            let row = document.querySelector(`[data-id='${id}']`);
            if (row) {
                row.style.background = "#fff3cd";
                setTimeout(() => row.style.background = "", 1500);
            }
        }
        function checkEmpty() {
            let rows = document.querySelectorAll("#<%= gvStreams.ClientID %> tbody tr");
            let visible = Array.from(rows).some(r => r.style.display !== "none");

            let emptyDiv = document.getElementById("noDataMsg");

            if (!visible) {
                emptyDiv.style.display = "block";
            } else {
                emptyDiv.style.display = "none";
            }
        }
        document.addEventListener("DOMContentLoaded", function () {

            // 🔍 SEARCH
            const searchInput = document.getElementById("<%= txtSearch.ClientID %>");
            if (searchInput) {
                searchInput.addEventListener("keyup", function () {

                    let value = searchInput.value.toLowerCase();
                    let rows = document.querySelectorAll("#<%= gvStreams.ClientID %> tbody tr");

            let visible = false;

            rows.forEach(row => {
                let text = row.innerText.toLowerCase();
                let match = text.includes(value);
                row.style.display = match ? "" : "none";
                if (match) visible = true;
            });

            document.getElementById("noDataMsg").style.display = visible ? "none" : "block";
        });
    }

    // 🔴 DUPLICATE CHECK
    const input = document.getElementById("<%= txtStreamName.ClientID %>");
    if (input) {
        input.addEventListener("keyup", function () {

            let value = input.value.trim().toLowerCase();
            let exists = false;

            document.querySelectorAll("#<%= gvStreams.ClientID %> tbody tr").forEach(row => {
                let text = row.cells[0]?.innerText.toLowerCase();
                if (text === value) exists = true;
            });

            input.classList.toggle("is-invalid", exists);
        });
            }

        });
    </script>
</asp:Content>