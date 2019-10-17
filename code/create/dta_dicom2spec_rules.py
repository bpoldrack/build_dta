# rules for converting the dta-dicoms into a bids-dataset.
from datalad_hirni.support.BIDS_helper import apply_bids_label_restrictions


def _guess_modality(record, dcm_dict):

    # not sure, if the strings in the dcm-headers are always consistent,
    # so we just ignore the capital-letters.
    protocol = record.get("ProtocolName", None).lower()
    if protocol:

        if "dti_"   in protocol:
            return "dwi"
        if "60dir"  in protocol:
            return "dwi"
        if "120dir" in protocol:
            return "dwi"
        if "field map" in protocol:
            return "fieldmap"

        import re
        prot_parts = re.split('_|-|\s', protocol)

        # this is a bad protocol name, but it is a resting state scan for pmu_rest and a task-bold if bold_task
        if ("dta_epi_pmu_rest" == protocol) or ("DTA_ep2d_bold_Task".lower() == protocol):
               return "bold"

        image_type = record.get("ImageType", None)
        if image_type and "fieldmap" in protocol:
                return "fieldmap"

	# this list should try to just contain values that might appear in the DTA-dataset.
	# TODO: magnitude/phase does not appear in the dcm-headers, just fieldmap, and we correct it later?
        direct_search_terms = ["t1", "t1w", "dwi", "phasediff", "phase1", "phase2", "magnitude1", "magnitude2", "fieldmap"]

        for m in direct_search_terms:
            if m in prot_parts:
                return m
            if "mprage" in prot_parts:
                return "t1w"
    return None


def get_column( t_value ):
     table_path = "/data/BnB1/DATA/source_data/DTA/code/dtage.tsv"
     with open( table_path, 'r' ) as table:
        for line in table:
           for part in line.split("\t"):
              if t_value in part:
                 return str(line.split("\t").index(part))
     return None


def _guess_task(dcm_dict, record):

    protocol = record.get("ProtocolName", None).lower()

    # TODO: do I really need/use this values?
    count_if_same_protocol_but_scanned_earlier = 1
    exp_flag = False

    # check if protocol is unequal to None
    if protocol:
        if protocol == "dta_epi_pmu_rest":
               return "rest"
        if protocol == "dta_ep2d_bold_task":
            return ( "exp" + get_column( record.get("PatientID") ) )

        if "60dir" in protocol:
            return "60dir"
        if "120dir" in protocol:
            return "120dir"

        import re
        prot_parts = re.split('_|-|\s', protocol)

	# TODO: is this try/except-block helpful for DTA or just for forrest?
        try:
            idx = prot_parts.index("task")
            task = prot_parts[idx + 1]
            return task
        except (ValueError, IndexError):
            return None
    return None



def _guess_run(dcm_dict, record):

        # maybe this function can be deleted, I think there are no runs at all in DTA.
#        return None
	# now I don't think that anymore. Seemed to be important.

	# start with 1.
        run = 1
        protocol = record.get("ProtocolName")

#        # the bold-tasks don't have runs.
#        if "DTA_ep2d_bold_Task".lower() in protocol.lower():
#              return "1"
#       if "DTA_epi_pmu_rest".lower() in protocol.lower():
#            return "1"

	# I return 60dir as a run, because it is easy
	# to change that later to acq-60dir
        if "60dir".lower() in protocol.lower():
            return "60dir"
        if "120dir".lower() in protocol.lower():
            return "120dir"

	# TODO: here's something wrong, so change that.
        if protocol:
            for elem in dcm_dict._dicom_series:
                if protocol in str(elem):
                    if str(record) == str(elem):
                       return str(run)
                    run = run + 1
            return str(run)
        # default to None will lead to counting series with same protocol
        return None


# TODO: probably I could clean a few things in this class.
class dta_DICOM2SpecRules(object):

    def __init__(self, dicommetadata):
        """

        Parameter
        ----------
        dicommetadata: list of dict
            dicom metadata as extracted by datalad; one dict per image series
        """
        self._dicom_series = dicommetadata

    def __call__(self, subject=None, anon_subject=None, session=None):
        """

        Parameters
        ----------

        Returns
        -------
        list of tuple (dict, bool)
        """
        spec_dicts = []
        for dicom_dict in self._dicom_series:
            spec_dicts.append((self._rules(dicom_dict,
                                           subject=subject,
                                           anon_subject=anon_subject,
                                           session=session),
                               self.series_is_valid(dicom_dict)
                               )
                              )
        return spec_dicts


    def _rules(self, series_dict, subject=None, anon_subject=None,
               session=None):

        protocol_name = series_dict.get('ProtocolName', None)
        run = _guess_run(self, series_dict)

        # TODO: Default numbering should still fill up leading zero(s)
        return {'description': series_dict['SeriesDescription'] if "SeriesDescription" in series_dict else '',
                'comment': 'trying to bidsify',
                'subject': self.read_subject_for_session_from_table(series_dict['PatientID']) if not subject else subject,
                'anon-subject': apply_bids_label_restrictions(anon_subject) if anon_subject else None,
                'bids-session': apply_bids_label_restrictions(series_dict['PatientID']) if series_dict['PatientID'] else None,
                'bids-modality': apply_bids_label_restrictions(_guess_modality(series_dict, self) ),
                'bids-task': apply_bids_label_restrictions(_guess_task(self, series_dict) ),
                'id': series_dict.get('SeriesNumber', 'unknown'),
		'bids-run' : apply_bids_label_restrictions( run )
                }

    # The table contains rows like "DTA003   T12122   T15722"
    # so if you find a T-value in the table, you know, that the
    # first field of that row contains the DTA003-value, that
    # I have to use as the subject-ID
    def get_column( self, t_value ):
	# TODO: check if the relative path with .. in the beginning works.
#         table_path = "/data/BnB1/DATA/source_data/DTA/code/dtage.tsv"
         table_path = "../dtage.tsv"
         with open( table_path, 'r' ) as table:
            for line in table:
               for part in line.split("\t"):
                  if t_value in part:
                     return str(line.split("\t").index(part))
         return None


    # this function reads a table and searches the given t-value (these are the session values for dta)
    # when it finds the session value, it retunrs the matching subject-ID from the table.
    def read_subject_for_session_from_table( self, t_value ):
        table_path = "/data/BnB1/DATA/source_data/DTA/code/dtage.tsv"
        with open( table_path, 'r' ) as table:
            for line in table:
                if t_value in line:
                   return line.replace("\n","\t").split("\t")[0]


    # TODO: maybe I sould use this function or build something equaly. Or delete it, if I am more sure about it.
    # anyways, ExamCard is not a protocol-name of DTA at all.
    def series_is_valid(self, series_dict):
        return series_dict['ProtocolName'] != 'ExamCard'


__datalad_hirni_rules = dta_DICOM2SpecRules
