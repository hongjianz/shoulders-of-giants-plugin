# 09: 故障排除与恢复流程

## 0结果处理速查表

当任意数据源返回0条结果时，按以下策略逐级降级：

| 数据源 | 第1尝试 | 第2尝试 | 第3尝试 | 第4尝试 |
|--------|---------|---------|---------|---------|
| **PubMed** | 检查MeSH翻译异常，修正后重试 | 去掉最具体限定词，保留核心概念 | 拆分成更宽泛的子查询 | 切换到 WebSearch site:pubmed.ncbi.nlm.nih.gov |
| **Consensus** | 简化查询词，去掉行业术语 | 改用更宽泛的上位词 | 切换到 WebSearch site:scholar.google.com | 标记不可用 |
| **bioRxiv** | 放宽分类范围（上层分类） | 扩展时间窗口（提前6个月） | 切换到 WebSearch site:biorxiv.org | 标记不可用 |
| **ClinicalTrials** | 放宽条件/去掉干预措施限定 | 改用同义术语搜索 | 切换到 WebSearch site:clinicaltrials.gov | 标记不可用 |
| **ChEMBL** | 扩大相似度阈值（90%→80%） | 改用通用名/商品名互换 | 切换到 WebSearch（drug+target+mechanism） | 标记不可用 |
| **WebSearch** | 去掉site限定或地域限定 | 使用同义概念重写查询 | 拆分为简短子查询分别执行 | 确认网络连接 |

### 全局0结果应对

如果所有数据源均返回0条结果：
1. 执行语言通道切换 → 用另一种语言重试
2. 使用更宽泛的概念重写整个检索策略
3. 报告"当前关键词未能检索到结果，建议重新设计检索策略"

## MCP工具不可用降级

```
PubMed不可用     → Consensus（优先）+ WebSearch site:pubmed.ncbi.nlm.nih.gov
Consensus不可用  → WebSearch + site:scholar.google.com
bioRxiv不可用   → WebSearch site:biorxiv.org
ClinicalTrials  → WebSearch site:clinicaltrials.gov
ChEMBL不可用    → WebSearch（drug target + 机制关键词）
```

降级原则：
1. 优先使用同类替代源
2. 其次使用 WebSearch + site 限定模拟
3. 最后标注为该数据源"不可用"并在报告中声明

## MeSH翻译异常

### 已知陷阱词

| 用户输入 | MeSH翻译陷阱 | 正确用法 |
|---------|-------------|---------|
| `AI` | "antagonists and inhibitors"[MeSH] | "artificial intelligence"[TIAB] |
| `ML` | 可能被忽略 | "machine learning"[TIAB] |
| `POCT` | 可能不被识别 | "point-of-care testing"[TIAB] |
| `WT` | 可能被理解为"wild type"或"weight" | 使用全称 |

### 检测与处理流程

每次 PubMed 检索后，从 `query_translation` 字段提取翻译结果，与已知陷阱词对比：

1. **发现陷阱词** → 建议用户使用 [TIAB] 替代 [All Fields] 后重试
2. **0结果 + MeSH异常** → 修正后重试；仍为0 → 标记"PubMed不可用"
3. **大量结果但不相关** → 检查MeSH翻译是否引入了意外的AND/OR组合

## 常见问题FAST（快速排查）

| 现象 | 可能原因 | 解决方案 |
|------|---------|---------|
| PubMed返回0结果 | MeSH翻译陷阱 | 检查 query_translation, 使用 [TIAB] |
| Consensus只返回3条 | 免费账户限制 | 使用 WebSearch 补充或切换到 site:scholar.google.com |
| 中文检索无结果 | 关键词对译不准确 | 检查中英术语对应关系 |
| 专利检索无结果 | 数据源不支持 | 尝试不同专利数据库(Google Patents/Espacenet/CNIPA) |
| 所有数据源均返回0 | 关键词过于具体或偏门 | 执行全局0结果应对流程 |
| bioRxiv结果不相关 | 不支持关键词搜索 | 改用 WebSearch site:biorxiv.org |

## 会话中断恢复

如果对话超过上下文限制或意外中断：

1. **已产出内容**：最终报告应已写入 `.shoulders-of-giants/outputs/`（如果用户要求持久化）
2. **未完成的调研**：记录当前进度到 `.shoulders-of-giants/checkpoint.md`
3. **恢复方式**：重新开始调研时，注明"继续上次调研：[主题]"，快速执行阶段1-2后从断点继续
