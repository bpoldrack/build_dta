# create a dataset
datalad create -c hirni DTA
cd DTA

# installing the necessary code into the dataset
datalad install -d . -s git@github.com:TobiasKadelka/build_dta.git code/build_dta

# modify the rules for the spec, so the dta-rules will be used
git config --file .datalad/config --add datalad.hirni.dicom2spec.rules code/build_dta/code/create/dta_dicom2spec_rules.py

# configuring the .datalad/config, so it knows where to find the procedure for renaming the fieldmaps
git config --file .datalad/config --add datalad.procedures.fix-fieldmaps-names.call-format bash {script} {ds} {{bids-subject}}
git config --file .datalad/config --add datalad.locations.dataset-procedures code/build_dta/code/procedures


# get the source_data for DTA1 # TODO: put tars into separate folder outside of dataset
#mkdir -p code/tmp/
#python code/build_dta/code/scripts/tar_DTA1.py $(pwd) > code/tmp/tar_DTA1.sh # relative paths in tar_DTA.sh-scripts
#chmod 775 code/tmp/tar_DTA1.sh
# here the tar commands are happening ( one tar per acquisition -> session with T1, task-rest, etc)
#./code/tmp/tar_DTA1.sh

# source_data for DTA2
#python code/build_dta/code/scripts/tar_DTA2.py $(pwd) > code/tmp/tar_DTA2.sh
#chmod 775 code/tmp/tar_DTA2.sh
#./code/tmp/tar_DTA2.sh

# hirni-import-dcm
#chmod 775 ./code/build_dta/code/scripts/hirni-import-dcm.sh
#./code/build_dta/code/scripts/hirni-import-dcm.sh
./code/build_dta/code/scripts/hirni-import-dcm_reduced.sh

# hirni-dicom2spec # hirni-import macht das eh, im Buildscript weg, code daneben in einen Ordner legen
#chmod 775 code/build_dta/code/scripts/run_dicom2spec.sh
#./code/build_dta/code/scripts/run_dicom2spec.sh

# add procedures for correcting names to the studyspec.json
for d in ./T* ; do
	code/build_dta/code/scripts/rename_fieldmaps.py $d/studyspec.json
done

######### don't spec2bids here, but use this as the source for another dataset. (siehe demo von ben)

# hirni-spec2bids
#chmod 775 code/build_dta/code/scripts/run_spec2bids.sh
#./code/build_dta/code/scripts/run_spec2bids.sh

# drei demo-befehle testen

