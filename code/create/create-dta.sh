#!/usr/bin/env bash

# First argument: Path to install the DTA_study data
# This Script creates the complete BIDS-dataset for the DTA-study.

# create a dataset and go into that Folder.
datalad create -c hirni $1/DTA_study
cd $1/DTA_study

# installing the necessary code into the dataset ( the build_dta )
datalad install -d . -s git@github.com:bpoldrack/build_dta.git code/build_dta
datalad save code -m "installed the code for creating the DTA-dataset as a bids-dataset."

# modify the rules for the spec, so the dta-rules will be used
git config -f .datalad/config --add datalad.hirni.dicom2spec.rules ./code/build_dta/code/create/dta_dicom2spec_rules.py
datalad save -m "changed the hirni rules specification file to the one for DTA"

# hirni-import-dcm
# TODO: maybe just one line, if install also saves
datalad install -d . -s git@github.com:TobiasKadelka/DTA_data.git sourcedata --recursive --nosave
datalad save sourcedata -m "installed the sourcedata that has to be converted into a bids-dataset"

# Importing the dicoms and create the bids-data based on their studyspec.jsons
./code/build_dta/code/routines/hirni-import-dcm.sh sourcedata
datalad hirni-spec2bids */studyspec.json


# Changing the fieldmap filenames to magnitude1/2 or phase1/2, then sorting them by time
./code/build_dta/code/procedures/fieldmaps-to-phase-or-magnitude_fix_all.sh
python code/build_dta/code/routines/order-magnitude-and-phase_fix_all.py ./ > code/build_dta/code/routines/order-magnitude-and-phase.sh
chmod 775 code/build_dta/code/routines/order-magnitude-and-phase.sh
./code/build_dta/code/routines/order-magnitude-and-phase.sh
datalad save -r -m "fixing fieldmap filenames and order."

# sometimes while scanning, something happens and they start a scan again from the beginning.
# That creates additional runs, that need to be removed depending on the number of their scans.
python code/build_dta/code/create/check_dimensions.py ./ | grep rm > code/build_dta/code/routines/remove_stopped_tasks.sh
chmod 775 code/build_dta/code/routines/remove_stopped_tasks.sh
./code/build_dta/code/routines/remove_stopped_tasks.sh
datalad save -r -m "Removed the tasks, that where stopped while scanning."

# dwi-files had run-120dir in their names, that needs to be an acq-120dir. (or 60dir)
./code/build_dta/code/routines/change-dwi-run-to-acq_fix_all.sh
datalad save -r -m "Changed the \"run\" in dwi to \"acq\""

# other files should not have a "run-..." in their name. Exceptions will happen in the end of this script.
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
# Changes for the second subject.
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
# Changes for third subject.
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
git mv ./sub-DTA148/ses-T11670/fmap/sub-DTA148_ses-T11670_run-4_phase1.nii.gz		./sub-DTA148/ses-T11670/fmap/sub-DTA148_ses-T11670_run-tb_phase1.nii.gz
git mv ./sub-DTA148/ses-T11670/fmap/sub-DTA148_ses-T11670_run-4_phase2.json		./sub-DTA148/ses-T11670/fmap/sub-DTA148_ses-T11670_run-tb_phase2.json
git mv ./sub-DTA148/ses-T11670/fmap/sub-DTA148_ses-T11670_run-4_phase2.nii.gz		./sub-DTA148/ses-T11670/fmap/sub-DTA148_ses-T11670_run-tb_phase2.nii.gz
# Changes for fourth subject. (delete second set of fmaps)
git rm ./sub-DTA088/ses-T11041/fmap/sub-DTA088_ses-T11041_run-2_magnitude1.json
git rm ./sub-DTA088/ses-T11041/fmap/sub-DTA088_ses-T11041_run-2_magnitude1.nii.gz
git rm ./sub-DTA088/ses-T11041/fmap/sub-DTA088_ses-T11041_run-2_magnitude2.json
git rm ./sub-DTA088/ses-T11041/fmap/sub-DTA088_ses-T11041_run-2_magnitude2.nii.gz
git rm ./sub-DTA088/ses-T11041/fmap/sub-DTA088_ses-T11041_run-4_phase1.json
git rm ./sub-DTA088/ses-T11041/fmap/sub-DTA088_ses-T11041_run-4_phase1.nii.gz
git rm ./sub-DTA088/ses-T11041/fmap/sub-DTA088_ses-T11041_run-4_phase2.json
git rm ./sub-DTA088/ses-T11041/fmap/sub-DTA088_ses-T11041_run-4_phase2.nii.gz
datalad save -r -m "Changed fieldmaps for the exception cases."

# Subject DTA061 were missing in the table for the subject-values for the T-numbers. This block moves the files manually, so they are in the right subject/session-folder.
git mv ./sub-None/ses-T11776/dwi/sub-None_ses-T11776_run-120dir_dwi.bval		sub-DTA061/ses-T11485/dwi/sub-DTA061_ses-T11485_acq-120dir_dwi.bval
git mv ./sub-None/ses-T11776/dwi/sub-None_ses-T11776_run-120dir_dwi.bvec		sub-DTA061/ses-T11485/dwi/sub-DTA061_ses-T11485_acq-120dir_dwi.bvec
git mv ./sub-None/ses-T11776/dwi/sub-None_ses-T11776_run-120dir_dwi.json		sub-DTA061/ses-T11485/dwi/sub-DTA061_ses-T11485_acq-120dir_dwi.json
git mv ./sub-None/ses-T11776/dwi/sub-None_ses-T11776_run-120dir_dwi.nii.gz		sub-DTA061/ses-T11485/dwi/sub-DTA061_ses-T11485_acq-120dir_dwi.nii.gz
rm -rdf sub-None
datalad save -r -m "The files from sub-None belong to sub-DTA061/sesT11485 - manually added."

git rm ./sub-DTA143/ses-T11936/func/*run-7*
git rm ./sub-DTA070/ses-T11486/func/sub-DTA070_ses-T11486_task-exp2_run-2_events.tsv
git rm ./sub-DTA073/ses-T11528/func/sub-DTA073_ses-T11528_task-exp2_run-2_events.tsv

# TODO: drop all sourcedata and code and so on.
