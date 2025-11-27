# 故障排查指南

使用 Skill Seeker 过程中常见问题与解决方法。

---

## 安装相关问题

### 找不到 Python

**错误：**
```
python3: command not found
```

**解决：**
1. **检查是否安装 Python：**
   ```bash
   which python3
   python --version  # 尝试不带 3 的命令
   ```

2. **安装 Python：**
   - **macOS：**`brew install python3`
   - **Linux：**`sudo apt install python3 python3-pip`
   - **Windows：**到 python.org 下载并勾选 “Add to PATH”

3. **使用 python 代替 python3：**
   ```bash
   python cli/doc_scraper.py --help
   ```

### 模块缺失

**错误：**
```
ModuleNotFoundError: No module named 'requests'
ModuleNotFoundError: No module named 'bs4'
ModuleNotFoundError: No module named 'mcp'
```

**解决：**
1. **安装依赖：**
   ```bash
   pip3 install requests beautifulsoup4
   pip3 install -r mcp/requirements.txt  # MCP 依赖
   ```

2. **权限不足时使用 --user：**
   ```bash
   pip3 install --user requests beautifulsoup4
   ```

3. **确认 pip 正常：**
   ```bash
   pip3 --version
   ```

### 权限不足

**错误：**
```
Permission denied: '/usr/local/lib/python3.x/...'
```

**解决：**
1. **使用 --user 参数：**
   ```bash
   pip3 install --user requests beautifulsoup4
   ```

2. **使用 sudo（不推荐）：**
   ```bash
   sudo pip3 install requests beautifulsoup4
   ```

3. **使用虚拟环境（最佳实践）：**
   ```bash
   python3 -m venv venv
   source venv/bin/activate
   pip install requests beautifulsoup4
   ```

---

## 运行时问题

### 找不到文件

**错误：**
```
FileNotFoundError: [Errno 2] No such file or directory: 'cli/doc_scraper.py'
```

**解决：**
1. **检查是否位于 Skill_Seekers 目录：**
   ```bash
   pwd
   # 期望：.../Skill_Seekers

   ls
   # 期望：README.md、cli/、mcp/、configs/
   ```

2. **切换到正确目录：**
   ```bash
   cd ~/Projects/Skill_Seekers  # 按需调整路径
   ```

### 找不到配置文件

**错误：**
```
FileNotFoundError: configs/react.json
```

**解决：**
1. **检查配置是否存在：**
   ```bash
   ls configs/
   # 期望：godot.json、react.json、vue.json 等
   ```

2. **使用绝对路径：**
   ```bash
   skill-seekers scrape --config $(pwd)/configs/react.json
   ```

3. **交互方式创建缺失配置：**
   ```bash
   skill-seekers scrape --interactive
   ```

---

## MCP 安装相关问题

### MCP 服务器未加载

**现象：**
- Claude Code 中不显示工具
- “List all available configs” 无法执行

**解决：**

1. **检查配置文件：**
   ```bash
   cat ~/.config/claude-code/mcp.json
   ```

2. **确保路径为绝对路径（不使用占位符）：**
   ```json
   {
     "mcpServers": {
       "skill-seeker": {
         "args": [
           "/Users/yourname/Projects/Skill_Seekers/mcp/server.py"
         ]
       }
     }
   }
   ```
   ❌ 错误示例：`$REPO_PATH` 或 `/path/to/Skill_Seekers`
   ✅ 正确示例：`/Users/john/Projects/Skill_Seekers`

3. **手动测试服务器：**
   ```bash
   cd ~/Projects/Skill_Seekers
   python3 mcp/server.py
   # 若无错误则正常（Ctrl+C 停止）
   ```

4. **重新运行安装脚本：**
   ```bash
   ./setup_mcp.sh
   # 选择 "y" 自动配置
   ```

5. **彻底重启 Claude Code：**
   - 完全退出（不要只关闭窗口）
   - 重新打开

### 配置中使用了占位符路径

**问题：**配置包含 `$REPO_PATH` 或 `/Users/username/` 等占位符

**解决：**
```bash
# 获取实际路径
cd ~/Projects/Skill_Seekers
pwd
# 复制该路径

# 编辑配置
nano ~/.config/claude-code/mcp.json

# 将所有占位符替换为实际路径
# 保存（Ctrl+O、回车、Ctrl+X）

# 重启 Claude Code
```

### 工具显示但不可用

**现象：**
- 工具已列出但命令执行失败
- 出现 “Error executing tool” 提示

**解决：**

1. **检查工作目录：**
   ```json
   {
     "cwd": "/FULL/PATH/TO/Skill_Seekers"
   }
   ```

2. **确认文件存在：**
   ```bash
   ls cli/doc_scraper.py
   ls mcp/server.py
   ```

3. **直接测试 CLI 工具：**
   ```bash
   skill-seekers scrape --help
   ```

---

## 抓取相关问题

### 速度慢或卡住

**解决：**

1. **检查网络连接：**
   ```bash
   ping google.com
   curl -I https://docs.yoursite.com
   ```

2. **测试更小的 max_pages：**
   ```bash
   skill-seekers scrape --config configs/test.json --max-pages 5
   ```

3. **提高配置中的 rate_limit：**
   ```json
   {
     "rate_limit": 1.0  // 从 0.5 增加
   }
   ```

### 抓取到页面但内容为空

**解决：**

1. **检查配置中的选择器：**
   ```bash
   # 在浏览器开发者工具中尝试
   # 关注：article、main、div[role="main"]、div.content
   ```

2. **验证站点可访问：**
   ```bash
   curl https://docs.example.com
   ```

3. **尝试不同的选择器：**
   ```json
   {
     "selectors": {
       "main_content": "article"  // 可尝试 main、div.content 等
     }
   }
   ```

### 访问限制 / 429 错误

**错误：**
```
HTTP Error 429: Too Many Requests
```

**解决：**

1. **增加 rate_limit：**
   ```json
   {
     "rate_limit": 2.0  // 两次请求之间等待 2 秒
   }
   ```

2. **降低 max_pages：**
   ```json
   {
     "max_pages": 50  // 抓取更少页面
   }
   ```

3. **稍后重试：**
   ```bash
   # 等一小时后再试
   ```

---

## 平台特定问题

### macOS

**问题：**无法运行 `./setup_mcp.sh`

**解决：**
```bash
chmod +x setup_mcp.sh
./setup_mcp.sh
```

**问题：**未安装 Homebrew

**解决：**
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Linux

**问题：**找不到 pip3

**解决：**
```bash
sudo apt update
sudo apt install python3-pip
```

**问题：**权限错误

**解决：**
```bash
# 使用 --user 参数
pip3 install --user requests beautifulsoup4
```

### Windows（WSL）

**问题：**Python 未加入 PATH

**解决：**
1. 重新安装 Python
2. 勾选 “Add Python to PATH”
3. 或手动加入 PATH

**问题：**换行符导致脚本错误

**解决：**
```bash
dos2unix setup_mcp.sh
./setup_mcp.sh
```

---

## 验证命令

用于快速检查环境：

```bash
# 1. 检查 Python
python3 --version  # 应为 3.10+

# 2. 检查依赖
pip3 list | grep requests
pip3 list | grep beautifulsoup4
pip3 list | grep mcp

# 3. 检查文件是否存在
ls cli/doc_scraper.py
ls mcp/server.py
ls configs/

# 4. 检查 MCP 配置
cat ~/.config/claude-code/mcp.json

# 5. 测试抓取器
skill-seekers scrape --help

# 6. 测试 MCP 服务器
timeout 3 python3 mcp/server.py || echo "Server OK"

# 7. 查看仓库状态
git status
git log --oneline -5
```

---

## 获取帮助

若以上方法仍无法解决：

1. **查看现有 Issue：**
   https://github.com/yusufkaraaslan/Skill_Seekers/issues

2. **创建新 Issue，并附带：**
   - 操作系统（macOS 13、Ubuntu 22.04 等）
   - Python 版本（`python3 --version`）
   - 完整错误信息
   - 执行的命令
   - 上述“验证命令”的输出

3. **附加调试信息：**
   ```bash
   # 系统信息
   uname -a
   python3 --version
   pip3 --version

   # Skill Seeker 信息
   cd ~/Projects/Skill_Seekers  # 你的路径
   pwd
   git log --oneline -1
   ls -la cli/ mcp/ configs/

   # MCP 配置（若使用 MCP）
   cat ~/.config/claude-code/mcp.json
   ```

---

## 快速检查清单

- [ ] 当前在 Skill_Seekers 目录？（`pwd`）
- [ ] 已安装 Python 3.10+？（`python3 --version`）
- [ ] 依赖已安装？（`pip3 list | grep requests`）
- [ ] 配置文件存在？（`ls configs/yourconfig.json`）
- [ ] 网络连接正常？（`ping google.com`）
- [ ] MCP：配置使用绝对路径？（不是 `$REPO_PATH`）
- [ ] MCP：Claude Code 已重启？（完全退出后重开）

---

**仍然卡住？** 创建 Issue：https://github.com/yusufkaraaslan/Skill_Seekers/issues/new
