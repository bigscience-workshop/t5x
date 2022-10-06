import functools
import seqio
from t5.data import preprocessors, utils
import tensorflow as tf

seqio.add_global_cache_dirs(
    ['gs://t5x-test/seqio_cached_tasks/']
)

vocabulary = seqio.SentencePieceVocabulary(
    'gs://t5-data/vocabs/cc_all.32000/sentencepiece.model', extra_ids=100)
output_features = {
    'inputs': seqio.Feature(vocabulary=vocabulary),
    'targets': seqio.Feature(vocabulary=vocabulary)
}

DEFAULT_OUTPUT_FEATURES = {
    "inputs": seqio.Feature(
        vocabulary=vocabulary, add_eos=True,
        required=False),
    "targets": seqio.Feature(
        vocabulary=vocabulary, add_eos=True)
}

DATASET_FOLDER="gs://t5x-test/data/c4/raw/raw//"
DATASET_SPLITS_TO_FILEPATTERN={
    "train": [f"gs://t5x-test/data/c4/raw/raw//c4-train.{i:05}-of-01024.json" for _ in range(1024)],
    "val": [f"gs://t5x-test/data/c4/raw/raw//c4-train.{i:05}-of-01024.json" for _ in range(1024)],
    "test": [f"gs://t5x-test/data/c4/raw/raw//c4-train.{i:05}-of-01024.json" for _ in range(1024)],
}

@utils.map_over_dataset
def extract_text_from_json_tf(json: str):
    output = tf.strings.split(json, '{"text":"', maxsplit=1)[1]
    output = tf.strings.split(output, '",', maxsplit=1)[0]
    return {"text": output}

seqio.TaskRegistry.add(
    'c4_eye_span_corruption', # version of c4 corresponding to one hosted on the-eye
    source=seqio.TextLineDataSource(
        split_to_filepattern=DATASET_SPLITS_TO_FILEPATTERN,
    ),
    preprocessors=[
        extract_text_from_json_tf,
        functools.partial(
            preprocessors.rekey, key_map={
                "inputs": None,
                "targets": "text"
            }),
        seqio.preprocessors.tokenize,
        seqio.CacheDatasetPlaceholder(),
        preprocessors.span_corruption,
        seqio.preprocessors.append_eos_after_trim,
    ],
    output_features=DEFAULT_OUTPUT_FEATURES,
    metric_fns=[]
)

