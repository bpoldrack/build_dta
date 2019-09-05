for d in /data/BnB_USER/Kadelka/SOURCEDATA/* ; do
        for b in $d/* ; do
                echo $b
                datalad hirni-import-dcm $b
        done
done
