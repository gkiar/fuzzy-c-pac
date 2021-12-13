#!/usr/bin/env bash

odir="/ocean/projects/cis210040p/shared/ABIDE_NYU/derivatives"
pls="afni python hybrid"
for fl in `ls ${odir} | grep cpac_`
do

  for pl in $pls 
  do

    for ev in `seq 9`
    do

      sbatch ./metadriver.sh ${odir}/$fl eval-${ev} $pl

    done
  done
done

