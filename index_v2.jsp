<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>점검표 관리 시스템 v2 (전자결재 + 통계)</title>

  <link
    href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
    rel="stylesheet"
  />
  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

  <style>
    :root {
      --bg: #f4f7fb;
      --card: #ffffff;
      --txt: #1f2937;
      --muted: #6b7280;
    }

    body {
      background: var(--bg);
      color: var(--txt);
      font-size: 15px;
      line-height: 1.5;
      font-family: "Pretendard", "Noto Sans KR", -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
    }

    .page-wrap {
      max-width: 1280px;
    }

    .dashboard-card {
      border: 0;
      border-radius: 14px;
      box-shadow: 0 4px 18px rgba(31, 41, 55, 0.08);
      background: var(--card);
    }

    .metric-title {
      color: var(--muted);
      font-weight: 600;
      font-size: 0.9rem;
    }

    .metric-value {
      font-size: 1.4rem;
      font-weight: 700;
    }

    .chart-box {
      min-height: 300px;
    }

    .tab-content {
      background: var(--card);
      border-radius: 0 0 12px 12px;
      padding: 1.2rem;
      box-shadow: 0 4px 12px rgba(0, 0, 0, 0.04);
    }

    .check-item-row {
      border-bottom: 1px dashed #e5e7eb;
      padding: 0.65rem 0;
    }

    .check-item-row:last-child {
      border-bottom: none;
    }

    .status-badge {
      font-size: 0.8rem;
      min-width: 70px;
    }

    .table thead th {
      white-space: nowrap;
    }

    .small-muted {
      color: var(--muted);
      font-size: 0.84rem;
    }
  </style>
</head>
<body>
<div class="container-fluid py-4 page-wrap">
  <header class="mb-4">
    <h2 class="fw-bold mb-1">점검표 관리 시스템 v2</h2>
    <div class="small-muted">전자결재 워크플로우 + 통계 시각화(로컬 저장형 프로토타입)</div>
  </header>

  <section class="row g-3 mb-4" id="topDashboard">
    <div class="col-md-3">
      <div class="card dashboard-card p-3">
        <div class="metric-title">전체 점검표</div>
        <div class="metric-value" id="metricTotal">0건</div>
      </div>
    </div>
    <div class="col-md-3">
      <div class="card dashboard-card p-3">
        <div class="metric-title">결재대기</div>
        <div class="metric-value text-warning" id="metricPending">0건</div>
      </div>
    </div>
    <div class="col-md-3">
      <div class="card dashboard-card p-3">
        <div class="metric-title">승인완료</div>
        <div class="metric-value text-success" id="metricApproved">0건</div>
      </div>
    </div>
    <div class="col-md-3">
      <div class="card dashboard-card p-3">
        <div class="metric-title">반려</div>
        <div class="metric-value text-danger" id="metricRejected">0건</div>
      </div>
    </div>
  </section>

  <ul class="nav nav-tabs" id="mainTab" role="tablist">
    <li class="nav-item" role="presentation">
      <button class="nav-link active" id="write-tab" data-bs-toggle="tab" data-bs-target="#writePane" type="button" role="tab">점검표 작성</button>
    </li>
    <li class="nav-item" role="presentation">
      <button class="nav-link" id="approval-tab" data-bs-toggle="tab" data-bs-target="#approvalPane" type="button" role="tab">결재 관리</button>
    </li>
    <li class="nav-item" role="presentation">
      <button class="nav-link" id="analytics-tab" data-bs-toggle="tab" data-bs-target="#analyticsPane" type="button" role="tab">통계 분석</button>
    </li>
  </ul>

  <div class="tab-content">
    <div class="tab-pane fade show active" id="writePane" role="tabpanel" aria-labelledby="write-tab">
      <form id="inspectionForm" class="row g-3">
        <div class="col-md-3">
          <label class="form-label fw-semibold">점검일자</label>
          <input type="date" class="form-control" id="inspectionDate" required />
        </div>
        <div class="col-md-3">
          <label class="form-label fw-semibold">점검자</label>
          <input type="text" class="form-control" id="inspector" placeholder="홍길동" required />
        </div>
        <div class="col-md-3">
          <label class="form-label fw-semibold">사업장/라인</label>
          <input type="text" class="form-control" id="site" placeholder="A공장 1라인" required />
        </div>
        <div class="col-md-3">
          <label class="form-label fw-semibold">기록 ID</label>
          <input type="text" class="form-control" id="recordId" readonly />
        </div>

        <div class="col-12 mt-2">
          <div class="card border-0 bg-light">
            <div class="card-body">
              <h6 class="fw-bold">점검 항목</h6>
              <div id="checklistContainer"></div>
            </div>
          </div>
        </div>

        <div class="col-12">
          <label class="form-label fw-semibold">종합 의견</label>
          <textarea class="form-control" id="overallComment" rows="3" placeholder="현장 특이사항을 기록하세요."></textarea>
        </div>

        <div class="col-12 d-flex flex-wrap gap-2 mt-2">
          <button type="button" class="btn btn-outline-secondary" id="btnNew">신규 작성</button>
          <button type="button" class="btn btn-primary" id="btnSaveDraft">작성중 저장</button>
          <button type="button" class="btn btn-warning" id="btnRequestApproval">결재 요청</button>
        </div>
      </form>
    </div>

    <div class="tab-pane fade" id="approvalPane" role="tabpanel" aria-labelledby="approval-tab">
      <div class="d-flex justify-content-between align-items-center mb-3">
        <h6 class="fw-bold m-0">결재 목록</h6>
        <div class="form-check form-switch">
          <input class="form-check-input" type="checkbox" id="adminModeSwitch" />
          <label class="form-check-label" for="adminModeSwitch">관리자 모드 (승인/반려 가능)</label>
        </div>
      </div>

      <div class="table-responsive">
        <table class="table table-striped align-middle" id="approvalTable">
          <thead class="table-light">
          <tr>
            <th>ID</th>
            <th>일자</th>
            <th>점검자</th>
            <th>사업장</th>
            <th>결재상태</th>
            <th>요약</th>
            <th>처리</th>
          </tr>
          </thead>
          <tbody></tbody>
        </table>
      </div>
    </div>

    <div class="tab-pane fade" id="analyticsPane" role="tabpanel" aria-labelledby="analytics-tab">
      <div class="row g-3">
        <div class="col-lg-6">
          <div class="card dashboard-card p-3 h-100">
            <h6 class="fw-bold">최근 점검 결과 비율 (정상 vs 이상)</h6>
            <div class="small-muted mb-2">최근 30건의 점검 항목 합계를 기반으로 계산</div>
            <div class="chart-box">
              <canvas id="resultPieChart"></canvas>
            </div>
          </div>
        </div>
        <div class="col-lg-6">
          <div class="card dashboard-card p-3 h-100">
            <h6 class="fw-bold">일별 점검 완료 건수</h6>
            <div class="small-muted mb-2">결재 요청 이후 상태(결재대기/승인/반려) 건수 집계</div>
            <div class="chart-box">
              <canvas id="dailyBarChart"></canvas>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
  const STORAGE_KEY = "inspectionRecords_v2";
  const CHECK_ITEMS = [
    "소화기 압력 상태",
    "비상구 적치물 여부",
    "설비 누유/누전 여부",
    "보호구 착용 상태",
    "작업장 정리정돈",
    "환기 장치 동작 여부",
    "조명/전기 스위치 상태",
    "위험구역 표지판 상태"
  ];

  let records = [];
  let pieChart = null;
  let barChart = null;

  const el = {
    form: document.getElementById("inspectionForm"),
    inspectionDate: document.getElementById("inspectionDate"),
    inspector: document.getElementById("inspector"),
    site: document.getElementById("site"),
    recordId: document.getElementById("recordId"),
    overallComment: document.getElementById("overallComment"),
    checklistContainer: document.getElementById("checklistContainer"),
    btnNew: document.getElementById("btnNew"),
    btnSaveDraft: document.getElementById("btnSaveDraft"),
    btnRequestApproval: document.getElementById("btnRequestApproval"),
    approvalTbody: document.querySelector("#approvalTable tbody"),
    adminModeSwitch: document.getElementById("adminModeSwitch"),
    metricTotal: document.getElementById("metricTotal"),
    metricPending: document.getElementById("metricPending"),
    metricApproved: document.getElementById("metricApproved"),
    metricRejected: document.getElementById("metricRejected")
  };

  function uid() {
    return "REC-" + Date.now() + "-" + Math.floor(Math.random() * 1000);
  }

  function createChecklistHtml() {
    el.checklistContainer.innerHTML = CHECK_ITEMS.map((item, idx) => `
      <div class="check-item-row row align-items-center g-2">
        <div class="col-md-5 fw-semibold">${idx + 1}. ${item}</div>
        <div class="col-md-3">
          <select class="form-select check-result" data-item="${item}">
            <option value="정상">정상</option>
            <option value="이상">이상</option>
          </select>
        </div>
        <div class="col-md-4">
          <input type="text" class="form-control check-note" data-item="${item}" placeholder="비고" />
        </div>
      </div>
    `).join("");
  }

  function getStatusBadge(status) {
    if (status === "승인완료") return '<span class="badge text-bg-success status-badge">승인완료</span>';
    if (status === "결재대기") return '<span class="badge text-bg-warning status-badge">결재대기</span>';
    if (status === "반려") return '<span class="badge text-bg-danger status-badge">반려</span>';
    return '<span class="badge text-bg-secondary status-badge">작성중</span>';
  }

  function loadRecords() {
    try {
      const raw = localStorage.getItem(STORAGE_KEY);
      records = raw ? JSON.parse(raw) : [];
      if (!Array.isArray(records)) records = [];
    } catch (e) {
      console.error("localStorage 파싱 오류", e);
      records = [];
    }
  }

  function saveRecords() {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(records));
  }

  function collectFormData(status) {
    const checklist = Array.from(document.querySelectorAll(".check-item-row")).map(row => {
      const resultEl = row.querySelector(".check-result");
      const noteEl = row.querySelector(".check-note");
      return {
        item: resultEl.dataset.item,
        result: resultEl.value,
        note: noteEl.value.trim()
      };
    });

    return {
      id: el.recordId.value,
      date: el.inspectionDate.value,
      inspector: el.inspector.value.trim(),
      site: el.site.value.trim(),
      checklist,
      overallComment: el.overallComment.value.trim(),
      status,
      requestedAt: status === "결재대기" ? new Date().toISOString() : null,
      updatedAt: new Date().toISOString()
    };
  }

  function validateRequired() {
    if (!el.inspectionDate.value || !el.inspector.value.trim() || !el.site.value.trim()) {
      alert("점검일자, 점검자, 사업장/라인은 필수 입력입니다.");
      return false;
    }
    return true;
  }

  function upsertRecord(payload) {
    const index = records.findIndex(r => r.id === payload.id);
    if (index >= 0) {
      const prev = records[index];
      records[index] = {
        ...prev,
        ...payload,
        createdAt: prev.createdAt || new Date().toISOString()
      };
    } else {
      records.unshift({ ...payload, createdAt: new Date().toISOString() });
    }
    saveRecords();
    refreshAll();
  }

  function clearForm() {
    el.form.reset();
    el.inspectionDate.value = new Date().toISOString().slice(0, 10);
    el.recordId.value = uid();
    createChecklistHtml();
  }

  function fillForm(record) {
    el.recordId.value = record.id;
    el.inspectionDate.value = record.date;
    el.inspector.value = record.inspector;
    el.site.value = record.site;
    el.overallComment.value = record.overallComment || "";

    createChecklistHtml();
    record.checklist.forEach(chk => {
      const resultEl = document.querySelector(`.check-result[data-item="${chk.item}"]`);
      const noteEl = document.querySelector(`.check-note[data-item="${chk.item}"]`);
      if (resultEl) resultEl.value = chk.result;
      if (noteEl) noteEl.value = chk.note || "";
    });
  }

  function renderApprovalTable() {
    const isAdmin = el.adminModeSwitch.checked;
    if (records.length === 0) {
      el.approvalTbody.innerHTML = `<tr><td colspan="7" class="text-center text-muted py-4">데이터가 없습니다.</td></tr>`;
      return;
    }

    el.approvalTbody.innerHTML = records.map(record => {
      const normalCount = record.checklist.filter(c => c.result === "정상").length;
      const abnormalCount = record.checklist.filter(c => c.result === "이상").length;

      let actionHtml = `<button class="btn btn-sm btn-outline-primary" data-action="edit" data-id="${record.id}">열기</button>`;
      if (isAdmin && record.status === "결재대기") {
        actionHtml += `
          <button class="btn btn-sm btn-success ms-1" data-action="approve" data-id="${record.id}">승인</button>
          <button class="btn btn-sm btn-danger ms-1" data-action="reject" data-id="${record.id}">반려</button>
        `;
      }

      return `
        <tr>
          <td>${record.id}</td>
          <td>${record.date || "-"}</td>
          <td>${record.inspector || "-"}</td>
          <td>${record.site || "-"}</td>
          <td>${getStatusBadge(record.status)}</td>
          <td>정상 ${normalCount} / 이상 ${abnormalCount}</td>
          <td>${actionHtml}</td>
        </tr>
      `;
    }).join("");
  }

  function updateMetrics() {
    const pending = records.filter(r => r.status === "결재대기").length;
    const approved = records.filter(r => r.status === "승인완료").length;
    const rejected = records.filter(r => r.status === "반려").length;

    el.metricTotal.textContent = `${records.length}건`;
    el.metricPending.textContent = `${pending}건`;
    el.metricApproved.textContent = `${approved}건`;
    el.metricRejected.textContent = `${rejected}건`;
  }

  function buildChartData() {
    const latest = [...records].slice(0, 30);
    let normalTotal = 0;
    let abnormalTotal = 0;

    latest.forEach(r => {
      (r.checklist || []).forEach(c => {
        if (c.result === "정상") normalTotal += 1;
        else abnormalTotal += 1;
      });
    });

    const completedRecords = records.filter(r => ["결재대기", "승인완료", "반려"].includes(r.status));
    const dailyMap = {};
    completedRecords.forEach(r => {
      const key = r.date || "미지정";
      dailyMap[key] = (dailyMap[key] || 0) + 1;
    });

    const sortedDates = Object.keys(dailyMap).sort();
    const dailyCounts = sortedDates.map(d => dailyMap[d]);

    return {
      normalTotal,
      abnormalTotal,
      sortedDates,
      dailyCounts
    };
  }

  function renderCharts() {
    const { normalTotal, abnormalTotal, sortedDates, dailyCounts } = buildChartData();

    if (pieChart) pieChart.destroy();
    if (barChart) barChart.destroy();

    pieChart = new Chart(document.getElementById("resultPieChart"), {
      type: "pie",
      data: {
        labels: ["정상", "이상"],
        datasets: [{
          data: [normalTotal, abnormalTotal],
          backgroundColor: ["#22c55e", "#ef4444"],
          borderWidth: 1
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: { position: "bottom" }
        }
      }
    });

    barChart = new Chart(document.getElementById("dailyBarChart"), {
      type: "bar",
      data: {
        labels: sortedDates.length ? sortedDates : ["데이터 없음"],
        datasets: [{
          label: "완료 건수",
          data: dailyCounts.length ? dailyCounts : [0],
          backgroundColor: "#3b82f6",
          borderRadius: 6,
          maxBarThickness: 42
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        scales: {
          y: {
            beginAtZero: true,
            ticks: { stepSize: 1 }
          }
        }
      }
    });
  }

  function refreshAll() {
    renderApprovalTable();
    updateMetrics();
    renderCharts();
  }

  function bindEvents() {
    el.btnNew.addEventListener("click", clearForm);

    el.btnSaveDraft.addEventListener("click", () => {
      if (!validateRequired()) return;
      const payload = collectFormData("작성중");
      upsertRecord(payload);
      alert("작성중 상태로 저장되었습니다.");
    });

    el.btnRequestApproval.addEventListener("click", () => {
      if (!validateRequired()) return;
      const payload = collectFormData("결재대기");
      upsertRecord(payload);
      alert("결재 요청이 완료되었습니다. 상태: 결재대기");
    });

    el.adminModeSwitch.addEventListener("change", renderApprovalTable);

    el.approvalTbody.addEventListener("click", (e) => {
      const action = e.target.dataset.action;
      const id = e.target.dataset.id;
      if (!action || !id) return;

      const index = records.findIndex(r => r.id === id);
      if (index < 0) return;

      if (action === "edit") {
        fillForm(records[index]);
        const tab = new bootstrap.Tab(document.getElementById("write-tab"));
        tab.show();
        return;
      }

      if (!el.adminModeSwitch.checked) {
        alert("관리자 모드에서만 승인/반려가 가능합니다.");
        return;
      }

      if (action === "approve") {
        records[index].status = "승인완료";
        records[index].updatedAt = new Date().toISOString();
      }
      if (action === "reject") {
        records[index].status = "반려";
        records[index].updatedAt = new Date().toISOString();
      }

      saveRecords();
      refreshAll();
    });
  }

  function init() {
    createChecklistHtml();
    loadRecords();
    clearForm();
    bindEvents();
    refreshAll();
  }

  init();
</script>
</body>
</html>
