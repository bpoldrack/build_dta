#!/usr/bin/env bash

# First argument: Path to install the DTA_study data

# create a dataset
datalad create -c hirni $1/DTA_study
cd $1/DTA_study

# installing the necessary code into the dataset
#datalad install -d . -s git@github.com:TobiasKadelka/build_dta.git code/build_dta
# TODO: erase the next line, use the one before this.
datalad install -d . -s git@github.com:bpoldrack/build_dta.git code/build_dta

# modify the rules for the spec, so the dta-rules will be used
git config -f .datalad/config --add datalad.hirni.dicom2spec.rules code/build_dta/code/create/dta_dicom2spec_rules.py
datalad save

# hirni-import-dcm (but with reduced number of input tars)
datalad install -d . -s git@github.com:TobiasKadelka/DTA_data.git sourcedata --recursive
datalad save
./code/build_dta/code/routines/hirni-import-dcm.sh sourcedata

# add procedures for correcting names to the studyspec.json
for d in ./T* ; do
	code/build_dta/code/routines/add-mods-to-specs.py $d/studyspec.json
done
datalad save

# TODO: test the 3 lines from benjamins demo for really installing this as a dataset.

