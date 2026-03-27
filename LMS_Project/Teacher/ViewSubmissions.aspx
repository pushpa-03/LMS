<%@ Page Language="C#" AutoEventWireup="true"
    MasterPageFile="~/Teacher/TeacherMaster.master"
    CodeBehind="ViewSubmissions.aspx.cs"
    Inherits="LearningManagementSystem.Teacher.ViewSubmissions" %>

<asp:Content ContentPlaceHolderID="head" runat="server">
<style>

/* ── Page Banner ── */
.page-banner {
    background: linear-gradient(135deg, #2e7d32 0%, #388e3c 60%, #66bb6a 100%);
    border-radius: 16px;
    padding: 24px 32px;
    color: #fff;
    margin-bottom: 24px;
    position: relative;
    overflow: hidden;
}
.page-banner::after {
    content: "\f15c";
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

/* ── Summary strip ── */
.summary-strip {
    background: #fff;
    border-radius: 14px;
    box-shadow: 0 2px 8px rgba(0,0,0,.06);
    padding: 14px 24px;
    display: flex;
    align-items: center;
    gap: 10px;
    margin-bottom: 20px;
    font-size: 14px;
    color: #455a64;
}
.summary-strip i      { color: #2e7d32; font-size: 18px; }
.summary-strip strong { color: #2e7d32; }

/* ── Panel card ── */
.panel-card {
    background: #fff;
    border-radius: 14px;
    box-shadow: 0 2px 8px rgba(0,0,0,.06);
    padding: 20px;
    margin-bottom: 24px;
    overflow-x: auto;
}

/* ── Table ── */
.submissions-table {
    width: 100%;
    border-collapse: collapse;
}
.submissions-table thead tr {
    background: #e8f5e9;
}
.submissions-table thead th {
    padding: 12px 16px;
    font-size: 11px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: .6px;
    color: #2e7d32;
    border: none;
    white-space: nowrap;
}
.submissions-table tbody tr {
    border-bottom: 1px solid #f0f7f2;
    transition: background .15s;
}
.submissions-table tbody tr:last-child { border-bottom: none; }
.submissions-table tbody tr:hover { background: #f9fbe7; }
.submissions-table td {
    padding: 13px 16px;
    font-size: 13px;
    color: #455a64;
    vertical-align: middle;
    border: none;
}

/* Edit row highlight */
.submissions-table tr.edit-row { background: #f1f8e9 !important; }

/* ── Student name ── */
.s-name {
    font-weight: 700;
    color: #263238;
    font-size: 13px;
}

/* ── Pills ── */
.pill {
    display: inline-block;
    padding: 3px 12px;
    border-radius: 20px;
    font-size: 11px;
    font-weight: 700;
}
.pill-green  { background: #e8f5e9; color: #2e7d32; }
.pill-orange { background: #fff3e0; color: #e65100; }
.pill-grey   { background: #f5f5f5; color: #78909c; }

/* ── Form controls in edit mode ── */
.edit-input {
    border: 1.5px solid #a5d6a7;
    border-radius: 8px;
    padding: 6px 10px;
    font-size: 13px;
    color: #455a64;
    background: #fff;
    outline: none;
    width: 100%;
    min-width: 80px;
    box-sizing: border-box;
}
.edit-input:focus { border-color: #2e7d32; }

/* ── Action buttons ── */
.btn-action {
    display: inline-flex; align-items: center; gap: 5px;
    padding: 5px 14px;
    border-radius: 20px;
    font-size: 12px; font-weight: 600;
    text-decoration: none;
    transition: background .2s, color .2s;
    border: none; cursor: pointer;
    white-space: nowrap;
}
.btn-edit     { background: #e8f5e9; color: #2e7d32; }
.btn-edit:hover   { background: #2e7d32; color: #fff; }
.btn-save     { background: #e0f2f1; color: #00796b; }
.btn-save:hover   { background: #00796b; color: #fff; }
.btn-cancel   { background: #fce4ec; color: #c62828; }
.btn-cancel:hover { background: #c62828; color: #fff; }
.btn-download { background: #e3f2fd; color: #1565c0; }
.btn-download:hover { background: #1565c0; color: #fff; text-decoration: none; }

/* ── Marks display ── */
.marks-badge {
    display: inline-block;
    background: transparent;
    color: #263238;
    font-weight: 700;
    font-size: 14px;
    min-width: 40px;
    text-align: center;
}
.marks-badge.not-graded {
    background: transparent;
    color: #90a4ae;
    font-weight: 400;
}

/* ── Empty state ── */
.empty-state {
    text-align: center;
    padding: 50px 20px;
    color: #90a4ae;
}
.empty-state i  { font-size: 48px; margin-bottom: 12px; display: block; color: #c8e6c9; }
.empty-state h6 { font-weight: 700; color: #78909c; margin-bottom: 4px; }
.empty-state p  { font-size: 13px; margin: 0; }

/* ── Back button ── */
.btn-back {
    display: inline-flex; align-items: center; gap: 6px;
    padding: 7px 18px;
    border-radius: 20px;
    background: rgba(255,255,255,.2);
    color: #fff;
    font-size: 13px; font-weight: 600;
    text-decoration: none;
    transition: background .2s;
    border: none;
}
.btn-back:hover { background: rgba(255,255,255,.35); color: #fff; text-decoration: none; }

</style>
</asp:Content>

<asp:Content ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

<%-- ══ PAGE BANNER ══ --%>
<div class="page-banner">
    <div class="d-flex align-items-start justify-content-between flex-wrap gap-2">
        <div>
            <h4><i class="fas fa-paper-plane me-2"></i>Student Submissions</h4>
            <p>Review, grade and give feedback on student assignment submissions.</p>
        </div>
        <a href="TeacherAssignment.aspx" class="btn-back">
            <i class="fas fa-arrow-left"></i> Back to Assignments
        </a>
    </div>
</div>

<%-- ══ SUMMARY STRIP ══ --%>
<div class="summary-strip">
    <i class="fas fa-users"></i>
    <span>
        <strong>
            <asp:Label ID="lblSubmissionCount" runat="server" Text="0" />
        </strong>
        submission(s) received for this assignment.
    </span>
</div>

<%-- ══ SUBMISSIONS TABLE ══ --%>
<div class="panel-card">

    <asp:GridView ID="gvSubmissions" runat="server"
        CssClass="submissions-table"
        AutoGenerateColumns="false"
        DataKeyNames="SubmissionId"
        GridLines="None"
        OnRowEditing="gvSubmissions_RowEditing"
        OnRowCancelingEdit="gvSubmissions_RowCancelingEdit"
        OnRowUpdating="gvSubmissions_RowUpdating"
        EmptyDataText="">

        <RowStyle CssClass="" />
        <EditRowStyle CssClass="edit-row" />

        <Columns>

            <%-- # --%>
            <asp:TemplateField HeaderText="#">
                <ItemTemplate>
                    <span style="color:#b0bec5; font-size:12px;">
                        <%# Container.DataItemIndex + 1 %>
                    </span>
                </ItemTemplate>
            </asp:TemplateField>

            <%-- Student Name --%>
            <asp:TemplateField HeaderText="Student">
                <ItemTemplate>
                    <span class="s-name"><%# Eval("FullName") %></span>
                </ItemTemplate>
                <EditItemTemplate>
                    <span class="s-name"><%# Eval("FullName") %></span>
                </EditItemTemplate>
            </asp:TemplateField>

            <%-- Submitted On --%>
            <asp:TemplateField HeaderText="Submitted On">
                <ItemTemplate>
                    <span style="font-size:13px; color:#455a64;">
                        <i class="far fa-clock me-1" style="color:#81c784;"></i>
                        <%# Eval("SubmittedOn", "{0:dd MMM yyyy, hh:mm tt}") %>
                    </span>
                </ItemTemplate>
                <EditItemTemplate>
                    <span style="font-size:13px; color:#455a64;">
                        <i class="far fa-clock me-1" style="color:#81c784;"></i>
                        <%# Eval("SubmittedOn", "{0:dd MMM yyyy, hh:mm tt}") %>
                    </span>
                </EditItemTemplate>
            </asp:TemplateField>

            <%-- Marks --%>
            <asp:TemplateField HeaderText="Marks">
                <ItemTemplate>
                    <%# Eval("MarksObtained") != DBNull.Value && Eval("MarksObtained") != null
                        ? "<span class='marks-badge'>" + Eval("MarksObtained") + "</span>"
                        : "<span class='marks-badge not-graded'>—</span>" %>
                </ItemTemplate>
                <EditItemTemplate>
                    <asp:TextBox ID="txtMarks" runat="server"
                        Text='<%# Bind("MarksObtained") %>'
                        CssClass="edit-input"
                        placeholder="Marks"
                        Style="width:80px;" />
                </EditItemTemplate>
            </asp:TemplateField>

            <%-- Feedback --%>
            <asp:TemplateField HeaderText="Feedback">
                <ItemTemplate>
                    <span style="font-size:12px; color:#607d8b;">
                        <%# string.IsNullOrEmpty(Eval("Feedback")?.ToString())
                            ? "<span style='color:#cfd8dc;'>No feedback yet</span>"
                            : Eval("Feedback").ToString() %>
                    </span>
                </ItemTemplate>
                <EditItemTemplate>
                    <asp:TextBox ID="txtFeedback" runat="server"
                        Text='<%# Bind("Feedback") %>'
                        CssClass="edit-input"
                        placeholder="Write feedback..."
                        Style="width:180px;" />
                </EditItemTemplate>
            </asp:TemplateField>

            <%-- File --%>
            <asp:TemplateField HeaderText="File">
                <ItemTemplate>
                    <asp:HyperLink runat="server"
                        NavigateUrl='<%# Eval("FilePath") %>'
                        CssClass="btn-action btn-download"
                        Target="_blank"
                        Visible='<%# Eval("FilePath") != DBNull.Value && Eval("FilePath").ToString() != "" %>'>
                        <i class="fas fa-download"></i> Download
                    </asp:HyperLink>
                    <asp:Label runat="server"
                        Text="<span style='color:#cfd8dc; font-size:12px;'>No file</span>"
                        Visible='<%# Eval("FilePath") == DBNull.Value || Eval("FilePath").ToString() == "" %>' />
                </ItemTemplate>
                <EditItemTemplate>
                    <asp:HyperLink runat="server"
                        NavigateUrl='<%# Eval("FilePath") %>'
                        CssClass="btn-action btn-download"
                        Target="_blank"
                        Visible='<%# Eval("FilePath") != DBNull.Value && Eval("FilePath").ToString() != "" %>'>
                        <i class="fas fa-download"></i> Download
                    </asp:HyperLink>
                </EditItemTemplate>
            </asp:TemplateField>

            <%-- Edit / Save / Cancel --%>
            <asp:TemplateField HeaderText="Action">
                <ItemTemplate>
                    <asp:LinkButton runat="server"
                        CommandName="Edit"
                        CssClass="btn-action btn-edit">
                        <i class="fas fa-pen"></i> Grade
                    </asp:LinkButton>
                </ItemTemplate>
                <EditItemTemplate>
                    <asp:LinkButton runat="server"
                        CommandName="Update"
                        CssClass="btn-action btn-save me-1">
                        <i class="fas fa-check"></i> Save
                    </asp:LinkButton>
                    <asp:LinkButton runat="server"
                        CommandName="Cancel"
                        CssClass="btn-action btn-cancel">
                        <i class="fas fa-times"></i> Cancel
                    </asp:LinkButton>
                </EditItemTemplate>
            </asp:TemplateField>

        </Columns>

    </asp:GridView>

    <%-- Empty state --%>
    <asp:Panel ID="pnlEmpty" runat="server" Visible="false">
        <div class="empty-state">
            <i class="fas fa-inbox"></i>
            <h6>No Submissions Yet</h6>
            <p>No students have submitted this assignment yet.</p>
        </div>
    </asp:Panel>

</div>

</asp:Content>