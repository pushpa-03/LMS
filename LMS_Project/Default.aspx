<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="LMS.Default" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>LMS | Advanced Learning Portal</title>

    <link rel="shortcut icon" href="assets/images/book.png" type="image/x-icon">
    <link href="assets/css/bootstrap.min.css" rel="stylesheet">
    <link href="assets/icons/fontawesome/css/fontawesome.min.css" rel="stylesheet">
    <link href="assets/icons/fontawesome/css/solid.min.css" rel="stylesheet">

    <style>
        :root {
            --glass-bg: rgba(255, 255, 255, 0.12);
            --glass-border: rgba(255, 255, 255, 0.25);
            --primary-accent: #00d2ff;
            --secondary-accent: #3a7bd5;
            --text-light: #f8f9fa;
        }

        body, html {
            margin: 0;
            padding: 0;
            height: 100%;
            font-family: system-ui, -apple-system, "Segoe UI", Roboto, sans-serif;
            background: #0f172a; /* Deep base color */
            overflow: hidden;
        }

        /* Stunning Animated Mesh Background */
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
        }

        /* Overlay to blend the image with the mesh gradient */
        .overlay {
            position: absolute;
            top: 0; left: 0; width: 100%; height: 100%;
            background: rgba(15, 23, 42, 0.65); /* Dark tint */
            backdrop-filter: saturate(1.2);
        }

        .login-card {
            background: var(--glass-bg);
            backdrop-filter: blur(25px) saturate(150%);
            -webkit-backdrop-filter: blur(25px) saturate(150%);
            border: 1px solid var(--glass-border);
            border-radius: 24px;
            padding: 3rem;
            width: 100%;
            max-width: 450px;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
            z-index: 10;
            transition: transform 0.3s ease;
        }

        .login-card:hover {
            border: 1px solid rgba(255, 255, 255, 0.4);
        }

        .brand-logo {
            font-size: 1.5rem;
            font-weight: 800;
            color: #fff;
            letter-spacing: -0.5px;
            margin-bottom: 2rem;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .brand-logo img { height: 35px; }

        h2 {
            color: #fff;
            font-weight: 700;
            margin-bottom: 0.5rem;
            font-size: 2rem;
        }

        p.subtitle {
            color: rgba(255, 255, 255, 0.6);
            font-size: 0.95rem;
            margin-bottom: 2.5rem;
        }

        .label-custom {
            color: rgba(255, 255, 255, 0.8);
            font-size: 0.75rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 1px;
            margin-bottom: 0.5rem;
            display: block;
        }

        .input-wrapper {
            position: relative;
            margin-bottom: 1.5rem;
        }

        .form-control-glass {
            background: rgba(255, 255, 255, 0.07);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 12px;
            padding: 14px 18px;
            color: #fff !important;
            font-size: 1rem;
            transition: all 0.3s ease;
        }

        .form-control-glass:focus {
            background: rgba(255, 255, 255, 0.12);
            border-color: var(--primary-accent);
            box-shadow: 0 0 0 4px rgba(0, 210, 255, 0.15);
            outline: none;
        }

        .form-control-glass::placeholder {
            color: rgba(255, 255, 255, 0.3);
        }

        .password-eye {
            position: absolute;
            right: 18px;
            top: 50%;
            transform: translateY(-50%);
            color: rgba(255, 255, 255, 0.5);
            cursor: pointer;
            z-index: 10;
        }

        .btn-premium {
/*            background: linear-gradient(135deg, var(--primary-accent), var(--secondary-accent));*/
            background: linear-gradient(135deg, hsla(220, 90%, 25%, 1), #1976d2);
            border: none;
            border-radius: 12px;
            padding: 14px;
            color: white;
            font-weight: 700;
            font-size: 1rem;
            width: 100%;
            margin-top: 1rem;
            box-shadow: 0 10px 20px -5px rgba(0, 210, 255, 0.4);
            transition: all 0.3s ease;
        }

        .btn-premium:hover {
            transform: translateY(-2px);
            box-shadow: 0 15px 25px -5px rgba(0, 210, 255, 0.5);
            filter: brightness(1.1);
        }

        .form-check-label {
            color: rgba(255, 255, 255, 0.7);
            font-size: 0.9rem;
            cursor: pointer;
        }

        .forgot-link {
            color: #516ff8;
            text-decoration: none;
            font-size: 0.9rem;
            font-weight: 1000;
        }

        .forgot-link:hover { text-decoration: underline; }

        .footer-text {
            text-align: center;
            margin-top: 2rem;
            color: rgba(255, 255, 255, 0.5);
            font-size: 0.9rem;
        }

        .footer-text a {
            color: #fff;
            text-decoration: none;
            font-weight: 700;
        }

        /* Hide branding on very small screens to keep card clean */
        @media (max-width: 480px) {
            .login-card { padding: 2rem; border-radius: 0; height: 100vh; max-width: 100%; border: none; }
        }
    </style>
</head>
<body>
    <div class="mesh-gradient"></div>
    <div class="main-wrapper">
        <div class="overlay"></div>
        
        <form id="form1" runat="server">
            <div class="login-card">
                <div class="brand-logo">
                    <img src="assets/images/book.png" alt="Logo">
                    <span>Please Login here</span>
                </div>

                <h2>Welcome Back</h2>
                <p class="subtitle">Please enter your details to sign in.</p>

                <asp:Label ID="lblMsg" runat="server" CssClass="alert alert-danger d-block py-2 text-center border-0 mb-4" 
                    style="background: rgba(220, 53, 69, 0.2); color: #ff8e98; border-radius: 8px;" Visible="false"></asp:Label>

                <div class="input-group-custom">
                    <label class="label-custom">Username / Email</label>
                    <div class="input-wrapper">
                        <asp:TextBox ID="txtUsername" runat="server" CssClass="form-control-glass w-100" placeholder="e.g. admin@school.com"></asp:TextBox>
                    </div>
                </div>

                <div class="input-group-custom">
                    <label class="label-custom">Password</label>
                    <div class="input-wrapper">
                        <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" CssClass="form-control-glass w-100" placeholder="••••••••"></asp:TextBox>
                        <i class="fas fa-eye password-eye" id="togglePassword"></i>
                    </div>
                </div>

                <div class="d-flex justify-content-between align-items-center mb-4">
                    <div class="form-check">
                        <asp:CheckBox ID="chkRemember" runat="server" CssClass="form-check-input" />
                        <asp:Label runat="server" AssociatedControlID="chkRemember" CssClass="form-check-label ms-2">Remember me</asp:Label>
                    </div>
                    <a href="ForgotPassword.aspx" class="forgot-link">Forgot?</a>
                </div>

                <asp:Button ID="btnLogin" runat="server" Text="Sign In to Portal" CssClass="btn-premium" OnClick="btnLogin_Click" />

                <div class="footer-text">
                    New user? <a href="RegisterUser.aspx">Create an account</a>
                </div>
            </div>
        </form>
    </div>

    <script src="assets/js/jquery-3.6.0.min.js"></script>
    <script>
        $(document).ready(function () {
            const togglePassword = document.getElementById("togglePassword");
            const passwordBox = document.querySelector('input[id$="txtPassword"]');

            togglePassword.addEventListener("click", function () {
                const type = passwordBox.getAttribute("type") === "password" ? "text" : "password";
                passwordBox.setAttribute("type", type);
                this.classList.toggle("fa-eye");
                this.classList.toggle("fa-eye-slash");
            });
        });
    </script>
</body>
</html>