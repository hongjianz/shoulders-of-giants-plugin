# Shoulders of Giants — 系统性调研方法论插件

> 站在巨人的肩膀上，做更可靠的科研调研。

一个基于 Claude Code 的系统性研究方法论 6 阶段工作流插件。通过多源交叉验证、证据水印和对抗验证机制，提升 AI 辅助科研调研的信源覆盖度和结论可靠性。

---

## 安装

### 前置条件

- Claude Code 已安装并可用

### 方式一：通过市场源安装

```bash
claude plugins install shoulders-of-giants-sop
```

### 方式二：从 GitHub 手动注册

将以下内容添加到 `~/.claude/plugins/known_marketplaces.json`：

```json
"shoulders-of-giants-sop": {
  "source": {
    "source": "github",
    "repo": "hongjianz/shoulders-of-giants-plugin"
  }
}
```

然后执行：

```bash
claude plugins install shoulders-of-giants-sop
```

### 方式三：本地安装

```bash
git clone https://github.com/hongjianz/shoulders-of-giants-plugin.git
claude plugins install ./shoulders-of-giants-plugin
```

---

## 快速开始

### 入口方式

| 方式 | 触发 | 适用场景 |
|------|------|---------|
| **命令** | `/shoulders-of-giants <调研主题>` | 即席调研，快速启动 |
| **技能** | 打开 Claude Code 后自动加载 `sog` 技能 | 需要与技能交互时 |

### 使用示例

```
/shoulders-of-giants AI酶设计对分子POCT行业的影响
```

插件会自动执行 6 阶段流程，在每个阶段与你确认后继续推进。

### 模式选择

| 模式 | 说明 |
|------|------|
| `--quick` | 跳过深挖和对抗验证阶段，快速输出报告 |
| `--deep` | 强制执行全部深挖和完整对抗验证 |

---

## 6 阶段工作流

```
问题分类 → 检索方案 → 多源采集 → 证据标注 → 对抗验证 → 综合报告
```

### 阶段 1: 问题分类
自动识别问题类型（技术趋势/产业格局/竞争分析/文献综述），并判断是否需要中英双语通道。

### 阶段 2: 检索方案
为问题定制数据源组合（PubMed / Consensus / bioRxiv / WebSearch / Google Scholar），设计关键词策略。

### 阶段 3: 多源采集
并行检索多个数据源，自动检测 PubMed MeSH 翻译陷阱，处理 0 结果场景，合并中英文结果。

### 阶段 4: 证据标注
使用 7 级证据水印系统为每条发现标注：

| 符号 | 含义 |
|------|------|
| 🔒 | 交叉验证+对抗通过 |
| 📄⭐ | 单篇同行评议 |
| 📄 | 单一非评议源 |
| 🏢 | 产业资讯/公司公告 |
| 🔬 | 预印本 |
| ⚡ | 发现矛盾 |
| ❓ | 单一声称/未独立验证 |

### 阶段 5: 对抗验证
从 3 个角度对核心主张施压：
- **技术局限性** — 什么条件下会失效？
- **乐观偏差** — 独立第三方验证过吗？
- **替代解释** — 同样的现象有其他解释吗？

### 阶段 6: 综合报告
输出规范格式报告，包含执行摘要、核心发现（带水印）、对抗验证结果、信息缺口声明、完整引用列表。

---

## 参考文件

| 文件 | 用途 |
|------|------|
| `00-workflow-overview.md` | 完整流程导航、模式对比、交互密度表 |
| `01-problem-classification.md` | 自动分类规则、中文通道触发条件 |
| `02-search-plan.md` | MCP 路由决策树、关键词设计原则 |
| `03-data-collection.md` | 各数据源调用规范、MeSH 陷阱检测、0 结果处理 |
| `04-evidence-labeling.md` | 7 级水印系统、交叉验证矩阵 |
| `05-adversarial-verification.md` | 3 角度验证模板、置信度调整规则 |
| `06-synthesis-report.md` | 报告模板、水印集成、对抗结果整合 |

### 优化资产

| 文件 | 用途 |
|------|------|
| `01-language-channel.md` | 语言通道检测与翻译表 |
| `02-adversarial-verification-template.md` | 各角度的详细搜索策略 |
| `03-pubmed-mesh-check.md` | MeSH 陷阱词检测与交互修正 |
| `04-evidence-watermark.md` | 完整符号系统与分配矩阵 |

---

## 集成生态

### 关联插件

| 插件 | 仓库 | 互补场景 |
|------|------|---------|
| **industry-analysis** | [hongjianz/industry-analysis-plugin](https://github.com/hongjianz/industry-analysis-plugin) | Shoulders-of-giants 完成证据采集和评级后，industry-analysis 用于深度产业解读和战略建议 |

### 推荐流程

```
shoulders-of-giants (证据层) → industry-analysis (解读层)
    收集原始数据             输出战略分析
    水印标注                 给出行动建议
    置信度评估               SWOT / 时间线
```

---

## 开发

### 项目结构

```
shoulders-of-giants-plugin/
├── .clode-plugin/
│   └── marketplace.json         ← 市场注册文件
└── shoulders-of-giants/         ← 插件本体
    ├── .claude-plugin/
    │   └── plugin.json          ← 插件清单
    ├── commands/
    │   └── shoulders-of-giants.md
    ├── skills/
    │   └── shoulders-of-giants/
    │       ├── SKILL.md         ← 核心技能定义
    │       ├── scripts/
    │       │   └── verify.sh    ← 启动校验脚本
    │       └── references/      ← 7 个阶段 SOP + 优化资产
    └── ...
```

### 本地测试

```bash
# 安装本地副本
claude plugins install ./shoulders-of-giants-plugin/shoulders-of-giants

# 启动 Claude Code 并触发
claude
> /shoulders-of-giants 你的调研主题
```

---

## 版本历史

| 版本 | 日期 | 变更 |
|------|------|------|
| v0.9.0 | 2026-06-04 | 初始版本：6 阶段 SOP、4 项 Tier-1 优化、E2E 测试验证 |
| v1.0 (计划) | — | 时间序列分析、自动分块、0 结果自动重路由、专利检索集成 |

---

## 方法论溯源

本插件的设计理念源自科研工作者在 AI 辅助调研中的以下痛点：

1. **信源透明度** — AI 有多源检索能力但不会告诉你结论的可信度
2. **确认偏误** — AI 倾向于提供支持性证据而非反方证据
3. **覆盖盲区** — 单一数据源（如仅 PubMed）无法覆盖产业动态
4. **评估空心化** — 缺乏对"这个结论有多可靠"的系统判断

通过 **证据水印系统** + **对抗验证** + **渐进式确认** 三支柱来回应这些问题。

---

## 许可证

MIT
