
# create a dataset
mkdir DTA
cd DTA
datalad create --force
datalad run-procedure cfg_hirni

# installing the necessary code into the dataset
datalad install -d . -s git@github.com:TobiasKadelka/build_dta.git code/build_dta

# get the source_data
mkdir -p code/tmp/
python code/build_dta/code/scripts/tar_DTA1.py $(pwd) > code/tmp/tar_DTA1.sh
