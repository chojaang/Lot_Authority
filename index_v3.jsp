<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="true" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>점검표 설계/실행/결재 통합 프로토타입 v3</title>

  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />
  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

  <style>
    :root {
      --bg: #f4f6fb;
      --surface: #ffffff;
      --text: #1f2937;
      --muted: #6b7280;
      --border: #e5e7eb;
      --navy: #1d3557;
      --danger-bg: #fff1f2;
    }

    body {
      margin: 0;
      background: var(--bg);
      color: var(--text);
      font-family: "Pretendard", "Noto Sans KR", sans-serif;
      font-size: 15px;
    }

    .layout {
      min-height: 100vh;
      display: grid;
      grid-template-columns: 240px 1fr;
    }

    .sidebar {
      background: var(--navy);
      color: #fff;
      padding: 1rem;
      position: sticky;
      top: 0;
      height: 100vh;
    }

    .sidebar .brand {
      font-weight: 700;
      font-size: 1.05rem;
      margin-bottom: 1rem;
    }

    .side-btn {
      width: 100%;
      border: 0;
      border-radius: 10px;
      padding: .65rem .75rem;
      margin-bottom: .45rem;
      text-align: left;
      color: #dbeafe;
      background: transparent;
    }

    .side-btn.active,
    .side-btn:hover {
      background: rgba(255, 255, 255, 0.14);
      color: #fff;
    }

    .content {
      padding: 1.25rem;
    }

    .surface {
      background: var(--surface);
      border-radius: 14px;
      border: 1px solid var(--border);
      box-shadow: 0 5px 16px rgba(15, 23, 42, 0.06);
      padding: 1rem;
    }

    .section-page {
      display: none;
    }

    .section-page.active {
      display: block;
    }

    .builder-item {
      border: 1px dashed #94a3b8;
      border-radius: 10px;
      padding: .7rem;
      margin-bottom: .6rem;
      background: #f8fafc;
      cursor: grab;
    }

    .builder-item.dragging {
      opacity: .4;
    }

    .sla-late {
      background: var(--danger-bg) !important;
    }

    .kpi {
      border: 1px solid var(--border);
      border-radius: 10px;
      padding: .75rem;
      background: #fff;
    }

    .kpi .label {
      color: var(--muted);
      font-size: .82rem;
    }

    .kpi .value {
      font-size: 1.2rem;
      font-weight: 700;
    }

    .chart-wrap {
      min-height: 300px;
    }
  </style>
</head>
<body>
<div class="layout">
  <aside class="sidebar">
    <div class="brand">ERP 점검/결재 v3</div>
    <button class="side-btn active" data-page="templatePage">템플릿 제작</button>
    <button class="side-btn" data-page="executePage">점검 수행</button>
    <button class="side-btn" data-page="approvalPage">결재함</button>
    <button class="side-btn" data-page="approverAdminPage">승인자 관리</button>
    <button class="side-btn" data-page="statsPage">통계 분석</button>
    <hr class="border-light opacity-25" />
    <div class="small">저장소: localStorage</div>
    <div class="small opacity-75">Templates / CheckLogs / Approvals</div>
  </aside>

  <main class="content">
    <section id="templatePage" class="section-page active">
      <div class="surface mb-3">
        <h5 class="fw-bold mb-3">템플릿 제작 (Form Builder)</h5>
        <div class="row g-3">
          <div class="col-md-5">
            <label class="form-label">템플릿 제목</label>
            <input type="text" id="templateTitle" class="form-control" placeholder="예: 설비 안전 일일점검" />
          </div>
          <div class="col-md-2">
            <label class="form-label">공장</label>
            <select id="templateFactory" class="form-select"></select>
          </div>
          <div class="col-md-2">
            <label class="form-label">공정</label>
            <select id="templateProcess" class="form-select"></select>
          </div>
          <div class="col-md-3">
            <label class="form-label">주기</label>
            <select id="templateCycle" class="form-select">
              <option value="일일">일일</option>
              <option value="주간">주간</option>
              <option value="월간">월간</option>
            </select>
          </div>
          <div class="col-md-2">
            <label class="form-label">결재 납기(일)</label>
            <input type="number" id="templateSlaHours" class="form-control" min="1" value="1" />
          </div>
          <div class="col-md-2">
            <label class="form-label">검토자(고정)</label>
            <input type="text" id="templateReviewer" class="form-control" placeholder="검토자명" />
          </div>
          <div class="col-md-2">
            <label class="form-label">승인자(고정)</label>
            <input type="text" id="templateApprover" class="form-control" placeholder="승인자명" />
          </div>
          <div class="col-md-2 d-grid align-items-end">
            <button class="btn btn-primary" id="saveTemplateBtn" type="button">템플릿 저장</button>
          </div>
        </div>
      </div>

      <div class="surface mb-3">
        <h6 class="fw-bold">공장/공정 관리</h6>
        <div class="row g-2">
          <div class="col-md-6">
            <div class="input-group input-group-sm">
              <span class="input-group-text">공장</span>
              <input class="form-control" id="newFactoryInput" placeholder="공장명 추가" />
              <button class="btn btn-outline-primary" id="addFactoryBtn" type="button">추가</button>
            </div>
          </div>
          <div class="col-md-6">
            <div class="input-group input-group-sm">
              <span class="input-group-text">공정</span>
              <input class="form-control" id="newProcessInput" placeholder="공정명 추가" />
              <button class="btn btn-outline-primary" id="addProcessBtn" type="button">추가</button>
            </div>
          </div>
        </div>
      </div>

      <div class="surface mb-3">
        <div class="d-flex justify-content-between align-items-center mb-2">
          <h6 class="fw-bold m-0">문항 설계</h6>
          <div class="d-flex gap-2">
            <button class="btn btn-outline-secondary btn-sm" id="addTextQBtn" type="button">텍스트 문항</button>
            <button class="btn btn-outline-secondary btn-sm" id="addChoiceQBtn" type="button">선택형 문항</button>
            <button class="btn btn-outline-secondary btn-sm" id="addNumberQBtn" type="button">숫자 문항</button>
          </div>
        </div>
        <div class="small text-muted mb-2">문항 카드를 드래그해 순서를 변경할 수 있습니다.</div>
        <div id="builderItems"></div>
      </div>

      <div class="surface">
        <h6 class="fw-bold">저장된 템플릿</h6>
        <div class="row g-2 mb-2">
          <div class="col-md-3"><select id="filterFactory" class="form-select form-select-sm"></select></div>
          <div class="col-md-3"><select id="filterProcess" class="form-select form-select-sm"></select></div>
          <div class="col-md-3"><select id="filterCycle" class="form-select form-select-sm"><option value="">주기 전체</option><option value="일일">일일</option><option value="주간">주간</option><option value="월간">월간</option></select></div>
          <div class="col-md-3 d-grid"><button id="resetTemplateFilters" class="btn btn-sm btn-outline-secondary" type="button">필터 초기화</button></div>
        </div>
        <div class="table-responsive">
          <table class="table table-sm align-middle" id="templateTable">
            <thead class="table-light">
            <tr>
              <th>제목(상세)</th>
              <th>공장</th>
              <th>공정</th>
              <th>주기</th>
              <th>검토/승인</th>
              <th>문항 수</th>
              <th>SLA</th>
              <th>작업</th>
            </tr>
            </thead>
            <tbody></tbody>
          </table>
        </div>
      </div>
    </section>

    <section id="executePage" class="section-page">
      <div class="surface mb-3">
        <h5 class="fw-bold mb-3">점검 수행</h5>
        <div class="row g-3">
          <div class="col-md-4">
            <label class="form-label">템플릿 선택</label>
            <select id="execTemplateSelect" class="form-select"></select>
          </div>
          <div class="col-md-3">
            <label class="form-label">점검일</label>
            <input type="date" id="execDate" class="form-control" />
          </div>
          <div class="col-md-5">
            <label class="form-label">작성자</label>
            <input type="text" id="lineOwner" class="form-control" placeholder="작성자명" />
          </div>
        </div>
        <div class="d-flex justify-content-end mt-2">
          <div id="execInfoPanel" class="border rounded p-2 bg-light small text-end"></div>
        </div>
      </div>

      <div class="surface mb-3">
        <h6 class="fw-bold">공장/공정 기준 템플릿</h6>
        <div id="executeTemplateByCategory" class="small"></div>
      </div>

      <div class="surface mb-3">
        <h6 class="fw-bold">점검 입력</h6>
        <div id="execFormArea" class="mt-2"></div>
      </div>

      <div class="surface">
        <div class="d-flex gap-2 flex-wrap">
          <button class="btn btn-secondary" id="saveDraftLogBtn" type="button">임시저장</button>
          <button class="btn btn-warning" id="requestApprovalBtn" type="button">결재 요청</button>
          <input type="month" id="bulkMonth" class="form-control" style="max-width: 180px;" />
          <button class="btn btn-outline-warning" id="bulkRequestBtn" type="button">선택 월 일괄 결재요청</button>
        </div>
      </div>

      <div class="surface mt-3">
        <h6 class="fw-bold mb-2">작성자 확인용 점검 이력</h6>
        <div class="table-responsive">
          <table class="table table-sm align-middle" id="writerLogTable">
            <thead class="table-light">
            <tr>
              <th>선택</th>
              <th>일자</th>
              <th>템플릿</th>
              <th>공장/공정</th>
              <th>상태</th>
              <th>결재라인</th>
              <th>조치</th>
            </tr>
            </thead>
            <tbody></tbody>
          </table>
        </div>
      </div>
    </section>

    <section id="approvalPage" class="section-page">
      <div class="surface">
        <h5 class="fw-bold mb-2">결재함</h5>
        <div class="row g-3">
          <div class="col-lg-6">
            <h6 class="fw-bold">검토자 결재함</h6>
            <div class="table-responsive">
              <table class="table align-middle" id="approvalTableReviewer">
                <thead class="table-light"><tr><th>요청시각</th><th>템플릿</th><th>상태</th><th>SLA</th><th>처리</th></tr></thead>
                <tbody></tbody>
              </table>
            </div>
          </div>
          <div class="col-lg-6">
            <h6 class="fw-bold">승인자 결재함</h6>
            <div class="table-responsive">
              <table class="table align-middle" id="approvalTableApprover">
                <thead class="table-light"><tr><th>요청시각</th><th>템플릿</th><th>상태</th><th>SLA</th><th>처리</th></tr></thead>
                <tbody></tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
    </section>

    <section id="statsPage" class="section-page">
      <div class="row g-3 mb-3">
        <div class="col-md-3"><div class="kpi"><div class="label">전체 템플릿</div><div class="value" id="kpiTemplates">0</div></div></div>
        <div class="col-md-3"><div class="kpi"><div class="label">전체 점검 로그</div><div class="value" id="kpiLogs">0</div></div></div>
        <div class="col-md-3"><div class="kpi"><div class="label">결재중</div><div class="value text-warning" id="kpiInApproval">0</div></div></div>
        <div class="col-md-3"><div class="kpi"><div class="label">지연 건수</div><div class="value text-danger" id="kpiDelayed">0</div><button class="btn btn-link btn-sm p-0" id="showDelayedBtn" type="button">지연 목록 보기</button></div></div></div>
      </div>
      <div class="surface mb-3" id="delayedListWrap" style="display:none;">
        <h6 class="fw-bold">지연 점검 목록</h6>
        <ul id="delayedList" class="mb-0"></ul>
      </div>
      <div class="surface mb-3">
        <h6 class="fw-bold">주기별 템플릿/진행 현황</h6>
        <div class="table-responsive">
          <table class="table table-sm" id="cycleSummaryTable">
            <thead class="table-light"><tr><th>주기</th><th>전체 템플릿</th><th>진행 중 로그</th><th>이행률(승인완료/전체로그)</th></tr></thead>
            <tbody></tbody>
          </table>
        </div>
      </div>
      <div class="surface mb-3">
        <h6 class="fw-bold">공정별 진행/완료 시각화</h6>
        <div class="chart-wrap"><canvas id="processProgressChart"></canvas></div>
      </div>

      <div class="row g-3">
        <div class="col-lg-6">
          <div class="surface h-100">
            <h6 class="fw-bold">주기별 이행률 (일/주/월)</h6>
            <div class="small text-muted mb-2">완료율 = 승인완료 ÷ 전체 로그</div>
            <div class="chart-wrap"><canvas id="complianceChart"></canvas></div>
          </div>
        </div>
        <div class="col-lg-6">
          <div class="surface h-100">
            <h6 class="fw-bold">결재 지연 현황</h6>
            <div class="small text-muted mb-2">SLA 초과 건수</div>
            <div class="chart-wrap"><canvas id="delayChart"></canvas></div>
          </div>
        </div>
      </div>
    </section>

    <section id="approverAdminPage" class="section-page">
      <div class="surface">
        <h5 class="fw-bold mb-2">승인자 전용 요청시각 수정</h5>
        <div class="small text-muted mb-2">보안상 승인자 전용 페이지입니다. 요청시각 수정 후 저장 가능합니다.</div>
        <div class="table-responsive">
          <table class="table table-sm align-middle" id="approverAdminTable">
            <thead class="table-light"><tr><th>템플릿</th><th>현재 요청시각</th><th>수정 요청시각</th><th>저장</th></tr></thead>
            <tbody></tbody>
          </table>
        </div>
      </div>
    </section>
  </main>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<div class="modal fade" id="templateDetailModal" tabindex="-1">
  <div class="modal-dialog modal-lg modal-dialog-scrollable">
    <div class="modal-content">
      <div class="modal-header"><h5 class="modal-title">템플릿 상세</h5><button class="btn-close" data-bs-dismiss="modal"></button></div>
      <div class="modal-body" id="templateDetailBody"></div>
    </div>
  </div>
</div>
<script>
  const STORAGE = {
    templates: "Templates",
    logs: "CheckLogs",
    approvals: "Approvals",
    factoryOptions: "FactoryOptions",
    processOptions: "ProcessOptions"
  };

  let templates = [];
  let checkLogs = [];
  let approvals = [];
  let builderItems = [];
  let factoryOptions = [];
  let processOptions = [];
  let editingTemplateId = null;
  let editingLogId = null;
  let complianceChart = null;
  let delayChart = null;
  let processProgressChart = null;

  const $ = {
    sideBtns: document.querySelectorAll(".side-btn"),
    pages: document.querySelectorAll(".section-page"),
    templateTitle: document.getElementById("templateTitle"),
    templateFactory: document.getElementById("templateFactory"),
    templateProcess: document.getElementById("templateProcess"),
    templateCycle: document.getElementById("templateCycle"),
    templateSlaHours: document.getElementById("templateSlaHours"),
    templateReviewer: document.getElementById("templateReviewer"),
    templateApprover: document.getElementById("templateApprover"),
    newFactoryInput: document.getElementById("newFactoryInput"),
    addFactoryBtn: document.getElementById("addFactoryBtn"),
    newProcessInput: document.getElementById("newProcessInput"),
    addProcessBtn: document.getElementById("addProcessBtn"),
    saveTemplateBtn: document.getElementById("saveTemplateBtn"),
    addTextQBtn: document.getElementById("addTextQBtn"),
    addChoiceQBtn: document.getElementById("addChoiceQBtn"),
    addNumberQBtn: document.getElementById("addNumberQBtn"),
    builderItems: document.getElementById("builderItems"),
    templateTableBody: document.querySelector("#templateTable tbody"),
    filterFactory: document.getElementById("filterFactory"),
    filterProcess: document.getElementById("filterProcess"),
    filterCycle: document.getElementById("filterCycle"),
    resetTemplateFilters: document.getElementById("resetTemplateFilters"),
    execTemplateSelect: document.getElementById("execTemplateSelect"),
    execDate: document.getElementById("execDate"),
    lineOwner: document.getElementById("lineOwner"),
    execInfoPanel: document.getElementById("execInfoPanel"),
    executeTemplateByCategory: document.getElementById("executeTemplateByCategory"),
    execFormArea: document.getElementById("execFormArea"),
    writerLogBody: document.querySelector("#writerLogTable tbody"),
    saveDraftLogBtn: document.getElementById("saveDraftLogBtn"),
    requestApprovalBtn: document.getElementById("requestApprovalBtn"),
    bulkMonth: document.getElementById("bulkMonth"),
    bulkRequestBtn: document.getElementById("bulkRequestBtn"),
    approvalTableReviewerBody: document.querySelector("#approvalTableReviewer tbody"),
    approvalTableApproverBody: document.querySelector("#approvalTableApprover tbody"),
    kpiTemplates: document.getElementById("kpiTemplates"),
    kpiLogs: document.getElementById("kpiLogs"),
    kpiInApproval: document.getElementById("kpiInApproval"),
    kpiDelayed: document.getElementById("kpiDelayed"),
    showDelayedBtn: document.getElementById("showDelayedBtn"),
    delayedListWrap: document.getElementById("delayedListWrap"),
    delayedList: document.getElementById("delayedList"),
    cycleSummaryBody: document.querySelector("#cycleSummaryTable tbody"),
    templateDetailBody: document.getElementById("templateDetailBody"),
    approverAdminBody: document.querySelector("#approverAdminTable tbody")
  };

  function uid(prefix) {
    return prefix + "-" + Date.now() + "-" + Math.floor(Math.random() * 10000);
  }

  function readJson(key) {
    try {
      const raw = localStorage.getItem(key);
      if (!raw) return [];
      const parsed = JSON.parse(raw);
      return Array.isArray(parsed) ? parsed : [];
    } catch (e) {
      console.error(key + " load failed", e);
      return [];
    }
  }

  function writeJson(key, arr) {
    localStorage.setItem(key, JSON.stringify(arr));
  }

  function loadAll() {
    templates = readJson(STORAGE.templates).map(normalizeTemplate);
    checkLogs = readJson(STORAGE.logs).map(normalizeLog);
    approvals = readJson(STORAGE.approvals).map(normalizeApproval);
    factoryOptions = readJson(STORAGE.factoryOptions);
    processOptions = readJson(STORAGE.processOptions);
    if (!factoryOptions.length) factoryOptions = ["A공장"];
    if (!processOptions.length) processOptions = ["압출공정"];

    writeJson(STORAGE.templates, templates);
    writeJson(STORAGE.logs, checkLogs);
    writeJson(STORAGE.approvals, approvals);
    writeJson(STORAGE.factoryOptions, factoryOptions);
    writeJson(STORAGE.processOptions, processOptions);
  }

  function normalizeTemplate(t) {
    return {
      id: t.id || uid("TPL"),
      title: t.title || "제목없음 템플릿",
      factory: t.factory || "미지정 공장",
      process: t.process || "미지정 공정",
      cycle: ["일일", "주간", "월간"].includes(t.cycle) ? t.cycle : "일일",
      slaHours: Number(t.slaHours) > 0 ? Number(t.slaHours) : 24,
      reviewer: t.reviewer || "",
      approver: t.approver || "",
      fields: Array.isArray(t.fields) ? t.fields.map(f => ({
        id: f.id || uid("Q"),
        label: f.label || "문항",
        type: ["text", "choice", "number"].includes(f.type) ? f.type : "text",
        options: Array.isArray(f.options) ? f.options : ["정상", "이상"],
        noteText: f.noteText || "",
        referenceImage: f.referenceImage || ""
      })) : [],
      createdAt: t.createdAt || new Date().toISOString(),
      updatedAt: t.updatedAt || new Date().toISOString()
    };
  }

  function normalizeLog(l) {
    return {
      id: l.id || uid("LOG"),
      templateId: l.templateId || "",
      templateTitle: l.templateTitle || "-",
      factory: l.factory || "",
      process: l.process || "",
      cycle: ["일일", "주간", "월간"].includes(l.cycle) ? l.cycle : "일일",
      execDate: l.execDate || new Date().toISOString().slice(0, 10),
      answers: Array.isArray(l.answers) ? l.answers : [],
      approvalLine: l.approvalLine || { owner: "", reviewer: "", approver: "" },
      status: ["임시저장", "결재중", "검토반려", "승인완료", "승인반려"].includes(l.status) ? l.status : "임시저장",
      approvalId: l.approvalId || null,
      createdAt: l.createdAt || new Date().toISOString(),
      updatedAt: l.updatedAt || new Date().toISOString()
    };
  }

  function normalizeApproval(a) {
    return {
      id: a.id || uid("APR"),
      checkLogId: a.checkLogId || "",
      templateId: a.templateId || "",
      templateTitle: a.templateTitle || "-",
      factory: a.factory || "",
      process: a.process || "",
      cycle: ["일일", "주간", "월간"].includes(a.cycle) ? a.cycle : "일일",
      line: a.line || { owner: "", reviewer: "", approver: "" },
      requestedAt: a.requestedAt || new Date().toISOString(),
      slaHours: Number(a.slaHours) > 0 ? Number(a.slaHours) : 24,
      status: ["결재중", "검토반려", "승인완료", "승인반려"].includes(a.status) ? a.status : "결재중",
      currentStep: ["reviewer", "approver", "done"].includes(a.currentStep) ? a.currentStep : "reviewer",
      delayFlag: Boolean(a.delayFlag),
      processedAt: a.processedAt || null
    };
  }

  function saveAll() {
    writeJson(STORAGE.templates, templates);
    writeJson(STORAGE.logs, checkLogs);
    writeJson(STORAGE.approvals, approvals);
    writeJson(STORAGE.factoryOptions, factoryOptions);
    writeJson(STORAGE.processOptions, processOptions);
  }

  // sidebar
  function bindSidebar() {
    $.sideBtns.forEach(btn => {
      btn.addEventListener("click", () => {
        const pageId = btn.dataset.page;
        $.sideBtns.forEach(b => b.classList.remove("active"));
        btn.classList.add("active");

        $.pages.forEach(p => p.classList.remove("active"));
        document.getElementById(pageId).classList.add("active");
      });
    });
  }

  function renderCategoryOptions() {
    $.templateFactory.innerHTML = factoryOptions.map(v => `<option value="${v}">${v}</option>`).join("");
    $.templateProcess.innerHTML = processOptions.map(v => `<option value="${v}">${v}</option>`).join("");

    $.filterFactory.innerHTML = `<option value="">공장 전체</option>` + factoryOptions.map(v => `<option value="${v}">${v}</option>`).join("");
    $.filterProcess.innerHTML = `<option value="">공정 전체</option>` + processOptions.map(v => `<option value="${v}">${v}</option>`).join("");
  }

  function showTemplateDetail(templateId) {
    const tpl = templates.find(t => t.id === templateId);
    if (!tpl) return;
    $.templateDetailBody.innerHTML = `
      <div><strong>${tpl.title}</strong> (${tpl.factory}/${tpl.process}, ${tpl.cycle})</div>
      <div class="small text-muted mb-2">검토자 ${tpl.reviewer} / 승인자 ${tpl.approver}</div>
      <ul>${tpl.fields.map(f => `<li>${f.label} [${f.type}] ${f.noteText ? `- ${f.noteText}` : ""}</li>`).join("")}</ul>
    `;
    new bootstrap.Modal(document.getElementById("templateDetailModal")).show();
  }

  // form builder
  function addBuilderItem(type) {
    const newItem = {
      id: uid("Q"),
      type,
      label: type === "choice" ? "선택형 문항" : (type === "number" ? "숫자 문항" : "텍스트 문항"),
      options: type === "choice" ? ["정상", "이상"] : []
    };
    builderItems.push(newItem);
    renderBuilder();
  }

  function renderBuilder() {
    if (!builderItems.length) {
      $.builderItems.innerHTML = '<div class="text-muted">문항이 없습니다. 상단 버튼으로 문항을 추가하세요.</div>';
      return;
    }

    $.builderItems.innerHTML = builderItems.map((item, idx) => {
      const optionHtml = item.type === "choice"
        ? `<input class="form-control form-control-sm mt-2 choice-options" data-id="${item.id}" value="${item.options.join(",")}" placeholder="선택지(쉼표 구분)"/>`
        : "";

      return `
        <div class="builder-item" draggable="true" data-id="${item.id}">
          <div class="d-flex justify-content-between align-items-center">
            <div class="small text-muted">문항 ${idx + 1} (${item.type})</div>
            <button class="btn btn-sm btn-outline-danger remove-item-btn" data-id="${item.id}" type="button">삭제</button>
          </div>
          <input class="form-control form-control-sm mt-2 question-label" data-id="${item.id}" value="${item.label}" />
          ${optionHtml}
          <textarea class="form-control form-control-sm mt-2 question-note" data-id="${item.id}" placeholder="문항 비고 텍스트">${item.noteText || ""}</textarea>
          <div class="mt-2">
            <input type="file" accept="image/*" class="form-control form-control-sm question-image" data-id="${item.id}" />
          </div>
          ${item.referenceImage ? `<img src="${item.referenceImage}" alt="참고 이미지" class="img-thumbnail mt-2" style="max-height:120px;" />` : ""}
        </div>
      `;
    }).join("");

    bindBuilderDomEvents();
  }

  function bindBuilderDomEvents() {
    document.querySelectorAll(".remove-item-btn").forEach(btn => {
      btn.addEventListener("click", () => {
        builderItems = builderItems.filter(i => i.id !== btn.dataset.id);
        renderBuilder();
      });
    });

    document.querySelectorAll(".question-label").forEach(input => {
      input.addEventListener("input", () => {
        const found = builderItems.find(i => i.id === input.dataset.id);
        if (found) found.label = input.value;
      });
    });

    document.querySelectorAll(".choice-options").forEach(input => {
      input.addEventListener("input", () => {
        const found = builderItems.find(i => i.id === input.dataset.id);
        if (found) {
          found.options = input.value.split(",").map(v => v.trim()).filter(Boolean);
        }
      });
    });

    document.querySelectorAll(".question-note").forEach(input => {
      input.addEventListener("input", () => {
        const found = builderItems.find(i => i.id === input.dataset.id);
        if (found) found.noteText = input.value;
      });
    });

    document.querySelectorAll(".question-image").forEach(input => {
      input.addEventListener("change", (e) => {
        const file = e.target.files && e.target.files[0];
        if (!file) return;
        const reader = new FileReader();
        reader.onload = () => {
          const found = builderItems.find(i => i.id === input.dataset.id);
          if (found) {
            found.referenceImage = reader.result;
            renderBuilder();
          }
        };
        reader.readAsDataURL(file);
      });
    });

    const draggable = document.querySelectorAll(".builder-item");
    draggable.forEach(card => {
      card.addEventListener("dragstart", () => card.classList.add("dragging"));
      card.addEventListener("dragend", () => {
        card.classList.remove("dragging");
        const newOrder = Array.from(document.querySelectorAll(".builder-item")).map(el => el.dataset.id);
        builderItems = newOrder.map(id => builderItems.find(i => i.id === id)).filter(Boolean);
        renderBuilder();
      });

      card.addEventListener("dragover", e => e.preventDefault());
      card.addEventListener("drop", e => {
        e.preventDefault();
        const dragging = document.querySelector(".builder-item.dragging");
        if (dragging && dragging !== card) {
          const parent = card.parentNode;
          parent.insertBefore(dragging, card);
        }
      });
    });
  }

  function saveTemplate() {
    const title = $.templateTitle.value.trim();
    const factory = $.templateFactory.value.trim();
    const process = $.templateProcess.value.trim();
    const cycle = $.templateCycle.value;
    const slaHours = Number($.templateSlaHours.value || 24);
    const reviewer = $.templateReviewer.value.trim();
    const approver = $.templateApprover.value.trim();

    if (!title) return alert("템플릿 제목을 입력하세요.");
    if (!factory || !process) return alert("공장/공정을 입력하세요.");
    if (!reviewer || !approver) return alert("검토자/승인자(고정 결재자)를 입력하세요.");
    if (!builderItems.length) return alert("최소 1개 이상의 문항이 필요합니다.");

    const template = normalizeTemplate({
      id: editingTemplateId || uid("TPL"),
      title,
      factory,
      process,
      cycle,
      slaHours,
      reviewer,
      approver,
      fields: builderItems,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    });

    if (editingTemplateId) {
      const idx = templates.findIndex(t => t.id === editingTemplateId);
      if (idx >= 0) templates[idx] = { ...templates[idx], ...template, updatedAt: new Date().toISOString() };
    } else {
      templates.unshift(template);
    }
    editingTemplateId = null;
    saveAll();
    renderTemplateTable();
    renderTemplateSelect();
    alert("템플릿이 저장되었습니다.");
  }

  function renderTemplateTable() {
    const filtered = templates.filter(t => {
      if ($.filterFactory.value && t.factory !== $.filterFactory.value) return false;
      if ($.filterProcess.value && t.process !== $.filterProcess.value) return false;
      if ($.filterCycle.value && t.cycle !== $.filterCycle.value) return false;
      return true;
    });

    if (!filtered.length) {
      $.templateTableBody.innerHTML = '<tr><td colspan="8" class="text-center text-muted">저장된 템플릿이 없습니다.</td></tr>';
      return;
    }

    $.templateTableBody.innerHTML = filtered.map(t => `
      <tr>
        <td><button class="btn btn-link btn-sm p-0 tpl-detail-btn" data-id="${t.id}" type="button">${t.title}</button></td>
        <td>${t.factory}</td>
        <td>${t.process}</td>
        <td>${t.cycle}</td>
        <td>${t.reviewer} / ${t.approver}</td>
        <td>${t.fields.length}</td>
        <td>${t.slaHours}일</td>
        <td>
          <button class="btn btn-sm btn-outline-primary use-template-btn" data-id="${t.id}" type="button">불러오기/수정</button>
          <button class="btn btn-sm btn-outline-secondary copy-template-btn" data-id="${t.id}" type="button">복사</button>
          <button class="btn btn-sm btn-outline-danger delete-template-btn" data-id="${t.id}" type="button">삭제</button>
        </td>
      </tr>
    `).join("");

    document.querySelectorAll(".use-template-btn").forEach(btn => {
      btn.addEventListener("click", () => {
        const tpl = templates.find(t => t.id === btn.dataset.id);
        if (!tpl) return;
        $.templateTitle.value = tpl.title;
        $.templateFactory.value = tpl.factory;
        $.templateProcess.value = tpl.process;
        $.templateCycle.value = tpl.cycle;
        $.templateSlaHours.value = tpl.slaHours;
        $.templateReviewer.value = tpl.reviewer;
        $.templateApprover.value = tpl.approver;
        builderItems = tpl.fields.map(f => ({ ...f, options: [...(f.options || [])] }));
        editingTemplateId = tpl.id;
        renderBuilder();
      });
    });

    document.querySelectorAll(".copy-template-btn").forEach(btn => {
      btn.addEventListener("click", () => {
        const tpl = templates.find(t => t.id === btn.dataset.id);
        if (!tpl) return;
        const copy = normalizeTemplate({ ...tpl, id: uid("TPL"), title: tpl.title + " (복사본)", createdAt: new Date().toISOString(), updatedAt: new Date().toISOString() });
        templates.unshift(copy);
        saveAll();
        refreshAll();
      });
    });

    document.querySelectorAll(".tpl-detail-btn").forEach(btn => {
      btn.addEventListener("click", () => showTemplateDetail(btn.dataset.id));
    });

    document.querySelectorAll(".delete-template-btn").forEach(btn => {
      btn.addEventListener("click", () => {
        if (!confirm("템플릿을 삭제하시겠습니까?")) return;
        templates = templates.filter(t => t.id !== btn.dataset.id);
        saveAll();
        renderTemplateTable();
        renderTemplateSelect();
        refreshAll();
      });
    });
  }

  // execute logs
  function renderTemplateSelect() {
    if (!templates.length) {
      $.execTemplateSelect.innerHTML = '<option value="">템플릿 없음</option>';
      $.execFormArea.innerHTML = '<div class="text-muted">템플릿을 먼저 생성하세요.</div>';
      return;
    }

    $.execTemplateSelect.innerHTML = templates.map(t => `<option value="${t.id}">${t.title} (${t.factory}/${t.process}, ${t.cycle})</option>`).join("");
    renderExecuteCategoryTemplates();
    renderExecForm();
  }

  function renderExecuteCategoryTemplates() {
    const groups = {};
    templates.forEach(t => {
      const key = `${t.factory} / ${t.process}`;
      if (!groups[key]) groups[key] = [];
      groups[key].push(t);
    });
    const html = Object.keys(groups).map(key => `
      <div class="mb-2">
        <div class="fw-semibold">${key}</div>
        <div class="d-flex flex-wrap gap-1 mt-1">
          ${groups[key].map(t => `<button class="btn btn-sm btn-outline-primary exec-quick-template" data-id="${t.id}" type="button">${t.title}</button>`).join("")}
        </div>
      </div>
    `).join("");
    $.executeTemplateByCategory.innerHTML = html || '<div class="text-muted">표시할 템플릿이 없습니다.</div>';
    document.querySelectorAll(".exec-quick-template").forEach(btn => {
      btn.addEventListener("click", () => {
        $.execTemplateSelect.value = btn.dataset.id;
        renderExecForm();
      });
    });
  }

  function renderExecForm() {
    const tpl = templates.find(t => t.id === $.execTemplateSelect.value) || templates[0];
    if (!tpl) return;

    const header = `
      <div class="alert alert-light border mb-3">
        <div><strong>분류:</strong> ${tpl.factory} / ${tpl.process}</div>
        <div><strong>결재라인:</strong> 검토자 ${tpl.reviewer} → 승인자 ${tpl.approver}</div>
      </div>
    `;
    $.execInfoPanel.innerHTML = `
      <div><span class="badge text-bg-primary">${tpl.factory}</span> <span class="badge text-bg-info">${tpl.process}</span></div>
      <div class="mt-1">검토자 <strong>${tpl.reviewer}</strong> / 승인자 <strong>${tpl.approver}</strong></div>
    `;

    const body = tpl.fields.map(f => {
      const guide = `
        ${f.noteText ? `<div class="small text-muted mb-1">비고: ${f.noteText}</div>` : ""}
        ${f.referenceImage ? `<img src="${f.referenceImage}" alt="참고 이미지" class="img-fluid rounded border mb-2" style="max-height:140px;" />` : ""}
      `;
      if (f.type === "number") {
        return `
          <div class="mb-2">
            <label class="form-label">${f.label}</label>
            ${guide}
            <input type="number" class="form-control exec-answer" data-qid="${f.id}" data-type="number" />
          </div>
        `;
      }

      if (f.type === "choice") {
        const ops = (f.options || ["정상", "이상"]).map(op => `<option value="${op}">${op}</option>`).join("");
        return `
          <div class="mb-2">
            <label class="form-label">${f.label}</label>
            ${guide}
            <select class="form-select exec-answer" data-qid="${f.id}" data-type="choice">${ops}</select>
          </div>
        `;
      }

      return `
        <div class="mb-2">
          <label class="form-label">${f.label}</label>
          ${guide}
          <input type="text" class="form-control exec-answer" data-qid="${f.id}" data-type="text" />
        </div>
      `;
    }).join("");

    $.execFormArea.innerHTML = header + body;
  }

  function collectExecAnswers() {
    return Array.from(document.querySelectorAll(".exec-answer")).map(input => ({
      questionId: input.dataset.qid,
      type: input.dataset.type,
      value: input.value
    }));
  }

  function saveCheckLog(nextStatus) {
    const tpl = templates.find(t => t.id === $.execTemplateSelect.value);
    if (!tpl) return alert("템플릿이 없습니다.");

    const owner = $.lineOwner.value.trim();
    const reviewer = (tpl.reviewer || "").trim();
    const approver = (tpl.approver || "").trim();

    if (!owner) {
      return alert("작성자를 입력하세요.");
    }
    if (!reviewer || !approver) {
      return alert("템플릿에 검토자/승인자를 먼저 설정하세요.");
    }

    const logId = editingLogId || uid("LOG");
    const answers = collectExecAnswers();

    let approvalId = null;
    if (nextStatus === "결재중") {
      const approval = normalizeApproval({
        id: uid("APR"),
        checkLogId: logId,
        templateId: tpl.id,
        templateTitle: tpl.title,
        factory: tpl.factory,
        process: tpl.process,
        cycle: tpl.cycle,
        line: { owner, reviewer, approver },
        requestedAt: new Date().toISOString(),
        slaHours: tpl.slaHours,
        status: "결재중",
        currentStep: "reviewer",
        delayFlag: false,
        processedAt: null
      });
      approvals.unshift(approval);
      approvalId = approval.id;
    }

    const log = normalizeLog({
      id: logId,
      templateId: tpl.id,
      templateTitle: tpl.title,
      factory: tpl.factory,
      process: tpl.process,
      cycle: tpl.cycle,
      execDate: $.execDate.value || new Date().toISOString().slice(0, 10),
      answers,
      approvalLine: { owner, reviewer, approver },
      status: nextStatus,
      approvalId,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    });

    const logIndex = checkLogs.findIndex(l => l.id === logId);
    if (logIndex >= 0) checkLogs[logIndex] = log;
    else checkLogs.unshift(log);
    editingLogId = null;
    saveAll();
    refreshAll();
    alert(nextStatus === "결재중" ? "결재 요청 완료" : "임시저장 완료");
  }

  // approval
  function isDelayed(approval) {
    if (approval.status !== "결재중") return false;
    const requestedMs = new Date(approval.requestedAt).getTime();
    const dueMs = requestedMs + approval.slaHours * 24 * 3600 * 1000;
    return Date.now() > dueMs;
  }

  function renderApprovalInbox() {
    approvals.forEach(a => a.delayFlag = isDelayed(a));

    const sorted = [...approvals].sort((a, b) => {
      if (a.delayFlag !== b.delayFlag) return a.delayFlag ? -1 : 1;
      return new Date(b.requestedAt) - new Date(a.requestedAt);
    });

    const renderRows = (list, role) => list.map(a => {
      const late = a.delayFlag ? "sla-late" : "";
      const statusBadge = a.status === "승인완료"
        ? '<span class="badge text-bg-success">승인완료</span>'
        : a.status === "검토반려"
          ? '<span class="badge text-bg-danger">검토반려</span>'
          : a.status === "승인반려"
            ? '<span class="badge text-bg-danger">승인반려</span>'
          : '<span class="badge text-bg-warning">결재중</span>';

      const canReview = role === "reviewer" && a.status === "결재중" && a.currentStep === "reviewer";
      const canApprove = role === "approver" && a.status === "결재중" && a.currentStep === "approver";

      return `
        <tr class="${late}">
          <td>${a.requestedAt.replace("T", " ").slice(0, 16)}</td>
          <td><button class="btn btn-link btn-sm p-0 tpl-detail-btn" data-id="${a.templateId}" type="button">${a.templateTitle}</button><div class="small text-muted">${a.factory} / ${a.process}</div></td>
          <td>${statusBadge} ${a.delayFlag ? '<span class="ms-1">⚠️ 지연</span>' : ''}</td>
          <td>${a.slaHours}일</td>
          <td>
            ${canReview ? `<button class="btn btn-sm btn-primary inbox-act" data-id="${a.id}" data-action="review-ok">검토완료</button>` : ""}
            ${canReview ? `<button class="btn btn-sm btn-outline-danger inbox-act" data-id="${a.id}" data-action="review-reject">검토반려</button>` : ""}
            ${canApprove ? `<button class="btn btn-sm btn-success inbox-act" data-id="${a.id}" data-action="approve">승인</button>
                           <button class="btn btn-sm btn-outline-danger inbox-act" data-id="${a.id}" data-action="reject">반려</button>` : ""}
            <button class="btn btn-sm btn-outline-dark inbox-delete" data-id="${a.id}" type="button">삭제</button>
          </td>
        </tr>
      `;
    }).join("");

    const reviewerList = sorted.filter(a => a.currentStep === "reviewer" || a.status !== "결재중");
    const approverList = sorted.filter(a => a.currentStep === "approver" || a.status !== "결재중");

    $.approvalTableReviewerBody.innerHTML = reviewerList.length ? renderRows(reviewerList, "reviewer") : '<tr><td colspan="5" class="text-center text-muted">데이터 없음</td></tr>';
    $.approvalTableApproverBody.innerHTML = approverList.length ? renderRows(approverList, "approver") : '<tr><td colspan="5" class="text-center text-muted">데이터 없음</td></tr>';

    document.querySelectorAll(".inbox-act").forEach(btn => {
      btn.addEventListener("click", () => handleApprovalAction(btn.dataset.id, btn.dataset.action));
    });
    document.querySelectorAll(".inbox-delete").forEach(btn => {
      btn.addEventListener("click", () => deleteApprovalWithPassword(btn.dataset.id));
    });
    document.querySelectorAll("#approvalPage .tpl-detail-btn").forEach(btn => {
      btn.addEventListener("click", () => showTemplateDetail(btn.dataset.id));
    });

    saveAll();
  }

  function syncLogStatus(approval) {
    const log = checkLogs.find(l => l.id === approval.checkLogId);
    if (!log) return;

    if (approval.status === "결재중") {
      log.status = "결재중";
    } else if (approval.status === "승인완료") {
      log.status = "승인완료";
    } else if (approval.status === "검토반려") {
      log.status = "검토반려";
    } else if (approval.status === "승인반려") {
      log.status = "승인반려";
    } else {
      log.status = "승인반려";
    }
    log.updatedAt = new Date().toISOString();
  }

  function handleApprovalAction(approvalId, action) {
    const target = approvals.find(a => a.id === approvalId);
    if (!target) return;

    if (action === "review-ok" && target.currentStep === "reviewer") {
      target.currentStep = "approver";
      target.status = "결재중";
    }

    if (action === "review-reject" && target.currentStep === "reviewer") {
      target.currentStep = "done";
      target.status = "검토반려";
      target.processedAt = new Date().toISOString();
    }

    if (action === "approve" && target.currentStep === "approver") {
      target.currentStep = "done";
      target.status = "승인완료";
      target.processedAt = new Date().toISOString();
    }

    if (action === "reject") {
      target.currentStep = "done";
      target.status = "승인반려";
      target.processedAt = new Date().toISOString();
    }

    syncLogStatus(target);
    saveAll();
    refreshAll();
  }

  function deleteApprovalWithPassword(approvalId) {
    const pw = prompt("삭제 비밀번호를 입력하세요.");
    if (pw !== "koreno") return alert("비밀번호가 올바르지 않습니다.");
    if (!confirm("삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.")) return;

    const target = approvals.find(a => a.id === approvalId);
    approvals = approvals.filter(a => a.id !== approvalId);
    if (target) {
      checkLogs = checkLogs.filter(l => l.id !== target.checkLogId);
    }
    saveAll();
    refreshAll();
  }

  function renderApproverAdmin() {
    if (!approvals.length) {
      $.approverAdminBody.innerHTML = '<tr><td colspan="4" class="text-center text-muted">데이터 없음</td></tr>';
      return;
    }
    $.approverAdminBody.innerHTML = approvals.map(a => `
      <tr>
        <td>${a.templateTitle}</td>
        <td>${a.requestedAt.replace("T"," ").slice(0,16)}</td>
        <td><input type="datetime-local" class="form-control form-control-sm admin-req-time" data-id="${a.id}" value="${a.requestedAt.slice(0,16)}" /></td>
        <td><button class="btn btn-sm btn-primary admin-save-time" data-id="${a.id}" type="button">저장</button></td>
      </tr>
    `).join("");
    document.querySelectorAll(".admin-save-time").forEach(btn => {
      btn.addEventListener("click", () => {
        const input = document.querySelector(`.admin-req-time[data-id="${btn.dataset.id}"]`);
        if (!input || !input.value) return;
        const row = approvals.find(a => a.id === btn.dataset.id);
        if (!row) return;
        row.requestedAt = new Date(input.value).toISOString();
        saveAll();
        refreshAll();
      });
    });
  }

  function renderWriterLogs() {
    if (!checkLogs.length) {
      $.writerLogBody.innerHTML = '<tr><td colspan="7" class="text-center text-muted">작성 이력이 없습니다.</td></tr>';
      return;
    }

    $.writerLogBody.innerHTML = checkLogs.map(log => {
      const isRejected = log.status === "검토반려" || log.status === "승인반려";
      const editBtn = (log.status === "임시저장" || isRejected) ? `<button class="btn btn-sm btn-outline-secondary writer-edit-log" data-id="${log.id}">불러오기</button>` : "";
      const canResubmit = isRejected ? `<button class="btn btn-sm btn-outline-primary writer-edit-resubmit" data-id="${log.id}">수정 후 재요청</button>` : "";
      const canBulk = (log.status === "임시저장" || isRejected) ? `<input type="checkbox" class="form-check-input writer-bulk" data-id="${log.id}" data-month="${log.execDate.slice(0,7)}" />` : "";
      return `
        <tr>
          <td>${canBulk}</td>
          <td>${log.execDate}</td>
          <td>${log.templateTitle}</td>
          <td>${log.factory || "-"} / ${log.process || "-"}</td>
          <td><span class="badge text-bg-${isRejected ? "danger" : (log.status === "승인완료" ? "success" : "secondary")}">${log.status}</span></td>
          <td>${log.approvalLine.owner} → ${log.approvalLine.reviewer} → ${log.approvalLine.approver}</td>
          <td>${editBtn} ${canResubmit}</td>
        </tr>
      `;
    }).join("");

    document.querySelectorAll(".writer-edit-resubmit").forEach(btn => {
      btn.addEventListener("click", () => loadLogForEdit(btn.dataset.id));
    });
    document.querySelectorAll(".writer-edit-log").forEach(btn => {
      btn.addEventListener("click", () => loadLogForEdit(btn.dataset.id));
    });
  }

  function loadLogForEdit(logId) {
    const log = checkLogs.find(l => l.id === logId);
    if (!log) return;
    $.execTemplateSelect.value = log.templateId;
    $.execDate.value = log.execDate;
    $.lineOwner.value = log.approvalLine.owner;
    renderExecForm();
    (log.answers || []).forEach(ans => {
      const input = document.querySelector(`.exec-answer[data-qid="${ans.questionId}"]`);
      if (input) input.value = ans.value;
    });
    editingLogId = log.id;
    const pageBtn = document.querySelector('.side-btn[data-page=\"executePage\"]');
    if (pageBtn) pageBtn.click();
  }

  function requestBulkByMonth() {
    const month = $.bulkMonth.value;
    if (!month) return alert("일괄 결재요청 월을 선택하세요.");
    const selectedIds = Array.from(document.querySelectorAll(".writer-bulk:checked"))
      .filter(c => c.dataset.month === month)
      .map(c => c.dataset.id);
    const autoIds = checkLogs
      .filter(l => l.execDate.slice(0, 7) === month && ["임시저장", "검토반려", "승인반려"].includes(l.status))
      .map(l => l.id);
    const targetIds = selectedIds.length ? selectedIds : autoIds;
    if (!targetIds.length) return alert("선택한 월의 요청 대상이 없습니다.");

    targetIds.forEach(id => {
      const log = checkLogs.find(l => l.id === id);
      if (!log) return;
      const tpl = templates.find(t => t.id === log.templateId);
      if (!tpl) return;
      const approval = normalizeApproval({
        id: uid("APR"),
        checkLogId: log.id,
        templateId: tpl.id,
        templateTitle: tpl.title,
        factory: tpl.factory,
        process: tpl.process,
        cycle: tpl.cycle,
        line: log.approvalLine,
        requestedAt: new Date().toISOString(),
        slaHours: tpl.slaHours,
        status: "결재중",
        currentStep: "reviewer",
        delayFlag: false
      });
      approvals.unshift(approval);
      log.status = "결재중";
      log.approvalId = approval.id;
      log.updatedAt = new Date().toISOString();
    });
    saveAll();
    refreshAll();
  }

  // charts/stats
  function calcComplianceByCycle() {
    const cycles = ["일일", "주간", "월간"];
    return cycles.map(cycle => {
      const logs = checkLogs.filter(l => l.cycle === cycle);
      const done = logs.filter(l => l.status === "승인완료").length;
      const rate = logs.length ? Math.round((done / logs.length) * 100) : 0;
      return { cycle, rate };
    });
  }

  function calcDelayStats() {
    const delayed = approvals.filter(a => isDelayed(a) && a.status === "결재중").length;
    const normal = approvals.filter(a => !isDelayed(a) && a.status === "결재중").length;
    return { delayed, normal };
  }

  function renderStats() {
    const delayStats = calcDelayStats();

    $.kpiTemplates.textContent = templates.length;
    $.kpiLogs.textContent = checkLogs.length;
    $.kpiInApproval.textContent = approvals.filter(a => a.status === "결재중").length;
    $.kpiDelayed.textContent = delayStats.delayed;

    const compliance = calcComplianceByCycle();
    const cycles = ["일일","주간","월간"];
    $.cycleSummaryBody.innerHTML = cycles.map(c => {
      const tplCount = templates.filter(t => t.cycle === c).length;
      const logs = checkLogs.filter(l => l.cycle === c);
      const inProgress = logs.filter(l => l.status === "결재중").length;
      const done = logs.filter(l => l.status === "승인완료").length;
      const rate = logs.length ? Math.round(done / logs.length * 100) : 0;
      return `<tr><td>${c}</td><td>${tplCount}</td><td>${inProgress}</td><td>${rate}%</td></tr>`;
    }).join("");

    const delayedRows = approvals.filter(a => isDelayed(a) && a.status === "결재중");
    $.delayedList.innerHTML = delayedRows.length
      ? delayedRows.map(a => `<li>${a.templateTitle} (${a.factory}/${a.process}) - 요청 ${a.requestedAt.slice(0,16).replace("T"," ")}</li>`).join("")
      : "<li>지연 건이 없습니다.</li>";

    if (complianceChart) complianceChart.destroy();
    if (delayChart) delayChart.destroy();
    if (processProgressChart) processProgressChart.destroy();

    complianceChart = new Chart(document.getElementById("complianceChart"), {
      type: "bar",
      data: {
        labels: compliance.map(v => v.cycle),
        datasets: [{
          label: "이행률(%)",
          data: compliance.map(v => v.rate),
          backgroundColor: ["#2563eb", "#0ea5e9", "#6366f1"]
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        scales: {
          y: {
            beginAtZero: true,
            max: 100
          }
        }
      }
    });

    delayChart = new Chart(document.getElementById("delayChart"), {
      type: "doughnut",
      data: {
        labels: ["지연", "정상"],
        datasets: [{
          data: [delayStats.delayed, delayStats.normal],
          backgroundColor: ["#ef4444", "#22c55e"]
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false
      }
    });

    const processMap = {};
    checkLogs.forEach(l => {
      const k = l.process || "미지정";
      if (!processMap[k]) processMap[k] = { done: 0, progress: 0 };
      if (l.status === "승인완료") processMap[k].done += 1;
      if (l.status === "결재중") processMap[k].progress += 1;
    });
    const pLabels = Object.keys(processMap);
    const finalLabels = pLabels.length ? pLabels : ["데이터 없음"];
    const progressData = pLabels.length ? pLabels.map(k => processMap[k].progress) : [0];
    const doneData = pLabels.length ? pLabels.map(k => processMap[k].done) : [0];
    processProgressChart = new Chart(document.getElementById("processProgressChart"), {
      type: "bar",
      data: {
        labels: finalLabels,
        datasets: [
          { label: "진행중", data: progressData, backgroundColor: "#f59e0b" },
          { label: "완료", data: doneData, backgroundColor: "#22c55e" }
        ]
      },
      options: { responsive: true, maintainAspectRatio: false }
    });
  }

  function refreshAll() {
    renderTemplateTable();
    renderTemplateSelect();
    renderWriterLogs();
    renderApprovalInbox();
    renderApproverAdmin();
    renderStats();
  }

  function bindEvents() {
    $.addTextQBtn.addEventListener("click", () => addBuilderItem("text"));
    $.addChoiceQBtn.addEventListener("click", () => addBuilderItem("choice"));
    $.addNumberQBtn.addEventListener("click", () => addBuilderItem("number"));
    $.saveTemplateBtn.addEventListener("click", saveTemplate);
    $.addFactoryBtn.addEventListener("click", () => {
      const v = $.newFactoryInput.value.trim();
      if (!v) return;
      if (!factoryOptions.includes(v)) factoryOptions.push(v);
      $.newFactoryInput.value = "";
      saveAll();
      renderCategoryOptions();
      renderTemplateTable();
    });
    $.addProcessBtn.addEventListener("click", () => {
      const v = $.newProcessInput.value.trim();
      if (!v) return;
      if (!processOptions.includes(v)) processOptions.push(v);
      $.newProcessInput.value = "";
      saveAll();
      renderCategoryOptions();
      renderTemplateTable();
    });
    $.filterFactory.addEventListener("change", renderTemplateTable);
    $.filterProcess.addEventListener("change", renderTemplateTable);
    $.filterCycle.addEventListener("change", renderTemplateTable);
    $.resetTemplateFilters.addEventListener("click", () => {
      $.filterFactory.value = "";
      $.filterProcess.value = "";
      $.filterCycle.value = "";
      renderTemplateTable();
    });

    $.execTemplateSelect.addEventListener("change", renderExecForm);
    $.saveDraftLogBtn.addEventListener("click", () => saveCheckLog("임시저장"));
    $.requestApprovalBtn.addEventListener("click", () => saveCheckLog("결재중"));
    $.bulkRequestBtn.addEventListener("click", requestBulkByMonth);

    $.showDelayedBtn.addEventListener("click", () => {
      $.delayedListWrap.style.display = $.delayedListWrap.style.display === "none" ? "block" : "none";
    });
  }

  function init() {
    bindSidebar();
    loadAll();
    renderCategoryOptions();
    $.execDate.value = new Date().toISOString().slice(0, 10);
    $.bulkMonth.value = new Date().toISOString().slice(0, 7);
    bindEvents();
    renderBuilder();
    refreshAll();
  }

  init();
</script>
</body>
</html>
