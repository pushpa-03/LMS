<%@ Page Title="Change Password" Language="C#"
    MasterPageFile="~/Student/StudentMaster.Master"
    AutoEventWireup="true"
    CodeBehind="ChangePassword.aspx.cs"
    Inherits="LMS_Project.Student.ChangePassword" %>

<asp:Content ID="cHead" ContentPlaceHolderID="head" runat="server">
<style>

.cp-wrapper {
    max-width: 500px;
    margin: 0 auto;
}

.cp-card {
    background:#fff; border-radius:16px;
    box-shadow:0 4px 20px rgba(0,0,0,.08);
    overflow:hidden;
}

.cp-header {
    background:linear-gradient(135deg,#1565c0,#1976d2);
    padding:24px 28px; color:#fff;
}
.cp-header h5 { margin:0; font-weight:800; font-size:18px; }
.cp-header p  { margin:6px 0 0; font-size:13px; opacity:.85; }

.cp-body { padding:28px; }

.cp-group { margin-bottom:18px; }
.cp-group label {
    font-size:12px; font-weight:700; color:#546e7a;
    display:block; margin-bottom:6px;
    text-transform:uppercase; letter-spacing:.4px;
}
.cp-input-wrap { position:relative; }
.cp-input-wrap input {
    width:100%; padding:11px 42px 11px 14px;
    border:1.5px solid #e3e8f0; border-radius:10px;
    font-size:14px; color:#263238; outline:none;
    background:#f8fbff; transition:border .2s;
    box-sizing:border-box;
}
.cp-input-wrap input:focus { border-color:#1565c0; background:#fff; }
.cp-eye-btn {
    position:absolute; right:12px; top:50%;
    transform:translateY(-50%);
    background:none; border:none; cursor:pointer;
    color:#90a4ae; font-size:14px;
    padding:0; transition:color .2s;
}
.cp-eye-btn:hover { color:#1565c0; }

/* Password strength */
.strength-bar-wrap { margin-top:6px; }
.strength-bar-track {
    height:4px; background:#e8f0fe; border-radius:2px; overflow:hidden;
}
.strength-bar-fill { height:100%; border-radius:2px; transition:all .3s; width:0; }
.strength-label {
    font-size:11px; font-weight:700; margin-top:3px;
}
.str-weak   { color:#c62828; }
.str-fair   { color:#f57f17; }
.str-good   { color:#1976d2; }
.str-strong { color:#2e7d32; }

/* Rules checklist */
.pwd-rules { margin-top:10px; display:flex; flex-direction:column; gap:4px; }
.pwd-rule {
    font-size:12px; color:#90a4ae;
    display:flex; align-items:center; gap:6px;
    transition:color .2s;
}
.pwd-rule.met { color:#2e7d32; }
.pwd-rule i   { font-size:11px; }

/* Buttons */
.btn-change-pwd {
    width:100%; padding:12px;
    background:linear-gradient(135deg,#1565c0,#1976d2);
    color:#fff; border:none; border-radius:10px;
    font-size:14px; font-weight:700; cursor:pointer;
    transition:opacity .2s; margin-top:4px;
}
.btn-change-pwd:hover { opacity:.88; }
.btn-change-pwd:disabled {
    background:#cfd8dc; cursor:not-allowed; opacity:1;
}

/* First-login banner */
.first-login-banner {
    background:#fff3e0; border:1.5px solid #ffcc80;
    border-radius:10px; padding:12px 16px;
    font-size:13px; color:#e65100;
    margin-bottom:20px;
    display:flex; align-items:flex-start; gap:10px;
}
.first-login-banner i { margin-top:2px; flex-shrink:0; }

/* Alert */
.cp-alert {
    padding:10px 16px; border-radius:9px;
    font-size:13px; font-weight:600; margin-bottom:16px;
}
.cp-success { background:#e8f5e9; color:#2e7d32; border:1.5px solid #a5d6a7; }
.cp-error   { background:#ffebee; color:#c62828; border:1.5px solid #ef9a9a; }

</style>
</asp:Content>

<asp:Content ID="cBody" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<div class="cp-wrapper">

    <%-- First-login warning --%>
    <asp:Panel ID="pnlFirstLogin" runat="server" Visible="false">
        <div class="first-login-banner">
            <i class="fas fa-exclamation-triangle"></i>
            <div>
                <strong>Action Required:</strong> You must change your password
                before continuing. Your current password was set by the admin.
            </div>
        </div>
    </asp:Panel>

    <div class="cp-card">

        <div class="cp-header">
            <h5><i class="fas fa-key me-2"></i>Change Password</h5>
            <p>Keep your account secure with a strong password.</p>
        </div>

        <div class="cp-body">

            <asp:Label ID="lblMsg" runat="server" Visible="false" CssClass="cp-alert d-block" />

            <%-- Current password (hidden on first login) --%>
            <asp:Panel ID="pnlCurrentPwd" runat="server">
                <div class="cp-group">
                    <label>Current Password</label>
                    <div class="cp-input-wrap">
                        <asp:TextBox ID="txtCurrentPwd" runat="server"
                            TextMode="Password" CssClass="form-control"
                            placeholder="Enter current password"
                            style="padding:11px 42px 11px 14px;border:1.5px solid #e3e8f0;
                                   border-radius:10px;font-size:14px;width:100%;
                                   box-sizing:border-box;outline:none;background:#f8fbff;" />
                        <button type="button" class="cp-eye-btn" onclick="toggleEye('txtCurrentPwd', this)">
                            <i class="fas fa-eye"></i>
                        </button>
                    </div>
                </div>
            </asp:Panel>

            <%-- New password --%>
            <div class="cp-group">
                <label>New Password</label>
                <div class="cp-input-wrap">
                    <asp:TextBox ID="txtNewPwd" runat="server"
                        TextMode="Password"
                        placeholder="Enter new password"
                        oninput="checkStrength(this.value)"
                        style="width:100%;padding:11px 42px 11px 14px;
                               border:1.5px solid #e3e8f0;border-radius:10px;
                               font-size:14px;box-sizing:border-box;
                               outline:none;background:#f8fbff;" />
                    <button type="button" class="cp-eye-btn" onclick="toggleEye('txtNewPwd', this)">
                        <i class="fas fa-eye"></i>
                    </button>
                </div>

                <%-- Strength bar --%>
                <div class="strength-bar-wrap">
                    <div class="strength-bar-track">
                        <div class="strength-bar-fill" id="strengthBar"></div>
                    </div>
                    <div class="strength-label" id="strengthLabel"></div>
                </div>

                <%-- Rules --%>
                <div class="pwd-rules">
                    <div class="pwd-rule" id="rule-len">
                        <i class="fas fa-circle"></i> At least 8 characters
                    </div>
                    <div class="pwd-rule" id="rule-upper">
                        <i class="fas fa-circle"></i> One uppercase letter
                    </div>
                    <div class="pwd-rule" id="rule-num">
                        <i class="fas fa-circle"></i> One number
                    </div>
                    <div class="pwd-rule" id="rule-special">
                        <i class="fas fa-circle"></i> One special character
                    </div>
                </div>
            </div>

            <%-- Confirm password --%>
            <div class="cp-group">
                <label>Confirm New Password</label>
                <div class="cp-input-wrap">
                    <asp:TextBox ID="txtConfirmPwd" runat="server"
                        TextMode="Password"
                        placeholder="Re-enter new password"
                        oninput="checkMatch()"
                        style="width:100%;padding:11px 42px 11px 14px;
                               border:1.5px solid #e3e8f0;border-radius:10px;
                               font-size:14px;box-sizing:border-box;
                               outline:none;background:#f8fbff;" />
                    <button type="button" class="cp-eye-btn" onclick="toggleEye('txtConfirmPwd', this)">
                        <i class="fas fa-eye"></i>
                    </button>
                </div>
                <div id="matchMsg" style="font-size:12px;font-weight:700;margin-top:4px;"></div>
            </div>

            <asp:Button ID="btnChange" runat="server"
                Text="Change Password"
                CssClass="btn-change-pwd"
                OnClick="btnChange_Click"
                OnClientClick="return validateForm();" />

        </div>
    </div>

    <div style="text-align:center;margin-top:14px;">
        <a href="Profile.aspx" style="font-size:13px;color:#78909c;text-decoration:none;">
            <i class="fas fa-arrow-left me-1"></i>Back to Profile
        </a>
    </div>

</div>

<script>
// ── Toggle password visibility ────────────────────────────
function toggleEye(controlId, btn) {
    var inp = document.getElementById('<%= txtCurrentPwd.ClientID %>');
    // find the right input
    var inputs = btn.closest('.cp-input-wrap').querySelectorAll('input');
    inputs.forEach(function(i) {
        i.type = i.type === 'password' ? 'text' : 'password';
    });
    var icon = btn.querySelector('i');
    icon.className = icon.className.includes('fa-eye-slash')
        ? 'fas fa-eye' : 'fas fa-eye-slash';
}

// ── Password strength checker ─────────────────────────────
function checkStrength(val) {
    var bar   = document.getElementById('strengthBar');
    var label = document.getElementById('strengthLabel');

    var rules = {
        len:     val.length >= 8,
        upper:   /[A-Z]/.test(val),
        num:     /[0-9]/.test(val),
        special: /[^A-Za-z0-9]/.test(val)
    };

    // Update rule indicators
    setRule('rule-len',     rules.len);
    setRule('rule-upper',   rules.upper);
    setRule('rule-num',     rules.num);
    setRule('rule-special', rules.special);

    var score = Object.values(rules).filter(Boolean).length;
    var configs = [
        { width:'0%',   color:'',        cls:'',          text:'' },
        { width:'25%',  color:'#c62828', cls:'str-weak',  text:'Weak' },
        { width:'50%',  color:'#f57f17', cls:'str-fair',  text:'Fair' },
        { width:'75%',  color:'#1976d2', cls:'str-good',  text:'Good' },
        { width:'100%', color:'#2e7d32', cls:'str-strong',text:'Strong' }
    ];
    var cfg = configs[score];
    bar.style.width      = cfg.width;
    bar.style.background = cfg.color;
    label.textContent    = cfg.text;
    label.className      = 'strength-label ' + cfg.cls;

    checkMatch();
}

function setRule(id, met) {
    var el   = document.getElementById(id);
    var icon = el.querySelector('i');
    el.className  = 'pwd-rule' + (met ? ' met' : '');
    icon.className = met ? 'fas fa-check-circle' : 'fas fa-circle';
}

// ── Confirm match ──────────────────────────────────────────
function checkMatch() {
    var np = document.getElementById('<%= txtNewPwd.ClientID %>').value;
    var cp = document.getElementById('<%= txtConfirmPwd.ClientID %>').value;
    var msg = document.getElementById('matchMsg');
    if (!cp) { msg.textContent = ''; return; }
    if (np === cp) {
        msg.style.color = '#2e7d32';
        msg.textContent = '✓ Passwords match';
    } else {
        msg.style.color = '#c62828';
        msg.textContent = '✗ Passwords do not match';
    }
}

// ── Validate before submit ────────────────────────────────
function validateForm() {
    var np = document.getElementById('<%= txtNewPwd.ClientID %>').value;
    var cp = document.getElementById('<%= txtConfirmPwd.ClientID %>').value;

    if (np.length < 8) {
        alert('Password must be at least 8 characters.');
        return false;
    }
    if (np !== cp) {
        alert('Passwords do not match.');
        return false;
    }
    return true;
}
</script>

</asp:Content>
