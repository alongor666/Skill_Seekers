# 在 Claude Code 中测试 MCP 服务器（中文唯一版本）

本文演示如何通过真实的 Claude Code（使用 MCP 协议，而不是 Python 函数调用）来测试 Skill Seeker 的 MCP 服务器。

## 重要：我测试了什么 vs 你需要测试什么

### 我测试的内容（Python 直接调用） ✅
我通过直接调用 Python 中的 MCP 服务器函数进行了单元验证：
```python
await server.list_configs_tool({})
await server.generate_config_tool({...})
```

这确认了代码本身可工作，但没有验证 MCP 协议集成。

### 你需要测试的内容（真实 MCP 协议） 🎯
需要通过 Claude Code 使用 MCP 协议进行测试：
```
在 Claude Code 中：
> List all available configs
> mcp__skill-seeker__list_configs
```

这将验证完整集成流程是否正常。

## Setup Instructions

### 第 1 步：配置 Claude Code

Create the MCP configuration file:

```bash
# Create config directory
mkdir -p ~/.config/claude-code

# Create/edit MCP configuration
nano ~/.config/claude-code/mcp.json
```

填入如下内容（将 `/path/to/` 替换为你的实际路径）：

```json
{
  "mcpServers": {
    "skill-seeker": {
      "command": "python3",
      "args": [
        "/mnt/1ece809a-2821-4f10-aecb-fcdf34760c0b/Git/Skill_Seekers/skill_seeker_mcp/server.py"
      ],
      "cwd": "/mnt/1ece809a-2821-4f10-aecb-fcdf34760c0b/Git/Skill_Seekers"
    }
  }
}
```

或使用脚本：
```bash
./setup_mcp.sh
```

### 第 2 步：重启 Claude Code

**IMPORTANT:** Completely quit and restart Claude Code (don't just close the window).

### 第 3 步：验证 MCP 服务器加载

In Claude Code, check if the server loaded:

```
Show me all available MCP tools
```

你应当看到以 `mcp__skill-seeker__` 为前缀的 6 个工具：
- `mcp__skill-seeker__list_configs`
- `mcp__skill-seeker__generate_config`
- `mcp__skill-seeker__validate_config`
- `mcp__skill-seeker__estimate_pages`
- `mcp__skill-seeker__scrape_docs`
- `mcp__skill-seeker__package_skill`

## 测试全部 MCP 工具

### 测试 1：list_configs

在 Claude Code 中输入：
```
List all available Skill Seeker configs
```

或明确指定：
```
Use mcp__skill-seeker__list_configs
```

期望输出：
```
📋 Available Configs:

  • django.json
  • fastapi.json
  • godot.json
  • react.json
  • vue.json
  ...
```

### 测试 2：generate_config

在 Claude Code 中输入：
```
Generate a config for Astro documentation at https://docs.astro.build with max 15 pages
```

或明确指定：
```
Use mcp__skill-seeker__generate_config with:
- name: astro-test
- url: https://docs.astro.build
- description: Astro framework testing
- max_pages: 15
```

期望输出：
```
✅ Config created: configs/astro-test.json
```

### 测试 3：validate_config

在 Claude Code 中输入：
```
Validate the astro-test config
```

或明确指定：
```
Use mcp__skill-seeker__validate_config for configs/astro-test.json
```

期望输出：
```
✅ Config is valid!
  Name: astro-test
  Base URL: https://docs.astro.build
  Max pages: 15
```

### 测试 4：estimate_pages

在 Claude Code 中输入：
```
Estimate pages for the astro-test config
```

或明确指定：
```
Use mcp__skill-seeker__estimate_pages for configs/astro-test.json
```

期望输出：
```
📊 ESTIMATION RESULTS
Estimated Total: ~25 pages
Recommended max_pages: 75
```

### 测试 5：scrape_docs

在 Claude Code 中输入：
```
Scrape docs using the astro-test config
```

或明确指定：
```
Use mcp__skill-seeker__scrape_docs with configs/astro-test.json
```

期望输出：
```
✅ Skill built: output/astro-test/
Scraped X pages
Created Y categories
```

### 测试 6：package_skill

在 Claude Code 中输入：
```
Package the astro-test skill
```

或明确指定：
```
Use mcp__skill-seeker__package_skill for output/astro-test/
```

期望输出：
```
✅ Package created: output/astro-test.zip
Size: X KB
```

## 完整工作流测试

Test the entire workflow in Claude Code with natural language:

```
Step 1:
> List all available configs

Step 2:
> Generate config for Svelte at https://svelte.dev/docs with description "Svelte framework" and max 20 pages

Step 3:
> Validate configs/svelte.json

Step 4:
> Estimate pages for configs/svelte.json

Step 5:
> Scrape docs using configs/svelte.json

Step 6:
> Package skill at output/svelte/
```

期望结果：生成 `output/svelte.zip` 可直接上传。

## 故障排除

### 问题：工具未出现

症状：
- Claude Code doesn't recognize skill-seeker commands
- No `mcp__skill-seeker__` tools listed

解决：

1. Check configuration exists:
   ```bash
   cat ~/.config/claude-code/mcp.json
   ```

2. Verify server can start:
   ```bash
   cd /path/to/Skill_Seekers
   python3 skill_seeker_mcp/server.py
   # Should start without errors (Ctrl+C to exit)
   ```

3. Check dependencies installed:
   ```bash
   pip3 list | grep mcp
   # Should show: mcp x.x.x
   ```

4. Completely restart Claude Code (quit and reopen)

5. Check Claude Code logs:
   - macOS: `~/Library/Logs/Claude Code/`
   - Linux: `~/.config/claude-code/logs/`

### 问题：权限不足

```bash
chmod +x skill_seeker_mcp/server.py
```

### 问题：模块未找到

```bash
pip3 install -r skill_seeker_mcp/requirements.txt
pip3 install requests beautifulsoup4
```

## 验证清单

Use this checklist to verify MCP integration:

- [ ] Configuration file created at `~/.config/claude-code/mcp.json`
- [ ] Repository path in config is absolute and correct
- [ ] Python dependencies installed (`mcp`, `requests`, `beautifulsoup4`)
- [ ] Server starts without errors when run manually
- [ ] Claude Code completely restarted (quit and reopened)
- [ ] Tools appear when asking "show me all MCP tools"
- [ ] Tools have `mcp__skill-seeker__` prefix
- [ ] Can list configs successfully
- [ ] Can generate a test config
- [ ] Can scrape and package a small skill

## 和我之前测试的不同点

| What I Tested | What You Should Test |
|---------------|---------------------|
| Python function calls | Claude Code MCP protocol |
| `await server.list_configs_tool({})` | Natural language in Claude Code |
| Direct Python imports | Full MCP server integration |
| Validates code works | Validates Claude Code integration |
| Quick unit testing | Real-world usage testing |

## 成功标准

✅ **MCP Integration is Working When:**

1. You can ask Claude Code to "list all available configs"
2. Claude Code responds with the actual config list
3. You can generate, validate, scrape, and package skills
4. All through natural language commands in Claude Code
5. No Python code needed - just conversation!

## 成功后下一步

Once MCP integration works:

1. **Create your first skill:**
   ```
   > Generate config for TailwindCSS at https://tailwindcss.com/docs
   > Scrape docs using configs/tailwind.json
   > Package skill at output/tailwind/
   ```

2. **Upload to Claude:**
   - Take the generated `.zip` file
   - Upload to Claude.ai
   - Start using your new skill!

3. **Share feedback:**
   - Report any issues on GitHub
   - Share successful skills created
   - Suggest improvements

## 参考

- **Full Setup Guide:** [docs/MCP_SETUP.md](docs/MCP_SETUP.md)
- **MCP Documentation:** [mcp/README.md](mcp/README.md)
- **Main README:** [README.md](README.md)
- **Setup Script:** `./setup_mcp.sh`

---

重要：本文用于测试真实的 MCP 协议集成，不是仅测试 Python 函数。请确保通过 Claude Code 的 UI 进行测试，而非 Python 脚本！
# 在 Claude Code 中测试 MCP 服务器

本文演示如何通过真实的 Claude Code（使用 MCP 协议，而不仅是 Python 函数调用）来测试 Skill Seeker 的 MCP 服务器。

## 重要：我测试了什么 vs 你需要测试什么

### 我测试的内容（Python 直接调用） ✅
我通过直接调用 Python 中的 MCP 服务器函数进行了单元验证：
```python
await server.list_configs_tool({})
await server.generate_config_tool({...})
```

这确认了**代码本身可工作**，但没有验证**MCP 协议集成**。

### 你需要测试的内容（真实 MCP 协议） 🎯
需要通过 **Claude Code** 使用 MCP 协议进行测试：
```
在 Claude Code 中：
> List all available configs
> mcp__skill-seeker__list_configs
```

这将验证**完整集成流程**是否正常。

## 设置步骤

### 第 1 步：配置 Claude Code

创建 MCP 配置文件：

```bash
# 创建配置目录
mkdir -p ~/.config/claude-code

# 创建/编辑 MCP 配置
nano ~/.config/claude-code/mcp.json
```

填入如下内容（将 `/path/to/` 替换为你的实际路径）：

```json
{
  "mcpServers": {
    "skill-seeker": {
      "command": "python3",
      "args": [
        "/mnt/1ece809a-2821-4f10-aecb-fcdf34760c0b/Git/Skill_Seekers/skill_seeker_mcp/server.py"
      ],
      "cwd": "/mnt/1ece809a-2821-4f10-aecb-fcdf34760c0b/Git/Skill_Seekers"
    }
  }
}
```

或使用脚本：
```bash
./setup_mcp.sh
```

### 第 2 步：重启 Claude Code

**重要：** 完全退出并重启 Claude Code（不是仅关闭窗口）。

### 第 3 步：验证 MCP 服务器加载

在 Claude Code 中输入：

```
Show me all available MCP tools
```

你应当看到以 `mcp__skill-seeker__` 为前缀的 6 个工具：
- `mcp__skill-seeker__list_configs`
- `mcp__skill-seeker__generate_config`
- `mcp__skill-seeker__validate_config`
- `mcp__skill-seeker__estimate_pages`
- `mcp__skill-seeker__scrape_docs`
- `mcp__skill-seeker__package_skill`

## 测试全部 6 个 MCP 工具

### 测试 1：list_configs

**在 Claude Code 中输入：**
```
List all available Skill Seeker configs
```

**或明确指定：**
```
Use mcp__skill-seeker__list_configs
```

**期望输出：**
```
📋 Available Configs:

  • django.json
  • fastapi.json
  • godot.json
  • react.json
  • vue.json
  ...
```

### 测试 2：generate_config

**在 Claude Code 中输入：**
```
Generate a config for Astro documentation at https://docs.astro.build with max 15 pages
```

**或明确指定：**
```
Use mcp__skill-seeker__generate_config with:
- name: astro-test
- url: https://docs.astro.build
- description: Astro framework testing
- max_pages: 15
```

**期望输出：**
```
✅ Config created: configs/astro-test.json
```

### 测试 3：validate_config

**在 Claude Code 中输入：**
```
Validate the astro-test config
```

**或明确指定：**
```
Use mcp__skill-seeker__validate_config for configs/astro-test.json
```

**期望输出：**
```
✅ Config is valid!
  Name: astro-test
  Base URL: https://docs.astro.build
  Max pages: 15
```

### 测试 4：estimate_pages

**在 Claude Code 中输入：**
```
Estimate pages for the astro-test config
```

**或明确指定：**
```
Use mcp__skill-seeker__estimate_pages for configs/astro-test.json
```

**期望输出：**
```
📊 ESTIMATION RESULTS
Estimated Total: ~25 pages
Recommended max_pages: 75
```

### 测试 5：scrape_docs

**在 Claude Code 中输入：**
```
Scrape docs using the astro-test config
```

**或明确指定：**
```
Use mcp__skill-seeker__scrape_docs with configs/astro-test.json
```

**期望输出：**
```
✅ Skill built: output/astro-test/
Scraped X pages
Created Y categories
```

### 测试 6：package_skill

**在 Claude Code 中输入：**
```
Package the astro-test skill
```

**或明确指定：**
```
Use mcp__skill-seeker__package_skill for output/astro-test/
```

**期望输出：**
```
✅ Package created: output/astro-test.zip
Size: X KB
```

## 完整工作流测试

在 Claude Code 中用自然语言测试整个流程：

```
Step 1:
> List all available configs

Step 2:
> Generate config for Svelte at https://svelte.dev/docs with description "Svelte framework" and max 20 pages

Step 3:
> Validate configs/svelte.json

Step 4:
> Estimate pages for configs/svelte.json

Step 5:
> Scrape docs using configs/svelte.json

Step 6:
> Package skill at output/svelte/
```

期望结果：`output/svelte.zip` 准备好上传。

## 故障排除

### 问题：工具未出现

**症状：**
- Claude Code 未识别 skill-seeker 命令
- 未列出 `mcp__skill-seeker__` 工具

**解决：**
1. 检查配置文件存在：
   ```bash
   cat ~/.config/claude-code/mcp.json
   ```
2. 验证服务器可启动：
   ```bash
   cd /path/to/Skill_Seekers
   python3 skill_seeker_mcp/server.py
   # 应正常启动（Ctrl+C 退出）
   ```
3. 检查依赖安装：
   ```bash
   pip3 list | grep mcp
   # 应显示：mcp x.x.x
   ```
4. 完全重启 Claude Code（退出并重新打开）
5. 查看 Claude Code 日志：
   - macOS: `~/Library/Logs/Claude Code/`
   - Linux: `~/.config/claude-code/logs/`

### 问题："Permission Denied"
```bash
chmod +x skill_seeker_mcp/server.py
```

### 问题："Module Not Found"
```bash
pip3 install -r skill_seeker_mcp/requirements.txt
pip3 install requests beautifulsoup4
```

## 验证清单

- [ ] `~/.config/claude-code/mcp.json` 已创建
- [ ] 配置中的仓库路径为绝对路径且正确
- [ ] 已安装依赖（`mcp`、`requests`、`beautifulsoup4`）
- [ ] 服务器手动启动无错误
- [ ] Claude Code 已完全重启
- [ ] 提示 “show me all MCP tools” 能列出工具
- [ ] 工具前缀为 `mcp__skill-seeker__`
- [ ] 能成功列出配置
- [ ] 能生成测试配置
- [ ] 能抓取并打包一个小技能

## 和我之前测试的不同点

| 我测试的 | 你需要测试的 |
|----------|----------------|
| Python 函数调用 | Claude Code MCP 协议 |
| `await server.list_configs_tool({})` | 在 Claude Code 中使用自然语言 |
| 直接 Python import | 完整 MCP 服务器集成 |
| 验证代码可运行 | 验证 Claude Code 集成 |
| 快速单元测试 | 真实使用场景测试 |

## 成功标准

✅ **当以下条件满足，说明 MCP 集成工作正常：**
1. 你能让 Claude Code 列出所有可用配置
2. Claude Code 正确返回配置列表
3. 你能生成、验证、抓取并打包技能
4. 全程通过自然语言完成
5. 无需编写 Python 代码，仅通过对话即可

## 成功后下一步

1. **创建你的第一个技能：**
   ```
   > Generate config for TailwindCSS at https://tailwindcss.com/docs
   > Scrape docs using configs/tailwind.json
   > Package skill at output/tailwind/
   ```
2. **上传到 Claude：**
   - 选择生成的 `.zip` 文件
   - 上传到 Claude.ai
   - 开始使用你的新技能！
3. **反馈与分享：**
   - 在 GitHub 报告问题
   - 分享成功创建的技能
   - 提出改进建议

## 参考

- **完整设置指南：** [docs/MCP_SETUP.md](docs/MCP_SETUP.md)
- **MCP 文档：** [mcp/README.md](mcp/README.md)
- **主 README：** [README.md](README.md)
- **设置脚本：** `./setup_mcp.sh`

---

**重要：** 本文用于测试 **真实的 MCP 协议集成**，不是仅测试 Python 函数。请确保通过 Claude Code 的 UI 进行测试，而非 Python 脚本！
