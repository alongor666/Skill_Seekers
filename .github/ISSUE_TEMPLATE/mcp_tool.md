---
name: MCP 工具需求
about: 为 MCP 服务器建议新工具
title: '[MCP] Add tool: '
labels: mcp, enhancement
assignees: ''
---

## 工具名称
<!-- 例如：auto_detect_selectors -->

## 工具描述
<!-- 该工具的作用是什么？ -->

## 输入参数
```json
{
  "param1": {
    "type": "string",
    "description": "...",
    "required": true
  }
}
```

## 期望输出
<!-- 该工具应返回什么？ -->

## 使用示例
<!-- 用户会如何与该工具交互？ -->
```
用户："为 https://docs.example.com 自动检测选择器"
工具：分析页面结构并给出最优选择器建议
```

## CLI 集成
<!-- 该工具封装了哪个 CLI？或为全新逻辑？ -->
- [ ] 封装现有 CLI：`cli/tool_name.py`
- [ ] 全新功能

## 实现说明
<!-- 技术细节、依赖等 -->
