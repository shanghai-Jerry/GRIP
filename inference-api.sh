#!/bin/bash
python inference/agent-api.py \
    --input_file data/inference/test.jsonl \
    --output_file output/output-test.jsonl \
    --max_round 4 \
    --batch_size 32