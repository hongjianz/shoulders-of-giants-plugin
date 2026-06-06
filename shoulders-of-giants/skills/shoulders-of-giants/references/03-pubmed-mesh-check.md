# PubMed MeSH翻译校验规则

> 优化项 #3 — 在PubMed检索结果返回时，自动检查MeSH翻译质量

## 问题

PubMed的MeSH自动翻译引擎会将特定缩写/术语映射到不相关的MeSH术语。
已知的陷阱词：

```
用户输入 "AI"              → MeSH翻译: "antagonists and inhibitors"[MeSH Subheading]
用户输入 "ML"              → 可能被忽略或错误扩展
用户输入 "point of care"  → 通常OK
用户输入 "POCT"           → 通常不被识别
用户输入 "CRISPR"         → 通常OK
用户输入 "WT"             → 可能被理解为"wild type"或"weight"
```

## 校验流程

每次PubMed检索后，从返回结果的 `query_translation` 字段提取MeSH翻译，
执行自动检查：

```python
# 伪代码逻辑
known_traps = {
    "AI": ["antagonists and inhibitors", "artificial intelligence"],
    "ML": ["machine learning"],
    "POCT": ["point-of-care testing"],
    # 持续积累
}

def check_query_translation(original_query, translated_query):
    warnings = []
    for term, expected in known_traps.items():
        if term in original_query:
            if not any(e in translated_query for e in expected):
                warnings.append(f"⚠  '{term}' 可能被MeSH错误翻译")
    return warnings
```

## 交互提示模板

当检测到可能的翻译问题时，向用户展示：

```
┌───────── PubMed MeSH 翻译校验 ─────────────────┐
│                                                 │
│  原始查询: "AI enzyme design diagnostics"        │
│  MeSH翻译: (antagonists and inhibitors[...])     │
│            AND (enzymes[...]) AND (...)          │
│                                                 │
│  ⚠ 发现问题: "AI" 被翻译为                     │
│     "antagonists and inhibitors"                │
│                                                 │
│  建议修正:                                      │
│  使用 "artificial intelligence"[TIAB]           │
│  替代 "AI"[All Fields]                          │
│                                                 │
│  是否重新检索？ [是/否]                          │
└─────────────────────────────────────────────────┘
```

## 异常处理

如果检索返回0条结果且MeSH翻译异常：
1. 建议修正关键词后重试
2. 如果仍为0 → 报告"PubMed检索无结果，已尝试放宽条件"
3. 切换数据源（如Consensus）作为替代

如果检索返回大量结果但大部分不相关：
1. 检查MeSH翻译是否引入了意料之外的AND/OR组合
2. 建议使用 [TIAB] 限域替代 [All Fields]
