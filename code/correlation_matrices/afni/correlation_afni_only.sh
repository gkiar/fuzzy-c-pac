#!/usr/bin/env bash

parc=$1
bold=$2

~/images/afni/3dNetCorr -inset $bold -in_rois $parc -prefix result_afni.txt

mv result_afni.txt_000.netcc result_afni.txt
rm result_afni.txt_000*

tail -n +7 result_afni.txt > result_afni2.txt
mv result_afni2.txt result_afni.txt
