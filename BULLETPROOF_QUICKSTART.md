# 防弹级快速上手指南

**适用人群：** 完全新手｜从未使用过 Python/git？从这里开始！

**耗时：** 共计 15-30 分钟（包含所有安装）

**结果：** 完成 Skill Seeker 安装，并创建你的第一个 Claude 技能

---

## 📋 你需要准备什么

开始之前，你只需要：

- 一台电脑（macOS、Linux，或安装了 WSL 的 Windows）
- 可用的网络连接
- 约 30 分钟时间

就这些！其他内容我们将一起完成安装。

---

## 第 1 步：安装 Python（约 5 分钟）

### 检查是否已安装 Python

在终端（macOS/Linux）或命令提示符（Windows）中输入：

```bash
python3 --version
```

**✅ 如果看到：**`Python 3.10.x`、`Python 3.11.x` 或更高版本 → **直接进入第 2 步！**

**❌ 如果看到：**`command not found` 或版本低于 3.10 → **继续往下**

### 安装 Python

#### macOS：

```bash
# 安装 Homebrew（若未安装）
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 安装 Python
brew install python3
```

**验证：**

```bash
python3 --version
# 期望：显示 Python 3.11.x 或类似版本
```

#### Linux（Ubuntu/Debian）：

```bash
sudo apt update
sudo apt install python3 python3-pip
```

**验证：**

```bash
python3 --version
pip3 --version
```

#### Windows：

1. 前往 https://www.python.org/downloads/ 下载 Python
2. 运行安装程序
3. **重要：** 安装时勾选 “Add Python to PATH”
4. 打开命令提示符并验证：

```bash
python --version
```

**✅ 期望结果：**

```
Python 3.11.5
```

---

## 第 2 步：安装 Git（约 3 分钟）

### 检查是否已安装 Git

```bash
git --version
```

**✅ 如果看到：**`git version 2.x.x` → **直接进入第 3 步！**

**❌ 如果未安装：**

#### macOS：

```bash
brew install git
```

#### Linux：

```bash
sudo apt install git
```

#### Windows：

下载地址：https://git-scm.com/download/win

**验证：**

```bash
git --version
# 期望：显示 git version 2.x.x
```

---

## 第 3 步：获取 Skill Seeker（约 2 分钟）

### 选择项目存放位置

推荐位置：

- macOS/Linux：`~/Projects/` 或 `~/Documents/`
  - 说明：`~` 表示用户主目录（macOS 为 `/Users/你的用户名`，Linux 为 `/home/你的用户名`）
- Windows：`C:\Users\你的用户名\Projects\`

### 克隆仓库

```bash
# 若不存在则创建 Projects 目录
mkdir -p ~/Projects
cd ~/Projects

# 克隆 Skill Seeker
git clone https://github.com/yusufkaraaslan/Skill_Seekers.git

# 进入目录
cd Skill_Seekers
```

**✅ 期望输出：**

```
Cloning into 'Skill_Seekers'...
remote: Enumerating objects: 245, done.
remote: Counting objects: 100% (245/245), done.
```

**验证当前目录是否正确：**

```bash
pwd
# 期望类似：
#   macOS: /Users/你的用户名/Projects/Skill_Seekers
#   Linux: /home/你的用户名/Projects/Skill_Seekers

ls
# 期望：README.md、cli/、mcp/、configs/ 等
```

**❌ 若 `git clone` 失败：**

```bash
# 检查网络连接
ping google.com

# 或手动下载 ZIP：
# https://github.com/yusufkaraaslan/Skill_Seekers/archive/refs/heads/main.zip
# 解压后进入对应目录
```

---

## 第 4 步：创建虚拟环境并安装依赖（约 3 分钟）

虚拟环境用于隔离 Skill Seeker 的依赖，避免与系统环境冲突。

```bash
# 确认当前在 Skill_Seekers 目录
cd ~/Projects/Skill_Seekers  # ~ 表示主目录（$HOME）

# 创建虚拟环境
python3 -m venv venv

# 激活虚拟环境
source venv/bin/activate  # macOS/Linux
# Windows：venv\Scripts\activate
```

**✅ 期望提示：**

```
(venv) username@computer Skill_Seekers %
```

出现 `(venv)` 表示虚拟环境已激活！

```bash
# 安装依赖（仅首次）
pip install requests beautifulsoup4 pytest

# 保存依赖列表
pip freeze > requirements.txt
```

**✅ 期望输出：**

```
Successfully installed requests-2.32.5 beautifulsoup4-4.14.2 pytest-8.4.2 ...
```

**可选（仅当你需要 API 增强，默认本地增强不需要）：**

```bash
pip install anthropic
```

**重要提示：**

- 每次打开新终端使用 Skill Seeker 前，请先运行 `source venv/bin/activate`
- 看到终端提示有 `(venv)` 即代表已激活
- 需要退出时输入 `deactivate` 即可

**❌ 若找不到 python3：**

```bash
# 尝试不带 3
python -m venv venv
```

**❌ 若出现权限问题：**

```bash
# 使用虚拟环境无需 sudo，可能是路径错误
# 确认当前在 Skill_Seekers 目录：
pwd
# 期望类似：/Users/你的用户名/Projects/Skill_Seekers
```

---

## 第 5 步：验证安装（约 1 分钟）

确认一切正常：

```bash
# 运行主脚本帮助
skill-seekers scrape --help
```

**✅ 期望输出：**

```
usage: doc_scraper.py [-h] [--config CONFIG] [--interactive] ...
```

**❌ 若看到 “No such file or directory” ：**

```bash
# 检查当前目录
pwd  # 应以 /Skill_Seekers 结尾

# 列出文件
ls cli/  # 应看到 doc_scraper.py、estimate_pages.py 等
```

---

## 第 6 步：创建你的第一个技能！（约 5-10 分钟）

让我们用一个预设配置来创建技能。

### 方案 A：小型测试（首次推荐）

```bash
# 先为小型站点创建一个配置
cat > configs/test.json << 'EOF'
{
  "name": "test-skill",
  "description": "Test skill creation",
  "base_url": "https://tailwindcss.com/docs/installation",
  "max_pages": 5,
  "rate_limit": 0.5
}
EOF

# 运行抓取
skill-seekers scrape --config configs/test.json
```

**会发生什么：**

1. 抓取 Tailwind CSS 文档的 5 个页面
2. 创建目录 `output/test-skill/`
3. 生成 SKILL.md 与参考文档

**⏱️ 耗时：**约 30 秒

**✅ 期望输出：**

```
Scraping: https://tailwindcss.com/docs/installation
Page 1/5: Installation
Page 2/5: Editor Setup
...
✅ Skill created at: output/test-skill/
```

### 方案 B：完整示例（React 文档）

```bash
# 使用 React 预设
skill-seekers scrape --config configs/react.json --max-pages 50
```

**⏱️ 耗时：**约 5 分钟

**你将得到：**

- `output/react/SKILL.md` - 主技能文件
- `output/react/references/` - 分类整理的文档

### 验证结果

```bash
# 检查输出
ls output/test-skill/
# 期望：SKILL.md、references/、scripts/、assets/

# 查看生成的 SKILL.md
head output/test-skill/SKILL.md
```

---

## 第 7 步：为 Claude 打包（约 30 秒）

```bash
# 打包技能
skill-seekers package output/test-skill/
```

**✅ 期望输出：**

```
✅ Skill packaged successfully!
📦 Created: output/test-skill.zip
📏 Size: 45.2 KB

Ready to upload to Claude AI!
```

**现在你已拥有：**可上传到 Claude 的 `output/test-skill.zip`！

---

## 第 8 步：上传到 Claude（约 2 分钟）

1. 打开 https://claude.ai
2. 点击头像 → Settings
3. 点击 “Knowledge” 或 “Skills”
4. 点击 “Upload Skill”
5. 选择 `output/test-skill.zip`
6. 完成！Claude 即可使用该技能

---

## 🎉 成功！接下来做什么？

你已完成 Skill Seeker 的安装！你可以：

### 试试其他预设

```bash
# 查看所有预设
ls configs/

# 尝试 Vue.js
skill-seekers scrape --config configs/vue.json --max-pages 50

# 尝试 Django
skill-seekers scrape --config configs/django.json --max-pages 50
```

### 创建自定义技能

```bash
# 交互模式——按提示回答
skill-seekers scrape --interactive

# 或为任意网站创建配置
skill-seekers scrape \
  --name myframework \
  --url https://docs.myframework.com/ \
  --description "My favorite framework"
```

### 配合 Claude Code 使用（进阶）

若已安装 Claude Code：

```bash
# 一次性设置
./setup_mcp.sh

# 然后在 Claude Code 中用自然语言指令：
# "Generate a skill for Svelte docs"
# "Package the skill at output/svelte/"
```

**详见：**[docs/MCP_SETUP.md](docs/MCP_SETUP.md)

---

## 🔧 故障排查

### “Command not found” 错误

**问题：**`python3: command not found`

**解决：**Python 未安装或未加入 PATH

- macOS/Linux：使用 brew/apt 重新安装
- Windows：重新安装并勾选 “Add to PATH”
- 尝试使用 `python` 代替 `python3`

### “Permission denied” 错误

**问题：**无法安装依赖或运行脚本

**解决：**

```bash
# 使用 --user 参数
pip3 install --user requests beautifulsoup4

# 或赋予执行权限
chmod +x cli/doc_scraper.py
```

### “No such file or directory”

**问题：**找不到 cli/doc_scraper.py

**解决：**当前目录错误

```bash
# 切换到 Skill_Seekers 目录
cd ~/Projects/Skill_Seekers  # 请按你的路径调整

# 验证
ls cli/  # 应看到 doc_scraper.py
```

### “ModuleNotFoundError”

**问题：**缺少 Python 依赖

**解决：**

```bash
# 重新安装依赖
pip3 install requests beautifulsoup4

# 若仍失败，尝试：
pip3 install --user requests beautifulsoup4
```

### 抓取很慢或失败

**问题：**耗时很久或报错

**解决：**

```bash
# 先用更小的页数测试
skill-seekers scrape --config configs/react.json --max-pages 10

# 检查网络连接
ping google.com

# 检查网站可达性
curl -I https://docs/yoursite.com
```

### 仍然有问题？

1. **查看详细排错指南：**[TROUBLESHOOTING.md](TROUBLESHOOTING.md)
2. **提交 Issue：**https://github.com/yusufkaraaslan/Skill_Seekers/issues
3. **请附带信息：**
   - 操作系统（macOS 13、Ubuntu 22.04、Windows 11 等）
   - Python 版本（`python3 --version`）
   - 完整错误信息
   - 运行的具体命令

---

## 📚 下一步

- **阅读完整 README：**[README.md](README.md)
- **了解预设：**[configs/](configs/)
- **尝试 MCP 集成：**[docs/MCP_SETUP.md](docs/MCP_SETUP.md)
- **高级用法：**[docs/](docs/)

---

## ✅ 快速参考

```bash
# 典型工作流：

# 1. 创建/使用配置
skill-seekers scrape --config configs/react.json --max-pages 50

# 2. 打包
skill-seekers package output/react/

# 3. 上传 output/react.zip 到 Claude

# 完成！🎉
```

**常见位置：**

- **配置：**`configs/*.json`
- **输出：**`output/skill-name/`
- **打包技能：**`output/skill-name.zip`

**时间预估：**

- 小型技能（5-10 页）：约 30 秒
- 中型技能（50-100 页）：约 3-5 分钟
- 大型技能（500+ 页）：约 15-30 分钟

---

**仍然不确定？** 没关系！创建一个 Issue，我们会帮助你开始：https://github.com/yusufkaraaslan/Skill_Seekers/issues/new
