python3 -c "import jax; print(jax.device_count()); print(jax.local_device_count())"

# Model dir to save logs, ckpts, etc. in "gs://model_dir" format.
ORIGINAL_EXPERIMENT_NAME=$1

if [[ $ORIGINAL_EXPERIMENT_NAME == *t0_adapt* ]]
then
  echo "I don't know how much T0 adaptation one has to do, so I don't know the correct checkpoint"
  exit 1
else
  CHECKPOINT_STEP=524288
fi

EXPERIMENT_NAME=$ORIGINAL_EXPERIMENT_NAME"_t0_eval_"$CHECKPOINT_STEP
CHECKPOINT_DIR="gs://bigscience-t5x/arch_objective_exps/$ORIGINAL_EXPERIMENT_NAME/checkpoint_$CHECKPOINT_STEP"
#MODEL_DIR="gs://bigscience-t5x/arch_objective_exps/$EXPERIMENT_NAME"

# directory where the T5X repo is cloned.
T5X_DIR="/home/thomas/code/t5x"
export PYTHONPATH=${T5X_DIR}/bigscience/gins

# Logs
LOGS_PATH="/home/thomas/logs"
mkdir -p $LOGS_PATH

if [[ $ORIGINAL_EXPERIMENT_NAME == c_dec* ]]
then
  MODEL_GIN_FILE=c_dec_xxl.gin
fi
if [[ $ORIGINAL_EXPERIMENT_NAME == nc_dec* ]]
then
  MODEL_GIN_FILE=nc_dec_xxl.gin
fi
if [[ $ORIGINAL_EXPERIMENT_NAME == enc_dec* ]]
then
  MODEL_GIN_FILE=enc_dec_xxl.gin
fi
if [[ $GIN_FILE == "" ]]
then
  echo "Incorrect experiment name $ORIGINAL_EXPERIMENT_NAME, does not start with c_dec/nc_dec/enc_dec"
  exit
fi

python3 ${T5X_DIR}/t5x/eval.py \
  --gin_file="$MODEL_GIN_FILE" \
  --gin_file="bigscience/gins/eval_t0.gin" \
  --gin.CHECKPOINT_PATH="'$CHECKPOINT_DIR'" \
  --gin.OUTPUT_DIR="'/home/thomas/arch_objective_exps/$EXPERIMENT_NAME'" \
  2>&1 | tee $LOGS_PATH/t0_eval_$EXPERIMENT_NAME.txt