#!/usr/bin/env bash

# Provide and parse arguments:
dp=$1       # 1: Dataset path            =/path/to/data
op=$2       # 2: Output path             =/path/to/results
mode=$3     # 3: MCA mode                ={ieee, mca}
numb=$4     # 4: Number of runs         >=0
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

if iters=`seq 0 ${numb}`;
then
  echo Number of iterations: ${numb}
else
  iters=${numb}
  echo Number of iterations: 1
fi

for i in $iters;
do
  mkdir -p ${op}/eval-${i}
  cat > ${op}/eval-${i}/script.sh <<EOF
#!/bin/bash
#SBATCH -N 1
#SBATCH -p RM-shared
#SBATCH -t 1:00:00
#SBATCH --ntasks-per-node=3

cd ${PWD}

singularity exec \\
      -B ${PWD}:${PWD} \\
      -B ${dp}:${dp} \\
      -B ${op}:${op} \\
      -B ~/code/C-PAC/CPAC/:/code/CPAC/ \\
      -B ~/code/C-PAC/dev/docker_data/run.py:/code/CPAC/run.py \\
      -B ~/code/C-PAC/dev/docker_data/run.py:/cpac_resources/run.py \\
      -B ~/code/C-PAC/dev/docker_data/default_pipeline.yml:/cpac_resources/default_pipeline.yml \\
      --env VFC_BACKENDS_FROM_FILE=${op}/vfcbackend.txt \\
      ~/shared_data/singularity_images/fuzzy-cpac-1.8.3.sif \\
      /code/CPAC/run.py \\
      ${dp} \\
      ${op}/eval-${i}/ \\
      participant \\
      --skip_bids_validator \\
      --save_working_dir \\
      --pipeline_file ${PWD}/minimal.yml \\
      --participant_label 0050952\\
      --n_cpus 2 \\
      --mem_gb 6 \\
      --runtime_usage ${PWD}/callback.log \\
      --runtime_buffer 5

EOF

  chmod +x ${op}/eval-${i}/script.sh  
  # sbatch ${op}/eval-${i}/script.sh
  cat ${op}/eval-${i}/script.sh
  echo ${op}/eval-${i}/script.sh
done
