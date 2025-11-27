# Active Skills Design - Demand-Driven Documentation Loading

**Date:** 2025-10-24
**Type:** Architecture Design
**Status:** Phase 1 Implemented ✅
**Author:** Edgar + Claude (Brainstorming Session)

---

## Executive Summary

Transform Skill_Seekers from creating **passive documentation dumps** into **active, intelligent skills** that load documentation on-demand. This eliminates context bloat (300k → 5-10k per query) while maintaining full access to complete documentation.

**Key Innovation:** Skills become lightweight routers with heavy tools in `scripts/`, not documentation repositories.

---

## Problem Statement

### Current Architecture: Passive Skills

**What happens today:**
```
Agent: "How do I use Hono middleware?"
  ↓
Skill: *Claude loads 203k llms-txt.md into context*
  ↓
Agent: *answers using loaded docs*
  ↓
Result: Context bloat, slower performance, hits limits
```

**Issues:**
1. **Context Bloat**: 319k llms-full.txt loaded entirely into context
2. **Wasted Resources**: Agent needs 5k but gets 319k
3. **Truncation Loss**: 36% of content lost (319k → 203k) due to size limits
4. **File Extension Bug**: llms.txt files stored as .txt instead of .md
5. **Single Variant**: Only downloads one file (usually llms-full.txt)

### Current File Structure

```
output/hono/
├── SKILL.md ──────────► Documentation dump + instructions
├── references/
│   └── llms-txt.md ───► 203k (36% truncated from 319k original)
├── scripts/ ──────────► EMPTY (placeholder only!)
└── assets/ ───────────► EMPTY (placeholder only!)
```

---

## Proposed Architecture: Active Skills

### Core Concept

**Skills = Routers + Tools**, not documentation dumps.

**New workflow:**
```
Agent: "How do I use Hono middleware?"
  ↓
Skill: *runs scripts/search.py "middleware"*
  ↓
Script: *loads llms-full.md, extracts middleware section, returns 8k*
  ↓
Agent: *answers using ONLY 8k* (CLEAN CONTEXT!)
  ↓
Result: 40x less context, no truncation, full access to docs
```

### Benefits

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| Context per query | 203k | 5-10k | **20-40x reduction** |
| Content loss | 36% truncated | 0% (no truncation) | **Full fidelity** |
| Variants available | 1 | 3 | **User choice** |
| File format | .txt (wrong) | .md (correct) | **Fixed** |
| Agent workflow | Passive read | Active tools | **Autonomous** |

---

## Design Components

### Component 1: Multi-Variant Download

**Change:** Download ALL 3 variants, not just one.

**File naming (FIXED):**
- `https://hono.dev/llms-full.txt` → `llms-full.md` ✅
- `https://hono.dev/llms.txt` → `llms.md` ✅
- `https://hono.dev/llms-small.txt` → `llms-small.md` ✅

**Sizes (Hono example):**
- `llms-full.md` - 319k (complete documentation)
- `llms-small.md` - 176k (curated essentials)
- `llms.md` - 5.4k (quick reference)

**Storage:**
```
output/hono/references/
├── llms-full.md    # 319k - everything (RENAMED from .txt)
├── llms-small.md   # 176k - curated (RENAMED from .txt)
├── llms.md         # 5.4k - quick ref (RENAMED from .txt)
└── catalog.json    # Generated index (NEW)
```

**Implementation in `_try_llms_txt()`:**
```python
def _try_llms_txt(self) -> bool:
    """Download ALL llms.txt variants for active skills"""

    # 1. Detect all available variants
    detector = LlmsTxtDetector(self.base_url)
    variants = detector.detect_all()  # NEW method

    downloaded = {}
    for variant_info in variants:
        url = variant_info['url']       # https://hono.dev/llms-full.txt
        variant = variant_info['variant']  # 'full', 'standard', 'small'

        downloader = LlmsTxtDownloader(url)
        content = downloader.download()

        if content:
            # ✨ FIX: Rename .txt → .md immediately
            clean_name = f"llms-{variant}.md"
            downloaded[variant] = {
                'content': content,
                'filename': clean_name
            }

    # 2. Save ALL variants (not just one)
    for variant, data in downloaded.items():
        path = os.path.join(self.skill_dir, "references", data['filename'])
        with open(path, 'w', encoding='utf-8') as f:
            f.write(data['content'])

    # 3. Generate catalog from smallest variant
    if 'small' in downloaded:
        self._generate_catalog(downloaded['small']['content'])

    return True
```

---

### Component 2: The Catalog System

**Purpose:** Lightweight index of what exists, not the content itself.

**File:** `assets/catalog.json`

**Structure:**
```json
{
  "metadata": {
    "framework": "hono",
    "version": "auto-detected",
    "generated": "2025-10-24T14:30:00Z",
    "total_sections": 93,
    "variants": {
      "quick": "llms-small.md",
      "standard": "llms.md",
      "complete": "llms-full.md"
    }
  },
  "sections": [
    {
      "id": "routing",
      "title": "Routing",
      "h1_marker": "# Routing",
      "topics": ["routes", "path", "params", "wildcard"],
      "size_bytes": 4800,
      "variants": ["quick", "complete"],
      "complexity": "beginner"
    },
    {
      "id": "middleware",
      "title": "Middleware",
      "h1_marker": "# Middleware",
      "topics": ["cors", "auth", "logging", "compression"],
      "size_bytes": 8200,
      "variants": ["quick", "complete"],
      "complexity": "intermediate"
    }
  ],
  "search_index": {
    "cors": ["middleware"],
    "routing": ["routing", "path-parameters"],
    "authentication": ["middleware", "jwt"],
    "context": ["context-handling"],
    "streaming": ["streaming-responses"]
  }
}
```

**Generation (from llms-small.md):**
```python
def _generate_catalog(self, llms_small_content):
    """Generate catalog.json from llms-small.md TOC"""
    catalog = {
        "metadata": {...},
        "sections": [],
        "search_index": {}
    }

    # Split by h1 headers
    sections = re.split(r'\n# ', llms_small_content)

    for section_text in sections[1:]:
        lines = section_text.split('\n')
        title = lines[0].strip()

        # Extract h2 topics
        topics = re.findall(r'^## (.+)$', section_text, re.MULTILINE)
        topics = [t.strip().lower() for t in topics]

        section_info = {
            "id": title.lower().replace(' ', '-'),
            "title": title,
            "h1_marker": f"# {title}",
            "topics": topics + [title.lower()],
            "size_bytes": len(section_text),
            "variants": ["quick", "complete"]
        }

        catalog["sections"].append(section_info)

        # Build search index
        for topic in section_info["topics"]:
            if topic not in catalog["search_index"]:
                catalog["search_index"][topic] = []
            catalog["search_index"][topic].append(section_info["id"])

    # Save to assets/catalog.json
    catalog_path = os.path.join(self.skill_dir, "assets", "catalog.json")
    with open(catalog_path, 'w', encoding='utf-8') as f:
        json.dump(catalog, f, indent=2)
```

---

### Component 3: Active Scripts

**Location:** `scripts/` directory (currently empty)

#### Script 1: `scripts/search.py`

**Purpose:** Search and return only relevant documentation sections.

```python
#!/usr/bin/env python3
"""
ABOUTME: Searches framework documentation and returns relevant sections
ABOUTME: Loads only what's needed - keeps agent context clean
"""

import json
import sys
import re
from pathlib import Path

def search(query, detail="auto"):
    """
    Search documentation and return relevant sections.

    Args:
        query: Search term (e.g., "middleware", "cors", "routing")
        detail: "quick" | "standard" | "complete" | "auto"

    Returns:
        Markdown text of relevant sections only
    """
    # Load catalog
    catalog_path = Path(__file__).parent.parent / "assets" / "catalog.json"
    catalog = json.load(open(catalog_path))

    # 1. Find matching sections using search index
    query_lower = query.lower()
    matching_section_ids = set()

    for keyword, section_ids in catalog["search_index"].items():
        if query_lower in keyword or keyword in query_lower:
            matching_section_ids.update(section_ids)

    # Get section details
    matches = [s for s in catalog["sections"] if s["id"] in matching_section_ids]

    if not matches:
        return f"❌ No sections found for '{query}'. Try: python scripts/list_topics.py"

    # 2. Determine detail level
    if detail == "auto":
        # Use quick for overview, complete for deep dive
        total_size = sum(s["size_bytes"] for s in matches)
        if total_size > 50000:  # > 50k
            variant = "quick"
        else:
            variant = "complete"
    else:
        variant = detail

    variant_file = catalog["metadata"]["variants"].get(variant, "complete")

    # 3. Load documentation file
    doc_path = Path(__file__).parent.parent / "references" / variant_file
    doc_content = open(doc_path, 'r', encoding='utf-8').read()

    # 4. Extract matched sections
    results = []
    for match in matches:
        h1_marker = match["h1_marker"]

        # Find section boundaries
        start = doc_content.find(h1_marker)
        if start == -1:
            continue

        # Find next h1 (or end of file)
        next_h1 = doc_content.find("\n# ", start + len(h1_marker))
        if next_h1 == -1:
            section_text = doc_content[start:]
        else:
            section_text = doc_content[start:next_h1]

        results.append({
            'title': match['title'],
            'size': len(section_text),
            'content': section_text
        })

    # 5. Format output
    output = [f"# Search Results for '{query}' ({len(results)} sections found)\n"]
    output.append(f"**Variant used:** {variant} ({variant_file})")
    output.append(f"**Total size:** {sum(r['size'] for r in results):,} bytes\n")
    output.append("---\n")

    for result in results:
        output.append(result['content'])
        output.append("\n---\n")

    return '\n'.join(output)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python search.py <query> [detail]")
        print("Example: python search.py middleware")
        print("Example: python search.py routing --detail quick")
        sys.exit(1)

    query = sys.argv[1]
    detail = sys.argv[2] if len(sys.argv) > 2 else "auto"

    print(search(query, detail))
```

#### Script 2: `scripts/list_topics.py`

**Purpose:** Show all available documentation sections.

```python
#!/usr/bin/env python3
"""
ABOUTME: Lists all available documentation sections with sizes
ABOUTME: Helps agent discover what documentation exists
"""

import json
from pathlib import Path

def list_topics():
    """List all available documentation sections."""
    catalog_path = Path(__file__).parent.parent / "assets" / "catalog.json"
    catalog = json.load(open(catalog_path))

    print(f"# Available Documentation Topics ({catalog['metadata']['framework']})\n")
    print(f"**Total sections:** {catalog['metadata']['total_sections']}")
    print(f"**Variants:** {', '.join(catalog['metadata']['variants'].keys())}\n")
    print("---\n")

    # Group by complexity if available
    by_complexity = {}
    for section in catalog["sections"]:
        complexity = section.get("complexity", "general")
        if complexity not in by_complexity:
            by_complexity[complexity] = []
        by_complexity[complexity].append(section)

    for complexity in ["beginner", "intermediate", "advanced", "general"]:
        if complexity not in by_complexity:
            continue

        sections = by_complexity[complexity]
        print(f"## {complexity.title()} ({len(sections)} sections)\n")

        for section in sections:
            size_kb = section["size_bytes"] / 1024
            topics_str = ", ".join(section["topics"][:3])
            print(f"- **{section['title']}** ({size_kb:.1f}k)")
            print(f"  Topics: {topics_str}")
            print(f"  Search: `python scripts/search.py {section['id']}`\n")

if __name__ == "__main__":
    list_topics()
```

#### Script 3: `scripts/get_section.py`

**Purpose:** Extract a complete section by exact title.

```python
#!/usr/bin/env python3
"""
ABOUTME: Extracts a complete documentation section by title
ABOUTME: Returns full section from llms-full.md (no truncation)
"""

import json
import sys
from pathlib import Path

def get_section(title, variant="complete"):
    """
    Get a complete section by exact title.

    Args:
        title: Section title (e.g., "Middleware", "Routing")
        variant: Which file to use (quick/standard/complete)

    Returns:
        Complete section content
    """
    catalog_path = Path(__file__).parent.parent / "assets" / "catalog.json"
    catalog = json.load(open(catalog_path))

    # Find section
    section = None
    for s in catalog["sections"]:
        if s["title"].lower() == title.lower():
            section = s
            break

    if not section:
        return f"❌ Section '{title}' not found. Try: python scripts/list_topics.py"

    # Load doc
    variant_file = catalog["metadata"]["variants"].get(variant, "complete")
    doc_path = Path(__file__).parent.parent / "references" / variant_file
    doc_content = open(doc_path, 'r', encoding='utf-8').read()

    # Extract section
    h1_marker = section["h1_marker"]
    start = doc_content.find(h1_marker)

    if start == -1:
        return f"❌ Section '{title}' not found in {variant_file}"

    next_h1 = doc_content.find("\n# ", start + len(h1_marker))
    if next_h1 == -1:
        section_text = doc_content[start:]
    else:
        section_text = doc_content[start:next_h1]

    return section_text

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python get_section.py <title> [variant]")
        print("Example: python get_section.py Middleware")
        print("Example: python get_section.py Routing quick")
        sys.exit(1)

    title = sys.argv[1]
    variant = sys.argv[2] if len(sys.argv) > 2 else "complete"

    print(get_section(title, variant))
```

---

### Component 4: Active SKILL.md Template

**New template for llms.txt-based skills:**

```markdown
---
name: {name}
description: {description}
type: active
---

# {Name} Skill

**⚡ This is an ACTIVE skill** - Uses scripts to load documentation on-demand instead of dumping everything into context.

## 🎯 Strategy: Demand-Driven Documentation

**Traditional approach:**
- Load 300k+ documentation into context
- Agent reads everything to answer one question
- Context bloat, slower performance

**Active approach:**
- Load 5-10k of relevant sections on-demand
- Agent calls scripts to fetch what's needed
- Clean context, faster performance

## 📚 Available Documentation

This skill provides access to {num_sections} documentation sections across 3 detail levels:

- **Quick Reference** (`llms-small.md`): {small_size}k - Curated essentials
- **Standard** (`llms.md`): {standard_size}k - Core concepts
- **Complete** (`llms-full.md`): {full_size}k - Everything

## 🔧 Tools Available

### 1. Search Documentation
Find and load only relevant sections:

```bash
python scripts/search.py "middleware"
python scripts/search.py "routing" --detail quick
```

**Returns:** 5-10k of relevant content (not 300k!)

### 2. List All Topics
See what documentation exists:

```bash
python scripts/list_topics.py
```

**Returns:** Table of contents with section sizes and search hints

### 3. Get Complete Section
Extract a full section by title:

```bash
python scripts/get_section.py "Middleware"
python scripts/get_section.py "Routing" quick
```

**Returns:** Complete section from chosen variant

## 💡 Recommended Workflow

1. **Discover:** `python scripts/list_topics.py` to see what's available
2. **Search:** `python scripts/search.py "your topic"` to find relevant sections
3. **Deep Dive:** Use returned content to answer questions in detail
4. **Iterate:** Search more specific topics as needed

## ⚠️ Important

**DON'T:** Read `references/*.md` files directly into context
**DO:** Use scripts to fetch only what you need

This keeps your context clean and focused!

## 📊 Index

Complete section catalog available in `assets/catalog.json` with search mappings and size information.

## 🔄 Updating

To refresh with latest documentation:
```bash
python3 cli/doc_scraper.py --config configs/{name}.json
```
```

---

## Implementation Plan

### Phase 1: Foundation (Quick Fixes)

**Tasks:**
1. Fix `.txt` → `.md` renaming in downloader
2. Download all 3 variants (not just one)
3. Store all variants in `references/` with correct names
4. Remove content truncation (2500 chars → unlimited)

**Time:** 1-2 hours
**Files:** `cli/doc_scraper.py`, `cli/llms_txt_downloader.py`

### Phase 2: Catalog System

**Tasks:**
1. Implement `_generate_catalog()` method
2. Parse llms-small.md to extract sections
3. Build search index from topics
4. Generate `assets/catalog.json`

**Time:** 2-3 hours
**Files:** `cli/doc_scraper.py`

### Phase 3: Active Scripts

**Tasks:**
1. Create `scripts/search.py`
2. Create `scripts/list_topics.py`
3. Create `scripts/get_section.py`
4. Make scripts executable (`chmod +x`)

**Time:** 2-3 hours
**Files:** New scripts in `scripts/` template directory

### Phase 4: Template Updates

**Tasks:**
1. Create new active SKILL.md template
2. Update `create_enhanced_skill_md()` to use active template for llms.txt skills
3. Update documentation to explain active skills

**Time:** 1 hour
**Files:** `cli/doc_scraper.py`, `README.md`, `CLAUDE.md`

### Phase 5: Testing & Refinement

**Tasks:**
1. Test with Hono skill (has all 3 variants)
2. Test search accuracy
3. Measure context reduction
4. Document examples

**Time:** 2-3 hours

**Total Estimated Time:** 8-12 hours

---

## Migration Path

### Backward Compatibility

**Existing skills:** No changes (passive skills still work)
**New llms.txt skills:** Automatically use active architecture
**User choice:** Can disable via config flag

### Config Option

```json
{
  "name": "hono",
  "llms_txt_url": "https://hono.dev/llms-full.txt",
  "active_skill": true,  // NEW: Enable active architecture (default: true)
  "base_url": "https://hono.dev/docs"
}
```

### Detection Logic

```python
# In _try_llms_txt()
active_mode = self.config.get('active_skill', True)  # Default true

if active_mode:
    # Download all variants, generate catalog, create scripts
    self._build_active_skill(downloaded)
else:
    # Traditional: single file, no scripts
    self._build_passive_skill(downloaded)
```

---

## Benefits Analysis

### Context Efficiency

| Scenario | Passive Skill | Active Skill | Improvement |
|----------|---------------|--------------|-------------|
| Simple query | 203k loaded | 5k loaded | **40x reduction** |
| Multi-topic query | 203k loaded | 15k loaded | **13x reduction** |
| Deep dive | 203k loaded | 30k loaded | **6x reduction** |

### Data Fidelity

| Aspect | Passive | Active |
|--------|---------|--------|
| Content truncation | 36% lost | 0% lost |
| Code truncation | 600 chars max | Unlimited |
| Variants available | 1 | 3 |

### Agent Capabilities

**Passive Skills:**
- ❌ Cannot choose detail level
- ❌ Cannot search efficiently
- ❌ Must read entire context
- ❌ Limited by context window

**Active Skills:**
- ✅ Chooses appropriate detail level
- ✅ Searches catalog efficiently
- ✅ Loads only what's needed
- ✅ Unlimited documentation access

---

## Trade-offs

### Advantages

1. **Massive context reduction** (20-40x less per query)
2. **No content loss** (all 3 variants preserved)
3. **Correct file format** (.md not .txt)
4. **Agent autonomy** (tools to fetch docs)
5. **Scalable** (works with 1MB+ docs)

### Disadvantages

1. **Complexity** (scripts + catalog vs simple files)
2. **Initial overhead** (catalog generation)
3. **Agent learning curve** (must learn to use scripts)
4. **Dependency** (Python required to run scripts)

### Risk Mitigation

**Risk:** Scripts don't work in Claude's sandbox
**Mitigation:** Test thoroughly, provide fallback to passive mode

**Risk:** Catalog generation fails
**Mitigation:** Graceful degradation to single-file mode

**Risk:** Agent doesn't use scripts
**Mitigation:** Clear SKILL.md instructions, examples in quick reference

---

## Success Metrics

### Technical Metrics

- ✅ Context per query < 20k (down from 203k)
- ✅ All 3 variants downloaded and named correctly
- ✅ 0% content truncation
- ✅ Catalog generation < 5 seconds
- ✅ Search script < 1 second response time

### User Experience Metrics

- ✅ Agent successfully uses scripts without prompting
- ✅ Answers are equally or more accurate than passive mode
- ✅ Agent can handle queries about all documentation sections
- ✅ No "context limit exceeded" errors

---

## Future Enhancements

### Phase 6: Smart Caching

Cache frequently accessed sections in SKILL.md quick reference:
```python
# Track access frequency in catalog.json
"sections": [
  {
    "id": "middleware",
    "access_count": 47,  # NEW: Track usage
    "last_accessed": "2025-10-24T14:30:00Z"
  }
]

# Include top 10 most-accessed sections directly in SKILL.md
```

### Phase 7: Semantic Search

Use embeddings for better search:
```python
# Generate embeddings for each section
"sections": [
  {
    "id": "middleware",
    "embedding": [...],  # NEW: Vector embedding
    "topics": ["cors", "auth"]
  }
]

# In search.py: Use cosine similarity for better matches
```

### Phase 8: Progressive Loading

Load increasingly detailed docs:
```python
# First: Load llms.md (5.4k - overview)
# If insufficient: Load llms-small.md section (15k)
# If still insufficient: Load llms-full.md section (30k)
```

---

## Conclusion

Active skills represent a fundamental shift from **documentation repositories** to **documentation routers**. By treating skills as intelligent intermediaries rather than static dumps, we can:

1. **Eliminate context bloat** (40x reduction)
2. **Preserve full fidelity** (0% truncation)
3. **Enable agent autonomy** (tools to fetch docs)
4. **Scale indefinitely** (no size limits)

This design maintains backward compatibility while unlocking new capabilities for modern, LLM-optimized documentation sources like llms.txt.

**Recommendation:** Implement in phases, starting with foundation fixes, then catalog system, then active scripts. Test thoroughly with Hono before making it the default for all llms.txt-based skills.

---

## References

- Original brainstorming session: 2025-10-24
- llms.txt convention: https://llmstxt.org/
- Hono example: https://hono.dev/llms-full.txt
- Skill_Seekers repository: Current project

---

## Appendix: Example Workflows

### Example 1: Agent Searches for "Middleware"

```bash
# Agent runs:
python scripts/search.py "middleware"

# Script returns ~8k of middleware documentation from llms-full.md
# Agent uses that 8k to answer the question
# Total context used: 8k (not 319k!)
```

### Example 2: Agent Explores Documentation

```bash
# 1. Agent lists topics
python scripts/list_topics.py
# Returns: Table of contents (2k)

# 2. Agent picks a topic
python scripts/get_section.py "Routing"
# Returns: Complete Routing section (5k)

# 3. Agent searches related topics
python scripts/search.py "path parameters"
# Returns: Routing + Path section (7k)

# Total context used across 3 queries: 14k (not 3 × 319k = 957k!)
```

### Example 3: Agent Needs Quick Answer

```bash
# Agent uses quick variant for overview
python scripts/search.py "cors" --detail quick

# Returns: Short CORS explanation from llms-small.md (2k)
# If insufficient, agent can follow up with:
python scripts/get_section.py "Middleware"  # Full section from llms-full.md
```

---

**Document Status:** Ready for review and implementation planning.
# 主动技能设计 - 按需加载文档

**日期：** 2025-10-24
**类型：** 架构设计
**状态：** 阶段 1 已实现 ✅
**作者：** Edgar + Claude（头脑风暴）

---

## 执行摘要

将 Skill_Seekers 从**被动文档倾倒**转变为**主动、智能技能**，按需加载文档。这样每次查询上下文从 300k 缩减至 5-10k，同时保持对完整文档的访问。

**关键创新：** 技能变为轻量路由器，重工具在 `scripts/`，而非文档仓库。

---

## 问题陈述

### 当前架构：被动技能

```
Agent: "How do I use Hono middleware?"
  ↓
Skill: *Claude 加载 203k llms-txt.md 到上下文*
  ↓
Agent: *基于已加载文档作答*
  ↓
结果：上下文膨胀、性能下降、出现截断
```

**问题：**
1. **上下文膨胀**：整份 319k llms-full.txt 被加载
2. **资源浪费**：Agent 实际只需 5k，却给了 319k
3. **截断丢失**：因大小限制导致 36% 内容丢失（319k → 203k）
4. **扩展名错误**：llms.txt 文件存为 .txt 而非 .md
5. **单一变体**：仅下载一个文件（通常 llms-full.txt）

### 当前文件结构

```
output/hono/
├── SKILL.md ──────────► 文档倾倒 + 指令
├── references/
│   └── llms-txt.md ───► 203k（从 319k 截断 36%）
├── scripts/ ──────────► 空（仅占位）
└── assets/ ───────────► 空（仅占位）
```

---

## 提议架构：主动技能

### 核心概念

**技能 = 路由器 + 工具**，而非文档仓库。

**新工作流：**
```
Agent: "How do I use Hono middleware?"
  ↓
Skill: *运行 scripts/search.py "middleware"*
  ↓
Script: *加载 llms-full.md，抽取 middleware 章节，返回 8k*
  ↓
Agent: *仅使用 8k 作答*
  ↓
结果：上下文缩减 40x，无截断，保持完整访问
```

### 优势

| 指标 | 之前 | 之后 | 改进 |
|------|------|------|------|
| 每次查询上下文 | 203k | 5-10k | **20-40x** |
| 内容丢失 | 36% | 0% | **完整保真** |
| 变体数量 | 1 | 3 | **可选** |
| 文件格式 | .txt | .md | **修复** |
| Agent 工作流 | 被动读取 | 主动工具 | **自主** |

---

## 设计组件

### 组件 1：多变体下载

- 下载全部 3 个变体
- 命名修复：`.txt` → `.md`
- 存储：`references/llms-full.md`、`llms-small.md`、`llms.md`、`assets/catalog.json`

### 组件 2：目录系统

- 目的：构建轻量索引而非存储内容
- 从 `llms-small.md` 生成 `assets/catalog.json`
- 提供 `sections` 与 `search_index`

### 组件 3：主动脚本

- `scripts/search.py`：按主题搜索并返回相关章节
- `scripts/list_topics.py`：列出可用章节与大小
- `scripts/get_section.py`：按标题抽取完整章节

### 组件 4：主动 SKILL.md 模板

- 强调按需加载策略
- 提供使用脚本的工作流与示例

---

## 实施计划（阶段）

### 阶段 1：基础修复（已完成）
- 修复扩展名与多变体下载
- 移除内容截断

### 阶段 2：目录系统
- 解析 `llms-small.md` 并生成 `catalog.json`

### 阶段 3：主动脚本
- 创建 `search.py`、`list_topics.py`、`get_section.py`

### 阶段 4：模板更新
- 应用主动技能模板到 llms.txt 技能

---

## 迁移路径与兼容性

- 旧技能保持可用（被动模式不变）
- 新的 llms.txt 技能默认启用主动架构（可配置关闭）

---

## 成功指标与权衡

- 上下文效率：20-40x 减少
- 数据保真：0% 截断
- Agent 能力：可选细节层级、仅加载所需、无限文档访问
- 复杂度：脚本与目录增加一定初期成本

---

## 风险与缓解

- 脚本在 Claude 沙箱中不可用 → 充分测试、提供被动回退
- 目录生成失败 → 优雅降级为单文件模式
- Agent 不使用脚本 → SKILL.md 清晰说明与示例
