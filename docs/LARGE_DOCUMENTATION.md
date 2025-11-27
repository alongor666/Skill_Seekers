# 大型文档站点处理（1万+ 页）

使用 Skill Seeker 抓取与管理大型文档站点的完整指南。

---

## 目录

- [何时需要拆分文档](#何时需要拆分文档)
- [拆分策略](#拆分策略)
- [快速开始](#快速开始)
- [详细工作流](#详细工作流)
- [最佳实践](#最佳实践)
- [示例](#示例)
- [故障排除](#故障排除)

---

## 何时需要拆分文档

### 规模建议

| Documentation Size | Recommendation | Strategy |
|-------------------|----------------|----------|
| < 5,000 pages | **One skill** | No splitting needed |
| 5,000 - 10,000 pages | **Consider splitting** | Category-based |
| 10,000 - 30,000 pages | **Recommended** | Router + Categories |
| 30,000+ pages | **Strongly recommended** | Router + Categories |

### 为什么拆分大型文档？

**优势：**
- ✅ Faster scraping (parallel execution)
- ✅ More focused skills (better Claude performance)
- ✅ Easier maintenance (update one topic at a time)
- ✅ Better user experience (precise answers)
- ✅ Avoids context window limits

**权衡：**
- ⚠️ Multiple skills to manage
- ⚠️ Initial setup more complex
- ⚠️ Router adds one extra skill

---

## 拆分策略

### 1. **不拆分**（一个大技能）
**适用：** 小至中型文档（< 5000 页）

```bash
# Just use the config as-is
python3 cli/doc_scraper.py --config configs/react.json
```

**优点：** 简单，维护一个技能
**缺点：** 大型文档较慢且可能触碰限制

---

### 2. **按分类拆分**（多个聚焦技能）
**适用：** 5000-15000 页，主题划分清晰

```bash
# Auto-split by categories
python3 cli/split_config.py configs/godot.json --strategy category

# Creates:
# - godot-scripting.json
# - godot-2d.json
# - godot-3d.json
# - godot-physics.json
# - etc.
```

**优点：** 技能聚焦，边界清晰
**缺点：** 用户需了解使用哪个技能

---

### 3. **路由器 + 分类**（智能枢纽）⭐ 推荐
**适用：** 1万+ 页，最佳用户体验

```bash
# Create router + sub-skills
python3 cli/split_config.py configs/godot.json --strategy router

# Creates:
# - godot.json (router/hub)
# - godot-scripting.json
# - godot-2d.json
# - etc.
```

**优点：** 兼顾两端，智能路由，自然的 UX
**缺点：** 设置略复杂

---

### 4. **按规模拆分**
**适用：** 无明确分类的文档

```bash
# Split every 5000 pages
python3 cli/split_config.py configs/bigdocs.json --strategy size --target-pages 5000

# Creates:
# - bigdocs-part1.json
# - bigdocs-part2.json
# - bigdocs-part3.json
# - etc.
```

**优点：** 简单、可预期
**缺点：** 可能拆分相关主题

---

## 快速开始

### 方案一：自动（推荐）

```bash
# 1. Create config
python3 cli/doc_scraper.py --interactive
# Name: godot
# URL: https://docs.godotengine.org
# ... fill in prompts ...

# 2. Estimate pages (discovers it's large)
python3 cli/estimate_pages.py configs/godot.json
# Output: ⚠️  40,000 pages detected - splitting recommended

# 3. Auto-split with router
python3 cli/split_config.py configs/godot.json --strategy router

# 4. Scrape all sub-skills
for config in configs/godot-*.json; do
  python3 cli/doc_scraper.py --config $config &
done
wait

# 5. Generate router
python3 cli/generate_router.py configs/godot-*.json

# 6. Package all
python3 cli/package_multi.py output/godot*/

# 7. Upload all .zip files to Claude
```

---

### 方案二：手动控制

```bash
# 1. Define split in config
nano configs/godot.json

# Add:
{
  "split_strategy": "router",
  "split_config": {
    "target_pages_per_skill": 5000,
    "create_router": true,
    "split_by_categories": ["scripting", "2d", "3d", "physics"]
  }
}

# 2. Split
python3 cli/split_config.py configs/godot.json

# 3. Continue as above...
```

---

## 详细工作流

### 工作流 1：路由器 + 分类（4 万页）

**场景：** Godot 文档（40,000 页）

**Step 1: Estimate**
```bash
python3 cli/estimate_pages.py configs/godot.json

# Output:
# Estimated: 40,000 pages
# Recommended: Split into 8 skills (5K each)
```

**Step 2: Split Configuration**
```bash
python3 cli/split_config.py configs/godot.json --strategy router --target-pages 5000

# Creates:
# configs/godot.json (router)
# configs/godot-scripting.json (5K pages)
# configs/godot-2d.json (8K pages)
# configs/godot-3d.json (10K pages)
# configs/godot-physics.json (6K pages)
# configs/godot-shaders.json (11K pages)
```

**Step 3: Scrape Sub-Skills (Parallel)**
```bash
# Open multiple terminals or use background jobs
python3 cli/doc_scraper.py --config configs/godot-scripting.json &
python3 cli/doc_scraper.py --config configs/godot-2d.json &
python3 cli/doc_scraper.py --config configs/godot-3d.json &
python3 cli/doc_scraper.py --config configs/godot-physics.json &
python3 cli/doc_scraper.py --config configs/godot-shaders.json &

# Wait for all to complete
wait

# Time: 4-8 hours (parallel) vs 20-40 hours (sequential)
```

**Step 4: Generate Router**
```bash
python3 cli/generate_router.py configs/godot-*.json

# Creates:
# output/godot/SKILL.md (router skill)
```

**Step 5: Package All**
```bash
python3 cli/package_multi.py output/godot*/

# Creates:
# output/godot.zip (router)
# output/godot-scripting.zip
# output/godot-2d.zip
# output/godot-3d.zip
# output/godot-physics.zip
# output/godot-shaders.zip
```

**Step 6: Upload to Claude**
Upload all 6 .zip files to Claude. The router will intelligently direct queries to the right sub-skill!

---

### 工作流 2：仅分类拆分（1.5 万页）

**Scenario:** Vue.js documentation (15,000 pages)

**No router needed - just focused skills:**

```bash
# 1. Split
python3 cli/split_config.py configs/vue.json --strategy category

# 2. Scrape each
for config in configs/vue-*.json; do
  python3 cli/doc_scraper.py --config $config
done

# 3. Package
python3 cli/package_multi.py output/vue*/

# 4. Upload all to Claude
```

**结果：** 5 个聚焦的 Vue 技能（组件、响应式、路由等）

---

## 最佳实践

### 1. **合理选择目标规模**

```bash
# Small focused skills (3K-5K pages) - more skills, very focused
python3 cli/split_config.py config.json --target-pages 3000

# Medium skills (5K-8K pages) - balanced (RECOMMENDED)
python3 cli/split_config.py config.json --target-pages 5000

# Larger skills (8K-10K pages) - fewer skills, broader
python3 cli/split_config.py config.json --target-pages 8000
```

### 2. **使用并行抓取**

```bash
# Serial (slow - 40 hours)
for config in configs/godot-*.json; do
  python3 cli/doc_scraper.py --config $config
done

# Parallel (fast - 8 hours) ⭐
for config in configs/godot-*.json; do
  python3 cli/doc_scraper.py --config $config &
done
wait
```

### 3. **全量前先测试**

```bash
# Test with limited pages first
nano configs/godot-2d.json
# Set: "max_pages": 50

python3 cli/doc_scraper.py --config configs/godot-2d.json

# If output looks good, increase to full
```

### 4. **长任务启用断点**

```bash
# Enable checkpoints in config
{
  "checkpoint": {
    "enabled": true,
    "interval": 1000
  }
}

# If scrape fails, resume
python3 cli/doc_scraper.py --config config.json --resume
```

---

## 示例

### 示例 1：AWS 文档（假设 5 万页）

```bash
# 1. Split by AWS services
python3 cli/split_config.py configs/aws.json --strategy router --target-pages 5000

# Creates ~10 skills:
# - aws (router)
# - aws-compute (EC2, Lambda)
# - aws-storage (S3, EBS)
# - aws-database (RDS, DynamoDB)
# - etc.

# 2. Scrape in parallel (overnight)
# 3. Upload all skills to Claude
# 4. User asks "How do I create an S3 bucket?"
# 5. Router activates aws-storage skill
# 6. Focused, accurate answer!
```

### 示例 2：Microsoft Docs（10 万+ 页）

```bash
# Too large even with splitting - use selective categories

# Only scrape key topics
python3 cli/split_config.py configs/microsoft.json --strategy category

# Edit configs to include only:
# - microsoft-azure (Azure docs only)
# - microsoft-dotnet (.NET docs only)
# - microsoft-typescript (TS docs only)

# Skip less relevant sections
```

---

## 故障排除

### 问题：“拆分后技能过多”

**Solution:** Increase target size or combine categories

```bash
# Instead of 5K per skill, use 8K
python3 cli/split_config.py config.json --target-pages 8000

# Or manually combine categories in config
```

### 问题：“路由器未正确路由”

**Solution:** Check routing keywords in router SKILL.md

```bash
# Review router
cat output/godot/SKILL.md

# Update keywords if needed
nano output/godot/SKILL.md
```

### 问题：“并行抓取失败”

**Solution:** Reduce parallelism or check rate limits

```bash
# Scrape 2-3 at a time instead of all
python3 cli/doc_scraper.py --config config1.json &
python3 cli/doc_scraper.py --config config2.json &
wait

python3 cli/doc_scraper.py --config config3.json &
python3 cli/doc_scraper.py --config config4.json &
wait
```

---

## 总结

**针对 4 万+ 页文档：**

1. ✅ **Estimate first**: `python3 cli/estimate_pages.py config.json`
2. ✅ **Split with router**: `python3 cli/split_config.py config.json --strategy router`
3. ✅ **Scrape in parallel**: Multiple terminals or background jobs
4. ✅ **Generate router**: `python3 cli/generate_router.py configs/*-*.json`
5. ✅ **Package all**: `python3 cli/package_multi.py output/*/`
6. ✅ **Upload to Claude**: All .zip files

**Result:** Intelligent, fast, focused skills that work seamlessly together!

---

**更多信息：**
- [Main README](../README.md)
- [MCP Setup Guide](MCP_SETUP.md)
- [Enhancement Guide](ENHANCEMENT.md)
