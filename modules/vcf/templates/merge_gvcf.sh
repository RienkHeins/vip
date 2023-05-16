#!/bin/bash
set -euo pipefail

merge_gvcfs () {
  local args=()
  # --merge: no new multiallelics, output multiple records instead
  args+=("--merge" "none")
  args+=("--gvcf" "!{refSeqPath}")
  # the only 'clair3' INFO fields P and F are of type 'Flag' and cannot be merged by bcftools
  args+=("--info-rules" "-")
  args+=("--output-type" "z")
  args+=("--output" "merged.g.vcf.gz")
  args+=("--no-version")
  args+=("--threads" "!{task.cpus}")
  for gVcf in !{gVcfs}; do
    args+=("${gVcf}")
  done

  ${CMD_BCFTOOLS} merge "${args[@]}"
}

remove_info_p_f () {
  local args=()
  # content of INFO fields P and F are invalid after the merge, so remove them
  args+=("-x" "INFO/P,INFO/F")
  args+=("--output-type" "z")
  args+=("--output" "merged_remove_annotations.g.vcf.gz")
  args+=("--no-version")
  args+=("--threads" "!{task.cpus}")
  args+=("merged.g.vcf.gz")

  ${CMD_BCFTOOLS} annotate "${args[@]}"
}

filter_and_trim () {
  local args=()
  # keep records that have at least one non-reference allele in one of the samples
  args+=("--min-ac" "1:nref")
  # remove alternative alleles not seen in any samples such as <NON_REF>
  args+=("--trim-alt-alleles")
  # do not calculate INFO/AC and INFO/AN
  args+=("--no-update")
  args+=("--output-type" "z")
  args+=("--output" "!{vcfOut}")
  args+=("--no-version")
  args+=("--threads" "!{task.cpus}")
  args+=("merged_remove_annotations.g.vcf.gz")

  ${CMD_BCFTOOLS} view "${args[@]}"
}

index () {
  ${CMD_BCFTOOLS} index --csi --output "!{vcfOutIndex}" --threads "!{task.cpus}" "!{vcfOut}"
}

stats () {
  ${CMD_BCFTOOLS} index --stats "!{vcfOut}" > "!{vcfOutStats}"
}

main () {
  merge_gvcfs
  remove_info_p_f
  filter_and_trim
  index
  stats
}

main "$@"
