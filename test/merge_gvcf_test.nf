nextflow.enable.dsl=2

include { merge_gvcf } from '../modules/vcf/merge_gvcf'

workflow {
    Channel.of([[assembly: 'GRCh38'], [file("patient_3.g.vcf.gz"), file("father_3.g.vcf.gz"), file("mother_3.g.vcf.gz")], [file("patient_3.g.vcf.gz.csi"), file("father_3.g.vcf.gz.csi"), file("mother_3.g.vcf.gz.csi")]])
      | merge_gvcf
      | view
}