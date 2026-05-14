<%@ Page Language="C#" AutoEventWireup="true"
    MasterPageFile="~/Teacher/TeacherMaster.master"
    CodeBehind="TeacherProfile.aspx.cs"
    Inherits="LMS_Project.Teacher.TeacherProfile" %>

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
    content: "\f007";
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

/* ── Edit button in banner ── */
.btn-banner-edit {
    display: inline-flex; align-items: center; gap: 6px;
    padding: 7px 20px;
    border-radius: 20px;
    background: rgba(255,255,255,.2);
    color: #fff;
    font-size: 13px; font-weight: 600;
    border: none; cursor: pointer;
    transition: background .2s;
    text-decoration: none;
}
.btn-banner-edit:hover { background: rgba(255,255,255,.35); color: #fff; }

/* ── Panel card ── */
.panel-card {
    background: #fff;
    border-radius: 14px;
    box-shadow: 0 2px 8px rgba(0,0,0,.06);
    padding: 28px;
    margin-bottom: 24px;
}
.panel-card .section-title {
    font-size: 13px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: .8px;
    color: #1565c0;
    margin-bottom: 18px;
    padding-bottom: 10px;
    border-bottom: 2px solid #e3f2fd;
    display: flex;
    align-items: center;
    gap: 8px;
}

/* ── Profile avatar block ── */
.profile-avatar-block {
    display: flex;
    align-items: center;
    gap: 20px;
    margin-bottom: 28px;
    padding-bottom: 24px;
    border-bottom: 1px solid #e3f2fd;
}
.profile-avatar {
    width: 80px; height: 80px;
    border-radius: 50%;
    background: linear-gradient(135deg, #1565c0, #42a5f5);
    color: #fff;
    font-size: 30px;
    font-weight: 800;
    display: flex; align-items: center; justify-content: center;
    flex-shrink: 0;
    box-shadow: 0 4px 14px rgba(21,101,192,.3);
}
.profile-avatar-info .p-name {
    font-size: 20px;
    font-weight: 800;
    color: #263238;
    margin-bottom: 3px;
}
.profile-avatar-info .p-designation {
    font-size: 13px;
    color: #1565c0;
    font-weight: 600;
    margin-bottom: 3px;
}
.profile-avatar-info .p-email {
    font-size: 12px;
    color: #90a4ae;
}

/* ── Stat pills below avatar ── */
.profile-stat-pill {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    background: #e3f2fd;
    color: #1565c0;
    border-radius: 20px;
    padding: 4px 14px;
    font-size: 12px;
    font-weight: 700;
    margin-right: 6px;
    margin-top: 8px;
}

/* ── Form fields ── */
.form-label-custom {
    font-size: 11px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: .5px;
    color: #78909c;
    margin-bottom: 6px;
    display: block;
}
.form-control-custom {
    width: 100%;
    border: 1.5px solid #e3f2fd;
    border-radius: 10px;
    padding: 10px 14px;
    font-size: 13px;
    color: #455a64;
    background: #f0f7ff;
    outline: none;
    transition: border .2s, background .2s, box-shadow .2s;
    box-sizing: border-box;
    font-weight: 500;
}
.form-control-custom:focus {
    border-color: #1976d2;
    background: #fff;
    box-shadow: 0 0 0 3px rgba(25,118,210,.1);
}
.form-control-custom[readonly] {
    background: #f0f7ff;
    color: #546e7a;
    border-color: #e3f2fd;
    cursor: default;
}

/* ── Info display row (read mode) ── */
.info-display-row {
    display: flex;
    flex-direction: column;
    gap: 2px;
    padding: 12px 14px;
    background: #f0f7ff;
    border-radius: 10px;
    border: 1.5px solid #e3f2fd;
    height: 100%;
}
.info-display-row .idr-label {
    font-size: 10px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: .5px;
    color: #90a4ae;
}
.info-display-row .idr-value {
    font-size: 14px;
    font-weight: 600;
    color: #263238;
}

/* ── Buttons ── */
.btn-submit {
    background: linear-gradient(135deg, #1565c0, #1976d2);
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
    box-shadow: 0 4px 12px rgba(21,101,192,.25);
}
.btn-submit:hover { opacity: .9; transform: translateY(-2px); }

.btn-cancel {
    background: #e3f2fd;
    color: #1565c0;
    border: none;
    border-radius: 10px;
    padding: 11px 22px;
    font-size: 14px;
    font-weight: 600;
    cursor: pointer;
    transition: background .2s;
    display: inline-flex;
    align-items: center;
    gap: 8px;
    margin-left: 10px;
}
.btn-cancel:hover { background: #bbdefb; }

/* ── Success / Error alerts ── */
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

/* ── Change password card ── */
.pwd-card {
    background: #f0f7ff;
    border-radius: 12px;
    padding: 20px;
    border: 1.5px solid #e3f2fd;
}

/* ── Section divider ── */
.section-divider {
    height: 1px;
    background: #e3f2fd;
    margin: 24px 0;
}

</style>
</asp:Content>

<asp:Content ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

<%-- ══ PAGE BANNER ══ --%>
<div class="page-banner">
    <div class="d-flex align-items-start justify-content-between flex-wrap gap-2">
        <div>
            <h4><i class="fas fa-user-circle me-2"></i>My Profile</h4>
            <p>View and update your personal and professional information.</p>
        </div>
        <asp:Button ID="btnEdit" runat="server"
            Text="✏ Edit Profile"
            CssClass="btn-banner-edit"
            OnClick="btnEdit_Click" />
    </div>
</div>

<%-- ══ SUCCESS ALERT ══ --%>
<asp:Panel ID="pnlSuccess" runat="server" Visible="false">
    <div class="alert-success-custom">
        <i class="fas fa-check-circle"></i>
        Profile updated successfully!
    </div>
</asp:Panel>

<%-- ══ MAIN PANEL ══ --%>
<div class="panel-card">

    <%-- ── Avatar Block ── --%>
    <div class="profile-avatar-block">
        <div class="profile-avatar">
            <asp:Label ID="lblInitialBig" runat="server" Text="T" />
        </div>
        <div class="profile-avatar-info">
            <div class="p-name">
                <asp:Label ID="lblDisplayName" runat="server" />
            </div>
            <div class="p-designation">
                <i class="fas fa-id-badge me-1"></i>
                <asp:Label ID="lblDisplayDesignation" runat="server" />
            </div>
            <div class="p-email">
                <i class="fas fa-envelope me-1"></i>
                <asp:Label ID="lblDisplayEmail" runat="server" />
            </div>
            <div>
                <span class="profile-stat-pill">
                    <i class="fas fa-building"></i>
                    <asp:Label ID="lblDisplayDept" runat="server" Text="Department" />
                </span>
                <span class="profile-stat-pill">
                    <i class="fas fa-graduation-cap"></i>
                    <asp:Label ID="lblDisplayQual" runat="server" Text="Qualification" />
                </span>
                <span class="profile-stat-pill">
                    <i class="fas fa-briefcase"></i>
                    <asp:Label ID="lblDisplayExp" runat="server" Text="0 yrs exp" />
                </span>
            </div>
        </div>
    </div>

    <%-- ── Personal Information ── --%>
    <div class="section-title">
        <i class="fas fa-user"></i> Personal Information
    </div>

    <div class="row g-3 mb-4">
        <div class="col-md-6">
            <label class="form-label-custom">Full Name</label>
            <asp:TextBox ID="txtFullName" runat="server"
                CssClass="form-control-custom" ReadOnly="true" />
        </div>
        <div class="col-md-6">
            <label class="form-label-custom">Email</label>
            <asp:TextBox ID="txtEmail" runat="server"
                CssClass="form-control-custom" ReadOnly="true" />
        </div>
        <div class="col-md-6">
            <label class="form-label-custom">Contact Number</label>
            <asp:TextBox ID="txtContact" runat="server"
                CssClass="form-control-custom" ReadOnly="true" />
        </div>
        <div class="col-md-6">
            <label class="form-label-custom">Address</label>
            <asp:TextBox ID="txtAddress" runat="server"
                CssClass="form-control-custom" ReadOnly="true" />
        </div>
        <div class="col-md-4">
            <label class="form-label-custom">City</label>
            <asp:TextBox ID="txtCity" runat="server"
                CssClass="form-control-custom" ReadOnly="true" />
        </div>
        <div class="col-md-4">
            <label class="form-label-custom">Country</label>
            <asp:TextBox ID="txtCountry" runat="server"
                CssClass="form-control-custom" ReadOnly="true" />
        </div>
        <div class="col-md-4">
            <label class="form-label-custom">Pincode</label>
            <asp:TextBox ID="txtPincode" runat="server"
                CssClass="form-control-custom" ReadOnly="true" />
        </div>
    </div>

    <div class="section-divider"></div>

    <%-- ── Professional Information ── --%>
    <div class="section-title">
        <i class="fas fa-briefcase"></i> Professional Information
    </div>

    <div class="row g-3 mb-4">
        <div class="col-md-4">
            <label class="form-label-custom">Designation</label>
            <asp:TextBox ID="txtDesignation" runat="server"
                CssClass="form-control-custom" ReadOnly="true" />
        </div>
        <div class="col-md-4">
            <label class="form-label-custom">Qualification</label>
            <asp:TextBox ID="txtQualification" runat="server"
                CssClass="form-control-custom" ReadOnly="true" />
        </div>
        <div class="col-md-4">
            <label class="form-label-custom">Experience (Years)</label>
            <asp:TextBox ID="txtExperience" runat="server"
                CssClass="form-control-custom" ReadOnly="true" />
        </div>
    </div>

    <div class="section-divider"></div>

    <%-- ── Change Password ── --%>
    <asp:Panel ID="pnlChangePassword" runat="server" Visible="false">
        <div class="section-title">
            <i class="fas fa-lock"></i> Change Password
        </div>
        <div class="pwd-card">
            <div class="row g-3">
                <div class="col-md-4">
                    <label class="form-label-custom">Current Password</label>
                    <asp:TextBox ID="txtCurrentPassword" runat="server"
                        TextMode="Password"
                        CssClass="form-control-custom"
                        placeholder="Enter current password" />
                </div>
                <div class="col-md-4">
                    <label class="form-label-custom">New Password</label>
                    <asp:TextBox ID="txtNewPassword" runat="server"
                        TextMode="Password"
                        CssClass="form-control-custom"
                        placeholder="Enter new password" />
                </div>
                <div class="col-md-4">
                    <label class="form-label-custom">Confirm New Password</label>
                    <asp:TextBox ID="txtConfirmPassword" runat="server"
                        TextMode="Password"
                        CssClass="form-control-custom"
                        placeholder="Confirm new password" />
                </div>
            </div>
        </div>
        <div class="section-divider"></div>
    </asp:Panel>

    <%-- ── Action Buttons ── --%>
    <div>
        <asp:Button ID="btnUpdate" runat="server"
            Text="💾 Save Changes"
            CssClass="btn-submit"
            Visible="false"
            OnClick="btnUpdate_Click" />

        <asp:Button ID="btnCancel" runat="server"
            Text="✕ Cancel"
            CssClass="btn-cancel"
            Visible="false"
            OnClick="btnCancel_Click"
            CausesValidation="false" />
    </div>

</div>

</asp:Content>