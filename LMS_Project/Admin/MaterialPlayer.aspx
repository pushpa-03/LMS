<%--<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MaterialPlayer.aspx.cs" Inherits="LMS_Project.Admin.MaterialPlayer" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Material Player</title>

    <link href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.0/css/bootstrap.min.css" rel="stylesheet" />
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

    <style>
        body { background:#f5f7fb; }
        .card { border-radius:12px; }
        .chat-box {
            height:300px;
            overflow-y:auto;
            background:#fff;
            padding:10px;
            border-radius:10px;
        }
        .chat-msg { margin-bottom:10px; }
        .user { font-weight:bold; color:#0d6efd; }
        .ai { color:#198754; }
    </style>
</head>

<body>
<form id="form1" runat="server">
    <asp:HiddenField ID="hfFilePath" runat="server" />

<div class="container mt-3">

    <a href="SubjectDetails.aspx" class="btn btn-dark mb-2">⬅ Back</a>

    <div class="card p-3 shadow">

        <h4><asp:Label ID="lblTitle" runat="server" /></h4>

        <!-- FILE VIEW -->
        <div id="fileViewer" runat="server"></div>

        <a id="downloadLink" runat="server" class="btn btn-success mt-2">Download</a>

        <!-- TABS -->
        <ul class="nav nav-tabs mt-3" id="materialTabs" role="tablist">
            <li class="nav-item">
                <button class="nav-link active" data-bs-toggle="tab" data-bs-target="#quiz" type="button">Quiz</button>
            </li>
            <li class="nav-item">
                <button class="nav-link" data-bs-toggle="tab" data-bs-target="#doubt" type="button">Doubts</button>
            </li>
            <li class="nav-item">
                <button class="nav-link" data-bs-toggle="tab" data-bs-target="#notes" type="button">Notes</button>
            </li>
        </ul>

        <div class="tab-content mt-3">

            <!-- QUIZ -->
            <div class="tab-pane fade show active" id="quiz">
                <button class="btn btn-primary" onclick="generateQuiz()">Generate Quiz</button>
                <div id="quizBox" class="chat-box mt-2"></div>
            </div>

            <!-- DOUBTS -->
            <div class="tab-pane fade" id="doubt">
                <div class="input-group">
                    <input id="txtQ" class="form-control" placeholder="Ask your doubt..." />
                    <button class="btn btn-success" onclick="askDoubt()">Ask</button>
                </div>
                <div id="chatBox" class="chat-box mt-2"></div>
            </div>

            <!-- NOTES -->
            <div class="tab-pane fade" id="notes">
                <button class="btn btn-warning" onclick="generateNotes()">Generate Notes</button>
                <div id="notesBox" class="chat-box mt-2"></div>
            </div>

        </div>

        <!-- HISTORY -->
        <div id="historyContainer">
    <asp:Repeater ID="rptHistory" runat="server">
        <ItemTemplate>
            <div class="border p-2 mb-2 bg-light rounded history-item">
                <b><%# Eval("Type") %></b><br />
                <%# Eval("Question") %><br />
                <span class="text-success"><%# Eval("Response") %></span>
            </div>
        </ItemTemplate>
    </asp:Repeater>
</div>

    </div>
</div>

<style>
.chat-box {
    height: 300px;
    overflow-y: auto;
    background: #f8f9fa;
    padding: 10px;
    border-radius: 10px;
}
</style>

<script> 
    let materialId = '<%= Request.QueryString["MaterialId"] %>';

    // Helper function to save the result to the DB via C#
    function saveResult(type, question, aiResponse) {
        $.ajax({
            type: "POST",
            url: "MaterialPlayer.aspx/SaveToHistory",
            data: JSON.stringify({
                materialId: materialId,
                type: type,
                question: question,
                response: aiResponse
            }),
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function (res) {
                console.log("History Updated");

                // 🔥 NEW: Automatically add the new entry to the top of the history list
                const newEntry = `
                <div class="border p-2 mb-2 bg-light rounded history-item" style="border-left: 5px solid #198754 !important;">
                    <b>${type}</b><br />
                    ${question}<br />
                    <span class="text-success">${aiResponse.replace(/\n/g, "<br>")}</span>
                </div>`;

                // Prepend adds it to the top so the user sees it immediately
                $("#historyContainer").prepend(newEntry);
            }
        });
    }

    async function generateQuiz() {
        event.preventDefault();
        const box = document.getElementById("quizBox");
        const filePath = $('#<%= hfFilePath.ClientID %>').val();
        box.innerHTML = "⏳ AI is thinking...";

        try {
            const response = await fetch("http://localhost:8000/material-quiz", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ file_path: filePath })
            });
            const data = await response.json();
            const resultText = data.result || data.error;
            
            box.innerHTML = "<h6>Quiz:</h6><pre style='white-space:pre-wrap;'>" + resultText + "</pre>";
            
            // SAVE TO HISTORY
            saveResult("Quiz", "Generated Quiz", resultText);
        } catch (err) { box.innerHTML = "❌ AI Server Down"; }
    }

    async function generateNotes() {
        event.preventDefault();
        const box = document.getElementById("notesBox");
        const filePath = $('#<%= hfFilePath.ClientID %>').val();
        box.innerHTML = "⏳ Generating notes...";

        try {
            const response = await fetch("http://localhost:8000/material-notes", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ file_path: filePath })
            });
            const resultText = await response.json();
            box.innerHTML = "<h6>Notes:</h6><pre style='white-space:pre-wrap;'>" + resultText + "</pre>";
            
            // SAVE TO HISTORY
            saveResult("Notes", "Generated Notes", resultText);
        } catch (err) { box.innerHTML = "❌ AI Server Down"; }
    }

    async function askDoubt() {
        event.preventDefault();
        const q = $("#txtQ").val();
        if (!q) return;
        const filePath = $('#<%= hfFilePath.ClientID %>').val();
        const chatBox = document.getElementById("chatBox");

        $(chatBox).append(`<div><b>You:</b> ${q}</div><div id='temp-ai'><b>AI:</b> Thinking...</div>`);
        $("#txtQ").val("");

        try {
            const response = await fetch("http://localhost:8000/material-ask", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ file_path: filePath, question: q })
            });
            const resultText = await response.json();
            $("#temp-ai").remove();
            $(chatBox).append(`<div><b>AI:</b> <pre style='white-space:pre-wrap;'>${resultText}</pre></div><br>`);

            // SAVE TO HISTORY
            saveResult("Doubt", q, resultText);
        } catch (err) { $("#temp-ai").html("<b>AI:</b> Server Error"); }
    }
</script>
</form>
</body>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.0/js/bootstrap.bundle.min.js"></script>
</html>--%>

<%--------------------------------------------------------------------------------------------------------------------------------------%>

<%--<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MaterialPlayer.aspx.cs" Inherits="LMS_Project.Admin.MaterialPlayer" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Admin - Material Management</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.0/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet" />
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

    <style>
        :root { --primary-color: #4e73df; --secondary-color: #858796; }
        body { background: #f8f9fc; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        .admin-card { border: none; border-radius: 15px; box-shadow: 0 0.15rem 1.75rem 0 rgba(58, 59, 69, 0.15); }
        .viewer-section { background: #fff; border-radius: 15px; overflow: hidden; height: 600px; }
        .sidebar-section { height: 600px; display: flex; flex-direction: column; }
        .chat-container { flex-grow: 1; overflow-y: auto; background: #fdfdfd; border: 1px solid #e3e6f0; border-radius: 10px; padding: 15px; }
        .nav-tabs .nav-link { color: var(--secondary-color); font-weight: 600; }
        .nav-tabs .nav-link.active { color: var(--primary-color); border-bottom: 3px solid var(--primary-color); }
        .badge-admin { font-size: 0.7rem; text-transform: uppercase; letter-spacing: 1px; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:HiddenField ID="hfFilePath" runat="server" />
        <div class="container-fluid py-4">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <a href="javascript:history.back()" class="btn btn-outline-secondary btn-sm rounded-pill">
                        <i class="fas fa-arrow-left"></i> Back to List
                    </a>
                    <h3 class="mt-2 text-gray-800"><asp:Label ID="lblTitle" runat="server" /> <span class="badge bg-primary badge-admin">Admin View</span></h3>
                </div>
                <div class="btn-group">
                    <asp:HyperLink ID="lnkEdit" runat="server" CssClass="btn btn-warning"><i class="fas fa-edit"></i> Edit Material</asp:HyperLink>
                    <a id="downloadLink" runat="server" class="btn btn-success"><i class="fas fa-download"></i> Download</a>
                </div>
            </div>

            <div class="row">
                <div class="col-lg-8">
                    <div class="admin-card viewer-section shadow p-2">
                        <div id="fileViewer" runat="server" style="height: 100%;"></div>
                    </div>
                </div>

                <div class="col-lg-4">
                    <div class="admin-card sidebar-section shadow p-3">
                        <ul class="nav nav-tabs mb-3" id="adminTabs">
                            <li class="nav-item">
                                <a class="nav-link active" data-bs-toggle="tab" href="#aiPreview">AI Tools</a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link" data-bs-toggle="tab" href="#activityLog">Activity Log</a>
                            </li>
                        </ul>

                        <div class="tab-content flex-grow-1 d-flex flex-direction-column">
                            <div class="tab-pane fade show active flex-grow-1" id="aiPreview">
                                <small class="text-muted mb-2 d-block">Preview generated content for this file:</small>
                                <div class="d-flex gap-2 mb-3">
                                    <button class="btn btn-sm btn-primary flex-fill" onclick="generateAI('quiz')"><i class="fas fa-question-circle"></i> Quiz</button>
                                    <button class="btn btn-sm btn-info text-white flex-fill" onclick="generateAI('notes')"><i class="fas fa-sticky-note"></i> Notes</button>
                                </div>
                                
                                <div id="aiResponseBox" class="chat-container mb-2">
                                    <div class="text-center text-muted mt-5">
                                        <i class="fas fa-robot fa-3x mb-3"></i>
                                        <p>Select a tool above to preview AI generation.</p>
                                    </div>
                                </div>
                                
                                <div class="input-group mt-2">
                                    <input id="txtAdminQuery" class="form-control border-end-0" placeholder="Test AI with a question..." />
                                    <button class="btn btn-primary" onclick="askAdminDoubt()"><i class="fas fa-paper-plane"></i></button>
                                </div>
                            </div>

                            <div class="tab-pane fade flex-grow-1" id="activityLog">
                                <div id="historyContainer" class="chat-container" style="height: 480px;">
                                    <asp:Repeater ID="rptHistory" runat="server">
                                        <ItemTemplate>
                                            <div class="border-bottom py-2">
                                                <div class="d-flex justify-content-between">
                                                    <span class="badge bg-light text-dark"><%# Eval("Type") %></span>
                                                    <small class="text-muted"><%# Eval("CreatedOn", "{0:MMM dd, HH:mm}") %></small>
                                                </div>
                                                <p class="mb-1 small"><strong>Q:</strong> <%# Eval("Question") %></p>
                                                <p class="mb-0 small text-success"><strong>A:</strong> <%# Eval("Response").ToString().Length > 100 ? Eval("Response").ToString().Substring(0,100) + "..." : Eval("Response") %></p>
                                            </div>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>

    <script>
        let materialId = '<%= Request.QueryString["MaterialId"] %>';

        async function generateAI(type) {
            event.preventDefault();
            const box = document.getElementById("aiResponseBox");
            const filePath = $('#<%= hfFilePath.ClientID %>').val();
            box.innerHTML = `<div class="text-center mt-5"><div class="spinner-border text-primary"></div></div>`;

            let endpoint = type === 'quiz' ? 'material-quiz' : 'material-notes';

            try {
                const response = await fetch(`http://localhost:8000/${endpoint}`, {
                    method: "POST",
                    headers: { "Content-Type": "application/json" },
                    body: JSON.stringify({ file_path: filePath })
                });

                const data = await response.json();

                // FIX: Handle both object {result: "..."} and direct string response
                const resultText = (typeof data === 'object') ? (data.result || data.answer || JSON.stringify(data)) : data;

                box.innerHTML = `<h6>${type.toUpperCase()} Preview:</h6><hr><div class="small" style="white-space:pre-wrap;">${resultText}</div>`;

                // Save to DB so it shows in Activity Log
                saveResult(type.charAt(0).toUpperCase() + type.slice(1), "Admin Preview", resultText);
            } catch (err) {
                console.error(err);
                box.innerHTML = "<div class='alert alert-danger'>AI Error: Check Console</div>";
            }
        }

        async function askAdminDoubt() {
            event.preventDefault();
            const q = $("#txtAdminQuery").val();
            if (!q) return;
            const box = document.getElementById("aiResponseBox");
            const filePath = $('#<%= hfFilePath.ClientID %>').val();

            box.innerHTML = `<div class="text-center mt-5"><div class="spinner-border text-primary" role="status"></div></div>`;

            try {
                const response = await fetch("http://localhost:8000/material-ask", {
                    method: "POST",
                    headers: { "Content-Type": "application/json" },
                    body: JSON.stringify({ file_path: filePath, question: q })
                });
                const resultText = await response.json();
                box.innerHTML = `<h6>Question: ${q}</h6><hr><div class="small" style="white-space:pre-wrap;">${resultText}</div>`;
                saveResult("Admin Doubt", q, resultText);
                $("#txtAdminQuery").val("");
            } catch (err) { box.innerHTML = "<div class='alert alert-danger'>Server Error</div>"; }
        }

        function saveResult(type, question, aiResponse) {
            $.ajax({
                type: "POST",
                url: "MaterialPlayer.aspx/SaveToHistory",
                data: JSON.stringify({ materialId: materialId, type: type, question: question, response: aiResponse }),
                contentType: "application/json; charset=utf-8",
                success: function () {
                    // Add to the top of the activity log visually
                    const newEntry = `
                <div class="border-bottom py-2 bg-light">
                    <div class="d-flex justify-content-between">
                        <span class="badge bg-primary">${type}</span>
                        <small class="text-muted">Just now</small>
                    </div>
                    <p class="mb-1 small"><strong>Q:</strong> ${question}</p>
                    <p class="mb-0 small text-success"><strong>A:</strong> ${aiResponse.substring(0, 100)}...</p>
                </div>`;
                    $("#historyContainer").prepend(newEntry);
                }
            });
        }
    </script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.0/js/bootstrap.bundle.min.js"></script>
</body>
</html>--%>

<%-----------------------------------------------------------------------------------------------------------------------------------%>

<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MaterialPlayer.aspx.cs" Inherits="LMS_Project.Admin.MaterialPlayer" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Admin - Material Management</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.0/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet" />
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

    <style>
        :root { --primary-color: #4e73df; --secondary-color: #858796; }
        body { background: #f8f9fc; font-family: 'Segoe UI', sans-serif; }
        .admin-card { border: none; border-radius: 15px; box-shadow: 0 0.15rem 1.75rem 0 rgba(58, 59, 69, 0.15); background:#fff; }
        .viewer-section { height: 600px; overflow: hidden; }
        .sidebar-section { height: 600px; display: flex; flex-direction: column; }
        .chat-container { flex-grow: 1; overflow-y: auto; background: #fdfdfd; border: 1px solid #e3e6f0; border-radius: 10px; padding: 15px; }
        .nav-tabs .nav-link { color: var(--secondary-color); font-weight: 600; }
        .nav-tabs .nav-link.active { color: var(--primary-color); border-bottom: 3px solid var(--primary-color); }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:HiddenField ID="hfFilePath" runat="server" />
        <div class="container-fluid py-4">
            <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap">
    <div class="d-flex align-items-center gap-3">
        <a href="javascript:history.back()" class="btn btn-outline-secondary btn-sm rounded-pill">
            <i class="fas fa-arrow-left"></i> 
        </a>
        <h3 class="mb-0 d-flex align-items-center gap-2">
            <asp:Label ID="lblTitle" runat="server" /> 
            <span class="badge bg-primary text-uppercase" style="font-size:10px">Admin</span>
        </h3>
    </div>

    <div class="btn-group">
        <asp:HyperLink ID="lnkEdit" runat="server" CssClass="btn btn-sm btn-warning">
            <i class="fas fa-edit"></i> Edit
        </asp:HyperLink>
        <a id="downloadLink" runat="server" class="btn btn-sm btn-success">
            <i class="fas fa-download"></i> Download
        </a>
    </div>
</div>

            <div class="row">
                <div class="col-lg-8">
                    <div class="admin-card viewer-section p-2">
                        <div id="fileViewer" runat="server" style="height: 100%;"></div>
                    </div>
                </div>

                <div class="col-lg-4">
                    <div class="admin-card sidebar-section p-3">
                        <ul class="nav nav-tabs mb-3" id="adminTabs">
                            <li class="nav-item"><a class="nav-link active" data-bs-toggle="tab" href="#aiPreview">AI Tools</a></li>
                            <li class="nav-item"><a class="nav-link" data-bs-toggle="tab" href="#activityLog">History</a></li>
                        </ul>

                        <div class="tab-content d-flex flex-column flex-grow-1">
                            <div class="tab-pane fade show active flex-grow-1" id="aiPreview">
                                <div class="d-flex gap-2 mb-3">
                                    <button type="button" class="btn btn-sm btn-primary flex-fill" onclick="generateAI('quiz')">Quiz</button>
                                    <button type="button" class="btn btn-sm btn-info text-white flex-fill" onclick="generateAI('notes')">Notes</button>
                                </div>
                                
                                <div id="aiResponseBox" class="chat-container mb-2">
                                    <div class="text-center text-muted mt-5">
                                        <i class="fas fa-robot fa-3x mb-2"></i>
                                        <p>Generate Quiz or Notes to preview.</p>
                                    </div>
                                </div>
                                
                                <div class="input-group">
                                    <input id="txtAdminQuery" class="form-control" placeholder="Ask a doubt..." />
                                    <button type="button" class="btn btn-primary" onclick="askAdminDoubt()"><i class="fas fa-paper-plane"></i></button>
                                </div>
                            </div>

                            <div class="tab-pane fade flex-grow-1" id="activityLog">
                                <div id="historyContainer" class="chat-container" style="height: 450px;">
                                    <asp:Repeater ID="rptHistory" runat="server">
                                        <ItemTemplate>
                                            <div class="border-bottom py-2">
                                                <span class="badge bg-secondary mb-1"><%# Eval("Type") %></span>
                                                <p class="mb-1 small"><strong>Q:</strong> <%# Eval("Question") %></p>
                                                <p class="mb-0 small text-success"><strong>A:</strong> <%# Eval("Response") %></p>
                                            </div>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>

    <script>
        let materialId = '<%= Request.QueryString["MaterialId"] %>';

        async function generateAI(type) {
            const box = document.getElementById("aiResponseBox");
            const filePath = $('#<%= hfFilePath.ClientID %>').val();
            box.innerHTML = `<div class="text-center mt-5"><div class="spinner-border text-primary"></div><p>AI Processing...</p></div>`;

            let endpoint = type === 'quiz' ? 'material-quiz' : 'material-notes';

            try {
                const response = await fetch(`http://localhost:8000/${endpoint}`, {
                    method: "POST",
                    headers: { "Content-Type": "application/json" },
                    body: JSON.stringify({ file_path: filePath })
                });

                const data = await response.json();
                // Handle different response formats from FastAPI
                const resultText = typeof data === 'string' ? data : (data.result || data.answer || JSON.stringify(data));

                box.innerHTML = `<h6>${type.toUpperCase()} Preview:</h6><hr><div class="small" style="white-space:pre-wrap;">${resultText}</div>`;
                saveResult(type.charAt(0).toUpperCase() + type.slice(1), "Generated via AI", resultText);
            } catch (err) {
                box.innerHTML = "<div class='alert alert-danger'>AI Server is Offline</div>";
            }
        }

        async function askAdminDoubt() {
            const q = $("#txtAdminQuery").val();
            if (!q) return;
            const box = document.getElementById("aiResponseBox");
            const filePath = $('#<%= hfFilePath.ClientID %>').val();
            box.innerHTML = `<div class="text-center mt-5"><div class="spinner-border text-success"></div></div>`;

            try {
                const response = await fetch("http://localhost:8000/material-ask", {
                    method: "POST",
                    headers: { "Content-Type": "application/json" },
                    body: JSON.stringify({ file_path: filePath, question: q })
                });
                const resultText = await response.json();
                box.innerHTML = `<h6>Result:</h6><hr><div class="small" style="white-space:pre-wrap;">${resultText}</div>`;
                saveResult("Doubt", q, resultText);
                $("#txtAdminQuery").val("");
            } catch (err) { box.innerHTML = "<div class='alert alert-danger'>Error contacting AI</div>"; }
        }

        function saveResult(type, question, aiResponse) {
            $.ajax({
                type: "POST",
                url: "MaterialPlayer.aspx/SaveToHistory",
                data: JSON.stringify({ materialId: materialId, type: type, question: question, response: aiResponse }),
                contentType: "application/json; charset=utf-8",
                success: function () {
                    const entry = `<div class="border-bottom py-2 bg-light"><span class="badge bg-primary">${type}</span><p class="mb-0 small"><strong>Q:</strong> ${question}</p><p class="mb-0 small text-success"><strong>A:</strong> ${aiResponse.substring(0, 50)}...</p></div>`;
                    $("#historyContainer").prepend(entry);
                }
            });
        }
    </script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.0/js/bootstrap.bundle.min.js"></script>
</body>
</html>