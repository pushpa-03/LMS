<%@ Page Title="My Subjects" Language="C#"
    MasterPageFile="~/Student/StudentMaster.Master"
    AutoEventWireup="true"
    CodeBehind="MySubjects.aspx.cs"
    Inherits="LMS_Project.Student.MySubjects" %>

<asp:Content ID="cHead" ContentPlaceHolderID="head" runat="server">
<style>

/* ── Page header bar ── */
.page-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 24px;
    flex-wrap: wrap;
    gap: 12px;
}
.page-header h4 {
    margin: 0;
    font-weight: 800;
    color: #1565c0;
    font-size: 20px;
}
.page-header .sub {
    font-size: 13px;
    color: #90a4ae;
    margin-top: 2px;
}

/* ── Search bar ── */
.search-bar {
    display: flex;
    align-items: center;
    background: #fff;
    border: 1.5px solid #e3e8f0;
    border-radius: 10px;
    padding: 6px 14px;
    gap: 8px;
    min-width: 260px;
    box-shadow: 0 1px 4px rgba(0,0,0,.05);
    transition: border-color .2s;
}
.search-bar:focus-within {
    border-color: #1976d2;
}
.search-bar i { color: #90a4ae; }
.search-bar input {
    border: none;
    outline: none;
    font-size: 13px;
    background: transparent;
    width: 100%;
    color: #263238;
}

/* ── Summary strip ── */
.summary-strip {
    display: flex;
    gap: 12px;
    margin-bottom: 24px;
    flex-wrap: wrap;
}
.summary-chip {
    background: #fff;
    border: 1.5px solid #e3e8f0;
    border-radius: 10px;
    padding: 10px 18px;
    display: flex;
    align-items: center;
    gap: 10px;
    box-shadow: 0 1px 4px rgba(0,0,0,.05);
}
.summary-chip .chip-icon {
    width: 36px; height: 36px;
    border-radius: 9px;
    display: flex; align-items: center; justify-content: center;
    font-size: 16px;
    flex-shrink: 0;
}
.summary-chip .chip-label {
    font-size: 11px; font-weight: 700;
    text-transform: uppercase;
    letter-spacing: .5px;
    color: #90a4ae;
}
.summary-chip .chip-value {
    font-size: 20px; font-weight: 800;
    color: #263238;
    line-height: 1;
}

/* ── Subject card ── */
.subject-card {
    background: #fff;
    border-radius: 14px;
    box-shadow: 0 2px 10px rgba(0,0,0,.06);
    overflow: hidden;
    height: 100%;
    display: flex;
    flex-direction: column;
    transition: transform .2s, box-shadow .2s;
    border: 1.5px solid #e8f0fe;
}
.subject-card:hover {
    transform: translateY(-4px);
    box-shadow: 0 8px 24px rgba(21,101,192,.13);
    border-color: #90caf9;
}

/* Colored top strip — cycles through 4 colors */
.subject-card .card-stripe {
    height: 6px;
    width: 100%;
}
.stripe-blue   { background: linear-gradient(90deg, #1565c0, #42a5f5); }
.stripe-purple { background: linear-gradient(90deg, #6a1b9a, #ab47bc); }
.stripe-green  { background: linear-gradient(90deg, #2e7d32, #66bb6a); }
.stripe-orange { background: linear-gradient(90deg, #e65100, #ffa726); }

.subject-card .card-body {
    padding: 18px;
    flex: 1;
    display: flex;
    flex-direction: column;
}

.subject-card .subject-code {
    font-size: 11px; font-weight: 700;
    color: #1976d2;
    text-transform: uppercase;
    letter-spacing: .6px;
    margin-bottom: 5px;
}
.subject-card .subject-name {
    font-size: 15px; font-weight: 800;
    color: #1a237e;
    margin-bottom: 12px;
    line-height: 1.3;
}
.subject-card .subject-desc {
    font-size: 12px;
    color: #78909c;
    margin-bottom: 14px;
    flex: 1;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
}

/* Meta row */
.meta-row {
    display: flex;
    flex-direction: column;
    gap: 5px;
    margin-bottom: 14px;
    padding-bottom: 14px;
    border-bottom: 1px solid #f0f4f8;
}
.meta-item {
    font-size: 12px;
    color: #546e7a;
    display: flex;
    align-items: center;
    gap: 6px;
}
.meta-item i {
    width: 14px;
    color: #1976d2;
    font-size: 11px;
}

/* Content stats row */
.content-stats {
    display: flex;
    gap: 8px;
    margin-bottom: 14px;
}
.content-stat {
    flex: 1;
    background: #f5f9ff;
    border-radius: 8px;
    padding: 6px 8px;
    text-align: center;
}
.content-stat .cs-val {
    font-size: 16px; font-weight: 800;
    color: #1565c0;
    display: block;
}
.content-stat .cs-lbl {
    font-size: 10px; color: #90a4ae;
    text-transform: uppercase;
    letter-spacing: .4px;
}

/* Action button */
.btn-study {
    display: block;
    width: 100%;
    padding: 9px;
    background: linear-gradient(135deg, #1565c0, #1976d2);
    color: #fff;
    border: none;
    border-radius: 9px;
    font-size: 13px;
    font-weight: 700;
    text-align: center;
    text-decoration: none;
    transition: opacity .2s, transform .15s;
    cursor: pointer;
}
.btn-study:hover {
    opacity: .9;
    color: #fff;
    transform: translateY(-1px);
}
.btn-study i { margin-right: 6px; }

/* ── Empty state ── */
.empty-state {
    text-align: center;
    padding: 60px 20px;
    color: #90a4ae;
}
.empty-state .empty-icon {
    font-size: 56px;
    margin-bottom: 16px;
    display: block;
    color: #cfd8dc;
}
.empty-state h5 { color: #546e7a; font-weight: 700; }
.empty-state p  { font-size: 13px; margin: 0; }

/* ── Session badge ── */
.session-badge {
    background: #e3f2fd;
    color: #1565c0;
    font-size: 12px;
    font-weight: 700;
    padding: 4px 14px;
    border-radius: 20px;
    border: 1.5px solid #90caf9;
}

</style>
</asp:Content>

<asp:Content ID="cBody" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<%-- ══ PAGE HEADER ══ --%>
<div class="page-header">
    <div>
        <h4><i class="fas fa-book-open me-2"></i>My Subjects</h4>
        <div class="sub">
            All subjects enrolled for
            <asp:Label ID="lblSessionName" runat="server" CssClass="session-badge ms-1" />
        </div>
    </div>

    <%-- Search --%>
    <div class="search-bar">
        <i class="fas fa-search"></i>
        <asp:TextBox ID="txtSearch" runat="server"
            placeholder="Search by subject name or code..."
            AutoPostBack="true"
            OnTextChanged="txtSearch_TextChanged" />
        <asp:LinkButton ID="btnClear" runat="server"
            OnClick="btnClear_Click"
            CssClass="text-muted"
            style="font-size:12px; text-decoration:none;">
            <i class="fas fa-times"></i>
        </asp:LinkButton>
    </div>
</div>

<%-- ══ SUMMARY STRIP ══ --%>
<div class="summary-strip">

    <div class="summary-chip">
        <div class="chip-icon" style="background:#e3f2fd; color:#1976d2;">
            <i class="fas fa-book-open"></i>
        </div>
        <div>
            <div class="chip-label">Total Subjects</div>
            <div class="chip-value">
                <asp:Label ID="lblTotalSubjects" runat="server" Text="0" />
            </div>
        </div>
    </div>

    <div class="summary-chip">
        <div class="chip-icon" style="background:#f3e5f5; color:#7b1fa2;">
            <i class="fas fa-list-ul"></i>
        </div>
        <div>
            <div class="chip-label">Total Chapters</div>
            <div class="chip-value">
                <asp:Label ID="lblTotalChapters" runat="server" Text="0" />
            </div>
        </div>
    </div>

    <div class="summary-chip">
        <div class="chip-icon" style="background:#fff3e0; color:#e65100;">
            <i class="fas fa-play-circle"></i>
        </div>
        <div>
            <div class="chip-label">Total Videos</div>
            <div class="chip-value">
                <asp:Label ID="lblTotalVideos" runat="server" Text="0" />
            </div>
        </div>
    </div>

    <div class="summary-chip">
        <div class="chip-icon" style="background:#e8f5e9; color:#2e7d32;">
            <i class="fas fa-file-alt"></i>
        </div>
        <div>
            <div class="chip-label">Total Materials</div>
            <div class="chip-value">
                <asp:Label ID="lblTotalMaterials" runat="server" Text="0" />
            </div>
        </div>
    </div>

</div>

<%-- ══ SUBJECT CARDS GRID ══ --%>
<asp:Panel ID="pnlSubjects" runat="server">
    <div class="row g-4">
        <asp:Repeater ID="rptSubjects" runat="server">
            <ItemTemplate>
                <div class="col-md-6 col-lg-4">
                    <div class="subject-card">

                        <%-- Colored stripe — cycles by ItemIndex mod 4 --%>
                        <div class='card-stripe <%# GetStripeClass(Container.ItemIndex) %>'></div>

                        <div class="card-body">

                            <div class="subject-code"><%# Eval("SubjectCode") %></div>
                            <div class="subject-name"><%# Eval("SubjectName") %></div>
                            <div class="subject-desc">
                                <%# string.IsNullOrEmpty(Eval("Description")?.ToString())
                                    ? "No description available."
                                    : Eval("Description") %>
                            </div>

                            <%-- Meta --%>
                            <div class="meta-row">
                                <div class="meta-item">
                                    <i class="fas fa-layer-group"></i>
                                    <%# Eval("StreamName") %> &nbsp;|&nbsp; <%# Eval("CourseName") %>
                                </div>
                                <div class="meta-item">
                                    <i class="fas fa-graduation-cap"></i>
                                    <%# Eval("LevelName") %> &nbsp;—&nbsp; <%# Eval("SemesterName") %>
                                </div>
                                <div class="meta-item">
                                    <i class="fas fa-user-tie"></i>
                                    <%# Eval("TeacherName") %>
                                </div>
                                <div class="meta-item">
                                    <i class="fas fa-clock"></i>
                                    <%# Eval("Duration") %>
                                </div>
                            </div>

                            <%-- Content stats --%>
                            <div class="content-stats">
                                <div class="content-stat">
                                    <span class="cs-val"><%# Eval("ChapterCount") %></span>
                                    <span class="cs-lbl">Chapters</span>
                                </div>
                                <div class="content-stat">
                                    <span class="cs-val"><%# Eval("VideoCount") %></span>
                                    <span class="cs-lbl">Videos</span>
                                </div>
                                <div class="content-stat">
                                    <span class="cs-val"><%# Eval("MaterialCount") %></span>
                                    <span class="cs-lbl">Materials</span>
                                </div>
                            </div>

                            <%-- Study button --%>
                            <a href='StudyMaterial.aspx?SubjectId=<%# Eval("SubjectId") %>'
                               class="btn-study">
                                <i class="fas fa-play-circle"></i>Start Studying
                            </a>

                        </div>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>
</asp:Panel>

<%-- ══ EMPTY STATE ══ --%>
<asp:Panel ID="pnlEmpty" runat="server" Visible="false">
    <div class="empty-state">
        <i class="fas fa-book empty-icon"></i>
        <h5>No subjects found</h5>
        <p id="emptyMsg" runat="server">You are not enrolled in any subjects yet.<br/>
            Please contact your administrator.</p>
    </div>
</asp:Panel>

</asp:Content>
