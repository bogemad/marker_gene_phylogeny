#!/bin/bash

base_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
temp_scripts=$base_path/scripts/temp

mkdir -p $temp_scripts

sed "s~xxxbasepathxxx~$base_path~g" $base_path/scripts/submit_qsub.sh > $temp_scripts/submit_qsub_temp.sh
qsub $temp_scripts/submit_qsub_temp.sh

rm -rf $temp_scripts/*
rm -rf $temp_scripts
