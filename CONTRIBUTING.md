# 为 Skill Seeker 做贡献

首先，感谢你愿意为 Skill Seeker 贡献！正是因为有你的参与，项目才能不断变得更好。

## 目录

- [分支工作流](#分支工作流)
- [行为准则](#行为准则)
- [我可以如何贡献](#我可以如何贡献)
- [开发环境搭建](#开发环境搭建)
- [拉取请求流程](#拉取请求流程)
- [编码规范](#编码规范)
- [测试](#测试)
- [文档](#文档)

---

## 分支工作流

**⚠️ 重要：**Skill Seekers 采用双分支工作流。

### 分支结构

```
main（生产）
  ↑
  │（仅维护者合并）
  │
development（集成） ← PR 默认目标分支
  ↑
  │（所有贡献者的 PR 进入此分支）
  │
feature 分支
```

### 分支说明

- **`main`** - 生产分支
  - 保持稳定
  - 仅由维护者从 `development` 合并
  - 受保护：需测试通过 + 至少 1 次评审

- **`development`** - 集成分支
  - **所有 PR 的默认目标分支**
  - 活跃开发发生在此分支
  - 受保护：需测试通过
  - 由维护者合并到 `main`

- **Feature 分支** - 你的工作分支
  - 从 `development` 创建
  - 使用描述性名称（如 `add-github-scraping`）
  - 通过 PR 合并回 `development`

### 工作流示例

```bash
# 1. Fork 并克隆
git clone https://github.com/YOUR_USERNAME/Skill_Seekers.git
cd Skill_Seekers

# 2. 添加上游
git remote add upstream https://github.com/yusufkaraaslan/Skill_Seekers.git

# 3. 从 development 创建功能分支
git checkout development
git pull upstream development
git checkout -b my-feature

# 4. 修改、提交并推送
git add .
git commit -m "Add my feature"
git push origin my-feature

# 5. 创建 PR，目标指向 'development' 分支
```

---

## 行为准则

本项目及所有参与者承诺营造开放、友好的环境。请在所有交流中保持尊重与建设性。

---

## 我可以如何贡献

### 报告缺陷

在创建缺陷报告前，请先查看 [现有 Issues](https://github.com/yusufkaraaslan/Skill_Seekers/issues) 以避免重复。

创建缺陷报告时，请包含：
- **清晰的标题与描述**
- **复现步骤**
- **期望行为** 与 **实际行为**
- **截图**（如适用）
- **环境信息**（OS、Python 版本等）
- **错误信息** 与堆栈

**示例：**
```markdown
**Bug:** MCP tool fails when config has no categories

**Steps to Reproduce:**
1. Create config with empty categories: `"categories": {}`
2. Run `python3 cli/doc_scraper.py --config configs/test.json`
3. See error

**Expected:** Should use auto-inferred categories
**Actual:** Crashes with KeyError

**Environment:**
- OS: Ubuntu 22.04
- Python: 3.10.5
- Version: 1.0.0
```

### 建议改进

改进建议通过 [GitHub Issues](https://github.com/yusufkaraaslan/Skill_Seekers/issues) 进行跟踪。

请包含：
- **清晰标题** 描述改进点
- **详细说明** 拟新增功能
- **使用场景** 与收益
- **工作方式** 示例
- **已考虑的替代方案**

### 添加新的框架配置

欢迎贡献新的框架配置！步骤如下：

1. Create a config file in `configs/`
2. Test it thoroughly with different page counts
3. Submit a PR with:
   - The config file
   - Brief description of the framework
   - Test results (number of pages scraped, categories found)

**示例 PR：**
```markdown
**Add Svelte Documentation Config**

Adds configuration for Svelte documentation (https://svelte.dev/docs).

- Config: `configs/svelte.json`
- Tested with max_pages: 100
- Successfully categorized: getting_started, components, api, advanced
- Total pages available: ~150
```

### 拉取请求（PR）

我们非常欢迎你的 PR！

**⚠️ 重要：**所有 PR 必须指向 `development`，不要指向 `main`。

1. Fork the repo and create your branch from `development`
2. If you've added code, add tests
3. If you've changed APIs, update the documentation
4. Ensure the test suite passes
5. Make sure your code follows our coding standards
6. Issue that pull request to `development` branch!

---

## 开发环境搭建

### 前置条件

- Python 3.10 或更高（用于 MCP 集成）
- Git

### 设置步骤

1. **Fork and clone the repository**
   ```bash
   git clone https://github.com/YOUR_USERNAME/Skill_Seekers.git
   cd Skill_Seekers
   ```

2. **安装依赖**
   ```bash
   pip install requests beautifulsoup4
   pip install pytest pytest-cov
   pip install -r mcp/requirements.txt
   ```

3. **从 development 创建功能分支**
   ```bash
   git checkout development
   git pull upstream development
   git checkout -b feature/my-awesome-feature
   ```

4. **进行修改**
   ```bash
   # Edit files...
   ```

5. **运行测试**
   ```bash
   python -m pytest tests/ -v
   ```

6. **提交变更**
   ```bash
   git add .
   git commit -m "Add awesome feature"
   ```

7. **推送到你的 fork**
   ```bash
   git push origin feature/my-awesome-feature
   ```

8. **创建拉取请求（PR）**

---

## 拉取请求流程

### 提交前检查

- [ ] 本地测试通过（`python -m pytest tests/ -v`）
- [ ] 代码遵循 PEP 8 风格
- [ ] 需要时已更新文档
- [ ] 更新了 CHANGELOG.md（如适用）
- [ ] 提交信息清晰且具描述性

### PR 模板

```markdown
## 描述
简要说明此 PR 的作用。

## 变更类型
- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## 测试说明
描述你为验证变更所运行的测试。

## 检查清单
- [ ] My code follows the style guidelines of this project
- [ ] I have performed a self-review of my own code
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] I have made corresponding changes to the documentation
- [ ] My changes generate no new warnings
- [ ] I have added tests that prove my fix is effective or that my feature works
- [ ] New and existing unit tests pass locally with my changes
```

### 评审流程

1. 维护者将在 3-5 个工作日内评审你的 PR
2. 你需处理反馈或变更请求
3. 评审通过后，维护者将合并 PR
4. 你的贡献会被纳入下一次发布！

---

## 编码规范

### Python 风格指南

遵循 [PEP 8](https://www.python.org/dev/peps/pep-0008/) 并做少量修改：

- **Line length:** 100 characters (not 79)
- **Indentation:** 4 spaces
- **Quotes:** Double quotes for strings
- **Naming:**
  - Functions/variables: `snake_case`
  - Classes: `PascalCase`
  - Constants: `UPPER_SNAKE_CASE`

### 代码组织

```python
# 1. Standard library imports
import os
import sys
from pathlib import Path

# 2. Third-party imports
import requests
from bs4 import BeautifulSoup

# 3. Local application imports
from cli.utils import open_folder

# 4. Constants
MAX_PAGES = 1000
DEFAULT_RATE_LIMIT = 0.5

# 5. Functions and classes
def my_function():
    """Docstring describing what this function does."""
    pass
```

### 文档要求

- 所有函数应有 docstring
- 适当使用类型标注
- 复杂逻辑需添加注释

```python
def scrape_page(url: str, selectors: dict) -> dict:
    """
    Scrape a single page and extract content.

    Args:
        url: The URL to scrape
        selectors: Dictionary of CSS selectors

    Returns:
        Dictionary containing extracted content

    Raises:
        RequestException: If page cannot be fetched
    """
    pass
```

---

## 测试

### 运行测试

```bash
# Run all tests
python -m pytest tests/ -v

# Run specific test file
python -m pytest tests/test_mcp_server.py -v

# Run with coverage
python -m pytest tests/ --cov=cli --cov=mcp --cov-report=term
```

### 编写测试

- Tests go in the `tests/` directory
- Test files should start with `test_`
- Use descriptive test names

```python
def test_config_validation_with_missing_fields():
    """Test that config validation fails when required fields are missing."""
    config = {"name": "test"}  # Missing base_url
    result = validate_config(config)
    assert result is False
```

### 覆盖率目标

- Aim for >80% code coverage
- Critical paths should have 100% coverage
- Add tests for bug fixes to prevent regressions

---

## 文档

### 文档位置

- **README.md** - Overview, quick start, basic usage
- **docs/** - Detailed guides and tutorials
- **CHANGELOG.md** - All notable changes
- **Code comments** - Complex logic and non-obvious decisions

### 文档风格

- Use clear, simple language
- Include code examples
- Add screenshots for UI-related features
- Keep it up to date with code changes

---

## 项目结构

```
Skill_Seekers/
├── cli/                    # CLI tools
│   ├── doc_scraper.py     # Main scraper
│   ├── package_skill.py   # Packager
│   ├── upload_skill.py    # Uploader
│   └── utils.py           # Shared utilities
├── mcp/                   # MCP server
│   ├── server.py          # MCP implementation
│   └── requirements.txt   # MCP dependencies
├── configs/               # Framework configs
├── docs/                  # Documentation
├── tests/                 # Test suite
└── .github/              # GitHub config
    └── workflows/         # CI/CD workflows
```

---

## 发布流程

版本发布由维护者管理：

1. Update version in relevant files
2. Update CHANGELOG.md
3. Create and push version tag
4. GitHub Actions will create the release
5. Announce on relevant channels

---

## 有问题？

- 💬 [发起讨论](https://github.com/yusufkaraaslan/Skill_Seekers/discussions)
- 🐛 [报告缺陷](https://github.com/yusufkaraaslan/Skill_Seekers/issues)
- 📧 联系方式：yusufkaraaslan.yk@pm.me

---

## 贡献致谢

贡献者将被收录于：
- README.md 的贡献者章节
- 每次发布的 CHANGELOG.md
- GitHub Contributors 页面

感谢你为 Skill Seeker 做出贡献！🎉
