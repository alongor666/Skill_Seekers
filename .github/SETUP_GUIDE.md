# GitHub 项目设置指南

用于 Skill Seeker MCP 开发的 GitHub Issues 与项目看板快速设置指南。

---

## 步骤 1：创建 GitHub Issues（约 5 分钟）

### 快速方式：
1. Open: https://github.com/yusufkaraaslan/Skill_Seekers/issues/new
2. Open in another tab: `.github/ISSUES_TO_CREATE.md` (in your repo)
3. Copy title and body for each issue
4. Create 4 issues

### 需要创建的 Issues：

**Issue #1：**
- Title: `Fix 3 test failures (warnings vs errors handling)`
- Labels: `bug`, `tests`, `good first issue`
- Body: Copy from ISSUES_TO_CREATE.md (Issue 1)

**Issue #2：**
- Title: `Create comprehensive MCP setup guide for Claude Code`
- Labels: `documentation`, `mcp`, `enhancement`
- Body: Copy from ISSUES_TO_CREATE.md (Issue 2)

**Issue #3：**
- Title: `Test MCP server with actual Claude Code instance`
- Labels: `testing`, `mcp`, `priority-high`
- Body: Copy from ISSUES_TO_CREATE.md (Issue 3)

**Issue #4：**
- Title: `Update all documentation for new monorepo structure`
- Labels: `documentation`, `breaking-change`
- Body: Copy from ISSUES_TO_CREATE.md (Issue 4)

---

## 步骤 2：创建 GitHub 项目看板（约 2 分钟）

### 步骤：
1. Go to: https://github.com/yusufkaraaslan/Skill_Seekers/projects
2. Click **"New project"**
3. Choose **"Board"** template
4. Name it: **"Skill Seeker MCP Development"**
5. Click **"Create project"**

### 看板配置：

**默认列：**
- Todo
- In Progress
- Done

**添加自定义列（可选）：**
- Testing

**你的看板将类似如下：**
```
📋 Todo          | 🚧 In Progress  | 🧪 Testing  | ✅ Done
-----------------|-----------------│-------------|---------
Issue #1         |                 |             |
Issue #2         |                 |             |
Issue #3         |                 |             |
Issue #4         |                 |             |
```

---

## 步骤 3：将 Issues 加入项目

1. In your project board, click **"Add item"**
2. Search for your issues (#1, #2, #3, #4)
3. Add them to "Todo" column
4. Done!

---

## 步骤 4：开始执行

1. Move **Issue #1** to "In Progress"
2. Work on fixing tests
3. When done, move to "Done"
4. Repeat!

---

## 备选：快速脚本

```bash
# View issue templates
cat .github/ISSUES_TO_CREATE.md

# Get direct URLs for creating issues
.github/create_issues.sh
```

---

## 提示

### 在 PR 中关联 Issues
When you create a PR, mention the issue:
```
Fixes #1
```

### 自动关闭 Issues
In commit message:
```
Fix test failures

Fixes #1
```

### 项目自动化
GitHub Projects can auto-move issues:
- PR opened → Move to "In Progress"
- PR merged → Move to "Done"

Enable in Project Settings → Workflows

---

## 你的工作流

```
Daily:
1. Check Project Board
2. Pick task from "Todo"
3. Move to "In Progress"
4. Work on it
5. Create PR (mention issue number)
6. Move to "Testing"
7. Merge PR → Auto moves to "Done"
```

---

## 快速链接

- **Issues:** https://github.com/yusufkaraaslan/Skill_Seekers/issues
- **Projects:** https://github.com/yusufkaraaslan/Skill_Seekers/projects
- **New Issue:** https://github.com/yusufkaraaslan/Skill_Seekers/issues/new
- **New Project:** https://github.com/yusufkaraaslan/Skill_Seekers/projects/new

---

需要帮助？请查看 `.github/ISSUES_TO_CREATE.md` 获取完整 Issue 内容！
