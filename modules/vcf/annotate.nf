include { basename; getProbandHpoIds; areProbandHpoIdsIndentical } from './utils'

process annotate {
  input:
    tuple val(meta), path(vcf), path(vcfIndex), path(vcfStats)
  output:
    tuple val(meta), path(vcfOut), path(vcfOutIndex), path(vcfOutStats)
  shell:
    basename = basename(meta)
    vcfOut = "${basename}_annotated.vcf.gz"
    vcfOutIndex = "${vcfOut}.csi"
    vcfOutStats = "${vcfOut}.stats"
    
    hpoIds = meta.hpo_ids.join(",")
    
    refSeqPath = params[meta.assembly].reference.fasta
    vepCustomGnomAdPath = params.vcf.annotate[meta.assembly].vep_custom_gnomad
    vepCustomClinVarPath = params.vcf.annotate[meta.assembly].vep_custom_clinvar
    vepCustomPhyloPPath = params.vcf.annotate[meta.assembly].vep_custom_phylop
    vepPluginSpliceAiIndelPath = params.vcf.annotate[meta.assembly].vep_plugin_spliceai_indel
    vepPluginSpliceAiSnvPath = params.vcf.annotate[meta.assembly].vep_plugin_spliceai_snv
    vepPluginVkglPath = params.vcf.annotate[meta.assembly].vep_plugin_vkgl
    vepPluginUtrAnnotatorPath = params.vcf.annotate[meta.assembly].vep_plugin_utrannotator
    capiceModelPath = params.vcf.annotate[meta.assembly].capice_model

    gadoGenesPath = params.vcf.annotate.gado_genes
    gadoHpoPath = params.vcf.annotate.gado_hpo
    gadoPredictInfoPath = params.vcf.annotate.gado_predict_info
    gadoPredictMatrixPath = params.vcf.annotate.gado_predict_matrix
    areProbandHpoIdsIndentical = areProbandHpoIdsIndentical(meta.sampleSheet)
    gadoHpoIds = getProbandHpoIds(meta.sampleSheet).join(",")

    template 'annotate.sh'
}

process annotate_publish {
  publishDir "$params.output/intermediates", mode: 'link'

  input:
    tuple val(meta), path(vcfs), path(vcfIndexes)
  output:
    tuple val(meta), path(vcfOut), path(vcfOutIndex)
  shell:
    basename = basename(meta)
    vcfOut="${basename}_annotations.vcf.gz"
    vcfOutIndex = "${vcfOut}.csi"

    template 'publish.sh'
}
