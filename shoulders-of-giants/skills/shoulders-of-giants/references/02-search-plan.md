# 02: 检索计划

## 数据源路由决策树

### 自动路由矩阵

根据问题类型 + 领域特征，自动选择最优数据源组合：

```
┌────────────────────────────────────────────────────────────────────────┐
│                        自动路由引擎                                     │
│                                                                        │
│  输入：问题类型 + 领域关键词 + 语言通道                                 │
│  输出：推荐数据源组合（必须/推荐/可选） + 检索策略                       │
└────────────────────────────────────────────────────────────────────────┘
```

### 基础路由表

```
问题类型:
│
├─ 学术文献调研 → 数据源优先级:
│     1. PubMed（同行评议，MeSH精确检索）
│     2. Consensus（引文排名，研究类型过滤）
│     3. bioRxiv（预印本，时效性优先）
│
├─ 产业趋势评估 → 数据源优先级:
│     1. Consensus（综述+引文分析）
│     2. WebSearch（产业新闻+融资信息）
│     3. ClinicalTrials.gov（临床试验管线）
│
├─ 技术可行性评估 → 数据源优先级:
│     1. Consensus（技术论文+综述）
│     2. PubMed（方法学细节）
│     3. bioRxiv（最新进展）
│
├─ 竞争格局分析 → 数据源优先级:
│     1. WebSearch（公司信息+融资）
│     2. ClinicalTrials.gov（管线深度）
│     3. Consensus（学术背景）
│
└─ 混合型 → 按子问题分别路由
```

### 领域增强路由（子问题级别）

当主问题分解为子问题后，对每个子问题根据领域特征进一步优化：

```
子问题领域特征 → 附加/替换数据源:
──────────────────────────────────────

生物医药/制药相关:
  "drug" / "clinical trial" / "protein" / "enzyme" / "antibody"
  ├─ 追加 ChEMBL（靶点/化合物/机制数据）
  ├─ 追加 ClinicalTrials.gov（临床试验管线）
  └─ 追加 bioRxiv（最新预印本）

材料/化学相关:
  "material" / "catalyst" / "polymer" / "nanoparticle"
  ├─ 追加 WebSearch（Google Patents/Espacenet专利检索）
  └─ 考虑 对应学科数据库（如材料基因组）

信息技术/软件相关:
  "algorithm" / "AI" / "model" / "platform"
  ├─ 追加 WebSearch（arXiv检索 + 公司博客）
  └─ 考虑 ArXiv / 开发者文档

专利/IP相关:
  "patent" / "IP" / "绕行" / "自由实施"
  ├─ 追加 WebSearch + Google Patents 定向检索
  └─ 追加 WebSearch + CNIPA (中国专利) 定向检索

产业/商业相关:
  "market" / "funding" / "startup" / "revenue"
  ├─ 追加 WebSearch 多角度检索
  └─ 追加 ClinicalTrials.gov（如涉及医疗产品管线）
```

### 语言通道路由

当语言通道评估触发多语言后，路由规则扩展：

```
├─ 英文通道 → 标准路由
│
├─ 中文通道 → 追加:
│     ├─ WebSearch（中文关键词）
│     ├─ WebSearch（CNKI/万方引用检索，通过site:cnki.net）
│     └─ 专利 → WebSearch（中国专利/CNIPA）
│
└─ 日/韩/其他 → 追加:
      └─ WebSearch（对应语言关键词 + 地域限定）
```

### MCP可用性降级规则

```
MCP工具不可用时的自动降级:
──────────────────────────

PubMed不可用 → Consensus（优先）+ WebSearch site:pubmed.ncbi.nlm.nih.gov
Consensus不可用 → WebSearch + site:scholar.google.com
bioRxiv不可用 → WebSearch site:biorxiv.org
ClinicalTrials.gov不可用 → WebSearch site:clinicaltrials.gov
ChEMBL不可用 → WebSearch（drug target + 机制关键词）

降级原则:
  1. 优先使用同类替代源
  2. 其次使用 WebSearch + site 限定模拟
  3. 最后标注为该数据源"不可用"并在报告中声明
```

## 检索计划模板

```markdown
## 📋 检索计划

### 分解后的问题

| 子问题 | 数据源 | 检索策略 |
|--------|--------|---------|
| [子问题1] | [源1, 源2] | [关键词+过滤] |
| [子问题2] | [源1, 源3] | [关键词+过滤] |

### 语言通道

| 语言 | 需要 | 关键词(对译) |
|------|------|-------------|
| English | ✅ | [英文关键词] |
| 中文 | [是/否] | [中文关键词] |

### 路由说明

| 数据源 | 路由理由 | 可用性 | 优先级 |
|--------|---------|--------|-------|
| PubMed | [为什么选] | ✅/⚠/❌ | 必须/推荐/可选 |
| Consensus | [为什么选] | ✅/⚠/❌ | 必须/推荐/可选 |
| ... | ... | ... | ... |

### PubMed MeSH 翻译预检

原始查询: [query]
MeSH翻译: [translation]
⚠ 告警: [如有陷阱词则显示]

请确认计划？可以添加/修改/删除子问题，或调整数据源组合。
```

## 关键词设计原则

1. **具体 > 宽泛**：先用精确关键词，0结果再放宽
2. **备用术语**：对每个概念准备2-3种表述方式
3. **时间范围**：除非研究历史趋势，优先近3-5年文献
4. **排除词**：对宽泛概念使用 NOT 缩小范围
5. **语言对译**：多语言通道时确保术语对应关系准确
