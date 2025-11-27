# 统一的多源抓取

**版本：** 2.0（截至 2025-10 功能完备）

## 概览

统一的多源抓取允许你将来自多种来源的知识合并为一个完整的 Claude 技能。不必在“文档 / GitHub 仓库 / PDF 手册”之间二选一，你可以同时提取并智能合并这些来源的信息。

## 为什么需要统一抓取？

**问题：** 文档与代码随时间常常发生偏差。官方文档可能过时，遗漏代码中已存在的功能，或记录已删除的功能。单独抓取文档与代码会得到两个不完整的技能。

**解决：** 统一抓取：
- 从多个来源提取信息（文档、GitHub、PDF）
- **检测**文档与实际代码实现之间的冲突
- **智能合并**冲突信息并保持透明
- 使用内联警示（⚠️）**突出差异**
- 生成一个**完整技能**，呈现全貌

## 快速开始

### 1. 创建统一配置

Create a config file with multiple sources:

```json
{
  "name": "react",
  "description": "Complete React knowledge from docs + codebase",
  "merge_mode": "rule-based",
  "sources": [
    {
      "type": "documentation",
      "base_url": "https://react.dev/",
      "extract_api": true,
      "max_pages": 200
    },
    {
      "type": "github",
      "repo": "facebook/react",
      "include_code": true,
      "code_analysis_depth": "surface",
      "max_issues": 100
    }
  ]
}
```

### 2. 抓取并构建

```bash
python3 cli/unified_scraper.py --config configs/react_unified.json
```

The tool will:
1. ✅ **Phase 1**: Scrape all sources (docs + GitHub)
2. ✅ **Phase 2**: Detect conflicts between sources
3. ✅ **Phase 3**: Merge conflicts intelligently
4. ✅ **Phase 4**: Build unified skill with conflict transparency

### 3. 打包并上传

```bash
python3 cli/package_skill.py output/react/
```

## 配置格式

### 统一配置结构

```json
{
  "name": "skill-name",
  "description": "When to use this skill",
  "merge_mode": "rule-based|claude-enhanced",
  "sources": [
    {
      "type": "documentation|github|pdf",
      ...source-specific fields...
    }
  ]
}
```

### 文档来源

```json
{
  "type": "documentation",
  "base_url": "https://docs.example.com/",
  "extract_api": true,
  "selectors": {
    "main_content": "article",
    "title": "h1",
    "code_blocks": "pre code"
  },
  "url_patterns": {
    "include": [],
    "exclude": ["/blog/"]
  },
  "categories": {
    "getting_started": ["intro", "tutorial"],
    "api": ["api", "reference"]
  },
  "rate_limit": 0.5,
  "max_pages": 200
}
```

### GitHub 来源

```json
{
  "type": "github",
  "repo": "owner/repo",
  "github_token": "ghp_...",
  "include_issues": true,
  "max_issues": 100,
  "include_changelog": true,
  "include_releases": true,
  "include_code": true,
  "code_analysis_depth": "surface|deep|full",
  "file_patterns": [
    "src/**/*.js",
    "lib/**/*.ts"
  ]
}
```

**代码分析深度：**
- `surface`（默认）：基础结构，不分析代码
- `deep`：提取类/函数签名、参数、返回类型
- `full`：完整 AST 分析（开销大）

### PDF 来源

```json
{
  "type": "pdf",
  "path": "/path/to/manual.pdf",
  "extract_tables": false,
  "ocr": false,
  "password": "optional-password"
}
```

## 冲突检测

统一抓取器会自动检测 4 类冲突：

### 1. 文档缺失

**严重性：**中
**描述：**代码中存在该 API，但文档未提及

**Example**:
```python
# Code has this method:
def move_local_x(self, delta: float, snap: bool = False) -> None:
    """Move node along local X axis"""

# But documentation doesn't mention it
```

**建议：**补充文档

### 2. 代码缺失

**严重性：**高
**描述：**文档中存在该 API，但代码库中不存在

**Example**:
```python
# Docs say:
def rotate(angle: float) -> None

# But code doesn't have this function
```

**建议：**更新文档删除该 API，或在代码中补齐

### 3. 签名不匹配

**严重性：**中-高
**描述：**文档与代码均存在该 API，但签名不同

**Example**:
```python
# Docs say:
def move_local_x(delta: float)

# Code has:
def move_local_x(delta: float, snap: bool = False)
```

**建议：**更新文档以匹配实际签名

### 4. 描述不匹配

**Severity**: Low
**Description**: Different descriptions/docstrings

## 合并模式

### 规则合并（默认）

Fast, deterministic merging using predefined rules:

1. **If API only in docs** → Include with `[DOCS_ONLY]` tag
2. **If API only in code** → Include with `[UNDOCUMENTED]` tag
3. **If both match perfectly** → Include normally
4. **If conflict exists** → Prefer code signature, keep docs description

**适用场景：**
- 快速合并（<1 秒）
- 自动化工作流
- 不需要人工审校

**Example**:
```bash
python3 cli/unified_scraper.py --config config.json --merge-mode rule-based
```

### Claude 增强合并

AI-powered reconciliation using local Claude Code:

1. Opens new terminal with Claude Code
2. Provides conflict context and instructions
3. Claude analyzes and creates reconciled API reference
4. Human can review and adjust before finalizing

**适用场景：**
- 复杂冲突需要判断
- 追求最高质量的合并
- 有时间进行人工审校

**Example**:
```bash
python3 cli/unified_scraper.py --config config.json --merge-mode claude-enhanced
```

## 技能输出结构

The unified scraper creates this structure:

```
output/skill-name/
├── SKILL.md                     # Main skill file with merged APIs
├── references/
│   ├── documentation/           # Documentation references
│   │   └── index.md
│   ├── github/                  # GitHub references
│   │   ├── README.md
│   │   ├── issues.md
│   │   └── releases.md
│   ├── pdf/                     # PDF references (if applicable)
│   │   └── index.md
│   ├── api/                     # Merged API reference
│   │   └── merged_api.md
│   └── conflicts.md             # Detailed conflict report
├── scripts/                     # Empty (for user scripts)
└── assets/                      # Empty (for user assets)
```

### SKILL.md 格式

```markdown
# React

Complete React knowledge base combining official documentation and React codebase insights.

## 📚 Sources

This skill combines knowledge from multiple sources:

- ✅ **Documentation**: https://react.dev/
  - Pages: 200
- ✅ **GitHub Repository**: facebook/react
  - Code Analysis: surface
  - Issues: 100

## ⚠️ Data Quality

**5 conflicts detected** between sources.

**Conflict Breakdown:**
- missing_in_docs: 3
- missing_in_code: 2

See `references/conflicts.md` for detailed conflict information.

## 🔧 API Reference

*Merged from documentation and code analysis*

### ✅ Verified APIs

*Documentation and code agree*

#### `useState(initialValue)`

...

### ⚠️ APIs with Conflicts

*Documentation and code differ*

#### `useEffect(callback, deps?)`

⚠️ **Conflict**: Documentation signature differs from code implementation

**Documentation says:**
```
useEffect(callback: () => void, deps: any[])
```

**Code implementation:**
```
useEffect(callback: () => void | (() => void), deps?: readonly any[])
```

*Source: both*

---
```

## 示例

### 示例 1：React（文档 + GitHub）

```json
{
  "name": "react",
  "description": "Complete React framework knowledge",
  "merge_mode": "rule-based",
  "sources": [
    {
      "type": "documentation",
      "base_url": "https://react.dev/",
      "extract_api": true,
      "max_pages": 200
    },
    {
      "type": "github",
      "repo": "facebook/react",
      "include_code": true,
      "code_analysis_depth": "surface"
    }
  ]
}
```

### 示例 2：Django（文档 + GitHub）

```json
{
  "name": "django",
  "description": "Complete Django framework knowledge",
  "merge_mode": "rule-based",
  "sources": [
    {
      "type": "documentation",
      "base_url": "https://docs.djangoproject.com/en/stable/",
      "extract_api": true,
      "max_pages": 300
    },
    {
      "type": "github",
      "repo": "django/django",
      "include_code": true,
      "code_analysis_depth": "deep",
      "file_patterns": [
        "django/db/**/*.py",
        "django/views/**/*.py"
      ]
    }
  ]
}
```

### 示例 3：混合来源（文档 + GitHub + PDF）

```json
{
  "name": "godot",
  "description": "Complete Godot Engine knowledge",
  "merge_mode": "claude-enhanced",
  "sources": [
    {
      "type": "documentation",
      "base_url": "https://docs.godotengine.org/en/stable/",
      "extract_api": true,
      "max_pages": 500
    },
    {
      "type": "github",
      "repo": "godotengine/godot",
      "include_code": true,
      "code_analysis_depth": "deep"
    },
    {
      "type": "pdf",
      "path": "/path/to/godot_manual.pdf",
      "extract_tables": true
    }
  ]
}
```

## 命令参考

### 统一抓取器

```bash
# Basic usage
python3 cli/unified_scraper.py --config configs/react_unified.json

# Override merge mode
python3 cli/unified_scraper.py --config configs/react_unified.json --merge-mode claude-enhanced

# Use cached data (skip re-scraping)
python3 cli/unified_scraper.py --config configs/react_unified.json --skip-scrape
```

### 校验配置

```bash
python3 -c "
import sys
sys.path.insert(0, 'cli')
from config_validator import validate_config

validator = validate_config('configs/react_unified.json')
print(f'Format: {\"Unified\" if validator.is_unified else \"Legacy\"}')
print(f'Sources: {len(validator.config.get(\"sources\", []))}')
print(f'Needs API merge: {validator.needs_api_merge()}')
"
```

## MCP 集成

统一抓取器已完全集成 MCP。`scrape_docs` 工具会自动检测统一/传统配置并路由到相应抓取器。

```python
# MCP tool usage
{
  "name": "scrape_docs",
  "arguments": {
    "config_path": "configs/react_unified.json",
    "merge_mode": "rule-based"  # Optional override
  }
}
```

The tool will:
1. Auto-detect unified format
2. Route to `unified_scraper.py`
3. Apply specified merge mode
4. Return comprehensive output

## 向后兼容

**传统配置仍然有效！** 系统会自动检测传统的单源配置并路由到原始 `doc_scraper.py`。

```json
// Legacy config (still works)
{
  "name": "react",
  "base_url": "https://react.dev/",
  ...
}

// Automatically detected as legacy format
// Routes to doc_scraper.py
```

## 测试

Run integration tests:

```bash
python3 cli/test_unified_simple.py
```

Tests validate:
- ✅ Unified config validation
- ✅ Backward compatibility with legacy configs
- ✅ Mixed source type support
- ✅ Error handling for invalid configs

## 架构

### 组件

1. **config_validator.py**: Validates unified and legacy configs
2. **code_analyzer.py**: Extracts code signatures at configurable depth
3. **conflict_detector.py**: Detects API conflicts between sources
4. **merge_sources.py**: Implements rule-based and Claude-enhanced merging
5. **unified_scraper.py**: Main orchestrator
6. **unified_skill_builder.py**: Generates final skill structure
7. **skill_seeker_mcp/server.py**: MCP integration with auto-detection

### 数据流

```
Unified Config
     ↓
ConfigValidator (validates format)
     ↓
UnifiedScraper.run()
     ↓
┌────────────────────────────────────┐
│ Phase 1: Scrape All Sources        │
│  - Documentation → doc_scraper     │
│  - GitHub → github_scraper         │
│  - PDF → pdf_scraper               │
└────────────────────────────────────┘
     ↓
┌────────────────────────────────────┐
│ Phase 2: Detect Conflicts          │
│  - ConflictDetector                │
│  - Compare docs APIs vs code APIs  │
│  - Classify by type and severity   │
└────────────────────────────────────┘
     ↓
┌────────────────────────────────────┐
│ Phase 3: Merge Sources              │
│  - RuleBasedMerger (fast)          │
│  - OR ClaudeEnhancedMerger (AI)    │
│  - Create unified API reference    │
└────────────────────────────────────┘
     ↓
┌────────────────────────────────────┐
│ Phase 4: Build Skill                │
│  - UnifiedSkillBuilder             │
│  - Generate SKILL.md with conflicts│
│  - Create reference structure      │
│  - Generate conflicts report       │
└────────────────────────────────────┘
     ↓
Unified Skill (.zip ready)
```

## 最佳实践

### 1. 先使用规则合并

Rule-based is fast and works well for most cases. Only use Claude-enhanced if you need human oversight.

### 2. 使用浅层代码分析

`code_analysis_depth: "surface"` is usually sufficient. Deep analysis is expensive and rarely needed.

### 3. 限制 GitHub Issues 数量

`max_issues: 100` is a good default. More than 200 issues rarely adds value.

### 4. 文件模式尽量具体

```json
"file_patterns": [
  "src/**/*.js",     // Good: specific paths
  "lib/**/*.ts"
]

// Not recommended:
"file_patterns": ["**/*.js"]  // Too broad, slow
```

### 5. 关注冲突报告

Always review `references/conflicts.md` to understand discrepancies between sources.

## 故障排除

### 未检测到冲突

**Possible causes**:
- `extract_api: false` in documentation source
- `include_code: false` in GitHub source
- Code analysis found no APIs (check `code_analysis_depth`)

**Solution**: Ensure both sources have API extraction enabled

### 冲突过多

**Possible causes**:
- Fuzzy matching threshold too strict
- Documentation uses different naming conventions
- Old documentation version

**Solution**: Review conflicts manually and adjust merge strategy

### 合并耗时过长

**Possible causes**:
- Using `code_analysis_depth: "full"` (very slow)
- Too many file patterns
- Large repository

**Solution**:
- Use `"surface"` or `"deep"` analysis
- Narrow file patterns
- Increase `rate_limit`

## 未来增强

Planned features:
- [ ] Automated conflict resolution strategies
- [ ] Conflict trend analysis across versions
- [ ] Multi-version comparison (docs v1 vs v2)
- [ ] Custom merge rules DSL
- [ ] Conflict confidence scores

## 支持

For issues, questions, or suggestions:
- GitHub Issues: https://github.com/yusufkaraaslan/Skill_Seekers/issues
- Documentation: https://github.com/yusufkaraaslan/Skill_Seekers/docs

## 更新日志

**v2.0 (October 2025)**: Unified multi-source scraping feature complete
- ✅ Config validation for unified format
- ✅ Deep code analysis with AST parsing
- ✅ Conflict detection (4 types, 3 severity levels)
- ✅ Rule-based merging
- ✅ Claude-enhanced merging
- ✅ Unified skill builder with inline conflict warnings
- ✅ MCP integration with auto-detection
- ✅ Backward compatibility with legacy configs
- ✅ Comprehensive tests and documentation
