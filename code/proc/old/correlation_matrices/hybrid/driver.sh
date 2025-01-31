#!/usr/bin/env bash

parc=$1
bold=$2
outp=$3

tmpout=/tmp/$(basename ${outp})_means.1D

3dROIstats -quiet -mask $parc -1Dformat $bold > ${tmpout}2
/jet/home/gkiar/images/afni/1dtranspose ${tmpout}2 > ${tmpout}

python -c "import CPAC.connectome.pipeline as cc; cc.compute_correlation('${tmpout}', 'PearsonCorr')"
python -c "import numpy as np; d=np.load('correlation_connectome.npy'); np.savetxt('${outp}', d)"

rm correlation_connectome.npy
