<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="RegisterUser.aspx.cs" Inherits="LMS.RegisterUser" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Join Us | Create LMS Account</title>
    
    
    <link rel="shortcut icon" href="assets/images/book.png" type="image/x-icon">
    <link href="./assets/css/bootstrap.min.css" rel="stylesheet" />
    <link href="./assets/icons/fontawesome/css/all.min.css" rel="stylesheet" />
    <link href="./assets/css/style.css" rel="stylesheet" />

    <style>
        :root {
            --glass-bg: rgba(255, 255, 255, 0.12);
            --glass-border: rgba(255, 255, 255, 0.25);
            --primary-accent: #00d2ff;
            --secondary-accent: #3a7bd5;
        }

        body, html {
            margin: 0;
            padding: 0;
            height: 100%;
            font-family: system-ui, -apple-system, "Segoe UI", Roboto, sans-serif;
            background: #0f172a;
            overflow: hidden;
        }

        /* Animated Mesh Background (Matches Login) */
        .mesh-gradient {
            position: fixed;
            top: 0; left: 0; width: 100%; height: 100%;
            background: 
                radial-gradient(at 0% 0%, hsla(210, 100%, 20%, 1) 0, transparent 50%), 
                radial-gradient(at 50% 0%, hsla(205, 100%, 30%, 1) 0, transparent 50%), 
                radial-gradient(at 100% 0%, hsla(220, 100%, 25%, 1) 0, transparent 50%),
                radial-gradient(at 0% 100%, hsla(190, 100%, 35%, 1) 0, transparent 50%),
                radial-gradient(at 100% 100%, hsla(230, 100%, 20%, 1) 0, transparent 50%);
            z-index: -1;
        }

        .main-wrapper {
            display: flex;
            height: 100vh;
            align-items: center;
            justify-content: center;
            background: url('assets/images/bgImg.png') no-repeat center center;
            background-size: cover;
            position: relative;
        }

        .overlay {
            position: absolute;
            top: 0; left: 0; width: 100%; height: 100%;
            background: rgba(15, 23, 42, 0.65);
            backdrop-filter: saturate(1.2);
        }

        /* Glass Card */
        .signup-card {
            background: var(--glass-bg);
            backdrop-filter: blur(25px) saturate(150%);
            -webkit-backdrop-filter: blur(25px) saturate(150%);
            border: 1px solid var(--glass-border);
            border-radius: 24px;
            padding: 2.5rem;
            width: 100%;
            max-width: 500px;
            height: 90vh;
            max-height: 800px;
            display: flex;
            flex-direction: column;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
            z-index: 10;
        }

        .brand-logo {
            font-size: 1.25rem;
            font-weight: 800;
            color: #fff;
            margin-bottom: 1.5rem;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .brand-logo img { height: 30px; }

        h2 { color: #fff; font-weight: 700; font-size: 1.75rem; margin-bottom: 0.5rem; }
        p.subtitle { color: rgba(255, 255, 255, 0.6); font-size: 0.9rem; margin-bottom: 1.5rem; }

        /* Scrollable Body Section */
        .signup-body {
            overflow-y: auto;
            flex: 1;
            padding-right: 10px;
            margin-bottom: 1rem;
        }

        /* Custom Scrollbar for the Glass Card */
        .signup-body::-webkit-scrollbar { width: 5px; }
        .signup-body::-webkit-scrollbar-track { background: rgba(255, 255, 255, 0.05); }
        .signup-body::-webkit-scrollbar-thumb { background: rgba(255, 255, 255, 0.2); border-radius: 10px; }

        .label-custom {
            color: rgba(255, 255, 255, 0.8);
            font-size: 0.7rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 1px;
            margin-bottom: 0.4rem;
            display: block;
        }

        /* Glass Input Styles */
        .form-control-glass, .form-select-glass {
            background: rgba(255, 255, 255, 0.07) !important;
            border: 1px solid rgba(255, 255, 255, 0.1) !important;
            border-radius: 10px !important;
            padding: 12px 15px !important;
            color: black !important;
            font-size: 0.95rem;
            transition: all 0.3s ease;
        }

        .form-control-glass:focus, .form-select-glass:focus {
            border-color: var(--primary-accent) !important;
            box-shadow: 0 0 0 4px rgba(0, 210, 255, 0.15) !important;
            outline: none;
        }

        /* Fix for select arrow color */
/*        .form-select-glass {
            background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 16 16'%3e%3cpath fill='none' stroke='rgba(255,255,255,0.5)' stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='m2 5 6 6 6-6'/%3e%3c/svg%3e") !important;
        }*/

        .btn-premium {
/*            background: linear-gradient(135deg, var(--primary-accent), var(--secondary-accent));*/
            background: linear-gradient(135deg, hsla(220, 90%, 25%, 1), #1976d2);
            border: none;
            border-radius: 12px;
            padding: 14px;
            color: white;
            font-weight: 700;
            width: 100%;
            box-shadow: 0 10px 20px -5px rgba(0, 210, 255, 0.4);
            transition: all 0.3s ease;
        }

        .btn-premium:hover { transform: translateY(-2px); filter: brightness(1.1); }

        .footer-text { text-align: center; margin-top: 1rem; color: rgba(255, 255, 255, 0.5); font-size: 0.85rem; }
        .footer-text a { color: #fff; text-decoration: none; font-weight: 700; }

        @media (max-width: 480px) {
            .signup-card { height: 100vh; max-height: 100vh; border-radius: 0; padding: 1.5rem; }
        }
    </style>
</head>
<body>
    <div class="mesh-gradient"></div>
    <div class="main-wrapper">
        <div class="overlay"></div>

        <form id="form1" runat="server">
            <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>

            <div class="signup-card">
                <div class="brand-logo">
                    <img src="assets/images/book.png" alt="Logo">
                    <span>Please Create an Account</span>
                </div>

                <h2>Create Account</h2>
                <p class="subtitle">Join our community and start learning.</p>

               <%-- <asp:Label ID="lblMsg" runat="server" CssClass="alert d-block py-2 text-center border-0 mb-3" 
                    style="background: rgba(220, 53, 69, 0.2); color: #ff8e98; border-radius: 8px; font-size: 0.85rem;" Visible="false"></asp:Label>--%>

                <asp:Label ID="lblMsg" runat="server" CssClass="alert alert-danger d-block py-2 text-center border-0 mb-4" 
                style="background: rgba(220, 53, 69, 0.2); color: #ff8e98; border-radius: 8px;" Visible="false"></asp:Label>

                <div class="signup-body">
                    <asp:UpdatePanel ID="updSelection" runat="server">
                        <ContentTemplate>
                            <div class="mb-3">
                                <label class="label-custom">Society Name</label>
                                <asp:DropDownList ID="ddlSociety" runat="server" AutoPostBack="true"
                                    CssClass="form-select form-select-glass" OnSelectedIndexChanged="ddlSociety_SelectedIndexChanged">
                                </asp:DropDownList>
                            </div>

                            <div class="mb-3">
                                <label class="label-custom">Institute Name</label>
                                <asp:DropDownList ID="ddlInstitute" runat="server" CssClass="form-select form-select-glass">
                                    <asp:ListItem Text="-- Select Society First --" Value="0"></asp:ListItem>
                                </asp:DropDownList>
                            </div>
                        </ContentTemplate>
                    </asp:UpdatePanel>

                    <div class="mb-3">
                        <label class="label-custom">Username</label>
                        <asp:TextBox ID="txtUsername" runat="server" CssClass="form-control form-control-glass" Placeholder="Pick a unique name" />
                    </div>

                    <div class="mb-3">
                        <label class="label-custom">Email Address</label>
                        <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control form-control-glass" Placeholder="name@institution.com" />
                    </div>

                    <div class="mb-3">
                        <label class="label-custom">Password</label>
                        <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" CssClass="form-control form-control-glass" Placeholder="Strong password" />
                    </div>

                    <div class="mb-2">
                        <label class="label-custom">Confirm Password</label>
                        <asp:TextBox ID="txtConfirm" runat="server" TextMode="Password" CssClass="form-control form-control-glass" Placeholder="Repeat password" />
                    </div>
                </div>

                <div class="signup-footer">
                    <asp:Button ID="btnRegister" runat="server" Text="Create My Account"
                        CssClass="btn-premium" OnClick="btnRegister_Click" />
                    
                    <div class="footer-text">
                        Already have an account? <a href="Default.aspx">Sign In</a>
                    </div>
                </div>
            </div>
        </form>
    </div>

    <script src="./assets/js/jquery-3.6.0.min.js"></script>
    <script src="./assets/js/bootstrap.bundle.min.js"></script>
</body>
</html>