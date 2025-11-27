## 目标范围
- 将“项目内不含中文的 md 文件”统一翻译为简体中文，排除生成产物与第三方依赖。
- 需转换的文件列表：
  - `README.md`
  - `QUICKSTART.md`
  - `BULLETPROOF_QUICKSTART.md`
  - `TROUBLESHOOTING.md`
  - `STRUCTURE.md`
  - `CONTRIBUTING.md`
  - `ROADMAP.md`
  - `FLEXIBLE_ROADMAP.md`
  - `FUTURE_RELEASES.md`
  - `ASYNC_SUPPORT.md`
  - `CHANGELOG.md`
  - `CLAUDE.md`（项目根目录）
  - `tests/mcp_integration_test.md`
  - `src/skill_seekers/mcp/README.md`
  - `.github/SETUP_INSTRUCTIONS.md`
  - `.github/SETUP_GUIDE.md`
  - `.github/PULL_REQUEST_TEMPLATE.md`
  - `.github/PROJECT_BOARD_SETUP.md`
  - `.github/ISSUES_TO_CREATE.md`
  - `.github/ISSUE_TEMPLATE/documentation.md`
  - `.github/ISSUE_TEMPLATE/bug_report.md`
  - `.github/ISSUE_TEMPLATE/feature_request.md`
  - `.github/ISSUE_TEMPLATE/mcp_tool.md`

## 排除项
- `output/react/**` 全部生成产物
- `venv/**` 第三方依赖包内文档

## 翻译与风格准则
- 语言：简体中文；保持技术术语英文原文 + 中文释义（首次出现）
- 保留所有代码块、命令、文件路径、API 名称为英文并用反引号标注
- 标题结构与原文一致；链接目标与锚点保持可用（必要时更新锚点）
- 术语统一：如“Quickstart → 快速开始”，“Troubleshooting → 故障排查”，“Roadmap → 路线图”
- 标点：中文正文使用全角标点；代码、参数、URL 使用半角
- 日期/版本：保留原有版本号与语义；日期统一为 `YYYY-MM-DD`

## 批次与优先级
- 批次 A（核心用户文档，最高优先）
  - `README.md`, `QUICKSTART.md`, `BULLETPROOF_QUICKSTART.md`, `TROUBLESHOOTING.md`, `STRUCTURE.md`
- 批次 B（贡献流程与模板）
  - `CONTRIBUTING.md`, `.github/*` 全部模板与指南, `tests/mcp_integration_test.md`
- 批次 C（路线图与其他）
  - `ROADMAP.md`, `FLEXIBLE_ROADMAP.md`, `FUTURE_RELEASES.md`, `ASYNC_SUPPORT.md`, `CLAUDE.md`, `src/skill_seekers/mcp/README.md`, `CHANGELOG.md`

## `CHANGELOG.md` 处理策略
- 翻译自然语言描述与章节标题；保留版本号、提交标识、代码引用原样
- 若出现大量历史记录，采用“最近版本完整翻译 + 旧版本摘要翻译”以控复杂度

## 验证标准
- 每个文件含中文，且英文仅保留在代码/专有名词/命令
- 所有内部链接与锚点正常；外链不破坏
- 运行 Markdown 链接检查与格式检查（如 `markdownlint` / `lychee`），确保无明显格式问题

## 交付与回滚
- 按批次提交改动，提交信息包含“中文化”与文件名清单
- 如需回滚：保留英文原文在历史版本中；必要时为个别文件保留英文备份分支

## 待确认偏好
- 是否“全中文”还是“中英对照”（当前默认全中文，仅保留必要英文术语）
- `CHANGELOG.md` 的翻译粒度选择（完整 vs. 最近完整 + 历史摘要）
- 是否需要统一的术语表文档（默认不新增独立文件，内联首处释义）

## 下一步
- 获得确认后，按批次 A → B → C 开始翻译与验证，并逐批提交更改