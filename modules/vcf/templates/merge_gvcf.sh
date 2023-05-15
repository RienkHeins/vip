#!/bin/bash
set -euo pipefail

merge () {
  local args=()
  # --merge: no new multiallelics, output multiple records instead
  args+=("--merge" "none")
  args+=("--gvcf" "!{refSeqPath}")
  # --info-rules: same as bcftools 1.17 default
  # --info-rules: the merged QUAL value is currently set to the maximum. This behaviour is not user controllable in bcftools 1.17.
  args+=("--info-rules" "QS:sum,MinDP:min,I16:sum,IDV:max,IMF:max")
  args+=("--output-type" "z")
  args+=("--output" "!{vcfOut}")
  args+=("--write-index")
  args+=("--no-version")
  args+=("--threads" "!{task.cpus}")
  for gVcf in !{gVcfs}; do
    args+=("${gVcf}")
  done

  ${CMD_BCFTOOLS} merge "${args[@]}"
}

stats () {
  ${CMD_BCFTOOLS} index --stats "!{vcfOut}" > "!{vcfOutStats}"
}

main () {
  merge
  stats
}

main "$@"
