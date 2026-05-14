<%@ Page Title="My Profile" Language="C#"
    MasterPageFile="~/Student/StudentMaster.Master"
    AutoEventWireup="true"
    CodeBehind="Profile.aspx.cs"
    Inherits="LMS_Project.Student.Profile" %>

<asp:Content ID="cHead" ContentPlaceHolderID="head" runat="server">
<style>

.page-header {
    display:flex; align-items:center; justify-content:space-between;
    margin-bottom:22px; flex-wrap:wrap; gap:12px;
}
.page-header h4 { margin:0; font-weight:800; color:#1565c0; font-size:20px; }

/* ── Profile hero card ── */
.profile-hero {
    background: linear-gradient(135deg, #1565c0, #1976d2);
    border-radius:16px; padding:28px 30px;
    display:flex; align-items:center; gap:24px;
    margin-bottom:22px; flex-wrap:wrap;
    color:#fff;
}
.profile-photo-wrap {
    position:relative; flex-shrink:0;
}
.profile-photo {
    width:100px; height:100px; border-radius:50%;
    object-fit:cover;
    border:4px solid rgba(255,255,255,.4);
}
.photo-edit-btn {
    position:absolute; bottom:2px; right:2px;
    width:28px; height:28px; border-radius:50%;
    background:#fff; color:#1565c0;
    border:none; cursor:pointer;
    display:flex; align-items:center; justify-content:center;
    font-size:12px; box-shadow:0 2px 6px rgba(0,0,0,.2);
    transition:all .2s;
}
.photo-edit-btn:hover { background:#e3f2fd; }

.profile-hero-info h5 { margin:0 0 6px; font-weight:900; font-size:22px; }
.profile-hero-info .hero-role {
    background:rgba(255,255,255,.2); border-radius:8px;
    padding:2px 12px; font-size:12px; font-weight:600;
    display:inline-block; margin-bottom:10px;
}
.hero-meta { display:flex; gap:16px; flex-wrap:wrap; font-size:12px; opacity:.9; }
.hero-meta span { display:flex; align-items:center; gap:5px; }

.btn-edit-profile {
    margin-left:auto; padding:9px 22px;
    background:rgba(255,255,255,.2);
    border:1.5px solid rgba(255,255,255,.5);
    color:#fff; border-radius:9px; font-size:13px;
    font-weight:700; cursor:pointer; transition:all .2s;
    flex-shrink:0;
}
.btn-edit-profile:hover { background:rgba(255,255,255,.35); }

/* ── Section card ── */
.info-card {
    background:#fff; border-radius:14px;
    box-shadow:0 2px 8px rgba(0,0,0,.06);
    padding:20px 24px; margin-bottom:18px;
}
.info-card-header {
    display:flex; align-items:center; justify-content:space-between;
    margin-bottom:18px; padding-bottom:12px;
    border-bottom:1.5px solid #f0f4f8;
}
.info-card-header h6 {
    margin:0; font-weight:800; color:#1565c0; font-size:14px;
    display:flex; align-items:center; gap:8px;
}

/* ── Info grid (view mode) ── */
.info-grid {
    display:grid; grid-template-columns:1fr 1fr;
    gap:14px 24px;
}
@media (max-width:600px) { .info-grid { grid-template-columns:1fr; } }

.info-item .lbl {
    font-size:11px; font-weight:700; color:#90a4ae;
    text-transform:uppercase; letter-spacing:.4px;
    margin-bottom:3px;
}
.info-item .val {
    font-size:14px; color:#263238; font-weight:600;
}
.info-item .val.empty { color:#cfd8dc; font-style:italic; font-weight:400; }

/* ── Edit form ── */
.edit-form { display:none; }
.form-group { margin-bottom:14px; }
.form-group label {
    font-size:12px; font-weight:700; color:#546e7a;
    display:block; margin-bottom:4px;
}
.form-group input,
.form-group textarea,
.form-group select {
    width:100%; padding:9px 12px;
    border:1.5px solid #e3e8f0; border-radius:9px;
    font-size:13px; color:#263238; outline:none;
    background:#f8fbff; transition:border .2s;
    box-sizing:border-box;
}
.form-group input:focus,
.form-group textarea:focus { border-color:#1565c0; background:#fff; }

.form-grid { display:grid; grid-template-columns:1fr 1fr; gap:0 16px; }
@media (max-width:600px) { .form-grid { grid-template-columns:1fr; } }

.btn-save {
    padding:9px 26px;
    background:linear-gradient(135deg,#1565c0,#1976d2);
    color:#fff; border:none; border-radius:9px;
    font-size:13px; font-weight:700; cursor:pointer;
    transition:opacity .2s;
}
.btn-save:hover { opacity:.88; }
.btn-cancel-edit {
    padding:9px 20px;
    background:#f0f4f8; color:#546e7a;
    border:1.5px solid #e3e8f0; border-radius:9px;
    font-size:13px; font-weight:700; cursor:pointer;
    margin-left:10px;
}

/* Academic badge strip */
.academic-strip {
    display:flex; gap:10px; flex-wrap:wrap;
}
.acad-badge {
    background:#e3f2fd; color:#1565c0;
    padding:5px 14px; border-radius:20px;
    font-size:12px; font-weight:700;
    display:flex; align-items:center; gap:5px;
}

/* Alert */
.profile-alert {
    padding:10px 16px; border-radius:9px;
    font-size:13px; font-weight:600; margin-bottom:14px;
}
.alert-success { background:#e8f5e9; color:#2e7d32; border:1.5px solid #a5d6a7; }
.alert-error   { background:#ffebee; color:#c62828; border:1.5px solid #ef9a9a; }

</style>
</asp:Content>

<asp:Content ID="cBody" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<asp:HiddenField ID="hfEditMode" runat="server" Value="0" />

<%-- Alert --%>
<asp:Label ID="lblMsg" runat="server" Visible="false" CssClass="profile-alert d-block" />

<%-- ══ HERO CARD ══ --%>
<div class="profile-hero">

    <div class="profile-photo-wrap">
        <asp:Image ID="imgPhoto" runat="server" CssClass="profile-photo"
            AlternateText="Profile Photo" />
        <button type="button" class="photo-edit-btn"
            onclick="document.getElementById('<%= fuPhoto.ClientID %>').click();"
            title="Change photo">
            <i class="fas fa-camera"></i>
        </button>
        <%-- Hidden file input --%>
        <asp:FileUpload ID="fuPhoto" runat="server"
            style="display:none;" accept=".jpg,.jpeg,.png,.gif"
            onchange="this.form.submit();" />
        <asp:Button ID="btnUploadPhoto" runat="server"
            style="display:none;" OnClick="btnUploadPhoto_Click" />
    </div>

    <div class="profile-hero-info">
        <h5><asp:Label ID="lblHeroName"  runat="server" /></h5>
        <div class="hero-role">Student</div>
        <div class="hero-meta">
            <span><i class="fas fa-id-badge"></i>
                <asp:Label ID="lblHeroRoll" runat="server" /></span>
            <span><i class="fas fa-book"></i>
                <asp:Label ID="lblHeroCourse" runat="server" /></span>
            <span><i class="fas fa-envelope"></i>
                <asp:Label ID="lblHeroEmail" runat="server" /></span>
        </div>
    </div>

    <asp:LinkButton ID="btnToggleEdit" runat="server"
        CssClass="btn-edit-profile"
        OnClick="btnToggleEdit_Click">
        <i class="fas fa-edit me-1"></i>Edit Profile
    </asp:LinkButton>

</div>

<%-- ══ ACADEMIC INFO (read-only always) ══ --%>
<div class="info-card">
    <div class="info-card-header">
        <h6><i class="fas fa-graduation-cap"></i>Academic Details</h6>
    </div>
    <div class="academic-strip">
        <div class="acad-badge">
            <i class="fas fa-stream"></i>
            <asp:Label ID="lblStream" runat="server" Text="—" />
        </div>
        <div class="acad-badge">
            <i class="fas fa-book-open"></i>
            <asp:Label ID="lblCourse" runat="server" Text="—" />
        </div>
        <div class="acad-badge">
            <i class="fas fa-layer-group"></i>
            <asp:Label ID="lblLevel" runat="server" Text="—" />
        </div>
        <div class="acad-badge">
            <i class="fas fa-calendar-alt"></i>
            <asp:Label ID="lblSemester" runat="server" Text="—" />
        </div>
        <div class="acad-badge">
            <i class="fas fa-users"></i>
            Section: <asp:Label ID="lblSection" runat="server" Text="—" />
        </div>
        <div class="acad-badge">
            <i class="fas fa-calendar"></i>
            <asp:Label ID="lblSession" runat="server" Text="—" />
        </div>
    </div>
</div>

<%-- ══ PERSONAL INFO ══ --%>
<div class="info-card">
    <div class="info-card-header">
        <h6><i class="fas fa-user"></i>Personal Information</h6>
    </div>

    <%-- VIEW MODE --%>
    <div id="viewPersonal">
        <div class="info-grid">
            <div class="info-item">
                <div class="lbl">Full Name</div>
                <div class="val"><asp:Label ID="lblFullName" runat="server" /></div>
            </div>
            <div class="info-item">
                <div class="lbl">Username</div>
                <div class="val"><asp:Label ID="lblUsername" runat="server" /></div>
            </div>
            <div class="info-item">
                <div class="lbl">Email</div>
                <div class="val"><asp:Label ID="lblEmail" runat="server" /></div>
            </div>
            <div class="info-item">
                <div class="lbl">Gender</div>
                <div class="val"><asp:Label ID="lblGender" runat="server" /></div>
            </div>
            <div class="info-item">
                <div class="lbl">Date of Birth</div>
                <div class="val"><asp:Label ID="lblDOB" runat="server" /></div>
            </div>
            <div class="info-item">
                <div class="lbl">Contact</div>
                <div class="val"><asp:Label ID="lblContact" runat="server" /></div>
            </div>
            <div class="info-item">
                <div class="lbl">Father's Name</div>
                <div class="val"><asp:Label ID="lblFather" runat="server" /></div>
            </div>
            <div class="info-item">
                <div class="lbl">Mother's Name</div>
                <div class="val"><asp:Label ID="lblMother" runat="server" /></div>
            </div>
        </div>
    </div>

    <%-- EDIT MODE --%>
    <asp:Panel ID="pnlEditPersonal" runat="server" CssClass="edit-form" style="display:none;">
        <div class="form-grid">
            <div class="form-group">
                <label>Full Name <span class="text-danger">*</span></label>
                <asp:TextBox ID="txtFullName" runat="server" CssClass="form-control" />
            </div>
            <div class="form-group">
                <label>Email</label>
                <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" TextMode="Email" />
            </div>
            <div class="form-group">
                <label>Contact Number</label>
                <asp:TextBox ID="txtContact" runat="server" CssClass="form-control" />
            </div>
            <div class="form-group">
                <label>Father's Name</label>
                <asp:TextBox ID="txtFather" runat="server" CssClass="form-control" />
            </div>
            <div class="form-group">
                <label>Mother's Name</label>
                <asp:TextBox ID="txtMother" runat="server" CssClass="form-control" />
            </div>
        </div>
    </asp:Panel>
</div>

<%-- ══ CONTACT & ADDRESS ══ --%>
<div class="info-card">
    <div class="info-card-header">
        <h6><i class="fas fa-map-marker-alt"></i>Address & Emergency Contact</h6>
    </div>

    <div id="viewAddress">
        <div class="info-grid">
            <div class="info-item" style="grid-column:1/-1;">
                <div class="lbl">Address</div>
                <div class="val"><asp:Label ID="lblAddress" runat="server" /></div>
            </div>
            <div class="info-item">
                <div class="lbl">City</div>
                <div class="val"><asp:Label ID="lblCity" runat="server" /></div>
            </div>
            <div class="info-item">
                <div class="lbl">Country</div>
                <div class="val"><asp:Label ID="lblCountry" runat="server" /></div>
            </div>
            <div class="info-item">
                <div class="lbl">Pincode</div>
                <div class="val"><asp:Label ID="lblPincode" runat="server" /></div>
            </div>
            <div class="info-item">
                <div class="lbl">Emergency Contact</div>
                <div class="val"><asp:Label ID="lblEmerName" runat="server" /></div>
            </div>
            <div class="info-item">
                <div class="lbl">Emergency Phone</div>
                <div class="val"><asp:Label ID="lblEmerNo" runat="server" /></div>
            </div>
        </div>
    </div>

    <asp:Panel ID="pnlEditAddress" runat="server" CssClass="edit-form" style="display:none;">
        <div class="form-group">
            <label>Address</label>
            <asp:TextBox ID="txtAddress" runat="server" CssClass="form-control"
                TextMode="MultiLine" Rows="2" />
        </div>
        <div class="form-grid">
            <div class="form-group">
                <label>City</label>
                <asp:TextBox ID="txtCity" runat="server" CssClass="form-control" />
            </div>
            <div class="form-group">
                <label>Country</label>
                <asp:TextBox ID="txtCountry" runat="server" CssClass="form-control" />
            </div>
            <div class="form-group">
                <label>Pincode</label>
                <asp:TextBox ID="txtPincode" runat="server" CssClass="form-control" />
            </div>
            <div class="form-group">
                <label>Emergency Contact Name</label>
                <asp:TextBox ID="txtEmerName" runat="server" CssClass="form-control" />
            </div>
            <div class="form-group">
                <label>Emergency Contact Phone</label>
                <asp:TextBox ID="txtEmerNo" runat="server" CssClass="form-control" />
            </div>
        </div>
    </asp:Panel>
</div>

<%-- ══ ABOUT / SKILLS ══ --%>
<div class="info-card">
    <div class="info-card-header">
        <h6><i class="fas fa-star"></i>Skills & About</h6>
    </div>

    <div id="viewAbout">
        <div class="info-grid">
            <div class="info-item">
                <div class="lbl">Skills</div>
                <div class="val"><asp:Label ID="lblSkills" runat="server" /></div>
            </div>
            <div class="info-item">
                <div class="lbl">Hobbies</div>
                <div class="val"><asp:Label ID="lblHobbies" runat="server" /></div>
            </div>
            <div class="info-item" style="grid-column:1/-1;">
                <div class="lbl">About Me</div>
                <div class="val"><asp:Label ID="lblDescription" runat="server" /></div>
            </div>
        </div>
    </div>

    <asp:Panel ID="pnlEditAbout" runat="server" CssClass="edit-form" style="display:none;">
        <div class="form-group">
            <label>Skills <span style="color:#90a4ae;font-weight:400;">(comma separated)</span></label>
            <asp:TextBox ID="txtSkills" runat="server" CssClass="form-control"
                placeholder="e.g. Python, Java, Web Development" />
        </div>
        <div class="form-group">
            <label>Hobbies</label>
            <asp:TextBox ID="txtHobbies" runat="server" CssClass="form-control"
                placeholder="e.g. Reading, Gaming, Football" />
        </div>
        <div class="form-group">
            <label>About Me</label>
            <asp:TextBox ID="txtDescription" runat="server" CssClass="form-control"
                TextMode="MultiLine" Rows="3"
                placeholder="Tell something about yourself..." />
        </div>
    </asp:Panel>
</div>

<%-- ══ SAVE / CANCEL (shown in edit mode) ══ --%>
<asp:Panel ID="pnlSaveBar" runat="server" Visible="false"
    style="margin-bottom:24px; display:flex; align-items:center;">
    <asp:Button ID="btnSave" runat="server" Text="Save Changes"
        CssClass="btn-save" OnClick="btnSave_Click" />
    <asp:LinkButton ID="btnCancelEdit" runat="server"
        CssClass="btn-cancel-edit" OnClick="btnCancelEdit_Click">
        Cancel
    </asp:LinkButton>
</asp:Panel>

<script>
// Toggle edit panels when server sets edit mode
window.addEventListener('DOMContentLoaded', function () {
    var editMode = document.getElementById('<%= hfEditMode.ClientID %>').value === '1';
    if (editMode) {
        document.querySelectorAll('.edit-form').forEach(function(el) {
            el.style.display = 'block';
        });
        document.getElementById('viewPersonal').style.display = 'none';
        document.getElementById('viewAddress').style.display  = 'none';
        document.getElementById('viewAbout').style.display    = 'none';
    }
});

// Auto-submit form on photo file select
document.addEventListener('DOMContentLoaded', function () {
    var fu = document.getElementById('<%= fuPhoto.ClientID %>');
    if (fu) {
        fu.onchange = function () {
            document.getElementById('<%= btnUploadPhoto.ClientID %>').click();
        };
    }
});
</script>

</asp:Content>
