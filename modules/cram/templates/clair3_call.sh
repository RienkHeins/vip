#!/bin/bash
set -euo pipefail

create_bed () {
  echo -e "!{bedContent}" > "!{bed}"
}

call_small_variants () {
    local args=()
    args+=("--bam_fn=!{cram}")
    args+=("--ref_fn=$(realpath "!{reference}")")
    args+=("--bed_fn=$(realpath "!{bed}")")
    args+=("--threads=!{task.cpus}")
    args+=("--platform=!{platform}")
    args+=("--model_path=/opt/models/!{modelName}")
    args+=("--output=$(realpath .)")
    args+=("--sample_name=!{meta.sample.individual_id}")
    args+=("--longphase_for_phasing")
    args+=("--remove_intermediate_dir")
    args+=("--gvcf")

    REF_CACHE=!{refCachePath}/%2s/%2s/%s REF_PATH=":" ${CMD_CLAIR3} "${args[@]}"

    mv "merge_output.gvcf.gz" "!{vcfOut}"
    mv "merge_output.gvcf.gz.tbi" "!{vcfOutIndex}"
}

stats () {
  ${CMD_BCFTOOLS} index --stats "!{vcfOut}" > "!{vcfOutStats}"
}

main() {
    create_bed
    call_small_variants
    stats
}

main "$@"
