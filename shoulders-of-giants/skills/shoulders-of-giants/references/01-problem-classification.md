# 01: 问题分类与语言通道评估

## 问题类型判断规则

### 自动分类逻辑

```
输入问题 → 提取关键词 → 匹配以下类别特征:
─────────────────────────────────────────────────

学术文献调研（PubMed + Consensus 优先）
  特征词: mechanism / 机制 / pathway / 信号通路
          clinical trial / 临床试验 / efficacy
          review / 综述 / meta-analysis
          method / 方法 / protocol

产业趋势评估（Consensus + Web 优先）
  特征词: impact / 影响 / market / 市场
          industry / 行业 / commercialization
          trend / 趋势 / landscape / 格局
          funding / 融资 / IPO / investment

技术可行性评估（Consensus + PubMed 优先）
  特征词: feasibility / 可行性 / technology roadmap
          comparison / 对比 / 路线
          capability / 能力 / limitation / 局限
          de novo / 从头 / engineering

竞争格局分析（Web + ClinicalTrials 优先）
  特征词: company / 公司 / startup / 创业
          competitive / 竞争 / landscape
          patent / 专利 / IP
          market share / 市场份额 / player
```

### 多类别处理

当问题跨越多个类别时：
1. 列出所有匹配类别及其权重
2. 使用权重最高的作为主类别
3. 推荐覆盖次高类别的数据源

## 语言通道评估

### 触发条件

当问题或预期答案涉及以下内容时，自动加入对应语言通道：

```
中文通道触发词:
  - 地域: 中国 / 上海 / 北京 / 国内 / 台湾 / 香港
  - 公司: 天鹜 / 分子之心 / 百奥几何 / 华大 / 之江
  - 人名（拼音）: 洪亮 / 许锦波 / 张 / 王 / 李
  - 机构: 上海交大 / 浙大 / 中科院 / 清华大学
  - 概念: 国产替代 / 自主可控 / 突破封锁 / 卡脖子
  - 数据源: 知网 / CNKI / 万方

日文/韩文通道:
  - 暂未实现。可通过 WebSearch 语言参数处理

其他语言:
  - 通过 WebSearch + region 参数处理
```

### 关键词对译表

对每个语言通道，需要生成对应的关键词对译：

```
英文关键词: AI enzyme design point-of-care diagnostics
中文关键词: AI酶设计 即时诊断 POCT 分子检测
```

### 交互模板

```markdown
## 🌐 语言覆盖评估

检测到问题涉及中国团队/技术，自动加入中文通道。

| 语言 | 状态 | 说明 |
|------|------|------|
| English | ✅ 主通道 | 默认 |
| 中文 | ✅ 次通道 | 匹配: [触发的关键词列表] |

中文关键词建议:
  [自动生成的对译]

请确认是否需要调整中文关键词？
```

## 用户确认模板

```markdown
## 阶段1 确认: 问题分类

我的判断:
  ┌─ 主类型: [类型名]
  │
  ├─ 子维度: [维度1, 维度2]
  │
  └─ 语言: [英文 / 英文+中文]

判断依据: [简要说明推理]
  
请确认分类是否准确？需要调整或补充吗？
```
