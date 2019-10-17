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
datalad save -m "changed the hirni rules specification file"

# hirni-import-dcm (but with reduced number of input tars)
# maybe just one line, if install also saves. TODO
datalad install -d . -s git@github.com:TobiasKadelka/DTA_data.git sourcedata --recursive --nosave
datalad save sourcedata -m "installed the sourcedata that has to be converted into a bids-dataset"

./code/build_dta/code/routines/hirni-import-dcm.sh sourcedata

# add procedures for correcting names to the studyspec.json
#for d in ./T* ; do
#	code/build_dta/code/routines/add-mods-to-specs.py $d/studyspec.json
#done
#datalad save -m "added modifications to studyspec.json files"

datalad hirni-spec2bids */studyspec.json

# FIRST this. then the rest.
code/build_dta/code/procedures/fieldmaps-to-phase-or-magnitude_fix_all.sh

# for generating the ( TODO: git mv ) mv commands for ordering magnitude/phase 1/2
python code/build_dta/code/routines/order-magnitude-and-phase_fix_all.py /data/BnB_USER/Kadelka/DTA_study/ > code/build_dta/code/routines/order-magnitude-and-phase.sh
chmod 775 code/build_dta/code/routines/order-magnitude-and-phase.sh
./code/build_dta/code/routines/order-magnitude-and-phase.sh
datalad save -r -m "fixing fieldmaps."

python code/build_dta/code/create/check_dimensions.py ./ | grep rm > code/build_dta/code/routines/remove_stopped_tasks.sh
chmod 775 code/build_dta/code/routines/remove_stopped_tasks.sh
./code/build_dta/code/routines/remove_stopped_tasks.sh
datalad save -r -m "Removed the tasks, that where stopped while scanning."

./code/build_dta/code/procedures/fix-useless-run-values.sh

