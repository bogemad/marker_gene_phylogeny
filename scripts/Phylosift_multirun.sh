#!/bin/bash

workdir=$base_path/.temp/psift_$num
mkdir -p $workdir
cd $workdir
export workdir
function finish {
  rm -rf "$workdir"
}
trap finish EXIT

cp -a $base_path/.mc/opt/phylosift_20141126 .
phylodir=$workdir/phylosift_20141126

cd $out

$phylodir/phylosift search --isolate --besthit --debug $file
$phylodir/phylosift align --isolate --besthit --debug $file
