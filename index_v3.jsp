<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
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
          <div class="col-md-3">
            <label class="form-label">주기</label>
            <select id="templateCycle" class="form-select">
              <option value="일일">일일</option>
              <option value="주간">주간</option>
              <option value="월간">월간</option>
            </select>
          </div>
          <div class="col-md-2">
            <label class="form-label">SLA(시간)</label>
            <input type="number" id="templateSlaHours" class="form-control" min="1" value="24" />
          </div>
          <div class="col-md-2 d-grid align-items-end">
            <button class="btn btn-primary" id="saveTemplateBtn" type="button">템플릿 저장</button>
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
        <div class="table-responsive">
          <table class="table table-sm align-middle" id="templateTable">
            <thead class="table-light">
            <tr>
              <th>제목</th>
              <th>주기</th>
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
          <div class="col-md-2">
            <label class="form-label">점검일</label>
            <input type="date" id="execDate" class="form-control" />
          </div>
          <div class="col-md-2">
            <label class="form-label">담당자</label>
            <input type="text" id="lineOwner" class="form-control" placeholder="담당자" />
          </div>
          <div class="col-md-2">
            <label class="form-label">검토자</label>
            <input type="text" id="lineReviewer" class="form-control" placeholder="검토자" />
          </div>
          <div class="col-md-2">
            <label class="form-label">승인자</label>
            <input type="text" id="lineApprover" class="form-control" placeholder="승인자" />
          </div>
        </div>
      </div>

      <div class="surface mb-3">
        <h6 class="fw-bold">점검 입력</h6>
        <div id="execFormArea" class="mt-2"></div>
      </div>

      <div class="surface">
        <div class="d-flex gap-2">
          <button class="btn btn-secondary" id="saveDraftLogBtn" type="button">임시저장</button>
          <button class="btn btn-warning" id="requestApprovalBtn" type="button">결재 요청</button>
        </div>
      </div>
    </section>

    <section id="approvalPage" class="section-page">
      <div class="surface">
        <div class="d-flex justify-content-between align-items-center mb-2">
          <h5 class="fw-bold m-0">결재함</h5>
          <div class="d-flex align-items-center gap-2">
            <label class="small text-muted">처리자 역할</label>
            <select id="approvalRole" class="form-select form-select-sm" style="width: 120px;">
              <option value="reviewer">검토자</option>
              <option value="approver">승인자</option>
            </select>
          </div>
        </div>

        <div class="table-responsive">
          <table class="table align-middle" id="approvalTableV3">
            <thead class="table-light">
            <tr>
              <th>요청시각</th>
              <th>템플릿</th>
              <th>주기</th>
              <th>담당자→검토자→승인자</th>
              <th>상태</th>
              <th>SLA</th>
              <th>처리</th>
            </tr>
            </thead>
            <tbody></tbody>
          </table>
        </div>
      </div>
    </section>

    <section id="statsPage" class="section-page">
      <div class="row g-3 mb-3">
        <div class="col-md-3"><div class="kpi"><div class="label">전체 템플릿</div><div class="value" id="kpiTemplates">0</div></div></div>
        <div class="col-md-3"><div class="kpi"><div class="label">전체 점검 로그</div><div class="value" id="kpiLogs">0</div></div></div>
        <div class="col-md-3"><div class="kpi"><div class="label">결재중</div><div class="value text-warning" id="kpiInApproval">0</div></div></div>
        <div class="col-md-3"><div class="kpi"><div class="label">지연 건수</div><div class="value text-danger" id="kpiDelayed">0</div></div></div>
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
  </main>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
  const STORAGE = {
    templates: "Templates",
    logs: "CheckLogs",
    approvals: "Approvals"
  };

  let templates = [];
  let checkLogs = [];
  let approvals = [];
  let builderItems = [];
  let complianceChart = null;
  let delayChart = null;

  const $ = {
    sideBtns: document.querySelectorAll(".side-btn"),
    pages: document.querySelectorAll(".section-page"),
    templateTitle: document.getElementById("templateTitle"),
    templateCycle: document.getElementById("templateCycle"),
    templateSlaHours: document.getElementById("templateSlaHours"),
    saveTemplateBtn: document.getElementById("saveTemplateBtn"),
    addTextQBtn: document.getElementById("addTextQBtn"),
    addChoiceQBtn: document.getElementById("addChoiceQBtn"),
    addNumberQBtn: document.getElementById("addNumberQBtn"),
    builderItems: document.getElementById("builderItems"),
    templateTableBody: document.querySelector("#templateTable tbody"),
    execTemplateSelect: document.getElementById("execTemplateSelect"),
    execDate: document.getElementById("execDate"),
    lineOwner: document.getElementById("lineOwner"),
    lineReviewer: document.getElementById("lineReviewer"),
    lineApprover: document.getElementById("lineApprover"),
    execFormArea: document.getElementById("execFormArea"),
    saveDraftLogBtn: document.getElementById("saveDraftLogBtn"),
    requestApprovalBtn: document.getElementById("requestApprovalBtn"),
    approvalRole: document.getElementById("approvalRole"),
    approvalTableBody: document.querySelector("#approvalTableV3 tbody"),
    kpiTemplates: document.getElementById("kpiTemplates"),
    kpiLogs: document.getElementById("kpiLogs"),
    kpiInApproval: document.getElementById("kpiInApproval"),
    kpiDelayed: document.getElementById("kpiDelayed")
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

    writeJson(STORAGE.templates, templates);
    writeJson(STORAGE.logs, checkLogs);
    writeJson(STORAGE.approvals, approvals);
  }

  function normalizeTemplate(t) {
    return {
      id: t.id || uid("TPL"),
      title: t.title || "제목없음 템플릿",
      cycle: ["일일", "주간", "월간"].includes(t.cycle) ? t.cycle : "일일",
      slaHours: Number(t.slaHours) > 0 ? Number(t.slaHours) : 24,
      fields: Array.isArray(t.fields) ? t.fields.map(f => ({
        id: f.id || uid("Q"),
        label: f.label || "문항",
        type: ["text", "choice", "number"].includes(f.type) ? f.type : "text",
        options: Array.isArray(f.options) ? f.options : ["정상", "이상"]
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
      cycle: ["일일", "주간", "월간"].includes(l.cycle) ? l.cycle : "일일",
      execDate: l.execDate || new Date().toISOString().slice(0, 10),
      answers: Array.isArray(l.answers) ? l.answers : [],
      approvalLine: l.approvalLine || { owner: "", reviewer: "", approver: "" },
      status: ["임시저장", "결재중", "승인완료", "반려"].includes(l.status) ? l.status : "임시저장",
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
      cycle: ["일일", "주간", "월간"].includes(a.cycle) ? a.cycle : "일일",
      line: a.line || { owner: "", reviewer: "", approver: "" },
      requestedAt: a.requestedAt || new Date().toISOString(),
      slaHours: Number(a.slaHours) > 0 ? Number(a.slaHours) : 24,
      status: ["결재중", "승인완료", "반려"].includes(a.status) ? a.status : "결재중",
      currentStep: ["reviewer", "approver", "done"].includes(a.currentStep) ? a.currentStep : "reviewer",
      delayFlag: Boolean(a.delayFlag),
      processedAt: a.processedAt || null
    };
  }

  function saveAll() {
    writeJson(STORAGE.templates, templates);
    writeJson(STORAGE.logs, checkLogs);
    writeJson(STORAGE.approvals, approvals);
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
    const cycle = $.templateCycle.value;
    const slaHours = Number($.templateSlaHours.value || 24);

    if (!title) return alert("템플릿 제목을 입력하세요.");
    if (!builderItems.length) return alert("최소 1개 이상의 문항이 필요합니다.");

    const template = normalizeTemplate({
      id: uid("TPL"),
      title,
      cycle,
      slaHours,
      fields: builderItems,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    });

    templates.unshift(template);
    saveAll();
    renderTemplateTable();
    renderTemplateSelect();
    alert("템플릿이 저장되었습니다.");
  }

  function renderTemplateTable() {
    if (!templates.length) {
      $.templateTableBody.innerHTML = '<tr><td colspan="5" class="text-center text-muted">저장된 템플릿이 없습니다.</td></tr>';
      return;
    }

    $.templateTableBody.innerHTML = templates.map(t => `
      <tr>
        <td>${t.title}</td>
        <td>${t.cycle}</td>
        <td>${t.fields.length}</td>
        <td>${t.slaHours}시간</td>
        <td>
          <button class="btn btn-sm btn-outline-primary use-template-btn" data-id="${t.id}" type="button">불러오기</button>
          <button class="btn btn-sm btn-outline-danger delete-template-btn" data-id="${t.id}" type="button">삭제</button>
        </td>
      </tr>
    `).join("");

    document.querySelectorAll(".use-template-btn").forEach(btn => {
      btn.addEventListener("click", () => {
        const tpl = templates.find(t => t.id === btn.dataset.id);
        if (!tpl) return;
        $.templateTitle.value = tpl.title;
        $.templateCycle.value = tpl.cycle;
        $.templateSlaHours.value = tpl.slaHours;
        builderItems = tpl.fields.map(f => ({ ...f, options: [...(f.options || [])] }));
        renderBuilder();
      });
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

    $.execTemplateSelect.innerHTML = templates.map(t => `<option value="${t.id}">${t.title} (${t.cycle})</option>`).join("");
    renderExecForm();
  }

  function renderExecForm() {
    const tpl = templates.find(t => t.id === $.execTemplateSelect.value) || templates[0];
    if (!tpl) return;

    $.execFormArea.innerHTML = tpl.fields.map(f => {
      if (f.type === "number") {
        return `
          <div class="mb-2">
            <label class="form-label">${f.label}</label>
            <input type="number" class="form-control exec-answer" data-qid="${f.id}" data-type="number" />
          </div>
        `;
      }

      if (f.type === "choice") {
        const ops = (f.options || ["정상", "이상"]).map(op => `<option value="${op}">${op}</option>`).join("");
        return `
          <div class="mb-2">
            <label class="form-label">${f.label}</label>
            <select class="form-select exec-answer" data-qid="${f.id}" data-type="choice">${ops}</select>
          </div>
        `;
      }

      return `
        <div class="mb-2">
          <label class="form-label">${f.label}</label>
          <input type="text" class="form-control exec-answer" data-qid="${f.id}" data-type="text" />
        </div>
      `;
    }).join("");
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
    const reviewer = $.lineReviewer.value.trim();
    const approver = $.lineApprover.value.trim();

    if (!owner || !reviewer || !approver) {
      return alert("결재 라인(담당자/검토자/승인자)을 모두 입력하세요.");
    }

    const logId = uid("LOG");
    const answers = collectExecAnswers();

    let approvalId = null;
    if (nextStatus === "결재중") {
      const approval = normalizeApproval({
        id: uid("APR"),
        checkLogId: logId,
        templateId: tpl.id,
        templateTitle: tpl.title,
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
      cycle: tpl.cycle,
      execDate: $.execDate.value || new Date().toISOString().slice(0, 10),
      answers,
      approvalLine: { owner, reviewer, approver },
      status: nextStatus,
      approvalId,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    });

    checkLogs.unshift(log);
    saveAll();
    refreshAll();
    alert(nextStatus === "결재중" ? "결재 요청 완료" : "임시저장 완료");
  }

  // approval
  function isDelayed(approval) {
    if (approval.status !== "결재중") return false;
    const requestedMs = new Date(approval.requestedAt).getTime();
    const dueMs = requestedMs + approval.slaHours * 3600 * 1000;
    return Date.now() > dueMs;
  }

  function renderApprovalInbox() {
    approvals.forEach(a => a.delayFlag = isDelayed(a));

    const sorted = [...approvals].sort((a, b) => {
      if (a.delayFlag !== b.delayFlag) return a.delayFlag ? -1 : 1;
      return new Date(b.requestedAt) - new Date(a.requestedAt);
    });

    if (!sorted.length) {
      $.approvalTableBody.innerHTML = '<tr><td colspan="7" class="text-center text-muted">결재 데이터가 없습니다.</td></tr>';
      return;
    }

    $.approvalTableBody.innerHTML = sorted.map(a => {
      const late = a.delayFlag ? "sla-late" : "";
      const statusBadge = a.status === "승인완료"
        ? '<span class="badge text-bg-success">승인완료</span>'
        : a.status === "반려"
          ? '<span class="badge text-bg-danger">반려</span>'
          : '<span class="badge text-bg-warning">결재중</span>';

      const canReview = $.approvalRole.value === "reviewer" && a.status === "결재중" && a.currentStep === "reviewer";
      const canApprove = $.approvalRole.value === "approver" && a.status === "결재중" && a.currentStep === "approver";

      return `
        <tr class="${late}">
          <td>${a.requestedAt.replace("T", " ").slice(0, 16)}</td>
          <td>${a.templateTitle}</td>
          <td>${a.cycle}</td>
          <td>${a.line.owner} → ${a.line.reviewer} → ${a.line.approver}</td>
          <td>${statusBadge} ${a.delayFlag ? '<span class="ms-1">⚠️ 지연</span>' : ''}</td>
          <td>${a.slaHours}시간</td>
          <td>
            ${canReview ? `<button class="btn btn-sm btn-primary inbox-act" data-id="${a.id}" data-action="review-ok">검토완료</button>` : ""}
            ${canApprove ? `<button class="btn btn-sm btn-success inbox-act" data-id="${a.id}" data-action="approve">승인</button>
                           <button class="btn btn-sm btn-outline-danger inbox-act" data-id="${a.id}" data-action="reject">반려</button>` : ""}
          </td>
        </tr>
      `;
    }).join("");

    document.querySelectorAll(".inbox-act").forEach(btn => {
      btn.addEventListener("click", () => handleApprovalAction(btn.dataset.id, btn.dataset.action));
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
    } else {
      log.status = "반려";
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

    if (action === "approve" && target.currentStep === "approver") {
      target.currentStep = "done";
      target.status = "승인완료";
      target.processedAt = new Date().toISOString();
    }

    if (action === "reject") {
      target.currentStep = "done";
      target.status = "반려";
      target.processedAt = new Date().toISOString();
    }

    syncLogStatus(target);
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

    if (complianceChart) complianceChart.destroy();
    if (delayChart) delayChart.destroy();

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
  }

  function refreshAll() {
    renderTemplateTable();
    renderTemplateSelect();
    renderApprovalInbox();
    renderStats();
  }

  function bindEvents() {
    $.addTextQBtn.addEventListener("click", () => addBuilderItem("text"));
    $.addChoiceQBtn.addEventListener("click", () => addBuilderItem("choice"));
    $.addNumberQBtn.addEventListener("click", () => addBuilderItem("number"));
    $.saveTemplateBtn.addEventListener("click", saveTemplate);

    $.execTemplateSelect.addEventListener("change", renderExecForm);
    $.saveDraftLogBtn.addEventListener("click", () => saveCheckLog("임시저장"));
    $.requestApprovalBtn.addEventListener("click", () => saveCheckLog("결재중"));

    $.approvalRole.addEventListener("change", renderApprovalInbox);
  }

  function init() {
    bindSidebar();
    loadAll();
    $.execDate.value = new Date().toISOString().slice(0, 10);
    bindEvents();
    renderBuilder();
    refreshAll();
  }

  init();
</script>
</body>
</html>
