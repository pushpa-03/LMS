<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="LMS.Default" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Login</title>

    <!-- Stylesheets -->
    <link rel="shortcut icon" href="assets/images/favicon.ico" type="image/x-icon">
    <link href="assets/css/bootstrap.min.css" rel="stylesheet">
    <link href="assets/icons/fontawesome/css/fontawesome.min.css" rel="stylesheet">
    <link href="assets/icons/fontawesome/css/brands.min.css" rel="stylesheet">
    <link href="assets/icons/fontawesome/css/solid.min.css" rel="stylesheet">
    <link href="assets/plugin/quill/quill.snow.css" rel="stylesheet">
    <link href="assets/css/style.css" rel="stylesheet">

    <style>
        body {
            background: url('assets/images/bgImg.jpeg') no-repeat center center fixed;
            background-size: cover;
        }

        .password-eye {
            position: absolute;
            right: 15px;
            top: 50%;
            transform: translateY(-50%);
            cursor: pointer;
            color: #6c757d;
            z-index: 5;
        }

        .form-control.pe-5 {
            padding-right: 45px;
        }
    </style>
</head>

<body>
    <form id="form1" runat="server">

        <div class="container">
            <div class="row justify-content-center min-vh-100 align-items-center">
                <div class="col-11 col-sm-8 col-md-8 col-lg-4">

                    <div class="bg-white rounded-4 shadow-sm p-4">

                        <!-- Logo -->
                        <div class="text-center mb-4">
                            <div class="d-flex align-items-center justify-content-center gap-2">
                                <img src="assets/images/logo.png" alt="logo">
                            </div>
                        </div>

                        <!-- Heading -->
                        <h2 class="mb-4 text-dark h4">Sign In</h2>

                        <!-- Message -->
                        <asp:Label ID="lblMsg"
                            runat="server"
                            CssClass="text-danger small mb-3 d-block">
                        </asp:Label>

                        <!-- Username -->
                        <div class="mb-3 position-relative">
                            <label class="form-label text-muted small">UserName</label>

                            <div class="position-relative">

                                <asp:TextBox
                                    ID="txtUsername"
                                    runat="server"
                                    CssClass="form-control form-control-lg rounded-3"
                                    Placeholder="Enter UserName">
                                </asp:TextBox>

                            </div>
                        </div>

                        <!-- Password -->
                        <div class="mb-4 position-relative">

                            <label class="form-label text-muted small">
                                Password
                            </label>

                            <div class="position-relative">

                                <asp:TextBox
                                    ID="txtPassword"
                                    runat="server"
                                    TextMode="Password"
                                    CssClass="form-control form-control-lg rounded-3 pe-5"
                                    Placeholder="Enter Password">
                                </asp:TextBox>

                                <!-- eye icon -->
                                <i class="fas fa-eye password-eye"
                                    id="togglePassword"></i>

                            </div>

                        </div>


                        <!-- Remember + Forgot -->
                        <div class="row mb-4">

                            <div class="col-12 col-lg-6 mb-2 mb-lg-0">

                                <div class="form-check ps-0">

                                    <asp:CheckBox
                                        ID="chkRemember"
                                        runat="server" />

                                    <label class="form-check-label">
                                        Remember me
                                    </label>

                                </div>

                            </div>


                            <div class="col-12 col-lg-6 text-lg-end">

                                <a href="ForgotPassword.aspx"
                                    class="text-primary">Forgot password
                                </a>

                            </div>

                        </div>


                        <!-- Login button -->
                        <asp:Button
                            ID="btnLogin"
                            runat="server"
                            Text="Sign In"
                            CssClass="btn btn-signin btn-lg w-100 rounded-3 mb-4"
                            OnClick="btnLogin_Click" />


                        <!-- Register -->
                        <div class="text-center text-muted mb-4 text-size-14">
                            Don't have an account yet?

                        <a href="RegisterUser.aspx"
                            class="text-primary">Sign Up
                        </a>

                        </div>

                    </div>

                </div>
            </div>
        </div>

    </form>


    <!-- Scripts -->
    <script src="assets/js/jquery-3.6.0.min.js"></script>
    <script src="assets/js/bootstrap.bundle.min.js"></script>
    <script src="assets/plugin/chart/chart.js"></script>
    <script src="assets/plugin/quill/quill.js"></script>
    <script src="assets/js/chart.js"></script>
    <script src="assets/js/main.js"></script>


    <!-- Password Toggle Script -->
    <script>

        const togglePassword =
            document.getElementById("togglePassword");

        const passwordBox =
            document.getElementById("<%= txtPassword.ClientID %>");


        togglePassword.addEventListener("click", function () {

            if (passwordBox.type === "password") {
                passwordBox.type = "text";

                this.classList.remove("fa-eye");

                this.classList.add("fa-eye-slash");
            }
            else {
                passwordBox.type = "password";

                this.classList.remove("fa-eye-slash");

                this.classList.add("fa-eye");
            }

        });

    </script>


</body>
</html>