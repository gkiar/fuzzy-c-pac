#!/bin/bash
#SBATCH -p RM-shared
#SBATCH -t 10:00:00
#SBATCH --ntasks-per-node=2
#SBATCH -N 1

source ~/env/gp38/bin/activate

time python /jet/home/gkiar/code/fuzzy-c-pac/compare_images.py \
     clean1_results.csv \
     /jet/home/gkiar/data/ABIDE_NYU/clean1.txt -v
