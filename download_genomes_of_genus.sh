#!/bin/bash

base_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export PATH=$base_path/.mc/bin:$base_path/.mc/share/phylosift_20141126:$PATH
temp=$base_path/temp
genus=$1

mkdir -p $temp
wget -O $temp/assembly_summary.txt ftp://ftp.ncbi.nlm.nih.gov/genomes/refseq/bacteria/assembly_summary.txt

