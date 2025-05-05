#!/bin/bash

# Define variables for multiple datasets and models
# DATASETS=("assist2012" "assist2017" "statics2011" "edi2020-task34" "slepemapy-anatomy" "moocradar-C746997" "xes3g5m" "ednet-kt1" "assist2009")
# DATASETS=("assist2009" "assist2012")
# MODELS=("DKT" "RouterKT" "AKT")
DATASETS=("statics2011")
MODELS=("RouterKT")
NUM_FOLDS=5 # Number of folds for k-fold cross-validation
SETTING_NAME="pykt_setting"
SEED="0"

# # # Prepare datasets
echo "Preparing datasets..."
for DATASET_NAME in "${DATASETS[@]}"; do
    echo "Preparing dataset: $DATASET_NAME"
    python examples/knowledge_tracing/prepare_dataset/pykt_setting.py --dataset_name ${DATASET_NAME}
done

# echo "Clearing saved models..."
# rm -rf ./dataset/dataset/saved_models/*

# Loop through each dataset
for DATASET_NAME in "${DATASETS[@]}"; do
    echo "Processing dataset: $DATASET_NAME"
    
    # Loop through each model
    for MODEL_NAME in "${MODELS[@]}"; do
        echo "Using model: $MODEL_NAME"
        
        # # Determine the correct training script based on the model
        # if [ "$MODEL_NAME" == "DKT" ]; then
        #     TRAIN_SCRIPT="examples/knowledge_tracing/train/dkt.py"
        # elif [ "$MODEL_NAME" == "RouterKT" ]; then
        #     TRAIN_SCRIPT="examples/knowledge_tracing/train/router_kt.py"
        # elif [ "$MODEL_NAME" == "AKT" ]; then
        #     TRAIN_SCRIPT="examples/knowledge_tracing/train/akt.py"
        # else
        #     echo "Unknown model: $MODEL_NAME, skipping..."
        #     continue
        # fi
        
        # echo "Starting k-fold training for $DATASET_NAME with $MODEL_NAME..."
        # for i in $(seq 0 $(($NUM_FOLDS-1))); do
        #     echo "Training fold $i..."
        #     python "$TRAIN_SCRIPT" \
        #         --train_file_name ${DATASET_NAME}_train_fold_${i}.txt \
        #         --valid_file_name ${DATASET_NAME}_valid_fold_${i}.txt \
        #         --save_model True \
        #         --setting_name ${SETTING_NAME} \
        #         --dataset_name ${DATASET_NAME}
        # done

        # Second loop: Evaluate models on test data for each fold
        echo "Starting k-fold evaluation for $DATASET_NAME with $MODEL_NAME..."
        for i in $(seq 0 $(($NUM_FOLDS-1))); do
            echo "Evaluating fold $i..."
            # First find the matching model directory using bash glob
            MODEL_PATTERN="${MODEL_NAME}@@${SETTING_NAME}@@${DATASET_NAME}_train_fold_${i}@@seed_${SEED}@@*@*"
            MODEL_DIR=$(ls -d ./dataset/dataset/saved_models/${MODEL_PATTERN} 2>/dev/null | head -n 1)
            
            if [ -z "$MODEL_DIR" ]; then
                echo "No matching model directory found for pattern: ${MODEL_PATTERN}"
                continue
            fi
            
            # Convert to absolute path and remove any duplicate path components
            MODEL_DIR=$(realpath "$MODEL_DIR")
            echo "Found model directory: ${MODEL_DIR}"
            python examples/knowledge_tracing/evaluate/sequential_dlkt.py \
                --model_dir_name "${MODEL_DIR}" \
                --dataset_name ${DATASET_NAME} \
                --test_file_name ${DATASET_NAME}_test.txt
        done
    done
done

echo "All models and datasets processing completed!"