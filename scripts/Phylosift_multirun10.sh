#PBS -N Phylosift_xxxnumxxx
#PBS -l ncpus=1
#PBS -l mem=8gb
#PBS -l walltime=2:00:00
#PBS -q smallq
#PBS -o xxxbasepathxxx/logs/Phylosift_xxxnumxxx.out
#PBS -e xxxbasepathxxx/logs/Phylosift_xxxnumxxx.err

base_path=xxxbasepathxxx
workdir=$base_path/.temp/psift_xxxnumxxx
mkdir -p $workdir
cd $workdir
export workdir
function finish {
  rm -rf "$workdir"
}
trap finish EXIT

cp -av $base_path/.mc/share/phylosift_20141126 .
phylodir=$workdir/phylosift_20141126

out=xxxoutxxx
cd $out
file0=xxxfile0xxx

$phylodir/phylosift search --isolate --besthit --debug $file0
$phylodir/phylosift align --isolate --besthit --debug $file0
file1=xxxfile1xxx

$phylodir/phylosift search --isolate --besthit --debug $file1
$phylodir/phylosift align --isolate --besthit --debug $file1
file2=xxxfile2xxx

$phylodir/phylosift search --isolate --besthit --debug $file2
$phylodir/phylosift align --isolate --besthit --debug $file2
file3=xxxfile3xxx

$phylodir/phylosift search --isolate --besthit --debug $file3
$phylodir/phylosift align --isolate --besthit --debug $file3
file4=xxxfile4xxx

$phylodir/phylosift search --isolate --besthit --debug $file4
$phylodir/phylosift align --isolate --besthit --debug $file4
file5=xxxfile5xxx

$phylodir/phylosift search --isolate --besthit --debug $file5
$phylodir/phylosift align --isolate --besthit --debug $file5
file6=xxxfile6xxx

$phylodir/phylosift search --isolate --besthit --debug $file6
$phylodir/phylosift align --isolate --besthit --debug $file6
file7=xxxfile7xxx

$phylodir/phylosift search --isolate --besthit --debug $file7
$phylodir/phylosift align --isolate --besthit --debug $file7
file8=xxxfile8xxx

$phylodir/phylosift search --isolate --besthit --debug $file8
$phylodir/phylosift align --isolate --besthit --debug $file8
file9=xxxfile9xxx

$phylodir/phylosift search --isolate --besthit --debug $file9
$phylodir/phylosift align --isolate --besthit --debug $file9
