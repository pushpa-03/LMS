<%@ Page Language="C#" AutoEventWireup="true"
    MasterPageFile="~/Teacher/TeacherMaster.master"
    CodeBehind="TeacherAssignment.aspx.cs"
    Inherits="LearningManagementSystem.Teacher.TeacherAssignment" %>

<asp:Content ContentPlaceHolderID="head" runat="server">
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

/* ── Panel card ── */
.panel-card {
    background: #fff;
    border-radius: 14px;
    box-shadow: 0 2px 8px rgba(0,0,0,.06);
    padding: 24px;
    margin-bottom: 24px;
}
.panel-card .section-title {
    font-size: 15px;
    font-weight: 700;
    color: #1565c0;
    margin-bottom: 20px;
    display: flex;
    align-items: center;
    gap: 8px;
    padding-bottom: 12px;
    border-bottom: 2px solid #e3f2fd;
}

/* ── Form fields ── */
.form-label-custom {
    font-size: 12px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: .5px;
    color: #546e7a;
    margin-bottom: 6px;
    display: block;
}
.form-control-custom {
    width: 100%;
    border: 1.5px solid #bbdefb;
    border-radius: 10px;
    padding: 10px 14px;
    font-size: 13px;
    color: #455a64;
    background: #e3f2fd;
    outline: none;
    transition: border .2s, background .2s;
    box-sizing: border-box;
}
.form-control-custom:focus {
    border-color: #42a5f5;
    background: #fff;
}
select.form-control-custom {
    appearance: none;
    background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 12 12'%3E%3Cpath fill='%2364b5f6' d='M6 8L1 3h10z'/%3E%3C/svg%3E");
    background-repeat: no-repeat;
    background-position: right 14px center;
    padding-right: 36px;
}
textarea.form-control-custom { resize: vertical; min-height: 100px; }

/* File upload */
.file-upload-wrap {
    border: 2px dashed #90caf9;
    border-radius: 10px;
    padding: 16px;
    text-align: center;
    background: #e3f2fd;
    color: #78909c;
    font-size: 13px;
    cursor: pointer;
    transition: border .2s;
}
.file-upload-wrap:hover { border-color: #1565c0; }
.file-upload-wrap i { font-size: 24px; color: #64b5f6; display: block; margin-bottom: 6px; }
.file-upload-wrap input[type=file] { display: none; }

/* Submit button */
.btn-submit {
    background: linear-gradient(135deg, #1565c0, #42a5f5);
    color: #fff;
    border: none;
    border-radius: 10px;
    padding: 11px 28px;
    font-size: 14px;
    font-weight: 600;
    cursor: pointer;
    transition: opacity .2s, transform .2s;
    display: inline-flex;
    align-items: center;
    gap: 8px;
}
.btn-submit:hover { opacity: .9; transform: translateY(-2px); }

/* ── Alert ── */
.alert-success-custom {
    background: #e3f2fd;
    border-left: 4px solid #1565c0;
    border-radius: 10px;
    padding: 12px 18px;
    font-size: 13px;
    color: #1565c0;
    font-weight: 600;
    margin-bottom: 20px;
    display: flex;
    align-items: center;
    gap: 10px;
}

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
.summary-strip i      { color: #1976d2; font-size: 18px; }
.summary-strip strong { color: #1565c0; }

/* ── Assignment cards ── */
.assignment-card {
    background: #fff;
    border-radius: 14px;
    box-shadow: 0 2px 10px rgba(0,0,0,.06);
    padding: 20px;
    border-left: 4px solid #1976d2;
    transition: transform .2s, box-shadow .2s;
    display: flex;
    flex-direction: column;
    height: 100%;
}
.assignment-card:hover {
    transform: translateY(-3px);
    box-shadow: 0 8px 20px rgba(0,0,0,.1);
}
.assignment-card .card-icon {
    width: 42px; height: 42px;
    border-radius: 12px;
    background: #e3f2fd;
    display: flex; align-items: center; justify-content: center;
    font-size: 17px; color: #1565c0;
    margin-bottom: 12px;
}
.assignment-card .a-title {
    font-size: 15px; font-weight: 700;
    color: #263238; margin-bottom: 6px;
    line-height: 1.3;
}
.assignment-card .a-subject {
    font-size: 12px; color: #1976d2;
    font-weight: 600; margin-bottom: 12px;
}
.assignment-card .meta-row {
    display: flex; align-items: center;
    gap: 8px; font-size: 12px;
    color: #78909c; margin-bottom: 7px;
}
.assignment-card .meta-row i { width: 14px; color: #1976d2; }
.assignment-card .desc-text {
    font-size: 12px; color: #607d8b;
    line-height: 1.5; margin-bottom: 14px;
}
.assignment-card .card-footer-row {
    margin-top: auto;
    padding-top: 14px;
    border-top: 1px solid #e3f2fd;
    display: flex; align-items: center;
    gap: 8px; flex-wrap: wrap;
}

/* Pills */
.pill {
    display: inline-block;
    padding: 3px 12px;
    border-radius: 20px;
    font-size: 11px;
    font-weight: 700;
}
.pill-green  { background: #e3f2fd; color: #1565c0; }
.pill-orange { background: #fff3e0; color: #e65100; }
.pill-red    { background: #ffebee; color: #c62828; }

/* Action buttons */
.btn-action {
    display: inline-flex; align-items: center; gap: 5px;
    padding: 5px 14px;
    border-radius: 20px;
    font-size: 12px; font-weight: 600;
    text-decoration: none;
    transition: background .2s, color .2s;
    border: none; cursor: pointer;
}
.btn-download       { background: #e3f2fd; color: #1565c0; }
.btn-download:hover { background: #1565c0; color: #fff; text-decoration: none; }
.btn-view           { background: #e0f2f1; color: #00796b; }
.btn-view:hover     { background: #00796b; color: #fff; text-decoration: none; }

/* ── Empty state ── */
.empty-state {
    text-align: center; padding: 50px 20px;
    color: #90a4ae;
}
.empty-state i { font-size: 48px; margin-bottom: 12px; display: block; color: #90caf9; }
.empty-state h6 { font-weight: 700; color: #78909c; margin-bottom: 4px; }
.empty-state p  { font-size: 13px; margin: 0; }

</style>
</asp:Content>

<asp:Content ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

<%-- ══ PAGE BANNER ══ --%>
<div class="page-banner">
    <h4><i class="fas fa-upload me-2"></i>Assignments</h4>
    <p>Create new assignments and manage existing ones for your subjects.</p>
</div>

<%-- ══ SUCCESS MESSAGE ══ --%>
<asp:Panel ID="pnlSuccess" runat="server" Visible="false">
    <div class="alert-success-custom">
        <i class="fas fa-check-circle"></i>
        <asp:Label ID="lblSuccessMessage" runat="server" />
    </div>
</asp:Panel>

<%-- ══ CREATE ASSIGNMENT FORM ══ --%>
<div class="panel-card">
    <div class="section-title">
        <i class="fas fa-plus-circle"></i> Create New Assignment
    </div>

    <div class="row g-3">

        <div class="col-md-6">
            <label class="form-label-custom">Subject</label>
            <asp:DropDownList 
                ID="ddlSubject" 
                runat="server" 
                CssClass="form-control-custom"
                AutoPostBack="true"
                OnSelectedIndexChanged="ddlSubject_SelectedIndexChanged" />
        </div>

        <div class="col-md-6">
            <label class="form-label-custom">Chapter (Optional)</label>
            <asp:DropDownList 
                ID="ddlChapter" 
                runat="server" 
                CssClass="form-control-custom" />
        </div>

        <div class="col-md-6">
            <label class="form-label-custom">Title</label>
            <asp:TextBox ID="txtTitle" runat="server" CssClass="form-control-custom"
                placeholder="Enter assignment title" />
        </div>

        <div class="col-12">
            <label class="form-label-custom">Description</label>
            <asp:TextBox ID="txtDescription" runat="server" TextMode="MultiLine" Rows="4"
                CssClass="form-control-custom" placeholder="Describe the assignment..." />
        </div>

        <div class="col-md-4">
            <label class="form-label-custom">Due Date</label>
            <asp:TextBox ID="txtDueDate" runat="server" TextMode="Date"
                CssClass="form-control-custom" />
        </div>

        <div class="col-md-4">
            <label class="form-label-custom">Max Marks</label>
            <asp:TextBox ID="txtMarks" runat="server" CssClass="form-control-custom"
                placeholder="e.g. 100" />
        </div>

        <div class="col-md-4">
            <label class="form-label-custom">
                Assignment File <span style="color:red">*</span>
            </label>
            <div class="file-upload-wrap" onclick="document.getElementById('fuAssignment').click()">
                <i class="fas fa-cloud-upload-alt"></i>
                <span id="fileLabel">Click to upload a file</span>
                <asp:FileUpload ID="fuAssignment" runat="server"
                    Style="display:none"
                    ClientIDMode="Static"
                    onchange="updateLabel(this)" />
            </div>
        </div>

        <div class="col-12 mt-2">
            <asp:Button ID="btnSave" runat="server" Text="" 
                CssClass="btn-submit"
                OnClick="btnSave_Click"
                OnClientClick="this.innerHTML='<i class=\'fas fa-spinner fa-spin\'></i> Saving...'" />
        </div>

    </div>
</div>

<%-- ══ ASSIGNMENTS LIST ══ --%>
<div class="summary-strip">
    <i class="fas fa-tasks"></i>
    <span>
        <strong><asp:Label ID="lblAssignmentCount" runat="server" Text="0" /></strong>
        assignment(s) created by you.
    </span>
</div>

<asp:Panel ID="pnlAssignments" runat="server">
    <div class="row g-3">
        <asp:Repeater ID="rptAssignments" runat="server" 
            OnItemCommand="rptAssignments_ItemCommand">
            <ItemTemplate>
                <div class="col-md-6 col-lg-4">
                    <div class="assignment-card">

                        <div class="card-icon">
                            <i class="fas fa-file-alt"></i>
                        </div>

                        <div class="a-title"><%# Eval("Title") %></div>
                        <div class="a-subject">
                            <i class="fas fa-book me-1"></i><%# Eval("SubjectName") %>
                        </div>

                        <div class="desc-text">
                            <%# Eval("Description").ToString().Length > 100
                                ? Eval("Description").ToString().Substring(0, 100) + "..."
                                : Eval("Description") %>
                        </div>

                        <div class="meta-row">
                            <i class="far fa-calendar-alt"></i>
                            <span>Due: <strong><%# Eval("DueDate", "{0:dd MMM yyyy}") %></strong></span>
                        </div>

                        <div class="meta-row">
                            <i class="fas fa-star"></i>
                            <span>Max Marks: <strong><%# Eval("MaxMarks") %></strong></span>
                        </div>

                        <div class="mt-2 mb-1">
                            <%# GetDueBadge(Eval("DueDate")) %>
                        </div>

                        <div class="card-footer-row">
                            <asp:HyperLink runat="server"
                                NavigateUrl='<%# Eval("FilePath") %>'
                                CssClass="btn-action btn-download"
                                Visible='<%# Eval("FilePath") != DBNull.Value && Eval("FilePath").ToString() != "" %>'
                                Target="_blank">
                                <i class="fas fa-download"></i> File
                            </asp:HyperLink>

                            <asp:HyperLink runat="server"
                                NavigateUrl='<%# "ViewSubmissions.aspx?AssignmentId=" + Eval("AssignmentId") %>'
                                CssClass="btn-action btn-view">
                                <i class="fas fa-eye"></i> Submissions
                            </asp:HyperLink>

                            <asp:LinkButton runat="server"
                                CommandName="DeleteAssignment"
                                CommandArgument='<%# Eval("AssignmentId") %>'
                                CssClass="btn-action"
                                OnClientClick="return confirm('Are you sure you want to delete this assignment?');">
                                <i class="fas fa-trash"></i> Delete
                            </asp:LinkButton>
                        </div>

                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>
</asp:Panel>

<asp:Panel ID="pnlEmpty" runat="server" Visible="false">
    <div class="panel-card">
        <div class="empty-state">
            <i class="fas fa-clipboard"></i>
            <h6>No Assignments Yet</h6>
            <p>You haven't created any assignments yet.<br />Use the form above to get started.</p>
        </div>
    </div>
</asp:Panel>

<script>
    function updateLabel(input) {
        const label = document.getElementById("fileLabel");
        label.textContent = input.files.length > 0
            ? input.files[0].name
            : "Click to upload a file";
    }
</script>

</asp:Content>