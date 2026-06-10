mkdir -p data
aws s3 sync s3://cubayes-demo-data/giab data/

./nextflow run cubayes.nf \
    --sample HG002 \
    --ref data/giab/ref/GRCh38_full_analysis_set_plus_decoy_hla.fa \
    --r1 data/giab/HG002_R1.fastq.gz \
    --r2 data/giab/HG002_R2.fastq.gz \
    $@
