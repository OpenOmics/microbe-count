# Functions and rules for removing host reads
# Standard Library
import textwrap
# Local imports
from scripts.common import (
    allocated
)

# Data processing host removal rules
rule host_removed_reads:
    """
    Data-processing step to convert BAM files into host removed
    FastQ files. The pipeline takes host-aligned BAM files as input.
    Prior to estimating microbial composition, we extract unmapped
    reads from the BAM file and then create host removed FastQ files.
    This will ensure no-host contaminating reads are included in
    the downstream analysis.
    @Input:
        Input BAM file (scatter-per-sample)
    @Output:
        Paired-end FastQ files containing unmapped reads
    """
    input:
        bam   = join(workpath, "{name}.bam"),
    output:
        r1 = join(workpath, "fastqs", "{name}.R1.fastq.gz"),
        r2 = join(workpath, "fastqs", "{name}.R2.fastq.gz"),
    params:
        rname  = "hostrmfqs",
        tmpdir = join(workpath, "temp"),
    resources:
        mem   = allocated("mem",  "host_removed_reads", cluster),
        time  = allocated("time", "host_removed_reads", cluster),
    threads: int(allocated("threads", "host_removed_reads", cluster))
    container: config["images"]["microbe-count"]
    shell: """
    # Setups temporary directory for
    # intermediate files with built-in
    # mechanism for deletion on exit
    if [[ ! -d "{params.tmpdir}" ]]; then mkdir -p "{params.tmpdir}"; fi
    tmp=$(mktemp -d -p "{params.tmpdir}")
    trap 'rm -rf "${{tmp}}"' EXIT
    export TMPDIR="${{tmp}}"

    # Extract un-mapped paired-ends reads
    # from the input host aligned BAM file,
    # where extracted reads must:
    #   • Be un-mapped (flag 12)
    #   • Not be secondary (flag 256),
    #     technically not required since
    #     secondary alignments are not
    #     un-mapped, but we include this
    #     filter for safety and to avoid
    #     any potential issues later.
    #   • Not be supplementary (flag 2048),
    #     technically not required since
    #     supplementary alignments are not
    #     un-mapped, but we include this
    #     filter for safety and to avoid
    #     any potential issues later.
    # And creates paired-end FastQ files while
    # discarding singletons, supplementary,
    # and secondary reads using samtools
    samtools view -u -f 12 -F 256 -F 2048 {input.bam} \\
        | samtools collate -@ {threads} -u -O - \\
        | samtools fastq \\
            -1 {output.r1} \\
            -2 {output.r2} \\
            -0 /dev/null \\
            -s /dev/null \\
            -n
    """
