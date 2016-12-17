#!/bin/bash

scripts="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
base_path=`dirname $scripts`
export PATH=$base_path/.mc/bin:$base_path/scripts:$base_path/.mc/share/phylosift_20141126:$PATH

data=$base_path/raw_data
results=$base_path/analysis_results
alignments=$results/phylosift_analysis_files

mkdir -p $alignments
cp -avf $data/PS_temp/* $alignments || (echo "File transfer failed, please retry."; exit 1)
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

find $results -type f -regex '.*alignDir/concat.codon.updated.1.fasta' -exec cat {} \; | sed -r 's/\.1\..*//'  > $results/raw_alignment.fa

trimal -in $results/raw_alignment.fa -out $results/trimmed_alignment.fa -nogaps

check_trim $results/trimmed_alignment.fa $results/raw_alignment.fa

FastTree -nt -gtr < $results/trimmed_alignment.fa > $results/phylosift_tree.tre

