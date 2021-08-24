#!/usr/bin/env bash

# Provide and parse arguments:
dp=$1       # 1: Dataset path            =/path/to/data
op=$2       # 2: Output path             =/path/to/results
mode=$3     # 3: MCA mode                ={ieee, mca}
numb=$4     # 4: Number of runs         >=1
spar=$5     # 5: Sparsity                =(0, 1]
prec=$6     # 6: Reduction in precision >=0


if [ $mode == 'ieee' ]
then
  # Setup IEEE Backend
  op=${op}_${mode}
  mkdir -p ${op}
  echo "libinterflop_ieee.so" > ${op}/vfcbackend.txt

else
  # Setup MCA Backend
  # First, make sure all args are there
  if [ -z "$prec" ]
  then
    echo "Provide args as follows:"
    echo "   dataset_path output_path {ieee,mca} n_runs sparsity precision_reduction"
    exit 1
  fi
  op=${op}_${mode}_sp-${spar}_pr-${prec}
  mkdir -p ${op}

  # Validate sparsity
  if [ $(echo "($spar > 0) && ($spar <= 1)" | bc) -eq 1 ]
  then
    # Validate precision
    if (("$prec" >= 0))
    then
      fprec=$((24 - "$prec"))
      dprec=$((53 - "$prec"))
      echo "libinterflop_mca.so -m mca --sparsity=${spar} --precision-binary32=${fprec} --precision-binary64=${dprec}" > ${op}/vfcbackend.txt

    fi
  fi
fi

# Print backend
cat ${op}/vfcbackend.txt

for i in `seq 0 ${numb}`;
do
  mkdir -p ${op}/eval-${i}
  cat > ${op}/eval-${i}/script.sh <<EOF
#!/bin/bash

module load singularity
cd ${PWD}

singularity run \\
      -B ${PWD}:${PWD} \\
      -B ${dp}:${dp} \\
      -B ${op}:${op} \\
      --env VFC_BACKENDS_FROM_FILE=${op}/vfcbackend.txt \\
      ~/images/fuzzy-cpac.sif \\
      ${dp} \\
      ${op}/mca-${i}/ \\
      participant \\
      --save_working_dir \\
      --skip_bids_validator \\
      --preconfig preproc \\
      --n_cpus 7 \\
      --mem_gb 14

singularity run \\
      -B ${PWD}:${PWD} \\
      -B ${dp}:${dp} \\
      -B ${op}:${op} \\
      --env VFC_BACKENDS_FROM_FILE=${op}/vfcbackend.txt \\
      ~/images/fuzzy-cpac.sif \\
      connectivity_scripts.... #TODO: this

EOF

  chmod +x ${op}/eval-${i}/script.sh  
  sbatch ${op}/eval-${i}/script.sh -t 2:00:00 -p RM-shared -n 7
done
