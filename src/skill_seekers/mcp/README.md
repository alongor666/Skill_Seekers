# Skill Seeker MCP 服务器

面向 Skill Seeker 的 Model Context Protocol（MCP）服务器——使 Claude Code 能直接生成文档技能。

## 这是什么？

该 MCP 服务器使 Claude Code 可通过自然语言直接调用 Skill Seeker 工具。无需手动运行 CLI 命令，你可以让 Claude Code：

- 为任意文档站点生成配置文件
- 在抓取前估计页面数量
- 抓取文档并构建技能
- 将技能打包为 `.zip` 文件
- 列出并校验配置
- 将大型文档（1 万-4 万+ 页）拆分为聚焦子技能
- 为拆分文档生成智能路由/枢纽技能
- **新增：**抓取 PDF 文档并提取代码/图片

## 快速开始

### 1. 安装依赖

```bash
# From repository root
pip3 install -r mcp/requirements.txt
pip3 install requests beautifulsoup4
```

### 2. 快速设置（自动化）

```bash
# 运行安装脚本
# 按提示操作，脚本将：
# - 安装依赖
# - 测试服务器
# - 生成配置
# - 引导完成 Claude Code 设置
```

### 3. 手动设置

Add to `~/.config/claude-code/mcp.json`:

```json
{
  "mcpServers": {
    "skill-seeker": {
      "command": "python3",
      "args": [
        "/path/to/Skill_Seekers/mcp/server.py"
      ],
      "cwd": "/path/to/Skill_Seekers"
    }
  }
}
```

**将 `/path/to/Skill_Seekers` 替换为你的实际仓库路径！**

### 4. 重启 Claude Code

完全退出并重新打开 Claude Code（不是仅关闭窗口）。

### 5. 测试

In Claude Code, type:
```
List all available configs
```

应能看到预设配置列表（Godot、React、Vue 等）。

## 可用工具

该 MCP 服务器提供 10 个工具：

### 1. `generate_config`
为任意文档网站创建新的配置文件。

**Parameters:**
- `name` (required): Skill name (e.g., "tailwind")
- `url` (required): Documentation URL (e.g., "https://tailwindcss.com/docs")
- `description` (required): When to use this skill
- `max_pages` (optional): Maximum pages to scrape (default: 100)
- `rate_limit` (optional): Delay between requests in seconds (default: 0.5)

**Example:**
```
Generate config for Tailwind CSS at https://tailwindcss.com/docs
```

### 2. `estimate_pages`
快速估计配置将抓取的页面数（不下载数据）。

**Parameters:**
- `config_path` (required): Path to config file (e.g., "configs/react.json")
- `max_discovery` (optional): Maximum pages to discover (default: 1000)

**Example:**
```
Estimate pages for configs/react.json
```

### 3. `scrape_docs`
抓取文档并构建 Claude 技能。

**Parameters:**
- `config_path` (required): Path to config file
- `enhance_local` (optional): Open terminal for local enhancement (default: false)
- `skip_scrape` (optional): Use cached data (default: false)
- `dry_run` (optional): Preview without saving (default: false)

**Example:**
```
Scrape docs using configs/react.json
```

### 4. `package_skill`
将技能目录打包为可上传到 Claude 的 `.zip`。若设置了 ANTHROPIC_API_KEY 将自动上传。

**Parameters:**
- `skill_dir` (required): Path to skill directory (e.g., "output/react/")
- `auto_upload` (optional): Try to upload automatically if API key is available (default: true)

**Example:**
```
Package skill at output/react/
```

### 5. `upload_skill`
自动将技能 `.zip` 上传至 Claude（需要 ANTHROPIC_API_KEY）。

**Parameters:**
- `skill_zip` (required): Path to skill .zip file (e.g., "output/react.zip")

**Example:**
```
Upload output/react.zip using upload_skill
```

### 6. `list_configs`
列出所有可用的预设配置。

**Parameters:** None

**Example:**
```
List all available configs
```

### 7. `validate_config`
校验配置文件是否存在错误。

**Parameters:**
- `config_path` (required): Path to config file

**Example:**
```
Validate configs/godot.json
```

### 8. `split_config`
将大型文档配置拆分为多个聚焦技能。适用于 1 万+ 页文档。

**Parameters:**
- `config_path` (required): Path to config JSON file (e.g., "configs/godot.json")
- `strategy` (optional): Split strategy - "auto", "none", "category", "router", "size" (default: "auto")
- `target_pages` (optional): Target pages per skill (default: 5000)
- `dry_run` (optional): Preview without saving files (default: false)

**Example:**
```
Split configs/godot.json using router strategy with 5000 pages per skill
```

**Strategies:**
- **auto** - Intelligently detects best strategy based on page count and config
- **category** - Split by documentation categories (creates focused sub-skills)
- **router** - Create router/hub skill + specialized sub-skills (RECOMMENDED for 10K+ pages)
- **size** - Split every N pages (for docs without clear categories)

### 9. `generate_router`
为拆分文档生成路由/枢纽技能，实现到子技能的智能路由。

**Parameters:**
- `config_pattern` (required): Config pattern for sub-skills (e.g., "configs/godot-*.json")
- `router_name` (optional): Router skill name (inferred from configs if not provided)

**Example:**
```
Generate router for configs/godot-*.json
```

**What it does:**
- Analyzes all sub-skill configs
- Extracts routing keywords from categories and names
- Creates router SKILL.md with intelligent routing logic
- Users can ask questions naturally, router directs to appropriate sub-skill

### 10. `scrape_pdf`
抓取 PDF 文档并构建 Claude 技能。支持从 PDF 提取文本、代码块、图片与表格等高级能力。

**Parameters:**
- `config_path` (optional): Path to PDF config JSON file (e.g., "configs/manual_pdf.json")
- `pdf_path` (optional): Direct PDF path (alternative to config_path)
- `name` (optional): Skill name (required with pdf_path)
- `description` (optional): Skill description
- `from_json` (optional): Build from extracted JSON file (e.g., "output/manual_extracted.json")
- `use_ocr` (optional): Use OCR for scanned PDFs (requires pytesseract)
- `password` (optional): Password for encrypted PDFs
- `extract_tables` (optional): Extract tables from PDF
- `parallel` (optional): Process pages in parallel for faster extraction
- `max_workers` (optional): Number of parallel workers (default: CPU count)

**Examples:**
```
Scrape PDF at docs/manual.pdf and create skill named api-docs
Create skill from configs/example_pdf.json
Build skill from output/manual_extracted.json
Scrape scanned PDF with OCR: --pdf docs/scanned.pdf --ocr
Scrape encrypted PDF: --pdf docs/manual.pdf --password mypassword
Extract tables: --pdf docs/data.pdf --extract-tables
Fast parallel processing: --pdf docs/large.pdf --parallel --workers 8
```

**能力概述：**
- Extracts text and markdown from PDF pages
- Detects code blocks using 3 methods (font, indent, pattern)
- Detects programming language with confidence scoring (19+ languages)
- Validates syntax and scores code quality (0-10 scale)
- Extracts images with size filtering
- **NEW:** Extracts tables from PDFs (Priority 2)
- **NEW:** OCR support for scanned PDFs (Priority 2, requires pytesseract + Pillow)
- **NEW:** Password-protected PDF support (Priority 2)
- **NEW:** Parallel page processing for faster extraction (Priority 3)
- **NEW:** Intelligent caching of expensive operations (Priority 3)
- Detects chapters and creates page chunks
- Categorizes content automatically
- Generates complete skill structure (SKILL.md + references)

**性能：**
- Sequential: ~30-60 seconds per 100 pages
- Parallel (8 workers): ~10-20 seconds per 100 pages (3x faster)

**参考：**完整 PDF 指南见 `docs/PDF_SCRAPER.md`

## 示例工作流

### 从零生成新技能

```
User: Generate config for Svelte at https://svelte.dev/docs

Claude: ✅ Config created: configs/svelte.json

User: Estimate pages for configs/svelte.json

Claude: 📊 Estimated pages: 150

User: Scrape docs using configs/svelte.json

Claude: ✅ Skill created at output/svelte/

User: Package skill at output/svelte/

Claude: ✅ Created: output/svelte.zip
      Ready to upload to Claude!
```

### 使用现有预设

```
User: List all available configs

Claude: [Shows all configs: godot, react, vue, django, fastapi, etc.]

User: Scrape docs using configs/react.json

Claude: ✅ Skill created at output/react/

User: Package skill at output/react/

Claude: ✅ Created: output/react.zip
```

### 抓取前先校验

```
User: Validate configs/godot.json

Claude: ✅ Config is valid!
        Name: godot
        Base URL: https://docs.godotengine.org/en/stable/
        Max pages: 500
        Rate limit: 0.5s

User: Scrape docs using configs/godot.json

Claude: [Starts scraping...]
```

### PDF 文档 - 新增

```
User: Scrape PDF at docs/api-manual.pdf and create skill named api-docs

Claude: 📄 Scraping PDF documentation...
        ✅ Extracted 120 pages
        ✅ Found 45 code blocks (Python, JavaScript, C++)
        ✅ Extracted 12 images
        ✅ Created skill at output/api-docs/
        📦 Package with: python3 cli/package_skill.py output/api-docs/

User: Package skill at output/api-docs/

Claude: ✅ Created: output/api-docs.zip
        Ready to upload to Claude!
```

### 大型文档（40K 页）

```
User: Estimate pages for configs/godot.json

Claude: 📊 Estimated pages: 40,000
        ⚠️  Large documentation detected!
        💡 Recommend splitting into multiple skills

User: Split configs/godot.json using router strategy

Claude: ✅ Split complete!
        Created 5 sub-skills:
        - godot-scripting.json (5,000 pages)
        - godot-2d.json (8,000 pages)
        - godot-3d.json (10,000 pages)
        - godot-physics.json (6,000 pages)
        - godot-shaders.json (11,000 pages)

User: Scrape all godot sub-skills in parallel

Claude: [Starts scraping all 5 configs in parallel...]
        ✅ All skills created in 4-8 hours instead of 20-40!

User: Generate router for configs/godot-*.json

Claude: ✅ Router skill created at output/godot/
        Routing logic:
        - "scripting", "gdscript" → godot-scripting
        - "2d", "sprites", "tilemap" → godot-2d
        - "3d", "meshes", "camera" → godot-3d
        - "physics", "collision" → godot-physics
        - "shaders", "visual shader" → godot-shaders

User: Package all godot skills

Claude: ✅ 6 skills packaged:
        - godot.zip (router)
        - godot-scripting.zip
        - godot-2d.zip
        - godot-3d.zip
        - godot-physics.zip
        - godot-shaders.zip

        Upload all to Claude!
        Users just ask questions naturally - router handles routing!
```

## 架构

### 服务器结构

```
mcp/
├── server.py           # Main MCP server
├── requirements.txt    # MCP dependencies
└── README.md          # This file
```

### 工作原理

1. **Claude Code** sends MCP requests to the server
2. **Server** routes requests to appropriate tool functions
3. **Tools** call CLI scripts (`doc_scraper.py`, `estimate_pages.py`, etc.)
4. **CLI scripts** perform actual work (scraping, packaging, etc.)
5. **Results** returned to Claude Code via MCP protocol

### 工具实现

Each tool is implemented as an async function:

```python
async def generate_config_tool(args: dict) -> list[TextContent]:
    """Generate a config file"""
    # Create config JSON
    # Save to configs/
    # Return success message
```

Tools use `subprocess.run()` to call CLI scripts:

```python
result = subprocess.run([
    sys.executable,
    str(CLI_DIR / "doc_scraper.py"),
    "--config", config_path
], capture_output=True, text=True)
```

## 测试

该 MCP 服务器具备完善的测试覆盖：

```bash
# Run MCP server tests (25 tests)
python3 -m pytest tests/test_mcp_server.py -v

# Expected output: 25 passed in ~0.3s
```

### 测试覆盖

- **Server initialization** (2 tests)
- **Tool listing** (2 tests)
- **generate_config** (3 tests)
- **estimate_pages** (3 tests)
- **scrape_docs** (4 tests)
- **package_skill** (3 tests)
- **upload_skill** (2 tests)
- **list_configs** (3 tests)
- **validate_config** (3 tests)
- **split_config** (3 tests)
- **generate_router** (3 tests)
- **Tool routing** (2 tests)
- **Integration** (1 test)

**Total: 34 tests | Pass rate: 100%**

## 故障排查

### MCP 服务器未加载

**现象：**
- Tools don't appear in Claude Code
- No response to skill-seeker commands

**解决：**

1. Check configuration:
   ```bash
   cat ~/.config/claude-code/mcp.json
   ```

2. Verify server can start:
   ```bash
   python3 mcp/server.py
   # Should start without errors (Ctrl+C to exit)
   ```

3. Check dependencies:
   ```bash
   pip3 install -r mcp/requirements.txt
   ```

4. Completely restart Claude Code (quit and reopen)

5. Check Claude Code logs:
   - macOS: `~/Library/Logs/Claude Code/`
   - Linux: `~/.config/claude-code/logs/`

### “ModuleNotFoundError: No module named 'mcp'”

```bash
pip3 install -r mcp/requirements.txt
```

### 工具显示但不可用

**解决：**

1. Verify `cwd` in config points to repository root
2. Check CLI tools exist:
   ```bash
   ls cli/doc_scraper.py
   ls cli/estimate_pages.py
   ls cli/package_skill.py
   ```

3. Test CLI tools directly:
   ```bash
   python3 cli/doc_scraper.py --help
   ```

### 操作缓慢

1. Check rate limit in configs (increase if needed)
2. Use smaller `max_pages` for testing
3. Use `skip_scrape` to avoid re-downloading data

## 高级配置

### 使用虚拟环境

```bash
# Create venv
python3 -m venv venv
source venv/bin/activate
pip install -r mcp/requirements.txt
pip install requests beautifulsoup4
which python3  # Copy this path
```

配置 Claude Code 使用 venv 的 Python：

```json
{
  "mcpServers": {
    "skill-seeker": {
      "command": "/path/to/Skill_Seekers/venv/bin/python3",
      "args": ["/path/to/Skill_Seekers/mcp/server.py"],
      "cwd": "/path/to/Skill_Seekers"
    }
  }
}
```

### 调试模式

启用详细日志：

```json
{
  "mcpServers": {
    "skill-seeker": {
      "command": "python3",
      "args": ["-u", "/path/to/Skill_Seekers/mcp/server.py"],
      "cwd": "/path/to/Skill_Seekers",
      "env": {
        "DEBUG": "1"
      }
    }
  }
}
```

### 配合 API 增强

若使用基于 API 的增强（需要 Anthropic API Key）：

```json
{
  "mcpServers": {
    "skill-seeker": {
      "command": "python3",
      "args": ["/path/to/Skill_Seekers/mcp/server.py"],
      "cwd": "/path/to/Skill_Seekers",
      "env": {
        "ANTHROPIC_API_KEY": "sk-ant-your-key-here"
      }
    }
  }
}
```

## 性能

| Operation | Time | Notes |
|-----------|------|-------|
| List configs | <1s | Instant |
| Generate config | <1s | Creates JSON file |
| Validate config | <1s | Quick validation |
| Estimate pages | 1-2min | Fast, no data download |
| Split config | 1-3min | Analyzes and creates sub-configs |
| Generate router | 10-30s | Creates router SKILL.md |
| Scrape docs | 15-45min | First time only |
| Scrape docs (40K pages) | 20-40hrs | Sequential |
| Scrape docs (40K pages, parallel) | 4-8hrs | 5 skills in parallel |
| Scrape (cached) | <1min | With `skip_scrape` |
| Package skill | 5-10s | Creates .zip |
| Package multi | 30-60s | Packages 5-10 skills |

## 文档

- **Full Setup Guide**: [docs/MCP_SETUP.md](../docs/MCP_SETUP.md)
- **Main README**: [README.md](../README.md)
- **Usage Guide**: [docs/USAGE.md](../docs/USAGE.md)
- **Testing Guide**: [docs/TESTING.md](../docs/TESTING.md)

## 支持

- **Issues**: [GitHub Issues](https://github.com/yusufkaraaslan/Skill_Seekers/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yusufkaraaslan/Skill_Seekers/discussions)

## 许可证

MIT License - See [LICENSE](../LICENSE) for details
