#!/bin/bash
# shoulders-of-giants 插件完整性校验
# 在每次会话启动时自动运行

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(dirname "$0")/../..}"

references=(
  "00-workflow-overview.md"
  "01-problem-classification.md"
  "02-search-plan.md"
  "03-data-collection.md"
  "04-evidence-labeling.md"
  "05-adversarial-verification.md"
  "06-synthesis-report.md"
)

ref_dir="${PLUGIN_ROOT}/skills/shoulders-of-giants/references"
missing=0

echo "🔍 shoulders-of-giants 完整性校验..."

for ref in "${references[@]}"; do
  if [ ! -f "${ref_dir}/${ref}" ]; then
    echo "  ❌ MISSING: references/${ref}"
    missing=$((missing+1))
  fi
done

if [ -d "${ref_dir}" ]; then
  found=$(find "${ref_dir}" -maxdepth 1 -name "*.md" | wc -l)
  echo "  📄 参考文件: ${found} 个"
fi

if [ $missing -eq 0 ]; then
  echo "✅ shoulders-of-giants 所有参考文件就绪"
else
  echo "⚠️  ${missing} 个参考文件缺失，部分功能可能受限"
fi

# 检查MCP工具可用性
echo ""
echo "📡 MCP工具状态（运行时检查）:"
echo "  PubMed / Consensus / bioRxiv 可用时将增强检索质量"
echo "  WebSearch 作为通用回退方案"
