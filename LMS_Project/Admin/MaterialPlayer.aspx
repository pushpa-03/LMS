<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MaterialPlayer.aspx.cs" Inherits="LMS_Project.Admin.MaterialPlayer" %>

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
</html>