# llms.txt 支持

## 概览

在可用的情况下，Skill_Seekers 会自动检测并使用 llms.txt 文件，从而实现约 10 倍速度的文档摄取。

## 什么是 llms.txt？

llms.txt 是一种逐渐流行的约定，文档站点会提供预格式化、适合 LLM 使用的 Markdown 文件：

- `llms-full.txt` — 完整文档
- `llms.txt` — 标准平衡版本
- `llms-small.txt` — 快速参考

## 工作原理

1. 在进行 HTML 抓取之前，Skill_Seekers 会检查是否存在 llms.txt 文件
2. 如果找到，则下载并解析该 Markdown 内容
3. 如果未找到，则自动回退为 HTML 抓取
4. 无需任何额外配置修改

## 配置

### 自动检测（推荐）

无需改动配置，直接运行即可：

```bash
python3 cli/doc_scraper.py --config configs/hono.json
```

### 显式 URL

也可在配置中指定 llms.txt 的 URL：

```json
{
  "name": "hono",
  "llms_txt_url": "https://hono.dev/llms-full.txt",
  "base_url": "https://hono.dev/docs"
}
```

## 性能对比

| 方式 | 耗时 | 请求数 |
|------|------|--------|
| HTML 抓取（20 页） | 20-60s | 20+ |
| llms.txt | < 5s | 1 |

## 已支持站点

已知提供 llms.txt 的站点：

- Hono: https://hono.dev/llms-full.txt
- （持续补充中）

## 回退行为

若 llms.txt 下载或解析失败，将自动无缝回退为 HTML 抓取，无需用户干预。
