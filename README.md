# What Language Model Architecture and Pretraining Objective Work Best for Zero-Shot Generalization?

Large pretrained Transformer language models have been shown to exhibit *zero-shot generalization*, i.e. they can perform a wide variety of tasks that they were not explicitly trained on.
However, the architectures and pretraining objectives used across state-of-the-art models differ significantly, and there has been limited systematic comparison of these factors.
In this work, we present a large-scale evaluation of modeling choices and their impact on zero-shot generalization.
In particular, we focus on text-to-text models and experiment with three model architectures (causal/non-causal decoder-only and encoder-decoder), trained with two different pretraining objectives (autoregressive and masked language modeling), and evaluated with and without multitask prompted finetuning. 
We train models with over 5 billion parameters for more than 168 billion tokens, thereby increasing the likelihood that our conclusions will transfer to even larger scales.
Our experiments show that causal decoder-only models trained on an autoregressive language modeling objective exhibit the strongest zero-shot generalization after purely self-supervised pretraining.
However, models with non-causal visibility on their input trained with a masked language modeling objective followed by multitask finetuning perform the best among our experiments.
We therefore consider the adaptation of pretrained models across architectures and objectives.
Code and checkpoints are available at [https://github.com/bigscience-workshop/architecture-objective](https://github.com/bigscience-workshop/architecture-objective).

Full paper is available at: https://arxiv.org/abs/2204.05832

## Checkpoints

// TODO (@thomasw21):  link to checkpoints.

| checkpoints | path |
|-------------|------|
| CD:FLM (168B) | gs://bigscience-t5x/arch_objective_exps_v2/c_dec_c4_full_lm_bs2048/checkpoint_131072 |
| ND:PLM (168B) | gs://bigscience-t5x/arch_objective_exps_v2/nc_dec_c4_prefix_lm_bs2048/checkpoint_131072 |
| ED:PLM (168B) | gs://bigscience-t5x/arch_objective_exps_v2/enc_dec_c4_prefix_lm_bs2048/checkpoint_131072 |
| CD:FLM (168B) + CD:MTF (13B) | gs://bigscience-t5x/arch_objective_exps_v2/dropout_reruns/cd_flm_131072-cd_mtf_141072/checkpoint_141072 |
| ND:PLM (168B) + ND:MTF (13B) | gs://bigscience-t5x/arch_objective_exps_v2/dropout_reruns/nd_plm_131072-nd_mtf_141072/checkpoint_141072 |
| ED:PLM (168B) + ED:MTF (13B) | gs://bigscience-t5x/arch_objective_exps_v2/dropout_reruns/ed_plm_131072-ed_mtf_141072/checkpoint_141072 |
| CD:MLM (168B) + CD:MTF (13B) | gs://bigscience-t5x/arch_objective_exps_v2/dropout_reruns/cd_mlm_131072-cd_mtf_141072/checkpoint_141072 |
| ND:MLM (168B) + ND:MTF (13B) | gs://bigscience-t5x/arch_objective_exps_v2/dropout_reruns/nd_mlm_131072-nd_mtf_141072/checkpoint_141072 |
| ED:MLM (168B) + ED:MTF (13B) | gs://bigscience-t5x/arch_objective_exps_v2/dropout_reruns/ed_mlm_131072-ed_mtf_141072/checkpoint_141072 |
| CD:FLM (219B) | TODO @thomasw21 |
| CD:FLM (219B) + ND:MTF (13B) | gs://bigscience-t5x/arch_objective_exps_v2/dropout_reruns/cd_flm_171008-cd_mtf_181008/checkpoint_181008 |
| CD:FLM (219B) + ND:MTF (13B) | gs://bigscience-t5x/arch_objective_exps_v2/dropout_reruns/cd_flm_171008-nd_mtf_181008/checkpoint_181008 |
| CD:FLM (168B) + ND:MLM (51B) | gs://bigscience-t5x/arch_objective_exps_v2/dropout_reruns/cd_flm_131072-nd_mlm_171008/checkpoint_171008 |
| CD:FLM (168B) + ND:MLM (51B) + MTF (13B)| gs://bigscience-t5x/arch_objective_exps_v2/dropout_reruns/cd_flm_131072-nd_mlm_171008-nd_mtf_181008/checkpoint_181008 |

## How to cite

    @article{wang2022language,
      title={What Language Model Architecture and Pretraining Objective Work Best for Zero-Shot Generalization?},
      author={Wang, Thomas and Roberts, Adam and Hesslow, Daniel and Scao, Teven Le and Chung, Hyung Won and Beltagy, Iz and Launay, Julien and Raffel, Colin},
      journal={arXiv preprint arXiv:2204.05832},
      year={2022}
    }




# T5X

T5X is a modular, composable, research-friendly framework for high-performance,
configurable, self-service training, evaluation, and inference of sequence
models (starting with language) at many scales.

It is essentially a new and improved implementation of the
[T5 codebase](https://github.com/google-research/text-to-text-transfer-transformer)
(based on [Mesh TensorFlow](https://github.com/tensorflow/mesh)) in [JAX](https://github.com/google/jax) and [Flax](https://github.com/google/flax).

## Installation

Note that all the commands in this document should be run in the commandline of
the TPU VM instance unless otherwise stated.

1.  Follow the
    [instructions](https://cloud.google.com/tpu/docs/jax-quickstart-tpu-vm#install_the_google_cloud_sdk)
    to set up a Google Cloud Platform (GCP) account and enable the Cloud TPU
    API.

    **Note:** While T5X works with GPU as well, we haven't heavily tested the
    GPU usage.

2.  Create a
    [Cloud TPU VM instance](https://cloud.google.com/blog/products/compute/introducing-cloud-tpu-vms)
    following
    [this instruction](https://cloud.google.com/tpu/docs/jax-quickstart-tpu-vm#create-vm).
    We recommend that you develop your workflow in a single v3-8 TPU (i.e.,
    `--accelerator-type=v3-8`) and scale up to pod slices once the pipeline is
    ready. In this README, we focus on using a single v3-8 TPU. See
    [here](https://cloud.google.com/tpu/docs/system-architecture-tpu-vm) to
    learn more about TPU architectures.

3.  With Cloud TPU VMs, you ssh directly into the host machine of the TPU VM.
    You can install packages, run your code run, etc. in the host machine. Once
    the TPU instance is created, ssh into it with

    ```sh
    gcloud alpha compute tpus tpu-vm ssh ${TPU_NAME} --zone=${ZONE}
    ```

    where `TPU_NAME` and `ZONE` are the name and the zone used in step 2.

4.  Install T5X and the dependencies. JAX and Gin-config need to be installed
    from the source.

    ```sh
    git clone --branch=main https://github.com/google-research/t5x
    cd t5x

    python3 -m pip install -e . -f \
      https://storage.googleapis.com/jax-releases/libtpu_releases.html

    ```


5.  Create toogle Cloud Storage (GCS) bucket to store the dataset and model
    checkpoints. To create a GCS bucket, see these
    [instructions](https://cloud.google.com/storage/docs/creating-buckets).

## Example: English to German translation

As a running example, we use the WMT14 En-De translation. The raw dataset is
available in TensorFlow Datasets as
["wmt_t2t_translate"](https://www.tensorflow.org/datasets/catalog/wmt_t2t_translate).

T5 casts the translation task such as the following

```py
{'en': 'That is good.', 'de': 'Das ist gut.'}
```

to the form called "text-to-text":

```py
{'inputs': 'translate English to German: That is good.', 'targets': 'Das ist gut.'}
```

This formulation allows many different classes of language tasks to be expressed
in a uniform manner and a single encoder-decoder architecture can handle them
without any task-specific parameters. For more detail, refer to the [T5 paper
(Raffel et al. 2019)][t5_paper].

For a scalable data pipeline and an evaluation framework, we use
[`SeqIO`](https://github.com/google/seqio), which was factored out of the [T5
library][t5_github]. A `seqio.Task` packages together the raw dataset, vocabulary,
preprocessing such as tokenization and evaluation metrics such as
[BLEU](https://aclanthology.org/P02-1040.pdf) and provides a
[`tf.data`](https://www.tensorflow.org/guide/data) instance.

[The T5 library][t5_github] provides a number of `seqio.Task`s that were used in the
[T5 paper][t5_paper]. In this example, we use [wmt_t2t_ende_v003](https://github.com/google-research/text-to-text-transfer-transformer/blob/d81c0bab2a41b4d5dfbe4971de32f7d67df65f31/t5/data/tasks.py#L212).


### Training

To run a training job, we use the `t5x/train.py` script.

```sh
# Model dir to save logs, ckpts, etc. in "gs://model_dir" format.
MODEL_DIR="..."

# Data dir to save the processed dataset in "gs://data_dir" format.
TFDS_DATA_DIR="..."
T5X_DIR="..."  # directory where the T5X repo is cloned.

python3 ${T5X_DIR}/t5x/train.py \
  --gin_file="t5x/examples/t5/t5_1_1/examples/t5_1_1_base_wmt_from_scratch.gin" \
  --gin.MODEL_DIR="'${MODEL_DIR}'" \
  --tfds_data_dir=${TFDS_DATA_DIR}
```

The configuration for this training run is defined in the Gin file
[t5_1_1_base_wmt_from_scratch.gin](t5x/examples/t5/t5_1_1/examples/t5_1_1_base_wmt_from_scratch.gin).
[Gin-config](https://github.com/google/gin-config) is a library to handle
configurations based on dependency injection. Among many benefits, Gin allows
users to pass custom components such as a custom model to the T5X library
without having to modify the core library. The [custom
components](#custom-components) section shows how this is done.

While the core library is independent of Gin, it is central to the examples we
provide. Therefore, we provide a short [introduction][gin-primer] to Gin in the
context of T5X.  All the configurations are written to a file "config.gin" in
`MODEL_DIR`. This makes debugging as well as reproducing the experiment much
easier.

In addition to the `config.json`, `model-info.txt` file summarizes the model
parameters (shape, names of the axes, partitioning info) as well as the
optimizer states.



#### TensorBoard

To monitor the training in [TensorBoard](https://www.tensorflow.org/tensorboard), it is much easier (due to
authentification issues) to launch the TensorBoard on your own machine and _not_ in
the TPU VM. So in the commandline where you ssh'ed into the TPU VM, launch the
TensorBoard with the `logdir` pointing to the `MODEL_DIR`.

```sh
# NB: run this on your machine not TPU VM!
MODEL_DIR="..."  # Copy from the TPU VM.
tensorboard --logdir=${MODEL_DIR}
```

Or you can launch the TensorBoard inside a Colab. In a Colab cell, run

```python
from google.colab import auth
auth.authenticate_user()
```

to authorize the Colab to access the GCS bucket and launch the TensorBoard.

```python
%load_ext tensorboard
model_dir = "..."  # Copy from the TPU VM.
%tensorboard --logdir=model_dir
```

TODO(hwchung): Add tfds preparation instruction


### Fine-tuning

We can leverage the benefits of self-supervised pre-training by initializing
from one of our pre-trained models. Here we use the T5.1.1 Base checkpoint.

```sh
# Model dir to save logs, ckpts, etc. in "gs://model_dir" format.
MODEL_DIR="..."

# Data dir to save the processed dataset in "gs://data_dir" format.
TFDS_DATA_DIR="..."
T5X_DIR="..."  # directory where the T5X repo is cloned.

python3 ${T5X_DIR}/t5x/train.py \
  --gin_file="t5x/examples/t5/t5_1_1/examples/t5_1_1_base_wmt_finetune.gin" \
  --gin.MODEL_DIR="'${MODEL_DIR}'" \
  --tfds_data_dir=${TFDS_DATA_DIR}
```

**Note:** when supplying a string, dict, list, tuple value, or a bash variable
via a flag, you must put it in quotes. In the case of strings, it requires
"triple quotes" (`"'<string>'"`). For example:
`--gin.utils.DatasetConfig.split="'validation'"` or
`--gin.MODEL_DIR="'${MODEL_DIR}'"`.

Gin makes it easy to change a number of configurations. For example, you can
change the `partitioning.ModelBasedPjitPartitioner.num_partitions` (overriding
the value in
[t5_1_1_base_wmt_from_scratch.gin](t5x/examples/t5/t5_1_1/examples/t5_1_1_base_wmt_from_scratch.gin))
to chanage the parallelism strategy and pass it as a commandline arg.

```sh
--gin.partitioning.ModelBasedPjitPartitioner.num_partitions=8
```








### Evaluation

To run the offline (i.e. without training) evaluation, you can use `t5x/eval.py`
script.

```sh
EVAL_OUTPUT_DIR="..."  # directory to write eval output
T5X_DIR="..."  # directory where the t5x is cloned, e.g., ${HOME}"/t5x".
TFDS_DATA_DIR="..."
CHECKPOINT_PATH="..."

python3 ${T5X_DIR}/t5x/eval.py \
  --gin_file="t5x/examples/t5/t5_1_1/examples/t5_1_1_base_wmt_eval.gin" \
  --gin.CHECKPOINT_PATH="'${CHECKPOINT_PATH}'" \
  --gin.EVAL_OUTPUT_DIR="'${EVAL_OUTPUT_DIR}'" \
  --tfds_data_dir=${TFDS_DATA_DIR}
```


### Inference

To run inference, you can use `t5x/infer.py` script. Here we use the same
`seqio.Task`, but for inference we do not use the targets features other than
logging them alongside the prediction in a JSON file.

```sh
INFER_OUTPUT_DIR="..."  # directory to write infer output
T5X_DIR="..."  # directory where the t5x is cloned, e.g., ${HOME}"/t5x".
TFDS_DATA_DIR="..."
CHECKPOINT_PATH="..."

python3 ${T5X_DIR}/t5x/infer.py \
  --gin_file="t5x/examples/t5/t5_1_1/examples/t5_1_1_base_wmt_infer.gin" \
  --gin.CHECKPOINT_PATH="'${CHECKPOINT_PATH}'" \
  --gin.INFER_OUTPUT_DIR="'${INFER_OUTPUT_DIR}'" \
  --tfds_data_dir=${TFDS_DATA_DIR}
```



## Custom components

[The translation example](#example-english-to-german-translation) uses the
encoder-decoder model that T5X provides as well as the dataset from the T5
library. This section shows how you can use your own dataset and a model and
pass via Gin.

### Example: custom dataset in a user directory

For this example, we have the following directory structure with
`${HOME}/dir1/user_dir` representing a user directory with custom components.

```
${HOME}
└── dir1
    └── user_dir
        ├── t5_1_1_base_de_en.gin
        └── tasks.py
```

As an example, let's define a new dataset. Here we use the same Translation
dataset but we define the translation task in the opposite direction, i.e.,
German to English intead of English to German. We define this task in `tasks.py`

```py
# ${HOME}/dir1/user_dir/tasks.py

import functools
import seqio
import tensorflow_datasets as tfds
from t5.evaluation import metrics
from t5.data import preprocessors

vocabulary = seqio.SentencePieceVocabulary(
    'gs://t5-data/vocabs/cc_all.32000/sentencepiece.model', extra_ids=100)
output_features = {
    'inputs': seqio.Feature(vocabulary=vocabulary),
    'targets': seqio.Feature(vocabulary=vocabulary)
}

seqio.TaskRegistry.add(
    'wmt_t2t_de_en_v003',
    source=seqio.TfdsDataSource(tfds_name='wmt_t2t_translate/de-en:1.0.0'),
    preprocessors=[
        functools.partial(
            preprocessors.translate,
            source_language='de', target_language='en'),
        seqio.preprocessors.tokenize,
        seqio.CacheDatasetPlaceholder(),
        seqio.preprocessors.append_eos_after_trim,
    ],
    metric_fns=[metrics.bleu],
    output_features=output_features)
```

In the Gin file, most of the settings are equivalent to those used in the
[En->De example](#example-english-to-german-translation). So we include the Gin
file from that example. To use "wmt_t2t_de_en_v003" task we just defined, we
need to import the task module "tasks.py". Note that we use a relative path
defined with respect to the user directory. This will be specified as a
flag.

```py
# ${HOME}/dir1/user_dir/t5_1_1_base_de_en.gin
from __gin__ import dynamic_registration
import tasks  # This imports the task defined in dir1/user_dir/tasks.py.

include "t5x-tmp/t5x/examples/t5/t5_1_1/examples/t5_1_1_base_wmt_from_scratch.gin"
MIXTURE_OR_TASK_NAME = "wmt_t2t_de_en_v003"
```

Finally, we launch training passing the user directory as a flag
`gin_search_paths` such that the Gin file and python modules can be specified
with relative paths.

```sh
PROJECT_DIR=${HOME}"/dir1/user_dir"
T5X_DIR="..."  # directory where the t5x is cloned.
TFDS_DATA_DIR="..."
MODEL_DIR="..."
export PYTHONPATH=${PROJECT_DIR}

python3 ${T5X_DIR}/t5x/train.py \
  --gin_search_paths=${PROJECT_DIR} \
  --gin_file="t5_1_1_base_de_en.gin" \
  --gin.MODEL_DIR="'${MODEL_DIR}'" \
  --tfds_data_dir=${TFDS_DATA_DIR}
```



## Released Checkpoints

We release the checkpoints for the T5.1.1 models in a native T5X format.

* **t5.1.1.small** (~77 million parameters): [gs://t5-data/pretrained_models/t5x/t5_1_1_small/checkpoint_1000000](https://console.cloud.google.com/storage/browser/t5-data/pretrained_models/t5x/t5_1_1_small/checkpoint_1000000)
* **t5.1.1.base** (~250 million parameters): [gs://t5-data/pretrained_models/t5x/t5_1_1_base/checkpoint_1000000](https://console.cloud.google.com/storage/browser/t5-data/pretrained_models/t5x/t5_1_1_base/checkpoint_1000000)
* **t5.1.1.large** (~800 million parameters): [gs://t5-data/pretrained_models/t5x/t5_1_1_large/checkpoint_1000000](https://console.cloud.google.com/storage/browser/t5-data/pretrained_models/t5x/t5_1_1_large/checkpoint_1000000)
* **t5.1.1.xl** (~3 billion parameters): [gs://t5-data/pretrained_models/t5x/t5_1_1_xl/checkpoint_1000000](https://console.cloud.google.com/storage/browser/t5-data/pretrained_models/t5x/t5_1_1_xl/checkpoint_1000000)
* **t5.1.1.xxl** (~11 billion parameters): [gs://t5-data/pretrained_models/t5x/t5_1_1_xxl/checkpoint_1000000](https://console.cloud.google.com/storage/browser/t5-data/pretrained_models/t5x/t5_1_1_xxl/checkpoint_1000000)

These are converted from the public [Mesh TensorFlow
checkpoints](https://github.com/google-research/text-to-text-transfer-transformer/blob/main/released_checkpoints.md#t511)
.



## Compatibility with the Mesh TensorFlow checkpoints
The Mesh TensorFlow checkpoints trained using the [T5 library][t5_github] can be
directly loaded into T5X. For example, we can rerun the fine-tuning example
initializing from the MTF checkpoint by changing the `INIT_CHECKPOINT` Gin
macro.

```sh
# Model dir to save logs, ckpts, etc. in "gs://model_dir" format.
MODEL_DIR="..."

# Data dir to save the processed dataset in "gs://data_dir" format.
TFDS_DATA_DIR="..."
T5X_DIR="..."  # directory where the T5X repo is cloned.

python3 ${T5X_DIR}/t5x/train.py \
  --gin_file="t5x/examples/t5/t5_1_1/examples/wmt19_ende_from_scratch.gin" \
  --gin.MODEL_DIR="'${MODEL_DIR}'" \
  --gin.MIXTURE_OR_TASK_NAME="'wmt_t2t_ende_v003'" \
  --gin.INIT_CHECKPOINT="'gs://t5-data/pretrained_models/t5.1.1.base/model.ckpt-1000000'" \
  --tfds_data_dir=${TFDS_DATA_DIR}
```

Note that restoring directly from the Mesh TensorFlow checkpoints can be
inefficient if heavy model parallelism is used for large models. This is
because each host loads the entire copy of the model first and then keep only
the relevant slices dictated by the model parallelism specification. If you have
Mesh TensorFlow checkpoints that you run often, we recommend converting the
checkpoints to T5X native format using
[`Checkpointer.convert_from_tf_checkpoint`](https://github.com/google-research/t5x/blob/fba685d1d49bfb1000f37b5952a9a0533f24ed36/t5x/checkpoints.py#L886).

TODO(hwchung): Add a conversion script.



## Note
This is not an officially supported Google product

[t5_paper]: https://arxiv.org/abs/1910.10683
[t5_github]: https://github.com/google-research/text-to-text-transfer-transformer
[gin-primer]: gin-primer.md
