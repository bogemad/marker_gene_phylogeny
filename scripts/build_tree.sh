#!/bin/bash

scripts="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
base_path=`dirname $scripts`
export PATH=$base_path/.mc/bin:$base_path/scripts:$base_path/.mc/opt/phylosift_20141126:$PATH

clean_trim_alignments.py "$@"

