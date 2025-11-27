# 仓库结构

```
Skill_Seekers/
│
├── 📄 根文档
│   ├── README.md                  # 项目总览（从这里开始）
│   ├── CLAUDE.md                  # Claude Code 快速参考
│   ├── QUICKSTART.md              # 三步快速开始
│   ├── ROADMAP.md                 # 开发路线图
│   ├── TODO.md                    # 当前迭代任务
│   ├── STRUCTURE.md               # 本文件
│   ├── LICENSE                    # MIT 许可证
│   └── .gitignore                 # Git 忽略规则
│
├── 🔧 CLI 工具（cli/）
│   ├── doc_scraper.py             # 主抓取工具
│   ├── estimate_pages.py          # 页面数量预估
│   ├── enhance_skill.py           # AI 增强（API 版）
│   ├── enhance_skill_local.py     # AI 增强（本地，无需 API）
│   ├── package_skill.py           # 技能打包工具
│   └── run_tests.py               # 测试运行器
│
├── 🌐 MCP 服务器（mcp/）
│   ├── server.py                  # MCP 主服务器
│   ├── requirements.txt           # MCP 依赖
│   └── README.md                  # MCP 安装指南
│
├── 📁 configs/                    # 预设配置
│   ├── godot.json
│   ├── react.json
│   ├── vue.json
│   ├── django.json
│   ├── fastapi.json
│   ├── kubernetes.json
│   └── steam-economy-complete.json
│
├── 🧪 tests/                      # 测试套件（71 个测试，100% 通过）
│   ├── test_config_validation.py
│   ├── test_integration.py
│   └── test_scraper_features.py
│
├── 📚 docs/                       # 详细文档
│   ├── CLAUDE.md                  # 技术架构
│   ├── ENHANCEMENT.md             # AI 增强指南
│   ├── USAGE.md                   # 完整用法指南
│   ├── TESTING.md                 # 测试指南
│   └── UPLOAD_GUIDE.md            # 上传技能指南
│
├── 🔀 .github/                    # GitHub 配置
│   ├── SETUP_GUIDE.md             # GitHub 项目设置
│   ├── ISSUES_TO_CREATE.md        # Issue 模板与清单
│   └── ISSUE_TEMPLATE/            # Issue 模板
│
└── 📦 output/                     # 生成技能（已 git 忽略）
    ├── {name}_data/               # 抓取的原始数据（缓存）
    └── {name}/                    # 构建后的技能
        ├── SKILL.md               # 主技能文件
        └── references/            # 参考文档
```

## 关键文件

### 面向用户：
- **README.md** - 项目总览与安装说明
- **QUICKSTART.md** - 三步快速开始
- **configs/** - 7 个开箱即用的预设
- **mcp/README.md** - Claude Code 的 MCP 服务器设置

### 面向 CLI 使用：
- **cli/doc_scraper.py** - 主抓取工具
- **cli/estimate_pages.py** - 页面数量预估
- **cli/enhance_skill_local.py** - 本地增强（无需 API Key）
- **cli/package_skill.py** - 打包技能为 .zip

### 面向 MCP 使用（Claude Code）：
- **mcp/server.py** - MCP 服务器（6 个工具）
- **mcp/README.md** - 安装配置说明
- **configs/** - 共享配置

### 面向开发者：
- **docs/CLAUDE.md** - 架构与内部实现
- **docs/USAGE.md** - 完整用法指南
- **docs/TESTING.md** - 测试指南
- **tests/** - 71 个测试（100% 通过）

### 面向贡献者：
- **ROADMAP.md** - 开发路线图
- **TODO.md** - 当前迭代任务
- **.github/SETUP_GUIDE.md** - GitHub 设置
- **LICENSE** - MIT 许可证

## 架构

### Monorepo 结构

该仓库采用 monorepo 组织方式，包含两个主要模块：

1. **CLI 工具**（`cli/`）：用于命令行的独立 Python 脚本
2. **MCP 服务器**（`mcp/`）：面向 Claude Code 的 MCP 集成

两者共享同一份配置与输出目录。

### 数据流

```
Config (configs/*.json)
  ↓
CLI Tools OR MCP Server
  ↓
Scraper (cli/doc_scraper.py)
  ↓
Output (output/{name}_data/)
  ↓
Builder (cli/doc_scraper.py)
  ↓
Skill (output/{name}/)
  ↓
Enhancer (optional)
  ↓
Packager (cli/package_skill.py)
  ↓
Skill .zip (output/{name}.zip)
```
