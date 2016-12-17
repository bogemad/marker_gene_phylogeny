#!/bin/bash

base_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source $base_path/.mc/bin/activate phylosift
out=$1
temp=$HOME/temp/phylosift_scripts
script_path=$base_path/scripts

cd $out
num=11

mkdir -p $temp

while [ $num -lt `find $out -maxdepth 1 -name "*.fasta" | wc -l` ]; do
	let topnum=num-10
	file_list=( $(find $out -maxdepth 1 -name "*.fasta" | tail -n +$topnum | head -n 10) )
	sed "s~xxxnumxxx~$num~g" $script_path/Phylosift_multirun10.sh | \
	sed "s~xxxoutxxx~$out~g" | \
	sed "s~xxxfile0xxx~${file_list[0]}~g" | \
	sed "s~xxxfile1xxx~${file_list[1]}~g" | \
	sed "s~xxxfile2xxx~${file_list[2]}~g" | \
	sed "s~xxxfile3xxx~${file_list[3]}~g" | \
	sed "s~xxxfile4xxx~${file_list[4]}~g" | \
	sed "s~xxxfile5xxx~${file_list[5]}~g" | \
	sed "s~xxxfile6xxx~${file_list[6]}~g" | \
	sed "s~xxxfile7xxx~${file_list[7]}~g" | \
	sed "s~xxxfile8xxx~${file_list[8]}~g" | \
	sed "s~xxxfile9xxx~${file_list[9]}~g" \
	> $temp/Phylosift_$num.sh
	qsub $temp/Phylosift_$num.sh
	rm $temp/Phylosift_$num.sh
	let num=num+10
done

let topnum=num-10
num=0
for file in $(find $out -maxdepth 1 -name "*.fasta" | tail -n +$topnum); do
	let num=num+1
	sed -e "s~xxxnumxxx~$num~g" $script_path/Phylosift_multirun.sh | sed -e "s~xxxoutxxx~$out~g" | sed -e "s~xxxfilexxx~$file~g" > $temp/Phylosift_$num.sh
	qsub $temp/Phylosift_$num.sh
	rm $temp/Phylosift_$num.sh
done
