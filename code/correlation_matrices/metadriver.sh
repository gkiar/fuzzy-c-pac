#!/usr/bin/env bash
# #SBATCH -N 1
# #SBATCH -p RM-shared
# #SBATCH -t 20:00:00
# #SBATCH --ntasks-per-node=2

module load singularity

op=$1
modif=$2

bp=/ocean/projects/cis210040p/gkiar/
sc=${bp}code/fuzzy-c-pac/code/correlation_matrices/driver.sh

cd /ocean/projects/cis210040p/gkiar/code/fuzzy-c-pac/code/correlation_matrices/

singularity exec \
      -B ${PWD}:${PWD} \
      -B ${bp}:${bp} \
      -B ${op}:${op} \
      --env VFC_BACKENDS_FROM_FILE=${op}/vfcbackend.txt \
      ~/images/fuzzy-cpac.sif \
      ${sc} \
      ${op}/${modif}
