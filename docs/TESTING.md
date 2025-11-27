# Skill Seeker 测试指南（中文唯一版本）

Skill Seeker 项目的综合测试文档。

## 快速开始

```bash
# Run all tests
python3 run_tests.py

# Run all tests with verbose output
python3 run_tests.py -v

# Run specific test suite
python3 run_tests.py --suite config
python3 run_tests.py --suite features
python3 run_tests.py --suite integration

# Stop on first failure
python3 run_tests.py --failfast

# List all available tests
python3 run_tests.py --list
```

## 测试结构

```
tests/
├── __init__.py                          # Test package marker
├── test_config_validation.py            # Config validation tests (30+ tests)
├── test_scraper_features.py             # Core feature tests (25+ tests)
├── test_integration.py                  # Integration tests (15+ tests)
├── test_pdf_extractor.py                # PDF extraction tests (23 tests)
├── test_pdf_scraper.py                  # PDF workflow tests (18 tests)
└── test_pdf_advanced_features.py        # PDF advanced features (26 tests) NEW
```

## 测试套件

### 1. 配置校验测试（`test_config_validation.py`）

Tests the `validate_config()` function with comprehensive coverage.

测试类别：
- ✅ Valid configurations (minimal and complete)
- ✅ Missing required fields (`name`, `base_url`)
- ✅ Invalid name formats (special characters)
- ✅ Valid name formats (alphanumeric, hyphens, underscores)
- ✅ Invalid URLs (missing protocol)
- ✅ Valid URL protocols (http, https)
- ✅ Selector validation (structure and recommended fields)
- ✅ URL patterns validation (include/exclude lists)
- ✅ Categories validation (structure and keywords)
- ✅ Rate limit validation (range 0-10, type checking)
- ✅ Max pages validation (range 1-10000, type checking)
- ✅ Start URLs validation (format and protocol)

示例测试：
```python
def test_valid_complete_config(self):
    """Test valid complete configuration"""
    config = {
        'name': 'godot',
        'base_url': 'https://docs.godotengine.org/en/stable/',
        'selectors': {
            'main_content': 'div[role="main"]',
            'title': 'title',
            'code_blocks': 'pre code'
        },
        'rate_limit': 0.5,
        'max_pages': 500
    }
    errors = validate_config(config)
    self.assertEqual(len(errors), 0)
```

运行：
```bash
python3 run_tests.py --suite config -v
```

---

### 2. 抓取功能测试（`test_scraper_features.py`）

Tests core scraper functionality including URL validation, language detection, pattern extraction, and categorization.

测试类别：

URL 校验：
- ✅ URL matching include patterns
- ✅ URL matching exclude patterns
- ✅ Different domain rejection
- ✅ No pattern configuration

语言检测：
- ✅ Detection from CSS classes (`language-*`, `lang-*`)
- ✅ Detection from parent elements
- ✅ Python detection (import, from, def)
- ✅ JavaScript detection (const, let, arrow functions)
- ✅ GDScript detection (func, var)
- ✅ C++ detection (#include, int main)
- ✅ Unknown language fallback

模式抽取：
- ✅ Extraction with "Example:" marker
- ✅ Extraction with "Usage:" marker
- ✅ Pattern limit (max 5)

分类：
- ✅ Categorization by URL keywords
- ✅ Categorization by title keywords
- ✅ Categorization by content keywords
- ✅ Fallback to "other" category
- ✅ Empty category removal

文本清洗：
- ✅ Multiple spaces normalization
- ✅ Newline normalization
- ✅ Tab normalization
- ✅ Whitespace stripping

示例测试：
```python
def test_detect_python_from_heuristics(self):
    """Test Python detection from code content"""
    html = '<code>import os\nfrom pathlib import Path</code>'
    elem = BeautifulSoup(html, 'html.parser').find('code')
    lang = self.converter.detect_language(elem, elem.get_text())
    self.assertEqual(lang, 'python')
```

运行：
```bash
python3 run_tests.py --suite features -v
```

---

### 3. 集成测试（`test_integration.py`）

Tests complete workflows and interactions between components.

测试类别：

Dry-Run 模式：
- ✅ No directories created in dry-run mode
- ✅ Dry-run flag properly set
- ✅ Normal mode creates directories

配置加载：
- ✅ Load valid configuration files
- ✅ Invalid JSON error handling
- ✅ Nonexistent file error handling
- ✅ Validation errors during load

真实配置校验：
- ✅ Godot config validation
- ✅ React config validation
- ✅ Vue config validation
- ✅ Django config validation
- ✅ FastAPI config validation
- ✅ Steam Economy config validation

URL 处理：
- ✅ URL normalization
- ✅ Start URLs fallback to base_url
- ✅ Multiple start URLs handling

内容提取：
- ✅ Empty content handling
- ✅ Basic content extraction
- ✅ Code sample extraction with language detection

示例测试：
```python
def test_dry_run_no_directories_created(self):
    """Test that dry-run mode doesn't create directories"""
    converter = DocToSkillConverter(self.config, dry_run=True)

    data_dir = Path(f"output/{self.config['name']}_data")
    skill_dir = Path(f"output/{self.config['name']}")

    self.assertFalse(data_dir.exists())
    self.assertFalse(skill_dir.exists())
```

运行：
```bash
python3 run_tests.py --suite integration -v
```

---

### 4. PDF 提取测试（`test_pdf_extractor.py`）【新增】

Tests PDF content extraction functionality (B1.2-B1.5).

说明：该套件需要 PyMuPDF（`pip install PyMuPDF`）；未安装时自动跳过。

测试类别：

**Language Detection (5 tests):**
- ✅ Python detection with confidence scoring
- ✅ JavaScript detection with confidence
- ✅ C++ detection with confidence
- ✅ Unknown language returns low confidence
- ✅ Confidence always between 0 and 1

**Syntax Validation (5 tests):**
- ✅ Valid Python syntax validation
- ✅ Invalid Python indentation detection
- ✅ Unbalanced brackets detection
- ✅ Valid JavaScript syntax validation
- ✅ Natural language fails validation

**Quality Scoring (4 tests):**
- ✅ Quality score between 0 and 10
- ✅ High-quality code gets good score (>7)
- ✅ Low-quality code gets low score (<4)
- ✅ Quality considers multiple factors

**Chapter Detection (4 tests):**
- ✅ Detect chapters with numbers
- ✅ Detect uppercase chapter headers
- ✅ Detect section headings (e.g., "2.1")
- ✅ Normal text not detected as chapter

**Code Block Merging (2 tests):**
- ✅ Merge code blocks split across pages
- ✅ Don't merge different languages

**Code Detection Methods (2 tests):**
- ✅ Pattern-based detection (keywords)
- ✅ Indent-based detection

**Quality Filtering (1 test):**
- ✅ Filter by minimum quality threshold

示例测试：
```python
def test_detect_python_with_confidence(self):
    """Test Python detection returns language and confidence"""
    extractor = self.PDFExtractor.__new__(self.PDFExtractor)
    code = "def hello():\n    print('world')\n    return True"

    language, confidence = extractor.detect_language_from_code(code)

    self.assertEqual(language, "python")
    self.assertGreater(confidence, 0.7)
    self.assertLessEqual(confidence, 1.0)
```

运行：
```bash
python3 -m pytest tests/test_pdf_extractor.py -v
```

---

### 5. PDF 工作流测试（`test_pdf_scraper.py`）【新增】

Tests PDF to skill conversion workflow (B1.6).

说明：需要 PyMuPDF；未安装时自动跳过。

测试类别：

**PDFToSkillConverter (3 tests):**
- ✅ Initialization with name and PDF path
- ✅ Initialization with config file
- ✅ Requires name or config_path

**Categorization (3 tests):**
- ✅ Categorize by keywords
- ✅ Categorize by chapters
- ✅ Handle missing chapters

**Skill Building (3 tests):**
- ✅ Create required directory structure
- ✅ Create SKILL.md with metadata
- ✅ Create reference files for categories

**Code Block Handling (2 tests):**
- ✅ Include code blocks in references
- ✅ Prefer high-quality code

**Image Handling (2 tests):**
- ✅ Save images to assets directory
- ✅ Reference images in markdown

**Error Handling (3 tests):**
- ✅ Handle missing PDF files
- ✅ Handle invalid config JSON
- ✅ Handle missing required config fields

**JSON Workflow (2 tests):**
- ✅ Load from extracted JSON
- ✅ Build from JSON without extraction

示例测试：
```python
def test_build_skill_creates_structure(self):
    """Test that build_skill creates required directory structure"""
    converter = self.PDFToSkillConverter(
        name="test_skill",
        pdf_path="test.pdf",
        output_dir=self.temp_dir
    )

    converter.extracted_data = {
        "pages": [{"page_number": 1, "text": "Test", "code_blocks": [], "images": []}],
        "total_pages": 1
    }
    converter.categories = {"test": [converter.extracted_data["pages"][0]]}

    converter.build_skill()

    skill_dir = Path(self.temp_dir) / "test_skill"
    self.assertTrue(skill_dir.exists())
    self.assertTrue((skill_dir / "references").exists())
    self.assertTrue((skill_dir / "scripts").exists())
    self.assertTrue((skill_dir / "assets").exists())
```

运行：
```bash
python3 -m pytest tests/test_pdf_scraper.py -v
```

---

### 6. PDF 高级特性测试（`test_pdf_advanced_features.py`）【新增】

Tests advanced PDF features (Priority 2 & 3).

说明：需要 PyMuPDF；OCR 测试还需 pytesseract 与 Pillow。未安装时自动跳过。

测试类别：

**OCR Support (5 tests):**
- ✅ OCR flag initialization
- ✅ OCR disabled behavior
- ✅ OCR only triggers for minimal text
- ✅ Warning when pytesseract unavailable
- ✅ OCR extraction triggered correctly

**Password Protection (4 tests):**
- ✅ Password parameter initialization
- ✅ Encrypted PDF detection
- ✅ Wrong password handling
- ✅ Missing password error

**Table Extraction (5 tests):**
- ✅ Table extraction flag initialization
- ✅ No extraction when disabled
- ✅ Basic table extraction
- ✅ Multiple tables per page
- ✅ Error handling during extraction

**Caching (5 tests):**
- ✅ Cache initialization
- ✅ Set and get cached values
- ✅ Cache miss returns None
- ✅ Caching can be disabled
- ✅ Cache overwrite

**Parallel Processing (4 tests):**
- ✅ Parallel flag initialization
- ✅ Disabled by default
- ✅ Worker count auto-detection
- ✅ Custom worker count

**Integration (3 tests):**
- ✅ Full initialization with all features
- ✅ Various feature combinations
- ✅ Page data includes tables

示例测试：
```python
def test_table_extraction_basic(self):
    """Test basic table extraction"""
    extractor = self.PDFExtractor.__new__(self.PDFExtractor)
    extractor.extract_tables = True
    extractor.verbose = False

    # Create mock table
    mock_table = Mock()
    mock_table.extract.return_value = [
        ["Header 1", "Header 2", "Header 3"],
        ["Data 1", "Data 2", "Data 3"]
    ]
    mock_table.bbox = (0, 0, 100, 100)

    mock_tables = Mock()
    mock_tables.tables = [mock_table]

    mock_page = Mock()
    mock_page.find_tables.return_value = mock_tables

    tables = extractor.extract_tables_from_page(mock_page)

    self.assertEqual(len(tables), 1)
    self.assertEqual(tables[0]['row_count'], 2)
    self.assertEqual(tables[0]['col_count'], 3)
```

运行：
```bash
python3 -m pytest tests/test_pdf_advanced_features.py -v
```

---

## 测试运行器特性

The custom test runner (`run_tests.py`) provides:

### 彩色输出
- 🟢 Green for passing tests
- 🔴 Red for failures and errors
- 🟡 Yellow for skipped tests

### 详细摘要
```
======================================================================
TEST SUMMARY
======================================================================

Total Tests: 70
✓ Passed: 68
✗ Failed: 2
⊘ Skipped: 0

Success Rate: 97.1%

Test Breakdown by Category:
  TestConfigValidation: 28/30 passed
  TestURLValidation: 6/6 passed
  TestLanguageDetection: 10/10 passed
  TestPatternExtraction: 3/3 passed
  TestCategorization: 5/5 passed
  TestDryRunMode: 3/3 passed
  TestConfigLoading: 4/4 passed
  TestRealConfigFiles: 6/6 passed
  TestContentExtraction: 3/3 passed

======================================================================
```

### 命令行选项

```bash
# Verbose output (show each test name)
python3 run_tests.py -v

# Quiet output (minimal)
python3 run_tests.py -q

# Stop on first failure
python3 run_tests.py --failfast

# Run specific suite
python3 run_tests.py --suite config

# List all tests
python3 run_tests.py --list
```

---

## 运行单项测试

### 运行单个测试文件
```bash
python3 -m unittest tests.test_config_validation
python3 -m unittest tests.test_scraper_features
python3 -m unittest tests.test_integration
```

### 运行单个测试类
```bash
python3 -m unittest tests.test_config_validation.TestConfigValidation
python3 -m unittest tests.test_scraper_features.TestLanguageDetection
```

### 运行单个测试方法
```bash
python3 -m unittest tests.test_config_validation.TestConfigValidation.test_valid_complete_config
python3 -m unittest tests.test_scraper_features.TestLanguageDetection.test_detect_python_from_heuristics
```

---

## 测试覆盖率

### 当前覆盖率

| Component | Tests | Coverage |
|-----------|-------|----------|
| Config Validation | 30+ | 100% |
| URL Validation | 6 | 95% |
| Language Detection | 10 | 90% |
| Pattern Extraction | 3 | 85% |
| Categorization | 5 | 90% |
| Text Cleaning | 4 | 100% |
| Dry-Run Mode | 3 | 100% |
| Config Loading | 4 | 95% |
| Real Configs | 6 | 100% |
| Content Extraction | 3 | 80% |
| **PDF Extraction** | **23** | **90%** |
| **PDF Workflow** | **18** | **85%** |
| **PDF Advanced Features** | **26** | **95%** |

**Total: 142 tests (75 passing + 67 PDF tests)**

**Note:** PDF tests (67 total) require PyMuPDF and will be skipped if not installed. When PyMuPDF is available, all 142 tests run.

### 尚未覆盖
- Network operations (actual scraping)
- Enhancement scripts (`enhance_skill.py`, `enhance_skill_local.py`)
- Package creation (`package_skill.py`)
- Interactive mode
- SKILL.md generation
- Reference file creation
- PDF extraction with real PDF files (tests use mocked data)

---

## 编写新测试

### 测试模板

```python
#!/usr/bin/env python3
"""
Test suite for [feature name]
Tests [description of what's being tested]
"""

import sys
import os
import unittest

# Add parent directory to path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from doc_scraper import DocToSkillConverter


class TestYourFeature(unittest.TestCase):
    """Test [feature] functionality"""

    def setUp(self):
        """Set up test fixtures"""
        self.config = {
            'name': 'test',
            'base_url': 'https://example.com/',
            'selectors': {
                'main_content': 'article',
                'title': 'h1',
                'code_blocks': 'pre code'
            },
            'rate_limit': 0.1,
            'max_pages': 10
        }
        self.converter = DocToSkillConverter(self.config, dry_run=True)

    def tearDown(self):
        """Clean up after tests"""
        pass

    def test_your_feature(self):
        """Test description"""
        # Arrange
        test_input = "something"

        # Act
        result = self.converter.some_method(test_input)

        # Assert
        self.assertEqual(result, expected_value)


if __name__ == '__main__':
    unittest.main()
```

### 最佳实践

1. **Use descriptive test names**: `test_valid_name_formats` not `test1`
2. **Follow AAA pattern**: Arrange, Act, Assert
3. **One assertion per test** when possible
4. **Test edge cases**: empty inputs, invalid inputs, boundary values
5. **Use setUp/tearDown**: for common initialization and cleanup
6. **Mock external dependencies**: don't make real network calls
7. **Keep tests independent**: tests should not depend on each other
8. **Use dry_run=True**: for converter tests to avoid file creation

---

## 持续集成

### GitHub Actions (Future)

```yaml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-python@v2
        with:
          python-version: '3.7'
      - run: pip install requests beautifulsoup4
      - run: python3 run_tests.py
```

---

## 故障排除

### Tests Fail with Import Errors
```bash
# Make sure you're in the repository root
cd /path/to/Skill_Seekers

# Run tests from root directory
python3 run_tests.py
```

### Tests Create Output Directories
```bash
# Clean up test artifacts
rm -rf output/test-*

# Make sure tests use dry_run=True
# Check test setUp methods
```

### Specific Test Keeps Failing
```bash
# Run only that test with verbose output
python3 -m unittest tests.test_config_validation.TestConfigValidation.test_name -v

# Check the error message carefully
# Verify test expectations match implementation
```

---

## 性能

Test execution times:
- **Config Validation**: ~0.1 seconds (30 tests)
- **Scraper Features**: ~0.3 seconds (25 tests)
- **Integration Tests**: ~0.5 seconds (15 tests)
- **Total**: ~1 second (70 tests)

---

## 提交测试

When adding new features:

1. Write tests **before** implementing the feature (TDD)
2. Ensure tests cover:
   - ✅ Happy path (valid inputs)
   - ✅ Edge cases (empty, null, boundary values)
   - ✅ Error cases (invalid inputs)
3. Run tests before committing:
   ```bash
   python3 run_tests.py
   ```
4. Aim for >80% coverage for new code

---

## 参考资源

- **unittest documentation**: https://docs.python.org/3/library/unittest.html
- **pytest** (alternative): https://pytest.org/ (more powerful, but requires installation)
- **Test-Driven Development**: https://en.wikipedia.org/wiki/Test-driven_development

---

## 总结

✅ **142 comprehensive tests** covering all major features (75 + 67 PDF)
✅ **PDF support testing** with 67 tests for B1 tasks + Priority 2 & 3
✅ **Colored test runner** with detailed summaries
✅ **Fast execution** (~1 second for full suite)
✅ **Easy to extend** with clear patterns and templates
✅ **Good coverage** of critical paths

**PDF Tests Status:**
- 23 tests for PDF extraction (language detection, syntax validation, quality scoring, chapter detection)
- 18 tests for PDF workflow (initialization, categorization, skill building, code/image handling)
- **26 tests for advanced features (OCR, passwords, tables, parallel, caching)** NEW!
- Tests are skipped gracefully when PyMuPDF is not installed
- Full test coverage when PyMuPDF + optional dependencies are available

**Advanced PDF Features Tested:**
- ✅ OCR support for scanned PDFs (5 tests)
- ✅ Password-protected PDFs (4 tests)
- ✅ Table extraction (5 tests)
- ✅ Parallel processing (4 tests)
- ✅ Caching (5 tests)
- ✅ Integration (3 tests)

Run tests frequently to catch bugs early! 🚀
# Skill Seeker 测试指南

Skill Seeker 项目的综合测试文档。

## 快速开始

```bash
# 运行全部测试
python3 run_tests.py

# 详细输出
python3 run_tests.py -v

# 运行特定测试套件
python3 run_tests.py --suite config
python3 run_tests.py --suite features
python3 run_tests.py --suite integration

# 首个失败即停止
python3 run_tests.py --failfast

# 列出所有可用测试
python3 run_tests.py --list
```

## 测试结构

```
tests/
├── __init__.py                          # 测试包标记
├── test_config_validation.py            # 配置校验测试（30+）
├── test_scraper_features.py             # 核心功能测试（25+）
├── test_integration.py                  # 集成测试（15+）
├── test_pdf_extractor.py                # PDF 提取测试（23）
├── test_pdf_scraper.py                  # PDF 工作流测试（18）
└── test_pdf_advanced_features.py        # PDF 高级特性（26，新增）
```

## 测试套件

### 1. 配置校验测试（`test_config_validation.py`）

测试 `validate_config()` 的完整覆盖。

**测试类别：**
- ✅ 合法配置（最小与完整）
- ✅ 缺少必填字段（`name`、`base_url`）
- ✅ 非法名称格式（特殊字符）
- ✅ 合法名称格式（字母数字、连字符、下划线）
- ✅ 非法 URL（缺少协议）
- ✅ 合法 URL 协议（http、https）
- ✅ 选择器校验（结构与推荐字段）
- ✅ URL 模式校验（包含/排除列表）
- ✅ 分类校验（结构与关键字）
- ✅ 限速校验（范围 0-10、类型检查）
- ✅ 最大页数校验（范围 1-10000、类型检查）
- ✅ 起始 URL 校验（格式与协议）

**示例测试：**
```python
def test_valid_complete_config(self):
    """测试完整配置合法性"""
    config = {
        'name': 'godot',
        'base_url': 'https://docs.godotengine.org/en/stable/',
        'selectors': {
            'main_content': 'div[role="main"]',
            'title': 'title',
            'code_blocks': 'pre code'
        },
        'rate_limit': 0.5,
        'max_pages': 500
    }
    errors = validate_config(config)
    self.assertEqual(len(errors), 0)
```

**运行：**
```bash
python3 run_tests.py --suite config -v
```

---

### 2. 抓取功能测试（`test_scraper_features.py`）

测试核心抓取功能：URL 校验、语言检测、模式抽取、分类。

**测试类别：**

**URL 校验：**
- ✅ URL 匹配 include 模式
- ✅ URL 匹配 exclude 模式
- ✅ 不同域名拒绝
- ✅ 未配置模式时的行为

**语言检测：**
- ✅ 来自 CSS 类（`language-*`、`lang-*`）
- ✅ 来自父节点
- ✅ Python（import、from、def）
- ✅ JavaScript（const、let、箭头函数）
- ✅ GDScript（func、var）
- ✅ C++（#include、int main）
- ✅ 未知语言回退

**模式抽取：**
- ✅ “Example:” 标记
- ✅ “Usage:” 标记
- ✅ 模式数量上限（最多 5）

**分类：**
- ✅ 按 URL 关键词分类
- ✅ 按标题关键词分类
- ✅ 按内容关键词分类
- ✅ 回退至 “other”
- ✅ 空分类移除

**文本清洗：**
- ✅ 多空格归一化
- ✅ 换行归一化
- ✅ Tab 归一化
- ✅ 去除首尾空白

**示例测试：**
```python
def test_detect_python_from_heuristics(self):
    """测试基于内容的 Python 语言检测"""
    html = '<code>import os\nfrom pathlib import Path</code>'
    elem = BeautifulSoup(html, 'html.parser').find('code')
    lang = self.converter.detect_language(elem, elem.get_text())
    self.assertEqual(lang, 'python')
```

**运行：**
```bash
python3 run_tests.py --suite features -v
```

---

### 3. 集成测试（`test_integration.py`）

测试完整工作流与组件交互。

**测试类别：**

**Dry-Run 模式：**
- ✅ 试运行模式不创建目录
- ✅ Dry-run 标志正确设置
- ✅ 正常模式将创建目录

**配置加载：**
- ✅ 加载合法配置文件
- ✅ 非法 JSON 错误处理
- ✅ 不存在文件错误处理
- ✅ 加载时的校验错误

**真实配置校验：**
- ✅ Godot 配置
- ✅ React 配置
- ✅ Vue 配置
- ✅ Django 配置
- ✅ FastAPI 配置
- ✅ Steam Economy 配置

**URL 处理：**
- ✅ URL 规范化
- ✅ 起始 URL 回退到 base_url
- ✅ 多起始 URL 处理

**内容提取：**
- ✅ 空内容处理
- ✅ 基础内容提取
- ✅ 代码示例提取与语言检测

**示例测试：**
```python
def test_dry_run_no_directories_created(self):
    """试运行模式不创建目录"""
    converter = DocToSkillConverter(self.config, dry_run=True)

    data_dir = Path(f"output/{self.config['name']}_data")
    skill_dir = Path(f"output/{self.config['name']}")

    self.assertFalse(data_dir.exists())
    self.assertFalse(skill_dir.exists())
```

**运行：**
```bash
python3 run_tests.py --suite integration -v
```

---

### 4. PDF 提取测试（`test_pdf_extractor.py`）【新增】

覆盖 PDF 内容提取功能（B1.2-B1.5）。

**说明：** 需要安装 PyMuPDF（`pip install PyMuPDF`）。未安装时自动跳过。

**测试类别：**

**语言检测（5 项）：**
- ✅ Python 检测与置信度
- ✅ JavaScript 检测与置信度
- ✅ C++ 检测与置信度
- ✅ 未知语言返回低置信度
- ✅ 置信度区间始终在 [0,1]

**语法校验（5 项）：**
- ✅ 合法 Python 语法
- ✅ Python 缩进错误检测
- ✅ 括号不平衡检测
- ✅ 合法 JavaScript 语法
- ✅ 自然语言误判为代码的过滤

**质量评分（4 项）：**
- ✅ 分数区间在 [0,10]
- ✅ 高质量代码得分 >7
- ✅ 低质量代码得分 <4
- ✅ 综合多因素评分

**章节检测（4 项）：**
- ✅ 数字章节检测
- ✅ 大写章节标题检测
- ✅ 小节标题（如 “2.1”）
- ✅ 普通文本不误判为章节

**代码块合并（2 项）：**
- ✅ 合并跨页拆分的代码块
- ✅ 不合并不同语言的块

**检测方法（2 项）：**
- ✅ 基于模式检测
- ✅ 基于缩进检测

**质量过滤（1 项）：**
- ✅ 按最小质量阈值过滤

**示例测试：**
```python
def test_detect_python_with_confidence(self):
    """Python 检测返回语言与置信度"""
    extractor = self.PDFExtractor.__new__(self.PDFExtractor)
    code = "def hello():\n    print('world')\n    return True"

    language, confidence = extractor.detect_language_from_code(code)

    self.assertEqual(language, "python")
    self.assertGreater(confidence, 0.7)
    self.assertLessEqual(confidence, 1.0)
```

**运行：**
```bash
python3 -m pytest tests/test_pdf_extractor.py -v
```

---

### 5. PDF 工作流测试（`test_pdf_scraper.py`）【新增】

覆盖 PDF → 技能转换工作流（B1.6）。

**说明：** 需要安装 PyMuPDF；未安装时自动跳过。

**测试类别：**

**PDFToSkillConverter（3 项）：**
- ✅ 以 name 与 PDF 路径初始化
- ✅ 以配置文件初始化
- ✅ 要求提供 name 或 config_path

**分类（3 项）：**
- ✅ 关键词分类
- ✅ 章节分类
- ✅ 处理缺失章节

**技能构建（3 项）：**
- ✅ 创建必要目录结构
- ✅ 生成带元数据的 SKILL.md
- ✅ 为分类生成参考文件

**代码块处理（2 项）：**
- ✅ 在参考文件中包含代码块
- ✅ 优先高质量代码

**图片处理（2 项）：**
- ✅ 保存图片到 assets 目录
- ✅ 在 Markdown 引用图片

**错误处理（3 项）：**
- ✅ 缺失 PDF
- ✅ 非法配置 JSON
- ✅ 缺失必需配置字段

**JSON 工作流（2 项）：**
- ✅ 从提取 JSON 加载
- ✅ 无需再次提取即可构建

**示例测试：**
```python
def test_build_skill_creates_structure(self):
    """构建应创建必要目录结构"""
    converter = self.PDFToSkillConverter(
        name="test_skill",
        pdf_path="test.pdf",
        output_dir=self.temp_dir
    )

    converter.extracted_data = {
        "pages": [{"page_number": 1, "text": "Test", "code_blocks": [], "images": []}],
        "total_pages": 1
    }
    converter.categories = {"test": [converter.extracted_data["pages"][0]]}

    converter.build_skill()

    skill_dir = Path(self.temp_dir) / "test_skill"
    self.assertTrue(skill_dir.exists())
    self.assertTrue((skill_dir / "references").exists())
    self.assertTrue((skill_dir / "scripts").exists())
    self.assertTrue((skill_dir / "assets").exists())
```

**运行：**
```bash
python3 -m pytest tests/test_pdf_scraper.py -v
```

---

### 6. PDF 高级特性测试（`test_pdf_advanced_features.py`）【新增】

覆盖高级 PDF 特性（优先级 2 与 3）。

**说明：** 需要 PyMuPDF；OCR 测试还需 pytesseract 与 Pillow。未安装时自动跳过。

**测试类别：**

**OCR 支持（5 项）：**
- ✅ OCR 标志初始化
- ✅ OCR 关闭行为
- ✅ 文本极少时才触发 OCR
- ✅ 未安装 pytesseract 的警告
- ✅ 正确触发 OCR 提取

**密码保护（4 项）：**
- ✅ 密码参数初始化
- ✅ 加密 PDF 检测
- ✅ 错误密码处理
- ✅ 缺失密码报错

**表格提取（5 项）：**
- ✅ 表格提取标志初始化
- ✅ 关闭时不提取
- ✅ 基本表格提取
- ✅ 单页多表格
- ✅ 异常处理

**缓存（5 项）：**
- ✅ 缓存初始化
- ✅ 设置与获取缓存值
- ✅ 未命中返回 None
- ✅ 可关闭缓存
- ✅ 缓存覆盖

**并行处理（4 项）：**
- ✅ 并行标志初始化
- ✅ 默认关闭
- ✅ 自动检测 worker 数
- ✅ 自定义 worker 数

**集成（3 项）：**
- ✅ 全特性初始化
- ✅ 多种特性组合
- ✅ 页面数据包含表格

**示例测试：**
```python
def test_table_extraction_basic(self):
    """基本表格提取"""
    extractor = self.PDFExtractor.__new__(self.PDFExtractor)
    extractor.extract_tables = True
    extractor.verbose = False

    # 构造模拟表格
    mock_table = Mock()
    mock_table.extract.return_value = [
        ["Header 1", "Header 2", "Header 3"],
        ["Data 1", "Data 2", "Data 3"]
    ]
    mock_table.bbox = (0, 0, 100, 100)

    mock_tables = Mock()
    mock_tables.tables = [mock_table]

    mock_page = Mock()
    mock_page.find_tables.return_value = mock_tables

    tables = extractor.extract_tables_from_page(mock_page)

    self.assertEqual(len(tables), 1)
    self.assertEqual(tables[0]['row_count'], 2)
    self.assertEqual(tables[0]['col_count'], 3)
```

**运行：**
```bash
python3 -m pytest tests/test_pdf_advanced_features.py -v
```

---

## 测试运行器特性

自定义测试运行器（`run_tests.py`）提供：

### 彩色输出
- 🟢 通过
- 🔴 失败/错误
- 🟡 跳过

### 详细摘要
```
======================================================================
TEST SUMMARY
======================================================================

Total Tests: 70
✓ Passed: 68
✗ Failed: 2
⊘ Skipped: 0

Success Rate: 97.1%

Test Breakdown by Category:
  TestConfigValidation: 28/30 passed
  TestURLValidation: 6/6 passed
  TestLanguageDetection: 10/10 passed
  TestPatternExtraction: 3/3 passed
  TestCategorization: 5/5 passed
  TestDryRunMode: 3/3 passed
  TestConfigLoading: 4/4 passed
  TestRealConfigFiles: 6/6 passed
  TestContentExtraction: 3/3 passed

======================================================================
```

### 命令行选项

```bash
# 详细输出
python3 run_tests.py -v

# 简洁输出
python3 run_tests.py -q

# 首个失败即停止
python3 run_tests.py --failfast

# 运行特定套件
python3 run_tests.py --suite config

# 列出所有测试
python3 run_tests.py --list
```

---

## 运行单项测试

### 运行单个测试文件
```bash
python3 -m unittest tests.test_config_validation
python3 -m unittest tests.test_scraper_features
python3 -m unittest tests.test_integration
```

### 运行单个测试类
```bash
python3 -m unittest tests.test_config_validation.TestConfigValidation
python3 -m unittest tests.test_scraper_features.TestLanguageDetection
```

### 运行单个测试方法
```bash
python3 -m unittest tests.test_config_validation.TestConfigValidation.test_valid_complete_config
python3 -m unittest tests.test_scraper_features.TestLanguageDetection.test_detect_python_from_heuristics
```

---

## 测试覆盖率

### 当前覆盖率

| 组件 | 测试数 | 覆盖率 |
|------|--------|--------|
| 配置校验 | 30+ | 100% |
| URL 校验 | 6 | 95% |
| 语言检测 | 10 | 90% |
| 模式抽取 | 3 | 85% |
| 分类 | 5 | 90% |
| 文本清洗 | 4 | 100% |
| 试运行 | 3 | 100% |
| 配置加载 | 4 | 95% |
| 真实配置 | 6 | 100% |
| 内容提取 | 3 | 80% |
| **PDF 提取** | **23** | **90%** |
| **PDF 工作流** | **18** | **85%** |
| **PDF 高级特性** | **26** | **95%** |

**总计：142 测试（75 通过 + 67 PDF 测试）**

**说明：** PDF 测试（67）需要 PyMuPDF，未安装时会跳过；安装后将运行全部 142 项测试。

### 尚未覆盖
- 网络操作（真实抓取）
- 增强脚本（`enhance_skill.py`、`enhance_skill_local.py`）
- 打包（`package_skill.py`）
- 交互模式
- SKILL.md 生成
- 参考文件创建
- 使用真实 PDF 文件的提取（当前使用模拟数据）

---

## 编写新测试

### 测试模板

```python
#!/usr/bin/env python3
"""
测试套件：[功能名称]
测试说明：覆盖 [被测内容]
"""

import sys
import os
import unittest

# 将父目录加入路径
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from doc_scraper import DocToSkillConverter


class TestYourFeature(unittest.TestCase):
    """测试 [某功能]"""

    def setUp(self):
        """测试前置"""
        self.config = {
            'name': 'test',
            'base_url': 'https://example.com/',
            'selectors': {
                'main_content': 'article',
                'title': 'h1',
                'code_blocks': 'pre code'
            },
            'rate_limit': 0.1,
            'max_pages': 10
        }
        self.converter = DocToSkillConverter(self.config, dry_run=True)

    def tearDown(self):
        """测试后清理"""
        pass

    def test_your_feature(self):
        """测试描述"""
        # Arrange
        test_input = "something"

        # Act
        result = self.converter.some_method(test_input)

        # Assert
        self.assertEqual(result, expected_value)


if __name__ == '__main__':
    unittest.main()
```

### 最佳实践
1. **使用描述性名称**：如 `test_valid_name_formats` 而不是 `test1`
2. **AAA 模式**：Arrange、Act、Assert
3. **尽量单断言**：每个测试一个断言更清晰
4. **覆盖边界与异常**：空输入、非法输入、边界值
5. **使用 setUp/tearDown**：管理公共初始化与清理
6. **Mock 外部依赖**：避免真实网络调用
7. **测试独立**：互不依赖
8. **使用 dry_run=True**：避免创建文件/目录

---

## 持续集成

### GitHub Actions（未来）

```yaml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-python@v2
        with:
          python-version: '3.7'
      - run: pip install requests beautifulsoup4
      - run: python3 run_tests.py
```

---

## 故障排除

### 导入错误导致测试失败
```bash
# 请在仓库根目录运行
cd /path/to/Skill_Seekers
python3 run_tests.py
```

### 测试创建了输出目录
```bash
# 清理测试产物
rm -rf output/test-*

# 使用 dry_run=True
# 检查各测试的 setUp 方法
```

### 某个测试持续失败
```bash
# 单独运行该测试并查看详细输出
python3 -m unittest tests.test_config_validation.TestConfigValidation.test_name -v

# 仔细阅读报错并修正预期
```

---

## 性能

测试执行时间：
- **配置校验**：~0.1s（30 项）
- **抓取功能**：~0.3s（25 项）
- **集成测试**：~0.5s（15 项）
- **总计**：~1s（70 项）

---

## 贡献测试

新增功能时：
1. 先写测试再实现（TDD）
2. 测试覆盖：
   - ✅ 正常路径
   - ✅ 边界情况
   - ✅ 错误情况
3. 提交前运行：
   ```bash
   python3 run_tests.py
   ```
4. 新代码覆盖率目标：>80%

---

## 其它资源

- **unittest 文档**: https://docs.python.org/3/library/unittest.html
- **pytest**（替代方案）: https://pytest.org/
- **测试驱动开发**: https://en.wikipedia.org/wiki/Test-driven_development

---

## 总结

✅ **142 个覆盖全面的测试**，覆盖所有主要功能（75 + 67 PDF）
✅ **PDF 支持测试**：B1 任务 + 优先级 2/3，共 67 项
✅ **彩色测试运行器**与详细摘要
✅ **快速执行**（~1s 全套）
✅ **易扩展**（清晰的模式与模板）
✅ **关键路径良好覆盖**

**PDF 测试状态：**
- PDF 提取：23（语言检测、语法校验、质量评分、章节检测）
- PDF 工作流：18（初始化、分类、技能构建、代码/图片处理）
- PDF 高级特性：26（OCR、密码、表格、并行、缓存、集成）
- 未安装 PyMuPDF 时会跳过；安装后覆盖全套 142 项

**已测试高级特性：**
- ✅ 扫描 PDF 的 OCR 支持（5）
- ✅ 密码保护 PDF（4）
- ✅ 表格提取（5）
- ✅ 并行处理（4）
- ✅ 缓存（5）
- ✅ 集成（3）

请频繁运行测试，尽早发现问题！🚀
