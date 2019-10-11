 #!/usr/bin/env bash 

# this script imports the tars from a given sourcedata-directory.
for d in $1/*/* ; do
                datalad hirni-import-dcm $d
done

