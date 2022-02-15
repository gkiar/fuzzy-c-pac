#!/usr/bin/env bash

cd /data/CPAC-testing/

# echo "libinterflop_ieee.so"
echo "libinterflop_mca.so -m mca --sparsity=0.1" > vfcbackend.txt

for i in `seq 0 9`;
do
  docker run --security-opt=apparmor:unconfined \
             -v ${PWD}:${PWD} \
             -e VFC_BACKENDS_FROM_FILE=${PWD}/vfcbackend.txt \
             -ti \
             gkiar/fuzzy-cpac \
               ${PWD}/NYU/ \
               ${PWD}/output_mca_0.1_${i}/ \
               participant \
               --save_working_dir \
               --skip_bids_validator \
               --preconfig preproc \
               --n_cpus 5 \
               --mem_gb 14

done
