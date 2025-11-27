# PDF 解析库调研（任务 B1.1）

**日期：** 2025-10-21
**任务：** B1.1 - 调研 PDF 解析库
**目的：** 评估用于从 PDF 文档中提取文本与代码的 Python 库

---

## 摘要

综合调研后，推荐以 **PyMuPDF (fitz)** 作为 Skill Seeker 的主要 PDF 解析库，**pdfplumber** 作为复杂表格提取的备选方案。

### 快速建议：
- **Primary Choice:** PyMuPDF (fitz) - Fast, comprehensive, well-maintained
- **Secondary/Fallback:** pdfplumber - Better for tables, slower but more precise
- **Avoid:** PyPDF2 (deprecated, merged into pypdf)

---

## 库对比矩阵

| Library | Speed | Text Quality | Code Detection | Tables | Maintenance | License |
|---------|-------|--------------|----------------|--------|-------------|---------|
| **PyMuPDF** | ⚡⚡⚡⚡⚡ Fastest (42ms) | High | Excellent | Good | Active | AGPL/Commercial |
| **pdfplumber** | ⚡⚡ Slower (2.5s) | Very High | Excellent | Excellent | Active | MIT |
| **pypdf** | ⚡⚡⚡ Fast | Medium | Good | Basic | Active | BSD |
| **pdfminer.six** | ⚡ Slow | Very High | Good | Medium | Active | MIT |
| **pypdfium2** | ⚡⚡⚡⚡⚡ Very Fast (3ms) | Medium | Good | Basic | Active | Apache-2.0 |

---

## 详细分析

### 1. PyMuPDF (fitz) ⭐ 推荐

**性能：** 42ms（比 pdfminer.six 快约 60 倍）

**安装：**
```bash
pip install PyMuPDF
```

**优点：**
- ✅ Extremely fast (C-based MuPDF backend)
- ✅ Comprehensive features (text, images, tables, metadata)
- ✅ Supports markdown output
- ✅ Can extract images and diagrams
- ✅ Well-documented and actively maintained
- ✅ Handles complex layouts well

**缺点：**
- ⚠️ AGPL license (requires commercial license for proprietary projects)
- ⚠️ Requires MuPDF binary installation (handled by pip)
- ⚠️ Slightly larger dependency footprint

**代码示例：**
```python
import fitz  # PyMuPDF

# Extract text from entire PDF
def extract_pdf_text(pdf_path):
    doc = fitz.open(pdf_path)
    text = ''
    for page in doc:
        text += page.get_text()
    doc.close()
    return text

# Extract text from single page
def extract_page_text(pdf_path, page_num):
    doc = fitz.open(pdf_path)
    page = doc.load_page(page_num)
    text = page.get_text()
    doc.close()
    return text

# Extract with markdown formatting
def extract_as_markdown(pdf_path):
    doc = fitz.open(pdf_path)
    markdown = ''
    for page in doc:
        markdown += page.get_text("markdown")
    doc.close()
    return markdown
```

**Skill Seeker 使用场景：**
- Fast extraction of code examples from PDF docs
- Preserving formatting for code blocks
- Extracting diagrams and screenshots
- High-volume documentation scraping

---

### 2. pdfplumber ⭐ 推荐（适合表格）

**性能：** ~2.5s（较慢但更精细）

**安装：**
```bash
pip install pdfplumber
```

**优点：**
- ✅ MIT license (fully open source)
- ✅ Exceptional table extraction
- ✅ Visual debugging tool
- ✅ Precise layout preservation
- ✅ Built on pdfminer (proven text extraction)
- ✅ No binary dependencies

**缺点：**
- ⚠️ Slower than PyMuPDF
- ⚠️ Higher memory usage for large PDFs
- ⚠️ Requires more configuration for optimal results

**代码示例：**
```python
import pdfplumber

# Extract text from PDF
def extract_with_pdfplumber(pdf_path):
    with pdfplumber.open(pdf_path) as pdf:
        text = ''
        for page in pdf.pages:
            text += page.extract_text()
        return text

# Extract tables
def extract_tables(pdf_path):
    tables = []
    with pdfplumber.open(pdf_path) as pdf:
        for page in pdf.pages:
            page_tables = page.extract_tables()
            tables.extend(page_tables)
    return tables

# Extract specific region (for code blocks)
def extract_region(pdf_path, page_num, bbox):
    with pdfplumber.open(pdf_path) as pdf:
        page = pdf.pages[page_num]
        cropped = page.crop(bbox)
        return cropped.extract_text()
```

**Skill Seeker 使用场景：**
- Extracting API reference tables from PDFs
- Precise code block extraction with layout
- Documentation with complex table structures

---

### 3. pypdf（原 PyPDF2）

**Performance:** Fast (medium speed)

**Installation:**
```bash
pip install pypdf
```

**优点：**
- ✅ BSD license
- ✅ Simple API
- ✅ Can modify PDFs (merge, split, encrypt)
- ✅ Actively maintained (PyPDF2 merged back)
- ✅ No external dependencies

**缺点：**
- ⚠️ Limited complex layout support
- ⚠️ Basic text extraction only
- ⚠️ Poor with scanned/image PDFs
- ⚠️ No table extraction

**Code Example:**
```python
from pypdf import PdfReader

# Extract text
def extract_with_pypdf(pdf_path):
    reader = PdfReader(pdf_path)
    text = ''
    for page in reader.pages:
        text += page.extract_text()
    return text
```

**Skill Seeker 使用场景：**
- Simple text extraction
- Fallback when PyMuPDF licensing is an issue
- Basic PDF manipulation tasks

---

### 4. pdfminer.six

**Performance:** Slow (~2.5 seconds)

**Installation:**
```bash
pip install pdfminer.six
```

**优点：**
- ✅ MIT license
- ✅ Excellent text quality (preserves formatting)
- ✅ Handles complex layouts
- ✅ Pure Python (no binaries)

**缺点：**
- ⚠️ Slowest option
- ⚠️ Complex API
- ⚠️ Poor documentation
- ⚠️ Limited table support

**Skill Seeker 使用场景：**
- Not recommended (pdfplumber is built on this with better API)

---

### 5. pypdfium2

**Performance:** Very fast (3ms - fastest tested)

**Installation:**
```bash
pip install pypdfium2
```

**优点：**
- ✅ Extremely fast
- ✅ Apache 2.0 license
- ✅ Lightweight
- ✅ Clean output

**缺点：**
- ⚠️ Basic features only
- ⚠️ Limited documentation
- ⚠️ No table extraction
- ⚠️ Newer/less proven

**Skill Seeker 使用场景：**
- High-speed basic extraction
- Potential future optimization

---

## 许可考虑

### 开源项目（Skill Seeker）：
- **PyMuPDF:** ✅ AGPL license is fine for open-source projects
- **pdfplumber:** ✅ MIT license (most permissive)
- **pypdf:** ✅ BSD license (permissive)

### 重要说明：
PyMuPDF requires AGPL compliance (source code must be shared) OR a commercial license for proprietary use. Since Skill Seeker is open source on GitHub, AGPL is acceptable.

---

## 性能基准

Based on 2025 testing:

| Library | Time (single page) | Time (100 pages) |
|---------|-------------------|------------------|
| pypdfium2 | 0.003s | 0.3s |
| PyMuPDF | 0.042s | 4.2s |
| pypdf | 0.1s | 10s |
| pdfplumber | 2.5s | 250s |
| pdfminer.six | 2.5s | 250s |

**最佳：** pypdfium2（速度） / PyMuPDF（功能与速度平衡）

---

## 对 Skill Seeker 的建议

### 主方案：PyMuPDF (fitz)

**理由：**
1. **Speed** - 60x faster than alternatives
2. **Features** - Text, images, markdown output, metadata
3. **Quality** - High-quality text extraction
4. **Maintained** - Active development, good docs
5. **License** - AGPL is fine for open source

**实现策略：**
```python
import fitz  # PyMuPDF

def extract_pdf_documentation(pdf_path):
    """
    Extract documentation from PDF with code block detection
    """
    doc = fitz.open(pdf_path)
    pages = []

    for page_num, page in enumerate(doc):
        # Get text with layout info
        text = page.get_text("text")

        # Get markdown (preserves code blocks)
        markdown = page.get_text("markdown")

        # Get images (for diagrams)
        images = page.get_images()

        pages.append({
            'page_number': page_num,
            'text': text,
            'markdown': markdown,
            'images': images
        })

    doc.close()
    return pages
```

### 备选方案：pdfplumber

**使用时机：**
- PDF has complex tables that PyMuPDF misses
- Need visual debugging
- License concerns (use MIT instead of AGPL)

**实现策略：**
```python
import pdfplumber

def extract_pdf_tables(pdf_path):
    """
    Extract tables from PDF documentation
    """
    with pdfplumber.open(pdf_path) as pdf:
        tables = []
        for page in pdf.pages:
            page_tables = page.extract_tables()
            if page_tables:
                tables.extend(page_tables)
        return tables
```

---

## 代码块检测策略

PDFs don't have semantic "code block" markers like HTML. Detection strategies:

### 1. 基于字体的检测
```python
# PyMuPDF can detect font changes
def detect_code_by_font(page):
    blocks = page.get_text("dict")["blocks"]
    code_blocks = []

    for block in blocks:
        if 'lines' in block:
            for line in block['lines']:
                for span in line['spans']:
                    font = span['font']
                    # Monospace fonts indicate code
                    if 'Courier' in font or 'Mono' in font:
                        code_blocks.append(span['text'])

    return code_blocks
```

### 2. 基于缩进的检测
```python
def detect_code_by_indent(text):
    lines = text.split('\n')
    code_blocks = []
    current_block = []

    for line in lines:
        # Code often has consistent indentation
        if line.startswith('    ') or line.startswith('\t'):
            current_block.append(line)
        elif current_block:
            code_blocks.append('\n'.join(current_block))
            current_block = []

    return code_blocks
```

### 3. 基于模式的检测
```python
import re

def detect_code_by_pattern(text):
    # Look for common code patterns
    patterns = [
        r'(def \w+\(.*?\):)',  # Python functions
        r'(function \w+\(.*?\) \{)',  # JavaScript
        r'(class \w+:)',  # Python classes
        r'(import \w+)',  # Import statements
    ]

    code_snippets = []
    for pattern in patterns:
        matches = re.findall(pattern, text)
        code_snippets.extend(matches)

    return code_snippets
```

---

## 后续步骤（任务 B1.2+）

### 紧接任务：B1.2 - 创建简单的 PDF 文本提取器

**Goal:** Proof of concept using PyMuPDF

**实现计划：**
1. Create `cli/pdf_extractor_poc.py`
2. Extract text from sample PDF
3. Detect code blocks using font/pattern matching
4. Output to JSON (similar to web scraper)

**依赖：**
```bash
pip install PyMuPDF
```

**预期输出：**
```json
{
  "pages": [
    {
      "page_number": 1,
      "text": "...",
      "code_blocks": ["def main():", "import sys"],
      "images": []
    }
  ]
}
```

### 未来任务：
- **B1.3:** Add page chunking (split large PDFs)
- **B1.4:** Improve code block detection
- **B1.5:** Extract images/diagrams
- **B1.6:** Create full `pdf_scraper.py` CLI
- **B1.7:** Add MCP tool integration
- **B1.8:** Create PDF config format

---

## 更多资源

### 文档：
- PyMuPDF: https://pymupdf.readthedocs.io/
- pdfplumber: https://github.com/jsvine/pdfplumber
- pypdf: https://pypdf.readthedocs.io/

### 对比研究：
- 2025 Comparative Study: https://arxiv.org/html/2410.09871v1
- Performance Benchmarks: https://github.com/py-pdf/benchmarks

### 示例场景：
- Extracting API docs from PDF manuals
- Converting PDF guides to markdown
- Building skills from PDF-only documentation

---

## 结论

**For Skill Seeker's PDF documentation extraction:**

1. **Use PyMuPDF (fitz)** as primary library
2. **Add pdfplumber** for complex table extraction
3. **Detect code blocks** using font + pattern matching
4. **Preserve formatting** with markdown output
5. **Extract images** for diagrams/screenshots

**预计实现时间：**
- B1.2 (POC): 2-3 hours
- B1.3-B1.5 (Features): 5-8 hours
- B1.6 (CLI): 3-4 hours
- B1.7 (MCP): 2-3 hours
- B1.8 (Config): 1-2 hours
- **Total: 13-20 hours** for complete PDF support

**许可：** AGPL（PyMuPDF）对 Skill Seeker（开源）是可接受的

---

**调研完成：** ✅ 2025-10-21
**下一任务：** B1.2 - 创建简单 PDF 文本提取器（概念验证）
