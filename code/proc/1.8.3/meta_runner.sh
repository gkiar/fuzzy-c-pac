#!/usr/bin/env bash


inp='/jet/home/gkiar/shared_data/ABIDEI/NYU'
outp='/jet/home/gkiar/shared_data/ABIDEI/NYU/derivatives/resource'

n="2th_run"
sparse='1 0.5 0.1 0.01'
prec='1 2 3'

./runner-singularity.sh ${inp} ${outp} ieee ${n}
exit 0

for s in ${sparse}
do
  for p in ${prec}
  do

    echo ${s} ${p}
    ./runner-singularity.sh ${inp} ${outp} mca ${n} ${s} ${p}

  done
done
