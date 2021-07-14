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


def mcacond(fname, substr='cpac_'):
    fn = op.split(substr)[1].split('/')[:2]
    if fn[0] == 'ieee':
        sp = 1
        pr = -1
    else:
        sp = float(fn[0].split('sp-')[1].split('_')[0])
        pr = int(fn[0].split('pr-')[1])
    nu = int(fn[1].split('-')[1])
    return sp, pr, nu


def difference(im1, im2, verbose=True):
    # Compare headers and affines
    headers = im1.header == im2.header
    affines = (im1.affine == im2.affine).all()
    
    # Compare images
    d1 = np.reshape(im1.get_fdata().astype(float), -1)
    d2 = np.reshape(im2.get_fdata().astype(float), -1)

    identical = np.array_equal(d1, d2)

    if not identical:
        pearson = pearsonr(d1, d2)[0]
        euc = np.linalg.norm(d1 - d2)
        mindif = np.min(np.abs(d1 - d2))
        meandif = np.mean(np.abs(d1 - d2))
        maxdif = np.max(np.abs(d1 - d2))
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
    parser.add_argument("-s", "--substr", action="store", default="cpac_mca")

    args = parser.parse_args()
    output = args.output
    image_files = args.images
    verbose = args.verbose
    substr = args.substr

    if image_files[0].endswith('.txt'):
        with open(image_files[0]) as fhandle:
            tmp = fhandle.read().split('\n')
            image_files = [t for t in tmp if len(t) > 1]

    result_dicts = []
    for _idx, _i in enumerate(image_files):
        im_i = nib.load(_i)
        for _jdx, _j in enumerate(image_files[_idx:]):

            # Get metadata: subject, spaces, simulation conditions
            id_i, id_j = subject(_i), subject(_j)
            s_i, s_j = space(_i), space(_j)
            sp_i, pr_i, n_i = mcacond(_i, substr)
            sp_j, pr_j, n_j = mcacond(_j, substr)

            # Extract simulation conditions and only compare within condition
            # Label things as w/in sub, cross sub

            # We want to compare... 
            if ((pr_i == pr_j or                     # Within precisions.... 
                 pr_i == -1 or pr_j == -1) and       #  ...Except IEEE + any
                (sp_i == sp_j or                     # Within sparsities....
                 sp_i == -1 or sp_j == -1) and       #  ...Except IEEE + any
                (id_i == id_j or                     # Within subjects...
                 (s_i == s_j and s_i != 'native'))): #  ...Except in same space
               pass
            else:
                continue

            im_j = nib.load(_j)
            if verbose:
                print("Comparing:\n\t{0}\n\t\tAND\n\t{1}".format(_i, _j))

            # If the results are in the same space, compare them
            results = difference(im_i, im_j, verbose=verbose)

            tmpdict = {
                "images": (_i, _j),
                "subjects": (id_i, id_j),
                "within subject": id_i == id_j,
                "space": s_i,
                "sparsity": sp_i,
                "precision reduction": pr_i,
                "identical header": results[0],
                "identical affine": results[1],
                "identical data": results[2],
                "pearson": results[3],
                "euc": results[4],
                "mindif": results[5],
                "meandif": results[6],
                "maxdif": results[7]
            }

            if verbose:
                print(tmpdict)

            result_dicts += [tmpdict]
            del tmpdict


    df = pd.DataFrame.from_dict(result_dicts)
    df.to_csv(output)


if __name__ == "__main__":
    main()

