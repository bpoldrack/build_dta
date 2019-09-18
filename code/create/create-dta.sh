#!/usr/bin/env bash

# First argument: Path to install the DTA_study data
# Second argument: which sourcedata to use
# Example-call for installing DTA_sourcedata_reduced:
# >> ./create_BIDS_DTA.sh . /data/BnB_TEMP/Kadelka/DTA_sourcedata_reduced/

# create a dataset
datalad create -c hirni $1
cd $1

# installing the necessary code into the dataset
datalad install -d . -s git@github.com:TobiasKadelka/build_dta.git code/build_dta

# modify the rules for the spec, so the dta-rules will be used
git config -f .datalad/config --add datalad.hirni.dicom2spec.rules code/build_dta/code/create/dta_dicom2spec_rules.py
# Ben: TODO: git-config modifies .datalad/config here. So you want to call datalad-save afterwards

# configuring the .datalad/config, so it knows where to find the procedure for renaming the fieldmaps
# git config -f .datalad/config --add datalad.locations.dataset-procedures code/build_dta/code/procedures
# Ben: TODO: This is a configuration that belongs to the dataset containing that procedure. You can either make
#      build_dta a datalad dataset and have that config in it (therefore no need for a config call to show up anywhere
#      in the scripts) or you copy the procedures directory into actual DTA dataset (code/procedures for example) and
#      adjust that git-config call accordingly.
#      If you go for the latter you can call the above mentioned datalad-save afterwards, of course and include both
#      config changes in that one commit.

# THIS IS NOT NECESSARY, WHEN FILES ARE ALREADY IN TARS ON CLUSTER
# get the source_data for DTA1
# ./code/tmp/tar-DTA1_output.sh
# source_data for DTA2
# ./code/tmp/tar-DTA2_output.sh
# Ben: TODO: The outcommented block above seems outdated, since at this point those paths don't exist (code/tmp/..).
#      Adjust or delete that block. Remember: Two years from now, there might be a need to figure out, what exactly was
#      going on. Even if outcommented, invalid left-overs can only cause confusion then.

# hirni-import-dcm (but with reduced number of input tars)
datalad install -d . -s git@github.com:TobiasKadelka/DTA_data.git DTA_data --recursive
./code/build_dta/code/routines/hirni-import-dcm.sh DTA_data
# Ben: That DTA_data is an unusual approach, but certainly a way to do it. I guess, I like it. ;-)

# TODO : everything from here

# dicom2spec will be called by hirni-import-dcm anyways.
# ./code/build_dta/code/scripts/run_dicom2spec.sh

# add procedures for correcting names to the studyspec.json
# Ben: TODO: add-mods-to-specs.py actually isn't a procedure in the sense of a datalad-procedure. So it should move to
#      routines/ or somewhere else. Otherwise it will be discovered by datalad run-procedure and can lead to confusion.
for d in ./T* ; do
	code/build_dta/code/procedures/add-mods-to-specs.py $d/studyspec.json
done

######### don't spec2bids here, but use this as the source for another dataset. (siehe demo von ben)

# hirni-spec2bids
# chmod 775 code/build_dta/code/scripts/run_spec2bids.sh
# ./code/build_dta/code/scripts/run_spec2bids.sh

# drei demo-befehle testen
