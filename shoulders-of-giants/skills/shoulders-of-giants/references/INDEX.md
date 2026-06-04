# References 索引

## 核心阶段文件（6阶段流程）

| 文件 | 对应阶段 | 说明 |
|------|---------|------|
| `00-workflow-overview.md` | 流程总览 | 完整6阶段流程图示，各阶段交互密度说明 |
| `01-problem-classification.md` | 阶段1 | 问题分类 + 语言通道评估（含中文通道触发规则） |
| `02-search-plan.md` | 阶段2 | 数据源路由决策树，领域增强路由，检索计划模板 |
| `03-data-collection.md` | 阶段3 | 多源并行采集 SOP, MeSH陷阱检测，0结果重路由 |
| `04-evidence-labeling.md` | 阶段4 | 证据水印系统，分层标准，交叉验证矩阵，组合语法 |
| `05-adversarial-verification.md` | 阶段5 | 3角度对抗验证，搜索策略，置信度调整规则 |
| `06-synthesis-report.md` | 阶段6 | 综合报告模板，水印使用规范，对抗结果整合 |

## 辅助文件

| 文件 | 用途 |
|------|------|
| `07-timeline-analysis.md` | 时间序列分析（deep模式，v1.0新增） |
| `08-output-management.md` | 输出持久化与跨插件证据传递规范 |
| `09-troubleshooting.md` | 故障排除与恢复流程（0结果/MCP降级/MeSH异常） |
| `10-integration-industry-analysis.md` | shoulders-of-giants 与 industry-analysis 集成指南 |

## 文件分类图例

- **00-07**: 核心流程阶段（按序号对应6阶段 + 时间序列）
- **08-09**: 辅助规范（输出管理，故障排除）
- **10+**: 跨插件集成

## 使用建议

- **首次使用**: 从 `00-workflow-overview.md` 开始，了解整体流程
- **执行调研**: 按 `01→02→03→04→05→06` 顺序参考
- **遇到问题**: 查阅 `09-troubleshooting.md`
- **跨插件联动**: 查阅 `10-integration-industry-analysis.md`
