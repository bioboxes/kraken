#!/bin/bash

set -o errexit
set -o nounset

TASK=$1
OUTPUT=/bbx/output/bbx
INPUT=/bbx/input/biobox.yaml
THREADS=8
MAX_DB_SIZE=15

#validate yaml
${VALIDATOR}validate-biobox-file --schema=${VALIDATOR}schema.yaml --input=$INPUT

# Run the given task
CMD=$(egrep ^${TASK}: /Taskfile | cut -f 2 -d ':')
if [[ -z ${CMD} ]]; then
  echo "Abort, no task found for '${TASK}'."
  exit 1
fi

TMP_DIR=$(mktemp -d)
DB=$TMP_DIR

KRAKEN_OUT="${TMP_DIR}/kraken_out.tsv"

INPUT_JSON="${TMP_DIR}/biobox.json"

$(yaml2json < ${INPUT} > $INPUT_JSON)

ARGUMENTS=$(jq  --raw-output '.arguments[]' $INPUT_JSON )

#get fasta
CONTIGS=$( echo $ARGUMENTS | jq --raw-output 'select(has("fasta")) | .fasta.value ' | tr '\n' ' ')

#get cache
CACHE=$( echo $ARGUMENTS | jq --raw-output 'select(has("cache")) | .cache ' | tr '\n' ' ')

KRAKEN_MINI_URL="http://ccb.jhu.edu/software/kraken/dl/minikraken.tgz"

#check if cache is defined
if [  -z "$CACHE" ]; then

        # no cache defined -> download the data to temp dir
        wget --quiet --output-document - $KRAKEN_MINI_URL \
        |  tar zxvf   - --directory $DB --strip-components=1
else 
        DB=$CACHE
        # cache contains database
        if [ ! "$(ls -A $DB)" ]; then
                wget  --quiet --output-document - $KRAKEN_MINI_URL \
                |  tar zxvf  - --directory $DB --strip-components=1
        fi
fi 

eval ${CMD}

mkdir -p $OUTPUT

#build cami format
awk 'BEGIN { FS = "\t"} /^C/ { print $2"\t"$3 } ' $KRAKEN_OUT > ${OUTPUT}/out.binning

cat << EOF > ${OUTPUT}/biobox.yaml
version: 0.9.0
arguments:
  - binning:
     - value: out.binning
       type: false
EOF
