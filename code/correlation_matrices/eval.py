#!/usr/bin/env python

import numpy as np


d1 = np.loadtxt('python/result_python.txt')
d2 = np.loadtxt('afni/result_afni.txt')
d3 = np.load('hybrid/result_hybrid.npy')

for d in [d1, d2, d3]:
    np.fill_diagonal(d, 1)

print(np.mean(np.abs(d1-d2)))
print(np.mean(np.abs(d1-d3)))
print(np.mean(np.abs(d2-d3)))
