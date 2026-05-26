<div align="center">

  <h1 style="font-size: 250%">microbe-count 🔬</h1>

  <b><i>An awesome snakemake pipeline to quantify microbial composition</i></b><br>
  <a href="https://doi.org/10.5281/zenodo.20349358">
    <img src="https://img.shields.io/badge/DOI-10.5281%2Fzenodo.20349358-blue" alt="DOI">
  </a>
  <a href="https://github.com/OpenOmics/microbe-count/releases">
    <img alt="GitHub release" src="https://img.shields.io/github/v/release/OpenOmics/microbe-count?color=blue&include_prereleases">
  </a>
  <a href="https://hub.docker.com/repository/docker/skchronicles/microbe-count">
    <img alt="Docker Pulls" src="https://img.shields.io/docker/pulls/skchronicles/microbe-count">
  </a><br>
  <a href="https://github.com/OpenOmics/microbe-count/actions/workflows/main.yaml">
    <img alt="tests" src="https://github.com/OpenOmics/microbe-count/workflows/tests/badge.svg">
  </a>
  <a href="https://github.com/OpenOmics/microbe-count/actions/workflows/docs.yml">
    <img alt="docs" src="https://github.com/OpenOmics/microbe-count/workflows/docs/badge.svg">
  </a>
  <a href="https://github.com/OpenOmics/microbe-count/issues">
    <img alt="GitHub issues" src="https://img.shields.io/github/issues/OpenOmics/microbe-count?color=brightgreen">
  </a>
  <a href="https://github.com/OpenOmics/microbe-count/blob/main/LICENSE">
    <img alt="GitHub license" src="https://img.shields.io/github/license/OpenOmics/microbe-count">
  </a>

  <p>
    This is the home of the pipeline, microbe-count. Its long-term goals: to make estimating microbial composition from host-aligned data quick and easy.
  </p>

</div>


## Overview

Welcome to microbe-count! Before getting started, we highly recommend reading through [microbe-count's documentation](https://openomics.github.io/microbe-count/). This pipeline is a wrapper around several tools to estimates microbial composition from host-aligned paired-end BAM files. For each sample, reads that did not align to the host genome are extracted from the BAM file and converted to FASTQ format using [samtools<sup>1</sup>](https://github.com/samtools/samtools). The unmapped reads are then classified taxonomically with [kraken2<sup>2</sup>](https://github.com/DerrickWood/kraken2), and [bracken<sup>3</sup>](https://github.com/jenniferlu717/Bracken) is used to estimate different taxonomic-level abundances from the kraken2's output. Finally, per-sample bracken outputs are merged into a count matrix with samples as rows and microbial species as columns using [taxpasta<sup>4</sup>](https://github.com/taxprofiler/taxpasta). The pipeline is designed to be highly scalable, reproducible, and easy to use.

The **`./microbe-count`** pipeline is composed several inter-related sub commands to setup and run the pipeline across different systems. Each of the available sub commands perform different functions:

<section align="center" markdown="1" style="display: flex; flex-wrap: row wrap; justify-content: space-around;">

!!! inline custom-grid-button ""

    [<code style="font-size: 1em;">microbe-count <b>run</b></code>](usage/run.md)
    Run the microbe-count pipeline with your input BAM files.

!!! inline custom-grid-button ""

    [<code style="font-size: 1em;">microbe-count <b>unlock</b></code>](usage/unlock.md)
    Unlocks a previous runs output directory.

</section>

<section align="center" markdown="1" style="display: flex; flex-wrap: row wrap; justify-content: space-around;">


!!! inline custom-grid-button ""

    [<code style="font-size: 1em;">microbe-count <b>install</b></code>](usage/install.md)
    Download remote reference files locally.


!!! inline custom-grid-button ""

    [<code style="font-size: 1em;">microbe-count <b>cache</b></code>](usage/cache.md)
    Cache remote software containers locally.

</section>

**microbe-count** is a pipeline to make running kraken2 and bracken easier, more reproducible, and more scalable. It relies on technologies like [Singularity<sup>5</sup>](https://singularity.lbl.gov/) to maintain the highest-level of reproducibility. The pipeline consists of a series of data processing and quality-control steps orchestrated by [Snakemake<sup>6</sup>](https://snakemake.readthedocs.io/en/stable/), a flexible and scalable workflow management system, to submit jobs to a cluster.

The pipeline is compatible with data generated from Illumina short-read sequencing technologies. As input, it accepts a set of BAM files and can be run locally on a compute instance or on-premise using a cluster. A user can define the method or mode of execution. The pipeline can submit jobs to a cluster using a job scheduler like SLURM (more coming soon!). A hybrid approach ensures the pipeline is accessible to all users.

Before getting started, we highly recommend reading through the [usage](usage/run.md) section of each available sub command.

For more information about issues or trouble-shooting a problem, please checkout our [FAQ](faq/questions.md) prior to [opening an issue on Github](https://github.com/OpenOmics/microbe-count/issues).

## Contribute

This site is a living document, created for and by members like you. microbe-count is maintained by the members of OpenOmics and is improved by continous feedback! We encourage you to contribute new content and make improvements to existing content via pull request to our [GitHub repository :octicons-heart-fill-24:{ .heart }](https://github.com/OpenOmics/microbe-count).

## Citation

If you use this software, please cite it as below:

=== "BibTex"

    ```
    @software{kuhn_2026_20349359,
      author       = {Kuhn, Skyler},
      title        = {OpenOmics/microbe-count: v0.1.0},
      month        = may,
      year         = 2026,
      publisher    = {Zenodo},
      version      = {v0.1.0},
      doi          = {10.5281/zenodo.20349359},
      url          = {https://doi.org/10.5281/zenodo.20349359},
    }
    ```

=== "APA"

    ```
    Kuhn, S. (2026). OpenOmics/microbe-count: v0.1.0 (v0.1.0). Zenodo. https://doi.org/10.5281/zenodo.20349359
    ```

For more citation style options, please visit the pipeline's [Zenodo page](https://doi.org/10.5281/zenodo.20349358).


## References

<sup>**1.** Li, H., Handsaker, B., Wysoker, A., Fennell, T., Ruan, J., Homer, N., Marth, G., Abecasis, G., Durbin, R., & 1000 Genome Project Data Processing Subgroup (2009). The Sequence Alignment/Map format and SAMtools. Bioinformatics (Oxford, England), 25(16), 2078–2079. https://doi.org/10.1093/bioinformatics/btp352</sup>
<sup>**2.** Wood, D. E., Lu, J., & Langmead, B. (2019). Improved metagenomic analysis with Kraken 2. Genome biology, 20(1), 257. https://doi.org/10.1186/s13059-019-1891-0</sup>
<sup>**3.** Lu, J., Breitwieser, F. P., Thielen, P., & Salzberg, S. L. (2017). Bracken: estimating species abundance in metagenomics data. PeerJ. Computer science, 3, e104. https://doi.org/10.7717/peerj-cs.104</sup>
<sup>**4.** Beber, M. E., Borry, M., Stamouli, S., & Fellows Yates, J. A. (2023). TAXPASTA: TAXonomic Profile Aggregation and STAndardisation. Journal of Open Source Software, 8(87), 5627. https://doi.org/10.21105/joss.05627</sup>
<sup>**5.**  Kurtzer GM, Sochat V, Bauer MW (2017). Singularity: Scientific containers for mobility of compute. PLoS ONE 12(5): e0177459.</sup>
<sup>**6.**  Koster, J. and S. Rahmann (2018). "Snakemake-a scalable bioinformatics workflow engine." Bioinformatics 34(20): 3600.</sup>
