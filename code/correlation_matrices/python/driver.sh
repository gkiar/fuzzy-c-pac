#!/usr/bin/env bash

parc=$1
bold=$2
outp=$3

sc="/ocean/projects/cis210040p/gkiar/code/fuzzy-c-pac/code/correlation_matrices/python"
python ${sc}/correlation_python_only.py ${parc} ${bold} ${outp}

