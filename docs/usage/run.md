# <code>microbe-count <b>run</b></code>

## 1. About 

The `microbe-count` executable is composed of several inter-related sub commands. Please see `microbe-count -h` for all available options.

This part of the documentation describes options and concepts for <code>microbe-count <b>run</b></code> sub command in more detail. With minimal configuration, the **`run`** sub command enables you to start running microbe-count pipeline. 

Setting up the microbe-count pipeline is fast and easy! In its most basic form, <code>microbe-count <b>run</b></code> only has *three required inputs*.

## 2. Synopsis

```text
$ microbe-count run [--help] \\
      [--dry-run] [--job-name JOB_NAME] [--mode {{slurm,local}}] \\
      [--sif-cache SIF_CACHE] [--singularity-cache SINGULARITY_CACHE] \\
      [--silent] [--threads THREADS] [--tmp-dir TMP_DIR] \\
      [--batch-id BATCH_ID] [--taxonomic-level TAXONOMIC_LEVEL] \\
      --input INPUT [INPUT ...] \\
      --output OUTPUT \\
      --kraken2-db-path KRAKEN2_DB_PATH
```

The synopsis for each command shows its arguments and their usage. Optional arguments are shown in square brackets.

A user **must** provide a list of host aligned, paired-end BAM files (globbing is supported) to analyze via `--input` argument, an output directory to store results via `--output` argument, and a path/directory to a kraken2 database. The kraken2 database path must also contain bracken db reference files, along with a `names.dmp` and `nodes.dmp` files. Kraken2 databases downloaded from [Ben Langmead's AWS indexes](https://benlangmead.github.io/aws-indexes/k2) are compatible with microbe-count. These public databases can all the required reference file for running the pipeline end-to-end.

Use you can always use the `-h` option for information on a specific command. 

### 2.1 Required arguments

Each of the following arguments are required. Failure to provide a required argument will result in a non-zero exit-code.

  `--input INPUT [INPUT ...]`  
> **Input BAM file(s).**  
> *type: BAM file(s)*  
> 
> Input host aligned, paired-end BAM files to process. BAM files for one or more samples can be provided. Multiple input BAM files should be seperated by a space. Globbing for multiple file is also supported! This makes selecting BAM files easy.
> 
> ***Example:*** `--input .tests/*.bam`

---  
  `--output OUTPUT`
> **Path to an output directory.**   
> *type: path*
>   
> This location is where the pipeline will create all of its output files, also known as the pipeline's working directory. If the provided output directory does not exist, it will be created automatically. Within this output directory, the `counts` directory will contain a counts matrix for each of the taxonomic levels that were provide via the `--taxonomic-level` argument. The `report` directory contains a multiqc report summarizing the output from different tools (i.e `kraken2`, `samtools`, `fastp`, `fastqc`, etc.). 
> 
> ***Example:*** `--output /data/$USER/microbe-count_out`

---  
  `--kraken2-db-path KRAKEN2_DB_PATH`
> **Path to a Kraken2 + Braken Database.**   
> *type: path*
>   
> A path or a directory to a kraken2 + braken database. This database will be used for estimating microbial composition of each sample using kraken2 and bracken. Please see the kraken2 + bracken documentation for more information on how to build reference files for these tools. Kraken2 + bracken databases downloaded from [Ben Langmead's AWS indexes](https://benlangmead.github.io/aws-indexes/k2) are compatible with microbe-count. These public databases can all the required reference file for running the pipeline end-to-end. If you have already built a kraken2 database, you can provide the path to the directory containing the database files. The pipeline will automatically search for the other database files in the same directory.
> 
> ***Example:*** `--kraken2-db-path .tests/kraken2-db`

### 2.2 Analysis options

Each of the following arguments are optional, and do not need to be provided. 

  `--batch-id BATCH_ID`
> **Unique identifer to associate with a batch of samples.**   
> *type: string*  
> *default: None*   
>
> This option can be provided to ensure that the counts matrix are not over-written between runs of the pipeline. This ensures project-level files (which are unique) will not get over written. With that being said, it is always a good idea to provide this option. A unique batch id should be provided between runs. This batch id should be composed of alphanumeric characters and it should not contain a white space or tab characters. Here is a list of valid or acceptable characters: `aA-Zz`, `0-9`, `-`, `_`.
> 
> ***Example:*** `--batch-id 2025_04_08`

  `--taxonomic-level TAXONOMIC_LEVEL`
> **One or more taxonomic levels to re-estimate microbial abudances.**  
> *type: string(s)*  
> *default: `S`*  
>
> This option is used to specify the one or more taxonomic levels to estimate microbial composition with bracken. Valid options include: `D` for domain, `P` for phylum, `C` for class, `O` for order, `F` for family, `G` for genus, and `S` for species. By default, the pipeline will estimate microbial composition at the species-level.
> 
> ***Example:*** `--taxonomic-level D G S`

### 2.3 Orchestration options

Each of the following arguments are optional, and do not need to be provided. 

  `--dry-run`            
> **Dry run the pipeline.**  
> *type: boolean flag*
> 
> Displays what steps in the pipeline remain or will be run. Does not execute anything!
>
> ***Example:*** `--dry-run`

---  
  `--silent`            
> **Silence standard output.**  
> *type: boolean flag*
> 
> Reduces the amount of information directed to standard output when submitting master job to the job scheduler. Only the job id of the master job is returned.
>
> ***Example:*** `--silent`

---  
  `--mode {slurm,local}`  
> **Execution Method.**  
> *type: string*   
> *default: slurm*
> 
> Execution Method. Defines the mode or method of execution. Vaild mode options include: slurm or local. 
> 
> ***slurm***    
> The slurm execution method will submit jobs to the [SLURM workload manager](https://slurm.schedmd.com/). It is recommended running microbe-count in this mode as execution will be significantly faster in a distributed environment. This is the default mode of execution.
>
> ***local***  
> Local executions will run serially on compute instance. This is useful for testing, debugging, or when a users does not have access to a high performance computing environment. If this option is not provided, it will default to a local execution mode. 
> 
> ***Example:*** `--mode slurm`

---  
  `--job-name JOB_NAME`  
> **Set the name of the pipeline's master job.**  
> *type: string*  
> *default: pl:microbe-count*
> 
> When submitting the pipeline to a job scheduler, like SLURM, this option always you to set the name of the pipeline's master job. By default, the name of the pipeline's master job is set to "pl:microbe-count".
> 
> ***Example:*** `--job-name pl_id-42`

---  
  `--singularity-cache SINGULARITY_CACHE`  
> **Overrides the $SINGULARITY_CACHEDIR environment variable.**  
> *type: path*  
> *default: `--output OUTPUT/.singularity`*
>
> Singularity will cache image layers pulled from remote registries. This ultimately speeds up the process of pull an image from DockerHub if an image layer already exists in the singularity cache directory. By default, the cache is set to the value provided to the `--output` argument. Please note that this cache cannot be shared across users. Singularity strictly enforces you own the cache directory and will return a non-zero exit code if you do not own the cache directory! See the `--sif-cache` option to create a shareable resource. 
> 
> ***Example:*** `--singularity-cache /data/$USER/.singularity`

---  
  `--sif-cache SIF_CACHE`
> **Path where a local cache of SIFs are stored.**  
> *type: path*  
>
> Uses a local cache of SIFs on the filesystem. This SIF cache can be shared across users if permissions are set correctly. If a SIF does not exist in the SIF cache, the image will be pulled from Dockerhub and a warning message will be displayed. The `microbe-count cache` subcommand can be used to create a local SIF cache. Please see `microbe-count cache` for more information. This command is extremely useful for avoiding DockerHub pull rate limits. It also remove any potential errors that could occur due to network issues or DockerHub being temporarily unavailable. We recommend running microbe-count with this option when ever possible.
> 
> ***Example:*** `--sif-cache /data/$USER/SIFs`

---  
  `--threads THREADS`   
> **Max number of threads for each process.**  
> *type: int*  
> *default: 2*
> 
> Max number of threads for each process. This option is more applicable when running the pipeline with `--mode local`.  It is recommended setting this vaule to the maximum number of CPUs available on the host machine.
> 
> ***Example:*** `--threads 12`


---  
  `--tmp-dir TMP_DIR`   
> **Max number of threads for each process.**  
> *type: path*  
> *default: /path/to/output/temp*
> 
> Path on the file system for writing temporary output files. Ideally, this path should point to a dedicated location on the filesystem for writing tmp files. On many systems, this location is set to somewhere in `/data/scratch`. If you need to inject a variable into this string that should NOT be expanded, please quote this options value in single quotes. By default, the temporary directory is set to a folder called `temp` in the output directory.
> 
> ***Example:*** `--tmp-dir /data/scratch/$USER`

### 2.4 Miscellaneous options 

Each of the following arguments are optional, and do not need to be provided. 

  `-h, --help`            
> **Display Help.**  
> *type: boolean flag*
> 
> Shows command's synopsis, help message, and an example command
> 
> ***Example:*** `--help`

## 3. Example

```bash 
# Step 1.) Grab an interactive node,
# do not run on head node!
srun -N 1 -n 1 --time=1:00:00 --mem=8gb  --cpus-per-task=2 --pty bash
module purge
module load snakemake/7.22.0-ufanewz

# Step 2A.) Dry-run the pipeline
./microbe-count run --input .tests/*.bam \
    --output microbe-count_output \
    --taxonomic-level G S \
    --kraken2-db-path .tests/kraken2-db \
    --mode slurm \
    --dry-run

# Step 2B.) Run the microbe-count pipeline
# The slurm mode will submit jobs to 
# the cluster. It is recommended running 
# the pipeline in this mode.
./microbe-count run --input .tests/*.bam \
    --output microbe-count_output \
    --taxonomic-level G S \
    --kraken2-db-path .tests/kraken2-db \
    --mode slurm
```
