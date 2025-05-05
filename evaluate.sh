#!/bin/bash

# Define variables for multiple datasets and models
DATASETS=("assist2009" "assist2012" "assist2017" "edi2020-task34" "slepemapy-anatomy" "moocradar-C746997" "xes3g5m" "ednet-kt1" "statics2011")
MODELS=("AKT" "DKT" "SimpleKT" "SparseKT")  # Currently we only have AKT models
NUM_FOLDS=5
SETTING_NAME="pykt_setting"
SEED="0"

# Loop through each dataset
for DATASET_NAME in "${DATASETS[@]}"; do
    echo "Processing dataset: $DATASET_NAME"
    
    # Loop through each model
    for MODEL_NAME in "${MODELS[@]}"; do
        echo "Using model: $MODEL_NAME"
        
        # Evaluate models on test data for each fold
        echo "Starting k-fold evaluation for $DATASET_NAME with $MODEL_NAME..."
        for i in $(seq 0 $(($NUM_FOLDS-1))); do
            echo "Evaluating fold $i..."
            # Get the timestamp from existing folder
            TIMESTAMP=$(ls -d ./dataset/dataset/saved_models/${MODEL_NAME}/${MODEL_NAME}@@${SETTING_NAME}@@${DATASET_NAME}_train_fold_${i}@@seed_${SEED}@@* | grep -o "@@[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}@[0-9]\{2\}-[0-9]\{2\}-[0-9]\{2\}$")
            if [ -n "$TIMESTAMP" ]; then
                MODEL_PATTERN="${MODEL_NAME}/${MODEL_NAME}@@${SETTING_NAME}@@${DATASET_NAME}_train_fold_${i}@@seed_${SEED}${TIMESTAMP}"
                echo "Found model: $MODEL_PATTERN"
                python examples/knowledge_tracing/evaluate/sequential_dlkt.py \
                    --model_dir_name "${MODEL_PATTERN}" \
                    --dataset_name ${DATASET_NAME} \
                    --test_file_name ${DATASET_NAME}_test.txt
            else
                echo "Skipping ${DATASET_NAME} fold ${i} - model directory not found"
            fi
        done
    done
done

echo "All evaluations completed!"