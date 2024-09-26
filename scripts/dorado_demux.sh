#!/bin/bash

input_dir=$1
output_dir=$2

temp_dir=$(mktemp -d)

# Loop through all fastq.gz files in the input directory
for fastq_file in ${input_dir}/*.fastq.gz; do

base_name=$(basename "$fastq_file" .fastq.gz)

zcat $fastq_file | awk '{
    if(NR % 4 == 1) {
        if(length($0) > 200) {
            print substr($0, 1, 200)
        } else {
            print $0
        }
    } else {
        print $0
    }
}' | gzip > "${base_name}_shortened.fastq.gz"

   # Run Dorado on the current fastq.gz file, outputting to the temporary directory
    dorado demux --output-dir ${temp_dir} --kit-name TWIST-16-UDI --emit-fastq --barcode-both-ends "${base_name}_shortened.fastq.gz"
    rm "${base_name}_shortened.fastq.gz"

    for output_file in ${temp_dir}/*.fastq; do
        filename=$(basename "$output_file")
        if [ -f "${output_dir}/${filename}" ]; then
            # If the output file already exists, append contents of demultiplexed file to it
            cat "${output_file}" >> "${output_dir}/${filename}"
        else
            # If the output file does not exist, move the demultiplexed file to output directory
            mv "${temp_dir}/${filename}" "${output_dir}/"
        fi
    done

done

# Clean up temporary directory
rm -r ${temp_dir}
rm "${output_dir}/unclassified.fastq"