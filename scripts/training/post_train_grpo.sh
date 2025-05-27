#!/bin/bash


echo "START TIME: $(date)"
echo "PYTHON ENV: $(which python)"

source "./scripts/set/set_vars.sh"

# export CUDA_VISIBLE_DEVICES=0 # Set the GPUs you want to use
GPU_COUNT=$(python -c "import torch; print(torch.cuda.device_count())")

echo ""
echo "Number of GPUs: ${GPU_COUNT}"
echo ""

MODEL_NAME="DeepSeek-R1-Distill-Qwen-1.5B"

## Main datasets
# DATASET_NAME="curated_deepscaler"
#DATASET_NAME="curated_still"
# DATASET_NAME="curated_open_rs3"
DATASET_NAME="curated_open_rs2"
#DATASET_NAME="curated_open_rs1"

## Extra datasets
#DATASET_NAME="curated_limr"
#DATASET_NAME="curated_open_r1"
#DATASET_NAME="curated_thoughts"

## Ablation
#DATASET_NAME="curated_limr_large_lr_ablation"
#DATASET_NAME="curated_limr_small_lr_ablation"
#DATASET_NAME="curated_limr_large_rank_ablation"
#DATASET_NAME="curated_limr_medium_rank_ablation"
#DATASET_NAME="curated_limr_small_rank_ablation"
#DATASET_NAME="curated_limr_tiny_rank_ablation"
#DATASET_NAME="curated_open_rs3_drgrpo_ablation"

PY_SCRIPT="./tina/post_train_hf/grpo.py"
PY_CONFIG="./recipes/${MODEL_NAME}/grpo/model_${DATASET_NAME}.yaml"
ACCELERATE_DS_CONFIG="./recipes/accelerate_ds_cfgs/ds_zero2.yaml"

echo ""
echo "Running ${PY_SCRIPT} on model ${MODEL_NAME} with dataset ${DATASET_NAME}"
echo ""

if [[ "${DATASET_NAME}" == "curated_thoughts" || "${DATASET_NAME}" == "curated_open_r1" || "${DATASET_NAME}" == "curated_open_rs3" || "${DATASET_NAME}" == "curated_open_rs3_drgrpo_ablation" ]]; then
    ACCELERATE_LOG_LEVEL=info accelerate launch \
        --config_file "${ACCELERATE_DS_CONFIG}" \
        --main_process_port=29500 \
        --num_processes="${GPU_COUNT}" "${PY_SCRIPT}" --config "${PY_CONFIG}" --cosine_max_len 3584
else
    ACCELERATE_LOG_LEVEL=info accelerate launch \
        --config_file "${ACCELERATE_DS_CONFIG}" \
        --main_process_port=29500 \
        --num_processes="${GPU_COUNT}" "${PY_SCRIPT}" --config "${PY_CONFIG}"
fi

echo "END TIME: $(date)"
echo "DONE"
