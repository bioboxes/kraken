## kraken

### Signature
`FASTA A, [FASTQ] B -> BINNING C`

### Run kraken biobox

```shell
sudo docker run -v /path/to/test.yaml:/bbx/input/biobox.yaml:rw  \
-v /path/to/fasta/test.fna:/bbx/input/test.fna:ro      \
-v /path/to/output:/bbx/output:rw  kraken default     
```

### Input yaml Example:

```YAML
---
version: 0.9.0
arguments: 
  - fasta:    
       id: "fasta"
       value: "/bbx/input/test.fna"
       type: "contig" 
```
