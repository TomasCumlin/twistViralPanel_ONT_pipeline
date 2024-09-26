#!/bin/bash

export input_dir=$1
export output_dir=$2
mkdir -p "${output_dir}/assembly_QC"

# 1) Assemble metagenomic data

# Loop over each FASTQ file
for fastq in "$input_dir"/*.fastq; do
    base_name=$(basename "$fastq" .fastq)
    megahit -r $fastq -o "${output_dir}/${base_name}" --out-prefix $base_name --min-count 2 --k-min 27 --k-max 127 --k-step 10 --min-contig-len 500 --prune-level 2 -t 8
    mv "$output_dir/$base_name"/*.fa $output_dir
    mv "$output_dir/$base_name"/*.log $output_dir
    rm -r "$output_dir/$base_name"
done

# 2) Check assembly quality

for file in "$output_dir"/*.fa; do
  base_name=$(basename "$file" .contigs.fa)
  quast --no-icarus --no-html --space-efficient -o "${output_dir}/${base_name}" "$file"
  mv "$output_dir/$base_name"/report.pdf "${output_dir}/assembly_QC/${base_name}_report.pdf"
  rm -r "$output_dir/$base_name" 
done
