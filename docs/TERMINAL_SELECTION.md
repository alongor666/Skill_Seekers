# 终端选择指南

使用 `--enhance-local` 时，Skill Seeker 会打开一个新的终端窗口来运行 Claude Code。本文说明如何控制使用哪个终端应用。

## 优先级顺序

脚本按以下顺序自动检测应使用的终端：

1. **`SKILL_SEEKER_TERMINAL` 环境变量**（最高优先级）
2. **`TERM_PROGRAM` 环境变量**（继承当前终端）
3. **Terminal.app**（回退默认）

## 设置首选终端

### 方案一：设置环境变量（推荐）

将如下内容添加到你的 Shell 配置（`~/.zshrc` 或 `~/.bashrc`）：

```bash
# Ghostty 用户
export SKILL_SEEKER_TERMINAL="Ghostty"

# iTerm 用户
export SKILL_SEEKER_TERMINAL="iTerm"

# WezTerm 用户
export SKILL_SEEKER_TERMINAL="WezTerm"
```

然后重新加载 Shell：
```bash
source ~/.zshrc  # or source ~/.bashrc
```

### 方案二：按会话设置

在运行命令前设置该变量：

```bash
SKILL_SEEKER_TERMINAL="Ghostty" python3 cli/doc_scraper.py --config configs/react.json --enhance-local
```

### 方案三：继承当前终端（自动）

如果你从 Ghostty、iTerm2 或 WezTerm 运行脚本，将自动在同一终端应用中打开增强流程。

**注意：** IDE 的集成终端（VS Code、Zed、JetBrains）使用独特的 `TERM_PROGRAM` 值，除非设置 `SKILL_SEEKER_TERMINAL`，否则会回退到 Terminal.app。

## 支持的终端

- **Ghostty**（`ghostty`）
- **iTerm2**（`iTerm.app`）
- **Terminal.app**（`Apple_Terminal`）
- **WezTerm**（`WezTerm`）

## 示例输出

终端检测成功时：
```
🚀 Launching Claude Code in new terminal...
   Using terminal: Ghostty (from SKILL_SEEKER_TERMINAL)
```

从 IDE 终端运行时：
```
🚀 Launching Claude Code in new terminal...
⚠️  unknown TERM_PROGRAM (zed)
   → Using Terminal.app as fallback
```

**提示：** 设置 `SKILL_SEEKER_TERMINAL` 可避免回退行为。

## 故障排除

**问：我已设置 `SKILL_SEEKER_TERMINAL`，但仍打开了错误的终端？**

答：请确保在编辑 `~/.zshrc` 后已重新加载：
```bash
source ~/.zshrc
```

**问：我想临时使用不同的终端？**

答：内联设置变量：
```bash
SKILL_SEEKER_TERMINAL="iTerm" python3 cli/doc_scraper.py --enhance-local ...
```

**问：可以使用自定义终端应用吗？**

答：可以！直接使用 `/Applications/` 中显示的应用名称：
```bash
export SKILL_SEEKER_TERMINAL="Alacritty"
```
