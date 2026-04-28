# Eval

评估模块，计算模型预测的准确率指标。

---

## eval.py

主评估脚本，计算多种评估指标。

### 评估指标

| 指标 | 说明 |
|------|------|
| EM (Exact Match) | 精确匹配率 |
| Cover EM | 预测包含答案的匹配率 |
| F1 | F1 分数 |
| ROUGE | ROUGE-1/2/L 分数 |

### 输入格式

**Reference 文件**：
```jsonl
{"question": "问题", "answer": "答案"}
```

**Prediction 文件**：
```jsonl
{"question": "问题", "prediction": "模型预测"}
```

### 使用

```bash
python eval.py \
  --references_path /path/to/reference.jsonl \
  --predictions_path /path/to/prediction.jsonl \
  --answer_field answer
```

### 输出示例

```
======== Data Statistic ========
Total questions: 1000    Missing predictions: 0
==================================================
Exact Match Score:
EM: 0.8500 (850/1000)

F1 Score:
F1: 0.8234

ROUGE Score:
ROUGE: 0.7912
==================================================
```

---

## utils.py

评估工具函数模块。

### 函数

| 函数 | 说明 |
|------|------|
| `normalize_answer()` | 标准化答案（去除冠词、标点、空格，转小写） |
| `em_score()` | 精确匹配 |
| `cover_em_score()` | 覆盖匹配（答案是否在预测中） |
| `f1_score()` | F1 分数 |
| `evaluate_predictions()` | 主评估函数，读取文件并计算指标 |
| `evaluate_predictions_impl()` | 内部实现，基于字典计算指标 |

### 标准化流程

1. 转小写
2. 去除标点符号
3. 去除冠词 (a, an, the)
4. 修复多余空格