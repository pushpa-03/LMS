<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="RegisterUser.aspx.cs" Inherits="LMS.RegisterUser" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Signup</title>
    <link href="./assets/css/bootstrap.min.css" rel="stylesheet" />
    <link href="./assets/icons/fontawesome/css/all.min.css" rel="stylesheet" />
    <link href="./assets/css/style.css" rel="stylesheet" />
    <style>
        body {
            background: url('assets/images/bgImg.jpeg') no-repeat center center fixed;
            background-size: cover;
        }

        .signup-card {
            height: 85vh;
            max-height: 720px;
            display: flex;
            flex-direction: column;
        }

        .signup-body {
            overflow-y: auto;
            flex: 1;
            padding-right: 4px;
        }
    </style>
</head>
<body>
    <form runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
        <div class="container">
            <div class="row justify-content-center align-items-center min-vh-100">
                <div class="col-11 col-sm-8 col-md-8 col-lg-4">
                    <div class="bg-white rounded-4 shadow-sm p-4 signup-card ">
                        <!-- Logo (UNCHANGED) -->
                        <div class="text-center mb-4">
                            <div class="d-flex align-items-center justify-content-center gap-2">
                                <img src="assets/images/logo.png" alt="logo">
                            </div>
                        </div>
                        <!-- Heading -->
                        <h2 class="mb-4 text-dark h4">Sign Up</h2>

                        <asp:Label ID="lblMsg" runat="server" CssClass="text-danger small mb-3 d-block"></asp:Label>

                        <div class="signup-body">
                            <asp:UpdatePanel ID="updSelection" runat="server">
                                <ContentTemplate>
                                    <div class="mb-3 position-relative">
                                        <label class="form-label text-muted small">Society Name</label>
                                        <asp:DropDownList ID="ddlSociety" runat="server" AutoPostBack="true"
                                            CssClass="form-select form-select-xs" OnSelectedIndexChanged="ddlSociety_SelectedIndexChanged">
                                        </asp:DropDownList>
                                    </div>

                                    <div class="mb-3 position-relative">
                                        <label class="form-label text-muted small">Institute Name</label>
                                        <asp:DropDownList ID="ddlInstitute" runat="server" CssClass="form-select form-select-xs">
                                            <asp:ListItem Text="-- Select Society First --" Value="0"></asp:ListItem>
                                        </asp:DropDownList>
                                    </div>
                                </ContentTemplate>
                            </asp:UpdatePanel>

                            <div class="mb-3 position-relative">
                                <label class="form-label text-muted small">Username</label>
                                <div class="position-relative">
                                    <asp:TextBox ID="txtUsername" runat="server"
                                        CssClass="form-control form-control-lg rounded-3"
                                        Placeholder="Enter UserName" />
                                </div>
                            </div>

                            <div class="mb-3 position-relative">
                                <label class="form-label text-muted small">Email</label>
                                <div class="position-relative">
                                    <asp:TextBox ID="txtEmail" runat="server"
                                        CssClass="form-control form-control-lg rounded-3"
                                        Placeholder="Enter Email" />
                                </div>
                            </div>

                            <div class="mb-4 position-relative">
                                <label class="form-label text-muted small">Password</label>
                                <div class="position-relative">
                                    <asp:TextBox ID="txtPassword" runat="server"
                                        TextMode="Password"
                                        CssClass="form-control form-control-lg rounded-3"
                                        Placeholder="Enter Password" />
                                </div>
                            </div>

                            <div class="mb-3 position-relative">
                                <label class="form-label text-muted small">Confirm Password</label>
                                <asp:TextBox ID="txtConfirm" runat="server" TextMode="Password" CssClass="form-control form-control-lg" Placeholder="Re-Enter Password" />
                            </div>
                        </div>

                        <!-- Sign Up Button (CLASS PRESERVED) -->


                        <div class="mt-3">
                            <asp:Button ID="btnRegister" runat="server" Text="Sign Up"
                                CssClass="btn btn-signin btn-lg w-100 rounded-3 mb-4" OnClick="btnRegister_Click" />
                            <div class="text-center text-muted mb-4 text-size-14">
                                Already have an account? <a href="Default.aspx" class="text-primary">Login</a>
                            </div>
                        </div>

                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>