# Functions and rules for microbial taxonomic classification
# Local imports
from scripts.common import (
    allocated
)


# Data processing classification rules
rule kraken2_classification:
    """
    Data-processing step for microbial taxonomic classification. Kraken2
    uses exact k-mer matches to achieve high accuracy and fast classification
    speeds. This classifier matches each k-mer within a query sequence to the
    lowest common ancestor (LCA) of all genomes containing the given k-mer. 
    @Input:
        Paired-end FastQ files containing unmapped reads (scatter)
    @Output:
        Taxonomic classification report of host-removed reads
    """
    input:
        r1 = join(workpath, "{name}", "fastqs", "{name}.R1.fastq.gz"),
        r2 = join(workpath, "{name}", "fastqs", "{name}.R2.fastq.gz"),
    output:
        rpt = join(workpath, "{name}", "kraken2", "{name}.kraken2.report"),
        tsv = join(workpath, "{name}", "kraken2", "{name}.kraken2.output.tsv"),
    params:
        rname  = "kraken2",
        tmpdir = join(workpath, "temp"),
        db     = config["options"]["kraken2_db_path"],
        conf   = config["options"]["KRAKEN2_CONFIDENCE"],
    resources:
        mem   = allocated("mem",  "kraken2_classification", cluster),
        time  = allocated("time", "kraken2_classification", cluster),
    threads: int(allocated("threads", "kraken2_classification", cluster))
    container: config['images']['microbe-count']
    shell: """
    # Setups temporary directory for
    # intermediate files with built-in 
    # mechanism for deletion on exit
    if [ ! -d "{params.tmpdir}" ]; then mkdir -p "{params.tmpdir}"; fi
    tmp=$(mktemp -d -p "{params.tmpdir}")
    trap 'rm -rf "${{tmp}}"' EXIT
    export TMPDIR="${{tmp}}"

    # Run kraken2 with user provided database
    kraken2 --threads {threads} \\
        --db {params.db} \\
        --paired \\
        --gzip-compressed \\
        --confidence {params.conf} \\
        --report {output.rpt} \\
        --output {output.tsv} \\
        {input.r1} {input.r2}
    """


rule bracken_abundance_estimation:
    """
    Data-processing step for re-estimating microbial abundances. While
    Kraken classifies reads to multiple levels in the taxonomic tree,
    Bracken (Bayesian Reestimation of Abundance with KrakEN) allows
    re-estimation of abundances at a single level using an output
    report file kraken2. It is worth noting that bracken is not
    compatible with mpa-style reports from kraken2.
    @Input:
        Taxonomic classification report of host-removed reads (scatter)
    @Output:
        Re-estimated abundances from bracken
    """
    input:
        r1 = join(workpath, "{name}", "fastqs", "{name}.R1.fastq.gz"),
        r2 = join(workpath, "{name}", "fastqs", "{name}.R2.fastq.gz"),
        rpt = join(workpath, "{name}", "kraken2", "{name}.kraken2.report"),
    output:
        bracken = join(workpath, "{name}", "kraken2", "{name}.bracken.{level}.tsv"),
    params:
        rname  = "kraken2",
        tmpdir = join(workpath, "temp"),
        db     = config["options"]["kraken2_db_path"],
        thresh = config["options"]["BRACKEN_THRESHOLD"],
    resources:
        mem   = allocated("mem",  "bracken_abundance_estimation", cluster),
        time  = allocated("time", "bracken_abundance_estimation", cluster),
    threads: int(allocated("threads", "bracken_abundance_estimation", cluster))
    container: config['images']['microbe-count']
    shell: """
    # Setups temporary directory for
    # intermediate files with built-in 
    # mechanism for deletion on exit
    if [ ! -d "{params.tmpdir}" ]; then mkdir -p "{params.tmpdir}"; fi
    tmp=$(mktemp -d -p "{params.tmpdir}")
    trap 'rm -rf "${{tmp}}"' EXIT
    export TMPDIR="${{tmp}}"

    # Estimate max read length from host-removed
    # FastQ files to select the best bracken
    # database for re-estimation of abundances
    read_length=$(
        zcat {input.r1} {input.r2} | \\
        awk 'NR % 4 == 2 {{
            l = length($0)
            if (l > max) max = l
          }}
          END {{
            if (max <= 50) r = 50
            else if (max <= 75) r = 75
            else if (max <= 100) r = 100
            else if (max <= 150) r = 150
            else if (max <= 200) r = 200
            else if (max <= 250) r = 250
            else if (max <= 300) r = 300
            else {{
                print "Error: max read length " max " exceeds db read length." > "/dev/stderr"
                exit 1
            }}
            print r
        }}'
    )

    # Run bracken to re-estimate abundances
    # at a given taxonomic level
    echo "Running Bracken at {wildcards.level} level with ${{read_length}} read length."
    bracken \\
      -d {params.db} \\
      -i {input.rpt} \\
      -o {output.bracken} \\
      -r "${{read_length}}" \\
      -l {wildcards.level} \\
      -t {params.thresh}
    """