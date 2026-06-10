# Prerequisites

This demo assumes you're running on AWS EC2 g6e.12xlarge image with the NVIDIA
Deep Learning base AMI.

You'll also need a working `aws` CLI command with credentials from the
environment. We recommend using `aws login --remote`.


# Running

One-liner to do HG002 analysis (downloads ~170GB of data):

```
curl https://shadowfaxbio.github.io/cubayes-demo/run.sh | sh
```

Or clone the repo:

```
git clone https://github.com/shadowfaxbio/cubayes-demo
cd cubayes-demo
```

Install nextflow and apptainer:

```
./init.sh
```

Run on parabricks sample data (downloads ~16GB of data):

```
./run_small.sh
```

Run on full HG002 (downloads ~170GB of data):

```
./run_full.sh
```

Run on your own data:

```
./nextflow run cubayes.nf \
    --sample SAMPLE_NAME \
    --ref path/to/reference.fasta \
    --r1 path/to/read1_file.fastq.gz \
    --r2 path/to/read2_file.fastq.gz \
```
