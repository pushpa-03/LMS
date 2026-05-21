<%@ Page Title="My Profile" Language="C#"
    MasterPageFile="~/Admin/AdminMaster.master"
    AutoEventWireup="true"
    CodeBehind="AdminProfile.aspx.cs"
    Inherits="LearningManagementSystem.Admin.AdminProfile" %>

<asp:Content ID="C1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<link href="https://fonts.googleapis.com/css2?family=Bricolage+Grotesque:opsz,wght@12..96,300;12..96,400;12..96,500;12..96,600;12..96,700;12..96,800&family=Instrument+Sans:ital,wght@0,400;0,500;0,600;0,700;1,400&family=DM+Mono:wght@400;500&display=swap" rel="stylesheet">
</asp:Content>

<asp:Content ID="C2" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

<asp:HiddenField ID="hfToastMsg"  runat="server" />
<asp:HiddenField ID="hfToastType" runat="server" />

<style>
/* ═══════════════════════════════════════════════════════════
   ADMIN PROFILE — Refined editorial light
   Bricolage Grotesque (display) · Instrument Sans (body) · DM Mono
═══════════════════════════════════════════════════════════ */
:root{
  --bg:#f4f6fb;--surf:#fff;--surf2:#f9fafd;--surf3:#eef2f9;
  --bdr:#e4e9f4;--bdr2:#c9d4ec;
  --blue:#2563eb;--blue2:#3b82f6;--blue-lt:#eff6ff;--blue-mid:#dbeafe;
  --indigo:#4f46e5;--green:#059669;--green-lt:#ecfdf5;
  --amber:#d97706;--red:#dc2626;--red-lt:#fef2f2;
  --sky:#0891b2;--purple:#7c3aed;--purple-lt:#f5f3ff;
  --ink:#0f172a;--ink2:#1e293b;--ink3:#334155;--muted:#64748b;--dim:#94a3b8;
  --f:'Instrument Sans',system-ui,sans-serif;
  --fd:'Bricolage Grotesque',system-ui,sans-serif;
  --mono:'DM Mono',monospace;
  --r:12px;--rlg:16px;--rxl:22px;
  --sh:0 1px 4px rgba(15,23,42,.06),0 6px 20px rgba(15,23,42,.07);
  --sh2:0 6px 28px rgba(15,23,42,.10),0 14px 44px rgba(15,23,42,.08);
}
*,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
.ap-root{font-family:var(--f);color:var(--ink);font-size:14px;line-height:1.55}
::-webkit-scrollbar{width:5px}
::-webkit-scrollbar-thumb{background:var(--bdr2);border-radius:3px}

/* ── LAYOUT ── */
.ap-layout{display:grid;grid-template-columns:300px 1fr;gap:22px;align-items:start}
@media(max-width:1024px){.ap-layout{grid-template-columns:1fr}}

/* ── PROFILE HERO CARD (left column) ── */
.ap-hero{
  background:var(--surf);border:1px solid var(--bdr);border-radius:var(--rxl);
  box-shadow:var(--sh);overflow:hidden;position:sticky;top:20px;
  animation:fadeUp .45s both;
}
.ap-hero-banner{
  height:88px;
  background:linear-gradient(135deg,#1e3a8a 0%,#2563eb 50%,#6366f1 100%);
  position:relative;
}
.ap-hero-banner::after{
  content:'';position:absolute;bottom:-1px;left:0;right:0;height:32px;
  background:var(--surf);clip-path:ellipse(60% 100% at 50% 100%);
}
.ap-avatar-wrap{
  display:flex;flex-direction:column;align-items:center;
  padding:0 20px 20px;margin-top:-42px;position:relative;z-index:2;
}
.ap-avatar{
  width:84px;height:84px;border-radius:50%;
  border:4px solid var(--surf);box-shadow:0 4px 16px rgba(0,0,0,.12);
  overflow:hidden;display:flex;align-items:center;justify-content:center;
  font-family:var(--fd);font-size:28px;font-weight:800;color:#fff;
  flex-shrink:0;position:relative;cursor:pointer;transition:.2s;
}
.ap-avatar:hover .ap-photo-overlay{opacity:1}
.ap-photo-overlay{
  position:absolute;inset:0;background:rgba(0,0,0,.45);
  display:flex;align-items:center;justify-content:center;
  border-radius:50%;opacity:0;transition:.2s;
}
.ap-photo-overlay i{color:#fff;font-size:18px}
.ap-avatar img{width:100%;height:100%;object-fit:cover}
.ap-hero-name{
  font-family:var(--fd);font-size:1.15rem;font-weight:800;
  color:var(--ink);text-align:center;margin-top:10px;margin-bottom:3px;
}
.ap-hero-role{
  display:inline-flex;align-items:center;gap:5px;
  background:var(--blue-lt);border:1px solid var(--blue-mid);
  border-radius:20px;padding:2px 11px;
  font-size:11px;font-weight:700;color:var(--blue);
}
.ap-hero-inst{
  font-size:11px;color:var(--muted);margin-top:6px;text-align:center;
}

/* Stat pills in hero */
.ap-hero-stats{
  display:grid;grid-template-columns:1fr 1fr 1fr;
  gap:8px;padding:16px 18px;border-top:1px solid var(--bdr);
}
.ap-hstat{
  background:var(--surf3);border-radius:10px;padding:10px 8px;text-align:center;
  border:1px solid var(--bdr);transition:.15s;
}
.ap-hstat:hover{background:var(--blue-lt);border-color:var(--blue-mid)}
.ap-hstat-val{
  font-family:var(--mono);font-size:1.1rem;font-weight:500;
  color:var(--ink);line-height:1;margin-bottom:3px;
}
.ap-hstat-lbl{font-size:9px;font-weight:700;color:var(--muted);text-transform:uppercase;letter-spacing:.05em}

/* Meta info list */
.ap-hero-meta{padding:0 18px 20px}
.ap-meta-item{
  display:flex;align-items:flex-start;gap:10px;
  padding:9px 0;border-bottom:1px solid var(--bdr);
}
.ap-meta-item:last-child{border-bottom:none}
.ap-meta-icon{
  width:28px;height:28px;border-radius:7px;flex-shrink:0;
  display:flex;align-items:center;justify-content:center;font-size:11px;
}
.ap-meta-key{font-size:10px;font-weight:700;color:var(--dim);text-transform:uppercase;letter-spacing:.05em;margin-bottom:2px}
.ap-meta-val{font-size:12px;font-weight:600;color:var(--ink3)}

/* Photo upload hidden input */
#photoInput{display:none}

/* ── RIGHT COLUMN: TABS + FORMS ── */
.ap-right{animation:fadeUp .45s .08s both}
@keyframes fadeUp{from{opacity:0;transform:translateY(16px)}to{opacity:1;transform:translateY(0)}}

/* TABS */
.ap-tabs{
  display:flex;gap:2px;background:var(--surf3);
  border:1px solid var(--bdr);border-radius:12px;padding:4px;
  margin-bottom:20px;overflow-x:auto;
}
.ap-tab{
  flex:1;min-width:max-content;padding:8px 16px;border-radius:8px;border:none;
  font-family:var(--f);font-size:12px;font-weight:700;cursor:pointer;
  background:transparent;color:var(--muted);transition:.18s;display:flex;
  align-items:center;gap:6px;justify-content:center;white-space:nowrap;
}
.ap-tab.on{background:var(--surf);color:var(--blue);box-shadow:var(--sh)}
.ap-tab i{font-size:12px}
.ap-pane{display:none}
.ap-pane.on{display:block}

.ap-card{
  background:var(--surf);border:1px solid var(--bdr);border-radius:var(--rlg);
  box-shadow:var(--sh);overflow:hidden;margin-bottom:18px;
  transition:box-shadow .2s;
}
.ap-card:hover{box-shadow:var(--sh2)}
.ap-card-head{
  display:flex;align-items:center;justify-content:space-between;
  padding:15px 20px;border-bottom:1px solid var(--bdr);
  background:linear-gradient(135deg,#fafcff,#f4f7fe);
}
.ap-card-title{
  font-family:var(--fd);font-size:14px;font-weight:700;color:var(--ink2);
  display:flex;align-items:center;gap:8px;
}
.ap-card-title .ico{
  width:30px;height:30px;border-radius:8px;
  display:flex;align-items:center;justify-content:center;font-size:12px;flex-shrink:0;
}
.ap-card-body{padding:20px 22px}

/* ── FORM GRID ── */
.ap-fg{display:grid;grid-template-columns:1fr 1fr;gap:16px 20px}
.ap-fg.cols3{grid-template-columns:1fr 1fr 1fr}
.ap-fg.cols1{grid-template-columns:1fr}
@media(max-width:700px){.ap-fg,.ap-fg.cols3{grid-template-columns:1fr}}
.ap-field{display:flex;flex-direction:column;gap:5px}
.ap-field.full{grid-column:1/-1}
.ap-lbl{
  font-size:10px;font-weight:700;text-transform:uppercase;
  letter-spacing:.07em;color:var(--muted);
}
.ap-lbl .req{color:var(--red);margin-left:2px}
.ap-input,.ap-select,.ap-textarea{
  width:100%;border:1.5px solid var(--bdr);border-radius:var(--r);
  padding:9px 13px;font-family:var(--f);font-size:13px;font-weight:500;
  color:var(--ink2);background:var(--surf2);
  transition:border-color .18s,box-shadow .18s,background .18s;outline:none;
}
.ap-input:focus,.ap-select:focus,.ap-textarea:focus{
  border-color:var(--blue2);background:var(--surf);
  box-shadow:0 0 0 3px rgba(59,130,246,.12);
}
.ap-input[readonly]{background:#f1f5f9;color:var(--muted);cursor:not-allowed}
.ap-textarea{resize:vertical;min-height:90px}
.ap-select{cursor:pointer}

/* ── BUTTON ── */
.ap-btn-row{
  display:flex;gap:10px;align-items:center;flex-wrap:wrap;
  margin-top:18px;padding-top:16px;border-top:1px solid var(--bdr);
}
.ap-btn{
  display:inline-flex;align-items:center;gap:7px;
  padding:9px 22px;border-radius:10px;border:none;
  font-family:var(--f);font-size:13px;font-weight:700;
  cursor:pointer;transition:all .18s;white-space:nowrap;
}
.ap-btn.primary{
  background:linear-gradient(135deg,var(--blue),var(--blue2));
  color:#fff;box-shadow:0 4px 14px rgba(37,99,235,.3);
}
.ap-btn.primary:hover{box-shadow:0 6px 22px rgba(37,99,235,.45);transform:translateY(-1px)}
.ap-btn.danger{background:var(--red-lt);color:var(--red);border:1.5px solid #fca5a5}
.ap-btn.danger:hover{background:var(--red);color:#fff}
.ap-btn.ghost{background:var(--surf3);color:var(--ink3);border:1.5px solid var(--bdr)}
.ap-btn.ghost:hover{background:var(--bdr);border-color:var(--bdr2)}

/* ── PASSWORD STRENGTH ── */
.pw-strength-bar{height:4px;border-radius:2px;background:var(--bdr);margin-top:6px;overflow:hidden}
.pw-strength-fill{height:100%;border-radius:2px;transition:width .3s,background .3s;width:0}
.pw-strength-label{font-size:11px;font-weight:600;margin-top:4px}

/* ── ACTIVITY TIMELINE ── */
.ap-timeline{position:relative;padding-left:30px}
.ap-timeline::before{
  content:'';position:absolute;left:12px;top:0;bottom:0;
  width:2px;background:var(--bdr);border-radius:1px;
}
.ap-tl-item{position:relative;margin-bottom:16px}
.ap-tl-dot{
  position:absolute;left:-24px;top:2px;
  width:20px;height:20px;border-radius:50%;
  display:flex;align-items:center;justify-content:center;
  font-size:8px;color:#fff;flex-shrink:0;
  border:2px solid var(--surf);
}
.ap-tl-card{
  background:var(--surf2);border:1px solid var(--bdr);border-radius:10px;
  padding:10px 14px;transition:.15s;
}
.ap-tl-card:hover{background:var(--blue-lt);border-color:var(--blue-mid)}
.ap-tl-type{font-size:13px;font-weight:600;color:var(--ink3)}
.ap-tl-time{font-size:11px;color:var(--dim);margin-top:2px;font-family:var(--mono)}

/* ── PHOTO UPLOAD ZONE ── */
.ap-photo-zone{
  border:2px dashed var(--bdr2);border-radius:var(--rlg);
  padding:28px;text-align:center;cursor:pointer;
  transition:all .22s;
}
.ap-photo-zone:hover{border-color:var(--blue2);background:var(--blue-lt)}
.ap-photo-zone i{font-size:2rem;color:var(--blue2);margin-bottom:10px;display:block}
.ap-photo-zone p{font-size:13px;color:var(--muted);margin:0}
.ap-photo-zone small{font-size:11px;color:var(--dim)}

/* ── TOAST ── */
.ap-toast{
  position:fixed;top:22px;right:22px;z-index:9999;
  display:flex;align-items:center;gap:10px;
  min-width:280px;max-width:380px;
  background:var(--surf);border:1.5px solid var(--bdr);
  border-radius:12px;padding:13px 18px;
  box-shadow:var(--sh2);
  transform:translateX(420px);transition:transform .35s cubic-bezier(.4,0,.2,1);
}
.ap-toast.show{transform:translateX(0)}
.ap-toast.success{border-color:#a7f3d0;background:#f0fdf4}
.ap-toast.error  {border-color:#fca5a5;background:#fef2f2}
.ap-toast-icon{width:30px;height:30px;border-radius:8px;flex-shrink:0;
  display:flex;align-items:center;justify-content:center;font-size:14px}
.ap-toast.success .ap-toast-icon{background:var(--green-lt);color:var(--green)}
.ap-toast.error   .ap-toast-icon{background:var(--red-lt);  color:var(--red)}
.ap-toast-msg{font-size:13px;font-weight:600;color:var(--ink3);flex:1}
.ap-toast-close{background:none;border:none;cursor:pointer;color:var(--dim);font-size:14px;padding:0}

/* ── SESSION BADGE ── */
.ap-sess-badge{
  display:inline-flex;align-items:center;gap:6px;
  background:var(--green-lt);border:1px solid #a7f3d0;
  border-radius:20px;padding:4px 12px;
  font-size:11px;font-weight:700;color:var(--green);
}
.ap-sess-badge::before{content:'';width:6px;height:6px;border-radius:50%;background:var(--green)}

/* ── EMPTY TIMELINE ── */
.ap-empty-tl{text-align:center;padding:32px 20px;color:var(--dim)}
.ap-empty-tl i{font-size:2rem;opacity:.2;display:block;margin-bottom:8px}
</style>

<!-- TOAST -->
<div class="ap-toast" id="apToast">
    <div class="ap-toast-icon"><i class="fa fa-check" id="toastIcon"></i></div>
    <div class="ap-toast-msg" id="toastMsg"></div>
    <button class="ap-toast-close" onclick="hideToast()"><i class="fa fa-times"></i></button>
</div>

<!-- HIDDEN PHOTO INPUT -->
<input type="file" id="photoInput" accept=".jpg,.jpeg,.png,.webp"
    onchange="previewPhoto(this)" />

<div class="ap-root">
<div class="ap-layout">

<!-- ══════════════════════════════════════════
     LEFT: PROFILE HERO
══════════════════════════════════════════ -->
<div class="ap-hero">

    <div class="ap-hero-banner"></div>

    <div class="ap-avatar-wrap">
        <div class="ap-avatar"
             style="background:<%=AvatarBg%>"
             onclick="document.getElementById('photoInput').click()"
             title="Click to change photo" id="avatarEl">
            <% if (HasPhoto) { %>
                <img src="<%=ResolveUrl(ProfileImagePath)%>" alt="Profile Photo" id="avatarImg" />
            <% } else { %>
                <span id="avatarText"><%=AdminInitials%></span>
            <% } %>
            <div class="ap-photo-overlay"><i class="fa fa-camera"></i></div>
        </div>

        <div class="ap-hero-name"><%=AdminName%></div>
        <div class="ap-hero-role"><i class="fa fa-shield-alt"></i><%=AdminRole%></div>
        <div class="ap-hero-inst">
            <asp:Label ID="lblInstitute" runat="server" /><br/>
            <small style="color:var(--dim)"><asp:Label ID="lblSociety" runat="server" /></small>
        </div>

        <% if (Convert.ToBoolean(Session["CurrentSessionId"] != null)) { %>
        <div class="ap-sess-badge" style="margin-top:10px">
            <asp:Label ID="lblSessionName" runat="server"
                Text='<%# Session["SessionName"] %>' />
        </div>
        <% } %>
    </div>

    <!-- Quick stats -->
    <div class="ap-hero-stats">
        <div class="ap-hstat">
            <div class="ap-hstat-val" style="color:var(--blue)"><%=StatStudents%></div>
            <div class="ap-hstat-lbl">Students</div>
        </div>
        <div class="ap-hstat">
            <div class="ap-hstat-val" style="color:var(--green)"><%=StatTeachers%></div>
            <div class="ap-hstat-lbl">Teachers</div>
        </div>
        <div class="ap-hstat">
            <div class="ap-hstat-val" style="color:var(--amber)"><%=StatSubjects%></div>
            <div class="ap-hstat-lbl">Subjects</div>
        </div>
        <div class="ap-hstat">
            <div class="ap-hstat-val" style="color:var(--purple)"><%=StatVideos%></div>
            <div class="ap-hstat-lbl">Videos</div>
        </div>
        <div class="ap-hstat">
            <div class="ap-hstat-val" style="color:var(--sky)"><%=StatAssignments%></div>
            <div class="ap-hstat-lbl">Assignments</div>
        </div>
        <div class="ap-hstat">
            <div class="ap-hstat-val" style="color:var(--green)"><%=StatAttendance%></div>
            <div class="ap-hstat-lbl">Attendance</div>
        </div>
    </div>

    <!-- Meta info -->
    <div class="ap-hero-meta">
        <div class="ap-meta-item">
            <div class="ap-meta-icon" style="background:#eff6ff;color:#2563eb"><i class="fa fa-calendar-alt"></i></div>
            <div>
                <div class="ap-meta-key">Joined</div>
                <div class="ap-meta-val"><asp:Label ID="lblJoined" runat="server" /></div>
            </div>
        </div>
        <div class="ap-meta-item">
            <div class="ap-meta-icon" style="background:#ecfdf5;color:#059669"><i class="fa fa-clock"></i></div>
            <div>
                <div class="ap-meta-key">Last Login</div>
                <div class="ap-meta-val"><asp:Label ID="lblLastLogin" runat="server" /></div>
            </div>
        </div>
        <div class="ap-meta-item">
            <div class="ap-meta-icon" style="background:#fef3c7;color:#d97706"><i class="fa fa-user-plus"></i></div>
            <div>
                <div class="ap-meta-key">Account Created</div>
                <div class="ap-meta-val"><asp:Label ID="lblCreated" runat="server" /></div>
            </div>
        </div>
        <div class="ap-meta-item">
            <div class="ap-meta-icon" style="background:#f5f3ff;color:#7c3aed"><i class="fa fa-key"></i></div>
            <div>
                <div class="ap-meta-key">First Login Pending</div>
                <div class="ap-meta-val"><asp:Label ID="lblFirstLogin" runat="server" /></div>
            </div>
        </div>
    </div>
</div>

<!-- ══════════════════════════════════════════
     RIGHT: TABS + FORMS
══════════════════════════════════════════ -->
<div class="ap-right">

    <div class="ap-tabs" id="apTabs">
        <button class="ap-tab on"  type="button" onclick="apSwitch(this,'tPersonal')"><i class="fa fa-user"></i>Personal Info</button>
        <button class="ap-tab"     type="button" onclick="apSwitch(this,'tAccount')"><i class="fa fa-at"></i>Account</button>
        <button class="ap-tab"     type="button" onclick="apSwitch(this,'tSecurity')"><i class="fa fa-lock"></i>Security</button>
        <button class="ap-tab"     type="button" onclick="apSwitch(this,'tPhoto')"><i class="fa fa-camera"></i>Photo</button>
        <button class="ap-tab"     type="button" onclick="apSwitch(this,'tActivity')"><i class="fa fa-bolt"></i>Activity</button>
    </div>

    <!-- ── TAB: PERSONAL INFO ── -->
    <div class="ap-pane on" id="tPersonal">

        <div class="ap-card">
            <div class="ap-card-head">
                <div class="ap-card-title">
                    <div class="ico" style="background:#eff6ff;color:#2563eb"><i class="fa fa-user"></i></div>
                    Personal Information
                </div>
            </div>
            <div class="ap-card-body">
                <div class="ap-fg">
                    <div class="ap-field">
                        <label class="ap-lbl">Full Name <span class="req">*</span></label>
                        <asp:TextBox ID="txtFullName" runat="server" CssClass="ap-input" placeholder="Your full name" />
                    </div>
                    <div class="ap-field">
                        <label class="ap-lbl">Username</label>
                        <asp:TextBox ID="txtUsername" runat="server" CssClass="ap-input" ReadOnly="true" />
                    </div>
                    <div class="ap-field">
                        <label class="ap-lbl">Gender</label>
                        <asp:DropDownList ID="txtGender" runat="server" CssClass="ap-select">
                            <asp:ListItem Value="">-- Select --</asp:ListItem>
                            <asp:ListItem Value="Male">Male</asp:ListItem>
                            <asp:ListItem Value="Female">Female</asp:ListItem>
                            <asp:ListItem Value="Other">Other</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div class="ap-field">
                        <label class="ap-lbl">Date of Birth</label>
                        <asp:TextBox ID="txtDOB" runat="server" CssClass="ap-input" TextMode="Date" />
                    </div>
                    <div class="ap-field">
                        <label class="ap-lbl">Contact Number</label>
                        <asp:TextBox ID="txtContact" runat="server" CssClass="ap-input" placeholder="+91 9000000000" />
                    </div>
                    <div class="ap-field">
                        <label class="ap-lbl">Father's Name</label>
                        <asp:TextBox ID="txtFather" runat="server" CssClass="ap-input" placeholder="Father's name" />
                    </div>
                    <div class="ap-field">
                        <label class="ap-lbl">Mother's Name</label>
                        <asp:TextBox ID="txtMother" runat="server" CssClass="ap-input" placeholder="Mother's name" />
                    </div>
                    <div class="ap-field">
                        <label class="ap-lbl">Emergency Contact Name</label>
                        <asp:TextBox ID="txtEmgName" runat="server" CssClass="ap-input" placeholder="Emergency contact" />
                    </div>
                    <div class="ap-field">
                        <label class="ap-lbl">Emergency Contact No</label>
                        <asp:TextBox ID="txtEmgNo" runat="server" CssClass="ap-input" placeholder="Emergency phone" />
                    </div>
                    <div class="ap-field full">
                        <label class="ap-lbl">Address</label>
                        <asp:TextBox ID="txtAddress" runat="server" CssClass="ap-input" placeholder="Street / Building" />
                    </div>
                    <div class="ap-field">
                        <label class="ap-lbl">City</label>
                        <asp:TextBox ID="txtCity" runat="server" CssClass="ap-input" placeholder="City" />
                    </div>
                    <div class="ap-field">
                        <label class="ap-lbl">Country</label>
                        <asp:TextBox ID="txtCountry" runat="server" CssClass="ap-input" placeholder="Country" />
                    </div>
                    <div class="ap-field">
                        <label class="ap-lbl">Pincode</label>
                        <asp:TextBox ID="txtPincode" runat="server" CssClass="ap-input" placeholder="Pincode" TextMode="Number" />
                    </div>
                    <div class="ap-field">
                        <label class="ap-lbl">Skills / Expertise</label>
                        <asp:TextBox ID="txtSkills" runat="server" CssClass="ap-input" placeholder="e.g. Leadership, Management" />
                    </div>
                    <div class="ap-field full">
                        <label class="ap-lbl">Bio / About Me</label>
                        <asp:TextBox ID="txtBio" runat="server" CssClass="ap-textarea" TextMode="MultiLine"
                            placeholder="Write a short bio about yourself…" />
                    </div>
                </div>
                <div class="ap-btn-row">
                    <asp:Button ID="btnSaveProfile" runat="server"
                        Text="Save Changes" CssClass="ap-btn primary"
                        OnClick="btnSaveProfile_Click" />
                </div>
            </div>
        </div>

    </div>

    <!-- ── TAB: ACCOUNT ── -->
    <div class="ap-pane" id="tAccount">

        <div class="ap-card">
            <div class="ap-card-head">
                <div class="ap-card-title">
                    <div class="ico" style="background:#ecfdf5;color:#059669"><i class="fa fa-at"></i></div>
                    Email Address
                </div>
            </div>
            <div class="ap-card-body">
                <div class="ap-fg">
                    <div class="ap-field">
                        <label class="ap-lbl">Current Email</label>
                        <asp:TextBox ID="txtEmail" runat="server" CssClass="ap-input" ReadOnly="true" />
                    </div>
                    <div class="ap-field">
                        <label class="ap-lbl">New Email Address <span class="req">*</span></label>
                        <asp:TextBox ID="txtNewEmail" runat="server" CssClass="ap-input"
                            TextMode="Email" placeholder="new@email.com" />
                    </div>
                </div>
                <div class="ap-btn-row">
                    <asp:Button ID="btnSaveEmail" runat="server"
                        Text="Update Email" CssClass="ap-btn primary"
                        OnClick="btnSaveEmail_Click" />
                </div>
            </div>
        </div>

        <div class="ap-card" style="background:linear-gradient(135deg,#fffbeb,#fef3c7);border-color:#fde68a">
            <div class="ap-card-head" style="background:transparent">
                <div class="ap-card-title" style="color:#92400e">
                    <div class="ico" style="background:#fef3c7;color:#d97706"><i class="fa fa-exclamation-circle"></i></div>
                    Account Info (Read-only)
                </div>
            </div>
            <div class="ap-card-body">
                <div class="ap-fg cols3">
                    <div class="ap-field">
                        <label class="ap-lbl">Username</label>
                        <asp:TextBox runat="server" CssClass="ap-input" ReadOnly="true"
                            Text='<%# Session["Username"] %>' />
                    </div>
                    <div class="ap-field">
                        <label class="ap-lbl">Role</label>
                        <input type="text" class="ap-input" readonly value="<%=AdminRole%>" />
                    </div>
                    <div class="ap-field">
                        <label class="ap-lbl">Institute</label>
                        <input type="text" class="ap-input" readonly
                            value="<%=lblInstitute.Text%>" />
                    </div>
                </div>
            </div>
        </div>

    </div>

    <!-- ── TAB: SECURITY ── -->
    <div class="ap-pane" id="tSecurity">

        <div class="ap-card">
            <div class="ap-card-head">
                <div class="ap-card-title">
                    <div class="ico" style="background:#f5f3ff;color:#7c3aed"><i class="fa fa-lock"></i></div>
                    Change Password
                </div>
            </div>
            <div class="ap-card-body">
                <div class="ap-fg cols1" style="max-width:440px">
                    <div class="ap-field">
                        <label class="ap-lbl">Current Password <span class="req">*</span></label>
                        <div style="position:relative">
                            <asp:TextBox ID="txtCurrentPwd" runat="server" CssClass="ap-input"
                                TextMode="Password" placeholder="Enter current password"
                                style="padding-right:42px" />
                            <button type="button" onclick="togglePwd('<%=txtCurrentPwd.ClientID%>',this)"
                                style="position:absolute;right:12px;top:50%;transform:translateY(-50%);
                                       background:none;border:none;cursor:pointer;color:var(--dim)">
                                <i class="fa fa-eye"></i>
                            </button>
                        </div>
                    </div>
                    <div class="ap-field">
                        <label class="ap-lbl">New Password <span class="req">*</span></label>
                        <div style="position:relative">
                            <asp:TextBox ID="txtNewPwd" runat="server" CssClass="ap-input"
                                TextMode="Password" placeholder="Min 8 characters"
                                onkeyup="checkPwdStrength(this.value)"
                                style="padding-right:42px" />
                            <button type="button" onclick="togglePwd('<%=txtNewPwd.ClientID%>',this)"
                                style="position:absolute;right:12px;top:50%;transform:translateY(-50%);
                                       background:none;border:none;cursor:pointer;color:var(--dim)">
                                <i class="fa fa-eye"></i>
                            </button>
                        </div>
                        <div class="pw-strength-bar"><div class="pw-strength-fill" id="pwBar"></div></div>
                        <div class="pw-strength-label" id="pwLabel" style="color:var(--dim)">Enter a password</div>
                    </div>
                    <div class="ap-field">
                        <label class="ap-lbl">Confirm New Password <span class="req">*</span></label>
                        <asp:TextBox ID="txtConfirmPwd" runat="server" CssClass="ap-input"
                            TextMode="Password" placeholder="Re-enter new password"
                            onkeyup="checkPwdMatch()" />
                        <div id="pwMatchMsg" style="font-size:11px;margin-top:4px"></div>
                    </div>
                </div>
                <div class="ap-btn-row">
                    <asp:Button ID="btnChangePassword" runat="server"
                        Text="Change Password" CssClass="ap-btn primary"
                        OnClick="btnChangePassword_Click" />
                </div>
            </div>
        </div>

        <!-- Security Tips -->
        <div class="ap-card">
            <div class="ap-card-head">
                <div class="ap-card-title">
                    <div class="ico" style="background:#ecfdf5;color:#059669"><i class="fa fa-shield-alt"></i></div>
                    Security Tips
                </div>
            </div>
            <div class="ap-card-body">
                <div style="display:flex;flex-direction:column;gap:12px">
                    <%  string[] tips = {
                          "Use at least 8 characters with a mix of letters, numbers and symbols.",
                          "Never share your password with anyone, including support staff.",
                          "Change your password regularly — every 90 days is recommended.",
                          "Do not reuse passwords across multiple platforms.",
                          "Always log out when using a shared or public computer."
                        };
                        string[] icons = {"fa-key","fa-user-secret","fa-redo","fa-copy","fa-sign-out-alt"};
                        for(int i=0;i<tips.Length;i++){ %>
                    <div style="display:flex;align-items:flex-start;gap:10px">
                        <div style="width:28px;height:28px;border-radius:7px;background:var(--green-lt);
                                    color:var(--green);display:flex;align-items:center;justify-content:center;
                                    font-size:11px;flex-shrink:0">
                            <i class="fa <%=icons[i]%>"></i>
                        </div>
                        <div style="font-size:12px;color:var(--ink3);padding-top:6px"><%=tips[i]%></div>
                    </div>
                    <% } %>
                </div>
            </div>
        </div>

    </div>

    <!-- ── TAB: PHOTO ── -->
    <div class="ap-pane" id="tPhoto">
        <div class="ap-card">
            <div class="ap-card-head">
                <div class="ap-card-title">
                    <div class="ico" style="background:#fdf2f8;color:#db2777"><i class="fa fa-camera"></i></div>
                    Profile Photo
                </div>
            </div>
            <div class="ap-card-body">

                <div style="display:flex;gap:24px;align-items:flex-start;flex-wrap:wrap">

                    <!-- Current photo preview -->
                    <div style="text-align:center">
                        <div id="photoPreview" style="width:120px;height:120px;border-radius:50%;
                             overflow:hidden;border:3px solid var(--bdr2);margin-bottom:10px;
                             display:flex;align-items:center;justify-content:center;
                             font-family:var(--fd);font-size:36px;font-weight:800;color:#fff;
                             background:<%=AvatarBg%>">
                            <% if (HasPhoto) { %>
                                <img id="ppImg" src="<%=ResolveUrl(ProfileImagePath)%>"
                                    style="width:100%;height:100%;object-fit:cover" />
                            <% } else { %>
                                <span><%=AdminInitials%></span>
                            <% } %>
                        </div>
                        <div style="font-size:11px;color:var(--muted)">Current Photo</div>
                    </div>

                    <div style="flex:1;min-width:240px">
                        <div class="ap-photo-zone" onclick="document.getElementById('photoInput').click()">
                            <i class="fa fa-cloud-upload-alt"></i>
                            <p><b>Click to upload</b> or drag &amp; drop</p>
                            <small>PNG, JPG, WEBP — Max 2 MB</small>
                        </div>

                        <div style="margin-top:14px">
                            <asp:FileUpload ID="fuPhoto" runat="server"
                                CssClass="ap-input" style="padding:7px" />
                        </div>
                    </div>
                </div>

                <div class="ap-btn-row">
                    <asp:Button ID="btnUploadPhoto" runat="server"
                        Text="Upload Photo" CssClass="ap-btn primary"
                        OnClick="btnUploadPhoto_Click" />
                </div>
            </div>
        </div>
    </div>

    <!-- ── TAB: ACTIVITY ── -->
    <div class="ap-pane" id="tActivity">
        <div class="ap-card">
            <div class="ap-card-head">
                <div class="ap-card-title">
                    <div class="ico" style="background:#fff7ed;color:#d97706"><i class="fa fa-history"></i></div>
                    Recent Activity
                </div>
                <span style="font-size:11px;color:var(--muted)">Last 30 actions</span>
            </div>
            <div class="ap-card-body" style="max-height:500px;overflow-y:auto">
                <div class="ap-timeline">
                    <asp:Repeater ID="rptActivity" runat="server">
                        <ItemTemplate>
                            <div class="ap-tl-item">
                                <div class="ap-tl-dot" style="background:<%# ActivityColor(Eval("ActivityType")) %>">
                                    <i class="fa <%# ActivityIcon(Eval("ActivityType")) %>"></i>
                                </div>
                                <div class="ap-tl-card">
                                    <div class="ap-tl-type"><%# Eval("ActivityType") %></div>
                                    <div class="ap-tl-time">
                                        <i class="fa fa-clock me-1"></i><%# FormatDateTime(Eval("ActionTime")) %>
                                    </div>
                                </div>
                            </div>
                        </ItemTemplate>
                        <FooterTemplate>
                            <%# rptActivity.Items.Count == 0
                                ? "<div class='ap-empty-tl'><i class='fa fa-history'></i><p>No activity recorded yet</p></div>"
                                : "" %>
                        </FooterTemplate>
                    </asp:Repeater>
                </div>
            </div>
        </div>
    </div>

</div><%-- /ap-right --%>
</div><%-- /ap-layout --%>
</div><%-- /ap-root --%>

<script>
/* ── TAB SWITCHER ── */
function apSwitch(btn, pane){
    document.querySelectorAll('.ap-tab').forEach(function(b){b.classList.remove('on')});
    document.querySelectorAll('.ap-pane').forEach(function(p){p.classList.remove('on')});
    btn.classList.add('on');
    var el=document.getElementById(pane);
    if(el)el.classList.add('on');
}

/* ── TOAST ── */
var _toastTimer;
function showToast(msg,type){
    var t=document.getElementById('apToast');
    var m=document.getElementById('toastMsg');
    var i=document.getElementById('toastIcon');
    if(!t||!m)return;
    m.textContent=msg;
    t.className='ap-toast '+(type||'success')+' show';
    i.className='fa '+(type==='error'?'fa-exclamation-circle':'fa-check-circle');
    clearTimeout(_toastTimer);
    _toastTimer=setTimeout(function(){hideToast()},4000);
}
function hideToast(){
    var t=document.getElementById('apToast');
    if(t)t.classList.remove('show');
}

/* ── SHOW TOAST FROM HIDDEN FIELD (postback) ── */
document.addEventListener('DOMContentLoaded',function(){
    var msg  = document.getElementById('<%=hfToastMsg.ClientID%>');
    var type = document.getElementById('<%=hfToastType.ClientID%>');
    if(msg&&msg.value) showToast(msg.value, type?type.value:'success');
});

/* ── PASSWORD STRENGTH ── */
function checkPwdStrength(val){
    var bar=document.getElementById('pwBar');
    var lbl=document.getElementById('pwLabel');
    if(!bar||!lbl)return;
    var score=0;
    if(val.length>=8)score++;
    if(/[A-Z]/.test(val))score++;
    if(/[0-9]/.test(val))score++;
    if(/[^A-Za-z0-9]/.test(val))score++;
    var map=[
        {w:'0%',  c:'transparent',l:'Enter a password',   lc:'var(--dim)'},
        {w:'25%', c:'#ef4444',    l:'Weak',               lc:'#ef4444'},
        {w:'50%', c:'#f97316',    l:'Fair',               lc:'#f97316'},
        {w:'75%', c:'#f59e0b',    l:'Good',               lc:'#d97706'},
        {w:'100%',c:'#059669',    l:'Strong ✓',           lc:'#059669'}
    ];
    var s=map[score]||map[0];
    bar.style.width=s.w;bar.style.background=s.c;
    lbl.textContent=s.l;lbl.style.color=s.lc;
}

/* ── PASSWORD MATCH CHECK ── */
function checkPwdMatch(){
    var n=document.getElementById('<%=txtNewPwd.ClientID%>');
    var c=document.getElementById('<%=txtConfirmPwd.ClientID%>');
    var d=document.getElementById('pwMatchMsg');
    if(!n||!c||!d)return;
    if(c.value===''){d.textContent='';return;}
    if(n.value===c.value){
        d.textContent='✓ Passwords match';d.style.color='#059669';
    }else{
        d.textContent='✗ Passwords do not match';d.style.color='#dc2626';
    }
}

/* ── TOGGLE PASSWORD VISIBILITY ── */
function togglePwd(id,btn){
    var inp=document.getElementById(id);
    if(!inp)return;
    if(inp.type==='password'){
        inp.type='text';
        btn.innerHTML='<i class="fa fa-eye-slash"></i>';
    }else{
        inp.type='password';
        btn.innerHTML='<i class="fa fa-eye"></i>';
    }
}

/* ── PHOTO PREVIEW ── */
function previewPhoto(input){
    if(!input.files||!input.files[0])return;
    var reader=new FileReader();
    reader.onload=function(e){
        var pp=document.getElementById('photoPreview');
        var ppi=document.getElementById('ppImg');
        var av=document.getElementById('avatarEl');
        if(pp){
            pp.innerHTML='<img style="width:100%;height:100%;object-fit:cover" src="'+e.target.result+'" />';
        }
        if(av){
            av.innerHTML='<img src="'+e.target.result+'" style="width:100%;height:100%;object-fit:cover" />'
                +'<div class="ap-photo-overlay"><i class="fa fa-camera"></i></div>';
        }
        // Copy to FileUpload control
        try{
            var fu=document.getElementById('<%=fuPhoto.ClientID%>');
            if(fu){
                var dt=new DataTransfer();
                dt.items.add(input.files[0]);
                fu.files=dt.files;
            }
        }catch(ex){}
    };
    reader.readAsDataURL(input.files[0]);
}
</script>

</asp:Content>
