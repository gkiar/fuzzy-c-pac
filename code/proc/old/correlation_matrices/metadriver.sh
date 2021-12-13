#!/usr/bin/env bash
#SBATCH -N 1
#SBATCH -p RM-shared
#SBATCH -t 20:00:00
#SBATCH --ntasks-per-node=4

module load singularity

op=$1
modif=$2
config=$3 #"afni", "python" or "hybrid"

bp=/ocean/projects/cis210040p/gkiar/
sc=${bp}code/fuzzy-c-pac/code/correlation_matrices/driver.sh

cd /ocean/projects/cis210040p/gkiar/code/fuzzy-c-pac/code/correlation_matrices/

echo ${op}/vfcbackend.txt

singularity exec \
      -B ${PWD}:${PWD} \
      -B ${bp}:${bp} \
      -B ${op}:${op} \
      --env VFC_BACKENDS_FROM_FILE=${op}/vfcbackend.txt \
      ~/images/fuzzy-cpac.sif \
      ${sc} \
      ${op}/${modif} \
      ${config}
