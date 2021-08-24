#!/usr/bin/env bash

parc=$1
bold=$2
outp=$3

tmpout=/tmp/$(basename ${outp})
~/images/afni/3dNetCorr -inset $bold -in_rois $parc -prefix ${tmpout}

tail -n +7 ${tmpout}_000.netcc > ${outp}
