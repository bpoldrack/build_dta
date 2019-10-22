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

./code/build_dta/code/routines/change-dwi-run-to-acq_fix_all.sh
datalad save -r -m "Changed the \"run\" in dwi to \"acq\""

./code/build_dta/code/procedures/fix-useless-run-values.sh
datalad save -r - "changed the filenames with wrong \"run\" in them"

# changes, that I talked about with Lya/Robert and that I have to do by hand:
git mv ./sub-DTA026/ses-T10783/fmap/sub-DTA026_ses-T10783_magnitude1.json 		./sub-DTA026/ses-T10783/fmap/sub-DTA026_ses-T10783_run-rs_magnitude1.json
git mv ./sub-DTA026/ses-T10783/fmap/sub-DTA026_ses-T10783_magnitude1.nii.gz		./sub-DTA026/ses-T10783/fmap/sub-DTA026_ses-T10783_run-rs_magnitude1.nii.gz
git mv ./sub-DTA026/ses-T10783/fmap/sub-DTA026_ses-T10783_magnitude2.json		./sub-DTA026/ses-T10783/fmap/sub-DTA026_ses-T10783_run-rs_magnitude2.json
git mv ./sub-DTA026/ses-T10783/fmap/sub-DTA026_ses-T10783_magnitude2.nii.gz		./sub-DTA026/ses-T10783/fmap/sub-DTA026_ses-T10783_run-rs_magnitude2.nii.gz
git mv ./sub-DTA026/ses-T10783/fmap/sub-DTA026_ses-T10783_phase1.json			./sub-DTA026/ses-T10783/fmap/sub-DTA026_ses-T10783_run-rs_phase1.json
git mv ./sub-DTA026/ses-T10783/fmap/sub-DTA026_ses-T10783_phase1.nii.gz			./sub-DTA026/ses-T10783/fmap/sub-DTA026_ses-T10783_run-rs_phase1.nii.gz
git mv ./sub-DTA026/ses-T10783/fmap/sub-DTA026_ses-T10783_phase2.json			./sub-DTA026/ses-T10783/fmap/sub-DTA026_ses-T10783_run-rs_phase2.json
git mv ./sub-DTA026/ses-T10783/fmap/sub-DTA026_ses-T10783_phase2.nii.gz			./sub-DTA026/ses-T10783/fmap/sub-DTA026_ses-T10783_run-rs_phase2.nii.gz
git mv ./sub-DTA026/ses-T10783/fmap/sub-DTA026_ses-T10783_run-3_phase1.json		./sub-DTA026/ses-T10783/fmap/sub-DTA026_ses-T10783_run-tb_phase1.json
git mv ./sub-DTA026/ses-T10783/fmap/sub-DTA026_ses-T10783_run-3_phase1.nii.gz		./sub-DTA026/ses-T10783/fmap/sub-DTA026_ses-T10783_run-tb_phase1.nii.gz
git mv ./sub-DTA026/ses-T10783/fmap/sub-DTA026_ses-T10783_run-3_phase2.json		./sub-DTA026/ses-T10783/fmap/sub-DTA026_ses-T10783_run-tb_phase2.json
git mv ./sub-DTA026/ses-T10783/fmap/sub-DTA026_ses-T10783_run-3_phase2.nii.gz		./sub-DTA026/ses-T10783/fmap/sub-DTA026_ses-T10783_run-tb_phase2.nii.gz
git mv ./sub-DTA026/ses-T10783/fmap/sub-DTA026_ses-T10783_run-4_magnitude1.json		./sub-DTA026/ses-T10783/fmap/sub-DTA026_ses-T10783_run-tb_magnitude1.json
git mv ./sub-DTA026/ses-T10783/fmap/sub-DTA026_ses-T10783_run-4_magnitude1.nii.gz	./sub-DTA026/ses-T10783/fmap/sub-DTA026_ses-T10783_run-tb_magnitude1.nii.gz
git mv ./sub-DTA026/ses-T10783/fmap/sub-DTA026_ses-T10783_run-4_magnitude2.json		./sub-DTA026/ses-T10783/fmap/sub-DTA026_ses-T10783_run-tb_magnitude2.json
git mv ./sub-DTA026/ses-T10783/fmap/sub-DTA026_ses-T10783_run-4_magnitude2.nii.gz	./sub-DTA026/ses-T10783/fmap/sub-DTA026_ses-T10783_run-tb_magnitude2.nii.gz

git mv ./sub-DTA143/ses-T11936/fmap/sub-DTA143_ses-T11936_magnitude1.json 		./sub-DTA143/ses-T11936/fmap/sub-DTA143_ses-T11936_run-rs_magnitude1.json
git mv ./sub-DTA143/ses-T11936/fmap/sub-DTA143_ses-T11936_magnitude1.nii.gz 		./sub-DTA143/ses-T11936/fmap/sub-DTA143_ses-T11936_run-rs_magnitude1.nii.gz
git mv ./sub-DTA143/ses-T11936/fmap/sub-DTA143_ses-T11936_magnitude2.json 		./sub-DTA143/ses-T11936/fmap/sub-DTA143_ses-T11936_run-rs_magnitude2.json
git mv ./sub-DTA143/ses-T11936/fmap/sub-DTA143_ses-T11936_magnitude2.nii.gz		./sub-DTA143/ses-T11936/fmap/sub-DTA143_ses-T11936_run-rs_magnitude2.nii.gz
git mv ./sub-DTA143/ses-T11936/fmap/sub-DTA143_ses-T11936_phase1.json			./sub-DTA143/ses-T11936/fmap/sub-DTA143_ses-T11936_run-rs_phase1.json
git mv ./sub-DTA143/ses-T11936/fmap/sub-DTA143_ses-T11936_phase1.nii.gz			./sub-DTA143/ses-T11936/fmap/sub-DTA143_ses-T11936_run-rs_phase1.nii.gz
git mv ./sub-DTA143/ses-T11936/fmap/sub-DTA143_ses-T11936_phase2.json			./sub-DTA143/ses-T11936/fmap/sub-DTA143_ses-T11936_run-rs_phase2.json
git mv ./sub-DTA143/ses-T11936/fmap/sub-DTA143_ses-T11936_phase2.nii.gz			./sub-DTA143/ses-T11936/fmap/sub-DTA143_ses-T11936_run-rs_phase2.nii.gz
git mv ./sub-DTA143/ses-T11936/fmap/sub-DTA143_ses-T11936_run-4_magnitude1.json		./sub-DTA143/ses-T11936/fmap/sub-DTA143_ses-T11936_run-tb_magnitude1.json
git mv ./sub-DTA143/ses-T11936/fmap/sub-DTA143_ses-T11936_run-4_magnitude1.nii.gz	./sub-DTA143/ses-T11936/fmap/sub-DTA143_ses-T11936_run-tb_magnitude1.nii.gz
git mv ./sub-DTA143/ses-T11936/fmap/sub-DTA143_ses-T11936_run-4_magnitude2.json		./sub-DTA143/ses-T11936/fmap/sub-DTA143_ses-T11936_run-tb_magnitude2.json
git mv ./sub-DTA143/ses-T11936/fmap/sub-DTA143_ses-T11936_run-4_magnitude2.nii.gz	./sub-DTA143/ses-T11936/fmap/sub-DTA143_ses-T11936_run-tb_magnitude2.nii.gz
git mv ./sub-DTA143/ses-T11936/fmap/sub-DTA143_ses-T11936_run-3_phase1.json		./sub-DTA143/ses-T11936/fmap/sub-DTA143_ses-T11936_run-tb_phase1.json
git mv ./sub-DTA143/ses-T11936/fmap/sub-DTA143_ses-T11936_run-3_phase1.nii.gz		./sub-DTA143/ses-T11936/fmap/sub-DTA143_ses-T11936_run-tb_phase1.nii.gz
git mv ./sub-DTA143/ses-T11936/fmap/sub-DTA143_ses-T11936_run-3_phase2.json		./sub-DTA143/ses-T11936/fmap/sub-DTA143_ses-T11936_run-tb_phase2.json
git mv ./sub-DTA143/ses-T11936/fmap/sub-DTA143_ses-T11936_run-3_phase2.nii.gz		./sub-DTA143/ses-T11936/fmap/sub-DTA143_ses-T11936_run-tb_phase2.nii.gz

git mv ./sub-DTA148/ses-T11670/fmap/sub-DTA148_ses-T11670_magnitude1.json		./sub-DTA148/ses-T11670/fmap/sub-DTA148_ses-T11670_run-rs_magnitude1.json
git mv ./sub-DTA148/ses-T11670/fmap/sub-DTA148_ses-T11670_magnitude1.nii.gz		./sub-DTA148/ses-T11670/fmap/sub-DTA148_ses-T11670_run-rs_magnitude1.nii.gz
git mv ./sub-DTA148/ses-T11670/fmap/sub-DTA148_ses-T11670_magnitude2.json		./sub-DTA148/ses-T11670/fmap/sub-DTA148_ses-T11670_run-rs_magnitude2.json
git mv ./sub-DTA148/ses-T11670/fmap/sub-DTA148_ses-T11670_magnitude2.nii.gz		./sub-DTA148/ses-T11670/fmap/sub-DTA148_ses-T11670_run-rs_magnitude2.nii.gz
git mv ./sub-DTA148/ses-T11670/fmap/sub-DTA148_ses-T11670_run-3_phase1.json		./sub-DTA148/ses-T11670/fmap/sub-DTA148_ses-T11670_run-rs_phase1.json
git mv ./sub-DTA148/ses-T11670/fmap/sub-DTA148_ses-T11670_run-3_phase1.nii.gz		./sub-DTA148/ses-T11670/fmap/sub-DTA148_ses-T11670_run-rs_phase1.nii.gz
git mv ./sub-DTA148/ses-T11670/fmap/sub-DTA148_ses-T11670_run-3_phase2.json		./sub-DTA148/ses-T11670/fmap/sub-DTA148_ses-T11670_run-rs_phase2.json
git mv ./sub-DTA148/ses-T11670/fmap/sub-DTA148_ses-T11670_run-3_phase2.nii.gz		./sub-DTA148/ses-T11670/fmap/sub-DTA148_ses-T11670_run-rs_phase2.nii.gz
git mv ./sub-DTA148/ses-T11670/fmap/sub-DTA148_ses-T11670_run-2_magnitude1.json		./sub-DTA148/ses-T11670/fmap/sub-DTA148_ses-T11670_run-tb_magnitude1.json
git mv ./sub-DTA148/ses-T11670/fmap/sub-DTA148_ses-T11670_run-2_magnitude1.nii.gz	./sub-DTA148/ses-T11670/fmap/sub-DTA148_ses-T11670_run-tb_magnitude1.nii.gz
git mv ./sub-DTA148/ses-T11670/fmap/sub-DTA148_ses-T11670_run-2_magnitude2.json		./sub-DTA148/ses-T11670/fmap/sub-DTA148_ses-T11670_run-tb_magnitude2.json
git mv ./sub-DTA148/ses-T11670/fmap/sub-DTA148_ses-T11670_run-2_magnitude2.nii.gz	./sub-DTA148/ses-T11670/fmap/sub-DTA148_ses-T11670_run-tb_magnitude2.nii.gz
git mv ./sub-DTA148/ses-T11670/fmap/sub-DTA148_ses-T11670_run-4_phase1.json		./sub-DTA148/ses-T11670/fmap/sub-DTA148_ses-T11670_run-tb_phase1.json
git mv ./sub-DTA148/ses-T11670/fmap/sub-DTA148_ses-T11670_run-4_phase1.nii.gz	./sub-DTA148/ses-T11670/fmap/sub-DTA148_ses-T11670_run-tb_phase1.nii.gz
git mv ./sub-DTA148/ses-T11670/fmap/sub-DTA148_ses-T11670_run-4_phase2.json	./sub-DTA148/ses-T11670/fmap/sub-DTA148_ses-T11670_run-tb_phase2.json
git mv ./sub-DTA148/ses-T11670/fmap/sub-DTA148_ses-T11670_run-4_phase2.nii.gz	./sub-DTA148/ses-T11670/fmap/sub-DTA148_ses-T11670_run-tb_phase2.nii.gz


datalad save -r -m "Changed fieldmap-names for the exception cases."
