#!/usr/bin/env python

#extraction NODDI images (OD, ISOVF, ICVF) of both GM and WM
import os
from glob import glob
from pathlib import Path

import nibabel as nib
import numpy as np
import pandas as pd

dict_list = []
subject_list = []
NODDI_dir = "/scratch/fogunsanya/dmri-microstructure/NODDI_volume_space_masked"
subject_dirs = glob(f"{NODDI_dir}/*")

for subject_dir in subject_dirs:
    subject = os.path.basename(subject_dir)
    subject_list.append(subject)
    scan_dict = {}
    scan_dict["subject_id"] = subject
    for indice in ["ICVF", "ISOVF", "OD"]:
        for mask in ["GM", "WM"]:
            image_path = f"{NODDI_dir}/{subject}/ses-01/dwi/{subject}_ses-01_space-MNI152NLin6Asym_desc-{indice}_NODDI_label-{mask}.nii.gz"
            img = nib.load(image_path)
            data = img.get_fdata()
            data = data[data>0]
            mean = np.around(data.mean(), 3)
            scan_dict[f"{indice}_{mask}"] = mean
    dict_list.append(scan_dict)
    
noddi_df = pd.DataFrame.from_dict(dict_list)

#need to add demographic dataframe
csv_demo = pd.read_csv("/scratch/fogunsanya/dmri-microstructure/tay_mri_demo.csv")
#need to rename and remove subjects not in subject_list
demo_subjects = csv_demo["subject_id"]
demo_subjects= demo_subjects.tolist()
for index,sub in enumerate(demo_subjects):
    id = sub.split("_")[-1]
    sub = f'sub-CMH{id}'
    demo_subjects[index] = sub
    if sub not in subject_list:
        demo_subjects[index] = ""#removing rows in which subject id are not in 

csv_demo["subject_id"]= demo_subjects
csv_demo= csv_demo[csv_demo.subject_id != ""]#eliminates rows in which subject id is missing

#replacing clinical diagnosis value
csv_demo = csv_demo.replace("No - participant has not received a previous clinical diagnosis of ASD", "False")
csv_demo= csv_demo.replace("Yes - participant has received a previous clinical diagnosis of ASD", "True")

merged_df = pd.merge(left=csv_demo, right=noddi_df, how='left', left_on='subject_id', right_on='subject_id')
print(merged_df)
filepath=Path('/scratch/fogunsanya/dmri-microstructure/TAY_Demo_NODDI_Measures.csv')#merged data final csv
merged_df.to_csv(filepath)