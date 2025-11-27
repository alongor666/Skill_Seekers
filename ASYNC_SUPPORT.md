# 异步支持文档

## 🚀 高性能抓取的异步模式

自本版本起，Skill Seeker 支持异步抓取，在抓取文档网站时显著提升性能。

---

## ⚡ 性能收益

| 指标 | 同步（线程） | 异步 | 提升 |
|------|---------------|------|------|
| **页/秒** | ~15-20 | ~40-60 | **快 2-3 倍** |
| **每 worker 内存** | ~10-15 MB | ~1-2 MB | **降低 80-90%** |
| **最大并发** | ~50-100 | ~500-1000 | **提升 10 倍** |
| **CPU 效率** | 受 GIL 限制 | 充分利用多核 | **显著更好** |

---

## 📋 如何启用异步模式

### 选项 1：命令行标志

```bash
# 启用异步模式并设置 8 个 worker 以获得最佳性能
python3 cli/doc_scraper.py --config configs/react.json --async --workers 8

# 使用异步模式的快速模式
python3 cli/doc_scraper.py --name react --url https://react.dev/ --async --workers 8

# 使用异步模式进行测试性运行
python3 cli/doc_scraper.py --config configs/godot.json --async --workers 4 --dry-run
```

### 选项 2：配置文件

将 `"async_mode": true` 添加到你的配置 JSON 文件中：

```json
{
  "name": "react",
  "base_url": "https://react.dev/",
  "async_mode": true,
  "workers": 8,
  "rate_limit": 0.5,
  "max_pages": 500
}
```

然后正常运行：

```bash
python3 cli/doc_scraper.py --config configs/react-async.json
```

---

## 🎯 推荐设置

### 小型文档 (~100-500 页)
```bash
--async --workers 4
```

### 中型文档 (~500-2000 页)
```bash
--async --workers 8
```

### 大型文档 (2000+ 页)
```bash
--async --workers 8 --no-rate-limit
```

**注意：** 更多的 worker 并不总是更好。先用 4 个测试，然后增加到 8 个，以找到适合你用例的最佳性能。

---

## 🔧 技术实现

### 变更内容

**新方法：**
- `async def scrape_page_async()` - 页面抓取的异步版本
- `async def scrape_all_async()` - 抓取循环的异步版本

**关键技术：**
- **httpx.AsyncClient** - 支持连接池的异步 HTTP 客户端
- **asyncio.Semaphore** - 并发控制（替代 threading.Lock）
- **asyncio.gather()** - 并行任务执行
- **asyncio.sleep()** - 非阻塞式速率限制

**向后兼容性：**
- 异步模式是 **可选的**（默认为同步模式）
- 所有现有配置无需更改即可工作
- 零破坏性变更

---

## 📊 基准测试

### 测试用例：React 文档 (7,102 个字符, 500 页)

**同步模式（线程）：**
```bash
python3 cli/doc_scraper.py --config configs/react.json --workers 8
# 时间：约 45 分钟
# 页/秒：约 18
# 内存：约 120 MB
```

**异步模式：**
```bash
python3 cli/doc_scraper.py --config configs/react.json --async --workers 8
# 时间：约 15 分钟 (快 3 倍！)
# 页/秒：约 55
# 内存：约 40 MB (减少 66%)
```

---

## ⚠️ 重要说明

### 何时使用异步模式

✅ **建议使用异步模式的情况：**
- 抓取 500 页以上
- 使用 4 个以上的 worker
- 网络延迟高
- 内存受限

❌ **不建议使用异步模式的情况：**
- 抓取少于 100 页（开销不划算）
- worker = 1 (没有并行优势)
- 测试/调试（同步模式更简单）

### 速率限制

异步模式和同步模式一样遵循速率限制：
```bash
# 请求之间延迟 0.5 秒 (默认)
--async --workers 8 --rate-limit 0.5

# 无速率限制 (请谨慎使用！)
--async --workers 8 --no-rate-limit
```

### 检查点

异步模式支持检查点，可用于恢复中断的抓取：
```json
{
  "async_mode": true,
  "checkpoint": {
    "enabled": true,
    "interval": 1000
  }
}
```

---

## 🧪 测试

异步模式包含全面的测试：

```bash
# 运行异步相关的特定测试
python -m pytest tests/test_async_scraping.py -v

# 运行所有测试
python cli/run_tests.py
```

**测试覆盖范围：**
- 11 个异步相关的特定测试
- 配置测试
- 路由测试（同步 vs 异步）
- 错误处理
- llms.txt 集成

---

## 🐛 故障排除

### "打开文件过多" 错误

减少 worker 数量：
```bash
--async --workers 4  # 而不是 8
```

### 异步模式比同步模式慢

这可能发生在以下情况：
- worker 数量非常少（建议使用 >= 4）
- 本地网络非常快（异步开销不划算）
- 文档规模小（< 100 页）

**解决方案：** 对小型文档使用同步模式，对大型文档使用异步模式。

### 内存使用仍然很高

异步模式减少了每个 worker 的内存，但是：
- BeautifulSoup 解析仍然是内存密集型操作
- 更多的 worker = 更多的内存

**解决方案：** 使用 4-6 个 worker，而不是 8-10 个。

---

## 📚 示例

### 示例 1：使用异步模式快速抓取

```bash
# Godot 文档 (约 1,600 页)
python3 cli/doc_scraper.py \
  --config configs/godot.json \
  --async \
  --workers 8 \
  --rate-limit 0.3

# 结果：约 12 分钟 (同步模式约 40 分钟)
```

### 示例 2：使用异步模式进行礼貌性抓取

```bash
# Django 文档，使用礼貌的速率限制
python3 cli/doc_scraper.py \
  --config configs/django.json \
  --async \
  --workers 4 \
  --rate-limit 1.0

# 仍然比同步模式快，但对服务器友好
```

### 示例 3：测试异步模式

```bash
# 测试性运行以测试异步模式，不进行实际抓取
python3 cli/doc_scraper.py \
  --config configs/react.json \
  --async \
  --workers 8 \
  --dry-run

# 预览 URL，测试配置
```

---

## 🔮 未来增强

计划对异步模式进行的改进：

- [ ] 基于服务器响应时间的自适应 worker 扩展
- [ ] 连接池优化
- [ ] 异步抓取的进度条
- [ ] 实时性能指标
- [ ] 失败请求的自动重试与退避策略

---

## 💡 最佳实践

1. **从 4 个 worker 开始** - 先测试，如果需要再增加
2. **首先使用 --dry-run** - 在抓取前验证配置
3. **遵守速率限制** - 除非必要，否则不要禁用
4. **监控内存** - 如果内存使用率高，则减少 worker
5. **使用检查点** - 对大型抓取（>1000 页）启用

---

## 📖 其他资源

- **主 README**: [README.md](README.md)
- **技术文档**: [docs/CLAUDE.md](docs/CLAUDE.md)
- **测试套件**: [tests/test_async_scraping.py](tests/test_async_scraping.py)
- **配置指南**: 请参阅 `configs/` 目录中的示例

---

## ✅ 版本信息

- **功能**: 异步支持
- **版本**: 在当前版本中添加
- **状态**: 生产就绪
- **测试覆盖范围**: 11 个异步相关的特定测试，全部通过
- **向后兼容**: 是（可选功能）
