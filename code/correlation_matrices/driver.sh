#!/usr/bin/env bash

derivdir="/ocean/projects/cis210040p/gkiar/data/ABIDE_NYU/derivatives/"
pattern="*space-template*cleaned*nii.gz"
sublist="./preproc_bold.txt"

if [ ! -f ${sublist} ]
then
  find ${derivdir} -type f -name ${pattern} > ${sublist}
fi

cat ${sublist} | wc -l

parcellations="200 600 1000"
implementations="afni python hybrid"

while read -r line 
do
  for parc in ${parcellations}
  do
    for imp in ${implementations}
    do
      echo ${line}
      echo ${line/bold.nii.gz/parc-Schaeffer${parc}_corr-${imp}.mat}
    done
  done
  break
done < "${sublist}"
