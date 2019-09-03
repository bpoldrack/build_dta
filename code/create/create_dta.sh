
# create a dataset
mkdir DTA
cd DTA
datalad create --force
datalad run-procedure cfg_hirni

# installing the necessary code into the dataset
datalad install -d . -s git@github.com:TobiasKadelka/build_dta.git code/build_dta

# modify the rules for the spec, so the dta-rules will be used
echo '[datalad "hirni.dicom2spec"]' >> .datalad/config
echo '  rules = code/build_dta/code/create/dta_dicom2spec_rules.py' >> .datalad/config

# get the source_data for DTA1
mkdir -p code/tmp/
python code/build_dta/code/scripts/tar_DTA1.py $(pwd) > code/tmp/tar_DTA1.sh
chmod 775 code/tmp/tar_DTA1.sh
./code/tmp/tar_DTA1.sh

# source_data for DTA2
python code/build_dta/code/scripts/tar_DTA2.py $(pwd) > code/tmp/tar_DTA2.sh
chmod 775 code/tmp/tar_DTA2.sh
./code/tmp/tar_DTA2.sh

# hirni-import-dcm
chmod 775 ./code/build_dta/code/scripts/hirni-import-dcm.sh
./code/build_dta/code/scripts/hirni-import-dcm.sh

# hirni-dicom2spec
chmod 775 code/build_dta/code/scripts/run_dicom2spec.sh
./code/build_dta/code/scripts/run_dicom2spec.sh

# hirni-spec2bids
chmod 775 code/build_dta/code/scripts/run_spec2bids.sh
./code/build_dta/code/scripts/run_spec2bids.sh
