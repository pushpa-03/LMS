
//// Global chart instances
//var chartInstance = null;
//var asgChartInstance = null;
//var divisionChartInstance = null;
//var avgMarksChartInstance = null;

//// Comparison Analytics variables
//var _cmpTab = 'section';
//var _cmpMetric = 'marks';
//var _secData = null;
//var _subData = null;
//var _secChart = null;
//var _subChart = null;

//// ── Activity Trend Chart ────────────────────────────────────────
//var activityChartInstance = null;
//var _actChartType = 'line';

//function renderSubjectChart() {
//    var hf = document.getElementById('<%= hfChartData.ClientID %>');
//    if (!hf || !hf.value) return;
//    var data;
//    try { data = JSON.parse(hf.value); } catch (e) { return; }
//    var ctx = document.getElementById('subjectChart');
//    if (!ctx) return;
//    if (chartInstance) { chartInstance.destroy(); chartInstance = null; }

//    var labels = data.map(function (d) { return d.SubjectName; });
//    var counts = data.map(function (d) { return d.StudentCount; });
//    var subIds = data.map(function (d) { return d.SubjectId; });
//    var colors = ['#1565c0', '#0288d1', '#1976d2', '#ef6c00', '#5e35b1',
//        '#388e3c', '#c62828', '#00838f', '#4527a0', '#2e7d32'];

//    chartInstance = new Chart(ctx, {
//        type: 'bar',
//        data: {
//            labels: labels,
//            datasets: [{
//                label: 'Students Enrolled',
//                data: counts,
//                backgroundColor: labels.map(function (_, i) { return colors[i % colors.length] + 'cc'; }),
//                borderColor: labels.map(function (_, i) { return colors[i % colors.length]; }),
//                borderWidth: 2,
//                borderRadius: 8
//            }]
//        },
//        options: {
//            responsive: true,
//            maintainAspectRatio: false,
//            plugins: {
//                legend: { display: false },
//                tooltip: { callbacks: { label: function (c) { return ' ' + c.parsed.y + ' students'; } } }
//            },
//            scales: {
//                y: { beginAtZero: true, ticks: { stepSize: 1, font: { size: 11 } }, grid: { color: '#e3f2fd' } },
//                x: { ticks: { font: { size: 11 }, maxRotation: 30 }, grid: { display: false } }
//            },
//            onClick: function (evt, elements) {
//                if (elements.length > 0)
//                    window.location.href = 'CourseVideos.aspx?SubjectId=' + subIds[elements[0].index];
//            }
//        }
//    });
//    ctx.style.cursor = 'pointer';
//}

//function setAsgView(v) {
//    ['btnAsgList', 'btnAsgChart'].forEach(function (id) {
//        var el = document.getElementById(id);
//        if (!el) return;
//        el.className = el.className.replace('btn-primary', 'btn-outline-primary');
//    });
//    var activeEl = document.getElementById(v === 'list' ? 'btnAsgList' : 'btnAsgChart');
//    if (activeEl) activeEl.className = activeEl.className.replace('btn-outline-primary', 'btn-primary');

//    var list = document.getElementById('<%= pnlAssignments.ClientID %>');
//    var chart = document.getElementById('<%= pnlAsgChart.ClientID %>');
//    if (list) list.style.display = (v === 'list') ? 'block' : 'none';
//    if (chart) chart.style.display = (v === 'chart') ? 'block' : 'none';
//    if (v === 'chart') renderAsgChart();
//}

//function renderAsgChart() {
//    var hf = document.getElementById('<%= hfAsgChartData.ClientID %>');
//    if (!hf || !hf.value) return;
//    var data;
//    try { data = JSON.parse(hf.value); } catch (e) { return; }
//    var ctx = document.getElementById('asgChart');
//    if (!ctx) return;
//    if (asgChartInstance) { asgChartInstance.destroy(); asgChartInstance = null; }

//    asgChartInstance = new Chart(ctx, {
//        type: 'bar',
//        data: {
//            labels: data.map(function (d) { return d.Title; }),
//            datasets: [
//                {
//                    label: 'Submitted',
//                    data: data.map(function (d) { return d.SubmissionCount; }),
//                    backgroundColor: '#1565c0cc',
//                    borderColor: '#1565c0',
//                    borderWidth: 2,
//                    borderRadius: 6
//                },
//                {
//                    label: 'Pending',
//                    data: data.map(function (d) { return d.Pending; }),
//                    backgroundColor: '#ef6c00cc',
//                    borderColor: '#ef6c00',
//                    borderWidth: 2,
//                    borderRadius: 6
//                }
//            ]
//        },
//        options: {
//            responsive: true,
//            maintainAspectRatio: false,
//            plugins: {
//                legend: { display: true, position: 'top', labels: { font: { size: 11 } } },
//                tooltip: {
//                    callbacks: {
//                        label: function (c) {
//                            return ' ' + c.dataset.label + ': ' + c.parsed.y + ' students';
//                        }
//                    }
//                }
//            },
//            scales: {
//                x: { ticks: { font: { size: 10 }, maxRotation: 30 }, grid: { display: false } },
//                y: { beginAtZero: true, ticks: { stepSize: 1, font: { size: 11 } }, grid: { color: '#e3f2fd' } }
//            }
//        }
//    });
//}

//function renderDivisionChart() {
//    var hf = document.getElementById('<%= hfDivisionData.ClientID %>');
//    if (!hf || !hf.value) return;
//    var data;
//    try { data = JSON.parse(hf.value); } catch (e) { return; }
//    var ctx = document.getElementById('divisionChart');
//    if (!ctx) return;

//    if (divisionChartInstance) { divisionChartInstance.destroy(); divisionChartInstance = null; }

//    var colors = ['#1565c0','#2e7d32','#ef6c00','#5e35b1','#0288d1','#c62828'];
//    divisionChartInstance = new Chart(ctx, {
//        type: 'bar',
//        data: {
//            labels: data.map(function (d) { return d.Division; }),
//            datasets: [{
//                label: 'Students',
//                data: data.map(function (d) { return d.StudentCount; }),
//                backgroundColor: data.map(function (_, i) { return colors[i % colors.length] + 'cc'; }),
//                borderColor: data.map(function (_, i) { return colors[i % colors.length]; }),
//                borderWidth: 2,
//                borderRadius: 6
//            }]
//        },
//        options: {
//            responsive: true,
//            maintainAspectRatio: false,
//            plugins: {
//                legend: { display: false },
//                tooltip: {
//                    callbacks: {
//                        label: function (c) {
//                            return ' ' + c.parsed.y + ' students';
//                        }
//                    }
//                }
//            },
//            scales: {
//                y: { beginAtZero: true, ticks: { stepSize: 1, font: { size: 10 } }, grid: { color: '#e3f2fd' } },
//                x: { ticks: { font: { size: 10 }, maxRotation: 30 }, grid: { display: false } }
//            }
//        }
//    });
//}

//function renderAvgMarksChart() {
//    var hf = document.getElementById('<%= hfAvgMarksData.ClientID %>');
//    if (!hf || !hf.value) return;
//    var data;
//    try { data = JSON.parse(hf.value); } catch (e) { return; }
//    var ctx = document.getElementById('avgMarksChart');
//    if (!ctx) return;

//    if (avgMarksChartInstance) { avgMarksChartInstance.destroy(); avgMarksChartInstance = null; }

//    avgMarksChartInstance = new Chart(ctx, {
//        type: 'pie',
//        data: {
//            labels: data.map(function (d) { return d.SubjectName; }),
//            datasets: [{
//                data: data.map(function (d) { return d.AvgMarks; }),
//                backgroundColor: data.map(function (d) { return d.Color + 'cc'; }),
//                borderColor: data.map(function (d) { return d.Color; }),
//                borderWidth: 2
//            }]
//        },
//        options: {
//            responsive: true,
//            maintainAspectRatio: false,
//            plugins: {
//                legend: { display: false },
//                tooltip: {
//                    callbacks: {
//                        label: function (c) {
//                            return ' ' + c.label + ': ' + c.parsed + ' avg marks';
//                        }
//                    }
//                }
//            }
//        }
//    });
//}

//// ── Student Marks Modal ───────────────────────────────────────
//var studentMarksChartInstance = null;

//function openStudentModal(studentId, studentName, subjectName) {
//    // Set header info
//    document.getElementById('modalStudentName').textContent = studentName;
//    document.getElementById('modalStudentMeta').textContent = subjectName;

//    // Reset UI
//    document.getElementById('modalLoader').style.display = 'block';
//    document.getElementById('modalKpiRow').style.display = 'none';
//    document.getElementById('studentMarksChart').style.display = 'none';
//    document.getElementById('modalAsgTable').style.display = 'none';
//    document.getElementById('modalEmpty').style.display = 'none';

//    // Show modal
//    var modal = new bootstrap.Modal(document.getElementById('studentMarksModal'));
//    modal.show();

//    // Fetch data
//    fetch('GetStudentMarks.ashx?studentId=' + studentId)
//        .then(function (r) { return r.json(); })
//        .then(function (data) {
//            document.getElementById('modalLoader').style.display = 'none';

//            if (!Array.isArray(data) || data.length === 0) {
//                document.getElementById('modalEmpty').style.display = 'block';
//                return;
//            }

//            // KPIs
//            var total = data.length;
//            var sumMarks = data.reduce(function (s, d) { return s + d.MarksObtained; }, 0);
//            var avg = Math.round(sumMarks / total);
//            var highest = Math.max.apply(null, data.map(function (d) { return d.MarksObtained; }));
//            var lowest = Math.min.apply(null, data.map(function (d) { return d.MarksObtained; }));

//            document.getElementById('modalTotalAsg').textContent = total;
//            document.getElementById('modalAvgMarks').textContent = avg;
//            document.getElementById('modalHighest').textContent = highest;
//            document.getElementById('modalLowest').textContent = lowest;
//            document.getElementById('modalKpiRow').style.display = '';

//            // Chart
//            var canvas = document.getElementById('studentMarksChart');
//            canvas.style.display = 'block';

//            if (studentMarksChartInstance) {
//                studentMarksChartInstance.destroy();
//                studentMarksChartInstance = null;
//            }

//            var labels = data.map(function (d) { return d.AssignmentTitle; });
//            var obtained = data.map(function (d) { return d.MarksObtained; });
//            var maxMarks = data.map(function (d) { return d.MaxMarks; });
//            var pcts = data.map(function (d) { return d.Percentage; });

//            var barColors = pcts.map(function (p) {
//                if (p >= 80) return '#2e7d32cc';
//                if (p >= 60) return '#1565c0cc';
//                if (p >= 50) return '#ef6c00cc';
//                return '#c62828cc';
//            });
//            var borderColors = pcts.map(function (p) {
//                if (p >= 80) return '#2e7d32';
//                if (p >= 60) return '#1565c0';
//                if (p >= 50) return '#ef6c00';
//                return '#c62828';
//            });

//            studentMarksChartInstance = new Chart(canvas, {
//                type: 'bar',
//                data: {
//                    labels: labels,
//                    datasets: [
//                        {
//                            label: 'Marks Obtained',
//                            data: obtained,
//                            backgroundColor: barColors,
//                            borderColor: borderColors,
//                            borderWidth: 2,
//                            borderRadius: 8,
//                            order: 1
//                        },
//                        {
//                            label: 'Max Marks',
//                            data: maxMarks,
//                            type: 'line',
//                            borderColor: '#90a4ae',
//                            borderWidth: 2,
//                            borderDash: [6, 3],
//                            pointRadius: 4,
//                            pointBackgroundColor: '#90a4ae',
//                            fill: false,
//                            tension: 0.3,
//                            order: 0
//                        }
//                    ]
//                },
//                options: {
//                    responsive: true,
//                    maintainAspectRatio: false,
//                    plugins: {
//                        legend: {
//                            display: true,
//                            position: 'top',
//                            labels: { font: { size: 11 } }
//                        },
//                        tooltip: {
//                            callbacks: {
//                                label: function (c) {
//                                    if (c.datasetIndex === 0)
//                                        return ' Marks: ' + c.parsed.y + ' (' + pcts[c.dataIndex] + '%)';
//                                    return ' Max: ' + c.parsed.y;
//                                }
//                            }
//                        }
//                    },
//                    scales: {
//                        y: {
//                            beginAtZero: true,
//                            ticks: { stepSize: 1, font: { size: 11 } },
//                            grid: { color: '#e3f2fd' }
//                        },
//                        x: {
//                            ticks: { font: { size: 10 }, maxRotation: 35 },
//                            grid: { display: false }
//                        }
//                    }
//                }
//            });

//            // Table
//            var tbody = document.getElementById('modalAsgTableBody');
//            tbody.innerHTML = '';
//            data.forEach(function (d, i) {
//                var gradeColor = d.Percentage >= 80 ? '#2e7d32'
//                    : d.Percentage >= 60 ? '#1565c0'
//                        : d.Percentage >= 50 ? '#ef6c00'
//                            : '#c62828';
//                tbody.innerHTML +=
//                    '<tr>' +
//                    '<td style="color:#90a4ae;">' + (i + 1) + '</td>' +
//                    '<td><strong>' + d.AssignmentTitle + '</strong></td>' +
//                    '<td style="color:#78909c;">' + d.SubjectName + '</td>' +
//                    '<td><strong style="color:#263238;">' + d.MarksObtained + '</strong></td>' +
//                    '<td style="color:#90a4ae;">' + d.MaxMarks + '</td>' +
//                    '<td><strong style="color:' + gradeColor + ';">' + d.Percentage + '%</strong></td>' +
//                    '<td><span style="background:' + gradeColor + '22;color:' + gradeColor + ';padding:2px 8px;border-radius:8px;font-size:11px;font-weight:700;">' + d.Grade + '</span></td>' +
//                    '<td style="color:#90a4ae;">' + d.SubmittedOn + '</td>' +
//                    '</tr>';
//            });
//            document.getElementById('modalAsgTable').style.display = '';
//        })
//        .catch(function () {
//            document.getElementById('modalLoader').style.display = 'none';
//            document.getElementById('modalEmpty').style.display = 'block';
//        });
//}

//// ── COMPARISON ANALYTICS FUNCTIONS ──
//function initCompareData() {
//    var hfSec = document.getElementById('hfSecCompareData');
//    var hfSub = document.getElementById('hfSubCompareData');
//    try {
//        if (hfSec && hfSec.value) _secData = JSON.parse(hfSec.value);
//        console.log('Section data loaded:', _secData);
//    } catch (e) { console.error('Error parsing section data:', e); }
//    try {
//        if (hfSub && hfSub.value) _subData = JSON.parse(hfSub.value);
//        console.log('Subject data loaded:', _subData);
//    } catch (e) { console.error('Error parsing subject data:', e); }
//}

//function switchCompareTab(tab) {
//    console.log('Switching tab to:', tab);
//    _cmpTab = tab;

//    var tabSec = document.getElementById('tabSec');
//    var tabSub = document.getElementById('tabSub');
//    if (tabSec) tabSec.className = 'compare-tab' + (tab === 'section' ? ' active' : '');
//    if (tabSub) tabSub.className = 'compare-tab' + (tab === 'subject' ? ' active' : '');

//    var pSec = document.getElementById('pnlCompareSections');
//    var pSub = document.getElementById('pnlCompareSubjects');

//    if (pSec) pSec.style.display = (tab === 'section') ? 'block' : 'none';
//    if (pSub) pSub.style.display = (tab === 'subject') ? 'block' : 'none';

//    renderCmpChart();
//    return false;
//}

//function switchMetric(metric) {
//    console.log('Switching metric to:', metric);
//    _cmpMetric = metric;

//    var btnMarks = document.getElementById('btnMarks');
//    var btnAttend = document.getElementById('btnAttend');
//    var btnEngage = document.getElementById('btnEngage');

//    if (btnMarks) btnMarks.className = 'metric-btn marks' + (metric === 'marks' ? ' active' : '');
//    if (btnAttend) btnAttend.className = 'metric-btn attend' + (metric === 'attendance' ? ' active' : '');
//    if (btnEngage) btnEngage.className = 'metric-btn engage' + (metric === 'engagement' ? ' active' : '');

//    renderCmpChart();
//    return false;
//}

//function cmpMetricField() {
//    if (_cmpMetric === 'marks') return 'AvgMarks';
//    if (_cmpMetric === 'attendance') return 'AttendancePct';
//    return 'VideoViews';
//}

//function cmpMetricLabel() {
//    if (_cmpMetric === 'marks') return 'Avg Marks';
//    if (_cmpMetric === 'attendance') return 'Attendance %';
//    return 'Video Views';
//}

//function cmpMetricColor() {
//    if (_cmpMetric === 'marks') return '#2e7d32';
//    if (_cmpMetric === 'attendance') return '#ef6c00';
//    return '#5e35b1';
//}

//function renderCmpChart() {
//    if (_cmpTab === 'section') renderCmpSectionChart();
//    else renderCmpSubjectChart();
//}

//function renderCmpSectionChart() {
//    var ctx = document.getElementById('secCompareChart');
//    if (!ctx) return;

//    if (_secChart) { _secChart.destroy(); _secChart = null; }

//    if (!_secData || _secData.length === 0) {
//        ctx.style.display = 'none';
//        var emp = document.getElementById('<%= pnlNoSecCompare.ClientID %>');
//        if (emp) emp.style.display = 'block';
//        return;
//    }

//    ctx.style.display = 'block';
//    var emp2 = document.getElementById('<%= pnlNoSecCompare.ClientID %>');
//    if (emp2) emp2.style.display = 'none';

//    var field = cmpMetricField();
//    var mc = cmpMetricColor();
//    var labels = _secData.map(function (d) { return d.SectionName || 'No Section'; });
//    var vals = _secData.map(function (d) { return parseFloat(d[field]) || 0; });
//    var maxVal = vals.length ? Math.max.apply(null, vals) : 1;

//    _secChart = new Chart(ctx, {
//        type: 'bar',
//        data: {
//            labels: labels,
//            datasets: [{
//                label: cmpMetricLabel(),
//                data: vals,
//                backgroundColor: vals.map(function (v) { return v === maxVal ? mc + 'ee' : mc + '44'; }),
//                borderColor: vals.map(function (v) { return v === maxVal ? mc : mc + '99'; }),
//                borderWidth: 2,
//                borderRadius: 8
//            }]
//        },
//        options: buildCmpOptions()
//    });
//}

//function renderCmpSubjectChart() {
//    var ctx = document.getElementById('subCompareChart');
//    if (!ctx) return;

//    if (_subChart) { _subChart.destroy(); _subChart = null; }

//    if (!_subData || _subData.length === 0) {
//        ctx.style.display = 'none';
//        var emp = document.getElementById('<%= pnlNoSubCompare.ClientID %>');
//        if (emp) emp.style.display = 'block';
//        return;
//    }

//    ctx.style.display = 'block';
//    var emp2 = document.getElementById('<%= pnlNoSubCompare.ClientID %>');
//    if (emp2) emp2.style.display = 'none';

//    var field = cmpMetricField();
//    var mc = cmpMetricColor();
//    var labels = _subData.map(function (d) { return d.SubjectName; });
//    var vals = _subData.map(function (d) { return parseFloat(d[field]) || 0; });
//    var maxVal = vals.length ? Math.max.apply(null, vals) : 1;

//    _subChart = new Chart(ctx, {
//        type: 'bar',
//        data: {
//            labels: labels,
//            datasets: [{
//                label: cmpMetricLabel(),
//                data: vals,
//                backgroundColor: vals.map(function (v) { return v === maxVal ? mc + 'ee' : mc + '44'; }),
//                borderColor: vals.map(function (v) { return v === maxVal ? mc : mc + '99'; }),
//                borderWidth: 2,
//                borderRadius: 8
//            }]
//        },
//        options: buildCmpOptions()
//    });
//}

//function buildCmpOptions() {
//    return {
//        responsive: true,
//        maintainAspectRatio: false,
//        plugins: {
//            legend: { display: false },
//            tooltip: {
//                callbacks: {
//                    label: function (c) {
//                        var v = c.parsed.y;
//                        if (_cmpMetric === 'attendance') return ' ' + v + '%';
//                        if (_cmpMetric === 'engagement') return ' ' + v + ' views';
//                        return ' Avg: ' + v + ' marks';
//                    }
//                }
//            }
//        },
//        scales: {
//            y: {
//                beginAtZero: true,
//                ticks: {
//                    font: { size: 11 },
//                    callback: function (v) {
//                        if (_cmpMetric === 'attendance') return v + '%';
//                        return v;
//                    }
//                },
//                grid: { color: '#e3f2fd' }
//            },
//            x: {
//                ticks: { font: { size: 11 }, maxRotation: 30, autoSkip: false },
//                grid: { display: false }
//            }
//        }
//    };
//}
//function setActChartType(type) {
//    _actChartType = type;
//    var btnLine = document.getElementById('btnActLine');
//    var btnBar = document.getElementById('btnActBar');
//    if (btnLine) btnLine.className = (type === 'line')
//        ? 'btn btn-primary btn-sm' : 'btn btn-outline-primary btn-sm';
//    if (btnBar) btnBar.className = (type === 'bar')
//        ? 'btn btn-primary btn-sm' : 'btn btn-outline-primary btn-sm';
//    renderActivityTrendChart();
//}

//function renderActivityTrendChart() {
//    var hf = document.getElementById('hfActivityTrendData');
//    if (!hf || !hf.value) return;
//    var data;
//    try { data = JSON.parse(hf.value); } catch (e) { return; }
//    var ctx = document.getElementById('activityTrendChart');
//    if (!ctx) return;

//    if (activityChartInstance) { activityChartInstance.destroy(); activityChartInstance = null; }

//    var labels = data.map(function (d) { return d.DayLabel; });
//    var counts = data.map(function (d) { return d.ActionCount; });
//    var gradient;

//    if (_actChartType === 'line') {
//        // Build canvas gradient for fill
//        var chartCtx = ctx.getContext('2d');
//        gradient = chartCtx.createLinearGradient(0, 0, 0, 180);
//        gradient.addColorStop(0, 'rgba(21,101,192,0.25)');
//        gradient.addColorStop(1, 'rgba(21,101,192,0.02)');
//    }

//    activityChartInstance = new Chart(ctx, {
//        type: _actChartType,
//        data: {
//            labels: labels,
//            datasets: [{
//                label: 'Actions',
//                data: counts,
//                backgroundColor: _actChartType === 'line'
//                    ? gradient
//                    : counts.map(function (v, i) {
//                        var max = Math.max.apply(null, counts);
//                        return v === max ? '#1565c0cc' : '#1976d244';
//                    }),
//                borderColor: '#1565c0',
//                borderWidth: _actChartType === 'line' ? 2.5 : 2,
//                borderRadius: _actChartType === 'bar' ? 7 : 0,
//                pointBackgroundColor: '#1565c0',
//                pointRadius: _actChartType === 'line' ? 4 : 0,
//                pointHoverRadius: 6,
//                fill: _actChartType === 'line',
//                tension: 0.4
//            }]
//        },
//        options: {
//            responsive: true,
//            maintainAspectRatio: false,
//            plugins: {
//                legend: { display: false },
//                tooltip: {
//                    callbacks: {
//                        label: function (c) { return ' ' + c.parsed.y + ' actions'; }
//                    }
//                }
//            },
//            scales: {
//                y: {
//                    beginAtZero: true,
//                    ticks: { stepSize: 1, font: { size: 10 } },
//                    grid: { color: '#e3f2fd' }
//                },
//                x: {
//                    ticks: { font: { size: 10 }, maxRotation: 0 },
//                    grid: { display: false }
//                }
//            }
//        }
//    });
//}
//// Initialize everything when page loads
//document.addEventListener('DOMContentLoaded', function () {
//    renderDivisionChart();
//    renderSubjectChart();
//    renderAvgMarksChart();
//    initCompareData();
//    renderCmpChart();
//    renderEngagementChart();
//    renderActivityTrendChart();
//    renderLpPieChart();
//    initLpFullData();
//});
//// ── Engagement Chart ────────────────────────────────────────
//var engagementChart = null;

//function renderEngagementChart() {
//    var hf = document.getElementById('hfEngagementData');
//    if (!hf || !hf.value) return;
//    var data;
//    try { data = JSON.parse(hf.value); } catch (e) { return; }

//    var ctx = document.getElementById('engagementChart');
//    if (!ctx) return;

//    if (engagementChart) { engagementChart.destroy(); engagementChart = null; }

//    var chartTypeEl = document.getElementById('<%= ddlEngagementChartType.ClientID %>');
//    var chartType = chartTypeEl ? chartTypeEl.value : 'bar';

//    var colors = ['#1565c0', '#2e7d32', '#ef6c00', '#5e35b1', '#00838f', '#c62828', '#4527a0'];

//    var chartData = {
//        labels: data.map(function (d) { return d.VideoName; }),
//        datasets: [{
//            label: 'Avg Watch %',
//            data: data.map(function (d) { return d.WatchPercent; }),
//            backgroundColor: data.map(function (_, i) { return colors[i % colors.length] + 'cc'; }),
//            borderColor: data.map(function (_, i) { return colors[i % colors.length]; }),
//            borderWidth: 2,
//            borderRadius: chartType !== 'pie' ? 8 : 0
//        }]
//    };

//    var scalesConfig = chartType !== 'pie' ? {
//        y: {
//            beginAtZero: true,
//            max: 100,
//            ticks: { callback: function (v) { return v + '%'; }, font: { size: 11 } },
//            grid: { color: '#e3f2fd' }
//        },
//        x: {
//            ticks: { font: { size: 10 }, maxRotation: 35 },
//            grid: { display: false }
//        }
//    } : {};

//    var options = {
//        responsive: true,
//        maintainAspectRatio: false,
//        plugins: {
//            legend: { display: chartType === 'pie', position: 'top', labels: { font: { size: 11 } } },
//            tooltip: {
//                callbacks: {
//                    label: function (c) {
//                        if (chartType === 'pie') {
//                            var total = c.dataset.data.reduce(function (a, v) { return a + v; }, 0);
//                            var pct = ((c.parsed / total) * 100).toFixed(1);
//                            return ' ' + c.label + ': ' + c.parsed + '% (' + pct + '% of total)';
//                        }
//                        return ' ' + c.dataset.label + ': ' + c.parsed.y + '%';
//                    }
//                }
//            }
//        },
//        scales: scalesConfig
//    };

//    if (chartType === 'pie') {
//        engagementChart = new Chart(ctx, { type: 'pie', data: chartData, options: options });
//    } else if (chartType === 'horizontalBar') {
//        engagementChart = new Chart(ctx, { type: 'bar', data: chartData, options: Object.assign({}, options, { indexAxis: 'y' }) });
//    } else {
//        engagementChart = new Chart(ctx, { type: 'bar', data: chartData, options: options });
//    }
//}
//// ── Learning Path Pie Chart ─────────────────────────────────
//var lpPieChartInstance = null;

//function renderLpPieChart() {
//    var hf = document.getElementById('hfLpPieData');
//    if (!hf || !hf.value) return;
//    var data;
//    try { data = JSON.parse(hf.value); } catch (e) { return; }
//    var ctx = document.getElementById('lpPieChart');
//    if (!ctx) return;

//    if (lpPieChartInstance) { lpPieChartInstance.destroy(); lpPieChartInstance = null; }

//    lpPieChartInstance = new Chart(ctx, {
//        type: 'doughnut',
//        data: {
//            labels: data.map(function (d) { return d.SubjectName; }),
//            datasets: [{
//                data: data.map(function (d) { return d.SyllabusCompletionPct; }),
//                backgroundColor: data.map(function (d) { return d.Color + 'cc'; }),
//                borderColor: data.map(function (d) { return d.Color; }),
//                borderWidth: 2,
//                hoverOffset: 6
//            }]
//        },
//        options: {
//            responsive: true,
//            maintainAspectRatio: false,
//            cutout: '55%',
//            plugins: {
//                legend: { display: false },
//                tooltip: {
//                    callbacks: {
//                        label: function (c) {
//                            return ' ' + c.label + ': ' + c.parsed + '% done';
//                        }
//                    }
//                }
//            }
//        }
//    });
//}
//// ── Subject Progress Modal ──────────────────────────────────
//var _lpFullData = null;
//var subjectProgressChartInstance = null;

//function initLpFullData() {
//    var hf = document.getElementById('hfLpPieData');
//    if (!hf || !hf.value) return;
//    try { _lpFullData = JSON.parse(hf.value); } catch (e) { }
//}

//function openSubjectProgress(idx) {
//    if (!_lpFullData || idx >= _lpFullData.length) return;
//    var d = _lpFullData[idx];

//    // Header
//    document.getElementById('modalSubjectName').textContent = d.SubjectName;
//    document.getElementById('modalSubjectMeta').textContent =
//        d.StudentCount + ' students enrolled';

//    // KPI cards
//    document.getElementById('spStudents').textContent = d.StudentCount;
//    document.getElementById('spSyllabus').textContent = d.SyllabusCompletionPct + '%';
//    document.getElementById('spAvgWatch').textContent = d.AvgWatchPercent + '%';
//    document.getElementById('spVideos').textContent = d.VideosWatched + '/' + d.TotalVideos;

//    // Progress bars
//    var sylPct = parseFloat(d.SyllabusCompletionPct) || 0;
//    var vidPct = d.TotalVideos > 0
//        ? Math.round(d.VideosWatched / d.TotalVideos * 100)
//        : 0;
//    var chPct = d.TotalChapters > 0
//        ? Math.round(d.ChaptersCovered / d.TotalChapters * 100)
//        : 0;

//    document.getElementById('spSyllabusBar').style.width = sylPct + '%';
//    document.getElementById('spSyllabusBarLbl').textContent = sylPct + '%';
//    document.getElementById('spVideosBar').style.width = vidPct + '%';
//    document.getElementById('spVideosBarLbl').textContent =
//        d.VideosWatched + ' / ' + d.TotalVideos;
//    document.getElementById('spChaptersBar').style.width = chPct + '%';
//    document.getElementById('spChaptersBarLbl').textContent =
//        d.ChaptersCovered + ' / ' + d.TotalChapters;

//    // Show modal first so canvas has dimensions
//    var modal = new bootstrap.Modal(document.getElementById('subjectProgressModal'));
//    modal.show();

//    // Render chart after modal is visible
//    setTimeout(function () {
//        var ctx = document.getElementById('subjectProgressChart');
//        if (!ctx) return;
//        if (subjectProgressChartInstance) {
//            subjectProgressChartInstance.destroy();
//            subjectProgressChartInstance = null;
//        }

//        var color = d.Color || '#1565c0';

//        subjectProgressChartInstance = new Chart(ctx, {
//            type: 'bar',
//            data: {
//                labels: ['Syllabus %', 'Avg Watch %', 'Videos Done %', 'Chapters Done %'],
//                datasets: [{
//                    label: d.SubjectName,
//                    data: [sylPct, parseFloat(d.AvgWatchPercent) || 0, vidPct, chPct],
//                    backgroundColor: [
//                        '#1565c0cc', '#2e7d32cc', '#ef6c00cc', '#5e35b1cc'
//                    ],
//                    borderColor: [
//                        '#1565c0', '#2e7d32', '#ef6c00', '#5e35b1'
//                    ],
//                    borderWidth: 2,
//                    borderRadius: 8
//                }]
//            },
//            options: {
//                responsive: true,
//                maintainAspectRatio: false,
//                plugins: {
//                    legend: { display: false },
//                    tooltip: {
//                        callbacks: {
//                            label: function (c) { return ' ' + c.parsed.y + '%'; }
//                        }
//                    }
//                },
//                scales: {
//                    y: {
//                        beginAtZero: true,
//                        max: 100,
//                        ticks: {
//                            callback: function (v) { return v + '%'; },
//                            font: { size: 11 }
//                        },
//                        grid: { color: '#e3f2fd' }
//                    },
//                    x: {
//                        ticks: { font: { size: 11 } },
//                        grid: { display: false }
//                    }
//                }
//            }
//        });
//    }, 300);
//}

// ==================== TEACHER DASHBOARD - COMPLETE SCRIPT ====================
// FIXED: Removed all ASP.NET server tags - now accepts element IDs as parameters
// This version works as an external .js file

// Global chart instances
var chartInstance = null;
var asgChartInstance = null;
var divisionChartInstance = null;
var avgMarksChartInstance = null;

// Comparison Analytics variables
var _cmpTab = 'section';
var _cmpMetric = 'marks';
var _secData = null;
var _subData = null;
var _secChart = null;
var _subChart = null;

// Activity Trend Chart
var activityChartInstance = null;
var _actChartType = 'line';

// Engagement Chart
var engagementChart = null;

// Learning Path Pie Chart
var lpPieChartInstance = null;
var _lpFullData = null;
var subjectProgressChartInstance = null;

// Student Marks Modal Chart
var studentMarksChartInstance = null;

// Store element IDs for dynamic access
var elementIds = {};

// ========== INITIALIZATION FUNCTION (Call from ASPX with IDs) ==========
function initTeacherDashboard(chartIds, panelIds, dropdownIds) {
    // Store all the ASP.NET control IDs
    elementIds = {
        hfChartData: chartIds.hfChartData,
        hfDivisionData: chartIds.hfDivisionData,
        hfAvgMarksData: chartIds.hfAvgMarksData,
        hfAsgChartData: chartIds.hfAsgChartData,
        hfEngagementData: chartIds.hfEngagementData,
        hfActivityTrendData: chartIds.hfActivityTrendData,
        hfLpPieData: chartIds.hfLpPieData,
        hfSecCompareData: chartIds.hfSecCompareData,
        hfSubCompareData: chartIds.hfSubCompareData,
        pnlAssignments: panelIds.pnlAssignments,
        pnlAsgChart: panelIds.pnlAsgChart,
        pnlNoSecCompare: panelIds.pnlNoSecCompare,
        pnlNoSubCompare: panelIds.pnlNoSubCompare,
        ddlEngagementChartType: dropdownIds.ddlEngagementChartType
    };

    // Initialize all charts
    renderDivisionChart();
    renderSubjectChart();
    renderAvgMarksChart();
    renderAsgChart();
    initCompareData();
    renderCmpChart();
    renderEngagementChart();
    renderActivityTrendChart();
    renderLpPieChart();
    initLpFullData();
    initActivityLogDisplay();
}

// ========== 1. SUBJECT CHART (Students per Subject) ==========
function renderSubjectChart() {
    var hf = document.getElementById(elementIds.hfChartData);
    if (!hf || !hf.value) return;
    var data;
    try { data = JSON.parse(hf.value); } catch (e) { return; }
    var ctx = document.getElementById('subjectChart');
    if (!ctx) return;
    if (chartInstance) { chartInstance.destroy(); chartInstance = null; }

    var labels = data.map(function (d) { return d.SubjectName; });
    var counts = data.map(function (d) { return d.StudentCount; });
    var subIds = data.map(function (d) { return d.SubjectId; });
    var colors = ['#1565c0', '#0288d1', '#1976d2', '#ef6c00', '#5e35b1',
        '#388e3c', '#c62828', '#00838f', '#4527a0', '#2e7d32'];

    chartInstance = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: labels,
            datasets: [{
                label: 'Students Enrolled',
                data: counts,
                backgroundColor: labels.map(function (_, i) { return colors[i % colors.length] + 'cc'; }),
                borderColor: labels.map(function (_, i) { return colors[i % colors.length]; }),
                borderWidth: 2,
                borderRadius: 8
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: { display: false },
                tooltip: { callbacks: { label: function (c) { return ' ' + c.parsed.y + ' students'; } } }
            },
            scales: {
                y: { beginAtZero: true, ticks: { stepSize: 1, font: { size: 11 } }, grid: { color: '#e3f2fd' } },
                x: { ticks: { font: { size: 11 }, maxRotation: 30 }, grid: { display: false } }
            },
            onClick: function (evt, elements) {
                if (elements.length > 0)
                    window.location.href = 'SubjectAnalytics.aspx?SubjectId=' + subIds[elements[0].index];
            }
        }

    });
    ctx.style.cursor = 'pointer';
}

// ========== 2. ASSIGNMENT VIEW TOGGLE & CHART ==========
function setAsgView(v) {
    var listPanel = document.getElementById(elementIds.pnlAssignments);
    var chartPanel = document.getElementById(elementIds.pnlAsgChart);
    if (listPanel) listPanel.style.display = (v === 'list') ? 'block' : 'none';
    if (chartPanel) chartPanel.style.display = (v === 'chart') ? 'block' : 'none';
    if (v === 'chart') renderAsgChart();

    var btnList = document.getElementById('btnAsgList');
    var btnChart = document.getElementById('btnAsgChart');
    if (btnList && btnChart) {
        if (v === 'list') {
            btnList.className = 'btn btn-primary btn-sm';
            btnChart.className = 'btn btn-outline-primary btn-sm';
        } else {
            btnList.className = 'btn btn-outline-primary btn-sm';
            btnChart.className = 'btn btn-primary btn-sm';
        }
    }
}

function renderAsgChart() {
    setTimeout(function () {
        var hf = document.getElementById(elementIds.hfAsgChartData); // ← moved inside
        if (!hf || !hf.value) return;
        var data;
        try { data = JSON.parse(hf.value); } catch (e) { return; }

        var ctx = document.getElementById('asgChart');
        if (!ctx) return;
        if (asgChartInstance) { asgChartInstance.destroy(); asgChartInstance = null; }

        asgChartInstance = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: data.map(function (d) { return d.Title; }),
                datasets: [
                    {
                        label: 'Submitted',
                        data: data.map(function (d) { return d.SubmissionCount; }),
                        backgroundColor: '#1565c0cc',
                        borderColor: '#1565c0',
                        borderWidth: 2,
                        borderRadius: 6
                    },
                    {
                        label: 'Pending',
                        data: data.map(function (d) { return d.Pending; }),
                        backgroundColor: '#ef6c00cc',
                        borderColor: '#ef6c00',
                        borderWidth: 2,
                        borderRadius: 6
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: true, position: 'top', labels: { font: { size: 11 } } },
                    tooltip: {
                        callbacks: {
                            label: function (c) {
                                return ' ' + c.dataset.label + ': ' + c.parsed.y + ' students';
                            }
                        }
                    }
                },
                scales: {
                    x: { ticks: { font: { size: 10 }, maxRotation: 30 }, grid: { display: false } },
                    y: { beginAtZero: true, ticks: { stepSize: 1, font: { size: 11 } }, grid: { color: '#e3f2fd' } }
                }
            }
        });
    }, 300);
}// ========== 3. DIVISION CHART ==========
function renderDivisionChart() {
    var hf = document.getElementById(elementIds.hfDivisionData);
    if (!hf || !hf.value) return;
    var data;
    try { data = JSON.parse(hf.value); } catch (e) { return; }
    var ctx = document.getElementById('divisionChart');
    if (!ctx) return;
    if (divisionChartInstance) { divisionChartInstance.destroy(); divisionChartInstance = null; }

    var divLabels = data.map(function (d) { return d.Division; });
    var colors = ['#1565c0', '#2e7d32', '#ef6c00', '#5e35b1', '#0288d1', '#c62828'];

    divisionChartInstance = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: divLabels,
            datasets: [{
                label: 'Students',
                data: data.map(function (d) { return d.StudentCount; }),
                backgroundColor: data.map(function (_, i) { return colors[i % colors.length] + 'cc'; }),
                borderColor: data.map(function (_, i) { return colors[i % colors.length]; }),
                borderWidth: 2,
                borderRadius: 6
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            // ← NO onClick here — handled by canvas listener below
            plugins: {
                legend: { display: false },
                tooltip: {
                    callbacks: {
                        title: function (items) { return items[0].label; },
                        label: function (c) { return c.parsed.y + ' students — click to view'; }
                    }
                }
            },
            scales: {
                y: { beginAtZero: true, ticks: { stepSize: 1, font: { size: 10 } }, grid: { color: '#e3f2fd' } },
                x: { ticks: { font: { size: 10 }, maxRotation: 30 }, grid: { display: false } }
            }
        }
    });
    ctx.style.cursor = 'pointer';

    // ── Single canvas click handler ──
    ctx.addEventListener('click', function (evt) {
        var points = divisionChartInstance.getElementsAtEventForMode(
            evt, 'nearest', { intersect: true }, false
        );
        if (points && points.length > 0) {
            openSectionStudentsModal(divLabels[points[0].index]);
        }
    });
}
function renderAvgMarksChart() {
    var hf = document.getElementById(elementIds.hfAvgMarksData);
    if (!hf || !hf.value) return;
    var data;
    try { data = JSON.parse(hf.value); } catch (e) { return; }
    var ctx = document.getElementById('avgMarksChart');
    if (!ctx) return;
    if (avgMarksChartInstance) { avgMarksChartInstance.destroy(); avgMarksChartInstance = null; }

    avgMarksChartInstance = new Chart(ctx, {
        type: 'pie',
        data: {
            labels: data.map(function (d) { return d.SubjectName; }),
            datasets: [{
                data: data.map(function (d) { return d.AvgMarks; }),
                backgroundColor: data.map(function (d) { return d.Color + 'cc'; }),
                borderColor: data.map(function (d) { return d.Color; }),
                borderWidth: 2
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: { display: false },
                tooltip: { callbacks: { label: function (c) { return ' ' + c.label + ': ' + c.parsed + ' avg marks'; } } }
            }
        }
    });
}

// ========== 5. STUDENT MARKS MODAL ==========
function openStudentModal(studentId, studentName, subjectName) {
    console.log('Navigating with studentId:', studentId); // check this value
    window.location.href = 'MyStudentDetails.aspx?UserId=' + studentId;
    return;

    //the below code is unused
    document.getElementById('modalStudentName').textContent = studentName;
    document.getElementById('modalStudentMeta').textContent = subjectName;

    var loader = document.getElementById('modalLoader');
    var kpiRow = document.getElementById('modalKpiRow');
    var chartCanvas = document.getElementById('studentMarksChart');
    var asgTable = document.getElementById('modalAsgTable');
    var emptyDiv = document.getElementById('modalEmpty');

    if (loader) loader.style.display = 'block';
    if (kpiRow) kpiRow.style.display = 'none';
    if (chartCanvas) chartCanvas.style.display = 'none';
    if (asgTable) asgTable.style.display = 'none';
    if (emptyDiv) emptyDiv.style.display = 'none';

    var modal = new bootstrap.Modal(document.getElementById('studentMarksModal'));
    modal.show();

    fetch('GetStudentMarks.ashx?studentId=' + studentId)
        .then(function (r) { return r.json(); })
        .then(function (data) {
            if (loader) loader.style.display = 'none';
            if (!Array.isArray(data) || data.length === 0) {
                if (emptyDiv) emptyDiv.style.display = 'block';
                return;
            }

            var total = data.length;
            var sumMarks = data.reduce(function (s, d) { return s + d.MarksObtained; }, 0);
            var avg = Math.round(sumMarks / total);
            var highest = Math.max.apply(null, data.map(function (d) { return d.MarksObtained; }));
            var lowest = Math.min.apply(null, data.map(function (d) { return d.MarksObtained; }));

            document.getElementById('modalTotalAsg').textContent = total;
            document.getElementById('modalAvgMarks').textContent = avg;
            document.getElementById('modalHighest').textContent = highest;
            document.getElementById('modalLowest').textContent = lowest;
            if (kpiRow) kpiRow.style.display = '';

            if (chartCanvas) chartCanvas.style.display = 'block';
            if (studentMarksChartInstance) studentMarksChartInstance.destroy();

            var labels = data.map(function (d) { return d.AssignmentTitle; });
            var obtained = data.map(function (d) { return d.MarksObtained; });
            var maxMarks = data.map(function (d) { return d.MaxMarks; });
            var pcts = data.map(function (d) { return d.Percentage; });

            var barColors = pcts.map(function (p) {
                if (p >= 80) return '#2e7d32cc';
                if (p >= 60) return '#1565c0cc';
                if (p >= 50) return '#ef6c00cc';
                return '#c62828cc';
            });
            var borderColors = pcts.map(function (p) {
                if (p >= 80) return '#2e7d32';
                if (p >= 60) return '#1565c0';
                if (p >= 50) return '#ef6c00';
                return '#c62828';
            });

            studentMarksChartInstance = new Chart(chartCanvas, {
                type: 'bar',
                data: {
                    labels: labels,
                    datasets: [
                        {
                            label: 'Marks Obtained',
                            data: obtained,
                            backgroundColor: barColors,
                            borderColor: borderColors,
                            borderWidth: 2,
                            borderRadius: 8,
                            order: 1
                        },
                        {
                            label: 'Max Marks',
                            data: maxMarks,
                            type: 'line',
                            borderColor: '#90a4ae',
                            borderWidth: 2,
                            borderDash: [6, 3],
                            pointRadius: 4,
                            pointBackgroundColor: '#90a4ae',
                            fill: false,
                            tension: 0.3,
                            order: 0
                        }
                    ]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: { display: true, position: 'top', labels: { font: { size: 11 } } },
                        tooltip: {
                            callbacks: {
                                label: function (c) {
                                    if (c.datasetIndex === 0) return ' Marks: ' + c.parsed.y + ' (' + pcts[c.dataIndex] + '%)';
                                    return ' Max: ' + c.parsed.y;
                                }
                            }
                        }
                    },
                    scales: {
                        y: { beginAtZero: true, ticks: { stepSize: 1, font: { size: 11 } }, grid: { color: '#e3f2fd' } },
                        x: { ticks: { font: { size: 10 }, maxRotation: 35 }, grid: { display: false } }
                    }
                }
            });

            var tbody = document.getElementById('modalAsgTableBody');
            if (tbody) {
                tbody.innerHTML = '';
                data.forEach(function (d, i) {
                    var gradeColor = d.Percentage >= 80 ? '#2e7d32'
                        : d.Percentage >= 60 ? '#1565c0'
                            : d.Percentage >= 50 ? '#ef6c00' : '#c62828';
                    tbody.innerHTML += '<tr>' +
                        '<td style="color:#90a4ae;">' + (i + 1) + '</td>' +
                        '<td><strong>' + d.AssignmentTitle + '</strong></td>' +
                        '<td style="color:#78909c;">' + d.SubjectName + '</td>' +
                        '<td><strong style="color:#263238;">' + d.MarksObtained + '</strong></td>' +
                        '<td style="color:#90a4ae;">' + d.MaxMarks + '</td>' +
                        '<td><strong style="color:' + gradeColor + ';">' + d.Percentage + '%</strong></td>' +
                        '<td><span style="background:' + gradeColor + '22;color:' + gradeColor + ';padding:2px 8px;border-radius:8px;font-size:11px;font-weight:700;">' + d.Grade + '</span></td>' +
                        '<td style="color:#90a4ae;">' + d.SubmittedOn + '</td>' +
                        '</tr>';
                });
            }
            if (asgTable) asgTable.style.display = '';
        })
        .catch(function () {
            if (loader) loader.style.display = 'none';
            if (emptyDiv) emptyDiv.style.display = 'block';
        });
}

// ========== 6. COMPARISON ANALYTICS ==========
function initCompareData() {
    var hfSec = document.getElementById(elementIds.hfSecCompareData);
    var hfSub = document.getElementById(elementIds.hfSubCompareData);
    try { if (hfSec && hfSec.value) _secData = JSON.parse(hfSec.value); } catch (e) { }
    try { if (hfSub && hfSub.value) _subData = JSON.parse(hfSub.value); } catch (e) { }
}

function switchCompareTab(tab) {
    _cmpTab = tab;
    var tabSec = document.getElementById('tabSec');
    var tabSub = document.getElementById('tabSub');
    if (tabSec) tabSec.className = 'compare-tab' + (tab === 'section' ? ' active' : '');
    if (tabSub) tabSub.className = 'compare-tab' + (tab === 'subject' ? ' active' : '');
    var pSec = document.getElementById('pnlCompareSections');
    var pSub = document.getElementById('pnlCompareSubjects');
    if (pSec) pSec.style.display = (tab === 'section') ? 'block' : 'none';
    if (pSub) pSub.style.display = (tab === 'subject') ? 'block' : 'none';
    renderCmpChart();
    return false;
}

function switchMetric(metric) {
    _cmpMetric = metric;
    var btnMarks = document.getElementById('btnMarks');
    var btnAttend = document.getElementById('btnAttend');
    var btnEngage = document.getElementById('btnEngage');
    if (btnMarks) btnMarks.className = 'metric-btn marks' + (metric === 'marks' ? ' active' : '');
    if (btnAttend) btnAttend.className = 'metric-btn attend' + (metric === 'attendance' ? ' active' : '');
    if (btnEngage) btnEngage.className = 'metric-btn engage' + (metric === 'engagement' ? ' active' : '');
    renderCmpChart();
    return false;
}

function cmpMetricField() {
    if (_cmpMetric === 'marks') return 'AvgMarks';
    if (_cmpMetric === 'attendance') return 'AttendancePct';
    return 'VideoViews';
}

function cmpMetricLabel() {
    if (_cmpMetric === 'marks') return 'Avg Marks';
    if (_cmpMetric === 'attendance') return 'Attendance %';
    return 'Video Views';
}

function cmpMetricColor() {
    if (_cmpMetric === 'marks') return '#2e7d32';
    if (_cmpMetric === 'attendance') return '#ef6c00';
    return '#5e35b1';
}

function renderCmpChart() {
    if (_cmpTab === 'section') renderCmpSectionChart();
    else renderCmpSubjectChart();
}

function renderCmpSectionChart() {
    var ctx = document.getElementById('secCompareChart');
    if (!ctx) return;
    if (_secChart) _secChart.destroy();
    if (!_secData || _secData.length === 0) {
        ctx.style.display = 'none';
        var emp = document.getElementById(elementIds.pnlNoSecCompare);
        if (emp) emp.style.display = 'block';
        return;
    }
    ctx.style.display = 'block';
    var emp2 = document.getElementById(elementIds.pnlNoSecCompare);
    if (emp2) emp2.style.display = 'none';

    var field = cmpMetricField(), mc = cmpMetricColor();
    var labels = _secData.map(d => d.SectionName || 'No Section');
    var vals = _secData.map(d => parseFloat(d[field]) || 0);

    var pieColors = ['#1565c0', '#2e7d32', '#ef6c00', '#5e35b1', '#0288d1', '#c62828', '#00838f', '#f9a825'];

    _secChart = new Chart(ctx, {
        type: 'pie',
        data: {
            labels: labels,
            datasets: [{
                data: vals,
                backgroundColor: labels.map((_, i) => pieColors[i % pieColors.length] + 'cc'),
                borderColor: labels.map((_, i) => pieColors[i % pieColors.length]),
                borderWidth: 2,
                hoverOffset: 8
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    display: true,
                    position: 'right',
                    labels: { font: { size: 11 }, padding: 14 }
                },
                tooltip: {
                    callbacks: {
                        label: function (c) {
                            var v = c.parsed;
                            var total = c.dataset.data.reduce((a, b) => a + b, 0);
                            var pct = total > 0 ? ((v / total) * 100).toFixed(1) : 0;
                            if (_cmpMetric === 'attendance') return ' ' + c.label + ': ' + v + '% (' + pct + '% share)';
                            if (_cmpMetric === 'engagement') return ' ' + c.label + ': ' + v + ' views (' + pct + '% share)';
                            return ' ' + c.label + ': ' + v + ' avg marks (' + pct + '% share)';
                        }
                    }
                }
            }
        }
    });
}

function renderCmpSubjectChart() {
    var ctx = document.getElementById('subCompareChart');
    if (!ctx) return;
    if (_subChart) _subChart.destroy();
    if (!_subData || _subData.length === 0) {
        ctx.style.display = 'none';
        var emp = document.getElementById(elementIds.pnlNoSubCompare);
        if (emp) emp.style.display = 'block';
        return;
    }
    ctx.style.display = 'block';
    var emp2 = document.getElementById(elementIds.pnlNoSubCompare);
    if (emp2) emp2.style.display = 'none';

    var field = cmpMetricField();
    var labels = _subData.map(d => d.SubjectName);
    var vals = _subData.map(d => parseFloat(d[field]) || 0);

    var pieColors = ['#1565c0', '#2e7d32', '#ef6c00', '#5e35b1', '#0288d1', '#c62828', '#00838f', '#f9a825'];

    _subChart = new Chart(ctx, {
        type: 'pie',
        data: {
            labels: labels,
            datasets: [{
                data: vals,
                backgroundColor: labels.map((_, i) => pieColors[i % pieColors.length] + 'cc'),
                borderColor: labels.map((_, i) => pieColors[i % pieColors.length]),
                borderWidth: 2,
                hoverOffset: 8
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    display: true,
                    position: 'right',
                    labels: { font: { size: 11 }, padding: 14 }
                },
                tooltip: {
                    callbacks: {
                        label: function (c) {
                            var v = c.parsed;
                            var total = c.dataset.data.reduce((a, b) => a + b, 0);
                            var pct = total > 0 ? ((v / total) * 100).toFixed(1) : 0;
                            if (_cmpMetric === 'attendance') return ' ' + c.label + ': ' + v + '% (' + pct + '% share)';
                            if (_cmpMetric === 'engagement') return ' ' + c.label + ': ' + v + ' views (' + pct + '% share)';
                            return ' ' + c.label + ': ' + v + ' avg marks (' + pct + '% share)';
                        }
                    }
                }
            }
        }
    });
}

// ========== 7. ACTIVITY TREND CHART ==========
function setActChartType(type) {
    _actChartType = type;
    var btnLine = document.getElementById('btnActLine');
    var btnBar = document.getElementById('btnActBar');
    if (btnLine) btnLine.className = (type === 'line') ? 'btn btn-primary btn-sm' : 'btn btn-outline-primary btn-sm';
    if (btnBar) btnBar.className = (type === 'bar') ? 'btn btn-primary btn-sm' : 'btn btn-outline-primary btn-sm';
    renderActivityTrendChart();
}

function renderActivityTrendChart() {
    var hf = document.getElementById(elementIds.hfActivityTrendData);
    if (!hf || !hf.value) return;
    var data;
    try { data = JSON.parse(hf.value); } catch (e) { return; }
    var ctx = document.getElementById('activityTrendChart');
    if (!ctx) return;
    if (activityChartInstance) activityChartInstance.destroy();

    var labels = data.map(d => d.DayLabel);
    var assignments = data.map(d => d.AssignmentCount);
    var videos = data.map(d => d.VideoCount);

    activityChartInstance = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: labels,
            datasets: [
                {
                    label: 'Assignments',
                    data: assignments,
                    backgroundColor: '#1565c0cc',
                    borderColor: '#1565c0',
                    borderWidth: 2,
                    borderRadius: 6
                },
                {
                    label: 'Videos',
                    data: videos,
                    backgroundColor: '#5e35b1cc',
                    borderColor: '#5e35b1',
                    borderWidth: 2,
                    borderRadius: 6
                }
            ]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    display: true,
                    position: 'top',
                    labels: { font: { size: 10 }, boxWidth: 12 }
                },
                tooltip: {
                    callbacks: {
                        label: function (c) {
                            return ' ' + c.dataset.label + ': ' + c.parsed.y;
                        }
                    }
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    ticks: { stepSize: 1, font: { size: 10 } },
                    grid: { color: '#e3f2fd' }
                },
                x: {
                    ticks: { font: { size: 10 }, maxRotation: 0 },
                    grid: { display: false }
                }
            }
        }
    });
}

// ========== ACTIVITY LOG: SHOW TOP 2 + SEE MORE MODAL ==========
// ========== ACTIVITY LOG: SHOW TOP 2 + SEE MORE MODAL ==========
function initActivityLogDisplay() {
    // Give the page a moment to fully render
    setTimeout(function () {
        // Find all activity log items
        var items = document.querySelectorAll('.activity-log-item');
        console.log('Found activity items:', items.length);

        if (!items || items.length === 0) {
            // Try alternative selector if needed
            var altItems = document.querySelectorAll('#pnlActivityLog .activity-log-item, #Panel1 .activity-log-item');
            if (altItems && altItems.length > 0) {
                items = altItems;
                console.log('Found via alt selector:', items.length);
            }
        }

        if (items && items.length > 0) {
            // Hide items beyond the first 2
            items.forEach(function (item, i) {
                if (i >= 2) {
                    item.style.display = 'none';
                } else {
                    item.style.display = 'flex'; // Ensure first 2 are visible
                }
            });

            // Show "See more" button only if there are more than 2
            var btn = document.getElementById('activitySeeMoreBtn');
            if (btn) {
                btn.style.display = items.length > 2 ? 'block' : 'none';
                console.log('See more button display:', btn.style.display);
            }
        } else {
            // Hide see more button if no items
            var btn = document.getElementById('activitySeeMoreBtn');
            if (btn) btn.style.display = 'none';
        }
    }, 100); // Small delay to ensure DOM is ready
}

function openAllActivityModal() {
    // Find all activity items (including hidden ones)
    var items = document.querySelectorAll('.activity-log-item');

    // Also check if items are inside specific panels
    if (!items || items.length === 0) {
        items = document.querySelectorAll('#pnlActivityLog .activity-log-item, #Panel1 .activity-log-item');
    }

    var modal = new bootstrap.Modal(document.getElementById('allActivityModal'));
    modal.show();

    var body = document.getElementById('allActivityModalBody');
    if (!body) return;

    if (!items || items.length === 0) {
        body.innerHTML = '<div style="text-align:center;padding:30px;color:#90a4ae;">'
            + '<i class="fas fa-history" style="font-size:32px;display:block;margin-bottom:8px;"></i>'
            + 'No activity recorded yet.</div>';
        return;
    }

    // Clone all activity items into the modal
    var html = '';
    items.forEach(function (item) {
        html += item.outerHTML;
    });

    body.innerHTML = '<div id="allActivityList" style="max-height:500px;overflow-y:auto;">' + html + '</div>';

    // Ensure all are visible inside modal
    var cloned = body.querySelectorAll('.activity-log-item');
    cloned.forEach(function (item) {
        item.style.display = 'flex';
    });

    // Add highlight effect on hover
    var modalItems = body.querySelectorAll('.activity-log-item');
    modalItems.forEach(function (item) {
        item.addEventListener('mouseover', function () {
            this.style.background = '#f0f7ff';
            this.style.paddingLeft = '6px';
        });
        item.addEventListener('mouseout', function () {
            this.style.background = '';
            this.style.paddingLeft = '';
        });
    });
}
//function openAllActivityModal() {
//    var modal = new bootstrap.Modal(document.getElementById('allActivityModal'));
//    modal.show();

//    // Clone all activity items into the modal
//    var items = document.querySelectorAll('.activity-log-item');
//    var body = document.getElementById('allActivityModalBody');
//    if (!body) return;

//    if (!items || items.length === 0) {
//        body.innerHTML = '<div style="text-align:center;padding:30px;color:#90a4ae;">'
//            + '<i class="fas fa-history" style="font-size:32px;display:block;margin-bottom:8px;"></i>'
//            + 'No activity recorded yet.</div>';
//        return;
//    }

//    var html = '';
//    items.forEach(function (item) {
//        html += item.outerHTML;
//    });

//    // Wrap in a container and make all items visible inside the modal
//    body.innerHTML = '<div id="allActivityList">' + html + '</div>';

//    // Ensure all are visible inside modal (override the hidden ones)
//    var cloned = body.querySelectorAll('.activity-log-item');
//    cloned.forEach(function (item) {
//        item.style.display = 'flex';
//    });
//}
// ========== 8. ENGAGEMENT CHART ==========
function renderEngagementChart() {
    var hf = document.getElementById(elementIds.hfEngagementData);
    if (!hf || !hf.value) return;
    var data;
    try { data = JSON.parse(hf.value); } catch (e) { return; }
    var ctx = document.getElementById('engagementChart');
    if (!ctx) return;
    if (engagementChart) { engagementChart.destroy(); engagementChart = null; }
    if (!data || data.length === 0) return;

    var chartTypeEl = document.getElementById(elementIds.ddlEngagementChartType);
    var chartType = chartTypeEl ? chartTypeEl.value : 'bar';

    // ── Labels: "ChapterName – VideoTitle" ────────────────────────
    var labels = data.map(function (d) { return d.ChapterName + ' – ' + d.VideoName; });
    var chapterNames = data.map(function (d) { return d.ChapterName; });

    // ── One color per chapter ─────────────────────────────────────
    var palette = [
        '#ef4444', '#3b82f6', '#f59e0b', '#22c55e',
        '#a855f7', '#14b8a6', '#f97316', '#6366f1'
    ];
    var chapterColorMap = {};
    var colorIdx = 0;
    chapterNames.forEach(function (ch) {
        if (!chapterColorMap[ch]) {
            chapterColorMap[ch] = palette[colorIdx % palette.length];
            colorIdx++;
        }
    });

    var totalBg = chapterNames.map(function (ch) { return chapterColorMap[ch] + '99'; });
    var uniqueBg = chapterNames.map(function (ch) { return chapterColorMap[ch] + 'dd'; });
    var borders = chapterNames.map(function (ch) { return chapterColorMap[ch]; });

    var totalViews = data.map(function (d) { return d.TotalViews; });
    var uniqueViewers = data.map(function (d) { return d.UniqueViewers; });

    // ── Short x-axis label (video title only) ─────────────────────
    var shortLabels = labels.map(function (l) {
        var parts = l.split(' – ');
        return parts.length > 1 ? parts[1] : l;
    });

    // ── Shared tooltip title (full Chapter – Video) ───────────────
    var tooltipTitle = function (items) { return labels[items[0].dataIndex]; };

    // ══════════════════════════════════════════════════════════════
    // PIE CHART — two doughnuts side by side via custom HTML overlay
    // We render a single pie for Total Views; Unique is shown in legend
    // ══════════════════════════════════════════════════════════════
    if (chartType === 'pie') {
        engagementChart = new Chart(ctx, {
            type: 'pie',
            data: {
                labels: shortLabels,
                datasets: [
                    {
                        label: 'Total Views',
                        data: totalViews,
                        backgroundColor: totalBg,
                        borderColor: borders,
                        borderWidth: 2,
                        hoverOffset: 8
                    },
                    {
                        label: 'Unique Viewers',
                        data: uniqueViewers,
                        backgroundColor: uniqueBg,
                        borderColor: borders,
                        borderWidth: 2,
                        hoverOffset: 8
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        display: true,
                        position: 'right',
                        labels: { font: { size: 10 }, padding: 10 }
                    },
                    tooltip: {
                        callbacks: {
                            title: tooltipTitle,
                            label: function (c) {
                                return ' ' + c.dataset.label + ': ' + c.parsed;
                            }
                        }
                    }
                }
            }
        });
        return;
    }

    // ══════════════════════════════════════════════════════════════
    // BAR or HORIZONTAL BAR — grouped, two datasets
    // ══════════════════════════════════════════════════════════════
    var isHorizontal = chartType === 'horizontalBar';

    var scalesConfig = {
        x: {
            ticks: {
                font: { size: 10 },
                maxRotation: isHorizontal ? 0 : 45,
                callback: isHorizontal
                    ? undefined
                    : function (val, idx) { return shortLabels[idx]; }
            },
            grid: { display: isHorizontal }
        },
        y: {
            beginAtZero: true,
            ticks: { stepSize: 1, font: { size: 11 } },
            grid: { color: isHorizontal ? 'transparent' : '#e3f2fd' }
        }
    };

    // For horizontal bar Chart.js uses indexAxis:'y'
    // Labels on y-axis should be short
    var chartLabels = isHorizontal ? shortLabels : labels;

    engagementChart = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: chartLabels,
            datasets: [
                {
                    label: 'Total Views (Students)',
                    data: totalViews,
                    backgroundColor: totalBg,
                    borderColor: borders,
                    borderWidth: 2,
                    borderRadius: 6,
                    borderSkipped: false
                },
                {
                    label: 'Unique Student Viewers',
                    data: uniqueViewers,
                    backgroundColor: uniqueBg,
                    borderColor: borders,
                    borderWidth: 2,
                    borderRadius: 6,
                    borderSkipped: false
                }
            ]
        },
        options: {
            indexAxis: isHorizontal ? 'y' : 'x',
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    display: true,
                    position: 'top',
                    labels: { font: { size: 11 }, boxWidth: 14, padding: 14 }
                },
                tooltip: {
                    callbacks: {
                        title: tooltipTitle,
                        label: function (c) {
                            return ' ' + c.dataset.label + ': ' + c.parsed.y;
                        }
                    }
                }
            },
            scales: scalesConfig
        }
    });
}// ========== 9. LEARNING PATH PIE + MODAL ==========
function renderLpPieChart() {
    setTimeout(function () {
        var hf = document.getElementById(elementIds.hfLpPieData);
        if (!hf || !hf.value) return;
        var data;
        try { data = JSON.parse(hf.value); } catch (e) { return; }
        var ctx = document.getElementById('lpPieChart');
        if (!ctx) return;
        if (lpPieChartInstance) lpPieChartInstance.destroy();

        lpPieChartInstance = new Chart(ctx, {
            type: 'doughnut',
            data: {
                labels: data.map(function (d) { return d.SubjectName; }),
                datasets: [{
                    data: data.map(function (d) { return d.SyllabusCompletionPct; }),
                    backgroundColor: data.map(function (d) { return d.Color + 'cc'; }),
                    borderColor: data.map(function (d) { return d.Color; }),
                    borderWidth: 2,
                    hoverOffset: 6
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                cutout: '55%',
                plugins: {
                    legend: { display: false },
                    tooltip: {
                        callbacks: {
                            label: function (c) {
                                return ' ' + c.label + ': ' + c.parsed + '% done';
                            }
                        }
                    }
                }
            }
        });
    }, 300);
}
function initLpFullData() {
    var hf = document.getElementById(elementIds.hfLpPieData);
    if (!hf || !hf.value) return;
    try { _lpFullData = JSON.parse(hf.value); } catch (e) { }
}

function openSubjectProgress(idx) {
    if (!_lpFullData || idx >= _lpFullData.length) return;
    var d = _lpFullData[idx];
    document.getElementById('modalSubjectName').textContent = d.SubjectName;
    document.getElementById('modalSubjectMeta').textContent = d.StudentCount + ' students enrolled';
    document.getElementById('spStudents').textContent = d.StudentCount;
    document.getElementById('spSyllabus').textContent = d.SyllabusCompletionPct + '%';
    document.getElementById('spAvgWatch').textContent = d.AvgWatchPercent + '%';
    document.getElementById('spVideos').textContent = d.VideosWatched + '/' + d.TotalVideos;
    var sylPct = parseFloat(d.SyllabusCompletionPct) || 0;
    var vidPct = d.TotalVideos > 0 ? Math.round(d.VideosWatched / d.TotalVideos * 100) : 0;
    var chPct = d.TotalChapters > 0 ? Math.round(d.ChaptersCovered / d.TotalChapters * 100) : 0;
    document.getElementById('spSyllabusBar').style.width = sylPct + '%';
    document.getElementById('spSyllabusBarLbl').textContent = sylPct + '%';
    document.getElementById('spVideosBar').style.width = vidPct + '%';
    document.getElementById('spVideosBarLbl').textContent = d.VideosWatched + ' / ' + d.TotalVideos;
    document.getElementById('spChaptersBar').style.width = chPct + '%';
    document.getElementById('spChaptersBarLbl').textContent = d.ChaptersCovered + ' / ' + d.TotalChapters;
    var modal = new bootstrap.Modal(document.getElementById('subjectProgressModal'));
    modal.show();
    setTimeout(function () {
        var ctx = document.getElementById('subjectProgressChart');
        if (!ctx) return;
        if (subjectProgressChartInstance) subjectProgressChartInstance.destroy();
        subjectProgressChartInstance = new Chart(ctx, {
            type: 'bar',
            data: { labels: ['Syllabus %', 'Avg Watch %', 'Videos Done %', 'Chapters Done %'], datasets: [{ label: d.SubjectName, data: [sylPct, parseFloat(d.AvgWatchPercent) || 0, vidPct, chPct], backgroundColor: ['#1565c0cc', '#2e7d32cc', '#ef6c00cc', '#5e35b1cc'], borderColor: ['#1565c0', '#2e7d32', '#ef6c00', '#5e35b1'], borderWidth: 2, borderRadius: 8 }] },
            options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { display: false }, tooltip: { callbacks: { label: c => ' ' + c.parsed.y + '%' } } }, scales: { y: { beginAtZero: true, max: 100, ticks: { callback: v => v + '%', font: { size: 11 } }, grid: { color: '#e3f2fd' } }, x: { ticks: { font: { size: 11 } }, grid: { display: false } } } }
        });
    }, 300);
}
// ── Section chart click + modal ─────────────────────────────
var _allSectionStudents = [];

function openSectionStudentsModal(sectionName) {
    document.getElementById('sectionModalTitle').textContent = 'Section: ' + sectionName;
    document.getElementById('sectionModalMeta').textContent = 'Click any student to view details';
    document.getElementById('sectionStudentsLoading').style.display = '';
    document.getElementById('sectionStudentsList').style.display = 'none';
    document.getElementById('sectionStudentsEmpty').style.display = 'none';
    document.getElementById('sectionStudentSearch').value = '';

    var modal = new bootstrap.Modal(document.getElementById('sectionStudentsModal'));
    modal.show();

    fetch('GetSectionStudents.ashx?section=' + encodeURIComponent(sectionName))
        .then(function (r) { return r.json(); })
        .then(function (data) {
            _allSectionStudents = data;
            renderSectionStudents(data);
        })
        .catch(function () {
            document.getElementById('sectionStudentsLoading').style.display = 'none';
            document.getElementById('sectionStudentsEmpty').style.display = '';
        });
}

function renderSectionStudents(students) {
    var loading = document.getElementById('sectionStudentsLoading');
    var list = document.getElementById('sectionStudentsList');
    var empty = document.getElementById('sectionStudentsEmpty');

    loading.style.display = 'none';

    if (!students || students.length === 0) {
        list.style.display = 'none';
        empty.style.display = '';
        return;
    }

    var html = '';
    students.forEach(function (s, i) {
        var initial = s.StudentName.charAt(0).toUpperCase();
        var colors = ['#1565c0', '#2e7d32', '#ef6c00', '#5e35b1', '#0288d1', '#c62828'];
        var bgColor = colors[i % colors.length];
        var subtitle = [s.CourseName, s.SemesterName].filter(Boolean).join(' | ') || 'Student';

        html += '<div onclick="goToStudentDetail(' + s.UserId + ')"' +
            '     style="display:flex;align-items:center;gap:14px;padding:12px 10px;' +
            '            border-bottom:1px solid #f0f4f8;cursor:pointer;border-radius:10px;' +
            '            transition:background .15s;"' +
            '     onmouseover="this.style.background=\'#f0f7ff\'"' +
            '     onmouseout="this.style.background=\'\'">' +
            '  <div style="width:40px;height:40px;border-radius:50%;background:' + bgColor + ';' +
            '              display:flex;align-items:center;justify-content:center;' +
            '              font-size:16px;font-weight:800;color:#fff;flex-shrink:0;">' +
            '    ' + initial +
            '  </div>' +
            '  <div style="flex:1;min-width:0;">' +
            '    <div style="font-size:14px;font-weight:700;color:#263238;">' + s.StudentName + '</div>' +
            '    <div style="font-size:11px;color:#90a4ae;">' +
            '      <i class="fas fa-id-badge me-1"></i>' + (s.RollNumber || 'N/A') +
            '      &nbsp;|&nbsp;' + subtitle +
            '    </div>' +
            '  </div>' +
            '  <div style="flex-shrink:0;color:#1565c0;">' +
            '    <i class="fas fa-chevron-right"></i>' +
            '  </div>' +
            '</div>';
    });

    list.innerHTML = html;
    list.style.display = '';
    empty.style.display = 'none';
}

function filterSectionStudents(query) {
    if (!query) { renderSectionStudents(_allSectionStudents); return; }
    var q = query.toLowerCase();
    var filtered = _allSectionStudents.filter(function (s) {
        return s.StudentName.toLowerCase().includes(q) ||
            (s.RollNumber && s.RollNumber.toLowerCase().includes(q));
    });
    renderSectionStudents(filtered);
}

function goToStudentDetail(userId) {
    window.location.href = 'MyStudentDetails.aspx?UserId=' + userId;
}