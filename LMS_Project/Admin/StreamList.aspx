<%@ Page Title="Stream List"
    Language="C#"
    MasterPageFile="~/Admin/AdminMaster.master"
    AutoEventWireup="true"
    CodeBehind="StreamList.aspx.cs"
    Inherits="LearningManagementSystem.Admin.StreamList" %>


<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<style>

/* ===== HEADER ===== */
.page-header {
    display:flex; justify-content:space-between;
    align-items:center; flex-wrap:wrap;
    margin-bottom:20px;
}
.page-header h4 {
    font-weight:800; color:#1565c0;
}

/* ===== SUMMARY ===== */
.summary-row { display:flex; gap:14px; flex-wrap:wrap; margin-bottom:20px; }

.summary-card {
    background:#fff; border-radius:14px;
    padding:16px; flex:1; min-width:160px;
    display:flex; gap:12px; align-items:center;
    box-shadow:0 2px 8px rgba(0,0,0,.05);
    border-left:4px solid transparent;
}

.summary-card.blue { border-color:#1565c0; }
.summary-card.green { border-color:#2e7d32; }
.summary-card.red { border-color:#c62828; }
.summary-card.orange { border-color:#ef6c00; }

.summary-card:hover {
    transform:translateY(-2px);
    box-shadow:0 4px 14px rgba(0,0,0,.08);
}

.sc-icon {
    width:42px; height:42px;
    border-radius:10px;
    display:flex; align-items:center; justify-content:center;
}
.sc-icon.blue { background:#e3f2fd; color:#1565c0; }
.sc-icon.green { background:#e8f5e9; color:#2e7d32; }
.sc-icon.red { background:#ffebee; color:#c62828; }
.sc-icon.orange { background:#fff3e0; color:#ef6c00; }

.sc-val { font-size:22px; font-weight:900; }
.sc-lbl { font-size:11px; color:#90a4ae; font-weight:700; }

/* ===== TABS ===== */
.results-tabs {
    display:flex; border-bottom:2px solid #e3e8f0;
    margin-bottom:16px;
}
.tab-btn {
    padding:10px 20px; border:none;
    background:none; font-weight:700;
    color:#78909c;
    border-bottom:3px solid transparent;
}
.tab-btn.active {
    color:#1565c0;
    border-bottom-color:#1565c0;
}

/* ===== SEARCH ===== */
.filter-bar {
    background:#fff; padding:12px;
    border-radius:12px;
    margin-bottom:16px;
}

/* ===== STREAM CARD ===== */
.stream-card {
    background:#fff;
    border-radius:12px;
    padding:16px;
    margin-bottom:5px;
    display:flex; justify-content:space-between;
    align-items:center;
    box-shadow:0 1px 6px rgba(0,0,0,.06);
    transition:all .2s;
}
.stream-card:hover {
    transform:translateY(-2px);
    box-shadow:0 4px 14px rgba(0,0,0,.08);
}

.stream-title {
    font-weight:800;
    color:#1a237e;
}

.badge-active {
    background:#e8f5e9;
    color:#2e7d32;
    padding:4px 12px;
    border-radius:20px;
    font-size:11px;
}

.badge-inactive {
    background:#ffebee;
    color:#c62828;
    padding:4px 12px;
    border-radius:20px;
    font-size:11px;
}

.empty-state {
    text-align:center;
    padding:40px;
    color:#90a4ae;
}

/* ===== PAGINATION ===== */

.pager-wrap{
    display:flex;
    justify-content:center;
    align-items:center;
    gap:8px;
    padding:20px;
    flex-wrap:wrap;
}

.pager-btn{
    min-width:38px;
    height:38px;
    padding:0 14px;

    border-radius:10px;
    border:1px solid #ddd;

    background:#fff;
    color:#333 !important;

    font-weight:700;
    text-decoration:none !important;

    display:flex;
    align-items:center;
    justify-content:center;

    transition:all .2s ease;
}

.pager-btn:hover{
    background:#f5f5f5;
    transform:translateY(-1px);
}

.pager-btn.active{
    background:#1565c0;
    color:#fff !important;
    border-color:#1565c0;
}
</style>

</asp:Content>

<asp:Content ID="cBody" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

<!-- ===== HEADER ===== -->
<div class="page-header">
    <div> 
        <h4><i class="fas fa-layer-group me-2"></i>Streams</h4> 
        <small class="text-muted">Live monitoring of all streams</small> <span> | </span> 
        <small class="text-muted"> Last updated: <%= DateTime.Now.ToString("dd MMM yyyy hh:mm tt") %> </small> 
    </div>
    

    <asp:LinkButton ID="btnToggleView" runat="server"
        CssClass="btn btn-primary"
        OnClick="Filter_Click">
        Toggle View
    </asp:LinkButton>
</div>

<!-- ===== SUMMARY ===== -->
<div class="summary-row">

    <div class="summary-card blue">
        <div class="sc-icon blue"><i class="fas fa-layer-group"></i></div>
        <div>
            <div class="sc-val"><asp:Label ID="lblTotal" runat="server" /></div>
            <div class="sc-lbl">Total Streams</div>
        </div>
    </div>

    <div class="summary-card green">
        <div class="sc-icon green"><i class="fas fa-check"></i></div>
        <div>
            <div class="sc-val"><asp:Label ID="lblActive" runat="server" /></div>
            <div class="sc-lbl">Active</div>
        </div>
    </div>

    <div class="summary-card red">
        <div class="sc-icon red"><i class="fas fa-times"></i></div>
        <div>
            <div class="sc-val"><asp:Label ID="lblInactive" runat="server" /></div>
            <div class="sc-lbl">Inactive</div>
        </div>
    </div>

    <div class="summary-card orange">
        <div class="sc-icon orange"><i class="fas fa-chart-line"></i></div>
        <div>
            <div class="sc-val"><asp:Label ID="lblPercent" runat="server" /></div>
            <div class="sc-lbl">Active %</div>
        </div>
    </div>

</div>

<!-- ===== SEARCH ===== -->
<div class="filter-bar">
    <input type="text" id="txtSearch" runat="server"
        class="form-control"
        placeholder="Search streams..."
        onkeyup="filterStreams()" />
</div>


<!-- ===== STREAM LIST ===== -->
<asp:UpdatePanel ID="upStreams" runat="server" UpdateMode="Conditional">
<ContentTemplate>

    <asp:Repeater ID="rptStreams" runat="server">
        <ItemTemplate>

            <div class="stream-card">

                <div>
                    <div class="stream-title">
                        <%# Eval("StreamName") %>
                    </div>

                    <small class="text-muted">
                        Stream ID: <%# Eval("StreamId") %>
                    </small>
                </div>

                <div>
                    <span class='<%# Convert.ToBoolean(Eval("IsActive")) ? "badge-active" : "badge-inactive" %>'>
                        <%# Convert.ToBoolean(Eval("IsActive")) ? "Active" : "Inactive" %>
                    </span>
                </div>

            </div>

        </ItemTemplate>
    </asp:Repeater>

    <!-- ===== PAGINATION ===== -->
    <div class="pager-wrap" runat="server" id="pagerDiv">

        <!-- FIRST -->
        <asp:LinkButton ID="lnkFirst"
            runat="server"
            CssClass="pager-btn"
            CommandArgument="First"
            OnClick="Pager_Click">
            <<
        </asp:LinkButton>

        <!-- PREVIOUS -->
        <asp:LinkButton ID="lnkPrev"
            runat="server"
            CssClass="pager-btn"
            CommandArgument="Prev"
            OnClick="Pager_Click">
            <
        </asp:LinkButton>

        <!-- PAGE NUMBERS -->
        <asp:Repeater ID="rptPager" runat="server">
            <ItemTemplate>

                <asp:LinkButton ID="lnkPage"
                    runat="server"
                    CssClass='<%# Convert.ToBoolean(Eval("Selected")) ? "pager-btn active" : "pager-btn" %>'
                    Text='<%# Eval("Text") %>'
                    CommandArgument='<%# Eval("Value") %>'
                    OnClick="Pager_Click">
                </asp:LinkButton>

            </ItemTemplate>
        </asp:Repeater>

        <!-- NEXT -->
        <asp:LinkButton ID="lnkNext"
            runat="server"
            CssClass="pager-btn"
            CommandArgument="Next"
            OnClick="Pager_Click">
            >
        </asp:LinkButton>

        <!-- LAST -->
        <asp:LinkButton ID="lnkLast"
            runat="server"
            CssClass="pager-btn"
            CommandArgument="Last"
            OnClick="Pager_Click">
            >>
        </asp:LinkButton>

    </div>

</ContentTemplate>
</asp:UpdatePanel>

    <asp:Panel ID="pnlEmpty" runat="server" Visible="false">
        <div class="text-center p-5 bg-white rounded shadow-sm">
            <i class="fa fa-database fa-3x text-muted mb-3"></i>

            <h5>No Streams Found</h5>

            <p>
                Try adjusting the search or switch the active/inactive toggle.
            </p>
        </div>
    </asp:Panel>

<div id="noData" class="empty-state" style="display:none;">
    No streams found
</div>

<script>
function filterStreams() {
    let input = document.getElementById("<%= txtSearch.ClientID %>").value.toLowerCase();
        let cards = document.querySelectorAll(".stream-card");

        let visible = false;

        cards.forEach(c => {
            let text = c.innerText.toLowerCase();
            let show = text.includes(input);
            c.style.display = show ? "" : "none";
            if (show) visible = true;
        });

        document.getElementById("noData").style.display = visible ? "none" : "block";
    }
</script>

</asp:Content>