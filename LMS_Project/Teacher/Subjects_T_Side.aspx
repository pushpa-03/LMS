<%@ Page Title="My Subjects" Language="C#" MasterPageFile="~/Teacher/TeacherMaster.master" AutoEventWireup="true" CodeBehind="Subjects_T_Side.aspx.cs" Inherits="LMS_Project.Teacher.Subjects" %>

<asp:Content ID="headContent" ContentPlaceHolderID="head" runat="server">
<style>

/* ── Page Banner ── */
.page-banner {
    background: linear-gradient(135deg, #1565c0 0%, #1976d2 60%, #42a5f5 100%);
    border-radius: 16px;
    padding: 24px 32px;
    color: #fff;
    margin-bottom: 24px;
    position: relative;
    overflow: hidden;
}
.page-banner::after {
    content: "\f02d";
    font-family: "Font Awesome 6 Free";
    font-weight: 900;
    position: absolute;
    right: 32px;
    top: 50%;
    transform: translateY(-50%);
    font-size: 80px;
    opacity: .12;
    color: #fff;
}
.page-banner h4 { margin: 0 0 4px; font-weight: 800; font-size: 20px; }
.page-banner p  { margin: 0; opacity: .85; font-size: 13px; }
.page-banner .meta-info {
    font-size: 12px;
    opacity: .75;
    margin-top: 6px;
}
.banner-toggle {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    background: rgba(255,255,255,.2);
    border-radius: 20px;
    padding: 6px 16px;
    font-size: 13px;
    font-weight: 600;
    color: #fff;
    cursor: pointer;
    border: none;
    margin-top: 10px;
}
.banner-toggle:hover { background: rgba(255,255,255,.3); }

/* ── Summary cards ── */
.summary-card {
    background: #fff;
    border-radius: 14px;
    padding: 14px 16px;
    display: flex;
    align-items: center;
    gap: 12px;
    box-shadow: 0 2px 8px rgba(0,0,0,.06);
    border-left: 4px solid transparent;
    transition: all .2s ease;
    height: 100%;
}
.summary-card:hover { transform: translateY(-4px); box-shadow: 0 8px 20px rgba(0,0,0,.1); }
.summary-card.blue   { border-left-color: #1565c0; }
.summary-card.green  { border-left-color: #2e7d32; }
.summary-card.red    { border-left-color: #c62828; }
.summary-card.pink   { border-left-color: #9c4d9b; }
.summary-card.yellow { border-left-color: #f59e0b; }
.summary-card.orange { border-left-color: #f97316; }

.sc-icon {
    width: 44px; height: 44px;
    border-radius: 12px;
    display: flex; align-items: center; justify-content: center;
    font-size: 17px;
    flex-shrink: 0;
}
.sc-icon.blue   { background: #e3f2fd; color: #1565c0; }
.sc-icon.green  { background: #e8f5e9; color: #2e7d32; }
.sc-icon.red    { background: #ffebee; color: #c62828; }
.sc-icon.pink   { background: #fce4ec; color: #9c4d9b; }
.sc-icon.yellow { background: #fff8e1; color: #f59e0b; }
.sc-icon.orange { background: #fff3e0; color: #f97316; }

.sc-val { font-size: 22px; font-weight: 800; color: #263238; line-height: 1; }
.sc-lbl { font-size: 11px; font-weight: 700; color: #90a4ae; text-transform: uppercase; letter-spacing: .5px; margin-top: 2px; }

/* ── Subject cards ── */
.subject-card {
    background: #fff;
    border-radius: 14px;
    box-shadow: 0 2px 8px rgba(0,0,0,.06);
    padding: 22px;
    border-left: 4px solid #1976d2;
    transition: transform .2s, box-shadow .2s;
    height: 100%;
    display: flex;
    flex-direction: column;
}
.subject-card:hover {
    transform: translateY(-4px);
    box-shadow: 0 8px 20px rgba(0,0,0,.1);
}
.subject-card .s-title {
    font-size: 15px;
    font-weight: 700;
    color: #263238;
    margin-bottom: 4px;
}
.subject-card .s-code {
    display: inline-block;
    background: #e3f2fd;
    color: #1565c0;
    border-radius: 8px;
    padding: 2px 10px;
    font-size: 11px;
    font-weight: 700;
    margin-bottom: 12px;
}
.subject-card .s-meta {
    font-size: 12px;
    color: #78909c;
    margin-bottom: 5px;
    display: flex;
    align-items: center;
    gap: 6px;
}
.subject-card .s-meta i { color: #1976d2; width: 14px; }

/* ── Stat mini boxes inside card ── */
.card-stat-box {
    background: #f0f7ff;
    border-radius: 8px;
    padding: 8px 12px;
    text-align: center;
    flex: 1;
}
.card-stat-box .csb-val { font-size: 16px; font-weight: 800; color: #1565c0; }
.card-stat-box .csb-lbl { font-size: 10px; font-weight: 700; color: #90a4ae; text-transform: uppercase; letter-spacing: .3px; }

/* ── Badges ── */
.badge-mandatory { background: #e8f5e9; color: #2e7d32; border: 1px solid #c8e6c9; padding: 3px 12px; border-radius: 20px; font-size: 11px; font-weight: 700; }
.badge-elective  { background: #fff8e1; color: #f59e0b; border: 1px solid #fde68a; padding: 3px 12px; border-radius: 20px; font-size: 11px; font-weight: 700; }

/* ── Action button ── */
.btn-manage {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 6px;
    width: 100%;
    padding: 9px 0;
    background: linear-gradient(135deg, #1565c0, #1976d2);
    color: #fff;
    border-radius: 10px;
    font-size: 13px;
    font-weight: 600;
    text-decoration: none;
    transition: opacity .2s, transform .2s;
    margin-top: auto;
}
.btn-manage:hover { opacity: .9; transform: translateY(-2px); color: #fff; text-decoration: none; }

/* ── Empty state ── */
.empty-state {
    text-align: center;
    padding: 50px 20px;
    color: #90a4ae;
    background: #fff;
    border-radius: 14px;
    box-shadow: 0 2px 8px rgba(0,0,0,.06);
}
.empty-state i { font-size: 48px; margin-bottom: 12px; display: block; color: #90caf9; }
.empty-state h6 { font-weight: 700; color: #78909c; }
.empty-state p { font-size: 13px; margin: 0; }

/* ── Panel card ── */
.panel-card {
    background: #fff;
    border-radius: 14px;
    box-shadow: 0 2px 8px rgba(0,0,0,.06);
    padding: 20px;
}

</style>
</asp:Content>

<asp:Content ID="bodyContent" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

<%-- ══ PAGE BANNER ══ --%>
<div class="page-banner">
    <div class="d-flex align-items-start justify-content-between flex-wrap gap-3">
        <div>
            <h4><i class="fas fa-book-open me-2"></i>My Subjects</h4>
            <p>Subjects assigned to you for the current session.</p>
            <div class="meta-info">
                <i class="fas fa-clock me-1"></i>
                Last updated: <%= DateTime.Now.ToString("dd MMM yyyy hh:mm tt") %>
            </div>
        </div>
        <div style="display:flex;align-items:center;gap:10px;flex-wrap:wrap;">
            <div style="display:inline-flex;align-items:center;gap:8px;background:rgba(255,255,255,.2);border-radius:20px;padding:6px 16px;">
                <asp:CheckBox ID="chkStatus" runat="server" AutoPostBack="true"
                    OnCheckedChanged="chkStatus_CheckedChanged"
                    CssClass="form-check-input mt-0" role="switch" />
                <label style="font-size:13px;font-weight:600;color:#fff;margin:0;" for="<%= chkStatus.ClientID %>">
                    <%= chkStatus.Checked ? "Viewing Inactive" : "Viewing Active" %>
                </label>
            </div>
        </div>
    </div>
</div>

<%-- ══ STATS ══ --%>
<div class="row g-3 mb-4">
    <asp:Repeater ID="rptStats" runat="server" Visible="false">
        <ItemTemplate>
            <div class="col-6 col-md-2">
                <div class="summary-card blue">
                    <div class="sc-icon blue"><i class="fas fa-book"></i></div>
                    <div>
                        <div class="sc-val"><%# Eval("TotalSubjects") %></div>
                        <div class="sc-lbl">Total</div>
                    </div>
                </div>
            </div>
            <div class="col-6 col-md-2">
                <div class="summary-card yellow">
                    <div class="sc-icon yellow"><i class="fas fa-star"></i></div>
                    <div>
                        <div class="sc-val"><%# Eval("MandatoryCount") %></div>
                        <div class="sc-lbl">Mandatory</div>
                    </div>
                </div>
            </div>
            <div class="col-6 col-md-2">
                <div class="summary-card pink">
                    <div class="sc-icon pink"><i class="fas fa-users"></i></div>
                    <div>
                        <div class="sc-val"><%# Eval("TotalEnrollments") %></div>
                        <div class="sc-lbl">Enrollments</div>
                    </div>
                </div>
            </div>
            <div class="col-6 col-md-2">
                <div class="summary-card orange">
                    <div class="sc-icon orange"><i class="fas fa-chart-line"></i></div>
                    <div>
                        <div class="sc-val"><%# Eval("AvgPerSubject") %></div>
                        <div class="sc-lbl">Average</div>
                    </div>
                </div>
            </div>
            <div class="col-6 col-md-2">
                <div class="summary-card green">
                    <div class="sc-icon green"><i class="fas fa-check-circle"></i></div>
                    <div>
                        <div class="sc-val"><%# Eval("ActiveCount") %></div>
                        <div class="sc-lbl">Active</div>
                    </div>
                </div>
            </div>
            <div class="col-6 col-md-2">
                <div class="summary-card red">
                    <div class="sc-icon red"><i class="fas fa-times-circle"></i></div>
                    <div>
                        <div class="sc-val"><%# Eval("InactiveCount") %></div>
                        <div class="sc-lbl">Inactive</div>
                    </div>
                </div>
            </div>
        </ItemTemplate>
    </asp:Repeater>
</div>

<asp:Label ID="lblMsg" runat="server" CssClass="alert alert-info d-block mb-4" Visible="false" />

<%-- ══ SUBJECT CARDS ══ --%>
<div class="row g-4">
    <asp:Repeater ID="rptSubjects" runat="server">
        <ItemTemplate>
            <div class="col-xl-4 col-md-6">
                <div class="subject-card">

                    <%-- Title + Badge --%>
                    <div class="d-flex justify-content-between align-items-start mb-2">
                        <div style="flex:1;min-width:0;margin-right:10px;">
                            <div class="s-title"><%# Eval("SubjectName") %></div>
                            <span class="s-code">Code: <%# Eval("SubjectCode") %></span>
                        </div>
                        <%# (Eval("IsMandatory") != DBNull.Value && Convert.ToBoolean(Eval("IsMandatory")))
                            ? "<span class='badge-mandatory'>MANDATORY</span>"
                            : "<span class='badge-elective'>ELECTIVE</span>" %>
                    </div>

                    <%-- Meta info --%>
                    <div class="s-meta">
                        <i class="fas fa-layer-group"></i>
                        <span><%# Eval("StreamName") ?? "—" %></span>
                    </div>
                    <div class="s-meta">
                        <i class="fas fa-graduation-cap"></i>
                        <span><%# Eval("CourseName") ?? "—" %></span>
                    </div>
                    <div class="s-meta">
                        <i class="fas fa-calendar-alt"></i>
                        <span>Sem: <%# Eval("SemesterName") ?? "—" %></span>
                    </div>

                    <%-- Stat mini boxes --%>
                    <div class="d-flex gap-2 my-3">
                        <div class="card-stat-box">
                            <div class="csb-val"><%# Eval("StudentCount") %></div>
                            <div class="csb-lbl">Students</div>
                        </div>
                    </div>

                    <%-- Action button --%>
                    <a href='SubjectDetails_T_Side.aspx?SubjectId=<%# Eval("SubjectId") %>'
                       class="btn-manage">
                        <i class="fas fa-cog"></i> Manage Content
                    </a>

                </div>
            </div>
        </ItemTemplate>
    </asp:Repeater>
</div>

<%-- ══ EMPTY STATE ══ --%>
<asp:PlaceHolder ID="phEmpty" runat="server" Visible="false">
    <div class="empty-state mt-3">
        <i class="fas fa-book-open"></i>
        <h6>No Subjects Found</h6>
        <p>Use the toggle in the banner to view inactive subjects.</p>
    </div>
</asp:PlaceHolder>

</asp:Content>