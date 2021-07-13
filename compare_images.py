#!/usr/bin/env python

from argparse import ArgumentParser
from itertools import combinations
from scipy.stats import pearsonr
import nibabel as nib
import pandas as pd
import numpy as np

import os.path as op
import os


def subject(fname):
    fn = op.basename(fname).split('_')[0].split('-')[1]
    return fn


def space(fname):
    fn = op.basename(fname).split('run-1')[1].split('desc-')[0].strip('_')
    if fn.startswith('space-'):
        return fn[6:]
    else:
        return 'native'


def difference(im1, im2, verbose=True):
    # Compare headers and affines
    headers = im1.header == im2.header
    affines = (im1.affine == im2.affine).all()
    
    if verbose:
        print("\t Metadata & affine match: {0}".format(affines and headers))

    # Compare images
    d1 = np.reshape(im1.get_fdata().astype(float), -1)
    d2 = np.reshape(im2.get_fdata().astype(float), -1)

    identical = np.array_equal(d1, d2)
    if verbose:
        print("\t Data match: {0}".format(identical))

    if not identical:
        pearson = pearsonr(d1, d2)[0]
        euc = np.linalg.norm(d1 - d2)
        mindif = np.min(np.abs(d1 - d2))
        meandif = np.mean(np.abs(d1 - d2))
        maxdif = np.max(np.abs(d1 - d2))
        
        if verbose:
            print("\t Correlation: {0:.4f}".format(pearsonr(d1, d2)[0]))
            print("\t Diff. Norm: {0:.2f}".format(np.linalg.norm(d1 - d2)))
            print("\t Min Diff.: {0:.2e}".format(np.min(np.abs(d1 - d2))))
            print("\t Mean Diff.: {0:.2e}".format(np.mean(np.abs(d1 - d2))))
            print("\t Max Diff.: {0:.2e}".format(np.max(np.abs(d1 - d2))))
    else:
        pearson = 1
        euc = 0
        mindif = 0
        meandif = 0
        maxdif = 0

    return [headers, affines, identical, pearson,
            euc, mindif, meandif, maxdif]


def main():
    parser = ArgumentParser()
    parser.add_argument("output")
    parser.add_argument("images", nargs="+")
    parser.add_argument("-v", "--verbose", action="store_true")

    args = parser.parse_args()
    output = args.output
    image_files = args.images
    verbose = args.verbose

    if image_files[0].endswith('.txt'):
        with open(image_files[0]) as fhandle:
            tmp = fhandle.read().split('\n')
            image_files = [t for t in tmp if len(t) > 1]

    result_dicts = []
    for _i in image_files:
        im_i = nib.load(_i)
        for _j in image_files: 
            # Compare spaces
            id_i, id_j = subject(_i), subject(_j)
            s_i, s_j = space(_i), space(_j)

            # Extract simulation conditions and only compare within condition
            # Label things as w/in sub, cross sub

            # Skip dis-similar images
            if s_i != s_j or (s_i == 'native' and id_i != id_j):
                continue

            im_j = nib.load(_j)
            if verbose:
                print("Comparing:\n\t{0}\n\t\tAND\n\t{1}".format(_i, _j))

            # If the results are in the same space, compare them
            results = difference(im_i, im_j, verbose=verbose)

            tmpdict = {
                "im1": _i,
                "im2": _j,
                "headers": results[0],
                "affine": results[1],
                "identical": results[2],
                "pearson": results[3],
                "euc": results[4],
                "mindif": results[5],
                "meandif": results[6],
                "maxdif": results[7]
            }
            result_dicts += [tmpdict]
            del tmpdict


    df = pd.DataFrame.from_dict(result_dicts)
    df.to_csv(output)


if __name__ == "__main__":
    main()

