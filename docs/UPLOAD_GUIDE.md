# How to Upload Skills to Claude

## Quick Answer

**You have 3 options to upload the `.zip` file:**

### Option 1: Automatic Upload (Recommended for CLI)

```bash
# Set your API key (one-time setup)
export ANTHROPIC_API_KEY=sk-ant-...

# Package and upload automatically
python3 cli/package_skill.py output/react/ --upload

# OR upload existing .zip
python3 cli/upload_skill.py output/react.zip
```

✅ **Fully automatic** | No manual steps | Requires API key

### Option 2: Manual Upload (No API Key)

```bash
# Package the skill
python3 cli/package_skill.py output/react/

# This will:
# 1. Create output/react.zip
# 2. Open output/ folder automatically
# 3. Show clear upload instructions

# Then upload manually to https://claude.ai/skills
```

✅ **No API key needed** | Works for everyone | Simple

### Option 3: Claude Code MCP (Easiest)

```
In Claude Code, just say:
"Package and upload the React skill"

# Automatically packages and uploads!
```

✅ **Natural language** | Fully automatic | Best UX

---

## What's Inside the Zip?

The `.zip` file contains:

```
steam-economy.zip
├── SKILL.md              ← Main skill file (Claude reads this first)
└── references/           ← Reference documentation
    ├── index.md          ← Category index
    ├── api_reference.md  ← API docs
    ├── pricing.md        ← Pricing docs
    ├── trading.md        ← Trading docs
    └── ...               ← Other categorized docs
```

**Note:** The zip only includes what Claude needs. It excludes:
- `.backup` files
- Build artifacts
- Temporary files

## What Does package_skill.py Do?

The package script:

1. **Finds your skill directory** (e.g., `output/steam-economy/`)
2. **Validates SKILL.md exists** (required!)
3. **Creates a .zip file** with the same name
4. **Includes all files** except backups
5. **Saves to** `output/` directory

**Example:**
```bash
python3 cli/package_skill.py output/steam-economy/

📦 Packaging skill: steam-economy
   Source: output/steam-economy
   Output: output/steam-economy.zip
   + SKILL.md
   + references/api_reference.md
   + references/pricing.md
   + references/trading.md
   + ...

✅ Package created: output/steam-economy.zip
   Size: 14,290 bytes (14.0 KB)
```

## Complete Workflow

### Step 1: Scrape & Build
```bash
python3 cli/doc_scraper.py --config configs/steam-economy.json
```

**Output:**
- `output/steam-economy_data/` (raw scraped data)
- `output/steam-economy/` (skill directory)

### Step 2: Enhance (Recommended)
```bash
python3 cli/enhance_skill_local.py output/steam-economy/
```

**What it does:**
- Analyzes reference files
- Creates comprehensive SKILL.md
- Backs up original to SKILL.md.backup

**Output:**
- `output/steam-economy/SKILL.md` (enhanced)
- `output/steam-economy/SKILL.md.backup` (original)

### Step 3: Package
```bash
python3 cli/package_skill.py output/steam-economy/
```

**Output:**
- `output/steam-economy.zip` ← **THIS IS WHAT YOU UPLOAD**

### Step 4: Upload to Claude
1. Go to Claude (claude.ai)
2. Click "Add Skill" or skill upload button
3. Select `output/steam-economy.zip`
4. Done!

## What Files Are Required?

**Minimum required structure:**
```
your-skill/
└── SKILL.md          ← Required! Claude reads this first
```

**Recommended structure:**
```
your-skill/
├── SKILL.md          ← Main skill file (required)
└── references/       ← Reference docs (highly recommended)
    ├── index.md
    └── *.md          ← Category files
```

**Optional (can add manually):**
```
your-skill/
├── SKILL.md
├── references/
├── scripts/          ← Helper scripts
│   └── *.py
└── assets/           ← Templates, examples
    └── *.txt
```

## File Size Limits

The package script shows size after packaging:
```
✅ Package created: output/steam-economy.zip
   Size: 14,290 bytes (14.0 KB)
```

**Typical sizes:**
- Small skill: 5-20 KB
- Medium skill: 20-100 KB
- Large skill: 100-500 KB

Claude has generous size limits, so most documentation-based skills fit easily.

## Quick Reference

### Package a Skill
```bash
python3 cli/package_skill.py output/steam-economy/
```

### Package Multiple Skills
```bash
# Package all skills in output/
for dir in output/*/; do
  if [ -f "$dir/SKILL.md" ]; then
    python3 cli/package_skill.py "$dir"
  fi
done
```

### Check What's in a Zip
```bash
unzip -l output/steam-economy.zip
```

### Test a Packaged Skill Locally
```bash
# Extract to temp directory
mkdir temp-test
unzip output/steam-economy.zip -d temp-test/
cat temp-test/SKILL.md
```

## Troubleshooting

### "SKILL.md not found"
```bash
# Make sure you scraped and built first
python3 cli/doc_scraper.py --config configs/steam-economy.json

# Then package
python3 cli/package_skill.py output/steam-economy/
```

### "Directory not found"
```bash
# Check what skills are available
ls output/

# Use correct path
python3 cli/package_skill.py output/YOUR-SKILL-NAME/
```

### Zip is Too Large
Most skills are small, but if yours is large:
```bash
# Check size
ls -lh output/steam-economy.zip

# If needed, check what's taking space
unzip -l output/steam-economy.zip | sort -k1 -rn | head -20
```

Reference files are usually small. Large sizes often mean:
- Many images (skills typically don't need images)
- Large code examples (these are fine, just be aware)

## What Does Claude Do With the Zip?

When you upload a skill zip:

1. **Claude extracts it**
2. **Reads SKILL.md first** - This tells Claude:
   - When to activate this skill
   - What the skill does
   - Quick reference examples
   - How to navigate the references
3. **Indexes reference files** - Claude can search through:
   - `references/*.md` files
   - Find specific APIs, examples, concepts
4. **Activates automatically** - When you ask about topics matching the skill

## Example: Using the Packaged Skill

After uploading `steam-economy.zip`:

**You ask:** "How do I implement microtransactions in my Steam game?"

**Claude:**
- Recognizes this matches steam-economy skill
- Reads SKILL.md for quick reference
- Searches references/microtransactions.md
- Provides detailed answer with code examples

## API-Based Automatic Upload

### Setup (One-Time)

```bash
# Get your API key from https://console.anthropic.com/
export ANTHROPIC_API_KEY=sk-ant-...

# Add to your shell profile to persist
echo 'export ANTHROPIC_API_KEY=sk-ant-...' >> ~/.bashrc  # or ~/.zshrc
```

### Usage

```bash
# Upload existing .zip
python3 cli/upload_skill.py output/react.zip

# OR package and upload in one command
python3 cli/package_skill.py output/react/ --upload
```

### How It Works

The upload tool uses the Anthropic `/v1/skills` API endpoint to:
1. Read your .zip file
2. Authenticate with your API key
3. Upload to Claude's skill storage
4. Verify upload success

### Troubleshooting

**"ANTHROPIC_API_KEY not set"**
```bash
# Check if set
echo $ANTHROPIC_API_KEY

# If empty, set it
export ANTHROPIC_API_KEY=sk-ant-...
```

**"Authentication failed"**
- Verify your API key is correct
- Check https://console.anthropic.com/ for valid keys

**"Upload timed out"**
- Check your internet connection
- Try again or use manual upload

**Upload fails with error**
- Falls back to showing manual upload instructions
- You can still upload via https://claude.ai/skills

---

## Summary

**What you need to do:**

### With API Key (Automatic):
1. ✅ Scrape: `python3 cli/doc_scraper.py --config configs/YOUR-CONFIG.json`
2. ✅ Enhance: `python3 cli/enhance_skill_local.py output/YOUR-SKILL/`
3. ✅ Package & Upload: `python3 cli/package_skill.py output/YOUR-SKILL/ --upload`
4. ✅ Done! Skill is live in Claude

### Without API Key (Manual):
1. ✅ Scrape: `python3 cli/doc_scraper.py --config configs/YOUR-CONFIG.json`
2. ✅ Enhance: `python3 cli/enhance_skill_local.py output/YOUR-SKILL/`
3. ✅ Package: `python3 cli/package_skill.py output/YOUR-SKILL/`
4. ✅ Upload: Go to https://claude.ai/skills and upload the `.zip`

**What you upload:**
- The `.zip` file from `output/` directory
- Example: `output/steam-economy.zip`

**What's in the zip:**
- `SKILL.md` (required)
- `references/*.md` (recommended)
- Any scripts/assets you added (optional)

That's it! 🚀
# 如何将技能上传到 Claude

## 快速答案

**上传 `.zip` 文件有 3 种方式：**

### 方案一：自动上传（CLI 推荐）

```bash
# 一次性设置 API Key
export ANTHROPIC_API_KEY=sk-ant-...

# 打包并自动上传
python3 cli/package_skill.py output/react/ --upload

# 或上传现有 .zip
python3 cli/upload_skill.py output/react.zip
```

✅ **全自动** | 无需手动步骤 | 需要 API key

### 方案二：手动上传（无需 API Key）

```bash
# 打包技能
python3 cli/package_skill.py output/react/

# 该命令将：
# 1. 生成 output/react.zip
# 2. 自动打开 output/ 文件夹
# 3. 显示清晰的上传指引

# 然后手动访问 https://claude.ai/skills 上传
```

✅ **无需 API key** | 所有人可用 | 简单

### 方案三：Claude Code MCP（最省心）

```
在 Claude Code 直接说：
"Package and upload the React skill"

# 自动打包并上传！
```

✅ **自然语言** | 全自动 | 最佳体验

---

## Zip 包含什么？

Zip 内包含：

```
steam-economy.zip
├── SKILL.md              ← 主技能文件（Claude 首先读取）
└── references/           ← 参考文档
    ├── index.md          ← 分类索引
    ├── api_reference.md  ← API 文档
    ├── pricing.md        ← 价格文档
    ├── trading.md        ← 交易文档
    └── ...               ← 其他分类文档
```

**注意：** Zip 仅包含 Claude 需要的内容，排除：
- `.backup` 文件
- 构建产物
- 临时文件

## package_skill.py 做什么？

打包脚本将：

1. **定位你的技能目录**（如 `output/steam-economy/`）
2. **校验 SKILL.md 存在**（必需）
3. **创建同名 .zip 文件**
4. **包含所有文件**（除备份文件）
5. **保存到** `output/` 目录

**示例：**
```bash
python3 cli/package_skill.py output/steam-economy/

📦 Packaging skill: steam-economy
   Source: output/steam-economy
   Output: output/steam-economy.zip
   + SKILL.md
   + references/api_reference.md
   + references/pricing.md
   + references/trading.md
   + ...

✅ Package created: output/steam-economy.zip
   Size: 14,290 bytes (14.0 KB)
```

## 完整工作流

### 第一步：抓取与构建
```bash
python3 cli/doc_scraper.py --config configs/steam-economy.json
```

**输出：**
- `output/steam-economy_data/`（抓取的原始数据）
- `output/steam-economy/`（技能目录）

### 第二步：增强（推荐）
```bash
python3 cli/enhance_skill_local.py output/steam-economy/
```

**作用：**
- 分析参考文件
- 生成完善的 SKILL.md
- 将原始文件备份为 SKILL.md.backup

**输出：**
- `output/steam-economy/SKILL.md`（增强版）
- `output/steam-economy/SKILL.md.backup`（原始版）

### 第三步：打包
```bash
python3 cli/package_skill.py output/steam-economy/
```

**输出：**
- `output/steam-economy.zip` ← **这个文件需要上传**

### 第四步：上传至 Claude
1. 打开 Claude（claude.ai）
2. 点击 “Add Skill” 或上传按钮
3. 选择 `output/steam-economy.zip`
4. 完成！

## 需要哪些文件？

**最小必需结构：**
```
your-skill/
└── SKILL.md          ← 必需！Claude 首先读取
```

**推荐结构：**
```
your-skill/
├── SKILL.md          ← 主技能文件（必需）
└── references/       ← 参考文档（强烈推荐）
    ├── index.md
    └── *.md          ← 分类文件
```

**可选（可手动添加）：**
```
your-skill/
├── SKILL.md
├── references/
├── scripts/          ← 辅助脚本
│   └── *.py
└── assets/          ← 模板、示例
    └── *.txt
```

## 文件大小限制

打包脚本会显示包大小：
```
✅ Package created: output/steam-economy.zip
   Size: 14,290 bytes (14.0 KB)
```

**常见大小：**
- 小型技能：5-20 KB
- 中型技能：20-100 KB
- 大型技能：100-500 KB

Claude 的限制相对宽松，大多数基于文档的技能都能轻松通过。

## 快速参考

### 打包单个技能
```bash
python3 cli/package_skill.py output/steam-economy/
```

### 批量打包技能
```bash
# 打包 output/ 下的所有技能
for dir in output/*/; do
  if [ -f "$dir/SKILL.md" ]; then
    python3 cli/package_skill.py "$dir"
  fi
done
```

### 查看 Zip 内容
```bash
unzip -l output/steam-economy.zip
```

### 本地测试已打包技能
```bash
# 解压到临时目录
mkdir temp-test
unzip output/steam-economy.zip -d temp-test/
cat temp-test/SKILL.md
```

## 故障排除

### “SKILL.md not found”
```bash
# 请先确保完成抓取与构建
python3 cli/doc_scraper.py --config configs/steam-economy.json

# 然后执行打包
python3 cli/package_skill.py output/steam-economy/
```

### “Directory not found”
```bash
# 查看可用技能目录
ls output/

# 使用正确路径
python3 cli/package_skill.py output/YOUR-SKILL-NAME/
```

### Zip 过大
大多数技能通常较小；若包偏大：
```bash
# 查看大小
ls -lh output/steam-economy.zip

# 定位体积来源
unzip -l output/steam-economy.zip | sort -k1 -rn | head -20
```

参考文件通常较小。包过大通常意味着：
- 包含大量图片（技能一般不需要图片）
- 代码示例体积较大（通常可接受，仅需留意）

## Claude 如何使用 Zip？

上传技能 Zip 后：

1. **Claude 解压**
2. **优先读取 SKILL.md** — 包含：
   - 触发条件与技能用途
   - 技能能力说明
   - 快速参考示例
   - 如何导航 references
3. **索引参考文件** — 检索：
   - `references/*.md`
   - 定位具体 API、示例、概念
4. **自动激活** — 当用户提问匹配技能主题时

## 示例：使用已打包技能

上传 `steam-economy.zip` 后：

**你提问：**“如何在我的 Steam 游戏中实现微交易？”

**Claude：**
- 识别该问题匹配 steam-economy 技能
- 读取 SKILL.md 获取快速参考
- 搜索 references/microtransactions.md
- 输出包含代码示例的详细答案

## 基于 API 的自动上传

### 配置（一次性）

```bash
# 在 https://console.anthropic.com/ 获取 API Key
export ANTHROPIC_API_KEY=sk-ant-...

# 写入 Shell 配置以持久化
echo 'export ANTHROPIC_API_KEY=sk-ant-...' >> ~/.bashrc  # 或 ~/.zshrc
```

### 使用

```bash
# 上传现有 .zip
python3 cli/upload_skill.py output/react.zip

# 或打包并上传
python3 cli/package_skill.py output/react/ --upload
```

### 工作原理

上传工具通过 Anthropic `/v1/skills` API：
1. 读取 .zip 文件
2. 使用 API Key 鉴权
3. 上传至 Claude 的技能存储
4. 校验上传成功

### 故障排除

**“ANTHROPIC_API_KEY not set”**
```bash
# 检查是否已设置
echo $ANTHROPIC_API_KEY

# 若为空，请设置
export ANTHROPIC_API_KEY=sk-ant-...
```

**“Authentication failed”**
- 确认 API Key 正确
- 在 https://console.anthropic.com/ 检查 Key 状态

**“Upload timed out”**
- 检查网络连接
- 重试或改用手动上传

**上传失败（报错）**
- 工具会回退到显示手动上传指引
- 你仍可通过 https://claude.ai/skills 上传

---

## 总结

**你需要做的：**

### 有 API Key（自动）：
1. ✅ 抓取：`python3 cli/doc_scraper.py --config configs/YOUR-CONFIG.json`
2. ✅ 增强：`python3 cli/enhance_skill_local.py output/YOUR-SKILL/`
3. ✅ 打包并上传：`python3 cli/package_skill.py output/YOUR-SKILL/ --upload`
4. ✅ 完成！技能已在 Claude 中可用

### 无 API Key（手动）：
1. ✅ 抓取：`python3 cli/doc_scraper.py --config configs/YOUR-CONFIG.json`
2. ✅ 增强：`python3 cli/enhance_skill_local.py output/YOUR-SKILL/`
3. ✅ 打包：`python3 cli/package_skill.py output/YOUR-SKILL/`
4. ✅ 上传：访问 https://claude.ai/skills 上传 `.zip`

**需要上传的文件：**
- `output/` 目录下的 `.zip` 文件
- 示例：`output/steam-economy.zip`

**Zip 内含：**
- `SKILL.md`（必需）
- `references/*.md`（推荐）
- 你添加的脚本/资源（可选）

就这些！🚀
