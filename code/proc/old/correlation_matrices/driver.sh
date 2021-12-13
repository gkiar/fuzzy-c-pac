#!/usr/bin/env bash

derivdir=$1
# derivdir="/ocean/projects/cis210040p/gkiar/data/ABIDE_NYU/derivatives/"
pattern="*space-template*desc-cleaned-1_bold.nii.gz"

bp="/ocean/projects/cis210040p/gkiar/code/fuzzy-c-pac/code/correlation_matrices"
sublist="${derivdir}/cleaned_bold.txt"
proclist="${derivdir}/correlations.txt"
pardir="${bp}/Schaefer"

echo $sublist
if [ ! -f ${sublist} ]
then
  find ${derivdir} -type f -name ${pattern} > ${sublist}
fi

cat ${sublist} | wc -l

parcellations="200 600 1000"
implementations=$2
echo ${implementations}
# implementations="afni python hybrid"

while read -r line 
do
  for parc in ${parcellations}
  do
    for imp in ${implementations}
    do
      pfil=${pardir}/$(ls ${pardir} | grep ${parc})
      script=${bp}/${imp}/driver.sh
      outp=${line/bold.nii.gz/parc-Schaeffer${parc}_corr-${imp}.mat}

      ${script} ${pfil} ${line} ${outp}
      echo "${outp}" >> ${proclist}
    done
  done
done < "${sublist}"

