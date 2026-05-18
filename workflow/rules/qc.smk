# Functions and quality-control related rules
# Local imports
from scripts.common import (
    allocated
)

# Pre-alignment quality control
rule samtools_stats:
    """
    Quality-control step to assess quality and quanity of
    host-aligned BAM files. For more information, please visit
    samtools documentation:
    https://www.htslib.org/doc/samtools-flagstat.html
    
    @Input:
        Input BAM file (scatter-per-sample)
    @Output:
        Flagstat report on host-aligned BAM file
    """
    input:
        bam = join(workpath, "{name}.bam"),
    output:
        flagstat = join(workpath, "{name}", "qc", "{name}.flagstats"),
        stats    = join(workpath, "{name}", "qc", "{name}.stats"),
        idx      = join(workpath, "{name}", "qc", "{name}.idxstats"),
    params:
        rname  = "bamstat",
        tmpdir = join(workpath, "temp"),
        outdir = join(workpath, "{name}", "qc"),
    resources:
        mem   = allocated("mem",  "samtools_flagstat", cluster),
        time  = allocated("time", "samtools_flagstat", cluster),
    threads: int(allocated("threads", "samtools_flagstat", cluster))
    container: config['images']['microbe-count']
    shell: """
    # Setups temporary directory for
    # intermediate files with built-in 
    # mechanism for deletion on exit
    if [ ! -d "{params.tmpdir}" ]; then mkdir -p "{params.tmpdir}"; fi
    tmp=$(mktemp -d -p "{params.tmpdir}")
    trap 'rm -rf "${{tmp}}"' EXIT
    export TMPDIR="${{tmp}}"

    # Run samtools flagstat, stats,
    # and idxstats on input BAM file
    samtools flagstat \\
        {input.bam} \\
    > {output.flagstat}
    samtools stats \\
        {input.bam} \\
    > {output.stats}
    samtools idxstats \\
        {input.bam} \\
    > {output.idx}
    """


rule fastqc_extracted_reads:
    """
    Quality-control step to assess quality and quanity of
    unmapped reads (i.e host removed reads). 
    For more information, please visit their documentation:
    https://github.com/s-andrews/FastQC
    @Input:
        Paired-end FastQ files containing unmapped reads (scatter)
    @Output:
        FastQC html report and zip file on unmapped reads
    """
    input:
        r1 = join(workpath, "{name}", "fastqs", "{name}.R1.fastq.gz"),
        r2 = join(workpath, "{name}", "fastqs", "{name}.R2.fastq.gz"),
    output:
        join(workpath, "{name}", "qc", "{name}.R1_fastqc.zip"),
        join(workpath, "{name}", "qc", "{name}.R2_fastqc.zip"),
    params:
        rname  = "fqc",
        tmpdir = join(workpath, "temp"),
        outdir = join(workpath, "{name}", "qc"), 
    resources:
        mem   = allocated("mem",  "fastqc_extracted_reads", cluster),
        time  = allocated("time", "fastqc_extracted_reads", cluster),
    threads: int(allocated("threads", "fastqc_extracted_reads", cluster))
    container: config['images']['microbe-count']
    shell: """
    # Setups temporary directory for
    # intermediate files with built-in 
    # mechanism for deletion on exit
    if [ ! -d "{params.tmpdir}" ]; then mkdir -p "{params.tmpdir}"; fi
    tmp=$(mktemp -d -p "{params.tmpdir}")
    trap 'rm -rf "${{tmp}}"' EXIT
    export TMPDIR="${{tmp}}"

    # Running fastqc with local
    # disk or a tmpdir, fastqc
    # has been observed to lock
    # up gpfs filesystems, adding
    # this on request by HPC staff. 
    fastqc \\
        {input.r1} \\
        {input.r2} \\
        -t {threads} \\
        -o "${{tmp}}"
    
    # Copy output files from tmpdir
    # to output directory
    find "${{tmp}}" \\
        -type f \\
        \\( -name '*.html' -o -name '*.zip' \\) \\
        -exec cp {{}} {params.outdir} \\;
    """
