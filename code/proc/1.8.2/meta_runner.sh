#!/usr/bin/env bash


inp=''
outp=''


n=9
sparse='1 0.5 0.2 0.1 0.01'
prec='1 2 3 4 5'

for s in ${sparse}
do
  for p in ${prec}
  do

    echo ${s} ${p}
    ./runner-singularity.sh \
         /ocean/projects/cis210040p/shared/ABIDE_NYU/dataset/ \
         /ocean/projects/cis210040p/shared/ABIDE_NYU/derivatives_v1.8.2/cpac \
         mca ${n} ${s} ${p}

  done
done
