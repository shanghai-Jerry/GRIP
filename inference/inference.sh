#!/bin/bash

if [ -n "$CUDA_VISIBLE_DEVICES" ] && command -v nvidia-smi &> /dev/null; then
    # Multi-GPU (CUDA)
    NUM_GPUS=$(nvidia-smi -L | wc -l | tr -d ' ')
    torchrun --nproc_per_node=$NUM_GPUS --master_port=29500 $(dirname "$0")/agent.py \
        --model_path "$1" \
        --input_file "$2" \
        --output_file "$3" \
        --max_round "${4:-4}" \
        --batch_size "${5:-32}"
else
    # Single device (MPS or CPU)
    python $(dirname "$0")/agent.py \
        --model_path "$1" \
        --input_file "$2" \
        --output_file "$3" \
        --max_round "${4:-4}" \
        --batch_size "${5:-32}"
fi