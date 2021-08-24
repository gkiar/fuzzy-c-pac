#!/usr/bin/env python

from argparse import ArgumentParser

from nilearn.input_data import NiftiLabelsMasker
from nilearn.connectome import ConnectivityMeasure
from nilearn import plotting

import numpy as np


def main():
    parser = ArgumentParser()
    parser.add_argument("mask")
    parser.add_argument("timeseries")
    parser.add_argument("output")

    args = parser.parse_args()

    masker = NiftiLabelsMasker(labels_img=args.mask, standardize=True,
                               verbose=True)

    timeser = masker.fit_transform(args.timeseries)
    correlation_measure = ConnectivityMeasure(kind='correlation')
    corr_matrix = correlation_measure.fit_transform([timeser])[0]
    np.fill_diagonal(corr_matrix, 0)

    plotting.plot_matrix(corr_matrix)
    np.savetxt(args.output, corr_matrix)


if __name__ == "__main__":
    main()

