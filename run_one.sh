#!/bin/bash

# Check if dataset name is provided as argument
if [ $# -eq 0 ]; then
    echo "Error: Dataset name is required"
    echo "Usage: $0 <dataset_name>"
    exit 1
fi

# Define variables for dataset and models
DATASET_NAME="$1"  # Get dataset name from first command line argument
MODELS=("RouterKT")
NUM_FOLDS=5 # Number of folds for k-fold cross-validation
SETTING_NAME="pykt_setting"
SEED="0"

# echo "Clearing saved models..."
# rm -rf ./dataset/dataset/saved_models/*

# echo "Processing dataset: $DATASET_NAME"

# Loop through each model
for MODEL_NAME in "${MODELS[@]}"; do
    echo "Using model: $MODEL_NAME"
    
    # Determine the correct training script based on the model
    if [ "$MODEL_NAME" == "DKT" ]; then
        TRAIN_SCRIPT="examples/knowledge_tracing/train/dkt.py"
    elif [ "$MODEL_NAME" == "RouterKT" ]; then
        TRAIN_SCRIPT="examples/knowledge_tracing/train/router_kt.py"
    elif [ "$MODEL_NAME" == "AKT" ]; then
        TRAIN_SCRIPT="examples/knowledge_tracing/train/akt.py"
    else
        echo "Unknown model: $MODEL_NAME, skipping..."
        continue
    fi
    
    echo "Starting k-fold training for $DATASET_NAME with $MODEL_NAME..."
    for i in $(seq 0 $(($NUM_FOLDS-1))); do
        echo "Training fold $i..."
        python "$TRAIN_SCRIPT" \
            --train_file_name ${DATASET_NAME}_train_fold_${i}.txt \
            --valid_file_name ${DATASET_NAME}_valid_fold_${i}.txt \
            --save_model True \
            --setting_name ${SETTING_NAME} \
            --dataset_name ${DATASET_NAME} \
            --train_batch_size 512
    done

    # Second loop: Evaluate models on test data for each fold
    echo "Starting k-fold evaluation for $DATASET_NAME with $MODEL_NAME..."
    for i in $(seq 0 $(($NUM_FOLDS-1))); do
        echo "Evaluating fold $i..."
        # Define the model directory pattern without including the full path
        # This avoids the path duplication issue
        MODEL_PATTERN="${MODEL_NAME}@@${SETTING_NAME}@@${DATASET_NAME}_train_fold_${i}@@seed_${SEED}@@"
        python examples/knowledge_tracing/evaluate/sequential_dlkt.py \
            --model_dir_name "${MODEL_PATTERN}" \
            --dataset_name ${DATASET_NAME} \
            --test_file_name ${DATASET_NAME}_test.txt \
            --evaluate_batch_size 512
    done
done

echo "All models and datasets processing completed!"