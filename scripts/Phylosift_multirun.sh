#PBS -N Phylosift_xxxnumxxx
#PBS -l ncpus=1
#PBS -l mem=8gb
#PBS -l walltime=2:00:00
#PBS -q smallq
#PBS -o xxxbasepathxxx/logs/Phylosift_xxxnumxxx.out
#PBS -e xxxbasepathxxx/logs/Phylosift_xxxnumxxx.err

workdir=/scratch/work/psift_xxxnumxxx
base_path=xxxbasepathxxx
mkdir $workdir
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
file=xxxfilexxx

$phylodir/phylosift search --isolate --besthit --debug $file
$phylodir/phylosift align --isolate --besthit --debug $file
