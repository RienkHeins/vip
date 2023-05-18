#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"


main () {
    local -r envCmdBcfTools="apptainer exec $(realpath "${SCRIPT_DIR}/../images/bcftools-1.17.sif") bcftools" 
    local -r paramGRCh38ReferenceFasta="$(realpath "${SCRIPT_DIR}/../resources/GRCh38/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna.gz")"

    CMD_BCFTOOLS="${envCmdBcfTools}" nextflow run -offline --GRCh38.reference.fasta "${paramGRCh38ReferenceFasta}" "${SCRIPT_DIR}/merge_gvcf_test.nf"
}

main "$@"
