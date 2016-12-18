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

if [ -f $results/raw_alignment.fa ]; then
	echo "Raw alignment file already exists. Please rename or remove raw_alignment.fa file from analysis results directory."
	exit 1
fi

if [ -f $results/trimmed_alignment.fa ]; then
	echo "Trimmed alignment file already exists. Please rename or remove trimmed_alignment.fa file from analysis results directory."
	exit 1
fi

if [ -f $results/phylosift_tree.tre ]; then
	echo "Tree file already exists. Please rename or remove phylosift_tree.tre file from analysis results directory."
	exit 1
fi

#find $data/PS_temp -type f -regex '.*alignDir/concat.codon.updated.1.fasta' -exec cat {} \; | sed -r 's/\.1\..*//'  > $results/raw_alignment.fa

clean_alignments.py

trimal -in $results/raw_alignment.fa -out $results/trimmed_alignment_raw.fa -nogaps

trimal -in $results/cleaned_alignment_0.100.fa -out $results/trimmed_alignment_0.100.fa -nogaps
trimal -in $results/cleaned_alignment_0.050.fa -out $results/trimmed_alignment_0.050.fa -nogaps
trimal -in $results/cleaned_alignment_0.025.fa -out $results/trimmed_alignment_0.025.fa -nogaps

check_trim $results/trimmed_alignment_raw.fa $results/raw_alignment.fa $results/trimming_report_raw.txt

check_trim $results/trimmed_alignment_0.100.fa $results/cleaned_alignment_0.100.fa $results/trimming_report_0.100.txt
check_trim $results/trimmed_alignment_0.050.fa $results/cleaned_alignment_0.050.fa $results/trimming_report_0.050.txt
check_trim $results/trimmed_alignment_0.025.fa $results/cleaned_alignment_0.025.fa $results/trimming_report_0.025.txt

FastTree -nt -gtr < $results/trimmed_alignment_raw.fa > $results/phylosift_tree_raw.tre

FastTree -nt -gtr < $results/trimmed_alignment_0.100.fa > $results/phylosift_tree_0.100.tre
FastTree -nt -gtr < $results/trimmed_alignment_0.050.fa > $results/phylosift_tree_0.050.tre
FastTree -nt -gtr < $results/trimmed_alignment_0.025.fa > $results/phylosift_tree_0.025.tre

