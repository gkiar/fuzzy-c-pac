#!/usr/bin/env bash

cd /data/CPAC-testing/

echo "libinterflop_ieee.so" > vfcbackend_ieee.txt

for i in `seq 1 3`;
do
  docker run --security-opt=apparmor:unconfined \
             -v ${PWD}:${PWD} \
             -e VFC_BACKENDS_FROM_FILE=${PWD}/vfcbackend_ieee.txt \
             -ti \
             gkiar/fuzzy-cpac \
               ${PWD}/NYU/ \
               ${PWD}/output_ieee_${i}/ \
               participant \
               --save_working_dir \
               --skip_bids_validator \
               --preconfig preproc \
               --n_cpus 5 \
               --mem_gb 14
done
