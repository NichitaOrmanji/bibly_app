// Общее оформление отчётов в Word по требованиям UTM (см. docs/REPORT_FORMAT.md).
// Отчёт описывается списком блоков; build() собирает .docx и проставляет
// номера страниц в содержании (второй проход через LibreOffice).

const fs = require("fs");
const os = require("os");
const path = require("path");
const { execFileSync } = require("child_process");
const {
  Document, Packer, Paragraph, TextRun, Table, TableRow, TableCell,
  AlignmentType, HeadingLevel, WidthType, BorderStyle, ShadingType,
  Footer, PageNumber, TabStopType, VerticalAlign, SectionType,
} = require("docx");

const FONT = "Times New Roman";
const CODE_FONT = "Courier New";
const BODY = 24; // 12 pt — основной текст
const CHAPTER = 26; // 13 pt — заголовок главы
const TABLE = 22; // 11 pt — текст в таблицах и схемах
const CODE = 20; // 10 pt — исходный код

// A4; поля: верх, низ, слева — 20 мм, справа — 10 мм.
const PAGE_W = 11906, PAGE_H = 16838;
const MARGIN = { top: 1134, bottom: 1134, left: 1134, right: 567 };
const TEXT_W = PAGE_W - MARGIN.left - MARGIN.right;
const INDENT = 709; // 1,25 см
const LINE = 360; // интервал 1,5

// ---------- текст ----------

const run = (t) => (typeof t === "string" ? new TextRun({ text: t, font: FONT, size: BODY }) : t);
const b = (text) => new TextRun({ text, font: FONT, size: BODY, bold: true });
const i = (text) => new TextRun({ text, font: FONT, size: BODY, italics: true });

const p = (text, opts = {}) => new Paragraph({
  alignment: opts.align ?? AlignmentType.JUSTIFIED,
  indent: opts.noIndent ? undefined : { firstLine: INDENT },
  spacing: { line: LINE, before: opts.before ?? 0, after: opts.after ?? 0 },
  keepNext: opts.keepNext,
  children: (Array.isArray(text) ? text : [text]).map(run),
});

const bullet = (text) => new Paragraph({
  numbering: { reference: "dash", level: 0 },
  alignment: AlignmentType.JUSTIFIED,
  spacing: { line: LINE },
  children: (Array.isArray(text) ? text : [text]).map(run),
});

// Исходный код: Courier New 10 pt, интервал 1. Больше половины страницы — в приложение.
const code = (lines) => lines.map(l => new Paragraph({
  spacing: { line: 240 },
  children: [new TextRun({ text: l, font: CODE_FONT, size: CODE })],
}));

// Подпись таблицы — над таблицей слева, рисунка — под рисунком по центру.
const tableCaption = (text) => new Paragraph({
  spacing: { before: 120, after: 60, line: 240 }, keepNext: true,
  children: [new TextRun({ text, font: FONT, size: BODY })],
});
const figureCaption = (text) => new Paragraph({
  alignment: AlignmentType.CENTER, spacing: { before: 60, after: 120, line: 240 },
  children: [new TextRun({ text, font: FONT, size: BODY })],
});

// ---------- заголовки ----------

// Глава: с новой страницы, прописными, Bold, по центру, 13 pt.
// Номер арабской цифрой без точки; введение, выводы и т. п. — без номера.
const chapter = (num, title) => ({ kind: "chapter", num, title });
// Подглава: «1.1 Название», Bold 12 pt, по левому краю.
const section = (num, title) => ({ kind: "section", num, title });

const headingText = (h) => (h.num ? `${h.num} ` : "") + (h.kind === "chapter" ? h.title.toUpperCase() : h.title);

function headingParagraph(h, first) {
  const isCh = h.kind === "chapter";
  return new Paragraph({
    heading: isCh ? HeadingLevel.HEADING_1 : HeadingLevel.HEADING_2,
    alignment: isCh ? AlignmentType.CENTER : AlignmentType.LEFT,
    pageBreakBefore: isCh && !first,
    keepNext: true,
    spacing: isCh ? { before: 0, after: 240, line: 240 } : { before: 240, after: 120, line: 240 },
    indent: isCh ? undefined : { firstLine: INDENT },
    children: [new TextRun({ text: headingText(h), font: FONT, size: isCh ? CHAPTER : BODY, bold: true })],
  });
}

// ---------- таблицы и схемы ----------

const border = { style: BorderStyle.SINGLE, size: 4, color: "000000" };
const borders = { top: border, bottom: border, left: border, right: border };
const none = { style: BorderStyle.NONE, size: 0, color: "FFFFFF" };

const cell = (text, width, { header = false, center = false } = {}) => new TableCell({
  borders,
  width: { size: width, type: WidthType.DXA },
  shading: header ? { fill: "E7E6E6", type: ShadingType.CLEAR, color: "auto" } : undefined,
  margins: { top: 40, bottom: 40, left: 100, right: 100 },
  verticalAlign: VerticalAlign.CENTER,
  children: [new Paragraph({
    alignment: header || center ? AlignmentType.CENTER : AlignmentType.LEFT,
    spacing: { line: 240 },
    children: [new TextRun({ text, font: FONT, size: TABLE, bold: header })],
  })],
});

// widths — относительные доли колонок; centerCols — колонки с выравниванием по центру.
function table(widths, header, rows, centerCols = [0]) {
  const scale = TEXT_W / widths.reduce((a, c) => a + c, 0);
  const w = widths.map(x => Math.floor(x * scale));
  w[w.length - 1] += TEXT_W - w.reduce((a, c) => a + c, 0);
  return new Table({
    width: { size: TEXT_W, type: WidthType.DXA },
    columnWidths: w,
    rows: [
      new TableRow({ tableHeader: true, children: header.map((h, k) => cell(h, w[k], { header: true })) }),
      ...rows.map(r => new TableRow({
        cantSplit: true,
        children: r.map((c, k) => cell(c, w[k], { center: centerCols.includes(k) })),
      })),
    ],
  });
}

// Схема процесса: этапы в рамках, соединённые стрелками; под этапом — исполнитель.
// Вся схема — в одной неразрывной ячейке без рамок, чтобы не делилась между страницами.
function flow(steps) {
  const BOX_W = 6800;
  const thick = { style: BorderStyle.SINGLE, size: 8, color: "000000" };
  const out = [];
  steps.forEach(([who, what], k) => {
    out.push(new Table({
      alignment: AlignmentType.CENTER,
      width: { size: BOX_W, type: WidthType.DXA },
      columnWidths: [BOX_W],
      rows: [new TableRow({
        cantSplit: true,
        children: [new TableCell({
          borders: { top: thick, bottom: thick, left: thick, right: thick },
          width: { size: BOX_W, type: WidthType.DXA },
          shading: { fill: "F2F2F2", type: ShadingType.CLEAR, color: "auto" },
          margins: { top: 50, bottom: 50, left: 120, right: 120 },
          children: [
            new Paragraph({
              alignment: AlignmentType.CENTER, spacing: { line: 240 },
              children: [new TextRun({ text: `${k + 1}. ${what}`, font: FONT, size: TABLE, bold: true })],
            }),
            new Paragraph({
              alignment: AlignmentType.CENTER, spacing: { line: 240 },
              children: [new TextRun({ text: who, font: FONT, size: 20, italics: true })],
            }),
          ],
        })],
      })],
    }));
    if (k < steps.length - 1) {
      out.push(new Paragraph({
        alignment: AlignmentType.CENTER, spacing: { line: 240 },
        children: [new TextRun({ text: "↓", font: FONT, size: BODY, bold: true })],
      }));
    }
  });
  return new Table({
    width: { size: TEXT_W, type: WidthType.DXA },
    columnWidths: [TEXT_W],
    rows: [new TableRow({
      cantSplit: true,
      children: [new TableCell({
        borders: { top: none, bottom: none, left: none, right: none },
        width: { size: TEXT_W, type: WidthType.DXA },
        children: [new Paragraph({ spacing: { line: 240 }, children: [] }), ...out],
      })],
    })],
  });
}

// ---------- титульный лист ----------

const center = (text, opts = {}) => new Paragraph({
  alignment: AlignmentType.CENTER,
  spacing: { line: 276, before: opts.before ?? 0, after: opts.after ?? 0 },
  children: [new TextRun({ text, font: FONT, size: opts.size ?? 28, bold: opts.bold })],
});

const signLine = (left, right) => new Paragraph({
  tabStops: [{ type: TabStopType.RIGHT, position: TEXT_W }],
  spacing: { line: LINE },
  children: [
    new TextRun({ text: left, font: FONT, size: 28 }),
    new TextRun({ text: `\t${right}`, font: FONT, size: 28 }),
  ],
});

// t: { work, course, topic: [строки], project: [строки], student, group, checkerLabel, checker, year }
function titlePage(t) {
  return [
    center("МИНИСТЕРСТВО ОБРАЗОВАНИЯ, КУЛЬТУРЫ И ИССЛЕДОВАНИЙ"),
    center("РЕСПУБЛИКИ МОЛДОВА"),
    center("ТЕХНИЧЕСКИЙ УНИВЕРСИТЕТ МОЛДОВЫ"),
    center("ДЕПАРТАМЕНТ ПРОГРАММНОЙ ИНЖЕНЕРИИ И АВТОМАТИКИ"),
    center("ОТЧЁТ", { before: 3400, size: 40, bold: true, after: 120 }),
    center(t.work, { size: 32 }),
    center(t.course, { before: 120 }),
    ...t.topic.map((l, k) => center(l, { before: k === 0 ? 240 : 0, bold: true })),
    ...(t.project ?? []).map((l, k) => center(l, { before: k === 0 ? 240 : 0 })),
    new Paragraph({ spacing: { before: 2600 }, children: [] }),
    signLine(`Выполнил студент группы ${t.group}:`, t.student),
    signLine(t.checkerLabel, t.checker),
    center(`Кишинёв ${t.year}`, { before: 2400 }),
  ];
}

// ---------- содержание ----------

function tocParagraphs(headings, pages) {
  return headings.map(h => new Paragraph({
    tabStops: [{ type: TabStopType.RIGHT, position: TEXT_W, leader: "dot" }],
    indent: h.kind === "section" ? { left: 360 } : undefined,
    spacing: { line: LINE },
    children: [new TextRun({ text: `${headingText(h)}\t${pages.get(h) ?? ""}`, font: FONT, size: BODY })],
  }));
}

// ---------- сборка ----------

// front — блоки до введения (список сокращений и т. п., без номеров страниц);
// body — с введения до конца. Блок — Paragraph/Table или chapter()/section().
function makeDoc({ meta, title, front, body }, pages) {
  const headings = [...front, ...body].filter(x => x && x.kind);
  const render = (blocks, firstIsFirst) => blocks.map((x, k) =>
    x && x.kind ? headingParagraph(x, firstIsFirst && k === 0) : x);

  const tocTitle = new Paragraph({
    alignment: AlignmentType.CENTER, pageBreakBefore: true,
    spacing: { after: 240, line: 240 },
    children: [new TextRun({ text: "СОДЕРЖАНИЕ", font: FONT, size: CHAPTER, bold: true })],
  });

  const page = { size: { width: PAGE_W, height: PAGE_H }, margin: MARGIN };
  const emptyFooter = new Footer({ children: [new Paragraph({ children: [] })] });

  return new Document({
    creator: meta.author,
    title: meta.title,
    styles: {
      default: { document: { run: { font: FONT, size: BODY, color: "000000" } } },
      paragraphStyles: [
        { id: "Heading1", name: "Heading 1", basedOn: "Normal", next: "Normal", quickFormat: true,
          run: { font: FONT, size: CHAPTER, bold: true, color: "000000" }, paragraph: { outlineLevel: 0 } },
        { id: "Heading2", name: "Heading 2", basedOn: "Normal", next: "Normal", quickFormat: true,
          run: { font: FONT, size: BODY, bold: true, color: "000000" }, paragraph: { outlineLevel: 1 } },
      ],
    },
    numbering: {
      config: [{
        reference: "dash",
        levels: [{ level: 0, format: "bullet", text: "–", alignment: AlignmentType.LEFT,
          style: { paragraph: { indent: { left: INDENT + 360, hanging: 360 } } } }],
      }],
    },
    sections: [
      // Титул, содержание, список сокращений: страницы считаются, номер не печатается.
      {
        properties: { page },
        footers: { default: emptyFooter },
        children: [...titlePage(title), tocTitle, ...tocParagraphs(headings, pages), ...render(front, false)],
      },
      // С введения: номер внизу по центру, без точки; нумерация продолжается.
      {
        properties: { page, type: SectionType.NEXT_PAGE },
        footers: {
          default: new Footer({
            children: [new Paragraph({
              alignment: AlignmentType.CENTER,
              children: [new TextRun({ children: [PageNumber.CURRENT], font: FONT, size: BODY })],
            })],
          }),
        },
        children: render(body, true),
      },
    ],
  });
}

// Номера страниц заголовков: рендер в PDF через LibreOffice и поиск текста заголовка.
function findPages(docxPath, headings) {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), "report-"));
  execFileSync("soffice", [
    `-env:UserInstallation=file://${dir}/profile`, "--headless",
    "--convert-to", "pdf", "--outdir", dir, docxPath,
  ], { stdio: "ignore" });
  const pdf = path.join(dir, path.basename(docxPath).replace(/\.docx$/, ".pdf"));
  const norm = (s) => s.replace(/\s+/g, " ").trim();
  const texts = execFileSync("pdftotext", [pdf, "-"]).toString().split("\f").map(norm);
  const tocPage = texts.findIndex(t => t.includes("СОДЕРЖАНИЕ"));
  const pages = new Map();
  let from = tocPage + 1;
  for (const h of headings) {
    const key = norm(headingText(h)).slice(0, 30);
    for (let k = from; k < texts.length; k++) {
      if (texts[k].includes(key)) { pages.set(h, k + 1); from = k; break; }
    }
  }
  fs.rmSync(dir, { recursive: true, force: true });
  return pages;
}

async function build(report, outPath) {
  const headings = [...report.front, ...report.body].filter(x => x && x.kind);
  fs.writeFileSync(outPath, await Packer.toBuffer(makeDoc(report, new Map())));
  let pages = new Map();
  try {
    pages = findPages(outPath, headings);
  } catch (e) {
    console.warn("LibreOffice недоступен — номера страниц в содержании не проставлены.");
  }
  fs.writeFileSync(outPath, await Packer.toBuffer(makeDoc(report, pages)));
  const missing = headings.filter(h => !pages.has(h)).map(headingText);
  if (missing.length) console.warn("Не найдены страницы для:", missing.join("; "));
  console.log(outPath);
}

module.exports = {
  FONT, BODY, TEXT_W, AlignmentType, Paragraph, TextRun,
  p, b, i, bullet, code, tableCaption, figureCaption, table, flow, chapter, section, build,
};
