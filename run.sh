#!/bin/bash

TASK=$1
OUTPUT=/bbx/output/bbx
INPUT=/bbx/input/biobox.yaml
DB=/tmp
THREADS=8
MAX_DB_SIZE=15
KRAKEN_OUT=/tmp/kraken_out.tsv

#validate yaml
${VALIDATOR}/validate-biobox-file --schema=${VALIDATOR}schema.yaml --input=$INPUT

# Run the given task
CMD=$(egrep ^${TASK}: /tasks | cut -f 2 -d ':')
if [[ -z ${CMD} ]]; then
  echo "Abort, no task found for '${TASK}'."
  exit 1
fi

#get fasta
CONTIGS=$(sudo /usr/local/bin/yaml2json < ${INPUT} \
         | jq --raw-output '.arguments[] | select(has("fasta")) | .fasta.value ')

#fetch db
cd /tmp
wget http://ccb.jhu.edu/software/kraken/dl/minikraken.tgz 
tar xf minikraken.tgz --directory $DB --strip-components=1

eval ${CMD}

#build cami format
awk 'BEGIN { FS = "\t"} /^C/ { print $2"\t"$3 } ' $KRAKEN_OUT > ${OUTPUT}/out.binning

mkdir -p $OUTPUT

cat << EOF > ${OUTPUT}/biobox.yaml
version: 0.9.0
arguments:
  - binning:
     - value: out.binning
       type: false
EOF
