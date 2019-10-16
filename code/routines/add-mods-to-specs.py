#!/usr/bin/env python

def add_name_fixing(path):
    import datalad.support.json_py as json_py

    spec = [r for r in json_py.load_stream(path)]

    # Note: We append the procedure to dicomseries:all, since we do not
    # technically act upon a particular series. This is because the procedure
    # concerns the outcome of the conversion, not the raw data. The file
    # selection has to be done within the procedure and can't be controlled by
    # the spec or hirni-spec2bids ATM.
    for snippet in spec:
        if snippet['type'] == 'dicomseries:all':
            snippet['procedures'].append(
                {
                    'procedure-name': {'value': 'change-dwi-run-to-acq_fix_all',
                                       'approved': True},
                    'on-anonymize': {'value': False,
                                     'approved': True}
                }
            )
	    snippet['procedures'].append(
                {
                    'procedure-name': {'value': 'fieldmaps-to-phase-or-magnitude_fix_all',
                                       'approved': True},
                    'on-anonymize': {'value': False,
                                     'approved': True}
                }
            )

    json_py.dump2stream(spec, path)


if __name__ == '__main__':
    import sys
    import posixpath
    spec_path = sys.argv[1]
    if not posixpath.exists(spec_path):
        raise RuntimeError("spec file does not exist: %s" % spec_path)

    add_name_fixing(spec_path)

