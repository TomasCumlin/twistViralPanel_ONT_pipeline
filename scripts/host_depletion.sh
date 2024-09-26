#!/bin/bash

INPUT_DIR=$1
HUMAN_GENOME_INDEX=$2
OUTPUT_DIR=$3

# Create output directory if it doesn't exist
mkdir -p $OUTPUT_DIR

# Loop over each FASTQ file
for fastq in "$INPUT_DIR"/*.fastq.gz; do
    
    base_name=$(basename "$fastq" .fastq.gz)

    # Step 1: Align reads to the human genome
    minimap2 -ax map-ont $HUMAN_GENOME_INDEX $fastq | samtools view -b -f 4 - > "${OUTPUT_DIR}/${base_name}_non_human.bam"

    # Step 2: Convert non-human BAM file back to FASTQ format
    samtools fastq "${OUTPUT_DIR}/${base_name}_non_human.bam" > "${OUTPUT_DIR}/${base_name}_non_human.fastq"
    gzip "${OUTPUT_DIR}/${base_name}_non_human.fastq"

    # Clean up intermediate BAM file (optional)
    rm "${OUTPUT_DIR}/${base_name}_non_human.bam"

    echo "Finished host filtering $fastq"
done