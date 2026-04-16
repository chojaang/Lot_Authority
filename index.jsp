<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>
<%
    request.setCharacterEncoding("UTF-8");

    class LotRow {
        int no;
        String lotId;
        String status;

        LotRow(int no, String lotId, String status) {
            this.no = no;
            this.lotId = lotId;
            this.status = status;
        }
    }

    List<LotRow> resultRows = new ArrayList<>();
    String rawData = request.getParameter("lotData");

    if (rawData != null) {
        String[] lines = rawData.split("\\r?\\n");
        int no = 1;

        for (String line : lines) {
            if (line == null || line.trim().isEmpty()) {
                continue;
            }

            String[] cells = line.split("\\t");
            String lotId = cells.length > 0 ? cells[0].trim() : "";
            if (lotId.isEmpty()) {
                continue;
            }

            String status = (lotId.hashCode() & 1) == 0 ? "완료" : "대기중";
            resultRows.add(new LotRow(no, lotId, status));
            no++;
        }
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>LOT 데이터 대량 검색</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-slate-100 min-h-screen text-slate-800">
<div class="max-w-6xl mx-auto px-4 py-10">
    <header class="mb-8">
        <h1 class="text-3xl font-bold text-slate-900">LOT 데이터 대량 검색</h1>
        <p class="text-sm text-slate-500 mt-2">엑셀에서 복사한 LOT 데이터를 붙여넣고 실시간으로 확인하세요.</p>
    </header>

    <section class="bg-white rounded-2xl shadow-sm border border-slate-200 p-6">
        <form method="post" action="index.jsp" class="space-y-5">
            <div>
                <label for="lotData" class="block text-sm font-medium mb-2 text-slate-700">LOT 입력 데이터</label>
                <textarea
                    id="lotData"
                    name="lotData"
                    rows="9"
                    class="w-full rounded-xl border border-slate-300 focus:outline-none focus:ring-2 focus:ring-blue-400 focus:border-blue-400 p-4 text-sm resize-y"
                    placeholder="엑셀에서 복사한 데이터를 붙여넣으세요"><%= rawData == null ? "" : rawData %></textarea>
            </div>
            <div class="flex flex-wrap gap-3">
                <button type="submit" class="inline-flex items-center px-6 py-2.5 rounded-xl bg-blue-600 text-white text-sm font-semibold hover:bg-blue-700 transition-colors">검색하기</button>
                <button type="button" id="clearBtn" class="inline-flex items-center px-4 py-2.5 rounded-xl bg-slate-200 text-slate-700 text-sm font-medium hover:bg-slate-300 transition-colors">입력 초기화</button>
            </div>
        </form>

        <div class="mt-8">
            <div class="flex items-center justify-between mb-3">
                <h2 class="text-lg font-semibold text-slate-900">실시간 미리보기</h2>
                <span id="previewCount" class="text-xs text-slate-500">0건</span>
            </div>
            <div class="overflow-auto border border-slate-200 rounded-xl">
                <table class="min-w-full text-sm">
                    <thead class="bg-slate-50 text-slate-600">
                    <tr>
                        <th class="px-4 py-3 text-left font-semibold">No.</th>
                        <th class="px-4 py-3 text-left font-semibold">원본 행 데이터</th>
                        <th class="px-4 py-3 text-left font-semibold">삭제</th>
                    </tr>
                    </thead>
                    <tbody id="previewBody" class="divide-y divide-slate-100 bg-white">
                    <tr>
                        <td colspan="3" class="px-4 py-6 text-center text-slate-400">입력 대기 중입니다.</td>
                    </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </section>

    <section class="mt-8 bg-white rounded-2xl shadow-sm border border-slate-200 p-6">
        <div class="flex items-center justify-between mb-4 gap-3">
            <h2 class="text-xl font-semibold text-slate-900">검색 결과</h2>
            <button type="button" id="copyResultBtn" class="inline-flex items-center px-4 py-2 rounded-lg bg-emerald-600 text-white text-xs font-semibold hover:bg-emerald-700 transition-colors">결과 복사하기</button>
        </div>

        <% if (resultRows.isEmpty()) { %>
            <div class="rounded-xl border border-dashed border-slate-300 bg-slate-50 p-8 text-center text-slate-500">
                검색된 결과가 없습니다.
            </div>
        <% } else { %>
            <div class="overflow-auto border border-slate-200 rounded-xl">
                <table id="resultTable" class="min-w-full text-sm">
                    <thead class="bg-slate-50 text-slate-600">
                    <tr>
                        <th class="px-4 py-3 text-left font-semibold">순번</th>
                        <th class="px-4 py-3 text-left font-semibold">LOT 번호</th>
                        <th class="px-4 py-3 text-left font-semibold">처리상태</th>
                    </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-100 bg-white">
                    <% for (LotRow row : resultRows) { %>
                        <tr>
                            <td class="px-4 py-3"><%= row.no %></td>
                            <td class="px-4 py-3 font-medium text-slate-900"><%= row.lotId %></td>
                            <td class="px-4 py-3">
                                <span class="inline-flex px-2.5 py-1 rounded-full text-xs font-semibold <%= "완료".equals(row.status) ? "bg-emerald-100 text-emerald-700" : "bg-amber-100 text-amber-700" %>">
                                    <%= row.status %>
                                </span>
                            </td>
                        </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
        <% } %>
    </section>
</div>

<script>
    const lotDataEl = document.getElementById('lotData');
    const previewBody = document.getElementById('previewBody');
    const previewCount = document.getElementById('previewCount');
    const clearBtn = document.getElementById('clearBtn');
    const copyResultBtn = document.getElementById('copyResultBtn');

    function escapeHtml(value) {
        return value
            .replaceAll('&', '&amp;')
            .replaceAll('<', '&lt;')
            .replaceAll('>', '&gt;')
            .replaceAll('"', '&quot;')
            .replaceAll("'", '&#39;');
    }

    function parseRows(rawText) {
        return rawText
            .split(/\r?\n/)
            .map(line => line.trim())
            .filter(line => line.length > 0)
            .map((line, idx) => ({
                index: idx + 1,
                columns: line.split('\t').filter(col => col.trim().length > 0),
                original: line
            }));
    }

    function renderPreview(rows) {
        if (!rows.length) {
            previewBody.innerHTML = '<tr><td colspan="3" class="px-4 py-6 text-center text-slate-400">입력 대기 중입니다.</td></tr>';
            previewCount.textContent = '0건';
            return;
        }

        previewBody.innerHTML = rows.map(row => {
            const columnsText = row.columns.length
                ? row.columns.map(cell => `<span class="inline-block mr-1 mb-1 px-2 py-1 bg-slate-100 rounded text-xs">${escapeHtml(cell)}</span>`).join('')
                : '<span class="text-slate-400">(빈 데이터)</span>';

            return `
                <tr>
                    <td class="px-4 py-3 text-slate-500">${row.index}</td>
                    <td class="px-4 py-3">${columnsText}</td>
                    <td class="px-4 py-3">
                        <button type="button" data-index="${row.index}" class="delete-row inline-flex items-center justify-center w-7 h-7 rounded-full bg-rose-100 text-rose-600 hover:bg-rose-200">×</button>
                    </td>
                </tr>
            `;
        }).join('');

        previewCount.textContent = `${rows.length}건`;
    }

    function updatePreviewFromTextarea() {
        const rows = parseRows(lotDataEl.value);
        renderPreview(rows);
    }

    lotDataEl.addEventListener('input', updatePreviewFromTextarea);
    lotDataEl.addEventListener('paste', () => setTimeout(updatePreviewFromTextarea, 0));

    previewBody.addEventListener('click', (event) => {
        const target = event.target;
        if (!(target instanceof HTMLElement) || !target.classList.contains('delete-row')) {
            return;
        }

        const removeIndex = Number(target.dataset.index);
        const currentRows = parseRows(lotDataEl.value);
        const filteredRows = currentRows.filter(row => row.index !== removeIndex).map(row => row.original);
        lotDataEl.value = filteredRows.join('\n');
        updatePreviewFromTextarea();
    });

    clearBtn.addEventListener('click', () => {
        lotDataEl.value = '';
        updatePreviewFromTextarea();
        lotDataEl.focus();
    });

    copyResultBtn.addEventListener('click', async () => {
        const resultTable = document.getElementById('resultTable');
        if (!resultTable) {
            alert('복사할 검색 결과가 없습니다.');
            return;
        }

        const rows = Array.from(resultTable.querySelectorAll('tbody tr'));
        const tsv = rows.map(row => {
            const cols = Array.from(row.querySelectorAll('td')).map(td => td.innerText.trim());
            return cols.join('\t');
        }).join('\n');

        try {
            await navigator.clipboard.writeText(tsv);
            alert('검색 결과를 클립보드에 복사했습니다.');
        } catch (err) {
            alert('클립보드 복사에 실패했습니다.');
        }
    });

    updatePreviewFromTextarea();
</script>
</body>
</html>
