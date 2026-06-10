mkdir -p data
aws s3 sync s3://cubayes-demo-data/parabricks_sample data/

./nextflow run cubayes.nf \
    --sample HG002 \
    --ref data/parabricks_sample/Ref/Homo_sapiens_assembly38.fasta \
    --r1 data/parabricks_sample/Data/sample_1.fq.gz \
    --r2 data/parabricks_sample/Data/sample_2.fq.gz \
    $@
