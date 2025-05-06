rm -rf ./dataset/dataset/saved_models/*
# # Group 1
# CUDA_VISIBLE_DEVICES=2 bash run_one.sh assist2012
# CUDA_VISIBLE_DEVICES=3 bash run_one.sh assist2017
# CUDA_VISIBLE_DEVICES=4 bash run_one.sh statics2011
# CUDA_VISIBLE_DEVICES=5 bash run_one.sh edi2020-task34
# # Wait for Group 1 to finish
# wait

# Group 2
CUDA_VISIBLE_DEVICES=6 bash run_one.sh moocradar-C746997
CUDA_VISIBLE_DEVICES=3 bash run_one.sh slepemapy-anatomy
CUDA_VISIBLE_DEVICES=4 bash run_one.sh ednet-kt1
CUDA_VISIBLE_DEVICES=7 bash run_one.sh xes3g5m

# Wait for Group 2 to finish
wait
