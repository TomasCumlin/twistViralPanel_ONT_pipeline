# Pipeline for processing ONT sequencing data from the Twist Comprehensive Viral Research Panel protocol.
# Includes host filtering (optional), demultiplexing, preprocessing, and metagenomic assembly (optional).
# Specify variables marked with "edit" before running.
# The other scripts running the bioinformatic software may be edited by the user.


# 1) Specify directories

export root="/path/to/twistViralPanel_ONT_pipeline" #edit
export input_dir="/path/to/input/directory" #edit
export output_dir="/path/to/output/directory" #edit

# 2) Specify these analysis parameters for host DNA filtering and/or metagenomic assembly.

# 2a) To perform host DNA filtering, set "host_depletion" to true and specify the directory paths.
export host_depletion=false  #edit (optional)
export human_genome_index="/path/to/human_genome.mmi"  #edit (optional)

# 2b) To perform metagenomic assembly, set "assembly" to true.
export assembly=false #edit (optional)

# 3) Run analysis

mkdir -p $output_dir

if [ "$host_depletion" = true ]; then
    bash "${root}/scripts/host_depletion.sh" "$input_dir" "$human_genome_index" "${output_dir}/host_filtered_data"
    export input_dir="${output_dir}/host_filtered_data"
fi

mkdir -p "${output_dir}/dorado_output"
bash "${root}/scripts/dorado_demux.sh" "$input_dir" "${output_dir}/dorado_output"

mkdir -p "${output_dir}/demultiplexed_data"
bash "${root}/scripts/preprocessing_fastp.sh" "${output_dir}/dorado_output" "${output_dir}/demultiplexed_data"
rm -r "${output_dir}/dorado_output"

if [ "$assembly" = true ]; then
    bash "${root}/scripts/metagenomic_analysis.sh" "${output_dir}/demultiplexed_data" "${output_dir}/metagenomic_assembly"
fi