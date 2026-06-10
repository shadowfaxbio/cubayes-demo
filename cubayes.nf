#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

process alignment {
    tag "$sample"

    input:
    val sample
    path ref_bundle
    path r1
    path r2

    output:
    tuple val(sample), path("${sample}.bam"), path("${sample}.bam.bai"), emit: bam

    script:
    def ref = ref_bundle.find { it.name == file(params.ref).name }
    def readGroup = "@RG\\tID:${sample}\\tLB:${params.lib}\\tPL:${params.platform}\\tSM:${sample}\\tPU:${sample}"

    """
    pbrun fq2bam \
        --ref ${ref} \
        --in-fq ${r1} ${r2} '${readGroup}' \
        --gpusort \
        --gpuwrite \
        --out-bam ${sample}.bam \
    """

    stub:
    """
    touch ${sample}.bam ${sample}.bam.bai
    """
}

process variantCalling {
    tag "$sample"

    input:
    tuple val(sample), path(bam), path(bai)
    path ref_bundle

    output:
    tuple val(sample), path("${sample}.vcf"), emit: vcf
    path "${sample}.cubayes.log", emit: log

    script:
    def ref = ref_bundle.find { it.name == file(params.ref).name }
    def cubayesArgs = []
    if (params.batch_bam_gb)  cubayesArgs << "--batch-bam-gb ${params.batch_bam_gb}"
    if (params.batch_vram_gb) cubayesArgs << "--batch-vram-gb ${params.batch_vram_gb}"

    """
    cubayes ${cubayesArgs.join(' ')} ${bam} ${ref} > ${sample}.vcf 2> ${sample}.cubayes.log
    """

    stub:
    """
    cat > ${sample}.vcf <<'EOF'
    ##fileformat=VCFv4.2
    ##source=cubayes-stub
    #CHROM	POS	ID	REF	ALT	QUAL	FILTER	INFO	FORMAT	${sample}
    EOF
    touch ${sample}.cubayes.log
    """
}

process compressVCF {
    tag "$sample"

    publishDir params.outdir, mode: 'copy'

    input:
    tuple val(sample), path(vcf)

    output:
    tuple val(sample), path("${sample}.vcf.gz"), path("${sample}.vcf.gz.tbi"), emit: vcf_gz

    script:
    """
    bcftools view -Oz -o ${sample}.vcf.gz ${vcf}
    bcftools index --tbi --force ${sample}.vcf.gz
    """

    stub:
    """
    gzip -c ${vcf} > ${sample}.vcf.gz
    touch ${sample}.vcf.gz.tbi
    """
}

workflow {
    if (!params.sample) error "Missing required parameter: --sample"
    if (!params.ref)    error "Missing required parameter: --ref"
    if (!params.r1)     error "Missing required parameter: --r1"
    if (!params.r2)     error "Missing required parameter: --r2"

    ref_bundle = [
        file(params.ref, checkIfExists: true),
        file("${params.ref}.amb", checkIfExists: true),
        file("${params.ref}.ann", checkIfExists: true),
        file("${params.ref}.bwt", checkIfExists: true),
        file("${params.ref}.pac", checkIfExists: true),
        file("${params.ref}.sa",  checkIfExists: true),
        file("${params.ref}.fai", checkIfExists: true)
    ]

    aligned = alignment(
        params.sample,
        ref_bundle,
        file(params.r1, checkIfExists: true),
        file(params.r2, checkIfExists: true)
    )

    variants = variantCalling(aligned.bam, ref_bundle)
    compressVCF(variants.vcf)
}
