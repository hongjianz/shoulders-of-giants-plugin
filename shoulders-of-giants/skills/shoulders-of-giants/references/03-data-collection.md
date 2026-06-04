# 03: 多源数据采集

## 并行采集

对所有选定的数据源同时发起检索。每个源的调用策略如下：

### PubMed

**入口**: `mcp__plugin_bio-research_pubmed__search_articles`

| 参数 | 建议 |
|------|------|
| query | 使用 [TIAB] 限域避免MeSH过度翻译 |
| max_results | 15-20（太多增加噪声） |
| sort | relevance（默认） |
| date range | 按问题需要设定 |

**MeSH翻译陷阱词检测**:
```
已知陷阱词:
  "AI" → 会被翻译为 "antagonists and inhibitors"[MeSH]
  "ML" → 可能被忽略
  "POCT" → 可能不被识别

检测方法:
  从返回结果提取 query_translation 字段
  执行自动检查逻辑（见下方伪代码）
  若发现 → 建议用户修正关键词后重试

修正建议:
  "AI"[All Fields] → "artificial intelligence"[TIAB]
  "ML"[All Fields] → "machine learning"[TIAB]
  "POCT"[All Fields] → "point-of-care testing"[TIAB]
```

**MeSH翻译检测伪代码**:

```python
# 伪代码逻辑 — 在每次PubMed检索后自动执行
known_traps = {
    "AI": ["antagonists and inhibitors", "artificial intelligence"],
    "ML": ["machine learning"],
    "POCT": ["point-of-care testing"],
}

def check_query_translation(original_query, translated_query):
    warnings = []
    for term, expected in known_traps.items():
        if term in original_query:
            if not any(e in translated_query for e in expected):
                warnings.append(f"⚠  '{term}' 可能被MeSH错误翻译: {translated_query}")
    return warnings
```

**MeSH翻译异常提示模板**:

当检测到可能的翻译问题时，向用户展示：

```
┌───────── PubMed MeSH 翻译校验 ─────────────────┐
│                                                  │
│  原始查询: "AI enzyme design diagnostics"         │
│  MeSH翻译: (antagonists and inhibitors[...])      │
│            AND (enzymes[...]) AND (...)           │
│                                                  │
│  ⚠ 发现问题: "AI" 被翻译为                       │
│     "antagonists and inhibitors"                  │
│                                                  │
│  建议修正:                                        │
│  使用 "artificial intelligence"[TIAB]             │
│  替代 "AI"[All Fields]                           │
│                                                  │
│  是否重新检索？ [是/否]                           │
└──────────────────────────────────────────────────┘
```

**0结果处理**:
```
0结果自动重路由流程:
─────────────────────────────────────────────

当任意数据源返回0条结果时，执行以下重路由策略:

[PubMed 0结果]
  第1尝试: 检查MeSH翻译异常 → 若异常则修正后重试
    异常判断逻辑: 从 query_translation 提取翻译结果, 与 known_traps 对比
    若发现陷阱词: 建议使用 [TIAB] 替代 [All Fields]
  第2尝试: 去掉最具体的限定词，保留核心概念
+ 第3尝试: 拆分成更宽泛的子查询，分别检索
  第4尝试: 切换到 WebSearch site:pubmed.ncbi.nlm.nih.gov
  若全部失败 → 标记"PubMed不可用" + 记录信息缺口

[Consensus 0结果]
  第1尝试: 简化查询词（去掉行业术语，保留核心概念）
  第2尝试: 改用更宽泛的上位词
  第3尝试: 切换到 WebSearch site:scholar.google.com
  若全部失败 → 标记"Consensus不可用" + 记录信息缺口

[bioRxiv 0结果]
  第1尝试: 放宽分类范围（使用上层分类）
  第2尝试: 扩展时间窗口（date_from提前6个月）
  第3尝试: 切换到 WebSearch site:biorxiv.org
  若全部失败 → 标记"bioRxiv不可用" + 记录信息缺口

[ClinicalTrials.gov 0结果]
  第1尝试: 放宽条件/去掉干预措施限定
  第2尝试: 改用同义术语搜索（如"cancer"→"tumor"→"neoplasm"）
  第3尝试: 切换到 WebSearch site:clinicaltrials.gov
  若全部失败 → 标记"ClinicalTrials不可用" + 记录信息缺口

[ChEMBL 0结果]
  第1尝试: 扩大相似度阈值（如90%→80%）
  第2尝试: 改用通用名检索替代商品名（或反之）
  第3尝试: 切换到 WebSearch（drug + target + mechanism）
  若全部失败 → 标记"ChEMBL不可用" + 记录信息缺口

[WebSearch 0结果]（极少发生）
  第1尝试: 去掉site限定或地域限定
  第2尝试: 使用同义概念重写查询
  第3尝试: 拆分为简短子查询分别执行
  若全部失败 → 确认网络连接 + 标记信息缺口

[全局0结果]（所有数据源均返回0）
  1. 执行语言通道切换 → 中文检索（如当前是英文）
  2. 使用更宽泛的概念重写整个检索策略
  3. 报告"当前关键词未能检索到结果，建议重新设计检索策略"
```

### Consensus

**入口**: `mcp__plugin_bio-research_consensus__search`

| 参数 | 建议 |
|------|------|
| query | 自然语言即可，不需要MeSH规避 |
| medical_mode | 生物医学类问题设为 true |
| 过滤条件 | 仅当用户明确指定时才使用（研究类型/年份/Q值） |

**注意**: Consensus 免费账户每次搜索仅返回3条结果。

### bioRxiv

**入口**: `mcp__plugin_bio-research_biorxiv__search_preprints`

| 参数 | 建议 |
|------|------|
| category | 使用具体分类（避免 broad 分类造成噪声） |
| recent_days | 30-90天（最新预印本） |
| limit | 10-20 |

**注意**: bioRxiv 不支持关键词搜索，只能按分类+时间扫。
对于精确主题，可通过 WebSearch 替代搜索 bioRxiv。

### WebSearch

**入口**: WebSearch 工具

适用于：产业资讯、公司融资、产品发布、专利信息、中文内容。

**语言通道处理**:
```
若启用了中文通道:
  同时搜索:
    WebSearch(query="英文关键词", domain=default)
    WebSearch(query="中文关键词", domain=default)
```

### 专利检索（v1.0新增）

**入口**: WebSearch（专利数据库无专用MCP工具时用WebSearch模拟）

当问题涉及专利/IP布局、技术路线绕行、FTO（自由实施）分析时启用。

#### 专利数据库定向检索语法

```markdown
# Google Patents（通用覆盖好）
WebSearch(query="<技术关键词> patent <公司/发明人>")
WebSearch(query="<关键词> site:patents.google.com")

# 欧洲专利局 Espacenet
WebSearch(query="<关键词> site:worldwide.espacenet.com")

# 中国专利 CNIPA（中文通道启用时追加）
WebSearch(query="<中文关键词> 专利")
WebSearch(query="<中文关键词> site:patents.google.com AND 中国")
WebSearch(query="<关键词> site:cnipa.gov.cn")
WebSearch(query="<关键词> site:patents.google.com AND country:CN")

# 美国专利商标局 USPTO
WebSearch(query="<关键词> site:uspto.gov")
WebSearch(query="<关键词> site:patft.uspto.gov")

# WIPO PCT 国际专利
WebSearch(query="<关键词> site:patentscope.wipo.int")
```

#### 专利信息提取模板

对每个找到的相关专利，记录以下结构：

```
专利信息卡:
──────────────────────────────────────
标题: [专利标题]
专利号: [公开号，如 CNXXXXXXA / USXXXXXXXXB2]
申请人: [公司/机构]
发明人: [姓名]
申请日: YYYY-MM-DD
公开日: YYYY-MM-DD
关键技术点: [2-3句摘要]
战略意义: [技术路线布局/绕行/壁垒]
关联水印: 🏢（专利公开信息，非评议）
关联发现: [连接到调研中的其他发现]
──────────────────────────────────────
```

#### 专利检索触发条件

```
自动检索条件:
  □ 问题中包含 "patent" / "IP" / "知识产权" / "专利" / "绕行"
  □ 问题类型为 竞争格局分析
  □ 用户明确要求分析技术壁垒
  □ 发现涉及未公开/未发表的技术（此时专利是重要验证源）

推荐检索模式:
  ┌─ 宽泛检索: <领域> + patent （发现布局全貌）
  ├─ 精确检索: <公司> + <技术> + patent （跟踪特定玩家）
  └─ 地域检索: <技术> + patent + country:CN （分析区域布局）
```

#### 专利信息局限性声明

```
重要提示:
  - 专利公开 ≠ 技术有效 (专利可能未被实施)
  - 专利申请 ≠ 授权 (大量申请被驳回)
  - 专利信息通常滞后实际研发12-18个月
  - 中国专利的英文翻译质量参差不齐，中文检索更可靠
  - 本插件通过公开渠道检索，不替代专业专利分析工具
```

## 搜索结果汇总

采集完成后，按以下格式汇总：

```markdown
## 检索结果统计

| 数据源 | 命中 | 高相关 | 数据源状态 |
|--------|------|--------|-----------|
| PubMed | N | N | [可用/受限/不可用] |
| Consensus | N | N | [可用/受限/不可用] |
| bioRxiv | N | N | [可用/受限/不可用] |
| Web | N | N | [可用] |
| 专利 | N | N | [启用/未启用] |

### 高相关结果摘要

[列出高相关发现，每条约2-3行]
```
