#!/usr/bin/env python

from argparse import ArgumentParser
from itertools import combinations
from scipy.stats import pearsonr
import nibabel as nib
import numpy as np


def main():
    parser = ArgumentParser()
    parser.add_argument("images", nargs="+")

    image_files = parser.parse_args().images

    # Load images
    ims = {}

    # Create a couple of LUTs, to make life easier
    lut = {}
    tul = {}
    for i, _im in enumerate(image_files):
        print("Loading {0}... ({1})".format(i, _im))
        ims[_im] = nib.load(_im)
        lut[_im] = i
        tul[i] = _im

    for _i, _j in combinations(ims, 2):
        print("{0} vs. {1}".format(lut[_i], lut[_j]))
        im_i = ims[_i]
        im_j = ims[_j]

        # Compare headers and affines
        headers = im_i.header == im_j.header
        affines = (im_i.affine == im_j.affine).all()
        print("\t Metadata & affine match: {0}".format(affines and headers))

        # Compare images
        d_i = np.reshape(im_i.get_fdata().astype(float), -1)
        d_j = np.reshape(im_j.get_fdata().astype(float), -1)

        identical = np.array_equal(d_i, d_j)
        print("\t Data match: {0}".format(identical))
        if not identical:
            print("\t Correlation: {0:.4f}".format(pearsonr(d_i, d_j)[0]))
            print("\t Diff. Norm: {0:.2f}".format(np.linalg.norm(d_i - d_j)))
            print("\t Min Diff.: {0:.2e}".format(np.min(np.abs(d_i - d_j))))
            print("\t Mean Diff.: {0:.2e}".format(np.mean(np.abs(d_i - d_j))))
            print("\t Max Diff.: {0:.2e}".format(np.max(np.abs(d_i - d_j))))


if __name__ == "__main__":
    main()
