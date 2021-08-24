#!/usr/bin/env bash

parc=$1
bold=$2

3dROIstats -quiet -mask $parc -1Dformat $bold >> output_means.1D
~/images/afni/1dtranspose output_means.1D > output_means2.1D
mv output_means2.1D output_means.1D
python -c 'import CPAC.connectome.pipeline as cc; cc.compute_correlation("output_means.1D", "PearsonCorr")'
python -c 'import numpy as np; print(np.load("correlation_connectome.npy").shape)'
