<div align="center">
   
  <h1>microbe-count 🔬</h1>
  
  **_An awesome snakemake pipeline to quantify microbial composition_**

  [![GitHub release (latest SemVer including pre-releases)](https://img.shields.io/github/v/release/OpenOmics/microbe-count?color=blue&include_prereleases)](https://github.com/OpenOmics/microbe-count/releases) [![Docker Pulls](https://img.shields.io/docker/pulls/skchronicles/microbe-count)](https://hub.docker.com/repository/docker/skchronicles/microbe-count) <br> [![tests](https://github.com/OpenOmics/microbe-count/workflows/tests/badge.svg)](https://github.com/OpenOmics/microbe-count/actions/workflows/main.yaml) [![docs](https://github.com/OpenOmics/microbe-count/workflows/docs/badge.svg)](https://github.com/OpenOmics/microbe-count/actions/workflows/docs.yml) [![GitHub issues](https://img.shields.io/github/issues/OpenOmics/microbe-count?color=brightgreen)](https://github.com/OpenOmics/microbe-count/issues)  [![GitHub license](https://img.shields.io/github/license/OpenOmics/microbe-count)](https://github.com/OpenOmics/microbe-count/blob/main/LICENSE) 
  
  <i>
    This is the home of the pipeline, microbe-count. Its long-term goals: to make estimating microbial composition from host-aligned data quick and easy.
  </i>
</div>

## Overview

Welcome to microbe-count! Before getting started, we highly recommend reading through [microbe-count's documentation](https://openomics.github.io/microbe-count/). This pipeline is a wrapper around several tools to estimate microbial composition from host-aligned paired-end BAM files. For each sample, reads that did not align to the host genome are extracted from the BAM file and converted to FASTQ format using samtools<sup>1</sup>. The unmapped reads are then classified taxonomically with kraken2<sup>2</sup>, and bracken<sup>3</sup> is used to estimate different taxonomic-level abundances from the Kraken2's output. Finally, per-sample Bracken outputs are merged into a count matrix with samples as rows and microbial species as columns using taxpasta<sup>4</sup>. The pipeline is designed to be highly scalable, reproducible, and easy to use.

The **`./microbe-count`** pipeline is composed several inter-related sub commands to setup and run the pipeline across different systems. Each of the available sub commands perform different functions: 

 * [<code>microbe-count <b>run</b></code>](https://openomics.github.io/microbe-count/usage/run/): Run the microbe-count pipeline with your input BAM files.
 * [<code>microbe-count <b>unlock</b></code>](https://openomics.github.io/microbe-count/usage/unlock/): Unlocks a previous runs output directory.
 * [<code>microbe-count <b>install</b></code>](https://openomics.github.io/microbe-count/usage/install/): Download reference files locally.
 * [<code>microbe-count <b>cache</b></code>](https://openomics.github.io/microbe-count/usage/cache/): Cache software containers locally.

**microbe-count** is a pipeline to make running kraken2 and bracken easier, more reproducible, and more scalable. It relies on technologies like [Singularity<sup>5</sup>](https://singularity.lbl.gov/) to maintain the highest-level of reproducibility. The pipeline consists of a series of data processing and quality-control steps orchestrated by [Snakemake<sup>6</sup>](https://snakemake.readthedocs.io/en/stable/), a flexible and scalable workflow management system, to submit jobs to a cluster.

The pipeline is compatible with data generated from Illumina short-read sequencing technologies. As input, it accepts a set of host alined paired-end BAM files and can be run locally on a compute instance or on-premise using a cluster. A user can define the method or mode of execution. The pipeline can submit jobs to a cluster using a job scheduler like SLURM (more coming soon!). A hybrid approach ensures the pipeline is accessible to all users.

Before getting started, we highly recommend reading through the [usage](https://openomics.github.io/microbe-count/usage/run/) section of each available sub command.

For more information about issues or trouble-shooting a problem, please checkout our [FAQ](https://openomics.github.io/microbe-count/faq/questions/) prior to [opening an issue on Github](https://github.com/OpenOmics/microbe-count/issues).

## Dependencies

**Requires:** `singularity>=3.5`  `snakemake<=7.32.4`

At the current moment, the pipeline only has two dependencies: snakemake and singularity. With that being said, [snakemake](https://snakemake.readthedocs.io/en/stable/getting_started/installation.html) and [singularity](https://singularity.lbl.gov/all-releases) must be installed on the target system. Snakemake orchestrates the execution of each step in the pipeline. To guarantee the highest level of reproducibility, each step of the pipeline relies on versioned images from [DockerHub](https://hub.docker.com/repository/docker/skchronicles/microbe-count). Snakemake uses singularity to pull these images onto the local filesystem prior to job execution, and as so, snakemake and singularity will be the only two dependencies in the future.

## Installation

Please clone this repository to your local filesystem using the following command:
```bash
# Clone Repository from Github
git clone https://github.com/OpenOmics/microbe-count.git
# Change your working directory
cd microbe-count/
# Add dependencies to $PATH
# Skyline users should use
module load snakemake/7.22.0-ufanewz
# Get usage information
./microbe-count -h
```

## Contribute 

This site is a living document, created for and by members like you. microbe-count is maintained by the members of OpenOmics and is improved by continous feedback! We encourage you to contribute new content and make improvements to existing content via pull request to our [GitHub repository](https://github.com/OpenOmics/microbe-count).

## Cite

If you use this software, please cite it as below:  

<details>
  <summary><b><i>@BibText</i></b></summary>
 
```text
Coming Soon!
```

</details>

<details>
  <summary><b><i>@APA</i></b></summary>

```text
Coming Soon!
```

</details>


## References

<sup>**1.** Li, H., Handsaker, B., Wysoker, A., Fennell, T., Ruan, J., Homer, N., Marth, G., Abecasis, G., Durbin, R., & 1000 Genome Project Data Processing Subgroup (2009). The Sequence Alignment/Map format and SAMtools. Bioinformatics (Oxford, England), 25(16), 2078–2079. https://doi.org/10.1093/bioinformatics/btp352</sup>   
<sup>**2.** Wood, D. E., Lu, J., & Langmead, B. (2019). Improved metagenomic analysis with Kraken 2. Genome biology, 20(1), 257. https://doi.org/10.1186/s13059-019-1891-0</sup>   
<sup>**3.** Lu, J., Breitwieser, F. P., Thielen, P., & Salzberg, S. L. (2017). Bracken: estimating species abundance in metagenomics data. PeerJ. Computer science, 3, e104. https://doi.org/10.7717/peerj-cs.104</sup>   
<sup>**4.** Beber, M. E., Borry, M., Stamouli, S., & Fellows Yates, J. A. (2023). TAXPASTA: TAXonomic Profile Aggregation and STAndardisation. Journal of Open Source Software, 8(87), 5627. https://doi.org/10.21105/joss.05627</sup>  
<sup>**5.**  Kurtzer GM, Sochat V, Bauer MW (2017). Singularity: Scientific containers for mobility of compute. PLoS ONE 12(5): e0177459.</sup>  
<sup>**6.**  Koster, J. and S. Rahmann (2018). "Snakemake-a scalable bioinformatics workflow engine." Bioinformatics 34(20): 3600.</sup>  
 