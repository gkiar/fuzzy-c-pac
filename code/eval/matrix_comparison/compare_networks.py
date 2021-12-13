#!/usr/bin/env python

from argparse import ArgumentParser
import os.path as op
import os

from scipy.stats import pearsonr
import pandas as pd
import numpy as np


def pairwise_eval(df):
    inds = list(df.index)

    pmat = np.zeros((len(inds), len(inds)))

    for i, ind1 in enumerate(inds):
        for j, ind2 in enumerate(inds[i:]):
            m1 = df.loc[ind1].mat.flatten()
            m2 = df.loc[ind2].mat.flatten()
            try:
                print(len(m1), len(m2))
                pmat[i, j] = pearsonr(m1, m2)[0]
            except ValueError:
                print(df.loc[ind1])
                print(df.loc[ind2])
                import pdb; pdb.set_trace()
                raise(ValueError)

    return pmat


def main():
    parser = ArgumentParser()
    parser.add_argument("dataframe")

    results = parser.parse_args()
    df = pd.read_pickle(results.dataframe)
    dirname = op.dirname(results.dataframe)

    subs = list(df.subject.unique())
    for sub in subs:
        print(sub)
        df_sub = df.query("subject == '{0}'".format(sub)).reset_index()
        pmat = pairwise_eval(df_sub)
        fname = op.join(dirname, "sub-{0}.mat".format(sub))
        np.savetxt(fname, pmat)


if __name__ == "__main__":
    main()

