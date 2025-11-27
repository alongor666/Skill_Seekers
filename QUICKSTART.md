# 快速开始指南

## 🚀 三步创建一个技能

### 第一步：安装依赖

```bash
pip3 install requests beautifulsoup4
```

> 说明：Skill_Seekers 会优先检查 `llms.txt` 系列文件（如 `llms.txt`、`llms-full.txt`），若存在可加速约 10 倍。

### 第二步：运行工具

**方案 A：使用预设（最简单）**
```bash
skill-seekers scrape --config configs/godot.json
```

**方案 B：交互模式**
```bash
skill-seekers scrape --interactive
```

**方案 C：快速命令**
```bash
skill-seekers scrape --name react --url https://react.dev/
```

**方案 D：统一多来源（NEW - v2.0.0）**
```bash
# 在一个技能中同时合并文档 + GitHub 代码
skill-seekers unified --config configs/react_unified.json
```
*可自动检测“文档与代码实现”的差异！*

### 第三步：增强 SKILL.md（推荐）

```bash
# 本地增强（无需 API Key，使用 Claude Code Max）
skill-seekers enhance output/godot/
```

**耗时约 60 秒，可显著提升 SKILL.md 质量！**

### 第四步：打包技能

```bash
skill-seekers package output/godot/
```

**完成！** 现在你已获得可用的 `godot.zip`。

---

## 📋 可用预设

```bash
# Godot 引擎
skill-seekers scrape --config configs/godot.json

# React
skill-seekers scrape --config configs/react.json

# Vue.js
skill-seekers scrape --config configs/vue.json

# Django
skill-seekers scrape --config configs/django.json

# FastAPI
skill-seekers scrape --config configs/fastapi.json

# 统一多来源（NEW！）
skill-seekers unified --config configs/react_unified.json
skill-seekers unified --config configs/django_unified.json
skill-seekers unified --config configs/fastapi_unified.json
skill-seekers unified --config configs/godot_unified.json
```

---

## ⚡ 复用已存在数据（更快）

若你已经完成过一次抓取：

```bash
skill-seekers scrape --config configs/godot.json

# 出现提示：
✓ Found existing data: 245 pages
Use existing data? (y/n): y

# 几秒内即可构建完成！
```

或使用 `--skip-scrape`：
```bash
skill-seekers scrape --config configs/godot.json --skip-scrape
```

---

## 🎯 完整示例（推荐工作流）

```bash
# 1. 安装（一次性）
pip3 install requests beautifulsoup4

# 2. 抓取 React 文档并执行本地增强
skill-seekers scrape --config configs/react.json --enhance-local
# 等待 15-30 分钟（抓取）+ 60 秒（增强）

# 3. 打包
skill-seekers package output/react/

# 4. 在 Claude 中使用 react.zip！
```

**备选：抓取后再增强**
```bash
# 2a. 仅抓取（不增强）
skill-seekers scrape --config configs/react.json

# 2b. 后续再增强
skill-seekers enhance output/react/

# 3. 打包
skill-seekers package output/react/
```

---

## 💡 实用技巧

### 先用小页面测试
编辑配置文件：
```json
{
  "max_pages": 20  // 先用 20 页进行验证
}
```

### 即时重建
```bash
# 完成首次抓取后，即可即时重建：
skill-seekers scrape --config configs/react.json --skip-scrape
```

### 创建自定义配置
```bash
# 复制一个预设
cp configs/react.json configs/myframework.json

# 编辑
nano configs/myframework.json

# 使用
skill-seekers scrape --config configs/myframework.json
```

---

## 📁 生成内容结构

```
output/
├── godot_data/          # 原始抓取数据（可复用）
└── godot/               # 构建后的技能
    ├── SKILL.md        # 含真实代码示例
    └── references/     # 分类整理文档
```

---

## ❓ 需要帮助？

请查看 **README.md**，其中包含：
- 完整文档
- 配置文件结构
- 故障排查
- 高级用法

---

## 🎮 开始动手！

```bash
# Godot
skill-seekers scrape --config configs/godot.json

# 或使用交互模式
skill-seekers scrape --interactive
```

就这些！🚀
