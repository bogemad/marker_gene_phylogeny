#!/bin/bash

base_path=xxxbasepathxxx
workdir=$base_path/.temp/psift_xxxnumxxx
mkdir -p $workdir
cd $workdir
export workdir
function finish {
  rm -rf "$workdir"
}
trap finish EXIT

cp -av $base_path/.mc/opt/phylosift_20141126 .
phylodir=$workdir/phylosift_20141126

out=xxxoutxxx
cd $out
file=xxxfilexxx

$phylodir/phylosift search --isolate --besthit --debug $file
$phylodir/phylosift align --isolate --besthit --debug $file
