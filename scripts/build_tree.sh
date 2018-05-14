#!/bin/bash

scripts="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
base_path=`dirname $scripts`
export PATH=$base_path/.mc/bin:$base_path/scripts:$base_path/.mc/opt/phylosift_20141126:$PATH
limit=$1

data=$base_path/raw_data
results=$base_path/analysis_results

if [ "$(ls $results)" != '' ]; then
	echo "Alignment files already exist. Please move or delete files from analysis_results directory."
	exit 1
fi

clean_trim_alignments.py $limit

