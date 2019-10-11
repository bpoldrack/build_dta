#!/usr/bin/env bash

# First argument: Path to install the DTA_study data

# create a dataset
datalad create -c hirni $1
cd $1

# installing the necessary code into the dataset
datalad install -d . -s git@github.com:TobiasKadelka/build_dta.git code/build_dta

# modify the rules for the spec, so the dta-rules will be used
git config -f .datalad/config --add datalad.hirni.dicom2spec.rules code/build_dta/code/create/dta_dicom2spec_rules.py
datalad save

# hirni-import-dcm (but with reduced number of input tars)
datalad install -d . -s git@github.com:TobiasKadelka/DTA_data.git DTA_data --recursive
./code/build_dta/code/routines/hirni-import-dcm.sh DTA_data

# add procedures for correcting names to the studyspec.json
for d in ./T* ; do
	code/build_dta/code/procedures/add-mods-to-specs.py $d/studyspec.json
done
datalad save

# test the 3 lines from benjamins demo for really installing this as a dataset.

