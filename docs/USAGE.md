# Skill Seeker 完整使用指南（中文唯一版本）

涵盖全部命令、选项与工作流的完整参考。

## 目录

- 快速参考
- 主工具：doc_scraper.py
- 估算器：estimate_pages.py
- 增强工具
- 打包工具
- 测试工具
- 可用配置
- 常见工作流
- 故障排除

---

## 快速参考

```bash
# 1. Estimate pages (fast, 1-2 min)
python3 cli/estimate_pages.py configs/react.json

# 2. Scrape documentation (20-40 min)
python3 cli/doc_scraper.py --config configs/react.json

# 3. Enhance with Claude Code (60 sec)
python3 cli/enhance_skill_local.py output/react/

# 4. Package to .zip (instant)
python3 cli/package_skill.py output/react/

# 5. Test everything (1 sec)
python3 cli/run_tests.py
```

---

## 主工具：doc_scraper.py

### 完整帮助

```
usage: doc_scraper.py [-h] [--interactive] [--config CONFIG] [--name NAME]
                      [--url URL] [--description DESCRIPTION] [--skip-scrape]
                      [--dry-run] [--enhance] [--enhance-local]
                      [--api-key API_KEY]

Convert documentation websites to Claude skills

options:
  -h, --help            Show this help message and exit
  --interactive, -i     Interactive configuration mode
  --config, -c CONFIG   Load configuration from file (e.g., configs/godot.json)
  --name NAME           Skill name
  --url URL             Base documentation URL
  --description, -d DESCRIPTION
                        Skill description
  --skip-scrape         Skip scraping, use existing data
  --dry-run             Preview what will be scraped without actually scraping
  --enhance             Enhance SKILL.md using Claude API after building
                        (requires API key)
  --enhance-local       Enhance SKILL.md using Claude Code in new terminal
                        (no API key needed)
  --api-key API_KEY     Anthropic API key for --enhance (or set ANTHROPIC_API_KEY)
```

### 使用示例

1）使用预设配置（推荐）
```bash
python3 cli/doc_scraper.py --config configs/godot.json
python3 cli/doc_scraper.py --config configs/react.json
python3 cli/doc_scraper.py --config configs/vue.json
python3 cli/doc_scraper.py --config configs/django.json
python3 cli/doc_scraper.py --config configs/fastapi.json
```

2）交互模式
```bash
python3 cli/doc_scraper.py --interactive
# Wizard walks you through:
# - Skill name
# - Base URL
# - Description
# - Selectors (optional)
# - URL patterns (optional)
# - Rate limit
# - Max pages
```

3）快速模式（最小化配置）
```bash
python3 cli/doc_scraper.py \
  --name react \
  --url https://react.dev/ \
  --description "React framework for building UIs"
```

4）试运行（预览）
```bash
python3 cli/doc_scraper.py --config configs/react.json --dry-run
# Shows what will be scraped without downloading data
# No directories created
# Fast validation
```

5）跳过抓取（使用缓存数据）
```bash
python3 cli/doc_scraper.py --config configs/godot.json --skip-scrape
# Uses existing output/godot_data/
# Fast rebuild (1-3 minutes)
# Useful for testing changes
```

6）本地增强
```bash
python3 cli/doc_scraper.py --config configs/react.json --enhance-local
# Scrapes + enhances in one command
# Opens new terminal for Claude Code
# No API key needed
```

7）API 增强
```bash
export ANTHROPIC_API_KEY=sk-ant-...
python3 cli/doc_scraper.py --config configs/react.json --enhance

# Or with inline API key:
python3 cli/doc_scraper.py --config configs/react.json --enhance --api-key sk-ant-...
```

### 输出结构

```
output/
├── {name}_data/              # Scraped raw data (cached)
│   ├── pages/
│   │   ├── page_0.json
│   │   ├── page_1.json
│   │   └── ...
│   └── summary.json          # Scraping stats
│
└── {name}/                   # Built skill directory
    ├── SKILL.md              # Main skill file
    ├── SKILL.md.backup       # Backup (if enhanced)
    ├── references/           # Categorized docs
    │   ├── index.md
    │   ├── getting_started.md
    │   ├── api.md
    │   └── ...
    ├── scripts/              # Empty (user scripts)
    └── assets/               # Empty (user assets)
```

---

## 估算器：estimate_pages.py

### 完整帮助

```
usage: estimate_pages.py [-h] [--max-discovery MAX_DISCOVERY]
                         [--timeout TIMEOUT]
                         config

Estimate page count for Skill Seeker configs

positional arguments:
  config                Path to config JSON file

options:
  -h, --help            Show this help message and exit
  --max-discovery, -m MAX_DISCOVERY
                        Maximum pages to discover (default: 1000)
  --timeout, -t TIMEOUT
                        HTTP request timeout in seconds (default: 30)
```

### 使用示例

**1. Quick Estimate (100 pages)**
```bash
python3 cli/estimate_pages.py configs/react.json --max-discovery 100
# Time: ~30-60 seconds
# Good for: Quick validation
```

**2. Standard Estimate (1000 pages - default)**
```bash
python3 cli/estimate_pages.py configs/godot.json
# Time: ~1-2 minutes
# Good for: Most use cases
```

**3. Deep Estimate (2000 pages)**
```bash
python3 cli/estimate_pages.py configs/vue.json --max-discovery 2000
# Time: ~3-5 minutes
# Good for: Large documentation sites
```

**4. Custom Timeout**
```bash
python3 cli/estimate_pages.py configs/django.json --timeout 60
# Useful for slow servers
```

### 输出示例

```
🔍 Estimating pages for: react
📍 Base URL: https://react.dev/
🎯 Start URLs: 6
⏱️  Rate limit: 0.5s
🔢 Max discovery: 1000

⏳ Discovered: 180 pages (1.3 pages/sec)

======================================================================
📊 ESTIMATION RESULTS
======================================================================

Config: react
Base URL: https://react.dev/

✅ Pages Discovered: 180
⏳ Pages Pending: 50
📈 Estimated Total: 230

⏱️  Time Elapsed: 140.5s
⚡ Discovery Rate: 1.28 pages/sec

======================================================================
💡 RECOMMENDATIONS
======================================================================

✅ Current max_pages (300) is sufficient

⏱️  Estimated full scrape time: 1.9 minutes
   (Based on rate_limit: 0.5s)
```

包含内容：
- Estimated total pages to scrape
- Whether current `max_pages` is sufficient
- Recommended `max_pages` value
- Estimated scraping time
- Discovery rate (pages/sec)

---

## 增强工具

### enhance_skill_local.py（推荐）

**No API key needed - uses Claude Code Max plan**

```bash
# Usage
python3 cli/enhance_skill_local.py output/react/
python3 cli/enhance_skill_local.py output/godot/

# What it does:
# 1. Reads SKILL.md and references/
# 2. Opens new terminal with Claude Code
# 3. Claude enhances SKILL.md
# 4. Backs up original to SKILL.md.backup
# 5. Saves enhanced version

# Time: ~60 seconds
# Cost: Free (uses your Claude Code Max plan)
```

### enhance_skill.py（备选）

**Requires Anthropic API key**

```bash
# Install dependency first
pip3 install anthropic

# Usage with environment variable
export ANTHROPIC_API_KEY=sk-ant-...
python3 cli/enhance_skill.py output/react/

# Usage with inline API key
python3 cli/enhance_skill.py output/godot/ --api-key sk-ant-...

# What it does:
# 1. Reads SKILL.md and references/
# 2. Calls Claude API (Sonnet 4)
# 3. Enhances SKILL.md
# 4. Backs up original to SKILL.md.backup
# 5. Saves enhanced version

# Time: ~30-60 seconds
# Cost: ~$0.01-0.10 per skill (depending on size)
```

---

## 打包工具

### package_skill.py

```bash
# Usage
python3 cli/package_skill.py output/react/
python3 cli/package_skill.py output/godot/

# What it does:
# 1. Validates SKILL.md exists
# 2. Creates .zip with all skill files
# 3. Saves to output/{name}.zip

# Output:
# output/react.zip
# output/godot.zip

# Time: Instant
```

---

## 测试工具

### run_tests.py

```bash
# Run all tests (default)
python3 cli/run_tests.py
# 71 tests, ~1 second

# Verbose output
python3 cli/run_tests.py -v
python3 cli/run_tests.py --verbose

# Quiet output
python3 cli/run_tests.py -q
python3 cli/run_tests.py --quiet

# Stop on first failure
python3 cli/run_tests.py -f
python3 cli/run_tests.py --failfast

# Run specific test suite
python3 cli/run_tests.py --suite config
python3 cli/run_tests.py --suite features
python3 cli/run_tests.py --suite integration

# List all tests
python3 cli/run_tests.py --list
```

### 单项测试

```bash
# Run single test file
python3 -m unittest tests.test_config_validation
python3 -m unittest tests.test_scraper_features
python3 -m unittest tests.test_integration

# Run single test class
python3 -m unittest tests.test_config_validation.TestConfigValidation

# Run single test method
python3 -m unittest tests.test_config_validation.TestConfigValidation.test_valid_complete_config
```

---

## 可用配置

### 预设配置（即刻使用）

| Config | Framework | Pages | Description |
|--------|-----------|-------|-------------|
| `godot.json` | Godot Engine | ~500 | Game engine documentation |
| `react.json` | React | ~300 | React framework docs |
| `vue.json` | Vue.js | ~250 | Vue.js framework docs |
| `django.json` | Django | ~400 | Django web framework |
| `fastapi.json` | FastAPI | ~200 | FastAPI Python framework |
| `steam-economy-complete.json` | Steam | ~100 | Steam Economy API docs |

### 查看配置详情

```bash
# List all configs
ls configs/

# View config content
cat configs/react.json
python3 -m json.tool configs/godot.json
```

### 配置结构

```json
{
  "name": "react",
  "base_url": "https://react.dev/",
  "description": "React - JavaScript library for building UIs",
  "start_urls": [
    "https://react.dev/learn",
    "https://react.dev/reference/react",
    "https://react.dev/reference/react-dom"
  ],
  "selectors": {
    "main_content": "article",
    "title": "h1",
    "code_blocks": "pre code"
  },
  "url_patterns": {
    "include": ["/learn/", "/reference/"],
    "exclude": ["/blog/", "/community/"]
  },
  "categories": {
    "getting_started": ["learn", "tutorial", "intro"],
    "api": ["reference", "api", "hooks"],
    "guides": ["guide"]
  },
  "rate_limit": 0.5,
  "max_pages": 300
}
```

---

## 常见工作流

### 工作流 1：使用预设（最快）

```bash
# 1. Estimate (optional, 1-2 min)
python3 cli/estimate_pages.py configs/react.json

# 2. Scrape with local enhancement (25 min)
python3 cli/doc_scraper.py --config configs/react.json --enhance-local

# 3. Package (instant)
python3 cli/package_skill.py output/react/

# Result: output/react.zip
# Upload to Claude!
```

### 工作流 2：自定义文档

```bash
# 1. Create config
cat > configs/my-docs.json << 'EOF'
{
  "name": "my-docs",
  "base_url": "https://docs.example.com/",
  "description": "My documentation site",
  "rate_limit": 0.5,
  "max_pages": 200
}
EOF

# 2. Estimate
python3 cli/estimate_pages.py configs/my-docs.json

# 3. Dry-run test
python3 cli/doc_scraper.py --config configs/my-docs.json --dry-run

# 4. Full scrape
python3 cli/doc_scraper.py --config configs/my-docs.json

# 5. Enhance
python3 cli/enhance_skill_local.py output/my-docs/

# 6. Package
python3 cli/package_skill.py output/my-docs/
```

### 工作流 3：交互模式

```bash
# 1. Start interactive wizard
python3 cli/doc_scraper.py --interactive

# 2. Answer prompts:
#    - Name: my-framework
#    - URL: https://framework.dev/
#    - Description: My favorite framework
#    - Selectors: (uses defaults)
#    - Rate limit: 0.5
#    - Max pages: 100

# 3. Enhance
python3 cli/enhance_skill_local.py output/my-framework/

# 4. Package
python3 cli/package_skill.py output/my-framework/
```

### 工作流 4：快速模式

```bash
python3 cli/doc_scraper.py \
  --name vue \
  --url https://vuejs.org/ \
  --description "Vue.js framework" \
  --enhance-local
```

### 工作流 5：缓存重建

```bash
# Already scraped once?
# Skip re-scraping, just rebuild
python3 cli/doc_scraper.py --config configs/godot.json --skip-scrape

# Try new enhancement
python3 cli/enhance_skill_local.py output/godot/

# Re-package
python3 cli/package_skill.py output/godot/
```

### 工作流 6：测试新配置

```bash
# 1. Create test config with low max_pages
cat > configs/test.json << 'EOF'
{
  "name": "test-site",
  "base_url": "https://docs.test.com/",
  "max_pages": 20,
  "rate_limit": 0.1
}
EOF

# 2. Estimate
python3 cli/estimate_pages.py configs/test.json --max-discovery 50

# 3. Dry-run
python3 cli/doc_scraper.py --config configs/test.json --dry-run

# 4. Small scrape
python3 cli/doc_scraper.py --config configs/test.json

# 5. Validate output
ls output/test-site/
ls output/test-site/references/

# 6. If good, increase max_pages and re-run
```

---

## 故障排除

### 问题：Rate limit exceeded（限速超出）

```bash
# Increase rate_limit in config
# Default: 0.5 seconds
# Conservative: 1.0 seconds
# Very conservative: 2.0 seconds

# Edit config:
{
  "rate_limit": 1.0
}
```

### 问题：Too many pages（页面过多）

```bash
# Estimate first
python3 cli/estimate_pages.py configs/my-config.json

# Set max_pages based on estimate
# Add buffer: estimated + 50

# Edit config:
{
  "max_pages": 350  # for 300 estimated
}
```

### 问题：No content extracted（无内容提取）

```bash
# Wrong selectors
# Test selectors manually:
curl -s https://docs.example.com/ | grep -i 'article\|main\|content'

# Common selectors:
"main_content": "article"
"main_content": "main"
"main_content": ".content"
"main_content": "#main-content"
"main_content": "div[role=\"main\"]"

# Update config with correct selector
```

### 问题：Tests failing（测试失败）

```bash
# Run specific failing test
python3 -m unittest tests.test_config_validation.TestConfigValidation.test_name -v

# Check error message
# Verify expectations match implementation
```

### 问题：Enhancement fails（增强失败）

```bash
# Local enhancement:
# Make sure Claude Code is running
# Check terminal output

# API enhancement:
# Verify API key is set:
echo $ANTHROPIC_API_KEY

# Or use inline:
python3 cli/enhance_skill.py output/react/ --api-key sk-ant-...
```

### 问题：Package fails（打包失败）

```bash
# Verify SKILL.md exists
ls output/my-skill/SKILL.md

# If missing, build first:
python3 cli/doc_scraper.py --config configs/my-skill.json --skip-scrape
```

### 问题：无法找到输出

```bash
# Check output directory
ls output/

# Skill data (cached):
ls output/{name}_data/

# Built skill:
ls output/{name}/

# Packaged skill:
ls output/{name}.zip
```

---

## 高级用法

### 自定义选择器

```json
{
  "selectors": {
    "main_content": "div.documentation",
    "title": "h1.page-title",
    "code_blocks": "pre.highlight code",
    "navigation": "nav.sidebar"
  }
}
```

### URL 模式过滤

```json
{
  "url_patterns": {
    "include": [
      "/docs/",
      "/guide/",
      "/api/",
      "/tutorial/"
    ],
    "exclude": [
      "/blog/",
      "/news/",
      "/community/",
      "/showcase/"
    ]
  }
}
```

### 自定义分类

```json
{
  "categories": {
    "getting_started": ["intro", "tutorial", "quickstart", "installation"],
    "core_concepts": ["concept", "fundamental", "architecture"],
    "api": ["reference", "api", "method", "function"],
    "guides": ["guide", "how-to", "example"],
    "advanced": ["advanced", "expert", "performance"]
  }
}
```

### 多起始 URL

```json
{
  "start_urls": [
    "https://docs.example.com/getting-started/",
    "https://docs.example.com/api/",
    "https://docs.example.com/guides/",
    "https://docs.example.com/examples/"
  ]
}
```

---

## 性能提示

1. **Estimate first**: Save 20-40 minutes by validating config
2. **Use dry-run**: Test selectors before full scrape
3. **Cache data**: Use `--skip-scrape` for fast rebuilds
4. **Adjust rate_limit**: Balance speed vs politeness
5. **Set appropriate max_pages**: Don't scrape more than needed
6. **Use start_urls**: Target specific documentation sections
7. **Filter URLs**: Use include/exclude patterns
8. **Run tests**: Catch issues early

---

## 环境变量

```bash
# Anthropic API key (for API enhancement)
export ANTHROPIC_API_KEY=sk-ant-...

# Optional: Set custom output directory
export SKILL_SEEKER_OUTPUT_DIR=/path/to/output
```

---

## 退出码

- `0`: Success
- `1`: Error (general)
- `2`: Warning (estimation hit limit)

---

## 文件位置

```
Skill_Seekers/
├── doc_scraper.py           # Main tool
├── estimate_pages.py        # Estimator
├── enhance_skill.py         # API enhancement
├── enhance_skill_local.py   # Local enhancement
├── package_skill.py         # Packager
├── run_tests.py             # Test runner
├── configs/                 # Preset configs
├── tests/                   # Test suite
├── docs/                    # Documentation
└── output/                  # Generated output
```

---

## 获取帮助

```bash
# Tool-specific help
python3 cli/doc_scraper.py --help
python3 cli/estimate_pages.py --help
python3 cli/run_tests.py --help

# Documentation
cat CLAUDE.md              # Quick reference for Claude Code
cat docs/CLAUDE.md         # Detailed technical docs
cat docs/TESTING.md        # Testing guide
cat docs/USAGE.md          # This file
cat docs/ENHANCEMENT.md    # Enhancement guide
cat docs/UPLOAD_GUIDE.md   # Upload instructions
cat README.md              # Project overview
```

---

## 总结

**Essential Commands:**
```bash
python3 cli/estimate_pages.py configs/react.json              # Estimate
python3 cli/doc_scraper.py --config configs/react.json        # Scrape
python3 cli/enhance_skill_local.py output/react/              # Enhance
python3 cli/package_skill.py output/react/                    # Package
python3 cli/run_tests.py                                      # Test
```

**Quick Start:**
```bash
pip3 install requests beautifulsoup4
python3 cli/doc_scraper.py --config configs/react.json --enhance-local
python3 cli/package_skill.py output/react/
# Upload output/react.zip to Claude!
```

Happy skill creating! 🚀
# Skill Seeker 完整使用指南

涵盖全部命令、选项与工作流的完整参考。

## 目录

- 快速参考
- 主工具：doc_scraper.py
- 估算器：estimate_pages.py
- 增强工具
- 打包工具
- 测试工具
- 可用配置
- 常见工作流
- 故障排除

---

## 快速参考

```bash
# 1. 估算页面（快速，1-2 分钟）
python3 cli/estimate_pages.py configs/react.json

# 2. 抓取文档（20-40 分钟）
python3 cli/doc_scraper.py --config configs/react.json

# 3. 使用 Claude Code 增强（约 60 秒）
python3 cli/enhance_skill_local.py output/react/

# 4. 打包为 .zip（即时）
python3 cli/package_skill.py output/react/

# 5. 运行测试（约 1 秒）
python3 cli/run_tests.py
```

---

## 主工具：doc_scraper.py

### 完整帮助

```
usage: doc_scraper.py [-h] [--interactive] [--config CONFIG] [--name NAME]
                      [--url URL] [--description DESCRIPTION] [--skip-scrape]
                      [--dry-run] [--enhance] [--enhance-local]
                      [--api-key API_KEY]

将文档网站转换为 Claude 技能

options:
  -h, --help            显示帮助并退出
  --interactive, -i     交互式配置模式
  --config, -c CONFIG   从文件加载配置（例如 configs/godot.json）
  --name NAME           技能名称
  --url URL             文档基础 URL
  --description, -d DESCRIPTION
                        技能描述
  --skip-scrape         跳过抓取，使用现有数据
  --dry-run             预览将要抓取的内容，不实际执行
  --enhance             使用 Claude API 增强 SKILL.md（需要 API Key）
  --enhance-local       使用 Claude Code 在新终端增强 SKILL.md（无需 API Key）
  --api-key API_KEY     为 --enhance 指定 Anthropic API Key（或设置环境变量）
```

### 使用示例

**1. 使用预设配置（推荐）**
```bash
python3 cli/doc_scraper.py --config configs/godot.json
python3 cli/doc_scraper.py --config configs/react.json
python3 cli/doc_scraper.py --config configs/vue.json
python3 cli/doc_scraper.py --config configs/django.json
python3 cli/doc_scraper.py --config configs/fastapi.json
```

**2. 交互模式**
```bash
python3 cli/doc_scraper.py --interactive
# 向导将引导你完成：
# - 技能名
# - 基础 URL
# - 描述
# - 选择器（可选）
# - URL 模式（可选）
# - 速率限制
# - 最大页面数
```

**3. 快速模式（最小化配置）**
```bash
python3 cli/doc_scraper.py \
  --name react \
  --url https://react.dev/ \
  --description "React framework for building UIs"
```

**4. 试运行（预览）**
```bash
python3 cli/doc_scraper.py --config configs/react.json --dry-run
# 展示将会抓取的内容但不实际下载
# 不创建任何目录
# 快速校验
```

**5. 跳过抓取（使用缓存数据）**
```bash
python3 cli/doc_scraper.py --config configs/godot.json --skip-scrape
# 复用已有 output/godot_data/
# 快速重建（1-3 分钟）
# 适合测试改动
```

**6. 本地增强**
```bash
python3 cli/doc_scraper.py --config configs/react.json --enhance-local
# 抓取与增强一条命令完成
# 打开新终端运行 Claude Code
# 无需 API Key
```

**7. API 增强**
```bash
export ANTHROPIC_API_KEY=sk-ant-...
python3 cli/doc_scraper.py --config configs/react.json --enhance

# 或内联 API Key：
python3 cli/doc_scraper.py --config configs/react.json --enhance --api-key sk-ant-...
```

### 输出结构

```
output/
├── {name}_data/              # 抓取的原始数据（缓存）
│   ├── pages/
│   │   ├── page_0.json
│   │   ├── page_1.json
│   │   └── ...
│   └── summary.json          # 抓取统计
│
└── {name}/                   # 构建的技能目录
    ├── SKILL.md              # 主技能文件
    ├── SKILL.md.backup       # 备份（若执行增强）
    ├── references/           # 分类参考文档
    │   ├── index.md
    │   ├── getting_started.md
    │   ├── api.md
    │   └── ...
    ├── scripts/              # 为空（用户脚本）
    └── assets/               # 为空（用户资源）
```

---

## 估算器：estimate_pages.py

### 完整帮助

```
usage: estimate_pages.py [-h] [--max-discovery MAX_DISCOVERY]
                         [--timeout TIMEOUT]
                         config

为 Skill Seeker 配置估算页面数量

positional arguments:
  config                配置 JSON 文件路径

options:
  -h, --help            显示帮助并退出
  --max-discovery, -m MAX_DISCOVERY
                        最大发现页面数量（默认 1000）
  --timeout, -t TIMEOUT
                        HTTP 请求超时（默认 30 秒）
```

### 使用示例

**1. 快速估算（100 页）**
```bash
python3 cli/estimate_pages.py configs/react.json --max-discovery 100
# 时间：约 30-60 秒
# 适用：快速校验
```

**2. 标准估算（1000 页 - 默认）**
```bash
python3 cli/estimate_pages.py configs/godot.json
# 时间：约 1-2 分钟
# 适用：多数使用场景
```

**3. 深度估算（2000 页）**
```bash
python3 cli/estimate_pages.py configs/vue.json --max-discovery 2000
# 时间：约 3-5 分钟
# 适用：大型文档站点
```

**4. 自定义超时**
```bash
python3 cli/estimate_pages.py configs/django.json --timeout 60
# 适用于响应慢的服务器
```

### 输出示例

```
🔍 Estimating pages for: react
📍 Base URL: https://react.dev/
🎯 Start URLs: 6
⏱️  Rate limit: 0.5s
🔢 Max discovery: 1000

⏳ Discovered: 180 pages (1.3 pages/sec)

======================================================================
📊 ESTIMATION RESULTS
======================================================================

Config: react
Base URL: https://react.dev/

✅ Pages Discovered: 180
⏳ Pages Pending: 50
📈 Estimated Total: 230

⏱️  Time Elapsed: 140.5s
⚡ Discovery Rate: 1.28 pages/sec

======================================================================
💡 RECOMMENDATIONS
======================================================================

✅ Current max_pages (300) is sufficient

⏱️  Estimated full scrape time: 1.9 minutes
   (Based on rate_limit: 0.5s)
```

---

## 增强工具

### enhance_skill_local.py（推荐）

**无需 API Key — 使用 Claude Code Max 方案**

```bash
# 用法
python3 cli/enhance_skill_local.py output/react/
python3 cli/enhance_skill_local.py output/godot/

# 作用：
# 1. 读取 SKILL.md 与 references/
# 2. 打开新终端运行 Claude Code
# 3. 由 Claude 增强 SKILL.md
# 4. 将原始版本备份为 SKILL.md.backup
# 5. 保存增强版本

# 时间：约 60 秒
# 成本：免费（使用你的 Claude Code Max 方案）
```

### enhance_skill.py（备选）

**需要 Anthropic API Key**

```bash
# 预先安装依赖
pip3 install anthropic

# 环境变量方式
export ANTHROPIC_API_KEY=sk-ant-...
python3 cli/enhance_skill.py output/react/

# 内联方式
python3 cli/enhance_skill.py output/godot/ --api-key sk-ant-...

# 作用：
# 1. 读取 SKILL.md 与 references/
# 2. 调用 Claude API（Sonnet 4）
# 3. 增强 SKILL.md
# 4. 备份原始版至 SKILL.md.backup
# 5. 保存增强版本

# 时间：约 30-60 秒
# 成本：约 $0.01-0.10/技能（视大小而定）
```

---

## 打包工具

### package_skill.py

```bash
# 用法
python3 cli/package_skill.py output/react/
python3 cli/package_skill.py output/godot/

# 作用：
# 1. 校验 SKILL.md 是否存在
# 2. 将全部技能文件打包为 .zip
# 3. 输出到 output/{name}.zip

# 输出：
# output/react.zip
# output/godot.zip

# 时间：即时
```

---

## 测试工具

### run_tests.py

```bash
# 运行全部测试（默认）
python3 cli/run_tests.py
# 71 个测试，约 1 秒

# 详细输出
python3 cli/run_tests.py -v
python3 cli/run_tests.py --verbose

# 简洁输出
python3 cli/run_tests.py -q
python3 cli/run_tests.py --quiet

# 首个失败即停止
python3 cli/run_tests.py -f
python3 cli/run_tests.py --failfast

# 运行特定测试套件
python3 cli/run_tests.py --suite config
python3 cli/run_tests.py --suite features
python3 cli/run_tests.py --suite integration

# 列出全部测试
python3 cli/run_tests.py --list
```

### 单项测试

```bash
# 运行单个测试文件
python3 -m unittest tests.test_config_validation
python3 -m unittest tests.test_scraper_features
python3 -m unittest tests.test_integration

# 运行单个测试类
python3 -m unittest tests.test_config_validation.TestConfigValidation

# 运行单个测试方法
python3 -m unittest tests.test_config_validation.TestConfigValidation.test_valid_complete_config
```

---

## 可用配置

### 预设配置（即刻使用）

| Config | Framework | Pages | Description |
|--------|-----------|-------|-------------|
| `godot.json` | Godot Engine | ~500 | 游戏引擎文档 |
| `react.json` | React | ~300 | React 框架文档 |
| `vue.json` | Vue.js | ~250 | Vue.js 框架文档 |
| `django.json` | Django | ~400 | Django Web 框架 |
| `fastapi.json` | FastAPI | ~200 | FastAPI Python 框架 |
| `steam-economy-complete.json` | Steam | ~100 | Steam Economy API 文档 |

### 查看配置详情

```bash
# 列出所有配置
ls configs/

# 查看配置内容
cat configs/react.json
python3 -m json.tool configs/godot.json
```

### 配置结构

```json
{
  "name": "react",
  "base_url": "https://react.dev/",
  "description": "React - JavaScript library for building UIs",
  "start_urls": [
    "https://react.dev/learn",
    "https://react.dev/reference/react",
    "https://react.dev/reference/react-dom"
  ],
  "selectors": {
    "main_content": "article",
    "title": "h1",
    "code_blocks": "pre code"
  },
  "url_patterns": {
    "include": ["/learn/", "/reference/"],
    "exclude": ["/blog/", "/community/"]
  },
  "categories": {
    "getting_started": ["learn", "tutorial", "intro"],
    "api": ["reference", "api", "hooks"],
    "guides": ["guide"]
  },
  "rate_limit": 0.5,
  "max_pages": 300
}
```

---

## 常见工作流

### 工作流 1：使用预设（最快）

```bash
# 1. 估算（可选，1-2 分钟）
python3 cli/estimate_pages.py configs/react.json

# 2. 抓取并本地增强（约 25 分钟）
python3 cli/doc_scraper.py --config configs/react.json --enhance-local

# 3. 打包（即时）
python3 cli/package_skill.py output/react/

# 结果：output/react.zip
# 上传至 Claude！
```

### 工作流 2：自定义文档

```bash
# 1. 创建配置
cat > configs/my-docs.json << 'EOF'
{
  "name": "my-docs",
  "base_url": "https://docs.example.com/",
  "description": "My documentation site",
  "rate_limit": 0.5,
  "max_pages": 200
}
EOF

# 2. 估算
python3 cli/estimate_pages.py configs/my-docs.json

# 3. 试运行
python3 cli/doc_scraper.py --config configs/my-docs.json --dry-run

# 4. 全量抓取
python3 cli/doc_scraper.py --config configs/my-docs.json

# 5. 增强
python3 cli/enhance_skill_local.py output/my-docs/

# 6. 打包
python3 cli/package_skill.py output/my-docs/
```

### 工作流 3：交互模式

```bash
# 1. 启动交互向导
python3 cli/doc_scraper.py --interactive

# 2. 回答提示：
#    - Name: my-framework
#    - URL: https://framework.dev/
#    - Description: My favorite framework
#    - Selectors: （使用默认）
#    - Rate limit: 0.5
#    - Max pages: 100

# 3. 增强
python3 cli/enhance_skill_local.py output/my-framework/

# 4. 打包
python3 cli/package_skill.py output/my-framework/
```

### 工作流 4：快速模式

```bash
python3 cli/doc_scraper.py \
  --name vue \
  --url https://vuejs.org/ \
  --description "Vue.js framework" \
  --enhance-local
```

### 工作流 5：基于缓存重建

```bash
# 已抓取过？
# 跳过抓取，仅重建
python3 cli/doc_scraper.py --config configs/godot.json --skip-scrape

# 尝试新的增强
python3 cli/enhance_skill_local.py output/godot/

# 重新打包
python3 cli/package_skill.py output/godot/
```

### 工作流 6：测试新配置

```bash
# 1. 创建测试配置（较小 max_pages）
cat > configs/test.json << 'EOF'
{
  "name": "test-site",
  "base_url": "https://docs.test.com/",
  "max_pages": 20,
  "rate_limit": 0.1
}
EOF

# 2. 估算
python3 cli/estimate_pages.py configs/test.json --max-discovery 50

# 3. 试运行
python3 cli/doc_scraper.py --config configs/test.json --dry-run

# 4. 小规模抓取
python3 cli/doc_scraper.py --config configs/test.json

# 5. 校验输出
ls output/test-site/
ls output/test-site/references/

# 6. 若可用，再提高 max_pages 并重跑
```

---

## 故障排除

### 问题："Rate limit exceeded"

```bash
# 提高配置中的 rate_limit
{
  "rate_limit": 1.0
}
```

### 问题："Too many pages"

```bash
# 先估算
python3 cli/estimate_pages.py configs/my-config.json

# 根据估算设置合适的 max_pages（加 50 余量）
{
  "max_pages": 350
}
```

### 问题："No content extracted"

```bash
# 可能是选择器错误，先手工检查：
curl -s https://docs.example.com/ | grep -i 'article\|main\|content'

# 常见选择器：
"main_content": "article"
"main_content": "main"
"main_content": ".content"
"main_content": "#main-content"
"main_content": "div[role=\"main\"]"
```

### 问题："Tests failing"

```bash
# 仅运行失败的测试并查看详细输出
python3 -m unittest tests.test_config_validation.TestConfigValidation.test_name -v
```

### 问题："Enhancement fails"

```bash
# 本地增强：确保 Claude Code 正常运行，查看终端输出
# API 增强：确认 API Key 已设置
echo $ANTHROPIC_API_KEY
python3 cli/enhance_skill.py output/react/ --api-key sk-ant-...
```

### 问题："Package fails"

```bash
# 校验 SKILL.md 是否存在
ls output/my-skill/SKILL.md

# 若缺失，先执行构建：
python3 cli/doc_scraper.py --config configs/my-skill.json --skip-scrape
```

### 问题："Can't find output"

```bash
# 查看 output 目录
ls output/

# 技能数据（缓存）：
ls output/{name}_data/

# 构建的技能：
ls output/{name}/

# 打包文件：
ls output/{name}.zip
```

---

## 高级用法

### 自定义选择器

```json
{
  "selectors": {
    "main_content": "div.documentation",
    "title": "h1.page-title",
    "code_blocks": "pre.highlight code",
    "navigation": "nav.sidebar"
  }
}
```

### URL 模式过滤

```json
{
  "url_patterns": {
    "include": ["/docs/", "/guide/", "/api/", "/tutorial/"],
    "exclude": ["/blog/", "/news/", "/community/", "/showcase/"]
  }
}
```

### 自定义分类

```json
{
  "categories": {
    "getting_started": ["intro", "tutorial", "quickstart", "installation"],
    "core_concepts": ["concept", "fundamental", "architecture"],
    "api": ["reference", "api", "method", "function"],
    "guides": ["guide", "how-to", "example"],
    "advanced": ["advanced", "expert", "performance"]
  }
}
```

### 多个起始 URL

```json
{
  "start_urls": [
    "https://docs.example.com/getting-started/",
    "https://docs.example.com/api/",
    "https://docs.example.com/guides/",
    "https://docs.example.com/examples/"
  ]
}
```

---

## 性能建议

1. **先估算**：通过估算节省 20-40 分钟
2. **用试运行**：先验证选择器再抓取
3. **缓存数据**：使用 `--skip-scrape` 快速重建
4. **调整速率限制**：平衡速度与礼貌
5. **设置合理最大页数**：避免过度抓取
6. **使用起始 URL**：聚焦重要区域
7. **过滤 URL**：通过 include/exclude 控制范围
8. **运行测试**：尽早发现问题

---

## 环境变量

```bash
# Anthropic API Key（用于 API 增强）
export ANTHROPIC_API_KEY=sk-ant-...

# 可选：自定义输出目录
export SKILL_SEEKER_OUTPUT_DIR=/path/to/output
```

---

## 退出码

- `0`: 成功
- `1`: 一般错误
- `2`: 警告（估算达到上限）

---

## 文件位置

```
Skill_Seekers/
├── doc_scraper.py           # 主工具
├── estimate_pages.py        # 估算器
├── enhance_skill.py         # API 增强
├── enhance_skill_local.py   # 本地增强
├── package_skill.py         # 打包工具
├── run_tests.py             # 测试运行器
├── configs/                 # 预设配置
├── tests/                   # 测试套件
├── docs/                    # 文档
└── output/                  # 生成的输出
```

---

## 获取帮助

```bash
# 工具帮助
python3 cli/doc_scraper.py --help
python3 cli/estimate_pages.py --help
python3 cli/run_tests.py --help

# 文档
cat CLAUDE.md              # Claude Code 快速参考
cat docs/CLAUDE.md         # 技术文档
cat docs/TESTING.md        # 测试指南
cat docs/USAGE.md          # 本文件
cat docs/ENHANCEMENT.md    # 增强指南
cat docs/UPLOAD_GUIDE.md   # 上传说明
cat README.md              # 项目总览
```

---

## 总结

**核心命令：**
```bash
python3 cli/estimate_pages.py configs/react.json              # 估算
python3 cli/doc_scraper.py --config configs/react.json        # 抓取
python3 cli/enhance_skill_local.py output/react/              # 增强
python3 cli/package_skill.py output/react/                    # 打包
python3 cli/run_tests.py                                      # 测试
```

**快速开始：**
```bash
pip3 install requests beautifulsoup4
python3 cli/doc_scraper.py --config configs/react.json --enhance-local
python3 cli/package_skill.py output/react/
# 上传 output/react.zip 至 Claude！
```

祝你构建技能顺利！🚀
