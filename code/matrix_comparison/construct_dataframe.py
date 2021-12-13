#!/usr/bin/env python

from argparse import ArgumentParser
import os.path as op
import sys
import os

import pandas as pd
import numpy as np


def get_fnames(file_list, num_rois):
    with open(file_list) as fhandle:
        flist = fhandle.readlines()
    flist = [f.strip() for f in flist if str(num_rois) in f]
    return flist


def extract_info(fname, basedir=""):
    fname = op.relpath(fname, basedir) 
    
    sub = op.basename(fname).split('_')[0].split('-')[1]
    ses = op.basename(fname).split('_')[1].split('-')[1]

    mode = fname.split('/')[1].split('_')[1]
    run = fname.split('/')[2].strip('eval-')
    if mode == "mca":
        sp = fname.split('/')[1].split('_')[2].split('-')[1]
        pr = fname.split('/')[1].split('_')[3].split('-')[1]
    else:
        sp = 1
        pr = 0

    tool = op.splitext(op.basename(fname).split('_')[-1].split('-')[1])[0]

    return sub, ses, mode, sp, pr, run, tool


def create_df(fnames, num_rois):
    df_list = []
    basedir = op.commonprefix(fnames)
    for f in fnames:
        try:
            mat = np.loadtxt(f)
            sub, ses, mode, sp, pr, run, tool = extract_info(f, basedir)
            tmp_dict = {
                "subject": sub,
                "session": ses,
                "rois": num_rois,
                "corr_method": tool,
                "mode": mode,
                "evaluation_id": run,
                "sparsity": sp,
                "precision_reduction": pr,
                "mat": mat 
            }
            
            assert(mat.shape[0] == num_rois)

            df_list += [tmp_dict]
            del tmp_dict

        except OSError as e:
            continue

        except AssertionError as e:
            print(f, tmp_dict)
            import pdb; pdb.set_trace()

    print(df_list[-1])
    df = pd.DataFrame.from_dict(df_list)
    return df


def main():
    parser = ArgumentParser()
    parser.add_argument("file_list")
    parser.add_argument("num_rois", choices=[200, 600, 1000], type=int)
    parser.add_argument("outpath")

    results = parser.parse_args()
    fnames = get_fnames(results.file_list, results.num_rois)
    df = create_df(fnames, results.num_rois)

    df.to_pickle(results.outpath)


if __name__ == "__main__":
    main()

