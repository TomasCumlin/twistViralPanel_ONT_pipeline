#!/bin/bash

input_dir=$1
output_dir=$2

# Create the output directory if it doesn't exist
mkdir -p "$output_dir"
mkdir -p "${output_dir}/fastp_reports"

# Loop through all fastq.gz files in the input directory
for fastq_file in "$input_dir"/*.fastq
do
    base_name=$(basename "$fastq_file" .fastq)
    
    output_file="$output_dir/${base_name}.fastq"
    
    fastp -i "$fastq_file" -o "$output_file" -A -g -5 -3 -W 5 -M 20 -q 20 -e 20 -l 100 -h "${output_dir}/fastp_reports/${base_name}_fastp_report.html" -j "${output_dir}/fastp_reports/${base_name}_fastp_report.json"
done

echo "All files have been processed with fastp."
