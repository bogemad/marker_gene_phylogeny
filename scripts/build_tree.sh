#!/bin/bash

scripts="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
base_path=`dirname $scripts`
export PATH=$base_path/.mc/bin:$base_path/scripts:$base_path/.mc/share/phylosift_20141126:$PATH

data=$base_path/raw_data
results=$base_path/analysis_results
#alignments=$results/phylosift_analysis_files

#mkdir -p $alignments
#cp -avf $data/PS_temp/* $alignments || (echo "File transfer failed, please retry."; exit 1)
#rm -rf $data/PS_temp/*

if [ "$(ls $results)" != '' ]; then
	echo "Alignment files already exist. Please move or delete files from analysis_results directory."
	exit 1
fi

#find $data/PS_temp -type f -regex '.*alignDir/concat.codon.updated.1.fasta' -exec cat {} \; | sed -r 's/\.1\..*//'  > $results/raw_alignment.fa

clean_trim_alignments.py

# trimal -in $results/raw/raw_alignment.fa -out $results/raw/trimmed_alignment_raw.fa -nogaps

# trimal -in $results/gt_10.0_percent_gaps_removed/cleaned_alignment_0.100.fa -out $results/gt_10.0_percent_gaps_removed/trimmed_alignment_0.100.fa -nogaps
# trimal -in $results/gt_5.0_percent_gaps_removed/cleaned_alignment_0.050.fa -out $results/gt_5.0_percent_gaps_removed/trimmed_alignment_0.050.fa -nogaps
# trimal -in $results/gt_2.5_percent_gaps_removed/cleaned_alignment_0.025.fa -out $results/gt_2.5_percent_gaps_removed/trimmed_alignment_0.025.fa -nogaps

# check_trim $results/raw/trimmed_alignment_raw.fa $results/raw/raw_alignment.fa $results/raw/trimming_report_raw.txt

# check_trim $results/gt_10.0_percent_gaps_removed/trimmed_alignment_0.100.fa $results/gt_10.0_percent_gaps_removed/cleaned_alignment_0.100.fa $results/gt_10.0_percent_gaps_removed/trimming_report_0.100.txt
# check_trim $results/gt_5.0_percent_gaps_removed/trimmed_alignment_0.050.fa $results/gt_5.0_percent_gaps_removed/cleaned_alignment_0.050.fa $results/gt_5.0_percent_gaps_removed/trimming_report_0.050.txt
# check_trim $results/gt_2.5_percent_gaps_removed/trimmed_alignment_0.025.fa $results/gt_2.5_percent_gaps_removed/cleaned_alignment_0.025.fa $results/gt_2.5_percent_gaps_removed/trimming_report_0.025.txt

# FastTree -nt -gtr < $results/raw/trimmed_alignment_raw.fa > $results/raw/phylosift_tree_raw.tre

# FastTree -nt -gtr < $results/gt_10.0_percent_gaps_removed/trimmed_alignment_0.100.fa > $results/gt_10.0_percent_gaps_removed/phylosift_tree_0.100.tre
# FastTree -nt -gtr < $results/gt_5.0_percent_gaps_removed/trimmed_alignment_0.050.fa > $results/gt_5.0_percent_gaps_removed/phylosift_tree_0.050.tre
# FastTree -nt -gtr < $results/gt_2.5_percent_gaps_removed/trimmed_alignment_0.025.fa > $results/gt_2.5_percent_gaps_removed/phylosift_tree_0.025.tre

