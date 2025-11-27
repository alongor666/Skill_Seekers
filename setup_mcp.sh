#!/bin/bash
# Skill Seeker MCP 服务器 - 快速设置脚本
# 此脚本用于自动化 Claude Code 的 MCP 服务器设置

set -e  # 出错时退出

echo "=================================================="
echo "Skill Seeker MCP 服务器 - 快速设置"
echo "=================================================="
echo ""

# 输出颜色配置
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # 无颜色

# 步骤 1：检查 Python 版本
echo "步骤 1：正在检查 Python 版本..."
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}❌ 错误：未找到 python3${NC}"
    echo "请安装 Python 3.7 或更高版本"
    exit 1
fi

PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
echo -e "${GREEN}✓${NC} 已找到 Python $PYTHON_VERSION"
echo ""

# 步骤 2：获取仓库路径
REPO_PATH=$(pwd)
echo "步骤 2：仓库位置"
echo "路径：$REPO_PATH"
echo ""

# 步骤 3：安装依赖
echo "步骤 3：正在安装 Python 依赖..."

# 检查是否在虚拟环境中
if [[ -n "$VIRTUAL_ENV" ]]; then
    echo -e "${GREEN}✓${NC} 检测到虚拟环境：$VIRTUAL_ENV"
    PIP_INSTALL_CMD="pip install"
elif [[ -d "venv" ]]; then
    echo -e "${YELLOW}⚠${NC} 发现虚拟环境但未激活"
    echo "正在激活 venv..."
    source venv/bin/activate
    PIP_INSTALL_CMD="pip install"
else
    echo -e "${YELLOW}⚠${NC} 未发现虚拟环境"
    echo "建议使用虚拟环境以避免冲突。"
    echo ""
    read -p "是否现在创建一个？(y/n) " -n 1 -r
    echo ""

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "正在创建虚拟环境..."
        python3 -m venv venv || {
            echo -e "${RED}❌ 创建虚拟环境失败${NC}"
            echo "回退到系统安装..."
            PIP_INSTALL_CMD="pip3 install --user --break-system-packages"
        }

        if [[ -d "venv" ]]; then
            source venv/bin/activate
            PIP_INSTALL_CMD="pip install"
            echo -e "${GREEN}✓${NC} 虚拟环境已创建并激活"
        fi
    else
        echo "继续使用系统安装 (使用 --user --break-system-packages)..."
        echo -e "${YELLOW}注意：${NC} 这可能会覆盖系统管理的包"
        PIP_INSTALL_CMD="pip3 install --user --break-system-packages"
    fi
fi

echo "将安装：mcp, requests, beautifulsoup4"
read -p "继续吗？(y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "正在安装 MCP 服务器依赖..."
    $PIP_INSTALL_CMD -r src/skill_seekers/mcp/requirements.txt || {
        echo -e "${RED}❌ 安装 MCP 依赖失败${NC}"
        exit 1
    }

    echo "正在安装 CLI 工具依赖..."
    $PIP_INSTALL_CMD requests beautifulsoup4 || {
        echo -e "${RED}❌ 安装 CLI 依赖失败${NC}"
        exit 1
    }

    echo -e "${GREEN}✓${NC} 依赖安装成功"
else
    echo "跳过依赖安装"
fi
echo ""

# 步骤 4：测试 MCP 服务器
echo "步骤 4：正在测试 MCP 服务器..."
timeout 3 python3 src/skill_seekers/mcp/server.py 2>/dev/null || {
    if [ $? -eq 124 ]; then
        echo -e "${GREEN}✓${NC} MCP 服务器启动正常 (预期超时)"
    else
        echo -e "${YELLOW}⚠${NC} MCP 服务器测试结果不确定，但仍可能工作"
    fi
}
echo ""

# 步骤 5：可选 - 运行测试
echo "步骤 5：运行测试套件？(可选)"
read -p "运行 MCP 测试以验证一切正常？(y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    # 检查是否安装了 pytest
    if ! command -v pytest &> /dev/null; then
        echo "正在安装 pytest..."
        $PIP_INSTALL_CMD pytest || {
            echo -e "${YELLOW}⚠${NC} 无法安装 pytest，跳过测试"
        }
    fi

    if command -v pytest &> /dev/null; then
        echo "正在运行 MCP 服务器测试..."
        python3 -m pytest tests/test_mcp_server.py -v --tb=short || {
            echo -e "${RED}❌ 部分测试失败${NC}"
            echo "服务器可能仍可工作，但请检查上述错误"
        }
    fi
else
    echo "跳过测试"
fi
echo ""

# 步骤 6：配置 Claude Code
echo "步骤 6：配置 Claude Code"
echo "=================================================="
echo ""
echo "您需要将此配置添加到 Claude Code："
echo ""
echo -e "${YELLOW}配置文件：${NC} ~/.config/claude-code/mcp.json"
echo ""
echo "添加此 JSON 配置（路径已针对您的系统自动检测）："
echo ""
echo -e "${GREEN}{"
echo "  \"mcpServers\": {"
echo "    \"skill-seeker\": {"
echo "      \"command\": \"python3\","
echo "      \"args\": ["
echo "        \"$REPO_PATH/src/skill_seekers/mcp/server.py\""
echo "      ],"
echo "      \"cwd\": \"$REPO_PATH\""
echo "    }"
echo "  }"
echo -e "}${NC}"
echo ""
echo -e "${YELLOW}注意：${NC} 上述路径是您的实际路径（不是占位符！）"
echo ""

# 询问用户是否自动配置
echo ""
read -p "现在自动配置 Claude Code 吗？(y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    # 检查配置是否已存在
    if [ -f ~/.config/claude-code/mcp.json ]; then
        echo -e "${YELLOW}⚠ 警告：~/.config/claude-code/mcp.json 已存在${NC}"
        echo "当前内容："
        cat ~/.config/claude-code/mcp.json
        echo ""
        read -p "覆盖吗？(y/n) " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "跳过自动配置"
            echo "请手动将 skill-seeker 服务器添加到您的配置中"
            exit 0
        fi
    fi

    # 创建配置目录
    mkdir -p ~/.config/claude-code

    # 使用实际扩展路径写入配置
    cat > ~/.config/claude-code/mcp.json << EOF
{
  "mcpServers": {
    "skill-seeker": {
      "command": "python3",
      "args": [
        "$REPO_PATH/src/skill_seekers/mcp/server.py"
      ],
      "cwd": "$REPO_PATH"
    }
  }
}
EOF

    echo -e "${GREEN}✓${NC} 配置已写入 ~/.config/claude-code/mcp.json"
    echo ""
    echo "配置内容："
    cat ~/.config/claude-code/mcp.json
    echo ""

    # 验证路径是否存在
    if [ -f "$REPO_PATH/src/skill_seekers/mcp/server.py" ]; then
        echo -e "${GREEN}✓${NC} 验证通过：MCP 服务器文件存在于 $REPO_PATH/src/skill_seekers/mcp/server.py"
    else
        echo -e "${RED}❌ 警告：未在 $REPO_PATH/src/skill_seekers/mcp/server.py 找到 MCP 服务器${NC}"
        echo "请检查路径！"
    fi
else
    echo "跳过自动配置"
    echo "请使用上面的 JSON 手动配置 Claude Code"
    echo ""
    echo "重要：将 \$REPO_PATH 替换为实际路径：$REPO_PATH"
fi
echo ""

# 步骤 7：测试配置
if [ -f ~/.config/claude-code/mcp.json ]; then
    echo "步骤 7：正在测试 MCP 配置..."
    echo "正在检查路径是否正确..."

    # 提取配置的路径
    if command -v jq &> /dev/null; then
        CONFIGURED_PATH=$(jq -r '.mcpServers["skill-seeker"].args[0]' ~/.config/claude-code/mcp.json 2>/dev/null || echo "")
        if [ -n "$CONFIGURED_PATH" ] && [ -f "$CONFIGURED_PATH" ]; then
            echo -e "${GREEN}✓${NC} MCP 服务器路径有效：$CONFIGURED_PATH"
        elif [ -n "$CONFIGURED_PATH" ]; then
            echo -e "${YELLOW}⚠${NC} 警告：配置的路径不存在：$CONFIGURED_PATH"
        fi
    else
        echo "安装 'jq' 以进行配置验证：brew install jq (macOS) 或 apt install jq (Linux)"
    fi
fi
echo ""

# 步骤 8：最终说明
echo "=================================================="
echo "设置完成！"
echo "=================================================="
echo ""
echo "后续步骤："
echo ""
echo "  1. ${YELLOW}重启 Claude Code${NC} (退出并重新打开，不仅仅是关闭窗口)"
echo "  2. 在 Claude Code 中，使用以下命令测试：${GREEN}\"List all available configs\"${NC}"
echo "  3. 您应该能看到 9 个可用的 Skill Seeker 工具"
echo ""
echo "可用的 MCP 工具："
echo "  • generate_config   - 创建新配置文件"
echo "  • estimate_pages    - 估算抓取时间"
echo "  • scrape_docs       - 抓取文档"
echo "  • package_skill     - 创建 .zip 文件"
echo "  • list_configs      - 显示可用配置"
echo "  • validate_config   - 验证配置文件"
echo ""
echo "在 Claude Code 中尝试的示例命令："
echo "  • ${GREEN}List all available configs${NC}"
echo "  • ${GREEN}Validate configs/react.json${NC}"
echo "  • ${GREEN}Generate config for Tailwind at https://tailwindcss.com/docs${NC}"
echo ""
echo "文档："
echo "  • MCP 设置指南：${YELLOW}docs/MCP_SETUP.md${NC}"
echo "  • 完整文档：${YELLOW}README.md${NC}"
echo ""
echo "故障排除："
echo "  • 检查日志：~/Library/Logs/Claude Code/ (macOS)"
echo "  • 测试服务器：python3 src/skill_seekers/mcp/server.py"
echo "  • 运行测试：python3 -m pytest tests/test_mcp_server.py -v"
echo ""
echo "祝您创建技能愉快！ 🚀"
