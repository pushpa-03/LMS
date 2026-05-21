<%@ Page Title="Learning Progress" Language="C#" MasterPageFile="~/Student/StudentMaster.master" 
    AutoEventWireup="true" CodeBehind="ProgressTracker.aspx.cs" 
    Inherits="LMS_Project.Student.ProgressTracker" %>

<asp:Content ID="C1" ContentPlaceHolderID="head" runat="server">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"/>
    <style>
        :root {
            --primary: #6366f1;
            --primary-dark: #4f46e5;
            --success: #059669;
            --danger: #dc2626;
            --warn: #f59e0b;
            --bg: #f1f5f9;
            --card: #ffffff;
            --border: #e2e8f0;
            --text: #0f172a;
            --muted: #64748b;
            --shadow: 0 1px 3px rgba(0,0,0,.07), 0 4px 16px rgba(0,0,0,.05);
        }
        body { font-family: 'Inter', system-ui, sans-serif; background: var(--bg); color: var(--text); }
        
        .container-fluid { max-width: 1200px; margin: 0 auto; padding: 20px; }
        
        .page-header {
            display: flex; align-items: center; gap: 15px; margin-bottom: 24px;
            padding-bottom: 16px; border-bottom: 2px solid var(--border);
        }
        .page-header h1 { font-size: 28px; font-weight: 800; color: var(--text); margin: 0; }
        .page-header .stat { display: flex; align-items: center; gap: 8px; margin-left: auto; font-size: 13px; }
        .page-header .stat-badge { background: var(--primary); color: #fff; border-radius: 20px; padding: 4px 12px; font-weight: 600; }

        .subject-card {
            background: var(--card); border: 1px solid var(--border); border-radius: 12px;
            padding: 18px; margin-bottom: 16px; box-shadow: var(--shadow); cursor: pointer;
            transition: all .3s ease;
        }
        .subject-card:hover {
            border-color: var(--primary); box-shadow: 0 4px 12px rgba(99, 102, 241, 0.15);
        }
        .subject-header {
            display: flex; justify-content: space-between; align-items: center; gap: 15px; margin-bottom: 12px;
        }
        .subject-title { font-size: 16px; font-weight: 700; color: var(--text); }
        .completion-badge { display: inline-flex; align-items: center; gap: 6px; background: var(--bg); border-radius: 20px; padding: 6px 14px; font-size: 13px; font-weight: 600; }
        .completion-badge.full { background: #dcfce7; color: var(--success); }
        .completion-badge.partial { background: #fef3c7; color: var(--warn); }
        .completion-badge.empty { background: #fee2e2; color: var(--danger); }

        .progress-bar {
            height: 8px; background: var(--border); border-radius: 10px; overflow: hidden; margin: 10px 0;
        }
        .progress-fill {
            height: 100%; border-radius: 10px; background: linear-gradient(90deg, var(--primary), #a855f7);
            transition: width .5s ease;
        }

        .chapter-list { margin-top: 14px; padding-top: 14px; border-top: 1px solid var(--border); display: none; }
        .chapter-list.open { display: block; }
        .chapter-item {
            display: flex; gap: 12px; padding: 10px 0; border-bottom: 1px solid var(--border); font-size: 13px;
        }
        .chapter-item:last-child { border-bottom: none; }
        .ch-progress { flex: 1; }
        .ch-name { font-weight: 600; color: var(--text); margin-bottom: 4px; }
        .ch-bar { height: 5px; background: var(--border); border-radius: 5px; overflow: hidden; }
        .ch-bar-fill { height: 100%; background: linear-gradient(90deg, var(--primary), #a855f7); transition: width .3s; }
        .ch-stat { text-align: right; color: var(--muted); font-size: 12px; min-width: 60px; white-space: nowrap; }

        .video-list { margin-left: 30px; margin-top: 8px; display: none; }
        .video-list.open { display: block; }
        .video-item {
            display: flex; align-items: center; gap: 8px; padding: 7px 10px; margin: 4px 0;
            background: var(--bg); border-radius: 8px; font-size: 12px; cursor: pointer;
            transition: all .15s;
        }
        .video-item:hover { background: var(--border); }
        .video-item.completed { background: #dcfce7; }
        .video-item.inprogress { background: #fef3c7; }
        .video-status {
            display: flex; align-items: center; justify-content: center; width: 24px; height: 24px;
            border-radius: 50%; background: var(--border); color: var(--muted); font-size: 11px; flex-shrink: 0;
        }
        .video-item.completed .video-status { background: var(--success); color: #fff; }
        .video-item.inprogress .video-status { background: var(--warn); color: #fff; }
        .video-name { flex: 1; font-weight: 500; color: var(--text); }
        .video-pct { color: var(--muted); font-size: 11px; min-width: 45px; text-align: right; font-family: monospace; }

        .empty-state {
            text-align: center; padding: 40px 20px; color: var(--muted);
        }
        .empty-state i { font-size: 48px; margin-bottom: 16px; opacity: .3; }

        .filter-bar { display: flex; gap: 10px; margin-bottom: 20px; flex-wrap: wrap; }
        .filter-btn { background: var(--card); border: 1px solid var(--border); border-radius: 8px; padding: 8px 14px; font-size: 13px; font-weight: 600; cursor: pointer; color: var(--muted); transition: .18s; }
        .filter-btn.active { background: var(--primary); color: #fff; border-color: var(--primary); }
        .filter-btn:hover { border-color: var(--primary); }

        @media (max-width: 768px) {
            .page-header { flex-direction: column; align-items: flex-start; }
            .page-header .stat { margin-left: 0; }
            .subject-header { flex-direction: column; align-items: flex-start; }
        }
    </style>
</asp:Content>

<asp:Content ID="C2" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">

<div class="container-fluid">

    <!-- Page Header -->
    <div class="page-header">
        <div>
            <h1><i class="fas fa-chart-line me-2" style="color:var(--primary)"></i>Your Learning Progress</h1>
        </div>
        <div class="stat">
            <span>Overall Completion:</span>
            <span class="stat-badge" id="overallPct">—</span>
        </div>
    </div>

    <!-- Filter Bar -->
    <div class="filter-bar">
        <button class="filter-btn active" onclick="filterProgress('all', this)">All Subjects</button>
        <button class="filter-btn" onclick="filterProgress('completed', this)">Completed</button>
        <button class="filter-btn" onclick="filterProgress('inprogress', this)">In Progress</button>
        <button class="filter-btn" onclick="filterProgress('notstarted', this)">Not Started</button>
    </div>

    <!-- Content -->
    <div id="progressContent">
        <div class="empty-state">
            <i class="fas fa-spinner fa-spin"></i>
            <p>Loading your progress...</p>
        </div>
    </div>

</div>

<script>
    let allSubjects = [];
    let activeFilter = 'all';

    async function loadProgress() {
        try {
            const res = await fetch('ProgressTracker.aspx/GetProgressData', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json; charset=utf-8' },
                body: JSON.stringify({})
            });
            const result = await res.json();
            allSubjects = typeof result.d === 'string' ? JSON.parse(result.d) : (result.d || []);
            renderProgress(allSubjects);
        } catch (e) {
            document.getElementById('progressContent').innerHTML = `
                <div class="empty-state">
                    <i class="fas fa-exclamation-circle"></i>
                    <p>Failed to load progress data</p>
                </div>`;
        }
    }

    function renderProgress(subjects) {
        if (!subjects.length) {
            document.getElementById('progressContent').innerHTML = `
                <div class="empty-state">
                    <i class="fas fa-inbox"></i>
                    <p>No subjects assigned yet</p>
                </div>`;
            return;
        }

        // Calculate overall completion
        const totalVideos = subjects.reduce((sum, s) => sum + (s.TotalVideos || 0), 0);
        const completedVideos = subjects.reduce((sum, s) => sum + (s.CompletedVideos || 0), 0);
        const overallPct = totalVideos > 0 ? Math.round((completedVideos / totalVideos) * 100) : 0;
        document.getElementById('overallPct').textContent = overallPct + '%';

        const filtered = filterByStatus(subjects);

        document.getElementById('progressContent').innerHTML = filtered.map(s => `
<div class="subject-card" onclick="toggleChapters(this)">
    <div class="subject-header">
        <div class="subject-title">${escapeHtml(s.SubjectName)}</div>
        <div class="completion-badge ${getCompletionClass(s.CompletionPercent)}">
            <i class="fas fa-${s.CompletionPercent >= 100 ? 'check-circle' : (s.CompletionPercent > 0 ? 'circle-notch' : 'circle')}"></i>
            ${s.CompletionPercent}%
        </div>
    </div>
    <div class="progress-bar">
        <div class="progress-fill" style="width:${s.CompletionPercent}%"></div>
    </div>
    <div style="font-size:12px;color:var(--muted)">
        ${s.CompletedVideos} of ${s.TotalVideos} videos completed
    </div>
    <div class="chapter-list" id="chapters-${s.SubjectId}"></div>
</div>`).join('');

        // Load chapters for each subject
        subjects.forEach(s => loadChapters(s.SubjectId));
    }

    async function loadChapters(subjectId) {
        try {
            const res = await fetch('ProgressTracker.aspx/GetChapterData', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json; charset=utf-8' },
                body: JSON.stringify({ subjectId })
            });
            const result = await res.json();
            const chapters = typeof result.d === 'string' ? JSON.parse(result.d) : (result.d || []);
            
            const chDiv = document.getElementById('chapters-' + subjectId);
            if (!chDiv) return;

            chDiv.innerHTML = chapters.map(c => `
<div class="chapter-item">
    <div class="ch-progress">
        <div class="ch-name" onclick="toggleVideos(event, ${c.ChapterId})"
             style="cursor:pointer;display:flex;align-items:center;gap:6px">
            <i class="fas fa-chevron-right" id="chev-${c.ChapterId}" style="transition:.2s"></i>
            ${escapeHtml(c.ChapterName)}
        </div>
        <div class="ch-bar">
            <div class="ch-bar-fill" style="width:${c.CompletionPercent}%"></div>
        </div>
    </div>
    <div class="ch-stat">${c.CompletedVideos}/${c.TotalVideos}</div>
    <div class="video-list" id="videos-${c.ChapterId}"></div>
</div>`).join('');

            // Load videos for each chapter
            chapters.forEach(c => loadVideos(c.ChapterId));
        } catch (e) {
            console.error('Failed to load chapters:', e);
        }
    }

    async function loadVideos(chapterId) {
        try {
            const res = await fetch('ProgressTracker.aspx/GetVideoData', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json; charset=utf-8' },
                body: JSON.stringify({ chapterId })
            });
            const result = await res.json();
            const videos = typeof result.d === 'string' ? JSON.parse(result.d) : (result.d || []);

            const vDiv = document.getElementById('videos-' + chapterId);
            if (!vDiv) return;

            vDiv.innerHTML = videos.map(v => {
                const status = v.IsCompleted ? 'completed' : (v.WatchedPercent > 0 ? 'inprogress' : 'notstarted');
                const statusIcon = v.IsCompleted ? 'check' : (v.WatchedPercent > 0 ? 'play' : 'lock');
                return `
<div class="video-item ${status}">
    <div class="video-status"><i class="fas fa-${statusIcon}"></i></div>
    <span class="video-name" title="${escapeHtml(v.Title)}">${escapeHtml(v.Title)}</span>
    <span class="video-pct">${v.WatchedPercent}%</span>
</div>`;
            }).join('');
        } catch (e) {
            console.error('Failed to load videos:', e);
        }
    }

    function toggleChapters(card) {
        const chDiv = card.querySelector('.chapter-list');
        chDiv.classList.toggle('open');
        card.style.borderColor = chDiv.classList.contains('open') ? 'var(--primary)' : 'var(--border)';
    }

    function toggleVideos(e, chapterId) {
        e.stopPropagation();
        const vDiv = document.getElementById('videos-' + chapterId);
        const chev = document.getElementById('chev-' + chapterId);
        vDiv.classList.toggle('open');
        chev.style.transform = vDiv.classList.contains('open') ? 'rotate(90deg)' : 'rotate(0deg)';
    }

    function getCompletionClass(pct) {
        if (pct >= 100) return 'full';
        if (pct > 0) return 'partial';
        return 'empty';
    }

    function filterByStatus(subjects) {
        if (activeFilter === 'all') return subjects;
        return subjects.filter(s => {
            if (activeFilter === 'completed') return s.CompletionPercent >= 100;
            if (activeFilter === 'inprogress') return s.CompletionPercent > 0 && s.CompletionPercent < 100;
            if (activeFilter === 'notstarted') return s.CompletionPercent === 0;
            return true;
        });
    }

    function filterProgress(filter, btn) {
        activeFilter = filter;
        document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        renderProgress(allSubjects);
    }

    function escapeHtml(s) {
        return String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
    }

    document.addEventListener('DOMContentLoaded', loadProgress);
</script>

</asp:Content>
