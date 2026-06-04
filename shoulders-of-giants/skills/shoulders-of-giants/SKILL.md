---
name: shoulders-of-giants
description: >
  This skill should be used when the user asks to "系统性调研", "帮我查一下",
  "文献调研", "做调研", "检索资料", "research", "literature review",
  "帮我研究一下", "systematic research", "调研", or uses the
  /shoulders-of-giants command. It implements a 6-phase systematic research
  methodology: problem classification → search plan generation (user confirmed)
  → multi-source parallel collection → evidence stratification with watermarking
  → adversarial verification (3 angles per claim) → synthesis report with
  confidence ratings.
  Supports --quick mode (skip adversarial verification) and --deep mode
  (append timeline analysis).
version: 0.9.0
argument-hint: "'[--quick|--deep] <research-question>'"
allowed-tools:
  [
    "WebSearch",
    "WebFetch",
    "Bash",
    "Read",
    "Write",
    "Edit",
    "Agent",
  ]
session-start:
  - "Run `bash ${CLAUDE_PLUGIN_ROOT}/skills/shoulders-of-giants/scripts/verify.sh`"
  - "Check available MCP servers — especially PubMed, Consensus, bioRxiv, ClinicalTrials.gov"
  - "If both this plugin and industry-analysis are installed, note they can work in tandem: shoulders-of-giants for evidence collection + industry-analysis for industry interpretation"
---

# Shoulders of Giants / 系统性调研方法论

"站在巨人的肩膀上"——系统性调研的本质是以前人知识为起点，通过结构化的采集、检验和综合，得出可追溯、可审计、可纠错的结论。

## 与 industry-analysis 的关系

| 维度 | industry-analysis | shoulders-of-giants |
|------|-------------------|---------------------|
| 聚焦 | 产业分析（5类行业模板） | 通用调研方法论（不限领域） |
| 问题分类 | 5种行业类型 | 自动判断问题类型 |
| 证据分级 | 无 | 6级证据水印系统 |
| 对抗验证 | 无 | 3角度/主张强制检验 |
| 输出 | 金字塔结构报告 | 可信度标注综合报告 |
| MCP | 可选增强 | 推荐集成（PubMed/Consensus核心） |

**推荐联动方式**：
1. `shoulders-of-giants` 做信息采集、验证和可信度评估
2. 将发现作为输入，用 `industry-analysis` 做产业解读、趋势预测

---

## 6阶段流程总览

```
用户提问
  │
  ▼
阶段1: 问题分类 + 语言通道评估 ─── 展示结果 → 用户确认/修改
  │
  ▼
阶段2: 检索计划生成 + MCP路由 ─── 展示结果 → 用户确认/调整
  │
  ▼
阶段3: 多源并行采集
  │   ├─ PubMed (同行评议)
  │   ├─ Consensus (引文排名)
  │   ├─ bioRxiv (预印本)
  │   └─ WebSearch (产业资讯)
  │
  ▼
阶段4: 证据分层 + 水印标注
  │   └─ 推荐深挖方向 → 用户选择
  │
  ▼
阶段5: 对抗验证（3角度/主张） ← 快速模式可跳过
  │   ├─ 技术局限性
  │   ├─ 乐观偏差
  │   └─ 替代解释
  │
  ▼
阶段6: 综合报告（带可信度评级）
       └─ 信息缺口声明
```

---

## 阶段详解

### 阶段1: 问题定义与分类

自动判断问题类型，并按**语言通道评估规则**检查是否需要多语言检索：

| 问题类型 | 特征 | 适用数据源 |
|----------|------|-----------|
| 学术文献调研 | 涉及机制/方法/临床证据 | PubMed + Consensus + bioRxiv |
| 产业趋势评估 | 涉及影响/商业化/竞争 | Consensus + Web + ClinicalTrials |
| 技术可行性评估 | 涉及技术路线对比 | Consensus + PubMed + Web |
| 竞争格局分析 | 涉及玩家/融资/市场 | Web + ClinicalTrials |

**语言通道评估**（详见 `references/01-problem-classification.md`）：
- 检测问题中是否含中国相关的公司/团队/技术关键词
- 若命中 → 自动加入中文搜索通道
- 对每个通道生成对应的关键词对译表

**交互**：向用户展示分类结果和语言通道选择，等待确认/修改后再进入阶段2。

### 阶段2: 检索计划生成

根据问题类型匹配最优数据源组合，生成结构化检索计划：

```
┌─ 子问题1: [描述]
│   ├─ 推荐数据源: [源1, 源2]
│   └─ 检索策略: [关键词 + 过滤条件]
│
├─ 子问题2: [描述]
│   ├─ 推荐数据源: [源1, 源2]
│   └─ 检索策略: [关键词 + 过滤条件]
│
└─ 语言通道: [英文/中文/其他]
```

**PubMed MeSH 预检**：在提交检索前，对关键词做 MeSH 翻译检查。
已知陷阱词会自动标记警告（详见 `references/03-data-collection.md`）。

**交互**：展示计划 → 用户确认/调整。

### 阶段3: 多源并行采集

- 同时向选定数据源发起检索
- 检测0结果 → 自动放宽查询条件后重试
- 检索结果按相关性排序，返回各自命中数

**交互**：展示初步结果摘要 + 命中数统计。

### 阶段4: 证据分层与深挖方向推荐

使用**证据水印系统**（详见 `references/04-evidence-labeling.md`）对每条发现标注可信度：

```
🔒       交叉验证+对抗通过
📄⭐     单篇同行评议
🏢       产业资讯/公司公告
🔬       预印本
⚡       发现矛盾
❓       单一声称
```

**交互**：展示初步发现 + 水印标注 + 推荐2-4个深挖方向 → 用户选择。

### 阶段5: 对抗验证

对每个核心主张执行3角度对抗检验（详见 `references/05-adversarial-verification.md`）：

```
主张 P:
  A. 技术局限性 — "P在什么条件下会失效？"
  B. 乐观偏差 — "P的宣称是否被独立验证？"
  C. 替代解释 — "同样现象是否有其他解释？"
```

**快速模式**：直接跳过此阶段，进入综合报告。
**标准模式**：执行完整3角度验证。

**交互**：报告对抗发现 → 用户可选择在此环节深入某个争议点。

### 阶段6: 综合报告

输出结构化的调研报告，包含（详见 `references/06-synthesis-report.md`）：

```
执行摘要
调研方法（数据源+检索策略）
核心发现（每条带水印）
对抗验证结果（置信度调整说明）
产业影响时间线（如适用）
信息缺口声明
数据源列表
```

---

## MCP路由决策树

```
问题类型 = 学术文献调研?
├── YES → 必须: PubMed + Consensus
│         推荐: bioRxiv
│         可选: ChEMBL（机制相关）
│
├── 产业趋势/竞争格局?
│   ├── YES → 必须: Consensus + WebSearch
│   │         推荐: ClinicalTrials.gov（医疗相关）
│   │         可选: PubMed
│   │
│   └── NO → WebSearch为主
│             Consensus辅助
│
└── 技术可行性/路线对比?
    ├── YES → 必须: Consensus + 对应学科数据库
    │         推荐: PubMed（生物医学相关）
    │
    └── NO → 默认: WebSearch + Consensus
```

**重要**：MCP工具是**推荐非必须**。当MCP不可用时，WebSearch作为通用回退。

---

## 持久化

分析完成后，如果用户要求可以：
1. 将报告输出到当前工作目录的 `.shoulders-of-giants/outputs/` 下
2. 命名格式: `<YYYY-MM-DD>-<topic-slug>.md`

---

## 注意事项

- 始终标注每条证据的水印等级，读者应能一目了然地判断可信度
- 对抗验证的发现必须被整合到最终结论中，不能"先反驳再用原结论"
- 信息缺口和数据源限制必须在报告中明确声明
- 优先使用数据源提供的DOI/URL链接，保证可追溯性
- 当使用中文关键词检索时，注意中英术语的对应关系
