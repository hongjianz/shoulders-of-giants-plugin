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
  检查是否包含已知陷阱词的错误翻译
  若发现 → 建议用户修正关键词后重试

修正建议:
  "AI"[All Fields] → "artificial intelligence"[TIAB]
  "ML"[All Fields] → "machine learning"[TIAB]
  "POCT"[All Fields] → "point-of-care testing"[TIAB]
```

**0结果处理**:
```
if total_count == 0:
  if MeSH翻译异常:
    提示用户修正后重试
  else:
    自动执行:
      1. 去掉最具体的限定词
      2. 拆分成更宽泛的子查询
      3. 报告结果
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

### 高相关结果摘要

[列出高相关发现，每条约2-3行]
```
