# Data Generation

本目录用于生成 GRIP 模型的训练数据。

## make_first_steps.py

数据生成/标注脚本，对问题进行分类，生成四类训练样本。

### 输入格式

```jsonl
{"question": "问题内容", "answer": "答案"}
```

### 输出格式

| 文件 | 分类 | 含义 | 格式 |
|------|------|------|------|
| A.jsonl | Exact Match | 答案完全正确 | `[ANSWER] xxx [SOLVED]` |
| B.jsonl | Cover EM | 答案部分匹配，需要检索 | `[INTERMEDIARY] xxx [RETRIEVE] query` |
| C.jsonl | No Match | 模型答错了，需要检索补充 | `Intermediate_Answer` + 检索结果 |
| D.jsonl | Retrieved | 检索结果包含答案 | 检索后确认正确 |

### 输出字段

```json
{
  "Question": "问题",
  "Output": "模型输出格式",
  "Intermediate_Answer": "模型中间答案",
  "Retrieved_Context": "检索到的文本"
}
```

### 检索

使用 Elasticsearch（索引名 `wiki`）进行词法检索。当模型答不出或答不对时，检索相关上下文作为补充。

### 使用

```bash
python make_first_steps.py \
  --model_dir /path/to/model \
  --input_file /path/to/input.jsonl \
  --output_dir /path/to/output \
  --target 10000  # 每类目标数量
```

### 分类逻辑

1. 用模型生成答案
2. 与 ground truth 比较：
   - 完全匹配 → A 类
   - 答案包含在预测中 → B 类
   - 其他 → C 类
3. 对 C 类进行检索，用检索结果更新
4. 当某类满了后，多余样本作为 D 类候选（检查检索结果是否包含答案）

---

## use_gpt_for_data.py

使用 GPT 模型优化 C 类数据的 prompt 工程脚本。

### 功能

处理 C 类样本（模型答错了，需要检索补充），让 GPT 生成更好的中间答案和检索查询：

1. 结合问题、检索结果、初始中间答案
2. 纠正/完善中间答案中的错误或不完整信息
3. 生成新的检索查询（更可能找到答案证据）

### 输入格式

```jsonl
{"Question": "问题", "Output": "", "Intermediate_Answer": "模型答案", "Retrieved_Context": "检索到的文本"}
```

### 输出格式

```jsonl
{"Question": "问题", "Output": "[INTERMEDIARY] 优化后的中间答案 [RETRIEVE] 新的检索查询", "Intermediate_Answer": "模型答案", "Retrieved_Context": "检索到的文本"}
```

### 配置

修改脚本中的变量：
- `client`: OpenAI API 配置（base_url, api_key）
- `INPUT_FILE`: 输入文件路径
- `OUTPUT_FILE`: 输出文件路径
- `MAX_WORKERS`: 并发数（默认 64）

### 使用

```bash
python use_gpt_for_data.py
```

---

## merge_dataset.py

合并 A/B/C/D 四个分类文件，生成 SFT 和 RL 训练数据。

### 功能

1. 读取 A.jsonl, B.jsonl, C.jsonl, D.jsonl
2. 每个文件取前 10000 条作为 SFT 数据
3. 每个文件取后 1250 条作为 RL 数据
4. 输出 SFT_data.jsonl 和 RL_data.jsonl

### 数据划分

| 输出文件 | 用途 | 每类数量 | 总数量 |
|--------|------|--------|--------|
| SFT_data.jsonl | 有监督微调 | 10000 | 40000 |
| RL_data.jsonl | 强化学习 | 1250 | 5000 |

### 使用

```bash
python merge_dataset.py
```

### 配置

修改脚本中的变量：
- `input_dir`: A/B/C/D 文件所在目录
- `output_jsonl_dir`: 输出目录
- `files_to_merge`: 要合并的文件列表