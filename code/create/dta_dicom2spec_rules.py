## rules for converting the dta-dicoms into a bids-dataset.

from datalad_hirni.support.BIDS_helper import apply_bids_label_restrictions


def _guess_modality(record, dcm_dict):

    protocol = record.get("ProtocolName", None)
    if protocol:

        # BEGIN Additional rule for forrest-structural
        # TODO: Probably to be moved to some rule enhancement
        if "VEN_BOLD" in protocol:
            # TODO: Not clear yet; swi might be considered a datatype rather than
            # a modality by respective BIDS extension:
            # https://docs.google.com/document/d/1kyw9mGgacNqeMbp4xZet3RnDhcMmf4_BmRgKaOkO2Sc
            return "swi"

        if "DTI_" in protocol:
            # TODO: What actually is the relevant part of protocol here?
            return "dwi"

        if "60dir".lower() in protocol.lower():
            return "dwi"
        if "120dir".lower() in protocol.lower():
            return "dwi"

        if "field map" in protocol:
            return "fieldmap"
        # END

        import re
        prot_parts = re.split('_|-|\s', protocol.lower())

        # this is a bad protocol name, but it is a resting state scan for pmu_rest and a task-bold if bold_task
        if protocol.lower() in "dta_epi_pmu_rest" or protocol.lower() in "DTA_ep2d_bold_Task".lower():
               return "bold"

########## Hier fuer DTA extra die Abfrage machen, ob Magnitude or phasediff
        image_type = record.get("ImageType", None)
        if image_type and "fieldmap" in protocol.lower():
                return "fieldmap"


        # I deleted "t2star" from that list for this specific dataset, because it does not contain these.
        # It would probably also be fine, if I had moved the "fieldmap" value to the start
        direct_search_terms = ["t1", "t1w", "t2", "t2w",
                               "t1rho", "t1map", "t2map", "flair",
                               "flash", "pd", "pdmap", "pdt2", "inplanet1",
                               "inplanet2", "angio", "dwi", "phasediff",
                               "phase1", "phase2", "magnitude1", "magnitude2",
                               "fieldmap", "epi", "meg"]

        for m in direct_search_terms:
            if m in prot_parts:
                return m
            if "mprage" in prot_parts:
                return "t1w"

        # BEGIN: Additional rule for forrest-structural
        # TODO: Probably to be moved to some rule enhancement
        if "st1w" in prot_parts:
            return "t1w"
        if "st2w" in prot_parts:
            return "t2w"
        if "tof" in prot_parts:
            return "angio"
        # END

        if "func" in prot_parts:
            return "bold"

    # found nothing, but modality isn't necessarily required
    return None

def _guess_task(dcm_dict, record):
    protocol = record.get("ProtocolName", None)
    count_if_same_protocol_but_scanned_earlier = 1
    #
    exp_flag = False

    if protocol:
        if protocol.lower() in "dta_epi_pmu_rest":
               return "rest"
        if protocol.lower() in "DTA_ep2d_bold_Task".lower():
            for elem in dcm_dict._dicom_series:
               if "DTA_ep2d_bold_Task".lower() in elem.get("ProtocolName").lower():
                  return ( "exp" + get_column( record.get("PatientID") ) )

        if "60dir".lower() in protocol.lower():
            return "60dir"
        if "120dir".lower() in protocol.lower():
            return "120dir"


        import re
        prot_parts = re.split('_|-|\s', protocol.lower())
        try:
            idx = prot_parts.index("task")
            task = prot_parts[idx + 1]
            return task
        except (ValueError, IndexError):
            # default to entire protocol name?
            # This should actually check the results of other guesses
            # (like modality) to determine a better default than nothing.
            # At least parts of the protocol name that were already matched elsewhere
            # should be excluded
            return None
    else:
        # default to entire protocol name?
        # see above
        return None



def _guess_run(dcm_dict, record):
        run = 1
        # vielleicht andere Variablen-Namen?
        protocol = record.get("ProtocolName")
        # the bold-tasks don't have runs.
        if "DTA_ep2d_bold_Task".lower() in protocol.lower():
              return "1"
        if "DTA_epi_pmu_rest".lower() in protocol.lower():
              return "1"

#        if "DTA_fieldmap_B0_gre_t2star".lower() in protocol.lower():
#              return "1" # here sollte nur ne Nummer sein, nicht das "run-"?
        if protocol:
            for elem in dcm_dict._dicom_series:
                if protocol in str(elem): ## change this..
                    if str(record) == str(elem):
                       return str(run)
                    run = run + 1
            return str(run)
        # default to None will lead to counting series with same protocol#
        return None


def get_column( t_value ):
     table_path = "/data/BnB1/DATA/source_data/DTA/code/dtage.tsv"
     with open( table_path, 'r' ) as table:
        for line in table:
           for part in line.split("\t"):
              if t_value in part:
                 return str(line.split("\t").index(part))
     return None



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

    # this function reads a table and searches the given t-value (these are the session values for dta)
    # when it finds the session value, it retunrs the matching subject-ID from the table.
    def read_subject_for_session_from_table( self, t_value ):
        table_path = "/data/BnB1/DATA/source_data/DTA/code/dtage.tsv"
        with open( table_path, 'r' ) as table:
            for line in table:
                if t_value in line:
                   return line.replace("\n","\t").split("\t")[0]




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
              #  'bids-run' : apply_bids_label_restrictions(_guess_run(self, series_dict)) if "ProtocolName" in series_dict else None
                }


    def series_is_valid(self, series_dict):
        return series_dict['ProtocolName'] != 'ExamCard'


__datalad_hirni_rules = dta_DICOM2SpecRules
