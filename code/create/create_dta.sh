
# create a dataset
mkdir DTA
cd DTA
datalad create --force
datalad run-procedure cfg_hirni

# get the source_data
# hier bin ich im falschen (neuen) Directory, deshalb kann der auf die Pfade nicht zugreifen.
python code/scripts/tar_DTA1.py > ../tmp/tar_DTA1.sh
