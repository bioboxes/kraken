## kraken

### Signature
`FASTA A -> BINNING B`

### Run kraken biobox

```shell
sudo docker run -v /path/to/test.yaml:/bbx/input/biobox.yaml:rw  \
-v /path/to/fasta/test.fna:/bbx/input/test.fna:ro      \
-v /path/to/cache/directory:/cache:rw \
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
  - cache: "/cache"     
```

Please note that the cache parameter is option. The default task will download a database of 4GB size on the first run and reuse it in any further runs. If you do not specify the cache parameter it will download the database on every run.
