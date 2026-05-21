# Functions and rules for microbial taxonomic classification
# Standard library
from textwrap import dedent
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
    This rule is scatter per the cartesian product of samples and taxonomic
    levels.
    @Input:
        Trimmed paired-end FastQ files containing unmapped reads (scatter-per-sample-per-taxonomic-level)
    @Output:
        Taxonomic classification report of host-removed reads
    """
    input:
        r1 = join(workpath, "{name}", "fastqs", "{name}.R1.trimmed.fastq.gz"),
        r2 = join(workpath, "{name}", "fastqs", "{name}.R2.trimmed.fastq.gz"),
    output:
        rpt = join(workpath, "{name}", "kraken2", "{name}_kraken2.report"),
        tsv = join(workpath, "{name}", "kraken2", "{name}_kraken2_output.tsv"),
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
        Bracken abundances counts at the specified taxonomic level,
        Bracken abundances report
    """
    input:
        # Use un-trimmed fastqs for estimating
        # max read length for bracken kmer db
        r1 = join(workpath, "{name}", "fastqs", "{name}.R1.fastq.gz"),
        r2 = join(workpath, "{name}", "fastqs", "{name}.R2.fastq.gz"),
        rpt = join(workpath, "{name}", "kraken2", "{name}_kraken2.report"),
    output:
        bracken = join(workpath, "{name}", "bracken", "{name}_bracken_{level}-level.tsv"),
    params:
        rname  = "bracken",
        tmpdir = join(workpath, "temp"),
        # NOTE: Pre-built public kraken databases
        # are built with bracken db read lengths
        # of 50/75/100/150/200/250/300 bp included.
        # If providing a custom kraken2 database,
        # please ensure that you build a bracken
        # db with the appropriate read lengths
        # outlined below for your data.
        db     = config["options"]["kraken2_db_path"],
        thresh = config["options"]["BRACKEN_THRESHOLD"],
        level  = lambda w: str(BRACKEN_MAP[w.level]),
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
    echo "Running Bracken at {wildcards.level} level (i.e {params.level}) with ${{read_length}} read length."
    bracken \\
      -d {params.db} \\
      -i {input.rpt} \\
      -o {output.bracken} \\
      -r "${{read_length}}" \\
      -l {params.level} \\
      -t {params.thresh}
    """


rule taxpasta_counts_matrix:
    """
    Data-processing step for generating taxonomic count matrices. TaxPasta
    standardizes output from different taxonomic classifiers and can generate count
    matrices at different taxonomic levels. One counts matrix will be generated per
    taxonomic level.
    @Input:
        Bracken abundances counts at the specified taxonomic level (gather-per-taxonomic-level)
    @Output:
       Count matrix at the specified taxonomic level (e.g domain, genus, species, etc.)
    """
    input:
        counts = expand(join(workpath, "{name}", "bracken", "{name}_bracken_{{level}}-level.tsv"), name=samples)
    output:
        sheet = join(workpath, "counts", "bracken_{level}-level_sample-sheet.tsv"),
        matrix = join(workpath, "counts", "bracken_{level}-level_estimated-counts.tsv"),
    params:
        rname  = "mkmatrix",
        tmpdir = join(workpath, "temp"),
        # NOTE: this path must contain a nodes.dmp and
        # names.dmp file for retrieving for taxonomic
        # lineage information. The public pre-built
        # kraken2 databases should always contain
        # these files.
        db           = config["options"]["kraken2_db_path"],
        file_header  = "sample\tprofile",
        sample_sheet = lambda w: "\n".join([
            "{0}\t{1}".format(
                str(s),
                join(workpath, "{0}".format(s), "bracken", "{0}_bracken_{1}-level.tsv".format(s, w.level))
            )
            for s in samples
        ]),
    resources:
        mem   = allocated("mem",  "taxpasta_counts_matrix", cluster),
        time  = allocated("time", "taxpasta_counts_matrix", cluster),
    threads: int(allocated("threads", "taxpasta_counts_matrix", cluster))
    container: config['images']['microbe-count']
    shell:
        dedent("""
        # Setups temporary directory for
        # intermediate files with built-in
        # mechanism for deletion on exit
        if [ ! -d "{params.tmpdir}" ]; then mkdir -p "{params.tmpdir}"; fi
        tmp=$(mktemp -d -p "{params.tmpdir}")
        trap 'rm -rf "${{tmp}}"' EXIT
        export TMPDIR="${{tmp}}"

        # Create sample sheet to rename samples
        # in the output counts matrix, where:
        #  1st column = Sample (name in matrix)
        #  2nd column = Per-sample counts file
        cat << EOF > {output.sheet}
        {params.file_header}
        {params.sample_sheet}
        EOF
        # Run taxpasta to generate count matrix
        # at the {wildcards.level} level
        taxpasta merge -p bracken \\
            --add-name \\
            --add-lineage \\
            --taxonomy {params.db} \\
            --samplesheet {output.sheet} \\
            --output {output.matrix}
        """)
