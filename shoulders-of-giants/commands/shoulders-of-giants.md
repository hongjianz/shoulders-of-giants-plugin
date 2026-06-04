---
name: shoulders-of-giants
description: 系统性调研命令——启动完整的6阶段调研流程。基于多源并行采集、证据分层、对抗验证方法学，输出带可信度评级的综合报告。
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
---

# Shoulders of Giants / 系统性调研

Use this command when the user explicitly invokes it. For the full skill instructions (including auto-trigger behavior), see `${CLAUDE_PLUGIN_ROOT}/skills/shoulders-of-giants/SKILL.md`.

## Usage

```
/shoulders-of-giants <research-question>               # 标准模式（6阶段完整流程）
/shoulders-of-giants --quick <research-question>        # 快速模式（跳过对抗验证，保留报告输出）
/shoulders-of-giants --deep <research-question>         # 深度模式（追加时间序列分析）
```

## Examples

```
/shoulders-of-giants AI酶设计对分子POCT行业的影响
/shoulders-of-giants --quick CRISPR诊断商业化的最新进展
/shoulders-of-giants --deep 固态电池电解质技术路线对比
```

## Mode Comparison

| Mode | Phases | Anticipated Turns | Best For |
|------|--------|-------------------|----------|
| Standard | 6 phases | 4-6 turns | Most research questions |
| Quick | 5 phases (skip 5) | 2-3 turns | Rapid overview, familiar topic |
| Deep | 6 + timeline | 5-8 turns | Strategic decisions, investment research |

## Related Commands

- `industry-analysis` — 产业解读与预测（配合使用：shoulders-of-giants 负责采集验证，industry-analysis 负责产业解读）
