# PDF 抓取 CLI 工具（任务 B1.6 + B1.8）

**状态：** ✅ 已完成
**日期：** 2025-10-21
**任务：** B1.6 - 创建 `pdf_scraper.py` CLI；B1.8 - PDF 配置格式

---

## 概览

PDF 抓取器（`pdf_scraper.py`）是一个完整的 CLI 工具，可将 PDF 文档转换为 Claude 技能。它整合了 B1.1-B1.5 的所有 PDF 提取特性，并与 Skill Seeker 工作流结合生成可打包与上传的技能。

## 功能

### ✅ 完整工作流

1. **Extract** - Uses `pdf_extractor_poc.py` for extraction
2. **Categorize** - Organizes content by chapters or keywords
3. **Build** - Creates skill structure (SKILL.md, references/)
4. **Package** - Ready for `package_skill.py`

### ✅ 三种使用模式

1. **Config File** - Use JSON configuration (recommended)
2. **Direct PDF** - Quick conversion from PDF file
3. **From JSON** - Build skill from pre-extracted data

### ✅ 自动分类

- Chapter-based (from PDF structure)
- Keyword-based (configurable)
- Fallback to single category

### ✅ 质量过滤

- Uses quality scores from B1.4
- Extracts top code examples
- Filters by minimum quality threshold

---

## 使用

### 模式 1：配置文件（推荐）

```bash
# Create config file
cat > configs/my_manual.json <<EOF
{
  "name": "mymanual",
  "description": "My Manual documentation",
  "pdf_path": "docs/manual.pdf",
  "extract_options": {
    "chunk_size": 10,
    "min_quality": 6.0,
    "extract_images": true,
    "min_image_size": 150
  },
  "categories": {
    "getting_started": ["introduction", "setup"],
    "api": ["api", "reference", "function"],
    "tutorial": ["tutorial", "example", "guide"]
  }
}
EOF

# Run scraper
python3 cli/pdf_scraper.py --config configs/my_manual.json
```

**输出：**
```
🔍 Extracting from PDF: docs/manual.pdf
📄 Extracting from: docs/manual.pdf
   Pages: 150
   ...
✅ Extraction complete

💾 Saved extracted data to: output/mymanual_extracted.json

🏗️  Building skill: mymanual
📋 Categorizing content...
✅ Created 3 categories
   - Getting Started: 25 pages
   - Api: 80 pages
   - Tutorial: 45 pages

📝 Generating reference files...
   Generated: output/mymanual/references/getting_started.md
   Generated: output/mymanual/references/api.md
   Generated: output/mymanual/references/tutorial.md
   Generated: output/mymanual/references/index.md
   Generated: output/mymanual/SKILL.md

✅ Skill built successfully: output/mymanual/

📦 Next step: Package with: python3 cli/package_skill.py output/mymanual/
```

### 模式 2：直接 PDF

```bash
# Quick conversion without config file
python3 cli/pdf_scraper.py --pdf manual.pdf --name mymanual --description "My Manual Docs"
```

**默认设置：**
- Chunk size: 10
- Min quality: 5.0
- Extract images: true
- Min image size: 100px
- No custom categories (chapter-based)

### 模式 3：从提取的 JSON

```bash
# Step 1: Extract only (saves JSON)
python3 cli/pdf_extractor_poc.py manual.pdf -o manual_extracted.json --extract-images

# Step 2: Build skill from JSON (fast, can iterate)
python3 cli/pdf_scraper.py --from-json manual_extracted.json
```

**优势：**
- Separate extraction and building
- Iterate on skill structure without re-extracting
- Faster development cycle

---

## 配置文件格式（任务 B1.8）

### 完整示例

```json
{
  "name": "godot_manual",
  "description": "Godot Engine documentation from PDF manual",
  "pdf_path": "docs/godot_manual.pdf",
  "extract_options": {
    "chunk_size": 15,
    "min_quality": 6.0,
    "extract_images": true,
    "min_image_size": 200
  },
  "categories": {
    "getting_started": [
      "introduction",
      "getting started",
      "installation",
      "first steps"
    ],
    "scripting": [
      "gdscript",
      "scripting",
      "code",
      "programming"
    ],
    "3d": [
      "3d",
      "spatial",
      "mesh",
      "shader"
    ],
    "2d": [
      "2d",
      "sprite",
      "tilemap",
      "animation"
    ],
    "api": [
      "api",
      "class reference",
      "method",
      "property"
    ]
  }
}
```

### 字段参考

#### 必需字段

- **`name`** (string): Skill identifier
  - Used for directory names
  - Should be lowercase, no spaces
  - Example: `"python_guide"`

- **`pdf_path`** (string): Path to PDF file
  - Absolute or relative to working directory
  - Example: `"docs/manual.pdf"`

#### 可选字段

- **`description`** (string): Skill description
  - Shows in SKILL.md
  - Explains when to use the skill
  - Default: `"Documentation skill for {name}"`

- **`extract_options`** (object): Extraction settings
  - `chunk_size` (number): Pages per chunk (default: 10)
  - `min_quality` (number): Minimum code quality 0-10 (default: 5.0)
  - `extract_images` (boolean): Extract images to files (default: true)
  - `min_image_size` (number): Minimum image dimension in pixels (default: 100)

- **`categories`** (object): Keyword-based categorization
  - Keys: Category names (will be sanitized for filenames)
  - Values: Arrays of keywords to match
  - If omitted: Uses chapter-based categorization from PDF

---

## 输出结构

### 生成的文件

```
output/
├── mymanual_extracted.json          # Raw extraction data (B1.5 format)
└── mymanual/                        # Skill directory
    ├── SKILL.md                     # Main skill file
    ├── references/                  # Reference documentation
    │   ├── index.md                 # Category index
    │   ├── getting_started.md       # Category 1
    │   ├── api.md                   # Category 2
    │   └── tutorial.md              # Category 3
    ├── scripts/                     # Empty (for user scripts)
    └── assets/                      # Assets directory
        └── images/                  # Extracted images (if enabled)
            ├── mymanual_page5_img1.png
            └── mymanual_page12_img2.jpeg
```

### SKILL.md 格式

```markdown
# Mymanual Documentation Skill

My Manual documentation

## When to use this skill

Use this skill when the user asks about mymanual documentation,
including API references, tutorials, examples, and best practices.

## What's included

This skill contains:

- **Getting Started**: 25 pages
- **Api**: 80 pages
- **Tutorial**: 45 pages

## Quick Reference

### Top Code Examples

**Example 1** (Quality: 8.5/10):

```python
def initialize_system():
    config = load_config()
    setup_logging(config)
    return System(config)
```

**Example 2** (Quality: 8.2/10):

```javascript
const app = createApp({
  data() {
    return { count: 0 }
  }
})
```

## Navigation

See `references/index.md` for complete documentation structure.

## Languages Covered

- python: 45 examples
- javascript: 32 examples
- shell: 8 examples
```

### 参考文件格式

Each category gets its own reference file:

```markdown
# Getting Started

## Installation

This guide will walk you through installing the software...

### Code Examples

```bash
curl -O https://example.com/install.sh
bash install.sh
```

---

## Configuration

After installation, configure your environment...

### Code Examples

```yaml
server:
  port: 8080
  host: localhost
```

---
```

---

## 分类逻辑

### 基于章节（自动）

If PDF has detectable chapters (from B1.3):

1. Extract chapter titles and page ranges
2. Create one category per chapter
3. Assign pages to chapters by page number

**Advantages:**
- Automatic, no config needed
- Respects document structure
- Accurate page assignment

**Example chapters:**
- "Chapter 1: Introduction" → `chapter_1_introduction.md`
- "Part 2: Advanced Topics" → `part_2_advanced_topics.md`

### 基于关键词（可配置）

If `categories` config is provided:

1. Score each page against keyword lists
2. Assign to highest-scoring category
3. Fall back to "other" if no match

**Advantages:**
- Flexible, customizable
- Works with PDFs without clear chapters
- Can combine related sections

**Scoring:**
- Keyword in page text: +1 point
- Keyword in page heading: +2 points
- Assigned to category with highest score

---

## 与 Skill Seeker 集成

### 完整工作流

```bash
# 1. Create PDF config
cat > configs/api_manual.json <<EOF
{
  "name": "api_manual",
  "pdf_path": "docs/api.pdf",
  "extract_options": {
    "min_quality": 7.0,
    "extract_images": true
  }
}
EOF

# 2. Run PDF scraper
python3 cli/pdf_scraper.py --config configs/api_manual.json

# 3. Package skill
python3 cli/package_skill.py output/api_manual/

# 4. Upload to Claude (if ANTHROPIC_API_KEY set)
python3 cli/package_skill.py output/api_manual/ --upload

# Result: api_manual.zip ready for Claude!
```

### 增强（可选）

```bash
# After building, enhance with AI
python3 cli/enhance_skill_local.py output/api_manual/

# Or with API
export ANTHROPIC_API_KEY=sk-ant-...
python3 cli/enhance_skill.py output/api_manual/
```

---

## 性能

### 基准

| PDF Size | Pages | Extraction | Building | Total |
|----------|-------|------------|----------|-------|
| Small | 50 | 30s | 5s | 35s |
| Medium | 200 | 2m | 15s | 2m 15s |
| Large | 500 | 5m | 45s | 5m 45s |

**Extraction**: PDF → JSON (cpu-intensive)
**Building**: JSON → Skill (fast, i/o-bound)

### 优化建议

1. **Use `--from-json` for iteration**
   - Extract once, build many times
   - Test categorization without re-extraction

2. **Adjust chunk size**
   - Larger chunks: Faster extraction
   - Smaller chunks: Better chapter detection

3. **Filter aggressively**
   - Higher `min_quality`: Fewer low-quality code blocks
   - Higher `min_image_size`: Fewer small images

---

## 示例

### 示例 1：编程语言手册

```json
{
  "name": "python_reference",
  "description": "Python 3.12 Language Reference",
  "pdf_path": "python-3.12-reference.pdf",
  "extract_options": {
    "chunk_size": 20,
    "min_quality": 7.0,
    "extract_images": false
  },
  "categories": {
    "basics": ["introduction", "basic", "syntax", "types"],
    "functions": ["function", "lambda", "decorator"],
    "classes": ["class", "object", "inheritance"],
    "modules": ["module", "package", "import"],
    "stdlib": ["library", "standard library", "built-in"]
  }
}
```

### 示例 2：API 文档

```json
{
  "name": "rest_api_docs",
  "description": "REST API Documentation",
  "pdf_path": "api_docs.pdf",
  "extract_options": {
    "chunk_size": 10,
    "min_quality": 6.0,
    "extract_images": true,
    "min_image_size": 200
  },
  "categories": {
    "authentication": ["auth", "login", "token", "oauth"],
    "users": ["user", "account", "profile"],
    "products": ["product", "catalog", "inventory"],
    "orders": ["order", "purchase", "checkout"],
    "webhooks": ["webhook", "event", "callback"]
  }
}
```

### 示例 3：框架文档

```json
{
  "name": "django_docs",
  "description": "Django Web Framework Documentation",
  "pdf_path": "django-4.2-docs.pdf",
  "extract_options": {
    "chunk_size": 15,
    "min_quality": 6.5,
    "extract_images": true
  }
}
```
*注：未提供分类 —— 使用章节分类*

---

## 故障排除

### 未创建分类

**Problem:** Only "content" or "other" category

**Possible causes:**
1. No chapters detected in PDF
2. Keywords don't match content
3. Config has empty categories

**Solution:**
```bash
# Check extracted chapters
cat output/mymanual_extracted.json | jq '.chapters'

# If empty, add keyword categories to config
# Or let it create single "content" category (OK for small PDFs)
```

### 低质量代码块过多

**Problem:** Too many poor code examples

**Solution:**
```json
{
  "extract_options": {
    "min_quality": 7.0  // Increase threshold
  }
}
```

### 未提取到图片

**Problem:** No images in `assets/images/`

**Solution:**
```json
{
  "extract_options": {
    "extract_images": true,  // Enable extraction
    "min_image_size": 50     // Lower threshold
  }
}
```

---

## 与网页抓取器对比

| Feature | Web Scraper | PDF Scraper |
|---------|-------------|-------------|
| Input | HTML websites | PDF files |
| Crawling | Multi-page BFS | Single-file extraction |
| Structure detection | CSS selectors | Font/heading analysis |
| Categorization | URL patterns | Chapters/keywords |
| Images | Referenced | Embedded (extracted) |
| Code detection | `<pre><code>` | Font/indent/pattern |
| Language detection | CSS classes | Pattern matching |
| Quality scoring | No | Yes (B1.4) |
| Chunking | No | Yes (B1.3) |

---

## 下一步

### 任务 B1.7：MCP 工具集成

The PDF scraper will be available through MCP:

```python
# Future: MCP tool
result = mcp.scrape_pdf(
    config_path="configs/manual.json"
)

# Or direct
result = mcp.scrape_pdf(
    pdf_path="manual.pdf",
    name="mymanual",
    extract_images=True
)
```

---

## 结论

Tasks B1.6 and B1.8 successfully implement:

**B1.6 - PDF Scraper CLI:**
- ✅ Complete extraction → building workflow
- ✅ Three usage modes (config, direct, from-json)
- ✅ Automatic categorization (chapter or keyword-based)
- ✅ Integration with Skill Seeker workflow
- ✅ Quality filtering and top examples

**B1.8 - PDF Config Format:**
- ✅ JSON configuration format
- ✅ Extraction options (chunk size, quality, images)
- ✅ Category definitions (keyword-based)
- ✅ Compatible with web scraper config style

**影响：**
- Complete PDF documentation support
- Parallel workflow to web scraping
- Reusable extraction results
- High-quality skill generation

**已准备好 B1.7：** MCP 工具集成

---

**Tasks Completed:** October 21, 2025
**Next Task:** B1.7 - Add MCP tool `scrape_pdf`
