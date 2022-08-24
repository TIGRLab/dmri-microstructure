#!/usr/bin/env python
'''
Extraction NODDI images (OD, ISOVF, ICVF) of both GM and WM
Usage:
    07-Noddi Data Extraction.py <NODDI_direc> <Output_path> 
    
    Arguments:
    <NODDI_direc>    String of path to directory holding subject folders from NODDI outputs
    <Output_path>    String of path to the NODDI data csv 
'''
import os
from glob import glob
from pathlib import Path

from docopt import docopt
import nibabel as nib
import numpy as np
import pandas as pd

def main():
    arguments = docopt(__doc__)
    NODDI_direc = arguments['<NODDI_direc>']
    Output_path = arguments['<Output_path>']
    data_extraction(NODDI_direc,Output_path)
def data_extraction(NODDI_direc,Output_path):
    dict_list = []
    subject_list = []
    subject_dirs = glob(f"{NODDI_direc}/*")

    for subject_dir in subject_dirs:
        subject = os.path.basename(subject_dir)
        subject_list.append(subject)
        scan_dict = {}
        scan_dict["subject_id"] = subject
        for indice in ["ICVF", "ISOVF", "OD"]:
            for mask in ["GM", "WM"]:
                image_path = f"{NODDI_direc}/{subject}/ses-01/dwi/{subject}_ses-01_space-MNI152NLin6Asym_desc-{indice}_NODDI_label-{mask}.nii.gz"
                img = nib.load(image_path)
                data = img.get_fdata()
                data = data[data>0]
                mean = np.around(data.mean(), 3)
                scan_dict[f"{indice}_{mask}"] = mean
        dict_list.append(scan_dict)

    noddi_df = pd.DataFrame.from_dict(dict_list)
    filepath=Path(Output_path)
    noddi_df.to_csv(filepath)


if __name__ == "__main__":
    main()