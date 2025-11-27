# 需创建的 GitHub Issues 清单

可手动复制到 GitHub Issues，或使用 `gh issue create` 创建。

---

## Issue 1：修复剩余的 3 个测试失败

**标题：**Fix 3 test failures (warnings vs errors handling)

**标签：**bug, tests, good first issue

**内容：**
```markdown
## 问题
有 3 个测试失败，原因是它们校验的是错误（errors），但校验函数在这些情况下返回的是警告（warnings）：

1. `test_missing_recommended_selectors` - Missing selectors are warnings, not errors
2. `test_invalid_rate_limit_too_high` - Rate limit warnings
3. `test_invalid_max_pages_too_high` - Max pages warnings

**当前：**68/71 通过（95.8%）
**目标：**71/71 全部通过（100%）

## 位置
- `tests/test_config_validation.py`

## 方案
将测试改为校验 warnings 元组，而非 errors：
```python
# Before
errors, _ = validate_config(config)
self.assertTrue(any('title' in error.lower() for error in errors))

# After
_, warnings = validate_config(config)
self.assertTrue(any('title' in warning.lower() for warning in warnings))
```

## 验收标准
- [ ] 71 个测试全部通过
- [ ] 测试能正确区分 errors 与 warnings
- [ ] 无误报

## 需修改的文件
- `tests/test_config_validation.py` (3 test methods)
```

---

## Issue 2：创建 MCP 安装指南

**标题：**Create comprehensive MCP setup guide for Claude Code

**标签：**documentation, mcp, enhancement

**内容：**
```markdown
## 目标
为用户创建逐步指南，帮助在 Claude Code 中配置 MCP 服务器。

## 需要的内容

### 1. 前置条件
- Python 3.7+
- 已安装 Claude Code
- 已克隆仓库

### 2. 安装步骤
- 安装依赖
- 在 Claude Code 中配置 MCP
- 验证安装

### 3. 配置示例
- 完整的 `~/.config/claude-code/mcp.json` 示例
- 路径配置
- 常见问题排查

### 4. 使用示例
- 为新网站生成配置
- 估计页面数量
- 抓取并构建技能
- 端到端工作流

### 5. 截图/视频
- 安装配置的可视化引导
- 交互示例

## 交付物
- [ ] `docs/MCP_SETUP.md` - 主安装指南
- [ ] `.claude/mcp_config.example.json` - 配置示例
- [ ] `docs/images/` 中的截图
- [ ] 可选：快速上手视频

## 目标用户
已安装 Claude Code，但从未使用 MCP 的用户。
```

---

## Issue 3：测试 MCP 服务器功能

**标题：**Test MCP server with actual Claude Code instance

**标签：**testing, mcp, priority-high

**内容：**
```markdown
## 目标
验证 MCP 服务器能在真实的 Claude Code 环境中正常工作。

## 测试计划

### 准备
1. Install MCP server locally
2. Configure Claude Code MCP settings
3. Restart Claude Code

### 测试项

#### 测试 1：列出配置
```
User: "List all available configs"
Expected: Shows 7 configs (godot, react, vue, django, fastapi, kubernetes, steam-economy)
```

#### 测试 2：生成配置
```
User: "Generate config for Tailwind CSS at https://tailwindcss.com/docs"
Expected: Creates configs/tailwind.json
```

#### 测试 3：估计页面数
```
User: "Estimate pages for configs/tailwind.json"
Expected: Returns estimation results
```

#### 测试 4：校验配置
```
User: "Validate configs/react.json"
Expected: Shows config is valid
```

#### 测试 5：抓取文档
```
User: "Scrape docs using configs/kubernetes.json with max 10 pages"
Expected: Creates output/kubernetes/ directory with SKILL.md
```

#### 测试 6：打包技能
```
User: "Package skill at output/kubernetes/"
Expected: Creates kubernetes.zip
```

## 成功标准
- [ ] 6 个工具均能正确响应
- [ ] Claude Code 日志无错误
- [ ] 生成文件正确
- [ ] 性能可接受（简单操作 < 5s）

## 文档
将发现的问题与解决方案记录到测试结果中。

## 文件
- [ ] 创建 `tests/mcp_integration_test.md` 并写入测试结果
```

---

## Issue 4：为 Monorepo 更新文档

**标题：**Update all documentation for new monorepo structure

**标签：**documentation, breaking-change

**内容：**
```markdown
## 目标
更新所有文档以匹配 `cli/` 与 `mcp/` 的新结构。

## 需更新的文件

### 1. README.md
- [ ] Update file structure diagram
- [ ] Add MCP section
- [ ] Update installation commands
- [ ] Add quick start for both CLI and MCP

### 2. CLAUDE.md
- [ ] Update paths (cli/doc_scraper.py)
- [ ] Add MCP usage section
- [ ] Update examples

### 3. docs/USAGE.md
- [ ] Update all command paths
- [ ] Add MCP usage section
- [ ] Update examples

### 4. docs/TESTING.md
- [ ] Update test run commands
- [ ] Note new import structure

### 5. QUICKSTART.md
- [ ] Update for both CLI and MCP
- [ ] Add decision tree: "Use CLI or MCP?"

## 需要新增的文档
- [ ] `mcp/QUICKSTART.md` - MCP-specific quick start
- [ ] Update diagrams/architecture docs

## 需要记录的破坏性变更
- CLI tools moved from root to `cli/`
- Import path changes: `from doc_scraper` → `from cli.doc_scraper`
- New MCP-based workflow available

## 验证
- [ ] All code examples work
- [ ] All paths are correct
- [ ] Links are not broken
```

---

## How to Create Issues

### 方案 1：GitHub 网页端
1. Go to https://github.com/yusufkaraaslan/Skill_Seekers/issues/new
2. Copy title and body
3. Add labels
4. Create issue

### 方案 2：GitHub CLI
```bash
# Issue 1
gh issue create --title "Fix 3 test failures (warnings vs errors handling)" \
  --body-file issue1.md \
  --label "bug,tests,good first issue"

# Issue 2
gh issue create --title "Create comprehensive MCP setup guide for Claude Code" \
  --body-file issue2.md \
  --label "documentation,mcp,enhancement"

# Issue 3
gh issue create --title "Test MCP server with actual Claude Code instance" \
  --body-file issue3.md \
  --label "testing,mcp,priority-high"

# Issue 4
gh issue create --title "Update all documentation for new monorepo structure" \
  --body-file issue4.md \
  --label "documentation,breaking-change"
```

### 方案 3：手工脚本
将每个 Issue 的内容保存为 issue1.md、issue2.md 等，再按上述方式使用 gh CLI 创建。
