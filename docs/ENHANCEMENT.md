# SKILL.md 的 AI 增强（中文唯一版本）

提供两种脚本以显著提升 SKILL.md 的质量：
1. `enhance_skill_local.py` — 使用 Claude Code Max（无需 API Key，推荐）
2. `enhance_skill.py` — 使用 Anthropic API（约 $0.15-$0.30/技能）

两者都会分析参考文档并抽取最佳示例与指导。

## 为什么需要增强？

问题：自动生成的 SKILL.md 往往过于通用：
- Quick Reference 为空
- 缺少实用代码示例
- 触发条件过于泛化
- 关键特性没有高亮

解决：让 Claude 阅读你的参考文档并生成更好的 SKILL.md，包含：
- ✅ 文档中提炼的最佳代码示例
- ✅ 可落地的快速参考与真实模式
- ✅ 领域特定指导
- ✅ 清晰导航提示
- ✅ 关键概念解释

## 快速开始（本地，无需 API Key）

适用于 Claude Code Max 用户：

```bash
# Option 1: Standalone enhancement
python3 cli/enhance_skill_local.py output/steam-inventory/

# Option 2: Integrated with scraper
python3 cli/doc_scraper.py --config configs/steam-inventory.json --enhance-local
```

过程：
1. 打开新终端窗口
2. 以增强提示运行 Claude Code
3. Claude 分析参考文件（约 15-20K 字符）
4. 生成增强版 SKILL.md（30-60 秒）
5. 完成后终端自动关闭

要求：
- Claude Code Max 方案
- macOS 自动启动（其他系统可手动运行）

## API 增强（备选）

**If you prefer API-based approach:**

### 安装

```bash
pip3 install anthropic
```

### 配置 API Key

```bash
# Option 1: Environment variable (recommended)
export ANTHROPIC_API_KEY=sk-ant-...

# Option 2: Pass directly with --api-key
python3 cli/enhance_skill.py output/react/ --api-key sk-ant-...
```

### 用法

```bash
# Standalone enhancement
python3 cli/enhance_skill.py output/steam-inventory/

# Integrated with scraper
python3 cli/doc_scraper.py --config configs/steam-inventory.json --enhance

# Dry run (see what would be done)
python3 cli/enhance_skill.py output/react/ --dry-run
```

## 行为说明

1. **Reads reference files** (api_reference.md, webapi.md, etc.)
2. **Sends to Claude** with instructions to:
   - Extract 5-10 best code examples
   - Create practical quick reference
   - Write domain-specific "When to Use" triggers
   - Add helpful navigation guidance
3. **Backs up original** SKILL.md to SKILL.md.backup
4. **Saves enhanced version** as new SKILL.md

## 增强前后对比示例

### Before (Auto-Generated)
```markdown
## Quick Reference

### Common Patterns

*Quick reference patterns will be added as you use the skill.*
```

### After (AI-Enhanced)
```markdown
## Quick Reference

### Common API Patterns

**Granting promotional items:**
```cpp
void CInventory::GrantPromoItems()
{
    SteamItemDef_t newItems[2];
    newItems[0] = 110;
    newItems[1] = 111;
    SteamInventory()->AddPromoItems( &s_GenerateRequestResult, newItems, 2 );
}
```

**Getting all items in player inventory:**
```cpp
SteamInventoryResult_t resultHandle;
bool success = SteamInventory()->GetAllItems( &resultHandle );
```
[... 8 more practical examples ...]
```

## 成本预估

- **Input**: ~50,000-100,000 tokens (reference docs)
- **Output**: ~4,000 tokens (enhanced SKILL.md)
- **Model**: claude-sonnet-4-20250514
- **Estimated cost**: $0.15-$0.30 per skill

## 故障排除

### "No API key provided"
```bash
export ANTHROPIC_API_KEY=sk-ant-...
# or
python3 cli/enhance_skill.py output/react/ --api-key sk-ant-...
```

### "No reference files found"
Make sure you've run the scraper first:
```bash
python3 cli/doc_scraper.py --config configs/react.json
```

### "anthropic package not installed"
```bash
pip3 install anthropic
```

### Don't like the result?
```bash
# Restore original
mv output/steam-inventory/SKILL.md.backup output/steam-inventory/SKILL.md

# Try again (it may generate different content)
python3 cli/enhance_skill.py output/steam-inventory/
```

## 使用建议

1. **Run after scraping completes** - Enhancement works best with complete reference docs
2. **Review the output** - AI is good but not perfect, check the generated SKILL.md
3. **Keep the backup** - Original is saved as SKILL.md.backup
4. **Re-run if needed** - Each run may produce slightly different results
5. **Works offline after first run** - Reference files are local

## 真实案例结果

**Test Case: steam-economy skill**
- **Before:** 75 lines, generic template, empty Quick Reference
- **After:** 570 lines, 10 practical API examples, key concepts explained
- **Time:** 60 seconds
- **Quality Rating:** 9/10

The LOCAL enhancement successfully:
- Extracted best HTTP/JSON examples from 24 pages of documentation
- Explained domain concepts (Asset Classes, Context IDs, Transaction Lifecycle)
- Created navigation guidance for beginners through advanced users
- Added best practices for security, economy design, and API integration

## 限制

**LOCAL Enhancement (`enhance_skill_local.py`):**
- Requires Claude Code Max plan
- macOS auto-launch only (manual on other OS)
- Opens new terminal window
- Takes ~60 seconds

**API Enhancement (`enhance_skill.py`):**
- Requires Anthropic API key (paid)
- Cost: ~$0.15-$0.30 per skill
- Limited to ~100K tokens of reference input

**Both:**
- May occasionally miss the best examples
- Can't understand context beyond the reference docs
- Doesn't modify reference files (only SKILL.md)

## 增强方案对比

| Aspect | Manual Edit | LOCAL Enhancement | API Enhancement |
|--------|-------------|-------------------|-----------------|
| Time | 15-30 minutes | 30-60 seconds | 30-60 seconds |
| Code examples | You pick | AI picks best | AI picks best |
| Quick reference | Write yourself | Auto-generated | Auto-generated |
| Domain guidance | Your knowledge | From docs | From docs |
| Consistency | Varies | Consistent | Consistent |
| Cost | Free (your time) | Free (Max plan) | ~$0.20 per skill |
| Setup | None | None | API key needed |
| Quality | High (if expert) | 9/10 | 9/10 |
| **Recommended?** | For experts only | ✅ **Yes** | If no Max plan |

## 何时使用

**Use enhancement when:**
- You want high-quality SKILL.md quickly
- Working with large documentation (50+ pages)
- Creating skills for unfamiliar frameworks
- Need practical code examples extracted
- Want consistent quality across multiple skills

**Skip enhancement when:**
- Budget constrained (use manual editing)
- Very small documentation (<10 pages)
- You know the framework intimately
- Documentation has no code examples

## 进阶：定制增强提示

To customize how Claude enhances the SKILL.md, edit `enhance_skill.py` and modify the `_build_enhancement_prompt()` method around line 130.

Example customization:
```python
prompt += """
ADDITIONAL REQUIREMENTS:
- Focus on security best practices
- Include performance tips
- Add troubleshooting section
"""
```

## 参考

- [README.md](../README.md) - Main documentation
- [CLAUDE.md](CLAUDE.md) - Architecture guide
- [doc_scraper.py](../doc_scraper.py) - Main scraping tool
## 中文快速摘要

### 本地增强
```bash
python3 cli/enhance_skill_local.py output/<name>/
```
行为：打开新终端运行 Claude Code；分析 `references/*`；备份 `SKILL.md.backup`；输出增强版 `SKILL.md`。

### API 增强
```bash
export ANTHROPIC_API_KEY=sk-ant-...
python3 cli/enhance_skill.py output/<name>/
```
成本：约 $0.01-$0.10/技能（视文档大小）。

### 最佳实践
- 自动备份原始 SKILL.md
- 保持参考文件与导航一致
- 优先使用本地增强；批量或自动化场景下使用 API 增强
